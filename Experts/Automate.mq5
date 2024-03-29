//+------------------------------------------------------------------+
//|                                   SuperSetups - Order Management |
//|                                                   Newton Linchen |
//|                                        http://www.linchen.com.br |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert information                                               |
//+------------------------------------------------------------------+

#property copyright "linchen.com.br"
#property link      "http://www.linchen.com.br"
#property description "Automate"
#property version   "1.1"
#property tester_file "AUTOMATE.csv" // O nome do arquivo deve esta correto nesta property.

/*
 Super Setups
 http://www.linchen.com.br

 No commercial use permitted.
*/

// Trade
#include <Trade\Trade.mqh>
CTrade Trade;

#include <Trade\TerminalInfo.mqh>
CTerminalInfo TerminalInfo;

// Price
#include "Mql5Book\Price.mqh"
CBars Price;

// Money management
#include "Mql5Book\MoneyManagement.mqh"

// Trailing stops
#include "TrailingStops.mqh"
CQTV_Trailing Trail;

// Timer
#include "Mql5Book\Timer.mqh"
CTimer Timer;
CNewBar NewBar;

// SymbolInfo
#include <Trade\SymbolInfo.mqh>
//--- object for receiving symbol settings
CSymbolInfo symbol_info;

// Indicators
#include "Mql5Book\Indicators.mqh"

// Pending
#include "Mql5Book\Pending.mqh"
CPending Pending;

//DealInfo
#include <Trade\DealInfo.mqh>
CDealInfo DealInfo;

// Rotinas para acesso a internet
#include "Mql5Book\internetlib.mqh"

#include "Mql5Book\Classes.mqh"

// Manipulação da estratégia
#include <Strings\String.mqh>
CString StrM;

//Statistical Standard Desviation
#include <Math\Stat\Stat.mqh>

//struct STradeTransacions
//   {
//
//      bool     OrdExec_triggered;   // Identifica o status da Deal ( TRIGGERED/ CONSUMED )
//      ulong    OrdExec_OrderNumber; // Numero da ordem executada
//      string   OrdExec_type;        // 2 types ENUM_DEAL_TYPE ( DEAL_TYPE_BUY or DEAL_TYPE_SELL )
//      double   OrdExec_Volume;      // Quantidade de contratos executados
//      double   OrdExec_Price;       // Preço de execução da transação/ ordem
//   };


//+------------------------------------------------------------------+
//| CUSTOM ENUMERATORS                                               |
//| Create ENUM                                                      |
//+------------------------------------------------------------------+

//Exemplo de como transformar integer em ENUM e depois converter de ENUM para String
//Print( "AccountInfo/ ACCOUNT_TRADE_MODE: "+ EnumToString((ENUM_ACCOUNT_TRADE_MODE) AccountInfoInteger(ACCOUNT_TRADE_MODE)) );  //Demonstracao/ Torneio/ Real

//+------------------------------------------------------------------+
//| Input variables                                                  |
//+------------------------------------------------------------------+
// Ajustado o tipo dos dados contendo valores para o tipo "double" em virtude do dolar ter variacao em centavos "0,5"
input int MagicNumber=7172737; //MagicNumber, numero de identificacao do EA (ExpertAdvisor). Pode ser personalizado, guarde o numero.

sinput string lineGeneral;    // -------------------
sinput string General1;       // Parametros Gerais

                              // Overall inputs
//input double CheckPoint1_Distance = 100;  // A que distancia do ponto de entrada deve ser inserida a ordem.
//input bool Usar_Simbolo_Atual=false;  //Utilizar o ativo selecionado no grafico atual

input bool Atualizar_Analises_Automaticamente=true; //Buscar automaticamente o arquivo de analises

input ulong Slippage=50;
input ulong Dia_MidMonth=15;          // Dia para dividir o mes. Ponto central do mes
                                      //input bool TradeOnNewBar = false;

sinput string STOP_to_ENTRY;             // Stop to Entry after Target hit?
input bool UseStop_MoveToEntry=true;  // Mover o Stop para o valor de entrada apos target alcancado.

sinput string MM;                       // Money Management
input bool UseMoneyManagement = false;  // Usar variacao da porcentagem do capital em risco?
input double RiskPercent = 0;           // Porcentagem do capital em risco
input double FixedVolume = 5;           // Valor ou numero de contratos fixos, por trade

sinput string Daily_Limit_Gain_Loss_Eq; // Daily Limit de Ganhos e Perdas (EQUITY)
input bool UseDailyLimit_Gain_Equity=false; //EQUITY Usar o controle limite diario de ganhos
input double DailyLimitGain_Equity;     //EQUITY Informe o limite financeiro diario de ganhos (R$) (+)

input bool UseDailyLimit_Loss_Equity=false; //EQUITY Usar o controle limite diario de perdas
input double DailyLimitLoss_Equity;     //EQUITY Informe o limite diario de perdas (R$) (-)

sinput string Daily_Limit_Gain_e_Loss;    // Daily Limit de Ganhos e Perdas (BALANCE)
input bool UseDailyLimit_Gain = false;  //BALANCE Usar o controle limite diario de ganhos
input double DailyLimitGainCurrency;    //BALANCE Informe o limite financeiro diario de ganhos (R$) (+)
input double DailyLimitGainPoints;      //BALANCE Informe o limite diario de ganhos (pontos) (+)

input bool UseDailyLimit_Loss = false;  //BALANCE Usar o controle limite diario de perdas
input double DailyLimitLossCurrency;    //BALANCE Informe o limite financeiro diario de perdas (R$) (-)
input double DailyLimitLossPoints;      //BALANCE Informe o limite diario de perdas (pontos) (-)

input double Ativo_ValorTick = 0.20;   // Informe o valor do tick para o ativo em uso (Mini Indice = 0.20)
input double CustoPorContrato = 1.22;  // [R$] Custo por Contrato/ Lote unitario (Considerando CORRETAGEM, REGISTRO, EMOLUMENTOS, ISS, IRRF s/ DayTrade)
                                       //input bool   OpenSameDirection = true; // Abre novas posicoes, na mesma direcao de trades ativos?
input bool   OpenSamePosition=true;  // Abre novas posicoes, na mesma direcao da posicao atual?
input bool   OpenTradeSameDirection=true; // Abre novos trades, na mesma direcao de trades ativos?
input bool   ExibirLogsDetalhados=true;
//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+

//Controle de ganhos e perdas pelo site
bool _UseDailyLimit_Gain_Equity=UseDailyLimit_Gain_Equity;
double _DailyLimitGain_Equity=DailyLimitGain_Equity;

bool _UseDailyLimit_Loss_Equity=UseDailyLimit_Loss_Equity;
double _DailyLimitLoss_Equity=DailyLimitLoss_Equity;

bool _UseDailyLimit_Gain=UseDailyLimit_Gain;
double _DailyLimitGainPoints=DailyLimitGainPoints;
double _DailyLimitGainCurrency=DailyLimitGainCurrency;

bool _UseDailyLimit_Loss=UseDailyLimit_Loss;
double _DailyLimitLossPoints=DailyLimitLossPoints;
double _DailyLimitLossCurrency=DailyLimitLossCurrency;

//Controle de perdas pelo site
bool _OpenSamePosition=OpenSamePosition;
bool _OpenTradeSameDirection=OpenTradeSameDirection;

// Conta
int Conta;
bool ContaChecked=false;

// Symbol
double doubleSYMBOL_POINT;

// Infomar dados da ultima barra
double DailyFactor=0; // DailyFactor usado para o THIRSTY and LASTBAR
double LastBarRange= 0;
double LastBarBody = 0;
double LastBarBodyAbs=0;

// Valores ajustados conforme SymbolPOINT do ativo
double spGAP_Top=0;
double spGAP_Bottom=0;
uint   spSlippage = 0;
double spStopLoss = 0;
double spTakeProfit=0;
double spTrailingStop=0;
double spMinimumProfit=0;
double spStep=0;

bool glBuyPlaced,glSellPlaced;
bool glBuyPositionOpen,glSellPositionOpen;
string glBuyTradeIDOpen="";
string glSellTradeIDOpen="";

// Custom variables
// Iniciadores das variaveis dos arrays
bool     glPlaceOrder=false;
bool     glOrderPlaced=false;
bool     glOrderexecuted=false;
bool     glTargetOrderPlaced=false;
bool     glStopOrderPlaced=false;
bool     OpenLineObj  = false;
bool     RangeLineObj = false;
datetime RangeHitDay;
string   NewRangeHighLow= "";
string   RangeHighOrLow = "";
double   RangeLevel=0;
double   RRetreat_point=0;
bool     RRetreat_Hitted=false;
datetime RRetreat_Hit_AtTime=0;

double   ContratosDiarios=0;
datetime NewDayStarted;
double   DailyOpen=0;
datetime DailyTime;
double   RangeCurrent = 0;
datetime Range_AtTime = 0;
bool     RangeHit;
datetime Today;
bool     DayClosed=false;
datetime LastRestartedDate;
bool     RestartNewDay;
double   LastDailyHigh= 0;
double   LastDailyLow = 0;
double   LastDailyRange=0;

double   OrderSize=0;
bool     PosicaoAtual=false;
// ulong EntryOrder_OrderNumber;
long     Order_State=0;
datetime DailyEndTimer;
bool     DailyTimerOn;

// Entry Order variables
ulong    EntryOrder_OrderNumber=0;
string   EntryOrder_Status="";
string   EntryOrder_type="";
double   EntryOrder_Volume=0;
double   EntryOrder_VolExec=0;
double   EntryOrder_Price=0;
double   EntryOrder_PriceExec=0;
double   EntryOrder_StopPrice=0;   // Stop  -- NOT USED

                                   // Target Order variables
ulong  TargetTicketNumber=0;
string TgtOrder_Status="";
ulong  TgtOrder_OrderNumber=0;
string TgtOrder_type="";
double TgtOrder_Volume=0;
double TgtOrder_VolExec=0;
double TgtOrder_Price=0;
double TgtOrder_PriceExec=0;
string TgtOrder_ObjName="";

// Stop Order variables
ulong  StopLossTicketNumber=0;
ulong  StopOrder_OrderNumber=0;
string StopOrder_Status="";
string StopOrder_type="";
double StopOrder_Volume=0;
double StopOrder_VolExec=0;
double StopOrder_Price=0;
double StopOrder_PriceExec=0;

// Order executed variables
bool   OrdExec_triggered;   // Identifica o status da Deal ( TRIGGERED/ CONSUMED )

// Account Balance = Saldo da conta
double AccountEquity_DailyStarted;
double AccountEquity_Current;
double AccountBalance_Currency=0;
double AccountBalance_Points=0;
bool DailyLimitReached=false;

// Order paraemeters
ENUM_ORDER_TYPE_TIME Quant_type_time;

// Signals WPR (Wlliams%R) and MA (Moving Average)
string WPR_Signal = "";
string wMA_Signal = "";

// Verifica qual round esta acima e qual esta abaixo da posicao atual.
double roundAbove = 0;
double roundBelow = 0;
double Prev_roundAbove= 0;
double DailyLastAbove = 0;
double DailyLastBelow = 0;

//Indicadores Quantitativo
double Y_Open = 0;      // Yesterday Open
double Y_High = 0;      // Yesterday High
double Y_Low = 0;       // Yesterday Low
double Y_Close = 0;     // Yesterday Close
double Y_MidPoint = 0;  // Yesterday MidPoint
double TodayOpen = 0;   // Today Open
double qFirstBar = 0;   // First Bar CTO
float  IBS1 = 0;        // Yesterday close related to yesterday range
double GAP = 0;         // Daily GAP (today open - yesterday close)
float  DailyIBS1 = 0;   // Yesterday close related to yesterday range
double DailyGAP = 0;    // Daily GAP (today open - yesterday close)
double DailyGAPZScore=0;// Daily GAP in ZScore (today open - yesterday close)
double Range1 = 0;      // Range.1 (yesterday high - yesterday low)
double Range1_ZScore=0; // Range.1 in ZCore Value
double CTO1 = 0;        // CTO.1 (yesterday close - yesterday open)
double CTO1_ZScore = 0; // CTO.1 in ZScore Value
double LMC = 0;         // LMC (Last Month Close)
long   DOM = 0;         // DOM (Day of Month)
string MonthQuadrant;   // Month Quadrant (1+/1-/2+/2-)
string DailyMonthQuadrant;   // Month Quadrant (1+/1-/2+/2-)
string DayofWeek = "";  // Day of Week (SUN, MON, TUE, WED, THU, FRI, SAT)
string CTO = "";        // Close to Open. Current position related to Today Open
string CTC1 = "";       // Current position related to Yesterday Close
string MID1;            // Mid.1 ReferencePoint [H+/M+/M-/L-]
string BGSV = "";       // Current day BGSV
string Current_DayPosition="";  // Position of current day (ABOVE, BELOW, INSIDE, OUTSIDE)
                                //bool   IBS_Chk;       // IBS Checked
//bool   GAP_Chk;       // GAP Checked
//bool   WeekDay_Chk;   // WeekDay Checked
//bool   CTO_Chk;       // CTO Checked
//bool   CTC1_Chk;      // CTC.1 Checked

//MqlTradeRequest
MqlTradeRequest TradeRequest;
//MqlTradeResult
MqlTradeResult TradeResult;

//--- flags para instalação e exclusão de ordens pendentes
bool pending_done=false;
bool pending_deleted=false;
//--- bilhetagem da ordem pendente será armazenada aqui
ulong order_ticket=0;

// Array com TODOS os trades validos do arquivo CSV (marcados como true)
sTradeSettings AllTradesSet[];

// Array para o dia, contendo somente os trades que passaram pelos filtros diarios
sTradeSettings MySet[];

// All files must be in the \MQL5\Experts\Files folder of your MetaTrader 5 installation.
sCSVFileStruct stradesCSV[];

// Array para janela trace - uso em multiplas estratégias.
sTraceWindow ATraceWindow[];

string CSVFileName="AUTOMATE.csv";
string URL="";
string strDataUltimaAtualizacao;
string strDataUltimaAtualizacaoPorHorario;
string strDataUltimaValidacaoConta;
string strDataUltimaCargaAnalise;
double numeroContratos=0;
bool  cancelarTodasPosicoes=false;
bool notificacaoEnviada=false;
bool testeLocal=false;

bool bloqueioOperacoesAtivado=false;
bool recarregarAnalisesAposBloqueio=false;
bool notificacaoBloqueioEnviada=false;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

bool AtualizarCSV()
  {

   URL="http://www.linchen.com.br/Gerenciador/analise.php?conta="+(string)Conta;

   if(testeLocal)
      URL="http://localhost/analise.php?conta="+(string)Conta;

   MqlNet INet;
   
   string Host,Request,FileName;

   ParseURL(URL,Host,Request,FileName);
   FileName=CSVFileName;
   if(!INet.Open(Host,80)) false;

   Print("Atualizando "+FileName+" from  http://"+Host+" to Files");

   string newFileName="AUTOMATE.TEMP";

   if(!INet.Request("GET",Request,newFileName,true))
     {
      Print("Erro ao atualizar arquivo de analises ");
      return false;
     }
   else
     {

      //Apaga o csv existente
      if(FileIsExist(FileName))
         FileDelete(FileName);
      //Muda o nome do arquivo apos baixar com sucesso
      if(FileMove(newFileName,FILE_REWRITE,FileName,FILE_REWRITE))
         PrintFormat("%s arquivo movido",newFileName);
      else
         PrintFormat("Erro! Código = %d",GetLastError());

     }
   Print("Arquivo de analises atualizado com sucesso.");

   return true;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool InTesteMode()
  {
   return MQLInfoInteger(MQL_TESTER);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ValidarConta()
  {

   //Caso esteja em modo de teste nao valida a conta
   if(InTesteMode())
     {
      ContaChecked=true;
      return true;
     }

   URL="http://www.linchen.com.br/Gerenciador/ValidarLicenca.php?conta="+(string)Conta;

   if(testeLocal)
      URL="http://localhost/ValidarLicenca.php?conta="+(string)Conta;

   MqlNet INet;

   string Host,Request,FileName;

   ParseURL(URL,Host,Request,FileName);

   string licenca="";
   if(!INet.Open(Host,80)) false;

   Print("Validando licenca");

   if(!INet.Request("GET",Request,licenca))
     {
      Print("Erro ao validar licenca");
      ContaChecked=false;
      return false;
     }
   else
     {
      string result[];
      string sep=";";
      ushort u_sep;

      u_sep=StringGetCharacter(sep,0);

      int k=StringSplit(licenca,u_sep,result);

      if(k>0)
        {
         if(result[0]=="1")
           {
            ContaChecked=true;

            numeroContratos=StringToDouble(result[1]);

            string nomeArquivo=result[2];

            int _lopenSamePosition=StringToInteger(result[3]);

            int _lopentradesamedirection=StringToInteger(result[4]);

            if(_lopenSamePosition==1)
              {
               _OpenSamePosition=true;
              }
            else
              {
               _OpenSamePosition=false;
              }

            if(_lopentradesamedirection==1)
              {
               _OpenTradeSameDirection=true;
              }
            else
              {
               _OpenTradeSameDirection=false;
              }

            //Gain Equity
            int _luseDailyLimit_Gain_Equity= StringToInteger(result[5]);
            if(_luseDailyLimit_Gain_Equity == 1)
              {
               _UseDailyLimit_Gain_Equity=true;
               _DailyLimitGain_Equity=StringToDouble(result[6]);
              }
            else
              {
               _UseDailyLimit_Gain_Equity=false;
              }

            //Loss Equity
            int _luseDailyLimit_Loss_Equity= StringToInteger(result[7]);
            if(_luseDailyLimit_Loss_Equity == 1)
              {
               _UseDailyLimit_Loss_Equity=true;
               _DailyLimitLoss_Equity=StringToDouble(result[8]);
              }
            else
              {
               _UseDailyLimit_Loss_Equity=false;
              }

            //Daily Limit Gain
            int luseDailyLimit_Gain=StringToInteger(result[9]);
            if(luseDailyLimit_Gain == 1)
              {
               _UseDailyLimit_Gain=true;
               _DailyLimitGainPoints=StringToDouble(result[10]);
               _DailyLimitGainCurrency=StringToDouble(result[11]);
              }
            else
              {
               _UseDailyLimit_Gain=false;
              }

            //Daily Limit Loss
            int _luseDailyLimit_Loss= StringToInteger(result[12]);
            if(_luseDailyLimit_Loss == 1)
              {
               _UseDailyLimit_Loss=true;

               _DailyLimitLossPoints=StringToDouble(result[13]);
               _DailyLimitLossCurrency=StringToDouble(result[14]);

              }
            else
              {
               _UseDailyLimit_Loss=false;
              }
            string tipoConta=result[15];

            ENUM_ACCOUNT_TRADE_MODE tradeMode=(ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE);

            Print("Tipo Conta: "+EnumToString(tradeMode));

            Print("Tipo Conta Licenciado: "+tipoConta);

            Print("Conta: "+(string)Conta+" validada com sucesso conta");
            Print("Numero de contratos permitidos : ",numeroContratos);
            Print("Nome arquivo estrategias : ",nomeArquivo);

            Print("Open Same Position : ",_OpenSamePosition);
            Print("Open Trade Same Direction : ",_OpenTradeSameDirection);

            Print("Use Daily Limit Gain Equity : ",_UseDailyLimit_Gain_Equity);
            Print("Daily Limit Gain Equity : ",_DailyLimitGain_Equity);

            Print("Use Daily Limit Loss Equity : ",_UseDailyLimit_Loss_Equity);
            Print("Daily Limit Loss Equity : ",_DailyLimitLoss_Equity);

            Print("Use Daily Limit Gain : ",_UseDailyLimit_Gain);
            Print("Daily Limit Gain Points : ",_DailyLimitGainPoints);
            Print("Daily Limit Gain Currency : ",_DailyLimitGainCurrency);

            Print("Use Daily Limit Loss : ",_UseDailyLimit_Loss);
            Print("Daily Limit Loss Points : ",_DailyLimitLossPoints);
            Print("Daily Limit Loss Currency : ",_DailyLimitLossCurrency);

            if((tradeMode==ACCOUNT_TRADE_MODE_DEMO && tipoConta!="DEMO") ||
               (tradeMode==ACCOUNT_TRADE_MODE_REAL && tipoConta!="PROD")
               )
              {
               ContaChecked=false;

               Print("Expert não licenciado para operar com a conta devido ao tipo diferente do licenciado. ");
               return false;


              }

            return true;

           }
         else
           {
            Print("Expert não licenciado para operar com a conta: "+(string)Conta);
            ContaChecked=false;
            return false;
           }

        }

     }

   return false;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ValidaBloqueio()
  {

//Caso esteja em modo de teste nao valida a conta
   if(InTesteMode())
     {
      return true;
     }

   URL="http://www.linchen.com.br/Gerenciador/ValidarBloqueio.php?conta="+(string)Conta;

   if(testeLocal)
      URL="http://localhost/ValidarBloqueio.php?conta="+(string)Conta;

   MqlNet INet;

   string Host,Request,FileName;

   ParseURL(URL,Host,Request,FileName);

   string retorno="";
   if(!INet.Open(Host,80)) false;

   //Print("Validando Bloqueio");

   if(!INet.Request("GET",Request,retorno))
     {
      Print("Erro ao validar bloqueio");

      return false;
     }
   else
     {
      string result[];
      string sep=";";
      ushort u_sep;

      u_sep=StringGetCharacter(sep,0);

      int k=StringSplit(retorno,u_sep,result);

      if(k>0)
        {
         if(result[0]=="1")
           {
            bloqueioOperacoesAtivado=true;
            Print("Bloqueio de operações ativado.");

           }
         else
           {
            notificacaoBloqueioEnviada=false;
            bloqueioOperacoesAtivado=false;
           }

        }

     }

   return false;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NotificarSitePosicoesFechadas()
  {

   //Caso esteja em modo de teste nao envia relatorio 
   if(InTesteMode())
     {
      return true;
     }

   bool posicaoAberta=PositionSelect(_Symbol)==1;

   if(posicaoAberta)
      return false;

   int total_OrdensPendentes=OrdersTotal();

   if(total_OrdensPendentes>0)
      return false;

   URL="http://www.linchen.com.br/Gerenciador/notificar-fechamento.php?conta="+(string)Conta;

   if(testeLocal)
      URL="http://localhost/notificar-fechamento.php?conta="+(string)Conta;

   MqlNet INet;

   string Host,Request,FileName;

   ParseURL(URL,Host,Request,FileName);

   if(!INet.Open(Host,80)) false;

   Print("Enviando relatorio");

   string  retorno;
   if(!INet.Request("GET",Request,retorno))
     {
      Print("Erro ao Enviar relatorio");
      return false;
     }
   else
     {
      return true;
     }

   return false;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ParseURL(string path,string &host,string &request,string &filename)
  {
   host=StringSubstr(URL,7);
// remove
   int i=StringFind(host,"/");
   request=StringSubstr(host,i);
   host=StringSubstr(host,0,i);
   string file="";
   for(i=StringLen(URL)-1; i>=0; i--)
      if(StringSubstr(URL,i,1)=="/")
        {
         file=StringSubstr(URL,i+1);
         break;
        }
   if(file!="") filename=file;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ENUM_TIMEFRAMES RetornarTimeFrame(string time_frame)
  {

   if(time_frame=="CURRENT")
     {
      return PERIOD_CURRENT;
     }
   else if(time_frame=="M1")
     {
      return PERIOD_M1;
     }
   else if(time_frame=="M2")
     {
      return PERIOD_M2;
     }
   else if(time_frame=="M3")
     {
      return PERIOD_M3;
     }
   else if(time_frame=="M4")
     {
      return PERIOD_M4;
     }
   else if(time_frame=="M5")
     {
      return PERIOD_M5;
     }
   else if(time_frame=="M6")
     {
      return PERIOD_M6;
     }
   else if(time_frame=="M10")
     {
      return PERIOD_M10;
     }
   else if(time_frame=="M12")
     {
      return PERIOD_M12;
     }
   else if(time_frame=="M15")
     {
      return PERIOD_M15;
     }
   else if(time_frame=="M20")
     {
      return PERIOD_M20;
     }
   else if(time_frame=="M30")
     {
      return PERIOD_M30;
     }
   else if(time_frame=="H1")
     {
      return PERIOD_H1;
     }
   else if(time_frame=="H2")
     {
      return PERIOD_H2;
     }
   else if(time_frame=="H3")
     {
      return PERIOD_H3;
     }
   else if(time_frame=="H4")
     {
      return PERIOD_H4;
     }
   else if(time_frame=="H6")
     {
      return PERIOD_H6;
     }
   else if(time_frame=="H8")
     {
      return PERIOD_H8;
     }
   else if(time_frame=="H12")
     {
      return PERIOD_H12;
     }
   else if(time_frame=="D1")
     {
      return PERIOD_D1;
     }
   else if(time_frame=="W1")
     {
      return PERIOD_W1;
     }
   else if(time_frame=="MN1")
     {
      return PERIOD_MN1;
     }
   else
      return PERIOD_CURRENT;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CarregarAnalises()
  {

// All files must be in the \MQL5\Experts\Files folder of your MetaTrader 5 installation.

// Guarantee Array is Empty, no previous data on Trades array. If just change EA property trade array (AllTradeSet and MySet) was duplicated or with old parameters 
   ArrayResize(stradesCSV,0,1000);
   ArrayResize(AllTradesSet,0,1000);
   ArrayResize(ATraceWindow,0,50);      //Struct com Janela Trace - zero diariamente
   ArrayResize(MySet,0,1000);
   Print("File initial lenght: "+(string)ArraySize(stradesCSV));
   Print("AllTradeSet initial lenght: "+(string)ArraySize(AllTradesSet));
   Print("MySet initial lenght: "+(string)ArraySize(MySet));

   int y=0;
   bool HeaderLine=true;
   string HeaderDummyString;

   string terminal_data_path=TerminalInfoString(TERMINAL_DATA_PATH);

   Print("FileIsExist: "+(string)FileIsExist(CSVFileName));

   int fileHandle = FileOpen(CSVFileName,FILE_READ|FILE_CSV|FILE_ANSI,';');
   if(fileHandle !=INVALID_HANDLE)
     {
      Print("FileOpen OK");
      Print("Caminho: "+terminal_data_path+"\\MQL5\\Files");
     }
   else
     {
      Print("Operacao FileOpen falhou, erro ",GetLastError());
      Print("Caminho: "+terminal_data_path+"\\MQL5\\Files");
     }

   Print("FileSize:"+(string)FileSize(fileHandle));

   while(FileIsEnding(fileHandle)==false)
     {

      if(y==0 && HeaderLine==true)
        {
         // Disconsider firstLine data (file header/ cabecalho do arquivo)
         HeaderLine=false;
         while(FileIsLineEnding(fileHandle)==false)
           {
            HeaderDummyString=FileReadString(fileHandle);

           }

        }
      else
        {
         ArrayResize(stradesCSV,ArraySize(stradesCSV)+1,1000);
         if(ExibirLogsDetalhados)
            Print("At y = "+(string)y+" ArraSize:"+(string)ArraySize(stradesCSV));

         string IBS1_Top="";
         string IBS1_Bottom="";
         string GAP_Top="";
         string GAP_Bottom = "";
         string Range1_Top = "";
         string Range1_Bottom="";
         string CTO1_Top="";
         string CTO1_Bottom="";

         stradesCSV[y].Active=FileReadBool(fileHandle);
         stradesCSV[y].TradeID=FileReadString(fileHandle);
         stradesCSV[y].Ativo_Symbol=FileReadString(fileHandle);
         stradesCSV[y].Strategy=FileReadString(fileHandle);
         //if(Usar_Simbolo_Atual==true)
         //   stradesCSV[y].Ativo_Symbol=_Symbol;

         stradesCSV[y].Timeframe = FileReadString(fileHandle);
         stradesCSV[y].TradeType = FileReadString(fileHandle);

         IBS1_Top=FileReadString(fileHandle);
         if(ExibirLogsDetalhados) Print("numero IBS1_TOP: "+IBS1_Top);
         if(ExibirLogsDetalhados)Print("IBS1_Top_quantidade substituicoes: "+(string)StringReplace(IBS1_Top,",","."));
         stradesCSV[y].IBS_Top=StringToDouble(IBS1_Top);
         if(ExibirLogsDetalhados)Print("numero IBS1_TOP_Array: "+DoubleToString(stradesCSV[y].IBS_Top,2));

         IBS1_Bottom=FileReadString(fileHandle);
         if(ExibirLogsDetalhados)Print("numero IBS1_Bottom: "+IBS1_Bottom);
         if(ExibirLogsDetalhados)Print(" IBS1_Bottom_quantidade substituicoes: "+(string)StringReplace(IBS1_Bottom,",","."));
         stradesCSV[y].IBS_Bottom=StringToDouble(IBS1_Bottom);
         if(ExibirLogsDetalhados)Print("numero IBS1_Bottom_Array: "+DoubleToString(stradesCSV[y].IBS_Bottom,2));

         GAP_Top=FileReadString(fileHandle);
         if(ExibirLogsDetalhados)Print("numero GAP_Top: "+GAP_Top);
         if(ExibirLogsDetalhados)Print("GAP_Top_quantidade substituicoes: "+(string)StringReplace(GAP_Top,",","."));
         stradesCSV[y].GAP_Top=StringToDouble(GAP_Top);
         if(ExibirLogsDetalhados)Print("numero GAP_Top_Array: "+DoubleToString(stradesCSV[y].GAP_Top,2));

         GAP_Bottom=FileReadString(fileHandle);
         if(ExibirLogsDetalhados)Print("numero GAP_Bottom: "+GAP_Bottom);
         if(ExibirLogsDetalhados)Print(" GAP_Bottom_quantidade substituicoes: "+(string)StringReplace(GAP_Bottom,",","."));
         stradesCSV[y].GAP_Bottom=StringToDouble(GAP_Bottom);
         if(ExibirLogsDetalhados)Print("numero GAP_Bottom_Array: "+DoubleToString(stradesCSV[y].GAP_Bottom,2));

         Range1_Top=FileReadString(fileHandle);
         if(ExibirLogsDetalhados)Print("numero Range1_Top: "+Range1_Top);
         if(ExibirLogsDetalhados)Print("Range1_Top_quantidade substituicoes: "+(string)StringReplace(Range1_Top,",","."));
         stradesCSV[y].Range1_Top=StringToDouble(Range1_Top);
         if(ExibirLogsDetalhados)Print("numero Range1_Top_Array: "+DoubleToString(stradesCSV[y].Range1_Top,2));

         Range1_Bottom=FileReadString(fileHandle);
         if(ExibirLogsDetalhados)Print("numero Range1_Bottom: "+Range1_Bottom);
         if(ExibirLogsDetalhados)Print(" Range1_Bottom_quantidade substituicoes: "+(string)StringReplace(Range1_Bottom,",","."));
         stradesCSV[y].Range1_Bottom=StringToDouble(Range1_Bottom);
         if(ExibirLogsDetalhados)Print("numero Range1_Bottom_Array: "+DoubleToString(stradesCSV[y].Range1_Bottom,2));

         CTO1_Top=FileReadString(fileHandle);
         if(ExibirLogsDetalhados)Print("numero CTO1_Top: "+CTO1_Top);
         if(ExibirLogsDetalhados)Print("CTO1_Top_quantidade substituicoes: "+(string)StringReplace(CTO1_Top,",","."));
         stradesCSV[y].CTO1_Top=StringToDouble(CTO1_Top);
         if(ExibirLogsDetalhados) Print("numero CTO1_Top_Array: "+DoubleToString(stradesCSV[y].CTO1_Top,2));

         CTO1_Bottom=FileReadString(fileHandle);
         if(ExibirLogsDetalhados)Print("numero CTO1_Bottom: "+CTO1_Bottom);
         if(ExibirLogsDetalhados)Print(" CTO1_Bottom_quantidade substituicoes: "+(string)StringReplace(CTO1_Bottom,",","."));
         stradesCSV[y].CTO1_Bottom=StringToDouble(CTO1_Bottom);
         if(ExibirLogsDetalhados)Print("numero CTO1_Bottom_Array: "+DoubleToString(stradesCSV[y].CTO1_Bottom,2));

         stradesCSV[y].MonthQuadrant=FileReadString(fileHandle);
         stradesCSV[y].WeekDays=FileReadString(fileHandle);
         stradesCSV[y].CTO=FileReadString(fileHandle);
         stradesCSV[y].CTC1=FileReadString(fileHandle);
         stradesCSV[y].MID1_Reference=FileReadString(fileHandle);
         stradesCSV[y].DailyBGSV=FileReadString(fileHandle);
         stradesCSV[y].DayPosition=FileReadString(fileHandle);
         stradesCSV[y].HighLow=FileReadNumber(fileHandle);
         stradesCSV[y].HighLow_PreLimit=FileReadNumber(fileHandle);

         stradesCSV[y].Range_Min = FileReadNumber(fileHandle);
         stradesCSV[y].Range_Max = FileReadNumber(fileHandle);
         stradesCSV[y].Range_HighLow = FileReadString(fileHandle);
         stradesCSV[y].RRetreat_Perc = FileReadNumber(fileHandle);
         stradesCSV[y].RRetreat_Max_Timer=FileReadNumber(fileHandle);

         stradesCSV[y].TradeDirection= FileReadString(fileHandle);
         stradesCSV[y].TradeOnNewBar = FileReadBool(fileHandle);
         stradesCSV[y].EntryOrder_OrderType= FileReadNumber(fileHandle);
         stradesCSV[y].EarlyOrder_Distance = FileReadNumber(fileHandle);
         stradesCSV[y].TgtOrder_OrderType=FileReadNumber(fileHandle);
         stradesCSV[y].TakeProfit=FileReadNumber(fileHandle);
         stradesCSV[y].StopLoss=FileReadNumber(fileHandle);
         stradesCSV[y].TakeProfit_PercRange=FileReadNumber(fileHandle);
         stradesCSV[y].StopLoss_PercRange=FileReadNumber(fileHandle);

         stradesCSV[y].UseTrailingStop=FileReadBool(fileHandle);
         stradesCSV[y].TrailingStop=FileReadNumber(fileHandle);
         stradesCSV[y].MinimumProfit=FileReadNumber(fileHandle);
         stradesCSV[y].Step=FileReadNumber(fileHandle);

         stradesCSV[y].UseMoneyManagement=FileReadBool(fileHandle);
         stradesCSV[y].RiskPercent=FileReadNumber(fileHandle);
         //stradesCSV[y].FixedVolume = FileReadNumber(fileHandle);

         if(!InTesteMode())
           {
            stradesCSV[y].FixedVolume=FileReadNumber(fileHandle)*numeroContratos;
           }
         else
           { //Modo de teste
            stradesCSV[y].FixedVolume=FileReadNumber(fileHandle);

           }

         stradesCSV[y].UseTimer=FileReadBool(fileHandle);
         stradesCSV[y].StartHour=FileReadNumber(fileHandle);
         stradesCSV[y].StartMinute=FileReadNumber(fileHandle);
         stradesCSV[y].EndHour=FileReadNumber(fileHandle);
         stradesCSV[y].EndMinute=FileReadNumber(fileHandle);
         stradesCSV[y].UseEntryTimer=FileReadBool(fileHandle);
         stradesCSV[y].EntryStartHour=FileReadNumber(fileHandle);
         stradesCSV[y].EntryStartMinute=FileReadNumber(fileHandle);
         stradesCSV[y].EntryEndHour=FileReadNumber(fileHandle);
         stradesCSV[y].EntryEndMinute=FileReadNumber(fileHandle);

         //Inputs QUANTTREND
         //stradesCSV[y].WPRLength = FileReadNumber(fileHandle); 
         //stradesCSV[y].WPR_CutLevel = FileReadNumber(fileHandle);
         //stradesCSV[y].WPR_CutLevel_Side = FileReadNumber(fileHandle);
         //stradesCSV[y].wMALength = FileReadNumber(fileHandle);
         //stradesCSV[y].wMA_Side = FileReadNumber(fileHandle);
         //stradesCSV[y].wMAMethod = FileReadNumber(fileHandle);
         //stradesCSV[y].wMAShift = FileReadNumber(fileHandle);
         //stradesCSV[y].wMAPrice = FileReadNumber(fileHandle);

         stradesCSV[y].EntryRef_Open_Top=FileReadNumber(fileHandle);
         stradesCSV[y].EntryRef_Open_Bottom=FileReadNumber(fileHandle);
         stradesCSV[y].EntryPoint=FileReadNumber(fileHandle);

         stradesCSV[y].EntryBar=FileReadNumber(fileHandle);
         stradesCSV[y].Entry_ABoveBelow=FileReadNumber(fileHandle);
         stradesCSV[y].RangePerc_to_Entry=FileReadNumber(fileHandle);
         stradesCSV[y].DailyFactor_Max = FileReadNumber(fileHandle);
         stradesCSV[y].DailyFactor_Min = FileReadNumber(fileHandle);
         //---- input parameters BSP_BOP
         stradesCSV[y].BaseBSPBOP=FileReadString(fileHandle);
         stradesCSV[y].BSP_BOP=FileReadString(fileHandle);

         stradesCSV[y].MaPeriodo=FileReadNumber(fileHandle);
         stradesCSV[y].MaPosition=FileReadNumber(fileHandle);
         
        //---- input parameters Window Trace
        stradesCSV[y].TraceWindowDay=FileReadNumber(fileHandle);
        stradesCSV[y].TraceWindowGain=FileReadNumber(fileHandle);
        
        
        //---- input parameters ZSCORE
        stradesCSV[y].WindowZScore=FileReadNumber(fileHandle);
      

         //---- IBS N Periodos
         //stradesCSV[y].IBS_N_Timeframe=FileReadString(fileHandle);

         //stradesCSV[y].IBS_N_Periodos=FileReadNumber(fileHandle);
/*
            string IBS_N_Top=FileReadString(fileHandle);
            Print("numero IBS_N_TOP: "+IBS_N_Top);
            Print("IBS_N_Top_quantidade substituicoes: "+(string)StringReplace(IBS_N_Top,",","."));
            stradesCSV[y].IBS_N_Top=StringToDouble(IBS_N_Top);
            Print("numero IBS_N_TOP_Array: "+DoubleToString(stradesCSV[y].IBS_N_Top,2));

            string IBS_N_Bottom=FileReadString(fileHandle);
            Print("numero IBS_N_Bottom: "+IBS_N_Bottom);
            Print(" IBS_N_Bottom_quantidade substituicoes: "+(string)StringReplace(IBS_N_Bottom,",","."));
            stradesCSV[y].IBS_N_Bottom=StringToDouble(IBS_N_Bottom);
            Print("numero IBS_N_Bottom_Array: "+DoubleToString(stradesCSV[y].IBS_N_Bottom,2));
*/
         if(ExibirLogsDetalhados) Print("Lendo dados do arquivo. Linha: "+(string)(y+1));
         //Print( "FileIsEnding: "+(string)FileIsEnding(fileHandle));

         y++;
        }
     }

   FileClose(fileHandle);

   // Show Array data 
   //int y;
   y=0;
   Print("ArraySize(trade): "+(string)ArraySize(stradesCSV));

   while(ArraySize(stradesCSV)>y)
     {
      if(ExibirLogsDetalhados)

        {
         Print("tradesCSV["+(string)y+"].Active: "+(string)stradesCSV[y].Active);
         Print("tradesCSV["+(string)y+"].TradeID: "+(string)stradesCSV[y].TradeID);
         Print("tradesCSV["+(string)y+"].Ativo_Symbol: "+(string)stradesCSV[y].Ativo_Symbol);
         Print("tradesCSV["+(string)y+"].Timeframe: "+(string)stradesCSV[y].Timeframe );
         Print("tradesCSV["+(string)y+"].TradeType: "+(string)stradesCSV[y].TradeType );
         Print("tradesCSV["+(string)y+"].TakeProfit: "+(string)stradesCSV[y].TakeProfit);
         Print("tradesCSV["+(string)y+"].StopLoss: "+(string)stradesCSV[y].StopLoss);
         Print("tradesCSV["+(string)y+"].FixedVolume: "+(string)stradesCSV[y].FixedVolume);
         Print("TradesCSV["+(string)y+"].TradeDirection: "+(string)stradesCSV[y].TradeDirection);
         Print("TradesCSV["+(string)y+"].TakeProfit_PercRange: "+(string)stradesCSV[y].TakeProfit_PercRange);
         Print("TradesCSV["+(string)y+"].StopLoss_PercRange: "+(string)stradesCSV[y].StopLoss_PercRange);
         Print("TradesCSV[",y,"].Ativo_Symbol: ",stradesCSV[y].Ativo_Symbol);
        }
      y++;
     }

   LastDailyHigh = 0;  //Inicia valor de LastHigh
   LastDailyLow = 0;   //inicia valor de LastLow
   LastDailyRange = 0; //inicia valor de LastRange
   DailyFactor=0; // DailyFactor usado para o THIRSTY and LASTBAR
   LastBarRange= 0;
   LastBarBody = 0;
   LastBarBodyAbs=0;
   //TradeTrans.OrdExec_triggered = false;

   if(ArraySize(stradesCSV)>0)
     {
      // Show Array data 
      int y=0;

      while(ArraySize(stradesCSV)>y)
        {
         if(stradesCSV[y].Active==true)
           {

            // Ajusta tamanho do Array usado para controle dos trades
            ArrayResize(AllTradesSet,ArraySize(AllTradesSet)+1,1000);
            // Add new valid Trade
            int n=ArraySize(AllTradesSet)-1;

            AllTradesSet[n].TradeID=stradesCSV[y].TradeID;
            AllTradesSet[n].Ativo_Symbol=stradesCSV[y].Ativo_Symbol;
            AllTradesSet[n].Strategy=stradesCSV[y].Strategy;         // Insiro a estratégia
            doubleSYMBOL_POINT=SymbolInfoDouble(AllTradesSet[n].Ativo_Symbol,SYMBOL_POINT);   // Identifica o Symbol_Point do Ativo(Symbol)
            if(ExibirLogsDetalhados)Print("TradesCSV[",n,"].doubleSYMBOL_POINT: ",doubleSYMBOL_POINT," |Ativo_Symbol: ",AllTradesSet[n].Ativo_Symbol);
            //AllTradesSet[n].Timeframe = stradesCSV[y].Timeframe;
            AllTradesSet[n].TradeType=stradesCSV[y].TradeType;
            AllTradesSet[n].IBS_Top=stradesCSV[y].IBS_Top;
            AllTradesSet[n].IBS_Bottom=stradesCSV[y].IBS_Bottom;
            //Variáveis convertidas para valores em ZSCore           
            AllTradesSet[n].GAP_Top=stradesCSV[y].GAP_Top;
            AllTradesSet[n].GAP_Bottom = stradesCSV[y].GAP_Bottom;
            AllTradesSet[n].Range1_Top = stradesCSV[y].Range1_Top;
            AllTradesSet[n].Range1_Bottom=stradesCSV[y].Range1_Bottom;
            AllTradesSet[n].CTO1_Top=stradesCSV[y].CTO1_Top;
            AllTradesSet[n].CTO1_Bottom=stradesCSV[y].CTO1_Bottom;
            AllTradesSet[n].TakeProfit=stradesCSV[y].TakeProfit;
            AllTradesSet[n].StopLoss=stradesCSV[y].StopLoss;
                   
            // correção de divisão por zero - depois vejo pq esta divisão estava acontecendo - Paulo
            // 25/12/2018
            if (doubleSYMBOL_POINT!=0)
            {

               AllTradesSet[n].TrailingStop=stradesCSV[y].TrailingStop/doubleSYMBOL_POINT;
               AllTradesSet[n].MinimumProfit=stradesCSV[y].MinimumProfit/doubleSYMBOL_POINT;
               AllTradesSet[n].Step=stradesCSV[y].Step/doubleSYMBOL_POINT;

            } else
            {
               AllTradesSet[n].TrailingStop=stradesCSV[y].TrailingStop;
               AllTradesSet[n].MinimumProfit=stradesCSV[y].MinimumProfit;
               AllTradesSet[n].Step=stradesCSV[y].Step;

            }
           
            AllTradesSet[n].MonthQuadrant=stradesCSV[y].MonthQuadrant;
            AllTradesSet[n].WeekDays=stradesCSV[y].WeekDays;
            AllTradesSet[n].CTO=stradesCSV[y].CTO;
            AllTradesSet[n].CTC1=stradesCSV[y].CTC1;
            AllTradesSet[n].MID1_Reference=stradesCSV[y].MID1_Reference;
            AllTradesSet[n].DailyBGSV=stradesCSV[y].DailyBGSV;
            AllTradesSet[n].DayPosition=stradesCSV[y].DayPosition;
            AllTradesSet[n].HighLow=stradesCSV[y].HighLow;
            AllTradesSet[n].HighLow_PreLimit=stradesCSV[y].HighLow_PreLimit;

            AllTradesSet[n].Range_Min = stradesCSV[y].Range_Min;
            AllTradesSet[n].Range_Max = stradesCSV[y].Range_Max;
            AllTradesSet[n].RangeHighLow=stradesCSV[y].Range_HighLow;
            AllTradesSet[n].RRetreat_Perc= stradesCSV[y].RRetreat_Perc;
            AllTradesSet[n].RRetreat_Max_Timer=stradesCSV[y].RRetreat_Max_Timer;

            AllTradesSet[n].TradeDirection= stradesCSV[y].TradeDirection;
            AllTradesSet[n].TradeOnNewBar = stradesCSV[y].TradeOnNewBar;
            AllTradesSet[n].EntryOrder_OrderType=stradesCSV[y].EntryOrder_OrderType;
            if(AllTradesSet[n].EntryOrder_OrderType==0)
              {
               if(AllTradesSet[n].TradeType=="ROUNDN")
                 {
                  AllTradesSet[n].EarlyOrder_Distance=stradesCSV[y].EarlyOrder_Distance;
                 }
               else
                 {
                  AllTradesSet[n].EarlyOrder_Distance=0; // Se ordem a mercado, não enviar ordem antecipadamente
                 }
              }
            else AllTradesSet[n].EarlyOrder_Distance=stradesCSV[y].EarlyOrder_Distance;
            AllTradesSet[n].TgtOrder_OrderType=stradesCSV[y].TgtOrder_OrderType;



            AllTradesSet[n].TakeProfit_PercRange=stradesCSV[y].TakeProfit_PercRange;
            AllTradesSet[n].StopLoss_PercRange=stradesCSV[y].StopLoss_PercRange;

            AllTradesSet[n].UseTrailingStop=stradesCSV[y].UseTrailingStop;

            AllTradesSet[n].UseMoneyManagement=stradesCSV[y].UseMoneyManagement;
            AllTradesSet[n].RiskPercent =  stradesCSV[y].RiskPercent;
            AllTradesSet[n].FixedVolume = stradesCSV[y].FixedVolume;
            AllTradesSet[n].UseTimer=stradesCSV[y].UseTimer;
            AllTradesSet[n].StartTimer=qCreateDateTime(stradesCSV[y].StartHour,stradesCSV[y].StartMinute);
            AllTradesSet[n].EndTimer=qCreateDateTime(stradesCSV[y].EndHour,stradesCSV[y].EndMinute);
            AllTradesSet[n].StartHour=stradesCSV[y].StartHour;
            AllTradesSet[n].StartMinute=stradesCSV[y].StartMinute;
            AllTradesSet[n].EndHour=stradesCSV[y].EndHour;
            AllTradesSet[n].EndMinute=stradesCSV[y].EndMinute;
            AllTradesSet[n].UseEntryTimer=stradesCSV[y].UseEntryTimer;
            AllTradesSet[n].EntryStartTimer=qCreateDateTime(stradesCSV[y].EntryStartHour,stradesCSV[y].EntryStartMinute);
            AllTradesSet[n].EntryEndTimer=qCreateDateTime(stradesCSV[y].EntryEndHour,stradesCSV[y].EntryEndMinute);
            AllTradesSet[n].EntryStartHour=stradesCSV[y].EntryStartHour;
            AllTradesSet[n].EntryStartMinute=stradesCSV[y].EntryStartMinute;
            AllTradesSet[n].EntryEndHour=stradesCSV[y].EndHour;
            AllTradesSet[n].EntryEndMinute=stradesCSV[y].EndMinute;
            //teste
            // QUANTTREND
            //AllTradesSet[n].WPRLength = stradesCSV[y].WPRLength;
            //AllTradesSet[n].WPR_CutLevel = stradesCSV[y].WPR_CutLevel;
            //AllTradesSet[n].WPR_CutLevel_Side = stradesCSV[y].WPR_CutLevel_Side;
            //AllTradesSet[n].wMALength = stradesCSV[y].wMALength;
            //AllTradesSet[n].wMA_Side = stradesCSV[y].wMA_Side;
            //AllTradesSet[n].wMAMethod = stradesCSV[y].wMAMethod;
            //AllTradesSet[n].wMAShift = stradesCSV[y].wMAShift;
            //AllTradesSet[n].wMAPrice = stradesCSV[y].wMAPrice;

            AllTradesSet[n].EntryRef_Open_Top=stradesCSV[y].EntryRef_Open_Top;
            AllTradesSet[n].EntryRef_Open_Bottom=stradesCSV[y].EntryRef_Open_Bottom;
            AllTradesSet[n].EntryPoint=stradesCSV[y].EntryPoint;

            AllTradesSet[n].EntryBar=stradesCSV[y].EntryBar;
            AllTradesSet[n].Entry_ABoveBelow=stradesCSV[y].Entry_ABoveBelow;
            AllTradesSet[n].RangePerc_to_Entry=stradesCSV[y].RangePerc_to_Entry;
            AllTradesSet[n].DailyFactor_Max = stradesCSV[y].DailyFactor_Max;
            AllTradesSet[n].DailyFactor_Min = stradesCSV[y].DailyFactor_Min;

            AllTradesSet[n].BaseBSPBOP=stradesCSV[y].BaseBSPBOP;
            AllTradesSet[n].BSP_BOP=stradesCSV[y].BSP_BOP;

            AllTradesSet[n].InvertPosition=false;

            AllTradesSet[n].Daily_BarCounter=0;
            AllTradesSet[n].CalcBarRange= 0;
            AllTradesSet[n].DailyFactor = 0;
            AllTradesSet[n].CalcBarBody = 0;
            AllTradesSet[n].CalcBarBodyAbs=0;

            AllTradesSet[n].Timer_RefPoint=0;
            AllTradesSet[n].Timer_EntryPoint=0;
            AllTradesSet[n].Timer_Ref_fromDailyOpen=0;

            AllTradesSet[n].DailyGAP = 0;
            AllTradesSet[n].DailyIBS = 0;
            AllTradesSet[n].DailyRange1=0;
            AllTradesSet[n].DailyCTO1=0;
            AllTradesSet[n].DailyMonthQuadrant="";
            AllTradesSet[n].LastBar_Time= "";
            AllTradesSet[n].glBuyPlaced = glBuyPlaced;
            AllTradesSet[n].glSellPlaced = glSellPlaced;
            AllTradesSet[n].glPlaceOrder = glPlaceOrder;
            AllTradesSet[n].glOrderPlaced= glOrderPlaced;
            AllTradesSet[n].glOrderexecuted=glOrderexecuted;
            AllTradesSet[n].glTargetOrderPlaced=glTargetOrderPlaced;
            AllTradesSet[n].glStopOrderPlaced=glStopOrderPlaced;
            AllTradesSet[n].RangeLineObj= RangeLineObj;
            AllTradesSet[n].RangeHitDay = RangeHitDay;
            AllTradesSet[n].RangeLevel=RangeLevel;
            AllTradesSet[n].RangeHit=RangeHit;
            AllTradesSet[n].RRetreat_point= RRetreat_point;
            AllTradesSet[n].LastDailyHigh = 1000000;
            AllTradesSet[n].LastDailyLow=0;
            AllTradesSet[n].OrderSize=OrderSize;
            AllTradesSet[n].PosicaoAtual=PosicaoAtual;
            AllTradesSet[n].EntryOrder_OrderNumber = EntryOrder_OrderNumber;
            AllTradesSet[n].EntryOrder_OrderNumber = EntryOrder_OrderNumber;
            AllTradesSet[n].EntryOrder_Status=EntryOrder_Status;
            AllTradesSet[n].EntryOrder_type=EntryOrder_type;
            AllTradesSet[n].EntryOrder_Volume=EntryOrder_Volume;
            AllTradesSet[n].EntryOrder_VolExec=EntryOrder_VolExec;
            AllTradesSet[n].EntryOrder_Price=EntryOrder_Price;
            AllTradesSet[n].EntryOrder_PriceExec = EntryOrder_PriceExec;
            AllTradesSet[n].EntryOrder_StopPrice = EntryOrder_StopPrice;
            AllTradesSet[n].TargetTicketNumber=TargetTicketNumber;
            AllTradesSet[n].TgtOrder_OrderNumber=TgtOrder_OrderNumber;
            AllTradesSet[n].TgtOrder_Status=TgtOrder_Status;
            AllTradesSet[n].TgtOrder_type=TgtOrder_type;
            AllTradesSet[n].TgtOrder_Volume=TgtOrder_Volume;
            AllTradesSet[n].TgtOrder_VolExec=TgtOrder_VolExec;
            AllTradesSet[n].TgtOrder_Price=TgtOrder_Price;
            AllTradesSet[n].TgtOrder_PriceExec=TgtOrder_PriceExec;
            AllTradesSet[n].TgtOrder_ObjName=TgtOrder_ObjName;
            AllTradesSet[n].StopLossTicketNumber=StopLossTicketNumber;
            AllTradesSet[n].StopOrder_OrderNumber=StopOrder_OrderNumber;
            AllTradesSet[n].StopOrder_Status=StopOrder_Status;
            AllTradesSet[n].StopOrder_type=StopOrder_type;
            AllTradesSet[n].StopOrder_Volume=StopOrder_Volume;
            AllTradesSet[n].StopOrder_VolExec=StopOrder_VolExec;
            AllTradesSet[n].StopOrder_Price=StopOrder_Price;
            AllTradesSet[n].StopOrder_PriceExec=StopOrder_PriceExec;
            AllTradesSet[n].Trade_Status="WAITING";

            if(stradesCSV[y].Timeframe=="CURRENT")
              {
               AllTradesSet[n].Timeframe=PERIOD_CURRENT;
               if(ExibirLogsDetalhados)Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="M1")
              {
               AllTradesSet[n].Timeframe=PERIOD_M1;
               if(ExibirLogsDetalhados) Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="M2")
              {
               AllTradesSet[n].Timeframe=PERIOD_M2;
               if(ExibirLogsDetalhados)Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="M3")
              {
               AllTradesSet[n].Timeframe=PERIOD_M3;
               if(ExibirLogsDetalhados) Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="M4")
              {
               AllTradesSet[n].Timeframe=PERIOD_M4;
               if(ExibirLogsDetalhados) Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="M5")
              {
               AllTradesSet[n].Timeframe=PERIOD_M5;
               if(ExibirLogsDetalhados)Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="M6")
              {
               AllTradesSet[n].Timeframe=PERIOD_M6;
               if(ExibirLogsDetalhados) Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="M10")
              {
               AllTradesSet[n].Timeframe=PERIOD_M10;
               if(ExibirLogsDetalhados)Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="M12")
              {
               AllTradesSet[n].Timeframe=PERIOD_M12;
               if(ExibirLogsDetalhados)Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="M15")
              {
               AllTradesSet[n].Timeframe=PERIOD_M15;
               if(ExibirLogsDetalhados)Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="M20")
              {
               AllTradesSet[n].Timeframe=PERIOD_M20;
               if(ExibirLogsDetalhados)Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="M30")
              {
               AllTradesSet[n].Timeframe=PERIOD_M30;
               if(ExibirLogsDetalhados)Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="H1")
              {
               AllTradesSet[n].Timeframe=PERIOD_H1;
               if(ExibirLogsDetalhados)Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="H2")
              {
               AllTradesSet[n].Timeframe=PERIOD_H2;
               if(ExibirLogsDetalhados) Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="H3")
              {
               AllTradesSet[n].Timeframe=PERIOD_H3;
               if(ExibirLogsDetalhados) Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="H4")
              {
               AllTradesSet[n].Timeframe=PERIOD_H4;
               if(ExibirLogsDetalhados)Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="H6")
              {
               AllTradesSet[n].Timeframe=PERIOD_H6;
               if(ExibirLogsDetalhados) Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="H8")
              {
               AllTradesSet[n].Timeframe=PERIOD_H8;
               if(ExibirLogsDetalhados)Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="H12")
              {
               AllTradesSet[n].Timeframe=PERIOD_H12;
               if(ExibirLogsDetalhados)Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="D1")
              {
               AllTradesSet[n].Timeframe=PERIOD_D1;
               if(ExibirLogsDetalhados)Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="W1")
              {
               AllTradesSet[n].Timeframe=PERIOD_W1;
               Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }
            else if(stradesCSV[y].Timeframe=="MN1")
              {
               AllTradesSet[n].Timeframe=PERIOD_MN1;
               if(ExibirLogsDetalhados) Print("OnInit| Timeframe: "+EnumToString(AllTradesSet[n].Timeframe));
              }

            ///---- IBS N Periodos
            //AllTradesSet[n].IBS_N_Timeframe=RetornarTimeFrame(stradesCSV[y].IBS_N_Timeframe);
            //AllTradesSet[n].IBS_N_Periodos=stradesCSV[y].IBS_N_Periodos;
            //AllTradesSet[n].IBS_N_Bottom=stradesCSV[y].IBS_N_Bottom;
            //AllTradesSet[n].IBS_N_Top=stradesCSV[y].IBS_N_Top;

            AllTradesSet[n].MaPeriodo=stradesCSV[y].MaPeriodo;
            AllTradesSet[n].MaPosition=stradesCSV[y].MaPosition;
            AllTradesSet[n].TraceWindowDay=stradesCSV[y].TraceWindowDay;
            AllTradesSet[n].TraceWindowGain=stradesCSV[y].TraceWindowGain;
            //---- input parameters ZSCORE
            AllTradesSet[n].WindowZScore=stradesCSV[y].WindowZScore;   
            if(AllTradesSet[n].MaPeriodo>0)
              {

               AllTradesSet[n].MaHandle=iMA(AllTradesSet[n].Ativo_Symbol,AllTradesSet[n].Timeframe,
                                            AllTradesSet[n].MaPeriodo,0,MODE_EMA,PRICE_CLOSE);

               ArraySetAsSeries(AllTradesSet[n].MaBuffer,true);

              }

            ///////////////////////////////////////////////////////////////////////////
            // TIPO DE TRADE     Guarda variaveis especificas para cada tupo de trade//
            ///////////////////////////////////////////////////////////////////////////

            if(ExibirLogsDetalhados)Print("AllTradesSet["+(string)n+"].TradeID: ",AllTradesSet[n].TradeID);
            if(ExibirLogsDetalhados)Print("AllTradesSet["+(string)n+"].Ativo_Symbol: ",AllTradesSet[n].Ativo_Symbol);
            if(ExibirLogsDetalhados)Print("AllTradesSet["+(string)n+"].Timeframe: ",AllTradesSet[n].Timeframe );
            if(ExibirLogsDetalhados)Print("AllTradesSet["+(string)n+"].TradeType: ",AllTradesSet[n].TradeType );

            if(AllTradesSet[n].TradeType=="RANGE" && ExibirLogsDetalhados)
              {

               Print("AllTradesSet["+(string)n+"].Range: "+(string)AllTradesSet[n].Range_Min);
               Print("AllTradesSet["+(string)n+"].RangeHighLow: "+(string)AllTradesSet[n].RangeHighLow);

              }
            else if(AllTradesSet[n].TradeType=="HIGHLOW" && ExibirLogsDetalhados)
              {
               Print("AllTradesSet["+(string)n+"].HighLow: "+(string)AllTradesSet[n].HighLow);
              }
            //QUANTTREND
            //else if (AllTradesSet[n].TradeType == "QUANTTREND")
            //{
            //  Print("AllTradesSet["+(string)n+"].QuantTrend. MA Side: "+ EnumToString( AllTradesSet[n].wMA_Side) );
            //  Print("AllTradesSet["+(string)n+"].QuantTrend. W%R CutLevel: "+(string)AllTradesSet[n].WPR_CutLevel );
            //  Print("AllTradesSet["+(string)n+"].QuantTrend. W%R CutLevelSide: "+ EnumToString(AllTradesSet[n].WPR_CutLevel_Side) );
            //}
            else if(AllTradesSet[n].TradeType=="TIMEENTRY" && ExibirLogsDetalhados)
              {
               Print("AllTradesSet["+(string)n+"].TimeEntry. RefPoint TOP: "+(string)AllTradesSet[n].EntryRef_Open_Top);
               Print("AllTradesSet["+(string)n+"].TimeEntry. RefPoint BOTTOM: "+(string)AllTradesSet[n].EntryRef_Open_Bottom);
               Print("AllTradesSet["+(string)n+"].TimeEntry. EntryPoint: "+(string)AllTradesSet[n].EntryPoint);
              }
            else if(AllTradesSet[n].TradeType=="ROUNDN" && ExibirLogsDetalhados)
              {
               Print("AllTradesSet["+(string)n+"].TimeEntry. RefPoint TOP: "+(string)AllTradesSet[n].EntryRef_Open_Top);
               Print("AllTradesSet["+(string)n+"].TimeEntry. RefPoint BOTTOM: "+(string)AllTradesSet[n].EntryRef_Open_Bottom);
               Print("AllTradesSet["+(string)n+"].TimeEntry. EntryPoint: "+(string)AllTradesSet[n].EntryPoint);
              }
            else if((AllTradesSet[n].TradeType=="THIRSTY" || AllTradesSet[n].TradeType=="LASTBAR") && ExibirLogsDetalhados)
              {
               Print("AllTradesSet[",(string)n,"].TimeEntry. EntryBar: ",AllTradesSet[n].EntryBar);
               Print("AllTradesSet[",(string)n,"].TimeEntry. Entry_ABoveBelow: ",AllTradesSet[n].Entry_ABoveBelow);
               Print("AllTradesSet[",(string)n,"].TimeEntry. RangePerc_to_Entry: ",AllTradesSet[n].RangePerc_to_Entry);
               Print("AllTradesSet[",(string)n,"].TimeEntry. DailyFactor_Max: ", AllTradesSet[n].DailyFactor_Max);
               Print("AllTradesSet[",(string)n,"].TimeEntry. DailyFactor_Min: ", AllTradesSet[n].DailyFactor_Min);
              }
            else if(AllTradesSet[n].TradeType=="BSP_BOP" && ExibirLogsDetalhados)
              {
               Print("AllTradesSet[",(string)n,"].TimeEntry. BaseBSPBOP: ",AllTradesSet[n].BaseBSPBOP);
               Print("AllTradesSet[",(string)n,"].TimeEntry. BSP_BOP: ",AllTradesSet[n].BSP_BOP);
              }
            if(ExibirLogsDetalhados)
              {
               Print("AllTradesSet["+(string)n+"].TradeDirection: ",(string)AllTradesSet[n].TradeDirection);
               Print("AllTradesSet["+(string)n+"].TradeOnNewBar: ",(string)AllTradesSet[n].TradeOnNewBar);
               Print("AllTradesSet["+(string)n+"].TakeProfit: ",(string)AllTradesSet[n].TakeProfit);
               Print("AllTradesSet["+(string)n+"].StopLoss: ",(string)AllTradesSet[n].StopLoss);
               Print("AllTradesSet["+(string)n+"].OrderSize: ",(string)AllTradesSet[n].OrderSize);
               Print("AllTradesSet["+(string)n+"].EntryOrder_OrderType: ",EnumToString(AllTradesSet[n].EntryOrder_OrderType));
              }
            if(AllTradesSet[n].UseTrailingStop==true && ExibirLogsDetalhados)
              {
               Print("AllTradesSet["+(string)n+"].UseTrailingStop: "+(string)AllTradesSet[n].UseTrailingStop );
               Print("AllTradesSet["+(string)n+"].UseTrailingStop: "+(string)AllTradesSet[n].TrailingStop );
               Print("AllTradesSet["+(string)n+"].UseTrailingStop: "+(string)AllTradesSet[n].MinimumProfit );
               Print("AllTradesSet["+(string)n+"].UseTrailingStop: "+(string)AllTradesSet[n].Step );
              }
           }

         y++;

        }

      // Ajusta tamanho do Array usado para controle dos trades
      //ArrayResize(AllTradesSet,ArraySize(sTradesCSV),1000 );  
      if(ExibirLogsDetalhados)
        {
         Print("OInit| Size(file): "+(string)ArraySize(stradesCSV));
         Print("OInit| Size(AllTradesSet): "+(string)ArraySize(AllTradesSet));
        }

     }
   else
     {

     }

//   if(ExibirLogsDetalhados)
//     {
//
//      Print("MySettings. Trade1: "+(string)AllTradesSet[0].TradeType);
//      Print("OInit| Size(AllTradesSet): "+(string)ArraySize(AllTradesSet));
//     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FileInfo(const int handle,const ENUM_FILE_PROPERTY_INTEGER id,
              long l,const string type)
  {
   //--- receive the property value 
   ResetLastError();
   if((l=FileGetInteger(handle,id))!=-1)
     {
      //--- the value received, display it in the correct format 
      if(!StringCompare(type,"bool"))
         Print(EnumToString(id)," = ",l ? "true" : "false");
      if(!StringCompare(type,"date"))
         Print(EnumToString(id)," = ",(datetime)l);
      if(!StringCompare(type,"other"))
         Print(EnumToString(id)," = ",l);
     }
   else
      Print("Error, Code = ",GetLastError());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(InTesteMode())
      Print("Expert iniciado em Modo de Teste");
      
   
   //Atribui o nome do ativo do gráfico para o sistema   
   symbol_info.Name(_Symbol);
   //receive current rates and display
   symbol_info.RefreshRates();   

   RangeLevel=0;

   // Start Balance/ Saldo variables
   AccountEquity_DailyStarted=0;
   AccountEquity_Current=0;
   AccountBalance_Currency=0;
   AccountBalance_Points=0;
   DailyLimitReached=false;
   
   //Ajusta valores para Negativos, se forem informados positivos. Esboco, precisa criar as variaveis, se for usar este formato
   //glDailyLimitLossCurrency = DailyLimitLossCurrency;
   //if( DailyLimitLossCurrency > 0 ) glDailyLimitLossCurrency = DailyLimitLossCurrency * -1 ;
   //glDailyLimitLossPoints = DailyLimitLossPoints;
   //if( DailyLimitLossPoints > 0 ) glDailyLimitLossPoints = DailyLimitLossPoints * -1 ;
   //glDailyLimitLoss_Equity = DailyLimitLoss_Equity;
   //if( DailyLimitLoss_Equity > 0 ) glDailyLimitLoss_Equity = DailyLimitLoss_Equity * -1 ;


   //Verifica numero de digitos do Simbolo
   doubleSYMBOL_POINT=SymbolInfoDouble(_Symbol,SYMBOL_POINT);

   //Valores ajustados conforme SymbolPOINT do ativo
   // Ex: INDUFT Target 3pts ==> 3 / 1 = 3 
   // Ex: DOLFUT Target 3pts ==> 3 / 0.001 = 3000
   //spGAP_Top = GAP_Top / doubleSYMBOL_POINT;
   //spGAP_Bottom = GAP_Bottom / doubleSYMBOL_POINT;
   spSlippage=(ulong)(Slippage/doubleSYMBOL_POINT);
   //spStopLoss = StopLoss / doubleSYMBOL_POINT;
   //spTakeProfit = TakeProfit / doubleSYMBOL_POINT;
   //spTrailingStop = TrailingStop  / doubleSYMBOL_POINT;
   //spMinimumProfit = MinimumProfit  / doubleSYMBOL_POINT;
   //spStep = Step / doubleSYMBOL_POINT;         

   Trade.SetDeviationInPoints((ulong)(spSlippage*doubleSYMBOL_POINT));

   //--- define o MagicNumber para marcar todas as nossas ordens
   Trade.SetExpertMagicNumber(MagicNumber);
   //--- define o tipo de preenchimento da ordem
   Trade.SetTypeFilling(ORDER_FILLING_RETURN);
   Quant_type_time=ORDER_TIME_DAY;
   Print("Quant_type_time: "+(string)Quant_type_time);

   //--- marcadores de Compra e Venda
   glBuyPositionOpen  = false;
   glSellPositionOpen = false;
   glBuyTradeIDOpen="";
   glSellTradeIDOpen="";

   //PlaySound("alert.wav");
   
   //Check if "Negociacao Automatizada esta habilidato"
   //if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED) )
   //Alert("ALERTA CUSTOMIZADO: Check if automated trading is allowed in the terminal settings!");
   
   //ENUM_TIMEFRAMES

   Print("ENUM_TIMEFRAMES: PERIOD_CURRENT: "+(EnumToString(PERIOD_CURRENT)),"|",PERIOD_CURRENT);
   Print("ENUM_TIMEFRAMES: PERIOD_M1: "+(EnumToString(PERIOD_M1)),"|",PERIOD_M1);
   Print("ENUM_TIMEFRAMES: PERIOD_M5: "+(EnumToString(PERIOD_M5)),"|",PERIOD_M5);
   Print("ENUM_TIMEFRAMES: PERIOD_M10: "+(EnumToString(PERIOD_M10)),"|",PERIOD_M10);
   Print("ENUM_TIMEFRAMES: PERIOD_15: "+(EnumToString(PERIOD_M15)),"|",PERIOD_M15);
   Print("ENUM_TIMEFRAMES: PERIOD_M30: "+(EnumToString(PERIOD_M30)),"|",PERIOD_M30);
   Print("ENUM_TIMEFRAMES: PERIOD_H1: "+(EnumToString(PERIOD_H1)),"|",PERIOD_H1);
   Print("ENUM_TIMEFRAMES: PERIOD_H4: "+(EnumToString(PERIOD_H4)),"|",PERIOD_H4);
   Print("ENUM_TIMEFRAMES: PERIOD_D1: "+(EnumToString(PERIOD_D1)),"|",PERIOD_D1);
   Print("ENUM_TIMEFRAMES: PERIOD_W1: "+(EnumToString(PERIOD_W1)),"|",PERIOD_W1);
   // Check Account Info
   ContaChecked=false;
   Conta=(int)AccountInfoInteger(ACCOUNT_LOGIN);
   Print("Conta:"+(string)Conta);
   Print("AccountInfo/ ACCOUNT_LOGIN: "+(string)AccountInfoInteger(ACCOUNT_LOGIN));
   Print("AccountInfo/ ACCOUNT_TRADE_MODE: "+EnumToString((ENUM_ACCOUNT_TRADE_MODE) AccountInfoInteger(ACCOUNT_TRADE_MODE)));  //Demonstracao/ Torneio/ Real
   Print("AccountInfo/ ACCOUNT_LEVERAGE: "+(string)AccountInfoInteger(ACCOUNT_LEVERAGE));
   Print("AccountInfo/ ACCOUNT_LIMIT_ORDERS: "+(string)AccountInfoInteger(ACCOUNT_LIMIT_ORDERS));
   Print("AccountInfo/ ACCOUNT_MARGIN_SO_MODE: "+EnumToString((ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)));
   Print("AccountInfo/ ACCOUNT_TRADE_ALLOWED: "+(string)AccountInfoInteger(ACCOUNT_TRADE_ALLOWED));
   Print("AccountInfo/ ACCOUNT_TRADE_EXPERT: "+(string)AccountInfoInteger(ACCOUNT_TRADE_EXPERT));
   Print("AccountInfo/ ACCOUNT_MARGIN_MODE: "+EnumToString((ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE)));

   Print("AccountInfo/ ACCOUNT_NAME: "+AccountInfoString(ACCOUNT_NAME));
   Print("AccountInfo/ ACCOUNT_SERVER: "+AccountInfoString(ACCOUNT_SERVER));
   Print("AccountInfo/ ACCOUNT_CURRENCY: "+AccountInfoString(ACCOUNT_CURRENCY));
   Print("AccountInfo/ ACCOUNT_COMPANY: "+AccountInfoString(ACCOUNT_COMPANY));

   Print("AccountInfo/ ACCOUNT_BALANCE: "+(string)AccountInfoDouble(ACCOUNT_BALANCE));
   Print("AccountInfo/ ACCOUNT_CREDIT: "+(string)AccountInfoDouble(ACCOUNT_CREDIT));
   Print("AccountInfo/ ACCOUNT_PROFIT: "+(string)AccountInfoDouble(ACCOUNT_PROFIT));
   Print("AccountInfo/ ACCOUNT_EQUITY: "+(string)AccountInfoDouble(ACCOUNT_EQUITY));
   Print("AccountInfo/ ACCOUNT_MARGIN: "+(string)AccountInfoDouble(ACCOUNT_MARGIN));
   Print("AccountInfo/ ACCOUNT_MARGIN_FREE: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_FREE));
   Print("AccountInfo/ ACCOUNT_MARGIN_LEVEL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
   Print("AccountInfo/ ACCOUNT_MARGIN_SO_CALL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));
   Print("AccountInfo/ ACCOUNT_MARGIN_SO_SO: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));
   Print("AccountInfo/ ACCOUNT_MARGIN_INITIAL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_INITIAL));
   Print("AccountInfo/ ACCOUNT_MARGIN_MAINTENANCE: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE));
   Print("AccountInfo/ ACCOUNT_ASSETS: "+(string)AccountInfoDouble(ACCOUNT_ASSETS));
   Print("AccountInfo/ ACCOUNT_LIABILITIES: "+(string)AccountInfoDouble(ACCOUNT_LIABILITIES));
   Print("AccountInfo/ ACCOUNT_COMMISSION_BLOCKED: "+(string)AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED));
   //Print( "AccountInfo/ : "+(string)AccountInfoDouble(ACCOUNT_) );

   //SYMBOL INFO
   Print("OInit| ------------------------------------------------");
   Print("OInit| ------Propriedades do Ativo --------------------");
   Print("OInit| Ativo negociado: "+(string)_Symbol+" Descrição: "+SymbolInfoString(_Symbol,SYMBOL_DESCRIPTION));
   Print("OInit| SYMBOL_CURRENCY_BASE: "+SymbolInfoString(_Symbol,SYMBOL_CURRENCY_BASE));
   Print("OInit| SYMBOL_ISIN: "+SymbolInfoString(_Symbol,SYMBOL_ISIN));
   Print("OInit| SYMBOL_BASIS: "+SymbolInfoString(_Symbol,SYMBOL_BASIS));
   Print("OInit| SYMBOL_CURRENCY_BASE: "+SymbolInfoString(_Symbol,SYMBOL_CURRENCY_BASE));
   Print("OInit| SYMBOL_CURRENCY_PROFIT: "+SymbolInfoString(_Symbol,SYMBOL_CURRENCY_PROFIT));
   Print("OInit| SYMBOL_CURRENCY_MARGIN: "+SymbolInfoString(_Symbol,SYMBOL_CURRENCY_MARGIN));
   Print("OInit| SYMBOL_BANK: "+SymbolInfoString(_Symbol,SYMBOL_BANK));
   Print("OInit| SYMBOL_DESCRIPTION: "+SymbolInfoString(_Symbol,SYMBOL_DESCRIPTION));
   Print("OInit| SYMBOL_PATH: "+SymbolInfoString(_Symbol,SYMBOL_PATH));
   //   Print("OInit| : "+SymbolInfoString(_Symbol,));

   Print("OInit| SYMBOL_BID: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_BID));
   Print("OInit| SYMBOL_BIDHIGH: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_BIDHIGH));
   Print("OInit| SYMBOL_BIDLOW: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_BIDLOW));
   Print("OInit| SYMBOL_ASK: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_ASK));
   Print("OInit| SYMBOL_ASKHIGH: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_ASKHIGH));
   Print("OInit| SYMBOL_ASKLOW: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_ASKLOW));
   Print("OInit| SYMBOL_LAST: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_LAST));
   Print("OInit| SYMBOL_LASTHIGH: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_LASTHIGH));
   Print("OInit| SYMBOL_LASTLOW: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_LASTLOW));
   Print("OInit| SYMBOL_OPTION_STRIKE: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_OPTION_STRIKE));
   Print("OInit| SYMBOL_POINT: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_POINT));
   Print("OInit| SYMBOL_TRADE_TICK_VALUE: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE));
   Print("OInit| SYMBOL_TRADE_TICK_VALUE_PROFIT: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE_PROFIT));
   Print("OInit| SYMBOL_TRADE_TICK_VALUE_LOSS: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE_LOSS));
   Print("OInit| SYMBOL_TRADE_TICK_SIZE: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE));
   Print("OInit| SYMBOL_TRADE_CONTRACT_SIZE: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_TRADE_CONTRACT_SIZE));
   Print("OInit| SYMBOL_VOLUME_MIN: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MIN));
   Print("OInit| SYMBOL_VOLUME_MAX: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_MAX));
   Print("OInit| SYMBOL_VOLUME_STEP: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP));
   Print("OInit| SYMBOL_VOLUME_LIMIT: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_LIMIT));
   Print("OInit| SYMBOL_SWAP_LONG: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_SWAP_LONG));
   Print("OInit| SYMBOL_SWAP_SHORT: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_SWAP_SHORT));
   Print("OInit| SYMBOL_MARGIN_INITIAL: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_MARGIN_INITIAL));
   Print("OInit| SYMBOL_MARGIN_MAINTENANCE: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_MARGIN_MAINTENANCE));
   Print("OInit| SYMBOL_SESSION_VOLUME: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_SESSION_VOLUME));
   Print("OInit| SYMBOL_SESSION_TURNOVER: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_SESSION_TURNOVER));
   Print("OInit| SYMBOL_SESSION_INTEREST: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_SESSION_INTEREST));
   Print("OInit| SYMBOL_SESSION_BUY_ORDERS_VOLUME: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_SESSION_BUY_ORDERS_VOLUME));
   Print("OInit| SYMBOL_SESSION_SELL_ORDERS_VOLUME: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_SESSION_SELL_ORDERS_VOLUME));
   Print("OInit| SYMBOL_SESSION_OPEN: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_SESSION_OPEN));
   Print("OInit| SYMBOL_SESSION_CLOSE: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_SESSION_CLOSE));
   Print("OInit| SYMBOL_SESSION_AW: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_SESSION_AW));
   Print("OInit| SYMBOL_SESSION_PRICE_SETTLEMENT: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_SESSION_PRICE_SETTLEMENT));
   Print("OInit| SYMBOL_SESSION_PRICE_LIMIT_MIN: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_SESSION_PRICE_LIMIT_MIN));
   Print("OInit| SYMBOL_SESSION_PRICE_LIMIT_MAX: "+(string)SymbolInfoDouble(_Symbol,SYMBOL_SESSION_PRICE_LIMIT_MAX));

   Print("OInit| SYMBOL_SELECT: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_SELECT));
   Print("OInit| SYMBOL_SESSION_DEALS: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_SESSION_DEALS));
   Print("OInit| SYMBOL_SESSION_BUY_ORDERS: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_SESSION_BUY_ORDERS));
   Print("OInit| SYMBOL_SESSION_SELL_ORDERS: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_SESSION_SELL_ORDERS));
   Print("OInit| SYMBOL_VOLUME: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_VOLUME));
   Print("OInit| SYMBOL_VOLUMEHIGH: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_VOLUMEHIGH));
   Print("OInit| SYMBOL_VOLUMELOW: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_VOLUMELOW));
   Print("OInit| SYMBOL_TIME: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_TIME));
   Print("OInit| SYMBOL_DIGITS: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS));
   Print("OInit| SYMBOL_SPREAD_FLOAT: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD_FLOAT));
   Print("OInit| SYMBOL_SPREAD: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_SPREAD));
   Print("OInit| SYMBOL_TICKS_BOOKDEPTH: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_TICKS_BOOKDEPTH));
   Print("OInit| SYMBOL_TRADE_CALC_MODE: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_CALC_MODE));
   Print("OInit| SYMBOL_TRADE_MODE: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_MODE));
   Print("OInit| SYMBOL_START_TIME: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_START_TIME));
   Print("OInit| SYMBOL_EXPIRATION_TIME: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_EXPIRATION_TIME));
   Print("OInit| SYMBOL_TRADE_STOPS_LEVEL: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL));
   Print("OInit| SYMBOL_TRADE_FREEZE_LEVEL: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_FREEZE_LEVEL));
   Print("OInit| SYMBOL_TRADE_EXEMODE: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_EXEMODE));
   Print("OInit| SYMBOL_SWAP_MODE: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_SWAP_MODE));
   Print("OInit| SYMBOL_SWAP_ROLLOVER3DAYS: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_SWAP_ROLLOVER3DAYS));
   Print("OInit| SYMBOL_EXPIRATION_MODE : "+(string)SymbolInfoInteger(_Symbol,SYMBOL_EXPIRATION_MODE));
   Print("OInit| SYMBOL_FILLING_MODE: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE));
   Print("OInit| SYMBOL_ORDER_MODE: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_ORDER_MODE));
   Print("OInit| SYMBOL_OPTION_MODE: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_OPTION_MODE));
   Print("OInit| SYMBOL_OPTION_RIGHT: "+(string)SymbolInfoInteger(_Symbol,SYMBOL_OPTION_RIGHT));

//Valida se permite o uso de Dll externas
   Print("OInit| Validando uso de DLL Externa");
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!TerminalInfo.IsDLLsAllowed())
     {
      Print("OInit| USO DE DLL EXTERNAS NAO PERMITIDO");
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      Print("OInit| USO DE DLL EXTERNAS CONFIGURADO COM SUCESSO");
     }

   string strDataAtual=TimeToString(TimeLocal(),TIME_DATE);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(ValidarConta())
     {
      strDataUltimaValidacaoConta=strDataAtual;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Atualizar_Analises_Automaticamente==false)
     {
      Print("OInit| ATUALIZACAO AUTOMATICA DE ANALISES DESATIVADA");
      CarregarAnalises();
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      Print("OInit| ATUALIZACAO AUTOMATICA DE ANALISES HABILITADA");
     }
//Quando o ea e colocado no grafico em qualquer horario caso o prametro esteja habilitado entao busca o csv mais atualizado
   if(Atualizar_Analises_Automaticamente==true && strDataUltimaAtualizacao!=strDataAtual)
     {
      AtualizarCSV();

      Print("OnInit| Carregando arquivo de analises, Data Ultima Atualizacao:",strDataUltimaCargaAnalise," | Data Atual:",strDataAtual);
      CarregarAnalises();

      strDataUltimaAtualizacao=strDataAtual;
      strDataUltimaCargaAnalise=strDataAtual;

     }
   EventSetTimer(60*1);

//Indica que deve cancelar todas as posicoes em aberto
   cancelarTodasPosicoes=true;
   notificacaoEnviada=false;
   return(0);

  }
/// MELHORIAS
// Verificar se negociacao automatica esta ativa
// LIMITAR TENTATIVA DE COLOCAR ORDEM A PARAMETRO NO INPUT. Input OrdemTentativas, com DEFAULT = 3;
// enviar e-mail com envio de ordem, status da ordem e modificacao
// enviar e-mail com valor total da operaï¿½ï¿½o
int contadorTemploBloqueio=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {

   string strDataAtual=TimeToString(TimeLocal(),TIME_DATE);

//if(strDataUltimaValidacaoConta!=strDataAtual)
//  {
//   if(ValidarConta())
//    {
//      strDataUltimaValidacaoConta=strDataAtual;
//     }
//  }

//Caso esteja antes do inicio do pregao busca o csv mais atualizado
   datetime    time=TimeLocal();
   MqlDateTime mqlTime;
   TimeToStruct(time,mqlTime);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if((mqlTime.hour>=8 && mqlTime.min>55) && mqlTime.hour<9 && strDataUltimaAtualizacaoPorHorario!=strDataAtual && Atualizar_Analises_Automaticamente==true)
     {

      if(ValidarConta())
        {
         strDataUltimaValidacaoConta=strDataAtual;
        }

      AtualizarCSV();

      Print("OnTimer| Carregando arquivo de analises, Data Ultima Atualizacao:",strDataUltimaCargaAnalise," | Data Atual:",strDataAtual);
      CarregarAnalises();

      strDataUltimaAtualizacaoPorHorario=strDataAtual;
      strDataUltimaCargaAnalise=strDataAtual;
     }

//Consulta o site para verificar se existe bloqueio a cada 2 minutos  
   contadorTemploBloqueio++;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(contadorTemploBloqueio>=3)
     {
      ValidaBloqueio();
      contadorTemploBloqueio=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CancelarTodasPosicoes()
  {

//Fecha todas as ordens pendentes
   int Total_OrdensPendentes=OrdersTotal();

   for(int i=0; i<Total_OrdensPendentes; i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      ulong ticket=OrderGetTicket(0); // pega sempre a primeira ordem
      string _symbol=OrderGetString(ORDER_SYMBOL);

      if(_Symbol==_symbol)
         Trade.OrderDelete(ticket);

     }

//Fecha todos os trades em andamento

   //bool  posicaoAberta=PositionSelect(_Symbol)==1;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(PositionSelect(_Symbol)>0)
   {
      //Pego o comentário do início da operação, pois se pegar diretamente da ordem em aberto fica errado
      //ulong Ticket = PositionGetInteger(POSITION_TICKET);
      ulong identificador = PositionGetInteger(POSITION_IDENTIFIER);
      bool resultado = HistorySelectByPosition(identificador);
      ulong Ticket = HistoryDealGetTicket(0);
      
      string StrategyHistory = HistoryDealGetString(Ticket,DEAL_COMMENT); 
      //Manipulação de string de comentário
      StrM.Assign(StrategyHistory);
      //Caracteres-chave para a estratégia no comentário
      string StrategyResult= StrM.Mid(StrM.Find(0,">")+1,StringLen(StrategyHistory));
      //Caracteres-chave para a inversão de janela no comentário
      string StrategyInvert= StrM.Mid(StrM.Find(0,"*")+1,1);
      // Pego se a flag se o dia foi de inversão de janela e o nome da estratégia
      Trade.PositionClose(_Symbol,-1,"*" + (string)StrategyInvert+ "S>"+(string)StrategyResult);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   string strDataAtual=TimeToString(TimeLocal(),TIME_DATE);
   if(Atualizar_Analises_Automaticamente==true && strDataUltimaCargaAnalise!=strDataAtual)
     {
      Print("OnTick| Carregando arquivo de analises, Data Ultima Carga Analise:",strDataUltimaCargaAnalise," | Data Atual:",strDataAtual);
      CarregarAnalises();
      strDataUltimaCargaAnalise=strDataAtual;
     }
   if(cancelarTodasPosicoes)
     {
      //Fecha todas as posiçoes caso OnInit tenha sido executado
      Print("Cancelando todas as ordens e posições ao iniciar EA");
      CancelarTodasPosicoes();

      cancelarTodasPosicoes=false;
     }

   //Caso seja apos as 16 horas deve fechar todas as posições caso estejam em aberto
   //Deve notificar no site que tudo foi fechado
   MqlDateTime mqlTime;

   TimeToStruct(TimeLocal(),mqlTime);
   if(mqlTime.hour>=16)
     {
      if(!notificacaoEnviada)
        {
         Print("Efetuando fechamento de todas as posições após 16:00.");
         CancelarTodasPosicoes();
         notificacaoEnviada=NotificarSitePosicoesFechadas();
        }
      return;
     }
   // Verifica se conta foi bloqueada
   if(bloqueioOperacoesAtivado)
     {
      recarregarAnalisesAposBloqueio=true;
      if(!notificacaoBloqueioEnviada)
        {
         CancelarTodasPosicoes();
         notificacaoBloqueioEnviada=NotificarSitePosicoesFechadas();
        }
      return;
     }
   else
     {
      if(recarregarAnalisesAposBloqueio)
        {
         recarregarAnalisesAposBloqueio=false;

         ValidarConta();

         if(Atualizar_Analises_Automaticamente==true)
           {
            AtualizarCSV();
            CarregarAnalises();
           }
        }
     }
   if(ContaChecked)
     {

      bool DayOKtoTrade=true;  // Anteriormente, o teste era feito somente com o _Symbol (ativo mostrado no gráfico).

      //---------------------------
      //--- Inicia analise do dia   
      //---------------------------
      if(DayOKtoTrade==true)
        {

         //+------------------------------------------------------------------+
         //|  Limites Diarios de Ganhos (Gain) e perdas (Loss)                |
         //+------------------------------------------------------------------+


         //+------------------------------------------------------------------+
         //| Acompanha saldo diario - Equity                                  |
         //+------------------------------------------------------------------+

         //input bool UseDailyLimit_Gain_Equity = false; //EQUITY Usar o controle limite diario de ganhos
         //input double DailyLimitGain_Equity;   //EQUITY Informe o limite financeiro diario de ganhos (R$)

         //input bool UseDailyLimit_Loss_Equity = false; //EQUITY Usar o controle limite diario de perdas
         //input double DailyLimitLoss_Equity;   //EQUITY Informe o limite diario de perdas (R$)

         // Equity diario
         AccountEquity_Current=AccountInfoDouble(ACCOUNT_EQUITY)-AccountEquity_DailyStarted;
         //Print( "OnTick| Equity_Current: ",AccountEquity_Current," |Equity_Inicio do dia: ",AccountEquity_DailyStarted );

         //============================
         //Limite Positivo
         if(_UseDailyLimit_Gain_Equity==true && DailyLimitReached==false)
           {
            //AccountEquity_Current

            if(( AccountEquity_Current>=_DailyLimitGain_Equity && _DailyLimitGain_Equity!=0) && OrdersTotal()>0)
              {
               int Total_OrdensPendentes=OrdersTotal();
               Print("Orderstotal:",Total_OrdensPendentes);
               //Adicionar script para cancelar todas as ordens em aberto, e relaizar o cancelamento antes de encerrar as posições.
               for(int i=0; i<Total_OrdensPendentes; i++)
                 {
                  ulong ticket=OrderGetTicket(0); // pega sempre a primeira ordem
                  Print("OnTrade| Order Ticket#:",ticket," |i:",i);
                  string LD_Comment=OrderGetString(ORDER_COMMENT);
                  Trade.OrderDelete(ticket); // Trade.mqh
                                             //Trade.Delete(ticket);    // MQL5Book/Trade.mqh
                  Print("OnTick| LIMITE EQUITY GAIN DIARIO ATINGIDO. Cancelando ordem#:",ticket," Order Comment: ",LD_Comment);
                 }
              }

            //Se limite do dia ultrapassado, cancela as ordens e encerra as posições.
            if(AccountEquity_Current>=_DailyLimitGain_Equity && _DailyLimitGain_Equity!=0)
              {

               for(int j=0;j<=(ArraySize(MySet)-1); j++)
                 {
                  if(PositionSelect(MySet[j].Ativo_Symbol)>0)
                    {
                     Trade.PositionClose(MySet[j].Ativo_Symbol,-1,"*NS>"+(string)MySet[j].Strategy);  // Trade.mqh
                                                                  //Trade.Close(_Symbol,0,"Encerrar posicao!");   //Mql5Book/Trade.mqh
                     Print("OnTick| Fechando posicoes abertas. Ativo:",MySet[j].Ativo_Symbol);
                    }

                  if(MySet[j].Trade_Status!="FINISHED")
                    {
                     MySet[j].Trade_Status="FINISHED";
                     Print("OnTick| Limite EQUITY GAIN do dia alcancado. Finalizando trade: ",MySet[j].TradeID,". Voltamos só amanha!");
                    }
                 }
               Print("OnTick| LIMITE EQUITY GAIN DIARIO ATINGIDO. Novas operacoes do dia finalizadas! Todas as posições abertas, encerradas!");
               DailyLimitReached=true;
               Print("DailyLimitReached: ",DailyLimitReached);
              }
           }

         //Limite_Diario_Perdas (Loss)
         if(_UseDailyLimit_Loss_Equity==true && DailyLimitReached==false)
           {
            //AccountEquity_Current

            if((AccountEquity_Current<=_DailyLimitLoss_Equity && _DailyLimitLoss_Equity!=0) && OrdersTotal()>0)
              {
               int Total_OrdensPendentes=OrdersTotal();
               Print("Orderstotal:",Total_OrdensPendentes);
               //Adicionar script para cancelar todas as ordens em aberto, e relaizar o cancelamento antes de encerrar as posições.
               for(int i=0; i<Total_OrdensPendentes; i++)
                 {
                  ulong ticket=OrderGetTicket(0); // pega sempre a primeira ordem
                  Print("OnTrade| Order Ticket#:",ticket," |i:",i);
                  string LD_Comment=OrderGetString(ORDER_COMMENT);
                  Trade.OrderDelete(ticket); // Trade.mqh
                                             //Trade.Delete(ticket);    // MQL5Book/Trade.mqh
                  Print("OnTick| LIMITE EQUITY LOSS DIARIO ATINGIDO. Cancelando ordem#:",ticket," Order Comment: ",LD_Comment);
                 }
              }

            //Se limite EQUITY do dia ultrapassado, cancela as ordens e encerra as posições.
            if(AccountEquity_Current<=_DailyLimitLoss_Equity && _DailyLimitLoss_Equity!=0)
              {

               for(int j=0;j<=(ArraySize(MySet)-1); j++)
                 {
                  if(PositionSelect(MySet[j].Ativo_Symbol)>0)
                    {
                     Trade.PositionClose(MySet[j].Ativo_Symbol,-1,"*NS>"+(string)MySet[j].Strategy);  // Trade.mqh
                                                                  //Trade.Close(_Symbol,0,"Encerrar posicao!");   //Mql5Book/Trade.mqh
                     Print("OnTick| Fechando posicoes abertas. Ativo:",MySet[j].Ativo_Symbol);
                    }

                  if(MySet[j].Trade_Status!="FINISHED")
                    {
                     MySet[j].Trade_Status="FINISHED";
                     Print("OnTick| Limite EQUITY LOSS do dia alcancado. Finalizando trade: ",MySet[j].TradeID,". Voltamos só amanha!");
                    }
                 }
               Print("OnTick| LIMITE EQUITY LOSS DIARIO ATINGIDO. Novas operacoes do dia finalizadas! Todas as posições abertas, encerradas!");
               DailyLimitReached=true;
               Print("DailyLimitReached: ",DailyLimitReached);
              }
           }

         //=======================================
         // Limites baseados no Balance
         //=======================================
         //Limite_Diario_Ganhos (Gain)
         if(_UseDailyLimit_Gain==true && DailyLimitReached==false)
           {
            //AccountBalance_Currency
            //AccountBalance_Points

            if(((AccountBalance_Points>=_DailyLimitGainPoints && _DailyLimitGainPoints!=0) || 
               (AccountBalance_Currency>=_DailyLimitGainCurrency && _DailyLimitGainCurrency!=0)) && OrdersTotal()>0)
              {
               int Total_OrdensPendentes=OrdersTotal();
               Print("Orderstotal:",Total_OrdensPendentes);
               //Adicionar script para cancelar todas as ordens em aberto, e relaizar o cancelamento antes de encerrar as posições.
               for(int i=0; i<Total_OrdensPendentes; i++)
                 {
                  ulong ticket=OrderGetTicket(0); // pega sempre a primeira ordem
                  Print("OnTrade| Order Ticket#:",ticket," |i:",i);
                  string LD_Comment=OrderGetString(ORDER_COMMENT);
                  Trade.OrderDelete(ticket); // Trade.mqh
                                             //Trade.Delete(ticket);    // MQL5Book/Trade.mqh
                  Print("OnTick| LIMITE GAIN DIARIO ATINGIDO. Cancelando ordem#:",ticket," Order Comment: ",LD_Comment);
                 }
              }

            //Se limite do dia ultrapassado, cancela as ordens e encerra as posições.
            if((AccountBalance_Points>=_DailyLimitGainPoints && _DailyLimitGainPoints!=0) || 
               (AccountBalance_Currency>=_DailyLimitGainCurrency && _DailyLimitGainCurrency!=0))
              {

               for(int j=0;j<=(ArraySize(MySet)-1); j++)
                 {
                  if(PositionSelect(MySet[j].Ativo_Symbol)>0)
                    {
                     Trade.PositionClose(MySet[j].Ativo_Symbol,-1,"*NS>"+(string)MySet[j].Strategy);  // Trade.mqh
                                                                  //Trade.Close(_Symbol,0,"Encerrar posicao!");   //Mql5Book/Trade.mqh
                     Print("OnTick| Fechando posicoes abertas. Ativo:",MySet[j].Ativo_Symbol);
                    }

                  if(MySet[j].Trade_Status!="FINISHED")
                    {
                     MySet[j].Trade_Status="FINISHED";
                     Print("OnTick| Limite GAIN do dia alcancado. Finalizando trade: ",MySet[j].TradeID,". Voltamos só amanha!");
                    }
                 }
               Print("OnTick| LIMITE GAIN DIARIO ATINGIDO. Novas operacoes do dia finalizadas! Todas as posições abertas, encerradas!");
               DailyLimitReached=true;
               Print("DailyLimitReached: ",DailyLimitReached);
              }
           }

         //Limite_Diario_Perdas (Loss)
         if(_UseDailyLimit_Loss==true && DailyLimitReached==false)
           {
            //AccountBalance_Currency
            //AccountBalance_Points


            if(((AccountBalance_Points<=_DailyLimitLossPoints && _DailyLimitLossPoints!=0) || 
               (AccountBalance_Currency<=_DailyLimitLossCurrency && _DailyLimitLossCurrency!=0)) && OrdersTotal()>0)
              {
               int Total_OrdensPendentes=OrdersTotal();
               Print("Orderstotal:",Total_OrdensPendentes);
               //Adicionar script para cancelar todas as ordens em aberto, e relaizar o cancelamento antes de encerrar as posições.
               for(int i=0; i<Total_OrdensPendentes; i++)
                 {
                  ulong ticket=OrderGetTicket(0); // pega sempre a primeira ordem
                  Print("OnTrade| Order Ticket#:",ticket," |i:",i);
                  string LD_Comment=OrderGetString(ORDER_COMMENT);
                  Trade.OrderDelete(ticket); // Trade.mqh
                                             //Trade.Delete(ticket);    // MQL5Book/Trade.mqh
                  Print("OnTick| LIMITE LOSS DIARIO ATINGIDO. Cancelando ordem#:",ticket," Order Comment: ",LD_Comment);
                 }
              }

            //Se limite do dia ultrapassado, cancela as ordens e encerra as posições.
            if((AccountBalance_Points<=_DailyLimitLossPoints && _DailyLimitLossPoints!=0) || 
               (AccountBalance_Currency<=_DailyLimitLossCurrency && _DailyLimitLossCurrency!=0))
              {

               for(int j=0;j<=(ArraySize(MySet)-1); j++)
                 {
                  if(PositionSelect(MySet[j].Ativo_Symbol)>0)
                    {
                     //"S>" Indica campo logo em seguida da estratégia
                     //"*N" Indica que não é um trade com inversão de Janela
                     Trade.PositionClose(MySet[j].Ativo_Symbol,-1,"*NS>"+(string)MySet[j].Strategy);  // Trade.mqh
                                                                  //Trade.Close(_Symbol,0,"Encerrar posicao!");   //Mql5Book/Trade.mqh
                     Print("OnTick| Fechando posicoes abertas. Ativo:",MySet[j].Ativo_Symbol);
                    }

                  if(MySet[j].Trade_Status!="FINISHED")
                    {
                     MySet[j].Trade_Status="FINISHED";
                     Print("OnTick| Limite LOSS do dia alcancado. Finalizando trade: ",MySet[j].TradeID,". Voltamos só amanha!");
                    }
                 }
               Print("OnTick| LIMITE LOSS DIARIO ATINGIDO. Novas operacoes do dia finalizadas! Todas as posições abertas, encerradas!");
               DailyLimitReached=true;
               Print("DailyLimitReached: ",DailyLimitReached);
              }
           }

         //+------------------------------------------------------------------+
         //|  //Limites Diarios de Ganhos (Gain) e perdas (Loss)              |
         //+------------------------------------------------------------------+


         //======================================
         // Update prices
         //======================================
         //Price.Update(MySet[x].Ativo_Symbol,MySet[x].Timeframe);
         Price.Update(_Symbol,_Period);

         //======================================
         // Data request
         //======================================


         // Monthly OHLC
         MqlRates Monthly[];
         ArraySetAsSeries(Monthly,true);
         CopyRates(_Symbol,PERIOD_MN1,0,2,Monthly);

         //Parametros/ Filtro Mensal
         LMC = Monthly[1].close;
         DOM = StringToInteger( StringSubstr(TimeToString(TimeCurrent(),TIME_DATE),8,2) );

         // Daily OHLC
         MqlRates Daily[];
         ArraySetAsSeries(Daily,true);
         //CopyRates(MySet[x].Ativo_Symbol,PERIOD_D1,0,3,Daily);
         CopyRates(_Symbol,PERIOD_D1,0,3,Daily);

         //Parametros/ Filtros diarios
         DailyOpen=Daily[0].open;
         Y_Open = Daily[1].open;
         Y_High = Daily[1].high;
         Y_Low=Daily[1].low;
         Y_Close=Daily[1].close;
         DailyTime=Daily[0].time;
         RangeCurrent=Daily[0].high-Daily[0].low;
         Range1=Y_High-Y_Low;
         CTO1=Y_Close-Y_Open;

         //Print( "RangeCurrent:"+(string)RangeCurrent );

         //Tick data - using Period defined in chart 
         MqlRates rates[];
         ArraySetAsSeries(rates,true);
         //CopyRates(MySet[x].Ativo_Symbol,MySet[x].Timeframe,0,3,rates);
         CopyRates(_Symbol,_Period,0,3,rates);

         datetime TodayOpen=TimeCurrent();    // Today Open

                                              //Print("Rates 1 Time :", TimeToString(rates[1].time,TIME_DATE));
         //Print("Time Current :", TimeToString(TimeCurrent(),TIME_DATE));  
         //Print("LastRestartedDate " , TimeToString(LastRestartedDate,TIME_DATE));

         if(TimeToString(LastRestartedDate,TIME_DATE)!=TimeToString(TimeCurrent(),TIME_DATE))
           {
            if(ExibirLogsDetalhados)
               Print("OnTick| Solicitado restart das variaveis diarias.");
            RestartNewDay=true;
            notificacaoEnviada=false;
           }

         //======================================
         // Check if New Day started - Restart daily variables and Do Withdraw if is on test mode
         //======================================
         // New Day Started?
         // Verifica o numero de contratos/ titulos negociados no dia anterior
         // if ( TimeToString(Today, TIME_DATE) != TimeToString(TimeCurrent(), TIME_DATE) )
         if(RestartNewDay==true)
           {
            //               
            if(ExibirLogsDetalhados)
               Print("Yesterday: "+TimeToString(Today,TIME_DATE)+", TimeCurrent: "+TimeToString(TimeCurrent(),TIME_DATE)+
                     ", Yesterday Contracts:"+(string)ContratosDiarios+", Yesterday Range: "+(string)RangeCurrent);

            //Calcula os custos das operacoes do dia anterior e Retira o valor para pagamento dos custos (corretagem, emol,...)
            if((ContratosDiarios*CustoPorContrato)!=0)
              {
               if(TesterWithdrawal(ContratosDiarios*CustoPorContrato))
                 {
                  Print("Sacado, Referente ao dia: "+TimeToString(Today,TIME_DATE)+", Valor em R$:"+(string)CustoPorContrato+" referente ao total de contratos:"+(string)ContratosDiarios);
                 }
              }

            //Reinicia variaveis de indicadores quantitativos - DIARIOS
            GAP=0;
            IBS1=0;
            DailyIBS1 = 0;   // Yesterday close related to yesterday range
            DailyGAP = 0;    // Daily GAP (today open - yesterday close)
            Range1=0;
            CTO1= 0;
            LMC = 0;
            DOM = 0;
            DayofWeek="";
            DailyMonthQuadrant="";   // Month Quadrant (1+/1-/2+/2-)
            qFirstBar=0;

            //Reinicia variaveis de indicadores quantitativos - Intraday
            CTO  = "";
            CTC1 = "";
            Current_DayPosition="";
            BGSV = "";
            MID1 = "";
            roundAbove = 0;
            roundBelow = 0;
            Prev_roundAbove= 0;
            DailyLastAbove = 0;
            DailyLastBelow = 0;


            //Reinicia contadores diarios
            ContratosDiarios=0;
            LastRestartedDate=TimeCurrent();
            Today=TimeCurrent();
            DayClosed=false;
            DailyLimitReached=false;
            LastBarRange= 0;
            LastBarBody = 0;
            LastBarBodyAbs=0;
            DailyFactor=0;

            //Reinicia Range do dia
            RangeCurrent = 0;
            Range_AtTime = "";
            RangeHighOrLow="";
            Order_State=0;

            //Reinicia variaveis de ordens executadas
            OrdExec_triggered=false;

            // Reinicia variaveis de Balance/ Saldo diario da conta
            AccountEquity_DailyStarted=AccountEquity_Current=AccountInfoDouble(ACCOUNT_EQUITY);
            AccountBalance_Currency=0;
            AccountBalance_Points=0;

            //--- marcadores de Compra e Venda
            glBuyPositionOpen  = false;
            glSellPositionOpen = false;
            glBuyTradeIDOpen="";
            glSellTradeIDOpen="";

            //------------------------------------------------------------------------------------------------
            // VERIFICA SE HOUVE TRADES QUE PASSARAM DO FINAL E PRECISAM SER ENCERRADOS NA ABERTURA
            //------------------------------------------------------------------------------------------------
            //TODO : Não deve validar se for swingtrade
            for(int i=0;i<=(ArraySize(MySet)-1); i++)
              {
               //Verifica se ficou posicao em aberto, do dia anterior. Se ficou posicao em aberto, encerra na abertura.
               if(PositionSelect(MySet[i].Ativo_Symbol)>0)
                 {
                  //"S>" Indica campo logo em seguida da estratégia
                  //"*N" Indica que não é um trade com inversão de Janela
                  Trade.PositionClose(MySet[i].Ativo_Symbol,-1,"*NS>"+(string)MySet[i].Strategy);  // Trade.mqh
                                                               //Trade.Close(_Symbol,0,"Encerrar posicao!");   //Mql5Book/Trade.mqh
                  Print("OnTick| TradeID: ",MySet[i].TradeID," ENCERRANDO POSICAO EM ABERTO DO DIA ANTERIOR!!!. Todas as posições abertas, encerradas!");
                 }
              }

            //--------------------------------
            // REINICIA VARIAVEIS DO ARRAY DIARIO
            //--------------------------------
            // Delete Array - Trace Window
            ArrayResize(ATraceWindow,0,50);
            // Delete Array
            int MySetLimpo;
            //ArrayFree(MySet);
            MySetLimpo=ArrayResize(MySet,0,1000);
            if(MySetLimpo!=-1)
              {
               Print("Matriz Diaria zerada.");
              }
            else
              {
               Print("ERRO ao zerar o array diario!");
              }

            //}

            Print("Variaveis para o dia reiniciadas");
            RestartNewDay=false;

            // Dados da conta
            if(ExibirLogsDetalhados)
              {
               Print("AccountInfo/ ACCOUNT_BALANCE: "+(string)AccountInfoDouble(ACCOUNT_BALANCE));
               Print("AccountInfo/ ACCOUNT_CREDIT: "+(string)AccountInfoDouble(ACCOUNT_CREDIT));
               Print("AccountInfo/ ACCOUNT_PROFIT: "+(string)AccountInfoDouble(ACCOUNT_PROFIT));
               Print("AccountInfo/ ACCOUNT_EQUITY: "+(string)AccountInfoDouble(ACCOUNT_EQUITY));
               Print("AccountInfo/ ACCOUNT_MARGIN: "+(string)AccountInfoDouble(ACCOUNT_MARGIN));
               Print("AccountInfo/ ACCOUNT_MARGIN_FREE: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_FREE));
               Print("AccountInfo/ ACCOUNT_MARGIN_LEVEL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_LEVEL));
               Print("AccountInfo/ ACCOUNT_MARGIN_SO_CALL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL));
               Print("AccountInfo/ ACCOUNT_MARGIN_SO_SO: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_SO_SO));
               Print("AccountInfo/ ACCOUNT_MARGIN_INITIAL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_INITIAL));
               Print("AccountInfo/ ACCOUNT_MARGIN_MAINTENANCE: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE));
               Print("AccountInfo/ ACCOUNT_ASSETS: "+(string)AccountInfoDouble(ACCOUNT_ASSETS));
               Print("AccountInfo/ ACCOUNT_LIABILITIES: "+(string)AccountInfoDouble(ACCOUNT_LIABILITIES));
               Print("AccountInfo/ ACCOUNT_COMMISSION_BLOCKED: "+(string)AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED));
              }

           } // RESTART

         // Verifica se novo dia comecou
         if(GAP==0 && IBS1==0 && TimeToString(rates[0].time,TIME_DATE)==TimeToString(TimeCurrent(),TIME_DATE) && 
            TimeToString(NewDayStarted,TIME_DATE)!=TimeToString(TimeCurrent(),TIME_DATE))
           {
             
            if(ExibirLogsDetalhados)
               Print("OnTick| 1 -  Novo dia comecou. Solicitando indicadores diarios.");

            NewDayStarted=TimeCurrent(); // Indica que um novo dia comecou e guarda este dia
 
             //GAP ---- Daily Gap: Open - Yesterday close
            GAP=DailyOpen-Y_Close;
            if(ExibirLogsDetalhados)
               Print("OnTick| Parametros de abertura. Ativo:",_Symbol," |DailyOpen: "+(string)DailyOpen+" Y_Close: "+(string)Y_Close+" Daily[1].close: "+(string)Daily[1].close+" Daily[1].low: "+(string)Daily[1].low+" Daily[1].high: "+(string)Daily[1].high);
            if(ExibirLogsDetalhados)
               Print("OnTick| Ativo:",_Symbol," | GAP do dia "+TimeToString(TodayOpen,TIME_DATE)+" |GAP: "+(string)GAP);

            //IBS1
            IBS1=(( Daily[1].close-Daily[1].low)/(Daily[1].high-Daily[1].low));
            DailyIBS1=IBS1;
            if(ExibirLogsDetalhados)
               Print("OnTick| Ativo:",_Symbol," |IBS.1 do dia "+TimeToString(TodayOpen,TIME_DATE)+" |IBS.1: "+StringFormat("%.2f",IBS1));

            //RANGE1
            Range1=(Daily[1].high-Daily[1].low);
            if(ExibirLogsDetalhados)
               Print("OnTick| Ativo:",_Symbol," |Range.1 do dia "+TimeToString(TodayOpen,TIME_DATE)+" |Range.1: "+StringFormat("%.2f",Range1));

            //CTO1
            CTO1=(Daily[1].close-Daily[1].open);
            if(ExibirLogsDetalhados)
               Print("OnTick| Ativo:",_Symbol," |CTO.1 do dia "+TimeToString(TodayOpen,TIME_DATE)+" |CTO.1: "+StringFormat("%.2f",CTO1));

            //MonthQuadrant
            // Analise do Quadrante do mes está mais abaixo no looping.


            //DAY OF WEEK
            //WEEKDAY
            MqlDateTime dt;
            TimeToStruct(TimeCurrent(),dt);
            switch(dt.day_of_week)
              {
               case 0:
                  DayofWeek="SUN";
                  Print("OnTick| DayofWeek: "+DayofWeek);
                  break;
               case 1:
                  DayofWeek="MON";
                  Print("OnTick| DayofWeek: "+DayofWeek);
                  break;
               case 2:
                  DayofWeek="TUE";
                  Print("OnTick| DayofWeek: "+DayofWeek);
                  break;
               case 3:
                  DayofWeek="WED";
                  Print("OnTick| DayofWeek: "+DayofWeek);
                  break;
               case 4:
                  DayofWeek="THU";
                  Print("OnTick| DayofWeek: "+DayofWeek);
                  break;
               case 5:
                  DayofWeek="FRI";
                  Print("OnTick| DayofWeek: "+DayofWeek);
                  break;
               case 6:
                  DayofWeek="SAT";
                  Print("OnTick| DayofWeek: "+DayofWeek);
                  break;
              }
            //DayofWeek = dt.day_of_week;

            //Print("OnTick| DayofWeek: "+DayofWeek);

            //============================================================================
            // START SELECAO DOS TRADES PARA O DIA - MONTANDO ARRAY DIARIO
            //============================================================================
            int AuxTrace=0; //Variável auxiliar para montar o ID das estratégias
             
            // Looping para verificar todos os trades que passam nos filtros diarios e montar array diario
            for(int x=0;x<=(ArraySize(AllTradesSet)-1); x++)
              {
               if(ExibirLogsDetalhados)
                  Print("AllTradesSet Size: ",ArraySize(AllTradesSet),". x:",x);
               // Trade aprovado para operar no dia
               bool TradeForToday;
               TradeForToday=true;

               if(AllTradesSet[x].Trade_Status!="FINISHED")
                 {
                  if(AllTradesSet[x].Ativo_Symbol=="WDOFUT")
                    {
                     if(TimeToString(TimeCurrent(),TIME_DATE)=="2014.06.17"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2014.06.23"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2014.07.04"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2014.07.08"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2015.10.08"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2015.10.09"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2015.10.15"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2015.10.30"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2015.11.30"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2016.01.07"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2016.02.03"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2016.03.11"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2016.03.15" )
                       {
                        DayOKtoTrade=false;
                        //MySet[x].Trade_Status = "FINISHED";
                        TradeForToday=false;
                        Print("OnTick| Symbol: ",AllTradesSet[x].Ativo_Symbol," Dia: [",TimeToString(TimeCurrent(),TIME_DATE),"] com erro de dados! Desconsiderar movimentos deste dia.");
                       }
                    }
                  else if(AllTradesSet[x].Ativo_Symbol=="WINFUT")
                    {
                     if(TimeToString(TimeCurrent(),TIME_DATE)=="2014.04.16"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2014.06.17"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2014.06.18"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2014.06.23"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2014.07.04"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2014.07.08")
                       {
                        DayOKtoTrade=false;
                        //MySet[x].Trade_Status = "FINISHED";
                        TradeForToday=false;
                        Print("OnTick| Symbol: ",AllTradesSet[x].Ativo_Symbol," Dia: [",TimeToString(TimeCurrent(),TIME_DATE),"] com erro de dados! Desconsiderar movimentos deste dia.");
                       }
                    }
                  else if(AllTradesSet[x].Ativo_Symbol=="DOLFUT")
                    {
                     if(TimeToString(TimeCurrent(),TIME_DATE)=="2016.01.07"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2016.02.03"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2016.03.11"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2016.03.15"
                        || TimeToString(TimeCurrent(),TIME_DATE) ==  "2016.04.29")
                       {
                        DayOKtoTrade=false;
                        //MySet[x].Trade_Status = "FINISHED";
                        TradeForToday=false;
                        Print("OnTick| Symbol: ",AllTradesSet[x].Ativo_Symbol," Dia: [",TimeToString(TimeCurrent(),TIME_DATE),"] com erro de dados! Desconsiderar movimentos deste dia.");
                       }
                    }
                  else
                    {
                     //DayOKtoTrade = true;
                     if(ExibirLogsDetalhados)
                        Print("OnTick| TradeID: ",AllTradesSet[x].TradeID," | Trade passou pela BlackList de dias com dados com problema.");
                    }
                 } //if( AllTradeSet[x].Trade_Status != "FINISHED" )

               //======================================
               // Update prices
               //======================================
               Price.Update(AllTradesSet[x].Ativo_Symbol,AllTradesSet[x].Timeframe);
               //Print("Price.Update:"+ Price.Close[0] );

               //======================================
               // Data request
               //======================================

               // Monthly OHLC
               MqlRates Monthly[];
               ArraySetAsSeries(Monthly,true);
               CopyRates(AllTradesSet[x].Ativo_Symbol,PERIOD_MN1,0,2,Monthly);

               // Daily OHLC
               //MqlRates Daily[];
               //ArraySetAsSeries(Daily,true);
               CopyRates(AllTradesSet[x].Ativo_Symbol,PERIOD_D1,0,3,Daily);
               //CopyRates(_Symbol,PERIOD_D1,0,3,Daily);

               //Parametros/ Filtros diarios
               DailyOpen=Daily[0].open;
               Y_Open = Daily[1].open;
               Y_High = Daily[1].high;
               Y_Low=Daily[1].low;
               Y_MidPoint=Y_Low+((Y_High-Y_Low)/2); // Ponto Medio
               Y_Close=Daily[1].close;
               DailyTime=Daily[0].time;
               RangeCurrent=Daily[0].high-Daily[0].low;
               Range1=Y_High-Y_Low;
               CTO1=Y_Close-Y_Open;

               //Print( "RangeCurrent:"+(string)RangeCurrent );

               //Tick data - using Period defined in chart 
               //MqlRates rates[];
               //ArraySetAsSeries(rates,true);
               int copied;
               copied=CopyRates(AllTradesSet[x].Ativo_Symbol,AllTradesSet[x].Timeframe,0,3,rates);
               //CopyRates(_Symbol,_Period,0,3,rates);
               //if (copied > 0)
               //{
               //   Print("OnTick| Ativo: ",AllTradesSet[x].Ativo_Symbol," |Timeframe: ",AllTradesSet[x].Timeframe," |rates[0].time ",TimeToString(rates[0].time,TIME_DATE|TIME_MINUTES)," | rates[0].CLOSE ",rates[0].close," rates[1].time ",TimeToString(rates[1].time,TIME_DATE|TIME_MINUTES)," | rates[1].CLOSE ",rates[1].close );
               //}


               //=========================================================
               // Verifica qualificadores/ indicadores na abertura do dia
               //=========================================================
               //Print("Verifica qualificadores/ indicadores na abertura do dia");
               //Print("LastDayChecked :" , AllTradesSet[x].LastDayChecked);
               //Print("TimeCurrent : " , TimeToString(TimeCurrent(),TIME_DATE));
               //Print("Rates 0 Time : " , TimeToString(rates[0].time,TIME_DATE));

               //if ( AllTradesSet[x].DailyGAP == 0 && AllTradesSet[x].DailyIBS == 0 && TimeToString(rates[0].time, TIME_DATE) == TimeToString(TimeCurrent(), TIME_DATE) )
               if(AllTradesSet[x].LastDayChecked!=TimeToString(TimeCurrent(),TIME_DATE))
               {
                  //Ambos os valores: de Janela Trace e Quantidade de gains devem estar preenchidos para acionamento do trace
                  if (AllTradesSet[x].TraceWindowDay!=0 && AllTradesSet[x].TraceWindowGain!=0)
                  {
                     // Verifico se a estratégia já esta inserida na matriz de janela trace, varrendo o arquivo de estratégias aptas a trade no dia
                     bool Strategy=false;
                     int Aux=0;
                                    
                     do
                     {
                        int size  = ArraySize(ATraceWindow);
                        if (AuxTrace>=size){
                           ArrayResize(ATraceWindow,AuxTrace+1,50); 
                        }
                        if (AllTradesSet[x].Strategy==ATraceWindow[Aux].Strategy)         //comparo se estratégias aptas no dia com matriz trace
                        {
                           Strategy=true;
                           break;
                        };
                        Aux+=1;                  
                     }                   
                     while(Aux<=(ArraySize(ATraceWindow)-1));    // fim da verificação da janela trace
                     
                     // Insiro uma nova estratégia na matriz com a estratégia, os dias e quantidade de gain para acionamento do trace
                     if (!Strategy)
                     {
                        ATraceWindow[AuxTrace].Strategy=AllTradesSet[x].Strategy;                // Nome da estratégia
                        ATraceWindow[AuxTrace].TraceWindowDay=AllTradesSet[x].TraceWindowDay;    // Dia do trace
                        ATraceWindow[AuxTrace].TraceWindowGain=AllTradesSet[x].TraceWindowGain;  // Qtde dia de gain
                        ATraceWindow[AuxTrace].WindowInvert= TraceWindow(AllTradesSet[x].Strategy,AllTradesSet[x].TraceWindowDay,
                        AllTradesSet[x].TraceWindowGain);  //procedimento para verificar se window acionada
                        if(ExibirLogsDetalhados)
                           Print("OnTick| 2 - TradeID:",AllTradesSet[x].TradeID," Estratégia: ",AllTradesSet[x].Strategy," Inversão de Janela: "+(string)ATraceWindow[AuxTrace].WindowInvert);

                        AuxTrace+=1;                                                             // contador de estratégias inseridas
                    };
                  };
                                                              
                  if(ExibirLogsDetalhados)
                     Print("OnTick| 2 -  Novo dia comecou. Solicitado indicadores diarios.");

                  NewDayStarted=TimeCurrent(); // Indica que um novo dia comecou e guarda este dia
                  AllTradesSet[x].LastDayChecked=TimeToString(TimeCurrent(),TIME_DATE);

                  //GAP ---- Daily Gap: Open - Yesterday close
                  GAP=DailyOpen-Y_Close;
                  DailyGAP=GAP;
                  // ZScore do DailyGAPZScore - janela foi prolongada em +1 para pegar sempre fechamento do dia anterior ao loop da vez
                  DailyGAPZScore=ZScore("GAP",AllTradesSet[x].WindowZScore,0,0,DailyGAP);
                  if(ExibirLogsDetalhados)
                     Print("OnTick| 2 - TradeID:",AllTradesSet[x].TradeID," Parametros de abertura. Ativo:",AllTradesSet[x].Ativo_Symbol,"DailyOpen: "+(string)DailyOpen+" Y_Close: "+(string)Y_Close+" Daily[1].close: "+(string)Daily[1].close+" Daily[1].low: "+(string)Daily[1].low+" Daily[1].high: "+(string)Daily[1].high);

                  if(ExibirLogsDetalhados)
                     Print("OnTick| 2 - TradeID:",AllTradesSet[x].TradeID," Ativo:",AllTradesSet[x].Ativo_Symbol," |GAP do dia "+TimeToString(TodayOpen,TIME_DATE)+" |GAP: "+(string)GAP);
                     Print("OnTick| 2 - TradeID:",AllTradesSet[x].TradeID," Ativo:",AllTradesSet[x].Ativo_Symbol," |GAP do dia em ZScore "+TimeToString(TodayOpen,TIME_DATE)+" |GAP ZScore: "+(string)DailyGAPZScore);

                  //IBS1
                  IBS1=(( Daily[1].close-Daily[1].low)/(Daily[1].high-Daily[1].low));
                  DailyIBS1=IBS1;

                  if(ExibirLogsDetalhados)
                     Print("OnTick| 2 - TradeID:",AllTradesSet[x].TradeID," Ativo:",AllTradesSet[x].Ativo_Symbol," |IBS.1 do dia: "+TimeToString(TodayOpen,TIME_DATE)+" |IBS.1: "+StringFormat("%.2f",IBS1));

                  //Range1
                  Range1=(Daily[1].high-Daily[1].low);
                  // ZScore do RANGE.1 é uma leitura a menos pois o próprio RANGE.1 já é um dia anterior
                  double ZScoreRangeValueTop;
                  double ZScoreRangeValueBottom;
                  ZScoreRange("RANGEV", (AllTradesSet[x].WindowZScore-1),Range1,0,0,Range1_ZScore,ZScoreRangeValueTop,ZScoreRangeValueBottom);
                  if(ExibirLogsDetalhados)
                      Print("OnTick| 2 - TradeID:",AllTradesSet[x].TradeID," Ativo:",AllTradesSet[x].Ativo_Symbol," |Range.1 do dia: "+TimeToString(TodayOpen,TIME_DATE)+" |Range.1 em Z-SCore: "+StringFormat("%.2f",Range1_ZScore));

                  //CTO1
                  CTO1=(Daily[1].close-Daily[1].open);
                  // ZScore do CTO.1 é uma leitura a menos pois o próprio CTO.1 já é um dia anterior
                  CTO1_ZScore=ZScore("CTO.1", (AllTradesSet[x].WindowZScore-1));
                  if(ExibirLogsDetalhados)
                     //Print("OnTick| 2 - TradeID:",AllTradesSet[x].TradeID," Ativo:",AllTradesSet[x].Ativo_Symbol," |CTO.1 do dia: "+TimeToString(TodayOpen,TIME_DATE)+" |CTO.1: "+StringFormat("%.2f",CTO1));
                     Print("OnTick| 2 - TradeID:",AllTradesSet[x].TradeID," Ativo:",AllTradesSet[x].Ativo_Symbol," |CTO.1 do dia: "+TimeToString(TodayOpen,TIME_DATE)+" |CTO.1 em Z-SCore: "+StringFormat("%.2f",CTO1_ZScore));

                  //LAST 4 DAYS - 4D

                  // Verifica o Quaddrante do dia
                  LMC = Monthly[1].close;
                  DOM = StringToInteger( StringSubstr(TimeToString(TimeCurrent(),TIME_DATE),8,2) );

                  if(ExibirLogsDetalhados)
                     Print("OnTick| TradeID:",AllTradesSet[x].TradeID," Ativo:",AllTradesSet[x].Ativo_Symbol," |Dados do dia: "+TimeToString(TodayOpen,TIME_DATE)+" |LMC: "+(string)LMC+" |DOM: "+(string)DOM+" |Dia_MidMonth: "+(string)Dia_MidMonth+" |DailyOpen: "+(string)DailyOpen);
                  //Print( "OnTick| TradeID:",AllTradesSet[x].TradeID," Ativo:",AllTradesSet[x].Ativo_Symbol," |Dados do dia: "+TimeToString(TodayOpen, TIME_DATE)+" |LMC: "+(string)LMC+" |DOM: "+(string)DOM+" |Dia_MidMonth: "+(string)Dia_MidMonth );

                  if(DailyOpen>=LMC) // Acima do fechamento do mes anterior
                    {
                     if(DOM<=Dia_MidMonth) // Inicio do mes
                       {
                        DailyMonthQuadrant="1+";
                       }
                     else if(DOM>Dia_MidMonth) // Final do mes
                       {
                        DailyMonthQuadrant="2+";
                       }
                     else
                       {
                        Print("OnTick| Verificar MonthQuadrant. +DOM");
                       }
                    }
                  else if(DailyOpen<LMC) // Abaixo do fechamento do mes anterior
                    {
                     if(DOM<=Dia_MidMonth) // Inicio do mes
                       {
                        DailyMonthQuadrant="1-";
                       }
                     else if(DOM>Dia_MidMonth) // Final do mes
                       {
                        DailyMonthQuadrant="2-";
                       }
                     else
                       {
                        Print("OnTick| Verificar MonthQuadrant. DOM");
                       }
                    }
                  else
                    {
                     Print("OnTick| Verificar MonthQuadrant. LMC");
                    }

                  if(ExibirLogsDetalhados)
                     Print("OnTick| TradeID:",AllTradesSet[x].TradeID," Ativo:",AllTradesSet[x].Ativo_Symbol," |Dia: "+TimeToString(TodayOpen,TIME_DATE)+" |MonthQuadrant: ",DailyMonthQuadrant);

                 } // Verifica qualificadores/ indicadores na abertura do dia 

               if(DailyMonthQuadrant=="")
                 {
                  Print("DailyMonthQuadrant Vazio");
                  //Print("OnTick| 2 - LastDayChecked ",AllTradesSet[x].LastDayChecked);
                  //Print("OnTick| 2 - rates[0].time ",TimeToString(rates[0].time,TIME_DATE));
                  //Print("OnTick| 2 - TimeCurrent ",TimeToString(TimeCurrent(),TIME_DATE));

                  // Verifica o Quaddrante do dia
                  LMC = Monthly[1].close;
                  DOM = StringToInteger( StringSubstr(TimeToString(TimeCurrent(),TIME_DATE),8,2) );
                  //Print("OnTick| TradeID:",AllTradesSet[x].TradeID," Ativo:",AllTradesSet[x].Ativo_Symbol," |Dados do dia: "+TimeToString(TodayOpen,TIME_DATE)+" |LMC: "+(string)LMC+" |DOM: "+(string)DOM+" |Dia_MidMonth: "+(string)Dia_MidMonth+" |DailyOpen: "+(string)DailyOpen);
                  //Print( "OnTick| TradeID:",AllTradesSet[x].TradeID," Ativo:",AllTradesSet[x].Ativo_Symbol," |Dados do dia: "+TimeToString(TodayOpen, TIME_DATE)+" |LMC: "+(string)LMC+" |DOM: "+(string)DOM+" |Dia_MidMonth: "+(string)Dia_MidMonth );

                  if(DailyOpen>=LMC) // Acima do fechamento do mes anterior
                    {
                     if(DOM<=Dia_MidMonth) // Inicio do mes
                       {
                        DailyMonthQuadrant="1+";
                       }
                     else if(DOM>Dia_MidMonth) // Final do mes
                       {
                        DailyMonthQuadrant="2+";
                       }
                     else
                       {
                        Print("OnTick| Verificar MonthQuadrant. +DOM");
                       }
                    }
                  else if(DailyOpen<LMC) // Abaixo do fechamento do mes anterior
                    {
                     if(DOM<=Dia_MidMonth) // Inicio do mes
                       {
                        DailyMonthQuadrant="1-";
                       }
                     else if(DOM>Dia_MidMonth) // Final do mes
                       {
                        DailyMonthQuadrant="2-";
                       }
                     else
                       {
                        Print("OnTick| Verificar MonthQuadrant. DOM");
                       }
                    }
                  else
                    {
                     Print("OnTick| Verificar MonthQuadrant. LMC");
                    }
                  if(ExibirLogsDetalhados)
                     Print("OnTick| TradeID:",AllTradesSet[x].TradeID," Ativo:",AllTradesSet[x].Ativo_Symbol," |Dia: "+TimeToString(TodayOpen,TIME_DATE)+" |MonthQuadrant: ",DailyMonthQuadrant);

                 }

               //Check Daily Filters

               //Check IBS.1
               if(DailyIBS1<AllTradesSet[x].IBS_Bottom || DailyIBS1>AllTradesSet[x].IBS_Top)
                 {
                  //AllTradesSet[x].Trade_Status = "FINISHED"; // Condicao do dia nao satisfeita para esta configuracao
                  TradeForToday=false; // Condicao do dia nao satisfeita para esta configuracao
                  if(ExibirLogsDetalhados)
                     Print("OnTick| TradeID: ",AllTradesSet[x].TradeID,"/"+(string)AllTradesSet[x].TradeType+"/"+(string)AllTradesSet[x].Trade_Status+"/"+(string)AllTradesSet[x].TradeDirection+" Finalizado. Filtro diario IBS.1 nao satisfeito.  IBS.1: "+(string)IBS1+" |Maximo(IBS.1_Top): "+(string)AllTradesSet[x].IBS_Top+" |Minimo(IBS.1_Bottom): "+(string)AllTradesSet[x].IBS_Bottom);
                  continue;
                 }

               //Check GAP
               //SYMBOL_POINT AJUSTE
               // In Point current mode
               //if(DailyGAP<AllTradesSet[x].GAP_Bottom || DailyGAP>AllTradesSet[x].GAP_Top)
               //In ZScore Mode
               if(DailyGAPZScore<AllTradesSet[x].GAP_Bottom || DailyGAPZScore>AllTradesSet[x].GAP_Top)
                 {
                  //AllTradesSet[x].Trade_Status = "FINISHED"; // Condicao do dia nao satisfeita para esta configuracao
                  TradeForToday=false; // Condicao do dia nao satisfeita para esta configuracao
                  if(ExibirLogsDetalhados)
                     Print("OnTick| TradeID: ",AllTradesSet[x].TradeID,"/"+(string)AllTradesSet[x].TradeType+"/"+(string)AllTradesSet[x].Trade_Status+"/"+(string)AllTradesSet[x].TradeDirection+" Finalizado. Filtro diario GAP nao satisfeito. GAP: "+(string)GAP+" |Maximo: "+(string)AllTradesSet[x].GAP_Top+" |Minimo: "+(string)AllTradesSet[x].GAP_Bottom+". Trade_Status: "+(string)AllTradesSet[x].Trade_Status);
                     Print("OnTick| TradeID: ",AllTradesSet[x].TradeID,"/"+(string)AllTradesSet[x].TradeType+"/"+(string)AllTradesSet[x].Trade_Status+"/"+(string)AllTradesSet[x].TradeDirection+" Finalizado. Filtro diario GAP nao satisfeito. GAP: "+(string)GAP+" |Maximo: "+(string)AllTradesSet[x].GAP_Top+" |Minimo: "+(string)AllTradesSet[x].GAP_Bottom+". GAP em ZScore: "+(string)DailyGAPZScore);
                     continue;
                 }

               //Check Range.1
               //if(Range1<AllTradesSet[x].Range1_Bottom || Range1>AllTradesSet[x].Range1_Top)
               if(Range1_ZScore<AllTradesSet[x].Range1_Bottom || Range1_ZScore>AllTradesSet[x].Range1_Top)

                 {
                  //AllTradesSet[x].Trade_Status = "FINISHED"; // Condicao do dia nao satisfeita para esta configuracao
                  TradeForToday=false; // Condicao do dia nao satisfeita para esta configuracao
                  Print("OnTick| TradeID: ",AllTradesSet[x].TradeID,"/"+(string)AllTradesSet[x].TradeType+"/"+(string)AllTradesSet[x].Trade_Status+"/"+(string)AllTradesSet[x].TradeDirection+" Finalizado. Filtro diario Range.1 nao satisfeito.  Range.1 em Z-Score: "+(string)Range1_ZScore+" |Maximo(Range.1_Top): "+(string)AllTradesSet[x].Range1_Top+" |Minimo(Range.1_Bottom): "+(string)AllTradesSet[x].Range1_Bottom);
                  continue;
                 }
               //Check CTO.1
               //if(CTO1<AllTradesSet[x].CTO1_Bottom || CTO1>AllTradesSet[x].CTO1_Top)
               if(CTO1_ZScore<AllTradesSet[x].CTO1_Bottom || CTO1_ZScore>AllTradesSet[x].CTO1_Top)
                 {
                  //AllTradesSet[x].Trade_Status = "FINISHED"; // Condicao do dia nao satisfeita para esta configuracao
                  TradeForToday=false; // Condicao do dia nao satisfeita para esta configuracao
                  if(ExibirLogsDetalhados)
                     Print("OnTick| TradeID: ",AllTradesSet[x].TradeID,"/"+(string)AllTradesSet[x].TradeType+"/"+(string)AllTradesSet[x].Trade_Status+"/"+(string)AllTradesSet[x].TradeDirection+" Finalizado. Filtro diario CTO.1 nao satisfeito.  CTO.1 em Z-Score: "+(string)CTO1_ZScore+" |Maximo(CTO.1_Top): "+(string)AllTradesSet[x].CTO1_Top+" |Minimo(CTO.1_Bottom): "+(string)AllTradesSet[x].CTO1_Bottom);
                  continue;
                 }

               //Check MonthQuadrant [1+/1-/2+/2-]
               //if ( AllTradeSet[x].MonthQuadrant != "" )
               if(StringFind(AllTradesSet[x].MonthQuadrant,DailyMonthQuadrant)<0)
                 {
                  if(AllTradesSet[x].MonthQuadrant!=DailyMonthQuadrant)
                    {
                     //AllTradesSet[x].Trade_Status = "FINISHED"; // Condicao do dia nao satisfeita para esta configuracao
                     TradeForToday=false; // Condicao do dia nao satisfeita para esta configuracao
                     if(ExibirLogsDetalhados)
                        Print("OnTick| TradeID: ",AllTradesSet[x].TradeID,"/"+(string)AllTradesSet[x].TradeType+"/"+(string)AllTradesSet[x].Trade_Status+"/"+(string)AllTradesSet[x].TradeDirection+" Finalizado. Filtro diario MonthQuadrant nao satisfeito.  DailyMonthQuadrant: "+(string)DailyMonthQuadrant+" |MonthQuadrant: "+AllTradesSet[x].MonthQuadrant);
                     continue;
                    }
                  else
                    {
                     if(ExibirLogsDetalhados)
                        Print("OnTick| TradeID: ",AllTradesSet[x].TradeID,"/"+(string)AllTradesSet[x].TradeType+"/"+(string)AllTradesSet[x].Trade_Status+"/"+(string)AllTradesSet[x].TradeDirection+" Verificar o filtro MonthQuadrant.  DailyMonthQuadrant: "+(string)AllTradesSet[x].DailyMonthQuadrant+" |MonthQuadrant: "+AllTradesSet[x].MonthQuadrant);
                    }
                 }

               //Check WeekDays [SUN/MON/TUE/WED/THU/FRI/SAT]
               if(StringFind(AllTradesSet[x].WeekDays,DayofWeek)<0)
                 {
                  //MySet[x].Trade_Status = "FINISHED"; // Condicao do dia nao satisfeita para esta configuracao
                  TradeForToday=false; // Condicao do dia nao satisfeita para esta configuracao
                  Print("OnTick| Trade number: ",x,"/"+(string)AllTradesSet[x].TradeType+"/"+(string)AllTradesSet[x].Trade_Status+"/"+(string)AllTradesSet[x].TradeDirection+" Finalizado. Dia da Semana: "+(string)DayofWeek+" |Periodo permitido: "+(string)AllTradesSet[x].WeekDays);
                  continue;
                 }

               if(TradeForToday==true) // Adiciona trade ao array diario - MySet
                 {
                  int RowsCopiadas=0;
                  // Ajusta tamanho do Array usado para controle dos trades
                  ArrayResize(MySet,ArraySize(MySet)+1,1000);
                  // Add new valid Trade
                  int n=ArraySize(MySet)-1;

                  if(ExibirLogsDetalhados)
                     Print("Adicionando trade ",AllTradesSet[x].TradeID," para o dia: ",TimeToString(TimeCurrent(),TIME_DATE)," Total de trades para o dia: ",n);

                  //RowsCopiadas = ArrayCopy(MySet,AllTradesSet,n,x,1);

                  MySet[n].TradeID=AllTradesSet[x].TradeID;
                  MySet[n].Ativo_Symbol=AllTradesSet[x].Ativo_Symbol;
                  MySet[n].Strategy=AllTradesSet[x].Strategy;
                  //doubleSYMBOL_POINT = SymbolInfoDouble(MySet[n].Ativo_Symbol,SYMBOL_POINT);   // Identifica o Symbol_Point do Ativo(Symbol)
                  MySet[n].Timeframe = AllTradesSet[x].Timeframe;
                  MySet[n].TradeType = AllTradesSet[x].TradeType;
                  MySet[n].IBS_Top=AllTradesSet[x].IBS_Top;
                  MySet[n].IBS_Bottom=AllTradesSet[x].IBS_Bottom;
                  MySet[n].GAP_Top=AllTradesSet[x].GAP_Top;
                  MySet[n].GAP_Bottom = AllTradesSet[x].GAP_Bottom;
                  MySet[n].Range1_Top = AllTradesSet[x].Range1_Top;
                  MySet[n].Range1_Bottom=AllTradesSet[x].Range1_Bottom;
                  MySet[n].CTO1_Top=AllTradesSet[x].CTO1_Top;
                  MySet[n].CTO1_Bottom=AllTradesSet[x].CTO1_Bottom;
                  MySet[n].MonthQuadrant=AllTradesSet[x].MonthQuadrant;
                  MySet[n].WeekDays=AllTradesSet[x].WeekDays;
                  MySet[n].CTO=AllTradesSet[x].CTO;
                  MySet[n].CTC1=AllTradesSet[x].CTC1;
                  MySet[n].MID1_Reference=AllTradesSet[x].MID1_Reference;
                  MySet[n].DailyBGSV=AllTradesSet[x].DailyBGSV;
                  MySet[n].DayPosition=AllTradesSet[x].DayPosition;
                  MySet[n].HighLow=AllTradesSet[x].HighLow;
                  MySet[n].HighLow_PreLimit=AllTradesSet[x].HighLow_PreLimit;

                  MySet[n].Range_Min = AllTradesSet[x].Range_Min;
                  MySet[n].Range_Max = AllTradesSet[x].Range_Max;
                  MySet[n].RangeHighLow=AllTradesSet[x].RangeHighLow;
                  MySet[n].RRetreat_Perc= AllTradesSet[x].RRetreat_Perc;
                  MySet[n].RRetreat_Max_Timer=AllTradesSet[x].RRetreat_Max_Timer;
                  MySet[n].RRetreat_point=AllTradesSet[x].RRetreat_point;

                  MySet[n].TradeDirection= AllTradesSet[x].TradeDirection;
                  MySet[n].TradeOnNewBar = AllTradesSet[x].TradeOnNewBar;
                  MySet[n].EntryOrder_OrderType= AllTradesSet[x].EntryOrder_OrderType;
                  MySet[n].EarlyOrder_Distance = AllTradesSet[x].EarlyOrder_Distance;
                  MySet[n].TgtOrder_OrderType=AllTradesSet[x].TgtOrder_OrderType;
                  MySet[n].TakeProfit=AllTradesSet[x].TakeProfit;                  
                  double ValueCurrentZScore=0;
                  //Aproveito a mesma função do HIGHLOW para conversão do take profit de ZSCore para pontos
                  ZScoreHighLow(AllTradesSet[x].WindowZScore,0,MySet[n].TakeProfit,ValueCurrentZScore,MySet[n].TakeProfitPoints);                 
                  MySet[n].StopLoss=AllTradesSet[x].StopLoss;                             // In ZSCore Points
                   //Aproveito a mesma função do HIGHLOW para conversão do Stop Loss de ZSCore para pontos
                  ZScoreHighLow(AllTradesSet[x].WindowZScore,0,MySet[n].StopLoss,ValueCurrentZScore,MySet[n].StopLossPoints);                 
                  
                  MySet[n].TakeProfit_PercRange=AllTradesSet[x].TakeProfit_PercRange;
                  MySet[n].StopLoss_PercRange=AllTradesSet[x].StopLoss_PercRange;
                  Print("MySet[n].TakeProfit_PercRange=",MySet[n].TakeProfit_PercRange," |AllTradesSet[x].TakeProfit_PercRange=",AllTradesSet[x].TakeProfit_PercRange);
                  Print("MySet[n].StopLoss_PercRange=",MySet[n].StopLoss_PercRange," |AllTradesSet[x].StopLoss_PercRange=",AllTradesSet[x].StopLoss_PercRange);
                  MySet[n].UseTrailingStop=AllTradesSet[x].UseTrailingStop;
                  MySet[n].TrailingStop=AllTradesSet[x].TrailingStop;
                  MySet[n].MinimumProfit=AllTradesSet[x].MinimumProfit;
                  MySet[n].Step=AllTradesSet[x].Step;
                  MySet[n].UseMoneyManagement=AllTradesSet[x].UseMoneyManagement;
                  MySet[n].RiskPercent = AllTradesSet[x].RiskPercent;
                  MySet[n].FixedVolume = AllTradesSet[x].FixedVolume;
                  MySet[n].UseTimer=AllTradesSet[x].UseTimer;
                  MySet[n].StartTimer=AllTradesSet[x].StartTimer;
                  MySet[n].EndTimer=AllTradesSet[x].EndTimer;
                  MySet[n].StartHour=AllTradesSet[x].StartHour;
                  MySet[n].StartMinute=AllTradesSet[x].StartMinute;
                  MySet[n].EndHour=AllTradesSet[x].EndHour;
                  MySet[n].EndMinute=AllTradesSet[x].EndMinute;
                  MySet[n].UseEntryTimer=AllTradesSet[x].UseEntryTimer;
                  MySet[n].EntryStartTimer=AllTradesSet[x].EntryStartTimer;
                  MySet[n].EntryEndTimer=AllTradesSet[x].EntryEndTimer;
                  MySet[n].EntryStartHour=AllTradesSet[x].EntryStartHour;
                  MySet[n].EntryStartMinute=AllTradesSet[x].EntryStartMinute;
                  MySet[n].WindowZScore=AllTradesSet[x].WindowZScore;
                  MySet[n].EntryEndHour=AllTradesSet[x].EntryEndHour;
                  MySet[n].EntryEndMinute=AllTradesSet[x].EntryEndMinute;

                  // QUANTTREND
                  //MySet[n].WPRLength = AllTradesSet[x].WPRLength;
                  //MySet[n].WPR_CutLevel;
                  //MySet[n].WPR_CutLevel_Side;
                  //MySet[n].wMALength;
                  //MySet[n].wMA_Side;
                  //MySet[n].wMAMethod;
                  //MySet[n].wMAShift;
                  //MySet[n].wMAPrice;

                  MySet[n].EntryRef_Open_Top=AllTradesSet[x].EntryRef_Open_Top;
                  MySet[n].EntryRef_Open_Bottom=AllTradesSet[x].EntryRef_Open_Bottom;
                  MySet[n].EntryPoint=AllTradesSet[x].EntryPoint;

                  MySet[n].EntryBar=AllTradesSet[x].EntryBar;
                  MySet[n].Entry_ABoveBelow=AllTradesSet[x].Entry_ABoveBelow;
                  MySet[n].RangePerc_to_Entry=AllTradesSet[x].RangePerc_to_Entry;
                  MySet[n].DailyFactor_Max = AllTradesSet[x].DailyFactor_Max;
                  MySet[n].DailyFactor_Min = AllTradesSet[x].DailyFactor_Min;

                  MySet[n].BaseBSPBOP=AllTradesSet[n].BaseBSPBOP;
                  MySet[n].BSP_BOP=AllTradesSet[n].BSP_BOP;

                  MySet[n].InvertPosition=AllTradesSet[n].InvertPosition;

                  MySet[n].DailyFactor=AllTradesSet[x].DailyFactor;
                  MySet[n].CalcBarRange= AllTradesSet[x].CalcBarRange;
                  MySet[n].CalcBarBody = AllTradesSet[x].CalcBarBody;
                  MySet[n].CalcBarBodyAbs=AllTradesSet[x].CalcBarBodyAbs;

                  MySet[n].Daily_BarCounter=AllTradesSet[n].Daily_BarCounter;
                  MySet[n].CalcBarRange= AllTradesSet[n].CalcBarRange;
                  MySet[n].DailyFactor = AllTradesSet[n].DailyFactor;
                  MySet[n].CalcBarBody = AllTradesSet[n].CalcBarBody;
                  MySet[n].CalcBarBodyAbs=AllTradesSet[n].CalcBarBodyAbs;

                  MySet[n].Timer_RefPoint=AllTradesSet[x].Timer_RefPoint;
                  MySet[n].Timer_EntryPoint=AllTradesSet[x].Timer_EntryPoint;
                  MySet[n].Timer_Ref_fromDailyOpen=AllTradesSet[x].Timer_Ref_fromDailyOpen;

                  MySet[n].EntryBar=AllTradesSet[n].EntryBar;
                  MySet[n].Entry_ABoveBelow=AllTradesSet[n].Entry_ABoveBelow;
                  MySet[n].RangePerc_to_Entry=AllTradesSet[n].RangePerc_to_Entry;
                  MySet[n].DailyFactor_Max = AllTradesSet[n].DailyFactor_Max;
                  MySet[n].DailyFactor_Min = AllTradesSet[n].DailyFactor_Min;

                  MySet[n].DailyGAP = DailyGAP;
                  MySet[n].DailyGAPZScore = DailyGAPZScore;
                  MySet[n].DailyIBS = DailyIBS1;
                  MySet[n].DailyRange1=Range1;
                  MySet[n].DailyCTO1=CTO1;
                  MySet[n].DailyMonthQuadrant=DailyMonthQuadrant;
                  MySet[n].LastBar_Time= AllTradesSet[x].LastBar_Time;
                  MySet[n].glBuyPlaced = AllTradesSet[x].glBuyPlaced;
                  MySet[n].glSellPlaced = AllTradesSet[x].glSellPlaced;
                  MySet[n].glPlaceOrder = AllTradesSet[x].glPlaceOrder;
                  MySet[n].glOrderPlaced= AllTradesSet[x].glOrderPlaced;
                  MySet[n].glOrderexecuted=AllTradesSet[x].glOrderexecuted;
                  MySet[n].glTargetOrderPlaced=AllTradesSet[x].glTargetOrderPlaced;
                  MySet[n].glStopOrderPlaced=AllTradesSet[x].glStopOrderPlaced;
                  MySet[n].RangeLineObj= AllTradesSet[x].RangeLineObj;
                  MySet[n].RangeHitDay = AllTradesSet[x].RangeHitDay;
                  MySet[n].RangeLevel=AllTradesSet[x].RangeLevel;
                  MySet[n].RangeHit=AllTradesSet[x].RangeHit;
                  MySet[n].LastDailyHigh= AllTradesSet[x].LastDailyHigh;
                  MySet[n].LastDailyLow = AllTradesSet[x].LastDailyLow;
                  MySet[n].OrderSize=AllTradesSet[x].OrderSize;
                  MySet[n].PosicaoAtual=AllTradesSet[x].PosicaoAtual;
                  MySet[n].EntryOrder_OrderNumber=AllTradesSet[x].EntryOrder_OrderNumber;
                  MySet[n].EntryOrder_Status=AllTradesSet[x].EntryOrder_Status;
                  MySet[n].EntryOrder_type=AllTradesSet[x].EntryOrder_type;
                  MySet[n].EntryOrder_Volume=AllTradesSet[x].EntryOrder_Volume;
                  MySet[n].EntryOrder_VolExec=AllTradesSet[x].EntryOrder_VolExec;
                  MySet[n].EntryOrder_Price=AllTradesSet[x].EntryOrder_Price;
                  MySet[n].EntryOrder_PriceExec = AllTradesSet[x].EntryOrder_PriceExec;
                  MySet[n].EntryOrder_StopPrice = AllTradesSet[x].EntryOrder_StopPrice;
                  MySet[n].TargetTicketNumber=AllTradesSet[x].TargetTicketNumber;
                  MySet[n].TgtOrder_OrderNumber=AllTradesSet[x].TgtOrder_OrderNumber;
                  MySet[n].TgtOrder_Status=AllTradesSet[x].TgtOrder_Status;
                  MySet[n].TgtOrder_type=AllTradesSet[x].TgtOrder_type;
                  MySet[n].TgtOrder_Volume=AllTradesSet[x].TgtOrder_Volume;
                  MySet[n].TgtOrder_VolExec=AllTradesSet[x].TgtOrder_VolExec;
                  MySet[n].TgtOrder_Price=AllTradesSet[x].TgtOrder_Price;
                  MySet[n].TgtOrder_PriceExec=AllTradesSet[x].TgtOrder_PriceExec;
                  MySet[n].TgtOrder_ObjName=AllTradesSet[x].TgtOrder_ObjName;
                  MySet[n].StopLossTicketNumber=AllTradesSet[x].StopLossTicketNumber;
                  MySet[n].StopOrder_OrderNumber=AllTradesSet[x].StopOrder_OrderNumber;
                  MySet[n].StopOrder_Status=AllTradesSet[x].StopOrder_Status;
                  MySet[n].StopOrder_type=AllTradesSet[x].StopOrder_type;
                  MySet[n].StopOrder_Volume=AllTradesSet[x].StopOrder_Volume;
                  MySet[n].StopOrder_VolExec=AllTradesSet[x].StopOrder_VolExec;
                  MySet[n].StopOrder_Price=AllTradesSet[x].StopOrder_Price;
                  MySet[n].StopOrder_PriceExec=AllTradesSet[x].StopOrder_PriceExec;
                  MySet[n].Trade_Status=AllTradesSet[x].Trade_Status;

                  MySet[n].MaPeriodo=AllTradesSet[x].MaPeriodo;
                  MySet[n].MaHandle=AllTradesSet[x].MaHandle;
                  MySet[n].MaPosition=AllTradesSet[x].MaPosition;

                  //IBS N Periodos
                  //MySet[n].IBS_N_Timeframe=AllTradesSet[x].IBS_N_Timeframe;
                  //MySet[n].IBS_N_Periodos=AllTradesSet[x].IBS_N_Periodos;
                  //MySet[n].IBS_N_Bottom=AllTradesSet[x].IBS_N_Bottom;
                  //MySet[n].IBS_N_Top=AllTradesSet[x].IBS_N_Top;
                  if(ExibirLogsDetalhados)
                     Print("OnTick| TradeID: ",AllTradesSet[x].TradeID," Valido para este dia. Linhas copiadas:",ArraySize(MySet));
                 }
               else
                 {
                  Print("OnTick| TradeID: ",AllTradesSet[x].TradeID," Descartado para este dia.");
                 }

              } // Verifica qualificadores/ indicadores na abertura do dia

         } // Verifica se novo dia comecou

         // Mostra os valores da conta em tempo real
         //Print( "AccountInfo/ ACCOUNT_BALANCE: "+(string)AccountInfoDouble(ACCOUNT_BALANCE) );
         //Print( "AccountInfo/ ACCOUNT_EQUITY : "+(string)AccountInfoDouble(ACCOUNT_EQUITY) );



         ////////////////////////////////////////////////////////
         // START LOOPIN DAILY TRADES
         ////////////////////////////////////////////////////////         
         //Print( "OnTick| NewDayStarted ",TimeToString(NewDayStarted,TIME_DATE)," TimeCurrent() ",TimeToString(TimeCurrent(),TIME_DATE) );
         if(TimeToString(NewDayStarted,TIME_DATE)==TimeToString(TimeCurrent(),TIME_DATE))
           {

            //Print("OnTick| START LOOPING DAILY TRADES!");

            // Looping para verificar todos os trades da estrategia, individualmente
            for(int x=0;x<=(ArraySize(MySet)-1); x++)
              {

               //Print("Checkpoint do RA! "+(string)TimeCurrent() );
               //Print("OnTick| TradeID: ",MySet[x].TradeID," |Ativo: ",MySet[x].Ativo_Symbol," |Timeframe: ",MySet[x].Timeframe," |Trade_Status: ",MySet[x].Trade_Status," |FIM."  );

               // Checkpoint para debug
               if(TimeCurrent()==StringToTime("2016.10.06 11:29"))
                 {
                  Print("Checkpoint! "+(string)TimeCurrent());
                  //Print("OnTick| Checkpoint! ",x," |Trade_Status",MySet[x].Trade_Status," |EntryOrder_Status ",MySet[x].EntryOrder_Status," |TgtOrder_Status ",MySet[x].TgtOrder_Status," |StopOrder_Status ",MySet[x].StopOrder_Status  );
                 }

               //Trade parameters
               bool CancelPreviousOrder=false;

               //RESTART DURING THE DAY
               // Check if trade finished for today
               if(MySet[x].Trade_Status=="FINISHED")
                 {
                  if(MySet[x].TradeType=="ROUNDN")
                    {
                     if(MySet[x].EntryOrder_Status=="FILLED" && (MySet[x].TgtOrder_Status=="FILLED" || MySet[x].TgtOrder_Status=="CANCELED") && (MySet[x].StopOrder_Status=="FILLED" || MySet[x].StopOrder_Status=="CANCELED"))
                       {
                        // Restart Trade variables. Continue trading during the day
                        //Reinicia variaveis de MoneyManagement
                        MySet[x].OrderSize=0;

                        //Reinicia variaveis de controle de trade realizado no dia
                        MySet[x].Trade_Status = "WAITING";
                        MySet[x].glPlaceOrder = false;
                        MySet[x].glOrderPlaced= false;
                        MySet[x].glOrderexecuted=false;
                        MySet[x].glBuyPlaced=false;
                        MySet[x].glSellPlaced=false;
                        MySet[x].glTargetOrderPlaced=false;
                        MySet[x].glStopOrderPlaced=false;

                        //Reinicia variaveis de controle de ordens
                        MySet[x].EntryOrder_OrderNumber=0;
                        MySet[x].TargetTicketNumber=0;
                        MySet[x].StopLossTicketNumber=0;

                        //Reinicia variaveis da ordem de entrada
                        MySet[x].EntryOrder_OrderNumber=0;
                        MySet[x].EntryOrder_Status="";
                        MySet[x].EntryOrder_type="";
                        MySet[x].EntryOrder_Volume=0;
                        MySet[x].EntryOrder_VolExec=0;
                        MySet[x].EntryOrder_Price=0;
                        MySet[x].EntryOrder_PriceExec = 0;
                        MySet[x].EntryOrder_StopPrice = 0;

                        //Reinicia variaveis de ordem Target
                        MySet[x].TgtOrder_OrderNumber=0;
                        MySet[x].TgtOrder_Status="";
                        MySet[x].TgtOrder_type="";
                        MySet[x].TgtOrder_Volume=0;
                        MySet[x].TgtOrder_VolExec=0;
                        MySet[x].TgtOrder_Price=0;
                        MySet[x].TgtOrder_PriceExec=0;

                        //Stop Order variables
                        MySet[x].StopLossTicketNumber=0;
                        MySet[x].StopOrder_OrderNumber=0;
                        MySet[x].StopOrder_Status="";
                        MySet[x].StopOrder_type="";
                        MySet[x].StopOrder_Volume=0;
                        MySet[x].StopOrder_VolExec=0;
                        MySet[x].StopOrder_Price=0;
                        MySet[x].StopOrder_PriceExec=0;
                        //Reinicia a inversão da janela
                        MySet[x].TraceWindowInvert=false;

                        Print("OnTick| TradeID:",MySet[x].TradeID," |ROUNDN |Variaveis do trade reiniciadas, pronto para proximo sinal!",TimeCurrent());
                       }
                    } // if ( MySet[x].TradeType == "ROUNDN" )

                 } //if ( MySet[x].Trade_Status == "FINISHED" )

               // Check if trade finished for today
               if(MySet[x].Trade_Status=="FINISHED")
                 {
                  //AJUSTAR_MENSAGEM
                  //Print("ended for now!",x,"/"+(string)MySet[x].TradeType+"/"+(string)MySet[x].Trade_Status+"/"+(string)MySet[x].TradeDirection+" Finalizado. "+MySet[x].Trade_Status);
                  continue;
                 }

               //======================================
               // Update prices
               //======================================
               Price.Update(MySet[x].Ativo_Symbol,MySet[x].Timeframe);
               //Print("Price.Update:"+ Price.Close[0] );

               //======================================
               // Data request
               //======================================

               // Monthly OHLC
               MqlRates Monthly[];
               ArraySetAsSeries(Monthly,true);
               CopyRates(MySet[x].Ativo_Symbol,PERIOD_MN1,0,2,Monthly);

               // Daily OHLC
               //MqlRates Daily[];
               //ArraySetAsSeries(Daily,true);
               CopyRates(MySet[x].Ativo_Symbol,PERIOD_D1,0,3,Daily);
               //CopyRates(_Symbol,PERIOD_D1,0,3,Daily);

               //Parametros/ Filtros diarios
               DailyOpen=Daily[0].open;
               Y_Open = Daily[1].open;
               Y_High = Daily[1].high;
               Y_Low=Daily[1].low;
               Y_MidPoint=Y_Low+((Y_High-Y_Low)/2); // Ponto Medio
               Y_Close=Daily[1].close;
               DailyTime=Daily[0].time;
               RangeCurrent=Daily[0].high-Daily[0].low;
               Range1=Daily[1].high-Daily[1].low;
               CTO1=Daily[1].close-Daily[1].open;

               if(RangeCurrent>MySet[x].LastRange)
                 {
                  // Uma nova máxima ou mínima foi atingida - calculo o zscore
                  ZScoreRange("RANGE", (MySet[x].WindowZScore -1),RangeCurrent,MySet[x].Range_Max,MySet[x].Range_Min, MySet[x].Range_ZScore,
                  MySet[x].Range_MaxPoints ,MySet[x].Range_MinPoints);

                  // Guarda a data e hora da ultima range identificada
                  Range_AtTime=TimeCurrent();
                  MySet[x].RangeLevel_AtTime=Range_AtTime;

                  //Reinicia variavel Retreat_Hitted
                  MySet[x].RRetreat_Hitted=false;
                  MySet[x].RRetreat_Hit_AtTime=0;

                  //Print("OnTick| TradeID:",MySet[x].TradeID," |RangeCurrent: ",RangeCurrent," |LastDailyHigh: ",MySet[x].LastDailyHigh," |LastDailyLow: ",MySet[x].LastDailyLow );
                  if(Daily[0].high>MySet[x].LastDailyHigh)
                    {
                     RangeHighOrLow="HIGH";
                     //Print( "OnTick| TradeID:",MySet[x].TradeID," | RangeHighOrLow: HIGH/",RangeHighOrLow," |Range: ",RangeCurrent," |Range_AtTime: ",TimeToString(Range_AtTime,TIME_DATE|TIME_MINUTES) );
                    }
                  else if(Daily[0].low<MySet[x].LastDailyLow)
                    {
                     RangeHighOrLow="LOW";
                     //Print( "OnTick| TradeID:",MySet[x].TradeID," | RangeHighOrLow:  LOW/",RangeHighOrLow," |Range: ",RangeCurrent," |Range_AtTime: ",TimeToString(Range_AtTime,TIME_DATE|TIME_MINUTES) );
                    }

                  // Ordem STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)

                  if(MySet[x].TradeType=="RRETREAT" && RangeCurrent>=MySet[x].Range_MinPoints && RangeCurrent<=MySet[x].Range_MaxPoints && MySet[x].Trade_Status!="STARTED" && MySet[x].Trade_Status!="FINISHED")
                    {
                     // CALCULAR O PONTO DE ENTRADA
                     if(RangeCurrent>MySet[x].LastRange && RangeHighOrLow=="HIGH" && MySet[x].RangeHighLow=="HIGH")
                       {
                       //Não considera no cálculo o ZScore quando informado percentual do RRetreat
                        if(MySet[x].RRetreat_Perc>0)
                          {
                           MySet[x].RRetreat_point=Daily[0].high -(RangeCurrent*MySet[x].RRetreat_Perc/100);
                           Print("OnTick| TradeID:",MySet[x].TradeID," | EntryPoint: "+(string)MySet[x].RRetreat_point+" | Range atual: "+(string)RangeCurrent+"|"+RangeHighOrLow+" | Retracao em Perc : "+(string)MySet[x].RRetreat_Perc," |TakeProfit_PercRange ",MySet[x].TakeProfit_PercRange," |StopLoss_PercRange",MySet[x].StopLoss_PercRange);
                          }

                        // Calcula pontos de Target, se target baseado em percentual da range
                        if(MySet[x].TakeProfit_PercRange>0) // Prioriza o Target baseado em percentual da Range
                          {
                           MySet[x].TakeProfitPoints=RangeCurrent*MySet[x].TakeProfit_PercRange/100;
                           Print("OnTick| TradeID:",MySet[x].TradeID," | TakeProfit_PercRange: ",MySet[x].TakeProfit_PercRange," | TakeProfit: ",MySet[x].TakeProfitPoints);
                          }

                        // Calcula pontos de Stop, se stop baseado em percentual da range
                        if(MySet[x].StopLoss_PercRange>0) // Prioriza o Stop baseado em percentual da Range
                          {
                           MySet[x].StopLossPoints=RangeCurrent*MySet[x].StopLoss_PercRange/100;
                           Print("OnTick| TradeID:",MySet[x].TradeID," | StopLoss_PercRange: ",MySet[x].StopLoss_PercRange," | StopLoss: ",MySet[x].StopLossPoints);
                          }
                       }
                     else if(RangeCurrent>MySet[x].LastRange && RangeHighOrLow=="LOW" && MySet[x].RangeHighLow=="LOW")
                       {

                        if(MySet[x].RRetreat_Perc>0)
                          {
                           MySet[x].RRetreat_point=Daily[0].low+(RangeCurrent*MySet[x].RRetreat_Perc/100);
                           Print("OnTick| TradeID:",MySet[x].TradeID," | EntryPoint: "+(string)MySet[x].RRetreat_point+" | Range atual: "+(string)RangeCurrent+"|"+RangeHighOrLow+" | Retracao em Perc : "+(string)MySet[x].RRetreat_Perc," |TakeProfit_PercRange ",MySet[x].TakeProfit_PercRange," |StopLoss_PercRange",MySet[x].StopLoss_PercRange);
                          }

                        // Calcula pontos de Target, se target baseado em percentual da range
                        if(MySet[x].TakeProfit_PercRange>0) // Prioriza o Target baseado em percentual da Range
                          {
                           MySet[x].TakeProfitPoints=RangeCurrent*MySet[x].TakeProfit_PercRange/100;
                           Print("OnTick| TradeID:",MySet[x].TradeID," | TakeProfit_PercRange: ",MySet[x].TakeProfit_PercRange," | TakeProfit: ",MySet[x].TakeProfitPoints);
                          }

                        // Calcula pontos de Stop, se stop baseado em percentual da range
                        if(MySet[x].StopLoss_PercRange>0) // Prioriza o Stop baseado em percentual da Range
                          {
                           MySet[x].StopLossPoints =RangeCurrent*MySet[x].StopLoss_PercRange/100;
                           Print("OnTick| TradeID:",MySet[x].TradeID," | StopLoss_PercRange: ",MySet[x].StopLoss_PercRange," | StopLoss: ",MySet[x].StopLossPoints);
                          }
                       } // CALCULAR O PONTO DE ENTRADA
                    } //if ( RangeCurrent >= MySet[x].Range_Min && RangeCurrent <= MySet[x].Range_Max )
                 }
               else if(MySet[x].TradeType=="RRETREAT" && RangeCurrent==MySet[x].LastRange && MySet[x].RRetreat_point>0 && RangeCurrent>=MySet[x].Range_MinPoints && RangeCurrent<=MySet[x].Range_MaxPoints && MySet[x].Trade_Status!="STARTED" && MySet[x].Trade_Status!="FINISHED")
                 {
                  // Verifica se bateu no ponto de entrada - RETRACAO
                  if(RangeHighOrLow=="HIGH" && MySet[x].RangeHighLow=="HIGH" && rates[0].close<=MySet[x].RRetreat_point && MySet[x].RRetreat_Hitted==false)
                    {
                     MySet[x].RRetreat_Hitted=true;
                     MySet[x].RRetreat_Hit_AtTime=TimeCurrent();

                     Print("OnTick| TradeID:",MySet[x].TradeID," | EntryPoint ATINGIDO: "+(string)MySet[x].RRetreat_point+" | Range atual: "+(string)RangeCurrent+"|"+RangeHighOrLow+" | Retracao em Percentual: "+(string)MySet[x].RRetreat_Perc," |AtTime: ",TimeToString(MySet[x].RRetreat_Hit_AtTime,TIME_MINUTES)," |EntryStartTimer: ",TimeToString(MySet[x].EntryStartTimer,TIME_MINUTES));
                    }
                  else if(RangeHighOrLow=="LOW" && MySet[x].RangeHighLow=="LOW" && rates[0].close>=MySet[x].RRetreat_point && MySet[x].RRetreat_Hitted==false)
                    {
                     MySet[x].RRetreat_Hitted=true;
                     MySet[x].RRetreat_Hit_AtTime=TimeCurrent();

                     Print("OnTick| TradeID:",MySet[x].TradeID," | EntryPoint ATINGIDO: "+(string)MySet[x].RRetreat_point+" | Range atual: "+(string)RangeCurrent+"|"+RangeHighOrLow+" | Retracao em Percentual: "+(string)MySet[x].RRetreat_Perc," |AtTime: ",TimeToString(MySet[x].RRetreat_Hit_AtTime,TIME_MINUTES)," |EntryStartTimer: ",TimeToString(MySet[x].EntryStartTimer,TIME_MINUTES));
                    }

                  // TimeStructure
                  MqlDateTime strRangeLevel_AtTime,strTimeCurrent;
                  double RangeAtTime_inMINUTES,TimeCurrent_inMINUTES;
                  TimeToStruct(MySet[x].RangeLevel_AtTime,strRangeLevel_AtTime);
                  TimeToStruct(TimeCurrent(),strTimeCurrent);
                  RangeAtTime_inMINUTES = strRangeLevel_AtTime.hour*60+strRangeLevel_AtTime.min;
                  TimeCurrent_inMINUTES = strTimeCurrent.hour*60+strTimeCurrent.min;

                  //Print("OnTick| TradeID:",MySet[x].TradeID," | FILTROS: RRetreat_Hit_AtTime=",TimeToString(MySet[x].RRetreat_Hit_AtTime,TIME_DATE|TIME_MINUTES)," |MySet[x].EntryStartTimer=",TimeToString(MySet[x].EntryStartTimer,TIME_DATE|TIME_MINUTES) );
                  //Print("OnTick| TradeID:",MySet[x].TradeID," | FILTROS: MySet[x].RRetreat_Max_Timer: ",MySet[x].RRetreat_Max_Timer," |RangeAtTime_inMINUTES=",RangeAtTime_inMINUTES," |TimeCurrent_inMinutes: ",TimeCurrent_inMINUTES );

                  // Verifica se ponto de retracao atingido antes do horario de trade
                  if(MySet[x].RRetreat_Hitted==true && MySet[x].RRetreat_Hit_AtTime>0 && TimeToString(MySet[x].RRetreat_Hit_AtTime,TIME_MINUTES)<TimeToString(MySet[x].EntryStartTimer,TIME_MINUTES) && TimeToString(TimeCurrent(),TIME_MINUTES)>TimeToString(MySet[x].EntryStartTimer,TIME_MINUTES) && RangeCurrent<MySet[x].Range_MaxPoints)
                    {
                     MySet[x].Trade_Status="FINISHED"; // Ponto e entrada ja foi alcancado no passado. Evitar entrada atrasada
                     Print("OnTick| TradeID:",MySet[x].TradeID," | Horarios do filtro: RRetreat_Hit_AtTime=",TimeToString(MySet[x].RRetreat_Hit_AtTime,TIME_DATE|TIME_MINUTES)," |MySet[x].EntryStartTimer=",TimeToString(MySet[x].EntryStartTimer,TIME_DATE|TIME_MINUTES) );
                     Print("OnTick| TradeID:",MySet[x].TradeID," | Cancelando trade porque ponto de entrada foi atingido antes da janela de horario de entrada permitido para o trade. Trade[ Faixa de range: Min "+(string)MySet[x].Range_MinPoints+"/Max "+(string)MySet[x].Range_MaxPoints+"/"+(string)MySet[x].RangeHighLow+"/"+(string)MySet[x].TradeDirection+"| Range atual: "+(string)RangeCurrent );
                    }

                  // Verifica se o timer para ocorrer a retracao esgotou. 
                  if(MySet[x].RRetreat_Hitted==false && (TimeCurrent_inMINUTES-RangeAtTime_inMINUTES)>MySet[x].RRetreat_Max_Timer && TimeToString(TimeCurrent(),TIME_MINUTES)>TimeToString(MySet[x].EntryStartTimer,TIME_MINUTES))
                    {
                     MySet[x].Trade_Status="FINISHED"; // Ponto e entrada ja foi alcancado no passado. Evitar entrada atrasada
                     Print("OnTick| TradeID:",MySet[x].TradeID," | Horarios do filtro: RRetreat_Max_Timer=",MySet[x].RRetreat_Max_Timer," |MySet[x].EntryStartTimer=",TimeToString(MySet[x].EntryStartTimer,TIME_DATE|TIME_MINUTES)," |TimeCurrent_inMINUTES: ",TimeCurrent_inMINUTES," |RangeAtTime_inMINUTES: ",RangeAtTime_inMINUTES );
                     Print("OnTick| TradeID:",MySet[x].TradeID," | Cancelando trade porque ponto de entrada foi atingido antes da janela de horario de entrada permitido para o trade. Trade[ Faixa de range: Min "+(string)MySet[x].Range_MinPoints+"/Max "+(string)MySet[x].Range_MaxPoints+"/"+(string)MySet[x].RangeHighLow+"/"+(string)MySet[x].TradeDirection+"| Range atual: "+(string)RangeCurrent );
                    }

                 } // RangeCurrent == MySet[x].LastRange

               //Print( "RangeCurrent:"+(string)RangeCurrent );

               //Tick data - using Period defined in chart 
               //MqlRates rates[];
               //ArraySetAsSeries(rates,true);
               int copied;
               copied=CopyRates(MySet[x].Ativo_Symbol,MySet[x].Timeframe,0,3,rates);
               //CopyRates(_Symbol,_Period,0,3,rates);
               //if (copied > 0)
               //{
               //   Print("OnTick| Ativo: ",MySet[x].Ativo_Symbol," |Timeframe: ",MySet[x].Timeframe," |rates[0].time ",TimeToString(rates[0].time,TIME_DATE|TIME_MINUTES)," | rates[0].CLOSE ",rates[0].close," rates[1].time ",TimeToString(rates[1].time,TIME_DATE|TIME_MINUTES)," | rates[1].CLOSE ",rates[1].close );
               //}


               //            //======================================
               //            // Verifica qualificadores/ indicadores na abertura do dia
               //            //======================================
               //            
               //            if ( MySet[x].DailyGAP == 0 && MySet[x].DailyIBS == 0 && TimeToString(rates[0].time, TIME_DATE) == TimeToString(TimeCurrent(), TIME_DATE) )
               //            {
               //               //Print("OnTick| Novo dia comecou. Solicitado indicadores diarios.");
               //               
               //               NewDayStarted = TimeCurrent(); // Indica que um novo dia comecou e guarda este dia
               //               
               //               //GAP ---- Daily Gap: Open - Yesterday close
               //               GAP = DailyOpen - Y_Close;
               //               MySet[x].DailyGAP = GAP;
               //               Print( "OnTick| TradeID:",MySet[x].TradeID," Parametros de abertura. Ativo:",MySet[x].Ativo_Symbol,"DailyOpen: "+(string)DailyOpen+" Y_Close: "+(string)Y_Close+" Daily[1].close: "+(string)Daily[1].close+" Daily[1].low: "+(string)Daily[1].low+" Daily[1].high: "+(string)Daily[1].high );
               //               Print( "OnTick| TradeID:",MySet[x].TradeID," Ativo:",MySet[x].Ativo_Symbol," |GAP do dia "+TimeToString(TodayOpen, TIME_DATE)+" |GAP: "+(string)GAP );
               //               
               //               //IBS1
               //               IBS1 = (( Daily[1].close - Daily[1].low)/(Daily[1].high - Daily[1].low )) ;
               //               MySet[x].DailyIBS = IBS1;
               //               Print( "OnTick| TradeID:",MySet[x].TradeID," Ativo:",MySet[x].Ativo_Symbol," |IBS.1 do dia: "+TimeToString(TodayOpen, TIME_DATE)+" |IBS.1: "+StringFormat("%.2f",IBS1) );
               //               
               //               //LAST 4 DAYS - 4D
               //               
               //               // Verifica o Quaddrante do dia
               //               LMC = Monthly[1].close;
               //               DOM = StringToInteger( StringSubstr(TimeToString(TimeCurrent(),TIME_DATE),8,2) );
               //               Print( "OnTick| TradeID:",MySet[x].TradeID," Ativo:",MySet[x].Ativo_Symbol," |Dados do dia: "+TimeToString(TodayOpen, TIME_DATE)+" |LMC: "+(string)LMC+" |DOM: "+(string)DOM+" |Dia_MidMonth: "+(string)Dia_MidMonth+" |DailyOpen: "+(string)DailyOpen );
               //               //Print( "OnTick| TradeID:",MySet[x].TradeID," Ativo:",MySet[x].Ativo_Symbol," |Dados do dia: "+TimeToString(TodayOpen, TIME_DATE)+" |LMC: "+(string)LMC+" |DOM: "+(string)DOM+" |Dia_MidMonth: "+(string)Dia_MidMonth );
               //               
               //               if( DailyOpen >= LMC ) // Acima do fechamento do mes anterior
               //               {
               //                  if( DOM <= Dia_MidMonth ) // Inicio do mes
               //                  {
               //                     MySet[x].DailyMonthQuadrant = "1+";
               //                  }
               //                  else if( DOM > Dia_MidMonth ) // Final do mes
               //                  {
               //                     MySet[x].DailyMonthQuadrant = "2+";
               //                  }
               //                  else
               //                  {
               //                     Print("OnTick| Verificar MonthQuadrant. +DOM");
               //                  }
               //               }
               //               else if( DailyOpen < LMC ) // Abaixo do fechamento do mes anterior
               //               {
               //                  if( DOM <= Dia_MidMonth ) // Inicio do mes
               //                  {
               //                     MySet[x].DailyMonthQuadrant = "1-";
               //                  }
               //                  else if( DOM > Dia_MidMonth ) // Final do mes
               //                  {
               //                     MySet[x].DailyMonthQuadrant = "2-";
               //                  }
               //                  else
               //                  {
               //                     Print("OnTick| Verificar MonthQuadrant. DOM");
               //                  }
               //               }
               //               else
               //               {
               //                  Print("OnTick| Verificar MonthQuadrant. LMC");
               //               }
               //               Print( "OnTick| TradeID:",MySet[x].TradeID," Ativo:",MySet[x].Ativo_Symbol," |Dia: "+TimeToString(TodayOpen, TIME_DATE)+" |MonthQuadrant: ",MySet[x].DailyMonthQuadrant );
               //               
               //            } // Verifica qualificadores/ indicadores na abertura do dia // REMOVER 




               //+------------------------------------------------------------------+
               //| Filtros do momento INTRADAY filters                              |
               //+------------------------------------------------------------------+

               //CTO 
               if((rates[0].close-DailyOpen)>=0)
                 {
                  CTO="+";
                 }
               else
                 {
                  CTO="-";
                 }

               //CTC.1
               //Y_Close;
               if((rates[0].close-Y_Close)>=0)
                 {
                  CTC1="+";
                 }
               else
                 {
                  CTC1="-";
                 }

               //DayPosition (ABOVE, BELOW, INSIDE, OUTSIDE)
               //Y_High;
               //y_Low;
               if(Daily[0].high>Y_High)
                 {
                  if(Daily[0].low>=Y_Low)
                    {
                     Current_DayPosition="ABOVE";
                    }
                  else
                    {
                     Current_DayPosition="OUTSIDE";
                    }
                 }
               else
                 {
                  if(Daily[0].low>=Y_Low)
                    {
                     Current_DayPosition="INSIDE";
                    }
                  else
                    {
                     Current_DayPosition="BELOW";
                    }
                 }

               //BGSV
               if((Daily[0].high-Daily[0].open)>(Daily[0].open-Daily[0].low))
                 {
                  BGSV="+";
                 }
               else
                 {
                  BGSV="-";
                 }

               //MID1
               if(rates[0].close>Y_High)
                 {
                  MID1="H+";
                 }
               else if(rates[0].close<=Y_High && rates[0].close>=Y_MidPoint)
                 {
                  MID1="M+";
                 }
               else if(rates[0].close<Y_MidPoint && rates[0].close>=Y_Low)
                 {
                  MID1="M-";
                 }
               else if(rates[0].close<Y_Low)
                 {
                  MID1="L-";
                 }
               else
                 {
                  MID1="";
                  Print("OnTick| Verificar parametro MID1. Nao foi possivel classificar. Y_High",Y_High," |Y_MidPoint: ",Y_MidPoint," |Y_Low: ",Y_Low);
                 }

               // Check for new bar
               //AJUSTAR_MENSAGEM - MOVER PARA FORA DO LOOPING?
               bool newBar=true;
               int barShift=1;
               //newBar = NewBar.CheckNewBar(MySet[x].Ativo_Symbol,MySet[x].Timeframe);

               if(TimeToString(rates[0].time,TIME_MINUTES)!=TimeToString(MySet[x].LastBar_Time,TIME_MINUTES))
                 {
                  newBar=true;
                  MySet[x].Daily_BarCounter=MySet[x].Daily_BarCounter+1;
                  barShift=1;
                  MySet[x].LastBar_Time=TimeToString(rates[0].time,TIME_MINUTES);

                  LastBarRange=rates[1].high-rates[1].low;
                  if(LastBarRange==0) LastBarRange=1;
                  LastBarBody=rates[1].close-rates[1].open;
                  LastBarBodyAbs=MathAbs(rates[1].close-rates[1].open);
                  DailyFactor=LastBarBodyAbs/LastBarRange;

                  if(ExibirLogsDetalhados)
                     Print("OnTick| TradeID: ",MySet[x].TradeID," |CurrentBarTIME: ",TimeToString(rates[0].time,TIME_MINUTES)," |TimeFrame: ",EnumToString(MySet[x].Timeframe)," |barShift: ",barShift," |newBar: ",newBar," |LastBarTIME: ",TimeToString(rates[1].time,TIME_MINUTES)," |LastBarRANGE: ",LastBarRange," |LastBarCTO: ",LastBarBody," |LastBarOHLC: ",rates[1].open,",",rates[1].high,",",rates[1].low,",",rates[1].close);
                  //newBar = NewBar.CheckNewBar(MySet[x].Ativo_Symbol,MySet[x].Timeframe);
                 }
               else
                 {
                  if(MySet[x].TradeOnNewBar==false)
                    {
                     newBar=true;
                    }
                  else
                    {
                     newBar=false;
                    }
                  barShift=0;
                  MySet[x].LastBar_Time=TimeToString(rates[0].time,TIME_MINUTES);
                 }

               //}

               //               //Check Daily Filters
               //
               //               //Check IBS.1
               //               if ( MySet[x].DailyIBS < MySet[x].IBS_Bottom || MySet[x].DailyIBS > MySet[x].IBS_Top )
               //               {
               //                     MySet[x].Trade_Status = "FINISHED"; // Condicao do dia nao satisfeita para esta configuracao
               //                     Print("OnTick| TradeID: ",MySet[x].TradeID,"/"+(string)MySet[x].TradeType+"/"+(string)MySet[x].Trade_Status+"/"+(string)MySet[x].TradeDirection+" Finalizado. Filtro diario IBS.1 nao satisfeito.  IBS.1: "+(string)IBS1+" |Maximo(IBS.1_Top): "+(string)MySet[x].IBS_Top+" |Minimo(IBS.1_Bottom): "+(string)MySet[x].IBS_Bottom );
               //                     continue;
               //               }
               //               
               //               //Check GAP
               //               //SYMBOL_POINT AJUSTE 
               //               if ( MySet[x].DailyGAP < MySet[x].GAP_Bottom || MySet[x].DailyGAP > MySet[x].GAP_Top )
               //               {
               //                     MySet[x].Trade_Status = "FINISHED"; // Condicao do dia nao satisfeita para esta configuracao
               //                     Print("OnTick| TradeID: ",MySet[x].TradeID,"/"+(string)MySet[x].TradeType+"/"+(string)MySet[x].Trade_Status+"/"+(string)MySet[x].TradeDirection+" Finalizado. Filtro diario GAP nao satisfeito. GAP: "+(string)GAP+" |Maximo: "+(string)MySet[x].GAP_Top+" |Minimo: "+(string)MySet[x].GAP_Bottom+". Trade_Status: "+(string)MySet[x].Trade_Status );
               //                     continue;
               //               }
               //               
               //               
               //               //Check MonthQuadrant [1+/1-/2+/2-]
               //               //if ( MySet[x].MonthQuadrant != "" )
               //               if ( StringFind(MySet[x].MonthQuadrant, MySet[x].DailyMonthQuadrant ) < 0 )
               //               {
               //                  if ( MySet[x].MonthQuadrant != MySet[x].DailyMonthQuadrant )
               //                  {
               //                        MySet[x].Trade_Status = "FINISHED"; // Condicao do dia nao satisfeita para esta configuracao
               //                        Print("OnTick| TradeID: ",MySet[x].TradeID,"/"+(string)MySet[x].TradeType+"/"+(string)MySet[x].Trade_Status+"/"+(string)MySet[x].TradeDirection+" Finalizado. Filtro diario MonthQuadrant nao satisfeito.  DailyMonthQuadrant: "+(string)MySet[x].DailyMonthQuadrant+" |MonthQuadrant: "+MySet[x].MonthQuadrant );
               //                        continue;
               //                  }
               //                  else
               //                  {
               //                     Print("OnTick| TradeID: ",MySet[x].TradeID,"/"+(string)MySet[x].TradeType+"/"+(string)MySet[x].Trade_Status+"/"+(string)MySet[x].TradeDirection+" Verificar o filtro MonthQuadrant.  DailyMonthQuadrant: "+(string)MySet[x].DailyMonthQuadrant+" |MonthQuadrant: "+MySet[x].MonthQuadrant);
               //                  }
               //               }
               //               
               //               
               //               //Check WeekDays [SUN/MON/TUE/WED/THU/FRI/SAT]
               //               if ( StringFind(MySet[x].WeekDays, DayofWeek ) < 0 ) 
               //               {
               //                     MySet[x].Trade_Status = "FINISHED"; // Condicao do dia nao satisfeita para esta configuracao
               //                     Print("OnTick| Trade number: ",x,"/"+(string)MySet[x].TradeType+"/"+(string)MySet[x].Trade_Status+"/"+(string)MySet[x].TradeDirection+" Finalizado. Dia da Semana: "+(string)DayofWeek+" |Periodo permitido: "+(string)MySet[x].WeekDays );
               //                     continue;
               //               }




               //SendMail
               if(PositionSelect(_Symbol)!=PosicaoAtual || (TimeToString(TimeCurrent(),TIME_MINUTES)=="17:55" && DayClosed==false))
                 {
                  if(TimeToString(TimeCurrent(),TIME_MINUTES)=="17:55") DayClosed=true;

                  PosicaoAtual=PositionSelect(_Symbol);
                  string subject = "EA_Daily Position "+_Symbol;
                  string message = "Situacao Atual da conta: "+(string)Conta+" no Ativo:  "+_Symbol+"\r\n";
                  message+=" "+"\r\n";
                  message+="Horario Atual: "+ TimeToString( TimeCurrent(),TIME_DATE|TIME_MINUTES)+"\r\n";
                  message+="PositionSelect: "+(string)PositionSelect(_Symbol)+"\r\n";
                  message+=" "+"\r\n";
                  message+=StringFormat("IBS.1: %.2f",IBS1)+"\r\n";
                  message+="GAP: "+(string)GAP+"\r\n";
                  message+="qFirstBar: "+(string)qFirstBar+"\r\n";
                  message+=" "+"\r\n";
                  message+="Contratos Executados no dia. "+(string)ContratosDiarios+"\r\n";
                  message+="Range neste momento: "+(string)RangeCurrent+"\r\n";
                  message+="Order_State: "+(string)Order_State+"\r\n";
                  message+=". "+"\r\n";
                  message+="Saldo da conta em Pontos: "+(string)AccountBalance_Points+"\r\n";
                  message+="Saldo da conta em R$    : "+(string)AccountBalance_Currency+"\r\n";
                  message+=" "+"\r\n";
                  message+=" "+"\r\n";
                  message+=" "+"\r\n";
                  message+=" "+"\r\n";
                  message+=" "+"\r\n";
                  message+=" "+"\r\n";
                  message+=" "+"\r\n";
                  //Table HEADER
                  message+="|Seq"+"|TradeID"+"|Ativo_Symbol"+"|Timeframe"+"|TradeType"+"|IBS_Top"+"|IBS_Bottom"+"|GAP_Top"+"|GAP_Bottom"+"|MonthQuadrant"+"|WeekDays"+"|CTO"+"|CTC1"+"|MID1_Reference"+"|DailyBGSV"+"|DayPosition"+"|HighLow"+"|HighLow_PreLimit"+"|Range"+"|RangeHighLow"+"|TradeDirection"+"|TradeOnNewBar"+"|EntryOrder_OrderType"+"|EarlyOrder_Distance"+"|TgtOrder_OrderType"+"|TakeProfit"+"|StopLoss"+"|TakeProfit_PercRange"+"|StopLoss_PercRange"+"|UseTrailingStop"+"|TrailingStop"+"|MinimumProfit"+"|Step"+"|UseMoneyManagement"+"|RiskPercent"+"|FixedVolume"+"|UseTimer"+"|StartTimer"+"|EndTimer"+"|StartHour"+"|StartMinute"+"|EndHour"+"|EndMinute"+"|UseLocalTime"+"|UseEntryTimer"+"|EntryStartTimer"+"|EntryEndTimer"+"|EntryStartHour"+"|EntryStartMinute"+"|EntryEndHour"+"|EntryEndMinute"+"|EntryRef_Open_Top"+"|EntryRef_Open_Bottom"+"|EntryPoint"+"|Timer_RefPoint"+"|Timer_Ref_fromDailyOpen"+"|Timer_EntryPoint"+"|EntryPoint_entered_flag"+"|TradeCounter"+"|DailyGAP"+"|DailyIBS"+"|DailyMonthQuadrant"+"|LastBar_Time"+"|glBuyPlaced"+"|glSellPlaced"+"|glPlaceOrder"+"|glOrderPlaced"+"|glOrderexecuted"+"|glTargetOrderPlaced"+"|glStopOrderPlaced"+"|RangeLineObj"+"|RangeHitDay"+"|NewRangeHighLow"+"|RangeLevel"+"|RangeHit"+"|LastDailyHigh"+"|LastDailyLow"+"|OrderSize"+"|PosicaoAtual"+"|EntryOrder_OrderNumber"+"|EntryOrder_Status"+"|EntryOrder_type"+"|EntryOrder_Volume"+"|EntryOrder_VolExec"+"|EntryOrder_Price"+"|EntryOrder_PriceExec"+"|EntryOrder_StopPrice"+"|TargetTicketNumber"+"|TgtOrder_OrderNumber"+"|TgtOrder_Status"+"|TgtOrder_type"+"|TgtOrder_Volume"+"|TgtOrder_VolExec"+"|TgtOrder_Price"+"|TgtOrder_PriceExec"+"|TgtOrder_ObjName"+"|StopLossTicketNumber"+"|StopOrder_OrderNumber"+"|StopOrder_Status"+"|StopOrder_type"+"|StopOrder_Volume"+"|StopOrder_VolExec"+"|StopOrder_Price"+"|StopOrder_PriceExec"+"|Trade_Status|"+"\r\n";

                  // Table BODY (detalhes dos trades)
                  for(int i=0;i<=(ArraySize(MySet)-1); i++)
                    {
                     //Table Data BODY
                     message+="|"+(string)(i+1);

                     message+="|"+MySet[i].TradeID;
                     message+="|"+MySet[i].Ativo_Symbol;
                     message+="|"+EnumToString(MySet[i].Timeframe);
                     message+="|"+MySet[i].TradeType;
                     message+="|"+(string)MySet[i].IBS_Top;
                     message+="|"+(string)MySet[i].IBS_Bottom;
                     message+="|"+(string)MySet[i].GAP_Top;
                     message+="|"+(string)MySet[i].GAP_Bottom;
                     message+="|"+MySet[i].MonthQuadrant;
                     message+="|"+MySet[i].WeekDays;
                     message+="|"+MySet[i].CTO;
                     message+="|"+MySet[i].CTC1;
                     message+="|"+MySet[i].MID1_Reference;
                     message+="|"+MySet[i].DailyBGSV;
                     message+="|"+MySet[i].DayPosition;
                     message+="|"+(string)MySet[i].HighLow;
                     message+="|"+(string)MySet[i].HighLow_PreLimit;
                     message+="|"+(string)MySet[i].Range_Min;
                     message+="|"+(string)MySet[i].Range_Max;
                     message+="|"+MySet[i].RangeHighLow;
                     message+="|"+MySet[i].TradeDirection;
                     message+="|"+(string)MySet[i].TradeOnNewBar;
                     message+="|"+EnumToString(MySet[i].EntryOrder_OrderType);
                     message+="|"+(string)MySet[i].EarlyOrder_Distance;
                     message+="|"+EnumToString(MySet[i].TgtOrder_OrderType);
                     message+="|"+(string)MySet[i].TakeProfit;
                     message+="|"+(string)MySet[i].StopLoss;
                     message+="|"+(string)MySet[i].TakeProfit_PercRange;
                     message+="|"+(string)MySet[i].StopLoss_PercRange;
                     message+="|"+(string)MySet[i].UseTrailingStop;
                     message+="|"+(string)MySet[i].TrailingStop;
                     message+="|"+(string)MySet[i].MinimumProfit;
                     message+="|"+(string)MySet[i].Step;
                     message+="|"+(string)MySet[i].UseMoneyManagement;
                     message+="|"+(string)MySet[i].RiskPercent;
                     message+="|"+(string)MySet[i].FixedVolume;
                     message+="|"+(string)MySet[i].UseTimer;
                     message+="|"+TimeToString(MySet[i].StartTimer,TIME_MINUTES);
                     message+="|"+TimeToString(MySet[i].EndTimer,TIME_MINUTES);
                     message+="|"+(string)MySet[i].StartHour;
                     message+="|"+(string)MySet[i].StartMinute;
                     message+="|"+(string)MySet[i].EndHour;
                     message+="|"+(string)MySet[i].EndMinute;
                     message+="|"+(string)MySet[i].UseLocalTime;
                     message+="|"+(string)MySet[i].UseEntryTimer;
                     message+="|"+TimeToString(MySet[i].EntryStartTimer,TIME_MINUTES);
                     message+="|"+TimeToString(MySet[i].EntryEndTimer,TIME_MINUTES);
                     message+="|"+(string)MySet[i].EntryStartHour;
                     message+="|"+(string)MySet[i].EntryStartMinute;
                     message+="|"+(string)MySet[i].EntryEndHour;
                     message+="|"+(string)MySet[i].EntryEndMinute;
                     message+="|"+(string)MySet[i].EntryRef_Open_Top;
                     message+="|"+(string)MySet[i].EntryRef_Open_Bottom;
                     message+="|"+(string)MySet[i].EntryPoint;
                     message+="|"+(string)MySet[i].Timer_RefPoint;
                     message+="|"+(string)MySet[i].Timer_Ref_fromDailyOpen;
                     message+="|"+(string)MySet[i].Timer_EntryPoint;
                     message+="|"+(string)MySet[i].EntryPoint_entered_flag;
                     message+="|"+(string)MySet[i].TradeCounter;
                     message+="|"+(string)MySet[i].DailyGAP;
                     message+="|"+(string)MySet[i].DailyIBS;
                     message+="|"+MySet[i].DailyMonthQuadrant;
                     message+="|"+MySet[i].LastBar_Time;
                     message+="|"+(string)MySet[i].glBuyPlaced;
                     message+="|"+(string)MySet[i].glSellPlaced;
                     message+="|"+(string)MySet[i].glPlaceOrder;
                     message+="|"+(string)MySet[i].glOrderPlaced;
                     message+="|"+(string)MySet[i].glOrderexecuted;
                     message+="|"+(string)MySet[i].glTargetOrderPlaced;
                     message+="|"+(string)MySet[i].glStopOrderPlaced;
                     message+="|"+(string)MySet[i].RangeLineObj;
                     message+="|"+TimeToString(MySet[i].RangeHitDay,TIME_MINUTES);
                     message+="|"+MySet[i].NewRangeHighLow;
                     message+="|"+(string)MySet[i].RangeLevel;
                     message+="|"+(string)MySet[i].RangeHit;
                     message+="|"+(string)MySet[i].LastDailyHigh;
                     message+="|"+(string)MySet[i].LastDailyLow;
                     message+="|"+(string)MySet[i].OrderSize;
                     message+="|"+(string)MySet[i].PosicaoAtual;
                     message+="|"+(string)MySet[i].EntryOrder_OrderNumber;
                     message+="|"+MySet[i].EntryOrder_Status;
                     message+="|"+MySet[i].EntryOrder_type;
                     message+="|"+(string)MySet[i].EntryOrder_Volume;
                     message+="|"+(string)MySet[i].EntryOrder_VolExec;
                     message+="|"+(string)MySet[i].EntryOrder_Price;
                     message+="|"+(string)MySet[i].EntryOrder_PriceExec;
                     message+="|"+(string)MySet[i].EntryOrder_StopPrice;
                     message+="|"+(string)MySet[i].TargetTicketNumber;
                     message+="|"+(string)MySet[i].TgtOrder_OrderNumber;
                     message+="|"+MySet[i].TgtOrder_Status;
                     message+="|"+MySet[i].TgtOrder_type;
                     message+="|"+(string)MySet[i].TgtOrder_Volume;
                     message+="|"+(string)MySet[i].TgtOrder_VolExec;
                     message+="|"+(string)MySet[i].TgtOrder_Price;
                     message+="|"+(string)MySet[i].TgtOrder_PriceExec;
                     message+="|"+MySet[i].TgtOrder_ObjName;
                     message+="|"+(string)MySet[i].StopLossTicketNumber;
                     message+="|"+(string)MySet[i].StopOrder_OrderNumber;
                     message+="|"+MySet[i].StopOrder_Status;
                     message+="|"+MySet[i].StopOrder_type;
                     message+="|"+(string)MySet[i].StopOrder_Volume;
                     message+="|"+(string)MySet[i].StopOrder_VolExec;
                     message+="|"+(string)MySet[i].StopOrder_Price;
                     message+="|"+(string)MySet[i].StopOrder_PriceExec;
                     message+="|"+MySet[i].Trade_Status;


                     //                        message+="|"+MySet[i].TradeType;
                     //                        message+="|"+(string)MySet[i].Range;
                     //                        message+="|"+(string)MySet[i].RangeHighLow;
                     //                        message+="|"+(string)MySet[i].HighLow;
                     //                        message+="|"+(string)MySet[i].HighLow_PreLimit;
                     //                        
                     //                        message+="|"+(string)MySet[i].TradeDirection;
                     //                        message+="|"+(string)MySet[i].FixedVolume;
                     //                        message+="|"+(string)MySet[i].TakeProfit;
                     //                        message+="|"+(string)MySet[i].StopLoss;
                     //                        message+="|"+(string)MySet[i].StartHour+":"+(string)MySet[i].StartMinute;
                     //                        message+="|"+(string)MySet[i].EndHour+":"+(string)MySet[i].EndMinute;
                     //                        //Variaveis de flag de trade
                     //                        message+="|"+MySet[i].Trade_Status;
                     //                        message+="|"+MySet[i].NewRangeHighLow;
                     //                        message+="|"+(string)MySet[i].EntryOrder_OrderNumber;
                     //                        //message+="|"+MySet[i].glBuyPlaced;
                     //                        //Variaveis de controle de ordens
                     //                        //message+="|"+(string)MySet[i].EntryOrder_OrderNumber;
                     //                        //Variaveis da ordem de entrada
                     //                        message+="|"+(string)MySet[i].EntryOrder_OrderNumber;
                     //                        message+="|"+MySet[i].EntryOrder_Status;
                     //                        message+="|"+MySet[i].EntryOrder_type;
                     //                        message+="|"+(string)MySet[i].EntryOrder_Volume;
                     //                        message+="|"+(string)MySet[i].EntryOrder_VolExec;
                     //                        message+="|"+(string)MySet[i].EntryOrder_Price;
                     //                        message+="|"+(string)MySet[i].EntryOrder_PriceExec;
                     //                        message+="|"+(string)MySet[i].EntryOrder_StopPrice;
                     //                        //Variaveis de ordem Target
                     //                        message+="|"+(string)MySet[i].TargetTicketNumber;
                     //                        //message+="|"+(string)MySet[i].TgtOrder_OrderNumber;
                     //                        message+="|"+MySet[i].TgtOrder_Status;
                     //                        message+="|"+MySet[i].TgtOrder_type;
                     //                        message+="|"+(string)MySet[i].TgtOrder_Volume;
                     //                        message+="|"+(string)MySet[i].TgtOrder_VolExec;
                     //                        message+="|"+(string)MySet[i].TgtOrder_Price;
                     //                        //Stop Order variables
                     //                        message+="|"+(string)MySet[i].StopLossTicketNumber;
                     //                        //message+="|"+(string)MySet[i].StopOrder_OrderNumber;
                     //                        message+="|"+MySet[i].StopOrder_Status;
                     //                        message+="|"+MySet[i].StopOrder_type;
                     //                        message+="|"+(string)MySet[i].StopOrder_Volume;
                     //                        message+="|"+(string)MySet[i].StopOrder_VolExec;
                     //                        message+="|"+(string)MySet[i].StopOrder_Price;
                     message+=" \r\n ";
                    }

                  SendMail(subject,message);
                  Print("Mensagem enviada por e-mail: "+message);
                 }

               //if(MySet[x].TradeOnNewBar == true)
               //{
               //	//newBar = NewBar.CheckNewBar(_Symbol,_Period);
               //	barShift = 1;
               //	//Print("OnTick| TradeOnNewBar ",x," |Trade_Type: ",MySet[x].TradeType," |Trade_Status: ",MySet[x].Trade_Status," |TimeFrame: ",EnumToString(MySet[x].Timeframe)," |Current_Time: ",TimeToString(rates[0].time, TIME_MINUTES)," |LastBar_Time: ",TimeToString(MySet[x].LastBar_Time, TIME_MINUTES)," |barShift: ",barShift," |newBar: ",newBar );
               //}


               // ENTRY Timer
               //bool timerOn = true; (linha de comando original do template
               bool EntryTimerOn=false;
               if(MySet[x].UseEntryTimer==true)
                 {
                  //Timer para a entrada. Timer para limitar o horario de entrada.

                  if(TimeToString(TimeCurrent(),TIME_MINUTES)>=TimeToString(MySet[x].EntryStartTimer,TIME_MINUTES) && TimeToString(TimeCurrent(),TIME_MINUTES)<TimeToString(MySet[x].EntryEndTimer,TIME_MINUTES))
                    {
                     EntryTimerOn=true;
                    }

                  if(TimeToString(TimeCurrent(),TIME_MINUTES)>=TimeToString(MySet[x].EntryEndTimer,TIME_MINUTES))
                  {
                     Print(MySet[x].Trade_Status);
                  }


                  //EntryTimerEnds - Cancel Entry Orders
                  if(TimeToString(TimeCurrent(),TIME_MINUTES)>=TimeToString(MySet[x].EntryEndTimer,TIME_MINUTES) && (MySet[x].Trade_Status=="PLACED" || MySet[x].Trade_Status=="WAITING"))
                    {
                     //Print("OnTick| Timer encerrado. Trade: "+MySet[x].TradeType+"/"+(string)MySet[x].Range+"/"+MySet[x].RangeHighLow+"/"+MySet[x].TradeDirection+" | horario de encerramento: "+ TimeToString(MySet[x].EndTimer,TIME_MINUTES)+" | Hora: "+(string)MySet[x].EndHour+" |Minuto: "+(string)MySet[x].EndMinute );

                     //Adicionar script para cancelar as ordens de entrada em aberto do trade, realizar o cancelamento antes de ter posicoes abertas.
                     // Ordem STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                     // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)

                     if(MySet[x].Trade_Status=="WAITING")
                       {
                        MySet[x].Trade_Status="FINISHED"; // Janela de entrada no trade encerrada
                        Print("OnTick| TradeID:",MySet[x].TradeID," |Trade_Type:",MySet[x].TradeType," |Trade_Status:",MySet[x].Trade_Status," | EntryTimer Encerrado.");

                       }
                     else if(MySet[x].Trade_Status=="PLACED")
                       {
                        if(MySet[x].EntryOrder_Status=="PLACED" || MySet[x].EntryOrder_Status=="PARTIAL")
                          {
                           bool EntryOrder_Canceled;
                           EntryOrder_Canceled=Trade.OrderDelete(MySet[x].EntryOrder_OrderNumber);
                           Print("OnTick| TradeID:"+MySet[x].TradeID+" |EntryTimer encerrado. Cancelando ordem#:"+(string)MySet[x].EntryOrder_OrderNumber+" |Status: "+(string)EntryOrder_Canceled);
                           if(EntryOrder_Canceled)
                             {
                              MySet[x].Trade_Status="FINISHED"; // Janela de entrada no trade encerrada
                              Print("OnTick| TradeID:",MySet[x].TradeID," |Trade_Type:",MySet[x].TradeType," |Trade_Status:",MySet[x].Trade_Status," | EntryTimer Encerrado.");

                             }
                          }
                       }

                     if(MySet[x].Trade_Status=="WAITING")
                       {
                        MySet[x].Trade_Status="FINISHED"; // Janela de entrada no trade encerrada
                        Print("OnTick| TradeID:",MySet[x].TradeID," /Status anterior:WAITING. Janela de entrada no trade encerrada.");
                       }

                    } //TimerEnds - Cancel Orders
                 } // Timer

               // Timer  // Timer geral do dia, contendo horario de inicio e fim das posicoes
               //bool timerOn = true; (linha de comando original do template
               bool timerOn=false;
               if(MySet[x].UseTimer==true)
                 {
                  //Timer para o dia. TImer para evitar que posicoes fiquem abertas de um dia para o outro.
                  //DailyTimerOn = Timer.DailyTimer(StartHour,StartMinute,EndHour,EndMinute,UseLocalTime);
                  //qCreateDateTime(EndHour,EndMinute);

                  if(TimeToString(TimeCurrent(),TIME_MINUTES)>=TimeToString(MySet[x].StartTimer,TIME_MINUTES) && TimeToString(TimeCurrent(),TIME_MINUTES)<TimeToString(MySet[x].EndTimer,TIME_MINUTES))
                    {
                     timerOn=true;
                    }

                  //TimerEnds - Cancel Orders
                  //if ( TimeCurrent() >= Timer.GetEndTime() && OrdersTotal() > 0 )
                  if(TimeToString(TimeCurrent(),TIME_MINUTES)>=TimeToString(MySet[x].EndTimer,TIME_MINUTES) && MySet[x].Trade_Status!="FINISHED")
                    {
                     //Print("OnTick| Timer encerrado. Trade: "+MySet[x].TradeType+"/"+(string)MySet[x].Range+"/"+MySet[x].RangeHighLow+"/"+MySet[x].TradeDirection+" | horario de encerramento: "+ TimeToString(MySet[x].EndTimer,TIME_MINUTES)+" | Hora: "+(string)MySet[x].EndHour+" |Minuto: "+(string)MySet[x].EndMinute );

                     //Adicionar script para cancelar as ordens em aberto do trade, e realizar o cancelamento antes de encerrar as posições.
                     // Ordem STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                     // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                     if(MySet[x].Trade_Status=="WAITING")
                       {
                        MySet[x].Trade_Status="FINISHED"; // Janela de trade no dia encerrada
                        Print("OnTick| TradeID:",MySet[x].TradeID," |Timer encerrado.");
                       }
                     else if(MySet[x].Trade_Status=="PLACED")
                       {
                        if(MySet[x].EntryOrder_Status=="PLACED" || MySet[x].EntryOrder_Status=="PARTIAL")
                          {
                           bool EntryOrder_Canceled;
                           EntryOrder_Canceled=Trade.OrderDelete(MySet[x].EntryOrder_OrderNumber);
                           Print("OnTick| TradeID:"+MySet[x].TradeID+" |Timer encerrado. Cancelando ordem#:"+(string)MySet[x].EntryOrder_OrderNumber+" |Status: "+(string)EntryOrder_Canceled);
                           if(EntryOrder_Canceled)
                             {
                              MySet[x].Trade_Status="FINISHED"; // Janela de trade no dia encerrada
                              Print("OnTick| TradeID:",MySet[x].TradeID," |Timer encerrado. Ordens Canceladas!");
                             }
                          }
                       }

                     else if(MySet[x].Trade_Status=="STARTED")
                       {
                        bool EntryOrder_Canceled;
                        bool TgtOrder_Canceled;
                        bool StopOrder_Canceled;

                        if(MySet[x].EntryOrder_Status=="REQUESTED" || MySet[x].EntryOrder_Status=="REMOVED" || MySet[x].EntryOrder_Status=="FINISHED" || MySet[x].EntryOrder_Status=="CANCELED")
                          {
                           EntryOrder_Canceled=true;
                          }
                        else if(MySet[x].EntryOrder_Status=="PLACED")
                          {
                           EntryOrder_Canceled=Trade.OrderDelete(MySet[x].EntryOrder_OrderNumber);
                           Print("OnTick| TradeID:"+MySet[x].TradeID+" |Timer encerrado. Cancelando ordem#:"+(string)MySet[x].EntryOrder_OrderNumber+" |Status: "+(string)EntryOrder_Canceled);
                           if(EntryOrder_Canceled)
                             {
                              MySet[x].EntryOrder_Status="CANCELED";
                             }
                          }
                        else if((MySet[x].EntryOrder_Status=="FILLED" || MySet[x].EntryOrder_Status=="PARTIAL") && MySet[x].TgtOrder_OrderNumber!=0)
                          {
                           if(MySet[x].EntryOrder_type=="DEAL_TYPE_BUY")
                             {
                              EntryOrder_Canceled=Trade.OrderModify(MySet[x].TgtOrder_OrderNumber,(rates[0].close-spSlippage),0,0,Quant_type_time,0,0);
                              //EntryOrder_Canceled = Trade.OrderModify(MySet[x].TgtOrder_OrderNumber,MySet[x].StopOrder_Price,0,0,Quant_type_time,0,0);
                              //EntryOrder_Canceled = Trade.OrderDelete(MySet[x].EntryOrder_OrderNumber);
                              Print("OnTick| TradeID:"+MySet[x].TradeID+" |Timer encerrado. Ajuste na ordem#:"+(string)MySet[x].TgtOrder_OrderNumber+" |Status: "+(string)EntryOrder_Canceled);
                              if(EntryOrder_Canceled)
                                {
                                 MySet[x].EntryOrder_Status="CANCELED";
                                }
                             }
                           else
                             {
                              EntryOrder_Canceled=Trade.OrderModify(MySet[x].TgtOrder_OrderNumber,(rates[0].close+spSlippage),0,0,Quant_type_time,0,0);
                              Print("OnTick| TradeID:"+MySet[x].TradeID+" |Timer encerrado. Ajuste na ordem#:"+(string)MySet[x].TgtOrder_OrderNumber+" |Status: "+(string)EntryOrder_Canceled);
                              if(EntryOrder_Canceled)
                                {
                                 MySet[x].EntryOrder_Status="CANCELED";
                                }
                             }

                          }
                        else if((MySet[x].EntryOrder_Status=="FILLED" || MySet[x].EntryOrder_Status=="PARTIAL") && MySet[x].TgtOrder_OrderNumber==0)
                          {
                           if(MySet[x].EntryOrder_type=="DEAL_TYPE_BUY")
                             {
                              // Inverte posicao?
                              if(MySet[x].TradeType=="OVER_UNDER" && MySet[x].InvertPosition==true) MySet[x].OrderSize=MySet[x].OrderSize/2;
                              EntryOrder_Canceled=Trade.Sell(MySet[x].OrderSize,MySet[x].Ativo_Symbol,0,0,0,"EndTimer@*NS>" +(string)MySet[x].Strategy);
                              Print("OnTick| TradeID:"+MySet[x].TradeID+" |Timer encerrado. Contrapartida da ordem#:"+(string)MySet[x].EntryOrder_OrderNumber+" |Status: "+(string)EntryOrder_Canceled);
                              if(EntryOrder_Canceled)
                                {
                                 MySet[x].EntryOrder_Status="CANCELED";
                                }
                             }
                           else
                             {
                              // Inverte posicao?
                              if(MySet[x].TradeType=="OVER_UNDER" && MySet[x].InvertPosition==true) MySet[x].OrderSize=MySet[x].OrderSize/2;
                              EntryOrder_Canceled=Trade.Buy(MySet[x].OrderSize,MySet[x].Ativo_Symbol,0,0,0,"EndTimer@*NS>" +(string)MySet[x].Strategy);
                              Print("OnTick| TradeID:"+MySet[x].TradeID+" |Timer encerrado. Contrapartida da ordem#:"+(string)MySet[x].EntryOrder_OrderNumber+" |Status: "+(string)EntryOrder_Canceled);
                              if(EntryOrder_Canceled)
                                {
                                 MySet[x].EntryOrder_Status="CANCELED";
                                }
                             }

                          }

                        //if (MySet[x].TgtOrder_Status =="REQUESTED" || MySet[x].TgtOrder_Status =="REMOVED" || MySet[x].TgtOrder_Status =="FILLED" || MySet[x].TgtOrder_Status =="FINISHED" || MySet[x].TgtOrder_Status =="CANCELED" )
                        //{
                        //   TgtOrder_Canceled = true;
                        //}
                        //else if (MySet[x].TgtOrder_Status   == "PLACED" || MySet[x].TgtOrder_Status   == "PARTIAL" )
                        //{
                        //   TgtOrder_Canceled = Trade.OrderDelete(MySet[x].TgtOrder_OrderNumber);
                        //   Print("OnTick| Timer encerrado. Cancelando ordem#:"+(string)MySet[x].TgtOrder_OrderNumber+" |Status: "+TgtOrder_Canceled);
                        //   if ( TgtOrder_Canceled )
                        //   {
                        //      MySet[x].TgtOrder_Status = "CANCELED";
                        //   }
                        //}

                        if(MySet[x].StopOrder_Status=="REQUESTED" || MySet[x].StopOrder_Status=="REMOVED" || MySet[x].StopOrder_Status=="FILLED" || MySet[x].StopOrder_Status=="FINISHED" || MySet[x].StopOrder_Status=="CANCELED")
                          {
                           StopOrder_Canceled=true;
                          }
                        else if(MySet[x].StopOrder_Status=="PLACED" || MySet[x].StopOrder_Status=="PARTIAL")
                          {
                           StopOrder_Canceled=Trade.OrderDelete(MySet[x].StopOrder_OrderNumber);
                           Print("OnTick| TradeID:"+MySet[x].TradeID+" |Timer encerrado. Cancelando ordem#:"+(string)MySet[x].StopOrder_OrderNumber+" |Status: "+(string)StopOrder_Canceled);
                           if(StopOrder_Canceled)
                             {
                              MySet[x].StopOrder_Status="CANCELED";
                             }
                          }

                        if(EntryOrder_Canceled && TgtOrder_Canceled && StopOrder_Canceled)
                          {
                           MySet[x].Trade_Status="FINISHED"; // Janela de trade no dia encerrada
                           Print("OnTick| TradeID:",MySet[x].TradeID," |Trade_Type:",MySet[x].TradeType," |Trade_Status:",MySet[x].Trade_Status," |Timer encerrado. Ordens canceladas");
                          }

                       }
                     if(MySet[x].Trade_Status=="WAITING")
                       {
                        MySet[x].Trade_Status="FINISHED"; // Janela de trade no dia encerrada
                        Print("OnTick| TradeID:",MySet[x].TradeID," |Trade_Type:",MySet[x].TradeType," |Trade_Status:",MySet[x].Trade_Status," |Janela de trade no dia encerrada.");
                       }

                    } //TimerEnds - Cancel Orders

                  //Se após o horario de encerramento do dia, estiver com posição em aberto, cancela as ordens e encerra as posições.
                  //TimerEnds - Close Open Position
                  //if ( TimeCurrent() >= Timer.GetEndTime() && PositionSelect(_Symbol) > 0 )
                  //      		if ( TimeToString(TimeCurrent(),TIME_MINUTES) >= TimeToString(DailyEndTimer,TIME_MINUTES) && PositionSelect(_Symbol) > 0 )
                  //      		{
                  //      		   Trade.PositionClose(_Symbol);
                  //      		   Print("OnTick| Timer encerrado para o dia! Todas as posições abertas, encerradas!");
                  //      		   
                  //               
                  //      		   
                  //      		} //TimerEnds - Close Open Position



                  //Se após o horario de encerramento do dia, estiver com posição em aberto, cancela as ordens e encerra as posições.
                  //TimerEnds - Close Open Position
                  //      		if ( TimeCurrent() >= MySet[x].EndTimer && MySet[0].Trade_Status == "STARTED" )
                  //      		{
                  //      		   if( MySet[x].RangeHighLow == "DEAL_TYPE_BUY" )
                  //      		   
                  //      		   
                  //      		   Print("OnTick| Timer encerrado para o trade X! Posicao encerrada, encerradas!");
                  //      		   
                  //               
                  //               // Dados da conta
                  //               Print( "AccountInfo/ ACCOUNT_BALANCE: "+(string)AccountInfoDouble(ACCOUNT_BALANCE) );
                  //               Print( "AccountInfo/ ACCOUNT_CREDIT: "+(string)AccountInfoDouble(ACCOUNT_CREDIT) );
                  //               Print( "AccountInfo/ ACCOUNT_PROFIT: "+(string)AccountInfoDouble(ACCOUNT_PROFIT) );
                  //               Print( "AccountInfo/ ACCOUNT_EQUITY: "+(string)AccountInfoDouble(ACCOUNT_EQUITY) );
                  //               Print( "AccountInfo/ ACCOUNT_MARGIN: "+(string)AccountInfoDouble(ACCOUNT_MARGIN) );
                  //               Print( "AccountInfo/ ACCOUNT_MARGIN_FREE: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_FREE) );
                  //               Print( "AccountInfo/ ACCOUNT_MARGIN_LEVEL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_LEVEL) );
                  //               Print( "AccountInfo/ ACCOUNT_MARGIN_SO_CALL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL) );
                  //               Print( "AccountInfo/ ACCOUNT_MARGIN_SO_SO: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_SO_SO) );
                  //               Print( "AccountInfo/ ACCOUNT_MARGIN_INITIAL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_INITIAL) );
                  //               Print( "AccountInfo/ ACCOUNT_MARGIN_MAINTENANCE: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE) );
                  //               Print( "AccountInfo/ ACCOUNT_ASSETS: "+(string)AccountInfoDouble(ACCOUNT_ASSETS) );
                  //               Print( "AccountInfo/ ACCOUNT_LIABILITIES: "+(string)AccountInfoDouble(ACCOUNT_LIABILITIES) );
                  //               Print( "AccountInfo/ ACCOUNT_COMMISSION_BLOCKED: "+(string)AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED) );
                  //      		   
                  //      		} //TimerEnds - Close Open Position

                  //          ///////////////////////////////
                  //          //  TIMER PARA O DIA INTEIRO
                  //          ///////////////////////////////      		
                  //      		//Print("Timer");
                  //      		
                  //      		//Blocker Time
                  //      		//Timer.BlockTimer()
                  //      		
                  //      		
                  //      		//TimerEnds - Cancel Orders
                  //      		//if ( TimeCurrent() >= Timer.GetEndTime() && OrdersTotal() > 0 )
                  //      		if ( TimeCurrent() >= MySet[x].EndTimer && OrdersTotal() > 0 )
                  //            {
                  //                  //Adicionar script para cancelar todas as ordens em aberto, e relaizar o cancelamento antes de dencerrar as posições.
                  //                  for(int i = 0; i < OrdersTotal(); i++)
                  //                  {
                  //                     ulong ticket = OrderGetTicket(i);
                  //                     Trade.OrderDelete(ticket);
                  //                     Print("OnTick| Timer encerrado. Cancelando ordem#:"+(string)ticket);
                  //                  }
                  //                  
                  //            } //TimerEnds - Cancel Orders
                  //            
                  //      		//Se após o horario de encerramento do dia, estiver com posição em aberto, cancela as ordens e encerra as posições.
                  //      		//TimerEnds - Close Open Position
                  //      		//if ( TimeCurrent() >= Timer.GetEndTime() && PositionSelect(_Symbol) > 0 )
                  //      		if ( TimeCurrent() >= MySet[x].EndTimer && PositionSelect(_Symbol) > 0 )
                  //      		{
                  //      		   Trade.PositionClose(_Symbol);
                  //      		   Print("OnTick| Timer encerrado para o dia! Todas as posições abertas, encerradas!");
                  //      		   
                  //               
                  //      		   
                  //      		} //TimerEnds - Close Open Position

                 } // Timer

               //Print("OnTick| x: ",x," |TradeType: ",MySet[x].TradeType," |Trade_Status:",MySet[x].Trade_Status," |EntryOrder_Status:",MySet[x].EntryOrder_Status," |TgtOrder_Status:",MySet[x].TgtOrder_Status," |StopOrder_Status:",MySet[x].StopOrder_Status );
               //Print("OnTick| newBar: ",newBar," |timerOn: ",timerOn," |EntryTimerOn: ",EntryTimerOn," |MySet.EntryTimer: ",MySet[x].UseEntryTimer );
               // Order placement
               if((MySet[x].TradeOnNewBar==false || newBar==true) && timerOn==true && (EntryTimerOn==true || MySet[x].UseEntryTimer==false))
                 {
                  MySet[x].RangeHit=false;

                  //            //Print( "RangeCurrent:"+(string)RangeCurrent );
                  //            //Print( "hIGHlOW: high "+Daily[0].high  +" -LastHigh "+ MySet[x].LastDailyHigh  +" - low "+ Daily[0].low +" - LastLow "+ MySet[x].LastDailyLow );
                  //            //Print( "Daily extremes: high "+Daily[0].high  +" -LastHigh "+ MySet[x].LastDailyHigh  +" - low "+ Daily[0].low +" - LastLow "+ MySet[x].LastDailyLow );      
                  //            //Print( " Outros dados: Range "+MySet[x].Range+" EarlyOrder_Distance "+MySet[x].EarlyOrder_Distance+"  Orderexecuted? "+MySet[x].glOrderexecuted );
                  //Print("OnTick| x:",x ) ;
                  //Print("OnTick| x: ",x," |TradeType: ",MySet[x].TradeType," |Trade_Status:",MySet[x].Trade_Status," |EntryOrder_Status:",MySet[x].EntryOrder_Status," |TgtOrder_Status:",MySet[x].TgtOrder_Status," |StopOrder_Status:",MySet[x].StopOrder_Status );

                  //NOVOS FILTROS DIARIOS
                  //TODO:ERLON 

                  //=============================================================================
                  // TradeType: RANGE   ==== Check Entry signal and previous order request
                  //=============================================================================
                  if(MySet[x].TradeType=="RANGE" && (RangeCurrent>=(MySet[x].Range_MinPoints-MySet[x].EarlyOrder_Distance)) && !MySet[x].glOrderexecuted && MySet[x].Trade_Status!="FINISHED" && MySet[x].EntryOrder_Status!="REJECTED")
                    {
                     // Verifica se range atual esta acima da range de trade. Neste caso, simplesmente descarta o trade, 
                     // senao, caso o EA inicie no meio do dia, teremos varios trades startados erroneamente.
                     if(RangeCurrent>MySet[x].Range_MaxPoints && MySet[x].Trade_Status=="WAITING") // Verifica se range atual esta acima da range de trade. Neste caso, simplesmente descarta o trade, senao caso o EA inicie no meio do dia, teriamos varios trades startados erroneamente
                       {
                        MySet[x].Trade_Status="FINISHED"; // Ponto e entrada ja foi alcancado no passado. Evitar entrada atrasada
                        if(ExibirLogsDetalhados)
                           Print("OnTick| Cancelando trades com ponto de entrada Superior a range atual! : ZScore atual "+(string)MySet[x].Range_ZScore+"/"+(string)MySet[x].RangeHighLow+"/"+(string)MySet[x].TradeDirection+"| Range atual: "+(string)RangeCurrent);
                      
                       }
                     else if(RangeCurrent>MySet[x].Range_MaxPoints+Slippage && (MySet[x].Trade_Status=="REQUESTED" || MySet[x].Trade_Status=="PLACED")) // Verifica se range atual esta acima da range de trade. Neste caso, simplesmente descarta o trade, senao caso o EA inicie no meio do dia, teriamos varios trades startados erroneamente
                       {
                        bool OrderCanceled=Trade.OrderDelete(MySet[x].EntryOrder_OrderNumber);
                        if(OrderCanceled)
                          {
                           Print("OnTick| Ordem Cancelada, Condicoes de trade perdidas. Ticket: "+(string)MySet[x].EntryOrder_OrderNumber+" Status: "+(string)OrderCanceled);
                           CancelPreviousOrder=false;
                           MySet[x].glBuyPlaced=false;
                           MySet[x].glSellPlaced=false;
                           MySet[x].glOrderPlaced=false;
                           MySet[x].EntryOrder_Status="REMOVED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                          }
                        else
                          {
                           Print("OnTick| Problema com o cancelamento da ordem!. Order Number: "+(string)MySet[x].EntryOrder_OrderNumber);
                          }
                        MySet[x].Trade_Status="FINISHED"; // Ponto e entrada ja foi alcancado no passado. Evitar entrada atrasada
                        if(ExibirLogsDetalhados)
                           Print("OnTick| Cancelando trades com ponto de entrada inferior a range atual! Trade: "+(string)MySet[x].Range_MinPoints+"/"+(string)MySet[x].RangeHighLow+"/"+(string)MySet[x].TradeDirection+"| Range atual: "+(string)RangeCurrent);

                       }
                     else
                       { // else related to [if ( RangeCurrent > MySet[x].Range && MySet[x].Trade_Status == "WAITING" ) ]
                        //PlaySound("alert.wav"); // Play Sound as signal that range was stablished on level requested.

                        //Print( "Daily extremes: high "+ (string)Daily[0].high  +" -LastHigh "+ (string)MySet[x].LastDailyHigh  +" - low "+ (string)Daily[0].low +" - LastLow "+ (string)MySet[x].LastDailyLow );

                        //Identifica se a range esta sendo formada por uma nova máxima(high) ou por uma nova mínima(low)
                        if(Daily[0].high>MySet[x].LastDailyHigh)
                          {

                           //Moment filters
                           //Filtros analisados no momento de entrada do trade

                           // CTO 
                           if(MySet[x].CTO=="" || (MySet[x].CTO=="+" && (Daily[0].low+MySet[x].Range_MinPoints)-DailyOpen>=0) || (MySet[x].CTO=="-" && (Daily[0].low+MySet[x].Range_MinPoints)-DailyOpen<0))
                             {

                              // CTC.1
                              if(MySet[x].CTC1=="" || (MySet[x].CTC1=="+" && (Daily[0].low+MySet[x].Range_MinPoints)-Y_Close>=0) || (MySet[x].CTC1=="-" && (Daily[0].low+MySet[x].Range_MinPoints)-Y_Close<0))
                                {

                                 // MID.1 [H+/M+/M-/L-]
                                 //if ( StringFind(MySet[x].MID1_Reference,MID1) > -1 )
                                 if((StringFind(MySet[x].MID1_Reference,fMID1((Daily[0].low+MySet[x].Range_MinPoints),Y_High,Y_Low)))>-1)
                                   {

                                    // DayPosition [ABOVE/BELOW/INSIDE/OUTSIDE]
                                    if(StringFind(MySet[x].DayPosition,Current_DayPosition)>-1)
                                      {

                                       // DailyBGSV
                                       if(MySet[x].DailyBGSV=="" || (MySet[x].DailyBGSV=="+" && (Daily[0].high-DailyOpen)>=(DailyOpen-Daily[0].low)) || (MySet[x].DailyBGSV=="-" && (Daily[0].high-DailyOpen)<(DailyOpen-Daily[0].low)))
                                         {

                                          // Verifica se o trade esperado eh Venda (SHORT) apos range estabelecido por uma nova alta (HIGH)
                                          if(MySet[x].RangeHighLow=="HIGH" && MySet[x].TradeDirection=="SHORT")
                                            {
                                             if(MySet[x].NewRangeHighLow!="HIGH")
                                               {
                                                // Verifica se ja existe ordem pendente, no outro extremo da range
                                                if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                                //Informa que precisa enviar Ordem Pendente
                                                MySet[x].glPlaceOrder=true;
                                                MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                                MySet[x].RangeLevel=Daily[0].low+MySet[x].Range_MinPoints;  //Identifica o ponto onde a Range foi identificada

                                                Print("OnTick| TradeID:",MySet[x].TradeID," |Expected range HIGH on:"+(string)MySet[x].RangeLevel+" .Extremos do dia, neste momento. Daily High: "+(string)Daily[0].high+" Daily Low: "+(string)Daily[0].low+" Lastvalues: High["+(string)MySet[x].LastDailyHigh+"] Low["+(string)MySet[x].LastDailyLow+"]  HIGH/SHORT" );
                                                Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );
                                               }
                                             //Atualiza valor da variavel RangeHighLow
                                             MySet[x].NewRangeHighLow="HIGH";

                                            } //if ( MySet[x].RangeHighLow == "HIGH" && MySet[x].TradeDirection == "SHORT"  
                                          else if(MySet[x].RangeHighLow=="HIGH" && MySet[x].TradeDirection=="LONG") // Verifica se o trade esperado eh Compra (LONG) apos range estabelecido por uma nova alta (HIGH)
                                            {
                                             if(RangeCurrent>=(MySet[x].Range_MinPoints-Slippage))
                                               {
                                                if(MySet[x].NewRangeHighLow!="HIGH")
                                                  {
                                                   // Verifica se ja existe ordem pendente, no outro extremo da range
                                                   if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                                   //Informa que precisa enviar Ordem Pendente
                                                   MySet[x].glPlaceOrder=true;
                                                   MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                                   MySet[x].RangeLevel=Daily[0].low+MySet[x].Range_MinPoints;  //Identifica o ponto onde a Range foi identificada

                                                   Print("OnTick| TradeID:",MySet[x].TradeID," |Expected range HIGH on:"+(string)MySet[x].RangeLevel+" Extremos do dia, neste momento. Daily High: "+(string)Daily[0].high+" Daily Low: "+(string)Daily[0].low+" Lastvalues: High["+(string)MySet[x].LastDailyHigh+"] Low["+(string)MySet[x].LastDailyLow+"]  HIGH/LONG" );
                                                   Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );
                                                  }
                                                //Atualiza valor da variavel RangeHighLow
                                                MySet[x].NewRangeHighLow="HIGH";
                                               } //if ( RangeCurrent >= ( MySet[x].Range - Slippage ) )

                                            } // Close else. "// Verifica se o trade esperado eh Venda (SHORT) apos range estabelecido por uma nova alta (HIGH)"

                                         } //DailyBGSV

                                      } // DayPosition

                                   } // MID.1

                                } //CTC.1

                             } //CTO

                          } //Identifica se a range esta sendo formada por uma nova máxima(high)-->then; Ou por uma nova mínima(low)-->else
                        else if(Daily[0].low<MySet[x].LastDailyLow)
                          {

                           //Moment filters
                           //Filtros analisados no momento de entrada do trade

                           // CTO 
                           if(MySet[x].CTO=="" || (MySet[x].CTO=="+" && (Daily[0].high-MySet[x].Range_MinPoints)-DailyOpen>=0) || (MySet[x].CTO=="-" && (Daily[0].high-MySet[x].Range_MinPoints)-DailyOpen<0))
                             {

                              // CTC.1
                              if(MySet[x].CTC1=="" || (MySet[x].CTC1=="+" && (Daily[0].high-MySet[x].Range_MinPoints)-Y_Close>=0) || (MySet[x].CTC1=="-" && (Daily[0].high-MySet[x].Range_MinPoints)-Y_Close<0))
                                {

                                 // MID.1 [H+/M+/M-/L-]
                                 //if ( StringFind(MySet[x].MID1_Reference,MID1) > -1 )
                                 if((StringFind(MySet[x].MID1_Reference,fMID1((Daily[0].high-MySet[x].Range_MinPoints),Y_High,Y_Low)))>-1)
                                   {

                                    // DayPosition [ABOVE/BELOW/INSIDE/OUTSIDE]
                                    if(StringFind(MySet[x].DayPosition,Current_DayPosition)>-1)
                                      {

                                       // DailyBGSV
                                       if(MySet[x].DailyBGSV=="" || (MySet[x].DailyBGSV=="+" && (Daily[0].high-DailyOpen)>=(DailyOpen-Daily[0].low)) || (MySet[x].DailyBGSV=="-" && (Daily[0].high-DailyOpen)<(DailyOpen-Daily[0].low)))
                                         {

                                          if(MySet[x].RangeHighLow=="LOW" && MySet[x].TradeDirection=="LONG")
                                            {
                                             if(MySet[x].NewRangeHighLow!="LOW")
                                               {
                                                // Verifica se ja existe ordem pendente, no outro extremo da range
                                                if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                                //Informa que precisa enviar Ordem Pendente 
                                                MySet[x].glPlaceOrder=true;
                                                MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                                MySet[x].RangeLevel=Daily[0].high-MySet[x].Range_MinPoints;  //Identifica o ponto onde a Range foi identificada

                                                Print("OnTick| TradeID:",MySet[x].TradeID," |Expected range LOW on:"+(string)MySet[x].RangeLevel+" Extremos do dia, neste momento. Daily High: "+(string)Daily[0].high+" Daily Low: "+(string)Daily[0].low+" Lastvalues: High["+(string)MySet[x].LastDailyHigh+"] Low["+(string)MySet[x].LastDailyLow+"]  LOW/LONG" );
                                                Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );
                                               } //if ( MySet[x].NewRangeHighLow != "LOW" )
                                             //Atualiza valor da variavel RangeHighLow
                                             MySet[x].NewRangeHighLow="LOW";
                                            } //if ( MySet[x].RangeHighLow == "LOW" && MySet[x].TradeDirection == "LONG"  )
                                          else
                                            {
                                             if(RangeCurrent>=(MySet[x].Range_MinPoints-Slippage))
                                               {

                                                if(MySet[x].NewRangeHighLow!="LOW")
                                                  {
                                                   // Verifica se ja existe ordem pendente, no outro extremo da range
                                                   if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;
                                                      //Informa que precisa enviar Ordem Pendente 
                                                      MySet[x].glPlaceOrder=true;
                                                      MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                                      MySet[x].RangeLevel=Daily[0].high-MySet[x].Range_MinPoints;  //Identifica o ponto onde a Range foi identificada
   
                                                      Print("OnTick| TradeID:",MySet[x].TradeID," |Expected range LOW on:"+(string)MySet[x].RangeLevel+" Extremos do dia, neste momento. Daily High: "+(string)Daily[0].high+" Daily Low: "+(string)Daily[0].low+" Lastvalues: High["+(string)MySet[x].LastDailyHigh+"] Low["+(string)MySet[x].LastDailyLow+"] LOW/SHORT" );
                                                      Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );
                                                  }   // if ( MySet[x].NewRangeHighLow != "LOW" )
                                                //Atualiza valor da variavel RangeHighLow
                                                MySet[x].NewRangeHighLow="LOW";

                                               } //if ( RangeCurrent >= ( MySet[x].Range - Slippage ) )
                                            }  //if ( MySet[x].RangeHighLow == "LOW" && MySet[x].TradeDirection == "LONG"  )                                  

                                         } //DailyBGSV

                                      } // DayPosition

                                   } // MID.1

                                } //CTC.1

                             } //CTO

                           //Show Line with Range on Current Chart
                           if(ObjectCreate(0,"HLINE_Range",OBJ_HLINE,0,0,50000))
                             {
                              MySet[x].RangeLineObj=true;
                              //--- set line color
                              ObjectSetInteger(0,"HLINE_Range",OBJPROP_COLOR,clrGold);
                             }
                           if(MySet[x].RangeLineObj) ObjectMove(0,"HLINE_Range",0,0,MySet[x].RangeLevel);

                          } //Range high or low
                       } // else related to [if ( RangeCurrent > MySet[x].Range && MySet[x].Trade_Status == "WAITING" ) ]

                    } // TradeType RANGE. Check Entry signal and previous order request
                  
                  //=============================================================================
                  // TradeType: HIGHLOW ==== Check Entry signal and previous order request
                  //=============================================================================
                  // Condição para HIGHLOW: 1 - Tem que ser HIGHLOW e (Nova máxima ou nova mínima) e;
                  //                        2 - Para HIGHLOW positivo, (máxima-abertura)>highlow ou (Mínima-abertura)<= high_low_pre_limit e;
                  //                        3 - Para HIGHLOW negativo, (mínima-abertura)>highlow ou (máxima-abertura)<= high_low_pre_limit e;
                  //                        4 - Outras verificações com trade Status
                  //MySet[x].EarlyOrder_Distance - É uma antecipação do valor de entrada no mercado
                  
                  
                  //Rompeu a máxima ou mínima do dia para HIGHLOW
                  else if(MySet[x].TradeType=="HIGHLOW" && (Daily[0].high>MySet[x].LastDailyHigh || Daily[0].low<MySet[x].LastDailyLow))
                  {
                     //Cálculo do ZScore do HIGHLOW   
                     double ValueCurrentPoints = ((MySet[x].HighLow>0)?Daily[0].high-DailyOpen:Daily[0].low-DailyOpen);
                     //1 - Calculo o ZScore do HIGHLOW no momento (Daily[0].high-DailyOpen ou Daily[0].low-DailyOpen) - para plotar prints e conferir valores
                     //2 - Converto o valor do HIGHLOW do csv para pontos - pensado para aproveitar a lógica já existente
                     double HighLowZSCoreToPoints=0;
                     double ValueCurrentZScore=0;
                     ZScoreHighLow(MySet[x].WindowZScore,ValueCurrentPoints,MySet[x].HighLow,ValueCurrentZScore,HighLowZSCoreToPoints);
                     
                     //Calculo o ZScore do HIGHLOW pré-limit
                     ValueCurrentPoints = ((MySet[x].HighLow>0)?Daily[0].low-DailyOpen:Daily[0].high-DailyOpen);
                     double HLPreLimitZSCoreToPoints=0;
                     double ValueCurrentHLPreLimitZScore=0;
                     ZScoreHighLow(MySet[x].WindowZScore,ValueCurrentPoints,MySet[x].HighLow_PreLimit,ValueCurrentHLPreLimitZScore,HLPreLimitZSCoreToPoints);                                           
                     
                     if (((MySet[x].HighLow>0 &&(Daily[0].high-DailyOpen>=HighLowZSCoreToPoints-MySet[x].EarlyOrder_Distance || Daily[0].low-DailyOpen<=HLPreLimitZSCoreToPoints)) ||
                        (MySet[x].HighLow<0 && (Daily[0].low-DailyOpen<=HighLowZSCoreToPoints+MySet[x].EarlyOrder_Distance || Daily[0].high-DailyOpen>=HLPreLimitZSCoreToPoints)))
                       && !MySet[x].glOrderexecuted && (MySet[x].Trade_Status!="FINISHED" && MySet[x].Trade_Status!="STARTED" && MySet[x].EntryOrder_Status!="REJECTED"))
                     {
                        // Verifica se range atual esta acima da range de trade. Neste caso, simplesmente descarta o trade, 
                        // senao, caso o EA inicie no meio do dia, teremos varios trades startados erroneamente.
                        if(((MySet[x].HighLow>0 &&((Daily[0].high-DailyOpen)>HighLowZSCoreToPoints+Slippage || (Daily[0].low-DailyOpen)<=HLPreLimitZSCoreToPoints)) ||
                           (MySet[x].HighLow<0 && ((Daily[0].low-DailyOpen)<HighLowZSCoreToPoints-Slippage || (Daily[0].high-DailyOpen)>=HLPreLimitZSCoreToPoints)))
                           && MySet[x].Trade_Status=="WAITING") // Verifica se range atual esta acima da range de trade. Neste caso, simplesmente descarta o trade, senao caso o EA inicie no meio do dia, teriamos varios trades startados erroneamente
                          {
                           MySet[x].Trade_Status="FINISHED"; // Ponto e entrada ja foi alcancado no passado. Evitar entrada atrasada
                           if(ExibirLogsDetalhados)
                              Print("OnTick| Cancelando trades com ponto de entrada inferior ao HighLow atual! TradeID:"+MySet[x].TradeID+"/"+(string)HighLowZSCoreToPoints+"/"+(string)HLPreLimitZSCoreToPoints+"/"+(string)MySet[x].TradeDirection);
                              Print("OnTick| HighLow atual em ZSCore! TradeID:"+MySet[x].TradeID+"/"+(string)ValueCurrentZScore+"/"+(string)ValueCurrentHLPreLimitZScore+"/"+(string)MySet[x].TradeDirection);

                          
                          }
                        // Verifica se range atual esta acima da range de trade. Neste caso, simplesmente descarta o trade, 
                        // senao, caso o EA inicie no meio do dia, teremos varios trades startados erroneamente.
                        else if(((MySet[x].HighLow>0 && ((Daily[0].high-DailyOpen)>HighLowZSCoreToPoints+Slippage || (Daily[0].low-DailyOpen)<=HLPreLimitZSCoreToPoints)) || 
                           (MySet[x].HighLow<0 && ((Daily[0].low-DailyOpen)<HighLowZSCoreToPoints-Slippage || (Daily[0].high-DailyOpen)>=HLPreLimitZSCoreToPoints)))
                           && (MySet[x].Trade_Status=="REQUESTED" || MySet[x].Trade_Status=="PLACED")) // Verifica se range atual esta acima da range de trade. Neste caso, simplesmente descarta o trade, senao caso o EA inicie no meio do dia, teriamos varios trades startados erroneamente
                             {
                              bool OrderCanceled=Trade.OrderDelete(MySet[x].EntryOrder_OrderNumber);
                              if(OrderCanceled)
                                {
                                 Print("OnTick| Ordem Cancelada. Ticket: "+(string)MySet[x].EntryOrder_OrderNumber+" Status: "+(string)OrderCanceled);
                                 CancelPreviousOrder=false;
                                 MySet[x].glBuyPlaced=false;
                                 MySet[x].glSellPlaced=false;
                                 MySet[x].glOrderPlaced=false;
                                 MySet[x].EntryOrder_Status="REMOVED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                        
                                }
                              else
                                {
                                 Print("OnTick| Problema com o cancelamento da ordem!. Order Number: "+(string)MySet[x].EntryOrder_OrderNumber);
                                }
                        
                              MySet[x].Trade_Status="FINISHED"; // Ponto e entrada ja foi alcancado no passado. Evitar entrada atrasada
                              if(ExibirLogsDetalhados)
                                 Print("OnTick| Cancelando trades com ponto de entrada inferior ao HighLow atual! TradeID: "+MySet[x].TradeID+"/"+(string)HLPreLimitZSCoreToPoints+"/"+(string)MySet[x].TradeDirection);
                                 Print("OnTick| HighLow atual em ZSCore! TradeID:"+MySet[x].TradeID+"/"+(string)ValueCurrentZScore+"/"+(string)ValueCurrentHLPreLimitZScore+"/"+(string)MySet[x].TradeDirection);
                       
                             }
                           else
                             { // else related to [if ( RangeCurrent > MySet[x].Range_Min && MySet[x].Trade_Status == "WAITING" ) ]
                              //PlaySound("alert.wav"); // Play Sound as signal that range was stablished on level requested.
                        
                              //Print( "Daily extremes: high "+ (string)Daily[0].high  +" -LastHigh "+ (string)MySet[x].LastDailyHigh  +" - low "+ (string)Daily[0].low +" - LastLow "+ (string)MySet[x].LastDailyLow );
                        
                              //Identifica se a range esta sendo formada por uma nova máxima(high) ou por uma nova mínima(low)
                              if(Daily[0].high>MySet[x].LastDailyHigh && MySet[x].HighLow>0)
                                 {
                        
                                 //Moment filters
                                 //Filtros analisados no momento de entrada do trade
                        
                                 // CTO -- DESCONSIDERAR PARA O HIGHLOW pois esta explicito se o valor do highlow eh positivo ou negativo, em seu valor de referencia.
                                 //if ( MySet[x].CTO == "" || ( MySet[x].CTO == "+" && (Daily[0].low + MySet[x].Range_Min) - DailyOpen >= 0 ) || ( MySet[x].CTO == "-" && (Daily[0].low + MySet[x].Range_Min) - DailyOpen < 0 ) )
                                 //{
                        
                                 // CTC.1
                                 if(MySet[x].CTC1=="" || (MySet[x].CTC1=="+" && ((DailyOpen+HighLowZSCoreToPoints)-Y_Close)>=0) || (MySet[x].CTC1=="-" && ((DailyOpen+HighLowZSCoreToPoints)-Y_Close)<0))
                                   {
                        
                                    // MID.1 [H+/M+/M-/L-]
                                    //if ( StringFind(MySet[x].MID1_Reference,MID1) > -1 )
                                    if((StringFind(MySet[x].MID1_Reference,fMID1((DailyOpen+HighLowZSCoreToPoints),Y_High,Y_Low)))>-1)
                                      {
                        
                                       // DayPosition [ABOVE/BELOW/INSIDE/OUTSIDE]
                                       if(StringFind(MySet[x].DayPosition,Current_DayPosition)>-1)
                                         {
                        
                                          // DailyBGSV
                                          if(MySet[x].DailyBGSV=="" || (MySet[x].DailyBGSV=="+" && (Daily[0].high-DailyOpen)>=(DailyOpen-Daily[0].low)) || (MySet[x].DailyBGSV=="-" && (Daily[0].high-DailyOpen)<(DailyOpen-Daily[0].low)))
                                            {
                        
                                             // Verifica se o trade esperado eh Venda (SHORT) apos range estabelecido por uma nova alta (HIGH)
                                             if(MySet[x].TradeDirection=="SHORT")
                                               {
                                                if(MySet[x].NewRangeHighLow!="HIGH")
                                                  {
                                                   // Verifica se ja existe ordem pendente, no outro extremo da range
                                                   if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;
                                                      //Informa que precisa enviar Ordem Pendente
                                                      MySet[x].glPlaceOrder=true;
                                                      MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                      MySet[x].RangeLevel=DailyOpen+HighLowZSCoreToPoints;  //Identifica o ponto de entrada para a operacao HighLow
                        
                                                      Print("OnTick| TradeID:",MySet[x].TradeID," |Expected HighLow HIGH on:"+(string)HighLowZSCoreToPoints+" Extremos do dia, neste momento. Daily High: "+(string)Daily[0].high+" Daily Low: "+(string)Daily[0].low+" Lastvalues: High["+(string)MySet[x].LastDailyHigh+"] Low["+(string)MySet[x].LastDailyLow+"]  HIGH/SHORT" );
                                                      Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );
                                                  }
                                                //Atualiza valor da variavel RangeHighLow
                                                MySet[x].NewRangeHighLow="HIGH";
                        
                                               } //if ( MySet[x].RangeHighLow == "HIGH" && MySet[x].TradeDirection == "SHORT"  
                                             else if(MySet[x].TradeDirection=="LONG")// Verifica se o trade esperado eh Compra (LONG) apos parametros de entrada estabelecido por uma nova alta (HIGH)
                                               {
                                                if(Daily[0].high>=((DailyOpen+HighLowZSCoreToPoints)-Slippage))
                                                  {
                                                   if(MySet[x].NewRangeHighLow!="HIGH")
                                                     {
                                                      // Verifica se ja existe ordem pendente, no outro extremo da range
                                                      if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;
                        
                                                      //Informa que precisa enviar Ordem Pendente
                                                      MySet[x].glPlaceOrder=true;
                                                      MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                      MySet[x].RangeLevel=DailyOpen+HighLowZSCoreToPoints;  //Identifica o ponto de entrada para a operacao HighLow
                        
                                                      Print("OnTick| TradeID:",MySet[x].TradeID," |Expected HighLow HIGH on:"+(string)HighLowZSCoreToPoints+" Extremos do dia, neste momento. Daily High: "+(string)Daily[0].high+" Daily Low: "+(string)Daily[0].low+" Lastvalues: High["+(string)MySet[x].LastDailyHigh+"] Low["+(string)MySet[x].LastDailyLow+"]  HIGH/SHORT" );
                                                      Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );
                                                     }
                                                   //Atualiza valor da variavel RangeHighLow
                                                   MySet[x].NewRangeHighLow="HIGH";
                                                  } //if ( RangeCurrent >= ( MySet[x].Range_Min - Slippage ) )
                        
                                               } // Close else. "// Verifica se o trade esperado eh Venda (SHORT) apos range estabelecido por uma nova alta (HIGH)"
                        
                                            } //DailyBGSV
                        
                                         } // DayPosition
                        
                                      } //MID.1
                        
                                   } //CTC.1
                        
                                 //} //CTO
                        
                                } //Identifica se a range esta sendo formada por uma nova máxima(high)-->then; Ou por uma nova mínima(low)-->else
                              else if(Daily[0].low<MySet[x].LastDailyLow && MySet[x].HighLow<0)
                                {
                        
                                 //Moment filters
                                 //Filtros analisados no momento de entrada do trade
                        
                                 // CTO -- DESCONSIDERAR PARA O HIGHLOW
                                 //if ( MySet[x].CTO == "" || ( MySet[x].CTO == "+" && (Daily[0].low + MySet[x].Range_Min) - DailyOpen >= 0 ) || ( MySet[x].CTO == "-" && (Daily[0].low + MySet[x].Range_Min) - DailyOpen < 0 ) )
                                 //{
                        
                                 // CTC.1
                                 if(MySet[x].CTC1=="" || (MySet[x].CTC1=="+" && ((DailyOpen+HighLowZSCoreToPoints)-Y_Close)>=0) || (MySet[x].CTC1=="-" && ((DailyOpen+HighLowZSCoreToPoints)-Y_Close)<0))
                                   {
                        
                                    // MID.1 [H+/M+/M-/L-]
                                    //if ( StringFind(MySet[x].MID1_Reference,MID1) > -1 )
                                    if((StringFind(MySet[x].MID1_Reference,fMID1((DailyOpen+HighLowZSCoreToPoints),Y_High,Y_Low)))>-1)
                                      {
                        
                                       // DayPosition [ABOVE/BELOW/INSIDE/OUTSIDE]
                                       if(StringFind(MySet[x].DayPosition,Current_DayPosition)>-1)
                                         {
                        
                                          // DailyBGSV
                                          if(MySet[x].DailyBGSV=="" || (MySet[x].DailyBGSV=="+" && (Daily[0].high-DailyOpen)>=(DailyOpen-Daily[0].low)) || (MySet[x].DailyBGSV=="-" && (Daily[0].high-DailyOpen)<(DailyOpen-Daily[0].low)))
                                            {
                        
                                             if(MySet[x].TradeDirection=="LONG")
                                               {
                                                if(MySet[x].NewRangeHighLow!="LOW")
                                                  {
                                                   // Verifica se ja existe ordem pendente, no outro extremo da range
                                                   if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;
                        
                                                   //Informa que precisa enviar Ordem Pendente 
                                                   MySet[x].glPlaceOrder=true;
                                                   MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                                   MySet[x].RangeLevel=DailyOpen+HighLowZSCoreToPoints;  //Identifica o ponto de entrada para a operacao HighLow
                        
                                                   Print("OnTick| TradeID:",MySet[x].TradeID," |Expected HighLow LOW on:"+(string)HighLowZSCoreToPoints+" Extremos do dia, neste momento. Daily High: "+(string)Daily[0].high+" Daily Low: "+(string)Daily[0].low+" Lastvalues: High["+(string)MySet[x].LastDailyHigh+"] Low["+(string)MySet[x].LastDailyLow+"]  HIGH/SHORT" );
                                                   Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );
                                                  } //if ( MySet[x].NewRangeHighLow != "LOW" )
                                                //Atualiza valor da variavel RangeHighLow
                                                MySet[x].NewRangeHighLow="LOW";
                                               } //if ( MySet[x].RangeHighLow == "LOW" && MySet[x].TradeDirection == "LONG"  )
                                             else if(MySet[x].TradeDirection=="SHORT")
                                               {
                                                if(Daily[0].low<=((DailyOpen+HighLowZSCoreToPoints)+Slippage))
                                                  {
                        
                                                   if(MySet[x].NewRangeHighLow!="LOW")
                                                     {
                                                      // Verifica se ja existe ordem pendente, no outro extremo da range
                                                      if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;
                        
                                                      //Informa que precisa enviar Ordem Pendente 
                                                      MySet[x].glPlaceOrder=true;
                                                      MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                                      MySet[x].RangeLevel=DailyOpen+HighLowZSCoreToPoints;  //Identifica o ponto de entrada para a operacao HighLow
                        
                                                      Print("OnTick| TradeID:",MySet[x].TradeID," |Expected HighLow LOW on:"+(string)HighLowZSCoreToPoints+" Extremos do dia, neste momento. Daily High: "+(string)Daily[0].high+" Daily Low: "+(string)Daily[0].low+" Lastvalues: High["+(string)MySet[x].LastDailyHigh+"] Low["+(string)MySet[x].LastDailyLow+"]  HIGH/SHORT" );
                                                      Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );
                        
                                                     }   // if ( MySet[x].NewRangeHighLow != "LOW" )
                                                   //Atualiza valor da variavel RangeHighLow
                                                   MySet[x].NewRangeHighLow="LOW";
                        
                                                  } //if ( RangeCurrent >= ( MySet[x].Range_Min - Slippage ) )
                                               }  //if ( MySet[x].RangeHighLow == "LOW" && MySet[x].TradeDirection == "LONG"  )                                  
                        
                                            } //DailyBGSV
                        
                                         } // DayPosition
                        
                                      } //MID.1
                        
                                   } //CTC.1
                        
                                 //} //CTO
                        
                                 //Show Line with Range on Current Chart
                                 if(ObjectCreate(0,"HLINE_Range",OBJ_HLINE,0,0,50000))
                                   {
                                    MySet[x].RangeLineObj=true;
                                    //--- set line color
                                    ObjectSetInteger(0,"HLINE_Range",OBJPROP_COLOR,clrGold);
                                   }
                                 if(MySet[x].RangeLineObj) ObjectMove(0,"HLINE_Range",0,0,MySet[x].RangeLevel);
                        
                                } //Range high or low
                             } // else related to [if ( RangeCurrent > MySet[x].Range_Min && MySet[x].Trade_Status == "WAITING" ) ]
                        }
                     } // TradeType HIGHLOW. Check Entry signal and previous order request

                     //=============================================================================
                     // TradeType: QUANTTREND ==== Check Entry signal and previous order request
                     //=============================================================================
                     //               else if ( MySet[x].TradeType == "QUANTTREND"  && MySet[x].EntryOrder_Status != "REJECTED" )
                     //               {
                     //                  // Dynamic arrays to store indicators values
                     //                  double _wpr[];
                     //                  double _ma1[];
                     //                  
                     //                  // Setting the indexing in arrays the same as in timeseries, i.e. array element with zero
                     //                  // index will store the values of the last bar, with 1th index - the last but one, etc.
                     //                  ArraySetAsSeries(_wpr, true);
                     //                  ArraySetAsSeries(_ma1, true);
                     //                  
                     //                  // Using indicators handles, let's copy the values of indicator
                     //                  // buffers to arrays, specially prepared for this purpose
                     //                  if (CopyBuffer(MySet[x].Will_PercentR,0,0,MySet[x].WPRLength,_wpr) < 0){Print("CopyBufferWPR error =",GetLastError());}
                     //                  if (CopyBuffer(MySet[x].MA1,0,0,MySet[x].wMALength,_ma1) < 0){Print("CopyBufferMA1 error =",GetLastError());}
                     //
                     //                  
                     //               	// Order placement
                     //               	//if(newBar == true && timerOn == true && ( EntryTimerOn == true || MySet[x].UseEntryTimer == false ) )
                     //               	//{
                     //                  
                     //            		//MOVING AVERAGE
                     //            		if ( rates[barShift].close > _ma1[barShift] )
                     //            		{
                     //                     //Print ("Preço "+(string)rates[barShift].close+" acima da média: "+(string)_ma1[barShift] );
                     //            		   wMA_Signal = "ACIMA_MA";
                     //            		}
                     //            	   else if (rates[barShift].close < _ma1[barShift] )
                     //            	   {
                     //                     //Print ("Preço "+(string)rates[barShift].close+" abaixo da média: "+(string)_ma1[barShift] );
                     //            		   wMA_Signal = "ABAIXO_MA";
                     //            	   }
                     //            	   else ( wMA_Signal = "NONE" );
                     //                  
                     //                  
                     //            		// WILLIAMS PERCENT R (%R) 
                     //            		if (_wpr[barShift] > MySet[x].WPR_OverBoughtLevel) 
                     //            		{
                     //                     //Print("OnTick| Williams %R [0] acima de ",(string)MySet[x].WPR_OverBoughtLevel,": ", (string)_wpr[0] );
                     //                     //Print("OnTick| Williams %R [",(string)barShift,"] acima de ",(string)MySet[x].WPR_OverBoughtLevel,": ", (string)_wpr[barShift] );
                     //                     WPR_Signal = "ACIMA_WR";
                     //            		}
                     //            		else if (_wpr[barShift] < MySet[x].WPR_OverSoldLevel)
                     //            		{
                     //            		   //Print("OnTick| Williams %R [0] abaixo de ",(string)MySet[x].WPR_OverSoldLevel,": ", (string)_wpr[0] );
                     //            		   //Print("OnTick| Williams %R [",(string)barShift,"] abaixo de ",(string)MySet[x].WPR_OverSoldLevel,": ", (string)_wpr[barShift] );
                     //                     WPR_Signal = "ABAIXO_WR";
                     //            		}
                     //            		else (WPR_Signal = "NONE");
                     //                  
                     //                  
                     //                  //Print("OnTick| Posicao atual: "+MySet[x].EntryOrder_Status+" BuyPlaced: "+(string)MySet[x].glBuyPlaced+" SellPlaced: "+(string)MySet[x].glSellPlaced );
                     //                  //Print("OnTick| x: ",x," |TradeType: ",MySet[x].TradeType," |Trade_Status:",MySet[x].Trade_Status," |EntryOrder_Status:",MySet[x].EntryOrder_Status," |TgtOrder_Status:",MySet[x].TgtOrder_Status," |StopOrder_Status:",MySet[x].StopOrder_Status );
                     //                  
                     //                  
                     //                  //Check last position status
                     //                  if ( MySet[x].EntryOrder_Status == "" && ( MySet[x].glBuyPlaced == true || MySet[x].glSellPlaced == true ) && (MySet[x].EntryOrder_type != "DEAL_TYPE_BUY" || MySet[x].EntryOrder_type != "DEAL_TYPE_SELL") ) 
                     //                  {
                     //                     Print("Posicao encerrada. Reiniciando as flags.");
                     //                     MySet[x].glBuyPlaced = false;
                     //                     MySet[x].glSellPlaced = false;
                     //                     //glOrderPlacedWaitingReturn = false; MySet[x].EntryOrder_Status == "PLACED"
                     //                     //Position_lastchecked_status = MySet[x].EntryOrder_Status;
                     //                  }
                     //                  
                     //                  
                     //           		   //Moment filters
                     //                  //Filtros analisados no momento de entrada do trade
                     //                  
                     //                  // CTO 
                     //                  if ( MySet[x].CTO == "" || ( MySet[x].CTO == "+" && (Daily[0].low + MySet[x].Range_Min) - DailyOpen >= 0 ) || ( MySet[x].CTO == "-" && (Daily[0].low + MySet[x].Range_Min) - DailyOpen < 0 ) )
                     //                  {
                     //                     
                     //                     // CTC.1
                     //                     if ( MySet[x].CTC1 == "" || ( MySet[x].CTC1 == "+" && (Daily[0].low + MySet[x].Range_Min) - Y_Close >= 0 ) || ( MySet[x].CTC1 == "-" && (Daily[0].low + MySet[x].Range_Min) - Y_Close < 0 ) )
                     //                     {
                     //                        
                     //                        // DayPosition [ABOVE/BELOW/INSIDE/OUTSIDE]
                     //                        if ( StringFind(MySet[x].DayPosition,Current_DayPosition) > -1 )
                     //                        {
                     //                           
                     //                           // DailyBGSV
                     //                           if ( MySet[x].DailyBGSV == "" || ( MySet[x].DailyBGSV == "+" && (Daily[0].high - DailyOpen) >= (DailyOpen - Daily[0].low) ) || ( MySet[x].DailyBGSV == "-" && (Daily[0].high - DailyOpen) < (DailyOpen - Daily[0].low) ) )
                     //                           {
                     //                              
                     //                        		// Open order above the MovingAverage
                     //                        		if( wMA_Signal == "ACIMA_MA" && MySet[x].wMA_Side == 1  )
                     //                        		{
                     //                        		    if( WPR_Signal == "ACIMA_WR" && MySet[x].WPR_CutLevel_Side == 1 )
                     //                        		    {
                     //                              		   if( MySet[x].TradeDirection == "LONG" &&  MySet[x].EntryOrder_type != "DEAL_TYPE_BUY" && MySet[x].glBuyPlaced == false && MySet[x].glSellPlaced == false )
                     //                              		   {
                     //                                    		Print("OnTick| QUANTTREND. TradeID:",MySet[x].TradeID," Parametros: |MA ",wMA_Signal," |WPR: ",WPR_Signal) ;
                     //                                    		Print("OnTick| QUANTTREND. TradeID:",MySet[x].TradeID," Solicita entrada LONG!");
                     //                                             
                     //                                          // Verifica se ja existe ordem pendente, no outro extremo da range
                     //                                          if ( MySet[x].glOrderPlaced ) CancelPreviousOrder = true;
                     //                                                
                     //                                          //Informa que precisa enviar Ordem Pendente
                     //                                          MySet[x].glPlaceOrder = true;
                     //                                          MySet[x].EntryOrder_Status = "REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                     //                                    		      
                     //                                       }    // if( MySet[x].TradeDirection == "LONG" &&...)
                     //                                   	   else if( MySet[x].TradeDirection == "SHORT" && MySet[x].EntryOrder_type != "DEAL_TYPE_SELL" && MySet[x].glBuyPlaced == false && MySet[x].glSellPlaced == false )
                     //                              		   {
                     //                                    		Print("OnTick| QUANTTREND. TradeID:",MySet[x].TradeID," Parametros: |MA ",wMA_Signal," |WPR: ",WPR_Signal) ;
                     //                                    		Print("OnTick| QUANTTREND. TradeID:",MySet[x].TradeID," Solicita entrada SHORT!");
                     //                                          
                     //                                          // Verifica se ja existe ordem pendente, no outro extremo da range
                     //                                          if ( MySet[x].glOrderPlaced ) CancelPreviousOrder = true;
                     //                                                
                     //                                          //Informa que precisa enviar Ordem Pendente
                     //                                          MySet[x].glPlaceOrder = true;
                     //                                          MySet[x].EntryOrder_Status = "REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                     //                              		   } // else if( MySet[x].TradeDirection == "SHORT" && ...)
                     //            
                     //               						} // if( WPR_Signal == "ACIMA_WR" && MySet[x].WPR_CutLevel_Side == 1/*ACIMA_WR*/ )
                     //               						else if( WPR_Signal == "ABAIXO_WR" && MySet[x].WPR_CutLevel_Side == 0 )
                     //               						{
                     //                              		   if( MySet[x].TradeDirection == "LONG" && MySet[x].EntryOrder_type != "DEAL_TYPE_BUY"  && MySet[x].glBuyPlaced == false && MySet[x].glSellPlaced == false )
                     //                              		   {
                     //                                    		Print("OnTick| QUANTTREND. TradeID:",MySet[x].TradeID," Parametros: |MA ",wMA_Signal," |WPR: ",WPR_Signal) ;
                     //                                    		Print("OnTick| QUANTTREND. TradeID:",MySet[x].TradeID," Solicita entrada LONG!");
                     //                                             
                     //                                          // Verifica se ja existe ordem pendente, no outro extremo da range
                     //                                          if ( MySet[x].glOrderPlaced ) CancelPreviousOrder = true;
                     //                                                
                     //                                          //Informa que precisa enviar Ordem Pendente
                     //                                          MySet[x].glPlaceOrder = true;
                     //                                          MySet[x].EntryOrder_Status = "REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                     //   
                     //                     						} // if( MySet[x].TradeDirection == "LONG" &&...)
                     //                                    	else if( MySet[x].TradeDirection == "SHORT" && MySet[x].EntryOrder_type != "DEAL_TYPE_SELL" && MySet[x].glBuyPlaced == false && MySet[x].glSellPlaced == false )
                     //                              		   {
                     //                                    		Print("OnTick| QUANTTREND. TradeID:",MySet[x].TradeID," Parametros: |MA ",wMA_Signal," |WPR: ",WPR_Signal) ;
                     //                                    		Print("OnTick| QUANTTREND. TradeID:",MySet[x].TradeID," Solicita entrada SHORT!");
                     //                                          
                     //                                          // Verifica se ja existe ordem pendente, no outro extremo da range
                     //                                          if ( MySet[x].glOrderPlaced ) CancelPreviousOrder = true;
                     //                                          
                     //                                          //Informa que precisa enviar Ordem Pendente
                     //                                          MySet[x].glPlaceOrder = true;
                     //                                          MySet[x].EntryOrder_Status = "REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                     //                                       } // else if( MySet[x].TradeDirection == "SHORT" && ...)
                     //                                       
                     //            						   } // else if( WPR_Signal == "ABAIXO_WR" && MySet[x].WPR_CutLevel_Side == 0/*ABAIXO_WR*/ )
                     //                         		} // if(wMA_Signal == "ACIMA_MA" && MySet[x].wMA_Side == 1 /*ACIMA_MA*/ )
                     //                              
                     //                        		// Open order below the MovingAverage
                     //                        		if(wMA_Signal == "ABAIXO_MA" && MySet[x].wMA_Side == 0 )
                     //                        		{
                     //                        		   if( WPR_Signal == "ACIMA_WR" && MySet[x].WPR_CutLevel_Side == 1 )
                     //                        		   {
                     //                              		   if( MySet[x].TradeDirection == "LONG" && MySet[x].EntryOrder_type != "DEAL_TYPE_BUY"  && MySet[x].glBuyPlaced == false && MySet[x].glSellPlaced == false )
                     //                              		   {
                     //                                    		Print("OnTick| QUANTTREND. TradeID:",MySet[x].TradeID," Parametros: |MA ",wMA_Signal," |WPR: ",WPR_Signal) ;
                     //                                    		Print("OnTick| QUANTTREND. TradeID:",MySet[x].TradeID," Solicita entrada LONG!");
                     //                                             
                     //                                          // Verifica se ja existe ordem pendente, no outro extremo da range
                     //                                          if ( MySet[x].glOrderPlaced ) CancelPreviousOrder = true;
                     //                                                
                     //                                          //Informa que precisa enviar Ordem Pendente
                     //                                          MySet[x].glPlaceOrder = true;
                     //                                          MySet[x].EntryOrder_Status = "REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                     //   
                     //                     						} // if( MySet[x].TradeDirection == "LONG" &&...)
                     //                                    	else if( MySet[x].TradeDirection == "SHORT" && MySet[x].EntryOrder_type != "DEAL_TYPE_SELL" && MySet[x].glBuyPlaced == false && MySet[x].glSellPlaced == false )
                     //                              		   {
                     //                                    		Print("OnTick| QUANTTREND. TradeID:",MySet[x].TradeID," Parametros: |MA ",wMA_Signal," |WPR: ",WPR_Signal) ;
                     //                                    		Print("OnTick| QUANTTREND. TradeID:",MySet[x].TradeID," Solicita entrada SHORT!");
                     //                                          
                     //                                          // Verifica se ja existe ordem pendente, no outro extremo da range
                     //                                          if ( MySet[x].glOrderPlaced ) CancelPreviousOrder = true;
                     //                                                
                     //                                          //Informa que precisa enviar Ordem Pendente
                     //                                          MySet[x].glPlaceOrder = true;
                     //                                          MySet[x].EntryOrder_Status = "REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                     //                                       } // else if( MySet[x].TradeDirection == "SHORT" && ...)
                     //   
                     //            						   } // if( WPR_Signal == "ACIMA_WR" && MySet[x].WPR_CutLevel_Side == 1 )
                     //            						   else if( WPR_Signal == "ABAIXO_WR" && MySet[x].WPR_CutLevel_Side == 0 )
                     //            						   {
                     //                              		   if( MySet[x].TradeDirection == "LONG" && MySet[x].EntryOrder_type != "DEAL_TYPE_BUY"  && MySet[x].glBuyPlaced == false && MySet[x].glSellPlaced == false )
                     //                              		   {
                     //                                    		Print("OnTick| QUANTTREND. TradeID:",MySet[x].TradeID," Parametros: |MA ",wMA_Signal," |WPR: ",WPR_Signal) ;
                     //                                    		Print("OnTick| QUANTTREND. Solicita entrada LONG!");
                     //                                             
                     //                                          // Verifica se ja existe ordem pendente, no outro extremo da range
                     //                                          if ( MySet[x].glOrderPlaced ) CancelPreviousOrder = true;
                     //                                                
                     //                                          //Informa que precisa enviar Ordem Pendente
                     //                                          MySet[x].glPlaceOrder = true;
                     //                                          MySet[x].EntryOrder_Status = "REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                     //   
                     //                     						} // if( MySet[x].TradeDirection == "LONG" &&...)
                     //                                    	else if( MySet[x].TradeDirection == "SHORT" && MySet[x].EntryOrder_type != "DEAL_TYPE_SELL" && MySet[x].glBuyPlaced == false && MySet[x].glSellPlaced == false )
                     //                              		   {
                     //                                    		Print("OnTick| QUANTTREND. TradeID:",MySet[x].TradeID," Parametros: |MA ",wMA_Signal," |WPR: ",WPR_Signal) ;
                     //                                    		Print("OnTick| QUANTTREND. TradeID:",MySet[x].TradeID," Solicita entrada SHORT!");
                     //                                          
                     //                                          // Verifica se ja existe ordem pendente, no outro extremo da range
                     //                                          if ( MySet[x].glOrderPlaced ) CancelPreviousOrder = true;
                     //                                                
                     //                                          //Informa que precisa enviar Ordem Pendente
                     //                                          MySet[x].glPlaceOrder = true;
                     //                                          MySet[x].EntryOrder_Status = "REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                     //                                       } // else if( MySet[x].TradeDirection == "SHORT" && ...)
                     //            	   
                     //            						   } // wWR_Signal == ABAIXO_WR
                     //                        		} // if(wMA_Signal == "ABAIXO_MA" && MySet[x].wMA_Side == 0 /*ABAIXO_MA*/ )
                     //                           } //DailyBGSV
                     //                        } // DayPosition
                     //                     } //CTC.1
                     //                  } //CTO
                     //                 //} // Order placement end
                     //               } // TradeType: QUANTTREND ==== Check Entry signal and previous order request



                     //=============================================================================
                     // TradeType: TIMEENTRY ==== Check Entry signal and previous order request
                     //=============================================================================
                     else if(MySet[x].TradeType=="TIMEENTRY" && MySet[x].Trade_Status!="FINISHED" && MySet[x].Trade_Status!="STARTED" && MySet[x].EntryOrder_Status!="REJECTED")
                       {
                        bool filtroMaOk=false;
                        if(MySet[x].MaPeriodo==0 && MySet[x].MaPosition==0)
                          {
                           filtroMaOk=true;
                          }
                        else if(MySet[x].MaPeriodo>0 && MySet[x].MaPosition!=0)
                          {

                           ArraySetAsSeries(MySet[x].MaBuffer,true);

                           int bufferCurrent=CopyBuffer(MySet[x].MaHandle,0,0,3,MySet[x].MaBuffer);

                           if(bufferCurrent>0)
                             {
                              double ma=MySet[x].MaBuffer[0];
                              if(MySet[x].TradeDirection=="LONG") //Compra
                                {
                                if(MySet[x].MaPosition==1 && rates[0].close>ma) //Compra acima da media 
                                   {
                                    filtroMaOk=true;
                                   }
                                 else if(MySet[x].MaPosition==-1 && rates[0].close<ma) //Compra abaixo da media
                                   {
                                    filtroMaOk=true;
                                   }

                                }

                              if(MySet[x].TradeDirection=="SHORT") // Venda
                                {

                                 if(MySet[x].MaPosition==1 && rates[0].close>ma) //venda acima da media 
                                   {
                                    filtroMaOk=true;
                                   }
                                 else if(MySet[x].MaPosition==-1 && rates[0].close<ma) //venda abaixo da media
                                   {
                                    filtroMaOk=true;
                                   }
                                }

                             }
                          }

                        if(TimeToString(TimeCurrent(),TIME_MINUTES)>TimeToString(MySet[x].EntryStartTimer,TIME_MINUTES)
                           && MySet[x].Timer_RefPoint==0
                           && MySet[x].Trade_Status=="WAITING") // Verifica se ja passou do horario de referencia da estrategia. Neste caso, simplesmente descarta o trade, senao caso o EA inicie no meio do dia, teriamos varios trades startados erroneamente
                          {
                           MySet[x].Trade_Status="FINISHED"; // Horario de referencia ja passou. Evitar entrada atrasada
                           if(ExibirLogsDetalhados)
                              Print("OnTick| Cancelando trades atrasados, com horario de referencia no passado! Trade: "+(string)MySet[x].TradeID+"/ Start Timer:"+TimeToString(MySet[x].EntryStartTimer,TIME_MINUTES)+" / CurrentTime:"+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES)+" /"+(string)MySet[x].TradeDirection);
                           continue; // continue ou usar else?
                          }

                        //Print( "OnTick| TradeID:",MySet[x].TradeID," MySet[",x,"].Timer_RefPoint:",MySet[x].Timer_RefPoint );
                        // Get Reference Point
                        if(EntryTimerOn==true && MySet[x].Timer_RefPoint==0)
                          {
                           //Timer_RefPoint = rates[1].close;
                           MySet[x].Timer_RefPoint=rates[0].close;
                           MySet[x].Timer_EntryPoint=MySet[x].Timer_RefPoint+MySet[x].EntryPoint;
                           MySet[x].Timer_Ref_fromDailyOpen=MySet[x].Timer_RefPoint-DailyOpen;

                           Print("OnTick| TIMEENTRY. TradeID: ",MySet[x].TradeID," |TimeCurrent:",TimeToString(TimeCurrent(),TIME_SECONDS)," |Data e Hora de referencia: ",TimeToString(rates[0].time,TIME_DATE|TIME_SECONDS),"| ReferencePoint: ",MySet[x].Timer_RefPoint,"| EntryPoint: ",MySet[x].Timer_EntryPoint,"| Reference from Daily Open: ",MySet[x].Timer_Ref_fromDailyOpen);
                          }
                        // Escala em ZScore
                        MySet[x].Timer_Ref_fromDailyOpenZScore=ZScore("TIMEENTRY",MySet[x].WindowZScore,MySet[x].EntryStartHour,MySet[x].EntryStartMinute,MySet[x].Timer_Ref_fromDailyOpen);
                        // Escala em pontos
                        //if(MySet[x].Timer_Ref_fromDailyOpen>MySet[x].EntryRef_Open_Top || MySet[x].Timer_Ref_fromDailyOpen<MySet[x].EntryRef_Open_Bottom)
                        if(MySet[x].Timer_Ref_fromDailyOpenZScore>MySet[x].EntryRef_Open_Top || MySet[x].Timer_Ref_fromDailyOpenZScore<MySet[x].EntryRef_Open_Bottom)
                          {
                           MySet[x].Trade_Status="FINISHED"; // Horario de referencia ja passou. Evitar entrada atrasada
                           //Print("OnTick| Preco fora da range de referencia! Trade: "+(string)MySet[x].TradeID+"/"+TimeToString(MySet[x].EntryStartTimer,TIME_MINUTES)+"/ RefRangeTOP:"+(string)MySet[x].EntryRef_Open_Top+"/ RefRangeBOTTOM:"+(string)MySet[x].EntryRef_Open_Bottom+"/ Referencia abertura:"+(string)MySet[x].Timer_Ref_fromDailyOpen);
                           Print("OnTick| Preco fora da range de referencia! Trade: "+(string)MySet[x].TradeID+"/"+TimeToString(MySet[x].EntryStartTimer,TIME_MINUTES)+"/ RefRangeTOP:"+(string)MySet[x].EntryRef_Open_Top+"/ RefRangeBOTTOM:"+(string)MySet[x].EntryRef_Open_Bottom+"/ Referencia abertura Em ZScore:"+(string)MySet[x].Timer_Ref_fromDailyOpenZScore);
                           continue; // continue ou usar else?
                          }

                        // LATE ENTRY. Verifica se preco ja passou do ponto de entrada. Neste caso, simplesmente descarta o trade, 
                        // senao, caso o EA inicie no meio do dia, teremos varios trades startados erroneamente. LATE ENTRY
                        if(((MySet[x].EntryPoint>=0 && rates[0].close>MySet[x].Timer_EntryPoint+Slippage) || 
                           (MySet[x].EntryPoint<0 && rates[0].close<MySet[x].Timer_EntryPoint-Slippage))
                           && MySet[x].Trade_Status=="WAITING") // Verifica se o preco atual ja ultrapassou o ponto de entrada. Neste caso, simplesmente descarta o trade, senao caso o EA inicie no meio do dia, teriamos varios trades startados erroneamente
                          {
                           MySet[x].Trade_Status="FINISHED"; // Ponto e entrada ja foi alcancado no passado. Evitar entrada atrasada
                           if(ExibirLogsDetalhados)
                              Print("OnTick| Cancelando trades atrasados, com preco que ultrapassou o ponto de entrada! TradeID: "+MySet[x].TradeID+"/"+TimeToString(MySet[x].EntryStartTimer,TIME_MINUTES)+"/EntryPoint:"+(string)MySet[x].Timer_EntryPoint+" /Preco atual:"+(string)rates[0].close);
                          }
                        else if(((MySet[x].EntryPoint>=0 && rates[0].close>MySet[x].Timer_EntryPoint+(2*Slippage)) || 
                           (MySet[x].EntryPoint<0 && rates[0].close<MySet[x].Timer_EntryPoint-(2*Slippage)))
                           && (MySet[x].Trade_Status=="REQUESTED" || MySet[x].Trade_Status=="PLACED")) // Verifica se o preco ja ultrapassou o ponto de entrada. Neste caso, simplesmente descarta o trade, senao caso o EA inicie no meio do dia, teriamos varios trades startados erroneamente
                             {
                              bool OrderCanceled=Trade.OrderDelete(MySet[x].EntryOrder_OrderNumber);
                              if(OrderCanceled)
                                {
                                 Print("OnTick| Ordem Cancelada. Ticket: "+(string)MySet[x].EntryOrder_OrderNumber+" Status: "+(string)OrderCanceled+" TradeID:"+MySet[x].TradeID);
                                 CancelPreviousOrder=false;
                                 MySet[x].glBuyPlaced=false;
                                 MySet[x].glSellPlaced=false;
                                 MySet[x].glOrderPlaced=false;
                                 MySet[x].EntryOrder_Status="REMOVED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                }
                              else
                                {
                                 Print("OnTick| Problema com o cancelamento da ordem!. Order Number: "+(string)MySet[x].EntryOrder_OrderNumber);
                                }

                              MySet[x].Trade_Status="FINISHED"; // Ponto de entrada ja foi alcancado no passado. Evitar entrada atrasada
                              if(ExibirLogsDetalhados)
                                 Print("OnTick| Cancelando trades com ponto de entrada ja ultrapassado! TradeID: "+MySet[x].TradeID+"/ Order Number:"+(string)MySet[x].EntryOrder_OrderNumber+"/ EntryPoint:"+(string)MySet[x].EntryPoint+"/ CurrentPrice:"+(string)rates[0].close+"/ Timer_Entrypoint: "+(string)MySet[x].Timer_EntryPoint+"/ Direction:"+(string)MySet[x].TradeDirection);

                             }
                           else if(MySet[x].glOrderPlaced)
                             {
                              //Print( "OnTick| TradeID:",MySet[x].TradeID," |Ordem ja enviada. ",MySet[x].glOrderPlaced );
                             }

                        else
                          { // else related to [if ( RangeCurrent > MySet[x].Range_Min && MySet[x].Trade_Status == "WAITING" ) ]
                           //PlaySound("alert.wav"); // Play Sound as signal that range was stablished on level requested.

                           //Moment filters
                           //Filtros analisados no momento de entrada do trade

                           // CTO 
                           if(MySet[x].CTO=="" || (MySet[x].CTO=="+" && (MySet[x].Timer_RefPoint-DailyOpen)>=0) || (MySet[x].CTO=="-" && (MySet[x].Timer_RefPoint-DailyOpen)<0))
                             {
                              // CTC.1
                              if(MySet[x].CTC1=="" || (MySet[x].CTC1=="+" && (MySet[x].Timer_RefPoint-Y_Close)>=0) || (MySet[x].CTC1=="-" && (MySet[x].Timer_RefPoint-Y_Close)<0))
                                {

                                 // MID.1 [H+/M+/M-/L-]
                                 //if ( StringFind(MySet[x].MID1_Reference,MID1) > -1 )
                                 string MID1_TE;
                                 MID1_TE=fMID1((MySet[x].Timer_RefPoint),Y_High,Y_Low);
                                 if(StringFind(MySet[x].MID1_Reference,MID1_TE)>-1)
                                   {

                                    // DayPosition [ABOVE/BELOW/INSIDE/OUTSIDE]
                                    if(StringFind(MySet[x].DayPosition,Current_DayPosition)>-1)
                                      {
                                       // DailyBGSV
                                       if(MySet[x].DailyBGSV=="" || (MySet[x].DailyBGSV=="+" && (Daily[0].high-DailyOpen)>=(DailyOpen-Daily[0].low)) || (MySet[x].DailyBGSV=="-" && (Daily[0].high-DailyOpen)<(DailyOpen-Daily[0].low)))
                                         {
                                          // EntryPoint HIGH
                                          if(MySet[x].EntryPoint>=0)
                                            {
                                             // TradeDirection LONG
                                             if(MySet[x].TradeDirection=="LONG" && rates[0].close>=MySet[x].Timer_EntryPoint-Slippage && filtroMaOk)
                                               {
                                                MySet[x].TradeCounter+=1;

                                                Print("OnTick| TIMEENTRY. TradeID:",MySet[x].TradeID," Solicita entrada LONG!");
                                                Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition);

                                                //Informa que precisa enviar Ordem Pendente
                                                MySet[x].glPlaceOrder=true;
                                                MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                MySet[x].RangeLevel=MySet[x].Timer_EntryPoint; // Ponto de entrada
                                               }
                                             // TradeDirection SHORT
                                             else if(MySet[x].TradeDirection=="SHORT" && rates[0].close>=MySet[x].Timer_EntryPoint-MySet[x].EarlyOrder_Distance && filtroMaOk)
                                               {
                                                MySet[x].TradeCounter+=1;

                                                Print("OnTick| TIMEENTRY. TradeID:",MySet[x].TradeID," Solicita entrada SHORT!");
                                                Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition);

                                                //Informa que precisa enviar Ordem Pendente
                                                MySet[x].glPlaceOrder=true;
                                                MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                MySet[x].RangeLevel=MySet[x].Timer_EntryPoint; // Ponto de entrada
                                               } // TradeDirection SHORT
                                            } // EntryPoint HIGH
                                          else if(MySet[x].EntryPoint<0) // EntryPoint LOW
                                            {
                                             // TradeDirection LONG
                                             if(MySet[x].TradeDirection=="LONG" && rates[0].close<=MySet[x].Timer_EntryPoint+MySet[x].EarlyOrder_Distance && filtroMaOk)
                                               {
                                                MySet[x].TradeCounter+=1;

                                                Print("OnTick| TIMEENTRY. TradeID:",MySet[x].TradeID," Solicita entrada LONG!");
                                                Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition);

                                                //Informa que precisa enviar Ordem Pendente
                                                MySet[x].glPlaceOrder=true;
                                                MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                MySet[x].RangeLevel=MySet[x].Timer_EntryPoint; // Ponto de entrada
                                               }
                                             // TradeDirection SHORT
                                             else if(MySet[x].TradeDirection=="SHORT" && rates[0].close<=MySet[x].Timer_EntryPoint+Slippage && filtroMaOk)
                                               {
                                                MySet[x].TradeCounter+=1;

                                                Print("OnTick| TIMEENTRY. TradeID:",MySet[x].TradeID," Solicita entrada SHORT!");
                                                Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition);

                                                //Informa que precisa enviar Ordem Pendente
                                                MySet[x].glPlaceOrder=true;
                                                MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                MySet[x].RangeLevel=MySet[x].Timer_EntryPoint; // Ponto de entrada
                                               } // TradeDirection SHORT

                                            } // EntryPoint LOW

                                         } //DailyBGSV

                                      } // DayPosition

                                   } //MID.1
                                 else
                                   {
                                    MySet[x].Trade_Status="FINISHED";
                                    if(ExibirLogsDetalhados)
                                       Print("OnTick| TradeID:",MySet[x].TradeID," |Trade Finalizado por MID1. CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1_TE," Curr_DayPosition",Current_DayPosition);
                                   }

                                } //CTC.1
                              else
                                {
                                 MySet[x].Trade_Status="FINISHED";
                                 if(ExibirLogsDetalhados)
                                    Print("OnTick| TradeID:",MySet[x].TradeID," |Trade Finalizado por CTC1. CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition);
                                }

                             } //CTO
                           else
                             {
                              MySet[x].Trade_Status="FINISHED";
                              if(ExibirLogsDetalhados)
                                 Print("OnTick| TradeID:",MySet[x].TradeID," |Trade Finalizado por CTO. CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition);
                             }

                          }// LATE ENTRY
                       } // TradeType: TIMEENTRY ==== Check Entry signal and previous order request

                  //=============================================================================
                  // TradeType: RRETREAT  ==== RANGE_RETREAT Check Entry signal and previous order request
                  //=============================================================================
                  if(MySet[x].TradeType=="RRETREAT" && RangeCurrent>=MySet[x].Range_MinPoints && 
                     (( MySet[x].RangeHighLow=="HIGH" && MySet[x].TradeDirection=="LONG" && rates[0].close<=MySet[x].RRetreat_point+MySet[x].EarlyOrder_Distance) ||
                     ( MySet[x].RangeHighLow == "HIGH" && MySet[x].TradeDirection == "SHORT" && rates[0].close <= MySet[x].RRetreat_point + Slippage ) ||
                     ( MySet[x].RangeHighLow == "LOW"  && MySet[x].TradeDirection == "LONG"  && rates[0].close >= MySet[x].RRetreat_point - Slippage ) ||
                     ( MySet[x].RangeHighLow == "LOW"  && MySet[x].TradeDirection == "SHORT" && rates[0].close >= MySet[x].RRetreat_point - MySet[x].EarlyOrder_Distance ) ) &&
                     !MySet[x].glOrderexecuted && MySet[x].Trade_Status!="FINISHED" && MySet[x].EntryOrder_Status!="REJECTED")
                    {

                     // TimeStructure
                     MqlDateTime strRangeLevel_AtTime,strTimeCurrent;
                     double RangeAtTime_inMINUTES,TimeCurrent_inMINUTES;
                     TimeToStruct(MySet[x].RangeLevel_AtTime,strRangeLevel_AtTime);
                     TimeToStruct(TimeCurrent(),strTimeCurrent);
                     RangeAtTime_inMINUTES = strRangeLevel_AtTime.hour*60+strRangeLevel_AtTime.min;
                     TimeCurrent_inMINUTES = strTimeCurrent.hour*60+strTimeCurrent.min;

                     // Verifica se ponto de retracao atingido antes do horario de trade
                     if(MySet[x].RRetreat_Hitted==true && MySet[x].RRetreat_Hit_AtTime>0 && MySet[x].RRetreat_Hit_AtTime<MySet[x].EntryStartTimer && RangeCurrent<MySet[x].Range_MaxPoints) //&& RangeCurrent > MySet[x].Range_Min )
                       {
                        MySet[x].Trade_Status="FINISHED"; // Ponto e entrada ja foi alcancado no passado. Evitar entrada atrasada
                        Print("OnTick| TradeID:",MySet[x].TradeID," | Horarios do filtro: RRetreat_Hit_AtTime=",TimeToString(MySet[x].RRetreat_Hit_AtTime,TIME_DATE|TIME_MINUTES)," |MySet[x].EntryStartTimer=",TimeToString(MySet[x].EntryStartTimer,TIME_DATE|TIME_MINUTES) );
                        Print("OnTick| TradeID:",MySet[x].TradeID," | Cancelando trade porque ponto de entrada foi atingido antes da janela de horario de entrada permitido para o trade. Trade[ Faixa de range: Min "+(string)MySet[x].Range_MinPoints+"/Max "+(string)MySet[x].Range_MaxPoints+"/"+(string)MySet[x].RangeHighLow+"/"+(string)MySet[x].TradeDirection+"| Range atual: "+(string)RangeCurrent );
                       }
                     // Verifica se range atual esta acima da range de trade. Neste caso, simplesmente descarta o trade, 
                     // senao, caso o EA inicie no meio do dia, teremos varios trades startados erroneamente.
                     else if(RangeCurrent>MySet[x].Range_MaxPoints && MySet[x].Trade_Status=="WAITING") // Verifica se range atual esta acima da faixa de range de trade. Neste caso, simplesmente descarta o trade, senao caso o EA inicie no meio do dia, teriamos varios trades startados erroneamente
                       {
                        MySet[x].Trade_Status="FINISHED"; // Ponto e entrada ja foi alcancado no passado. Evitar entrada atrasada
                        Print("OnTick| TradeID:",MySet[x].TradeID," | Cancelando trade com ponto de entrada inferior a range atual! Trade[ Faixa de range: Min "+(string)MySet[x].Range_MinPoints+"/Max "+(string)MySet[x].Range_MaxPoints+"/"+(string)MySet[x].RangeHighLow+"/"+(string)MySet[x].TradeDirection+"| Range atual: "+(string)RangeCurrent);
                       }
                     else if(RangeCurrent>MySet[x].Range_MaxPoints && (MySet[x].Trade_Status=="REQUESTED" || MySet[x].Trade_Status=="PLACED")) // Verifica se range atual esta acima da range de trade. Neste caso, simplesmente descarta o trade, senao caso o EA inicie no meio do dia, teriamos varios trades startados erroneamente
                       {
                        bool OrderCanceled=Trade.OrderDelete(MySet[x].EntryOrder_OrderNumber);
                        if(OrderCanceled)
                          {
                           Print("OnTick| TradeID:",MySet[x].TradeID," | Ordem Cancelada, Condicoes de trade perdidas. Ticket: "+(string)MySet[x].EntryOrder_OrderNumber+" Status: "+(string)OrderCanceled);
                           CancelPreviousOrder=false;
                           MySet[x].glBuyPlaced=false;
                           MySet[x].glSellPlaced=false;
                           MySet[x].glOrderPlaced=false;
                           MySet[x].EntryOrder_Status="REMOVED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                          }
                        else
                          {
                           Print("OnTick| TradeID:",MySet[x].TradeID," | Problema com o cancelamento da ordem!. Order Number: "+(string)MySet[x].EntryOrder_OrderNumber);
                          }
                        MySet[x].Trade_Status="FINISHED"; // Ponto e entrada ja foi alcancado no passado. Evitar entrada atrasada
                        Print("OnTick| TradeID:",MySet[x].TradeID," | Cancelando trades com ponto de entrada inferior a range atual! Trade: "+(string)MySet[x].Range_MinPoints+"/"+(string)MySet[x].RangeHighLow+"/"+(string)MySet[x].TradeDirection+"| Range atual: "+(string)RangeCurrent);

                       }
                     // Verifica se a retracao ocorreu antes do horario de entrada no trade e finaliza o trade
                     else if((TimeCurrent_inMINUTES-RangeAtTime_inMINUTES)>MySet[x].RRetreat_Max_Timer)
                       {
                        Print("OnTick| TradeID:",MySet[x].TradeID," | Hora da ultima Range: ",RangeAtTime_inMINUTES," |Hora atual: ",TimeCurrent_inMINUTES);

                        //Verifica se tem ordem pendente, se tiver, cancela
                        if(MySet[x].Trade_Status=="REQUESTED" || MySet[x].Trade_Status=="PLACED")
                          {
                           bool OrderCanceled=Trade.OrderDelete(MySet[x].EntryOrder_OrderNumber);
                           if(OrderCanceled)
                             {
                              Print("OnTick| TradeID:",MySet[x].TradeID," | Ordem Cancelada, Condicoes de trade perdidas. Ticket: "+(string)MySet[x].EntryOrder_OrderNumber+" Status: "+(string)OrderCanceled);
                              CancelPreviousOrder=false;
                              MySet[x].glBuyPlaced=false;
                              MySet[x].glSellPlaced=false;
                              MySet[x].glOrderPlaced=false;
                              MySet[x].EntryOrder_Status="REMOVED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                             }
                           else
                             {
                              Print("OnTick| TradeID:",MySet[x].TradeID," | Problema com o cancelamento da ordem!. Order Number: "+(string)MySet[x].EntryOrder_OrderNumber);
                             }
                          }
                        else if(MySet[x].Trade_Status=="WAITING")
                          {
                           Print("OnTick| TradeID:",MySet[x].TradeID," | Tempo esgotado, ja se passaram ",MySet[x].RRetreat_Max_Timer," minutos desde a formacao da ultima range. Range atual: ",RangeCurrent);
                          }

                        //Encerra o trade
                        MySet[x].Trade_Status="FINISHED";
                        Print("OnTick| TradeID:",MySet[x].TradeID," | Cancelando trades que ultrapassarm o tempo maximo de retracao apos a range. Trade Range(Min/Max/HighLow/Direction/CurrentRange): ",MySet[x].Range_MinPoints,"/",MySet[x].Range_MaxPoints,"/",MySet[x].RangeHighLow,"/",MySet[x].TradeDirection+"| Range atual: "+(string)RangeCurrent);
                       }
                     // Verifica se nova range foi feita e calcula os valores de retracao, target e stop
                     else if(RangeCurrent>MySet[x].LastRange && (MySet[x].Trade_Status=="WAITING" || MySet[x].Trade_Status=="REQUESTED" || MySet[x].Trade_Status=="PLACED"))
                       {
                        if(MySet[x].Trade_Status=="WAITING")
                          {
                           // Alguma action?

                          } // if( MySet[x].Trade_Status == "WAITING" )
                        else if(MySet[x].Trade_Status=="REQUESTED" || MySet[x].Trade_Status=="PLACED")
                          {
                           // Alguma action?

                           // Solicita cancelamento da ordem enviada anteriormente.
                           CancelPreviousOrder=true;
                           //Solicita o envio da ordem
                           //MySet[x].glPlaceOrder = true;



                          } // else if ( MySet[x].Trade_Status == "REQUESTED" || MySet[x].Trade_Status == "PLACED" )
                        else
                          {
                           Print("OnTick| TradeID:",MySet[x].TradeID," |Revisar status do trade enquanto a range se expande");
                          }

                        //Print("OnTick| TradeID:",MySet[x].TradeID," | Recalcular e Reposicionar o ponto de entrada RRETREAT." );

                       }
                     else if(MySet[x].RRetreat_point>0 && RangeCurrent==MySet[x].LastRange && (MySet[x].Trade_Status=="WAITING" || MySet[x].Trade_Status=="REQUESTED" || MySet[x].Trade_Status=="PLACED"))
                       {
                        //PlaySound("alert.wav"); // Play Sound as signal that range was stablished on level requested.

                        //Print("Daily extremes: high "+ (string)Daily[0].high  +" -LastHigh "+ (string)MySet[x].LastDailyHigh  +" - low "+ (string)Daily[0].low +" - LastLow "+ (string)MySet[x].LastDailyLow );

                        //Identifica se a range esta sendo formada por uma nova máxima(high) ou por uma nova mínima(low)
                        if(RangeHighOrLow=="HIGH")
                          {
                           //Moment filters
                           //Filtros analisados no momento de entrada do trade

                           // CTO 
                           if(MySet[x].CTO=="" || (MySet[x].CTO=="+" && MySet[x].RRetreat_point-DailyOpen>=0) || (MySet[x].CTO=="-" && MySet[x].RRetreat_point-DailyOpen<0))
                             {
                              // CTC.1
                              if(MySet[x].CTC1=="" || (MySet[x].CTC1=="+" && MySet[x].RRetreat_point-Y_Close>=0) || (MySet[x].CTC1=="-" && MySet[x].RRetreat_point-Y_Close<0))
                                {
                                 // MID.1 [H+/M+/M-/L-]
                                 //if ( StringFind(MySet[x].MID1_Reference,MID1) > -1 )
                                 if((StringFind(MySet[x].MID1_Reference,fMID1(MySet[x].RRetreat_point,Y_High,Y_Low)))>-1)
                                   {
                                    // DayPosition [ABOVE/BELOW/INSIDE/OUTSIDE]
                                    if(StringFind(MySet[x].DayPosition,Current_DayPosition)>-1)
                                      {
                                       // DailyBGSV
                                       if(MySet[x].DailyBGSV=="" || (MySet[x].DailyBGSV=="+" && (Daily[0].high-DailyOpen)>=(DailyOpen-Daily[0].low)) || (MySet[x].DailyBGSV=="-" && (Daily[0].high-DailyOpen)<(DailyOpen-Daily[0].low)))
                                         {
                                          // Verifica se o trade esperado eh Compra (LONG) apos range estabelecido por uma nova alta (HIGH)
                                          if(MySet[x].RangeHighLow=="HIGH" && MySet[x].TradeDirection=="LONG")
                                            {
                                             if(MySet[x].NewRangeHighLow!="HIGH")
                                               {
                                                // Verifica se ja existe ordem pendente, no outro extremo da range
                                                if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                                //Informa que precisa enviar Ordem Pendente
                                                MySet[x].glPlaceOrder=true;
                                                MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                                MySet[x].RangeLevel=RangeCurrent; //Identifica o ponto onde a Range foi identificada

                                                Print("OnTick| TradeID:",MySet[x].TradeID," |Expected range HIGH on:"+(string)MySet[x].RangeLevel+" .Extremos do dia, neste momento. Daily High: "+(string)Daily[0].high+" Daily Low: "+(string)Daily[0].low+" Lastvalues: High["+(string)MySet[x].LastDailyHigh+"] Low["+(string)MySet[x].LastDailyLow+"]  HIGH/LONG" );
                                                Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );
                                               }
                                             //Atualiza valor da variavel RangeHighLow
                                             MySet[x].NewRangeHighLow="HIGH";

                                            } //if ( MySet[x].RangeHighLow == "HIGH" && MySet[x].TradeDirection == "LONG"  
                                          else if(MySet[x].RangeHighLow=="HIGH" && MySet[x].TradeDirection=="SHORT") // Verifica se o trade esperado eh Compra (LONG) apos range estabelecido por uma nova alta (HIGH)
                                            {
                                             if(rates[0].close<=(MySet[x].RRetreat_point+Slippage))
                                               {
                                                if(MySet[x].NewRangeHighLow!="HIGH")
                                                  {
                                                   // Verifica se ja existe ordem pendente, no outro extremo da range
                                                   if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                                   //Informa que precisa enviar Ordem Pendente
                                                   MySet[x].glPlaceOrder=true;
                                                   MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                                   MySet[x].RangeLevel=Daily[0].low+MySet[x].Range_MinPoints;  //Identifica o ponto onde a Range foi identificada

                                                   Print("OnTick| TradeID:",MySet[x].TradeID," |Expected range HIGH on:"+(string)MySet[x].RangeLevel+" Extremos do dia, neste momento. Daily High: "+(string)Daily[0].high+" Daily Low: "+(string)Daily[0].low+" Lastvalues: High["+(string)MySet[x].LastDailyHigh+"] Low["+(string)MySet[x].LastDailyLow+"]  HIGH/SHORT" );
                                                   Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );
                                                  }
                                                //Atualiza valor da variavel RangeHighLow
                                                MySet[x].NewRangeHighLow="HIGH";
                                               } //if ( rates[0].close <= ( MySet[x].RRetreat_point - Slippage ) )
                                            } // Close else. "// Verifica se o trade esperado eh Venda (SHORT) apos range estabelecido por uma nova alta (HIGH)"
                                         } //DailyBGSV
                                      } // DayPosition
                                   } // MID.1
                                } //CTC.1
                             } //CTO

                          } //Identifica se a range esta sendo formada por uma nova máxima(high)-->then; Ou por uma nova mínima(low)-->else
                        else if(RangeHighOrLow=="LOW")
                          {

                           //Moment filters
                           //Filtros analisados no momento de entrada do trade

                           // CTO 
                           if(MySet[x].CTO=="" || (MySet[x].CTO=="+" && MySet[x].RRetreat_point-DailyOpen>=0) || (MySet[x].CTO=="-" && MySet[x].RRetreat_point-DailyOpen<0))
                             {
                              // CTC.1
                              if(MySet[x].CTC1=="" || (MySet[x].CTC1=="+" && MySet[x].RRetreat_point-Y_Close>=0) || (MySet[x].CTC1=="-" && MySet[x].RRetreat_point-Y_Close<0))
                                {
                                 // MID.1 [H+/M+/M-/L-]
                                 //if ( StringFind(MySet[x].MID1_Reference,MID1) > -1 )
                                 if((StringFind(MySet[x].MID1_Reference,fMID1(MySet[x].RRetreat_point,Y_High,Y_Low)))>-1)
                                   {
                                    // DayPosition [ABOVE/BELOW/INSIDE/OUTSIDE]
                                    if(StringFind(MySet[x].DayPosition,Current_DayPosition)>-1)
                                      {
                                       // DailyBGSV
                                       if(MySet[x].DailyBGSV=="" || (MySet[x].DailyBGSV=="+" && (Daily[0].high-DailyOpen)>=(DailyOpen-Daily[0].low)) || (MySet[x].DailyBGSV=="-" && (Daily[0].high-DailyOpen)<(DailyOpen-Daily[0].low)))
                                         {
                                          if(MySet[x].RangeHighLow=="LOW" && MySet[x].TradeDirection=="SHORT")
                                            {
                                             if(MySet[x].NewRangeHighLow!="LOW")
                                               {
                                                // Verifica se ja existe ordem pendente, no outro extremo da range
                                                if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                                //Informa que precisa enviar Ordem Pendente 
                                                MySet[x].glPlaceOrder=true;
                                                MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                                MySet[x].RangeLevel=RangeCurrent;  //Identifica o ponto onde a Range foi identificada

                                                Print("OnTick| TradeID:",MySet[x].TradeID," |Expected range LOW on:"+(string)MySet[x].RangeLevel+" Extremos do dia, neste momento. Daily High: "+(string)Daily[0].high+" Daily Low: "+(string)Daily[0].low+" Lastvalues: High["+(string)MySet[x].LastDailyHigh+"] Low["+(string)MySet[x].LastDailyLow+"]  LOW/SHORT" );
                                                Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );
                                               } //if ( MySet[x].NewRangeHighLow != "LOW" )
                                             //Atualiza valor da variavel RangeHighLow
                                             MySet[x].NewRangeHighLow="LOW";
                                            } //if ( MySet[x].RangeHighLow == "LOW" && MySet[x].TradeDirection == "SHORT"  )
                                          else if(MySet[x].RangeHighLow=="LOW" && MySet[x].TradeDirection=="LONG")
                                            {
                                             if(rates[0].close>=(MySet[x].RRetreat_point-Slippage))
                                               {
                                                if(MySet[x].NewRangeHighLow!="LOW")
                                                  {
                                                   // Verifica se ja existe ordem pendente, no outro extremo da range
                                                   if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                                   //Informa que precisa enviar Ordem Pendente 
                                                   MySet[x].glPlaceOrder=true;
                                                   MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                                   MySet[x].RangeLevel=RangeCurrent;  //Identifica o ponto onde a Range foi identificada

                                                   Print("OnTick| TradeID:",MySet[x].TradeID," |Expected range LOW on:"+(string)MySet[x].RangeLevel+" Extremos do dia, neste momento. Daily High: "+(string)Daily[0].high+" Daily Low: "+(string)Daily[0].low+" Lastvalues: High["+(string)MySet[x].LastDailyHigh+"] Low["+(string)MySet[x].LastDailyLow+"] LOW/LONG" );
                                                   Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );
                                                  }   // if ( MySet[x].NewRangeHighLow != "LOW" )
                                                //Atualiza valor da variavel RangeHighLow
                                                MySet[x].NewRangeHighLow="LOW";

                                               } //if ( rates[0].close >= ( MySet[x].RRetreat_point - Slippage ) )
                                            }  //if ( MySet[x].RangeHighLow == "LOW" && MySet[x].TradeDirection == "LONG"  )                                  
                                         } //DailyBGSV
                                      } // DayPosition
                                   } // MID.1
                                } //CTC.1
                             } //CTO

                           //Show Line with Range on Current Chart
                           if(ObjectCreate(0,"HLINE_Range",OBJ_HLINE,0,0,50000))
                             {
                              MySet[x].RangeLineObj=true;
                              //--- set line color
                              ObjectSetInteger(0,"HLINE_Range",OBJPROP_COLOR,clrGold);
                             }
                           if(MySet[x].RangeLineObj) ObjectMove(0,"HLINE_Range",0,0,MySet[x].RangeLevel);

                          } //Range high or low
                       } // else related to [if ( RangeCurrent > MySet[x].Range && MySet[x].Trade_Status == "WAITING" ) ]

                    } // TradeType RRETREAT. Check Entry signal and previous order request

                  //=============================================================================
                  // TradeType: ROUNDN ==== Check Entry signal and previous order request
                  //=============================================================================
                  else if(MySet[x].TradeType=="ROUNDN" && MySet[x].Trade_Status!="FINISHED" && MySet[x].Trade_Status!="STARTED" && MySet[x].EntryOrder_Status!="REJECTED")
                    {
                     // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                     // Ordem de Entrada - STATUS (REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED)
                     // Print("Estou aqui");

                     //Print( "Checking formula: close: ",rates[0].close,"| Substring: ",StringSubstr( (string)rates[0].close,0,2),"| formula: ",StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500") );

                     //Check last position status
                     if(MySet[x].EntryOrder_Status=="" && (MySet[x].glBuyPlaced==true || MySet[x].glSellPlaced==true) && (MySet[x].EntryOrder_type!="DEAL_TYPE_BUY" || MySet[x].EntryOrder_type!="DEAL_TYPE_SELL"))
                       {
                        Print("OnTick| TradeID:",MySet[x].TradeID," |ROUNDN: Posicao encerrada. Reiniciando as flags.");
                        MySet[x].glBuyPlaced=false;
                        MySet[x].glSellPlaced=false;
                        //glOrderPlacedWaitingReturn = false; MySet[x].EntryOrder_Status == "PLACED"
                        //Position_lastchecked_status = MySet[x].EntryOrder_Status;
                       }

                     // 500 EM 500
                     if(roundAbove==0 && roundBelow==0)
                       {
                        if(rates[0].close<StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500"))
                          {
                           roundAbove = StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500");
                           roundBelow = StringToDouble(StringSubstr((string)rates[0].close,0,2)+"000");
                           //Print("OnTick| Abaixo de 500. Ponto atual: "+(string)rates[0].close+"/ roundAbove: "+(string)roundAbove+"/ roundBelow: "+(string)roundBelow );
                          }
                        else if(rates[0].close>StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500"))
                          {
                           roundAbove = StringToDouble(StringSubstr(((string)(rates[0].close+1000)),0,2)+"000");
                           roundBelow = StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500");
                           //Print("OnTick| Acima de 500. Ponto atual: "+(string)rates[0].close+"/ roundAbove: "+(string)roundAbove+"/ roundBelow: "+(string)roundBelow );
                          }

                        Print("OnTick| TradeID:",MySet[x].TradeID," |First Check. Ponto atual: "+(string)rates[0].close+"/ roundAbove: "+(string)roundAbove+"/ roundBelow: "+(string)roundBelow," |MySet[x].EntryOrder_Status:",MySet[x].EntryOrder_Status," |MySet[x].EntryRef_Open_Top ",MySet[x].EntryRef_Open_Top);
                       }
                     else
                       {
                        if(rates[0].close<=(roundBelow-MySet[x].EntryPoint))
                          {
                           if(rates[0].close<StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500"))
                             {
                              roundAbove = StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500");
                              roundBelow = StringToDouble(StringSubstr((string)rates[0].close,0,2)+"000");
                              //Print("OnTick| Abaixo de 500. Ponto atual: "+(string)rates[0].close+"/ roundAbove: "+(string)roundAbove+"/ roundBelow: "+(string)roundBelow );
                             }
                           else if(rates[0].close>StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500"))
                             {
                              roundAbove = StringToDouble(StringSubstr(((string)(rates[0].close+1000)),0,2)+"000");
                              roundBelow = StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500");
                              //Print("OnTick| Acima de 500. Ponto atual: "+(string)rates[0].close+"/ roundAbove: "+(string)roundAbove+"/ roundBelow: "+(string)roundBelow );
                             }
                          }
                        else if(rates[0].close>=(roundAbove+MySet[x].EntryPoint))
                          {
                           if(rates[0].close<StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500"))
                             {
                              roundAbove = StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500");
                              roundBelow = StringToDouble(StringSubstr((string)rates[0].close,0,2)+"000");
                              //Print("OnTick| Abaixo de 500. Ponto atual: "+(string)rates[0].close+"/ roundAbove: "+(string)roundAbove+"/ roundBelow: "+(string)roundBelow );
                             }
                           else if(rates[0].close>StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500"))
                             {
                              roundAbove = StringToDouble(StringSubstr(((string)(rates[0].close+1000)),0,2)+"000");
                              roundBelow = StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500");
                              //Print("OnTick| Acima de 500. Ponto atual: "+(string)rates[0].close+"/ roundAbove: "+(string)roundAbove+"/ roundBelow: "+(string)roundBelow );
                             }
                          }

                        if(roundAbove!=Prev_roundAbove)
                          {
                           if(MySet[x].EntryRef_Open_Bottom==1) // MySet[x].EntryRef_Open_Bottom == 1 (Todos os retornos) ou 0 (Somente primeira entrada)
                             {
                              if(roundAbove==DailyLastAbove)
                                {
                                 DailyLastAbove = 0;
                                 DailyLastBelow = 0;
                                }
                              Print("OnTick| TradeID: ",MySet[x].TradeID," Restart Last Above & Below.");
                             }

                           Print("OnTick| TradeID:",MySet[x].TradeID," |Ponto atual: "+(string)rates[0].close+"/ roundAbove: "+(string)roundAbove+"/ roundBelow: "+(string)roundBelow," |MySet[x].EntryOrder_Status:",MySet[x].EntryOrder_Status," |MySet[x].EntryRef_Open_Top ",MySet[x].EntryRef_Open_Top," |DailyLastAbove: ",DailyLastAbove," |DailyLastBelow: ",DailyLastBelow);
                          }

                        // Atualiza valor do Previous roundAbove
                        Prev_roundAbove=roundAbove;

                       } // 500 EM 500

                     //                  // 1000 EM 1000
                     //                  if ( roundAbove == 0 && roundBelow == 0 )
                     //                  {
                     //                     if (rates[0].close < StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500") )
                     //                     {
                     //                        roundAbove = StringToDouble(StringSubstr(((string)(rates[0].close+1000)),0,2)+"000");
                     //                        roundBelow = StringToDouble(StringSubstr((string)rates[0].close,0,2)+"000");
                     //                        //Print("OnTick| Abaixo de 500. Ponto atual: "+(string)rates[0].close+"/ roundAbove: "+(string)roundAbove+"/ roundBelow: "+(string)roundBelow );
                     //                     }
                     //                     else if (rates[0].close > StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500") )
                     //                     {
                     //                        roundAbove = StringToDouble(StringSubstr(((string)(rates[0].close+1000)),0,2)+"000");
                     //                        roundBelow = StringToDouble(StringSubstr((string)rates[0].close,0,2)+"000");
                     //                        //Print("OnTick| Acima de 500. Ponto atual: "+(string)rates[0].close+"/ roundAbove: "+(string)roundAbove+"/ roundBelow: "+(string)roundBelow );
                     //                     }
                     //                     
                     //                     Print("OnTick| TradeID:",MySet[x].TradeID," |First Check. Ponto atual: "+(string)rates[0].close+"/ roundAbove: "+(string)roundAbove+"/ roundBelow: "+(string)roundBelow," |MySet[x].EntryOrder_Status:",MySet[x].EntryOrder_Status," |MySet[x].EntryRef_Open_Top ",MySet[x].EntryRef_Open_Top );
                     //                  }
                     //                  else
                     //                  {
                     //                     if (rates[0].close <= (roundBelow-MySet[x].EntryPoint)  )
                     //                     {
                     //                        if (rates[0].close < StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500") )
                     //                        {
                     //                           roundAbove = StringToDouble(StringSubstr(((string)(rates[0].close+1000)),0,2)+"000");
                     //                           roundBelow = StringToDouble(StringSubstr((string)rates[0].close,0,2)+"000");
                     //                           //Print("OnTick| Abaixo de 500. Ponto atual: "+(string)rates[0].close+"/ roundAbove: "+(string)roundAbove+"/ roundBelow: "+(string)roundBelow );
                     //                        }
                     //                        else if (rates[0].close > StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500") )
                     //                        {
                     //                           roundAbove = StringToDouble(StringSubstr(((string)(rates[0].close+1000)),0,2)+"000");
                     //                           roundBelow = StringToDouble(StringSubstr((string)rates[0].close,0,2)+"000");
                     //                           //Print("OnTick| Acima de 500. Ponto atual: "+(string)rates[0].close+"/ roundAbove: "+(string)roundAbove+"/ roundBelow: "+(string)roundBelow );
                     //                        }
                     //                     }
                     //                     else if (rates[0].close >= (roundAbove+MySet[x].EntryPoint) )
                     //                     {
                     //                        if (rates[0].close < StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500") )
                     //                        {
                     //                           roundAbove = StringToDouble(StringSubstr(((string)(rates[0].close+1000)),0,2)+"000");
                     //                           roundBelow = StringToDouble(StringSubstr((string)rates[0].close,0,2)+"000");
                     //                           //Print("OnTick| Abaixo de 500. Ponto atual: "+(string)rates[0].close+"/ roundAbove: "+(string)roundAbove+"/ roundBelow: "+(string)roundBelow );
                     //                        }
                     //                        else if (rates[0].close > StringToDouble(StringSubstr((string)rates[0].close,0,2)+"500") )
                     //                        {
                     //                           roundAbove = StringToDouble(StringSubstr(((string)(rates[0].close+1000)),0,2)+"000");
                     //                           roundBelow = StringToDouble(StringSubstr((string)rates[0].close,0,2)+"000");
                     //                           //Print("OnTick| Acima de 500. Ponto atual: "+(string)rates[0].close+"/ roundAbove: "+(string)roundAbove+"/ roundBelow: "+(string)roundBelow );
                     //                        }
                     //                     }
                     //                     
                     //                     if ( roundAbove != Prev_roundAbove )
                     //                     {
                     //                        if ( MySet[x].EntryRef_Open_Bottom == 1 ) // MySet[x].EntryRef_Open_Bottom == 1 (Todos os retornos) ou 0 (Somente primeira entrada)
                     //                        {
                     //                           if( roundAbove == DailyLastAbove )
                     //                           {
                     //                              DailyLastAbove = 0;
                     //                              DailyLastBelow = 0;                        
                     //                           }
                     //                           Print("OnTick| TradeID: ",MySet[x].TradeID," Restart Last Above & Below.");
                     //                        }
                     //                        
                     //                        Print("OnTick| TradeID:",MySet[x].TradeID," |Ponto atual: "+(string)rates[0].close+"/ roundAbove: "+(string)roundAbove+"/ roundBelow: "+(string)roundBelow," |MySet[x].EntryOrder_Status:",MySet[x].EntryOrder_Status," |MySet[x].EntryRef_Open_Top ",MySet[x].EntryRef_Open_Top," |DailyLastAbove: ",DailyLastAbove," |DailyLastBelow: ",DailyLastBelow );
                     //                     }
                     //                     
                     //                     // Atualiza valor do Previous roundAbove
                     //                     Prev_roundAbove = roundAbove;
                     //                     
                     //                  } // 1000 EM 1000



                     if(MySet[x].EntryOrder_Status=="")
                       { // else related to [if ( RangeCurrent > MySet[x].Range && MySet[x].Trade_Status == "WAITING" ) ]
                        //PlaySound("alert.wav"); // Play Sound as signal that range was stablished on level requested.

                        //Print( "Daily extremes: high "+ (string)Daily[0].high  +" -LastHigh "+ (string)MySet[x].LastDailyHigh  +" - low "+ (string)Daily[0].low +" - LastLow "+ (string)MySet[x].LastDailyLow );

                        //Identifica se alcancou o round number superior
                        if(rates[0].close>=roundAbove-MySet[x].EarlyOrder_Distance && MySet[x].EntryRef_Open_Top==1 && roundAbove!=DailyLastAbove) // MySet[x].EntryRef_Open_Top == 1 (Above) ou 0 (Below)
                          {

                           //Moment filters
                           //Filtros analisados no momento de entrada do trade

                           // CTO 
                           if(MySet[x].CTO=="" || (MySet[x].CTO=="+" && (roundAbove-MySet[x].EarlyOrder_Distance)-DailyOpen>=0) || (MySet[x].CTO=="-" && (roundAbove-MySet[x].EarlyOrder_Distance)-DailyOpen<0))
                             {

                              // CTC.1
                              if(MySet[x].CTC1=="" || (MySet[x].CTC1=="+" && (roundAbove-MySet[x].EarlyOrder_Distance)-Y_Close>=0) || (MySet[x].CTC1=="-" && (roundAbove-MySet[x].EarlyOrder_Distance)-Y_Close<0))
                                {

                                 // MID.1 [H+/M+/M-/L-]
                                 //if ( StringFind(MySet[x].MID1_Reference,MID1) > -1 )
                                 if((StringFind(MySet[x].MID1_Reference,fMID1((roundAbove-MySet[x].EarlyOrder_Distance),Y_High,Y_Low)))>-1)
                                   {

                                    // DayPosition [ABOVE/BELOW/INSIDE/OUTSIDE]
                                    if(StringFind(MySet[x].DayPosition,Current_DayPosition)>-1)
                                      {

                                       // DailyBGSV
                                       if(MySet[x].DailyBGSV=="" || (MySet[x].DailyBGSV=="+" && (Daily[0].high-DailyOpen)>=(DailyOpen-Daily[0].low)) || (MySet[x].DailyBGSV=="-" && (Daily[0].high-DailyOpen)<(DailyOpen-Daily[0].low)))
                                         {

                                          // Verifica se o trade esperado eh Venda (SHORT)
                                          if(MySet[x].TradeDirection=="SHORT") // Vender sempre que alcancar o round above
                                            {

                                             // Verifica se ja existe ordem pendente, no outro extremo da range
                                             if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                             //Informa que precisa enviar Ordem Pendente
                                             MySet[x].glPlaceOrder=true;
                                             MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                             MySet[x].RangeLevel=(roundAbove-MySet[x].EarlyOrder_Distance);  //Identifica o ponto de entrada

                                             Print("OnTick| TradeID:",MySet[x].TradeID," SHORT |Round Above:",(string)MySet[x].RangeLevel," |DailyLastAbove:", DailyLastAbove," |EarlyDistance:",MySet[x].EarlyOrder_Distance," |EntryPoint:",MySet[x].EntryPoint );
                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );

                                             // Atualiza valor do ultimo round que deu entrada
                                             DailyLastAbove=roundAbove;

                                            } //if ( MySet[x].RangeHighLow == "HIGH" && MySet[x].TradeDirection == "SHORT"  
                                          else if(MySet[x].TradeDirection=="LONG") // Verifica se o trade esperado eh Compra (LONG)
                                            {
                                             // Verifica se ja existe ordem pendente, no outro extremo da range
                                             if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                             //Informa que precisa enviar Ordem Pendente
                                             MySet[x].glPlaceOrder=true;
                                             MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                             MySet[x].RangeLevel=(roundAbove-MySet[x].EarlyOrder_Distance);  //Identifica o ponto onde a Range foi identificada

                                             Print("OnTick| TradeID:",MySet[x].TradeID," LONG |Round Above:",(string)MySet[x].RangeLevel," |DailyLastAbove:", DailyLastAbove," |EarlyDistance:",MySet[x].EarlyOrder_Distance," |EntryPoint:",MySet[x].EntryPoint );
                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );

                                             // Atualiza valor do ultimo round que deu entrada
                                             DailyLastAbove=roundAbove;

                                            } // Close else. "// Verifica se o trade esperado eh Venda (SHORT)

                                         } //DailyBGSV

                                      } // DayPosition

                                   } // MID.1

                                } //CTC.1

                             } //CTO

                          } // END roundAbove
                        else if((rates[0].close<=(roundBelow+MySet[x].EarlyOrder_Distance)) && (MySet[x].EntryRef_Open_Top==0) && roundBelow!=DailyLastBelow) // MySet[x].EntryRef_Open_Top == 1 (Above) ou 0 (Below) )
                          {

                           //Print("OnTick| TradeID:",MySet[x].TradeID," PREVIOUS |Round Below:",roundBelow," ",MySet[x].RangeLevel," |DailyLastBelow:", DailyLastBelow," |EarlyDistance:",MySet[x].EarlyOrder_Distance," |EntryPoint:",MySet[x].EntryPoint );

                           //Moment filters
                           //Filtros analisados no momento de entrada do trade

                           // CTO 
                           if(MySet[x].CTO=="" || (MySet[x].CTO=="+" && (roundBelow+MySet[x].EarlyOrder_Distance)-DailyOpen>=0) || (MySet[x].CTO=="-" && (roundBelow+MySet[x].EarlyOrder_Distance)-DailyOpen<0))
                             {

                              // CTC.1
                              if(MySet[x].CTC1=="" || (MySet[x].CTC1=="+" && (roundBelow+MySet[x].EarlyOrder_Distance)-Y_Close>=0) || (MySet[x].CTC1=="-" && (roundBelow+MySet[x].EarlyOrder_Distance)-Y_Close<0))
                                {

                                 // MID.1 [H+/M+/M-/L-]
                                 //if ( StringFind(MySet[x].MID1_Reference,MID1) > -1 )
                                 if((StringFind(MySet[x].MID1_Reference,fMID1((roundBelow+MySet[x].EarlyOrder_Distance),Y_High,Y_Low)))>-1)
                                   {

                                    // DayPosition [ABOVE/BELOW/INSIDE/OUTSIDE]
                                    if(StringFind(MySet[x].DayPosition,Current_DayPosition)>-1)
                                      {

                                       // DailyBGSV
                                       if(MySet[x].DailyBGSV=="" || (MySet[x].DailyBGSV=="+" && (Daily[0].high-DailyOpen)>=(DailyOpen-Daily[0].low)) || (MySet[x].DailyBGSV=="-" && (Daily[0].high-DailyOpen)<(DailyOpen-Daily[0].low)))
                                         {

                                          // Verifica se o trade esperado eh Venda (SHORT)
                                          if(MySet[x].TradeDirection=="LONG") // Vender sempre que alcancar o round above
                                            {

                                             // Verifica se ja existe ordem pendente, no outro extremo da range
                                             if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                             //Informa que precisa enviar Ordem Pendente
                                             MySet[x].glPlaceOrder=true;
                                             MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                             MySet[x].RangeLevel=(roundBelow+MySet[x].EarlyOrder_Distance);  //Identifica o ponto de entrada

                                             Print("OnTick| TradeID:",MySet[x].TradeID," LONG |Round Below:",(string)MySet[x].RangeLevel," |DailyLastBelow:", DailyLastBelow," |EarlyDistance:",MySet[x].EarlyOrder_Distance," |EntryPoint:",MySet[x].EntryPoint );
                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );

                                             // Atualiza valor do ultimo round Below que deu entrada
                                             DailyLastBelow=roundBelow;

                                            } //if ( MySet[x].RangeHighLow == "HIGH" && MySet[x].TradeDirection == "SHORT"  
                                          else if(MySet[x].TradeDirection=="SHORT") // Verifica se o trade esperado eh Compra (LONG)
                                            {
                                             // Verifica se ja existe ordem pendente, no outro extremo da range
                                             if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                             //Informa que precisa enviar Ordem Pendente
                                             MySet[x].glPlaceOrder=true;
                                             MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                             MySet[x].RangeLevel=(roundBelow+MySet[x].EarlyOrder_Distance);  //Identifica o ponto onde a Range foi identificada

                                             Print("OnTick| TradeID:",MySet[x].TradeID," SHORT |Round Below:",(string)MySet[x].RangeLevel," |DailyLastBelow:", DailyLastBelow," |EarlyDistance:",MySet[x].EarlyOrder_Distance," |EntryPoint:",MySet[x].EntryPoint );
                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );

                                             // Atualiza valor do ultimo round Below que deu entrada
                                             DailyLastBelow=roundBelow;

                                            } // Close else. "// Verifica se o trade esperado eh Venda (SHORT)

                                         } //DailyBGSV

                                      } // DayPosition

                                   } // MID.1

                                } //CTC.1

                             } //CTO

                          }  // END roundBelow

                        //Show Line with Range on Current Chart
                        if(ObjectCreate(0,"HLINE_Range",OBJ_HLINE,0,0,50000))
                          {
                           MySet[x].RangeLineObj=true;
                           //--- set line color
                           ObjectSetInteger(0,"HLINE_Range",OBJPROP_COLOR,clrGold);
                          }
                        if(MySet[x].RangeLineObj) ObjectMove(0,"HLINE_Range",0,0,MySet[x].RangeLevel);

                       } // else related to [if ( RangeCurrent > MySet[x].Range && MySet[x].Trade_Status == "WAITING" ) ]

                    } // TradeType ROUNDN. Check Entry signal and previous order request

                  //=============================================================================
                  // TradeType: THIRSTY ==== Check Entry signal and previous order request ANDREA UNGER
                  //=============================================================================
                  else if(MySet[x].TradeType=="THIRSTY" && MySet[x].Trade_Status!="FINISHED" && MySet[x].Trade_Status!="STARTED" && MySet[x].EntryOrder_Status!="REJECTED")
                    {
                     // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                     // Ordem de Entrada - STATUS (REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED)
                     //Print("OnTick| TradeID:",MySet[x].TradeID," newBar: ",newBar," |barShift: ",barShift," |MySet[x].EntryBar: ",MySet[x].EntryBar," |Daily_BarCounter: ",MySet[x].Daily_BarCounter," |MySet[x].EntryOrder_Price: ",MySet[x].EntryOrder_Price );

                     //Check last position status
                     if(MySet[x].EntryOrder_Status=="" && (MySet[x].glBuyPlaced==true || MySet[x].glSellPlaced==true) && (MySet[x].EntryOrder_type!="DEAL_TYPE_BUY" || MySet[x].EntryOrder_type!="DEAL_TYPE_SELL"))
                       {
                        Print("OnTick| TradeID:",MySet[x].TradeID," |THIRSTY: Posicao encerrada. Reiniciando as flags.");
                        MySet[x].glBuyPlaced=false;
                        MySet[x].glSellPlaced=false;
                        //glOrderPlacedWaitingReturn = false; MySet[x].EntryOrder_Status == "PLACED"
                        //Position_lastchecked_status = MySet[x].EntryOrder_Status;
                       }
                     else if(barShift==1 && MySet[x].EntryBar==MySet[x].Daily_BarCounter && MySet[x].EntryOrder_Price==0)
                       {

                        MySet[x].CalcBarRange= LastBarRange;
                        MySet[x].CalcBarBody = LastBarBody;
                        MySet[x].CalcBarBodyAbs=LastBarBodyAbs;
                        MySet[x].DailyFactor=DailyFactor;

                        Print("OnTick| TradeID:",MySet[x].TradeID," |THIRSTY. LastBarTime:",MySet[x].LastBar_Time," |DailyFactor: ",DailyFactor);

                        if(MySet[x].DailyFactor>=MySet[x].DailyFactor_Min && MySet[x].DailyFactor<=MySet[x].DailyFactor_Max)
                          {
                           // Verifica se a entrada eh Above ou Below e calcula o ponto de entrada, em pontos.
                           if(MySet[x].Entry_ABoveBelow==1) // 1= Above
                             {
                              MySet[x].EntryOrder_Price=rates[1].high+(MySet[x].CalcBarRange *(MySet[x].RangePerc_to_Entry/100));
                              // STOP para tradetype THIRSTY é baseado na maxima e minima da barra de referencia
                              MySet[x].StopLossPoints=MySet[x].EntryOrder_Price-rates[1].high;
                             }
                           else if(MySet[x].Entry_ABoveBelow==0) // 0= Below
                             {
                              MySet[x].EntryOrder_Price=rates[1].low -(MySet[x].CalcBarRange *(MySet[x].RangePerc_to_Entry/100));
                              // STOP para tradetype THIRSTY é baseado na maxima e minima da barra de referencia
                              MySet[x].StopLossPoints=rates[1].low-MySet[x].EntryOrder_Price;
                             }

                           Print("OnTick| TradeID:",MySet[x].TradeID," |THIRSTY. LastBarTime:",MySet[x].LastBar_Time," |LastBarRange: ",MySet[x].CalcBarRange," |CalcBarBody: ",MySet[x].CalcBarBody," |LastBarHigh: ",rates[1].high," |LastBarLow: ",rates[1].low," |RangePerc_to_Entry: ",MySet[x].RangePerc_to_Entry," |Quantos pontos: ",(MySet[x].CalcBarRange *(MySet[x].RangePerc_to_Entry/100))," |Resultado: ",MySet[x].EntryOrder_Price," |StopLoss: ",MySet[x].StopLossPoints);

                           // Calcula pontos de Target, se target baseado em percentual da range
                           if(MySet[x].TakeProfit_PercRange>0) // Prioriza o Target baseado em percentual da Range
                             {
                              MySet[x].TakeProfitPoints=MySet[x].CalcBarRange*MySet[x].TakeProfit_PercRange/100;
                              Print("OnTick| TradeID:",MySet[x].TradeID," | TakeProfit_PercRange: ",MySet[x].TakeProfit_PercRange," | TakeProfit: ",MySet[x].TakeProfitPoints);
                             }
                           //// Calcula pontos de Stop, se stop baseado em percentual da range
                           //if( MySet[x].StopLoss_PercRange > 0 ) // Prioriza o Stop baseado em percentual da Range
                           //{
                           //   MySet[x].StopLoss = MySet[x].CalcBarRange * MySet[x].StopLoss_PercRange / 100;
                           //   Print( "OnTick| TradeID:",MySet[x].TradeID," | StopLoss_PercRange: ",MySet[x].StopLoss_PercRange," | StopLoss: ",MySet[x].StopLoss );
                           //}

                          }
                       }

                     if(MySet[x].EntryOrder_Status=="" && MySet[x].EntryOrder_Price!=0 && MySet[x].Daily_BarCounter>=MySet[x].EntryBar)
                       { // else related to [if ( RangeCurrent > MySet[x].Range && MySet[x].Trade_Status == "WAITING" ) ]
                        //PlaySound("alert.wav"); // Play Sound as signal that range was stablished on level requested.

                        //Print( "Daily extremes: high "+ (string)Daily[0].high  +" -LastHigh "+ (string)MySet[x].LastDailyHigh  +" - low "+ (string)Daily[0].low +" - LastLow "+ (string)MySet[x].LastDailyLow );

                        //Identifica se alcancou o ponto de entrada Above
                        if(rates[0].close>=MySet[x].EntryOrder_Price && MySet[x].Entry_ABoveBelow==1) // MySet[x].Entry_ABoveBelow == 1  sendo, 1=(Above) ou 0=(Below)
                          {

                           //Moment filters
                           //Filtros analisados no momento de entrada do trade

                           // CTO 
                           if(MySet[x].CTO=="" || (MySet[x].CTO=="+" && MySet[x].EntryOrder_Price-DailyOpen>=0) || (MySet[x].CTO=="-" && MySet[x].EntryOrder_Price-DailyOpen<0))
                             {

                              // CTC.1
                              if(MySet[x].CTC1=="" || (MySet[x].CTC1=="+" && MySet[x].EntryOrder_Price-Y_Close>=0) || (MySet[x].CTC1=="-" && MySet[x].EntryOrder_Price-Y_Close<0))
                                {

                                 // MID.1 [H+/M+/M-/L-]
                                 //if ( StringFind(MySet[x].MID1_Reference,MID1) > -1 )
                                 if((StringFind(MySet[x].MID1_Reference,fMID1(MySet[x].EntryOrder_Price,Y_High,Y_Low)))>-1)
                                   {

                                    // DayPosition [ABOVE/BELOW/INSIDE/OUTSIDE]
                                    if(StringFind(MySet[x].DayPosition,Current_DayPosition)>-1)
                                      {

                                       // DailyBGSV
                                       if(MySet[x].DailyBGSV=="" || (MySet[x].DailyBGSV=="+" && (Daily[0].high-DailyOpen)>=(DailyOpen-Daily[0].low)) || (MySet[x].DailyBGSV=="-" && (Daily[0].high-DailyOpen)<(DailyOpen-Daily[0].low)))
                                         {

                                          // Verifica se o trade esperado eh Venda (SHORT)
                                          if(MySet[x].TradeDirection=="SHORT") // Vender sempre que alcancar o round above
                                            {

                                             // Verifica se ja existe ordem pendente, no outro extremo da range
                                             if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                             //Informa que precisa enviar Ordem Pendente
                                             MySet[x].glPlaceOrder=true;
                                             MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                             MySet[x].RangeLevel=MySet[x].EntryOrder_Price;  //Identifica o ponto de entrada

                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Entry_Higher_SHORT:",(string)MySet[x].RangeLevel," |rates[0].close", rates[0].close );
                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );

                                             // Atualiza valor do ultimo round que deu entrada
                                             DailyLastAbove=MySet[x].EntryOrder_Price;

                                            } //if ( MySet[x].RangeHighLow == "HIGH" && MySet[x].TradeDirection == "SHORT"  
                                          else if(MySet[x].TradeDirection=="LONG") // Verifica se o trade esperado eh Compra (LONG)
                                            {
                                             // Verifica se ja existe ordem pendente, no outro extremo da range
                                             if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                             //Informa que precisa enviar Ordem Pendente
                                             MySet[x].glPlaceOrder=true;
                                             MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                             MySet[x].RangeLevel=MySet[x].EntryOrder_Price;  //Identifica o ponto onde a Range foi identificada

                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Entry_Higher_LONG:",(string)MySet[x].RangeLevel," |rates[0].close", rates[0].close );
                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );

                                             // Atualiza valor do ultimo round que deu entrada
                                             DailyLastAbove=MySet[x].EntryOrder_Price;

                                            } // Close else. "// Verifica se o trade esperado eh Venda (SHORT)

                                         } //DailyBGSV

                                      } // DayPosition

                                   } // MID.1

                                } //CTC.1

                             } //CTO

                          } // END Above
                        else if(rates[0].close<=MySet[x].EntryOrder_Price && MySet[x].Entry_ABoveBelow==0) // MySet[x].Entry_ABoveBelow == 1  sendo, 1=(Above) ou 0=(Below)
                          {

                           //Moment filters
                           //Filtros analisados no momento de entrada do trade

                           // CTO 
                           if(MySet[x].CTO=="" || (MySet[x].CTO=="+" && MySet[x].EntryOrder_Price-DailyOpen>=0) || (MySet[x].CTO=="-" && MySet[x].EntryOrder_Price-DailyOpen<0))
                             {

                              // CTC.1
                              if(MySet[x].CTC1=="" || (MySet[x].CTC1=="+" && MySet[x].EntryOrder_Price-Y_Close>=0) || (MySet[x].CTC1=="-" && MySet[x].EntryOrder_Price-Y_Close<0))
                                {

                                 // MID.1 [H+/M+/M-/L-]
                                 //if ( StringFind(MySet[x].MID1_Reference,MID1) > -1 )
                                 if((StringFind(MySet[x].MID1_Reference,fMID1(roundBelow,Y_High,Y_Low)))>-1)
                                   {

                                    // DayPosition [ABOVE/BELOW/INSIDE/OUTSIDE]
                                    if(StringFind(MySet[x].DayPosition,Current_DayPosition)>-1)
                                      {

                                       // DailyBGSV
                                       if(MySet[x].DailyBGSV=="" || (MySet[x].DailyBGSV=="+" && (Daily[0].high-DailyOpen)>=(DailyOpen-Daily[0].low)) || (MySet[x].DailyBGSV=="-" && (Daily[0].high-DailyOpen)<(DailyOpen-Daily[0].low)))
                                         {

                                          // Verifica se o trade esperado eh Compra (LONG)
                                          if(MySet[x].TradeDirection=="LONG") // Comprar sempre que alcancar o round above
                                            {

                                             // Verifica se ja existe ordem pendente, no outro extremo da range
                                             if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                             //Informa que precisa enviar Ordem Pendente
                                             MySet[x].glPlaceOrder=true;
                                             MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                             MySet[x].RangeLevel=MySet[x].EntryOrder_Price;  //Identifica o ponto de entrada

                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Entry_Lower_LONG:",(string)MySet[x].RangeLevel," |rates[0].close", rates[0].close );
                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );

                                             // Atualiza valor do ultimo round Below que deu entrada
                                             DailyLastBelow=MySet[x].EntryOrder_Price;

                                            } //if ( MySet[x].RangeHighLow == "HIGH" && MySet[x].TradeDirection == "SHORT"  
                                          else if(MySet[x].TradeDirection=="SHORT") // Verifica se o trade esperado eh Venda (SHORT)
                                            {
                                             // Verifica se ja existe ordem pendente, no outro extremo da range
                                             if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                             //Informa que precisa enviar Ordem Pendente
                                             MySet[x].glPlaceOrder=true;
                                             MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                             MySet[x].RangeLevel=MySet[x].EntryOrder_Price;  //Identifica o ponto onde a Range foi identificada

                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Entry_Lower_SHORT:",(string)MySet[x].RangeLevel," |rates[0].close", rates[0].close );
                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );

                                             // Atualiza valor do ultimo round Below que deu entrada
                                             DailyLastBelow=MySet[x].EntryOrder_Price;

                                            } // Close else. "// Verifica se o trade esperado eh Venda (SHORT)

                                         } //DailyBGSV

                                      } // DayPosition

                                   } // MID.1

                                } //CTC.1

                             } //CTO

                          }  // END Below

                        //Show Line with Range on Current Chart
                        if(ObjectCreate(0,"HLINE_Range",OBJ_HLINE,0,0,50000))
                          {
                           MySet[x].RangeLineObj=true;
                           //--- set line color
                           ObjectSetInteger(0,"HLINE_Range",OBJPROP_COLOR,clrGold);
                          }
                        if(MySet[x].RangeLineObj) ObjectMove(0,"HLINE_Range",0,0,MySet[x].RangeLevel);

                       } // else related to [if ( RangeCurrent > MySet[x].Range && MySet[x].Trade_Status == "WAITING" ) ]

                    } // TradeType THIRSTY.

                  //=============================================================================
                  // TradeType: LASTBAR ==== Check Entry signal and previous order request LASTBAR
                  //=============================================================================
                  else if(MySet[x].TradeType=="LASTBAR" && MySet[x].Trade_Status!="FINISHED" && MySet[x].Trade_Status!="STARTED" && MySet[x].EntryOrder_Status!="REJECTED")
                    {
                     // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                     // Ordem de Entrada - STATUS (REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED)
                     //Print("OnTick| TradeID:",MySet[x].TradeID," newBar: ",newBar," |barShift: ",barShift," |MySet[x].EntryBar: ",MySet[x].EntryBar," |Daily_BarCounter: ",MySet[x].Daily_BarCounter," |MySet[x].EntryOrder_Price: ",MySet[x].EntryOrder_Price );

                     //Check last position status
                     if(MySet[x].EntryOrder_Status=="" && (MySet[x].glBuyPlaced==true || MySet[x].glSellPlaced==true) && (MySet[x].EntryOrder_type!="DEAL_TYPE_BUY" || MySet[x].EntryOrder_type!="DEAL_TYPE_SELL"))
                       {
                        Print("OnTick| TradeID:",MySet[x].TradeID," |LASTBAR: Posicao encerrada. Reiniciando as flags.");
                        MySet[x].glBuyPlaced=false;
                        MySet[x].glSellPlaced=false;
                        //glOrderPlacedWaitingReturn = false; MySet[x].EntryOrder_Status == "PLACED"
                        //Position_lastchecked_status = MySet[x].EntryOrder_Status;
                       }
                     else if(barShift==1 && MySet[x].EntryBar==MySet[x].Daily_BarCounter && MySet[x].EntryOrder_Price==0)
                       {

                        MySet[x].CalcBarRange= LastBarRange;
                        MySet[x].CalcBarBody = LastBarBody;
                        MySet[x].CalcBarBodyAbs=LastBarBodyAbs;
                        MySet[x].DailyFactor=DailyFactor;

                        Print("OnTick| TradeID:",MySet[x].TradeID," |LASTBAR. LastBarTime:",MySet[x].LastBar_Time," |DailyFactor: ",DailyFactor);

                        if(MySet[x].DailyFactor>=MySet[x].DailyFactor_Min && MySet[x].DailyFactor<=MySet[x].DailyFactor_Max)
                          {
                           // Verifica se a entrada eh Above ou Below e calcula o ponto de entrada, em pontos.
                           if(MySet[x].Entry_ABoveBelow==1) // 1= Above
                             {
                              MySet[x].EntryOrder_Price=rates[1].high+(MySet[x].CalcBarRange *(MySet[x].RangePerc_to_Entry/100));
                             }
                           else if(MySet[x].Entry_ABoveBelow==0) // 0= Below
                             {
                              MySet[x].EntryOrder_Price=rates[1].low -(MySet[x].CalcBarRange *(MySet[x].RangePerc_to_Entry/100));
                             }

                           Print("OnTick| TradeID:",MySet[x].TradeID," |LASTBAR. LastBarTime:",MySet[x].LastBar_Time," |LastBarRange: ",MySet[x].CalcBarRange," |CalcBarBody: ",MySet[x].CalcBarBody," |LastBarHigh: ",rates[1].high," |LastBarLow: ",rates[1].low," |RangePerc_to_Entry: ",MySet[x].RangePerc_to_Entry," |Quantos pontos: ",(MySet[x].CalcBarRange *(MySet[x].RangePerc_to_Entry/100))," |Resultado: ",MySet[x].EntryOrder_Price," |StopLoss: ",MySet[x].StopLossPoints);

                           // Calcula pontos de Target, se target baseado em percentual da range
                           if(MySet[x].TakeProfit_PercRange>0) // Prioriza o Target baseado em percentual da Range
                             {
                              MySet[x].TakeProfitPoints=MySet[x].CalcBarRange*MySet[x].TakeProfit_PercRange/100;
                              Print("OnTick| TradeID:",MySet[x].TradeID," | TakeProfit_PercRange: ",MySet[x].TakeProfit_PercRange," | TakeProfit: ",MySet[x].TakeProfitPoints);
                             }

                          }
                       }

                     if(MySet[x].EntryOrder_Status=="" && MySet[x].EntryOrder_Price!=0 && MySet[x].Daily_BarCounter>=MySet[x].EntryBar)
                       { // else related to [if ( RangeCurrent > MySet[x].Range && MySet[x].Trade_Status == "WAITING" ) ]
                        //PlaySound("alert.wav"); // Play Sound as signal that range was stablished on level requested.

                        //Print( "Daily extremes: high "+ (string)Daily[0].high  +" -LastHigh "+ (string)MySet[x].LastDailyHigh  +" - low "+ (string)Daily[0].low +" - LastLow "+ (string)MySet[x].LastDailyLow );

                        //Identifica se alcancou o ponto de entrada Above
                        if(rates[0].close>=MySet[x].EntryOrder_Price && MySet[x].Entry_ABoveBelow==1) // MySet[x].Entry_ABoveBelow == 1  sendo, 1=(Above) ou 0=(Below)
                          {

                           //Moment filters
                           //Filtros analisados no momento de entrada do trade

                           // CTO 
                           if(MySet[x].CTO=="" || (MySet[x].CTO=="+" && MySet[x].EntryOrder_Price-DailyOpen>=0) || (MySet[x].CTO=="-" && MySet[x].EntryOrder_Price-DailyOpen<0))
                             {

                              // CTC.1
                              if(MySet[x].CTC1=="" || (MySet[x].CTC1=="+" && MySet[x].EntryOrder_Price-Y_Close>=0) || (MySet[x].CTC1=="-" && MySet[x].EntryOrder_Price-Y_Close<0))
                                {

                                 // MID.1 [H+/M+/M-/L-]
                                 //if ( StringFind(MySet[x].MID1_Reference,MID1) > -1 )
                                 if((StringFind(MySet[x].MID1_Reference,fMID1(MySet[x].EntryOrder_Price,Y_High,Y_Low)))>-1)
                                   {

                                    // DayPosition [ABOVE/BELOW/INSIDE/OUTSIDE]
                                    if(StringFind(MySet[x].DayPosition,Current_DayPosition)>-1)
                                      {

                                       // DailyBGSV
                                       if(MySet[x].DailyBGSV=="" || (MySet[x].DailyBGSV=="+" && (Daily[0].high-DailyOpen)>=(DailyOpen-Daily[0].low)) || (MySet[x].DailyBGSV=="-" && (Daily[0].high-DailyOpen)<(DailyOpen-Daily[0].low)))
                                         {

                                          // Verifica se o trade esperado eh Venda (SHORT)
                                          if(MySet[x].TradeDirection=="SHORT") // Vender sempre que alcancar o round above
                                            {

                                             // Verifica se ja existe ordem pendente, no outro extremo da range
                                             if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                             //Informa que precisa enviar Ordem Pendente
                                             MySet[x].glPlaceOrder=true;
                                             MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                             MySet[x].RangeLevel=MySet[x].EntryOrder_Price;  //Identifica o ponto de entrada

                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Entry_Higher_SHORT:",(string)MySet[x].RangeLevel," |rates[0].close", rates[0].close );
                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );

                                             // Atualiza valor do ultimo round que deu entrada
                                             DailyLastAbove=MySet[x].EntryOrder_Price;

                                            } //if ( MySet[x].RangeHighLow == "HIGH" && MySet[x].TradeDirection == "SHORT"  
                                          else if(MySet[x].TradeDirection=="LONG") // Verifica se o trade esperado eh Compra (LONG)
                                            {
                                             // Verifica se ja existe ordem pendente, no outro extremo da range
                                             if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                             //Informa que precisa enviar Ordem Pendente
                                             MySet[x].glPlaceOrder=true;
                                             MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                             MySet[x].RangeLevel=MySet[x].EntryOrder_Price;  //Identifica o ponto onde a Range foi identificada

                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Entry_Higher_LONG:",(string)MySet[x].RangeLevel," |rates[0].close", rates[0].close );
                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );

                                             // Atualiza valor do ultimo round que deu entrada
                                             DailyLastAbove=MySet[x].EntryOrder_Price;

                                            } // Close else. "// Verifica se o trade esperado eh Venda (SHORT)

                                         } //DailyBGSV

                                      } // DayPosition

                                   } // MID.1

                                } //CTC.1

                             } //CTO

                          } // END Above
                        else if(rates[0].close<=MySet[x].EntryOrder_Price && MySet[x].Entry_ABoveBelow==0) // MySet[x].Entry_ABoveBelow == 1  sendo, 1=(Above) ou 0=(Below)
                          {

                           //Moment filters
                           //Filtros analisados no momento de entrada do trade

                           // CTO 
                           if(MySet[x].CTO=="" || (MySet[x].CTO=="+" && MySet[x].EntryOrder_Price-DailyOpen>=0) || (MySet[x].CTO=="-" && MySet[x].EntryOrder_Price-DailyOpen<0))
                             {

                              // CTC.1
                              if(MySet[x].CTC1=="" || (MySet[x].CTC1=="+" && MySet[x].EntryOrder_Price-Y_Close>=0) || (MySet[x].CTC1=="-" && MySet[x].EntryOrder_Price-Y_Close<0))
                                {

                                 // MID.1 [H+/M+/M-/L-]
                                 //if ( StringFind(MySet[x].MID1_Reference,MID1) > -1 )
                                 if((StringFind(MySet[x].MID1_Reference,fMID1(roundBelow,Y_High,Y_Low)))>-1)
                                   {

                                    // DayPosition [ABOVE/BELOW/INSIDE/OUTSIDE]
                                    if(StringFind(MySet[x].DayPosition,Current_DayPosition)>-1)
                                      {

                                       // DailyBGSV
                                       if(MySet[x].DailyBGSV=="" || (MySet[x].DailyBGSV=="+" && (Daily[0].high-DailyOpen)>=(DailyOpen-Daily[0].low)) || (MySet[x].DailyBGSV=="-" && (Daily[0].high-DailyOpen)<(DailyOpen-Daily[0].low)))
                                         {

                                          // Verifica se o trade esperado eh Compra (LONG)
                                          if(MySet[x].TradeDirection=="LONG") // Comprar sempre que alcancar o round above
                                            {

                                             // Verifica se ja existe ordem pendente, no outro extremo da range
                                             if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                             //Informa que precisa enviar Ordem Pendente
                                             MySet[x].glPlaceOrder=true;
                                             MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                             MySet[x].RangeLevel=MySet[x].EntryOrder_Price;  //Identifica o ponto de entrada

                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Entry_Lower_LONG:",(string)MySet[x].RangeLevel," |rates[0].close", rates[0].close );
                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );

                                             // Atualiza valor do ultimo round Below que deu entrada
                                             DailyLastBelow=MySet[x].EntryOrder_Price;

                                            } //if ( MySet[x].RangeHighLow == "HIGH" && MySet[x].TradeDirection == "SHORT"  
                                          else if(MySet[x].TradeDirection=="SHORT") // Verifica se o trade esperado eh Venda (SHORT)
                                            {
                                             // Verifica se ja existe ordem pendente, no outro extremo da range
                                             if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                             //Informa que precisa enviar Ordem Pendente
                                             MySet[x].glPlaceOrder=true;
                                             MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                             MySet[x].RangeLevel=MySet[x].EntryOrder_Price;  //Identifica o ponto onde a Range foi identificada

                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Entry_Lower_SHORT:",(string)MySet[x].RangeLevel," |rates[0].close", rates[0].close );
                                             Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );

                                             // Atualiza valor do ultimo round Below que deu entrada
                                             DailyLastBelow=MySet[x].EntryOrder_Price;

                                            } // Close else. "// Verifica se o trade esperado eh Venda (SHORT)

                                         } //DailyBGSV

                                      } // DayPosition

                                   } // MID.1

                                } //CTC.1

                             } //CTO

                          }  // END Below

                        //Show Line with Range on Current Chart
                        if(ObjectCreate(0,"HLINE_Range",OBJ_HLINE,0,0,50000))
                          {
                           MySet[x].RangeLineObj=true;
                           //--- set line color
                           ObjectSetInteger(0,"HLINE_Range",OBJPROP_COLOR,clrGold);
                          }
                        if(MySet[x].RangeLineObj) ObjectMove(0,"HLINE_Range",0,0,MySet[x].RangeLevel);

                       } // else related to [if ( RangeCurrent > MySet[x].Range && MySet[x].Trade_Status == "WAITING" ) ]

                    } // TradeType LASTBAR.

                  //=============================================================================
                  // TradeType: BSP_BOP ==== Check Entry signal and previous order request BSP_BOP
                  //=============================================================================
                  else if(MySet[x].TradeType=="BSP_BOP" && MySet[x].Trade_Status!="FINISHED" && MySet[x].Trade_Status!="STARTED" && MySet[x].EntryOrder_Status!="REJECTED")
                    {
                     // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                     // Ordem de Entrada - STATUS (REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED)
                     //Print("OnTick| TradeID:",MySet[x].TradeID," newBar: ",newBar," |barShift: ",barShift," |MySet[x].EntryBar: ",MySet[x].EntryBar," |Daily_BarCounter: ",MySet[x].Daily_BarCounter," |MySet[x].EntryOrder_Price: ",MySet[x].EntryOrder_Price );

                     //Check last position status
                     if(MySet[x].EntryOrder_Status=="" && (MySet[x].glBuyPlaced==true || MySet[x].glSellPlaced==true) && (MySet[x].EntryOrder_type!="DEAL_TYPE_BUY" || MySet[x].EntryOrder_type!="DEAL_TYPE_SELL"))
                       {
                        Print("OnTick| TradeID:",MySet[x].TradeID," |BSP_BOP: Posicao encerrada. Reiniciando as flags.");
                        MySet[x].glBuyPlaced=false;
                        MySet[x].glSellPlaced=false;
                        //glOrderPlacedWaitingReturn = false; MySet[x].EntryOrder_Status == "PLACED"
                        //Position_lastchecked_status = MySet[x].EntryOrder_Status;
                       }
                     else if(barShift==1 && MySet[x].EntryBar==MySet[x].Daily_BarCounter && MySet[x].EntryOrder_Price==0)
                       {

                        MySet[x].CalcBarRange= LastBarRange;
                        MySet[x].CalcBarBody = LastBarBody;
                        MySet[x].CalcBarBodyAbs=LastBarBodyAbs;
                        MySet[x].DailyFactor=DailyFactor;

                        Print("OnTick| TradeID:",MySet[x].TradeID," |BSP_BOP. LastBarTime:",MySet[x].LastBar_Time," |DailyFactor: ",DailyFactor );
                        Print("OnTick| TradeID:",MySet[x].TradeID," |BSP_BOP. BaseBSPBOP:",MySet[x].BaseBSPBOP ," |BSP_BOP: ",MySet[x].BSP_BOP );

                        if(MySet[x].DailyFactor>=MySet[x].DailyFactor_Min && MySet[x].DailyFactor<=MySet[x].DailyFactor_Max)
                          {
                           if(MySet[x].BaseBSPBOP=="CTO")
                             {
                              if(MySet[x].BSP_BOP=="BSP")
                                {
                                 if(LastBarBody>0)
                                   {
                                    if(MySet[x].TradeDirection=="LONG" || MySet[x].TradeDirection=="")
                                      {
                                       MySet[x].TradeDirection="LONG";
                                       MySet[x].EntryOrder_Price=rates[0].close-Slippage;
                                      }
                                   }
                                 else if(LastBarBody<0)
                                   {
                                    if(MySet[x].TradeDirection=="SHORT" || MySet[x].TradeDirection=="")
                                      {
                                       MySet[x].TradeDirection="SHORT";
                                       MySet[x].EntryOrder_Price=rates[0].close+Slippage;
                                      }
                                   }
                                } // if ( MySet[x].BSP_BOP == "BSP" )
                              else if(MySet[x].BSP_BOP=="BOP")
                                {
                                 if(LastBarBody>0)
                                   {
                                    if(MySet[x].TradeDirection=="SHORT" || MySet[x].TradeDirection=="")
                                      {
                                       MySet[x].TradeDirection="SHORT";
                                       MySet[x].EntryOrder_Price=rates[0].close+Slippage;
                                      }
                                   }
                                 else if(LastBarBody<0)
                                   {
                                    if(MySet[x].TradeDirection=="LONG" || MySet[x].TradeDirection=="")
                                      {
                                       MySet[x].TradeDirection="LONG";
                                       MySet[x].EntryOrder_Price=rates[0].close-Slippage;
                                      }
                                   }
                                } // else if ( MySet[x].BSP_BOP == "BOP" )
                              Print("OnTick| TradeID:",MySet[x].TradeID," |BSP_BOP. Base:",MySet[x].BaseBSPBOP," |Sentido do trade: ",MySet[x].BSP_BOP," |TradeDirection: ",MySet[x].TradeDirection," |LastBarCTO: ",LastBarBody," |EntryPoint: ",MySet[x].EntryOrder_Price);
                             } // if ( MySet[x].BaseBSPBOP == "CTO" )
                           else if(MySet[x].BaseBSPBOP=="BGSV")
                             {
                              string LastBarBGSV;
                              if(MySet[x].BSP_BOP=="BSP")
                                {
                                 if((rates[1].high-rates[1].open)>(rates[1].open-rates[1].low))
                                   {
                                    if(MySet[x].TradeDirection=="LONG" || MySet[x].TradeDirection=="")
                                      {
                                       MySet[x].TradeDirection="LONG";
                                       MySet[x].EntryOrder_Price=rates[0].close-Slippage;
                                       LastBarBGSV="UP";
                                      }
                                   }
                                 else if((rates[1].high-rates[1].open)<(rates[1].open-rates[1].low))
                                   {
                                    if(MySet[x].TradeDirection=="SHORT" || MySet[x].TradeDirection=="")
                                      {
                                       MySet[x].TradeDirection="SHORT";
                                       MySet[x].EntryOrder_Price=rates[0].close+Slippage;
                                       LastBarBGSV="DOWN";
                                      }
                                   }
                                } // if ( MySet[x].BSP_BOP == "BSP" )
                              else if(MySet[x].BSP_BOP=="BOP")
                                {
                                 if((rates[1].high-rates[1].open)>(rates[1].open-rates[1].low))
                                   {
                                    if(MySet[x].TradeDirection=="LONG" || MySet[x].TradeDirection=="")
                                      {
                                       MySet[x].TradeDirection="LONG";
                                       MySet[x].EntryOrder_Price=rates[0].close-Slippage;
                                       LastBarBGSV="UP";
                                      }
                                   }
                                 else if((rates[1].high-rates[1].open)<(rates[1].open-rates[1].low))
                                   {
                                    if(MySet[x].TradeDirection=="SHORT" || MySet[x].TradeDirection=="")
                                      {
                                       MySet[x].TradeDirection="SHORT";
                                       MySet[x].EntryOrder_Price=rates[0].close+Slippage;
                                       LastBarBGSV="DOWN";
                                      }
                                   }
                                } // else if ( MySet[x].BSP_BOP == "BOP" )
                              Print("OnTick| TradeID:",MySet[x].TradeID," |BSP_BOP. Base:",MySet[x].BaseBSPBOP," |Sentido do trade: ",MySet[x].BSP_BOP," |TradeDirection: ",MySet[x].TradeDirection," |LastBarBGSV: ",LastBarBGSV," |LastBarCTO: ",LastBarBody," |EntryPoint: ",MySet[x].EntryOrder_Price);
                             } // else if ( MySet[x].BaseBSPBOP == "BGSV" )

                           Print("OnTick| TradeID:",MySet[x].TradeID," |BSP_BOP. LastBarTime:",MySet[x].LastBar_Time," |LastBarRange: ",MySet[x].CalcBarRange," |CalcBarBody: ",MySet[x].CalcBarBody," |LastBarHigh: ",rates[1].high," |LastBarLow: ",rates[1].low," |Resultado: ",MySet[x].EntryOrder_Price," |StopLoss: ",MySet[x].StopLossPoints);

                           // Calcula pontos de Target, se target baseado em percentual da range
                           if(MySet[x].TakeProfit_PercRange>0) // Prioriza o Target baseado em percentual da Range
                             {
                              MySet[x].TakeProfitPoints=MySet[x].CalcBarRange*MySet[x].TakeProfit_PercRange/100;
                              Print("OnTick| TradeID:",MySet[x].TradeID," | TakeProfit_PercRange: ",MySet[x].TakeProfit_PercRange," | TakeProfit: ",MySet[x].TakeProfitPoints);
                             }

                          } //if ( MySet[x].DailyFactor >= MySet[x].DailyFactor_Min && MySet[x].DailyFactor <= MySet[x].DailyFactor_Max ) 
                       } // if ( barShift == 1 && MySet[x].EntryBar == MySet[x].Daily_BarCounter && MySet[x].EntryOrder_Price == 0 )

                     if(MySet[x].EntryOrder_Status=="" && MySet[x].EntryOrder_Price!=0 && MySet[x].Daily_BarCounter>=MySet[x].EntryBar)
                       { // else related to [if ( RangeCurrent > MySet[x].Range && MySet[x].Trade_Status == "WAITING" ) ]
                        //PlaySound("alert.wav"); // Play Sound as signal that range was stablished on level requested.

                        //Print( "Daily extremes: high "+ (string)Daily[0].high  +" -LastHigh "+ (string)MySet[x].LastDailyHigh  +" - low "+ (string)Daily[0].low +" - LastLow "+ (string)MySet[x].LastDailyLow );

                        //Moment filters
                        //Filtros analisados no momento de entrada do trade

                        // CTO 
                        if(MySet[x].CTO=="" || (MySet[x].CTO=="+" && MySet[x].EntryOrder_Price-DailyOpen>=0) || (MySet[x].CTO=="-" && MySet[x].EntryOrder_Price-DailyOpen<0))
                          {

                           // CTC.1
                           if(MySet[x].CTC1=="" || (MySet[x].CTC1=="+" && MySet[x].EntryOrder_Price-Y_Close>=0) || (MySet[x].CTC1=="-" && MySet[x].EntryOrder_Price-Y_Close<0))
                             {

                              // MID.1 [H+/M+/M-/L-]
                              //if ( StringFind(MySet[x].MID1_Reference,MID1) > -1 )
                              if((StringFind(MySet[x].MID1_Reference,fMID1(MySet[x].EntryOrder_Price,Y_High,Y_Low)))>-1)
                                {

                                 // DayPosition [ABOVE/BELOW/INSIDE/OUTSIDE]
                                 if(StringFind(MySet[x].DayPosition,Current_DayPosition)>-1)
                                   {

                                    // DailyBGSV
                                    if(MySet[x].DailyBGSV=="" || (MySet[x].DailyBGSV=="+" && (Daily[0].high-DailyOpen)>=(DailyOpen-Daily[0].low)) || (MySet[x].DailyBGSV=="-" && (Daily[0].high-DailyOpen)<(DailyOpen-Daily[0].low)))
                                      {

                                       // Verifica se o trade esperado eh Venda (SHORT)
                                       if(MySet[x].TradeDirection=="SHORT") // Vender sempre que alcancar o round above
                                         {

                                          // Verifica se ja existe ordem pendente, no outro extremo da range
                                          if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                          //Informa que precisa enviar Ordem Pendente
                                          MySet[x].glPlaceOrder=true;
                                          MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                          MySet[x].RangeLevel=MySet[x].EntryOrder_Price;  //Identifica o ponto de entrada

                                          Print("OnTick| TradeID:",MySet[x].TradeID," |Entry_SHORT:",(string)MySet[x].RangeLevel," |rates[0].close", rates[0].close );
                                          Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );

                                          // Atualiza valor do ultimo round que deu entrada
                                          DailyLastAbove=MySet[x].EntryOrder_Price;

                                         } //if ( MySet[x].RangeHighLow == "HIGH" && MySet[x].TradeDirection == "SHORT"  
                                       else if(MySet[x].TradeDirection=="LONG") // Verifica se o trade esperado eh Compra (LONG)
                                         {
                                          // Verifica se ja existe ordem pendente, no outro extremo da range
                                          if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                          //Informa que precisa enviar Ordem Pendente
                                          MySet[x].glPlaceOrder=true;
                                          MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                          MySet[x].RangeLevel=MySet[x].EntryOrder_Price;  //Identifica o ponto onde a Range foi identificada

                                          Print("OnTick| TradeID:",MySet[x].TradeID," |Entry_LONG:",(string)MySet[x].RangeLevel," |rates[0].close:", rates[0].close );
                                          Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );

                                          // Atualiza valor do ultimo round que deu entrada
                                          DailyLastAbove=MySet[x].EntryOrder_Price;

                                         } // Close else. "// Verifica se o trade esperado eh Venda (SHORT)

                                      } //DailyBGSV

                                   } // DayPosition

                                } // MID.1

                             } //CTC.1

                          } //CTO

                        //Show Line with Range on Current Chart
                        if(ObjectCreate(0,"HLINE_Range",OBJ_HLINE,0,0,50000))
                          {
                           MySet[x].RangeLineObj=true;
                           //--- set line color
                           ObjectSetInteger(0,"HLINE_Range",OBJPROP_COLOR,clrGold);
                          }
                        if(MySet[x].RangeLineObj) ObjectMove(0,"HLINE_Range",0,0,MySet[x].RangeLevel);

                       } // else related to [if ( RangeCurrent > MySet[x].Range && MySet[x].Trade_Status == "WAITING" ) ]

                    } // TradeType BSP_BOP.

                  //=============================================================================
                  // TradeType: OVER_UNDER ==== Check Entry signal and previous order request OVER_UNDER
                  //=============================================================================
                  else if(MySet[x].TradeType=="OVER_UNDER" && MySet[x].Trade_Status!="FINISHED" && /*MySet[x].Trade_Status != "STARTED" &&*/ MySet[x].EntryOrder_Status!="REJECTED")
                    {
                     // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                     // Ordem de Entrada - STATUS (REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED)
                     //Print("OnTick| TradeID:",MySet[x].TradeID," newBar: ",newBar," |barShift: ",barShift," |MySet[x].EntryBar: ",MySet[x].EntryBar," |Daily_BarCounter: ",MySet[x].Daily_BarCounter," |MySet[x].EntryOrder_Price: ",MySet[x].EntryOrder_Price );

                     //Print("OnTick| TradeID:",MySet[x].TradeID," |OVER_UNDER. rates[0].time: ",TimeToString(rates[0].time, TIME_MINUTES), "|TimeCurrent: ",TimeToString( TimeCurrent(), TIME_MINUTES) );

                     //Check last position status
                     if(MySet[x].EntryOrder_Status=="" && (MySet[x].glBuyPlaced==true || MySet[x].glSellPlaced==true) && (MySet[x].EntryOrder_type!="DEAL_TYPE_BUY" || MySet[x].EntryOrder_type!="DEAL_TYPE_SELL"))
                       {
                        Print("OnTick| TradeID:",MySet[x].TradeID," |OVER_UNDER: Posicao encerrada. Reiniciando as flags.");
                        MySet[x].glBuyPlaced=false;
                        MySet[x].glSellPlaced=false;
                        //glOrderPlacedWaitingReturn = false; MySet[x].EntryOrder_Status == "PLACED"
                        //Position_lastchecked_status = MySet[x].EntryOrder_Status;
                       }
                     //Abre primeria posicao do dia
                     else if(TimeToString(TimeCurrent(),TIME_MINUTES)>="09:01" && MySet[x].Daily_BarCounter==1 && MySet[x].EntryOrder_Price==0)
                       {
                        Print("Abre a posicao do dia.");

                        //Check if price is Over or Under the daily open
                        if(rates[0].close>Daily[0].open) // Pirce is over opening
                          {
                           MySet[x].TradeDirection="LONG";
                           MySet[x].EntryOrder_Price=rates[0].close-Slippage;
                          }
                        else if(rates[0].close<Daily[0].open) // Pirce is under opening
                          {
                           MySet[x].TradeDirection="SHORT";
                           MySet[x].EntryOrder_Price=rates[0].close+Slippage;
                          }
                        Print("OnTick| TradeID:",MySet[x].TradeID," |BSP_BOP. Base:",MySet[x].BaseBSPBOP," |Sentido do trade: ",MySet[x].BSP_BOP," |TradeDirection: ",MySet[x].TradeDirection," |LastBarCTO: ",LastBarBody," |EntryPoint: ",MySet[x].EntryOrder_Price);

                       }
                     //PROXIMO PASSO, VERIFICAR SE INVERTE O TRADE OU FICA POSICIONADO
                     else if(barShift==1 && MySet[x].EntryOrder_Price!=0 && (MySet[x].EntryOrder_Status=="FILLED" || MySet[x].EntryOrder_Status=="PARTIAL"))
                       {

                        //MySet[x].FixedVolume = MySet[x].FixedVolume;

                        Print("OnTick| TradeID:",MySet[x].TradeID," |OVER_UNDER. LastBarTime:",MySet[x].LastBar_Time," |DailyFactor: ",DailyFactor);

                        if(MySet[x].EntryOrder_type=="DEAL_TYPE_BUY" && rates[0].close<DailyOpen)
                          {

                           // Restart Trade variables. Reverter posicao
                           //Reinicia variaveis de MoneyManagement
                           MySet[x].OrderSize=0;

                           //Reinicia variaveis de controle de trade realizado no dia
                           MySet[x].Trade_Status = "WAITING";
                           MySet[x].glPlaceOrder = false;
                           MySet[x].glOrderPlaced= false;
                           MySet[x].glOrderexecuted=false;
                           MySet[x].glBuyPlaced=false;
                           MySet[x].glSellPlaced=false;
                           MySet[x].glTargetOrderPlaced=false;
                           MySet[x].glStopOrderPlaced=false;

                           //Reinicia variaveis de controle de ordens
                           MySet[x].EntryOrder_OrderNumber=0;

                           //Reinicia variaveis da ordem de entrada
                           MySet[x].EntryOrder_OrderNumber=0;
                           MySet[x].EntryOrder_Status="";
                           MySet[x].EntryOrder_type="";
                           MySet[x].EntryOrder_Volume=0;
                           MySet[x].EntryOrder_VolExec=0;
                           MySet[x].EntryOrder_Price=0;
                           MySet[x].EntryOrder_PriceExec = 0;
                           MySet[x].EntryOrder_StopPrice = 0;

                           Print("OnTick| TradeID:",MySet[x].TradeID," |OVER_UNDER |Variaveis do trade reiniciadas, pronto para proximo sinal!",TimeCurrent());

                           MySet[x].TradeDirection="SHORT";
                           MySet[x].EntryOrder_Price=rates[0].close+Slippage;
                           //MySet[x].EntryOrder_Status = "";
                           //MySet[x].glOrderPlaced = false;
                           //MySet[x].glSellPlaced = false;
                           MySet[x].InvertPosition=true;
                          }
                        else if(MySet[x].EntryOrder_type=="DEAL_TYPE_SELL" && rates[0].close>DailyOpen)
                          {
                           // Restart Trade variables. Continue trading during the day
                           //Reinicia variaveis de MoneyManagement
                           MySet[x].OrderSize=0;

                           //Reinicia variaveis de controle de trade realizado no dia
                           MySet[x].Trade_Status = "WAITING";
                           MySet[x].glPlaceOrder = false;
                           MySet[x].glOrderPlaced= false;
                           MySet[x].glOrderexecuted=false;
                           MySet[x].glBuyPlaced=false;
                           MySet[x].glSellPlaced=false;
                           MySet[x].glTargetOrderPlaced=false;
                           MySet[x].glStopOrderPlaced=false;

                           //Reinicia variaveis de controle de ordens
                           MySet[x].EntryOrder_OrderNumber=0;

                           //Reinicia variaveis da ordem de entrada
                           MySet[x].EntryOrder_OrderNumber=0;
                           MySet[x].EntryOrder_Status="";
                           MySet[x].EntryOrder_type="";
                           MySet[x].EntryOrder_Volume=0;
                           MySet[x].EntryOrder_VolExec=0;
                           MySet[x].EntryOrder_Price=0;
                           MySet[x].EntryOrder_PriceExec = 0;
                           MySet[x].EntryOrder_StopPrice = 0;

                           Print("OnTick| TradeID:",MySet[x].TradeID," |OVER_UNDER |Variaveis do trade reiniciadas, pronto para proximo sinal!",TimeCurrent());

                           MySet[x].TradeDirection="LONG";
                           MySet[x].EntryOrder_Price=rates[0].close-Slippage;
                           //MySet[x].EntryOrder_Status = "";
                           //MySet[x].glOrderPlaced = false;
                           //MySet[x].glBuyPlaced = false;
                           MySet[x].InvertPosition=true;
                          }

                        Print("OnTick| TradeID:",MySet[x].TradeID," |OVER_UNDER. LastBarTime:",MySet[x].LastBar_Time," |LastBarRange: ",MySet[x].CalcBarRange," |CalcBarBody: ",MySet[x].CalcBarBody," |LastBarHigh: ",rates[1].high," |LastBarLow: ",rates[1].low," |Resultado: ",MySet[x].EntryOrder_Price," |StopLoss: ",MySet[x].StopLossPoints);

                       } // if ( barShift == 1 && MySet[x].EntryBar == MySet[x].Daily_BarCounter && MySet[x].EntryOrder_Price == 0 )

                     if(MySet[x].EntryOrder_Status=="" && MySet[x].EntryOrder_Price!=0)
                       { // else related to [if ( RangeCurrent > MySet[x].Range && MySet[x].Trade_Status == "WAITING" ) ]
                        //PlaySound("alert.wav"); // Play Sound as signal that range was stablished on level requested.

                        //Print( "Daily extremes: high "+ (string)Daily[0].high  +" -LastHigh "+ (string)MySet[x].LastDailyHigh  +" - low "+ (string)Daily[0].low +" - LastLow "+ (string)MySet[x].LastDailyLow );

                        //Moment filters
                        //Filtros analisados no momento de entrada do trade

                        // CTO 
                        if(MySet[x].CTO=="" || (MySet[x].CTO=="+" && MySet[x].EntryOrder_Price-DailyOpen>=0) || (MySet[x].CTO=="-" && MySet[x].EntryOrder_Price-DailyOpen<0))
                          {

                           // CTC.1
                           if(MySet[x].CTC1=="" || (MySet[x].CTC1=="+" && MySet[x].EntryOrder_Price-Y_Close>=0) || (MySet[x].CTC1=="-" && MySet[x].EntryOrder_Price-Y_Close<0))
                             {

                              // MID.1 [H+/M+/M-/L-]
                              //if ( StringFind(MySet[x].MID1_Reference,MID1) > -1 )
                              if((StringFind(MySet[x].MID1_Reference,fMID1(MySet[x].EntryOrder_Price,Y_High,Y_Low)))>-1)
                                {

                                 // DayPosition [ABOVE/BELOW/INSIDE/OUTSIDE]
                                 if(StringFind(MySet[x].DayPosition,Current_DayPosition)>-1)
                                   {

                                    // DailyBGSV
                                    if(MySet[x].DailyBGSV=="" || (MySet[x].DailyBGSV=="+" && (Daily[0].high-DailyOpen)>=(DailyOpen-Daily[0].low)) || (MySet[x].DailyBGSV=="-" && (Daily[0].high-DailyOpen)<(DailyOpen-Daily[0].low)))
                                      {

                                       // Verifica se o trade esperado eh Venda (SHORT)
                                       if(MySet[x].TradeDirection=="SHORT") // Vender sempre que alcancar o round above
                                         {

                                          // Verifica se ja existe ordem pendente, no outro extremo da range
                                          if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                          //Informa que precisa enviar Ordem Pendente
                                          MySet[x].glPlaceOrder=true;
                                          MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                          MySet[x].RangeLevel=MySet[x].EntryOrder_Price;  //Identifica o ponto de entrada

                                          Print("OnTick| TradeID:",MySet[x].TradeID," |Entry_SHORT:",(string)MySet[x].RangeLevel," |rates[0].close", rates[0].close );
                                          Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );


                                         } //if ( MySet[x].RangeHighLow == "HIGH" && MySet[x].TradeDirection == "SHORT"  
                                       else if(MySet[x].TradeDirection=="LONG") // Verifica se o trade esperado eh Compra (LONG)
                                         {
                                          // Verifica se ja existe ordem pendente, no outro extremo da range
                                          if(MySet[x].glOrderPlaced) CancelPreviousOrder=true;

                                          //Informa que precisa enviar Ordem Pendente
                                          MySet[x].glPlaceOrder=true;
                                          MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                          MySet[x].RangeLevel=MySet[x].EntryOrder_Price;  //Identifica o ponto onde a Range foi identificada

                                          Print("OnTick| TradeID:",MySet[x].TradeID," |Entry_LONG:",(string)MySet[x].RangeLevel," |rates[0].close:", rates[0].close );
                                          Print("OnTick| TradeID:",MySet[x].TradeID," |Filtros do momemto: CTO",CTO," CTC.1",CTC1," BGSV",BGSV," MID1",MID1," Curr_DayPosition",Current_DayPosition );

                                         } // Close else. "// Verifica se o trade esperado eh Venda (SHORT)

                                      } //DailyBGSV

                                   } // DayPosition

                                } // MID.1

                             } //CTC.1

                          } //CTO

                        //Show Line with Range on Current Chart
                        if(ObjectCreate(0,"HLINE_Range",OBJ_HLINE,0,0,50000))
                          {
                           MySet[x].RangeLineObj=true;
                           //--- set line color
                           ObjectSetInteger(0,"HLINE_Range",OBJPROP_COLOR,clrGold);
                          }
                        if(MySet[x].RangeLineObj) ObjectMove(0,"HLINE_Range",0,0,MySet[x].RangeLevel);

                       } // else related to [if ( RangeCurrent > MySet[x].Range && MySet[x].Trade_Status == "WAITING" ) ]

                    } // TradeType OVER_UNDER.

                  //+------------------------------------------------------------------+
                  //| FIM DAS REGRAS DE TRADE TYPES. NOVOS TRADETYPES, ADICIONAR ACIMA  |
                  //+------------------------------------------------------------------+


                  //Atualiza valores da ultima maxima(high) e minima(low) do dia.
                  MySet[x].LastDailyHigh= Daily[0].high;
                  MySet[x].LastDailyLow = Daily[0].low;
                  MySet[x].LastRange=Daily[0].high-Daily[0].low;

                  //--- create a horizontal line DailyOpen
                  if(ObjectCreate(0,"HLINE_DayOpen",OBJ_HLINE,0,0,50000))
                    {
                     OpenLineObj=true;
                     //--- set line color
                     ObjectSetInteger(0,"HLINE_DayOpen",OBJPROP_COLOR,clrAquamarine);
                    }
                  // Move Line Object for day parameters DailyOpen
                  if(OpenLineObj) ObjectMove(0,"HLINE_DayOpen",0,0,DailyOpen);

                  ////////////////////////////////////////////////////////////////////////////////////////
                  ////////////////////////////////////////////////////////////////////////////////////////
                  //
                  // ORDER MANAGEMENT           ORDER MANAGEMENT           ORDER MANAGEMENT
                  //
                  ////////////////////////////////////////////////////////////////////////////////////////
                  ////////////////////////////////////////////////////////////////////////////////////////

                  //============================================
                  // ORDER PLACED - CHECK CONDITION STILL VALID
                  //============================================

                  if(MySet[x].EntryOrder_Status=="PLACED")
                    {
                     // DayPosition [ABOVE/BELOW/INSIDE/OUTSIDE]
                     if(StringFind(MySet[x].DayPosition,Current_DayPosition)==-1)
                       {
                        CancelPreviousOrder=true;
                       }

                     // DailyBGSV
                     if(( MySet[x].DailyBGSV=="+" && (Daily[0].high-DailyOpen)<(DailyOpen-Daily[0].low)) || (MySet[x].DailyBGSV=="-" && (Daily[0].high-DailyOpen)>(DailyOpen-Daily[0].low)))
                       {
                        CancelPreviousOrder=true;
                       }
                    } // Order Status == PLACED

                  //===============================================
                  //===============================================
                  //  New order required?
                  //  Check if cancel previous order is required
                  //  Check if place order is required
                  //===============================================
                  //===============================================

                  //CancelPreviousOrder
                  if(CancelPreviousOrder)
                    {
                     bool OrderCanceled=Trade.OrderDelete(MySet[x].EntryOrder_OrderNumber);
                     if(OrderCanceled)
                       {
                        Print("OnTick| Ordem Cancelada. Ticket: "+(string)MySet[x].EntryOrder_OrderNumber+" Status: "+(string)OrderCanceled);
                        CancelPreviousOrder=false;
                        MySet[x].glBuyPlaced=false;
                        MySet[x].glSellPlaced=false;
                        MySet[x].glOrderPlaced=false;
                        MySet[x].EntryOrder_Status="REMOVED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                       }
                     else
                       {
                        Print("OnTick| Problema com o cancelamento da ordem!. Order Number: "+(string)MySet[x].EntryOrder_OrderNumber);
                       }
                    } //CancelPreviousOrder

                  //======================================
                  // Place order LONG/SHORT
                  //======================================
                  if(MySet[x].glPlaceOrder==true)
                    {
                     MySet[x].glPlaceOrder=false; // Order placement executed;
                                                  //Print( "PlaceOrder: TradeID:",MySet[x].TradeID," |TradeType: ",MySet[x].TradeType," |TradeDirection:",MySet[x].TradeDirection );
                     MySet[x].TraceWindowInvert=false;
                     // Verifico se foi acionado a janela trace
                     for (int Aux=0;Aux<=(ArraySize(ATraceWindow)-1); Aux++)
                     {
                        if ((MySet[x].Strategy==ATraceWindow[Aux].Strategy) && ATraceWindow[Aux].WindowInvert)
                        {
                           Print("OnTick| A estratégia : " + ATraceWindow[Aux].Strategy + " acionou a janela Trace de inversão de posição nesta data !");                    
                           //Realizo a inversão de posição
                           MySet[x].TraceWindowInvert=true;
                           MySet[x].TradeDirection=(MySet[x].TradeDirection=="LONG")?"SHORT":"LONG";
                        };
                     };
                     //======================================
                     // Money management
                     //======================================
                     double tradeSize;
                     if(MySet[x].UseMoneyManagement==true) tradeSize=MoneyManagement(MySet[x].Ativo_Symbol,MySet[x].FixedVolume,MySet[x].RiskPercent,MySet[x].StopLossPoints);
                     else tradeSize=VerifyVolume(MySet[x].Ativo_Symbol,MySet[x].FixedVolume);
                     MySet[x].OrderSize=tradeSize;
                     // Inverte posicao?
                     if(MySet[x].TradeType=="OVER_UNDER" && MySet[x].InvertPosition==true) MySet[x].OrderSize=tradeSize*2;

                     Print("OnTick| TradeID:",MySet[x].TradeID," MoneyManagement. UseMoneyManagement: ",MySet[x].UseMoneyManagement," |Tradesize:",tradeSize," |Ativo: ",MySet[x].Ativo_Symbol," |FixedVol: ",MySet[x].FixedVolume," |RiskPercent: ",MySet[x].RiskPercent," |StopLoss: ",MySet[x].StopLossPoints);

                     //Verifica se esta posicionado na mesma direcao (Position)
                     if(_OpenSamePosition==false && ((MySet[x].TradeDirection=="LONG" && glBuyPositionOpen==true) || (MySet[x].TradeDirection=="SHORT" && glSellPositionOpen==true)))
                       {
                        MySet[x].Trade_Status="FINISHED";
                        MySet[x].EntryOrder_Status="FINISHED";
                        Print("OnTick| TradeID:",MySet[x].TradeID," |Posicao em aberto na mesma direcao nao permitido. Trade Finalizado.");
                       }

                     //Verifica se ja tem trade na mesma direcao LONG (TRADEID)
                     else if(_OpenTradeSameDirection==false && (MySet[x].TradeDirection=="LONG" && glBuyTradeIDOpen!=""))
                       {
                        MySet[x].Trade_Status="FINISHED";
                        MySet[x].EntryOrder_Status="FINISHED";
                        Print("OnTick| TradeID:",MySet[x].TradeID," |Trade na mesma direcao (LONG) nao permitido. Trade Finalizado. Tradeemaberto: ",glBuyTradeIDOpen);
                       }
                     //Verifica se ja tem trade na mesma direcao SHORT (TRADEID)
                     else if(_OpenTradeSameDirection==false && (MySet[x].TradeDirection=="SHORT" && glSellTradeIDOpen!=""))
                       {
                        MySet[x].Trade_Status="FINISHED";
                        MySet[x].EntryOrder_Status="FINISHED";
                        Print("OnTick| TradeID:",MySet[x].TradeID," |Trade na mesma direcao (SHORT) nao permitido. Trade Finalizado. Tradeemaberto: ",glSellTradeIDOpen);
                       }

                     //======================================
                     // Place order - LONG
                     //======================================
                     //if ( (  MySet[x].NewRangeHighLow == "LOW" && MySet[x].RangeHighLow == "LOW" && MySet[x].TradeDirection == "LONG") ||  (MySet[x].NewRangeHighLow == "HIGH" && MySet[x].RangeHighLow == "HIGH" && MySet[x].TradeDirection == "LONG") )
                     else if(( MySet[x].TradeType=="HIGHLOW" && MySet[x].TradeDirection=="LONG") || 
                        (MySet[x].TradeType=="RANGE" && ((MySet[x].NewRangeHighLow=="LOW" && MySet[x].RangeHighLow=="LOW" && MySet[x].TradeDirection=="LONG") || (MySet[x].NewRangeHighLow=="HIGH" && MySet[x].RangeHighLow=="HIGH" && MySet[x].TradeDirection=="LONG"))) || 
                        //( MySet[x].TradeType == "QUANTTREND" && MySet[x].TradeDirection == "LONG" ) ||
                        ( MySet[x].TradeType == "ROUNDN"  && MySet[x].TradeDirection == "LONG" ) ||
                        ( MySet[x].TradeType == "THIRSTY"  && MySet[x].TradeDirection == "LONG" ) ||
                        ( MySet[x].TradeType == "LASTBAR"  && MySet[x].TradeDirection == "LONG" ) ||
                        ( MySet[x].TradeType == "TIMEENTRY"  && MySet[x].TradeDirection == "LONG" ) ||
                        ( MySet[x].TradeType == "BSP_BOP"  && MySet[x].TradeDirection == "LONG" ) ||
                        ( MySet[x].TradeType == "OVER_UNDER"  && MySet[x].TradeDirection == "LONG" ) ||
                        ( MySet[x].TradeType == "RRETREAT"  && MySet[x].TradeDirection == "LONG" )
                        )
                          {
                           // Open pending buy order
                           //Print("111, glBuyPlaced",MySet[x].glBuyPlaced," |glOrderPlaced",MySet[x].glOrderPlaced);
                           if(MySet[x].glBuyPlaced==false && MySet[x].glOrderPlaced==false)
                             {
                              double orderPrice;
                              if(MySet[x].TradeType=="RRETREAT")
                                {
                                 orderPrice=MySet[x].RRetreat_point;
                                }
                              else
                                {
                                 orderPrice=MySet[x].RangeLevel;
                                }

                              //glBuyPlaced = Trade.BuyLimit(_Symbol,tradeSize,RangeLevel,0,0,0,NULL);  // Limit Order
                              MySet[x].glOrderPlaced=MySet[x].glBuyPlaced;
                              //glBuyPlaced = Trade.Buy(_Symbol,tradeSize);  // Market Order

                              // Classe CTrade referente a entradas LONG(Buy)
                              //--- additions methods
                              //bool  Buy(const double volume,const string symbol=NULL,double price=0.0,const double sl=0.0,const double tp=0.0,const string comment="");
                              //bool  Sell(const double volume,const string symbol=NULL,double price=0.0,const double sl=0.0,const double tp=0.0,const string comment="");
                              //bool  BuyLimit(const double volume,const double price,const string symbol=NULL,const double sl=0.0,const double tp=0.0,
                              //                           const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");
                              //bool  BuyStop(const double volume,const double price,const string symbol=NULL,const double sl=0.0,const double tp=0.0,
                              //                          const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");
                              //bool  SellLimit(const double volume,const double price,const string symbol=NULL,const double sl=0.0,const double tp=0.0,
                              //                            const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");
                              //bool  SellStop(const double volume,const double price,const string symbol=NULL,const double sl=0.0,const double tp=0.0,
                              //                           const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");

                              // Stop Loss para a colocacao da ordem de entrada
                              //double buyStop = BuyStopLoss(_Symbol,StopLoss,orderPrice);
                              // Take Profit devemos substituir por Pending order "na pedra" para garantir a execuÃ§Ã£o no valor exato que queremos sair com lucro
                              //double buyProfit = BuyTakeProfit(_Symbol,TakeProfit,orderPrice);

                              //Template original com ordem BuyStop
                              //glBuyPlaced = Trade.BuyStop(_Symbol,tradeSize,orderPrice,buyStop,buyProfit);

                              string OrderCommentary;
                              if( MySet[x].EntryOrder_OrderType == 0 ) OrderCommentary = "E.Buy@"+MySet[x].TradeID;     // EntryOrder_OrderType == 0 AtMarket
                              if( MySet[x].EntryOrder_OrderType == 1 ) OrderCommentary = "E.BuyLmt@"+MySet[x].TradeID;  // EntryOrder_OrderType == 1 Limit 
                              //Incluo a estrategia nos comentários para recupeção na janela de Trace
                              //Acionou a Janela trace, se sim insere *S, senão *N - para ser 
                              OrderCommentary += (MySet[x].TraceWindowInvert)?"*S":"*N";
                              //Insiro o nome da estratégia
                              OrderCommentary += "S>" + (string)MySet[x].Strategy;                                                                                                                        //Print("11111, EntryOrder_OrderType:",MySet[x].EntryOrder_OrderType);
                              if(MySet[x].EntryOrder_OrderType==0) // 0 == AtMarket ordens
                                {
                                 MySet[x].glBuyPlaced=Trade.Buy(MySet[x].OrderSize,MySet[x].Ativo_Symbol,0,0,0,OrderCommentary);
                                 //Print( "OnTick| Envia ordem do tipo Buy(",MySet[x].OrderSize,",",MySet[x].Ativo_Symbol,",",",",0,",",0,",",0,",",OrderCommentary );
                                }
                              else
                                {
                                 MySet[x].glBuyPlaced=Trade.BuyLimit(MySet[x].OrderSize,orderPrice,MySet[x].Ativo_Symbol,0,0,Quant_type_time,0,OrderCommentary);
                                 Print("OnTick| Envia ordem do tipo BuyLimit(",MySet[x].OrderSize,",",orderPrice,",",MySet[x].Ativo_Symbol,",",0,",",0,",",Quant_type_time,",",0,",",OrderCommentary);
                                 MySet[x].EntryOrder_Price=orderPrice; // ordem Limit, executa a ordem no valor exato da ordem.
                                }

                              MySet[x].glOrderPlaced=MySet[x].glBuyPlaced;

                              if(MySet[x].glBuyPlaced==true)
                                {
                                 // Atualiza flags das posicoes de trade
                                 if(glSellPositionOpen==true)
                                   {
                                    glSellPositionOpen = false;
                                    glBuyPositionOpen  = false;
                                    Print("OnTick| TradeID: ",MySet[x].TradeID," |Flag de direcao do trade atualizado: BuyPosition: ",glBuyPositionOpen," |SellPosition: ",glSellPositionOpen);
                                   }
                                 else
                                   {
                                    glBuyPositionOpen=true;
                                    Print("OnTick| TradeID: ",MySet[x].TradeID," |Flag de direcao do trade atualizado: BuyPosition: ",glBuyPositionOpen);
                                   }

                                 MySet[x].glSellPlaced=false;
                                 Trade.Request(TradeRequest);
                                 Trade.Result(TradeResult);
                                 MySet[x].EntryOrder_OrderNumber=Trade.ResultOrder();

                                 // Solicita o valor da ordem, caso ainda nao tenha o valor executado.
                                 if(MySet[x].EntryOrder_OrderType==0) // 0 == AtMarket ordens
                                   {
                                    //MySet[x].EntryOrder_Price = Trade.ResultPrice();
                                    //Print( "OnTick| TradeID: ",MySet[x].TradeID," |Preco da ordem Mkt: ",MySet[x].EntryOrder_Price );
                                   }
                                 else
                                   {
                                    //MySet[x].EntryOrder_Price = Trade.ResultPrice();
                                    //Print( "OnTick| TradeID: ",MySet[x].TradeID," |Preco da ordem Lmt: ",MySet[x].EntryOrder_Price );
                                   }

                                 MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                 MySet[x].EntryOrder_type="";
                                 MySet[x].EntryOrder_Volume=MySet[x].OrderSize;
                                 Print("OnTick| TradeID:",MySet[x].TradeID," |ResultPrice: ",MySet[x].EntryOrder_PriceExec);

                                 Print("OnTick| Ordem enviada. Ordem# "+(string)MySet[x].EntryOrder_OrderNumber+" |Resultado: "+(string)MySet[x].glBuyPlaced+" Codigo de Retorno: "+(string)Trade.CheckResultRetcode()+" / "+Trade.CheckResultRetcodeDescription());
                                 Print("OnTick| ResultVolume: "+(string)Trade.ResultVolume());
                                 Print("OnTick| TradeID:"+MySet[x].TradeID+".Entry Order Price: "+(string)MySet[x].EntryOrder_Price);

                                 //Aviso sonoro de colocacao da ordem
                                 //PlaySound("RIMMER.wav");
                                 bool OrdSelected;

                                 OrdSelected=OrderSelect(MySet[x].EntryOrder_OrderNumber);
                                 //if ( OrderSelect(MySet[x].EntryOrder_OrderNumber) )
                                 if(MySet[x].EntryOrder_OrderNumber!=0)
                                   {
                                    Order_State=OrderGetInteger(ORDER_STATE);
                                    MySet[x].Trade_Status="PLACED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                                    Print("OnTick| Status da Ordem# "+(string)MySet[x].EntryOrder_OrderNumber+" | "+MySet[x].Trade_Status+" | "+EnumToString(ENUM_ORDER_STATE(Order_State)));
                                    // Guarda o TradeID da ordem LONG
                                    glBuyTradeIDOpen=MySet[x].TradeID;
                                    Print("OnTick| Parametro glBuyTradeIDOpen atualizado. TradeID: ",glBuyTradeIDOpen);

                                   }
                                 else(Print("OnTick| Ordem nao encontrada. Numero da ordem pesquisada: "+(string)MySet[x].EntryOrder_OrderNumber));

                                 //// Imprime informacoes do trade
                                 //  		Print("OnTick| EntryOrder Placement: TradeStatus: "
                                 //  		+(string)MySet[x].Range+"\r\n"
                                 //        +"RangeHighAction "+(string)MySet[x].RangeHighAction+"\r\n"
                                 //        +"RangeHighAction "+(string)MySet[x].RangeHighAction+"\r\n"
                                 //        +"EarlyOrder_Distance "+(string)MySet[x].EarlyOrder_Distance+"\r\n"
                                 //        +"glBuyPlaced "+(string)MySet[x].glBuyPlaced+"\r\n"
                                 //        +"glSellPlaced "+(string)MySet[x].glSellPlaced+"\r\n"
                                 //        +"glPlaceOrder "+(string)MySet[x].glPlaceOrder+"\r\n"
                                 //        +"glOrderPlaced "+(string)MySet[x].glOrderPlaced+"\r\n"
                                 //        +"glOrderexecuted "+(string)MySet[x].glOrderexecuted+"\r\n"
                                 //        +"glTargetOrderPlaced "+(string)MySet[x].glTargetOrderPlaced+"\r\n"
                                 //        +"glStopOrderPlaced "+(string)MySet[x].glStopOrderPlaced+"\r\n"
                                 //        +"RangeLineObj "+(string)MySet[x].RangeLineObj+"\r\n"
                                 //        +"RangeHitDay "+(string)MySet[x].RangeHitDay+"\r\n"
                                 //        +"RangeHighLow "+(string)MySet[x].RangeHighLow+"\r\n"
                                 //        +"RangeLevel "+(string)MySet[x].RangeLevel+"\r\n"
                                 //        +"RangeHit "+(string)MySet[x].RangeHit+"\r\n"
                                 //        +"LastDailyHigh "+(string)MySet[x].LastDailyHigh+"\r\n"
                                 //        +"LastDailyLow "+(string)MySet[x].LastDailyLow+"\r\n"
                                 //        +"OrderSize "+(string)MySet[x].OrderSize+"\r\n"
                                 //        +"PosicaoAtual "+(string)MySet[x].PosicaoAtual+"\r\n"
                                 //        +"EntryOrder_OrderNumber "+(string)MySet[x].EntryOrder_OrderNumber+"\r\n"
                                 //        +"EntryOrder_OrderNumber "+(string)MySet[x].EntryOrder_OrderNumber+"\r\n"
                                 //        +"EntryOrder_Status "+(string)MySet[x].EntryOrder_Status+"\r\n"
                                 //        +"EntryOrder_type "+(string)MySet[x].EntryOrder_type+"\r\n"
                                 //        +"EntryOrder_Volume "+(string)MySet[x].EntryOrder_Volume+"\r\n"
                                 //        +"EntryOrder_VolExec "+(string)MySet[x].EntryOrder_VolExec+"\r\n"
                                 //        +"EntryOrder_Price "+(string)MySet[x].EntryOrder_Price+"\r\n"
                                 //        +"EntryOrder_StopPrice "+(string)MySet[x].EntryOrder_StopPrice+"\r\n"
                                 //        +"TargetTicketNumber "+(string)MySet[x].TargetTicketNumber+"\r\n"
                                 //        +"TgtOrder_OrderNumber "+(string)MySet[x].TgtOrder_OrderNumber+"\r\n"
                                 //        +"TgtOrder_Status "+(string)MySet[x].TgtOrder_Status+"\r\n"
                                 //        +"TgtOrder_type "+(string)MySet[x].TgtOrder_type+"\r\n"
                                 //        +"TgtOrder_Volume "+(string)MySet[x].TgtOrder_Volume+"\r\n"
                                 //        +"TgtOrder_VolExec "+(string)MySet[x].TgtOrder_VolExec+"\r\n"
                                 //        +"TgtOrder_Price "+(string)MySet[x].TgtOrder_Price+"\r\n"
                                 //        +"StopLossTicketNumber "+(string)MySet[x].StopLossTicketNumber+"\r\n"
                                 //        +"StopOrder_OrderNumber "+(string)MySet[x].StopOrder_OrderNumber+"\r\n"
                                 //        +"StopOrder_Status "+(string)MySet[x].StopOrder_Status+"\r\n"
                                 //        +"StopOrder_type "+(string)MySet[x].StopOrder_type+"\r\n"
                                 //        +"StopOrder_Volume "+(string)MySet[x].StopOrder_Volume+"\r\n"
                                 //        +"StopOrder_VolExec "+(string)MySet[x].StopOrder_VolExec+"\r\n"
                                 //        +"StopOrder_Price "+(string)MySet[x].StopOrder_Price+"\r\n"
                                 //        +"Trade_Status"+(string)MySet[x].Trade_Status+"\r\n"
                                 //        );

                                } //if(MySet[x].glBuyPlaced == true)
                              else
                                {
                                 MySet[x].EntryOrder_OrderNumber=Trade.ResultOrder();
                                 Print("OnTick| TradeID[",MySet[x].TradeID,"] Entry Order:",MySet[x].EntryOrder_OrderNumber," RetCode:",Trade.CheckResultRetcode());
                                 if(Trade.CheckResultRetcode()==10006) // RetCode 10006 == "REJECTED"
                                   {
                                    MySet[x].EntryOrder_Status="REJECTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                                           //MySet[x].Trade_Status = "FINISHED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                                    Print("OnTick| TradeID:",MySet[x].TradeID," |ResultRetCode: ",Trade.CheckResultRetcode());
                                    Print("OnTick| Ordem REJEITADA. Ordem# "+(string)MySet[x].EntryOrder_OrderNumber+" |Resultado: "+(string)MySet[x].glBuyPlaced+" Codigo de Retorno: "+(string)Trade.CheckResultRetcode()+" / "+Trade.CheckResultRetcodeDescription());
                                    //PlaySound("stops.wav");
                                   }
                                 else
                                   {
                                    Print("OnTick| TradeID:",MySet[x].TradeID," Envio da ordem FALHOU. EntryOrder_OrderType: ",MySet[x].EntryOrder_OrderType);
                                   }

                                }
                             } // Open pending buy order
                          } //Place order - LONG

                        //======================================
                        // Place Order - SHORT
                        //======================================
                        //if ( ( MySet[x].NewRangeHighLow == "LOW" && MySet[x].RangeHighLow == "LOW" && MySet[x].TradeDirection == "SHORT") ||  (MySet[x].NewRangeHighLow == "HIGH" && MySet[x].RangeHighLow == "HIGH" && MySet[x].TradeDirection == "SHORT") )
                        //Print( "PlaceOrder: TradeID:",MySet[x].TradeID," |TradeType: ",MySet[x].TradeType," |TradeDirection:",MySet[x].TradeDirection );

                        else if(( MySet[x].TradeType=="HIGHLOW" && MySet[x].TradeDirection=="SHORT") || 
                           (MySet[x].TradeType=="RANGE" && ((MySet[x].NewRangeHighLow=="LOW" && MySet[x].RangeHighLow=="LOW" && MySet[x].TradeDirection=="SHORT") || (MySet[x].NewRangeHighLow=="HIGH" && MySet[x].RangeHighLow=="HIGH" && MySet[x].TradeDirection=="SHORT"))) || 
                           //( MySet[x].TradeType == "QUANTTREND" && MySet[x].TradeDirection == "SHORT" ) ||
                           ( MySet[x].TradeType == "ROUNDN"  && MySet[x].TradeDirection == "SHORT" ) ||
                           ( MySet[x].TradeType == "THIRSTY"  && MySet[x].TradeDirection == "SHORT" ) ||
                           ( MySet[x].TradeType == "LASTBAR"  && MySet[x].TradeDirection == "SHORT" ) ||
                           ( MySet[x].TradeType == "TIMEENTRY"  && MySet[x].TradeDirection == "SHORT" ) ||
                           ( MySet[x].TradeType == "BSP_BOP"  && MySet[x].TradeDirection == "SHORT" ) ||
                           ( MySet[x].TradeType == "OVER_UNDER"  && MySet[x].TradeDirection == "SHORT" ) ||
                           ( MySet[x].TradeType == "RRETREAT"  && MySet[x].TradeDirection == "SHORT" )
                           )
                             {

                              // Open sell order
                              //Print("222, glBuyPlaced",MySet[x].glBuyPlaced," |glOrderPlaced",MySet[x].glOrderPlaced);

                              if(MySet[x].glSellPlaced==false && MySet[x].glOrderPlaced==false)
                                {
                                 double orderPrice;
                                 if(MySet[x].TradeType=="RRETREAT")
                                   {
                                    orderPrice=MySet[x].RRetreat_point;
                                   }
                                 else
                                   {
                                    orderPrice=MySet[x].RangeLevel;
                                   }

                                 //orderPrice = AdjustBelowStopLevel(_Symbol,orderPrice);

                                 // Stop Loss para a colocacao da ordem de entrada
                                 //double sellStop = SellStopLoss(_Symbol,StopLoss,orderPrice);
                                 // Take Profit devemos substituir por Pending order "na pedra" para garantir a execuÃ§Ã£o no valor exato que queremos sair com lucro
                                 //double sellProfit = SellTakeProfit(_Symbol,TakeProfit,orderPrice);

                                 //Template original com ordem SellStop
                                 //glSellPlaced = Trade.SellLimit(_Symbol,tradeSize,RangeLevel,0,0,0,NULL);
                                 //Template original com ordem SellStop
                                 //glSellPlaced = Trade.SellStop(_Symbol,tradeSize,orderPrice,sellStop,sellProfit);

                                 string OrderCommentary;
                                 if( MySet[x].EntryOrder_OrderType == 0 ) OrderCommentary = "E.Sell@"+MySet[x].TradeID;     // EntryOrder_OrderType == 0 AtMarket
                                 if( MySet[x].EntryOrder_OrderType == 1 ) OrderCommentary = "E.SellLmt@"+MySet[x].TradeID;  // EntryOrder_OrderType == 1 Limit 
                                 //Incluo a estrategia nos comentários para recupeção na janela de Trace
                                 //Acionou a Janela trace, se sim insere *S, senão *N - para ser 
                                 OrderCommentary += (MySet[x].TraceWindowInvert)?"*S":"*N";
                                 Print("String de envio para inversao de janela:" + MySet[x].TraceWindowInvert);
                                 //Insiro o nome da estratégia
                                 OrderCommentary += "S>" + (string)MySet[x].Strategy;                                                                                                                        //Print("11111, EntryOrder_OrderType:",MySet[x].EntryOrder_OrderType);
                                 if(MySet[x].EntryOrder_OrderType==0) // 0 == AtMarket ordens
                                   {
                                    MySet[x].glSellPlaced=Trade.Sell(MySet[x].OrderSize,MySet[x].Ativo_Symbol,0,0,0,OrderCommentary);
                                    //Print( "OnTick| Envia ordem do tipo Sell(",MySet[x].OrderSize,",",MySet[x].Ativo_Symbol,",",0,",",0,",",Quant_type_time,",",0,",",OrderCommentary );

                                   }
                                 else
                                   {
                                    MySet[x].glSellPlaced=Trade.SellLimit(MySet[x].OrderSize,orderPrice,MySet[x].Ativo_Symbol,0,0,Quant_type_time,0,OrderCommentary);
                                    Print("OnTick| Envia ordem do tipo SellLimit(",MySet[x].OrderSize,",",orderPrice,",",MySet[x].Ativo_Symbol,",",0,",",0,",",Quant_type_time,",",0,",",OrderCommentary);
                                    MySet[x].EntryOrder_Price=orderPrice; // ordem Limit, executa a ordem no valor exato da ordem.
                                   }

                                 MySet[x].glOrderPlaced=MySet[x].glSellPlaced;

                                 if(MySet[x].glSellPlaced==true)
                                   {
                                    // Atualiza flags das posicoes de trade
                                    if(glBuyPositionOpen==true)
                                      {
                                       glSellPositionOpen = false;
                                       glBuyPositionOpen  = false;
                                       Print("OnTick| TradeID: ",MySet[x].TradeID," |Flag de direcao do trade atualizado: SellPosition: ",glSellPositionOpen," |BuyPosition: ",glBuyPositionOpen);

                                      }
                                    else
                                      {
                                       glSellPositionOpen=true;
                                       Print("OnTick| TradeID: ",MySet[x].TradeID," |Flag de direcao do trade atualizado: SellPosition: ",glSellPositionOpen);
                                      }

                                    MySet[x].glBuyPlaced=false;
                                    Trade.Request(TradeRequest);
                                    Trade.Result(TradeResult);
                                    MySet[x].EntryOrder_OrderNumber=Trade.ResultOrder();

                                    // Solicita o valor da ordem, caso ainda nao tenha o valor executado.
                                    if(MySet[x].EntryOrder_OrderType==0) // 0 == AtMarket ordens
                                      {
                                       //MySet[x].EntryOrder_Price = Trade.ResultPrice();
                                       //Print( "OnTick| TradeID: ",MySet[x].TradeID," |Preco da ordem Mkt: ",MySet[x].EntryOrder_Price );
                                      }
                                    else
                                      {
                                       //MySet[x].EntryOrder_Price = Trade.ResultPrice();
                                       //Print( "OnTick| TradeID: ",MySet[x].TradeID," |Preco da ordem Lmt: ",MySet[x].EntryOrder_Price );
                                      }

                                    MySet[x].EntryOrder_Status="REQUESTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED )
                                    MySet[x].EntryOrder_type="";
                                    MySet[x].EntryOrder_Volume=MySet[x].OrderSize;

                                    Print("OnTick| TradeID:"+MySet[x].TradeID+" .Ordem de ENTRADA enviada. Ordem# "+(string)MySet[x].EntryOrder_OrderNumber+" Resultado: "+(string)MySet[x].glSellPlaced +" Codigo de Retorno: "+ (string)Trade.CheckResultRetcode()+" / "+ Trade.CheckResultRetcodeDescription());
                                    Print("OnTick| TradeID:"+MySet[x].TradeID+".ResultVolume: "+ (string)Trade.ResultVolume());
                                    Print("OnTick| TradeID:"+MySet[x].TradeID+".Order Price: "+ (string)MySet[x].EntryOrder_Price);

                                    //Aviso sonoro de colocacao da ordem
                                    //PlaySound("RIMMER.wav");

                                    bool OrdSelected;

                                    OrdSelected=OrderSelect(MySet[x].EntryOrder_OrderNumber);
                                    //if ( OrderSelect(MySet[x].EntryOrder_OrderNumber) )
                                    if(MySet[x].EntryOrder_OrderNumber!=0)
                                      {
                                       Order_State=OrderGetInteger(ORDER_STATE);
                                       MySet[x].Trade_Status="PLACED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                                       Print("OnTick| TradeID:"+MySet[x].TradeID+".Status da Ordem# "+(string)MySet[x].EntryOrder_OrderNumber+" | "+EnumToString(ENUM_ORDER_STATE(Order_State)));
                                       // Guarda o TradeID da ordem SHORT
                                       glSellTradeIDOpen=MySet[x].TradeID;
                                       Print("OnTick| Parametro glSellTradeIDOpen atualizado. TradeID: ",glSellTradeIDOpen);

                                      }
                                    else(Print("OnTick| TradeID:"+MySet[x].TradeID+".Ordem nao encontrada. Numero da ordem pesquisada: "+(string)MySet[x].EntryOrder_OrderNumber));

                                    //OrderGetInteger(ORDER_MAGIC);

                                    //// Imprime informacoes do trade
                                    //  		Print("OnTick| EntryOrder Placement: Range@"+(string)MySet[x].Range+"\r\n"
                                    //        +"RangeHighAction: "+(string)MySet[x].RangeHighAction+"\r\n"
                                    //        +"RangeHighAction: "+(string)MySet[x].RangeHighAction+"\r\n"
                                    //        +"EarlyOrder_Distance: "+(string)MySet[x].EarlyOrder_Distance+"\r\n"
                                    //        +"glBuyPlaced: "+(string)MySet[x].glBuyPlaced+"\r\n"
                                    //        +"glSellPlaced: "+(string)MySet[x].glSellPlaced+"\r\n"
                                    //        +"glPlaceOrder: "+(string)MySet[x].glPlaceOrder+"\r\n"
                                    //        +"glOrderPlaced: "+(string)MySet[x].glOrderPlaced+"\r\n"
                                    //        +"glOrderexecuted: "+(string)MySet[x].glOrderexecuted+"\r\n"
                                    //        +"glTargetOrderPlaced: "+(string)MySet[x].glTargetOrderPlaced+"\r\n"
                                    //        +"glStopOrderPlaced: "+(string)MySet[x].glStopOrderPlaced+"\r\n"
                                    //        +"RangeLineObj: "+(string)MySet[x].RangeLineObj+"\r\n"
                                    //        +"RangeHitDay: "+(string)MySet[x].RangeHitDay+"\r\n"
                                    //        +"RangeHighLow: "+(string)MySet[x].RangeHighLow+"\r\n"
                                    //        +"RangeLevel: "+(string)MySet[x].RangeLevel+"\r\n"
                                    //        +"RangeHit: "+(string)MySet[x].RangeHit+"\r\n"
                                    //        +"LastDailyHigh: "+(string)MySet[x].LastDailyHigh+"\r\n"
                                    //        +"LastDailyLow: "+(string)MySet[x].LastDailyLow+"\r\n"
                                    //        +"OrderSize: "+(string)MySet[x].OrderSize+"\r\n"
                                    //        +"PosicaoAtual: "+(string)MySet[x].PosicaoAtual+"\r\n"
                                    //        +"EntryOrder_OrderNumber: "+(string)MySet[x].EntryOrder_OrderNumber+"\r\n"
                                    //        +"EntryOrder_OrderNumber: "+(string)MySet[x].EntryOrder_OrderNumber+"\r\n"
                                    //        +"EntryOrder_Status: "+(string)MySet[x].EntryOrder_Status+"\r\n"
                                    //        +"EntryOrder_type: "+(string)MySet[x].EntryOrder_type+"\r\n"
                                    //        +"EntryOrder_Volume: "+(string)MySet[x].EntryOrder_Volume+"\r\n"
                                    //        +"EntryOrder_VolExec: "+(string)MySet[x].EntryOrder_VolExec+"\r\n"
                                    //        +"EntryOrder_Price: "+(string)MySet[x].EntryOrder_Price+"\r\n"
                                    //        +"EntryOrder_StopPrice: "+(string)MySet[x].EntryOrder_StopPrice+"\r\n"
                                    //        +"TargetTicketNumber: "+(string)MySet[x].TargetTicketNumber+"\r\n"
                                    //        +"TgtOrder_OrderNumber: "+(string)MySet[x].TgtOrder_OrderNumber+"\r\n"
                                    //        +"TgtOrder_Status: "+(string)MySet[x].TgtOrder_Status+"\r\n"
                                    //        +"TgtOrder_type: "+(string)MySet[x].TgtOrder_type+"\r\n"
                                    //        +"TgtOrder_Volume: "+(string)MySet[x].TgtOrder_Volume+"\r\n"
                                    //        +"TgtOrder_VolExec: "+(string)MySet[x].TgtOrder_VolExec+"\r\n"
                                    //        +"TgtOrder_Price: "+(string)MySet[x].TgtOrder_Price+"\r\n"
                                    //        +"StopLossTicketNumber: "+(string)MySet[x].StopLossTicketNumber+"\r\n"
                                    //        +"StopOrder_OrderNumber: "+(string)MySet[x].StopOrder_OrderNumber+"\r\n"
                                    //        +"StopOrder_Status: "+(string)MySet[x].StopOrder_Status+"\r\n"
                                    //        +"StopOrder_type: "+(string)MySet[x].StopOrder_type+"\r\n"
                                    //        +"StopOrder_Volume: "+(string)MySet[x].StopOrder_Volume+"\r\n"
                                    //        +"StopOrder_VolExec: "+(string)MySet[x].StopOrder_VolExec+"\r\n"
                                    //        +"StopOrder_Price: "+(string)MySet[x].StopOrder_Price+"\r\n"
                                    //        +"Trade_Status: "+(string)MySet[x].Trade_Status+"\r\n"
                                    //        );


                                   } //if(MySet[x].glSellPlaced == true)
                                 else
                                   {
                                    MySet[x].EntryOrder_OrderNumber=Trade.ResultOrder();
                                    Print("OnTick| TradeID[",MySet[x].TradeID,"] Entry Order:",MySet[x].EntryOrder_OrderNumber," RetCode:",Trade.CheckResultRetcode());
                                    if(Trade.CheckResultRetcode()==10006) // RetCode 10006 == "REJECTED"
                                      {
                                       MySet[x].EntryOrder_Status="REJECTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                                              //MySet[x].Trade_Status = "FINISHED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                                       Print("OnTick| TradeID:",MySet[x].TradeID," |ResultRetCode: ",Trade.CheckResultRetcode());
                                       Print("OnTick| Ordem REJEITADA. Ordem# "+(string)MySet[x].EntryOrder_OrderNumber+" |Resultado: "+(string)MySet[x].glBuyPlaced+" Codigo de Retorno: "+(string)Trade.CheckResultRetcode()+" / "+Trade.CheckResultRetcodeDescription());
                                       //PlaySound("stops.wav");
                                      }
                                    else
                                      {
                                       Print("OnTick| TradeID:",MySet[x].TradeID," Envio da ordem FALHOU. EntryOrder_OrderType: ",MySet[x].EntryOrder_OrderType);
                                      }

                                   }
                                } // Open sell order
                              else
                                {
                                 //Print("OnTick| TradeID:",MySet[x].TradeID," Envio da ordem FALHOU. EntryOrder_OrderType: ", MySet[x].EntryOrder_OrderType ) ;
                                }

                             } // Place Order - SHORT
                           else
                             {
                              //Print ("OnTick| TradeID:",MySet[x].TradeID," |Envio da ordem FALHOU. PlaceOrder");
                             }

                    } // Place order LONG/SHORT

                 } // Order placement end

               //Atualiza valores da ultima maxima(high) e minima(low) do dia.
               MySet[x].LastDailyHigh= Daily[0].high;
               MySet[x].LastDailyLow = Daily[0].low;
               MySet[x].LastRange=Daily[0].high-Daily[0].low;

               //============================================================================
               // Entry Order executed - Trade started - Trailing Stop
               //============================================================================

               //SYMBOL_POINT
               //AJUSTAR PARA ATUALIZAR TRAILINGSTOP EM CASOS ONDE NAO HA POSICAO EM ABERTO. pode haver casos de operacoes que se anulem, mas o trailing tem que seguir avancado.

               //Print("OnTick| Verificando Trailing Stop: MySet[x].EntryOrder_Status:"+MySet[x].EntryOrder_Status+" MySet[x].Trade_Status:"+MySet[x].Trade_Status+". " );
               //if( MySet[x].UseTrailingStop == true && PositionGetInteger(POSITION_TYPE) != -1 )
               if(MySet[x].UseTrailingStop==true)
                 {
                  if(( MySet[x].EntryOrder_Status=="PARTIAL" || MySet[x].EntryOrder_Status=="FILLED") && (MySet[x].StopOrder_Status=="PLACED" && MySet[x].TgtOrder_Status=="PLACED") && MySet[x].Trade_Status=="STARTED" && MySet[x].Trade_Status!="FINISHED")
                    {
                     //if( MySet[x].EntryOrder_PriceExec > 0 )
                     if(MySet[x].EntryOrder_Price>0)
                       {
                        //Print("OnTick| TradeID:",MySet[x].TradeID,". Chamando TrailingStop. Symbol:"+MySet[x].Ativo_Symbol+"  EntryOrder_Number:"+(string)MySet[x].EntryOrder_OrderNumber+"  StopOrder_Number:"+(string)MySet[x].StopOrder_OrderNumber+"  TrailingStop:"+(string)MySet[x].TrailingStop+"  MinimunProfit:"+(string)MySet[x].MinimumProfit+"  Step:"+(string)MySet[x].Step+"" );
                        //double currentStop = HistoryOrderGetDouble(MySet[x].StopOrder_OrderNumber, ORDER_PRICE_OPEN);
                        double currentStop=MySet[x].StopOrder_Price;
                        double StopAfterTrailing=currentStop;
                        //Print("OnTick| TradeID:",MySet[x].TradeID,". Preco da EntryOrder: "+ (string)MySet[x].EntryOrder_Price +" |openPrice:"+MySet[x].EntryOrder_Price+" Preco da ordem Stop: "+(string)MySet[x].StopOrder_Price );
                        //Print("OnTick| openPrice: "+(string)MySet[x].EntryOrder_Price+" currentStop: "+ (string)currentStop);
                        StopAfterTrailing=Trail.QTV_TrailingStop(MySet[x].Ativo_Symbol,MySet[x].TradeDirection,MySet[x].EntryOrder_OrderNumber,MySet[x].EntryOrder_Price,MySet[x].StopOrder_OrderNumber,MySet[x].StopOrder_Price,MySet[x].TrailingStop,MySet[x].MinimumProfit,MySet[x].Step);

                        //MySet[x].StopOrder_OrderNumber = Trade.ResultOrder();
                        //Print( "OnTick| TradeID[",MySet[x].TradeID,"] Stop Order:",MySet[x].StopOrder_OrderNumber," RetCode:",Trade.CheckResultRetcode() );

                        if(Trade.CheckResultRetcode()==10006) // RetCode 10006 == "REJECTED"
                          {
                           MySet[x].StopOrder_Status="REJECTED"; // Ordem Stop - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                                 //MySet[x].Trade_Status = "FINISHED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                           Print("OnTick| TradeID:",MySet[x].TradeID," |ResultRetCode: ",Trade.CheckResultRetcode() );
                           Print("OnTick| TradeID:",MySet[x].TradeID," Ordem REJEITADA ao ajustar TrailingStop. Ordem# "+(string)MySet[x].StopOrder_OrderNumber+" |Resultado: "+(string)MySet[x].glBuyPlaced +" Codigo de Retorno: "+(string)Trade.CheckResultRetcode()+" / "+ Trade.CheckResultRetcodeDescription());
                           //PlaySound("stops.wav");
                           //PlaySound("RIMMER.wav");
                          }
                        else
                          {
                           //Print("OnTick| TradeID:",MySet[x].TradeID," Envio da ordem FALHOU. StopOrder_type: ", MySet[x].StopOrder_type ) ;
                          }

                        //Print("OnTick| TradeID:",MySet[x].TradeID,". StopAfterTrailing: ",StopAfterTrailing," currentStop: ",currentStop);
                        if(StopAfterTrailing!=currentStop && StopAfterTrailing!=-1)
                          {
                           MySet[x].StopOrder_Price=StopAfterTrailing;
                           Print("OnTick| TradeID:",MySet[x].TradeID,". New Stop: ",StopAfterTrailing," Old Stop: ",currentStop);
                           //Aviso sonoro de colocacao da ordem
                           //PlaySound("wait.wav");
                          }
                       } // if( MySet[x].EntryOrder_Price > 0 )
                     else
                       {
                        //Print( "OnTick| TradeID:",MySet[x].TradeID,". Verificar o Preco da entrada. OpenPrice:",MySet[x].EntryOrder_Price );
                        Print("OnTick| TradeID:",MySet[x].TradeID,". Verificar o Preco da entrada. OpenPrice:",MySet[x].EntryOrder_PriceExec);
                       }
                    } // if (  ( MySet[x].EntryOrder_Status == "PARTIAL" || MySet[x].EntryOrder_Status == "FILLED" ) && ( MySet[x].StopOrder_Status == "PLACED" && MySet[x].TgtOrder_Status == "PLACED"  ) && MySet[x].Trade_Status == "STARTED" && MySet[x].Trade_Status != "FINISHED" )
                 } // if( MySet[x].UseTrailingStop == true )

               //       //======================================
               //      	// Break even -  "By the book"
               //      	//======================================
               //      	if(UseBreakEven == true && PositionType(MySet[x].Ativo_Symbol) != -1)
               //      	{
               //      		Trail.BreakEven(_Symbol,BreakEvenProfit,LockProfit);
               //      	}
               //      
               //       //======================================
               //      	// Trailing stop -  "By the book"
               //      	//======================================
               //      	if(UseTrailingStop == true && PositionType(MySet[x].Ativo_Symbol) != -1)
               //      	{
               //      		Trail.TrailingStop(MySet[x].Ativo_Symbol,TrailingStop,MinimumProfit,Step);
               //      	}




               //===========================================================================
               // Entry Order executed - Trade started - Place Start and Stop orders
               //===========================================================================
               //if (MySet[x].glOrderPlaced && MySet[x].Trade_Status != "FINISHED" )
               //Print("OnTick| Colcoar ordens de tgt e stop: MySet[x].EntryOrder_Status:"+MySet[x].EntryOrder_Status+" MySet[x].Trade_Status:"+MySet[x].Trade_Status+". " );
               if(( MySet[x].EntryOrder_Status=="PARTIAL" || MySet[x].EntryOrder_Status=="FILLED") && MySet[x].Trade_Status=="STARTED" && MySet[x].Trade_Status!="FINISHED" && MySet[x].TradeType!="OVER_UNDER")
                 {
                  //Print("OnTick| Colocar ordens de tgt e stop: MySet[x].EntryOrder_VolExec:"+MySet[x].EntryOrder_VolExec+" MySet[x].EntryOrder_Volume:"+MySet[x].EntryOrder_Volume+" MySet[x].TgtOrder_Volume:"+MySet[x].TgtOrder_Volume );

                  //if ( OrdExec_triggered == true && OrdExec_OrderNumber == MySet[x].EntryOrder_OrderNumber && MySet[x].TgtOrder_Volume < MySet[x].EntryOrder_Volume  )  // glOrderexecuted = true 
                  if(MySet[x].EntryOrder_VolExec>0 && MySet[x].EntryOrder_VolExec<=MySet[x].EntryOrder_Volume && MySet[x].TgtOrder_Volume<MySet[x].EntryOrder_VolExec && (MySet[x].glTargetOrderPlaced==false || (MySet[x].TargetTicketNumber!=0 && MySet[x].TgtOrder_Status=="PLACED")))
                    {

                     //Print("OnTick| TradeID:"+MySet[x].TradeID+". EntryOrder executed "+ (string)MySet[x].EntryOrder_OrderNumber +", type "+(string)MySet[x].EntryOrder_type+" at price: "+(string)MySet[x].EntryOrder_Price+"! Request Target and Stop orders. Volume: "+(string)MySet[x].EntryOrder_VolExec );
                     Print("OnTick| TradeID:"+MySet[x].TradeID+". EntryOrder executed "+(string)MySet[x].EntryOrder_OrderNumber+", type "+(string)MySet[x].EntryOrder_type+" at price: "+(string)MySet[x].EntryOrder_PriceExec+"! Request Target and Stop orders. Volume: "+(string)MySet[x].EntryOrder_VolExec);
                     //Aviso sonoro de execucao da ordem
                     //PlaySound("request.wav");

                     MySet[x].glOrderexecuted=OrdExec_triggered;
                     OrdExec_triggered=false;
                     //MySet[x].Trade_Status = "STARTED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)

                     // Ajusta quantidade das ordens
                     //if ( OrdExec_Volume > MySet[x].EntryOrder_Volume ) OrdExec_Volume = OrdExec_Volume / 2;
                     double RequestVolume=MySet[x].EntryOrder_VolExec;
                     //OrdExec_Volume = 0;
                     Print("OnTick| TradeID:"+MySet[x].TradeID+".TgtOrder_Volume: "+(string)RequestVolume);
                     Print("OnTick| TradeID:"+MySet[x].TradeID+".MySet[x].EntryOrder_type: "+MySet[x].EntryOrder_type );

                     // Dados da conta
                     //Print( "AccountInfo/ ACCOUNT_BALANCE: "+(string)AccountInfoDouble(ACCOUNT_BALANCE) );
                     //Print( "AccountInfo/ ACCOUNT_CREDIT: "+(string)AccountInfoDouble(ACCOUNT_CREDIT) );
                     //Print( "AccountInfo/ ACCOUNT_PROFIT: "+(string)AccountInfoDouble(ACCOUNT_PROFIT) );
                     //Print( "AccountInfo/ ACCOUNT_EQUITY: "+(string)AccountInfoDouble(ACCOUNT_EQUITY) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN: "+(string)AccountInfoDouble(ACCOUNT_MARGIN) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_FREE: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_FREE) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_LEVEL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_LEVEL) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_SO_CALL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_SO_SO: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_SO_SO) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_INITIAL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_INITIAL) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_MAINTENANCE: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE) );
                     //Print( "AccountInfo/ ACCOUNT_ASSETS: "+(string)AccountInfoDouble(ACCOUNT_ASSETS) );
                     //Print( "AccountInfo/ ACCOUNT_LIABILITIES: "+(string)AccountInfoDouble(ACCOUNT_LIABILITIES) );
                     //Print( "AccountInfo/ ACCOUNT_COMMISSION_BLOCKED: "+(string)AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED) );


                     //============
                     // ADD TARGET ORDER
                     //============
                     if(MySet[x].EntryOrder_type=="DEAL_TYPE_BUY")
                       {
                        //--- TARGET ---
  
                        //Print("Ontick| Prepara envio da ordem Target. Preco da ordem de entrada: ",MySet[x].EntryOrder_Price," |Preco Target: ",MySet[x].EntryOrder_Price+MySet[x].TakeProfit );
                        //double buyProfit = BuyTakeProfit(MySet[x].Ativo_Symbol,MySet[x].TakeProfit,MySet[x].EntryOrder_Price);
                        double buyProfit=BuyTakeProfit(MySet[x].Ativo_Symbol,MySet[x].TakeProfitPoints,MySet[x].EntryOrder_PriceExec);
  
  
                        //Calculo o ZSCore para Take Profit caso não tenha sido calculado via percentual
                        if(MySet[x].TakeProfit_PercRange==0) // Prioriza o Take baseado em percentual da Range
                        {                                                                          
                            Print("OnTick| TradeID:",MySet[x].TradeID,". Valor do Take Profit em ZSCore: "+(string)MySet[x].TakeProfit+" | Em Pontos: " + (string)buyProfit);
                        
                        }                         
                        
                        MySet[x].TgtOrder_type="SELL";
                        MySet[x].TgtOrder_Price=buyProfit;
                        //Print("Ontick| Target. Preço da ordem de entrada: ",MySet[x].EntryOrder_Price," |Preço Target: ",MySet[x].TgtOrder_Price );

                        //Print("OnTick| TradeID:"+MySet[x].TradeID+" .Verifica se ordem target ja existe, e solicita o cancelamento. Ordem:"+(string)MySet[x].TargetTicketNumber+" com status:"+MySet[x].TgtOrder_Status);
                        if(MySet[x].TargetTicketNumber!=0 && MySet[x].TgtOrder_Status=="PLACED") // Ordem Target ja existe
                          {
                           //CancelOrder - Target Order to entre with new volume 
                           Print("OnTick| TradeID: ",MySet[x].TradeID," | TgtTicketNumber: ",MySet[x].TargetTicketNumber," |TgtOrder_Status: ",MySet[x].TgtOrder_Status);
                           bool OrderCanceled=Trade.OrderDelete(MySet[x].TargetTicketNumber);
                           if(OrderCanceled)
                             {
                              Print("OnTick| TradeID:"+MySet[x].TradeID+".Ordem Cancelada Target - MOTIVO: Ajuste do volume. Ticket: "+(string)MySet[x].TargetTicketNumber);
                             }
                           else
                             {
                              Print("OnTick| TradeID:"+MySet[x].TradeID+".Problema com o cancelamento da ordem TARGET!. Order Number: "+(string)MySet[x].TargetTicketNumber);
                             }

                          }

                        string OrderCommentary;
                        if(MySet[x].TradeType=="RANGE") OrderCommentary="T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType=="HIGHLOW") OrderCommentary="T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        //else if (MySet[x].TradeType == "QUANTTREND") OrderCommentary = "T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "TIMEENTRY")  OrderCommentary = "T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "RRETREAT")   OrderCommentary = "T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "THIRSTY")    OrderCommentary = "T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "LASTBAR")    OrderCommentary = "T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "BSP_BOP")    OrderCommentary = "T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "OVER_UNDER")    OrderCommentary = "T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else OrderCommentary="T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        //Incluo a estrategia nos comentários para recupeção na janela de Trace
                        //Acionou a Janela trace, se sim insere *S, senão *N - para ser 
                        OrderCommentary += (MySet[x].TraceWindowInvert)?"*S":"*N";
                        //Insiro o nome da estratégia
                        OrderCommentary += "S>" + (string)MySet[x].Strategy;                                                                                                                        //Print("11111, EntryOrder_OrderType:",MySet[x].EntryOrder_OrderType);

                        //bool  SellLimit(const double volume,const double price,const string symbol=NULL,const double sl=0.0,const double tp=0.0,
                        //                            const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");
                        //MySet[x].glTargetOrderPlaced = Trade.SellLimit(RequestVolume,MySet[x].TgtOrder_Price,MySet[x].Ativo_Symbol,0,0,Quant_type_time,0,OrderCommentary );
                        //Print( "OnTick| TradeID:",MySet[x].TradeID,". Ordem Target solicitada. TgtOrder_Volume: "+(string)RequestVolume+".MySet[x].EntryOrder_type: "+MySet[x].EntryOrder_type );

                        //                        // CHECK ORDERTYPE FOR TARGET ORDERS
                        //                        string OrderCommentary;
                        //                        if( MySet[x].TgtOrder_OrderType == 0 ) OrderCommentary = "Tgt f/Ord:"+MySet[x].TradeID;  // TgtOrder_OrderType == 0 AtMarket
                        //                        if( MySet[x].TgtOrder_OrderType == 1 ) OrderCommentary = "Tgt f/Ord:"+MySet[x].TradeID;  // TgtOrder_OrderType == 1 Limit 
                        //                        
                        //                        //Print("11111, EntryOrder_OrderType:",MySet[x].EntryOrder_OrderType);
                        //                        
                        //                        if( MySet[x].TgtOrder_OrderType == 0 ) // 0 == AtMarket ordens
                        //                        {
                        //                           MySet[x].glTargetOrderPlaced = Trade.Sell(RequestVolume,MySet[x].Ativo_Symbol,0,0,0,OrderCommentary );
                        //                           //Print( "OnTick| Envia ordem target tipo Sell(",RequetVolume,",",MySet[x].Ativo_Symbol,",",",",0,",",0,",",0,",",OrderCommentary );
                        //                           Print( "OnTick| TradeID:",MySet[x].TradeID,". Ordem Target solicitada. TgtOrder_Volume: "+(string)RequestVolume+".MySet[x].EntryOrder_type: "+MySet[x].EntryOrder_type );
                        //
                        //                        }
                        //                        else
                        //                        {
                        MySet[x].glTargetOrderPlaced=Trade.SellLimit(RequestVolume,MySet[x].TgtOrder_Price,MySet[x].Ativo_Symbol,0,0,Quant_type_time,0,OrderCommentary);
                        Print("OnTick| Envia ordem target tipo SellLimit(",RequestVolume,",",MySet[x].TgtOrder_Price,",",MySet[x].Ativo_Symbol,",",0,",",0,",",Quant_type_time,",",0,",",OrderCommentary);
                        Print("OnTick| TradeID:",MySet[x].TradeID,". Ordem Target solicitada. TgtOrder_Volume: "+(string)RequestVolume+".MySet[x].EntryOrder_type: "+MySet[x].EntryOrder_type);
                        //                        }
                        //                        // end CHECK ORDERTYPE FOR TARGET ORDERS




                       } // ADD TARGET ORDER // if ( MySet[x].EntryOrder_type == "DEAL_TYPE_BUY" )
                     else
                       {

                        //--- TARGET ---
                        
                        //double sellProfit = SellTakeProfit(MySet[x].Ativo_Symbol,MySet[x].TakeProfit,MySet[x].EntryOrder_Price );
                        double sellProfit=SellTakeProfit(MySet[x].Ativo_Symbol,MySet[x].TakeProfitPoints,MySet[x].EntryOrder_PriceExec);

                        //Calculo o ZSCore para Take Profit caso não tenha sido calculado via percentual
                        if(MySet[x].TakeProfit_PercRange==0) // Prioriza o Take baseado em percentual da Range
                        {                                                                          
                           Print("OnTick| TradeID:",MySet[x].TradeID,". Valor do Take Profit em ZSCore: "+(string)MySet[x].TakeProfit+" | Em Pontos: " + (string)sellProfit);
                        }   

                        MySet[x].TgtOrder_type="BUY";
                        MySet[x].TgtOrder_Price=sellProfit;

                        //Print("OnTick| TradeID:"+MySet[x].TradeID+".Verifica se ordem target ja existe, e solicita o cancelamento. Ordem:"+(string)MySet[x].TargetTicketNumber+" com status:"+MySet[x].TgtOrder_Status);
                        if(MySet[x].TargetTicketNumber!=0 && MySet[x].TgtOrder_Status=="PLACED") // Ordem Target ja existe
                          {
                           //CancelOrder - Target Order to entre with new volume 
                           bool OrderCanceled=Trade.OrderDelete(MySet[x].TargetTicketNumber);
                           if(OrderCanceled)
                             {
                              Print("OnTick| TradeID:"+MySet[x].TradeID+".Ordem Cancelada Target - MOTIVO: Ajuste do volume. Ticket: "+(string)MySet[x].TargetTicketNumber);
                             }
                           else
                             {
                              Print("OnTick| TradeID:"+MySet[x].TradeID+".Problema com o cancelamento da ordem TARGET!. Order Number: "+(string)MySet[x].TargetTicketNumber);
                             }

                          }

                        string OrderCommentary;
                        if(MySet[x].TradeType=="RANGE") OrderCommentary="T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType=="HIGHLOW") OrderCommentary="T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        //else if (MySet[x].TradeType == "QUANTTREND") OrderCommentary = "T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "TIMEENTRY")  OrderCommentary = "T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "RRETREAT")   OrderCommentary = "T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "THIRSTY")   OrderCommentary = "T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "LASTBAR")   OrderCommentary = "T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "BSP_BOP")   OrderCommentary = "T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "OVER_UNDER")   OrderCommentary = "T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else OrderCommentary="T:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        //Incluo a estrategia nos comentários para recupeção na janela de Trace
                        //Acionou a Janela trace, se sim insere *S, senão *N - para ser 
                        OrderCommentary += (MySet[x].TraceWindowInvert)?"*S":"*N";
                        //Insiro o nome da estratégia
                        OrderCommentary += "S>" + (string)MySet[x].Strategy;                                                                                                                        //Print("11111, EntryOrder_OrderType:",MySet[x].EntryOrder_OrderType);

                        //bool  BuyLimit(const double volume,const double price,const string symbol=NULL,const double sl=0.0,const double tp=0.0,
                        //                           const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");
                        MySet[x].glTargetOrderPlaced=Trade.BuyLimit(RequestVolume,MySet[x].TgtOrder_Price,MySet[x].Ativo_Symbol,0,0,Quant_type_time,0,OrderCommentary);
                        Print("OnTick| TradeID:",MySet[x].TradeID,". Ordem Target solicitada. TgtOrder_Volume: "+(string)RequestVolume+".MySet[x].EntryOrder_type: "+MySet[x].EntryOrder_type);

                       } // ADD TARGET ORDER

                     if(MySet[x].glTargetOrderPlaced==true) // target order placed?
                       {

                        MySet[x].TargetTicketNumber=Trade.ResultOrder();
                        Trade.Request(TradeRequest);
                        Trade.Result(TradeResult);
                        MySet[x].TgtOrder_OrderNumber=MySet[x].TargetTicketNumber;
                        MySet[x].TgtOrder_Volume=TradeRequest.volume;
                        MySet[x].TgtOrder_VolExec=0;

                        Print("OnTick| TradeID:"+MySet[x].TradeID+".Ordem de TARGET enviada. Ordem# "+(string)MySet[x].TargetTicketNumber+" Resultado: "+(string)MySet[x].glTargetOrderPlaced +" Codigo de Retorno: "+ (string)Trade.CheckResultRetcode()+" / "+ Trade.CheckResultRetcodeDescription());
                        Print("OnTick| TradeID:"+MySet[x].TradeID+".ResultVolume: "+ (string)Trade.ResultVolume());
                        Print("OnTick| TradeID:"+MySet[x].TradeID+".ResultPrice: "+ (string)Trade.ResultPrice());
                        Print("OnTick| TradeID:"+MySet[x].TradeID+".TARGEtPrice: "+ (string)MySet[x].TgtOrder_Price);

                       } // target order placed?
                     else
                       {
                        MySet[x].TargetTicketNumber=Trade.ResultOrder();
                        Print("OnTick| TradeID[",MySet[x].TradeID,"] Target Order:",MySet[x].TargetTicketNumber," RetCode:",Trade.CheckResultRetcode());

                        if(Trade.CheckResultRetcode()==10006) // RetCode 10006 == "REJECTED"
                          {
                           MySet[x].TgtOrder_Status="REJECTED"; // Ordem Target - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                                //MySet[x].Trade_Status = "FINISHED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                           Print("OnTick| TradeID:",MySet[x].TradeID," |ResultRetCode: ",Trade.CheckResultRetcode());
                           Print("OnTick| Ordem REJEITADA. Ordem# "+(string)MySet[x].TargetTicketNumber+" |Resultado: "+(string)MySet[x].glBuyPlaced+" Codigo de Retorno: "+(string)Trade.CheckResultRetcode()+" / "+Trade.CheckResultRetcodeDescription());
                           //PlaySound("stops.wav");
                          }
                        else
                          {
                           //Target Order falhou o envio
                           Print("OnTick| TradeID:",MySet[x].TradeID," Envio da ordem FALHOU. TgtOrder_type: ",MySet[x].TgtOrder_type);
                          }
                       }

                     //============
                     // ADD STOP ORDER
                     //============
                     if(MySet[x].glStopOrderPlaced==false)
                       {
                        //Ajusta volume da ordem STOP
                        MySet[x].StopOrder_Volume=MySet[x].EntryOrder_Volume;

                        if(MySet[x].EntryOrder_type=="DEAL_TYPE_BUY") // Entry order is BUY or SELL?
                          {

                           //--- STOP ---
                           //double buyStop = BuyStopLoss(MySet[x].Ativo_Symbol,MySet[x].StopLoss,MySet[x].EntryOrder_Price);
                           MySet[x].StopLossPoints=MySet[x].StopLossPoints/doubleSYMBOL_POINT;
                           double buyStop=BuyStopLoss(MySet[x].Ativo_Symbol,MySet[x].StopLossPoints,MySet[x].EntryOrder_PriceExec);
                           
                           //Calculo o ZSCore para stop loss caso não tenha sido calculado via percentual
                           if(MySet[x].StopLoss_PercRange==0) // Prioriza o Stop baseado em percentual da Range
                           {                                                                          
                              //Aproveito a mesma função do HIGHLOW para cálculo do ZScore do stop loss
                               Print("OnTick| TradeID:",MySet[x].TradeID,". Valor do Buy Stop em ZSCore: "+(string)MySet[x].StopLoss+" | Em Pontos: " + (string)buyStop);
                           
                           } 

                           MySet[x].StopOrder_Price= buyStop;
                           MySet[x].StopOrder_type = "SELL";

                           string OrderCommentary;
                           if(MySet[x].TradeType=="RANGE") OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType=="HIGHLOW") OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           //else if (MySet[x].TradeType == "QUANTTREND") OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "TIMEENTRY")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "RRETREAT")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "THIRSTY")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "LASTBAR")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "BSP_BOP")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "OVER_UNDER")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           //Incluo a estrategia nos comentários para recupeção na janela de Trace
                           //Acionou a Janela trace, se sim insere *S, senão *N - para ser 
                           OrderCommentary += (MySet[x].TraceWindowInvert)?"*S":"*N";
                           //Insiro o nome da estratégia
                           OrderCommentary += "S>" + (string)MySet[x].Strategy;                                                                                                                        //Print("11111, EntryOrder_OrderType:",MySet[x].EntryOrder_OrderType);
                        //bool  SellStop(const double volume,const double price,const string symbol=NULL,const double sl=0.0,const double tp=0.0,
                           //                           const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");

                           MySet[x].glStopOrderPlaced=Trade.SellStop(MySet[x].StopOrder_Volume,MySet[x].StopOrder_Price,MySet[x].Ativo_Symbol,0,0,Quant_type_time,0,OrderCommentary);
                           Print("OnTick| TradeID:",MySet[x].TradeID,". Ordem Stop solicitada. StpOrder_Volume: "+(string)MySet[x].StopOrder_Volume+" |StopOrder_Price: ",MySet[x].StopOrder_Price,".MySet[x].EntryOrder_type: "+MySet[x].EntryOrder_type);

                          } // Entry order is BUY or SELL?
                        else
                          {

                           //--- STOP ---
                           //double sellStop = SellStopLoss(MySet[x].Ativo_Symbol,MySet[x].StopLoss,MySet[x].EntryOrder_Price);
                           MySet[x].StopLossPoints=MySet[x].StopLossPoints/doubleSYMBOL_POINT;
                           double sellStop=SellStopLoss(MySet[x].Ativo_Symbol,MySet[x].StopLossPoints,MySet[x].EntryOrder_PriceExec);
                           
                           //Calculo o ZSCore para stop loss caso não tenha sido calculado via percentual
                           if(MySet[x].StopLoss_PercRange==0) // Prioriza o Stop baseado em percentual da Range
                           {                                                                          
                               Print("OnTick| TradeID:",MySet[x].TradeID,". Valor do Sell Stop em ZSCore: "+(string)MySet[x].StopLoss+" | Em Pontos: " + (string)sellStop);                          
                           }                            
                           
                           MySet[x].StopOrder_Price= sellStop;
                           MySet[x].StopOrder_type = "BUY";

                           string OrderCommentary;
                           if(MySet[x].TradeType=="RANGE") OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType=="HIGHLOW") OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           //else if (MySet[x].TradeType == "QUANTTREND") OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "TIMEENTRY")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "RRETREAT")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "THIRSTY")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "LASTBAR")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "BSP_BOP")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "OVER_UNDER")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           //Incluo a estrategia nos comentários para recupeção na janela de Trace
                           //Acionou a Janela trace, se sim insere *S, senão *N - para ser 
                           OrderCommentary += (MySet[x].TraceWindowInvert)?"*S":"*N";
                           //Insiro o nome da estratégia
                           OrderCommentary += "S>" + (string)MySet[x].Strategy;                                                                                                                        //Print("11111, EntryOrder_OrderType:",MySet[x].EntryOrder_OrderType);

                           //bool  BuyStop(const double volume,const double price,const string symbol=NULL,const double sl=0.0,const double tp=0.0,
                           //                          const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");
                           MySet[x].glStopOrderPlaced=Trade.BuyStop(MySet[x].StopOrder_Volume,MySet[x].StopOrder_Price,MySet[x].Ativo_Symbol,0,0,Quant_type_time,0,OrderCommentary);
                           Print("OnTick| TradeID:",MySet[x].TradeID,". Ordem Stop solicitada. StpOrder_Volume: "+(string)MySet[x].StopOrder_Volume+" |StopOrder_Price: ",MySet[x].StopOrder_Price,".MySet[x].EntryOrder_type: "+MySet[x].EntryOrder_type);

                          } // Entry order is BUY or SELL?

                        if(MySet[x].glStopOrderPlaced==true) // Stop order placed?
                          {

                           MySet[x].StopLossTicketNumber=Trade.ResultOrder();
                           Trade.Request(TradeRequest);
                           Trade.Result(TradeResult);
                           MySet[x].StopOrder_OrderNumber=MySet[x].StopLossTicketNumber;
                           MySet[x].StopOrder_VolExec=0;
                           Trade.ResultPrice();

                           Print("OnTick| TradeID:"+MySet[x].TradeID+".Ordem de STOP enviada. Ordem# "+(string)MySet[x].StopLossTicketNumber+" Resultado: "+(string)MySet[x].glStopOrderPlaced +" Codigo de Retorno: "+ (string)Trade.CheckResultRetcode()+" / "+ Trade.CheckResultRetcodeDescription());
                           Print("OnTick| TradeID:"+MySet[x].TradeID+".ResultVolume: "+ (string)Trade.ResultVolume());
                           Print("OnTick| TradeID:"+MySet[x].TradeID+".ResultPrice: "+ (string)Trade.ResultPrice());
                           Print("OnTick| TradeID:"+MySet[x].TradeID+".Stop  Price: "+ (string)MySet[x].StopOrder_Price);

                          }// Stop order placed?
                        else
                          {
                           MySet[x].StopLossTicketNumber=Trade.ResultOrder();
                           Print("OnTick| TradeID[",MySet[x].TradeID,"] Stop Order:",MySet[x].StopLossTicketNumber," RetCode:",Trade.CheckResultRetcode());
                           if((string)Trade.CheckResultRetcode()=="10006") // RetCode 10006 == "REJECTED"
                             {
                              MySet[x].StopOrder_Status="REJECTED"; // Ordem Stop - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                                    //MySet[x].Trade_Status = "FINISHED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                              Print("OnTick| TradeID:",MySet[x].TradeID," |ResultRetCode: ",Trade.CheckResultRetcode());
                              Print("OnTick| Ordem REJEITADA. Ordem# "+(string)MySet[x].StopLossTicketNumber+" |Resultado: "+(string)MySet[x].glBuyPlaced+" Codigo de Retorno: "+(string)Trade.CheckResultRetcode()+" / "+Trade.CheckResultRetcodeDescription());
                              //PlaySound("stops.wav");
                             }
                           else
                             {
                              //Stop Order falhou o envio
                              Print("OnTick| TradeID:",MySet[x].TradeID," Envio da ordem FALHOU. StopOrder_OrderType: ",MySet[x].StopOrder_type);
                             }

                          }
                       } // ADD STOP ORDER 			

                    }

                 }  // Order Entry Executed - Trade Started

               //======================================
               // Entry Order Rejected - Finish trade
               //======================================

               if(MySet[x].Trade_Status=="WAITING" && MySet[x].EntryOrder_Status=="REJECTED")
                 {
                  // Finaliza o trade
                  MySet[x].Trade_Status="FINISHED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED) Trade Chegou ao fim // Stop Executado. Trade encerrado
                                                     // Atualiza flags das posicoes de trade
                  if(MySet[x].TradeDirection=="LONG")
                    {
                     glBuyPositionOpen=false;
                     Print("OnTick| TradeID: ",MySet[x].TradeID," | Trade Compra Finalizado |Flag de direcao do trade atualizado: BuyPosition: ",glBuyPositionOpen," |SellPosition: ",glSellPositionOpen);
                    }
                  else if(MySet[x].TradeDirection=="SHORT")
                    {
                     glSellPositionOpen=false;
                     Print("OnTick| TradeID: ",MySet[x].TradeID," | Trade Venda Finalizado |Flag de direcao do trade atualizado: BuyPosition: ",glBuyPositionOpen," |SellPosition: ",glSellPositionOpen);
                    }

                  //MySet[x].TgtOrder_Status = "CANCELED";
                  //OrdExec_triggered = false;
                  //OrdExec_Volume = 0; // Zera a quantidade no controle de execucacao
                  Print("OnTick| TradeID:"+MySet[x].TradeID+".Ordem Entry REJEITADA. Trade finalizado. Ticket: "+(string)MySet[x].EntryOrder_OrderNumber);
                  //PlaySound("request.wav");

                 }

               //======================================
               // Target Order Rejected - Finish trade
               //======================================
               if(MySet[x].Trade_Status=="STARTED" && MySet[x].TgtOrder_Status=="REJECTED")
                 {
                  // Verifica se tem ordem stop e solicita o cancelamento
                  if(MySet[x].StopOrder_Status!="CANCELED")
                    {
                     bool OrderCanceled=Trade.OrderDelete(MySet[x].StopLossTicketNumber);
                     if(OrderCanceled)
                       {
                        //MySet[x].Trade_Status = "FINISHED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                        //MySet[x].StopOrder_Status = "CANCELED";
                        //OrdExec_triggered = false;
                        //OrdExec_Volume = 0; // Zera a quantidade no controle de execucacao
                        Print("OnTick| TradeID:"+MySet[x].TradeID+".Ordem STOP Ajustada - Target Atingido e executado Parcialmente. Ticket: "+(string)MySet[x].StopLossTicketNumber);
                       }
                     else
                       {
                        Print("OnTick| TradeID:"+MySet[x].TradeID+".Problema com o cancelamento da ordem STOP!. Order Number: "+(string)MySet[x].StopLossTicketNumber);
                       }

                    }
                  //Envia ordem para a mercado para anular a entrada
                  if(MySet[x].EntryOrder_Status=="PARTIAL" || MySet[x].EntryOrder_Status=="FILLED")
                    {
                     Print("OnTick| TradeID:",MySet[x].TradeID," Enviando ordem a mercado para anular a entrada e finalizar o trade.");

                     if(MySet[x].EntryOrder_type=="DEAL_TYPE_BUY")
                       {
                        //MySet[x].StopOrder_Price = MySet[x].EntryOrder_Price;  // Ajusta Stop para o valor de entrada do Trade, impendindo que o resultado torne-se negativo
                        //MySet[x].StopOrder_type = "SELL";
                        MySet[x].StopOrder_Volume=MySet[x].EntryOrder_VolExec;
                        string OrderCommentary;
                        if(MySet[x].TradeType=="RANGE") OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "HIGHLOW")    OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "QUANTTREND") OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "TIMEENTRY")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "RRETREAT")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "THIRSTY")    OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "LASTBAR")    OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "BSP_BOP")    OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "OVER_UNDER")    OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        //Incluo a estrategia nos comentários para recupeção na janela de Trace
                        //Acionou a Janela trace, se sim insere *S, senão *N - para ser 
                        OrderCommentary += (MySet[x].TraceWindowInvert)?"*S":"*N";
                        //Insiro o nome da estratégia
                        OrderCommentary += "S>" + (string)MySet[x].Strategy;                                                                                                                        //Print("11111, EntryOrder_OrderType:",MySet[x].EntryOrder_OrderType);

                        //bool  SellStop(const double volume,const double price,const string symbol=NULL,const double sl=0.0,const double tp=0.0,
                        //                           const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");
                        MySet[x].glStopOrderPlaced=Trade.Sell(MySet[x].StopOrder_Volume,MySet[x].Ativo_Symbol,0,0,0,OrderCommentary);

                       }
                     else
                       {

                        //MySet[x].StopOrder_Price = MySet[x].EntryOrder_Price;  // Ajusta Stop para o valor de entrada do Trade, impendindo que o resultado torne-se negativo
                        //MySet[x].StopOrder_type = "BUY";
                        MySet[x].StopOrder_Volume=MySet[x].EntryOrder_VolExec;
                        string OrderCommentary;
                        if(MySet[x].TradeType=="RANGE") OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType=="HIGHLOW") OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        //else if (MySet[x].TradeType == "QUANTTREND") OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "TIMEENTRY")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "THIRSTY")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "LASTBAR")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "BSP_BOP")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "OVER_UNDER")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        else if(MySet[x].TradeType == "RRETREAT")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                        //Incluo a estrategia nos comentários para recupeção na janela de Trace
                        //Acionou a Janela trace, se sim insere *S, senão *N - para ser 
                        OrderCommentary += (MySet[x].TraceWindowInvert)?"*S":"*N";
                        //Insiro o nome da estratégia
                        OrderCommentary += "S>" + (string)MySet[x].Strategy;                                                                                                                        //Print("11111, EntryOrder_OrderType:",MySet[x].EntryOrder_OrderType);


                        //bool  BuyStop(const double volume,const double price,const string symbol=NULL,const double sl=0.0,const double tp=0.0,
                        //                          const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");
                        MySet[x].glStopOrderPlaced=Trade.Buy(MySet[x].StopOrder_Volume,MySet[x].Ativo_Symbol,0,0,0,OrderCommentary);

                       }

                     if(MySet[x].glStopOrderPlaced==true)
                       {

                        MySet[x].StopLossTicketNumber=Trade.ResultOrder();
                        Trade.Request(TradeRequest);
                        Trade.Result(TradeResult);
                        MySet[x].StopOrder_OrderNumber=MySet[x].StopLossTicketNumber;
                        MySet[x].StopOrder_VolExec=0;

                        Print("OnTick| TradeID:"+MySet[x].TradeID+".Ordem de Saida enviada. Ordem# "+(string)MySet[x].StopLossTicketNumber+" Resultado: "+(string)MySet[x].glStopOrderPlaced +" Codigo de Retorno: "+ (string)Trade.CheckResultRetcode()+" / "+ Trade.CheckResultRetcodeDescription());
                        Print("OnTick| TradeID:"+MySet[x].TradeID+".ResultVolume: "+ (string)Trade.ResultVolume());
                        Print("OnTick| TradeID:"+MySet[x].TradeID+".ResultPrice: "+ (string)Trade.ResultPrice());
                        Print("OnTick| TradeID:"+MySet[x].TradeID+".Order Price: "+ (string)MySet[x].StopOrder_Price);

                       }

                    }

                  // Finaliza o trade
                  MySet[x].Trade_Status="FINISHED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED) Trade Chegou ao fim // Stop Executado. Trade encerrado
                  if(MySet[x].TradeDirection=="LONG")
                    {
                     glBuyPositionOpen=false;
                     Print("OnTick| TradeID: ",MySet[x].TradeID," | Trade Compra Finalizado |Flag de direcao do trade atualizado: BuyPosition: ",glBuyPositionOpen," |SellPosition: ",glSellPositionOpen);
                    }
                  else if(MySet[x].TradeDirection=="SHORT")
                    {
                     glSellPositionOpen=false;
                     Print("OnTick| TradeID: ",MySet[x].TradeID," | Trade Venda Finalizado |Flag de direcao do trade atualizado: BuyPosition: ",glBuyPositionOpen," |SellPosition: ",glSellPositionOpen);
                    }
                  //MySet[x].TgtOrder_Status = "CANCELED";
                  //OrdExec_triggered = false;
                  //OrdExec_Volume = 0; // Zera a quantidade no controle de execucacao
                  Print("OnTick| TradeID:"+MySet[x].TradeID+".Ordem Target REJEITADA. Trade finalizado. Ticket: "+(string)MySet[x].TgtOrder_OrderNumber);
                  //PlaySound("request.wav");
                 } // Target Order Rejected - Finish trade

               //======================================
               // Entry Order Executed and Target and Stop Order are Running
               //======================================
               //if ( OrdExec_triggered && MySet[x].glOrderPlaced && MySet[x].glOrderexecuted && MySet[x].glTargetOrderPlaced && MySet[x].glStopOrderPlaced && MySet[x].Trade_Status == "STARTED" )
               if(MySet[x].Trade_Status=="STARTED" && MySet[x].glStopOrderPlaced)
                 {

                  //Target Executed?
                  //CancelOrder - Stop Order
                  if((MySet[x].TgtOrder_Status=="PARTIAL" || MySet[x].TgtOrder_Status=="FILLED") && MySet[x].StopOrder_Status!="CANCELED")
                    {

                     // Dados da conta
                     //Print( "AccountInfo/ ACCOUNT_BALANCE: "+(string)AccountInfoDouble(ACCOUNT_BALANCE) );
                     //Print( "AccountInfo/ ACCOUNT_CREDIT: "+(string)AccountInfoDouble(ACCOUNT_CREDIT) );
                     //Print( "AccountInfo/ ACCOUNT_PROFIT: "+(string)AccountInfoDouble(ACCOUNT_PROFIT) );
                     //Print( "AccountInfo/ ACCOUNT_EQUITY: "+(string)AccountInfoDouble(ACCOUNT_EQUITY) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN: "+(string)AccountInfoDouble(ACCOUNT_MARGIN) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_FREE: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_FREE) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_LEVEL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_LEVEL) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_SO_CALL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_SO_SO: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_SO_SO) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_INITIAL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_INITIAL) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_MAINTENANCE: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE) );
                     //Print( "AccountInfo/ ACCOUNT_ASSETS: "+(string)AccountInfoDouble(ACCOUNT_ASSETS) );
                     //Print( "AccountInfo/ ACCOUNT_LIABILITIES: "+(string)AccountInfoDouble(ACCOUNT_LIABILITIES) );
                     //Print( "AccountInfo/ ACCOUNT_COMMISSION_BLOCKED: "+(string)AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED) );


                     // Target Executed PARTIAL?
                     if(MySet[x].TgtOrder_Status=="PARTIAL")
                       {
                        bool OrderCanceled=Trade.OrderDelete(MySet[x].StopLossTicketNumber);
                        if(OrderCanceled)
                          {
                           //Enter new Stop Order with result volume left
                           //============
                           // ADD STOP ORDER
                           //============

                           //Ajusta volume da ordem STOP
                           MySet[x].StopOrder_Volume=MySet[x].TgtOrder_Volume-MySet[x].TgtOrder_VolExec;

                           if(MySet[x].EntryOrder_type=="DEAL_TYPE_BUY")
                             {

                              //--- STOP ---
                              //double buyStop = BuyStopLoss(_Symbol,MySet[x].StopLoss,MySet[x].EntryOrder_Price);

                              // Se o trade nao tiver trailingstop, ajusta Stop para o valor de entrada do Trade, impendindo que o resultado torne-se negativo.
                              if(MySet[x].UseTrailingStop==false)
                                {
                                 //MySet[x].StopOrder_Price = MySet[x].EntryOrder_Price;
                                 MySet[x].StopOrder_Price=MySet[x].EntryOrder_PriceExec;
                                }

                              MySet[x].StopOrder_type="SELL";
                              string OrderCommentary;
                              if(MySet[x].TradeType=="RANGE") OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              else if(MySet[x].TradeType=="HIGHLOW") OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              //else if (MySet[x].TradeType == "QUANTTREND") OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              else if(MySet[x].TradeType == "TIMEENTRY")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              else if(MySet[x].TradeType == "RRETREAT")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              else if(MySet[x].TradeType == "THIRSTY")    OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              else if(MySet[x].TradeType == "LASTBAR")    OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              else if(MySet[x].TradeType == "BSP_BOP")    OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              else if(MySet[x].TradeType == "OVER_UNDER")    OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              else OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              //Incluo a estrategia nos comentários para recupeção na janela de Trace
                              //Acionou a Janela trace, se sim insere *S, senão *N - para ser 
                              OrderCommentary += (MySet[x].TraceWindowInvert)?"*S":"*N";
                              //Insiro o nome da estratégia
                              OrderCommentary += "S>" + (string)MySet[x].Strategy;                                                                                                                        //Print("11111, EntryOrder_OrderType:",MySet[x].EntryOrder_OrderType);

                              //bool  SellStop(const double volume,const double price,const string symbol=NULL,const double sl=0.0,const double tp=0.0,
                              //                           const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");
                              MySet[x].glStopOrderPlaced=Trade.SellStop(MySet[x].StopOrder_Volume,MySet[x].StopOrder_Price,MySet[x].Ativo_Symbol,0,0,Quant_type_time,0,OrderCommentary);

                             }
                           else
                             {

                              //--- STOP ---
                              //double sellStop = SellStopLoss(_Symbol,MySet[x].StopLoss,MySet[x].EntryOrder_Price);

                              // Se o trade nao tiver trailingstop, ajusta Stop para o valor de entrada do Trade, impendindo que o resultado torne-se negativo.
                              if(MySet[x].UseTrailingStop==false)
                                {
                                 //MySet[x].StopOrder_Price = MySet[x].EntryOrder_Price;
                                 MySet[x].StopOrder_Price=MySet[x].EntryOrder_PriceExec;
                                }

                              MySet[x].StopOrder_type="BUY";
                              string OrderCommentary;
                              if(MySet[x].TradeType=="RANGE") OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              else if(MySet[x].TradeType=="HIGHLOW") OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              //else if (MySet[x].TradeType == "QUANTTREND") OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              else if(MySet[x].TradeType == "TIMEENTRY")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              else if(MySet[x].TradeType == "RRETREAT")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              else if(MySet[x].TradeType == "THISRTY")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              else if(MySet[x].TradeType == "LASTBAR")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              else if(MySet[x].TradeType == "BSP_BOP")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              else if(MySet[x].TradeType == "OVER_UNDER")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              else OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                              //Incluo a estrategia nos comentários para recupeção na janela de Trace
                              //Acionou a Janela trace, se sim insere *S, senão *N - para ser 
                              OrderCommentary += (MySet[x].TraceWindowInvert)?"*S":"*N";
                              //Insiro o nome da estratégia
                              OrderCommentary += "S>" + (string)MySet[x].Strategy;                                                                                                                        //Print("11111, EntryOrder_OrderType:",MySet[x].EntryOrder_OrderType);

                              //bool  BuyStop(const double volume,const double price,const string symbol=NULL,const double sl=0.0,const double tp=0.0,
                              //                          const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");
                              MySet[x].glStopOrderPlaced=Trade.BuyStop(MySet[x].StopOrder_Volume,MySet[x].StopOrder_Price,MySet[x].Ativo_Symbol,0,0,Quant_type_time,0,OrderCommentary);

                             }

                           if(MySet[x].glStopOrderPlaced==true)
                             {

                              MySet[x].StopLossTicketNumber=Trade.ResultOrder();
                              Trade.Request(TradeRequest);
                              Trade.Result(TradeResult);
                              MySet[x].StopOrder_OrderNumber=MySet[x].StopLossTicketNumber;
                              MySet[x].StopOrder_VolExec=0;

                              Print("OnTick| TradeID:"+MySet[x].TradeID+".Ordem de STOP Reenviada. Ordem# "+(string)MySet[x].StopLossTicketNumber+" Resultado: "+(string)MySet[x].glStopOrderPlaced +" Codigo de Retorno: "+ (string)Trade.CheckResultRetcode()+" / "+ Trade.CheckResultRetcodeDescription());
                              Print("OnTick| TradeID:"+MySet[x].TradeID+".ResultVolume: "+ (string)Trade.ResultVolume());
                              Print("OnTick| TradeID:"+MySet[x].TradeID+".ResultPrice: "+ (string)Trade.ResultPrice());
                              Print("OnTick| TradeID:"+MySet[x].TradeID+".Stop  Price: "+ (string)MySet[x].StopOrder_Price);

                             }
                           else
                             {
                              MySet[x].StopLossTicketNumber=Trade.ResultOrder();
                              Print("OnTick| TradeID[",MySet[x].TradeID,"] Stop Order:",MySet[x].StopLossTicketNumber," RetCode:",Trade.CheckResultRetcode());
                              if((string)Trade.CheckResultRetcode()=="10006") // RetCode 10006 == "REJECTED"
                                {
                                 MySet[x].StopOrder_Status="REJECTED"; // Ordem Stop - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                                       //MySet[x].Trade_Status = "FINISHED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                                 Print("OnTick| TradeID:",MySet[x].TradeID," |ResultRetCode: ",Trade.CheckResultRetcode());
                                 Print("OnTick| Ordem REJEITADA. Ordem# "+(string)MySet[x].StopLossTicketNumber+" |Resultado: "+(string)MySet[x].glBuyPlaced+" Codigo de Retorno: "+(string)Trade.CheckResultRetcode()+" / "+Trade.CheckResultRetcodeDescription());
                                }
                              else
                                {
                                 //Stop Order falhou o envio
                                 Print("OnTick| TradeID:",MySet[x].TradeID," Envio da ordem FALHOU. StopOrder_OrderType: ",MySet[x].StopOrder_type);
                                }
                             }

                           //MySet[x].Trade_Status = "FINISHED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                           //MySet[x].StopOrder_Status = "CANCELED";
                           //OrdExec_triggered = false;
                           //OrdExec_Volume = 0; // Zera a quantidade no controle de execucacao
                           Print("OnTick| TradeID:"+MySet[x].TradeID+".Ordem STOP Ajustada - Target Atingido e executado Parcialmente. Ticket: "+(string)MySet[x].StopLossTicketNumber);

                          }
                        else
                          {
                           Print("OnTick| TradeID:"+MySet[x].TradeID+".Problema com o cancelamento da ordem STOP!. Order Number: "+(string)MySet[x].StopLossTicketNumber);
                          }
                       } // Target Executed PARTIAL?

                     else // Target Executed COMPLETE
                       {
                        bool OrderCanceled=Trade.OrderDelete(MySet[x].StopLossTicketNumber);
                        if(OrderCanceled) // stop order canceled?
                          {
                           MySet[x].Trade_Status="FINISHED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)  // Target Executado. Trade encerrado
                           MySet[x].StopOrder_Status="CANCELED";
                           if(MySet[x].TradeDirection=="LONG")
                             {
                              glBuyPositionOpen=false;
                              Print("OnTick| TradeID: ",MySet[x].TradeID," | Trade Compra Finalizado |Flag de direcao do trade atualizado: BuyPosition: ",glBuyPositionOpen," |SellPosition: ",glSellPositionOpen);
                             }
                           else if(MySet[x].TradeDirection=="SHORT")
                             {
                              glSellPositionOpen=false;
                              Print("OnTick| TradeID: ",MySet[x].TradeID," | Trade Venda Finalizado |Flag de direcao do trade atualizado: BuyPosition: ",glBuyPositionOpen," |SellPosition: ",glSellPositionOpen);
                             }

                           //OrdExec_triggered = false;
                           //OrdExec_Volume = 0; // Zera a quantidade no controle de execucacao
                           Print("OnTick| TradeID:"+MySet[x].TradeID+".Ordem STOP Cancelada - Target Atingido. Ticket: "+(string)MySet[x].StopLossTicketNumber);
                           //Aviso sonoro de execucao da ordem
                           //PlaySound("request.wav");

                           // Account Balance - Saldo da Conta
                           if(MySet[x].EntryOrder_type=="DEAL_TYPE_BUY") // Trade "DEAL_TYPE_BUY = LONG
                             {
                              //AccountBalance_Points = AccountBalance_Points + (MySet[x].TgtOrder_Price - MySet[x].EntryOrder_Price);
                              AccountBalance_Points=AccountBalance_Points+(MySet[x].TgtOrder_Price-MySet[x].EntryOrder_PriceExec);
                              //Print( "OnTick| Saldo do dia em Pontos. Preco do Tgt: "+(string)MySet[x].TgtOrder_Price+" Preco de entrada: "+(string)MySet[x].EntryOrder_Price+" Saldo: "+(string)AccountBalance_Points );
                              Print("OnTick| Saldo do dia em Pontos. Preco do Tgt: "+(string)MySet[x].TgtOrder_Price+" Preco de entrada: "+(string)MySet[x].EntryOrder_PriceExec+" Saldo: "+(string)AccountBalance_Points);
                             }
                           else
                             {
                              //AccountBalance_Points = AccountBalance_Points + (MySet[x].EntryOrder_Price - MySet[x].TgtOrder_Price);
                              AccountBalance_Points=AccountBalance_Points+(MySet[x].EntryOrder_PriceExec-MySet[x].TgtOrder_Price);
                              //Print( "OnTick| Saldo do dia em Pontos. Preco do Tgt: "+(string)MySet[x].TgtOrder_Price+" Preco de entrada: "+(string)MySet[x].EntryOrder_Price+" Saldo: "+(string)AccountBalance_Points );
                              Print("OnTick| Saldo do dia em Pontos. Preco do Tgt: "+(string)MySet[x].TgtOrder_Price+" Preco de entrada: "+(string)MySet[x].EntryOrder_PriceExec+" Saldo: "+(string)AccountBalance_Points);
                             }
                           Print("OnTick| Saldo do dia em Pontos   : "+(string)AccountBalance_Points);
                           //AccountBalance_Currency = AccountInfoDouble(ACCOUNT_BALANCE);
                           AccountBalance_Currency=AccountBalance_Points*MySet[x].EntryOrder_Volume*Ativo_ValorTick;

                           Print("OnTick| Saldo do dia em Valor(R$): "+(string)AccountBalance_Currency);
                           Print("AccountInfo/ ACCOUNT_BALANCE: "+(string)AccountInfoDouble(ACCOUNT_BALANCE));
                           Print("AccountInfo/ ACCOUNT_EQUITY : "+(string)AccountInfoDouble(ACCOUNT_EQUITY));

                          } // stop order canceled?
                        else
                          {
                           Print("OnTick| TradeID:"+MySet[x].TradeID+".Problema com o cancelamento da ordem STOP!. Order Number: "+(string)MySet[x].StopLossTicketNumber);
                          } // stop order canceled?
                       } // Target Executed COMPLETE
                    }  //Target Executed? CancelOrder - Stop Order

                  //CancelOrder - Entry Order
                  if((MySet[x].TgtOrder_Status=="PARTIAL" || MySet[x].TgtOrder_Status=="FILLED") && MySet[x].EntryOrder_Status=="PARTIAL")
                    {
                     bool OrderCanceled=Trade.OrderDelete(MySet[x].EntryOrder_OrderNumber);
                     if(OrderCanceled)
                       {
                        MySet[x].EntryOrder_Status="FINISHED";
                        Print("OnTick| TradeID:"+MySet[x].TradeID+".Ordem ENTRYPOINT Cancelada - Target Atingido. Ticket: "+(string)MySet[x].EntryOrder_OrderNumber);
                       }
                     else
                       {
                        Print("OnTick| TradeID:"+MySet[x].TradeID+".Problema com o cancelamento da ordem ENTRYPOINT!. Order Number: "+(string)MySet[x].EntryOrder_OrderNumber);
                       }
                    } //CancelOrder - Entry Order

                  //Stop Executed?

                  //CancelOrder - Target Order 
                  if((MySet[x].StopOrder_Status=="PARTIAL" || MySet[x].StopOrder_Status=="FILLED") && (MySet[x].TgtOrder_Status!="CANCELED" && MySet[x].TgtOrder_Status!="REJECTED"))
                    {

                     // Dados da conta
                     //Print( "AccountInfo/ ACCOUNT_BALANCE: "+(string)AccountInfoDouble(ACCOUNT_BALANCE) );
                     //Print( "AccountInfo/ ACCOUNT_CREDIT: "+(string)AccountInfoDouble(ACCOUNT_CREDIT) );
                     //Print( "AccountInfo/ ACCOUNT_PROFIT: "+(string)AccountInfoDouble(ACCOUNT_PROFIT) );
                     //Print( "AccountInfo/ ACCOUNT_EQUITY: "+(string)AccountInfoDouble(ACCOUNT_EQUITY) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN: "+(string)AccountInfoDouble(ACCOUNT_MARGIN) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_FREE: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_FREE) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_LEVEL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_LEVEL) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_SO_CALL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_SO_SO: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_SO_SO) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_INITIAL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_INITIAL) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_MAINTENANCE: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE) );
                     //Print( "AccountInfo/ ACCOUNT_ASSETS: "+(string)AccountInfoDouble(ACCOUNT_ASSETS) );
                     //Print( "AccountInfo/ ACCOUNT_LIABILITIES: "+(string)AccountInfoDouble(ACCOUNT_LIABILITIES) );
                     //Print( "AccountInfo/ ACCOUNT_COMMISSION_BLOCKED: "+(string)AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED) );


                     Print("OnTick| TradeID:"+MySet[x].TradeID+" STOP Atingido. Cancelando Ordem TARGET!. Order Number: "+(string)MySet[x].TargetTicketNumber);
                     //Aviso sonoro de execucao da ordem
                     //PlaySound("request.wav");

                     bool OrderCanceled=Trade.OrderDelete(MySet[x].TargetTicketNumber);
                     if(OrderCanceled)
                       {
                        MySet[x].Trade_Status="FINISHED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED) Trade Chegou ao fim // Stop Executado. Trade encerrado
                        MySet[x].TgtOrder_Status="CANCELED";
                        if(MySet[x].TradeDirection=="LONG")
                          {
                           glBuyPositionOpen=false;
                           Print("OnTick| TradeID: ",MySet[x].TradeID," | Trade Compra Finalizado |Flag de direcao do trade atualizado: BuyPosition: ",glBuyPositionOpen," |SellPosition: ",glSellPositionOpen);
                          }
                        else if(MySet[x].TradeDirection=="SHORT")
                          {
                           glSellPositionOpen=false;
                           Print("OnTick| TradeID: ",MySet[x].TradeID," | Trade Venda Finalizado |Flag de direcao do trade atualizado: BuyPosition: ",glBuyPositionOpen," |SellPosition: ",glSellPositionOpen);
                          }

                        //OrdExec_triggered = false;
                        //OrdExec_Volume = 0; // Zera a quantidade no controle de execucacao
                        Print("OnTick| TradeID:"+MySet[x].TradeID+".Ordem TARGET Cancelada - STOP Atingido. Ticket: "+(string)MySet[x].TargetTicketNumber);

                        // Account Balance - Saldo da Conta
                        if(MySet[x].EntryOrder_type=="DEAL_TYPE_BUY") // Trade "DEAL_TYPE_BUY = LONG
                          {
                           //AccountBalance_Points = AccountBalance_Points + (MySet[x].StopOrder_Price - MySet[x].EntryOrder_Price);
                           AccountBalance_Points=AccountBalance_Points+(MySet[x].StopOrder_Price-MySet[x].EntryOrder_PriceExec);
                           //Print( "OnTick| Saldo do dia em Pontos. Preco do Stop: "+(string)MySet[x].StopOrder_Price+" Preco de entrada: "+MySet[x].EntryOrder_Price+" Saldo: "+(string)AccountBalance_Points );
                          }
                        else
                          {
                           //AccountBalance_Points = AccountBalance_Points + (MySet[x].EntryOrder_Price - MySet[x].StopOrder_Price);
                           AccountBalance_Points=AccountBalance_Points+(MySet[x].EntryOrder_PriceExec-MySet[x].StopOrder_Price);
                           //Print( "OnTick| Saldo do dia em Pontos. Preco do Stop: "+(string)MySet[x].StopOrder_Price+" Preco de entrada: "+MySet[x].EntryOrder_Price+" Saldo: "+(string)AccountBalance_Points );
                          }
                        Print("OnTick| Saldo do dia em Pontos: "+(string)AccountBalance_Points);

                        //AccountBalance_Currency = AccountInfoDouble(ACCOUNT_BALANCE);
                        AccountBalance_Currency=AccountBalance_Points*MySet[x].EntryOrder_Volume*Ativo_ValorTick;
                        Print("OnTick| Saldo do dia em Valor(R$): "+(string)AccountBalance_Currency);

                       }
                     else
                       {
                        Print("OnTick| TradeID:"+MySet[x].TradeID+". STOP Atingido. Problema com o cancelamento da ordem TARGET!. Order Number: "+(string)MySet[x].TargetTicketNumber);
                       }
                    } // Stop Executed? CancelOrder - Target Order

                  // Stop Executed but REJECTED? CancelOrder - Target Order and resubmitt Stop
                  //CancelOrder - Target Order 
                  if(MySet[x].StopOrder_Status=="REJECTED" && (MySet[x].TgtOrder_Status!="CANCELED" && MySet[x].TgtOrder_Status!="REJECTED"))
                    {

                     // Dados da conta
                     //Print( "AccountInfo/ ACCOUNT_BALANCE: "+(string)AccountInfoDouble(ACCOUNT_BALANCE) );
                     //Print( "AccountInfo/ ACCOUNT_CREDIT: "+(string)AccountInfoDouble(ACCOUNT_CREDIT) );
                     //Print( "AccountInfo/ ACCOUNT_PROFIT: "+(string)AccountInfoDouble(ACCOUNT_PROFIT) );
                     //Print( "AccountInfo/ ACCOUNT_EQUITY: "+(string)AccountInfoDouble(ACCOUNT_EQUITY) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN: "+(string)AccountInfoDouble(ACCOUNT_MARGIN) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_FREE: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_FREE) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_LEVEL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_LEVEL) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_SO_CALL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_SO_SO: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_SO_SO) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_INITIAL: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_INITIAL) );
                     //Print( "AccountInfo/ ACCOUNT_MARGIN_MAINTENANCE: "+(string)AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE) );
                     //Print( "AccountInfo/ ACCOUNT_ASSETS: "+(string)AccountInfoDouble(ACCOUNT_ASSETS) );
                     //Print( "AccountInfo/ ACCOUNT_LIABILITIES: "+(string)AccountInfoDouble(ACCOUNT_LIABILITIES) );
                     //Print( "AccountInfo/ ACCOUNT_COMMISSION_BLOCKED: "+(string)AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED) );


                     Print("OnTick| TradeID:"+MySet[x].TradeID+" STOP Atingido, mas ordem REJEITADA. Cancelando Ordem TARGET!. Order Number: "+(string)MySet[x].TargetTicketNumber);
                     //PlaySound("request.wav");

                     bool OrderCanceled=Trade.OrderDelete(MySet[x].TargetTicketNumber);
                     if(OrderCanceled)
                       {
                        //MySet[x].Trade_Status = "FINISHED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED) Trade Chegou ao fim // Stop Executado. Trade encerrado
                        MySet[x].TgtOrder_Status="CANCELED";
                        //OrdExec_triggered = false;
                        //OrdExec_Volume = 0; // Zera a quantidade no controle de execucacao
                        Print("OnTick| TradeID:"+MySet[x].TradeID+".Ordem TARGET Cancelada - STOP Atingido. Ticket: "+(string)MySet[x].TargetTicketNumber);

                        // Account Balance - Saldo da Conta
                        if(MySet[x].EntryOrder_type=="DEAL_TYPE_BUY") // Trade "DEAL_TYPE_BUY = LONG
                          {
                           //AccountBalance_Points = AccountBalance_Points + (MySet[x].StopOrder_Price - MySet[x].EntryOrder_Price);
                           AccountBalance_Points=AccountBalance_Points+(MySet[x].StopOrder_Price-MySet[x].EntryOrder_PriceExec);
                           //Print( "OnTick| Saldo do dia em Pontos. Preco do Stop: "+(string)MySet[x].StopOrder_Price+" Preco de entrada: "+MySet[x].EntryOrder_Price+" Saldo: "+(string)AccountBalance_Points );
                          }
                        else
                          {
                           //AccountBalance_Points = AccountBalance_Points + (MySet[x].EntryOrder_Price - MySet[x].StopOrder_Price);
                           AccountBalance_Points=AccountBalance_Points+(MySet[x].EntryOrder_PriceExec-MySet[x].StopOrder_Price);
                           //Print( "OnTick| Saldo do dia em Pontos. Preco do Stop: "+(string)MySet[x].StopOrder_Price+" Preco de entrada: "+MySet[x].EntryOrder_Price+" Saldo: "+(string)AccountBalance_Points );
                          }
                        Print("OnTick| Saldo do dia em Pontos: "+(string)AccountBalance_Points);

                        //AccountBalance_Currency = AccountInfoDouble(ACCOUNT_BALANCE);
                        AccountBalance_Currency=AccountBalance_Points*MySet[x].EntryOrder_Volume*Ativo_ValorTick;
                        Print("OnTick| Saldo do dia em Valor(R$): "+(string)AccountBalance_Currency);

                        //====================================================================
                        // Send order at market after cancel target order
                        //================
                        // ADD EXIT ORDER
                        //================

                        Print("OnTick| TradeID:",MySet[x].TradeID," Enviando ordem a mercado para substituir a ordem de STOP e finalizar o trade.");

                        if(MySet[x].EntryOrder_type=="DEAL_TYPE_BUY")
                          {
                           //MySet[x].StopOrder_Price = MySet[x].EntryOrder_Price;  // Ajusta Stop para o valor de entrada do Trade, impendindo que o resultado torne-se negativo
                           //MySet[x].StopOrder_type = "SELL";
                           //MySet[x].StopOrder_Volume = MySet[x].EntryOrder_VolExec;
                           string OrderCommentary;
                           if(MySet[x].TradeType=="RANGE") OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType=="HIGHLOW") OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           //else if (MySet[x].TradeType == "QUANTTREND") OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "TIMEENTRY")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "RRETREAT")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "THIRSTY")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "LASTBAR")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "BSP_BOP")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "OVER_UNDER")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           //Incluo a estrategia nos comentários para recupeção na janela de Trace
                           //Acionou a Janela trace, se sim insere *S, senão *N - para ser 
                           OrderCommentary += (MySet[x].TraceWindowInvert)?"*S":"*N";
                           //Insiro o nome da estratégia
                           OrderCommentary += "S>" + (string)MySet[x].Strategy;                                                                                                                        //Print("11111, EntryOrder_OrderType:",MySet[x].EntryOrder_OrderType);

                           //bool  SellStop(const double volume,const double price,const string symbol=NULL,const double sl=0.0,const double tp=0.0,
                           //                           const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");
                           MySet[x].glStopOrderPlaced=Trade.Sell(MySet[x].StopOrder_Volume,MySet[x].Ativo_Symbol,0,0,0,OrderCommentary);

                          }
                        else
                          {
                           //MySet[x].StopOrder_Price = MySet[x].EntryOrder_Price;  // Ajusta Stop para o valor de entrada do Trade, impendindo que o resultado torne-se negativo
                           //MySet[x].StopOrder_type = "BUY";
                           //MySet[x].StopOrder_Volume = MySet[x].EntryOrder_VolExec;
                           string OrderCommentary;
                           if(MySet[x].TradeType=="RANGE") OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType=="HIGHLOW") OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           //else if (MySet[x].TradeType == "QUANTTREND") OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "TIMEENTRY")  OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "RRETREAT")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "THIRSTY")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "LASTBAR")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "BSP_BOP")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else if(MySet[x].TradeType == "OVER_UNDER")   OrderCommentary = "S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           else OrderCommentary="S:"+(string)MySet[x].EntryOrder_OrderNumber+"@"+MySet[x].TradeID;
                           //Incluo a estrategia nos comentários para recupeção na janela de Trace
                           //Acionou a Janela trace, se sim insere *S, senão *N - para ser 
                           OrderCommentary += (MySet[x].TraceWindowInvert)?"*S":"*N";
                           //Insiro o nome da estratégia
                           OrderCommentary += "S>" + (string)MySet[x].Strategy;                                                                                                                        //Print("11111, EntryOrder_OrderType:",MySet[x].EntryOrder_OrderType);

                           //bool  BuyStop(const double volume,const double price,const string symbol=NULL,const double sl=0.0,const double tp=0.0,
                           //                          const ENUM_ORDER_TYPE_TIME type_time=ORDER_TIME_GTC,const datetime expiration=0,const string comment="");
                           MySet[x].glStopOrderPlaced=Trade.Buy(MySet[x].StopOrder_Volume,MySet[x].Ativo_Symbol,0,0,0,OrderCommentary);
                          }

                        if(MySet[x].glStopOrderPlaced==true)
                          {
                           MySet[x].StopLossTicketNumber=Trade.ResultOrder();
                           Trade.Request(TradeRequest);
                           Trade.Result(TradeResult);
                           MySet[x].StopOrder_OrderNumber=MySet[x].StopLossTicketNumber;
                           MySet[x].StopOrder_VolExec=0;

                           Print("OnTick| TradeID:"+MySet[x].TradeID+".Ordem de STOP Reenviada. Ordem# "+(string)MySet[x].StopLossTicketNumber+" Resultado: "+(string)MySet[x].glStopOrderPlaced +" Codigo de Retorno: "+ (string)Trade.CheckResultRetcode()+" / "+ Trade.CheckResultRetcodeDescription());
                           Print("OnTick| TradeID:"+MySet[x].TradeID+".ResultVolume: "+ (string)Trade.ResultVolume());
                           Print("OnTick| TradeID:"+MySet[x].TradeID+".ResultPrice: "+ (string)Trade.ResultPrice());
                           Print("OnTick| TradeID:"+MySet[x].TradeID+".Stop  Price: "+ (string)MySet[x].StopOrder_Price);

                          }
                        else
                          {
                           MySet[x].StopLossTicketNumber=Trade.ResultOrder();
                           Print("OnTick| TradeID[",MySet[x].TradeID,"] Stop Order:",MySet[x].StopLossTicketNumber," RetCode:",Trade.CheckResultRetcode());
                           if((string)Trade.CheckResultRetcode()=="10006") // RetCode 10006 == "REJECTED"
                             {
                              MySet[x].StopOrder_Status="REJECTED"; // Ordem Stop - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                                    //MySet[x].Trade_Status = "FINISHED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                              Print("OnTick| TradeID:",MySet[x].TradeID," |ResultRetCode: ",Trade.CheckResultRetcode());
                              Print("OnTick| Ordem REJEITADA. Ordem# "+(string)MySet[x].StopLossTicketNumber+" |Resultado: "+(string)MySet[x].glBuyPlaced+" Codigo de Retorno: "+(string)Trade.CheckResultRetcode()+" / "+Trade.CheckResultRetcodeDescription());
                              //PlaySound("request.wav");
                             }
                           else
                             {
                              //Stop Order falhou o envio
                              Print("OnTick| TradeID:",MySet[x].TradeID," Envio da ordem FALHOU. StopOrder_OrderType: ",MySet[x].StopOrder_type);
                             }

                          }

                        //MySet[x].Trade_Status = "FINISHED";  // Status do trade (WAITING/ PLACED/ STARTED/ FINISHED)
                        //MySet[x].StopOrder_Status = "CANCELED";
                        //OrdExec_triggered = false;
                        //OrdExec_Volume = 0; // Zera a quantidade no controle de execucacao
                        Print("OnTick| TradeID:"+MySet[x].TradeID+".Ordem STOP Ajustada - STOP REJEITADO, entao ordem target cancelada e nova ordem de stop criada. Ticket: "+(string)MySet[x].StopLossTicketNumber);
                        //====================================================================

                       }
                     else
                       {
                        Print("OnTick| TradeID:"+MySet[x].TradeID+". STOP Atingido, mas ordem REJEITADA. Problema com o cancelamento da ordem TARGET!. Order Number: "+(string)MySet[x].TargetTicketNumber);
                        //PlaySound("request.wav");
                       }
                    } // Stop Executed but REJECTED? CancelOrder - Target Order and resubmitt Stop

                 } // Entry Order Executed and Target and Stop Order are Running

              } //for(x=0;x<=(ArraySize(MySet)-1); x++)

           } // NewDayStarted

        } // if (DayOKtoTrade == true)
     } //if (ContaChecked)

  } // OnTick()
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
//ExtExpert.OnTrade();

//OrderTentative = 0; //Counter to avoid infinite order submissions

//Adiciona no log a lsita de ordens em aberto.
   for(int i=0; i<OrdersTotal(); i++)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      ulong ticket=OrderGetTicket(i);
      Print("OnTrade| Order Ticket#:"+(string)ticket);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=(ENUM_TRADE_TRANSACTION_TYPE)trans.type;
//--- if the transaction is the request handling result, only its name is displayed

   Print("OTT| OntradeTransaction|Started! Transaction Type: "+EnumToString(type));
// Check Deal Add - Verifica se ordem de entrada foi executada - Order triggered
   if(trans.type==TRADE_TRANSACTION_DEAL_ADD && trans.deal_type!=DEAL_TYPE_BALANCE)
     {
      //Print("Ordem: "+(string)trans.order+" executada. Deal# "+(string)trans.deal+" Tipo: "+EnumToString(trans.deal_type)+" com volume: "+(string)trans.volume+" no valor: "+ (string)trans.price );

      // Verifica ordens
      for(int z=0;z<=(ArraySize(MySet)-1); z++)
        {
         //Print("OnTradeTransaction| trans.order: "+(string)trans.order+" MySet[z].EntryOrder_OrderNumber"+(string)MySet[z].EntryOrder_OrderNumber );
         if(trans.order==MySet[z].EntryOrder_OrderNumber)
           {
            MySet[z].EntryOrder_type=EnumToString(trans.deal_type); // 2 types ENUM_DEAL_TYPE ( DEAL_TYPE_BUY or DEAL_TYPE_SELL )
            MySet[z].EntryOrder_VolExec=MySet[z].EntryOrder_VolExec+trans.volume;

            // Atualiza o preco executado da ordem de entrada
            if(MySet[z].EntryOrder_PriceExec==0)
              {
               MySet[z].EntryOrder_PriceExec=trans.price;
              }

            // Atualiza o preco da ordem de entrada, baseado no preco de execucao
            if(MySet[z].EntryOrder_Price==0)
              {
               MySet[z].EntryOrder_Price=trans.price;
              }

            if(MySet[z].EntryOrder_VolExec<MySet[z].EntryOrder_Volume)
              {
               MySet[z].EntryOrder_Status="PARTIAL"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
               MySet[z].Trade_Status="STARTED";
               //Adiciona numero de contratos para calculo dos custos diarios
               ContratosDiarios=ContratosDiarios+trans.volume;

               // LOG no Expert
               Print("OTT| TradeID: ",MySet[z].TradeID," |Entrada executada PARCIALMENTE. Contratos executados: "+(string)trans.volume+" |Total de contratos no dia: "+ (string)ContratosDiarios );
               Print("OTT| TradeID: ",MySet[z].TradeID," |Entrada executada PARCIALMENTE. Contratos executados: "+(string)trans.volume+" |Volume executado ate o momento: "+(string)MySet[z].EntryOrder_VolExec+" |Volume total do trade: "+ (string)MySet[z].EntryOrder_Volume );
               Print("OTT| TradeID: ",MySet[z].TradeID," |Entrada executada PARCIALMENTE. Preco de execucao: "+(string)trans.price+" |Preco da ordem: "+ (string)MySet[z].EntryOrder_Price );

              }
            else
              {
               MySet[z].EntryOrder_VolExec=MySet[z].EntryOrder_Volume; //Encontrado BUG que duplica a transacao TRADE_TRANSACTION_DEAL_ADD em dias com grande volatilidade.
               MySet[z].EntryOrder_Status="FILLED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
               MySet[z].Trade_Status="STARTED";
               //Adiciona numero de contratos para calculo dos custos diarios
               ContratosDiarios=ContratosDiarios+trans.volume;

               // LOG no Expert
               Print("OTT| TradeID: ",MySet[z].TradeID," |Entrada executada INTEGRALMENTE. Contratos executados: "+(string)trans.volume+" |Total de contratos no dia: "+ (string)ContratosDiarios );
               Print("OTT| TradeID: ",MySet[z].TradeID," |Entrada executada INTEGRALMENTE. Contratos executados: "+(string)trans.volume+" |Volume executado ate o momento: "+(string)MySet[z].EntryOrder_VolExec+" |Volume total do trade: "+ (string)MySet[z].EntryOrder_Volume );
               Print("OTT| TradeID: ",MySet[z].TradeID," |Entrada executada INTEGRALMENTE. Preco de execucao: "+(string)trans.price+" |Preco da ordem: "+ (string)MySet[z].EntryOrder_Price );

              }
            Print("OTT| TradeID:"+(string)MySet[z].TradeID+" .TradeStatus: "+MySet[z].Trade_Status+" Ordem ENTRY: "+(string)MySet[z].EntryOrder_OrderNumber+" Executada! Status: "+MySet[z].EntryOrder_Status+" Type: "+MySet[z].EntryOrder_type+" VolExec: "+(string)MySet[z].EntryOrder_VolExec+" Price: "+(string)trans.price);

           }
         else if(trans.order==MySet[z].TgtOrder_OrderNumber)
           {
            MySet[z].TgtOrder_type=EnumToString(trans.deal_type); // 2 types ENUM_DEAL_TYPE ( DEAL_TYPE_BUY or DEAL_TYPE_SELL )
            MySet[z].TgtOrder_VolExec=MySet[z].TgtOrder_VolExec+trans.volume;

            // Atualiza o preco executado da ordem de Target
            if(MySet[z].TgtOrder_PriceExec==0)
              {
               MySet[z].TgtOrder_PriceExec=trans.price;
              }

            // Atualiza o preco da ordem de Target, baseado no preco de execucao
            if(MySet[z].TgtOrder_Price==0)
              {
               MySet[z].TgtOrder_Price=trans.price;
              }

            if(MySet[z].TgtOrder_VolExec<MySet[z].TgtOrder_Volume)
              {
               MySet[z].TgtOrder_Status="PARTIAL"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                   //Adiciona numero de contratos para calculo dos custos diarios
               ContratosDiarios=ContratosDiarios+trans.volume;

               // LOG no Expert
               Print("OTT| TradeID: ",MySet[z].TradeID," |Target executado PARCIALMENTE. Contratos executados: "+(string)trans.volume+" |Total de contratos no dia: "+ (string)ContratosDiarios );
               Print("OTT| TradeID: ",MySet[z].TradeID," |Target executado PARCIALMENTE. Contratos executados: "+(string)trans.volume+" |Volume executado ate o momento: "+(string)MySet[z].TgtOrder_VolExec+" |Volume total do trade: "+ (string)MySet[z].TgtOrder_Volume );
               Print("OTT| TradeID: ",MySet[z].TradeID," |Target executado PARCIALMENTE. Preco de execucao: "+(string)trans.price+" |Preco da ordem: "+ (string)MySet[z].TgtOrder_Price );

              }
            else
              {
               MySet[z].TgtOrder_VolExec=MySet[z].TgtOrder_Volume; //Encontrado BUG que duplica a transacao TRADE_TRANSACTION_DEAL_ADD em dias com grande volatilidade.
               MySet[z].TgtOrder_Status="FILLED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                  //Adiciona numero de contratos para calculo dos custos diarios
               ContratosDiarios=ContratosDiarios+trans.volume;

               // LOG no Expert
               Print("OTT| TradeID: ",MySet[z].TradeID," |Target executado INTEGRALMENTE. Contratos executados: "+(string)trans.volume+" |Total de contratos no dia: "+ (string)ContratosDiarios );
               Print("OTT| TradeID: ",MySet[z].TradeID," |Target executado INTEGRALMENTE. Contratos executados: "+(string)trans.volume+" |Volume executado ate o momento: "+(string)MySet[z].TgtOrder_VolExec+" |Volume total do trade: "+ (string)MySet[z].TgtOrder_Volume );
               Print("OTT| TradeID: ",MySet[z].TradeID," |Target executado INTEGRALMENTE. Preco de execucao: "+(string)trans.price+" |Preco da ordem: "+ (string)MySet[z].TgtOrder_Price );

              }
            Print("OTT| TradeID:"+(string)MySet[z].TradeID+" .TradeStatus: "+MySet[z].Trade_Status+" Ordem TARGET: "+(string)MySet[z].TgtOrder_OrderNumber+" Executada! Status: "+MySet[z].TgtOrder_Status+" Type: "+MySet[z].TgtOrder_type+" VolExec: "+(string)MySet[z].TgtOrder_VolExec+" Price: "+(string)MySet[z].TgtOrder_Price);
            // Atualiza flags de TradeID Direction
            if(MySet[z].TradeID==glBuyTradeIDOpen)
              {
               glBuyTradeIDOpen="";
               Print("OTT| ",MySet[z].TradeID," |Parametro glBuyTradeIDOpen atualizado, Target alcancado. Conteudo: ",glBuyTradeIDOpen);
              }
            else if(MySet[z].TradeID==glSellTradeIDOpen)
              {
               glSellTradeIDOpen="";
               Print("OTT| ",MySet[z].TradeID," |Parametro glSellTradeIDOpen atualizado. Target alcancado. Conteudo: ",glSellTradeIDOpen);
              }

           }
         else if(trans.order==MySet[z].StopOrder_OrderNumber)
           {
            MySet[z].StopOrder_type=EnumToString(trans.deal_type); // 2 types ENUM_DEAL_TYPE ( DEAL_TYPE_BUY or DEAL_TYPE_SELL )
            MySet[z].StopOrder_VolExec=MySet[z].StopOrder_VolExec+trans.volume;

            // Atualiza o preco executado da ordem de Stop
            if(MySet[z].StopOrder_PriceExec==0)
              {
               MySet[z].StopOrder_PriceExec=trans.price;
              }

            // Atualiza o preco da ordem de Stop, baseado no preco de execucao
            if(MySet[z].StopOrder_Price==0)
              {
               MySet[z].StopOrder_Price=trans.price;
              }

            if(MySet[z].StopOrder_VolExec<MySet[z].StopOrder_Volume)
              {
               MySet[z].StopOrder_Status="PARTIAL"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                    //Adiciona numero de contratos para calculo dos custos diarios
               ContratosDiarios=ContratosDiarios+trans.volume;

               // LOG no Expert
               Print("OTT| TradeID: ",MySet[z].TradeID," |Stop executado PARCIALMENTE. Contratos executados: "+(string)trans.volume+" |Total de contratos no dia: "+ (string)ContratosDiarios );
               Print("OTT| TradeID: ",MySet[z].TradeID," |Stop executado PARCIALMENTE. Contratos executados: "+(string)trans.volume+" |Volume executado ate o momento: "+(string)MySet[z].StopOrder_VolExec+" |Volume total do trade: "+ (string)MySet[z].StopOrder_Volume );
               Print("OTT| TradeID: ",MySet[z].TradeID," |Stop executado PARCIALMENTE. Preco de execucao: "+(string)trans.price+" |Preco da ordem: "+ (string)MySet[z].StopOrder_Price );

              }
            else
              {
               MySet[z].StopOrder_VolExec=MySet[z].StopOrder_Volume; //Encontrado BUG que duplica a transacao TRADE_TRANSACTION_DEAL_ADD em dias com grande volatilidade.
               MySet[z].StopOrder_Status="FILLED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                   //Adiciona numero de contratos para calculo dos custos diarios
               ContratosDiarios=ContratosDiarios+trans.volume;

               // LOG no Expert
               Print("OTT| TradeID: ",MySet[z].TradeID," |Stop executado INTEGRALMENTE. Contratos executados: "+(string)trans.volume+" |Total de contratos no dia: "+ (string)ContratosDiarios );
               Print("OTT| TradeID: ",MySet[z].TradeID," |Stop executado INTEGRALMENTE. Contratos executados: "+(string)trans.volume+" |Volume executado ate o momento: "+(string)MySet[z].StopOrder_VolExec+" |Volume total do trade: "+ (string)MySet[z].StopOrder_Volume );
               Print("OTT| TradeID: ",MySet[z].TradeID," |Stop executado INTEGRALMENTE. Preco de execucao: "+(string)trans.price+" |Preco da ordem: "+ (string)MySet[z].StopOrder_Price );

              }
            Print("OTT| TradeID:"+(string)MySet[z].TradeID+" .TradeStatus: "+MySet[z].Trade_Status+" Ordem STOP: "+(string)MySet[z].StopOrder_OrderNumber+" Executada! Status: "+MySet[z].StopOrder_Status+" Type: "+MySet[z].StopOrder_type+" VolExec: "+(string)MySet[z].StopOrder_VolExec+" Price: "+(string)MySet[z].StopOrder_Price);
            // Atualiza flags de TradeID Direction
            if(MySet[z].TradeID==glBuyTradeIDOpen)
              {
               glBuyTradeIDOpen="";
               Print("OTT| ",MySet[z].TradeID," |Parametro glBuyTradeIDOpen atualizado, Stop alcancado. Conteudo: ",glBuyTradeIDOpen);
              }
            else if(MySet[z].TradeID==glSellTradeIDOpen)
              {
               glSellTradeIDOpen="";
               Print("OTT| ",MySet[z].TradeID," |Parametro glSellTradeIDOpen atualizado. Stop alcancado. Conteudo: ",glSellTradeIDOpen);
              }
           }
         else
           {
            //Print("ORDEM NAO ENCONTRADA!!! Ordem numero:"+ (string)trans.order );
           }

        }

      OrdExec_triggered=true;
     }
//Check Deal Add [TRADE_TRANSACTION_DEAL_ADD] / deal_type DEAL_TYPE_BALANCE / WITHDRAWAL
//       Lancamento realcionado ao TesterWithDrawal, retiradas diárias referentes a custos das operacoes do dia anterior
   if(trans.type==TRADE_TRANSACTION_DEAL_ADD && trans.deal_type==DEAL_TYPE_BALANCE)
     {
      Print("OTT| Withdrawal. Retirada diaria relacionado a custo total das operacoes do dia anterior. Deal# "+(string)trans.deal+" Tipo: "+EnumToString(trans.deal_type)+".");
     }
//Check Order Add [TRADE_TRANSACTION_ORDER_ADD]  
   if(trans.type==TRADE_TRANSACTION_ORDER_ADD && trans.order_state==ORDER_STATE_FILLED)
     {
      Print("OTT| Ordem: "+(string)trans.order+" do Tipo: "+(string)trans.order_type+" adicionada.  State: "+EnumToString(trans.order_state)+" com volume: "+(string)trans.volume+" no valor: "+(string)trans.price);
     }
//Check Order Update [TRADE_TRANSACTION_HISTORY_ADD] - ORDER_STATE_PARTIAL
   if(trans.type==TRADE_TRANSACTION_HISTORY_ADD && trans.order_state==ORDER_STATE_PARTIAL)
     {
      Print("OTT| Ordem: "+(string)trans.order+" do Tipo: "+(string)trans.order_type+" parcialmente preenchida.  State: "+EnumToString(trans.order_state)+" com volume: "+(string)trans.volume+" no valor: "+(string)trans.price);
     }
//Check Order Update [TRADE_TRANSACTION_HISTORY_ADD] - ORDER_STATE_FILLED
   if(trans.type==TRADE_TRANSACTION_HISTORY_ADD && trans.order_state==ORDER_STATE_FILLED)
     {
      Print("OTT| Ordem: "+(string)trans.order+" do Tipo: "+EnumToString(trans.order_type)+" completamente preenchida.  State: "+EnumToString(trans.order_state)+" com volume: "+(string)trans.volume+" no valor: "+(string)trans.price);
     }
//Order Placed - COLOCADA NA PEDRA/ PLACED
   if((trans.type==TRADE_TRANSACTION_ORDER_ADD || trans.type==TRADE_TRANSACTION_ORDER_UPDATE) && trans.order_state==ORDER_STATE_PLACED)

     {
      Print("OTT| Ordem: "+(string)trans.order+" PLACED (na pedra!). Agora: "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES)+" Transacao do tipo: "+EnumToString(trans.type)+" Ordem do tipo: "+EnumToString(trans.order_type)+" com volume: "+(string)trans.volume+" de valor: "+(string)trans.price+" SL: "+(string)trans.price_sl+" TP: "+(string)trans.price_tp);

      // Verifica ordens
      for(int z=0;z<=(ArraySize(MySet)-1); z++)
        {
         if(trans.order==MySet[z].EntryOrder_OrderNumber)
           {
            MySet[z].EntryOrder_Status="PLACED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
            MySet[z].Trade_Status="PLACED";
            Print("OTT| TradeID:"+(string)MySet[z].TradeID+" .TradeStatus: "+MySet[z].Trade_Status+" Ordem ENTRY: "+(string)MySet[z].EntryOrder_OrderNumber+" Executada! Status: "+MySet[z].EntryOrder_Status+" Type: "+MySet[z].EntryOrder_type+" VolExec: "+(string)MySet[z].EntryOrder_VolExec+" Price: "+(string)MySet[z].EntryOrder_PriceExec);
           }
         else if(trans.order==MySet[z].TgtOrder_OrderNumber)
           {
            MySet[z].TgtOrder_Status="PLACED"; // Target ordem - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
            Print("OTT| TradeID:"+(string)MySet[z].TradeID+" .TradeStatus: "+MySet[z].Trade_Status+" Ordem TARGET: "+(string)MySet[z].TgtOrder_OrderNumber+" Executada! Status: "+MySet[z].TgtOrder_Status+" Type: "+MySet[z].TgtOrder_type+" VolExec: "+(string)MySet[z].TgtOrder_VolExec+" Price: "+(string)MySet[z].TgtOrder_Price);
           }
         else if(trans.order==MySet[z].StopOrder_OrderNumber)
           {
            MySet[z].StopOrder_Status="PLACED"; // Stop ordem - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
            Print("OTT| TradeID:"+(string)MySet[z].TradeID+" .TradeStatus: "+MySet[z].Trade_Status+" Ordem STOP: "+(string)MySet[z].StopOrder_OrderNumber+" Executada! Status: "+MySet[z].StopOrder_Status+" Type: "+MySet[z].StopOrder_type+" VolExec: "+(string)MySet[z].StopOrder_VolExec+" Price: "+(string)MySet[z].StopOrder_Price);
           }
        }
     }
//Check Order Delete [TRADE_TRANSACTION_ORDER_DELETE] - SOLICITADO CANCELAMENTO
   if(trans.type==TRADE_TRANSACTION_ORDER_DELETE && trans.order_state==ORDER_STATE_REQUEST_CANCEL)
     {
      Print("OTT| Ordem: "+(string)trans.order+", solicitado CANCELAMENTO. Tipo: "+EnumToString(trans.order_type)+" com volume: "+(string)trans.volume+" de valor: "+(string)trans.price+" SL: "+(string)trans.price_sl+" TP: "+(string)trans.price_tp);
     }
//Check Order Delete [TRADE_TRANSACTION_ORDER_DELETE] - CANCELADA
   if(trans.type==TRADE_TRANSACTION_ORDER_DELETE && trans.order_state==ORDER_STATE_CANCELED)
     {
      Print("OTT| Ordem: "+(string)trans.order+" CANCELADA. Tipo: "+EnumToString(trans.order_type)+" com volume: "+(string)trans.volume+" de valor: "+(string)trans.price+" SL: "+(string)trans.price_sl+" TP: "+(string)trans.price_tp);

      // Verifica ordens
      for(int z=0;z<=(ArraySize(MySet)-1); z++)
        {
         if(trans.order==MySet[z].EntryOrder_OrderNumber)
           {
            MySet[z].EntryOrder_Status="CANCELED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
           }
         else if(trans.order==MySet[z].TgtOrder_OrderNumber)
           {
            MySet[z].TgtOrder_Status="CANCELED"; // Target ordem - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )

                                                 // Atualiza flags de TradeID Direction
            if(MySet[z].TradeID==glBuyTradeIDOpen)
              {
               glBuyTradeIDOpen="";
               Print("OTT| ",MySet[z].TradeID," |Parametro glBuyTradeIDOpen atualizado, Target Cancelado. Conteudo: ",glBuyTradeIDOpen);
              }
            else if(MySet[z].TradeID==glSellTradeIDOpen)
              {
               glSellTradeIDOpen="";
               Print("OTT| ",MySet[z].TradeID," |Parametro glSellTradeIDOpen atualizado. Target Cancelado. Conteudo: ",glSellTradeIDOpen);
              }
           }
         else if(trans.order==MySet[z].StopOrder_OrderNumber)
           {
            MySet[z].StopOrder_Status="CANCELED"; // Stop ordem - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
                                                  // Atualiza flags de TradeID Direction
            if(MySet[z].TradeID==glBuyTradeIDOpen)
              {
               glBuyTradeIDOpen="";
               Print("OTT| ",MySet[z].TradeID," |Parametro glBuyTradeIDOpen atualizado, Stop cancelado. Conteudo: ",glBuyTradeIDOpen);
              }
            else if(MySet[z].TradeID==glSellTradeIDOpen)
              {
               glSellTradeIDOpen="";
               Print("OTT| ",MySet[z].TradeID," |Parametro glSellTradeIDOpen atualizado. Stop cancelado. Conteudo: ",glSellTradeIDOpen);
              }

           }
        }
     }
//Check Order Delete [TRADE_TRANSACTION_ORDER_DELETE] - REJEITADA
   if(trans.type==TRADE_TRANSACTION_ORDER_DELETE && trans.order_state==ORDER_STATE_REJECTED)
     {
      Print("OTT| Ordem: "+(string)trans.order+" REJEITADA!. Tipo: "+EnumToString(trans.order_type)+" com volume: "+(string)trans.volume+" de valor: "+(string)trans.price+" SL: "+(string)trans.price_sl+" TP: "+(string)trans.price_tp);

      // Verifica ordens
      for(int z=0;z<=(ArraySize(MySet)-1); z++)
        {
         if(trans.order==MySet[z].EntryOrder_OrderNumber)
           {
            MySet[z].EntryOrder_Status="REJECTED"; // Ordem de Entrada - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
            Print("OTT| Ordem: "+(string)trans.order+" REJEITADA!. EntryOrder_Status: "+MySet[z].EntryOrder_Status+".");
           }
         else if(trans.order==MySet[z].TgtOrder_OrderNumber)
           {
            MySet[z].TgtOrder_Status="REJECTED"; // Target ordem - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
            Print("OTT| Ordem: "+(string)trans.order+" REJEITADA!. EntryOrder_Status: "+MySet[z].TgtOrder_Status+".");
            // Atualiza flags de TradeID Direction
            if(MySet[z].TradeID==glBuyTradeIDOpen)
              {
               glBuyTradeIDOpen="";
               Print("OTT| ",MySet[z].TradeID," |Parametro glBuyTradeIDOpen atualizado, Target rejeitado. Conteudo: ",glBuyTradeIDOpen);
              }
            else if(MySet[z].TradeID==glSellTradeIDOpen)
              {
               glSellTradeIDOpen="";
               Print("OTT| ",MySet[z].TradeID," |Parametro glSellTradeIDOpen atualizado. Target rejeitado. Conteudo: ",glSellTradeIDOpen);
              }
           }
         else if(trans.order==MySet[z].StopOrder_OrderNumber)
           {
            MySet[z].StopOrder_Status="REJECTED"; // Stop ordem - STATUS ( REQUESTED/ REMOVED/ PLACED/ PARTIAL/ FILLED/ FINISHED/ CANCELED/ REJECTED )
            Print("OTT| Ordem: "+(string)trans.order+" REJEITADA!. EntryOrder_Status: "+MySet[z].StopOrder_Status+".");
            // Atualiza flags de TradeID Direction
            if(MySet[z].TradeID==glBuyTradeIDOpen)
              {
               glBuyTradeIDOpen="";
               Print("OTT| ",MySet[z].TradeID," |Parametro glBuyTradeIDOpen atualizado, Stop rejeitado. Conteudo: ",glBuyTradeIDOpen);
              }
            else if(MySet[z].TradeID==glSellTradeIDOpen)
              {
               glSellTradeIDOpen="";
               Print("OTT| ",MySet[z].TradeID," |Parametro glSellTradeIDOpen atualizado. Stop rejeitado. Conteudo: ",glSellTradeIDOpen);
              }
           }
        }
     }
//Check Order Delete [TRADE_TRANSACTION_HISTORY_ADD] - CANCELADA
   if(trans.type==TRADE_TRANSACTION_HISTORY_ADD && trans.order_state==ORDER_STATE_CANCELED)
     {
      Print("OTT| Ordem: "+(string)trans.order+" CANCELADA (history). Cancelada em "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES)+" Transacao do tipo: "+EnumToString(trans.type)+" Ordem do tipo: "+EnumToString(trans.order_type)+" com volume: "+(string)trans.volume+" de valor: "+(string)trans.price+" SL: "+(string)trans.price_sl+" TP: "+(string)trans.price_tp);
     }
//Check Order Delete [TRADE_TRANSACTION_ORDER_DELETE] - EXPIRED
   if(trans.type==TRADE_TRANSACTION_ORDER_DELETE && trans.order_state==ORDER_STATE_EXPIRED)
     {
      Print("OTT| Ordem: "+(string)trans.order+" EXPIRADA. Expirou em "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES)+"Tipo: "+EnumToString(trans.order_type)+" com volume: "+(string)trans.volume+" de valor: "+(string)trans.price+" SL: "+(string)trans.price_sl+" TP: "+(string)trans.price_tp);
     }
//Check Deal Cancel [TRADE_TRANSACTION_DEAL_DELETE]
   if(trans.type==TRADE_TRANSACTION_DEAL_DELETE)
     {
      Print("OTT| Deal(transacao): "+(string)trans.deal+" DELETADA! Verificar casos. Detalhes: Ordem# "+(string)trans.order+" Deletada em "+TimeToString(TimeCurrent(),TIME_DATE|TIME_MINUTES)+" Transacao do tipo: "+EnumToString(trans.type)+" Ordem do tipo: "+EnumToString(trans.order_type)+" com volume: "+(string)trans.volume+" de valor: "+(string)trans.price+" SL: "+(string)trans.price_sl+" TP: "+(string)trans.price_tp);
      //--- display description of the received transaction in the Journal
      Print("------------TransactionDescription\r\n",TransactionDescription(trans));
     }
//Check History Delete [TRADE_TRANSACTION_HISTORY_DELETE]
   if(trans.type==TRADE_TRANSACTION_HISTORY_DELETE)
     {
      Print("OTT| Historico DELETADO! Verificar casos. Detalhes da Transaction abaixo.");
      //--- display description of the received transaction in the Journal
      Print("OTT| ------------TransactionDescription\r\n",TransactionDescription(trans));
     }
//Check Deal Add [TRADE_TRANSACTION_DEAL_ADD]
//Check Deal Update [TRADE_TRANSACTION_DEAL_UPDATE]
//Check Deal Cancel [TRADE_TRANSACTION_DEAL_DELETE]
//Check History Add [TRADE_TRANSACTION_HISTORY_ADD]
//Check History Update [TRADE_TRANSACTION_HISTORY_UPDATE]
//Check History Delete [TRADE_TRANSACTION_HISTORY_DELETE]
//Check Position [TRADE_TRANSACTION_POSITION]
//Check Request [TRADE_TRANSACTION_REQUEST]


//---
//--- Add to log, details related to Transaction
   if(type==TRADE_TRANSACTION_REQUEST)
     {
      Print(EnumToString(type));
      //--- display the handled request string name
      Print("OTT| ------------RequestDescription\r\n",RequestDescription(request));
      //--- display request result description
      Print("OTT| ------------ResultDescription\r\n",TradeResultDescription(result));
      //--- store the order ticket for its deletion at the next handling in OnTick()
      if(result.order!=0)
        {
         //--- delete this order by its ticket at the next OnTick() call
         order_ticket=result.order;
         Print("OTT|  Pending order ticket ",order_ticket,"\r\n");
        }
     }
   else // display the full description for transactions of another type
//--- display description of the received transaction in the Journal
      Print("OTT| ------------TransactionDescription\r\n",TransactionDescription(trans));
   Print("OTT| OntradeTransaction!!!! Ends");
   //---     
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   //ExtExpert.Deinit();
   glOrderPlaced=false;

   Conta=0;
   ContaChecked=false;

   if(ObjectDelete(0,"HLINE_DayOpen")) Print("Object HLINE_DayOpen deleted.");
   if(ObjectDelete(0,"HLINE_Range")) Print("Object HLINE_Range deleted.");

   // Remove QuantTrend Indicators
   int z;
   z=0;

   //QUANTTREND
   //while( ArraySize(MySet) > z ) 
   //{
   //   if( MySet[z].TradeType == "QUANTTREND" )
   //   {
   //      //---    QUANTTREND 
   //   	//--- WILLIAMS PERCENT R
   //   	if ( IndicatorRelease(MySet[z].Will_PercentR) ) Print("OnDeinit| Indicador W%R: ",(string)MySet[z].Will_PercentR," deleted.");
   //   	if ( IndicatorRelease(MySet[z].MA1) )           Print("OnDeinit| Indicador MA1: ",(string)MySet[z].MA1," deleted.");
   //   }
   //   z++;
   //}

//--- free the array MySet
   ArrayFree(MySet);
   ArrayFree(ATraceWindow);

   Print("OnDeinit| MySet liberado.");

   //Delete all objects available on Current Chart, including subCharts
   //Print("Total Objects Deleted: "+ObjectsDeleteAll(0,-1,-1) );
   
   Print("OnDeinit");
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTesterInit()
  {
   //ExtExpert.OnTesterinit();
   //Testando = true;


   //+------------------------------------------------------------------+
   //| Dados do Simbolo                                                 |
   //+------------------------------------------------------------------+

   //--- object for receiving symbol settings
   //CSymbolInfo symbol_info;  // Adicionado em
   //--- set the name for the appropriate symbol
   symbol_info.Name(_Symbol);
   //--- receive current rates and display
   symbol_info.RefreshRates();
   Print(symbol_info.Name()," (",symbol_info.Description(),")",
         "  Bid=",symbol_info.Bid(),"   Ask=",symbol_info.Ask());
   //--- receive minimum freeze levels for trade operations
   Print("StopsLevel=",symbol_info.StopsLevel()," pips, FreezeLevel=",
         symbol_info.FreezeLevel()," pips");
   //--- receive the number of decimal places and point size
   Print("Digits=",symbol_info.Digits(),
         ", Point=",DoubleToString(symbol_info.Point(),symbol_info.Digits()));
   //--- spread info
   Print("SpreadFloat=",symbol_info.SpreadFloat(),", Spread(current)=",
         symbol_info.Spread()," pips");
   //--- request order execution type for limitations
   Print("Limitations for trade operations: ",EnumToString(symbol_info.TradeMode()),
         " (",symbol_info.TradeModeDescription(),")");
   //--- clarifying trades execution mode
   Print("Trades execution mode: ",EnumToString(symbol_info.TradeExecution()),
         " (",symbol_info.TradeExecutionDescription(),")");
   //--- clarifying contracts price calculation method
   Print("Contract price calculation: ",EnumToString(symbol_info.TradeCalcMode()),
         " (",symbol_info.TradeCalcModeDescription(),")");
   //--- sizes of contracts
   Print("Standard contract size: ",symbol_info.ContractSize(),
         " (",symbol_info.CurrencyBase(),")");
   //--- minimum and maximum volumes in trade operations
   Print("Volume info: LotsMin=",symbol_info.LotsMin(),"  LotsMax=",symbol_info.LotsMax(),
         "  LotsStep=",symbol_info.LotsStep());
   //---
   Print(__FUNCTION__,"  completed");

  }

//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTesterDeinit()
  {
   Print("OnTesterDeinit");

  }

//+------------------------------------------------------------------+
//| Returns datetime value                                           |
//+------------------------------------------------------------------+
// Create datetime value
datetime qCreateDateTime(int pHour=0,int pMinute=0)
  {
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(),timeStruct);

   timeStruct.hour= pHour;
   timeStruct.min = pMinute;

   datetime useTime=StructToTime(timeStruct);

   return(useTime);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
////////ONTRADE TRANSACTION
//+------------------------------------------------------------------+
//| Returns transaction textual description                          |
//+------------------------------------------------------------------+
string TransactionDescription(const MqlTradeTransaction &trans)
  {
//--- 
   string desc="Type: "+EnumToString(trans.type)+"\r\n";
   desc+="Symbol: "+trans.symbol+"\r\n";
   desc+="Deal ticket: "+(string)trans.deal+"\r\n";
   desc+="Deal type: "+EnumToString(trans.deal_type)+"\r\n";
   desc+="Order ticket: "+(string)trans.order+"\r\n";
   desc+="Order type: "+EnumToString(trans.order_type)+"\r\n";
   desc+="Order state: "+EnumToString(trans.order_state)+"\r\n";
   desc+="Order time type: "+EnumToString(trans.time_type)+"\r\n";
   desc+="Order expiration: "+TimeToString(trans.time_expiration)+"\r\n";
   desc+="Price: "+StringFormat("%G",trans.price)+"\r\n";
   desc+="Price trigger: "+StringFormat("%G",trans.price_trigger)+"\r\n";
   desc+="Stop Loss: "+StringFormat("%G",trans.price_sl)+"\r\n";
   desc+="Take Profit: "+StringFormat("%G",trans.price_tp)+"\r\n";
   desc+="Volume: "+StringFormat("%G",trans.volume)+"\r\n";
//--- return the obtained string
   return desc;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Returns the trade request textual description                    |
//+------------------------------------------------------------------+
string RequestDescription(const MqlTradeRequest &request)
  {
//---
   string desc=EnumToString(request.action)+"\r\n";
   desc+="Symbol: "+request.symbol+"\r\n";
   desc+="Magic Number: "+StringFormat("%d",request.magic)+"\r\n";
   desc+="Order ticket: "+(string)request.order+"\r\n";
   desc+="Order type: "+EnumToString(request.type)+"\r\n";
   desc+="Order filling: "+EnumToString(request.type_filling)+"\r\n";
   desc+="Order time type: "+EnumToString(request.type_time)+"\r\n";
   desc+="Order expiration: "+TimeToString(request.expiration)+"\r\n";
   desc+="Price: "+StringFormat("%G",request.price)+"\r\n";
   desc+="Deviation points: "+StringFormat("%G",request.deviation)+"\r\n";
   desc+="Stop Loss: "+StringFormat("%G",request.sl)+"\r\n";
   desc+="Take Profit: "+StringFormat("%G",request.tp)+"\r\n";
   desc+="Stop Limit: "+StringFormat("%G",request.stoplimit)+"\r\n";
   desc+="Volume: "+StringFormat("%G",request.volume)+"\r\n";
   desc+="Comment: "+request.comment+"\r\n";
//--- return the obtained string
   return desc;
  }
//+------------------------------------------------------------------+
//| Returns the textual description of the request handling result   |
//+------------------------------------------------------------------+
string TradeResultDescription(const MqlTradeResult &result)
  {
//---
   string desc="Retcode "+(string)result.retcode+"\r\n";
   desc+="Request ID: "+StringFormat("%d",result.request_id)+"\r\n";
   desc+="Order ticket: "+(string)result.order+"\r\n";
   desc+="Deal ticket: "+(string)result.deal+"\r\n";
   desc+="Volume: "+StringFormat("%G",result.volume)+"\r\n";
   desc+="Price: "+StringFormat("%G",result.price)+"\r\n";
   desc+="Ask: "+StringFormat("%G",result.ask)+"\r\n";
   desc+="Bid: "+StringFormat("%G",result.bid)+"\r\n";
   desc+="Comment: "+result.comment+"\r\n";
//--- return the obtained string
   return desc;
  }
//+------------------------------------------------------------------+
//| script "Delete All pending orders"                              |
//+------------------------------------------------------------------+
//int DeleteAllPendingOrders()
//  {
//   int totalPendingOrders = 0;
//   bool   isDeleted;       //To check order deleted is successful or not
//   int    Order_Type, total;
////----
//   total=OrdersTotal();    //getting total orders including open and pending
////----
////+------------------------------------------------------------------+
////| counting total pending orders                                    |
////+------------------------------------------------------------------+
//   
//   for(int a=0; a<total; a++)
//     {
//      if(OrderSelect(a) )
//        {
//         Order_Type=OrderType();
//         //---- pending orders only are considered
//         if(Order_Type!=OP_BUY && Order_Type!=OP_SELL)
//           {
//            totalPendingOrders++;
//            }
//         }
//   }
//   
//   //Displaying number or total pending orders
//   Print("Total Pending Orders "+totalPendingOrders);
//   
//   
//   //Selecting pending orders and deleting first order in the loop till last order
//   for(int i=0; i<totalPendingOrders; i++)
//     {
//     for(int b=0; b<totalPendingOrders; b++)
//      {
//      if(OrderSelect(b) )
//        {
//         Order_Type=OrderType();
//         //---- pending orders only are considered
//         if(Order_Type!=OP_BUY && Order_Type!=OP_SELL&& Symbol()==OrderSymbol())
//           {
//            //---- print selected order
//            OrderPrint();
//            //---- delete first pending order
//            isDeleted=OrderDelete(OrderTicket());
//            if(isDeleted!=TRUE) Print("LastError = ", GetLastError());
//            break;
//           }
//        }
//      else { Print( "Error when order select ", GetLastError()); break; }
//     }
////----
//   }
//   return(0);
//  }
//+------------------------------------------------------------------+*/

//+------------------------------------------------------------------+
//| Returns value for MID1 based on parametrs provided               |
//+------------------------------------------------------------------+
// Create datetime value
string fMID1(double pPointToCheck,double pY_HIGH,double pY_LOW)
  {
//---
   string MID1_ToReturn;
   double fMID1_Y_MidPoint;

   fMID1_Y_MidPoint=((pY_HIGH-pY_LOW)/2)+pY_LOW;
//MID1
   if(pPointToCheck>pY_HIGH)
     {
      MID1_ToReturn="H+";
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else if(pPointToCheck<=pY_HIGH && pPointToCheck>=Y_MidPoint)
     {
      MID1_ToReturn="M+";
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else if(pPointToCheck<Y_MidPoint && pPointToCheck>=pY_LOW)
     {
      MID1_ToReturn="M-";
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else if(pPointToCheck<pY_LOW)
     {
      MID1_ToReturn="L-";
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      MID1_ToReturn="";
      Print("fMID1| Verificar parametro MID1. Nao foi possivel classificar. PointToCheck: ",pPointToCheck," |Y_High: ",pY_HIGH," |Y_MidPoint: ",fMID1_Y_MidPoint," |Y_Low: ",pY_LOW);
     }

//Print("fMID1| parametro MID1: ",MID1_ToReturn," |PointToCheck: ",pPointToCheck," |Y_High: ",pY_HIGH," |Y_MidPoint: ",fMID1_Y_MidPoint," |Y_Low: ",pY_LOW);

//--- return MID1 string
   return MID1_ToReturn;
  }

//+------------------------------------------------------------------+
//|        Janela trade - faz trade contrário no dia                 |
//+------------------------------------------------------------------+
bool TraceWindow(string Strategy, int WindowDay, int TraceWindowGain)
{
   //Pega os parâmetros do TraceWindowDay e TraceWindowGain no csv
   //Compara se houve a quantidade de gains para a inversão de trade no dia

   double Res = 0;  // soma  valores dos gains parciais
   datetime time,previoustime;  
   bool result=false;
   int gains=0;
   //int TimeBegin=FindTrading(day);
  
   //if (HistorySelect(TimeCurrent()-(TimeBegin*PeriodSeconds(PERIOD_D1)), TimeCurrent()))
   
   //Conta o primeiro primeiro dia 
   int CountDay=0;
   
   //Seleciona todo o histório da conta para a janela
   if (HistorySelect(0, TimeCurrent()))
   {
      for (int i = HistoryDealsTotal(); i>=0; i--)
      {
         ulong Ticket = HistoryDealGetTicket(i);
         if (HistoryDealGetInteger(Ticket, DEAL_ENTRY)==DEAL_ENTRY_OUT)    // verifico se a ordem é do tipo - out     
         {
            time  = HistoryDealGetInteger(Ticket,DEAL_TIME); 
            // Consulto qual estratégia está no histórico
            string StrategyHistory = HistoryDealGetString(Ticket, DEAL_COMMENT);
            //Consulto o comentário para selecionar a estratégia
            //ATENÇÃO: Máximo de 10 caracteres requeridos na estratégia no CSV, Senão atinge limite do comentário do mt5
            StrM.Assign(StrategyHistory);
            string StrategyResult= StrM.Mid(StrM.Find(0,">")+1,StringLen(StrategyHistory));
            string StrategyInvert= StrM.Mid(StrM.Find(0,"*")+1,1);
            
            // Verifico se é o mesmo robô com a mesma estratégia
            if((HistoryDealGetInteger(Ticket, DEAL_MAGIC) == MagicNumber) && (HistoryDealGetString(Ticket, DEAL_SYMBOL) == _Symbol) 
               && StrategyResult == Strategy)
            {  
               CountDay++;
               if (CountDay==1) previoustime=time; //igualo as variáveis no primeiro loop
               
               if (TimeToString(time,TIME_DATE)!=TimeToString(previoustime,TIME_DATE))
               {  
                  WindowDay--;
                  //Se atingiu o Nº de dias de trade encerra a varredura
                  if (WindowDay==0) break;
                  // saldo do dia anterior
                  if (Res>0) gains+=1;  // se houve gain no dia anterior contabiliza + 1
                  Res=0;
                  previoustime=time;
               }
               double val =  HistoryDealGetDouble(Ticket, DEAL_PROFIT);
               Res += (StrategyInvert=="S")? val-(2*val):val;
            }
         }
      }
   } 
   //calculo do valor do último loop que ficou de fora
   if (Res>0) gains+=1;  
   // quantidade de gains agrupado por saldo dos dias de filtro
   result=(gains>=TraceWindowGain)?true:false;

   return(result);   
}
//
//int FindTrading(int days)
//{
//   //Obtenho o número de dias no final de semana para a soma no pregão
//   int div;
//   // dias de fim de semana
//   div=(days<=5)?0:(days/5)*2;
//   // A cada 5 dias de pregão são 7 dias corridos
//   int z;
//   // obtenho o valor do resto dos dias
//   z=MathMod(days,5);   
//   // se houver resto pego, senao pego os dias informados
//   int aux = (z>0)?z:days;
//  
//   // Conta quantos dias de fim de semana tem na janela - conta no máximo 4 dias do resto da divisão
//   int Weekend=0;
//   for (int i=1;i<=aux;i++)
//   {
//      datetime time=TimeCurrent()-(i*PeriodSeconds(PERIOD_D1));
//      MqlDateTime dt;
//      TimeToStruct(time,dt);
//      if (dt.day_of_week==6 || dt.day_of_week==0) 
//      {
//         Weekend=2;
//         break;
//      }
//   }
//   // Somo todos os fins de semana com os dias correntes para chegar na data certa do início da janela
//   int a= (Weekend+ div + days);    
//     
//   return a;
//}



//+------------------------------------------------------------------+
//| Função genérica para calcular o z-score                                                          |
//+------------------------------------------------------------------+
double ZScore(string feature,int days, int hour=0,int minute=0, double Value=0){
   double StdDays[];
   MqlDateTime TimeEntry;
   ArrayResize(StdDays,days);
   ArrayInitialize(StdDays,0);
   double zscore, soma=0;
   int i=0,DayInit;
   // Daily OHLC
   MqlRates Daily[];
   ArraySetAsSeries(Daily,true);
   //Somente no CTO.1 e RANGE desconsidero o dia anterior ao atual na varredura
   DayInit = (feature=="CTO.1" || feature=="RANGE")?2:1;
   //Pego a quantidade de dias e somo + 1 para feature de gap por causa do dia fechamento do dia anterior
   int DayEnd =  (feature=="GAP")?days+1:days;
   CopyRates(_Symbol,PERIOD_D1,DayInit,DayEnd,Daily);
   
   
   if (feature=="TIMEENTRY")
   {
      //Armazena a abertura do pregão para a data/hora selecionada no csv para a início do timeentry
      uint DayBefore;

      //Faço o loop varrendo cada dia especificamente para Time Entry 
      for (i=0; i<=(days-1);i++)
      {
         //Pego o horário de abertura do pregão de cada dia menos o valor de abertura da data/hora no csv
         TimeToStruct(Daily[i].time,TimeEntry);
         TimeEntry.hour=hour;
         TimeEntry.min=minute;
         datetime aux;
         aux= StructToTime(TimeEntry);
         
         int Bar= iBarShift(_Symbol,PERIOD_M1,aux);
         DayBefore= iOpen(_Symbol,PERIOD_M1,Bar);    
         
         StdDays[i]=DayBefore -Daily[i].open;
         // Soma para calcular a média
         soma+=StdDays[i];
                     
      }
   } else {
      //Verificação do ZScore do CTO.1 E GAP.1
      do 
      {
         // ZScore para CTO.1
         if (feature=="CTO.1") 
         {
            StdDays[i]=Daily[i].close-Daily[i].open;
         }
         // ZScore para RANGE como variável
         if (feature=="RANGE") 
         {
            StdDays[i]=Daily[i].high-Daily[i].low;
         }
         //ZScore para GAP.1 
         else if (feature=="GAP")
         {
            // GAP - Abertura de hoje - fechamento de ontem
            StdDays[i]=Daily[i].open-Daily[i+1].close;
         };
         // Soma para calcular a média
         soma+=StdDays[i];
         
         //Conta quantos dias satisfez a condição
         i++;
      } while (i<=(days-1));     //Enquanto não contar a quantidade de dias da janela continua
            
   }
   //Evitar divisão por zero
   double media=soma/(i=(i>1?i:1));
   //z-score: (valor - média)/desvio padrão
   zscore = (Value-media)/MathStandardDeviation(StdDays); 
   return zscore;
}


//+------------------------------------------------------------------+
//| Função genérica para calcular o z-score                                                          |
//+------------------------------------------------------------------+
void ZScoreHighLow(int days,double Value,double ZScoreCSV,double& zscore, double& ZScoreToValue){
   //Valor = Para HIGHLOW positivo, high-open, senão low-open
   //média = ((high-open)+(low-open))/(dias*2)
   //dsvp  = todo o meu espaço amostral - para cada dia dois valores
 
   double StdDays[];
   //Para cada dia são dois valores a serem obtidos
   ArrayResize(StdDays,days*2);
   ArrayInitialize(StdDays,0);
   double soma=0;
   int i=0;
   // Daily OHLC
   MqlRates Daily[];
   ArraySetAsSeries(Daily,true);

   CopyRates(_Symbol,PERIOD_D1,1,days,Daily);

   //Faço o loop varrendo cada dia especificamente para Time Entry 
   for (i=0; i<=(days-1);i++)
   {
      StdDays[i*2]=Daily[i].high -Daily[i].open;
      StdDays[(i*2)+1]=Daily[i].low -Daily[i].open;
      // Soma para calcular a média
      soma+=StdDays[i*2]+StdDays[(i*2)+1];
   }
   //Evitar divisão por zero
   double media=soma/(i=(i>1?i*2:1));
   
   //z-score: (valor - média)/desvio padrão
   zscore = (Value-media)/MathStandardDeviation(StdDays);
   //ZScore do csv transformado em pontos / valor da ação
   ZScoreToValue = symbol_info.NormalizePrice((ZScoreCSV*MathStandardDeviation(StdDays))+media);
         
}

//+------------------------------------------------------------------+
//| Função para calcular o z-score do RANGE                                                          |
//+------------------------------------------------------------------+
void ZScoreRange(string feature,int days,double Value,double ZScoreCSVTop,double ZScoreCSVBottom,double& zscore, double& ZScoreToValueTop, 
double& ZScoreToValueBottom){
   //Valor = Para RANGE high-low
   //média = ((high-low)/(dias)
   //dsvp  = todo o meu espaço amostral - para cada valor
 
   double StdDays[];
   //Para cada dia são dois valores a serem obtidos
   ArrayResize(StdDays,days);
   ArrayInitialize(StdDays,0);
   double soma=0;
   int i=0;
   // Daily OHLC
   MqlRates Daily[];
   ArraySetAsSeries(Daily,true);
   //Para RANGEV=RANGE VARIÁVEL INICIO NO TERCEIRO DIA (0,1,2) ANTERIOR AO DO FILTRO
   int DayInit = (feature=="RANGEV")?2:1;
   CopyRates(_Symbol,PERIOD_D1,DayInit,days,Daily);
   do 
   {
      //máxima - minima
      StdDays[i]=Daily[i].high-Daily[i].low;
      // Soma para calcular a média
      soma+=StdDays[i];
      
      //Conta quantos dias satisfez a condição
      i++;
   } while (i<=(days-1));     //Enquanto não contar a quantidade de dias da janela continua
   //Evitar divisão por zero
   double media=soma/(i=(i>1?i:1));
   
   //z-score: (valor - média)/desvio padrão
   zscore = (Value-media)/MathStandardDeviation(StdDays);
   //ZScore do csv transformado em pontos / valor da ação
   ZScoreToValueTop = symbol_info.NormalizePrice((ZScoreCSVTop*MathStandardDeviation(StdDays))+media);
   ZScoreToValueBottom = symbol_info.NormalizePrice((ZScoreCSVBottom*MathStandardDeviation(StdDays))+media);
 
} 