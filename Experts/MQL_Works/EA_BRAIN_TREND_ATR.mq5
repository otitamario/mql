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
#include <Controls\Dialog.mqh>

#define INFOPANEL_SIZE 4 // Size of the array for info panel objects
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

// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input string simbolo="WINQ18";//Simbolo Original
input ulong Magic_Number=5072018;
input ulong deviation_points=1;//Deviation em Pontos(Padrao)
input double Lot=1000;//Lote Entrada
input double _Stop=150;//Stop Loss em Pontos
input double _TakeProfit=2500; //Take Profit em Pontos
input double ptsromp=15;//Pontos Rompimento
sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";
input bool UsarLucro=false;//Usar Lucro para Fechamento True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes
input double valor_corret=0.25;// Valor Corretagem

sinput string STrailing="############---------------Trailing Stop----------########";

input bool   Use_TraillingStop=true; //Usar Trailing 
input int TraillingStart=0;//Lucro Minimo Iniciar trailing stop
input int TraillingDistance=10;// Distanccia em Pontos do Stop Loss
input int TraillingStep=3;// Passo para atualizar Stop Loss

sinput string shorario="############------FILTRO DE HORARIO------#################";

input bool UseTimer = true;
input int StartHour = 9;//Hora de Inicio
input int StartMinute=0;//Minuto de Inicio

sinput string horafech="HORARIO PARA FECHAMENTO DE POSICOES E ORDENS";
input int EndHour=17;//Hora de Fechamento
input int EndMinute=00;//Minuto de Fechamento
input bool Daytrade=true;// Fechar posicoes Daytrade fim do dia

sinput string sindic="############------Indicators------#################";
input int ATR_Period=7;
input uint   Length=10;           // Indicator period
input uint   ATRPeriod=5;         // Period of ATR
input double Kv=2.5;              // Volatility by ATR
input int    Shift=0;             // Horizontal shift of the indicator in bars
input ENUM_TIMEFRAMES TIMEFRAME_ATR=PERIOD_M5;//TIMEFRAME ATR



                                  //Variaveis 
string original_symbol;
double ask,bid;
double lucro_total,pontos_total,lucro_liquido;
bool timerOn,tradeOn;
double ponto,ticksize,digits;
long curChartID;
int atr_handle;
double ATR_High[],ATR_Low[];

int brain_handle;
double BrainUp[],BrainDown[];
double high[],low[],open[],close[];
ulong ENTRADAS_TOTAL;
ulong trade_ticket,compra1_ticket,venda1_ticket,stp_venda_ticket,stp_compra_ticket,tkp_venda_ticket,tkp_compra_ticket;

ulong nsubwindows,nchart_stoch;
double buyprice,sellprice,oldprice;
string informacoes=" ";
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
int PrevPositions;
datetime time_novodia[4];
double lotes_stop;
int res_code;

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
   "name_liquido",
   "name_entradas",
   "name_variacao"
  };
// Array of names of objects that display values of position properties
string pos_prop_values[INFOPANEL_SIZE]=
  {
   "value_resultado",
   "value_liquido",
   "value_entradas",
   "value_variacao"
  };
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   original_symbol=simbolo;
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

   brain_handle=iCustom(Symbol(),periodoRobo,"braintrend2sig",ATR_Period);
   ChartIndicatorAdd(curChartID,0,brain_handle);

   ArraySetAsSeries(BrainDown,true);
   ArraySetAsSeries(BrainUp,true);
   atr_handle=iCustom(Symbol(),TIMEFRAME_ATR,"atrstops_v1",Length,ATRPeriod,Kv,Shift);

   ChartIndicatorAdd(curChartID,0,atr_handle);

   ArraySetAsSeries(ATR_High,true);
   ArraySetAsSeries(ATR_Low,true);

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

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeletaIndicadores();

   IndicatorRelease(brain_handle);
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
   double price_deal;
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
      myorder.Select(order_ticket);
      myposition.SelectByTicket(trans.position);

      //Stop para posição comprada
      if(order_ticket==compra1_ticket && trans.order_state==ORDER_STATE_FILLED)

        {
         if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Sell_opened())
           {
            res_code=-1;
            while(res_code<=0)
              {
               mytrade.PositionCloseBy(compra1_ticket,venda1_ticket);
               res_code=mytrade.ResultOrder();
               Print("RES_CODE ",res_code);
              }
           }

         mytrade.PositionModify(compra1_ticket,0,NormalizeDouble(myposition.PriceOpen()+_TakeProfit*ponto,digits));
         sellprice=NormalizeDouble(myposition.PriceOpen()-_Stop*ponto,digits);
         oldprice=PriceLastStopOrder(ORDER_TYPE_SELL_STOP);
         if(oldprice==-1 || sellprice>oldprice && Buy_opened()) // No order or New price is better
           {
            DeleteOrders(ORDER_TYPE_SELL_STOP);
            res_code=-1;
            while(res_code<=0)
              {

               mytrade.SellStop(Lot,sellprice,original_symbol,0,0,0,0,"STOP"+exp_name);
               stp_venda_ticket=mytrade.ResultOrder();
               res_code=mytrade.ResultOrder();
               Print("RES_CODE ",res_code);
               if(res_code==0)
                 {
                  myposition.SelectByTicket(compra1_ticket);
                  sellprice=NormalizeDouble(myposition.PriceOpen()-_Stop*ponto,digits);

                 }
              }
           }

        }
      //--------------------------------------------------
      if(order_ticket==stp_venda_ticket && trans.order_type==ORDER_TYPE_SELL_STOP && trans.order_state==ORDER_STATE_FILLED)
        {
         informacoes="Posicao Fechada por Ordem Sell Stop";
         Print(informacoes);
         if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
           {
            res_code=-1;
            while(res_code<=0)
              {
               mytrade.PositionCloseBy(compra1_ticket,stp_venda_ticket);
               res_code=mytrade.ResultOrder();
               Print("RES_CODE ",res_code);

              }
           }

        }

      //Stop para posição vendida
      if(order_ticket==venda1_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened())
           {
            res_code=-1;
            while(res_code<=0)
              {
               mytrade.PositionCloseBy(compra1_ticket,venda1_ticket);
               res_code=mytrade.ResultOrder();
               Print("RES_CODE ",res_code);

              }
           }

         mytrade.PositionModify(venda1_ticket,0,NormalizeDouble(myposition.PriceOpen()-_TakeProfit*ponto,digits));
         buyprice=NormalizeDouble(myposition.PriceOpen()+_Stop*ponto,digits);
         oldprice=PriceLastStopOrder(ORDER_TYPE_BUY_STOP);
         if(oldprice==-1 || buyprice<oldprice && Sell_opened()) // No order or New price is better
           {
            DeleteOrders(ORDER_TYPE_BUY_STOP);
            res_code=-1;
            while(res_code<=0)
              {

               mytrade.BuyStop(Lot,buyprice,original_symbol,0,0,0,0,"STOP"+exp_name);
               stp_compra_ticket=mytrade.ResultOrder();
               res_code=mytrade.ResultOrder();
               Print("RES_CODE ",res_code);
               if(res_code==0)
                 {
                  myposition.SelectByTicket(venda1_ticket);
                  buyprice=NormalizeDouble(myposition.PriceOpen()+_Stop*ponto,digits);

                 }
              }

           }
        }
      //--------------------------------------------------
      if(order_ticket==stp_compra_ticket && trans.order_type==ORDER_TYPE_BUY_STOP && trans.order_state==ORDER_STATE_FILLED)
        {
         informacoes="Posicao Fechada por Ordem Buy Stop";
         Print(informacoes);
         if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
           {
            res_code=-1;
            while(res_code<=0)
              {
               mytrade.PositionCloseBy(venda1_ticket,stp_compra_ticket);
               res_code=mytrade.ResultOrder();
               Print("RES_CODE ",res_code);

              }
           }

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

   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }
   GetPositionProperties();

   bool novodia;
   novodia=NewBar.CheckNewBar(original_symbol,PERIOD_D1);
   if(novodia)
     {
      ENTRADAS_TOTAL=0;
      tradeOn=true;
      Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");
      informacoes=" ";

     }

   lucro_total=LucroOrdens()+LucroPositions();
   lucro_liquido=lucro_total-Corretagem(1.5*valor_corret);

   if(UsarLucro && (lucro_liquido>=lucro || lucro_liquido<=-prejuizo))
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

      //  if(CheckBuyClose() && Buy_opened())ClosePosType(POSITION_TYPE_BUY);
      // if(CheckSellClose() && Sell_opened())ClosePosType(POSITION_TYPE_SELL);
      if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
        {

         if(myposition.SelectByTicket(compra1_ticket) && myposition.SelectByTicket(stp_venda_ticket))
           {
            res_code=-1;
            while(res_code<=0)
              {
               mytrade.PositionCloseBy(compra1_ticket,stp_venda_ticket);
               res_code=mytrade.ResultOrder();
               Print("RES CODE ",res_code);
              }
           }
         if(myposition.SelectByTicket(venda1_ticket) && myposition.SelectByTicket(stp_compra_ticket))
           {
            res_code=-1;
            while(res_code<=0)
              {
               mytrade.PositionCloseBy(venda1_ticket,stp_compra_ticket);
               res_code=mytrade.ResultOrder();
               Print("RES CODE ",res_code);
              }
           }
         if(myposition.SelectByTicket(compra1_ticket) && myposition.SelectByTicket(venda1_ticket))
           {
            res_code=-1;
            while(res_code<=0)
              {
               mytrade.PositionCloseBy(compra1_ticket,venda1_ticket);
               res_code=mytrade.ResultOrder();
               Print("RES CODE ",res_code);
              }
           }
        }
      if(NewBar.CheckNewBar(Symbol(),periodoRobo))
        {

         if(BuySignal() && !Buy_opened())
           {

            if(ATR_High[1]<EMPTY_VALUE && close[0]>ATR_High[1])
              {
               if(Sell_opened())ClosePosType(POSITION_TYPE_SELL);
               if(OrdersTotal()>0)
                 {
                  DeleteOrders(ORDER_TYPE_SELL_STOP);
                  DeleteOrders(ORDER_TYPE_BUY_STOP);
                 }
               mytrade.Buy(Lot,original_symbol,0,0,0,"BUY"+exp_name);
               trade_ticket=mytrade.ResultOrder();
               compra1_ticket=trade_ticket;
              }
            if(ATR_Low[1]<EMPTY_VALUE && close[0]<ATR_Low[1])
              {
               if(!PosicaoAberta())DeleteOrders(ORDER_TYPE_SELL_STOP);
               buyprice=NormalizeDouble(MathRound(ATR_Low[1]/ticksize)*ticksize+ptsromp*ponto,digits);
               oldprice=PriceLastStopOrder(ORDER_TYPE_BUY_STOP);
               if(oldprice==-1 || buyprice<oldprice) // No order or New price is better
                 {
                  DeleteOrders(ORDER_TYPE_BUY_STOP);
                  if(Sell_opened())lotes_stop=2*Lot;
                  else lotes_stop=Lot;
                  mytrade.BuyStop(lotes_stop,buyprice,original_symbol,0,0,0,0,"BUY"+exp_name);
                  trade_ticket=mytrade.ResultOrder();
                  compra1_ticket=trade_ticket;
                 }

              }

           }

         if(SellSignal() && !Sell_opened())
           {
            if(ATR_Low[1]<EMPTY_VALUE && close[0]<ATR_Low[1])
              {
               if(Buy_opened())ClosePosType(POSITION_TYPE_BUY);
               if(OrdersTotal()>0)
                 {
                  DeleteOrders(ORDER_TYPE_SELL_STOP);
                  DeleteOrders(ORDER_TYPE_BUY_STOP);
                 }

               mytrade.Sell(Lot,original_symbol,0,0,0,"SELL"+exp_name);

               trade_ticket=mytrade.ResultOrder();
               venda1_ticket=trade_ticket;
              }
            if(ATR_High[1]<EMPTY_VALUE && close[0]>ATR_High[1] && ATR_High[1]>0)
              {
               if(!PosicaoAberta())DeleteOrders(ORDER_TYPE_BUY_STOP);
               sellprice=NormalizeDouble(MathRound(ATR_High[1]/ticksize)*ticksize-ptsromp*ponto,digits);
               oldprice=PriceLastStopOrder(ORDER_TYPE_SELL_STOP);
               if(oldprice==-1 || sellprice>oldprice) // No order or New price is better
                 {
                  DeleteOrders(ORDER_TYPE_SELL_STOP);
                  if(Buy_opened())lotes_stop=2*Lot;
                  else lotes_stop=Lot;
                  mytrade.SellStop(lotes_stop,sellprice,original_symbol,0,0,0,0,"SELL"+exp_name);
                  trade_ticket=mytrade.ResultOrder();
                  venda1_ticket=trade_ticket;
                 }

              }

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
   bool signal;
   signal=BrainUp[1]>0;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   bool signal;
   signal=BrainDown[1]>0;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckSellClose()
  {
   bool signal=BrainUp[1]>0;
   return signal;
  }
//+------------------------------------------------------------------+
//| Buy Close conditions                                                  |
//+------------------------------------------------------------------+
bool CheckBuyClose()
  {
   bool signal=BrainDown[1]>0;
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
   b_get=CopyBuffer(brain_handle,0,0,5,BrainDown)<=0 || 
         CopyBuffer(brain_handle,1,0,5,BrainUp)<=0 || 
         CopyBuffer(atr_handle,0,0,5,ATR_High)<=0 || 
         CopyBuffer(atr_handle,1,0,5,ATR_Low)<=0 || 
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
   if(myposition.SelectByMagic(original_symbol,Magic_Number)==true)
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
               if(myorder.Select(stp_venda_ticket)) mytrade.OrderModify(stp_venda_ticket,trailStopPrice,0,0,0,0,0);
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
               if(myorder.Select(stp_compra_ticket))mytrade.OrderModify(stp_compra_ticket,trailStopPrice,0,0,0,0,0);

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
   pos_liquido=DoubleToString(lucro_liquido,2);
   pos_entradas=IntegerToString(ENTRADAS_TOTAL);
   pos_variacao=DoubleToString(VarDiaria(),2);
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
   CreateLabel(0,0,pos_prop_names[1],"Resultado Liquido :",anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[1],2);
//    Property value
   CreateLabel(0,0,pos_prop_values[1],GetPropertyValue(1),anchor,corner,font_name,font_size,font_color,x_second_column+30,y_prop_array[1],2);
//---

   CreateLabel(0,0,pos_prop_names[2],"Entradas :",anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[2],2);
   CreateLabel(0,0,pos_prop_values[2],GetPropertyValue(2),anchor,corner,font_name,font_size,font_color,x_second_column,y_prop_array[2],2);
//---
   CreateLabel(0,0,pos_prop_names[3],"Variacao "+original_symbol+" : ",anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[3],2);
   CreateLabel(0,0,pos_prop_values[3],GetPropertyValue(3),anchor,corner,font_name,font_size,font_color,x_second_column+30,y_prop_array[3],2);
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
      case 1  : return(DoubleToString(lucro_liquido,2));      break;
      case 2  : return(IntegerToString(ENTRADAS_TOTAL));    break;
      case 3  : return(DoubleToString(VarDiaria(),2));      break;

      default : return(empty);

     }
  }
//+------------------------------------------------------------------+
