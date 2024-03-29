//+------------------------------------------------------------------+
//|                                                       Params.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#resource "\\Indicators\\Indic_Afastamento_Media_MATS.ex5"
#resource "\\Indicators\\Indicador BOLA.ex5"
#resource "\\Indicators\\wpr_histogram.ex5"
#resource "\\Indicators\\stochastic_histogram.ex5"
#resource "\\Indicators\\afast_media_dx.ex5"
#resource "\\Indicators\\didi_index_sign.ex5"
#resource "\\Indicators\\Custom Moving Average Input Color.ex5"
#resource "\\Indicators\\atrstops_v1.ex5"
#resource "\\Indicators\\PTL.ex5"
#resource "\\Indicators\\RSO.ex5"
#resource "\\Indicators\\linearregression.ex5"
#resource "\\Indicators\\Prince NY.ex5"
#resource "\\Indicators\\FiboIndicator.ex5"
#resource "\\Indicators\\fp-channel-indicator.ex5"
#resource "\\Indicators\\bw-zonetrade-indicator.ex5"
#resource "\\Indicators\\gann_hi_lo_activator_ssl.ex5"

bool TimeEnt;
bool AdxAllow;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

enum EntBoll
  {
   EntBTick,//Cada tick Contra
   EntBTickFav,//Cada Tick Favor
   EntBFFFD,//Fechou Fora Fechou Dentro
   EntBFav//Entrada a Favor
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Strategy
  {
   Afast,//Afastamento da Média
   ATRStp,//ATR Stop
   BolaWprSt,//Bola+Wpr+Stoch
   Didi,//Didi Index
   PTLRSO,//PLT+RSO
   Regress,//Regressão Linear
   TresMed,//Três Médias
   HiLoPrNY,//HiLo - Príncipe de NY
   FPCHANN,//Fp Channel
   BollingEst//Bollinger
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
enum ENUM_WIDTH // type of constant
  {
   w_1 = 1,   // 1
   w_2,       // 2
   w_3,       // 3
   w_4,       // 4
   w_5        // 5
  };

#include <EA_Igor\Expert_Class_Igor.mqh>

input string setup_name="NOME DO SETUP";//Nome do Setup
                                        // gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
                                                 //input string simbolo="WING19";//Digitar Símbolo Original
input bool FecharPainel=false;//Fechar Painel                                                 
input ulong MAGIC_NUMBER=20082018;//Número Mágico
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input string SComum="############-----------------------------Comum---------------------------########";//Comum
input string simbolo="";//Digitar Simbolo Original (Vazio Símbolo Atual)
input double Lot=1;//Lote Entrada
input double _Stop=300;//Stop Loss em Pontos
input double _TakeProfit=300;//Take Profit em Pontos
input Strategy Estrategia=BolaWprSt;//Selecione a Estratégia
input string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia
sinput string strailprof="###------------------------Trailing Profit---------------------#####";    //Trailing Profit
input bool UsarTrailingProfit=false;//Usar Trailing Profit

input double TrailProfitMin1=20;//Lucro Mínimo em Moeda para Iniciar Trailing Profit
input double TrailPerc1=90;//Porcentagem Retração do Lucro para Fechar Posição
input double TrailStep=10;//Atualização em Moeda do Trailinng

sinput string stadx="###-----------------------Filtro ADX-------------------#####";//Filtro ADX
input bool UsarADX=false;//Usar Filtro ADX
input bool PlotADX=false;//Plotar ADX
input int per_adx=14;//Período ADX
input double adxmin=20;//Valor Mínimo Tendência
input double adx_lim=15;//Valor Limite Contra-Tendëncia


sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:04";//Horario Inicial
input string end_hour_ent="17:00";//Horario Final Entradas
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

sinput string SEstrateg="############-----------------------------Estratégia Bola+WPR+STO---------------------------########";//Estratégia Bola+WPR+STO
input bool ReverterSig=false;//Reverter no Sinal Contrário
input bool Inverter=false;//Inverter Sinal
input bool UsarSoBola=false;//Usar Somente o Indicador Bola
input int n_minutes=0;//Número de Minutos de Pausa em Consolidação

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




sinput string SEst_Med="############---------------------------------------Afastamento da Média------------------------------------------------########";   //Afastamento da Média
input bool ReverterSigAfast=false;//Reverter no Sinal Contrário
input int period_media=7; //Período Média                                                                                                                                  //Periodo da Media
input ENUM_MA_METHOD modo_media=MODE_EMA;  //Modo Média                                                                                                                //Modo da Média
input ENUM_APPLIED_PRICE app_media=PRICE_CLOSE; //Aplicar a                                                                                                            //Aplicar a
input double dist_media=2.0;  //Distância da Média para Entradas                                                                                                                              //Distância da Média em Pontos
input Operacao operacao=Favor; //Sentido da Operação                                                                                                                             //Operar a Favor ou Contra a Tendência
input Sentido operar=Compra_e_Venda; //Tipo de Entradas                                                                                                                       // Operar Comprado, Vendido
input bool cada_tick=true; //Operar a Cada tick                                                                                                                                 //Operar a cada tick
input uint n_minutes_pausa=10;//Minutos de pausa após fechar um trade
input bool FecharMedia=false;//Fechar Posições ao Toque na Média

sinput string SsaidSec="############-------------------------------------------Saída Média Secundária----------------------------------------############";  //Média Secundária
input int period_med_sec=5;   //Período Média Secundária                                                                                                                               //Período Média Secundária
input ENUM_MA_METHOD mode_sec=MODE_EMA; //Modo Média                                                                                                                    //Modo Média Secundária
input ENUM_APPLIED_PRICE app_sec=PRICE_CLOSE;   //Aplicar a
input bool FecharMediaSec=false;//Fechar na Média Secundária                                                                                                         
input ulong saida_sec=4;  //A partir de qual Aumento Fechar na Média Secundária                                                                                                                                   //Aum de Pos p acionar Fech Média Sec/ 0 Não Sair na Secundária
sinput string SGap="############----------------------------------------------------Filtro de Gap---------------------------------------------############"; //Gap
input OpcaoGap UsarGap=Operar_Apos_Toque_Media; // Usar Gap                                                                                                             //Opção de Gap
input double pts_gap=10;//Pontos de Gap para Filtro                                                                                                                                     //Gap em Pontos para Filtrar Entradas

sinput string SEsthilPrinc="############----------------------------------------------------Estratégia HiLo - Príncipe de NY---------------------------------------------############"; //Estratégia HiLo - Príncipe de NY
input bool ReverterSigHiLPr=false;//Reverter no Sinal Contrário
input int n_minutesHiLPr=0;//Número de Minutos de Pausa em Consolidação
input int period_hilo=14;//Período HiLo
input ENUM_MA_METHOD InpMethod=MODE_SMMA;// Method Hilo
input int per_principe=30;//Período Príncipe NY
input int barras_conf=5;//Barras para Sinal do Princípe NY e Virada de HiLo
sinput string SEstfpchan="############----------------------------------------------------Estratégia Fp Channel---------------------------------------------############"; //Estratégia Fp Channel
input bool ReverterSigFP=false;//Reverter no Sinal Contrário
input int n_minutesFP=0;//Número de Minutos de Pausa em Consolidação
input int period_fp=100;//Período FP Channel
input int shift_fp=0;//Shift FP

sinput string SEstDidi="############----------------------------------------------------Estratégia Didi Index---------------------------------------------############"; //Estratégia Didi Index
input bool ReverterSigDidi=false;//Reverter no Sinal Contrário
input bool InverterDidi=false;//Inverter Sinal
input int n_minutesDidi=0;//Número de Minutos de Pausa em Consolidação

input uint      Curta=17;
input uint      Longa=48;
input ENUM_MA_METHOD DidiMA_Method=MODE_SMA; // Ìåòîä óñðåäíåíèÿ èíäèêàòîðà
input ENUM_APPLIED_PRICE DidiMA_Price=PRICE_CLOSE;// Öåíîâàÿ êîíñòàíòà

sinput string SEst3Med="############----------------------------------------------------Estratégia 3 Médias---------------------------------------------############"; //Estratégia 3 Médias
input bool ReverterSigMed=false;//Reverter no Sinal Contrário
input int n_minutesMed=0;//Número de Minutos de Pausa em Consolidação

input int period_mfast=3;               // Período Média Rápida
input ENUM_MA_METHOD modo_mfast=MODE_EMA;               // Modo Média Rápida

input int period_minter=30;               // Período Média Intermediária
input ENUM_MA_METHOD modo_minter=MODE_EMA;               // Modo Média Intermediária
input int period_mslow=60;               // Período Média Lenta
input ENUM_MA_METHOD modo_mslow=MODE_EMA;               // Modo Média Lenta

sinput string SEstAtr="############----------------------------------------------------Estratégia ATR Stop---------------------------------------------############"; //Estratégia ATR Stop
input bool ReverterSigATR=false;//Reverter no Sinal Contrário
input int n_minutesATR=0;//Número de Minutos de Pausa em Consolidação

input uint   Length=10;           // Indicator period
input uint   ATRPeriod=5;         // Period of ATR
input double Kv=2.5;              // Volatility by ATR
input int    ShiftATR=0;             // Horizontal shift of the indicator in bars

sinput string SEstPTLRSO="############----------------------------------------------------Estratégia PTL+RSO---------------------------------------------############"; //Estratégia PTL+RSO
input bool ReverterSigPTL=false;//Reverter no Sinal Contrário
input int n_minutesPTL=0;//Número de Minutos de Pausa em Consolidação

input int inpFastLength = 3; // Fast length PTL
input int inpSlowLength = 7; // Slow length PTL
input int InpPeriodRSO=14;        // RSO Period


sinput string SEstLinReg="############----------------------------------------------------Estratégia Regressão Linear---------------------------------------------############"; //Estratégia Regressão Linear
input bool ReverterSigLR=false;//Reverter no Sinal Contrário
input int n_minutesLR=0;//Número de Minutos de Pausa em Consolidação

//+------------------------------------------------+
//| Indicator input parameters                     |
//+------------------------------------------------+
string lines_sirname="Linear_Regression_"; // Graphic objects group name
input int LR_length=34;                          // Indicator calculation period
bool Deletelevel=true;                     // Level deletion

input color LR_c=Blue;                           // Middle line color
ENUM_LINE_STYLE LR_style=STYLE_SOLID;      // Middle line style
ENUM_WIDTH LR_width=w_3;                   // Middle line width

double std_channel_1=0.618;                // Minimum regression
color c_1=Gold;                            // Minimum line color
ENUM_LINE_STYLE style_1=STYLE_DASH;        // Minimum line style
ENUM_WIDTH width_1=w_1;                    // Minimum line width

double std_channel_2=1.618;                // Nominal regression
color c_2=Lime;                            // Nominal line color
ENUM_LINE_STYLE style_2=STYLE_DOT;         // Nominal line style
ENUM_WIDTH width_2=w_1;                    // Nominal line width

double std_channel_3=2.618;                // Maximum regression
input color c_3=Magenta;                         // Maximum line color
ENUM_LINE_STYLE style_3=STYLE_SOLID;       // Maximum line style
ENUM_WIDTH width_3=w_3;                    // Maximum line width
//+----------------------------------------------+
sinput string SEstBoll="############----------------------------------------------------Estratégia Bollinger---------------------------------------------############"; //Estratégia Bollinger
input EntBoll entr_Boll=EntBFFFD;//Sinal de Entrada
input bool ReverterBoll=false;//Reverter no Sinal Contrário
input int n_minutesBoll=0;//Número de Minutos de Pausa em Consolidação
input int per_boll=20;//Período Bollinger
input double desv_boll=2.0;//Desvio Bollinger

/*
sinput string SEstMFI = "############----------------------------------------------------Estratégia MFI---------------------------------------------############"; //Estratégia MFI

input uint                 MFIPeriod=14;           // ïåðèîä èíäèêàòîðà
input ENUM_APPLIED_VOLUME MFIVolumeType=VOLUME_TICK;  // îáú¸ì 
input uint                 MFIHighLevel=70;           // óðîâåíü ïåðåêóïëåííîñòè
input uint                 MFILowLevel=30;            // óðîâåíü ïåðåïðîäàííîñòè
input int                  MFIShift=0;                // Ñäâèã èíäèêàòîðà ïî ãîðèçîíòàëè â áàðàõ
*/

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
