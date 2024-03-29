//+------------------------------------------------------------------+
//|                                                 WndContainer.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property strict
#include "Controls\Window.mqh"
#include "Controls\MenuBar.mqh"
#include "Controls\MenuItem.mqh"
#include "Controls\ContextMenu.mqh"
#include "Controls\SeparateLine.mqh"
#include "Controls\SimpleButton.mqh"
#include "Controls\IconButton.mqh"
#include "Controls\SplitButton.mqh"
#include "Controls\ButtonsGroup.mqh"
#include "Controls\IconButtonsGroup.mqh"
#include "Controls\RadioButtons.mqh"
#include "Controls\StatusBar.mqh"
#include "Controls\Tooltip.mqh"
#include "Controls\ListView.mqh"
#include "Controls\ComboBox.mqh"
#include "Controls\CheckBox.mqh"
#include "Controls\SpinEdit.mqh"
#include "Controls\CheckBoxEdit.mqh"
#include "Controls\CheckComboBox.mqh"
#include "Controls\Slider.mqh"
#include "Controls\DualSlider.mqh"
#include "Controls\LabelsTable.mqh"
#include "Controls\Table.mqh"
#include "Controls\CanvasTable.mqh"
#include "Controls\Tabs.mqh"
#include "Controls\IconTabs.mqh"
#include "Controls\Calendar.mqh"
#include "Controls\DropCalendar.mqh"
#include "Controls\TreeItem.mqh"
#include "Controls\TreeView.mqh"
#include "Controls\FileNavigator.mqh"
#include "Controls\ColorButton.mqh"
#include "Controls\ColorPicker.mqh"
#include "Controls\ProgressBar.mqh"
#include "Controls\IndicatorBar.mqh"
#include "Controls\LineGraph.mqh"
#include "Controls\StandardChart.mqh"
#include "Controls\TextBox.mqh"
#include "Controls\TextEdit.mqh"
#include "Controls\TextLabel.mqh"
#include "Controls\Picture.mqh"
#include "Controls\PicturesSlider.mqh"
#include "Controls\TimeEdit.mqh"
#include "Controls\CheckBoxList.mqh"
//+------------------------------------------------------------------+
//| Class for storing all interface objects                          |
//+------------------------------------------------------------------+
class CWndContainer
  {
private:
   //--- Element counter
   int               m_counter_element_id;
   //---
protected:
   //--- Class instance for getting the mouse parameters
   CMouse            m_mouse;
   //--- Window array
   CWindow          *m_windows[];
   //--- Structure of the element arrays
   struct WindowElements
     {
      //--- Common array of all objects
      CChartObject     *m_objects[];
      //--- Common array of all elements
      CElementBase     *m_elements[];

      //--- Private arrays of elements:
      //    Context menu array
      CContextMenu     *m_context_menus[];
      //--- Main menu array
      CMenuBar         *m_menu_bars[];
      //--- Tooltips
      CTooltip         *m_tooltips[];
      //--- Array of drop-down list views of different types
      CElementBase     *m_drop_lists[];
      //--- Array of scrollbars
      CElementBase     *m_scrolls[];
      //--- Array of text label tables
      CElementBase     *m_labels_tables[];
      //--- Array of edit box tables
      CElementBase     *m_tables[];
      //--- Array of rendered tables
      CElementBase     *m_canvas_tables[];
      //--- Array of tabs
      CTabs            *m_tabs[];
      //--- Array of icon tabs
      CIconTabs        *m_icon_tabs[];
      //--- Array of calendars
      CCalendar        *m_calendars[];
      //--- Array of drop down calendars
      CDropCalendar    *m_drop_calendars[];
      //--- Tree views
      CTreeView        *m_treeview_lists[];
      //--- File navigators
      CFileNavigator   *m_file_navigators[];
      //--- Subcharts
      CStandardChart   *m_sub_charts[];
      //--- Picture sliders
      CPicturesSlider  *m_pictures_slider[];
      //--- Time
      CTimeEdit        *m_time_edits[];
      //--- Multiline text boxes
      CTextBox         *m_text_boxes[];
     };
   //--- Array of element arrays for each window
   WindowElements    m_wnd[];
   //---
protected:
                     CWndContainer(void);
                    ~CWndContainer(void);
   //---
public:
   //--- Number of windows in the interface
   int               WindowsTotal(void) { return(::ArraySize(m_windows)); }
   //--- Number of objects of all elements
   int               ObjectsElementsTotal(const int window_index);
   //--- Number of elements
   int               ElementsTotal(const int window_index);
   //--- Number of context menus
   int               ContextMenusTotal(const int window_index);
   //--- Number of main menus
   int               MenuBarsTotal(const int window_index);
   //--- Number of tooltips
   int               TooltipsTotal(const int window_index);
   //--- Number of drop-down list views
   int               DropListsTotal(const int window_index);
   //--- The number of scrollbars
   int               ScrollsTotal(const int window_index);
   //--- The number of text label tables
   int               LabelsTablesTotal(const int window_index);
   //--- The number of edit box tables
   int               TablesTotal(const int window_index);
   //--- The number of rendered tables
   int               CanvasTablesTotal(const int window_index);
   //--- The number of tabs
   int               TabsTotal(const int window_index);
   //--- The number of icon tabs
   int               IconTabsTotal(const int window_index);
   //--- Number of calendars
   int               CalendarsTotal(const int window_index);
   //--- The number of drop down calendars
   int               DropCalendarsTotal(const int window_index);
   //--- The number of tree views
   int               TreeViewListsTotal(const int window_index);
   //--- The number of file navigators
   int               FileNavigatorsTotal(const int window_index);
   //--- The number of subcharts
   int               SubChartsTotal(const int window_index);
   //--- The number of picture sliders
   int               PicturesSliderTotal(const int window_index);
   //--- The number of Time controls
   int               TimeEditsTotal(const int window_index);
   //--- The number of Multiline Text box controls
   int               TextBoxesTotal(const int window_index);
   //---
protected:
   //--- Adds a window pointer to the base of interface elements
   void              AddWindow(CWindow &object);
   //--- Adds element object pointers to the common array
   template<typename T>
   void              AddToObjectsArray(const int window_index,T &object);
   //--- Adds the object pointer to the array
   void              AddToArray(const int window_index,CChartObject &object);
   //--- Adds a pointer to the element array
   void              AddToElementsArray(const int window_index,CElementBase &object);
   //--- Template method for adding pointers to the array passed by a link
   template<typename T1,typename T2>
   void              AddToRefArray(T1 &object,T2 &ref_array[]);
   //---
   void              PrintElementsTotal(void);
   //---
private:
   //--- Checking for exceeding the array range
   int               CheckOutOfRange(const int window_index);
   //--- Stores pointers to the context menu controls
   bool              AddContextMenuElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the main menu controls
   bool              AddMenuBarElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the split button controls
   bool              AddSplitButtonElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the tooltip controls
   bool              AddTooltipElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the list view objects
   bool              AddListViewElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the drop-down list view controls (combobox)
   bool              AddComboBoxElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the drop-down list view controls (combobox with checkbox)
   bool              AddCheckComboBoxElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the text label table elements
   bool              AddLabelsTableElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the edit box table elements
   bool              AddTableElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the rendered table elements
   bool              AddCanvasTableElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the tabs in the private array
   bool              AddTabsElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the icon tabs in the private array
   bool              AddIconTabsElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the calendar controls
   bool              AddCalendarElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the drop down calendar controls 
   bool              AddDropCalendarElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the tree view controls
   bool              AddTreeViewListsElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the tree view controls
   bool              AddFileNavigatorElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the color picker controls
   bool              AddColorPickersElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the subchart controls
   bool              AddSubChartsElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the picture slider controls
   bool              AddPicturesSliderElements(const int window_index,CElementBase &object);
   //--- Stores pointers to the Time controls
   bool              AddTimeEditsElements(const int window_index,CElementBase &object);
   //--- Stores pointers to objects of the list of checkboxes
   bool              AddCheckBoxListElements(const int window_index,CElementBase &object);
   //--- Stores pointers to objects of the multiline text box
   bool              AddTextBoxElements(const int window_index,CElementBase &object);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CWndContainer::CWndContainer(void) : m_counter_element_id(0)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CWndContainer::~CWndContainer(void)
  {
  }
//+------------------------------------------------------------------+
//| The number of objects at the specified window index              |
//+------------------------------------------------------------------+
int CWndContainer::ObjectsElementsTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_objects) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of controls at the specified window index             |
//+------------------------------------------------------------------+
int CWndContainer::ElementsTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_elements) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of context menus at the specified window index        |
//+------------------------------------------------------------------+
int CWndContainer::ContextMenusTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_context_menus) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of main menus at the specified window index           |
//+------------------------------------------------------------------+
int CWndContainer::MenuBarsTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_menu_bars) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of tooltips at the specified window index             |
//+------------------------------------------------------------------+
int CWndContainer::TooltipsTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_tooltips) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of drop-down lists at the specified window index      |
//+------------------------------------------------------------------+
int CWndContainer::DropListsTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_drop_lists) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of scrollbars at the specified window index           |
//+------------------------------------------------------------------+
int CWndContainer::ScrollsTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_scrolls) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of text labels at the specified window index          |
//+------------------------------------------------------------------+
int CWndContainer::LabelsTablesTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_labels_tables) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of tables at the specified window index               |
//+------------------------------------------------------------------+
int CWndContainer::TablesTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_tables) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of rendered tables at the specified window index      |
//+------------------------------------------------------------------+
int CWndContainer::CanvasTablesTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_canvas_tables) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of tab groups at the specified window index           |
//+------------------------------------------------------------------+
int CWndContainer::TabsTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_tabs) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of tab groups at the specified window index           |
//+------------------------------------------------------------------+
int CWndContainer::IconTabsTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_icon_tabs) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of calendars at the specified window index            |
//+------------------------------------------------------------------+
int CWndContainer::CalendarsTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_calendars) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of drop-down calendars at the specified window index  |
//+------------------------------------------------------------------+
int CWndContainer::DropCalendarsTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_drop_calendars) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of tree views at the specified window index           |
//+------------------------------------------------------------------+
int CWndContainer::TreeViewListsTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_treeview_lists) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of file navigators at the specified window index      |
//+------------------------------------------------------------------+
int CWndContainer::FileNavigatorsTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_file_navigators) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of subcharts at the specified window index            |
//+------------------------------------------------------------------+
int CWndContainer::SubChartsTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_sub_charts) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of picture sliders at the specified window index      |
//+------------------------------------------------------------------+
int CWndContainer::PicturesSliderTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_pictures_slider) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of the Time controls                                  |
//+------------------------------------------------------------------+
int CWndContainer::TimeEditsTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_time_edits) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| The number of Multiline Text box controls                        |
//+------------------------------------------------------------------+
int CWndContainer::TextBoxesTotal(const int window_index)
  {
   int index=CheckOutOfRange(window_index);
   return((index!=WRONG_VALUE)? ::ArraySize(m_wnd[index].m_text_boxes) : WRONG_VALUE);
  }
//+------------------------------------------------------------------+
//| Adds the window pointer to the base of the interface elements    |
//+------------------------------------------------------------------+
void CWndContainer::AddWindow(CWindow &object)
  {
   int windows_total=::ArraySize(m_windows);
//--- If there are not any windows, zero the control counter
   if(windows_total<1)
      m_counter_element_id=0;
//--- Add pointer to the window array
   ::ArrayResize(m_wnd,windows_total+1);
   ::ArrayResize(m_windows,windows_total+1);
   m_windows[windows_total]=::GetPointer(object);
//--- Add pointer to the common array of controls
   int elements_total=::ArraySize(m_wnd[windows_total].m_elements);
   ::ArrayResize(m_wnd[windows_total].m_elements,elements_total+1);
   m_wnd[windows_total].m_elements[elements_total]=::GetPointer(object);
//--- Add element objects to the common array of objects
   AddToObjectsArray(windows_total,object);
//--- Set the identifier and store the id of the last element
   m_windows[windows_total].Id(m_counter_element_id);
   m_windows[windows_total].LastId(m_counter_element_id);
//--- Increase the counter of control identifiers
   m_counter_element_id++;
  }
//+------------------------------------------------------------------+
//| Adds the element object pointers to the common array             |
//+------------------------------------------------------------------+
template<typename T>
void CWndContainer::AddToObjectsArray(const int window_index,T &object)
  {
   int total=object.ObjectsElementTotal();
   for(int i=0; i<total; i++)
      AddToArray(window_index,object.Object(i));
//--- Store the mouse pointer in the base class of the control
   object.MousePointer(m_mouse);
  }
//+------------------------------------------------------------------+
//| Adds an object pointer to the array                              |
//+------------------------------------------------------------------+
void CWndContainer::AddToArray(const int window_index,CChartObject &object)
  {
   int size=::ArraySize(m_wnd[window_index].m_objects);
   ::ArrayResize(m_wnd[window_index].m_objects,size+1);
   m_wnd[window_index].m_objects[size]=::GetPointer(object);
  }
//+------------------------------------------------------------------+
//| Adds a pointer to the element array                              |
//+------------------------------------------------------------------+
void CWndContainer::AddToElementsArray(const int window_index,CElementBase &object)
  {
//--- If the base does not contain forms for controls
   if(::ArraySize(m_windows)<1)
     {
      ::Print(__FUNCTION__," > Before creating a control, create a form "
              "and add it to the base using the CWndContainer::AddWindow(CWindow &object) method.");
      return;
     }
//--- If the request is for a non-existent form
   if(window_index>=::ArraySize(m_windows))
     {
      ::Print(PREVENTING_OUT_OF_RANGE," window_index: ",window_index,"; ArraySize(m_windows): ",::ArraySize(m_windows));
      return;
     }
//--- Add to the common array of elements
   int size=::ArraySize(m_wnd[window_index].m_elements);
   ::ArrayResize(m_wnd[window_index].m_elements,size+1);
   m_wnd[window_index].m_elements[size]=::GetPointer(object);
//--- Update the position of objects
   object.Moving(m_windows[window_index].X(),m_windows[window_index].Y(),true);
//--- Add element objects to the common array of objects
   AddToObjectsArray(window_index,object);
//--- Store the id of the last element in all forms
   int windows_total=::ArraySize(m_windows);
   for(int w=0; w<windows_total; w++)
      m_windows[w].LastId(m_counter_element_id);
//--- Increase the counter of control identifiers
   m_counter_element_id++;
//--- Stores pointers to the context menu objects
   if(AddContextMenuElements(window_index,object))
      return;
//--- Stores pointers to the main menu objects
   if(AddMenuBarElements(window_index,object))
      return;
//--- Stores pointers to the split button objects 
   if(AddSplitButtonElements(window_index,object))
      return;
//--- Stores pointers to the tooltip objects 
   if(AddTooltipElements(window_index,object))
      return;
//--- Stores pointers to the list view objects in the base
   if(AddListViewElements(window_index,object))
      return;
//--- Stores pointers to the combobox control objects 
   if(AddComboBoxElements(window_index,object))
      return;
//--- Stores pointers to the combobox with a checkbox control objects 
   if(AddCheckComboBoxElements(window_index,object))
      return;
//--- Stores pointers to the text label table elements
   if(AddLabelsTableElements(window_index,object))
      return;
//--- Stores pointers to the edit box table elements
   if(AddTableElements(window_index,object))
      return;
//--- Stores pointers to the rendered table elements
   if(AddCanvasTableElements(window_index,object))
      return;
//--- Stores pointers to the tabs in the private array
   if(AddTabsElements(window_index,object))
      return;
//--- Stores pointers to the icon tabs in the private array
   if(AddIconTabsElements(window_index,object))
      return;
//--- Stores pointers to the calendar controls
   if(AddCalendarElements(window_index,object))
      return;
//--- Stores pointers to the drop down calendar controls 
   if(AddDropCalendarElements(window_index,object))
      return;
//--- Stores pointers to the tree view controls
   if(AddTreeViewListsElements(window_index,object))
      return;
//--- Stores pointers to the file navigator controls
   if(AddFileNavigatorElements(window_index,object))
      return;
//--- Stores pointers to the color picker controls
   if(AddColorPickersElements(window_index,object))
      return;
//--- Stores pointers to the subchart controls
   if(AddSubChartsElements(window_index,object))
      return;
//--- Stores pointers to the picture slider controls
   if(AddPicturesSliderElements(window_index,object))
      return;
//--- Stores pointers to the Time controls
   if(AddTimeEditsElements(window_index,object))
      return;
//--- Stores pointers to controls of the list of checkboxes
   if(AddCheckBoxListElements(window_index,object))
      return;
//--- Stores pointers to controls of the multiline text box
   if(AddTextBoxElements(window_index,object))
      return;
  }
//+------------------------------------------------------------------+
//| Adjustment of window index in case the range has been exceeded   |
//+------------------------------------------------------------------+
int CWndContainer::CheckOutOfRange(const int window_index)
  {
   int array_size=::ArraySize(m_wnd);
   if(array_size<1)
     {
      ::Print(PREVENTING_OUT_OF_RANGE);
      return(WRONG_VALUE);
     }
//--- Adjustment in case the range has been exceeded
   int index=(window_index>=array_size)? array_size-1 : window_index;
//--- Return the window index
   return(index);
  }
//+------------------------------------------------------------------+
//| Stores the pointers to the context menu objects in the base      |
//+------------------------------------------------------------------+
bool CWndContainer::AddContextMenuElements(const int window_index,CElementBase &object)
  {
//--- Leave, if this is not a context menu
   if(dynamic_cast<CContextMenu *>(&object)==NULL)
      return(false);
//--- Get the context menu pointer
   CContextMenu *cm=::GetPointer(object);
//--- Store the pointers to its objects in the base
   int items_total=cm.ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      //--- Increasing the element array
      int size=::ArraySize(m_wnd[window_index].m_elements);
      ::ArrayResize(m_wnd[window_index].m_elements,size+1);
      //--- Getting the menu item pointer
      CMenuItem *mi=cm.ItemPointerByIndex(i);
      //--- Store the pointer in the array
      m_wnd[window_index].m_elements[size]=mi;
      //--- Add the pointers to all menu item objects to the common array
      AddToObjectsArray(window_index,mi);
     }
//--- Add the pointer to the private array
   AddToRefArray(cm,m_wnd[window_index].m_context_menus);
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores the pointers to the main menu objects in the base         |
//+------------------------------------------------------------------+
bool CWndContainer::AddMenuBarElements(const int window_index,CElementBase &object)
  {
//--- Leave, if this is not the main menu
   if(dynamic_cast<CMenuBar *>(&object)==NULL)
      return(false);
//--- Get the main menu pointer
   CMenuBar *mb=::GetPointer(object);
//--- Store the pointers to its objects in the base
   int items_total=mb.ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      //--- Increasing the element array
      int size=::ArraySize(m_wnd[window_index].m_elements);
      ::ArrayResize(m_wnd[window_index].m_elements,size+1);
      //--- Getting the menu item pointer
      CMenuItem *mi=mb.ItemPointerByIndex(i);
      //--- Store the pointer in the array
      m_wnd[window_index].m_elements[size]=mi;
      //--- Add the pointers to all menu item objects to the common array
      AddToObjectsArray(window_index,mi);
     }
//--- Add the pointer to the private array
   AddToRefArray(mb,m_wnd[window_index].m_menu_bars);
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores the pointers to the elements of a split button in the base|
//+------------------------------------------------------------------+
bool CWndContainer::AddSplitButtonElements(const int window_index,CElementBase &object)
  {
//--- Leave, if this is not a split button
   if(dynamic_cast<CSplitButton *>(&object)==NULL)
      return(false);
//--- Get the split button pointer
   CSplitButton *sb=::GetPointer(object);
//--- Increasing the element array
   int size=::ArraySize(m_wnd[window_index].m_elements);
   ::ArrayResize(m_wnd[window_index].m_elements,size+1);
//--- Getting the context menu pointer
   CContextMenu *cm=sb.GetContextMenuPointer();
//--- Store the element and objects in the base
   m_wnd[window_index].m_elements[size]=cm;
   AddToObjectsArray(window_index,cm);
//--- Store the pointers to its objects in the base
   int items_total=cm.ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      //--- Increasing the element array
      size=::ArraySize(m_wnd[window_index].m_elements);
      ::ArrayResize(m_wnd[window_index].m_elements,size+1);
      //--- Getting the menu item pointer
      CMenuItem *mi=cm.ItemPointerByIndex(i);
      //--- Store the pointer in the array
      m_wnd[window_index].m_elements[size]=mi;
      //--- Add the pointers to all menu item objects to the common array
      AddToObjectsArray(window_index,mi);
     }
//--- Add the pointer to the private array
   AddToRefArray(cm,m_wnd[window_index].m_context_menus);
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores the tooltip pointer in the private array                  |
//+------------------------------------------------------------------+
bool CWndContainer::AddTooltipElements(const int window_index,CElementBase &object)
  {
//--- Leave, if this is not a tooltip
   if(dynamic_cast<CTooltip *>(&object)==NULL)
      return(false);
//--- Get the tooltip pointer
   CTooltip *t=::GetPointer(object);
//--- Add the pointer to the private array
   AddToRefArray(t,m_wnd[window_index].m_tooltips);
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores the pointers to the list view objects in the base         |
//+------------------------------------------------------------------+
bool CWndContainer::AddListViewElements(const int window_index,CElementBase &object)
  {
//--- Leave, if this is not a list view
   if(dynamic_cast<CListView *>(&object)==NULL)
      return(false);
//--- Get the list view pointer
   CListView *lv=::GetPointer(object);
//--- Increasing the element array
   int size=::ArraySize(m_wnd[window_index].m_elements);
   ::ArrayResize(m_wnd[window_index].m_elements,size+1);
//--- Get the scrollbar pointer
   CScrollV *sv=lv.GetScrollVPointer();
//--- Store the element in the base
   m_wnd[window_index].m_elements[size]=sv;
   AddToObjectsArray(window_index,sv);
//--- Add the pointer to the private array
   AddToRefArray(sv,m_wnd[window_index].m_scrolls);
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores the pointer to the drop-down list view in a private array |
//| (combobox)                                                       |
//+------------------------------------------------------------------+
bool CWndContainer::AddComboBoxElements(const int window_index,CElementBase &object)
  {
//--- Leave, if this is not a combobox
   if(dynamic_cast<CComboBox *>(&object)==NULL)
      return(false);
//--- Get the combobox pointer
   CComboBox *cb=::GetPointer(object);
//---
   for(int i=0; i<2; i++)
     {
      //--- Increasing the element array
      int size=::ArraySize(m_wnd[window_index].m_elements);
      ::ArrayResize(m_wnd[window_index].m_elements,size+1);
      //--- Add the list to the base
      if(i==0)
        {
         CListView *lv=cb.GetListViewPointer();
         m_wnd[window_index].m_elements[size]=lv;
         AddToObjectsArray(window_index,lv);
         //--- Add the pointer to the private array
         AddToRefArray(lv,m_wnd[window_index].m_drop_lists);
        }
      //--- Add the scrollbar to the base
      else if(i==1)
        {
         CScrollV *sv=cb.GetScrollVPointer();
         m_wnd[window_index].m_elements[size]=sv;
         AddToObjectsArray(window_index,sv);
         //--- Add the pointer to the private array
         AddToRefArray(sv,m_wnd[window_index].m_scrolls);
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores the pointer to the drop-down list view in a private array |
//| (combobox with checkbox)                                         |
//+------------------------------------------------------------------+
bool CWndContainer::AddCheckComboBoxElements(const int window_index,CElementBase &object)
  {
//--- Leave, if this is not a combobox with checkbox
   if(dynamic_cast<CCheckComboBox *>(&object)==NULL)
      return(false);
//--- Get the pointer to the drop-down list view
   CCheckComboBox *ccb=::GetPointer(object);
//---
   for(int i=0; i<2; i++)
     {
      int size=::ArraySize(m_wnd[window_index].m_elements);
      ::ArrayResize(m_wnd[window_index].m_elements,size+1);
      if(i==0)
        {
         CListView *lv=ccb.GetListViewPointer();
         m_wnd[window_index].m_elements[size]=lv;
         AddToObjectsArray(window_index,lv);
         //--- Add the pointer to the private array
         AddToRefArray(lv,m_wnd[window_index].m_drop_lists);
        }
      else if(i==1)
        {
         CScrollV *sv=ccb.GetScrollVPointer();
         m_wnd[window_index].m_elements[size]=sv;
         AddToObjectsArray(window_index,sv);
         //--- Add the pointer to the private array
         AddToRefArray(sv,m_wnd[window_index].m_scrolls);
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Store the pointers to the text label table elements              |
//+------------------------------------------------------------------+
bool CWndContainer::AddLabelsTableElements(const int window_index,CElementBase &object)
  {
//--- Leave, if it is not a text label table
   if(dynamic_cast<CLabelsTable *>(&object)==NULL)
      return(false);
//--- Get the pointer to the text label table
   CLabelsTable *lt=::GetPointer(object);
   for(int i=0; i<2; i++)
     {
      int size=::ArraySize(m_wnd[window_index].m_elements);
      ::ArrayResize(m_wnd[window_index].m_elements,size+1);
      if(i==0)
        {
         //--- Get the scrollbar pointer
         CScrollV *sv=lt.GetScrollVPointer();
         m_wnd[window_index].m_elements[size]=sv;
         AddToObjectsArray(window_index,sv);
         //--- Add the pointer to the private array
         AddToRefArray(sv,m_wnd[window_index].m_scrolls);
        }
      else if(i==1)
        {
         CScrollH *sh=lt.GetScrollHPointer();
         m_wnd[window_index].m_elements[size]=sh;
         AddToObjectsArray(window_index,sh);
         //--- Add the pointer to the private array
         AddToRefArray(sh,m_wnd[window_index].m_scrolls);
        }
     }
//--- Add the pointer to the private array
   AddToRefArray(lt,m_wnd[window_index].m_labels_tables);
   return(true);
  }
//+------------------------------------------------------------------+
//| Store pointers to the edit box table elements                    |
//+------------------------------------------------------------------+
bool CWndContainer::AddTableElements(const int window_index,CElementBase &object)
  {
//--- Leave, if it is not a text label table
   if(dynamic_cast<CTable *>(&object)==NULL)
      return(false);
//--- Get the pointer to the text label table
   CTable *te=::GetPointer(object);
   for(int i=0; i<2; i++)
     {
      int size=::ArraySize(m_wnd[window_index].m_elements);
      ::ArrayResize(m_wnd[window_index].m_elements,size+1);
      if(i==0)
        {
         //--- Get the scrollbar pointer
         CScrollV *sv=te.GetScrollVPointer();
         m_wnd[window_index].m_elements[size]=sv;
         AddToObjectsArray(window_index,sv);
         //--- Add the pointer to the private array
         AddToRefArray(sv,m_wnd[window_index].m_scrolls);
        }
      else if(i==1)
        {
         CScrollH *sh=te.GetScrollHPointer();
         m_wnd[window_index].m_elements[size]=sh;
         AddToObjectsArray(window_index,sh);
         //--- Add the pointer to the private array
         AddToRefArray(sh,m_wnd[window_index].m_scrolls);
        }
     }
//--- Add the pointer to the private array
   AddToRefArray(te,m_wnd[window_index].m_tables);
   return(true);
  }
//+------------------------------------------------------------------+
//| Store the pointers to the rendered table elements                |
//+------------------------------------------------------------------+
bool CWndContainer::AddCanvasTableElements(const int window_index,CElementBase &object)
  {
//--- Leave, if it is not a rendered table
   if(dynamic_cast<CCanvasTable *>(&object)==NULL)
      return(false);
//--- Get the pointer to the rendered table
   CCanvasTable *ct=::GetPointer(object);
   for(int i=0; i<2; i++)
     {
      int size=::ArraySize(m_wnd[window_index].m_elements);
      ::ArrayResize(m_wnd[window_index].m_elements,size+1);
      if(i==0)
        {
         //--- Get the scrollbar pointer
         CScrollV *sv=ct.GetScrollVPointer();
         m_wnd[window_index].m_elements[size]=sv;
         AddToObjectsArray(window_index,sv);
         //--- Add the pointer to the private array
         AddToRefArray(sv,m_wnd[window_index].m_scrolls);
        }
      else if(i==1)
        {
         CScrollH *sh=ct.GetScrollHPointer();
         m_wnd[window_index].m_elements[size]=sh;
         AddToObjectsArray(window_index,sh);
         //--- Add the pointer to the private array
         AddToRefArray(sh,m_wnd[window_index].m_scrolls);
        }
     }
//--- Add the pointer to the private array
   AddToRefArray(ct,m_wnd[window_index].m_canvas_tables);
   return(true);
  }
//+------------------------------------------------------------------+
//| Store pointers to the tabs in the private array                  |
//+------------------------------------------------------------------+
bool CWndContainer::AddTabsElements(const int window_index,CElementBase &object)
  {
//--- Leave, if these are not tabs
   if(dynamic_cast<CTabs *>(&object)==NULL)
      return(false);
//--- Get the pointer to the Tabs control
   CTabs *tabs=::GetPointer(object);
//--- Add the pointer to the private array
   AddToRefArray(tabs,m_wnd[window_index].m_tabs);
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores pointers to the icon tabs in the private array            |
//+------------------------------------------------------------------+
bool CWndContainer::AddIconTabsElements(const int window_index,CElementBase &object)
  {
//--- Leave, if these are not tabs
   if(object.ClassName()!="CIconTabs")
      return(false);
//--- Get the pointer to the Tabs control
   CIconTabs *icon_tabs=::GetPointer(object);
//--- Add the pointer to the private array
   AddToRefArray(icon_tabs,m_wnd[window_index].m_icon_tabs);
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores the pointers to the calendar objects in the base          |
//+------------------------------------------------------------------+
bool CWndContainer::AddCalendarElements(const int window_index,CElementBase &object)
  {
//--- Leave, if this is not a calendar
   if(dynamic_cast<CCalendar *>(&object)==NULL)
      return(false);
//--- Get the pointer to the Calendar control
   CCalendar *cal=::GetPointer(object);
//---
   for(int i=0; i<5; i++)
     {
      int size=::ArraySize(m_wnd[window_index].m_elements);
      ::ArrayResize(m_wnd[window_index].m_elements,size+1);
      //---
      switch(i)
        {
         case 0 :
           {
            CComboBox *cb=cal.GetComboBoxPointer();
            m_wnd[window_index].m_elements[size]=cb;
            AddToObjectsArray(window_index,cb);
            break;
           }
         case 1 :
           {
            CSpinEdit *se=cal.GetSpinEditPointer();
            m_wnd[window_index].m_elements[size]=se;
            AddToObjectsArray(window_index,se);
            break;
           }
         case 2 :
           {
            CListView *lv=cal.GetListViewPointer();
            m_wnd[window_index].m_elements[size]=lv;
            AddToObjectsArray(window_index,lv);
            break;
           }
         case 3 :
           {
            CScrollV *sv=cal.GetScrollVPointer();
            m_wnd[window_index].m_elements[size]=sv;
            AddToObjectsArray(window_index,sv);
            //--- Add the pointer to the private array
            AddToRefArray(sv,m_wnd[window_index].m_scrolls);
            break;
           }
         case 4 :
           {
            CIconButton *ib=cal.GetIconButtonPointer();
            m_wnd[window_index].m_elements[size]=ib;
            AddToObjectsArray(window_index,ib);
            break;
           }
        }
     }
//--- Add the pointer to the private array
   AddToRefArray(cal,m_wnd[window_index].m_calendars);
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores pointers to drop down calendar objects in the base        |
//+------------------------------------------------------------------+
bool CWndContainer::AddDropCalendarElements(const int window_index,CElementBase &object)
  {
//--- Leave, if this is not a drop-down calendar
   if(dynamic_cast<CDropCalendar *>(&object)==NULL)
      return(false);
//--- Get the pointer to the Drop Down Calendar control
   CDropCalendar *dc=::GetPointer(object);
//--- Add the pointer to the private array
   AddToRefArray(dc,m_wnd[window_index].m_drop_calendars);
//--- Get the pointer to the Calendar control
   CCalendar *cal=dc.GetCalendarPointer();
//--- Increasing the element array
   int size=::ArraySize(m_wnd[window_index].m_elements);
   ::ArrayResize(m_wnd[window_index].m_elements,size+1);
//--- Store the element and objects in the base
   m_wnd[window_index].m_elements[size]=cal;
   AddToObjectsArray(window_index,cal);
//---
   for(int i=0; i<5; i++)
     {
      size=::ArraySize(m_wnd[window_index].m_elements);
      ::ArrayResize(m_wnd[window_index].m_elements,size+1);
      //---
      switch(i)
        {
         case 0 :
           {
            CComboBox *cb=cal.GetComboBoxPointer();
            m_wnd[window_index].m_elements[size]=cb;
            AddToObjectsArray(window_index,cb);
            break;
           }
         case 1 :
           {
            CSpinEdit *se=cal.GetSpinEditPointer();
            m_wnd[window_index].m_elements[size]=se;
            AddToObjectsArray(window_index,se);
            break;
           }
         case 2 :
           {
            CListView *lv=cal.GetListViewPointer();
            m_wnd[window_index].m_elements[size]=lv;
            AddToObjectsArray(window_index,lv);
            break;
           }
         case 3 :
           {
            CScrollV *sv=cal.GetScrollVPointer();
            m_wnd[window_index].m_elements[size]=sv;
            AddToObjectsArray(window_index,sv);
            //--- Add the pointer to the private array
            AddToRefArray(sv,m_wnd[window_index].m_scrolls);
            break;
           }
         case 4 :
           {
            CIconButton *ib=cal.GetIconButtonPointer();
            m_wnd[window_index].m_elements[size]=ib;
            AddToObjectsArray(window_index,ib);
            break;
           }
        }
     }
//--- Add the pointer to the private array
   AddToRefArray(cal,m_wnd[window_index].m_calendars);
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores pointers to the tree view controls                        |
//+------------------------------------------------------------------+
bool CWndContainer::AddTreeViewListsElements(const int window_index,CElementBase &object)
  {
//--- Leave, if this is not a tree view
   if(dynamic_cast<CTreeView *>(&object)==NULL)
      return(false);
//--- Get the pointer to the Tree View control
   CTreeView *tv=::GetPointer(object);
//--- Add the pointer to the private array
   AddToRefArray(tv,m_wnd[window_index].m_treeview_lists);
//--- Array size
   int size=0;
//---
   for(int i=0; i<4; i++)
     {
      if(i>1)
        {
         size=::ArraySize(m_wnd[window_index].m_elements);
         ::ArrayResize(m_wnd[window_index].m_elements,size+1);
        }
      //---
      switch(i)
        {
         case 0 :
           {
            for(int j=0; j<tv.ItemsTotal(); j++)
              {
               size=::ArraySize(m_wnd[window_index].m_elements);
               ::ArrayResize(m_wnd[window_index].m_elements,size+1);
               CTreeItem *ti=tv.ItemPointer(j);
               m_wnd[window_index].m_elements[size]=ti;
               AddToObjectsArray(window_index,ti);
              }
            break;
           }
         case 1 :
           {
            for(int j=0; j<tv.ContentItemsTotal(); j++)
              {
               size=::ArraySize(m_wnd[window_index].m_elements);
               ::ArrayResize(m_wnd[window_index].m_elements,size+1);
               CTreeItem *ti=tv.ContentItemPointer(j);
               m_wnd[window_index].m_elements[size]=ti;
               AddToObjectsArray(window_index,ti);
              }
            break;
           }
         case 2 :
           {
            //--- List scrollbars
            CScrollV *sv=tv.GetScrollVPointer();
            m_wnd[window_index].m_elements[size]=sv;
            AddToObjectsArray(window_index,sv);
            //--- Add the pointer to the private array
            AddToRefArray(sv,m_wnd[window_index].m_scrolls);
            break;
           }
         case 3 :
           {
            CScrollV *csv=tv.GetContentScrollVPointer();
            m_wnd[window_index].m_elements[size]=csv;
            AddToObjectsArray(window_index,csv);
            //--- Add the pointer to the private array
            AddToRefArray(csv,m_wnd[window_index].m_scrolls);
            break;
           }
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores pointers to the file navigator controls                   |
//+------------------------------------------------------------------+
bool CWndContainer::AddFileNavigatorElements(const int window_index,CElementBase &object)
  {
//--- Leave, if this is not a file navigator
   if(dynamic_cast<CFileNavigator *>(&object)==NULL)
      return(false);
//--- Get the pointer to the File Navigator control
   CFileNavigator *fn=::GetPointer(object);
//--- Add the pointer to the private array
   AddToRefArray(fn,m_wnd[window_index].m_file_navigators);
//--- Store pointer to the tree view
   int size=::ArraySize(m_wnd[window_index].m_elements);
   ::ArrayResize(m_wnd[window_index].m_elements,size+1);
   CTreeView *tv=fn.TreeViewPointer();
   m_wnd[window_index].m_elements[size]=tv;
   AddToObjectsArray(window_index,tv);
//--- Add the pointer to the private array
   AddToRefArray(tv,m_wnd[window_index].m_treeview_lists);
//---
   for(int i=0; i<4; i++)
     {
      if(i>1)
        {
         size=::ArraySize(m_wnd[window_index].m_elements);
         ::ArrayResize(m_wnd[window_index].m_elements,size+1);
        }
      //---
      switch(i)
        {
         case 0 :
           {
            //--- Add tree view items
            for(int j=0; j<tv.ItemsTotal(); j++)
              {
               size=::ArraySize(m_wnd[window_index].m_elements);
               ::ArrayResize(m_wnd[window_index].m_elements,size+1);
               CTreeItem *ti=tv.ItemPointer(j);
               m_wnd[window_index].m_elements[size]=ti;
               AddToObjectsArray(window_index,ti);
              }
            break;
           }
         case 1 :
           {
            //--- Add content list items
            for(int j=0; j<tv.ContentItemsTotal(); j++)
              {
               size=::ArraySize(m_wnd[window_index].m_elements);
               ::ArrayResize(m_wnd[window_index].m_elements,size+1);
               CTreeItem *ti=tv.ContentItemPointer(j);
               m_wnd[window_index].m_elements[size]=ti;
               AddToObjectsArray(window_index,ti);
              }
            break;
           }
         case 2 :
           {
            //--- List scrollbars
            CScrollV *sv=tv.GetScrollVPointer();
            m_wnd[window_index].m_elements[size]=sv;
            AddToObjectsArray(window_index,sv);
            //--- Add the pointer to the private array
            AddToRefArray(sv,m_wnd[window_index].m_scrolls);
            break;
           }
         case 3 :
           {
            CScrollV *csv=tv.GetContentScrollVPointer();
            m_wnd[window_index].m_elements[size]=csv;
            AddToObjectsArray(window_index,csv);
            //--- Add the pointer to the private array
            AddToRefArray(csv,m_wnd[window_index].m_scrolls);
            break;
           }
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores pointers to the color picker controls                     |
//+------------------------------------------------------------------+
bool CWndContainer::AddColorPickersElements(const int window_index,CElementBase &object)
  {
//--- Leave, if this is not a Leave, if this is not a tree view
   if(dynamic_cast<CColorPicker *>(&object)==NULL)
      return(false);
//--- Get the pointer to the control
   CColorPicker *cp=::GetPointer(object);
//---
   for(int i=0; i<12; i++)
     {
      int size=::ArraySize(m_wnd[window_index].m_elements);
      ::ArrayResize(m_wnd[window_index].m_elements,size+1);
      //---
      switch(i)
        {
         //--- Add the group of radio buttons to the common array
         case 0 :
           {
            CRadioButtons *rb=cp.GetRadioButtonsHslPointer();
            m_wnd[window_index].m_elements[size]=rb;
            AddToObjectsArray(window_index,rb);
            break;
           }
         //--- Add the group of edit boxes (1 - 9) to the common array 
         case 1 :
           {
            CSpinEdit *se1=cp.GetSpinEditHslHPointer();
            m_wnd[window_index].m_elements[size]=se1;
            AddToObjectsArray(window_index,se1);
            break;
           }
         case 2 :
           {
            CSpinEdit *se2=cp.GetSpinEditHslSPointer();
            m_wnd[window_index].m_elements[size]=se2;
            AddToObjectsArray(window_index,se2);
            break;
           }
         case 3 :
           {
            CSpinEdit *se3=cp.GetSpinEditHslLPointer();
            m_wnd[window_index].m_elements[size]=se3;
            AddToObjectsArray(window_index,se3);
            break;
           }
         case 4 :
           {
            CSpinEdit *se4=cp.GetSpinEditRgbRPointer();
            m_wnd[window_index].m_elements[size]=se4;
            AddToObjectsArray(window_index,se4);
            break;
           }
         case 5 :
           {
            CSpinEdit *se5=cp.GetSpinEditRgbGPointer();
            m_wnd[window_index].m_elements[size]=se5;
            AddToObjectsArray(window_index,se5);
            break;
           }
         case 6 :
           {
            CSpinEdit *se6=cp.GetSpinEditRgbBPointer();
            m_wnd[window_index].m_elements[size]=se6;
            AddToObjectsArray(window_index,se6);
            break;
           }
         case 7 :
           {
            CSpinEdit *se7=cp.GetSpinEditLabLPointer();
            m_wnd[window_index].m_elements[size]=se7;
            AddToObjectsArray(window_index,se7);
            break;
           }
         case 8 :
           {
            CSpinEdit *se8=cp.GetSpinEditLabAPointer();
            m_wnd[window_index].m_elements[size]=se8;
            AddToObjectsArray(window_index,se8);
            break;
           }
         case 9 :
           {
            CSpinEdit *se9=cp.GetSpinEditLabBPointer();
            m_wnd[window_index].m_elements[size]=se9;
            AddToObjectsArray(window_index,se9);
            break;
           }
         //--- Add the 'OK' and 'Cancel' buttons (10 - 11) to the common array
         case 10 :
           {
            CSimpleButton *sb1=cp.GetSimpleButtonOKPointer();
            m_wnd[window_index].m_elements[size]=sb1;
            AddToObjectsArray(window_index,sb1);
            break;
           }
         case 11 :
           {
            CSimpleButton *sb2=cp.GetSimpleButtonCancelPointer();
            m_wnd[window_index].m_elements[size]=sb2;
            AddToObjectsArray(window_index,sb2);
            break;
           }
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores the pointer to the subcharts in a private array           |
//+------------------------------------------------------------------+
bool CWndContainer::AddSubChartsElements(const int window_index,CElementBase &object)
  {
//--- Leave, if this is not a standard chart
   if(dynamic_cast<CStandardChart *>(&object)==NULL)
      return(false);
//--- Get the pointer to the standard chart
   CStandardChart *sc=::GetPointer(object);
//--- Add the pointer to the private array
   AddToRefArray(sc,m_wnd[window_index].m_sub_charts);
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores the pointer to the picture sliders in a private array     |
//+------------------------------------------------------------------+
bool CWndContainer::AddPicturesSliderElements(const int window_index,CElementBase &object)
  {
//--- Leave, if this is not a picture slider
   if(dynamic_cast<CPicturesSlider *>(&object)==NULL)
      return(false);
//--- Get the pointer to the picture slider
   CPicturesSlider *ps=::GetPointer(object);
   for(int i=0; i<3; i++)
     {
      int size=::ArraySize(m_wnd[window_index].m_elements);
      ::ArrayResize(m_wnd[window_index].m_elements,size+1);
      if(i==0)
        {
         //--- Get the radio button pointer
         CRadioButtons *rb=ps.GetRadioButtonsPointer();
         m_wnd[window_index].m_elements[size]=rb;
         AddToObjectsArray(window_index,rb);
        }
      else
        {
         //--- Get the button pointer
         CIconButton *ib=(i<2)? ps.GetLeftArrowPointer() : ps.GetRightArrowPointer();
         m_wnd[window_index].m_elements[size]=ib;
         AddToObjectsArray(window_index,ib);
        }
     }
//--- Add the pointer to the private array
   AddToRefArray(ps,m_wnd[window_index].m_pictures_slider);
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores the pointer to the Time controls in a private array       |
//+------------------------------------------------------------------+
bool CWndContainer::AddTimeEditsElements(const int window_index,CElementBase &object)
  {
//--- Leave, if this is not a Time control
   if(dynamic_cast<CTimeEdit *>(&object)==NULL)
      return(false);
//--- Get the pointer to the Time control
   CTimeEdit *te=::GetPointer(object);
   for(int i=0; i<2; i++)
     {
      int size=::ArraySize(m_wnd[window_index].m_elements);
      ::ArrayResize(m_wnd[window_index].m_elements,size+1);
      if(i==0)
        {
         //--- Get the pointer to the edit box for hours
         CSpinEdit *se=te.GetHoursEditPointer();
         m_wnd[window_index].m_elements[size]=se;
         AddToObjectsArray(window_index,se);
        }
      else
        {
         //--- Get the pointer to the edit box for minutes
         CSpinEdit *se=te.GetMinutesEditPointer();
         m_wnd[window_index].m_elements[size]=se;
         AddToObjectsArray(window_index,se);
        }
     }
//--- Add the pointer to the private array
   AddToRefArray(te,m_wnd[window_index].m_time_edits);
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores pointers to objects of list of checkboxes in the base     |
//+------------------------------------------------------------------+
bool CWndContainer::AddCheckBoxListElements(const int window_index,CElementBase &object)
  {
//--- Leave, if this is not a list of checkboxes
   if(dynamic_cast<CCheckBoxList *>(&object)==NULL)
      return(false);
//--- Get the list view pointer
   CCheckBoxList *cbl=::GetPointer(object);
//--- Increasing the element array
   int size=::ArraySize(m_wnd[window_index].m_elements);
   ::ArrayResize(m_wnd[window_index].m_elements,size+1);
//--- Get the scrollbar pointer
   CScrollV *sv=cbl.GetScrollVPointer();
//--- Store the element in the base
   m_wnd[window_index].m_elements[size]=sv;
   AddToObjectsArray(window_index,sv);
//--- Add the pointer to the private array
   AddToRefArray(sv,m_wnd[window_index].m_scrolls);
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores pointers to objects of the multiline text box             |
//+------------------------------------------------------------------+
bool CWndContainer::AddTextBoxElements(const int window_index,CElementBase &object)
  {
//--- Leave, if this is not a multiline text box
   if(dynamic_cast<CTextBox *>(&object)==NULL)
      return(false);
//--- Get the pointer to the control
   CTextBox *tb=::GetPointer(object);
   for(int i=0; i<2; i++)
     {
      int size=::ArraySize(m_wnd[window_index].m_elements);
      ::ArrayResize(m_wnd[window_index].m_elements,size+1);
      if(i==0)
        {
         //--- Get the scrollbar pointer
         CScrollV *sv=tb.GetScrollVPointer();
         m_wnd[window_index].m_elements[size]=sv;
         AddToObjectsArray(window_index,sv);
         //--- Add the pointer to the private array
         AddToRefArray(sv,m_wnd[window_index].m_scrolls);
        }
      else if(i==1)
        {
         CScrollH *sh=tb.GetScrollHPointer();
         m_wnd[window_index].m_elements[size]=sh;
         AddToObjectsArray(window_index,sh);
         //--- Add the pointer to the private array
         AddToRefArray(sh,m_wnd[window_index].m_scrolls);
        }
     }
//--- Add the pointer to the private array
   AddToRefArray(tb,m_wnd[window_index].m_text_boxes);
   return(true);
  }
//+------------------------------------------------------------------+
//| Stores the pointer (T1) in the array passed by the link (T2)     |
//+------------------------------------------------------------------+
template<typename T1,typename T2>
void CWndContainer::AddToRefArray(T1 &object,T2 &array[])
  {
   int size=::ArraySize(array);
   ::ArrayResize(array,size+1);
   array[size]=object;
  }
//+------------------------------------------------------------------+
//| Fills arrays with objects by types                               |
//+------------------------------------------------------------------+
void CWndContainer::PrintElementsTotal(void)
  {
   if(::ArraySize(m_wnd)<1)
     {
      ::Print(__FUNCTION__," > Before filling arrays with objects, it is necessary to add the main window.");
      return;
     }
//---
   int window_total=::ArraySize(m_windows);
   if(window_total>0)
      ::Print("window_total: ",window_total);
//---
   for(int w=0; w<window_total; w++)
     {
      if(ObjectsElementsTotal(w)>0)
         ::Print("ObjectsElementsTotal("+string(w)+"): ",ObjectsElementsTotal(w));
      if(ElementsTotal(w)>0)
         ::Print("ElementsTotal("+string(w)+"): ",ElementsTotal(w));
      if(DropListsTotal(w)>0)
         ::Print("DropListsTotal("+string(w)+"): ",DropListsTotal(w));
      if(LabelsTablesTotal(w)>0)
         ::Print("LabelsTablesTotal("+string(w)+"): ",LabelsTablesTotal(w));
      if(TablesTotal(w)>0)
         ::Print("TablesTotal("+string(w)+"): ",TablesTotal(w));
      if(CanvasTablesTotal(w)>0)
         ::Print("CanvasTablesTotal("+string(w)+"): ",CanvasTablesTotal(w));
      if(TabsTotal(w)>0)
         ::Print("TabsTotal("+string(w)+"): ",TabsTotal(w));
      if(IconTabsTotal(w)>0)
         ::Print("IconTabsTotal("+string(w)+"): ",IconTabsTotal(w));
      if(ContextMenusTotal(w)>0)
         ::Print("ContextMenusTotal("+string(w)+"): ",ContextMenusTotal(w));
      if(MenuBarsTotal(w)>0)
         ::Print("MenuBarsTotal("+string(w)+"): ",MenuBarsTotal(w));
      if(CalendarsTotal(w)>0)
         ::Print("CalendarsTotal("+string(w)+"): ",CalendarsTotal(w));
      if(DropCalendarsTotal(w)>0)
         ::Print("DropCalendarsTotal("+string(w)+"): ",DropCalendarsTotal(w));
      if(ScrollsTotal(w)>0)
         ::Print("ScrollsTotal("+string(w)+"): ",ScrollsTotal(w));
      if(TreeViewListsTotal(w)>0)
         ::Print("TreeViewListsTotal("+string(w)+"): ",TreeViewListsTotal(w));
      if(FileNavigatorsTotal(w)>0)
         ::Print("FileNavigatorsTotal("+string(w)+"): ",FileNavigatorsTotal(w));
      if(SubChartsTotal(w)>0)
         ::Print("SubChartsTotal("+string(w)+"): ",SubChartsTotal(w));
      if(PicturesSliderTotal(w)>0)
         ::Print("PicturesSliderTotal("+string(w)+"): ",PicturesSliderTotal(w));
      if(TimeEditsTotal(w)>0)
         ::Print("TimeEditsTotal("+string(w)+"): ",TimeEditsTotal(w));
      if(TextBoxesTotal(w)>0)
         ::Print("TextBoxesTotal("+string(w)+"): ",TextBoxesTotal(w));
      //---
      ::Print("---");
     }
//---
   ::Print(__FUNCTION__," > m_counter_element_id: ",m_counter_element_id);
   ::Print("---");
  }
//+------------------------------------------------------------------+
