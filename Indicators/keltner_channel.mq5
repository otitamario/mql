//+------------------------------------------------------------------+
//|                                              Keltner Channel.mq5 |
//|                               Copyright © 2011, Nikolay Kositsin |
//|                                Khabarovsk, farria@mail.redcom.ru |
//+------------------------------------------------------------------+ 
// For the indicator to work, place the file SmoothAlgorithms.mqh    | 
// in the terminal_data_catalogue\MQL5\Include                       |
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers
#property indicator_buffers 3 
//---- 3 plots are used
#property indicator_plots   3
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing of the indicator as a line
#property indicator_type1   DRAW_LINE
//---- use yellow color for the indicator line
#property indicator_color1 Yellow
//---- indicator line is a solid curve
#property indicator_style1  STYLE_SOLID
//---- Indicator line width is equal to 1
#property indicator_width1  1
//---- displaying of the the indicator label
#property indicator_label1  "Upper Keltner"

//---- drawing of the indicator as a line
#property indicator_type2   DRAW_LINE
//---- use gray color for the indicator line
#property indicator_color2 Gray
//---- indicator line is a solid curve
#property indicator_style2  STYLE_SOLID
//---- Indicator line width is equal to 1
#property indicator_width2  1
//---- displaying of the indicator label
#property indicator_label2  "Middle Keltner"

//---- drawing of the indicator as a line
#property indicator_type3   DRAW_LINE
//---- Magenta color is used for indicator line
#property indicator_color3 Magenta
//---- indicator line is a solid curve
#property indicator_style3  STYLE_SOLID
//---- Indicator line width is equal to 1
#property indicator_width3  1
//---- displaying of the the indicator label
#property indicator_label3  "Lower Keltner"
//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPLE_,        //PRICE_SIMPLE
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_   //PRICE_TRENDFOLLOW1_
  };
input int KeltnerPeriod=20; //Period of averaging
input ENUM_MA_METHOD MA_Method_=MODE_SMA; //Method of averaging
input double Ratio=1.0;
input Applied_price_ IPC=PRICE_CLOSE_;//Price constant
/* , used for calculation of the indicator (1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPLE, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0; // Horizontal shift of the indicator in bars
//---+
//Indicator buffers
double UpperBuffer[];
double MiddleBuffer[];
double LowerBuffer[];
//---- Declaration of the integer variables for the start of data calculation
int StartBar;
//+------------------------------------------------------------------+
// Declaration of classes of averaging                               |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh>
//+------------------------------------------------------------------+
// calculation of the half of the Keltner Channel width              |
//+------------------------------------------------------------------+ 
double GetKeltner(int period,int bar,const double &High[],const double &Low[])
  {
//----
   double Resalt,sum=0;
   for(int iii=0; iii<period; iii++)
      sum+=High[bar-iii] - Low[bar-iii];
   Resalt = sum / period;
   return(Resalt);
//----
  }
//+------------------------------------------------------------------+    
//| Keltner Channel indicator initialization function                | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialize constants
   StartBar=2*KeltnerPeriod+1;
//---- turning a dynamic array into an indicator buffer
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by AroonShift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBar);
//--- Create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Upper Keltner");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- turning a dynamic array into an indicator buffer
   SetIndexBuffer(1,MiddleBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,KeltnerPeriod-1);
//--- Create label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Middle Keltner");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- turning a dynamic array into an indicator buffer
   SetIndexBuffer(2,LowerBuffer,INDICATOR_DATA);
//---- shifting the indicator 3 horizontally
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 3
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,StartBar);
//--- Create label to display in DataWindow
   PlotIndexSetString(2,PLOT_LABEL,"Lower Keltner");
//---- setting values of the indicator that won't be visible on the chart
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of the variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Keltner( KeltnerPeriod = ",KeltnerPeriod,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- end of initialization
  }
//+------------------------------------------------------------------+  
//| Keltner Channel iteration function                               | 
//+------------------------------------------------------------------+  
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<StartBar) return(0);

//---- Declaration of variables with a floating point  
   double price_,middle,Keltner;
//---- Declaration of integer variables
   int first1,first2,bar;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated==0) // checking for the first start of the indicator calculation
     {
      first1=0; // starting number for calculation of all bars
      first2=StartBar;
     }
   else // starting number for calculation of new bars
     {
      first1=prev_calculated-1;
      first2=first1;
     }

//---- declaration of the classes Moving_Average and StdDeviation
   static CMoving_Average MA;

//---- Main cycle of calculation of the channel center line
   for(bar=first1; bar<rates_total; bar++)
     {
      //----+ Calling the function PriceSeries to get the input price 'Series'
      price_=PriceSeries(IPC,bar,open,low,high,close);
      MiddleBuffer[bar]=MA.MASeries(0,prev_calculated,rates_total,KeltnerPeriod,MA_Method_,price_,bar,false);
     }
//---- Main cycle of calculation of the channel
   for(bar=first2; bar<rates_total; bar++)
     {
      middle=MiddleBuffer[bar];
      Keltner=Ratio*GetKeltner(KeltnerPeriod,bar,high,low);

      UpperBuffer[bar]=middle+Keltner;
      LowerBuffer[bar]=middle-Keltner;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+