//+------------------------------------------------------------------+
//|                                           Bollinger bands %b.mq5 |
//|                                   Copyright 2014, mohsen khashei |
//|                                               mkhashei@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, mohsen khashei"
#property link      "mkhashei@gmail.com"
#property version   "1.10"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot Label1
#property indicator_label1  "Bollinger bands %b"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_level1 0.0
#property indicator_level2 0.5
#property indicator_level3 1.0

//---- input parameters
input int    BBPeriod=20;        //Period
input int    BBShift=0;         // Shift
input double StdDeviation=2.0;  //Standard Deviation
input ENUM_APPLIED_PRICE appliedprc=PRICE_CLOSE; //Applied Price
//--- indicator buffers
double         UpperBuffer[];
double         LowerBuffer[];
double         MiddleBuffer[];
double         BLGBuffer[];
int    bbhandle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,BLGBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,MiddleBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,UpperBuffer ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,LowerBuffer ,INDICATOR_CALCULATIONS); 
    IndicatorSetInteger(INDICATOR_DIGITS,_Digits+2);
  
//    if(Bars(_Symbol,_Period)<60)
//  {
//  Alert("We have less than 60 bars for Indicator exited now!!");
//  return (-1);
//  
//  }
   bbhandle=iBands(NULL,0,BBPeriod,BBShift,StdDeviation,appliedprc);
    if(bbhandle<0){
  Alert("Can not create handle ",GetLastError(),"!!");
  return (-1);
  }
 //---
   return(INIT_SUCCEEDED);
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
//---
     int    i,limit;
//--- check for bars count
   if(rates_total<BBPeriod)
      return(0);
   int calculated=BarsCalculated(bbhandle);
   if(calculated<rates_total)
     {
      Print("Not all data of BB is calculated (",calculated,"bars ). Error",GetLastError());
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
   if(CopyBuffer(bbhandle,1,0,to_copy,UpperBuffer)<=0||CopyBuffer(bbhandle,2,0,to_copy,LowerBuffer)<=0||
   CopyBuffer(bbhandle,0,0,to_copy,MiddleBuffer)<=0)
     {
      Print("Getting BB data is failed! Error",GetLastError());
      return(0);
     }
//--- preliminary calculations
   limit=prev_calculated-1;
   if(limit<BBPeriod)
      limit=BBPeriod;
//--- the main loop of calculations
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      BLGBuffer[i]=(close[i]-LowerBuffer[i])/(UpperBuffer[i]-LowerBuffer[i]);
     }
     
   return(rates_total);
  }
//+------------------------------------------------------------------+
