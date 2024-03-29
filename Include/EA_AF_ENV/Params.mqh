//+------------------------------------------------------------------+
//|                                                       Params.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#resource "\\Indicators\\Custom Moving Average Input Color.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Resposta
  {
   _SIM,//SIM
   _NAO//NAO
  }
;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <EA_AF_ENV\Expert_Class_AF_ENV.mqh>


// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
ulong deviation_points=50;//Deviation em Pontos(Padrao)
sinput string shorario="HORARIO DAS OPERACOES";//****************************
input uchar start_hour=9;//INICIO (HORA) 
input uchar start_min=4;//INICIO (MINUTOS)
input uchar end_hour=17;//TERMINO (HORA)
input uchar end_min=20;//TERMINO (MINUTOS)
input Resposta daytrade=_SIM;//ENCERRAR OPERACOES APOS TERMINO

sinput string sindicators="PARAMETROS DOS INDICADORES";//****************************
input int period_media=10;//  MÉDIA MÓVEL EXPONENCIAL (PERÍODO)
input ENUM_APPLIED_VOLUME tipo_vol=VOLUME_REAL;//VOLUME APLICADO

sinput string sparsent1="PARAMETROS DA ENTRADA 1";//****************************
input double retenv1=100;//RETORNO AO ENVELOPE  (PONTOS)
input ulong volmin1=500;//VOLUME MINIMO PARA ABRIR POSICAO
input ulong volmax1=2000;//VOLUME MAXIMO PARA ABIR POSICAO
input double _TakeProfit1=300;//GAIN (PONTOS)
input double _Stop1=300;//LOSS (PONTOS)
input double Lot1Par=0;//QUANTIDADE CONTRATOS PARCIAL
input double _TakeParcial1=100;//GAIN(PONTOS)
input double Lot1=1;//Lotes Abrir Posição
input double dist1=100;//Distância da Média Abrir Posição (PONTOS)
sinput string SAumento="Aumento de Posição";//****************************
input double Lot_entry1=0;//Lotes Incremento 1 (0 não entrar)
input double pts_entry1=0;//Distância da Média Incremento 1
input double Lot_entry2=0;//Lotes Incremento 2 (0 não entrar)
input double pts_entry2=0;//Distância da Média Incremento 2 
input double Lot_entry3=0;//Lotes Incremento 3 (0 não entrar)
input double pts_entry3=0;//Distância da Média Incremento 3
input double Lot_entry4=0;//Lotes Incremento 4 (0 não entrar)
input double pts_entry4=0;//Distância da Média Incremento 4
input double Lot_entry5=0;//Lotes Incremento 5 (0 não entrar)
input double pts_entry5=0;//Distância da Média Incremento 5
input double Lot_entry6=0;//Lotes Incremento 6 (0 não entrar)
input double pts_entry6=0;//Distância da Média Incremento 6



sinput string sbreak="BREAK EVEN";//****************************

input Resposta UsarBreakEven=_NAO;//USAR BREAK EVEN
input double pts_break=100;//ACIONA BREAK EVEN (PONTOS)

sinput string sriscos="PARAMETROS DE RISCO";//****************************
input double lucro=1000.0;//GANHO MAXIMO DIA (ENCERRA POSICOES)R$
input double prejuizo=500.0;//PERDA MAXIMO DIA (ENCERRA POSICOES)R$

input uchar nmax_stops=0;//STOPS MAXIMO DIA (QUANTIDADE)-"0" OPERAR NORMALMENTE 
input ushort ping_max=0; //LATENCIA MAXIMA - "0" OPERAR NORMALMENTE
input ulong n_seconds=5;//Segundos para Fechar Posição Sem Stop Loss




sinput string sparsea="PARAMETROS DO EA";//****************************
                                         //CHAVE DE ACESSO
input ulong MAGIC_NUMBER=1;//NUMERO MAGICO
