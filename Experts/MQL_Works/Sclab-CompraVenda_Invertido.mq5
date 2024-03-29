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

input ulong Magic_Number=55555;//Numero Mágico
input double Lot=1;//Lote de entrada;
input double _StopLoss=70;//Stop Loss em Pontos (Distancia dos extremos da barra) 
input double _TakeProfit=10;//Take Profit em Pontos
input double rompimento=5;//Rompimento da Barra em pontos para entrada
sinput string shorario="############------FILTRO DE HORARIO------#################";
input string start_hour="9:05";//Horario Inicial
input string end_hour="17:30";//Horario Final
input int periodo_media=6;//Periodo Media
input ENUM_MA_METHOD modo_media=MODE_SMA;//Modo Média
string          symbol;
ENUM_TIMEFRAMES period;

double ponto,ticksize,digits;
ulong compra1_ticket,venda1_ticket,stp_venda_ticket,stp_compra_ticket,tp_venda_ticket,tp_compra_ticket;
double ask,bid,last,last_low,last_higt,b_open,b_close,b_high,b_low,c_open,c_close,c_high,c_low,vol_ticks_1,vol_ticks_2;
double oldprice,sellprice,buyprice,tp_position,sl_position;

string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string tp_vd_tick="tp_vd_tick"+Symbol()+IntegerToString(Magic_Number),tp_cp_tick="tp_cp_tick"+Symbol()+IntegerToString(Magic_Number);
string stp_vd_tick="stp_vd_tick"+Symbol()+IntegerToString(Magic_Number),stp_cp_tick="stp_cp_tick"+Symbol()+IntegerToString(Magic_Number);
string global_b_high="b_high"+Symbol()+IntegerToString(Magic_Number),global_b_low="b_low"+Symbol()+IntegerToString(Magic_Number);
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
string informacoes;
datetime time_open;
datetime hora_inicial,hora_final;
double smaArray[];
int smaHandle;
bool timerOn;
datetime TimeBar[1];
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
   m_lastbar_time=0;
   smaHandle=iMA(_Symbol,_Period,periodo_media,0,modo_media,PRICE_CLOSE);
   ChartIndicatorAdd(ChartID(),0,smaHandle);
   ArraySetAsSeries(smaArray,true);

   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0);
   if(!GlobalVariableCheck(tp_vd_tick))GlobalVariableSet(tp_vd_tick,0);
   if(!GlobalVariableCheck(tp_cp_tick))GlobalVariableSet(tp_cp_tick,0);
   if(!GlobalVariableCheck(stp_vd_tick))GlobalVariableSet(stp_vd_tick,0);
   if(!GlobalVariableCheck(stp_cp_tick))GlobalVariableSet(stp_cp_tick,0);

   if(!GlobalVariableCheck(global_b_high))GlobalVariableSet(global_b_high,0);
   if(!GlobalVariableCheck(global_b_low))GlobalVariableSet(global_b_low,0);

   current_chart.SetSymbol(Symbol());
   current_chart.SetPeriod(Period());

   symbol = current_chart.GetSymbol();
   period = current_chart.GetPeriod();

   Comment(">>>>>>>>>>> ",period);

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
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

   if(type==TRADE_TRANSACTION_HISTORY_ADD)
     {

      ulong order_ticket=trans.order;
      myorder.Select(order_ticket);
      myposition.SelectByTicket(trans.position);

      if(order_ticket==compra1_ticket && trans.order_state==ORDER_STATE_FILLED)

        {
         myposition.SelectByTicket(compra1_ticket);
         buyprice=myposition.PriceOpen();
         sl_position=NormalizeDouble(buyprice-_StopLoss*ponto,digits);
         tp_position=NormalizeDouble(buyprice+_TakeProfit*ponto,digits);
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
         sellprice=myposition.PriceOpen();
         sl_position=NormalizeDouble(sellprice+_StopLoss*ponto,digits);
         tp_position=NormalizeDouble(sellprice-_TakeProfit*ponto,digits);
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
         Print("Ordem Buy Limit Deletada pelo tempo");
        }
      if(myorder.Select(venda1_ticket))
        {
         mytrade.OrderDelete(venda1_ticket);
         Print("Ordem Sell Limit Deletada pelo tempo");
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
   IndicatorRelease(smaHandle);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   int nticket;

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   compra1_ticket=(int) GlobalVariableGet(cp_tick);
   venda1_ticket=(int) GlobalVariableGet(vd_tick);
   stp_compra_ticket=(int) GlobalVariableGet(stp_cp_tick);
   stp_venda_ticket=(int) GlobalVariableGet(stp_vd_tick);
   tp_compra_ticket=(int) GlobalVariableGet(tp_cp_tick);
   tp_venda_ticket=(int) GlobalVariableGet(tp_vd_tick);
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final;
   if(timerOn==false)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
     }

   CopyTime(Symbol(),PERIOD_CURRENT,0,1,TimeBar);
//int total=PositionsTotal();
//nticket=PositionGetTicket(total);
//nticket=mytrade.RequestOrder(position_ticket);
   CopyBuffer(smaHandle,0,0,3,smaArray);

   last        = SymbolInfoDouble(_Symbol, SYMBOL_LAST);
   last_low    = SymbolInfoDouble(_Symbol, SYMBOL_LASTLOW);
   last_higt   = SymbolInfoDouble(_Symbol, SYMBOL_LASTHIGH);


   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(Symbol(),0,0,4,rates);

   b_open  =StringToDouble(rates[1].open);
   b_close =StringToDouble(rates[1].close);
   b_high  =StringToDouble(rates[1].high);
   b_low   =StringToDouble(rates[1].low);

   GlobalVariableSet(global_b_high,b_high);
   GlobalVariableSet(global_b_low,b_low);
//rates[1].tick_volume;

   c_open  =StringToDouble(rates[2].open);
   c_close =StringToDouble(rates[2].close);
   c_high  =StringToDouble(rates[2].high);
   c_low   =StringToDouble(rates[2].low);
//rates[2].tick_volume;

   Comment("b_open  --> ",b_open,
           "\nb_close --> ",b_close,
           "\nb_high  --> ",b_high,
           "\nb_low   --> ",b_low,
           "\nordens abertas  --> ",OrdersTotal(),
           "\ncurrent_chart  --> ",current_chart.isNewBar(),
           "\nsmaArray0  --> ",smaArray[0],
           "\nsmaArray1  --> ",smaArray[1],
           "\nsmaArray2  --> ",smaArray[2]);

//CONDIÇÕES

//Volume de ticks 1 ---------->
   if(b_open<b_close)
     {
      vol_ticks_1=(b_close-b_open);
     }
   else
     {
      vol_ticks_1=(b_open-b_close);
     }
//Volume de ticks 1 ----------<

//Volume de ticks 2 ---------->
   if(c_open<c_close)
     {
      vol_ticks_2=(c_close-c_open);
     }
   else
     {
      vol_ticks_2=(c_open-c_close);
     }
//Volume de ticks 2 ----------<

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

   if(timerOn)

     {
      if(isNewBar(TimeBar[0]))
        {
         if((vol_ticks_1<vol_ticks_2*4) && (vol_ticks_1*4>vol_ticks_2) && b_close+mysymbol.TickSize()<smaArray[1] && c_close-mysymbol.TickSize()>smaArray[2] && ((ask+bid)/2<smaArray[0]) && PositionsTotal()==0 && OrdersTotal()==0)
           {

            if(!OrdemAberta(ORDER_TYPE_BUY_LIMIT) && !Buy_opened())
              {
               sellprice=NormalizeDouble(b_low-rompimento*ponto,digits);
               mytrade.BuyLimit(Lot,sellprice,Symbol(),0,0,0,0,"BUY"+exp_name);
               compra1_ticket=mytrade.ResultOrder();
               GlobalVariableSet(cp_tick,(double)compra1_ticket);
               EventSetTimer(PeriodSeconds());

              }

           }
         if((vol_ticks_1<vol_ticks_2*4) && (vol_ticks_1*4>vol_ticks_2) && b_close-mysymbol.TickSize()>smaArray[1] && c_close+mysymbol.TickSize()<smaArray[2] && ((ask+bid)/2>smaArray[0]) && PositionsTotal()==0 && OrdersTotal()==0)
           {

            if(!OrdemAberta(ORDER_TYPE_SELL_LIMIT) && !Sell_opened())
              {
               buyprice=NormalizeDouble(b_high+rompimento*ponto,digits);
               mytrade.SellLimit(Lot,buyprice,Symbol(),0,0,0,0,"SELL"+exp_name);
               venda1_ticket=mytrade.ResultOrder();
               GlobalVariableSet(vd_tick,(double)venda1_ticket);
               EventSetTimer(PeriodSeconds());

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
