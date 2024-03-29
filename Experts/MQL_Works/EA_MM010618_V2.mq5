//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>

//Classes
CNewBar NewBar;
CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
CTimer Timer;
CiMA *maP1;
CiMA *maP2;
CiMA *maP3;
CiMA *maP4;
CiMA *maP5;
// Parametros de Entrada 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_M15;//TIMEFRAME ROBO
input ulong Magic_Number=01062018;
input ulong deviation_points=100;//Deviation in Points
input double Lot=1000;//Lote Entrada

input bool UseTimer = true;
input int StartHour = 10;
input int StartMinute=0;

sinput string horafech="HORARIO PARA TERMINO DE ENTRADAS E FECHAMENTO DE POSICOES E ORDENS SE DAYTRADE";
input int EndHour=17;
input int EndMinute=30;
input double _Stop=0;//Stop Loss
input double _TakeProfit=1000; //Take Profit em pontos
sinput string smedias="-----------MEDIAS------------------";
input int per_mP1=30;//Periodo Media P1
input ENUM_MA_METHOD modoP1=MODE_SMA;//Modo Media P1
input int per_mP2=15;//Periodo Media P2
input ENUM_MA_METHOD modoP2=MODE_SMA;//Modo Media P2

input int per_mP3=20;//Periodo Media P3
input ENUM_MA_METHOD modoP3=MODE_SMA;//Modo Media P3

input int per_mP4=10;//Periodo Media P4
input ENUM_MA_METHOD modoP4=MODE_EMA;//Modo Media P4

input int per_mP5=30;//Periodo Media P5
input ENUM_MA_METHOD modoP5=MODE_EMA;//Modo Media P5
sinput string svars="*************   VARS   ******************************";
input double Var1=0;//  Var1
input double Var2=1;// Porcentagem Var2
input double Var3=1;// Porcentagem Var3
input double Var4=0;// Porcentagem Var4 (nao esta sendo usado devido ordem Sell Stop em Var3)
input double Var5=3;// Porcentagem Var5
input double Var6=1;// Porcentagem Var6
input double Var7=0;// Porcentagem Var7(nao esta sendo usado devido ordem Sell Stop em Var6)

                    //***************************************************************************************************

// Variaveis Globais

double ask,bid;
double lucro_total;
bool timerOn;
double StopLoss,TakeProfit;
double preco,ponto,ticksize,digits,lotes_trade,stop_movel;
double sellprice,oldprice;
long posicao;
long curChartID;
double open[],close[],high[],low[];
datetime time_inicio;
MqlDateTime inicio_struct;
ulong ENTRADAS_TOTAL;
ulong trade_ticket,compra1_ticket,venda1_ticket;
double preco_media_compra=0.0;
string informacoes;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   preco_media_compra=0.0;
   trade_ticket=0;
   ENTRADAS_TOTAL=0;
   mysymbol.Name(Symbol());
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.SetDeviationInPoints(deviation_points);
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

   inicio_struct.hour=0;
   inicio_struct.min=0;
   inicio_struct.sec=0;
   time_inicio=StructToTime(inicio_struct);
   lucro_total=0.0;
// Criação dos Indicadores
   maP1=new CiMA;
   maP1.Create(NULL,periodoRobo,per_mP1,0,modoP1,PRICE_CLOSE);
   maP2=new CiMA;
   maP2.Create(NULL,periodoRobo,per_mP2,0,modoP2,PRICE_CLOSE);
   maP3=new CiMA;
   maP3.Create(NULL,periodoRobo,per_mP3,0,modoP3,PRICE_CLOSE);
   maP4=new CiMA;
   maP4.Create(NULL,periodoRobo,per_mP4,0,modoP4,PRICE_CLOSE);
   maP5=new CiMA;
   maP5.Create(NULL,periodoRobo,per_mP5,0,modoP5,PRICE_CLOSE);

//Adiciona indicadores no Gráfico
   maP1.AddToChart(ChartID(),0);
   maP2.AddToChart(ChartID(),0);
   maP3.AddToChart(ChartID(),0);
   maP4.AddToChart(ChartID(),0);
   maP5.AddToChart(ChartID(),0);

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

// parametros incorretos desnecessarios na otimizacao

   string dados_invalidos;
   if(per_mP2>=per_mP1)
     {
      dados_invalidos="Media P2 tem que ser mais rapida que P1";
      Print(dados_invalidos);
      Alert(dados_invalidos);
      return(INIT_PARAMETERS_INCORRECT);

     }

   if(per_mP4>=per_mP5)
     {
      dados_invalidos="Media P4 tem que ser mais rapida que P5";
      Print(dados_invalidos);
      Alert(dados_invalidos);
      return(INIT_PARAMETERS_INCORRECT);

     }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   delete(maP1);
   delete(maP2);
   delete(maP3);
   delete(maP4);
   delete(maP5);
   Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");

//---

  }
//+------------------------------------------------------------------+ 
//| TradeTransaction function                                        | 
//+------------------------------------------------------------------+ 
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {

//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;

//--- if transaction is result of addition of the transaction in history

   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      ulong order_ticket=trans.order;
      myorder.SelectByIndex(order_ticket);
      mydeal.SelectByIndex(trans.deal);

      if(order_ticket==trade_ticket && trans.deal_type!=DEAL_TYPE_BALANCE)ENTRADAS_TOTAL++;

      if(order_ticket==compra1_ticket && trans.deal_type==DEAL_TYPE_BUY)
        {
         preco_media_compra=maP1.Main(0);
         sellprice=MathRound(((1-Var3/100)*maP1.Main(0))/ticksize)*ticksize;
         sellprice=NormalizeDouble(sellprice,digits);
         if(sellprice>bid)
           {
            informacoes="Preco Sell Stop Invalido. MAP1-Var3% acima do BID.Enviando ordem 20 pontos abaixo de low";
            Print(informacoes);
            sellprice=NormalizeDouble(low[0]-20*ponto,digits);
           }
         oldprice=PriceLastStopOrder(ORDER_TYPE_SELL_STOP);
         if(oldprice==-1 || sellprice>oldprice) // No order or New price is better
           {
            DeleteOrders(ORDER_TYPE_SELL_STOP);
            mytrade.SellStop(Lot,sellprice,Symbol(),0,0,0,0,"SELL STOP");
            trade_ticket=mytrade.ResultOrder();
            venda1_ticket=trade_ticket;

           }
        }

      if(order_ticket==venda1_ticket && trans.deal_type==DEAL_TYPE_SELL && myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
        {
         mytrade.PositionCloseBy(compra1_ticket,venda1_ticket);
         informacoes="Posicao Fechada por Ordem Sell Stop";
         Print(informacoes);
        }

      if(StringSubstr(mydeal.Comment(),0,2)=="sl" || StringSubstr(mydeal.Comment(),0,2)=="tp")
        {
         DeleteOrders(ORDER_TYPE_SELL_STOP);
         preco_media_compra=0.0;
         informacoes="Posicao Fechada por "+StringSubstr(mydeal.Comment(),0,2)=="sl"?"Stop Loss":"Take Profit";
         Print(informacoes);
        }

     }//End TRANSACTIONS DEAL ADD

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   Main_Program();

  }// fim OnTick
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//------------------------------------------------------------------------
//------------------------------------------------------------------------


//+-------------ROTINAS----------------------------------------------+

void Main_Program()
  {

   
   mysymbol.Refresh();
   mysymbol.RefreshRates();
//Atualização dos valores dos indicadores---------
   if(GetIndValue())
     {
      Print("Erro em obter OPEN, CLOSE,HIGH,LOW");
      return;
     }

   maP1.Refresh();
   maP1.Refresh();
   maP2.Refresh();
   maP3.Refresh();
   maP4.Refresh();
   maP5.Refresh();
//---------------------------
//--------------------------------


   bool novodia;
   novodia=NewBar.CheckNewBar(Symbol(),PERIOD_D1);
   if(novodia)
     {
      ENTRADAS_TOTAL=0;
      Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");
      informacoes="";
     }

   lucro_total=LucroOrdens()+LucroPositions();


   if(UseTimer==true) timerOn=Timer.DailyTimer(StartHour,StartMinute,EndHour,EndMinute);
   else timerOn=true;

//Atualizacao das Cotacoes----ticks
   MqlTick last_tick;
   if(SymbolInfoTick(Symbol(),last_tick))
     {
      bid= last_tick.bid;
      ask=last_tick.ask;
      preco=last_tick.last;

     }
   else
     {
      Print("Falhou obter o tick");
      return;
     }
   double spread=ask-bid;
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }

//----------------------------------------------------------------------------

//------------------------------------------------------------------------------
   if(timerOn)

     {// inicio Timer On

      if(NewBar.CheckNewBar(Symbol(),periodoRobo))
        {

         if(CancelaOrdem() && OrdersTotal()>0 && PositionsTotal()==0)
           {
            DeleteOrders(ORDER_TYPE_BUY_LIMIT);
            informacoes="Ordem Limitada Fechada por criterios";
            Print(informacoes);
           }

         if(BuySignal() && !Buy_opened()&&!OrdemAberta(ORDER_TYPE_BUY_LIMIT))
           {

            if(close[0]>(1+Var2/100)*maP1.Main(0))
              {
               if(_Stop>0)StopLoss=NormalizeDouble(bid-_Stop*ponto,digits);
               else StopLoss=0;

               if(_TakeProfit>0)TakeProfit=NormalizeDouble(ask+_TakeProfit*ponto,digits);
               else TakeProfit=0;
               mytrade.BuyLimit(Lot,NormalizeDouble(MathRound(maP1.Main(0)/ticksize)*ticksize,digits),Symbol(),StopLoss,TakeProfit,0,0,"Buy Limit");
               trade_ticket=mytrade.ResultOrder();
               compra1_ticket=trade_ticket;

              }
            if(close[0]<(1-Var2/100)*maP1.Main(0))
              {
               mytrade.Buy(Lot,Symbol(),0,StopLoss,TakeProfit,"Buy");
               trade_ticket=mytrade.ResultOrder();
               compra1_ticket=trade_ticket;

              }

           }
         //STOP na media MEDIA
         //*********************************************************************************************
         if(AtualizaStop())
           {
            preco_media_compra=maP1.Main(0);
            sellprice=MathRound(((1-Var6/100)*maP1.Main(0))/ticksize)*ticksize;
            sellprice=NormalizeDouble(sellprice,digits);
            oldprice=PriceLastStopOrder(ORDER_TYPE_SELL_STOP);
            if(oldprice==-1 || sellprice>oldprice) // No order or New price is better
              {
               DeleteOrders(ORDER_TYPE_SELL_STOP);
               mytrade.SellStop(Lot,sellprice,Symbol(),0,0,0,0,"SELL STOP");
               trade_ticket=mytrade.ResultOrder();
               venda1_ticket=trade_ticket;
               informacoes="Stop Movel Atualizado";
               Print(informacoes);

              }
           }
         //*********************************************************************************************

        }//Fim NewBar

     }// Fim Timer On

   else
     {
      if(OrdemAberta(ORDER_TYPE_BUY_LIMIT))
        {
         DeleteOrders(ORDER_TYPE_BUY_LIMIT);
         informacoes="Fechou Ordem Limitada fim do dia";
        }// fechou ordens pendentes no Day trade fora do horario
     }

   Comentarios();

  }
//+------------------------------------------------------------------+
//| Buy conditions                                                   |
//+------------------------------------------------------------------+
bool Buy_opened()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_BUY)
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
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_SELL)
         return(true);  //It is a Buy
     }
   return(false);
  }
//+------------------------------------------------------------------+
double DME(int index)
  {
   return maP4.Main(index)-maP5.Main(index);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   bool signal=DME(1)>Var1 && maP1.Main(1)<maP2.Main(1);
   return signal;
  }
//+------------------------------------------------------------------+

bool CancelaOrdem()
  {
   bool signal=DME(1)<Var1 || maP1.Main(1)>maP2.Main(1);
   signal=signal || open[0]<=maP3.Main(0);
   return signal;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AtualizaStop()
  {
   if(Buy_opened()&&preco_media_compra>0&&maP1.Main(1)>(1+Var5/100)*preco_media_compra) return true;
   else return false;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void Comentarios()
  {

   string s_coment=""+"\n"+"RESULTADO DIÁRIO: "+DoubleToString(lucro_total,2)+"\n";
   s_coment+="ENTRADAS NO DIA: "+IntegerToString(ENTRADAS_TOTAL)+"\n";
   s_coment+=informacoes;
   Comment(s_coment);

  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   bool b_get;
   b_get=CopyHigh(Symbol(),periodoRobo,0,5,high)<=0 || 
         CopyOpen(Symbol(),periodoRobo,0,5,open)<=0 || 
         CopyLow(Symbol(),periodoRobo,0,5,low)<=0 || 
         CopyClose(Symbol(),periodoRobo,0,5,close)<=0;
   return(b_get);


  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void CloseALL()
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
        {
         if(!mytrade.PositionClose(PositionGetTicket(i)))
           {
            Print(PositionGetTicket(i),"PositionClose() method failed. Return code=",mytrade.ResultRetcode(),
                  ". Code description: ",mytrade.ResultRetcodeDescription());
           }
         else
           {
            Print(PositionGetTicket(i),"PositionClose() method executed successfully. Return code=",mytrade.ResultRetcode(),
                  " (",mytrade.ResultRetcodeDescription(),")");
           }
        }
     }
  }
//------------------------------------------------------------------------

void ClosePosType(ENUM_POSITION_TYPE ptype)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype)
        {
         if(!mytrade.PositionClose(PositionGetTicket(i)))
           {
            Print(PositionGetTicket(i),"PositionClose() method failed. Return code=",mytrade.ResultRetcode(),
                  ". Code description: ",mytrade.ResultRetcodeDescription());
           }
         else
           {
            Print(PositionGetTicket(i),"PositionClose() method executed successfully. Return code=",mytrade.ResultRetcode(),
                  " (",mytrade.ResultRetcodeDescription(),")");
           }
        }
     }
  }
//------------------------------------------------------------------------
// Select total orders in history and get total pending orders
// (as shown within the COrderInfo class section). 
void DeleteALL()
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
     {
      ulong o_ticket=OrderGetTicket(j);
      if(o_ticket!=0)
        {
         myorder.Select(o_ticket);
         if(myorder.Magic()==Magic_Number && myorder.Symbol()==mysymbol.Name()) mytrade.OrderDelete(o_ticket);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAbertas(double distancia)
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
     {
      ulong o_ticket=OrderGetTicket(j);
      if(o_ticket!=0)
        {
         myorder.Select(o_ticket);
         if(myorder.Magic()==Magic_Number && myorder.Symbol()==mysymbol.Name() && MathAbs(myorder.PriceOpen()-ask)>distancia*ponto)
           {
            if(myorder.Type()==ORDER_TYPE_BUY_LIMIT || myorder.Type()==ORDER_TYPE_SELL_LIMIT)
               mytrade.OrderDelete(o_ticket);
           }
        }
     }
  }
//------------------------------------------------------------------------
//+------------------------------------------------------------------+
//| Highest High & Lowest Low                                        |
//+------------------------------------------------------------------+

double HighestHigh(string pSymbol,ENUM_TIMEFRAMES pPeriod,int pBars,int pStart=0)
  {
   double high[];
   ArraySetAsSeries(high,true);

   int copied= CopyHigh(pSymbol,pPeriod,pStart,pBars,high);
   if(copied == -1) return(copied);

   int maxIdx=ArrayMaximum(high);
   double highest=high[maxIdx];

   return(highest);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LowestLow(string pSymbol,ENUM_TIMEFRAMES pPeriod,int pBars,int pStart=0)
  {
   double low[];
   ArraySetAsSeries(low,true);

   int copied= CopyLow(pSymbol,pPeriod,pStart,pBars,low);
   if(copied == -1) return(copied);

   int minIdx=ArrayMinimum(low);
   double lowest=low[minIdx];

   return(lowest);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PriceLastStopOrder(const ENUM_ORDER_TYPE pending_order_type)
  {
   datetime last_time=0;
   double last_price=-1.0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==pending_order_type)
               if(myorder.TimeSetup()>last_time)
                 {
                  last_time=myorder.TimeSetup();
                  last_price=myorder.PriceOpen();
                 }
//---
   return(last_price);
  }
//+------------------------------------------------------------------+
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void DeleteOrders(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+
//| Ordens Abertas                                                    |
//+------------------------------------------------------------------+
bool OrdemAberta(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               return true;
   return false;
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
//+------------------------------------------------------------------+
double LucroOrdens()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   MqlDateTime stm_end,time_aux;
   TimeToStruct(tm_end,stm_end);
   time_aux=stm_end;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);
   HistorySelect(tm_start,tm_end);
   uint total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LucroPositions()
  {
   double profit=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
         profit+=myposition.Profit();
   return profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
