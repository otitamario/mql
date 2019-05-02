//+------------------------------------------------------------------+
//|                                                   3LineBreak.mq4 |
//|                               Copyright © 2004, Poul_Trade_Forum |
//|                                                         Aborigen |
//|                                          http://forex.kbpauk.ru/ |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright " Copyright © 2004, Poul_Trade_Forum"
//---- link to the website of the author
#property link      " http://forex.kbpauk.ru/"
//---- indicator version
#property version   "1.00"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- three buffers are used for calculation and drawing the indicator
#property indicator_buffers 3
//---- only one plot is used
#property indicator_plots   1
//---- the following colors are used
#property indicator_color1 Blue,Red
//---- thickness of the indicator 1 line is equal to 2
#property indicator_width1 2
//---- color bars are used as an indicator
#property indicator_type1   DRAW_COLOR_HISTOGRAM2
//---- displaying the indicator label
#property indicator_label1  "UpTend; DownTrend;"

//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int Lines_Break=3;
//+----------------------------------------------+

//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtColorsBuffer[];
//----
bool Swing_;
int StartBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- initialization of global variables 
   StartBars=Lines_Break;
//---- set dynamic arrays as indicator buffers
   SetIndexBuffer(0,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLowBuffer,INDICATOR_DATA);
//---- set dynamic array as a color index buffer   
   SetIndexBuffer(2,ExtColorsBuffer,INDICATOR_COLOR_INDEX);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtColorsBuffer,true);

//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="3LineBreak";
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
   if(rates_total<StartBars) return(0);

//---- declarations of local variables 
   int limit,bar;
   double VALUE1,VALUE2;
   bool OLDSwing,Swing;

//---- calculations of the necessary amount of data to be copied and
//---- the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-StartBars; // starting index for calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
     }

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);

//---- restore values of the variables
   Swing=Swing_;

//---- main indicator calculation loop
   for(bar=limit; bar>=0; bar--)
     {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==0) Swing_=Swing;

      OLDSwing=Swing;
      //----
      VALUE1 = high[ArrayMaximum(high,bar+1,Lines_Break)];
      VALUE2 = low [ArrayMinimum(low, bar+1,Lines_Break)];
      //----
      if( OLDSwing && low [bar]<VALUE2) Swing=false;
      if(!OLDSwing && high[bar]>VALUE1) Swing=true;
      //----
      ExtHighBuffer[bar]=high[bar];
      ExtLowBuffer [bar]=low [bar];

      if(Swing) ExtColorsBuffer[bar]=0;
      else      ExtColorsBuffer[bar]=1;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
