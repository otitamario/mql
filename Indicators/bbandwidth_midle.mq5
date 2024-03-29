//+------------------------------------------------------------------+
//|                                                   BBandwidth.mq5 |
//|                        Copyright Copyright 2010, Investors Haven |
//|                                    http://www.InvestorsHaven.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, Investors Haven"
#property link      "http://www.InvestorsHaven.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot BBBandwidth
#property indicator_label1  "BBandwidth"
#property indicator_type1   DRAW_LINE
#property indicator_color1  Purple
#property indicator_style1  STYLE_SOLID
#property indicator_width1  3

// --- Inputs
input int     InpBandsPeriod=20;       // Period
input int     InpBandsShift=0;         // Shift
input double  InpBandsDeviations=2.0;  // Deviation

input double  InpNivel1=0.002;  // Nível 1
input double  InpNivel2=0.006;  // Nível 2
input double  InpNivel3=0.015;  // Nível 3
input double  InpNivel4=0.020;  // Nível 4

                                       // --- BollingerBand handle
int BBHandle;
//--- indicator buffers
double         BBandwidthBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BBandwidthBuffer,INDICATOR_DATA);
/*
   saving processing time by making calls to the iBands indicator to get the upper and 
   lower band values, then we just perform a simple calculation to output the result
   to a single indicator on a seperate chart window.
*/
   BBHandle=iBands(_Symbol,PERIOD_CURRENT,InpBandsPeriod,InpBandsShift,InpBandsDeviations,PRICE_CLOSE);
   IndicatorSetInteger(INDICATOR_DIGITS,4);
   
   IndicatorSetInteger(INDICATOR_LEVELS,4);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,0,InpNivel1);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,1,InpNivel2);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,2,InpNivel3);
   IndicatorSetDouble(INDICATOR_LEVELVALUE,3,InpNivel4);

   IndicatorSetInteger(INDICATOR_LEVELCOLOR,0,clrRed);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,1,clrRed);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,2,clrLime);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR,3,clrLime);


//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//--- variables
   int pos=0;
   double upper_band[];
   double lower_band[];
   double middle_band[];

// --- Turn the arrays into dynamic series arrays   
   ArraySetAsSeries(lower_band,true);
   ArraySetAsSeries(upper_band,true);
   ArraySetAsSeries(middle_band,true);

   ArraySetAsSeries(BBandwidthBuffer,true);

//--- check if all data calculated
   if(BarsCalculated(BBHandle)<rates_total) return(0);
//--- we can copy all data
   if(CopyBuffer(BBHandle,0,0,rates_total,middle_band) <=0) return(0);
   if(CopyBuffer(BBHandle,1,0,rates_total,upper_band) <=0) return(0);
   if(CopyBuffer(BBHandle,2,0,rates_total,lower_band) <=0) return(0);

/*
   Now loop through the rates_total to populate the  the buffer with the calculation
   needed to get the bandwidth of the bollinger bands.  Using a switch on the digits
   value to determine the decimal calculation offset so that result is consistent.
*/
   for(int i=pos;i<rates_total -1;i++)
     {
                  BBandwidthBuffer[i]=(upper_band[i]-lower_band[i])/middle_band[i];

     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
