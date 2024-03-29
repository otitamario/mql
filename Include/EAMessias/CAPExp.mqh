//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <EAMessias\Params_Coyote.mqh>
#include<ChartObjects\ChartObjectsLines.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CAPRobot: public MyExpert
  {
private:
   CChartObjectHLine HLine_Price,HLine_SL,HLine_TP;
   string            currency_symbol;
   int               vwap_handle;
   double            VWap_Buffer[];
   int               cap_handle;
   double            CAP_Sell[],CAP_Buy[];
   CiMA             *media_incl;
   CiMA             *media_vol;
   CiVolumes        *volume;
   double            preco_medio;
   double            vol_pos,vol_stp,preco_stp;
   double            PointBreakEven[5];
   double            PointProfit[5];
   double            sl_position,tp_position;
   datetime          hora_inicial1,hora_final1,hora_inicial2,hora_final2,hora_inicial3,hora_final3;
   bool              timer1,timer2,timer3,timerPaus;
   bool              opt_tester;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   bool              time_new_ent;
   bool              buysignal,sellsignal;
   double            Buyprice,Sellprice;
   int               trend_handle;
   double            trend_sup,trend_res;

public:
   void              CAPRobot();
   void             ~CAPRobot();
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
   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);
   int               LastTouch();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAPRobot::CAPRobot()
  {

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAPRobot::~CAPRobot()
  {
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CAPRobot::OnInit(void)
  {
   time_new_ent=true;
   tradeOn=true;
   setExpName();
   setSymbol(Symbol());
   setOriginalSymbol(Symbol());
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

   hora_inicial1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour1);
   hora_final1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour1);

   hora_inicial2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour2);
   hora_final2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour2);

   hora_inicial3=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour3);
   hora_final3=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour3);

   ulong curChartID=ChartID();

   trend_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\autotrendlines.ex5",
                        InpLineType,InpLeftExmSide,InpRightExmSide,InpFromCurrent,InpPrevExmBar,InpLinesWidth,InpSupColor,InpResColor);

   ChartIndicatorAdd(curChartID,0,trend_handle);

   cap_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\CAPZACK v1.2.ex5",
                      center_period,0,average_period,average_mult,center_angle);

// ChartIndicatorAdd(curChartID,0,cap_handle);

   ArraySetAsSeries(CAP_Buy,true);
   ArraySetAsSeries(CAP_Sell,true);

   if(UsarMediaIncl)
     {
      media_incl=new CiMA;
      media_incl.Create(Symbol(),periodoRobo,period_media_inc,0,modo_media_inc,PRICE_CLOSE);
      //   media_incl.AddToChart(curChartID, 0);
     }

   volume=new CiVolumes;
   volume.Create(Symbol(),periodoRobo,InpVolType);
   ulong vol_chart=ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL);
//volume.AddToChart(curChartID,(int)vol_chart);

   media_vol=new CiMA;
   media_vol.Create(Symbol(),periodoRobo,per_med_vol,0,MODE_EMA,volume.Handle());
//media_vol.AddToChart(curChartID, (int)vol_chart);

   if(UsarVWap)
     {
      vwap_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\vwap_lite.ex5",Price_Type,Calc_Every_Tick,Enable_Daily,Show_Daily_Value,Enable_Weekly,Show_Weekly_Value,Enable_Monthly,Show_Monthly_Value);
      // ChartIndicatorAdd(curChartID,0,vwap_handle);
     }
   ArraySetAsSeries(VWap_Buffer,true);

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(ChartID(),CHART_SHOW_TRADE_LEVELS,false);
//ChartSetInteger(ChartID(),CHART_DRAG_TRADE_LEVELS,true);
//ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

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
   stop_entr_cont=stop_entr_cont||_Stop<=pts_entry4 || _Stop<=pts_entry5 || _Stop<=pts_entry6;
   stop_entr_cont=stop_entr_cont||_Stop<=pts_entry7 || _Stop<=pts_entry8 || _Stop<=pts_entry9|| _Stop<=pts_entry10;

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

   return(INIT_SUCCEEDED);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAPRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   if(UsarVWap)IndicatorRelease(vwap_handle);
   IndicatorRelease(cap_handle);
   if(UsarMediaIncl)delete(media_incl);
   delete(volume);
   delete(media_vol);
   DeletaIndicadores();
   int k=ObjectsDeleteAll(0,"",0,OBJ_HLINE);
   EventKillTimer();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CAPRobot::OnTimer()
  {
   time_new_ent=true;
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAPRobot::OnTick(void)
  {
   static int last_touch=0;
   static double bid_prev=0.0;
   static double ask_prev=0.0;

   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today",(double)TimeNow.day_of_year);

   bool novodia;
   novodia=Bar_NovoDia.CheckNewBar(original_symbol,PERIOD_D1);

   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      last_touch=0;
      gv.Set("glob_entr_tot",0.0);
      gv.Set("deals_total_prev",0.0);
      tradeOn=true;
      time_new_ent=true;
      hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
      hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

      hora_inicial1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour1);
      hora_final1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour1);

      hora_inicial2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour2);
      hora_final2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour2);

      hora_inicial3=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour3);
      hora_final3=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour3);
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
      timer1=UsePause1 && TimeCurrent()>=hora_inicial1 && TimeCurrent()<=hora_final1;
      timer2=UsePause2&&TimeCurrent()>=hora_inicial2 && TimeCurrent()<=hora_final2;
      timer3=UsePause3&&TimeCurrent()>=hora_inicial3 && TimeCurrent()<=hora_final3;
      timerPaus=!timer1 && !timer2 && !timer3;
      timerOn=timerPaus && TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
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

   if(!tradeOn)return;

   gv.Set("gv_today_prev",gv.Get("gv_today"));

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   if(UsarMediaIncl)media_incl.Refresh();
   volume.Refresh();
   media_vol.Refresh();
   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }

   if(bid>=ask)return;//Leilão
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))return;

   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

   trend_sup=ObjectGetDouble(0,"Current_Support",OBJPROP_PRICE);
   trend_res=ObjectGetDouble(0,"Current_Resistance",OBJPROP_PRICE);

   if((ask<=trend_sup && ask_prev>trend_sup)||(low[1]<=trend_sup&&close[0]>trend_sup))last_touch=1;
   if((bid>=trend_res && bid_prev<trend_res)||(high[1]>=trend_res&&close[0]<trend_res))last_touch=-1;
   Comment("Last Touch: ",IntegerToString(last_touch));

   bid_prev=bid;
   ask_prev=ask;

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
      if(PositionsTotal()>0) CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
      return;
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened()) CloseByPosition();

   if(!PosicaoAberta())
     {
      if(OrdersTotal()>0)DeleteALL();
      if(!opt_tester)
        {
         int k=ObjectsDeleteAll(0,"",0,OBJ_HLINE);
        }
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

      if(!opt_tester)
        {
         HLine_SL.Delete();
         myposition.Select(original_symbol);
         HLine_SL.Create(0,"Stop Loss",0,myposition.StopLoss());
         HLine_SL.Color(clrRed);
        }

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
         if(RevertPos)
           {
            buysignal=BuySignal() && !Buy_opened();
            sellsignal=SellSignal() && !Sell_opened();
           }
         else
           {
            buysignal=BuySignal() && !PosicaoAberta();
            sellsignal=SellSignal() && !PosicaoAberta();
           }

         if(UsarTrendLines)
           {
            buysignal=buysignal && last_touch==1;
            sellsignal=sellsignal && last_touch==-1;
           }

         if(buysignal && time_new_ent)
           {
            if(OrdersTotal()>0)DeleteALL();
            if(Sell_opened())ClosePosType(POSITION_TYPE_SELL);
            sl_position=NormalizeDouble(bid-_Stop*ponto,digits);
            tp_position=NormalizeDouble(ask+_TakeProfit*ponto,digits);
            if(mytrade.Buy(Lot,original_symbol,0,sl_position,tp_position,"BUY"+exp_name))
              {
               gv.Set(cp_tick,(double)mytrade.ResultOrder());
              }
            else Print("Erro enviar ordem ",GetLastError());
           }

         if(sellsignal && time_new_ent)
           {
            if(OrdersTotal()>0)DeleteALL();
            if(Buy_opened())ClosePosType(POSITION_TYPE_BUY);
            sl_position=NormalizeDouble(ask+_Stop*ponto,digits);
            tp_position=NormalizeDouble(bid-_TakeProfit*ponto,digits);
            if(mytrade.Sell(Lot,original_symbol,0,sl_position,tp_position,"SELL"+exp_name))
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
bool CAPRobot::GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(cap_handle,9,0,5,CAP_Buy)<=0 || 
         CopyBuffer(cap_handle,8,0,5,CAP_Sell)<=0 || 
         CopyHigh(Symbol(),period,0,3,high)<=0 ||
         CopyOpen(Symbol(),period,0,3,open)<=0 ||
         CopyLow(Symbol(),period,0,3,low)<=0 || 
         CopyClose(Symbol(),period,0,3,close)<=0;
   if(UsarVWap)
      b_get=b_get || CopyBuffer(vwap_handle,0,0,5,VWap_Buffer)<=0;

   return(b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAPRobot::TimeDayFilter()
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
bool CAPRobot::BuySignal()
  {
   bool signal=false;
   signal=CAP_Buy[2]==EMPTY_VALUE && CAP_Buy[1]!=EMPTY_VALUE;
   if(UsarMediaIncl)signal=signal && media_incl.Main(1)>media_incl.Main(2);
   if(UsarVol)
     {
      if(HowUseVol==AcimaMed)signal=signal && media_vol.Main(1)>volume.Main(1);
      else signal=signal && media_vol.Main(1)<volume.Main(1);
     }
   if(UsarVWap)
     {
      if(InvertVWAp)signal=signal && close[0]<VWap_Buffer[0];
      else signal=signal && close[0]>VWap_Buffer[0];
     }
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CAPRobot::SellSignal()
  {
   bool signal=false;
   signal=CAP_Sell[2]==EMPTY_VALUE && CAP_Sell[1]!=EMPTY_VALUE;
   if(UsarMediaIncl)signal=signal && media_incl.Main(1)<media_incl.Main(2);
   if(UsarVol)signal=signal && media_vol.Main(1)>volume.Main(1);
   if(UsarVWap)
     {
      if(InvertVWAp)signal=signal && close[0]>VWap_Buffer[0];
      else signal=signal && close[0]<VWap_Buffer[0];
     }
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


void CAPRobot::OnTradeTransaction(const MqlTradeTransaction &trans,
                                  const MqlTradeRequest &request,
                                  const MqlTradeResult &result)
  {

   if(trans.symbol!=original_symbol)
      return;
   int TENTATIVAS=10;

//--- get transaction type as enumeration value
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history

//--- if a request was sent
   if(trans.type==TRADE_TRANSACTION_REQUEST)
     {
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(type==TRADE_TRANSACTION_ORDER_UPDATE)
     {
     }

   if(type==TRADE_TRANSACTION_HISTORY_UPDATE)
     {
     }

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

            if(deal_comment=="BUY"+exp_name)
              {
               myposition.SelectByTicket(trans.order);
               int cont = 0;
               Buyprice = 0;
               while(Buyprice==0 && cont<TENTATIVAS)
                 {
                  Buyprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(Buyprice== 0)
                  Buyprice= mysymbol.Ask();

               sl_position = NormalizeDouble(Buyprice - _Stop * ponto, digits);
               tp_position = NormalizeDouble(Buyprice + _TakeProfit * ponto, digits);
               if(mytrade.SellLimit(Lot,tp_position,original_symbol,0,0,order_time_type,0,"TAKE PROFIT"))
                 {
                  gv.Set("tp_vd_tick",(double)mytrade.ResultOrder());
                  mytrade.PositionModify(trans.order,sl_position,0);
                 }
               else
                  Print("Erro enviar ordem: ",GetLastError());

               Entr_Parcial_Buy(Buyprice);
               Entr_Favor_Buy(Buyprice);
               Real_Parc_Buy(Lot,Buyprice);

               if(!opt_tester)
                 {
                  int k=ObjectsDeleteAll(0,0,OBJ_HLINE);
                  HLine_Price.Create(0, "Entrada", 0, Buyprice);
                  HLine_Price.Color(clrAqua);
                  HLine_SL.Create(0, "Stop Loss", 0, myposition.StopLoss());
                  HLine_SL.Color(clrRed);
                  HLine_TP.Create(0, "Take Profit", 0, myposition.TakeProfit());
                  HLine_TP.Color(clrLime);
                 }
              }
            //--------------------------------------------------

            if(deal_comment=="SELL"+exp_name)
              {
               myposition.SelectByTicket(trans.order);
               Sellprice= myposition.PriceOpen();
               int cont = 0;
               Sellprice= 0;
               while(Sellprice==0 && cont<TENTATIVAS)
                 {
                  Sellprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(Sellprice== 0)
                  Sellprice= mysymbol.Bid();
               sl_position = NormalizeDouble(Sellprice + _Stop * ponto, digits);
               tp_position = NormalizeDouble(Sellprice - _TakeProfit * ponto, digits);
               if(mytrade.BuyLimit(Lot,tp_position,original_symbol,0,0,order_time_type,0,"TAKE PROFIT"))
                 {
                  gv.Set("tp_cp_tick",(double)mytrade.ResultOrder());
                  mytrade.PositionModify(trans.order,sl_position,0);
                 }
               else
                  Print("Erro enviar ordem: ",GetLastError());

               Entr_Parcial_Sell(Sellprice);
               Entr_Favor_Sell(Sellprice);
               Real_Parc_Sell(Lot,Sellprice);
               if(!opt_tester)
                 {
                  int k=ObjectsDeleteAll(0,0,OBJ_HLINE);
                  HLine_Price.Create(0, "Entrada", 0, Sellprice);
                  HLine_Price.Color(clrAqua);
                  HLine_SL.Create(0, "Stop Loss", 0, myposition.StopLoss());
                  HLine_SL.Color(clrRed);
                  HLine_TP.Create(0, "Take Profit", 0, myposition.TakeProfit());
                  HLine_TP.Color(clrLime);
                 }
              }

            if((deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL) && (deal_entry==DEAL_ENTRY_OUT || deal_entry==DEAL_ENTRY_OUT_BY))
              {

               if(deal_profit<0)
                 {
                  Print("Saída por STOP LOSS");
                 }

               if(deal_profit>0)
                 {
                  Print("Saída no GAIN");
                 }
               if(n_minutes>0)
                 {
                  time_new_ent=false;
                  EventSetTimer(n_minutes*60);
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(type==TRADE_TRANSACTION_HISTORY_ADD)
     {
      if(HistoryOrderSelect(trans.order))
        {
         myhistory.Ticket(trans.order);
         if(myhistory.Magic()!=(ulong)Magic_Number)
            return;

         if((myhistory.Comment()=="BUY"+exp_name || myhistory.Comment()=="SELL"+exp_name) && trans.order_state==ORDER_STATE_FILLED)
           {
            gv.Set("glob_entr_tot",gv.Get("glob_entr_tot")+1);
           }

         if(myhistory.Comment()=="TAKE PROFIT")
           {
            if(n_minutes>0)
              {
               time_new_ent=false;
               EventSetTimer(n_minutes*60);
              }
           }

         if(StringFind(myhistory.Comment(),"Entrada Parcial")>=0)
           {
            if(Buy_opened())
              {
               sl_position=gv.Get("sl_position");
               myposition.SelectByTicket((ulong)gv.Get("cp_tick"));
               if(myposition.StopLoss()==0)
                  mytrade.PositionModify(myposition.Ticket(),sl_position,0);

               if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
                 {
                  for(int i=PositionsTotal()-1; i>=0; i--)
                    {
                     if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_BUY && myposition.Symbol()==mysymbol.Name())
                       {
                        if(myposition.StopLoss()==0)
                           mytrade.PositionModify(myposition.Ticket(),sl_position,0);
                       }
                    }
                 }
               if(pts_saida_aumento>0)
                  mytrade.SellLimit(myhistory.VolumeCurrent(),NormalizeDouble(myhistory.PriceOpen()+pts_saida_aumento*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Aumento");
              }

            if(Sell_opened())
              {
               sl_position=gv.Get("sl_position");
               myposition.SelectByTicket((ulong)gv.Get("vd_tick"));
               if(myposition.StopLoss()==0)
                  mytrade.PositionModify(myposition.Ticket(),sl_position,0);

               if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
                 {
                  for(int i=PositionsTotal()-1; i>=0; i--)
                    {
                     if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_SELL && myposition.Symbol()==mysymbol.Name())
                       {
                        if(myposition.StopLoss()==0)
                           mytrade.PositionModify(myposition.Ticket(),sl_position,0);
                       }
                    }
                 }

               if(pts_saida_aumento>0)
                  mytrade.BuyLimit(myhistory.VolumeCurrent(),NormalizeDouble(myhistory.PriceOpen()-pts_saida_aumento*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Aumento");
              }
           }

         if(StringFind(myhistory.Comment(),"Entrada Favor")>=0)
           {
            if(Buy_opened())
              {
               sl_position=gv.Get("sl_position");
               myposition.SelectByTicket((ulong)gv.Get("cp_tick"));
               if(myposition.StopLoss()==0)
                  mytrade.PositionModify(myposition.Ticket(),sl_position,0);
               if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
                 {
                  for(int i=PositionsTotal()-1; i>=0; i--)
                    {
                     if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_BUY && myposition.Symbol()==mysymbol.Name())
                       {
                        if(myposition.StopLoss()==0)
                           mytrade.PositionModify(myposition.Ticket(),sl_position,0);
                       }
                    }
                 }
               if(pts_saida_aumento_fv>0)
                  mytrade.SellLimit(myhistory.VolumeCurrent(),NormalizeDouble(myhistory.PriceOpen()+pts_saida_aumento_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Favor");
              }

            if(Sell_opened())
              {
               sl_position=gv.Get("sl_position");
               myposition.SelectByTicket((ulong)gv.Get("vd_tick"));
               if(myposition.StopLoss()==0)
                  mytrade.PositionModify(myposition.Ticket(),sl_position,0);

               if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
                 {
                  for(int i=PositionsTotal()-1; i>=0; i--)
                    {
                     if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_SELL && myposition.Symbol()==mysymbol.Name())
                       {
                        if(myposition.StopLoss()==0)
                           mytrade.PositionModify(myposition.Ticket(),sl_position,0);
                       }
                    }
                 }
               if(pts_saida_aumento_fv>0)
                  mytrade.BuyLimit(myhistory.VolumeCurrent(),NormalizeDouble(myhistory.PriceOpen()-pts_saida_aumento_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Favor");
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAPRobot::Entr_Parcial_Buy(const double preco)
  {
   if(Lot_entry1>0) mytrade.BuyLimit(Lot_entry1,NormalizeDouble(preco-pts_entry1*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 1");
   if(Lot_entry2>0) mytrade.BuyLimit(Lot_entry2,NormalizeDouble(preco-pts_entry2*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 2");
   if(Lot_entry3>0) mytrade.BuyLimit(Lot_entry3,NormalizeDouble(preco-pts_entry3*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 3");
   if(Lot_entry4>0) mytrade.BuyLimit(Lot_entry4,NormalizeDouble(preco-pts_entry4*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 4");
   if(Lot_entry5>0) mytrade.BuyLimit(Lot_entry5,NormalizeDouble(preco-pts_entry5*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 5");
   if(Lot_entry6>0) mytrade.BuyLimit(Lot_entry6,NormalizeDouble(preco-pts_entry6*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 6");
   if(Lot_entry7>0) mytrade.BuyLimit(Lot_entry7,NormalizeDouble(preco-pts_entry7*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 7");
   if(Lot_entry8>0) mytrade.BuyLimit(Lot_entry8,NormalizeDouble(preco-pts_entry8*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 8");
   if(Lot_entry9>0) mytrade.BuyLimit(Lot_entry9,NormalizeDouble(preco-pts_entry9*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 9");
   if(Lot_entry10>0) mytrade.BuyLimit(Lot_entry10,NormalizeDouble(preco-pts_entry10*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 10");
  }
//+------------------------------------------------------------------+
void CAPRobot::Entr_Parcial_Sell(const double preco)
  {
   if(Lot_entry1>0) mytrade.SellLimit(Lot_entry1,NormalizeDouble(preco+pts_entry1*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 1");
   if(Lot_entry2>0) mytrade.SellLimit(Lot_entry2,NormalizeDouble(preco+pts_entry2*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 2");
   if(Lot_entry3>0) mytrade.SellLimit(Lot_entry3,NormalizeDouble(preco+pts_entry3*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 3");
   if(Lot_entry4>0) mytrade.SellLimit(Lot_entry4,NormalizeDouble(preco+pts_entry4*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 4");
   if(Lot_entry5>0) mytrade.SellLimit(Lot_entry5,NormalizeDouble(preco+pts_entry5*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 5");
   if(Lot_entry6>0) mytrade.SellLimit(Lot_entry6,NormalizeDouble(preco+pts_entry6*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 6");
   if(Lot_entry7>0) mytrade.SellLimit(Lot_entry7,NormalizeDouble(preco+pts_entry7*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 7");
   if(Lot_entry8>0) mytrade.SellLimit(Lot_entry8,NormalizeDouble(preco+pts_entry8*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 8");
   if(Lot_entry9>0) mytrade.SellLimit(Lot_entry9,NormalizeDouble(preco+pts_entry9*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 9");
   if(Lot_entry10>0) mytrade.SellLimit(Lot_entry10,NormalizeDouble(preco+pts_entry10*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 10");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAPRobot::Entr_Favor_Buy(const double preco)
  {

   if(Lot_entry1_fv>0) mytrade.BuyStop(Lot_entry1_fv,NormalizeDouble(preco+pts_entry1_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 1");
   if(Lot_entry2_fv>0) mytrade.BuyStop(Lot_entry2_fv,NormalizeDouble(preco+pts_entry2_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 2");
   if(Lot_entry3_fv>0) mytrade.BuyStop(Lot_entry3_fv,NormalizeDouble(preco+pts_entry3_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 3");
   if(Lot_entry4_fv>0) mytrade.BuyStop(Lot_entry4_fv,NormalizeDouble(preco+pts_entry4_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 4");
  }
//+------------------------------------------------------------------+
void CAPRobot::Entr_Favor_Sell(const double preco)
  {
   if(Lot_entry1_fv>0) mytrade.SellStop(Lot_entry1_fv,NormalizeDouble(preco-pts_entry1_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 1");
   if(Lot_entry2_fv>0) mytrade.SellStop(Lot_entry2_fv,NormalizeDouble(preco-pts_entry2_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 2");
   if(Lot_entry3_fv>0) mytrade.SellStop(Lot_entry3_fv,NormalizeDouble(preco-pts_entry3_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 3");
   if(Lot_entry4_fv>0) mytrade.SellStop(Lot_entry4_fv,NormalizeDouble(preco-pts_entry4_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 4");
  }
//+------------------------------------------------------------------+

void CAPRobot::Atual_vol_Stop_Take()
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
         // preco_stp=myorder.PriceOpen();
         preco_stp=mysymbol.NormalizePrice(PrecoMedio(POSITION_TYPE_BUY)+_TakeProfit*ponto);

         if(vol_pos!=vol_stp)
           {
            mytrade.OrderDelete((ulong)gv.Get("tp_vd_tick"));
            mytrade.SellLimit(vol_pos, preco_stp, original_symbol, 0, 0, 0, 0, "TAKE PROFIT");
            gv.Set("tp_vd_tick",(double)mytrade.ResultOrder());
           }
        }
     }
   if(Sell_opened())
     {

      if(myposition.SelectByTicket((ulong)gv.Get("vd_tick")) && myorder.Select((ulong)gv.Get("tp_cp_tick")))
        {
         vol_pos = VolPosType(POSITION_TYPE_SELL)-vol_ent_contra-vol_ent_fav-vol_parc;
         vol_stp = myorder.VolumeInitial();
         //  preco_stp=myorder.PriceOpen();
         preco_stp=mysymbol.NormalizePrice(PrecoMedio(POSITION_TYPE_SELL)-_TakeProfit*ponto);

         if(vol_pos!=vol_stp)
           {
            mytrade.OrderDelete((ulong)gv.Get("tp_cp_tick"));
            mytrade.BuyLimit(vol_pos, preco_stp, original_symbol, 0, 0, 0, 0, "TAKE PROFIT");
            gv.Set("tp_cp_tick",(double)mytrade.ResultOrder());
           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CAPRobot::Real_Parc_Buy(double vol,double preco)
  {
   double lts_rp1=0;
   double lts_rp2=0;
   double lts_rp3=0;
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
void CAPRobot::Real_Parc_Sell(double vol,double preco)
  {
   double lts_rp1=0;
   double lts_rp2=0;
   double lts_rp3=0;
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
