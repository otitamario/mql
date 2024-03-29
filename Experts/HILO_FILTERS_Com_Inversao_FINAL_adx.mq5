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


//Classes
CNewBar NewBar;
CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
CiMA *ema;
CiADX *adx;
// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=11062018;
input ulong deviation_points=100;//Deviation in Points
input double Lot=2;//Lote Entrada
input double _Stop=150;//Fixed Stop Loss in Points

sinput string STrailing="############---------------Trailing Stop----------########";

input bool   Use_TraillingStop=true; //Use Trailing Stop True/False
input int TraillingStart=0;//Minimum Profit to start trailing stop
input int TraillingDistance=100;// Stop loss distance in Points to price
input int TraillingStep=10;// Step in Points to update Stop Loss

sinput string Lucro="###----Profit in currency Daily Objetcive/Stop----#####";
input bool UsarLucro=true;//Use Profit Currency True/False
input double lucro=1000.0;//Profit to Close Plositions
input double prejuizo=500.0;//Loss to Close Positions

sinput string SPontos="#####--------Profit in Points------########";
input bool UsarLucroPoints=true;//Use Profit in Points True/False
input double lucroPoints=300.0;//Profit Points to Close Plositions
input double prejuizoPoints=300.0;//Loss Points to Close Positions

sinput string shorario="############------TIME FILTER------#################";

sinput string horafech="Friday Time Filter to Close Orders and Positions";
input bool UseTimer=true;// Use Friday Time Filter True/False
input int EndHour=17;//Friday Hour to Close Orders and Positions
input int EndMinute=30;//Friday Minute  to Close Orders and Positions

sinput string sindic="############------Indicators------#################";
input int period_hilo=14;//Periodo Hilo
input ENUM_MA_METHOD InpMethod=MODE_SMMA;// Method Hilo

input bool Use_EMA=true;//Use EMA filter True/False
input int period_ema=9;//EMA Period
input bool Use_ADX=true;//Use ADX creas/decreasing filter True/False
input int period_adx=21;//ADX Period
input bool Use_ADX_MIN=true;//Use Minimum ADX value filter True/False
input double adx_minim=20;//Minimum ADX value
sinput string sinverter="############------Inverter Sinais------#################";
input bool InvertSignals=false;//Invert Signals True/False;

                               //Variaveis 
string original_symbol;
double ask,bid;
double lucro_total,pontos_total;
bool tradeOn;
double ponto,ticksize,digits;
long curChartID;
int hilo_handle;
double hilo_color[],hilo_buffer[];
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
   Print("TRADE CALC MODE ",mysymbol.TradeCalcMode());
   Print("CONTRATC SIZE ",mysymbol.ContractSize()," TICK VALUE ",mysymbol.TickValueProfit()," TICK SIZE ",mysymbol.TickSize()," PONTO",mysymbol.Point());
   lucro_total=0.0;
   pontos_total=0.0;
   curChartID=ChartID();

   ema=new CiMA;
   ema.Create(NULL,periodoRobo,period_ema,0,MODE_EMA,PRICE_CLOSE);
   ema.AddToChart(curChartID,0);
   nsubwindows=ChartGetInteger(curChartID,CHART_WINDOWS_TOTAL);
   nchart_adx=nsubwindows;
   adx=new CiADX;
   adx.Create(NULL,periodoRobo,period_adx);
   adx.AddToChart(curChartID,nchart_adx);

   hilo_handle=iCustom(NULL,periodoRobo,"gann_hi_lo_activator_ssl",period_hilo,InpMethod);
   ChartIndicatorAdd(ChartID(),0,hilo_handle);

   ArraySetAsSeries(hilo_color,true);
   ArraySetAsSeries(hilo_buffer,true);

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

   delete(ema);
   delete(adx);
   IndicatorRelease(hilo_handle);

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
         sellprice=NormalizeDouble(myposition.PriceOpen()-_Stop*ponto,digits);
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
         buyprice=NormalizeDouble(myposition.PriceOpen()+_Stop*ponto,digits);
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

//------------------------------------------------------------------------
//------------------------------------------------------------------------


//+-------------ROTINAS----------------------------------------------+

void Main_Program()
  {

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   ema.Refresh();
   adx.Refresh();

   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

   bool novodia;
   novodia=NewBar.CheckNewBar(Symbol(),PERIOD_D1);
   if(novodia)
     {
      ENTRADAS_TOTAL=0;
      tradeOn=true;
      Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");
      informacoes="";
     }
   if(TimeFridayFilter())
     {
      if(PosicaoAberta())CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
     }

   lucro_total=LucroOrdens()+LucroPositions();
   pontos_total=CalcPontos(lucro_total);

   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
      informacoes="EA encerrado lucro ou prejuizo";
     }

   if(UsarLucroPoints && (pontos_total>=lucroPoints || pontos_total<=-prejuizoPoints))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
      informacoes="EA encerrado lucro ou prejuizo em Pontos";
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

   if(tradeOn)//Begin Trade On
     {
      if(NewBar.CheckNewBar(Symbol(),periodoRobo))
        {
         if(!InvertSignals)
           {
            if(CheckBuyClose() && Buy_opened())
              {
               ClosePosType(POSITION_TYPE_BUY);
              }
            if(CheckSellClose() && Sell_opened())
              {
               ClosePosType(POSITION_TYPE_SELL);
              }
           }
         else
           {
            if(CheckSellClose() && Buy_opened())
              {
               ClosePosType(POSITION_TYPE_BUY);
              }
            if(CheckBuyClose() && Sell_opened())
              {
               ClosePosType(POSITION_TYPE_SELL);
              }
           }

         if(!InvertSignals)
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
           }
         else
           {
            if(SellSignal() && !Buy_opened())
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

            if(BuySignal() && !Sell_opened())
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
bool BuySignal()
  {
   bool signal;
   signal=hilo_color[1]==0.0 && hilo_color[2]==1.0;
   if(Use_EMA)signal=signal&&(ema.Main(2)<ema.Main(1));
   if(Use_ADX)signal=signal&&(adx.Main(1)>adx.Main(2));
   if(Use_ADX_MIN)signal=signal&&(adx.Main(1)>=adx_minim);

   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   bool signal;
   signal=hilo_color[1]==1.0 && hilo_color[2]==0.0;
   if(Use_EMA)signal=signal&&(ema.Main(2)>ema.Main(1));
   if(Use_ADX)signal=signal&&(adx.Main(1)>adx.Main(2));
   if(Use_ADX_MIN)signal=signal&&(adx.Main(1)>=adx_minim);
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckSellClose()
  {
   bool signal=hilo_color[1]==0.0 && hilo_color[2]==1.0;

   return signal;
  }
//+------------------------------------------------------------------+
//| Buy Close conditions                                                  |
//+------------------------------------------------------------------+
bool CheckBuyClose()
  {
   bool signal=hilo_color[1]==1.0 && hilo_color[2]==0.0;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Comentarios()
  {
   bool emac=(ema.Main(1)<ema.Main(0));
   string semac;
   if(emac)semac="EMA is creasing";
   else semac="EMA is decreasing";
   bool badxmin=(adx.Main(1)>=adx_minim);
   bool badxc=(adx.Main(0)>adx.Main(1));
   string sadxc;
   if(badxc) sadxc="ADX is creasing";
   else sadxc="ADX is NOT creasing";
   string sadxmin;
   if(badxmin) sadxmin="ADX >= adxmin";
   else sadxmin="ADX < adxmin";;
   string s_coment=""+"\n"+"RESULTADO DIÁRIO $: "+DoubleToString(lucro_total,2)+"\n";
   s_coment+="RESULTADO DIÁRIO PONTOS: "+DoubleToString(pontos_total,2)+"\n";
   s_coment+="ENTRADAS NO DIA: "+IntegerToString(ENTRADAS_TOTAL)+"\n";
   s_coment+=semac+"\n";
   s_coment+=sadxc+"\n";
   s_coment+=sadxmin+"\n";

   s_coment+=informacoes;
   Comment(s_coment);

  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(hilo_handle,0,0,5,hilo_buffer)<=0 || 
         CopyBuffer(hilo_handle,1,0,5,hilo_color)<=0 || 
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
bool TimeFridayFilter()
  {
   MqlDateTime TimeNow;
   TimeToStruct(TimeCurrent(),TimeNow);
   if( UseTimer && TimeNow.day_of_week == 5 && TimeNow.hour >= EndHour&& TimeNow.min>=EndMinute ) return true;
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
double CalcPontos(double profit)
  {
   double pontos;
   double cont_size=mysymbol.ContractSize();
   double den=((mysymbol.TickValue()*Lot)/mysymbol.TickSize());
   pontos=cont_size*profit/den;
   return(pontos);
  }
//+------------------------------------------------------------------+
