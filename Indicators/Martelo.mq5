//+------------------------------------------------------------------+
//|                                                      Martelo.mq5 |
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

input double CorpoMinimo=20; // Corpo mínimo (%)
input double CorpoMaximo=40; // Corpo máximo (%)
input double Sombra=50; // Sombra maior que (%)
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

   if(CorpoMinimo+Sombra>100)
     {
      return INIT_FAILED;
     }

   if(CorpoMinimo>CorpoMaximo)
     {
      return INIT_FAILED;
     }

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
   for(int i=MathMax(0,prev_calculated-1); i<rates_total; i++)
     {
      CompraBuffer[i]=VendaBuffer[i]=0;

      double amplitude=high[i]-low[i];

      if(amplitude==0) continue;

      double corpo=MathAbs(close[i]-open[i])/amplitude*100;
      double sombra_superior=MathAbs(high[i]-MathMax(open[i],close[i]))/amplitude*100;
      double sombra_inferior=MathAbs(MathMin(open[i],close[i])-low[i])/amplitude*100;

      if(corpo>=CorpoMinimo && corpo<=CorpoMaximo)
        {
         CompraBuffer[i]= sombra_inferior > Sombra ? low[i] : EMPTY_VALUE;
         VendaBuffer[i] = sombra_superior > Sombra ? high[i] : EMPTY_VALUE;
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
