//+------------------------------------------------------------------+
//|                                                       Params.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#resource "\\Indicators\\Indic_Afastamento_Media_MATS.ex5"
#resource "\\Indicators\\bbandwidth_midle.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

enum OpcaoGap
  {
   Nao_Operar,              //Não Operar
   Operar_Apos_Toque_Media, //Operar Após Toque na Média
   Operacoes_Normais        //Operar Normalmente
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Operacao
  {
   Contra, //Contra-Tendência
   Favor   //Favor da Tendência
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Sentido
  {
   Compra,        //Operar Comprado
   Venda,         //Operar Vendido
   Compra_e_Venda //Operar Comprado e Vendido
  };

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

#include <Expert_Class_New.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>

CAccountInfo      myaccount;
MyPanel ExtDialog;

CLabel            m_label[50];

#define LARGURA_PAINEL 270 // Largura Painel
#define ALTURA_PAINEL 180 // Altura Painel




// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
                                                 //input string simbolo="WING19";//Digitar Símbolo Original
input int MAGIC_NUMBER=20082018;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input double Lot=1;//Lote Entrada
input double _Stop=300;//Stop Loss em Pontos
input double _TakeProfit=300;//Take Profit em Pontos
input uint n_minutes=10;//Minutos de pausa após fechar um trade
input string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia

sinput string srealp="############------------------------Realização Parcial-------------------------------#################";//Realização Parcial
input double rp1=0;//Pontos R.P 1 (0 Não Usar)
input double _lts_rp1=25;//Porcentagem Lotes R.P 1
input double rp2=0;//Pontos R.P 2 (0 Não Usar)
input double _lts_rp2=25;//Porcentagem Lotes R.P 2
input double rp3=0;//Pontos R.P 3 (0 Não Usar)
input double _lts_rp3=0;//Porcentagem Lotes R.P 3

sinput string STrailing="############---------------Trailing Stop----------########";//Trailing
input bool   Use_TraillingStop=false; //Usar Trailing 
input double TraillingStart=0;//Lucro Minimo Iniciar trailing stop
input double TraillingDistance=200;// Distancia em Pontos do Stop Loss
input double TraillingStep=10;// Passo para atualizar Stop Loss

sinput string sbreak="########---------Break Even---------------###############";//BreakEven
input    bool              UseBreakEven=false;                          //Usar BreakEven
input    double               BreakEvenPoint1=100;                            //Pontos para BreakEven 1
input    double               ProfitPoint1=10;                             //Pontos de Lucro da Posicao 1
input    double               BreakEvenPoint2=150;                            //Pontos para BreakEven 2
input    double               ProfitPoint2=80;                            //Pontos de Lucro da Posicao 2
input    double               BreakEvenPoint3=200;                            //Pontos para BreakEven 3
input    double               ProfitPoint3=130;                            //Pontos de Lucro da Posicao 3
input    double               BreakEvenPoint4=300;                            //Pontos para BreakEven 4
input    double               ProfitPoint4=230;                            //Pontos de Lucro da Posicao 4
input    double               BreakEvenPoint5         =500;                            //Pontos para BreakEven 5
input    double               ProfitPoint5            =400;                            //Pontos de Lucro da Posicao 5


input string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:04";//Horario Inicial
input string end_hour="17:20";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario
sinput string sdias="FILTRO DOS DIAS DA SEMANA";//Dias da Semana
input bool trade0=true;// Operar Domingo
input bool trade1=true;// Operar Segunda
input bool trade2=true;// Operar Terça
input bool trade3=true;// Operar Quarta
input bool trade4=true;// Operar Quinta
input bool trade5=true;// Operar Sexta
input bool trade6=true;// Operar Sábado

sinput string SEst_Med="############---------------------------------------Afastamento da Média------------------------------------------------########";   //Afastamento da Média
input int period_media=7; //Período Média                                                                                                                                  //Periodo da Media
input ENUM_MA_METHOD modo_media=MODE_EMA;  //Modo Média                                                                                                                //Modo da Média
input ENUM_APPLIED_PRICE app_media=PRICE_CLOSE; //Aplicar a                                                                                                            //Aplicar a
input double dist_media=2.0;  //Distância da Média para Entradas                                                                                                                              //Distância da Média em Pontos
input Operacao operacao=Favor; //Sentido da Operação                                                                                                                             //Operar a Favor ou Contra a Tendência
input Sentido operar=Compra_e_Venda; //Tipo de Entradas                                                                                                                       // Operar Comprado, Vendido
input bool cada_tick=true; //Operar a Cada tick                                                                                                                                 //Operar a cada tick

sinput string SsaidSec="############-------------------------------------------Saída Média Secundária----------------------------------------############";  //Média Secundária
input int period_med_sec=5;   //Período Média Secundária                                                                                                                               //Período Média Secundária
input ENUM_MA_METHOD mode_sec=MODE_EMA; //Modo Média                                                                                                                    //Modo Média Secundária
input ENUM_APPLIED_PRICE app_sec=PRICE_CLOSE;   //Aplicar a
input bool FecharMediaSec=false;//Fechar na Média Secundária                                                                                                         
input ulong saida_sec=4;  //A partir de qual Aumento Fechar na Média Secundária                                                                                                                                   //Aum de Pos p acionar Fech Média Sec/ 0 Não Sair na Secundária
sinput string Sbband="############-------------------------------------------BBANDWIDTH----------------------------------------############";  //BBandWidth
input int     InpBandsPeriod=20;       // Período Banda
input int     InpBandsShift=0;         // Shift
input double  InpBandsDeviations=2.0;  // Deviation
input double  InpNivel1=0.002;  // Nível 1
input double  InpNivel2=0.0045;  // Nível 2
input double  InpNivel3=0.015;  // Nível 3
input double  InpNivel4=0.020;  // Nível 4
sinput string SGap="############----------------------------------------------------Filtro de Gap---------------------------------------------############"; //Gap
input OpcaoGap UsarGap=Operar_Apos_Toque_Media; // Usar Gap                                                                                                             //Opção de Gap
input double pts_gap=10;//Pontos de Gap para Filtro                                                                                                                                     //Gap em Pontos para Filtrar Entradas

sinput string SAumento="############---------------Aumento de Posição Contra----------########";//Aumento Contra
input double pts_saida_aumento=0;//Pontos de Saída Dos Aumentos(0 não sair)
input double Lot_entry1=0;//Lotes Entrada 1 (0 não entrar)
input double pts_entry1=0;//Pontos Entrada 1
input double Lot_entry2=0;//Lotes Entrada 2 (0 não entrar)
input double pts_entry2=0;//Pontos Entrada 2 
input double Lot_entry3=0;//Lotes Entrada 3 (0 não entrar)
input double pts_entry3=0;//Pontos Entrada 3
input double Lot_entry4=0;//Lotes Entrada 4 (0 não entrar)
input double pts_entry4=0;//Pontos Entrada 4
input double Lot_entry5=0;//Lotes Entrada 5 (0 não entrar)
input double pts_entry5=0;//Pontos Entrada 5
input double Lot_entry6=0;//Lotes Entrada 6 (0 não entrar)
input double pts_entry6=0;//Pontos Entrada 6
input double Lot_entry7=0;//Lotes Entrada 7 (0 não entrar)
input double pts_entry7=0;//Pontos Entrada 7
input double Lot_entry8=0;//Lotes Entrada 8 (0 não entrar)
input double pts_entry8=0;//Pontos Entrada 8
input double Lot_entry9=0;//Lotes Entrada 9 (0 não entrar)
input double pts_entry9=0;//Pontos Entrada 9
input double Lot_entry10=0;//Lotes Entrada 10 (0 não entrar)
input double pts_entry10=0;//Pontos Entrada 10

sinput string SAumentofavor="############---------------Aumento de Posição A Favor----------########";//Aumento Favor
input double pts_saida_aumento_fv=150;//Pontos de Saída Dos Aumentos(0 não sair)
input double Lot_entry1_fv=0;//Lotes Entrada 1 (0 não entrar)
input double pts_entry1_fv=0;//Pontos Entrada 1
input double Lot_entry2_fv=0;//Lotes Entrada 2 (0 não entrar)
input double pts_entry2_fv=0;//Pontos Entrada 2 
input double Lot_entry3_fv=0;//Lotes Entrada 3 (0 não entrar)
input double pts_entry3_fv=0;//Pontos Entrada 3
input double Lot_entry4_fv=0;//Lotes Entrada 4 (0 não entrar)
input double pts_entry4_fv=0;//Pontos Entrada 4
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class AfastMedia : public MyExpert
  {
private:
   CiMA             *media;
   CiMA             *media_sec;
   CChartObjectVLine VLine[];

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
   bool              opt_tester;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   bool              time_new_ent;
   int               bband_handle;
   double            BB_WID_Buff[];

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
   void              Real_Parc_Sell(double vol,double preco);
   void              Real_Parc_Buy(double vol,double preco);

  };

AfastMedia MyAfastMed;
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

   ulong curChartID=ChartID();

   media=new CiMA;
   media.Create(Symbol(), periodoRobo, period_media, 0, modo_media, app_media);
   media.AddToChart(curChartID, 0);

   media_sec=new CiMA;
   media_sec.Create(Symbol(), periodoRobo, period_med_sec, 0, mode_sec, app_sec);
   media_sec.AddToChart(curChartID, 0);

   media_mat_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\Indic_Afastamento_Media_MATS.ex5",period_media,modo_media,app_media);
   ChartIndicatorAdd(curChartID,(int)ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),media_mat_handle);

   bband_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\bbandwidth_midle.ex5",InpBandsPeriod,InpBandsShift,InpBandsDeviations,InpNivel1,InpNivel2,InpNivel3,InpNivel4);
   ChartIndicatorAdd(curChartID,(int)ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),bband_handle);

   ArraySetAsSeries(BB_WID_Buff,true);
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
      ulong ticket_history_deal=0;
      int cont_deals=0;
      for(int i=0;i<total_deals;i++)
        {
         ticket_history_deal=HistoryDealGetTicket(i);

         //--- try to get deals ticket_history_deal
         if(ticket_history_deal>0)
           {
            ulong deal_magic=HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
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
//---
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
   novodia=Bar_NovoDia.CheckNewBar(original_symbol,PERIOD_D1);

   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      gv.Set("glob_entr_tot",0.0);
      gv.Set("deals_total_prev",0.0);
      gv.Set("last_stop",0.0);
      tradeOn=true;
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

   if(!tradeOn)return;


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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

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

   if(!gapOn)return;

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

   if(!PosicaoAberta())
     {
      gv.Set("close_buy_sec",0.0);
      gv.Set("close_sell_sec",0.0);
      if(OrdersTotal()>0)DeleteALL();
     }
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
      if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);
      if(UseBreakEven)BreakEven(original_symbol,UseBreakEven,PointBreakEven,PointProfit);
     }
   if(tradeOn && timerOn)

     { // inicio Trade On

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

         if(Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo))
           {
            tradebarra=true;
            if(!cada_tick)
              {
               if(BuySignal() && !Buy_opened() && operar!=Venda && tradebarra && TradeStop())
                 {
                  if(OrdersTotal()>0)DeleteALL();
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
                  if(OrdersTotal()>0)DeleteALL();
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
               if(OrdersTotal()>0) DeleteALL();
               if(Sell_opened())
                  ClosePosType(POSITION_TYPE_SELL);
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
               if(OrdersTotal()>0) DeleteALL();
               if(Buy_opened())
                  ClosePosType(POSITION_TYPE_BUY);
               if(mytrade.Sell(Lot,original_symbol,0,NormalizeDouble(ask+_Stop*ponto,digits),0,"SELL"+exp_name))
                 {
                  gv.Set("vd_tick",(double)mytrade.ResultOrder());
                  tradebarra=false;
                 }
               else
                  Print("Erro enviar ordem ",GetLastError());
              }
           }

        } // Fim gap On

     } //End Trade On

  } //End OnTick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AfastMedia::BuySignal()
  {
   bool b_signal,bb_width;
   if(operacao==Favor)
      b_signal= bid-media.Main(0)>= dist_media * ponto;
   else
      b_signal=media.Main(0)-ask>=dist_media*ponto;
   if(operacao== Contra)
      bb_width=BB_WID_Buff[1]<BB_WID_Buff[2] && BB_WID_Buff[0]<=InpNivel2;
   else
      bb_width=BB_WID_Buff[1]>BB_WID_Buff[2] && BB_WID_Buff[0]>InpNivel2;
   b_signal=b_signal && bb_width;
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
   bool s_signal,bb_width;
   if(operacao==Favor)
      s_signal= media.Main(0)-ask>= dist_media * ponto;
   else
      s_signal=bid-media.Main(0)>=dist_media*ponto;
   if(operacao== Contra)
      bb_width=BB_WID_Buff[1]<BB_WID_Buff[2] && BB_WID_Buff[0]<=InpNivel2;
   else
      bb_width=BB_WID_Buff[1]>BB_WID_Buff[2] && BB_WID_Buff[0]>InpNivel2;
   s_signal=s_signal && bb_width;
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
   b_get=CopyBuffer(bband_handle,0,0,5,BB_WID_Buff)<=0 || 
         CopyHigh(Symbol(),periodoRobo,0,5,high)<=0 || 
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
               if(mytrade.SellLimit(Lot,tp_position,original_symbol,0,0,order_time_type,0,"TAKE PROFIT"))
                 {
                  gv.Set("tp_vd_tick",(double)mytrade.ResultOrder());
                 }
               else
                  Print("Erro enviar ordem: ",GetLastError());

               if(!mytrade.BuyLimit(Lot,NormalizeDouble(buyprice-ticksize,digits),original_symbol,0,0,order_time_type,0,"MEDIO_BUY"))
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
               if(mytrade.BuyLimit(Lot,tp_position,original_symbol,0,0,order_time_type,0,"TAKE PROFIT"))
                 {
                  gv.Set("tp_cp_tick",(double)mytrade.ResultOrder());
                 }
               else
                  Print("Erro enviar ordem: ",GetLastError());
               if(!mytrade.SellLimit(Lot,NormalizeDouble(sellprice+ticksize,digits),original_symbol,0,0,order_time_type,0,"MEDIO_SELL"))
                  Print("Erro enviar ordem: ",GetLastError());

               Entr_Parcial_Sell(sellprice);
               Entr_Favor_Sell(sellprice);
               Real_Parc_Sell(Lot,sellprice);

              }

            if(mydeal.Comment()=="MEDIO_SELL")
              {
               int cont=0;
               sellprice=0;
               while(sellprice==0 && cont<TENTATIVAS)
                 {
                  sellprice=mydeal.Price();
                  cont+=1;
                 }
               if(sellprice== 0)
                  sellprice= mysymbol.Bid();

               if(!mytrade.BuyLimit(Lot,NormalizeDouble(sellprice-2*ticksize,digits),original_symbol,0,0,order_time_type,0,"MEDIO_SELL_OUT"))
                  Print("Erro enviar ordem: ",GetLastError());

              }
            if(mydeal.Comment()=="MEDIO_BUY")
              {
               int cont=0;
               buyprice=0;
               while(buyprice==0 && cont<TENTATIVAS)
                 {
                  buyprice=mydeal.Price();
                  cont+=1;
                 }
               if(buyprice== 0)
                  buyprice= mysymbol.Ask();

               if(!mytrade.SellLimit(Lot,NormalizeDouble(buyprice+2*ticksize,digits),original_symbol,0,0,order_time_type,0,"MEDIO_BUY_OUT"))
                  Print("Erro enviar ordem: ",GetLastError());
              }

            if(mydeal.Comment()=="MEDIO_SELL_OUT")
              {
               if(Sell_opened() && myposition.SelectByTicket((ulong)gv.Get("vd_tick")))
                 {
                  int cont=0;
                  sellprice=0;
                  while(sellprice==0 && cont<TENTATIVAS)
                    {
                     sellprice=myposition.PriceOpen();
                     cont+=1;
                    }
                  if(sellprice== 0)
                     sellprice= mysymbol.Bid();

                  if(!mytrade.SellLimit(Lot,NormalizeDouble(sellprice+ticksize,digits),original_symbol,0,0,order_time_type,0,"MEDIO_SELL"))
                     Print("Erro enviar ordem: ",GetLastError());
                 }
              }
            if(mydeal.Comment()=="MEDIO_BUY_OUT")
              {
               if(Buy_opened() && myposition.SelectByTicket((ulong)gv.Get("cp_tick")))
                 {

                  int cont=0;
                  buyprice=0;
                  while(buyprice==0 && cont<TENTATIVAS)
                    {
                     buyprice=myposition.PriceOpen();
                     cont+=1;
                    }
                  if(buyprice== 0)
                     buyprice= mysymbol.Ask();

                  if(!mytrade.SellLimit(Lot,NormalizeDouble(buyprice-ticksize,digits),original_symbol,0,0,order_time_type,0,"MEDIO_BUY"))
                     Print("Erro enviar ordem: ",GetLastError());
                 }
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

            if((mydeal.DealType()==DEAL_TYPE_BUY || mydeal.DealType()==DEAL_TYPE_SELL) && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
              {
               if(mydeal.Profit()<0)
                 {
                  Print("Saída por STOP LOSS. Aguardar Toque na Média");
                  gv.Set("last_stop",1.0);
                  gv.Set("pos_stop",mydeal.Price()-media.Main(0));
                 }
               time_new_ent=false;
               EventSetTimer(n_minutes);

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
   bool bb_exit,dist;
   dist=false;
   bool sec=false;
   if(operacao==Contra)
     {
      dist=ask<=media.Main(0);
      if(gv.Get("close_sell_sec")==1.0 && saida_sec>0)
         sec=ask<=media_sec.Main(0);
     }
   if(operacao==Contra)
      bb_exit=BB_WID_Buff[1]>BB_WID_Buff[2] && BB_WID_Buff[0]>InpNivel2;
   else
      bb_exit=BB_WID_Buff[1]<BB_WID_Buff[2] && BB_WID_Buff[0]<InpNivel2;

   return (dist || sec||bb_exit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AfastMedia::CheckBuyClose()
  {
   bool bb_exit,dist;
   dist=false;
   bool sec=false;
   if(operacao==Contra)
     {
      dist=bid>=media.Main(0);
      if(gv.Get("close_buy_sec")==1.0 && saida_sec>0)
         sec=bid>=media_sec.Main(0);
     }
   if(operacao==Contra)
      bb_exit=BB_WID_Buff[1]>BB_WID_Buff[2] && BB_WID_Buff[0]>InpNivel2;
   else
      bb_exit=BB_WID_Buff[1]<BB_WID_Buff[2] && BB_WID_Buff[0]<InpNivel2;
   return (dist || sec||bb_exit);
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
      default:
         filter=false;
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

void OnTimer()
  {
   MyAfastMed.OnTimer();
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   if((!MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_TESTER)) || MQLInfoInteger(MQL_VISUAL_MODE))
     {
      if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
         return(INIT_PARAMETERS_INCORRECT);
      //--- run application 

      ExtDialog.Run();
     }

   return MyAfastMed.OnInit();


//---

//---
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   MyAfastMed.OnDeinit(reason);
   if((!MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_TESTER)) || MQLInfoInteger(MQL_VISUAL_MODE)) ExtDialog.Destroy(reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   MyAfastMed.OnTick();
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

   color cor_labels=clrDeepSkyBlue;

   string str_pos;
   if(!MyAfastMed.PosicaoAberta())str_pos="Zerado";
   if(MyAfastMed.Buy_opened())str_pos="Comprado";
   if(MyAfastMed.Sell_opened())str_pos="Vendido";

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Posição: "+str_pos,xx1,yy1,xx2,yy2))
      return(false);
   m_label[0].Color(cor_labels);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;


   string str_vol_pos;
   if(!MyAfastMed.PosicaoAberta())str_vol_pos="-";
   if(MyAfastMed.Buy_opened())str_vol_pos=DoubleToString(MyAfastMed.VolPosType(POSITION_TYPE_BUY),2);
   if(MyAfastMed.Sell_opened())str_vol_pos=DoubleToString(MyAfastMed.VolPosType(POSITION_TYPE_SELL),2);

   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"Volume: "+str_vol_pos,xx1,yy1,xx2,yy2))
      return(false);
   m_label[1].Color(cor_labels);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;


   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"Resultado Mensal: "+MyAfastMed.GetCurrency()+" "+DoubleToString(MyAfastMed.LucroTotalMes(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[2].Color(cor_labels);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+3*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"Resultado Semanal: "+MyAfastMed.GetCurrency()+" "+DoubleToString(MyAfastMed.LucroTotalSemana(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[3].Color(cor_labels);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+4*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],"Resultado Diário: "+MyAfastMed.GetCurrency()+" "+DoubleToString(MyAfastMed.LucroTotal(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[4].Color(cor_labels);

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyPanel::OnTick(void)
  {

   string str_pos;
   if(!MyAfastMed.PosicaoAberta())str_pos="Zerado";
   if(MyAfastMed.Buy_opened())str_pos="Comprado";
   if(MyAfastMed.Sell_opened())str_pos="Vendido";

   string str_vol_pos;
   if(!MyAfastMed.PosicaoAberta())str_vol_pos="-";
   if(MyAfastMed.Buy_opened())str_vol_pos=DoubleToString(MyAfastMed.VolPosType(POSITION_TYPE_BUY),2);
   if(MyAfastMed.Sell_opened())str_vol_pos=DoubleToString(MyAfastMed.VolPosType(POSITION_TYPE_SELL),2);

   m_label[0].Text("Posição: "+str_pos);
   m_label[1].Text("Volume: "+str_vol_pos);
   m_label[2].Text("Resultado Mensal: "+MyAfastMed.GetCurrency()+" "+DoubleToString(MyAfastMed.LucroTotalMes(),2));
   m_label[3].Text("Resultado Semanal: "+MyAfastMed.GetCurrency()+" "+DoubleToString(MyAfastMed.LucroTotalSemana(),2));
   m_label[4].Text("Resultado Diário: "+MyAfastMed.GetCurrency()+" "+DoubleToString(MyAfastMed.LucroTotal(),2));

  }
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(MyPanel)

EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
