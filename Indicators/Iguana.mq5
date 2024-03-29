#property copyright "Mario"
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


double corpo,open25cents,open75cents;
bool open_close25,open_close75,Is4High,Is4Low;
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
   for(int i=MathMax(4,prev_calculated-1); i<rates_total; i++)
     {
      CompraBuffer[i]=VendaBuffer[i]=0;

      corpo=high[i]-low[i];
      open25cents=low[i]+0.25*corpo;
      open_close25=open[i]<=open25cents && close[i]<=open25cents;
      Is4High=high[i]>high[i-1] && high[i]>high[i-2] && high[i]>high[i-3];
      bool IguanaBaixa=open_close25 && corpo>=10*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE) && Is4High;

      open75cents=low[i]+0.75*corpo;
      open_close75=open[i]>=open75cents && close[i]>=open75cents;
      Is4Low=low[i]<low[i-1] && low[i]<low[i-2] && low[i]<low[i-3];

      bool IguanaAlta=open_close75 && corpo>=10*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE) && Is4Low;

      CompraBuffer[i]= IguanaAlta ? low[i] : EMPTY_VALUE;
      VendaBuffer[i] = IguanaBaixa ? high[i] : EMPTY_VALUE;

     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
