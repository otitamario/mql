//+------------------------------------------------------------------+
//|                                                   Trend Line.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+

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

input int confirmarCandleAnterior = 0;

int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);

   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);

   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);
//---
   return(INIT_SUCCEEDED);
  }
 
void OnDeinit(const int reason)
{
ObjectDelete(0,"Compra");
ObjectDelete(0,"Venda");

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
//---

for (int i = MathMax(rates_total-10, prev_calculated - 1); i < rates_total; i++) {

if(high[i-2]-low[i-2]<100 && high[i-1]<high[i-2] && low[i-1]>low[i-2])
{
               ObjectCreate(0, "Compra", OBJ_HLINE, 0, time[i-2], high[i-2]);
               ObjectCreate(0, "Venda", OBJ_HLINE, 0, time[i-2], low[i-2]);

}

    double precoCompra = ObjectGetDouble(0, "Compra", OBJPROP_PRICE, 0);

    double precoVenda = ObjectGetDouble(0, "Venda", OBJPROP_PRICE, 0);
    
{
      if (precoCompra != 0.0 && close[i] > precoCompra)
      {
        CompraBuffer[i] = low[i];
      } else {
        CompraBuffer[i] = 0;
      }

      if (precoVenda != 0.0 && close[i] < precoVenda)
      {
        VendaBuffer[i] = high[i];
      } else {
        VendaBuffer[i] = 0;
      }
    }

if(CompraBuffer[i-1]>0 || VendaBuffer[i-1]>0)
{
ObjectDelete(0,"Compra");
ObjectDelete(0,"Venda");
precoCompra=precoVenda=0;

}

  }
  

  //--- return value of prev_calculated for next call
  return (rates_total);
}
//+------------------------------------------------------------------+
