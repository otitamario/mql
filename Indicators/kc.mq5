//+------------------------------------------------------------------+
//|                                                           KC.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "ATR channel"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- number of indicator buffers 3
#property indicator_buffers 3 
//---- 3 plots are used
#property indicator_plots   3
//+--------------------------------------------+ 
//|  Declaration of constants                  |
//+--------------------------------------------+
#define RESET 0  // the constant for getting the command for the indicator recalculation back to the terminal
//+--------------------------------------------+
//|  Indicator drawing parameters              |
//+--------------------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- use BlueViolet color for the indicator line
#property indicator_color1 BlueViolet
//---- the indicator line is a dash-dotted curve
#property indicator_style1  STYLE_DASHDOTDOT
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "MA"
//+--------------------------------------------+
//|  Channel drawing parameters                |
//+--------------------------------------------+
//---- drawing the levels as lines
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- selection of levels colors
#property indicator_color2  Red
#property indicator_color3  Red
//---- Bollinger Bands are dott-dash curves
#property indicator_style2 STYLE_DASHDOTDOT
#property indicator_style3 STYLE_DASHDOTDOT
//---- levels width is equal to 1
#property indicator_width2  1
#property indicator_width3  1
//---- display levels labels
#property indicator_label2  "+ATR"
#property indicator_label3  "-ATR"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input ENUM_MA_METHOD MA_Method=MODE_SMA; // MA smoothing method
input uint MA_Period=20;                 // MA period
input uint ATR_Period=20;                // ATR period
input double Factor=1.5;                 // Number of deviations
input ENUM_APPLIED_PRICE IPC=PRICE_CLOSE;// Applied price
input int Shift=0;                       // Horizontal shift of the indicator in bars
//+-----------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double MA_Buffer[],UpATRBuffer[],DnATRBuffer[];
//---- declaration of integer variables for the indicators handles
int MA_Handle,ATR_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=int(MathMax(MA_Period,ATR_Period));

//---- getting handle of the MA indicator
   MA_Handle=iMA(NULL,0,MA_Period,0,MA_Method,IPC);
   if(MA_Handle==INVALID_HANDLE) Print(" Failed to get handle of the MA indicator");

//---- getting handle of the ATR indicator
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE) Print(" Failed to get handle of the ATR indicator");

//---- set MA_Buffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,MA_Buffer,INDICATOR_DATA);
//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(MA_Buffer,true);

//---- set UpATRBuffer[] and DnATRBuffer[] dynamic arrays into indicator buffers
   SetIndexBuffer(1,UpATRBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,DnATRBuffer,INDICATOR_DATA);
//---- horizontal shift of the indicators
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//---- set the position, from which the indicators drawing starts
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- indexing the elements in the buffer as timeseries
   ArraySetAsSeries(UpATRBuffer,true);
   ArraySetAsSeries(DnATRBuffer,true);

//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"ATR channel");

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+ 
//| Custom iteration function                                        | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
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
   if(BarsCalculated(MA_Handle)<rates_total
      || BarsCalculated(ATR_Handle)<rates_total
      || rates_total<min_rates_total) return(RESET);

//---- declarations of local variables 
   int limit,to_copy;
   double ATR[],atr;

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(ATR,true);

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

   to_copy=limit+1;

//--- copy newly appeared data in the array
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   if(CopyBuffer(MA_Handle,0,0,to_copy,MA_Buffer)<=0) return(RESET);

//---- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      atr=Factor*ATR[bar];
      UpATRBuffer[bar]=MA_Buffer[bar]+atr;
      DnATRBuffer[bar]=MA_Buffer[bar]-atr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
