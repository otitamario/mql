//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

enum Operacao
  {
   Contra,//Contra-Tendência
   Favor //Favor da Tendência
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TipoLote
  {
   Fixo,//Fixo
   Dinamico //Dinâmico
  };

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include<Trade\AccountInfo.mqh>
#include <Controls\Defines.mqh>
#include<ChartObjects\ChartObjectsLines.mqh>


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
#include <Auxiliares.mqh>

CLabel            m_label[50];
CButton BotaoFechar;
CButton BotaoDel;

#define TENTATIVAS 10 // Tentativas envio ordem
#define LARGURA_PAINEL 450 // Largura Painel
#define ALTURA_PAINEL 170 // Altura Painel
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {

   int xx1=INDENT_LEFT;
   int yy1=INDENT_TOP;
   int xx2=x1+BUTTON_WIDTH;
   int yy2=INDENT_TOP+BUTTON_HEIGHT;

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);

//--- create dependent controls 

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Nome: "+AccountInfoString(ACCOUNT_NAME),xx1,yy1,xx2,yy2))
      return(false);
   m_label[0].Color(clrDeepSkyBlue);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"Servidor: "+AccountInfoString(ACCOUNT_SERVER)+" Login: "+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)),xx1,yy1,xx2,yy2))
      return(false);
   m_label[1].Color(clrYellow);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"RESULTADO MENSAL: "+DoubleToString(lucro_total_mes,2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[2].Color(clrYellow);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+3*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"RESULTADO SEMANAL: "+DoubleToString(lucro_total_semana,2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[3].Color(clrMediumSpringGreen);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+4*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],"RESULTADO DIÁRIO: "+DoubleToString(lucro_total,2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[4].Color(clrMediumSpringGreen);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+5*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[5],"GAP: "+DoubleToString(Gap,3),xx1,yy1,xx2,yy2))
      return(false);
   m_label[5].Color(clrMediumSpringGreen);

   xx1=LARGURA_PAINEL-INDENT_RIGHT-BUTTON_WIDTH-CONTROLS_GAP_X;
   yy1=INDENT_TOP;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+1.5*BUTTON_HEIGHT;

   if(!CreateButton(m_chart_id,m_subwin,BotaoFechar,"CLOSE ALL",xx1,yy1,xx2,yy2))
      return(false);
   BotaoFechar.ColorBackground(clrLimeGreen);

   xx1=LARGURA_PAINEL-INDENT_RIGHT-BUTTON_WIDTH-CONTROLS_GAP_X;
   yy1=INDENT_TOP+(BUTTON_HEIGHT+4*CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+1.5*BUTTON_HEIGHT;

   if(!CreateButton(m_chart_id,m_subwin,BotaoDel,"DEL ALL",xx1,yy1,xx2,yy2))
      return(false);
   BotaoDel.ColorBackground(clrBlueViolet);
   BotaoDel.Color(clrYellow);


//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnTick(void)
  {
   m_label[0].Text("Nome: "+AccountInfoString(ACCOUNT_NAME));
   m_label[1].Text("Servidor: "+AccountInfoString(ACCOUNT_SERVER)+" Login: "+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)));
   m_label[2].Text("RESULTADO MENSAL: "+DoubleToString(lucro_total_mes,2));
   m_label[3].Text("RESULTADO SEMANAL: "+DoubleToString(lucro_total_semana,2));
   m_label[4].Text("RESULTADO DIÁRIO: "+DoubleToString(lucro_total,2));
   m_label[5].Text("GAP: "+DoubleToString(Gap,3));
  }
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(CControlsDialog)
ON_EVENT(ON_CLICK,BotaoFechar,OnClickBotaoFechar)
ON_EVENT(ON_CLICK,BotaoDel,OnClickBotaoDel)
EVENT_MAP_END(CAppDialog)

void OnClickBotaoFechar()
  {
   CloseALL();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnClickBotaoDel()
  {
   DeleteALL();
  }

//Classes
CNewBar NewBar;
CisNewBar newbar_ind; // instance of the CisNewBar class: detect new tick candlestick
CTimer Timer;
CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
CControlsDialog ExtDialog;
CChartObjectVLine VLine_Init,VLine_Fim;
CChartObjectTrend TrendLine;

// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=20082018;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input string SEstrateg="############-------------Estratégia----------########";//Estratégia
input TipoLote tipo_lote=Dinamico;//Tipo de Cálculo do Lote
input double Lot=10;//Lote Entrada - Se Fixo
input double deposito=1500;// Valor Total Financeiro Usado para Trade
input double margin_lote=150;// Margem Financeira usada Para Cada Lote Mínimo

input Operacao operacao=Favor;//Operar a Favor ou Contra a Tendência
input string Gap_init="17:50";//Horário Gap Inicial
input string Gap_final="09:01";//Horário Gap Final
input bool first_tick=false;//Gap Inicial=Primeiro Tick?
input double gap_min=100;//Gap Mínimo
input double gap_max=400;//Gap Máximo
input string open_order="9:01:15";//Horário de Abertura da Ordem
input string Sfechamentos="############-------------Opções de Fechamento----------########";//Fechamento
input string Sfechamepreco="############------------------------------########";//Fechamento por Preço
input double lot_fech1=1;//1- Lotes Fechar por SL,TP
input double stop1=100;//Stop Loss 1
input double take1=100;//Take Profit 1 
input bool Trail1=false;//Trailing Stop 1 True/False
input double lot_fech2=1;//2- Lotes Fechar por SL,TP 
input double stop2=100;//Stop Loss 2
input double take2=100;//Take Profit 2 
input bool Trail2=false;//Trailing Stop 2 True/False
input double lot_fech3=1;//3- Lotes Fechar por SL,TP
input double stop3=100;//Stop Loss 3
input double take3=100;//Take Profit 3 
input bool Trail3=false;//Trailing Stop 3 True/False 
input string Sfechamehorar="############------------------------------########";//Fechamento por Horário
input string tp_hor4="9:50:10";//Horário TP 4
input double lot_fech4=1;//4- Lotes Fechar por Horario
input double stop4=100;//Stop Loss 4
input bool Trail4=false;//Trailing Stop 4 True/False
input string tp_hor5="10:10:10";//Horário TP 5
input double lot_fech5=1;//5- Lotes Fechar por Horario
input double stop5=100;//Stop Loss 5
input bool Trail5=false;//Trailing Stop 5 True/False
input string tp_hor6="10:30:10";//Horário TP 6
input double lot_fech6=1;//6- Lotes Fechar por Horario
input double stop6=100;//Stop Loss 6
input bool Trail6=false;//Trailing Stop 6 True/False 
sinput string STrailing="############---------------Trailing Stop----------########";//Trailing
input double TraillingStart=0;//Lucro Minimo Iniciar trailing stop
input double TraillingDistance=75;// Distanccia em Pontos do Stop Loss
input double TraillingStep=10;// Passo para atualizar Stop Loss

input string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes no Dia
input string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:01";//Horario Inicial
input string end_hour="17:30";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario
sinput string sdias="FILTRO DOS DIAS DA SEMANA";//Dias da Semana
input bool trade0=true;// Operar Domingo
input bool trade1=true;// Operar Segunda
input bool trade2=true;// Operar Terça
input bool trade3=true;// Operar Quarta
input bool trade4=true;// Operar Quinta
input bool trade5=true;// Operar Sexta
input bool trade6=true;// Operar Sábado


                       //Variaveis 

string original_symbol;
double ask,bid;
double lucro_total,pontos_total,lucro_entry,lucro_total_mes,lucro_total_semana;
bool timerOn,tradeOn;
double ponto,ticksize,digits;
long curChartID;
int atr_handle;
double ATR_High[],ATR_Low[];
int heiken_handle;
double Heiken_Color[];

double high[],low[],open[],close[];
double price_open;
string glob_entr_tot="ENT_TOT"+Symbol()+IntegerToString(Magic_Number);
string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string tp_cp_tick="tp_cp_tick"+Symbol()+IntegerToString(Magic_Number),tp_vd_tick="tp_vd_tick"+Symbol()+IntegerToString(Magic_Number);
string deals_total="deals_total"+Symbol()+IntegerToString(Magic_Number),deals_total_prev="deals_total_prev"+Symbol()+IntegerToString(Magic_Number);
string gv_today="gv_today"+Symbol()+IntegerToString(Magic_Number),gv_today_prev="gv_today_prev"+Symbol()+IntegerToString(Magic_Number);
string sl1_tick="sl1_tick"+Symbol()+IntegerToString(Magic_Number),sl2_tick="sl2_tick"+Symbol()+IntegerToString(Magic_Number);
string sl3_tick="sl3_tick"+Symbol()+IntegerToString(Magic_Number),sl4_tick="sl4_tick"+Symbol()+IntegerToString(Magic_Number);
string sl5_tick="sl5_tick"+Symbol()+IntegerToString(Magic_Number),sl6_tick="sl6_tick"+Symbol()+IntegerToString(Magic_Number);
string set_tp4="set_tp4"+Symbol()+IntegerToString(Magic_Number),set_tp5="set_tp5"+Symbol()+IntegerToString(Magic_Number);
string set_tp6="set_tp6"+Symbol()+IntegerToString(Magic_Number);

double buyprice,sellprice,oldprice;
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
datetime time_novodia[4];
double lotes_stop,lotes_take;
int res_code;
int cont;
datetime hora_inicial,hora_final;
double stop_price,take_price;
uint total_deals,cont_deals;
ulong ticket_history_deal,deal_magic;
MqlDateTime TimeNow;
ENUM_ORDER_TYPE_TIME order_time_type;
datetime gap_init,gap_fin,hor_open_order;
int idx_gap_init,idx_gap_fin;
double Gap;
bool tradebarra;
datetime horario_tp4,horario_tp5,horario_tp6;
double lote_entrada,lote_saida;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   EventSetMillisecondTimer(200);

   original_symbol=Symbol();
   if(SymbolInfoInteger(original_symbol,SYMBOL_EXPIRATION_MODE)==2)order_time_type=1;
   else order_time_type=0;

   tradeOn=true;
   tradebarra=true;
   TimeToStruct(TimeCurrent(),TimeNow);
   GlobalVariableSet(gv_today_prev,(double)TimeNow.day_of_year);

   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.SetDeviationInPoints(deviation_points);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      Print("ORDER_FILLING_FOK");
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      Print("ORDER_FILLING_IOC");
   else
      Print("ORDER_FILLING_RETURN");
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      mytrade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      mytrade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      mytrade.SetTypeFilling(ORDER_FILLING_RETURN);
   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);

   int find_wdo=StringFind(original_symbol,"WDO");
   int find_dol=StringFind(original_symbol,"DOL");
   if(find_dol>=0|| find_wdo>=0) ponto=ponto*1000;


   curChartID=ChartID();

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

// parametros incorretos desnecessarios na otimizacao
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   gap_init=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Gap_init);
   gap_fin=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Gap_final);
   hor_open_order=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+open_order);

   horario_tp4=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+tp_hor4);
   horario_tp5=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+tp_hor5);
   horario_tp6=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+tp_hor6);


   if(gap_init>gap_fin)gap_init=gap_init=StringToTime(TimeToString(iTime(original_symbol,PERIOD_D1,1),TIME_DATE)+" "+Gap_init);
   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(deposito=1500<margin_lote=150)
     {
      string erro="Financeiro Está menor que a Margem";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

//   Print("open order "+TimeToString(hor_open_order,TIME_SECONDS)+" gap fin "+TimeToString(gap_fin,TIME_SECONDS));
   if(hor_open_order<gap_fin)
     {
      string erro="Hora de Abertura da Ordem deve ser Maior que o Hórário do Gap Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(horario_tp4<hor_open_order || horario_tp5<hor_open_order || horario_tp6<hor_open_order)
     {
      string erro="Horário da Saída Parcial deve ser Maior que Horário de Abertura da Ordem";
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

   if(lot_fech1+lot_fech2+lot_fech3+lot_fech4+lot_fech5+lot_fech6!=Lot)
     {
      string erro="Os Lotes das saídas parciais deve ser igual ao Lote de entrada";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);

     }

//Global Variables Check

   if(!GlobalVariableCheck(glob_entr_tot))GlobalVariableSet(glob_entr_tot,0.0);
   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0.0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0.0);
   if(!GlobalVariableCheck(tp_cp_tick))GlobalVariableSet(tp_cp_tick,0.0);
   if(!GlobalVariableCheck(tp_vd_tick))GlobalVariableSet(tp_vd_tick,0.0);

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))

      return(INIT_FAILED);
//--- run application 

   ExtDialog.Run();

   if(HistorySelect(iTime(original_symbol,PERIOD_D1,0),TimeCurrent()))
     {
      total_deals=HistoryDealsTotal();
      ticket_history_deal=0;
      cont_deals=0;
      for(uint i=0;i<total_deals;i++)
        {
         //--- try to get deals ticket_history_deal
         if((ticket_history_deal=HistoryDealGetTicket(i))>0)
           {
            deal_magic=HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
            if(deal_magic==Magic_Number && HistoryDealGetString(ticket_history_deal,DEAL_SYMBOL)==mysymbol.Name())cont_deals+=1;
           }
        }
     }
   GlobalVariableSet(deals_total_prev,(double)cont_deals);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeletaIndicadores();
   ExtDialog.Destroy(reason);
   VLine_Init.Delete();
   VLine_Fim.Delete();
   EventKillTimer();

//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   mysymbol.Refresh();
   mysymbol.RefreshRates();
   if(!first_tick)
     {

      if(TimeCurrent()==gap_fin)
        {
         idx_gap_init=iBarShift(original_symbol,periodoRobo,gap_init);
         idx_gap_fin=iBarShift(original_symbol,periodoRobo,gap_fin);
         Gap=iOpen(original_symbol,periodoRobo,idx_gap_fin)-iOpen(original_symbol,periodoRobo,idx_gap_init);

         VLine_Init.Delete();
         VLine_Fim.Delete();
         TrendLine.Delete();

         VLine_Init.Create(ChartID(),"Barra Inicial",0,gap_init);
         VLine_Init.Color(clrBlue);
         VLine_Fim.Create(ChartID(),"Barra Final",0,gap_fin);
         VLine_Fim.Color(clrLime);
         TrendLine.Create(ChartID(),"TrendLine",0,iTime(original_symbol,periodoRobo,idx_gap_init),iOpen(original_symbol,periodoRobo,idx_gap_init),iTime(original_symbol,periodoRobo,idx_gap_fin),iOpen(original_symbol,periodoRobo,idx_gap_fin));
         TrendLine.Color(clrAqua);

        }
      if(TimeCurrent()>=hor_open_order)
        {
         if(BuySignal() && !Buy_opened() && tradebarra)
           {
            if(mytrade.Buy(Lot,original_symbol,0,0,0,"BUY"+exp_name))
              {
               GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
               tradebarra=false;
              }
            else Print("Erro enviar ordem ",GetLastError());
           }

         if(SellSignal() && !Sell_opened() && tradebarra)
           {
            if(mytrade.Sell(Lot,original_symbol,0,0,0,"SELL"+exp_name))
              {
               GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
               tradebarra=false;
              }
            else Print("Erro enviar ordem ",GetLastError());

           }

        }
     }

   SetTPHorario();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   Main_Program();

  }// fim OnTick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



//+-------------ROTINAS----------------------------------------------+

void Main_Program()
  {

   TimeToStruct(TimeCurrent(),TimeNow);
   GlobalVariableSet(gv_today,(double)TimeNow.day_of_year);

   bool novodia;
   novodia=NewBar.CheckNewBar(original_symbol,PERIOD_D1);
   mysymbol.Refresh();
   mysymbol.RefreshRates();
   if(mysymbol.Bid()>mysymbol.Ask() && mysymbol.Ask()>0) return;//Leilão

   if(!PosicaoAberta())
     {
      GlobalVariableSet(set_tp4,0.0);
      GlobalVariableSet(set_tp5,0.0);
      GlobalVariableSet(set_tp6,0.0);
     }
   if(novodia || GlobalVariableGet(gv_today)!=GlobalVariableGet(gv_today_prev))
     {
      GlobalVariableSet(glob_entr_tot,0.0);
      GlobalVariableSet(deals_total_prev,0.0);
      GlobalVariableSet(set_tp4,0.0);
      GlobalVariableSet(set_tp5,0.0);
      GlobalVariableSet(set_tp6,0.0);

      tradeOn=true;

      gap_init=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Gap_init);
      //   if(first_tick)gap_fin=iTime(original_symbol,PERIOD_M1,0);
      if(first_tick)gap_fin=TimeCurrent();
      else gap_fin=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Gap_final);
      hor_open_order=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+open_order);
      horario_tp4=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+tp_hor4);
      horario_tp5=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+tp_hor5);
      horario_tp6=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+tp_hor6);

      if(gap_init>gap_fin)gap_init=gap_init=StringToTime(TimeToString(iTime(original_symbol,PERIOD_D1,1),TIME_DATE)+" "+Gap_init);
      tradebarra=true;

      if(first_tick)
        {
         idx_gap_init=iBarShift(original_symbol,periodoRobo,gap_init);
         // Gap=iOpen(original_symbol,PERIOD_D1,0)-iOpen(original_symbol,periodoRobo,idx_gap_init);
         Gap=SymbolInfoDouble(original_symbol,SYMBOL_ASK)-iOpen(original_symbol,periodoRobo,idx_gap_init);

         Print("Open init ",iOpen(original_symbol,periodoRobo,idx_gap_init)," Open fin ",iOpen(original_symbol,PERIOD_D1,0));
         VLine_Init.Delete();
         VLine_Fim.Delete();
         TrendLine.Delete();

         VLine_Init.Create(ChartID(),"Barra Inicial",0,gap_init);
         VLine_Init.Color(clrBlue);
         VLine_Fim.Create(ChartID(),"Barra Final",0,gap_fin);
         VLine_Fim.Color(clrLime);
         TrendLine.Create(ChartID(),"TrendLine",0,iTime(original_symbol,periodoRobo,idx_gap_init),iOpen(original_symbol,periodoRobo,idx_gap_init),iTime(original_symbol,PERIOD_D1,0),iOpen(original_symbol,PERIOD_D1,0));
         TrendLine.Color(clrAqua);

         if(BuySignal() && !Buy_opened() && tradebarra)
           {
            lote_entrada=CalculoLote(tipo_lote);
            if(mytrade.Buy(lote_entrada,original_symbol,0,0,0,"BUY"+exp_name))
              {
               GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
               tradebarra=false;
              }
            else Print("Erro enviar ordem ",GetLastError());
           }

         if(SellSignal() && !Sell_opened() && tradebarra)
           {
            lote_entrada=CalculoLote(tipo_lote);
            if(mytrade.Sell(lote_entrada,original_symbol,0,0,0,"SELL"+exp_name))
              {
               GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
               tradebarra=false;
              }
            else Print("Erro enviar ordem ",GetLastError());

           }

        }//FIm first tick

     }

   GlobalVariableSet(gv_today_prev,GlobalVariableGet(gv_today));

   MytradeTransaction();

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   ExtDialog.OnTick();
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

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

   lucro_total=LucroOrdens()+LucroPositions();
   lucro_total_semana=LucroOrdensSemana()+LucroPositions();
   lucro_total_mes=LucroOrdensMes()+LucroPositions();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
      Print("EA encerrado lucro ou prejuizo");

     }

   timerOn=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!timerOn && daytrade)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();

     }

//Atualizacao das Cotacoes----ticks
   MqlTick last_tick;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(SymbolInfoTick(Symbol(),last_tick))
     {
      bid= last_tick.bid;
      ask=last_tick.ask;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      Print("Falhou obter o tick");
      return;
     }
   double spread=ask-bid;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!PosicaoAberta())DeleteALL();

   if(Buy_opened() && Sell_opened())CloseByPosition();

   if(PosicaoAberta()) Trail();

   if(tradeOn && timerOn)

     {// inicio Trade On

      if(NewBar.CheckNewBar(Symbol(),periodoRobo))
        {

        }//End NewBar

     }//End Trade On
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


  }//End Main Program
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Buy conditions                                                   |
//+------------------------------------------------------------------+
bool Buy_opened()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_BUY)
         return(true);  //It is a Buy
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Sell_opened()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_SELL)
         return(true);  //It is a Buy
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   bool signal;
   signal=MathAbs(Gap)>=gap_min && MathAbs(Gap)<=gap_max;
   if(operacao==Favor)signal=signal&&Gap>0;
   else signal=signal&&Gap<0;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   bool signal;
   signal=MathAbs(Gap)>=gap_min && MathAbs(Gap)<=gap_max;
   if(operacao==Favor)signal=signal&&Gap<0;
   else signal=signal&&Gap>0;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   bool b_get;
   b_get=CopyHigh(Symbol(),periodoRobo,0,5,high)<=0 || 
         CopyOpen(Symbol(),periodoRobo,0,5,open)<=0 || 
         CopyLow(Symbol(),periodoRobo,0,5,low)<=0 || 
         CopyClose(Symbol(),periodoRobo,0,5,close)<=0;
   return(b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculoLote(TipoLote tplote)
  {
   double lotes=0;
   if(tplote==Fixo)lotes=Lot;
   else
     {
      lotes=MathRound((deposito/margin_lote)/mysymbol.LotsMin())*mysymbol.LotsMin();
      lotes=MathMax(lotes,mysymbol.LotsMin());
     }
   return lotes;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseALL()
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
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

void ClosePosType(ENUM_POSITION_TYPE ptype)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && myposition.Symbol()==mysymbol.Name())
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//------------------------------------------------------------------------
// Select total orders in history and get total pending orders
// (as shown within the COrderInfo class section). 
void DeleteALL()
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
     {
      ulong o_ticket=OrderGetTicket(j);
      if(o_ticket!=0)
        {
         myorder.Select(o_ticket);
         if(myorder.Magic()==Magic_Number && myorder.Symbol()==mysymbol.Name()) mytrade.OrderDelete(o_ticket);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAbertas(double distancia)
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
         if(myorder.Magic()==Magic_Number && myorder.Symbol()==mysymbol.Name() && MathAbs(myorder.PriceOpen()-ask)>distancia*ponto)
           {
            if(myorder.Type()==ORDER_TYPE_BUY_LIMIT || myorder.Type()==ORDER_TYPE_SELL_LIMIT)
               mytrade.OrderDelete(o_ticket);
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
double PriceLastStopOrder(const ENUM_ORDER_TYPE pending_order_type)
  {
   datetime last_time=0;
   double last_price=-1.0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==pending_order_type)
               if(myorder.TimeSetup()>last_time)
                 {
                  last_time=myorder.TimeSetup();
                  last_price=myorder.PriceOpen();
                 }
//---
   return(last_price);
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
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void DeleteOrders(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Ordens Abertas                                                    |
//+------------------------------------------------------------------+
bool OrdemAberta(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=mysymbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LucroOrdens()
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
   uint total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LucroPositions()
  {
   double profit=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
         profit+=myposition.Profit();
   return profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void DeletaIndicadores()
  {
   string name;
//--- O número de janelas no gráfico (ao menos uma janela principal está sempre presente) 
   int windows=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
//--- Verifique todas as janelas 
   for(int w=windows-1;w>=0;w--)
     {
      //--- o número de indicadores nesta janela/sub-janela 
      int total=ChartIndicatorsTotal(0,w);
      //--- Passar por todos os indicadores na janela 
      for(int i=total-1;i>=0;i--)
        {
         //--- obtém o nome abreviado do indicador 
         name=ChartIndicatorName(0,w,i);
         ChartIndicatorDelete(0,w,name);
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PosicaoAberta()
  {
   if(myposition.SelectByMagic(original_symbol,Magic_Number)==true)
      return(myposition.PositionType()== POSITION_TYPE_BUY||myposition.PositionType()== POSITION_TYPE_SELL);
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void MytradeTransaction()
  {
   ulong order_ticket;
   ulong deals_ticket;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

      GlobalVariableSet(deals_total,(double)cont_deals);

      if(GlobalVariableGet(deals_total)>GlobalVariableGet(deals_total_prev))
        {
         if(deals_ticket>0)
           {
            mydeal.Ticket(deals_ticket);
            order_ticket=mydeal.Order();

            if(mydeal.Comment()=="BUY"+exp_name || mydeal.Comment()=="SELL"+exp_name)
              {
               GlobalVariableSet(glob_entr_tot,GlobalVariableGet(glob_entr_tot)+1);
              }

            if(order_ticket==(ulong)GlobalVariableGet(cp_tick))

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
               SetSL(POSITION_TYPE_BUY,buyprice);
               SetTP(POSITION_TYPE_BUY,buyprice);

              }
            //--------------------------------------------------

            if(order_ticket==(ulong)GlobalVariableGet(vd_tick))
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
               SetSL(POSITION_TYPE_SELL,sellprice);
               SetTP(POSITION_TYPE_SELL,sellprice);

              }

            if(StringFind(mydeal.Comment(),"SL")>=0 || StringFind(mydeal.Comment(),"TP")>=0)
              {
               AjusteOrdens();
              }

           }// if dealsticket>0
        }//Fim deals>prev
     }//Fim HistorySelect
   GlobalVariableSet(deals_total_prev,GlobalVariableGet(deals_total));

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteOrdersComment(const string comm)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.Comment()==comm)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void CloseByPosition()
  {
   ulong tick_sell,tick_buy;
   if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      while(Buy_opened() && Sell_opened())
        {
         tick_buy=TickecBuyPos();
         tick_sell=TickecSellPos();
         if(tick_buy>0 && tick_sell>0)mytrade.PositionCloseBy(tick_buy,tick_sell);
        }

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong TickecBuyPos()
  {
   ulong tick=0;
   if(Buy_opened())
     {

      for(int i=PositionsTotal()-1;i>=0; i--)
        {
         if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
           {
            if(myposition.PositionType()==POSITION_TYPE_BUY)
              {
               tick=myposition.Ticket();
               break;
              }
           }
        }

     }
   return tick;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong TickecSellPos()
  {
   ulong tick=0;
   if(Sell_opened())
     {
      for(int i=PositionsTotal()-1;i>=0; i--)
        {
         if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
           {
            if(myposition.PositionType()==POSITION_TYPE_SELL)
              {
               tick=myposition.Ticket();
               break;
              }
           }
        }

     }
   return tick;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double GainsOrdens()
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
   uint total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            if(mydeal.Profit()>0)
               profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LossOrdens()
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
   uint total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            if(mydeal.Profit()<0)
               profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GainsOrdensSemana()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   datetime tm_start=WeekStartTime(TimeCurrent());
   HistorySelect(tm_start,tm_end);
   uint total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            if(mydeal.Profit()>0)
               profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LucroOrdensSemana()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   datetime tm_start=WeekStartTime(TimeCurrent());
   HistorySelect(tm_start,tm_end);
   uint total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LossOrdensSemana()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   datetime tm_start=WeekStartTime(TimeCurrent());
   HistorySelect(tm_start,tm_end);
   uint total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            if(mydeal.Profit()<0)
               profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
long WeekStartTime(datetime aTime,bool aStartsOnMonday=false)
  {
   long tmp=aTime;
   long Corrector;
   if(aStartsOnMonday)
     {
      Corrector=259200; // duration of three days (86400*3)
     }
   else
     {
      Corrector=345600; // duration of four days (86400*4)
     }
   tmp+=Corrector;
   tmp=(tmp/604800)*604800;
   tmp-=Corrector;
   return(tmp);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double LucroOrdensMes()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   MqlDateTime stm_end,time_aux;
   TimeToStruct(tm_end,stm_end);
   time_aux=stm_end;
   time_aux.day=1;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);

   HistorySelect(tm_start,tm_end);
   uint total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool TimeDayFilter()
  {
   bool filter;
   MqlDateTime TimeNow;
   TimeToStruct(TimeCurrent(),TimeNow);
   switch(TimeNow.day_of_week)
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void DeleteOrdersExEntry()
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(StringFind(myorder.Comment(),"BUY")<0 && StringFind(myorder.Comment(),"SELL")<0)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+

void SetSL(const ENUM_POSITION_TYPE ptype,const double preco)
  {
   if(ptype==POSITION_TYPE_BUY)
     {
      if(lot_fech1>0)
        {
         stop_price=NormalizeDouble(preco-stop1*ponto,digits);
         if(mytrade.SellStop(lot_fech1,stop_price,original_symbol,0,0,order_time_type,0,"SL1"))
           {
            GlobalVariableSet(sl1_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 1 não enviado: ",GetLastError());
        }

      if(lot_fech2>0)
        {
         stop_price=NormalizeDouble(preco-stop2*ponto,digits);
         if(mytrade.SellStop(lot_fech2,stop_price,original_symbol,0,0,order_time_type,0,"SL2"))
           {
            GlobalVariableSet(sl2_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 2 não enviado: ",GetLastError());
        }
      if(lot_fech3>0)
        {
         stop_price=NormalizeDouble(preco-stop3*ponto,digits);
         if(mytrade.SellStop(lot_fech3,stop_price,original_symbol,0,0,order_time_type,0,"SL3"))
           {
            GlobalVariableSet(sl3_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 3 não enviado: ",GetLastError());
        }
      if(lot_fech4>0)
        {
         stop_price=NormalizeDouble(preco-stop4*ponto,digits);
         if(mytrade.SellStop(lot_fech4,stop_price,original_symbol,0,0,order_time_type,0,"SL4"))
           {
            GlobalVariableSet(sl4_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 4 não enviado: ",GetLastError());
        }
      if(lot_fech5>0)
        {
         stop_price=NormalizeDouble(preco-stop5*ponto,digits);
         if(mytrade.SellStop(lot_fech5,stop_price,original_symbol,0,0,order_time_type,0,"SL5"))
           {
            GlobalVariableSet(sl5_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 5 não enviado: ",GetLastError());
        }
      if(lot_fech6>0)
        {
         stop_price=NormalizeDouble(preco-stop6*ponto,digits);
         if(mytrade.SellStop(lot_fech6,stop_price,original_symbol,0,0,order_time_type,0,"SL6"))
           {
            GlobalVariableSet(sl6_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 6 não enviado: ",GetLastError());
        }
     }

   if(ptype==POSITION_TYPE_SELL)
     {
      if(lot_fech1>0)
        {
         stop_price=NormalizeDouble(preco+stop1*ponto,digits);
         if(mytrade.BuyStop(lot_fech1,stop_price,original_symbol,0,0,order_time_type,0,"SL1"))
           {
            GlobalVariableSet(sl1_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 1 não enviado: ",GetLastError());
        }

      if(lot_fech2>0)
        {
         stop_price=NormalizeDouble(preco+stop2*ponto,digits);
         if(mytrade.BuyStop(lot_fech2,stop_price,original_symbol,0,0,order_time_type,0,"SL2"))
           {
            GlobalVariableSet(sl2_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 2 não enviado: ",GetLastError());
        }
      if(lot_fech3>0)
        {
         stop_price=NormalizeDouble(preco+stop3*ponto,digits);
         if(mytrade.BuyStop(lot_fech3,stop_price,original_symbol,0,0,order_time_type,0,"SL3"))
           {
            GlobalVariableSet(sl3_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 3 não enviado: ",GetLastError());
        }
      if(lot_fech4>0)
        {
         stop_price=NormalizeDouble(preco+stop4*ponto,digits);
         if(mytrade.BuyStop(lot_fech4,stop_price,original_symbol,0,0,order_time_type,0,"SL4"))
           {
            GlobalVariableSet(sl4_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 4 não enviado: ",GetLastError());
        }
      if(lot_fech5>0)
        {
         stop_price=NormalizeDouble(preco+stop5*ponto,digits);
         if(mytrade.BuyStop(lot_fech5,stop_price,original_symbol,0,0,order_time_type,0,"SL5"))
           {
            GlobalVariableSet(sl5_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 5 não enviado: ",GetLastError());
        }
      if(lot_fech6>0)
        {
         stop_price=NormalizeDouble(preco+stop6*ponto,digits);
         if(mytrade.BuyStop(lot_fech6,stop_price,original_symbol,0,0,order_time_type,0,"SL6"))
           {
            GlobalVariableSet(sl6_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 6 não enviado: ",GetLastError());
        }
     }

  }
//+------------------------------------------------------------------+
void TrailingStop(double pTrailPoints,double pMinProfit,double pStep,const ulong o_ticket)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number && pTrailPoints>0)
        {

         long posType=myposition.PositionType();
         double currentStop;
         double openPrice=NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
         double point=ponto;
         int digits=mysymbol.Digits();
         if(pStep<10) pStep=10;
         double step=pStep*point;

         double minProfit = pMinProfit * point;
         double trailStop = pTrailPoints * point;
         double trailStopPrice;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            myorder.Select(o_ticket);
            currentStop=myorder.PriceOpen();
            trailStopPrice = mysymbol.Bid() - trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=mysymbol.Bid()-openPrice;

            if(trailStopPrice>currentStop+step && currentProfit>=minProfit)
              {
               if(myorder.Select(o_ticket))
                 {
                  mytrade.OrderModify(o_ticket,trailStopPrice,0,0,order_time_type,0,0);
                 }
              }

           }
         else if(posType==POSITION_TYPE_SELL)
           {

            myorder.Select(o_ticket);
            currentStop=myorder.PriceOpen();
            trailStopPrice = mysymbol.Ask() + trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=openPrice-mysymbol.Ask();

            if((trailStopPrice<currentStop-step || currentStop==0) && currentProfit>=minProfit)
              {
               if(myorder.Select(o_ticket))
                 {
                  mytrade.OrderModify(o_ticket,trailStopPrice,0,0,order_time_type,0,0);
                 }

              }

           }
        }

     }

  }
//+------------------------------------------------------------------+

void Trail()
  {
   if(lot_fech1>0 && Trail1) TrailingStop(TraillingDistance,TraillingStart,TraillingStep,(ulong)GlobalVariableGet(sl1_tick));
   if(lot_fech2>0 && Trail2) TrailingStop(TraillingDistance,TraillingStart,TraillingStep,(ulong)GlobalVariableGet(sl2_tick));
   if(lot_fech3>0 && Trail3) TrailingStop(TraillingDistance,TraillingStart,TraillingStep,(ulong)GlobalVariableGet(sl3_tick));
   if(lot_fech4>0 && Trail4) TrailingStop(TraillingDistance,TraillingStart,TraillingStep,(ulong)GlobalVariableGet(sl4_tick));
   if(lot_fech5>0 && Trail5) TrailingStop(TraillingDistance,TraillingStart,TraillingStep,(ulong)GlobalVariableGet(sl5_tick));
   if(lot_fech6>0 && Trail6) TrailingStop(TraillingDistance,TraillingStart,TraillingStep,(ulong)GlobalVariableGet(sl6_tick));
  }
//+------------------------------------------------------------------+

void SetTP(const ENUM_POSITION_TYPE ptype,const double preco)
  {
   if(ptype==POSITION_TYPE_BUY)
     {
      if(lot_fech1>0)
        {
         take_price=NormalizeDouble(preco+take1*ponto,digits);
         if(!mytrade.SellLimit(lot_fech1,take_price,original_symbol,0,0,order_time_type,0,"TP1"))
            Print("Take Profit 1 não enviado: ",GetLastError());
        }

      if(lot_fech2>0)
        {
         take_price=NormalizeDouble(preco+take2*ponto,digits);
         if(!mytrade.SellLimit(lot_fech2,take_price,original_symbol,0,0,order_time_type,0,"TP2"))
            Print("Take Profit 2 não enviado: ",GetLastError());
        }
      if(lot_fech3>0)
        {
         take_price=NormalizeDouble(preco+take3*ponto,digits);
         if(!mytrade.SellLimit(lot_fech3,take_price,original_symbol,0,0,order_time_type,0,"TP3"))
            Print("Take Profit 3 não enviado: ",GetLastError());
        }
     }

   if(ptype==POSITION_TYPE_SELL)
     {
      if(lot_fech1>0)
        {
         take_price=NormalizeDouble(preco-take1*ponto,digits);
         if(!mytrade.BuyLimit(lot_fech1,take_price,original_symbol,0,0,order_time_type,0,"TP1"))
            Print("Take Profit 1 não enviado: ",GetLastError());
        }

      if(lot_fech2>0)
        {
         take_price=NormalizeDouble(preco-take2*ponto,digits);
         if(!mytrade.BuyLimit(lot_fech2,take_price,original_symbol,0,0,order_time_type,0,"TP2"))
            Print("Take Profit 2 não enviado: ",GetLastError());
        }
      if(lot_fech3>0)
        {
         take_price=NormalizeDouble(preco-take3*ponto,digits);
         if(!mytrade.BuyLimit(lot_fech3,take_price,original_symbol,0,0,order_time_type,0,"TP3"))
            Print("Take Profit 3 não enviado: ",GetLastError());
        }
     }

  }
//+------------------------------------------------------------------+

bool IsOrdersComment(const string comm)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.Comment()==comm)
               return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AjusteOrdens()
  {
   if(!(IsOrdersComment("SL1") && IsOrdersComment("TP1")))
     {
      if(IsOrdersComment("SL1"))DeleteOrdersComment("SL1");
      if(IsOrdersComment("TP1"))DeleteOrdersComment("TP1");
     }

   if(!(IsOrdersComment("SL2") && IsOrdersComment("TP2")))
     {
      if(IsOrdersComment("SL2"))DeleteOrdersComment("SL2");
      if(IsOrdersComment("TP2"))DeleteOrdersComment("TP2");
     }

   if(!(IsOrdersComment("SL3") && IsOrdersComment("TP3")))
     {
      if(IsOrdersComment("SL3"))DeleteOrdersComment("SL3");
      if(IsOrdersComment("TP3"))DeleteOrdersComment("TP3");
     }

  }
//+------------------------------------------------------------------+

void SetTPHorario()
  {
   if(Buy_opened() && (!Sell_opened()))
     {
      if(lot_fech4>0 && TimeCurrent()>=horario_tp4 && GlobalVariableGet(set_tp4)==0.0)
        {
         if(mytrade.Sell(lot_fech4,original_symbol,0,0,0,"TP4"))
           {
            GlobalVariableSet(set_tp4,1.0);
            DeleteOrdersComment("SL4");
           }
         else Print("Take Profit 4 não enviado: ",GetLastError());
        }
      if(lot_fech5>0 && TimeCurrent()>=horario_tp5 && GlobalVariableGet(set_tp5)==0.0)
        {
         if(mytrade.Sell(lot_fech5,original_symbol,0,0,0,"TP5"))
           {
            GlobalVariableSet(set_tp5,1.0);
            DeleteOrdersComment("SL5");
           }
         else Print("Take Profit 5 não enviado: ",GetLastError());
        }
      if(lot_fech6>0 && TimeCurrent()>=horario_tp6 && GlobalVariableGet(set_tp6)==0.0)
        {
         if(mytrade.Sell(lot_fech6,original_symbol,0,0,0,"TP6"))
           {
            GlobalVariableSet(set_tp6,1.0);
            DeleteOrdersComment("SL6");
           }
         else Print("Take Profit 6 não enviado: ",GetLastError());
        }

     }

   if(Sell_opened() && (!Buy_opened()))
     {

      if(lot_fech4>0 && TimeCurrent()>=horario_tp4 && GlobalVariableGet(set_tp4)==0.0)
        {
         if(mytrade.Buy(lot_fech4,original_symbol,0,0,0,"TP4"))
           {
            GlobalVariableSet(set_tp4,1.0);
            DeleteOrdersComment("SL4");
           }
         else Print("Take Profit 4 não enviado: ",GetLastError());
        }
      if(lot_fech5>0 && TimeCurrent()>=horario_tp5 && GlobalVariableGet(set_tp5)==0.0)
        {
         if(mytrade.Buy(lot_fech5,original_symbol,0,0,0,"TP5"))
           {
            GlobalVariableSet(set_tp5,1.0);
            DeleteOrdersComment("SL5");
           }
         else Print("Take Profit 5 não enviado: ",GetLastError());
        }
      if(lot_fech6>0 && TimeCurrent()>=horario_tp6 && GlobalVariableGet(set_tp6)==0.0)
        {
         if(mytrade.Buy(lot_fech6,original_symbol,0,0,0,"TP6"))
           {
            GlobalVariableSet(set_tp6,1.0);
            DeleteOrdersComment("SL6");
           }
         else Print("Take Profit 6 não enviado: ",GetLastError());
        }

     }

  }
//+------------------------------------------------------------------+
