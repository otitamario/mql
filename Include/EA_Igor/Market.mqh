//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#define TAM_MAX_PRECOS 500 //Tamanho Maximo Array de PRECOS ACIMA ou ABAIXO

#include <EA_Igor\Params_Market.mqh>
#include<ChartObjects\ChartObjectsLines.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MarketRobot: public MyExpert
  {
private:
   CChartObjectHLine HLine_Entrada,HLine_SL,HLine_TP;
   CChartObjectHLine HLine_Break[5];
   CChartObjectHLine HLine_EntCont[6];
   CChartObjectHLine HLine_EntFav[4];
   CChartObjectVLine VLine[];
   double            preco_acima[TAM_MAX_PRECOS],preco_abaixo[TAM_MAX_PRECOS],precos[2*TAM_MAX_PRECOS];
   string            currency_symbol;
   int               stpmt_handle;
   double            STP_Buy[],STP_Sell[];
   double            sl,tp,price_open;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   CiIchimoku       *ichimoku;
   int               force_handle;
   double            vol_pos,vol_stp,preco_stp;
   double            sl_position,tp_position;
   bool              opt_tester;
   double            PointBreakEven[5];
   double            PointProfit[5];
   bool              buy_signal,sell_signal;
   bool              trade_buy,trade_sell;
   string            last_trade;
   bool              time_new_ent;
   string            pais;
   int               touros;
   bool              investing_filter,TemNoticia;
   datetime          Hora_in[],Hora_fin[];

public:
   void              MarketRobot();
   void             ~MarketRobot();
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

   bool              HLineCreate(const long            chart_ID=0,// ID de gráfico 
                                 const string          name="HLine",      // nome da linha 
                                 const int             sub_window=0,      // índice da sub-janela 
                                 double                price=0,           // line price 
                                 const color           clr=clrRed,        // cor da linha 
                                 const ENUM_LINE_STYLE style=STYLE_DASH,// estilo da linha 
                                 const int             width=1,           // largura da linha 
                                 const bool            back=false,        // no fundo 
                                 const bool            selection=true,    // destaque para mover 
                                 const bool            hidden=true,       //ocultar na lista de objetos 
                                 const long            z_order=0);
   bool              HLineDelete(const long   chart_ID=0,const string name="HLine"); // nome da linha 
   void              Histograma();
   bool              BarrasBaixa();
   bool              BarrasAlta();
   void              ContaTick();
   void              MudaTakeSemEntrada();
   void              MudaStopZero();
   bool              HorasInvesting(string _pais,int _touros);
   bool              InvestingTime(bool isnews);
   string            NewsInvesting(string _pais,int _touros);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MarketRobot::MarketRobot()
  {
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MarketRobot::~MarketRobot()
  {
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MarketRobot::OnInit(void)
  {

   trade_sell=true;
   trade_buy=true;
   last_trade="NEUTRO";
   tradeOn=true;
   time_new_ent=true;
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

   stpmt_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\STPMT.ex5",
                        InpPeriodK1,InpPeriodD1,InpSlowing1,InpMethod1,
                        InpPriceField1,InpWeight1,InpPeriodK2,InpPeriodD2,
                        InpSlowing2,InpMethod2,InpPriceField2,InpWeight2,InpPeriodK3,
                        InpPeriodD3,InpSlowing3,InpMethod3,InpPriceField3,
                        InpWeight3,InpPeriodK4,InpPeriodD4,InpSlowing4,
                        InpMethod4,InpPriceField4,InpWeight4,InpPeriodSig,InpShowComponents);
   ChartIndicatorAdd(curChartID,(int)ChartGetInteger(curChartID,CHART_WINDOWS_TOTAL),stpmt_handle);

   force_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\Force.ex5",vol_force,zzticks);
   ChartIndicatorAdd(curChartID,(int)ChartGetInteger(curChartID,CHART_WINDOWS_TOTAL),force_handle);

   ichimoku=new CiIchimoku;
   ichimoku.Create(Symbol(),periodoRobo,_tenkan_sen,_kijun_sen,_senkou_span_b);
   ichimoku.AddToChart(curChartID,0);

   ArraySetAsSeries(STP_Buy,true);
   ArraySetAsSeries(STP_Sell,true);
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

   switch(Inp_pais)
     {
      case EUR:
         pais="EUR";break;
      case CAN:
         pais="CAN";break;
      case USD:
         pais="USD";break;
      case BRL:
         pais="BRL";break;
     }

   switch(Inp_touros)
     {
      case Touro_1:
         touros=1;break;
      case Touro_2:
         touros=2;break;
      case Touro_3:
         touros=3;break;
     }

   if(UsarNew && HorasInvesting(pais,touros))
     {
      investing_filter=false;
      int j=ObjectsDeleteAll(ChartID(),0,OBJ_VLINE);
      ArrayResize(VLine,ArraySize(Hora_fin));
      for(int i=0;i<ArraySize(Hora_fin);i++)
        {
         if(Hora_in[i]>0 && Hora_fin[i]>0)
           {
            Print("inicio "+TimeToString(Hora_in[i])+" fim "+TimeToString(Hora_fin[i]));
            investing_filter=investing_filter || (TimeCurrent()>=Hora_in[i] && TimeCurrent()<=Hora_fin[i]);
            TemNoticia=true;
            VLine[i].Create(ChartID(),"News_"+IntegerToString(i),0,Hora_in[i]+minutos_news*60);
            VLine[i].Color(clrBlue);
           }
        }

     }
   else
     {
      Alert("Sem notícias filtradas");
      investing_filter=false;
      TemNoticia=false;
     }

   if(UsarNew)MessageBox(NewsInvesting(pais,touros));

   return(INIT_SUCCEEDED);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MarketRobot::OnTimer()
  {
   trade_buy=true;
   trade_sell=true;
   time_new_ent=true;
   EventKillTimer();
   Print("Pausa de "+IntegerToString(n_minutesMark)+" minutos finalizada. Novas Entradas Permitidas");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MarketRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   IndicatorRelease(stpmt_handle);
   IndicatorRelease(force_handle);
   delete(ichimoku);
   DeletaIndicadores();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MarketRobot::OnTick(void)
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

      ArrayInitialize(preco_abaixo,0.0);
      ArrayInitialize(preco_acima,0.0);
      gv.Set("glob_pr_max",0.0);
      gv.Set("glob_pr_cp",0.0);
      gv.Set("glob_pr_vd",0.0);


      if(UsarNew && HorasInvesting(pais,touros))
        {
         investing_filter=false;
         int j=ObjectsDeleteAll(ChartID(),0,OBJ_VLINE);
         ArrayResize(VLine,ArraySize(Hora_fin));
         for(int i=0;i<ArraySize(Hora_fin);i++)
           {
            if(Hora_in[i]>0 && Hora_fin[i]>0)
              {
               Print("inicio "+TimeToString(Hora_in[i])+" fim "+TimeToString(Hora_fin[i]));
               investing_filter=investing_filter || (TimeCurrent()>=Hora_in[i] && TimeCurrent()<=Hora_fin[i]);
               TemNoticia=true;
               VLine[i].Create(ChartID(),"News_"+IntegerToString(i),0,Hora_in[i]+minutos_news*60);
               VLine[i].Color(clrBlue);
              }
           }

        }
      else
        {
         Alert("Sem notícias filtradas");
         investing_filter=false;
         TemNoticia=false;
        }

     }// Fim Novo Dia

   timerOn=true;
   investing_filter=false;
   if(UsarNew)investing_filter=InvestingTime(TemNoticia);

   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
      if(UsarNew && investing_filter)
        {
        timerOn=false;
        }
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
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))return;

   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
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


   ContaTick();

   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened()) CloseByPosition();

   if(!PosicaoAberta())
     {
      DeleteOrdersExEntry();
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

      MudaTakeSemEntrada();
      MudaStopZero();

      if(Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo))
        {

         HLineDelete(0,"MaisNegociado");
         HLineDelete(0,"Compra");
         HLineDelete(0,"Venda");

         Histograma();
         if(ReverterMark)
           {
            buy_signal=!Buy_opened() && BuySignal();
            sell_signal=!Sell_opened() && SellSignal();
           }
         else
           {
            buy_signal=!PosicaoAberta() && BuySignal();
            sell_signal=!PosicaoAberta() && SellSignal();
           }

         if(inverter)
           {
            bool aux_signal=buy_signal;
            buy_signal=sell_signal;
            sell_signal=aux_signal;
           }

         if(gv.Get("glob_pr_max")>0 && sell_signal && time_new_ent && operar!=Compra)
           {
            DeleteALL();
            CloseALL();
            if(gv.Get("glob_pr_max")<bid)
              {
               sl_position=NormalizeDouble(gv.Get("glob_pr_max")+_Stop*ponto,digits);
               if(mytrade.SellStop(Lot,gv.Get("glob_pr_max"),Symbol(),sl_position,0,order_time_type,0,"SELL"+exp_name))
                 {
                  gv.Set(vd_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Erro enviar ordem ",GetLastError());
              }
            else
              {
               sl_position=NormalizeDouble(ask+_Stop*ponto,digits);
               if(mytrade.Sell(Lot,Symbol(),0,sl_position,0,"SELL"+exp_name))
                 {
                  gv.Set(vd_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Erro enviar ordem ",GetLastError());

              }
           }
         if(gv.Get("glob_pr_max")>0 && buy_signal && time_new_ent && operar!=Venda)
           {
            DeleteALL();
            CloseALL();
            if(gv.Get("glob_pr_max")>ask)
              {

               sl_position=NormalizeDouble(gv.Get("glob_pr_max")-_Stop*ponto,digits);
               if(mytrade.BuyStop(Lot,gv.Get("glob_pr_max"),Symbol(),sl_position,0,order_time_type,0,"BUY"+exp_name))
                 {
                  gv.Set(cp_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Erro enviar ordem ",GetLastError());
              }
            else
              {
               sl_position=NormalizeDouble(bid-_Stop*ponto,digits);
               if(mytrade.Buy(Lot,Symbol(),0,sl_position,0,"BUY"+exp_name))
                 {
                  gv.Set(cp_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Erro enviar ordem ",GetLastError());

              }

           }

         ArrayInitialize(preco_abaixo,0.0);
         ArrayInitialize(preco_acima,0.0);
         ArrayInitialize(precos,0.0);
        }//End NewBar 

     }//End Trade On

  }//Fim Ontick
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool MarketRobot::GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(stpmt_handle,0,0,5,STP_Buy)<=0 || 
         CopyBuffer(stpmt_handle,1,0,5,STP_Sell)<=0 || 
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
bool MarketRobot::TimeDayFilter()
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
bool MarketRobot::BuySignal()
  {
   bool signal=false;
   signal=STP_Buy[2]<STP_Sell[2] && STP_Buy[1]>STP_Sell[1];
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MarketRobot::SellSignal()
  {
   bool signal=false;
   signal=STP_Buy[2]>STP_Sell[2] && STP_Buy[1]<STP_Sell[1];
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MarketRobot::OnTradeTransaction(const MqlTradeTransaction &trans,
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
                  Print("Pausa de "+IntegerToString(n_minutesMark)+" minutos Interrompida. Novas Entradas Permitidas");
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
                     Print("break Even. Pausa de "+IntegerToString(n_minutesMark)+" minutos Interrompida. Novas Entradas Permitidas");
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

            if(ReverterMark && last_trade=="SELL" && n_minutesMark>0)
              {
               trade_sell=false;
               EventSetTimer(n_minutesMark*60);
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
            if(ReverterMark && last_trade=="BUY" && n_minutesMark>0)
              {
               trade_buy=false;
               EventSetTimer(n_minutesMark*60);
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

         if(StringFind(myhistory.Comment(),"Entrada Parcial")>=0 && trans.order_state==ORDER_STATE_FILLED)
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

         if(myhistory.Comment()=="Entrada Parcial 1" && trans.order_state==ORDER_STATE_FILLED)
           {
            if(Buy_opened())
              {
               myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick));
               tp_position=myposition.PriceOpen()+(0.01*porc_take*_TakeProfit*ponto);
               tp_position=NormalizeDouble(MathRound(tp_position/ticksize)*ticksize,digits);
               if(TimeCurrent()-myposition.Time()<=time_order) mytrade.OrderModify((ulong)gv.Get(tp_vd_tick),tp_position,0,0,order_time_type,0,0);
              }
            if(Sell_opened())
              {
               myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick));
               tp_position=myposition.PriceOpen()-(0.01*porc_take*_TakeProfit*ponto);
               tp_position=NormalizeDouble(MathRound(tp_position/ticksize)*ticksize,digits);
               Print("Time ",IntegerToString(TimeCurrent()-myposition.Time()));
               if(TimeCurrent()-myposition.Time()<=time_order) mytrade.OrderModify((ulong)gv.Get(tp_cp_tick),tp_position,0,0,order_time_type,0,0);
              }
           }

         if(StringFind(myhistory.Comment(),"Entrada Favor")>=0 && trans.order_state==ORDER_STATE_FILLED)
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
        }//Fim History Select
     }//FIM TRANSACTION HISTOY ADD
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MarketRobot::Entr_Parcial_Buy(const double preco)
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
void MarketRobot::Entr_Parcial_Sell(const double preco)
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
void MarketRobot::Entr_Favor_Buy(const double preco)
  {

   sl_position=NormalizeDouble(preco-_Stop*ponto,digits);
   if(Lot_entry1_fv>0) mytrade.BuyStop(Lot_entry1_fv,NormalizeDouble(preco+pts_entry1_fv*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Favor 1");
   if(Lot_entry2_fv>0) mytrade.BuyStop(Lot_entry2_fv,NormalizeDouble(preco+pts_entry2_fv*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Favor 2");
   if(Lot_entry3_fv>0) mytrade.BuyStop(Lot_entry3_fv,NormalizeDouble(preco+pts_entry3_fv*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Favor 3");
   if(Lot_entry4_fv>0) mytrade.BuyStop(Lot_entry4_fv,NormalizeDouble(preco+pts_entry4_fv*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Favor 4");
  }
//+------------------------------------------------------------------+
void MarketRobot::Entr_Favor_Sell(const double preco)
  {
   sl_position=NormalizeDouble(preco+_Stop*ponto,digits);
   if(Lot_entry1_fv>0) mytrade.SellStop(Lot_entry1_fv,NormalizeDouble(preco-pts_entry1_fv*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Favor 1");
   if(Lot_entry2_fv>0) mytrade.SellStop(Lot_entry2_fv,NormalizeDouble(preco-pts_entry2_fv*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Favor 2");
   if(Lot_entry3_fv>0) mytrade.SellStop(Lot_entry3_fv,NormalizeDouble(preco-pts_entry3_fv*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Favor 3");
   if(Lot_entry4_fv>0) mytrade.SellStop(Lot_entry4_fv,NormalizeDouble(preco-pts_entry4_fv*ponto,digits),original_symbol,sl_position,0,order_time_type,0,"Entrada Favor 4");
  }
//+------------------------------------------------------------------+

void MarketRobot::Atual_vol_Stop_Take()
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
         preco_stp=NormalizeDouble(PrecoMedio(POSITION_TYPE_BUY)+_TakeProfit*ponto,digits);

         if(vol_pos!=vol_stp)
           {
            mytrade.OrderDelete((ulong)gv.Get("tp_vd_tick"));
            mytrade.SellLimit(vol_pos, preco_stp, original_symbol, 0, 0, 0, 0, "TAKE PROFIT");
            gv.Set("tp_vd_tick",(double)mytrade.ResultOrder());
            ObjectDelete(0,"TakeProfit");
            ObjectDelete(0,"Line_TP");
            CriandoTagPreco(clrLightPink,"TakeProfit",preco_stp);
            HLine_TP.Create(0,"Line_TP",0,preco_stp);
            HLine_TP.Color(clrLightPink);

           }
        }
     }
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
            mytrade.BuyLimit(vol_pos, preco_stp, original_symbol, 0, 0, 0, 0, "TAKE PROFIT");
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
void MarketRobot::Real_Parc_Buy(double vol,double preco)
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
void MarketRobot::Real_Parc_Sell(double vol,double preco)
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
void MarketRobot::SegurancaPos(int nsec)
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
void MarketRobot::CriandoTagPreco(color cor,string name_tag,double alvo)
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
void MarketRobot::CreateLinesBreakBuy(double preco)
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
void MarketRobot::CreateLinesBreakSell(double preco)
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
void MarketRobot::CreateLinesContraBuy(double preco)
  {
   double Entr_Cont_Buf[6];
   double preco_break;
   Entr_Cont_Buf[0]=pts_entry1; Entr_Cont_Buf[1]=pts_entry2; Entr_Cont_Buf[2]=pts_entry3;
   Entr_Cont_Buf[3]=pts_entry4; Entr_Cont_Buf[4]=pts_entry5;Entr_Cont_Buf[5]=pts_entry6;

   for(int i=0;i<6;i++)
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
void MarketRobot::CreateLinesContraSell(double preco)
  {
   double Entr_Cont_Buf[6];
   double preco_break;
   Entr_Cont_Buf[0]=pts_entry1; Entr_Cont_Buf[1]=pts_entry2; Entr_Cont_Buf[2]=pts_entry3;
   Entr_Cont_Buf[3]=pts_entry4; Entr_Cont_Buf[4]=pts_entry5;Entr_Cont_Buf[5]=pts_entry6;

   for(int i=0;i<6;i++)
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
void MarketRobot::CreateLinesFavorBuy(double preco)
  {
   double Entr_Fv_Buf[4];
   double preco_break;
   Entr_Fv_Buf[0]=pts_entry1_fv; Entr_Fv_Buf[1]=pts_entry2_fv; Entr_Fv_Buf[2]=pts_entry3_fv;
   Entr_Fv_Buf[3]=pts_entry4_fv;
   for(int i=0;i<4;i++)
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
void MarketRobot::CreateLinesFavorSell(double preco)
  {
   double Entr_Fv_Buf[4];
   double preco_break;
   Entr_Fv_Buf[0]=pts_entry1_fv; Entr_Fv_Buf[1]=pts_entry2_fv; Entr_Fv_Buf[2]=pts_entry3_fv;
   Entr_Fv_Buf[3]=pts_entry4_fv;
   for(int i=0;i<4;i++)
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

bool MarketRobot::HLineCreate(const long            chart_ID=0,// ID de gráfico 
                              const string          name="HLine",      // nome da linha 
                              const int             sub_window=0,      // índice da sub-janela 
                              double                price=0,           // line price 
                              const color           clr=clrRed,        // cor da linha 
                              const ENUM_LINE_STYLE style=STYLE_DASH,// estilo da linha 
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
bool MarketRobot::HLineDelete(const long   chart_ID=0,// ID do gráfico 
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
void MarketRobot::Histograma()
  {
   int total_acima,total_abaixo;
   double value_tick;
   double preco_compra,preco_venda,preco_max;
   double soma;
   int id_max;
   int size_acima,size_abaixo;
   size_acima=ArraySize(preco_acima);
   size_abaixo=ArraySize(preco_abaixo);
   soma=0;
   preco_compra=0.0;
   preco_venda=0.0;
   for( int i=0;i<size_acima;i++)soma+=preco_acima[i];
   for( int i=0;i<size_abaixo;i++)soma+=preco_abaixo[i];
   if(soma>0)
     {
      for(int i=0;i<size_acima;i++)
        {
         preco_acima[i]=preco_acima[i]/soma;
        }
      for(int i=0;i<size_abaixo;i++)
        {
         preco_abaixo[i]=preco_abaixo[i]/soma;
        }
     }
   int cont=0;
   value_tick=preco_acima[cont];
   while(value_tick!=0)
     {
      cont+=1;
      value_tick=preco_acima[cont];
     }
   total_acima=cont;
   cont=0;
   value_tick=preco_abaixo[cont];
   while(value_tick!=0)
     {
      cont+=1;
      value_tick=preco_abaixo[cont];

     }
   total_abaixo=cont;
   for(int i=0;i<total_abaixo;i++)precos[i]=preco_abaixo[total_abaixo-1-i];
   for(int i=total_abaixo;i<total_abaixo+total_acima;i++)precos[i]=preco_acima[i-total_abaixo];
   double media=0;
   for(int i=0;i<ArraySize(precos);i++)
     {
      if(precos[i]>0)
        {
         //       Print("preco ",DoubleToString(low[1]+i*ticksize,digits)," porcentagem ",DoubleToString(precos[i]*100,2));
         media+=100*precos[i];
        }

     }
   id_max=ArrayMaximum(precos,0);
   preco_max=low[1]+id_max*ticksize;
   gv.Set("glob_pr_max",preco_max);
   HLineCreate(0,"MaisNegociado",0,gv.Get("glob_pr_max"),clrOrangeRed,STYLE_SOLID,2,false,false,true,0);
   bool achou_compra=false;
   for(int i=id_max+1;i<ArraySize(precos);i++)
     {
      if(precos[i]<porc_lim/100)
        {
         preco_compra=preco_max+(i-id_max)*ticksize;
         achou_compra=true;
         break;
        }
     }
   if(!achou_compra)preco_compra=0;
   gv.Set("glob_pr_cp",preco_compra);
   bool achou_venda=false;
   for(int i=id_max-1;i>=0;i--)
     {
      if(precos[i]<porc_lim/100)
        {
         preco_venda=preco_max-(id_max-i)*ticksize;
         achou_venda=true;
         break;
        }
     }
   if(!achou_venda)preco_venda=0;
   gv.Set("glob_pr_vd",preco_venda);

   if(close[1]<preco_max)
     {

      if(!BarrasAlta())
        {
         gv.Set("glob_pr_vd",0);
         if(gv.Get("glob_pr_cp")>0)HLineCreate(0,"Compra",0,gv.Get("glob_pr_cp"),clrDarkGray,STYLE_SOLID,2,false,false,true,0);
        }
      else
        {
         gv.Set("glob_pr_cp",0);
         if(gv.Get("glob_pr_vd")>0)HLineCreate(0,"Venda",0,gv.Get("glob_pr_vd"),clrWhite,STYLE_SOLID,2,false,false,true,0);

        }

     }

   if(close[1]>preco_max)
     {
      if(!BarrasBaixa())
        {
         gv.Set("glob_pr_cp",0);
         if(gv.Get("glob_pr_vd")>0)HLineCreate(0,"Venda",0,gv.Get("glob_pr_vd"),clrRed,STYLE_SOLID,2,false,false,true,0);
        }
      else
        {
         gv.Set("glob_pr_vd",0);
         if(gv.Get("glob_pr_cp")>0)HLineCreate(0,"Compra",0,gv.Get("glob_pr_cp"),clrAqua,STYLE_SOLID,2,false,false,true,0);
        }
     }
   if(close[1]==preco_max)
     {
      gv.Set("glob_pr_cp",0);
      gv.Set("glob_pr_vd",0);
     }
  }
//+------------------------------------------------------------------+
bool MarketRobot::BarrasAlta()
  {
   bool signal=close[1]>open[1] && close[2]>open[2] && close[3]>open[3] && close[4]>open[4];
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MarketRobot::BarrasBaixa()
  {
   bool signal=close[1]<open[1] && close[2]<open[2] && close[3]<open[3] && close[4]<open[4];
   return signal;
  }
//+------------------------------------------------------------------+
void MarketRobot::ContaTick()
  {
   MqlTick last_tick;
   double last=0.0;
   int numb_tick;
   if(SymbolInfoTick(Symbol(),last_tick))
      if(last_tick.last>0)
         last=last_tick.last;
   numb_tick=(int)((last-open[0])/ticksize);
   if(numb_tick>=0)
     {
      preco_acima[numb_tick]+=1;
     }
   else
     {
      preco_abaixo[-numb_tick-1]+=1;
     }
  }
//+------------------------------------------------------------------+
void MarketRobot::MudaStopZero()
  {
   double stp_atual,stp_new;
   if(Buy_opened())
     {
      myposition.SelectByTicket((ulong)gv.Get(cp_tick));
      stp_new = myposition.PriceOpen() + ticksize;
      stp_new = NormalizeDouble(MathRound(stp_new / ticksize) * ticksize, digits);
      stp_atual=myposition.StopLoss();
      if(TimeCurrent()-myposition.Time()>=time_order_zero*60 && stp_new>stp_atual && mysymbol.Bid()>stp_new)
        {

         for(int i=PositionsTotal()-1; i>=0; i--)
           {
            if(myposition.SelectByIndex(i))
              {
               if(myposition.Symbol()!=mysymbol.Name())continue;
                 {
                  if(myposition.Magic()!=Magic_Number)continue;
                    {
                     if(myposition.PositionType()==POSITION_TYPE_BUY)
                       {
                        if(stp_new<SymbolInfoDouble(original_symbol,SYMBOL_BID) && stp_new<myposition.PriceOpen())
                          {
                           mytrade.PositionModify(myposition.Ticket(),stp_new,myposition.TakeProfit());
                          }
                        else
                          {
                           mytrade.PositionClose(myposition.Ticket());
                          }
                       }
                    }
                 }
              }
           }

        }

     }
   if(Sell_opened())
     {
      myposition.SelectByTicket((ulong)gv.Get(vd_tick));
      stp_new = myposition.PriceOpen() + ticksize;
      stp_new = NormalizeDouble(MathRound(stp_new / ticksize) * ticksize, digits);
      stp_atual=myposition.StopLoss();
      if(TimeCurrent()-myposition.Time()>=time_order_zero*60 && stp_new<stp_atual && mysymbol.Ask()<stp_new)
        {
         for(int i=PositionsTotal()-1; i>=0; i--)
           {
            if(myposition.SelectByIndex(i))
              {
               if(myposition.Symbol()!=mysymbol.Name())continue;
                 {
                  if(myposition.Magic()!=Magic_Number)continue;
                    {
                     if(myposition.PositionType()==POSITION_TYPE_SELL)
                       {
                        if(stp_new>SymbolInfoDouble(original_symbol,SYMBOL_ASK) && stp_new>myposition.PriceOpen())
                          {
                           mytrade.PositionModify(myposition.Ticket(),stp_new,myposition.TakeProfit());
                          }
                        else
                          {
                           mytrade.PositionClose(myposition.Ticket());
                          }
                       }
                    }
                 }
              }
           }

        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MarketRobot::MudaTakeSemEntrada()
  {
   double take_atual;
   if(Buy_opened() && OrdemAbertaComent("Entrada Parcial 1"))
     {
      myposition.SelectByTicket((ulong)gv.Get(cp_tick));
      tp_position = myposition.PriceOpen() + (0.01 * porc_take * _TakeProfit * ponto);
      tp_position = NormalizeDouble(MathRound(tp_position / ticksize) * ticksize, digits);
      myorder.Select((ulong)gv.Get(tp_vd_tick));
      take_atual=myorder.PriceOpen();
      if(TimeCurrent()-myposition.Time()>=time_order_sem && take_atual>tp_position)
         mytrade.OrderModify((ulong)gv.Get(tp_vd_tick),tp_position,0,0,order_time_type,0,0);
     }
   if(Sell_opened() && OrdemAbertaComent("Entrada Parcial 1"))
     {
      myposition.SelectByTicket((ulong)gv.Get(vd_tick));
      tp_position = myposition.PriceOpen() - (0.01 * porc_take * _TakeProfit * ponto);
      tp_position = NormalizeDouble(MathRound(tp_position / ticksize) * ticksize, digits);
      myorder.Select((ulong)gv.Get(tp_cp_tick));
      take_atual=myorder.PriceOpen();
      if(TimeCurrent()-myposition.Time()>=time_order_sem && take_atual<tp_position)
         mytrade.OrderModify((ulong)gv.Get(tp_cp_tick),tp_position,0,0,order_time_type,0,0);
     }
  }
//+------------------------------------------------------------------+
bool MarketRobot::HorasInvesting(string _pais,int _touros)
  {
//Tentative
   datetime hora_init_news,hora_fin_news,hora_news;
   string str_time_new;
   string to_split=Investing::getDados(_pais,_touros); // Um string para dividir em substrings
   string sep="#";                // Um separador como um caractere
   ushort u_sep;                  // O código do caractere separador
   string result[];               // Um array para obter strings
//--- Obtém o código do separador
   u_sep=StringGetCharacter(sep,0);
//--- Divide a string em substrings
   int k=StringSplit(to_split,u_sep,result);
//--- Exibe um comentário
//  PrintFormat("Strings obtidos: %d. Usado separador '%s' com o código %d",k,sep,u_sep);
//--- Agora imprime todos os resultados obtidos
   if(k>0)
     {
      ArrayResize(Hora_in,k);
      ArrayResize(Hora_fin,k);
      ArrayInitialize(Hora_in,0);
      ArrayInitialize(Hora_fin,0);
      for(int i=0;i<k;i++)
        {
         //PrintFormat("result[%d]=\"%s\"",i,result[i]);
         str_time_new=StringSubstr(result[i],0,5);
         if(str_time_new!="Tentative")
           {
            hora_news=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+str_time_new);
            hora_init_news=hora_news-minutos_news*60;
            hora_fin_news=hora_news+minutos_news*60;
            Hora_in[i]=hora_init_news;
            Hora_fin[i]=hora_fin_news;
           }
        }
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool MarketRobot::InvestingTime(bool isnews)
  {
   bool investing;
   if(isnews)
     {
      investing=false;
      for(int i=0;i<ArraySize(Hora_fin);i++)
        {
         if(Hora_in[i]>0 && Hora_fin[i]>0) investing=investing || (TimeCurrent()>=Hora_in[i] && TimeCurrent()<=Hora_fin[i]);
        }
     }
   else investing=false;
   return investing;
  }
//+------------------------------------------------------------------+
string MarketRobot::NewsInvesting(string _pais,int _touros)
  {
//Tentative
   datetime hora_init_news,hora_fin_news,hora_news;
   string str_time_new;
   string to_split=Investing::getDados(_pais,_touros); // Um string para dividir em substrings
   string sep="#";                // Um separador como um caractere
   ushort u_sep;                  // O código do caractere separador
   string result[];               // Um array para obter strings
//--- Obtém o código do separador
   u_sep=StringGetCharacter(sep,0);
//--- Divide a string em substrings
   int k=StringSplit(to_split,u_sep,result);
//--- Exibe um comentário
//  PrintFormat("Strings obtidos: %d. Usado separador '%s' com o código %d",k,sep,u_sep);
//--- Agora imprime todos os resultados obtidos
   string timer_news="-----------------Filtro de Notícias-------------"+"\n";
   if(k>0)
     {
      for(int i=0;i<k;i++)
        {
         //PrintFormat("result[%d]=\"%s\"",i,result[i]);
         timer_news=timer_news+result[i]+"\n";
         str_time_new=StringSubstr(result[i],0,5);
         if(str_time_new!="Tentative")
           {
            hora_news=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+str_time_new);
            hora_init_news=hora_news-minutos_news*60;
            hora_fin_news=hora_news+minutos_news*60;
            timer_news=timer_news+"Hora início pausa news: "+TimeToString(hora_init_news)+" Hora final pausa news: "+TimeToString(hora_fin_news)+"\n";
            timer_news=timer_news+"-------------------------------------------------------------------"+"\n";
           }
        }
     }
   return timer_news;
  }
//+------------------------------------------------------------------+
