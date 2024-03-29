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
enum TipoStop
  {
   Pontos,
   Porcentagem
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Applied_Extrem //Type of extreme points
  {
   HIGH_LOW,
   HIGH_LOW_OPEN,
   HIGH_LOW_CLOSE,
   OPEN_HIGH_LOW,
   CLOSE_HIGH_LOW
  };

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>
#include <Controls\Dialog.mqh>

#define INFOPANEL_SIZE 2 // Size of the array for info panel objects
#define EXPERT_NAME MQL5InfoString(MQL5_PROGRAM_NAME) // Name of the Expert Advisor


//Classes
CNewBar NewBar;
CTimer Timer;
CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
CiStochastic *stoch;

// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=21062018;
input ulong deviation_points=1000;//Deviation em Pontos(Padrao)
input double Lot=1;//Lote Entrada
input TipoStop StopType=Pontos;// Stop em Pontos ou Porcentagem
input double _Stop=150;//Valor Stop Loss 
input TipoStop TakeType=Pontos;// Stop em Pontos ou Porcentagem
input double _TakeProfit=2500; //Valor Take Profit

sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";
input bool UsarLucro=true;//Usar Lucro para Fechamento True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes

sinput string STrailing="############---------------Trailing Stop----------########";

input bool   Use_TraillingStop=true; //Usar Trailing 
input int TraillingStart=0;//Lucro Minimo Iniciar trailing stop
input int TraillingDistance=150;// Distanccia em Pontos do Stop Loss
input int TraillingStep=10;// Passo para atualizar Stop Loss

sinput string shorario="############------FILTRO DE HORARIO------#################";

input bool UseTimer = true;
input int StartHour = 9;//Hora de Inicio
input int StartMinute=0;//Minuto de Inicio

sinput string horafech="HORARIO PARA FECHAMENTO DE POSICOES E ORDENS";
input int EndHour=17;//Hora de Fechamento
input int EndMinute=00;//Minuto de Fechamento
input bool Daytrade=true;// Fechar posicoes Daytrade fim do dia

sinput string sindic="############------Indicators------#################";
input int DonchianPeriod=20;            //Period of averaging
input Applied_Extrem Extremes=CLOSE_HIGH_LOW; //Type of extreme points
input int Margins=0; //Margin
input int Shift=0;                      //Horizontal shift of the indicator in bars
input int InpKPeriod=10;  // K period Stochastic
input int InpDPeriod=3;  // D period Stochastic
input int InpSlowing=3;  // Slowing Stochastic


                         //Variaveis 
string original_symbol;
double mystop,mytake;
double ask,bid;
double lucro_total,pontos_total,lucro_liquido;
bool timerOn,tradeOn;
double ponto,ticksize,digits;
long curChartID;
int donchian_handle;
double Donchian_High[],Donchian_Low[];
double high[],low[],open[],close[];
ulong ENTRADAS_TOTAL;
ulong trade_ticket,compra1_ticket,venda1_ticket,stp_venda_ticket,stp_compra_ticket,tkp_venda_ticket,tkp_compra_ticket;

ulong nsubwindows,nchart_stoch;
double buyprice,sellprice,oldprice;
string informacoes=" ";
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
int PrevPositions;
datetime time_novodia[4];

//--- GLOBAL VARIABLES
string             pos_resultado=" ";           // Resultado
string             pos_liquido=" ";           // Resultado Liquido
string            pos_entradas=" ";     // Entradas
string               pos_variacao=" ";         // Variacao
string               pos_barra=" ";         // Trade Barra

//--- Array of names of objects that display the names of position properties
string pos_prop_names[INFOPANEL_SIZE]=
  {
   "name_resultado",
   "name_entradas"
  };
// Array of names of objects that display values of position properties
string pos_prop_values[INFOPANEL_SIZE]=
  {
   "value_resultado",
   "value_entradas"
  };
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   original_symbol=Symbol();
   tradeOn=true;
   trade_ticket=0;
   ENTRADAS_TOTAL=0;
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
   lucro_total=0.0;
   pontos_total=0.0;
   informacoes=" ";

   curChartID=ChartID();

   donchian_handle=iCustom(Symbol(),periodoRobo,"donchian_channels",DonchianPeriod,Extremes,Margins,Shift);
   ChartIndicatorAdd(ChartID(),0,donchian_handle);

   ArraySetAsSeries(Donchian_High,true);
   ArraySetAsSeries(Donchian_Low,true);

   stoch=new CiStochastic;
   stoch.Create(NULL,periodoRobo,InpKPeriod,InpDPeriod,InpSlowing,MODE_EMA,STO_LOWHIGH);
   stoch.AddToChart(ChartID(),1);

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
      string erro="Lote deve ser maior que 0";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);

     }
   if(_Stop<0)
     {
      string erro="Stop Negativo";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(_TakeProfit<0)
     {
      string erro="TakeProfit Negativo";
      MessageBox(erro);
      Print(erro);
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
   DeletaIndicadores();

   IndicatorRelease(donchian_handle);
   delete(stoch);
   Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");

   if(reason==REASON_REMOVE)
      //--- Delete all objects relating to the info panel from the chart
      DeleteInfoPanel();

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

      if(order_ticket==trade_ticket && trans.deal_type!=DEAL_TYPE_BALANCE)ENTRADAS_TOTAL++;

      if(StringSubstr(mydeal.Comment(),0,2)=="sl" || StringSubstr(mydeal.Comment(),0,2)=="tp")
        {
         DeleteOrders(ORDER_TYPE_SELL_STOP);
         DeleteOrders(ORDER_TYPE_BUY_STOP);
         informacoes="Posicao Fechada por "+StringSubstr(mydeal.Comment(),0,2)=="sl"?"Stop Loss":"Take Profit";
         Print(informacoes);
        }

     }//End TRANSACTIONS DEAL ADD
   if(type==TRADE_TRANSACTION_HISTORY_ADD)
     {

      ulong order_ticket=trans.order;
      myorder.SelectByIndex(order_ticket);
      mydeal.SelectByIndex(trans.deal);
      myposition.SelectByTicket(trans.position);

      //Stop para posição comprada
      if(order_ticket==compra1_ticket && trans.order_state==ORDER_STATE_FILLED)

        {

         if(TakeType==Pontos)mytake=NormalizeDouble(myposition.PriceOpen()+_TakeProfit*ponto,digits);
         else mytake=NormalizeDouble(MathRound((myposition.PriceOpen()*(1+_TakeProfit/100))/ticksize)*ticksize,digits);
         mytrade.PositionModify(compra1_ticket,0,mytake);
         if(StopType==Pontos) sellprice=NormalizeDouble(myposition.PriceOpen()-_Stop*ponto,digits);
         else sellprice=NormalizeDouble(MathRound((myposition.PriceOpen()*(1-_Stop/100))/ticksize)*ticksize,digits);
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

        }

      //Stop para posição vendida
      if(order_ticket==venda1_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         if(TakeType==Pontos)mytake=NormalizeDouble(myposition.PriceOpen()-_TakeProfit*ponto,digits);
         else mytake=NormalizeDouble(MathRound((myposition.PriceOpen()*(1-_TakeProfit/100))/ticksize)*ticksize,digits);
         mytrade.PositionModify(venda1_ticket,0,mytake);

         if(StopType==Pontos) buyprice=NormalizeDouble(myposition.PriceOpen()+_Stop*ponto,digits);
         else buyprice=NormalizeDouble(MathRound((myposition.PriceOpen()*(1+_Stop/100))/ticksize)*ticksize,digits);

         oldprice=PriceLastStopOrder(ORDER_TYPE_BUY_STOP);
         if(oldprice==-1 || buyprice<oldprice && Sell_opened()) // No order or New price is better
           {
            DeleteOrders(ORDER_TYPE_BUY_STOP);
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



//+-------------ROTINAS----------------------------------------------+

void Main_Program()
  {

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   stoch.Refresh();

   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }
   GetPositionProperties();

   bool novodia;
   novodia=NewBar.CheckNewBar(Symbol(),PERIOD_D1);
   if(novodia)
     {
      ENTRADAS_TOTAL=0;
      tradeOn=true;
      Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");
      informacoes=" ";

     }

   lucro_total=LucroOrdens()+LucroPositions();

   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
      informacoes="EA encerrado lucro ou prejuizo";
     }

   timerOn=false;
   if(UseTimer==true)
     {
      timerOn=Timer.DailyTimer(StartHour,StartMinute,EndHour,EndMinute);
     }
   else
     {
      timerOn=true;
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

     {// inicio Trade On


      if(NewBar.CheckNewBar(Symbol(),periodoRobo))
        {
         if(BuySignal() && !Buy_opened())
           {
            if(PositionsTotal()>0)CloseALL();
            if(OrdersTotal()>0)
              {
               DeleteOrders(ORDER_TYPE_SELL_STOP);
               DeleteOrders(ORDER_TYPE_BUY_STOP);
              }
            mytrade.Buy(Lot,Symbol(),0,0,0,"BUY"+exp_name);
            trade_ticket=mytrade.ResultOrder();
            compra1_ticket=trade_ticket;
           }

         if(SellSignal() && !Sell_opened())
           {
            if(PositionsTotal()>0)CloseALL();
            if(OrdersTotal()>0)
              {
               DeleteOrders(ORDER_TYPE_SELL_STOP);
               DeleteOrders(ORDER_TYPE_BUY_STOP);
              }

            mytrade.Sell(Lot,Symbol(),0,0,0,"SELL"+exp_name);

            trade_ticket=mytrade.ResultOrder();
            venda1_ticket=trade_ticket;
           }
        }//Fim NewBar
      if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);

     }//End Trade On
   else
     {
      if(Daytrade==true)
        {
         DeleteALL();
         CloseALL();
        }
     } // fechou ordens pendentes no Day trade fora do horario

//Comentarios();

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
   bool b_signal,buy_1,buy_2;
   buy_1=low[2]<=Donchian_Low[1]+15*ponto && close[1]>Donchian_Low[1] && stoch.Main(1)>stoch.Main(2) && stoch.Main(1)<25;  //Reversão
   buy_2=close[1]>Donchian_High[2] && stoch.Main(1)>stoch.Main(2) && stoch.Main(1)>75;//Rompimento

   b_signal=buy_1 || buy_2;

   return b_signal;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   bool s_signal,sell_1,sell_2;
   sell_1=high[2]>=Donchian_High[1]-15*ponto && close[1]<Donchian_High[1] && stoch.Main(1)<stoch.Main(2) && stoch.Main(1)>75;//Reversao
   sell_2=close[1]<Donchian_Low[2] && stoch.Main(1)<stoch.Main(2) && stoch.Main(1)<25;//Rompimento

   s_signal=sell_1 || sell_2;
   return s_signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
//|                                                                  |
//+------------------------------------------------------------------+

void Comentarios()
  {
   string s_coment=""+"\n"+"RESULTADO DIÁRIO $: "+DoubleToString(lucro_total,2)+"\n";
   s_coment+="ENTRADAS NO DIA: "+IntegerToString(ENTRADAS_TOTAL)+"\n";
   s_coment+=original_symbol+": "+DoubleToString(VarDiaria(),2)+" %"+"\n";

   s_coment+=informacoes;
   Comment(s_coment);

  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(donchian_handle,0,0,5,Donchian_High)<=0 || 
         CopyBuffer(donchian_handle,2,0,5,Donchian_Low)<=0 || 
         CopyHigh(Symbol(),periodoRobo,0,5,high)<=0 ||
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
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && myposition.Symbol()==mysymbol.Name())
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcPontos(double profit)
  {
   double pontos;
   double cont_size=mysymbol.ContractSize();
   double den=((mysymbol.TickValue()*Lot)/mysymbol.TickSize());
   pontos=cont_size*profit/den;
   return(pontos);
  }
//+------------------------------------------------------------------+
double VarDiaria()
  {
   double fec_ant[1];
   double variacao;
   CopyClose(original_symbol,PERIOD_D1,1,1,fec_ant);
   variacao=(close[0]-fec_ant[0])/fec_ant[0];
   variacao=variacao*100;
   return variacao;
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
//|                                                                  |
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
   pos_resultado=DoubleToString(lucro_total,2);
   pos_entradas=IntegerToString(ENTRADAS_TOTAL);
//---
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
   CreateEdit(0,0,"InfoPanelBackground","",corner,font_name,8,clrBlack,170,100,10,y_bg,0,clrCornflowerBlue,true);
//--- Header of the info panel
   CreateEdit(0,0,"InfoPanelHeader",MQLInfoString(MQL_PROGRAM_NAME),corner,font_name,8,clrWhite,170,14,10,y_bg,1,clrFireBrick,true);
//--- List of the names of position properties and their values
//    Property name
   CreateLabel(0,0,pos_prop_names[0],"Resultado Diario :",anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[0],2);
//    Property value
   CreateLabel(0,0,pos_prop_values[0],GetPropertyValue(0),anchor,corner,font_name,font_size,font_color,x_second_column+30,y_prop_array[0],2);
//---

   CreateLabel(0,0,pos_prop_names[1],"Entradas :",anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[1],2);
   CreateLabel(0,0,pos_prop_values[1],GetPropertyValue(2),anchor,corner,font_name,font_size,font_color,x_second_column,y_prop_array[1],2);
//---

//---
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

   switch(number)
     {
      case 0  : return(DoubleToString(lucro_total,2));      break;
      case 1  : return(IntegerToString(ENTRADAS_TOTAL));    break;

      default : return(empty);

     }
  }
//+------------------------------------------------------------------+
