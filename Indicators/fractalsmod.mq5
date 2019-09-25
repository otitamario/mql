//+------------------------------------------------------------------+
//|                                                  FractalsMod.mq5 |
//|                                    Copyright 2012, Manel Sanchon |
//+------------------------------------------------------------------+
#property copyright "Manel Sanchon"
#property link      ""
#property version   "1.00"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_color1  Red
#property indicator_color2  Blue
#property indicator_label1  "Fractal Up"
#property indicator_label2  "Fractal Down"
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input int leftbars      = 10;
input int rightbars     = 10;
input int shift         = 10;
//--- indicator buffers
double ExtUpperBuffer[];
double ExtLowerBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtUpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLowerBuffer,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_ARROW,115);
   PlotIndexSetInteger(1,PLOT_ARROW,115);
//--- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//--- initialization done
  }
//+------------------------------------------------------------------+
//|  Accelerator/Decelerator Oscillator                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,      // size of the price[] array
                const int prev_calculated,  // bars handled on a previous call
                const datetime &Time[],     // Time
                const double &Open[],       // Open
                const double &High[],       // High
                const double &Low[],        // Low
                const double &Close[],      // Close
                const long &TickVolume[],   // Tick Volume
                const long &Volume[],       // Real Volume
                const int &Spread[])        // Spread
  {
   int i,j;
   int limit;
   int countup=0;
   int countdown=0;
//--- I need leftbars+rightbars+1 to calculate the indicator
   if(rates_total<leftbars+rightbars+1)
      return(0);
//---
   if(prev_calculated<leftbars+rightbars+1)
     {
      limit=leftbars;
      //--- clean up arrays
      ArrayInitialize(ExtUpperBuffer,0);
      ArrayInitialize(ExtLowerBuffer,0);
     }
   else
     {
      limit=rates_total-(leftbars+rightbars+1);
     }
//--- we calculate the indicator 
   for(i=limit;i<=rates_total-leftbars-1;i++)
     {
      for(j=1;j<=leftbars;j++)
        {
         if(High[i]>High[i+j]) countup=countup+1;
         if(Low[i]<Low[i+j]) countdown=countdown+1;
        }
      for(j=1;j<=rightbars;j++)
        {
         if(High[i]>High[i-j]) countup=countup+1;
         if(Low[i]<Low[i-j]) countdown=countdown+1;
        }
      if(countup==leftbars+rightbars) ExtUpperBuffer[i+shift]=High[i];
      else ExtUpperBuffer[i+shift]=ExtUpperBuffer[i+shift-1];
      if(countdown==leftbars+rightbars) ExtLowerBuffer[i+shift]=Low[i];
      else ExtLowerBuffer[i+shift]=ExtLowerBuffer[i+shift-1];
      countup=0;
      countdown=0;
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }

//+------------------------------------------------------------------+
