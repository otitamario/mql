//+------------------------------------------------------------------+
//|                                           SSL_Channel_Chart.mq5  |
//|                                       Copyright © 2007, Kalenzo  |
//|                                     bartlomiej.gorski@gmail.com  |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2007, Kalenzo"
//---- link to the website of the author
#property link "bartlomiej.gorski@gmail.com"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- 2 buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- 1 plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Cloud drawing parameters         |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1 DRAW_FILLING
//---- the following colors are used for the indicator cloud
#property indicator_color1 clrDeepSkyBlue,clrMagenta
//---- displaying label of the signal line
#property indicator_label1  "Up Trend; Down Trend"

//+----------------------------------------------+
//|  declaring constants                         |
//+----------------------------------------------+
#define RESET  0 // The constant for returning the indicator recalculation command to the terminal
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint   period=13;           // Moving averages period;
input bool   NRTR=false;          // NRTR
input int    Shift=0;             // Horizontal shift of the indicator in bars
input uint   AlertCount=0;        // Number of submitted alerts
input uint   AlertBar=0;          // The bar, from which the alert is
//+----------------------------------------------+
//---- declaration of dynamic arrays that
// will be used as indicator buffers
double ExtMapBufferUp[];
double ExtMapBufferDown[];
double ExtMapBufferUp1[];
double ExtMapBufferDown1[];
//---- declaration of integer variables for indicators handles
int HMA_Handle,LMA_Handle;
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//|  Getting string timeframe                                        |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
//----
   return(StringSubstr(EnumToString(timeframe),7,-1));
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
int OnInit()
  {
//---- getting handle of the HMA indicator
   HMA_Handle=iMA(NULL,0,period,0,MODE_LWMA,PRICE_HIGH);
   if(HMA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the HMA indicator");
      return(1);
     }

//---- getting handle of the LMA indicator
   LMA_Handle=iMA(NULL,0,period,0,MODE_LWMA,PRICE_LOW);
   if(LMA_Handle==INVALID_HANDLE)
     {
      Print(" Failed to get handle of the LMA indicator");
      return(1);
     }

//---- initialization of variables of the start of data calculation
   min_rates_total=int(period+1);

//---- set ExtMapBufferUp[] dynamic array as an indicator buffer
   SetIndexBuffer(0,ExtMapBufferUp,INDICATOR_DATA);
//---- shifting indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBufferUp,true);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- set ExtMapBufferDown[] dynamic array as an indicator buffer
   SetIndexBuffer(1,ExtMapBufferDown,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//---- shifting the starting point of calculation of drawing of the indicator 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtMapBufferDown,true);
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"SSL_Channel_Chart(",period,", ",Shift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of minimums of price for the calculation of indicator
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking for the sufficiency of bars for the calculation
   if(BarsCalculated(HMA_Handle)<rates_total
      || BarsCalculated(LMA_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);

//---- declaration of local variables 
   double HMA[],LMA[];
   int limit,to_copy,bar,trend,Hld;
   static int trend_;
   static uint UpCount,DnCount;

//---- indexing elements in arrays as in time series  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(HMA,true);
   ArraySetAsSeries(LMA,true);

//---- calculation of the limit starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total-1;               // starting index for calculation of all bars
      trend_=0;
     }
   else
     {
      limit=rates_total-prev_calculated;                 // starting index for calculation of new bars
     }

   to_copy=limit+2;
//---- copy newly appeared data into the arrays
   if(CopyBuffer(HMA_Handle,0,0,to_copy,HMA)<=0) return(RESET);
   if(CopyBuffer(LMA_Handle,0,0,to_copy,LMA)<=0) return(RESET);

//---- restore values of the variables
   trend=trend_;

//---- main loop of the indicator calculation
   for(bar=limit; bar>=0; bar--)
     {
      ExtMapBufferUp[bar]=EMPTY_VALUE;
      ExtMapBufferDown[bar]=EMPTY_VALUE;

      if(close[bar]>HMA[bar+1]) Hld=+1;
      else
        {
         if(close[bar]<LMA[bar+1]) Hld=-1;
         else Hld=0;
        }
      if(Hld!=0) trend=Hld;

      if(trend==-1)
        {
         if(!NRTR || ExtMapBufferDown[bar+1]==EMPTY_VALUE)
           {
            ExtMapBufferDown[bar]=HMA[bar+1];
            ExtMapBufferUp[bar]=LMA[bar+1];
           }
         else if(ExtMapBufferDown[bar+1]!=EMPTY_VALUE)
           {
            ExtMapBufferDown[bar]=MathMin(HMA[bar+1],ExtMapBufferDown[bar+1]);
            ExtMapBufferUp[bar]=MathMin(LMA[bar+1],ExtMapBufferUp[bar+1]);
           }
        }
      else
        {

         if(!NRTR || ExtMapBufferUp[bar+1]==EMPTY_VALUE)
           {
            ExtMapBufferUp[bar]=HMA[bar+1];
            ExtMapBufferDown[bar]=LMA[bar+1];
           }
         else  if(ExtMapBufferUp[bar+1]!=EMPTY_VALUE)
           {
            ExtMapBufferUp[bar]=MathMax(HMA[bar+1],ExtMapBufferUp[bar+1]);
            ExtMapBufferDown[bar]=MathMax(LMA[bar+1],ExtMapBufferDown[bar+1]);
           }
        }

      if(bar) trend_=trend;
     }

//---- alerts counters reset to zeros
   if(rates_total!=prev_calculated)
     {
      UpCount=0;
      DnCount=0;
     }

   int bar1=int(AlertBar);
   int bar2=int(AlertBar+1);

//---- submission of an alert for buying
   if(UpCount<AlertCount && ExtMapBufferUp[bar1]>ExtMapBufferDown[bar1] && ExtMapBufferUp[bar2]<=ExtMapBufferDown[bar2])
     {
      UpCount++;
      Alert("SSL_Channel_Chart indicator "+Symbol()+GetStringTimeframe(Period())+": ""Buy signal "+Symbol());
     }

//---- submission of an alert for selling
   if(DnCount<AlertCount && ExtMapBufferDown[bar1]>ExtMapBufferUp[bar1] && ExtMapBufferDown[bar2]<=ExtMapBufferUp[bar2])
     {
      DnCount++;
      Alert("SSL_Channel_Chart indicator "+Symbol()+GetStringTimeframe(Period())+": ""Buy signal "+Symbol());
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
