//+------------------------------------------------------------------+
//|                                      Elliott Wave Oscillator.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, Hossein Nouri"
#property description "Fully Coded By Hossein Nouri"
#property description "Email : hsn.nouri@gmail.com"
#property description "Skype : hsn.nouri"
#property description "MQL5 Profile : https://www.mql5.com/en/users/hsnnouri"
#property description " "
#property description "Feel free to contact me for MQL4/MQL5 coding."
#property link      "https://www.mql5.com/en/users/hsnnouri"
#property version   "1.00"
#include <MovingAverages.mqh>
//--- indicator settings
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   2
//--- plot EWO
#property indicator_label1  "EWO"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrLime,clrRed,clrMaroon
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_label2  "MA"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_DOT
#property indicator_width2  1

//--- input parameters
input int                     InpFastMA=5;                                                //Fast Period
input int                     InpSlowMA=35;                                               //Slow Period
input ENUM_APPLIED_PRICE      InpPriceSource=PRICE_MEDIAN;                                //Apply to
input ENUM_MA_METHOD          InpSmoothingMethod=MODE_SMA;                                //Method
input string                  Desc="************ Moving Average of EWO ************";     //Description
input bool                    InpShowMA=true;                                             //Show MA
input int                     InpMaPeriod=5;                                              //Period
input ENUM_MA_METHOD          InpMaMethod=MODE_SMA;                                       //Method
//--- indicator buffers
double         EWOBuffer[];
double         EWOColors[];
double         MABuffer[];
double         FastMABuffer[];
double         SlowMABuffer[];
//Variables
int FastMaHandle,SlowMaHandle;
int Begin;
int WeightedSum;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   Begin=MathMax(InpFastMA,InpSlowMA);
   SetIndexBuffer(0,EWOBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,EWOColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,MABuffer,INDICATOR_DATA);
   SetIndexBuffer(3,FastMABuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,SlowMABuffer,INDICATOR_CALCULATIONS);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Begin);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,Begin+InpMaPeriod);

   IndicatorSetString(INDICATOR_SHORTNAME,"EWO("+string(InpFastMA)+","+string(InpSlowMA)+")");
   PlotIndexSetString(0,PLOT_LABEL,"EWO("+string(InpFastMA)+","+string(InpSlowMA)+")");
   PlotIndexSetString(1,PLOT_LABEL,"MA("+string(InpMaPeriod)+")");
   FastMaHandle=iMA(_Symbol,_Period,InpFastMA,0,InpSmoothingMethod,InpPriceSource);
   SlowMaHandle=iMA(_Symbol,_Period,InpSlowMA,0,InpSmoothingMethod,InpPriceSource);

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
   if(rates_total < MathMax(InpSlowMA,InpFastMA)+InpMaPeriod)    return(0);
//--- not all data may be calculated
   int calculated=BarsCalculated(FastMaHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtFastMaHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
   calculated=BarsCalculated(SlowMaHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtSlowMaHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }

   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
   if(CopyBuffer(FastMaHandle,0,0,to_copy,FastMABuffer)<=0)
     {
      Print("Getting fast EMA is failed! Error",GetLastError());
     }
   if(CopyBuffer(SlowMaHandle,0,0,to_copy,SlowMABuffer)<=0)
     {
      Print("Getting slow SMA is failed! Error",GetLastError());
     }

   int limit;
   if(prev_calculated==0)
      limit=MathMax(InpSlowMA,InpFastMA);
   else limit=prev_calculated-1;

   for(int i=limit;i<rates_total && !IsStopped();i++)
     {
      CalculateValue(i);
     }
   CalculateMA(rates_total,prev_calculated,limit);

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
void CalculateValue(int index)
  {
   EWOBuffer[index]=FastMABuffer[index]-SlowMABuffer[index];

   if(EWOBuffer[index]==EWOBuffer[index-1])
     {
      EWOColors[index]=EWOColors[index-1];
      return;
     }
   if(EWOBuffer[index]>0)
     {
      if(EWOBuffer[index]>EWOBuffer[index-1])
        {
         EWOColors[index]=1;
         return;
        }
      if(EWOBuffer[index]<EWOBuffer[index-1])
        {
         EWOColors[index]=0;
         return;
        }
     }
   if(EWOBuffer[index]<0)
     {
      if(EWOBuffer[index]>EWOBuffer[index-1])
        {
         EWOColors[index]=3;
         return;
        }
      if(EWOBuffer[index]<EWOBuffer[index-1])
        {
         EWOColors[index]=2;
         return;
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateMA(const int &rates_total,const int &prev_calculated,int limit)
  {
   if(InpShowMA==true)
     {
      if(InpMaMethod==MODE_SMA)
        {
         SimpleMAOnBuffer(rates_total,prev_calculated,Begin+InpMaPeriod,InpMaPeriod,EWOBuffer,MABuffer);
         return;
        }
      if(InpMaMethod==MODE_LWMA)
        {

         LinearWeightedMAOnBuffer(rates_total,prev_calculated,Begin+InpMaPeriod,InpMaPeriod,EWOBuffer,MABuffer,WeightedSum);
         return;
        }
      if(InpMaMethod==MODE_EMA)
        {
         ExponentialMAOnBuffer(rates_total,prev_calculated,Begin+InpMaPeriod,InpMaPeriod,EWOBuffer,MABuffer);
         return;
        }
      if(InpMaMethod==MODE_SMMA)
        {
         SmoothedMAOnBuffer(rates_total,prev_calculated,Begin+InpMaPeriod,InpMaPeriod,EWOBuffer,MABuffer);
         return;
        }
     }
   ArrayInitialize(MABuffer,EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
