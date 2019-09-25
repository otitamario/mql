//+------------------------------------------------------------------+
//|                                                       Params.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#resource "\\Indicators\\gann_hi_lo_activator_ssl.ex5"

bool TimeEnt;
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
   EstRSI//RSI
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum EnAdxFilt
  {
   FiltAdMaior,//Maior que
   FiltAdMenor//Menor que
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <EA_Igor\Expert_Class_Igor.mqh>
input string SComum="############-----------------------------Comum---------------------------########";//Comum
input string setup_name="NOME DO SETUP";//Nome do Setup
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
                                                 //input string simbolo="WING19";//Digitar Símbolo Original
input bool FecharPainel=false;//Fechar Painel                                                 
input ulong MAGIC_NUMBER=20082018;//Número Mágico
ulong deviation_points=500;//Deviation em Pontos(Padrao)
input string simbolo="";//Digitar Simbolo Original (Vazio Símbolo Atual)
input string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia
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

sinput string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia 
input OpcoesDistancia opt_dist=DistBarra;//Unidade de Medida
input double Lot=1;//Volume Entrada
input double _Stop=300;//Stop Loss 
input double _TakeProfit=300;//Take Profit
input Strategy Estrategia=EstRSI;//Selecione a Estratégia
input ENUM_BOOLEANO FiltroRSI=BOOL_NO;//Filtro RSI
input ENUM_BOOLEANO FiltroHiLo=BOOL_NO;//Filtro ADX
input ENUM_BOOLEANO FiltroADX=BOOL_NO;//Filtro HiLo
input EnAdxFilt filt_adx=FiltAdMaior;//Filtro ADX
input double adxmin=20;//ADX Maior que 
input double adxmax=35;//ADX Menor que 

input bool ReverterSig=false;//Reverter no Sinal Contrário
input Sentido operar=Compra_e_Venda; //Tipo de Entradas                                                                                                                       // Operar Comprado, Vendido



sinput string sind="----------Indicadores-----------------------";//Indicadores
sinput string SIndHiLo="---HiLo---";//HiLo
input uint           InpPeriod=13;       // Period
input ENUM_MA_METHOD InpMethod=MODE_SMMA;// Method
sinput string stadx="###-----------------------Filtro ADX-------------------#####";//Filtro ADX
input int per_adx=14;//Período ADX
sinput string SIndRSI="---RSI---";//RSI
input int per_rsi=14;//Período RSI
input double rsi_min=20;//RSI Sobrevendido
input double rsi_max=80;//RSI Sobrecomprado


sinput string STrailing="############---------------Trailing Stop----------########";//Trailing
input bool   Use_TraillingStop=false; //Usar Trailing 
input double TraillingStart=0;//Lucro Minimo Iniciar trailing stop
input double TraillingDistance=200;// Distancia em Pontos do Stop Loss
input double TraillingStep=10;// Passo para atualizar Stop Loss

sinput string sbreak="########---------Break Even---------------###############";//BreakEven
input    bool              UseBreakEven=false;                          //Usar BreakEven
sinput string sdesc_break="";//Ganho BE >Distância BE; Distância BE=0=Não Usar
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
input double rp1=0;//Pontos R.P 1 (0 Não Usar)
input double _lts_rp1=25;//Porcentagem Lotes R.P 1
input double rp2=0;//Pontos R.P 2 (0 Não Usar)
input double _lts_rp2=25;//Porcentagem Lotes R.P 2
input double rp3=0;//Pontos R.P 3 (0 Não Usar)
input double _lts_rp3=0;//Porcentagem Lotes R.P 3

sinput string SAumento="############---------------Entrada Parcial----------########";//Entrada Parcial
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
