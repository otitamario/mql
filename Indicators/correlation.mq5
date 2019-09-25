

//+------------------------------------------------------------------
#property copyright   "mladen"
#property link        "mladenfx@gmail.com"
#property link        "https://www.mql5.com"
#property description "Correlation"
//+------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDimGray,clrLimeGreen,clrCrimson
#property indicator_width1  2
#property indicator_level1  0.8
#property indicator_level2 -0.8
//--- input parameters
enum enColorMode
  {
   clm_displayColorLine,      // Display two colored line
   clm_displaySingleColorLine // Display single colored line
  };
input int         inpPeriod    = 14;                   // Correlation period
input string      inpSymbol1   = "";                   // First symbol (leave empty for current chart symbol)
input string      inpSymbol2   = "USDCHF";             // Second symbol (leave empty for current chart symbol)
input enColorMode inpColorMode = clm_displayColorLine; // Line colors :


//--- buffers and global variables declarations
double corr[],corrc[],diff1[],diff2[];
int _handle1,_handle2; string _symbol1,_symbol2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,corr,INDICATOR_DATA);
   SetIndexBuffer(1,corrc,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,diff1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,diff2,INDICATOR_CALCULATIONS);
//---
   _symbol1 = (inpSymbol1=="" ? _Symbol : inpSymbol1);
   _symbol2 = (inpSymbol2=="" ? _Symbol : inpSymbol2);
   _handle1 = iMA(_symbol1,0,inpPeriod,0,MODE_SMA,PRICE_CLOSE); if(_handle1==INVALID_HANDLE) {                             return(INIT_FAILED); }
   _handle2 = iMA(_symbol2,0,inpPeriod,0,MODE_SMA,PRICE_CLOSE); if(_handle2==INVALID_HANDLE) { IndicatorRelease(_handle1); return(INIT_FAILED); }
//---
   IndicatorSetString(INDICATOR_SHORTNAME,_symbol1+" to "+_symbol2+" correlation ("+(string)inpPeriod+")");
   //---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator de-initialization function                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(_handle1!=INVALID_HANDLE) IndicatorRelease(_handle1);
   if(_handle2!=INVALID_HANDLE) IndicatorRelease(_handle2);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Bars(_Symbol,_Period)<rates_total) return(prev_calculated);
   if(BarsCalculated(_handle1)<0 || BarsCalculated(_handle2)<0) return(prev_calculated);
   if(!_symbolCheck(_symbol1,_Period))  return(prev_calculated);
   if(!_symbolCheck(_symbol2,_Period))  return(prev_calculated);

   double   _val[1];
   MqlRates _rates[1];
   int i=(int)MathMax(prev_calculated-1,1); for(; i<rates_total && !_StopFlag; i++)
     {
      corr[i]=EMPTY_VALUE;
      int _copied=CopyBuffer(_handle1,0,time[i],1,_val);  if(_copied!=1) continue;
      _copied = CopyRates(_symbol1,0,time[i],1,_rates); if(_copied!=1) continue;
      diff1[i]=_rates[0].close -_val[0];
      _copied = CopyBuffer(_handle2,0,time[i],1,_val);  if(_copied!=1) continue;
      _copied = CopyRates(_symbol2,0,time[i],1,_rates); if(_copied!=1) continue;
      diff2[i]=_rates[0].close -_val[0];

      double sum=0,sump1=0,sump2=0;
      for(int k=0; k<inpPeriod && (i-k)>=0; k++)
        {
         sum   += diff1[i-k]*diff2[i-k];
         sump1 += diff1[i-k]*diff1[i-k];
         sump2 += diff2[i-k]*diff2[i-k];
        }
      corr[i]  = (sump1*sump2!=0) ? sum/MathSqrt(sump1*sump2) : 0;
      corrc[i] = (inpColorMode==clm_displaySingleColorLine) ? 0 : (corr[i]>0) ? 1 : 2;
     }
   return (i);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int    _tfsPer[]={PERIOD_M1,PERIOD_M2,PERIOD_M3,PERIOD_M4,PERIOD_M5,PERIOD_M6,PERIOD_M10,PERIOD_M12,PERIOD_M15,PERIOD_M20,PERIOD_M30,PERIOD_H1,PERIOD_H2,PERIOD_H3,PERIOD_H4,PERIOD_H6,PERIOD_H8,PERIOD_H12,PERIOD_D1,PERIOD_W1,PERIOD_MN1};
string _tfsStr[]={"1 minute","2 minutes","3 minutes","4 minutes","5 minutes","6 minutes","10 minutes","12 minutes","15 minutes","20 minutes","30 minutes","1 hour","2 hours","3 hours","4 hours","6 hours","8 hours","12 hours","daily","weekly","monthly"};
//+------------------------------------------------------------------+
//| Custom functions                                                 |
//+------------------------------------------------------------------+
string timeFrameToString(int period)
  {
   if(period==PERIOD_CURRENT)
      period=_Period;
   int i; for(i=0;i<ArraySize(_tfsPer);i++) if(period==_tfsPer[i]) break;
   return(_tfsStr[i]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool _symbolCheck(string _symbol,ENUM_TIMEFRAMES _timeFrame)
  {
   datetime _time[1];
   int _timeCopied=CopyTime(_symbol,_timeFrame,Bars(_symbol,_timeFrame)-1,1,_time);
   if(_timeCopied==1)
     {
      static bool warned=false;
      if(_time[0]<SeriesInfoInteger(_symbol,_timeFrame,SERIES_FIRSTDATE))
        {
         datetime startTime,testTime[];
         if(SeriesInfoInteger(_symbol,PERIOD_M1,SERIES_TERMINAL_FIRSTDATE,startTime))
         if(startTime>0)                        { CopyTime(_symbol,_timeFrame,_time[0],1,testTime); SeriesInfoInteger(_symbol,_timeFrame,SERIES_FIRSTDATE,startTime); }
         if(startTime<=0 || startTime>_time[0]) { Comment(MQL5InfoString(MQL5_PROGRAM_NAME)+"\nMissing data for "+_symbol+" "+timeFrameToString(_timeFrame)+" time frame\nRe-trying on next tick"); warned=true; return(false); }
        }
      if(warned) { Comment(""); warned=false; }
     }
   return(true);
  }
//+------------------------------------------------------------------+
