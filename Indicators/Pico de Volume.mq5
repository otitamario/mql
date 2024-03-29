//+------------------------------------------------------------------+
//|                                               Pico de Volume.mq5 |
//|                                                  Henrique Vilela |
//|                                               http://vilela.one/ |
//+------------------------------------------------------------------+
#property copyright "Henrique Vilela"
#property link      "http://vilela.one/"
#property version   "1.00"

#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   4

#property indicator_label1  "Venda"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrTomato
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Compra"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "Volume"
#property indicator_type3   DRAW_HISTOGRAM
#property indicator_color3  clrGray
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2

#property indicator_label4  "Media do Volume"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

input int      Periodos=14; // Períodos
input double   Superior=10; // Superior (%)

double         VendaBuffer[];
double         CompraBuffer[];
double         VolumeBuffer[];
double         MediaVolumeBuffer[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,VolumeBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,MediaVolumeBuffer,INDICATOR_DATA);

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
   for(int i=MathMax(Periodos-1,prev_calculated-1); i<rates_total; i++)
     {
      MediaVolumeBuffer[i]=0;
      for(int j=0; j<Periodos; j++)
        {
         MediaVolumeBuffer[i]+=volume[i-j]/Periodos;
        }
      MediaVolumeBuffer[i]*=1+Superior/100;

      VolumeBuffer[i]=volume[i];

      VendaBuffer[i]=volume[i]>MediaVolumeBuffer[i] && close[i]<open[i]?  MediaVolumeBuffer[i]: EMPTY_VALUE;
      CompraBuffer[i]=volume[i]>MediaVolumeBuffer[i] && close[i]>open[i]?  MediaVolumeBuffer[i]: EMPTY_VALUE;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
