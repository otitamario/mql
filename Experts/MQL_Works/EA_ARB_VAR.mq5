//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include<ChartObjects\ChartObjectsLines.mqh>
#include <Controls\Defines.mqh>
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
//#undef CONTROLS_LABEL_COLOR  

color borda_bg=clrNONE;//Cor Borda
color painel_bg=clrBlack;//Cor Painel 
color cor_txt_borda_bg=clrYellowGreen;//Cor Texto Borda
                                      //color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG          borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg

#include <Expert_Class_New.mqh>
#include <statistics.mqh>

MyPanel ExtDialog;

CLabel            m_label[50];
CRadioGroup radio_ativar;
CButton BotaoBuyA;
CButton BotaoBuyB;
CButton BotaoSellA;
CButton BotaoSellB;
CTrade mytradePanel;

#define LARGURA_PAINEL 300 // Largura Painel
#define ALTURA_PAINEL 230 // Altura Painel




// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input int MAGIC_NUMBER=20082018;
input string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input string   SimboloA="INDJ19";//Ativo Adicional 
string SimboloB=Symbol();
input double loteB=25;//Lote do Ativo
input   double loteA=5;//Lote do Ativo Adicional
input uint nticks_spread=4;//Ticks de spread Entrada
input double lucro_spread_exit=200;//Lucro Saída em Reais
input double prej_spread_exit=200;//Prejuízo Saída em Reais
input string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:00";//Horario Inicial
input string end_hour="17:30";//Horario Final
input bool daytrade=true;//Fechar Posição Daytrade ao Fim do Horario
sinput string sdias="FILTRO DOS DIAS DA SEMANA";//Dias da Semana
input bool trade0=true;// Operar Domingo
input bool trade1=true;// Operar Segunda
input bool trade2=true;// Operar Terça
input bool trade3=true;// Operar Quarta
input bool trade4=true;// Operar Quinta
input bool trade5=true;// Operar Sexta
input bool trade6=true;// Operar Sábado
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyRobot: public MyExpert
  {
private:
   string            currency_symbol;
   double            sl,tp,price_open;
   int               bol_handle;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   CSymbolInfo       mysymbolA,mysymbolB;

public:
   void              MyRobot();
   void             ~MyRobot();
   int               OnInit();
   void              OnDeinit(const int reason);
   void              OnTick();
   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);

   string GetCurrency(){return SymbolInfoString(original_symbol,SYMBOL_CURRENCY_BASE);}
   bool              TimeDayFilter();
   bool              PosicaoAberta_SymbolA();
   bool              PosicaoAberta_SymbolB();
   void              CheckClose();
   double            CalculoLote(double valor,double price,double lotemin);
   void              ClosePos_AB();
   double            LucroAberto();
  };

MyRobot MyEA;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::MyRobot()
  {
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::~MyRobot()
  {
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::OnInit(void)
  {

   tradeOn=true;
   setExpName();
   setSymbol(Symbol());
   setOriginalSymbol(Symbol());
   setMagic(MAGIC_NUMBER);
   if(SymbolInfoInteger(SimboloA,SYMBOL_EXPIRATION_MODE)==2)order_time_type=1;
   else order_time_type=0;
   mysymbolA.Name(SimboloA);
   mysymbolB.Name(SimboloB);
   mytrade.SetExpertMagicNumber(MAGIC_NUMBER);
   mytrade.SetDeviationInPoints(50);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
   mytrade.SetTypeFillingBySymbol(original_symbol);
   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);

   gv.Init(SimboloA+SimboloB,Magic_Number);
   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today_prev",(double)TimeNow.day_of_year);
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   setNameGvOrder();

   ChartSetInteger(ChartID(),CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   if(loteB<mysymbolB.LotsMin())
     {
      string erro="lote ativo < Lote Mímino";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   if(loteA<mysymbolA.LotsMin())
     {
      string erro="lote ativo Adicional < Lote Mímino";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

   if(lucro_spread_exit<=0 || prej_spread_exit<=0)
     {
      string erro="Lucro e Prejuízo das Operações devem ser >0";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }
   if(nticks_spread<=1)
     {
      string erro="Número de ticks de sread Entrada deve ser MAIOR que 1";
      MessageBox(erro);
      Print(erro);
      return (INIT_PARAMETERS_INCORRECT);
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   return (INIT_SUCCEEDED);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   DeletaIndicadores();
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

   if(!mysymbolA.Refresh() || !mysymbolB.Refresh() || !mysymbolA.RefreshRates() || !mysymbolB.RefreshRates())
      return;


   if(mysymbolA.Bid()>mysymbolA.Ask() || mysymbolB.Bid()>mysymbolB.Ask())//Leilão
      return;

   if(mysymbolA.Bid()==0 || mysymbolA.Ask()==0 || mysymbolB.Bid()==0 || mysymbolB.Ask()==0)
      return;


   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   timerOn=true;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
     }

   if(!timerOn && daytrade)
     {
      if(PositionsTotal()>0)ClosePos_AB();
     }

   if(tradeOn && timerOn)

     {// inicio Trade On

      if(!PosicaoAberta_SymbolA() && !PosicaoAberta_SymbolB())
        {

         if(MathAbs(mysymbolA.Bid()-mysymbolB.Ask())>=nticks_spread*mysymbolA.TickSize())
           {
            mytrade.Sell(loteA,SimboloA,0);
            mytrade.Buy(loteB,SimboloB,0);
           }
        }
      if(PositionsTotal()>0)CheckClose();
     }//End Trade On

  }//Fim Ontick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::CheckClose()
  {
   if(LucroAberto()>=lucro_spread_exit || LucroAberto()<=-prej_spread_exit)
     {
      ClosePos_AB();
      Print("Sapida por SL ou TP");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::ClosePos_AB()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
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
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::TimeDayFilter()
  {
   bool filter;
   MqlDateTime TimeToday;
   TimeToStruct(TimeCurrent(),TimeToday);
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
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::PosicaoAberta_SymbolB()
  {
   if(myposition.SelectByMagic(SimboloB,Magic_Number))
      return true;
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::LucroAberto()
  {
   double profit=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && (myposition.Symbol()==mysymbolA.Name() || myposition.Symbol()==mysymbolB.Name()))
         profit+=myposition.Profit();
   return profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::CalculoLote(double valor,double price,double lotemin)
  {
   double lotes=MathMax(MathRound(valor/(price*lotemin))*lotemin,lotemin);
   return lotes;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MyRobot::OnTradeTransaction(const MqlTradeTransaction &trans,
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
         deal_type         =(ENUM_DEAL_TYPE)HistoryDealGetInteger(trans.deal,DEAL_TYPE);
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
            string order_exec="Ordem executada ticket: "+(string)deal_order+", "+EnumToString(deal_type)+", "+"Volume: "+DoubleToString(deal_volume,2)+" "+deal_symbol;
            Print(order_exec);
            if(TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED))SendNotification(order_exec);

           }

        }
      else
         return;

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

   mytradePanel.SetExpertMagicNumber(MAGIC_NUMBER);
   mytradePanel.SetDeviationInPoints(50);
   mytradePanel.LogLevel(LOG_LEVEL_ERRORS);
   mytradePanel.SetTypeFillingBySymbol(Symbol());


   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
      return(INIT_FAILED);
//--- run application 

   ExtDialog.Run();

   return MyEA.OnInit();

  }
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
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.Destroy(reason);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   MyEA.OnTick();
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.OnTick();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void OnChartEvent(const int id,// event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  {
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyPanel::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {

   int xx1=INDENT_LEFT;
   int yy1=INDENT_TOP;
   int xx2=x1+BUTTON_WIDTH;
   int yy2=INDENT_TOP+BUTTON_HEIGHT;

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);

//--- create dependent controls 

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Resultado Aberto: "+DoubleToString(MyEA.LucroAberto(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[0].Color(clrDeepSkyBlue);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],SimboloB+" BID: "+DoubleToString(SymbolInfoDouble(SimboloB,SYMBOL_BID),_Digits)+" ASK: "+DoubleToString(SymbolInfoDouble(SimboloB,SYMBOL_ASK),_Digits),xx1,yy1,xx2,yy2))
      return(false);
   m_label[1].Color(clrDeepSkyBlue);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+2*CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=(int)(yy1+1.5*BUTTON_HEIGHT);

   if(!CreateButton(m_chart_id,m_subwin,BotaoBuyB,"Buy "+SimboloB,xx1,yy1,xx2,yy2))
      return(false);
   BotaoBuyB.ColorBackground(clrBlue);
   BotaoBuyB.Color(clrYellow);

   xx1=INDENT_LEFT+BUTTON_WIDTH+2*CONTROLS_GAP_X;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+2*CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=(int)(yy1+1.5*BUTTON_HEIGHT);

   if(!CreateButton(m_chart_id,m_subwin,BotaoSellB,"Sell "+SimboloB,xx1,yy1,xx2,yy2))
      return(false);
   BotaoSellB.ColorBackground(clrRed);
   BotaoSellB.Color(clrYellow);



   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+5*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],SimboloA+" BID: "+DoubleToString(SymbolInfoDouble(SimboloA,SYMBOL_BID),_Digits)+" ASK: "+DoubleToString(SymbolInfoDouble(SimboloA,SYMBOL_ASK),_Digits),xx1,yy1,xx2,yy2))
      return(false);
   m_label[2].Color(clrOrangeRed);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+6*BUTTON_HEIGHT+2*CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=(int)(yy1+1.5*BUTTON_HEIGHT);

   if(!CreateButton(m_chart_id,m_subwin,BotaoBuyA,"Buy "+SimboloA,xx1,yy1,xx2,yy2))
      return(false);
   BotaoBuyA.ColorBackground(clrBlue);
   BotaoBuyA.Color(clrYellow);

   xx1=INDENT_LEFT+BUTTON_WIDTH+2*CONTROLS_GAP_X;
   yy1=INDENT_TOP+6*BUTTON_HEIGHT+2*CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=(int)(yy1+1.5*BUTTON_HEIGHT);

   if(!CreateButton(m_chart_id,m_subwin,BotaoSellA,"Sell "+SimboloA,xx1,yy1,xx2,yy2))
      return(false);
   BotaoSellA.ColorBackground(clrRed);
   BotaoSellA.Color(clrYellow);



//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyPanel::OnTick(void)
  {
   m_label[0].Text("Resultado Aberto: "+DoubleToString(MyEA.LucroAberto(),2));
   m_label[1].Text(SimboloB+" BID: "+DoubleToString(SymbolInfoDouble(SimboloB,SYMBOL_BID),_Digits)+" ASK: "+DoubleToString(SymbolInfoDouble(SimboloB,SYMBOL_ASK),_Digits));
   m_label[2].Text(SimboloA+" BID: "+DoubleToString(SymbolInfoDouble(SimboloA,SYMBOL_BID),_Digits)+" ASK: "+DoubleToString(SymbolInfoDouble(SimboloA,SYMBOL_ASK),_Digits));

  }
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(MyPanel)
ON_EVENT(ON_CLICK,BotaoBuyA,OnClickBotaoBuyA)
ON_EVENT(ON_CLICK,BotaoSellA,OnClickBotaoSellA)
ON_EVENT(ON_CLICK,BotaoBuyB,OnClickBotaoBuyB)
ON_EVENT(ON_CLICK,BotaoSellB,OnClickBotaoSellB)

EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+

void OnClickBotaoBuyA()
  {
   mytradePanel.Buy(loteA,SimboloA,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnClickBotaoBuyB()
  {
   mytradePanel.Buy(loteB,SimboloB,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnClickBotaoSellA()
  {
   mytradePanel.Sell(loteA,SimboloA,0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnClickBotaoSellB()
  {
   mytradePanel.Sell(loteB,SimboloB,0);
  }
//+------------------------------------------------------------------+
