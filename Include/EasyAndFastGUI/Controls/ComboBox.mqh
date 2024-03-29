//+------------------------------------------------------------------+
//|                                                     ComboBox.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "ListView.mqh"
//+------------------------------------------------------------------+
//| Class for creating a combobox                                    |
//+------------------------------------------------------------------+
class CComboBox : public CElement
  {
private:
   //--- Objects for creating a combobox
   CRectLabel        m_area;
   CBmpLabel         m_icon;
   CLabel            m_label;
   CEdit             m_button;
   CBmpLabel         m_drop_arrow;
   CListView         m_listview;
   //--- Combobox properties:
   //    Color of the general background
   color             m_area_color;
   //--- Control icons in the active and blocked states
   string            m_icon_file_on;
   string            m_icon_file_off;
   //--- Icon margins
   int               m_icon_x_gap;
   int               m_icon_y_gap;
   //--- Text and margins of the text label
   string            m_label_text;
   int               m_label_x_gap;
   int               m_label_y_gap;
   //--- Colors of the text label in different states
   color             m_label_color;
   color             m_label_color_off;
   color             m_label_color_hover;
   color             m_label_color_array[];
   //--- (1) Button text and (2) its size
   string            m_button_text;
   int               m_button_x_size;
   int               m_button_y_size;
   //--- Colors of the button in different states
   color             m_button_color;
   color             m_button_color_off;
   color             m_button_color_hover;
   color             m_button_color_pressed;
   color             m_button_color_array[];
   //--- Colors of the button frame in different states
   color             m_button_border_color;
   color             m_button_border_color_off;
   color             m_button_border_color_hover;
   color             m_button_border_color_array[];
   //--- Color of the button text in different states
   color             m_button_text_color;
   color             m_button_text_color_off;
   //--- Icon margins
   int               m_drop_arrow_x_gap;
   int               m_drop_arrow_y_gap;
   //--- Icons of the button with a drop-down menu in the active and blocked states
   string            m_drop_arrow_file_on;
   string            m_drop_arrow_file_off;
   //--- Priorities of the left mouse button click
   int               m_area_zorder;
   int               m_button_zorder;
   int               m_zorder;
   //--- Available/blocked
   bool              m_combobox_state;
   //---
public:
                     CComboBox(void);
                    ~CComboBox(void);
   //--- Methods for creating a combobox
   bool              CreateComboBox(const long chart_id,const int subwin,const string label_text,const int x_gap,const int y_gap);
   //---
private:
   bool              CreateArea(void);
   bool              CreateIcon(void);
   bool              CreateLabel(void);
   bool              CreateButton(void);
   bool              CreateDropArrow(void);
   bool              CreateList(void);
   //---
public:
   //--- Returns pointers to (1) the list view and (2) the scrollbar
   CListView        *GetListViewPointer(void)                         { return(::GetPointer(m_listview));                }
   CScrollV         *GetScrollVPointer(void)                          { return(m_listview.GetScrollVPointer());          }
   //--- Setting (1) the size of the list view (number of items) and (2) its visible part, (3) getting and setting the element state
   void              ItemsTotal(const int items_total)                { m_listview.ListSize(items_total);                }
   void              VisibleItemsTotal(const int visible_items_total) { m_listview.VisibleListSize(visible_items_total); }
   bool              ComboBoxState(void)                        const { return(m_combobox_state);                        }
   void              ComboBoxState(const bool state);
   //--- Icon margins
   void              IconXGap(const int x_gap)                        { m_icon_x_gap=x_gap;                              }
   void              IconYGap(const int y_gap)                        { m_icon_y_gap=y_gap;                              }
   //--- (1) Background color, (2) gets/sets description of the control
   void              AreaColor(const color clr)                       { m_area_color=clr;                                }
   string            LabelText(void)                            const { return(m_label.Description());                   }
   void              LabelText(const string text)                     { m_label.Description(text);                       }
   //--- Text label margins
   void              LabelXGap(const int x_gap)                       { m_label_x_gap=x_gap;                             }
   void              LabelYGap(const int y_gap)                       { m_label_y_gap=y_gap;                             }
   //--- (1) Returns the button text, (2) setting the button size
   string            ButtonText(void)                           const { return(m_button_text);                           }
   void              ButtonXSize(const int x_size)                    { m_button_x_size=x_size;                          }
   void              ButtonYSize(const int y_size)                    { m_button_y_size=y_size;                          }
   //--- (1) Background color, (2) colors of the text label
   void              LabelColor(const color clr)                      { m_label_color=clr;                               }
   void              LabelColorOff(const color clr)                   { m_label_color_off=clr;                           }
   void              LabelColorHover(const color clr)                 { m_label_color_hover=clr;                         }
   //--- Button colors
   void              ButtonBackColor(const color clr)                 { m_button_color=clr;                              }
   void              ButtonBackColorOff(const color clr)              { m_button_color_off=clr;                          }
   void              ButtonBackColorHover(const color clr)            { m_button_color_hover=clr;                        }
   void              ButtonBackColorPressed(const color clr)          { m_button_color_pressed=clr;                      }
   //--- Colors of the button frame
   void              ButtonBorderColor(const color clr)               { m_button_border_color=clr;                       }
   void              ButtonBorderColorOff(const color clr)            { m_button_border_color_off=clr;                   }
   void              ButtonBorderColorHover(const color clr)          { m_button_border_color_hover=clr;                 }
   //--- Colors of the button text
   void              ButtonTextColor(const color clr)                 { m_button_text_color=clr;                         }
   void              ButtonTextColorOff(const color clr)              { m_button_text_color_off=clr;                     }
   //--- Setting icons for the button with a drop-down menu in the active and blocked states
   void              DropArrowFileOn(const string file_path)          { m_drop_arrow_file_on=file_path;                  }
   void              DropArrowFileOff(const string file_path)         { m_drop_arrow_file_off=file_path;                 }
   //--- Icon margins
   void              DropArrowXGap(const int x_gap)                   { m_drop_arrow_x_gap=x_gap;                        }
   void              DropArrowYGap(const int y_gap)                   { m_drop_arrow_y_gap=y_gap;                        }
   //--- Setting icons for the control in the active and blocked states
   void              IconFileOn(const string file_path);
   void              IconFileOff(const string file_path);
   //--- Stores the passed value in the list view by specified index
   void              SetItemValue(const int item_index,const string item_text);
   //--- Highlighting the item by specified index
   void              SelectItem(const int item_index);
   //--- Changing the object color when the cursor is hovering over it
   void              ChangeObjectsColor(void);
   //--- Changes the current state of the combobox for the opposite
   void              ChangeComboBoxListState(void);
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
   //--- Handling of pressing the button
   bool              OnClickButton(const string clicked_object);
   //--- Checking the pressed left mouse button over the combobox button
   void              CheckPressedOverButton(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CComboBox::CComboBox(void) : m_area_color(clrNONE),
                             m_combobox_state(true),
                             m_icon_x_gap(0),
                             m_icon_y_gap(0),
                             m_icon_file_on(""),
                             m_icon_file_off(""),
                             m_label_text(""),
                             m_label_x_gap(0),
                             m_label_y_gap(2),
                             m_label_color(clrBlack),
                             m_label_color_off(clrSilver),
                             m_label_color_hover(C'85,170,255'),
                             m_button_text(""),
                             m_button_y_size(18),
                             m_button_text_color(clrBlack),
                             m_button_text_color_off(clrDarkGray),
                             m_button_color(C'220,220,220'),
                             m_button_color_off(C'230,230,230'),
                             m_button_color_hover(C'193,218,255'),
                             m_button_color_pressed(C'153,178,215'),
                             m_button_border_color(clrSilver),
                             m_button_border_color_off(clrSilver),
                             m_button_border_color_hover(C'85,170,255'),
                             m_drop_arrow_x_gap(16),
                             m_drop_arrow_y_gap(1),
                             m_drop_arrow_file_on(""),
                             m_drop_arrow_file_off("")
  {
//--- Store the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
//--- Drop-down list view mode
   m_listview.IsDropdown(true);
//--- Set priorities of the left mouse button click
   m_zorder        =0;
   m_area_zorder   =1;
   m_button_zorder =2;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CComboBox::~CComboBox(void)
  {
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CComboBox::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
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
      m_button.MouseFocus(m_mouse.X()>m_button.X() && m_mouse.X()<m_button.X2() && 
                          m_mouse.Y()>m_button.Y() && m_mouse.Y()<m_button.Y2());
      //--- Check of the pressed left mouse button over the button
      CheckPressedOverButton();
      return;
     }
//--- Handling the list view item press event
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_LIST_ITEM)
     {
      //--- If identifiers match
      if(lparam==CElementBase::Id())
        {
         //--- Store and set the text in the button
         m_button_text=m_listview.SelectedItemText();
         m_button.Description(m_listview.SelectedItemText());
         //--- Change the list view state
         ChangeComboBoxListState();
         //--- Send a message about it
         ::EventChartCustom(m_chart_id,ON_CLICK_COMBOBOX_ITEM,CElementBase::Id(),0,m_label_text);
        }
      //---
      return;
     }
//--- Handling the left mouse button click on the object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- Pressing on the combobox button
      if(OnClickButton(sparam))
         return;
      //---
      return;
     }
//--- Handling the chart properties change event
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      //--- Leave, if the element is blocked
      if(!m_combobox_state)
         return;
      //--- Leave, if the list view is hidden
      if(!m_listview.IsVisible())
         return;
      //--- Hide the list view
      m_listview.Hide();
      //--- Restore colors
      ResetColors();
      //--- If the form is blocked and identifiers match
      if(m_wnd.IsLocked() && CElement::CheckIdActivatedElement())
        {
         //--- Unblock the form
         m_wnd.IsLocked(false);
         m_wnd.IdActivatedElement(WRONG_VALUE);
        }
      return;
     }
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CComboBox::OnEventTimer(void)
  {
//--- If this is a drop-down element and the list view is hidden
   if(CElementBase::IsDropdown() && !m_listview.IsVisible())
      ChangeObjectsColor();
   else
     {
      //--- If the form and the element are not blocked
      if(!m_wnd.IsLocked() && m_combobox_state)
         ChangeObjectsColor();
     }
  }
//+------------------------------------------------------------------+
//| Creates a group of the combobox objects                          |
//+------------------------------------------------------------------+
bool CComboBox::CreateComboBox(const long chart_id,const int subwin,const string label_text,const int x_gap,const int y_gap)
  {
//--- Exit if there is no pointer to the form
   if(!CElement::CheckWindowPointer())
      return(false);
//--- Initializing variables
   m_id         =m_wnd.LastId()+1;
   m_chart_id   =chart_id;
   m_subwin     =subwin;
   m_x          =CElement::CalculateX(x_gap);
   m_y          =CElement::CalculateY(y_gap);
   m_label_text =label_text;
   m_area_color =(m_area_color!=clrNONE)? m_area_color : m_wnd.WindowBgColor();
//--- Margins from the edge
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
//--- Creating an element
   if(!CreateArea())
      return(false);
   if(!CreateIcon())
      return(false);
   if(!CreateLabel())
      return(false);
   if(!CreateButton())
      return(false);
   if(!CreateDropArrow())
      return(false);
   if(!CreateList())
      return(false);
//--- Store and set the text in the button
   m_button_text=m_listview.SelectedItemText();
   m_button.Description(m_listview.SelectedItemText());
//--- Hide the element if the window is a dialog one or is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates combobox area                                            |
//+------------------------------------------------------------------+
bool CComboBox::CreateArea(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_combobox_area_"+(string)CElementBase::Id();
//--- Set the object
   if(!m_area.Create(m_chart_id,name,m_subwin,m_x,m_y,m_x_size,m_y_size))
      return(false);
//--- Set properties
   m_area.BackColor(m_area_color);
   m_area.Color(m_area_color);
   m_area.BorderType(BORDER_FLAT);
   m_area.Corner(m_corner);
   m_area.Selectable(false);
   m_area.Z_Order(m_area_zorder);
   m_area.Tooltip("\n");
//--- Store coordinates
   m_area.X(m_x);
   m_area.Y(m_y);
//--- Margins from the edge
   m_area.XGap(CElement::CalculateXGap(m_x));
   m_area.YGap(CElement::CalculateYGap(m_y));
//--- Store the object pointer
   CElementBase::AddToArray(m_area);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the control icon                                         |
//+------------------------------------------------------------------+
bool CComboBox::CreateIcon(void)
  {
//--- Leave, if the icon is not needed
   if(m_icon_file_on=="" || m_icon_file_off=="")
      return(true);
//--- Formation of the window name
   string name="";
   if(m_index==WRONG_VALUE)
      name=CElementBase::ProgramName()+"_combobox_bmp_"+(string)CElementBase::Id();
   else
      name=CElementBase::ProgramName()+"_combobox_bmp_"+(string)CElementBase::Index()+"__"+(string)CElementBase::Id();
//--- Calculate the coordinates
   int x =m_x+m_icon_x_gap;
   int y =m_y+m_icon_y_gap;
//--- Set the object
   if(!m_icon.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_icon.BmpFileOn("::"+m_icon_file_on);
   m_icon.BmpFileOff("::"+m_icon_file_off);
   m_icon.State(true);
   m_icon.Corner(m_corner);
   m_icon.GetInteger(OBJPROP_ANCHOR,m_anchor);
   m_icon.Selectable(false);
   m_icon.Z_Order(m_zorder);
   m_icon.Tooltip("\n");
//--- Store coordinates
   m_icon.X(x);
   m_icon.Y(y);
//--- Margins from the edge
   m_icon.XGap(CElement::CalculateXGap(x));
   m_icon.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_icon);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates combobox label                                           |
//+------------------------------------------------------------------+
bool CComboBox::CreateLabel(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_combobox_lable_"+(string)CElementBase::Id();
//--- Coordinates
   int x=m_x+m_label_x_gap;
   int y=m_y+m_label_y_gap;
   color label_color=(m_combobox_state)? m_label_color : m_label_color_off;
//--- Set the object
   if(!m_label.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_label.Description(m_label_text);
   m_label.Font(CElementBase::Font());
   m_label.FontSize(CElementBase::FontSize());
   m_label.Color(label_color);
   m_label.Corner(m_corner);
   m_label.Anchor(m_anchor);
   m_label.Selectable(false);
   m_label.Z_Order(m_zorder);
   m_label.Tooltip("\n");
//--- Store coordinates
   m_label.X(x);
   m_label.Y(y);
//--- Margins from the edge
   m_label.XGap(CElement::CalculateXGap(x));
   m_label.YGap(CElement::CalculateYGap(y));
//--- Initializing the array gradient
   CElementBase::InitColorArray(label_color,m_label_color_hover,m_label_color_array);
//--- Store the object pointer
   CElementBase::AddToArray(m_label);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates combobox button                                          |
//+------------------------------------------------------------------+
bool CComboBox::CreateButton(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_combobox_button_"+(string)CElementBase::Id();
//--- Coordinates
   int x =m_x+m_x_size-m_button_x_size;
   int y =m_y-1;
//--- Set the object
   if(!m_button.Create(m_chart_id,name,m_subwin,x,y,m_button_x_size,m_button_y_size))
      return(false);
//--- Set properties
   m_button.Font(CElementBase::Font());
   m_button.FontSize(CElementBase::FontSize());
   m_button.Description(m_button_text);
   m_button.Color(m_button_text_color);
   m_button.BackColor(m_button_color);
   m_button.BorderColor(m_button_border_color);
   m_button.Corner(m_corner);
   m_button.Anchor(m_anchor);
   m_button.Selectable(false);
   m_button.Z_Order(m_button_zorder);
   m_button.ReadOnly(true);
   m_button.Tooltip("\n");
//--- Store coordinates
   m_button.X(x);
   m_button.Y(y);
//--- Store the size
   m_button.XSize(m_button_x_size);
   m_button.YSize(m_button_y_size);
//--- Margins from the edge
   m_button.XGap(CElement::CalculateXGap(x));
   m_button.YGap(CElement::CalculateYGap(y));
//--- Initializing the array gradient
   CElementBase::InitColorArray(m_button_color,m_button_color_hover,m_button_color_array);
   CElementBase::InitColorArray(m_button_border_color,m_button_border_color_hover,m_button_border_color_array);
//--- Store the object pointer
   CElementBase::AddToArray(m_button);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create arrow on the combobox                                     |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Controls\\DropOff.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\DropOff_black.bmp"
//---
bool CComboBox::CreateDropArrow(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_combobox_drop_"+(string)CElementBase::Id();
//--- Coordinates
   int x=m_button.X2()-m_drop_arrow_x_gap;
   int y=m_button.Y()+m_drop_arrow_y_gap;
//--- If the icon for the arrow is not specified, then set the default one
   if(m_drop_arrow_file_on=="")
      m_drop_arrow_file_on="Images\\EasyAndFastGUI\\Controls\\DropOff_black.bmp";
   if(m_drop_arrow_file_off=="")
      m_drop_arrow_file_off="Images\\EasyAndFastGUI\\Controls\\DropOff.bmp";
//--- Set the icon
   if(!m_drop_arrow.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_drop_arrow.BmpFileOn("::"+m_drop_arrow_file_on);
   m_drop_arrow.BmpFileOff("::"+m_drop_arrow_file_off);
   m_drop_arrow.State(true);
   m_drop_arrow.Corner(m_corner);
   m_drop_arrow.GetInteger(OBJPROP_ANCHOR,m_anchor);
   m_drop_arrow.Selectable(false);
   m_drop_arrow.Z_Order(m_zorder);
   m_drop_arrow.Tooltip("\n");
//--- Store coordinates
   m_drop_arrow.X(x);
   m_drop_arrow.Y(y);
//--- Store the size
   m_drop_arrow.XSize(m_drop_arrow.X_Size());
   m_drop_arrow.YSize(m_drop_arrow.Y_Size());
//--- Margins from the edge
   m_drop_arrow.XGap(CElement::CalculateXGap(x));
   m_drop_arrow.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_drop_arrow);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the list view                                            |
//+------------------------------------------------------------------+
bool CComboBox::CreateList(void)
  {
//--- Store pointers to the form and the combobox
   m_listview.WindowPointer(m_wnd);
   m_listview.ComboBoxPointer(this);
//--- Coordinates
   int x=CElement::CalculateXGap(CElementBase::X2()-m_button_x_size);
   int y=CElement::CalculateYGap(m_y+m_button_y_size-1);
//--- Set properties
   m_listview.Id(CElementBase::Id());
   m_listview.XSize(m_button_x_size);
   m_listview.AnchorRightWindowSide(m_anchor_right_window_side);
   m_listview.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Create control
   if(!m_listview.CreateListView(m_chart_id,m_subwin,x,y))
      return(false);
//--- Hide the list view
   m_listview.Hide();
   return(true);
  }
//+------------------------------------------------------------------+
//| Set icon for the "ON" state                                      |
//+------------------------------------------------------------------+
void CComboBox::IconFileOn(const string file_path)
  {
   m_icon_file_on=file_path;
   m_icon.BmpFileOn("::"+file_path);
  }
//+------------------------------------------------------------------+
//| Set icon for the "OFF" state                                     |
//+------------------------------------------------------------------+
void CComboBox::IconFileOff(const string file_path)
  {
   m_icon_file_off=file_path;
   m_icon.BmpFileOff("::"+file_path);
  }
//+------------------------------------------------------------------+
//| Stores the passed value in the list view by the specified index  |
//+------------------------------------------------------------------+
void CComboBox::SetItemValue(const int item_index,const string item_text)
  {
   m_listview.SetItemValue(item_index,item_text);
  }
//+------------------------------------------------------------------+
//| Select the item by specified index                               |
//+------------------------------------------------------------------+
void CComboBox::SelectItem(const int item_index)
  {
//--- Select the item in the list view
   m_listview.SelectItem(item_index);
//--- Store and set the text in the button
   m_button_text=m_listview.SelectedItemText();
   m_button.Description(m_listview.SelectedItemText());
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CComboBox::Moving(const int x,const int y,const bool moving_mode=false)
  {
//--- Leave, if the control is hidden
   if(!CElementBase::IsVisible())
      return;
//--- If the management is delegated to the window, identify its location
   if(!moving_mode)
      if(m_wnd.ClampingAreaMouse()!=PRESSED_INSIDE_HEADER)
         return;
//--- If the anchored to the right
   if(m_anchor_right_window_side)
     {
      //--- Storing coordinates in the element fields
      CElementBase::X(m_wnd.X2()-XGap());
      //--- Storing coordinates in the fields of the objects
      m_area.X(m_wnd.X2()-m_area.XGap());
      m_icon.X(m_wnd.X2()-m_icon.XGap());
      m_label.X(m_wnd.X2()-m_label.XGap());
      m_button.X(m_wnd.X2()-m_button.XGap());
      m_drop_arrow.X(m_wnd.X2()-m_drop_arrow.XGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::X(x+XGap());
      //--- Storing coordinates in the fields of the objects
      m_area.X(x+m_area.XGap());
      m_icon.X(x+m_icon.XGap());
      m_label.X(x+m_label.XGap());
      m_button.X(x+m_button.XGap());
      m_drop_arrow.X(x+m_drop_arrow.XGap());
     }
//--- If the anchored to the bottom
   if(m_anchor_bottom_window_side)
     {
      //--- Storing coordinates in the element fields
      CElementBase::Y(m_wnd.Y2()-YGap());
      //--- Storing coordinates in the fields of the objects
      m_area.Y(m_wnd.Y2()-m_area.YGap());
      m_icon.Y(m_wnd.Y2()-m_icon.YGap());
      m_label.Y(m_wnd.Y2()-m_label.YGap());
      m_button.Y(m_wnd.Y2()-m_button.YGap());
      m_drop_arrow.Y(m_wnd.Y2()-m_drop_arrow.YGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::Y(y+YGap());
      //--- Storing coordinates in the fields of the objects
      m_area.Y(y+m_area.YGap());
      m_icon.Y(y+m_icon.YGap());
      m_label.Y(y+m_label.YGap());
      m_button.Y(y+m_button.YGap());
      m_drop_arrow.Y(y+m_drop_arrow.YGap());
     }
//--- Updating coordinates of graphical objects
   m_area.X_Distance(m_area.X());
   m_area.Y_Distance(m_area.Y());
   m_icon.X_Distance(m_icon.X());
   m_icon.Y_Distance(m_icon.Y());
   m_label.X_Distance(m_label.X());
   m_label.Y_Distance(m_label.Y());
   m_button.X_Distance(m_button.X());
   m_button.Y_Distance(m_button.Y());
   m_drop_arrow.X_Distance(m_drop_arrow.X());
   m_drop_arrow.Y_Distance(m_drop_arrow.Y());
  }
//+------------------------------------------------------------------+
//| Shows combobox                                                   |
//+------------------------------------------------------------------+
void CComboBox::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElementBase::IsVisible())
      return;
//--- Make all the objects visible
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_ALL_PERIODS);
//--- Show the list view
   m_listview.Hide();
//--- Visible state
   CElementBase::IsVisible(true);
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
//| Hides combobox                                                   |
//+------------------------------------------------------------------+
void CComboBox::Hide(void)
  {
//--- Leave, if the element is already visible
   if(!CElementBase::IsVisible())
      return;
//--- Hide all objects
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_NO_PERIODS);
//--- Button color
   m_button.BackColor((m_combobox_state)? m_button_color : m_button_color_off);
//--- Hide the list view
   m_listview.Hide();
//--- Visible state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CComboBox::Reset(void)
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
void CComboBox::Delete(void)
  {
//--- Removing objects
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Delete();
//--- Visible state
   CElementBase::IsVisible(true);
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
  }
//+------------------------------------------------------------------+
//| Seth the priorities                                              |
//+------------------------------------------------------------------+
void CComboBox::SetZorders(void)
  {
   m_area.Z_Order(m_area_zorder);
   m_icon.Z_Order(m_zorder);
   m_label.Z_Order(m_zorder);
   m_button.Z_Order(m_button_zorder);
   m_drop_arrow.Z_Order(m_zorder);
   m_listview.SetZorders();
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CComboBox::ResetZorders(void)
  {
   m_area.Z_Order(0);
   m_icon.Z_Order(0);
   m_label.Z_Order(0);
   m_button.Z_Order(0);
   m_drop_arrow.Z_Order(0);
   m_listview.ResetZorders();
  }
//+------------------------------------------------------------------+
//| Reset the color                                                  |
//+------------------------------------------------------------------+
void CComboBox::ResetColors(void)
  {
//--- Leave, if the element is blocked
   if(!m_combobox_state)
      return;
//--- Zero the color
   m_label.Color(m_label_color);
   m_button.BackColor(m_button_color);
//--- Zero the focus
   CElementBase::MouseFocus(false);
  }
//+------------------------------------------------------------------+
//| Changing the object color when the cursor is hovering over it    |
//+------------------------------------------------------------------+
void CComboBox::ChangeObjectsColor(void)
  {
//--- Leave, if the element is blocked
   if(!m_combobox_state)
      return;
//--- Change the object color
   CElementBase::ChangeObjectColor(m_label.Name(),CElementBase::MouseFocus(),OBJPROP_COLOR,m_label_color,m_label_color_hover,m_label_color_array);
   CElementBase::ChangeObjectColor(m_button.Name(),CElementBase::MouseFocus(),OBJPROP_BGCOLOR,m_button_color,m_button_color_hover,m_button_color_array);
   CElementBase::ChangeObjectColor(m_button.Name(),CElementBase::MouseFocus(),OBJPROP_BORDER_COLOR,m_button_border_color,m_button_border_color_hover,m_button_border_color_array);
  }
//+------------------------------------------------------------------+
//| Changing the combobox state                                      |
//+------------------------------------------------------------------+
void CComboBox::ComboBoxState(const bool state)
  {
   m_combobox_state=state;
//--- Set colors corresponding to the current state to the object
   m_icon.State(state);
   m_label.Color((state)? m_label_color : m_label_color_off);
   m_button.Color((state)? m_button_text_color : m_button_text_color_off);
   m_button.BackColor((state)? m_button_color : m_button_color_off);
   m_button.BorderColor((state)? m_button_border_color : m_button_border_color_off);
   m_drop_arrow.State(state);
  }
//+------------------------------------------------------------------+
//| Changes the current state of the combobox for the opposite       |
//+------------------------------------------------------------------+
void CComboBox::ChangeComboBoxListState(void)
  {
//--- Leave, if the element is blocked
   if(!m_combobox_state)
      return;
//--- If the list view is visible
   if(m_listview.IsVisible())
     {
      //--- Hide the list view
      m_listview.Hide();
      //--- Set colors
      m_label.Color(m_label_color_hover);
      m_button.BackColor(m_button_color_hover);
      //--- If this is not a drop-down element
      if(!CElementBase::IsDropdown())
        {
         //--- Unblock the form
         m_wnd.IsLocked(false);
         m_wnd.IdActivatedElement(WRONG_VALUE);
         //--- Send a signal to restore the priorities of the left mouse click
         ::EventChartCustom(m_chart_id,ON_SET_PRIORITIES,CElementBase::Id(),0.0,CElementBase::ClassName());
        }
     }
//--- If the list view is hidden
   else
     {
      //--- Show the list view
      m_listview.Show();
      //--- Set colors
      m_label.Color(m_label_color_hover);
      m_button.BackColor(m_button_color_pressed);
      //--- Block the form
      m_wnd.IsLocked(true);
      m_wnd.IdActivatedElement(CElementBase::Id());
     }
  }
//+------------------------------------------------------------------+
//| Pressing on the combobox button                                  |
//+------------------------------------------------------------------+
bool CComboBox::OnClickButton(const string clicked_object)
  {
//--- Leave, if the form is blocked and identifiers do not match
   if(m_wnd.IsLocked() && !CElement::CheckIdActivatedElement())
      return(false);
//--- Leave, if it has a different object name  
   if(clicked_object!=m_button.Name())
      return(false);
//--- Change the list view state
   ChangeComboBoxListState();
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_CLICK_COMBOBOX_BUTTON,CElementBase::Id(),0,"");
   return(true);
  }
//+------------------------------------------------------------------+
//| Check of the pressed left mouse button over the button           |
//+------------------------------------------------------------------+
void CComboBox::CheckPressedOverButton(void)
  {
//--- Leave, if the element is blocked
   if(!m_combobox_state)
      return;
//--- Leave, if the left mouse button is released
   if(!m_mouse.LeftButtonState())
      return;
//--- Leave, if the form is blocked and identifiers do not match
   if(m_wnd.IsLocked() && !CElement::CheckIdActivatedElement())
      return;
//--- If there is no focus
   if(!CElementBase::MouseFocus())
     {
      //--- Leave, if the focus is not over the list view or the scrollbar is enabled
      if(m_listview.MouseFocus() || m_listview.ScrollState())
         return;
      //--- Hide the list view
      m_listview.Hide();
      //--- Restore colors
      ResetColors();
      //--- If identifiers match and the element is not a drop-down
      if(CElement::CheckIdActivatedElement() && !CElementBase::IsDropdown())
        {
         //--- Unblock the form
         m_wnd.IsLocked(false);
         m_wnd.IdActivatedElement(WRONG_VALUE);
         //--- Send a signal to restore the priorities of the left mouse click
         ::EventChartCustom(m_chart_id,ON_SET_PRIORITIES,CElementBase::Id(),0.0,CElementBase::ClassName());
        }
     }
//--- If there is focus
   else
     {
      //--- Leave, if the list view is visible
      if(m_listview.IsVisible())
         return;
      //--- Set the color considering the focus
      if(m_button.MouseFocus())
         m_button.BackColor(m_button_color_pressed);
      else
         m_button.BackColor(m_button_color_hover);
     }
  }
//+------------------------------------------------------------------+
