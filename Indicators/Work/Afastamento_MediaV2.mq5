//+------------------------------------------------------------------+
//|                                                    EMA_Angle.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description   ""
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot HistEMA
#property indicator_label1  "Afastamento Media"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrGreen,clrRed,clrYellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  4
//--- input parameters
input int      InpPeriod=7;   // Period EMA
input ENUM_APPLIED_PRICE InpApplied=PRICE_CLOSE;//Applied Price
//--- indicator buffers
double         BufferDist[];
double         BufferDistColors[];
double         BufferTMP[];
//--- global variables
int            period;
int            handle_ema;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set parameters
   period=(InpPeriod<1 ? 1 : InpPeriod);
   handle_ema=iMA(NULL,0,period,0,MODE_EMA,InpApplied);
   if(handle_ema==INVALID_HANDLE)
     {
      Print("Failed to create an EMA handle");
      return INIT_FAILED;
     }
   ChartIndicatorAdd(ChartID(),0,handle_ema);
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferDist,INDICATOR_DATA);
   SetIndexBuffer(1,BufferDistColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,BufferTMP,INDICATOR_CALCULATIONS);
//--- colors parameters
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,0,clrGreen);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,1,clrRed);
   PlotIndexSetInteger(1,PLOT_LINE_COLOR,2,clrYellow);
//--- strings parameters
   string params="("+(string)period+")";
   IndicatorSetString(INDICATOR_SHORTNAME,"Afastamento Media"+params);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(handle_ema);
   ChartIndicatorDelete(ChartID(),0,"MA("+string(InpPeriod)+")");

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
//--- Checking for minimum number of bars
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
   CopyBuffer(handle_ema,0,0,to_copy,BufferTMP);

   for(int i=MathMax(2,prev_calculated-1); i<rates_total;i++)
     {

      if(high[i]-BufferTMP[i]>BufferTMP[i]-low[i])BufferDist[i]=high[i]-BufferTMP[i];
      else BufferDist[i]=low[i]-BufferTMP[i];
      if(BufferDist[i]>=0)
         BufferDistColors[i]=0;
      else BufferDistColors[i]=1;

     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
