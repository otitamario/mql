//+------------------------------------------------------------------+
//|                                    Rompimento de Linha Dagua.mq5 |
//|                                                  Henrique Vilela |
//|                                               http://vilela.one/ |
//+------------------------------------------------------------------+
#property copyright "Henrique Vilela"
#property link      "http://vilela.one/"
#property version   "1.00"

#define SECONDSINADAY  300   //86400

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

   for(int i=MathMax(1,prev_calculated-1); i<rates_total; i++)
     {
      bool bear=false;
      bool bull=close[i]>open[i-1]&&open[i]<close[i-1]&&close[i-1]<open[i-1];
      if(bull) CompraBuffer[i]=low[i];
      else CompraBuffer[i]=EMPTY_VALUE;
      if(bear) VendaBuffer[i]=high[i];
      else VendaBuffer[i]=EMPTY_VALUE;
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+

