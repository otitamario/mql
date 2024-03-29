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
#property indicator_buffers 5
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

input int      InpPeriod=9;   // Period EMA
input bool UsarEMA=true;//Usar Filtro da Média
input bool PlotEMA=false;//Plotar EMA se não usá-la?

double         VendaBuffer[];
double         CompraBuffer[];
double         MaximaAnteriorBuffer[];
double         MinimaAnteriorBuffer[];
double         BufferTMP[];

int            period;
int            handle_ema;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   period=(InpPeriod<1 ? 1 : InpPeriod);
   handle_ema=iMA(NULL,0,period,0,MODE_EMA,PRICE_CLOSE);
   if(handle_ema==INVALID_HANDLE)
     {
      Print("Failed to create an EMA handle");
      return INIT_FAILED;
     }
   if(UsarEMA || (!UsarEMA && PlotEMA))ChartIndicatorAdd(ChartID(),0,handle_ema);

   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,MaximaAnteriorBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,MinimaAnteriorBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,BufferTMP,INDICATOR_CALCULATIONS);

   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);

   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);

   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);

   string params="("+(string)period+")";
   IndicatorSetString(INDICATOR_SHORTNAME,"InsideBarMedia"+params);
   ArrayInitialize(CompraBuffer,EMPTY_VALUE);
   ArrayInitialize(VendaBuffer,EMPTY_VALUE);
   ArrayInitialize(MinimaAnteriorBuffer,EMPTY_VALUE);
   ArrayInitialize(MaximaAnteriorBuffer,EMPTY_VALUE);
   return(INIT_SUCCEEDED);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(handle_ema);
   ChartIndicatorDelete(ChartID(),0,"MA("+string(InpPeriod)+")");
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
   static bool break_candle=false;

   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
   CopyBuffer(handle_ema,0,0,to_copy,BufferTMP);

   for(int i=MathMax(1,prev_calculated); i<rates_total; i++)
     {
      //      if ( high[i-1]>high[i] && low[i-1]<low[i] ) // if((time[i]/SECONDSINADAY)==(time[i-1]/SECONDSINADAY))
      CompraBuffer[i]=EMPTY_VALUE;
      VendaBuffer[i]=EMPTY_VALUE;
      MaximaAnteriorBuffer[i]=EMPTY_VALUE;
      MinimaAnteriorBuffer[i]=EMPTY_VALUE;

      if(high[i-1]>high[i] && low[i-1]<low[i]) // if((time[i]/SECONDSINADAY)==(time[i-1]/SECONDSINADAY))
        {

         MinimaAnteriorBuffer[i]=low[i-1];
         MaximaAnteriorBuffer[i]=high[i-1];
         MinimaAnteriorBuffer[i-1]=low[i-1];
         MaximaAnteriorBuffer[i-1]=high[i-1];


         break_candle=false;
        }
      else
        {
         if(!break_candle)
           {
            MinimaAnteriorBuffer[i]=MinimaAnteriorBuffer[i-1];
            MaximaAnteriorBuffer[i]=MaximaAnteriorBuffer[i-1];
           }
        }

      if(!UsarEMA)
        {
         if(high[i]>MaximaAnteriorBuffer[i])
           {
            CompraBuffer[i]=low[i];
            break_candle=true;
           }
         if(low[i]<MinimaAnteriorBuffer[i] && MinimaAnteriorBuffer[i]!=EMPTY_VALUE)
           {
            VendaBuffer[i]=high[i];
            break_candle=true;
           }
        }

      else
        {

         if(high[i]>MaximaAnteriorBuffer[i] && high[i]>BufferTMP[i])
           {
            CompraBuffer[i]=low[i];
            break_candle=true;
           }
         if(low[i]<MinimaAnteriorBuffer[i] && MinimaAnteriorBuffer[i]!=EMPTY_VALUE && low[i]<BufferTMP[i])
           {
            VendaBuffer[i]=high[i];
            break_candle=true;
           }

        }

     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
