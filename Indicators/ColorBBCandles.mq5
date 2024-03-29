//+---------------------------------------------------------------------+
//|                                                  ColorBBCandles.mq5 |
//|                                Copyright © 2011,   Nikolay Kositsin | 
//|                                 Khabarovsk,   farria@mail.redcom.ru | 
//+---------------------------------------------------------------------+ 
//| Place the SmoothAlgorithms.mqh file                                 |
//| in the directory: terminal_data_folder\MQL5\Include                 |
//+---------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "ColorBBCandles"
//---- indicator version number
#property version   "1.01"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- five buffers are used for the indicator calculation and drawing
#property indicator_buffers 5
//---- only one plot is used
#property indicator_plots   1
//---- color candlesticks are used as an indicator
#property indicator_type1   DRAW_COLOR_CANDLES
//---- the following colors are used for the candlesticks
#property indicator_color1 clrDarkViolet,CLR_NONE,clrBlack
//---- displaying the indicator label
#property indicator_label1  "ColorBBCandles 10 colors"

//+-----------------------------------+
//|  Averaging classes description    |
//+-----------------------------------+
#include <SmoothAlgorithms.mqh> 
//+-----------------------------------+

//---- declaration of CStdDeviation and CMoving_Average class variables from SmoothAlgorithms.mqh
CStdDeviation STD;
CMoving_Average MA;
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_,  //TrendFollow_2 Price 
   PRICE_DEMARK_         //Demark Price
  };

//+----------------------------------------------+
//| Indicator input parameters                 |
//+----------------------------------------------+
input int               BandsPeriod=100;        // BB averaging period
input double            BandsDeviation=1.0;     // Deviation
input ENUM_MA_METHOD    MA_Method_=MODE_EMA;    // Indicator averaging method
input Applied_price_    IPC=PRICE_CLOSE_;       // Price constant
//+----------------------------------------------+

//---- declaration of dynamic arrays that further 
// will be used as indicator buffers
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorsBuffer[];

//---- Declaration of integer variables of data starting point
int StartBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   StartBars=BandsPeriod+1;

//---- setting dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- Setting a dynamic array as a color index buffer   
   SetIndexBuffer(4,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//---- Performing the shift of beginning of indicator drawing
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,StartBars);
//--- set colors quantity 11 for the color buffer
// PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,11);
//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- data window name and subwindow label 
   string short_name="ColorBBCandles";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---- Checking if there is enough bars for the calculation
   if(rates_total<StartBars) return(0);

//---- Declaring floating point variables  
   double price_,stdev,ma;
   double UpBB1;
   double DnBB1;
//---- Declaration of integer variables
   int first,bar;

//---- Calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) //checking for the first start of calculation of an indicator
      first=0; // starting number for calculation of all bars
   else first=prev_calculated-1; // starting index for the calculation of new bars

//---- Bollinger Bands main calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Calling the PriceSeries function to get the input price price_
      price_=PriceSeries(IPC,bar,open,low,high,close);

      //---- Calling the MASeries function to get the moving value
      ma=MA.MASeries(0,prev_calculated,rates_total,BandsPeriod,MA_Method_,price_,bar,false);

      //---- Call of the StdDevSeries function to get the value of the half of the channel width with Deviation = 1.0 
      stdev=STD.StdDevSeries(StartBars,prev_calculated,rates_total,BandsPeriod,1.0,price_,ma,bar,false);

      //---- Get the values of the levels
      UpBB1=ma+stdev*BandsDeviation;
      DnBB1=ma-stdev*BandsDeviation;


      if((price_>UpBB1 || price_<DnBB1) && bar>StartBars) //there are signals to color candlesticks
        {
         if(price_>UpBB1)
            ExtColorsBuffer[bar]=2;
         else if(price_<DnBB1)
            ExtColorsBuffer[bar]=0;

         ExtOpenBuffer[bar]=open[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
         ExtCloseBuffer[bar]=close[bar];
        }
      else // there are no signals for candlesticks coloring
        {
         ExtOpenBuffer[bar]=0.0;
         ExtHighBuffer[bar]=0.0;
         ExtLowBuffer[bar]=0.0;
         ExtCloseBuffer[bar]=0.0;
         ExtColorsBuffer[bar]=1;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
