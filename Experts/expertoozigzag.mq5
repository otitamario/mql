//+----------------------------------------------------------------------+
//|                                                  ExpertOOZigZag.mq5  |
//|                   Copyright © 2013, Laplacianlab - Jordi Bassagañas  | 
//+----------------------------------------------------------------------+
#include <zigzagtrend.mqh>
//--- EA properties
#property copyright     "Copyright © 2013, Laplacianlab - Jordi Bassagañas"
#property link          "http://www.mql5.com/en/articles"
#property version       "1.00"
#property description   "This dummy Expert Advisor is just for showing how to use the object-oriented version of MetaQuotes' ZigZag indicator."
//--- EA inputs
input ENUM_TIMEFRAMES   EAPeriod=PERIOD_H1;
input string            CurrencyPair="EURUSD";
//--- global variables
CiZigZag *ciZigZag;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ciZigZag=new CiZigZag;
   ciZigZag.Create(CurrencyPair,EAPeriod,12,5,3);
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   delete(ciZigZag);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {   
   //--- refresh data
   ciZigZag.Refresh();
   //--- print values
   if(ciZigZag.ZigZag(0)!=0) Print("OO ZigZag buffer(0): ", ciZigZag.ZigZag(0));
   if(ciZigZag.High(0)!=0) Print("OO ZigZag high(0): ", ciZigZag.High(0));
   if(ciZigZag.Low(0)!=0) Print("OO ZigZag low(0): ",ciZigZag.Low(0));
  }
//+------------------------------------------------------------------+
