//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include<Trade\AccountInfo.mqh>

//Classes
CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=20082018;
input string simbolo="";//Simbolo Original
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input double Lot=5;//Lote Entrada
input double _Stop=300; //Stop Loss em Pontos
input double _TakeProfit=1000; //Take Profit em Pontos
sinput string SEst_Med="############-------------Indicadores----------########";

input int    period_fast=5;//Período Média Rápida
input int    period_slow=10;//Período Média Lenta

sinput string SAumento="############---------------Aumento de Posição----------########";
input double Lot_entry1=1;//Lotes Entrada 1 (0 não entrar)
input double pts_entry1=50;//Pontos Entrada 1
input double Lot_entry2=1;//Lotes Entrada 2 (0 não entrar)
input double pts_entry2=80;//Pontos Entrada 2 
input double Lot_entry3=1;//Lotes Entrada 3 (0 não entrar)
input double pts_entry3=110;//Pontos Entrada 3

sinput string SRealParc="############---------------Realização Parcial----------########";
input double Lot_parc1=1;//Lotes Entrada 1 (0 não entrar)
input double pts_parc1=50;//Pontos Entrada 1
input double Lot_parc2=1;//Lotes Entrada 2 (0 não entrar)
input double pts_parc2=80;//Pontos Entrada 2
input double Lot_parc3=1;//Lotes Entrada 3 (0 não entrar)
input double pts_parc3=110;//Pontos Entrada 3

                           //Variaveis 

string original_symbol;
double ask,bid;
double ponto,ticksize,digits;
int ma_fast,ma_slow;
double M_FAST[],M_SLOW[];
double high[],low[],open[],close[];
string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string tp_vd_tick="tp_vd_tick"+Symbol()+IntegerToString(Magic_Number),tp_cp_tick="tp_cp_tick"+Symbol()+IntegerToString(Magic_Number);
string stp_vd_tick="stp_vd_tick"+Symbol()+IntegerToString(Magic_Number),stp_cp_tick="stp_cp_tick"+Symbol()+IntegerToString(Magic_Number);

string deals_total="deals_total"+Symbol()+IntegerToString(Magic_Number),deals_total_prev="deals_total_prev"+Symbol()+IntegerToString(Magic_Number);

string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);

double vol_pos,vol_stp,preco_stp;
double sellprice,sl_position,tp_position,buyprice;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   original_symbol=simbolo;

   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.SetDeviationInPoints(deviation_points);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
   mytrade.SetTypeFilling(ORDER_FILLING_RETURN);
   //mytrade.SetAsyncMode(true);
   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);

   ma_fast=iMA(Symbol(),periodoRobo,period_fast,0,MODE_EMA,PRICE_CLOSE);
   ma_slow=iMA(Symbol(),periodoRobo,period_slow,0,MODE_EMA,PRICE_CLOSE);

   ChartIndicatorAdd(ChartID(),0,ma_fast);
   ChartIndicatorAdd(ChartID(),0,ma_slow);

   ArraySetAsSeries(M_FAST,true);
   ArraySetAsSeries(M_SLOW,true);

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

//Global Variables Check

   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0.0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0.0);
   if(!GlobalVariableCheck(stp_vd_tick))GlobalVariableSet(stp_vd_tick,0);
   if(!GlobalVariableCheck(stp_cp_tick))GlobalVariableSet(stp_cp_tick,0);
   if(!GlobalVariableCheck(tp_vd_tick))GlobalVariableSet(tp_vd_tick,0);
   if(!GlobalVariableCheck(tp_cp_tick))GlobalVariableSet(tp_cp_tick,0);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(ma_fast);
   IndicatorRelease(ma_slow);
//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   Main_Program();

  }// fim OnTick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



//+-------------ROTINAS----------------------------------------------+

void Main_Program()
  {
   mysymbol.Refresh();
   mysymbol.RefreshRates();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//Atualizacao das Cotacoes----ticks
   MqlTick last_tick;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!PosicaoAberta())DeleteALL();

   Atual_vol_Stop_Take();
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened())CloseByPosition();

   if(BuySignal() && !PosicaoAberta())
     {
      if(mytrade.Buy(Lot,original_symbol,0,0,0,"BUY"+exp_name))
        {
         Print("BUY Result Order ",mytrade.ResultOrder());
         GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
        }
      else Print("Erro enviar ordem ",GetLastError());
     }

   if(SellSignal() && !PosicaoAberta())
     {
      if(mytrade.Sell(Lot,original_symbol,0,0,0,"SELL"+exp_name))
        {
         Print("Sell Result Order ",mytrade.ResultOrder());
         GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
        }
      else Print("Erro enviar ordem ",GetLastError());

     }

   MytradeTransaction();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//Comentarios();

   MqlDateTime stm_end,time_aux;
   TimeToStruct(TimeCurrent(),stm_end);
   time_aux=stm_end;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);

   if(HistorySelect(tm_start,TimeCurrent()))
     {
      GlobalVariableSet(deals_total_prev,(double)HistoryDealsTotal());
     }

  }//End Main Program
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   return M_FAST[2]<M_SLOW[2]&&M_FAST[1]>M_SLOW[1];
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   return M_FAST[2]>M_SLOW[2]&&M_FAST[1]<M_SLOW[1];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(ma_fast,0,0,5,M_FAST)<=0 || 
         CopyBuffer(ma_slow,0,0,5,M_SLOW)<=0 || 
         CopyHigh(Symbol(),periodoRobo,0,5,high)<=0 ||
         CopyOpen(Symbol(),periodoRobo,0,5,open)<=0 ||
         CopyLow(Symbol(),periodoRobo,0,5,low)<=0 || 
         CopyClose(Symbol(),periodoRobo,0,5,close)<=0;
   return(b_get);


  }
//+------------------------------------------------------------------+
//|                                                                  |
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
void MytradeTransaction()
  {
   ulong order_ticket;
   MqlDateTime stm_end,time_aux;
   TimeToStruct(TimeCurrent(),stm_end);
   time_aux=stm_end;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);

   if(HistorySelect(tm_start,TimeCurrent()))
     {
      GlobalVariableSet(deals_total,(double)HistoryDealsTotal());
      if(GlobalVariableGet(deals_total)>GlobalVariableGet(deals_total_prev))
        {
         ulong deals_ticket=HistoryDealGetTicket((ulong)GlobalVariableGet(deals_total)-1);
         mydeal.Ticket(deals_ticket);
         order_ticket=mydeal.Order();
         //         Print("order ",order_ticket);
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number)
           {

            if(order_ticket==(ulong)GlobalVariableGet(cp_tick))

              {
               myposition.SelectByTicket(order_ticket);

               buyprice=myposition.PriceOpen();
               sl_position=NormalizeDouble(buyprice-_Stop*ponto,digits);
               tp_position=NormalizeDouble(buyprice+_TakeProfit*ponto,digits);
               mytrade.SellLimit(Lot,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT");
               GlobalVariableSet(tp_vd_tick,(double)mytrade.ResultOrder());
               //Stop para posição comprada
               sellprice=sl_position;
               mytrade.SellStop(Lot,sellprice,Symbol(),0,0,0,0,"STOP"+exp_name);
               GlobalVariableSet(stp_vd_tick,(double)mytrade.ResultOrder());

               Entr_Parcial_Buy(myposition.PriceOpen());
               Saida_Parcial_Buy(myposition.PriceOpen());

              }
            //--------------------------------------------------

            if(order_ticket==(ulong)GlobalVariableGet(vd_tick))
              {
               myposition.SelectByTicket(order_ticket);

               sellprice=myposition.PriceOpen();
               sl_position=NormalizeDouble(sellprice+_Stop*ponto,digits);
               tp_position=NormalizeDouble(sellprice-_TakeProfit*ponto,digits);
               mytrade.BuyLimit(Lot,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT");
               GlobalVariableSet(tp_cp_tick,(double)mytrade.ResultOrder());
               buyprice=sl_position;
               mytrade.BuyStop(Lot,buyprice,Symbol(),0,0,0,0,"STOP"+exp_name);
               GlobalVariableSet(stp_cp_tick,(double)mytrade.ResultOrder());

               Entr_Parcial_Sell(myposition.PriceOpen());
               Saida_Parcial_Sell(myposition.PriceOpen());

              }

           }//Fim mydeal symbol
        }//Fim deals>prev
     }//Fim HistorySelect
  }
//+------------------------------------------------------------------+

void Entr_Parcial_Buy(const double preco)
  {
   if(Lot_entry1>0) mytrade.BuyLimit(Lot_entry1,NormalizeDouble(preco-pts_entry1*ponto,digits),original_symbol,0,0,0,0,"Entrada Parcial");
   if(Lot_entry2>0) mytrade.BuyLimit(Lot_entry2,NormalizeDouble(preco-pts_entry2*ponto,digits),original_symbol,0,0,0,0,"Entrada Parcial");
   if(Lot_entry3>0) mytrade.BuyLimit(Lot_entry3,NormalizeDouble(preco-pts_entry3*ponto,digits),original_symbol,0,0,0,0,"Entrada Parcial");
  }
//+------------------------------------------------------------------+
void Entr_Parcial_Sell(const double preco)
  {
   if(Lot_entry1>0) mytrade.SellLimit(Lot_entry1,NormalizeDouble(preco+pts_entry1*ponto,digits),original_symbol,0,0,0,0,"Entrada Parcial");
   if(Lot_entry2>0) mytrade.SellLimit(Lot_entry2,NormalizeDouble(preco+pts_entry2*ponto,digits),original_symbol,0,0,0,0,"Entrada Parcial");
   if(Lot_entry3>0) mytrade.SellLimit(Lot_entry3,NormalizeDouble(preco+pts_entry3*ponto,digits),original_symbol,0,0,0,0,"Entrada Parcial");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Saida_Parcial_Buy(const double preco)
  {
   if(Lot_parc1>0) mytrade.SellLimit(Lot_parc1,NormalizeDouble(preco+pts_parc1*ponto,digits),original_symbol,0,0,0,0,"Saida Parcial");
   if(Lot_parc2>0) mytrade.SellLimit(Lot_parc2,NormalizeDouble(preco+pts_parc2*ponto,digits),original_symbol,0,0,0,0,"Saida Parcial");
   if(Lot_parc3>0) mytrade.SellLimit(Lot_parc3,NormalizeDouble(preco+pts_parc3*ponto,digits),original_symbol,0,0,0,0,"Saida Parcial");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Saida_Parcial_Sell(const double preco)
  {
   if(Lot_parc1>0) mytrade.BuyLimit(Lot_parc1,NormalizeDouble(preco-pts_parc1*ponto,digits),original_symbol,0,0,0,0,"Saida Parcial");
   if(Lot_parc2>0) mytrade.BuyLimit(Lot_parc2,NormalizeDouble(preco-pts_parc2*ponto,digits),original_symbol,0,0,0,0,"Saida Parcial");
   if(Lot_parc3>0) mytrade.BuyLimit(Lot_parc3,NormalizeDouble(preco-pts_parc3*ponto,digits),original_symbol,0,0,0,0,"Saida Parcial");
  }
//+------------------------------------------------------------------+
void Atual_vol_Stop_Take()
  {

   if(PosicaoAberta())
     {
      if(Buy_opened())
        {
         if(myposition.SelectByTicket((int)GlobalVariableGet(cp_tick)) && myorder.Select((int)GlobalVariableGet(stp_vd_tick)))
           {
            vol_pos=VolPosType(POSITION_TYPE_BUY);
            vol_stp=myorder.VolumeInitial();
            preco_stp=myorder.PriceOpen();

            if(vol_pos!=vol_stp)
              {
               mytrade.OrderDelete((int)GlobalVariableGet(stp_vd_tick));
               mytrade.SellStop(vol_pos,preco_stp,Symbol(),0,0,0,0,"STOP"+exp_name);
               GlobalVariableSet(stp_vd_tick,(double)mytrade.ResultOrder());
              }
           }

         if(myposition.SelectByTicket((int)GlobalVariableGet(cp_tick)) && myorder.Select((int)GlobalVariableGet(tp_vd_tick)))
           {
            vol_pos=VolPosType(POSITION_TYPE_BUY);
            vol_stp=myorder.VolumeInitial();
            preco_stp=myorder.PriceOpen();

            if(vol_pos!=vol_stp)
              {
               mytrade.OrderDelete((int)GlobalVariableGet(tp_vd_tick));
               mytrade.SellLimit(vol_pos,preco_stp,original_symbol,0,0,0,0,"TAKE PROFIT");
               GlobalVariableSet(tp_vd_tick,(double)mytrade.ResultOrder());
              }
           }

        }
      if(Sell_opened())
        {
         if(myposition.SelectByTicket((int)GlobalVariableGet(vd_tick)) && myorder.Select((int)GlobalVariableGet(stp_cp_tick)))
           {
            vol_pos=VolPosType(POSITION_TYPE_SELL);
            vol_stp=myorder.VolumeInitial();
            preco_stp=myorder.PriceOpen();

            if(vol_pos!=vol_stp)
              {
               mytrade.OrderDelete((int)GlobalVariableGet(stp_cp_tick));
               mytrade.BuyStop(vol_pos,preco_stp,Symbol(),0,0,0,0,"STOP"+exp_name);
               GlobalVariableSet(stp_cp_tick,(double)mytrade.ResultOrder());

              }
           }

         if(myposition.SelectByTicket((int)GlobalVariableGet(vd_tick)) && myorder.Select((int)GlobalVariableGet(tp_cp_tick)))
           {
            vol_pos=VolPosType(POSITION_TYPE_SELL);
            vol_stp=myorder.VolumeInitial();
            preco_stp=myorder.PriceOpen();

            if(vol_pos!=vol_stp)
              {
               mytrade.OrderDelete((int)GlobalVariableGet(tp_cp_tick));
               mytrade.BuyLimit(vol_pos,preco_stp,original_symbol,0,0,0,0,"TAKE PROFIT");
               GlobalVariableSet(tp_cp_tick,(double)mytrade.ResultOrder());

              }
           }
        }
     }

  }
//+------------------------------------------------------------------+
void CloseByPosition()
  {
   ulong tick_sell,tick_buy;
   if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      while(Buy_opened() && Sell_opened())
        {
         tick_buy=TickecBuyPos();
         tick_sell=TickecSellPos();
         if(tick_buy>0 && tick_sell>0)mytrade.PositionCloseBy(tick_buy,tick_sell);
        }

     }

  }
//+------------------------------------------------------------------+
ulong TickecBuyPos()
  {
   ulong tick=0;
   if(Buy_opened())
     {

      for(int i=PositionsTotal()-1;i>=0; i--)
        {
         if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
           {
            if(myposition.PositionType()==POSITION_TYPE_BUY)
              {
               tick=myposition.Ticket();
               break;
              }
           }
        }

     }
   return tick;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong TickecSellPos()
  {
   ulong tick=0;
   if(Sell_opened())
     {
      for(int i=PositionsTotal()-1;i>=0; i--)
        {
         if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
           {
            if(myposition.PositionType()==POSITION_TYPE_SELL)
              {
               tick=myposition.Ticket();
               break;
              }
           }
        }

     }
   return tick;
  }
//+------------------------------------------------------------------+
double VolPosType(ENUM_POSITION_TYPE ptype)
  {
   double vol=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && myposition.Symbol()==mysymbol.Name())
        {
         vol+=myposition.Volume();
        }
     }
   return vol;
  }
//+------------------------------------------------------------------+
