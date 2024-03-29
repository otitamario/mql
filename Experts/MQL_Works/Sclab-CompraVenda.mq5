//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

#include "CisNewBar.mqh"
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include<Trade\AccountInfo.mqh>


CisNewBar current_chart; // instance of the CisNewBar class: current chart

CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
CiMA *media;
CiVolumes *vol;

input ulong Magic_Number=55555;//Numero Mágico
input double Lot=1;//Lote de entrada;
input double _StopLoss=70;//Stop Loss em Pontos (Distancia dos extremos da barra) 
input double _TakeProfit=10;//Take Profit em Pontos
input double rompimento=5;//Rompimento da Barra em pontos para entrada
sinput string shorario="############------FILTRO DE HORARIO------#################";
input string start_hour="9:05";//Horario Inicial
input string end_hour="17:30";//Horario Final
input int periodo_media=6;//Periodo Media
sinput string slimitrad="############------Limite de Operações------#################";
input int perd_cons=2;//Máximo de Perdas Consecutivas
input int n_perd_tot=3;//Máximo de Perdas Totais
input bool Use_gain_cons=true;//Usar Ganhos Consecutivos
input int n_gain_tot=20;//Máximo de Ganhos Consecutivos

input ENUM_MA_METHOD modo_media=MODE_SMA;//Modo Média
input int velas_amplitude=3;//Número de Velas para Amplitude;
input bool UsarMelhor10=true;//Usar Melhoria 10
input int num_melhor10=6;//Numero da Vela da Melhoria 10
input double lim_inf_ampl_padrao=1.2;//Limite Inferior Amplitude Padrão
input double lim_sup_ampl_padrao=1.5;//Limite Superior Amplitude Padrão
input int ticks_ampl=0;//Ticks Favoráveis Entrada Amplitude
input int ticks_stop=1;//Ticks Ajustar Stop/Take Profit Não Atingido
input int ticks_take=0;//Ticks Ajustar Abertura/Take Profit Não Atingido
input double lim_inf_buy_ml5=-1.0;//Limite inferior Compra PPCE Melhoria 5
input double lim_sup_buy_ml5=2.0;//Limite superior Compra PPCE Melhoria 5
input double lim_inf_sell_ml5=-2.0;//Limite inferior Venda PPCE Melhoria 5
input double lim_sup_sell_ml5=1.0;//Limite superior Venda PPCE Melhoria 5
input bool UsarMelhor2=true;//Usar Melhoria 2
input bool UsarMelhor9=false;//Usar Melhoria 9
input bool UsarMelhor11=false;//Usar Melhoria 11
input bool UsarMelhor12=false;//Usar Melhoria 12
input bool UsarMelhor13=false;//Usar Melhoria 13(Take Profit Amplitude)
input double Take_Ampl13=30;//TakeProfit Melhoria 13
input bool UsarMelhor14=false;//Usar Melhoria 14
input bool UsarMelhor15=false;//Usar Melhoria 15
input int num_cand_tend=12;//Numero de Candles Linha de Tendencia - Melhoria 15
input double lim_inf_pos_buy_melhl5=50.0;//Lim inf positivo Linha Tendencia Melhoria 15
input double lim_sup_pos_buy_melhl5=75.0;//Lim sup positivo Linha Tendencia Melhoria 15
input double lim_inf_neg_buy_melhl5=-45.0;//Lim infr negativo Linha Tendencia Melhoria 15
input double lim_sup_neg_buy_melhl5=-10.0;//Lim sup negativo Linha Tendencia Melhoria 15
input double lim_inf_pos_sell_melhl5=10.0;//Lim inf positivo Linha Tendencia Melhoria 15
input double lim_sup_pos_sell_melh15=45.0;//Lim sup positivo Linha Tendencia Melhoria 15
input double lim_inf_neg_sell_melhl5=-75.0;//Lim infr negativo Linha Tendencia Melhoria 15
input double lim_sup_neg_sell_melhl5=-50.0;//Lim sup negativo Linha Tendencia Melhoria 15
input bool UsarMelhor17=false;//Usar Melhoria 17
input double lim_inf_pcv=1.0;//Lim inferior PCV;
input double lim_sup_pcv=25.0;//Lim superior PCV;
input int n_ticks_stop_pcv=1;//N ticks STOP Melhoria 17;
input double take_prof_melh17=50;//Take Profit em pontos Melhoria 17
string          symbol;
ENUM_TIMEFRAMES period;

double ponto,ticksize,digits;
ulong compra1_ticket,venda1_ticket,stp_venda_ticket,stp_compra_ticket,tp_venda_ticket,tp_compra_ticket;
double ask,bid;
double oldprice,sellprice,buyprice,tp_position,sl_position;
double high[],low[],open[],close[];

string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string tp_vd_tick="tp_vd_tick"+Symbol()+IntegerToString(Magic_Number),tp_cp_tick="tp_cp_tick"+Symbol()+IntegerToString(Magic_Number);
string stp_vd_tick="stp_vd_tick"+Symbol()+IntegerToString(Magic_Number),stp_cp_tick="stp_cp_tick"+Symbol()+IntegerToString(Magic_Number);
string global_b_high="b_high"+Symbol()+IntegerToString(Magic_Number),global_b_low="b_low"+Symbol()+IntegerToString(Magic_Number);
string perd_tot="perd_tot"+Symbol()+IntegerToString(Magic_Number),gain_tot="gain_tot"+Symbol()+IntegerToString(Magic_Number);
string trans_tot="trans_tot"+Symbol()+IntegerToString(Magic_Number);
string last_trade="last_trade"+Symbol()+IntegerToString(Magic_Number);

string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
string informacoes;
datetime time_open;
datetime hora_inicial,hora_final;
bool timerOn,tradeOn;
datetime TimeBar[1],TimeNewDay[1];
datetime          m_lastbar_time;   // Time of opening last bar
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   mysymbol.Name(Symbol());
   mytrade.SetExpertMagicNumber(Magic_Number);
   ponto=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
   ticksize=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
   tradeOn=true;
   m_lastbar_time=0;
   media=new CiMA;
   media.Create(Symbol(),Period(),periodo_media,0,modo_media,PRICE_CLOSE);
   media.AddToChart(ChartID(),0);

   vol=new CiVolumes;
   vol.Create(Symbol(),Period(),VOLUME_REAL);
   vol.AddToChart(ChartID(),ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL));

   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0);
   if(!GlobalVariableCheck(tp_vd_tick))GlobalVariableSet(tp_vd_tick,0);
   if(!GlobalVariableCheck(tp_cp_tick))GlobalVariableSet(tp_cp_tick,0);
   if(!GlobalVariableCheck(stp_vd_tick))GlobalVariableSet(stp_vd_tick,0);
   if(!GlobalVariableCheck(stp_cp_tick))GlobalVariableSet(stp_cp_tick,0);

   if(!GlobalVariableCheck(global_b_high))GlobalVariableSet(global_b_high,0);
   if(!GlobalVariableCheck(global_b_low))GlobalVariableSet(global_b_low,0);
   if(!GlobalVariableCheck(perd_tot))GlobalVariableSet(perd_tot,0);
   if(!GlobalVariableCheck(gain_tot))GlobalVariableSet(gain_tot,0);
   if(!GlobalVariableCheck(trans_tot))GlobalVariableSet(trans_tot,0);
   if(!GlobalVariableCheck(last_trade))GlobalVariableSet(last_trade,0);

   current_chart.SetSymbol(Symbol());
   current_chart.SetPeriod(Period());

   symbol = current_chart.GetSymbol();
   period = current_chart.GetPeriod();

   Comment(">>>>>>>>>>> ",period);

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(velas_amplitude<1)
     {
      string erro="Número de Velas de Amplitude tem que ser maior que 1";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(velas_amplitude>=num_melhor10)
     {
      string erro="Número da Vela da Melhoria 10 deve ser maior que número de velas da Amplitude";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   return(INIT_SUCCEEDED);


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

      if(HistorySelect(TimeCurrent()-PeriodSeconds(PERIOD_D1),TimeCurrent()))
        {
         ulong deals_total=HistoryDealsTotal();
         ulong deals_ticket=HistoryDealGetTicket(deals_total-1);
         mydeal.Ticket(deals_ticket);

         if((trans.deal_type==DEAL_TYPE_BUY || trans.deal_type==DEAL_TYPE_SELL) && mydeal.Entry()==DEAL_ENTRY_OUT)
           {

            if(mydeal.Profit()>0)
              {
               GlobalVariableSet(gain_tot,GlobalVariableGet(gain_tot)+1);
               GlobalVariableSet(last_trade,1);
               GlobalVariableSet(trans_tot,0);

              }

            if(mydeal.Profit()<0)
              {
               GlobalVariableSet(perd_tot,GlobalVariableGet(perd_tot)+1);
               if(GlobalVariableGet(last_trade)==-1 || GlobalVariableGet(trans_tot)==0)GlobalVariableSet(trans_tot,GlobalVariableGet(trans_tot)-1);
               GlobalVariableSet(last_trade,-1);

              }

           }
        }
     }

   if(type==TRADE_TRANSACTION_HISTORY_ADD)
     {

      ulong order_ticket=trans.order;
      myorder.Select(order_ticket);
      myposition.SelectByTicket(trans.position);

      if(order_ticket==compra1_ticket && trans.order_state==ORDER_STATE_FILLED)

        {
         myposition.SelectByTicket(compra1_ticket);
         time_open=iTime(Symbol(),Period(),0);
         buyprice=myposition.PriceOpen();
         if(UsarMelhor17) sl_position=NormalizeDouble(GlobalVariableGet(global_b_low)-n_ticks_stop_pcv*ticksize,digits);
         else sl_position=NormalizeDouble(GlobalVariableGet(global_b_low)-_StopLoss*ponto,digits);
         tp_position=NormalizeDouble(buyprice+_TakeProfit*ponto,digits);
         if(UsarMelhor10)tp_position=NormalizeDouble(buyprice+Melhoria10()*ponto,digits);
         if(Melhoria1() && UsarMelhor13)tp_position=NormalizeDouble(buyprice+Take_Ampl13*ponto,digits);
         if(UsarMelhor17)tp_position=NormalizeDouble(buyprice+take_prof_melh17*ponto,digits);
         mytrade.SellLimit(Lot,tp_position,Symbol(),0,0,0,0,"TAKE PROFIT");
         tp_venda_ticket=mytrade.ResultOrder();
         GlobalVariableSet(tp_vd_tick,(double)tp_venda_ticket);
         //Stop para posição comprada
         sellprice=sl_position;
         mytrade.SellStop(Lot,sellprice,Symbol(),0,0,0,0,"STOP"+exp_name);
         stp_venda_ticket=mytrade.ResultOrder();
         GlobalVariableSet(stp_vd_tick,(double)stp_venda_ticket);

        }
      //--------------------------------------------------

      if(order_ticket==venda1_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         myposition.SelectByTicket(venda1_ticket);
         time_open=iTime(Symbol(),Period(),0);
         sellprice=myposition.PriceOpen();
         if(UsarMelhor17) sl_position=NormalizeDouble(GlobalVariableGet(global_b_high)+n_ticks_stop_pcv*ticksize,digits);
         else sl_position=NormalizeDouble(GlobalVariableGet(global_b_high)+_StopLoss*ponto,digits);
         tp_position=NormalizeDouble(sellprice-_TakeProfit*ponto,digits);
         if(UsarMelhor10)tp_position=NormalizeDouble(sellprice-Melhoria10()*ponto,digits);
         if(Melhoria1() && UsarMelhor13)tp_position=NormalizeDouble(sellprice-Take_Ampl13*ponto,digits);
         if(UsarMelhor17)tp_position=NormalizeDouble(sellprice-take_prof_melh17*ponto,digits);
         mytrade.BuyLimit(Lot,tp_position,Symbol(),0,0,0,0,"TAKE PROFIT");
         tp_compra_ticket=mytrade.ResultOrder();
         GlobalVariableSet(tp_cp_tick,(double)tp_compra_ticket);
         buyprice=sl_position;
         mytrade.BuyStop(Lot,buyprice,Symbol(),0,0,0,0,"STOP"+exp_name);
         stp_compra_ticket=mytrade.ResultOrder();
         GlobalVariableSet(stp_cp_tick,(double)stp_compra_ticket);

        }
      //--------------------------------------------------

      // Fechar Ordens e Posicoes

      if(order_ticket==stp_compra_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         informacoes="Posicao Fechada por Ordem Buy Stop";
         DeleteALL();;
         Print(informacoes);

        }

      if(order_ticket==stp_venda_ticket && trans.order_type==ORDER_TYPE_SELL_STOP && trans.order_state==ORDER_STATE_FILLED)
        {
         informacoes="Posicao Fechada por Ordem Sell Stop";
         DeleteALL();;
         Print(informacoes);
        }

      if(order_ticket==tp_compra_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         informacoes="Posicao Fechada por Take Profit";
         DeleteALL();
         Print(informacoes);

        }
      if(order_ticket==tp_venda_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         informacoes="Posicao Fechada por Take Profit";
         DeleteALL();
         Print(informacoes);

        }

     }//End TRANSACTIONS HISTORY ADD

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void OnTimer()
  {
   if(!PosicaoAberta())
     {
      if(myorder.Select(compra1_ticket))
        {
         mytrade.OrderDelete(compra1_ticket);
         Print("Ordem Buy Stop Deletada pelo tempo");
        }
      if(myorder.Select(venda1_ticket))
        {
         mytrade.OrderDelete(venda1_ticket);
         Print("Ordem Sell Stop Deletada pelo tempo");
        }
     }
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   DeletaIndicadores();
   delete(media);
   delete(vol);
   if(reason!=5)
     {
      GlobalVariableSet(perd_tot,0);
      GlobalVariableSet(gain_tot,0);
      GlobalVariableSet(trans_tot,0);
      GlobalVariableSet(last_trade,0);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   int nticket;
   mysymbol.Refresh();
   mysymbol.RefreshRates();
   media.Refresh();
   vol.Refresh();

   CopyTime(Symbol(),PERIOD_D1,0,1,TimeNewDay);
   bool novodia;
   novodia=isNewBar(TimeNewDay[0]);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(novodia)
     {
      GlobalVariableSet(perd_tot,0);
      GlobalVariableSet(gain_tot,0);
      GlobalVariableSet(trans_tot,0);
      GlobalVariableSet(last_trade,0);
      tradeOn=true;
     }

   tradeOn=!LimiteOperacoes();

   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

   compra1_ticket=(int) GlobalVariableGet(cp_tick);
   venda1_ticket=(int) GlobalVariableGet(vd_tick);
   stp_compra_ticket=(int) GlobalVariableGet(stp_cp_tick);
   stp_venda_ticket=(int) GlobalVariableGet(stp_vd_tick);
   tp_compra_ticket=(int) GlobalVariableGet(tp_cp_tick);
   tp_venda_ticket=(int) GlobalVariableGet(tp_vd_tick);
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final;
   if(!timerOn || !tradeOn)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
     }

   CopyTime(Symbol(),PERIOD_CURRENT,0,1,TimeBar);

   GlobalVariableSet(global_b_high,high[1]);
   GlobalVariableSet(global_b_low,low[1]);

   Comment("b_open  --> ",open[1],
           "\nb_close --> ",close[1],
           "\nb_high  --> ",high[1],
           "\nb_low   --> ",low[1],
           "\nordens abertas  --> ",OrdersTotal(),
           "\ncurrent_chart  --> ",current_chart.isNewBar(),
           "\nsmaArray0  --> ",media.Main(0),
           "\nsmaArray1  --> ",media.Main(1),
           "\nsmaArray2  --> ",media.Main(2),
           "\n PPCE "+DoubleToString(PPCE(),8),
           "\n Perdas Totais : "+DoubleToString(GlobalVariableGet(perd_tot),0),
           "\n Perdas Consecutivas : "+DoubleToString(-GlobalVariableGet(trans_tot),0),
           "\n Ganhos Consecutivos: "+DoubleToString(GlobalVariableGet(gain_tot),0),
           "\n Take Profit Melhoria 10: "+DoubleToString(Melhoria10(),0),
           "\n Tangente em graus Melhoria 15: "+DoubleToString(Melhoria15(),2),
           "\n PCV Melhoria 17: "+DoubleToString(PCV(),2),
           "\n Pavio Superior: "+DoubleToString(Pavio_Sup(),2),
           "\n Pavio Inferior: "+DoubleToString(Pavio_Inf(),2),

           tradeOn?"\n STATUS: "+"ATIVO ":"\n STATUS: "+"FINALIZADO",
           timerOn?"\n HORÁRIO PERMITIDO":"\n FORA DO HORÁRIO");

   string          comment;
//---
   int new_bars=current_chart.isNewBar();
   if(new_bars>0)
     {
      comment=current_chart.GetComment();
      Print(symbol,GetPeriodName(period),comment);
      Print(symbol,GetPeriodName(period)," Number of new bars = ",new_bars," Time = ",TimeToString(TimeCurrent(),TIME_SECONDS));

     }
   MqlTick last_tick;

   if(SymbolInfoTick(Symbol(),last_tick))
     {
      bid= last_tick.bid;
      ask=last_tick.ask;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      Print("Falhou obter o tick");
      return;
     }
   double spread=ask-bid;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }

   if(timerOn && tradeOn)

     {
      if(isNewBar(TimeBar[0]))
        {

         if(UsarMelhor17)
           {
            if(BuySignal() && PCV_Entry_Buy() && !Buy_opened())
              {
               DeleteALL();
               CloseALL();
               if(mytrade.Buy(Lot,Symbol(),0,0,0,"BUY"+exp_name))
                 {
                  compra1_ticket=mytrade.ResultOrder();
                  GlobalVariableSet(cp_tick,(double)compra1_ticket);
                 }
              }

            if(SellSignal() && PCV_Entry_Sell() && !Sell_opened())
              {
               DeleteALL();
               CloseALL();
               if(mytrade.Sell(Lot,Symbol(),0,0,0,"SELL"+exp_name))
                 {
                  venda1_ticket=mytrade.ResultOrder();
                  GlobalVariableSet(vd_tick,(double)venda1_ticket);
                 }
              }

           }//Fim Melhoria 17
         else
           {
            Melhoria3();
            if(SellSignal() && !PosicaoAberta() && !OpenOrders())
              {
               if(!Melhoria1())
                 {
                  if(!OrdemAberta(ORDER_TYPE_SELL_STOP) && !Sell_opened())
                    {
                     sellprice=NormalizeDouble(low[1]-rompimento*ponto,digits);
                     if(bid>sellprice)
                       {
                        mytrade.SellStop(Lot,sellprice,Symbol(),0,0,0,0,"SELL"+exp_name);
                        venda1_ticket=mytrade.ResultOrder();
                        GlobalVariableSet(vd_tick,(double)venda1_ticket);
                        EventSetTimer(PeriodSeconds());
                       }
                     else
                       {
                        mytrade.Sell(Lot,Symbol(),0,0,0,"SELL"+exp_name);
                        venda1_ticket=mytrade.ResultOrder();
                        GlobalVariableSet(vd_tick,(double)venda1_ticket);
                       }
                    }
                 }

               else
                 {
                  if(!Sell_opened())
                    {
                     mytrade.SellLimit(Lot,NormalizeDouble(close[1]+ticks_ampl*ticksize,digits),Symbol(),0,0,0,0,"SELL"+exp_name);
                     venda1_ticket=mytrade.ResultOrder();
                     GlobalVariableSet(vd_tick,(double)venda1_ticket);
                     EventSetTimer(PeriodSeconds());

                    }
                 }
              }
            if(BuySignal() && !PosicaoAberta() && !OpenOrders())
              {
               if(!Melhoria1())
                 {
                  if(!OrdemAberta(ORDER_TYPE_BUY_STOP) && !Buy_opened())
                    {
                     buyprice=NormalizeDouble(high[1]+rompimento*ponto,digits);
                     if(ask<buyprice)
                       {
                        mytrade.BuyStop(Lot,buyprice,Symbol(),0,0,0,0,"BUY"+exp_name);
                        compra1_ticket=mytrade.ResultOrder();
                        GlobalVariableSet(cp_tick,(double)compra1_ticket);
                        EventSetTimer(PeriodSeconds());
                       }
                     else
                       {
                        mytrade.Buy(Lot,Symbol(),0,0,0,"BUY"+exp_name);
                        compra1_ticket=mytrade.ResultOrder();
                        GlobalVariableSet(cp_tick,(double)compra1_ticket);

                       }
                    }
                 }
               else
                 {
                  if(!Buy_opened())
                    {
                     mytrade.BuyLimit(Lot,NormalizeDouble(close[1]-ticks_ampl*ticksize,digits),Symbol(),0,0,0,0,"BUY"+exp_name);
                     compra1_ticket=mytrade.ResultOrder();
                     GlobalVariableSet(cp_tick,(double)compra1_ticket);
                     EventSetTimer(PeriodSeconds());

                    }
                 }

              }
           }//Else Melhoria 17
         //Melhoria2
         if(TimeCurrent()-time_open<=PeriodSeconds())
           {
            if(Buy_opened() && Melhoria2())
              {
               CloseALL();
               DeleteALL();
               Print("Melhoria 2");
              }
            if(Sell_opened() && Melhoria2())
              {
               CloseALL();
               DeleteALL();
               Print("Melhoria 2");
              }

           }

        }//Fim NewBar
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

string GetPeriodName(ENUM_TIMEFRAMES period)
  {
   if(period==PERIOD_CURRENT) period=Period();
//---
   switch(period)
     {
      case PERIOD_M1:  return(" M1 ");
      case PERIOD_M2:  return(" M2 ");
      case PERIOD_M3:  return(" M3 ");
      case PERIOD_M4:  return(" M4 ");
      case PERIOD_M5:  return(" M5 ");
      case PERIOD_M6:  return(" M6 ");
      case PERIOD_M10: return(" M10 ");
      case PERIOD_M12: return(" M12 ");
      case PERIOD_M15: return(" M15 ");
      case PERIOD_M20: return(" M20 ");
      case PERIOD_M30: return(" M30 ");
      case PERIOD_H1:  return(" H1 ");
      case PERIOD_H2:  return(" H2 ");
      case PERIOD_H3:  return(" H3 ");
      case PERIOD_H4:  return(" H4 ");
      case PERIOD_H6:  return(" H6 ");
      case PERIOD_H8:  return(" H8 ");
      case PERIOD_H12: return(" H12 ");
      case PERIOD_D1:  return(" Daily ");
      case PERIOD_W1:  return(" Weekly ");
      case PERIOD_MN1: return(" Monthly ");
     }
//---
   return("unknown period");
  }
//+------------------------------------------------------------------+
bool BuySignal()
  {
   bool signal=(Vol_ticks1()<Vol_ticks2()*4) && (Vol_ticks1()*4>Vol_ticks2()) && close[1]-mysymbol.TickSize()>media.Main(1) && close[2]+mysymbol.TickSize()<media.Main(2) && ((ask+bid)/2>media.Main(0));
   signal=signal && !Melhoria4() && Melhoria5_Buy();
   bool melhor11=close[3]<=open[3]&&open[3]<media.Main(3)&&close[2]>open[2]&&close[2]<media.Main(2)&&close[1]>open[1];
   bool melhor12=close[3]>open[3]&&close[3]<media.Main(3)&&close[2]<open[2]&&open[2]<media.Main(2)&&close[1]>open[1];
   bool melhor14=close[3]==open[3]&&close[3]<media.Main(3)&&close[2]<open[2]&&open[2]<media.Main(2)&&close[1]>open[1];

   if(UsarMelhor9)signal=signal && !Melhoria9();
   if(UsarMelhor11)signal=signal&&!melhor11;
   if(UsarMelhor12)signal=signal&&!melhor12;
   if(UsarMelhor14)signal=signal&&!melhor14;
   if(UsarMelhor15)signal=signal&&Melhoria15_Buy();
   if(UsarMelhor17)signal=signal||PCV_Entry_Buy();

   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   bool signal=(Vol_ticks1()<Vol_ticks2()*4) && (Vol_ticks1()*4>Vol_ticks2()) && close[1]+mysymbol.TickSize()<media.Main(1) && close[2]-mysymbol.TickSize()>media.Main(2) && ((ask+bid)/2<media.Main(0));

   signal=signal && !Melhoria4() && Melhoria5_Sell();
   bool melhor11=close[3]>=open[3]&&open[3]>media.Main(3)&&close[2]<open[2]&&close[2]>media.Main(2)&&close[1]<open[1];
   bool melhor12=close[3]<open[3]&&close[3]>media.Main(3)&&close[2]>open[2]&&open[2]>media.Main(2)&&close[1]<open[1];
   bool melhor14=close[3]==open[3]&&close[3]>media.Main(3)&&close[2]>open[2]&&open[2]>media.Main(2)&&close[1]<open[1];

   if(UsarMelhor9)signal=signal && !Melhoria9();
   if(UsarMelhor11)signal=signal&&!melhor11;
   if(UsarMelhor12)signal=signal&&!melhor12;
   if(UsarMelhor14)signal=signal&&!melhor14;
   if(UsarMelhor15)signal=signal&&Melhoria15_Sell();
   if(UsarMelhor17)signal=signal||PCV_Entry_Sell();

   return signal;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool IsOpenOrders()
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteALL()
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      ulong o_ticket=OrderGetTicket(j);
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      ulong o_ticket=OrderGetTicket(j);
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Buy_opened()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name() && myposition.PositionType()==POSITION_TYPE_BUY)
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
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name() && myposition.PositionType()==POSITION_TYPE_SELL)
         return(true);  //It is a Buy
     }
   return(false);
  }
//+------------------------------------------------------------------+
double PriceLastStopOrder(const ENUM_ORDER_TYPE pending_order_type)
  {
   datetime last_time=0;
   double last_price=-1.0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+
bool OrdemAberta(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OpenOrders()
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            return true;
   return false;
  }
//+------------------------------------------------------------------+
bool PosicaoAberta()
  {
   if(myposition.SelectByMagic(Symbol(),Magic_Number)==true)
      return(myposition.PositionType()== POSITION_TYPE_BUY||myposition.PositionType()== POSITION_TYPE_SELL);
   else return(false);
  }
//+------------------------------------------------------------------+
void DeletaIndicadores()
  {
   string name;
//--- O número de janelas no gráfico (ao menos uma janela principal está sempre presente) 
   int windows=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
//--- Verifique todas as janelas 
   for(int w=windows-1;w>=0;w--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
  }
//+------------------------------------------------------------------+
void CloseALL()
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
bool isNewBar(datetime newbar_time)
  {

   uint              m_retcode;        // Result code of detecting new bar 
   int               m_new_bars;       // Number of new bars
   string            m_comment;        // Comment of execution

//--- Initialization of protected variables
   m_new_bars = 0;      // Number of new bars
   m_retcode  = 0;      // Result code of detecting new bar: 0 - no error
   m_comment  =__FUNCTION__+" Successful check for new bar";
//---

//--- Just to be sure, check: is the time of (hypothetically) new bar m_newbar_time less than time of last bar m_lastbar_time? 
   if(m_lastbar_time>newbar_time)
     { // If new bar is older than last bar, print error message
      m_comment=__FUNCTION__+" Synchronization error: time of previous bar "+TimeToString(m_lastbar_time)+
                ", time of new bar request "+TimeToString(newbar_time);
      m_retcode=-1;     // Result code of detecting new bar: return -1 - synchronization error
      return(false);
     }
//---

//--- if it's the first call 
   if(m_lastbar_time==0)
     {
      m_lastbar_time=newbar_time; //--- set time of last bar and exit
                                  //  m_comment=__FUNCTION__+" Initialization of lastbar_time = "+TimeToString(m_lastbar_time);
      return(false);
     }
//---

//--- Check for new bar: 
   if(m_lastbar_time<newbar_time)
     {
      m_new_bars=1;               // Number of new bars
      m_lastbar_time=newbar_time; // remember time of last bar
      return(true);
     }
//---

//--- if we've reached this line, then the bar is not new; return false
   return(false);
  }
//+------------------------------------------------------------------+

bool GetIndValue()
  {
   bool b_get;
   b_get=CopyHigh(Symbol(),Period(),0,5,high)<=0 || 
         CopyOpen(Symbol(),Period(),0,5,open)<=0 || 
         CopyLow(Symbol(),Period(),0,5,low)<=0 || 
         CopyClose(Symbol(),Period(),0,5,close)<=0;
   return(b_get);
  }
//+------------------------------------------------------------------+

double Vol_ticks1()
  {
   double vol;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(open[1]<close[1])
     {
      vol=(close[1]-open[1]);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      vol=(open[1]-close[1]);
     }
   return vol;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Vol_ticks2()
  {
   double vol;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(open[2]<close[2])
     {
      vol=(close[2]-open[2]);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      vol=(open[2]-close[2]);
     }
   return vol;
  }
//+------------------------------------------------------------------+
bool Melhoria4()
  {
   bool signal;
   if(open[2]<close[2])
     {
      signal=media.Main(2)>=open[2] && media.Main(2)<=close[2];
     }
   else signal=media.Main(2)>=close[2] && media.Main(2)<=open[2];
   signal=signal || media.Main(3)>=low[3] && media.Main(3)<=high[3];
   if(signal)Print("Melhoria 4: Média entre abertura e fechamento do candle 2 OU Média entre máxima e minima candle 3");
   return signal;
  }
//+------------------------------------------------------------------+
bool Melhoria2()
  {
   bool signal=false;
   if(Buy_opened())signal=open[0]<media.Main(0);
   if(Sell_opened())signal=open[0]>media.Main(0);
   if(!UsarMelhor2)signal=false;
   return signal;
  }
//+------------------------------------------------------------------+
double PPCE()
  {
   double ma_gat,ma2,ma1,ma;
   ma_gat=media.Main(1);
   ma1=media.Main(2);
   ma2=media.Main(3);
   ma=(ma_gat+ma1+ma2)/3;
   double ppce=((ma_gat-ma2)/ma)*100;
   return ppce;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Amplitude()
  {
   double amplitude=0;
   for(int i=1;i<=velas_amplitude;i++)amplitude+=iHigh(Symbol(),Period(),i)-iLow(Symbol(),Period(),i);
   amplitude=amplitude/velas_amplitude;
   amplitude=(high[1]-low[1])/amplitude;
   return amplitude;
  }
//+------------------------------------------------------------------+
bool Melhoria1()
  {
   bool signal;
   signal=Amplitude()>=lim_inf_ampl_padrao && Amplitude()<=lim_sup_ampl_padrao;
   return signal;
  }
//+------------------------------------------------------------------+
void Melhoria3()
  {
   double price;
   if(TimeCurrent()-time_open>=2*PeriodSeconds() && TimeCurrent()-time_open<3*PeriodSeconds())
     {
      if(Buy_opened())
        {
         myposition.SelectByTicket(compra1_ticket);
         price=NormalizeDouble(myposition.PriceOpen()+ticks_take*ticksize,digits);
         mytrade.OrderModify(tp_venda_ticket,price,0,0,0,0,0);
         mytrade.OrderModify(stp_venda_ticket,NormalizeDouble(low[2]-ticks_stop*ticksize,digits),0,0,0,0,0);
         Print("Melhoria 3: Stop e Take Profit Modificados");
        }
      if(Sell_opened())
        {
         myposition.SelectByTicket(venda1_ticket);
         price=NormalizeDouble(myposition.PriceOpen()-ticks_take*ticksize,digits);
         mytrade.OrderModify(tp_compra_ticket,price,0,0,0,0,0);
         mytrade.OrderModify(stp_compra_ticket,NormalizeDouble(high[2]+ticks_stop*ticksize,digits),0,0,0,0,0);
         Print("Melhoria 3: Stop e Take Profit Modificados");
        }

     }

  }
//+------------------------------------------------------------------+
bool Melhoria5_Buy()
  {
   bool signal;
   signal=PPCE()>=lim_inf_buy_ml5 && PPCE()<=lim_sup_buy_ml5;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Melhoria5_Sell()
  {
   bool signal;
   signal=PPCE()>=lim_inf_sell_ml5 && PPCE()<=lim_sup_sell_ml5;
   return signal;

  }
//+------------------------------------------------------------------+
bool LimiteOperacoes()
  {
   bool signal=(GlobalVariableGet(perd_tot)==n_perd_tot || (Use_gain_cons && GlobalVariableGet(gain_tot)==n_gain_tot) || GlobalVariableGet(trans_tot)==-perd_cons);
   return signal;
  }
//+------------------------------------------------------------------+
bool Melhoria9()
  {
   bool b1,b2,signal;
   b1=close[3]>media.Main(3) && close[2]>media.Main(2) && open[3]>media.Main(3) && open[2]>media.Main(2) && close[1]<open[1] && close[1]<media.Main(1);
   b1=b1&&close[3]>open[3]&&close[2]>open[2];
   b2=close[3]<media.Main(3) && close[2]<media.Main(2) && open[3]<media.Main(3) && open[2]<media.Main(2) && close[1]>open[1] && close[1]>media.Main(1);
   b2=b2&&close[3]<open[3]&&close[2]<open[2];
   signal=(b1 || b2);
   return signal;


  }
//+------------------------------------------------------------------+
double Melhoria10()
  {
   const int n_tot=num_melhor10-velas_amplitude+1;
   double media[];
   double mmedia=0,desvio=0;
   double var,newtake;
   ArrayResize(media,n_tot);
   int cont=0;

   for(int i=velas_amplitude;i<=num_melhor10;i++)
     {
      media[cont]=0.5*(iClose(Symbol(),Period(),i)+iOpen(Symbol(),Period(),i));
      mmedia+=media[cont];
      cont+=1;
     }
   mmedia=mmedia/n_tot;
   cont=0;
   for(int i=velas_amplitude;i<=num_melhor10;i++)
     {
      desvio+=MathPow((media[cont]-mmedia),2);
      cont+=1;
     }
   desvio=desvio/n_tot;
   desvio=MathSqrt(desvio);
   var=1000*(desvio/mmedia);
   newtake=_TakeProfit*var;
   newtake=NormalizeDouble(MathRound(newtake/ticksize)*ticksize,digits);
   newtake=MathMax(newtake,ticksize);
// newtake=MathMin(_TakeProfit,newtake);
   return newtake;
  }
//+------------------------------------------------------------------+
double Melhoria15()
  {
   double tg;
   tg=(media.Main(1)-media.Main(num_cand_tend))/(num_cand_tend-1);
   tg=MathArctan(tg);
   tg=(180*tg)/M_PI;
   return tg;


  }
//+------------------------------------------------------------------+
bool Melhoria15_Buy()
  {
   bool signal;
   signal=Melhoria15()>=lim_inf_pos_buy_melhl5 && Melhoria15()<=lim_sup_pos_buy_melhl5 || Melhoria15()>=lim_inf_neg_buy_melhl5 && Melhoria15()<=lim_sup_neg_buy_melhl5;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Melhoria15_Sell()
  {
   bool signal;
   signal=Melhoria15()>=lim_inf_pos_sell_melhl5 && Melhoria15()<=lim_sup_pos_sell_melh15 || Melhoria15()>=lim_inf_neg_sell_melhl5 && Melhoria15()<=lim_sup_neg_sell_melhl5;
   return signal;
  }
//+------------------------------------------------------------------+
double PCV()
  {
   return 100*(vol.Main(2)/vol.Main(1));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PCV_Entry()
  {
   return PCV()>=lim_inf_pcv&& PCV()<=lim_sup_pcv;
  }
//+------------------------------------------------------------------+
double Pavio_Sup()
  {
   double pavio;
   if(close[1]>open[1]) pavio=high[1]-close[1];
   else pavio=high[1]-open[1];
   return pavio;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Pavio_Inf()
  {
   double pavio;
   if(close[1]>open[1]) pavio=open[1]-low[1];
   else pavio=close[1]-low[1];
   return pavio;

  }
//+------------------------------------------------------------------+
bool PCV_Entry_Buy()
  {
   return PCV_Entry()&&Pavio_Sup()<Pavio_Inf();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PCV_Entry_Sell()
  {
   return PCV_Entry()&&Pavio_Sup()>Pavio_Inf();
  }
//+------------------------------------------------------------------+
