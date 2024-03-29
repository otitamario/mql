//+------------------------------------------------------------------+
//|                                                  SplitButton.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "ContextMenu.mqh"
//+------------------------------------------------------------------+
//| Class for creating a split button                                |
//+------------------------------------------------------------------+
class CSplitButton : public CElement
  {
private:
   //--- Object for creating a button
   CButton           m_button;
   CBmpLabel         m_icon;
   CLabel            m_label;
   CEdit             m_drop_button;
   CBmpLabel         m_drop_arrow;
   CContextMenu      m_drop_menu;
   //--- Button properties:
   //    Size and priority of the button for the left mouse click
   int               m_button_x_size;
   int               m_button_y_size;
   int               m_button_zorder;
   //--- Background colors
   color             m_back_color;
   color             m_back_color_off;
   color             m_back_color_pressed;
   color             m_back_color_hover;
   color             m_back_color_array[];
   //--- Frame colors
   color             m_border_color;
   color             m_border_color_off;
   color             m_border_color_hover;
   color             m_border_color_array[];
   //--- Size and priority of the left mouse click for the button with a drop-down menu
   int               m_drop_button_x_size;
   int               m_drop_button_zorder;
   //--- Icon margins
   int               m_drop_arrow_x_gap;
   int               m_drop_arrow_y_gap;
   //--- Icons of the button with a drop-down menu in the active and blocked states
   string            m_drop_arrow_file_on;
   string            m_drop_arrow_file_off;
   //--- Icon margins
   int               m_icon_x_gap;
   int               m_icon_y_gap;
   //--- Icons for the button in both active and blocked states
   string            m_icon_file_on;
   string            m_icon_file_off;
   //--- Text and margins of the text label
   string            m_label_text;
   int               m_label_x_gap;
   int               m_label_y_gap;
   //--- Colors of the text label
   color             m_label_color;
   color             m_label_color_off;
   color             m_label_color_hover;
   color             m_label_color_pressed;
   color             m_label_color_array[];
   //--- General priority of unclickable objects
   int               m_zorder;
   //--- Available/blocked
   bool              m_button_state;
   //--- State of the context menu 
   bool              m_drop_menu_state;
   //---
public:
                     CSplitButton(void);
                    ~CSplitButton(void);
   //--- Methods for creating a button
   bool              CreateSplitButton(const long chart_id,const int subwin,const string button_text,const int x_gap,const int y_gap);
   //---
private:
   bool              CreateButton(void);
   bool              CreateIcon(void);
   bool              CreateLabel(void);
   bool              CreateDropButton(void);
   bool              CreateDropIcon(void);
   bool              CreateDropMenu(void);
   //---
public:
   //--- (1) get the pointer to context menu, (2) general state of the button (available/blocked)
   CContextMenu     *GetContextMenuPointer(void)              { return(::GetPointer(m_drop_menu));  }
   bool              ButtonState(void)                  const { return(m_button_state);             }
   void              ButtonState(const bool state);
   //--- Size of the main button and the button with a drop-down menu
   void              ButtonXSize(const int x_size)            { m_button_x_size=x_size;             }
   void              ButtonYSize(const int y_size)            { m_button_y_size=y_size;             }
   void              DropButtonXSize(const int x_size)        { m_drop_button_x_size=x_size;        }
   //--- Setting up the color of the button frame
   void              BorderColor(const color clr)             { m_border_color=clr;                 }
   void              BorderColorOff(const color clr)          { m_border_color_off=clr;             }
   void              BorderColorHover(const color clr)        { m_border_color_hover=clr;           }
   //--- Icon margins
   void              IconXGap(const int x_gap)                { m_icon_x_gap=x_gap;                 }
   void              IconYGap(const int y_gap)                { m_icon_y_gap=y_gap;                 }
   //--- Background colors
   void              BackColor(const color clr)               { m_back_color=clr;                   }
   void              BackColorOff(const color clr)            { m_back_color_off=clr;               }
   void              BackColorHover(const color clr)          { m_back_color_hover=clr;             }
   void              BackColorPressed(const color clr)        { m_back_color_pressed=clr;           }
   //--- (1) Text and (2) margins of the text label
   string            Text(void)                         const { return(m_label.Description());      }
   void              Text(const string text)                  { m_label.Description(text);          }
   void              LabelXGap(const int x_gap)               { m_label_x_gap=x_gap;                }
   void              LabelYGap(const int y_gap)               { m_label_y_gap=y_gap;                }
   //--- Colors of the text label
   void              LabelColor(const color clr)              { m_label_color=clr;                  }
   void              LabelColorOff(const color clr)           { m_label_color_off=clr;              }
   void              LabelColorHover(const color clr)         { m_label_color_hover=clr;            }
   void              LabelColorPressed(const color clr)       { m_label_color_pressed=clr;          }
   //--- Setting icons for the button with a drop-down menu in the active and blocked states
   void              DropArrowFileOn(const string file_path)  { m_drop_arrow_file_on=file_path;     }
   void              DropArrowFileOff(const string file_path) { m_drop_arrow_file_off=file_path;    }
   //--- Icon margins
   void              DropArrowXGap(const int x_gap)           { m_drop_arrow_x_gap=x_gap;           }
   void              DropArrowYGap(const int y_gap)           { m_drop_arrow_y_gap=y_gap;           }
   //--- Adds a menu item with specified properties before the creation of a context menu
   void              AddItem(const string text,const string path_bmp_on,const string path_bmp_off);
   //--- Adds a separation line after the specified item before the creation of the context menu
   void              AddSeparateLine(const int item_index);
   //--- Setting labels for the button in the active and blocked states
   void              IconFileOn(const string file_path);
   void              IconFileOff(const string file_path);
   //--- Changing the color
   void              ChangeObjectsColor(void);
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
   //---
private:
   //--- Handling of pressing the button
   bool              OnClickButton(const string clicked_object);
   //--- Handling the pressing of the button with a drop down menu
   bool              OnClickDropButton(const string clicked_object);
   //--- Check of the pressed left mouse button over a split button
   void              CheckPressedOverButton(const bool mouse_state);
   //--- Hides the drop-down menu
   void              HideDropDownMenu(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSplitButton::CSplitButton(void) : m_drop_menu_state(false),
                                   m_button_state(true),
                                   m_icon_x_gap(4),
                                   m_icon_y_gap(3),
                                   m_label_x_gap(25),
                                   m_label_y_gap(4),
                                   m_drop_button_x_size(17),
                                   m_drop_arrow_x_gap(0),
                                   m_drop_arrow_y_gap(3),
                                   m_drop_arrow_file_on(""),
                                   m_drop_arrow_file_off(""),
                                   m_icon_file_on(""),
                                   m_icon_file_off(""),
                                   m_button_y_size(18),
                                   m_border_color(C'150,170,180'),
                                   m_border_color_off(C'178,195,207'),
                                   m_border_color_hover(C'150,170,180'),
                                   m_back_color(clrGainsboro),
                                   m_back_color_off(clrLightGray),
                                   m_back_color_hover(C'193,218,255'),
                                   m_back_color_pressed(C'190,190,200'),
                                   m_label_color(clrBlack),
                                   m_label_color_off(clrDarkGray),
                                   m_label_color_hover(clrBlack),
                                   m_label_color_pressed(clrBlack)
  {
//--- Store the name of the element class in the base class  
   CElementBase::ClassName(CLASS_NAME);
//--- Set priorities of the left mouse button click
   m_zorder             =0;
   m_button_zorder      =1;
   m_drop_button_zorder =2;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSplitButton::~CSplitButton(void)
  {
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CSplitButton::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
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
      m_drop_button.MouseFocus(m_mouse.X()>m_drop_button.X() && m_mouse.X()<m_drop_button.X2() && 
                               m_mouse.Y()>m_drop_button.Y() && m_mouse.Y()<m_drop_button.Y2());
      //--- Leave, if the button is blocked
      if(!m_button_state)
         return;
      //--- Outside of the element area and with pressed mouse button
      if(!CElementBase::MouseFocus() && m_mouse.LeftButtonState())
        {
         //--- Leave, if the focus is in the context menu
         if(m_drop_menu.MouseFocus())
            return;
         //--- Hide the drop-down menu
         HideDropDownMenu();
         return;
        }
      //--- Check of the pressed left mouse button over a split button
      CheckPressedOverButton(m_mouse.LeftButtonState());
      return;
     }
//--- Handling the event of pressing of the free menu item
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_FREEMENU_ITEM)
     {
      //--- Leave, if the identifiers do not match
      if(CElementBase::Id()!=lparam)
         return;
      //--- Hide the drop-down menu
      HideDropDownMenu();
      //--- Send a message
      ::EventChartCustom(m_chart_id,ON_CLICK_CONTEXTMENU_ITEM,lparam,dparam,sparam);
      return;
     }
//--- Handling the left mouse button click on the object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- Pressing of the simple button
      if(OnClickButton(sparam))
         return;
      //--- Pressing of the button with a drop-down menu
      if(OnClickDropButton(sparam))
         return;
     }
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CSplitButton::OnEventTimer(void)
  {
//--- If this is a drop-down element
   if(CElementBase::IsDropdown())
      ChangeObjectsColor();
   else
     {
      //--- If the form and the button are not blocked
      if(!m_wnd.IsLocked() && m_button_state)
         ChangeObjectsColor();
     }
  }
//+------------------------------------------------------------------+
//| Create "Button" control                                          |
//+------------------------------------------------------------------+
bool CSplitButton::CreateSplitButton(const long chart_id,const int subwin,const string button_text,const int x_gap,const int y_gap)
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
   m_label_text =button_text;
//--- Margins from the edge
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
//--- Creating a button
   if(!CreateButton())
      return(false);
   if(!CreateIcon())
      return(false);
   if(!CreateLabel())
      return(false);
   if(!CreateDropButton())
      return(false);
   if(!CreateDropIcon())
      return(false);
   if(!CreateDropMenu())
      return(false);
//--- Hide the list view
   m_drop_menu.Hide();
//--- Hide the element if the window is a dialog one or is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the button background                                    |
//+------------------------------------------------------------------+
bool CSplitButton::CreateButton(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_split_button_"+(string)CElementBase::Id();
//--- Set the background
   if(!m_button.Create(m_chart_id,name,m_subwin,m_x,m_y,m_button_x_size,m_button_y_size))
      return(false);
//--- Set properties
   m_button.Font(CElementBase::Font());
   m_button.FontSize(CElementBase::FontSize());
   m_button.Color(m_back_color);
   m_button.Description("");
   m_button.BorderColor(m_border_color);
   m_button.BackColor(m_back_color);
   m_button.Corner(m_corner);
   m_button.Anchor(m_anchor);
   m_button.Selectable(false);
   m_button.Z_Order(m_button_zorder);
   m_button.Tooltip("\n");
//--- Store the size
   CElementBase::XSize(m_button_x_size);
   CElementBase::YSize(m_button_y_size);
//--- Margins from the edge
   m_button.XGap(CElement::CalculateXGap(m_x));
   m_button.YGap(CElement::CalculateYGap(m_y));
//--- Initializing the array gradient
   CElementBase::InitColorArray(m_back_color,m_back_color_hover,m_back_color_array);
//--- Store the object pointer
   CElementBase::AddToArray(m_button);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the button icon                                          |
//+------------------------------------------------------------------+
bool CSplitButton::CreateIcon(void)
  {
//--- Leave, if the icon is not needed
   if(m_icon_file_on=="" || m_icon_file_off=="")
      return(true);
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_split_button_bmp_"+(string)CElementBase::Id();
//--- Coordinates
   int x =m_x+m_icon_x_gap;
   int y =m_y+m_icon_y_gap;
//--- Set the icon
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
//--- Margins from the edge
   m_icon.XGap(CElement::CalculateXGap(x));
   m_icon.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_icon);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the button text                                          |
//+------------------------------------------------------------------+
bool CSplitButton::CreateLabel(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_split_button_lable_"+(string)CElementBase::Id();
//--- Coordinates
   int x =m_x+m_label_x_gap;
   int y =m_y+m_label_y_gap;
//--- Set the text label
   if(!m_label.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_label.Description(m_label_text);
   m_label.Font(CElementBase::Font());
   m_label.FontSize(CElementBase::FontSize());
   m_label.Color(m_label_color);
   m_label.Corner(m_corner);
   m_label.Anchor(m_anchor);
   m_label.Selectable(false);
   m_label.Z_Order(m_zorder);
   m_label.Tooltip("\n");
//--- Margins from the edge
   m_label.XGap(CElement::CalculateXGap(x));
   m_label.YGap(CElement::CalculateYGap(y));
//--- Initializing the array gradient
   CElementBase::InitColorArray(m_label_color,m_label_color_hover,m_label_color_array);
//--- Store the object pointer
   CElementBase::AddToArray(m_label);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates combobox button                                          |
//+------------------------------------------------------------------+
bool CSplitButton::CreateDropButton(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_split_button_drop_button_"+(string)CElementBase::Id();
//--- Coordinates
   int x =m_x+m_x_size-m_drop_button_x_size;
   int y =m_y;
//--- Set up a button
   if(!m_drop_button.Create(m_chart_id,name,m_subwin,x,y,m_drop_button_x_size,m_button_y_size))
      return(false);
//--- Set properties
   m_drop_button.Font(CElementBase::Font());
   m_drop_button.FontSize(CElementBase::FontSize());
   m_drop_button.Color(clrNONE);
   m_drop_button.Description("");
   m_drop_button.BackColor(m_back_color);
   m_drop_button.BorderColor(m_border_color);
   m_drop_button.Corner(m_corner);
   m_drop_button.Anchor(m_anchor);
   m_drop_button.Selectable(false);
   m_drop_button.Z_Order(m_drop_button_zorder);
   m_drop_button.ReadOnly(true);
   m_drop_button.Tooltip("\n");
//--- Store coordinates
   m_drop_button.X(x);
   m_drop_button.Y(y);
//--- Store the size
   m_drop_button.XSize(m_drop_button_x_size);
   m_drop_button.YSize(m_button_y_size);
//--- Margins from the edge
   m_drop_button.XGap(CElement::CalculateXGap(x));
   m_drop_button.YGap(CElement::CalculateYGap(y));
//--- Initializing gradient arrays
   CElementBase::InitColorArray(m_border_color,m_border_color_hover,m_border_color_array);
   CElementBase::InitColorArray(m_back_color,m_back_color_hover,m_back_color_array);
//--- Store the object pointer
   CElementBase::AddToArray(m_drop_button);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create icon on combobox                                          |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Controls\\DropOff.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\DropOff_black.bmp"
//---
bool CSplitButton::CreateDropIcon(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_split_button_combobox_icon_"+(string)CElementBase::Id();
//--- Coordinates
   int x =m_drop_button.X()+m_drop_arrow_x_gap;
   int y =m_drop_button.Y()+m_drop_arrow_y_gap;
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
//--- Store sizes (in object)
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
//| Creates a drop-down menu                                         |
//+------------------------------------------------------------------+
bool CSplitButton::CreateDropMenu(void)
  {
//--- Pass the panel object
   m_drop_menu.WindowPointer(m_wnd);
//--- Detached context menu
   m_drop_menu.FreeContextMenu(true);
//--- Coordinates
   int x=CElement::CalculateXGap(m_x);
   int y=CElement::CalculateYGap(m_y+m_y_size);
//--- Set properties
   m_drop_menu.Id(CElementBase::Id());
   m_drop_menu.XSize((m_drop_menu.XSize()>0)? m_drop_menu.XSize() : m_button_x_size);
   m_drop_menu.AnchorRightWindowSide(m_anchor_right_window_side);
   m_drop_menu.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Set up a context menu
   if(!m_drop_menu.CreateContextMenu(m_chart_id,m_subwin,x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Adds a menu item                                                 |
//+------------------------------------------------------------------+
void CSplitButton::AddItem(const string text,const string path_bmp_on,const string path_bmp_off)
  {
   m_drop_menu.AddItem(text,path_bmp_on,path_bmp_off,MI_SIMPLE);
  }
//+------------------------------------------------------------------+
//| Adds a separation line                                           |
//+------------------------------------------------------------------+
void CSplitButton::AddSeparateLine(const int item_index)
  {
   m_drop_menu.AddSeparateLine(item_index);
  }
//+------------------------------------------------------------------+
//| Set icon for the "ON" state                                      |
//+------------------------------------------------------------------+
void CSplitButton::IconFileOn(const string file_path)
  {
   m_icon_file_on=file_path;
   m_icon.BmpFileOn("::"+file_path);
  }
//+------------------------------------------------------------------+
//| Set icon for the "OFF" state                                     |
//+------------------------------------------------------------------+
void CSplitButton::IconFileOff(const string file_path)
  {
   m_icon_file_off=file_path;
   m_icon.BmpFileOff("::"+file_path);
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CSplitButton::Moving(const int x,const int y,const bool moving_mode=false)
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
      m_button.X(m_wnd.X2()-m_button.XGap());
      m_icon.X(m_wnd.X2()-m_icon.XGap());
      m_label.X(m_wnd.X2()-m_label.XGap());
      m_drop_button.X(m_wnd.X2()-m_drop_button.XGap());
      m_drop_arrow.X(m_wnd.X2()-m_drop_arrow.XGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::X(x+XGap());
      //--- Storing coordinates in the fields of the objects
      m_button.X(x+m_button.XGap());
      m_icon.X(x+m_icon.XGap());
      m_label.X(x+m_label.XGap());
      m_drop_button.X(x+m_drop_button.XGap());
      m_drop_arrow.X(x+m_drop_arrow.XGap());
     }
//--- If the anchored to the bottom
   if(m_anchor_bottom_window_side)
     {
      //--- Storing coordinates in the element fields
      CElementBase::Y(m_wnd.Y2()-YGap());
      //--- Storing coordinates in the fields of the objects
      m_button.Y(m_wnd.Y2()-m_button.YGap());
      m_icon.Y(m_wnd.Y2()-m_icon.YGap());
      m_label.Y(m_wnd.Y2()-m_label.YGap());
      m_drop_button.Y(m_wnd.Y2()-m_drop_button.YGap());
      m_drop_arrow.Y(m_wnd.Y2()-m_drop_arrow.YGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::Y(y+YGap());
      //--- Storing coordinates in the fields of the objects
      m_button.Y(y+m_button.YGap());
      m_icon.Y(y+m_icon.YGap());
      m_label.Y(y+m_label.YGap());
      m_drop_button.Y(y+m_drop_button.YGap());
      m_drop_arrow.Y(y+m_drop_arrow.YGap());
     }
//--- Updating coordinates of graphical objects
   m_button.X_Distance(m_button.X());
   m_button.Y_Distance(m_button.Y());
   m_icon.X_Distance(m_icon.X());
   m_icon.Y_Distance(m_icon.Y());
   m_label.X_Distance(m_label.X());
   m_label.Y_Distance(m_label.Y());
   m_drop_button.X_Distance(m_drop_button.X());
   m_drop_button.Y_Distance(m_drop_button.Y());
   m_drop_arrow.X_Distance(m_drop_arrow.X());
   m_drop_arrow.Y_Distance(m_drop_arrow.Y());
  }
//+------------------------------------------------------------------+
//| Shows the button                                                 |
//+------------------------------------------------------------------+
void CSplitButton::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElementBase::IsVisible())
      return;
//--- Make all the objects visible
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_ALL_PERIODS);
//--- Visible state
   CElementBase::IsVisible(true);
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
//| Hides the button                                                 |
//+------------------------------------------------------------------+
void CSplitButton::Hide(void)
  {
//--- Leave, if the control is hidden
   if(!CElementBase::IsVisible())
      return;
//--- Hide all objects
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_NO_PERIODS);
//--- Hide the list view
   m_drop_menu.Hide();
//--- Visible state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CSplitButton::Reset(void)
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
void CSplitButton::Delete(void)
  {
//--- Removing objects
   m_button.Delete();
   m_icon.Delete();
   m_label.Delete();
   m_drop_button.Delete();
   m_drop_arrow.Delete();
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
//--- Initializing of variables by default values
   CElementBase::MouseFocus(false);
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Seth the priorities                                              |
//+------------------------------------------------------------------+
void CSplitButton::SetZorders(void)
  {
   m_icon.Z_Order(m_zorder);
   m_label.Z_Order(m_zorder);
   m_drop_arrow.Z_Order(m_zorder);
   m_drop_button.Z_Order(m_drop_button_zorder);
   m_button.Z_Order(m_button_zorder);
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CSplitButton::ResetZorders(void)
  {
   m_button.Z_Order(-1);
   m_icon.Z_Order(-1);
   m_label.Z_Order(-1);
   m_drop_button.Z_Order(-1);
   m_drop_arrow.Z_Order(-1);
  }
//+------------------------------------------------------------------+
//| Changing the object color when the cursor is hovering over it    |
//+------------------------------------------------------------------+
void CSplitButton::ChangeObjectsColor(void)
  {
   CElementBase::ChangeObjectColor(m_label.Name(),CElementBase::MouseFocus(),OBJPROP_COLOR,m_label_color,m_label_color_hover,m_label_color_array);
   CElementBase::ChangeObjectColor(m_button.Name(),CElementBase::MouseFocus(),OBJPROP_BGCOLOR,m_back_color,m_back_color_hover,m_back_color_array);
   CElementBase::ChangeObjectColor(m_drop_button.Name(),CElementBase::MouseFocus(),OBJPROP_BGCOLOR,m_back_color,m_back_color_hover,m_back_color_array);
   CElementBase::ChangeObjectColor(m_button.Name(),CElementBase::MouseFocus(),OBJPROP_BORDER_COLOR,m_border_color,m_border_color_hover,m_border_color_array);
   CElementBase::ChangeObjectColor(m_drop_button.Name(),CElementBase::MouseFocus(),OBJPROP_BORDER_COLOR,m_border_color,m_border_color_hover,m_border_color_array);
  }
//+------------------------------------------------------------------+
//| Changing the button state                                        |
//+------------------------------------------------------------------+
void CSplitButton::ButtonState(const bool state)
  {
   m_button_state=state;
//--- Set colors corresponding to the current state to the object
   m_icon.State(state);
   m_label.Color((state)? m_label_color : m_label_color_off);
   m_button.State(false);
   m_button.BackColor((state)? m_back_color : m_back_color_off);
   m_button.BorderColor((state)? m_border_color : m_border_color_off);
   m_drop_button.BackColor((state)? m_back_color : m_back_color_off);
   m_drop_button.BorderColor((state)? m_border_color : m_border_color_off);
   m_drop_arrow.State(state);
  }
//+------------------------------------------------------------------+
//| Pressing the button                                              |
//+------------------------------------------------------------------+
bool CSplitButton::OnClickButton(const string clicked_object)
  {
//--- Leave, if it has a different object name  
   if(clicked_object!=m_button.Name())
      return(false);
//--- Leave, if the button is blocked
   if(!m_button_state)
     {
      //--- Unpress the button
      m_button.State(false);
      return(false);
     }
//--- Hide the menu
   m_drop_menu.Hide();
   m_drop_menu_state=false;
//--- Unpress the button and set up the color of the focus
   m_button.State(false);
   m_button.BackColor(m_back_color_hover);
   m_drop_button.BackColor(m_back_color_hover);
//--- Unblock the form
   m_wnd.IsLocked(false);
   m_wnd.IdActivatedElement(WRONG_VALUE);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_CLICK_BUTTON,CElementBase::Id(),CElementBase::Index(),m_label.Description());
   return(true);
  }
//+------------------------------------------------------------------+
//| Pressing of the button with a drop-down menu                     |
//+------------------------------------------------------------------+
bool CSplitButton::OnClickDropButton(const string clicked_object)
  {
//--- Leave, if it has a different object name  
   if(clicked_object!=m_drop_button.Name())
      return(false);
//--- Leave, if the button is blocked
   if(!m_button_state)
     {
      //--- Unpress the button
      m_button.State(false);
      return(false);
     }
//--- If the list is shown, hide it
   if(m_drop_menu_state)
     {
      m_drop_menu_state=false;
      m_drop_menu.Hide();
      m_button.BackColor(m_back_color_hover);
      m_drop_button.BackColor(m_back_color_hover);
      //--- Unblock the form and zero the activating element id
      m_wnd.IsLocked(false);
      m_wnd.IdActivatedElement(WRONG_VALUE);
     }
//--- If the list is hidden, show it
   else
     {
      m_drop_menu_state=true;
      m_drop_menu.Show();
      m_button.BackColor(m_back_color_hover);
      m_drop_button.BackColor(m_back_color_pressed);
      //--- Block the form and store the activating element id
      m_wnd.IsLocked(true);
      m_wnd.IdActivatedElement(CElementBase::Id());
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Check of the pressed left mouse button over a split button       |
//+------------------------------------------------------------------+
void CSplitButton::CheckPressedOverButton(const bool mouse_state)
  {
//--- Leave, if it is outside of the element area
   if(!CElementBase::MouseFocus())
      return;
//--- Leave, if the form is blocked and the identifiers of the form and this element do not match
   if(m_wnd.IsLocked() && !CElement::CheckIdActivatedElement())
      return;
//--- Mouse button pressed
   if(mouse_state)
     {
      //--- In the menu button area
      if(m_drop_button.MouseFocus())
        {
         m_button.BackColor(m_back_color_hover);
         m_drop_button.BackColor(m_back_color_pressed);
        }
      else
        {
         m_button.BackColor(m_back_color_pressed);
         m_drop_button.BackColor(m_back_color_pressed);
        }
     }
//--- Mouse button unpressed
   else
     {
      if(m_drop_menu_state)
        {
         m_button.BackColor(m_back_color_hover);
         m_drop_button.BackColor(m_back_color_pressed);
        }
     }
  }
//+------------------------------------------------------------------+
//| Hides a drop-down menu                                           |
//+------------------------------------------------------------------+
void CSplitButton::HideDropDownMenu(void)
  {
//--- Hide the menu and set up corresponding indications
   m_drop_menu.Hide();
   m_drop_menu_state=false;
   m_button.BackColor(m_back_color);
   m_drop_button.BackColor(m_back_color);
//--- Unblock the form if the identifiers of the form and this element match
   if(CElement::CheckIdActivatedElement())
     {
      m_wnd.IsLocked(false);
      m_wnd.IdActivatedElement(WRONG_VALUE);
     }
  }
//+------------------------------------------------------------------+
