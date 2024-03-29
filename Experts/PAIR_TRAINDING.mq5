//+------------------------------------------------------------------+
//|                                                     Junio_v3.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
enum Operacao
  {
   Diferenca=1,  //Diferenca
   Razao=2       //Razao
  };

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>


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
input ulong Magic_Number=15062018;
input ulong deviation_points=100;//Deviation in Points
input double Lot=1;//Lote Ativo 1
input double Lot2=2;//Lote Ativo 2

input double _Stop=150;//Fixed Stop Loss in Points
input string ativo_dol="WDON18";//Codigo DOLAR
input string ativo_ind="WINQ18";//Codigo INDICE
sinput string STrailing="############---------------Trailing Stop----------########";

input bool   Use_TraillingStop=false; //Use Trailing Stop True/False
input int TraillingStart=0;//Minimum Profit to start trailing stop
input int TraillingDistance=100;// Stop loss distance in Points to price
input int TraillingStep=10;// Step in Points to update Stop Loss

sinput string Lucro="###----Profit in currency Daily Objetcive/Stop----#####";
input bool UsarLucro=false;//Use Profit Currency True/False
input double lucro=1000.0;//Profit to Close Plositions
input double prejuizo=500.0;//Loss to Close Positions

sinput string sindic="############------Indicators------#################";
input int HMA_Period=13;  // HMA period 

input datetime BeginTime=D'2018.06.12'; //Data inicial
input string   Symbol1="WDO_2POINTS";       //Papel 1
input string   Symbol2="WIN_50POINTS";       //Papel 2
input Operacao Action         =  Razao;         //Operacao
input bool     Invert1        =  false;         //Inverter papel 1
input bool     Invert2        =  false;         //Inverter papel 2
input double   Multi1         =  1;             //Multiplicador papel 1
input double   Multi2         =  1;             //Multiplicador papel 2
input uint     Window         =  100;           //Numero de barras considerado
input bool     ShowBands      =  true;          //Mostrar Bandas de Bollinger
input int      BandsPeriod    =  40;            //Periodo para as BB
input double   BandsDev       =  1.5;           //Desvio Padrao para as BB
input bool     PushNotify     =  false;         //Enviar notificacoes push
input double   LoLevelNotify  =  0.1;           //Limite inferior para envio de notificacao
input double   HiLevelNotify  =  5.0;           //Limite superior para envio de notificacao

                                                //Variaveis 
string original_symbol;
double ask,bid;
double lucro_total,pontos_total;
bool tradeOn;
double ponto,ticksize,digits;
long curChartID;
int ratioDOL_IND_handle;
double ratioDOL_IND_buffer[],UpperBB_DOL_IND[],LowerBB_DOL_IND[],MedBB_DOL_IND[];
int ratioIND_DOL_handle;
double ratioIND_DOL_buffer[],UpperBB_IND_DOL[],LowerBB_IND_DOL[],MedBB_IND_DOL[];
int hmaDOL_handle;
double hmaDOL_buffer[];
int hmaIND_handle;
double hmaIND_buffer[];
double high[],low[],open[],close[];
ulong ENTRADAS_TOTAL;
ulong trade_ticket,compra1_ticket,venda1_ticket,stp_venda_ticket,stp_compra_ticket;
ulong nsubwindows,nchart_adx;
double buyprice,sellprice,oldprice;
string informacoes;
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME)+"_"+Symbol();
int PrevPositions;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   original_symbol=ativo_ind;
   tradeOn=true;
   trade_ticket=0;
   ENTRADAS_TOTAL=0;
//mysymbol.Name();
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
// ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
// ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
//digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);
   lucro_total=0.0;
   pontos_total=0.0;
   curChartID=ChartID();
   ratioDOL_IND_handle=iCustom(Symbol1,periodoRobo,"LSRatio",BeginTime,Symbol1,Symbol2,Action,Invert1,Invert2,Multi1,Multi2,Window,ShowBands,BandsPeriod,BandsDev,PushNotify,LoLevelNotify,HiLevelNotify);
   ratioIND_DOL_handle=iCustom(Symbol2,periodoRobo,"LSRatio",BeginTime,Symbol2,Symbol1,Action,Invert1,Invert2,Multi1,Multi2,Window,ShowBands,BandsPeriod,BandsDev,PushNotify,LoLevelNotify,HiLevelNotify);
   ulong newChartID=ChartOpen(Symbol1,periodoRobo);
   ChartIndicatorAdd(newChartID,1,ratioDOL_IND_handle);
   ChartIndicatorAdd(curChartID,1,ratioIND_DOL_handle);

   hmaDOL_handle=iCustom(Symbol1,periodoRobo,"colorhma",HMA_Period,0);
   ChartIndicatorAdd(newChartID,0,hmaDOL_handle);
   hmaIND_handle=iCustom(Symbol2,periodoRobo,"colorhma",HMA_Period,0);
   ChartIndicatorAdd(curChartID,0,hmaIND_handle);

   ArraySetAsSeries(hmaDOL_buffer,true);
   ArraySetAsSeries(hmaIND_buffer,true);

   ArraySetAsSeries(ratioDOL_IND_buffer,true);
   ArraySetAsSeries(UpperBB_DOL_IND,true);
   ArraySetAsSeries(LowerBB_DOL_IND,true);
   ArraySetAsSeries(MedBB_DOL_IND,true);

   ArraySetAsSeries(ratioIND_DOL_buffer,true);
   ArraySetAsSeries(UpperBB_IND_DOL,true);
   ArraySetAsSeries(LowerBB_IND_DOL,true);
   ArraySetAsSeries(MedBB_IND_DOL,true);

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

// parametros incorretos desnecessarios na otimizacao

   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeletaIndicadores();

   IndicatorRelease(ratioDOL_IND_handle);
   IndicatorRelease(ratioIND_DOL_handle);
   IndicatorRelease(hmaDOL_handle);
   IndicatorRelease(hmaIND_handle);

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

//--- get transaction type as enumeratioDOL_INDn value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history

   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      ulong order_ticket=trans.order;

      if(order_ticket==trade_ticket && trans.deal_type!=DEAL_TYPE_BALANCE)ENTRADAS_TOTAL++;

     }//End TRANSACTIONS DEAL ADD

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

   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

   bool novodia;
   novodia=NewBar.CheckNewBar(original_symbol,PERIOD_D1);
   if(novodia)
     {
      ENTRADAS_TOTAL=0;
      tradeOn=true;
      Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");
      informacoes="";
     }

   lucro_total=LucroOrdens()+LucroPositions();

   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
      informacoes="EA encerrado lucro ou prejuizo";
     }

//Atualizacao das Cotacoes----ticks
   MqlTick last_tick;
   if(SymbolInfoTick(original_symbol,last_tick))
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

   if(tradeOn)//Begin Trade On
     {
      Check_BuyDOLSellIND_Close();
      Check_BuyINDSellDOL_Close();
      if(NewBar.CheckNewBar(Symbol(),periodoRobo))
        {

         if(BuyDOLSellIND())
           {
            if(PositionsTotal()>0)CloseALL();

            mytrade.Buy(Lot,ativo_dol);
            trade_ticket=mytrade.ResultOrder();
            mytrade.Sell(Lot2,ativo_ind);

           }

         if(BuyINDSellDOL())
           {
            if(PositionsTotal()>0)CloseALL();
            mytrade.Buy(Lot2,ativo_ind);
            trade_ticket=mytrade.ResultOrder();
            mytrade.Sell(Lot,ativo_dol);

           }

         //*********************************************************************************************

        }//Fim NewBar

      // Trailing stop

      if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);

     }//End Trade On
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
bool BuyDOLSellIND()
  {
   bool signal,s1,s2;
   s1=ratioDOL_IND_buffer[2]<LowerBB_DOL_IND[2]&&ratioDOL_IND_buffer[1]>LowerBB_DOL_IND[1];
   s2=ratioIND_DOL_buffer[2]>UpperBB_IND_DOL[2]&&ratioIND_DOL_buffer[1]<UpperBB_IND_DOL[1];
   signal=(s1 || s2)&& (hmaDOL_buffer[1]==1.0 && hmaIND_buffer[1]==2.0);
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BuyINDSellDOL()
  {
   bool signal,s1,s2;
   s1=ratioIND_DOL_buffer[2]<LowerBB_IND_DOL[2]&&ratioIND_DOL_buffer[1]>LowerBB_IND_DOL[1];
   s2=ratioDOL_IND_buffer[2]>UpperBB_DOL_IND[2]&&ratioDOL_IND_buffer[1]<UpperBB_DOL_IND[1];
   signal=(s1 || s2) && (hmaIND_buffer[1]==1.0 && hmaDOL_buffer[1]==2.0);

   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Check_BuyDOLSellIND_Close()
  {
   bool comprado_dolar=false;
   if(PositionsTotal()>0)
     {
      for(int i=PositionsTotal()-1;i>=0; i--)
         if(myposition.SelectByIndex(i) && myposition.Symbol()==ativo_dol && myposition.Magic()==Magic_Number && myposition.Type()==POSITION_TYPE_BUY)
            comprado_dolar=true;

     }
   if(comprado_dolar && ratioDOL_IND_buffer[2]<LowerBB_DOL_IND[2] && ratioDOL_IND_buffer[1]<LowerBB_DOL_IND[1] && hmaDOL_buffer[1]==2.0)CloseALL();
   if(comprado_dolar && ratioIND_DOL_buffer[2]>UpperBB_IND_DOL[2] && ratioIND_DOL_buffer[1]>UpperBB_IND_DOL[1] && hmaIND_buffer[1]==1.0)CloseALL();


  }
//+------------------------------------------------------------------+
//| Buy Close conditions                                                  |
//+------------------------------------------------------------------+
void Check_BuyINDSellDOL_Close()
  {
   bool comprado_ind=false;
   if(PositionsTotal()>0)
     {
      for(int i=PositionsTotal()-1;i>=0; i--)
         if(myposition.SelectByIndex(i) && myposition.Symbol()==ativo_ind && myposition.Magic()==Magic_Number && myposition.Type()==POSITION_TYPE_BUY)
            comprado_ind=true;

     }
   if(comprado_ind && ratioIND_DOL_buffer[2]<LowerBB_IND_DOL[2] && ratioIND_DOL_buffer[1]<LowerBB_IND_DOL[1] && hmaIND_buffer[1]==2.0)CloseALL();
   if(comprado_ind && ratioDOL_IND_buffer[2]>UpperBB_DOL_IND[2] && ratioDOL_IND_buffer[1]>UpperBB_DOL_IND[1] && hmaDOL_buffer[1]==1.0)CloseALL();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Comentarios()
  {
   string s_coment=""+"\n"+"RESULTADO DIÁRIO $: "+DoubleToString(lucro_total,2)+"\n";
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
   b_get=CopyBuffer(hmaDOL_handle,1,0,4,hmaDOL_buffer)<=0 || 
         CopyBuffer(hmaIND_handle,1,0,4,hmaIND_buffer)<=0 || 
         CopyBuffer(ratioDOL_IND_handle,0,0,5,ratioDOL_IND_buffer)<=0 || 
         CopyBuffer(ratioDOL_IND_handle,1,0,5,UpperBB_DOL_IND)<=0 || 
         CopyBuffer(ratioDOL_IND_handle,2,0,5,MedBB_DOL_IND)<=0 || 
         CopyBuffer(ratioDOL_IND_handle,3,0,5,LowerBB_DOL_IND)<=0 || 
         CopyBuffer(ratioIND_DOL_handle,0,0,5,ratioIND_DOL_buffer)<=0 || 
         CopyBuffer(ratioIND_DOL_handle,1,0,5,UpperBB_IND_DOL)<=0 || 
         CopyBuffer(ratioIND_DOL_handle,2,0,5,MedBB_IND_DOL)<=0 || 
         CopyBuffer(ratioIND_DOL_handle,3,0,5,LowerBB_IND_DOL)<=0 || 
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
