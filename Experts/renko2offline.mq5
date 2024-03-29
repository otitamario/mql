//+------------------------------------------------------------------+
//|                                                Renko2offline.mq5 |
//|                                Copyright 2018, Guilherme Santos. |
//|                                               fishguil@gmail.com |
//|                                                Renko 2.0 Offline |
//|                                                                  |
//|2018-03-28:                                                       |
//| Fixed events and time from renko rates                           |
//|2018-04-02:                                                       |
//| Fixed renko open time on renko rates                             |
//|2018-04-10:                                                       |
//| Add tick event and remove timer event for tester                 |
//|2018-04-30:                                                       |
//| Correct volume on renko bars, wicks, performance, and parameters |
//|2018-05-10:                                                       |
//| Now with timer event                                             |
//|2018-05-16:                                                       |
//| New methods and MiniChart display by Marcelo Hoepfner            |
//|2018-06-21:                                                       |
//| New library with custom tick, performance and other improvements |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Guilherme Santos."
#property link      "fishguil@gmail.com"
#property version   "2.0"
#property description "Renko 2.0 Offline"
#include <RenkoCharts.mqh>
// Inputs
input string RenkoSymbol = "";                              //Symbol (Default = current)
input ENUM_RENKO_TYPE RenkoType = RENKO_TYPE_TICKS;         //Type
input double RenkoSize = 20;                                //Brick Size (Ticks, Pips or Points)
input bool RenkoWicks = true;                               //Show Wicks
input ENUM_RENKO_WINDOW RenkoWindow = RENKO_CURRENT_WINDOW; //Window
input int RenkoTimer = 1000;                                //Timer in milliseconds (0 = Off)
// Renko Charts
RenkoCharts RenkoOffline();
string original_symbol, custom_symbol;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//Get Symbol
   if(RenkoSymbol!="")
      original_symbol = RenkoSymbol;
//Check Period
   if(RenkoWindow == RENKO_CURRENT_WINDOW && ChartPeriod(0) != PERIOD_M1)
     {
      MessageBox("Renko must be M1 period!", __FILE__, MB_OK);
      ChartSetSymbolPeriod(0, _Symbol, PERIOD_M1);
      return(INIT_SUCCEEDED);
     }
//Check Symbol
   if(!RenkoOffline.ValidateSymbol(original_symbol))
     {
      MessageBox("Invalid symbol error. Select a valid symbol!", __FILE__, MB_OK);
      return(INIT_FAILED);
     }
//Setup Renko
   if(!RenkoOffline.Setup(original_symbol, RenkoType, RenkoSize, RenkoWicks))
     {
      MessageBox("Renko setup error. Check error log!", __FILE__, MB_OK);
      return(INIT_FAILED);
     }
//Create Custom Symbol
   RenkoOffline.CreateCustomSymbol();
   RenkoOffline.ClearCustomSymbol();
   custom_symbol = RenkoOffline.GetSymbolName();
//Load History
   RenkoOffline.UpdateRates();
   RenkoOffline.ReplaceCustomSymbol();   
//Chart Setup
   RenkoOffline.Start(RenkoWindow);
   if(RenkoTimer>0) EventSetMillisecondTimer(RenkoTimer);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   RenkoOffline.Stop();
  }
//+------------------------------------------------------------------+
//| Tick Event (for testing purposes only)                           |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(!IsStopped()) RenkoOffline.Refresh();
  }
//+------------------------------------------------------------------+
//| Book Event                                                       |
//+------------------------------------------------------------------+
void OnBookEvent(const string& symbol)
  {
   OnTick();
  }
//+------------------------------------------------------------------+
//| Timer Event (Turn off when backtesting)                          |
//+------------------------------------------------------------------+
void OnTimer()
  {
   OnTick();
  }
//+------------------------------------------------------------------+