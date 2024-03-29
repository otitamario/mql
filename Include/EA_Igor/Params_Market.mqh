//+------------------------------------------------------------------+
//|                                                       Params.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#resource "\\Indicators\\STPMT.ex5"
#resource "\\Indicators\\Force.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#import "Investing.dll"

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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_INPUT_YES_NO
  {
   INPUT_YES   =  1, // Yes
   INPUT_NO    =  0  // No
  };
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

#include <EA_Igor\Expert_Class_Igor.mqh>


// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
                                                 //input string simbolo="WING19";//Digitar Símbolo Original
input ulong MAGIC_NUMBER=20082018;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input string SComum="############-----------------------------Comum---------------------------########";//Comum
input string simbolo="";//Digitar Simbolo Original (Vazio Símbolo Atual)
input double Lot=1;//Lote Entrada
input double _Stop=300;//Stop Loss em Pontos
input double _TakeProfit=300;//Take Profit em Pontos
input bool ReverterMark=false;//ReverterMark no Sinal Contrário
input int n_minutesMark=0;//Número de Minutos de Pausa em Consolidação
input bool inverter=false;//trocar Onde vende compra e onde compra vende
input Sentido operar=Compra_e_Venda; //Tipo de Entradas
input uint time_order=240;//Tempo em Segundos para Entrada mudar TakeProfit
input uint time_order_sem=480;//Tempo em Segundos Sem Entrada. Mudar TakeProfit
input uint time_order_zero=30;//Tempo em Minutos Mover Stop para 0 a 0
input double porc_take=40;//Porcentagem para mudar TakeProfit
                          // Operar Comprado, Vendido
sinput string sporclim="############------Porcentagem Limite------#################";//Porcentagem Limite
input double porc_lim=2.36;//Porcentagem Limite para Entrada
input string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia
sinput string strailprof="###------------------------Trailing Profit---------------------#####";    //Trailing Profit
input bool UsarTrailingProfit=false;//Usar Trailing Profit
input double TrailProfitMin1=20;//Lucro Mínimo em Moeda para Iniciar Trailing Profit
input double TrailPerc1=90;//Porcentagem Retração do Lucro para Fechar Posição
input double TrailStep=10;//Atualização em Moeda do Trailinng

sinput string sinvest="############------Notícias Investig.com------#################";//Notícias
input bool UsarNew=true;//Usar filtro de Notícias
input Moeda Inp_pais=USD;//País das Notícias
input Touros Inp_touros=Touro_3;//Touros
input uint minutos_news=15;//Tempo em Minutos para pausar o EA antes e depois da notícia

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

input uint              InpPeriodK1       =  5;             // Stochastic 1 %K period
input uint              InpPeriodD1       =  3;             // Stochastic 1 %D period
input uint              InpSlowing1       =  3;             // Stochastic 1 Slowing
input ENUM_MA_METHOD    InpMethod1        =  MODE_SMA;      // Stochastic 1 Method
input ENUM_STO_PRICE    InpPriceField1    =  STO_LOWHIGH;   // Stochastic 1 Price field
input double            InpWeight1        =  4.1;           // Stochastic 1 Weight

input uint              InpPeriodK2       =  14;            // Stochastic 2 %K period
input uint              InpPeriodD2       =  3;             // Stochastic 2 %D period
input uint              InpSlowing2       =  3;             // Stochastic 2 Slowing
input ENUM_MA_METHOD    InpMethod2        =  MODE_SMA;      // Stochastic 2 Method
input ENUM_STO_PRICE    InpPriceField2    =  STO_LOWHIGH;   // Stochastic 2 Price field
input double            InpWeight2        =  2.5;           // Stochastic 2 Weight

input uint              InpPeriodK3       =  45;            // Stochastic 3 %K period
input uint              InpPeriodD3       =  14;            // Stochastic 3 %D period
input uint              InpSlowing3       =  3;             // Stochastic 3 Slowing
input ENUM_MA_METHOD    InpMethod3        =  MODE_SMA;      // Stochastic 3 Method
input ENUM_STO_PRICE    InpPriceField3    =  STO_LOWHIGH;   // Stochastic 3 Price field
input double            InpWeight3        =  1.0;           // Stochastic 3 Weight

input uint              InpPeriodK4       =  75;            // Stochastic 4 %K period
input uint              InpPeriodD4       =  20;            // Stochastic 4 %D period
input uint              InpSlowing4       =  3;             // Stochastic 4 Slowing
input ENUM_MA_METHOD    InpMethod4        =  MODE_SMA;      // Stochastic 4 Method
input ENUM_STO_PRICE    InpPriceField4    =  STO_LOWHIGH;   // Stochastic 4 Price field
input double            InpWeight4        =  4.0;           // Stochastic 4 Weight

input uint              InpPeriodSig      =  9;             // Signal line period
input ENUM_INPUT_YES_NO InpShowComponents =  INPUT_YES;     // Show components

                                                            //sinput string SindForce="############--------Force----------########";//Force
ENUM_APPLIED_VOLUME vol_force=VOLUME_REAL;//Volume Type
int zzticks=15;//Zig Zag Ticks

               //sinput string SEst_Med="############-------------Indicadores----------########";
int                  _tenkan_sen=9;              // período Tenkan-sen 
int                  _kijun_sen=26;              // período Kijun-sen 
int                  _senkou_span_b=52;          // período Senkou Span B 


sinput string SGap="############----------------------------------------------------Filtro de Gap---------------------------------------------############"; //Gap
input OpcaoGap UsarGap=Operacoes_Normais; // Usar Gap                                                                                                             //Opção de Gap
input double pts_gap=10;//Pontos de Gap para Filtro                                                                                                                                     //Gap em Pontos para Filtrar Entradas

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
