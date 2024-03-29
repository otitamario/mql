//+------------------------------------------------------------------+
//|                              Abritragem.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.0"
#property description "Arbitragem EA"
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
#include <Controls\ComboBox.mqh> 
#include <Controls\Edit.mqh>
#include <Controls\RadioGroup.mqh> 



#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>

input string indice_futuro="WINQ19";
input ulong Magic_Number=11062018;
input int EndHour=16;//Hora de Fechamento
input int EndMinute=45;//Minuto de Fechamento

                       //Global Variables
string ativo;
long ticket_acao,ticket_ind;
double lucro_acao,lucro_ind,alvo,perda;
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps 
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width) 
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width) 
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width) 
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width) 
#define CONTROLS_GAP_X                      (10)       // gap by X coordinate 
#define CONTROLS_GAP_Y                      (10)       // gap by Y coordinate 
//--- for buttons 
#define BUTTON_WIDTH                        (110)     // size by X coordinate 
#define BUTTON_HEIGHT                       (33)      // size by Y coordinate 

//--- for the indication area 
#define EDIT_HEIGHT                         (30)      // size by Y coordinate 
//--- for group controls 
#define GROUP_WIDTH                         (130)     // size by X coordinate 
#define LIST_HEIGHT                         (199)     // size by Y coordinate 
#define RADIO_HEIGHT                        (56)      // size by Y coordinate 
#define CHECK_HEIGHT                        (113)      // size by Y coordinate //---
//--- RadioGroup
//+------------------------------------------------------------------+
//| Class CControlsDialog                                            |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class ArbitragemPanel : public CAppDialog
  {
protected:
   CPositionInfo     m_position;                      // trade position object
   CTrade            m_trade;                         // trading object
   CAccountInfo      m_account;                       // account info wrapper

private:
   CButton           m_button_buysell;                       // the button object
   CButton           m_button_sellbuy;                       // the button object
   CButton           m_button_fechar;                       // the button object
   CComboBox         m_combo_box;;                    // CComboBox object 
   CEdit             m_edit_lot_acao;                          // CEdit object 
   CEdit             m_edit_lot_ind;                          // CEdit object 
   CEdit             m_edit_alvo;                          // CEdit object 
   CEdit             m_edit_perda;                          // CEdit object 
   CLabel            m_label_acao;
   CLabel            m_label_lote_acao;
   CLabel            m_label_indice;
   CLabel            m_label_lote_indice;
   CLabel            m_label_bid_acao;
   CLabel            m_label_bid_ind;
   CLabel            m_label_ask_acao;
   CLabel            m_label_ask_ind;
   CLabel            m_label_alvo;
   CLabel            m_label_perda;
   CLabel            m_label_posicao;
   CLabel            m_label_acao_profit;
   CLabel            m_label_ind_profit;
   CLabel            m_label_situacao;
   CRadioGroup       m_radio_group;                   // CRadioGroup object 

public:
                     ArbitragemPanel(void);
                    ~ArbitragemPanel(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   virtual void      OnTick(void);

protected:
   //--- create dependent controls
   bool              CreateButtonBuySell(void);
   bool              CreateButtonSellBuy(void);
   bool              CreateButtonFechar(void);
   bool              CreateRadioGroup(void);

   bool              CreateComboBox(void);
   bool              CreateEditLot(void);
   bool              CreateEditLotInd(void);
   bool              CreateEditAlvo(void);
   bool              CreateEditPerda(void);
   bool              CreateLabelAcao(void);
   bool              CreateLabelLot(void);
   bool              CreateLabelIndice(void);
   bool              CreateLabelLotIndice(void);
   bool              CreateLabelBidAcao(void);
   bool              CreateLabelBidInd(void);
   bool              CreateLabelAskAcao(void);
   bool              CreateLabelAskInd(void);
   bool              CreateLabelAlvo(void);
   bool              CreateLabelPerda(void);
   bool              CreateLabelAcaoProfit(void);
   bool              CreateLabelIndProfit(void);
   bool              CreateLabelSituacao(void);

   //--- handlers of the dependent controls events
   void              OnClickButtonBuySell(void);
   void              OnClickButtonSellBuy(void);
   void              OnClickButtonFechar(void);
   void              OnChangeComboBox(void);
   void              OnChangeRadioGroup(void);

  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(ArbitragemPanel)
ON_EVENT(ON_CLICK,m_button_buysell,OnClickButtonBuySell)
ON_EVENT(ON_CLICK,m_button_sellbuy,OnClickButtonSellBuy)
ON_EVENT(ON_CLICK,m_button_fechar,OnClickButtonFechar)
ON_EVENT(ON_CHANGE,m_radio_group,OnChangeRadioGroup)

ON_EVENT(ON_CHANGE,m_combo_box,OnChangeComboBox)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
ArbitragemPanel::ArbitragemPanel(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
ArbitragemPanel::~ArbitragemPanel(void)
  {
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool ArbitragemPanel::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   m_trade.SetExpertMagicNumber(Magic_Number);
   m_trade.SetTypeFilling(ORDER_FILLING_RETURN);
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//--- create dependent controls
   if(!CreateButtonBuySell())
      return(false);
   if(!CreateButtonSellBuy())
      return(false);
   if(!CreateButtonFechar())
      return(false);


   if(!CreateComboBox())
      return(false);
   if(!CreateEditLot())
      return(false);
   if(!CreateEditLotInd())
      return(false);
   if(!CreateEditAlvo())
      return(false);
   if(!CreateEditPerda())
      return(false);

   if(!CreateLabelAcao())
      return(false);
   if(!CreateLabelLot())
      return(false);
   if(!CreateLabelIndice())
      return(false);
   if(!CreateLabelLotIndice())
      return(false);
   if(!CreateLabelBidAcao())
      return(false);
   if(!CreateLabelBidInd())
      return(false);
   if(!CreateLabelAskAcao())
      return(false);
   if(!CreateLabelAskInd())
      return(false);
   if(!CreateLabelAlvo())
      return(false);
   if(!CreateLabelPerda())
      return(false);
   if(!CreateLabelAcaoProfit())
      return(false);
   if(!CreateLabelIndProfit())
      return(false);
   if(!CreateLabelSituacao())
      return(false);
   if(!CreateRadioGroup())
      return(false);

//--- succeed
   return(true);
  }

//+------------------------------------------------------------------+
//| Global Variable                                                  |
//+------------------------------------------------------------------+
ArbitragemPanel ExtDialog;
string Acoes[6]={"BOVA11","ITSA4","ITUB4","PETR4","USIM5","VALE3"};
bool fechar_zero;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- create application dialog
   if(!ExtDialog.Create(0,"Arbitragem EA",0,40,40,400,520))
      return(INIT_FAILED);
//--- run application
   ExtDialog.Run();
//--- succeed
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("");
//--- destroy dialog
   ExtDialog.Destroy(reason);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtDialog.OnTick();

  }
//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ArbitragemPanel::CreateComboBox(void)
  {
//--- coordinates 

   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;



//--- create 
   if(!m_combo_box.Create(m_chart_id,m_name+"ComboBox",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_combo_box))
      return(false);
//--- fill out with strings 
   for(int i=0;i<ArraySize(Acoes);i++)
      if(!m_combo_box.ItemAdd(Acoes[i]))
         return(false);
//m_combo_box.SelectByText("PETR4");
   ativo=m_combo_box.Select();
//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+ 
//| Event handler                                                    | 
//+------------------------------------------------------------------+ 
void ArbitragemPanel::OnChangeComboBox(void)
  {
   Comment(__FUNCTION__+" \""+m_combo_box.Select()+"\"");
   ativo=m_combo_box.Select();
   m_label_bid_acao.Text("BID "+DoubleToString(SymbolInfoDouble(ativo,SYMBOL_BID),SymbolInfoInteger(ativo,SYMBOL_DIGITS)));
   m_label_ask_acao.Text("BID "+DoubleToString(SymbolInfoDouble(ativo,SYMBOL_ASK),SymbolInfoInteger(ativo,SYMBOL_DIGITS)));


  }
//********************Buttons*******************************************

//+------------------------------------------------------------------+
//| Create the "Button1" button                                      |
//+------------------------------------------------------------------+
bool ArbitragemPanel::CreateButtonBuySell(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+5*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;

//--- create
   if(!m_button_buysell.Create(0,"Button1",0,x1,y1,x2,y2))
      return(false);
   if(!m_button_buysell.Text("BUY AC/SELL IND"))
      return(false);
   if(!Add(m_button_buysell))
      return(false);
   m_button_buysell.ColorBackground(clrAqua);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button2"                                             |
//+------------------------------------------------------------------+
bool ArbitragemPanel::CreateButtonSellBuy(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+1.5*BUTTON_WIDTH;
   int y1=INDENT_TOP+5*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_button_sellbuy.Create(0,"Button2",0,x1,y1,x2,y2))
      return(false);
   if(!m_button_sellbuy.Text("SELL AC/BUY IND"))
      return(false);
   if(!Add(m_button_sellbuy))
      return(false);
   m_button_sellbuy.ColorBackground(clrOrange);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ArbitragemPanel::CreateButtonFechar(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;        // x1            = 11  pixels
   int y1=INDENT_TOP+11*BUTTON_HEIGHT;         // y1            = 11  pixels
   int x2=x1+BUTTON_WIDTH;    // x2 = 11 + 100 = 111 pixels
   int y2=y1+BUTTON_HEIGHT;   // y2 = 11 + 20  = 32  pixels
//--- create
   if(!m_button_fechar.Create(0,"ButtonFechar",0,x1,y1,x2,y2))
      return(false);
   if(!m_button_fechar.Text("CLOSE ALL"))
      return(false);
   if(!Add(m_button_fechar))
      return(false);
   m_button_fechar.ColorBackground(clrLightCoral);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ArbitragemPanel::CreateRadioGroup(void)
  {
//--- coordinates 
   int x1=INDENT_LEFT+1.5*BUTTON_WIDTH;        // x1            = 11  pixels
   int y1=INDENT_TOP+11*BUTTON_HEIGHT;         // y1            = 11  pixels
   int x2=x1+GROUP_WIDTH;
   int y2=y1+RADIO_HEIGHT;
//--- create 
   if(!m_radio_group.Create(m_chart_id,m_name+"RadioGroup",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_radio_group))
      return(false);
//--- fill out with strings 
   if(!m_radio_group.AddItem("Fechar zero",1))
      return(false);
   if(!m_radio_group.AddItem("NÂO Fechar zero",2))
      return(false);

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Event handler                                                    | 
//+------------------------------------------------------------------+ 
void ArbitragemPanel::OnChangeRadioGroup(void)
  {
   Comment(__FUNCTION__+" : Value="+IntegerToString(m_radio_group.Value()));
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void ArbitragemPanel::OnClickButtonBuySell(void)
  {
   if(m_account.TradeMode()==ACCOUNT_TRADE_MODE_DEMO)
     {
      // ativo=ativo=m_combo_box.Select();
      Print("ATIVO ",ativo," Lote ",StringToDouble(m_edit_lot_acao.Text()));
      m_trade.Buy(StringToDouble(m_edit_lot_acao.Text()),ativo);
      ticket_acao=m_trade.ResultOrder();
      Print("ticket ",ticket_acao);
      Print("RESULT ",m_trade.ResultRetcodeDescription());
      m_trade.Sell(StringToDouble(m_edit_lot_ind.Text()),indice_futuro);
      ticket_ind=m_trade.ResultOrder();
     }
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void ArbitragemPanel::OnClickButtonSellBuy(void)
  {
   if(m_account.TradeMode()==ACCOUNT_TRADE_MODE_DEMO)
     {
      ativo=ativo=m_combo_box.Select();
      m_trade.Sell(StringToDouble(m_edit_lot_acao.Text()),ativo);
      ticket_acao=m_trade.ResultOrder();
      m_trade.Buy(StringToDouble(m_edit_lot_ind.Text()),indice_futuro);
      ticket_ind=m_trade.ResultOrder();

     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void ArbitragemPanel::OnClickButtonFechar(void)
  {
   if(m_account.TradeMode()==ACCOUNT_TRADE_MODE_DEMO)
      for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
         if(m_position.SelectByIndex(i) && m_position.Magic()==Magic_Number) // selects the position by index for further access to its properties
            if(m_position.Symbol()==Symbol())
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//*********************LABELS**********************************
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool ArbitragemPanel::CreateLabelAcao(void)
  {
//--- coordinates 
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP;
   int x2=x1+BUTTON_WIDTH;
   int y2=INDENT_TOP+BUTTON_HEIGHT;




//--- create 
   if(!m_label_acao.Create(m_chart_id,m_name+"LabelAcao",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label_acao.Text("Escolha a Ação"))
      return(false);
   if(!Add(m_label_acao))
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
bool ArbitragemPanel::CreateLabelLot(void)
  {
//--- coordinates 
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+2*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;




//--- create 
   if(!m_label_lote_acao.Create(m_chart_id,m_name+"LabelLot",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label_lote_acao.Text("Lotes"))
      return(false);
   if(!Add(m_label_lote_acao))
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
bool ArbitragemPanel::CreateLabelIndice(void)
  {
//--- coordinates 

   int x1=INDENT_LEFT+2*BUTTON_WIDTH;
   int y1=INDENT_TOP;
   int x2=x1+BUTTON_WIDTH;
   int y2=INDENT_TOP+BUTTON_HEIGHT;




//--- create 
   if(!m_label_indice.Create(m_chart_id,m_name+"LabelInd",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label_indice.Text(indice_futuro))
      return(false);
   if(!Add(m_label_indice))
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

bool ArbitragemPanel::CreateLabelLotIndice(void)
  {
//--- coordinates 

   int x1=INDENT_LEFT+BUTTON_WIDTH+5*CONTROLS_GAP_X;
   int y1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;




//--- create 
   if(!m_label_lote_indice.Create(m_chart_id,m_name+"LabelLotInd",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label_lote_indice.Text("Contratos"))
      return(false);
   if(!Add(m_label_lote_indice))
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
bool ArbitragemPanel::CreateLabelBidAcao(void)

  {
//--- coordinates 

   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+3*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;




//--- create 
   if(!m_label_bid_acao.Create(m_chart_id,m_name+"LabelBidAcao",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label_bid_acao.Text("BID "+DoubleToString(SymbolInfoDouble(ativo,SYMBOL_BID),SymbolInfoInteger(ativo,SYMBOL_DIGITS))))
      return(false);
   if(!Add(m_label_bid_acao))
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

bool ArbitragemPanel::CreateLabelBidInd(void)

  {
//--- coordinates 

   int x1=INDENT_LEFT+1.35*BUTTON_WIDTH+CONTROLS_GAP_X;
   int y1=INDENT_TOP+2*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=INDENT_LEFT+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;



//--- create 
   if(!m_label_bid_ind.Create(m_chart_id,m_name+"LabelBidInd",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label_bid_ind.Text("BID "+DoubleToString(SymbolInfoDouble(indice_futuro,SYMBOL_BID),SymbolInfoInteger(indice_futuro,SYMBOL_DIGITS))))
      return(false);
   if(!Add(m_label_bid_ind))
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
bool ArbitragemPanel::CreateLabelAskAcao(void)
  {
//--- coordinates 

   int x1=INDENT_LEFT+0.6*BUTTON_WIDTH;
   int y1=INDENT_TOP+3*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;




//--- create 
   if(!m_label_ask_acao.Create(m_chart_id,m_name+"LabelAskAcao",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label_ask_acao.Text("ASK "+DoubleToString(SymbolInfoDouble(ativo,SYMBOL_ASK),SymbolInfoInteger(ativo,SYMBOL_DIGITS))))
      return(false);
   if(!Add(m_label_ask_acao))
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

bool ArbitragemPanel::CreateLabelAskInd(void)
  {
//--- coordinates 
   int x1=INDENT_LEFT+2*BUTTON_WIDTH+2*CONTROLS_GAP_X;
   int y1=INDENT_TOP+2*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;


//--- create 
   if(!m_label_ask_ind.Create(m_chart_id,m_name+"LabelAskInd",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label_ask_ind.Text("ASK "+DoubleToString(SymbolInfoDouble(indice_futuro,SYMBOL_ASK),SymbolInfoInteger(indice_futuro,SYMBOL_DIGITS))))
      return(false);
   if(!Add(m_label_ask_ind))
      return(false);
//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ArbitragemPanel::CreateLabelAlvo(void)
  {
//--- coordinates 
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;




//--- create 
   if(!m_label_alvo.Create(m_chart_id,m_name+"LabelAlvo",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label_alvo.Text("Lucro ALVO"))
      return(false);
   if(!Add(m_label_alvo))
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

bool ArbitragemPanel::CreateLabelPerda(void)
  {
//--- coordinates 
   int x1=INDENT_LEFT+1.3*BUTTON_WIDTH;
   int y1=INDENT_TOP+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+0.5*BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;


//--- create 
   if(!m_label_perda.Create(m_chart_id,m_name+"LabelPerda",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label_perda.Text("Perda Máxima"))
      return(false);
   if(!Add(m_label_perda))
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
bool ArbitragemPanel:: CreateLabelAcaoProfit(void)
  {
//--- coordinates 
   int x1=INDENT_LEFT;
   int y1=INDENT_TOP+6*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;



//m_position.SelectByMagic(ativo,Magic_Number);
   m_position.SelectByTicket(ticket_acao);
   lucro_acao=m_position.Profit();
//--- create 
   if(!m_label_acao_profit.Create(m_chart_id,m_name+"LabelAcaoProfit",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label_acao_profit.Text("Lucro Acao: "+DoubleToString(lucro_acao,2)))
      return(false);
   if(!Add(m_label_acao_profit))
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

bool ArbitragemPanel::CreateLabelIndProfit(void)
  {
//--- coordinates 
   int x1=INDENT_LEFT+1.2*BUTTON_WIDTH;
   int y1=INDENT_TOP+6*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;

//m_position.SelectByMagic(indice_futuro,Magic_Number);
   m_position.SelectByTicket(ticket_ind);
   lucro_ind=m_position.Profit();

//--- create 
   if(!m_label_ind_profit.Create(m_chart_id,m_name+"LabelIndProf",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label_ind_profit.Text("Lucro Ind: "+DoubleToString(lucro_ind,2)))
      return(false);
   if(!Add(m_label_ind_profit))
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
bool ArbitragemPanel::CreateLabelSituacao(void)
  {
//--- coordinates 
   int x1=INDENT_LEFT+0.6*BUTTON_WIDTH;
   int y1=INDENT_TOP+7*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;




//--- create 
   if(!m_label_situacao.Create(m_chart_id,m_name+"LabelSituacao",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_label_situacao.Text("LUCRO ATUAL: "+DoubleToString(lucro_acao+lucro_ind,2)))
      return(false);
   if(!Add(m_label_situacao))
      return(false);
//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ArbitragemPanel::CreateEditLot(void)
  {
//--- coordinates 

   int x1=INDENT_LEFT+0.35*BUTTON_WIDTH;
   int y1=INDENT_TOP+2*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=INDENT_LEFT+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;

//--- create 
   if(!m_edit_lot_acao.Create(m_chart_id,m_name+"EditLot",m_subwin,x1,y1,x2,y2))
      return(false);
//--- allow editing the content 
   if(!m_edit_lot_acao.ReadOnly(false))
      return(false);

   if(!m_edit_lot_acao.TextAlign(ALIGN_CENTER))
      return(false);

   if(!Add(m_edit_lot_acao))
      return(false);
//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ArbitragemPanel::CreateEditLotInd(void)
  {
//--- coordinates 

   int x1=INDENT_LEFT+BUTTON_WIDTH+5*CONTROLS_GAP_X+0.7*BUTTON_WIDTH+CONTROLS_GAP_X;
   int y1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   int x2=x1+0.5*BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;

//--- create 
   if(!m_edit_lot_ind.Create(m_chart_id,m_name+"EditLotInd",m_subwin,x1,y1,x2,y2))
      return(false);
//--- allow editing the content 
   if(!m_edit_lot_ind.ReadOnly(false))
      return(false);

   if(!m_edit_lot_ind.TextAlign(ALIGN_CENTER))
      return(false);

   if(!Add(m_edit_lot_ind))
      return(false);
//--- succeed 
   return(true);
  }//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ArbitragemPanel::CreateEditAlvo(void)
  {
//--- coordinates 

   int x1=INDENT_LEFT+0.7*BUTTON_WIDTH;
   int y1=INDENT_TOP+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+0.5*BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;

//--- create 
   if(!m_edit_alvo.Create(m_chart_id,m_name+"EditAlvo",m_subwin,x1,y1,x2,y2))
      return(false);
//--- allow editing the content 
   if(!m_edit_alvo.ReadOnly(false))
      return(false);

   if(!m_edit_alvo.TextAlign(ALIGN_CENTER))
      return(false);

   if(!Add(m_edit_alvo))
      return(false);
//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ArbitragemPanel::CreateEditPerda(void)
  {
//--- coordinates 

   int x1=INDENT_LEFT+2.3*BUTTON_WIDTH;
   int y1=INDENT_TOP+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+0.5*BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;

//--- create 
   if(!m_edit_perda.Create(m_chart_id,m_name+"EditPerda",m_subwin,x1,y1,x2,y2))
      return(false);
//--- allow editing the content 
   if(!m_edit_perda.ReadOnly(false))
      return(false);

   if(!m_edit_perda.TextAlign(ALIGN_CENTER))
      return(false);

   if(!Add(m_edit_perda))
      return(false);
//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
void ArbitragemPanel::OnTick(void)
  {
   if(m_radio_group.Value()==1)fechar_zero=true;
   else fechar_zero=false;
//--- Change Ask and Bid prices on panel
   m_label_bid_acao.Text("BID "+DoubleToString(SymbolInfoDouble(ativo,SYMBOL_BID),SymbolInfoInteger(ativo,SYMBOL_DIGITS)));
   m_label_bid_ind.Text("BID "+DoubleToString(SymbolInfoDouble(indice_futuro,SYMBOL_BID),SymbolInfoInteger(indice_futuro,SYMBOL_DIGITS)));
   m_label_ask_acao.Text("BID "+DoubleToString(SymbolInfoDouble(ativo,SYMBOL_ASK),SymbolInfoInteger(ativo,SYMBOL_DIGITS)));
   m_label_ask_ind.Text("BID "+DoubleToString(SymbolInfoDouble(indice_futuro,SYMBOL_ASK),SymbolInfoInteger(indice_futuro,SYMBOL_DIGITS)));
// m_position.SelectByMagic(ativo,Magic_Number);
   m_position.SelectByTicket(ticket_acao);
   lucro_acao=m_position.Profit();
   m_label_acao_profit.Text("Lucro Acao: "+DoubleToString(lucro_acao,2));
// m_position.SelectByMagic(indice_futuro,Magic_Number);
   m_position.SelectByTicket(ticket_ind);
   lucro_ind=m_position.Profit();
   m_label_ind_profit.Text("Lucro Ind: "+DoubleToString(lucro_ind,2));
   alvo=StringToDouble(m_edit_alvo.Text());

   perda=StringToDouble(m_edit_perda.Text());

   double lucro_total=lucro_acao+lucro_ind;
   m_label_situacao.Text("LUCRO ATUAL: "+DoubleToString(lucro_total,2));
   if(PositionsTotal()>0 && lucro_total!=0.0 && (lucro_total>=alvo || lucro_total<=-perda))
     {
      m_trade.PositionClose(ticket_acao);
      m_trade.PositionClose(ticket_ind);
     }

   if(fechar_zero && PositionsTotal()>0 && (lucro_total>=-10 && lucro_total<=10))
     {
      m_trade.PositionClose(ticket_acao);
      m_trade.PositionClose(ticket_ind);
     }
   if(TimeClose() && PositionsTotal()>0)
     {
      m_trade.PositionClose(ticket_acao);
      m_trade.PositionClose(ticket_ind);
     }
  }
//+------------------------------------------------------------------+

bool TimeClose()
  {
   MqlDateTime TimeNow;
   TimeToStruct(TimeCurrent(),TimeNow);
   if( TimeNow.hour >= EndHour&& TimeNow.min>=EndMinute ) return true;
   return false;

  }
//+------------------------------------------------------------------+
