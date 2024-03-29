//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"

#property indicator_chart_window
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- only one plot is used
#property indicator_plots   1
//---- drawing the indicator as a line
#property indicator_type1   DRAW_COLOR_LINE
//---- Gray, MediumPurple and Red colors are used for three-color line
#property indicator_color1  clrGray,clrLime,clrRed
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  2

double ExtLineBuffer[];
double ColorExtLineBuffer[];
int  min_rates_total;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   min_rates_total=2;

   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+1);

//---- set ColorExtLineBuffer[] dynamic array as an indicator buffer   
   SetIndexBuffer(1,ColorExtLineBuffer,INDICATOR_COLOR_INDEX);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total+1);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   for(int i=MathMax(1,prev_calculated-1); i<rates_total; i++)
     {
      ExtLineBuffer[i]=0.5*(high[i]+low[i]);
     }


   for(int i=MathMax(1,prev_calculated-1); i<rates_total; i++)
     {
      ColorExtLineBuffer[i]=0;
      if(ExtLineBuffer[i-1]<ExtLineBuffer[i]) ColorExtLineBuffer[i]=1;
      if(ExtLineBuffer[i-1]>ExtLineBuffer[i]) ColorExtLineBuffer[i]=2;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
