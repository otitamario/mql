//+------------------------------------------------------------------+
//|                                                       Params.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#resource "\\Indicators\\autotrendlines.ex5"
#resource "\\Indicators\\Coyoteindex.ex5"
#resource "\\Indicators\\bw-wiseman-1.ex5"
#resource "\\Indicators\\CAPZACK v1.2.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

enum ENUM_LINE_TYPE
  {
   EXM_EXM,    // 1: By 2 extremums
   EXM_DELTA   // 2: Extremum and delta
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum LT
  {
   _5M,//LT 5 minutos
   _15M,           //LT 15 minutos
   _30M,           //LT 30 minutos
   _1HORA            //LT 1 Hora
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum VolStrat
  {
   AbaixoMed,//Abaixo da Média
   AcimaMed//Acima da Média
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Strategy
  {
   StatBW,//Bw-Wiseman
   StatCAP,//CAPZACK
   StatCoyote,//Coyote
   StatMedCross//Média Cross
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum PRICE_TYPE
  {
   OPEN,
   CLOSE,
   HIGH,
   LOW,
   OPEN_CLOSE,
   HIGH_LOW,
   CLOSE_HIGH_LOW,
   OPEN_CLOSE_HIGH_LOW
  };

#include <EAMessias\Expert_Class_Viper.mqh>


sinput string senha="";//Cole a senha
sinput string nome_setup="";//Nome do Setup
input Strategy Estrategia=StatBW;//Selecione a Estratégia
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input int MAGIC_NUMBER=20082018;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
sinput string SComum="############---------Comum--------########";//Comum
input double Lot=1;//Lote Entrada
input double _Stop=300;//Stop Loss em Pontos
input double _TakeProfit=300;//Take Profit em Pontos
input uint n_minutes=10;//Minutos de pausa após fechar um trade - 0 Não Usar
input bool RevertPos=false;//Reverter Posições no Sinal Contrário
input bool UsarTrendLines=true;//Usar Filtro Linhas de Tendência
sinput string svol="###----Volume----#####";    //Volume
input bool UsarVol=false;//Usar Filtro Volume
input ENUM_APPLIED_VOLUME InpVolType=VOLUME_REAL;//Tipo do Volume
input int per_med_vol=21;//Período Média do Volume
input VolStrat HowUseVol=AbaixoMed;//Volume Acima/Abaixo Média
input bool UsarMediaIncl=false;//Usar Filtro Média Inclinação
input int period_media_inc=9;//Período da Média Filtro Inclinação
input ENUM_MA_METHOD modo_media_inc=MODE_EMA;//Modo Média Inclinação
input bool UsarVWap=false;//Usar Filtro VWAP
input bool InvertVWAp=false;//Inverter VWAP
PRICE_TYPE  Price_Type          = CLOSE;
bool        Calc_Every_Tick     = false;
bool        Enable_Daily        = true;
bool        Show_Daily_Value    = true;
bool        Enable_Weekly       = false;
bool        Show_Weekly_Value   = false;
bool        Enable_Monthly      = false;
bool        Show_Monthly_Value  = false;
input bool UsarHiLoFiltro=false;
input int period_hilo_slow=21;//Periodo Hilo Lento
input ENUM_MA_METHOD InpMethod_slow=MODE_SMMA;// Method Hilo Lento
sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia
input string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:04";//Horario Inicial
input string end_hour="17:20";//Horario Final
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
sinput string sdias="FILTRO DOS DIAS DA SEMANA";//Dias da Semana
input bool trade0=true;// Operar Domingo
input bool trade1=true;// Operar Segunda
input bool trade2=true;// Operar Terça
input bool trade3=true;// Operar Quarta
input bool trade4=true;// Operar Quinta
input bool trade5=true;// Operar Sexta
input bool trade6=true;// Operar Sábado

sinput string SEstbw="----Estratégia Bw-Wiseman-----";//Estratégia Bw-Wiseman
input uint                    _back=2;                       // Number of bars for analysis
input uint                    _jaw_period=13;                // Period for calculating jaws
input uint                    _jaw_shift=8;                  // Horizontal shift of jaws
input uint                    _teeth_period=8;               // Teeth calculation period
input uint                    _teeth_shift=5;                // Horizontal shift of teeth
input uint                    _lips_period=5;                // Period for calculating lips
input uint                    _lips_shift=3;                 // Horizontal shift of lips
input ENUM_MA_METHOD          _ma_method=MODE_SMMA;          // Smoothing type
input ENUM_APPLIED_PRICE      _applied_price=PRICE_MEDIAN;   // Price type or handle

sinput string SEstCAP="----Estratégia CAPZACK-----";//Estratégia CAPZACK
input int center_period=100;//Centered TMA hal period
input int average_period=100;//Average true range period
input double average_mult=2.4;//Average true range multiplier
input int center_angle=4;//Centered TMA angle
sinput string SEstCoyote="----Estratégia Coyote-----";//Estratégia Coyote
input    double Pontos_coyote=10; //Variação minima entre extremos dos candles anteriores
input    bool     ModoAgressivo=true; //Modo Agressivo
input    bool     UsarCandleAtual=false; //Usar Candle Atual?
input    double Percentual=50;//% de retração (Modo Agressivo = false)
input    bool     ExibirRaio=false; //Exibir Raio?

sinput string SEstMedCross="----Estratégia Cruzamento Preço Média-----";//Estratégia Cruzamento Preço Média
input int period_media_cross=21;//Período da Média 
input ENUM_MA_METHOD modo_media_cross=MODE_EMA;//Modo Média 
input ENUM_APPLIED_PRICE app_media_cross=PRICE_CLOSE;//Preço Média 

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


sinput string srealp="############----Realização Parcial------#################";//Realização Parcial
input double rp1=0;//Pontos R.P 1 (0 Não Usar)
input double _lts_rp1=25;//Porcentagem Lotes R.P 1
input double rp2=0;//Pontos R.P 2 (0 Não Usar)
input double _lts_rp2=25;//Porcentagem Lotes R.P 2
input double rp3=0;//Pontos R.P 3 (0 Não Usar)
input double _lts_rp3=0;//Porcentagem Lotes R.P 3

sinput string SAumento="############----Aumento de Posição Contra----########";//Aumento Contra
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

sinput string SAumentofavor="############----Aumento de Posição A Favor----########";//Aumento Favor
input double pts_saida_aumento_fv=150;//Pontos de Saída Dos Aumentos(0 não sair)
input double Lot_entry1_fv=0;//Lotes Entrada 1 (0 não entrar)
input double pts_entry1_fv=0;//Pontos Entrada 1
input double Lot_entry2_fv=0;//Lotes Entrada 2 (0 não entrar)
input double pts_entry2_fv=0;//Pontos Entrada 2 
input double Lot_entry3_fv=0;//Lotes Entrada 3 (0 não entrar)
input double pts_entry3_fv=0;//Pontos Entrada 3
input double Lot_entry4_fv=0;//Lotes Entrada 4 (0 não entrar)
input double pts_entry4_fv=0;//Pontos Entrada 4



ENUM_LINE_TYPE InpLineType = EXM_DELTA;// Line type
int            InpLeftExmSide = 10;    // Left extremum side (Type 1, 2)
int            InpRightExmSide = 3;    // Right extremum side (Type 1)
int            InpFromCurrent = 3;     // Offset from the current barà (Type 2)
bool           InpPrevExmBar = false;  // Account for the bar before the extremum (Type 2)
//---
int            InpLinesWidth = 2;      // lines width
color          InpSupColor = clrRed;   // Support line color
color          InpResColor = clrBlue;  // Resistance line color
