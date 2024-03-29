//+------------------------------------------------------------------+
//|                                                       Slider.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "SeparateLine.mqh"
//+------------------------------------------------------------------+
//| Class for creating a slider with edit                            |
//+------------------------------------------------------------------+
class CSlider : public CElement
  {
private:
   //--- Objects for creating the element
   CRectLabel        m_area;
   CLabel            m_label;
   CEdit             m_edit;
   CSeparateLine     m_slot;
   CRectLabel        m_indicator;
   CRectLabel        m_thumb;
   //--- Color of the element background
   color             m_area_color;
   //--- Text for describing the slider
   string            m_label_text;
   //--- Colors of the text label in different states
   color             m_label_color;
   color             m_label_color_hover;
   color             m_label_color_locked;
   color             m_label_color_array[];
   //--- Current value of the edit
   double            m_edit_value;
   //--- Size of the entry field
   int               m_edit_x_size;
   int               m_edit_y_size;
   //--- Colors of the entry field in different states
   color             m_edit_color;
   color             m_edit_color_locked;
   //--- Colors of the text of the entry field in different states
   color             m_edit_text_color;
   color             m_edit_text_color_locked;
   //--- Colors of the edit frame in different states
   color             m_edit_border_color;
   color             m_edit_border_color_hover;
   color             m_edit_border_color_locked;
   color             m_edit_border_color_array[];
   //--- Size of the slit
   int               m_slot_y_size;
   //--- Colors of the slit
   color             m_slot_line_dark_color;
   color             m_slot_line_light_color;
   //--- Colors of the indicator in different states
   color             m_slot_indicator_color;
   color             m_slot_indicator_color_locked;
   //--- Size of the slider runner
   int               m_thumb_x_size;
   int               m_thumb_y_size;
   //--- Colors of the slider runner
   color             m_thumb_color;
   color             m_thumb_color_hover;
   color             m_thumb_color_locked;
   color             m_thumb_color_pressed;
   //--- Priorities of the left mouse button click
   int               m_zorder;
   int               m_area_zorder;
   int               m_edit_zorder;
   //--- (1) Minimum and (2) maximum value, (3) step for changing the value
   double            m_min_value;
   double            m_max_value;
   double            m_step_value;
   //--- Number of decimal places
   int               m_digits;
   //--- Mode of text alignment
   ENUM_ALIGN_MODE   m_align_mode;
   //--- Checkbox state (available/blocked)
   bool              m_slider_state;
   //--- Current position of the slider runner: (1) value, (2) the X coordinate
   double            m_current_pos;
   double            m_current_pos_x;
   //--- Number of pixels in the working area
   int               m_pixels_total;
   //--- Number of steps in the value range of the working area
   int               m_value_steps_total;
   //--- Step in relation to the width of the working area
   double            m_position_step;
   //--- State of the mouse button (pressed/released)
   ENUM_MOUSE_STATE  m_clamping_area_mouse;
   //--- To identify the mode of the slider runner movement
   bool              m_slider_thumb_state;
   //--- Variables connected with the slider movement
   int               m_slider_size_fixing;
   int               m_slider_point_fixing;
   //---
public:
                     CSlider(void);
                    ~CSlider(void);
   //--- Methods for creating the control
   bool              CreateSlider(const long chart_id,const int subwin,const string text,const int x_gap,const int y_gap);
   //---
private:
   bool              CreateArea(void);
   bool              CreateLabel(void);
   bool              CreateEdit(void);
   bool              CreateSlot(void);
   bool              CreateIndicator(void);
   bool              CreateThumb(void);
   //---
public:
   //--- (1) Background color, (2) get/set the state of the control
   void              AreaColor(const color clr)                     { m_area_color=clr;                   }
   bool              SliderState(void)                        const { return(m_slider_state);             }
   void              SliderState(const bool state);
   //--- Colors of the text label
   void              LabelColor(const color clr)                    { m_label_color=clr;                  }
   void              LabelColorHover(const color clr)               { m_label_color_hover=clr;            }
   void              LabelColorLocked(const color clr)              { m_label_color_locked=clr;           }
   //--- (1) Gets/sets description of the control
   string            LabelText(void)                          const { return(m_label.Description());      }
   void              LabelText(const string text)                   { m_label.Description(text);          }
   //--- Size of (1) the edit and (2) the slot
   void              EditXSize(const int x_size)                    { m_edit_x_size=x_size;               }
   void              EditYSize(const int y_size)                    { m_edit_y_size=y_size;               }
   void              SlotYSize(const int y_size)                    { m_slot_y_size=y_size;               }
   //--- Colors of the entry field in different states
   void              EditColor(const color clr)                     { m_edit_color=clr;                   }
   void              EditColorLocked(const color clr)               { m_edit_color_locked=clr;            }
   //--- Colors of the text of the entry field in different states
   void              EditTextColor(const color clr)                 { m_edit_text_color=clr;              }
   void              EditTextColorLocked(const color clr)           { m_edit_text_color_locked=clr;       }
   //--- Colors of the edit frame in different states
   void              EditBorderColor(const color clr)               { m_edit_border_color=clr;            }
   void              EditBorderColorHover(const color clr)          { m_edit_border_color_hover=clr;      }
   void              EditBorderColorLocked(const color clr)         { m_edit_border_color_locked=clr;     }
   //--- (1) Dark and (2) light color of the separation line (slit)
   void              SlotLineDarkColor(const color clr)             { m_slot_line_dark_color=clr;         }
   void              SlotLineLightColor(const color clr)            { m_slot_line_light_color=clr;        }
   //--- Colors of the slider indicator in different states
   void              SlotIndicatorColor(const color clr)            { m_slot_indicator_color=clr;         }
   void              SlotIndicatorColorLocked(const color clr)      { m_slot_indicator_color_locked=clr;  }
   //--- Size of the slider runner
   void              ThumbXSize(const int x_size)                   { m_thumb_x_size=x_size;              }
   void              ThumbYSize(const int y_size)                   { m_thumb_y_size=y_size;              }
   //--- Colors of the slider runner
   void              ThumbColor(const color clr)                    { m_thumb_color=clr;                  }
   void              ThumbColorHover(const color clr)               { m_thumb_color_hover=clr;            }
   void              ThumbColorLocked(const color clr)              { m_thumb_color_locked=clr;           }
   void              ThumbColorPressed(const color clr)             { m_thumb_color_pressed=clr;          }
   //--- Minimum value
   double            MinValue(void)                           const { return(m_min_value);                }
   void              MinValue(const double value)                   { m_min_value=value;                  }
   //--- Maximum value
   double            MaxValue(void)                           const { return(m_max_value);                }
   void              MaxValue(const double value)                   { m_max_value=value;                  }
   //--- Step of changing the value
   double            StepValue(void)                          const { return(m_step_value);               }
   void              StepValue(const double value)                  { m_step_value=(value<=0)? 1 : value; }
   //--- (1) The number of decimal places, (2) mode of text alignment, (3) return and set the edit value
   void              SetDigits(const int digits)                    { m_digits=::fabs(digits);            }
   void              AlignMode(ENUM_ALIGN_MODE mode)                { m_align_mode=mode;                  }
   double            GetValue(void)                           const { return(m_edit_value);               }
   bool              SetValue(const double value);
   //--- Changing the value in the edit
   void              ChangeValue(const double value);
   //--- Changing the object color when the cursor is hovering over it
   void              ChangeObjectsColor(void);
   //--- Change the color of the slider runner
   void              ChangeThumbColor(void);
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
   //--- Handling the value entering in the edit
   bool              OnEndEdit(const string object_name);
   //--- Process of the slider runner movement
   void              OnDragThumb(const int x);
   //--- Updating the slider runner location
   void              UpdateThumb(const int new_x_point);
   //--- Checks the state of the mouse button
   void              CheckMouseButtonState(void);
   //--- Zeroing variables connected with the slider runner movement
   void              ZeroThumbVariables(void);
   //--- Calculation of values (steps and coefficients)
   bool              CalculateCoefficients(void);
   //--- Calculation of the X coordinate of the slider runner
   void              CalculateThumbX(void);
   //--- Changes the current position of the slider runner in relation to the current value
   void              CalculateThumbPos(void);
   //--- Updating the slider indicator
   void              UpdateIndicator(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSlider::CSlider(void) : m_digits(2),
                         m_edit_value(WRONG_VALUE),
                         m_align_mode(ALIGN_LEFT),
                         m_slider_state(true),
                         m_slider_thumb_state(false),
                         m_slider_size_fixing(0),
                         m_slider_point_fixing(0),
                         m_min_value(0),
                         m_max_value(10),
                         m_step_value(1),
                         m_current_pos(WRONG_VALUE),
                         m_area_color(clrNONE),
                         m_label_color(clrBlack),
                         m_label_color_hover(C'85,170,255'),
                         m_label_color_locked(clrSilver),
                         m_edit_x_size(30),
                         m_edit_y_size(18),
                         m_edit_color(clrWhite),
                         m_edit_color_locked(clrWhiteSmoke),
                         m_edit_text_color(clrBlack),
                         m_edit_text_color_locked(clrSilver),
                         m_edit_border_color(clrSilver),
                         m_edit_border_color_hover(C'85,170,255'),
                         m_edit_border_color_locked(clrSilver),
                         m_slot_y_size(4),
                         m_slot_line_dark_color(clrSilver),
                         m_slot_line_light_color(clrWhite),
                         m_slot_indicator_color(C'85,170,255'),
                         m_slot_indicator_color_locked(clrLightGray),
                         m_thumb_x_size(6),
                         m_thumb_y_size(14),
                         m_thumb_color(C'170,170,170'),
                         m_thumb_color_hover(C'200,200,200'),
                         m_thumb_color_locked(clrLightGray),
                         m_thumb_color_pressed(clrSilver)
  {
//--- Store the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
//--- Set priorities of the left mouse button click
   m_zorder      =0;
   m_area_zorder =1;
   m_edit_zorder =2;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSlider::~CSlider(void)
  {
  }
//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void CSlider::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
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
      m_thumb.MouseFocus(m_mouse.X()>m_thumb.X() && m_mouse.X()<m_thumb.X2() && 
                         m_mouse.Y()>m_thumb.Y() && m_mouse.Y()<m_thumb.Y2());
      //--- Leave, if the element is blocked
      if(!m_slider_state)
         return;
      //--- Verify and store the state of the mouse button
      CheckMouseButtonState();
      //--- Change the color of the slider runner
      ChangeThumbColor();
      //--- If management was passed to the slider line, identify its location
      if(m_clamping_area_mouse==PRESSED_INSIDE)
        {
         //--- Moving the slider runner
         OnDragThumb(m_mouse.X());
         //--- Calculation of the slider runner position in the value range
         CalculateThumbPos();
         //--- Setting a new value in the edit
         ChangeValue(m_current_pos);
         //--- Update the slider indicator
         UpdateIndicator();
         return;
        }
     }
//--- Handling the value change in edit event
   if(id==CHARTEVENT_OBJECT_ENDEDIT)
     {
      //--- Handling of the value entry
      if(OnEndEdit(sparam))
         return;
     }
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CSlider::OnEventTimer(void)
  {
//--- If the element is a drop-down
   if(CElementBase::IsDropdown())
      ChangeObjectsColor();
   else
     {
      //--- If the form and the element are not blocked
      if(!m_wnd.IsLocked())
         ChangeObjectsColor();
     }
  }
//+------------------------------------------------------------------+
//| Create slider with edit control                                  |
//+------------------------------------------------------------------+
bool CSlider::CreateSlider(const long chart_id,const int subwin,const string text,const int x_gap,const int y_gap)
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
   m_label_text =text;
   m_area_color =(m_area_color!=clrNONE)? m_area_color : m_wnd.WindowBgColor();
//--- Margins from the edge
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
//--- Creating an element
   if(!CreateArea())
      return(false);
   if(!CreateLabel())
      return(false);
   if(!CreateEdit())
      return(false);
   if(!CreateSlot())
      return(false);
   if(!CreateIndicator())
      return(false);
   if(!CreateThumb())
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
bool CSlider::CreateArea(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_slider_area_"+(string)CElementBase::Id();
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
   m_area.X(CElementBase::X());
   m_area.Y(CElementBase::Y());
//--- Sizes
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
//| Create label of editable edit control                            |
//+------------------------------------------------------------------+
bool CSlider::CreateLabel(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_slider_lable_"+(string)CElementBase::Id();
//--- Coordinates
   int x=CElementBase::X();
   int y=m_y+5;
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
   m_label.Z_Order(m_zorder);
   m_label.Tooltip("\n");
//--- Store coordinates
   m_area.X(x);
   m_area.Y(y);
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
//| Creates edit control with spins                                  |
//+------------------------------------------------------------------+
bool CSlider::CreateEdit(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_slider_edit_"+(string)CElementBase::Id();
//--- Coordinates
   int x=CElementBase::X2()-m_edit_x_size;
   int y=m_y+3;
//--- Set the object
   if(!m_edit.Create(m_chart_id,name,m_subwin,x,y,m_edit_x_size,m_edit_y_size))
      return(false);
//--- Set properties
   m_edit.Font(CElementBase::Font());
   m_edit.FontSize(CElementBase::FontSize());
   m_edit.TextAlign(m_align_mode);
   m_edit.Description(::DoubleToString(m_edit_value,m_digits));
   m_edit.Color(m_edit_text_color);
   m_edit.BorderColor(m_edit_border_color);
   m_edit.BackColor(m_edit_color);
   m_edit.Corner(m_corner);
   m_edit.Anchor(m_anchor);
   m_edit.Selectable(false);
   m_edit.Z_Order(m_edit_zorder);
   m_edit.Tooltip("\n");
//--- Store coordinates
   m_edit.X(x);
   m_edit.Y(y);
//--- Sizes
   m_edit.XSize(m_edit_x_size);
   m_edit.YSize(m_edit_y_size);
//--- Margins from the edge
   m_edit.XGap(CElement::CalculateXGap(x));
   m_edit.YGap(CElement::CalculateYGap(y));
//--- Initializing the array gradient
   CElementBase::InitColorArray(m_edit_border_color,m_edit_border_color_hover,m_edit_border_color_array);
//--- Store the object pointer
   CElementBase::AddToArray(m_edit);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create slot for the scrollbar                                    |
//+------------------------------------------------------------------+
bool CSlider::CreateSlot(void)
  {
//--- Coordinates
   int x=CElement::CalculateXGap(CElementBase::X());
   int y=CElement::CalculateYGap(CElementBase::Y()+30);
//--- Store the form pointer
   m_slot.WindowPointer(m_wnd);
//--- Set properties
   m_slot.TypeSepLine(H_SEP_LINE);
   m_slot.DarkColor(m_slot_line_dark_color);
   m_slot.LightColor(m_slot_line_light_color);
   m_slot.AnchorRightWindowSide(m_anchor_right_window_side);
   m_slot.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating a separation line
   if(!m_slot.CreateSeparateLine(m_chart_id,m_subwin,0,x,y,CElementBase::XSize(),m_slot_y_size))
      return(false);
//--- Store the object pointer
   CElementBase::AddToArray(m_slot.Object(0));
   return(true);
  }
//+------------------------------------------------------------------+
//| Create scrollbar indicator                                       |
//+------------------------------------------------------------------+
bool CSlider::CreateIndicator(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_slider_indicator_"+(string)CElementBase::Id();
//--- Coordinates
   int x=CElementBase::X();
   int y=m_slot.Y()+1;
//--- Size
   int y_size=m_slot_y_size-2;
//--- Set the object
   if(!m_indicator.Create(m_chart_id,name,m_subwin,x,y,m_x_size,y_size))
      return(false);
//--- Set properties
   m_indicator.BackColor(m_slot_indicator_color);
   m_indicator.Color(m_slot_indicator_color);
   m_indicator.BorderType(BORDER_FLAT);
   m_indicator.Corner(m_corner);
   m_indicator.Selectable(false);
   m_indicator.Z_Order(m_zorder);
   m_indicator.Tooltip("\n");
//--- Store coordinates
   m_indicator.X(x);
   m_indicator.Y(y);
//--- Sizes
   m_indicator.XSize(CElementBase::XSize());
   m_indicator.YSize(y_size);
//--- Margins from the edge
   m_indicator.XGap(CElement::CalculateXGap(x));
   m_indicator.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_indicator);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the slider runner                                        |
//+------------------------------------------------------------------+
bool CSlider::CreateThumb(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_slider_thumb_"+(string)CElementBase::Id();
//--- Coordinates
   int x=CElementBase::X();
   int y=m_slot.Y()-((m_thumb_y_size-m_slot_y_size)/2);
//--- Set the object
   if(!m_thumb.Create(m_chart_id,name,m_subwin,x,y,m_thumb_x_size,m_thumb_y_size))
      return(false);
//--- Set properties
   m_thumb.Color(m_thumb_color);
   m_thumb.BackColor(m_thumb_color);
   m_thumb.BorderType(BORDER_FLAT);
   m_thumb.Corner(m_corner);
   m_thumb.Selectable(false);
   m_thumb.Z_Order(m_zorder);
   m_thumb.Tooltip("\n");
//--- Store coordinates
   m_thumb.X(x);
   m_thumb.Y(y);
//--- Store the size
   m_thumb.XSize(m_thumb.X_Size());
   m_thumb.YSize(m_thumb.Y_Size());
//--- Margins from the edge
   m_thumb.XGap(CElement::CalculateXGap(x));
   m_thumb.YGap(CElement::CalculateYGap(y));
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
//--- Calculation of the values of auxiliary variables
   CalculateCoefficients();
//--- Calculation of the X coordinates of the slider runner in relation to the current value in the entry field
   CalculateThumbX();
//--- Calculation of the slider runner position in the value range
   CalculateThumbPos();
//--- Update the slider indicator
   UpdateIndicator();
//--- Store the object pointer
   CElementBase::AddToArray(m_thumb);
   return(true);
  }
//+------------------------------------------------------------------+
//| Change the state of the control                                  |
//+------------------------------------------------------------------+
void CSlider::SliderState(const bool state)
  {
//--- Control state
   m_slider_state=state;
//--- Color of the text label
   m_label.Color((state)? m_label_color : m_label_color_locked);
//--- Color of the edit
   m_edit.Color((state)? m_edit_text_color : m_edit_text_color_locked);
   m_edit.BackColor((state)? m_edit_color : m_edit_color_locked);
   m_edit.BorderColor((state)? m_edit_border_color : m_edit_border_color_locked);
//--- Color of the indicator
   m_indicator.BackColor((state)? m_slot_indicator_color : m_slot_indicator_color_locked);
   m_indicator.Color((state)? m_slot_indicator_color : m_slot_indicator_color_locked);
//--- Color of the slider runner
   m_thumb.BackColor((state)? m_thumb_color : m_thumb_color_locked);
   m_thumb.Color((state)? m_thumb_color : m_thumb_color_locked);
//--- Setting in relation of the current state
   if(!m_slider_state)
      //--- Edit in the read only mode
      m_edit.ReadOnly(true);
   else
//--- The edit control in the edit mode
      m_edit.ReadOnly(false);
  }
//+------------------------------------------------------------------+
//| Set current value                                                |
//+------------------------------------------------------------------+
bool CSlider::SetValue(const double value)
  {
//--- Adjust considering the step
   double corrected_value=::MathRound(value/m_step_value)*m_step_value;
//--- Check for the minimum/maximum
   if(corrected_value<=m_min_value)
      corrected_value=m_min_value;
   if(corrected_value>=m_max_value)
      corrected_value=m_max_value;
//--- If the value has been changed
   if(m_edit_value!=corrected_value)
     {
      m_edit_value=corrected_value;
      return(true);
     }
//--- Value unchanged
   return(false);
  }
//+------------------------------------------------------------------+
//| Changing the value in the edit                                   |
//+------------------------------------------------------------------+
void CSlider::ChangeValue(const double value)
  {
//--- Check, adjust and store the new value
   SetValue(value);
//--- Set the new value in the edit
   m_edit.Description(::DoubleToString(GetValue(),m_digits));
  }
//+------------------------------------------------------------------+
//| Changing the object color when the cursor is hovering over it    |
//+------------------------------------------------------------------+
void CSlider::ChangeObjectsColor(void)
  {
//--- Leave, if the control is blocked or is in the mode of the slider runner movement
   if(!m_slider_state || m_slider_thumb_state)
      return;
//---
   CElementBase::ChangeObjectColor(m_label.Name(),CElementBase::MouseFocus(),OBJPROP_COLOR,m_label_color,m_label_color_hover,m_label_color_array);
   CElementBase::ChangeObjectColor(m_edit.Name(),CElementBase::MouseFocus(),OBJPROP_BORDER_COLOR,m_edit_border_color,m_edit_border_color_hover,m_edit_border_color_array);
  }
//+------------------------------------------------------------------+
//| Change the color of the scrollbar                                |
//+------------------------------------------------------------------+
void CSlider::ChangeThumbColor(void)
  {
//--- Leave, if the form is blocked and the identifier of the currently active element differs
   if(m_wnd.IsLocked() && !CElement::CheckIdActivatedElement())
      return;
//--- If the cursor is in the slider runner area
   if(m_thumb.MouseFocus())
     {
      //--- If the left mouse button is released
      if(m_clamping_area_mouse==NOT_PRESSED)
        {
         m_slider_thumb_state=false;
         m_thumb.Color(m_thumb_color_hover);
         m_thumb.BackColor(m_thumb_color_hover);
        }
      //--- Left mouse button is pressed
      else if(m_clamping_area_mouse==PRESSED_INSIDE)
        {
         m_slider_thumb_state=true;
         m_thumb.Color(m_thumb_color_pressed);
         m_thumb.BackColor(m_thumb_color_pressed);
        }
     }
//--- If the cursor is outside of the scrollbar area
   else
     {
      //--- Left mouse button is released
      if(!m_mouse.LeftButtonState())
        {
         m_slider_thumb_state=false;
         m_thumb.Color(m_thumb_color);
         m_thumb.BackColor(m_thumb_color);
        }
     }
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CSlider::Moving(const int x,const int y,const bool moving_mode=false)
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
      m_label.X(m_wnd.X2()-m_label.XGap());
      m_edit.X(m_wnd.X2()-m_edit.XGap());
      m_indicator.X(m_wnd.X2()-m_indicator.XGap());
      m_thumb.X(m_wnd.X2()-m_thumb.XGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::X(x+XGap());
      //--- Storing coordinates in the fields of the objects
      m_area.X(x+m_area.XGap());
      m_label.X(x+m_label.XGap());
      m_edit.X(x+m_edit.XGap());
      m_indicator.X(x+m_indicator.XGap());
      m_thumb.X(x+m_thumb.XGap());
     }
//--- If the anchored to the bottom
   if(m_anchor_bottom_window_side)
     {
      //--- Storing coordinates in the element fields
      CElementBase::Y(m_wnd.Y2()-YGap());
      //--- Storing coordinates in the fields of the objects
      m_area.Y(m_wnd.Y2()-m_area.YGap());
      m_label.Y(m_wnd.Y2()-m_label.YGap());
      m_edit.Y(m_wnd.Y2()-m_edit.YGap());
      m_indicator.Y(m_wnd.Y2()-m_indicator.YGap());
      m_thumb.Y(m_wnd.Y2()-m_thumb.YGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::Y(y+YGap());
      //--- Storing coordinates in the fields of the objects
      m_area.Y(y+m_area.YGap());
      m_label.Y(y+m_label.YGap());
      m_edit.Y(y+m_edit.YGap());
      m_indicator.Y(y+m_indicator.YGap());
      m_thumb.Y(y+m_thumb.YGap());
     }
//--- Updating coordinates of graphical objects  
   m_area.X_Distance(m_area.X());
   m_area.Y_Distance(m_area.Y());
   m_label.X_Distance(m_label.X());
   m_label.Y_Distance(m_label.Y());
   m_edit.X_Distance(m_edit.X());
   m_edit.Y_Distance(m_edit.Y());
   m_indicator.X_Distance(m_indicator.X());
   m_indicator.Y_Distance(m_indicator.Y());
   m_thumb.X_Distance(m_thumb.X());
   m_thumb.Y_Distance(m_thumb.Y());
//--- Moving the slot
   m_slot.Moving(x,y,true);
  }
//+------------------------------------------------------------------+
//| Shows a menu item                                                |
//+------------------------------------------------------------------+
void CSlider::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElementBase::IsVisible())
      return;
//--- Make all the objects visible
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_ALL_PERIODS);
//--- Show the slot
   m_slot.Show();
//--- Visible state
   CElementBase::IsVisible(true);
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
//| Hides a menu item                                                |
//+------------------------------------------------------------------+
void CSlider::Hide(void)
  {
//--- Leave, if the element is already visible
   if(!CElementBase::IsVisible())
      return;
//--- Hide all objects
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_NO_PERIODS);
//--- Hide the slot
   m_slot.Hide();
//--- Visible state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CSlider::Reset(void)
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
void CSlider::Delete(void)
  {
//--- Removing objects  
   m_area.Delete();
   m_label.Delete();
   m_edit.Delete();
   m_slot.Delete();
   m_indicator.Delete();
   m_thumb.Delete();
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
//--- Initializing of variables by default values
   CElementBase::MouseFocus(false);
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Seth the priorities                                              |
//+------------------------------------------------------------------+
void CSlider::SetZorders(void)
  {
//--- Leave, if the element is blocked
   if(!m_slider_state)
      return;
//--- Set the default values
   m_area.Z_Order(m_area_zorder);
   m_label.Z_Order(m_zorder);
   m_edit.Z_Order(m_edit_zorder);
   m_indicator.Z_Order(m_zorder);
   m_thumb.Z_Order(m_zorder);
//--- The edit control in the edit mode
   m_edit.ReadOnly(false);
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CSlider::ResetZorders(void)
  {
//--- Leave, if the element is blocked
   if(!m_slider_state)
      return;
//--- Zeroing priorities
   m_area.Z_Order(0);
   m_label.Z_Order(0);
   m_edit.Z_Order(0);
   m_indicator.Z_Order(0);
   m_thumb.Z_Order(0);
//--- Edit in the read only mode
   m_edit.ReadOnly(true);
  }
//+------------------------------------------------------------------+
//| Reset the color of the element objects                           |
//+------------------------------------------------------------------+
void CSlider::ResetColors(void)
  {
//--- Leave, if the element is blocked
   if(!m_slider_state)
      return;
//--- Zero the color
   m_label.Color(m_label_color);
   m_edit.BorderColor(m_edit_border_color);
//--- Zero the focus
   CElementBase::MouseFocus(false);
  }
//+------------------------------------------------------------------+
//| Handling the value entering in the edit                          |
//+------------------------------------------------------------------+
bool CSlider::OnEndEdit(const string object_name)
  {
//--- Leave, if it has a different object name
   if(object_name!=m_edit.Name())
      return(false);
//--- Get the entered value
   double entered_value=::StringToDouble(m_edit.Description());
//--- Check, adjust and store the new value
   ChangeValue(entered_value);
//--- Calculate the X coordinate of the slider runner
   CalculateThumbX();
//--- Calculate the position in the value range
   CalculateThumbPos();
//--- Update the slider indicator
   UpdateIndicator();
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_END_EDIT,CElementBase::Id(),CElementBase::Index(),m_label.Description());
   return(true);
  }
//+------------------------------------------------------------------+
//| Process of the slider runner movement                            |
//+------------------------------------------------------------------+
void CSlider::OnDragThumb(const int x)
  {
//--- To identify the new X coordinate
   int new_x_point=0;
//--- If the slider runner is inactive, ...
   if(!m_slider_thumb_state)
     {
      //--- ...zero auxiliary variables for moving the slider
      m_slider_point_fixing =0;
      m_slider_size_fixing  =0;
      return;
     }
//--- If the fixation point is zero, store current coordinates of the cursor
   if(m_slider_point_fixing==0)
      m_slider_point_fixing=x;
//--- If the distance from the edge of the slider to the current coordinate of the cursor is zero, calculate it
   if(m_slider_size_fixing==0)
      m_slider_size_fixing=m_thumb.X()-x;
//--- If the threshold is passed to the right in the pressed down state
   if(x-m_slider_point_fixing>0)
     {
      //--- Calculate the X coordinate
      new_x_point=x+m_slider_size_fixing;
      //--- Updating the scrollbar location
      UpdateThumb(new_x_point);
      return;
     }
//--- If the threshold is passed to the left in the pressed down state
   if(x-m_slider_point_fixing<0)
     {
      //--- Calculate the X coordinate
      new_x_point=x-::fabs(m_slider_size_fixing);
      //--- Updating the scrollbar location
      UpdateThumb(new_x_point);
      return;
     }
  }
//+------------------------------------------------------------------+
//| Updating the slider runner location                              |
//+------------------------------------------------------------------+
void CSlider::UpdateThumb(const int new_x_point)
  {
   int x=new_x_point;
//--- Zeroing the fixation point
   m_slider_point_fixing=0;
//--- Check for exceeding the working area
   if(new_x_point>m_area.X2()-m_thumb.XSize())
      x=m_area.X2()-m_thumb.XSize();
   if(new_x_point<=m_area.X())
      x=m_area.X();
//--- Update the list view and scrollbar
   m_thumb.X(x);
   m_thumb.X_Distance(x);
//--- Store margins
   m_thumb.XGap((m_anchor_right_window_side)? m_wnd.X2()-(m_area.X2()-(m_area.X2()-m_thumb.X())) : m_thumb.X()-m_wnd.X());
  }
//+------------------------------------------------------------------+
//| Updating the slider indicator                                    |
//+------------------------------------------------------------------+
void CSlider::UpdateIndicator(void)
  {
//--- Calculate the size
   int x_size=m_thumb.X()-m_indicator.X();
//--- Adjustment in case of impermissible values
   if(x_size<=0)
      x_size=1;
//--- Setting a new size
   m_indicator.X_Size(x_size);
  }
//+------------------------------------------------------------------+
//| Checking the mouse button state                                  |
//+------------------------------------------------------------------+
void CSlider::CheckMouseButtonState(void)
  {
//--- If the left mouse button is released
   if(!m_mouse.LeftButtonState())
     {
      //--- Zero variables
      ZeroThumbVariables();
      return;
     }
//--- If the left mouse button is pressed
   else
     {
      //--- Leave, if the button is pressed down in another area
      if(m_clamping_area_mouse!=NOT_PRESSED)
         return;
      //--- Outside of the slider runner area
      if(!m_thumb.MouseFocus())
         m_clamping_area_mouse=PRESSED_OUTSIDE;
      //--- Inside the slider runner area
      else
        {
         m_clamping_area_mouse=PRESSED_INSIDE;
         //--- Block the form and store the active element identifier
         m_wnd.IsLocked(true);
         m_wnd.IdActivatedElement(CElementBase::Id());
        }
     }
  }
//+------------------------------------------------------------------+
//| Zeroing variables connected with the slider runner movement      |
//+------------------------------------------------------------------+
void CSlider::ZeroThumbVariables(void)
  {
//--- If you are here, it means that the left mouse button is released.
//    If the left mouse button was pressed over the slider runner...
   if(m_clamping_area_mouse==PRESSED_INSIDE)
     {
      //--- ... send a message that changing of the value in the entry field with the sider runner is completed
      ::EventChartCustom(m_chart_id,ON_END_EDIT,CElementBase::Id(),CElementBase::Index(),m_label.Description());
     }
//---
   m_slider_size_fixing  =0;
   m_clamping_area_mouse =NOT_PRESSED;
//--- If the element identifier matches the activating identifier,
//    unblock the form and reset the identifier of the activated element
   if(CElement::CheckIdActivatedElement())
     {
      m_wnd.IsLocked(false);
      m_wnd.IdActivatedElement(WRONG_VALUE);
     }
  }
//+------------------------------------------------------------------+
//| Calculation of values (steps and coefficients)                   |
//+------------------------------------------------------------------+
bool CSlider::CalculateCoefficients(void)
  {
//--- Leave, if the width of the element is less than the width of the slider runner
   if(CElementBase::XSize()<m_thumb_x_size)
      return(false);
//--- Number of pixels in the working area
   m_pixels_total=CElementBase::XSize()-m_thumb_x_size;
//--- Number of steps in the value range of the working area
   m_value_steps_total=int((m_max_value-m_min_value)/m_step_value);
//--- Step in relation to the width of the working area
   m_position_step=m_step_value*(double(m_value_steps_total)/double(m_pixels_total));
   return(true);
  }
//+------------------------------------------------------------------+
//| Calculating the X coordinate of the slider runner                |
//+------------------------------------------------------------------+
void CSlider::CalculateThumbX(void)
  {
//--- Adjustment considering that the minimum value can be negative
   double neg_range=(m_min_value<0)? ::fabs(m_min_value/m_position_step) : 0;
//--- Calculate the X coordinate for the slider runner
   m_current_pos_x=m_area.X()+(m_edit_value/m_position_step)+neg_range;
//--- If the working area is exceeded on the left
   if(m_current_pos_x<m_area.X())
       m_current_pos_x=m_area.X();
//--- If the working area is exceeded on the right
   if(m_current_pos_x+m_thumb.XSize()>m_area.X2())
       m_current_pos_x=m_area.X2()-m_thumb.XSize();
//--- Store and set the new X coordinate
   m_thumb.X(int(m_current_pos_x));
   m_thumb.X_Distance(int(m_current_pos_x));
   m_thumb.XGap((m_anchor_right_window_side)? m_wnd.X2()-(m_area.X2()-(m_area.X2()-m_thumb.X())) : m_thumb.X()-m_wnd.X());
  }
//+------------------------------------------------------------------+
//| Calculation of the slider runner position in the value range     |
//+------------------------------------------------------------------+
void CSlider::CalculateThumbPos(void)
  {
//--- Get the position number of the slider runner
   m_current_pos=(m_thumb.X()-m_area.X())*m_position_step;
//--- Adjustment considering that the minimum value can be negative
   if(m_min_value<0 && m_current_pos_x!=WRONG_VALUE)
      m_current_pos+=int(m_min_value);
//--- Check for exceeding the working area on the right/left
   if(m_thumb.X2()>=m_area.X2())
      m_current_pos=int(m_max_value);
   if(m_thumb.X()<=m_area.X())
      m_current_pos=int(m_min_value);
  }
//+------------------------------------------------------------------+
