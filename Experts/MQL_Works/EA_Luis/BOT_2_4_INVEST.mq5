//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
enum Sentido
  {
   Compra,//Operar Comprado
   Venda,//Operar Vendido
   Compra_e_Venda //Operar Comprado e Vendido
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Sinal
  {
   Atual,//Barra Atual
   Anterior//Barra Anterior
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Moeda
  {
   EUR,//Europa
   CAN,//Canadá
   USD,//Estados Unidos
   BRL//Brasil
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Touros
  {
   Touro_1,//1 Touro
   Touro_2,//2 Touros
   Touro_3//3 Touros
  };

#resource "\\Indicators\\INDICADOR1_T.ex5"
#resource "\\Indicators\\INDICADOR2_T.ex5"
#resource "\\Indicators\\INDCADOR BESOS.ex5"
#resource "\\Indicators\\INDICADOR BOLU.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum enTimeFrames
  {
   tf_cu  = PERIOD_CURRENT, // Current time frame
   tf_m1  = PERIOD_M1,      // 1 minute
   tf_m2  = PERIOD_M2,      // 2 minutes
   tf_m3  = PERIOD_M3,      // 3 minutes
   tf_m4  = PERIOD_M4,      // 4 minutes
   tf_m5  = PERIOD_M5,      // 5 minutes
   tf_m6  = PERIOD_M6,      // 6 minutes
   tf_m10 = PERIOD_M10,     // 10 minutes
   tf_m12 = PERIOD_M12,     // 12 minutes
   tf_m15 = PERIOD_M15,     // 15 minutes
   tf_m20 = PERIOD_M20,     // 20 minutes
   tf_m30 = PERIOD_M30,     // 30 minutes
   tf_h1  = PERIOD_H1,      // 1 hour
   tf_h2  = PERIOD_H2,      // 2 hours
   tf_h3  = PERIOD_H3,      // 3 hours
   tf_h4  = PERIOD_H4,      // 4 hours
   tf_h6  = PERIOD_H6,      // 6 hours
   tf_h8  = PERIOD_H8,      // 8 hours
   tf_h12 = PERIOD_H12,     // 12 hours
   tf_d1  = PERIOD_D1,      // daily
   tf_w1  = PERIOD_W1,      // weekly
   tf_mn  = PERIOD_MN1,     // monthly
   tf_cp1 = -1,             // Next higher time frame
   tf_cp2 = -2,             // Second higher time frame
   tf_cp3 = -3              // Third higher time frame
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum enMaTypes
  {
   ma_sma,    // Simple moving average
   ma_ema,    // Exponential moving average
   ma_smma,   // Smoothed MA
   ma_lwma    // Linear weighted MA
  };

#import "Investing.dll"

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include<Trade\AccountInfo.mqh>
#include<ChartObjects\ChartObjectsLines.mqh>
#include <Controls\Defines.mqh>

#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
//#undef CONTROLS_LABEL_COLOR  

color borda_bg=clrNONE;//Cor Borda
color painel_bg=clrNONE;//Cor Painel clrNONE=Transparente
color cor_txt_borda_bg=clrYellowGreen;//Cor Texto Borda
                                      //color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG          borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg
#include <Auxiliares.mqh>

CLabel            m_label[50];
CRect retang;
CButton BotaoFechar;
CButton BotaoDel;
CButton BotaoNews;

#define TENTATIVAS 10 // Tentativas envio ordem
#define TAM_MAX_PRECOS 500 //Tamanho Maximo Array de PRECOS ACIMA ou ABAIXO
#define LARGURA_PAINEL 450 // Largura Painel
#define ALTURA_PAINEL 210 // Altura Painel
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

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"RESULTADO DIÁRIO: "+DoubleToString(lucro_total,2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[0].Color(clrKhaki);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"GAINS NO DIA: "+DoubleToString(GainsOrdens()+(LucroPositions()>0?LucroPositions():0),2)+"     LOSS NO DIA: "+DoubleToString(LossOrdens()+(LucroPositions()<0?LucroPositions():0),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[1].Color(clrPaleTurquoise);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"Nome: "+AccountInfoString(ACCOUNT_NAME),xx1,yy1,xx2,yy2))
      return(false);
   m_label[2].Color(clrDeepSkyBlue);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+3*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;
   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"Servidor: "+AccountInfoString(ACCOUNT_SERVER)+" Login: "+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)),xx1,yy1,xx2,yy2))
      return(false);
   m_label[3].Color(clrYellow);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+4*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],"RESULTADO MENSAL: "+DoubleToString(lucro_total_mes,2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[4].Color(clrYellow);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+5*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[5],"RESULTADO SEMANAL: "+DoubleToString(lucro_total_semana,2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[5].Color(clrMediumSpringGreen);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+6*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;
   m_label[0].Color(clrMediumSpringGreen);

   if(!CreateLabel(m_chart_id,m_subwin,m_label[6],"GAINS NA SEMANA: "+DoubleToString(GainsOrdensSemana()+(LucroPositions()>0?LucroPositions():0),2)+"     LOSS NA SEMANA: "+DoubleToString(LossOrdensSemana()+(LucroPositions()<0?LucroPositions():0),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[6].Color(clrMediumSpringGreen);

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

   xx1=LARGURA_PAINEL-INDENT_RIGHT-BUTTON_WIDTH-CONTROLS_GAP_X;
   yy1=INDENT_TOP+2*(BUTTON_HEIGHT+4*CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+1.5*BUTTON_HEIGHT;

   if(!CreateButton(m_chart_id,m_subwin,BotaoNews,"Notícias",xx1,yy1,xx2,yy2))
      return(false);
   BotaoNews.ColorBackground(clrRed);
   BotaoNews.Color(clrYellow);



//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnTick(void)
  {
   m_label[0].Text("RESULTADO DIÁRIO: "+DoubleToString(lucro_total,2));
   m_label[1].Text("GAINS NO DIA: "+DoubleToString(GainsOrdens()+(LucroPositions()>0?LucroPositions():0),2)+"     LOSS NO DIA: "+DoubleToString(LossOrdens()+(LucroPositions()<0?LucroPositions():0),2));
   m_label[2].Text("Nome: "+AccountInfoString(ACCOUNT_NAME));
   m_label[3].Text("Servidor: "+AccountInfoString(ACCOUNT_SERVER)+" Login: "+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)));
   m_label[4].Text("RESULTADO MENSAL: "+DoubleToString(lucro_total_mes,2));
   m_label[5].Text("RESULTADO SEMANAL: "+DoubleToString(lucro_total_semana,2));
   m_label[6].Text("GAINS NA SEMANA: "+DoubleToString(GainsOrdensSemana()+(LucroPositions()>0?LucroPositions():0),2)+"     LOSS NA SEMANA: "+DoubleToString(LossOrdensSemana()+(LucroPositions()<0?LucroPositions():0),2));

  }
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(CControlsDialog)
ON_EVENT(ON_CLICK,BotaoFechar,OnClickBotaoFechar)
ON_EVENT(ON_CLICK,BotaoDel,OnClickBotaoDel)
ON_EVENT(ON_CLICK,BotaoNews,OnClickBotaoNews)
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnClickBotaoNews()
  {
   string message=NewsInvesting(pais,touros);
   MessageBox(message);
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
CChartObjectVLine VLine[];

CControlsDialog ExtDialog;
// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=23072018;
input double Lot=1;//Lote Entrada
input double _Stop=100;//Stop Loss em Pontos
input double _TakeProfit=2000; //Take Profit em Pontos
input uint time_order=240;//Tempo em Segundos para Entrada mudar TakeProfit
input uint time_order_sem=480;//Tempo em Segundos Sem Entrada. Mudar TakeProfit
input uint time_order_zero=30;//Tempo em Minutos Mover Stop para 0 a 0
input double porc_take=40;//Porcentagem para mudar TakeProfit
input uint n_minutes=10;//Minutos de pausa após fechar um trade
input Sentido operar=Compra_e_Venda;// Operar Comprado, Vendido
input Sinal sinal=Atual;//Barra Atual ou Anterior
input bool reverter=false;//Reverter no Sinal Contrário
input bool inverter=false;//Inverter Sinal

sinput string sinvest="############------Notícias Investig.com------#################";//Notícias
input bool UsarNew=true;//Usar filtro de Notícias
input Moeda Inp_pais=USD;//País das Notícias
input Touros Inp_touros=Touro_3;//Touros
input uint minutos_news=15;//Tempo em Minutos para pausar o EA antes e depois da notícia

sinput string sprotec="############------Proteção de Posição------#################";//Proteção
input uint n_ticks_stop=8;//Número de ticks Além do Stop para fechar no Stop Loss
input uint n_ticks_take=8;//Número de ticks Além do Take para fechar no Take Profit

sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";//Lucro
input bool UsarLucro=true;//Usar Lucro para Fechamento True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes

sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário

input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:00";//Horario Inicial
input string end_hour="17:30";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario

input bool UsePause1=false;//Usar Pausa 1
input string start_hour1="8:30";//Initial Pause Hour 1
input string end_hour1="10:30";//Final Pause Hour 1
input bool UsePause2=false;//Usar Pausa 2
input string start_hour2="18:00";//Initial Pause Hour 2
input string end_hour2="20:30";//Final Pause Hour 2
input bool UsePause3=false;//Usar Pausa 3
input string start_hour3="23:00";//Initial Pause Hour 3
input string end_hour3="03:00";//Final Pause Hour 3
sinput string sporclim="############------Porcentagem Limite------#################";//Porcentagem Limite
input double porc_lim=2.36;//Porcentagem Limite para Entrada
sinput string STrailing="############---------------Trailing Stop----------########";//Trailing

input bool   Use_TraillingStop=true; //Usar Trailing 
input int TraillingStart=0;//Lucro Minimo Iniciar trailing stop
input int TraillingDistance=100;// Distanccia em Pontos do Stop Loss
input int TraillingStep=10;// Passo para atualizar Stop Loss
sinput string SAumento="############---------------Aumento de Posição Contra----------########";//Aumento Contra
input double pts_saida_aumento=150;//Pontos de Saída Dos Aumentos(0 não sair)
input double Lot_entry1=1;//Lotes Entrada 1 (0 não entrar)
input double pts_entry1=50;//Pontos Entrada 1
input double Lot_entry2=1;//Lotes Entrada 2 (0 não entrar)
input double pts_entry2=80;//Pontos Entrada 2 
input double Lot_entry3=1;//Lotes Entrada 3 (0 não entrar)
input double pts_entry3=110;//Pontos Entrada 3
input double Lot_entry4=1;//Lotes Entrada 4 (0 não entrar)
input double pts_entry4=140;//Pontos Entrada 4
input double Lot_entry5=1;//Lotes Entrada 5 (0 não entrar)
input double pts_entry5=170;//Pontos Entrada 5
input double Lot_entry6=1;//Lotes Entrada 6 (0 não entrar)
input double pts_entry6=200;//Pontos Entrada 6
sinput string SAumentofavor="############---------------Aumento de Posição A Favor----------########";//Aumento Favor
input double pts_saida_aumento_fv=150;//Pontos de Saída Dos Aumentos(0 não sair)
input double Lot_entry1_fv=1;//Lotes Entrada 1 (0 não entrar)
input double pts_entry1_fv=50;//Pontos Entrada 1
input double Lot_entry2_fv=1;//Lotes Entrada 2 (0 não entrar)
input double pts_entry2_fv=80;//Pontos Entrada 2 
input double Lot_entry3_fv=1;//Lotes Entrada 3 (0 não entrar)
input double pts_entry3_fv=110;//Pontos Entrada 3
input double Lot_entry4_fv=1;//Lotes Entrada 4 (0 não entrar)
input double pts_entry4_fv=140;//Pontos Entrada 4

sinput string sbreak="########---------Break Even---------------###############";//BreakEven
input    bool              UseBreakEven=false;                          //Usar BreakEven
input    int               BreakEvenPoint1         =100;                            //Pontos para BreakEven 1
input    int               ProfitPoint1            =80;                             //Pontos de Lucro da Posicao 1
input    int               BreakEvenPoint2         =200;                            //Pontos para BreakEven 2
input    int               ProfitPoint2            =150;                            //Pontos de Lucro da Posicao 2
input    int               BreakEvenPoint3         =300;                            //Pontos para BreakEven 3
input    int               ProfitPoint3            =250;                            //Pontos de Lucro da Posicao 3
input    int               BreakEvenPoint4         =500;                            //Pontos para BreakEven 4
input    int               ProfitPoint4            =400;                            //Pontos de Lucro da Posicao 4
input    int               BreakEvenPoint5         =700;                            //Pontos para BreakEven 5
input    int               ProfitPoint5            =550;                            //Pontos de Lucro da Posicao 5
sinput string srealpa="########---------Realização Parcial---------------###############";//Realização Parcial
input bool UsarRealizParc=false;//Usar Realização Parcial
input double DistanceRealizeParcial=70;//Distância Realização Parcial em Pontos
input double porc_parcial=0.5;//Porcentagem Lotes Realização Parcial

sinput string sindic1="########---------INDICADOR 1---------------###############";//Indicador 1
input int inpRwiLength=25;       // DeCesari Indicador
sinput string sindic2="########---------INDICADOR 2---------------###############";//Indicador 2
input int       inpMaPreSmoothPeriod = 7;           // Pre smoothing average period
input enMaTypes inpMaPreSmoothMethod = ma_lwma;     // Pre smoothing average method
input int       inpMaPosSmoothPeriod = 7;           // Pos smoothing average period
input enMaTypes inpMaPosSmoothMethod = ma_lwma;     // Pos smoothing average method
input int       inpMaPeriod          = 2;           // Signal period
input enMaTypes inpMaMethod          = ma_smma;     // Signal method
sinput string sindicbel="########---------BESOS ---------------###############";//Besos
input int RISK=4;
input double AtrRatio=0.24;
input int Shift=0;
sinput string sindicmed="########---------BOLU ---------------###############";//Bolu
input enTimeFrames       inpTimeFrame      = tf_cu;       // Time frame
input int                inpFastPeriod     = 19;          // Fast DEMA period
input int                inpSlowPeriod     = 39;          // Slow DEMA period
input int                inpSignalPeriod   = 9;           // Signal period
input int                inpLookBackPeriod = 50;          // Lookback period
input double             inpEarlyLevel     = 25;          // Early levels %
input ENUM_APPLIED_PRICE inpPrice          = PRICE_CLOSE; // Price 
input bool               inpInterpolate    = true;        // Interpolate in multi time frame mode?



                                                          //Variaveis 
string original_symbol;
double ask,bid;
double lucro_total,lucro_total_semana,lucro_total_mes;
bool timerOn,tradeOn,timerPaus;
double ponto,ticksize,digits;
double high[],low[],open[],close[];
int ind1_handle,ind2_handle;
double Ind1_RandomWalk_Up[],Ind1_RandomWalk_Down[];
double Ind2_Color_Hist[],Ind2_Color_Line[];
int bolu_handle,besos_handle;
double  Besos_Up[],Besos_Down[],media_buffer[];

long curChartID;
ulong trade_ticket;
string glob_entr_tot="ENT_TOT"+Symbol()+IntegerToString(Magic_Number);
string glob_tot_gain="glob_tot_gain"+Symbol()+IntegerToString(Magic_Number);
string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string tp_vd_tick="tp_vd_tick"+Symbol()+IntegerToString(Magic_Number),tp_cp_tick="tp_cp_tick"+Symbol()+IntegerToString(Magic_Number);
string stp_vd_tick="stp_vd_tick"+Symbol()+IntegerToString(Magic_Number),stp_cp_tick="stp_cp_tick"+Symbol()+IntegerToString(Magic_Number);
string glob_pr_cp="preco_compra"+Symbol()+IntegerToString(Magic_Number),glob_pr_vd="preco_venda"+Symbol()+IntegerToString(Magic_Number);
string glob_pr_max="preco_max"+Symbol()+IntegerToString(Magic_Number);
string gv_today="gv_today"+Symbol()+IntegerToString(Magic_Number),gv_today_prev="gv_today_prev"+Symbol()+IntegerToString(Magic_Number);
string deals_total="deals_total"+Symbol()+IntegerToString(Magic_Number),deals_total_prev="deals_total_prev"+Symbol()+IntegerToString(Magic_Number);

double buyprice,sellprice,oldprice;
string informacoes=" ";
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
datetime time_novodia[4];
int res_code;
int cont;
datetime hora_inicial,hora_final;
double preco_acima[TAM_MAX_PRECOS],preco_abaixo[TAM_MAX_PRECOS],precos[2*TAM_MAX_PRECOS];
double vol_pos,vol_stp,preco_stp,preco_medio;
double   PointBreakEven[5],PointProfit[5];
MqlDateTime TimeNow;
uint total_deals,cont_deals;
ulong ticket_history_deal,deal_magic;
bool time_new_ent;
datetime hora_inicial1,hora_final1,hora_inicial2,hora_final2,hora_inicial3,hora_final3;
bool timer1,timer2,timer3;
ENUM_ORDER_TYPE_TIME order_time_type;
int idx;
bool buysignal,sellsignal;
string pais;
int touros;
bool investing_filter,TemNoticia;
datetime Hora_in[],Hora_fin[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(!TestaLogin())return (INIT_FAILED);

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

   switch(Inp_touros)
     {
      case Touro_1:
         touros=1;break;
      case Touro_2:
         touros=2;break;
      case Touro_3:
         touros=3;break;
     }

   if(UsarNew && HorasInvesting(pais,touros))
     {
      investing_filter=false;
      int j=ObjectsDeleteAll(ChartID(),0,OBJ_VLINE);
      ArrayResize(VLine,ArraySize(Hora_fin));
      for(int i=0;i<ArraySize(Hora_fin);i++)
        {
         if(Hora_in[i]>0 && Hora_fin[i]>0)
           {
            Print("inicio "+TimeToString(Hora_in[i])+" fim "+TimeToString(Hora_fin[i]));
            investing_filter=investing_filter || (TimeCurrent()>=Hora_in[i] && TimeCurrent()<=Hora_fin[i]);
            TemNoticia=true;
            VLine[i].Create(ChartID(),"News_"+IntegerToString(i),0,Hora_in[i]+minutos_news*60);
            VLine[i].Color(clrBlue);
           }
        }

     }
   else
     {
      Alert("Sem notícias filtradas");
      investing_filter=false;
      TemNoticia=false;
     }

   if(UsarNew)MessageBox(NewsInvesting(pais,touros));

   TimeToStruct(TimeCurrent(),TimeNow);
   GlobalVariableSet(gv_today_prev,(double)TimeNow.day_of_year);

   original_symbol=Symbol();

   if(SymbolInfoInteger(original_symbol,SYMBOL_EXPIRATION_MODE)==2)order_time_type=1;
   else order_time_type=0;

   trade_ticket=0;
   tradeOn=true;
   time_new_ent=true;

   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.SetDeviationInPoints(100*SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE));
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
   if(sinal==Atual)idx=1;
   else idx=2;
   ArraySetAsSeries(Ind1_RandomWalk_Up,true);
   ArraySetAsSeries(Ind1_RandomWalk_Down,true);
   ArraySetAsSeries(Ind2_Color_Hist,true);
   ArraySetAsSeries(Ind2_Color_Line,true);

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ArrayInitialize(preco_abaixo,0);
   ArrayInitialize(preco_acima,0);

   curChartID=ChartID();

   ind1_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\INDICADOR1_T.ex5",inpRwiLength);
   ChartIndicatorAdd(ChartID(),ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),ind1_handle);
   ind2_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\INDICADOR2_T.ex5",inpMaPreSmoothPeriod,inpMaPreSmoothMethod,inpMaPosSmoothPeriod,inpMaPosSmoothMethod,inpMaPeriod,inpMaMethod);
   ChartIndicatorAdd(ChartID(),ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),ind2_handle);

   besos_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\INDCADOR BESOS.ex5",RISK,AtrRatio,Shift);
   ChartIndicatorAdd(ChartID(),0,besos_handle);

   bolu_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\INDICADOR BOLU.ex5",inpTimeFrame,inpFastPeriod,inpSlowPeriod,inpSignalPeriod,inpLookBackPeriod,inpEarlyLevel,inpPrice,inpInterpolate);            // Channel bottom size

   ChartIndicatorAdd(ChartID(),ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),bolu_handle);

   ArraySetAsSeries(media_buffer,true);
   ArraySetAsSeries(Besos_Down,true);
   ArraySetAsSeries(Besos_Up,true);

   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

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
         return(INIT_PARAMETERS_INCORRECT);

        }

     }

   for(int i=0;i<4;i++)
     {
      if(PointBreakEven[i+1]<=PointBreakEven[i])
        {
         string erro="Pontos de Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);

        }

     }

   for(int i=0;i<4;i++)
     {
      if(PointProfit[i+1]<=PointProfit[i])
        {
         string erro="Pontos de Profit do Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);

        }

     }

   if(Lot<mysymbol.LotsMin())
     {
      string erro="Lote deve ser maior que "+DoubleToString(mysymbol.LotsMin(),mysymbol.Digits());
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(UsarRealizParc && Lot<=mysymbol.LotsMin())
     {
      string erro="Para Usar Realização Parcial o Lote deve ser maior que "+DoubleToString(mysymbol.LotsMin(),mysymbol.Digits());
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   HLineDelete(0,"MaisNegociado");
   HLineDelete(0,"Compra");
   HLineDelete(0,"Venda");

//Global Variables Check

   if(!GlobalVariableCheck(glob_entr_tot))GlobalVariableSet(glob_entr_tot,0.0);
   if(!GlobalVariableCheck(glob_tot_gain))GlobalVariableSet(glob_tot_gain,0.0);

   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0.0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0.0);
   if(!GlobalVariableCheck(stp_vd_tick))GlobalVariableSet(stp_vd_tick,0);
   if(!GlobalVariableCheck(stp_cp_tick))GlobalVariableSet(stp_cp_tick,0);
   if(!GlobalVariableCheck(tp_vd_tick))GlobalVariableSet(tp_vd_tick,0);
   if(!GlobalVariableCheck(tp_cp_tick))GlobalVariableSet(tp_cp_tick,0);
   if(!GlobalVariableCheck(glob_pr_max))GlobalVariableSet(glob_pr_max,0.0);
   if(!GlobalVariableCheck(glob_pr_cp))GlobalVariableSet(glob_pr_cp,0.0);
   if(!GlobalVariableCheck(glob_pr_vd))GlobalVariableSet(glob_pr_vd,0.0);


   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
      return(INIT_FAILED);
//--- run application 

   ExtDialog.Run();

//---

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   hora_inicial1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour1);
   hora_final1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour1);

   hora_inicial2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour2);
   hora_final2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour2);

   hora_inicial3=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour3);
   hora_final3=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour3);

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

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

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   time_new_ent=true;
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   int j=ObjectsDeleteAll(ChartID(),0,OBJ_VLINE);
   IndicatorRelease(ind1_handle);
   IndicatorRelease(ind2_handle);
   DeletaIndicadores();
   ExtDialog.Destroy(reason);
   EventKillTimer();

//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,// event ID   
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
   if(novodia || GlobalVariableGet(gv_today)!=GlobalVariableGet(gv_today_prev))
     {
      GlobalVariableSet(glob_entr_tot,0.0);
      GlobalVariableSet(deals_total_prev,0.0);
      GlobalVariableSet(glob_tot_gain,0.0);
      tradeOn=true;
      ArrayInitialize(preco_abaixo,0.0);
      ArrayInitialize(preco_acima,0.0);
      GlobalVariableSet(glob_pr_max,0.0);
      GlobalVariableSet(glob_pr_cp,0.0);
      GlobalVariableSet(glob_pr_vd,0.0);
      if(UsarNew && HorasInvesting(pais,touros))
        {
         investing_filter=false;
         int j=ObjectsDeleteAll(ChartID(),0,OBJ_VLINE);
         ArrayResize(VLine,ArraySize(Hora_fin));
         for(int i=0;i<ArraySize(Hora_fin);i++)
           {
            if(Hora_in[i]>0 && Hora_fin[i]>0)
              {
               Print("inicio "+TimeToString(Hora_in[i])+" fim "+TimeToString(Hora_fin[i]));
               investing_filter=investing_filter || (TimeCurrent()>=Hora_in[i] && TimeCurrent()<=Hora_fin[i]);
               TemNoticia=true;
               VLine[i].Create(ChartID(),"News_"+IntegerToString(i),0,Hora_in[i]+minutos_news*60);
               VLine[i].Color(clrBlue);
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

   GlobalVariableSet(gv_today_prev,GlobalVariableGet(gv_today));

   MytradeTransaction();

   ProtectPosition();
   mysymbol.Refresh();
   mysymbol.RefreshRates();
   ExtDialog.OnTick();

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
      informacoes="EA encerrado lucro ou prejuizo";

     }

   timerOn=true;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   investing_filter=false;
   if(UsarNew)investing_filter=InvestingTime(TemNoticia);

   if(UseTimer)
     {
      timer1=UsePause1&&TimeCurrent()>=hora_inicial1 && TimeCurrent()<=hora_final1;
      timer2=UsePause2&&TimeCurrent()>=hora_inicial2 && TimeCurrent()<=hora_final2;
      timer3=UsePause3&&TimeCurrent()>=hora_inicial3 && TimeCurrent()<=hora_final3;
      timerPaus=!timer1 && !timer2 && !timer3;
      timerOn=timerPaus && TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final;
      if(UsarNew && investing_filter)timerOn=false;
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



   ContaTick();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!PosicaoAberta())DeleteOrdersExEntry();

   if(Buy_opened() && !Sell_opened())
     {
      myposition.SelectByTicket(TickecBuyPos());
      if(myposition.Comment()=="STOP"+exp_name || myposition.Comment()=="TAKE PROFIT")
        {
         DeleteALL();
         CloseALL();
        }
     }

   if(Sell_opened() && !Buy_opened())
     {
      myposition.SelectByTicket(TickecSellPos());
      if(myposition.Comment()=="STOP"+exp_name || myposition.Comment()=="TAKE PROFIT")
        {
         DeleteALL();
         CloseALL();
        }
     }

   if(Buy_opened())
     {
      myorder.Select((ulong)GlobalVariableGet(stp_vd_tick));
      DeleteOrdersLimit(ORDER_TYPE_BUY_LIMIT,myorder.PriceOpen());
     }

   if(Sell_opened())
     {
      myorder.Select((ulong)GlobalVariableGet(stp_cp_tick));
      DeleteOrdersLimit(ORDER_TYPE_SELL_LIMIT,myorder.PriceOpen());
     }

   if(tradeOn && timerOn)

     {// inicio Trade On
      Atual_vol_Stop_Take();
      if(Buy_opened() && Sell_opened())CloseByPosition();

      MudaTakeSemEntrada();
      MudaStopZero();

      if(NewBar.CheckNewBar(Symbol(),periodoRobo))
        {
         HLineDelete(0,"MaisNegociado");
         HLineDelete(0,"Compra");
         HLineDelete(0,"Venda");

         Histograma();
         if(reverter)
           {
            buysignal=!Buy_opened() && BuySignal();
            sellsignal=!Sell_opened() && SellSignal();
           }
         else
           {
            buysignal=!PosicaoAberta() && BuySignal();
            sellsignal=!PosicaoAberta() && SellSignal();
           }

         if(inverter)
           {
            bool aux_signal=buysignal;
            buysignal=sellsignal;
            sellsignal=aux_signal;
           }

         if(GlobalVariableGet(glob_pr_max)>0 && sellsignal && time_new_ent && operar!=Compra)
           {
            DeleteALL();
            CloseALL();
            if(GlobalVariableGet(glob_pr_max)<bid)
              {
               if(mytrade.SellStop(Lot,GlobalVariableGet(glob_pr_max),Symbol(),0,0,order_time_type,0,"SELL"+exp_name))
                 {
                  GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Erro enviar ordem ",GetLastError());
              }
            else
              {
               if(mytrade.Sell(Lot,Symbol(),0,0,0,"SELL"+exp_name))
                 {
                  GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Erro enviar ordem ",GetLastError());

              }
           }
         if(GlobalVariableGet(glob_pr_max)>0 && buysignal && time_new_ent && operar!=Venda)
           {
            DeleteALL();
            CloseALL();
            if(GlobalVariableGet(glob_pr_max)>ask)
              {
               if(mytrade.BuyStop(Lot,GlobalVariableGet(glob_pr_max),Symbol(),0,0,order_time_type,0,"BUY"+exp_name))
                 {
                  GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Erro enviar ordem ",GetLastError());
              }
            else
              {
               if(mytrade.Buy(Lot,Symbol(),0,0,0,"BUY"+exp_name))
                 {
                  GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Erro enviar ordem ",GetLastError());

              }

           }

         ArrayInitialize(preco_abaixo,0.0);
         ArrayInitialize(preco_acima,0.0);
         ArrayInitialize(precos,0.0);

        }//Fim NewBar
      if(PosicaoAberta())
        {
         if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);
         if(UsarRealizParc)RealizacaoParcial();
         //BrakeEven
         if(UseBreakEven)BreakEven(original_symbol,UseBreakEven,PointBreakEven,PointProfit);
        }

     }//End Trade On

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
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
   signal=Ind1_RandomWalk_Up[1]>Ind1_RandomWalk_Down[1] && Ind2_Color_Line[1]==0.0 && Besos_Up[idx]!=NULL && Besos_Up[idx+1]==NULL && media_buffer[1]==0;
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
   signal=Ind1_RandomWalk_Up[1]<Ind1_RandomWalk_Down[1] && Ind2_Color_Line[1]==1.0 && Besos_Down[idx]!=NULL && Besos_Down[idx+1]==NULL && media_buffer[1]==0;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(ind1_handle,0,0,5,Ind1_RandomWalk_Up)<=0 || 
         CopyBuffer(ind1_handle,1,0,5,Ind1_RandomWalk_Down)<=0 || 
         CopyBuffer(ind2_handle,1,0,5,Ind2_Color_Hist)<=0 ||
         CopyBuffer(ind2_handle,5,0,5,Ind2_Color_Line)<=0 ||
         CopyBuffer(besos_handle,2,0,5,Besos_Up)<=0 || 
         CopyBuffer(besos_handle,3,0,5,Besos_Down)<=0 || 
         CopyBuffer(bolu_handle,6,0,5,media_buffer)<=0 || 
         CopyHigh(Symbol(),periodoRobo,0,5,high)<=0 ||
         CopyOpen(Symbol(),periodoRobo,0,5,open)<=0 ||
         CopyLow(Symbol(),periodoRobo,0,5,low)<=0 || 
         CopyClose(Symbol(),periodoRobo,0,5,close)<=0;
   return(b_get);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//------------------------------------------------------------------------

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
double PriceLastStopOrder(const ENUM_ORDER_TYPE pending_order_type)
  {
   datetime last_time=0;
   double last_price=-1.0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
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

int TotalGains()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   datetime tm_start=iTime(original_symbol,PERIOD_D1,0);
   HistorySelect(tm_start,tm_end);
   uint total_deals=HistoryDealsTotal();
   ulong ticket=0;
   int profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY) && mydeal.Profit()>0)
            profit+=1;
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalEntradas()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   datetime tm_start=iTime(original_symbol,PERIOD_D1,0);
   HistorySelect(tm_start,tm_end);
   uint total_deals=HistoryDealsTotal();
   ulong ticket=0;
   int profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_IN || mydeal.Entry()==DEAL_ENTRY_INOUT))
            profit+=1;
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalEntradasSemana()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   datetime tm_start=WeekStartTime(TimeCurrent());
   HistorySelect(tm_start,tm_end);
   uint total_deals=HistoryDealsTotal();
   ulong ticket=0;
   int profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_IN || mydeal.Entry()==DEAL_ENTRY_INOUT))
            profit+=1;
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalGainsSemana()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   datetime tm_start=WeekStartTime(TimeCurrent());
   HistorySelect(tm_start,tm_end);
   uint total_deals=HistoryDealsTotal();
   ulong ticket=0;
   int profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY) && mydeal.Profit()>0)
            profit+=1;
     }
   return(profit);
  }
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

// Trailing stop (points)
void TrailingStop(int pTrailPoints,int pMinProfit=0,int pStep=10)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number && pTrailPoints>0)
        {

         double currentTakeProfit=myposition.TakeProfit();
         long posType=myposition.PositionType();
         double currentStop;
         double openPrice=NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
         double point=mysymbol.Point();
         int digits=mysymbol.Digits();
         if(pStep<10) pStep=10;
         double step=pStep*point;

         double minProfit = pMinProfit * point;
         double trailStop = pTrailPoints * point;
         currentTakeProfit=NormalizeDouble(currentTakeProfit,digits);
         double trailStopPrice;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            myorder.Select((ulong)GlobalVariableGet(stp_vd_tick));
            currentStop=myorder.PriceOpen();
            trailStopPrice = bid - trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=bid-openPrice;

            if(trailStopPrice>currentStop+step && currentProfit>=minProfit)
              {
               // mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
               if(myorder.Select((ulong)GlobalVariableGet(stp_vd_tick)))
                 {
                  mytrade.OrderModify((ulong)GlobalVariableGet(stp_vd_tick),trailStopPrice,0,0,order_time_type,0,0);
                 }
              }

           }
         else if(posType==POSITION_TYPE_SELL)
           {
            myorder.Select((ulong)GlobalVariableGet(stp_cp_tick));
            currentStop=myorder.PriceOpen();
            trailStopPrice = ask + trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=openPrice-ask;

            if((trailStopPrice<currentStop-step || currentStop==0) && currentProfit>=minProfit)
              {
               //mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
               if(myorder.Select((ulong)GlobalVariableGet(stp_cp_tick)))
                 {
                  mytrade.OrderModify((ulong)GlobalVariableGet(stp_cp_tick),trailStopPrice,0,0,order_time_type,0,0);
                 }

              }

           }
        }

     }
  }
//+------------------------------------------------------------------+
void ContaTick()
  {
   MqlTick last_tick;
   double last;
   int numb_tick;
   if(SymbolInfoTick(Symbol(),last_tick))
      if(last_tick.last>0)
         last=last_tick.last;
   numb_tick=(int)((last-open[0])/ticksize);
   if(numb_tick>=0)
     {
      preco_acima[numb_tick]+=1;
     }
   else
     {
      preco_abaixo[-numb_tick-1]+=1;
     }
  }
//+------------------------------------------------------------------+
void Histograma()
  {
   int total_acima,total_abaixo;
   double value_tick;
   double preco_compra,preco_venda,preco_max;
   double soma;
   double max,max_acima,max_abaixo;
   int id_max,id_max_acima,id_max_abaixo;
   int size_acima,size_abaixo;
   size_acima=ArraySize(preco_acima);
   size_abaixo=ArraySize(preco_abaixo);
   soma=0;
   for( int i=0;i<size_acima;i++)soma+=preco_acima[i];
   for( int i=0;i<size_abaixo;i++)soma+=preco_abaixo[i];
   for( int i=0;i<size_acima;i++)
     {
      preco_acima[i]=preco_acima[i]/soma;
     }
   for(int i=0;i<size_abaixo;i++)
     {
      preco_abaixo[i]=preco_abaixo[i]/soma;
     }
   int cont=0;
   value_tick=preco_acima[cont];
   while(value_tick!=0)
     {
      cont+=1;
      value_tick=preco_acima[cont];
     }
   total_acima=cont;
   cont=0;
   value_tick=preco_abaixo[cont];
   while(value_tick!=0)
     {
      cont+=1;
      value_tick=preco_abaixo[cont];

     }
   total_abaixo=cont;
   for(int i=0;i<total_abaixo;i++)precos[i]=preco_abaixo[total_abaixo-1-i];
   for(int i=total_abaixo;i<total_abaixo+total_acima;i++)precos[i]=preco_acima[i-total_abaixo];
   double media=0;
   for(int i=0;i<ArraySize(precos);i++)
     {
      if(precos[i]>0)
        {
         //       Print("preco ",DoubleToString(low[1]+i*ticksize,digits)," porcentagem ",DoubleToString(precos[i]*100,2));
         media+=100*precos[i];
        }

     }
   id_max=ArrayMaximum(precos,0);
   preco_max=low[1]+id_max*ticksize;
   GlobalVariableSet(glob_pr_max,preco_max);
   HLineCreate(0,"MaisNegociado",0,GlobalVariableGet(glob_pr_max),clrYellow,STYLE_SOLID,2,false,false,true,0);
   bool achou_compra=false;
   for(int i=id_max+1;i<ArraySize(precos);i++)
     {
      if(precos[i]<porc_lim/100)
        {
         preco_compra=preco_max+(i-id_max)*ticksize;
         achou_compra=true;
         break;
        }
     }
   if(!achou_compra)preco_compra=0;
   GlobalVariableSet(glob_pr_cp,preco_compra);
   bool achou_venda=false;
   for(int i=id_max-1;i>=0;i--)
     {
      if(precos[i]<porc_lim/100)
        {
         preco_venda=preco_max-(id_max-i)*ticksize;
         achou_venda=true;
         break;
        }
     }
   if(!achou_venda)preco_venda=0;
   GlobalVariableSet(glob_pr_vd,preco_venda);

   if(close[1]<preco_max)
     {

      if(!BarrasAlta())
        {
         GlobalVariableSet(glob_pr_vd,0);
         if(GlobalVariableGet(glob_pr_cp)>0)HLineCreate(0,"Compra",0,GlobalVariableGet(glob_pr_cp),clrAqua,STYLE_SOLID,2,false,false,true,0);
        }
      else
        {
         GlobalVariableSet(glob_pr_cp,0);
         if(GlobalVariableGet(glob_pr_vd)>0)HLineCreate(0,"Venda",0,GlobalVariableGet(glob_pr_vd),clrRed,STYLE_SOLID,2,false,false,true,0);

        }

     }

   if(close[1]>preco_max)
     {
      if(!BarrasBaixa())
        {
         GlobalVariableSet(glob_pr_cp,0);
         if(GlobalVariableGet(glob_pr_vd)>0)HLineCreate(0,"Venda",0,GlobalVariableGet(glob_pr_vd),clrRed,STYLE_SOLID,2,false,false,true,0);
        }
      else
        {
         GlobalVariableSet(glob_pr_vd,0);
         if(GlobalVariableGet(glob_pr_cp)>0)HLineCreate(0,"Compra",0,GlobalVariableGet(glob_pr_cp),clrAqua,STYLE_SOLID,2,false,false,true,0);
        }
     }
   if(close[1]==preco_max)
     {
      GlobalVariableSet(glob_pr_cp,0);
      GlobalVariableSet(glob_pr_vd,0);
     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
//| Criar a linha horizontal                                         | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long            chart_ID=0,        // ID de gráfico 
                 const string          name="HLine",      // nome da linha 
                 const int             sub_window=0,      // índice da sub-janela 
                 double                price=0,           // line price 
                 const color           clr=clrRed,        // cor da linha 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // estilo da linha 
                 const int             width=1,           // largura da linha 
                 const bool            back=false,        // no fundo 
                 const bool            selection=true,    // destaque para mover 
                 const bool            hidden=true,       //ocultar na lista de objetos 
                 const long            z_order=0)         // prioridade para clique do mouse 
  {
//--- se o preço não está definido, defina-o no atual nível de preço Bid 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- redefine o valor de erro 
   ResetLastError();
//--- criar um linha horizontal 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": falha ao criar um linha horizontal! Código de erro = ",GetLastError());
      return(false);
     }
//--- definir cor da linha 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- definir o estilo de exibição da linha 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- definir a largura da linha 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- exibir em primeiro plano (false) ou fundo (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- habilitar (true) ou desabilitar (false) o modo do movimento da seta com o mouse 
//--- ao criar um objeto gráfico usando a função ObjectCreate, o objeto não pode ser 
//--- destacado e movimentado por padrão. Dentro deste método, o parâmetro de seleção 
//--- é verdade por padrão, tornando possível destacar e mover o objeto 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- ocultar (true) ou exibir (false) o nome do objeto gráfico na lista de objeto  
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- definir a prioridade para receber o evento com um clique do mouse no gráfico 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- sucesso na execução 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Excluir uma linha horizontal                                     | 
//+------------------------------------------------------------------+ 
bool HLineDelete(const long   chart_ID=0,   // ID do gráfico 
                 const string name="HLine") // nome da linha 
  {
//--- redefine o valor de erro 
   ResetLastError();
//--- excluir uma linha horizontal 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": falha ao Excluir um linha horizontal! Código de erro = ",GetLastError());
      return(false);
     }
//--- sucesso na execução 
   return(true);
  }
//+------------------------------------------------------------------+
bool BarrasAlta()
  {
   bool signal=close[1]>open[1] && close[2]>open[2] && close[3]>open[3] && close[4]>open[4];
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BarrasBaixa()
  {
   bool signal=close[1]<open[1] && close[2]<open[2] && close[3]<open[3] && close[4]<open[4];
   return signal;
  }
//+------------------------------------------------------------------+
void RealizacaoParcial()
  {
   double currentProfit,currentStop,preco,novostop;
   double sellprice,buyprice,tp_position;
   double lote_parcial;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
        {
         currentStop=myposition.StopLoss();
         preco=myposition.PriceOpen();
         if(myposition.PositionType()==POSITION_TYPE_BUY)
           {
            currentProfit=bid-preco;
            if(currentProfit>=DistanceRealizeParcial*_Point && myposition.Volume()==Lot)
              {
               lote_parcial=MathMax(mysymbol.LotsMin(),MathFloor(porc_parcial*myposition.Volume()));
               if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)mytrade.PositionClosePartial(myposition.Ticket(),lote_parcial);
               else mytrade.Sell(lote_parcial);
               Print("Venda Saída Parcial : ");
               myorder.Select((ulong)GlobalVariableGet(stp_vd_tick));
               sellprice=myorder.PriceOpen();
               mytrade.OrderDelete((ulong)GlobalVariableGet(stp_vd_tick));
               mytrade.SellStop(Lot-lote_parcial,sellprice,Symbol(),0,0,order_time_type,0,"STOP"+exp_name);
               GlobalVariableSet(stp_vd_tick,(double)mytrade.ResultOrder());
               myorder.Select((ulong)GlobalVariableGet(stp_vd_tick));
               tp_position=myorder.PriceOpen();
               mytrade.OrderDelete((ulong)GlobalVariableGet(stp_vd_tick));
               mytrade.SellLimit(Lot-lote_parcial,tp_position,original_symbol,0,0,order_time_type,0,"TAKE PROFIT");
               GlobalVariableSet(tp_vd_tick,(double)mytrade.ResultOrder());
              }
           }

         if(myposition.PositionType()==POSITION_TYPE_SELL)
           {
            currentProfit=preco-ask;

            if(currentProfit>=DistanceRealizeParcial*_Point && myposition.Volume()==Lot)
              {
               lote_parcial=MathMax(mysymbol.LotsMin(),MathFloor(porc_parcial*myposition.Volume()));
               if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)mytrade.PositionClosePartial(myposition.Ticket(),lote_parcial);
               else mytrade.Buy(lote_parcial);
               Print("Compra Saída Parcial : ");
               myorder.Select((ulong)GlobalVariableGet(stp_cp_tick));
               buyprice=myorder.PriceOpen();
               mytrade.OrderDelete((ulong)GlobalVariableGet(stp_cp_tick));
               mytrade.BuyStop(Lot-lote_parcial,buyprice,Symbol(),0,0,order_time_type,0,"STOP"+exp_name);
               GlobalVariableSet(stp_cp_tick,(double)mytrade.ResultOrder());
               myorder.Select((ulong)GlobalVariableGet(tp_cp_tick));
               tp_position=myorder.PriceOpen();
               mytrade.OrderDelete((ulong)GlobalVariableGet(tp_cp_tick));
               mytrade.BuyLimit(Lot-lote_parcial,tp_position,original_symbol,0,0,order_time_type,0,"TAKE PROFIT");
               GlobalVariableSet(tp_cp_tick,(double)mytrade.ResultOrder());

              }
           }
        }//Fim myposition Select
     }//Fim for
  }
//+------------------------------------------------------------------+
void Atual_vol_Stop_Take()
  {
   double vol_sl,vol_tp;
   if(PosicaoAberta())
     {
      if(Buy_opened())
        {
         if(myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick)) && myorder.Select((ulong)GlobalVariableGet(stp_vd_tick)))
           {
            // vol_pos=VolPosType(POSITION_TYPE_BUY);
            vol_pos=VolPosType(POSITION_TYPE_BUY)+VolumeOrdens(ORDER_TYPE_BUY_LIMIT);
            myorder.Select((ulong)GlobalVariableGet(stp_vd_tick));
            vol_stp=myorder.VolumeCurrent();
            preco_stp=myorder.PriceOpen();

            if(vol_pos!=vol_stp && vol_pos>0)
              {
               mytrade.OrderDelete((int)GlobalVariableGet(stp_vd_tick));
               mytrade.SellStop(vol_pos,preco_stp,Symbol(),0,0,order_time_type,0,"STOP"+exp_name);
               GlobalVariableSet(stp_vd_tick,(double)mytrade.ResultOrder());
              }
           }

         if(myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick)) && myorder.Select((ulong)GlobalVariableGet(tp_vd_tick)))
           {
            //            vol_pos=VolPosType(POSITION_TYPE_BUY);
            vol_pos=VolPosType(POSITION_TYPE_BUY)-VolumeOrdens(ORDER_TYPE_SELL_LIMIT)+VolumeOrdensCmt("TAKE PROFIT");
            myorder.Select((ulong)GlobalVariableGet(tp_vd_tick));
            vol_stp=myorder.VolumeCurrent();
            preco_stp=myorder.PriceOpen();

            if(vol_pos!=vol_stp && vol_pos>0)
              {
               mytrade.OrderDelete((int)GlobalVariableGet(tp_vd_tick));
               mytrade.SellLimit(vol_pos,preco_stp,original_symbol,0,0,order_time_type,0,"TAKE PROFIT");
               GlobalVariableSet(tp_vd_tick,(double)mytrade.ResultOrder());
              }
           }

        }
      if(Sell_opened())
        {
         if(myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick)) && myorder.Select((ulong)GlobalVariableGet(stp_cp_tick)))
           {
            //   vol_pos=VolPosType(POSITION_TYPE_SELL);
            vol_pos=VolPosType(POSITION_TYPE_SELL)+VolumeOrdens(ORDER_TYPE_SELL_LIMIT);
            myorder.Select((ulong)GlobalVariableGet(stp_cp_tick));
            vol_stp=myorder.VolumeCurrent();
            preco_stp=myorder.PriceOpen();

            if(vol_pos!=vol_stp && vol_pos>0)
              {
               mytrade.OrderDelete((int)GlobalVariableGet(stp_cp_tick));
               mytrade.BuyStop(vol_pos,preco_stp,Symbol(),0,0,order_time_type,0,"STOP"+exp_name);
               GlobalVariableSet(stp_cp_tick,(double)mytrade.ResultOrder());

              }
           }

         if(myposition.SelectByTicket((int)GlobalVariableGet(vd_tick)) && myorder.Select((int)GlobalVariableGet(tp_cp_tick)))
           {
            // vol_pos=VolPosType(POSITION_TYPE_SELL);
            vol_pos=VolPosType(POSITION_TYPE_SELL)-VolumeOrdens(ORDER_TYPE_BUY_LIMIT)+VolumeOrdensCmt("TAKE PROFIT");
            myorder.Select((ulong)GlobalVariableGet(tp_cp_tick));
            vol_stp=myorder.VolumeCurrent();
            preco_stp=myorder.PriceOpen();

            if(vol_pos!=vol_stp && vol_pos>0)
              {
               mytrade.OrderDelete((int)GlobalVariableGet(tp_cp_tick));
               mytrade.BuyLimit(vol_pos,preco_stp,original_symbol,0,0,order_time_type,0,"TAKE PROFIT");
               GlobalVariableSet(tp_cp_tick,(double)mytrade.ResultOrder());

              }
           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double VolPosType(ENUM_POSITION_TYPE ptype)
  {
   double vol=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && myposition.Symbol()==mysymbol.Name())
        {
         vol+=myposition.Volume();
        }
     }
   return vol;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Entr_Parcial_Buy(const double preco)
  {
   if(Lot_entry1>0) mytrade.BuyLimit(Lot_entry1,NormalizeDouble(preco-pts_entry1*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 1");
   if(Lot_entry2>0) mytrade.BuyLimit(Lot_entry2,NormalizeDouble(preco-pts_entry2*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 2");
   if(Lot_entry3>0) mytrade.BuyLimit(Lot_entry3,NormalizeDouble(preco-pts_entry3*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 3");
   if(Lot_entry4>0) mytrade.BuyLimit(Lot_entry4,NormalizeDouble(preco-pts_entry4*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 4");
   if(Lot_entry5>0) mytrade.BuyLimit(Lot_entry5,NormalizeDouble(preco-pts_entry5*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 5");
   if(Lot_entry6>0) mytrade.BuyLimit(Lot_entry6,NormalizeDouble(preco-pts_entry6*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 6");
  }
//+------------------------------------------------------------------+
void Entr_Parcial_Sell(const double preco)
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
void Entr_Favor_Buy(const double preco)
  {

   if(Lot_entry1_fv>0) mytrade.BuyStop(Lot_entry1_fv,NormalizeDouble(preco+pts_entry1_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 1");
   if(Lot_entry2_fv>0) mytrade.BuyStop(Lot_entry2_fv,NormalizeDouble(preco+pts_entry2_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 2");
   if(Lot_entry3_fv>0) mytrade.BuyStop(Lot_entry3_fv,NormalizeDouble(preco+pts_entry3_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 3");
   if(Lot_entry4_fv>0) mytrade.BuyStop(Lot_entry4_fv,NormalizeDouble(preco+pts_entry4_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 4");
  }
//+------------------------------------------------------------------+
void Entr_Favor_Sell(const double preco)
  {
   if(Lot_entry1_fv>0) mytrade.SellStop(Lot_entry1_fv,NormalizeDouble(preco-pts_entry1_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 1");
   if(Lot_entry2_fv>0) mytrade.SellStop(Lot_entry2_fv,NormalizeDouble(preco-pts_entry2_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 2");
   if(Lot_entry3_fv>0) mytrade.SellStop(Lot_entry3_fv,NormalizeDouble(preco-pts_entry3_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 3");
   if(Lot_entry4_fv>0) mytrade.SellStop(Lot_entry4_fv,NormalizeDouble(preco-pts_entry4_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 4");
  }
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
void ProtectPosition()
  {
   if(Buy_opened() && !Sell_opened())
     {
      myposition.SelectByTicket(TickecBuyPos());
      if(mysymbol.Bid()<=myposition.PriceOpen()-_Stop*ponto-n_ticks_stop*ticksize || mysymbol.Bid()>=myposition.PriceOpen()+_TakeProfit*ponto+n_ticks_take*ticksize)
        {
         DeleteALL();
         ClosePosType(POSITION_TYPE_BUY);
        }
     }
   if(Sell_opened() && !Buy_opened())
     {
      myposition.SelectByTicket(TickecSellPos());
      if(mysymbol.Ask()>=myposition.PriceOpen()+_Stop*ponto+n_ticks_stop*ticksize || mysymbol.Ask()<=myposition.PriceOpen()-_TakeProfit*ponto-n_ticks_take*ticksize)
        {
         DeleteALL();
         ClosePosType(POSITION_TYPE_SELL);
        }

     }
  }
//+------------------------------------------------------------------+
bool IsConnect()
  {
   return TerminalInfoInteger(TERMINAL_CONNECTED);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double PrecoMedio(ENUM_POSITION_TYPE ptype)
  {
   double vol=0;
   double preco=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && myposition.Symbol()==mysymbol.Name())
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
//+------------------------------------------------------------------+
//| Break even stop                                                  |
//+------------------------------------------------------------------+
//Break Even

void BreakEven(string pSymbol,bool usarbreak,double &pBreakEven[],double &pLockProfit[])
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && usarbreak==true)
        {

         long posType=myposition.PositionType();
         long posTicket=myposition.Ticket();
         double currentSL;
         double openPrice= NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
         double currentTP=myposition.TakeProfit();
         double breakEvenStop;
         double currentProfit;
         double ponto=SymbolInfoDouble(pSymbol,SYMBOL_POINT);
         double bid,ask;

         if(posType==POSITION_TYPE_BUY)
           {
            myorder.Select((ulong)GlobalVariableGet(stp_vd_tick));
            currentSL=myorder.PriceOpen();
            bid=SymbolInfoDouble(pSymbol,SYMBOL_BID);
            currentProfit=bid-openPrice;
            //Break Even 0 a 3
            for(int k=0;k<4;k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop=openPrice+pLockProfit[k]*ponto;
                  breakEvenStop=MathRound(breakEvenStop/ticksize)*ticksize;
                  if(currentSL<breakEvenStop || currentSL==0)
                    {
                     Print("Break even stop:");
                     //   mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                     mytrade.OrderModify((ulong)GlobalVariableGet(stp_vd_tick),breakEvenStop,0,0,order_time_type,0,0);

                    }
                 }
              }
            //----------------------
            //Break Even 4
            if(currentProfit>=pBreakEven[4]*ponto)
              {
               breakEvenStop=openPrice+pLockProfit[4]*ponto;
               breakEvenStop=MathRound(breakEvenStop/ticksize)*ticksize;
               if(currentSL<breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop:");
                  // mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                  mytrade.OrderModify((ulong)GlobalVariableGet(stp_vd_tick),breakEvenStop,0,0,order_time_type,0,0);

                 }
              }
           }
         //----------------------

         //----------------------

         if(posType==POSITION_TYPE_SELL)
           {
            myorder.Select((ulong)GlobalVariableGet(stp_cp_tick));
            currentSL=myorder.PriceOpen();
            ask=SymbolInfoDouble(pSymbol,SYMBOL_ASK);
            currentProfit=openPrice-ask;
            //Break Even 0 a 3
            for(int k=0;k<4;k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop=openPrice-pLockProfit[k]*ponto;
                  breakEvenStop=MathRound(breakEvenStop/ticksize)*ticksize;
                  if(currentSL>breakEvenStop || currentSL==0)
                    {
                     Print("Break even stop:");
                     //mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                     mytrade.OrderModify((ulong)GlobalVariableGet(stp_cp_tick),breakEvenStop,0,0,order_time_type,0,0);

                    }
                 }
              }
            //----------------------
            //Break Even 4
            if(currentProfit>=pBreakEven[4]*ponto)
              {
               breakEvenStop=openPrice-pLockProfit[4]*ponto;
               breakEvenStop=MathRound(breakEvenStop/ticksize)*ticksize;
               if(currentSL>breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop:");
                  //mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                  mytrade.OrderModify((ulong)GlobalVariableGet(stp_cp_tick),breakEvenStop,0,0,order_time_type,0,0);

                 }

              }
            //----------------------

           }

        } //Fim Position Select

     }//Fim for
  }
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
void MudaTakeSemEntrada()
  {
   double take_atual,tp_position;
   if(Buy_opened() && OrdemAbertaComent("Entrada Parcial 1"))
     {
      myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick));
      tp_position=myposition.PriceOpen()+(0.01*porc_take*_TakeProfit*ponto);
      tp_position=NormalizeDouble(MathRound(tp_position/ticksize)*ticksize,digits);
      myorder.Select((ulong)GlobalVariableGet(tp_vd_tick));
      take_atual=myorder.PriceOpen();
      if(TimeCurrent()-myposition.Time()>=time_order_sem && take_atual>tp_position) mytrade.OrderModify((ulong)GlobalVariableGet(tp_vd_tick),tp_position,0,0,order_time_type,0,0);
     }
   if(Sell_opened() && OrdemAbertaComent("Entrada Parcial 1"))
     {
      myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick));
      tp_position=myposition.PriceOpen()-(0.01*porc_take*_TakeProfit*ponto);
      tp_position=NormalizeDouble(MathRound(tp_position/ticksize)*ticksize,digits);
      myorder.Select((ulong)GlobalVariableGet(tp_cp_tick));
      take_atual=myorder.PriceOpen();
      if(TimeCurrent()-myposition.Time()>=time_order_sem && take_atual<tp_position) mytrade.OrderModify((ulong)GlobalVariableGet(tp_cp_tick),tp_position,0,0,order_time_type,0,0);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrdemAbertaComent(const string cmt)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.Comment()==cmt)
               return true;
   return false;
  }
//+------------------------------------------------------------------+
void DeleteOrdersLimit(const ENUM_ORDER_TYPE order_type,double price)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
     {
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
        {
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number && myorder.OrderType()==order_type)
           {
            if(myorder.OrderType()==ORDER_TYPE_BUY_LIMIT && myorder.PriceOpen()<=price)
               mytrade.OrderDelete(myorder.Ticket());
            if(myorder.OrderType()==ORDER_TYPE_SELL_LIMIT && myorder.PriceOpen()>=price)
               mytrade.OrderDelete(myorder.Ticket());
           }
        }
     }
  }
//+------------------------------------------------------------------+
void MudaStopZero()
  {
   double stp_atual,stp_new;
   if(Buy_opened())
     {
      myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick));
      stp_new=myposition.PriceOpen()+ticksize;
      stp_new=NormalizeDouble(MathRound(stp_new/ticksize)*ticksize,digits);
      myorder.Select((ulong)GlobalVariableGet(stp_vd_tick));
      stp_atual=myorder.PriceOpen();
      if(TimeCurrent()-myposition.Time()>=time_order_zero*60 && stp_new>stp_atual && mysymbol.Bid()>stp_new) mytrade.OrderModify((ulong)GlobalVariableGet(stp_vd_tick),stp_new,0,0,order_time_type,0,0);
     }
   if(Sell_opened())
     {
      myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick));
      stp_new=myposition.PriceOpen()+ticksize;
      stp_new=NormalizeDouble(MathRound(stp_new/ticksize)*ticksize,digits);
      myorder.Select((ulong)GlobalVariableGet(stp_cp_tick));
      stp_atual=myorder.PriceOpen();
      if(TimeCurrent()-myposition.Time()>=time_order_zero*60 && stp_new<stp_atual && mysymbol.Ask()<stp_new) mytrade.OrderModify((ulong)GlobalVariableGet(stp_cp_tick),stp_new,0,0,order_time_type,0,0);
     }

  }
//+------------------------------------------------------------------+
void MytradeTransaction()
  {
   double sl_position,tp_position;

   ulong order_ticket;
   ulong deals_ticket;

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
         GlobalVariableSet(deals_total_prev,GlobalVariableGet(deals_total));
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
               if(myorder.Select((ulong)GlobalVariableGet(vd_tick)))mytrade.OrderDelete((ulong)GlobalVariableGet(vd_tick));
               myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick));
               int cont=0;
               buyprice=0;
               while(buyprice==0 && cont<TENTATIVAS)
                 {
                  buyprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(buyprice==0)buyprice=ask;
               Entr_Parcial_Buy(buyprice);
               Entr_Favor_Buy(buyprice);
               sl_position=NormalizeDouble(buyprice-_Stop*ponto,digits);
               tp_position=NormalizeDouble(buyprice+_TakeProfit*ponto,digits);
               if(mytrade.SellLimit(Lot,tp_position,original_symbol,0,0,order_time_type,0,"TAKE PROFIT"))
                 {
                  GlobalVariableSet(tp_vd_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Erro enviar ordem de Take Profit",GetLastError());

               //Stop para posição comprada
               sellprice=sl_position;
               if(mytrade.SellStop(Lot,sellprice,Symbol(),0,0,order_time_type,0,"STOP"+exp_name))
                 {
                  GlobalVariableSet(stp_vd_tick,(double)mytrade.ResultOrder());
                 }
               else
                 {
                  Print("Erro enviar ordem de STOP",GetLastError());
                  DeleteALL();
                  CloseALL();
                 }

              }
            //--------------------------------------------------

            if(order_ticket==(ulong)GlobalVariableGet(vd_tick))
              {
               if(myorder.Select((ulong)GlobalVariableGet(cp_tick)))mytrade.OrderDelete((ulong)GlobalVariableGet(cp_tick));
               myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick));
               int cont=0;
               sellprice=0;
               while(sellprice==0 && cont<TENTATIVAS)
                 {
                  sellprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(sellprice==0)sellprice=bid;

               Entr_Parcial_Sell(sellprice);
               Entr_Favor_Sell(sellprice);
               sl_position=NormalizeDouble(sellprice+_Stop*ponto,digits);
               tp_position=NormalizeDouble(sellprice-_TakeProfit*ponto,digits);
               if(mytrade.BuyLimit(Lot,tp_position,original_symbol,0,0,order_time_type,0,"TAKE PROFIT"))
                 {
                  GlobalVariableSet(tp_cp_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Erro enviar ordem de Take Profit ",GetLastError());

               buyprice=sl_position;
               if(mytrade.BuyStop(Lot,buyprice,Symbol(),0,0,order_time_type,0,"STOP"+exp_name))
                 {
                  GlobalVariableSet(stp_cp_tick,(double)mytrade.ResultOrder());
                 }
               else
                 {
                  Print("Erro enviar ordem de STOP",GetLastError());
                  DeleteALL();
                  CloseALL();
                 }

              }

            if(StringFind(mydeal.Comment(),"Entrada Parcial")>=0)
              {
               if(Buy_opened())
                 {
                  myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick));
                  preco_medio=myposition.PriceOpen();
                  preco_medio=NormalizeDouble(MathRound(preco_medio/ticksize)*ticksize,digits);
                  if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)preco_medio=PrecoMedio(POSITION_TYPE_BUY);
                  mytrade.OrderModify((ulong)GlobalVariableGet(tp_vd_tick),NormalizeDouble(preco_medio+_TakeProfit*ponto,digits),0,0,order_time_type,0,0);
                  if(pts_saida_aumento>0) mytrade.SellLimit(mydeal.Volume(),NormalizeDouble(mydeal.Price()+pts_saida_aumento*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Aumento");
                 }

               if(Sell_opened())
                 {
                  myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick));
                  preco_medio=myposition.PriceOpen();
                  preco_medio=NormalizeDouble(MathRound(preco_medio/ticksize)*ticksize,digits);
                  if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)preco_medio=PrecoMedio(POSITION_TYPE_SELL);
                  mytrade.OrderModify((ulong)GlobalVariableGet(tp_cp_tick),NormalizeDouble(preco_medio-_TakeProfit*ponto,digits),0,0,order_time_type,0,0);
                  if(pts_saida_aumento>0) mytrade.BuyLimit(mydeal.Volume(),NormalizeDouble(mydeal.Price()-pts_saida_aumento*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Aumento");
                 }
              }
            if(mydeal.Comment()=="Entrada Parcial 1")
              {
               if(Buy_opened())
                 {
                  myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick));
                  tp_position=myposition.PriceOpen()+(0.01*porc_take*_TakeProfit*ponto);
                  tp_position=NormalizeDouble(MathRound(tp_position/ticksize)*ticksize,digits);
                  if(TimeCurrent()-myposition.Time()<=time_order) mytrade.OrderModify((ulong)GlobalVariableGet(tp_vd_tick),tp_position,0,0,order_time_type,0,0);
                 }
               if(Sell_opened())
                 {
                  myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick));
                  tp_position=myposition.PriceOpen()-(0.01*porc_take*_TakeProfit*ponto);
                  tp_position=NormalizeDouble(MathRound(tp_position/ticksize)*ticksize,digits);
                  Print("Time ",IntegerToString(TimeCurrent()-myposition.Time()));
                  if(TimeCurrent()-myposition.Time()<=time_order) mytrade.OrderModify((ulong)GlobalVariableGet(tp_cp_tick),tp_position,0,0,order_time_type,0,0);
                 }
              }

            if(StringFind(mydeal.Comment(),"Entrada Favor")>=0)
              {
               if(Buy_opened())
                 {
                  myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick));
                  preco_medio=myposition.PriceOpen();
                  preco_medio=NormalizeDouble(MathRound(preco_medio/ticksize)*ticksize,digits);
                  if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)preco_medio=PrecoMedio(POSITION_TYPE_BUY);
                  mytrade.OrderModify((ulong)GlobalVariableGet(tp_vd_tick),NormalizeDouble(preco_medio+_TakeProfit*ponto,digits),0,0,order_time_type,0,0);
                  if(pts_saida_aumento_fv>0) mytrade.SellLimit(mydeal.Volume(),NormalizeDouble(mydeal.Price()+pts_saida_aumento_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Favor");
                 }

               if(Sell_opened())
                 {
                  myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick));
                  preco_medio=myposition.PriceOpen();
                  preco_medio=NormalizeDouble(MathRound(preco_medio/ticksize)*ticksize,digits);
                  if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)preco_medio=PrecoMedio(POSITION_TYPE_SELL);
                  mytrade.OrderModify((ulong)GlobalVariableGet(tp_cp_tick),NormalizeDouble(preco_medio-_TakeProfit*ponto,digits),0,0,order_time_type,0,0);
                  if(pts_saida_aumento_fv>0) mytrade.BuyLimit(mydeal.Volume(),NormalizeDouble(mydeal.Price()-pts_saida_aumento_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Favor");
                 }
              }

            if(mydeal.Comment()=="TAKE PROFIT" || mydeal.Comment()=="STOP")
              {
               EventSetTimer(n_minutes*60);
               time_new_ent=false;
               DeleteALL();
               if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened())CloseByPosition();
              }

           }// if dealsticket>0
        }//Fim deals>prev
     }//Fim HistorySelect

  }
//+------------------------------------------------------------------+
double VolumeOrdens(const ENUM_ORDER_TYPE order_type)
  {
   double volume=0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               volume+=1;
   return volume;
  }
//+------------------------------------------------------------------+
double VolumeOrdensCmt(const string cmt)
  {
   double volume=0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.Comment()==cmt)
               volume+=1;
   return volume;
  }
//+------------------------------------------------------------------+

bool GetInvesting(string _pais,int _touros)
  {
//Tentative
   datetime hora_init_news,hora_fin_news,hora_news;
   bool timer_news;
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
// PrintFormat("Strings obtidos: %d. Usado separador '%s' com o código %d",k,sep,u_sep);
//--- Agora imprime todos os resultados obtidos
   timer_news=false;
   if(k>0)
     {
      for(int i=0;i<k;i++)
        {
         //PrintFormat("result[%d]=\"%s\"",i,result[i]);
         str_time_new=StringSubstr(result[i],0,5);
         if(str_time_new!="Tentative")
           {
            hora_news=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+str_time_new);
            hora_init_news=hora_news-minutos_news*60;
            hora_fin_news=hora_news+minutos_news*60;
            // Print("Hora início pausa news: "+TimeToString(hora_init_news)+" Hora final pausa news: "+TimeToString(hora_fin_news));
            timer_news=timer_news || TimeCurrent()>=hora_init_news && TimeCurrent()<=hora_fin_news;
           }
        }
     }
   return timer_news;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string NewsInvesting(string _pais,int _touros)
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
bool HorasInvesting(string _pais,int _touros)
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
bool InvestingTime(bool isnews)
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
bool TestaLogin()
  {
   int contas[8]={15725,444927,17738,17737,17106,17105,2001079876,426704};
   for(int i=0;i<8;i++)
      if(AccountInfoInteger(ACCOUNT_LOGIN)==contas[i])return true;
   return false;
  }
//+------------------------------------------------------------------+
