//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include<ChartObjects\ChartObjectsTxtControls.mqh>



CChartObjectRectLabel retang;

#define LARGURA_PAINEL 300 // Largura Painel
#define ALTURA_PAINEL 200 // Altura Painel

long curChartID;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   ChartSetInteger(0,CHART_SHIFT,0,true);
   ChartSetDouble(0,CHART_SHIFT_SIZE,25);

   retang.Create(0,"Retang",ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL)-1,LARGURA_PAINEL,30,LARGURA_PAINEL,ALTURA_PAINEL);
   retang.Corner(CORNER_RIGHT_UPPER);


//  retang.Create(0,"Retang",ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL)-1,0,ALTURA_PAINEL,LARGURA_PAINEL,ALTURA_PAINEL);
// retang.Corner(CORNER_LEFT_LOWER);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   retang.Delete();
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  {
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

  }// fim OnTick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
