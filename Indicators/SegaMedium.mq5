//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"

#property indicator_chart_window
//---- two buffers are used for calculation and drawing the indicator
#property indicator_buffers 6
//---- only one plot is used
#property indicator_plots   5
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_SOLID
#property indicator_type13  DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrAqua
#property indicator_style5  STYLE_SOLID

input int     InpPeriod=5;         // Média Amplitude


double LineBuy[],LineSell[],GainBuy[],GainSell[],PMd[],Amp[];
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
      ExtLineBuffer[i]=0.5*(close[i]+open[i]);
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





void CalculateAmp(int rates_total,int prev_calculated,const double &high[],const double &low[])
  {
   int i,limit;
//--- first calculation or number of bars was changed
   if(prev_calculated==0)// first calculation
     {
      limit=InpPeriod;
      //--- set empty value for first limit bars
      for(i=0;i<limit-1;i++) Amp[i]=0.0;
      //--- calculate first visible value
      double firstValue=0;
      for(i=0;i<limit;i++)
         firstValue+=high[i]-low[i];
      firstValue/=InpPeriod;
      Amp[limit-1]=firstValue;
     }
   else limit=prev_calculated-1;
//--- main loop
   for(i=limit;i<rates_total && !IsStopped();i++)
      ExtLineBuffer[i]=ExtLineBuffer[i-1]+(price[i]-price[i-InpMAPeriod])/InpMAPeriod;
//---
  }