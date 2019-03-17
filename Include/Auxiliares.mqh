//+------------------------------------------------------------------+
//|                                                   Auxiliares.mqh |
//|                        Copyright 2017,  Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check for New Bar                                                |
//+------------------------------------------------------------------+
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
#include <Controls\ComboBox.mqh> 
#include <Controls\Edit.mqh>
#include <Controls\RadioGroup.mqh> 
#include <Controls\Picture.mqh>
#include <Controls\ListView.mqh>
#include <Controls\Rect.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>

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
     }

   return(newBar);
  }

//------------------------------------------------------------------------

//------------------------------------------------------------------------

//------------------------------------------------------------------------
// Timer
#define TIME_ADD_MINUTE 60
#define TIME_ADD_HOUR 3600
#define TIME_ADD_DAY	86400
#define TIME_ADD_WEEK 604800
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTimer
  {
private:
   bool              TimerStarted;
   datetime          StartTime,EndTime;
   void              PrintTimerMessage(bool pTimerOn);

public:
   bool              CheckTimer(datetime pStartTime,datetime pEndTime,bool pLocalTime=false);
   bool              DailyTimer(int pStartHour,int pStartMinute,int pEndHour,int pEndMinute,bool pLocalTime=false);

  };
// Daily timer
bool CTimer::DailyTimer(int pStartHour,int pStartMinute,int pEndHour,int pEndMinute,bool pLocalTime=false)
  {
   datetime currentTime;
   if(pLocalTime==true) currentTime=TimeLocal();
   else currentTime=TimeCurrent();

   StartTime=CreateDateTime(pStartHour,pStartMinute);
   EndTime=CreateDateTime(pEndHour,pEndMinute);

   if(EndTime<=StartTime)
     {
      StartTime-=TIME_ADD_DAY;

      if(currentTime>EndTime)
        {
         StartTime+=TIME_ADD_DAY;
         EndTime+=TIME_ADD_DAY;
        }
     }

   bool timerOn=CheckTimer(StartTime,EndTime,pLocalTime);
//PrintTimerMessage(timerOn);

   return(timerOn);
  }
// Check timer
bool CTimer::CheckTimer(datetime pStartTime,datetime pEndTime,bool pLocalTime=false)
  {
   if(pStartTime>=pEndTime)
     {
      Alert("Error: Invalid start or end time");
      return(false);
     }

   datetime currentTime;
   if(pLocalTime==true) currentTime=TimeLocal();
   else currentTime=TimeCurrent();

   bool timerOn=false;
   if(currentTime>=pStartTime && currentTime<pEndTime)
     {
      timerOn=true;
     }

   return(timerOn);
  }
//---------------------
// Print a message to the screen
void CTimer::PrintTimerMessage(bool pTimerOn)
  {
   if(pTimerOn==true && TimerStarted==false)
     {
      string message="Timer started";
      Print(message);
      Comment(message);
      TimerStarted=true;
     }
   else if(pTimerOn==false && TimerStarted==true)
     {
      string message="Timer stopped";
      Print(message);
      Comment(message);
      TimerStarted=false;
     }
  }
// Create datetime value
datetime CreateDateTime(int pHour=0,int pMinute=0)
  {
   MqlDateTime timeStruct;
   TimeToStruct(TimeCurrent(),timeStruct);

   timeStruct.hour= pHour;
   timeStruct.min = pMinute;

   datetime useTime=StructToTime(timeStruct);

   return(useTime);
  }
//------------------------------------------------
//------------------------------------------------
//------------------------------------------------
class CisNewBar
  {
protected:
   datetime          m_lastbar_time;   // Time of opening last bar

   string            m_symbol;         // Symbol name
   ENUM_TIMEFRAMES   m_period;         // Chart period

   uint              m_retcode;        // Result code of detecting new bar 
   int               m_new_bars;       // Number of new bars
   string            m_comment;        // Comment of execution

public:
   void              CisNewBar();      // CisNewBar constructor      
   //--- Methods of access to protected data:
   uint              GetRetCode() const      {return(m_retcode);     }  // Result code of detecting new bar 
   datetime          GetLastBarTime() const  {return(m_lastbar_time);}  // Time of opening new bar
   int               GetNewBars() const      {return(m_new_bars);    }  // Number of new bars
   string            GetComment() const      {return(m_comment);     }  // Comment of execution
   string            GetSymbol() const       {return(m_symbol);      }  // Symbol name
   ENUM_TIMEFRAMES   GetPeriod() const       {return(m_period);      }  // Chart period
   //--- Methods of initializing protected data:
   void              SetLastBarTime(datetime lastbar_time){m_lastbar_time=lastbar_time;                            }
   void              SetSymbol(string symbol)             {m_symbol=(symbol==NULL || symbol=="")?Symbol():symbol;  }
   void              SetPeriod(ENUM_TIMEFRAMES period)    {m_period=(period==PERIOD_CURRENT)?Period():period;      }
   //--- Methods of detecting new bars:
   bool              isNewBar(datetime new_Time);                       // First type of request for new bar
   int               isNewBar();                                        // Second type of request for new bar 
  };
//+------------------------------------------------------------------+
//| CisNewBar constructor.                                           |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CisNewBar::CisNewBar()
  {
   m_retcode=0;         // Result code of detecting new bar 
   m_lastbar_time=0;    // Time of opening last bar
   m_new_bars=0;        // Number of new bars
   m_comment="";        // Comment of execution
   m_symbol=Symbol();   // Symbol name, by default - symbol of current chart
   m_period=Period();   // Chart period, by default - period of current chart    
  }
//+------------------------------------------------------------------+
//| First type of request for new bar                     |
//| INPUT:  newbar_time - time of opening (hypothetically) new bar|
//| OUTPUT: true   - if new bar(s) has(ve) appeared                  |
//|         false  - if there is no new bar or in case of error      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CisNewBar::isNewBar(datetime newbar_time)
  {
//--- Initialization of protected variables
   m_new_bars = 0;      // Number of new bars
   m_retcode  = 0;      // Result code of detecting new bar: 0 - no error
   m_comment  =__FUNCTION__+" Successful check for new bar";
//---

//--- Just to be sure, check: is the time of (hypothetically) new bar m_newbar_time less than time of last bar m_lastbar_time? 
   if(m_lastbar_time>newbar_time)
     { // If new bar is older than last bar, print error message
      m_comment=__FUNCTION__+" Synchronization error: time of previous bar "+TimeToString(m_lastbar_time)+
                ", time of new bar request "+TimeToString(newbar_time);
      m_retcode=-1;     // Result code of detecting new bar: return -1 - synchronization error
      return(false);
     }
//---

//--- if it's the first call 
   if(m_lastbar_time==0)
     {
      m_lastbar_time=newbar_time; //--- set time of last bar and exit
                                  //  m_comment=__FUNCTION__+" Initialization of lastbar_time = "+TimeToString(m_lastbar_time);
      return(false);
     }
//---

//--- Check for new bar: 
   if(m_lastbar_time<newbar_time)
     {
      m_new_bars=1;               // Number of new bars
      m_lastbar_time=newbar_time; // remember time of last bar
      return(true);
     }
//---

//--- if we've reached this line, then the bar is not new; return false
   return(false);
  }
//+------------------------------------------------------------------+
//| Second type of request for new bar                     |
//| INPUT:  no.                                                      |
//| OUTPUT: m_new_bars - Number of new bars                          |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
int CisNewBar::isNewBar()
  {
   datetime newbar_time;
   datetime lastbar_time=m_lastbar_time;

//--- Request time of opening last bar:
   ResetLastError(); // Set value of predefined variable _LastError as 0.
   if(!SeriesInfoInteger(m_symbol,m_period,SERIES_LASTBAR_DATE,newbar_time))
     { // If request has failed, print error message:
      m_retcode=GetLastError();  // Result code of detecting new bar: write value of variable _LastError
      m_comment=__FUNCTION__+" Error when getting time of last bar opening: "+IntegerToString(m_retcode);
      return(0);
     }
//---

//---Next use first type of request for new bar, to complete analysis:
   if(!isNewBar(newbar_time)) return(0);

//---Correct number of new bars:
   m_new_bars=Bars(m_symbol,m_period,lastbar_time,newbar_time)-1;

//--- If we've reached this line - then there is(are) new bar(s), return their number:
   return(m_new_bars);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
//| Class CControlsDialog                                            | 
//| Usage: main dialog of the Controls application                   | 
//+------------------------------------------------------------------+ 
class CControlsDialog : public CAppDialog
  {

protected:
   CPositionInfo     m_position;                      // trade position object
   CTrade            m_trade;                         // trading object
   CAccountInfo      m_account;                       // account info wrapper

                                                      //private:
   //  CLabel            m_label[500];

public:
                     CControlsDialog(void);
                    ~CControlsDialog(void);
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
CControlsDialog::CControlsDialog(void)
  {
  }
//+------------------------------------------------------------------+ 
//| Destructor                                                       | 
//+------------------------------------------------------------------+ 
CControlsDialog::~CControlsDialog(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::CreateLabel(const long chart,const int subwindow,CLabel &object,const string text,const uint x1,const uint y1,const uint x2,const uint y2)
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
bool CControlsDialog::CreateEdit(const long chart,const int subwindow,CEdit &object,const uint x1,const uint y1,const uint x2,const uint y2)
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
bool CControlsDialog::CreateButton(const long chart,const int subwindow,CButton &object,const string text,const uint x1,const uint y1,const uint x2,const uint y2)
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
bool CControlsDialog::CreatePicture(const long chart,const int subwindow,CPicture &object,const uint x1,const uint y1,const uint x2,const uint y2,string path)
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

bool CControlsDialog::CreatePanel(const long chart,const int subwindow,CPanel &object,const uint x1,const uint y1,const uint x2,const uint y2)
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
bool CControlsDialog::CreateComboBox(const long chart,const string name,const int subwindow,CComboBox &object,const uint x1,const uint y1,const uint x2,const uint y2)

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
bool CControlsDialog::CreateRadioGroup(const long chart,const string name,const int subwindow,CRadioGroup &object,const uint x1,const uint y1,const uint x2,const uint y2)
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
bool CControlsDialog::CreateListView(const long chart,const string name,const int subwindow,CListView &object,const uint x1,const uint y1,const uint x2,const uint y2)

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
