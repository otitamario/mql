//+------------------------------------------------------------------+
//|                                                    Envelopes.mq5 |
//|                   Copyright 2009-2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009-2017, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Blue
#property indicator_label1  "Diferença ADX+ e ADX-"
#property indicator_level1 0.0
//--- input parameters
input int                InpMAPeriod=14;              // Periodo ADX
//--- indicator buffers
double                   DiffBuffer[];
double                   ADXPBuffer[];
double                   ADXNBuffer[];
//--- MA handle
int                      ADXHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,DiffBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ADXPBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,ADXNBuffer,INDICATOR_CALCULATIONS);
//---
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpMAPeriod-1);
//--- name for DataWindow
   IndicatorSetString(INDICATOR_SHORTNAME,"DiffADX("+string(InpMAPeriod)+")");
   PlotIndexSetString(0,PLOT_LABEL,"DiffADX("+string(InpMAPeriod)+")");
   
//---
   ADXHandle=iADX(NULL,0,InpMAPeriod);
   if(ADXHandle<0){
  Alert("Can not create handle ",GetLastError(),"!!");
  //return(-1);
  }
//--- initialization done
  //return(0);
  }
//+------------------------------------------------------------------+
//|                                                         |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   int    i,limit;
//--- check for bars count
   if(rates_total<InpMAPeriod)
      return(0);
   int calculated=BarsCalculated(ADXHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ADXHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
//--- we can copy not all data
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
//---- get ma buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ADXHandle,1,0,to_copy,ADXPBuffer)<=0||CopyBuffer(ADXHandle,2,0,to_copy,ADXNBuffer)<=0)
     {
      Print("Getting ADX data is failed! Error",GetLastError());
      return(0);
     }
//--- preliminary calculations
   limit=prev_calculated-1;
   if(limit<InpMAPeriod)
      limit=InpMAPeriod;
//--- the main loop of calculations
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      DiffBuffer[i]=ADXPBuffer[i]-ADXNBuffer[i];
     }
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+
