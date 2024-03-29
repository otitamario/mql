//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
#resource "\\Indicators\\gann_hi_lo_activator_ssl.ex5"
#resource "\\Indicators\\atrstops_v1.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
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
enum Tipo_Ordem
  {
   Limitada,
   Mercado
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Sinal_Entr
  {
   Medias,//Médias
   ATR_STOP,// ATR STOP
   HiLo,//HiLo
   RSI,//RSI
   Estocastico,//Estocástico
   Bollinger,//Bandas de Bollinger
   MACD,//MACD
   Heiken,// Heiken Ashi
   Aberturas //Aberturas
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Ind_Sinal
  {
   Nao,//Não Usar
   Filtro //Filtro
  };

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include<Trade\AccountInfo.mqh>
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
CiMA *media1;
CiMA *media2;
CiMA *media3;
CiMA *media4;
CiMA *media5;
CiRSI *rsi;
CiStochastic *stoch;
CiMACD *macd;
CiBands *banda;
CiADX *adx;
CiMA *media_adx;

CControlsDialog ExtDialog;
// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=20082018;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input string SEstrateg="############-------------Estratégia----------########";//Estratégia
input Tipo_Ordem ordem_entrada=Mercado;//Tipo de Ordem de Entrada
input Tipo_Ordem ordem_saida=Limitada;// Tipo de Ordem Gain
input int num_tick_entr=1;//Número de ticks favoráveis para Ordem de Entrada Limitada
input int nbars=3;//Número de Candles p/ Expirar Ordem de Entrada
input double Lot=3;//Lote Entrada
input double _Stop=100; //Stop Loss em Pontos
input double _TakeProfit=100; //Take Profit em Pontos
sinput string sprotec="############------Proteção de Posição------#################";//Proteção
input uint n_ticks_stop=8;//Número de ticks Além do Stop para fechar no Stop Loss
input uint n_ticks_take=8;//Número de ticks Além do Take para fechar no Take Profit

input string Partial_Closing="====< Realização Parcial >====";   //  Parcial
input bool UsePartial=false; // Usar Realização Parcial 
input int Lot_entry1=1;//Lotes Realização Parcial 1 (0 Não Usar)
input int pts_entry1=70;//Pontos Realização Parcial 1
input int Lot_entry2=1;//Lotes Realização Parcial 2 (0 Não Usar)
input int pts_entry2=100;//Pontos Realização Parcial 2
input int Lot_entry3=1;//Lotes Realização Parcial 3 (0 Não Usar)
input int pts_entry3=150;//Pontos Realização Parcial 3

input string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes no Dia
input string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:00";//Horario Inicial
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

input string STrailing="############---------------Trailing Stop----------########";//Trailing
input bool   Use_TraillingStop=true; //Usar Trailing 
input double TraillingStart=100;//Lucro Minimo Iniciar trailing stop
input double TraillingDistance=90;// Distanccia em Pontos do Stop Loss
input double TraillingStep=10;// Passo para atualizar Stop Loss
input bool UseSTOPHilo=true;//Usar Stop Movel no HiLo
input double DistSTOPHilo=20;//Distancia do stop movel Para HiLo
input bool UseSTOP_ATR=true;//Usar Stop Movel no STOP ATR
input double DistSTOP_ATR=20;//Distancia do stop movel Para STOP ATR
input bool StopCandle=true;//Usar Stop Máxima/Mínima do Candle Anterior
input double DistSTOPCandle=20;//Distancia para Candle Anterior
input string SSinais="############------------Sinal e Filtros de Entrada----------########";//Sinais
input Sinal_Entr sinal_entr=Medias;//Escolha o Sinal de Entrada
input Ind_Sinal UsarStratMedias=Filtro;//Usar Estratégia das Médias como Filtro
input Ind_Sinal UsarHilo=Nao;//Usar HiLo como Filtro
input Ind_Sinal UsarStopATR=Nao;//Usar StopATR como Filtro
input Ind_Sinal UsarStoch=Nao;//Usar Estocastico como Filtro
input Ind_Sinal UsarRsi=Nao;//Usar RSI como Filtro
input Ind_Sinal Usarbanda=Nao;//Usar Bandas de Bollinger como Filtro
input Ind_Sinal Usarmacd=Nao;//Usar MACD como Filtro
input Ind_Sinal UsarHeiken=Nao;//Usar Heiken como Filtro
input Ind_Sinal UsarAberturas=Nao;//Usar Aberturas como Filtro
input Ind_Sinal UsarADX=Nao;//Usar ADX como Filtro
input string SMedias="############-------------Medias----------########";//Médias
input bool UsarMedia1=true;//Usar Média 1
input int per_media1=5;//Periodo Media 1
input bool UsarMedia2=true;//Usar Média 2
input int per_media2=9;//Periodo Media 2
input bool UsarMedia3=true;//Usar Média 3
input int per_media3=15;//Periodo Media 3
input bool UsarMedia4=true;//Usar Média 4
input int per_media4=21;//Periodo Media 4
input bool UsarMedia5=true;//Usar Média 5
input int per_media5=42;//Periodo Media 5
input string Shilo="############-------------HiLo----------########";//HiLo
input Sentido operar=Compra_e_Venda;//Somente Compra ou Venda ou Compra e Venda
input int period_hilo=25;//Periodo Hilo
input ENUM_MA_METHOD InpMethod=MODE_SMMA;// Method Hilo
input string SStopATR="############-------------Stop ATR----------########";//Stop ATR
input uint   Length=10;           // Indicator period
input uint   ATRPeriod=5;         // Period of ATR
input double Kv=2.5;              // Volatility by ATR
input int    Shift=0;             // Horizontal shift of the indicator in bars
input string Srsi="############-------------RSI----------########";//RSI
input int period_rsi=14;//Periodo RSI
input double rsi_sob_vend=30;// Nivel Sobrevendido
input double rsi_sob_comp=70;//Nivel Sobrecomprado

input string Sstoch="############-------------Estocástico----------########";//Estocástico
input int InpKPeriod=10;  // Stochastic K period
input int InpDPeriod=3;  // Stochastic D period
input int InpSlowing=3;  // Stochastic Slowing
input double stoch_sob_vend=20;// Nivel Sobrevendido
input double stoch_sob_comp=80;//Nivel Sobrecomprado
input string Sbanda="############-------------Bandas de Bollinger----------########";//Bollinger
input int period_banda=20;//Periodo Banda de Bollinger
input double desvio_banda=2.0;//Desvio Banda de Bollinger
input string Smacd="############-------------MACD----------########";//MACD
input int                InpFastEMA=12;               // Fast EMA period
input int                InpSlowEMA=26;               // Slow EMA period
input int                InpSignalSMA=9;              // Signal SMA period
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE; // Applied price
input string Sadx="############-------------ADX----------########";//ADX
input int period_adx=14;//Periodo ADX
input int period_media_adx=14;//Periodo Média ADX
input double adx_min=20;// Nivel Mínimo ADX
input double adx_max=45;//Nivel Máximo ADX



                        //Variaveis 

string original_symbol;
double ask,bid;
double lucro_total,pontos_total,lucro_entry,lucro_total_mes,lucro_total_semana;
bool timerOn,tradeOn;
double ponto,ticksize,digits;
long curChartID;
int hilo_handle;
double hilo_color[],hilo_buffer[];
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
string tp_cp1_tick="tp_cp1"+Symbol()+IntegerToString(Magic_Number),tp_cp2_tick="tp_cp2"+Symbol()+IntegerToString(Magic_Number),tp_cp3_tick="tp_cp3"+Symbol()+IntegerToString(Magic_Number);
string tp_vd1_tick="tp_vd1"+Symbol()+IntegerToString(Magic_Number),tp_vd2_tick="tp_vd2"+Symbol()+IntegerToString(Magic_Number),tp_vd3_tick="tp_vd3"+Symbol()+IntegerToString(Magic_Number);
string gv_today="gv_today"+Symbol()+IntegerToString(Magic_Number),gv_today_prev="gv_today_prev"+Symbol()+IntegerToString(Magic_Number);

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
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   original_symbol=Symbol();
   if(SymbolInfoInteger(original_symbol,SYMBOL_EXPIRATION_MODE)==2)order_time_type=1;
   else order_time_type=0;

   tradeOn=true;
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

   if((UsarStratMedias!=Nao || sinal_entr==Medias) && UsarMedia1)
     {
      media1=new CiMA;
      media1.Create(Symbol(),periodoRobo,per_media1,0,MODE_EMA,PRICE_CLOSE);
      media1.AddToChart(curChartID,0);
     }

   if((UsarStratMedias!=Nao || sinal_entr==Medias) && UsarMedia2)
     {
      media2=new CiMA;
      media2.Create(Symbol(),periodoRobo,per_media2,0,MODE_EMA,PRICE_CLOSE);
      media2.AddToChart(curChartID,0);
     }

   if((UsarStratMedias!=Nao || sinal_entr==Medias) && UsarMedia3)
     {
      media3=new CiMA;
      media3.Create(Symbol(),periodoRobo,per_media3,0,MODE_EMA,PRICE_CLOSE);
      media3.AddToChart(curChartID,0);
     }
   if((UsarStratMedias!=Nao || sinal_entr==Medias) && UsarMedia4)
     {
      media4=new CiMA;
      media4.Create(Symbol(),periodoRobo,per_media4,0,MODE_EMA,PRICE_CLOSE);
      media4.AddToChart(curChartID,0);
     }
   if((UsarStratMedias!=Nao || sinal_entr==Medias) && UsarMedia5)
     {
      media5=new CiMA;
      media5.Create(Symbol(),periodoRobo,per_media5,0,MODE_EMA,PRICE_CLOSE);
      media5.AddToChart(curChartID,0);
     }

   if(UsarHilo!=Nao || sinal_entr==HiLo || UseSTOPHilo)
     {
      hilo_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\gann_hi_lo_activator_ssl.ex5",period_hilo,InpMethod);
      ChartIndicatorAdd(curChartID,0,hilo_handle);
      ArraySetAsSeries(hilo_color,true);
      ArraySetAsSeries(hilo_buffer,true);
     }

   if(UsarStopATR!=Nao || sinal_entr==ATR_STOP || UseSTOP_ATR)
     {
      atr_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\atrstops_v1.ex5",Length,ATRPeriod,Kv,Shift);
      ChartIndicatorAdd(ChartID(),0,atr_handle);
      ArraySetAsSeries(ATR_High,true);
      ArraySetAsSeries(ATR_Low,true);
     }
   if(UsarStoch!=Nao || sinal_entr==Estocastico)
     {
      stoch=new CiStochastic;
      stoch.Create(original_symbol,periodoRobo,InpKPeriod,InpDPeriod,InpSlowing,MODE_SMA,STO_LOWHIGH);
      stoch.AddToChart(curChartID,ChartGetInteger(curChartID,CHART_WINDOWS_TOTAL));
     }

   if(UsarRsi!=Nao || sinal_entr==RSI)
     {
      rsi=new CiRSI;
      rsi.Create(Symbol(),periodoRobo,period_rsi,PRICE_CLOSE);
      rsi.AddToChart(curChartID,ChartGetInteger(curChartID,CHART_WINDOWS_TOTAL));
     }
   if(Usarbanda!=Nao || sinal_entr==Bollinger)
     {
      banda=new CiBands;
      banda.Create(Symbol(),periodoRobo,period_banda,0,desvio_banda,PRICE_CLOSE);
      banda.AddToChart(curChartID,0);
     }
   if(Usarmacd!=Nao || sinal_entr==MACD)
     {
      macd=new CiMACD;
      macd.Create(NULL,periodoRobo,InpFastEMA,InpSlowEMA,InpSignalSMA,InpAppliedPrice);
      macd.AddToChart(curChartID,ChartGetInteger(curChartID,CHART_WINDOWS_TOTAL));
     }
   if(UsarHeiken!=Nao || sinal_entr==Heiken)
     {
      heiken_handle=iCustom(Symbol(),periodoRobo,"Examples\\Heiken_Ashi");
      ChartIndicatorAdd(ChartID(),0,heiken_handle);
      ArraySetAsSeries(Heiken_Color,true);
     }

   if(UsarADX!=Nao)
     {
      adx=new CiADX;
      adx.Create(Symbol(),periodoRobo,period_adx);
      ulong adx_chart=ChartGetInteger(curChartID,CHART_WINDOWS_TOTAL);
      adx.AddToChart(curChartID,adx_chart);
      media_adx=new CiMA;
      media_adx.Create(Symbol(),periodoRobo,period_media_adx,0,MODE_EMA,adx.Handle());
      media_adx.AddToChart(curChartID,adx_chart);
     }

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

   if((UsarMedia1 && !UsarMedia2) || (!UsarMedia1 && !UsarMedia2) || (!UsarMedia1 && UsarMedia2))
     {
      string erro="Você deve usar pelo menos duas médias para o Cruzamento";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if((UsarMedia2 && per_media2<=per_media1) || (UsarMedia3 && per_media3<=per_media2) || (UsarMedia4 && per_media4<=per_media3) || (UsarMedia5 && per_media5<=per_media4))
     {
      string erro="Os períodos das Médias devem estar em ordem Crescente";
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
   if(!GlobalVariableCheck(tp_cp1_tick))GlobalVariableSet(tp_cp1_tick,0.0);
   if(!GlobalVariableCheck(tp_cp2_tick))GlobalVariableSet(tp_cp2_tick,0.0);
   if(!GlobalVariableCheck(tp_cp3_tick))GlobalVariableSet(tp_cp3_tick,0.0);
   if(!GlobalVariableCheck(tp_vd1_tick))GlobalVariableSet(tp_vd1_tick,0.0);
   if(!GlobalVariableCheck(tp_vd2_tick))GlobalVariableSet(tp_vd2_tick,0.0);
   if(!GlobalVariableCheck(tp_vd3_tick))GlobalVariableSet(tp_vd3_tick,0.0);

   if(UsePartial && (pts_entry1>pts_entry2 || pts_entry1>pts_entry3 || pts_entry2>pts_entry3))
     {
      string erro="A distancia das saidas parciais devem estar ordenadas ";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(UsePartial && Lot_entry1+Lot_entry2+Lot_entry3>=Lot)
     {
      string erro="A soma dos Lotes das Parciais deve ser menor que o Lote de Entrada";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

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
   if((UsarStratMedias!=Nao||sinal_entr==Medias) && UsarMedia1)delete(media1);
   if((UsarStratMedias!=Nao||sinal_entr==Medias) && UsarMedia2)delete(media2);
   if((UsarStratMedias!=Nao||sinal_entr==Medias) && UsarMedia3)delete(media3);
   if((UsarStratMedias!=Nao||sinal_entr==Medias)&& UsarMedia4)delete(media4);
   if((UsarStratMedias!=Nao||sinal_entr==Medias) && UsarMedia5)delete(media5);
   if(UsarRsi!=Nao ||sinal_entr==RSI)delete(rsi);
   if(Usarbanda!=Nao||sinal_entr==Bollinger)delete(banda);
   if(UsarStoch!=Nao||sinal_entr==Estocastico)delete(stoch);
   if(Usarmacd!=Nao||sinal_entr==MACD)delete(macd);
   if(UsarHilo!=Nao ||sinal_entr==HiLo|| UseSTOPHilo)IndicatorRelease(hilo_handle);
   if(UsarStopATR!=Nao || sinal_entr==ATR_STOP || UseSTOP_ATR)IndicatorRelease(atr_handle);
   if(UsarHeiken!=Nao || sinal_entr==Heiken)IndicatorRelease(heiken_handle);
   if(UsarADX!=Nao)
     {
      delete(adx);
      delete(media_adx);
     }

   DeletaIndicadores();
   ExtDialog.Destroy(reason);

   if(reason!=5)
     {
      GlobalVariableSet(glob_entr_tot,0.0);
      GlobalVariableSet(tp_vd1_tick,0);
      GlobalVariableSet(tp_vd2_tick,0);
      GlobalVariableSet(tp_vd3_tick,0);
      GlobalVariableSet(tp_cp1_tick,0);
      GlobalVariableSet(tp_cp2_tick,0);
      GlobalVariableSet(tp_cp3_tick,0);
     }

//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(myorder.Select((ulong)GlobalVariableGet(cp_tick)))mytrade.OrderDelete((ulong)GlobalVariableGet(cp_tick));
   if(myorder.Select((ulong)GlobalVariableGet(vd_tick)))mytrade.OrderDelete((ulong)GlobalVariableGet(vd_tick));
   EventKillTimer();
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
   ProtectPosition();
   mysymbol.Refresh();
   mysymbol.RefreshRates();
   ExtDialog.OnTick();
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   TimeToStruct(TimeCurrent(),TimeNow);
   GlobalVariableSet(gv_today,(double)TimeNow.day_of_year);

   if((UsarStratMedias!=Nao||sinal_entr==Medias) && UsarMedia1)media1.Refresh();
   if((UsarStratMedias!=Nao||sinal_entr==Medias)&& UsarMedia2)media2.Refresh();
   if((UsarStratMedias!=Nao||sinal_entr==Medias)&& UsarMedia3)media3.Refresh();
   if((UsarStratMedias!=Nao||sinal_entr==Medias) && UsarMedia4)media4.Refresh();
   if((UsarStratMedias!=Nao||sinal_entr==Medias) && UsarMedia5)media5.Refresh();
   if(UsarRsi!=Nao || sinal_entr==RSI)rsi.Refresh();
   if(Usarbanda!=Nao||sinal_entr==Bollinger)banda.Refresh();
   if(UsarStoch!=Nao||sinal_entr==Estocastico)stoch.Refresh();
   if(Usarmacd!=Nao || sinal_entr==MACD)macd.Refresh();
   if(UsarADX!=Nao)
     {
      adx.Refresh();
      media_adx.Refresh();
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

   bool novodia;
   novodia=NewBar.CheckNewBar(original_symbol,PERIOD_D1);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(novodia || GlobalVariableGet(gv_today)!=GlobalVariableGet(gv_today_prev))
     {
      GlobalVariableSet(glob_entr_tot,0.0);
      tradeOn=true;

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
      Print("EA encerrado lucro ou prejuizo");

     }

   timerOn=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

   if(!PosicaoAberta() && OrdersTotal()>0)
     {
      DeleteOrdersComment("TAKE PROFIT");
      DeleteOrdersComment("Saida Parcial 1");
      DeleteOrdersComment("Saida Parcial 2");
      DeleteOrdersComment("Saida Parcial 3");

     }
   if(Buy_opened() && Sell_opened())CloseByPosition();

   if(!Buy_opened())
     {
      if(myorder.Select((int)GlobalVariableGet(tp_vd1_tick))) mytrade.OrderDelete((int)GlobalVariableGet(tp_vd1_tick));
      if(myorder.Select((int)GlobalVariableGet(tp_vd2_tick))) mytrade.OrderDelete(GlobalVariableGet(tp_vd2_tick));
      if(myorder.Select((int)GlobalVariableGet(tp_vd3_tick))) mytrade.OrderDelete(GlobalVariableGet(tp_vd3_tick));

      GlobalVariableSet(tp_vd1_tick,0);
      GlobalVariableSet(tp_vd2_tick,0);
      GlobalVariableSet(tp_vd3_tick,0);

     }
   if(!Sell_opened())
     {
      if(myorder.Select((int)GlobalVariableGet(tp_cp1_tick))) mytrade.OrderDelete((int)GlobalVariableGet(tp_cp1_tick));
      if(myorder.Select((int)GlobalVariableGet(tp_cp2_tick))) mytrade.OrderDelete(GlobalVariableGet(tp_cp2_tick));
      if(myorder.Select((int)GlobalVariableGet(tp_cp3_tick))) mytrade.OrderDelete(GlobalVariableGet(tp_cp3_tick));

      GlobalVariableSet(tp_cp1_tick,0);
      GlobalVariableSet(tp_cp2_tick,0);
      GlobalVariableSet(tp_cp3_tick,0);
     }

   if(tradeOn && timerOn)

     {// inicio Trade On

      if(NewBar.CheckNewBar(Symbol(),periodoRobo))
        {

         if(PosicaoAberta())
           {
            if(UseSTOPHilo)Trailing_HiLo();
            if(UseSTOP_ATR)Trailing_ATR();
            if(StopCandle)Trailing_Candle();
           }

         if(BuySignal() && !Buy_opened())
           {
            if(Sell_opened())ClosePosType(POSITION_TYPE_SELL);
            if(ordem_saida==Mercado) take_price=NormalizeDouble(ask+_TakeProfit*ponto,digits);
            else take_price=0;
            if(UsePartial && Lot>mysymbol.LotsMin()) take_price=0;
            if(ordem_entrada==Mercado)
              {
               if(mytrade.Buy(Lot,original_symbol,0,NormalizeDouble(bid-_Stop*ponto,digits),take_price,"BUY"+exp_name))
                 {
                  GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Erro enviar ordem ",GetLastError());
              }
            else
              {

               if(mytrade.BuyLimit(Lot,NormalizeDouble(ask-num_tick_entr*ticksize,digits),original_symbol,NormalizeDouble(ask-num_tick_entr*ticksize-_Stop*ponto,digits),take_price,order_time_type,0,"BUY"+exp_name))
                 {
                  GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
                  EventSetTimer(nbars*PeriodSeconds());
                 }
               else Print("Erro enviar ordem ",GetLastError());
              }
           }

         if(SellSignal() && !Sell_opened())
           {
            if(Buy_opened())ClosePosType(POSITION_TYPE_BUY);
            if(ordem_saida==Mercado)take_price=NormalizeDouble(bid-_TakeProfit*ponto,digits);
            else take_price=0;
            if(UsePartial && Lot>mysymbol.LotsMin()) take_price=0;
            if(ordem_entrada==Mercado)
              {
               if(mytrade.Sell(Lot,original_symbol,0,NormalizeDouble(ask+_Stop*ponto,digits),take_price,"SELL"+exp_name))
                 {
                  GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Erro enviar ordem ",GetLastError());
              }
            else
              {

               if(mytrade.SellLimit(Lot,NormalizeDouble(bid+num_tick_entr*ticksize,digits),original_symbol,NormalizeDouble(bid+num_tick_entr*ticksize+_Stop*ponto,digits),take_price,order_time_type,0,"SELL"+exp_name))
                 {
                  GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
                  EventSetTimer(nbars*PeriodSeconds());
                 }
               else Print("Erro enviar ordem ",GetLastError());
              }
           }

        }//End NewBar

      MytradeTransaction();

      if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);

     }//End Trade On
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

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
            if(deal_magic==Magic_Number)cont_deals+=1;
           }
        }
     }
   GlobalVariableSet(deals_total_prev,(double)cont_deals);

   TimeToStruct(TimeCurrent(),TimeNow);
   GlobalVariableSet(gv_today_prev,(double)TimeNow.day_of_year);

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
   if(sinal_entr==Medias)signal=Strategy_Med_Buy();
   if(sinal_entr==ATR_STOP)signal=ATR_High[2]==EMPTY_VALUE&&ATR_High[1]!=EMPTY_VALUE;
   if(sinal_entr==HiLo && operar!=Venda)signal=hilo_color[2]!=0.0&&hilo_color[1]==0.0;
   if(sinal_entr==RSI)signal=rsi.Main(2)<=rsi_sob_vend&&rsi.Main(1)>rsi_sob_vend;
   if(sinal_entr==Estocastico)signal=stoch.Main(2)<stoch.Signal(2)&&stoch.Main(1)>stoch.Signal(1)&&stoch.Main(2)<stoch_sob_vend;
   if(sinal_entr==MACD)signal=macd.Main(2)<macd.Signal(2) && macd.Main(1)>macd.Signal(1);
   if(sinal_entr==Bollinger)signal=close[2]<=banda.Lower(2) && close[1]>banda.Lower(1);
   if(sinal_entr==Heiken)signal=Heiken_Color[1]==0.0&&Heiken_Color[2]!=0.0;
   if(sinal_entr==Aberturas)signal=open[0]>open[1];

   signal=signal && Filtro_Buy();
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
   if(sinal_entr==Medias)signal=Strategy_Med_Sell();
   if(sinal_entr==ATR_STOP)signal=ATR_Low[2]==EMPTY_VALUE&&ATR_Low[1]!=EMPTY_VALUE;
   if(sinal_entr==HiLo && operar!=Compra)signal=hilo_color[2]!=1.0&&hilo_color[1]==1.0;
   if(sinal_entr==RSI)signal=rsi.Main(2)>=rsi_sob_comp&&rsi.Main(1)<rsi_sob_comp;
   if(sinal_entr==Estocastico)signal=stoch.Main(2)>stoch.Signal(2)&&stoch.Main(1)<stoch.Signal(1)&&stoch.Main(2)>stoch_sob_comp;
   if(sinal_entr==MACD)signal=macd.Main(2)<macd.Signal(2) && macd.Main(1)>macd.Signal(1);
   if(sinal_entr==Bollinger)signal=close[2]>=banda.Upper(2) && close[1]<banda.Upper(1);
   if(sinal_entr==Heiken)signal=Heiken_Color[1]==1.0&&Heiken_Color[2]!=1.0;
   if(sinal_entr==Aberturas)signal=open[0]<open[1];

   signal=signal && Filtro_Sell();
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool Filtro_Buy()
  {
   bool signal=true;
   if(UsarStratMedias==Filtro)signal=signal && Medias_Up(1);
   if(UsarStopATR==Filtro)signal=signal && ATR_High[1]!=EMPTY_VALUE;
   if(UsarHilo==Filtro)signal=signal && hilo_color[1]==0.0;
   if(UsarRsi==Filtro)signal=signal && rsi.Main(1)<rsi_sob_comp;
   if(UsarStoch==Filtro)signal=signal && stoch.Main(1)>stoch.Signal(1) && stoch.Main(1)<stoch_sob_comp;
   if(Usarmacd==Filtro)signal=signal && macd.Main(1)>macd.Signal(1);
   if(Usarbanda==Filtro)signal=signal && close[1]<=banda.Upper(1) && close[1]>=banda.Lower(1);
   if(UsarHeiken==Filtro)signal=signal && Heiken_Color[1]==0.0;
   if(UsarAberturas==Filtro)signal=signal && open[0]>open[1];
   if(UsarADX==Filtro)signal=signal && media_adx.Main(0)>adx_min && media_adx.Main(0)<adx_max;

   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool Filtro_Sell()
  {
   bool signal=true;
   if(UsarStratMedias==Filtro)signal=signal && Medias_Down(1);
   if(UsarStopATR==Filtro)signal=signal && ATR_Low[1]!=EMPTY_VALUE;
   if(UsarHilo==Filtro)signal=signal && hilo_color[1]==1.0;
   if(UsarRsi==Filtro)signal=signal && rsi.Main(1)>rsi_sob_vend;
   if(UsarStoch==Filtro)signal=signal && stoch.Main(1)<stoch.Signal(1) && stoch.Main(1)>stoch_sob_vend;
   if(Usarmacd==Filtro)signal=signal && macd.Main(1)<macd.Signal(1);
   if(Usarbanda==Filtro)signal=signal && close[1]<=banda.Upper(1) && close[1]>=banda.Lower(1);
   if(UsarHeiken==Filtro)signal=signal && Heiken_Color[1]==1.0;
   if(UsarAberturas==Filtro)signal=signal && open[0]<open[1];
   if(UsarADX==Filtro)signal=signal && media_adx.Main(0)>adx_min && media_adx.Main(0)<adx_max;

   return signal;
  }
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

   if(UsarHilo || UseSTOPHilo || sinal_entr==HiLo)
     {
      b_get=b_get || CopyBuffer(hilo_handle,0,0,5,hilo_buffer)<=0 || 
            CopyBuffer(hilo_handle,1,0,5,hilo_color)<=0;
     }
   if(UsarStopATR || UseSTOP_ATR || sinal_entr==ATR_STOP)
     {
      b_get=b_get || CopyBuffer(atr_handle,0,0,5,ATR_High)<=0 || 
            CopyBuffer(atr_handle,1,0,5,ATR_Low)<=0;
     }
   if(UsarHeiken || sinal_entr==Heiken)
     {
      b_get=b_get || CopyBuffer(heiken_handle,4,0,5,Heiken_Color)<=0;
     }
   return(b_get);
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
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
// Trailing stop (points)
void TrailingStop(double pTrailPoints,double pMinProfit=0,double pStep=10)
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
            currentStop=myposition.StopLoss();
            trailStopPrice = bid - trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=bid-openPrice;

            if(trailStopPrice>currentStop+step && currentProfit>=minProfit)
              {
               mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);

              }

           }
         else if(posType==POSITION_TYPE_SELL)
           {
            currentStop=myposition.StopLoss();
            trailStopPrice = ask + trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=openPrice-ask;

            if((trailStopPrice<currentStop-step || currentStop==0) && currentProfit>=minProfit)
              {
               mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);

              }

           }
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void MytradeTransaction()
  {
   ulong order_ticket;
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
            if(deal_magic==Magic_Number)cont_deals+=1;
           }
        }

      GlobalVariableSet(deals_total,(double)cont_deals);

      if(GlobalVariableGet(deals_total)>GlobalVariableGet(deals_total_prev))
        {
         for(uint i=total_deals-1;i>=0;i--)
           {
            if(HistoryDealGetTicket(i)>0)
              {
               ulong deals_ticket=HistoryDealGetTicket(i);
               mydeal.Ticket(deals_ticket);
               order_ticket=mydeal.Order();
               if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number)
                 {

                  if((order_ticket==(ulong)GlobalVariableGet(cp_tick) || order_ticket==(ulong)GlobalVariableGet(vd_tick)))
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
                     if(UsePartial)Saida_Parcial_Sell(buyprice);
                     if(UsePartial)lotes_take=Lot-Lot_entry1-Lot_entry2-Lot_entry3;
                     else lotes_take=Lot;

                     if(ordem_saida==Mercado)take_price=NormalizeDouble(buyprice+_TakeProfit*ponto,digits);
                     else take_price=0;
                     mytrade.PositionModify(order_ticket,NormalizeDouble(buyprice-_Stop*ponto,digits),take_price);
                     if(ordem_saida==Limitada)
                       {
                        if(mytrade.SellLimit(lotes_take,NormalizeDouble(buyprice+_TakeProfit*ponto,digits),original_symbol,0,0,order_time_type,0,"TAKE PROFIT"))
                          {
                           GlobalVariableSet(tp_vd_tick,(double)mytrade.ResultOrder());
                          }
                        else Print("Erro enviar ordem ",GetLastError());

                       }

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

                     if(UsePartial)Saida_Parcial_Buy(sellprice);
                     if(UsePartial)lotes_take=Lot-Lot_entry1-Lot_entry2-Lot_entry3;
                     else lotes_take=Lot;

                     if(ordem_saida==Mercado)take_price=NormalizeDouble(sellprice-_TakeProfit*ponto,digits);
                     else take_price=0;
                     mytrade.PositionModify(order_ticket,NormalizeDouble(sellprice+_Stop*ponto,digits),take_price);
                     if(ordem_saida==Limitada)
                       {
                        if(mytrade.BuyLimit(lotes_take,NormalizeDouble(sellprice-_TakeProfit*ponto,digits),original_symbol,0,0,order_time_type,0,"TAKE PROFIT"))
                          {
                           GlobalVariableSet(tp_cp_tick,(double)mytrade.ResultOrder());
                          }
                        else Print("Erro enviar ordem ",GetLastError());

                       }

                    }

                  return;
                 }//Fim mydeal symbol
              }// if histoticket>0
           }//Fim for total_deals
        }//Fim deals>prev
     }//Fim HistorySelect
  }
//+------------------------------------------------------------------+
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
         double openPrice= MathRound(myposition.PriceOpen()/ticksize)*ticksize;
         double currentTP=myposition.TakeProfit();
         double breakEvenStop;
         double currentProfit;
         double ponto=SymbolInfoDouble(pSymbol,SYMBOL_POINT);
         double bid,ask;

         if(posType==POSITION_TYPE_BUY)
           {
            //           myorder.Select(stp_venda_ticket);
            //  currentSL=myorder.PriceOpen();
            currentSL=myposition.StopLoss();
            bid=SymbolInfoDouble(pSymbol,SYMBOL_BID);
            currentProfit=bid-openPrice;
            //Break Even 0 a 3
            for(int k=0;k<4;k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop=openPrice+pLockProfit[k]*ponto;
                  breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
                  if(currentSL<breakEvenStop || currentSL==0)
                    {
                     if(mytrade.PositionModify(posTicket,breakEvenStop,currentTP))Print("Break even stop bem sucedido");
                     else Print("Falha modificar Breakeven: ",GetLastError());

                    }
                 }
              }
            //----------------------
            //Break Even 4
            if(currentProfit>=pBreakEven[4]*ponto)
              {
               breakEvenStop=openPrice+pLockProfit[4]*ponto;
               breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
               if(currentSL<breakEvenStop || currentSL==0)
                 {
                  if(mytrade.PositionModify(posTicket,breakEvenStop,currentTP))Print("Break even stop bem sucedido");
                  else Print("Falha modificar Breakeven: ",GetLastError());

                 }
              }
           }
         //----------------------

         //----------------------

         if(posType==POSITION_TYPE_SELL)
           {
            //  myorder.Select(stp_compra_ticket);
            // currentSL=myorder.PriceOpen();
            currentSL=myposition.StopLoss();
            ask=SymbolInfoDouble(pSymbol,SYMBOL_ASK);
            currentProfit=openPrice-ask;
            //Break Even 0 a 3
            for(int k=0;k<4;k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop=openPrice-pLockProfit[k]*ponto;
                  breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
                  if(currentSL>breakEvenStop || currentSL==0)
                    {
                     if(mytrade.PositionModify(posTicket,breakEvenStop,currentTP))Print("Break even stop bem sucedido");
                     else Print("Falha modificar Breakeven: ",GetLastError());

                    }
                 }
              }
            //----------------------
            //Break Even 4
            if(currentProfit>=pBreakEven[4]*ponto)
              {
               breakEvenStop=openPrice-pLockProfit[4]*ponto;
               breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
               if(currentSL>breakEvenStop || currentSL==0)
                 {
                  if(mytrade.PositionModify(posTicket,breakEvenStop,currentTP))Print("Break even stop bem sucedido");
                  else Print("Falha modificar Breakeven: ",GetLastError());

                 }

              }
            //----------------------

           }

        } //Fim Position Select

     }//Fim for
  }
//+------------------------------------------------------------------+
bool Medias_Up(const int idx)
  {
   bool signal=false;
   if(UsarStratMedias)
     {
      signal=true;
      if(UsarMedia2)signal=signal&&media2.Main(idx)<media1.Main(idx);
      if(UsarMedia3)signal=signal&&media3.Main(idx)<media2.Main(idx);
      if(UsarMedia4)signal=signal&&media4.Main(idx)<media3.Main(idx);
      if(UsarMedia5)signal=signal&&media5.Main(idx)<media4.Main(idx);
     }
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Medias_Down(const int idx)
  {
   bool signal=false;
   if(UsarStratMedias)
     {
      signal=true;
      if(UsarMedia2)signal=signal&&media2.Main(idx)>media1.Main(idx);
      if(UsarMedia3)signal=signal&&media3.Main(idx)>media2.Main(idx);
      if(UsarMedia4)signal=signal&&media4.Main(idx)>media3.Main(idx);
      if(UsarMedia5)signal=signal&&media5.Main(idx)>media4.Main(idx);
     }
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Strategy_Med_Buy()
  {
   return Medias_Up(1)&&!Medias_Up(2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Strategy_Med_Sell()
  {
   return Medias_Down(1)&&!Medias_Down(2);
  }
//+------------------------------------------------------------------+

void Trailing_Candle()
  {

   double stop_movel=DistSTOPCandle*ponto;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
        {
         if(myposition.PositionType()==POSITION_TYPE_BUY)
           {
            double curSTP=myposition.StopLoss();
            double curTake=myposition.TakeProfit();
            double stp_compra=NormalizeDouble(low[1]-stop_movel,digits);
            if(stp_compra>curSTP)mytrade.PositionModify(myposition.Ticket(),stp_compra,curTake);
           }

         if(myposition.PositionType()==POSITION_TYPE_SELL)
           {
            double curSTP=myposition.StopLoss();
            double curTake=myposition.TakeProfit();
            double stp_venda=NormalizeDouble(high[1]+stop_movel,digits);
            if(stp_venda<curSTP)mytrade.PositionModify(myposition.Ticket(),stp_venda,curTake);
           }
        }//Fim if PositionSelect

     }//Fim for

  }      //Fim Stop Candle      
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trailing_HiLo()
  {
   if(UsarHilo)
     {
      double stop_movel=DistSTOPHilo*ponto;
      double stop_med=NormalizeDouble(MathRound(hilo_buffer[1]/ticksize)*ticksize,digits);

      for(int i=PositionsTotal()-1;i>=0; i--)
        {
         if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
           {
            if(myposition.PositionType()==POSITION_TYPE_BUY && bid>hilo_buffer[1])
              {
               double curSTP=myposition.StopLoss();
               double curTake=myposition.TakeProfit();
               double stp_compra=stop_med-stop_movel;
               stp_compra=NormalizeDouble(MathRound(stp_compra/ticksize)*ticksize,digits);
               if(stp_compra>curSTP)mytrade.PositionModify(myposition.Ticket(),stp_compra,curTake);

              }

            if(myposition.PositionType()==POSITION_TYPE_SELL && ask<hilo_buffer[1])
              {
               double curSTP=myposition.StopLoss();
               double curTake=myposition.TakeProfit();
               double stp_venda=stop_med+stop_movel;
               stp_venda=NormalizeDouble(MathRound(stp_venda/ticksize)*ticksize,digits);
               if(stp_venda<curSTP)mytrade.PositionModify(myposition.Ticket(),stp_venda,curTake);
              }
           }//Fim if PositionSelect

        }//Fim for
     }
  }  //Fim STOP HiLo
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Trailing_ATR()
  {
   if(UsarStopATR)
     {
      double stop_movel=DistSTOP_ATR*ponto;
      double stop_med;

      for(int i=PositionsTotal()-1;i>=0; i--)
        {
         if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
           {
            if(myposition.PositionType()==POSITION_TYPE_BUY && bid>ATR_High[1])
              {
               double curSTP=myposition.StopLoss();
               double curTake=myposition.TakeProfit();
               stop_med=NormalizeDouble(MathRound(ATR_High[1]/ticksize)*ticksize,digits);
               double stp_compra=stop_med-stop_movel;
               stp_compra=NormalizeDouble(MathRound(stp_compra/ticksize)*ticksize,digits);
               if(stp_compra>curSTP)mytrade.PositionModify(myposition.Ticket(),stp_compra,curTake);

              }

            if(myposition.PositionType()==POSITION_TYPE_SELL && ask<ATR_Low[1] && ATR_Low[1]!=EMPTY_VALUE)
              {
               double curSTP=myposition.StopLoss();
               double curTake=myposition.TakeProfit();
               stop_med=NormalizeDouble(MathRound(ATR_Low[1]/ticksize)*ticksize,digits);
               double stp_venda=stop_med+stop_movel;
               stp_venda=NormalizeDouble(MathRound(stp_venda/ticksize)*ticksize,digits);
               if(stp_venda<curSTP)mytrade.PositionModify(myposition.Ticket(),stp_venda,curTake);
              }
           }//Fim if PositionSelect

        }//Fim for
     }
  }  //Fim STOP HiLo
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
void Saida_Parcial_Buy(const double preco)
  {
   if(Lot_entry1>0) mytrade.BuyLimit(Lot_entry1,NormalizeDouble(preco-pts_entry1*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Parcial 1");
   if(Lot_entry2>0) mytrade.BuyLimit(Lot_entry2,NormalizeDouble(preco-pts_entry2*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Parcial 2");
   if(Lot_entry3>0) mytrade.BuyLimit(Lot_entry3,NormalizeDouble(preco-pts_entry3*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Parcial 3");
  }
//+------------------------------------------------------------------+
void Saida_Parcial_Sell(const double preco)
  {
   if(Lot_entry1>0) mytrade.SellLimit(Lot_entry1,NormalizeDouble(preco+pts_entry1*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Parcial 1");
   if(Lot_entry2>0) mytrade.SellLimit(Lot_entry2,NormalizeDouble(preco+pts_entry2*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Parcial 2");
   if(Lot_entry3>0) mytrade.SellLimit(Lot_entry3,NormalizeDouble(preco+pts_entry3*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Parcial 3");
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
