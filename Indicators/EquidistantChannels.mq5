//+------------------------------------------------------------------+
//|                                          EquidistantChannels.mq5 |
//|                                           Copyright 2016, denkir |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, denkir"
#property link      "https://www.mql5.com"
#property version   "1.00"
//--- include
#include <CFractalPoint.mqh>
//---
#property description "Equidistant channel indicator,"
#property description "plotted based on fractals"
//---
#define BUFF_NUM 5
#property indicator_chart_window
#property indicator_buffers BUFF_NUM             // indicator buffers
#property indicator_plots   5                    // plotting series
//--- plot UpFractals
#property indicator_label1  "Up Fractals"        // label 1
#property indicator_type1   DRAW_ARROW           // type of line 1
#property indicator_color1  clrDodgerBlue        // color of line 1
#property indicator_style1  STYLE_SOLID          // style of line 1
#property indicator_width1  1                    // width of line 1
//--- plot DnFractals
#property indicator_label2  "Down Fractals"      // label 2
#property indicator_type2   DRAW_ARROW           // type of line 2
#property indicator_color2  clrTomato            // color of line 2
#property indicator_style2  STYLE_SOLID          // style of line 2
#property indicator_width2  1                    // width of line 2
//--- plot Upper Border
#property indicator_label3  "Upper Border"       // label 3
#property indicator_type3   DRAW_LINE            // type of line 3
#property indicator_color3  clrSteelBlue         // color of line 3
#property indicator_width3  2                    // width of line 3
//--- plot Lower Border
#property indicator_label4  "Lower Border"       // label 4
#property indicator_type4   DRAW_LINE            // type of line 4
#property indicator_color4  clrOrchid            // color of line 4
#property indicator_width4  2                    // width of line 4
//---
#property indicator_label5  "New channel"        // label 5
#property indicator_type5   DRAW_NONE            // type of line 5

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input int InpPrevFracNum=3;                        // Previous fractals
input bool InpToPlotFracs=true;                    // Display fractals?
input int InpBarsBeside=10;                        // Bars on the left/right of fractal
input int InpBarsBetween=1;                        // Intermediate bars
input ENUM_RELEVANT_EXTREMUM InpRelevantPoint=RELEVANT_EXTREMUM_PREV; // Relevant point
sinput int InpLineWidth=3;                         // Line width
sinput bool InpToLog=true;                         // Keep the log?
//+------------------------------------------------------------------+
//| Globals                                                          |
//+------------------------------------------------------------------+
double gUpFractalsBuffer[]; // buffer of upper fractals
double gDnFractalsBuffer[]; // buffer of lower fractals
double gUpperBuffer[];      // buffer of upper line
double gLowerBuffer[];      // buffer of lower line
double gNewChannelBuffer[]; // buffer of new channel
CFractalSet gFracSet;       // set of fractal points 
//---
int gMinRequiredBars;
int gLeftSide,gRightSide;
int gMaxSide;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- checking 
   if(InpBarsBeside<1)
     {
      gLeftSide=gRightSide=2;

      PrintFormat("Invalid parameter value  \"Number of bars on the left/right of fractal\": %d. The value to be used: %d.",
                  InpBarsBeside,gLeftSide);
        } else {
      gLeftSide=gRightSide=InpBarsBeside;
     }
//--- minimum number of required bars
   gMinRequiredBars=gLeftSide+gRightSide+1;
   gMaxSide=gLeftSide;
//--- buffer mapping
   SetIndexBuffer(0,gUpFractalsBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,gDnFractalsBuffer,INDICATOR_DATA);

//--- if should not be displayed
   if(!InpToPlotFracs)
      for(int i=0;i<2;i++)
         PlotIndexSetInteger(i,PLOT_DRAW_TYPE,DRAW_NONE);
//--- arrow codes
   PlotIndexSetInteger(0,PLOT_ARROW,217);
   PlotIndexSetInteger(1,PLOT_ARROW,218);
//--- arrow shift
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);
//--- display settings
   for(int i=0;i<2;i++)
     {
      PlotIndexSetInteger(i,PLOT_DRAW_BEGIN,gMinRequiredBars);
      PlotIndexSetDouble(i,PLOT_EMPTY_VALUE,0.0);
     }
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- buffer mapping
   SetIndexBuffer(2,gUpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,gLowerBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,gNewChannelBuffer,INDICATOR_DATA);
//--- display settings
   for(int buff_idx=2;buff_idx<BUFF_NUM;buff_idx++)
      PlotIndexSetDouble(buff_idx,PLOT_EMPTY_VALUE,0.); 
//---
   return INIT_SUCCEEDED;
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
//--- if there were no bars at the previous call
   if(prev_calculated==0)
     {
      //--- zero out the buffers
      ArrayInitialize(gUpFractalsBuffer,0.);
      ArrayInitialize(gDnFractalsBuffer,0.);
      ArrayInitialize(gUpperBuffer,0.);
      ArrayInitialize(gLowerBuffer,0.);
      ArrayInitialize(gNewChannelBuffer,0.);
     }
//--- Calculation for fractals [start]
   int startBar,lastBar;
//---
   if(rates_total<gMinRequiredBars)
     {
      Print("Not enough data for calculation");
      return 0;
     }
//---
   if(prev_calculated<gMinRequiredBars)
      startBar=gLeftSide;
   else
      startBar=rates_total-gMinRequiredBars;
//---
   lastBar=rates_total-gRightSide;
   for(int bar_idx=startBar; bar_idx<lastBar && !IsStopped(); bar_idx++)
     {
      //---
      if(isUpFractal(bar_idx,gMaxSide,high))
         gUpFractalsBuffer[bar_idx]=high[bar_idx];
      else
         gUpFractalsBuffer[bar_idx]=0.0;
      //---
      if(isDnFractal(bar_idx,gMaxSide,low))
         gDnFractalsBuffer[bar_idx]=low[bar_idx];
      else
         gDnFractalsBuffer[bar_idx]=0.0;
     }
//--- Calculation for fractals [end]

//--- Calculation for channel borders [start]
   if(prev_calculated>0)
     {
      //--- if the set had not been initialized
      if(!gFracSet.IsInit())
         if(!gFracSet.Init(
            InpPrevFracNum,
            InpBarsBeside,
            InpBarsBetween,
            InpRelevantPoint,
            InpLineWidth,
            InpToLog
            ))
           {
            Print("Fractal set initialization error!");
            return 0;
           }
      //--- calculation
      gFracSet.Calculate(gUpFractalsBuffer,gDnFractalsBuffer,time,
                         gUpperBuffer,gLowerBuffer,
                         gNewChannelBuffer
                         );
     }
//--- Calculation for channel borders [end]

//--- return value of prev_calculated for next call
   return rates_total;
  }
//+------------------------------------------------------------------+
//| Check if is Up Fractal function                                  |
//+------------------------------------------------------------------+
bool isUpFractal(int bar,int max,const double &High[])
  {
//---
   for(int i=1; i<=max; i++)
     {
      if(i<=gLeftSide && High[bar]<High[bar-i])
         return false;
      if(i<=gRightSide && High[bar]<=High[bar+i])
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Check if is Down Fractal function                                |
//+------------------------------------------------------------------+
bool isDnFractal(int bar,int max,const double &Low[])
  {
//---
   for(int i=1; i<=max; i++)
     {
      if(i<=gLeftSide && Low[bar]>Low[bar-i])
         return false;
      if(i<=gRightSide && Low[bar]>=Low[bar+i])
         return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
