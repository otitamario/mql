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

#define INFOPANEL_SIZE 12 // Size of the array for info panel objects
#define EXPERT_NAME MQL5InfoString(MQL5_PROGRAM_NAME) // Name of the Expert Advisor

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
CiATR *atrgain;
CiATR *atrvol;
// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=25062018;
input double max_sllipage=15;//Desvio Máximo de Preço Entrada
input double Lot=1;//Lote Entrada
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
sinput string hora_pausa="HORARIO PAUSA - SEM OPERAR";
input bool UseTimer_Pausa=false;// Usar filtro Pausar o EA
input int StartHourPs = 9;// Hora inicial Pausa
input int StartMinutePs=0;// Minuto inicial Pausa
input int EndHourPs=17;//Hora Final Pausa
input int EndMinutePs=00;// Minuto Final Pausa

sinput string strail="############------Trailing Stop------#################";
input bool   Use_TraillingStop=true;
input int TraillingDistance=15;// Distancia do STOP movel para o preço
input double valor_corret=0.16;// Valor Corretagem
input bool UseBreakEven=true;//Usar BreakEven
input int BreakEvenPoint1=120;//Pontos para BreakEven 1
input int ProfitPoint1=60;//Pontos de Lucro da Posicao 1
input int BreakEvenPoint2=250;//Pontos para BreakEven 2
input int ProfitPoint2=180;//Pontos de Lucro da Posicao 2

sinput string sindic="############------Indicadores------#################";
input int period_mms=9;//Periodo mms
input int period_rsi2=2;//Periodo rsi 2
input int period_rsi=21;// Periodo rsi
input int period_adx=21;//Periodo adx
input int period_banda=21;//Periodo Bollinger
input double banda_deviation=2.0;//Deviation Bollinger
input int period_atr_gain=2;//Periodo ATR Gain
input int period_atr_vol=18;//Periodo ATR Volatilidade

sinput string sparams="############------Parametros de Entrada------#################";
input bool usar_x5=true;// Usar Oscilacao na abertura
input double X5=5;//Pontos Oscilacao da abertura
input double X98_6=98.6;//Sobrecompra RSI2
input double X1_4=1.4;//Sobrevenda RSI2
input double X55=55;//Limite Minimo ATR de Volatilidade
input double X65=65;//Porcentagem do corpo da Barra para entradas
input double X10=10;//Pontos distancia para Ordem Stop da abertuda
input double X15=15;//Pontos do rompimento para cancelar ordem
input int tempo_max=500;//Tempo em Segundos para trade na barra
input double vx_ATR=80;//Porcentagem da ATR para STOP GAIN
input bool stop_maxmin=false;//Stop na Max ou Min Candle Anterior
input bool StopCandle=true;//Usar Stop Movel no Candle Anterior
input double DistSTOPCandle=10;//Distancia para Candle Anterior

                               //Variaveis 
double deviation_points=100;//Deviation in Points
string original_symbol;
double ask,bid;
double lucro_total,profit,saldo_inicial;
double lucro_liquido,lucro_liquido2;
bool tradeOn,timerOn,timerEnt,timerPs;
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
ulong trade_ticket,compra1_ticket,venda1_ticket,stp_venda_ticket,stp_compra_ticket,tkp_venda_ticket,tkp_compra_ticket;

double LUCRO_DEALS,CORRETAGEM;

ulong nsubwindows,nchart_rsi,nchart_rsi2,nchart_adx,nchart_atr;
double buyprice,sellprice,oldprice;
string informacoes;
bool tradebarra;//1 trade por barra
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME)+"_"+Symbol();
string pos_prop_names[INFOPANEL_SIZE];

// Array of names of objects that display values of position properties
string pos_prop_values[INFOPANEL_SIZE];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   original_symbol=Symbol();
   tradeOn=true;
   timerPs=false;
   trade_ticket=0;
   tradebarra=false;
   ENTRADAS_TOTAL=0;
   informacoes=" ";
   LUCRO_DEALS=LucroOrdens();
   CORRETAGEM=Corretagem(1.5*valor_corret);
   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(Magic_Number);
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
   adx=new CiADX;
   adx.Create(NULL,periodoRobo,period_adx);
   adx.AddToChart(curChartID,nchart_adx);


   rsi=new CiRSI;
   rsi.Create(NULL,periodoRobo,period_rsi,PRICE_CLOSE);
   rsi.AddToChart(curChartID,nchart_rsi);

   TesterHideIndicators(true);

   rsi2=new CiRSI;
   rsi2.Create(NULL,periodoRobo,period_rsi2,PRICE_CLOSE);

   atrgain=new CiATR;
   atrgain.Create(NULL,periodoRobo,period_atr_gain);

   atrvol=new CiATR;
   atrvol.Create(NULL,periodoRobo,period_atr_vol);

   banda=new CiBands;
   banda.Create(NULL,periodoRobo,period_banda,0,banda_deviation,PRICE_CLOSE);
   banda.AddToChart(curChartID,0);

   TesterHideIndicators(false);

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
      Alert("Lote deve ser maior que 0");
      return(INIT_PARAMETERS_INCORRECT);

     }
   if(BreakEvenPoint1<=ProfitPoint1 || BreakEvenPoint2<=ProfitPoint2)
     {
      MessageBox("BreakEven Incorreto");
      Print("BreakEven Incorreto");
      return(INIT_PARAMETERS_INCORRECT);

     }

   for(int i=0;i<INFOPANEL_SIZE;i++)
     {

      pos_prop_values[i]="value "+IntegerToString(i);
      pos_prop_names[i]="name "+IntegerToString(i);
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
   delete(atrgain);
   delete(atrvol);
   delete(banda);
   delete(rsi);
   delete(rsi2);
   if(reason==REASON_REMOVE)
      //--- Delete all objects relating to the info panel from the chart
      DeleteInfoPanel();

   Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");
   HLineDelete(0,"Compra");
   HLineDelete(0,"Venda");

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
      myorder.Select(order_ticket);
      mydeal.SelectByIndex(trans.deal);
      myposition.SelectByTicket(trans.position);

      if(order_ticket==trade_ticket && trans.deal_type!=DEAL_TYPE_BALANCE)ENTRADAS_TOTAL++;

      if(StringSubstr(mydeal.Comment(),0,2)=="sl" || StringSubstr(mydeal.Comment(),0,2)=="tp")
        {
         DeleteALL();
         informacoes="Posicao Fechada por "+StringSubstr(mydeal.Comment(),0,2)=="sl"?"Stop Loss":"Take Profit";
         Print(informacoes);
        }

     }//End TRANSACTIONS DEAL ADD
   if(type==TRADE_TRANSACTION_HISTORY_ADD)
     {

      ulong order_ticket=trans.order;
      myorder.Select(order_ticket);
      myposition.SelectByTicket(trans.position);

      //Stop para posição comprada
      if(order_ticket==compra1_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         //Saida TakeProfit
         mytrade.SellLimit(Lot,trans.price+MathRound((vx_ATR/100)*atrgain.Main(0)/ticksize)*ticksize,NULL,0,0,0,0,"TAKE PROFIT"+exp_name);
         tkp_compra_ticket=mytrade.ResultOrder();

         if(!stop_maxmin)sellprice=NormalizeDouble(open[0]-X10*ponto,digits);
         else sellprice=NormalizeDouble(low[1]-X5*ponto,digits);
         oldprice=PriceLastStopOrder(ORDER_TYPE_SELL_STOP);
         if(oldprice==-1 || sellprice>oldprice && Buy_opened()) // No order or New price is better
           {
            DeleteOrders(ORDER_TYPE_SELL_STOP);
            mytrade.SellStop(Lot,sellprice,Symbol(),0,0,0,0,"STOP"+exp_name);
            stp_venda_ticket=mytrade.ResultOrder();

           }
        }
      //--------------------------------------------------
      if(order_ticket==stp_venda_ticket && trans.order_type==ORDER_TYPE_SELL_STOP && trans.order_state==ORDER_STATE_FILLED)
        {
         informacoes="Posicao Fechada por Ordem Sell Stop";
         Print(informacoes);
         if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) mytrade.PositionCloseBy(compra1_ticket,stp_venda_ticket);
         mytrade.OrderDelete(tkp_compra_ticket);

        }
      if(order_ticket==tkp_compra_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         informacoes="Take Profit atingido";
         Print(informacoes);
         if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) mytrade.PositionCloseBy(compra1_ticket,tkp_compra_ticket);
         mytrade.OrderDelete(stp_venda_ticket);
        }

      //Stop para posição vendida
      if(order_ticket==venda1_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         //Saida TakeProfit

         mytrade.BuyLimit(Lot,trans.price-MathRound((vx_ATR/100)*atrgain.Main(0)/ticksize)*ticksize,NULL,0,0,0,0,"TAKE PROFIT"+exp_name);
         tkp_venda_ticket=mytrade.ResultOrder();

         if(!stop_maxmin) buyprice=NormalizeDouble(open[0]+X10*ponto,digits);
         buyprice=NormalizeDouble(high[1]+X5*ponto,digits);
         oldprice=PriceLastStopOrder(ORDER_TYPE_BUY_STOP);
         if(oldprice==-1 || buyprice<oldprice && Sell_opened()) // No order or New price is better
           {
            DeleteOrders(ORDER_TYPE_SELL_STOP);
            mytrade.BuyStop(Lot,buyprice,Symbol(),0,0,0,0,"STOP"+exp_name);
            stp_compra_ticket=mytrade.ResultOrder();

           }
        }
      //--------------------------------------------------
      if(order_ticket==stp_compra_ticket && trans.order_type==ORDER_TYPE_BUY_STOP && trans.order_state==ORDER_STATE_FILLED)
        {
         informacoes="Posicao Fechada por Ordem Buy Stop";
         Print(informacoes);
         if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) mytrade.PositionCloseBy(venda1_ticket,stp_compra_ticket);
         mytrade.OrderDelete(tkp_venda_ticket);

        }

      if(order_ticket==tkp_venda_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         informacoes="Take Profit atingido";
         Print(informacoes);
         if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) mytrade.PositionCloseBy(venda1_ticket,tkp_venda_ticket);
         mytrade.OrderDelete(stp_compra_ticket);
        }

     }//End TRANSACTIONS HISTORY ADD

  }
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
   atrgain.Refresh();
   atrvol.Refresh();

   if(GetIndValue())
     {
      Print("Erro em obter OPEN, CLOSE,HIGH,LOW");
      return;
     }
   GetPositionProperties();

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
      if(UseTimer_Pausa)timerPs=Timer.DailyTimer(StartHourPs,StartMinutePs,EndHourPs,EndMinutePs);

     }
   else
     {
      timerOn = true;
      timerEnt=true;
      timerPs=false;
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
   datetime time[1];
   CopyTime(Symbol(),periodoRobo,0,1,time);

   if(timerPs)
     {
      informacoes="EA SEM OPERAR - Pausa no Horario";
      if(PosicaoAberta())CloseALL();
      if(OrdersTotal()>0)DeleteALL();
     }

   if(tradeOn && timerOn && (!timerPs))
     {

      if(TimeCurrent()>=time[0]+tempo_max)
        {
         tradebarra=false;
         if(!PosicaoAberta() && OrdersTotal()>0)DeleteALL();
        }

      if(TimeCurrent()>=time[0]+PeriodSeconds()-2)
        {
         if(PositionsTotal()>0 && (!StopCandle))
           {
            CloseALL();
            informacoes="Posicao Fechada Fim da Barra";
            Print(informacoes);
           }
         if(!PosicaoAberta() && OrdersTotal()>0)DeleteALL();

        }
      if(NewBar.CheckNewBar(original_symbol,periodoRobo))
        {
         HLineDelete(0,"Compra");
         HLineDelete(0,"Venda");
         HLineCreate(0,"Compra",0,NormalizeDouble(high[1]+X5*ponto,digits),clrLime,STYLE_DASH,2,false,false,true,0);
         HLineCreate(0,"Venda",0,NormalizeDouble(low[1]-X5*ponto,digits),clrRed,STYLE_DASH,2,false,false,true,0);

         if(PositionsTotal()>0 && (!StopCandle))
           {
            CloseALL();
            informacoes="Posicao Fechada Nova Barra";
            Print(informacoes);
           }
         if(!PosicaoAberta() && OrdersTotal()>0)DeleteALL();
         tradebarra=true;

         if(StopCandle)
           {

            for(int i=PositionsTotal()-1;i>=0; i--)
              {
               if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number)
                 {
                  if(myposition.PositionType()==POSITION_TYPE_BUY)
                    {
                     double curTake=myposition.TakeProfit();
                     double stp_compra=NormalizeDouble(low[1]-DistSTOPCandle*ponto,digits);
                     myorder.Select(stp_venda_ticket);
                     double curSTP=myorder.PriceOpen();

                     if(stp_compra>curSTP || curSTP==0)
                        mytrade.OrderModify(stp_venda_ticket,NormalizeDouble(MathRound(stp_compra/ticksize)*ticksize,digits),0,0,0,0,0);
                    }

                  if(myposition.PositionType()==POSITION_TYPE_SELL)
                    {
                     double curTake=myposition.TakeProfit();
                     double stp_venda=NormalizeDouble(high[1]+DistSTOPCandle*ponto,digits);
                     myorder.Select(stp_compra_ticket);
                     double curSTP=myorder.PriceOpen();

                     if(stp_venda<curSTP || curSTP==0)
                        mytrade.OrderModify(stp_compra_ticket,NormalizeDouble(MathRound(stp_venda/ticksize)*ticksize,digits),0,0,0,0,0);

                    }
                 }//Fim if PositionSelect

              }//Fim for

           }      //Fim Stop Candle  

        }

      if(timerEnt)
        {
         if(!PosicaoAberta())
           {
            if(OrdemAberta(ORDER_TYPE_SELL_LIMIT) && bid<NormalizeDouble(low[1]-(X5+max_sllipage)*ponto,digits))
              {
               DeleteOrders(ORDER_TYPE_SELL_LIMIT);
              }
            if(OrdemAberta(ORDER_TYPE_BUY_LIMIT) && bid<NormalizeDouble(low[1]-(X5+max_sllipage)*ponto,digits))
              {
               DeleteOrders(ORDER_TYPE_BUY_LIMIT);
              }
           }

         CancelaOrdemEntrada();
         AtualizaTakeATR();
         bool ask_aceitavel=ask>=NormalizeDouble(high[1]+X5*ponto,digits) && ask<=NormalizeDouble(high[1]+(X5+max_sllipage)*ponto,digits);
         if(BuySignal() && !Buy_opened() && tradebarra && ask_aceitavel && TimeCurrent()<=time[0]+tempo_max)
           {
            if(PositionsTotal()>0)CloseALL();
            if(OrdersTotal()>0)DeleteALL();
            Print("ENTROU SINAL");
            //OpenBuyStop();
            mytrade.BuyLimit(Lot,NormalizeDouble(high[1]+(X5+max_sllipage)*ponto,digits),original_symbol,0,0,0,0,"BUY"+exp_name);
            trade_ticket=mytrade.ResultOrder();
            compra1_ticket=trade_ticket;
            tradebarra=false;

           }
         bool bid_aceitavel=bid<=NormalizeDouble(low[1]-X5*ponto,digits) && bid>=NormalizeDouble(low[1]-(X5+max_sllipage)*ponto,digits);

         if(SellSignal() && !Sell_opened() && tradebarra && bid_aceitavel && TimeCurrent()<=time[0]+tempo_max)
           {
            if(PositionsTotal()>0)CloseALL();
            if(OrdersTotal()>0)DeleteALL();

            //            OpenSellStop();
            mytrade.SellLimit(Lot,NormalizeDouble(low[1]-(X5+max_sllipage)*ponto,digits),original_symbol,0,0,0,0,"SELL"+exp_name);
            trade_ticket=mytrade.ResultOrder();
            venda1_ticket=trade_ticket;
            tradebarra=false;

           }
        }//Fim Timer Entradas 

      if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingDistance,0);

     }// Fim Timer On

//Comentarios();

  }
//+------------------------------------------------------------------+
//| Buy conditions                                                   |
//+------------------------------------------------------------------+
bool Buy_opened()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && mysymbol.Name()==Symbol() && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_BUY)
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
      if(myposition.SelectByIndex(i) && mysymbol.Name()==Symbol() && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_SELL)
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
   bool s3=usar_x5?low[0]>=open[0]-X5*ponto:true;
   bool s4=rsi2.Main(0)<X98_6;
   bool s5=open[0]<=banda.Upper(0)&&open[0]>=banda.Lower(0);
   bool s6=atrvol.Main(0)>=X55*ponto;
   double corpo=high[1]-low[1];
   bool s7=open[0]>=high[1]-(X65/100)*corpo*ponto;
   bool s8=low[0]>=low[1];
   signal=s1 && s2 && s3 && s4 && s5 && s6 && s7 && s8;
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
   bool s3=usar_x5?high[0]<=open[0]+X5*ponto:true;
   bool s4=rsi2.Main(0)>X1_4;
   bool s5=open[0]<=banda.Upper(0)&&open[0]>=banda.Lower(0);
   bool s6=atrvol.Main(0)>=X55*ponto;
   double corpo=high[1]-low[1];
   bool s7=open[0]<=low[1]+(X65/100)*corpo*ponto;
   bool s8=high[0]<=high[1];
   signal=s1 && s2 && s3 && s4 && s5 && s6 && s7 && s8;

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
   bool s3=usar_x5?open[0]-low[0]<=X5:true;
   bool s4=rsi2.Main(0)<X98_6;
   bool s5=open[0]<=banda.Upper(0)&&open[0]>=banda.Lower(0);
   bool s6=atrvol.Main(0)>=X55;
   double corpo=high[1]-low[1];
   bool s7=open[0]>=low[1]+(X65/100)*corpo;

   bool ss2=adx.Plus(0)<adx.Minus(0);
   bool ss3=usar_x5?high[0]-open[0]<=X5:true;
   bool ss4=rsi2.Main(0)>X1_4;
   bool ss6=atrvol.Main(0)>=X55;
   bool ss7=open[0]<=high[1]-(X65/100)*corpo;


   string s_coment=""+"\n"+"RESULTADO DIÁRIO: "+DoubleToString(lucro_total,2)+"\n";
   s_coment+="LUCRO LIQUIDO: "+DoubleToString(lucro_liquido,2)+"\n";
   s_coment+="ENTRADAS TOTAL: "+IntegerToString(ENTRADAS_TOTAL)+"\n";
   if(tradebarra)s_coment+="Trade Barra "+"True"+"\n";
   else s_coment+="Trade Barra "+"False"+"\n";
   s_coment+="RSI "+DoubleToString(rsi.Main(0),_Digits+2)+" ";
   if(rsi.Main(0)>50)s_coment+="BUY"+"\n";
   else if(rsi.Main(0)<50) s_coment+="SELL"+"\n";
   s_coment+="ADX+ "+DoubleToString(adx.Plus(0),_Digits+2)+" "+"ADX- "+DoubleToString(adx.Minus(0),_Digits+2);
   if(s2)s_coment+=" BUY"+"\n";
   else if(ss2) s_coment+=" SELL"+"\n";
   else s_coment+="\n";

   s_coment+="Open "+DoubleToString(open[0],_Digits+2)+" "+"High "+DoubleToString(high[0],_Digits)+" Low "+DoubleToString(low[0],_Digits);
   if(s3)s_coment+=" BUY"+"\n";
   else if(ss3) s_coment+=" SELL"+"\n";
   else s_coment+="\n";
   if(s5) s_coment+="ABERTURA DENTRO DA BANDA "+"\n";
   else s_coment+="ABERTURA DENTRO DA BANDA"+"\n";
   s_coment+="RSI 2= "+DoubleToString(rsi2.Main(0),_Digits+2)+"\n";
   s_coment+="ATR VOL "+DoubleToString(atrvol.Main(0),_Digits+2)+"\n";
   s_coment+="ATR GAIN "+DoubleToString(atrgain.Main(0),_Digits+2)+"\n";

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

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number && pTrailPoints>0)
        {

         double currentTakeProfit=myposition.TakeProfit();
         long posType=myposition.PositionType();
         double currentStop;
         double openPrice=myposition.PriceOpen();
         double point=mysymbol.Point();
         int digits=mysymbol.Digits();
         if(pStep<10) pStep=10;
         double step=pStep*point;

         double minProfit = pMinProfit * point;
         double trailStop = pTrailPoints * point;
         currentTakeProfit=NormalizeDouble(currentTakeProfit,digits);
         double trailStopPrice;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            myorder.Select(stp_venda_ticket);
            currentStop=myorder.PriceOpen();
            trailStopPrice = bid - trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=bid-openPrice;

            if(trailStopPrice>currentStop+step && currentProfit>=minProfit)
              {
               // mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
               mytrade.OrderModify(stp_venda_ticket,trailStopPrice,0,0,0,0,0);
              }

           }
         else if(posType==POSITION_TYPE_SELL)
           {
            myorder.Select(stp_compra_ticket);
            currentStop=myorder.PriceOpen();
            trailStopPrice = ask + trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=openPrice-ask;

            if((trailStopPrice<currentStop-step || currentStop==0) && currentProfit>=minProfit)
              {
               //mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
               mytrade.OrderModify(stp_compra_ticket,trailStopPrice,0,0,0,0,0);

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
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
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
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name() && myposition.PositionType()==ptype)
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

// TakeProfit=NormalizeDouble(high[1]+MathRound((vx_ATR/100)*atrgain.Main(0)/ticksize)*ticksize,digits);
   double bprice=NormalizeDouble(high[1]+X5*ponto,digits);

   oldprice=PriceLastStopOrder(ORDER_TYPE_BUY_STOP);
   if(oldprice==-1 || bprice<oldprice) // No order or New price is better
     {
      DeleteOrders(ORDER_TYPE_BUY_STOP);
      //  double tprofit=NormalizeDouble(bprice+takeprofit*ponto,_Digits);
      if(bprice>ask)
        {
         mytrade.BuyStop(Lot,bprice,_Symbol,0,0,0,0,"BUY STOP"+exp_name);
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

// TakeProfit=NormalizeDouble(low[1]-MathRound((vx_ATR/100)*atrgain.Main(0)/ticksize)*ticksize,digits);//POde ser meaior que o valor do preco de compra e aparecerá ERRO
   double bprice=NormalizeDouble(low[1]-X5*ponto,digits);
   double oldprice=0.0;
   oldprice=PriceLastStopOrder(ORDER_TYPE_SELL_STOP);
   if(oldprice==-1 || bprice>oldprice) // No order or New price is better
     {
      DeleteOrders(ORDER_TYPE_SELL_STOP);
      // double tprofit=NormalizeDouble(bprice-takeprofit*ponto,_Digits);
      if(bprice<bid)
        {
         mytrade.SellStop(Lot,bprice,_Symbol,0,0,0,0,"SELL STOP"+exp_name);
         trade_ticket=mytrade.ResultOrder();
         venda1_ticket=trade_ticket;
        }

     }
  }
//+------------------------------------------------------------------+

void CancelaOrdemEntrada()
  {
   if(!PosicaoAberta())
     {

      bool b_signal,s_signal;
      double corpo=high[1]-low[1];

      bool b1=rsi.Main(0)<50.0;
      bool b2=adx.Plus(0)<adx.Minus(0);
      bool b3=!(usar_x5?low[0]>=open[0]-X5*ponto:true);
      bool b4=rsi2.Main(0)>X98_6*ponto;
      bool b5=close[0]>banda.Upper(0)||close[0]<banda.Lower(0);
      bool b6=atrvol.Main(0)<X55*ponto;
      bool b7=ask<low[1] || close[0]>high[0]+X15*ponto;
      bool b8=low[0]<low[1];
      b_signal=b1 || b2 || b3 || b4 || b5 || b6 || b7 || b8;
      bool s1=rsi.Main(0)>50.0;
      bool s2=adx.Plus(0)>adx.Minus(0);
      bool s3= !(usar_x5?high[0]<=open[0]+X5*ponto:true);

      bool s4=rsi2.Main(0)<X1_4*ponto;
      bool s5=close[0]>banda.Upper(0)||close[0]<banda.Lower(0);
      bool s6=atrvol.Main(0)<X55*ponto;
      bool s7=bid>high[1] || close[0]<low[0]-X15*ponto;
      bool s8=high[0]>high[1];
      s_signal=s1 || s2 || s3 || s4 || s5 || s6 || s7 || s8;

      if(OrdemAberta(ORDER_TYPE_BUY_LIMIT) && b_signal)
        {
         DeleteOrders(ORDER_TYPE_BUY_LIMIT);
         tradebarra=false;
         informacoes="Cancela Ordem BUY LIMIT -- Reversao ode Sinais ou Rompimento Minima Anterior";
         Print(informacoes);
        }
      if(OrdemAberta(ORDER_TYPE_SELL_LIMIT) && s_signal)
        {

         DeleteOrders(ORDER_TYPE_SELL_LIMIT);
         tradebarra=false;
         informacoes="Cancela Ordem SELL LIMIT -- Reversao de Sinais ou Rompimento Maxima Anterior";
         Print(informacoes);

        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AtualizaTakeATR()
  {
   double novo_tkprofit;
   if(Buy_opened())
     {
      myorder.Select(tkp_compra_ticket);
      novo_tkprofit=myposition.PriceOpen()+MathRound((vx_ATR/100)*atrgain.Main(0)/ticksize)*ticksize;
      if(novo_tkprofit>myorder.PriceOpen())
        {
         mytrade.OrderModify(tkp_compra_ticket,novo_tkprofit,0,0,0,0,0);
         informacoes="Take Profit atualizado ATR";
         Print(informacoes);
        }

     }
   if(Sell_opened())
     {
      myorder.Select(tkp_venda_ticket);
      novo_tkprofit=myposition.PriceOpen()-MathRound((vx_ATR/100)*atrgain.Main(0)/ticksize)*ticksize;
      if(novo_tkprofit<myorder.PriceOpen())
        {
         mytrade.OrderModify(tkp_venda_ticket,novo_tkprofit,0,0,0,0,0);
         informacoes="Take Profit atualizado ATR";
         Print(informacoes);
        }

     }

  }
//+------------------------------------------------------------------+
//#######################         PAINEL        #######################################
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CREATING THE EDIT OBJECT                                         |
//+------------------------------------------------------------------+
void CreateEdit(long             chart_id,         // chart id
                int              sub_window,       // (sub)window number
                string           name,             // object name
                string           text,             // displayed text
                ENUM_BASE_CORNER corner,           // chart corner
                string           font_name,        // font
                int              font_size,        // font size
                color            font_color,       // font color
                int              x_size,           // width
                int              y_size,           // height
                int              x_distance,       // X-coordinate
                int              y_distance,       // Y-coordinate
                long             z_order,          // Z-order
                color            background_color, // background color
                bool             read_only)        // Read Only flag
  {
// If the object has been created successfully...
   if(ObjectCreate(chart_id,name,OBJ_EDIT,sub_window,0,0))
     {
      // ...set its properties
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);                 // displayed text
      ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);            // set the chart corner
      ObjectSetString(chart_id,name,OBJPROP_FONT,font_name);            // set the font
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,font_size);       // set the font size
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,font_color);         // font color
      ObjectSetInteger(chart_id,name,OBJPROP_BGCOLOR,background_color); // background color
      ObjectSetInteger(chart_id,name,OBJPROP_XSIZE,x_size);             // width
      ObjectSetInteger(chart_id,name,OBJPROP_YSIZE,y_size);             // height
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,x_distance);     // set the X-coordinate
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,y_distance);     // set the Y-coordinate
      ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,false);         // cannot select the object if FALSE
      ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,z_order);           // Z-order of the object
      ObjectSetInteger(chart_id,name,OBJPROP_READONLY,read_only);       // Read Only
      ObjectSetInteger(chart_id,name,OBJPROP_ALIGN,ALIGN_LEFT);         // align left
      ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n");              // no tooltip if "\n"
     }
  }
//+------------------------------------------------------------------+
//| CREATING THE LABEL OBJECT                                        |
//+------------------------------------------------------------------+
void CreateLabel(long               chart_id,   // chart id
                 int                sub_window, // (sub)window number
                 string             name,       // object name
                 string             text,       // displayed text
                 ENUM_ANCHOR_POINT  anchor,     // anchor point
                 ENUM_BASE_CORNER   corner,     // chart corner
                 string             font_name,  // font
                 int                font_size,  // font size
                 color              font_color, // font color
                 int                x_distance, // X-coordinate
                 int                y_distance, // Y-coordinate
                 long               z_order)    // Z-order
  {
// If the object has been created successfully...
   if(ObjectCreate(chart_id,name,OBJ_LABEL,sub_window,0,0))
     {
      // ...set its properties
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);              // displayed text
      ObjectSetString(chart_id,name,OBJPROP_FONT,font_name);         // set the font
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,font_color);      // set the font color
      ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,anchor);         // set the anchor point
      ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);         // set the chart corner
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,font_size);    // set the font size
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,x_distance);  // set the X-coordinate
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,y_distance);  // set the Y-coordinate
      ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,false);      // cannot select the object if FALSE
      ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,z_order);        // Z-order of the object
      ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n");           // no tooltip if "\n"
     }
  }
//+------------------------------------------------------------------+
//| DELETING THE OBJECT BY NAME                                      |
//+------------------------------------------------------------------+
void DeleteObjectByName(string name)
  {
   int  sub_window=0;      // Returns the number of the subwindow where the object is located
   bool res       =false;  // Result following an attempt to delete the object
//--- Find the object by name
   sub_window=ObjectFind(ChartID(),name);
//---
   if(sub_window>=0) // If it has been found,..
     {
      res=ObjectDelete(ChartID(),name); // ...delete it
      //---
      // If an error occurred when deleting the object, print the relevant message
      if(!res)
         Print("Error deleting the object: ("+IntegerToString(GetLastError())+") ");
     }
  }
//+------------------------------------------------------------------+
//| GETTING POSITION PROPERTIES                                      |
//+------------------------------------------------------------------+
void GetPositionProperties()
  {
   SetInfoPanel(); // Set/update the info panel
  }
//+------------------------------------------------------------------+
//| SETTING THE INFO PANEL                                           |
//|------------------------------------------------------------------+
void SetInfoPanel()
  {
   int               y_bg=18;             // Y-coordinate for the background and header
   int               y_property=32;       // Y-coordinate for the list of properties and their values
   int               line_height=12;      // Line height
//---
   int               font_size=8;         // Font size
   string            font_name="Calibri"; // Font
   color             font_color=clrBlack; // Font color
//---
   ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER; // Anchor point in the top left corner
   ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER; // Origin of coordinates in the top left corner of the chart
//--- X-coordinates
   int               x_first_column=20;  // First column (names of properties)
   int               x_second_column=85;  // Second column (values of properties)
//--- Array of Y-coordinates for the names of position properties and their values
   int               y_prop_array[INFOPANEL_SIZE]={0};
//--- Fill the array with coordinates for each line on the info panel
   for(int i=0; i<INFOPANEL_SIZE; i++)
     {
      if(i==0) y_prop_array[i]=y_property;
      else     y_prop_array[i]=y_property+line_height*i;
     }
//--- Background of the info panel
   CreateEdit(0,0,"InfoPanelBackground","",corner,font_name,8,clrBlack,240,220,10,y_bg,0,clrLemonChiffon,true);
//--- Header of the info panel
   CreateEdit(0,0,"InfoPanelHeader",MQLInfoString(MQL_PROGRAM_NAME),corner,font_name,8,clrWhite,240,14,10,y_bg,1,clrFireBrick,true);
//--- List of the names of position properties and their values
//    Property name
   CreateLabel(0,0,pos_prop_names[0]," Resultado Diario :",anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[0],2);
//    Property value
   CreateLabel(0,0,pos_prop_values[0],GetPropertyValue(0),anchor,corner,font_name,font_size,font_color,x_second_column+30,y_prop_array[0],2);
//---
   CreateLabel(0,0,pos_prop_names[1]," Resultado Liquido :",anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[1],2);
//    Property value
   CreateLabel(0,0,pos_prop_values[1],GetPropertyValue(1),anchor,corner,font_name,font_size,font_color,x_second_column+30,y_prop_array[1],2);
//---

   CreateLabel(0,0,pos_prop_names[2]," Entradas :",anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[2],2);
   CreateLabel(0,0,pos_prop_values[2],GetPropertyValue(2),anchor,corner,font_name,font_size,font_color,x_second_column,y_prop_array[2],2);

   CreateLabel(0,0,pos_prop_values[3],GetPropertyValue(3),anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[3],2);
   CreateLabel(0,0,pos_prop_values[4],GetPropertyValue(4),anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[4],2);
   CreateLabel(0,0,pos_prop_values[5],GetPropertyValue(5),anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[5],2);
   CreateLabel(0,0,pos_prop_values[6],GetPropertyValue(6),anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[6],2);
   CreateLabel(0,0,pos_prop_values[7],GetPropertyValue(7),anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[7],2);
   CreateLabel(0,0,pos_prop_values[8],GetPropertyValue(8),anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[8],2);
   CreateLabel(0,0,pos_prop_values[9],GetPropertyValue(9),anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[9],2);
   CreateLabel(0,0,pos_prop_values[10],GetPropertyValue(10),anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[10],2);
   CreateLabel(0,0,pos_prop_values[11],GetPropertyValue(11),anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[11],2);

   ChartRedraw(); // Redraw the chart
  }
//+------------------------------------------------------------------+
//| DELETING THE INFO PANEL                                          |
//+------------------------------------------------------------------+
void DeleteInfoPanel()
  {
   DeleteObjectByName("InfoPanelBackground");   // Delete the panel background
   DeleteObjectByName("InfoPanelHeader");       // Delete the panel header
//--- Delete position properties and their values
   for(int i=0; i<INFOPANEL_SIZE; i++)
     {
      DeleteObjectByName(pos_prop_names[i]);    // Delete the property
      DeleteObjectByName(pos_prop_values[i]);   // Delete the value
     }
//---
   ChartRedraw(); // Redraw the chart
  }
//+------------------------------------------------------------------+
//| RETURNING THE STRING WITH POSITION PROPERTY VALUE                |
//+------------------------------------------------------------------+
string GetPropertyValue(int number)
  {
//--- Sign indicating the lack of an open position or a certain property
//    E.g. the lack of a comment, Stop Loss or Take Profit
   string empty="-";

   bool s2=adx.Plus(0)>adx.Minus(0);
   bool s3=usar_x5?open[0]-low[0]<=X5:true;
   bool s4=rsi2.Main(0)<X98_6;
   bool s5=open[0]<=banda.Upper(0)&&open[0]>=banda.Lower(0);
   bool s6=atrvol.Main(0)>=X55;
   double corpo=high[1]-low[1];
   bool s7=open[0]>=low[1]+(X65/100)*corpo;

   bool ss2=adx.Plus(0)<adx.Minus(0);
   bool ss3=usar_x5?high[0]-open[0]<=X5:true;
   bool ss4=rsi2.Main(0)>X1_4;
   bool ss6=atrvol.Main(0)>=X55;
   bool ss7=open[0]<=high[1]-(X65/100)*corpo;

   string str3,str4,str5,str6,str7,str8,str9,str10,str11;
   if(tradebarra)str3="Trade Barra "+"True";
   else str3="Trade Barra "+"False";
   str4="RSI "+DoubleToString(rsi.Main(0),1)+" ";
   if(rsi.Main(0)>50)str4+="BUY";
   else if(rsi.Main(0)<50) str4+="SELL";
   str5="ADX+ "+DoubleToString(adx.Plus(0),_Digits)+" "+"ADX- "+DoubleToString(adx.Minus(0),_Digits);
   if(s2)str5+=" BUY";
   else if(ss2) str5+=" SELL";

   str6="Open "+DoubleToString(open[0],_Digits)+" "+"High "+DoubleToString(high[0],_Digits)+" Low "+DoubleToString(low[0],_Digits);
   if(s3)str6+=" BUY";
   else if(ss3) str6+=" SELL";
   if(s5) str7="ABERTURA DENTRO DA BANDA ";
   else str7="ABERTURA DENTRO DA BANDA";
   str8="RSI 2= "+DoubleToString(rsi2.Main(0),1);
   str9="ATR VOL "+DoubleToString(atrvol.Main(0),_Digits);
   str10="ATR GAIN "+DoubleToString(atrgain.Main(0),_Digits);

   str11=informacoes;

   switch(number)
     {
      case 0  : return(DoubleToString(lucro_total,2));      break;
      case 1  : return(DoubleToString(lucro_liquido,2));      break;
      case 2  : return(IntegerToString(ENTRADAS_TOTAL));    break;
      case 3: return(str3); break;
      case 4: return(str4); break;
      case 5: return(str5); break;
      case 6: return(str6); break;
      case 7: return(str7); break;
      case 8: return(str8); break;
      case 9: return(str9); break;
      case 10: return(str10); break;
      case 11: return(str11); break;

      default : return(empty);

     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
//| Criar a linha horizontal                                         | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long            chart_ID=0,        // ID de gráfico 
                 const string          name="HLine",      // nome da linha 
                 const int             sub_window=0,      // índice da sub-janela 
                 double                price=0,           // line price 
                 const color           clr=clrRed,        // cor da linha 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // estilo da linha 
                 const int             width=1,           // largura da linha 
                 const bool            back=false,        // no fundo 
                 const bool            selection=true,    // destaque para mover 
                 const bool            hidden=true,       //ocultar na lista de objetos 
                 const long            z_order=0)         // prioridade para clique do mouse 
  {
//--- se o preço não está definido, defina-o no atual nível de preço Bid 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- redefine o valor de erro 
   ResetLastError();
//--- criar um linha horizontal 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": falha ao criar um linha horizontal! Código de erro = ",GetLastError());
      return(false);
     }
//--- definir cor da linha 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- definir o estilo de exibição da linha 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- definir a largura da linha 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- exibir em primeiro plano (false) ou fundo (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- habilitar (true) ou desabilitar (false) o modo do movimento da seta com o mouse 
//--- ao criar um objeto gráfico usando a função ObjectCreate, o objeto não pode ser 
//--- destacado e movimentado por padrão. Dentro deste método, o parâmetro de seleção 
//--- é verdade por padrão, tornando possível destacar e mover o objeto 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- ocultar (true) ou exibir (false) o nome do objeto gráfico na lista de objeto  
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- definir a prioridade para receber o evento com um clique do mouse no gráfico 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- sucesso na execução 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Excluir uma linha horizontal                                     | 
//+------------------------------------------------------------------+ 
bool HLineDelete(const long   chart_ID=0,   // ID do gráfico 
                 const string name="HLine") // nome da linha 
  {
//--- redefine o valor de erro 
   ResetLastError();
//--- excluir uma linha horizontal 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": falha ao Excluir um linha horizontal! Código de erro = ",GetLastError());
      return(false);
     }
//--- sucesso na execução 
   return(true);
  }
//+------------------------------------------------------------------+
