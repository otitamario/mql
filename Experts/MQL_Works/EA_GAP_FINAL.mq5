//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


enum IntervGapMin
  {
   GapMin1=1,//1
   GapMin2=2,//2
   GapMin3=3,//3
   GapMin4=4,//4
   GapMin5=5,//5
   GapMin6=6,//6
   GapMin7=7,//7
   GapMin8=8,//8
   GapMin9=9,//9
   GapMin10=10//10
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum IntervGapMax
  {
   GapMax1=1,//1
   GapMax2=2,//2
   GapMax3=3,//3
   GapMax4=4,//4
   GapMax5=5,//5
   GapMax6=6,//6
   GapMax7=7,//7
   GapMax8=8,//8
   GapMax9=9,//9
   GapMax10=10//10
  };
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

   if(!CreateLabel(m_chart_id,m_subwin,m_label[5],"GAP: "+DoubleToString(Gap,_Digits),xx1,yy1,xx2,yy2))
      return(false);
   m_label[5].Color(clrMediumSpringGreen);

   xx1=LARGURA_PAINEL-INDENT_RIGHT-BUTTON_WIDTH-CONTROLS_GAP_X;
   yy1=INDENT_TOP;
   xx2=xx1+BUTTON_WIDTH;
   yy2=(int)(yy1+1.5*BUTTON_HEIGHT);

   if(!CreateButton(m_chart_id,m_subwin,BotaoFechar,"CLOSE ALL",xx1,yy1,xx2,yy2))
      return(false);
   BotaoFechar.ColorBackground(clrLimeGreen);

   xx1=LARGURA_PAINEL-INDENT_RIGHT-BUTTON_WIDTH-CONTROLS_GAP_X;
   yy1=INDENT_TOP+(BUTTON_HEIGHT+4*CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=(int)(yy1+1.5*BUTTON_HEIGHT);

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
   m_label[5].Text("GAP: "+DoubleToString(Gap,_Digits));
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
CHistoryOrderInfo myhistory;
CControlsDialog ExtDialog;
CChartObjectVLine VLine_Init,VLine_Fim;
CChartObjectTrend TrendLine;

// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=20082018;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
sinput string SEstrateg="############-------------Estratégia----------########";//Estratégia
input TipoLote tipo_lote=Dinamico;//Tipo de Cálculo do Lote
input double Lot=10;//Lote Entrada - Se Fixo
sinput string Sdep="(limita lotes dinâmicos)";//Valor Financeiro Máximo a ser Usado

input double deposito=15000;// Valor Financeiro Máximo
sinput string Smarg="(calcula lotes dinâmicos, sempre múltiplos de 3)";//Margem Financeira Para Cada Lote
input double margin_lote=150;// Margem Financeira Para Cada Lote
input Operacao operacao=Favor;//Operar a Favor ou Contra a Tendência
input string Gap_init="17:50";//Horário Gap Inicial
input string Gap_final="09:01";//Horário Gap Final
input IntervGapMin Inpgap_min=GapMin1;//Nível de desequilíbrio 1 - menor é mais agressivo
input IntervGapMax Inpgap_max=GapMax1;//Nível de desequilíbrio 2 - menor é mais agressivo
input string open_order="9:01:15";//Horário de Abertura da Ordem
input string Sfechamentos="############-------------Opções de Fechamento----------########";//Fechamento
input double lot_fech1=1;//1- Lotes Fechar por SL,TP - Se FIXO
input double stop1=100;//Stop Loss 1
input double take1=100;//Take Profit 1 
input bool Trail1=false;//Trailing Stop 1 True/False
input double lot_fech2=1;//2- Lotes Fechar por SL,TP Se FIXO
input double stop2=100;//Stop Loss 2
input double take2=100;//Take Profit 2 
input bool Trail2=false;//Trailing Stop 2 True/False
input double lot_fech3=1;//3- Lotes Fechar por SL,TP Se FIXO
input double stop3=100;//Stop Loss 3
input double take3=100;//Take Profit 3 
input bool Trail3=false;//Trailing Stop 3 True/False 
sinput string STrailing="############---------------Trailing Stop----------########";//Trailing
input double TraillingStart=0;//Lucro Minimo Iniciar trailing stop
input double TraillingDistance=75;// Distanccia em Pontos do Stop Loss
input double TraillingStep=10;// Passo para atualizar Stop Loss

input string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes no Dia

input bool UsarLucroDinamico=false;//Usar Lucro Por Lote para Fechamento
input double lucro_dinam=50.0;//Lucro Médio por Lote para Fechar Posicoes no Dia
input double prejuizo_dinam=50.0;//Prejuizo Médio Por Lote para Fechar Posicoes no Dia

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
double Ask,Bid;
double lucro_total,pontos_total,lucro_entry,lucro_total_mes,lucro_total_semana;
bool TimerOn,tradeOn;
double ponto,ticksize;
int _digits;
long curChartID;
int atr_handle;
double ATR_High[],ATR_Low[];
int heiken_handle;
double Heiken_Color[];

double High[],Low[],Open[],Close[];
string glob_entr_tot="ENT_TOT"+Symbol()+IntegerToString(Magic_Number);
string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string tp_cp_tick="tp_cp_tick"+Symbol()+IntegerToString(Magic_Number),tp_vd_tick="tp_vd_tick"+Symbol()+IntegerToString(Magic_Number);
string deals_total="deals_total"+Symbol()+IntegerToString(Magic_Number),deals_total_prev="deals_total_prev"+Symbol()+IntegerToString(Magic_Number);
string gv_today="gv_today"+Symbol()+IntegerToString(Magic_Number),gv_today_prev="gv_today_prev"+Symbol()+IntegerToString(Magic_Number);
string sl1_tick="sl1_tick"+Symbol()+IntegerToString(Magic_Number),sl2_tick="sl2_tick"+Symbol()+IntegerToString(Magic_Number);
string sl3_tick="sl3_tick"+Symbol()+IntegerToString(Magic_Number);

double buyprice,sellprice,oldprice;
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
datetime time_novodia[4];
double lotes_stop,lotes_take;
int res_code;
int cont;
datetime hora_inicial,hora_final;
double stop_price,take_price;
int total_deals,cont_deals;
ulong ticket_history_deal,deal_magic;
MqlDateTime TimeNow;
ENUM_ORDER_TYPE_TIME order_time_type;
datetime gap_init,gap_fin,hor_open_order;
int idx_gap_init,idx_gap_fin;
double Gap;
bool tradebarra;
double lote_entrada,lote_saida;
double InpLot_fech1,InpLot_fech2,InpLot_fech3;
MqlRates         rates_init[];
MqlRates         rates_fin[];

double gap_min,gap_max;
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

   mytrade.SetTypeFilling(ORDER_FILLING_RETURN);
   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
   _digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);

   int find_wdo=StringFind(original_symbol,"WDO");
   int find_dol=StringFind(original_symbol,"DOL");
   if(find_dol>=0|| find_wdo>=0) ponto=ponto*1000;


   curChartID=ChartID();

   ArraySetAsSeries(rates_init,true);
   ArraySetAsSeries(rates_fin,true);
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Open,true);

   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

// parametros incorretos desnecessarios na otimizacao
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   switch(Inpgap_min)
     {
      case   GapMin1:
         gap_min=5;
         break;

      case   GapMin2:
         gap_min=30;
         break;

      case   GapMin3:
         gap_min=50;
         break;
      case   GapMin4:
         gap_min=100;
         if(Inpgap_max==10)
           {
            string erro="Escolha um nível de desequilíbrio 2 menor que 10";
            MessageBox(erro);
            Print(erro);
            return(INIT_PARAMETERS_INCORRECT);
           }
         break;
      case   GapMin5:
         gap_min=140;
         if(Inpgap_max==10)
           {
            string erro="Escolha um nível de desequilíbrio 2 menor que 10";
            MessageBox(erro);
            Print(erro);
            return(INIT_PARAMETERS_INCORRECT);
           }
         break;
      case   GapMin6:
         gap_min=170;
         if(Inpgap_max==10)
           {
            string erro="Escolha um nível de desequilíbrio 2 menor que 10";
            MessageBox(erro);
            Print(erro);
            return(INIT_PARAMETERS_INCORRECT);
           }
         break;
      case   GapMin7:
         gap_min=250;
         if(Inpgap_max>=9)
           {
            string erro="Escolha um nível de desequilíbrio 2 menor que 9";
            MessageBox(erro);
            Print(erro);
            return(INIT_PARAMETERS_INCORRECT);
           }

         break;
      case   GapMin8:
         gap_min=400;
         if(Inpgap_max>=8)
           {
            string erro="Escolha um nível de desequilíbrio 2 menor que 8";
            MessageBox(erro);
            Print(erro);
            return(INIT_PARAMETERS_INCORRECT);
           }

         break;
      case   GapMin9:
         gap_min=600;
         if(Inpgap_max>=6)
           {
            string erro="Escolha um nível de desequilíbrio 2 menor que 6";
            MessageBox(erro);
            Print(erro);
            return(INIT_PARAMETERS_INCORRECT);
           }

         break;
      case   GapMin10:
         gap_min=750;
         if(Inpgap_max>=6)
           {
            string erro="Escolha um nível de desequilíbrio 2 menor que 6";
            MessageBox(erro);
            Print(erro);
            return(INIT_PARAMETERS_INCORRECT);
           }
         break;
     }

   switch(Inpgap_max)
     {
      case   GapMax1:
         gap_max=2000;
         break;

      case   GapMax2:
         gap_max=1500;
         break;

      case   GapMax3:
         gap_max=1200;
         break;
      case   GapMax4:
         gap_max=1000;
         break;
      case   GapMax5:
         gap_max=800;
         break;
      case   GapMax6:
         gap_max=600;
         break;
      case   GapMax7:
         gap_max=450;
         break;
      case   GapMax8:
         gap_max=320;
         break;
      case   GapMax9:
         gap_max=200;
         break;
      case   GapMax10:
         gap_max=100;
         break;
     }

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(deposito<margin_lote)
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

   if(Lot<mysymbol.LotsMin())
     {
      string erro="Lote deve ser maior ou igual a "+DoubleToString(mysymbol.LotsMin(),2);
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);

     }

   lote_entrada=CalculoLote(tipo_lote);
   if(tipo_lote==Fixo)
     {
      InpLot_fech1=lot_fech1;
      InpLot_fech2=lot_fech2;
      InpLot_fech3=lot_fech3;
     }
   else
     {
      int lote_aux=(int)(lote_entrada/3);
      InpLot_fech1=(double)lote_aux;
      InpLot_fech2=(double)lote_aux;
      InpLot_fech3=(double)lote_aux;
      lote_entrada=((double)(3*lote_aux));
     }

   if(InpLot_fech1+InpLot_fech2+InpLot_fech3!=lote_entrada)
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
   int k=ObjectsDeleteAll(0,"",0,OBJ_TREND);

//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {

   if(trans.symbol!=original_symbol)return;

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
      deal_magic=0;
      long deal_reason=-1;
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

         if(deal_symbol!=original_symbol) return;
         if(deal_magic==Magic_Number)
           {
            GlobalVariableSet("last_deal_time",(double)deal_time);

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

            if((deal_comment=="BUY"+exp_name || deal_comment=="SELL"+exp_name))
              {
               GlobalVariableSet(glob_entr_tot,GlobalVariableGet(glob_entr_tot));
              }

            if(trans.order==(ulong)GlobalVariableGet(cp_tick))

              {
               myposition.SelectByTicket(trans.order);
               cont=0;
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

            if(trans.order==(ulong)GlobalVariableGet(vd_tick))
              {
               myposition.SelectByTicket(trans.order);
               sellprice=myposition.PriceOpen();
               cont=0;
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

            if(StringFind(deal_comment,"SL")>=0 || StringFind(deal_comment,"TP")>=0)
              {
               AjusteOrdens();
              }

           } //Fim deal magic

        }
      else
         return;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   mysymbol.Refresh();
   mysymbol.RefreshRates();
   if(mysymbol.Bid()>=mysymbol.Ask()) return;//Leilão

   gap_init=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Gap_init);
   gap_fin=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Gap_final);
   hor_open_order=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+open_order);

   if(gap_init>gap_fin)gap_init=StringToTime(TimeToString(iTime(original_symbol,PERIOD_D1,1),TIME_DATE)+" "+Gap_init);

   if(TimeCurrent()==gap_fin)
     {
      idx_gap_init=iBarShift(original_symbol,periodoRobo,gap_init);
      idx_gap_fin=iBarShift(original_symbol,periodoRobo,gap_fin);

      int  copied=CopyRates(original_symbol,periodoRobo,gap_init,1,rates_init);
      int  copied_fin=CopyRates(original_symbol,periodoRobo,gap_fin,1,rates_fin);

      //Gap=iOpen(original_symbol,periodoRobo,idx_gap_fin)-iClose(original_symbol,periodoRobo,idx_gap_init);
      Gap=rates_fin[0].open-rates_init[0].close;

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
   if(TimeCurrent()==hor_open_order)
     {
      if(BuySignal() && !Buy_opened() && tradebarra)
        {
         if(mytrade.Buy(lote_entrada,original_symbol,0,0,0,"BUY"+exp_name))
           {
            GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
            tradebarra=false;
           }
         else Print("Erro enviar ordem ",GetLastError());
        }

      if(SellSignal() && !Sell_opened() && tradebarra)
        {
         if(mytrade.Sell(lote_entrada,original_symbol,0,0,0,"SELL"+exp_name))
           {
            GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
            tradebarra=false;
           }
         else Print("Erro enviar ordem ",GetLastError());

        }

     }

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
   if(mysymbol.Bid()>=mysymbol.Ask()) return;//Leilão

   gap_init=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Gap_init);
   gap_fin=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Gap_final);
   if(gap_init>gap_fin)gap_init=StringToTime(TimeToString(iTime(original_symbol,PERIOD_D1,1),TIME_DATE)+" "+Gap_init);

   if(novodia || GlobalVariableGet(gv_today)!=GlobalVariableGet(gv_today_prev))
     {
      GlobalVariableSet(glob_entr_tot,0.0);
      GlobalVariableSet(deals_total_prev,0.0);

      tradeOn=true;

      lote_entrada=CalculoLote(tipo_lote);
      if(tipo_lote==Fixo)
        {
         InpLot_fech1=lot_fech1;
         InpLot_fech2=lot_fech2;
         InpLot_fech3=lot_fech3;
        }
      else
        {
         int lote_aux=(int)(lote_entrada/3);
         InpLot_fech1=(double)lote_aux;
         InpLot_fech2=(double)lote_aux;
         InpLot_fech3=(double)lote_aux;
         lote_entrada=((double)(3*lote_aux));
        }

      //      gap_init=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Gap_init);
      //    if(first_tick)gap_fin=TimeCurrent();
      //  else gap_fin=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+Gap_final);
      hor_open_order=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+open_order);

      tradebarra=true;

     }

   GlobalVariableSet(gv_today_prev,GlobalVariableGet(gv_today));

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

   if(UsarLucroDinamico && (lucro_total>=lucro_dinam*lote_entrada || lucro_total<=-prejuizo_dinam*lote_entrada))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
      Print("EA encerrado lucro ou prejuizo médio por lote");
     }

   TimerOn=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer)
     {
      TimerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!TimerOn && daytrade)
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
      Bid= last_tick.bid;
      Ask=last_tick.ask;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      Print("Falhou obter o tick");
      return;
     }
   double spread=Ask-Bid;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Bid==0 || Ask==0)
     {
      Print("BID ou ASK=0 : ",Bid," ",Ask);
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

   if(tradeOn && TimerOn)

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
   signal=MathAbs(Gap)>=gap_min*ponto && MathAbs(Gap)<=gap_max*ponto;
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
   signal=MathAbs(Gap)>=gap_min*ponto && MathAbs(Gap)<=gap_max*ponto;
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
   b_get=CopyHigh(Symbol(),periodoRobo,0,5,High)<=0 || 
         CopyOpen(Symbol(),periodoRobo,0,5,Open)<=0 || 
         CopyLow(Symbol(),periodoRobo,0,5,Low)<=0 || 
         CopyClose(Symbol(),periodoRobo,0,5,Close)<=0;
   return(b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculoLote(TipoLote tplote)
  {
   double lotes=mysymbol.LotsMin();
   double saldo_util=MathMin(deposito,myaccount.FreeMargin());
   if(tplote==Fixo)lotes=Lot;
   else
     {
      lotes=MathRound((saldo_util/margin_lote)/mysymbol.LotsMin())*mysymbol.LotsMin();
      lotes=MathMax(lotes,mysymbol.LotsMin());
      lotes=MathMin(lotes,mysymbol.LotsMax());

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
         if(myorder.Magic()==Magic_Number && myorder.Symbol()==mysymbol.Name() && MathAbs(myorder.PriceOpen()-Ask)>distancia*ponto)
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
   total_deals=HistoryDealsTotal();
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
   total_deals=HistoryDealsTotal();
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
   total_deals=HistoryDealsTotal();
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
   datetime tm_start=(datetime)WeekStartTime(TimeCurrent());
   HistorySelect(tm_start,tm_end);
   total_deals=HistoryDealsTotal();
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
   datetime tm_start=(datetime)WeekStartTime(TimeCurrent());
   HistorySelect(tm_start,tm_end);
   total_deals=HistoryDealsTotal();
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
   datetime tm_start=(datetime)WeekStartTime(TimeCurrent());
   HistorySelect(tm_start,tm_end);
   total_deals=HistoryDealsTotal();
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
   total_deals=HistoryDealsTotal();
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
   bool filter=false;
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
      if(InpLot_fech1>0)
        {
         stop_price=NormalizeDouble(preco-stop1*ponto,_digits);
         if(mytrade.SellStop(InpLot_fech1,stop_price,original_symbol,0,0,order_time_type,0,"SL1"))
           {
            GlobalVariableSet(sl1_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 1 não enviado: ",GetLastError());
        }

      if(InpLot_fech2>0)
        {
         stop_price=NormalizeDouble(preco-stop2*ponto,_digits);
         if(mytrade.SellStop(InpLot_fech2,stop_price,original_symbol,0,0,order_time_type,0,"SL2"))
           {
            GlobalVariableSet(sl2_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 2 não enviado: ",GetLastError());
        }
      if(InpLot_fech3>0)
        {
         stop_price=NormalizeDouble(preco-stop3*ponto,_digits);
         if(mytrade.SellStop(InpLot_fech3,stop_price,original_symbol,0,0,order_time_type,0,"SL3"))
           {
            GlobalVariableSet(sl3_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 3 não enviado: ",GetLastError());
        }
     }

   if(ptype==POSITION_TYPE_SELL)
     {
      if(InpLot_fech1>0)
        {
         stop_price=NormalizeDouble(preco+stop1*ponto,_digits);
         if(mytrade.BuyStop(InpLot_fech1,stop_price,original_symbol,0,0,order_time_type,0,"SL1"))
           {
            GlobalVariableSet(sl1_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 1 não enviado: ",GetLastError());
        }

      if(InpLot_fech2>0)
        {
         stop_price=NormalizeDouble(preco+stop2*ponto,_digits);
         if(mytrade.BuyStop(InpLot_fech2,stop_price,original_symbol,0,0,order_time_type,0,"SL2"))
           {
            GlobalVariableSet(sl2_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 2 não enviado: ",GetLastError());
        }
      if(InpLot_fech3>0)
        {
         stop_price=NormalizeDouble(preco+stop3*ponto,_digits);
         if(mytrade.BuyStop(InpLot_fech3,stop_price,original_symbol,0,0,order_time_type,0,"SL3"))
           {
            GlobalVariableSet(sl3_tick,(double) mytrade.ResultOrder());
           }
         else Print("Stop Loss 3 não enviado: ",GetLastError());
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
         double openPrice=NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,_digits);
         double point=ponto;
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
            trailStopPrice = NormalizeDouble(trailStopPrice,_digits);
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
            trailStopPrice = NormalizeDouble(trailStopPrice,_digits);
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
   if(InpLot_fech1>0 && Trail1) TrailingStop(TraillingDistance,TraillingStart,TraillingStep,(ulong)GlobalVariableGet(sl1_tick));
   if(InpLot_fech2>0 && Trail2) TrailingStop(TraillingDistance,TraillingStart,TraillingStep,(ulong)GlobalVariableGet(sl2_tick));
   if(InpLot_fech3>0 && Trail3) TrailingStop(TraillingDistance,TraillingStart,TraillingStep,(ulong)GlobalVariableGet(sl3_tick));
  }
//+------------------------------------------------------------------+

void SetTP(const ENUM_POSITION_TYPE ptype,const double preco)
  {
   if(ptype==POSITION_TYPE_BUY)
     {
      if(InpLot_fech1>0)
        {
         take_price=NormalizeDouble(preco+take1*ponto,_digits);
         if(!mytrade.SellLimit(InpLot_fech1,take_price,original_symbol,0,0,order_time_type,0,"TP1"))
            Print("Take Profit 1 não enviado: ",GetLastError());
        }

      if(InpLot_fech2>0)
        {
         take_price=NormalizeDouble(preco+take2*ponto,_digits);
         if(!mytrade.SellLimit(InpLot_fech2,take_price,original_symbol,0,0,order_time_type,0,"TP2"))
            Print("Take Profit 2 não enviado: ",GetLastError());
        }
      if(InpLot_fech3>0)
        {
         take_price=NormalizeDouble(preco+take3*ponto,_digits);
         if(!mytrade.SellLimit(InpLot_fech3,take_price,original_symbol,0,0,order_time_type,0,"TP3"))
            Print("Take Profit 3 não enviado: ",GetLastError());
        }
     }

   if(ptype==POSITION_TYPE_SELL)
     {
      if(InpLot_fech1>0)
        {
         take_price=NormalizeDouble(preco-take1*ponto,_digits);
         if(!mytrade.BuyLimit(InpLot_fech1,take_price,original_symbol,0,0,order_time_type,0,"TP1"))
            Print("Take Profit 1 não enviado: ",GetLastError());
        }

      if(InpLot_fech2>0)
        {
         take_price=NormalizeDouble(preco-take2*ponto,_digits);
         if(!mytrade.BuyLimit(InpLot_fech2,take_price,original_symbol,0,0,order_time_type,0,"TP2"))
            Print("Take Profit 2 não enviado: ",GetLastError());
        }
      if(InpLot_fech3>0)
        {
         take_price=NormalizeDouble(preco-take3*ponto,_digits);
         if(!mytrade.BuyLimit(InpLot_fech3,take_price,original_symbol,0,0,order_time_type,0,"TP3"))
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
