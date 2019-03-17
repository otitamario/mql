//+------------------------------------------------------------------+
//|                                                    Donchian Fibo |
//|                               Copyright © 2015, Guilherme Santos |
//|                                               fishguil@gmail.com |
//|                                                                  |
//|                            Modified Version of Donchian Channels |
//|                                        By Luis Guilherme Damiani |
//|                                      http://www.damianifx.com.br |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2015, Guilherme Santos"
#property link      "fishguil@gmail.com"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 7 
//---- 7 plots are used
#property indicator_plots   7
//+-----------------------------------+
//| Parameters of indicator drawing   |
//+-----------------------------------+
//Escalas Fibo: 1, .786, .618, .5, .382, .214, .0
//---- drawing of the indicator as a line
#property indicator_type1   DRAW_LINE
//---- use olive color for the indicator line
#property indicator_color1 Blue
//---- indicator line is a solid curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  2
//---- indicator label display
#property indicator_label1  "Fibo 1.000"
//----
//---- drawing of the indicator as a line
#property indicator_type2   DRAW_LINE
//---- use gray color for the indicator line
#property indicator_color2 DeepSkyBlue
//---- indicator line is a solid curve
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width2  1
//---- indicator label display
#property indicator_label2  "Fibo 0.786"
//----
//---- drawing of the indicator as a line
#property indicator_type3   DRAW_LINE
//---- use pale violet red color for the indicator line
#property indicator_color3 Aqua
//---- indicator line is a solid curve
#property indicator_style3  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width3  1
//---- indicator label display
#property indicator_label3  "Fibo 0.618"
//----
//---- drawing of the indicator as a line
#property indicator_type4   DRAW_LINE
//---- use pale violet red color for the indicator line
#property indicator_color4 White
//---- indicator line is a solid curve
#property indicator_style4  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width4  2
//---- indicator label display
#property indicator_label4  "Fibo 0.500"
//----
//---- drawing of the indicator as a line
#property indicator_type5   DRAW_LINE
//---- use pale violet red color for the indicator line
#property indicator_color5 Yellow
//---- indicator line is a solid curve
#property indicator_style5  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width5  1
//---- indicator label display
#property indicator_label5  "Fibo 0.382"
//----
//---- drawing of the indicator as a line
#property indicator_type6   DRAW_LINE
//---- use pale violet red color for the indicator line
#property indicator_color6 Orange
//---- indicator line is a solid curve
#property indicator_style6  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width6  1
//---- indicator label display
#property indicator_label6  "Fibo 0.214"
//----
//---- drawing of the indicator as a line
#property indicator_type7   DRAW_LINE
//---- use pale violet red color for the indicator line
#property indicator_color7 Red
//---- indicator line is a solid curve
#property indicator_style7  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width7  2
//---- indicator label display
#property indicator_label7  "Fibo 0.000"
//+-----------------------------------+
//| Enumeration declaration           |
//+-----------------------------------+
enum Applied_Extrem //type of extreme points
  {
   HIGH_LOW,
   HIGH_LOW_OPEN,
   HIGH_LOW_CLOSE,
   OPEN_HIGH_LOW,
   CLOSE_HIGH_LOW
  };
//+-----------------------------------+
//| Input parameters of the indicator |
//+-----------------------------------+
input int FiboPeriod=72;                  // Period of averaging
input Applied_Extrem Extremes=HIGH_LOW;   // Type of extreme points
input int Margins=-2;
input int Shift=0;                        // Horizontal shift of the indicator in bars
//+-----------------------------------+
//---- indicator buffers
double Buffer1000[];
double Buffer0786[];
double Buffer0618[];
double Buffer0500[];
double Buffer0382[];
double Buffer0214[];
double Buffer0000[];
//+------------------------------------------------------------------+
//| Searching index of the highest bar                               |
//+------------------------------------------------------------------+
int iHighest(
             const double &array[],   // array for searching for maximum element index
             int count,               // the number of the array elements (from a current bar to the index descending), 
             // along which the searching must be performed.
             int startPos             // the initial bar index (shift relative to a current bar), 
             // the search for the greatest value begins from
             )
  {
//----
   int index=startPos;
//----checking correctness of the initial index
   if(startPos<0)
     {
      Print("Bad value in the function iHighest, startPos = ",startPos);
      return(0);
     }
//---- checking correctness of startPos value
   if(startPos-count<0)
      count=startPos;
//---
   double max=array[startPos];
//---- searching for an index
   for(int i=startPos; i>startPos-count; i--)
     {
      if(array[i]>max)
        {
         index=i;
         max=array[i];
        }
     }
//---- returning of the greatest bar index
   return(index);
  }
//+------------------------------------------------------------------+
//| Searching index of the lowest bar                                |
//+------------------------------------------------------------------+
int iLowest(
            const double &array[],// array for searching for minimum element index
            int count,// the number of the array elements (from a current bar to the index descending), 
            // along which the searching must be performed.
            int startPos //the initial bar index (shift relative to a current bar), 
            // the search for the lowest value begins from
            )
  {
   int index=startPos;
//----checking correctness of the initial index
   if(startPos<0)
     {
      Print("Bad value in the function iLowest, startPos = ",startPos);
      return(0);
     }
//---- checking correctness of startPos value
   if(startPos-count<0)
      count=startPos;
//---
   double min=array[startPos];
//---- searching for an index
   for(int i=startPos; i>startPos-count; i--)
     {
      if(array[i]<min)
        {
         index=i;
         min=array[i];
        }
     }
//---- returning of the lowest bar index
   return(index);
  }
//+------------------------------------------------------------------+    
//| Donchian Channel indicator initialization function               | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- turning a dynamic array into an indicator buffer
   SetIndexBuffer(0,Buffer1000,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by AroonShift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,FiboPeriod-1);
//--- create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Fibo 1.000");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//----
//---- turning a dynamic array into an indicator buffer
   SetIndexBuffer(1,Buffer0786,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,FiboPeriod-1);
//--- create label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Fibo 0.786");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//----
//---- turning a dynamic array into an indicator buffer
   SetIndexBuffer(2,Buffer0618,INDICATOR_DATA);
//---- shifting the indicator 3 horizontally
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,FiboPeriod-1);
//--- create label to display in DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Fibo 0.618");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//----
//---- turning a dynamic array into an indicator buffer
   SetIndexBuffer(3,Buffer0500,INDICATOR_DATA);
//---- shifting the indicator 3 horizontally
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,FiboPeriod-1);
//--- create label to display in DataWindow
   PlotIndexSetString(3,PLOT_LABEL,"Fibo 0.500");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//----
//---- turning a dynamic array into an indicator buffer
   SetIndexBuffer(4,Buffer0382,INDICATOR_DATA);
//---- shifting the indicator 3 horizontally
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,FiboPeriod-1);
//--- create label to display in DataWindow
   PlotIndexSetString(4,PLOT_LABEL,"Fibo 0.382");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//----
//---- turning a dynamic array into an indicator buffer
   SetIndexBuffer(5,Buffer0214,INDICATOR_DATA);
//---- shifting the indicator 3 horizontally
   PlotIndexSetInteger(5,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,FiboPeriod-1);
//--- create label to display in DataWindow
   PlotIndexSetString(5,PLOT_LABEL,"Fibo 0.214");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//----
//---- turning a dynamic array into an indicator buffer
   SetIndexBuffer(6,Buffer0000,INDICATOR_DATA);
//---- shifting the indicator 3 horizontally
   PlotIndexSetInteger(6,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,FiboPeriod-1);
//--- create label to display in DataWindow
   PlotIndexSetString(6,PLOT_LABEL,"Fibo 0.000");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(6,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//----
//---- initialization of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Donchian Fibo(Period = ",FiboPeriod,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| Donchian Channel iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<FiboPeriod+1) return(0);
//---- declaration of variables with a floating point  
   double smin=0,smax=0,sdiff=0;
//---- declaration of integer variables
   int first,bar;
//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated==0) // checking for the first start of the indicator calculation
     {
      first=FiboPeriod;    // starting number for calculation of all bars
     }
   else
     {
      first=prev_calculated-1; // starting number for calculation of new bars
     }
//---- main cycle of calculation of the channel
   for(bar=first; bar<rates_total; bar++)
     {
      switch(Extremes)
        {
         case HIGH_LOW:
            smax = high[iHighest(high,FiboPeriod,bar)];
            smin = low[iLowest(low,FiboPeriod,bar)];
            break;
            //---
         case HIGH_LOW_OPEN:
            smax = (open[iHighest(open,FiboPeriod,bar)]+high[iHighest(high,FiboPeriod,bar)])/2;
            smin = (open[iLowest(open,FiboPeriod,bar)]+low[iLowest(low,FiboPeriod,bar)])/2;
            break;
            //---
         case HIGH_LOW_CLOSE:
            smax = (close[iHighest(close,FiboPeriod,bar)]+high[iHighest(high,FiboPeriod,bar)])/2;
            smin = (close[iLowest(close,FiboPeriod,bar)]+low[iLowest(low,FiboPeriod,bar)])/2;
            break;
            //---
         case OPEN_HIGH_LOW:
            smax = open[iHighest(open,FiboPeriod,bar)];
            smin = open[iLowest(open,FiboPeriod,bar)];
            break;
            //---
         case CLOSE_HIGH_LOW:
            smax = close[iHighest(close,FiboPeriod,bar)];
            smin = close[iLowest(close,FiboPeriod,bar)];
            break;
        }
      sdiff=smax-smin;
      Buffer1000[bar] = smax;
      Buffer0786[bar] = smin + sdiff * .786;
      Buffer0618[bar] = smin + sdiff * .618;
      Buffer0500[bar] = smin + sdiff * .5;
      Buffer0382[bar] = smin + sdiff * .382;
      Buffer0214[bar] = smin + sdiff * .214;
      Buffer0000[bar] = smin;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
