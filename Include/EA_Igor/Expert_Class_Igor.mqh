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
enum OpcoesDistancia //
  {
   DistPontos,//Pontos
   DistForex,//Forex(Pips)
   DistBarra//Vezes a Amplitude da Barra
  };
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
      if(!MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_TESTER))
         PrintFormat("New bar: %s",TimeToString(TimeCurrent(),TIME_SECONDS));
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
   template<typename T>
   void              OnTick(T &MyEA);
   void              OnTick();
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
   ulong             Magic_Number;   //Expert Magic Number
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
   CHistoryOrderInfo myhistory;
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
   double            TrailPerc,TrailProfitMin;
   //--- Public member/functions
public:
   static bool       profitstart;
   CGlobalVariables  gv;
   void              MyExpert();                                  //Class Constructor
   void             ~MyExpert();
   void              setSymbol(string syb){symbol=syb;}         //function to set current symbol
   void              setOriginalSymbol(string syb){original_symbol=syb;}         //function to set original symbol
   void              setPeriod(ENUM_TIMEFRAMES prd){period=prd;}//function to set current symbol timeframe/period
   void              setLOTS(double lot){LOTS=lot;}               //function to set The Lot size to trade
   void              setMagic(ulong magic){Magic_Number=magic;}         //function to set Expert Magic number
   void              setNameGvOrder();
   void setExpName(){exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);}
   bool              Buy_opened();
   bool              Sell_opened();
   virtual bool      BuySignal();
   virtual bool      SellSignal();
   virtual bool      GetIndValue();
   void              CloseALL();
   void              ClosePosType(ENUM_POSITION_TYPE ptype);
   void              DeleteALL();
   void              DeleteAbertas(double distancia);
   double            PriceLastStopOrder(const ENUM_ORDER_TYPE pending_order_type);
   void              DeleteOrders(const ENUM_ORDER_TYPE order_type);
   bool              OrdemAberta(const ENUM_ORDER_TYPE order_type);
   int               TotalGains();
   int               TotalEntradas();
   int               TotalEntradasSemana();
   int               TotalGainsSemana();
   double            LossOrdensSemana();
   double            GainsOrdensSemana();
   virtual double    LucroOrdensSemana();
   virtual double    LucroOrdensMes();
   double            LossOrdens();
   double            GainsOrdens();
   virtual double    LucroOrdens();
   virtual double    LucroPositions();
   double LucroTotal(){return LucroOrdens()+LucroPositions();}
   double LucroTotalMes(){return LucroOrdensMes()+LucroPositions();}
   double LucroTotalSemana(){return LucroOrdensSemana()+LucroPositions();}
   void              DeletaIndicadores();
   bool              PosicaoAberta();
   void              Atual_vol_Stop_Take();
   double            VolPosType(ENUM_POSITION_TYPE ptype);
   void              DeleteOrdersExEntry();
   void              DeleteOrdersComment(const string comm);
   void              CloseByPosition();
   ulong             TickecBuyPos();
   ulong             TickecSellPos();
   double            PrecoMedio(ENUM_POSITION_TYPE ptype);
   void              BreakEven(string pSymbol,bool usarbreak,double &pBreakEven[],double &pLockProfit[]);
   void              BreakEven(string pSymbol,bool usarbreak,double &pBreakEven[],double &pLockProfit[],OpcoesDistancia opt=DistPontos,double tam_barra=1);
   void              BreakEvenOrders(string pSymbol,bool usarbreak,double &pBreakEven[],double &pLockProfit[]);
   void              TrailingStop(double pTrailPoints,double pMinProfit=0,double pStep=10);
   void              TrailingStop(double pTrailPoints,double pMinProfit=0,double pStep=10,OpcoesDistancia opt=DistPontos,double tam_barra=1);
   void              TrailingStopOrders(double pTrailPoints,double pMinProfit=0,double pStep=10);
   void              Trailing_Candle(double dist);
   long              WeekStartTime(datetime aTime,bool aStartsOnMonday=false);
   bool              OrdemAbertaComent(const string cmt);
   void              DeleteOrdersLimit(const ENUM_ORDER_TYPE order_type,double price);
   double            VolumeOrdens(const ENUM_ORDER_TYPE order_type);
   double            VolumeOrdensCmt(const string cmt);
   string            CandleTime();
   double            VolOrdAbert();
   double            PrecoOrdAbCmt(const string cmt);
   double            StopLoss();
   double            TakeProfit();
   void              TrailingProfit(double pTrailPerc,double pMinProfit,double pStep);
   double            NormalizaPreco(double preco);

   //--- Protected members
  };   // end of class declaration

bool MyExpert::profitstart=false;
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
//+------------------------------------------------------------------+

double MyExpert::VolOrdAbert()
  {
   double volume=0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            volume+=myorder.VolumeCurrent();
   return volume;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyExpert::TrailingStop(double pTrailPoints,double pMinProfit=0,double pStep=10)
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number && pTrailPoints>0)
        {

         double currentTakeProfit=myposition.TakeProfit();
         long posType=myposition.PositionType();
         double currentStop=myposition.StopLoss();
         //double openPrice=myposition.PriceOpen();
         double openPrice;
         double _tick=SymbolInfoDouble(myposition.Symbol(),SYMBOL_TRADE_TICK_SIZE);
         if(pStep<_tick) pStep=_tick;
         double step=pStep*ponto;

         double minProfit = pMinProfit * ponto;
         double trailStop = pTrailPoints * ponto;
         currentTakeProfit=NormalizeDouble(currentTakeProfit,digits);
         double trailStopPrice;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            openPrice=PrecoMedio(POSITION_TYPE_BUY);
            trailStopPrice = bid - trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=bid-openPrice;

            if(trailStopPrice>currentStop+step && currentProfit>=minProfit)
              {
               mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);

              }

           }
         else if(posType==POSITION_TYPE_SELL)
           {
            openPrice=PrecoMedio(POSITION_TYPE_SELL);
            trailStopPrice = ask + trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
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

void MyExpert::TrailingStop(double pTrailPoints,double pMinProfit=0,double pStep=10,OpcoesDistancia opt=DistPontos,double tam_barra=1)
  {
   double _Ponto=ponto;
   if(opt==DistForex)_Ponto=10*ponto;
   if(opt==DistBarra)_Ponto=tam_barra*ponto;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number && pTrailPoints>0)
        {

         double currentTakeProfit=myposition.TakeProfit();
         long posType=myposition.PositionType();
         double currentStop=myposition.StopLoss();
         //double openPrice=myposition.PriceOpen();
         double openPrice;
         double _tick=SymbolInfoDouble(myposition.Symbol(),SYMBOL_TRADE_TICK_SIZE);
         if(pStep<_tick) pStep=_tick;
         double step=pStep*_Ponto;
         double minProfit = pMinProfit * _Ponto;
         double trailStop = pTrailPoints * _Ponto;
         currentTakeProfit=NormalizeDouble(currentTakeProfit,digits);
         double trailStopPrice;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            openPrice=PrecoMedio(POSITION_TYPE_BUY);
            trailStopPrice = bid - trailStop;
            trailStopPrice = NormalizaPreco(trailStopPrice);
            currentProfit=bid-openPrice;

            if(trailStopPrice>currentStop+step && currentProfit>=minProfit)
              {
               mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);

              }

           }
         else if(posType==POSITION_TYPE_SELL)
           {
            openPrice=PrecoMedio(POSITION_TYPE_SELL);
            trailStopPrice = ask + trailStop;
            trailStopPrice = NormalizaPreco(trailStopPrice);
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
//|                                                                  |
//+------------------------------------------------------------------+
void MyExpert::TrailingProfit(double pTrailPerc,double pMinProfit,double pStep)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number)
        {

         long posType=myposition.PositionType();
         double lots=myposition.Volume();
         double currentStop=myposition.StopLoss();
         double trailStopPrice;
         double trailStop;
         double currentProfit=myposition.Profit();
         if(posType==POSITION_TYPE_BUY)
           {
            trailStopPrice=(bid-currentStop)*VolPosType(POSITION_TYPE_BUY)*ponto*mysymbol.TickValue()/ticksize;

            if((1-pTrailPerc*0.01)*currentProfit<trailStopPrice+(1-pTrailPerc*0.01)*pStep && currentProfit>=pMinProfit)
              {
               trailStop=(currentProfit*pTrailPerc*0.01*ticksize/mysymbol.TickValue())*ponto;
               trailStop=trailStop/VolPosType(POSITION_TYPE_BUY);
               trailStop=MathRound(trailStop/ticksize)*ticksize;
               trailStopPrice=NormalizeDouble(bid-trailStop*ponto,mysymbol.Digits());
               if(trailStopPrice>currentStop)
                 {
                  mytrade.PositionModify(myposition.Ticket(),trailStopPrice,myposition.TakeProfit());
                  profitstart=true;
                 }
              }

           }
         else if(posType==POSITION_TYPE_SELL)
           {
            trailStopPrice=(currentStop-ask)*VolPosType(POSITION_TYPE_SELL)*ponto*mysymbol.TickValue()/ticksize;
            if((1-pTrailPerc*0.01)*currentProfit<trailStopPrice+(1-pTrailPerc*0.01)*pStep && currentProfit>=pMinProfit)
              {
               trailStop=(currentProfit*pTrailPerc*0.01*ticksize/mysymbol.TickValue())*ponto;
               trailStop=trailStop/VolPosType(POSITION_TYPE_SELL);
               trailStop=MathRound(trailStop/ticksize)*ticksize;
               trailStopPrice=NormalizeDouble(ask+trailStop*ponto,mysymbol.Digits());
               if(trailStopPrice<currentStop)
                 {
                  mytrade.PositionModify(myposition.Ticket(),trailStopPrice,myposition.TakeProfit());
                  profitstart=true;
                 }
              }

           }
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool MyExpert::GetIndValue()
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
void MyExpert::CloseALL()
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
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

void MyExpert::ClosePosType(ENUM_POSITION_TYPE ptype)
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
void MyExpert::DeleteALL()
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
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
void MyExpert::DeleteAbertas(double distancia)
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
     {
      ulong o_ticket=OrderGetTicket(j);
      if(o_ticket!=0)
        {
         myorder.Select(o_ticket);
         if(myorder.Magic()==Magic_Number && myorder.Symbol()==mysymbol.Name() && MathAbs(myorder.PriceOpen()-ask)>distancia*ponto)
           {
            if(myorder.Type()==ORDER_TYPE_BUY_LIMIT || myorder.Type()==ORDER_TYPE_SELL_LIMIT)
               mytrade.OrderDelete(o_ticket);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyExpert::PriceLastStopOrder(const ENUM_ORDER_TYPE pending_order_type)
  {
   datetime last_time=0;
   double last_price=-1.0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==pending_order_type)
               if(myorder.TimeSetup()>last_time)
                 {
                  last_time=myorder.TimeSetup();
                  last_price=myorder.PriceOpen();
                 }
//---
   return(last_price);
  }
//+------------------------------------------------------------------+
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void MyExpert::DeleteOrders(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+
//| Ordens Abertas                                                    |
//+------------------------------------------------------------------+
bool MyExpert::OrdemAberta(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int MyExpert::TotalGains()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   datetime tm_start=iTime(original_symbol,PERIOD_D1,0);
   HistorySelect(tm_start,tm_end);
   int total_deals=HistoryDealsTotal();
   ulong ticket=0;
   int profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY) && mydeal.Profit()>0)
            profit+=1;
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyExpert::TotalEntradas()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   datetime tm_start=iTime(original_symbol,PERIOD_D1,0);
   HistorySelect(tm_start,tm_end);
   int total_deals=HistoryDealsTotal();
   ulong ticket=0;
   int profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_IN || mydeal.Entry()==DEAL_ENTRY_INOUT))
            profit+=1;
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyExpert::TotalEntradasSemana()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   datetime tm_start=(datetime)WeekStartTime(TimeCurrent());
   HistorySelect(tm_start,tm_end);
   int total_deals=HistoryDealsTotal();
   ulong ticket=0;
   int profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_IN || mydeal.Entry()==DEAL_ENTRY_INOUT))
            profit+=1;
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyExpert::TotalGainsSemana()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   datetime tm_start=(datetime)WeekStartTime(TimeCurrent());
   HistorySelect(tm_start,tm_end);
   int total_deals=HistoryDealsTotal();
   ulong ticket=0;
   int profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY) && mydeal.Profit()>0)
            profit+=1;
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyExpert::LossOrdensSemana()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   datetime tm_start=(datetime)WeekStartTime(TimeCurrent());
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
            if(mydeal.Profit()<0)
               profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyExpert::GainsOrdensSemana()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   datetime tm_start=(datetime)WeekStartTime(TimeCurrent());
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
            if(mydeal.Profit()>0)
               profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyExpert::LucroOrdensSemana()
  {
   static int total_deals=0;
   static int total_deals_prev=0;
   static double profit=0;
   ulong ticket=0;

//--- request trade history 
   datetime tm_end=TimeCurrent();
   datetime tm_start=(datetime)WeekStartTime(TimeCurrent());
   HistorySelect(tm_start,tm_end);
   total_deals=HistoryDealsTotal();
   if(total_deals==0)profit=0;
   if(total_deals>total_deals_prev)
     {
      profit=0;
      for(int i=0;i<total_deals;i++) // returns the number of current orders
        {
         ticket=HistoryDealGetTicket(i);
         mydeal.Ticket(ticket);
         if(ticket>0)
            if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
               profit+=mydeal.Profit();
        }
     }
   total_deals_prev=total_deals;
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MyExpert::LossOrdens()
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
            if(mydeal.Profit()<0)
               profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyExpert::GainsOrdens()
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
            if(mydeal.Profit()>0)
               profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyExpert::LucroOrdens()
  {
//--- request trade history 
   static int total_deals=0;
   static int total_deals_prev=0;
   static double profit=0;
   ulong ticket=0;
   datetime tm_end=TimeCurrent();
   MqlDateTime stm_end,time_aux;
   TimeToStruct(tm_end,stm_end);
   time_aux=stm_end;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);
   HistorySelect(tm_start,tm_end);
   total_deals=HistoryDealsTotal();
   if(total_deals==0)profit=0;
   if(total_deals>total_deals_prev)
     {
      profit=0;
      for(int i=0;i<total_deals;i++) // returns the number of current orders
        {
         ticket=HistoryDealGetTicket(i);
         mydeal.Ticket(ticket);
         if(ticket>0)
            if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
               profit+=mydeal.Profit();
        }
     }
   total_deals_prev=total_deals;

   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyExpert::LucroOrdensMes()
  {
//--- request trade history 
   static int total_deals=0;
   static int total_deals_prev=0;
   static double profit=0;
   ulong ticket=0;

   datetime tm_end=TimeCurrent();
   MqlDateTime stm_end,time_aux;
   TimeToStruct(tm_end,stm_end);
   time_aux=stm_end;
   time_aux.day=1;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);

   HistorySelect(tm_start,tm_end);
   total_deals=HistoryDealsTotal();
   if(total_deals==0)profit=0;
   if(total_deals>total_deals_prev)
     {
      profit=0;
      for(int i=0;i<total_deals;i++) // returns the number of current orders
        {
         ticket=HistoryDealGetTicket(i);
         mydeal.Ticket(ticket);
         if(ticket>0)
            if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
               profit+=mydeal.Profit();
        }
     }
   total_deals_prev=total_deals;

   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyExpert::LucroPositions()
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyExpert::PosicaoAberta()
  {
   if(myposition.SelectByMagic(original_symbol,Magic_Number)==true)
      return(myposition.PositionType()== POSITION_TYPE_BUY||myposition.PositionType()== POSITION_TYPE_SELL);
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

// Trailing stop (points)
void MyExpert::TrailingStopOrders(double pTrailPoints,double pMinProfit=0,double pStep=10)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number && pTrailPoints>0)
        {

         double currentTakeProfit=myposition.TakeProfit();
         long posType=myposition.PositionType();
         double currentStop;
         double openPrice=NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
         double point=mysymbol.Point();
         digits=mysymbol.Digits();
         if(pStep<10) pStep=10;
         double step=pStep*point;

         double minProfit = pMinProfit * point;
         double trailStop = pTrailPoints * point;
         currentTakeProfit=NormalizeDouble(currentTakeProfit,digits);
         double trailStopPrice;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            myorder.Select((ulong)gv.Get(stp_vd_tick));
            currentStop=myorder.PriceOpen();
            trailStopPrice = bid - trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=bid-openPrice;

            if(trailStopPrice>currentStop+step && currentProfit>=minProfit)
              {
               // mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
               if(myorder.Select((ulong)gv.Get(stp_vd_tick)))
                 {
                  mytrade.OrderModify((ulong)gv.Get(stp_vd_tick),trailStopPrice,0,0,order_time_type,0,0);
                 }
              }

           }
         else if(posType==POSITION_TYPE_SELL)
           {
            myorder.Select((ulong)gv.Get(stp_cp_tick));
            currentStop=myorder.PriceOpen();
            trailStopPrice = ask + trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=openPrice-ask;

            if((trailStopPrice<currentStop-step || currentStop==0) && currentProfit>=minProfit)
              {
               //mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
               if(myorder.Select((ulong)gv.Get(stp_cp_tick)))
                 {
                  mytrade.OrderModify((ulong)gv.Get(stp_cp_tick),trailStopPrice,0,0,order_time_type,0,0);
                 }

              }

           }
        }

     }
  }
//+------------------------------------------------------------------+

void MyExpert::Atual_vol_Stop_Take()
  {
   double vol_pos,vol_stp,preco_stp;
   if(Buy_opened())
     {
      if(myposition.SelectByTicket((ulong)gv.Get(cp_tick)) && myorder.Select((ulong)gv.Get(stp_vd_tick)))
        {
         // vol_pos=VolPosType(POSITION_TYPE_BUY);
         vol_pos=VolPosType(POSITION_TYPE_BUY)+VolumeOrdens(ORDER_TYPE_BUY_LIMIT);
         myorder.Select((ulong)gv.Get(stp_vd_tick));
         vol_stp=myorder.VolumeCurrent();
         preco_stp=myorder.PriceOpen();

         if(vol_pos!=vol_stp && vol_pos>0)
           {
            mytrade.OrderDelete((ulong)gv.Get(stp_vd_tick));
            mytrade.SellStop(vol_pos,preco_stp,Symbol(),0,0,order_time_type,0,"STOP"+exp_name);
            gv.Set(stp_vd_tick,(double)mytrade.ResultOrder());
           }
        }

      if(myposition.SelectByTicket((ulong)gv.Get(cp_tick)) && myorder.Select((ulong)gv.Get(tp_vd_tick)))
        {
         //            vol_pos=VolPosType(POSITION_TYPE_BUY);
         vol_pos=VolPosType(POSITION_TYPE_BUY)-VolumeOrdens(ORDER_TYPE_SELL_LIMIT)+VolumeOrdensCmt("TAKE PROFIT");
         myorder.Select((ulong)gv.Get(tp_vd_tick));
         vol_stp=myorder.VolumeCurrent();
         preco_stp=myorder.PriceOpen();

         if(vol_pos!=vol_stp && vol_pos>0)
           {
            mytrade.OrderDelete((ulong)gv.Get(tp_vd_tick));
            mytrade.SellLimit(vol_pos,preco_stp,original_symbol,0,0,order_time_type,0,"TAKE PROFIT");
            gv.Set(tp_vd_tick,(double)mytrade.ResultOrder());
           }
        }

     }
   if(Sell_opened())
     {
      if(myposition.SelectByTicket((ulong)gv.Get(vd_tick)) && myorder.Select((ulong)gv.Get(stp_cp_tick)))
        {
         //   vol_pos=VolPosType(POSITION_TYPE_SELL);
         vol_pos=VolPosType(POSITION_TYPE_SELL)+VolumeOrdens(ORDER_TYPE_SELL_LIMIT);
         myorder.Select((ulong)gv.Get(stp_cp_tick));
         vol_stp=myorder.VolumeCurrent();
         preco_stp=myorder.PriceOpen();

         if(vol_pos!=vol_stp && vol_pos>0)
           {
            mytrade.OrderDelete((ulong)gv.Get(stp_cp_tick));
            mytrade.BuyStop(vol_pos,preco_stp,Symbol(),0,0,order_time_type,0,"STOP"+exp_name);
            gv.Set(stp_cp_tick,(double)mytrade.ResultOrder());

           }
        }

      if(myposition.SelectByTicket((ulong)gv.Get(vd_tick)) && myorder.Select((ulong)gv.Get(tp_cp_tick)))
        {
         // vol_pos=VolPosType(POSITION_TYPE_SELL);
         vol_pos=VolPosType(POSITION_TYPE_SELL)-VolumeOrdens(ORDER_TYPE_BUY_LIMIT)+VolumeOrdensCmt("TAKE PROFIT");
         myorder.Select((ulong)gv.Get(tp_cp_tick));
         vol_stp=myorder.VolumeCurrent();
         preco_stp=myorder.PriceOpen();

         if(vol_pos!=vol_stp && vol_pos>0)
           {
            mytrade.OrderDelete((ulong)gv.Get(tp_cp_tick));
            mytrade.BuyLimit(vol_pos,preco_stp,original_symbol,0,0,order_time_type,0,"TAKE PROFIT");
            gv.Set(tp_cp_tick,(double)mytrade.ResultOrder());

           }
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyExpert::VolPosType(ENUM_POSITION_TYPE ptype)
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
/*
void MyExpert::Entr_Parcial_Buy(const double preco)
  {
   if(Lot_entry1>0) mytrade.BuyLimit(Lot_entry1,NormalizeDouble(preco-pts_entry1*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 1");
   if(Lot_entry2>0) mytrade.BuyLimit(Lot_entry2,NormalizeDouble(preco-pts_entry2*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 2");
   if(Lot_entry3>0) mytrade.BuyLimit(Lot_entry3,NormalizeDouble(preco-pts_entry3*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 3");
   if(Lot_entry4>0) mytrade.BuyLimit(Lot_entry4,NormalizeDouble(preco-pts_entry4*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 4");
   if(Lot_entry5>0) mytrade.BuyLimit(Lot_entry5,NormalizeDouble(preco-pts_entry5*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 5");
   if(Lot_entry6>0) mytrade.BuyLimit(Lot_entry6,NormalizeDouble(preco-pts_entry6*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 6");
  }
//+------------------------------------------------------------------+
void MyExpert::Entr_Parcial_Sell(const double preco)
  {
   if(Lot_entry1>0) mytrade.SellLimit(Lot_entry1,NormalizeDouble(preco+pts_entry1*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 1");
   if(Lot_entry2>0) mytrade.SellLimit(Lot_entry2,NormalizeDouble(preco+pts_entry2*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 2");
   if(Lot_entry3>0) mytrade.SellLimit(Lot_entry3,NormalizeDouble(preco+pts_entry3*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 3");
   if(Lot_entry4>0) mytrade.SellLimit(Lot_entry4,NormalizeDouble(preco+pts_entry4*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 4");
   if(Lot_entry5>0) mytrade.SellLimit(Lot_entry5,NormalizeDouble(preco+pts_entry5*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 5");
   if(Lot_entry6>0) mytrade.SellLimit(Lot_entry6,NormalizeDouble(preco+pts_entry6*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 6");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyExpert::Entr_Favor_Buy(const double preco)
  {

   if(Lot_entry1_fv>0) mytrade.BuyStop(Lot_entry1_fv,NormalizeDouble(preco+pts_entry1_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 1");
   if(Lot_entry2_fv>0) mytrade.BuyStop(Lot_entry2_fv,NormalizeDouble(preco+pts_entry2_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 2");
   if(Lot_entry3_fv>0) mytrade.BuyStop(Lot_entry3_fv,NormalizeDouble(preco+pts_entry3_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 3");
   if(Lot_entry4_fv>0) mytrade.BuyStop(Lot_entry4_fv,NormalizeDouble(preco+pts_entry4_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 4");
  }
//+------------------------------------------------------------------+
void MyExpert::Entr_Favor_Sell(const double preco)
  {
   if(Lot_entry1_fv>0) mytrade.SellStop(Lot_entry1_fv,NormalizeDouble(preco-pts_entry1_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 1");
   if(Lot_entry2_fv>0) mytrade.SellStop(Lot_entry2_fv,NormalizeDouble(preco-pts_entry2_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 2");
   if(Lot_entry3_fv>0) mytrade.SellStop(Lot_entry3_fv,NormalizeDouble(preco-pts_entry3_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 3");
   if(Lot_entry4_fv>0) mytrade.SellStop(Lot_entry4_fv,NormalizeDouble(preco-pts_entry4_fv*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Favor 4");
  }
//+------------------------------------------------------------------+
*/
void MyExpert::DeleteOrdersExEntry()
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(StringFind(myorder.Comment(),"BUY")<0 && StringFind(myorder.Comment(),"SELL")<0)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyExpert::DeleteOrdersComment(const string comm)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.Comment()==comm)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+
void MyExpert::CloseByPosition()
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
ulong MyExpert::TickecBuyPos()
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
ulong MyExpert::TickecSellPos()
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

double MyExpert::PrecoMedio(ENUM_POSITION_TYPE ptype)
  {
   double vol=0;
   double preco=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && myposition.Symbol()==mysymbol.Name())
        {
         vol+=myposition.Volume();
         preco+=myposition.Volume()*myposition.PriceOpen();
        }
     }
   if(VolPosType(ptype)>0)preco=preco/VolPosType(ptype);
   preco=NormalizeDouble(MathRound(preco/ticksize)*ticksize,digits);
   return preco;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Break even stop                                                  |
//+------------------------------------------------------------------+
//Break Even

void MyExpert::BreakEvenOrders(string pSymbol,bool usarbreak,double &pBreakEven[],double &pLockProfit[])
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && usarbreak==true)
        {

         long posType=myposition.PositionType();
         ulong posTicket=myposition.Ticket();
         double currentSL;
         double openPrice= NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
         double currentTP=myposition.TakeProfit();
         double breakEvenStop;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            myorder.Select((ulong)gv.Get(stp_vd_tick));
            currentSL=myorder.PriceOpen();
            bid=SymbolInfoDouble(pSymbol,SYMBOL_BID);
            currentProfit=bid-openPrice;
            //Break Even 0 a 3
            for(int k=0;k<4;k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop=openPrice+pLockProfit[k]*ponto;
                  breakEvenStop=MathRound(breakEvenStop/ticksize)*ticksize;
                  if(currentSL<breakEvenStop || currentSL==0)
                    {
                     Print("Break even stop:");
                     //   mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                     mytrade.OrderModify((ulong)gv.Get(stp_vd_tick),breakEvenStop,0,0,order_time_type,0,0);

                    }
                 }
              }
            //----------------------
            //Break Even 4
            if(currentProfit>=pBreakEven[4]*ponto)
              {
               breakEvenStop=openPrice+pLockProfit[4]*ponto;
               breakEvenStop=MathRound(breakEvenStop/ticksize)*ticksize;
               if(currentSL<breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop:");
                  // mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                  mytrade.OrderModify((ulong)gv.Get(stp_vd_tick),breakEvenStop,0,0,order_time_type,0,0);

                 }
              }
           }
         //----------------------

         //----------------------

         if(posType==POSITION_TYPE_SELL)
           {
            myorder.Select((ulong)gv.Get(stp_cp_tick));
            currentSL=myorder.PriceOpen();
            ask=SymbolInfoDouble(pSymbol,SYMBOL_ASK);
            currentProfit=openPrice-ask;
            //Break Even 0 a 3
            for(int k=0;k<4;k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop=openPrice-pLockProfit[k]*ponto;
                  breakEvenStop=MathRound(breakEvenStop/ticksize)*ticksize;
                  if(currentSL>breakEvenStop || currentSL==0)
                    {
                     Print("Break even stop:");
                     //mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                     mytrade.OrderModify((ulong)gv.Get(stp_cp_tick),breakEvenStop,0,0,order_time_type,0,0);

                    }
                 }
              }
            //----------------------
            //Break Even 4
            if(currentProfit>=pBreakEven[4]*ponto)
              {
               breakEvenStop=openPrice-pLockProfit[4]*ponto;
               breakEvenStop=MathRound(breakEvenStop/ticksize)*ticksize;
               if(currentSL>breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop:");
                  //mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                  mytrade.OrderModify((ulong)gv.Get(stp_cp_tick),breakEvenStop,0,0,order_time_type,0,0);

                 }

              }
            //----------------------

           }

        } //Fim Position Select

     }//Fim for
  }
//+------------------------------------------------------------------+
long MyExpert::WeekStartTime(datetime aTime,bool aStartsOnMonday=false)
  {
   long tmp=aTime;
   long Corrector;
   if(aStartsOnMonday)
     {
      Corrector=259200; // duration of three days (86400*3)
     }
   else
     {
      Corrector=345600; // duration of four days (86400*4)
     }
   tmp+=Corrector;
   tmp=(tmp/604800)*604800;
   tmp-=Corrector;
   return(tmp);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyExpert::OrdemAbertaComent(const string cmt)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.Comment()==cmt)
               return true;
   return false;
  }
//+------------------------------------------------------------------+
void MyExpert::DeleteOrdersLimit(const ENUM_ORDER_TYPE order_type,double price)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
     {
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
        {
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number && myorder.OrderType()==order_type)
           {
            if(myorder.OrderType()==ORDER_TYPE_BUY_LIMIT && myorder.PriceOpen()<=price)
               mytrade.OrderDelete(myorder.Ticket());
            if(myorder.OrderType()==ORDER_TYPE_SELL_LIMIT && myorder.PriceOpen()>=price)
               mytrade.OrderDelete(myorder.Ticket());
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
double MyExpert::VolumeOrdens(const ENUM_ORDER_TYPE order_type)
  {
   double volume=0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               volume+=myorder.VolumeCurrent();
   return volume;
  }
//+------------------------------------------------------------------+
double MyExpert::VolumeOrdensCmt(const string cmt)
  {
   double volume=0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.Comment()==cmt)
               volume+=myorder.VolumeCurrent();
   return volume;
  }
//+------------------------------------------------------------------+
/*
bool MyExpert::TimeDayFilter()
  {
   bool filter;
   MqlDateTime Today;
   TimeToStruct(TimeCurrent(),Today);
   switch(Today.day_of_week)
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

     }
   return filter;
  }
*/
//+------------------------------------------------------------------+

void MyExpert::BreakEven(string pSymbol,bool usarbreak,double &pBreakEven[],double &pLockProfit[])
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && usarbreak==true)
        {

         long posType=myposition.PositionType();
         ulong posTicket=myposition.Ticket();
         double currentSL=myposition.StopLoss();
         //double openPrice= NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
         double openPrice;
         double currentTP=myposition.TakeProfit();
         double breakEvenStop;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            openPrice=PrecoMedio(POSITION_TYPE_BUY);
            bid=SymbolInfoDouble(pSymbol,SYMBOL_BID);
            currentProfit=bid-openPrice;
            //Break Even 0 a 3
            for(int k=0;k<4;k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop=openPrice+pLockProfit[k]*ponto;
                  breakEvenStop=MathRound(breakEvenStop/ticksize)*ticksize;
                  if(currentSL<breakEvenStop || currentSL==0)
                    {
                     Print("Break even stop:");
                     mytrade.PositionModify(posTicket,breakEvenStop,currentTP);

                    }
                 }
              }
            //----------------------
            //Break Even 4
            if(currentProfit>=pBreakEven[4]*ponto)
              {
               breakEvenStop=openPrice+pLockProfit[4]*ponto;
               breakEvenStop=MathRound(breakEvenStop/ticksize)*ticksize;
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
            openPrice=PrecoMedio(POSITION_TYPE_SELL);
            ask=SymbolInfoDouble(pSymbol,SYMBOL_ASK);
            currentProfit=openPrice-ask;
            //Break Even 0 a 3
            for(int k=0;k<4;k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop=openPrice-pLockProfit[k]*ponto;
                  breakEvenStop=MathRound(breakEvenStop/ticksize)*ticksize;
                  if(currentSL>breakEvenStop || currentSL==0)
                    {
                     Print("Break even stop:");
                     mytrade.PositionModify(posTicket,breakEvenStop,currentTP);

                    }
                 }
              }
            //----------------------
            //Break Even 4
            if(currentProfit>=pBreakEven[4]*ponto)
              {
               breakEvenStop=openPrice-pLockProfit[4]*ponto;
               breakEvenStop=MathRound(breakEvenStop/ticksize)*ticksize;
               if(currentSL>breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop:");
                  mytrade.PositionModify(posTicket,breakEvenStop,currentTP);

                 }

              }
            //----------------------

           }

        } //Fim Position Select

     }//Fim for
  }
//+------------------------------------------------------------------+

double MyExpert::NormalizaPreco(double preco)
  {
   double _tick=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   return NormalizeDouble(MathRound(preco/_tick)*_tick,digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyExpert::BreakEven(string pSymbol,bool usarbreak,double &pBreakEven[],double &pLockProfit[],OpcoesDistancia opt=DistPontos,double tam_barra=1)
  {
   if(!usarbreak) return;
   double _Ponto=ponto;
   if(opt==DistForex)_Ponto=10*ponto;
   if(opt==DistBarra)_Ponto=tam_barra*ponto;

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && usarbreak==true)
        {

         long posType=myposition.PositionType();
         ulong posTicket=myposition.Ticket();
         double currentSL=myposition.StopLoss();
         //double openPrice= NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
         double openPrice;
         double currentTP=myposition.TakeProfit();
         double breakEvenStop;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            openPrice=PrecoMedio(POSITION_TYPE_BUY);
            bid=SymbolInfoDouble(pSymbol,SYMBOL_BID);
            currentProfit=bid-openPrice;
            //Break Even 0 a 3
            for(int k=0;k<4;k++)
              {
               if(currentProfit>=pBreakEven[k]*_Ponto && currentProfit<pBreakEven[k+1]*_Ponto)
                 {
                  breakEvenStop=openPrice+pLockProfit[k]*_Ponto;
                  breakEvenStop=NormalizaPreco(breakEvenStop);
                  if(currentSL<breakEvenStop || currentSL==0)
                    {
                     Print("Break even stop:");
                     mytrade.PositionModify(posTicket,breakEvenStop,currentTP);

                    }
                 }
              }
            //----------------------
            //Break Even 4
            if(currentProfit>=pBreakEven[4]*_Ponto)
              {
               breakEvenStop=openPrice+pLockProfit[4]*_Ponto;
               breakEvenStop=NormalizaPreco(breakEvenStop);
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
            openPrice=PrecoMedio(POSITION_TYPE_SELL);
            ask=SymbolInfoDouble(pSymbol,SYMBOL_ASK);
            currentProfit=openPrice-ask;
            //Break Even 0 a 3
            for(int k=0;k<4;k++)
              {
               if(currentProfit>=pBreakEven[k]*_Ponto && currentProfit<pBreakEven[k+1]*_Ponto)
                 {
                  breakEvenStop=openPrice-pLockProfit[k]*_Ponto;
                  breakEvenStop=NormalizaPreco(breakEvenStop);
                  if(currentSL>breakEvenStop || currentSL==0)
                    {
                     Print("Break even stop:");
                     mytrade.PositionModify(posTicket,breakEvenStop,currentTP);

                    }
                 }
              }
            //----------------------
            //Break Even 4
            if(currentProfit>=pBreakEven[4]*_Ponto)
              {
               breakEvenStop=openPrice-pLockProfit[4]*_Ponto;
               breakEvenStop=NormalizaPreco(breakEvenStop);
               if(currentSL>breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop:");
                  mytrade.PositionModify(posTicket,breakEvenStop,currentTP);

                 }

              }
            //----------------------

           }

        } //Fim Position Select

     }//Fim for
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyExpert::Trailing_Candle(double dist)
  {

   double stop_movel=dist*ponto;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
        {
         if(myposition.PositionType()==POSITION_TYPE_BUY)
           {
            double curSTP=myposition.StopLoss();
            double curTake=myposition.TakeProfit();
            double stp_compra=NormalizeDouble(low[1]-stop_movel,digits);
            if(stp_compra>curSTP)mytrade.PositionModify(myposition.Ticket(),stp_compra,curTake);
           }

         if(myposition.PositionType()==POSITION_TYPE_SELL)
           {
            double curSTP=myposition.StopLoss();
            double curTake=myposition.TakeProfit();
            double stp_venda=NormalizeDouble(high[1]+stop_movel,digits);
            if(stp_venda<curSTP)mytrade.PositionModify(myposition.Ticket(),stp_venda,curTake);
           }
        }//Fim if PositionSelect

     }//Fim for

  }      //Fim Stop Candle      
//+------------------------------------------------------------------+

double MyExpert::StopLoss()
  {
   double _sl=0;
   if(PosicaoAberta())_sl=gv.Get("sl_position");
   return _sl;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyExpert::TakeProfit()
  {
   double _tp=0;
   if(PosicaoAberta())
      _tp=PrecoOrdAbCmt("TAKE PROFIT");
   return _tp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyExpert::PrecoOrdAbCmt(const string cmt)
  {
   double preco=0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.Comment()==cmt)
               preco=myorder.PriceOpen();
   return preco;
  }
//+------------------------------------------------------------------+
