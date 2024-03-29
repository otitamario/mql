//+------------------------------------------------------------------+
//|                                                    Sequencia.mq5 |
//|                                                  Henrique Vilela |
//|                                               http://vilela.one/ |
//+------------------------------------------------------------------+
#property copyright "Henrique Vilela"
#property link      "http://vilela.one/"
#property version   "1.00"

#property indicator_chart_window

#property indicator_buffers 3
#property indicator_plots   3

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

double         SequenciaBuffer[];

input ushort   Conta=3; // Contagem 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,SequenciaBuffer,INDICATOR_DATA);

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
      if(close[i]>open[i]) // Positivo
        {
         if(close[i-1]>open[i-1]) // Anterior Positivo
           {
            SequenciaBuffer[i]=SequenciaBuffer[i-1]+1;
           }
         else  // Anterior Negativo
           {
            SequenciaBuffer[i]=1;
           }
        }
      else if(close[i]<open[i]) // Negativo
        {
         if(close[i-1]<open[i-1]) //  // Anterior Negativo
           {
            SequenciaBuffer[i]=SequenciaBuffer[i-1]-1;
           }
         else  // Anterior Positivo
           {
            SequenciaBuffer[i]=-1;
           }
        }
      else // Doji (nem positivo, nem negativo)
        {
         SequenciaBuffer[i]=0;
        }

      CompraBuffer[i]= SequenciaBuffer[i] == Conta ? low[i] : EMPTY_VALUE;
      VendaBuffer[i] = -SequenciaBuffer[i] == Conta ? high[i] : EMPTY_VALUE;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
