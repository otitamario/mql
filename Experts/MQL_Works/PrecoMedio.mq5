//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>
CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;

//--- input parameters
input double  Lot=10;//Lote
input double BreakEvenPoint1=100;//Pontos para BreakEven 1
input double ProfitPoint1=50;//Pontos de Lucro da Posicao 1
input double BreakEvenPoint2=150;//Pontos para BreakEven 2
input double ProfitPoint2=100;//Pontos de Lucro da Posicao 2
input double BreakEvenPoint3=200;//Pontos para BreakEven 3
input double ProfitPoint3=150;//Pontos de Lucro da Posicao 3
input double TakeProfit=250;//Take Profit



double deviation_points=100;
double ponto,ticksize;
int digits;
double ask,bid,last;
double BreakEvenPoint[2],ProfitPoint[2];

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   mysymbol.Name(Symbol());
   mytrade.SetDeviationInPoints(deviation_points);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      Print("ORDER_FILLING_FOK");
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      Print("ORDER_FILLING_IOC");
   else
      Print("ORDER_FILLING_RETURN");
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      mytrade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      mytrade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      mytrade.SetTypeFilling(ORDER_FILLING_RETURN);
   ponto=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
   ticksize=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);

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

//Atualizacao das Cotacoes----ticks
   MqlTick last_tick;
   if(SymbolInfoTick(Symbol(),last_tick))
     {
      bid= last_tick.bid;
      ask=last_tick.ask;
      last=last_tick.last;

     }
   else
     {
      Print("Falhou obter o tick");
      return;
     }

TrailingStop(TraillingPoints,TraillingPoints,TraillingPoints);


  }
//+------------------------------------------------------------------+

bool Buy_opened()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && mysymbol.Name()==Symbol() && myposition.PositionType()==POSITION_TYPE_BUY)
         return(true);  //It is a Buy
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Sell_opened()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && mysymbol.Name()==Symbol() && myposition.PositionType()==POSITION_TYPE_SELL)
         return(true);  //It is a Buy
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double VolumeBuyTotal()
  {
   double vol=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.PositionType()==POSITION_TYPE_BUY)
         vol+=myposition.Volume();

   return vol;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double VolumeSellTotal()
  {
   double vol=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.PositionType()==POSITION_TYPE_SELL)
         vol+=myposition.Volume();

   return vol;

  }
//+------------------------------------------------------------------+

//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=mysymbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//|                                                                  |

void TrailingStop(int pTrailPoints,int pMinProfit=0,int pStep=10)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() &&  pTrailPoints>0)
        {

         double currentTakeProfit=myposition.TakeProfit();
         long posType=myposition.PositionType();
         double currentStop=myposition.StopLoss();
         double openPrice=myposition.PriceOpen();
         double point=mysymbol.Point();
         int digits=mysymbol.Digits();
         if(pStep<10) pStep=10;
         double step=pStep*point;

         double minProfit = pMinProfit * point;
         double trailStop = pTrailPoints * point;
         currentStop=NormalizeDouble(currentStop,digits);
         currentTakeProfit=NormalizeDouble(currentTakeProfit,digits);
         double trailStopPrice;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            trailStopPrice = bid - trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=bid-openPrice;

            if((trailStopPrice>=currentStop+step|| currentStop==0) && currentProfit>=minProfit)
              {
               mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
               mytrade.Buy(Lot,NULL,0,trailStopPrice,currentTakeProfit,"");


              }

           }
         else if(posType==POSITION_TYPE_SELL)
           {
            trailStopPrice = ask + trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=openPrice-ask;

            if((trailStopPrice<=currentStop-step || currentStop==0) && currentProfit>=minProfit)
              {
               mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
               mytrade.Sell(Lot,NULL,0,trailStopPrice,currentTakeProfit,"");
              }

           }
        }

     }
  }
  
  
  
  void BreakEvenPiram(string pSymbol,bool usarbreak,int &pBreakEven[],int &pLockProfit[])
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && usarbreak==true)
        {

         long posType=myposition.PositionType();
         long posTicket=myposition.Ticket();
         double currentSL=myposition.StopLoss();
         double openPrice;
         double currentTP=myposition.TakeProfit();
         double breakEvenStop;
         double currentProfit;
         double ponto=SymbolInfoDouble(pSymbol,SYMBOL_POINT);
         double bid,ask;

         if(posType==POSITION_TYPE_BUY)
           {
            openPrice=price_compra;
            bid=SymbolInfoDouble(pSymbol,SYMBOL_BID);
            currentProfit=bid-openPrice;
            //Break Even 0
            if(currentProfit>=pBreakEven[0]*ponto && currentProfit<pBreakEven[1]*ponto)
              {
               breakEvenStop=openPrice+pLockProfit[0]*ponto;
               if(currentSL<breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop:");
                  mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                 }
              }
            //----------------------
            //Break Even 1
            else if(currentProfit>=pBreakEven[1]*ponto)
              {
               breakEvenStop=openPrice+pLockProfit[1]*ponto;
               if(currentSL<breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop:");
                  mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                 }
              }
           }
         //----------------------

         //----------------------

         else if(posType==POSITION_TYPE_SELL)
           {
            openPrice=price_venda;
            ask=SymbolInfoDouble(pSymbol,SYMBOL_ASK);
            currentProfit=openPrice-ask;
            //Break Even 0
            if(currentProfit>=pBreakEven[0]*ponto && currentProfit<pBreakEven[1]*ponto)
              {
               breakEvenStop=openPrice-pLockProfit[0]*ponto;
               if(currentSL>breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop:");
                  mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                 }
              }
            //----------------------
            //Break Even 1
            else if(currentProfit>=pBreakEven[1]*ponto)
              {
               breakEvenStop=openPrice-pLockProfit[1]*ponto;
               if(currentSL>breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop:");
                  mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                 }

              }
            //----------------------

           }

        }   //Fim Position Select

     }//Fim for
  }
