//+------------------------------------------------------------------+ 
//|                                   PercentageCrossoverChannel.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 3 
//---- three plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- green color is used for the indicator line
#property indicator_color1 Green
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Upper PC Channel"

//---- drawing the indicator as a line
#property indicator_type2   DRAW_LINE
//---- blue color is used for the indicator line
#property indicator_color2 Blue
//---- the indicator line is a continuous curve
#property indicator_style2  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "Middle PC Channel"

//---- drawing the indicator as a line
#property indicator_type3   DRAW_LINE
//---- magenta color is used for the indicator line
#property indicator_color3 Magenta
//---- the indicator line is a continuous curve
#property indicator_style3  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width3  1
//---- displaying the indicator label
#property indicator_label3  "Lower PC Channel"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input double percent=1.0; // Percentage price deviation from the indicator previous value
input int Shift=0;        // Horizontal shift of the indicator in bars
//+-----------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double UpperBuffer[];
double MiddleBuffer[];
double LowerBuffer[];
//---- declaration of global variables
double plusvar,minusvar;
//---- Declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+    
//| Custom indicator indicator initialization function               | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialize constants
   min_rates_total=2;
   double var1=percent/100;
   plusvar=1+var1;
   minusvar=1-var1;
   
//---- set UpperBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by AroonShift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set MiddleBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,MiddleBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the start of drawing the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set LowerBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(2,LowerBuffer,INDICATOR_DATA);
//---- shifting the indicator 3 horizontally
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the start of drawing the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Percentage Crossover Channel(percent = ",percent,")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const int begin,          // bars reliable counting beginning index
                const double &price[])    // price array for the indicator calculation
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total+begin) return(0);

//---- declaration of integer variables
   int first,bar,bar1;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated==0) // checking for the first start of the indicator calculation
     {
      first=1+begin;      // starting index for calculation of all bars
      MiddleBuffer[first-1]=price[first-1];
      //---- performing the shift of the beginning of the indicators drawing
      PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+begin);
      PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+begin);
      PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total+begin);
     }
   else // starting index for calculation of new bars
     {
      first=prev_calculated-1;
     }

//---- main cycle of calculation of the channel center line
   for(bar=first; bar<rates_total; bar++)
     {
      bar1=bar-1;
      if((price[bar]*minusvar)>MiddleBuffer[bar1]) MiddleBuffer[bar]=price[bar]*minusvar;
      else
        {
         if(price[bar]*plusvar<MiddleBuffer[bar1]) MiddleBuffer[bar]=price[bar]*plusvar;
         else MiddleBuffer[bar]=MiddleBuffer[bar1];
        }

      UpperBuffer[bar]=MiddleBuffer[bar] + (MiddleBuffer[bar]/100) * percent;
      LowerBuffer[bar]=MiddleBuffer[bar] - (MiddleBuffer[bar]/100) * percent;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
