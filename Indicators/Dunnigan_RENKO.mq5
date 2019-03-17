//+------------------------------------------------------------------+
//|                                                     Dunnigan.mq5 |
//|                                                  Henrique Vilela |
//|                                               http://vilela.one/ |
//+------------------------------------------------------------------+
#property copyright "Henrique Vilela"
#property link      "http://vilela.one/"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2

#property indicator_label1  "Venda"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Compra"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

double         VendaBuffer[];
double         CompraBuffer[];
#include <AZ-INVEST/SDK/MedianRenkoIndicator.mqh>
MedianRenkoIndicator medianRenkoIndicator;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);

   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);

   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);

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
  
  if(!medianRenkoIndicator.OnCalculate(rates_total,prev_calculated,time))
      return(0);
  int _prev_calculated = medianRenkoIndicator.GetPrevCalculated();
 
  
   for(int i=MathMax(1,_prev_calculated-1); i<rates_total;i++)
     {
      if(medianRenkoIndicator.Low[i]<medianRenkoIndicator.Low[i-1] && medianRenkoIndicator.High[i]<medianRenkoIndicator.High[i-1])
        {
         VendaBuffer[i]=medianRenkoIndicator.High[i];
        }
      else
        {
         VendaBuffer[i]=0;
        }

      if(medianRenkoIndicator.Low[i]>medianRenkoIndicator.Low[i-1] && medianRenkoIndicator.High[i]>medianRenkoIndicator.High[i-1])
        {
         CompraBuffer[i]=medianRenkoIndicator.Low[i];
        }
      else
        {
         CompraBuffer[i]=0;
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
