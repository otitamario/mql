//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <EA_EST_PRP\Params_EstProp.mqh>
#include<ChartObjects\ChartObjectsLines.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class HedgeRobot: public MyExpert
  {
private:
   CChartObjectHLine HLine_Price,HLine_SL,HLine_TP;
   CChartObjectLabel LabelLucroGlob;
   CChartObjectLabel LabelLucroGrupo;
   string            currency_symbol;
   double            preco_medio;
   double            vol_pos,vol_stp,preco_stp;
   double            sl_position,tp_position;
   bool              opt_tester;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   bool              buysignal,sellsignal;
   Reentradas        Reent_Ord[5];

public:
   void              HedgeRobot();
   void             ~HedgeRobot();
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
   void              SegurancaPos(int nsec);
   bool              buy_sent,sell_sent;
   double            LucroOrdensGrupo();
   double            LucroGrupo();
   double            LucroPositionsGrupo();
   void              CloseALLGrupo();
   void              DeleteALLGrupo();
   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HedgeRobot::HedgeRobot()
  {

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HedgeRobot::~HedgeRobot()
  {
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int HedgeRobot::OnInit(void)
  {

   buy_sent=false;
   sell_sent=false;
   EventSetMillisecondTimer(200);
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

//  mytrade.SetTypeFillingBySymbol(original_symbol);
   mytrade.SetTypeFilling(ORDER_FILLING_RETURN);

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

   Reent_Ord[0].Lote=Lot_entry1;Reent_Ord[0].Ponto=pts_entry1;Reent_Ord[0].SL=_Stop1;Reent_Ord[0].TP=_TakeProfit1;
   Reent_Ord[1].Lote=Lot_entry2;Reent_Ord[1].Ponto=pts_entry2;Reent_Ord[1].SL=_Stop2;Reent_Ord[1].TP=_TakeProfit2;
   Reent_Ord[2].Lote=Lot_entry3;Reent_Ord[2].Ponto=pts_entry3;Reent_Ord[2].SL=_Stop3;Reent_Ord[2].TP=_TakeProfit3;
   Reent_Ord[3].Lote=Lot_entry4;Reent_Ord[3].Ponto=pts_entry4;Reent_Ord[3].SL=_Stop4;Reent_Ord[3].TP=_TakeProfit4;
   Reent_Ord[4].Lote=Lot_entry5;Reent_Ord[4].Ponto=pts_entry5;Reent_Ord[4].SL=_Stop5;Reent_Ord[4].TP=_TakeProfit5;


   ulong curChartID=ChartID();

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

// parametros incorretos desnecessarios na otimizacao
   bool stop_entr_cont=_Stop<=pts_entry1 || _Stop<=pts_entry2 || _Stop<=pts_entry3;
   stop_entr_cont=stop_entr_cont || _Stop<=pts_entry4 || _Stop<=pts_entry5;
/*  if(stop_entr_cont)
     {
      string erro="O Stop Máximo deve ser maior que todos pontos de aumento entrada";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }
*/

   LabelLucroGlob.Create(0,"Label Lucro Glob",0,(int)(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS)-200),20);
   LabelLucroGlob.Color(clrYellow);
   LabelLucroGlob.Description("Lucro Global "+AccountInfoString(ACCOUNT_CURRENCY)+" "+DoubleToString(LucroGlobal(),2));

   LabelLucroGrupo.Create(0,"Label Lucro Grupo",0,(int)(ChartGetInteger(0,CHART_WIDTH_IN_PIXELS)-200),40);
   LabelLucroGrupo.Color(clrAqua);
   LabelLucroGrupo.Description("Lucro Grupo "+AccountInfoString(ACCOUNT_CURRENCY)+" "+DoubleToString(LucroGrupo(),2));



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
void HedgeRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   DeletaIndicadores();
   int k=ObjectsDeleteAll(0,"",0,OBJ_HLINE);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void HedgeRobot::OnTimer()
  {
   if(TimeCurrent()==hora_inicial)
     {
      if(BuySignal() && !Buy_opened() && !buy_sent)
        {
         buy_sent=true;
         sl_position=NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_BID)-_Stop*ponto,digits);
         tp_position=NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_ASK)+_TakeProfit*ponto,digits);

         if(mytrade.Buy(Lot,original_symbol,0,sl_position,tp_position,start_hour+"_"+"BUY"+exp_name))
           {
            gv.Set(cp_tick,(double)mytrade.ResultOrder());
           }
         else Print("Erro enviar ordem ",GetLastError());
        }
      if(SellSignal() && !Sell_opened() && !sell_sent)
        {
         sell_sent=true;
         sl_position=NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_ASK)+_Stop*ponto,digits);
         tp_position=NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_BID)-_TakeProfit*ponto,digits);

         if(mytrade.Sell(Lot,original_symbol,0,sl_position,tp_position,start_hour+"_"+"SELL"+exp_name))
           {
            gv.Set(vd_tick,(double)mytrade.ResultOrder());
           }
         else Print("Erro enviar ordem ",GetLastError());
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HedgeRobot::OnTick(void)
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
      hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
      hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

      lucro_orders=LucroOrdens();
      if(!opt_tester)
        {
         lucro_orders_mes=LucroOrdensMes();
         lucro_orders_sem=LucroOrdensSemana();
        }

      buy_sent=false;
      sell_sent=false;
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
         if(OrdersTotal()>0)
           {
            DeleteALL();
           }
         if(PositionsTotal()>0)
           {
            CloseALL();
           }
        }
      return;
     }

   if(!tradeOn)return;

   gv.Set("gv_today_prev",gv.Get("gv_today"));

//MytradeTransaction();

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   if(!mysymbol.Refresh() || !mysymbol.RefreshRates())
      return;
   if(!mysymbol.IsSynchronized())//Símbolos não sincronizados
      return;
   if(mysymbol.Bid()>=mysymbol.Ask()) //Leilão
      return;


   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }
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
   switch(filtrolucro)
     {
      case ProfitGrupo:
         lucro_total=LucroGrupo();
         break;
      case ProfitGlob:
         lucro_total=LucroGlobal();
         break;
      case ProfitRobo:
         lucro_total=LucroTotal();
         break;
     }
   if(!opt_tester)
     {
      lucro_total_semana=lucro_orders_sem+lucro_positions;
      lucro_total_mes=lucro_orders_mes+lucro_positions;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UsarLucro && ((lucro_total>=lucro && lucro>0) || (lucro_total<=-prejuizo && prejuizo>0)))
     {
      if(PositionsTotal()>0) CloseALLGrupo();
      if(OrdersTotal()>0)DeleteALLGrupo();
      tradeOn=false;
      return;
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


   LabelLucroGlob.Description("Lucro Global "+AccountInfoString(ACCOUNT_CURRENCY)+" "+DoubleToString(LucroGlobal(),2));
   LabelLucroGrupo.Description("Lucro Grupo "+AccountInfoString(ACCOUNT_CURRENCY)+" "+DoubleToString(LucroGrupo(),2));

//if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened()) CloseByPosition();

   if(!PosicaoAberta())
     {
      if(!opt_tester)
        {
         int k=ObjectsDeleteAll(0,"",0,OBJ_HLINE);
        }
     }
   else
     {
      //Atual_vol_Stop_Take();
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

      if(Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo))
        {
        }//End NewBar

     }//End Trade On

  }//Fim Ontick
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool HedgeRobot::GetIndValue()
  {
   bool b_get;
   b_get=CopyHigh(Symbol(),period,0,3,high)<=0 || 
         CopyOpen(Symbol(),period,0,3,open)<=0 || 
         CopyLow(Symbol(),period,0,3,low)<=0 || 
         CopyClose(Symbol(),period,0,3,close)<=0;
   return(b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HedgeRobot::TimeDayFilter()
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
bool HedgeRobot::BuySignal()
  {
   bool signal=false;
   signal=sentido!=Venda && (bool)TerminalInfoInteger(TERMINAL_CONNECTED);
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HedgeRobot::SellSignal()
  {
   bool signal=false;
   signal=sentido!=Compra && (bool)TerminalInfoInteger(TERMINAL_CONNECTED);
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HedgeRobot::SegurancaPos(int nsec)
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
void HedgeRobot::MytradeTransaction()
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

            if(mydeal.Comment()==start_hour+"_"+"BUY"+exp_name || mydeal.Comment()==start_hour+"_"+"SELL"+exp_name)
              {
               gv.Set("glob_entr_tot",gv.Get("glob_entr_tot")+1);
              }

            if(mydeal.Comment()==start_hour+"_"+"BUY"+exp_name)
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
               mytrade.PositionModify(order_ticket,sl_position,tp_position);
/*if(mytrade.SellLimit(Lot,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT"))
                 {
                  gv.Set("tp_vd_tick",(double)mytrade.ResultOrder());
                 }
               else
                  Print("Erro enviar ordem: ",GetLastError());
               */
               Entr_Parcial_Sell(buyprice);

               if(!opt_tester)
                 {
                  int k=ObjectsDeleteAll(0,0,OBJ_HLINE);
                  HLine_Price.Create(0,"Entrada_BUY",0,buyprice);
                  HLine_Price.Color(clrAqua);
                  HLine_SL.Create(0,"Stop Loss_BUY",0,myposition.StopLoss());
                  HLine_SL.Color(clrRed);
                  HLine_TP.Create(0,"Take Profit_BUY",0,myposition.TakeProfit());
                  HLine_TP.Color(clrLime);
                 }
              }
            //--------------------------------------------------

            if(mydeal.Comment()==start_hour+"_"+"SELL"+exp_name)
              {
               myposition.SelectByTicket(order_ticket);
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
               mytrade.PositionModify(order_ticket,sl_position,tp_position);
/*if(mytrade.BuyLimit(Lot,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT"))
                 {
                  gv.Set("tp_cp_tick",(double)mytrade.ResultOrder());
                 }
               else
                  Print("Erro enviar ordem: ",GetLastError());
              */
               Entr_Parcial_Buy(sellprice);
               if(!opt_tester)
                 {
                  int k=ObjectsDeleteAll(0,0,OBJ_HLINE);
                  HLine_Price.Create(0,"Entrada_SELL",0,sellprice);
                  HLine_Price.Color(clrAqua);
                  HLine_SL.Create(0,"Stop Loss_SELL",0,myposition.StopLoss());
                  HLine_SL.Color(clrRed);
                  HLine_TP.Create(0,"Take Profit_SELL",0,myposition.TakeProfit());
                  HLine_TP.Color(clrLime);
                 }
              }

            if((mydeal.DealType()==DEAL_TYPE_BUY || mydeal.DealType()==DEAL_TYPE_SELL) && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))

              {
               if(mydeal.Profit()<0)
                 {
                  Print("Saída por STOP LOSS");
/* if(mydeal.PositionId()==(long)gv.Get("pos_virmao1_buy"))
                    {
                     int cont=0;
                     buyprice=0;
                     while(buyprice==0 && cont<TENTATIVAS)
                       {
                        buyprice=mydeal.Price();
                        cont+=1;
                       }
                     if(buyprice==0)buyprice=mysymbol.Bid();

                     sl_position=NormalizeDouble(buyprice-_StopTercEt*ponto,digits);
                     tp_position=NormalizeDouble(buyprice+_TakeProfitTercEt*ponto,digits);

                     if(mytrade.Buy(Lot_entry_TercEt,original_symbol,0,sl_position,tp_position,start_hour+"_"+"3aEtapa-BUY"))
                        Print("Ordem de Compra 3a Etapa enviada");
                     else Print("Erro enviar Ordem de Compra 3a Etapa: ",GetLastError());

                 }

               if(mydeal.PositionId()==(long)gv.Get("pos_virmao1_sell"))
                 {
                  int cont=0;
                  sellprice=0;
                  while(sellprice==0 && cont<TENTATIVAS)
                    {
                     sellprice=mydeal.Price();
                     cont+=1;
                    }
                  if(sellprice==0)sellprice=mysymbol.Ask();

                  sl_position=NormalizeDouble(sellprice+_StopTercEt*ponto,digits);
                  tp_position=NormalizeDouble(sellprice-_TakeProfitTercEt*ponto,digits);

                  if(mytrade.Sell(Lot_entry_TercEt,original_symbol,0,sl_position,tp_position,start_hour+"_"+"3aEtapa-Sell"))
                     Print("Ordem de Compra 3a Etapa enviada");
                  else Print("Erro enviar Ordem de Compra 3a Etapa: ",GetLastError());
                  }
*/

                 }

               if(mydeal.Profit()>0)
                 {
                  Print("Saída no GAIN");
                 }
              }

            if(mydeal.Comment()==start_hour+"_"+"VirMaoSELL "+IntegerToString(5)+"M"+IntegerToString(Magic_Number))
              {

               gv.Set("pos_virmao1_sell",(double)mydeal.PositionId());
              }

            if(mydeal.Comment()==start_hour+"_"+"VirMaoBUY "+IntegerToString(5)+"M"+IntegerToString(Magic_Number))
              {
               gv.Set("pos_virmao1_buy",(double)mydeal.PositionId());
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void HedgeRobot::Entr_Parcial_Buy(const double preco)
  {
   double preco_ent,stop_ent,take_ent;
   for(int i=0;i<5;i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(Reent_Ord[i].Lote>0)
        {
         preco_ent=NormalizeDouble(preco+Reent_Ord[i].Ponto*ponto,digits);
         stop_ent=NormalizeDouble(preco_ent-Reent_Ord[i].SL*ponto,digits);
         take_ent=NormalizeDouble(preco_ent+Reent_Ord[i].TP*ponto,digits);
         mytrade.BuyStop(Reent_Ord[i].Lote,preco_ent,original_symbol,stop_ent,take_ent,order_time_type,0,start_hour+"_"+"VirMaoBUY "+IntegerToString(i+1)+"M"+IntegerToString(Magic_Number));
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void HedgeRobot::Entr_Parcial_Sell(const double preco)
  {
   double preco_ent,stop_ent,take_ent;
   for(int i=0;i<5;i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(Reent_Ord[i].Lote>0)
        {
         preco_ent=NormalizeDouble(preco-Reent_Ord[i].Ponto*ponto,digits);
         stop_ent=NormalizeDouble(preco_ent+Reent_Ord[i].SL*ponto,digits);
         take_ent=NormalizeDouble(preco_ent-Reent_Ord[i].TP*ponto,digits);
         mytrade.SellStop(Reent_Ord[i].Lote,preco_ent,original_symbol,stop_ent,take_ent,order_time_type,0,start_hour+"_"+"VirMaoSELL "+IntegerToString(i+1)+"M"+IntegerToString(Magic_Number));
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double HedgeRobot::LucroOrdensGrupo()
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
   int total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(StringFind(mydeal.Comment(),start_hour+"_")>=0)
            if(mydeal.Symbol()==mysymbol.Name() && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
               profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double HedgeRobot::LucroPositionsGrupo()
  {
   double profit=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && StringFind(myposition.Comment(),start_hour+"_")>=0
         )
         profit+=myposition.Profit();
   return profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double HedgeRobot::LucroGrupo()
  {
   return LucroOrdensGrupo()+LucroPositionsGrupo();
  }
//+------------------------------------------------------------------+

void HedgeRobot::CloseALLGrupo()
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && StringFind(myposition.Comment(),start_hour+"_")>=0)
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
void HedgeRobot::DeleteALLGrupo()
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
         if(myorder.Symbol()==mysymbol.Name() && StringFind(myorder.Comment(),start_hour+"_")>=0) mytrade.OrderDelete(o_ticket);
        }
     }
  }
//+------------------------------------------------------------------+
void HedgeRobot::OnTradeTransaction(const MqlTradeTransaction &trans,
                                    const MqlTradeRequest &request,
                                    const MqlTradeResult &result)
  {
   double buyprice,sellprice;
   int TENTATIVAS=10;
   int cont;

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
         deal_time=HistoryDealGetInteger(trans.deal,DEAL_TIME);
         deal_time_msc=HistoryDealGetInteger(trans.deal,DEAL_TIME_MSC);
         deal_type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_entry = HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
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

         if(deal_magic==Magic_Number)
           {
            GlobalVariableSet("last_deal_time",deal_time);

            if((deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL) && (deal_entry==DEAL_ENTRY_OUT))
              {
               if(deal_profit<0)
                 {
                  Print("Saída por STOP LOSS");
                 }

               if(deal_profit>0)
                 {
                  Print("Saída no GAIN");
                 }
              }

            if(deal_comment==start_hour+"_"+"BUY"+exp_name || deal_comment==start_hour+"_"+"SELL"+exp_name)
               gv.Set("glob_entr_tot",gv.Get("glob_entr_tot")+1);

            if(deal_comment==start_hour+"_"+"BUY"+exp_name)

              {
               myposition.SelectByTicket(deal_order);
               cont=0;
               buyprice=0;
               while(buyprice==0 && cont<TENTATIVAS)
                 {
                  buyprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(buyprice==0)
                  buyprice = mysymbol.Ask();
               sl_position = NormalizeDouble(buyprice - _Stop * ponto, digits);
               tp_position = NormalizeDouble(buyprice + _TakeProfit * ponto, digits);
               mytrade.PositionModify(deal_order,sl_position,tp_position);

               Entr_Parcial_Sell(buyprice);

               if(!opt_tester)
                 {
                  int k=ObjectsDeleteAll(0,0,OBJ_HLINE);
                  HLine_Price.Create(0, "Entrada_SELL"+IntegerToString(Magic_Number), 0, buyprice);
                  HLine_Price.Color(clrAqua);
                  HLine_SL.Create(0, "Stop Loss_SELL"+IntegerToString(Magic_Number), 0, myposition.StopLoss());
                  HLine_SL.Color(clrRed);
                  HLine_TP.Create(0, "Take Profit_SELL"+IntegerToString(Magic_Number), 0, myposition.TakeProfit());
                  HLine_TP.Color(clrLime);
                 }
              }
            //--------------------------------------------------

            if(deal_comment==start_hour+"_"+"SELL"+exp_name)
              {
               myposition.SelectByTicket(deal_order);
               cont=0;
               sellprice=0;
               while(sellprice==0 && cont<TENTATIVAS)
                 {
                  sellprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(sellprice== 0)
                  sellprice= mysymbol.Bid();
               sl_position = NormalizeDouble(sellprice + _Stop * ponto, digits);
               tp_position = NormalizeDouble(sellprice - _TakeProfit * ponto, digits);
               mytrade.PositionModify(deal_order,sl_position,tp_position);

               Entr_Parcial_Buy(sellprice);
               if(!opt_tester)
                 {
                  int k=ObjectsDeleteAll(0,0,OBJ_HLINE);
                  HLine_Price.Create(0, "Entrada_BUY"+IntegerToString(Magic_Number), 0, sellprice);
                  HLine_Price.Color(clrAqua);
                  HLine_SL.Create(0, "Stop Loss_BUY"+IntegerToString(Magic_Number), 0, myposition.StopLoss());
                  HLine_SL.Color(clrRed);
                  HLine_TP.Create(0, "Take Profit_BUY"+IntegerToString(Magic_Number), 0, myposition.TakeProfit());
                  HLine_TP.Color(clrLime);
                 }
              }
           }

         lucro_orders=LucroOrdens();
         if(!opt_tester)
           {
            lucro_orders_mes = LucroOrdensMes();
            lucro_orders_sem = LucroOrdensSemana();
           }
        }
      else
         return;
     }
  }
//+------------------------------------------------------------------+
