//+------------------------------------------------------------------+
//|                                           Trend Direction EA.mq5 |
//|                                     Copyright 2018, Master Forex |
//|             https://www.mql5.com/ru/users/Master_Forex/portfolio |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Master Forex"
#property link      "https://www.mql5.com/ru/users/Master_Forex/portfolio"
#property version   "1.00" 
#property description "Created - 20.05.2018 06:41"
#property description " "
#property description "Customer: Carlos Augusto ( https://www.mql5.com/en/users/gutogontijo )"
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
#include <Trade/Trade.mqh> 
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include<Trade\AccountInfo.mqh>
CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
CHistoryOrderInfo myhistory;

input string EAComment="Trend Direction EA";// EA Comment 
input string Main_Settings="====< Main Settings >====";   //  
input double Distance        = 1200;   // "x" distance points
input double Lots            = 0.1;    // Lots 
input bool   Martingale      = 1;      // Use Martingale  
input double Multiplier      = 2;      // Martingale Multiplier  
input double StopLoss        = 200;    // Stop Loss   
input double TakeProfit      = 400;    // Take Profit     
input int    Magic           = 0;      // Magic Number 

input string Partial_Closing="====< Partial Closing Settings >====";   //  
input bool UsePartial=0; // Use Partial Closing
input int ptp1=100;//Partial Closing Start TP 1
input int need_close_1=50;//Partial Closing Percent(%) for TP 1
input int ptp2=200;//Partial Closing Start TP 2
input int need_close_2=50;//Partial Closing Percent(%) for TP 2
input int ptp3=300;//Partial Closing Start TP 3
input int need_close_3=50;//Partial Closing Percent(%) for TP 3

input string Break_Even="====< Break Even Settings >====";   //  
input bool   UseBreakEven=0;      // Use Break Even
input double BEStart=200;    // Break Even Start
input double BEGain= 10;     // Break Even Gain 
input string Trailing_Settings="====< Trailing Settings >====";// 
input bool use_trail=true;//Use trailing stop
input int trail_start=100;//Trailing stop start
input int trail_step=20;//Distancia para ultima cotação
input int trail_tick=2;//Frequência de ajuste
input string Time_Settings="====< Schedule Settings >====";//  
input bool   Use_Time_Filter = 0;      // Use Time Filter
input string Time_Start      = "00:00";// Time Start
input string Time_End        = "23:59";// Time End
input string snovas="---------------Novas Opções------------";
input bool UseMedio=true;//Usar Preço Médio: True/False
input double distentmed=100;//Distancia da nova entrada
input double vol_ent_med=1;//Volume nova entrada

                           //HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
//+----------------------------------------------+
//--- declaration of integer variables for the indicators handles
datetime ctm[1],buy,sell;string gvp;
double ponto,ticksize,digits;
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic);
string med_cp_tick="med_cp_tick"+Symbol()+IntegerToString(Magic),med_vd_tick="med_vd_tick"+Symbol()+IntegerToString(Magic);
string entr_parc="entr_parc"+Symbol()+IntegerToString(Magic);
string lot_mart="lot_mart"+Symbol()+IntegerToString(Magic);
double preco_medio;
string tot_pend_orders="tot_ord"+Symbol()+IntegerToString(Magic),total_positions="tot_pos"+Symbol()+IntegerToString(Magic);
string tp_cp1_tick="tp_cp1"+Symbol()+IntegerToString(Magic),tp_cp2_tick="tp_cp2"+Symbol()+IntegerToString(Magic),tp_cp3_tick="tp_cp3"+Symbol()+IntegerToString(Magic);
string tp_vd1_tick="tp_vd1"+Symbol()+IntegerToString(Magic),tp_vd2_tick="tp_vd2"+Symbol()+IntegerToString(Magic),tp_vd3_tick="tp_vd3"+Symbol()+IntegerToString(Magic);
string tp_med_cp_tick="tp_med_cp_tick"+Symbol()+IntegerToString(Magic),tp_med_vd_tick="tp_med_vd_tick"+Symbol()+IntegerToString(Magic);
//---
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---      
   gvp=_Symbol+"_"+IntegerToString(Magic)+"_"+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_DEMO)gvp=gvp+"_d";
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_REAL)gvp=gvp+"_r";
   if(MQL5InfoInteger(MQL5_TESTING))gvp=gvp+"_t";
   mytrade.SetExpertMagicNumber(Magic);
   mysymbol.Name(Symbol());
   ponto=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
   ticksize=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);

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

   if(!GlobalVariableCheck(lot_mart))GlobalVariableSet(lot_mart,Lots);
   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0);
   if(!GlobalVariableCheck(med_cp_tick))GlobalVariableSet(med_cp_tick,0);
   if(!GlobalVariableCheck(med_vd_tick))GlobalVariableSet(med_vd_tick,0);

   if(!GlobalVariableCheck(tot_pend_orders))GlobalVariableSet(tot_pend_orders,CountOrders());
   if(!GlobalVariableCheck(total_positions))GlobalVariableSet(total_positions,CountPositions());

   if(!GlobalVariableCheck(tp_cp1_tick))GlobalVariableSet(tp_cp1_tick,0.0);
   if(!GlobalVariableCheck(tp_cp2_tick))GlobalVariableSet(tp_cp2_tick,0.0);
   if(!GlobalVariableCheck(tp_cp3_tick))GlobalVariableSet(tp_cp3_tick,0.0);
   if(!GlobalVariableCheck(tp_vd1_tick))GlobalVariableSet(tp_vd1_tick,0.0);
   if(!GlobalVariableCheck(tp_vd2_tick))GlobalVariableSet(tp_vd2_tick,0.0);
   if(!GlobalVariableCheck(tp_vd3_tick))GlobalVariableSet(tp_vd3_tick,0.0);

   if(!GlobalVariableCheck(tp_med_cp_tick))GlobalVariableSet(tp_med_cp_tick,0.0);
   if(!GlobalVariableCheck(tp_med_vd_tick))GlobalVariableSet(tp_med_vd_tick,0.0);


   if(Lots<=mysymbol.LotsMin())
     {
      string erro="Lote deve ser maior que o volume minimo de Lotes";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);

     }

   if(UsePartial && (ptp1>ptp2 || ptp1>ptp3 || ptp2>ptp3))
     {
      string erro="A distancia das saidas parciais devem estar ordenadas ";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(UsePartial && need_close_1+need_close_2+need_close_3!=100)
     {
      string erro="A soma das porcentagens de saida parciais tem que ser=100";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

//---    
   return(INIT_SUCCEEDED);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(reason==REASON_REMOVE) DeleteGV();

   return;
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   GlobalVariableSet(total_positions,CountPositions());

   if(GlobalVariableGet(lot_mart)==0)GlobalVariableSet(lot_mart,Lots);
   datetime hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Time_End);

   if(Use_Time_Filter && TimeCurrent()>=hora_final)
     {
      DeleteALL();
      CloseALL();
     }

   if(!Buy_opened())
     {
      if(myorder.Select((int)GlobalVariableGet(med_cp_tick))) mytrade.OrderDelete((int)GlobalVariableGet(med_cp_tick));
      if(myorder.Select((int)GlobalVariableGet(tp_vd1_tick))) mytrade.OrderDelete((int)GlobalVariableGet(tp_vd1_tick));
      if(myorder.Select((int)GlobalVariableGet(tp_vd2_tick))) mytrade.OrderDelete(GlobalVariableGet(tp_vd2_tick));
      if(myorder.Select((int)GlobalVariableGet(tp_vd3_tick))) mytrade.OrderDelete(GlobalVariableGet(tp_vd3_tick));
      if(myorder.Select((int)GlobalVariableGet(tp_med_vd_tick))) mytrade.OrderDelete(GlobalVariableGet(tp_med_vd_tick));

      GlobalVariableSet(tp_vd1_tick,0);
      GlobalVariableSet(tp_vd2_tick,0);
      GlobalVariableSet(tp_vd3_tick,0);

     }
   if(!Sell_opened())
     {
      if(myorder.Select((int)GlobalVariableGet(med_vd_tick))) mytrade.OrderDelete((int)GlobalVariableGet(med_vd_tick));
      if(myorder.Select((int)GlobalVariableGet(tp_cp1_tick))) mytrade.OrderDelete((int)GlobalVariableGet(tp_cp1_tick));
      if(myorder.Select((int)GlobalVariableGet(tp_cp2_tick))) mytrade.OrderDelete(GlobalVariableGet(tp_cp2_tick));
      if(myorder.Select((int)GlobalVariableGet(tp_cp3_tick))) mytrade.OrderDelete(GlobalVariableGet(tp_cp3_tick));
      if(myorder.Select((int)GlobalVariableGet(tp_med_cp_tick))) mytrade.OrderDelete(GlobalVariableGet(tp_med_cp_tick));

      GlobalVariableSet(tp_cp1_tick,0);
      GlobalVariableSet(tp_cp2_tick,0);
      GlobalVariableSet(tp_cp3_tick,0);
     }

   MqlRates rt[];
//---  
   if(CopyRates(_Symbol,0,0,3,rt)<0) return;

   if(CopyTime(_Symbol,0,0,1,ctm)<0) return;    //  Comment(OP(),"\n",Orders(-1));

//---- Getting buy signals
   if(DayFilterResult() && rt[2].open>rt[2].close && Entry(0,rt[2].close)==1 && (OP()==0 || (GVGet("b")!=Entry(2) || OP()-rt[2].close>=Distance*point())))
     {
      Deal_Hist();

      if(Orders(-1)<1)
        {
         if(mytrade.Buy(Martingale?GlobalVariableGet(lot_mart):Lots,NULL,0,0,0,"BUY"+exp_name))
            //if(mytrade.Buy(Lot(),NULL,0,0,0,"BUY"+exp_name))
           {
            GlobalVariableSet(cp_tick,mytrade.ResultOrder());
            myposition.SelectByTicket(GlobalVariableGet(cp_tick));
            if(UseMedio)
              {
               GlobalVariableSet(entr_parc,NormalizeDouble(myposition.PriceOpen()-distentmed*ponto,digits));
               if(mytrade.BuyLimit(vol_ent_med,GlobalVariableGet(entr_parc),NULL,0,0,0,0,"BUY PARC"+exp_name))GlobalVariableSet(med_cp_tick,(double)mytrade.ResultOrder());

              }

            buy=ctm[0];
            GVSet("lot",Lot());
            GVSet("b",Entry(2));

           }
        }
     }
//---- Getting sell signals
   if(DayFilterResult() && rt[2].open<rt[2].close && Entry(1,rt[2].close)==1 && (OP()==0 || (GVGet("s")!=Entry(3) || rt[2].close-OP()>=Distance*point())))
     {
      Deal_Hist();
      if(Orders(-1)<1)
        {
         if(mytrade.Sell(Martingale?GlobalVariableGet(lot_mart):Lots,NULL,0,0,0,"SELL"+exp_name))
            // if(mytrade.Sell(Lot(),NULL,0,0,0,"SELL"+exp_name))
           {
            GlobalVariableSet(vd_tick,mytrade.ResultOrder());
            myposition.SelectByTicket(GlobalVariableGet(vd_tick));
            if(UseMedio)
              {
               GlobalVariableSet(entr_parc,NormalizeDouble(myposition.PriceOpen()+distentmed*ponto,digits));
               if(mytrade.SellLimit(vol_ent_med,GlobalVariableGet(entr_parc),NULL,0,0,0,0,"SELL PARC"+exp_name))GlobalVariableSet(med_vd_tick,(double)mytrade.ResultOrder());
              }

            sell=ctm[0];
            GVSet("lot",Lot());
            GVSet("s",Entry(3));
           }
        }
     }
//---
   if(Orders(-1)>0)
     {
      //  InitialSLTP(_Symbol,StopLoss,TakeProfit);
      if(UseBreakEven) BreakEven(_Symbol,BEStart,BEGain);
      if(!DayFilterResult()) ClosePosition(_Symbol);
      if(use_trail)trail();
     }

   if(PositionJustOpenned((int)GlobalVariableGet(vd_tick)))
     {
      myposition.SelectByTicket((int)GlobalVariableGet(vd_tick));
      mytrade.PositionModify((int)GlobalVariableGet(vd_tick),NormalizeDouble(myposition.PriceOpen()+StopLoss*ponto,digits),NormalizeDouble(myposition.PriceOpen()-TakeProfit*ponto,digits));
      if(UsePartial) RealizacaoParcial();//Partial(_Symbol);

     }
   if(PositionJustOpenned((int)GlobalVariableGet(cp_tick)))
     {
      myposition.SelectByTicket((int)GlobalVariableGet(cp_tick));
      mytrade.PositionModify((int)GlobalVariableGet(cp_tick),NormalizeDouble(myposition.PriceOpen()-StopLoss*ponto,digits),NormalizeDouble(myposition.PriceOpen()+TakeProfit*ponto,digits));
      if(UsePartial) RealizacaoParcial();//Partial(_Symbol);

     }

   if(OrderFilled((int)GlobalVariableGet(med_vd_tick)))
     {
      myposition.SelectByTicket((int)GlobalVariableGet(vd_tick));
      preco_medio=NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
      mytrade.PositionModify((int)GlobalVariableGet(vd_tick),NormalizeDouble(preco_medio+StopLoss*ponto,digits),NormalizeDouble(preco_medio-TakeProfit*ponto,digits));
      AjusteParcial();
      if(mytrade.BuyLimit(vol_ent_med,NormalizeDouble(preco_medio-ptp1*ponto,digits),NULL,0,0,0,0,"Saída Parcial Medio"))
        {
         GlobalVariableSet(tp_med_cp_tick,(double)mytrade.ResultOrder());
         Print("Close buy part Medio done");
        }
      else Print("Position buy close Medio error: ",GetLastError());

     }
   if(OrderFilled((int)GlobalVariableGet(med_cp_tick)))
     {
      myposition.SelectByTicket((int)GlobalVariableGet(cp_tick));
      preco_medio=NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
      mytrade.PositionModify((int)GlobalVariableGet(cp_tick),NormalizeDouble(preco_medio-StopLoss*ponto,digits),NormalizeDouble(preco_medio+TakeProfit*ponto,digits));
      AjusteParcial();
      if(mytrade.SellLimit(vol_ent_med,NormalizeDouble(preco_medio+ptp1*ponto,digits),NULL,0,0,0,0,"Saía Parcial Medio"))
        {
         GlobalVariableSet(tp_med_vd_tick,(double)mytrade.ResultOrder());
         Print("Close sell part Medio done");
        }
      else Print("Position sell close Medio error: ",GetLastError());

     }

   GlobalVariableSet(tot_pend_orders,CountOrders());

//---  
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
//+------------------------------------------------------------------+
//|  Get consecutive bars                                            | 
//+------------------------------------------------------------------+
int Cnt(int ty=-1)
  {
   MqlRates rates[];
   ArraySetAsSeries(rates,true);
   int copied=CopyRates(Symbol(),0,0,50,rates),ke=0,ks=0;

   if(copied>0)
     {
      int size=fmin(copied,40);

      for(int i=size;i>0;i--)
        {
         if(rates[i].open<rates[i].close){ ks++;ke=0;}

         if(rates[i].open>rates[i].close){ ke++;ks=0;}
        }
      if(ty==0) return(ks);
      if(ty==1) return(ke);
     }
   return(-1);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//   
//+------------------------------------------------------------------+
//|  Get consecutive bars                                            | 
//+------------------------------------------------------------------+
double Entry(int ty=-1,double val=0)
  {
   double Highs = iHigh(_Symbol,0,Cnt(1));
   double Lows  = iLow(_Symbol,0,Cnt(0));

   if(ty==0 && Highs-val >= Distance*point()) return(1);

   if(ty==1 && val-Lows >= Distance*point()) return(1);

   if(ty==2) return(Highs);

   if(ty==3) return(Lows);

   return(0);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Calculate Trade Volume(Lot)                                      |
//+------------------------------------------------------------------+
double Lot()
  {
   double lots=Lots;

   if(Martingale && Loss()>0){ lots=NormalizeDouble(lots*MathPow(Multiplier,Loss()),2);}

   return( RoundLot(_Symbol, lots) );
  }
//+------------------------------------------------------------------+
int Loss()
  {
   int cnt=0;

   if(HistorySelect(0,TimeCurrent()))

      for(int x=HistoryDealsTotal()-1; x>=0; x--)
        {
         ulong ticket=HistoryDealGetTicket(x);
         string symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         ulong type=HistoryDealGetInteger(ticket,DEAL_TYPE);
         ulong magic = HistoryDealGetInteger(ticket,DEAL_MAGIC);
         ulong entry = HistoryDealGetInteger(ticket,DEAL_ENTRY);
         double profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);

         if(symbol!=_Symbol) continue;
         if(entry == DEAL_ENTRY_OUT && profit > 0) break;
         if(magic == Magic && entry == DEAL_ENTRY_OUT)
            if(type==DEAL_TYPE_BUY || type==DEAL_TYPE_SELL) cnt++;
        }
   return(cnt);
  }
//+------------------------------------------------------------------+
double OP()
  {
   double op=0;datetime prev=0,next=0;

   if(HistorySelect(0,TimeCurrent()))

      for(int x=HistoryDealsTotal()-1; x>=0; x--)
        {
         ulong ticket=HistoryDealGetTicket(x);
         string symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         ulong type=HistoryDealGetInteger(ticket,DEAL_TYPE);
         ulong magic = HistoryDealGetInteger(ticket,DEAL_MAGIC);
         ulong entry = HistoryDealGetInteger(ticket,DEAL_ENTRY);
         prev=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);

         if(symbol==_Symbol && magic==Magic && entry==DEAL_ENTRY_IN)
         if(prev>next){ op=HistoryDealGetDouble(ticket,DEAL_PRICE); next=prev;}
        }
   return(op);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
//+------------------------------------------------------------------+
//| Partial Closing                                                  |
//+------------------------------------------------------------------+
void Partial(string symbol=NULL)
  {
   int total=PositionsTotal();

   for(int i=0; i<total; i++)
     {
      ulong  position_ticket=PositionGetTicket(i);
      ulong  magic=PositionGetInteger(POSITION_MAGIC);

      if(magic==Magic)
        {
         double fCloseLot=(GVGet("lot")*PartialPercent)/100;
         
         fCloseLot=RoundLot(symbol,fCloseLot);
         
         double fOpenPrice=PositionGetDouble(POSITION_PRICE_OPEN);
         double fSL=PositionGetDouble(POSITION_SL);
         double fTP=PositionGetDouble(POSITION_TP);
         int nDigits=(int) SymbolInfoInteger(symbol,SYMBOL_DIGITS);
         ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
         double vol=PositionGetDouble(POSITION_VOLUME);

         if(type==POSITION_TYPE_BUY && fCloseLot>0 && vol>=GVGet("lot"))
           {
            double fBid=SymbolInfoDouble(symbol,SYMBOL_BID);

            if(fBid>=(fOpenPrice+PartialStart*point()))
              {
               Print("Closed by Partial Closing");
               ClosePosition(symbol,fCloseLot);
              }
           }
         if(type==POSITION_TYPE_SELL && fCloseLot>0 && vol>=GVGet("lot"))
           {
            double fBid=SymbolInfoDouble(symbol,SYMBOL_BID);

            if(fBid<=(fOpenPrice-PartialStart*point()))
              {
               Print("Closed by Partial Closing");
               ClosePosition(symbol,fCloseLot);
              }
           }
        }
     }
   return;
  }
  */
//+-------------------------------------------------------------------+
//| Close function                                                    |
//+-------------------------------------------------------------------+
void PARTIAL_CLOSE()
  {
//Function fro cloe positions
   MqlTradeRequest request;
   MqlTradeResult  result;
   int total=PositionsTotal(); // 

   int dos;
   dos=2;if(SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP)==0.1) dos=1;
   if(SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP)==1)dos=0;

   double points;
   points=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
//--- 
   for(int i=total-1; i>=0; i--)
     {
      ulong  position_ticket=PositionGetTicket(i);
      PositionSelectByTicket(position_ticket);
      string position_symbol=PositionGetString(POSITION_SYMBOL);
      ulong  magic_order=PositionGetInteger(POSITION_MAGIC);
      double volume=PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      //--- 
      if(Magic==magic_order && Symbol()==position_symbol)
        {
         double sl_real=PositionGetDouble(POSITION_SL);
         double tp_real=PositionGetDouble(POSITION_TP);
         ZeroMemory(request);ZeroMemory(result);
         request.action   =TRADE_ACTION_DEAL;
         request.position =position_ticket;
         request.symbol   =position_symbol;
         request.deviation=100;
         request.magic    =Magic;
         request.tp    =0;
         request.sl    =0;
         //---
         double bid=SymbolInfoDouble(position_symbol,SYMBOL_BID);
         double ask=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
         double price=PositionGetDouble(POSITION_PRICE_OPEN);
         //---
         double our_lot=GVGet("lot");
         double lot_1_must_be =NormalizeDouble(our_lot - our_lot/100*need_close_1,dos);
         double lot_2_must_be =NormalizeDouble(lot_1_must_be - lot_1_must_be/100*need_close_2,dos);
         double lot_3_must_be =NormalizeDouble(lot_2_must_be - lot_2_must_be/100*need_close_3,dos);
         //---

         //---
         //close buy
         if(type==POSITION_TYPE_BUY)
           {
            double LOT_FOR_CLOSE_1=NormalizeDouble(volume-lot_1_must_be,dos);
            double LOT_FOR_CLOSE_2 =NormalizeDouble(volume - lot_2_must_be,dos);
            double LOT_FOR_CLOSE_3 =NormalizeDouble(volume - lot_3_must_be,dos);

            request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
            request.type =ORDER_TYPE_SELL;
            double cur_dist=(bid -price)/points;

            if(cur_dist>=ptp1 && volume>lot_1_must_be && LOT_FOR_CLOSE_1>0.01)
              {
               Print("Try close part from buy, vol: ",volume," / will closed: ",LOT_FOR_CLOSE_1);
               request.volume=LOT_FOR_CLOSE_1;
               if(!OrderSend(request,result)) Print("Position buy close part 1 error: ",GetLastError());
               else {Print("Close buy part 1 done");break;}
              }

            if(cur_dist>=ptp2 && volume>lot_2_must_be && LOT_FOR_CLOSE_2>0.01)
              {
               Print("Try close part from buy, vol: ",volume," / will closed: ",LOT_FOR_CLOSE_2);
               request.volume=LOT_FOR_CLOSE_2;
               if(!OrderSend(request,result)) Print("Position buy close part 2 error: ",GetLastError());
               else {Print("Close buy part 2 done");break;}
              }

            if(cur_dist>=ptp3 && volume>lot_3_must_be && LOT_FOR_CLOSE_3>0.01)
              {
               Print("Try close part from buy, vol: ",volume," / will closed: ",LOT_FOR_CLOSE_3);
               request.volume=LOT_FOR_CLOSE_3;
               if(!OrderSend(request,result)) Print("Position buy close part 3 error: ",GetLastError());
               else {Print("Close buy part 3 done");break;}
              }

           }
         //close sell
         if(type==POSITION_TYPE_SELL)
           {

            double LOT_FOR_CLOSE_1 = NormalizeDouble(volume - lot_1_must_be,dos);
            double LOT_FOR_CLOSE_2 = NormalizeDouble(volume - lot_2_must_be,dos);
            double LOT_FOR_CLOSE_3 = NormalizeDouble(volume - lot_3_must_be,dos);
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
            request.type =ORDER_TYPE_BUY;
            double cur_dist=(price -ask)/points;

            if(cur_dist>=ptp1 && volume>lot_1_must_be && LOT_FOR_CLOSE_1>0.01)
              {
               Print("Try close part from sell, vol: ",volume," / will closed: ",LOT_FOR_CLOSE_1);
               request.volume=NormalizeDouble(LOT_FOR_CLOSE_1,dos);
               if(!OrderSend(request,result)) Print("Position sell close part 1 error: ",GetLastError());
               else {Print("Close sell part 1 done");break;}
              }

            if(cur_dist>=ptp2 && volume>lot_2_must_be && LOT_FOR_CLOSE_2>0.01)
              {
               Print("Try close part from sell, vol: ",volume," / will closed: ",LOT_FOR_CLOSE_2);
               request.volume=NormalizeDouble(LOT_FOR_CLOSE_2,dos);
               if(!OrderSend(request,result)) Print("Position sell close part 2 error: ",GetLastError());
               else {Print("Close sell part 2 done");break;}
              }

            if(cur_dist>=ptp3 && volume>lot_3_must_be && LOT_FOR_CLOSE_3>0.01)
              {
               Print("Try close part from sell, vol: ",volume," / will closed: ",LOT_FOR_CLOSE_3);
               request.volume=NormalizeDouble(LOT_FOR_CLOSE_3,dos);
               if(!OrderSend(request,result)) Print("Position sell close part 3 error: ",GetLastError());
               else {Print("Close sell part 3 done");break;}
              }

           }
        }
     }
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
//+------------------------------------------------------------------+
//| Open trade                                                       |
//+------------------------------------------------------------------+
bool MarketOrder(const string sSymbol,const ENUM_POSITION_TYPE eType,const double fLot,const double prices,const int nSL=0,const int nTP=0,const ulong nMagic=0,const uint nSlippage=1000)
  {
   bool bRetVal=false;

   MqlTradeRequest oRequest={0};
   MqlTradeResult    oResult={0};

   double fPoint = SymbolInfoDouble(sSymbol, SYMBOL_POINT);
   int nDigits   = (int) SymbolInfoInteger(sSymbol, SYMBOL_DIGITS);
   if(prices==0)
     {
      oRequest.action=TRADE_ACTION_DEAL;
     }
   if(prices>0)
     {
      oRequest.action=TRADE_ACTION_PENDING;
     }
   oRequest.symbol      = sSymbol;
   oRequest.volume      = fLot;
   oRequest.stoplimit   = 0;
   oRequest.deviation   = nSlippage;

   if(eType==POSITION_TYPE_BUY && prices==0)
     {
      oRequest.type=ORDER_TYPE_BUY;
      oRequest.price      = NormalizeDouble(SymbolInfoDouble(sSymbol, SYMBOL_ASK), nDigits);
      oRequest.sl         = NormalizeDouble(oRequest.price - nSL * fPoint, nDigits) * (nSL > 0);
      oRequest.tp         = NormalizeDouble(oRequest.price + nTP * fPoint, nDigits) * (nTP > 0);
     }

   if(eType==POSITION_TYPE_SELL && prices==0)
     {
      oRequest.type=ORDER_TYPE_SELL;
      oRequest.price      = NormalizeDouble(SymbolInfoDouble(sSymbol, SYMBOL_BID), nDigits);
      oRequest.sl         = NormalizeDouble(oRequest.price + nSL * fPoint, nDigits) * (nSL > 0);
      oRequest.tp         = NormalizeDouble(oRequest.price - nTP * fPoint, nDigits) * (nTP > 0);
     }
   if(eType==POSITION_TYPE_BUY && prices>0)
     {
      oRequest.type=ORDER_TYPE_BUY_LIMIT;
      oRequest.price      = NormalizeDouble(prices, nDigits);
      oRequest.sl         = NormalizeDouble(oRequest.price - nSL * fPoint, nDigits) * (nSL > 0);
      oRequest.tp         = NormalizeDouble(oRequest.price + nTP * fPoint, nDigits) * (nTP > 0);
     }

   if(eType==POSITION_TYPE_SELL && prices>0)
     {
      oRequest.type=ORDER_TYPE_SELL_LIMIT;
      oRequest.price      = NormalizeDouble(prices, nDigits);
      oRequest.sl         = NormalizeDouble(oRequest.price + nSL * fPoint, nDigits) * (nSL > 0);
      oRequest.tp         = NormalizeDouble(oRequest.price - nTP * fPoint, nDigits) * (nTP > 0);
     }
   if((int) SymbolInfoInteger(sSymbol,SYMBOL_FILLING_MODE)==SYMBOL_FILLING_FOK)
     {
      oRequest.type_filling=ORDER_FILLING_FOK;
     }
   if((int) SymbolInfoInteger(sSymbol,SYMBOL_FILLING_MODE)==SYMBOL_FILLING_IOC)
     {
      oRequest.type_filling=ORDER_FILLING_IOC;
     }
   if((int) SymbolInfoInteger(sSymbol,SYMBOL_FILLING_MODE)==0)
     {
      oRequest.type_filling=ORDER_FILLING_RETURN;
     }
//--- check filling
   if((int) SymbolInfoInteger(sSymbol,SYMBOL_FILLING_MODE)>2)
     {
      if(!FillingCheck(sSymbol))
         return(false);
     }
   oRequest.magic=nMagic;

   MqlTradeCheckResult oCheckResult={0};

   bool bCheck=OrderCheck(oRequest,oCheckResult);

   Print("Order Check MarketOrder:",
         " OrderCheck = ",bCheck,
         ", retcode = ",oCheckResult.retcode,
         ", balance = ",NormalizeDouble(oCheckResult.balance,2),
         ", equity = ",         NormalizeDouble(oCheckResult.equity, 2),
         ", margin = ",         NormalizeDouble(oCheckResult.margin, 2),
         ", margin_free = ",NormalizeDouble(oCheckResult.margin_free,2),
         ", margin_level = ",NormalizeDouble(oCheckResult.margin_level,2),
         ", comment = ",oCheckResult.comment);

   if(bCheck==true && oCheckResult.retcode==0)
     {
      bool bResult=false;

      for(int k=0; k<5; k++)
        {
         bResult=OrderSend(oRequest,oResult);

         if(bResult==true && (oResult.retcode==TRADE_RETCODE_PLACED || oResult.retcode==TRADE_RETCODE_DONE))
            break;

         if(k==4)
            break;

         Sleep(100);
        }
      Print("Order Send MarketOrder:",
            " OrderSend = ",bResult,
            ", retcode = ",   oResult.retcode,
            ", deal = ",      oResult.deal,
            ", order = ",oResult.order,
            ", volume = ",NormalizeDouble(oResult.volume,2),
            ", price = ",NormalizeDouble(oResult.price,_Digits),
            ", bid = ",         NormalizeDouble(oResult.bid, _Digits),
            ", ask = ",         NormalizeDouble(oResult.ask, _Digits),
            ", comment = ",   oResult.comment,
            ", request_id = ",oResult.request_id);

      if(oResult.retcode==TRADE_RETCODE_DONE)
         bRetVal=true;
     }
   else if(oResult.retcode==TRADE_RETCODE_NO_MONEY)
     {
      Print("There is not enough money to open a position. Expert work stopped.");
      ExpertRemove();
     }

   return(bRetVal);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
//+------------------------------------------------------------------+
bool InitialSLTP(const string sSymbol,const double nSL=0,const double nTP=0)
  {
   bool bRetVal=false;
//--- declare and initialize the trade request and result of trade request
   MqlTradeRequest request;
   MqlTradeResult  result;
   int total=PositionsTotal(); // number of open positions   
//--- iterate over all open positions
   for(int i=0; i<total; i++)
     {
      //--- parameters of the order
      ulong  position_ticket=PositionGetTicket(i);// ticket of the position
      string position_symbol=PositionGetString(POSITION_SYMBOL); // symbol 
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS); // number of decimal places
      ulong  magic=PositionGetInteger(POSITION_MAGIC); // MagicNumber of the position
      double volume=PositionGetDouble(POSITION_VOLUME);    // volume of the position
      double sl=PositionGetDouble(POSITION_SL);  // Stop Loss of the position
      double tp=PositionGetDouble(POSITION_TP);  // Take Profit of the position
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);  // type of the position 

      //--- if the MagicNumber matches, Stop Loss and Take Profit are not defined
      if(magic==Magic && sl==0 && tp==0 && (nSL>0 || nTP>0))
        {
         //--- calculate the current price levels
         double price=PositionGetDouble(POSITION_PRICE_OPEN);
         double bid=SymbolInfoDouble(position_symbol,SYMBOL_BID);
         double ask=SymbolInfoDouble(position_symbol,SYMBOL_ASK);

         if(type==POSITION_TYPE_BUY)
           {
            if(nSL > 0) sl=NormalizeDouble(bid-nSL*point(),digits);
            if(nTP > 0) tp=NormalizeDouble(ask+nTP*point(),digits);
           }
         if(type==POSITION_TYPE_SELL)
           {
            if(nSL > 0) sl=NormalizeDouble(ask+nSL*point(),digits);
            if(nTP > 0) tp=NormalizeDouble(bid-nTP*point(),digits);
           }
         //--- zeroing the request and result values
         ZeroMemory(request);
         ZeroMemory(result);
         //--- setting the operation parameters
         request.action  =TRADE_ACTION_SLTP; // type of trade operation
         request.position=position_ticket;   // ticket of the position
         request.symbol=position_symbol;     // symbol 
         request.sl      =sl;                // Stop Loss of the position
         request.tp      =tp;                // Take Profit of the position
         request.magic=Magic;                // MagicNumber of the position 
         //--- send the request
         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());  // if unable to send the request, output the error code 
        }
     }
   return (bRetVal);
  }
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM\\
//+------------------------------------------------------------------+
bool ClosePosition(const string sSymbol,double fLot=0)
  {
   bool bRetVal=false;
//--- declare and initialize the trade request and result of trade request
   MqlTradeRequest request;
   MqlTradeResult  result;
   int total=PositionsTotal(); // number of open positions   
//--- iterate over all open positions
   for(int i=total-1; i>=0; i--)
     {
      //--- parameters of the order
      ulong  position_ticket=PositionGetTicket(i);                                      // ticket of the position
      string position_symbol=sSymbol;                        // symbol 
      int    digits=(int)SymbolInfoInteger(position_symbol,SYMBOL_DIGITS);              // number of decimal places
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                  // MagicNumber of the position
      double volume=PositionGetDouble(POSITION_VOLUME);                                 // volume of the position
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);    // type of the position 

      if(magic==Magic)
        {
         //--- zeroing the request and result values
         ZeroMemory(request);
         ZeroMemory(result);
         //--- setting the operation parameters
         request.action   =TRADE_ACTION_DEAL;        // type of trade operation
         request.position =position_ticket;          // ticket of the position
         request.symbol   =position_symbol;          // symbol  
         if(fLot==0) request.volume=volume;      // volume of the position
         else request.volume=fLot;
         request.deviation=5;                        // allowed deviation from the price
         request.magic    =Magic;                    // MagicNumber of the position

         if((int) SymbolInfoInteger(sSymbol,SYMBOL_FILLING_MODE)==SYMBOL_FILLING_FOK)
           {
            request.type_filling=ORDER_FILLING_FOK;
           }
         if((int) SymbolInfoInteger(sSymbol,SYMBOL_FILLING_MODE)==SYMBOL_FILLING_IOC)
           {
            request.type_filling=ORDER_FILLING_IOC;
           }
         if((int) SymbolInfoInteger(sSymbol,SYMBOL_FILLING_MODE)==0)
           {
            request.type_filling=ORDER_FILLING_RETURN;
           }
         //--- check filling
         if((int) SymbolInfoInteger(sSymbol,SYMBOL_FILLING_MODE)>2)
           {
            if(!FillingCheck(sSymbol)) return(false);
           }
         //--- set the price and order type depending on the position type
         if(type==POSITION_TYPE_BUY)
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_BID);
            request.type =ORDER_TYPE_SELL;
           }
         else
           {
            request.price=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
            request.type =ORDER_TYPE_BUY;
           }
         //--- send the request
         if(!OrderSend(request,result))
            PrintFormat("OrderSend error %d",GetLastError());  // if unable to send the request, output the error code
         else bRetVal=true;
         //---
        }
     }
   return(bRetVal);
  }
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM\\
//+------------------------------------------------------------------+
//| Break Even                                                       |
//+------------------------------------------------------------------+
bool BreakEven(const string sSymbol,const double nBEActivationProfit,const double nBEStep)
  {
   bool bRetVal=false; double fNewSL=0; int total=PositionsTotal();

//--- declare and initialize the trade request and result of trade request
   MqlTradeRequest request; MqlTradeResult  result;

//--- iterate over all open positions
   for(int i=total-1; i>=0; i--)
     {
      //--- parameters of the order
      ulong  position_ticket=PositionGetTicket(i);                                      // ticket of the position
      string position_symbol=sSymbol;                        // symbol  
      ulong  magic=PositionGetInteger(POSITION_MAGIC);                                  // MagicNumber of the position
      double volume=PositionGetDouble(POSITION_VOLUME);                                 // volume of the position
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);    // type of the position 
      double fOpenPrice=PositionGetDouble(POSITION_PRICE_OPEN);
      double fSL=PositionGetDouble(POSITION_SL);
      double fTP=PositionGetDouble(POSITION_TP);
      double fPoint=point();
      int nDigits=(int) SymbolInfoInteger(sSymbol,SYMBOL_DIGITS);

      if(magic==Magic)
        {
         //--- zeroing the request and result values
         ZeroMemory(request);
         ZeroMemory(result);
         request.volume   =volume;                   // volume of the position
         request.deviation=5;                        // allowed deviation from the price
         request.magic    =Magic;                    // MagicNumber of the position
         request.position =position_ticket;          // ticket of the position

         if((int) SymbolInfoInteger(sSymbol,SYMBOL_FILLING_MODE)==SYMBOL_FILLING_FOK)
           {
            request.type_filling=ORDER_FILLING_FOK;
           }
         if((int) SymbolInfoInteger(sSymbol,SYMBOL_FILLING_MODE)==SYMBOL_FILLING_IOC)
           {
            request.type_filling=ORDER_FILLING_IOC;
           }
         if((int) SymbolInfoInteger(sSymbol,SYMBOL_FILLING_MODE)==0)
           {
            request.type_filling=ORDER_FILLING_RETURN;
           }
         //--- check filling
         if((int) SymbolInfoInteger(sSymbol,SYMBOL_FILLING_MODE)>2)
           {
            if(!FillingCheck(sSymbol)) return(false);
           }
         //---            
         if(type==POSITION_TYPE_BUY)
           {
            double fBid=SymbolInfoDouble(sSymbol,SYMBOL_BID);

            if(fBid>=(fOpenPrice+nBEActivationProfit*fPoint))
               fNewSL=fOpenPrice+nBEStep*fPoint;
           }
         if(type==POSITION_TYPE_SELL)
           {
            double fAsk=SymbolInfoDouble(sSymbol,SYMBOL_ASK);

            if(fAsk<=(fOpenPrice-nBEActivationProfit*fPoint))
               fNewSL=fOpenPrice-nBEStep*fPoint;
           }
         fNewSL=NormalizeDouble(MathRound(fNewSL/ticksize)*ticksize,digits);
         if((type==POSITION_TYPE_BUY && fNewSL>fSL) || (type==POSITION_TYPE_SELL && (fNewSL>0 && (fNewSL<fSL || fSL==0))))
           {
            request.action         = TRADE_ACTION_SLTP;
            request.symbol         = sSymbol;
            request.sl               = NormalizeDouble(fNewSL, nDigits);
            request.tp               = NormalizeDouble(fTP, nDigits);

            //--- send the request
            if(!OrderSend(request,result)) PrintFormat("OrderSend error %d",GetLastError());
            else{ Print("Position modified by Break Even! SL is = ",NormalizeDouble(fNewSL,nDigits)); bRetVal=true;}
            //---
           }
        }
     }
   return (bRetVal);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
//+------------------------------------------------------------------+
//| Check for open positions                                         |
//+------------------------------------------------------------------+
int Orders(int ty=-1)
  {
   int result=0,total=PositionsTotal(); // number of open positions   
//--- iterate over all open positions
   for(int i=0; i<total; i++)
     {
      //--- parameters of the order
      ulong  position_ticket=PositionGetTicket(i);// ticket of the position
      string position_symbol=PositionGetString(POSITION_SYMBOL); // symbol  
      ulong  magic=PositionGetInteger(POSITION_MAGIC); // MagicNumber of the position 
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);  // type of the position 

      if(magic==Magic)
        {
         if(type==ty || ty==-1) result++;
        }
     }
   return(result); // 0 means there are no orders/positions
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
//+------------------------------------------------------------------+
//| Checks and corrects type of filling policy                       |
//+------------------------------------------------------------------+
bool FillingCheck(const string symbol)
  {
   MqlTradeRequest   m_request={0};         // request data
   MqlTradeResult    m_result={0};          // result data

   ENUM_ORDER_TYPE_FILLING m_type_filling=0;
//--- get execution mode of orders by symbol
   ENUM_SYMBOL_TRADE_EXECUTION exec=(ENUM_SYMBOL_TRADE_EXECUTION)SymbolInfoInteger(symbol,SYMBOL_TRADE_EXEMODE);
//--- check execution mode
   if(exec==SYMBOL_TRADE_EXECUTION_REQUEST || exec==SYMBOL_TRADE_EXECUTION_INSTANT)
     {
      //--- neccessary filling type will be placed automatically
      return(true);
     }
//--- get possible filling policy types by symbol
   uint filling=(uint)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE);
//--- check execution mode again
   if(exec==SYMBOL_TRADE_EXECUTION_MARKET)
     {
      //--- for the MARKET execution mode
      //--- analyze order
      if(m_request.action!=TRADE_ACTION_PENDING)
        {
         //--- in case of instant execution order
         //--- if the required filling policy is supported, add it to the request
         if(m_type_filling==ORDER_FILLING_FOK && (filling  &SYMBOL_FILLING_FOK)!=0)
           {
            m_request.type_filling=m_type_filling;
            return(true);
           }
         if(m_type_filling==ORDER_FILLING_IOC && (filling  &SYMBOL_FILLING_IOC)!=0)
           {
            m_request.type_filling=m_type_filling;
            return(true);
           }
         //--- wrong filling policy, set error code
         m_result.retcode=TRADE_RETCODE_INVALID_FILL;
         return(false);
        }
      return(true);
     }
//--- EXCHANGE execution mode
   switch(m_type_filling)
     {
      case ORDER_FILLING_FOK:
         //--- analyze order
         if(m_request.action==TRADE_ACTION_PENDING)
           {
            //--- in case of pending order
            //--- add the expiration mode to the request
            if(!ExpirationCheck(symbol))
               m_request.type_time=ORDER_TIME_DAY;
            //--- stop order?
            if(m_request.type==ORDER_TYPE_BUY_STOP || m_request.type==ORDER_TYPE_SELL_STOP)
              {
               //--- in case of stop order
               //--- add the corresponding filling policy to the request
               m_request.type_filling=ORDER_FILLING_RETURN;
               return(true);
              }
           }
         //--- in case of limit order or instant execution order
         //--- if the required filling policy is supported, add it to the request
         if((filling  &SYMBOL_FILLING_FOK)!=0)
           {
            m_request.type_filling=m_type_filling;
            return(true);
           }
         //--- wrong filling policy, set error code
         m_result.retcode=TRADE_RETCODE_INVALID_FILL;
         return(false);
      case ORDER_FILLING_IOC:
         //--- analyze order
         if(m_request.action==TRADE_ACTION_PENDING)
           {
            //--- in case of pending order
            //--- add the expiration mode to the request
            if(!ExpirationCheck(symbol))
               m_request.type_time=ORDER_TIME_DAY;
            //--- stop order?
            if(m_request.type==ORDER_TYPE_BUY_STOP || m_request.type==ORDER_TYPE_SELL_STOP)
              {
               //--- in case of stop order
               //--- add the corresponding filling policy to the request
               m_request.type_filling=ORDER_FILLING_RETURN;
               return(true);
              }
           }
         //--- in case of limit order or instant execution order
         //--- if the required filling policy is supported, add it to the request
         if((filling  &SYMBOL_FILLING_IOC)!=0)
           {
            m_request.type_filling=m_type_filling;
            return(true);
           }
         //--- wrong filling policy, set error code
         m_result.retcode=TRADE_RETCODE_INVALID_FILL;
         return(false);
      case ORDER_FILLING_RETURN:
         //--- add filling policy to the request
         m_request.type_filling=m_type_filling;
         return(true);
     }
//--- unknown execution mode, set error code
   m_result.retcode=TRADE_RETCODE_ERROR;
   return(false);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
//+------------------------------------------------------------------+
//| Check expiration type of pending order                           |
//+------------------------------------------------------------------+
bool ExpirationCheck(const string symbol)
  {
   CSymbolInfo sym;
   MqlTradeRequest   m_request={0};         // request data
   MqlTradeResult    m_result={0};          // result data

//--- check symbol
   if(!sym.Name((symbol==NULL)?Symbol():symbol))
      return(false);
//--- get flags
   int flags=sym.TradeTimeFlags();
//--- check type
   switch(m_request.type_time)
     {
      case ORDER_TIME_GTC:
         if((flags&SYMBOL_EXPIRATION_GTC)!=0)
         return(true);
         break;
      case ORDER_TIME_DAY:
         if((flags&SYMBOL_EXPIRATION_DAY)!=0)
         return(true);
         break;
      case ORDER_TIME_SPECIFIED:
         if((flags&SYMBOL_EXPIRATION_SPECIFIED)!=0)
         return(true);
         break;
      case ORDER_TIME_SPECIFIED_DAY:
         if((flags&SYMBOL_EXPIRATION_SPECIFIED_DAY)!=0)
         return(true);
         break;
      default:
         Print(__FUNCTION__+": Unknown expiration type");
         break;
     }
//--- failed
   return(false);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
//+------------------------------------------------------------------+
//| Time Filter                                                      |
//+------------------------------------------------------------------+
bool DayFilterResult()
  {
   if(!Use_Time_Filter)return(true);

   long hs1 = StringToInteger(StringSubstr(Time_Start, 0, 2)), ms1 = StringToInteger(StringSubstr(Time_Start, 3, 2));
   long he1 = StringToInteger(StringSubstr(Time_End, 0, 2)), me1 = StringToInteger(StringSubstr(Time_End, 3, 2));

   if(hs1<he1)
     {
      if(((TimeHour(TimeCurrent())==hs1 && TimeMinute(TimeCurrent())>=ms1) && TimeHour(TimeCurrent())<he1)
         || (TimeHour(TimeCurrent())>hs1 && TimeHour(TimeCurrent())<he1)
         || ((TimeMinute(TimeCurrent())<=me1 && TimeHour(TimeCurrent())==he1) && TimeHour(TimeCurrent())>hs1)
         || (TimeHour(TimeCurrent())<he1 && TimeHour(TimeCurrent())>hs1))
         return(true);
     }
   if(hs1>he1)
     {
      if((TimeHour(TimeCurrent())==hs1 && TimeMinute(TimeCurrent())>=ms1 && TimeHour(TimeCurrent())<24)
         || (TimeHour(TimeCurrent())>hs1 && TimeHour(TimeCurrent())<24)
         || (TimeHour(TimeCurrent())==he1 && TimeMinute(TimeCurrent())<=me1 && TimeHour(TimeCurrent())>=0)
         || (TimeHour(TimeCurrent())<he1 && TimeHour(TimeCurrent())>=0))
         return(true);
     }
   return(false);
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
int TimeHour(datetime date){ MqlDateTime Tm;TimeToStruct(date,Tm);return(Tm.hour);}
int TimeMinute(datetime date){ MqlDateTime Tm;TimeToStruct(date,Tm);return(Tm.min);}
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
double RoundLot(const string sSymbol,const double fLot)
  {
   double fMinLot  = SymbolInfoDouble(sSymbol, SYMBOL_VOLUME_MIN);
   double fMaxLot  = SymbolInfoDouble(sSymbol, SYMBOL_VOLUME_MAX);
   double fLotStep = SymbolInfoDouble(sSymbol, SYMBOL_VOLUME_STEP);

   int nLotDigits=(int) StringToInteger(DoubleToString(MathAbs(MathLog(fLotStep)/MathLog(10)),0));

   double fRoundedLot=MathFloor(fLot/fLotStep+0.5)*fLotStep;

   fRoundedLot=NormalizeDouble(fRoundedLot,nLotDigits);

   if(fRoundedLot<fMinLot)
      fRoundedLot=fMinLot;

   if(fRoundedLot>fMaxLot)
      fRoundedLot=fMaxLot;

   return(fRoundedLot);
  }
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM\\
double High[],Low[];
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES TFMigrate(int tf)
  {
   switch(tf)
     {
      case 0: return(PERIOD_CURRENT);
      case 1: return(PERIOD_M1);
      case 5: return(PERIOD_M5);
      case 15: return(PERIOD_M15);
      case 30: return(PERIOD_M30);
      case 60: return(PERIOD_H1);
      case 240: return(PERIOD_H4);
      case 1440: return(PERIOD_D1);
      case 10080: return(PERIOD_W1);
      case 43200: return(PERIOD_MN1);

      case 2: return(PERIOD_M2);
      case 3: return(PERIOD_M3);
      case 4: return(PERIOD_M4);
      case 6: return(PERIOD_M6);
      case 10: return(PERIOD_M10);
      case 12: return(PERIOD_M12);
      case 16385: return(PERIOD_H1);
      case 16386: return(PERIOD_H2);
      case 16387: return(PERIOD_H3);
      case 16388: return(PERIOD_H4);
      case 16390: return(PERIOD_H6);
      case 16392: return(PERIOD_H8);
      case 16396: return(PERIOD_H12);
      case 16408: return(PERIOD_D1);
      case 32769: return(PERIOD_W1);
      case 49153: return(PERIOD_MN1);
      default: return(PERIOD_CURRENT);
     }
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//
//+------------------------------------------------------------------+
//| Check Symbol Points                                              |
//+------------------------------------------------------------------+     
double point()
  {
   return(SymbolInfoDouble(_Symbol,SYMBOL_POINT));
  }
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM\\
//+------------------------------------------------------------------+
//|   Delete GlobalVariabeles with perfix gvp                        | 
//+------------------------------------------------------------------+
void DeleteGV()
  {
   for(int i=GlobalVariablesTotal()-1;i>=0;i--)
     {
      if(StringFind(GlobalVariableName(i),gvp,0)==0)

         GlobalVariableDel(GlobalVariableName(i));
     }
  }
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM\\
//+------------------------------------------------------------------+
//|  Global Variable Set                                             |
//+------------------------------------------------------------------+  
datetime GVSet(string name,double value)
  {
   return(GlobalVariableSet(gvp+name,value));
  }
//MMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMMM\\
//+------------------------------------------------------------------+
//|  Global Variable Get                                             |
//+------------------------------------------------------------------+
double GVGet(string name)
  {
   return(GlobalVariableGet(gvp+name));
  }
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
//+-------------------------------------------------------------------+
//| Trailing                                                          |
//+-------------------------------------------------------------------+
void trail()
  {
//--- 
   MqlTradeRequest request;
   MqlTradeResult  result;
   int total=PositionsTotal();
//--- 
   for(int i=0; i<total; i++)
     {
      //--- 
      ulong  position_ticket=PositionGetTicket(i);
      string position_symbol=PositionGetString(POSITION_SYMBOL);
      ulong  magic=PositionGetInteger(POSITION_MAGIC);
      double sl_trail=PositionGetDouble(POSITION_SL);
      double tp_trail=PositionGetDouble(POSITION_TP);
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      //--- 
      if(position_symbol==Symbol() && magic==magic)
        {
         double bid=SymbolInfoDouble(position_symbol,SYMBOL_BID);
         double ask=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
         double price=PositionGetDouble(POSITION_PRICE_OPEN);
         int    stop_level=(int)SymbolInfoInteger(position_symbol,SYMBOL_TRADE_STOPS_LEVEL);
         int STEP=trail_step;
         //---
         if(type==POSITION_TYPE_BUY && bid-trail_start*Point()>price)
           {

            double current_distance=(bid-price)/Point();
            double SL_WILL_PRICE=price+(trail_start-trail_step)*Point();
            if(trail_tick>0)
              {
               current_distance=(current_distance-trail_start)/trail_tick;
               SL_WILL_PRICE=SL_WILL_PRICE+current_distance*Point();
               SL_WILL_PRICE=NormalizeDouble(MathRound(SL_WILL_PRICE/ticksize)*ticksize,digits);
              }

            double newsl=NormalizeDouble(SL_WILL_PRICE,Digits());
            if(newsl>sl_trail || sl_trail==0)
              {
               if((sl_trail<newsl || sl_trail==0) && newsl>price)
                 {
                  ZeroMemory(request);
                  ZeroMemory(result);
                  request.action  =TRADE_ACTION_SLTP;
                  request.position=position_ticket;
                  request.symbol=position_symbol;
                  request.sl =newsl;
                  request.tp =tp_trail;
                  request.magic=magic;
                  //--- 
                  if(!OrderSend(request,result)) PrintFormat("OrderSend error %d",GetLastError());
                 }
              }
           }
         if(type==POSITION_TYPE_SELL && ask+trail_start*Point()<price)
           {

            double current_distance=(price-bid)/Point();
            double SL_WILL_PRICE=price-(trail_start-trail_step)*Point();
            if(trail_tick>0)
              {
               current_distance=(current_distance-trail_start)/trail_tick;
               SL_WILL_PRICE=SL_WILL_PRICE-current_distance*Point();
               SL_WILL_PRICE=NormalizeDouble(MathRound(SL_WILL_PRICE/ticksize)*ticksize,digits);
              }

            double newsl=NormalizeDouble(SL_WILL_PRICE,Digits());
            if(newsl<sl_trail || sl_trail==0)
              {
               if((sl_trail>newsl || sl_trail==0) && newsl<price)
                 {
                  ZeroMemory(request);
                  ZeroMemory(result);
                  request.action  =TRADE_ACTION_SLTP;
                  request.position=position_ticket;
                  request.symbol=position_symbol;
                  request.sl =newsl;
                  request.tp =tp_trail;
                  request.magic=magic;
                  //--- 
                  if(!OrderSend(request,result)) PrintFormat("OrderSend error %d",GetLastError());
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=mysymbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
bool PosicaoAberta()
  {
   if(myposition.SelectByMagic(Symbol(),Magic)==true)
      return(myposition.PositionType()== POSITION_TYPE_BUY||myposition.PositionType()== POSITION_TYPE_SELL);
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseALL()
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic && myposition.Symbol()==mysymbol.Name())
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
void DeleteALL()
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      ulong o_ticket=OrderGetTicket(j);
      if(o_ticket!=0)
        {
         myorder.Select(o_ticket);
         if(myorder.Magic()==Magic && myorder.Symbol()==mysymbol.Name()) mytrade.OrderDelete(o_ticket);
        }
     }
  }
//+------------------------------------------------------------------+
bool Buy_opened()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic && myposition.Symbol()==mysymbol.Name() && myposition.PositionType()==POSITION_TYPE_BUY)
         return(true);  //It is a Buy
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Sell_opened()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic && myposition.Symbol()==mysymbol.Name() && myposition.PositionType()==POSITION_TYPE_SELL)
         return(true);  //It is a Buy
     }
   return(false);
  }
//+------------------------------------------------------------------+
void DeleteOrders(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic)
            if(myorder.OrderType()==order_type)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
//| Retorna o último ticket de ordem em histórico ou -1              | 
//+------------------------------------------------------------------+ 
ulong GetLastOrderTicket()
  {
   if(!GetTradeHistory(1))
     {
      //--- notificar sobre chamada sem sucesso e retorno -1 
      Print(__FUNCTION__," HistorySelect() retornou false");
      return -1;
     }
//---  
   ulong first_order,last_order,orders=HistoryOrdersTotal();
//--- trabalhar com ordens se houver alguma 
   if(orders>0)
     {
      first_order=HistoryOrderGetTicket(0);
      if(orders>1)
        {
         last_order=HistoryOrderGetTicket((int)orders-1);
         return last_order;
        }
      return first_order;
     }
//--- nenhuma ordem encontrada, retornar -1 
   return -1;
  }
//+---------------------------------------------------------------------------------+ 
//| Solicitações de histórico para os últimos dias e retorna false em caso de falha | 
//+---------------------------------------------------------------------------------+ 
bool GetTradeHistory(int days)
  {
//--- define um período da semana para solicitar histórico da operação 
   datetime to=TimeCurrent();
   datetime from=to-days*PeriodSeconds(PERIOD_D1);
   ResetLastError();
//--- fazer um pedido e verificar o resultado 
   if(!HistorySelect(from,to))
     {
      Print(__FUNCTION__," HistorySelect=false. Código de erro=",GetLastError());
      return false;
     }
//--- histórico recebido com sucesso 
   return true;
  }
//+------------------------------------------------------------------+

bool OrderFilled(ulong order_tick)
  {
   long order_state;
   ulong last_order=GetLastOrderTicket();
   if(HistorySelect(TimeCurrent()-PeriodSeconds(PERIOD_D1),TimeCurrent()))
     {
      if((int)GlobalVariableGet(tot_pend_orders)>CountOrders())
        {
         if(last_order==order_tick)
           {
            myhistory.Ticket(last_order);
            order_state=myhistory.State();
            if(order_state==ORDER_STATE_FILLED)return true;

           }
        }
     }
   return false;
  }
//+------------------------------------------------------------------+
void Deal_Hist()
  {
   if(HistorySelect(TimeCurrent()-PeriodSeconds(PERIOD_D1),TimeCurrent()))
     {
      ulong deals_total=HistoryDealsTotal();
      ulong deals_ticket=HistoryDealGetTicket(deals_total-1);
      mydeal.Ticket(deals_ticket);

      if((mydeal.Type()==DEAL_TYPE_BUY || mydeal.Type()==DEAL_TYPE_SELL) && mydeal.Entry()==DEAL_ENTRY_OUT)
        {
         if(mydeal.Profit()<0)GlobalVariableSet(lot_mart,ArredondLot(GlobalVariableGet(lot_mart)*Multiplier));
         else GlobalVariableSet(lot_mart,Lots);
        }
     }

  }
//+------------------------------------------------------------------+
double ArredondLot(const double fLot)
  {
   return MathCeil(fLot/mysymbol.LotsStep())*mysymbol.LotsStep();

  }
//+------------------------------------------------------------------+
int CountOrders()
  {
   int mark=0;

   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      if(myorder.Select(OrderGetTicket(i)))
        {
         if(myorder.Magic()==Magic && myorder.Symbol()==_Symbol) mark++;
        }
     }
   return(mark);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountPositions()
  {
   int mark=0;

   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic && myposition.Symbol()==mysymbol.Name()) mark++;

     }
   return(mark);
  }
//+------------------------------------------------------------------+
bool PositionJustOpenned(ulong pos_tick)
  {
   if((int)GlobalVariableGet(total_positions)<CountPositions())
     {
      for(int i=PositionsTotal()-1;i>=0; i--)
        {
         if(myposition.SelectByIndex(i)&&myposition.Ticket()==pos_tick && myposition.Magic()==Magic && myposition.Symbol()==mysymbol.Name())return true;

        }
     }
   return false;
  }
//+------------------------------------------------------------------+

void RealizacaoParcial()
  {

   double LOT_FOR_CLOSE_1,LOT_FOR_CLOSE_2,LOT_FOR_CLOSE_3;
//Function fro cloe positions
   int total=PositionsTotal(); // 

   int dos;
   dos=2;if(SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP)==0.1) dos=1;
   if(SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_STEP)==1)dos=0;

   double points;
   points=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
//--- 
   for(int i=total-1; i>=0; i--)
     {
      ulong  position_ticket=PositionGetTicket(i);
      PositionSelectByTicket(position_ticket);
      string position_symbol=PositionGetString(POSITION_SYMBOL);
      ulong  magic_order=PositionGetInteger(POSITION_MAGIC);
      double volume=PositionGetDouble(POSITION_VOLUME);
      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      //--- 
      if(Magic==magic_order && Symbol()==position_symbol)
        {
         double price=PositionGetDouble(POSITION_PRICE_OPEN);
         price=NormalizeDouble(MathRound(price/ticksize)*ticksize,digits);
         //---
         //---

         LOT_FOR_CLOSE_1=NormalizeDouble(MathRound((volume/100*need_close_1)/mysymbol.LotsStep())*mysymbol.LotsStep(),dos);
         LOT_FOR_CLOSE_1=MathMin(LOT_FOR_CLOSE_1,volume);
         LOT_FOR_CLOSE_1=MathMax(LOT_FOR_CLOSE_1,mysymbol.LotsMin());
         LOT_FOR_CLOSE_2=NormalizeDouble(MathRound((volume/100*need_close_2)/mysymbol.LotsStep())*mysymbol.LotsStep(),dos);
         LOT_FOR_CLOSE_2=MathMin(LOT_FOR_CLOSE_2,volume-LOT_FOR_CLOSE_1);
         if(LOT_FOR_CLOSE_2>0)LOT_FOR_CLOSE_2=MathMax(LOT_FOR_CLOSE_2,mysymbol.LotsMin());
         LOT_FOR_CLOSE_3=NormalizeDouble(MathRound((volume/100*need_close_3)/mysymbol.LotsStep())*mysymbol.LotsStep(),dos);
         LOT_FOR_CLOSE_3=MathMin(LOT_FOR_CLOSE_3,volume-LOT_FOR_CLOSE_1-LOT_FOR_CLOSE_2);
         if(LOT_FOR_CLOSE_3>0)LOT_FOR_CLOSE_3=MathMax(LOT_FOR_CLOSE_3,mysymbol.LotsMin());

         //---
         //close buy
         if(type==POSITION_TYPE_BUY)
           {

            if(LOT_FOR_CLOSE_1>=mysymbol.LotsMin() && GlobalVariableGet(tp_vd1_tick)==0)
              {
               Print("Try close part from buy, vol: ",volume," / will closed: ",LOT_FOR_CLOSE_1);
               if(mytrade.SellLimit(LOT_FOR_CLOSE_1,NormalizeDouble(price+ptp1*ponto,digits),NULL,0,0,0,0,"Saía Parcial 1"))
                 {
                  GlobalVariableSet(tp_vd1_tick,(double)mytrade.ResultOrder());
                  Print("Close buy part 1 done");
                 }
               else Print("Position buy close part 1 error: ",GetLastError());
              }

            if(LOT_FOR_CLOSE_2>=mysymbol.LotsMin() && GlobalVariableGet(tp_vd2_tick)==0)
              {
               Print("Try close part from buy, vol: ",volume," / will closed: ",LOT_FOR_CLOSE_2);
               if(mytrade.SellLimit(LOT_FOR_CLOSE_2,NormalizeDouble(price+ptp2*ponto,digits),NULL,0,0,0,0,"Saía Parcial 2"))
                 {
                  GlobalVariableSet(tp_vd2_tick,(double)mytrade.ResultOrder());
                  Print("Close buy part 2 done");
                 }
               else Print("Position buy close part 2 error: ",GetLastError());
              }
            if(LOT_FOR_CLOSE_3>=mysymbol.LotsMin() && GlobalVariableGet(tp_vd3_tick)==0)
              {
               Print("Try close part from buy, vol: ",volume," / will closed: ",LOT_FOR_CLOSE_3);
               if(mytrade.SellLimit(LOT_FOR_CLOSE_3,NormalizeDouble(price+ptp3*ponto,digits),NULL,0,0,0,0,"Saía Parcial 3"))
                 {
                  GlobalVariableSet(tp_vd3_tick,(double)mytrade.ResultOrder());
                  Print("Close buy part 3 done");
                 }
               else Print("Position buy close part 3 error: ",GetLastError());
              }

           }
         //close sell
         if(type==POSITION_TYPE_SELL)
           {

            if(LOT_FOR_CLOSE_1>=mysymbol.LotsMin() && GlobalVariableGet(tp_cp1_tick)==0)
              {
               Print("Try close part from buy, vol: ",volume," / will closed: ",LOT_FOR_CLOSE_1);
               if(mytrade.BuyLimit(LOT_FOR_CLOSE_1,NormalizeDouble(price-ptp1*ponto,digits),NULL,0,0,0,0,"Saía Parcial 1"))
                 {
                  GlobalVariableSet(tp_cp1_tick,(double)mytrade.ResultOrder());
                  Print("Close buy part 1 done");
                 }
               else Print("Position buy close part 1 error: ",GetLastError());
              }

            if(LOT_FOR_CLOSE_2>=mysymbol.LotsMin() && GlobalVariableGet(tp_cp2_tick)==0)
              {
               Print("Try close part from buy, vol: ",volume," / will closed: ",LOT_FOR_CLOSE_2);
               if(mytrade.BuyLimit(LOT_FOR_CLOSE_2,NormalizeDouble(price-ptp2*ponto,digits),NULL,0,0,0,0,"Saía Parcial 2"))
                 {
                  GlobalVariableSet(tp_cp2_tick,(double)mytrade.ResultOrder());
                  Print("Close buy part 2 done");
                 }
               else Print("Position buy close part 2 error: ",GetLastError());
              }
            if(LOT_FOR_CLOSE_3>=mysymbol.LotsMin() && GlobalVariableGet(tp_cp3_tick)==0)
              {
               Print("Try close part from buy, vol: ",volume," / will closed: ",LOT_FOR_CLOSE_3);
               if(mytrade.BuyLimit(LOT_FOR_CLOSE_3,NormalizeDouble(price-ptp3*ponto,digits),NULL,0,0,0,0,"Saía Parcial 3"))
                 {
                  GlobalVariableSet(tp_cp3_tick,(double)mytrade.ResultOrder());
                  Print("Close buy part 3 done");
                 }
               else Print("Position buy close part 3 error: ",GetLastError());
              }

           }
        }
     }
  }
//+------------------------------------------------------------------+
void AjusteParcial()
  {
   double preco;
   if(Buy_opened())
     {
      myposition.SelectByTicket((int)GlobalVariableGet(cp_tick));
      preco=NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
      if(myorder.Select((int)GlobalVariableGet(tp_vd1_tick))) mytrade.OrderModify((int)GlobalVariableGet(tp_vd1_tick),NormalizeDouble(preco+ptp1*ponto,digits),0,0,0,0,0);
      if(myorder.Select((int)GlobalVariableGet(tp_vd2_tick))) mytrade.OrderModify((int)GlobalVariableGet(tp_vd2_tick),NormalizeDouble(preco+ptp2*ponto,digits),0,0,0,0,0);
      if(myorder.Select((int)GlobalVariableGet(tp_vd3_tick))) mytrade.OrderModify((int)GlobalVariableGet(tp_vd3_tick),NormalizeDouble(preco+ptp3*ponto,digits),0,0,0,0,0);

     }
   if(Sell_opened())
     {
      myposition.SelectByTicket((int)GlobalVariableGet(vd_tick));
      preco=NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);

      if(myorder.Select((int)GlobalVariableGet(tp_cp1_tick))) mytrade.OrderModify((int)GlobalVariableGet(tp_cp1_tick),NormalizeDouble(preco-ptp1*ponto,digits),0,0,0,0,0);
      if(myorder.Select((int)GlobalVariableGet(tp_cp2_tick))) mytrade.OrderModify((int)GlobalVariableGet(tp_cp2_tick),NormalizeDouble(preco-ptp2*ponto,digits),0,0,0,0,0);
      if(myorder.Select((int)GlobalVariableGet(tp_cp3_tick))) mytrade.OrderModify((int)GlobalVariableGet(tp_cp3_tick),NormalizeDouble(preco-ptp3*ponto,digits),0,0,0,0,0);
     }

  }
//+------------------------------------------------------------------+
