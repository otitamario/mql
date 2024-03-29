//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#define VALIDADE   D'2100.12.31 23:59:59'//Data de Validade ano.mes.dia horas:minutos:segundos(opcional)
#define VERSION "1.0"// Mudar aqui as Versões

#property copyright "Autor da Estratégia: Messias da Silva <trendbot@bol.com.br>"
#property version   VERSION
#property description   "AVISO DE ALTO RISCO: a negociação tem um alto nível de risco que pode não"
#property description   "ser adequado para todos os investidores. A alavancagem cria risco adicional"
#property description   "e exposição à perda. Antes de tomar qualquer decisão, considere cuidadosamente"
#property description   "seus objetivos de investimento, nível de experiência e tolerância ao risco."
#property description   "Você pode perder algum ou todo seu investimento inicial."
#property description   "Não invista dinheiro que não pode perder."


#include<ChartObjects\ChartObjectsLines.mqh>
#include <Controls\Defines.mqh>
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
//#undef CONTROLS_LABEL_COLOR  

color borda_bg=clrLightCyan;//Cor Borda
color painel_bg=clrBlack;//Cor Painel 
color cor_txt_borda_bg=clrBlue;//Cor Texto Borda
                               //color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG          borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg

#include <EAMessias\Params.mqh>
#include <EAMessias\AfastMedia.mqh>

CAccountInfo      myaccount;
AfastMedia MyAfastMed;
MyPanel ExtDialog;

CLabel            m_label[50];
CButton BotaoFechar;
#define LARGURA_PAINEL 290 // Largura Painel
#define ALTURA_PAINEL 200 // Altura Painel
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyRobot: public MyExpert
  {
private:
   CiMA             *media_vol;
   CiVolumes        *volume;
   CChartObjectHLine HLine_Price,HLine_SL,HLine_TP;
   string            currency_symbol;
   int               brain_handle,brain_stop_handle;
   int               trend_handle;
   double            BrainDown[],BrainUp[];
   double            SellStopBuffer[],BuyStopBuffer[];
   double            Trend_Buffer[];
   int               pivot_handle;
   double            R1Buffer[],R2Buffer[],R3Buffer[],R4Buffer[];
   double            S1Buffer[],S2Buffer[],S3Buffer[],S4Buffer[];
   double            PBuffer[];
   double            preco_medio;
   double            vol_pos,vol_stp,preco_stp;
   double            PointBreakEven[5];
   double            PointProfit[5];
   CiRSI            *rsi;
   CiEnvelopes      *envelope;
   CiMA             *media_filt;
   CiMA             *mhigh;
   CiMA             *mlow;
   double            sl_position,tp_position;
   datetime          hora_inicial1,hora_final1,hora_inicial2,hora_final2,hora_inicial3,hora_final3;
   bool              timer1,timer2,timer3,timerPaus;
   bool              opt_tester;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   bool              time_new_ent;
   int               bb_handle;
   double            BBWD_Buffer[];

public:
   void              MyRobot();
   void             ~MyRobot();
   int               OnInit();
   void              OnDeinit(const int reason);
   void              OnTick();
   void              OnTimer();
   string GetCurrency(){return SymbolInfoString(original_symbol,SYMBOL_CURRENCY_BASE);}
   bool              TimeDayFilter();
   virtual bool      GetIndValue();
   virtual bool      BuySignal();
   virtual bool      SellSignal();
   virtual void      MytradeTransaction();
   void              Entr_Parcial_Buy(const double preco);
   void              Entr_Parcial_Sell(const double preco);
   void              Entr_Favor_Buy(const double preco);
   void              Entr_Favor_Sell(const double preco);
   virtual void      Atual_vol_Stop_Take();
   void              Real_Parc_Sell(double vol,double preco);
   void              Real_Parc_Buy(double vol,double preco);
   void              SegurancaPos(int nsec);

  };

MyRobot MyEA;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::MyRobot()
  {

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::~MyRobot()
  {
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::OnInit(void)
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

   if(Estrategia==Brain)
     {
      brain_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\braintrend2sig.ex5",ATR_Period);
      ChartIndicatorAdd(curChartID,0,brain_handle);
      ArraySetAsSeries(BrainDown,true);
      ArraySetAsSeries(BrainUp,true);

      brain_stop_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\BrainTrend2Stop.ex5",ATR_Period);
      ChartIndicatorAdd(curChartID,0,brain_stop_handle);
      ArraySetAsSeries(SellStopBuffer,true);
      ArraySetAsSeries(BuyStopBuffer,true);
     }
   if(Estrategia==IndexZone)
     {
      rsi=new CiRSI;
      rsi.Create(Symbol(),periodoRobo,period_indexz,PRICE_CLOSE);
      rsi.AddToChart(curChartID,(int)ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL));
     }

   if(UsarFiltMed)
     {
      media_filt=new CiMA;
      media_filt.Create(Symbol(),periodoRobo,period_filt_med,0,MODE_EMA,PRICE_CLOSE);
      media_filt.AddToChart(curChartID,0);
     }

   if(Estrategia==Envel)
     {
      envelope=new CiEnvelopes;
      envelope.Create(Symbol(),periodoRobo,InpMAPeriod,InpMAShift,InpMAMethod,InpAppliedPrice,InpDeviation);
      envelope.AddToChart(curChartID,0);
     }
   if(Estrategia==Pivo)
     {
      pivot_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\pivotpointuniversal.ex5",InpPivotType,InpPeriod,InpTime);
      ChartIndicatorAdd(curChartID,0,pivot_handle);
      ArraySetAsSeries(R1Buffer,true);
      ArraySetAsSeries(R2Buffer,true);
      ArraySetAsSeries(R3Buffer,true);
      ArraySetAsSeries(R4Buffer,true);
      ArraySetAsSeries(S1Buffer,true);
      ArraySetAsSeries(S2Buffer,true);
      ArraySetAsSeries(S3Buffer,true);
      ArraySetAsSeries(S4Buffer,true);
      ArraySetAsSeries(PBuffer,true);
     }

   if(Estrategia==TrendMag)
     {
      trend_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\trendmagic.ex5",CCI_Period_Trend,ATR_Period_Trend);
      ChartIndicatorAdd(curChartID,0,trend_handle);
      ArraySetAsSeries(Trend_Buffer,true);
     }

   if(Estrategia==MaxMin)
     {

      if(InpNivel1>=InpNivel2)
        {
         string erro="Nivel 1 do BBANDWIDTH deve ser menor que o Nível 2";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);
        }

      if(InpNivel1<=0 || InpNivel2<=0)
        {
         string erro="Nivel 1 e Nivel 2 do BBANDWIDTH devem ser >0";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);
        }

      trend_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\trendmagic.ex5",CCI_Period_Trend,ATR_Period_Trend);
      ChartIndicatorAdd(curChartID,0,trend_handle);
      ArraySetAsSeries(Trend_Buffer,true);
      bb_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\bbandwidth_interv.ex5",InpBandsPeriod,InpBandsShift,InpBandsDeviations,InpNivel1,InpNivel2);
      ChartIndicatorAdd(curChartID,(int)ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),bb_handle);
      ArraySetAsSeries(BBWD_Buffer,true);

      mhigh=new CiMA;
      mhigh.Create(Symbol(),periodoRobo,per_med_max,0,InpMAMethodHigh,PRICE_HIGH);
      mhigh.AddToChart(curChartID,0);
      mlow=new CiMA;
      mlow.Create(Symbol(),periodoRobo,per_med_min,0,InpMAMethodLow,PRICE_LOW);
      mlow.AddToChart(curChartID,0);

     }

   volume=new CiVolumes;
   volume.Create(Symbol(),periodoRobo,InpVolType);
   ulong vol_chart=ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL);
   volume.AddToChart(curChartID,(int)vol_chart);

   media_vol=new CiMA;
   media_vol.Create(Symbol(), periodoRobo, per_med_vol, 0,MODE_EMA,volume.Handle());
   media_vol.AddToChart(curChartID, (int)vol_chart);

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
void MyRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   delete(volume);
   delete(media_vol);
   if(UsarFiltMed)delete(media_filt);
   if(Estrategia==Pivo)IndicatorRelease(pivot_handle);
   if(Estrategia==TrendMag)IndicatorRelease(trend_handle);
   if(Estrategia==Brain)
     {
      IndicatorRelease(brain_handle);
      IndicatorRelease(brain_stop_handle);
     }
   if(Estrategia==IndexZone)delete(rsi);
   if(Estrategia==Envel)delete(envelope);
   if(Estrategia==TrendMag)
     {
      IndicatorRelease(trend_handle);
      IndicatorRelease(bb_handle);
      delete(mhigh);
      delete(mlow);
     }

   DeletaIndicadores();
   int k=ObjectsDeleteAll(0,"",0,OBJ_HLINE);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MyRobot::OnTimer()
  {
   time_new_ent=true;
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTick(void)
  {

   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today",(double)TimeNow.day_of_year);

   bool novodia;
   novodia=Bar_NovoDia.CheckNewBar(original_symbol,PERIOD_D1);

   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
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

   MytradeTransaction();

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   if(Estrategia==IndexZone)rsi.Refresh();
   if(Estrategia==Envel)envelope.Refresh();
   if(UsarFiltMed)media_filt.Refresh();
   if(Estrategia==MaxMin)
     {
      mhigh.Refresh();
      mlow.Refresh();
     }
   volume.Refresh();
   media_vol.Refresh();
   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }
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

      SegurancaPos(n_seconds);

      if(Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo))
        {
         if(GetIndValue())
           {
            Print("Error in obtain indicators buffers or price rates");
            return;
           }

         if(Estrategia!=MaxMin || (Estrategia==MaxMin && (!cada_tick_maxmin)))
           {
            if(BuySignal() && !Buy_opened() && time_new_ent)
              {
               if(OrdersTotal()>0)DeleteALL();
               if(Sell_opened())ClosePosType(POSITION_TYPE_SELL);
               if(mytrade.Buy(Lot,original_symbol,0,NormalizeDouble(bid-_Stop*ponto,digits),NormalizeDouble(ask+_TakeProfit*ponto,digits),"BUY"+exp_name))
                 {
                  gv.Set(cp_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Erro enviar ordem ",GetLastError());
              }

            if(SellSignal() && !Sell_opened() && time_new_ent)
              {
               if(OrdersTotal()>0)DeleteALL();
               if(Buy_opened())ClosePosType(POSITION_TYPE_BUY);
               if(mytrade.Sell(Lot,original_symbol,0,NormalizeDouble(ask+_Stop*ponto,digits),NormalizeDouble(bid-_TakeProfit*ponto,digits),"SELL"+exp_name))
                 {
                  gv.Set(vd_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Erro enviar ordem ",GetLastError());

              }
           }
        }//End NewBar

      if(Estrategia==MaxMin && cada_tick_maxmin)
        {
         if(GetIndValue())
           {
            Print("Error in obtain indicators buffers or price rates");
            return;
           }
         if(BuySignal() && !Buy_opened() && time_new_ent)
           {
            if(OrdersTotal()>0)DeleteALL();
            if(Sell_opened())ClosePosType(POSITION_TYPE_SELL);
            if(mytrade.Buy(Lot,original_symbol,0,NormalizeDouble(bid-_Stop*ponto,digits),NormalizeDouble(ask+_TakeProfit*ponto,digits),"BUY"+exp_name))
              {
               gv.Set(cp_tick,(double)mytrade.ResultOrder());
              }
            else Print("Erro enviar ordem ",GetLastError());
           }

         if(SellSignal() && !Sell_opened() && time_new_ent)
           {
            if(OrdersTotal()>0)DeleteALL();
            if(Buy_opened())ClosePosType(POSITION_TYPE_BUY);
            if(mytrade.Sell(Lot,original_symbol,0,NormalizeDouble(ask+_Stop*ponto,digits),NormalizeDouble(bid-_TakeProfit*ponto,digits),"SELL"+exp_name))
              {
               gv.Set(vd_tick,(double)mytrade.ResultOrder());
              }
            else Print("Erro enviar ordem ",GetLastError());

           }
        }

     }//End Trade On

  }//Fim Ontick
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool MyRobot::GetIndValue()
  {
   bool b_get;
   b_get=CopyHigh(Symbol(),period,0,3,high)<=0 || 
         CopyOpen(Symbol(),period,0,3,open)<=0 || 
         CopyLow(Symbol(),period,0,3,low)<=0 || 
         CopyClose(Symbol(),period,0,3,close)<=0;

   if(Estrategia==Pivo)
     {
      b_get=b_get || CopyBuffer(pivot_handle,8,0,3,R4Buffer)<=0 || 
            CopyBuffer(pivot_handle,6,0,3,R3Buffer)<=0 ||
            CopyBuffer(pivot_handle,4,0,3,R2Buffer)<=0 ||
            CopyBuffer(pivot_handle,2,0,3,R1Buffer)<=0 ||
            CopyBuffer(pivot_handle,0,0,3,PBuffer)<=0 || 
            CopyBuffer(pivot_handle,1,0,3,S1Buffer)<=0 ||
            CopyBuffer(pivot_handle,3,0,3,S2Buffer)<=0 ||
            CopyBuffer(pivot_handle,5,0,3,S3Buffer)<=0||
            CopyBuffer(pivot_handle,7,0,3,S4Buffer)<=0;
     }
   if(Estrategia==Brain)
     {
      b_get=b_get || CopyBuffer(brain_handle,0,0,3,BrainDown)<=0 || 
            CopyBuffer(brain_handle,1,0,3,BrainUp)<=0 || 
            CopyBuffer(brain_stop_handle,0,0,3,SellStopBuffer)<=0 || 
            CopyBuffer(brain_stop_handle,1,0,3,BuyStopBuffer)<=0;
     }

   if(Estrategia==TrendMag)
     {
      b_get=b_get || CopyBuffer(trend_handle,1,0,3,Trend_Buffer)<=0;
     }

   if(Estrategia==MaxMin)
     {
      b_get=b_get || CopyBuffer(trend_handle,1,0,3,Trend_Buffer)<=0 || CopyBuffer(bb_handle,0,0,5,BBWD_Buffer)<=0;
     }

   return(b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::TimeDayFilter()
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
bool MyRobot::BuySignal()
  {
   bool signal=false;
   bool pivot;

   if(Estrategia==Pivo)
     {
      pivot=(close[2]<PBuffer[2] && close[1]>PBuffer[1]+dx_pivot*ponto) || 
            (close[2]<R1Buffer[2] && close[1]>R1Buffer[1]+dx_pivot*ponto) || 
            (close[2]<R2Buffer[2] && close[1]>R2Buffer[1]+dx_pivot*ponto) || 
            (close[2]<R3Buffer[2] && close[1]>R3Buffer[1]+dx_pivot*ponto) || 
            (close[2]<R4Buffer[2] && close[1]>R4Buffer[1]+dx_pivot*ponto);
      signal=pivot;
     }
   if(Estrategia==Brain)signal=BuyStopBuffer[1]>0;
   if(Estrategia==IndexZone)signal=rsi.Main(2)<sobrecomprado&&rsi.Main(1)>sobrecomprado;
   if(Estrategia==Envel)signal=close[1]<envelope.Lower(1);
   if(Estrategia==TrendMag)signal=Trend_Buffer[1]==0.0&&Trend_Buffer[2]!=0.0;
   if(Estrategia==MaxMin)
     {
      int idx=0;
      if(!cada_tick_maxmin)idx=1;
      if(AtivarTrend)
        {
         if(FiltroTrendMag!=ContTend_Trend) signal=Trend_Buffer[idx]==0.0 && close[idx+1]<mlow.Main(idx+1) && close[idx]>mlow.Main(idx) && BBWD_Buffer[idx]>InpNivel2;
         else signal=Trend_Buffer[idx]==1.0 && close[idx+1]<mlow.Main(idx+1) && close[idx]>mlow.Main(idx) && BBWD_Buffer[idx]>InpNivel2;
        }
      if(UsarVol)signal=signal && media_vol.Main(idx)>volume.Main(idx);
     }

   if(UsarFiltMed)signal=signal && close[1]>media_filt.Main(1);

   if(UsarVol && Estrategia!=MaxMin)signal=signal && media_vol.Main(1)>volume.Main(1);

   return signal;
  }//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal=false;
   bool pivot;
   if(Estrategia==Pivo)
     {
      pivot=(close[2]>PBuffer[2] && close[1]<PBuffer[1]-dx_pivot*ponto) || 
            (close[2]>S1Buffer[2] && close[1]<S1Buffer[1]-dx_pivot*ponto) || 
            (close[2]>S2Buffer[2] && close[1]<S2Buffer[1]-dx_pivot*ponto) || 
            (close[2]>S3Buffer[2] && close[1]<S3Buffer[1]-dx_pivot*ponto) || 
            (close[2]>S4Buffer[2] && close[1]<S4Buffer[1]-dx_pivot*ponto);
      signal=pivot;
     }
   if(Estrategia==Brain)signal=SellStopBuffer[1]>0;;
   if(Estrategia==IndexZone)signal=rsi.Main(2)>sobrevendido&&rsi.Main(1)<sobrevendido;
   if(Estrategia==Envel)signal=close[1]>envelope.Upper(1);
   if(Estrategia==TrendMag)signal=Trend_Buffer[1]==1.0&&Trend_Buffer[2]!=1.0;
   if(Estrategia==MaxMin)
     {
      int idx=0;
      if(!cada_tick_maxmin)idx=1;
      if(AtivarTrend)
        {
         if(FiltroTrendMag!=ContTend_Trend)signal=Trend_Buffer[idx]==1.0 && close[idx+1]>mhigh.Main(idx+1) && close[idx]<mhigh.Main(idx) && BBWD_Buffer[idx]>InpNivel2;
         else signal=Trend_Buffer[idx]==0.0 && close[idx+1]>mhigh.Main(idx+1) && close[idx]<mhigh.Main(idx) && BBWD_Buffer[idx]>InpNivel2;
        }
      if(UsarVol)signal=signal && media_vol.Main(idx)>volume.Main(idx);
     }

   if(UsarFiltMed)signal=signal && close[1]<media_filt.Main(1);
   if(UsarVol && Estrategia!=MaxMin)signal=signal && media_vol.Main(1)>volume.Main(1);

   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::SegurancaPos(int nsec)
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
void MyRobot::MytradeTransaction()
  {
   ulong order_ticket;
   ulong deals_ticket;
   uint total_deals,cont_deals;
   ulong ticket_history_deal,deal_magic;
   double buyprice,sellprice;
   int TENTATIVAS=10;

   if(HistorySelect(iTime(original_symbol,PERIOD_D1,0),TimeCurrent()))
     {
      total_deals=HistoryDealsTotal();
      ticket_history_deal=0;
      deals_ticket=0;
      cont_deals=0;
      for(uint i=0;i<total_deals;i++)
        {
         ticket_history_deal=HistoryDealGetTicket(i);

         //--- try to get deals ticket_history_deal
         if(ticket_history_deal>0)
           {
            deal_magic=HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
            if(deal_magic==Magic_Number && HistoryDealGetString(ticket_history_deal,DEAL_SYMBOL)==mysymbol.Name())
              {
               cont_deals+=1;
               deals_ticket=ticket_history_deal;
               gv.Set("last_deal_time",(double)HistoryDealGetInteger(deals_ticket,DEAL_TIME));
              }
           }
        }

      gv.Set("deals_total",(double)cont_deals);

      if(gv.Get("deals_total")>gv.Get("deals_total_prev"))
        {

         if(deals_ticket>0)
           {
            mydeal.Ticket(deals_ticket);
            order_ticket=mydeal.Order();

            if(mydeal.Comment()=="BUY"+exp_name || mydeal.Comment()=="SELL"+exp_name)
              {
               gv.Set("glob_entr_tot",gv.Get("glob_entr_tot")+1);
              }

            if(mydeal.Comment()=="BUY"+exp_name)

              {
               myposition.SelectByTicket(order_ticket);
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
               mytrade.PositionModify(order_ticket,sl_position,0);
               if(mytrade.SellLimit(Lot,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT"))
                 {
                  gv.Set("tp_vd_tick",(double)mytrade.ResultOrder());
                 }
               else
                  Print("Erro enviar ordem: ",GetLastError());

               Entr_Parcial_Buy(buyprice);
               Entr_Favor_Buy(buyprice);
               Real_Parc_Buy(Lot,buyprice);

               if(!opt_tester)
                 {
                  int k=ObjectsDeleteAll(0,0,OBJ_HLINE);
                  HLine_Price.Create(0,"Entrada",0,buyprice);
                  HLine_Price.Color(clrAqua);
                  HLine_SL.Create(0,"Stop Loss",0,myposition.StopLoss());
                  HLine_SL.Color(clrRed);
                  HLine_TP.Create(0,"Take Profit",0,myposition.TakeProfit());
                  HLine_TP.Color(clrLime);
                 }
              }
            //--------------------------------------------------

            if(mydeal.Comment()=="SELL"+exp_name)
              {
               myposition.SelectByTicket(order_ticket);
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
               mytrade.PositionModify(order_ticket,sl_position,0);
               if(mytrade.BuyLimit(Lot,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT"))
                 {
                  gv.Set("tp_cp_tick",(double)mytrade.ResultOrder());
                 }
               else
                  Print("Erro enviar ordem: ",GetLastError());

               Entr_Parcial_Sell(sellprice);
               Entr_Favor_Sell(sellprice);
               Real_Parc_Sell(Lot,sellprice);
               if(!opt_tester)
                 {
                  int k=ObjectsDeleteAll(0,0,OBJ_HLINE);
                  HLine_Price.Create(0,"Entrada",0,sellprice);
                  HLine_Price.Color(clrAqua);
                  HLine_SL.Create(0,"Stop Loss",0,myposition.StopLoss());
                  HLine_SL.Color(clrRed);
                  HLine_TP.Create(0,"Take Profit",0,myposition.TakeProfit());
                  HLine_TP.Color(clrLime);
                 }
              }

            if((mydeal.DealType()==DEAL_TYPE_BUY || mydeal.DealType()==DEAL_TYPE_SELL) && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))

              {
               if(mydeal.Profit()<0)
                 {
                  Print("Saída por STOP LOSS");
                 }

               if(mydeal.Profit()>0)
                 {
                  Print("Saída no GAIN");
                 }
               time_new_ent=false;
               EventSetTimer(n_minutes*60);

              }
            if(mydeal.Comment()=="TAKE PROFIT")
              {
               time_new_ent=false;
               EventSetTimer(n_minutes*60);
              }

            if(StringFind(mydeal.Comment(),"Entrada Parcial")>=0)
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

            if(StringFind(mydeal.Comment(),"Entrada Favor")>=0)
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
            lucro_orders=LucroOrdens();
            if(!opt_tester)
              {
               lucro_orders_mes=LucroOrdensMes();
               lucro_orders_sem=LucroOrdensSemana();
              }

           }// if dealsticket>0
        }//Fim deals>prev
     }//Fim HistorySelect
   gv.Set("deals_total_prev",gv.Get("deals_total"));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::Entr_Parcial_Buy(const double preco)
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
void MyRobot::Entr_Parcial_Sell(const double preco)
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
void MyRobot::Entr_Favor_Buy(const double preco)
  {

   if(Lot_entry1_fv>0) mytrade.BuyStop(Lot_entry1_fv,NormalizeDouble(preco+pts_entry1_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 1");
   if(Lot_entry2_fv>0) mytrade.BuyStop(Lot_entry2_fv,NormalizeDouble(preco+pts_entry2_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 2");
   if(Lot_entry3_fv>0) mytrade.BuyStop(Lot_entry3_fv,NormalizeDouble(preco+pts_entry3_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 3");
   if(Lot_entry4_fv>0) mytrade.BuyStop(Lot_entry4_fv,NormalizeDouble(preco+pts_entry4_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 4");
  }
//+------------------------------------------------------------------+
void MyRobot::Entr_Favor_Sell(const double preco)
  {
   if(Lot_entry1_fv>0) mytrade.SellStop(Lot_entry1_fv,NormalizeDouble(preco-pts_entry1_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 1");
   if(Lot_entry2_fv>0) mytrade.SellStop(Lot_entry2_fv,NormalizeDouble(preco-pts_entry2_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 2");
   if(Lot_entry3_fv>0) mytrade.SellStop(Lot_entry3_fv,NormalizeDouble(preco-pts_entry3_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 3");
   if(Lot_entry4_fv>0) mytrade.SellStop(Lot_entry4_fv,NormalizeDouble(preco-pts_entry4_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 4");
  }
//+------------------------------------------------------------------+

void MyRobot::Atual_vol_Stop_Take()
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
         preco_stp=myorder.PriceOpen();

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
         preco_stp=myorder.PriceOpen();

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
void MyRobot::Real_Parc_Buy(double vol,double preco)
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
void MyRobot::Real_Parc_Sell(double vol,double preco)
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
void OnTimer()
  {
   if(Estrategia==Afast)MyAfastMed.OnTimer();
   else MyEA.OnTimer();

  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   datetime expiracao=VALIDADE;
   string msg_validade="Validade até "+TimeToString(expiracao); MessageBox(msg_validade);
   Print(msg_validade);
   bool licenca=TimeCurrent()>expiracao;
   if(licenca)
     {
      string erro="Licença Inválida";
      MessageBox(erro);
      Print(erro);
      return(INIT_FAILED);
     }

   if(AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO)
     {
      string erro="EA permitido apenas em conta DEMO";
      MessageBox(erro);
      Print(erro);
      return(INIT_FAILED);
     }

   if((!MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_TESTER)) || MQLInfoInteger(MQL_VISUAL_MODE))
     {
      if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
         return(INIT_PARAMETERS_INCORRECT);
      //--- run application 

      ExtDialog.Run();
     }

   if(Estrategia==Afast)return MyAfastMed.OnInit();
   else return MyEA.OnInit();


//---

//---
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   if((!MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_TESTER))) ExtDialog.Destroy(reason);
   if(Estrategia==Afast)MyAfastMed.OnDeinit(reason);
   else MyEA.OnDeinit(reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(Estrategia==Afast)MyAfastMed.OnTick();
   else  MyEA.OnTick();
   if((!MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_TESTER)) || MQLInfoInteger(MQL_VISUAL_MODE)) ExtDialog.OnTick();
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  {
   if((!MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_TESTER)) || MQLInfoInteger(MQL_VISUAL_MODE)) ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyPanel::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {

   int xx1=INDENT_LEFT;
   int yy1=INDENT_TOP;
   int xx2=x1+BUTTON_WIDTH;
   int yy2=INDENT_TOP+BUTTON_HEIGHT;

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);

//--- create dependent controls 

   string s_estrateg="";
   if(Estrategia==Brain)s_estrateg="Brain Trend";
   if(Estrategia==Afast)s_estrateg="Afastamento da Média";
   if(Estrategia==Pivo)s_estrateg="Pivot Point";
   if(Estrategia==IndexZone)s_estrateg="IndexZone";
   if(Estrategia==TrendMag)s_estrateg="TrendMagic";
   if(Estrategia==Envel)s_estrateg="Envelopes";
   if(Estrategia==MaxMin)s_estrateg="Máximas e Mínimas";

   color cor_labels=clrDeepSkyBlue;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Estratégia: "+s_estrateg,xx1,yy1,xx2,yy2))
      return(false);

   m_label[0].Color(cor_labels);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;


   string str_pos;
   if(Estrategia!=Afast)
     {
      if(!MyEA.PosicaoAberta())str_pos="Zerado";
      if(MyEA.Buy_opened())str_pos="Comprado";
      if(MyEA.Sell_opened())str_pos="Vendido";
     }
   else
     {
      if(!MyAfastMed.PosicaoAberta())str_pos="Zerado";
      if(MyAfastMed.Buy_opened())str_pos="Comprado";
      if(MyAfastMed.Sell_opened())str_pos="Vendido";
     }
   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"Posição: "+str_pos,xx1,yy1,xx2,yy2))
      return(false);
   m_label[1].Color(cor_labels);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   string str_vol_pos;
   if(Estrategia!=Afast)
     {
      if(!MyEA.PosicaoAberta())str_vol_pos="-";
      if(MyEA.Buy_opened())str_vol_pos=DoubleToString(MyEA.VolPosType(POSITION_TYPE_BUY),2);
      if(MyEA.Sell_opened())str_vol_pos=DoubleToString(MyEA.VolPosType(POSITION_TYPE_SELL),2);
     }
   else
     {
      if(!MyAfastMed.PosicaoAberta())str_vol_pos="-";
      if(MyAfastMed.Buy_opened())str_vol_pos=DoubleToString(MyAfastMed.VolPosType(POSITION_TYPE_BUY),2);
      if(MyAfastMed.Sell_opened())str_vol_pos=DoubleToString(MyAfastMed.VolPosType(POSITION_TYPE_SELL),2);
     }

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"Volume: "+str_vol_pos,xx1,yy1,xx2,yy2))
      return(false);
   m_label[2].Color(cor_labels);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+3*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;


   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"Resultado Mensal: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[3].Color(cor_labels);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+4*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],"Resultado Semanal: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[4].Color(cor_labels);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+5*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[5],"Resultado Diário: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[5].Color(cor_labels);

   xx1=(int)(LARGURA_PAINEL-INDENT_RIGHT-0.7*BUTTON_WIDTH-CONTROLS_GAP_X);
   yy1=INDENT_TOP;
   xx2=(int)(xx1+0.7*BUTTON_WIDTH);
   yy2=(int)(yy1+1.5*BUTTON_HEIGHT);

   if(!CreateButton(m_chart_id,m_subwin,BotaoFechar,"ZERAR",xx1,yy1,xx2,yy2))
      return(false);
   BotaoFechar.ColorBackground(clrLime);

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyPanel::OnTick(void)
  {

   string s_estrateg="";
   if(Estrategia==Brain)s_estrateg="Brain Trend";
   if(Estrategia==Afast)s_estrateg="Afastamento da Média";
   if(Estrategia==Pivo)s_estrateg="Pivot Point";
   if(Estrategia==IndexZone)s_estrateg="IndexZone";
   if(Estrategia==TrendMag)s_estrateg="TrendMagic";
   if(Estrategia==Envel)s_estrateg="Envelopes";
   if(Estrategia==MaxMin)s_estrateg="Máximas e Mínimas";


   string str_pos;
   if(Estrategia!=Afast)
     {
      if(!MyEA.PosicaoAberta())str_pos="Zerado";
      if(MyEA.Buy_opened())str_pos="Comprado";
      if(MyEA.Sell_opened())str_pos="Vendido";
     }
   else
     {
      if(!MyAfastMed.PosicaoAberta())str_pos="Zerado";
      if(MyAfastMed.Buy_opened())str_pos="Comprado";
      if(MyAfastMed.Sell_opened())str_pos="Vendido";
     }
   string str_vol_pos;
   if(Estrategia!=Afast)
     {
      if(!MyEA.PosicaoAberta())str_vol_pos="-";
      if(MyEA.Buy_opened())str_vol_pos=DoubleToString(MyEA.VolPosType(POSITION_TYPE_BUY),2);
      if(MyEA.Sell_opened())str_vol_pos=DoubleToString(MyEA.VolPosType(POSITION_TYPE_SELL),2);
     }
   else
     {
      if(!MyAfastMed.PosicaoAberta())str_vol_pos="-";
      if(MyAfastMed.Buy_opened())str_vol_pos=DoubleToString(MyAfastMed.VolPosType(POSITION_TYPE_BUY),2);
      if(MyAfastMed.Sell_opened())str_vol_pos=DoubleToString(MyAfastMed.VolPosType(POSITION_TYPE_SELL),2);
     }

   if(Estrategia!=Afast)
     {
      m_label[0].Text("Estratégia: "+s_estrateg);
      m_label[1].Text("Posição: "+str_pos);
      m_label[2].Text("Volume: "+str_vol_pos);
      m_label[3].Text("Resultado Mensal: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2));
      m_label[4].Text("Resultado Semanal: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2));
      m_label[5].Text("Resultado Diário: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2));
     }
   else
     {
      m_label[0].Text("Estratégia: "+s_estrateg);
      m_label[1].Text("Posição: "+str_pos);
      m_label[2].Text("Volume: "+str_vol_pos);
      m_label[3].Text("Resultado Mensal: "+MyAfastMed.GetCurrency()+" "+DoubleToString(MyAfastMed.LucroTotalMes(),2));
      m_label[4].Text("Resultado Semanal: "+MyAfastMed.GetCurrency()+" "+DoubleToString(MyAfastMed.LucroTotalSemana(),2));
      m_label[5].Text("Resultado Diário: "+MyAfastMed.GetCurrency()+" "+DoubleToString(MyAfastMed.LucroTotal(),2));

     }

  }
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(MyPanel)
ON_EVENT(ON_CLICK,BotaoFechar,OnClickBotaoFechar)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
void OnClickBotaoFechar()
  {
   if(Estrategia!=Afast)
     {
      MyEA.DeleteALL();
      MyEA.CloseALL();
     }
   else
     {
      MyAfastMed.DeleteALL();
      MyAfastMed.CloseALL();
     }
  }
//+------------------------------------------------------------------+
