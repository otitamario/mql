//+------------------------------------------------------------------+
//|                                                 ButtonsGroup.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
//+------------------------------------------------------------------+
//| Class for creating a group of simple buttons                     |
//+------------------------------------------------------------------+
class CButtonsGroup : public CElement
  {
private:
   //--- Object for creating a button
   CButton           m_buttons[];
   //--- Button gradients
   struct ButtonsGradients
     {
      color             m_buttons_color_array[];
     };
   ButtonsGradients  m_buttons_total[];
   //--- Button properties:
   //    The radio button mode
   bool              m_radio_buttons_mode;
   //--- Arrays for unique properties of buttons
   bool              m_buttons_state[];
   int               m_buttons_x_gap[];
   int               m_buttons_y_gap[];
   string            m_buttons_text[];
   int               m_buttons_width[];
   color             m_buttons_color[];
   color             m_buttons_color_hover[];
   color             m_buttons_color_pressed[];
   //--- Height of buttons
   int               m_button_y_size;
   //--- Background colors
   color             m_back_color;
   color             m_back_color_off;
   color             m_back_color_hover;
   color             m_back_color_pressed;
   //--- Color frame in the active and blocked modes
   color             m_border_color;
   color             m_border_color_off;
   //--- Text color
   color             m_text_color;
   color             m_text_color_off;
   color             m_text_color_pressed;
   //--- (1) Text and (2) index of the highlighted button
   string            m_selected_button_text;
   int               m_selected_button_index;
   //--- Priority of left mouse click
   int               m_buttons_zorder;
   //--- Available/blocked
   bool              m_buttons_group_state;
   //---
public:
                     CButtonsGroup(void);
                    ~CButtonsGroup(void);
   //--- Methods for creating a button
   bool              CreateButtonsGroup(const long chart_id,const int subwin,const int x_gap,const int y_gap);
   //---
private:
   bool              CreateButtons(void);
   //---
public:
   //--- (1) the number of buttons, (2) general state of the button group (available/blocked)
   int               ButtonsTotal(void)                       const { return(::ArraySize(m_buttons));  }
   bool              ButtonsGroupState(void)                  const { return(m_buttons_group_state);   }
   void              ButtonsGroupState(const bool state);
   //--- (1) height of buttons, (2) setting the radio button mode
   void              ButtonYSize(const int y_size)                  { m_button_y_size=y_size;          }
   void              RadioButtonsMode(const bool flag)              { m_radio_buttons_mode=flag;       }
   //--- (1) Background colors of a blocked button and a frame ((2) available/(3) blocked)
   void              BackColorOff(const color clr)                  { m_back_color_off=clr;            }
   void              BorderColor(const color clr)                   { m_border_color=clr;              }
   void              BorderColorOff(const color clr)                { m_border_color_off=clr;          }
   //--- Text color
   void              TextColor(const color clr)                     { m_text_color=clr;                }
   void              TextColorOff(const color clr)                  { m_text_color_off=clr;            }
   void              TextColorPressed(const color clr)              { m_text_color_pressed=clr;        }
   //--- Returns (1) the text and (2) index of the highlighted button
   string            SelectedButtonText(void)                 const { return(m_selected_button_text);  }
   int               SelectedButtonIndex(void)                const { return(m_selected_button_index); }
   //--- Set the text by the specified index
   void              Text(const uint index,const string text);
   //--- Set the button background color
   void              BackColor(const uint index,const color clr);
   void              BackColorHover(const uint index,const color clr);
   void              BackColorPressed(const uint index,const color clr);
   //--- Toggles the button state by the specified index
   void              SelectButton(const uint index);

   //--- Adds a button with specified properties before creation
   void              AddButton(const int x_gap,const int y_gap,const string text,const int width,
                               const color button_color=clrNONE,const color button_color_hover=clrNONE,const color button_color_pressed=clrNONE);
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
   //--- Checking the pressed left mouse button over the group buttons
   void              CheckPressedOverButton(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CButtonsGroup::CButtonsGroup(void) : m_radio_buttons_mode(false),
                                     m_buttons_group_state(true),
                                     m_button_y_size(22),
                                     m_selected_button_text(""),
                                     m_selected_button_index(WRONG_VALUE),
                                     m_back_color(clrGainsboro),
                                     m_back_color_off(clrLightGray),
                                     m_back_color_hover(C'193,218,255'),
                                     m_back_color_pressed(C'190,190,200'),
                                     m_text_color(clrBlack),
                                     m_text_color_off(clrDarkGray),
                                     m_text_color_pressed(clrBlack),
                                     m_border_color(C'150,170,180'),
                                     m_border_color_off(C'178,195,207')
  {
//--- Store the name of the element class in the base class  
   CElementBase::ClassName(CLASS_NAME);
//--- Set priorities of the left mouse button click
   m_buttons_zorder=1;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CButtonsGroup::~CButtonsGroup(void)
  {
  }
//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void CButtonsGroup::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
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
      //--- Leave, if the buttons are blocked
      if(!m_buttons_group_state)
         return;
      //--- Define the focus
      int buttons_total=ButtonsTotal();
      for(int i=0; i<buttons_total; i++)
        {
         m_buttons[i].MouseFocus(m_mouse.X()>m_buttons[i].X() && m_mouse.X()<m_buttons[i].X2() && 
                                 m_mouse.Y()>m_buttons[i].Y() && m_mouse.Y()<m_buttons[i].Y2());
        }
      //--- Leave, if the form is blocked
      if(m_wnd.IsLocked())
         return;
      //--- Leave, if the mouse button is not pressed
      if(!m_mouse.LeftButtonState())
         return;
      //--- Checking the pressed left mouse button over the group buttons
      CheckPressedOverButton();
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
void CButtonsGroup::OnEventTimer(void)
  {
//--- Change the color, if the form is not blocked
   if(!m_wnd.IsLocked())
      ChangeObjectsColor();
  }
//+------------------------------------------------------------------+
//| Create group of buttons                                          |
//+------------------------------------------------------------------+
bool CButtonsGroup::CreateButtonsGroup(const long chart_id,const int subwin,const int x_gap,const int y_gap)
  {
//--- Exit if there is no pointer to the form
   if(!CElement::CheckWindowPointer())
      return(false);
//--- Initializing variables
   m_id       =m_wnd.LastId()+1;
   m_chart_id =chart_id;
   m_subwin   =subwin;
   m_x        =CElement::CalculateX(x_gap);
   m_y        =CElement::CalculateY(y_gap);
//--- Create buttons
   if(!CreateButtons())
      return(false);
//--- Hide the element if the window is a dialog one or is minimized
   if(CElement::m_wnd.WindowType()==W_DIALOG || CElement::m_wnd.IsMinimized())
      Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates buttons                                                  |
//+------------------------------------------------------------------+
bool CButtonsGroup::CreateButtons(void)
  {
//--- Coordinates
   int x=0,y=0;
//--- Get the number of buttons
   int buttons_total=ButtonsTotal();
//--- If there is no button in a group, report
   if(buttons_total<1)
     {
      ::Print(__FUNCTION__," > This method is to be called, "
              "if a group contains at least one button! Use the CButtonsGroup::AddButton() method");
      return(false);
     }
//--- Create the specified number of buttons
   for(int i=0; i<buttons_total; i++)
     {
      //--- Formation of the window name
      string name=CElementBase::ProgramName()+"_buttons_"+(string)i+"__"+(string)CElementBase::Id();
      //--- Calculating coordinates
      x=m_x+m_buttons_x_gap[i];
      y=m_y+m_buttons_y_gap[i];
      //--- Set up a button
      if(!m_buttons[i].Create(m_chart_id,name,m_subwin,x,y,m_buttons_width[i],m_button_y_size))
         return(false);
      //--- Setting up properties
      m_buttons[i].State(false);
      m_buttons[i].Font(CElementBase::Font());
      m_buttons[i].FontSize(CElementBase::FontSize());
      m_buttons[i].Color(m_text_color);
      m_buttons[i].Description(m_buttons_text[i]);
      m_buttons[i].BorderColor(m_border_color);
      m_buttons[i].BackColor(m_buttons_color[i]);
      m_buttons[i].Corner(m_corner);
      m_buttons[i].Anchor(m_anchor);
      m_buttons[i].Selectable(false);
      m_buttons[i].Z_Order(m_buttons_zorder);
      m_buttons[i].Tooltip("\n");
      //--- Coordinates
      m_buttons[i].X(x);
      m_buttons[i].Y(y);
      //--- Sizes
      m_buttons[i].XSize(m_buttons_width[i]);
      m_buttons[i].YSize(m_button_y_size);
      //--- Store margins from the edge
      m_buttons[i].XGap(CElement::CalculateXGap(x));
      m_buttons[i].YGap(CElement::CalculateYGap(y));
      //--- Initializing the array gradient
      CElementBase::InitColorArray(m_buttons_color[i],m_buttons_color_hover[i],m_buttons_total[i].m_buttons_color_array);
      //--- Store the object pointer
      CElementBase::AddToArray(m_buttons[i]);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Sets the button text                                             |
//+------------------------------------------------------------------+
void CButtonsGroup::Text(const uint index,const string text)
  {
//--- Get the number of buttons
   uint buttons_total=ButtonsTotal();
//--- Leave, if there is no button in a group
   if(buttons_total<1)
      return;
//--- Adjust the index value if the array range is exceeded
   uint correct_index=(index>=buttons_total)? buttons_total-1 : index;
//--- Store and set the text
   m_buttons_text[correct_index]=text;
   m_buttons[correct_index].Description(text);
  }
//+------------------------------------------------------------------+
//| Set the button color                                             |
//+------------------------------------------------------------------+
void CButtonsGroup::BackColor(const uint index,const color clr)
  {
//--- Get the number of buttons
   uint buttons_total=ButtonsTotal();
//--- Leave, if there is no button in a group
   if(buttons_total<1)
      return;
//--- Adjust the index value if the array range is exceeded
   uint correct_index=(index>=buttons_total)? buttons_total-1 : index;
//--- Store and set the color
   m_buttons_color[correct_index]=clr;
//--- If the element is not blocked
   if(m_buttons_group_state)
      m_buttons[correct_index].BackColor(clr);
//--- Initializing the array gradient
   CElementBase::InitColorArray(m_buttons_color[correct_index],m_buttons_color_hover[correct_index],m_buttons_total[correct_index].m_buttons_color_array);
  }
//+------------------------------------------------------------------+
//| Sets the button color when the cursor hovers over the button     |
//+------------------------------------------------------------------+
void CButtonsGroup::BackColorHover(const uint index,const color clr)
  {
//--- Get the number of buttons
   uint buttons_total=ButtonsTotal();
//--- Leave, if there is no button in a group
   if(buttons_total<1)
      return;
//--- Adjust the index value if the array range is exceeded
   uint correct_index=(index>=buttons_total)? buttons_total-1 : index;
//--- Store the color
   m_buttons_color_hover[correct_index]=clr;
//--- Initializing the array gradient
   CElementBase::InitColorArray(m_buttons_color[correct_index],m_buttons_color_hover[correct_index],m_buttons_total[correct_index].m_buttons_color_array);
  }
//+------------------------------------------------------------------+
//| Sets the button color in case of click                           |
//+------------------------------------------------------------------+
void CButtonsGroup::BackColorPressed(const uint index,const color clr)
  {
//--- Get the number of buttons
   uint buttons_total=ButtonsTotal();
//--- Leave, if there is no button in a group
   if(buttons_total<1)
      return;
//--- Adjust the index value if the array range is exceeded
   uint correct_index=(index>=buttons_total)? buttons_total-1 : index;
//--- Store the color
   m_buttons_color_pressed[correct_index]=clr;
//--- Initializing the array gradient
   CElementBase::InitColorArray(m_buttons_color[correct_index],m_buttons_color_hover[correct_index],m_buttons_total[correct_index].m_buttons_color_array);
  }
//+------------------------------------------------------------------+
//| Toggles the button state by the specified index                  |
//+------------------------------------------------------------------+
void CButtonsGroup::SelectButton(const uint index)
  {
//--- Leave, if the element is blocked
   if(!m_buttons_group_state)
     return;
//--- For checking for a pressed button in a group
   bool check_pressed_button=false;
//--- Get the number of buttons
   uint buttons_total=ButtonsTotal();
//--- If there is no button in a group, report
   if(buttons_total<1)
     {
      ::Print(__FUNCTION__," > This method is to be called, "
              "if a group contains at least one button! Use the CButtonsGroup::AddButton() method");
     }
//--- Adjust the index value if the array range is exceeded
   uint correct_index=(index>=buttons_total)? buttons_total-1 : index;
//--- Change the button state for the opposite
   m_buttons_state[correct_index]=(m_buttons_state[correct_index])? false : true;
//--- Iterate over a group of buttons
   for(uint i=0; i<buttons_total; i++)
     {
      //--- A relevant check is carried out depending on the mode
      bool condition=(m_radio_buttons_mode)?(i==correct_index) :(i==correct_index && m_buttons_state[i]);
      //--- If the condition is met, make the button pressed
      if(condition)
        {
         if(m_radio_buttons_mode)
            m_buttons_state[i]=true;
         //--- There is a pressed button
         check_pressed_button=true;
         m_buttons[i].State(true);
         //--- Set colors
         m_buttons[i].Color(m_text_color_pressed);
         m_buttons[i].BackColor(m_buttons_color_pressed[i]);
         CElementBase::InitColorArray(m_buttons_color_pressed[i],m_buttons_color_pressed[i],m_buttons_total[i].m_buttons_color_array);
        }
      //--- If the condition is not met, make the button unpressed
      else
        {
         //--- Set the disabled state and colors
         m_buttons_state[i]=false;
         m_buttons[i].State(false);
         m_buttons[i].Color(m_text_color);
         m_buttons[i].BackColor(m_buttons_color[i]);
         CElementBase::InitColorArray(m_buttons_color[i],m_buttons_color_hover[i],m_buttons_total[i].m_buttons_color_array);
        }
     }
//--- If there is a pressed button, store its text and index
   m_selected_button_text  =(check_pressed_button) ? m_buttons[correct_index].Description() : "";
   m_selected_button_index =(check_pressed_button) ? (int)correct_index : WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Adds a button                                                    |
//+------------------------------------------------------------------+
void CButtonsGroup::AddButton(const int x_gap,const int y_gap,const string text,const int width,
                              const color button_color=clrNONE,const color button_color_hover=clrNONE,const color pressed_button_color=clrNONE)
  {
//--- Increase the array size by one element
   int array_size=::ArraySize(m_buttons);
   int new_size=array_size+1;
   ::ArrayResize(m_buttons,new_size);
   ::ArrayResize(m_buttons_total,new_size);
   ::ArrayResize(m_buttons_state,new_size);
   ::ArrayResize(m_buttons_x_gap,new_size);
   ::ArrayResize(m_buttons_y_gap,new_size);
   ::ArrayResize(m_buttons_text,new_size);
   ::ArrayResize(m_buttons_width,new_size);
   ::ArrayResize(m_buttons_color,new_size);
   ::ArrayResize(m_buttons_color_hover,new_size);
   ::ArrayResize(m_buttons_color_pressed,new_size);
//--- Store the values of passed parameters
   m_buttons_x_gap[array_size]         =x_gap;
   m_buttons_y_gap[array_size]         =y_gap;
   m_buttons_text[array_size]          =text;
   m_buttons_width[array_size]         =width;
   m_buttons_color[array_size]         =(button_color==clrNONE)? m_back_color : button_color;
   m_buttons_color_hover[array_size]   =(button_color_hover==clrNONE)? m_back_color_hover : button_color_hover;
   m_buttons_color_pressed[array_size] =(pressed_button_color==clrNONE)? m_back_color_pressed : pressed_button_color;
   m_buttons_state[array_size]         =false;
  }
//+------------------------------------------------------------------+
//| Changing the object color when the cursor is hovering over it    |
//+------------------------------------------------------------------+
void CButtonsGroup::ChangeObjectsColor(void)
  {
//--- Leave, if the element is blocked
   if(!m_buttons_group_state)
      return;
//---
   int buttons_total=ButtonsTotal();
   for(int i=0; i<buttons_total; i++)
     {
      CElementBase::ChangeObjectColor(m_buttons[i].Name(),m_buttons[i].MouseFocus(),
                                  OBJPROP_BGCOLOR,m_buttons_color[i],m_buttons_color_hover[i],m_buttons_total[i].m_buttons_color_array);
     }
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CButtonsGroup::Moving(const int x,const int y,const bool moving_mode=false)
  {
//--- Leave, if the control is hidden
   if(!CElementBase::IsVisible())
      return;
//--- If the management is delegated to the window, identify its location
   if(!moving_mode)
      if(m_wnd.ClampingAreaMouse()!=PRESSED_INSIDE_HEADER)
         return;
//--- Storing coordinates in the element fields
   CElementBase::X((m_anchor_right_window_side)? m_wnd.X2()-XGap() : x+XGap());
   CElementBase::Y((m_anchor_bottom_window_side)? m_wnd.Y2()-YGap() : y+YGap());
//---
   int buttons_total=ButtonsTotal();
   for(int i=0; i<buttons_total; i++)
     {
      //--- Storing coordinates in the fields of the objects
      m_buttons[i].X((m_anchor_right_window_side)? m_wnd.X2()-m_buttons[i].XGap() : x+m_buttons[i].XGap());
      m_buttons[i].Y((m_anchor_bottom_window_side)? m_wnd.Y2()-m_buttons[i].YGap() : y+m_buttons[i].YGap());
      //--- Updating coordinates of graphical objects
      m_buttons[i].X_Distance(m_buttons[i].X());
      m_buttons[i].Y_Distance(m_buttons[i].Y());
     }
  }
//+------------------------------------------------------------------+
//| Shows the element                                                |
//+------------------------------------------------------------------+
void CButtonsGroup::Show(void)
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
//| Hides the element                                                |
//+------------------------------------------------------------------+
void CButtonsGroup::Hide(void)
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
void CButtonsGroup::Reset(void)
  {
//--- Leave, if this is a drop-down element
   if(CElementBase::IsDropdown())
      return;
//--- Hide and show
   Hide();
   Show();
  }
//+------------------------------------------------------------------+
//| Seth the priorities                                              |
//+------------------------------------------------------------------+
void CButtonsGroup::SetZorders(void)
  {
   int buttons_total=ButtonsTotal();
   for(int i=0; i<buttons_total; i++)
      m_buttons[i].Z_Order(m_buttons_zorder);
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CButtonsGroup::ResetZorders(void)
  {
   int buttons_total=ButtonsTotal();
   for(int i=0; i<buttons_total; i++)
      m_buttons[i].Z_Order(-1);
  }
//+------------------------------------------------------------------+
//| Remove                                                         |
//+------------------------------------------------------------------+
void CButtonsGroup::Delete(void)
  {
//--- Removing objects
   int buttons_total=ButtonsTotal();
   for(int i=0; i<buttons_total; i++)
      m_buttons[i].Delete();
//--- Emptying the control arrays
   ::ArrayFree(m_buttons);
   ::ArrayFree(m_buttons_total);
   ::ArrayFree(m_buttons_state);
   ::ArrayFree(m_buttons_x_gap);
   ::ArrayFree(m_buttons_y_gap);
   ::ArrayFree(m_buttons_text);
   ::ArrayFree(m_buttons_width);
   ::ArrayFree(m_buttons_color);
   ::ArrayFree(m_buttons_color_hover);
   ::ArrayFree(m_buttons_color_pressed);
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
//--- Initializing of variables by default values
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Changing the state of buttons                                    |
//+------------------------------------------------------------------+
void CButtonsGroup::ButtonsGroupState(const bool state)
  {
   m_buttons_group_state=state;
//---
   int buttons_total=ButtonsTotal();
   for(int i=0; i<buttons_total; i++)
     {
      m_buttons[i].State(false);
      m_buttons[i].Color((state)? m_text_color : m_text_color_off);
      m_buttons[i].BackColor((state)? m_buttons_color[i]: m_back_color_off);
      m_buttons[i].BorderColor((state)? m_border_color : m_border_color_off);
     }
//--- Press the button if it was pressed before blocking
   if(m_buttons_group_state)
     {
      if(m_selected_button_index!=WRONG_VALUE)
        {
         m_buttons[m_selected_button_index].State(true);
         m_buttons_state[m_selected_button_index]=true;
         m_buttons[m_selected_button_index].Color(m_text_color_pressed);
         m_buttons[m_selected_button_index].BackColor(m_buttons_color_pressed[m_selected_button_index]);
        }
     }
  }
//+------------------------------------------------------------------+
//| Pressing a button in a group                                     |
//+------------------------------------------------------------------+
bool CButtonsGroup::OnClickButton(const string pressed_object)
  {
//--- Leave, if the clicking was not on the menu item
   if(::StringFind(pressed_object,CElementBase::ProgramName()+"_buttons_",0)<0)
      return(false);
//--- Get the identifier from the object name
   int id=CElementBase::IdFromObjectName(pressed_object);
//--- Leave, if identifiers do not match
   if(id!=CElementBase::Id())
      return(false);
//--- For checking the index
   int check_index=WRONG_VALUE;
//--- Check, if the pressing was on one of the buttons of this group
   int buttons_total=ButtonsTotal();
//--- Leave, if the buttons are blocked
   if(!m_buttons_group_state)
     {
      for(int i=0; i<buttons_total; i++)
         m_buttons[i].State(false);
      //---
      return(false);
     }
//--- If the pressing took place, store the index
   for(int i=0; i<buttons_total; i++)
     {
      if(m_buttons[i].Name()==pressed_object)
        {
         check_index=i;
         break;
        }
     }
//--- Leave, if the button of this group was not pressed
   if(check_index==WRONG_VALUE)
      return(false);
//--- Toggle the button state
   SelectButton(check_index);
//--- Send a signal about it
   ::EventChartCustom(m_chart_id,ON_CLICK_BUTTON,CElementBase::Id(),m_selected_button_index,m_selected_button_text);
   return(true);
  }
//+------------------------------------------------------------------+
//| Checking the pressed left mouse button over the group buttons    |
//+------------------------------------------------------------------+
void CButtonsGroup::CheckPressedOverButton(void)
  {
   int buttons_total=ButtonsTotal();
//--- Set the color depending on the location of the left mouse button press
   for(int i=0; i<buttons_total; i++)
     {
      //--- If there is a focus, then the color of the pressed button
      if(m_buttons[i].MouseFocus())
         m_buttons[i].BackColor(m_buttons_color_pressed[i]);
      //--- If there is no focus, then...
      else
        {
         //--- ...if a group button is not pressed, assign the background color
         if(!m_buttons_state[i])
            m_buttons[i].BackColor(m_buttons_color[i]);
        }
     }
  }
//+------------------------------------------------------------------+
