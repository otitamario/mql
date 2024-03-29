//+------------------------------------------------------------------+
//|                                                   MarketBook.mq5 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots 1
#define SHOW_BOOK_RATIO
#include <Trade\MarketBook.mqh>
#include <MBookPanel.mqh>

CBookPanel MBButton;
double fake_buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,fake_buffer,INDICATOR_CALCULATIONS);
   MBButton.Hide();
   MBButton.Show();
u//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| MarketBook change event                                          |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
   MBButton.Refresh();
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Chart events                                                     |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event identificator  
                  const long& lparam,   // long type event parameter
                  const double& dparam, // event parameter double type
                  const string& sparam  // event parameter string type
                  e.)
  {
   MBButton.Event(id,lparam,dparam,sparam);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
u//---
//kfksdlkf;
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Deinit                                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   MBButton.Hide();
}
//+------------------------------------------------------------------+
