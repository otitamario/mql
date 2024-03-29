//+------------------------------------------------------------------+
//|                                     Donchian_Channels_System.mq5 |
//|                               Copyright © 2013, Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2013, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "The breakthrough system using the Donchian_Channels indicator"
//--- indicator version
#property version   "1.00"
//--- drawing the indicator in the main window
#property indicator_chart_window
//--- nine buffers are used for calculation and drawing the indicator
#property indicator_buffers 9
//--- four plots are used
#property indicator_plots   4
//+----------------------------------------------+
//| Indicator 1 drawing parameters               |
//+----------------------------------------------+
//--- drawing the indicator as a one-color cloud
#property indicator_type1   DRAW_FILLING
//--- WhiteSmoke color is used for the indicator
#property indicator_color1  clrSnow
//--- displaying the indicator label
#property indicator_label1  "Donchian_Channels"
//+----------------------------------------------+
//| Indicator 2 drawing parameters               |
//+----------------------------------------------+
//--- drawing indicator 2 as a line
#property indicator_type2   DRAW_LINE
//--- MediumSeaGreen color is used as the color of the bullish line of the indicator
#property indicator_color2  clrGreen
//--- the line of the indicator 2 is a continuous curve
#property indicator_style2  STYLE_SOLID
//--- indicator 2 line width is equal to 2
#property indicator_width2  2
//--- display of the indicator bullish label
#property indicator_label2  "Upper Donchian_Channels"
//+----------------------------------------------+
//| Indicator 3 drawing parameters               |
//+----------------------------------------------+
//--- drawing indicator 3 as a line
#property indicator_type3   DRAW_LINE
//--- Magenta is used for the color of the bearish indicator line
#property indicator_color3  clrCrimson
//--- the line of the indicator 3 is a continuous curve
#property indicator_style3  STYLE_SOLID
//--- indicator 3 line width is equal to 2
#property indicator_width3  2
//--- display of the bearish indicator label
#property indicator_label3  "Lower Donchian_Channels"
//+----------------------------------------------+
//| Indicator 4 drawing parameters               |
//+----------------------------------------------+
//--- drawing the indicator as a sequence of colored candlesticks
#property indicator_type4 DRAW_COLOR_CANDLES
//--- the following colors are used as the indicator colors
#property indicator_color4 clrDeepPink,clrGray,clrDodgerBlue
//--- indicator line is a solid one
#property indicator_style4 STYLE_SOLID
//--- indicator line width is 2
#property indicator_width4 2
//--- displaying the indicator label
#property indicator_label4 "Donchian_Channels_BARS"
//+----------------------------------------------+
//|  Declaration of enumeration                  |
//+----------------------------------------------+
enum Applied_Extrem //Type of extreme points
  {
   HIGH_LOW,
   HIGH_LOW_OPEN,
   HIGH_LOW_CLOSE,
   OPEN_HIGH_LOW,
   CLOSE_HIGH_LOW
  };
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input uint           DonchianPeriod=20;            // Period of averaging
input Applied_Extrem Extremes=HIGH_LOW;            // Extrema type
input uint           Shift=2;                      // Horizontal shift 
//+----------------------------------------------+
//--- declaration of dynamic arrays that will be used as indicator buffers
double Up1Buffer[],Dn1Buffer[];
double Up2Buffer[],Dn2Buffer[];
double ExtOpenBuffer[],ExtHighBuffer[],ExtLowBuffer[],ExtCloseBuffer[],ExtColorBuffer[];
//--- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//--- initialization of variables of the start of data calculation
   min_rates_total=int(DonchianPeriod+1+Shift);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(0,Up1Buffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Up1Buffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(1,Dn1Buffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Dn1Buffer,true);
//--- set dynamic array as an indicator buffer
   SetIndexBuffer(2,Up2Buffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Up2Buffer,true);
//--- Set dynamic array as an indicator buffer
   SetIndexBuffer(3,Dn2Buffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(Dn2Buffer,true);
//--- set IndBuffer dynamic array as an indicator buffer
   SetIndexBuffer(4,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,ExtCloseBuffer,INDICATOR_DATA);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
//--- setting a dynamic array as a color index buffer   
   SetIndexBuffer(8,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//--- indexing elements in the buffer as in timeseries
   ArraySetAsSeries(ExtColorBuffer,true);
//--- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- shifting the starting point of the indicator 1 drawing by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- shifting the indicator 2 horizontally by Shift
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- shifting the starting point of the indicator 2 drawing by min_rates_total
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- shifting the indicator 3 horizontally by Shift
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
//--- shifting the starting point of the indicator 3 drawing by min_rates_total
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//--- shifting the indicator 3 horizontally by Shift
   PlotIndexSetInteger(3,PLOT_SHIFT,0);
//--- shifting the starting point of the indicator 4 drawing by min_rates_total
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,min_rates_total);
//--- setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
//--- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"Donchian_Channels(",DonchianPeriod,")");
//--- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determining the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
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
//--- checking if the number of bars is enough for the calculation
   if(rates_total<min_rates_total) return(0);
//--- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- declaration of integer variables
   int limit;
//--- declaration of variables with a floating point  
   double smin,smax,SsMax=0.0,SsMin=0.0;
//--- calculations of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total; // starting index for calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
     }
//--- main indicator calculation loop
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      switch(Extremes)
        {
         case HIGH_LOW:
            SsMax=high[ArrayMaximum(high,bar,DonchianPeriod)];
            SsMin=low[ArrayMinimum(low,bar,DonchianPeriod)];
            break;

         case HIGH_LOW_OPEN:
            SsMax=(open[ArrayMaximum(open,bar,DonchianPeriod)]+high[ArrayMaximum(high,bar,DonchianPeriod)])/2;
            SsMin=(open[ArrayMinimum(open,bar,DonchianPeriod)]+low[ArrayMinimum(low,bar,DonchianPeriod)])/2;
            break;

         case HIGH_LOW_CLOSE:
            SsMax=(close[ArrayMaximum(close,bar,DonchianPeriod)]+high[ArrayMaximum(high,bar,DonchianPeriod)])/2;
            SsMin=(close[ArrayMinimum(close,bar,DonchianPeriod)]+low[ArrayMinimum(low,bar,DonchianPeriod)])/2;
            break;

         case OPEN_HIGH_LOW:
            SsMax=open[ArrayMaximum(open,bar,DonchianPeriod)];
            SsMin=open[ArrayMinimum(open,bar,DonchianPeriod)];
            break;

         case CLOSE_HIGH_LOW:
            SsMax=close[ArrayMaximum(close,bar,DonchianPeriod)];
            SsMin=close[ArrayMinimum(close,bar,DonchianPeriod)];
            break;
        }

      smin=SsMin;
      smax=SsMax;

      Up1Buffer[bar]=smax;
      Dn1Buffer[bar]=smin;
      Up2Buffer[bar]=smax;
      Dn2Buffer[bar]=smin;
     }
//--- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) limit-=int(Shift);
//--- the main loop of indicator bar coloring
   for(int bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      int clr=1;
      ExtOpenBuffer[bar]=0.0;
      ExtCloseBuffer[bar]=0.0;
      ExtHighBuffer[bar]=0.0;
      ExtLowBuffer[bar]=0.0;

      if(close[bar]>Up1Buffer[bar+Shift])
        {
         clr=2;
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
        }

      if(close[bar]<Dn1Buffer[bar+Shift])
        {
         clr=0;
         ExtOpenBuffer[bar]=open[bar];
         ExtCloseBuffer[bar]=close[bar];
         ExtHighBuffer[bar]=high[bar];
         ExtLowBuffer[bar]=low[bar];
        }

      ExtColorBuffer[bar]=clr;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
