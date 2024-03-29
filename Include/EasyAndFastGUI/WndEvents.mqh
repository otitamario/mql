//+------------------------------------------------------------------+
//|                                                    WndEvents.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Defines.mqh"
#include "WndContainer.mqh"
//+------------------------------------------------------------------+
//| Class for event handling                                         |
//+------------------------------------------------------------------+
class CWndEvents : public CWndContainer
  {
protected:
   //--- Class instance for managing the chart
   CChart            m_chart;
   //--- Identifier and window number of the chart
   long              m_chart_id;
   int               m_subwin;
   //--- Program name
   string            m_program_name;
   //--- Short name of the indicator
   string            m_indicator_shortname;
   //--- Index of the active window
   int               m_active_window_index;
   //--- Handle of the expert subwindow
   int               m_subwindow_handle;
   //--- Name of the expert subwindow
   string            m_subwindow_shortname;
   //--- The number of subwindows on the chart after setting the expert subwindow
   int               m_subwindows_total;
   //---
private:
   //--- Event parameters
   int               m_id;
   long              m_lparam;
   double            m_dparam;
   string            m_sparam;
   //---
protected:
                     CWndEvents(void);
                    ~CWndEvents(void);
   //--- Virtual chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {}
   //--- Timer
   void              OnTimerEvent(void);
   //---
public:
   //--- Event handlers of the chart
   void              ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //---
private:
   void              ChartEventCustom(void);
   void              ChartEventClick(void);
   void              ChartEventMouseMove(void);
   void              ChartEventObjectClick(void);
   void              ChartEventEndEdit(void);
   void              ChartEventChartChange(void);
   //--- Checking events in controls
   void              CheckElementsEvents(void);

   //--- Identifying the sub-window number
   void              DetermineSubwindow(void);
   //--- Delete the expert subwindow
   void              DeleteExpertSubwindow(void);
   //--- Check and update the expert subwindow number
   void              CheckExpertSubwindowNumber(void);
   //--- Check and update the indicator subwindow number
   void              CheckSubwindowNumber(void);
   //--- Resize the locked main form
   void              ResizeLockedWindow(void);

   //--- Initialization of event parameters
   void              InitChartEventsParams(const int id,const long lparam,const double dparam,const string sparam);
   //--- Moving the window
   void              MovingWindow(const bool moving_mode=false);
   //--- Checking events of all controls by timer
   void              CheckElementsEventsTimer(void);
   //--- Setting the state of the chart
   void              SetChartState(void);
   //---
protected:
   //--- Redraw the window
   void              ResetWindow(void);
   //--- Removing the interface
   void              Destroy(void);
   //---
private:
   //--- Minimizing/maximizing the form
   bool              OnWindowRollUp(void);
   bool              OnWindowUnroll(void);
   //--- Handle changing the window sizes
   bool              OnWindowChangeXSize(void);
   bool              OnWindowChangeYSize(void);
   //--- Enable/disable tooltips
   bool              OnWindowTooltips(void);
   //--- Hiding all context menus below the initiating item
   bool              OnHideBackContextMenus(void);
   //--- Hiding all context menus
   bool              OnHideContextMenus(void);

   //--- Opening a dialog window
   bool              OnOpenDialogBox(void);
   //--- Closing a dialog window
   bool              OnCloseDialogBox(void);
   //--- Zeroing the color of the form and its elements
   bool              OnResetWindowColors(void);
   //--- Resetting priorities of the left mouse button click
   bool              OnZeroPriorities(void);
   //--- Restoring priorities of the left mouse click
   bool              OnSetPriorities(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CWndEvents::CWndEvents(void) : m_chart_id(0),
                               m_subwin(0),
                               m_active_window_index(0),
                               m_indicator_shortname(""),
                               m_program_name(PROGRAM_NAME),
                               m_subwindow_handle(INVALID_HANDLE),
                               m_subwindow_shortname(""),
                               m_subwindows_total(1)

  {
//--- Start the timer
   if(!::MQLInfoInteger(MQL_TESTER))
      ::EventSetMillisecondTimer(TIMER_STEP_MSC);
//--- Get the ID of the current chart
   m_chart.Attach();
//--- Enable tracking of mouse events
   m_chart.EventMouseMove(true);
//--- Disable calling the command line for the Space and Enter keys
   m_chart.SetInteger(CHART_QUICK_NAVIGATION,false);
//--- Identifying the sub-window number
   DetermineSubwindow();
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CWndEvents::~CWndEvents(void)
  {
//--- Delete the timer
   ::EventKillTimer();
//--- Enable management
   m_chart.MouseScroll(true);
   m_chart.SetInteger(CHART_DRAG_TRADE_LEVELS,true);
//--- Disable tracking of mouse events
   m_chart.EventMouseMove(false);
//--- Enable calling the command line for the Space and Enter keys
   m_chart.SetInteger(CHART_QUICK_NAVIGATION,true);
//--- Detach from the chart
   m_chart.Detach();
//--- Delete the indicator subwindow
   DeleteExpertSubwindow();
//--- Erase the comment   
   ::Comment("");
  }
//+------------------------------------------------------------------+
//| Initialization of event variables                                |
//+------------------------------------------------------------------+
void CWndEvents::InitChartEventsParams(const int id,const long lparam,const double dparam,const string sparam)
  {
   m_id     =id;
   m_lparam =lparam;
   m_dparam =dparam;
   m_sparam =sparam;
  }
//+------------------------------------------------------------------+
//| Handling program events                                          |
//+------------------------------------------------------------------+
void CWndEvents::ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- If the array is empty, leave
   if(CWndContainer::WindowsTotal()<1)
      return;
//--- Initialization of the event parameter fields
   InitChartEventsParams(id,lparam,dparam,sparam);
//--- Get the mouse parameters
   m_mouse.OnEvent(id,lparam,dparam,sparam);
//--- Custom event
   ChartEventCustom();
//--- Verification of interface control events
   CheckElementsEvents();
//--- Event of mouse movement
   ChartEventMouseMove();
//--- Event of changing the chart properties
   ChartEventChartChange();
  }
//+------------------------------------------------------------------+
//| Verification of the control events                               |
//+------------------------------------------------------------------+
void CWndEvents::CheckElementsEvents(void)
  {
   int elements_total=CWndContainer::ElementsTotal(m_active_window_index);
   for(int e=0; e<elements_total; e++)
      m_wnd[m_active_window_index].m_elements[e].OnEvent(m_id,m_lparam,m_dparam,m_sparam);
//--- Forwarding the event to the application file
   OnEvent(m_id,m_lparam,m_dparam,m_sparam);
  }
//+------------------------------------------------------------------+
//| CHARTEVENT_CUSTOM event                                          |
//+------------------------------------------------------------------+
void CWndEvents::ChartEventCustom(void)
  {
//--- If the signal is for minimizing the form
   if(OnWindowRollUp())
      return;
//--- If the signal is for maximizing the form
   if(OnWindowUnroll())
      return;
//--- If the signal is to resize the controls along the X axis
   if(OnWindowChangeXSize())
      return;
//--- If the signal is to resize the controls along the Y axis
   if(OnWindowChangeYSize())
      return;
//--- If the signal is to enable/disable tooltips
   if(OnWindowTooltips())
      return;
//--- If the signal is for hiding context menus below the initiating item
   if(OnHideBackContextMenus())
      return;
//--- If the signal is to hide all context menus
   if(OnHideContextMenus())
      return;

//--- If the signal is to open a dialog window
   if(OnOpenDialogBox())
      return;
//--- If the signal is to close a dialog window
   if(OnCloseDialogBox())
      return;
//--- If the signal is to zero the colors of all elements on the specified form
   if(OnResetWindowColors())
      return;
//--- If the signal is to reset the priorities of the left mouse button click
   if(OnZeroPriorities())
      return;
//--- If the signal is to restore the priorities of the left mouse button click
   if(OnSetPriorities())
      return;
  }
//+------------------------------------------------------------------+
//| CHARTEVENT CLICK event                                           |
//+------------------------------------------------------------------+
void CWndEvents::ChartEventClick(void)
  {
  }
//+------------------------------------------------------------------+
//| CHARTEVENT MOUSE MOVE event                                      |
//+------------------------------------------------------------------+
void CWndEvents::ChartEventMouseMove(void)
  {
//--- Leave, if this is not a cursor displacement event
   if(m_id!=CHARTEVENT_MOUSE_MOVE)
      return;
//--- Moving the window
   MovingWindow();
//--- Setting the state of the chart
   SetChartState();
  }
//+------------------------------------------------------------------+
//| CHARTEVENT OBJECT CLICK event                                    |
//+------------------------------------------------------------------+
void CWndEvents::ChartEventObjectClick(void)
  {
  }
//+------------------------------------------------------------------+
//| CHARTEVENT OBJECT ENDEDIT event                                  |
//+------------------------------------------------------------------+
void CWndEvents::ChartEventEndEdit(void)
  {
  }
//+------------------------------------------------------------------+
//| CHARTEVENT CHART CHANGE event                                    |
//+------------------------------------------------------------------+
void CWndEvents::ChartEventChartChange(void)
  {
//--- Event of changing the chart properties
   if(m_id!=CHARTEVENT_CHART_CHANGE)
      return;
//--- Check and update the expert subwindow number
   CheckExpertSubwindowNumber();
//--- Check and update the indicator subwindow number
   CheckSubwindowNumber();
//--- Moving the window
   MovingWindow(true);
//--- Resize the locked main window
   ResizeLockedWindow();
//--- Redraw chart
   m_chart.Redraw();
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CWndEvents::OnTimerEvent(void)
  {
//--- Leave, if mouse cursor is at rest (difference between call is >300 ms) and the left mouse button is released
   if(m_mouse.GapBetweenCalls()>300 && !m_mouse.LeftButtonState())
     {
      int text_boxes_total=CWndContainer::TextBoxesTotal(m_active_window_index);
      for(int e=0; e<text_boxes_total; e++)
         m_wnd[m_active_window_index].m_text_boxes[e].OnEventTimer();
      //---
      return;
     }
//--- If the array is empty, leave  
   if(CWndContainer::WindowsTotal()<1)
      return;
//--- Checking events of all controls by timer
   CheckElementsEventsTimer();
//--- Redraw chart
   m_chart.Redraw();
  }
//+------------------------------------------------------------------+
//| ON_WINDOW_ROLLUP event                                           |
//+------------------------------------------------------------------+
bool CWndEvents::OnWindowRollUp(void)
  {
//--- If the signal is for minimizing the form
   if(m_id!=CHARTEVENT_CUSTOM+ON_WINDOW_ROLLUP)
      return(false);
//--- If the window identifier and the sub-window number match
   if(m_lparam==m_windows[0].Id() && (int)m_dparam==m_subwin)
     {
      int elements_total=CWndContainer::ElementsTotal(0);
      for(int e=0; e<elements_total; e++)
        {
         //--- Hide all elements except the form
         if(m_wnd[0].m_elements[e].ClassName()!="CWindow")
            m_wnd[0].m_elements[e].Hide();
        }
      //--- Reset the form colors
      m_windows[0].ResetColors();
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| ON_WINDOW_UNROLL event                                           |
//+------------------------------------------------------------------+
bool CWndEvents::OnWindowUnroll(void)
  {
//--- If the signal is to "Maximize the form"
   if(m_id!=CHARTEVENT_CUSTOM+ON_WINDOW_UNROLL)
      return(false);
//--- Index of the active window
   int awi=m_active_window_index;
//--- If the window identifier and the sub-window number match
   if(m_lparam==m_windows[awi].Id() && (int)m_dparam==m_subwin)
     {
      int elements_total=CWndContainer::ElementsTotal(awi);
      for(int e=0; e<elements_total; e++)
        {
         //--- Make all elements visible except the form and ...
         if(m_wnd[awi].m_elements[e].ClassName()!="CWindow")
           {
            //--- ... the drop down controls
            if(!m_wnd[awi].m_elements[e].IsDropdown())
               m_wnd[awi].m_elements[e].Show();
            //--- If the mode is enabled, adjust the height
            if(m_wnd[awi].m_elements[e].AutoYResizeMode())
               m_wnd[awi].m_elements[e].ChangeHeightByBottomWindowSide();
           }
         else
           {
            //--- Change the height if the mode is enabled
            if(m_windows[awi].AutoYResizeMode())
               m_windows[awi].ChangeWindowHeight(m_chart.HeightInPixels(m_subwin)-3);
           }
        }
      //--- Reset the form colors
      m_windows[0].ResetColors();
      //--- If there are tabs, show controls of the selected tab only
      int tabs_total=CWndContainer::TabsTotal(awi);
      for(int t=0; t<tabs_total; t++)
         m_wnd[awi].m_tabs[t].ShowTabElements();
      //--- If there are icon tabs, show controls of the selected tab only
      int icon_tabs_total=CWndContainer::IconTabsTotal(awi);
      for(int t=0; t<icon_tabs_total; t++)
         m_wnd[awi].m_icon_tabs[t].ShowTabElements();
      //--- If there are tree views, then show controls of the selected tab item only
      int treeview_total=CWndContainer::TreeViewListsTotal(awi);
      for(int tv=0; tv<treeview_total; tv++)
         m_wnd[awi].m_treeview_lists[tv].ShowTabElements();
     }
//--- Update location of all elements
   MovingWindow(true);
   m_chart.Redraw();
   return(true);
  }
//+------------------------------------------------------------------+
//| ON_WINDOW_CHANGE_XSIZE event                                     |
//+------------------------------------------------------------------+
bool CWndEvents::OnWindowChangeXSize(void)
  {
//--- If the signal is to "Resize the controls"
   if(m_id!=CHARTEVENT_CUSTOM+ON_WINDOW_CHANGE_XSIZE)
      return(false);
//--- Index of the active window
   int awi=m_active_window_index;
//--- If the window identifiers match
   if(m_lparam!=m_windows[awi].Id())
      return(true);
//--- Change the width of all controls except the form
   int elements_total=CWndContainer::ElementsTotal(awi);
   for(int e=0; e<elements_total; e++)
     {
      //--- If it is a window, go to the next
      if(m_wnd[awi].m_elements[e].ClassName()=="CWindow")
         continue;
      //--- If the mode is enabled, adjust the width
      if(m_wnd[awi].m_elements[e].AutoXResizeMode())
         m_wnd[awi].m_elements[e].ChangeWidthByRightWindowSide();
      //--- Update the position of object
      m_wnd[awi].m_elements[e].Moving(m_windows[awi].X(),m_windows[awi].Y(),true);
     }
//--- Update location of all elements
   m_chart.Redraw();
   return(true);
  }
//+------------------------------------------------------------------+
//| ON_WINDOW_CHANGE_YSIZE event                                     |
//+------------------------------------------------------------------+
bool CWndEvents::OnWindowChangeYSize(void)
  {
//--- If the signal is to "Resize the controls"
   if(m_id!=CHARTEVENT_CUSTOM+ON_WINDOW_CHANGE_YSIZE)
      return(false);
//--- Index of the active window
   int awi=m_active_window_index;
//--- If the window identifiers match
   if(m_lparam!=m_windows[awi].Id())
      return(true);
//--- Change the width of all controls except the form
   int elements_total=CWndContainer::ElementsTotal(awi);
   for(int e=0; e<elements_total; e++)
     {
      //--- If it is a window, go to the next
      if(m_wnd[awi].m_elements[e].ClassName()=="CWindow")
         continue;
      //--- If the mode is enabled, adjust the height
      if(m_wnd[awi].m_elements[e].AutoYResizeMode())
         m_wnd[awi].m_elements[e].ChangeHeightByBottomWindowSide();
      //--- Update the position of object
      m_wnd[awi].m_elements[e].Moving(m_windows[awi].X(),m_windows[awi].Y(),true);
     }
//--- Update location of all elements
   m_chart.Redraw();
   return(true);
  }
//+------------------------------------------------------------------+
//| ON_WINDOW_TOOLTIPS event                                         |
//+------------------------------------------------------------------+
bool CWndEvents::OnWindowTooltips(void)
  {
//--- If the signal is to "Enable/disable tooltips"
   if(m_id!=CHARTEVENT_CUSTOM+ON_WINDOW_TOOLTIPS)
      return(false);
//--- If the window identifiers match
   if(m_lparam!=m_windows[0].Id())
      return(true);
//--- Synchronize the tooltips mode across all windows
   int windows_total=WindowsTotal();
   for(int w=0; w<windows_total; w++)
     {
      if(w>0)
         m_windows[w].TooltipButtonState(m_windows[0].TooltipButtonState());
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| ON_HIDE_BACK_CONTEXTMENUS events                                 |
//+------------------------------------------------------------------+
bool CWndEvents::OnHideBackContextMenus(void)
  {
//--- If the signal is for hiding context menus below the initiating item
   if(m_id!=CHARTEVENT_CUSTOM+ON_HIDE_BACK_CONTEXTMENUS)
      return(false);
//--- Iterate over all menus from the last called
   int awi=m_active_window_index;
   int context_menus_total=CWndContainer::ContextMenusTotal(awi);
   for(int i=context_menus_total-1; i>=0; i--)
     {
      //--- Pointers to the context menu and its previous node
      CContextMenu *cm=m_wnd[awi].m_context_menus[i];
      CMenuItem    *mi=cm.PrevNodePointer();
      //--- If there is nothing after that point, then...
      if(::CheckPointer(mi)==POINTER_INVALID)
         continue;
      //--- If made it to the signal initiating item, then...
      if(mi.Id()==m_lparam)
        {
         //--- ...if its context menu has no focus, hide it
         if(!cm.MouseFocus())
            cm.Hide();
         //--- If there is nothing after that point, then...
         if(::CheckPointer(mi.PrevNodePointer())==POINTER_INVALID)
           {
            //--- ...unblock the window
            m_windows[awi].IsLocked(false);
           }
         //--- Stop the loop
         break;
        }
      else
        {
         //--- Hide the context menu
         cm.Hide();
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| ON_HIDE_CONTEXTMENUS event                                       |
//+------------------------------------------------------------------+
bool CWndEvents::OnHideContextMenus(void)
  {
//--- If the signal is to hide all context menus
   if(m_id!=CHARTEVENT_CUSTOM+ON_HIDE_CONTEXTMENUS)
      return(false);
//--- Hide all context menus
   int awi=m_active_window_index;
   int cm_total=CWndContainer::ContextMenusTotal(awi);
   for(int i=0; i<cm_total; i++)
      m_wnd[awi].m_context_menus[i].Hide();
//--- Disable main menus
   int menu_bars_total=CWndContainer::MenuBarsTotal(awi);
   for(int i=0; i<menu_bars_total; i++)
      m_wnd[awi].m_menu_bars[i].State(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| ON_OPEN_DIALOG_BOX event                                         |
//+------------------------------------------------------------------+
bool CWndEvents::OnOpenDialogBox(void)
  {
//--- If the signal is to open a dialog window
   if(m_id!=CHARTEVENT_CUSTOM+ON_OPEN_DIALOG_BOX)
      return(false);
//--- Leave, if the message is from another program
   if(m_sparam!=m_program_name)
      return(true);
//--- Iterate over the window array
   int window_total=CWndContainer::WindowsTotal();
   for(int w=0; w<window_total; w++)
     {
      //--- If identifiers match
      if(m_windows[w].Id()==m_lparam)
        {
         //--- Store the index of the window in the form from which the form was brought up
         m_windows[w].PrevActiveWindowIndex(m_active_window_index);
         //--- Activate the form
         m_windows[w].State(true);
         //--- Restore priorities of the left mouse click to the form objects
         m_windows[w].SetZorders();
         //--- Store the index of the activated window
         m_active_window_index=w;
         //--- Make all elements of the activated window visible
         int elements_total=CWndContainer::ElementsTotal(w);
         for(int e=0; e<elements_total; e++)
           {
            //--- Skip the forms and drop-down elements
            if(m_wnd[w].m_elements[e].ClassName()=="CWindow" || 
               m_wnd[w].m_elements[e].IsDropdown())
               continue;
            //--- Make the element visible
            m_wnd[w].m_elements[e].Show();
            //--- Restore the priority of the left mouse click to the element
            m_wnd[w].m_elements[e].SetZorders();
           }
         //--- Hiding tooltips in the previous window
         int tooltips_total=CWndContainer::TooltipsTotal(m_windows[w].PrevActiveWindowIndex());
         for(int t=0; t<tooltips_total; t++)
            m_wnd[m_windows[w].PrevActiveWindowIndex()].m_tooltips[t].FadeOutTooltip();
         //--- If there are tabs, show controls of the selected tab only
         int tabs_total=CWndContainer::TabsTotal(w);
         for(int t=0; t<tabs_total; t++)
            m_wnd[w].m_tabs[t].ShowTabElements();
         //--- If there are icon tabs, show controls of the selected tab only
         int icon_tabs_total=CWndContainer::IconTabsTotal(w);
         for(int t=0; t<icon_tabs_total; t++)
            m_wnd[w].m_icon_tabs[t].ShowTabElements();
         //--- If there are tree views, then show controls of the selected tab item only
         int treeview_total=CWndContainer::TreeViewListsTotal(w);
         for(int tv=0; tv<treeview_total; tv++)
            m_wnd[w].m_treeview_lists[tv].ShowTabElements();
        }
      //--- Other forms will be blocked until the activated window is closed
      else
        {
         //--- Block the form
         m_windows[w].State(false);
         //--- Zero priorities of the left mouse click for the form elements
         int elements_total=CWndContainer::ElementsTotal(w);
         for(int e=0; e<elements_total; e++)
            m_wnd[w].m_elements[e].ResetZorders();
        }
     }
//--- Move tooltips to the top layer
   for(int w=0; w<window_total; w++)
     {
      int tooltips_total=CWndContainer::TooltipsTotal(w);
      for(int t=0; t<tooltips_total; t++)
         m_wnd[w].m_tooltips[t].Reset();
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| ON_CLOSE_DIALOG_BOX event                                        |
//+------------------------------------------------------------------+
bool CWndEvents::OnCloseDialogBox(void)
  {
//--- If the signal is to close a dialog window
   if(m_id!=CHARTEVENT_CUSTOM+ON_CLOSE_DIALOG_BOX)
      return(false);
//--- Iterate over the window array
   int window_total=CWndContainer::WindowsTotal();
   for(int w=0; w<window_total; w++)
     {
      //--- If identifiers match
      if(m_windows[w].Id()==m_lparam)
        {
         //--- Block the form
         m_windows[w].State(false);
         //--- Hide the form
         int elements_total=CWndContainer::ElementsTotal(w);
         for(int e=0; e<elements_total; e++)
            m_wnd[w].m_elements[e].Hide();
         //--- Activate the previous form
         m_windows[int(m_dparam)].State(true);
         //--- Redrawing of the chart
         m_chart.Redraw();
         break;
        }
     }
//--- Setting the index of the previous window
   m_active_window_index=int(m_dparam);
//--- Restoring priorities of the left mouse click to the activated window
   int elements_total=CWndContainer::ElementsTotal(m_active_window_index);
   for(int e=0; e<elements_total; e++)
      m_wnd[m_active_window_index].m_elements[e].SetZorders();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| ON_RESET_WINDOW_COLORS event                                     |
//+------------------------------------------------------------------+
bool CWndEvents::OnResetWindowColors(void)
  {
//--- If the signal is to zero the window color
   if(m_id!=CHARTEVENT_CUSTOM+ON_RESET_WINDOW_COLORS)
      return(false);
//--- To identify the index of the form from which the message was received
   int index=WRONG_VALUE;
//--- Iterate over the window array
   int window_total=CWndContainer::WindowsTotal();
   for(int w=0; w<window_total; w++)
     {
      //--- If identifiers match
      if(m_windows[w].Id()==m_lparam)
        {
         //--- Store the index
         index=w;
         //--- Zero the color of the form
         m_windows[w].ResetColors();
         break;
        }
     }
//--- Leave, if the index was not identified
   if(index==WRONG_VALUE)
      return(true);
//--- Zero colors of all form elements
   int elements_total=CWndContainer::ElementsTotal(index);
   for(int e=0; e<elements_total; e++)
      m_wnd[index].m_elements[e].ResetColors();
//--- Redrawing of the chart
   m_chart.Redraw();
   return(true);
  }
//+------------------------------------------------------------------+
//| ON_ZERO_PRIORITIES event                                         |
//+------------------------------------------------------------------+
bool CWndEvents::OnZeroPriorities(void)
  {
//--- If the signal is to zero priorities of the left mouse click
   if(m_id!=CHARTEVENT_CUSTOM+ON_ZERO_PRIORITIES)
      return(false);
//---
   int elements_total=CWndContainer::ElementsTotal(m_active_window_index);
   for(int e=0; e<elements_total; e++)
     {
      //--- Zero priorities of all elements except the one with the id passed in the event and ...
      if(m_lparam!=m_wnd[m_active_window_index].m_elements[e].Id())
        {
         //--- ... except context menus
         if(m_wnd[m_active_window_index].m_elements[e].ClassName()=="CMenuItem" ||
            m_wnd[m_active_window_index].m_elements[e].ClassName()=="CContextMenu")
            continue;
         //---
         m_wnd[m_active_window_index].m_elements[e].ResetZorders();
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| ON_SET_PRIORITIES event                                          |
//+------------------------------------------------------------------+
bool CWndEvents::OnSetPriorities(void)
  {
//--- If the signal is to restore the priorities of the left mouse button click
   if(m_id!=CHARTEVENT_CUSTOM+ON_SET_PRIORITIES)
      return(false);
//---
   int elements_total=CWndContainer::ElementsTotal(m_active_window_index);
   for(int e=0; e<elements_total; e++)
      m_wnd[m_active_window_index].m_elements[e].SetZorders();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Moving the window                                                |
//+------------------------------------------------------------------+
void CWndEvents::MovingWindow(const bool moving_mode=false)
  {
   int awi=m_active_window_index;
//--- Moving the window
   int x=m_windows[awi].X();
   int y=m_windows[awi].Y();
   m_windows[awi].Moving(x,y);
//--- If the management is delegated to the window, identify its location
   if(!moving_mode)
      if(m_windows[awi].ClampingAreaMouse()!=PRESSED_INSIDE_HEADER)
         return;
//--- Moving controls
   int elements_total=CWndContainer::ElementsTotal(awi);
   for(int e=0; e<elements_total; e++)
      m_wnd[awi].m_elements[e].Moving(x,y,moving_mode);
  }
//+------------------------------------------------------------------+
//| Checking all element events by the timer                         |
//+------------------------------------------------------------------+
void CWndEvents::CheckElementsEventsTimer(void)
  {
   int elements_total=CWndContainer::ElementsTotal(m_active_window_index);
   for(int e=0; e<elements_total; e++)
      m_wnd[m_active_window_index].m_elements[e].OnEventTimer();
  }
//+------------------------------------------------------------------+
//| Identifying the sub-window number                                |
//+------------------------------------------------------------------+
void CWndEvents::DetermineSubwindow(void)
  {
//--- Leave, if the program type is "Script"
   if(PROGRAM_TYPE==PROGRAM_SCRIPT)
      return;
//--- Reset the last error
   ::ResetLastError();
//--- If the program type is "Expert"
   if(PROGRAM_TYPE==PROGRAM_EXPERT)
     {
      //--- Leave, if the graphical interface of the expert is required in the main window
      if(!EXPERT_IN_SUBWINDOW)
         return;
      //--- Get the handle of the placeholder indicator (empty subwindow)
      m_subwindow_handle=iCustom(::Symbol(),::Period(),"::Indicators\\SubWindow.ex5");
      //--- If there is no such indicator, report the error to the log
      if(m_subwindow_handle==INVALID_HANDLE)
         ::Print(__FUNCTION__," > Error getting the indicator handle in the directory ::Indicators\\SubWindow.ex5 !");
      //--- If the handle is obtained, then the indicator exists, included in the application as a resource,
      //    and this means that the graphical interface of the application must be placed in the subwindow.
      else
        {
         //--- Get the number of subwindows on the chart
         int subwindows_total=(int)::ChartGetInteger(m_chart_id,CHART_WINDOWS_TOTAL);
         //--- Set the subwindow for the graphical interface of the expert
         if(::ChartIndicatorAdd(m_chart_id,subwindows_total,m_subwindow_handle))
           {
            //--- Store the subwindow number and the current number of subwindows on the chart
            m_subwin           =subwindows_total;
            m_subwindows_total =subwindows_total+1;
            //--- Get and store the short name of the expert subwindow
            m_subwindow_shortname=::ChartIndicatorName(m_chart_id,m_subwin,0);
           }
         //--- If the subwindow was not set
         else
            ::Print(__FUNCTION__," > Error setting the expert subwindow! Error code: ",::GetLastError());
        }
      //---
      return;
     }
//--- Identifying the number of the indicator window
   m_subwin=::ChartWindowFind();
//--- If identification of the number failed, leave
   if(m_subwin<0)
     {
      ::Print(__FUNCTION__," > An error occurred while determining the number of the subwindow: ",::GetLastError());
      return;
     }
//--- If this is not the main window of the chart
   if(m_subwin>0)
     {
      //--- Get the total number of indicators in the specified sub-window
      int total=::ChartIndicatorsTotal(m_chart_id,m_subwin);
      //--- Get the short name of the last indicator in the list
      string indicator_name=::ChartIndicatorName(m_chart_id,m_subwin,total-1);
      //--- If the sub-window already contains an indicator, remove the program from the chart
      if(total!=1)
        {
         ::Print(__FUNCTION__," > This window already contains an indicator.");
         ::ChartIndicatorDelete(m_chart_id,m_subwin,indicator_name);
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//| Delete the expert subwindow                                      |
//+------------------------------------------------------------------+
void CWndEvents::DeleteExpertSubwindow(void)
  {
//--- Leave, if this is not expert
   if(PROGRAM_TYPE!=PROGRAM_EXPERT)
      return;
//--- Leave, if the handle is invalid
   if(m_subwindow_handle==INVALID_HANDLE)
      return;
//--- Get the number of windows on the chart
   int windows_total=(int)::ChartGetInteger(m_chart_id,CHART_WINDOWS_TOTAL);
//--- find the expert subwindow
   for(int w=0; w<windows_total; w++)
     {
      //--- Get the short name of the expert subwindow (the SubWindow.ex5 indicator)
      string indicator_name=::ChartIndicatorName(m_chart_id,w,0);
      //--- Go to the next, if this is not the expert subwindow
      if(indicator_name!=m_subwindow_shortname || w!=m_subwin)
         continue;
      //--- Delete the expert subwindow
      if(!::ChartIndicatorDelete(m_chart_id,m_subwin,indicator_name))
         ::Print(__FUNCTION__," > Error deleting the expert subwindow! Error code: ",::GetLastError());
     }
  }
//+------------------------------------------------------------------+
//| Check and update the expert subwindow number                     |
//+------------------------------------------------------------------+
void CWndEvents::CheckExpertSubwindowNumber(void)
  {
//--- Leave, if (1) this in not an expert or (2) the graphical interface of the expert in the main window
   if(PROGRAM_TYPE!=PROGRAM_EXPERT || !EXPERT_IN_SUBWINDOW)
      return;
//--- Get the number of subwindows on the chart
   int subwindows_total=(int)::ChartGetInteger(m_chart_id,CHART_WINDOWS_TOTAL);
//--- Leave, if the number of subwindows and the number of indicators have not changed
   if(subwindows_total==m_subwindows_total)
      return;
//--- Store the current number of subwindows
   m_subwindows_total=subwindows_total;
//--- For checking if expert subwindow is present
   bool is_subwindow=false;
//--- find the expert subwindow
   for(int sw=0; sw<subwindows_total; sw++)
     {
      //--- Stop the cycle, if the expert subwindow has been found
      if(is_subwindow)
         break;
      //--- The number of indicators in this window/subwindow
      int indicators_total=::ChartIndicatorsTotal(m_chart_id,sw);
      //--- Iterate over all indicators in the window 
      for(int i=0; i<indicators_total; i++)
        {
         //--- Get the short name of the indicator
         string indicator_name=::ChartIndicatorName(m_chart_id,sw,i);
         //--- If this is not the expert subwindow, go to the next
         if(indicator_name!=m_subwindow_shortname)
            continue;
         //--- Mark that expert has a subwindow
         is_subwindow=true;
         //--- If the subwindow number has changed, then 
         //    it is necessary to store the new number in all controls of the main form
         if(sw!=m_subwin)
           {
            //--- Store the subwindow number
            m_subwin=sw;
            //--- Store it in all the controls of the main form of the interface
            int elements_total=CWndContainer::ElementsTotal(0);
            for(int e=0; e<elements_total; e++)
               m_wnd[0].m_elements[e].SubwindowNumber(m_subwin);
           }
         //---
         break;
        }
     }
//--- If the expert subwindow was not found, remove the expert
   if(!is_subwindow)
     {
      ::Print(__FUNCTION__," > Deleting expert subwindow causes the expert to be removed!");
      //--- Removing the EA from the chart
      ::ExpertRemove();
     }
  }
//+------------------------------------------------------------------+
//| Checking and updating the program window number                  |
//+------------------------------------------------------------------+
void CWndEvents::CheckSubwindowNumber(void)
  {
//--- Leave, if this is not indicator
   if(PROGRAM_TYPE!=PROGRAM_INDICATOR)
      return;
//--- If the program in the sub-window and the numbers do not match
   if(m_subwin!=0 && m_subwin!=::ChartWindowFind())
     {
      //--- Identify the sub-window number
      DetermineSubwindow();
      //--- Store in all elements
      int windows_total=CWndContainer::WindowsTotal();
      for(int w=0; w<windows_total; w++)
        {
         int elements_total=CWndContainer::ElementsTotal(w);
         for(int e=0; e<elements_total; e++)
            m_wnd[w].m_elements[e].SubwindowNumber(m_subwin);
        }
     }
  }
//+------------------------------------------------------------------+
//| Resize the locked main window                                    |
//+------------------------------------------------------------------+
void CWndEvents::ResizeLockedWindow(void)
  {
//--- Store in all elements
   int windows_total=CWndContainer::WindowsTotal();
//--- Leave, if the interface has not been created
   if(windows_total<1)
      return;
//--- Resize all controls of the locked form, if one the modes is enabled
   if(m_windows[0].IsLocked() && (m_windows[0].AutoXResizeMode() || m_windows[0].AutoXResizeMode()))
     {
      int elements_total=CWndContainer::ElementsTotal(0);
      for(int e=0; e<elements_total; e++)
        {
         //--- If this is a form
         if(m_wnd[0].m_elements[e].ClassName()=="CWindow")
           {
            m_wnd[0].m_elements[e].OnEvent(m_id,m_lparam,m_dparam,m_sparam);
            continue;
           }
         //--- Resize all controls with this mode enabled
         if(m_wnd[0].m_elements[e].AutoXResizeMode())
            m_wnd[0].m_elements[e].ChangeWidthByRightWindowSide();
         //--- Resize all controls with this mode enabled
         if(m_wnd[0].m_elements[e].AutoYResizeMode())
            m_wnd[0].m_elements[e].ChangeHeightByBottomWindowSide();
         //--- Update the position of objects
         m_wnd[0].m_elements[e].Moving(m_windows[0].X(),m_windows[0].Y());
        }
      //--- Update (store) the chart properties of other forms
      for(int w=0; w<windows_total; w++)
        {
         if(w>0)
            m_windows[w].SetWindowProperties();
        }
     }
  }
//+------------------------------------------------------------------+
//| Redraw the window                                                |
//+------------------------------------------------------------------+
void CWndEvents::ResetWindow(void)
  {
//--- Leave, if there is no window yet
   if(CWndContainer::WindowsTotal()<1)
      return;
//--- Window index
   int awi=m_active_window_index;
//--- Redraw the window and its controls
   m_windows[awi].Reset();
   int elements_total=CWndContainer::ElementsTotal(awi);
   for(int e=0; e<elements_total; e++)
     {
      if(m_wnd[awi].m_elements[e].IsVisible())
         m_wnd[awi].m_elements[e].Reset();
     }
//--- Display controls of the active tab only
   int tabs_total=CWndContainer::TabsTotal(awi);
   for(int e=0; e<tabs_total; e++)
      m_wnd[awi].m_tabs[e].ShowTabElements();
  }
//+------------------------------------------------------------------+
//| Deleting all objects                                             |
//+------------------------------------------------------------------+
void CWndEvents::Destroy(void)
  {
//--- Set the index of the main window
   m_active_window_index=0;
//--- Get the number of windows
   int window_total=CWndContainer::WindowsTotal();
//--- Iterate over the window array
   for(int w=0; w<window_total; w++)
     {
      //--- Activate the main window
      if(m_windows[w].WindowType()==W_MAIN)
         m_windows[w].State(true);
      //--- Block dialog windows
      else
         m_windows[w].State(false);
     }
//--- Empty element arrays
   for(int w=0; w<window_total; w++)
     {
      int elements_total=CWndContainer::ElementsTotal(w);
      for(int e=0; e<elements_total; e++)
        {
         //--- If the pointer is invalid, move to the following
         if(::CheckPointer(m_wnd[w].m_elements[e])==POINTER_INVALID)
            continue;
         //--- Delete element objects
         m_wnd[w].m_elements[e].Delete();
        }
      //--- Empty element arrays
      ::ArrayFree(m_wnd[w].m_objects);
      ::ArrayFree(m_wnd[w].m_elements);
      ::ArrayFree(m_wnd[w].m_menu_bars);
      ::ArrayFree(m_wnd[w].m_context_menus);
      ::ArrayFree(m_wnd[w].m_tooltips);
      ::ArrayFree(m_wnd[w].m_drop_lists);
      ::ArrayFree(m_wnd[w].m_scrolls);
      ::ArrayFree(m_wnd[w].m_labels_tables);
      ::ArrayFree(m_wnd[w].m_tables);
      ::ArrayFree(m_wnd[w].m_canvas_tables);
      ::ArrayFree(m_wnd[w].m_tabs);
      ::ArrayFree(m_wnd[w].m_icon_tabs);
      ::ArrayFree(m_wnd[w].m_calendars);
      ::ArrayFree(m_wnd[w].m_drop_calendars);
      ::ArrayFree(m_wnd[w].m_treeview_lists);
      ::ArrayFree(m_wnd[w].m_file_navigators);
      ::ArrayFree(m_wnd[w].m_sub_charts);
      ::ArrayFree(m_wnd[w].m_pictures_slider);
      ::ArrayFree(m_wnd[w].m_time_edits);
     }
//--- Empty form arrays
   ::ArrayFree(m_wnd);
   ::ArrayFree(m_windows);
  }
//+------------------------------------------------------------------+
//| Sets the state of the chart                                      |
//+------------------------------------------------------------------+
void CWndEvents::SetChartState(void)
  {
   int awi=m_active_window_index;
//--- To identify the event when management must be disabled
   bool condition=false;
//--- Check windows
   int windows_total=CWndContainer::WindowsTotal();
   for(int i=0; i<windows_total; i++)
     {
      //--- Move to the next one, if this form is hidden
      if(!m_windows[i].IsVisible())
         continue;
      //--- Check conditions in the internal handler of the form
      m_windows[i].OnEvent(m_id,m_lparam,m_dparam,m_sparam);
      //--- If there is a focus, mark it
      if(m_windows[i].MouseFocus())
        {
         condition=true;
         break;
        }
     }
//--- Check drop-down list views
   if(!condition)
     {
      //--- Get the total of the drop-down list views
      int drop_lists_total=CWndContainer::DropListsTotal(awi);
      for(int i=0; i<drop_lists_total; i++)
        {
         //--- Get the pointer to the drop-down list view
         CListView *lv=m_wnd[awi].m_drop_lists[i];
         //--- If the list view is activated (visible)
         if(lv.IsVisible())
           {
            //--- Check the focus over the list view and the state of its scrollbar
            if(m_wnd[awi].m_drop_lists[i].MouseFocus() || lv.ScrollState())
              {
               condition=true;
               break;
              }
           }
        }
     }
//--- Check calendar
   if(!condition)
     {
      int drop_calendars_total=CWndContainer::DropCalendarsTotal(awi);
      for(int i=0; i<drop_calendars_total; i++)
        {
         if(m_wnd[awi].m_drop_calendars[i].GetCalendarPointer().MouseFocus())
           {
            condition=true;
            break;
           }
        }
     }
//--- Check the focus of context menus
   if(!condition)
     {
      //--- Check the total of drop-down context menus
      int context_menus_total=CWndContainer::ContextMenusTotal(awi);
      for(int i=0; i<context_menus_total; i++)
        {
         //--- If the focus is over the context menu
         if(m_wnd[awi].m_context_menus[i].MouseFocus())
           {
            condition=true;
            break;
           }
        }
     }
//--- Check the state of a scrollbar
   if(!condition)
     {
      int scrolls_total=CWndContainer::ScrollsTotal(awi);
      for(int i=0; i<scrolls_total; i++)
        {
         if(((CScroll*)m_wnd[awi].m_scrolls[i]).ScrollState())
           {
            condition=true;
            break;
           }
        }
     }
//--- Sets the chart state in all forms
   for(int i=0; i<windows_total; i++)
      m_windows[i].CustomEventChartState(condition);
  }
//+------------------------------------------------------------------+
