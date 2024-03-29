//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#define VALIDADE   D'2100.12.31 23:59:59'//Data de Validade ano.mes.dia horas:minutos:segundos(opcional)
#define NUMERO_CONTA 9011600   //Numero da conta
#define ONLY_DEMO "SIM" //"SIM"- Somente em Demo,"NAO"- liberado para conta Real


#resource "\\Indicators\\Indicador BOLA.ex5"
#resource "\\Indicators\\wpr_histogram.ex5"
#resource "\\Indicators\\stochastic_histogram.ex5"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include<ChartObjects\ChartObjectsLines.mqh>
#include <Controls\Defines.mqh>
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
//#undef CONTROLS_LABEL_COLOR  

color borda_bg=clrWhite;//Cor Borda
color painel_bg=clrWhite;//Cor Painel 
color cor_txt_borda_bg=clrBlack;//Cor Texto Borda
                                //color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG          borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg

#include <Expert_Class_New.mqh>
MyPanel ExtDialog;

CLabel            m_label[50];
CLabel            label_cotacao[50];
CLabel            label_porc[50];

#define LARGURA_PAINEL 310 // Largura Painel
#define ALTURA_PAINEL 420 // Altura Painel




// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input string simbolo="";//Símbolo Original (vazio = atual)
input int MAGIC_NUMBER=7022019;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
sinput string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input double Lot=1;//Lote Entrada
input double _Stop=100;//Stop Loss em Pontos
input double _TakeProfit=100;//Take Profit em Pontos
input bool ReverterSig=false;//Reverter no Sinal Contrário
input bool Inverter=false;//Inverter Sinal
input bool UsarSoBola=false;//Usar Somente o Indicador Bola
input int n_minutes=0;//Número de Minutos de Pausa em Consolidação
sinput string sseg="###-------------Segurança Posições-------------#####";    //Segurança Posições
input int n_seconds=5;//Segundos para Fechar Posição Sem Stop Loss
sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia

sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário
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
sinput string sind="----------Indicadores-----------------------";//Indicadores
sinput string sindbola="-------------------BOLA-----------------------";//BOLA
input int RISK=4;
input double AtrRatio=0.24;  // коэфициент ATR удаления NRTR
input int Shift=0; //сдвиг индикатора по горизонтали в барах 

sinput string sindwpr="-------------------WPR-----------------------";//WPR
input uint                 WPRPeriod=14;         // ïåðèîä èíäèêàòîðà
input int                  HighLevel=-30;        // óðîâåíü ïåðåêóïëåííîñòè
input int                  LowLevel=-70;         // óðîâåíü ïåðåïðîäàííîñòè
input int                  Shift_WPR=0;              // Ñäâèã èíäèêàòîðà ïî ãîðèçîíòàëè â áàðàõ
sinput string sindstoc="-------------------Stochastic-----------------------";//Stochastic
input int KPeriod=5;
input int DPeriod=3;
input int Slowing=3;
input ENUM_MA_METHOD MA_Method=MODE_SMA;
input ENUM_STO_PRICE Price_field=STO_LOWHIGH;
input uint HighLevelSTO=60;                       // óðîâåíü ïåðåêóïëåííîñòè
input uint LowLevelSTO=40;                        // óðîâåíü ïåðåïðîäàííîñòè
input int ShiftSTO=0;                             // Ñäâèã èíäèêàòîðà ïî ãîðèçîíòàëè â áàðàõ



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


sinput string srealp="############------------------------Realização Parcial-------------------------------#################";//Realização Parcial
input double rp1=0;//Pontos R.P 1 (0 Não Usar)
input double _lts_rp1=25;//Porcentagem Lotes R.P 1
input double rp2=0;//Pontos R.P 2 (0 Não Usar)
input double _lts_rp2=25;//Porcentagem Lotes R.P 2
input double rp3=0;//Pontos R.P 3 (0 Não Usar)
input double _lts_rp3=0;//Porcentagem Lotes R.P 3

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
class MyRobot: public MyExpert
  {
private:
   CChartObjectHLine HLine_Entrada,HLine_SL,HLine_TP;
   CChartObjectHLine HLine_Break[5];
   CChartObjectHLine HLine_EntCont[6];
   CChartObjectHLine HLine_EntFav[4];

   string            currency_symbol;
   double            sl,tp,price_open;
   int               bola_handle,wpr_handle,sto_handle;
   double            TrailProfitMin;//Lucro Mínimo em Moeda para Iniciar Trailing
   double            TrailPerc;//Porcentagem Retração do Lucro para Fechar Posição
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   double            vol_pos,vol_stp,preco_stp;
   double            sl_position,tp_position;
   bool              opt_tester;
   double            PointBreakEven[5];
   double            PointProfit[5];
   double            Besos_Down[],Besos_Up[];
   double            Wpr_Color[];
   double            Main_Sto[],Signal_Sto[];
   bool              buy_signal,sell_signal;
   bool              trade_buy,trade_sell;
   string            last_trade;
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
   double            PrecoOrdAbCmt(const string cmt);
   double            StopLoss();
   double            TakeProfit();
   double            VolOrdAbert();
   void              CriandoTagPreco(color cor,string name_tag,double alvo);
   void              CreateLinesBreakBuy(double preco);
   void              CreateLinesBreakSell(double preco);
   void              CreateLinesContraBuy(double preco);
   void              CreateLinesContraSell(double preco);
   void              CreateLinesFavorBuy(double preco);
   void              CreateLinesFavorSell(double preco);
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
int MyRobot::OnInit(void)
  {

   ulong numero_conta=NUMERO_CONTA;
   datetime expiracao=VALIDADE;
   string msg_validade="Validade até "+TimeToString(expiracao)+" para a conta "+IntegerToString(numero_conta)+" "+myaccount.Server();
   MessageBox(msg_validade);
   Print(msg_validade);
   bool licenca=TimeCurrent()>expiracao || myaccount.Login()!=numero_conta;
   if(licenca)
     {
      string erro="Licença Inválida";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(ONLY_DEMO=="SIM" && AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO)
     {
      string erro="EA permitido apenas em conta DEMO";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   trade_sell=true;
   trade_buy=true;
   last_trade="NEUTRO";
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

   bola_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\Indicador BOLA.ex5",RISK,AtrRatio,Shift);

   ChartIndicatorAdd(curChartID,0,bola_handle);

   wpr_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\wpr_histogram.ex5",WPRPeriod,HighLevel,LowLevel,Shift_WPR);
//ulong wpr_chart=ChartGetInteger(curChartID,CHART_WINDOWS_TOTAL);
   ChartIndicatorAdd(curChartID,(int)ChartGetInteger(curChartID,CHART_WINDOWS_TOTAL),wpr_handle);
   sto_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\stochastic_histogram.ex5",KPeriod,DPeriod,Slowing,MA_Method,Price_field,HighLevelSTO,LowLevelSTO,ShiftSTO);

   ChartIndicatorAdd(curChartID,(int)ChartGetInteger(curChartID,CHART_WINDOWS_TOTAL),sto_handle);

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ArraySetAsSeries(Besos_Down,true);
   ArraySetAsSeries(Besos_Up,true);
   ArraySetAsSeries(Wpr_Color,true);
   ArraySetAsSeries(Main_Sto,true);
   ArraySetAsSeries(Signal_Sto,true);

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

   return(INIT_SUCCEEDED);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTimer()
  {
   trade_buy=true;
   trade_sell=true;
   EventKillTimer();
   Print("Pausa de "+IntegerToString(n_minutes)+" minutos finalizada. Novas Entradas Permitidas");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   IndicatorRelease(bola_handle);
   IndicatorRelease(wpr_handle);
   IndicatorRelease(sto_handle);

   DeletaIndicadores();
  };
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
      trade_sell=true;
      trade_buy=true;
      last_trade="NEUTRO";
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
      int k=ObjectsDeleteAll(0,"",0,OBJ_HLINE);
      int j=ObjectsDeleteAll(0,"",0,OBJ_BUTTON);
      gv.Set("preco_break",0.0);
     }
   else
     {
      //     if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);
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

      SegurancaPos(n_seconds);
      if(Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo))
        {

         if(GetIndValue())
           {
            Print("Error in obtain indicators buffers or price rates");
            return;
           }

         buy_signal=BuySignal() && !PosicaoAberta();
         sell_signal=SellSignal() && !PosicaoAberta();

         if(ReverterSig)
           {
            buy_signal=BuySignal() && !Buy_opened();
            sell_signal=SellSignal() && !Sell_opened();
           }

         if(Inverter)
           {
            bool auxsig=buy_signal;
            buy_signal=sell_signal;
            sell_signal=auxsig;
           }

         if(ReverterSig)
           {
            buy_signal=buy_signal && trade_buy;
            sell_signal=sell_signal && trade_sell;
           }

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
bool MyRobot::GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(bola_handle,2,0,5,Besos_Up)<=0 || 
         CopyBuffer(bola_handle,3,0,5,Besos_Down)<=0 || 
         CopyBuffer(wpr_handle,2,0,5,Wpr_Color)<=0 || 
         CopyBuffer(sto_handle,0,0,5,Main_Sto)<=0 || 
         CopyBuffer(sto_handle,1,0,5,Signal_Sto)<=0 || 
         CopyHigh(Symbol(),period,0,5,high)<=0 ||
         CopyOpen(Symbol(),period,0,5,open)<=0 ||
         CopyLow(Symbol(),period,0,5,low)<=0 || 
         CopyClose(Symbol(),period,0,5,close)<=0;

   return(b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::StopLoss()
  {
   double _sl=0;
   if(PosicaoAberta())_sl=gv.Get("sl_position");
   return _sl;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::TakeProfit()
  {
   double _tp=0;
   if(PosicaoAberta())
      _tp=PrecoOrdAbCmt("TAKE PROFIT");
   return _tp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::PrecoOrdAbCmt(const string cmt)
  {
   double preco=0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.Comment()==cmt)
               preco=myorder.PriceOpen();
   return preco;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::VolOrdAbert()
  {
   double volume=0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            volume+=myorder.VolumeCurrent();
   return volume;
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
   bool signal,wpr_sig,sto_sig;
   wpr_sig=Wpr_Color[1]==0.0;
   sto_sig=Main_Sto[1]>Signal_Sto[1];
   signal=Besos_Up[1]>0;
   if(!UsarSoBola) signal=signal && wpr_sig && sto_sig;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal,wpr_sig,sto_sig;
   wpr_sig=Wpr_Color[1]==2.0;
   sto_sig=Main_Sto[1]<Signal_Sto[1];
   signal=Besos_Down[1]>0;
   if(!UsarSoBola) signal=signal && wpr_sig && sto_sig;
   return signal;
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
               gv.Set("last_deal_time",(double)HistoryDealGetInteger(ticket_history_deal,DEAL_TIME));
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

               if(ReverterSig && last_trade=="SELL" && n_minutes>0)
                 {
                  trade_sell=false;
                  EventSetTimer(n_minutes*60);
                 }
               last_trade="BUY";
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

            if(mydeal.Comment()=="SELL"+exp_name)
              {
               if(ReverterSig && last_trade=="BUY" && n_minutes>0)
                 {
                  trade_buy=false;
                  EventSetTimer(n_minutes*60);
                 }
               last_trade="SELL";

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

            if((mydeal.DealType()==DEAL_TYPE_BUY || mydeal.DealType()==DEAL_TYPE_SELL) && (mydeal.Entry()==DEAL_ENTRY_OUT))
              {
               if(mydeal.Profit()<0)
                 {
                  Print("Saída por STOP LOSS");
                  Print("Pausa de "+IntegerToString(n_minutes)+" minutos Interrompida. Novas Entradas Permitidas");
                  EventKillTimer();
                  trade_buy=true;
                  trade_sell=true;
                 }

               if(mydeal.Profit()>0)
                 {
                  Print("Saída no GAIN");
                  if(UseBreakEven && gv.Get("preco_break")>0 && mydeal.Price()>=gv.Get("preco_break"))
                    {
                     Print("break Even. Pausa de "+IntegerToString(n_minutes)+" minutos Interrompida. Novas Entradas Permitidas");
                     EventKillTimer();
                     trade_buy=true;
                     trade_sell=true;
                    }
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
         preco_stp=myorder.PriceOpen();

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
void MyRobot::CriandoTagPreco(color cor,string name_tag,double alvo)
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
void MyRobot::CreateLinesBreakBuy(double preco)
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
void MyRobot::CreateLinesBreakSell(double preco)
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
void MyRobot::CreateLinesContraBuy(double preco)
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
void MyRobot::CreateLinesContraSell(double preco)
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
void MyRobot::CreateLinesFavorBuy(double preco)
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
void MyRobot::CreateLinesFavorSell(double preco)
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
int OnInit()
  {
   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
      return(INIT_FAILED);
//--- run application 

   ExtDialog.Run();
   ExtDialog.Caption(Symbol()+" - "+SymbolInfoString(Symbol(),SYMBOL_DESCRIPTION));

   ChartSetInteger(ChartID(),CHART_COLOR_BACKGROUND,clrDarkBlue);
   ChartSetInteger(ChartID(),CHART_COLOR_FOREGROUND,clrWhite);
   ChartSetInteger(ChartID(),CHART_COLOR_GRID,clrLightSlateGray);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_UP,clrMediumSpringGreen);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_DOWN,clrOrangeRed);
   ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BULL,clrMediumSpringGreen);
   ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BEAR,clrOrangeRed);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_LINE,clrLime);
   ChartSetInteger(ChartID(),CHART_COLOR_VOLUME,clrLimeGreen);
   ChartSetInteger(ChartID(),CHART_COLOR_BID,clrLightSlateGray);
   ChartSetInteger(ChartID(),CHART_COLOR_ASK,clrRed);
   ChartSetInteger(ChartID(),CHART_COLOR_LAST,C'0,192,0');
   ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

   if(!ChartSetInteger(ChartID(),CHART_SHIFT,0,50))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }

   return MyEA.OnInit();


//---

//---
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
//---
   MyEA.OnDeinit(reason);
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.Destroy(reason);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   MyEA.OnTimer();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   MyEA.OnTick();
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.OnTick();
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  {
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.ChartEvent(id,lparam,dparam,sparam);
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

   int cotx1,cotx2,porcx1,porcx2;

   int col1=INDENT_LEFT;
   int col2=(int) (0.4*LARGURA_PAINEL)+INDENT_LEFT;
   int col3=(int) (0.7*LARGURA_PAINEL)+INDENT_LEFT;


   cotx1=col2;
   cotx2=col3-INDENT_LEFT;

   porcx1=col3;
   porcx2=LARGURA_PAINEL-INDENT_LEFT;

   double price_last,price_high,price_low,price_open,price_mean;
   double porc_last,porc_high,porc_low,porc_open;
   double fech_ant=iClose(Symbol(),PERIOD_D1,1);
   double dist_ant,amp_dia;
   dist_ant=iClose(Symbol(),PERIOD_D1,0)-fech_ant;
   price_last=SymbolInfoDouble(Symbol(),SYMBOL_LAST);
   price_high=SymbolInfoDouble(Symbol(),SYMBOL_LASTHIGH);
   price_low=SymbolInfoDouble(Symbol(),SYMBOL_LASTLOW);
   price_open=iOpen(Symbol(),PERIOD_D1,0);
   price_mean=MathRound((0.5)*(price_high+price_low)/SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE))*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE);
   price_mean=NormalizeDouble(price_mean,_Digits);
   amp_dia=price_high-price_low;
   porc_last=((price_last-fech_ant)/fech_ant)*100;
   porc_high=((price_high-fech_ant)/fech_ant)*100;
   porc_low=((price_low-fech_ant)/fech_ant)*100;
   porc_open=((price_open-fech_ant)/fech_ant)*100;

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);

//--- create dependent controls 

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Último: ",xx1,yy1,xx2,yy2))
      return(false);


   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[0],DoubleToString(price_last,_Digits),cotx1,yy1,cotx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_porc[0],DoubleToString(porc_last,2)+"%",porcx1,yy1,porcx2,yy2))
      return(false);


   xx1=col1;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;


   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"Abertura: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[1],DoubleToString(price_open,_Digits),cotx1,yy1,cotx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_porc[1],DoubleToString(porc_open,2)+"%",porcx1,yy1,porcx2,yy2))
      return(false);


   xx1=col1;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"Máxima: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[2],DoubleToString(price_high,_Digits),cotx1,yy1,cotx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_porc[2],DoubleToString(porc_high,2)+"%",porcx1,yy1,porcx2,yy2))
      return(false);

   xx1=col1;
   yy1=INDENT_TOP+3*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"Mínima: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[3],DoubleToString(price_low,_Digits),cotx1,yy1,cotx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_porc[3],DoubleToString(porc_low,2)+"%",porcx1,yy1,porcx2,yy2))
      return(false);


   xx1=col1;
   yy1=INDENT_TOP+4*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],"Média: ",xx1,yy1,xx2,yy2))
      return(false);


   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[4],DoubleToString(price_mean,_Digits),cotx1,yy1,cotx2,yy2))
      return(false);


   xx1=col1;
   yy1=2*INDENT_TOP+5*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[5],"Fechamento Dia Anterior: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[5],DoubleToString(fech_ant,_Digits),porcx1,yy1,porcx2,yy2))
      return(false);




   xx1=col1;
   yy1=2*INDENT_TOP+6*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[6],"Distância Dia Anterior: ",xx1,yy1,xx2,yy2))
      return(false);


   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[6],DoubleToString(dist_ant,_Digits),porcx1,yy1,porcx2,yy2))
      return(false);




   xx1=col1;
   yy1=2*INDENT_TOP+7*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[7],"Amplitude Dia: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[7],DoubleToString(amp_dia,_Digits),porcx1,yy1,porcx2,yy2))
      return(false);


   xx1=col1;
   yy1=3*INDENT_TOP+8*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[8],"Posição: ",xx1,yy1,xx2,yy2))
      return(false);


   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[8],"",cotx1,yy1,cotx2,yy2))
      return(false);



   xx1=col1;
   yy1=3*INDENT_TOP+9*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[9],"Preço: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[9],"",cotx1,yy1,cotx2,yy2))
      return(false);
   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[10],"",porcx1,yy1,porcx2,yy2))
      return(false);



   xx1=col1;
   yy1=3*INDENT_TOP+10*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[10],"Volume: ",xx1,yy1,xx2,yy2))
      return(false);
   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[11],"",cotx1,yy1,cotx2,yy2))
      return(false);


   xx1=col1;
   yy1=3*INDENT_TOP+11*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[11],"Profit: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[12],"",cotx1,yy1,cotx2,yy2))
      return(false);
   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[13],"",porcx1,yy1,porcx2,yy2))
      return(false);



   xx1=col1;
   yy1=3*INDENT_TOP+12*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[12],"Pontos: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[14],"",cotx1,yy1,cotx2,yy2))
      return(false);
   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[15],"",porcx1,yy1,porcx2,yy2))
      return(false);


   xx1=col1;
   yy1=4*INDENT_TOP+13*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[13],"Volume Ordens Pedentes: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[16],"",porcx1,yy1,porcx2,yy2))
      return(false);



   xx1=col1;
   yy1=5*INDENT_TOP+14*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[14],"Resultado Mensal: ",xx1,yy1,xx2,yy2))
      return(false);
   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[17],"",porcx1,yy1,porcx2,yy2))
      return(false);


   xx1=col1;
   yy1=5*INDENT_TOP+15*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[15],"Resultado Diário: ",xx1,yy1,xx2,yy2))
      return(false);
   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[18],"",porcx1,yy1,porcx2,yy2))
      return(false);


//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyPanel::OnTick(void)
  {
   double price_last,price_high,price_low,price_open,price_mean;
   double porc_last,porc_high,porc_low,porc_open;
   double fech_ant=iClose(Symbol(),PERIOD_D1,1);
   double dist_ant,amp_dia;
   dist_ant=iClose(Symbol(),PERIOD_D1,0)-fech_ant;
   price_last = SymbolInfoDouble(Symbol(), SYMBOL_LAST);
   price_high = SymbolInfoDouble(Symbol(), SYMBOL_LASTHIGH);
   price_low=SymbolInfoDouble(Symbol(),SYMBOL_LASTLOW);
   price_open = iOpen(Symbol(), PERIOD_D1, 0);
   price_mean = MathRound((0.5) * (price_high + price_low) / SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE)) * SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   price_mean = NormalizeDouble(price_mean, _Digits);
   amp_dia=price_high-price_low;
   porc_last = ((price_last - fech_ant) / fech_ant) * 100;
   porc_high = ((price_high - fech_ant) / fech_ant) * 100;
   porc_low=((price_low-fech_ant)/fech_ant)*100;
   porc_open = ((price_open - fech_ant) / fech_ant) * 100;
   for(int i = 0; i < 8; i++)
      label_cotacao[i].Color(clrGreen);

   for(int i=0; i<4; i++)
      label_porc[i].Color(clrGreen);
   label_cotacao[0].Text(DoubleToString(price_last,_Digits));
   if(price_last<fech_ant)
      label_cotacao[0].Color(clrRed);
   label_porc[0].Text(DoubleToString(porc_last,2)+"%");
   if(porc_last<0)
      label_porc[0].Color(clrRed);
   label_cotacao[1].Text(DoubleToString(price_open, _Digits));
   if(price_open<fech_ant)
      label_cotacao[1].Color(clrRed);
   label_porc[1].Text(DoubleToString(porc_open,2)+"%");
   if(porc_open<0)
      label_porc[1].Color(clrRed);
   label_cotacao[2].Text(DoubleToString(price_high, _Digits));
   if(price_high<fech_ant)
      label_cotacao[2].Color(clrRed);
   label_porc[2].Text(DoubleToString(porc_high,2)+"%");
   if(porc_high<0)
      label_porc[2].Color(clrRed);
   label_cotacao[3].Text(DoubleToString(price_low, _Digits));
   if(price_low<fech_ant)
      label_cotacao[3].Color(clrRed);
   label_porc[3].Text(DoubleToString(porc_low,2)+"%");
   if(porc_low<0)
      label_porc[3].Color(clrRed);
   label_cotacao[4].Text(DoubleToString(price_mean, _Digits));
   if(price_mean<fech_ant)
      label_cotacao[4].Color(clrRed);
   label_cotacao[5].Text(DoubleToString(fech_ant, _Digits));
   label_cotacao[6].Text(DoubleToString(dist_ant, _Digits));
   if(dist_ant<0)
      label_cotacao[6].Color(clrRed);
   label_cotacao[7].Text(DoubleToString(amp_dia,_Digits));
   if(price_last<fech_ant)
      label_cotacao[7].Color(clrRed);

   string s_pos;
   if(MyEA.Buy_opened())
     {
      s_pos="COMPRA";
      label_cotacao[8].Color(clrGreen);
     }
   else if(MyEA.Sell_opened())
     {
      s_pos="VENDA";
      label_cotacao[8].Color(clrRed);
     }
   else s_pos="ZERADO";

   label_cotacao[8].Text(s_pos);
   double preco_medio=MyEA.PrecoMedio(POSITION_TYPE_BUY)+MyEA.PrecoMedio(POSITION_TYPE_SELL);
   string s_medio=DoubleToString(preco_medio,_Digits);
   label_cotacao[9].Text(s_medio);
   label_cotacao[9].Color(clrGreen);
   double por_preco_medio=0.0;
   if(preco_medio!=0) por_preco_medio=((preco_medio-fech_ant)/fech_ant)*100;

   label_cotacao[10].Text(DoubleToString(por_preco_medio,2)+"%");
   if(por_preco_medio>=0)label_cotacao[10].Color(clrGreen);
   else  label_cotacao[10].Color(clrRed);

   double vol_pos=0.0;
   if(MyEA.PosicaoAberta())vol_pos=MyEA.VolPosType(POSITION_TYPE_BUY)+MyEA.VolPosType(POSITION_TYPE_SELL);
   label_cotacao[11].Text(DoubleToString(vol_pos,2));
   label_cotacao[11].Color(clrGreen);
   double profit_pos=MyEA.LucroPositions();
   label_cotacao[12].Text(DoubleToString(profit_pos,2));
   if(profit_pos>=0)label_cotacao[12].Color(clrGreen);
   else label_cotacao[12].Color(clrRed);

   label_cotacao[13].Text("SL: "+DoubleToString(MyEA.StopLoss(),_Digits));
   label_cotacao[13].Color(clrRed);
   double s_pontos=0;
   if(MyEA.Buy_opened())s_pontos=price_last-preco_medio;
   if(MyEA.Sell_opened())s_pontos=preco_medio-price_last;

   label_cotacao[14].Text(DoubleToString(s_pontos,_Digits));
   if(s_pontos>=0)label_cotacao[14].Color(clrGreen);
   else label_cotacao[14].Color(clrRed);
   label_cotacao[15].Text("TP: "+DoubleToString(MyEA.TakeProfit(),_Digits));
   label_cotacao[15].Color(clrGreen);
   label_cotacao[16].Text(DoubleToString(MyEA.VolOrdAbert(),2));
   label_cotacao[17].Text(DoubleToString(MyEA.LucroTotalMes(),2));
   label_cotacao[18].Text(DoubleToString(MyEA.LucroTotal(),2));
  }
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(MyPanel)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
