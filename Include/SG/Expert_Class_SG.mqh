//+------------------------------------------------------------------+
//|                                              my_expert_class.mqh |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include<Trade\AccountInfo.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
/*      if(!MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_TESTER))
         PrintFormat("New bar: %s",TimeToString(TimeCurrent(),TIME_SECONDS));*/
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
   void Init(string symbol,int magic)
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

#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
#include <Controls\ComboBox.mqh> 
#include <Controls\Edit.mqh>
#include <Controls\RadioGroup.mqh> 
#include <Controls\Picture.mqh>
#include <Controls\ListView.mqh>
#include <Controls\Rect.mqh>


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
//--- for the indication area 
#define EDIT_HEIGHT                         (20)      // size by Y coordinate 
//--- for group controls 
#define GROUP_WIDTH                         (150)     // size by X coordinate 
#define LIST_HEIGHT                         (179)     // size by Y coordinate 
#define RADIO_HEIGHT                        (56)      // size by Y coordinate 
#define CHECK_HEIGHT                        (93)      // size by Y coordinate //+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+ 
//| Class MyPanel                                            | 
//| Usage: main dialog of the Controls application                   | 
//+------------------------------------------------------------------+ 
class MyPanel : public CAppDialog
  {

public:
                     MyPanel(void);
                    ~MyPanel(void);
   //--- create 
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   virtual void      OnTick(void);
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

protected:
   //--- create dependent controls 
   bool              CreateLabel(const long chart,const int subwindow,CLabel &object,const string text,const uint x1,const uint y1,const uint x2,const uint y2);
   bool              CreateEdit(const long chart,const int subwindow,CEdit &object,const uint x1,const uint y1,const uint x2,const uint y2);
   bool              CreateButton(const long chart,const int subwindow,CButton &object,const string text,const uint x1,const uint y1,const uint x2,const uint y2);
   bool              CreatePicture(const long chart,const int subwindow,CPicture &object,const uint x1,const uint y1,const uint x2,const uint y2,string path);
   bool              CreatePanel(const long chart,const int subwindow,CPanel &object,const uint x1,const uint y1,const uint x2,const uint y2);
   bool              CreateComboBox(const long chart,const string name,const int subwindow,CComboBox &object,const uint x1,const uint y1,const uint x2,const uint y2);
   bool              CreateListView(const long chart,const string name,const int subwindow,CListView &object,const uint x1,const uint y1,const uint x2,const uint y2);
   bool              CreateRadioGroup(const long chart,const string name,const int subwindow,CRadioGroup &object,const uint x1,const uint y1,const uint x2,const uint y2);

  };
//+------------------------------------------------------------------+ 
//| Constructor                                                      | 
//+------------------------------------------------------------------+ 
MyPanel::MyPanel(void)
  {
  }
//+------------------------------------------------------------------+ 
//| Destructor                                                       | 
//+------------------------------------------------------------------+ 
MyPanel::~MyPanel(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyPanel::CreateLabel(const long chart,const int subwindow,CLabel &object,const string text,const uint x1,const uint y1,const uint x2,const uint y2)
  {
// All objects mast to have separate name
   string name="Label"+(string)ObjectsTotal(chart,-1,OBJ_LABEL);
//--- Call Create function
   if(!object.Create(chart,name,subwindow,x1,y1,x2,y2))
     {
      return false;
     }
//--- Addjust text
   if(!object.Text(text))
     {
      return false;
     }
//--- Add object to controls
   if(!Add(object))
     {
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyPanel::CreateEdit(const long chart,const int subwindow,CEdit &object,const uint x1,const uint y1,const uint x2,const uint y2)
  {
// All objects mast to have separate name
   string name="Edit"+(string)ObjectsTotal(chart,-1,OBJ_EDIT);
//--- Call Create function
   if(!object.Create(chart,name,subwindow,x1,y1,x2,y2))
     {
      return false;
     }

   if(!object.ReadOnly(false))
      return(false);

   if(!object.TextAlign(ALIGN_CENTER))
      return(false);

//--- Add object to controls
   if(!Add(object))
     {
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyPanel::CreateButton(const long chart,const int subwindow,CButton &object,const string text,const uint x1,const uint y1,const uint x2,const uint y2)
  {

// All objects mast to have separate name
   string name="Button"+(string)ObjectsTotal(chart,-1,OBJ_BUTTON);

//--- create 

   if(!object.Create(chart,name,subwindow,x1,y1,x2,y2))
      return(false);
   if(!object.Text(text))
      return(false);
   if(!Add(object))
      return(false);
//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyPanel::CreatePicture(const long chart,const int subwindow,CPicture &object,const uint x1,const uint y1,const uint x2,const uint y2,string path)
  {
// All objects mast to have separate name
   string name="Picture"+(string)ObjectsTotal(chart,-1,OBJ_BITMAP_LABEL);

//--- create 

   if(!object.Create(chart,name,subwindow,x1,y1,x2,y2))
      return(false);
   object.BmpName(path);
   if(!Add(object))
      return(false);
//--- definimos o nome dos arquivos bmp para exibir os controles CPicture 

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+

bool MyPanel::CreatePanel(const long chart,const int subwindow,CPanel &object,const uint x1,const uint y1,const uint x2,const uint y2)
  {
// All objects mast to have separate name
   string name="Panel"+(string)ObjectsTotal(chart,-1,OBJ_RECTANGLE_LABEL);

//--- create 
   if(!object.Create(chart,name,subwindow,x1,y1,x2,y2))
      return(false);
//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
bool MyPanel::CreateComboBox(const long chart,const string name,const int subwindow,CComboBox &object,const uint x1,const uint y1,const uint x2,const uint y2)

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
bool MyPanel::CreateRadioGroup(const long chart,const string name,const int subwindow,CRadioGroup &object,const uint x1,const uint y1,const uint x2,const uint y2)
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
//|                                                                  |
//+------------------------------------------------------------------+
bool MyPanel::CreateListView(const long chart,const string name,const int subwindow,CListView &object,const uint x1,const uint y1,const uint x2,const uint y2)

  {
//--- coordinates 
   if(!object.Create(chart,name,subwindow,x1,y1,x2,y2))
      return(false);
   if(!Add(object))
      return(false);
//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| CLASS DECLARATION                                                |
//+------------------------------------------------------------------+
class MyExpert
  {
   //--- private members
protected:
   int               Magic_Number;   //Expert Magic Number
   double            LOTS;       //Lots or volume to Trade
   string            symbol;     //variable to hold the current symbol name
   string            original_symbol;     //variable to hold the current symbol name
   ENUM_TIMEFRAMES   period;     //variable to hold the current timeframe value
   string            exp_name;
   CAccountInfo      myaccount;
   CDealInfo         mydeal;
   CTrade            mytrade;
   CPositionInfo     myposition;
   CSymbolInfo       mysymbol;
   COrderInfo        myorder;
   double            bid;
   double            ask;
   double            ponto;
   double            ticksize;
   int               digits;
   ENUM_ORDER_TYPE_TIME order_time_type;
   bool              tradeOn;
   MqlDateTime       TimeNow;
   datetime          hora_inicial;
   datetime          hora_final;
   bool              timerOn;
   uint              m_retcode;        // Result code of detecting new bar 
   int               m_new_bars;       // Number of new bars
   string            m_comment;        // Comment of execution
   datetime          m_lastbar_time;   // Time of opening last bar
   double            lucro_total;
   double            lucro_total_semana;
   double            lucro_total_mes;
   double            lucro_orders,lucro_positions;
   double            lucro_orders_mes,lucro_orders_sem;
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

   //--- Public member/functions
public:
   CGlobalVariables  gv;
   void              MyExpert();                                  //Class Constructor
   void             ~MyExpert();
   void              setSymbol(string syb){symbol=syb;}         //function to set current symbol
   void              setOriginalSymbol(string syb){original_symbol=syb;}         //function to set original symbol
   void              setPeriod(ENUM_TIMEFRAMES prd){period=prd;}//function to set current symbol timeframe/period
   void              setLOTS(double lot){LOTS=lot;}               //function to set The Lot size to trade
   void              setMagic(int magic){Magic_Number=magic;}         //function to set Expert Magic number
   void              setNameGvOrder();
   void setExpName(){exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);}
   bool              Buy_opened();
   bool              Sell_opened();
   virtual bool      BuySignal();
   virtual bool      SellSignal();
   void              DeletaIndicadores();
   string            CandleTime();

   //--- Protected members
protected:
  };   // end of class declaration
//+------------------------------------------------------------------+
//| Definition of our Class/member functions                         |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|  This CLASS CONSTRUCTOR                                          |
//|  *Does not have any input parameters                             |
//|  *Initilizes all the necessary variables                         |                 
//+------------------------------------------------------------------+
void MyExpert::MyExpert()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyExpert::~MyExpert()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+-----------------------------------------------------------------------+
//| OUR PUBLIC FUNCTIONS                                                  |
//+-----------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyExpert::setNameGvOrder()
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


string MyExpert::CandleTime()
  {
   int m=int(iTime(Symbol(),PERIOD_CURRENT,0)+PeriodSeconds()-TimeCurrent());
   int s=m%60;
   m=(m-s)/60;

   string _m="",_s="";
   if(m<10) _m="0";
   if(s<10) _s="0";

   return "Barra Fecha em "+_m+IntegerToString(m)+":"+_s+IntegerToString(s);

  }
//+------------------------------------------------------------------+
//|                                                                  |



bool MyExpert::Buy_opened()
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
bool MyExpert::Sell_opened()
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
bool MyExpert::BuySignal()
  {
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyExpert::SellSignal()
  {
   return false;
  }

void MyExpert::DeletaIndicadores()
  {
   string name;
//--- O número de janelas no gráfico (ao menos uma janela principal está sempre presente) 
   int windows=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
//--- Verifique todas as janelas 
   for(int w=windows-1;w>=0;w--)
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


