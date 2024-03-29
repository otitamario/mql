//+------------------------------------------------------------------+
//|                                                      MyPanel.mqh |
//|                                    Copyright © 2013, DeltaTrader |
//|                                    http://www.deltatrader.com.br | 
//+------------------------------------------------------------------+
#property copyright     "Mario"
#property version       "1.0"
#property description   "Distância para Média"
#property indicator_chart_window
#property indicator_buffers 1   
#property indicator_plots   1   
#property indicator_label1  "Media"
#property indicator_type1  DRAW_LINE
#property indicator_color1  clrAqua
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#define bars 10// Barras para plotar

//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+

input int PeriodoMedia=9; // Periodo Média
input double distancia=70;// Distância para a Média

//+------------------------------------------------------------------+
//| Global variabels                                                 |
//+------------------------------------------------------------------+
//--- Panel itself
int media_handle;
double media_buffer[];
double ponto;
//+------------------------------------------------------------------+
//| On Init                                                          |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,media_buffer,INDICATOR_DATA);
   media_handle=iMA(Symbol(),_Period,PeriodoMedia,0,MODE_EMA,PRICE_CLOSE);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Bars(Symbol(),Period())-bars);

   ponto=SymbolInfoDouble(Symbol(),SYMBOL_POINT);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(media_handle);
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
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
   CopyBuffer(media_handle,0,0,to_copy,media_buffer);
   int start=rates_total-bars;
//--- Se já foi calculado durante os inícios anteriores do OnCalculate 
   if(prev_calculated>0) start=prev_calculated-1;
   for(int i=start; i<rates_total && !IsStopped();i++)
     {

      if(MathAbs(close[i]-media_buffer[i])>=distancia*ponto)
        {
         Alert("Distanciamento para a Media "+Symbol());
        }
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
