//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#define VERSION "1.0"// Mudar aqui as Versões

//#property copyright "Igor"
#property version   VERSION

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <Controls\Defines.mqh>
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
//#undef CONTROLS_LABEL_COLOR  

color borda_bg=clrNONE;//Cor Borda
color painel_bg=clrNONE;//Cor Painel 
color cor_txt_borda_bg=clrYellowGreen;//Cor Texto Borda
                                      //color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG          borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg

#include <EA_Igor\Expert_Class_Igor.mqh>
#include <EA_Igor\ParamsIgorRSI.mqh>



CLabel            m_label[50];
CPanel painel;
CEdit edit_painel;
#define LARGURA_PAINEL 210 // Largura Painel
#define ALTURA_PAINEL 130 // Altura Painel




//Fim Parametros

//+------------------------------------------------------------------+
//|                                                   MyRobot.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <ChartObjects\ChartObjectsLines.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

struct DescPositions
  {
   ulong             pos_ticket;
   int               line_number;

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyPositions: public CObject
  {
public:
   ulong             pos_ticket;
   int               line_number;
   void SetNumber(int n){line_number=n;}
   void SetTicket(ulong t){pos_ticket=t;}
   int GetNumber(){return line_number;}
   ulong GetTicket(){return pos_ticket;}
   void              MyPositions(void);
   void             ~MyPositions(void);
  };
//+------------------------------------------------------------------+ 
//| Constructor                                                      | 
//+------------------------------------------------------------------+ 
MyPositions::MyPositions(void)
  {
  }
//+------------------------------------------------------------------+ 
//| Destructor                                                       | 
//+------------------------------------------------------------------+ 
MyPositions::~MyPositions(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyRobot : public MyExpert
  {
private:
   CChartObjectVLine VLine[];
   CiRSI            *rsi;
   CiADX            *adx;
   bool              pos_aberta;
   ulong             ticket_pos;
   int               positions_total;
   int               hilo_handle;
   double            HiLoBuffer[],HiLoColor[];
   string            informacoes;
   double            sl_position,tp_position;
   double            vol_pos,vol_stp;
   double            preco_stp;
   double            preco_medio;
   bool              opt_tester;
   double            barra_sinal;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   bool              buysignal,sellsignal;
   double            Buyprice,Sellprice;
   double            PointBreakEven[5];
   double            PointProfit[5];
   bool              TimeEnt;
   datetime          hora_ent;

public:
                     MyRobot();
                    ~MyRobot();
   int               OnInit();
   void              OnDeinit(const int reason);
   void              OnTick();
   void              OnTimer();
   string GetCurrency(){return SymbolInfoString(original_symbol,SYMBOL_CURRENCY_BASE);}
   bool              TimeDayFilter();
   virtual bool      GetIndValue();
   virtual bool      BuySignal();
   virtual bool      SellSignal();
   bool              FiltroBuy();
   bool              FiltroSell();

   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);
   void              Entr_Parcial_Buy(const double preco);
   void              Entr_Parcial_Sell(const double preco);
   void              Real_Parc_Buy(double vol,double preco);
   void              Real_Parc_Sell(double vol,double preco);
   void              Atual_vol_Stop_Take();
   void              Painel(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   bool              GapBuy(double p_gaps);
   bool              GapSell(double p_gaps);
  };

MyRobot MyEA;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MyRobot::MyRobot()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MyRobot::~MyRobot()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTimer()
  {
   Painel(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL);
   if(pos_aberta)
     {
      if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep,opt_dist,barra_sinal);
      if(UseBreakEven)BreakEven(original_symbol,UseBreakEven,PointBreakEven,PointProfit,opt_dist,barra_sinal);
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
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int MyRobot::OnInit()
  {
   TimeEnt=false;
   pos_aberta=false;
   EventSetTimer(1);
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
//mytrade.SetTypeFillingBySymbol(original_symbol);
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
   hora_ent=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_ent);

   ulong curChartID=ChartID();

   hilo_handle=iCustom(_Symbol,periodoRobo,"::Indicators\\gann_hi_lo_activator_ssl.ex5",InpPeriod,InpMethod);
   ChartIndicatorAdd(curChartID,0,hilo_handle);

   adx=new CiADX;
   adx.Create(_Symbol,periodoRobo,per_adx);
   adx.AddToChart(curChartID,(int)ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL));

   rsi=new CiRSI;
   rsi.Create(_Symbol,periodoRobo,per_rsi,price_rsi);
   rsi.AddToChart(curChartID,(int)ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL));

   ArraySetAsSeries(HiLoBuffer,true);
   ArraySetAsSeries(HiLoColor,true);

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
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(Lot<mysymbol.LotsMin())
     {
      string erro="Lote deve ser maior ou igual a "+DoubleToString(mysymbol.LotsMin(),2);
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(_lts_rp1*rp1+_lts_rp2*rp2+_lts_rp3*rp3>0 && _lts_rp1+_lts_rp2+_lts_rp3>100)
     {
      string erro="A soma das porcentagems de realização parcial devem ser menor ou igual que 100 %";
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
         if(PointBreakEven[i]>0 && PointBreakEven[i]<PointProfit[i])
           {
            string erro="Profit do Break Even deve ser menor que o Ponto de Break Even";
            MessageBox(erro);
            Print(erro);
            return (INIT_PARAMETERS_INCORRECT);
           }

        }

      for(int i=0;i<4;i++)
        {
         if(PointBreakEven[i+1]>0 && PointBreakEven[i]>0 && PointBreakEven[i+1]<=PointBreakEven[i])
           {
            string erro="Pontos de Break Even devem estar em ordem crescente";
            MessageBox(erro);
            Print(erro);
            return (INIT_PARAMETERS_INCORRECT);

           }
        }

      for(int i=0;i<4;i++)
        {
         if(PointProfit[i+1]>0 && PointProfit[i]>0 && PointProfit[i+1]<=PointProfit[i])
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

   Painel(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL);

   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   IndicatorRelease(hilo_handle);
   delete(rsi);
   delete(adx);
   DeletaIndicadores();
   EventKillTimer();
   ObjectsDeleteAll(0);
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+-------------ROTINAS----------------------------------------------+

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
      hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
      hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
      hora_ent=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_ent);

      lucro_orders=LucroOrdens();
      if(!opt_tester)
        {
         lucro_orders_mes=LucroOrdensMes();
         lucro_orders_sem=LucroOrdensSemana();
        }
     }

   timerOn=true;
   if(TimeCurrent()>hora_ent)TimeEnt=false;
   else TimeEnt=true;

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
      return;
     }

   gv.Set("gv_today_prev",gv.Get("gv_today"));

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   rsi.Refresh();
   adx.Refresh();
   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }
   if(bid>=ask) return;//Leilão

   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//   lucro_total=LucroTotal();
   pos_aberta=PosicaoAberta();
   if(pos_aberta)lucro_positions=LucroPositions();
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
   if(UsarLucro && ((lucro>0 && lucro_total>=lucro) || (prejuizo>0 && lucro_total<=-prejuizo)))
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

   if(!pos_aberta)
     {
      if(OrdersTotal()>0)DeleteOrdersExEntry();
     }

   if(tradeOn && timerOn)

     {// inicio Trade On

      if(pos_aberta)
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

      buysignal=BuySignal() && FiltroBuy() && !pos_aberta;
      sellsignal=SellSignal() && FiltroSell() && !pos_aberta;

      if(ReverterSig)
        {
         buysignal=BuySignal() && FiltroBuy() && !Buy_opened();
         sellsignal=SellSignal() && FiltroSell() && !Sell_opened();
        }
      buysignal=buysignal && operar!=Venda;
      sellsignal=sellsignal && operar!=Compra;

      if(UsarGap)
        {
         buysignal=buysignal && GapBuy(pts_gap);
         sellsignal=sellsignal && GapSell(pts_gap);
        }
      if(UsarLucro && ((lucro_ent>0 && lucro_total>=lucro_ent) || (prejuizo_ent>0 && lucro_total<=-prejuizo_ent)))
        {
         TimeEnt=false;
        }
      if(TimeEnt)
        {
         if(buysignal)
           {
            barra_sinal=high[1]-low[1];
            if(OrdersTotal()>0)DeleteALL();
            if(PositionsTotal()>0)CloseALL();
            switch(opt_dist)
              {
               case DistBarra:
                  sl_position=NormalizeDouble(bid-_Stop*(high[1]-low[1]),digits);
                  tp_position=NormalizeDouble(ask+_TakeProfit*(high[1]-low[1]),digits);
                  break;
               case DistPontos:
                  sl_position=NormalizeDouble(bid-_Stop*ponto,digits);
                  tp_position=NormalizeDouble(ask+_TakeProfit*ponto,digits);
                  break;
               case DistForex:
                  sl_position=NormalizeDouble(bid-_Stop*10*ponto,digits);
                  tp_position=NormalizeDouble(ask+_TakeProfit*10*ponto,digits);
                  break;
              }
            sl_position=NormalizaPreco(sl_position);
            tp_position=NormalizaPreco(tp_position);
            if(mytrade.Buy(Lot,original_symbol,0,sl_position,0,"BUY"+exp_name))
              {
               gv.Set(cp_tick,(double)mytrade.ResultOrder());

               if(mytrade.SellLimit(Lot,tp_position,original_symbol,0,0,order_time_type,0,"TAKE PROFIT"))
                 {
                  gv.Set("tp_vd_tick",(double)mytrade.ResultOrder());
                 }
               else
                  Print("Erro enviar ordem: ",GetLastError());
              }
            else Print("Erro enviar ordem ",GetLastError());
           }

         if(sellsignal)
           {
            if(OrdersTotal()>0)DeleteALL();
            if(PositionsTotal()>0)CloseALL();
            barra_sinal=high[1]-low[1];
            switch(opt_dist)
              {
               case DistBarra:
                  sl_position=NormalizeDouble(ask+_Stop*(high[1]-low[1]),digits);
                  tp_position=NormalizeDouble(bid-_TakeProfit*(high[1]-low[1]),digits);
                  break;
               case DistPontos:
                  sl_position=NormalizeDouble(ask+_Stop*ponto,digits);
                  tp_position=NormalizeDouble(bid-_TakeProfit*ponto,digits);
                  break;
               case DistForex:
                  sl_position=NormalizeDouble(ask+_Stop*10*ponto,digits);
                  tp_position=NormalizeDouble(bid-_TakeProfit*10*ponto,digits);
                  break;
              }
            sl_position=NormalizaPreco(sl_position);
            tp_position=NormalizaPreco(tp_position);

            if(mytrade.Sell(Lot,original_symbol,0,sl_position,0,"SELL"+exp_name))
              {
               gv.Set(vd_tick,(double)mytrade.ResultOrder());
               if(mytrade.BuyLimit(Lot,tp_position,original_symbol,0,0,order_time_type,0,"TAKE PROFIT"))
                 {
                  gv.Set("tp_cp_tick",(double)mytrade.ResultOrder());
                 }
               else
                  Print("Erro enviar ordem: ",GetLastError());

              }
            else Print("Erro enviar ordem ",GetLastError());
           }
        }

     }//End Trade On

  }//Fim Ontick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::BuySignal()
  {
   bool signal=false;
   switch(Estrategia)
     {
      case EstRSI:
         signal=rsi.Main(1)>rsi_min && rsi.Main(2)<rsi_min;
         break;
      case EstHiLo:
         signal=HiLoColor[1]==0.0 && HiLoColor[2]!=0.0;
         break;
      default:
         signal=false;
         break;
     }
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal=false;
   switch(Estrategia)
     {
      case EstRSI:
         signal=rsi.Main(1)<rsi_max && rsi.Main(2)>rsi_max;
         break;
      case EstHiLo:
         signal=HiLoColor[1]==1.0 && HiLoColor[2]!=1.0;
         break;
      default:
         signal=false;
         break;
     }

   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::FiltroBuy()
  {
   bool signal=true;

   switch(Estrategia)
     {
      case EstRSI:
         if(FiltroHiLo==BOOL_YES)signal=signal && HiLoColor[0]==0.0;
         break;
      case EstHiLo:
         if(FiltroRSI==BOOL_YES)signal=signal && rsi.Main(0)<rsi_min;
         break;
      default:
         signal=true;
         break;
     }
   if(FiltroADX==BOOL_YES)
     {
      switch(filt_adx)
        {
         case FiltAdMaior:
            signal=signal && adx.Main(0)>adxmin;
            break;
         case FiltAdMenor:
            signal=signal && adx.Main(0)<adxmax;
            break;
         default:
            signal=true;
            break;

        }
     }

   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::FiltroSell()
  {
   bool signal=true;
   switch(Estrategia)
     {
      case EstRSI:
         if(FiltroHiLo==BOOL_YES)signal=signal && HiLoColor[0]==1.0;
         break;
      case EstHiLo:
         if(FiltroRSI==BOOL_YES)signal=signal && rsi.Main(0)>rsi_max;
         break;
      default:
         signal=true;
         break;
     }
   if(FiltroADX==BOOL_YES)
     {
      switch(filt_adx)
        {
         case FiltAdMaior:
            signal=signal && adx.Main(0)>adxmin;
            break;
         case FiltAdMenor:
            signal=signal && adx.Main(0)<adxmax;
            break;
         default:
            signal=true;
            break;

        }
     }

   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MyRobot::GapBuy(double p_gaps)
  {
   return iClose(Symbol(), PERIOD_D1, 1) - iOpen(Symbol(), PERIOD_D1, 0)>= p_gaps * ponto;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::GapSell(double p_gaps)
  {
   return iClose(Symbol(), PERIOD_D1, 1) - iOpen(Symbol(), PERIOD_D1, 0)<= -p_gaps * ponto;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::Atual_vol_Stop_Take()
  {
   double vol_parc,mult_dist;

   vol_parc=VolumeOrdensCmt("PARCIAL 1")+VolumeOrdensCmt("PARCIAL 2")+VolumeOrdensCmt("PARCIAL 3");
   switch(opt_dist)
     {
      case DistBarra:
         mult_dist=barra_sinal/ponto;
         break;
      case DistForex:
         mult_dist=10;
         break;
      case DistPontos:
         mult_dist=1;
         break;
      default:
         mult_dist=1;
         break;
     }
   if(Buy_opened())
     {
      if(myposition.SelectByTicket((ulong)gv.Get("cp_tick")))
        {
         vol_pos=VolPosType(POSITION_TYPE_BUY)-vol_parc;
         if(myorder.Select((ulong)gv.Get("tp_vd_tick")))
            vol_stp=myorder.VolumeInitial();
         else vol_stp=0;
         //preco_stp=myorder.PriceOpen();

         preco_stp=NormalizaPreco(PrecoMedio(POSITION_TYPE_BUY)+_TakeProfit*mult_dist*ponto);

         if(vol_pos!=vol_stp)
           {
            if(myorder.Select((ulong)gv.Get("tp_vd_tick")))
               mytrade.OrderDelete((ulong)gv.Get("tp_vd_tick"));
            if(vol_pos>0)
              {
               mytrade.SellLimit(vol_pos,preco_stp,original_symbol,0,0,order_time_type,0,"TAKE PROFIT");
               gv.Set("tp_vd_tick",(double)mytrade.ResultOrder());
              }
           }
        }
     }
   if(Sell_opened())
     {

      if(myposition.SelectByTicket((ulong)gv.Get("vd_tick")))
        {
         vol_pos=VolPosType(POSITION_TYPE_SELL)-vol_parc;
         if(myorder.Select((ulong)gv.Get("tp_cp_tick")))
            vol_stp=myorder.VolumeInitial();
         else vol_stp=0;
         // preco_stp=myorder.PriceOpen();
         preco_stp=NormalizaPreco(PrecoMedio(POSITION_TYPE_SELL)-_TakeProfit*mult_dist*ponto);
         if(vol_pos!=vol_stp)
           {
            if(myorder.Select((ulong)gv.Get("tp_cp_tick")))
               mytrade.OrderDelete((ulong)gv.Get("tp_cp_tick"));
            if(vol_pos>0)
              {
               mytrade.BuyLimit(vol_pos,preco_stp,original_symbol,0,0,order_time_type,0,"TAKE PROFIT");
               gv.Set("tp_cp_tick",(double)mytrade.ResultOrder());
              }
           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool MyRobot::GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(hilo_handle,0,0,5,HiLoBuffer)<=0 || 
         CopyBuffer(hilo_handle,1,0,5,HiLoColor)<=0 || 
         CopyHigh(Symbol(),PERIOD_CURRENT,0,5,high)<=0 || 
         CopyOpen(Symbol(),PERIOD_CURRENT,0, 5, open) <= 0 ||
         CopyLow(Symbol(), PERIOD_CURRENT, 0, 5, low) <= 0 ||
         CopyClose(Symbol(),PERIOD_CURRENT,0,5,close) <= 0;
   return (b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTradeTransaction(const MqlTradeTransaction &trans,
                                 const MqlTradeRequest &request,
                                 const MqlTradeResult &result)
  {

   if(trans.symbol!=original_symbol)
      return;
   double buyprice,sellprice;
   int TENTATIVAS=10;
   double mult_dist;
   switch(opt_dist)
     {
      case DistBarra:
         mult_dist=barra_sinal/ponto;
         break;
      case DistForex:
         mult_dist=10;
         break;
      case DistPontos:
         mult_dist=1;
         break;
      default:
         mult_dist=1;
         break;
     }

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
                 }

               if(deal_profit>0)
                 {
                  Print("Saída no GAIN");
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

            myposition.SelectByTicket(trans.order);
            int cont=0;
            buyprice=0;
            while(buyprice==0 && cont<TENTATIVAS)
              {
               buyprice=myposition.PriceOpen();
               cont+=1;
              }
            if(buyprice==0)buyprice=mysymbol.Ask();

            Entr_Parcial_Buy(buyprice);
            Real_Parc_Buy(Lot,buyprice);

           }
         //--------------------------------------------------

         if(myhistory.Comment()=="SELL"+exp_name && trans.order_state==ORDER_STATE_FILLED)
           {
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

            Entr_Parcial_Sell(sellprice);
            Real_Parc_Sell(Lot,sellprice);

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
              }
           }
        }
     }//FIM TRANSACTION HISTOY ADD
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void MyRobot::Entr_Parcial_Buy(const double preco)
  {
   double mult_dist;
   switch(opt_dist)
     {
      case DistBarra:
         mult_dist=barra_sinal/ponto;
         break;
      case DistForex:
         mult_dist=10;
         break;
      case DistPontos:
         mult_dist=1;
         break;
      default:
         mult_dist=1;
         break;
     }

   sl_position=NormalizaPreco(preco-_Stop*mult_dist*ponto);
   if(Lot_entry1>0) mytrade.BuyLimit(Lot_entry1,NormalizaPreco(preco-pts_entry1*mult_dist*ponto),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 1");
   if(Lot_entry2>0) mytrade.BuyLimit(Lot_entry2,NormalizaPreco(preco-pts_entry2*mult_dist*ponto),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 2");
   if(Lot_entry3>0) mytrade.BuyLimit(Lot_entry3,NormalizaPreco(preco-pts_entry3*mult_dist*ponto),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 3");
   if(Lot_entry4>0) mytrade.BuyLimit(Lot_entry4,NormalizaPreco(preco-pts_entry4*mult_dist*ponto),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 4");
   if(Lot_entry5>0) mytrade.BuyLimit(Lot_entry5,NormalizaPreco(preco-pts_entry5*mult_dist*ponto),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 5");
   if(Lot_entry6>0) mytrade.BuyLimit(Lot_entry6,NormalizaPreco(preco-pts_entry6*mult_dist*ponto),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 6");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void MyRobot::Entr_Parcial_Sell(const double preco)
  {
   double mult_dist;
   switch(opt_dist)
     {
      case DistBarra:
         mult_dist=barra_sinal/ponto;
         break;
      case DistForex:
         mult_dist=10;
         break;
      case DistPontos:
         mult_dist=1;
         break;
      default:
         mult_dist=1;
         break;
     }

   sl_position=NormalizaPreco(preco+_Stop*mult_dist*ponto);
   if(Lot_entry1>0) mytrade.SellLimit(Lot_entry1,NormalizaPreco(preco+pts_entry1*mult_dist*ponto),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 1");
   if(Lot_entry2>0) mytrade.SellLimit(Lot_entry2,NormalizaPreco(preco+pts_entry2*mult_dist*ponto),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 2");
   if(Lot_entry3>0) mytrade.SellLimit(Lot_entry3,NormalizaPreco(preco+pts_entry3*mult_dist*ponto),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 3");
   if(Lot_entry4>0) mytrade.SellLimit(Lot_entry4,NormalizaPreco(preco+pts_entry4*mult_dist*ponto),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 4");
   if(Lot_entry5>0) mytrade.SellLimit(Lot_entry5,NormalizaPreco(preco+pts_entry5*mult_dist*ponto),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 5");
   if(Lot_entry6>0) mytrade.SellLimit(Lot_entry6,NormalizaPreco(preco+pts_entry6*mult_dist*ponto),original_symbol,sl_position,0,order_time_type,0,"Entrada Parcial 6");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::Real_Parc_Buy(double vol,double preco)
  {
   double lts_rp1=0;
   double lts_rp2=0;
   double lts_rp3=0;

   double mult_dist;
   switch(opt_dist)
     {
      case DistBarra:
         mult_dist=barra_sinal/ponto;
         break;
      case DistForex:
         mult_dist=10;
         break;
      case DistPontos:
         mult_dist=1;
         break;
      default:
         mult_dist=1;
         break;
     }

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

      if(rp1>0&&lts_rp1>0)mytrade.SellLimit(lts_rp1,NormalizaPreco(preco+rp1*mult_dist*ponto),original_symbol,0,0,order_time_type,0,"PARCIAL 1");
      if(rp2>0&&lts_rp2>0)mytrade.SellLimit(lts_rp2,NormalizaPreco(preco+rp2*mult_dist*ponto),original_symbol,0,0,order_time_type,0,"PARCIAL 2");
      if(rp3>0&&lts_rp3>0)mytrade.SellLimit(lts_rp3,NormalizaPreco(preco+rp3*mult_dist*ponto),original_symbol,0,0,order_time_type,0,"PARCIAL 3");


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   double mult_dist;
   switch(opt_dist)
     {
      case DistBarra:
         mult_dist=barra_sinal/ponto;
         break;
      case DistForex:
         mult_dist=10;
         break;
      case DistPontos:
         mult_dist=1;
         break;
      default:
         mult_dist=1;
         break;
     }

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
      if(rp1>0&&lts_rp1>0)mytrade.BuyLimit(lts_rp1,NormalizaPreco(preco-rp1*mult_dist*ponto),original_symbol,0,0,order_time_type,0,"PARCIAL 1");
      if(rp2>0&&lts_rp2>0)mytrade.BuyLimit(lts_rp2,NormalizaPreco(preco-rp2*mult_dist*ponto),original_symbol,0,0,order_time_type,0,"PARCIAL 2");
      if(rp3>0&&lts_rp3>0)mytrade.BuyLimit(lts_rp3,NormalizaPreco(preco-rp3*mult_dist*ponto),original_symbol,0,0,order_time_type,0,"PARCIAL 3");


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::Painel(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {

   int xx1=INDENT_LEFT;
   int yy1=INDENT_TOP;
   int xx2=x1+BUTTON_WIDTH;
   int yy2=INDENT_TOP+BUTTON_HEIGHT;

   edit_painel.Create(chart,name,subwin,x1,y1,x2,y2);
   edit_painel.ColorBackground(clrBlack);
//--- create dependent controls

   m_label[0].Create(chart,"label0",subwin,xx1,yy1,xx2,yy2);
   m_label[0].Color(clrDeepSkyBlue);
   m_label[0].FontSize(9);
   string s_pos="-";
   if(Buy_opened())s_pos="Comprado";
   if(Sell_opened())s_pos="Vendido";
   m_label[0].Text("Posição: "+s_pos);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;


   m_label[1].Create(chart,"label1",subwin,xx1,yy1,xx2,yy2);
   m_label[1].Color(clrDeepSkyBlue);
   m_label[1].FontSize(9);
   m_label[1].Text("Resultado Mensal: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2));

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   m_label[2].Create(chart,"label2",subwin,xx1,yy1,xx2,yy2);
   m_label[2].Color(clrDeepSkyBlue);
   m_label[2].FontSize(9);
   m_label[2].Text("Resultado Semanal: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2));

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+3*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   m_label[3].Create(chart,"label3",subwin,xx1,yy1,xx2,yy2);
   m_label[3].Color(clrDeepSkyBlue);
   m_label[3].FontSize(9);
   m_label[3].Text("Resultado Diário: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2));
//--- succeed 
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   MyEA.OnTradeTransaction(trans,request,result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

/* if(TimeCurrent()>D'2019.06.15 23:59:59')
     {
      string erro="Data de Validade Expirou";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO)
     {
      string erro="EA permitido apenas em conta DEMO";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }
*/
   if(!ChartSetInteger(ChartID(),CHART_SHIFT,0,LARGURA_PAINEL+30))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }

   return MyEA.OnInit();

//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   MyEA.OnTimer();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

//--- Código de motivo de desinicialização   
   Print(__FUNCTION__," UninitializeReason() = ",getUninitReasonText(UninitializeReason()));
   MyEA.OnDeinit(reason);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   MyEA.OnTick();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void OnChartEvent(const int id,// event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyPanel::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {

   int xx1=int(0.7*INDENT_LEFT);
   int yy1=INDENT_TOP;
   int xx2=int(xx1+0.7*BUTTON_WIDTH);
   int yy2=int(yy1+0.5*BUTTON_HEIGHT);

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);

   if(!CreatePanel(chart,subwin,painel,x1,y1,x2,y2))
      return (false);

//--- create dependent controls 

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Lucro Mês: "+DoubleToString(MyEA.LucroTotalMes(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[0].Color(clrYellowGreen);
   m_label[0].FontSize(8);

   xx1=int(0.7*INDENT_LEFT);
   yy1=int(INDENT_TOP+0.5*BUTTON_HEIGHT+0.6*CONTROLS_GAP_Y);
   xx2=int(xx1+0.7*BUTTON_WIDTH);
   yy2=int(yy1+0.5*BUTTON_HEIGHT);

   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"Lucro Semana: "+DoubleToString(MyEA.LucroTotalSemana(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[1].Color(clrYellowGreen);
   m_label[1].FontSize(8);

   xx1=int(0.7*INDENT_LEFT);
   yy1=int(INDENT_TOP+1.2*BUTTON_HEIGHT+0.6*CONTROLS_GAP_Y);
   xx2=int(xx1+0.7*BUTTON_WIDTH);
   yy2=int(yy1+0.5*BUTTON_HEIGHT);

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"Lucro Dia: "+DoubleToString(MyEA.LucroTotal(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[2].Color(clrYellowGreen);
   m_label[2].FontSize(8);

// Minimized(false);//Mudar Se nao quiser minimizar

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyPanel::OnTick(void)
  {
   m_label[0].Text("Lucro Mês: "+DoubleToString(MyEA.LucroTotalMes(),2));
   m_label[1].Text("Lucro Semana: "+DoubleToString(MyEA.LucroTotalSemana(),2));
   m_label[2].Text("Lucro Dia: "+DoubleToString(MyEA.LucroTotal(),2));
//Maximize();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(MyPanel)

EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+

int ChartWidthInPixels(const long chart_ID=0)
  {
//--- prepare the variable to get the property value
   long result=-1;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetInteger(chart_ID,CHART_WIDTH_IN_PIXELS,0,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return((int)result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ChartHeightInPixelsGet(const long chart_ID=0,const int sub_window=0)
  {
//--- prepare the variable to get the property value
   long result=-1;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetInteger(chart_ID,CHART_HEIGHT_IN_PIXELS,sub_window,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return((int)result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
string getUninitReasonText(int reasonCode)
  {
   string text="";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- 
   switch(reasonCode)
     {
      case REASON_ACCOUNT:
         text="Account was changed";break;
      case REASON_CHARTCHANGE:
         text="Symbol or timeframe was changed";break;
      case REASON_CHARTCLOSE:
         text="Chart was closed";break;
      case REASON_PARAMETERS:
         text="Input-parameter was changed";break;
      case REASON_RECOMPILE:
         text="Program "+__FILE__+" was recompiled";break;
      case REASON_REMOVE:
         text="Program "+__FILE__+" was removed from chart";break;
      case REASON_TEMPLATE:
         text="New template was applied to chart";break;
      default:text="Another reason";
     }
//--- 
   return text;
  }
//+------------------------------------------------------------------+
