//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
enum TipoOrdem
  {
   OrdBuy,//Ordem Buy Limit
   OrdSell//Ordem Sell Limit
  };
sinput string senha="";//Cole a senha
input ulong          MAGIC_NUMBER=0;         // Número Mágico
input ushort num_ordens=5;//Número de Ordens
input double dist_ordens=2.0;//Distância Entre Ordens
input double TP_Ordens=20.0;//Take Profit Ordens
input double SL_Ordens=20.0;//Stop Loss  Ordens

sinput string sTest="###----------BACKTEST--------#####";//BACKTEST
input double price_test=3900.00;//Preço Para Teste
input TipoOrdem tipo_ordem=OrdBuy;//Tipo de Ordem
input double TP_Test=20.0;//TP Ordem Inicial Teste
input double SL_Test=20.0;//SL Ordem Inicial Teste


sinput string Lucro="###---------------------Usar Lucro/Prejuizo para Fechamento-----------------------#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia

sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="10:00";//Horario Inicial
input string end_hour="16:50";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario
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
//Classes
class CNewBar
  {
private:
   datetime          Time[],LastTime;

public:
   void              CNewBar();
   bool              CheckNewBar(string pSymbol,ENUM_TIMEFRAMES pTimeframe);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CNewBar::CNewBar(void)
  {
   ArraySetAsSeries(Time,true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CNewBar::CheckNewBar(string pSymbol,ENUM_TIMEFRAMES pTimeframe)
  {
   bool firstRun=false,newBar=false;
   CopyTime(pSymbol,pTimeframe,0,2,Time);

   if(LastTime==0) firstRun=true;

   if(Time[0]>LastTime)
     {
      if(firstRun==false) newBar=true;
      LastTime=Time[0];
      //  if(!MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_TESTER))
      //   PrintFormat("New bar: %s",TimeToString(TimeCurrent(),TIME_SECONDS));
     }

   return(newBar);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CGlobalVariables
  {
private:
   string            m_common_prefix; // prefix of common variables
   string            m_order_prefix; // prefix of order variables
   void DeleteAll()
     {
      GlobalVariablesDeleteAll(m_common_prefix);
      GlobalVariablesDeleteAll(m_order_prefix);
     }
public:
   // constructor
   void CGlobalVariables(string symbol="",int magic=0)
     {
      Init(symbol,magic);
     }
   // destructor
   void ~CGlobalVariables()
     {
      Deinit();
     }
   void Init(string symbol,ulong magic)
     {
      m_order_prefix="order_";
      m_common_prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_"+symbol+"_"+IntegerToString(magic)+"_";
      if(MQLInfoInteger(MQL_TESTER))
        {
         m_order_prefix="tester_"+m_order_prefix;
         m_common_prefix="t_"+m_common_prefix;
         DeleteAll();
        }
     }
   // for common variables
   bool Check(string name)
     {
      return(GlobalVariableCheck(m_common_prefix+name));
     }
   void Set(string name,double value)
     {
      GlobalVariableSet(m_common_prefix+name,value);
     }
   double Get(string name)
     {
      return(GlobalVariableGet(m_common_prefix+name));
     }
   void Delete(string name)
     {
      GlobalVariableDel(m_common_prefix+name);
     }
   // for order variables
   bool Check(ulong ticket,string name)
     {
      return(GlobalVariableCheck(m_order_prefix+IntegerToString(ticket)+"_"+name));
     }
   void Set(ulong ticket,string name,double value)
     {
      GlobalVariableSet(m_order_prefix+IntegerToString(ticket)+"_"+name,value);
     }
   double Get(ulong ticket,string name)
     {
      return(GlobalVariableGet(m_order_prefix+IntegerToString(ticket)+"_"+name));
     }
   void Delete(ulong ticket,string name)
     {
      GlobalVariableDel(m_order_prefix+IntegerToString(ticket)+"_"+name);
     }
   void Deinit()
     {
      if(MQLInfoInteger(MQL_TESTER))
        {
         DeleteAll();
        }
     }
   void DeleteByPrefix(string prefix)
     {
      GlobalVariablesDeleteAll(m_common_prefix+prefix);
     }
   string Prefix()
     {
      return(m_common_prefix);
     }
   void Flush()
     {
      GlobalVariablesFlush();
     }
  };

//Fim Classes

#include <Controls\Defines.mqh>
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
#undef CONTROLS_LABEL_COLOR  

color borda_bg=clrGray;//Cor Borda
color painel_bg=clrBlack;//Cor Painel
color cor_txt_borda_bg=clrBlack;//Cor Texto Borda
color cor_txt_pn_bg=clrDodgerBlue;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG          borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg

#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
#include <Controls\ComboBox.mqh> 
#include <SpinEditDouble.mqh>
#include <Controls\RadioGroup.mqh> 
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include<Trade\AccountInfo.mqh>
#include <ChartObjects\ChartObjectsShapes.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>

//---
CChartObjectRectangle RectTP;
CChartObjectText TextTP;

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        (100)     // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate
#define GROUP_WIDTH                         (150)     // size by X coordinate 
#define LIST_HEIGHT                         (179)     // size by Y coordinate 
#define RADIO_HEIGHT                        (56)      // size by Y coordinate 
#define CHECK_HEIGHT                        (93)      // size by Y coordinate //+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Class Boleta                                       |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class Boleta : public CAppDialog
  {
private:
   CEdit             m_edit;
   CButton           m_buttonSend;                          // the display field object
   CButton           m_buttonZerar;                       // the button object
   CButton           m_buttonSell;                       // the button object
   CButton           m_buttonBuy;                       // the button object
   CSpinEditDouble   m_spin_edit_Lot;                    // the spinedit object
   CSpinEditDouble   m_spin_edit2;                    // the spinedit object
   CSpinEditDouble   m_spin_editStop;                   // the spinedit object
   CSpinEditDouble   m_spin_editTake;                   // the spinedit object
   CEdit             m_spin_price_limit;                   // the spinedit object
   CLabel            m_label_Lot; //label
   CLabel            m_label_Stop; //label
   CLabel            m_label_Take; //label
   CLabel            m_label_Posicao; //label
   CLabel            m_label_VolPosicao; //label
   CLabel            m_label_Lucro;
   CComboBox         comboOrdens;

   //---
   CPositionInfo     myposition;                      // trade position object
   CTrade            mytrade;                         // trading object
   CSymbolInfo       mysymbol;                        // symbol info object
   COrderInfo        myorder;                         // pending orders object
   CHistoryOrderInfo myhistory;
   CAccountInfo      myaccount;
   CDealInfo         mydeal;

   //---
   double            price_limit;
   string            mensagens;
   ulong             m_slippage;                      // slippage
   ulong             Magic_Number;   //Expert Magic Number
   double            LOTS;       //Lots or volume to Trade
   string            symbol;     //variable to hold the current symbol name
   string            original_symbol;     //variable to hold the current symbol name
   double            ponto,ticksize;
   int               digits;
   string            exp_name;
   string            tp_comment;
   double            sl_position,tp_position;
   double            sec_stop,sec_take;
   double            Sellprice,Buyprice;
   double            price_gain,price_stop;
   double            lucro_orders,lucro_positions,lucro_total;
   double            preco_medio;
   ENUM_ORDER_TYPE_TIME order_time_type;
   ENUM_TIMEFRAMES   period;     //variable to hold the current timeframe value
   bool              tradeOn;
   MqlDateTime       TimeNow;
   datetime          hora_inicial;
   datetime          hora_final;
   bool              timerOn;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   double            bid,ask;
   string            cp_tick;
   string            vd_tick;
   string            tp_cp_tick;
   string            tp_vd_tick;
   string            stp_cp_tick;
   string            stp_vd_tick;

   double            high[];
   double            low[];
   double            open[];
   double            close[];
   bool              IsTest;
   //--- refresh rates
   bool              RefreshRates(void);
   //--- close positions  
   //---
   bool              bln_close_all;

   bool
   bln_open_buy;
   bool              bln_open_sell;
   bool              bln_open_limit;
   double            volume_ent;

   double            _Stop;
   double            _TakeProfit;

protected:
   //--- create dependent controls
   bool              CreateButtonSendLimit(void);
   bool              CreateButtonZerar(void);
   bool              CreateButtonSell(void);
   bool              CreateButtonBuy(void);
   bool              CreateSpinEditLot(void);
   bool              CreateSpinEditStop(void);
   bool              CreateSpinEditTake(void);
   bool              CreateSpinEditPriceLimit(void);
   bool              CreateLabelLot(void);
   bool              CreateLabelStop(void);
   bool              CreateLabelTake(void);
   bool              CreateLabelPosicao(void);
   bool              CreateLabelVolPosicao(void);
   bool              CreateLabelLucro(void);
   bool              CreateComboBox(const long chart,const string name,const int subwindow,CComboBox &object,const uint x1,const uint y1,const uint x2,const uint y2);

   //--- override the parent method
   virtual void      Minimize(void);
   //--- handlers of the dependent controls events
   void              OnClickButtonZerar(void);
   void              OnClickButtonSend(void) { bln_open_limit=true;                    OnTick();   }
   void              OnClickButtonSell(void) { bln_open_sell=true;                    OnTick();   }
   void              OnClickButtonBuy(void) { bln_open_buy=true;                    OnTick();   }
   void              OnChangeSpinEdiLot(void) { volume_ent=m_spin_edit_Lot.Value();    OnTick();   }
   void              OnChangeSpinEditStop(void)   { _Stop  = m_spin_editStop.Value();   OnTick();   }
   void              OnChangeSpinEditTake(void)   { _TakeProfit  = m_spin_editTake.Value();   OnTick();   }

public:

   CGlobalVariables  gv;

                     Boleta(void);
                    ~Boleta(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,
                            const int x2,const int y2,const ulong magic);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   //---

   void              CloseALL(void);
   void              DeleteALL(void);
   void              DeleteOrdersExEntry();

   bool              PosicaoAberta(void);
   bool              Buy_opened(void);
   bool              Sell_opened(void);
   double            VolumePositions(void);

   void              ClosePositions(const ENUM_POSITION_TYPE pos_type);
   //--- calculate positions                              
   int               CalculatePositions(const ENUM_POSITION_TYPE pos_type);
   //--- delete pending orders                                                
   void              DeleteOrders(const ENUM_ORDER_TYPE order_type);
   //--- calculate pending orders                                                
   int               CalculateOrders(const ENUM_ORDER_TYPE order_type);

   void              OnTick(void);

   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);
   int               OnInit();
   bool              TimeDayFilter();
   double            LucroOrdens();
   double            LucroPositions();
   void              CloseByPosition();
   ulong             TickecBuyPos();
   ulong             TickecSellPos();
   bool              GetIndValue();
   void              setMagic(ulong magic){Magic_Number=magic;}         //function to set Expert Magic number
   void              setSymbol(string syb){symbol=syb;}         //function to set current symbol
   void              setOriginalSymbol(string syb){original_symbol=syb;}         //function to set original symbol
   void              setNameGvOrder();
   void              OnDeinit(const int reason);
   void              OnTimer();
   double            VolOrdAbert();
   double            PrecoMedio(ENUM_POSITION_TYPE ptype);
   double            VolPosType(ENUM_POSITION_TYPE ptype);
   double            VolumeOrdens(const ENUM_ORDER_TYPE order_type);
   double            VolumeOrdensCmt(const string cmt);
   void              Entr_Parcial_Buy(const double preco);
   void              Entr_Parcial_Sell(const double preco);
   void              ClosePosType(ENUM_POSITION_TYPE ptype);
   void              DeleteOrdersComment(const string comm);
   void              DeleteOrdersWithComment(const string comm);
   void              CloseTPByPosition();

  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(Boleta)
ON_EVENT(ON_CLICK,m_buttonSend,OnClickButtonSend)
ON_EVENT(ON_CLICK,m_buttonZerar,OnClickButtonZerar)
ON_EVENT(ON_CLICK,m_buttonSell,OnClickButtonSell)
ON_EVENT(ON_CLICK,m_buttonBuy,OnClickButtonBuy)
ON_EVENT(ON_CHANGE,m_spin_edit_Lot,OnChangeSpinEdiLot)
ON_EVENT(ON_CHANGE,m_spin_editStop,OnChangeSpinEditStop)
ON_EVENT(ON_CHANGE,m_spin_editTake,OnChangeSpinEditTake)
EVENT_MAP_END(CAppDialog)

void Boleta::OnClickButtonZerar(void)
  {
   DeleteALL();
   CloseALL();
  }
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
Boleta::Boleta(void) : Magic_Number(0),
                       m_slippage(100),
                       bln_close_all(false),
                       bln_open_buy(false),
                       bln_open_limit(false),
                       bln_open_sell(false)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
Boleta::~Boleta(void)
  {
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
int Boleta::OnInit()
  {
   IsTest=MQLInfoInteger(MQL_TESTER);
   exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
   period=PERIOD_CURRENT;
   tradeOn=true;
   setSymbol(Symbol());
   setOriginalSymbol(Symbol());
   setMagic(MAGIC_NUMBER);
   if(SymbolInfoInteger(original_symbol,SYMBOL_EXPIRATION_MODE)==2)order_time_type=1;
   else order_time_type=0;
   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(MAGIC_NUMBER);
   mytrade.SetDeviationInPoints(50);
   lucro_orders=LucroOrdens();
   mytrade.SetTypeFilling(ORDER_FILLING_RETURN);
   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);
   int find_wdo=StringFind(original_symbol,"WDO");
   int find_dol=StringFind(original_symbol,"DOL");
   if(find_dol>=0|| find_wdo>=0) ponto=1.0;
   gv.Init(symbol,Magic_Number);
   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today_prev",(double)TimeNow.day_of_year);
   setNameGvOrder();

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   ulong curChartID=ChartID();

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(ChartID(),CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Boleta::Create(const long chart,const string name,const int subwin,const int x1,const int y1,
                    const int x2,const int y2,const ulong magic)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//---
   symbol=Symbol();
   if(!mysymbol.Name(_Symbol)) // sets symbol name
      return(false);
   RefreshRates();
   Magic_Number=magic;
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.SetMarginMode();
   mytrade.SetTypeFillingBySymbol(mysymbol.Name());
   mytrade.SetDeviationInPoints(m_slippage);

   ponto=SymbolInfoDouble(_Symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS);

   int find_wdo=StringFind(_Symbol,"WDO");
   int find_dol=StringFind(_Symbol,"DOL");
   if(find_dol>=0|| find_wdo>=0) ponto=1.0;


//--- create dependent controls
   if(!CreateButtonSendLimit())
      return(false);
   if(!CreateButtonZerar())
      return(false);
   if(!CreateButtonSell())
      return(false);
   if(!CreateButtonBuy())
      return(false);
   if(!CreateSpinEditLot())
      return(false);
   if(!CreateSpinEditStop())
      return(false);
   if(!CreateSpinEditTake())
      return(false);
   if(!CreateLabelLot())
      return(false);
   if(!CreateLabelStop())
      return(false);
   if(!CreateLabelTake())
      return(false);
   if(!CreateLabelPosicao())
      return(false);
   if(!CreateLabelVolPosicao())
      return(false);
   if(!CreateLabelLucro())
      return(false);

   if(!CreateSpinEditPriceLimit())
      return(false);

   int xx1=INDENT_LEFT;
   int yy1=2*INDENT_TOP+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int xx2=xx1+BUTTON_WIDTH;
   int yy2=yy1+BUTTON_HEIGHT;

   if(!CreateComboBox(chart,"comboOrdens",subwin,comboOrdens,xx1,yy1,xx2,yy2))
      return(false);
   if(!Add(comboOrdens))
      return(false);

   if(!comboOrdens.ItemAdd("Buy Limit"))
      return(false);

   if(!comboOrdens.ItemAdd("Sell Limit"))
      return(false);

   comboOrdens.SelectByValue(0);

//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool Boleta::RefreshRates(void)
  {
   if(!mysymbol.Refresh())
     {
      Print("Refresh error");
      return(false);
     }
//--- refresh rates
   if(!mysymbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(mysymbol.Ask()==0 || mysymbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Boleta::OnTradeTransaction(const MqlTradeTransaction &trans,
                                const MqlTradeRequest &request,
                                const MqlTradeResult &result)
  {
   if(trans.symbol!=_Symbol)
      return;

   int TENTATIVAS=10;

//--- get transaction type as enumeration value
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history

//--- if a request was sent
   if(trans.type==TRADE_TRANSACTION_REQUEST)
     {
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(type==TRADE_TRANSACTION_ORDER_UPDATE)
     {
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(type==TRADE_TRANSACTION_HISTORY_UPDATE)
     {
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long deal_ticket= 0;
      long deal_order = 0;
      long deal_time=0;
      long deal_time_msc=0;
      ENUM_DEAL_TYPE deal_type=-1;
      long deal_entry=-1;
      ulong deal_magic = 0;
      long deal_reason = -1;
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
         deal_entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
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

         if(deal_symbol!=_Symbol)
            return;
         if(deal_magic==Magic_Number)
           {
            if(deal_comment=="BUY"+exp_name && (deal_entry==DEAL_ENTRY_IN || deal_entry==DEAL_ENTRY_INOUT))

              {
               myposition.SelectByTicket(trans.order);
               int cont = 0;
               Buyprice = 0;
               while(Buyprice==0 && cont<TENTATIVAS)
                 {
                  Buyprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(Buyprice== 0)
                  Buyprice= SymbolInfoDouble(original_symbol,SYMBOL_ASK);
               if(_Stop>0)
                 {
                  sl_position=NormalizeDouble(Buyprice-_Stop,digits);
                  if(sl_position<SymbolInfoDouble(original_symbol,SYMBOL_BID))
                    {
                     if(!mytrade.SellStop(volume_ent,sl_position,original_symbol,0,0,order_time_type,0,"STOP_"+IntegerToString(trans.order)))
                       {
                        Print("Erro enviar ordem Stop: ",GetLastError());
                        if(!mytrade.Sell(volume_ent,mysymbol.Name(),0,0,0,"STOP_"+IntegerToString(trans.order)))
                           Print("Erro enviar Fechar Ordem: ",GetLastError());

                       }
                    }
                  else
                    {
                     if(!mytrade.Sell(volume_ent,mysymbol.Name(),0,0,0,"STOP_"+IntegerToString(trans.order)))
                        Print("Erro enviar Fechar Ordem: ",GetLastError());
                    }
                 }
               if(_TakeProfit>0)
                 {
                  tp_position=NormalizeDouble(Buyprice+_TakeProfit,digits);
                  if(mytrade.SellLimit(volume_ent,tp_position,original_symbol,0,0,order_time_type,0,"GAIN_"+IntegerToString(trans.order)))
                    {
                     gv.Set("tp_vd_tick",(double)mytrade.ResultOrder());
                    }
                  else
                     Print("Erro enviar ordem Gain: ",GetLastError());
                 }
               Entr_Parcial_Buy(Buyprice);

              }
            //--------------------------------------------------

            if(deal_comment=="SELL"+exp_name && (deal_entry==DEAL_ENTRY_IN || deal_entry==DEAL_ENTRY_INOUT))
              {
               myposition.SelectByTicket(trans.order);
               Sellprice= myposition.PriceOpen();
               int cont = 0;
               Sellprice= 0;
               while(Sellprice==0 && cont<TENTATIVAS)
                 {
                  Sellprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(Sellprice==0)
                  Sellprice=SymbolInfoDouble(original_symbol,SYMBOL_BID);
               sl_position=NormalizeDouble(Sellprice+_Stop,digits);
               if(sl_position>SymbolInfoDouble(original_symbol,SYMBOL_ASK))
                 {
                  if(!mytrade.BuyStop(volume_ent,sl_position,original_symbol,0,0,order_time_type,0,"STOP_"+IntegerToString(trans.order)))
                    {
                     Print("Erro enviar ordem Stop: ",GetLastError());
                     if(!mytrade.Buy(volume_ent,mysymbol.Name(),0,0,0,"STOP_"+IntegerToString(trans.order)))
                        Print("Erro enviar Fechar Ordem: ",GetLastError());
                    }
                 }
               else
                 {
                  if(!mytrade.Buy(volume_ent,mysymbol.Name(),0,0,0,"STOP_"+IntegerToString(trans.order)))
                     Print("Erro enviar Fechar Ordem: ",GetLastError());
                 }

               tp_position=NormalizeDouble(Sellprice-_TakeProfit,digits);
               if(mytrade.BuyLimit(volume_ent,tp_position,original_symbol,0,0,order_time_type,0,"GAIN_"+IntegerToString(trans.order)))
                 {
                  gv.Set("tp_cp_tick",(double)mytrade.ResultOrder());
                 }
               else
                  Print("Erro enviar ordem Gain: ",GetLastError());

               Entr_Parcial_Sell(Sellprice);

              }

            if((deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL) && (deal_entry==DEAL_ENTRY_OUT || deal_entry==DEAL_ENTRY_OUT_BY))
              {

               if(deal_profit<0)
                 {
                  Print("Saída por STOP LOSS");
                 }

               if(deal_profit>0)
                 {
                  Print("Saída no GAIN");
                 }
              }

            lucro_orders=LucroOrdens();

/*            lucro_orders=LucroOrdens();
            lucro_orders_mes = LucroOrdensMes();
            lucro_orders_sem = LucroOrdensSemana();*/

           } //Fim deal magic
        }
      else
         return;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(type==TRADE_TRANSACTION_HISTORY_ADD)
     {

      if(HistoryOrderSelect(trans.order))
        {
         myhistory.Ticket(trans.order);
         if(myhistory.Magic()!=(ulong)Magic_Number)
            return;
         if(myhistory.Symbol()!=mysymbol.Name())return;
         if((myhistory.Comment()=="BUY"+exp_name || myhistory.Comment()=="SELL"+exp_name) && trans.order_state==ORDER_STATE_FILLED)
           {
            //   gv.Set("glob_entr_tot",gv.Get("glob_entr_tot")+1);
           }

         if((StringFind(myhistory.Comment(),"GAIN")==0 || StringFind(myhistory.Comment(),"STOP")==0) && trans.order_state==ORDER_STATE_FILLED)
           {
            if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)CloseTPByPosition();
            tradeOn=false;
           }
         if(StringFind(myhistory.Comment(),"Entrada Parcial")>=0 && trans.order_state==ORDER_STATE_FILLED)
           {
            if(Buy_opened())
              {
               if(TP_Ordens>0)
                 {
                  price_gain=myhistory.PriceOpen();
                  int cont=0;
                  while(price_gain==0 && cont<TENTATIVAS)
                    {
                     price_gain=myhistory.PriceOpen();
                     cont+=1;
                    }
                  if(price_gain==0)
                     price_gain=SymbolInfoDouble(original_symbol,SYMBOL_ASK);

                  price_gain=MathRound(price_gain/ticksize)*ticksize;
                  price_gain=NormalizeDouble(price_gain+TP_Ordens*ponto,digits);
                  if(mytrade.SellLimit(myhistory.VolumeInitial(),price_gain,original_symbol,0,0,order_time_type,0,"TP_"+IntegerToString(trans.order)))
                    {
                     Print("Gain Parcial Enviado");
                    }
                  else Print("Erro enviar Gain Parcial: ",GetLastError());
                 }

               price_stop=myhistory.PriceOpen();
               int cont=0;
               while(price_stop==0 && cont<TENTATIVAS)
                 {
                  price_stop=myhistory.PriceOpen();
                  cont+=1;
                 }
               if(price_stop==0)
                  price_stop=SymbolInfoDouble(original_symbol,SYMBOL_ASK);

               price_stop=MathRound(price_stop/ticksize)*ticksize;
               sl_position=NormalizeDouble(price_stop-SL_Ordens*ponto,digits);
               if(sl_position<SymbolInfoDouble(original_symbol,SYMBOL_BID))
                 {
                  if(!mytrade.SellStop(volume_ent,sl_position,original_symbol,0,0,order_time_type,0,"SL_"+IntegerToString(trans.order)))
                    {
                     Print("Erro enviar ordem Stop: ",GetLastError());
                     if(!mytrade.Sell(volume_ent,mysymbol.Name(),0,0,0,"SL_"+IntegerToString(trans.order)))
                        Print("Erro enviar Fechar Ordem: ",GetLastError());

                    }
                 }
               else
                 {
                  if(!mytrade.Sell(volume_ent,mysymbol.Name(),0,0,0,"SL_"+IntegerToString(trans.order)))
                     Print("Erro enviar Fechar Ordem: ",GetLastError());
                 }

              }

            if(Sell_opened())
              {
               if(TP_Ordens>0)
                 {

                  price_gain=myhistory.PriceOpen();
                  int cont=0;
                  while(price_gain==0 && cont<TENTATIVAS)
                    {
                     price_gain=myhistory.PriceOpen();
                     cont+=1;
                    }
                  if(price_gain==0)
                     price_gain=SymbolInfoDouble(original_symbol,SYMBOL_BID);

                  price_gain=MathRound(price_gain/ticksize)*ticksize;
                  price_gain=NormalizeDouble(price_gain-TP_Ordens*ponto,digits);

                  if(mytrade.BuyLimit(myhistory.VolumeInitial(),price_gain,original_symbol,0,0,order_time_type,0,"TP_"+IntegerToString(trans.order)))
                    {
                     Print("Gain Parcial Enviado");
                    }
                  else Print("Erro enviar Gain Parcial: ",GetLastError());
                 }

               price_stop=myhistory.PriceOpen();
               int cont=0;
               while(price_stop==0 && cont<TENTATIVAS)
                 {
                  price_stop=myhistory.PriceOpen();
                  cont+=1;
                 }
               if(price_stop==0)
                  price_stop=SymbolInfoDouble(original_symbol,SYMBOL_BID);
               price_stop=MathRound(price_stop/ticksize)*ticksize;
               sl_position=NormalizeDouble(price_stop+SL_Ordens*ponto,digits);
               if(sl_position>SymbolInfoDouble(original_symbol,SYMBOL_ASK))
                 {
                  if(!mytrade.BuyStop(volume_ent,sl_position,original_symbol,0,0,order_time_type,0,"SL_"+IntegerToString(trans.order)))
                    {
                     Print("Erro enviar ordem Stop: ",GetLastError());
                     if(!mytrade.Buy(volume_ent,mysymbol.Name(),0,0,0,"SL_"+IntegerToString(trans.order)))
                        Print("Erro enviar Fechar Ordem: ",GetLastError());

                    }
                 }
               else
                 {
                  if(!mytrade.Buy(volume_ent,mysymbol.Name(),0,0,0,"SL_"+IntegerToString(trans.order)))
                     Print("Erro enviar Fechar Ordem: ",GetLastError());
                 }

              }

           }

         if((StringFind(myhistory.Comment(),"TP_")==0 || StringFind(myhistory.Comment(),"SL")==0) && trans.order_state==ORDER_STATE_FILLED)
           {
            if(StringFind(myhistory.Comment(),"TP_")==0)DeleteOrdersComment("SL_"+StringSubstr(myhistory.Comment(),3));
            if(StringFind(myhistory.Comment(),"SL_")==0)DeleteOrdersComment("TP_"+StringSubstr(myhistory.Comment(),3));

            DeleteOrdersWithComment("Entrada Parcial");
            if(Buy_opened())
              {
               preco_medio=PrecoMedio(POSITION_TYPE_BUY);
               Entr_Parcial_Buy(preco_medio);
              }

            if(Sell_opened())
              {
               preco_medio=PrecoMedio(POSITION_TYPE_SELL);
               Entr_Parcial_Sell(preco_medio);
              }

           }

        }//Fim History Select
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Boleta::DeleteALL(void)
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
         if(myorder.Magic()==Magic_Number && myorder.Symbol()==mysymbol.Name()) mytrade.OrderDelete(o_ticket);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Boleta::CloseALL(void)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void Boleta::ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(myposition.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number)
            if(myposition.PositionType()==pos_type) // gets the position type
               mytrade.PositionClose(myposition.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Calculate positions                                              |
//+------------------------------------------------------------------+
int Boleta::CalculatePositions(const ENUM_POSITION_TYPE pos_type)
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(myposition.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number)
            if(myposition.PositionType()==pos_type)
               total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Boleta::VolumePositions(void)
  {
   double total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(myposition.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number)
            total+=myposition.Volume();
//---
   return(total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void Boleta::DeleteOrders(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Calculate Orders                                                    |
//+------------------------------------------------------------------+
int Boleta::CalculateOrders(const ENUM_ORDER_TYPE order_type)
  {
   int total=0;

   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Create the "Button1" button                                      |
//+------------------------------------------------------------------+
bool Boleta::CreateButtonZerar(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_buttonZerar.Create(m_chart_id,m_name+"Button1",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_buttonZerar.Text("ZERAR"))
      return(false);
   m_buttonZerar.ColorBackground(clrLime);

   if(!Add(m_buttonZerar))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Boleta::CreateButtonSendLimit()
  {
//--- coordinates
   int x1=(int)(INDENT_LEFT+0.5*(BUTTON_WIDTH+CONTROLS_GAP_X));
   int y1=2*INDENT_TOP+6*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;


//--- create
   if(!m_buttonSend.Create(m_chart_id,m_name+"ButtonSend",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_buttonSend.Text("ENVIAR"))
      return(false);
   m_buttonSend.ColorBackground(clrAqua);

   if(!Add(m_buttonSend))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool Boleta::CreateLabelLot(void)
  {
// All objects mast to have separate name
   string name="LabelLot"+(string)ObjectsTotal(m_chart_id,-1,OBJ_LABEL);
//--- Call Create function
   int x1=INDENT_LEFT;
   int y1=2*INDENT_TOP+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!m_label_Lot.Create(m_chart_id,name,m_subwin,x1,y1,x2,y2))
     {
      return false;
     }
//--- Addjust text
   if(!m_label_Lot.Text("Lote Entrada: "))
     {
      return false;
     }
   m_label_Lot.Color(clrYellow);
//--- Add object to controls
   if(!Add(m_label_Lot))
     {
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Boleta::CreateLabelStop(void)
  {
// All objects mast to have separate name
   string name="LabelStop"+(string)ObjectsTotal(m_chart_id,-1,OBJ_LABEL);
//--- Call Create function
   int x1=INDENT_LEFT;
   int y1=2*INDENT_TOP+(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!m_label_Stop.Create(m_chart_id,name,m_subwin,x1,y1,x2,y2))
     {
      return false;
     }
//--- Addjust text
   if(!m_label_Stop.Text("SL (Pontos)"))
     {
      return false;
     }
   m_label_Stop.Color(clrYellow);
//--- Add object to controls
   if(!Add(m_label_Stop))
     {
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Boleta::CreateLabelTake(void)
  {
// All objects mast to have separate name
   string name="LabelTake"+(string)ObjectsTotal(m_chart_id,-1,OBJ_LABEL);
//--- Call Create function
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=2*INDENT_TOP+(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!m_label_Take.Create(m_chart_id,name,m_subwin,x1,y1,x2,y2))
     {
      return false;
     }
//--- Addjust text
   if(!m_label_Take.Text("TP (Pontos)"))
     {
      return false;
     }
   m_label_Take.Color(clrYellow);
//--- Add object to controls
   if(!Add(m_label_Take))
     {
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Boleta::CreateSpinEditStop(void)
  {
   double min_value;
   int find_wdo=StringFind(_Symbol,"WDO");
   int find_dol=StringFind(_Symbol,"DOL");
   if(find_dol>=0|| find_wdo>=0) min_value=1.0;
   else min_value=10.0;

//--- coordinates
   int x1=INDENT_LEFT;
   int y1=2*INDENT_TOP+2*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_spin_editStop.Create(m_chart_id,m_name+"SpinEditStop",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_spin_editStop))
      return(false);
   m_spin_editStop.DisplayedDigits(mysymbol.Digits());
   m_spin_editStop.MinValue(mysymbol.TickSize()*min_value);
   m_spin_editStop.MaxValue(mysymbol.TickSize()*2000.0);
   m_spin_editStop.Value(0.0);
   _Stop=m_spin_editStop.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Boleta::CreateSpinEditTake(void)
  {
   double min_value;
   int find_wdo=StringFind(_Symbol,"WDO");
   int find_dol=StringFind(_Symbol,"DOL");
   if(find_dol>=0|| find_wdo>=0) min_value=1.0;
   else min_value=10.0;

//--- coordinates
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=2*INDENT_TOP+2*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_spin_editTake.Create(m_chart_id,m_name+"SpinEditTake",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_spin_editTake))
      return(false);
   m_spin_editTake.DisplayedDigits(mysymbol.Digits());
   m_spin_editTake.MinValue(mysymbol.TickSize()*min_value);
   m_spin_editTake.MaxValue(mysymbol.TickSize()*2000.0);
   m_spin_editTake.Value(0.0);
   _TakeProfit=m_spin_editTake.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Boleta::CreateSpinEditPriceLimit(void)
  {

//--- coordinates
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=2*INDENT_TOP+5*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_spin_price_limit.Create(m_chart_id,m_name+"SpinEditPriceLimit",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_spin_price_limit))
      return(false);
   m_spin_price_limit.Text(DoubleToString(iClose(_Symbol,_Period,1),_Digits));
//_TakeProfit=m_spin_editTake.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Create the "Button7" button                                      |
//+------------------------------------------------------------------+
bool Boleta::CreateButtonSell(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=2*INDENT_TOP+3*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_buttonSell.Create(m_chart_id,m_name+"Button7",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_buttonSell.Text("Sell "+DoubleToString(mysymbol.Bid(),mysymbol.Digits())))
      return(false);
   m_buttonSell.ColorBackground(clrMediumVioletRed);
   m_buttonSell.Color(clrYellow);

   if(!Add(m_buttonSell))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Create the "Button8" button                                      |
//+------------------------------------------------------------------+
bool Boleta::CreateButtonBuy(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=2*INDENT_TOP+3*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;


//--- create
   if(!m_buttonBuy.Create(m_chart_id,m_name+"Button8",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_buttonBuy.Text("Buy "+DoubleToString(mysymbol.Ask(),mysymbol.Digits())))
      return(false);
   m_buttonBuy.ColorBackground(clrAqua);
   if(!Add(m_buttonBuy))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Create the "SpinEditLot" element                                   |
//+------------------------------------------------------------------+
bool Boleta::CreateSpinEditLot(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=2*INDENT_TOP+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=(int)(x1+0.75*BUTTON_WIDTH);
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_spin_edit_Lot.Create(m_chart_id,m_name+"SpinEditLot",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_spin_edit_Lot))
      return(false);
   m_spin_edit_Lot.DisplayedDigits(2);
   m_spin_edit_Lot.MinValue(mysymbol.LotsMin());
   m_spin_edit_Lot.MaxValue(mysymbol.LotsMax());
   m_spin_edit_Lot.Value(mysymbol.LotsMin());
   volume_ent=m_spin_edit_Lot.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Boleta::CreateLabelPosicao(void)
  {
// All objects mast to have separate name
   string name="LabelPosicao"+(string)ObjectsTotal(m_chart_id,-1,OBJ_LABEL);
//--- Call Create function
   int x1=INDENT_LEFT;
   int y1=2*INDENT_TOP+7*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!m_label_Posicao.Create(m_chart_id,name,m_subwin,x1,y1,x2,y2))
     {
      return false;
     }
//--- Addjust text
   if(!m_label_Posicao.Text("Posição: "))
     {
      return false;
     }
   m_label_Posicao.Color(clrAqua);
//--- Add object to controls
   if(!Add(m_label_Posicao))
     {
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Boleta::CreateLabelVolPosicao(void)
  {
// All objects mast to have separate name
   string name="LabelVolPosicao"+(string)ObjectsTotal(m_chart_id,-1,OBJ_LABEL);
//--- Call Create function
   int x1=INDENT_LEFT;
   int y1=2*INDENT_TOP+8*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!m_label_VolPosicao.Create(m_chart_id,name,m_subwin,x1,y1,x2,y2))
     {
      return false;
     }
//--- Addjust text
   if(!m_label_VolPosicao.Text("Vol: - "))
     {
      return false;
     }
   m_label_VolPosicao.Color(clrAqua);
//--- Add object to controls
   if(!Add(m_label_VolPosicao))
     {
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Boleta::CreateLabelLucro(void)
  {
// All objects mast to have separate name
   string name="LabelLucro"+(string)ObjectsTotal(m_chart_id,-1,OBJ_LABEL);
//--- Call Create function
   int x1=INDENT_LEFT;
   int y1=2*INDENT_TOP+9*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!m_label_Lucro.Create(m_chart_id,name,m_subwin,x1,y1,x2,y2))
     {
      return false;
     }
//--- Addjust text
   if(!m_label_Lucro.Text("Resultado Diário: "))
     {
      return false;
     }
   m_label_Lucro.Color(clrAqua);
//--- Add object to controls
   if(!Add(m_label_Lucro))
     {
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Minimize                                                         |
//|   --> https://www.mql5.com/ru/articles/4503#para10               |
//+------------------------------------------------------------------+
void Boleta::Minimize(void)
  {
//--- переменная для получения панели быстрой торговли
   long one_click_visible=-1;  // 0 - панели быстрой торговли нет 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!ChartGetInteger(m_chart_id,CHART_SHOW_ONE_CLICK,0,one_click_visible))
     {
      //--- выведем сообщение об ошибке в журнал "Эксперты"
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- минимальный отступ для свернутой панели приложения
   int min_y_indent=28;
   if(one_click_visible)
      min_y_indent=100;  // отступ, если быстрая торговля показана на графике
//--- получим текущий отступ для свернутой панели приложения
   int current_y_top=m_min_rect.top;
   int current_y_bottom=m_min_rect.bottom;
   int height=current_y_bottom-current_y_top;
//--- вычислим новый минимальный отступ от верха для свернутой панели приложения
   if(m_min_rect.top!=min_y_indent)
     {
      m_min_rect.top=min_y_indent;
      //--- сместим также нижнюю границу свернутой иконки
      m_min_rect.bottom=m_min_rect.top+height;
     }
//--- теперь можно вызвать метод базового класса
   CAppDialog::Minimize();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void Boleta::OnTick(void)
  {
   static bool first_tick=true;
   static double last_bid=0;
   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today",(double)TimeNow.day_of_year);

   bool novodia;
   novodia=Bar_NovoDia.CheckNewBar(_Symbol,PERIOD_D1);

   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      gv.Set("glob_entr_tot", 0.0);
      gv.Set("deals_total_prev", 0.0);
      gv.Set("last_stop", 0.0);
      tradeOn=true;
      hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
      hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
      lucro_orders=LucroOrdens();
      first_tick=true;
     }

   if(PosicaoAberta())
      lucro_positions=LucroPositions();
   else
      lucro_positions=0;
   lucro_total=lucro_orders+lucro_positions;
   m_label_Lucro.Text("Resultado Diário: "+DoubleToString(lucro_total,2));
   if(!PosicaoAberta())
     {
      m_label_Posicao.Text("Posição: ZERADO");
      m_label_VolPosicao.Text("Vol: - ");
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      if(Buy_opened())
         m_label_Posicao.Text("Posição: COMPRADO");
      if(Sell_opened())
         m_label_Posicao.Text("Posição: VENDIDO");
      m_label_VolPosicao.Text("Vol: "+DoubleToString(VolumePositions(),2));
     }
   RefreshRates();
   Maximize();
   m_buttonSell.Text("Sell "+DoubleToString(mysymbol.Bid(),mysymbol.Digits()));
   m_buttonBuy.Text("Buy "+DoubleToString(mysymbol.Ask(),mysymbol.Digits()));
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(mysymbol.Bid()<last_bid && last_bid>0)
     {
      color cor_baixa=clrOrange;
      m_buttonZerar.ColorBackground(cor_baixa);
      m_buttonSell.ColorBackground(cor_baixa);
      m_buttonBuy.ColorBackground(cor_baixa);

      color cor_texto1 = clrBlack;
      color cor_texto2 = clrWhite;
      m_buttonZerar.Color(cor_texto1);
      m_buttonSell.Color(cor_texto1);
      m_buttonBuy.Color(cor_texto1);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else if(mysymbol.Bid()>last_bid && last_bid>0)
     {
      color cor_alta=clrDeepSkyBlue;
      m_buttonZerar.ColorBackground(cor_alta);
      m_buttonSell.ColorBackground(cor_alta);
      m_buttonBuy.ColorBackground(cor_alta);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      m_buttonZerar.ColorBackground(clrLime);
      m_buttonSell.ColorBackground(clrBlueViolet);
      m_buttonBuy.ColorBackground(clrMediumVioletRed);
     }

   last_bid=mysymbol.Bid();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


   timerOn=true;

   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
     }

   if(!timerOn)
     {
      if(daytrade)
        {
         if(OrdersTotal()>0)
            DeleteALL();
         if(PositionsTotal()>0)
            CloseALL();
        }
      return;
     }

   if(!tradeOn)
     {
      if(OrdersTotal()>0)
         DeleteALL();
      if(PositionsTotal()>0)
         CloseALL();
      return;
     }
   gv.Set("gv_today_prev",gv.Get("gv_today"));

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   bid = mysymbol.Bid();
   ask = mysymbol.Ask();
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }
   if(bid>=ask)return;//Leilão
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))return;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      if(OrdersTotal()>0)
         DeleteALL();
      CloseALL();
      tradeOn=false;
      Print("EA encerrado lucro ou prejuizo");
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
      CloseTPByPosition();

   if(tradeOn && timerOn)

     { // inicio Trade On

      if(IsTest && first_tick)
        {

         if(tipo_ordem==OrdBuy)//Buy
           {
            if(Sell_opened())
              {
               DeleteALL();
               ClosePosType(POSITION_TYPE_SELL);
              }

            price_limit=price_test;
            price_limit=mysymbol.NormalizePrice(MathRound(price_limit/ticksize)*ticksize);
            int find_wdo=StringFind(original_symbol,"WDO");
            int find_dol=StringFind(original_symbol,"DOL");
            if(find_dol>=0|| find_wdo>=0)
              {
               sec_stop=0.0;
               sec_take=0.0;
               if(SL_Test>0)sec_stop=mysymbol.NormalizePrice(price_limit-SL_Test*ponto-4*ticksize);
               if(TP_Test>0)sec_take=mysymbol.NormalizePrice(price_limit+TP_Test*ponto+4*ticksize);
              }
            else
              {
               sec_stop=0.0;
               sec_take=0.0;
               if(SL_Test>0)sec_stop=mysymbol.NormalizePrice(price_limit-SL_Test*ponto-20*ticksize);
               if(TP_Test>0)sec_take=mysymbol.NormalizePrice(price_limit+TP_Test*ponto+20*ticksize);
              }
            if(mytrade.BuyLimit(volume_ent,price_limit,mysymbol.Name(),sec_stop,sec_take,order_time_type,0,"BUY"+exp_name))
              {
               if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                 {
                  gv.Set(cp_tick,(double)mytrade.ResultOrder());
                  mensagens=__FUNCSIG__+" Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
                  Print(mensagens);
                 }
               else
                 {
                  mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  Print(mensagens);
                 }
              }
            else
              {
               mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
               Print(mensagens);
              }

           }
         if(tipo_ordem==OrdSell)//Sell
           {
            if(Buy_opened())
              {
               DeleteALL();
               ClosePosType(POSITION_TYPE_BUY);
              }
            price_limit=price_test;
            price_limit=mysymbol.NormalizePrice(MathRound(price_limit/ticksize)*ticksize);
            int find_wdo=StringFind(original_symbol,"WDO");
            int find_dol=StringFind(original_symbol,"DOL");
            if(find_dol>=0|| find_wdo>=0)
              {
               sec_stop=0.0;
               sec_take=0.0;
               if(SL_Test>0)sec_stop=mysymbol.NormalizePrice(price_limit+SL_Test*ponto+4*ticksize);
               if(TP_Test>0)sec_take=mysymbol.NormalizePrice(price_limit-TP_Test*ponto-4*ticksize);
              }
            else
              {
               sec_stop=0.0;
               sec_take=0.0;
               if(SL_Test>0)sec_stop=mysymbol.NormalizePrice(price_limit+SL_Test*ponto+20*ticksize);
               if(TP_Test>0)sec_take=mysymbol.NormalizePrice(price_limit-TP_Test*ponto-20*ticksize);
              }
            if(mytrade.SellLimit(volume_ent,price_limit,mysymbol.Name(),sec_stop,sec_take,order_time_type,0,"SELL"+exp_name))
              {
               if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                 {
                  gv.Set(vd_tick,(double)mytrade.ResultOrder());
                  mensagens=__FUNCSIG__+" Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
                  Print(mensagens);
                 }
               else
                 {
                  mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  Print(mensagens);
                 }
              }
            else
              {
               mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
               Print(mensagens);
              }

           }

         first_tick=false;
        }

      if(!PosicaoAberta())
        {
         if(OrdersTotal()>0)
            DeleteOrdersExEntry();
        }

      if(Bar_NovaBarra.CheckNewBar(Symbol(),PERIOD_M1))
        {
         m_spin_price_limit.Text(DoubleToString(iClose(_Symbol,_Period,1),_Digits));

        } //Fim Nova Barra

      if(bln_open_buy)
        {
         if(Sell_opened())
           {
            DeleteALL();
            ClosePosType(POSITION_TYPE_SELL);
           }

         int find_wdo=StringFind(original_symbol,"WDO");
         int find_dol=StringFind(original_symbol,"DOL");
         if(find_dol>=0|| find_wdo>=0)
           {
            sec_stop=0.0;
            sec_take=0.0;
            if(_Stop>0)sec_stop=mysymbol.NormalizePrice(bid-_Stop-4*ticksize);
            if(_TakeProfit>0)sec_take=mysymbol.NormalizePrice(ask+_TakeProfit+4*ticksize);
           }
         else
           {
            sec_stop=0.0;
            sec_take=0.0;
            if(_Stop>0)sec_stop=mysymbol.NormalizePrice(bid-_Stop-20*ticksize);
            if(_TakeProfit>0)sec_take=mysymbol.NormalizePrice(ask+_TakeProfit+20*ticksize);
           }
         if(mytrade.Buy(volume_ent,mysymbol.Name(),0,sec_stop,sec_take,"BUY"+exp_name))
           {
            if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
              {
               gv.Set(cp_tick,(double)mytrade.ResultOrder());
               mensagens=__FUNCSIG__+" Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
               Print(mensagens);
              }
            else
              {
               mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
               Print(mensagens);
              }
           }
         else
           {
            mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
            Print(mensagens);
           }

         bln_open_buy=false;

        }
      //---
      if(bln_open_sell)
        {
         if(Buy_opened())
           {
            DeleteALL();
            ClosePosType(POSITION_TYPE_BUY);
           }

         int find_wdo=StringFind(original_symbol,"WDO");
         int find_dol=StringFind(original_symbol,"DOL");
         if(find_dol>=0|| find_wdo>=0)
           {
            sec_stop=0.0;
            sec_take=0.0;
            if(_Stop>0)sec_stop=mysymbol.NormalizePrice(ask+_Stop+4*ticksize);
            if(_TakeProfit>0)sec_take=mysymbol.NormalizePrice(bid-_TakeProfit-4*ticksize);
           }
         else
           {
            sec_stop=0.0;
            sec_take=0.0;
            if(_Stop>0)sec_stop=mysymbol.NormalizePrice(ask+_Stop+20*ticksize);
            if(_TakeProfit>0)sec_take=mysymbol.NormalizePrice(bid-_TakeProfit-20*ticksize);
           }
         if(mytrade.Sell(volume_ent,mysymbol.Name(),0,sec_stop,sec_take,"SELL"+exp_name))
           {
            if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
              {
               gv.Set(vd_tick,(double)mytrade.ResultOrder());
               mensagens=__FUNCSIG__+" Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
               Print(mensagens);
              }
            else
              {
               mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
               Print(mensagens);
              }
           }
         else
           {
            mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
            Print(mensagens);
           }

         bln_open_sell=false;
        }

      if(bln_open_limit)
        {

         if(comboOrdens.Value()==0)//Buy
           {
            if(Sell_opened())
              {
               DeleteALL();
               ClosePosType(POSITION_TYPE_SELL);
              }

            price_limit=StringToDouble(m_spin_price_limit.Text());
            price_limit=mysymbol.NormalizePrice(MathRound(price_limit/ticksize)*ticksize);
            int find_wdo=StringFind(original_symbol,"WDO");
            int find_dol=StringFind(original_symbol,"DOL");
            if(find_dol>=0|| find_wdo>=0)
              {
               sec_stop=0.0;
               sec_take=0.0;
               if(_Stop>0)sec_stop=mysymbol.NormalizePrice(price_limit-_Stop-4*ticksize);
               if(_TakeProfit>0)sec_take=mysymbol.NormalizePrice(price_limit+_TakeProfit+4*ticksize);
              }
            else
              {
               sec_stop=0.0;
               sec_take=0.0;
               if(_Stop>0)sec_stop=mysymbol.NormalizePrice(price_limit-_Stop-20*ticksize);
               if(_TakeProfit>0)sec_take=mysymbol.NormalizePrice(price_limit+_TakeProfit+20*ticksize);
              }
            if(mytrade.BuyLimit(volume_ent,price_limit,mysymbol.Name(),sec_stop,sec_take,order_time_type,0,"BUY"+exp_name))
              {
               if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                 {
                  gv.Set(cp_tick,(double)mytrade.ResultOrder());
                  mensagens=__FUNCSIG__+" Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
                  Print(mensagens);
                 }
               else
                 {
                  mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  Print(mensagens);
                 }
              }
            else
              {
               mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
               Print(mensagens);
              }

           }
         if(comboOrdens.Value()==1)//Sell
           {
            if(Buy_opened())
              {
               DeleteALL();
               ClosePosType(POSITION_TYPE_BUY);
              }
            price_limit=StringToDouble(m_spin_price_limit.Text());
            price_limit=mysymbol.NormalizePrice(MathRound(price_limit/ticksize)*ticksize);
            int find_wdo=StringFind(original_symbol,"WDO");
            int find_dol=StringFind(original_symbol,"DOL");
            if(find_dol>=0|| find_wdo>=0)
              {
               sec_stop=0.0;
               sec_take=0.0;
               if(_Stop>0)sec_stop=mysymbol.NormalizePrice(price_limit+_Stop+4*ticksize);
               if(_TakeProfit>0)sec_take=mysymbol.NormalizePrice(price_limit-_TakeProfit-4*ticksize);
              }
            else
              {
               sec_stop=0.0;
               sec_take=0.0;
               if(_Stop>0)sec_stop=mysymbol.NormalizePrice(price_limit+_Stop+20*ticksize);
               if(_TakeProfit>0)sec_take=mysymbol.NormalizePrice(price_limit-_TakeProfit-20*ticksize);
              }
            if(mytrade.SellLimit(volume_ent,price_limit,mysymbol.Name(),sec_stop,sec_take,order_time_type,0,"SELL"+exp_name))
              {
               if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                 {
                  gv.Set(vd_tick,(double)mytrade.ResultOrder());
                  mensagens=__FUNCSIG__+" Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
                  Print(mensagens);
                 }
               else
                 {
                  mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  Print(mensagens);
                 }
              }
            else
              {
               mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
               Print(mensagens);
              }

           }
         bln_open_limit=false;
        }

      //---
      //---

     } //End Trade On

  } //End OnTick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool Boleta::PosicaoAberta(void)
  {
   if(myposition.SelectByMagic(_Symbol,Magic_Number)==true)
      return(myposition.PositionType()== POSITION_TYPE_BUY||myposition.PositionType()== POSITION_TYPE_SELL);
   else return(false);
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
bool Boleta::Buy_opened(void)
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_BUY)
         return(true);  //It is a Buy
     }
   return(false);
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
bool Boleta::Sell_opened(void)
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_SELL)
         return(true);  //It is a Buy
     }
   return(false);
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
double Boleta::LucroOrdens()
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
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Boleta::LucroPositions()
  {
   double profit=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
         profit+=myposition.Profit();
   return profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool Boleta::TimeDayFilter()
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void Boleta::CloseByPosition()
  {
   ulong tick_sell,tick_buy;
   if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      while(Buy_opened() && Sell_opened())
        {
         tick_buy=TickecBuyPos();
         tick_sell=TickecSellPos();
         if(tick_buy>0 && tick_sell>0)mytrade.PositionCloseBy(tick_buy,tick_sell);
        }

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
ulong Boleta::TickecBuyPos()
  {
   ulong tick=0;
   if(Buy_opened())
     {

      for(int i=PositionsTotal()-1;i>=0; i--)
        {
         if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
           {
            if(myposition.PositionType()==POSITION_TYPE_BUY)
              {
               tick=myposition.Ticket();
               break;
              }
           }
        }

     }
   return tick;
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
ulong Boleta::TickecSellPos()
  {
   ulong tick=0;
   if(Sell_opened())
     {
      for(int i=PositionsTotal()-1;i>=0; i--)
        {
         if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
           {
            if(myposition.PositionType()==POSITION_TYPE_SELL)
              {
               tick=myposition.Ticket();
               break;
              }
           }
        }

     }
   return tick;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool Boleta::GetIndValue()
  {
   bool b_get;
   b_get=CopyHigh(Symbol(),period,0,5,high)<=0 || 
         CopyOpen(Symbol(),period,0,5,open)<=0 || 
         CopyLow(Symbol(),period,0,5,low)<=0 || 
         CopyClose(Symbol(),period,0,5,close)<=0;
   return(b_get);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void Boleta::setNameGvOrder()
  {
   cp_tick="cp_tick";
   vd_tick="vd_tick";
   tp_cp_tick="tp_cp_tick";
   tp_vd_tick="tp_vd_tick";
   stp_cp_tick="stp_cp_tick";
   stp_vd_tick="stp_vd_tick";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void Boleta::OnDeinit(const int reason)
  {
   gv.Deinit();
//   DeletaIndicadores();
   EventKillTimer();
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void Boleta::OnTimer()
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double Boleta::VolOrdAbert()
  {
   double volume=0;
   for(int i=OrdersTotal()-1; i>=0; i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            volume+=myorder.VolumeCurrent();
   return volume;
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
double Boleta::PrecoMedio(ENUM_POSITION_TYPE ptype)
  {
   double vol=0;
   double preco=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && myposition.Symbol()==mysymbol.Name())
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Boleta::VolumeOrdens(const ENUM_ORDER_TYPE order_type)
  {
   double volume=0;
   for(int i=OrdersTotal()-1; i>=0; i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               volume+=myorder.VolumeCurrent();
   return volume;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double Boleta::VolumeOrdensCmt(const string cmt)
  {
   double volume=0;
   for(int i=OrdersTotal()-1; i>=0; i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.Comment()==cmt)
               volume+=myorder.VolumeCurrent();
   return volume;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double Boleta::VolPosType(ENUM_POSITION_TYPE ptype)
  {
   double vol=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && myposition.Symbol()==mysymbol.Name())
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
//+------------------------------------------------------------------+
void Boleta::Entr_Parcial_Buy(const double preco)
  {
   if(num_ordens<=0)return;
   double preco_ent;
   for(int i=0;i<num_ordens;i++)
     {
      preco_ent=preco-(i+1)*dist_ordens*ponto;
      preco_ent=NormalizeDouble(preco_ent,digits);
      mytrade.BuyLimit(volume_ent,preco_ent,original_symbol,0,0,order_time_type,0,"Entrada Parcial "+IntegerToString(i+1));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void Boleta::Entr_Parcial_Sell(const double preco)
  {
   if(num_ordens<=0)return;
   double preco_ent;
   for(int i=0;i<num_ordens;i++)
     {
      preco_ent=preco+(i+1)*dist_ordens*ponto;
      preco_ent=NormalizeDouble(preco_ent,digits);
      mytrade.SellLimit(volume_ent,preco_ent,original_symbol,0,0,order_time_type,0,"Entrada Parcial "+IntegerToString(i+1));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void Boleta::ClosePosType(ENUM_POSITION_TYPE ptype)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void Boleta::DeleteOrdersComment(const string comm)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.Comment()==comm)
               mytrade.OrderDelete(myorder.Ticket());
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
void Boleta::DeleteOrdersWithComment(const string comm)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(StringFind(myorder.Comment(),comm)>=0)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void Boleta::CloseTPByPosition()
  {
   int total=PositionsTotal();
   for(int i=total-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i))
        {
         ulong ticket=myposition.Ticket();
         if(ticket<=0 || myposition.Symbol()!=original_symbol)
            continue;
         //---
         if(myposition.Magic()!=Magic_Number)
            continue;

         tp_comment=myposition.Comment();
         if(StringFind(tp_comment,"TP")==0 || StringFind(tp_comment,"GAIN")==0 || StringFind(tp_comment,"STOP")==0 || StringFind(tp_comment,"SL")==0)
           {
            int start=StringFind(tp_comment,"_");
            if(start>0)
              {
               long ticket_by=StringToInteger(StringSubstr(tp_comment,start+1));
               //      ENUM_POSITION_TYPE type=myposition.PositionType();
               //    if(ticket_by>0 && myposition.SelectByTicket(ticket_by) && type!=myposition.PositionType())
               if(ticket_by>0)
                 {
                  if(mytrade.PositionCloseBy(ticket,ticket_by))
                     continue;
                 }
              }
           }
        }
     }

  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
bool Boleta::CreateComboBox(const long chart,const string name,const int subwindow,CComboBox &object,const uint x1,const uint y1,const uint x2,const uint y2)

  {

//--- create 
   if(!object.Create(chart,name,subwindow,x1,y1,x2,y2))
      return(false);
   if(!Add(object))
      return(false);
//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+

void Boleta::DeleteOrdersExEntry()
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(StringFind(myorder.Comment(),"BUY")<0 && StringFind(myorder.Comment(),"SELL")<0)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+
