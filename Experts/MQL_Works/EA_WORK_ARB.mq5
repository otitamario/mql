//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#define VERSION "2.0"
#property copyright "Mario"
#property version VERSION



#property icon "\\Files\\UltimateBot.ico"
//#resource "\\Indicators\\L&S.ex5"
//#resource "\\Images\\UltimateBot.bmp"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TipoEnt
  {
   Compra,//Compra
   Venda//Venda
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Estrategia
  {
   BuyASellB,//Compra A, Vende B
   BuyBSellA,//Compra B, Vende A
   EstNone//Nenhuma
  };
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct PosPerna
  {
   ENUM_POSITION_TYPE postypeA;
   double            _loteA;
   ulong             ticketA;
   ENUM_POSITION_TYPE postypeB;
   double            _loteB;
   ulong             ticketB;
  };

#include <ChartObjects\ChartObjectsLines.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>
#include <ChartObjects\ChartObjectsBmpControls.mqh>

#include <Controls\Defines.mqh>
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
//#undef CONTROLS_LABEL_COLOR

color borda_bg = clrNONE;                //Cor Borda
color painel_bg = clrBlack;              //Cor Painel
color cor_txt_borda_bg = clrYellowGreen; //Cor Texto Borda
                                         //color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG painel_bg
#define CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg

#include <SG\Expert_Class_SG.mqh>
#include <SG\statistics.mqh>

#define TENTATIVAS 50  //Tentativas de envio de Ordem
#define LARGURA_PAINEL 300 // Largura Painel
#define ALTURA_PAINEL 320  // Altura Painel

#define X_LABEL 11
#define Y_LABEL 15

// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia
ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT; //TIMEFRAME ROBO
input int MAGIC_NUMBER=20082018;
input string SEstrateg="############-----------------------------Estratégia---------------------------########"; //Estratégia
input double  Lots=0.01;              //Lots size 
datetime BeginTime=D'1970.01.01';                                                                               //Data inicial para Indicador
input string SimboloA="EURJPY";//Ativo Adicional
string SimboloB=Symbol();
input TipoEnt EntB=Compra;//Direção Ativo do Gráfico
input TipoEnt EntA=Venda;//Direção Ativo Adicional
input double pips_entry=10;//Spread Pips Entrada
input double min_profit=16.0;//Lucro em Moeda Para fechar Posições.
input double max_loss=16.0;//Prejuízo em Moeda Para fechar Posições.
input string shorario="############------FILTRO DE HORARIO------#################"; //Horário
input bool UseTimer=false;//Usar Filtro de Horário: True/False
input string start_hour="10:15";//Horario Inicial
input string end_hour="16:40";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario
sinput string sdias = "FILTRO DOS DIAS DA SEMANA";                                    //Dias da Semana
input bool trade0 = true;                                                             // Operar Domingo
input bool trade1 = true;                                                             // Operar Segunda
input bool trade2 = true;                                                             // Operar Terça
input bool trade3 = true;                                                             // Operar Quarta
input bool trade4 = true;                                                             // Operar Quinta
input bool trade5 = true;                                                             // Operar Sexta
input bool trade6 = true;                                                             // Operar Sábado
                                                                                      //input double Custo= 0;
//input Funcao funcao=PROM;                                                             // Função de avaliação
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int extTickDelay=2;//Atraso no Tick
int dias_op,horas_op,minut_op,sec_op;
bool opt_tester=MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_PROFILER) || MQLInfoInteger(MQL_VISUAL_MODE);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyRobot : public MyExpert
  {
private:
   CChartObjectHLine HLine_Perna1,HLine_Perna2,HLine_Perna3;
   //  CChartObjectEdit  Retangulo;
   CChartObjectBmpLabel FotoLess;
   CChartObjectButton BotaoFechar;
   CChartObjectLabel LabelLucro;
   CChartObjectLabel LabelPailnel[50];
   string            currency_symbol;
   double            sl,tp,price_open;
   int               bol_handle;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   CNewBar           Bar_RefreshIndicator;
   CSymbolInfo       mysymbolA,mysymbolB;
   double            loteA,loteB;
   double            lot_stepB;
   bool              check_marginA,check_marginB;
   double            margin_A,margin_B;
   double            closeA[],closeB[];
   double            pips;
   Estrategia        MyEstrategy;
   string            mensagem;
   double            Ask_A,Ask_B,Bid_A,Bid_B;
   double            spread;
   bool              Error_Init;
   bool              Conexao;
   bool              IsHedge;
   int               count_envios;
public:
   void              MyRobot();
   void             ~MyRobot();
   int               OnInit();
   void              OnDeinit(const int reason);
   void              OnTick();
   void              OnTimer();

   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);

   string GetCurrency() { return SymbolInfoString(original_symbol,SYMBOL_CURRENCY_BASE); }
   bool              TimeDayFilter();
   bool              PosicaoAberta_SymbolA();
   bool              PosicaoAberta_SymbolB();
   void              CheckClose();
   double            CalculoLote(double valor,double price,double lotemin);
   void              ClosePos_AB();
   double            LucroAberto();
   double            LucroOrdens();
   void              LOAD_DATA();
   int               CheckLoadHistory(string symbol,ENUM_TIMEFRAMES period,datetime start_date);
   void              AtualizaTimeOp();
   void              CreatePanel();
   void              PanelUpdate();
   bool              MyOrderCalcMargin(const ENUM_ORDER_TYPE action,const string marg_symbol,const double volume,const double price,double &margin);
   bool              PosicaoAberta();
   double            PrecoMedio(ENUM_POSITION_TYPE ptype);
   double            VolPosType(ENUM_POSITION_TYPE ptype);
   void              CheckConnection();
   bool              IsConnect();
  };

MyRobot MyEA;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::MyRobot(){};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::~MyRobot(){};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::OnInit(void)
  {

   loteA=Lots;
   loteB=Lots;
   Conexao=IsConnect();
   EventSetMillisecondTimer(200);
   Error_Init=true;
   LOAD_DATA();
   IsHedge=myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING;
   tradeOn=true;
   setExpName();
   setSymbol(Symbol());
   setOriginalSymbol(Symbol());
   setMagic(MAGIC_NUMBER);
   if(SymbolInfoInteger(SimboloA,SYMBOL_EXPIRATION_MODE)==2)
      order_time_type=1;
   else
      order_time_type=0;
   mysymbolA.Name(SimboloA);
   mysymbolB.Name(SimboloB);
   mytrade.SetExpertMagicNumber(MAGIC_NUMBER);
   mytrade.SetDeviationInPoints(5000000);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
   mytrade.SetTypeFilling(ORDER_FILLING_RETURN);
   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);
   if(ticksize==0.00001 || ticksize==0.001)
      pips=ticksize*10;
   else pips=ticksize;
   lot_stepB=SymbolInfoDouble(SimboloB,SYMBOL_VOLUME_STEP);
   gv.Init(SimboloA+SimboloB,Magic_Number);
   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today_prev",(double)TimeNow.day_of_year);
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   setNameGvOrder();


   if(EntA==Compra && EntB==Venda)MyEstrategy=BuyASellB;
   if(EntA==Venda && EntB==Compra) MyEstrategy=BuyBSellA;
   else MyEstrategy=EstNone;

   ArraySetAsSeries(closeA,true);
   ArraySetAsSeries(closeB,true);

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(ChartID(),CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

   if(!MQLInfoInteger(MQL_OPTIMIZATION))
      CreatePanel();

   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTimer()
  {
   CheckConnection();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   DeletaIndicadores();

// Motivo da desinicialização do EA
   printf("Deinit reason: %d",reason);
   ObjectsDeleteAll(0,0,OBJ_HLINE);
   ObjectsDeleteAll(0,0,OBJ_BUTTON);
   ObjectsDeleteAll(0,0,OBJ_LABEL);
   ObjectsDeleteAll(0,0,OBJ_BITMAP_LABEL);
   ObjectsDeleteAll(0,0,OBJ_RECTANGLE_LABEL);
   EventKillTimer();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTick(void)
  {
   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today",(double)TimeNow.day_of_year);

   bool novodia;
   novodia=Bar_NovoDia.CheckNewBar(SimboloB,PERIOD_D1);
   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      tradeOn=true;
     }

   gv.Set("gv_today_prev",gv.Get("gv_today"));

   mysymbolA.Refresh();
   mysymbolB.Refresh();
   mysymbolA.RefreshRates();
   mysymbolB.RefreshRates();

   PanelUpdate();

   Bid_A=mysymbolA.Bid();
   Bid_B=mysymbolB.Bid();
   Ask_A=mysymbolA.Ask();
   Ask_B=mysymbolB.Ask();

   lucro_total=LucroAberto();
   mensagem="\n"+"\n"+"\n"+"\n"+"\n"+
            SimboloA+" BID: "+DoubleToString(Bid_A,_Digits)+"\n"+
            SimboloA+" ASK: "+DoubleToString(Ask_A,_Digits)+"\n"+
            SimboloB+" BID: "+DoubleToString(Bid_B,_Digits)+"\n"+
            SimboloB+" ASK: "+DoubleToString(Ask_B,_Digits)+"\n"+
            "Spread: "+DoubleToString(spread,_Digits)+"\n"+
            "Spread em Pips: "+DoubleToString(spread/pips,_Digits)+"\n"+
            "Lucro Aberto: "+DoubleToString(lucro_total,2);
   Comment(mensagem);

   if(!mysymbolA.Refresh() || !mysymbolB.Refresh() || !mysymbolA.RefreshRates() || !mysymbolB.RefreshRates())
      return;
   if(!mysymbolA.IsSynchronized() || !mysymbolB.IsSynchronized())//Símbolos não sincronizados
      return;
   if(mysymbolA.Bid()>mysymbolA.Ask() || mysymbolB.Bid()>mysymbolB.Ask()) //Leilão
      return;

   if(mysymbolA.Bid()==0 || mysymbolA.Ask()==0 || mysymbolB.Bid()==0 || mysymbolB.Ask()==0)
      return;

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   if(!Conexao)//Sem Conexão
      return;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer)
     {
      if(hora_inicial>hora_final)
        {
         if(!(TimeCurrent()<=hora_final || TimeCurrent()>=hora_inicial))
           {
            if(OrdersTotal()>0 && daytrade)ClosePos_AB();
            return;
           }
        }
      else
        {
         if(!(TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final))
           {
            if(OrdersTotal()>0 && daytrade)ClosePos_AB();
            return;
           }
        }
     }
   else timerOn=true;

   if(!timerOn && daytrade)
     {
      if(PositionsTotal()>0)
         ClosePos_AB();
     }

   AtualizaTimeOp();

   if(!PosicaoAberta_SymbolA() && !PosicaoAberta_SymbolB())
     {
      gv.Set("pos_ab", 0.0);
      gv.Set("time_op", 0.0);
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(tradeOn && timerOn)

     { // inicio Trade On

      if(MyEstrategy==BuyASellB)spread=Ask_A-Bid_B;
      if(MyEstrategy==BuyBSellA)spread=Ask_B-Bid_A;
      else spread=Bid_B-Bid_A;

      if(lucro_total>=min_profit || lucro_total<=-max_loss)
        {
         ClosePos_AB();
         Print("Saída Por Lucro ou Prejuízo");
         return;
        }

      if(MathAbs(spread)<=pips_entry*pips)
        {
         if(MyEstrategy==BuyBSellA)
           {

            if(gv.Get("pos_ab")==0.0) //Compra B, Vende A
              {

               check_marginB = OrderCalcMargin(ORDER_TYPE_BUY, SimboloB, loteB, mysymbolB.Ask(), margin_B);
               check_marginA = OrderCalcMargin(ORDER_TYPE_SELL, SimboloA, loteA, mysymbolA.Bid(), margin_A);


               if(margin_A+margin_B<=myaccount.Equity())
                 {

                  if(mytrade.Sell(loteA,SimboloA,0,0,0,"SELL_"+exp_name))
                    {
                     if(mytrade.ResultDeal()==0)
                       {
                        if(mytrade.ResultRetcode()==10009)Print("Ordem Enviada à Corretora, esperando execução"); // trade order went to the exchange
                        else
                          {
                           Print("Venda Não Executada. Return code=",mytrade.ResultRetcode(),
                                 ". Code description: ",mytrade.ResultRetcodeDescription());
                           Sleep(1000);
                           return;//Não tenta a compra
                          }
                       }
                     else
                       {
                        gv.Set(vd_tick,(double)mytrade.ResultOrder());
                        Print("Venda executada com successo. Return code=",mytrade.ResultRetcode(),
                              " (",mytrade.ResultRetcodeDescription(),")");
                       }
                    }
                  else
                    {
                     Print("Erro enviar ordem ",GetLastError());
                     Print("Venda Não Executada. Return code=",mytrade.ResultRetcode(),
                           ". Code description: ",mytrade.ResultRetcodeDescription());
                     Sleep(1000);
                     return;//Não tenta a compra
                    }

                  if(mytrade.Buy(loteB,SimboloB,0,0,0,"BUY_"+exp_name))
                    {
                     if(mytrade.ResultDeal()==0)
                       {
                        if(mytrade.ResultRetcode()==10009)Print("Ordem Enviada à Corretora, esperando execução"); // trade order went to the exchange
                        else  Print("Compra Não Executada. Return code=",mytrade.ResultRetcode(),
                           ". Code description: ",mytrade.ResultRetcodeDescription());
                       }
                     else
                       {
                        gv.Set(cp_tick,(double)mytrade.ResultOrder());
                        Print("Compra executada com successo. Return code=",mytrade.ResultRetcode(),
                              " (",mytrade.ResultRetcodeDescription(),")");
                       }
                    }
                  else
                    {
                     Print("Erro enviar ordem ",GetLastError());
                     Print("Compra Não Executada. Return code=",mytrade.ResultRetcode(),
                           ". Code description: ",mytrade.ResultRetcodeDescription());
                    }

                  gv.Set("pos_ab",1.0);
                 }
               else
                 {
                  Print("Margem Insuficiente");
                  return;
                 }
              }
           }

         else// Sell B,Buy A
           {

            if(gv.Get("pos_ab")==0.0) //Compra A, Vende B
              {

               check_marginB = OrderCalcMargin(ORDER_TYPE_SELL, SimboloB, loteB, mysymbolB.Bid(), margin_B);
               check_marginA = OrderCalcMargin(ORDER_TYPE_BUY, SimboloA, loteA, mysymbolA.Ask(), margin_A);


               if(margin_A+margin_B<=myaccount.Equity())
                 {

                  if(mytrade.Sell(loteB,SimboloB,0,0,0,"SELL_"+exp_name))
                    {
                     if(mytrade.ResultDeal()==0)
                       {
                        if(mytrade.ResultRetcode()==10009)Print("Ordem Enviada à Corretora, esperando execução"); // trade order went to the exchange
                        else
                          {
                           Print("Venda Não Executada. Return code=",mytrade.ResultRetcode(),
                                 ". Code description: ",mytrade.ResultRetcodeDescription());
                           Sleep(1000);
                           return;//Não tenta a compra
                          }
                       }
                     else
                       {
                        gv.Set(vd_tick,(double)mytrade.ResultOrder());
                        Print("Venda executada com successo. Return code=",mytrade.ResultRetcode(),
                              " (",mytrade.ResultRetcodeDescription(),")");
                       }
                    }
                  else
                    {
                     Print("Erro enviar ordem ",GetLastError());
                     Print("Venda Não Executada. Return code=",mytrade.ResultRetcode(),
                           ". Code description: ",mytrade.ResultRetcodeDescription());
                     Sleep(1000);
                     return;//Não tenta a compra
                    }

                  if(mytrade.Buy(loteA,SimboloA,0,0,0,"BUY_"+exp_name))
                    {
                     if(mytrade.ResultDeal()==0)
                       {
                        if(mytrade.ResultRetcode()==10009)Print("Ordem Enviada à Corretora, esperando execução"); // trade order went to the exchange
                        else  Print("Compra Não Executada. Return code=",mytrade.ResultRetcode(),
                           ". Code description: ",mytrade.ResultRetcodeDescription());
                       }
                     else
                       {
                        gv.Set(cp_tick,(double)mytrade.ResultOrder());
                        Print("Compra executada com successo. Return code=",mytrade.ResultRetcode(),
                              " (",mytrade.ResultRetcodeDescription(),")");
                       }
                    }
                  else
                    {
                     Print("Erro enviar ordem ",GetLastError());
                     Print("Compra Não Executada. Return code=",mytrade.ResultRetcode(),
                           ". Code description: ",mytrade.ResultRetcodeDescription());
                    }

                  gv.Set("pos_ab",1.0);
                 }
               else
                 {
                  Print("Margem Insuficiente");
                  return;
                 }
              }

           }

        }
      if(Bar_RefreshIndicator.CheckNewBar(Symbol(),periodoRobo))
        {

        }

     } //End Trade On

   if(PosicaoAberta_SymbolA() && !PosicaoAberta_SymbolB())ClosePos_AB();
   if(PosicaoAberta_SymbolB() && !PosicaoAberta_SymbolA())ClosePos_AB();

  } //Fim Ontick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::LOAD_DATA()
  {
   datetime first_date;
   SeriesInfoInteger(SimboloA,_Period,SERIES_FIRSTDATE,first_date);

   int res=CheckLoadHistory(SimboloA,_Period,first_date);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   switch(res)
     {
      case -1:
         Print("Unknown symbol ",SimboloA);
         Error_Init=true;
         break;
      case -2:
         Print("Requested bars more than max bars in chart");
         Error_Init=true;
         break;
      case -3:
         Print("Program was stopped");
         Error_Init=true;
         break;
      case -4:
         Print("Indicator shouldn't load its own data");
         Error_Init=true;
         break;
      case -5:
         Print("Load failed");
         Error_Init=true;
         break;
      case 0:
         Print("Loaded OK");
         Error_Init=false;
         break;
      case 1:
         Print("Loaded previously");
         Error_Init=false;
         break;
      case 2:
         Print("Loaded previously and built");
         Error_Init=false;
         break;
      default:
         Print("Unknown result");
         Error_Init=true;
     }

   SeriesInfoInteger(SimboloB,_Period,SERIES_FIRSTDATE,first_date);

   res=CheckLoadHistory(SimboloB,_Period,first_date);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   switch(res)
     {
      case -1:
         Print("Unknown symbol ",SimboloB);
         Error_Init=true;
         break;
      case -2:
         Print("Requested bars more than max bars in chart");
         Error_Init=true;
         break;
      case -3:
         Print("Program was stopped");
         Error_Init=true;
         break;
      case -4:
         Print("Indicator shouldn't load its own data");
         Error_Init=true;
         break;
      case -5:
         Print("Load failed");
         Error_Init=true;
         break;
      case 0:
         Print("Loaded OK");
         Error_Init=false;
         break;
      case 1:
         Print("Loaded previously");
         Error_Init=false;
         break;
      case 2:
         Print("Loaded previously and built");
         Error_Init=false;
         break;
      default:
         Print("Unknown result");
         Error_Init=true;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::CheckLoadHistory(string Inpsymbol,ENUM_TIMEFRAMES Inpperiod,datetime start_date)
  {
   datetime first_date=0;
   datetime times[100];
//--- verifica ativo e período
   if(Inpsymbol== NULL|| Inpsymbol== "")
      Inpsymbol= Symbol();
   if(Inpperiod== PERIOD_CURRENT)
      Inpperiod= Period();
//--- verifica se o ativo está selecionado no Observador de Mercado
   if(!SymbolInfoInteger(Inpsymbol,SYMBOL_SELECT))
     {
      if(GetLastError()==ERR_MARKET_UNKNOWN_SYMBOL)
         return (-1);
      SymbolSelect(Inpsymbol,true);
     }
//--- verifica se os dados estão presentes
   SeriesInfoInteger(Inpsymbol,Inpperiod,SERIES_FIRSTDATE,first_date);
   if(first_date>0 && first_date<=start_date)
      return (1);
//--- não pede para carregar seus próprios dados se ele for um indicador
   if(MQL5InfoInteger(MQL5_PROGRAM_TYPE)==PROGRAM_INDICATOR && Period()==Inpperiod && Symbol()==Inpsymbol)
      return (-4);
//--- segunda tentativa
   if(SeriesInfoInteger(Inpsymbol,PERIOD_M1,SERIES_TERMINAL_FIRSTDATE,first_date))
     {
      //--- existe dados carregados para construir a série de tempo
      if(first_date>0)
        {
         //--- força a construção da série de tempo
         CopyTime(Inpsymbol,Inpperiod,first_date+PeriodSeconds(period),1,times);
         //--- verifica
         if(SeriesInfoInteger(Inpsymbol,Inpperiod,SERIES_FIRSTDATE,first_date))
            if(first_date>0 && first_date<=start_date)
               return (2);
        }
     }
//--- máximo de barras em um gráfico a partir de opções do terminal
   int max_bars=TerminalInfoInteger(TERMINAL_MAXBARS);
//--- carrega informações de histórico do ativo
   datetime first_server_date=0;
   while(!SeriesInfoInteger(Inpsymbol,PERIOD_M1,SERIES_SERVER_FIRSTDATE,first_server_date) && !IsStopped())
      Sleep(5);
//--- corrige data de início para carga
   if(first_server_date>start_date)
      start_date=first_server_date;
   if(first_date>0 && first_date<first_server_date)
      Print("Aviso: primeira data de servidor ",first_server_date," para ",Inpsymbol,
            " não coincide com a primeira data de série ",first_date);
//--- carrega dados passo a passo
   int fail_cnt=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   while(!IsStopped())
     {
      //--- espera pela construção da série de tempo
      while(!SeriesInfoInteger(Inpsymbol,Inpperiod,SERIES_SYNCHRONIZED) && !IsStopped())
         Sleep(5);
      //--- pede por construir barras
      int bars=Bars(Inpsymbol,Inpperiod);
      if(bars>0)
        {
         if(bars>=max_bars)
            return (-2);
         //--- pede pela primeira data
         if(SeriesInfoInteger(Inpsymbol,Inpperiod,SERIES_FIRSTDATE,first_date))
            if(first_date>0 && first_date<=start_date)
               return (0);
        }
      //--- cópia da próxima parte força carga de dados
      int copied=CopyTime(Inpsymbol,Inpperiod,bars,100,times);
      if(copied>0)
        {
         //--- verifica dados
         if(times[0]<=start_date)
            return (0);
         if(bars+copied>=max_bars)
            return (-2);
         fail_cnt=0;
        }
      else
        {
         //--- não mais que 100 tentativas com falha
         fail_cnt++;
         if(fail_cnt>=100)
            return (-5);
         Sleep(10);
        }
     }
//--- interrompido
   return (-3);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MyRobot::CheckClose()
  {
   if(PosicaoAberta_SymbolA() && PosicaoAberta_SymbolB())
     {

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::ClosePos_AB()
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && (myposition.Symbol()==mysymbolA.Name() || myposition.Symbol()==mysymbolB.Name()))
        {
         if(!mytrade.PositionClose(PositionGetTicket(i),5000000))
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::AtualizaTimeOp()
  {
   int tempo_oper=(int)(TimeCurrent() -(int)(gv.Get("time_op")));
   int resto;
   if(gv.Get("time_op")>0)
     {
      dias_op=tempo_oper/86400;
      resto=tempo_oper%86400;
      horas_op=resto/3600;
      resto=resto%3600;
      minut_op=resto/60;
      sec_op=resto%60;
     }
   else
     {
      dias_op=0;
      horas_op=0;
      minut_op=0;
      sec_op=0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::TimeDayFilter()
  {
   bool filter;
   MqlDateTime TimeToday;
   TimeToStruct(TimeCurrent(),TimeToday);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   switch(TimeToday.day_of_week)
     {
      case 0:
         filter=trade0;
         break;
      case 1:
         filter=trade1;
         break;
      case 2:
         filter=trade2;
         break;
      case 3:
         filter=trade3;
         break;
      case 4:
         filter=trade4;
         break;
      case 5:
         filter=trade5;
         break;
      case 6:
         filter=trade6;
         break;
      default:
         filter=false;
         break;
     }
   return filter;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MyRobot::PosicaoAberta_SymbolA()
  {
   if(myposition.SelectByMagic(SimboloA,Magic_Number))
      return true;
   else
      return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MyRobot::PosicaoAberta_SymbolB()
  {
   if(myposition.SelectByMagic(SimboloB,Magic_Number))
      return true;
   else
      return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::PosicaoAberta()
  {
   return (PosicaoAberta_SymbolA() || PosicaoAberta_SymbolB());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::PrecoMedio(ENUM_POSITION_TYPE ptype)
  {
   double vol=0;
   double preco=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && (myposition.Symbol()==mysymbolA.Name() || myposition.Symbol()==mysymbolB.Name()))
        {
         vol+=myposition.Volume();
         preco+=myposition.Volume()*myposition.PriceOpen();
        }
     }
   if(VolPosType(ptype)>0)
      preco=preco/VolPosType(ptype);
   preco=NormalizeDouble(MathRound(preco/ticksize)*ticksize,digits);
   return preco;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::VolPosType(ENUM_POSITION_TYPE ptype)
  {
   double vol= 0;
   for(int i = PositionsTotal()-1; i>= 0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && (myposition.Symbol()==mysymbolA.Name() || myposition.Symbol()==mysymbolB.Name()))
        {
         vol+=myposition.Volume();
        }
     }
   return vol;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::LucroAberto()
  {
   double profit=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && (myposition.Symbol()==mysymbolA.Name() || myposition.Symbol()==mysymbolB.Name()))
         profit+=myposition.Profit();
   return profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::LucroOrdens()
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
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if((mydeal.Symbol()==mysymbolA.Name() || mydeal.Symbol()==mysymbolB.Name()) && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::CalculoLote(double valor,double price,double lotemin)
  {
   double lotes=MathMax(MathCeil(valor/(price*lotemin))*lotemin,lotemin);
   return lotes;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::MyOrderCalcMargin(const ENUM_ORDER_TYPE action,const string marg_symbol,const double volume,const double price,double &margin)
  {
   double MarginInit,MarginMain;

   const bool Res=SymbolInfoMarginRate(symbol,action,MarginInit,MarginMain);

   margin=Res ? MarginInit*price*volume*SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE)/
          (SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE)*AccountInfoInteger(ACCOUNT_LEVERAGE))
          : 0;

   return (Res);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MyRobot::OnTradeTransaction(const MqlTradeTransaction &trans,
                                 const MqlTradeRequest &request,
                                 const MqlTradeResult &result)
  {
//--- get transaction type as enumeration value
//--- if transaction is result of addition of the transaction in history
   if(trans.type==TRADE_TRANSACTION_DEAL_ADD)
     {

      if(trans.symbol!=SimboloA && trans.symbol!=SimboloB)
         return;


      long deal_ticket= 0;
      long deal_order = 0;
      long deal_time=0;
      long deal_time_msc=0;
      ENUM_DEAL_TYPE deal_type=-1;
      long deal_entry = -1;
      long deal_magic = 0;
      long deal_reason= -1;
      long deal_position_id=0;
      double deal_volume= 0.0;
      double deal_price = 0.0;
      double deal_commission=0.0;
      double deal_swap=0.0;
      double deal_profit = 0.0;
      string deal_symbol = "";
      string deal_comment= "";
      string deal_external_id="";
      if(HistoryDealSelect(trans.deal))
        {
         deal_ticket= HistoryDealGetInteger(trans.deal,DEAL_TICKET);
         deal_order = HistoryDealGetInteger(trans.deal,DEAL_ORDER);
         deal_time=HistoryDealGetInteger(trans.deal,DEAL_TIME);
         deal_time_msc=HistoryDealGetInteger(trans.deal,DEAL_TIME_MSC);
         deal_type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_entry = HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
         deal_magic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
         deal_reason= HistoryDealGetInteger(trans.deal,DEAL_REASON);
         deal_position_id=HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);

         deal_volume= HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_price = HistoryDealGetDouble(trans.deal,DEAL_PRICE);
         deal_commission=HistoryDealGetDouble(trans.deal,DEAL_COMMISSION);
         deal_swap=HistoryDealGetDouble(trans.deal,DEAL_SWAP);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);

         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_comment=HistoryDealGetString(trans.deal,DEAL_COMMENT);
         deal_external_id=HistoryDealGetString(trans.deal,DEAL_EXTERNAL_ID);

         if(deal_magic==Magic_Number)
           {
            string order_exec="Ordem executada ticket: "+(string)deal_order+", "+EnumToString(deal_type)+", "+"Volume: "+DoubleToString(deal_volume,2)+" "+deal_symbol;
            Print(order_exec);
            //TesterWithdrawal(Custo);
            if(TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED))
               SendNotification(order_exec);

            if(deal_comment=="BUY_"+exp_name)
              {
               gv.Set("time_op",(double)TimeCurrent());
              }

/*            if(deal_comment=="BUY_LOWER"+exp_name)
              {
               gv.Set("Rent_Buy1",Boll_Inf[0]);
              }

            if(deal_comment=="SELL_UPPER"+exp_name)
              {
               gv.Set("Rent_Sell1",Boll_Sup[0]);
              }
*/

           }
        }
      else
         return;
     }

   else if(trans.type==TRADE_TRANSACTION_ORDER_UPDATE)
     {

      if((trans.symbol!=SimboloA) && (trans.symbol!=SimboloB))
         return;


      switch(trans.order_type)
        {
         case ORDER_TYPE_BUY:
         case ORDER_TYPE_SELL:
            switch(trans.order_state)
              {
               case ORDER_STATE_PLACED:
                  Print("Ordem com ticket ",trans.order," colocada com sucesso.");
                  break;
               case ORDER_STATE_CANCELED:
                  Print("Ordem com ticket ",trans.order," cancelada.");
                  break;
               case ORDER_STATE_STARTED:
                  Print("Ordem com ticket ",trans.order," iniciada.");
                  break;
               case ORDER_STATE_FILLED:
                  Print("Ordem com ticket ",trans.order," preenchida integralmente.");
                  break;
               case ORDER_STATE_PARTIAL:
                  Print("Ordem com ticket ",trans.order," preenchida parcialmente.");
                  break;
               case ORDER_STATE_EXPIRED:
                  Print("Ordem com ticket ",trans.order," expirou.");
                  break;
               case ORDER_STATE_REJECTED:
                  Print("Ordem com ticket ",trans.order," foi rejeitada.");
                  break;
              }
            break;
        }
     }

   else if(trans.type==TRADE_TRANSACTION_REQUEST)
     {

      // Foi enviada uma nova ordem para o servidor
      if(request.magic!=MAGIC_NUMBER)
        {
         // A ordem nao foi deste EA, desconsidera a mesma
         //Print("Ordem recebida de um EA diferente, com Magic: ", request.magic);
         return;
        }

      if(request.action==TRADE_ACTION_DEAL)
        {
         if((result.retcode==TRADE_RETCODE_DONE) || (result.retcode==TRADE_RETCODE_PLACED))
           {
            Print("Ordem de ",(request.type==ORDER_TYPE_BUY?"compra":"venda")," executada com sucesso.");
           }
         else
           {
            Print("Erro enviando ordem de ",(request.type==ORDER_TYPE_BUY?"compra":"venda"),": ",result.retcode);
           }
        }

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::IsConnect()
  {
   return ((bool)TerminalInfoInteger(TERMINAL_CONNECTED));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void MyRobot::CheckConnection()
  {
   string msg;
   if(!(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_OPTIMIZATION) || IsStopped()))
     {
      if(Conexao!=IsConnect())
        {
         if(IsConnect())msg="Conexão Reestabelecida";
         else msg="Conexão Perdida";
         Print(msg);
         Alert(msg);
         if(TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(msg);
        }
      Conexao=IsConnect();
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::CreatePanel()
  {
/* Retangulo.Create(0, "Retangulo", 0, 0, 0, LARGURA_PAINEL, ALTURA_PAINEL);
   Retangulo.Corner(CORNER_LEFT_UPPER);
   Retangulo.BackColor(clrBlack);
   Retangulo.Color(clrSilver);
   Retangulo.Background(false);
   Retangulo.Style(STYLE_SOLID);
   Retangulo.BorderType(BORDER_FLAT);
*/
/*
   FotoLess.Create(ChartID(),"FotoLS",0,0,0);
   FotoLess.BmpFileOn("::Images\\UltimateBot.bmp");
   FotoLess.BmpFileOff("::Images\\UltimateBot.bmp");

   FotoLess.SetInteger(OBJPROP_XSIZE,331);//LARGURA_PAINEL);
   FotoLess.SetInteger(OBJPROP_YSIZE,251);//ALTURA_PAINEL);
   FotoLess.Corner(CORNER_LEFT_UPPER);
   FotoLess.Background(false);
   FotoLess.State(false);
*/
   color CorLegenda=clrAqua;
   BotaoFechar.Create(0, "BotaoFechar", 0, (int)3 * LARGURA_PAINEL / 4 , 11, (int)LARGURA_PAINEL / 4, 30);
   BotaoFechar.Color(clrBlack);
   BotaoFechar.BackColor(clrAqua);
   BotaoFechar.Description("Close All");
   LabelLucro.Create(0, "LabelLucro", 0, X_LABEL,  Y_LABEL);
   LabelLucro.Color(CorLegenda);
   LabelLucro.Width(10);
   LabelLucro.Description("Lucro Aberto : " + AccountInfoString(ACCOUNT_CURRENCY) + " " + DoubleToString(LucroAberto(), 2));

   LabelPailnel[0].Create(0, "LabelLucroDia", 0, X_LABEL, 2 * Y_LABEL + 10);
   LabelPailnel[0].Color(CorLegenda);
   LabelPailnel[0].Description("Lucro Dia : " + AccountInfoString(ACCOUNT_CURRENCY) + " " + DoubleToString(LucroAberto()+LucroOrdens(), 2));

   LabelPailnel[0].FontSize(9);
   LabelLucro.FontSize(9);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::PanelUpdate()
  {
   LabelLucro.Description("Lucro Aberto : "+AccountInfoString(ACCOUNT_CURRENCY)+" "+DoubleToString(LucroAberto(),2));
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   LabelPailnel[0].Description("Lucro Dia : "+AccountInfoString(ACCOUNT_CURRENCY)+" "+DoubleToString(LucroAberto()+LucroOrdens(),2));

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   MyEA.OnTradeTransaction(trans,request,result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
  {


   ChartSetInteger(ChartID(),CHART_COLOR_BACKGROUND,clrBlack);
   ChartSetInteger(ChartID(),CHART_COLOR_FOREGROUND,clrWhite);
   ChartSetInteger(ChartID(),CHART_COLOR_GRID,clrLightSlateGray);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_UP,clrLime);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_DOWN,clrRed);
   ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BULL,clrLime);
   ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BEAR,clrRed);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_LINE,clrMidnightBlue);
   ChartSetInteger(ChartID(),CHART_COLOR_VOLUME,clrMediumBlue);
   ChartSetInteger(ChartID(),CHART_COLOR_BID,clrBrown);
   ChartSetInteger(ChartID(),CHART_COLOR_ASK,clrMediumBlue);
   ChartSetInteger(ChartID(),CHART_COLOR_LAST,clrLightSlateGray);
   ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

   if(!ChartSetInteger(ChartID(),CHART_SHIFT,0,50))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }

   return MyEA.OnInit();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   MyEA.OnDeinit(reason);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   MyEA.OnTimer();
   if(!opt_tester)MyEA.OnTick();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   if(opt_tester)MyEA.OnTick();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID
                  const long &lparam,   // event parameter of the long type
                  const double &dparam, // event parameter of the double type
                  const string &sparam) // event parameter of the string type
  {
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(StringFind(sparam,"BotaoFechar")!=-1)
        {
         MyEA.ClosePos_AB();
         ObjectSetInteger(0,"BotaoFechar",OBJPROP_STATE,false);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
