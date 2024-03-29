//+------------------------------------------------------------------+
//|                                                     TimeEdit.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "SpinEdit.mqh"
//+------------------------------------------------------------------+
//| Class for creating the Time control                              |
//+------------------------------------------------------------------+
class CTimeEdit : public CElement
  {
private:
   //--- Objects for creating the element
   CRectLabel        m_area;
   CBmpLabel         m_icon;
   CLabel            m_label;
   CSpinEdit         m_hours;
   CSpinEdit         m_minutes;
   //--- Color of the control background
   color             m_area_color;
   //--- Control icons in the active and blocked states
   string            m_icon_file_on;
   string            m_icon_file_off;
   //--- Icon margins
   int               m_icon_x_gap;
   int               m_icon_y_gap;
   //--- Description text of the control
   string            m_label_text;
   //--- Text label margins
   int               m_label_x_gap;
   int               m_label_y_gap;
   //--- Color of the text in different states
   color             m_label_color;
   color             m_label_color_hover;
   color             m_label_color_locked;
   color             m_label_color_array[];
   //--- Size of the entry field
   int               m_edit_x_size;
   //--- Margins for the Edit box
   int               m_edit_x_gap;
   int               m_edit_y_gap;
   //--- Priorities of the left mouse button press
   int               m_area_zorder;
   int               m_label_zorder;
   //--- Checkbox state (available/blocked)
   bool              m_time_edit_state;
   //--- The mode of resetting the value
   bool              m_reset_mode;
   //---
public:
                     CTimeEdit(void);
                    ~CTimeEdit(void);
   //--- Methods for creating the control
   bool              CreateTimeEdit(const long chart_id,const int subwin,const string label_text,const int x_gap,const int y_gap);
   //---
private:
   bool              CreateArea(void);
   bool              CreateIcon(void);
   bool              CreateLabel(void);
   bool              CreateHoursEdit(void);
   bool              CreateMinutesEdit(void);
   //---
public:
   //--- (1) Return the pointers to edit boxes, (2) get/set the availability state of the control
   CSpinEdit        *GetHoursEditPointer(void)                      { return(::GetPointer(m_hours));     }
   CSpinEdit        *GetMinutesEditPointer(void)                    { return(::GetPointer(m_minutes));   }
   bool              TimeEditState(void)                      const { return(m_time_edit_state);         }
   void              TimeEditState(const bool state);
   //--- (1) Background color, (2) margins for the icon
   void              AreaColor(const color clr)                     { m_area_color=clr;                  }
   void              IconXGap(const int x_gap)                      { m_icon_x_gap=x_gap;                }
   void              IconYGap(const int y_gap)                      { m_icon_y_gap=y_gap;                }
   //--- (1) Text of the control description, (2) margins for the text label
   string            LabelText(void)                          const { return(m_label.Description());     }
   void              LabelText(const string text)                   { m_label.Description(text);         }
   void              LabelXGap(const int x_gap)                     { m_label_x_gap=x_gap;               }
   void              LabelYGap(const int y_gap)                     { m_label_y_gap=y_gap;               }
   //--- Colors of the text label in different states
   void              LabelColor(const color clr)                    { m_label_color=clr;                 }
   void              LabelColorHover(const color clr)               { m_label_color_hover=clr;           }
   void              LabelColorLocked(const color clr)              { m_label_color_locked=clr;          }
   //--- (1) Edit box size, (2) margins for Edit boxes
   void              EditXSize(const int x_size)                    { m_edit_x_size=x_size;              }
   void              EditXGap(const int x_gap)                      { m_edit_x_gap=x_gap;                }
   void              EditYGap(const int y_gap)                      { m_edit_y_gap=y_gap;                }
   //--- (1) Reset mode when pressing the text label, (2) text selection mode
   bool              ResetMode(void)                                { return(m_reset_mode);              }
   void              ResetMode(const bool mode)                     { m_reset_mode=mode;                 }
   //--- Get and set the edit box values
   int               GetHours(void)                           const { return((int)m_hours.GetValue());   }
   int               GetMinutes(void)                         const { return((int)m_minutes.GetValue()); }
   void              SetHours(const uint value)                     { m_hours.ChangeValue(value);        }
   void              SetMinutes(const uint value)                   { m_minutes.ChangeValue(value);      }
   //--- Setting icons for the control in the active and blocked states
   void              IconFileOn(const string file_path);
   void              IconFileOff(const string file_path);
   //--- Changing the object colors
   void              ChangeObjectsColor(void);
   //---
public:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Timer
   virtual void      OnEventTimer(void);
   //--- Moving the element
   virtual void      Moving(const int x,const int y,const bool moving_mode=false);
   //--- (1) Show, (2) hide, (3) reset, (4) delete the control
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
   //--- Handling the press on the text label
   bool              OnClickLabel(const string clicked_object);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTimeEdit::CTimeEdit(void) : m_reset_mode(false),
                             m_time_edit_state(true),
                             m_area_color(clrNONE),
                             m_icon_x_gap(0),
                             m_icon_y_gap(3),
                             m_icon_file_on(""),
                             m_icon_file_off(""),
                             m_label_text(""),
                             m_label_x_gap(0),
                             m_label_y_gap(4),
                             m_label_color(clrBlack),
                             m_label_color_hover(C'85,170,255'),
                             m_label_color_locked(clrSilver),
                             m_edit_x_size(25),
                             m_edit_x_gap(35),
                             m_edit_y_gap(1)

  {
//--- Store the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
//--- Set priorities of the left mouse button click
   m_area_zorder  =1;
   m_label_zorder =0;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTimeEdit::~CTimeEdit(void)
  {
  }
//+------------------------------------------------------------------+
//| Event handling                                                |
//+------------------------------------------------------------------+
void CTimeEdit::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
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
      //--- Verifying the focus
      CElementBase::CheckMouseFocus();
      return;
     }
//--- Handling the left mouse button click on the object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- Leave, if the element is blocked
      if(!m_time_edit_state)
         return;
      //--- Handling the press on the text label
      if(OnClickLabel(sparam))
         return;
      //---
      return;
     }
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CTimeEdit::OnEventTimer(void)
  {
//--- If the element is a drop-down
   if(CElementBase::IsDropdown())
      ChangeObjectsColor();
   else
     {
      //--- Track the change of color and fast switching values, 
      //    only if the form is not blocked
      if(!m_wnd.IsLocked())
         ChangeObjectsColor();
     }
  }
//+------------------------------------------------------------------+
//| Creates the Time control                                         |
//+------------------------------------------------------------------+
bool CTimeEdit::CreateTimeEdit(const long chart_id,const int subwin,const string label_text,const int x_gap,const int y_gap)
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
   if(!CreateHoursEdit())
      return(false);
   if(!CreateMinutesEdit())
      return(false);
//--- Hide the element if the window is a dialog one or is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create area of editable edit control                             |
//+------------------------------------------------------------------+
bool CTimeEdit::CreateArea(void)
  {
//--- Formation of the window name
   string name="";
   if(m_index==WRONG_VALUE)
      name=CElementBase::ProgramName()+"_time_edit_area_"+(string)CElementBase::Id();
   else
      name=CElementBase::ProgramName()+"_time_edit_area_"+(string)CElementBase::Index()+"__"+(string)CElementBase::Id();
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
bool CTimeEdit::CreateIcon(void)
  {
//--- Leave, if the icon is not needed
   if(m_icon_file_on=="" || m_icon_file_off=="")
      return(true);
//--- Formation of the window name
   string name="";
   if(m_index==WRONG_VALUE)
      name=CElementBase::ProgramName()+"_time_edit_bmp_"+(string)CElementBase::Id();
   else
      name=CElementBase::ProgramName()+"_time_edit_bmp_"+(string)CElementBase::Index()+"__"+(string)CElementBase::Id();
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
   m_icon.Z_Order(m_label_zorder);
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
//| Creates the text label of the control                            |
//+------------------------------------------------------------------+
bool CTimeEdit::CreateLabel(void)
  {
//--- Formation of the window name
   string name="";
   if(m_index==WRONG_VALUE)
      name=CElementBase::ProgramName()+"_time_edit_lable_"+(string)CElementBase::Id();
   else
      name=CElementBase::ProgramName()+"_time_edit_lable_"+(string)CElementBase::Index()+"__"+(string)CElementBase::Id();
//--- Coordinates
   int x=m_x+m_label_x_gap;
   int y=m_y+m_label_y_gap;
//--- Set the object
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
   m_label.Z_Order(m_label_zorder);
   m_label.Tooltip("\n");
//--- Store coordinates
   m_label.X(x);
   m_label.Y(y);
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
//| Creates edit box for hours                                       |
//+------------------------------------------------------------------+
bool CTimeEdit::CreateHoursEdit(void)
  {
//--- Store the window pointer
   m_hours.WindowPointer(m_wnd);
//--- Coordinates
   int x=CElement::CalculateXGap(CElementBase::X2()-m_edit_x_gap);
   int y=CElement::CalculateYGap(CElementBase::Y()+m_edit_y_gap);
//--- Set properties before creation
   m_hours.Index(0);
   m_hours.XSize(m_edit_x_size+15);
   m_hours.YSize(m_y_size);
   m_hours.EditXSize(m_edit_x_size);
   m_hours.EditYSize(m_y_size);
   m_hours.MaxValue(23);
   m_hours.MinValue(0);
   m_hours.StepValue(1);
   m_hours.SetDigits(0);
   m_hours.SetValue(12);
   m_hours.AreaColor(m_area_color);
   m_hours.AlignMode(ALIGN_CENTER);
//--- Create control
   if(!m_hours.CreateSpinEdit(m_chart_id,m_subwin,"",x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates edit box for minutes                                     |
//+------------------------------------------------------------------+
bool CTimeEdit::CreateMinutesEdit(void)
  {
//--- Store the window pointer
   m_minutes.WindowPointer(m_wnd);
//--- Coordinates
   int x=CElement::CalculateXGap(m_hours.X2());
   int y=CElement::CalculateYGap(CElementBase::Y()+m_edit_y_gap);
//--- Set properties before creation
   m_minutes.Index(1);
   m_minutes.XSize(m_edit_x_size+15);
   m_minutes.YSize(m_y_size);
   m_minutes.EditXSize(m_edit_x_size);
   m_minutes.EditYSize(m_y_size);
   m_minutes.MaxValue(59);
   m_minutes.MinValue(0);
   m_minutes.StepValue(1);
   m_minutes.SetDigits(0);
   m_minutes.SetValue(30);
   m_minutes.AreaColor(m_area_color);
   m_minutes.AlignMode(ALIGN_CENTER);
//--- Create control
   if(!m_minutes.CreateSpinEdit(m_chart_id,m_subwin,"",x,y))
      return(false);
//--- Adjust the total width of the control
   m_x_size=m_minutes.X2()-CElementBase::X();
   m_area.X_Size(m_x_size);
   return(true);
  }
//+------------------------------------------------------------------+
//| Set icon for the "ON" state                                      |
//+------------------------------------------------------------------+
void CTimeEdit::IconFileOn(const string file_path)
  {
   m_icon_file_on=file_path;
   m_icon.BmpFileOn("::"+file_path);
  }
//+------------------------------------------------------------------+
//| Set icon for the "OFF" state                                     |
//+------------------------------------------------------------------+
void CTimeEdit::IconFileOff(const string file_path)
  {
   m_icon_file_off=file_path;
   m_icon.BmpFileOff("::"+file_path);
  }
//+------------------------------------------------------------------+
//| Setting the state of the control                                 |
//+------------------------------------------------------------------+
void CTimeEdit::TimeEditState(const bool state)
  {
   m_time_edit_state=state;
//--- Icon
   m_icon.State(state);
//--- Color of the text label
   m_label.Color((state)? m_label_color : m_label_color_locked);
//--- Set the states of edit boxes
   m_hours.SpinEditState(m_time_edit_state);
   m_minutes.SpinEditState(m_time_edit_state);
  }
//+------------------------------------------------------------------+
//| Changing the object color when the cursor is hovering over it    |
//+------------------------------------------------------------------+
void CTimeEdit::ChangeObjectsColor(void)
  {
//--- Leave, if the element is blocked
   if(!m_time_edit_state)
      return;
//--- Focus on the text label and edit
   CElementBase::ChangeObjectColor(m_label.Name(),CElementBase::MouseFocus(),OBJPROP_COLOR,m_label_color,m_label_color_hover,m_label_color_array);
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CTimeEdit::Moving(const int x,const int y,const bool moving_mode=false)
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
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::X(x+XGap());
      //--- Storing coordinates in the fields of the objects
      m_area.X(x+m_area.XGap());
      m_icon.X(x+m_icon.XGap());
      m_label.X(x+m_label.XGap());
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
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::Y(y+YGap());
      //--- Storing coordinates in the fields of the objects
      m_area.Y(y+m_area.YGap());
      m_icon.Y(y+m_icon.YGap());
      m_label.Y(y+m_label.YGap());
     }
//--- Updating coordinates of graphical objects
   m_area.X_Distance(m_area.X());
   m_area.Y_Distance(m_area.Y());
   m_icon.X_Distance(m_icon.X());
   m_icon.Y_Distance(m_icon.Y());
   m_label.X_Distance(m_label.X());
   m_label.Y_Distance(m_label.Y());
  }
//+------------------------------------------------------------------+
//| Shows the element                                                |
//+------------------------------------------------------------------+
void CTimeEdit::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElementBase::IsVisible())
      return;
//--- Make all the objects visible
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_ALL_PERIODS);
//--- Make all controls visible
   m_hours.Show();
   m_minutes.Show();
//--- Visible state
   CElementBase::IsVisible(true);
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
//| Hides the element                                                |
//+------------------------------------------------------------------+
void CTimeEdit::Hide(void)
  {
//--- Leave, if the element is already visible
   if(!CElementBase::IsVisible())
      return;
//--- Hide all objects
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_NO_PERIODS);
//--- Hide all controls
   m_hours.Hide();
   m_minutes.Hide();
//--- Visible state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CTimeEdit::Reset(void)
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
void CTimeEdit::Delete(void)
  {
//--- Removing objects
   int objects_total=CElementBase::ObjectsElementTotal();
   for(int i=0; i<objects_total; i++)
      CElementBase::Object(i).Delete();
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
//--- Initializing of variables by default values
   CElementBase::MouseFocus(false);
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Seth the priorities                                              |
//+------------------------------------------------------------------+
void CTimeEdit::SetZorders(void)
  {
//--- Leave, if the element is blocked
   if(!m_time_edit_state)
      return;
//--- Set the priorities
   m_area.Z_Order(m_area_zorder);
   m_icon.Z_Order(m_label_zorder);
   m_label.Z_Order(m_label_zorder);
   m_hours.SetZorders();
   m_minutes.SetZorders();
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CTimeEdit::ResetZorders(void)
  {
//--- Leave, if the element is blocked
   if(!m_time_edit_state)
      return;
//--- Reset the priorities
   m_area.Z_Order(-1);
   m_icon.Z_Order(-1);
   m_label.Z_Order(-1);
   m_hours.ResetZorders();
   m_minutes.ResetZorders();
  }
//+------------------------------------------------------------------+
//| Reset the color of the element objects                           |
//+------------------------------------------------------------------+
void CTimeEdit::ResetColors(void)
  {
//--- Leave, if the element is blocked
   if(!m_time_edit_state)
      return;
//--- Zero the color
   m_label.Color(m_label_color);
   m_hours.ResetColors();
   m_minutes.ResetColors();
//--- Zero the focus
   CElementBase::MouseFocus(false);
  }
//+------------------------------------------------------------------+
//| Handling the press on the text label                             |
//+------------------------------------------------------------------+
bool CTimeEdit::OnClickLabel(const string clicked_object)
  {
//--- Leave, if it has a different object name
   if(m_area.Name()!=clicked_object)
      return(false);
//--- If the mode of resetting the value is enabled
   if(m_reset_mode)
     {
      //--- Set the minimum value
      m_hours.ChangeValue(m_hours.MinValue());
      m_minutes.ChangeValue(m_minutes.MinValue());
     }
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_CLICK_LABEL,CElementBase::Id(),CElementBase::Index(),m_label.Description());
   return(true);
  }
//+------------------------------------------------------------------+
