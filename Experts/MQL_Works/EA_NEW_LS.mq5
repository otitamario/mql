#define VALIDADE   D'2100.12.31 23:59:59'//Data de Validade ano.mes.dia horas:minutos:segundos(opcional)
#define NUMERO_CONTA 9011600   //Numero da conta
#define ONLY_DEMO "SIM" //"SIM"- Somente em Demo,"NAO"- liberado para conta Real
#define VERSION "1.03"// Mudar aqui as Versões

#property copyright "SuperGain"
#property version   VERSION
#property description   "LESS - Long & Short System\n"

#property description   "1.02 \n*Correção na visualização das linhas das pernas após retomadas de operações"
#property description   "*Correção no painel para mostrar os valores das pernas de quando abriu a operação"
#property description   "*Correção no cálculo do percentual de lucro da operação"
#property description   "*Agora somente aparece as linhas de cima ou de baixo de acordo com o toque se foi na perna de cima ou na de baixo"
#property description   "*Colocado de volta os comentários no fechamento das operações\n"

#property description   "1.01 \n*Correção de acontecer um StopLoss e abrir outra perna em sequência"

#property icon "\\Experts\\SG\\LESS.ico"

#resource "\\Indicators\\SG\\L&S_ALL_Indicator.ex5"
#resource "\\Experts\\SG\\LESS.bmp"

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

#include<ChartObjects\ChartObjectsLines.mqh>
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

#include <SG\Expert_Class_SG.mqh>
#include <SG\statistics.mqh>

MyPanel ExtDialog;

CLabel            m_label[50];
CRadioGroup radio_ativar;

#define LARGURA_PAINEL 270 // Largura Painel
#define ALTURA_PAINEL 280 // Altura Painel




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

input double Perc_SLFin=2; // Stop Loss Percentual por Financeiro
input double Perc_TPFin=2; // Take Profit Percentual por Financeiro

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

public:
   void              MyRobot();
   void             ~MyRobot();
   int               OnInit();
   void              OnDeinit(const int reason);
   void              OnTick();
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

   bol_handle=iCustom(_Symbol,PERIOD_CURRENT,"::Indicators\\SG\\L&S_ALL_Indicator.ex5",BeginTime,SimboloA,SimboloB,Action,
                      Periodo,DesvioPerna1,DesvioPerna2,DesvioPerna3);

   ChartIndicatorAdd(curChartID,(int)ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),bol_handle);

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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   return (INIT_SUCCEEDED);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
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
   novodia=Bar_NovoDia.CheckNewBar(SimboloB,PERIOD_D1);
   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      tradeOn=true;
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

//   ExtDialog.OnTick();

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

/*
   string cotacoes;
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
     }
   AtualizaTimeOp();

   if(tradeOn && timerOn)

     {// inicio Trade On

      CheckClose();
      if(gv.Get("lower_ent")==1.0 && ratio[0]>=media)
        {
         ClosePos_AB();
        }

      if(gv.Get("upper_ent")==1.0 && ratio[0]<=media)
        {
         ClosePos_AB();
        }

      if(LowerSignalEntry() && gv.Get("pos_ab")==0.0)//Compra A, Vende B
        {
         loteA=CalculoLote(Financeiro,mysymbolA.Ask(),SymbolInfoDouble(SimboloA,SYMBOL_VOLUME_MIN));
         loteB=CalculoLote(Financeiro,mysymbolB.Bid(),SymbolInfoDouble(SimboloB,SYMBOL_VOLUME_MIN));

         check_marginA=OrderCalcMargin(ORDER_TYPE_BUY,SimboloA,loteA,mysymbolA.Ask(),margin_A);
         check_marginB=OrderCalcMargin(ORDER_TYPE_SELL,SimboloB,loteB,mysymbolB.Bid(),margin_B);
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
         loteA=CalculoLote(Financeiro,mysymbolA.Bid(),SymbolInfoDouble(SimboloA,SYMBOL_VOLUME_MIN));
         loteB=CalculoLote(Financeiro,mysymbolB.Ask(),SymbolInfoDouble(SimboloB,SYMBOL_VOLUME_MIN));

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
         loteA=CalculoLote(Financeiro,mysymbolA.Ask(),SymbolInfoDouble(SimboloA,SYMBOL_VOLUME_MIN));
         loteB=CalculoLote(Financeiro,mysymbolB.Bid(),SymbolInfoDouble(SimboloB,SYMBOL_VOLUME_MIN));
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
         loteA=CalculoLote(Financeiro,mysymbolA.Bid(),SymbolInfoDouble(SimboloA,SYMBOL_VOLUME_MIN));
         loteB=CalculoLote(Financeiro,mysymbolB.Ask(),SymbolInfoDouble(SimboloB,SYMBOL_VOLUME_MIN));

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
         loteA=CalculoLote(Financeiro,mysymbolA.Ask(),SymbolInfoDouble(SimboloA,SYMBOL_VOLUME_MIN));
         loteB=CalculoLote(Financeiro,mysymbolB.Bid(),SymbolInfoDouble(SimboloB,SYMBOL_VOLUME_MIN));
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
         loteA=CalculoLote(Financeiro,mysymbolA.Bid(),SymbolInfoDouble(SimboloA,SYMBOL_VOLUME_MIN));
         loteB=CalculoLote(Financeiro,mysymbolB.Ask(),SymbolInfoDouble(SimboloB,SYMBOL_VOLUME_MIN));

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
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+

void MyRobot::LOAD_DATA()
  {
   datetime first_date;
   SeriesInfoInteger(SimboloA,_Period,SERIES_FIRSTDATE,first_date);

   int res=CheckLoadHistory(SimboloA,_Period,first_date);
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
      if(gv.Get("sl_fin")>0.0 && gv.Get("tp_fin")>0.0 && (LucroAberto()>=gv.Get("tp_fin") || LucroAberto()<=-gv.Get("sl_fin")))
        {
         ClosePos_AB();
         Print("Sapida por SL ou TP Percentual");
        }
      if(dias_op>=StopTemporal)
        {
         ClosePos_AB();
         Print("Sapida por SL ou TP Percentual");
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::ClosePos_AB()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
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
   bool signal;
//   signal=Ratio[0]>=Boll_H2[0];
   signal=ratio[0]>=Boll_Sup2[0];
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::UpperH3Entry()
  {
   bool signal;
// signal=Ratio[0]>=Boll_H3[0];
   signal=ratio[0]>=Boll_Sup3[0];
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
   bool signal;
//  signal=Ratio[0]<=Boll_L2[0];
   signal=ratio[0]<=Boll_Inf2[0];
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::LowerL3Entry()
  {
   bool signal;
//signal=Ratio[0]<=Boll_L3[0];
   signal=ratio[0]<=Boll_Inf3[0];
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

           }

        }
      else
         return;

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
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

/*   if(TimeCurrent()>D'2019.02.15 23:59:59')
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
   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
      return(INIT_FAILED);
//--- run application 

   ExtDialog.Run();
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
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.Destroy(reason);
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
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.OnTick();
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
//   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.ChartEvent(id,lparam,dparam,sparam);
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

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Resultado Aberto: "+DoubleToString(MyEA.LucroAberto(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[0].Color(clrDeepSkyBlue);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   string s_time_op;
   if(!MyEA.PosicaoAberta_SymbolA() && !!MyEA.PosicaoAberta_SymbolB())s_time_op="";
   else s_time_op=IntegerToString(dias_op)+" dias "+IntegerToString(horas_op)+" h "+IntegerToString(minut_op)+"m "+IntegerToString(sec_op)+" s ";
   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"Tempo de Operação: "+s_time_op,xx1,yy1,xx2,yy2))
      return(false);
   m_label[1].Color(clrDeepSkyBlue);

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
void MyPanel::OnTick(void)
  {
   m_label[0].Text("Resultado Aberto: "+DoubleToString(MyEA.LucroAberto(),2));

   string s_time_op;
   if(!MyEA.PosicaoAberta_SymbolA() && !!MyEA.PosicaoAberta_SymbolB())s_time_op="";
   else s_time_op=IntegerToString(dias_op)+" dias "+IntegerToString(horas_op)+" h "+IntegerToString(minut_op)+"m "+IntegerToString(sec_op)+" s ";
   m_label[1].Text("Tempo de Operação: "+s_time_op);

  }
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(MyPanel)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
