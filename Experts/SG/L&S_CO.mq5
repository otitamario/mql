//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#define VALIDADE   D'2100.12.31 23:59:59'//Data de Validade ano.mes.dia horas:minutos:segundos(opcional)
#define NUMERO_CONTA 891938   //Numero da conta
#define ONLY_DEMO "SIM" //"SIM"- Somente em Demo,"NAO"- liberado para conta Real
#define VERSION "1.06"// Mudar aqui as Versões

#property copyright "SuperGain"
#property version   VERSION
#property description   "LESS - Long & Short System Por CoIntegração\n"

#property description   "1.00 \n*Versão Inicial"

#property icon "\\Experts\\SG\\LESS.ico"

#resource "\\Indicators\\SG\\L&S_CO.ex5"
#resource "\\Experts\\SG\\LESS.bmp"

#define LARGURA_PAINEL 270 // Largura Painel
#define ALTURA_PAINEL 280 // Altura Painel
#define X_LABEL 11 
#define Y_LABEL 15 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
EA com horário de início, término e fechamento.
Estratégia baseada no cruzamento de duas médias.
*/
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum tipoLotes  // enumeração de constantes nomeados 
  {
   Fixo=1,
   Financeiro=2
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct Perna1
  {
   double            volume;     // valor do tamanho do slippage admissível - 1 byte 
   int               quantidade;    // pula 1 byte 
   ulong             ticketCompra;
   ulong             ticketVenda;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct Perna2
  {
   double            volume;     // valor do tamanho do slippage admissível - 1 byte 
   int               quantidade;    // pula 1 byte 
   ulong             ticketCompra;
   ulong             ticketVenda;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct Perna3
  {
   double            volume;     // valor do tamanho do slippage admissível - 1 byte 
   int               quantidade;    // pula 1 byte 
   ulong             ticketCompra;
   ulong             ticketVenda;
  };

Perna1 perna1;
Perna2 perna2;
Perna3 perna3;

// Inclusão de bibliotecas utilizadas  
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include<Trade\AccountInfo.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>
#include <ChartObjects\ChartObjectsBmpControls.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>

CChartObjectHLine HLineBuyP2;

CChartObjectRectLabel Retangulo;
CChartObjectBmpLabel FotoLess;
CChartObjectButton BotaoFechar;
CChartObjectLabel LabelLucro;
CChartObjectLabel LabelPailnel[50];
CChartObjectLabel LabelVersao;

CAccountInfo      myaccount;
CDealInfo         mydeal;
CTrade            mytrade;
CPositionInfo     myposition;
CSymbolInfo       mysymbolA,mysymbolB;
COrderInfo        myorder;

MqlTradeRequest sg_request;
MqlTradeResult sg_result;
MqlTradeCheckResult sg_check_result;

input ENUM_TIMEFRAMES   TF=PERIOD_CURRENT;//TIMEFRAME do Indicador
input int Magic_Number=1234; // Número mágico

input double Financeiro=100000;
datetime BeginTime=D'1970.01.01'; //Data inicial para Indicador
input string   SimboloPapelA="PETR4";//Ativo Adicional 

input string  VolumePapelA="0.01";//Volume A 
input string  VolumePapelB="0.01";//Volume B 

input int   Periodo=40; // Período da MM.

input int StopTemporal=20;

input double   DesvioPerna1=2; // Desvio Perna1
input double   DesvioPerna2=3; // Desvio Perna2
input double   DesvioPerna3=4; // Desvio Perna3

input double PercentualSLFinanceiro=2; // Stop Loss Percentual por Financeiro
input double PercentualTPFinanceiro=2; // Take Profit Percentual por Financeiro

input bool NaoOperarMaisNoDiaNoSL=true; // Não operar mais no dia no caso de SL
input double Custo=10;

string SimboloPapelB=Symbol();

string gvprefix=MQLInfoInteger(MQL_TESTER)?"t_"+MQLInfoString(MQL_PROGRAM_NAME)+"_"+SimboloPapelA+"_"+SimboloPapelB+"_"+IntegerToString(Magic_Number)+"_":MQLInfoString(MQL_PROGRAM_NAME)+"_"+SimboloPapelA+"_"+SimboloPapelB+"_"+IntegerToString(Magic_Number)+"_";

int subwindow_number;

//--------------Variáveis Globais do Terminal----------------------------//

string IsBuy_rent2=gvprefix+"IsBuy_rent2";//OcorreuCompraReentrada2
string IsSell_rent2=gvprefix+"IsSell_rent2";//OcorreuVendaReentrada2
string IsBuy_rent3=gvprefix+"IsBuy_rent3";//OcorreuCompraReentrada3
string IsSell_rent3=gvprefix+"IsSell_rent3";//OcorreuVendaReentrada3

string Rent_Sell1=gvprefix+"Rent_Sell1";//
string Rent_Buy1=gvprefix+"Rent_Buy1";//

string Rent_Sell2=gvprefix+"Rent_Sell2";//   sinalReentradaVenda2 = reentradaVendaPerna2;
string Rent_Sell3=gvprefix+"Rent_Sell3";//    sinalReentradaVenda3 = reentradaVendaPerna3;

string Rent_Buy2=gvprefix+"Rent_Buy2"; // sinalReentradaCompra2 = reentradaCompraPerna2;
string Rent_Buy3=gvprefix+"Rent_Buy3";// sinalReentradaCompra3 = reentradaCompraPerna3;

string SVol_1=gvprefix+"SVol_1",SVol_2=gvprefix+"SVol_2";

//----------------------Fim Variáveis Globais do Terminal-------------------------//

double SimboloAAsk,SimboloABid,SimboloBAsk,SimboloBBid,myMiddleBandValue0,myUpperBandValue0,myLowerBandValue0,myCloseBandValue0;

int handleBollinger; //
int handleATR;

double VolumePapel1,VolumePapel2;

bool Buy_opened=false;  // variable to hold the result of Buy opened position
bool Sell_opened=false; // variables to hold the result of Sell opened position

bool accountModeHedge=false;

#include <Trade/SymbolInfo.mqh>
//CTrade negocio; // Classe responsável pela execução de negócios
CSymbolInfo simbolo; // Classe responsãvel pelos dados do ativo

double BollingerMeio[];
double BollingerCima[];
double BollingerBaixo[];
double BollingerFechamento[];
double BollingerPernaH2[];
double BollingerPernaL2[];
double BollingerPernaH3[];
double BollingerPernaL3[];

bool tradebar=true;
bool novodia;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   datetime bmptime;
   double bmpprice;
   int bmpsubw=0;
   ChartXYToTimePrice(ChartID(),0,0,bmpsubw,bmptime,bmpprice);

   Retangulo.Create(0,"Retangulo",0,0,0,LARGURA_PAINEL,ALTURA_PAINEL);
   Retangulo.Corner(CORNER_LEFT_UPPER);
   Retangulo.BackColor(clrBlack);
   Retangulo.Color(clrSilver);
   Retangulo.Background(false);
   Retangulo.Style(STYLE_SOLID);
   Retangulo.BorderType(BORDER_FLAT);


   FotoLess.Create(ChartID(),"FotoLess",0,0,0);
   FotoLess.BmpFileOn("::Experts\\SG\\LESS.bmp");
   FotoLess.SetInteger(OBJPROP_XSIZE,75);
   FotoLess.SetInteger(OBJPROP_YSIZE,50);
   FotoLess.Corner(CORNER_LEFT_UPPER);


   ulong numero_conta=NUMERO_CONTA;
   datetime expiracao=VALIDADE;
   string msg_validade="Validade até "+TimeToString(expiracao)+" para a conta "+IntegerToString(numero_conta)+" "+myaccount.Server();
   MessageBox(msg_validade);
   Print(msg_validade);
   bool licenca=TimeCurrent()>expiracao || myaccount.Login()!=numero_conta;
   if(licenca)
     {
      string erro="Licença Inválida";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(ONLY_DEMO=="SIM" && AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO)
     {
      string erro="EA permitido apenas em conta DEMO";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(!TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED))
      Alert("Notificações PUSH não autorizadas! Configurar no Terminal se quiser receber notificações");

   if(TF!=Period())
      Alert("O TIME FRAME corrente está diferente do TimeFrame do Indicador. O indicador será plotado em uma nova janela.");

   ArraySetAsSeries(BollingerMeio,true);
   ArraySetAsSeries(BollingerCima,true);
   ArraySetAsSeries(BollingerBaixo,true);
   ArraySetAsSeries(BollingerFechamento,true);
   ArraySetAsSeries(BollingerPernaH2,true);
   ArraySetAsSeries(BollingerPernaL2,true);
   ArraySetAsSeries(BollingerPernaH3,true);
   ArraySetAsSeries(BollingerPernaL3,true);

//---

   mysymbolA.Name(SimboloPapelA);
   mysymbolB.Name(SimboloPapelB);
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.SetDeviationInPoints(50);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
   mytrade.SetTypeFilling(ORDER_FILLING_IOC);

   VolumePapel1 = VolumePapelA;
   VolumePapel2 = VolumePapelB;
   GlobalVariableSet(SVol_1,VolumePapel1);
   GlobalVariableSet(SVol_2,VolumePapel2);

   if(DesvioPerna1>=DesvioPerna2)
     {
      printf("Desvio1 Maior que Desvio2");
      return INIT_FAILED;
        } else if(DesvioPerna2>=DesvioPerna3){
      printf("Desvio2 Maior que Desvio3");
      return INIT_FAILED;
        } else if(DesvioPerna1>=DesvioPerna3){
      printf("Desvio3 Maior que Desvio1");
      return INIT_FAILED;
     }

   datetime first_date;
   SeriesInfoInteger(SimboloPapelA,_Period,SERIES_FIRSTDATE,first_date);

   int res=CheckLoadHistory(SimboloPapelA,_Period,first_date);
   switch(res)
     {
      case -1 : Print("Unknown symbol ",SimboloPapelA);             break;
      case -2 : Print("Requested bars more than max bars in chart"); break;
      case -3 : Print("Program was stopped");                        break;
      case -4 : Print("Indicator shouldn't load its own data");      break;
      case -5 : Print("Load failed");                                break;
      case  0 : Print("Loaded OK");                                  break;
      case  1 : Print("Loaded previously");                          break;
      case  2 : Print("Loaded previously and built");                break;
      default : Print("Unknown result");
     }

   SeriesInfoInteger(SimboloPapelB,_Period,SERIES_FIRSTDATE,first_date);

   res=CheckLoadHistory(SimboloPapelB,_Period,first_date);
   switch(res)
     {
      case -1 : Print("Unknown symbol ",SimboloPapelB);             break;
      case -2 : Print("Requested bars more than max bars in chart"); break;
      case -3 : Print("Program was stopped");                        break;
      case -4 : Print("Indicator shouldn't load its own data");      break;
      case -5 : Print("Load failed");                                break;
      case  0 : Print("Loaded OK");                                  break;
      case  1 : Print("Loaded previously");                          break;
      case  2 : Print("Loaded previously and built");                break;
      default : Print("Unknown result");
     }

// Criação dos manipuladores com Períodos curto e longo
//handleBollinger=iBands(_Symbol,_Period,PeriodoBollinger,0,Desvio,PRICE_CLOSE);
   handleBollinger=iCustom(_Symbol,TF,"::Indicators\\SG\\L&S_CO.ex5",BeginTime,SimboloPapelA,SimboloPapelB,Periodo,DesvioPerna1,DesvioPerna2,DesvioPerna3);

   if(TF==Period())
      ChartIndicatorAdd(ChartID(),ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),handleBollinger);
   else
     {
      ulong newChart=ChartOpen(Symbol(),TF);
      ChartIndicatorAdd(newChart,ChartGetInteger(newChart,CHART_WINDOWS_TOTAL),handleBollinger);
     }

// Verificação do resultado da criação dos manipuladores
   if(handleBollinger==INVALID_HANDLE)
     {
      Print("Erro na criação dos manipuladores");
      return INIT_FAILED;
     }
//---

   subwindow_number=ChartWindowFind(0,"LS");

   if(PositionSelect(_Symbol)==true) // we have an opened position
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         Buy_opened=true;  //It is a Buy
        }
      else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         Sell_opened=true; // It is a Sell
        }
     }

// Verifica o tipo de conta logado Netting ou Hedging
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      Print("Conta no modo hedging detectada. Tratando ordens como posicoes independentes...");
      accountModeHedge=true;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      Print("Conta no modo netting detectada. Tratando posicoes de forma consolidada...");
      accountModeHedge=false;
     }
//+------------------------------------------------------------------+

   BotaoFechar.Create(0,"BotaoFechar",0,(int)3*LARGURA_PAINEL/4-10,11,(int)LARGURA_PAINEL/4,30);
   BotaoFechar.Color(clrBlack);
   BotaoFechar.BackColor(clrAqua);
   BotaoFechar.Description("Close All");
   LabelLucro.Create(0,"LabelLucro",0,X_LABEL,4*Y_LABEL);
   LabelLucro.Color(clrAqua);
   LabelLucro.Description("Lucro Atual do L&S: "+AccountInfoString(ACCOUNT_CURRENCY)+" "+DoubleToString(LucroPositions(),2));
   LabelPailnel[0].Create(0,"LabelPorcentagem",0,X_LABEL,5*Y_LABEL+5);
   LabelPailnel[0].Color(clrAqua);
   LabelPailnel[0].Description("Lucro Percentual do L&S: "+DoubleToString(100*LucroPositions()/AccountInfoDouble(ACCOUNT_BALANCE),2)+"%");


   LabelPailnel[1].Create(0,"RatiosAtual",0,X_LABEL,6*Y_LABEL+10);
   LabelPailnel[1].Color(clrAqua);
   LabelPailnel[1].Description("Ratio Atual: ");

   LabelPailnel[2].Create(0,"RatiosEnt",0,X_LABEL,7*Y_LABEL+10);
   LabelPailnel[2].Color(clrAqua);
   LabelPailnel[2].Description("Ratio Real das Entradas: ");


   LabelPailnel[3].Create(0,"Perna 1",0,X_LABEL,8*Y_LABEL+10);
   LabelPailnel[3].Color(clrAqua);
   LabelPailnel[3].Description("-  Perna 1: ");

   LabelPailnel[4].Create(0,"Perna 2",0,X_LABEL,9*Y_LABEL+10);
   LabelPailnel[4].Color(clrAqua);
   LabelPailnel[4].Description("-  Perna 2: ");

   LabelPailnel[5].Create(0,"Perna 3",0,X_LABEL,10*Y_LABEL+10);
   LabelPailnel[5].Color(clrAqua);
   LabelPailnel[5].Description("-  Perna 3: ");

   LabelPailnel[6].Create(0,"TP",0,X_LABEL,11*Y_LABEL+10);
   LabelPailnel[6].Color(clrAqua);
   LabelPailnel[6].Description("-  Take Profit: ");


   LabelPailnel[7].Create(0,"Horario",0,X_LABEL,13*Y_LABEL+10);
   LabelPailnel[7].Color(clrAqua);
   LabelPailnel[7].Description("Horário Atual do Servidor: "+TimeToString(TimeCurrent(),TIME_SECONDS));

   string hr_permitido;

   LabelPailnel[8].Create(0,"HorarioValido",0,X_LABEL,14*Y_LABEL+10);
   LabelPailnel[8].Color(clrAqua);
   LabelPailnel[8].Description("Permitido Operar por Horário: "+hr_permitido);

   LabelVersao.Create(0,"LabelVersao",0,(int)3*LARGURA_PAINEL/4-20,ALTURA_PAINEL-20);
   LabelVersao.Color(clrWhite);
   LabelVersao.FontSize(9);
   LabelVersao.Font("Arial Black");
   LabelVersao.Description("Versão "+VERSION);

   for(int i=0;i<=8;i++)LabelPailnel[i].FontSize(9);
   LabelLucro.FontSize(8);

   ChartRedraw();

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   DeletaIndicadores();
// Motivo da desinicialização do EA
   printf("Deinit reason: %d",reason);
   if(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_DEBUG) || MQLInfoInteger(MQL_OPTIMIZATION))
     {
      GlobalVariablesDeleteAll(gvprefix);
     }
   ObjectsDeleteAll(0,0,OBJ_HLINE);
   ObjectsDeleteAll(0,0,OBJ_BUTTON);
   ObjectsDeleteAll(0,0,OBJ_LABEL);
   ObjectsDeleteAll(0,0,OBJ_BITMAP_LABEL);
   ObjectsDeleteAll(0,0,OBJ_RECTANGLE_LABEL);

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   mysymbolA.Refresh();
   mysymbolB.Refresh();
   mysymbolA.RefreshRates();
   mysymbolB.RefreshRates();

   if(!mysymbolA.Refresh() || !mysymbolB.Refresh() || !mysymbolA.RefreshRates() || !mysymbolB.RefreshRates())
      return;


   if(mysymbolA.Bid()>mysymbolA.Ask() || mysymbolB.Bid()>mysymbolB.Ask())//Leilão
      return;


   novodia=isNewBar(PERIOD_D1);

   if(novodia)
     {
      tradebar=true;

      GlobalVariableSet(IsBuy_rent2,GlobalVariableGet(IsBuy_rent2));GlobalVariableSet(IsSell_rent2,GlobalVariableGet(IsSell_rent2));
      GlobalVariableSet(IsBuy_rent3,GlobalVariableGet(IsBuy_rent3));GlobalVariableSet(IsSell_rent3,GlobalVariableGet(IsSell_rent3));
      GlobalVariableSet(Rent_Sell2,GlobalVariableGet(Rent_Sell2));GlobalVariableSet(Rent_Sell3,GlobalVariableGet(Rent_Sell3));
      GlobalVariableSet(Rent_Buy2,GlobalVariableGet(Rent_Buy2));GlobalVariableSet(Rent_Buy3,GlobalVariableGet(Rent_Buy3));
      GlobalVariableSet(SVol_1,GlobalVariableGet(SVol_1));GlobalVariableSet(SVol_2,GlobalVariableGet(SVol_2));

      GlobalVariableSet(Rent_Sell1,GlobalVariableGet(Rent_Sell1));
      GlobalVariableSet(Rent_Buy1,GlobalVariableGet(Rent_Buy1));

      ChartRedraw();

     }

   if(!tradebar)return;

   if(!PosicaoAberta())
     {
      GlobalVariableSet(IsBuy_rent2,0.0);GlobalVariableSet(IsSell_rent2,0.0);
      GlobalVariableSet(IsBuy_rent3,0.0);GlobalVariableSet(IsSell_rent3,0.0);
      GlobalVariableSet(Rent_Sell2,0.0);GlobalVariableSet(Rent_Sell3,0.0);
      GlobalVariableSet(Rent_Buy2,0.0);GlobalVariableSet(Rent_Buy3,0.0);
      GlobalVariableSet(Rent_Sell1,0.0);
      GlobalVariableSet(Rent_Buy1,0.0);
     }

// Cópia dos buffers dos indicadores de média móvel com períodos curto e longo

   CopyBuffer(handleBollinger,0,0,3,BollingerFechamento);
   CopyBuffer(handleBollinger,1,0,3,BollingerMeio);
   CopyBuffer(handleBollinger,2,0,3,BollingerCima);
   CopyBuffer(handleBollinger,3,0,3,BollingerBaixo);
   CopyBuffer(handleBollinger,4,0,3,BollingerPernaH2);
   CopyBuffer(handleBollinger,5,0,3,BollingerPernaL2);
   CopyBuffer(handleBollinger,6,0,3,BollingerPernaH3);
   CopyBuffer(handleBollinger,7,0,3,BollingerPernaL3);

   if(PosicaoAberta())
     {
      if(Buy_opened)
        {
         criarObjetos(GlobalVariableGet(Rent_Buy1),GlobalVariableGet(Rent_Buy2),GlobalVariableGet(Rent_Buy3),"Compra");
           } else if(Sell_opened) {
         criarObjetos(GlobalVariableGet(Rent_Sell1),GlobalVariableGet(Rent_Sell2),GlobalVariableGet(Rent_Sell3),"Venda");
        }

     }

   int operacoesPorCandle=TradeCount(_Period);

// Verificar estratégia e determinar compra ou venda

//--- we have no errors, so continue
//--- Do we have positions opened already?

   verificarPosicaoAberta();

   string resultado_cruzamento="";
   resultado_cruzamento=Cruzamento();

   if(Buy_opened==true || Sell_opened==true)
     {
      Fechamento();
     }

   verificarPosicaoAberta();

// Estratégia indicou compra
   if(resultado_cruzamento=="Compra")
      if(!Buy_opened)
        {
         Compra(SimboloPapelB);
         Venda(SimboloPapelA);
        }

// Estratégia indicou venda
   if(resultado_cruzamento=="Venda")
      if(!Sell_opened)
        {
         Compra(SimboloPapelA);
         Venda(SimboloPapelB);
        }

   if(resultado_cruzamento=="VendaPerna2")
      if(GlobalVariableGet(IsSell_rent2)==0.0)
        {
         if(Sell_opened)
           {
            CompraPerna2(SimboloPapelA);
            VendaPerna2(SimboloPapelB);
           }
        }

   if(resultado_cruzamento=="VendaPerna3")
      if(GlobalVariableGet(IsSell_rent3)==0.0)
        {
         if(Sell_opened)
           {
            CompraPerna3(SimboloPapelA);
            VendaPerna3(SimboloPapelB);
           }
        }

   if(resultado_cruzamento=="CompraPerna2")
      if(GlobalVariableGet(IsBuy_rent2)==0.0)
        {
         if(Buy_opened)
           {
            CompraPerna2(SimboloPapelB);
            VendaPerna2(SimboloPapelA);
           }
        }

   if(resultado_cruzamento=="CompraPerna3")
      if(GlobalVariableGet(IsBuy_rent3)==0.0)
        {
         if(Buy_opened)
           {
            CompraPerna3(SimboloPapelB);
            VendaPerna3(SimboloPapelA);
           }
        }

   if(accountModeHedge)
     {
      if(isNewBar(PERIOD_M1))
        {
         if(Buy_opened || Sell_opened)
           {
            VericarPernas();
           }
        }
     }

  }

//+------------------------------------------------------------------+
//| Realizar compra com parâmetros especificados por input           |
//+------------------------------------------------------------------+
void Compra(string Simbolo)
  {
   double vol=0;

   simbolo.Name(Simbolo);
   simbolo.RefreshRates();

   if(Simbolo==SimboloPapelA)
     {
      vol=VolumePapel1;
        } else {
      vol=VolumePapel2;
     }

//CopyBuffer(handleATR,0,0,1,m_ATR_buff_main);
//ArraySetAsSeries(m_ATR_buff_main,true);


   double price=simbolo.Ask();
   double stoploss=0; // Cálculo normalizado do stoploss
   double takeprofit=0; // Cálculo normalizado do takeprofit
                        //negocio.Buy(Volume, NULL, price, stoploss, takeprofit, "Compra CruzamentoMediaEA"); // Envio da ordem de compra pela classe responsável

// Verificação de posição aberta
   if(PositionSelect(Simbolo))
     {

      vol=2*vol;
     }

   mytrade.Buy(vol,Simbolo,price,0,0,"Compra");
   mytrade.ResultRetcodeDescription();

   GlobalVariableSet(Rent_Buy1,NormalizeDouble(BollingerCima[0],4));
   GlobalVariableSet(Rent_Buy2,NormalizeDouble(BollingerPernaH2[0],4));
   GlobalVariableSet(Rent_Buy3,NormalizeDouble(BollingerPernaH3[0],4));

   GlobalVariableSet(IsBuy_rent2,0.0);
   GlobalVariableSet(IsBuy_rent3,0.0);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CompraPerna2(string Simbolo)
  {

   simbolo.Name(Simbolo);
   simbolo.RefreshRates();

   double vol=0;

   if(Simbolo==SimboloPapelA)
     {
      vol=VolumePapel1;
        } else {
      vol=VolumePapel2;
     }

   double price=simbolo.Ask();

   mytrade.Buy(vol,Simbolo,price,0,0,"CompraPerna2");
   Print(mytrade.ResultRetcodeDescription());

   GlobalVariableSet(IsBuy_rent2,1.0);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CompraPerna3(string Simbolo)
  {

   simbolo.Name(Simbolo);
   simbolo.RefreshRates();

   double vol=0;

   if(Simbolo==SimboloPapelA)
     {
      vol=VolumePapel1;
        } else {
      vol=VolumePapel2;
     }

   double price=simbolo.Ask();

   mytrade.Buy(vol,Simbolo,price,0,0,"CompraPerna3");
   mytrade.ResultRetcodeDescription();

   GlobalVariableSet(IsBuy_rent3,1.0);

  }
//+------------------------------------------------------------------+
//| Realizar venda com parâmetros especificados por input            |
//+------------------------------------------------------------------+
void VendaPerna2(string Simbolo)
  {

   double vol=0;

   if(Simbolo==SimboloPapelA)
     {
      vol=VolumePapel1;
        } else {
      vol=VolumePapel2;
     }

   simbolo.Name(Simbolo);
   simbolo.RefreshRates();

//CopyBuffer(handleATR,0,0,1,m_ATR_buff_main);
//ArraySetAsSeries(m_ATR_buff_main,true);

   double stoplossATR=0;

   double price=simbolo.Bid();

   mytrade.Sell(vol,Simbolo,price,0,0,"VendaPerna2");
   mytrade.ResultRetcodeDescription();

   GlobalVariableSet(IsSell_rent2,1.0);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void VendaPerna3(string Simbolo)
  {

   double vol=0;

   if(Simbolo==SimboloPapelA)
     {
     
      vol=VolumePapel1;
        } else {
      vol=VolumePapel2;
     }

   simbolo.Name(Simbolo);
   simbolo.RefreshRates();

//CopyBuffer(handleATR,0,0,1,m_ATR_buff_main);
//ArraySetAsSeries(m_ATR_buff_main,true);

   double stoplossATR=0;

   double price=simbolo.Bid();

//--- Preenchimento da requisição

   mytrade.Sell(vol,Simbolo,price,0,0,"VendaPerna3");
   mytrade.ResultRetcodeDescription();

   GlobalVariableSet(IsSell_rent3,1.0);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Venda(string Simbolo)
  {
   double vol;
   if(Simbolo==SimboloPapelA)
     {
      vol=VolumePapel1;
     }
   else
     {
      vol=VolumePapel2;
     }

// Verificação de posição aberta
   if(PositionSelect(Simbolo))
     {
      vol=2*vol;
     }

   simbolo.Name(Simbolo);
   simbolo.RefreshRates();

//CopyBuffer(handleATR,0,0,1,m_ATR_buff_main);
//ArraySetAsSeries(m_ATR_buff_main,true);

   double stoplossATR=0;

   double price=simbolo.Bid();

   mytrade.Sell(vol,Simbolo,price,0,0,"Venda");
   mytrade.ResultRetcodeDescription();

   GlobalVariableSet(Rent_Sell1,NormalizeDouble(BollingerBaixo[0],4));
   GlobalVariableSet(Rent_Sell2,NormalizeDouble(BollingerPernaL2[0],4));
   GlobalVariableSet(Rent_Sell3,NormalizeDouble(BollingerPernaL3[0],4));

   GlobalVariableSet(IsSell_rent2,0.0);
   GlobalVariableSet(IsSell_rent3,0.0);


  }
//+------------------------------------------------------------------+
//| Fechar posição aberta                                            |
//+------------------------------------------------------------------+
void Fechar(string Simbolo,string Comentario)
  {

   if(OrdersTotal()!=0)
     {
      for(int i=OrdersTotal()-1; i>=0; i--)
        {
         ulong ticket=OrderGetTicket(i);
         if(OrderGetString(ORDER_SYMBOL)==Simbolo)
           {
            ZeroMemory(sg_request);
            ZeroMemory(sg_result);
            ZeroMemory(sg_check_result);
            sg_request.action       =TRADE_ACTION_REMOVE;
            sg_request.order        =ticket;

            //--- Checagem e envio de ordens
            ResetLastError();
            if(!OrderCheck(sg_request,sg_check_result))
              {
               PrintFormat("Erro em OrderCheck: %d",GetLastError());
               PrintFormat("Código de Retorno: %d",sg_check_result.retcode);
               return;
              }

            if(!OrderSend(sg_request,sg_result))
              {
               PrintFormat("Erro em OrderSend: %d",GetLastError());
               PrintFormat("Código de Retorno: %d",sg_result.retcode);
              }
           }
        }
     }

// Verificação de posição aberta
   if(!PositionSelect(Simbolo))
      return;

   int posTotal=PositionsTotal();
//for(int i=PositionsTotal()-1;i>=0; i>=0)
   for(int posIndex=PositionsTotal()-1;posIndex>=0;posIndex--)
     {
      ulong ticket=PositionGetTicket(posIndex);
      if(PositionSelectByTicket(ticket) && 
         PositionGetString(POSITION_SYMBOL)==Simbolo &&
         PositionGetInteger(POSITION_MAGIC)==Magic_Number)
        {

         //posType   = PositionGetInteger(POSITION_TYPE);
         //posLots   = PositionGetDouble(POSITION_VOLUME);


         // Limpar informações das estruturas
         ZeroMemory(sg_request);
         ZeroMemory(sg_result);
         ZeroMemory(sg_check_result);
         double pos_volume=PositionGetDouble(POSITION_VOLUME);
         //--- Preenchimento da requisição
         sg_request.action       =TRADE_ACTION_DEAL;
         sg_request.magic        =Magic_Number;
         sg_request.symbol       =Simbolo;
         sg_request.volume       =pos_volume;
         sg_request.type_filling =ORDER_FILLING_IOC;
         sg_request.comment      ="Fechamento " + Comentario;

         if(accountModeHedge)
           {
            sg_request.position=ticket;
           }

         long tipo=PositionGetInteger(POSITION_TYPE); // Tipo da posição aberta

                                                      // Vender em caso de posição comprada
         if(tipo==POSITION_TYPE_BUY)
            //negocio.Sell(Volume, NULL, 0, 0, 0, "Fechamento CruzamentoMediaEA");
           {
            sg_request.price        =simbolo.Bid();
            sg_request.type         =ORDER_TYPE_SELL;
           }
         // Comprar em caso de posição vendida
         else
         //negocio.Buy(Volume, NULL, 0, 0, 0, "Fechamento CruzamentoMediaEA");
           {
            sg_request.price        =simbolo.Ask();
            sg_request.type         =ORDER_TYPE_BUY;
           }

         //--- Checagem e envio de ordens
         ResetLastError();
         if(!OrderCheck(sg_request,sg_check_result))
           {
            PrintFormat("Erro em OrderCheck: %d",GetLastError());
            PrintFormat("Código de Retorno: %d",sg_check_result.retcode);
            return;
           }

         if(!OrderSend(sg_request,sg_result))
           {
            PrintFormat("Erro em OrderSend: %d",GetLastError());
            PrintFormat("Código de Retorno: %d",sg_result.retcode);
           }

        }
     }

//ObjectsDeleteAll(0,subwindow_number,-1);
   ObjectsDeleteAll(0,subwindow_number,OBJ_HLINE);

   string arquivo=SimboloPapelA+"_"+SimboloPapelB+".csv";

   bool fechou=FileDelete(arquivo);

  }
//+------------------------------------------------------------------+
//| Verificar se há posição aberta                                   |
//+------------------------------------------------------------------+
bool SemPosicao()
  {
   bool resultado=!PositionSelect(_Symbol);
   return resultado;
  }
//+------------------------------------------------------------------+
//| Verificar se há ordem aberta                                     |
//+------------------------------------------------------------------+
bool SemOrdem()
  {
   for(int i=OrdersTotal()-1; i>=0; i--)
     {
      OrderGetTicket(i);
      if(OrderGetString(ORDER_SYMBOL)==_Symbol)
         return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Fechamento()
  {
   if(Sell_opened)
     {
      if(myCloseBandValue0>myMiddleBandValue0)
        {
         Fechar(SimboloPapelA,"Média");
         Fechar(SimboloPapelB,"Média");
        }
     }

   if(Buy_opened)
     {
      if(myCloseBandValue0<myMiddleBandValue0)
        {
         Fechar(SimboloPapelA,"Média");
         Fechar(SimboloPapelB,"Média");
        }
     }


   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Cruzamento()
  {

   myMiddleBandValue0=NormalizeDouble(BollingerMeio[0],4);
   myUpperBandValue0=NormalizeDouble(BollingerCima[0], 4);
   myLowerBandValue0=NormalizeDouble(BollingerBaixo[0], 4);
   myCloseBandValue0=NormalizeDouble(BollingerFechamento[0], 4);


// Venda
   if(!Sell_opened)
     {
      if((myCloseBandValue0<myLowerBandValue0) && (myCloseBandValue0>NormalizeDouble(BollingerPernaL2[0],4)))
        {
         return "Venda";
        }
     }
// Compra
   if(!Buy_opened)
     {
      if((myCloseBandValue0>myUpperBandValue0) && (myCloseBandValue0<NormalizeDouble(BollingerPernaH2[0],4)))
         return "Compra";
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Sell_opened)
     {
      if((myCloseBandValue0<GlobalVariableGet(Rent_Sell2)) && (myCloseBandValue0>GlobalVariableGet(Rent_Sell3)))
         if(GlobalVariableGet(IsSell_rent2)==0.0)
           {
            return "VendaPerna2";
           }

      if(myCloseBandValue0<GlobalVariableGet(Rent_Sell3))
         if(GlobalVariableGet(IsSell_rent3)==0.0 && GlobalVariableGet(IsSell_rent2) != 0.0)
           {
            return "VendaPerna3";
           }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(Buy_opened)
     {
      if((myCloseBandValue0>GlobalVariableGet(Rent_Buy2)) && (myCloseBandValue0<GlobalVariableGet(Rent_Buy3)))
         if(GlobalVariableGet(IsBuy_rent2)==0.0)
           {
            return "CompraPerna2";
           }

      if(myCloseBandValue0>GlobalVariableGet(Rent_Buy3))
         if(GlobalVariableGet(IsBuy_rent3)==0.0 || GlobalVariableGet(IsBuy_rent2)!=0.0)
           {
            return "CompraPerna3";
           }
     }

   return "Nada";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TradeCount(ENUM_TIMEFRAMES TimeFrame)
  {
//---

   int      Cnt;
   ulong    Ticket;
   long     EntryType;
   datetime DT[1];

   Cnt=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(CopyTime(Symbol(),TimeFrame,0,1,DT)<=0)
     {
      Cnt=-1;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      HistorySelect(DT[0],TimeCurrent());

      for(int i=HistoryDealsTotal()-1; i>=0; i--)
        {
         Ticket    = HistoryDealGetTicket(i);
         EntryType = HistoryDealGetInteger(Ticket, DEAL_ENTRY);

         if(EntryType==DEAL_ENTRY_IN || DEAL_ENTRY_INOUT)
            if(Symbol()==HistoryDealGetString(Ticket,DEAL_SYMBOL))
              {
               Cnt++;
              }
        }
     }

//---
   return(Cnt);
  }
//+------------------------------------------------------------------+

double OnTester()
  {

   double sqrtWins=MathSqrt(TesterStatistics(STAT_PROFIT_TRADES));
   double sqrtLosses=MathSqrt(TesterStatistics(STAT_LOSS_TRADES));

   double AvgWinningTrade=(TesterStatistics(STAT_GROSS_PROFIT)-(STAT_WITHDRAWAL))/TesterStatistics(STAT_PROFIT_TRADES);
   double AvgLosingTrade =  TesterStatistics(STAT_GROSS_LOSS)/TesterStatistics(STAT_LOSS_TRADES);

   return ( ((AvgWinningTrade * (TesterStatistics(STAT_PROFIT_TRADES) - sqrtWins) ) -
           (-AvgLosingTrade *(TesterStatistics(STAT_LOSS_TRADES)+sqrtLosses)))/
           TesterStatistics(STAT_INITIAL_DEPOSIT))*100;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int roundUp(int numToRound,int multiple)
  {
   if(multiple==0)
      return numToRound;

   int remainder= numToRound%multiple;
   if(remainder == 0)
      return numToRound;

   return numToRound + multiple - remainder;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void criarObjetos(double entrada,double sinalReentrada2,double sinalReentrada3,string perna)
  {
   ObjectCreate(0,"Perna1"+perna,OBJ_HLINE,1,0,entrada);

   ObjectCreate(0,"Perna2"+perna,OBJ_HLINE,1,0,sinalReentrada2);

   ObjectCreate(0,"Perna3"+perna,OBJ_HLINE,1,0,sinalReentrada3);
  }
//+------------------------------------------------------------------+
int CheckLoadHistory(string symbol,ENUM_TIMEFRAMES period,datetime start_date)
  {
   datetime first_date=0;
   datetime times[100];
//--- verifica ativo e período 
   if(symbol==NULL || symbol=="") symbol=Symbol();
   if(period==PERIOD_CURRENT)     period=Period();
//--- verifica se o ativo está selecionado no Observador de Mercado 
   if(!SymbolInfoInteger(symbol,SYMBOL_SELECT))
     {
      if(GetLastError()==ERR_MARKET_UNKNOWN_SYMBOL) return(-1);
      SymbolSelect(symbol,true);
     }
//--- verifica se os dados estão presentes 
   SeriesInfoInteger(symbol,period,SERIES_FIRSTDATE,first_date);
   if(first_date>0 && first_date<=start_date) return(1);
//--- não pede para carregar seus próprios dados se ele for um indicador 
   if(MQL5InfoInteger(MQL5_PROGRAM_TYPE)==PROGRAM_INDICATOR && Period()==period && Symbol()==symbol)
      return(-4);
//--- segunda tentativa 
   if(SeriesInfoInteger(symbol,PERIOD_M1,SERIES_TERMINAL_FIRSTDATE,first_date))
     {
      //--- existe dados carregados para construir a série de tempo 
      if(first_date>0)
        {
         //--- força a construção da série de tempo 
         CopyTime(symbol,period,first_date+PeriodSeconds(period),1,times);
         //--- verifica 
         if(SeriesInfoInteger(symbol,period,SERIES_FIRSTDATE,first_date))
            if(first_date>0 && first_date<=start_date) return(2);
        }
     }
//--- máximo de barras em um gráfico a partir de opções do terminal 
   int max_bars=TerminalInfoInteger(TERMINAL_MAXBARS);
//--- carrega informações de histórico do ativo 
   datetime first_server_date=0;
   while(!SeriesInfoInteger(symbol,PERIOD_M1,SERIES_SERVER_FIRSTDATE,first_server_date) && !IsStopped())
      Sleep(5);
//--- corrige data de início para carga 
   if(first_server_date>start_date) start_date=first_server_date;
   if(first_date>0 && first_date<first_server_date)
      Print("Aviso: primeira data de servidor ",first_server_date," para ",symbol,
            " não coincide com a primeira data de série ",first_date);
//--- carrega dados passo a passo 
   int fail_cnt=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   while(!IsStopped())
     {
      //--- espera pela construção da série de tempo 
      while(!SeriesInfoInteger(symbol,period,SERIES_SYNCHRONIZED) && !IsStopped())
         Sleep(5);
      //--- pede por construir barras 
      int bars=Bars(symbol,period);
      if(bars>0)
        {
         if(bars>=max_bars) return(-2);
         //--- pede pela primeira data 
         if(SeriesInfoInteger(symbol,period,SERIES_FIRSTDATE,first_date))
            if(first_date>0 && first_date<=start_date) return(0);
        }
      //--- cópia da próxima parte força carga de dados 
      int copied=CopyTime(symbol,period,bars,100,times);
      if(copied>0)
        {
         //--- verifica dados 
         if(times[0]<=start_date)  return(0);
         if(bars+copied>=max_bars) return(-2);
         fail_cnt=0;
        }
      else
        {
         //--- não mais que 100 tentativas com falha 
         fail_cnt++;
         if(fail_cnt>=100) return(-5);
         Sleep(10);
        }
     }
//--- interrompido 
   return(-3);
  }
//+------------------------------------------------------------------+

double LucroPositions()
  {
   double profit=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
         if(myposition.Symbol()==mysymbolA.Name() || myposition.Symbol()==mysymbolB.Name())
            profit+=myposition.Profit();

   return (profit);
  }
//+------------------------------------------------------------------+
void CloseALL()
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && (myposition.Symbol()==mysymbolA.Name() || myposition.Symbol()==mysymbolB.Name()))
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
bool PosicaoAberta()
  {
   if(myposition.SelectByMagic(SimboloPapelA,Magic_Number) || myposition.SelectByMagic(SimboloPapelB,Magic_Number))
      return true;
   else return(false);
  }
//+------------------------------------------------------------------+

void DeleteALL()
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      ulong o_ticket=OrderGetTicket(j);
      if(o_ticket!=0)
        {
         myorder.Select(o_ticket);
         if(myorder.Magic()==Magic_Number && (myorder.Symbol()==mysymbolA.Name() || myorder.Symbol()==mysymbolB.Name())) mytrade.OrderDelete(o_ticket);
        }
     }
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(StringFind(sparam,"BotaoFechar")!=-1)
        {
         CloseALL();
         ObjectSetInteger(0,"BotaoFechar",OBJPROP_STATE,false);
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

double LucroOrdens()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   MqlDateTime stm_end,time_aux;
   TimeToStruct(tm_end,stm_end);
   time_aux=stm_end;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);
   HistorySelect(tm_start,tm_end);
   int total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if((mydeal.Symbol()==mysymbolA.Name() || mydeal.Symbol()==mysymbolB.Name()) && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
           {
            profit+=mydeal.Profit();
           }
     }

   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeletaIndicadores()
  {
   string name;
//--- O número de janelas no gráfico (ao menos uma janela principal está sempre presente) 
   int windows=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
//--- Verifique todas as janelas 
   for(int w=windows-1;w>=0;w--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      //--- o número de indicadores nesta janela/sub-janela 
      int total=ChartIndicatorsTotal(0,w);
      //--- Passar por todos os indicadores na janela 
      for(int i=total-1;i>=0;i--)
        {
         //--- obtém o nome abreviado do indicador 
         name=ChartIndicatorName(0,w,i);
         ChartIndicatorDelete(0,w,name);
        }

     }
  }
//+------------------------------------------------------------------+

bool CheckNewBar(ENUM_TIMEFRAMES tf)
  {

   static datetime LastBar=0;
   datetime ThisBar=iTime(Symbol(),tf,0);
   if(LastBar!=ThisBar)
     {
      LastBar=ThisBar;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+

double CalcularFinanceiroPosicoes()
  {

   double financeiro=0;

   for(int i=PositionsTotal()-1;i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && (myposition.Symbol()==mysymbolA.Name() || myposition.Symbol()==mysymbolB.Name()))
        {
         if(myposition.PositionType()==POSITION_TYPE_BUY)
           {
            financeiro+=myposition.Volume()*myposition.PriceOpen();
           }
        }

     }

   return (financeiro);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| TradeTransaction function                                        |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long     deal_ticket       =0;
      long     deal_order        =0;
      long     deal_time         =0;
      long     deal_time_msc     =0;
      ENUM_DEAL_TYPE     deal_type=-1;
      long     deal_entry        =-1;
      long     deal_magic        =0;
      long     deal_reason       =-1;
      long     deal_position_id  =0;
      double   deal_volume       =0.0;
      double   deal_price        =0.0;
      double   deal_commission   =0.0;
      double   deal_swap         =0.0;
      double   deal_profit       =0.0;
      string   deal_symbol       ="";
      string   deal_comment      ="";
      string   deal_external_id  ="";
      if(HistoryDealSelect(trans.deal))
        {
         deal_ticket       =HistoryDealGetInteger(trans.deal,DEAL_TICKET);
         deal_order        =HistoryDealGetInteger(trans.deal,DEAL_ORDER);
         deal_time         =HistoryDealGetInteger(trans.deal,DEAL_TIME);
         deal_time_msc     =HistoryDealGetInteger(trans.deal,DEAL_TIME_MSC);
         deal_type         =HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_entry        =HistoryDealGetInteger(trans.deal,DEAL_ENTRY);
         deal_magic        =HistoryDealGetInteger(trans.deal,DEAL_MAGIC);
         deal_reason       =HistoryDealGetInteger(trans.deal,DEAL_REASON);
         deal_position_id  =HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);

         deal_volume       =HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_price        =HistoryDealGetDouble(trans.deal,DEAL_PRICE);
         deal_commission   =HistoryDealGetDouble(trans.deal,DEAL_COMMISSION);
         deal_swap         =HistoryDealGetDouble(trans.deal,DEAL_SWAP);
         deal_profit       =HistoryDealGetDouble(trans.deal,DEAL_PROFIT);

         deal_symbol       =HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_comment      =HistoryDealGetString(trans.deal,DEAL_COMMENT);
         deal_external_id  =HistoryDealGetString(trans.deal,DEAL_EXTERNAL_ID);

         if(deal_magic==Magic_Number)
           {
            string order_exec="Ordem executada ticket: "+(string)deal_order+", "+EnumToString(deal_type)+", "+"Volume: "+deal_volume+" "+deal_symbol;
            TesterWithdrawal(Custo);
            Print(order_exec);
            if(TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED))SendNotification(order_exec);
           }

        }
      else
         return;

     }

  }
//+------------------------------------------------------------------+

void verificarPosicaoAberta()
  {

   Buy_opened=false;  // variable to hold the result of Buy opened position
   Sell_opened=false; // variables to hold the result of Sell opened position

   if(myposition.SelectByMagic(SimboloPapelB,Magic_Number)==true) // we have an opened position
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         Buy_opened=true;  //It is a Buy
        }
      else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         Sell_opened=true; // It is a Sell
        }
     }

  }
//+------------------------------------------------------------------+

void VericarPernas()
  {
//--- request trade history 
   int total_deals=0;

   perna1.quantidade=0;
   perna1.volume=0;
   perna2.quantidade=0;
   perna2.volume=0;
   perna3.quantidade=0;
   perna3.volume=0;

   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
         if(myposition.Symbol()==mysymbolA.Name() || myposition.Symbol()==mysymbolB.Name())
           {
            HistorySelectByPosition(myposition.Ticket());

            int total_deals=HistoryDealsTotal();
            ulong ticket=0;
            double profit=0;
            for(int i=0;i<total_deals;i++) // returns the number of current orders
              {
               ticket=HistoryDealGetTicket(i);
               mydeal.Ticket(ticket);
               if(ticket>0)
                  if((mydeal.Symbol()==mysymbolA.Name() || mydeal.Symbol()==mysymbolB.Name()) && mydeal.Magic()==Magic_Number)
                    {
                     if(mydeal.Comment()=="Compra" || mydeal.Comment()=="Venda")
                       {
                        perna1.quantidade+=1;
                        perna1.volume+=mydeal.Volume();
                       }

                     if(mydeal.Comment()=="CompraPerna2" || mydeal.Comment()=="VendaPerna2")
                       {
                        perna2.quantidade+=1;
                        perna2.volume+=mydeal.Volume();
                       }
                     if(mydeal.Comment()=="CompraPerna3" || mydeal.Comment()=="VendaPerna3")
                       {
                        perna3.quantidade+=1;
                        perna3.volume+=mydeal.Volume();
                       }
                    }
              }
           }

   if(perna1.quantidade!=2 && perna1.quantidade!=0)
     {
      FecharDespernado(SimboloPapelA,"Compra","Venda");
      FecharDespernado(SimboloPapelB,"Compra","Venda");
      tradebar=false;
     }

   if(perna2.quantidade!=2 && perna2.quantidade!=0)
     {
      FecharDespernado(SimboloPapelA,"CompraPerna2","VendaPerna2");
      FecharDespernado(SimboloPapelB,"CompraPerna2","VendaPerna2");
      GlobalVariableSet(IsBuy_rent2, 0.0);
      GlobalVariableSet(IsSell_rent2, 0.0);
      tradebar=false;
     }

   if(perna3.quantidade!=2 && perna3.quantidade!=0)
     {
      FecharDespernado(SimboloPapelA,"CompraPerna3","VendaPerna3");
      FecharDespernado(SimboloPapelB,"CompraPerna3","VendaPerna3");
       GlobalVariableSet(IsBuy_rent3, 0.0);
      GlobalVariableSet(IsSell_rent3, 0.0);
      tradebar=false;
     }
  }
//+------------------------------------------------------------------+

void FecharDespernado(string Simbolo,string Comentario1,string Comentario2)
  {

// Verificação de posição aberta
   if(!PositionSelect(Simbolo))
      return;

   int posTotal=PositionsTotal();
//for(int i=PositionsTotal()-1;i>=0; i>=0)
   for(int posIndex=PositionsTotal()-1;posIndex>=0;posIndex--)
     {
      ulong ticket=PositionGetTicket(posIndex);
      if(PositionSelectByTicket(ticket) && 
         PositionGetString(POSITION_SYMBOL)==Simbolo &&
         PositionGetInteger(POSITION_MAGIC)==Magic_Number && (PositionGetString(POSITION_COMMENT)==Comentario1 || PositionGetString(POSITION_COMMENT) == Comentario2))
        {
         // Limpar informações das estruturas
         ZeroMemory(sg_request);
         ZeroMemory(sg_result);
         ZeroMemory(sg_check_result);
         double pos_volume=PositionGetDouble(POSITION_VOLUME);
         //--- Preenchimento da requisição
         sg_request.action       =TRADE_ACTION_DEAL;
         sg_request.magic        =Magic_Number;
         sg_request.symbol       =Simbolo;
         sg_request.volume       =pos_volume;
         sg_request.type_filling =ORDER_FILLING_IOC;
         sg_request.comment      ="Fechamento " + "Despernamento";

         if(accountModeHedge)
           {
            sg_request.position=ticket;
           }

         long tipo=PositionGetInteger(POSITION_TYPE); // Tipo da posição aberta

                                                      // Vender em caso de posição comprada
         if(tipo==POSITION_TYPE_BUY)
            //negocio.Sell(Volume, NULL, 0, 0, 0, "Fechamento CruzamentoMediaEA");
           {
            sg_request.price        =simbolo.Bid();
            sg_request.type         =ORDER_TYPE_SELL;
           }
         // Comprar em caso de posição vendida
         else
         //negocio.Buy(Volume, NULL, 0, 0, 0, "Fechamento CruzamentoMediaEA");
           {
            sg_request.price        =simbolo.Ask();
            sg_request.type         =ORDER_TYPE_BUY;
           }

         //--- Checagem e envio de ordens
         ResetLastError();
         if(!OrderCheck(sg_request,sg_check_result))
           {
            PrintFormat("Erro em OrderCheck: %d",GetLastError());
            PrintFormat("Código de Retorno: %d",sg_check_result.retcode);
            return;
           }

         if(!OrderSend(sg_request,sg_result))
           {
            PrintFormat("Erro em OrderSend: %d",GetLastError());
            PrintFormat("Código de Retorno: %d",sg_result.retcode);
           }

        }
     }

//ObjectsDeleteAll(0,subwindow_number,-1);
   ObjectsDeleteAll(0,subwindow_number,OBJ_HLINE);

   string arquivo=SimboloPapelA+"_"+SimboloPapelB+".csv";

   bool fechou=FileDelete(arquivo);

  }
//+------------------------------------------------------------------+


datetime          m_lastbar_time;   // Time of opening last bar
uint              m_retcode;        // Result code of detecting new bar 
int               m_new_bars;       // Number of new bars
string            m_comment;        // Comment of execution
//+------------------------------------------------------------------+
int isNewBar(ENUM_TIMEFRAMES period)
  {
   datetime newbar_time;
   datetime lastbar_time=m_lastbar_time;

//--- Request time of opening last bar:
   ResetLastError(); // Set value of predefined variable _LastError as 0.
   if(!SeriesInfoInteger(Symbol(),period,SERIES_LASTBAR_DATE,newbar_time))
     { // If request has failed, print error message:
      m_retcode=GetLastError();  // Result code of detecting new bar: write value of variable _LastError
      m_comment=__FUNCTION__+" Error when getting time of last bar opening: "+IntegerToString(m_retcode);
      return(0);
     }

//---Next use first type of request for new bar, to complete analysis:
   if(!isNewBarr(newbar_time)) return(0);

//---Correct number of new bars:
   m_new_bars=Bars(Symbol(),period,lastbar_time,newbar_time)-1;

//--- If we've reached this line - then there is(are) new bar(s), return their number:
   return(m_new_bars);
  }
  
  bool isNewBarr(datetime newbar_time)
  {
//--- Initialization of protected variables
   m_new_bars = 0;      // Number of new bars
   m_retcode  = 0;      // Result code of detecting new bar: 0 - no error
   m_comment  =__FUNCTION__+" Successful check for new bar";

//--- Just to be sure, check: is the time of (hypothetically) new bar m_newbar_time less than time of last bar m_lastbar_time? 
   if(m_lastbar_time>newbar_time)
     { // If new bar is older than last bar, print error message
      m_comment=__FUNCTION__+" Synchronization error: time of previous bar "+TimeToString(m_lastbar_time)+
                ", time of new bar request "+TimeToString(newbar_time);
      m_retcode=-1;     // Result code of detecting new bar: return -1 - synchronization error
      return(false);
     }

//--- if it's the first call 
   if(m_lastbar_time==0)
     {
      m_lastbar_time=newbar_time; //--- set time of last bar and exit
      m_comment=__FUNCTION__+" Initialization of lastbar_time = "+TimeToString(m_lastbar_time);
      return(false);
     }

//--- Check for new bar: 
   if(m_lastbar_time<newbar_time)
     {
      m_new_bars=1;               // Number of new bars
      m_lastbar_time=newbar_time; // remember time of last bar
      return(true);
     }

//--- if we've reached this line, then the bar is not new; return false
   return(false);
  }