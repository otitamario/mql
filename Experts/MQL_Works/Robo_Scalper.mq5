//+------------------------------------------------------------------+
//|                                                     Junio_v3.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
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
#include <ChartObjects\ChartObjectsArrows.mqh>      


//Classes
CNewBar NewBar;
CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
CTimer Timer;
CiMA *mms;
CiRSI *rsi;
CiRSI *rsi2;
CiADX *adx;
CiBands *banda;
CiATR *atr;
CChartObjectArrowDown arrow_down;
CChartObjectArrowUp arrow_up;
// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong MaxOrdens=1000;//Numero Maximo de Entradas por Dia
input ulong Magic_Number=5062018;
input ulong deviation_points=100;//Deviation in Points
input double Lot=2;//Lote Entrada
sinput string Lucro="Lucro para fechamento";
input bool UsarLucro=true;
input double lucro=1000.0;
input double prejuizo=500.0;
sinput string shorario="############------Horario------#################";

input bool UseTimer=true;// Usar filtro de Horario
input int StartHour = 9;// Hora inicial
input int StartMinute=0;// Minuto inicial

sinput string hora_limit_ent="HORARIO LIMITE PARA ENTRADAS";
input int EndHour_Ent=17;//Hora limite para entradas
input int EndMinute_Ent=00;// Minuto limite para entradas

sinput string horafech="HORARIO PARA FECHAMENTO DE POSICOES E ORDENS";
input int EndHour=17;//Hora para fechamento daytrade
input int EndMinute=30;//Minuto fechamento daytrade
input bool Daytrade=true;// Fechar posicoes Daytrade fim do dia
sinput string strail="############------Trailing Stop------#################";
input bool   Use_TraillingStop=true;
input int TraillingStart=15;//Lucro minimo Inicio do trailing stop
input int TraillingDistance=15;// Distancia do STOP movel para o preço
input int TraillingStep=0;// Passo para atualizar STOP movel
input double valor_corret=0.16;// Valor Corretagem
sinput string sindic="############------Indicadores------#################";
input int period_mms=9;//Periodo mms
input int period_rsi2=2;//Periodo rsi 2
input int period_rsi=21;// Periodo rsi
input int period_adx=21;//Periodo adx
input int period_banda=21;//Periodo Bollinger
input double banda_deviation=2.0;//Deviation Bollinger
input int period_atr=2;//Periodo ATR

sinput string sparams="############------Parametros de Entrada------#################";
input double X5=5;//X5 Pontos
input double X98_6=98.6;//X 98.6 RSI2
input double X1_4=1.4;//X 1.4 RSI2
input double X55=55;//X55
input double X65=65;//X65 Por cento
input double X10=10;//X10 pontos Stop



                    //Variaveis 
string original_symbol;
double ask,bid;
double lucro_total,profit,saldo_inicial;
double lucro_liquido,lucro_liquido2;
bool tradeOn,timerOn,timerEnt;
double StopLoss,TakeProfit;
double preco,ponto,ticksize,digits,lotes_trade,stop_movel;
double price_compra,price_venda,entrada_compra,entrada_venda;
long posicao;
long curChartID,newChartID;
double high[],low[],open[],close[];
double price_open;
datetime time_inicio;
MqlDateTime inicio_struct;
double stop_compra,stop_venda;
ulong ENTRADAS_TOTAL;
ulong trade_ticket,compra1_ticket,venda1_ticket,stp_venda_ticket,stp_compra_ticket;

double LUCRO_DEALS,CORRETAGEM;

ulong nsubwindows,nchart_rsi,nchart_rsi2,nchart_adx,nchart_atr;
double buyprice,sellprice,oldprice;
string informacoes;
bool tradebarra;//1 trade por barra
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   original_symbol=Symbol();
   tradeOn=true;
   trade_ticket=0;
   tradebarra=false;
   ENTRADAS_TOTAL=0;
   LUCRO_DEALS=LucroOrdens();
   CORRETAGEM=Corretagem(1.5*valor_corret);
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
   curChartID=ChartID();

   mms=new CiMA;
   mms.Create(NULL,periodoRobo,period_mms,0,MODE_EMA,PRICE_CLOSE);
   mms.AddToChart(curChartID,0);
   nsubwindows=ChartGetInteger(curChartID,CHART_WINDOWS_TOTAL);
   nchart_adx=nsubwindows;
   nchart_rsi=nsubwindows+1;
   nchart_rsi2=nsubwindows+2;
   nchart_atr=nsubwindows+3;
   adx=new CiADX;
   adx.Create(NULL,periodoRobo,period_adx);
   adx.AddToChart(curChartID,nchart_adx);


   rsi=new CiRSI;
   rsi.Create(NULL,periodoRobo,period_rsi,PRICE_CLOSE);
   rsi.AddToChart(curChartID,nchart_rsi);

   rsi2=new CiRSI;
   rsi2.Create(NULL,periodoRobo,period_rsi2,PRICE_CLOSE);
   rsi2.AddToChart(curChartID,nchart_rsi2);

   atr=new CiATR;
   atr.Create(NULL,periodoRobo,period_atr);
   atr.AddToChart(curChartID,nchart_atr);

   banda=new CiBands;
   banda.Create(NULL,periodoRobo,period_banda,0,banda_deviation,PRICE_CLOSE);
   banda.AddToChart(curChartID,0);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

// parametros incorretos desnecessarios na otimizacao

   if(Lot<=0)
     {
      Print("Soma dos Lotes Maior que Lote Maximo");
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
   ret=profit-vol*1.5*valor_corret;
   ret=ret/TesterStatistics(STAT_BALANCE_DD);
   return(ret);



//return(criterion_Ptr.GetCriterion());

  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   DeletaIndicadores();
   delete(mms);
   delete(adx);
   delete(atr);
   delete(banda);
   delete(rsi);
   delete(rsi2);




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
      myposition.SelectByTicket(trans.position);
      

      if(order_ticket==trade_ticket && trans.deal_type!=DEAL_TYPE_BALANCE)ENTRADAS_TOTAL++;

      //Stop para posição comprada
      if(mydeal.Entry()==DEAL_ENTRY_IN && myposition.Comment()=="BUY STOP")
        {
         tradebarra=false;
         sellprice=NormalizeDouble(open[0]-X10*ponto,digits);
         oldprice=PriceLastStopOrder(ORDER_TYPE_SELL_STOP);
         if(oldprice==-1 || sellprice>oldprice) // No order or New price is better
           {
            DeleteOrders(ORDER_TYPE_SELL_STOP);
            mytrade.SellStop(Lot,sellprice,Symbol(),0,0,0,0,"STOP");
            stp_venda_ticket=mytrade.ResultOrder();

           }
        }
      //--------------------------------------------------
      if(order_ticket==stp_venda_ticket)
        {
         informacoes="Posicao Fechada por Ordem Sell Stop";
         Print(informacoes);
         if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) mytrade.PositionCloseBy(compra1_ticket,stp_venda_ticket);

        }

      //Stop para posição vendida
      if(mydeal.Entry()==DEAL_ENTRY_IN && myposition.Comment()=="SELL STOP")
        {
         tradebarra=false;
         buyprice=NormalizeDouble(open[0]+X10*ponto,digits);
         oldprice=PriceLastStopOrder(ORDER_TYPE_BUY_STOP);
         if(oldprice==-1 || buyprice<oldprice) // No order or New price is better
           {
            DeleteOrders(ORDER_TYPE_SELL_STOP);
            mytrade.BuyStop(Lot,buyprice,Symbol(),0,0,0,0,"STOP");
            stp_compra_ticket=mytrade.ResultOrder();

           }
        }
      //--------------------------------------------------
      if(order_ticket==stp_compra_ticket && trans.deal_type==DEAL_TYPE_BUY)
        {
         informacoes="Posicao Fechada por Ordem Buy Stop";
         Print(informacoes);
         if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) mytrade.PositionCloseBy(venda1_ticket,stp_compra_ticket);

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
   mms.Refresh();
   rsi.Refresh();
   rsi2.Refresh();
   adx.Refresh();
   banda.Refresh();
   atr.Refresh();

   if(GetIndValue())
     {
      Print("Erro em obter OPEN, CLOSE,HIGH,LOW");
      return;
     }

//---
//--------------------------------



   bool novodia;
   novodia=NewBar.CheckNewBar(Symbol(),PERIOD_D1);
   if(novodia)
     {
      ENTRADAS_TOTAL=0;
      tradeOn=true;
      Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");
     }

   lucro_total=LucroOrdens()+LucroPositions();
   lucro_liquido=lucro_total-Corretagem(1.5*valor_corret);
   if(UsarLucro && (lucro_liquido>=lucro || lucro_liquido<=-prejuizo))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
     }

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
   if(tradeOn && timerOn)
     {

      if(NewBar.CheckNewBar(original_symbol,periodoRobo))
        {
         if(PositionsTotal()>0)
           {
            CloseALL();
            informacoes="Posicao Fechada Nova Barra";
            Print(informacoes);
           }
         if(OrdersTotal()>0)DeleteALL();
         tradebarra=true;
        }

      if(timerEnt)
        {

         if(BuySignal() && !Buy_opened() && tradebarra)
           {
            if(PositionsTotal()>0)CloseALL();
            if(OrdersTotal()>0)
              {
               DeleteOrders(ORDER_TYPE_SELL_LIMIT);
               DeleteOrders(ORDER_TYPE_SELL_STOP_LIMIT);
               DeleteOrders(ORDER_TYPE_SELL_STOP);

              }
            arrow_up.Create(0,"Buy",0,TimeCurrent(),low[0]-2*atr.Main(0));
            OpenBuyStop();

           }

         if(SellSignal() && !Sell_opened() && tradebarra)
           {
            if(PositionsTotal()>0)CloseALL();
            if(OrdersTotal()>0)
              {
               DeleteOrders(ORDER_TYPE_BUY_LIMIT);
               DeleteOrders(ORDER_TYPE_BUY_STOP_LIMIT);
               DeleteOrders(ORDER_TYPE_BUY_STOP);
              }
            arrow_down.Create(0,"Sell",0,TimeCurrent(),high[0]+2*atr.Main(0));

            OpenSellStop();
           }
        }//Fim Timer Entradas 

      if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);

     }// Fim Timer On

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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   bool signal;
   bool s1=rsi.Main(0)>50.0;
   bool s2=adx.Plus(0)>adx.Minus(0);
   bool s3=open[0]-low[0]<=X5;
   bool s4=rsi2.Main(0)<X98_6;
   bool s5=open[0]<=banda.Upper(0)&&open[0]>=banda.Lower(0);
   bool s6=atr.Main(0)>=X55;
   double corpo=high[1]-low[1];
   bool s7=open[0]>=low[1]+(X65/100)*corpo;
   signal=s1 && s2 && s3 && s4 && s5 && s6 && s7 && close[0]<high[1]+X5*ponto;
   return signal;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   bool signal;
   bool s1=rsi.Main(0)<50.0;
   bool s2=adx.Plus(0)<adx.Minus(0);
   bool s3=high[0]-open[0]<=X5;
   bool s4=rsi2.Main(0)>X1_4;
   bool s5=open[0]<=banda.Upper(0)&&open[0]>=banda.Lower(0);
   bool s6=atr.Main(0)>=X55;
   double corpo=high[1]-low[1];
   bool s7=open[0]<=high[1]-(X65/100)*corpo;
   signal=s1 && s2 && s3 && s4 && s5 && s6 && s7 && close[0]>low[1]-X5*ponto;

   return signal;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

   bool s2=adx.Plus(0)>adx.Minus(0);
   bool s3=open[0]-low[0]<=X5;
   bool s4=rsi2.Main(0)<X98_6;
   bool s5=open[0]<=banda.Upper(0)&&open[0]>=banda.Lower(0);
   bool s6=atr.Main(0)>=X55;
   double corpo=high[1]-low[1];
   bool s7=open[0]>=low[1]+(X65/100)*corpo;

   bool ss2=adx.Plus(0)<adx.Minus(0);
   bool ss3=high[0]-open[0]<=X5;
   bool ss4=rsi2.Main(0)>X1_4;
   bool ss6=atr.Main(0)>=X55;
   bool ss7=open[0]<=high[1]-(X65/100)*corpo;


   string s_coment=""+"\n"+"RESULTADO DIÁRIO: "+DoubleToString(lucro_total,2)+"\n";
   s_coment+="LUCRO LIQUIDO: "+DoubleToString(lucro_liquido,2)+"\n";
   s_coment+="ENTRADAS TOTAL: "+IntegerToString(ENTRADAS_TOTAL)+"\n";
   if(tradebarra)s_coment+="Trade Barra "+"True"+"\n";
   else s_coment+="Trade Barra "+"False"+"\n";
   s_coment+="RSI "+DoubleToString(rsi.Main(0),2)+" ";
   if(rsi.Main(0)>50)s_coment+="BUY"+"\n";
   else if(rsi.Main(0)<50) s_coment+="SELL"+"\n";
   s_coment+="ADX+ "+DoubleToString(adx.Plus(0),2)+" "+"ADX- "+DoubleToString(adx.Minus(0),2);
   if(s2)s_coment+=" BUY"+"\n";
   else if(ss2) s_coment+=" SELL"+"\n";
   else s_coment+="\n";

   s_coment+="Open "+DoubleToString(open[0],2)+" "+"High "+DoubleToString(high[0],2)+" Low "+DoubleToString(low[0],2);
   if(s3)s_coment+=" BUY"+"\n";
   else if(ss3) s_coment+=" SELL"+"\n";
   else s_coment+="\n";
   if (s5) s_coment+="ABERTURA DENTRO DA BANDA "+"\n";
   else s_coment+="ABERTURA DENTRO DA BANDA"+"\n";
   s_coment+="RSI 2= "+DoubleToString(rsi2.Main(0),2)+"\n";
   s_coment+="ATR "+DoubleToString(atr.Main(0),2)+"\n";
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
//|                                                                  |
//+------------------------------------------------------------------+
// Trailing stop (points)
void TrailingStop(int pTrailPoints,int pMinProfit=0,int pStep=10)
  {
   double currentStop;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number && pTrailPoints>0)
        {

         double currentTakeProfit=myposition.TakeProfit();
         long posType=myposition.PositionType();

         double openPrice=myposition.PriceOpen();
         double point=mysymbol.Point();
         int digits=mysymbol.Digits();
         if(pStep<10) pStep=10;
         double step=pStep*point;

         double minProfit = pMinProfit * point;
         double trailStop = pTrailPoints * point;
         double trailStopPrice;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            currentStop=myposition.StopLoss();

            trailStopPrice = bid - trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=bid-openPrice;

            if((trailStopPrice>currentStop+step|| currentStop==0) && currentProfit>=minProfit)
              {
               if(OrdemAberta(ORDER_TYPE_SELL_STOP))DeleteOrders(ORDER_TYPE_SELL_STOP);
               mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
              }

           }
         else if(posType==POSITION_TYPE_SELL)
           {
            currentStop=myposition.StopLoss();

            trailStopPrice = ask + trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=openPrice-ask;

            if((trailStopPrice<currentStop-step || currentStop==0) && currentProfit>=minProfit)
              {
               if(OrdemAberta(ORDER_TYPE_BUY_STOP))DeleteOrders(ORDER_TYPE_BUY_STOP);
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
//-------------------------------------------------------------------------------------
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
//|                                                                  |
//+------------------------------------------------------------------+
void DeletaIndicadores()
  {
   string name;
//--- O número de janelas no gráfico (ao menos uma janela principal está sempre presente) 
   int windows=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
//--- Verifique todas as janelas 
   for(int w=windows-1;w>=0;w--)
     {
      //--- o número de indicadores nesta janela/sub-janela 
      int total=ChartIndicatorsTotal(0,w);
      //--- Passar por todos os indicadores na janela 
      for(int i=total-1;i>=0;i--)
        {
         //--- obtém o nome abreviado do indicador 
         name=ChartIndicatorName(0,w,i);
         ChartIndicatorDelete(0,w,name);
        }

     }
  }//+------------------------------------------------------------------+
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenBuyStop()
  {
   double oldprice=0.0;

   TakeProfit=NormalizeDouble(high[1]+MathRound(atr.Main(0)/ticksize)*ticksize,digits);
   double bprice=NormalizeDouble(high[1]+X5*ponto,digits);

   oldprice=PriceLastStopOrder(ORDER_TYPE_BUY_STOP);
   if(oldprice==-1 || bprice<oldprice) // No order or New price is better
     {
      DeleteOrders(ORDER_TYPE_BUY_STOP);
      //  double tprofit=NormalizeDouble(bprice+takeprofit*ponto,_Digits);
      if(bprice>ask)
        {
         mytrade.BuyStop(Lot,bprice,_Symbol,0,TakeProfit,0,0,"BUY STOP");
         trade_ticket=mytrade.ResultOrder();
         compra1_ticket=trade_ticket;

        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
void OpenSellStop()
  {

   TakeProfit=NormalizeDouble(low[1]-MathRound(atr.Main(0)/ticksize)*ticksize,digits);//POde ser meaior que o valor do preco de compra e aparecerá ERRO
   double bprice=NormalizeDouble(low[1]-X5*ponto,digits);
   double oldprice=0.0;
   oldprice=PriceLastStopOrder(ORDER_TYPE_SELL_STOP);
   if(oldprice==-1 || bprice>oldprice) // No order or New price is better
     {
      DeleteOrders(ORDER_TYPE_SELL_STOP);
      // double tprofit=NormalizeDouble(bprice-takeprofit*ponto,_Digits);
      if(bprice<bid)
        {
         mytrade.SellStop(Lot,bprice,_Symbol,0,TakeProfit,0,0,"SELL STOP");
         trade_ticket=mytrade.ResultOrder();
         venda1_ticket=trade_ticket;
        }

     }
  }
//+------------------------------------------------------------------+
