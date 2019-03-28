//+------------------------------------------------------------------+
//|                                                       Params.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct Reentradas
  {
   double            Lote;
   double            Ponto;
   double            SL;
   double            TP;
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum VolStrat
  {
   AbaixoMed,//Abaixo da Média
   AcimaMed//Acima da Média
  };

enum Strategy
  {
   PrecoMed,//Preço Médio
   RevStr//Vira - Mão
  };

enum Sentido
  {
   Compra,        // Compra
   Venda        //Venda
  };


#include <EA_EST_PRP\Expert_Class_EstProp.mqh>


//sinput string senha="";//Cole a senha
input Strategy Estrategia=PrecoMed;//Selecione a Estratégia
ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input int MAGIC_NUMBER=29032019;//Número Mágico
ulong deviation_points=50;//Deviation em Pontos(Padrao)
sinput string SComum="############---------Comum--------########";//Comum
input double Lot=1;//Lote Entrada Inicial
input Sentido sentido=Compra;//Primeira Entrada
input double _Stop=30.0;//Stop Loss em Pontos
input double _TakeProfit=15.0;//Take Profit em Pontos
input string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:04";//Horario da Entrada Inicial
input string end_hour="17:20";//Horario de Encerramento
input bool daytrade=true;//Fechar Posicao Fim do Horario

sinput string SAumento="############----Reentradas----########";//Reentradas
sinput string Sentr1="-------------------------------------";//Reentrada 1
input double Lot_entry1=0;//Lotes Entrada 1 (0 não entrar)
input double pts_entry1=0;//Pontos Entrada 1
input double _Stop1=30.0;//Stop Loss em Pontos
input double _TakeProfit1=15.0;//Take Profit em Pontos
sinput string Sentr2="-------------------------------------";//Reentrada 2
input double Lot_entry2=0;//Lotes Entrada 2 (0 não entrar)
input double pts_entry2=0;//Pontos Entrada 2 
input double _Stop2=30.0;//Stop Loss em Pontos
input double _TakeProfit2=15.0;//Take Profit em Pontos

sinput string Sentr3="-------------------------------------";//Reentrada 3
input double Lot_entry3=0;//Lotes Entrada 3 (0 não entrar)
input double pts_entry3=0;//Pontos Entrada 3
input double _Stop3=30.0;//Stop Loss em Pontos
input double _TakeProfit3=15.0;//Take Profit em Pontos

sinput string Sentr4="-------------------------------------";//Reentrada 4
input double Lot_entry4=0;//Lotes Entrada 4 (0 não entrar)
input double pts_entry4=0;//Pontos Entrada 4
input double _Stop4=30.0;//Stop Loss em Pontos
input double _TakeProfit4=15.0;//Take Profit em Pontos

sinput string Sentr5="-------------------------------------";//Reentrada 5
input double Lot_entry5=0;//Lotes Entrada 5 (0 não entrar)
input double pts_entry5=0;//Pontos Entrada 5
input double _Stop5=30.0;//Stop Loss em Pontos
input double _TakeProfit5=15.0;//Take Profit em Pontos




sinput string sdias="FILTRO DOS DIAS DA SEMANA";//Dias da Semana
input bool trade0=true;// Operar Domingo
input bool trade1=true;// Operar Segunda
input bool trade2=true;// Operar Terça
input bool trade3=true;// Operar Quarta
input bool trade4=true;// Operar Quinta
input bool trade5=true;// Operar Sexta
input bool trade6=true;// Operar Sábado
sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia
sinput string sseg="###-------------Segurança Posições-------------#####";    //Segurança Posições
input int n_seconds=5;//Segundos para Fechar Posição Sem Stop Loss


