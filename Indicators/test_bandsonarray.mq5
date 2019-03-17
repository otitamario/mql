//+------------------------------------------------------------------+
//|                                            Test_BandsOnArray.mq5 |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3
//--- plot Label1
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Label2
#property indicator_label2  "Label2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Label3
#property indicator_label3  "Label3"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

input int            BBPeriod    =  10;
input ENUM_MA_METHOD BBMethod    =  MODE_SMA;
input double         BBDeviation =  2;

//--- indicator buffers
double         UBuffer[];
double         LBuffer[];
double         CBuffer[];
double         data[];

#include <IncOnArray/IncBandsOnArray.mqh>
CBandsOnArray bb;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   bb.Init(BBPeriod,BBMethod,BBDeviation);

//--- indicator buffers mapping
   SetIndexBuffer(0,UBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,CBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,data,INDICATOR_CALCULATIONS);

   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,bb.BarsRequired());
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,bb.BarsRequired());
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,bb.BarsRequired());

   PlotIndexSetString(0,PLOT_LABEL,bb.Name()+" Upper");
   PlotIndexSetString(1,PLOT_LABEL,bb.Name()+" Lower");
   PlotIndexSetString(2,PLOT_LABEL,bb.Name()+" MA");
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   int start;
   if(prev_calculated>0)
     {
      start=prev_calculated-1;
     }
   else
     {
      start=0;
     }
   for(int i=start;i<rates_total;i++)
     {
      data[i]=price[i];
     }

   bb.Solve(rates_total,prev_calculated,data,CBuffer,UBuffer,LBuffer);

   return(rates_total);
  }
//+------------------------------------------------------------------+
