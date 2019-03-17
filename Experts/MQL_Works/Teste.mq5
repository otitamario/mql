

#resource "\\Indicators\\LS3RATIO_V2.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Operacao
  {
   Subtract=1,  //Diferença
   Add=2,       //Soma
   Multiply=3,  //Produto
   Divizion=4   //Razão
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Reentradas
  {
   ReentInicio,//Reentrar nos Ratios Salvos no Início da Operação
   ReentAtual // Reentrar nos Ratios Atuais
  };

#include<ChartObjects\ChartObjectsLines.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>
#include <ChartObjects\ChartObjectsBmpControls.mqh>

#include <Controls\Defines.mqh>
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
//#undef CONTROLS_LABEL_COLOR  

color borda_bg=clrNONE;//Cor Borda
color painel_bg=clrBlack;//Cor Painel 
color cor_txt_borda_bg=clrYellowGreen;//Cor Texto Borda
                                      //color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG          borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg

#include <Expert_Class_LS.mqh>
#include <statistics.mqh>



#define LARGURA_PAINEL 300 // Largura Painel
#define ALTURA_PAINEL 320 // Altura Painel

#define X_LABEL 11 
#define Y_LABEL 15 



// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input int MAGIC_NUMBER=20082018;
input string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input double Financeiro=100000;//Valor Financeiro para Entrada
datetime BeginTime=D'1970.01.01'; //Data inicial para Indicador
input string   SimboloA="PETR4";//Ativo Adicional 
string SimboloB=Symbol();
input Operacao Action=Divizion;         //Operacao

input int   Periodo=40; // Período da MM.

input double   DesvioPerna1=2; // Desvio Banda 1
input double   DesvioPerna2=3; // Desvio Banda 2
input double   DesvioPerna3=4; // Desvio Banda 3
input int StopTemporal=20;//Dias de Operação para Stop 
input Reentradas Tipo_Reent=ReentInicio;//Selecionar Reentradas
input double Perc_SLFin=2; // Stop Loss Percentual por Financeiro
input double Perc_TPFin=2; // Take Profit Percentual por Financeiro
input bool NaoOperarMaisNoDiaNoSL=true; // Não operar mais no dia no caso de SL

input string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="10:00";//Horario Inicial
input string end_hour="16:45";//Horario Final
input bool daytrade=false;//Fechar Posição Daytrade ao Fim do Horario
sinput string sdias="FILTRO DOS DIAS DA SEMANA";//Dias da Semana
input bool trade0=true;// Operar Domingo
input bool trade1=true;// Operar Segunda
input bool trade2=true;// Operar Terça
input bool trade3=true;// Operar Quarta
input bool trade4=true;// Operar Quinta
input bool trade5=true;// Operar Sexta
input bool trade6=true;// Operar Sábado
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int               dias_op,horas_op,minut_op,sec_op;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyRobot: public MyExpert
  {
private:
   CChartObjectHLine HLine_Perna1,HLine_Perna2,HLine_Perna3;
   //  CChartObjectEdit  Retangulo;
   CChartObjectRectLabel Retangulo;
   CChartObjectBmpLabel FotoLess;
   CChartObjectButton BotaoFechar;
   CChartObjectLabel LabelLucro;
   CChartObjectLabel LabelPailnel[50];
   CChartObjectLabel LabelVersao;
   string            currency_symbol;
   double            sl,tp,price_open;
   int               bol_handle;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   CSymbolInfo       mysymbolA,mysymbolB;
   double            loteA,loteB;
   bool              check_marginA,check_marginB;
   double            margin_A,margin_B;
   double            closeA[],closeB[],ratio[],ratio_ant[],ratio_total[];
   double            media,desviopadrao,media_ant,desviopadrao_ant;
   double            Boll_Sup[2],Boll_Inf[2],Boll_Sup2[2],Boll_Inf2[2],Boll_Sup3[2],Boll_Inf3[2];
   bool              Error_Init;
   int               subcharBoll;
   bool              tradebar;
public:
   void              MyRobot();
   void             ~MyRobot();
   int               OnInit();
   void              OnDeinit(const int reason);
   void              OnTick();
   void              OnTimer();

   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);

   string GetCurrency(){return SymbolInfoString(original_symbol,SYMBOL_CURRENCY_BASE);}
   bool              TimeDayFilter();
   bool              UpperSignalEntry();
   bool              LowerSignalEntry();
   bool              LowerL2Entry();
   bool              LowerL3Entry();
   bool              UpperH2Entry();
   bool              UpperH3Entry();
   bool              PosicaoAberta_SymbolA();
   bool              PosicaoAberta_SymbolB();
   void              CheckClose();
   double            CalculoLote(double valor,double price,double lotemin);
   void              ClosePos_AB();
   double            LucroAberto();
   void              LOAD_DATA();
   int               CheckLoadHistory(string symbol,ENUM_TIMEFRAMES period,datetime start_date);
   void              AtualizaTimeOp();
   void              CreatePanel();
   void              PanelUpdate();
   double            CalcularFinanceiroPosicoes();
   bool              MyOrderCalcMargin(const ENUM_ORDER_TYPE action,const string marg_symbol,const double volume,const double price,double &margin);
   bool              PosicaoAberta();
   double            PrecoMedio(ENUM_POSITION_TYPE ptype);
   double            VolPosType(ENUM_POSITION_TYPE ptype);
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

   if(!TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED))
      Alert("Notificações PUSH não autorizadas! Configurar no Terminal se quiser receber notificações");

   EventSetTimer(60);
   Error_Init=true;
   LOAD_DATA();

   tradeOn=true;
   setExpName();
   setSymbol(Symbol());
   setOriginalSymbol(Symbol());
   setMagic(MAGIC_NUMBER);
   if(SymbolInfoInteger(SimboloA,SYMBOL_EXPIRATION_MODE)==2)order_time_type=1;
   else order_time_type=0;
   mysymbolA.Name(SimboloA);
   mysymbolB.Name(SimboloB);
   mytrade.SetExpertMagicNumber(MAGIC_NUMBER);
   mytrade.SetDeviationInPoints(50);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
   mytrade.SetTypeFillingBySymbol(original_symbol);
   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);

   gv.Init(SimboloA+SimboloB,Magic_Number);
   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today_prev",(double)TimeNow.day_of_year);
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   setNameGvOrder();

   long curChartID=ChartID();

   bol_handle=iCustom(_Symbol,PERIOD_CURRENT,"::Indicators\\LS3RATIO_V2.ex5",BeginTime,SimboloA,SimboloB,Action,
                      Periodo,DesvioPerna1,DesvioPerna2,DesvioPerna3);

   subcharBoll=(int)ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL);
   ChartIndicatorAdd(curChartID,subcharBoll,bol_handle);

   ArraySetAsSeries(closeA,true);
   ArraySetAsSeries(closeB,true);
   ArraySetAsSeries(ratio,true);
   ArraySetAsSeries(ratio_ant,true);
   ArraySetAsSeries(ratio_total,true);

   ArrayResize(closeA,Periodo+1);
   ArrayResize(closeB,Periodo+1);
   ArrayResize(ratio,Periodo);
   ArrayResize(ratio_ant,Periodo);
   ArrayResize(ratio_total,Periodo+1);

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
      return (INIT_PARAMETERS_INCORRECT);
     }

   if(Perc_SLFin<0 || Perc_SLFin>100)
     {
      string erro="Stop Loss Percentual deve ser um número entre 0 e 100";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }
   if(Perc_TPFin<0 || Perc_TPFin>100)
     {
      string erro="TAke Profit Percentual deve ser um número entre 0 e 100";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   if(DesvioPerna1>=DesvioPerna2 || DesvioPerna1>=DesvioPerna3 || DesvioPerna2>=DesvioPerna3)
     {
      string erro="Desvios Padrão das Bandas devem estar em ordem crescente";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   if(!MQLInfoInteger(MQL_OPTIMIZATION))CreatePanel();

   return (INIT_SUCCEEDED);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTimer()
  {
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   DeletaIndicadores();

// Motivo da desinicialização do EA
   printf("Deinit reason: %d",reason);
   ObjectsDeleteAll(0,0,OBJ_HLINE);
   ObjectsDeleteAll(0,0,OBJ_BUTTON);
   ObjectsDeleteAll(0,0,OBJ_LABEL);
   ObjectsDeleteAll(0,0,OBJ_BITMAP_LABEL);
   ObjectsDeleteAll(0,0,OBJ_RECTANGLE_LABEL);
   EventKillTimer();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTick(void)
  {

   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today",(double)TimeNow.day_of_year);

   bool novodia;
   novodia=Bar_NovoDia.CheckNewBar(SimboloB,PERIOD_D1);
   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      tradeOn=true;
      tradebar=true;
     }

   gv.Set("gv_today_prev",gv.Get("gv_today"));

   mysymbolA.Refresh();
   mysymbolB.Refresh();
   mysymbolA.RefreshRates();
   mysymbolB.RefreshRates();

   if(!mysymbolA.Refresh() || !mysymbolB.Refresh() || !mysymbolA.RefreshRates() || !mysymbolB.RefreshRates())
      return;


   if(mysymbolA.Bid()>mysymbolA.Ask() || mysymbolB.Bid()>mysymbolB.Ask())//Leilão
      return;

   if(mysymbolA.Bid()==0 || mysymbolA.Ask()==0 || mysymbolB.Bid()==0 || mysymbolB.Ask()==0)
      return;


   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   if(CopyClose(SimboloA,PERIOD_CURRENT,0,Periodo+1,closeA)<Periodo+1 || CopyClose(SimboloB,PERIOD_CURRENT,0,Periodo+1,closeB)<Periodo+1)
     {
      Print("Erro copy rates ");
      return;
     }

   switch(Action)
     {
      case   Subtract:
         for(int i=0;i<Periodo+1;i++)ratio_total[i]=closeA[i]-closeB[i];
         break;

      case   Add:
         for(int i=0;i<Periodo+1;i++)ratio_total[i]=closeA[i]+closeB[i];
         break;

      case   Multiply:
         for(int i=0;i<Periodo+1;i++)ratio_total[i]=closeA[i]*closeB[i];
         break;

      case   Divizion:
         for(int i=0;i<Periodo+1;i++)ratio_total[i]=closeA[i]/closeB[i];
         break;
     }

   for(int i=0;i<Periodo;i++)ratio[i]=ratio_total[i];
   for(int i=1;i<Periodo+1;i++)ratio_ant[i-1]=ratio_total[i];

   media=mean(ratio);
   desviopadrao=std(ratio);

   media_ant=mean(ratio_ant);
   desviopadrao_ant=std(ratio_ant);

   Boll_Sup[0]=media+DesvioPerna1*desviopadrao;
   Boll_Inf[0]=media-DesvioPerna1*desviopadrao;

   Boll_Sup2[0]=media+DesvioPerna2*desviopadrao;
   Boll_Inf2[0]=media-DesvioPerna2*desviopadrao;

   Boll_Sup3[0]=media+DesvioPerna3*desviopadrao;
   Boll_Inf3[0]=media-DesvioPerna3*desviopadrao;


   Boll_Sup[1]=media_ant+DesvioPerna1*desviopadrao_ant;
   Boll_Inf[1]=media_ant-DesvioPerna1*desviopadrao_ant;

   Boll_Sup2[1]=media_ant+DesvioPerna2*desviopadrao_ant;
   Boll_Inf2[1]=media_ant-DesvioPerna2*desviopadrao_ant;

   Boll_Sup3[1]=media_ant+DesvioPerna3*desviopadrao_ant;
   Boll_Inf3[1]=media_ant-DesvioPerna3*desviopadrao_ant;


/*  string cotacoes;
   cotacoes="Ratio "+DoubleToString(ratio[0],4)+"\n"+
            "Media "+DoubleToString(media,4)+"\n"+
            "---------------------------------------"+"\n"+
            "Banda Superior 3 "+DoubleToString(Boll_Sup3[0],4)+"\n"+
            "Banda Superior 2 "+DoubleToString(Boll_Sup2[0],4)+"\n"+
            "Banda Superior "+DoubleToString(Boll_Sup[0],4)+"\n"+
            "---------------------------------------"+"\n"+

            "Banda Inferior "+DoubleToString(Boll_Inf[0],4)+"\n"+
            "Banda Inferior 2 "+DoubleToString(Boll_Inf2[0],4)+"\n"+
            "Banda Inferior 3 "+DoubleToString(Boll_Inf3[0],4)+"\n"+
            "---------------------------------------";

   Comment(cotacoes);
 */
   timerOn=true;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
     }

   if(!timerOn && daytrade)
     {
      if(PositionsTotal()>0)ClosePos_AB();
     }

   if(!PosicaoAberta_SymbolA() && !PosicaoAberta_SymbolB())
     {
      gv.Set("pos_ab",0.0);
      gv.Set("pos_perna2",0.0);
      gv.Set("pos_perna3",0.0);
      gv.Set("upper_ent",0.0);
      gv.Set("lower_ent",0.0);
      gv.Set("sl_fin",0.0);
      gv.Set("tp_fin",0.0);
      gv.Set("time_op",0.0);

      gv.Set("Rent_Sell2",0.0);gv.Set("Rent_Sell3",0.0);
      gv.Set("Rent_Buy2",0.0);gv.Set("Rent_Buy3",0.0);
      gv.Set("Rent_Sell1",0.0);
      gv.Set("Rent_Buy1",0.0);

      gv.Set("Val_Perna2_Inf",0.0);
      gv.Set("Val_Perna3_Inf",0.0);
      gv.Set("Val_Perna2_Sup",0.0);
      gv.Set("Val_Perna3_Sup",0.0);

      HLine_Perna1.Delete();
      HLine_Perna2.Delete();
      HLine_Perna3.Delete();

     }

   AtualizaTimeOp();

   if(Tipo_Reent==ReentAtual)
     {
      gv.Set("Val_Perna2_Inf",Boll_Inf2[0]);
      gv.Set("Val_Perna3_Inf",Boll_Inf3[0]);
      gv.Set("Val_Perna2_Sup",Boll_Sup2[0]);
      gv.Set("Val_Perna3_Sup",Boll_Sup3[0]);
     }

   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      if(PosicaoAberta())
        {
         if(gv.Get("lower_ent")==1.0)
           {
            HLine_Perna1.Create(0,"Perna1",subcharBoll,gv.Get("Rent_Buy1"));
            HLine_Perna2.Create(0,"Perna2",subcharBoll,gv.Get("Val_Perna2_Inf"));
            HLine_Perna3.Create(0,"Perna3",subcharBoll,gv.Get("Val_Perna3_Inf"));
            HLine_Perna1.Color(clrLime);
            HLine_Perna2.Color(clrBlue);
            HLine_Perna3.Color(clrRed);
           }
         if(gv.Get("upper_ent")==1.0)
           {
            HLine_Perna1.Create(0,"Perna1",subcharBoll,gv.Get("Rent_Sell1"));
            HLine_Perna2.Create(0,"Perna2",subcharBoll,gv.Get("Val_Perna2_Sup"));
            HLine_Perna3.Create(0,"Perna3",subcharBoll,gv.Get("Val_Perna2_Sup"));
            HLine_Perna1.Color(clrLime);
            HLine_Perna2.Color(clrBlue);
            HLine_Perna3.Color(clrRed);
           }
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(tradeOn && timerOn)

     {// inicio Trade On

      CheckClose();
      if(gv.Get("lower_ent")==1.0 && ratio[0]>=media)
        {
         ClosePos_AB();
         Print("Saída na Média Central");
        }

      if(gv.Get("upper_ent")==1.0 && ratio[0]<=media)
        {
         ClosePos_AB();
         Print("Saída na Média Central");
        }

      if(!tradebar)return;


      if(LowerSignalEntry() && gv.Get("pos_ab")==0.0)//Compra A, Vende B
        {
         loteA=CalculoLote(Financeiro/3,mysymbolA.Ask(),SymbolInfoDouble(SimboloA,SYMBOL_VOLUME_MIN));
         loteB=CalculoLote(Financeiro/3,mysymbolB.Bid(),SymbolInfoDouble(SimboloB,SYMBOL_VOLUME_MIN));

         check_marginB=OrderCalcMargin(ORDER_TYPE_SELL,SimboloB,loteB,mysymbolB.Bid(),margin_B);
         check_marginB=MyOrderCalcMargin(ORDER_TYPE_SELL,SimboloB,loteB,mysymbolB.Bid(),margin_B);

         //margin_A=loteA*mysymbolA.Ask();
         //margin_B=loteB*mysymbolB.Bid();

         if(margin_A+margin_B<=myaccount.Equity())
           {

            if(!myposition.SelectByTicket((ulong)gv.Get(vd_tick)))
               if(mytrade.Sell(loteB,SimboloB,0,0,0,"SELL_LOWER"+exp_name))
                 {
                  gv.Set(vd_tick,(double)mytrade.ResultOrder());
                 }
            if(!myposition.SelectByTicket((ulong)gv.Get(cp_tick)))
               if(mytrade.Buy(loteA,SimboloA,0,0,0,"BUY_LOWER"+exp_name))
                 {
                  gv.Set(cp_tick,(double)mytrade.ResultOrder());
                 }

            if(myposition.SelectByTicket((ulong)gv.Get(cp_tick)) && myposition.SelectByTicket((ulong)gv.Get(vd_tick)))
              {
               gv.Set("pos_ab",1.0);
               gv.Set("lower_ent",1.0);
              }
           }
         else
           {
            Print("Margem Insuficiente");
            return;
           }

        }

      if(UpperSignalEntry() && gv.Get("pos_ab")==0.0)//Vende A, Compra B
        {
         loteA=CalculoLote(Financeiro/3,mysymbolA.Bid(),SymbolInfoDouble(SimboloA,SYMBOL_VOLUME_MIN));
         loteB=CalculoLote(Financeiro/3,mysymbolB.Ask(),SymbolInfoDouble(SimboloB,SYMBOL_VOLUME_MIN));

         check_marginA=OrderCalcMargin(ORDER_TYPE_SELL,SimboloA,loteA,mysymbolA.Bid(),margin_A);
         check_marginB=OrderCalcMargin(ORDER_TYPE_BUY,SimboloB,loteB,mysymbolB.Ask(),margin_B);
         if(margin_A+margin_B<=myaccount.Equity())
           {
            if(!myposition.SelectByTicket((ulong)gv.Get(vd_tick)))
               if(mytrade.Sell(loteA,SimboloA,0,0,0,"SELL_UPPER"+exp_name))
                 {
                  gv.Set(vd_tick,(double)mytrade.ResultOrder());
                 }
            if(!myposition.SelectByTicket((ulong)gv.Get(cp_tick)))
               if(mytrade.Buy(loteB,SimboloB,0,0,0,"BUY_UPPER"+exp_name))
                 {
                  gv.Set(cp_tick,(double)mytrade.ResultOrder());
                 }

            if(myposition.SelectByTicket((ulong)gv.Get(cp_tick)) && myposition.SelectByTicket((ulong)gv.Get(vd_tick)))
              {
               gv.Set("pos_ab",1.0);
               gv.Set("upper_ent",1.0);
              }
           }
         else
           {
            Print("Margem Insuficiente");
            return;
           }

        }

      if(LowerL2Entry() && gv.Get("pos_perna2")==0.0 && gv.Get("pos_ab")==1.0)//Compra A, Vende B
        {
         loteA=CalculoLote(Financeiro/3,mysymbolA.Ask(),SymbolInfoDouble(SimboloA,SYMBOL_VOLUME_MIN));
         loteB=CalculoLote(Financeiro/3,mysymbolB.Bid(),SymbolInfoDouble(SimboloB,SYMBOL_VOLUME_MIN));
         check_marginA=OrderCalcMargin(ORDER_TYPE_BUY,SimboloA,loteA,mysymbolA.Ask(),margin_A);
         check_marginB=OrderCalcMargin(ORDER_TYPE_SELL,SimboloB,loteB,mysymbolB.Bid(),margin_B);
         if(margin_A+margin_B<=myaccount.Equity())
           {
            if(!myposition.SelectByTicket((ulong)gv.Get("vd_perna2")))
               if(mytrade.Sell(loteB,SimboloB,0,0,0,"SELL_L2"+exp_name))
                 {
                  gv.Set("vd_perna2",(double)mytrade.ResultOrder());
                 }
            if(!myposition.SelectByTicket((ulong)gv.Get("cp_perna2")))
               if(mytrade.Buy(loteA,SimboloA,0,0,0,"BUY_L2"+exp_name))
                 {
                  gv.Set("cp_perna2",(double)mytrade.ResultOrder());
                 }

            if(myposition.SelectByTicket((ulong)gv.Get("cp_perna2")) && myposition.SelectByTicket((ulong)gv.Get("vd_perna2")))gv.Set("pos_perna2",1.0);
           }
         else
           {
            Print("Margem Insuficiente");
            return;
           }
        }

      if(UpperH2Entry() && gv.Get("pos_perna2")==0.0 && gv.Get("pos_ab")==1.0)//Vende A, Compra B
        {
         loteA=CalculoLote(Financeiro/3,mysymbolA.Bid(),SymbolInfoDouble(SimboloA,SYMBOL_VOLUME_MIN));
         loteB=CalculoLote(Financeiro/3,mysymbolB.Ask(),SymbolInfoDouble(SimboloB,SYMBOL_VOLUME_MIN));

         check_marginA=OrderCalcMargin(ORDER_TYPE_SELL,SimboloA,loteA,mysymbolA.Bid(),margin_A);
         check_marginB=OrderCalcMargin(ORDER_TYPE_BUY,SimboloB,loteB,mysymbolB.Ask(),margin_B);
         if(margin_A+margin_B<=myaccount.Equity())
           {
            if(!myposition.SelectByTicket((ulong)gv.Get("vd_perna2")))
               if(mytrade.Sell(loteA,SimboloA,0,0,0,"SELL_H2"+exp_name))
                 {
                  gv.Set("vd_perna2",(double)mytrade.ResultOrder());
                 }
            if(!myposition.SelectByTicket((ulong)gv.Get("cp_perna2")))
               if(mytrade.Buy(loteB,SimboloB,0,0,0,"BUY_H2"+exp_name))
                 {
                  gv.Set("cp_perna2",(double)mytrade.ResultOrder());
                 }

            if(myposition.SelectByTicket((ulong)gv.Get("cp_perna2")) && myposition.SelectByTicket((ulong)gv.Get("vd_perna2")))gv.Set("pos_perna2",1.0);

           }
         else
           {
            Print("Margem Insuficiente");
            return;
           }
        }
      if(LowerL3Entry() && gv.Get("pos_perna3")==0.0 && gv.Get("pos_perna2")==1.0 && gv.Get("pos_ab")==1.0)//Compra A, Vende B
        {
         loteA=CalculoLote(Financeiro/3,mysymbolA.Ask(),SymbolInfoDouble(SimboloA,SYMBOL_VOLUME_MIN));
         loteB=CalculoLote(Financeiro/3,mysymbolB.Bid(),SymbolInfoDouble(SimboloB,SYMBOL_VOLUME_MIN));
         check_marginA=OrderCalcMargin(ORDER_TYPE_BUY,SimboloA,loteA,mysymbolA.Ask(),margin_A);
         check_marginB=OrderCalcMargin(ORDER_TYPE_SELL,SimboloB,loteB,mysymbolB.Bid(),margin_B);
         if(margin_A+margin_B<=myaccount.Equity())
           {
            if(!myposition.SelectByTicket((ulong)gv.Get("vd_perna3")))
               if(mytrade.Sell(loteB,SimboloB,0,0,0,"SELL_L3"+exp_name))
                 {
                  gv.Set("vd_perna3",(double)mytrade.ResultOrder());
                 }
            if(!myposition.SelectByTicket((ulong)gv.Get("cp_perna3")))
               if(mytrade.Buy(loteA,SimboloA,0,0,0,"BUY_L3"+exp_name))
                 {
                  gv.Set("cp_perna3",(double)mytrade.ResultOrder());
                 }

            if(myposition.SelectByTicket((ulong)gv.Get("cp_perna3")) && myposition.SelectByTicket((ulong)gv.Get("vd_perna3")))gv.Set("pos_perna3",1.0);
           }
         else
           {
            Print("Margem Insuficiente");
            return;
           }
        }

      if(UpperH3Entry() && gv.Get("pos_perna3")==0.0 && gv.Get("pos_perna2")==1.0 && gv.Get("pos_ab")==1.0)//Vende A, Compra B
        {
         loteA=CalculoLote(Financeiro/3,mysymbolA.Bid(),SymbolInfoDouble(SimboloA,SYMBOL_VOLUME_MIN));
         loteB=CalculoLote(Financeiro/3,mysymbolB.Ask(),SymbolInfoDouble(SimboloB,SYMBOL_VOLUME_MIN));

         check_marginA=OrderCalcMargin(ORDER_TYPE_SELL,SimboloA,loteA,mysymbolA.Bid(),margin_A);
         check_marginB=OrderCalcMargin(ORDER_TYPE_BUY,SimboloB,loteB,mysymbolB.Ask(),margin_B);
         if(margin_A+margin_B<=myaccount.Equity())
           {
            if(!myposition.SelectByTicket((ulong)gv.Get("vd_perna3")))
               if(mytrade.Sell(loteA,SimboloA,0,0,0,"SELL_H3"+exp_name))
                 {
                  gv.Set("vd_perna3",(double)mytrade.ResultOrder());
                 }
            if(!myposition.SelectByTicket((ulong)gv.Get("cp_perna3")))
               if(mytrade.Buy(loteB,SimboloB,0,0,0,"BUY_H3"+exp_name))
                 {
                  gv.Set("cp_perna3",(double)mytrade.ResultOrder());
                 }

            if(myposition.SelectByTicket((ulong)gv.Get("cp_perna3")) && myposition.SelectByTicket((ulong)gv.Get("vd_perna3")))gv.Set("pos_perna3",1.0);
           }
         else
           {
            Print("Margem Insuficiente");
            return;
           }
        }
      if(Bar_NovaBarra.CheckNewBar(Symbol(),PERIOD_M1))ChartRedraw();

     }//End Trade On

   PanelUpdate();

  }//Fim Ontick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+

void MyRobot::LOAD_DATA()
  {
   datetime first_date;
   SeriesInfoInteger(SimboloA,_Period,SERIES_FIRSTDATE,first_date);

   int res=CheckLoadHistory(SimboloA,_Period,first_date);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   switch(res)
     {
      case -1 : Print("Unknown symbol ",SimboloA); Error_Init=true;  break;
      case -2 : Print("Requested bars more than max bars in chart"); Error_Init=true;  break;
      case -3 : Print("Program was stopped");   Error_Init=true;                break;
      case -4 : Print("Indicator shouldn't load its own data");  Error_Init=true;    break;
      case -5 : Print("Load failed");                 Error_Init=true;               break;
      case  0 : Print("Loaded OK");                 Error_Init=false;                 break;
      case  1 : Print("Loaded previously");             Error_Init=false;             break;
      case  2 : Print("Loaded previously and built");          Error_Init=false;      break;
      default : Print("Unknown result");Error_Init=true;
     }

   SeriesInfoInteger(SimboloB,_Period,SERIES_FIRSTDATE,first_date);

   res=CheckLoadHistory(SimboloB,_Period,first_date);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   switch(res)
     {
      case -1 : Print("Unknown symbol ",SimboloB); Error_Init=true;  break;
      case -2 : Print("Requested bars more than max bars in chart"); Error_Init=true;  break;
      case -3 : Print("Program was stopped");   Error_Init=true;                break;
      case -4 : Print("Indicator shouldn't load its own data");  Error_Init=true;    break;
      case -5 : Print("Load failed");                 Error_Init=true;               break;
      case  0 : Print("Loaded OK");                 Error_Init=false;                 break;
      case  1 : Print("Loaded previously");             Error_Init=false;             break;
      case  2 : Print("Loaded previously and built");          Error_Init=false;      break;
      default : Print("Unknown result");Error_Init=true;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::CheckLoadHistory(string Inpsymbol,ENUM_TIMEFRAMES Inpperiod,datetime start_date)
  {
   datetime first_date=0;
   datetime times[100];
//--- verifica ativo e período 
   if(Inpsymbol==NULL || Inpsymbol=="") Inpsymbol=Symbol();
   if(Inpperiod==PERIOD_CURRENT)     Inpperiod=Period();
//--- verifica se o ativo está selecionado no Observador de Mercado 
   if(!SymbolInfoInteger(Inpsymbol,SYMBOL_SELECT))
     {
      if(GetLastError()==ERR_MARKET_UNKNOWN_SYMBOL) return(-1);
      SymbolSelect(Inpsymbol,true);
     }
//--- verifica se os dados estão presentes 
   SeriesInfoInteger(Inpsymbol,Inpperiod,SERIES_FIRSTDATE,first_date);
   if(first_date>0 && first_date<=start_date) return(1);
//--- não pede para carregar seus próprios dados se ele for um indicador 
   if(MQL5InfoInteger(MQL5_PROGRAM_TYPE)==PROGRAM_INDICATOR && Period()==Inpperiod && Symbol()==Inpsymbol)
      return(-4);
//--- segunda tentativa 
   if(SeriesInfoInteger(Inpsymbol,PERIOD_M1,SERIES_TERMINAL_FIRSTDATE,first_date))
     {
      //--- existe dados carregados para construir a série de tempo 
      if(first_date>0)
        {
         //--- força a construção da série de tempo 
         CopyTime(Inpsymbol,Inpperiod,first_date+PeriodSeconds(period),1,times);
         //--- verifica 
         if(SeriesInfoInteger(Inpsymbol,Inpperiod,SERIES_FIRSTDATE,first_date))
            if(first_date>0 && first_date<=start_date) return(2);
        }
     }
//--- máximo de barras em um gráfico a partir de opções do terminal 
   int max_bars=TerminalInfoInteger(TERMINAL_MAXBARS);
//--- carrega informações de histórico do ativo 
   datetime first_server_date=0;
   while(!SeriesInfoInteger(Inpsymbol,PERIOD_M1,SERIES_SERVER_FIRSTDATE,first_server_date) && !IsStopped())
      Sleep(5);
//--- corrige data de início para carga 
   if(first_server_date>start_date) start_date=first_server_date;
   if(first_date>0 && first_date<first_server_date)
      Print("Aviso: primeira data de servidor ",first_server_date," para ",Inpsymbol,
            " não coincide com a primeira data de série ",first_date);
//--- carrega dados passo a passo 
   int fail_cnt=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   while(!IsStopped())
     {
      //--- espera pela construção da série de tempo 
      while(!SeriesInfoInteger(Inpsymbol,Inpperiod,SERIES_SYNCHRONIZED) && !IsStopped())
         Sleep(5);
      //--- pede por construir barras 
      int bars=Bars(Inpsymbol,Inpperiod);
      if(bars>0)
        {
         if(bars>=max_bars) return(-2);
         //--- pede pela primeira data 
         if(SeriesInfoInteger(Inpsymbol,Inpperiod,SERIES_FIRSTDATE,first_date))
            if(first_date>0 && first_date<=start_date) return(0);
        }
      //--- cópia da próxima parte força carga de dados 
      int copied=CopyTime(Inpsymbol,Inpperiod,bars,100,times);
      if(copied>0)
        {
         //--- verifica dados 
         if(times[0]<=start_date)  return(0);
         if(bars+copied>=max_bars) return(-2);
         fail_cnt=0;
        }
      else
        {
         //--- não mais que 100 tentativas com falha 
         fail_cnt++;
         if(fail_cnt>=100) return(-5);
         Sleep(10);
        }
     }
//--- interrompido 
   return(-3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MyRobot::CheckClose()
  {
   if(PosicaoAberta_SymbolA() && PosicaoAberta_SymbolB())
     {
      if(gv.Get("sl_fin")>0.0 && gv.Get("tp_fin")>0.0)
        {
         if(LucroAberto()>=gv.Get("tp_fin"))
           {
            ClosePos_AB();
            Print("Saída TP Percentual");
           }
         if(LucroAberto()<=-gv.Get("sl_fin"))
           {
            if(NaoOperarMaisNoDiaNoSL)tradebar=false;
            ClosePos_AB();
            Print("Saída SL Percentual");
           }

        }
      if(dias_op>=StopTemporal)
        {
         if(LucroAberto()<0 && NaoOperarMaisNoDiaNoSL)tradebar=false;
         ClosePos_AB();
         Print("Sapida após "+IntegerToString(StopTemporal)+" dias");
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::ClosePos_AB()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && (myposition.Symbol()==mysymbolA.Name() || myposition.Symbol()==mysymbolB.Name()))
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
void MyRobot::AtualizaTimeOp()
  {
   int tempo_oper=(int)(TimeCurrent()-(int)(gv.Get("time_op")));
   int resto;
   dias_op=tempo_oper/86400;
   resto=tempo_oper%86400;
   horas_op=resto/3600;
   resto=resto%3600;
   minut_op=resto/60;
   sec_op=resto%60;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::TimeDayFilter()
  {
   bool filter;
   MqlDateTime TimeToday;
   TimeToStruct(TimeCurrent(),TimeToday);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
bool MyRobot::UpperSignalEntry()
  {
   bool signal;
//   signal=Ratio[0]>=Boll_Upper[0] && Ratio[1]<Boll_Upper[1] && Ratio[0]<Boll_H2[0];
   signal=ratio[0]>=Boll_Sup[0] && ratio[1]<Boll_Sup[1] && ratio[0]<Boll_Sup2[0];
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::UpperH2Entry()
  {
   bool signal=false;
   if(gv.Get("Val_Perna2_Sup")>0)signal=ratio[0]>=gv.Get("Val_Perna2_Sup");
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::UpperH3Entry()
  {
   bool signal=false;
   if(gv.Get("Val_Perna2_Sup")>0)signal=ratio[0]>=gv.Get("Val_Perna3_Sup");
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::LowerSignalEntry()
  {
   bool signal;
//  signal=Ratio[0]<=Boll_Lower[0] && Ratio[1]>=Boll_Lower[1] && Ratio[0]>Boll_L2[0];
   signal=ratio[0]<=Boll_Inf[0] && ratio[1]>Boll_Inf[1] && ratio[0]>Boll_Inf2[0];
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::LowerL2Entry()
  {
   bool signal=false;
   if(gv.Get("Val_Perna2_Inf")>0)signal=ratio[0]<=gv.Get("Val_Perna2_Inf");
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::LowerL3Entry()
  {
   bool signal=false;
   if(gv.Get("Val_Perna3_Inf")>0)signal=ratio[0]<=gv.Get("Val_Perna3_Inf");
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


bool MyRobot::PosicaoAberta_SymbolA()
  {
   if(myposition.SelectByMagic(SimboloA,Magic_Number))
      return true;
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MyRobot::PosicaoAberta_SymbolB()
  {
   if(myposition.SelectByMagic(SimboloB,Magic_Number))
      return true;
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::PosicaoAberta()
  {
   return(PosicaoAberta_SymbolA()||PosicaoAberta_SymbolB());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::PrecoMedio(ENUM_POSITION_TYPE ptype)
  {
   double vol=0;
   double preco=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && (myposition.Symbol()==mysymbolA.Name() || myposition.Symbol()==mysymbolB.Name()))
        {
         vol+=myposition.Volume();
         preco+=myposition.Volume()*myposition.PriceOpen();
        }
     }
   if(VolPosType(ptype)>0)preco=preco/VolPosType(ptype);
   preco=NormalizeDouble(MathRound(preco/ticksize)*ticksize,digits);
   return preco;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::VolPosType(ENUM_POSITION_TYPE ptype)
  {
   double vol=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && (myposition.Symbol()==mysymbolA.Name() || myposition.Symbol()==mysymbolB.Name()))
        {
         vol+=myposition.Volume();
        }
     }
   return vol;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::LucroAberto()
  {
   double profit=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && (myposition.Symbol()==mysymbolA.Name() || myposition.Symbol()==mysymbolB.Name()))
         profit+=myposition.Profit();
   return profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::CalculoLote(double valor,double price,double lotemin)
  {
   double lotes=MathMax(MathRound(valor/(price*lotemin))*lotemin,lotemin);
   return lotes;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::MyOrderCalcMargin(const ENUM_ORDER_TYPE action,const string marg_symbol,const double volume,const double price,double &margin)
  {
   double MarginInit,MarginMain;

   const bool Res=SymbolInfoMarginRate(symbol,action,MarginInit,MarginMain);

   margin=Res ? MarginInit*price*volume*SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE)/
          (SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE)*AccountInfoInteger(ACCOUNT_LEVERAGE)) : 0;

   return(Res);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MyRobot::OnTradeTransaction(const MqlTradeTransaction &trans,
                                 const MqlTradeRequest &request,
                                 const MqlTradeResult &result)
  {
//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long     deal_ticket       =0;
      long     deal_order        =0;
      long     deal_time         =0;
      long     deal_time_msc     =0;
      ENUM_DEAL_TYPE     deal_type=-1;
      long     deal_entry        =-1;
      long     deal_magic        =0;
      long     deal_reason       =-1;
      long     deal_position_id  =0;
      double   deal_volume       =0.0;
      double   deal_price        =0.0;
      double   deal_commission   =0.0;
      double   deal_swap         =0.0;
      double   deal_profit       =0.0;
      string   deal_symbol       ="";
      string   deal_comment      ="";
      string   deal_external_id  ="";
      if(HistoryDealSelect(trans.deal))
        {
         deal_ticket       =HistoryDealGetInteger(trans.deal,DEAL_TICKET);
         deal_order        =HistoryDealGetInteger(trans.deal,DEAL_ORDER);
         deal_time         =HistoryDealGetInteger(trans.deal,DEAL_TIME);
         deal_time_msc     =HistoryDealGetInteger(trans.deal,DEAL_TIME_MSC);
         deal_type         =(ENUM_DEAL_TYPE)HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_entry        =HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_magic        =HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
         deal_reason       =HistoryDealGetInteger(trans.deal,DEAL_REASON);
         deal_position_id  =HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);

         deal_volume       =HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_price        =HistoryDealGetDouble(trans.deal,DEAL_PRICE);
         deal_commission   =HistoryDealGetDouble(trans.deal,DEAL_COMMISSION);
         deal_swap         =HistoryDealGetDouble(trans.deal,DEAL_SWAP);
         deal_profit       =HistoryDealGetDouble(trans.deal,DEAL_PROFIT);

         deal_symbol       =HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_comment      =HistoryDealGetString(trans.deal,DEAL_COMMENT);
         deal_external_id  =HistoryDealGetString(trans.deal,DEAL_EXTERNAL_ID);

         if(deal_magic==Magic_Number)
           {
            string order_exec="Ordem executada ticket: "+(string)deal_order+", "+EnumToString(deal_type)+", "+"Volume: "+DoubleToString(deal_volume,2)+" "+deal_symbol;
            Print(order_exec);
            if(TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED))SendNotification(order_exec);
            if(deal_comment=="BUY_UPPER"+exp_name || deal_comment=="BUY_LOWER"+exp_name ||
               deal_comment=="BUY_L2"+exp_name||deal_comment=="BUY_H2"+exp_name||
               deal_comment=="BUY_L3"+exp_name||deal_comment=="BUY_H3"+exp_name)
              {
               gv.Set("sl_fin",PrecoMedio(POSITION_TYPE_BUY)*VolPosType(POSITION_TYPE_BUY)*Perc_SLFin*0.01);
               gv.Set("tp_fin",PrecoMedio(POSITION_TYPE_BUY)*VolPosType(POSITION_TYPE_BUY)*Perc_TPFin*0.01);
              }

            if(deal_comment=="BUY_UPPER"+exp_name || deal_comment=="BUY_LOWER"+exp_name)
              {
               gv.Set("time_op",(double)TimeCurrent());
              }

            if(deal_comment=="BUY_LOWER"+exp_name)
              {
               gv.Set("Rent_Buy1",Boll_Inf[0]);
               if(Tipo_Reent==ReentInicio)
                 {
                  gv.Set("Val_Perna2_Inf",Boll_Inf2[0]);
                  gv.Set("Val_Perna3_Inf",Boll_Inf3[0]);
                 }
              }

            if(deal_comment=="BUY_L2"+exp_name)gv.Set("Rent_Buy2",Boll_Inf2[0]);
            if(deal_comment=="BUY_L3"+exp_name)gv.Set("Rent_Buy3",Boll_Inf3[0]);
            if(deal_comment=="SELL_UPPER"+exp_name)
              {
               gv.Set("Rent_Sell1",Boll_Sup[0]);
               if(Tipo_Reent==ReentInicio)
                 {
                  gv.Set("Val_Perna2_Sup",Boll_Sup2[0]);
                  gv.Set("Val_Perna3_Sup",Boll_Sup3[0]);
                 }

              }
            if(deal_comment=="SELL_H2"+exp_name)gv.Set("Rent_Sell2",Boll_Sup2[0]);
            if(deal_comment=="SELL_H3"+exp_name)gv.Set("Rent_Sell3",Boll_Sup3[0]);


           }

        }
      else
         return;

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot:: CalcularFinanceiroPosicoes()
  {

   double financeiro=0;

   for(int i=PositionsTotal()-1;i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && (myposition.Symbol()==mysymbolA.Name() || myposition.Symbol()==mysymbolB.Name()))
        {
         if(myposition.PositionType()==POSITION_TYPE_BUY)
           {
            financeiro+=myposition.Volume()*myposition.PriceOpen();
           }
        }

     }

   return (financeiro);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::CreatePanel()
  {
   Retangulo.Create(0,"Retangulo",0,0,0,LARGURA_PAINEL,ALTURA_PAINEL);
   Retangulo.Corner(CORNER_LEFT_UPPER);
   Retangulo.BackColor(clrBlack);
   Retangulo.Color(clrSilver);
   Retangulo.Background(false);
   Retangulo.Style(STYLE_SOLID);
   Retangulo.BorderType(BORDER_FLAT);

   FotoLess.Create(ChartID(),"FotoLess",0,0,0);
   FotoLess.BmpFileOn("::Experts\\SG\\LESS.bmp");
   FotoLess.SetInteger(OBJPROP_XSIZE,75);
   FotoLess.SetInteger(OBJPROP_YSIZE,50);
   FotoLess.Corner(CORNER_LEFT_UPPER);

   BotaoFechar.Create(0,"BotaoFechar",0,(int)3*LARGURA_PAINEL/4-10,11,(int)LARGURA_PAINEL/4,30);
   BotaoFechar.Color(clrBlack);
   BotaoFechar.BackColor(clrAqua);
   BotaoFechar.Description("Close All");
   LabelLucro.Create(0,"LabelLucro",0,X_LABEL,4*Y_LABEL);
   LabelLucro.Color(clrAqua);
   LabelLucro.Description("Lucro Atual do L&S: "+AccountInfoString(ACCOUNT_CURRENCY)+" "+DoubleToString(LucroAberto(),2));
   LabelPailnel[0].Create(0,"LabelPorcentagem",0,X_LABEL,5*Y_LABEL+5);
   LabelPailnel[0].Color(clrAqua);
   LabelPailnel[0].Description("Lucro Percentual do L&S: "+"0.00%");


   LabelPailnel[1].Create(0,"RatiosAtual",0,X_LABEL,6*Y_LABEL+10);
   LabelPailnel[1].Color(clrAqua);
   LabelPailnel[1].Description("Ratio Atual: ");

   LabelPailnel[2].Create(0,"RatiosEnt",0,X_LABEL,7*Y_LABEL+10);
   LabelPailnel[2].Color(clrAqua);
   LabelPailnel[2].Description("Ratio Real das Entradas: ");


   LabelPailnel[3].Create(0,"Perna 1",0,X_LABEL,8*Y_LABEL+10);
   LabelPailnel[3].Color(clrAqua);
   LabelPailnel[3].Description("-  Perna 1: ");

   LabelPailnel[4].Create(0,"Perna 2",0,X_LABEL,9*Y_LABEL+10);
   LabelPailnel[4].Color(clrAqua);
   LabelPailnel[4].Description("-  Perna 2: ");

   LabelPailnel[5].Create(0,"Perna 3",0,X_LABEL,10*Y_LABEL+10);
   LabelPailnel[5].Color(clrAqua);
   LabelPailnel[5].Description("-  Perna 3: ");

   LabelPailnel[6].Create(0,"TP",0,X_LABEL,11*Y_LABEL+10);
   LabelPailnel[6].Color(clrAqua);
   LabelPailnel[6].Description("-  Take Profit: ");


   LabelPailnel[7].Create(0,"Horario",0,X_LABEL,13*Y_LABEL+10);
   LabelPailnel[7].Color(clrAqua);
   LabelPailnel[7].Description("Horário Atual do Servidor: "+TimeToString(TimeCurrent(),TIME_SECONDS));




   string hr_permitido;
   if(timerOn)hr_permitido="SIM";
   else hr_permitido="NÃO";

   LabelPailnel[8].Create(0,"HorarioValido",0,X_LABEL,14*Y_LABEL+10);
   LabelPailnel[8].Color(clrAqua);
   LabelPailnel[8].Description("Permitido Operar por Horário: "+hr_permitido);


   string s_time_op;
   if(!MyEA.PosicaoAberta_SymbolA() && !MyEA.PosicaoAberta_SymbolB())s_time_op="";
   else s_time_op=IntegerToString(dias_op)+" dias "+IntegerToString(horas_op)+" h "+IntegerToString(minut_op)+"m "+IntegerToString(sec_op)+" s ";
   LabelPailnel[9].Create(0,"Tempo Oper",0,X_LABEL,15*Y_LABEL+10);
   LabelPailnel[9].Color(clrAqua);
   LabelPailnel[9].Description("Tempo de Operação: "+s_time_op);



   LabelVersao.Create(0,"LabelVersao",0,(int)3*LARGURA_PAINEL/4-20,ALTURA_PAINEL-20);
   LabelVersao.Color(clrWhite);
   LabelVersao.FontSize(9);
   LabelVersao.Font("Arial Black");
   LabelVersao.Description("Versão "+VERSION);

   for(int i=0;i<=9;i++)LabelPailnel[i].FontSize(8);
   LabelLucro.FontSize(8);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::PanelUpdate()
  {
   if(LucroAberto()>=0)
     {
      LabelLucro.Color(clrLightGreen);
      LabelPailnel[0].Color(clrLightGreen);
      Retangulo.BackColor(clrNavy);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      LabelLucro.Color(clrOrange);
      LabelPailnel[0].Color(clrOrange);
      Retangulo.BackColor(clrBlack);
     }
   LabelLucro.Description("Lucro Atual do L&S: "+AccountInfoString(ACCOUNT_CURRENCY)+" "+DoubleToString(LucroAberto(),2));
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(PosicaoAberta())
     {
      LabelPailnel[0].Description("Lucro Percentual do L&S: "+DoubleToString(100*LucroAberto()/CalcularFinanceiroPosicoes(),2)+"%");
     }
   else LabelPailnel[0].Description("Lucro Percentual do L&S: "+"0.00%");

   string spanel_ratio="";
   string spanel_perna2="";
   string spanel_perna3="";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(PosicaoAberta_SymbolA() && PosicaoAberta_SymbolB())
     {
      if(gv.Get("lower_ent")==1.0)
        {
         spanel_ratio=DoubleToString(gv.Get("Rent_Buy1"),4);
           } else {
         spanel_ratio=DoubleToString(gv.Get("Rent_Sell1"),4);
        }

     }

   LabelPailnel[1].Description("Ratio Atual: "+DoubleToString(ratio[0],4));
   LabelPailnel[2].Description("Ratio Real das Entradas: ");
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(PosicaoAberta())
     {
      if(gv.Get("lower_ent")==1.0)
        {
         spanel_perna2=DoubleToString(gv.Get("Rent_Buy2"),4);
         spanel_perna3=DoubleToString(gv.Get("Rent_Buy3"),4);
           } else {
         spanel_perna2=DoubleToString(gv.Get("Rent_Sell2"),4);
         spanel_perna3=DoubleToString(gv.Get("Rent_Sell3"),4);;
        }

     }

   LabelPailnel[3].Description("-  Perna 1: "+spanel_ratio);
   LabelPailnel[4].Description("-  Perna 2: "+spanel_perna2);
   LabelPailnel[5].Description("-  Perna 3: "+spanel_perna3);

   string stakeprofit;
   if(PosicaoAberta())stakeprofit=DoubleToString(media,4);
   else stakeprofit="";

   LabelPailnel[6].Description("-  Take Profit: "+stakeprofit);

   LabelPailnel[7].Description("Horário Atual do Servidor: "+TimeToString(TimeCurrent(),TIME_SECONDS));

   string hr_permitido;
   if(timerOn)hr_permitido="SIM";
   else hr_permitido="NÃO";

   LabelPailnel[8].Description("Permitido Operar por Horário: "+hr_permitido);

   string s_time_op;
   if(!MyEA.PosicaoAberta_SymbolA() && !MyEA.PosicaoAberta_SymbolB())s_time_op="";
   else s_time_op=IntegerToString(dias_op)+" dias "+IntegerToString(horas_op)+" h "+IntegerToString(minut_op)+"m "+IntegerToString(sec_op)+" s ";
   LabelPailnel[9].Description("Tempo de Operação: "+s_time_op);

   LabelVersao.Description("Versão "+VERSION);

  }
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
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   return MyEA.OnInit();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   MyEA.OnDeinit(reason);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void              OnTimer()
  {
   MyEA.OnTimer();
  }
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
void OnChartEvent(const int id,// event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(StringFind(sparam,"BotaoFechar")!=-1)
        {
         MyEA.ClosePos_AB();
         ObjectSetInteger(0,"BotaoFechar",OBJPROP_STATE,false);
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
