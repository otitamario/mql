//+------------------------------------------------------------------+
//|                                                      EA_DLLs.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#import "Class1.dll"

//#import "Investingdll.dll"
//#import "Investing.dll"

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
string x=Class1::getPrecoAjuste("G19","08/01/2019");
//string y=Class1::getPrecoAjuste("G19");
//string z=Investing::getDados("EUR",2);
//string x=Investing::getDados("JPY",2);
Print("Ajuste G19 ",x);
//Print("Ajuste G19 ",y);
//Print("noticias ",z);


//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
