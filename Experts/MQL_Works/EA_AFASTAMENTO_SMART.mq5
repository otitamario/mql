//+------------------------------------------------------------------+
#property copyright "Mario"
#property version "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

#resource "\\Indicators\\Indic_Afastamento_Media_MATS.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum OpcaoGap
  {
   Nao_Operar,//Não Operar
   Operar_Apos_Toque_Media,//Operar Após Toque na Média
   Operacoes_Normais          //Operar Normalmente
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
   Compra,//Operar Comprado
   Venda,         //Operar Vendido
   Compra_e_Venda //Operar Comprado e Vendido
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Moeda
  {
   EUR, //Europa
   CAN, //Canadá
   USD, //Estados Unidos
   BRL  //Brasil
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Touros
  {
   Touro_1, //1 Touro
   Touro_2, //2 Touros
   Touro_3  //3 Touros
  };

#import "Investing.dll"
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Trade\AccountInfo.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>
#include <Controls\Defines.mqh>

#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
//#undef CONTROLS_LABEL_COLOR

color borda_bg=clrNONE;                 //Cor Borda
color painel_bg=clrNONE;                 //Cor Painel clrNONE=Transparente
color cor_txt_borda_bg = clrYellowGreen; //Cor Texto Borda
                                         //color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG painel_bg
#define CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg
#include <Auxiliares.mqh>

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <ChartObjects\ChartObjectsLines.mqh>
#include <Controls\Defines.mqh>

CLabel m_label[50];
CButton BotaoFechar;
CButton BotaoDel;
CButton BotaoNews;

#define TENTATIVAS 10		// Tentativas envio ordem
#define TAM_MAX_PRECOS 500 //Tamanho Maximo Array de PRECOS ACIMA ou ABAIXO
#define LARGURA_PAINEL 450 // Largura Painel
#define ALTURA_PAINEL 210  // Altura Painel
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {

   int xx1 = INDENT_LEFT;
   int yy1 = INDENT_TOP;
   int xx2 = x1 + BUTTON_WIDTH;
   int yy2 = INDENT_TOP + BUTTON_HEIGHT;

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return (false);

//--- create dependent controls

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"RESULTADO DIÁRIO: "+DoubleToString(lucro_total,2),xx1,yy1,xx2,yy2))
      return (false);
   m_label[0].Color(clrKhaki);

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"GAINS NO DIA: "+DoubleToString(GainsOrdens()+(LucroPositions()>0 ? LucroPositions() : 0),2)+"     LOSS NO DIA: "+DoubleToString(LossOrdens()+(LucroPositions()<0 ? LucroPositions() : 0),2),xx1,yy1,xx2,yy2))
      return (false);
   m_label[1].Color(clrPaleTurquoise);

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + 2 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"Nome: "+AccountInfoString(ACCOUNT_NAME),xx1,yy1,xx2,yy2))
      return (false);
   m_label[2].Color(clrDeepSkyBlue);

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + 3 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;
   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"Servidor: "+AccountInfoString(ACCOUNT_SERVER)+" Login: "+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)),xx1,yy1,xx2,yy2))
      return (false);
   m_label[3].Color(clrYellow);

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + 4 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],"RESULTADO MENSAL: "+DoubleToString(lucro_total_mes,2),xx1,yy1,xx2,yy2))
      return (false);

   m_label[4].Color(clrYellow);

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + 5 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[5],"RESULTADO SEMANAL: "+DoubleToString(lucro_total_semana,2),xx1,yy1,xx2,yy2))
      return (false);

   m_label[5].Color(clrMediumSpringGreen);

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + 6 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;
   m_label[0].Color(clrMediumSpringGreen);

   if(!CreateLabel(m_chart_id,m_subwin,m_label[6],"GAINS NA SEMANA: "+DoubleToString(GainsOrdensSemana()+(LucroPositions()>0 ? LucroPositions() : 0),2)+"     LOSS NA SEMANA: "+DoubleToString(LossOrdensSemana()+(LucroPositions()<0 ? LucroPositions() : 0),2),xx1,yy1,xx2,yy2))
      return (false);
   m_label[6].Color(clrMediumSpringGreen);

   xx1 = LARGURA_PAINEL - INDENT_RIGHT - BUTTON_WIDTH - CONTROLS_GAP_X;
   yy1 = INDENT_TOP;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 =(int)( yy1 + 1.5 * BUTTON_HEIGHT);

   if(!CreateButton(m_chart_id,m_subwin,BotaoFechar,"Close ALL",xx1,yy1,xx2,yy2))
      return (false);
   BotaoFechar.ColorBackground(clrLimeGreen);

   xx1 = LARGURA_PAINEL - INDENT_RIGHT - BUTTON_WIDTH - CONTROLS_GAP_X;
   yy1 = INDENT_TOP + (BUTTON_HEIGHT + 4 * CONTROLS_GAP_Y);
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 =(int)(yy1 + 1.5 * BUTTON_HEIGHT);

   if(!CreateButton(m_chart_id,m_subwin,BotaoDel,"DEL ALL",xx1,yy1,xx2,yy2))
      return (false);
   BotaoDel.ColorBackground(clrBlueViolet);
   BotaoDel.Color(clrYellow);

   xx1 = LARGURA_PAINEL - INDENT_RIGHT - BUTTON_WIDTH - CONTROLS_GAP_X;
   yy1 = INDENT_TOP + 2 * (BUTTON_HEIGHT + 4 * CONTROLS_GAP_Y);
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 =(int)( yy1 + 1.5 * BUTTON_HEIGHT);

   if(!CreateButton(m_chart_id,m_subwin,BotaoNews,"Notícias",xx1,yy1,xx2,yy2))
      return (false);
   BotaoNews.ColorBackground(clrRed);
   BotaoNews.Color(clrYellow);

//--- succeed
   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnTick(void)
  {
   m_label[0].Text("RESULTADO DIÁRIO: " + DoubleToString(lucro_total, 2));
   m_label[1].Text("GAINS NO DIA: "+DoubleToString(GainsOrdens()+(LucroPositions()>0 ? LucroPositions() : 0),2)+"     LOSS NO DIA: "+DoubleToString(LossOrdens()+(LucroPositions()<0 ? LucroPositions() : 0),2));
   m_label[2].Text("Nome: " + AccountInfoString(ACCOUNT_NAME));
   m_label[3].Text("Servidor: " + AccountInfoString(ACCOUNT_SERVER) + " Login: " + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)));
   m_label[4].Text("RESULTADO MENSAL: " + DoubleToString(lucro_total_mes, 2));
   m_label[5].Text("RESULTADO SEMANAL: " + DoubleToString(lucro_total_semana, 2));
   m_label[6].Text("GAINS NA SEMANA: "+DoubleToString(GainsOrdensSemana()+(LucroPositions()>0 ? LucroPositions() : 0),2)+"     LOSS NA SEMANA: "+DoubleToString(LossOrdensSemana()+(LucroPositions()<0 ? LucroPositions() : 0),2));
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
CiMA *media;
CiMA *media_sec;
CControlsDialog ExtDialog;
// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT; //TIMEFRAME ROBO
input ulong Magic_Number=11;
input ulong deviation_points= 50;                                                                                                    //Deviation em Pontos(Padrao)
input double Lot = 1;                                                                                                                //Lote Entrada
input double _Stop= 20.0;                                                                                                             //Stop Loss Máximo em Pontos
input double _TakeProfit = 2.0;                                                                                                       //Take Profit em Pontos
sinput string sxtempo="----------------------------------Tempo=Minutos+Segundos-----------------------------------------------";   //Tempo para Cancelar Reentrada e Entrar a Mercado
input int xminutos=1;                                                                                                                //Tempo em Minutos
input int xsegundos=0;                                                                                                             //Tempo em Segundos
input double dist_entr=2.0;                                                                                                          //Distância para Entrada/Preço Médio Para Entrar à Mercado
sinput string Lucro="###--------------------------------Usar Lucro/Prejuizo para Fechamento------------------------------#####";   //Filtro Lucro
input bool UsarLucro= false;                                                                                                          //Usar Lucro para Fechamento Diário True/False
input double lucro = 1000.0;                                                                                                          //Lucro para Fechar Posicoes no Dia
input double prejuizo = 500.0;                                                                                                       //Prejuizo para Fechar Posicoes no Dia
sinput string shorario = "############------------------------------FILTRO DE HORARIO----------------------------#################"; //Horário
input bool UseTimer = true;                                                                                                          //Usar Filtro de Horário: True/False
input string start_hour = "9:00";                                                                                                    //Horario Inicial
input string end_hour_entr= "17:00";                                                                                                 //Horario Final Entradas
input string end_hour="17:30";                                                                                                       //Horario Final
input bool daytrade = true;                                                                                                          //Fechar Posicao Fim do Horario
sinput string sinvest = "############------------------------Notícias Investig.com------------------------------#################";  //Notícias
input bool UsarNew=true;                                                                                                             //Usar filtro de Notícias
input Moeda Inp_pais=USD;                                                                                                          //País das Notícias
input Touros Inp_touros=Touro_3;                                                                                                    //Touros
input uint minutos_news=15;                                                                                                          //Tempo em Minutos para pausar o EA antes e depois da notícia
sinput string SEst_Med = "############----------------------------------Estratégia--------------------------------------########";   //Estratégia
input int period_media = 7;                                                                                                          //Periodo da Media
input ENUM_MA_METHOD modo_media = MODE_EMA;                                                                                           //Modo da Média
input ENUM_APPLIED_PRICE app_media = PRICE_CLOSE;                                                                                     //Aplicar a
input double dist_media = 2.0;                                                                                                       //Distância da Média em Pontos para fazer Entrada
input Operacao operacao = Contra;                                                                                                    //Operar a Favor ou Contra a Tendência
input Sentido operar=Compra_e_Venda;                                                                                                 // Operar Comprado, Vendido
input bool cada_tick= true;
input bool sair_media=true;                                                                                                          //True:Sair na Média- False: Sair Take Profit                                                                                //Operar a cada tick
sinput string Spontos_aumento = "############-------------------------Pontos Aumento de Posição---------------------------########"; //Aumento Posição
input double pt_aum1 = 2.0;                                                                                                          //Pontos Aumento de Posição 1 (0 Não usar)
input double pt_aum2 = 4.0;                                                                                                          //Pontos Aumento de Posição 2 (0 Não usar)
input double pt_aum3 = 6.0;                                                                                                          //Pontos Aumento de Posição 3 (0 Não usar)
input double pt_aum4 = 8.0;                                                                                                          //Pontos Aumento de Posição 4 (0 Não usar)
input double pt_aum5 = 10.0;                                                                                                          //Pontos Aumento de Posição 5 (0 Não usar)
input double pt_aum6 = 12.0;                                                                                                          //Pontos Aumento de Posição 6 (0 Não usar)
input double pt_aum7 = 14.0;                                                                                                          //Pontos Aumento de Posição 7 (0 Não usar)
input double pt_aum8 = 16.0;                                                                                                          //Pontos Aumento de Posição 8 (0 Não usar)
sinput string Slotes_aumento="############--------------------------Lotes Aumento de Posição--------------------------########";   //Lotes Aumento		  //Lotes Aumento Posição
input double lote_aum1 = 1.0;                                                                                                          //Lotes Aumento de Posição 1 (0 Não usar)
input double lote_aum2 = 1.0;                                                                                                          //Lotes Aumento de Posição 2 (0 Não usar)
input double lote_aum3 = 2.0;                                                                                                          //Lotes Aumento de Posição 3 (0 Não usar)
input double lote_aum4 = 2.0;                                                                                                          //Lotes Aumento de Posição 4 (0 Não usar)
input double lote_aum5 = 4.0;                                                                                                          //Lotes Aumento de Posição 5 (0 Não usar)
input double lote_aum6 = 4.0;                                                                                                          //Lotes Aumento de Posição 6 (0 Não usar)
input double lote_aum7 = 4.0;                                                                                                          //Lotes Aumento de Posição 7 (0 Não usar)
input double lote_aum8 = 4.0;                                                                                                          //Lotes Aumento de Posição 8 (0 Não usar)

sinput string SsaidSec="-------------------------------------Saída Média Secundária------------------------------------";   //Média Secundária
input int period_med_sec = 5;                                                                                                   //Período Média Secundária
input ENUM_MA_METHOD mode_sec = MODE_EMA;                                                                                       //Modo Média Secundária
input ENUM_APPLIED_PRICE app_sec = PRICE_CLOSE;                                                                                 //Aplicar a
input ulong saida_sec = 4;                                                                                                      //Aum de Pos p acionar Fech Média Sec/ 0 Não Sair na Secundária
sinput string SGap="-------------------------------------------Filtro de Gap---------------------------------------------"; //Gap
input OpcaoGap UsarGap=Operar_Apos_Toque_Media;                                                                              //Opção de Gap
input double pts_gap=10;                                                                                                      //Gap em Pontos para Filtrar Entradas

sinput string sbreak="########---------------------------------Break Even-----------------------------------###############";  //Break Even
input bool UseBreakEven=true;                                                                                                   //Usar BreakEven
input double BreakEvenPoint1 = 1.5;                                                                                                //Pontos para BreakEven 1
input double ProfitPoint1 = 0.5;                                                                                                   //Pontos de Lucro da Posicao 1
input double BreakEvenPoint2 = 2.5;                                                                                                //Pontos para BreakEven 2
input double ProfitPoint2 = 1.0;                                                                                                   //Pontos de Lucro da Posicao 2
input double BreakEvenPoint3 = 4.0;                                                                                                //Pontos para BreakEven 3
input double ProfitPoint3 = 2.0;                                                                                                   //Pontos de Lucro da Posicao 3
sinput string STrailing = "############--------------------------------Trailing Stop----------------------------------########"; //Trailing
input bool Use_TraillingStop = true;                                                                                             //Usar Trailing
input double TraillingStart= 0;                                                                                                   //Lucro Minimo Iniciar trailing stop
input double TraillingDistance = 3.0;                                                                                             // Distanccia em Pontos do Stop Loss
input double TraillingStep=1.0;                                                                                                // Passo para atualizar Stop Loss

                                                                                                                               //Variaveis

string original_symbol;
double Ask,Bid;
double lucro_total,lucro_total_semana,lucro_total_mes;
bool TimerOn,tradeOn,timerEnt,gapOn;
double ponto,ticksize;
int _digits;
long curChartID;
int media_mat_handle;
double High[],Low[],Open[],Close[];
string glob_entr_tot="ENT_TOT"+Symbol()+IntegerToString(Magic_Number);
string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string tp_vd_tick="tp_vd_tick"+Symbol()+IntegerToString(Magic_Number),tp_cp_tick="tp_cp_tick"+Symbol()+IntegerToString(Magic_Number);

string deals_total="deals_total"+Symbol()+IntegerToString(Magic_Number),deals_total_prev="deals_total_prev"+Symbol()+IntegerToString(Magic_Number);
string Close_buy_sec="Close_buy_sec"+Symbol()+IntegerToString(Magic_Number),Close_sell_sec="Close_sell_sec"+Symbol()+IntegerToString(Magic_Number);
string gv_today="gv_today"+Symbol()+IntegerToString(Magic_Number),gv_today_prev="gv_today_prev"+Symbol()+IntegerToString(Magic_Number);
string last_stop= "last_stop"+Symbol()+IntegerToString(Magic_Number);
string pos_stop = "pos_stop"+Symbol()+IntegerToString(Magic_Number);

double buyprice,sellprice,oldprice;
string informacoes=" ";
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
datetime time_novodia[4];
double lotes_stop;
int res_code;
int cont;
datetime hora_inicial,hora_final,hora_final_ent;
double sl_position,tp_position;
double vol_pos,vol_stp,preco_stp;
MqlDateTime TimeNow;
int total_deals,cont_deals;
ulong ticket_history_deal,deal_magic;
double PointBreakEven[3],PointProfit[3];
bool tradebarra;
ENUM_ORDER_TYPE_TIME order_time_type;
string pais;
int touros;
bool investing_filter,TemNoticia;
datetime Hora_in[],Hora_fin[];
bool buysignal,sellsignal;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   switch(Inp_pais)
     {
      case EUR:
         pais="EUR";
         break;
      case CAN:
         pais="CAN";
         break;
      case USD:
         pais="USD";
         break;
      case BRL:
         pais="BRL";
         break;
     }

   switch(Inp_touros)
     {
      case Touro_1:
         touros=1;
         break;
      case Touro_2:
         touros=2;
         break;
      case Touro_3:
         touros=3;
         break;
     }

   if(UsarNew && HorasInvesting(pais,touros))
     {
      investing_filter=false;
      int j=ObjectsDeleteAll(ChartID(),0,OBJ_VLINE);
      ArrayResize(VLine,ArraySize(Hora_fin));
      for(int i=0; i<ArraySize(Hora_fin); i++)
        {
         if(Hora_in[i]>0 && Hora_fin[i]>0)
           {
            Print("inicio "+TimeToString(Hora_in[i])+" fim "+TimeToString(Hora_fin[i]));
            investing_filter=investing_filter || (TimeCurrent()>=Hora_in[i] && TimeCurrent()<=Hora_fin[i]);
            TemNoticia=true;
            VLine[i].Create(ChartID(), "News_" + IntegerToString(i), 0, Hora_in[i] + minutos_news * 60);
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

   if(UsarNew)
      MessageBox(NewsInvesting(pais,touros));

   TimeToStruct(TimeCurrent(),TimeNow);
   GlobalVariableSet(gv_today_prev,(double)TimeNow.day_of_year);

   original_symbol=Symbol();
   if(SymbolInfoInteger(original_symbol,SYMBOL_EXPIRATION_MODE)==2)
      order_time_type=1;
   else
      order_time_type=0;

   tradeOn=true;
   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.SetDeviationInPoints(deviation_points);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
   if(IsFillingTypeAlLowed(SYMBOL_FILLING_FOK))
      Print("ORDER_FILLING_FOK");
   else if(IsFillingTypeAlLowed(SYMBOL_FILLING_IOC))
      Print("ORDER_FILLING_IOC");
   else
      Print("ORDER_FILLING_RETURN");
   if(IsFillingTypeAlLowed(SYMBOL_FILLING_FOK))
      mytrade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAlLowed(SYMBOL_FILLING_IOC))
      mytrade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      mytrade.SetTypeFilling(ORDER_FILLING_RETURN);
   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
   _digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);

   int find_wdo = StringFind(original_symbol, "WDO");
   int find_dol = StringFind(original_symbol, "DOL");
   if(find_dol >= 0 || find_wdo >= 0)
      ponto=1.0;

   curChartID=ChartID();

   media=new CiMA;
   media.Create(Symbol(), periodoRobo, period_media, 0, modo_media, app_media);
   media.AddToChart(curChartID, 0);

   media_sec=new CiMA;
   media_sec.Create(Symbol(), periodoRobo, period_med_sec, 0, mode_sec, app_sec);
   media_sec.AddToChart(curChartID, 0);

   media_mat_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\Indic_Afastamento_Media_MATS.ex5",period_media,modo_media,app_media);

   ChartIndicatorAdd(curChartID,(int)ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),media_mat_handle);

   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Open,true);

   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   hora_final_ent=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_entr);

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   if(hora_final_ent<=hora_inicial || hora_final_ent>=hora_final)
     {
      string erro="Hora Final das Entradas deve estar entre  Horário Inicial e Final";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   if(Lot<mysymbol.LotsMin())
     {
      string erro="Lote deve ser maior ou igual a "+DoubleToString(mysymbol.LotsMin(),2);
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   if(operacao==Favor && sair_media)
     {
      string erro="Para sair na Média somente Operando Contra a Tendência";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   if(dist_entr>_Stop)
     {
      string erro="A distância para Entradas à Mercado deve ser menor que o Stop Loss";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   if(dist_entr>pt_aum1)
     {
      string erro="A distância para Entradas à Mercado deve ser menor ou igual aos pontos do Primeiro Aumento";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   if(_Stop<=pt_aum1 || _Stop<=pt_aum2 || _Stop<=pt_aum3 || _Stop<=pt_aum4 || _Stop<=pt_aum5 || _Stop<=pt_aum6 || _Stop<=pt_aum7 || _Stop<=pt_aum8)

     {
      string erro="O Stop Máximo deve ser maior que todos pontos de aumento entrada ";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   PointBreakEven[0] = BreakEvenPoint1;
   PointBreakEven[1] = BreakEvenPoint2;
   PointBreakEven[2] = BreakEvenPoint3;
   PointProfit[0] = ProfitPoint1;
   PointProfit[1] = ProfitPoint2;
   PointProfit[2] = ProfitPoint3;
   for(int i=0; i<3; i++)
     {
      if(PointBreakEven[i]<PointProfit[i])
        {
         string erro="Profit do Break Even deve ser menor que o Ponto de Break Even";
         MessageBox(erro);
         Print(erro);
         return (INIT_PARAMETERS_INCORRECT);
        }
     }

   for(int i=0; i<2; i++)
     {
      if(PointBreakEven[i+1]<=PointBreakEven[i])
        {
         string erro="Pontos de Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return (INIT_PARAMETERS_INCORRECT);
        }
     }

   for(int i=0; i<2; i++)
     {
      if(PointProfit[i+1]<=PointProfit[i])
        {
         string erro="Pontos de Profit do Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return (INIT_PARAMETERS_INCORRECT);
        }
     }

//Global Variables Check

   if(!GlobalVariableCheck(glob_entr_tot))
      GlobalVariableSet(glob_entr_tot,0.0);
   if(!GlobalVariableCheck(cp_tick))
      GlobalVariableSet(cp_tick,0.0);
   if(!GlobalVariableCheck(vd_tick))
      GlobalVariableSet(vd_tick,0.0);
   if(!GlobalVariableCheck(tp_cp_tick))
      GlobalVariableSet(tp_cp_tick,0.0);
   if(!GlobalVariableCheck(tp_vd_tick))
      GlobalVariableSet(tp_vd_tick,0.0);

   if(!GlobalVariableCheck(Close_buy_sec))
      GlobalVariableSet(Close_buy_sec,0.0);
   if(!GlobalVariableCheck(Close_sell_sec))
      GlobalVariableSet(Close_sell_sec,0.0);

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
      return (INIT_FAILED);

//--- run application

   ExtDialog.Run();

   if(HistorySelect(iTime(original_symbol,PERIOD_D1,0),TimeCurrent()+PeriodSeconds(PERIOD_D1)))
     {
      total_deals=HistoryDealsTotal();
      ticket_history_deal=0;
      cont_deals= 0;
      for(int i = 0; i<total_deals; i++)
        {
         //--- try to get deals ticket_history_deal
         if((ticket_history_deal=HistoryDealGetTicket(i))>0)
           {
            deal_magic=HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
            if(deal_magic == Magic_Number && HistoryDealGetString(ticket_history_deal,DEAL_SYMBOL) == mysymbol.Name())
               cont_deals+= 1;
           }
        }
     }
   GlobalVariableSet(deals_total_prev,(double)cont_deals);

//---
   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(media_mat_handle);
   delete (media);
   delete (media_sec);
   DeletaIndicadores();
   ExtDialog.Destroy(reason);
   EventKillTimer();
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick)))
     {
      double dist_preco=PrecoMedio(POSITION_TYPE_BUY)-mysymbol.Ask();
      if(pt_aum1>0 && OrdemAbertaComment("BUY_1"+exp_name) && dist_preco>=dist_entr*ponto)
        {
         EventKillTimer();
         DeleteOrdersComment("BUY_1"+exp_name);
         mytrade.Buy(lote_aum1,original_symbol,0,myposition.StopLoss(),0,"BUY_Mercado"+exp_name);
         EventSetTimer(60*xminutos+xsegundos);
         return;
        }

      if(pt_aum2>0 && OrdemAbertaComment("BUY_2"+exp_name) && !OrdemAbertaComment("BUY_1"+exp_name) && dist_preco>=dist_entr*ponto)
        {
         EventKillTimer();
         DeleteOrdersComment("BUY_2"+exp_name);
         mytrade.Buy(lote_aum2,original_symbol,0,myposition.StopLoss(),0,"BUY_Mercado"+exp_name);
         EventSetTimer(60*xminutos+xsegundos);
         return;
        }
      if(pt_aum3>0 && OrdemAbertaComment("BUY_3"+exp_name) && !OrdemAbertaComment("BUY_2"+exp_name) && dist_preco>=dist_entr*ponto)
        {
         EventKillTimer();
         DeleteOrdersComment("BUY_3"+exp_name);
         mytrade.Buy(lote_aum3,original_symbol,0,myposition.StopLoss(),0,"BUY_Mercado"+exp_name);
         EventSetTimer(60*xminutos+xsegundos);
         return;
        }
      if(pt_aum4>0 && OrdemAbertaComment("BUY_4"+exp_name) && !OrdemAbertaComment("BUY_3"+exp_name) && dist_preco>=dist_entr*ponto)
        {
         EventKillTimer();
         DeleteOrdersComment("BUY_4"+exp_name);
         mytrade.Buy(lote_aum4,original_symbol,0,myposition.StopLoss(),0,"BUY_Mercado"+exp_name);
         EventSetTimer(60*xminutos+xsegundos);
         return;
        }
      if(pt_aum5>0 && OrdemAbertaComment("BUY_5"+exp_name) && !OrdemAbertaComment("BUY_4"+exp_name) && dist_preco>=dist_entr*ponto)
        {
         EventKillTimer();
         DeleteOrdersComment("BUY_5"+exp_name);
         mytrade.Buy(lote_aum5,original_symbol,0,myposition.StopLoss(),0,"BUY_Mercado"+exp_name);
         EventSetTimer(60*xminutos+xsegundos);
         return;
        }
      if(pt_aum6>0 && OrdemAbertaComment("BUY_6"+exp_name) && !OrdemAbertaComment("BUY_5"+exp_name) && dist_preco>=dist_entr*ponto)
        {
         EventKillTimer();
         DeleteOrdersComment("BUY_6"+exp_name);
         mytrade.Buy(lote_aum6,original_symbol,0,myposition.StopLoss(),0,"BUY_Mercado"+exp_name);
         EventSetTimer(60*xminutos+xsegundos);
         return;
        }
      if(pt_aum7>0 && OrdemAbertaComment("BUY_7"+exp_name) && !OrdemAbertaComment("BUY_6"+exp_name) && dist_preco>=dist_entr*ponto)
        {
         EventKillTimer();
         DeleteOrdersComment("BUY_7"+exp_name);
         mytrade.Buy(lote_aum7,original_symbol,0,myposition.StopLoss(),0,"BUY_Mercado"+exp_name);
         EventSetTimer(60*xminutos+xsegundos);
         return;
        }
      if(pt_aum8>0 && OrdemAbertaComment("BUY_8"+exp_name) && !OrdemAbertaComment("BUY_7"+exp_name) && dist_preco>=dist_entr*ponto)
        {
         EventKillTimer();
         DeleteOrdersComment("BUY_8"+exp_name);
         mytrade.Buy(lote_aum8,original_symbol,0,myposition.StopLoss(),0,"BUY_Mercado"+exp_name);
         EventSetTimer(60*xminutos+xsegundos);
         return;
        }
     }

   if(myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick)))
     {
      double dist_preco=mysymbol.Bid()-PrecoMedio(POSITION_TYPE_SELL);
      if(pt_aum1>0 && OrdemAbertaComment("SELL_1"+exp_name) && dist_preco>=dist_entr*ponto)
        {
         EventKillTimer();
         DeleteOrdersComment("SELL_1"+exp_name);
         mytrade.Sell(lote_aum1,original_symbol,0,myposition.StopLoss(),0,"SELL_Mercado"+exp_name);
         EventSetTimer(60*xminutos+xsegundos);
         return;
        }

      if(pt_aum2>0 && OrdemAbertaComment("SELL_2"+exp_name) && !OrdemAbertaComment("SELL_1"+exp_name) && dist_preco>=dist_entr*ponto)
        {
         EventKillTimer();
         DeleteOrdersComment("SELL_2"+exp_name);
         mytrade.Sell(lote_aum2,original_symbol,0,myposition.StopLoss(),0,"SELL_Mercado"+exp_name);
         EventSetTimer(60*xminutos+xsegundos);
         return;
        }
      if(pt_aum3>0 && OrdemAbertaComment("SELL_3"+exp_name) && !OrdemAbertaComment("SELL_2"+exp_name) && dist_preco>=dist_entr*ponto)
        {
         EventKillTimer();
         DeleteOrdersComment("SELL_3"+exp_name);
         mytrade.Sell(lote_aum3,original_symbol,0,myposition.StopLoss(),0,"SELL_Mercado"+exp_name);
         EventSetTimer(60*xminutos+xsegundos);
         return;
        }
      if(pt_aum4>0 && OrdemAbertaComment("SELL_4"+exp_name) && !OrdemAbertaComment("SELL_3"+exp_name) && dist_preco>=dist_entr*ponto)
        {
         EventKillTimer();
         DeleteOrdersComment("SELL_4"+exp_name);
         mytrade.Sell(lote_aum4,original_symbol,0,myposition.StopLoss(),0,"SELL_Mercado"+exp_name);
         EventSetTimer(60*xminutos+xsegundos);
         return;
        }
      if(pt_aum5>0 && OrdemAbertaComment("SELL_5"+exp_name) && !OrdemAbertaComment("SELL_4"+exp_name) && dist_preco>=dist_entr*ponto)
        {
         EventKillTimer();
         DeleteOrdersComment("SELL_5"+exp_name);
         mytrade.Sell(lote_aum5,original_symbol,0,myposition.StopLoss(),0,"SELL_Mercado"+exp_name);
         EventSetTimer(60*xminutos+xsegundos);
         return;
        }
      if(pt_aum6>0 && OrdemAbertaComment("SELL_6"+exp_name) && !OrdemAbertaComment("SELL_5"+exp_name) && dist_preco>=dist_entr*ponto)
        {
         EventKillTimer();
         DeleteOrdersComment("SELL_6"+exp_name);
         mytrade.Sell(lote_aum6,original_symbol,0,myposition.StopLoss(),0,"SELL_Mercado"+exp_name);
         EventSetTimer(60*xminutos+xsegundos);
         return;
        }
      if(pt_aum7>0 && OrdemAbertaComment("SELL_7"+exp_name) && !OrdemAbertaComment("SELL_6"+exp_name) && dist_preco>=dist_entr*ponto)
        {
         EventKillTimer();
         DeleteOrdersComment("SELL_7"+exp_name);
         mytrade.Sell(lote_aum7,original_symbol,0,myposition.StopLoss(),0,"SELL_Mercado"+exp_name);
         EventSetTimer(60*xminutos+xsegundos);
         return;
        }
      if(pt_aum8>0 && OrdemAbertaComment("SELL_8"+exp_name) && !OrdemAbertaComment("SELL_7"+exp_name) && dist_preco>=dist_entr*ponto)
        {
         EventKillTimer();
         DeleteOrdersComment("SELL_8"+exp_name);
         mytrade.Sell(lote_aum8,original_symbol,0,myposition.StopLoss(),0,"SELL_Mercado"+exp_name);
         EventSetTimer(60*xminutos+xsegundos);
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,// event ID
                  const long &lparam,   // event parameter of the long type
                  const double &dparam, // event parameter of the double type
                  const string &sparam) // event parameter of the string type
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

  } // fim OnTick
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(novodia || GlobalVariableGet(gv_today)!=GlobalVariableGet(gv_today_prev))
     {
      GlobalVariableSet(glob_entr_tot,0.0);
      GlobalVariableSet(last_stop,0.0);
      tradeOn=true;

      if(UsarNew && HorasInvesting(pais,touros))
        {
         investing_filter=false;
         int j=ObjectsDeleteAll(ChartID(),0,OBJ_VLINE);
         ArrayResize(VLine,ArraySize(Hora_fin));
         for(int i=0; i<ArraySize(Hora_fin); i++)
           {
            if(Hora_in[i]>0 && Hora_fin[i]>0)
              {
               Print("inicio "+TimeToString(Hora_in[i])+" fim "+TimeToString(Hora_fin[i]));
               investing_filter=investing_filter || (TimeCurrent()>=Hora_in[i] && TimeCurrent()<=Hora_fin[i]);
               TemNoticia=true;
               VLine[i].Create(ChartID(), "News_" + IntegerToString(i), 0, Hora_in[i] + minutos_news * 60);
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

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   media.Refresh();
   media_sec.Refresh();
   ExtDialog.OnTick();
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   hora_final_ent=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_entr);

   if(mysymbol.Bid()>mysymbol.Ask() && mysymbol.Ask()>0)
      return; //LEILÃO

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

   TimerOn=true;
   timerEnt=true;
   investing_filter=false;
   if(UsarNew)
      investing_filter=InvestingTime(TemNoticia);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer==true)
     {
      TimerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final;
      timerEnt=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final_ent;
      if(UsarNew && investing_filter)
         TimerOn=false;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!TimerOn && daytrade)
     {
      if(OrdersTotal()>0)
         DeleteALL();
      if(PositionsTotal()>0)
         CloseALL();
     }

//Atualizacao das Cotacoes----ticks
   MqlTick last_tick;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(SymbolInfoTick(Symbol(),last_tick))
     {
      Bid = last_tick.bid;
      Ask = last_tick.ask;
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
      Print("Bid ou Ask=0 : ",Bid," ",Ask);
      return;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_Opened() && Sell_Opened())
     {
      DeleteALL();
      CloseByPosition();
     }
   if(!PosicaoAberta() && OrdersTotal()>0)
      DeleteALL();
   if(!PosicaoAberta())
     {
      GlobalVariableSet(Close_buy_sec,0.0);
      GlobalVariableSet(Close_sell_sec,0.0);
     }
   if(tradeOn && TimerOn)

     { // inicio Trade On

      Atual_vol_Stop_Take();

      if(operacao==Contra)
        {
         if(CheckBuyClose() && Buy_Opened())
           {
            DeleteALL();
            CloseByPosition();
            ClosePosType(POSITION_TYPE_BUY);
           }
         if(CheckSellClose() && Sell_Opened())
           {
            DeleteALL();
            CloseByPosition();
            ClosePosType(POSITION_TYPE_SELL);
           }
        }

      if(timerEnt && gapOn)
        {
         if(sair_media)
           {
            buysignal=BuySignal() && !Buy_Opened();
            sellsignal=SellSignal() && !Sell_Opened();
           }
         else
           {
            buysignal=BuySignal() && !PosicaoAberta();
            sellsignal=SellSignal() && !PosicaoAberta();
           }

         if(CheckNewBar(periodoRobo))
           {
            tradebarra=true;
            if(!cada_tick)
              {
               if(buysignal && operar!=Venda && tradebarra && TradeStop())
                 {
                  if(Sell_Opened())
                     ClosePosType(POSITION_TYPE_SELL);
                  DeleteALL();
                  if(mytrade.Buy(Lot,original_symbol,0,NormalizeDouble(Bid-_Stop*ponto,_digits),0,"BUY"+exp_name))
                    {
                     GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
                     tradebarra=false;
                    }
                  else
                     Print("Erro enviar ordem ",GetLastError());
                 }

               if(sellsignal && operar!=Compra && tradebarra && TradeStop())
                 {
                  if(Buy_Opened())
                     ClosePosType(POSITION_TYPE_BUY);
                  DeleteALL();
                  if(mytrade.Sell(Lot,original_symbol,0,NormalizeDouble(Ask+_Stop*ponto,_digits),0,"SELL"+exp_name))
                    {
                     GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
                     tradebarra=false;
                    }
                  else
                     Print("Erro enviar ordem ",GetLastError());
                 }
              }

           } //Fim Nova Barra

         if(cada_tick)
           {

            if(buysignal && operar!=Venda && tradebarra && TradeStop())
              {
               DeleteALL();
               if(Sell_Opened())
                  ClosePosType(POSITION_TYPE_SELL);
               if(mytrade.Buy(Lot,original_symbol,0,NormalizeDouble(Bid-_Stop*ponto,_digits),0,"BUY"+exp_name))
                 {
                  GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
                  tradebarra=false;
                 }
               else
                  Print("Erro enviar ordem ",GetLastError());
              }

            if(sellsignal && operar!=Compra && tradebarra && TradeStop())
              {

               DeleteALL();
               if(Buy_Opened())
                  ClosePosType(POSITION_TYPE_BUY);
               if(mytrade.Sell(Lot,original_symbol,0,NormalizeDouble(Ask+_Stop*ponto,_digits),0,"SELL"+exp_name))
                 {
                  GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
                  tradebarra=false;
                 }
               else
                  Print("Erro enviar ordem ",GetLastError());
              }
           }

        } // Fim Time Entradas

      if(Use_TraillingStop)
         TrailingStop(TraillingDistance,TraillingStart,TraillingStep);
      if(UseBreakEven && PosicaoAberta())
         BreakEven(original_symbol,UseBreakEven,PointBreakEven,PointProfit);

     } //End Trade On

  } //End Main Program
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Buy conditions                                                   |
//+------------------------------------------------------------------+
bool Buy_Opened()
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_BUY)
         return(true); //It is a Buy
     }
   return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Sell_Opened()
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_SELL)
         return(true); //It is a Buy
     }
   return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   bool b_signal;
   if(operacao == Favor)
      b_signal = Bid - media.Main(0) >= dist_media * ponto;
   else
      b_signal=media.Main(0)-Ask>=dist_media*ponto;

   return b_signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   bool s_signal;
   if(operacao == Favor)
      s_signal = media.Main(0) - Ask >= dist_media * ponto;
   else
      s_signal=Bid-media.Main(0)>=dist_media*ponto;
   return s_signal;
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
   b_get=CopyHigh(Symbol(),periodoRobo,0,5,High)<=0 || 
         CopyOpen(Symbol(),periodoRobo,0, 5, Open) <= 0 ||
         CopyLow(Symbol(), periodoRobo, 0, 5, Low) <= 0 ||
         CopyClose(Symbol(),periodoRobo,0,5,Close) <= 0;
   return (b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CloseALL()
  {

   for(int i=PositionsTotal()-1; i>=0; i--)
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

   for(int i=PositionsTotal()-1; i>=0; i--)
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
         if(myorder.Magic()==Magic_Number && myorder.Symbol()==mysymbol.Name())
            mytrade.OrderDelete(o_ticket);
        }
     }
  }
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
double PriceLastStopOrder(const ENUM_ORDER_TYPE pending_order_type)
  {
   datetime last_time= 0;
   double last_price = -1.0;
   for(int i=OrdersTotal()-1; i>=0; i--) // returns the number of current orders
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
   return (last_price);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void DeleteOrders(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1; i>=0; i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteOrdersComment(const string cmt)
  {
   for(int i=OrdersTotal()-1; i>=0; i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.Comment()==cmt)
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
   for(int i=OrdersTotal()-1; i>=0; i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrdemAbertaComment(const string cmt)
  {
   for(int i=OrdersTotal()-1; i>=0; i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.Comment()==cmt)
               return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//| Checks if the specified filling mode is alLowed                  |
//+------------------------------------------------------------------+
bool IsFillingTypeAlLowed(int fill_type)
  {
//--- Obtain the value of the property that describes alLowed filling modes
   int filling=mysymbol.TradeFillFlags();
//--- Return true, if mode fill_type is alLowed
   return ((filling & fill_type) == fill_type);
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
   time_aux.hour= 0;
   time_aux.min = 0;
   time_aux.sec = 0;
   datetime tm_start=StructToTime(time_aux);
   HistorySelect(tm_start,tm_end);
   total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0; i<total_deals; i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            profit+=mydeal.Profit();
     }
   return (profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LucroPositions()
  {
   double profit=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
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
   for(int w=windows-1; w>=0; w--)
     {
      //--- o número de indicadores nesta janela/sub-janela
      int total=ChartIndicatorsTotal(0,w);
      //--- Passar por todos os indicadores na janela
      for(int i=total-1; i>=0; i--)
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
      return (myposition.PositionType() == POSITION_TYPE_BUY || myposition.PositionType() == POSITION_TYPE_SELL);
   else
      return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void MytradeTransaction()
  {
   ulong order_ticket;
   ulong deals_ticket;

   if(HistorySelect(iTime(original_symbol,PERIOD_D1,0),TimeCurrent()))
     {
      total_deals=HistoryDealsTotal();
      ticket_history_deal=0;
      deals_ticket=0;
      cont_deals = 0;
      for(int i = 0; i < total_deals; i++)
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
            if((order_ticket==(ulong)GlobalVariableGet(cp_tick) || order_ticket==(ulong)GlobalVariableGet(vd_tick)))
              {
               GlobalVariableSet(glob_entr_tot,GlobalVariableGet(glob_entr_tot)+1);
              }

            if(order_ticket==(ulong)GlobalVariableGet(cp_tick))

              {
               myposition.SelectByTicket(order_ticket);
               cont = 0;
               buyprice = 0;
               while(buyprice==0 && cont<TENTATIVAS)
                 {
                  buyprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(buyprice == 0)
                  buyprice = mysymbol.Ask();
               sl_position = NormalizeDouble(buyprice - _Stop * ponto, _digits);
               tp_position = NormalizeDouble(buyprice + _TakeProfit * ponto, _digits);
               mytrade.PositionModify(order_ticket,sl_position,0);
               if(mytrade.SellLimit(Lot,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT"))
                 {
                  GlobalVariableSet(tp_vd_tick,(double)mytrade.ResultOrder());
                 }
               else
                  Print("Erro enviar ordem: ",GetLastError());

               Aumento_Buy();
               EventSetTimer(xminutos*60+xsegundos);
              }
            //--------------------------------------------------

            if(order_ticket==(ulong)GlobalVariableGet(vd_tick))
              {
               myposition.SelectByTicket(order_ticket);
               cont=0;
               sellprice=0;
               while(sellprice==0 && cont<TENTATIVAS)
                 {
                  sellprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(sellprice == 0)
                  sellprice = mysymbol.Bid();
               sl_position = NormalizeDouble(sellprice + _Stop * ponto, _digits);
               tp_position = NormalizeDouble(sellprice - _TakeProfit * ponto, _digits);
               mytrade.PositionModify(order_ticket,sl_position,0);
               if(mytrade.BuyLimit(Lot,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT"))
                 {
                  GlobalVariableSet(tp_cp_tick,(double)mytrade.ResultOrder());
                 }
               else
                  Print("Erro enviar ordem: ",GetLastError());
               Aumento_Sell();
               EventSetTimer(xminutos*60+xsegundos);
              }
            if(saida_sec>0 && sair_media)
              {
               if(mydeal.Comment()=="BUY_"+IntegerToString(saida_sec)+exp_name)
                 {
                  Print("Ativado Saída pela Média Secundária");
                  GlobalVariableSet(Close_buy_sec,1.0);
                 }
               if(mydeal.Comment()=="SELL_"+IntegerToString(saida_sec)+exp_name)
                 {
                  Print("Ativado Saída pela Média Secundária");
                  GlobalVariableSet(Close_sell_sec,1.0);
                 }
              }

            if(StringFind(mydeal.Comment(),"BUY_")!=-1||StringFind(mydeal.Comment(),"SELL_")!=-1)
              {
               EventKillTimer();
               EventSetTimer(xminutos*60+xsegundos);
              }

            if((mydeal.DealType()==DEAL_TYPE_BUY || mydeal.DealType()==DEAL_TYPE_SELL) && mydeal.Entry()==DEAL_ENTRY_OUT)
              {
               if(mydeal.Profit()<0)
                 {
                  Print("Saída por STOP LOSS. Aguardar Toque na Média");
                  GlobalVariableSet(last_stop,1.0);
                  GlobalVariableSet(pos_stop,mydeal.Price()-media.Main(0));
                 }
              }

           } // if dealsticket>0
        }    //Fim deals>prev
     }        //Fim HistorySelect

   GlobalVariableSet(deals_total_prev,GlobalVariableGet(deals_total));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void Aumento_Buy()
  {
   myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick));
   double preco_entr=myposition.PriceOpen();
   if(preco_entr<= 0.0 && mysymbol.Ask()>0)
      preco_entr = mysymbol.Ask();
   double preco_stop = myposition.StopLoss();
   double preco_take = myposition.TakeProfit();
   if(pt_aum1>0)
      mytrade.BuyLimit(lote_aum1,NormalizeDouble(preco_entr-pt_aum1*ponto,_digits),original_symbol,preco_stop,preco_take,0,0,"BUY_1"+exp_name);
   if(pt_aum2>0)
      mytrade.BuyLimit(lote_aum2,NormalizeDouble(preco_entr-pt_aum2*ponto,_digits),original_symbol,preco_stop,preco_take,0,0,"BUY_2"+exp_name);
   if(pt_aum3>0)
      mytrade.BuyLimit(lote_aum3,NormalizeDouble(preco_entr-pt_aum3*ponto,_digits),original_symbol,preco_stop,preco_take,0,0,"BUY_3"+exp_name);
   if(pt_aum4>0)
      mytrade.BuyLimit(lote_aum4,NormalizeDouble(preco_entr-pt_aum4*ponto,_digits),original_symbol,preco_stop,preco_take,0,0,"BUY_4"+exp_name);
   if(pt_aum5>0)
      mytrade.BuyLimit(lote_aum5,NormalizeDouble(preco_entr-pt_aum5*ponto,_digits),original_symbol,preco_stop,preco_take,0,0,"BUY_5"+exp_name);
   if(pt_aum6>0)
      mytrade.BuyLimit(lote_aum6,NormalizeDouble(preco_entr-pt_aum6*ponto,_digits),original_symbol,preco_stop,preco_take,0,0,"BUY_6"+exp_name);
   if(pt_aum7>0)
      mytrade.BuyLimit(lote_aum7,NormalizeDouble(preco_entr-pt_aum7*ponto,_digits),original_symbol,preco_stop,preco_take,0,0,"BUY_7"+exp_name);
   if(pt_aum8>0)
      mytrade.BuyLimit(lote_aum8,NormalizeDouble(preco_entr-pt_aum8*ponto,_digits),original_symbol,preco_stop,preco_take,0,0,"BUY_8"+exp_name);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Aumento_Sell()
  {
   myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick));
   double preco_entr=myposition.PriceOpen();
   if(preco_entr<= 0.0 && mysymbol.Bid()>0)
      preco_entr = mysymbol.Bid();
   double preco_stop = myposition.StopLoss();
   double preco_take = myposition.TakeProfit();
   if(pt_aum1>0)
      mytrade.SellLimit(lote_aum1,NormalizeDouble(preco_entr+pt_aum1*ponto,_digits),original_symbol,preco_stop,preco_take,0,0,"SELL_1"+exp_name);
   if(pt_aum2>0)
      mytrade.SellLimit(lote_aum2,NormalizeDouble(preco_entr+pt_aum2*ponto,_digits),original_symbol,preco_stop,preco_take,0,0,"SELL_2"+exp_name);
   if(pt_aum3>0)
      mytrade.SellLimit(lote_aum3,NormalizeDouble(preco_entr+pt_aum3*ponto,_digits),original_symbol,preco_stop,preco_take,0,0,"SELL_3"+exp_name);
   if(pt_aum4>0)
      mytrade.SellLimit(lote_aum4,NormalizeDouble(preco_entr+pt_aum4*ponto,_digits),original_symbol,preco_stop,preco_take,0,0,"SELL_4"+exp_name);
   if(pt_aum5>0)
      mytrade.SellLimit(lote_aum5,NormalizeDouble(preco_entr+pt_aum5*ponto,_digits),original_symbol,preco_stop,preco_take,0,0,"SELL_5"+exp_name);
   if(pt_aum6>0)
      mytrade.SellLimit(lote_aum6,NormalizeDouble(preco_entr+pt_aum6*ponto,_digits),original_symbol,preco_stop,preco_take,0,0,"SELL_6"+exp_name);
   if(pt_aum7>0)
      mytrade.SellLimit(lote_aum7,NormalizeDouble(preco_entr+pt_aum7*ponto,_digits),original_symbol,preco_stop,preco_take,0,0,"SELL_7"+exp_name);
   if(pt_aum8>0)
      mytrade.SellLimit(lote_aum8,NormalizeDouble(preco_entr+pt_aum8*ponto,_digits),original_symbol,preco_stop,preco_take,0,0,"SELL_8"+exp_name);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

bool CheckSellClose()
  {
   bool dist= Ask<= media.Main(0);
   bool sec = false;
   if(GlobalVariableGet(Close_sell_sec)==1.0 && saida_sec>0)
      sec=Ask<=media_sec.Main(0);
   if(sair_media)
      return (dist || sec);
   else
      return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckBuyClose()
  {
   bool dist= Bid>= media.Main(0);
   bool sec = false;
   if(GlobalVariableGet(Close_buy_sec)==1.0 && saida_sec>0)
      sec=Bid>=media_sec.Main(0);
   if(sair_media)
      return (dist || sec);
   else
      return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void CloseByPosition()
  {
   ulong tick_sell,tick_buy;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      while(Buy_Opened() && Sell_Opened())
        {
         tick_buy=TickecBuyPos();
         tick_sell=TickecSellPos();
         if(tick_buy>0 && tick_sell>0)
            mytrade.PositionCloseBy(tick_buy,tick_sell);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
ulong TickecBuyPos()
  {
   ulong tick=0;
   if(Buy_Opened())
     {

      for(int i=PositionsTotal()-1; i>=0; i--)
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
   if(Sell_Opened())
     {
      for(int i=PositionsTotal()-1; i>=0; i--)
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
bool Gap()
  {
   return MathAbs(iClose(Symbol(), PERIOD_D1, 1) - iOpen(Symbol(), PERIOD_D1, 0)) >= pts_gap * ponto;
  }
//+------------------------------------------------------------------+
double Pts_Gap()
  {
   return MathAbs(iClose(Symbol(), PERIOD_D1, 1) - iOpen(Symbol(), PERIOD_D1, 0));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PriceCrossDown()
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
int PriceCrossUp()
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
bool CrossUpToday()
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
bool CrossDownToday()
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
bool CrossToday()
  {
   return CrossDownToday() || CrossUpToday();
  }
//+------------------------------------------------------------------+
bool IsConnect()
  {
   return ((bool)TerminalInfoInteger(TERMINAL_CONNECTED));
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void Atual_vol_Stop_Take()
  {

   if(PosicaoAberta())
     {
      if(Buy_Opened())
        {
         if(myposition.SelectByTicket((int)GlobalVariableGet(cp_tick)) && myorder.Select((int)GlobalVariableGet(tp_vd_tick)))
           {
            vol_pos = VolPosType(POSITION_TYPE_BUY);
            vol_stp = myorder.VolumeInitial();
            // preco_stp=myorder.PriceOpen();
            preco_stp=NormalizeDouble(PrecoMedio(POSITION_TYPE_BUY)+_TakeProfit*ponto,_digits);
            if(vol_pos!=vol_stp)
              {
               mytrade.OrderDelete((int)GlobalVariableGet(tp_vd_tick));
               mytrade.SellLimit(vol_pos, preco_stp, original_symbol, 0, 0, 0, 0, "TAKE PROFIT");
               GlobalVariableSet(tp_vd_tick,(double)mytrade.ResultOrder());
              }
           }
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(Sell_Opened())
        {

         if(myposition.SelectByTicket((int)GlobalVariableGet(vd_tick)) && myorder.Select((int)GlobalVariableGet(tp_cp_tick)))
           {
            vol_pos = VolPosType(POSITION_TYPE_SELL);
            vol_stp = myorder.VolumeInitial();
            //   preco_stp=myorder.PriceOpen();
            preco_stp=NormalizeDouble(PrecoMedio(POSITION_TYPE_SELL)-_TakeProfit*ponto,_digits);
            if(vol_pos!=vol_stp)
              {
               mytrade.OrderDelete((int)GlobalVariableGet(tp_cp_tick));
               mytrade.BuyLimit(vol_pos, preco_stp, original_symbol, 0, 0, 0, 0, "TAKE PROFIT");
               GlobalVariableSet(tp_cp_tick,(double)mytrade.ResultOrder());
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
double VolPosType(ENUM_POSITION_TYPE ptype)
  {
   double vol= 0;
   for(int i = PositionsTotal()-1; i>= 0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && myposition.Symbol()==mysymbol.Name())
        {
         vol+=myposition.Volume();
        }
     }
   return vol;
  }
//+------------------------------------------------------------------+
void BreakEven(string pSymbol,bool usarbreak,double &pBreakEven[],double &pLockProfit[])
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && usarbreak==true)
        {

         long posType=myposition.PositionType();
         ulong posTicket=myposition.Ticket();
         double currentSL;
         double OpenPrice = NormalizeDouble(MathRound(myposition.PriceOpen() / ticksize) * ticksize, _digits);
         double currentTP = myposition.TakeProfit();
         double breakEvenStop;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            // myorder.Select((ulong)GlobalVariableGet(stp_vd_tick));
            //currentSL=myorder.PriceOpen();
            currentSL=myposition.StopLoss();
            Bid=SymbolInfoDouble(pSymbol,SYMBOL_BID);
            currentProfit=mysymbol.Bid()-OpenPrice;
            //Break Even 0 a 1
            for(int k=0; k<2; k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop = OpenPrice + pLockProfit[k] * ponto;
                  breakEvenStop = NormalizeDouble(MathRound(breakEvenStop / ticksize) * ticksize, _digits);
                  if(currentSL<breakEvenStop || currentSL==0)
                    {
                     if(k==0)
                        Print("Break even stop 1:");
                     else
                        Print("Break even stop 2:");
                     mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                     //                     mytrade.OrderModify((ulong)GlobalVariableGet(stp_vd_tick),breakEvenStop,0,0,0,0,0);
                    }
                 }
              }
            //----------------------
            //Break Even 2
            if(currentProfit>=pBreakEven[2]*ponto)
              {
               breakEvenStop = OpenPrice + pLockProfit[2] * ponto;
               breakEvenStop = NormalizeDouble(MathRound(breakEvenStop / ticksize) * ticksize, _digits);
               if(currentSL<breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop 3:");
                  mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                  //mytrade.OrderModify((ulong)GlobalVariableGet(stp_vd_tick),breakEvenStop,0,0,0,0,0);
                 }
              }
           }
         //----------------------

         //----------------------

         if(posType==POSITION_TYPE_SELL)
           {
            // myorder.Select((ulong)GlobalVariableGet(stp_cp_tick));
            //currentSL=myorder.PriceOpen();
            currentSL=myposition.StopLoss();
            Ask=SymbolInfoDouble(pSymbol,SYMBOL_ASK);
            currentProfit=OpenPrice-mysymbol.Ask();
            //Break Even 0 a 1
            for(int k=0; k<2; k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop = OpenPrice - pLockProfit[k] * ponto;
                  breakEvenStop = NormalizeDouble(MathRound(breakEvenStop / ticksize) * ticksize, _digits);
                  if(currentSL>breakEvenStop || currentSL==0)
                    {
                     if(k==0)
                        Print("Break even stop 1:");
                     else
                        Print("Break even stop 2:");
                     mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                     //mytrade.OrderModify((ulong)GlobalVariableGet(stp_cp_tick),breakEvenStop,0,0,0,0,0);
                    }
                 }
              }
            //----------------------
            //Break Even 2
            if(currentProfit>=pBreakEven[2]*ponto)
              {
               breakEvenStop = OpenPrice - pLockProfit[2] * ponto;
               breakEvenStop = NormalizeDouble(MathRound(breakEvenStop / ticksize) * ticksize, _digits);
               if(currentSL>breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop 3:");
                  mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                  //mytrade.OrderModify((ulong)GlobalVariableGet(stp_cp_tick),breakEvenStop,0,0,0,0,0);
                 }
              }
            //----------------------
           }

        } //Fim Position Select

     } //Fim for
  }
// Trailing stop (points)
void TrailingStop(double pTrailPoints,double pMinProfit=0,double pStep=10)
  {

   for(int i=PositionsTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number && pTrailPoints>0)
        {

         double currentTakeProfit=myposition.TakeProfit();
         long posType=myposition.PositionType();
         double currentStop;
         double OpenPrice=NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,_digits);
         double point=ponto;
         if(pStep<10)
            pStep=10;
         double step=pStep*point;

         double minProfit = pMinProfit * point;
         double trailStop = pTrailPoints * point;
         currentTakeProfit= NormalizeDouble(currentTakeProfit,_digits);
         double trailStopPrice;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            //myorder.Select((ulong)GlobalVariableGet(stp_vd_tick));
            //currentStop=myorder.PriceOpen();
            currentStop=myposition.StopLoss();
            trailStopPrice = mysymbol.Bid() - trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice, _digits);
            currentProfit=mysymbol.Bid()-OpenPrice;

            if(trailStopPrice>currentStop+step && currentProfit>=minProfit)
              {
               mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
/*if(myorder.Select((ulong)GlobalVariableGet(stp_vd_tick)))
					  {
						mytrade.OrderModify((ulong)GlobalVariableGet(stp_vd_tick),trailStopPrice,0,0,0,0,0);
					  }*/
              }
           }
         else if(posType==POSITION_TYPE_SELL)
           {
            //myorder.Select((ulong)GlobalVariableGet(stp_cp_tick));
            //currentStop=myorder.PriceOpen();
            currentStop=myposition.StopLoss();
            trailStopPrice = mysymbol.Ask() + trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice, _digits);
            currentProfit=OpenPrice-mysymbol.Ask();

            if((trailStopPrice<currentStop-step || currentStop==0) && currentProfit>=minProfit)
              {
               mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
/*if(myorder.Select((ulong)GlobalVariableGet(stp_cp_tick)))
					  {
						mytrade.OrderModify((ulong)GlobalVariableGet(stp_cp_tick),trailStopPrice,0,0,0,0,0);
					  }*/
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
bool CheckNewBar(ENUM_TIMEFRAMES tf)
  {

   static datetime LastBar=0;
   datetime ThisBar=iTime(Symbol(),tf,0);
   if(LastBar!=ThisBar)
     {
      PrintFormat("New bar. Opening time: %s  Time of last tick: %s",
                  TimeToString((datetime)ThisBar,TIME_SECONDS),
                  TimeToString(TimeCurrent(),TIME_SECONDS));
      LastBar=ThisBar;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
bool TradeStop()
  {
   if(GlobalVariableGet(last_stop)==1.0)
     {
      if(GlobalVariableGet(pos_stop) *(Close[0]-media.Main(0))<=0)
        {
         GlobalVariableSet(last_stop,0.0);
         return true;
        }
      else
         return false;
     }
   else
      return true;
  }
//+------------------------------------------------------------------+
double PrecoMedio(ENUM_POSITION_TYPE ptype)
  {
   double vol=0;
   double preco=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && myposition.Symbol()==mysymbol.Name())
        {
         vol+=myposition.Volume();
         preco+=myposition.Volume()*myposition.PriceOpen();
        }
     }
   if(VolPosType(ptype)>0)
      preco=preco/VolPosType(ptype);
   preco=NormalizeDouble(MathRound(preco/ticksize)*ticksize,_digits);
   return preco;
  }
//+------------------------------------------------------------------+

int TotalGains()
  {
//--- request trade history
   datetime tm_end=TimeCurrent();
   datetime tm_start=iTime(original_symbol,PERIOD_D1,0);
   HistorySelect(tm_start,tm_end);
   total_deals=HistoryDealsTotal();
   ulong ticket=0;
   int profit=0;
   for(int i=0; i<total_deals; i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY) && mydeal.Profit()>0)
            profit+=1;
     }
   return (profit);
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
   total_deals=HistoryDealsTotal();
   ulong ticket=0;
   int profit=0;
   for(int i=0; i<total_deals; i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_IN || mydeal.Entry()==DEAL_ENTRY_INOUT))
            profit+=1;
     }
   return (profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalEntradasSemana()
  {
//--- request trade history
   datetime tm_end=TimeCurrent();
   datetime tm_start=(datetime)WeekStartTime(TimeCurrent());
   HistorySelect(tm_start,tm_end);
   total_deals=HistoryDealsTotal();
   ulong ticket=0;
   int profit=0;
   for(int i=0; i<total_deals; i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_IN || mydeal.Entry()==DEAL_ENTRY_INOUT))
            profit+=1;
     }
   return (profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalGainsSemana()
  {
//--- request trade history
   datetime tm_end=TimeCurrent();
   datetime tm_start=(datetime)WeekStartTime(TimeCurrent());
   HistorySelect(tm_start,tm_end);
   total_deals=HistoryDealsTotal();
   ulong ticket=0;
   int profit=0;
   for(int i=0; i<total_deals; i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY) && mydeal.Profit()>0)
            profit+=1;
     }
   return (profit);
  }
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
   for(int i=0; i<total_deals; i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            if(mydeal.Profit()<0)
               profit+=mydeal.Profit();
     }
   return (profit);
  }
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
   for(int i=0; i<total_deals; i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            if(mydeal.Profit()>0)
               profit+=mydeal.Profit();
     }
   return (profit);
  }
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
   for(int i=0; i<total_deals; i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            profit+=mydeal.Profit();
     }
   return (profit);
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
   time_aux.hour= 0;
   time_aux.min = 0;
   time_aux.sec = 0;
   datetime tm_start=StructToTime(time_aux);
   HistorySelect(tm_start,tm_end);
   total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0; i<total_deals; i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            if(mydeal.Profit()<0)
               profit+=mydeal.Profit();
     }
   return (profit);
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
   time_aux.hour= 0;
   time_aux.min = 0;
   time_aux.sec = 0;
   datetime tm_start=StructToTime(time_aux);
   HistorySelect(tm_start,tm_end);
   total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0; i<total_deals; i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            if(mydeal.Profit()>0)
               profit+=mydeal.Profit();
     }
   return (profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool GetInvesting(string _pais,int _touros)
  {
//Tentative
   datetime hora_init_news,hora_fin_news,hora_news;
   bool timer_news;
   string str_time_new;
   string to_split=Investing::getDados(_pais,_touros); // Um string para dividir em substrings
   string sep= "#";                                        // Um separador como um caractere
   ushort u_sep;                                           // O código do caractere separador
   string result[];                                        // Um array para obter strings
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
      for(int i=0; i<k; i++)
        {
         //PrintFormat("result[%d]=\"%s\"",i,result[i]);
         str_time_new=StringSubstr(result[i],0,5);
         if(str_time_new!="Tentative")
           {
            hora_news=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+str_time_new);
            hora_init_news= hora_news-minutos_news * 60;
            hora_fin_news = hora_news+minutos_news * 60;
            // Print("Hora início pausa news: "+TimeToString(hora_init_news)+" Hora final pausa news: "+TimeToString(hora_fin_news));
            timer_news=(timer_news || TimeCurrent()>=hora_init_news) && TimeCurrent()<=hora_fin_news;
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
   string sep= "#";                                        // Um separador como um caractere
   ushort u_sep;                                           // O código do caractere separador
   string result[];                                        // Um array para obter strings
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
      for(int i=0; i<k; i++)
        {
         //PrintFormat("result[%d]=\"%s\"",i,result[i]);
         timer_news=timer_news+result[i]+"\n";
         str_time_new=StringSubstr(result[i],0,5);
         if(str_time_new!="Tentative")
           {
            hora_news=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+str_time_new);
            hora_init_news= hora_news-minutos_news * 60;
            hora_fin_news = hora_news+minutos_news * 60;
            timer_news = timer_news + "Hora início pausa news: " + TimeToString(hora_init_news) + " Hora final pausa news: " + TimeToString(hora_fin_news) + "\n";
            timer_news = timer_news + "-------------------------------------------------------------------" + "\n";
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
   time_aux.hour= 0;
   time_aux.min = 0;
   time_aux.sec = 0;
   datetime tm_start=StructToTime(time_aux);

   HistorySelect(tm_start,tm_end);
   total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0; i<total_deals; i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            profit+=mydeal.Profit();
     }
   return (profit);
  }
//+------------------------------------------------------------------+
bool HorasInvesting(string _pais,int _touros)
  {
//Tentative
   datetime hora_init_news,hora_fin_news,hora_news;
   string str_time_new;
   string to_split=Investing::getDados(_pais,_touros); // Um string para dividir em substrings
   string sep= "#";                                        // Um separador como um caractere
   ushort u_sep;                                           // O código do caractere separador
   string result[];                                        // Um array para obter strings
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
      for(int i=0; i<k; i++)
        {
         //PrintFormat("result[%d]=\"%s\"",i,result[i]);
         str_time_new=StringSubstr(result[i],0,5);
         if(str_time_new!="Tentative")
           {
            hora_news=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+str_time_new);
            hora_init_news= hora_news-minutos_news * 60;
            hora_fin_news = hora_news+minutos_news * 60;
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
      investing = false;
      for(int i = 0; i < ArraySize(Hora_fin); i++)
        {
         if(Hora_in[i]>0 && Hora_fin[i]>0)
            investing=investing || (TimeCurrent()>=Hora_in[i] && TimeCurrent()<=Hora_fin[i]);
        }
     }
   else
      investing=false;
   return investing;
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
   tmp+= Corrector;
   tmp =(tmp / 604800) * 604800;
   tmp-=Corrector;
   return (tmp);
  }
//+------------------------------------------------------------------+
