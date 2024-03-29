//+------------------------------------------------------------------+
//|                                                       Params.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

//#resource "\\Indicators\\Indic_Afastamento_Media_MATS.ex5"
#resource "\\Indicators\\afast_media_dx.ex5"
#resource "\\Indicators\\Custom Moving Average Input Color.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Entradas
  {
   CadaTick,//Cada Tick
   BarraClose//Esperar Barra Fechar
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum OpcoesEnt
  {
   DunnOnly,//Somente Dunningan
   SombraOnly,//Somente Sombra
   DunnSombra //Dunnigan OU Sombra 
  }
;
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

#include <EA_ROB\Expert_Class_ROB.mqh>


// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
                                                 //input string simbolo="WING19";//Digitar Símbolo Original
input int MAGIC_NUMBER=20082018;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input string SComum="############-----------------------------Comum---------------------------########";//Comum
input double Lot=1;//Lote Entrada
input double _Stop=300;//Stop Loss em Pontos
input double _TakeProfit=300;//Take Profit em Pontos
input string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia
sinput string sseg="###-------------Segurança Posições-------------#####";    //Segurança Posições
input int n_seconds=5;//Segundos para Fechar Posição Sem Stop Loss
sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input uchar start_hour=9;//Hora Inicial
input uchar start_min=4;//Minuto Inicial
input uchar end_hour=17;//Hora Final
input uchar end_min=20;//Minuto Final
input bool daytrade=true;//Fechar Posicao Fim do Horario
sinput string sdias="FILTRO DOS DIAS DA SEMANA";//Dias da Semana
input bool trade0=true;// Operar Domingo
input bool trade1=true;// Operar Segunda
input bool trade2=true;// Operar Terça
input bool trade3=true;// Operar Quarta
input bool trade4=true;// Operar Quinta
input bool trade5=true;// Operar Sexta
input bool trade6=true;// Operar Sábado



sinput string SEst_Med="############---------------------------------------Afastamento da Média------------------------------------------------########";   //Afastamento da Média
input bool ReverterSigAfast=false;//Reverter no Sinal Contrário
input int period_media=21; //Período Média                                                                                                                                  //Periodo da Media
input ENUM_MA_METHOD modo_media=MODE_SMA;  //Modo Média                                                                                                                //Modo da Média
input ENUM_APPLIED_PRICE app_media=PRICE_CLOSE; //Aplicar a                                                                                                            //Aplicar a
input double dist_media=300.0;  //Distância da Média para Entradas                                                                                                                              //Distância da Média em Pontos
input double dist_ent=50.0;//Distância para disparo da Ordem
input Sentido operar=Compra_e_Venda; //Tipo de Entradas                                                                                                                       // Operar Comprado, Vendido
input Entradas entradas=BarraClose;//Tipo de Sinal(Cada Tick ou Nova Barra)
input uint n_minutes_pausa=10;//Minutos de pausa após fechar um trade - 0 Não Pausar
input bool FecharMedia=false;//Fechar Posições ao Toque na Média
input uchar nmax_ent=0;//Número Máximo de Entradas - 0 Não Usar Filtro
input OpcoesEnt opcoes_ent=DunnSombra;//Opções de Entrada                                                                                                                                  //Aum de Pos p acionar Fech Média Sec/ 0 Não Sair na Secundária
sinput string sindicators="############------Sombra de Candle------#################";//Sombra de Candle
input double min_sombra=100;//Tamanho mínimo Sombra em Pontos
input double max_sombra_cont=50;//Tamanho máximo Sombra Contrária em Pontos

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
