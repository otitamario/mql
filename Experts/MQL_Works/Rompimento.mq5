//+------------------------------------------------------------------+
//|                                                       Rompimento |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, Leandro Ferreira"
#property version   "1.00"

#include <Trade\Trade.mqh>
#include <..\Include\Utils\TraderLog.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum EnumAlvo
  {
   x1=1,
   x2=2,
   x3=3
  };

input int               QtdeBarras        = 5;                       //Quantidade de barras
input ENUM_TIMEFRAMES   PeriodoStop       = PERIOD_M5;               //Periodicidade dos stops
input double            StopFinanceiro    = 1000;                    //Valor do stop financeiro
input int               StopInicial       = 70;                      //Amplitude do stop loss, em %
input EnumAlvo          Alvo              = 1;                       //Alvo do gain
input bool              CancelaOrdem      = true;                    //Cancela ordem na ponta inversa
input int               VariacaoEntrada   = 4;                       //Variacao do gatilho de entrada, em ticks
input int               VariacaoLoss      = 4;                       //Variacao do preço stop loss, em ticks
input datetime          HoraEncerramento  = D'2001.01.01 16:50:00';  //Horário de encerramento das posições

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrade         trade;
int            contadorBarras=0;
double         maxima,minima;
MqlRates       rt[2];
MqlRates       tf[8];
bool           onTrading=false;
bool           onPosition=false;
bool           stopOrdem=false;
bool           gainOrdem=false;
bool           pulaBarra=false;
double         lote;
MqlDateTime    dat,dataini,datafim,dataEncerramento;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit(void)
  {

   EventSetTimer(1);
   trade.SetTypeFilling(ORDER_FILLING_RETURN);

//ArraySetAsSeries(tf,true);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick(void)
  {

   if(onPosition && !PositionSelect(_Symbol))
     {
      onTrading=false;
      //onPosition=false;
      contadorBarras=0;
      stopOrdem=false;
      gainOrdem=false;

      DeleteOrders();
      minima=0;
      maxima=0;

      pulaBarra=true;

     }

   if(PositionSelect(_Symbol))
     {

      onPosition=true;

      if(stopOrdem==false)
        {

         if(CancelaOrdem)
           {
            DeleteOrders();
           }

         double entrada=PositionGetDouble(POSITION_PRICE_OPEN);

         double limit=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)*VariacaoLoss;

         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
           {
            double tamanho=(entrada-minima);
            double preco=entrada-(tamanho *((StopInicial)/100.0));
            trade.OrderOpen(_Symbol,ORDER_TYPE_SELL_STOP_LIMIT,lote,preco-limit,preco,0,0,ORDER_TIME_GTC,0,"Stop Loss");

            double alvo=entrada+(tamanho*Alvo);
            if(alvo!=PositionGetDouble(POSITION_TP))
               trade.PositionModify(_Symbol,0,alvo);

           }
         else
           {
            double tamanho=(maxima-entrada);
            double preco=entrada+(tamanho *((StopInicial)/100.0));
            trade.OrderOpen(_Symbol,ORDER_TYPE_BUY_STOP_LIMIT,lote,preco+limit,preco,0,0,ORDER_TIME_GTC,0,"Stop Loss");

            double alvo=entrada-(tamanho*Alvo);
            if(alvo!=PositionGetDouble(POSITION_TP))
               trade.PositionModify(_Symbol,0,alvo);

           }
         stopOrdem=true;
        }

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(isNewBar(PERIOD_M1))
     {

      CheckHorarioEncerramento();

      CheckToposFundos();

      if(pulaBarra)
        {
         pulaBarra=false;
         return;
        }

      contadorBarras++;

      if(CopyRates(_Symbol,PERIOD_M1,0,2,rt)!=2)
        {
         Print("CopyRates of ",_Symbol," failed, no history");
         return;
        }

      MqlDateTime data1,data2;

      if(!TimeToStruct(rt[0].time,data1)) return;
      if(!TimeToStruct(rt[1].time,data2)) return;

      if(data1.day!=data2.day)
        {
         onTrading=false;
         onPosition=false;
         contadorBarras=0;
         stopOrdem=false;
         gainOrdem=false;

         DeleteOrders();
         minima=0;
         maxima=0;

         return;
        }

      if(onTrading==false)
        {

         if(minima==0)
            minima=rt[0].low;

         if(maxima<rt[0].high)
            maxima=rt[0].high;

         if(minima>rt[0].low)
            minima=rt[0].low;

        }
     }

   if(contadorBarras==QtdeBarras && onTrading==false)
     {
      maxima += SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
      minima -= SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);

      double tamanho=(maxima-minima);

      lote=StopFinanceiro/tamanho;

      lote=((int)lote/100)*100;

      double limit=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)*VariacaoEntrada;

      trade.OrderOpen(_Symbol,ORDER_TYPE_BUY_STOP_LIMIT,lote,maxima+limit,maxima,0,0,ORDER_TIME_DAY);
      trade.OrderOpen(_Symbol,ORDER_TYPE_SELL_STOP_LIMIT,lote,minima-limit,minima,0,0,ORDER_TIME_DAY);
      onTrading=true;

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void  OnTradeTransaction(
                         const MqlTradeTransaction&    trans,        // estrutura das transações de negócios
                         const MqlTradeRequest&        request,      // estrutura solicitada
                         const MqlTradeResult&         result        // resultado da estrutura
                         )
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double OnTester(void)

  {
   return 0;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool isNewBar(ENUM_TIMEFRAMES period)
  {//--- memorize the time of opening of the last bar in the static variable
   static datetime last_time=0;
//--- current time
   datetime lastbar_time=(datetime)SeriesInfoInteger(Symbol(),period,SERIES_LASTBAR_DATE);

//--- if it is the first call of the function
   if(last_time==0)
     {
      //--- set the time and exit
      last_time=lastbar_time;
      return(false);
     }

//--- if the time differs
   if(last_time!=lastbar_time)
     {
      //--- memorize the time and return true
      last_time=lastbar_time;
      return(true);
     }
//--- if we passed to this line, then the bar is not new; return false
   return(false);
  }
//+------------------------------------------------------------------+

bool DeleteOrders()
  {

   uint     total=OrdersTotal();
   ulong    ticket=0;
   bool     retorno=false;

   for(uint i=0;i<total;i++)
      if((ticket=OrderGetTicket(i))>0)
         if(OrderGetString(ORDER_SYMBOL)==Symbol())
            retorno=trade.OrderDelete(ticket);

   if(retorno)
      DeleteOrders();

   return retorno;

  }
//+------------------------------------------------------------------+
void CheckHorarioEncerramento()
  {
   TimeToStruct(TimeCurrent(),dat);
   TimeToStruct(HoraEncerramento,dataEncerramento);

   if(dat.hour>=dataEncerramento.hour && dat.min>=dataEncerramento.min)
      if(PositionSelect(_Symbol))
         trade.PositionClose(_Symbol);

  }
//+------------------------------------------------------------------+

void CheckToposFundos()
  {

   if(PositionSelect(_Symbol))
     {

      if(CopyRates(_Symbol,PeriodoStop,0,8,tf)!=8)
        {
         Print("CopyRates of ",_Symbol," failed, no history");
         return;
        }

      double limit=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE)*VariacaoLoss;

      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         if(tf[4].high>tf[1].high &&
            tf[4].high>tf[2].high &&
            tf[4].high>tf[3].high &&
            tf[4].high>tf[5].high &&
            tf[4].high>tf[6].high &&
            tf[4].high>tf[7].high)
           {

            ulong ticket=FindOrder("Stop Loss");
            double stop = 0;
            if(OrderSelect(ticket))
               stop=OrderGetDouble(ORDER_PRICE_OPEN);

            if(stop>tf[4].high || stop==0)
               trade.OrderModify(ticket,tf[4].high+SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE),0,0,ORDER_TIME_DAY,0,tf[4].high-limit);
              
           }
        }
      else
        {
         if(tf[4].low<tf[1].low &&
            tf[4].low<tf[2].low &&
            tf[4].low<tf[3].low &&
            tf[4].low<tf[5].low &&
            tf[4].low<tf[6].low &&
            tf[4].low<tf[7].low)
           {
           
            ulong ticket=FindOrder("Stop Loss");
            double stop=0;
            if(OrderSelect(ticket))
               stop=OrderGetDouble(ORDER_PRICE_OPEN);

            if(stop<tf[4].low || stop==0)
               trade.OrderModify(ticket,tf[4].low-SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE),0,0,ORDER_TIME_DAY,0,tf[4].low+limit);
               
           }
        }
     }
  }
//+------------------------------------------------------------------+

ulong FindOrder(string comment)
  {

   bool     retorno=false;
   uint     total=OrdersTotal();
   ulong    ticket=0;
   ulong    _ticket=0;
   for(uint i=0;i<total;i++)
     {
      if((_ticket=OrderGetTicket(i))>0)
         if(OrderGetString(ORDER_SYMBOL)==_Symbol)
            if(OrderGetString(ORDER_COMMENT)==comment)
               ticket=_ticket;
     }

   return ticket;

  }
//+------------------------------------------------------------------+
