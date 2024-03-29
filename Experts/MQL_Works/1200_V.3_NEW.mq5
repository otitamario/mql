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
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include<Trade\AccountInfo.mqh>
CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;

input string EAComment="Trend Direction EA";// EA Comment 
input string Main_Settings="====< Main Settings >====";   //  
input double Distance=400;   // "x" distance points
input double Lot=4;    // Lots 
input bool   Martingale      = 1;      // Use Martingale  
input double Multiplier      = 2;      // Martingale Multiplier  
input double _Stop=200;    // Stop Loss   
input double _TakeProfit=400;    // Take Profit     
input int    Magic_Number=111;      // Magic Number 

sinput string srealp="############------Realização Parcial------#################";
input double rp1=40;//Pontos R.P 1 (0 Não Usar)
input double _lts_rp1=25;//Porcentagem Lotes R.P 1
input double rp2=70;//Pontos R.P 2 (0 Não Usar)
input double _lts_rp2=25;//Porcentagem Lotes R.P 2
input double rp3=100;//Pontos R.P 3 (0 Não Usar)
input double _lts_rp3=25;//Porcentagem Lotes R.P 3

sinput string sbreak="########---------Break Even---------------###############";
input    bool              UseBreakEven=true;                          //Usar BreakEven
input    double               BreakEvenPoint1=100;                            //Pontos para BreakEven 1
input    double               ProfitPoint1=20;                             //Pontos de Lucro da Posicao 1
input    double               BreakEvenPoint2=150;                            //Pontos para BreakEven 2
input    double               ProfitPoint2=70;                            //Pontos de Lucro da Posicao 2
input    double               BreakEvenPoint3=200;                            //Pontos para BreakEven 3
input    double               ProfitPoint3=130;                            //Pontos de Lucro da Posicao 3
sinput string STrailing="############---------------Trailing Stop----------########";
input bool   Use_TraillingStop=true; //Usar Trailing 
input double TraillingStart=0;//Lucro Minimo Iniciar trailing stop
input double TraillingDistance=200;// Distanccia em Pontos do Stop Loss
input double TraillingStep=10;// Passo para atualizar Stop Loss
input string Time_Settings="====< Schedule Settings >====";//  
input bool   Use_Time_Filter = 0;      // Use Time Filter
input string Time_Start      = "00:00";// Time Start
input string Time_End        = "23:59";// Time End

                                       //HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
//+----------------------------------------------+
//--- declaration of integer variables for the indicators handles
datetime ctm[1],buy,sell;string gvp;
string original_symbol;
double ponto,ticksize,digits;
string glob_entr_tot="ENT_TOT"+Symbol()+IntegerToString(Magic_Number);
string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string tp_cp_tick="tp_cp_tick"+Symbol()+IntegerToString(Magic_Number),tp_vd_tick="tp_vd_tick"+Symbol()+IntegerToString(Magic_Number);
string stp_cp_tick="stp_cp_tick"+Symbol()+IntegerToString(Magic_Number),stp_vd_tick="stp_vd_tick"+Symbol()+IntegerToString(Magic_Number);
string deals_total="deals_total"+Symbol()+IntegerToString(Magic_Number),deals_total_prev="deals_total_prev"+Symbol()+IntegerToString(Magic_Number);
string gv_today="gv_today"+Symbol()+IntegerToString(Magic_Number),gv_today_prev="gv_today_prev"+Symbol()+IntegerToString(Magic_Number);
MqlDateTime TimeNow;
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
double buyprice,sellprice;
double lts_rp1,lts_rp2,lts_rp3;
double vol_pos,vol_stp,preco_stp;
double   PointBreakEven[3],PointProfit[3];
uint total_deals,cont_deals;
ulong ticket_history_deal,deal_magic;
//---
//HHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHHH//  
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---      
   TimeToStruct(TimeCurrent(),TimeNow);
   GlobalVariableSet(gv_today_prev,(double)TimeNow.day_of_year);

   gvp=_Symbol+"_"+IntegerToString(Magic_Number)+"_"+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_DEMO)gvp=gvp+"_d";
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_REAL)gvp=gvp+"_r";
   if(MQL5InfoInteger(MQL5_TESTING))gvp=gvp+"_t";
   original_symbol=Symbol();
   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.SetDeviationInPoints(50);
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
   if(!GlobalVariableCheck(glob_entr_tot))GlobalVariableSet(glob_entr_tot,0.0);
   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0.0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0.0);



   if(rp1<0 || rp2<0 || rp3<0)
     {
      string erro="Realização Parcial em Pontos deve ser>=0";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if((rp1>=rp2 && rp2>0) || (rp1>=rp3 && rp3>0) || (rp2>=rp3 && rp3>0))
     {
      string erro="As Realizações Parciais devem estar em ordem crescente";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(rp1+rp2+rp3>0 && _lts_rp1+_lts_rp2+_lts_rp3>100)
     {
      string erro="Soma das Porcentagens dos Lotes de Realização Parcial deve ser Menor ou igual a 100%";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(rp3>=_TakeProfit)
     {
      string erro="Realização Parcial  3 deve ser Menor que TakeProfit";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   PointBreakEven[0]=BreakEvenPoint1; PointBreakEven[1]=BreakEvenPoint2; PointBreakEven[2]=BreakEvenPoint3;
   PointProfit[0]=ProfitPoint1; PointProfit[1]=ProfitPoint2; PointProfit[2]=ProfitPoint3;
   for(int i=0;i<3;i++)
     {
      if(PointBreakEven[i]<PointProfit[i])
        {
         string erro="Profit do Break Even deve ser menor que o Ponto de Break Even";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);

        }

     }

   for(int i=0;i<2;i++)
     {
      if(PointBreakEven[i+1]<=PointBreakEven[i])
        {
         string erro="Pontos de Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);

        }

     }

   for(int i=0;i<2;i++)
     {
      if(PointProfit[i+1]<=PointProfit[i])
        {
         string erro="Pontos de Profit do Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);

        }

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

   mysymbol.Refresh();
   mysymbol.RefreshRates();

   if(mysymbol.Bid()>mysymbol.Ask())
     {
      Print("Ativo em leilão");
      return;
     }

   TimeToStruct(TimeCurrent(),TimeNow);
   GlobalVariableSet(gv_today,(double)TimeNow.day_of_year);

   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened())
     {
      CloseByPosition();
     }

   if(!PosicaoAberta())DeleteALL();
   Atual_vol_Stop_Take();

   MqlRates rt[];
//---  
   if(CopyRates(_Symbol,0,0,3,rt)<0) return;

   if(CopyTime(_Symbol,0,0,1,ctm)<0) return;    //  Comment(OP(),"\n",Orders(-1));

//---- Getting buy signals
   if(DayFilterResult() && rt[2].open>rt[2].close && Entry(0,rt[2].close)==1 && (OP()==0 || (GVGet("b")!=Entry(2) || OP()-rt[2].close>=Distance*point())))
     {
      if(Orders(-1)<1)
        {
         if(mytrade.Buy(Lot,original_symbol,0,0,0,"BUY"+exp_name))
           {
            GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
            buy=ctm[0]; GVSet("lot",Lot()); GVSet("b",Entry(2));
           }
         else Print("Erro enviar ordem ",GetLastError());

        }
     }

//---- Getting sell signals
   if(DayFilterResult() && rt[2].open<rt[2].close && Entry(1,rt[2].close)==1 && (OP()==0 || (GVGet("s")!=Entry(3) || rt[2].close-OP()>=Distance*point())))
     {
      if(Orders(-1)<1)
        {
         if(mytrade.Sell(Lot,original_symbol,0,0,0,"SELL"+exp_name))
           {
            sell=ctm[0];GVSet("lot",Lot()); GVSet("s",Entry(3));
            GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
           }
         else Print("Erro enviar ordem ",GetLastError());

        }
     }
//---
   if(Orders(-1)>0)
     {
      if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);
      if(UseBreakEven && PosicaoAberta())BreakEven(original_symbol,UseBreakEven,PointBreakEven,PointProfit);
      if(!DayFilterResult()) ClosePosition(_Symbol);
     }

   MytradeTransaction();

   if(HistorySelect(iTime(original_symbol,PERIOD_D1,0),TimeCurrent()))
     {
      total_deals=HistoryDealsTotal();
      ticket_history_deal=0;
      cont_deals=0;
      for(uint i=0;i<total_deals;i++)
        {
         //--- try to get deals ticket_history_deal
         if((ticket_history_deal=HistoryDealGetTicket(i))>0)
           {
            deal_magic=HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
            if(deal_magic==Magic_Number)cont_deals+=1;
           }
        }
     }
   GlobalVariableSet(deals_total_prev,(double)cont_deals);

   TimeToStruct(TimeCurrent(),TimeNow);
   GlobalVariableSet(gv_today_prev,(double)TimeNow.day_of_year);

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
   double lots=Lot;

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
         if(magic == Magic_Number && entry == DEAL_ENTRY_OUT)
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

         if(symbol==_Symbol && magic==Magic_Number && entry==DEAL_ENTRY_IN)
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
      if(Magic_Number==magic_order && Symbol()==position_symbol)
        {
         double sl_real=PositionGetDouble(POSITION_SL);
         double tp_real=PositionGetDouble(POSITION_TP);
         ZeroMemory(request);ZeroMemory(result);
         request.action   =TRADE_ACTION_DEAL;
         request.position =position_ticket;
         request.symbol   =position_symbol;
         request.deviation=100;
         request.magic    =Magic_Number;
         request.tp    =0;
         request.sl    =0;
         //---
         double bid=SymbolInfoDouble(position_symbol,SYMBOL_BID);
         double ask=SymbolInfoDouble(position_symbol,SYMBOL_ASK);
         double price=PositionGetDouble(POSITION_PRICE_OPEN);
         //---
         double our_lot=GVGet("lot");
         double lot_1_must_be =NormalizeDouble(our_lot - our_lot/100*_lts_rp1,dos);
         double lot_2_must_be =NormalizeDouble(lot_1_must_be - lot_1_must_be/100*_lts_rp2,dos);
         double lot_3_must_be =NormalizeDouble(lot_2_must_be - lot_2_must_be/100*_lts_rp3,dos);
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

            if(cur_dist>=rp1 && volume>lot_1_must_be && LOT_FOR_CLOSE_1>0.01)
              {
               Print("Try close part from buy, vol: ",volume," / will closed: ",LOT_FOR_CLOSE_1);
               request.volume=LOT_FOR_CLOSE_1;
               if(!OrderSend(request,result)) Print("Position buy close part 1 error: ",GetLastError());
               else {Print("Close buy part 1 done");break;}
              }

            if(cur_dist>=rp2 && volume>lot_2_must_be && LOT_FOR_CLOSE_2>0.01)
              {
               Print("Try close part from buy, vol: ",volume," / will closed: ",LOT_FOR_CLOSE_2);
               request.volume=LOT_FOR_CLOSE_2;
               if(!OrderSend(request,result)) Print("Position buy close part 2 error: ",GetLastError());
               else {Print("Close buy part 2 done");break;}
              }

            if(cur_dist>=rp3 && volume>lot_3_must_be && LOT_FOR_CLOSE_3>0.01)
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

            if(cur_dist>=rp1 && volume>lot_1_must_be && LOT_FOR_CLOSE_1>0.01)
              {
               Print("Try close part from sell, vol: ",volume," / will closed: ",LOT_FOR_CLOSE_1);
               request.volume=NormalizeDouble(LOT_FOR_CLOSE_1,dos);
               if(!OrderSend(request,result)) Print("Position sell close part 1 error: ",GetLastError());
               else {Print("Close sell part 1 done");break;}
              }

            if(cur_dist>=rp2 && volume>lot_2_must_be && LOT_FOR_CLOSE_2>0.01)
              {
               Print("Try close part from sell, vol: ",volume," / will closed: ",LOT_FOR_CLOSE_2);
               request.volume=NormalizeDouble(LOT_FOR_CLOSE_2,dos);
               if(!OrderSend(request,result)) Print("Position sell close part 2 error: ",GetLastError());
               else {Print("Close sell part 2 done");break;}
              }

            if(cur_dist>=rp3 && volume>lot_3_must_be && LOT_FOR_CLOSE_3>0.01)
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
      if(magic==Magic_Number && sl==0 && tp==0 && (nSL>0 || nTP>0))
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
         request.magic=Magic_Number;                // MagicNumber of the position 
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

      if(magic==Magic_Number)
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
         request.magic=Magic_Number;                    // MagicNumber of the position

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

      if(magic==Magic_Number)
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
//+------------------------------------------------------------------+
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=mysymbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
void MytradeTransaction()
  {
   ulong order_ticket;
   if(HistorySelect(iTime(original_symbol,PERIOD_D1,0),TimeCurrent()))
     {
      total_deals=HistoryDealsTotal();
      ticket_history_deal=0;
      cont_deals=0;
      for(uint i=0;i<total_deals;i++)
        {
         //--- try to get deals ticket_history_deal
         if((ticket_history_deal=HistoryDealGetTicket(i))>0)
           {
            deal_magic=HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
            if(deal_magic==Magic_Number)cont_deals+=1;
           }
        }

      GlobalVariableSet(deals_total,(double)cont_deals);

      if(GlobalVariableGet(deals_total)>GlobalVariableGet(deals_total_prev))
        {
         for(uint i=total_deals-1;i>=0;i--)
           {
            if(HistoryDealGetTicket(i)>0)
              {
               ulong deals_ticket=HistoryDealGetTicket(i);
               mydeal.Ticket(deals_ticket);
               order_ticket=mydeal.Order();
               if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number)
                 {
                  if(mydeal.Comment()=="BUY"+exp_name || mydeal.Comment()=="SELL"+exp_name)
                    {
                     GlobalVariableSet(glob_entr_tot,GlobalVariableGet(glob_entr_tot)+1);
                    }

                  if(order_ticket==(ulong)GlobalVariableGet(cp_tick))

                    {
                     myposition.SelectByTicket(order_ticket);
                     buyprice=NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
                     mytrade.SellLimit(Lot,NormalizeDouble(buyprice+_TakeProfit*ponto,digits),original_symbol,0,0,0,0,"TAKE PROFIT");
                     GlobalVariableSet(tp_vd_tick,(double)mytrade.ResultOrder());
                     mytrade.SellStop(Lot,NormalizeDouble(buyprice-_Stop*ponto,digits),original_symbol,0,0,0,0,"STOP");
                     GlobalVariableSet(stp_vd_tick,(double)mytrade.ResultOrder());
                     Real_Parc_Buy(Lot);
                    }
                  //--------------------------------------------------

                  if(order_ticket==(ulong)GlobalVariableGet(vd_tick))
                    {
                     myposition.SelectByTicket(order_ticket);
                     sellprice=NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
                     mytrade.BuyLimit(Lot,NormalizeDouble(sellprice-_TakeProfit*ponto,digits),original_symbol,0,0,0,0,"TAKE PROFIT");
                     GlobalVariableSet(tp_cp_tick,(double)mytrade.ResultOrder());
                     mytrade.BuyStop(Lot,NormalizeDouble(sellprice+_Stop*ponto,digits),original_symbol,0,0,0,0,"STOP");
                     GlobalVariableSet(stp_cp_tick,(double)mytrade.ResultOrder());
                     Real_Parc_Sell(Lot);
                    }
                  if(mydeal.Comment()=="TAKE PROFIT" || mydeal.Comment()=="STOP")
                    {
                     DeleteALL();
                     if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened())CloseByPosition();

                    }

                  return;
                 }//Fim mydeal symbol
              }// if histoticket>0
           }//Fim for total_deals
        }//Fim deals>prev
     }//Fim HistorySelect
  }
//+------------------------------------------------------------------+
void Real_Parc_Buy(double vol)
  {
   lts_rp1=0;
   lts_rp2=0;
   lts_rp3=0;
   if(vol>mysymbol.LotsMin())
     {
      myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick));
      if(rp1>0 && _lts_rp1>0)
        {
         lts_rp1=MathMin(MathFloor(0.01*_lts_rp1*vol/mysymbol.LotsStep())*mysymbol.LotsStep(),vol);
         lts_rp1=MathMax(lts_rp1,mysymbol.LotsMin());
        }
      if(rp2>0 && _lts_rp2>0)
        {
         lts_rp2=MathFloor(0.01*_lts_rp2*vol/mysymbol.LotsStep())*mysymbol.LotsStep();
         lts_rp2=MathMax(lts_rp2,mysymbol.LotsMin());
        }
      if(lts_rp1+lts_rp2>=vol)
        {
         lts_rp2=vol-lts_rp1;
         lts_rp3=0;
         // mytrade.PositionModify((ulong)GlobalVariableGet(cp_tick),myposition.StopLoss(),0);
         mytrade.OrderDelete((ulong)GlobalVariableGet(tp_vd_tick));
        }
      else
        {

         if(rp3>0 && _lts_rp3>0)
           {
            lts_rp3=MathFloor(0.01*_lts_rp3*vol/mysymbol.LotsStep())*mysymbol.LotsStep();
            lts_rp3=MathMax(lts_rp3,mysymbol.LotsMin());
           }
         if(lts_rp1+lts_rp2+lts_rp3>=vol)
           {
            lts_rp3=vol-lts_rp1-lts_rp2;
            //  mytrade.PositionModify((ulong)GlobalVariableGet(cp_tick),myposition.StopLoss(),0);
            mytrade.OrderDelete((ulong)GlobalVariableGet(tp_vd_tick));

           }
        }

      if(rp1>0&&lts_rp1>0)mytrade.SellLimit(lts_rp1,NormalizeDouble(MathRound((myposition.PriceOpen()+rp1*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,0,0,"PARCIAL 1");
      if(rp2>0&&lts_rp2>0)mytrade.SellLimit(lts_rp2,NormalizeDouble(MathRound((myposition.PriceOpen()+rp2*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,0,0,"PARCIAL 2");
      if(rp3>0&&lts_rp3>0)mytrade.SellLimit(lts_rp3,NormalizeDouble(MathRound((myposition.PriceOpen()+rp3*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,0,0,"PARCIAL 3");


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Real_Parc_Sell(double vol)
  {
   lts_rp1=0;
   lts_rp2=0;
   lts_rp3=0;
   if(vol>mysymbol.LotsMin())
     {
      myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick));
      if(rp1>0 && _lts_rp1>0)
        {
         lts_rp1=MathMin(MathFloor(0.01*_lts_rp1*vol/mysymbol.LotsStep())*mysymbol.LotsStep(),vol);
         lts_rp1=MathMax(lts_rp1,mysymbol.LotsMin());
        }
      if(rp2>0 && _lts_rp2>0)
        {
         lts_rp2=MathFloor(0.01*_lts_rp2*vol/mysymbol.LotsStep())*mysymbol.LotsStep();
         lts_rp2=MathMax(lts_rp2,mysymbol.LotsMin());
        }
      if(lts_rp1+lts_rp2>=vol)
        {
         lts_rp2=vol-lts_rp1;
         lts_rp3=0;
         // mytrade.PositionModify((ulong)GlobalVariableGet(cp_tick),myposition.StopLoss(),0);
         mytrade.OrderDelete((ulong)GlobalVariableGet(tp_cp_tick));
        }
      else
        {

         if(rp3>0 && _lts_rp3>0)
           {
            lts_rp3=MathFloor(0.01*_lts_rp3*vol/mysymbol.LotsStep())*mysymbol.LotsStep();
            lts_rp3=MathMax(lts_rp3,mysymbol.LotsMin());
           }
         if(lts_rp1+lts_rp2+lts_rp3>=vol)
           {
            lts_rp3=vol-lts_rp1-lts_rp2;
            //  mytrade.PositionModify((ulong)GlobalVariableGet(cp_tick),myposition.StopLoss(),0);
            mytrade.OrderDelete((ulong)GlobalVariableGet(tp_cp_tick));

           }
        }
      if(rp1>0&&lts_rp1>0)mytrade.BuyLimit(lts_rp1,NormalizeDouble(MathRound((myposition.PriceOpen()-rp1*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,0,0,"PARCIAL 1");
      if(rp2>0&&lts_rp2>0)mytrade.BuyLimit(lts_rp2,NormalizeDouble(MathRound((myposition.PriceOpen()-rp2*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,0,0,"PARCIAL 2");
      if(rp3>0&&lts_rp3>0)mytrade.BuyLimit(lts_rp3,NormalizeDouble(MathRound((myposition.PriceOpen()-rp3*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,0,0,"PARCIAL 3");


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
void CloseByPosition()
  {
   ulong tick_sell,tick_buy;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
ulong TickecBuyPos()
  {
   ulong tick=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Buy_opened())
     {

      for(int i=PositionsTotal()-1;i>=0; i--)
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong TickecSellPos()
  {
   ulong tick=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Sell_opened())
     {
      for(int i=PositionsTotal()-1;i>=0; i--)
         //+------------------------------------------------------------------+
         //|                                                                  |
         //+------------------------------------------------------------------+
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
               mytrade.SellStop(vol_pos,preco_stp,Symbol(),0,0,0,0,"STOP");
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
               mytrade.BuyStop(vol_pos,preco_stp,Symbol(),0,0,0,0,"STOP");
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
//|                                                                  |
//+------------------------------------------------------------------+
bool PosicaoAberta()
  {
   if(myposition.SelectByMagic(original_symbol,Magic_Number)==true)
      return(myposition.PositionType()== POSITION_TYPE_BUY||myposition.PositionType()== POSITION_TYPE_SELL);
   else return(false);
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
void TrailingStop(double pTrailPoints,double pMinProfit=0,double pStep=10)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number && pTrailPoints>0)
        {

         double currentTakeProfit=myposition.TakeProfit();
         long posType=myposition.PositionType();
         double currentStop;
         double openPrice=NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
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
            myorder.Select((ulong)GlobalVariableGet(stp_vd_tick));
            currentStop=myorder.PriceOpen();
            trailStopPrice = mysymbol.Bid() - trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=mysymbol.Bid()-openPrice;

            if(trailStopPrice>currentStop+step && currentProfit>=minProfit)
              {
               // mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
               if(myorder.Select((ulong)GlobalVariableGet(stp_vd_tick)))
                 {
                  mytrade.OrderModify((ulong)GlobalVariableGet(stp_vd_tick),trailStopPrice,0,0,0,0,0);
                 }
              }

           }
         else if(posType==POSITION_TYPE_SELL)
           {
            myorder.Select((ulong)GlobalVariableGet(stp_cp_tick));
            currentStop=myorder.PriceOpen();
            trailStopPrice = mysymbol.Ask() + trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=openPrice-mysymbol.Ask();

            if((trailStopPrice<currentStop-step || currentStop==0) && currentProfit>=minProfit)
              {
               //mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
               if(myorder.Select((ulong)GlobalVariableGet(stp_cp_tick)))
                 {
                  mytrade.OrderModify((ulong)GlobalVariableGet(stp_cp_tick),trailStopPrice,0,0,0,0,0);
                 }

              }

           }
        }

     }
  }
//+------------------------------------------------------------------+
void BreakEven(string pSymbol,bool usarbreak,double &pBreakEven[],double &pLockProfit[])
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && usarbreak==true)
        {

         long posType=myposition.PositionType();
         long posTicket=myposition.Ticket();
         double currentSL;
         double openPrice= NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
         double currentTP=myposition.TakeProfit();
         double breakEvenStop;
         double currentProfit;
         double bid,ask;

         if(posType==POSITION_TYPE_BUY)
           {
            myorder.Select((ulong)GlobalVariableGet(stp_vd_tick));
            currentSL=myorder.PriceOpen();
            //currentSL=myposition.StopLoss();
            bid=SymbolInfoDouble(pSymbol,SYMBOL_BID);
            currentProfit=mysymbol.Bid()-openPrice;
            //Break Even 0 a 1
            for(int k=0;k<2;k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop=openPrice+pLockProfit[k]*ponto;
                  breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
                  if(currentSL<breakEvenStop || currentSL==0)
                    {
                     if(k==0)Print("Break even stop 1:");
                     else Print("Break even stop 2:");
                     // mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                     mytrade.OrderModify((ulong)GlobalVariableGet(stp_vd_tick),breakEvenStop,0,0,0,0,0);
                     Print("");

                    }
                 }
              }
            //----------------------
            //Break Even 2
            if(currentProfit>=pBreakEven[2]*ponto)
              {
               breakEvenStop=openPrice+pLockProfit[2]*ponto;
               breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
               if(currentSL<breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop 3:");
                  // mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                  mytrade.OrderModify((ulong)GlobalVariableGet(stp_vd_tick),breakEvenStop,0,0,0,0,0);
                 }
              }
           }
         //----------------------

         //----------------------

         if(posType==POSITION_TYPE_SELL)
           {
            myorder.Select((ulong)GlobalVariableGet(stp_cp_tick));
            currentSL=myorder.PriceOpen();
            // currentSL=myposition.StopLoss();
            ask=SymbolInfoDouble(pSymbol,SYMBOL_ASK);
            currentProfit=openPrice-mysymbol.Ask();
            //Break Even 0 a 1
            for(int k=0;k<2;k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop=openPrice-pLockProfit[k]*ponto;
                  breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
                  if(currentSL>breakEvenStop || currentSL==0)
                    {
                     if(k==0)Print("Break even stop 1:");
                     else Print("Break even stop 2:");
                     //    mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                     mytrade.OrderModify((ulong)GlobalVariableGet(stp_cp_tick),breakEvenStop,0,0,0,0,0);
                     Print("");

                    }
                 }
              }
            //----------------------
            //Break Even 2
            if(currentProfit>=pBreakEven[2]*ponto)
              {
               breakEvenStop=openPrice-pLockProfit[2]*ponto;
               breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
               if(currentSL>breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop 3:");
                  // mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                  mytrade.OrderModify((ulong)GlobalVariableGet(stp_cp_tick),breakEvenStop,0,0,0,0,0);

                 }

              }
            //----------------------

           }

        } //Fim Position Select

     }//Fim for
  }
//+------------------------------------------------------------------+
