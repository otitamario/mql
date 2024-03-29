//+------------------------------------------------------------------+
//|                                                    EMA_Angle.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description   ""
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
#property indicator_label1  "Media"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID // Line style 
#property indicator_label2  "Afastamento Superior"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_DOT // Line style 
#property indicator_label3  "Afastamento Inferior"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrMagenta
#property indicator_style3  STYLE_DOT // Line style 
//--- input parameters
input int      period_media=7;   // Periodo Média
input ENUM_MA_METHOD modo_media=MODE_EMA;//Modo Média
input ENUM_APPLIED_PRICE app_media=PRICE_CLOSE;//Appliedd Price
input double afast_dx=50;//Afastamento em Pontos

//--- indicator buffers
double               ExtLineBuffer[];
double               HighBuffer[];
double               LowBuffer[];
//--- global variables
int            period;
int            handle_ema;
double ponto;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set parameters
   period=(period_media<1 ? 1 : period_media);
   handle_ema=iMA(NULL,0,period,0,modo_media,app_media);
   if(handle_ema==INVALID_HANDLE)
     {
      Print("Failed to create an EMA handle");
      return INIT_FAILED;
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,LowBuffer,INDICATOR_DATA);

//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,period_media);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,period_media);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,period_media);

//--- strings parameters
   string params="("+(string)period+")";
   IndicatorSetString(INDICATOR_SHORTNAME,"Afastamento DX"+params);

   ponto=SymbolInfoDouble(_Symbol,SYMBOL_POINT);

   int find_wdo=StringFind(_Symbol,"WDO");
   int find_dol=StringFind(_Symbol,"DOL");
   if(find_dol>=0|| find_wdo>=0) ponto=1.0;

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(handle_ema);
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
//--- Checking for minimum number of bars
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
   CopyBuffer(handle_ema,0,0,to_copy,ExtLineBuffer);

   for(int i=MathMax(2,prev_calculated-1); i<rates_total;i++)
     {

      HighBuffer[i]=ExtLineBuffer[i]+afast_dx*ponto;
      LowBuffer[i]=ExtLineBuffer[i]-afast_dx*ponto;

     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
