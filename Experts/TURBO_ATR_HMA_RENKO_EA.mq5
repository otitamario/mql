//+------------------------------------------------------------------+
//|                                                     Junio_v3.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+-----------------------------------+
//|  Declaration of enumerations      |
//+-----------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TREND //Tendencias
  {
   COMPRA,
   VENDA,
   NEUTRO
  };
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
CiMA *ma10;
CiMA *ma200;
CiFractals *fractals;
// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input string simbolo="WINM18";                        //Renko Symbol
input double RenkoSize=70;//RenkoSize
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong MaxOrdens=100;//Numero Maximo de Entradas por Dia
input ulong Magic_Number=80620183;
input ulong deviation_points=50;//Deviation in Points
input double Lot=2;//Lote Entrada
input double distLot1=0;//Distancia Entrada 1
input double Lot2=0;//Lote Entrada 2
input double distLot2=0;//Distancia Entrada 2
input double Lot3=0;//Lote Entrada 3
input double distLot3=0;//Distancia Entrada 3
input double LotMax=14;//Total Maximo de Lotes
sinput string Lucro="Lucro para fechamento";
input bool UsarLucro=true;
input double lucro=1000.0;
input double prejuizo=500.0;
input bool UsarRealizParc=true;//Usar Realização Parcial
input double DistanceRealizeParcial=70;
input double porc_parcial=0.5;//Porcentagem Lotes Realizacao Parcial

input bool UseTimer = true;
input int StartHour = 9;
input int StartMinute=0;

sinput string hora_limit_ent="HORARIO LIMITE PARA ENTRADAS";
input int EndHour_Ent=17;
input int EndMinute_Ent=00;

sinput string horafech="HORARIO PARA FECHAMENTO DE POSICOES E ORDENS";
input int EndHour=17;
input int EndMinute= 30;
input bool Daytrade=true;// Fechar posicoes Daytrade fim do dia
input double _Stop=150;//Stop Loss
input double _TakeProfit=2000; //Take Profit
input bool UseBreakEven=true;//Usar BreakEven
input int BreakEvenPoint1=120;//Pontos para BreakEven 1
input int ProfitPoint1=60;//Pontos de Lucro da Posicao 1
input int BreakEvenPoint2=250;//Pontos para BreakEven 2
input int ProfitPoint2=180;//Pontos de Lucro da Posicao 2
input bool   Use_TraillingStop=true;
input int TraillingStart=0;//Lucro minimo Inicio do trailing stop
input int TraillingDistance=100;// Distancia do STOP movel para o preço
input int TraillingStep=10;// Passo para atualizar STOP movel
input bool UseSTOPMEDIA=true;//Usar Stop na media movel
input double DistSTOPMedia=60;//Distancia para media do stop movel
input bool StopCandle=true;//Usar Stop Candle
input double DistSTOPCandle=60;//Distancia para Candle Anterior
input double valor_corret=0.35;// Valor Corretagem
input int HMA_Period=23;  // HMA period 
input uint   Length=10;           // Indicator period
input uint   ATRPeriod=5;         // Period of ATR
input double Kv=2.5;              // Volatility by ATR
input int    Shift=0;             // Horizontal shift of the indicator in bars
input double gatilho_stop=45;// Gatilho Ordem Stop
                             //****************************** Variaveis Globais*************************************
TREND TENDENCIA=NEUTRO;
string custom_symbol,original_symbol;
double ask,bid,spread;
double TakeProfit_v=0;
double StopLoss_v=0;
int BreakEvenPoint[2],ProfitPoint[2];
double lucro_total,profit,saldo_inicial;
double lucro_liquido,lucro_liquido2;
bool timerOn,tradeOn,timerEnt;
double StopLoss,TakeProfit;
double preco,ponto,ticksize,digits,lotes_trade,stop_movel;
double price_compra,price_venda,entrada_compra,entrada_venda;
long posicao;
long curChartID,newChartID;
int hma_handle;
double hma_buffer[];
int atr_handle;
double ATR_High[],ATR_Low[];

double high[],low[],open[],close[];

double price_open;
datetime time_inicio;
MqlDateTime inicio_struct;
double stop_compra,stop_venda;
double stop_ordem_buy,take_ordem_buy,stop_ordem_sell,take_ordem_sell,preco_compra,preco_venda;
ulong ENTRADAS_TOTAL;
ulong trade_ticket,compra1_ticket,compra2_ticket,compra3_ticket,venda1_ticket,venda2_ticket,venda3_ticket;
ulong saida_compra1,saida_compra2,saida_compra3,saida_venda1,saida_venda2,saida_venda3;
double vol_compra1,vol_compra2,vol_compra3,vol_venda1,vol_venda2,vol_venda3;
double LUCRO_DEALS,CORRETAGEM;
int OrdersPrev=0;
int PositionsPrev=0;
string exp_name="_"+StringSubstr(MQLInfoString(MQL_PROGRAM_NAME),14,20);
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   original_symbol=simbolo;
   custom_symbol=Symbol();

// if(MQLInfoInteger(MQL_TESTER)==0 && MQLInfoInteger(MQL_OPTIMIZATION)==0 && MQLInfoInteger(MQL_DEBUG)==0) MarketBookAdd(original_symbol);
   tradeOn=true;
   entrada_compra=EMPTY_VALUE;
   entrada_venda=EMPTY_VALUE;
   OrdersPrev=OrdersTotal();
   PositionsPrev=PositionsTotal();
   trade_ticket=0;
   ENTRADAS_TOTAL=0;
   LUCRO_DEALS=LucroOrdens();
   CORRETAGEM=Corretagem(valor_corret);
   mysymbol.Name(original_symbol);
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
   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);

   inicio_struct.hour=0;
   inicio_struct.min=0;
   inicio_struct.sec=0;
   time_inicio=StructToTime(inicio_struct);
   lucro_total=0.0;
   saldo_inicial=AccountInfoDouble(ACCOUNT_BALANCE);
   BreakEvenPoint[0]=BreakEvenPoint1;BreakEvenPoint[1]=BreakEvenPoint2;ProfitPoint[0]=ProfitPoint1;ProfitPoint[1]=ProfitPoint2;
   curChartID=ChartID();
   ma10=new CiMA;
   ma10.Create(NULL,periodoRobo,10,0,MODE_EMA,PRICE_CLOSE);
   ma10.AddToChart(ChartID(),0);
   ma200=new CiMA;
   ma200.Create(NULL,periodoRobo,200,0,MODE_EMA,PRICE_CLOSE);
   ma200.AddToChart(ChartID(),0);
   fractals=new CiFractals;
   fractals.Create(NULL,periodoRobo);

   hma_handle=iCustom(Symbol(),_Period,"colorhma",HMA_Period,0);
   ChartIndicatorAdd(ChartID(),0,hma_handle);
   atr_handle=iCustom(Symbol(),periodoRobo,"atrstops_v1",Length,ATRPeriod,Kv,Shift);

   ChartIndicatorAdd(ChartID(),0,atr_handle);

   ArraySetAsSeries(ATR_High,true);
   ArraySetAsSeries(ATR_Low,true);

   ArraySetAsSeries(hma_buffer,true);

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

// parametros incorretos desnecessarios na otimizacao

   if(Lot+Lot2+Lot3>LotMax)
     {
      Print("Soma dos Lotes Maior que Lote Maximo");
      return(INIT_PARAMETERS_INCORRECT);

     }

   if((distLot1>=distLot2 && distLot2>0) || (distLot2>=distLot3 && distLot3>0) || (distLot1>=distLot3 && distLot3>0))
     {
      Print("Distancias Erradas das Entradas Parciais");
      return(INIT_PARAMETERS_INCORRECT);

     }

   if(BreakEvenPoint1<=ProfitPoint1 || BreakEvenPoint2<=ProfitPoint2)
     {
      Print("BreakEven Incorreto");
      return(INIT_PARAMETERS_INCORRECT);

     }

//---
   return(INIT_SUCCEEDED);
  }
//---------------------------------------------------------------------
//  The handler of the event of completion of another test pass:
//---------------------------------------------------------------------
double OnTester()
  {

   double ret=0.0;
   double profit=0;
   HistorySelect(0,TimeCurrent());

   uint total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double vol=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_IN || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
           {
            if(mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY)profit+=mydeal.Profit();
            vol+=mydeal.Volume();
           }
     }
   ret=profit-vol*valor_corret;
   ret=ret/TesterStatistics(STAT_BALANCE_DD);
   return(ret);



//return(criterion_Ptr.GetCriterion());

  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   IndicatorRelease(hma_handle);

   delete(ma10);
   delete(ma200);
   delete(fractals);
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

   double currentStop,currentTake,preco,novostop;

//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;

//--- if transaction is result of addition of the transaction in history

   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      ulong order_ticket=trans.order;
      ulong pos_ticket=trans.position;
      myorder.SelectByIndex(order_ticket);
      myposition.SelectByTicket(pos_ticket);
      if(order_ticket==trade_ticket && trans.deal_type!=DEAL_TYPE_BALANCE)ENTRADAS_TOTAL++;
      if(pos_ticket==compra1_ticket && trans.deal_type!=DEAL_TYPE_BALANCE)price_compra=myposition.PriceOpen();
      if(pos_ticket==venda1_ticket && trans.deal_type!=DEAL_TYPE_BALANCE)price_venda=myposition.PriceOpen();


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
   ma10.Refresh();
   ma200.Refresh();
   fractals.Refresh();
//---

   if(GetIndValue())
     {
      Print("Erro em obter os dados dos buffers de indicadores na funcao GET");
      return;
     }
   if(GetRenkoRates())
     {
      Print("Erro em obter Renko Rates");
      return;
     }

//--------------------------------

   bool novodia;
//novodia=CheckNovoDia(Symbol(),PERIOD_M1);
   novodia=NewBar.CheckNewBar(original_symbol,PERIOD_D1);
   if(novodia)
     {
      ENTRADAS_TOTAL=0;
      OrdersPrev=0;
      PositionsPrev=0;

     }

   lucro_total=LucroOrdens()+LucroPositions();
   lucro_liquido=lucro_total-Corretagem(valor_corret);
   if(UsarLucro && (lucro_liquido>=lucro || lucro_liquido<=-prejuizo))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
     }

   timerOn = false;
   timerEnt=false;
   if(UseTimer==true)
     {
      timerOn=Timer.DailyTimer(StartHour,StartMinute,EndHour,EndMinute);
      timerEnt=Timer.DailyTimer(StartHour,StartMinute,EndHour_Ent,EndMinute_Ent);
     }
   else
     {
      timerOn = true;
      timerEnt=true;
     }
   if(timerOn==false)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
     }

   MqlTick last_tick;
   if(SymbolInfoTick(original_symbol,last_tick))
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
   spread=ask-bid;
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }

   if(close[0]<ATR_Low[0] && ATR_Low[0]<EMPTY_VALUE)TENDENCIA=VENDA;
   if(close[0]>ATR_High[0])TENDENCIA=COMPRA;

//----------------------------------------------------------------------------

//------------------------------------------------------------------------------
   if(tradeOn && timerOn)

     {// inicio Trade On

      if(timerEnt)
        {

         if(BuySignal() && !Buy_opened() && ENTRADAS_TOTAL<MaxOrdens)
           {
            if(PositionsTotal()>0)CloseALL();
            if(OrdersTotal()>0)
              {
               DeleteOrders(ORDER_TYPE_SELL_LIMIT);
               DeleteOrders(ORDER_TYPE_SELL_STOP_LIMIT);
               DeleteOrders(ORDER_TYPE_SELL_STOP);

              }
            ConjuntoOrdensStopLimit(POSITION_TYPE_BUY);
           }

         if(SellSignal() && !Sell_opened() && ENTRADAS_TOTAL<MaxOrdens)
           {
            if(PositionsTotal()>0)CloseALL();
            if(OrdersTotal()>0)
              {
               DeleteOrders(ORDER_TYPE_BUY_LIMIT);
               DeleteOrders(ORDER_TYPE_BUY_STOP_LIMIT);
               DeleteOrders(ORDER_TYPE_BUY_STOP);
              }
            ConjuntoOrdensStopLimit(POSITION_TYPE_SELL);
           }
        }//Fim Timer Entradas 

      if(NewBar.CheckNewBar(custom_symbol,periodoRobo))
        {

         if(StopCandle)
           {

            stop_movel=NormalizeDouble(DistSTOPCandle*ponto,digits);
            for(int i=PositionsTotal()-1;i>=0; i--)
              {
               if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number)
                 {
                  if(myposition.PositionType()==POSITION_TYPE_BUY)
                    {
                     double curSTP=myposition.StopLoss();
                     double curTake=myposition.TakeProfit();
                     double stp_compra=low[1]-stop_movel;
                     if(stp_compra>curSTP)mytrade.PositionModify(myposition.Ticket(),MathRound(stp_compra/ticksize)*ticksize,curTake);

                    }

                  if(myposition.PositionType()==POSITION_TYPE_SELL)
                    {
                     double curSTP=myposition.StopLoss();
                     double curTake=myposition.TakeProfit();
                     double stp_venda=high[1]+stop_movel;
                     if(stp_venda<curSTP)mytrade.PositionModify(myposition.Ticket(),MathRound(stp_venda/ticksize)*ticksize,curTake);
                    }
                 }//Fim if PositionSelect

              }//Fim for

           }      //Fim Stop Candle  

         if(UseSTOPMEDIA)
           {

            stop_movel=NormalizeDouble(DistSTOPMedia*ponto,digits);
            double stop_med=NormalizeDouble(MathRound(ma10.Main(1)/ticksize)*ticksize,digits);

            for(int i=PositionsTotal()-1;i>=0; i--)
              {
               if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number)
                 {
                  if(myposition.PositionType()==POSITION_TYPE_BUY && bid>ma10.Main(1))
                    {
                     double curSTP=myposition.StopLoss();
                     double curTake=myposition.TakeProfit();
                     double stp_compra=stop_med-stop_movel;
                     if(stp_compra>curSTP)mytrade.PositionModify(myposition.Ticket(),MathRound(stp_compra/ticksize)*ticksize,curTake);

                    }

                  if(myposition.PositionType()==POSITION_TYPE_SELL && ask<ma10.Main(1))
                    {
                     double curSTP=myposition.StopLoss();
                     double curTake=myposition.TakeProfit();
                     double stp_venda=stop_med+stop_movel;
                     if(stp_venda<curSTP)mytrade.PositionModify(myposition.Ticket(),MathRound(stp_venda/ticksize)*ticksize,curTake);
                    }
                 }//Fim if PositionSelect

              }//Fim for

           }  //Fim STOP MEDIA

        }//Fim NewBar

      if(OrdersTotal()>0)DeleteAbertas(2.0*RenkoSize);

      if(UsarRealizParc)Piramide();

      //----------------------------------------------------------
      //----------------------------------------------------------
      //Ajustar Posicao

      //Diminuir lote se prejuizo sem Hedge

      //---------------------------------------------------------------------     
      // Trailing stop

      if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);

      //----------------------------------------------------------------------
      if(UseBreakEven) BreakEvenPiram(original_symbol,UseBreakEven,BreakEvenPoint,ProfitPoint);

      OrdersPrev=OrdersTotal();
      PositionsPrev=PositionsTotal();

     }// Fim tradeOn

   else
     {
      if(Daytrade==true)
        {
         DeleteALL();
         CloseALL();
        }
     } // fechou ordens pendentes no Day trade fora do horario

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

bool BuySignal()
  {
   bool signal;

   signal=hma_buffer[1]==1.0 && hma_buffer[2]!=1.0;
   return signal;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   bool signal;

   signal=hma_buffer[1]==2.0 && hma_buffer[2]!=2.0;
   return signal;

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double VolumeBuyTotal()
  {
   double vol=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_BUY)
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
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_SELL)
         vol+=myposition.Volume();

   return vol;

  }
//+------------------------------------------------------------------+
bool CheckSellClose()
  {
   bool signal;

   return signal;
  }
//+------------------------------------------------------------------+
//| Buy Close conditions                                                  |
//+------------------------------------------------------------------+
bool CheckBuyClose()
  {
   bool signal;
   return signal;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void Comentarios()
  {

   string s_coment=""+"\n"+"RESULTADO DIÁRIO: "+DoubleToString(lucro_total,2)+"\n";
   s_coment+="LUCRO LIQUIDO: "+DoubleToString(lucro_liquido,2)+"\n";
   s_coment+="ENTRADAS TOTAL: "+IntegerToString(ENTRADAS_TOTAL)+"\n";
   Comment(s_coment);

  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(hma_handle,1,0,4,hma_buffer)<=0 || 
         CopyBuffer(atr_handle,0,0,5,ATR_High)<=0 || 
         CopyBuffer(atr_handle,1,0,5,ATR_Low)<=0;

   if(b_get)Print("Erro em obter os indicadores");
   return(b_get);

  }//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GetRenkoRates()
  {
   bool b_get;
   b_get=CopyHigh(custom_symbol,periodoRobo,0,5,high)<=0 || 
         CopyOpen(custom_symbol,periodoRobo,0,5,open)<=0 || 
         CopyLow(custom_symbol,periodoRobo,0,5,low)<=0 || 
         CopyClose(custom_symbol,periodoRobo,0,5,close)<=0;

   if(b_get)Print("Erro em obter Renko rates");
   return(b_get);

  }//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckNovoDia(string pSymbol,ENUM_TIMEFRAMES pTimeframe)
  {
   bool newBar;
   datetime Time[],LastTime;
   ArraySetAsSeries(Time,true);
   MqlDateTime hoje,ontem;
   LastTime=TimeCurrent();
   CopyTime(pSymbol,pTimeframe,0,2,Time);
   TimeToStruct(LastTime,hoje);
   TimeToStruct(Time[1],ontem);
   newBar=false;
   if(hoje.day_of_year!=ontem.day_of_year) newBar=true;

   return(newBar);
  }
// Trailing stop (points)
void TrailingStop(int pTrailPoints,int pMinProfit=0,int pStep=10)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number && pTrailPoints>0)
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

            if(trailStopPrice>currentStop+step && currentProfit>=minProfit)
              {
               mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);

              }

           }
         else if(posType==POSITION_TYPE_SELL)
           {
            trailStopPrice = ask + trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=openPrice-ask;

            if((trailStopPrice<currentStop-step || currentStop==0) && currentProfit>=minProfit)
              {
               mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
              }

           }
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PosicaoAberta()
  {
   if(myposition.SelectByMagic(Symbol(),Magic_Number)==true)
      return(myposition.PositionType()== POSITION_TYPE_BUY||myposition.PositionType()== POSITION_TYPE_SELL);
   else return(false);
  }
//------------------------------------------------------------------------
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
//|                                                                  |
//+------------------------------------------------------------------+
void RealizacaoParcial()
  {
   double currentProfit,currentStop,preco,novostop;
   double vol_init;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
        {
         currentStop=myposition.StopLoss();
         preco=myposition.PriceOpen();
         if(myposition.PositionType()==POSITION_TYPE_BUY)
           {
            if(myposition.Comment()=="BUY"+exp_name)vol_init=Lot;
            else if(myposition.Comment()=="Buy Limit 2"+exp_name)vol_init=Lot2;
            else if(myposition.Comment()=="Buy Limit 3"+exp_name)vol_init=Lot3;
            else vol_init=0;
            currentProfit= bid-preco;
            if(currentProfit>=DistanceRealizeParcial*_Point && myposition.Volume()>=vol_init && vol_init>mysymbol.LotsMin())
              {
               mytrade.PositionClosePartial(myposition.Ticket(),MathMax(1,MathFloor(porc_parcial*myposition.Volume())),deviation_points);
               Print("Venda Saída Parcial : ");

               novostop=NormalizeDouble(preco-(DistanceRealizeParcial-15)*_Point,digits);
               if(novostop>currentStop)mytrade.PositionModify(myposition.Ticket(),novostop,myposition.TakeProfit());
              }
           }

         if(myposition.PositionType()==POSITION_TYPE_SELL)
           {

            if(myposition.Comment()=="SELL"+exp_name)vol_init=Lot;
            else if(myposition.Comment()=="Sell Limit 2"+exp_name)vol_init=Lot2;
            else if(myposition.Comment()=="Sell Limit 3"+exp_name)vol_init=Lot3;

            else vol_init=0;
            currentProfit= preco-ask;

            if(currentProfit>=DistanceRealizeParcial*_Point && myposition.Volume()>=vol_init && vol_init>mysymbol.LotsMin())
              {
               mytrade.PositionClosePartial(myposition.Ticket(),MathMax(1,MathFloor(porc_parcial*myposition.Volume())),deviation_points);
               Print("Compra Saída Parcial : ");

               novostop=NormalizeDouble(preco+(DistanceRealizeParcial-15)*_Point,digits);
               if(novostop<currentStop)mytrade.PositionModify(myposition.Ticket(),novostop,myposition.TakeProfit());
              }
           }
        }//Fim myposition Select
     }//Fim for
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Piramide()
  {
   double currentProfit,currentStop,preco,novostop,currentTake;
   double vol_init,vol_piramide;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
        {
         currentStop=myposition.StopLoss();
         currentTake=myposition.TakeProfit();
         preco=myposition.PriceOpen();
         if(myposition.PositionType()==POSITION_TYPE_BUY)
           {
            if(myposition.Comment()=="BUY"+exp_name)vol_init=Lot;
            else if(myposition.Comment()=="Buy Limit 2"+exp_name)vol_init=Lot2;
            else if(myposition.Comment()=="Buy Limit 3"+exp_name)vol_init=Lot3;
            else vol_init=0;
            currentProfit= bid-preco;
            if(currentProfit>=DistanceRealizeParcial*_Point && myposition.Volume()>=vol_init && vol_init>mysymbol.LotsMin())
              {
               vol_piramide=myposition.Volume()-MathMax(mysymbol.LotsMin(),MathFloor(porc_parcial*myposition.Volume()));
               mytrade.PositionClose(myposition.Ticket());
               Print("Piramide Parcial : ");
               if(spread<15*ticksize)mytrade.Buy(vol_piramide,original_symbol,0,preco,currentTake,"PIRAMIDE BUY"+exp_name);
               else mytrade.BuyLimit(vol_piramide,bid,original_symbol,preco,currentTake,0,0,"PIRAMIDE BUY"+exp_name);
              }
           }

         if(myposition.PositionType()==POSITION_TYPE_SELL)
           {

            if(myposition.Comment()=="SELL"+exp_name)vol_init=Lot;
            else if(myposition.Comment()=="Sell Limit 2"+exp_name)vol_init=Lot2;
            else if(myposition.Comment()=="Sell Limit 3"+exp_name)vol_init=Lot3;

            else vol_init=0;
            currentProfit= preco-ask;

            if(currentProfit>=DistanceRealizeParcial*_Point && myposition.Volume()>=vol_init && vol_init>mysymbol.LotsMin())
              {
               vol_piramide=myposition.Volume()-MathMax(mysymbol.LotsMin(),MathFloor(porc_parcial*myposition.Volume()));
               mytrade.PositionClose(myposition.Ticket());
               Print("Piramide Parcial : ");

               if(spread<15*ticksize) mytrade.Sell(vol_piramide,original_symbol,0,preco,currentTake,"PIRAMIDE SELL"+exp_name);
               else mytrade.SellLimit(vol_piramide,ask,original_symbol,preco,currentTake,0,0,"PIRAMIDE SELL"+exp_name);

              }
           }
        }//Fim myposition Select
     }//Fim for
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ConjuntoOrdensStopLimit(ENUM_POSITION_TYPE side)
  {
   double buyprice,sellprice;
   double oldprice=0.0;
   if(side==POSITION_TYPE_BUY)
     {
      StopLoss=NormalizeDouble(bid-_Stop*ponto,digits);
      if(_TakeProfit>0)TakeProfit=NormalizeDouble(ask+_TakeProfit*ponto,digits);
      else TakeProfit=0;

      if(TENDENCIA==COMPRA) buyprice=MathMax(high[1]+gatilho_stop*ponto,ask+2*ticksize);
      else buyprice=MathMax(MathRound(ATR_Low[0]/ticksize)*ticksize+gatilho_stop*ponto,ask+2*ticksize);

      buyprice=NormalizeDouble(buyprice,digits);

      oldprice=PriceLastStopOrder(ORDER_TYPE_BUY_STOP);
      if(oldprice==-1 || buyprice<oldprice) // No order or New price is better
        {
         DeleteOrders(ORDER_TYPE_BUY_STOP);
         DeleteOrders(ORDER_TYPE_BUY_STOP_LIMIT);
         mytrade.BuyStop(Lot,buyprice,original_symbol,StopLoss,TakeProfit,0,0,"BUY"+exp_name);
         trade_ticket=mytrade.ResultOrder();
         compra1_ticket=trade_ticket;

         if(Lot2>0)
            SendOrderStopLimit(ORDER_TYPE_BUY_STOP_LIMIT,Lot2,NormalizeDouble(buyprice-distLot2*ponto,digits),buyprice,StopLoss<bid-(distLot2+40)*ponto?StopLoss:NormalizeDouble(bid-(distLot2+50)*ponto,digits),TakeProfit,"Buy Limit 2"+exp_name);
         compra2_ticket=mytrade.ResultOrder();
         if(Lot3>0)
            SendOrderStopLimit(ORDER_TYPE_BUY_STOP_LIMIT,Lot3,NormalizeDouble(buyprice-distLot3*ponto,digits),buyprice,StopLoss<bid-(distLot3+40)*ponto?StopLoss:NormalizeDouble(bid-(distLot3+50)*ponto,digits),TakeProfit,"Buy Limit 3"+exp_name);
         compra3_ticket=mytrade.ResultOrder();

        }

     }

   if(side==POSITION_TYPE_SELL)

     {
      StopLoss=NormalizeDouble(ask+_Stop*ponto,digits);
      if(_TakeProfit>0)TakeProfit=NormalizeDouble(bid-_TakeProfit*ponto,digits);
      else TakeProfit=0;

      if(TENDENCIA==VENDA)sellprice=MathMin(low[1]-gatilho_stop*ponto,bid-2*ticksize);
      else sellprice=MathMin(MathRound(ATR_High[0]/ticksize)*ticksize-gatilho_stop*ponto,bid-2*ticksize);
      sellprice=NormalizeDouble(sellprice,digits);
      oldprice=PriceLastStopOrder(ORDER_TYPE_SELL_STOP);
      if(oldprice==-1 || sellprice>oldprice) // No order or New price is better
        {
         DeleteOrders(ORDER_TYPE_SELL_STOP);
         DeleteOrders(ORDER_TYPE_SELL_STOP_LIMIT);
         mytrade.SellStop(Lot,sellprice,original_symbol,StopLoss,TakeProfit,0,0,"SELL"+exp_name);
         trade_ticket=mytrade.ResultOrder();
         venda1_ticket=trade_ticket;

         if(Lot2>0)
            SendOrderStopLimit(ORDER_TYPE_SELL_STOP_LIMIT,Lot2,NormalizeDouble(sellprice+distLot2*ponto,digits),sellprice,StopLoss>ask+(distLot2+40)*ponto?StopLoss:NormalizeDouble(ask+(distLot2+50)*ponto,digits),TakeProfit,"Sell Limit 2"+exp_name);
         venda2_ticket=mytrade.ResultOrder();
         if(Lot3>0)
            SendOrderStopLimit(ORDER_TYPE_SELL_STOP_LIMIT,Lot3,NormalizeDouble(sellprice+distLot3*ponto,digits),sellprice,StopLoss>ask+(distLot3+40)*ponto?StopLoss:NormalizeDouble(ask+(distLot3+50)*ponto,digits),TakeProfit,"Sell Limit 3"+exp_name);
         venda3_ticket=mytrade.ResultOrder();

        }

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendOrderStopLimit(ENUM_ORDER_TYPE ordertype,double vol,double pricelimit,double price,double stloss,double tkprofit,string comment)
  {
//--- preparar um pedido 
   MqlTradeRequest request={0};
   request.action=TRADE_ACTION_PENDING;         // definição de uma ordem pendente 
   request.magic=Magic_Number;                  // ORDER_MAGIC 
   request.symbol=original_symbol;                      // símbolo 
   request.volume=vol;                          // volume em 0.1 lotes 
   request.sl=stloss;                                // Stop Loss (Parar Perda) não é especificado 
   request.tp=tkprofit;                                // Take Profit (Tomar Lucro) não é especificado 
   request.type=ordertype;                // tipo de ordem 
   request.stoplimit=pricelimit;
   request.price=price;
   request.comment=comment;
   request.type_filling=mytrade.RequestTypeFilling();
   request.type_time=ORDER_TIME_DAY;
//--- enviar um pedido de negociação  
   MqlTradeResult result={0};
   OrderSend(request,result);
//--- escrever resposta do servido para log   
   Print(__FUNCTION__,":",result.comment);
   if(result.retcode==10016) Print(result.bid,result.ask,result.price);

  }
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

//Break Even

void BreakEven(string pSymbol,bool usarbreak,int &pBreakEven[],int &pLockProfit[])
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && usarbreak==true)
        {

         long posType=myposition.PositionType();
         long posTicket=myposition.Ticket();
         double currentSL = myposition.StopLoss();
         double openPrice = myposition.PriceOpen();
         double currentTP=myposition.TakeProfit();
         double breakEvenStop;
         double currentProfit;
         double ponto=SymbolInfoDouble(pSymbol,SYMBOL_POINT);
         double bid,ask;

         if(posType==POSITION_TYPE_BUY)
           {
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
//+------------------------------------------------------------------+ 
//Break Even

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
//+------------------------------------------------------------------+
double Corretagem(double custo)
  {
   double corretagem;
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
   double vol=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_IN || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            vol+=mydeal.Volume();
     }

   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
         vol+=myposition.Volume();
   corretagem=custo*vol;
   return corretagem;
  }
//+------------------------------------------------------------------+
