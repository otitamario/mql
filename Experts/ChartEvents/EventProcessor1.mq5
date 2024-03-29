//+------------------------------------------------------------------+
//|                                              EventProcessor1.mq5 |
//|                                           Copyright 2014, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, denkir"
#property link      "https://login.mql5.com/en/users/denkir"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Easy access to the trade functions                               |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_BOOL
  {
   No=0,  // No
   Yes=1, // Yes
  };
//+------------------------------------------------------------------+
//| Iputs                                                            |
//+------------------------------------------------------------------+
sinput string Info_trade="+===--Trade--====+";   // +===--Trade--====+
input double InpLot=0.02;                        // Lot
input int InpStopLoss=125;                       // Stop Loss
input int InpTakeProfit=250;                     // Take Profit
input int InpSlippage=50;                        // Slippage

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,// event identifier:
                  const long   &lparam,
                  const double &dparam,
                  const string &sparam
                  )
  {
   string comment="Last event: ";

//--- select event on chart
   switch(id)
     {
      //--- 1
      case CHARTEVENT_KEYDOWN:
        {
         //--- "up" arrow
         if(lparam==38)
            TryToBuy();

         //--- "down" arrow
         else if(lparam==40)
            TryToSell();

         comment+="1) keystroke";
         break;
        }
      //--- 2
      case CHARTEVENT_MOUSE_MOVE:
        {
         comment+="2) mouse";
         //---
         break;
        }
      //--- 3
      case CHARTEVENT_OBJECT_CREATE:
        {
         comment+="3) create graphical object";
         //---
         break;
        }
      //--- 4
      case CHARTEVENT_OBJECT_CHANGE:
        {
         comment+="4) change object properties via properties dialog";
         //---
         break;
        }
      //--- 5
      case CHARTEVENT_OBJECT_DELETE:
        {
         comment+="5) delete graphical object";
         //---
         break;
        }
      //--- 6
      case CHARTEVENT_CLICK:
        {
         comment+="6) mouse click on chart";
         //---
         break;
        }
      //--- 7
      case CHARTEVENT_OBJECT_CLICK:
        {
         comment+="7) mouse click on graphical object";
         //---
         break;
        }
      //--- 8
      case CHARTEVENT_OBJECT_DRAG:
        {
         comment+="8) move graphical object with mouse";
         //---
         break;
        }
      //--- 9
      case CHARTEVENT_OBJECT_ENDEDIT:
        {
         comment+="9) finish editing text";
         //---
         break;
        }
      //--- 10
      case CHARTEVENT_CHART_CHANGE:
        {
         comment+="10) modify chart";
         //---
         break;
        }
     }
//---
   Comment(comment);
  }
//+------------------------------------------------------------------+
//| Try to buy by market                                             |
//+------------------------------------------------------------------+
bool TryToBuy(void)
  {
   bool is_done=false;
//---
   CTrade myTrade;
   MqlTick last_tick;
//--- get current prices
   if(SymbolInfoTick(_Symbol,last_tick))
     {
      myTrade.SetDeviationInPoints(InpSlippage);
      //--- prices
      double open_pr,sl_pr,tp_pr;
      open_pr=sl_pr=tp_pr=WRONG_VALUE;
      //---
      open_pr=NormalizeDouble(last_tick.ask,_Digits);
      sl_pr=NormalizeDouble(open_pr-_Point*InpStopLoss,_Digits);
      tp_pr=NormalizeDouble(open_pr+_Point*InpTakeProfit,_Digits);

      //--- buy by market
      is_done=myTrade.Buy(InpLot,_Symbol,open_pr,sl_pr,tp_pr);
     }
//---
   return is_done;
  }
//+------------------------------------------------------------------+
//| Try to sell by market                                            |
//+------------------------------------------------------------------+
bool TryToSell(void)
  {
   bool is_done=false;
//---
   CTrade myTrade;
   MqlTick last_tick;
//--- get current prices
   if(SymbolInfoTick(_Symbol,last_tick))
     {
      myTrade.SetDeviationInPoints(InpSlippage);
      //--- prices
      double open_pr,sl_pr,tp_pr;
      open_pr=sl_pr=tp_pr=WRONG_VALUE;
      //---
      open_pr=NormalizeDouble(last_tick.bid,_Digits);
      sl_pr=NormalizeDouble(open_pr+_Point*InpStopLoss,_Digits);
      tp_pr=NormalizeDouble(open_pr-_Point*InpTakeProfit,_Digits);

      //--- sell by market
      is_done=myTrade.Sell(InpLot,_Symbol,open_pr,sl_pr,tp_pr);
     }
//---
   return is_done;
  }
//+------------------------------------------------------------------+
