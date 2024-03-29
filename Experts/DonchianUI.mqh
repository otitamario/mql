//+------------------------------------------------------------------+
//|                                                      Program.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <EasyAndFastGUI\WndEvents.mqh>
//+------------------------------------------------------------------+
//| Class for creating an application                                |
//+------------------------------------------------------------------+
class CDonchianUI : public CWndEvents
  {
public:
   //--- Form 1
   CWindow           m_window;
   CCanvasTable      m_canvas_table;
   //--- Status bar
   CStatusBar        m_status_bar;
   //--- Label
   CTextLabel        m_label1;
   CTextLabel        m_label2;
   CTextLabel        m_label3;
   //---
                     CDonchianUI(void);
                    ~CDonchianUI(void);
   //--- Initialization/deinitialization
   void              OnInitEvent(void);
   void              OnDeinitEvent(const int reason);
   //--- Timer
   void              OnTimerEvent(void);
   //---
protected:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //---
public:
   //--- Form 
   bool              CreateMainPanel(const string caption_text);
   bool              CreateCheckBox(string text,int x_gap,int y_gap);
   //--- Status bar
   bool              CreateStatusBar(const int x_gap,const int y_gap);
   //--- Заголовок
   bool              CreateLabel1(const string caption_text);
   bool              CreateLabel2(const string caption_text);
   bool              CreateLabel3(const string caption_text);

   bool              CreateCanvasTable(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CDonchianUI::CDonchianUI(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CDonchianUI::~CDonchianUI(void)
  {
  }
//+------------------------------------------------------------------+
//| Initialization                                                    |
//+------------------------------------------------------------------+
void CDonchianUI::OnInitEvent(void)
  {
  }
//+------------------------------------------------------------------+
//| Deinitialization                                                  |
//+------------------------------------------------------------------+
void CDonchianUI::OnDeinitEvent(const int reason)
  {
//--- Removing the interface
   CWndEvents::Destroy();
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CDonchianUI::OnTimerEvent(void)
  {
   CWndEvents::OnTimerEvent();
//--- Updating the second item of the status bar every 500 milliseconds
   static int count=0;
   if(count<500)
     {
      count+=TIMER_STEP_MSC;
      return;
     }
//--- Zero the counter
   count=0;
//--- Change the value in the second item of the status bar
   m_status_bar.ValueToItem(1,TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS));
//--- Redraw the chart
   m_chart.Redraw();
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CDonchianUI::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Clicking on the menu item event
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_CONTEXTMENU_ITEM)
     {
      ::Print(__FUNCTION__," > id: ",id,"; lparam: ",lparam,"; dparam: ",dparam,"; sparam: ",sparam);
     }
//--- Event of pressing on the list view item or table
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_LIST_ITEM)
     {
      ::Print(__FUNCTION__," > id: ",id,"; lparam: ",lparam,"; dparam: ",dparam,"; sparam: ",sparam);
     }
  }
//+------------------------------------------------------------------+
//| Создаёт форму   для элементов управления                         |
//+------------------------------------------------------------------+
bool CDonchianUI::CreateMainPanel(const string caption_text)
  {
//--- Add a window pointer to the window array
   CWndContainer::AddWindow(m_window);

//--- Coordinates
   int x=(m_window.X()>0) ? m_window.X() : 80;
   int y=(m_window.Y()>0) ? m_window.Y() : 40;
//--- Properties
   m_window.XSize(400);
   m_window.YSize(300);
   m_window.UseRollButton();
   m_window.Movable(true);
   m_window.CaptionTextColor(clrWhite);
   m_window.CaptionBgColor(C'74,118,184');
   m_window.CaptionHeight(22);
//m_window.WindowBorderColor(C'237,189,55');

//--- Creating a form
   if(!m_window.CreateWindow(m_chart_id,m_subwin,caption_text,x,y))
      return(false);
   CreateCanvasTable();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the status bar                                           |
//+------------------------------------------------------------------+
bool CDonchianUI::CreateStatusBar(const int x_gap,const int y_gap)
  {
#define STATUS_LABELS_TOTAL 1
//--- Store the window pointer
   m_status_bar.WindowPointer(m_window);
//--- Width
   int width[]={0,110};
//--- Set properties before creation
   m_status_bar.YSize(24);
   m_status_bar.AutoXResizeMode(true);
   m_status_bar.AutoXResizeRightOffset(1);
   m_status_bar.AnchorBottomWindowSide(true);
//--- Specify the number of parts and set their properties
   for(int i=0; i<STATUS_LABELS_TOTAL; i++)
      m_status_bar.AddItem(width[i]);
//--- Create control
   if(!m_status_bar.CreateStatusBar(m_chart_id,m_subwin,x_gap,y_gap))
      return(false);
//--- Set text in the first item of the status bar
   m_status_bar.ValueToItem(0,"Loading...");
//--- Add the element pointer to the base
   CWndContainer::AddToElementsArray(0,m_status_bar);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDonchianUI::CreateLabel1(const string caption_text)
  {
//--- Store the window pointer
   m_label1.WindowPointer(m_window);
//--- Coordinates
   int x=30;
   int y=30;
   m_label1.FontSize(10);

//--- Create control
   if(!m_label1.CreateTextLabel(m_chart_id,m_subwin,caption_text,x,y))
      return(false);
//--- Add the object to the common array of the object groups
   CWndContainer::AddToElementsArray(0,m_label1);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDonchianUI::CreateLabel2(const string caption_text)
  {
//--- Store the window pointer
   m_label2.WindowPointer(m_window);
//--- Coordinates
   int x=30;
   int y=50;
   m_label2.FontSize(10);

//--- Create control
   if(!m_label2.CreateTextLabel(m_chart_id,m_subwin,caption_text,x,y))
      return(false);
//--- Add the object to the common array of the object groups
   CWndContainer::AddToElementsArray(0,m_label2);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDonchianUI::CreateLabel3(const string caption_text)
  {
//--- Store the window pointer
   m_label3.WindowPointer(m_window);
//--- Coordinates
   int x=30;
   int y=70;
   m_label3.FontSize(10);
//--- Create control
   if(!m_label3.CreateTextLabel(m_chart_id,m_subwin,caption_text,x,y))
      return(false);
//--- Add the object to the common array of the object groups
   CWndContainer::AddToElementsArray(0,m_label3);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a rendered table                                          |
//+------------------------------------------------------------------+
bool CDonchianUI::CreateCanvasTable(void)
  {
#define COLUMNS1_TOTAL 2
#define ROWS1_TOTAL    7
//--- Store pointer to the form
   m_canvas_table.WindowPointer(m_window);
//--- Coordinates
   int x=0;
   int y=22;
//--- The number of visible rows
   int visible_rows_total=5;
//--- Array of column widths
   int width[COLUMNS1_TOTAL];
   ::ArrayInitialize(width,70);
   width[0]=149;
   width[1]=250;
//--- Array of text alignment in columns
   ENUM_ALIGN_MODE align[COLUMNS1_TOTAL];
   ::ArrayInitialize(align,ALIGN_CENTER);
   align[0]=ALIGN_LEFT;
//--- Set properties before creation
   m_canvas_table.XSize(399);
   m_canvas_table.TableSize(COLUMNS1_TOTAL,ROWS1_TOTAL);
   m_canvas_table.TextAlign(align);
   m_canvas_table.ColumnsWidth(width);
   m_canvas_table.GridColor(clrLightGray);
   m_canvas_table.FontSize(10);
//--- Create control
   if(!m_canvas_table.CreateTable(m_chart_id,m_subwin,x,y))
      return(false);
//--- Add the object to the common array of the object groups
   CWndContainer::AddToElementsArray(0,m_canvas_table);
   return(true);
  }
//+------------------------------------------------------------------+
