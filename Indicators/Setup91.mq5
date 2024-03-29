//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Mario"
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


#property indicator_label3  "Média"
#property indicator_type3  DRAW_LINE
#property indicator_color3  clrAqua
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1



input int      InpPeriod=9;   // Period EMA

double         VendaBuffer[];
double         CompraBuffer[];
double BufferTMP[];

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

   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,BufferTMP,INDICATOR_DATA);

   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);

   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);


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

   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
   CopyBuffer(handle_ema,0,0,to_copy,BufferTMP);

   for(int i=MathMax(3,prev_calculated); i<rates_total; i++)
     {

      CompraBuffer[i]=VendaBuffer[i]=0;

      bool sig_up=BufferTMP[i-2]>BufferTMP[i-1] && BufferTMP[i-3]>BufferTMP[i-2] && BufferTMP[i]>BufferTMP[i-1];

      bool sig_down=BufferTMP[i-2]<BufferTMP[i-1] && BufferTMP[i-3]<BufferTMP[i-2] && BufferTMP[i]<BufferTMP[i-1];

      CompraBuffer[i]= sig_up ? low[i] : EMPTY_VALUE;
      VendaBuffer[i] = sig_down ? high[i] : EMPTY_VALUE;


     }

   return(rates_total-1);
  }
//+------------------------------------------------------------------+
