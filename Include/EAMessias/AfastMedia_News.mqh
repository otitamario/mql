//+------------------------------------------------------------------+
//|                                                   AfastMedia.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <EAMessias\Params_News.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AfastMedia : public MyExpert
  {
private:
   CiMA             *media;
   CiMA             *media_sec;
   CChartObjectVLine VLine[];
   CChartObjectVLine VLine_Antes[];
   CChartObjectVLine VLine_Depois[];

   int               media_mat_handle;
   string            informacoes;
   bool              tradebarra;
   double            sl_position,tp_position;
   double            vol_pos,vol_stp;
   double            preco_stp;
   bool              gapOn;
   double            preco_medio;
   double            PointBreakEven[5];
   double            PointProfit[5];
   datetime          hora_inicial1,hora_final1,hora_inicial2,hora_final2,hora_inicial3,hora_final3;
   bool              timer1,timer2,timer3,timerPaus;
   string            pais;
   bool              investing_filter,TemNoticia;
   datetime          Hora_in[],Hora_fin[];

public:
                     AfastMedia();
                    ~AfastMedia();
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
   bool              CheckSellClose();
   bool              CheckBuyClose();
   virtual void      Atual_vol_Stop_Take();
   int               PriceCrossDown();
   int               PriceCrossUp();
   bool              CrossUpToday();
   bool              CrossDownToday();
   bool              CrossToday();
   bool              TradeStop();
   void              Entr_Parcial_Buy(const double preco);
   void              Entr_Parcial_Sell(const double preco);
   void              Entr_Favor_Buy(const double preco);
   void              Entr_Favor_Sell(const double preco);
   bool              Gap();
   double            Pts_Gap();
   string            NewsInvesting(string _pais,int _touros);
   bool              HorasInvesting(string _pais,int _touros);
   bool              InvestingTime(bool isnews);
   void              Real_Parc_Sell(double vol,double preco);
   void              Real_Parc_Buy(double vol,double preco);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AfastMedia::AfastMedia()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
AfastMedia::~AfastMedia()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int AfastMedia::OnInit()
  {

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
   tradeOn=true;
   setExpName();
   setSymbol(Symbol());
   setOriginalSymbol(Symbol());
   setMagic(Magic_Number);
   if(SymbolInfoInteger(original_symbol,SYMBOL_EXPIRATION_MODE)==2)order_time_type=1;
   else order_time_type=0;
   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.SetDeviationInPoints(50);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
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

   media=new CiMA;
   media.Create(Symbol(), periodoRobo, period_media, 0, modo_media, app_media);
   media.AddToChart(curChartID, 0);

   media_sec=new CiMA;
   media_sec.Create(Symbol(), periodoRobo, period_med_sec, 0, mode_sec, app_sec);
   media_sec.AddToChart(curChartID, 0);

   media_mat_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\Indic_Afastamento_Media_MATS.ex5",period_media,modo_media,app_media);

   ChartIndicatorAdd(curChartID,ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),media_mat_handle);

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(ChartID(),CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_FAILED);
     }

   if(Lot<mysymbol.LotsMin())
     {
      string erro="Lote deve ser maior ou igual a "+DoubleToString(mysymbol.LotsMin(),2);
      MessageBox(erro);
      Print(erro);
      return(INIT_FAILED);
     }

   if(_lts_rp1*rp1+_lts_rp2*rp2+_lts_rp3*rp3>0 && _lts_rp1+_lts_rp2+_lts_rp3>=100)
     {
      string erro="A soma das porcentagems de realização parcial devem ser menor que 100";
      MessageBox(erro);
      Print(erro);
      return(INIT_FAILED);
     }

   if(_lts_rp1*rp1+_lts_rp2*rp2+_lts_rp3*rp3>0 && (rp1>=_TakeProfit || rp2>=_TakeProfit || rp3>=_TakeProfit))
     {
      string erro="Os pontos de realização parcial devem ser menores que o Take Profit";
      MessageBox(erro);
      Print(erro);
      return(INIT_FAILED);
     }

   PointBreakEven[0]=BreakEvenPoint1; PointBreakEven[1]=BreakEvenPoint2; PointBreakEven[2]=BreakEvenPoint3;
   PointBreakEven[3]=BreakEvenPoint4; PointBreakEven[4]=BreakEvenPoint5;
   PointProfit[0]=ProfitPoint1; PointProfit[1]=ProfitPoint2; PointProfit[2]=ProfitPoint3;
   PointProfit[3]=ProfitPoint4; PointProfit[4]=ProfitPoint5;


// parametros incorretos desnecessarios na otimizacao

   for(int i=0;i<5;i++)
     {
      if(PointBreakEven[i]<PointProfit[i])
        {
         string erro="Profit do Break Even deve ser menor que o Ponto de Break Even";
         MessageBox(erro);
         Print(erro);
         return false;
        }

     }

   for(int i=0;i<4;i++)
     {
      if(PointBreakEven[i+1]<=PointBreakEven[i])
        {
         string erro="Pontos de Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return false;

        }
     }

   for(int i=0;i<4;i++)
     {
      if(PointProfit[i+1]<=PointProfit[i])
        {
         string erro="Pontos de Profit do Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return false;
        }

     }

   if(HistorySelect(iTime(original_symbol,PERIOD_D1,0),TimeCurrent()+PeriodSeconds(PERIOD_D1)))
     {
      int total_deals=HistoryDealsTotal();
      int ticket_history_deal=0;
      int cont_deals=0;
      for(uint i=0;i<total_deals;i++)
        {
         //--- try to get deals ticket_history_deal
         if((ticket_history_deal=HistoryDealGetTicket(i))>0)
           {
            int deal_magic=HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
            if(deal_magic==Magic_Number && HistoryDealGetString(ticket_history_deal,DEAL_SYMBOL)==mysymbol.Name())cont_deals+=1;
           }
        }
      gv.Set("deals_total_prev",(double)cont_deals);

     }
   bool stop_entr_cont=_Stop<=pts_entry1+dist_media || _Stop<=pts_entry2+dist_media || _Stop<=pts_entry3+dist_media;
   stop_entr_cont=stop_entr_cont||_Stop<=pts_entry4+dist_media || _Stop<=pts_entry5+dist_media || _Stop<=pts_entry6+dist_media;
   stop_entr_cont=stop_entr_cont||_Stop<=pts_entry7+dist_media || _Stop<=pts_entry8+dist_media || _Stop<=pts_entry9+dist_media|| _Stop<=pts_entry10+dist_media;

   if(stop_entr_cont)
     {
      string erro="O Stop Máximo deve ser maior que todos pontos de aumento entrada + a distância de entrada da média ";
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

   if(HistorySelect(iTime(original_symbol,PERIOD_D1,0),TimeCurrent()))
     {
      int total_deals=HistoryDealsTotal();
      int ticket_history_deal=0;
      int cont_deals=0;
      for(uint i=0;i<total_deals;i++)
        {
         //--- try to get deals ticket_history_deal
         if((ticket_history_deal=HistoryDealGetTicket(i))>0)
           {
            int deal_magic=HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
            if(deal_magic==Magic_Number && HistoryDealGetString(ticket_history_deal,DEAL_SYMBOL)==mysymbol.Name())cont_deals+=1;
           }
        }
      gv.Set("deals_total_prev",(double)cont_deals);

     }

   if(UsarNew && HorasInvesting(pais,3))
     {
      investing_filter=false;
      int j=ObjectsDeleteAll(ChartID(),0,OBJ_VLINE);
      ArrayResize(VLine,ArraySize(Hora_fin));
      ArrayResize(VLine_Antes,ArraySize(Hora_fin));
      ArrayResize(VLine_Depois,ArraySize(Hora_fin));
      for(int i=0;i<ArraySize(Hora_fin);i++)
        {
         if(Hora_in[i]>0 && Hora_fin[i]>0)
           {
            Print("inicio "+TimeToString(Hora_in[i])+" fim "+TimeToString(Hora_fin[i]));
            investing_filter=investing_filter || (TimeCurrent()>=Hora_in[i] && TimeCurrent()<=Hora_fin[i]);
            TemNoticia=true;
            VLine[i].Create(ChartID(),"News_"+IntegerToString(i),0,Hora_in[i]+minutos_news*60);
            VLine[i].Color(clrBlue);
            VLine_Antes[i].Create(ChartID(),"News_Inicio"+IntegerToString(i),0,Hora_in[i]);
            VLine_Antes[i].Color(clrRed);
            VLine_Depois[i].Create(ChartID(),"News_Fim"+IntegerToString(i),0,Hora_fin[i]);
            VLine_Depois[i].Color(clrRed);

           }
        }

     }
   else
     {
      Alert("Sem notícias filtradas");
      investing_filter=false;
      TemNoticia=false;
     }

   if(UsarNew)MessageBox(NewsInvesting(pais,3));

   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void AfastMedia::OnDeinit(const int reason)
  {
   IndicatorRelease(media_mat_handle);
   delete (media);
   delete (media_sec);
   DeletaIndicadores();
   EventKillTimer();
   int j=ObjectsDeleteAll(ChartID(),0,OBJ_VLINE);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AfastMedia::OnTimer()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+-------------ROTINAS----------------------------------------------+

void AfastMedia::OnTick()
  {

   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today",(double)TimeNow.day_of_year);

   bool novodia;
   novodia=isNewBar(iTime(original_symbol,PERIOD_D1,0));

   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      gv.Set("glob_entr_tot",0.0);
      gv.Set("deals_total_prev",0.0);
      gv.Set("last_stop",0.0);
      tradeOn=true;
      if(UsarNew && HorasInvesting(pais,3))
        {
         investing_filter=false;
         int j=ObjectsDeleteAll(ChartID(),0,OBJ_VLINE);
         ArrayResize(VLine,ArraySize(Hora_fin));
         ArrayResize(VLine_Antes,ArraySize(Hora_fin));
         ArrayResize(VLine_Depois,ArraySize(Hora_fin));

         for(int i=0;i<ArraySize(Hora_fin);i++)
           {
            if(Hora_in[i]>0 && Hora_fin[i]>0)
              {
               Print("inicio "+TimeToString(Hora_in[i])+" fim "+TimeToString(Hora_fin[i]));
               investing_filter=investing_filter || (TimeCurrent()>=Hora_in[i] && TimeCurrent()<=Hora_fin[i]);
               TemNoticia=true;
               VLine[i].Create(ChartID(),"News_"+IntegerToString(i),0,Hora_in[i]+minutos_news*60);
               VLine[i].Color(clrBlue);
               VLine_Antes[i].Create(ChartID(),"News_Inicio"+IntegerToString(i),0,Hora_in[i]);
               VLine_Antes[i].Color(clrRed);
               VLine_Depois[i].Create(ChartID(),"News_Fim"+IntegerToString(i),0,Hora_fin[i]);
               VLine_Depois[i].Color(clrRed);

              }
           }

        }
      else
        {
         Alert("Sem notícias filtradas");
         investing_filter=false;
         TemNoticia=false;
        }

     }

   gv.Set("gv_today_prev",gv.Get("gv_today"));

   MytradeTransaction();

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   media.Refresh();
   media_sec.Refresh();
   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   hora_inicial1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour1);
   hora_final1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour1);

   hora_inicial2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour2);
   hora_final2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour2);

   hora_inicial3=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour3);
   hora_final3=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour3);

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

   if(Gap())
     {
      gapOn=false;
      if(UsarGap==Operacoes_Normais)
         gapOn=true;
      if(UsarGap==Operar_Apos_Toque_Media && CrossToday())
         gapOn=true;
     }
   else
      gapOn=true;

   lucro_total=LucroOrdens()+LucroPositions();
   lucro_total_semana=LucroOrdensSemana()+LucroPositions();
   lucro_total_mes=LucroOrdensMes()+LucroPositions();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      CloseALL();
      if(OrdersTotal()>0)
         DeleteALL();
      tradeOn=false;
      informacoes="EA encerrado lucro ou prejuizo";
     }

   timerOn=true;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   investing_filter=false;
   if(UsarNew)investing_filter=InvestingTime(TemNoticia);

   if(UseTimer==true)
     {
      timer1=UsePause1 && TimeCurrent()>=hora_inicial1 && TimeCurrent()<=hora_final1;
      timer2=UsePause2&&TimeCurrent()>=hora_inicial2 && TimeCurrent()<=hora_final2;
      timer3=UsePause3&&TimeCurrent()>=hora_inicial3 && TimeCurrent()<=hora_final3;
      timerPaus=!timer1 && !timer2 && !timer3;
      timerOn=timerPaus && TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
      if(UsarNew && investing_filter)timerOn=false;

     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!timerOn && daytrade)
     {
      if(OrdersTotal()>0)
         DeleteALL();
      if(PositionsTotal()>0)
         CloseALL();
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened()) CloseByPosition();

   if(!PosicaoAberta() && OrdersTotal()>0)
      DeleteALL();
   if(!PosicaoAberta())
     {
      gv.Set("close_buy_sec",0.0);
      gv.Set("close_sell_sec",0.0);
     }
   if(tradeOn && timerOn)

     { // inicio Trade On

      if(PosicaoAberta())
        {
         if(myposition.SelectByTicket((ulong)gv.Get("cp_tick")))
           {
            if(myposition.StopLoss()>0)gv.Set("sl_position",myposition.StopLoss());
           }
         if(myposition.SelectByTicket((ulong)gv.Get("vd_tick")))
           {
            if(myposition.StopLoss()>0)gv.Set("sl_position",myposition.StopLoss());
           }
        }

      Atual_vol_Stop_Take();

      if(operacao==Contra)
        {
         if(CheckBuyClose() && Buy_opened())
           {
            DeleteALL();
            CloseByPosition();
            ClosePosType(POSITION_TYPE_BUY);
           }
         if(CheckSellClose() && Sell_opened())
           {
            DeleteALL();
            CloseByPosition();
            ClosePosType(POSITION_TYPE_SELL);
           }
        }

      if(gapOn)
        {

         if(isNewBar(iTime(Symbol(),periodoRobo,0)))
           {
            tradebarra=true;
            if(!cada_tick)
              {
               if(BuySignal() && !Buy_opened() && operar!=Venda && tradebarra && TradeStop())
                 {
                  DeleteALL();
                  if(Sell_opened())ClosePosType(POSITION_TYPE_SELL);
                  if(mytrade.Buy(Lot,original_symbol,0,NormalizeDouble(bid-_Stop*ponto,digits),0,"BUY"+exp_name))
                    {
                     gv.Set("cp_tick",(double)mytrade.ResultOrder());
                     tradebarra=false;
                    }
                  else
                     Print("Erro enviar ordem ",GetLastError());
                 }

               if(SellSignal() && !Sell_opened() && operar!=Compra && tradebarra && TradeStop())
                 {
                  DeleteALL();
                  if(Buy_opened()) ClosePosType(POSITION_TYPE_BUY);
                  if(mytrade.Sell(Lot,original_symbol,0,NormalizeDouble(ask+_Stop*ponto,digits),0,"SELL"+exp_name))
                    {
                     gv.Set("vd_tick",(double)mytrade.ResultOrder());
                     tradebarra=false;
                    }
                  else
                     Print("Erro enviar ordem ",GetLastError());
                 }
              }

           } //Fim Nova Barra

         if(cada_tick)
           {
            if(BuySignal() && !Buy_opened() && operar!=Venda && tradebarra && TradeStop())
              {
               if(Sell_opened())
                  ClosePosType(POSITION_TYPE_SELL);
               DeleteALL();
               if(mytrade.Buy(Lot,original_symbol,0,NormalizeDouble(bid-_Stop*ponto,digits),0,"BUY"+exp_name))
                 {
                  gv.Set("cp_tick",(double)mytrade.ResultOrder());
                  tradebarra=false;
                 }
               else
                  Print("Erro enviar ordem ",GetLastError());
              }

            if(SellSignal() && !Sell_opened() && operar!=Compra && tradebarra && TradeStop())
              {
               if(Buy_opened())
                  ClosePosType(POSITION_TYPE_BUY);
               DeleteALL();
               if(mytrade.Sell(Lot,original_symbol,0,NormalizeDouble(ask+_Stop*ponto,digits),0,"SELL"+exp_name))
                 {
                  gv.Set("vd_tick",(double)mytrade.ResultOrder());
                  tradebarra=false;
                 }
               else
                  Print("Erro enviar ordem ",GetLastError());
              }
           }

        } // Fim Time Entradas

      if(PosicaoAberta() && Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);
      if(PosicaoAberta() && UseBreakEven)BreakEven(original_symbol,UseBreakEven,PointBreakEven,PointProfit);

     } //End Trade On

  } //End OnTick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string AfastMedia::NewsInvesting(string _pais,int _touros)
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
//|                                                                  |
//+------------------------------------------------------------------+
bool AfastMedia::HorasInvesting(string _pais,int _touros)
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
bool AfastMedia::InvestingTime(bool isnews)
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AfastMedia::BuySignal()
  {
   bool b_signal;
   if(operacao== Favor)
      b_signal= bid-media.Main(0)>= dist_media * ponto;
   else
      b_signal=media.Main(0)-ask>=dist_media*ponto;

   return b_signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool AfastMedia::SellSignal()
  {
   bool s_signal;
   if(operacao== Favor)
      s_signal= media.Main(0)-ask>= dist_media * ponto;
   else
      s_signal=bid-media.Main(0)>=dist_media*ponto;
   return s_signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool AfastMedia::GetIndValue()
  {
   bool b_get;
   b_get=CopyHigh(Symbol(),periodoRobo,0,5,high)<=0 || 
         CopyOpen(Symbol(),periodoRobo,0, 5, open) <= 0 ||
         CopyLow(Symbol(), periodoRobo, 0, 5, low) <= 0 ||
         CopyClose(Symbol(),periodoRobo,0,5,close) <= 0;
   return (b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


void AfastMedia::MytradeTransaction()
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
         if((ticket_history_deal=HistoryDealGetTicket(i))>0)
           {
            deal_magic=HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
            if(deal_magic==Magic_Number && HistoryDealGetString(ticket_history_deal,DEAL_SYMBOL)==mysymbol.Name())
              {
               cont_deals+=1;
               deals_ticket=ticket_history_deal;
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
               int cont = 0;
               buyprice = 0;
               while(buyprice==0 && cont<TENTATIVAS)
                 {
                  buyprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(buyprice==0)
                  buyprice = mysymbol.Ask();
               sl_position = NormalizeDouble(buyprice - _Stop * ponto, digits);
               tp_position = NormalizeDouble(buyprice + _TakeProfit * ponto, digits);
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

              }
            //--------------------------------------------------

            if(mydeal.Comment()=="SELL"+exp_name)

              {
               myposition.SelectByTicket(order_ticket);
               int cont=0;
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

              }
            if(saida_sec>0)
              {
               if(mydeal.Comment()=="BUY_"+IntegerToString(saida_sec)+exp_name)
                 {
                  Print("Ativado Saída pela Média Secundária");
                  gv.Set("close_buy_sec",1.0);
                 }
               if(mydeal.Comment()=="SELL_"+IntegerToString(saida_sec)+exp_name)
                 {
                  Print("Ativado Saída pela Média Secundária");
                  gv.Set("close_sell_sec",1.0);
                 }
              }

            if((mydeal.DealType()==DEAL_TYPE_BUY || mydeal.DealType()==DEAL_TYPE_SELL) && mydeal.Entry()==DEAL_ENTRY_OUT)
              {
               if(mydeal.Profit()<0)
                 {
                  Print("Saída por STOP LOSS. Aguardar Toque na Média");
                  gv.Set("last_stop",1.0);
                  gv.Set("pos_stop",mydeal.Price()-media.Main(0));
                 }
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

           } // if dealsticket>0
        }   //Fim deals>prev
     }     //Fim HistorySelect

   gv.Set("deals_total_prev",gv.Get("deals_total"));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool AfastMedia::CheckSellClose()
  {
   bool dist=false;
   if(FecharMedia)dist=ask<=media.Main(0);
   bool sec=false;
   if(FecharMediaSec && gv.Get("close_sell_sec")==1.0 && saida_sec>0)
      sec=ask<=media_sec.Main(0);
   return (dist || sec);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AfastMedia::CheckBuyClose()
  {
   bool dist=false;
   if(FecharMedia)dist=bid>=media.Main(0);
   bool sec=false;
   if(FecharMediaSec && gv.Get("close_buy_sec")==1.0 && saida_sec>0)
      sec=bid>=media_sec.Main(0);
   return (dist || sec);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool AfastMedia::Gap()
  {
   return MathAbs(iClose(Symbol(), PERIOD_D1, 1) - iOpen(Symbol(), PERIOD_D1, 0)) >= pts_gap * ponto;
  }
//+------------------------------------------------------------------+
double AfastMedia::Pts_Gap()
  {
   return MathAbs(iClose(Symbol(), PERIOD_D1, 1) - iOpen(Symbol(), PERIOD_D1, 0));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int AfastMedia::PriceCrossDown()
  {
   bool signal;
   int i;
   signal=false;
   i=0;
   while(!signal && !IsStopped())
     {
      signal=iClose(Symbol(),periodoRobo,i+1)>media.Main(i+1) && iClose(Symbol(),periodoRobo,i)<media.Main(i);
      i=i+1;
     }
   return i - 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int AfastMedia::PriceCrossUp()
  {
   bool signal;
   int i;
   signal=false;
   i=0;
   while(!signal && !IsStopped())
     {
      signal=iClose(Symbol(),periodoRobo,i+1)<media.Main(i+1) && iClose(Symbol(),periodoRobo,i)>media.Main(i);
      i=i+1;
     }
   return i - 1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AfastMedia::CrossUpToday()
  {
   int lastcross=PriceCrossUp()+1;
   datetime timecross=iTime(Symbol(),periodoRobo,lastcross);
   MqlDateTime TimeCross;
   TimeToStruct(timecross,TimeCross);
   MqlDateTime TimeNow;
   TimeToStruct(TimeCurrent(),TimeNow);
   if(TimeCross.day==TimeNow.day)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
bool AfastMedia::CrossDownToday()
  {
   int lastcross=PriceCrossDown()+1;
   datetime timecross=iTime(Symbol(),periodoRobo,lastcross);
   MqlDateTime TimeCross;
   TimeToStruct(timecross,TimeCross);
   MqlDateTime TimeNow;
   TimeToStruct(TimeCurrent(),TimeNow);
   if(TimeCross.day==TimeNow.day)
      return true;
   return false;
  }
//+------------------------------------------------------------------+
bool AfastMedia::CrossToday()
  {
   return CrossDownToday() || CrossUpToday();
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void AfastMedia::Atual_vol_Stop_Take()
  {
   double vol_ent_contra,vol_ent_fav,vol_parc;
   vol_ent_contra=VolumeOrdensCmt("Saída Aumento");
   vol_ent_fav=VolumeOrdensCmt("Saída Favor");
   vol_parc=VolumeOrdensCmt("PARCIAL 1")+VolumeOrdensCmt("PARCIAL 2")+VolumeOrdensCmt("PARCIAL 3");

   if(PosicaoAberta())
     {
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
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AfastMedia::TradeStop()
  {
   if(gv.Get("last_stop")==1.0)
     {
      if(gv.Get("pos_stop") *(close[0]-media.Main(0))<=0)
        {
         gv.Set("last_stop",0.0);
         return true;
        }
      else
         return false;
     }
   else
      return true;
  }
//+------------------------------------------------------------------+

void AfastMedia::Entr_Parcial_Buy(const double preco)
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
void AfastMedia::Entr_Parcial_Sell(const double preco)
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
void AfastMedia::Entr_Favor_Buy(const double preco)
  {

   if(Lot_entry1_fv>0) mytrade.BuyStop(Lot_entry1_fv,NormalizeDouble(preco+pts_entry1_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 1");
   if(Lot_entry2_fv>0) mytrade.BuyStop(Lot_entry2_fv,NormalizeDouble(preco+pts_entry2_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 2");
   if(Lot_entry3_fv>0) mytrade.BuyStop(Lot_entry3_fv,NormalizeDouble(preco+pts_entry3_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 3");
   if(Lot_entry4_fv>0) mytrade.BuyStop(Lot_entry4_fv,NormalizeDouble(preco+pts_entry4_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 4");
  }
//+------------------------------------------------------------------+
void AfastMedia::Entr_Favor_Sell(const double preco)
  {
   if(Lot_entry1_fv>0) mytrade.SellStop(Lot_entry1_fv,NormalizeDouble(preco-pts_entry1_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 1");
   if(Lot_entry2_fv>0) mytrade.SellStop(Lot_entry2_fv,NormalizeDouble(preco-pts_entry2_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 2");
   if(Lot_entry3_fv>0) mytrade.SellStop(Lot_entry3_fv,NormalizeDouble(preco-pts_entry3_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 3");
   if(Lot_entry4_fv>0) mytrade.SellStop(Lot_entry4_fv,NormalizeDouble(preco-pts_entry4_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 4");
  }
//+------------------------------------------------------------------+
bool AfastMedia::TimeDayFilter()
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

     }
   return filter;
  }
//+------------------------------------------------------------------+

void AfastMedia::Real_Parc_Buy(double vol,double preco)
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
void AfastMedia::Real_Parc_Sell(double vol,double preco)
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
