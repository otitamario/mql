//+------------------------------------------------------------------+
//|                                                  ColorButton.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
//+------------------------------------------------------------------+
//| Class for creating buttons to call the color picker              |
//+------------------------------------------------------------------+
class CColorButton : public CElement
  {
private:
   //--- Objects for creating the element
   CRectLabel        m_area;
   CBmpLabel         m_icon;
   CLabel            m_label;
   CButton           m_button;
   CRectLabel        m_button_icon;
   CLabel            m_button_label;
   //--- Background color
   color             m_area_color;
   //--- Control icons in the active and blocked states
   string            m_icon_file_on;
   string            m_icon_file_off;
   //--- Icon margins
   int               m_icon_x_gap;
   int               m_icon_y_gap;
   //--- Description text
   string            m_label_text;
   //--- Description indents
   int               m_label_x_gap;
   int               m_label_y_gap;
   //--- Color of the description in different states
   color             m_label_color;
   color             m_label_color_off;
   color             m_label_color_hover;
   color             m_label_color_array[];
   //--- Button sizes
   int               m_button_x_size;
   int               m_button_y_size;
   //--- Color of the button in different states
   color             m_back_color;
   color             m_back_color_off;
   color             m_back_color_hover;
   color             m_back_color_pressed;
   color             m_back_color_array[];
   //--- Frame color
   color             m_border_color;
   color             m_border_color_off;
   color             m_border_color_hover;
   color             m_border_color_array[];
   //--- Color of the button text in different states
   color             m_button_label_color;
   color             m_button_label_color_off;
   color             m_button_label_color_hover;
   color             m_button_label_color_pressed;
   color             m_button_label_color_array[];
   //--- Available/blocked
   bool              m_button_state;
   //--- Selected color
   color             m_current_color;
   //--- Priorities of the left mouse button press
   int               m_button_zorder;
   int               m_zorder;
   //---
public:
                     CColorButton(void);
                    ~CColorButton(void);
   //--- Methods for creating the control
   bool              CreateColorButton(const long chart_id,const int subwin,const string button_text,const int x_gap,const int y_gap);
   //---
private:
   bool              CreateArea(void);
   bool              CreateIcon(void);
   bool              CreateLabel(void);
   bool              CreateButton(void);
   bool              CreateButtonIcon(void);
   bool              CreateButtonLabel(void);
   //---
public:
   //--- (1) Icon margins, (2) setting the state of the control
   void              IconXGap(const int x_gap)                { m_icon_x_gap=x_gap;            }
   void              IconYGap(const int y_gap)                { m_icon_y_gap=y_gap;            }
   bool              ButtonState(void) const            const { return(m_button_state);        }
   void              ButtonState(const bool state);
   //--- Color (1) of the control background, (2) button sizes
   void              AreaColor(const color clr)               { m_area_color=clr;              }
   void              ButtonXSize(const int x_size)            { m_button_x_size=x_size;        }
   void              ButtonYSize(const int y_size)            { m_button_y_size=y_size;        }
   //--- (1) Gets/sets the control description, (2) description indents
   string            LabelText(void)                    const { return(m_label.Description()); }
   void              LabelText(const string text)             { m_label.Description(text);     }
   void              LabelXGap(const int x_gap)               { m_label_x_gap=x_gap;           }
   void              LabelYGap(const int y_gap)               { m_label_y_gap=y_gap;           }
   //--- Color of the description text in different states
   void              LabelColor(const color clr)              { m_label_color=clr;             }
   void              LabelColorOff(const color clr)           { m_label_color_off=clr;         }
   void              LabelColorHover(const color clr)         { m_label_color_hover=clr;       }
   //--- Color of the button background in different states
   void              BackColor(const color clr)               { m_back_color=clr;              }
   void              BackColorHover(const color clr)          { m_back_color_hover=clr;        }
   void              BackColorPressed(const color clr)        { m_back_color_pressed=clr;      }
   //--- (1) Colors of the button frame in different states, (2) get/set the current color of the parameter
   void              BorderColor(const color clr)             { m_border_color=clr;            }
   void              BorderColorOff(const color clr)          { m_border_color_off=clr;        }
   color             CurrentColor(void)                 const { return(m_current_color);       }
   void              CurrentColor(const color clr);
   //--- Setting icons for the control in the active and blocked states
   void              IconFileOn(const string file_path);
   void              IconFileOff(const string file_path);
   //--- Changing the color of the element
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
   //--- Zero the color
   virtual void      ResetColors(void);
   //---
private:
   //--- Handling the pressing of a button
   bool              OnClickButton(const string clicked_object);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CColorButton::CColorButton(void) : m_button_state(true),
                                   m_current_color(clrGold),
                                   m_area_color(clrNONE),
                                   m_icon_x_gap(0),
                                   m_icon_y_gap(0),
                                   m_icon_file_on(""),
                                   m_icon_file_off(""),
                                   m_label_x_gap(0),
                                   m_label_y_gap(2),
                                   m_button_y_size(18),
                                   m_label_color(clrBlack),
                                   m_label_color_off(clrSilver),
                                   m_label_color_hover(C'85,170,255'),
                                   m_back_color(C'220,220,220'),
                                   m_back_color_off(C'230,230,230'),
                                   m_back_color_hover(C'193,218,255'),
                                   m_back_color_pressed(C'153,178,215'),
                                   m_border_color(clrSilver),
                                   m_border_color_off(clrSilver),
                                   m_border_color_hover(C'85,170,255'),
                                   m_button_label_color(clrBlack),
                                   m_button_label_color_off(clrDarkGray),
                                   m_button_label_color_hover(clrBlack),
                                   m_button_label_color_pressed(clrBlack)
  {
//--- Store the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
//--- Set priorities of the left mouse button click
   m_button_zorder =1;
   m_zorder        =0;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CColorButton::~CColorButton(void)
  {
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CColorButton::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
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
      m_button.MouseFocus(m_mouse.X()>m_button.X() && m_mouse.X()<m_button.X2() && m_mouse.Y()>m_button.Y() && m_mouse.Y()<m_button.Y2());
      //--- Leave, if the form is blocked
      if(m_wnd.IsLocked())
         return;
      //--- Leave, if the left mouse button is released
      if(!m_mouse.LeftButtonState())
         return;
      //--- Leave, if the button is blocked
      if(!m_button_state)
         return;
      //--- If there is no focus
      if(!CElementBase::MouseFocus())
        {
         m_button.BackColor(m_back_color);
         return;
        }
      //--- If there is a focus
      else
        {
         m_label.Color(m_label_color_hover);
         //--- Set the color considering the focus
         if(m_button.MouseFocus())
            m_button.BackColor(m_back_color_pressed);
         else
            m_button.BackColor(m_back_color_hover);
         //---
         return;
        }
      //---
      return;
     }
//--- Handling the left mouse button click on the object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(OnClickButton(sparam))
         return;
     }
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CColorButton::OnEventTimer(void)
  {
//--- If the element is a drop-down
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
//| Create Button object                                             |
//+------------------------------------------------------------------+
bool CColorButton::CreateColorButton(const long chart_id,const int subwin,const string button_text,const int x_gap,const int y_gap)
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
   m_area_color =(m_area_color!=clrNONE)? m_area_color : m_wnd.WindowBgColor();
//--- Margins from the edge
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
//--- Creating a button
   if(!CreateArea())
      return(false);
   if(!CreateIcon())
      return(false);
   if(!CreateLabel())
      return(false);
   if(!CreateButton())
      return(false);
   if(!CreateButtonIcon())
      return(false);
   if(!CreateButtonLabel())
      return(false);
//--- Hide the element if the window is a dialog one or is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create area                                                      |
//+------------------------------------------------------------------+
bool CColorButton::CreateArea(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_color_button_area_"+(string)CElementBase::Id();
//--- Creating the object
   if(!m_area.Create(m_chart_id,name,m_subwin,m_x,m_y,m_x_size,m_y_size))
      return(false);
//--- Set properties
   m_area.BackColor(m_area_color);
   m_area.Color(m_area_color);
   m_area.BorderType(BORDER_FLAT);
   m_area.Corner(m_corner);
   m_area.Selectable(false);
   m_area.Z_Order(-1);
   m_area.Tooltip("\n");
//--- Margins from the edge
   m_area.XGap(CElement::CalculateXGap(m_x));
   m_area.YGap(CElement::CalculateYGap(m_y));
//--- Store the sizes (in the group)
   CElementBase::XSize(m_x_size);
   CElementBase::YSize(m_y_size);
//--- Store the object pointer
   CElementBase::AddToArray(m_area);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the control icon                                         |
//+------------------------------------------------------------------+
bool CColorButton::CreateIcon(void)
  {
//--- Leave, if the icon is not needed
   if(m_icon_file_on=="" || m_icon_file_off=="")
      return(true);
//--- Formation of the window name
   string name="";
   if(m_index==WRONG_VALUE)
      name=CElementBase::ProgramName()+"_color_button_bmp_"+(string)CElementBase::Id();
   else
      name=CElementBase::ProgramName()+"_color_button_bmp_"+(string)CElementBase::Index()+"__"+(string)CElementBase::Id();
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
//| Create a label                                                   |
//+------------------------------------------------------------------+
bool CColorButton::CreateLabel(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_color_button_lable_"+(string)CElementBase::Id();
//--- Coordinates
   int x =m_x+m_label_x_gap;
   int y =m_y+m_label_y_gap;
//--- Text color according to the state
   color label_color=(m_button_state)? m_label_color : m_label_color_off;
//--- Creating the object
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
//| Creates button                                                   |
//+------------------------------------------------------------------+
bool CColorButton::CreateButton(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_color_button_"+(string)CElementBase::Id();
//--- Coordinates
   int x =m_x+CElementBase::XSize()-m_button_x_size;
   int y =m_y-1;
//--- Creating the object
   if(!m_button.Create(m_chart_id,name,m_subwin,x,y,m_button_x_size,m_button_y_size))
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
   CElementBase::InitColorArray(m_back_color,m_back_color_hover,m_back_color_array);
   CElementBase::InitColorArray(m_border_color,m_border_color_hover,m_border_color_array);
//--- Store the object pointer
   CElementBase::AddToArray(m_button);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the button icon                                          |
//+------------------------------------------------------------------+
bool CColorButton::CreateButtonIcon(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_color_button_marker_"+(string)CElementBase::Id();
//--- Coordinates
   int x =m_button.X()+3;
   int y =m_button.Y()+3;
//--- Creating the object
   if(!m_button_icon.Create(m_chart_id,name,m_subwin,x,y,12,12))
      return(false);
//--- Set properties
   m_button_icon.Corner(m_corner);
   m_button_icon.Color(clrGray);
   m_button_icon.BackColor(m_current_color);
   m_button_icon.Selectable(false);
   m_button_icon.Z_Order(m_button_zorder);
   m_button_icon.BorderType(BORDER_FLAT);
   m_button_icon.Tooltip("\n");
//--- Store coordinates
   m_button_icon.X(x);
   m_button_icon.Y(y);
//--- Store the size
   m_button_icon.XSize(m_button_icon.X_Size());
   m_button_icon.YSize(m_button_icon.Y_Size());
//--- Margins from the edge
   m_button_icon.XGap(CElement::CalculateXGap(x));
   m_button_icon.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_button_icon);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the button text                                          |
//+------------------------------------------------------------------+
bool CColorButton::CreateButtonLabel(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_color_button_text_"+(string)CElementBase::Id();
//--- Coordinates
   int x =m_button.X()+20;
   int y =m_button.Y()+3;
//--- Creating the object
   if(!m_button_label.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_button_label.Description(::ColorToString(m_current_color));
   m_button_label.Font(CElementBase::Font());
   m_button_label.FontSize(CElementBase::FontSize());
   m_button_label.Color(m_button_label_color);
   m_button_label.Corner(m_corner);
   m_button_label.Anchor(m_anchor);
   m_button_label.Selectable(false);
   m_button_label.Z_Order(m_zorder);
   m_button_label.Tooltip("\n");
//--- Margins from the edge
   m_button_label.XGap(CElement::CalculateXGap(x));
   m_button_label.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_button_label);
   return(true);
  }
//+------------------------------------------------------------------+
//| Change the current color of parameter                            |
//+------------------------------------------------------------------+
void CColorButton::CurrentColor(const color clr)
  {
   m_current_color=clr;
   m_button_icon.BackColor(clr);
   m_button_label.Description(::ColorToString(clr));
  }
//+------------------------------------------------------------------+
//| Changing the button state                                        |
//+------------------------------------------------------------------+
void CColorButton::ButtonState(const bool state)
  {
   m_button_state=state;
//--- Set colors corresponding to the current state to the object
   m_icon.State(state);
   m_label.Color((state)? m_label_color : m_label_color_off);
   m_button_label.Color((state)? m_button_label_color : m_button_label_color_off);
   m_button.State(false);
   m_button.BackColor((state)? m_back_color : m_back_color_off);
   m_button.BorderColor((state)? m_border_color : m_border_color_off);
  }
//+------------------------------------------------------------------+
//| Set icon for the "ON" state                                      |
//+------------------------------------------------------------------+
void CColorButton::IconFileOn(const string file_path)
  {
   m_icon_file_on=file_path;
   m_icon.BmpFileOn("::"+file_path);
  }
//+------------------------------------------------------------------+
//| Set icon for the "OFF" state                                     |
//+------------------------------------------------------------------+
void CColorButton::IconFileOff(const string file_path)
  {
   m_icon_file_off=file_path;
   m_icon.BmpFileOff("::"+file_path);
  }
//+------------------------------------------------------------------+
//| Changing the object color when the cursor is hovering over it    |
//+------------------------------------------------------------------+
void CColorButton::ChangeObjectsColor(void)
  {
   color label_color=(m_button_state) ? m_label_color : m_label_color_off;
   CElementBase::ChangeObjectColor(m_label.Name(),CElementBase::MouseFocus(),OBJPROP_COLOR,label_color,m_label_color_hover,m_label_color_array);
   CElementBase::ChangeObjectColor(m_button.Name(),CElementBase::MouseFocus(),OBJPROP_BGCOLOR,m_back_color,m_back_color_hover,m_back_color_array);
   CElementBase::ChangeObjectColor(m_button.Name(),CElementBase::MouseFocus(),OBJPROP_BORDER_COLOR,m_border_color,m_border_color_hover,m_border_color_array);
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CColorButton::Moving(const int x,const int y,const bool moving_mode=false)
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
      m_button_icon.X(m_wnd.X2()-m_button_icon.XGap());
      m_button_label.X(m_wnd.X2()-m_button_label.XGap());
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
      m_button_icon.X(x+m_button_icon.XGap());
      m_button_label.X(x+m_button_label.XGap());
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
      m_button_icon.Y(m_wnd.Y2()-m_button_icon.YGap());
      m_button_label.Y(m_wnd.Y2()-m_button_label.YGap());
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
      m_button_icon.Y(y+m_button_icon.YGap());
      m_button_label.Y(y+m_button_label.YGap());
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
   m_button_icon.X_Distance(m_button_icon.X());
   m_button_icon.Y_Distance(m_button_icon.Y());
   m_button_label.X_Distance(m_button_label.X());
   m_button_label.Y_Distance(m_button_label.Y());
  }
//+------------------------------------------------------------------+
//| Shows the button                                                 |
//+------------------------------------------------------------------+
void CColorButton::Show(void)
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
void CColorButton::Hide(void)
  {
//--- Leave, if the control is hidden
   if(!CElementBase::IsVisible())
      return;
//--- Hide all objects
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_NO_PERIODS);
//--- Visible state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CColorButton::Reset(void)
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
void CColorButton::Delete(void)
  {
   m_area.Delete();
   m_icon.Delete();
   m_label.Delete();
   m_button.Delete();
   m_button_icon.Delete();
   m_button_label.Delete();
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
//--- Initializing of variables by default values
   CElementBase::MouseFocus(false);
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Seth the priorities                                              |
//+------------------------------------------------------------------+
void CColorButton::SetZorders(void)
  {
   m_area.Z_Order(m_zorder);
   m_icon.Z_Order(-1);
   m_label.Z_Order(m_zorder);
   m_button.Z_Order(m_button_zorder);
   m_button_icon.Z_Order(m_zorder);
   m_button_label.Z_Order(m_zorder);
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CColorButton::ResetZorders(void)
  {
   m_area.Z_Order(-1);
   m_icon.Z_Order(-1);
   m_label.Z_Order(-1);
   m_button.Z_Order(-1);
   m_button_icon.Z_Order(-1);
   m_button_label.Z_Order(-1);
  }
//+------------------------------------------------------------------+
//| Reset the color                                                  |
//+------------------------------------------------------------------+
void CColorButton::ResetColors(void)
  {
//--- Leave, if the element is blocked
   if(!m_button_state)
      return;
//--- Reset colors
   m_label.Color(m_label_color);
   m_button.BackColor(m_back_color);
   m_button.BorderColor(m_border_color);
//--- Zero the focus
   m_button.MouseFocus(false);
   CElementBase::MouseFocus(false);
  }
//+------------------------------------------------------------------+
//| Pressing the button                                              |
//+------------------------------------------------------------------+
bool CColorButton::OnClickButton(const string clicked_object)
  {
//--- Leave, if it has a different object name
   if(m_button.Name()!=clicked_object)
      return(false);
//--- Leave, if the button is blocked
   if(!m_button_state)
     {
      m_button.State(false);
      return(false);
     }
//--- Reset the state and color
   m_button.State(false);
   m_label.Color(m_label_color);
   m_button.BackColor(m_back_color);
   m_button.BorderColor(m_border_color);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_CLICK_BUTTON,CElementBase::Id(),CElementBase::Index(),m_label.Description());
   return(true);
  }
//+------------------------------------------------------------------+
