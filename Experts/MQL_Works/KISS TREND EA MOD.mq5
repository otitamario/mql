//+---------------------------------------------------------------------------------+
//|  Lucro OK Panel OK Version Fixed 061218 10:37HS  -  KISS TREND EA MOD.mq5   |
//|  SEGUNDO TIMER ADICIONADO // FECHAR NO NEUTRO // BLOQUEIO POR CONTAS // MAGIC   |
//|  PROBLEMAS COM ORDENS EM GRANDE QUANTIDADE - RESOLVIDO NESSA VERSÃO             |
//+---------------------------------------------------------------------------------+
//+---------------------------------------------------------------------------------+
//| Version 01 (03-Feb-2018):                                                       |
//|   01(a) Renamed Media <number>  to  Option <alphabet>                           |
//|   01(b) Included de-bugged library, velascolor_V01.mqh                          |
//| Version 02 (21-Mar-2018):                                                       |
//|   02(a) Added HPCS_Renko_Symbol_Generator.mqh to Libraries                      |
//|   02(b) Changed Trading symbol if "Symbol()" to _Symbol                         |
//|   02(c) Changed Indicators symbol if "_Symbol" to Symbol()                      |
//|   02(d) Added comment after every changed line as //chng_V02:                   |
//|---------------------------------------------------------------------------------|
//|   01(a) Changed Project name to KISS TREND EA MOD                               |
//|   01(b) Removed velascolor_V01.mqh and added kisstrendpro_V01.mqh in Libraries  |
//+---------------------------------------------------------------------------------+
//|   05(a) Corrected filling type before placing orders (For Index and Futures)    |
//|   05(b) Stop ATR Modify Error resolved                                          |
//+---------------------------------------------------------------------------------+
#property link "http://keeptradingcorp.com/"
#property copyright "Copyright© 2011-2019, Keep It Simple Trading Corp®."
#property version "1.12"
#property icon "\\Files\\icon_s.ico"
#property description "KISS TREND EA MOD."

#define d_ObjFunNom "image"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TipoLote
  {
   Lote_Fixo,    //Lote Fixo
   Porcent_Risco //Porcentagem Risco
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TipoGrafico
  {
   GrafNormal, //Símbolo Original
   GrafRenko   //Renko
  };

#define INFOPANEL_SIZE 3                              // Size of the array for info panel objects
#define EXPERT_NAME MQL5InfoString(MQL5_PROGRAM_NAME) // Name of the Expert Advisor

//string NomeCliente="NOME"; //NOME DO USUÁRIO
//bool blockCliente;

//ulong conta1 = 229150;    //
ulong conta1=5157768;//80414606;    //

ulong conta2 = 5251512;   //
ulong conta3 = 9019798;   //
ulong conta4 = 92402887;  //
ulong conta5 = 594078;    //
ulong conta6 = 96200;     //
ulong conta7 = 3376449;   //
ulong conta8 = 2551819;   //
ulong conta9 = 2518645;   //
ulong conta10 = 2951931;  //
ulong conta11 = 2451267;  //
ulong conta12 = 92451267; //
ulong conta13 = 82451267; //
ulong conta14 = 72451267;
ulong conta15 = 10851390;
ulong conta16 = 10851364;
ulong conta17 = 10851294;
ulong conta18 = 15017023;
ulong conta19 = 0;
ulong conta20 = 0;
ulong conta21 = 0;
ulong conta22 = 10671178;
ulong conta23 = 671178;
ulong conta24 = 295949;     // RODRIGO XP REAL
ulong conta25 = 50295949;   // RODRIGO XP
ulong conta26 = 5102165;    // RODRIGO ACTIVTRADES
ulong conta27 = 9015729;    // RODRIGO TERRA
ulong conta28 = 3000141516; // RODRIGO RICO
ulong conta29 = 8012459;    // RODRIGO TERRA
ulong conta30 = 9012459;    // RODRIGO TERRA
bool blockCliente;

//------- Libraries -------//
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <AuxiliaresT.mqh>
#include <kisstrend_mod.mqh> //chng KTEP_V01: Added Librery
#include <Trade\AccountInfo.mqh>
#include <KISTC_Renko_Symbol_Generator.mqh> //chng_V02: Added Library

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+

//------- Class Objects -------//
CAccountInfo myaccount;
CNewBar NewBar;
COrderInfo myorder;
CPositionInfo myposition;
CSymbolInfo mysymbol;
CTimer Timer;
CTrade mytrade;
CDealInfo mydeal;
CiVelas *gCP_iVelas,
*gCP_iVelasTend;

long gl_ChartID_Current,
gl_ChartID_New;
//
// indicators' handles
int gi_aHandleMA_T[15],//Handle for the MA indicators
gi_HandleATR_T,
gi_HandleVWAP_T,
gi_HandleHiLo_T;
int gi_HandleADX,
gi_HandleATR,
gi_HandleStopATR;
int gi_BarraTrade;
double PointBreakEven[5],PointProfit[5];
//
// buffers
double gd_abufferStopATR_Lower[],
gd_abufferStopATR_Upper[]; //buffer do ATR normal
double gd_abufferADX[],
gd_abufferADX_P[],
gd_abufferADX_N[],
gd_aClose[];
//
double gd_Lotes,
gd_Ponto,
ticksize,
gd_StopLoss,
gd_TakeProfit;
double gd_LotesTrades;
//
int gi_Digits;
long gl_Posicao;
bool gb_TradeOn;
bool timerOn,timerPausa;

double gd_LucroTotal,
gd_SaldoInicial;
double ask,
bid,
gd_Preco;
double gd_PrecoAbertura;
ulong trade_ticket;
datetime hora_inicial,hora_final;
datetime hora_inicial_pausa,hora_final_pausa;
string pos_resultado = " "; // Resultado
string pos_posicao = " ";   // Posicao
string posicao_atual="ZERADO";
string pos_horario=" "; // Horario

//--- Array of names of objects that display the names of position properties
string pos_prop_names[INFOPANEL_SIZE]=
  {
   "name_resultado",
   "name_posicao",
   "name_horario"
  };
// Array of names of objects that display values of position properties
string pos_prop_values[INFOPANEL_SIZE]=
  {
   "value_resultado",
   "value_posicao",
   "value_horario",
  };

//+------------------------------------------------------------------+
//| Input variables                                                 |
//+------------------------------------------------------------------+
input string original_symbol = "NOMEDOSIMBOLO"; //Nome do Simbolo conforme o original
input int Magic_Number = 1;                     // Numero Mágico
input ulong deviation_points = 1000;            //Desvio em Pontos
sinput string Volume;                           // Informe abaixo o volume a ser negociado:
input TipoLote tipolote = Lote_Fixo;            // Lote Fixo ou Porcentagem de Risco
input double Lot = 1;                           //Lote Fixo de Entrada
input double porc_Lot = 2;                      //Porcentagem de Risco para Lote
input int barras_entry = 1;                     //Barras em sequência para entradas: 1,2,3...
input bool fechar_neutro = true;                //Fechar no Box Neutro
sinput string Lucro= "Objetivo Financeiro para desligar o EA";
input double lucro = 100000.0;  //Lucro para Fechar Posicoes
input double prejuizo = 1000.0; //Prejuizo para Fechar Posicoes

sinput string shorario = "-----------------Filtro de Horário-----------------"; //Horário
input bool UseTimer = false;                                                    //Usar Filtro de Horário: True/False
input string start_hour = "09:05";                                              //Horario Inicial
input string end_hour = "17:30";                                                //Horario Final
input bool Daytrade = false;                                                    //Fechar Posicao Fim do Horario

sinput string shorpausa="-----------------Horário de Pausa-----------------"; //Pausa
input bool UseTimerPausa=false;
input string start_hour_pausa = "22:45"; //Horario Inicial Pausa
input string end_hour_pausa = "23:45";   //Horario Final Pausa
                                         //Fechar posicoes Daytrade fim do dia

sinput string SL_TP="Informe abaixo o Stoploss e TakeProfit das operações:"; //

input double _Stop = 500;             //Stop Loss
input double _TakeProfit = 1000;      //Take Profit
input bool UsarRompimento = false;    //Usar Rompimento para Entradas
input int BarrasVerificarEntrada = 4; //Numero de Barras p/ verificar rompimento max e min
input int Dist_Rompimento = 10;       //Distancia de rompimento para entradas
input bool UsarRealizParc = false;    //Usar Realização Parcial
input double DistanceRealizeParcial=45;
input double LotesParcial=1;
input bool BarraAtual = false;      //True:Barra Atual, False Espera Fechamento
input bool UseBreakEven = false;    //Usar BreakEven
input int BreakEvenPoint1 = 100;    //Pontos para BreakEven 1
input int ProfitPoint1 = 80;        //Pontos de Lucro da Posicao 1
input int BreakEvenPoint2 = 200;    //Pontos para BreakEven 2
input int ProfitPoint2 = 150;       //Pontos de Lucro da Posicao 2
input int BreakEvenPoint3 = 300;    //Pontos para BreakEven 3
input int ProfitPoint3 = 250;       //Pontos de Lucro da Posicao 3
input int BreakEvenPoint4 = 500;    //Pontos para BreakEven 4
input int ProfitPoint4 = 400;       //Pontos de Lucro da Posicao 4
input int BreakEvenPoint5 = 700;    //Pontos para BreakEven 5
input int ProfitPoint5 = 550;       //Pontos de Lucro da Posicao 5
input bool Filtro_ADX = false;      //Usar Filtro ADX
input int adx_period = 14;          //Periodo ADX
input double ADX_min = 20.0;        //ADX mínimo
input bool UseTrailingStop = false; //Usar Trailing
input int TrailingStop = 250;       //Distancia do Stop
input int MinimumProfit = 0;        //Lucro Minimo pra ativar o Stop
input int Step = 20;                //Passo pra atualizar o STOP
input bool Use_STOP_ATR = false;    // Usar Stop loss/gain movel STOPATR
input int dist_STOP_ATR = 250;      //Distância em pontos para STOP ATR

sinput string s_velas = "-----------------KISS TREND IND PRO - OPERADOR-----------------"; //
input ENUM_TIMEFRAMES period_velas = PERIOD_CURRENT;                                       //Período das Velas
input bool pMedia1 = false;                                                                // Usar Option A
bool pPlot1 = false;                                                                       //Plotar Option A
int pperiodo1 = 1;                                                                         // Periodo Option A
input bool pMedia2 = false;                                                                // Usar Option B
bool pPlot2 = false;                                                                       //Plotar Option B
int pperiodo2 = 2;                                                                         //Periodo Option B
input bool pMedia3 = false;                                                                // Usar Option C
bool pPlot3 = false;                                                                       //Plotar Option C
int pperiodo3 = 3;                                                                         //Periodo Option C
input bool pMedia4 = false;                                                                // Usar Option D
bool pPlot4 = false;                                                                       //Plotar Option D
int pperiodo4 = 4;                                                                         //Periodo Option D
input bool pMedia5 = false;                                                                // Usar Option E
bool pPlot5 = false;                                                                       //Plotar Option E
int pperiodo5 = 5;                                                                         //Periodo Option E
input bool pMedia6 = false;                                                                // Usar Option F
bool pPlot6 = false;                                                                       //Plotar Option F
int pperiodo6 = 6;                                                                         //Periodo Option F
input bool pMedia7 = false;                                                                // Usar Option G
bool pPlot7 = false;                                                                       //Plotar Option G
int pperiodo7 = 7;                                                                         //Periodo Option G
input bool pMedia8 = false;                                                                // Usar Option H
bool pPlot8 = false;                                                                       //Plotar Option H
int pperiodo8 = 8;                                                                         //Periodo Option H
input bool pMedia9 = false;                                                                // Usar Option I
bool pPlot9 = false;                                                                       //Plotar Option I
int pperiodo9 = 9;                                                                         //Periodo Option I
input bool pMedia10 = false;                                                               // Usar Option J
bool pPlot10 = false;                                                                      //Plotar Option J
int pperiodo10 = 10;                                                                       //Periodo Option J
input bool pMedia11 = false;                                                               // Usar Option K
bool pPlot11 = false;                                                                      //Plotar Option K
int pperiodo11 = 11;                                                                       //Periodo Option K
input bool pMedia12 = false;                                                               // Usar Option L
bool pPlot12 = false;                                                                      //Plotar Option L
int pperiodo12 = 12;                                                                       //Periodo Option L
input bool pMedia13 = false;                                                               // Usar Option M
bool pPlot13 = false;                                                                      //Plotar Option M
int pperiodo13 = 13;                                                                       //Periodo Option M
input bool pMedia14 = false;                                                               // Usar Option N
bool pPlot14 = false;                                                                      //Plotar Option N
int pperiodo14 = 14;                                                                       //Periodo Option N
input bool pMedia15 = false;                                                               // Usar Option O
bool pPlot15 = false;                                                                      //Plotar Option O
int pperiodo15 = 15;                                                                       //Periodo Option O

input bool pATRSTOP = false;   // Usar ATRSTOP
input bool pPlot_atr = false;  //Plotar ATRSTOP
input uint pLength = 5;        // Indicator period
input uint pATRPeriod = 20;    // Period of ATR
input double pKv = 2.0;        // Volatility by ATR
input int pShift = 0;          // Shift
input bool pUsar_VWAP = false; //Usar VWAP
input bool pPlot_VWAP = false; //Plotar VWAP
input PRICE_TYPE pPrice_Type= CLOSE;
input bool pCalc_Every_Tick = false;
input bool pEnable_Daily=false;
input bool pShow_Daily_Value=false;
input bool pEnable_Weekly=false;
input bool pShow_Weekly_Value=false;
input bool pEnable_Monthly=false;
input bool pShow_Monthly_Value=false;
input bool pUsar_Hilo = false; // Usar Hilo
input bool pPlot_hilo = false; //Plotar hilo
input int pperiod_hilo = 8;    //Periodo Hilo
input int pshift_hilo = 0;     // Deslocar Hilo

sinput string s_tend = "-----------------KISS TREND IND PRO - TENDENCIA-----------------"; //
input bool Use_TEND = false;                                                               //Usar Tendência;
input ENUM_TIMEFRAMES tend_period = PERIOD_M1;                                             //TimeFrame da Tendência
input bool Media1_T = false;                                                               // Usar Option A
bool Plot1_T = false;                                                                      //Plotar Option A
int periodo1_T = 1;                                                                        // Periodo Option A
input bool Media2_T = false;                                                               // Usar Option B
bool Plot2_T = false;                                                                      //Plotar Option B
int periodo2_T = 2;                                                                        //Periodo Option B
input bool Media3_T = false;                                                               // Usar Option C
bool Plot3_T = false;                                                                      //Plotar Option C
int periodo3_T = 3;                                                                        //Periodo Option C
input bool Media4_T = false;                                                               // Usar Option D
bool Plot4_T = false;                                                                      //Plotar Option D
int periodo4_T = 4;                                                                        //Periodo Option D
input bool Media5_T = false;                                                               // Usar Option E
bool Plot5_T = false;                                                                      //Plotar Option E
int periodo5_T = 5;                                                                        //Periodo Option E
input bool Media6_T = false;                                                               // Usar Option F
bool Plot6_T = false;                                                                      //Plotar Option F
int periodo6_T = 6;                                                                        //Periodo Option F
input bool Media7_T = false;                                                               // Usar Option G
bool Plot7_T = false;                                                                      //Plotar Option G
int periodo7_T = 7;                                                                        //Periodo Option G
input bool Media8_T = false;                                                               // Usar Option H
bool Plot8_T = false;                                                                      //Plotar Option H
int periodo8_T = 8;                                                                        //Periodo Option H
input bool Media9_T = false;                                                               // Usar Option I
bool Plot9_T = false;                                                                      //Plotar Option I
int periodo9_T = 9;                                                                        //Periodo Option I
input bool Media10_T = false;                                                              // Usar Option J
bool Plot10_T = false;                                                                     //Plotar Option J
int periodo10_T = 10;                                                                      //Periodo Option J
input bool Media11_T = false;                                                              // Usar Option K
bool Plot11_T = false;                                                                     //Plotar Option K
int periodo11_T = 11;                                                                      //Periodo Option K
input bool Media12_T = false;                                                              // Usar Option L
bool Plot12_T = false;                                                                     //Plotar Option L
int periodo12_T = 12;                                                                      //Periodo Option L
input bool Media13_T = false;                                                              // Usar Option M
bool Plot13_T = false;                                                                     //Plotar Option M
int periodo13_T = 13;                                                                      //Periodo Option M
input bool Media14_T = false;                                                              // Usar Option N
bool Plot14_T = false;                                                                     //Plotar Option N
int periodo14_T = 14;                                                                      //Periodo Option N
input bool Media15_T = false;                                                              // Usar Option O
bool Plot15_T = false;                                                                     //Plotar Option O
int periodo15_T = 15;                                                                      //Periodo Option O

input bool ATRSTOP_T = false;   // Usar ATRSTOP
input bool Plot_atr_T = false;  //Plotar ATRSTOP
input uint Length_T = 5;        // Indicator period
input uint ATRPeriod_T = 20;    // Period of ATR
input double Kv_T = 2.0;        // Volatility by ATR
input int Shift_T = 0;          // Shift
input bool Usar_VWAP_T = false; //Usar VWAP
input bool Plot_VWAP_T = false; //Plotar VWAP
input PRICE_TYPE Price_Type_T= CLOSE;
input bool Calc_Every_Tick_T = false;
input bool Enable_Daily_T=false;
input bool Show_Daily_Value_T=false;
input bool Enable_Weekly_T=false;
input bool Show_Weekly_Value_T=false;
input bool Enable_Monthly_T=false;
input bool Show_Monthly_Value_T=false;
input bool Usar_Hilo_T = false;                                  // Usar Hilo
input bool Plot_hilo_T = false;                                  //Plotar hilo
input int period_hilo_T = 8;                                     //Periodo Hilo
input int shift_hilo_T = 0;                                      // Deslocar Hilo
sinput string s_macd = "-----------------MACD-----------------"; //Filtro MACD
input bool UsarMACD = true;                                      //Usar MACD como filtro
input TipoGrafico tipografico = GrafNormal;                      //Símbolo para o Macd
input ENUM_TIMEFRAMES periodMACD = PERIOD_CURRENT;               //TIMEFRAME MACD
input int InpFastEMA = 12;                                       // Fast EMA period
input int InpSlowEMA = 26;                                       // Slow EMA period
input int InpSignalSMA = 9;                                      // Signal SMA period
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE;          // Applied price

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CiMACD *macd;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

/*
  blockCliente=  AccountInfoString(ACCOUNT_NAME)== NomeCliente;
  if( blockCliente==true)  
 {
  {
  
  Print("Liberado para uso."); */

   blockCliente=AccountInfoInteger(ACCOUNT_LOGIN)==conta1 || AccountInfoInteger(ACCOUNT_LOGIN)==conta2 || AccountInfoInteger(ACCOUNT_LOGIN)==conta3 || AccountInfoInteger(ACCOUNT_LOGIN)==conta4 || AccountInfoInteger(ACCOUNT_LOGIN)==conta5 || AccountInfoInteger(ACCOUNT_LOGIN)==conta6 || AccountInfoInteger(ACCOUNT_LOGIN)==conta7 || AccountInfoInteger(ACCOUNT_LOGIN)==conta8 || AccountInfoInteger(ACCOUNT_LOGIN)==conta9 || AccountInfoInteger(ACCOUNT_LOGIN)==conta10 || AccountInfoInteger(ACCOUNT_LOGIN)==conta11 || AccountInfoInteger(ACCOUNT_LOGIN)==conta12 || AccountInfoInteger(ACCOUNT_LOGIN)==conta13 || AccountInfoInteger(ACCOUNT_LOGIN)==conta14 || AccountInfoInteger(ACCOUNT_LOGIN)==conta15 || AccountInfoInteger(ACCOUNT_LOGIN)==conta16 || AccountInfoInteger(ACCOUNT_LOGIN)==conta17 || AccountInfoInteger(ACCOUNT_LOGIN)==conta18 || AccountInfoInteger(ACCOUNT_LOGIN)==conta19 || AccountInfoInteger(ACCOUNT_LOGIN)==conta20 || AccountInfoInteger(ACCOUNT_LOGIN)==conta21 || AccountInfoInteger(ACCOUNT_LOGIN)==conta22 || AccountInfoInteger(ACCOUNT_LOGIN)==conta23 || AccountInfoInteger(ACCOUNT_LOGIN)==conta24 || AccountInfoInteger(ACCOUNT_LOGIN)==conta25 || AccountInfoInteger(ACCOUNT_LOGIN)==conta26 || AccountInfoInteger(ACCOUNT_LOGIN)==conta27 || AccountInfoInteger(ACCOUNT_LOGIN)==conta28 || AccountInfoInteger(ACCOUNT_LOGIN)==conta29 || AccountInfoInteger(ACCOUNT_LOGIN)==conta30;
   if(blockCliente)
      Print("Liberado para uso.");

   else

     {

      Print("Conta não autorizada");

      return (INIT_FAILED);
     }

//}

   mytrade.SetTypeFilling(ORDER_FILLING_RETURN);

//Expiry date setting
/*
   string ExpiryDate="2019.07.09";
   if(TimeCurrent()>=StringToTime(ExpiryDate))
     {
      Alert("O período de testes do KISS TREND EA MOD expirou.");
      ChartIndicatorDelete(0,0,"KISS TREND EA MOD");
      ExpertRemove();
      Print("Expert removido devido ao periodo de utilização haver vencido. Nos contate para solicitar sua licença de uso!");
      return(0);
     }
   else
     {
      Print("KISS TREND EA MOD liberado para uso até 09/07/2019");
     } */

   IndicatorSetString(INDICATOR_SHORTNAME,"KISS TREND EA MOD");

   ObjectCreate(0,d_ObjFunNom,OBJ_BITMAP_LABEL,0,0,0);
   ObjectSetInteger(0,d_ObjFunNom,OBJPROP_XDISTANCE,1841);
   ObjectSetInteger(0,d_ObjFunNom,OBJPROP_YDISTANCE,89);
   ObjectSetInteger(0,d_ObjFunNom,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetString(0,d_ObjFunNom,OBJPROP_BMPFILE,0,"\\Files\\image.bmp");
   ObjectSetInteger(0,d_ObjFunNom,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,d_ObjFunNom,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,d_ObjFunNom,OBJPROP_HIDDEN,false);

   _KISTC_RENKO_SYMBOL; //chng_V02: To get Base Symbol in _Symbol

   mysymbol.Name(original_symbol); //chng_V02: _Symbol For Base Symbol
                                   //
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.SetDeviationInPoints(deviation_points);
//

   if(BarraAtual)
      gi_BarraTrade=0;
   else
      gi_BarraTrade=1;
//
   gl_ChartID_Current=ChartID();
   ChartRedraw(gl_ChartID_Current);
//
//
   gCP_iVelas=new CiVelas;
   gCP_iVelas.Create(Symbol(),period_velas,pMedia1,pMedia2,
                     pMedia3,
                     pMedia4,
                     pMedia5,
                     pMedia6,
                     pMedia7,
                     pMedia8,
                     pMedia9,
                     pMedia10,
                     pMedia11,
                     pMedia12,
                     pMedia13,
                     pMedia14,
                     pMedia15,
                     pATRSTOP,
                     pPlot_atr,pLength,pATRPeriod,pKv,pShift,pUsar_VWAP,pPlot_VWAP,pPrice_Type,
                     pCalc_Every_Tick,pEnable_Daily,pShow_Daily_Value,pEnable_Weekly,
                     pShow_Weekly_Value,pEnable_Monthly,pShow_Monthly_Value,pUsar_Hilo,
                     pPlot_hilo,pperiod_hilo,pshift_hilo);
   gCP_iVelas.AddToChart(gl_ChartID_Current,0);
//
//

   if(UsarMACD)
     {
      if(tipografico==GrafRenko && periodMACD>1)
        {
         string erro="MACD com Renko não pode ter TIMEFRAME Maior que 1 Minuto";
         MessageBox(erro);
         Print(erro);
         return (INIT_PARAMETERS_INCORRECT);
        }
      string simb_macd=_Symbol;
      long ChartMacd = gl_ChartID_Current;
      if(tipografico == GrafNormal)
        {
         simb_macd = original_symbol;
         ChartMacd = ChartOpen(simb_macd, periodMACD);
        }
      macd=new CiMACD;
      macd.Create(simb_macd, periodMACD, InpFastEMA, InpSlowEMA, InpSignalSMA, InpAppliedPrice);
      macd.AddToChart(ChartMacd, (int)ChartGetInteger(ChartMacd, CHART_WINDOWS_TOTAL));
     }

   if(Use_TEND)
     {
      gl_ChartID_New=ChartOpen(original_symbol,tend_period);
      ChartRedraw(gl_ChartID_New);
      //
      //
      gCP_iVelasTend=new CiVelas;
      gCP_iVelasTend.Create(original_symbol,tend_period,Media1_T,
                            Media2_T,
                            Media3_T,
                            Media4_T,
                            Media5_T,
                            Media6_T,
                            Media7_T,
                            Media8_T,
                            Media9_T,
                            Media10_T,
                            Media11_T,
                            Media12_T,
                            Media13_T,
                            Media14_T,
                            Media15_T,
                            ATRSTOP_T,
                            Plot_atr_T,Length_T,ATRPeriod_T,Kv_T,Shift_T,Usar_VWAP_T,Plot_VWAP_T,Price_Type_T,
                            Calc_Every_Tick_T,Enable_Daily_T,Show_Daily_Value_T,Enable_Weekly_T,
                            Show_Weekly_Value_T,Enable_Monthly_T,Show_Monthly_Value_T,Usar_Hilo_T,
                            Plot_hilo_T,period_hilo_T,shift_hilo_T);
      gCP_iVelasTend.AddToChart(gl_ChartID_New,0);

      //
      gi_aHandleMA_T[0] = iMA(original_symbol, tend_period, periodo1_T, 0, MODE_EMA, PRICE_CLOSE); //A//
      gi_aHandleMA_T[1] = iMA(original_symbol, tend_period, periodo2_T, 0, MODE_EMA, PRICE_CLOSE); //B//
      gi_aHandleMA_T[2] = iMA(original_symbol, tend_period, periodo3_T, 0, MODE_EMA, PRICE_CLOSE); //C//
      gi_aHandleMA_T[3] = iMA(original_symbol, tend_period, periodo4_T, 0, MODE_EMA, PRICE_CLOSE); //D//
      gi_aHandleMA_T[4] = iMA(original_symbol, tend_period, periodo5_T, 0, MODE_SMA, PRICE_CLOSE); //E//
      gi_aHandleMA_T[5] = iMA(original_symbol, tend_period, periodo6_T, 0, MODE_SMA, PRICE_CLOSE); //F//

      gi_aHandleMA_T[6] = iMA(original_symbol, tend_period, periodo7_T, 0, MODE_SMA, PRICE_CLOSE); //G//
      gi_aHandleMA_T[7] = iMA(original_symbol, tend_period, periodo8_T, 0, MODE_SMA, PRICE_CLOSE); //H//
      gi_aHandleMA_T[8] = iMA(original_symbol, tend_period, periodo9_T, 0, MODE_EMA, PRICE_CLOSE); //I//

      gi_aHandleMA_T[9] = iMA(original_symbol, tend_period, periodo10_T, 0, MODE_EMA, PRICE_CLOSE);  //J//
      gi_aHandleMA_T[10] = iMA(original_symbol, tend_period, periodo11_T, 0, MODE_EMA, PRICE_CLOSE); //K//
      gi_aHandleMA_T[11] = iMA(original_symbol, tend_period, periodo12_T, 0, MODE_EMA, PRICE_CLOSE); //L//

      gi_aHandleMA_T[12] = iMA(original_symbol, tend_period, periodo13_T, 0, MODE_EMA, PRICE_CLOSE); //M//
      gi_aHandleMA_T[13] = iMA(original_symbol, tend_period, periodo14_T, 0, MODE_EMA, PRICE_CLOSE); //N//
      gi_aHandleMA_T[14] = iMA(original_symbol, tend_period, periodo15_T, 0, MODE_EMA, PRICE_CLOSE); //O//
                                                                                                     //
      gi_HandleATR_T=iCustom(original_symbol,tend_period,"atrstops_v1",Length_T,ATRPeriod_T,Kv_T,Shift_T);
      gi_HandleVWAP_T=iCustom(original_symbol,tend_period,"vwap_lite",Price_Type_T,Calc_Every_Tick_T,Enable_Daily_T,
                              Show_Daily_Value_T,Enable_Weekly_T,Show_Weekly_Value_T,Enable_Monthly_T,Show_Monthly_Value_T);
      gi_HandleHiLo_T=iCustom(original_symbol,tend_period,"hilo_escada_smothed",period_hilo_T,MODE_SMMA,shift_hilo_T);
      //
      //
      if(Media1_T && Plot1_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_aHandleMA_T[0]);
      if(Media2_T && Plot2_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_aHandleMA_T[1]);
      if(Media3_T && Plot3_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_aHandleMA_T[2]);
      if(Media4_T && Plot4_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_aHandleMA_T[3]);
      if(Media5_T && Plot5_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_aHandleMA_T[4]);
      if(Media6_T && Plot6_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_aHandleMA_T[5]);
      if(Media7_T && Plot7_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_aHandleMA_T[6]);
      if(Media8_T && Plot8_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_aHandleMA_T[7]);
      if(Media9_T && Plot9_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_aHandleMA_T[8]);
      if(Media10_T && Plot10_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_aHandleMA_T[9]);
      if(Media11_T && Plot11_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_aHandleMA_T[10]);
      if(Media12_T && Plot12_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_aHandleMA_T[11]);
      if(Media13_T && Plot13_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_aHandleMA_T[12]);
      if(Media14_T && Plot14_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_aHandleMA_T[13]);
      if(Media15_T && Plot15_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_aHandleMA_T[14]);
      //
      if(ATRSTOP_T && Plot_atr_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_HandleATR_T);
      if(Usar_VWAP_T && Plot_VWAP_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_HandleVWAP_T);
      if(Usar_Hilo_T && Plot_hilo_T)
         ChartIndicatorAdd(gl_ChartID_New,0,gi_HandleHiLo_T);

     }                                                                     // End if TEND
//
//
   gd_Ponto = SymbolInfoDouble(original_symbol, SYMBOL_POINT);           //chng_V02: _Symbol For Base Symbol
   ticksize = SymbolInfoDouble(original_symbol, SYMBOL_TRADE_TICK_SIZE); //chng_V02: _Symbol For Base Symbol
   gi_Digits = (int)SymbolInfoInteger(original_symbol, SYMBOL_DIGITS);   //chng_V02: _Symbol For Base Symbol
                                                                         //
//
   if(Use_STOP_ATR)
     {
      gi_HandleStopATR=iCustom(Symbol(),period_velas,"atrstops_v1",pLength,pATRPeriod,pKv,pShift);
      //
      if(gi_HandleStopATR==INVALID_HANDLE)
        {
         Print(": Falha em obter o indicador STOP ATR");
         Print("Handle = ",gi_HandleStopATR,"  error = ",GetLastError());
         return (INIT_FAILED);
        }
     } //Fim ATR
//
//
   if(Filtro_ADX)
     {
      gi_HandleADX=iADX(original_symbol,PERIOD_M1,adx_period);
      //
      if(gi_HandleADX==INVALID_HANDLE)
        {
         Print(": Falha em obter o indicador ADX");
         Print("Handle = ",gi_HandleADX,"  error = ",GetLastError());
         return (INIT_FAILED);
        }
      ArrayInitialize(gd_abufferADX,0.0);
      ArrayInitialize(gd_abufferADX_P, 0.0);
      ArrayInitialize(gd_abufferADX_N, 0.0);
      //
      ArraySetAsSeries(gd_abufferADX,true);
      ArraySetAsSeries(gd_abufferADX_P,true);
      ArraySetAsSeries(gd_abufferADX_N,true);
     } // Fim ADX
//
//
   if(Use_STOP_ATR)
     {
      ChartIndicatorAdd(gl_ChartID_Current,0,gi_HandleStopATR);
      ArrayInitialize(gd_abufferStopATR_Lower, 0.0);
      ArrayInitialize(gd_abufferStopATR_Upper, 0.0);
      //
      ArraySetAsSeries(gd_abufferStopATR_Lower,true);
      ArraySetAsSeries(gd_abufferStopATR_Upper,true);
     }
//
//
   ArrayInitialize(gd_aClose,0.0);
   ArraySetAsSeries(gd_aClose,true);
//
//
//------------------------------------------------------------------------
   gd_Lotes=0.0;
   gd_LucroTotal=0.0;
   gd_SaldoInicial=AccountInfoDouble(ACCOUNT_BALANCE);
//
   PointBreakEven[0] = BreakEvenPoint1;
   PointBreakEven[1] = BreakEvenPoint2;
   PointBreakEven[2] = BreakEvenPoint3;
   PointBreakEven[3] = BreakEvenPoint4;
   PointBreakEven[4] = BreakEvenPoint5;
   PointProfit[0] = ProfitPoint1;
   PointProfit[1] = ProfitPoint2;
   PointProfit[2] = ProfitPoint3;
   PointProfit[3] = ProfitPoint4;
   PointProfit[4] = ProfitPoint5;
//

// parametros incorretos desnecessarios na otimizacao

   for(int i=0; i<5; i++)
     {
      if(PointBreakEven[i]<PointProfit[i])
        {
         string erro="Profit do Break Even deve ser menor que o Ponto de Break Even";
         MessageBox(erro);
         Print(erro);
         return (INIT_PARAMETERS_INCORRECT);
        }
     }

   for(int i=0; i<4; i++)
     {
      if(PointBreakEven[i+1]<=PointBreakEven[i])
        {
         string erro="Pontos de Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return (INIT_PARAMETERS_INCORRECT);
        }
     }

   for(int i=0; i<4; i++)
     {
      if(PointProfit[i+1]<=PointProfit[i])
        {
         string erro="Pontos de Profit do Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return (INIT_PARAMETERS_INCORRECT);
        }
     }

   if(Lot<=0)
     {
      string erro="Lote deve ser maior que 0";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   if(barras_entry<0)
     {
      string erro="Barras em sequência para entrada deve ser >= 0";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   hora_inicial_pausa=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour_pausa);
   hora_final_pausa=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_pausa);

   if(UseTimer && hora_final<=hora_inicial)
     {
      string erro="Horario Final deve ser Maior que Horario Inicial";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   if(UseTimer && UseTimerPausa && (hora_final_pausa>hora_final || hora_inicial_pausa<hora_inicial))
     {
      string erro="Horario de Pausa deve estar contido dentro do Horário Geral";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   return (INIT_SUCCEEDED);
  }
//---
//}

//}
/*
 else{
 ChartIndicatorDelete(0,0,"KISS TREND EA MOD");
 ExpertRemove();
 Print("Este sistema irá funcionar somente em contas previamente cadastradas pelo criador da ferramenta.");  
 Print("Favor contatar o criador da ferramenta se você possui autorização para uso da mesma.");   
             }
  return(INIT_SUCCEEDED);
  }   */

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   ObjectDelete(0,d_ObjFunNom);
   if(UsarMACD)
      delete (macd);
   delete gCP_iVelas;
   gCP_iVelas=NULL;
//
   if(Use_TEND)
     {
      delete gCP_iVelasTend;
      gCP_iVelas=NULL;
     }
   HLineDelete(0,"Abertura");
   HLineDelete(0,"Stop Loss");
   HLineDelete(0,"Take Profit");
   if(reason==REASON_REMOVE)
      //--- Delete all objects relating to the info panel from the chart
      DeleteInfoPanel();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- refresh data
   mysymbol.Refresh();
   mysymbol.RefreshRates();

   gCP_iVelas.Refresh();
   if(Use_TEND)
      gCP_iVelasTend.Refresh();
//
   if(UsarMACD)
      macd.Refresh();
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   hora_inicial_pausa=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour_pausa);
   hora_final_pausa=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_pausa);

   if(GetIndValue())
     {
      if(timerOn)
         Print("Erro em obter os dados dos buffers de indicadores na funcao GET");
      return;
     }
//
   GetPositionProperties();

   bool novodia;
   novodia=NewBar.CheckNewBar(_Symbol,PERIOD_D1); //chng_V02: _Symbol to get new day of Base Symbol
   if(novodia)
     {
      gd_SaldoInicial=AccountInfoDouble(ACCOUNT_BALANCE);
      gd_LucroTotal=AccountInfoDouble(ACCOUNT_BALANCE)-gd_SaldoInicial;
      gb_TradeOn=true;
     }

   gd_LucroTotal=LucroOrdens()+LucroPositions();
   if(gd_LucroTotal>=lucro || gd_LucroTotal<=-prejuizo)
     {
      if(PosicaoAberta())
        {
         DeleteALL();
         CloseALL();
        }
      gb_TradeOn=false;
     }
   else
      gb_TradeOn=true;
//
//
   timerOn=true;
   timerPausa=false;

   if(UseTimer==true)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final;
      timerPausa=TimeCurrent()>=hora_inicial_pausa && TimeCurrent()<=hora_final_pausa;
     }
//
   if(timerOn==false && PosicaoAberta() && UseTimer && Daytrade)
     {
      DeleteALL();
      CloseALL();
     }
//
//
//Atualizacao das Cotacoes----ticks
   MqlTick last_tick;
   if(SymbolInfoTick(original_symbol,last_tick))
     {
      bid = last_tick.bid;
      ask = last_tick.ask;
     }
   else
     {
      if(timerOn)
         Print("Falhou obter o tick");
      return;
     }
   double spread=ask-bid;
   if(bid==0 || ask==0)
     {
      if(timerOn)
         Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }

//
//
//------------------------------------------------------------------------------
   if(gb_TradeOn && timerOn)
     {
      if(!timerPausa)
        {

         gl_Posicao=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

         if(NewBar.CheckNewBar(Symbol(),PERIOD_CURRENT))
           {
            //------------------------------------------------------------------
            if(BuySignal() && (!Buy_opened())) // Open long position
              {
               DeleteOrders(ORDER_TYPE_SELL_STOP);
               // Adicionar gd_StopLoss e gd_TakeProfit
               if(Sell_opened())
                  ClosePosType(POSITION_TYPE_SELL);

               //
               if(_Stop>0)
                  gd_StopLoss=NormalizeDouble(_Stop,gi_Digits);
               else
                  gd_StopLoss=0;
               //
               if(_TakeProfit>0)
                  gd_TakeProfit=NormalizeDouble(_TakeProfit,gi_Digits);
               else
                  gd_TakeProfit=0;

               //
               if(UsarRompimento)
                  OpenBuyStop(BarrasVerificarEntrada,Dist_Rompimento,CalcLotes(),gd_StopLoss,gd_TakeProfit);
               else
                 {
                  //
                  if(_Stop>0)
                     gd_StopLoss=NormalizeDouble(bid-_Stop*gd_Ponto,gi_Digits);
                  else
                     gd_StopLoss=0;
                  //
                  if(_TakeProfit>0)
                     gd_TakeProfit=NormalizeDouble(ask+_TakeProfit*gd_Ponto,gi_Digits);
                  else
                     gd_TakeProfit=0;
                  //
                  mytrade.Buy(CalcLotes(),original_symbol,0,gd_StopLoss,gd_TakeProfit,"EA MOD - COMPRADO_MG_"+IntegerToString(Magic_Number)); //chng_V02: _Symbol For Base Symbol
                  trade_ticket=mytrade.ResultOrder();
                 }
              } // End By Condition

            //------------------------------------------------------------------

            if(SellSignal() && (!Sell_opened())) // Open short position
              {
               DeleteOrders(ORDER_TYPE_BUY_STOP);
               // Adicionar gd_StopLoss e gd_TakeProfit
               if(Buy_opened())
                  ClosePosType(POSITION_TYPE_BUY);

               //
               if(_Stop>0)
                  gd_StopLoss=NormalizeDouble(_Stop,gi_Digits);
               else
                  gd_StopLoss=0;
               //
               if(_TakeProfit>0)
                  gd_TakeProfit=NormalizeDouble(_TakeProfit,gi_Digits);
               else
                  gd_TakeProfit=0;
               //

               if(UsarRompimento)
                  OpenSellStop(BarrasVerificarEntrada,Dist_Rompimento,CalcLotes(),gd_StopLoss,gd_TakeProfit);
               else
                 {
                  //
                  if(_Stop>0)
                     gd_StopLoss=NormalizeDouble(ask+_Stop*gd_Ponto,gi_Digits);
                  else
                     gd_StopLoss=0;
                  //
                  if(_TakeProfit>0)
                     gd_TakeProfit=NormalizeDouble(bid-_TakeProfit*gd_Ponto,gi_Digits);
                  else
                     gd_TakeProfit=0;
                  //
                  mytrade.Sell(CalcLotes(),original_symbol,0,gd_StopLoss,gd_TakeProfit,"EA MOD - VENDIDO_MG_"+IntegerToString(Magic_Number)); //chng_V02: _Symbol For Base Symbol
                  trade_ticket=mytrade.ResultOrder();
                 }

              } // End Sell COndition
            //------------------------------------------------------------------
           }   //Fim NewBar
        }     //Fim TimerPausa

      CheckClosePosition(); //Fechar no candle amarelo ou candle contrario

                            // STOP Movel pelo STOP ATR + vz*ATR
      if(Use_STOP_ATR==true && PosicaoAberta())
         Stop_ATR();

      if(UseTrailingStop)
         TrailingStop(TrailingStop,MinimumProfit,Step);
      //chng_V02: _Symbol For Base Symbol
      if(UsarRealizParc)
         RealizacaoParcial();

      //BrakeEven
      if(UseBreakEven==true && PosicaoAberta())
         BreakEven(original_symbol,UseBreakEven,PointBreakEven,PointProfit); //chng_V02: _Symbol For Base Symbol

      if(PosicaoAberta())
        {
         //myposition.SelectByTicket(trade_ticket);
         myposition.SelectByMagic(original_symbol,Magic_Number);
         HLineCreate(0,"Abertura",0,myposition.PriceOpen(),clrWhite,STYLE_DOT,1,false,false,true,0);
         HLineCreate(0,"Stop Loss",0,myposition.StopLoss(),clrRed,STYLE_DOT,1,false,false,true,0);
         HLineCreate(0,"Take Profit",0,myposition.TakeProfit(),clrLime,STYLE_DOT,1,false,false,true,0);

         if(Buy_opened())
            posicao_atual="COMPRADO EM: "+DoubleToString(myposition.PriceOpen(),mysymbol.Digits());
         else if(Sell_opened())
            posicao_atual="VENDIDO EM: "+DoubleToString(myposition.PriceOpen(),mysymbol.Digits());
        }
      else
        {
         HLineDelete(0,"Abertura");
         HLineDelete(0,"Stop Loss");
         HLineDelete(0,"Take Profit");
         posicao_atual="ZERADO";
        }
     } // Fim gb_TradeOn

//
//  Comentarios();
//
   return;
  } // fim OnTick
//+------------------------------------------------------------------+
//+-------------ROTINAS----------------------------------------------+
bool Buy_opened()
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
bool Sell_opened()
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_SELL)
         return(true); //It is a Buy
     }
   return (false);
  }
//+------------------------------------------------------------------+
//| Buy conditions                                                   |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   bool b_signal;
   if(barras_entry<=1)
      b_signal=gCP_iVelas.CorVela(gi_BarraTrade)==0.0 && gCP_iVelas.CorVela(gi_BarraTrade+1)!=0.0 && gCP_iVelas.CorVela(gi_BarraTrade+1)!=EMPTY_VALUE;
   else
     {
      b_signal=true;
      for(int i=0; i<barras_entry; i++)
        {
         b_signal=b_signal && iClose(Symbol(),PERIOD_CURRENT,gi_BarraTrade+i)>iOpen(Symbol(),PERIOD_CURRENT,gi_BarraTrade+i) && gCP_iVelas.CorVela(gi_BarraTrade+i)==0.0;
        }
      b_signal=b_signal && gCP_iVelas.CorVela(gi_BarraTrade+barras_entry)!=0.0;
     }
//
   if(Filtro_ADX)
      b_signal=b_signal && (gd_abufferADX[0]>ADX_min);
//
   if(Use_TEND)
     {
      if(Tendencia()=="COMPRA")
         b_signal=b_signal || (gCP_iVelasTend.CorVela(0)==0 && gCP_iVelasTend.CorVela(1)!=0 && gCP_iVelasTend.CorVela(1)!=EMPTY_VALUE);
      else
         b_signal=false;
     }
//
   if(UsarMACD)
      b_signal=b_signal && macd.Main(gi_BarraTrade)>macd.Signal(gi_BarraTrade);

   return b_signal;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   bool s_signal;
   if(barras_entry<=1)
      s_signal=gCP_iVelas.CorVela(gi_BarraTrade)==1.0 && gCP_iVelas.CorVela(gi_BarraTrade+1)!=1.0 && gCP_iVelas.CorVela(gi_BarraTrade+1)!=EMPTY_VALUE;
   else
     {
      s_signal=true;
      for(int i=0; i<barras_entry; i++)
        {
         s_signal=s_signal && iClose(Symbol(),PERIOD_CURRENT,gi_BarraTrade+i)<iOpen(Symbol(),PERIOD_CURRENT,gi_BarraTrade+i) && gCP_iVelas.CorVela(gi_BarraTrade+i)==1.0;
        }
      s_signal=s_signal && gCP_iVelas.CorVela(gi_BarraTrade+barras_entry)!=1.0;
     }
//
   if(Filtro_ADX)
      s_signal=s_signal && (gd_abufferADX[0]>ADX_min);
//
   if(Use_TEND)
     {
      if(Tendencia()=="VENDA")
         s_signal=s_signal || (gCP_iVelasTend.CorVela(0)==1 && gCP_iVelasTend.CorVela(1)!=1 && gCP_iVelasTend.CorVela(1)!=EMPTY_VALUE);
      else
         s_signal=false;
     }
   if(UsarMACD)
      s_signal=s_signal && macd.Main(gi_BarraTrade)<macd.Signal(gi_BarraTrade);
//
   return s_signal;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void CheckClosePosition()
  {
   if(Buy_opened() && (gCP_iVelas.CorVela(1)==2.0 && fechar_neutro || gCP_iVelas.CorVela(1)==1.0))
      ClosePosType(POSITION_TYPE_BUY);
   if(Sell_opened() && (gCP_iVelas.CorVela(1)==2.0 && fechar_neutro || gCP_iVelas.CorVela(1)==0.0))
      ClosePosType(POSITION_TYPE_SELL);
  }
// Tendência
string Tendencia()
  {
   string s_t="";
//
   if(gCP_iVelasTend.CorVela(0)==0)
      s_t="COMPRA";
   else if(gCP_iVelasTend.CorVela(0)==1)
      s_t="VENDA";
   else
      s_t="NEUTRO";
//
   return (s_t);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void Comentarios()
  {
   string s_usar_adx,s_usar_tend;
//
   if(Filtro_ADX)
      s_usar_adx="SIM";
   else
      s_usar_adx="NÃO";
//
   if(Use_TEND)
      s_usar_tend="TENDÊNCIA: "+Tendencia();
   else
      s_usar_tend="";
//
   string s_adx;
   if(Filtro_ADX)
     {
      s_adx=s_usar_tend+" "+"FILTRO ADX: "+s_usar_adx+" ADX M1: "+DoubleToString(gd_abufferADX[0],2)+"\n"+
            " "+"ADX+ :"+DoubleToString(gd_abufferADX_P[0],2)+" "+"ADX- :"+DoubleToString(gd_abufferADX_N[0],2);
     }
   else
     {
      s_adx=s_usar_tend+" "+"FILTRO ADX: "+s_usar_adx;
     }
//
   string s_coment=""+"\n"+" RESULTADO DO DIA: "+DoubleToString(gd_LucroTotal,2)+"\n"+s_adx+"\n";
   Comment(s_coment);
  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   bool b_get,i_atr,i_adx;
   if(Use_STOP_ATR)
     {
      i_atr=CopyBuffer(gi_HandleStopATR,0,0,3,gd_abufferStopATR_Upper)<=0 || 
            CopyBuffer(gi_HandleStopATR,1,0,3,gd_abufferStopATR_Lower)<=0;
     }
   else
      i_atr=false;
   if(Filtro_ADX)
     {
      i_adx=CopyBuffer(gi_HandleADX,0,0,3,gd_abufferADX)<=0 || 
            CopyBuffer(gi_HandleADX, 1, 0, 3, gd_abufferADX_P) <= 0 ||
            CopyBuffer(gi_HandleADX, 2, 0, 3, gd_abufferADX_N) <= 0;
     }
   else
      i_adx=false;

   b_get=CopyClose(Symbol(),period_velas,0,3,gd_aClose)<=0;
   if(b_get)
      Print("Erro em obter fechamentos gd_aClose");
   if(i_atr)
      Print("Erro em obter ATR buffer");
   if(i_adx)
      Print("Erro em obter ADX buffer");

   b_get=b_get || i_atr || i_adx;
   return (b_get);
  }
//+------------------------------------------------------------------+
//| Trailing stop (points)                                           |
//+------------------------------------------------------------------+
void TrailingStop(int pTrailPoints,int pMinProfit=0,int pStep=10)
  {

   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number && pTrailPoints>0)
        {

         double currentTakeProfit=myposition.TakeProfit();
         long posType=myposition.PositionType();
         double currentStop=myposition.StopLoss();
         double openPrice=myposition.PriceOpen();
         double point=mysymbol.Point();
         int digits=mysymbol.Digits();
         if(pStep<10)
            pStep=10;
         double step=pStep*point;

         double minProfit = pMinProfit * point;
         double trailStop = pTrailPoints * point;
         currentStop=NormalizeDouble(currentStop,digits);
         currentTakeProfit=NormalizeDouble(currentTakeProfit,digits);
         double trailStopPrice;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            trailStopPrice = bid - trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice, digits);
            currentProfit=bid-openPrice;

            if(trailStopPrice>currentStop+step && currentProfit>=minProfit)
              {
               mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
              }
           }
         else if(posType==POSITION_TYPE_SELL)
           {
            trailStopPrice = ask + trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice, digits);
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
//+------------------------------------------------------------------+
bool PosicaoAberta()
  {
   if(myposition.SelectByMagic(original_symbol,Magic_Number)==true)
      return (myposition.PositionType() == POSITION_TYPE_BUY || myposition.PositionType() == POSITION_TYPE_SELL);
   else
      return (false);
  }
//+------------------------------------------------------------------+
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
//| Select total orders in history and get total pending orders      |
//| (as shown within the COrderInfo class section).                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
int Expiration(int barras)
  {
   return ((int)(TimeTradeServer() + barras * PeriodSeconds(period_velas)));
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void OpenBuyStop(int barras,int distancia,double pd_Lotes,double stoploss,double takeprofit)
  {
   double oldprice=0.0;
   double bprice=HighestHigh(Symbol(),period_velas,barras,1)+distancia*gd_Ponto;
   oldprice=PriceLastStopOrder(ORDER_TYPE_BUY_STOP);
   if(oldprice==-1 || bprice<oldprice) // No order or New price is better
     {
      DeleteOrders(ORDER_TYPE_BUY_STOP);
      double mprice = NormalizeDouble(bprice, _Digits);
      double stloss = NormalizeDouble(bprice - stoploss * gd_Ponto, _Digits);
      double tprofit= NormalizeDouble(bprice+takeprofit * gd_Ponto,_Digits);
      if(bprice>mysymbol.Ask())
        {
         if(mytrade.BuyStop(pd_Lotes,mprice,original_symbol,stloss,tprofit,0,0,"EA MOD - COMPRADO_MG_"+IntegerToString(Magic_Number))) //chng_V02: _Symbol For Base Symbol
           {
            trade_ticket=mytrade.ResultOrder();
            return;
           }
         else
           {
            Print("Erro Ordem Buy Stop:",mytrade.RequestVolume(),", sl:",mytrade.RequestSL(),", tp:",mytrade.RequestTP(),", price:",mytrade.RequestPrice()," Erro:",mytrade.ResultRetcodeDescription());
            return;
           }
        }
      else
        {
         mytrade.Buy(pd_Lotes,original_symbol,0,stloss,tprofit,"");
         trade_ticket=mytrade.ResultOrder();
        } //chng_V02: _Symbol For Base Symbol
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void OpenSellStop(int barras,int distancia,double pd_Lotes,double stoploss,double takeprofit)
  {
   double bprice=LowestLow(Symbol(),period_velas,barras,1)-distancia*gd_Ponto; //For Renko Chart
   double oldprice=0.0;
   oldprice=PriceLastStopOrder(ORDER_TYPE_SELL_STOP);
   if(oldprice==-1 || bprice>oldprice) // No order or New price is better
     {
      DeleteOrders(ORDER_TYPE_SELL_STOP);
      double mprice = NormalizeDouble(bprice, _Digits);
      double stloss = NormalizeDouble(bprice + stoploss * gd_Ponto, _Digits);
      double tprofit= NormalizeDouble(bprice-takeprofit * gd_Ponto,_Digits);
      string comentario="Enviada Ordem SellStop";
      if(bprice<mysymbol.Bid())
        {
         if(mytrade.SellStop(pd_Lotes,mprice,original_symbol,stloss,tprofit,0,0,"EA MOD - VENDIDO_MG_"+IntegerToString(Magic_Number))) //chng_V02: _Symbol For Base Symbol
           {
            trade_ticket=mytrade.ResultOrder();
            return;
           }
         else
           {
            Print("Erro Ordem Sell Stop:",mytrade.RequestVolume(),", sl:",mytrade.RequestSL(),", tp:",mytrade.RequestTP(),", price:",mytrade.RequestPrice()," Erro:",mytrade.ResultRetcodeDescription());
            return;
           }
        }
      else
        {
         mytrade.Sell(pd_Lotes,original_symbol,0,stloss,tprofit,"");
         trade_ticket=mytrade.ResultOrder();
        } //chng_V02: _Symbol For Base Symbol
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Highest High & Lowest Low                                        |
//+------------------------------------------------------------------+
double HighestHigh(string pSymbol,ENUM_TIMEFRAMES pPeriod,int pBars,int pStart=0)
  {
   double high[];
   ArraySetAsSeries(high,true);

   int copied= CopyHigh(pSymbol,pPeriod,pStart,pBars,high);
   if(copied == -1)
      return (copied);

   int maxIdx=ArrayMaximum(high);
   double highest=high[maxIdx];

   return (highest);
  }
//
//
double LowestLow(string pSymbol,ENUM_TIMEFRAMES pPeriod,int pBars,int pStart=0)
  {
   double low[];
   ArraySetAsSeries(low,true);

   int copied= CopyLow(pSymbol,pPeriod,pStart,pBars,low);
   if(copied == -1)
      return (copied);

   int minIdx=ArrayMinimum(low);
   double lowest=low[minIdx];

   return (lowest);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RealizacaoParcial()
  {
   double currentProfit,currentStop,preco;
   double vol_init;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
        {
         currentStop=myposition.StopLoss();
         preco=myposition.PriceOpen();
         if(myposition.PositionType()==POSITION_TYPE_BUY)
           {
            vol_init=CalcLotes();
            currentProfit=bid-preco;
            if(currentProfit>=DistanceRealizeParcial*_Point && myposition.Volume()>=vol_init && vol_init>mysymbol.LotsMin())
              {
               if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
                  mytrade.PositionClosePartial(myposition.Ticket(),LotesParcial,deviation_points);
               else
                  mytrade.Sell(LotesParcial,original_symbol,0,0,0,NULL);
               Print("Venda Saída Parcial : ");
              }
           }

         if(myposition.PositionType()==POSITION_TYPE_SELL)
           {

            vol_init=CalcLotes();
            currentProfit=preco-ask;

            if(currentProfit>=DistanceRealizeParcial*_Point && myposition.Volume()>=vol_init && vol_init>mysymbol.LotsMin())
              {
               if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
                  mytrade.PositionClosePartial(myposition.Ticket(),LotesParcial,deviation_points);
               else
                  mytrade.Buy(LotesParcial,original_symbol,0,0,0,NULL);
               Print("Compra Saída Parcial : ");
              }
           }
        } //Fim myposition Select
     }   //Fim for
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double PriceLastStopOrder(const ENUM_ORDER_TYPE pending_order_type)
  {
   datetime last_time= 0;
   double last_price = -1.0;
   for(int i = OrdersTotal() - 1; i >= 0; i--) // returns the number of current orders
      if(myorder.SelectByIndex(i))              // selects the pending order by index for further access to its properties
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
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void DeleteOrders(const ENUM_ORDER_TYPE order_type)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--) // returns the number of current orders
      if(myorder.SelectByIndex(i))              // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void Stop_ATR()
  {
   double stp_compra,stp_venda;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number)
        {
         if(myposition.PositionType()==POSITION_TYPE_BUY)
           {
            double curSTP=myposition.StopLoss();
            double curTake=myposition.TakeProfit();
            if((gd_aClose[0]>=gd_abufferStopATR_Upper[1]) && gd_abufferStopATR_Upper[1]!=EMPTY_VALUE)
              {
               stp_compra=NormalizeDouble(MathRound(gd_abufferStopATR_Upper[1]/ticksize)*ticksize-dist_STOP_ATR*gd_Ponto,gi_Digits);
               if(stp_compra>curSTP)
                  mytrade.PositionModify(myposition.Ticket(),stp_compra,curTake);
              }
           }

         if(myposition.PositionType()==POSITION_TYPE_SELL)
           {
            double curSTP=myposition.StopLoss();
            double curTake=myposition.TakeProfit();
            if((gd_aClose[0]<=gd_abufferStopATR_Lower[1]) && gd_abufferStopATR_Lower[1]!=EMPTY_VALUE)
              {
               stp_venda=NormalizeDouble(MathRound(gd_abufferStopATR_Lower[1]/ticksize)*ticksize+dist_STOP_ATR*gd_Ponto,gi_Digits);
               if(stp_venda<curSTP || curSTP==0)
                  mytrade.PositionModify(myposition.Ticket(),stp_venda,curTake);
              }
           }
        } //Fim if PositionSelect

     } //Fim for
  }
//+------------------------------------------------------------------+
//| Break even stop                                                  |
//+------------------------------------------------------------------+
//Break Even

void BreakEven(string pSymbol,bool usarbreak,double &pBreakEven[],double &pLockProfit[])
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && usarbreak==true)
        {

         long posType=myposition.PositionType();
         long posTicket=myposition.Ticket();
         double currentSL = myposition.StopLoss();
         double openPrice = myposition.PriceOpen();
         double currentTP = myposition.TakeProfit();
         double breakEvenStop;
         double currentProfit;
         double ponto=SymbolInfoDouble(pSymbol,SYMBOL_POINT);
         double bid,ask;

         if(posType==POSITION_TYPE_BUY)
           {
            bid=SymbolInfoDouble(pSymbol,SYMBOL_BID);
            currentProfit=bid-openPrice;
            //Break Even 0 a 3
            for(int k=0; k<4; k++)
              {
               if(currentProfit>=pBreakEven[k] *ponto && currentProfit<pBreakEven[k+1] *ponto)
                 {
                  breakEvenStop=openPrice+pLockProfit[k] *ponto;
                  if(currentSL<breakEvenStop || currentSL==0)
                    {
                     Print("Break even stop:");
                     mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                    }
                 }
              }
            //----------------------
            //Break Even 4
            if(currentProfit>=pBreakEven[4] *ponto)
              {
               breakEvenStop=openPrice+pLockProfit[4] *ponto;
               if(currentSL<breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop:");
                  mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                 }
              }
           }
         //----------------------

         //----------------------

         if(posType==POSITION_TYPE_SELL)
           {
            ask=SymbolInfoDouble(pSymbol,SYMBOL_ASK);
            currentProfit=openPrice-ask;
            //Break Even 0 a 3
            for(int k=0; k<4; k++)
              {
               if(currentProfit>=pBreakEven[k] *ponto && currentProfit<pBreakEven[k+1] *ponto)
                 {
                  breakEvenStop=openPrice-pLockProfit[k] *ponto;
                  if(currentSL>breakEvenStop || currentSL==0)
                    {
                     Print("Break even stop:");
                     mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                    }
                 }
              }
            //----------------------
            //Break Even 4
            if(currentProfit>=pBreakEven[4] *ponto)
              {
               breakEvenStop=openPrice-pLockProfit[4] *ponto;
               if(currentSL>breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop:");
                  mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                 }
              }
            //----------------------
           }

        } //Fim Position Select

     } //Fim for
  }
//====================================================

//TESTE DE ORDENS FOK, IOC E RETURN

//| Checks if the specified filling mode is allowed                  |
//+------------------------------------------------------------------+
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes
   int filling=mysymbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed
   return ((filling & fill_type) == fill_type);
  }
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
//+------------------------------------------------------------------+
//| Criar a linha horizontal                                         |
//+------------------------------------------------------------------+
bool HLineCreate(const long chart_ID = 0,                   // ID de gráfico
                 const string name = "HLine",               // nome da linha
                 const int sub_window = 0,                  // índice da sub-janela
                 double price = 0,                          // line price
                 const color clr = clrSilver,               // cor da linha
                 const ENUM_LINE_STYLE style = STYLE_SOLID, // estilo da linha
                 const int width = 1,                       // largura da linha
                 const bool back = false,                   // no fundo
                 const bool selection = true,               // destaque para mover
                 const bool hidden = true,                  //ocultar na lista de objetos
                 const long z_order = 0)                    // prioridade para clique do mouse
  {
//--- se o preço não está definido, defina-o no atual nível de preço Bid
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- redefine o valor de erro
   ResetLastError();
//--- criar um linha horizontal
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": falha ao criar um linha horizontal! Código de erro = ",GetLastError());
      return (false);
     }
//--- definir cor da linha
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- definir o estilo de exibição da linha
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- definir a largura da linha
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- exibir em primeiro plano (false) ou fundo (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- habilitar (true) ou desabilitar (false) o modo do movimento da seta com o mouse
//--- ao criar um objeto gráfico usando a função ObjectCreate, o objeto não pode ser
//--- destacado e movimentado por padrão. Dentro deste método, o parâmetro de seleção
//--- é verdade por padrão, tornando possível destacar e mover o objeto
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- ocultar (true) ou exibir (false) o nome do objeto gráfico na lista de objeto
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- definir a prioridade para receber o evento com um clique do mouse no gráfico
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- sucesso na execução
   return (true);
  }
//+------------------------------------------------------------------+
//| Excluir uma linha horizontal                                     |
//+------------------------------------------------------------------+
bool HLineDelete(const long chart_ID = 0,     // ID do gráfico
                 const string name = "HLine") // nome da linha
  {
//--- redefine o valor de erro
   ResetLastError();
//--- excluir uma linha horizontal
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": falha ao Excluir um linha horizontal! Código de erro = ",GetLastError());
      return (false);
     }
//--- sucesso na execução
   return (true);
  }
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
   uint total_deals=HistoryDealsTotal();
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

//------------------------------ Painel-----------------------------------

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CREATING THE EDIT OBJECT                                         |
//+------------------------------------------------------------------+
void CreateEdit(long chart_id,           // chart id
                int sub_window,          // (sub)window number
                string name,             // object name
                string text,             // displayed text
                ENUM_BASE_CORNER corner, // chart corner
                string font_name,        // font
                int font_size,           // font size
                color font_color,        // font color
                int x_size,              // width
                int y_size,              // height
                int x_distance,          // X-coordinate
                int y_distance,          // Y-coordinate
                long z_order,            // Z-order
                color background_color,  // background color
                bool read_only)          // Read Only flag
  {
// If the object has been created successfully...
   if(ObjectCreate(chart_id,name,OBJ_EDIT,sub_window,0,0))
     {
      // ...set its properties
      ObjectSetString(chart_id, name, OBJPROP_TEXT, text);                 // displayed text
      ObjectSetInteger(chart_id, name, OBJPROP_CORNER, corner);            // set the chart corner
      ObjectSetString(chart_id, name, OBJPROP_FONT, font_name);            // set the font
      ObjectSetInteger(chart_id, name, OBJPROP_FONTSIZE, font_size);       // set the font size
      ObjectSetInteger(chart_id, name, OBJPROP_COLOR, font_color);         // font color
      ObjectSetInteger(chart_id, name, OBJPROP_BGCOLOR, background_color); // background color
      ObjectSetInteger(chart_id, name, OBJPROP_XSIZE, x_size);             // width
      ObjectSetInteger(chart_id, name, OBJPROP_YSIZE, y_size);             // height
      ObjectSetInteger(chart_id, name, OBJPROP_XDISTANCE, x_distance);     // set the X-coordinate
      ObjectSetInteger(chart_id, name, OBJPROP_YDISTANCE, y_distance);     // set the Y-coordinate
      ObjectSetInteger(chart_id, name, OBJPROP_SELECTABLE, false);         // cannot select the object if FALSE
      ObjectSetInteger(chart_id, name, OBJPROP_ZORDER, z_order);           // Z-order of the object
      ObjectSetInteger(chart_id, name, OBJPROP_READONLY, read_only);       // Read Only
      ObjectSetInteger(chart_id, name, OBJPROP_ALIGN, ALIGN_LEFT);         // align left
      ObjectSetString(chart_id, name, OBJPROP_TOOLTIP, "\n");              // no tooltip if "\n"
     }
  }
//+------------------------------------------------------------------+
//| CREATING THE LABEL OBJECT                                        |
//+------------------------------------------------------------------+
void CreateLabel(long chart_id,            // chart id
                 int sub_window,           // (sub)window number
                 string name,              // object name
                 string text,              // displayed text
                 ENUM_ANCHOR_POINT anchor, // anchor point
                 ENUM_BASE_CORNER corner,  // chart corner
                 string font_name,         // font
                 int font_size,            // font size
                 color font_color,         // font color
                 int x_distance,           // X-coordinate
                 int y_distance,           // Y-coordinate
                 long z_order)             // Z-order
  {
// If the object has been created successfully...
   if(ObjectCreate(chart_id,name,OBJ_LABEL,sub_window,0,0))
     {
      // ...set its properties
      ObjectSetString(chart_id, name, OBJPROP_TEXT, text);             // displayed text
      ObjectSetString(chart_id, name, OBJPROP_FONT, font_name);        // set the font
      ObjectSetInteger(chart_id, name, OBJPROP_COLOR, font_color);     // set the font color
      ObjectSetInteger(chart_id, name, OBJPROP_ANCHOR, anchor);        // set the anchor point
      ObjectSetInteger(chart_id, name, OBJPROP_CORNER, corner);        // set the chart corner
      ObjectSetInteger(chart_id, name, OBJPROP_FONTSIZE, font_size);   // set the font size
      ObjectSetInteger(chart_id, name, OBJPROP_XDISTANCE, x_distance); // set the X-coordinate
      ObjectSetInteger(chart_id, name, OBJPROP_YDISTANCE, y_distance); // set the Y-coordinate
      ObjectSetInteger(chart_id, name, OBJPROP_SELECTABLE, false);     // cannot select the object if FALSE
      ObjectSetInteger(chart_id, name, OBJPROP_ZORDER, z_order);       // Z-order of the object
      ObjectSetString(chart_id, name, OBJPROP_TOOLTIP, "\n");          // no tooltip if "\n"
     }
  }
//+------------------------------------------------------------------+
//| DELETING THE OBJECT BY NAME                                      |
//+------------------------------------------------------------------+
void DeleteObjectByName(string name)
  {
   int sub_window = 0; // Returns the number of the subwindow where the object is located
   bool res = false;   // Result following an attempt to delete the object
//--- Find the object by name
   sub_window=ObjectFind(ChartID(),name);
//---
   if(sub_window>=0) // If it has been found,..
     {
      res=ObjectDelete(ChartID(),name); // ...delete it
      //---
      // If an error occurred when deleting the object, print the relevant message
      if(!res)
         Print("Error deleting the object: ("+IntegerToString(GetLastError())+") ");
     }
  }
//+------------------------------------------------------------------+
//| GETTING POSITION PROPERTIES                                      |
//+------------------------------------------------------------------+
void GetPositionProperties()
  {
   pos_resultado=DoubleToString(gd_LucroTotal,2);
   pos_posicao=posicao_atual;
   if(timerPausa)
      pos_horario="EM PAUSA";
   else if(timerOn && !timerPausa)
      pos_horario="ATIVADO";
   else
      pos_horario="INOPERANTE";

//---
   SetInfoPanel(); // Set/update the info panel
  }
//+------------------------------------------------------------------+
//| SETTING THE INFO PANEL                                           |
//|------------------------------------------------------------------+
void SetInfoPanel()
  {
   int y_bg = 18;                                // Y-coordinate for the background and header
   int y_property = 32;                          // Y-coordinate for the list of properties and their values
   int line_height = 18;                         // Line height
//---
   int font_size = 8;                            // Font size
   string font_name = "Arial";                   // Font
   color font_color = clrBlack;                  // Font color
//---
   ENUM_ANCHOR_POINT anchor = ANCHOR_LEFT_UPPER; // Anchor point in the top left corner
   ENUM_BASE_CORNER corner = CORNER_LEFT_UPPER;  // Origin of coordinates in the top left corner of the chart
//--- X-coordinates
   int x_first_column = 20;                      // First column (names of properties)
   int x_second_column = 113;                    // Second column (values of properties)
//--- Array of Y-coordinates for the names of position properties and their values
   int y_prop_array[INFOPANEL_SIZE]={0};
//--- Fill the array with coordinates for each line on the info panel
   for(int i=0; i<INFOPANEL_SIZE; i++)
     {
      if(i==0)
         y_prop_array[i]=y_property;
      else
         y_prop_array[i]=y_property+line_height*i;
     }
//--- Background of the info panel
   CreateEdit(0,0,"InfoPanelBackground","",corner,font_name,8,clrBlack,252,72,10,y_bg,0,clrWhite,true);
//--- Header of the info panel
   CreateEdit(0,0,"InfoPanelHeader",MQLInfoString(MQL_PROGRAM_NAME),corner,font_name,8,clrBlack,252,6,10,y_bg,1,clrBlack,true);
//--- List of the names of position properties and their values
//    Property name
   CreateLabel(0,0,pos_prop_names[0],"RESULTADO DIÁRIO :  $",anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[0],2);
//    Property value
   CreateLabel(0,0,pos_prop_values[0],GetPropertyValue(0),anchor,corner,font_name,font_size,font_color,x_second_column+30,y_prop_array[0],2);
//---

   CreateLabel(0,0,pos_prop_names[1],"POSIÇÃO: ",anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[1],2);
   CreateLabel(0,0,pos_prop_values[1],GetPropertyValue(1),anchor,corner,font_name,font_size,font_color,x_second_column,y_prop_array[1],2);
   CreateLabel(0,0,pos_prop_names[2],"STATUS: ",anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[2],2);
   CreateLabel(0,0,pos_prop_values[2],GetPropertyValue(2),anchor,corner,font_name,font_size,font_color,x_second_column,y_prop_array[2],2);

//---

//---
   ChartRedraw(); // Redraw the chart
  }
//+------------------------------------------------------------------+
//| DELETING THE INFO PANEL                                          |
//+------------------------------------------------------------------+
void DeleteInfoPanel()
  {
   DeleteObjectByName("InfoPanelBackground"); // Delete the panel background
   DeleteObjectByName("InfoPanelHeader");     // Delete the panel header
//--- Delete position properties and their values
   for(int i=0; i<INFOPANEL_SIZE; i++)
     {
      DeleteObjectByName(pos_prop_names[i]);  // Delete the property
      DeleteObjectByName(pos_prop_values[i]); // Delete the value
     }
//---
   ChartRedraw(); // Redraw the chart
  }
//+------------------------------------------------------------------+
//| RETURNING THE STRING WITH POSITION PROPERTY VALUE                |
//+------------------------------------------------------------------+
string GetPropertyValue(int number)
  {
//--- Sign indicating the lack of an open position or a certain property
//    E.g. the lack of a comment, Stop Loss or Take Profit
   string empty="-";

   switch(number)
     {
      case 0:
         return (DoubleToString(gd_LucroTotal, 2));
         break;
      case 1:
         return (posicao_atual);
         break;
      case 2:
         return (pos_horario);
         break;

      default:
         return (empty);
     }
  }
//+------------------------------------------------------------------+
double CalcLotes()
  {
   double lotes;
   double lot_step=mysymbol.LotsStep();
   double cont_size=mysymbol.ContractSize();

   if(tipolote==Lote_Fixo)
      lotes=Lot;
   else
     {
      lotes = (mysymbol.TickSize() / mysymbol.TickValue()) * (cont_size * porc_Lot * 0.01 * myaccount.Equity() / _Stop);
      lotes = MathMax(MathFloor(lotes / lot_step) * lot_step, mysymbol.LotsMin());
     }

   return lotes;
  }
//+------------------------------------------------------------------+
