//+------------------------------------------------------------------+
//|                                                   Desconecta.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

input int InpSegundos=1;//Segundos Limite 
#include <Trade\SymbolInfo.mqh>  

MqlTick tick;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create timer

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
PeriodoSemTicks(InpSegundos);
  
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {

//---
  }
//+------------------------------------------------------------------+
//| Analisamos o período que ficamos sem receber ticks da corretora  |
//+------------------------------------------------------------------+
void PeriodoSemTicks(int Segundos)
  {//Comment("Teste");
   static const bool isTester=(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_OPTIMIZATION));
   static datetime horaConexao;

   if(!isTester)
     {
      if(horaConexao!=TimeCurrent() && horaConexao!=0)
        {
         if(Segundos<(TimeCurrent()-horaConexao))
           {
            SymbolInfoTick(_Symbol,tick);
            if(tick.bid>=tick.ask) Comment("Ativo em leilão, valor teórico "+DoubleToString(tick.bid,_Digits)+" para "+_Symbol+" às "+TimeToString(horaConexao,TIME_SECONDS)+" intervalo de "+TimeToString((TimeCurrent()-horaConexao),TIME_SECONDS)+" sem receber ticks.");
            else Comment("Último tick recebido da corretora "+AccountInfoString(ACCOUNT_COMPANY)+" às "+TimeToString(horaConexao,TIME_SECONDS)+" intervalo de "+TimeToString((TimeCurrent()-horaConexao),TIME_SECONDS)+" sem receber ticks.");
           }
         horaConexao=TimeCurrent();
        }
      if(horaConexao==0) horaConexao=TimeCurrent();
     }
  }

//+------------------------------------------------------------------+
