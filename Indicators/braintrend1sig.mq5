//+------------------------------------------------------------------+
//|                                               BrainTrend1Sig.mq4 |
//|                               Copyright © 2005, BrainTrading Inc |
//|                                      http://www.braintrading.com |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2005, BrainTrading Inc."
//---- link to the website of the author
#property link      "http://www.braintrading.com/"
//---- Indicator Version Number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- only two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing the indicator 1 as a symbol
#property indicator_type1   DRAW_ARROW
//---- Magenta color is used as the color of the bearish indicator line
#property indicator_color1  Magenta
//---- thickness of line of the indicator 1 is equal to 4
#property indicator_width1  4
//---- displaying of the bearish label of the indicator
#property indicator_label1  "Brain1Sell"
//+----------------------------------------------+
//|  Parameters of drawing the bullish indicator |
//+----------------------------------------------+
//---- drawing the indicator 2 as a line
#property indicator_type2   DRAW_ARROW
//---- lime color is used as the color of the bullish line of the indicator
#property indicator_color2  Lime
//---- thickness of line of the indicator 2 is equal to 4
#property indicator_width2  4
//---- displaying of the bullish label of the indicator
#property indicator_label2 "Brain1Buy"

//+----------------------------------------------+
//| Input parameters of the indicator            |
//+----------------------------------------------+
input int ATR_Period=7; //Period of ATR 
input int STO_Period=9; //Period of Stochastic
input ENUM_MA_METHOD MA_Method = MODE_SMA; //Method of averaging
input ENUM_STO_PRICE STO_Price = STO_LOWHIGH; //Method of prices calculation 
//+----------------------------------------------+

//---- declaration of dynamic arrays that further 
// will be used as indicator buffers
double SellBuffer[];
double BuyBuffer[];
//----
double d,s;
int p,x1,x2,P_,StartBars,OldTrend;
int ATR_Handle,STO_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- initialization of global variables 
   d=2.3;
   s=1.5;
   x1 = 53;
   x2 = 47;
   StartBars=MathMax(ATR_Period,STO_Period)+2;
//---- getting handle of the ATR indicator
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)Print(" Failed to get handle of the ATR indicator");
//---- getting handle of the Stochastic indicator
   STO_Handle=iStochastic(NULL,0,STO_Period,STO_Period,1,MA_Method,STO_Price);
   if(STO_Handle==INVALID_HANDLE)Print(" Failed to get handle of the Stochastic indicator");

//---- turning a dynamic array into an indicator buffer
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
//---- Create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"Brain1Sell");
//---- indicator symbol
   PlotIndexSetInteger(0,PLOT_ARROW,108);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(SellBuffer,true);

//---- turning a dynamic array into an indicator buffer
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//---- shifting the start of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
//---- Create label to display in DataWindow
   PlotIndexSetString(1,PLOT_LABEL,"Brain1Buy");
//---- indicator symbol
   PlotIndexSetInteger(1,PLOT_ARROW,108);
//---- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(BuyBuffer,true);

//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and for the label of sub-windows 
   string short_name="BrainTrend1Sig";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
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
//---- checking the number of bars to be enough for the calculation
   if(BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(STO_Handle)<rates_total
      || rates_total<StartBars)
      return(0);

//---- declaration of local variables 
   int to_copy,limit,bar;
   double value2[],Range[],range,range2,val1,val2,val3;

//---- calculations of the necessary amount of data to be copied and
//the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      to_copy=rates_total; // calculated number of all bars
      limit=rates_total-StartBars; // starting number for calculation of all bars
     }
   else
     {
      to_copy=rates_total-prev_calculated+1; // calculated number of new bars
      limit=rates_total-prev_calculated; // starting number for calculation of new bars
     }

//---- copy the newly appeared data into the Range[] and value2[] arrays
   if(CopyBuffer(ATR_Handle,0,0,to_copy,Range)<=0) return(0);
   if(CopyBuffer(STO_Handle,0,0,to_copy,value2)<=0) return(0);

//---- indexing elements in arrays, as in timeseries  
   ArraySetAsSeries(Range,true);
   ArraySetAsSeries(value2,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);

//---- restore values of the variables
   p=P_;

//---- main cycle of calculation of the indicator
   for(bar=limit; bar>=0; bar--)
     {
      //---- memorize values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==0)
         P_=p;

      range=Range[bar]/d;
      range2=Range[bar]*s/4;
      val1 = 0.0;
      val2 = 0.0;
      SellBuffer[bar]=0.0;
      BuyBuffer[bar]=0.0;

      val3=MathAbs(close[bar]-close[bar+2]);
      if(value2[bar] < x2 && val3 > range) p = 1;
      if(value2[bar] > x1 && val3 > range) p = 2;

      if(val3<=range) continue;

      if(value2[bar]<x2 && (p==1 || p==0))
        {
         if(OldTrend>0) SellBuffer[bar]=high[bar];
         if(bar!=0)OldTrend=-1;
        }
      if(value2[bar]>x1 && (p==2 || p==0))
        {
         if(OldTrend<0) BuyBuffer[bar]=low[bar];
         if(bar!=0)OldTrend=+1;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
