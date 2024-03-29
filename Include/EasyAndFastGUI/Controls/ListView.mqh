//+------------------------------------------------------------------+
//|                                                     ListView.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "Scrolls.mqh"
//+------------------------------------------------------------------+
//| Class for creating a list view                                   |
//+------------------------------------------------------------------+
class CListView : public CElement
  {
private:
   //--- Pointer to the element managing the list view visibility
   CElement         *m_combobox;
   //--- Objects for creating the list view
   CRectLabel        m_area;
   CEdit             m_items[];
   CScrollV          m_scrollv;
   //--- Array of the list view values
   string            m_item_value[];
   //--- Size of the list view and its visible part
   int               m_items_total;
   int               m_visible_items_total;
   //--- (1) Index and (2) the text of the highlighted item
   int               m_selected_item_index;
   string            m_selected_item_text;
   //--- Properties of the list view background
   int               m_area_zorder;
   color             m_area_border_color;
   //--- Properties of the list view items
   int               m_item_zorder;
   int               m_item_y_size;
   color             m_item_color;
   color             m_item_color_hover;
   color             m_item_color_selected;
   color             m_item_text_color;
   color             m_item_text_color_hover;
   color             m_item_text_color_selected;
   //--- Mode of alignment of the text in the list view
   ENUM_ALIGN_MODE   m_align_mode;
   //--- Mode of highlighting when the cursor is hovering over
   bool              m_lights_hover;
   //--- Timer counter for fast forwarding the list view
   int               m_timer_counter;
   //--- To determine the moment of mouse cursor transition from one item to another
   int               m_prev_item_index_focus;
   //---
public:
                     CListView(void);
                    ~CListView(void);
   //--- Methods for creating the list view
   bool              CreateListView(const long chart_id,const int subwin,const int x_gap,const int y_gap);
   //---
private:
   bool              CreateItem(const int index,const int x,const int y,const int width);
   bool              CreateArea(void);
   bool              CreateList(void);
   bool              CreateScrollV(void);
   //---
public:
   //--- (1) Stores pointer to the combobox, (2) returns pointer to the scrollbar
   void              ComboBoxPointer(CElement &object)                   { m_combobox=::GetPointer(object);   }
   CScrollV         *GetScrollVPointer(void)                             { return(::GetPointer(m_scrollv));   }
   //--- (1) Item height, returns (2) the size of the list view and (3) its visible part
   void              ItemYSize(const int y_size)                         { m_item_y_size=y_size;              }
   int               ItemsTotal(void)                              const { return(::ArraySize(m_item_value)); }
   int               VisibleItemsTotal(void)                       const { return(::ArraySize(m_items));      }
   //--- State of the scrollbar
   bool              ScrollState(void) const { return(m_scrollv.ScrollState()); }
   //--- (1) Background frame color, (2) mode of highlighting items when hovering, (3) text alignment mode
   void              AreaBorderColor(const color clr)                    { m_area_border_color=clr;           }
   void              LightsHover(const bool state)                       { m_lights_hover=state;              }
   void              TextAlign(const ENUM_ALIGN_MODE align_mode)         { m_align_mode=align_mode;           }
   //--- Color of the list view items in different states
   void              ItemColor(const color clr)                          { m_item_color=clr;                  }
   void              ItemColorHover(const color clr)                     { m_item_color_hover=clr;            }
   void              ItemColorSelected(const color clr)                  { m_item_color_selected=clr;         }
   void              ItemTextColor(const color clr)                      { m_item_text_color=clr;             }
   void              ItemTextColorHover(const color clr)                 { m_item_text_color_hover=clr;       }
   void              ItemTextColorSelected(const color clr)              { m_item_text_color_selected=clr;    }
   //--- Returns (1) the index and (2) the text in the highlighted item in the list view
   int               SelectedItemIndex(void)                       const { return(m_selected_item_index);     }
   string            SelectedItemText(void)                        const { return(m_selected_item_text);      }
   //--- (1) Setting the value, (2) selecting the item
   void              SetItemValue(const uint item_index,const string value);
   void              SelectItem(const uint index);
   //--- Set the size of (1) the list view and (2) its visible part
   void              ListSize(const int items_total);
   void              VisibleListSize(const int visible_items_total);
   //--- Rebuilding the list
   void              Rebuilding(const int items_total,const int visible_items_total);
   //--- Add item to the list
   void              AddItem(const string value="");
   //--- Clears the list (deletes all items)
   void              Clear(void);
   //--- Scrolling the list
   void              Scrolling(const int pos=WRONG_VALUE);
   //--- Resetting the color of the list view items
   void              ResetItemsColor(void);
   //---
public:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Timer
   virtual void      OnEventTimer(void);
   //--- Moving the element
   virtual void      Moving(const int x,const int y,const bool moving_mode=false);
   //--- (1) Show, (2) hide, (3) reset, (4) delete
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Reset(void);
   virtual void      Delete(void);
   //--- (1) Set, (2) reset priorities of the left mouse button click
   virtual void      SetZorders(void);
   virtual void      ResetZorders(void);
   //--- Zero the color
   virtual void      ResetColors(void);
   //---
private:
   //--- Changing the color of list view items when the cursor is hovering over them
   void              ChangeItemsColor(void);
   //--- Checking the focus of list view items when the cursor is hovering
   void              CheckItemFocus(void);
   //--- Update the list
   void              UpdateList(const int pos=WRONG_VALUE);
   //--- Handling the pressing on the list view item
   bool              OnClickListItem(const string clicked_object);
   //--- Highlighting of the selected item
   void              HighlightSelectedItem(void);
   //--- Fast forward of the list view
   void              FastSwitching(void);
   
   //--- Calculation of the Y coordinate of the item
   int               CalculationItemY(const int item_index=0);
   //--- Calculating the width of items
   int               CalculationItemsWidth(void);
   //--- Calculation of the list size along the Y axis
   int               CalculationYSize(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CListView::CListView(void) : m_item_y_size(18),
                             m_lights_hover(false),
                             m_align_mode(ALIGN_LEFT),
                             m_items_total(0),
                             m_visible_items_total(2),
                             m_selected_item_index(WRONG_VALUE),
                             m_selected_item_text(""),
                             m_area_border_color(C'235,235,235'),
                             m_item_color(clrWhite),
                             m_item_color_hover(C'240,240,240'),
                             m_item_color_selected(C'51,153,255'),
                             m_item_text_color(clrBlack),
                             m_item_text_color_hover(clrBlack),
                             m_item_text_color_selected(clrWhite),
                             m_prev_item_index_focus(WRONG_VALUE)
  {
//--- Store the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
//--- Set priorities of the left mouse button click
   m_area_zorder =1;
   m_item_zorder =2;
//--- Set the size of the list view and its visible part
   ListSize(m_items_total);
   VisibleListSize(m_visible_items_total);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CListView::~CListView(void)
  {
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CListView::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Handling of the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      //--- Leave, if the control is hidden
      if(!CElementBase::IsVisible())
         return;
      //--- Leave, if numbers of subwindows do not match
      if(!CElementBase::CheckSubwindowNumber())
         return;
      //--- Checking the focus over elements
      CElementBase::CheckMouseFocus();
      //--- If this is a drop-down list and the mouse button is pressed
      if(CElementBase::IsDropdown() && m_mouse.LeftButtonState())
        {
         //--- If the cursor is outside the combobox, outside the list view and not in scrolling mode
         if(!m_combobox.MouseFocus() && !CElementBase::MouseFocus() && !m_scrollv.ScrollState())
           {
            //--- Hide the list view
            Hide();
            return;
           }
        }
      //--- Move the list if the management of the slider is enabled
      if(m_scrollv.ScrollBarControl())
        {
         UpdateList();
         return;
        }
      //--- Reset color of the element, if not in focus
      if(!CElementBase::MouseFocus())
        {
         //--- If the item already is in focus
         if(m_prev_item_index_focus!=WRONG_VALUE)
           {
            //--- Reset the color of the list view
            ResetColors();
            m_prev_item_index_focus=WRONG_VALUE;
           }
         return;
        }
      //--- Changes the color of the list view items when the cursor is hovering over it
      ChangeItemsColor();
      return;
     }
//--- Handling the pressing on objects
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- If the pressing was on the list view elements
      if(OnClickListItem(sparam))
        {
         //--- Highlighting the item
         HighlightSelectedItem();
         return;
        }
      //--- If the pressing was on the buttons of the scrollbar
      if(m_scrollv.OnClickScrollInc(sparam) || m_scrollv.OnClickScrollDec(sparam))
        {
         //--- Moves the list along the scrollbar
         UpdateList();
         return;
        }
     }
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CListView::OnEventTimer(void)
  {
//--- If the element is a drop-down
   if(CElementBase::IsDropdown())
      //--- Fast forward of the list view
      FastSwitching();
//--- If this is not a drop-down element, take current availability of the form into consideration
   else
     {
      //--- Track the fast forward of the list view only if the form is not blocked
      if(!m_wnd.IsLocked())
         FastSwitching();
     }
  }
//+------------------------------------------------------------------+
//| Creates the list view                                            |
//+------------------------------------------------------------------+
bool CListView::CreateListView(const long chart_id,const int subwin,const int x_gap,const int y_gap)
  {
//--- Exit if there is no pointer to the form
   if(!CElement::CheckWindowPointer())
      return(false);
//--- If the list view is a drop-down, a pointer to the combobox to which it will be attached is required
   if(CElementBase::IsDropdown())
     {
      //--- Leave, if there is no pointer to the combobox
      if(::CheckPointer(m_combobox)==POINTER_INVALID)
        {
         ::Print(__FUNCTION__," > Before creating a drop-down list view, the class must be passed "
                 "a pointer to the combobox: CListView::ComboBoxPointer(CElement &object)");
         return(false);
        }
     }
//--- Initializing variables
   m_id                  =m_wnd.LastId()+1;
   m_chart_id            =chart_id;
   m_subwin              =subwin;
   m_x                   =CElement::CalculateX(x_gap);
   m_y                   =CElement::CalculateY(y_gap);
   m_y_size              =CalculationYSize();
   m_selected_item_index =(m_selected_item_index==WRONG_VALUE) ? 0 : m_selected_item_index;
//--- Margins from the edge
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
//--- Creating a button
   if(!CreateArea())
      return(false);
   if(!CreateList())
      return(false);
   if(!CreateScrollV())
      return(false);
//--- Hide the element if the window is a dialog one or is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized() || CElementBase::IsDropdown())
      Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the list view background                                  |
//+------------------------------------------------------------------+
bool CListView::CreateArea(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_listview_area_"+(string)CElementBase::Id();
//--- Creating the object
   if(!m_area.Create(m_chart_id,name,m_subwin,m_x,m_y,m_x_size,m_y_size))
      return(false);
//--- Setting up properties
   m_area.BackColor(m_item_color);
   m_area.Color(m_area_border_color);
   m_area.BorderType(BORDER_FLAT);
   m_area.Corner(m_corner);
   m_area.Selectable(false);
   m_area.Z_Order(m_area_zorder);
   m_area.Tooltip("\n");
//--- Store coordinates
   m_area.X(CElementBase::X());
   m_area.Y(CElementBase::Y());
//--- Store the size
   m_area.XSize(CElementBase::XSize());
   m_area.YSize(CElementBase::YSize());
//--- Margins from the edge
   m_area.XGap(CElement::CalculateXGap(m_x));
   m_area.YGap(CElement::CalculateYGap(m_y));
//--- Store the object pointer
   CElementBase::AddToArray(m_area);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates an item                                                  |
//+------------------------------------------------------------------+
bool CListView::CreateItem(const int index,const int x,const int y,const int width)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_listview_item_"+(string)index+"__"+(string)CElementBase::Id();
//--- Creating the object
   if(!m_items[index].Create(m_chart_id,name,m_subwin,x,y,width,m_item_y_size))
      return(false);
//--- Setting up properties
   m_items[index].Description(m_item_value[index]);
   m_items[index].TextAlign(m_align_mode);
   m_items[index].Font(CElementBase::Font());
   m_items[index].FontSize(CElementBase::FontSize());
   m_items[index].Color(m_item_text_color);
   m_items[index].BackColor(m_item_color);
   m_items[index].BorderColor(m_item_color);
   m_items[index].Corner(m_corner);
   m_items[index].Anchor(m_anchor);
   m_items[index].Selectable(false);
   m_items[index].Z_Order(m_item_zorder);
   m_items[index].ReadOnly(true);
   m_items[index].Tooltip("\n");
//--- Coordinates
   m_items[index].X(x);
   m_items[index].Y(y);
//--- Sizes
   m_items[index].XSize(width);
   m_items[index].YSize(m_item_y_size);
//--- Margins from the edge of the panel
   m_items[index].XGap(CElement::CalculateXGap(x));
   m_items[index].YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_items[index]);
//--- Hide the item, if the control is hidden
   if(!CElementBase::IsVisible())
      m_items[index].Timeframes(OBJ_NO_PERIODS);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the list view items                                      |
//+------------------------------------------------------------------+
bool CListView::CreateList(void)
  {
//--- Leave, if there are no items in the list view
   if(ItemsTotal()<1)
      return(true);
//--- Coordinates
   int x =CElementBase::X()+1;
   int y =0;
//--- Calculating the width of the list view items
   int w=CalculationItemsWidth();
//---
   for(int i=0; i<m_items_total && i<m_visible_items_total; i++)
     {
      //--- Calculation of the Y coordinate
      y=CalculationItemY(i);
      //--- Creating the object
      if(!CreateItem(i,x,y,w))
         return(false);
     }
//--- Highlighting the selected item
   HighlightSelectedItem();
//--- Update the list
   UpdateList();
//--- Store the text of the selected item
   m_selected_item_text=m_item_value[m_selected_item_index];
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the vertical scrollbar                                   |
//+------------------------------------------------------------------+
bool CListView::CreateScrollV(void)
  {
//--- Store the form pointer
   m_scrollv.WindowPointer(m_wnd);
//--- Coordinates
   int x=CElement::CalculateXGap(CElementBase::X2()-m_scrollv.ScrollWidth());
   int y=CElement::CalculateYGap(CElementBase::Y());
//--- Set properties
   m_scrollv.Id(CElementBase::Id());
   m_scrollv.XSize(m_scrollv.ScrollWidth());
   m_scrollv.YSize(CElementBase::YSize());
   m_scrollv.AreaBorderColor(m_area_border_color);
   m_scrollv.IsDropdown(CElementBase::IsDropdown());
   m_scrollv.AnchorRightWindowSide(m_anchor_right_window_side);
   m_scrollv.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating the scrollbar
   if(!m_scrollv.CreateScroll(m_chart_id,m_subwin,x,y,m_items_total,m_visible_items_total))
      return(false);
//--- Update the position of objects
   m_scrollv.Moving(m_wnd.X(),m_wnd.Y(),true);
//--- Hide the scrollbar, if the number of items is less than the size of the list
   if(m_items_total<=m_visible_items_total)
      m_scrollv.Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Highlights selected item                                         |
//+------------------------------------------------------------------+
void CListView::SelectItem(const uint index)
  {
//--- Leave, if there are no items in the list view
   if(ItemsTotal()<1)
      return;
//--- Adjustment in case the range has been exceeded
   m_selected_item_index=(index>=uint(m_items_total))? m_items_total-1 :(int)index;
//--- Highlighting the selected item
   HighlightSelectedItem();
//--- Moves the list along the scrollbar
   UpdateList();
//--- Store the text of the selected item
   m_selected_item_text=m_item_value[m_selected_item_index];
  }
//+------------------------------------------------------------------+
//| Stores the passed value in the list view by the specified index  |
//+------------------------------------------------------------------+
void CListView::SetItemValue(const uint item_index,const string value)
  {
   uint array_size=::ArraySize(m_item_value);
//--- If there is no item in the list view, report
   if(array_size<1)
      ::Print(__FUNCTION__," > This method is to be called, if the list has at least one item!");
//--- Adjustment in case the range has been exceeded
   uint i=(item_index>=array_size)? array_size-1 : item_index;
//--- Store the value in the list view
   m_item_value[i]=value;
//--- Update the list
   UpdateList();
  }
//+------------------------------------------------------------------+
//| Sets the size of the list view                                   |
//+------------------------------------------------------------------+
void CListView::ListSize(const int items_total)
  {
//--- No point to make a list view shorter than two items
   m_items_total=(items_total<1) ? 0 : items_total;
   ::ArrayResize(m_item_value,m_items_total);
  }
//+------------------------------------------------------------------+
//| Sets the size of the visible part of the list view               |
//+------------------------------------------------------------------+
void CListView::VisibleListSize(const int visible_items_total)
  {
//--- No point to make a list view shorter than two items
   m_visible_items_total=(visible_items_total<2) ? 2 : visible_items_total;
   ::ArrayResize(m_items,m_visible_items_total);
  }
//+------------------------------------------------------------------+
//| Rebuilding the list                                              |
//+------------------------------------------------------------------+
void CListView::Rebuilding(const int items_total,const int visible_items_total)
  {
//--- Clearing the list
   Clear();
//--- Set the size of the list view and its visible part
   ListSize(items_total);
   VisibleListSize(visible_items_total);
//--- Adjust the list size
   int y_size=CalculationYSize();
   if(y_size!=CElementBase::YSize())
     {
      m_area.YSize(y_size);
      m_area.Y_Size(y_size);
      CElementBase::YSize(y_size);
     }
//--- Adjust the size of the scrollbar
   m_scrollv.ChangeThumbSize(m_items_total,m_visible_items_total);
   m_scrollv.ChangeYSize(y_size);
//--- Create the list
   CreateList();
//--- Display the scrollbar, if necessary
   if(m_items_total>m_visible_items_total)
     {
      if(CElementBase::IsVisible())
         m_scrollv.Show();
     }
  }
//+------------------------------------------------------------------+
//| Add item to the list                                             |
//+------------------------------------------------------------------+
void CListView::AddItem(const string value="")
  {
//--- Increase the array size by one element
   int array_size=ItemsTotal();
   m_items_total=array_size+1;
   ::ArrayResize(m_item_value,m_items_total);
   m_item_value[array_size]=value;
//--- If the total number of items is greater than visible
   if(m_items_total>m_visible_items_total)
     {
      //--- Adjust the size of the thumb and display the scrollbar
      m_scrollv.ChangeThumbSize(m_items_total,m_visible_items_total);
      if(CElementBase::IsVisible())
         m_scrollv.Show();
      //--- Leave, if the array has less than one element
      if(m_visible_items_total<1)
         return;
      //--- Calculating the width of the list view items
      int width=CElementBase::XSize()-m_scrollv.ScrollWidth()-1;
      if(width==m_items[0].XSize())
         return;
      //--- Set the new size to the list items
      for(int i=0; i<m_items_total && i<m_visible_items_total; i++)
        {
         m_items[i].XSize(width);
         m_items[i].X_Size(width);
        }
      //---
      return;
     }
//--- Calculating coordinates
   int x=CElementBase::X()+1;
   int y=CalculationItemY(array_size);
//--- Calculating the width of the list view items
   int width=CalculationItemsWidth();
//--- Creating the object
   CreateItem(array_size,x,y,width);
//--- Highlighting the selected item
   HighlightSelectedItem();
//--- Store the text of the selected item
   if(array_size==1)
      m_selected_item_text=m_item_value[0];
  }
//+------------------------------------------------------------------+
//| Clears the list (deletes all items)                              |
//+------------------------------------------------------------------+
void CListView::Clear(void)
  {
//--- Delete the item objects
   for(int r=0; r<m_visible_items_total; r++)
      m_items[r].Delete();
//--- Clear the array of pointers to objects
   CElementBase::FreeObjectsArray();
//--- Set the default values
   m_selected_item_text  ="";
   m_selected_item_index =0;
//--- Set the zero size to the list
   ListSize(0);
//--- Reset the scrollbar values
   m_scrollv.Hide();
   m_scrollv.MovingThumb(0);
   m_scrollv.ChangeThumbSize(m_items_total,m_visible_items_total);
//--- Add the list background to the array of pointers to objects of the control
   CElementBase::AddToArray(m_area);
  }
//+------------------------------------------------------------------+
//| Scrolling the list                                               |
//+------------------------------------------------------------------+
void CListView::Scrolling(const int pos=WRONG_VALUE)
  {
//--- Leave, if the scrollbar is not required
   if(m_items_total<=m_visible_items_total)
      return;
//--- To determine the position of the thumb
   int index=0;
//--- Index of the last position
   int last_pos_index=m_items_total-m_visible_items_total;
//--- Adjustment in case the range has been exceeded
   if(pos<0)
      index=last_pos_index;
   else
      index=(pos>last_pos_index)? last_pos_index : pos;
//--- Move the scrollbar thumb
   m_scrollv.MovingThumb(index);
//--- Move the list
   UpdateList(index);
  }
//+------------------------------------------------------------------+
//| Resetting the color of the list view items                       |
//+------------------------------------------------------------------+
void CListView::ResetItemsColor(void)
  {
//--- Get the current position of the scrollbar slider
   int v=m_scrollv.CurrentPos();
//--- Iterate over the visible part of the list view
   for(int i=0; i<m_visible_items_total; i++)
     {
      //--- Increase the counter if the list view range has not been exceeded
      if(v>=0 && v<m_items_total)
         v++;
      //--- Skip the selected item
      if(m_selected_item_index==v-1)
         continue;
      //--- Setting the color (background, text)
      m_items[i].BackColor(m_item_color);
      m_items[i].Color(m_item_text_color);
     }
  }
//+------------------------------------------------------------------+
//| Changing color of the list view item when the cursor is hovering |
//+------------------------------------------------------------------+
void CListView::ChangeItemsColor(void)
  {
//--- Leave, if the highlighting of the item when the cursor is hovering over it is disabled or the scrollbar is active
   if(!m_lights_hover || m_scrollv.ScrollState())
      return;
//--- Leave, if it is not a drop-down element and the form is blocked
   if(!CElementBase::IsDropdown() && m_wnd.IsLocked())
      return;
//--- If entered the list view again
   if(m_prev_item_index_focus==WRONG_VALUE)
     {
      //--- Check the focus on the current item
      CheckItemFocus();
     }
   else
     {
      //--- Check the focus on the current row
      int i=m_prev_item_index_focus;
      bool condition=m_mouse.X()>m_items[i].X() && m_mouse.X()<m_items[i].X2() && 
                     m_mouse.Y()>m_items[i].Y() && m_mouse.Y()<m_items[i].Y2();
      //--- If moved to another item
      if(!condition)
        {
         //--- Reset the color of the previous item
         m_items[i].BackColor(m_item_color);
         m_items[i].Color(m_item_text_color);
         m_prev_item_index_focus=WRONG_VALUE;
         //--- Check the focus on the current item
         CheckItemFocus();
        }
     }
  }
//+------------------------------------------------------------------+
//| Check the focus of list view items when the cursor is hovering   |
//+------------------------------------------------------------------+
void CListView::CheckItemFocus(void)
  {
//--- Get the current position of the scrollbar slider
   int v=m_scrollv.CurrentPos();
//--- Identify over which item the cursor is over and highlight it
   for(int i=0; i<m_visible_items_total; i++)
     {
      //--- Increase the counter if the list view range has not been exceeded
      if(v>=0 && v<m_items_total)
         v++;
      //--- Skip the selected item
      if(m_selected_item_index==v-1)
        {
         m_items[i].BackColor(m_item_color_selected);
         m_items[i].Color(m_item_text_color_selected);
         continue;
        }
      //--- If the cursor is over this item, highlight it
      if(m_mouse.X()>m_items[i].X() && m_mouse.X()<m_items[i].X2() &&
         m_mouse.Y()>m_items[i].Y() && m_mouse.Y()<m_items[i].Y2())
        {
         m_items[i].BackColor(m_item_color_hover);
         m_items[i].Color(m_item_text_color_hover);
         //--- Remember the item
         m_prev_item_index_focus=i;
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//| Updates the list                                                 |
//+------------------------------------------------------------------+
void CListView::UpdateList(const int pos=WRONG_VALUE)
  {
//--- Get the current position of the scrollbar slider
   int v=m_scrollv.CurrentPos();
//--- If the list must be moved to the specified position
   if(pos!=WRONG_VALUE)
     {
      v=pos;
      m_scrollv.MovingThumb(pos);
     }
//--- Iterate over the visible part of the list view
   for(int i=0; i<m_visible_items_total; i++)
     {
      //--- If inside the range of the list view
      if(v>=0 && v<m_items_total)
        {
         //--- Moving the text, the background color and the text color
         m_items[i].Description(m_item_value[v]);
         m_items[i].BackColor((m_selected_item_index==v) ? m_item_color_selected : m_item_color);
         m_items[i].Color((m_selected_item_index==v) ? m_item_text_color_selected : m_item_text_color);
         //--- Increase the counter
         v++;
        }
     }
  }
//+------------------------------------------------------------------+
//| Highlights selected item                                         |
//+------------------------------------------------------------------+
void CListView::HighlightSelectedItem(void)
  {
//--- Leave, if the scrollbar is active
   if(m_scrollv.ScrollState())
      return;
//--- Get the current position of the scrollbar slider
   int v=m_scrollv.CurrentPos();
//--- Iterate over the visible part of the list view
   for(int i=0; i<m_visible_items_total; i++)
     {
      //--- If inside the range of the list view
      if(v>=0 && v<m_items_total)
        {
         //--- Changing the background color and the text color
         m_items[i].BackColor((m_selected_item_index==v) ? m_item_color_selected : m_item_color);
         m_items[i].Color((m_selected_item_index==v) ? m_item_text_color_selected : m_item_text_color);
         //--- Increase the counter
         v++;
        }
     }
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CListView::Moving(const int x,const int y,const bool moving_mode=false)
  {
//--- Leave, if the control is hidden
   if(!CElementBase::IsVisible())
      return;
//--- If the management is delegated to the window, identify its location
   if(!moving_mode)
      if(m_wnd.ClampingAreaMouse()!=PRESSED_INSIDE_HEADER)
         return;
//--- Storing indents in the element fields
   CElementBase::X((m_anchor_right_window_side)? m_wnd.X2()-XGap() : x+XGap());
   CElementBase::Y((m_anchor_bottom_window_side)? m_wnd.Y2()-YGap() : y+YGap());
//--- Storing coordinates in the fields of the objects
   m_area.X((m_anchor_right_window_side)? m_wnd.X2()-m_area.XGap() : x+m_area.XGap());
   m_area.Y((m_anchor_bottom_window_side)? m_wnd.Y2()-m_area.YGap() : y+m_area.YGap());
//--- Updating coordinates of graphical objects   
   m_area.X_Distance(m_area.X());
   m_area.Y_Distance(m_area.Y());
//---
   for(int r=0; r<m_visible_items_total; r++)
     {
      //--- Storing coordinates in the fields of the objects
      m_items[r].X((m_anchor_right_window_side)? m_wnd.X2()-m_items[r].XGap() : x+m_items[r].XGap());
      m_items[r].Y((m_anchor_bottom_window_side)? m_wnd.Y2()-m_items[r].YGap() : y+m_items[r].YGap());
      //--- Updating coordinates of graphical objects
      m_items[r].X_Distance(m_items[r].X());
      m_items[r].Y_Distance(m_items[r].Y());
     }
  }
//+------------------------------------------------------------------+
//| Show the list view                                               |
//+------------------------------------------------------------------+
void CListView::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElementBase::IsVisible())
      return;
//--- Make all the objects visible
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_ALL_PERIODS);
//--- Show the scrollbar
   m_scrollv.Show();
//--- Visible state
   CElementBase::IsVisible(true);
//--- Send a signal for zeroing priorities of the left mouse click
   if(CElementBase::IsDropdown())
      ::EventChartCustom(m_chart_id,ON_ZERO_PRIORITIES,m_id,0.0,"");
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
//| Hide the list view                                               |
//+------------------------------------------------------------------+
void CListView::Hide(void)
  {
   if(!m_wnd.IsMinimized())
      if(!CElementBase::IsDropdown())
         if(!CElementBase::IsVisible())
            return;
//--- Hide all objects
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_NO_PERIODS);
//--- Hide the scrollbar
   m_scrollv.Hide();
//--- Visible state
   CElementBase::IsVisible(false);
//--- Send a signal to restore the priorities of the left mouse click
   if(!m_wnd.IsMinimized() && CElementBase::IsVisible())
      ::EventChartCustom(m_chart_id,ON_SET_PRIORITIES,CElementBase::Id(),0.0,CElementBase::ClassName());
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CListView::Reset(void)
  {
//--- Leave, if this is a drop-down element
   if(CElementBase::IsDropdown())
      return;
//--- Hide and show
   Hide();
   Show();
  }
//+------------------------------------------------------------------+
//| Remove                                                         |
//+------------------------------------------------------------------+
void CListView::Delete(void)
  {
//--- Removing objects
   m_area.Delete();
   for(int r=0; r<m_visible_items_total; r++)
      m_items[r].Delete();
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
//--- Initializing of variables by default values
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Seth the priorities                                              |
//+------------------------------------------------------------------+
void CListView::SetZorders(void)
  {
   m_area.Z_Order(m_area_zorder);
   m_scrollv.SetZorders();
   for(int i=0; i<m_visible_items_total; i++)
      m_items[i].Z_Order(m_item_zorder);
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CListView::ResetZorders(void)
  {
   m_area.Z_Order(0);
   m_scrollv.ResetZorders();
   for(int i=0; i<m_visible_items_total; i++)
      m_items[i].Z_Order(0);
  }
//+------------------------------------------------------------------+
//| Reset the color                                                  |
//+------------------------------------------------------------------+
void CListView::ResetColors(void)
  {
   ResetItemsColor();
   m_scrollv.ResetColors();
  }
//+------------------------------------------------------------------+
//| Handling the pressing on the list view item                      |
//+------------------------------------------------------------------+
bool CListView::OnClickListItem(const string clicked_object)
  {
//--- Leave, if the list view is not in focus
   if(!CElementBase::MouseFocus())
      return(false);
//--- Leave, if the form is blocked and identifiers do not match
   if(m_wnd.IsLocked() && !CElement::CheckIdActivatedElement())
      return(false);
//--- Leave, if the scrollbar is active
   if(m_scrollv.ScrollState())
      return(false);
//--- Leave, if the clicking was not on the menu item
   if(::StringFind(clicked_object,CElementBase::ProgramName()+"_listview_item_",0)<0)
      return(false);
//--- Get the identifier and index from the object name
   int id=CElementBase::IdFromObjectName(clicked_object);
//--- Leave, if the identifier does not match
   if(id!=CElementBase::Id())
      return(false);
//--- Get the current position of the scrollbar slider
   int v=m_scrollv.CurrentPos();
//--- Go over the visible part of the list view
   for(int i=0; i<m_visible_items_total; i++)
     {
      //--- If this list view item was selected
      if(m_items[i].Name()==clicked_object)
        {
         m_selected_item_index   =v;
         m_selected_item_text    =m_item_value[v];
         m_prev_item_index_focus =WRONG_VALUE;
         break;
        }
      //--- If inside the range of the list view
      if(v>=0 && v<m_items_total)
         //--- Increase the counter
         v++;
     }
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_CLICK_LIST_ITEM,CElementBase::Id(),0,m_selected_item_text);
   return(true);
  }
//+------------------------------------------------------------------+
//| Fast forward of the list view                                    |
//+------------------------------------------------------------------+
void CListView::FastSwitching(void)
  {
//--- Leave, if there is no focus on the list view
   if(!CElementBase::MouseFocus())
      return;
//--- Return counter to initial value if the mouse button is released если кнопка мыши отжата
   if(!m_mouse.LeftButtonState())
      m_timer_counter=SPIN_DELAY_MSC;
//--- If the mouse button is pressed down
   else
     {
      //--- Increase the counter by the set step
      m_timer_counter+=TIMER_STEP_MSC;
      //--- Exit if below zero
      if(m_timer_counter<0)
         return;
      //--- If scrolling up
      if(m_scrollv.ScrollIncState())
         m_scrollv.OnClickScrollInc(m_scrollv.ScrollIncName());
      //--- If scrolling down
      else if(m_scrollv.ScrollDecState())
         m_scrollv.OnClickScrollDec(m_scrollv.ScrollDecName());
      //--- Update the list
      UpdateList();
     }
  }
//+------------------------------------------------------------------+
//| Calculation of the Y coordinate of the item                      |
//+------------------------------------------------------------------+
int CListView::CalculationItemY(const int item_index=0)
  {
   return((item_index>0)? m_items[item_index-1].Y2()-1 : CElementBase::Y()+1);
  }
//+------------------------------------------------------------------+
//| Calculating the width of items                                   |
//+------------------------------------------------------------------+
int CListView::CalculationItemsWidth(void)
  {
   return((m_items_total>m_visible_items_total) ? CElementBase::XSize()-m_scrollv.ScrollWidth()-1 : CElementBase::XSize()-2);
  }
//+------------------------------------------------------------------+
//| Calculation of the list size along the Y axis                    |
//+------------------------------------------------------------------+
int CListView::CalculationYSize(void)
  {
   return(m_item_y_size*m_visible_items_total-(m_visible_items_total-1)+2);
  }
//+------------------------------------------------------------------+
