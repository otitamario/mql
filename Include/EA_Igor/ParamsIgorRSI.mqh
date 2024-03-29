//+------------------------------------------------------------------+
//|                                                       Params.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#resource "\\Indicators\\gann_hi_lo_activator_ssl.ex5"
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
enum ENUM_BOOLEANO
  {
   BOOL_NO,//Não
   BOOL_YES//Sim
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Strategy
  {
   EstHiLo,//HiLo 
   EstRSI,//RSI
   EstLandry//Landry
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum EnAdxFilt
  {
   FiltAdMaior,//Maior que
   FiltAdMenor//Menor que
  };

enum TpLandry
  {
   TPLRisco,//Risco
   TPLPontos//Pontos
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <EA_Igor\Expert_Class_Igor.mqh>
input string SComum="############-----------------------------Comum---------------------------########";//Comum
input string setup_name="NOME DO SETUP";//Nome do Setup
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong MAGIC_NUMBER=321;//Número Mágico
ulong deviation_points=500;//Deviation em Pontos(Padrao)
input string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";    //Lucro
input bool UsarLucro=true;//Usar Lucro para Fechamento Diário True/False
input double prejuizo_ent=126.0;//Perda Máxima: Parar Entradas (R$)
input double prejuizo=176.0;//Perda Máxima: Fechar Posicoes (R$)
input double lucro_ent=163.0;//Objetivo: Parar Entradas (R$)
input double lucro=185.0;//Objetivo: Fechar Posicoes (R$)
input bool UsarLucroGlobal=true;//Usar Lucro Global para Fechamento Diário True/False
input string numeros_magicos="321,111,222";//Números Mágicos separados por vírgula
input double prejuizo_global=500.0;//Perda Máxima Global: Fechar Posicoes (R$)
input double lucro_global=500.0;//Objetivo Global: Fechar Posicoes (R$)

sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:05";//Horario Inicial
input string end_hour_ent="10:50";//Horario Final Entradas
input string end_hour="17:30";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario
sinput string sPausa1="--";//Pausa 1
input bool UsePause1=false;//Usar Pausa 1
input string start_hour1="8:30";//Initial Pause Hour 1
input string end_hour1="10:30";//Final Pause Hour 1
input bool FecharPause1=false;//Fechar Posições Pausa 1
sinput string sPausa2="--";//Pausa 2
input bool UsePause2=false;//Usar Pausa 2
input string start_hour2="18:00";//Initial Pause Hour 2
input string end_hour2="20:30";//Final Pause Hour 2
input bool FecharPause2=false;//Fechar Posições Pausa 2


sinput string sdias="FILTRO DOS DIAS DA SEMANA";//Dias da Semana
input bool trade0=true;// Operar Domingo
input bool trade1=true;// Operar Segunda
input bool trade2=true;// Operar Terça
input bool trade3=true;// Operar Quarta
input bool trade4=true;// Operar Quinta
input bool trade5=true;// Operar Sexta
input bool trade6=true;// Operar Sábado

sinput string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia 
input OpcoesDistancia opt_dist=DistBarra;//Unidade de Medida
input double Lot=2;//Volume Entrada
input double _Stop=4.5;//Stop Loss 
input double _TakeProfit=5;//Take Profit
input Strategy Estrategia=EstRSI;//Selecione a Estratégia
input ENUM_BOOLEANO FiltroRSI=BOOL_NO;//Filtro RSI
input ENUM_BOOLEANO FiltroADX=BOOL_NO;//Filtro ADX
input ENUM_BOOLEANO FiltroHiLo=BOOL_NO;//Filtro HiLo
input EnAdxFilt filt_adx=FiltAdMaior;//Filtro ADX
input double adxmin=20;//ADX Maior que 
input double adxmax=35;//ADX Menor que 
input bool ReverterSig=false;//Reverter no Sinal Contrário
input Sentido operar=Compra_e_Venda; //Tipo de Entradas                                                                                                                       // Operar Comprado, Vendido
sinput string SFiltBB="############-----------Filtro BB Estratégia RSI---------------############"; //Filtro BB Estratégia RSI
input ENUM_BOOLEANO UsarFilroBB=BOOL_NO;//Usar FIltro BB
input int per_bb=20;//Período Banda
input double desvio_bb=2.0;//Desvio Banda
input ushort xbarras=0;//Número de Barras Sinal RSI                                                                                                                                     //Gap em Pontos para Filtrar Entradas
sinput string SEstrategIandr="############---------------Estratégia Landry-------------########";//Estratégia Landry 
input int per_med=9;//Período Médio
input ENUM_MA_METHOD modo_media=MODE_EMA;//Modo Média
input double barra_lim=1000;//Tamanho Máximo da Barra Entrada
input ushort barras_cancel=0;//Barras Cancelar Ordem ( 0 Não Cancelar)
input TpLandry tpLandry=TPLPontos;// Tipo Take Profit Landry
sinput string SGap="############----------------------Filtro de Gap-------------------------############"; //Gap
input bool UsarGap=false;//Usar GAP
input double pts_gap=1000;//Pontos de Gap para Filtro                                                                                                                                     //Gap em Pontos para Filtrar Entradas

sinput string sind="--------------Indicadores-------------------";//Indicadores
sinput string SIndHiLo="-------------HiLo-----------------";//HiLo
input uint           InpPeriod=13;       // Period
input ENUM_MA_METHOD InpMethod=MODE_SMMA;// Method
sinput string stadx="--------------ADX---------------";//ADX
input int per_adx=13;//Período ADX
sinput string SIndRSI="-------------------RSI--------------";//RSI
input int per_rsi=13;//Período RSI
input ENUM_APPLIED_PRICE price_rsi=PRICE_OPEN;//Aplicar à
input double rsi_max=62;//RSI Sobrecomprado
input double rsi_min=36;//RSI Sobrevendido


sinput string STrailing="--------------Trailing Stop-------------";//Trailing Stop
input bool   Use_TraillingStop=true; //Usar Trailing 
double TraillingStart=0;//Lucro Minimo Iniciar trailing stop
input double TraillingDistance=1.8;// Distancia do Stop Loss
input double TraillingStep=0;// Passo para atualizar Stop Loss

sinput string sbreak="--------------BreakEven-----------------";//BreakEven
input    bool              UseBreakEven=false;                          //Usar BreakEven
sinput string sdesc_break="Ganho BE >Distância BE; Distância BE=0=Não Usar";//Dicas BE
input    double               BreakEvenPoint1=100;                            //Distância para BreakEven 1
input    double               ProfitPoint1=10;                             //Ganho 1
input    double               BreakEvenPoint2=150;                            //Distância para BreakEven 2
input    double               ProfitPoint2=80;                            //Ganho 2
input    double               BreakEvenPoint3=200;                            //Distância para BreakEven 3
input    double               ProfitPoint3=130;                            //Ganho 3
input    double               BreakEvenPoint4=300;                            //Distância para BreakEven 4
input    double               ProfitPoint4=230;                            //Ganho 4
input    double               BreakEvenPoint5         =500;                            //Distância para BreakEven 5
input    double               ProfitPoint5            =400;                            //Ganho 5


sinput string srealp="############------------------------Realização Parcial-------------------------------#################";//Realização Parcial
input double rp1=1;//Pontos R.P 1 (0 Não Usar)
input double _lts_rp1=50;//Porcentagem Lotes R.P 1
input double rp2=1;//Pontos R.P 2 (0 Não Usar)
input double _lts_rp2=50;//Porcentagem Lotes R.P 2
input double rp3=0;//Pontos R.P 3 (0 Não Usar)
input double _lts_rp3=0;//Porcentagem Lotes R.P 3

sinput string SAumento="############---------------Entrada Parcial----------########";//Entrada Parcial
input double Lot_entry1=1;//Lotes Entrada 1 (0 não entrar)
input double pts_entry1=1.9;//Pontos Entrada 1
input double Lot_entry2=1;//Lotes Entrada 2 (0 não entrar)
input double pts_entry2=4.0;//Pontos Entrada 2 
input double Lot_entry3=0;//Lotes Entrada 3 (0 não entrar)
input double pts_entry3=0;//Pontos Entrada 3
input double Lot_entry4=0;//Lotes Entrada 4 (0 não entrar)
input double pts_entry4=0;//Pontos Entrada 4
input double Lot_entry5=0;//Lotes Entrada 5 (0 não entrar)
input double pts_entry5=0;//Pontos Entrada 5
input double Lot_entry6=0;//Lotes Entrada 6 (0 não entrar)
input double pts_entry6=0;//Pontos Entrada 6
