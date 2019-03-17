//+------------------------------------------------------------------+
//|                                                     MACD TAV.mq5 |
//|                                                     Hugo Raniere |
//|                                                      hugoraniere |
//+------------------------------------------------------------------+
#property copyright "Hugo Raniere"
#property link      "hugoraniere"
#property version   "1.02"

#include <MovingAverages.mqh>

#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot EMA1
#property indicator_label1  "MACD"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot EMA2
#property indicator_label2  "SIGNAL"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkViolet
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- input parameters
int      Periodo_EMA_Fast=21; // Período EMA Rápida
int      Periodo_EMA_Slow=89; // Período EMA Lenta
int      Periodo_Signal=42; // Período Signal
//--- indicator buffers
double         macdBuffer[];
double         signalBuffer[];
//--- indicator handles
int            macdHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,macdBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,signalBuffer,INDICATOR_DATA);
   
   ArraySetAsSeries(macdBuffer, true);
   ArraySetAsSeries(signalBuffer, true);
   
   if (_Period == PERIOD_H1 || _Period == PERIOD_M15)
   {
      Periodo_EMA_Fast = 27;
      Periodo_EMA_Slow = 117;
      Periodo_Signal = 55;
   }
   else if (_Period == PERIOD_M1)
   {
      Periodo_EMA_Fast = 21;
      Periodo_EMA_Slow = 89;
      Periodo_Signal = 42;
   }
   else {
      Periodo_EMA_Fast = 17;
      Periodo_EMA_Slow = 72;
      Periodo_Signal = 34;
   }
   
   
   //--- cria handlers dos indicadores
   macdHandle=iMACD(NULL, 0, Periodo_EMA_Fast, Periodo_EMA_Slow, Periodo_Signal, PRICE_CLOSE);
   
   //--- se o manipulador não é criado
   if(macdHandle==INVALID_HANDLE)
     {
      //--- mensagem sobre a falha e a saída do código de erro
      PrintFormat("Falha ao criar o manipulador do indicador iMACD para o símbolo %s/%s, código de erro %d",
                  _Symbol,
                  EnumToString(_Period),
                  GetLastError());
      //--- o indicador é interrompido precocemente
      return(INIT_FAILED);
     }
   
   //--- name for indicator
   PlotIndexSetString(0,PLOT_LABEL,StringFormat("MACD (%u, %u)",Periodo_EMA_Fast, Periodo_EMA_Slow));
   PlotIndexSetString(1,PLOT_LABEL,StringFormat("SIGNAL (%u)",Periodo_Signal));
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("MACD TAV(%u, %u, %u)",Periodo_EMA_Fast, Periodo_EMA_Slow, Periodo_Signal));
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate (const int rates_total,      
                 const int prev_calculated,  
                 const int begin,            
                 const double& price[])      
  {

//--- redefinir o código de erro
   ResetLastError();
//--- verifica se todos os dados estão calculados
   if(BarsCalculated(macdHandle)<rates_total)
   {
      Print("Erro ao calcular MACD. ",GetLastError());
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

//--- get MACD buffer values
   if(CopyBuffer(macdHandle,0,0,to_copy,macdBuffer)<=0)
     {
      Print("Erro ao copiar MACD. ",GetLastError());
      return(0);
     }
     
   // Calcula Signal
   if(ExponentialMAOnBuffer(rates_total, prev_calculated, Periodo_EMA_Slow, Periodo_Signal, macdBuffer, signalBuffer) != rates_total)
     {
      Print("Erro ao calcular signal. ",GetLastError());
      return(0);
     }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
