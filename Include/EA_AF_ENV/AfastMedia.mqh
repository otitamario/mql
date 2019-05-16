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
#include <EA_AF_ENV\Params.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AfastMedia : public MyExpert
  {
private:
   CiEnvelopes      *env1;
   CiEnvelopes      *env2;
   CiEnvelopes      *env3;
   CiVolumes        *Volumes;
   int               media_handle;
   double            Media_Buff[];
   string            informacoes;
   bool              tradebarra;
   double            sl_position,tp_position;
   double            vol_pos,vol_stp;
   double            preco_stp;
   double            preco_medio;
   double            PointBreakEven[5];
   double            PointProfit[5];
   datetime          hora_inicial1,hora_final1,hora_inicial2,hora_final2,hora_inicial3,hora_final3;
   bool              timer1,timer2,timer3,timerPaus;
   bool              opt_tester;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   bool              time_new_ent;
   bool              buy_signal,sell_signal;
   double            buy_price,sell_price,price_last_order;
   bool              trade_allowBuy1,trade_allowBuy2,trade_allowBuy3;
   bool              trade_allowSell1,trade_allowSell2,trade_allowSell3;

public:
                     AfastMedia();
                    ~AfastMedia();
   int               OnInit();
   void              OnDeinit(const int reason);
   void              OnTick();
   void              OnTimer();
   string GetCurrency(){return SymbolInfoString(original_symbol,SYMBOL_CURRENCY_BASE);}
   virtual bool      GetIndValue();
   virtual bool      BuySignal();
   virtual bool      SellSignal();
   bool              BuySignal1();
   bool              BuySignal2();
   bool              BuySignal3();
   bool              SellSignal1();
   bool              SellSignal2();
   bool              SellSignal3();

   void              SegurancaPos(ulong nsec);
   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);
   int EntradasDia(){return((int)gv.Get("glob_entr_tot"));};
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
void AfastMedia::OnTimer()
  {
   time_new_ent=true;
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int AfastMedia::OnInit()
  {
   time_new_ent=true;
   trade_allowBuy1=true;
   trade_allowBuy2=true;
   trade_allowBuy3=true;
   trade_allowSell1=true;
   trade_allowSell2=true;
   trade_allowSell3=true;

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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(start_hour>23 || end_hour>23)
     {
      string erro="Hora Inicial ou Final Inválida";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(start_min>59 || end_min>59)
     {
      string erro="Minuto Inicial ou Final Inválido";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+IntegerToString(start_hour)+":"+IntegerToString(start_min));
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+IntegerToString(end_hour)+":"+IntegerToString(end_min));

   ulong curChartID=ChartID();

   media_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\Custom Moving Average Input Color.ex5",period_media,0,MODE_EMA,clrAqua);
   ChartIndicatorAdd(curChartID,0,media_handle);

   env1=new CiEnvelopes;
   env1.Create(Symbol(),periodoRobo,period_media,0,MODE_EMA,PRICE_CLOSE,NormalizeDouble((dist1+10)*0.001,3));
   env1.AddToChart(curChartID,0);

   env2=new CiEnvelopes;
   env2.Create(Symbol(),periodoRobo,period_media,0,MODE_EMA,PRICE_CLOSE,NormalizeDouble((dist2+10)*0.001,3));
   env2.AddToChart(curChartID,0);

   env3=new CiEnvelopes;
   env3.Create(Symbol(),periodoRobo,period_media,0,MODE_EMA,PRICE_CLOSE,NormalizeDouble((dist3+10)*0.001,3));
   env3.AddToChart(curChartID,0);

   Volumes=new CiVolumes;
   Volumes.Create(Symbol(),periodoRobo,tipo_vol);
   Volumes.AddToChart(curChartID,(int)ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL));

   ArraySetAsSeries(Media_Buff,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(ChartID(),CHART_SHOW_TRADE_LEVELS,false);
//ChartSetInteger(ChartID(),CHART_DRAG_TRADE_LEVELS,true);
//ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

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
   IndicatorRelease(media_handle);
   delete (env1);
   delete (env2);
   delete (env3);
   delete(Volumes);
   DeletaIndicadores();
   EventKillTimer();

//---
  }
//+-------------ROTINAS----------------------------------------------+

void AfastMedia::OnTick()
  {

   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today",(double)TimeNow.day_of_year);

   bool novodia;
   novodia=Bar_NovoDia.CheckNewBar(original_symbol,PERIOD_D1);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      gv.Set("glob_entr_tot",0.0);
      gv.Set("deals_total_prev",0.0);
      gv.Set("last_stop",0.0);
      tradeOn=true;
      time_new_ent=true;
      trade_allowBuy1=true;
      trade_allowBuy2=true;
      trade_allowBuy3=true;
      trade_allowSell1=true;
      trade_allowSell2=true;
      trade_allowSell3=true;

      hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+IntegerToString(start_hour)+":"+IntegerToString(start_min));
      hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+IntegerToString(end_hour)+":"+IntegerToString(end_min));

      lucro_orders=LucroOrdens();
      if(!opt_tester)
        {
         lucro_orders_mes=LucroOrdensMes();
         lucro_orders_sem=LucroOrdensSemana();
        }

     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   env1.Refresh();
   env2.Refresh();
   env3.Refresh();
   Volumes.Refresh();
   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }
   if(bid>=ask) return;//Leilão
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

   if(PosicaoAberta())lucro_positions=LucroPositions();
   else lucro_positions=0;
   lucro_total=lucro_orders+lucro_positions;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!opt_tester)
     {
      lucro_total_semana=lucro_orders_sem+lucro_positions;
      lucro_total_mes=lucro_orders_mes+lucro_positions;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(lucro_total>=lucro || lucro_total<=-prejuizo)
     {
      CloseALL();
      if(OrdersTotal()>0)
         DeleteALL();
      tradeOn=false;
      informacoes="EA encerrado lucro ou prejuizo";
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened()) CloseByPosition();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!PosicaoAberta())
     {
      if(OrdersTotal()>0)DeleteALL();
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      if(myposition.SelectByTicket((ulong)gv.Get("cp_tick")))
        {
         if(myposition.StopLoss()>0)gv.Set("sl_position",myposition.StopLoss());
        }
      if(myposition.SelectByTicket((ulong)gv.Get("vd_tick")))
        {
         if(myposition.StopLoss()>0)gv.Set("sl_position",myposition.StopLoss());
        }
      Atual_vol_Stop_Take();
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(tradeOn && timerOn)

     { // inicio Trade On
      SegurancaPos(n_seconds);

      if(!trade_allowBuy1)
        {
         if(close[0]-env1.Lower(0)>=retenv1*ponto)trade_allowBuy1=true;
        }

      if(!trade_allowBuy2)
        {
         if(close[0]-env2.Lower(0)>=retenv2*ponto)trade_allowBuy2=true;
        }
      if(!trade_allowBuy3)
        {
         if(close[0]-env3.Lower(0)>=retenv3*ponto)trade_allowBuy3=true;
        }

      if(!trade_allowSell1)
        {
         if(env1.Upper(0)-close[0]>=retenv1*ponto)trade_allowSell1=true;
        }

      if(!trade_allowSell2)
        {
         if(env2.Upper(0)-close[0]>=retenv2*ponto)trade_allowSell2=true;
        }
      if(!trade_allowSell3)
        {
         if(env3.Upper(0)-close[0]>=retenv3*ponto)trade_allowSell3=true;
        }

      buy_signal=BuySignal() && !Buy_opened();
      sell_signal=SellSignal() && !Sell_opened();
      if(buy_signal)
        {
         DeleteALL();
         ClosePosType(POSITION_TYPE_SELL);
         if(BuySignal1())
           {
            sl_position=NormalizeDouble(mysymbol.Bid()-_Stop1*ponto,digits);
            tp_position=NormalizeDouble(mysymbol.Ask()+_TakeProfit1*ponto,digits);
            if(mytrade.Buy(Lot1,original_symbol,0,sl_position,tp_position,"BUY"+exp_name))
              {
               if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                 {
                  trade_allowBuy1=false;
                  Print("Ordem Enviada ou Executada com Sucesso");
                 }
               else
                  Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());
              }
            else
               Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());
           }
         if(BuySignal2())
           {
            sl_position=NormalizeDouble(mysymbol.Bid()-_Stop2*ponto,digits);
            tp_position=NormalizeDouble(mysymbol.Ask()+_TakeProfit2*ponto,digits);
            if(mytrade.Buy(Lot2,original_symbol,0,sl_position,tp_position,"BUY"+exp_name))
              {
               if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                 {
                  trade_allowBuy2=false;
                  Print("Ordem Enviada ou Executada com Sucesso");
                 }
               else
                  Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());
              }
            else
               Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());

           }

         if(BuySignal3())
           {
            sl_position=NormalizeDouble(mysymbol.Bid()-_Stop3*ponto,digits);
            tp_position=NormalizeDouble(mysymbol.Ask()+_TakeProfit3*ponto,digits);
            if(mytrade.Buy(Lot3,original_symbol,0,sl_position,tp_position,"BUY"+exp_name))
              {
               if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                 {
                  trade_allowBuy3=false;
                  Print("Ordem Enviada ou Executada com Sucesso");
                 }
               else
                  Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());
              }
            else
               Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());

           }
        }

      if(sell_signal)
        {
         DeleteALL();
         ClosePosType(POSITION_TYPE_BUY);
         if(SellSignal1())
           {
            sl_position=NormalizeDouble(mysymbol.Ask()+_Stop1*ponto,digits);
            tp_position=NormalizeDouble(mysymbol.Bid()-_TakeProfit1*ponto,digits);
            if(mytrade.Sell(Lot1,original_symbol,0,sl_position,tp_position,"SELL"+exp_name))
              {
               if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                 {
                  trade_allowSell1=false;
                  Print("Ordem Enviada ou Executada com Sucesso");
                 }
               else
                  Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());
              }
            else
               Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());

           }
         if(SellSignal2())
           {
            sl_position=NormalizeDouble(mysymbol.Ask()+_Stop2*ponto,digits);
            tp_position=NormalizeDouble(mysymbol.Bid()-_TakeProfit2*ponto,digits);
            if(mytrade.Sell(Lot2,original_symbol,0,sl_position,tp_position,"SELL"+exp_name))
              {
               if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                 {
                  trade_allowSell2=false;
                  Print("Ordem Enviada ou Executada com Sucesso");
                 }
               else
                  Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());
              }
            else
               Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());

           }

         if(SellSignal3())
           {
            sl_position=NormalizeDouble(mysymbol.Ask()+_Stop3*ponto,digits);
            tp_position=NormalizeDouble(mysymbol.Bid()-_TakeProfit3*ponto,digits);
            if(mytrade.Sell(Lot3,original_symbol,0,sl_position,tp_position,"SELL"+exp_name))
              {
               if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                 {
                  trade_allowSell3=false;
                  Print("Ordem Enviada ou Executada com Sucesso");
                 }
               else
                  Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());
              }
            else
               Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());

           }

        }

     } //End Trade On

  } //End OnTick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AfastMedia::BuySignal()
  {
   return (BuySignal1()||BuySignal2()||BuySignal3());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AfastMedia::BuySignal1()
  {
   bool signal=false;
   if(UsarEnt1==_SIM)signal=Media_Buff[0]-ask>=dist1*ponto&&Volumes.Main(0)>=volmin1&&Volumes.Main(0)<=volmax1;
   signal=signal && trade_allowBuy1;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AfastMedia::BuySignal2()
  {
   bool signal=false;
   if(UsarEnt2==_SIM)signal=Media_Buff[0]-ask>=dist2*ponto&&Volumes.Main(0)>=volmin2&&Volumes.Main(0)<=volmax2;
   signal=signal && trade_allowBuy2;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AfastMedia::BuySignal3()
  {
   bool signal=false;
   if(UsarEnt3==_SIM)signal=Media_Buff[0]-ask>=dist3*ponto&&Volumes.Main(0)>=volmin3&&Volumes.Main(0)<=volmax3;
   signal=signal && trade_allowBuy3;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool AfastMedia::SellSignal()
  {
   return (SellSignal1()||SellSignal2()||SellSignal3());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AfastMedia::SellSignal1()
  {
   bool signal=false;
   if(UsarEnt1==_SIM)signal=bid-Media_Buff[0]>=dist1*ponto&&Volumes.Main(0)>=volmin1&&Volumes.Main(0)<=volmax1;
   signal=signal && trade_allowSell1;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AfastMedia::SellSignal2()
  {
   bool signal=false;
   if(UsarEnt2==_SIM)signal=bid-Media_Buff[0]>=dist2*ponto&&Volumes.Main(0)>=volmin2&&Volumes.Main(0)<=volmax2;
   signal=signal && trade_allowSell2;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AfastMedia::SellSignal3()
  {
   bool signal=false;
   if(UsarEnt3==_SIM)signal=bid-Media_Buff[0]>=dist3*ponto&&Volumes.Main(0)>=volmin3&&Volumes.Main(0)<=volmax3;
   signal=signal && trade_allowSell3;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AfastMedia::SegurancaPos(ulong nsec)
  {
   if(PosicaoAberta())
     {
      for(int i=PositionsTotal()-1; i>=0; i--)
        {
         if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
           {
            if(myposition.StopLoss()==0 && (ulong)(TimeCurrent()-((datetime)gv.Get("last_deal_time")))>=nsec)
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
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool AfastMedia::GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(media_handle,0,0,5,Media_Buff)<=0 || 
         CopyHigh(Symbol(),periodoRobo,0,5,high)<=0 || 
         CopyOpen(Symbol(),periodoRobo,0, 5, open) <= 0 ||
         CopyLow(Symbol(), periodoRobo, 0, 5, low) <= 0 ||
         CopyClose(Symbol(),periodoRobo,0,5,close) <= 0;
   return (b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+

void AfastMedia::OnTradeTransaction(const MqlTradeTransaction &trans,
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

               if(deal_profit<0)
                 {
                  Print("Saída por STOP LOSS");
                  DeleteALL();
                 }
               if(deal_profit>0)
                 {
                  Print("Saída no GAIN");
                  DeleteALL();
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
      myhistory.Ticket(trans.order);
      if(myhistory.Magic()!=(long)Magic_Number)return;
      if((myhistory.Comment()=="BUY"+exp_name || myhistory.Comment()=="SELL"+exp_name) && trans.order_state==ORDER_STATE_FILLED)
        {
         gv.Set("glob_entr_tot",gv.Get("glob_entr_tot")+1);
        }

      if(myhistory.Comment()=="BUY"+exp_name && trans.order_state==ORDER_STATE_FILLED)
        {
         myposition.SelectByTicket(trans.order);
         int cont = 0;
         buyprice = 0;
         while(buyprice==0 && cont<TENTATIVAS)
           {
            buyprice=myposition.PriceOpen();
            cont+=1;
           }
         if(buyprice==0)
            buyprice= mysymbol.Ask();

        }
      //--------------------------------------------------

      if(myhistory.Comment()=="SELL"+exp_name && trans.order_state==ORDER_STATE_FILLED)

        {
         myposition.SelectByTicket(trans.order);
         int cont=0;
         sellprice=0;
         while(sellprice==0 && cont<TENTATIVAS)
           {
            sellprice=myposition.PriceOpen();
            cont+=1;
           }
         if(sellprice== 0)
            sellprice= mysymbol.Bid();

        }

      if(myhistory.Comment()=="TAKE PROFIT" && trans.order_state==ORDER_STATE_FILLED)//&& trans.order_state==ORDER_STATE_FILLED)
        {

         Print("Saída no GAIN");

        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
