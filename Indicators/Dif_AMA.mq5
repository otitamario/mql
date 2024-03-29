//+------------------------------------------------------------------+
//|                                                    Envelopes.mq5 |
//|                   Copyright 2009-2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009-2017, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Blue
#property indicator_label1  "Diferença AMA"
#property indicator_level1 10.0
#property indicator_level2 -10.0
//--- input parameters
input int                AMA_PeriodMA1                  =7;          // Adaptive Moving Average(10,...) Period of averaging
input int                AMA_PeriodFast1                =5;           // Adaptive Moving Average(10,...) Period of fast EMA
input int                AMA_PeriodSlow1                =30;          // Adaptive Moving Average(10,...) Period of slow EMA
input int                AMA_Shift1                     =0;           // Adaptive Moving Average(10,...) Time shift
input ENUM_APPLIED_PRICE Applied_Price_MA_1            =PRICE_MEDIAN; // Adaptive Moving Average(10,...) Prices series
//--- indicator buffers
double                  DiffBuffer[],AMA1_Buffer[];
;
//--- MA handle
int                      AMA1Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,DiffBuffer,INDICATOR_DATA);

   SetIndexBuffer(1,AMA1_Buffer,INDICATOR_CALCULATIONS);
 
   IndicatorSetInteger(INDICATOR_DIGITS,2);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,AMA_PeriodSlow1-1);
//--- name for DataWindow
   IndicatorSetString(INDICATOR_SHORTNAME,"DiffAMA");
   PlotIndexSetString(0,PLOT_LABEL,"DiffAMA");
   
//---
   AMA1Handle=iAMA(NULL,0,AMA_PeriodMA1,AMA_PeriodFast1,AMA_PeriodSlow1,AMA_Shift1,Applied_Price_MA_1);
   if(AMA1Handle<0){
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
   if(rates_total<AMA_PeriodSlow1)
      return(0);
   int calculated=BarsCalculated(AMA1Handle);
   if(calculated<rates_total)
     {
      Print("Not all data of AMA1Handle is calculated (",calculated,"bars ). Error",GetLastError());
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
   if(CopyBuffer(AMA1Handle,0,0,to_copy,AMA1_Buffer)<=0)
     {
      Print("Getting AMA data is failed! Error",GetLastError());
      return(0);
     }
//--- preliminary calculations
   limit=prev_calculated-1;
   if(limit<AMA_PeriodSlow1)
      limit=AMA_PeriodSlow1;
//--- the main loop of calculations
   for(i=i=MathMax(3,prev_calculated-1);i<rates_total && !IsStopped();i++)
     {
      DiffBuffer[i]=AMA1_Buffer[i]-AMA1_Buffer[i-1];
     }
//--- done
   return(rates_total);
  }
//+------------------------------------------------------------------+
