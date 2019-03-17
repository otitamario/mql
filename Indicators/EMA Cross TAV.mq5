//+------------------------------------------------------------------+
//|                                                EMA Cross TAV.mq5 |
//|                                                     Hugo Raniere |
//|                                                      hugoraniere |
//+------------------------------------------------------------------+
#property copyright "Hugo Raniere"
#property link      "hugoraniere"
#property version   "1.02"

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot EMA1
#property indicator_label1  "EMA1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkViolet
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot EMA2
#property indicator_label2  "EMA2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrAqua
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
int      Periodo_EMA1=21; // Período EMA1
int      Periodo_EMA2=42; // Período EMA2
//--- indicator buffers
double         EMA1Buffer[];
double         EMA2Buffer[];
//--- indicator handles
int            ema1Handle;
int            ema2Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,EMA1Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,EMA2Buffer,INDICATOR_DATA);
   
   if (_Period == PERIOD_H1 || _Period == PERIOD_M15)
   {
      Periodo_EMA1 = 27;
      Periodo_EMA2 = 55;
   }
   else if (_Period == PERIOD_M1)
   {
      Periodo_EMA1 = 21;
      Periodo_EMA2 = 42;
   }
   else {
      Periodo_EMA1 = 17;
      Periodo_EMA2 = 34;
   }
   
   
   //--- cria handlers dos indicadores
   ema1Handle=iMA(NULL,0,Periodo_EMA1,0,MODE_EMA,PRICE_CLOSE);
   ema2Handle=iMA(NULL,0,Periodo_EMA2,0,MODE_EMA,PRICE_CLOSE);
   
   //--- se o manipulador não é criado
   if(ema1Handle==INVALID_HANDLE || ema2Handle==INVALID_HANDLE)
     {
      //--- mensagem sobre a falha e a saída do código de erro
      PrintFormat("Falha ao criar o manipulador do indicador iEMA para o símbolo %s/%s, código de erro %d",
                  _Symbol,
                  EnumToString(_Period),
                  GetLastError());
      //--- o indicador é interrompido precocemente
      return(INIT_FAILED);
     }
   
   //--- name for indicator
   PlotIndexSetString(0,PLOT_LABEL,StringFormat("EMA1 (%u)",Periodo_EMA1));
   PlotIndexSetString(1,PLOT_LABEL,StringFormat("EMA2 (%u)",Periodo_EMA2));
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("EMA Cross TAV(%u, %u)",Periodo_EMA1, Periodo_EMA2));
   
//---
   return(INIT_SUCCEEDED);
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

//--- redefinir o código de erro
   ResetLastError();
//--- verifica se todos os dados estão calculados
   if(BarsCalculated(ema1Handle)<rates_total)
   {
      Print("Erro ao calcular EMA1. ",GetLastError());
      return(0);
   }
   if(BarsCalculated(ema2Handle)<rates_total)
   {
      Print("Erro ao calcular EMA2. ",GetLastError());
      return(0);
   }
//--- nós não podemos copiar todos os dados
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<=0) to_copy=rates_total;
   else
   {
      to_copy=rates_total-prev_calculated;
      //--- o último valor é sempre copiado
      to_copy++;
   }

//--- get EMA1 buffer values
   if(CopyBuffer(ema1Handle,0,0,to_copy,EMA1Buffer)<=0)
     {
      Print("Erro ao copiar EMA1. ",GetLastError());
      return(0);
     }
     
   if(CopyBuffer(ema2Handle,0,0,to_copy,EMA2Buffer)<=0)
     {
      Print("Erro ao copiar EMA2. ",GetLastError());
      return(0);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
