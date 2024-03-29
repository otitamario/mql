//+------------------------------------------------------------------+
//|                                                     TextEdit.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "Pointer.mqh"
//+------------------------------------------------------------------+
//| Class for creating the text edit box                             |
//+------------------------------------------------------------------+
class CTextEdit : public CElement
  {
private:
   //--- Objects for creating the edit
   CRectLabel        m_area;
   CBmpLabel         m_icon;
   CLabel            m_label;
   CEdit             m_edit;
   CPointer          m_text_select;
   //--- Color of the control background
   color             m_area_color;
   //--- Control icons in the active and blocked states
   string            m_icon_file_on;
   string            m_icon_file_off;
   //--- Icon margins
   int               m_icon_x_gap;
   int               m_icon_y_gap;
   //--- Text of the description of the edit
   string            m_label_text;
   //--- Text label margins
   int               m_label_x_gap;
   int               m_label_y_gap;
   //--- Color of the text in different states
   color             m_label_color;
   color             m_label_color_hover;
   color             m_label_color_locked;
   color             m_label_color_array[];
   //--- Current value of the edit
   string            m_edit_value;
   //--- Size of the entry field
   int               m_edit_x_size;
   int               m_edit_y_size;
   //--- Margins for the Edit box
   int               m_edit_x_gap;
   int               m_edit_y_gap;
   //--- Colors of the edit and text of the edit in different states
   color             m_edit_color;
   color             m_edit_color_locked;
   color             m_edit_text_color;
   color             m_edit_text_color_locked;
   color             m_edit_text_color_highlight;
   //--- Colors of the edit frame in different states
   color             m_edit_border_color;
   color             m_edit_border_color_hover;
   color             m_edit_border_color_locked;
   color             m_edit_border_color_array[];
   //--- Priorities of the left mouse button press
   int               m_area_zorder;
   int               m_label_zorder;
   int               m_edit_zorder;
   //--- Checkbox state (available/blocked)
   bool              m_text_edit_state;
   //--- Mode of resetting the value (empty string)
   bool              m_reset_mode;
   //--- Display mode of the text selection cursor
   bool              m_show_text_pointer_mode;
   //--- Mode of text alignment
   ENUM_ALIGN_MODE   m_align_mode;
   //---
public:
                     CTextEdit(void);
                    ~CTextEdit(void);
   //--- Methods for creating the text edit box
   bool              CreateTextEdit(const long chart_id,const int subwin,const string label_text,const int x_gap,const int y_gap);
   //---
private:
   bool              CreateArea(void);
   bool              CreateIcon(void);
   bool              CreateLabel(void);
   bool              CreateEdit(void);
   bool              CreateTextSelectPointer(void);
   //---
public:
   //--- (1) Icon margins, (2) get/set the state of availability of the edit box
   void              IconXGap(const int x_gap)                      { m_icon_x_gap=x_gap;                 }
   void              IconYGap(const int y_gap)                      { m_icon_y_gap=y_gap;                 }
   bool              TextEditState(void)                      const { return(m_text_edit_state);          }
   void              TextEditState(const bool state);
   //--- (1) Background color, (2) text of edit description, (3) margins of the text label
   void              AreaColor(const color clr)                     { m_area_color=clr;                   }
   string            LabelText(void)                          const { return(m_label.Description());      }
   void              LabelText(const string text)                   { m_label.Description(text);          }
   void              LabelXGap(const int x_gap)                     { m_label_x_gap=x_gap;                }
   void              LabelYGap(const int y_gap)                     { m_label_y_gap=y_gap;                }
   //--- Colors of the text label in different states
   void              LabelColor(const color clr)                    { m_label_color=clr;                  }
   void              LabelColorHover(const color clr)               { m_label_color_hover=clr;            }
   void              LabelColorLocked(const color clr)              { m_label_color_locked=clr;           }
   //--- (1) Edit size, (2) margin for edit from the right side
   void              EditXSize(const int x_size)                    { m_edit_x_size=x_size;               }
   void              EditYSize(const int y_size)                    { m_edit_y_size=y_size;               }
   //--- Margins for the Edit box
   void              EditXGap(const int x_gap)                      { m_edit_x_gap=x_gap;                 }
   void              EditYGap(const int y_gap)                      { m_edit_y_gap=y_gap;                 }
   //--- Colors of the entry field in different states
   void              EditColor(const color clr)                     { m_edit_color=clr;                   }
   void              EditColorLocked(const color clr)               { m_edit_color_locked=clr;            }
   //--- Colors of the text of the entry field in different states
   void              EditTextColor(const color clr)                 { m_edit_text_color=clr;              }
   void              EditTextColorLocked(const color clr)           { m_edit_text_color_locked=clr;       }
   void              EditTextColorHighlight(const color clr)        { m_edit_text_color_highlight=clr;    }
   //--- Colors of the edit frame in different states
   void              EditBorderColor(const color clr)               { m_edit_border_color=clr;            }
   void              EditBorderColorHover(const color clr)          { m_edit_border_color_hover=clr;      }
   void              EditBorderColorLocked(const color clr)         { m_edit_border_color_locked=clr;     }
   //--- (1) Reset mode when pressing the text label, (2) text selection mode
   bool              ResetMode(void)                                { return(m_reset_mode);               }
   void              ResetMode(const bool mode)                     { m_reset_mode=mode;                  }
   void              ShowTextPointerMode(const bool mode)           { m_show_text_pointer_mode=mode;      }
   //--- (1) Text alignment mode, (2) get and set the edit box value
   void              AlignMode(ENUM_ALIGN_MODE mode)                { m_align_mode=mode;                  }
   string            GetValue(void)                           const { return(m_edit.Description());       }
   void              SetValue(const string value);
   //--- Setting icons for the control in the active and blocked states
   void              IconFileOn(const string file_path);
   void              IconFileOff(const string file_path);
   //--- Changing the value in the edit
   void              ChangeValue(const string value);
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
   //--- Handling the press on the text label
   bool              OnClickLabel(const string clicked_object);
   //--- Handling the value entering in the edit
   bool              OnEndEdit(const string edited_object);

   //--- Change the width at the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTextEdit::CTextEdit(void) : m_edit_value(""),
                             m_reset_mode(false),
                             m_show_text_pointer_mode(false),
                             m_align_mode(ALIGN_LEFT),
                             m_text_edit_state(true),
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
                             m_edit_y_size(20),
                             m_edit_x_gap(50),
                             m_edit_y_gap(0),
                             m_edit_color(clrWhite),
                             m_edit_color_locked(clrWhiteSmoke),
                             m_edit_text_color(clrBlack),
                             m_edit_text_color_locked(clrSilver),
                             m_edit_text_color_highlight(clrRed),
                             m_edit_border_color(clrSilver),
                             m_edit_border_color_hover(C'85,170,255'),
                             m_edit_border_color_locked(clrSilver)

  {
//--- Store the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
//--- Set priorities of the left mouse button click
   m_area_zorder  =1;
   m_label_zorder =0;
   m_edit_zorder  =2;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTextEdit::~CTextEdit(void)
  {
  }
//+------------------------------------------------------------------+
//| Event handling                                                |
//+------------------------------------------------------------------+
void CTextEdit::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
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
      //--- Leave, if the form is blocked by another control
      if(m_wnd.IsLocked() && !CElement::CheckIdActivatedElement())
         return;
      //--- Checking the focus over elements
      CElement::CheckMouseFocus();
      m_edit.MouseFocus(m_mouse.X()>m_edit.X() && m_mouse.X()<m_edit.X2() && 
                        m_mouse.Y()>m_edit.Y() && m_mouse.Y()<m_edit.Y2());
      //--- If the mouse cursor in the edit box area
      if(m_edit.MouseFocus())
        {
         //--- Update the cursor coordinates and make it visible
         m_text_select.Moving(m_mouse.X(),m_mouse.Y());
         //--- Show the cursor
         m_text_select.Show();
        }
      else
        {
         //--- Hide the cursor
         m_text_select.Hide();
        }
      //---
      return;
     }
//--- Handling the left mouse button click on the object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- Leave, if the element is blocked
      if(!m_text_edit_state)
         return;
      //--- Handling the press on the text label
      if(OnClickLabel(sparam))
         return;
      //---
      return;
     }
//--- Handling the value change in edit event
   if(id==CHARTEVENT_OBJECT_ENDEDIT)
     {
      //--- Leave, if the element is blocked
      if(!m_text_edit_state)
         return;
      //--- Handling of the value entry
      if(OnEndEdit(sparam))
         return;
     }
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CTextEdit::OnEventTimer(void)
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
//| Creates a group of text edit box objects                         |
//+------------------------------------------------------------------+
bool CTextEdit::CreateTextEdit(const long chart_id,const int subwin,const string label_text,const int x_gap,const int y_gap)
  {
//--- Exit if there is no pointer to the form
   if(!CElement::CheckWindowPointer())
      return(false);
//--- Initializing variables
   m_id          =m_wnd.LastId()+1;
   m_chart_id    =chart_id;
   m_subwin      =subwin;
   m_x           =CElement::CalculateX(x_gap);
   m_y           =CElement::CalculateY(y_gap);
   m_x_size      =(m_x_size<1 || m_auto_xresize_mode)? m_wnd.X2()-m_x-m_auto_xresize_right_offset : m_x_size;
   m_y_size      =m_edit_y_size;
   m_label_text  =label_text;
   m_area_color  =(m_area_color!=clrNONE)? m_area_color : m_wnd.WindowBgColor();
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
   if(!CreateEdit())
      return(false);
   if(!CreateTextSelectPointer())
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
bool CTextEdit::CreateArea(void)
  {
//--- Formation of the window name
   string name="";
   if(m_index==WRONG_VALUE)
      name=CElementBase::ProgramName()+"_textedit_area_"+(string)CElementBase::Id();
   else
      name=CElementBase::ProgramName()+"_textedit_area_"+(string)CElementBase::Index()+"__"+(string)CElementBase::Id();
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
bool CTextEdit::CreateIcon(void)
  {
//--- Leave, if the icon is not needed
   if(m_icon_file_on=="" || m_icon_file_off=="")
      return(true);
//--- Formation of the window name
   string name="";
   if(m_index==WRONG_VALUE)
      name=CElementBase::ProgramName()+"_text_edit_bmp_"+(string)CElementBase::Id();
   else
      name=CElementBase::ProgramName()+"_text_edit_bmp_"+(string)CElementBase::Index()+"__"+(string)CElementBase::Id();
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
//| Create label of editable edit control                            |
//+------------------------------------------------------------------+
bool CTextEdit::CreateLabel(void)
  {
//--- Formation of the window name
   string name="";
   if(m_index==WRONG_VALUE)
      name=CElementBase::ProgramName()+"_textedit_lable_"+(string)CElementBase::Id();
   else
      name=CElementBase::ProgramName()+"_textedit_lable_"+(string)CElementBase::Index()+"__"+(string)CElementBase::Id();
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
//| Creates edit control with spins                                  |
//+------------------------------------------------------------------+
bool CTextEdit::CreateEdit(void)
  {
//--- Formation of the window name
   string name="";
   if(m_index==WRONG_VALUE)
      name=CElementBase::ProgramName()+"_textedit_edit_"+(string)CElementBase::Id();
   else
      name=CElementBase::ProgramName()+"_textedit_edit_"+(string)CElementBase::Index()+"__"+(string)CElementBase::Id();
//--- Coordinates
   int x =m_x+m_edit_x_gap;
   int y =m_y+m_edit_y_gap;
//--- Sizes
   m_edit_x_size=CElementBase::X2()-x;
   m_edit.XSize(m_edit_x_size);
   m_edit.YSize(m_edit_y_size);
   int y_size=y+m_edit_y_size-CElementBase::Y();
   m_area.YSize(y_size);
   m_area.Y_Size(y_size);
   CElementBase::YSize(y_size);
//--- Set the object
   if(!m_edit.Create(m_chart_id,name,m_subwin,x,y,m_edit_x_size,m_edit_y_size))
      return(false);
//--- Set properties
   m_edit.Font(CElementBase::Font());
   m_edit.FontSize(CElementBase::FontSize());
   m_edit.TextAlign(m_align_mode);
   m_edit.Description(m_edit_value);
   m_edit.Color(m_edit_text_color);
   m_edit.BackColor(m_edit_color);
   m_edit.BorderColor(m_edit_border_color);
   m_edit.Corner(m_corner);
   m_edit.Anchor(m_anchor);
   m_edit.Selectable(false);
   m_edit.Z_Order(m_edit_zorder);
   m_edit.Tooltip("\n");
//--- Store coordinates
   m_edit.X(x);
   m_edit.Y(y);
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
//| Creates cursor of text selection                                 |
//+------------------------------------------------------------------+
bool CTextEdit::CreateTextSelectPointer(void)
  {
//--- Leave, if showing the text cursor is not needed
   if(!m_show_text_pointer_mode)
      return(true);
//--- Setting up properties
   m_text_select.XGap(12);
   m_text_select.YGap(9);
   m_text_select.Id(CElementBase::Id());
   m_text_select.Type(MP_TEXT_SELECT);
//--- Creating an element
   if(!m_text_select.CreatePointer(m_chart_id,m_subwin))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Setting value in the edit box                                    |
//+------------------------------------------------------------------+
void CTextEdit::SetValue(const string value)
  {
   m_edit.Description(value);
  }
//+------------------------------------------------------------------+
//| Set icon for the "ON" state                                      |
//+------------------------------------------------------------------+
void CTextEdit::IconFileOn(const string file_path)
  {
   m_icon_file_on=file_path;
   m_icon.BmpFileOn("::"+file_path);
  }
//+------------------------------------------------------------------+
//| Set icon for the "OFF" state                                     |
//+------------------------------------------------------------------+
void CTextEdit::IconFileOff(const string file_path)
  {
   m_icon_file_off=file_path;
   m_icon.BmpFileOff("::"+file_path);
  }
//+------------------------------------------------------------------+
//| Changing the value in the edit                                   |
//+------------------------------------------------------------------+
void CTextEdit::ChangeValue(const string value)
  {
//--- Check, adjust and store the new value
   SetValue(value);
//--- Set the new value in the edit
   m_edit.Description(value);
  }
//+------------------------------------------------------------------+
//| Setting the state of the control                                 |
//+------------------------------------------------------------------+
void CTextEdit::TextEditState(const bool state)
  {
   m_text_edit_state=state;
//--- Icon
   m_icon.State(state);
//--- Color of the text label
   m_label.Color((state)? m_label_color : m_label_color_locked);
//--- Color of the edit
   m_edit.Color((state)? m_edit_text_color : m_edit_text_color_locked);
   m_edit.BackColor((state)? m_edit_color : m_edit_color_locked);
   m_edit.BorderColor((state)? m_edit_border_color : m_edit_border_color_locked);
//--- Setting in relation of the current state
   if(!m_text_edit_state)
     {
      //--- Priorities
      m_edit.Z_Order(-1);
      //--- Edit in the read only mode
      m_edit.ReadOnly(true);
     }
   else
     {
      //--- Priorities
      m_edit.Z_Order(m_edit_zorder);
      //--- The edit control in the edit mode
      m_edit.ReadOnly(false);
     }
  }
//+------------------------------------------------------------------+
//| Changing the object color when the cursor is hovering over it    |
//+------------------------------------------------------------------+
void CTextEdit::ChangeObjectsColor(void)
  {
//--- Leave, if the element is blocked
   if(!m_text_edit_state)
      return;
//--- Focus on the text label and edit
   CElementBase::ChangeObjectColor(m_label.Name(),CElementBase::MouseFocus(),OBJPROP_COLOR,m_label_color,m_label_color_hover,m_label_color_array);
   CElementBase::ChangeObjectColor(m_edit.Name(),CElementBase::MouseFocus(),OBJPROP_BORDER_COLOR,m_edit_border_color,m_edit_border_color_hover,m_edit_border_color_array);
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CTextEdit::Moving(const int x,const int y,const bool moving_mode=false)
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
      m_edit.X(m_wnd.X2()-m_edit.XGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::X(x+XGap());
      //--- Storing coordinates in the fields of the objects
      m_area.X(x+m_area.XGap());
      m_icon.X(x+m_icon.XGap());
      m_label.X(x+m_label.XGap());
      m_edit.X(x+m_edit.XGap());
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
      m_edit.Y(m_wnd.Y2()-m_edit.YGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::Y(y+YGap());
      //--- Storing coordinates in the fields of the objects
      m_area.Y(y+m_area.YGap());
      m_icon.Y(y+m_icon.YGap());
      m_label.Y(y+m_label.YGap());
      m_edit.Y(y+m_edit.YGap());
     }
//--- Updating coordinates of graphical objects
   m_area.X_Distance(m_area.X());
   m_area.Y_Distance(m_area.Y());
   m_icon.X_Distance(m_icon.X());
   m_icon.Y_Distance(m_icon.Y());
   m_label.X_Distance(m_label.X());
   m_label.Y_Distance(m_label.Y());
   m_edit.X_Distance(m_edit.X());
   m_edit.Y_Distance(m_edit.Y());
  }
//+------------------------------------------------------------------+
//| Shows combobox                                                   |
//+------------------------------------------------------------------+
void CTextEdit::Show(void)
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
//| Hides combobox                                                   |
//+------------------------------------------------------------------+
void CTextEdit::Hide(void)
  {
//--- Leave, if the element is already visible
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
void CTextEdit::Reset(void)
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
void CTextEdit::Delete(void)
  {
//--- Removing objects
   m_area.Delete();
   m_icon.Delete();
   m_label.Delete();
   m_edit.Delete();
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
//--- Initializing of variables by default values
   CElementBase::MouseFocus(false);
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Seth the priorities                                              |
//+------------------------------------------------------------------+
void CTextEdit::SetZorders(void)
  {
//--- Leave, if the element is blocked
   if(!m_text_edit_state)
      return;
//--- Set the priorities
   m_area.Z_Order(m_area_zorder);
   m_icon.Z_Order(m_label_zorder);
   m_label.Z_Order(m_label_zorder);
   m_edit.Z_Order(m_edit_zorder);
//--- The edit control in the edit mode
   m_edit.ReadOnly(false);
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CTextEdit::ResetZorders(void)
  {
//--- Leave, if the element is blocked
   if(!m_text_edit_state)
      return;
//--- Reset the priorities
   m_area.Z_Order(-1);
   m_icon.Z_Order(-1);
   m_label.Z_Order(-1);
   m_edit.Z_Order(-1);
//--- Edit in the read only mode
   m_edit.ReadOnly(true);
  }
//+------------------------------------------------------------------+
//| Reset the color of the element objects                           |
//+------------------------------------------------------------------+
void CTextEdit::ResetColors(void)
  {
//--- Leave, if the element is blocked
   if(!m_text_edit_state)
      return;
//--- Zero the color
   m_label.Color(m_label_color);
   m_edit.BorderColor(m_edit_border_color);
//--- Zero the focus
   CElementBase::MouseFocus(false);
  }
//+------------------------------------------------------------------+
//| Handling the press on the text label                             |
//+------------------------------------------------------------------+
bool CTextEdit::OnClickLabel(const string clicked_object)
  {
//--- Leave, if it has a different object name
   if(m_area.Name()!=clicked_object)
      return(false);
//--- If the mode of resetting the value is enabled
   if(m_reset_mode)
     {
      //--- Set the minimum value
      ChangeValue("");
     }
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_CLICK_LABEL,CElementBase::Id(),CElementBase::Index(),m_label.Description());
   return(true);
  }
//+------------------------------------------------------------------+
//| Handling the value entering in the edit                          |
//+------------------------------------------------------------------+
bool CTextEdit::OnEndEdit(const string edited_object)
  {
//--- Leave, if it has a different object name
   if(m_edit.Name()!=edited_object)
      return(false);
   ChangeValue(m_edit.Description());
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_END_EDIT,CElementBase::Id(),CElementBase::Index(),m_label.Description());
   return(true);
  }
//+------------------------------------------------------------------+
//| Change the width at the right edge of the form                   |
//+------------------------------------------------------------------+
void CTextEdit::ChangeWidthByRightWindowSide(void)
  {
//--- Coordinates
   int x=0;
//--- Sizes
   int x_size=0;
//--- Calculate and set the new size to the control background
   x_size=m_wnd.X2()-m_area.X()-m_auto_xresize_right_offset;
   CElementBase::XSize(x_size);
   m_area.XSize(x_size);
   m_area.X_Size(x_size);
//--- Calculate and set the new size to the indicator background
   m_edit_x_size=m_area.X2()-m_edit.X();
   m_edit.XSize(m_edit_x_size);
   m_edit.X_Size(m_edit_x_size);
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
