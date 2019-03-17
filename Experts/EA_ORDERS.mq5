//+------------------------------------------------------------------+
//|                                                    EA_ORDERS.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
int order_id;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   mysymbol.Name(Symbol());
   mytrade.SetTypeFillingBySymbol(Symbol());
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
   mysymbol.Refresh();
   mysymbol.RefreshRates();
   if(OrdersTotal()<1)
     {
      if(iClose(Symbol(),PERIOD_CURRENT,1)<iClose(Symbol(),PERIOD_CURRENT,2))
        {
         if(mytrade.SellLimit(0.01,mysymbol.Ask(),Symbol()))
           {
            order_id=mytrade.ResultOrder();
            if(myorder.Select(order_id))myorder.StoreState();

           }
        }
      else
        {
         mytrade.BuyLimit(0.01,mysymbol.Bid(),Symbol());
         order_id=mytrade.ResultOrder();
         if(myorder.Select(order_id))myorder.StoreState();

        }
     }

      if(myorder.CheckState())
        {
         Print("ORDER State ",EnumToString(myorder.State()));
        }
myposition.
  }
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//---

// Print("ORDER State ",EnumToString(trans.order_state));
  }
//+------------------------------------------------------------------+
