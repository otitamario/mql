//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+

input ulong          MAGIC_NUMBER=0;         // Número Mágico
sinput string STrailing="############---------------Trailing Stop----------########";//Trailing
input double TraillingStart=0;//Lucro Minimo Iniciar trailing stop
input double TraillingDistance=75;// Distanccia em Pontos do Stop Loss
input double TraillingStep=10;// Passo para atualizar Stop Loss

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
#include <SpinEditDouble.mqh>
#include <Controls\RadioGroup.mqh> 
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>  
#include <Trade\OrderInfo.mqh>
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
//| Class CTradingBoxingDialog                                       |
//| Usage: main dialog of the Controls application                   |
//+------------------------------------------------------------------+
class CTradingBoxingDialog : public CAppDialog
  {
private:
   CEdit             m_edit;                          // the display field object
   CButton           m_buttonZerar;                       // the button object
   CButton           m_buttonSell;                       // the button object
   CButton           m_buttonBuy;                       // the button object
   CSpinEditDouble   m_spin_edit1;                    // the spinedit object
   CSpinEditDouble   m_spin_edit2;                    // the spinedit object
   CSpinEditDouble   m_spin_editStop;                   // the spinedit object
   CSpinEditDouble   m_spin_editTake;                   // the spinedit object
   CLabel            m_label_Stop; //label
   CLabel            m_label_Take; //label
   CLabel            m_label_Posicao; //label
   CLabel            m_label_VolPosicao; //label
   CRadioGroup       Trailing_ativar;

   //---
   CPositionInfo     m_position;                      // trade position object
   CTrade            m_trade;                         // trading object
   CSymbolInfo       m_symbol;                        // symbol info object
   COrderInfo        m_order;                         // pending orders object
   //---
   ulong             m_magic;                         // magic number
   ulong             m_slippage;                      // slippage
   string            original_symbol;//Original Symbol
   double            ponto,ticksize;
   int               digits;
   //--- refresh rates
   bool              RefreshRates(void);
   //--- close positions  
   void              CloseALL(void);
   void              DeleteALL(void);
   bool              PosicaoAberta(void);
   bool              BuyOpenned(void);
   bool              SellOpenned(void);
   double            VolumePositions(void);
   void              TrailingStop(double pTrailPoints,double pMinProfit=0,double pStep=10);

   void              ClosePositions(const ENUM_POSITION_TYPE pos_type);
   //--- calculate positions                              
   int               CalculatePositions(const ENUM_POSITION_TYPE pos_type);
   //--- delete pending orders                                                
   void              DeleteOrders(const ENUM_ORDER_TYPE order_type);
   //--- calculate pending orders                                                
   int               CalculateOrders(const ENUM_ORDER_TYPE order_type);
   //---
   bool              bln_close_all;

   double            dbl_volume_buy;
   bool              bln_open_buy;

   double            dbl_volume_sell;
   bool              bln_open_sell;

   double            stop_points;
   double            take_points;
public:
                     CTradingBoxingDialog(void);
                    ~CTradingBoxingDialog(void);
   //--- create
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,
                            const int x2,const int y2,const ulong magic);
   //--- chart event handler
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //---
   void              OnTick(void);

protected:
   //--- create dependent controls
   bool              CreateButtonZerar(void);
   bool              CreateButtonSell(void);
   bool              CreateButtonBuy(void);
   bool              CreateSpinEdit1(void);
   bool              CreateSpinEdit2(void);
   bool              CreateSpinEditStop(void);
   bool              CreateSpinEditTake(void);
   bool              CreateLabelStop(void);
   bool              CreateLabelTake(void);
   bool              CreateLabelPosicao(void);
   bool              CreateLabelVolPosicao(void);
   bool              CreateTrailingAtivar(void);

   //--- override the parent method
   virtual void      Minimize(void);
   //--- handlers of the dependent controls events
   void              OnClickButtonZerar(void) { bln_close_all=true;                    OnTick();   }
   void              OnClickButtonSell(void) { bln_open_sell=true;                    OnTick();   }
   void              OnClickButtonBuy(void) { bln_open_buy=true;                    OnTick();   }
   void              OnChangeSpinEdit1(void)    { dbl_volume_sell       = m_spin_edit1.Value();    OnTick();   }
   void              OnChangeSpinEdit2(void)    { dbl_volume_buy       = m_spin_edit2.Value();    OnTick();   }
   void              OnChangeSpinEditStop(void)   { stop_points  = m_spin_editStop.Value();   OnTick();   }
   void              OnChangeSpinEditTake(void)   { take_points  = m_spin_editTake.Value();   OnTick();   }

  };
//+------------------------------------------------------------------+
//| Event Handling                                                   |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CTradingBoxingDialog)
ON_EVENT(ON_CLICK,m_buttonZerar,OnClickButtonZerar)
ON_EVENT(ON_CLICK,m_buttonSell,OnClickButtonSell)
ON_EVENT(ON_CLICK,m_buttonBuy,OnClickButtonBuy)
ON_EVENT(ON_CHANGE,m_spin_edit1,OnChangeSpinEdit1)
ON_EVENT(ON_CHANGE,m_spin_edit2,OnChangeSpinEdit2)
ON_EVENT(ON_CHANGE,m_spin_editStop,OnChangeSpinEditStop)
ON_EVENT(ON_CHANGE,m_spin_editTake,OnChangeSpinEditTake)

EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradingBoxingDialog::CTradingBoxingDialog(void) : m_magic(335685240),
                                                   m_slippage(100),
                                                   bln_close_all(false),
                                                   bln_open_buy(false),
                                                   bln_open_sell(false)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTradingBoxingDialog::~CTradingBoxingDialog(void)
  {
  }
//+------------------------------------------------------------------+
//| Create                                                           |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,
                                  const int x2,const int y2,const ulong magic)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
//---
   original_symbol=Symbol();
   if(!m_symbol.Name(original_symbol)) // sets symbol name
      return(false);
   RefreshRates();
   m_magic=magic;
   m_trade.SetExpertMagicNumber(m_magic);
   m_trade.SetMarginMode();
   m_trade.SetTypeFillingBySymbol(m_symbol.Name());
   m_trade.SetDeviationInPoints(m_slippage);

   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);

   int find_wdo=StringFind(original_symbol,"WDO");
   int find_dol=StringFind(original_symbol,"DOL");
   if(find_dol>=0|| find_wdo>=0) ponto=1.0;


//--- create dependent controls
   if(!CreateButtonZerar())
      return(false);
   if(!CreateButtonSell())
      return(false);
   if(!CreateButtonBuy())
      return(false);
   if(!CreateSpinEdit1())
      return(false);
   if(!CreateSpinEdit2())
      return(false);
   if(!CreateSpinEditStop())
      return(false);
   if(!CreateSpinEditTake())
      return(false);
   if(!CreateLabelStop())
      return(false);
   if(!CreateLabelTake())
      return(false);
   if(!CreateLabelPosicao())
      return(false);
   if(!CreateLabelVolPosicao())
      return(false);
   if(!CreateTrailingAtivar())
      return(false);


//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Refreshes the symbol quotes data                                 |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::RefreshRates(void)
  {
//--- refresh rates
   if(!m_symbol.RefreshRates())
     {
      Print("RefreshRates error");
      return(false);
     }
//--- protection against the return value of "zero"
   if(m_symbol.Ask()==0 || m_symbol.Bid()==0)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void CTradingBoxingDialog::DeleteALL(void)
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
     {
      ulong o_ticket=OrderGetTicket(j);
      if(o_ticket!=0)
        {
         m_order.Select(o_ticket);
         if(m_order.Magic()==m_magic && m_order.Symbol()==m_symbol.Name()) m_trade.OrderDelete(o_ticket);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CTradingBoxingDialog::CloseALL(void)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(m_position.SelectByIndex(i) && m_position.Magic()==m_magic && m_position.Symbol()==m_symbol.Name())
        {
         if(!m_trade.PositionClose(PositionGetTicket(i)))
           {
            Print(PositionGetTicket(i),"PositionClose() method failed. Return code=",m_trade.ResultRetcode(),
                  ". Code description: ",m_trade.ResultRetcodeDescription());
           }
         else
           {
            Print(PositionGetTicket(i),"PositionClose() method executed successfully. Return code=",m_trade.ResultRetcode(),
                  " (",m_trade.ResultRetcodeDescription(),")");
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Close positions                                                  |
//+------------------------------------------------------------------+
void CTradingBoxingDialog::ClosePositions(const ENUM_POSITION_TYPE pos_type)
  {
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of current positions
      if(m_position.SelectByIndex(i))     // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type) // gets the position type
               m_trade.PositionClose(m_position.Ticket()); // close a position by the specified symbol
  }
//+------------------------------------------------------------------+
//| Calculate positions                                              |
//+------------------------------------------------------------------+
int CTradingBoxingDialog::CalculatePositions(const ENUM_POSITION_TYPE pos_type)
  {
   int total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            if(m_position.PositionType()==pos_type)
               total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CTradingBoxingDialog::VolumePositions(void)
  {
   double total=0;

   for(int i=PositionsTotal()-1;i>=0;i--)
      if(m_position.SelectByIndex(i)) // selects the position by index for further access to its properties
         if(m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic)
            total+=m_position.Volume();
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void CTradingBoxingDialog::DeleteOrders(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            if(m_order.OrderType()==order_type)
               m_trade.OrderDelete(m_order.Ticket());
  }
//+------------------------------------------------------------------+
//| Calculate Orders                                                    |
//+------------------------------------------------------------------+
int CTradingBoxingDialog::CalculateOrders(const ENUM_ORDER_TYPE order_type)
  {
   int total=0;

   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(m_order.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(m_order.Symbol()==m_symbol.Name() && m_order.Magic()==m_magic)
            if(m_order.OrderType()==order_type)
               total++;
//---
   return(total);
  }
//+------------------------------------------------------------------+
//| Create the "Button1" button                                      |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateButtonZerar(void)
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
bool CTradingBoxingDialog::CreateLabelStop(void)
  {
// All objects mast to have separate name
   string name="LabelStop"+(string)ObjectsTotal(m_chart_id,-1,OBJ_LABEL);
//--- Call Create function
   int x1=INDENT_LEFT;
   int y1=2*INDENT_TOP+(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;

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
bool CTradingBoxingDialog::CreateLabelTake(void)
  {
// All objects mast to have separate name
   string name="LabelTake"+(string)ObjectsTotal(m_chart_id,-1,OBJ_LABEL);
//--- Call Create function
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=2*INDENT_TOP+(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;


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
bool CTradingBoxingDialog::CreateSpinEditStop(void)
  {
   double min_value;
   int find_wdo=StringFind(original_symbol,"WDO");
   int find_dol=StringFind(original_symbol,"DOL");
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
   m_spin_editStop.DisplayedDigits(m_symbol.Digits());
   m_spin_editStop.MinValue(m_symbol.TickSize()*min_value);
   m_spin_editStop.MaxValue(m_symbol.TickSize()*2000.0);
   m_spin_editStop.Value(0.0);
   stop_points=m_spin_editStop.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateSpinEditTake(void)
  {
   double min_value;
   int find_wdo=StringFind(original_symbol,"WDO");
   int find_dol=StringFind(original_symbol,"DOL");
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
   m_spin_editTake.DisplayedDigits(m_symbol.Digits());
   m_spin_editTake.MinValue(m_symbol.TickSize()*min_value);
   m_spin_editTake.MaxValue(m_symbol.TickSize()*2000.0);
   m_spin_editTake.Value(0.0);
   take_points=m_spin_editTake.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button7" button                                      |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateButtonSell(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=2*INDENT_TOP+3*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_buttonSell.Create(m_chart_id,m_name+"Button7",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_buttonSell.Text("Sell "+DoubleToString(m_symbol.Bid(),m_symbol.Digits())))
      return(false);
   m_buttonSell.ColorBackground(clrMediumVioletRed);
   m_buttonSell.Color(clrYellow);

   if(!Add(m_buttonSell))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "Button8" button                                      |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateButtonBuy(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=2*INDENT_TOP+3*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;


//--- create
   if(!m_buttonBuy.Create(m_chart_id,m_name+"Button8",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!m_buttonBuy.Text("Buy "+DoubleToString(m_symbol.Ask(),m_symbol.Digits())))
      return(false);
   m_buttonBuy.ColorBackground(clrAqua);
   if(!Add(m_buttonBuy))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "SpinEdit1" element                                   |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateSpinEdit1(void)
  {
//--- coordinates
   int x1=INDENT_LEFT;
   int y1=2*INDENT_TOP+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_spin_edit1.Create(m_chart_id,m_name+"SpinEdit1",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_spin_edit1))
      return(false);
   m_spin_edit1.DisplayedDigits(2);
   m_spin_edit1.MinValue(m_symbol.LotsMin());
   m_spin_edit1.MaxValue(m_symbol.LotsMax());
   m_spin_edit1.Value(m_symbol.LotsMin());
   dbl_volume_sell=m_spin_edit1.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "SpinEdit2" element                                   |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateSpinEdit2(void)
  {
//--- coordinates
   int x1=INDENT_LEFT+(BUTTON_WIDTH+CONTROLS_GAP_X);
   int y1=2*INDENT_TOP+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;
//--- create
   if(!m_spin_edit2.Create(m_chart_id,m_name+"SpinEdit2",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(m_spin_edit2))
      return(false);
   m_spin_edit2.DisplayedDigits(2);
   m_spin_edit2.MinValue(m_symbol.LotsMin());
   m_spin_edit2.MaxValue(m_symbol.LotsMax());
   m_spin_edit2.Value(m_symbol.LotsMin());
   dbl_volume_buy=m_spin_edit2.Value();
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::CreateLabelPosicao(void)
  {
// All objects mast to have separate name
   string name="LabelPosicao"+(string)ObjectsTotal(m_chart_id,-1,OBJ_LABEL);
//--- Call Create function
   int x1=INDENT_LEFT;
   int y1=2*INDENT_TOP+5*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;


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
bool CTradingBoxingDialog::CreateLabelVolPosicao(void)
  {
// All objects mast to have separate name
   string name="LabelVolPosicao"+(string)ObjectsTotal(m_chart_id,-1,OBJ_LABEL);
//--- Call Create function
   int x1=INDENT_LEFT;
   int y1=2*INDENT_TOP+6*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2=x1+BUTTON_WIDTH;
   int y2=y1+BUTTON_HEIGHT;


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
bool CTradingBoxingDialog::CreateTrailingAtivar(void)
  {

   int x1=INDENT_LEFT;
   int y1=2*INDENT_TOP+7*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   int x2 = x1 + GROUP_WIDTH;
   int y2 = y1 + RADIO_HEIGHT;

   if(!Trailing_ativar.Create(m_chart_id,"Radio TrailingGroup",m_subwin,x1,y1,x2,y2))
      return(false);
   if(!Add(Trailing_ativar))
      return(false);
   Trailing_ativar.AddItem("Ativar Trailing", 0);
   Trailing_ativar.AddItem("Desativar Trailing", 1);
   Trailing_ativar.BorderType(BORDER_FLAT);
   Trailing_ativar.ColorBorder(clrDarkBlue);
   Trailing_ativar.Value(1);

   return true;
  }
//+------------------------------------------------------------------+
//| Minimize                                                         |
//|   --> https://www.mql5.com/ru/articles/4503#para10               |
//+------------------------------------------------------------------+
void CTradingBoxingDialog::Minimize(void)
  {
//--- переменная для получения панели быстрой торговли
   long one_click_visible=-1;  // 0 - панели быстрой торговли нет 
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
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void CTradingBoxingDialog::OnTick(void)
  {
   double price_stop,price_take;
   static double last_bid=0;
   if(!PosicaoAberta())
     {
      m_label_Posicao.Text("Posição: ZERADO");
      m_label_VolPosicao.Text("Vol: - ");
     }
   else
     {
      if(BuyOpenned())
         m_label_Posicao.Text("Posição: COMPRADO");
      if(SellOpenned())
         m_label_Posicao.Text("Posição: VENDIDO");
      m_label_VolPosicao.Text("Vol: "+DoubleToString(VolumePositions(),2));
      if(Trailing_ativar.Value()==0) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);

     }
   RefreshRates();
   Maximize();
   m_buttonSell.Text("Sell "+DoubleToString(m_symbol.Bid(),m_symbol.Digits()));
   m_buttonBuy.Text("Buy "+DoubleToString(m_symbol.Ask(),m_symbol.Digits()));

   if(m_symbol.Bid()<last_bid && last_bid>0)
     {
      color cor_baixa=clrOrange;
      m_buttonZerar.ColorBackground(cor_baixa);
      m_buttonSell.ColorBackground(cor_baixa);
      m_buttonBuy.ColorBackground(cor_baixa);

      color cor_texto1=clrBlack;
      color cor_texto2=clrWhite;
      m_buttonZerar.Color(cor_texto1);
      m_buttonSell.Color(cor_texto1);
      m_buttonBuy.Color(cor_texto1);

     }
   else if(m_symbol.Bid()>last_bid && last_bid>0)
     {
      color cor_alta=clrDeepSkyBlue;
      m_buttonZerar.ColorBackground(cor_alta);
      m_buttonSell.ColorBackground(cor_alta);
      m_buttonBuy.ColorBackground(cor_alta);

     }
   else
     {
      m_buttonZerar.ColorBackground(clrLime);
      m_buttonSell.ColorBackground(clrBlueViolet);
      m_buttonBuy.ColorBackground(clrMediumVioletRed);

     }

   last_bid=m_symbol.Bid();
   if(bln_close_all)
     {
      CloseALL();
      DeleteALL();
      bln_close_all=false;
     }
//---
//---
   if(bln_open_buy)
     {
      if(stop_points==0)price_stop=0;
      else price_stop=NormalizeDouble(m_symbol.Bid()-stop_points,m_symbol.Digits());
      if(take_points==0)price_take=0;
      else price_take=NormalizeDouble(m_symbol.Ask()+take_points,m_symbol.Digits());
      m_trade.Buy(dbl_volume_buy,m_symbol.Name(),0,price_stop,price_take,NULL);
      bln_open_buy=false;
     }
//---
   if(bln_open_sell)
     {
      if(stop_points==0)price_stop=0;
      else price_stop=NormalizeDouble(m_symbol.Ask()+stop_points,m_symbol.Digits());
      if(take_points==0)price_take=0;
      else price_take=NormalizeDouble(m_symbol.Bid()-take_points,m_symbol.Digits());

      m_trade.Sell(dbl_volume_sell,m_symbol.Name(),0,price_stop,price_take,NULL);
      bln_open_sell=false;
     }
//---
  }
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::PosicaoAberta(void)
  {
   if(m_position.SelectByMagic(original_symbol,m_magic)==true)
      return(m_position.PositionType()== POSITION_TYPE_BUY||m_position.PositionType()== POSITION_TYPE_SELL);
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::BuyOpenned(void)
  {
   if(m_position.SelectByMagic(original_symbol,m_magic)==true)
      return(m_position.PositionType()== POSITION_TYPE_BUY);
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTradingBoxingDialog::SellOpenned(void)
  {
   if(m_position.SelectByMagic(original_symbol,m_magic)==true)
      return(m_position.PositionType()== POSITION_TYPE_SELL);
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


void CTradingBoxingDialog::TrailingStop(double pTrailPoints,double pMinProfit=0,double pStep=10)
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(m_position.SelectByIndex(i) && m_position.Symbol()==m_symbol.Name() && m_position.Magic()==m_magic && pTrailPoints>0)
        {
         double currentTakeProfit=m_position.TakeProfit();
         long posType=m_position.PositionType();
         double currentStop=m_position.StopLoss();
         double openPrice=m_position.PriceOpen();
         if(pStep<10) pStep=10;
         double step=pStep*ponto;

         double minProfit = pMinProfit * ponto;
         double trailStop = pTrailPoints * ponto;
         currentTakeProfit=NormalizeDouble(currentTakeProfit,digits);
         double trailStopPrice;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            trailStopPrice = SymbolInfoDouble(_Symbol,SYMBOL_BID)- trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=SymbolInfoDouble(_Symbol,SYMBOL_BID)-openPrice;

            if(trailStopPrice>currentStop+step && currentProfit>=minProfit)
              {
               m_trade.PositionModify(m_position.Ticket(),trailStopPrice,currentTakeProfit);

              }

           }
         else if(posType==POSITION_TYPE_SELL)
           {
            trailStopPrice = SymbolInfoDouble(_Symbol,SYMBOL_ASK) + trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=openPrice-SymbolInfoDouble(_Symbol,SYMBOL_ASK);

            if((trailStopPrice<currentStop-step || currentStop==0) && currentProfit>=minProfit)
              {
               m_trade.PositionModify(m_position.Ticket(),trailStopPrice,currentTakeProfit);

              }

           }
        }

     }
  }
//+------------------------------------------------------------------+
