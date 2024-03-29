//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <EA_Igor\Params.mqh>
#include<ChartObjects\ChartObjectsLines.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class ATRStpRobot: public MyExpert
  {
private:
   CChartObjectHLine HLine_Entrada,HLine_SL,HLine_TP;
   CChartObjectHLine HLine_Break[5];
   CChartObjectHLine HLine_EntCont[6];
   CChartObjectHLine HLine_EntFav[4];

   string            currency_symbol;
   double            sl,tp,price_open;
   int               atr_handle;
   double            ATR_High[],ATR_Low[];
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   double            vol_pos,vol_stp,preco_stp;
   double            sl_position,tp_position;
   bool              opt_tester;
   double            PointBreakEven[5];
   double            PointProfit[5];
   bool              buy_signal,sell_signal;
   bool              trade_buy,trade_sell;
   string            last_trade;
public:
   void              ATRStpRobot();
   void             ~ATRStpRobot();
   int               OnInit();
   void              OnDeinit(const int reason);
   void              OnTick();
   void              OnTimer();
   string GetCurrency(){return SymbolInfoString(original_symbol,SYMBOL_CURRENCY_BASE);}
   bool              TimeDayFilter();
   virtual bool      GetIndValue();
   virtual bool      BuySignal();
   virtual bool      SellSignal();
   void              Entr_Parcial_Buy(const double preco);
   void              Entr_Parcial_Sell(const double preco);
   void              Entr_Favor_Buy(const double preco);
   void              Entr_Favor_Sell(const double preco);
   virtual void      Atual_vol_Stop_Take();
   void              Real_Parc_Sell(double vol,double preco);
   void              Real_Parc_Buy(double vol,double preco);
   void              CriandoTagPreco(color cor,string name_tag,double alvo);
   void              CreateLinesBreakBuy(double preco);
   void              CreateLinesBreakSell(double preco);
   void              CreateLinesContraBuy(double preco);
   void              CreateLinesContraSell(double preco);
   void              CreateLinesFavorBuy(double preco);
   void              CreateLinesFavorSell(double preco);
   void              SegurancaPos(int nsec);
   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::ATRStpRobot()
  {
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::~ATRStpRobot()
  {
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ATRStpRobot::OnInit(void)
  {

   trade_sell=true;
   trade_buy=true;
   last_trade="NEUTRO";
   tradeOn=true;
   setExpName();
   setSymbol(Symbol());
   if(simbolo=="")setOriginalSymbol(Symbol());
   else setOriginalSymbol(simbolo);
   setMagic(MAGIC_NUMBER);
   if(SymbolInfoInteger(original_symbol,SYMBOL_EXPIRATION_MODE)==2)order_time_type=1;
   else order_time_type=0;
   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(MAGIC_NUMBER);
   mytrade.SetDeviationInPoints(50);
   opt_tester=(MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_PROFILER)) && !MQLInfoInteger(MQL_VISUAL_MODE);
   if(!opt_tester) mytrade.LogLevel(LOG_LEVEL_NO);
   else mytrade.LogLevel(LOG_LEVEL_ERRORS);
   lucro_orders=LucroOrdens();
   if(!opt_tester)
     {
      lucro_orders_mes=LucroOrdensMes();
      lucro_orders_sem=LucroOrdensSemana();
     }

   mytrade.SetTypeFillingBySymbol(original_symbol);
   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);

   int find_wdo=StringFind(original_symbol,"WDO");
   int find_dol=StringFind(original_symbol,"DOL");
   if(find_dol>=0|| find_wdo>=0) ponto=1.0;
   gv.Init(symbol,Magic_Number);
   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today_prev",(double)TimeNow.day_of_year);

   setNameGvOrder();

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   ulong curChartID=ChartID();

   atr_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\atrstops_v1.ex5",Length,ATRPeriod,Kv,ShiftATR);

   ChartIndicatorAdd(ChartID(),0,atr_handle);

   ArraySetAsSeries(ATR_High,true);
   ArraySetAsSeries(ATR_Low,true);

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(ChartID(),CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(period_mfast>=period_minter || period_mfast>=period_mslow || period_minter>=period_mslow)
     {
      string erro="Os períodos das médias devem estar alinhados";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Lot<mysymbol.LotsMin())
     {
      string erro="Lote deve ser maior ou igual a "+DoubleToString(mysymbol.LotsMin(),2);
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(_lts_rp1*rp1+_lts_rp2*rp2+_lts_rp3*rp3>0 && _lts_rp1+_lts_rp2+_lts_rp3>=100)
     {
      string erro="A soma das porcentagems de realização parcial devem ser menor que 100";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(_lts_rp1*rp1+_lts_rp2*rp2+_lts_rp3*rp3>0 && (rp1>=_TakeProfit || rp2>=_TakeProfit || rp3>=_TakeProfit))
     {
      string erro="Os pontos de realização parcial devem ser menores que o Take Profit";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   PointBreakEven[0]=BreakEvenPoint1; PointBreakEven[1]=BreakEvenPoint2; PointBreakEven[2]=BreakEvenPoint3;
   PointBreakEven[3]=BreakEvenPoint4; PointBreakEven[4]=BreakEvenPoint5;
   PointProfit[0]=ProfitPoint1; PointProfit[1]=ProfitPoint2; PointProfit[2]=ProfitPoint3;
   PointProfit[3]=ProfitPoint4; PointProfit[4]=ProfitPoint5;


// parametros incorretos desnecessarios na otimizacao

   if(UseBreakEven)
     {
      for(int i=0;i<5;i++)
        {
         if(PointBreakEven[i]<PointProfit[i])
           {
            string erro="Profit do Break Even deve ser menor que o Ponto de Break Even";
            MessageBox(erro);
            Print(erro);
            return (INIT_PARAMETERS_INCORRECT);
           }

        }

      for(int i=0;i<4;i++)
        {
         if(PointBreakEven[i+1]<=PointBreakEven[i])
           {
            string erro="Pontos de Break Even devem estar em ordem crescente";
            MessageBox(erro);
            Print(erro);
            return (INIT_PARAMETERS_INCORRECT);

           }
        }

      for(int i=0;i<4;i++)
        {
         if(PointProfit[i+1]<=PointProfit[i])
           {
            string erro="Pontos de Profit do Break Even devem estar em ordem crescente";
            MessageBox(erro);
            Print(erro);
            return (INIT_PARAMETERS_INCORRECT);
           }

        }
     }
   bool stop_entr_cont=_Stop<=pts_entry1 || _Stop<=pts_entry2 || _Stop<=pts_entry3;
   stop_entr_cont=stop_entr_cont || _Stop<=pts_entry4 || _Stop<=pts_entry5 || _Stop<=pts_entry6;

   if(stop_entr_cont)
     {
      string erro="O Stop Máximo deve ser maior que todos pontos de aumento entrada";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   if(pts_entry1_fv>=_TakeProfit || pts_entry2_fv>=_TakeProfit || pts_entry3_fv>=_TakeProfit || pts_entry4_fv>=_TakeProfit)
     {
      string erro="Os pontos de entrada a favor devem ser menores que o Take Profit ";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   if(HistorySelect(iTime(original_symbol,PERIOD_D1,0),TimeCurrent()+PeriodSeconds(PERIOD_D1)))
     {
      int total_deals=HistoryDealsTotal();
      ulong ticket_history_deal=0;
      int cont_deals=0;
      for(int i=0;i<total_deals;i++)
        {
         //--- try to get deals ticket_history_deal
         if((ticket_history_deal=HistoryDealGetTicket(i))>0)
           {
            ulong deal_magic=HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
            if(deal_magic==Magic_Number && HistoryDealGetString(ticket_history_deal,DEAL_SYMBOL)==mysymbol.Name())cont_deals+=1;
           }
        }
      gv.Set("deals_total_prev",(double)cont_deals);

     }

   return(INIT_SUCCEEDED);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::OnTimer()
  {
   trade_buy=true;
   trade_sell=true;
   EventKillTimer();
   Print("Pausa de "+IntegerToString(n_minutesATR)+" minutos finalizada. Novas Entradas Permitidas");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   IndicatorRelease(atr_handle);
   DeletaIndicadores();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::OnTick(void)
  {

   static double profit=0.0;
   static double profit_prev=0.0;
   static double stop_partial_profit=0.0;

   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today",(double)TimeNow.day_of_year);

   bool novodia;
   novodia=Bar_NovoDia.CheckNewBar(original_symbol,PERIOD_D1);

   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      gv.Set("glob_entr_tot",0.0);
      gv.Set("deals_total_prev",0.0);
      trade_sell=true;
      trade_buy=true;
      last_trade="NEUTRO";
      tradeOn=true;
      profitstart=false;
      hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
      hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

      lucro_orders=LucroOrdens();
      if(!opt_tester)
        {
         lucro_orders_mes=LucroOrdensMes();
         lucro_orders_sem=LucroOrdensSemana();
        }
     }

   timerOn=true;

   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
     }

   if(!timerOn)
     {
      if(daytrade)
        {
         if(OrdersTotal()>0)DeleteALL();
         if(PositionsTotal()>0)CloseALL();
        }
      return;
     }

   if(!tradeOn)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
      int k1=ObjectsDeleteAll(ChartID(),-1,OBJ_HLINE);
      int k2=ObjectsDeleteAll(ChartID(),-1,OBJ_BUTTON);
      stop_partial_profit=0.0;
      return;
     }

   gv.Set("gv_today_prev",gv.Get("gv_today"));

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }
   if(bid>=ask) return;//Leilão

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//   lucro_total=LucroTotal();
   if(PosicaoAberta())lucro_positions=LucroPositions();
   else lucro_positions=0;
   lucro_total=lucro_orders+lucro_positions;
   if(!opt_tester)
     {
      lucro_total_semana=lucro_orders_sem+lucro_positions;
      lucro_total_mes=lucro_orders_mes+lucro_positions;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0) CloseALL();

      tradeOn=false;
      return;
     }

   profit=lucro_total;

   if(UsarTrailingProfit && profit>=TrailProfitMin1 && profit>=TrailStep+profit_prev)
      stop_partial_profit=profit*(1-TrailPerc1*0.01);

   if(UsarTrailingProfit && profit_prev>stop_partial_profit && profit<=stop_partial_profit && stop_partial_profit>0)
     {
      if(OrdersTotal()>0)
         DeleteALL();
      CloseALL();
      tradeOn=false;
      Print("EA encerrado na meta parcial");
      return;
     }

   profit_prev=profit;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened()) CloseByPosition();

   if(!PosicaoAberta())
     {
      if(OrdersTotal()>0)DeleteALL();
      int k=ObjectsDeleteAll(0,"",0,OBJ_HLINE);
      int j=ObjectsDeleteAll(0,"",0,OBJ_BUTTON);
      gv.Set("preco_break",0.0);
     }
   else
     {
      if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);
      if(UseBreakEven)BreakEven(original_symbol,UseBreakEven,PointBreakEven,PointProfit);
      Atual_vol_Stop_Take();
      if(myposition.SelectByTicket((ulong)gv.Get("cp_tick")))
        {
         if(myposition.StopLoss()>0)gv.Set("sl_position",myposition.StopLoss());
        }
      if(myposition.SelectByTicket((ulong)gv.Get("vd_tick")))
        {
         if(myposition.StopLoss()>0)gv.Set("sl_position",myposition.StopLoss());
        }

      ObjectDelete(0,"StopLoss");
      ObjectDelete(0,"Line_SL");
      CriandoTagPreco(clrLime,"StopLoss",gv.Get("sl_position"));
      HLine_SL.Create(0,"Line_SL",0,gv.Get("sl_position"));
      HLine_SL.Color(clrLime);

     }

   if(tradeOn && timerOn)

     {// inicio Trade On

      if(PosicaoAberta())
        {
         for(int i=PositionsTotal()-1; i>=0; i--)
           {
            if(myposition.SelectByIndex(i))
              {
               if(myposition.Symbol()!=mysymbol.Name())continue;
               if(myposition.Magic()!=Magic_Number)continue;
               if(myposition.StopLoss()>0)continue;
               if(myposition.Comment()=="TAKE PROFIT")continue;
               if(myposition.Comment()=="BUY"+exp_name||myposition.Comment()=="SELL"+exp_name)continue;
               if(myposition.StopLoss()==0)
                  mytrade.PositionModify(myposition.Ticket(),gv.Get("sl_position"),0);
              }
           }

         for(int i=PositionsTotal()-1; i>=0; i--)
           {
            if(myposition.SelectByIndex(i))
              {
               if(myposition.Symbol()!=mysymbol.Name())continue;
               if(myposition.Magic()!=Magic_Number)continue;
               if(myposition.StopLoss()>0)continue;
               if(myposition.StopLoss()==0)
                  mytrade.PositionClose(myposition.Ticket());
              }
           }

        }

      if(Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo))
        {

         if(GetIndValue())
           {
            Print("Error in obtain indicators buffers or price rates");
            return;
           }

         buy_signal=BuySignal() && !PosicaoAberta();
         sell_signal=SellSignal() && !PosicaoAberta();

         if(ReverterSigATR)
           {
            buy_signal=BuySignal() && !Buy_opened();
            sell_signal=SellSignal() && !Sell_opened();
           }

         if(ReverterSigATR)
           {
            buy_signal=buy_signal && trade_buy;
            sell_signal=sell_signal && trade_sell;
           }

         buy_signal=buy_signal && TimeEnt && AdxAllow;
         sell_signal=sell_signal && TimeEnt && AdxAllow;

         if(buy_signal)
           {
            if(OrdersTotal()>0)DeleteALL();
            if(PositionsTotal()>0)CloseALL();
            if(mytrade.Buy(Lot,original_symbol,0,NormalizeDouble(bid-_Stop*ponto,digits),NormalizeDouble(ask+_TakeProfit*ponto,digits),"BUY"+exp_name))
              {
               gv.Set(cp_tick,(double)mytrade.ResultOrder());
              }
            else Print("Erro enviar ordem ",GetLastError());
           }

         if(sell_signal)
           {
            if(OrdersTotal()>0)DeleteALL();
            if(PositionsTotal()>0)CloseALL();
            if(mytrade.Sell(Lot,original_symbol,0,NormalizeDouble(ask+_Stop*ponto,digits),NormalizeDouble(bid-_TakeProfit*ponto,digits),"SELL"+exp_name))
              {
               gv.Set(vd_tick,(double)mytrade.ResultOrder());
              }
            else Print("Erro enviar ordem ",GetLastError());

           }
        }//End NewBar 

     }//End Trade On

  }//Fim Ontick
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool ATRStpRobot::GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(atr_handle,0,0,5,ATR_High)<=0 || 
         CopyBuffer(atr_handle,1,0,5,ATR_Low)<=0 || 
         CopyHigh(Symbol(),period,0,5,high)<=0 ||
         CopyOpen(Symbol(),period,0,5,open)<=0 ||
         CopyLow(Symbol(),period,0,5,low)<=0 || 
         CopyClose(Symbol(),period,0,5,close)<=0;

   return(b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ATRStpRobot::TimeDayFilter()
  {
   bool filter;
   MqlDateTime TimeToday;
   TimeToStruct(TimeCurrent(),TimeToday);
   switch(TimeToday.day_of_week)
     {
      case 0:
         filter=trade0;
         break;
      case 1:
         filter=trade1;
         break;
      case 2:
         filter=trade2;
         break;
      case 3:
         filter=trade3;
         break;
      case 4:
         filter=trade4;
         break;
      case 5:
         filter=trade5;
         break;
      case 6:
         filter=trade6;
         break;
      default:
         filter=false;
         break;
     }
   return filter;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ATRStpRobot::BuySignal()
  {
   bool signal;
   signal=ATR_High[1]!=EMPTY_VALUE && ATR_High[2]==EMPTY_VALUE;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ATRStpRobot::SellSignal()
  {
   bool signal;
   signal=ATR_Low[1]!=EMPTY_VALUE && ATR_Low[2]==EMPTY_VALUE;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::OnTradeTransaction(const MqlTradeTransaction &trans,
                                     const MqlTradeRequest &request,
                                     const MqlTradeResult &result)
  {

   if(trans.symbol!=original_symbol)
      return;
   double buyprice,sellprice;
   int TENTATIVAS=10;

//--- get transaction type as enumeration value
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history

   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long deal_ticket= 0;
      long deal_order = 0;
      long deal_time=0;
      long deal_time_msc=0;
      ENUM_DEAL_TYPE deal_type=-1;
      long deal_entry=-1;
      ulong deal_magic = 0;
      long deal_reason = -1;
      long deal_position_id=0;
      double deal_volume= 0.0;
      double deal_price = 0.0;
      double deal_commission=0.0;
      double deal_swap=0.0;
      double deal_profit = 0.0;
      string deal_symbol = "";
      string deal_comment= "";
      string deal_external_id="";
      if(HistoryDealSelect(trans.deal))
        {
         deal_ticket= HistoryDealGetInteger(trans.deal,DEAL_TICKET);
         deal_order = HistoryDealGetInteger(trans.deal,DEAL_ORDER);
         myorder.Select(deal_order);
         deal_time=HistoryDealGetInteger(trans.deal,DEAL_TIME);
         deal_time_msc=HistoryDealGetInteger(trans.deal,DEAL_TIME_MSC);
         deal_type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
         deal_magic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
         deal_reason= HistoryDealGetInteger(trans.deal,DEAL_REASON);
         deal_position_id=HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);

         deal_volume= HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_price = HistoryDealGetDouble(trans.deal,DEAL_PRICE);
         deal_commission=HistoryDealGetDouble(trans.deal,DEAL_COMMISSION);
         deal_swap=HistoryDealGetDouble(trans.deal,DEAL_SWAP);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);

         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_comment=HistoryDealGetString(trans.deal,DEAL_COMMENT);
         deal_external_id=HistoryDealGetString(trans.deal,DEAL_EXTERNAL_ID);

         if(deal_symbol!=original_symbol)
            return;
         if(deal_magic==Magic_Number)
           {

            gv.Set("last_deal_time",(double)deal_time);

            if((deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL) && (deal_entry==DEAL_ENTRY_OUT || deal_entry==DEAL_ENTRY_OUT_BY))
              {
               if(profitstart)tradeOn=false;

               if(deal_profit<0)
                 {
                  Print("Saída por STOP LOSS");
                  Print("Pausa de "+IntegerToString(n_minutesATR)+" minutos Interrompida. Novas Entradas Permitidas");
                  EventKillTimer();
                  trade_buy=true;
                  trade_sell=true;
                 }

               if(deal_profit>0)
                 {
                  Print("Saída no GAIN");
                  if(profitstart)tradeOn=false;
                  if(UseBreakEven && gv.Get("preco_break")>0 && mydeal.Price()>=gv.Get("preco_break"))
                    {
                     Print("break Even. Pausa de "+IntegerToString(n_minutesATR)+" minutos Interrompida. Novas Entradas Permitidas");
                     EventKillTimer();
                     trade_buy=true;
                     trade_sell=true;
                    }
                 }
              }

            lucro_orders=LucroOrdens();
            lucro_orders_mes = LucroOrdensMes();
            lucro_orders_sem = LucroOrdensSemana();

           } //Fim deal magic
        }
      else
         return;
     }

   if(type==TRADE_TRANSACTION_HISTORY_ADD)
     {
      if(HistoryOrderSelect(trans.order))
        {
         myhistory.Ticket(trans.order);
         if(myhistory.Magic()!=(long)Magic_Number)return;
         if((myhistory.Comment()=="BUY"+exp_name || myhistory.Comment()=="SELL"+exp_name) && trans.order_state==ORDER_STATE_FILLED)
           {
            gv.Set("glob_entr_tot",gv.Get("glob_entr_tot")+1);
           }

         if(myhistory.Comment()=="BUY"+exp_name && trans.order_state==ORDER_STATE_FILLED)
           {
            if(ReverterSigATR && last_trade=="SELL" && n_minutesATR>0)
              {
               trade_sell=false;
               EventSetTimer(n_minutesATR*60);
              }
            last_trade="BUY";
            myposition.SelectByTicket(trans.order);
            int cont=0;
            buyprice=0;
            while(buyprice==0 && cont<TENTATIVAS)
              {
               buyprice=myposition.PriceOpen();
               cont+=1;
              }
            if(buyprice==0)buyprice=mysymbol.Ask();

            sl_position=NormalizeDouble(buyprice-_Stop*ponto,digits);
            tp_position=NormalizeDouble(buyprice+_TakeProfit*ponto,digits);
            mytrade.PositionModify(trans.order,sl_position,0);
            if(mytrade.SellLimit(Lot,tp_position,original_symbol,0,0,order_time_type,0,"TAKE PROFIT"))
              {
               gv.Set("tp_vd_tick",(double)mytrade.ResultOrder());
               CriandoTagPreco(clrLightPink,"TakeProfit",tp_position);
               HLine_TP.Create(0,"Line_TP",0,tp_position);
               HLine_TP.Color(clrLightPink);
              }
            else
               Print("Erro enviar ordem: ",GetLastError());

            Entr_Parcial_Buy(buyprice);
            Entr_Favor_Buy(buyprice);
            Real_Parc_Buy(Lot,buyprice);

            CriandoTagPreco(clrAqua,"Entrada",buyprice);
            HLine_Entrada.Create(0,"Line_Entrada",0,buyprice);
            HLine_Entrada.Color(clrAqua);
            CreateLinesBreakBuy(buyprice);
            CreateLinesContraBuy(buyprice);
            CreateLinesFavorBuy(buyprice);
           }
         //--------------------------------------------------

         if(myhistory.Comment()=="SELL"+exp_name && trans.order_state==ORDER_STATE_FILLED)

           {

            if(ReverterSigATR && last_trade=="BUY" && n_minutesATR>0)
              {
               trade_buy=false;
               EventSetTimer(n_minutesATR*60);
              }
            last_trade="SELL";

            myposition.SelectByTicket(trans.order);
            sellprice=myposition.PriceOpen();
            int cont=0;
            sellprice=0;
            while(sellprice==0 && cont<TENTATIVAS)
              {
               sellprice=myposition.PriceOpen();
               cont+=1;
              }
            if(sellprice==0)sellprice=mysymbol.Bid();

            sl_position=NormalizeDouble(sellprice+_Stop*ponto,digits);
            tp_position=NormalizeDouble(sellprice-_TakeProfit*ponto,digits);
            mytrade.PositionModify(trans.order,sl_position,0);
            if(mytrade.BuyLimit(Lot,tp_position,original_symbol,0,0,order_time_type,0,"TAKE PROFIT"))
              {
               gv.Set("tp_cp_tick",(double)mytrade.ResultOrder());
               CriandoTagPreco(clrLightPink,"TakeProfit",tp_position);
               HLine_TP.Create(0,"Line_TP",0,tp_position);
               HLine_TP.Color(clrLightPink);

              }
            else
               Print("Erro enviar ordem: ",GetLastError());

            Entr_Parcial_Sell(sellprice);
            Entr_Favor_Sell(sellprice);
            Real_Parc_Sell(Lot,sellprice);

            CriandoTagPreco(clrAqua,"Entrada",sellprice);
            HLine_Entrada.Create(0,"Line_Entrada",0,sellprice);
            HLine_Entrada.Color(clrAqua);
            CreateLinesBreakSell(sellprice);
            CreateLinesContraSell(sellprice);
            CreateLinesFavorSell(sellprice);
           }

         if(StringFind(myhistory.Comment(),"Entrada Parcial")>=0)
           {
            if(Buy_opened())
              {
               sl_position=gv.Get("sl_position");
               myposition.SelectByTicket((ulong)gv.Get("cp_tick"));
               if(myposition.StopLoss()==0)mytrade.PositionModify(myposition.Ticket(),sl_position,0);

               if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
                 {
                  for(int i=PositionsTotal()-1;i>=0; i--)
                    {
                     if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_BUY && myposition.Symbol()==mysymbol.Name())
                       {
                        if(myposition.StopLoss()==0)mytrade.PositionModify(myposition.Ticket(),sl_position,0);
                       }
                    }
                 }
               if(pts_saida_aumento>0) mytrade.SellLimit(mydeal.Volume(),NormalizeDouble(mydeal.Price()+pts_saida_aumento*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Aumento");

              }

            if(Sell_opened())
              {
               sl_position=gv.Get("sl_position");
               myposition.SelectByTicket((ulong)gv.Get("vd_tick"));
               if(myposition.StopLoss()==0)mytrade.PositionModify(myposition.Ticket(),sl_position,0);

               if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
                 {
                  for(int i=PositionsTotal()-1;i>=0; i--)
                    {
                     if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_SELL && myposition.Symbol()==mysymbol.Name())
                       {
                        if(myposition.StopLoss()==0)mytrade.PositionModify(myposition.Ticket(),sl_position,0);
                       }
                    }
                 }

               if(pts_saida_aumento>0) mytrade.BuyLimit(mydeal.Volume(),NormalizeDouble(mydeal.Price()-pts_saida_aumento*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Aumento");
              }
           }

         if(StringFind(myhistory.Comment(),"Entrada Favor")>=0)
           {
            if(Buy_opened())
              {
               sl_position=gv.Get("sl_position");
               myposition.SelectByTicket((ulong)gv.Get("cp_tick"));
               if(myposition.StopLoss()==0)mytrade.PositionModify(myposition.Ticket(),sl_position,0);
               if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
                 {
                  for(int i=PositionsTotal()-1;i>=0; i--)
                    {
                     if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_BUY && myposition.Symbol()==mysymbol.Name())
                       {
                        if(myposition.StopLoss()==0)mytrade.PositionModify(myposition.Ticket(),sl_position,0);
                       }
                    }
                 }
               if(pts_saida_aumento_fv>0) mytrade.SellLimit(mydeal.Volume(),NormalizeDouble(mydeal.Price()+pts_saida_aumento_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Favor");
              }

            if(Sell_opened())
              {
               sl_position=gv.Get("sl_position");
               myposition.SelectByTicket((ulong)gv.Get("vd_tick"));
               if(myposition.StopLoss()==0)mytrade.PositionModify(myposition.Ticket(),sl_position,0);

               if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
                 {
                  for(int i=PositionsTotal()-1;i>=0; i--)
                    {
                     if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_SELL && myposition.Symbol()==mysymbol.Name())
                       {
                        if(myposition.StopLoss()==0)mytrade.PositionModify(myposition.Ticket(),sl_position,0);
                       }
                    }
                 }
               if(pts_saida_aumento_fv>0) mytrade.BuyLimit(mydeal.Volume(),NormalizeDouble(mydeal.Price()-pts_saida_aumento_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Favor");
              }
           }
        }
     }//FIM TRANSACTION HISTOY ADD
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::Entr_Parcial_Buy(const double preco)
  {
   sl_position=NormalizeDouble(preco-_Stop*ponto,digits);
   if(Lot_entry1>0) mytrade.BuyLimit(Lot_entry1,NormalizeDouble(preco-pts_entry1*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 1");
   if(Lot_entry2>0) mytrade.BuyLimit(Lot_entry2,NormalizeDouble(preco-pts_entry2*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 2");
   if(Lot_entry3>0) mytrade.BuyLimit(Lot_entry3,NormalizeDouble(preco-pts_entry3*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 3");
   if(Lot_entry4>0) mytrade.BuyLimit(Lot_entry4,NormalizeDouble(preco-pts_entry4*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 4");
   if(Lot_entry5>0) mytrade.BuyLimit(Lot_entry5,NormalizeDouble(preco-pts_entry5*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 5");
   if(Lot_entry6>0) mytrade.BuyLimit(Lot_entry6,NormalizeDouble(preco-pts_entry6*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 6");
  }
//+------------------------------------------------------------------+
void ATRStpRobot::Entr_Parcial_Sell(const double preco)
  {
   sl_position=NormalizeDouble(preco+_Stop*ponto,digits);
   if(Lot_entry1>0) mytrade.SellLimit(Lot_entry1,NormalizeDouble(preco+pts_entry1*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 1");
   if(Lot_entry2>0) mytrade.SellLimit(Lot_entry2,NormalizeDouble(preco+pts_entry2*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 2");
   if(Lot_entry3>0) mytrade.SellLimit(Lot_entry3,NormalizeDouble(preco+pts_entry3*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 3");
   if(Lot_entry4>0) mytrade.SellLimit(Lot_entry4,NormalizeDouble(preco+pts_entry4*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 4");
   if(Lot_entry5>0) mytrade.SellLimit(Lot_entry5,NormalizeDouble(preco+pts_entry5*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 5");
   if(Lot_entry6>0) mytrade.SellLimit(Lot_entry6,NormalizeDouble(preco+pts_entry6*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 6");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::Entr_Favor_Buy(const double preco)
  {

   sl_position=NormalizeDouble(preco-_Stop*ponto,digits);
   if(Lot_entry1_fv>0) mytrade.BuyStop(Lot_entry1_fv,NormalizeDouble(preco+pts_entry1_fv*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Favor 1");
   if(Lot_entry2_fv>0) mytrade.BuyStop(Lot_entry2_fv,NormalizeDouble(preco+pts_entry2_fv*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Favor 2");
   if(Lot_entry3_fv>0) mytrade.BuyStop(Lot_entry3_fv,NormalizeDouble(preco+pts_entry3_fv*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Favor 3");
   if(Lot_entry4_fv>0) mytrade.BuyStop(Lot_entry4_fv,NormalizeDouble(preco+pts_entry4_fv*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Favor 4");
  }
//+------------------------------------------------------------------+
void ATRStpRobot::Entr_Favor_Sell(const double preco)
  {
   sl_position=NormalizeDouble(preco+_Stop*ponto,digits);
   if(Lot_entry1_fv>0) mytrade.SellStop(Lot_entry1_fv,NormalizeDouble(preco-pts_entry1_fv*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Favor 1");
   if(Lot_entry2_fv>0) mytrade.SellStop(Lot_entry2_fv,NormalizeDouble(preco-pts_entry2_fv*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Favor 2");
   if(Lot_entry3_fv>0) mytrade.SellStop(Lot_entry3_fv,NormalizeDouble(preco-pts_entry3_fv*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Favor 3");
   if(Lot_entry4_fv>0) mytrade.SellStop(Lot_entry4_fv,NormalizeDouble(preco-pts_entry4_fv*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Favor 4");
  }
//+------------------------------------------------------------------+

void ATRStpRobot::Atual_vol_Stop_Take()
  {
   double vol_ent_contra,vol_ent_fav,vol_parc;
   vol_ent_contra=VolumeOrdensCmt("Saída Aumento");
   vol_ent_fav=VolumeOrdensCmt("Saída Favor");
   vol_parc=VolumeOrdensCmt("PARCIAL 1")+VolumeOrdensCmt("PARCIAL 2")+VolumeOrdensCmt("PARCIAL 3");
   if(Buy_opened())
     {
      if(myposition.SelectByTicket((ulong)gv.Get("cp_tick")) && myorder.Select((ulong)gv.Get("tp_vd_tick")))
        {
         vol_pos = VolPosType(POSITION_TYPE_BUY)-vol_ent_contra-vol_ent_fav-vol_parc;
         vol_stp = myorder.VolumeInitial();
         //  preco_stp=myorder.PriceOpen();
         preco_stp=NormalizeDouble(PrecoMedio(POSITION_TYPE_BUY)+_TakeProfit*ponto,digits);

         if(vol_pos!=vol_stp)
           {
            mytrade.OrderDelete((ulong)gv.Get("tp_vd_tick"));
            mytrade.SellLimit(vol_pos, preco_stp, original_symbol, 0, 0, order_time_type, 0, "TAKE PROFIT");
            gv.Set("tp_vd_tick",(double)mytrade.ResultOrder());
            ObjectDelete(0,"TakeProfit");
            ObjectDelete(0,"Line_TP");
            CriandoTagPreco(clrLightPink,"TakeProfit",preco_stp);
            HLine_TP.Create(0,"Line_TP",0,preco_stp);
            HLine_TP.Color(clrLightPink);

           }
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Sell_opened())
     {

      if(myposition.SelectByTicket((ulong)gv.Get("vd_tick")) && myorder.Select((ulong)gv.Get("tp_cp_tick")))
        {
         vol_pos = VolPosType(POSITION_TYPE_SELL)-vol_ent_contra-vol_ent_fav-vol_parc;
         vol_stp = myorder.VolumeInitial();
         //         preco_stp=myorder.PriceOpen();
         preco_stp=NormalizeDouble(PrecoMedio(POSITION_TYPE_SELL)-_TakeProfit*ponto,digits);

         if(vol_pos!=vol_stp)
           {
            mytrade.OrderDelete((ulong)gv.Get("tp_cp_tick"));
            mytrade.BuyLimit(vol_pos, preco_stp, original_symbol, 0, 0, order_time_type, 0, "TAKE PROFIT");
            gv.Set("tp_cp_tick",(double)mytrade.ResultOrder());
            ObjectDelete(0,"TakeProfit");
            ObjectDelete(0,"Line_TP");
            CriandoTagPreco(clrLightPink,"TakeProfit",preco_stp);
            HLine_TP.Create(0,"Line_TP",0,preco_stp);
            HLine_TP.Color(clrLightPink);

           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::Real_Parc_Buy(double vol,double preco)
  {
   double lts_rp1=0;
   double lts_rp2=0;
   double lts_rp3=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(vol>mysymbol.LotsMin())
     {
      myposition.SelectByTicket((ulong)gv.Get(cp_tick));
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
         mytrade.PositionModify((ulong)gv.Get(cp_tick),myposition.StopLoss(),0);
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
            mytrade.PositionModify((ulong)gv.Get(cp_tick),myposition.StopLoss(),0);

           }
        }

      if(rp1>0&&lts_rp1>0)mytrade.SellLimit(lts_rp1,NormalizeDouble(MathRound((preco+rp1*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 1");
      if(rp2>0&&lts_rp2>0)mytrade.SellLimit(lts_rp2,NormalizeDouble(MathRound((preco+rp2*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 2");
      if(rp3>0&&lts_rp3>0)mytrade.SellLimit(lts_rp3,NormalizeDouble(MathRound((preco+rp3*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 3");


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::Real_Parc_Sell(double vol,double preco)
  {
   double lts_rp1=0;
   double lts_rp2=0;
   double lts_rp3=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(vol>mysymbol.LotsMin())
     {
      myposition.SelectByTicket((ulong)gv.Get(vd_tick));
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
         mytrade.PositionModify((ulong)gv.Get(cp_tick),myposition.StopLoss(),0);
         //mytrade.OrderDelete((ulong)GlobalVariableGet(tp_cp_tick));
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
            mytrade.PositionModify((ulong)gv.Get(cp_tick),myposition.StopLoss(),0);
            // mytrade.OrderDelete((ulong)GlobalVariableGet(tp_cp_tick));

           }
        }
      if(rp1>0&&lts_rp1>0)mytrade.BuyLimit(lts_rp1,NormalizeDouble(MathRound((preco-rp1*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 1");
      if(rp2>0&&lts_rp2>0)mytrade.BuyLimit(lts_rp2,NormalizeDouble(MathRound((preco-rp2*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 2");
      if(rp3>0&&lts_rp3>0)mytrade.BuyLimit(lts_rp3,NormalizeDouble(MathRound((preco-rp3*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 3");


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::SegurancaPos(int nsec)
  {
   if(PosicaoAberta())
     {
      for(int i=PositionsTotal()-1; i>=0; i--)
        {
         if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
           {
            if(myposition.StopLoss()==0 && TimeCurrent()-((datetime)gv.Get("last_deal_time"))>=nsec)
              {
               mytrade.PositionClose(myposition.Ticket());
               Print(__FUNCTION__," Fechando Posição Por Segurança");
              }
           }
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::CriandoTagPreco(color cor,string name_tag,double alvo)
  {
   ObjectCreate(0,name_tag,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,name_tag,OBJPROP_CORNER,3);
   ObjectSetInteger(0,name_tag,OBJPROP_XDISTANCE,CHART_HEIGHT_IN_PIXELS-5);

   int x,y;
   ChartTimePriceToXY(0,0,0,alvo,x,y);
   ObjectSetInteger(0,name_tag,OBJPROP_YDISTANCE,y);

   ObjectSetInteger(0,name_tag,OBJPROP_XSIZE,100);
   ObjectSetInteger(0,name_tag,OBJPROP_YSIZE,14);
   ObjectSetInteger(0,name_tag,OBJPROP_READONLY,true);
   ObjectSetInteger(0,name_tag,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name_tag,OBJPROP_BACK,false);
   ObjectSetInteger(0,name_tag,OBJPROP_FONTSIZE,8);

   ObjectSetInteger(0,name_tag,OBJPROP_BGCOLOR,cor);
   ObjectSetInteger(0,name_tag,OBJPROP_BORDER_COLOR,cor);
   ObjectSetString(0,name_tag,OBJPROP_TEXT,name_tag);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::CreateLinesBreakBuy(double preco)
  {
   if(UseBreakEven)
     {
      for(int i=0;i<5;i++)
        {
         double preco_break=NormalizeDouble(preco+PointBreakEven[i]*ponto,_Digits);
         if(i==0)gv.Set("preco_break",preco_break);
         CriandoTagPreco(clrYellow,"Break Even "+IntegerToString(i+1),preco_break);
         HLine_Break[i].Create(0,"Line_Break Even "+IntegerToString(i+1),0,preco_break);
         HLine_Break[i].Color(clrYellow);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::CreateLinesBreakSell(double preco)
  {
   if(UseBreakEven)
     {
      for(int i=0;i<5;i++)
        {
         double preco_break=NormalizeDouble(preco-PointBreakEven[i]*ponto,_Digits);
         if(i==0)gv.Set("preco_break",preco_break);
         CriandoTagPreco(clrYellow,"Break Even "+IntegerToString(i+1),preco_break);
         HLine_Break[i].Create(0,"Line_Break Even "+IntegerToString(i+1),0,preco_break);
         HLine_Break[i].Color(clrYellow);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::CreateLinesContraBuy(double preco)
  {
   double Entr_Cont_Buf[6];
   double preco_break;
   Entr_Cont_Buf[0]=pts_entry1; Entr_Cont_Buf[1]=pts_entry2; Entr_Cont_Buf[2]=pts_entry3;
   Entr_Cont_Buf[3]=pts_entry4; Entr_Cont_Buf[4]=pts_entry5;Entr_Cont_Buf[5]=pts_entry6;

   for(int i=0;i<6;i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(Entr_Cont_Buf[i]>0)
        {
         preco_break=NormalizeDouble(preco-Entr_Cont_Buf[i]*ponto,_Digits);
         CriandoTagPreco(clrSalmon,"Entrada_Contra"+IntegerToString(i+1),preco_break);
         HLine_EntCont[i].Create(0,"Line_Contra"+IntegerToString(i+1),0,preco_break);
         HLine_EntCont[i].Color(clrSalmon);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::CreateLinesContraSell(double preco)
  {
   double Entr_Cont_Buf[6];
   double preco_break;
   Entr_Cont_Buf[0]=pts_entry1; Entr_Cont_Buf[1]=pts_entry2; Entr_Cont_Buf[2]=pts_entry3;
   Entr_Cont_Buf[3]=pts_entry4; Entr_Cont_Buf[4]=pts_entry5;Entr_Cont_Buf[5]=pts_entry6;

   for(int i=0;i<6;i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(Entr_Cont_Buf[i]>0)
        {
         preco_break=NormalizeDouble(preco+Entr_Cont_Buf[i]*ponto,_Digits);
         CriandoTagPreco(clrSalmon,"Entrada_Contra"+IntegerToString(i+1),preco_break);
         HLine_EntCont[i].Create(0,"Line_Contra"+IntegerToString(i+1),0,preco_break);
         HLine_EntCont[i].Color(clrSalmon);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::CreateLinesFavorBuy(double preco)
  {
   double Entr_Fv_Buf[4];
   double preco_break;
   Entr_Fv_Buf[0]=pts_entry1_fv; Entr_Fv_Buf[1]=pts_entry2_fv; Entr_Fv_Buf[2]=pts_entry3_fv;
   Entr_Fv_Buf[3]=pts_entry4_fv;
   for(int i=0;i<4;i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(Entr_Fv_Buf[i]>0)
        {
         preco_break=NormalizeDouble(preco+Entr_Fv_Buf[i]*ponto,_Digits);
         CriandoTagPreco(clrLightGray,"Entrada_Favor"+IntegerToString(i+1),preco_break);
         HLine_EntFav[i].Create(0,"Line_Favor"+IntegerToString(i+1),0,preco_break);
         HLine_EntFav[i].Color(clrLightGray);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ATRStpRobot::CreateLinesFavorSell(double preco)
  {
   double Entr_Fv_Buf[4];
   double preco_break;
   Entr_Fv_Buf[0]=pts_entry1_fv; Entr_Fv_Buf[1]=pts_entry2_fv; Entr_Fv_Buf[2]=pts_entry3_fv;
   Entr_Fv_Buf[3]=pts_entry4_fv;
   for(int i=0;i<4;i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(Entr_Fv_Buf[i]>0)
        {
         preco_break=NormalizeDouble(preco-Entr_Fv_Buf[i]*ponto,_Digits);
         CriandoTagPreco(clrLightGray,"Entrada_Favor"+IntegerToString(i+1),preco_break);
         HLine_EntFav[i].Create(0,"Line_Favor"+IntegerToString(i+1),0,preco_break);
         HLine_EntFav[i].Color(clrLightGray);
        }
     }
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
