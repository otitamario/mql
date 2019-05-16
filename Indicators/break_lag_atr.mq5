//+------------------------------------------------------------------+
//|                                                BREAK_LAG_ATR.mq5 |
//+------------------------------------------------------------------+
#property copyright   "Copyright 2011, Tol_x64."
#property description "email: hello.tol64@gmail.com"
#property version     "1.00"
//--- properties
#property indicator_separate_window
#property indicator_height  50
#property indicator_minimum 0.0
//---
#property indicator_buffers 4
#property indicator_plots   3
//---
#property indicator_type1   DRAW_LINE
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_type3   DRAW_HISTOGRAM
//---
#property indicator_color1  clrRoyalBlue
#property indicator_color2  clrOrangeRed
#property indicator_color3  clrLime
//---
#property indicator_label1  "BREAK_LAG_ATR"
//--- external parameters
input int InpAtrPeriod=14;  // ATR period
//--- buffers
double ExtATRBuffer[],ExtSubCOBuffer[];
//---
double ColorBuffer[];
double ExtTRBuffer[];
//--- global variables
int       ExtPeriodATR;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- checking the external parameter for correctness
   if(InpAtrPeriod<=0)
     {
      ExtPeriodATR=14;
      printf("Incorrect input parameter InpAtrPeriod = %d. Indicator will use value %d for calculations.",InpAtrPeriod,ExtPeriodATR);
     }
   else ExtPeriodATR=InpAtrPeriod;

//--- calculation buffer
   SetIndexBuffer(0,ExtATRBuffer,INDICATOR_DATA);
//--- calculation buffer
   SetIndexBuffer(1,ExtSubCOBuffer,INDICATOR_DATA);
//--- plotting buffer
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//--- intermediate calculation buffer
   SetIndexBuffer(3,ExtTRBuffer,INDICATOR_CALCULATIONS);

//--- accuracy in digits
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits); 

//--- indicator properties
//--- the bar, from which plotting will start (from a chart beginning: 0 1 2 3...N )
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpAtrPeriod);
//--- set the shift by one bar
   PlotIndexSetInteger(0,PLOT_SHIFT,1);
//--- set the line drawing style
   PlotIndexSetInteger(1,PLOT_LINE_STYLE,STYLE_SOLID);
//--- set the line width
   PlotIndexSetInteger(1,PLOT_LINE_WIDTH,4);
//--- set the line drawing style
   PlotIndexSetInteger(2,PLOT_LINE_STYLE,STYLE_SOLID);
//--- set the line width
   PlotIndexSetInteger(2,PLOT_LINE_WIDTH,4);
//--- the name displayed in a subwindow
   string short_name="BREAK_LAG_ATR("+string(ExtPeriodATR)+")";

//--- set the name to be displayed in a subwindow
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- the name display when the cursor hovers over the indicator
   PlotIndexSetString(0,PLOT_LABEL,short_name);
  }
//+------------------------------------------------------------------+
//| Average True Range                                               |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,     // price[] array size
                const int prev_calculated, // number of bars processed at the previous call
                const datetime &Time[],    // time array
                const double &Open[],      // open prices array
                const double &High[],      // close prices array
                const double &Low[],       // lows prices array
                const double &Close[],     // highs prices array
                const long &TickVolume[],  // tick volumes array
                const long &Volume[],      // trade volumes array
                const int &Spread[])       // ask/bid (spread) difference array
  {
   int i,limit;

//--- checking the number of bars for the calculation
   if(rates_total<=ExtPeriodATR) return(0); // in case the number of bars is less than a specified period, then exit

//--- preliminary calculations
   if(prev_calculated==0) // in case of a first call
     {
      //--- for zero indexes set zero values
      ExtTRBuffer[0]=0.0;
      ExtATRBuffer[0]=0.0;
      ColorBuffer[0]=0.0;

      //--- filling of the ExtTRBuffer[] array by the whole history values
      for(i=1; i<rates_total && !IsStopped(); i++)
        {
         ExtTRBuffer[i]=MathMax(High[i],Close[i-1])-MathMin(Low[i],Close[i-1]);
        }
      //--- the indicator first value is not calculated
      double firstValue=0.0;
      //---
      for(i=1; i<=ExtPeriodATR; i++)
        {
         ExtATRBuffer[i]=0.0; firstValue+=ExtTRBuffer[i];
        }

      //--- indicator first value calculation
      firstValue/=ExtPeriodATR;
      ExtATRBuffer[ExtPeriodATR]=firstValue;
      limit=ExtPeriodATR+1;
     }
   else limit=prev_calculated-1;

//--- main calculations for the indicator display
   for(i=limit; i<rates_total && !IsStopped(); i++)
     {
      ExtTRBuffer[i]=MathMax(High[i],Close[i-1])-MathMin(Low[i],Close[i-1]);
      //--- ATR
      ExtATRBuffer[i]=ExtATRBuffer[i-1]+(ExtTRBuffer[i]-ExtTRBuffer[i-ExtPeriodATR])/ExtPeriodATR;
      //---
      ExtSubCOBuffer[i]=MathAbs(Close[i-1]-Open[i-1]); // ABS(OPEN-CLOSE)
      //---
      if(ExtSubCOBuffer[i]>ExtATRBuffer[i-1]) { ColorBuffer[i]=ExtSubCOBuffer[i]; } else { ColorBuffer[i]=0.0; } // BREAK ATR
     }
//--- prev_calculated returned value till the next call
   return(rates_total);
  }
//-------------------------------------------------------------------+
