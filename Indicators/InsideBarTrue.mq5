#property copyright "Mario"
#property version   "1.00"

#define SECONDSINADAY  300   //86400

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4

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

#property indicator_label3  "Maxima Anterior"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGold
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2

#property indicator_label4  "Mínima Anterior"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrBlueViolet
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2

double         VendaBuffer[];
double         CompraBuffer[];
double         MaximaAnteriorBuffer[];
double         MinimaAnteriorBuffer[];

bool break_candle=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,MaximaAnteriorBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,MinimaAnteriorBuffer,INDICATOR_DATA);

   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);

   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);

   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);

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

   for(int i=MathMax(2,prev_calculated); i<rates_total; i++)
     {

      if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
        {
         CompraBuffer[i]=EMPTY_VALUE;
         VendaBuffer[i]=EMPTY_VALUE;
         MaximaAnteriorBuffer[i]=EMPTY_VALUE;
         MinimaAnteriorBuffer[i]=EMPTY_VALUE;

        }


      if(high[i-2]>high[i-1] && low[i-2]<low[i-1]) // if((time[i]/SECONDSINADAY)==(time[i-1]/SECONDSINADAY))
        {

         MinimaAnteriorBuffer[i-1]=low[i-2];
         MaximaAnteriorBuffer[i-1]=high[i-2];
         MinimaAnteriorBuffer[i-2]=low[i-2];
         MaximaAnteriorBuffer[i-2]=high[i-2];

         break_candle=false;
        }

      if(low[i]>MinimaAnteriorBuffer[i-1] && (high[i]<MaximaAnteriorBuffer[i-1] && MaximaAnteriorBuffer[i-1]!=EMPTY_VALUE && MaximaAnteriorBuffer[i-1]!=0))

        {
         MinimaAnteriorBuffer[i]=MinimaAnteriorBuffer[i-1];
         MaximaAnteriorBuffer[i]=MaximaAnteriorBuffer[i-1];
        }
      else
        {
         MaximaAnteriorBuffer[i]=EMPTY_VALUE;
         MinimaAnteriorBuffer[i]=EMPTY_VALUE;
        }


      if(high[i]>MaximaAnteriorBuffer[i-1] && MaximaAnteriorBuffer[i-1]!=EMPTY_VALUE)
        {
         CompraBuffer[i]=low[i];
         break_candle=true;

        }
      if(low[i]<MinimaAnteriorBuffer[i-1] && MinimaAnteriorBuffer[i-1]!=EMPTY_VALUE)
        {
         VendaBuffer[i]=high[i];
         break_candle=true;
        }

     }

   return(rates_total-1);
  }
//+------------------------------------------------------------------+
