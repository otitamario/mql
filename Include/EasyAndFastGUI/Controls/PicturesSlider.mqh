//+------------------------------------------------------------------+
//|                                               PicturesSlider.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "RadioButtons.mqh"
#include "IconButton.mqh"
//--- Default picture
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp64\\no_image.bmp"
//+------------------------------------------------------------------+
//| Class for creating the Picture Slider                            |
//+------------------------------------------------------------------+
class CPicturesSlider : public CElement
  {
private:
   //--- Objects for creating the element
   CRectLabel        m_area;
   CBmpLabel         m_pictures[];
   CRadioButtons     m_radio_buttons;
   CIconButton       m_left_arrow;
   CIconButton       m_right_arrow;
   //--- Control background and frame color
   color             m_area_color;
   color             m_area_border_color;
   //--- Array of pictures (path to pictures)
   string            m_file_path[];
   //--- Default path to the picture
   string            m_default_path;
   //--- Margin for the pictures along the Y axis
   int               m_pictures_y_gap;
   //--- Margins for buttons
   int               m_arrows_x_gap;
   int               m_arrows_y_gap;
   //--- Width of the radio button
   int               m_radio_button_width;
   //--- Margins for radio buttons
   int               m_radio_buttons_x_gap;
   int               m_radio_buttons_y_gap;
   int               m_radio_buttons_x_offset;
   //--- Priorities of the left mouse button press
   int               m_zorder;
   //---
public:
                     CPicturesSlider(void);
                    ~CPicturesSlider(void);
   //--- Methods for creating the Picture Slider
   bool              CreatePicturesSlider(const long chart_id,const int subwin,const int x_gap,const int y_gap);
   //---
private:
   bool              CreateArea(void);
   bool              CreatePictures(void);
   bool              CreateRadioButtons(void);
   bool              CreateLeftArrow(void);
   bool              CreateRightArrow(void);
   //---
public:
   //--- Returns pointers to components
   CRadioButtons    *GetRadioButtonsPointer(void)            { return(::GetPointer(m_radio_buttons)); }
   CIconButton      *GetLeftArrowPointer(void)               { return(::GetPointer(m_left_arrow));    }
   CIconButton      *GetRightArrowPointer(void)              { return(::GetPointer(m_right_arrow));   }
   //--- (1) Color of the background and (2) background frame 
   void              AreaColor(const color clr)              { m_area_color=clr;                      }
   void              AreaBorderColor(const color clr)        { m_area_border_color=clr;               }
   //--- Margins for arrow buttons
   void              ArrowsXGap(const int x_gap)             { m_arrows_x_gap=x_gap;                  }
   void              ArrowsYGap(const int y_gap)             { m_arrows_y_gap=y_gap;                  }
   //--- (1) Returns the number of pictures, (2) margin for the pictures along the Y axis
   int               PicturesTotal(void)               const { return(::ArraySize(m_pictures));       }
   void              PictureYGap(const int y_gap)            { m_pictures_y_gap=y_gap;                }
   //--- (1) Margins of the radio buttons, (2) distance between the radio buttons
   void              RadioButtonsXGap(const int x_gap)       { m_radio_buttons_x_gap=x_gap;           }
   void              RadioButtonsYGap(const int y_gap)       { m_radio_buttons_y_gap=y_gap;           }
   void              RadioButtonsXOffset(const int x_offset) { m_radio_buttons_x_offset=x_offset;     }
   //--- Add picture
   void              AddPicture(const string file_path="");
   //--- Switches the picture at the specified index
   void              SelectPicture(const int index);
   //---
public:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Timer
   virtual void      OnEventTimer(void) {}
   //--- Moving the element
   virtual void      Moving(const int x,const int y,const bool moving_mode=false);
   //--- (1) Show, (2) hide, (3) reset, (4) delete
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Reset(void);
   virtual void      Delete(void);
   //---
private:
   //--- Handling the clicking of left button
   bool              OnClickLeftArrow(const string clicked_object);
   //--- Handling the clicking of right button
   bool              OnClickRightArrow(const string clicked_object);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPicturesSlider::CPicturesSlider(void) : m_default_path("Images\\EasyAndFastGUI\\Icons\\bmp64\\no_image.bmp"),
                                         m_area_color(clrNONE),
                                         m_area_border_color(clrNONE),
                                         m_arrows_x_gap(2),
                                         m_arrows_y_gap(2),
                                         m_radio_button_width(12),
                                         m_radio_buttons_x_gap(25),
                                         m_radio_buttons_y_gap(1),
                                         m_radio_buttons_x_offset(20),
                                         m_pictures_y_gap(25)
  {
//--- Store the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
//--- Set priorities of the left mouse button click
   m_zorder=0;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPicturesSlider::~CPicturesSlider(void)
  {
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CPicturesSlider::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
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
      CElementBase::CheckMouseFocus();
      return;
     }
//--- Handling the event of clicking the radio button
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_LABEL)
     {
      //--- If this is a radio button of the slider, switch the picture
      if(lparam==CElementBase::Id())
         SelectPicture(m_radio_buttons.SelectedButtonIndex());
      //---
      return;
     }
//--- Handling the left mouse button click on the object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- If an arrow button of the slider was clicked, switch the picture
      if(OnClickLeftArrow(sparam))
         return;
      if(OnClickRightArrow(sparam))
         return;
      //---
      return;
     }
  }
//+------------------------------------------------------------------+
//| Create Picture control                                           |
//+------------------------------------------------------------------+
bool CPicturesSlider::CreatePicturesSlider(const long chart_id,const int subwin,const int x_gap,const int y_gap)
  {
//--- Exit if there is no pointer to the form
   if(!CElement::CheckWindowPointer())
      return(false);
//--- Initializing variables
   m_id                =m_wnd.LastId()+1;
   m_chart_id          =chart_id;
   m_subwin            =subwin;
   m_x                 =CElement::CalculateX(x_gap);
   m_y                 =CElement::CalculateY(y_gap);
   m_area_color        =(m_area_color!=clrNONE)? m_area_color : m_wnd.WindowBgColor();
   m_area_border_color =(m_area_border_color!=clrNONE)? m_area_border_color : m_wnd.WindowBgColor();
//--- Margins from the edge
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
//--- Creating an element
   if(!CreateArea())
      return(false);
   if(!CreatePictures())
      return(false);
   if(!CreateRadioButtons())
      return(false);
   if(!CreateLeftArrow())
      return(false);
   if(!CreateRightArrow())
      return(false);
//--- Hide the element if the window is a dialog one or is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the background of the control                             |
//+------------------------------------------------------------------+
bool CPicturesSlider::CreateArea(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_pictures_slider_area_"+(string)CElementBase::Id();
//--- Set the object
   if(!m_area.Create(m_chart_id,name,m_subwin,m_x,m_y,m_x_size,m_y_size))
      return(false);
//--- Set properties
   m_area.BackColor(m_area_color);
   m_area.Color(m_area_border_color);
   m_area.BorderType(BORDER_FLAT);
   m_area.Corner(m_corner);
   m_area.Selectable(false);
   m_area.Z_Order(m_zorder);
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
//| Create group of pictures                                         |
//+------------------------------------------------------------------+
bool CPicturesSlider::CreatePictures(void)
  {
//--- Get the number of pictures
   int pictures_total=PicturesTotal();
//--- If there is no picture in the group, report
   if(pictures_total<1)
     {
      ::Print(__FUNCTION__," > This method is to be called, "
              "if a group contains at least one picture! Use the CPicturesSlider::AddPicture() method");
      return(false);
     }
//--- Coordinates
   int x=CElementBase::X();
   int y=CElementBase::Y()+m_pictures_y_gap;
//---
   for(int i=0; i<pictures_total; i++)
     {
      //--- Formation of the window name
      string name=CElementBase::ProgramName()+"_pictures_slider_bmp_"+(string)i+"__"+(string)CElementBase::Id();
      //--- Set the object
      if(!m_pictures[i].Create(m_chart_id,name,m_subwin,x,y))
         return(false);
      //--- Set properties
      m_pictures[i].BmpFileOn("::"+m_file_path[i]);
      m_pictures[i].BmpFileOff("::"+m_file_path[i]);
      m_pictures[i].Color(m_wnd.CaptionBgColor());
      m_pictures[i].Corner(m_corner);
      m_pictures[i].Selectable(false);
      m_pictures[i].Z_Order(m_zorder);
      m_pictures[i].Tooltip("\n");
      //--- Store coordinates
      m_pictures[i].X(x);
      m_pictures[i].Y(y);
      //--- Store the size
      m_pictures[i].XSize(m_pictures[i].X_Size());
      m_pictures[i].YSize(m_pictures[i].Y_Size());
      //--- Margins from the edge
      m_pictures[i].XGap(CElement::CalculateXGap(x));
      m_pictures[i].YGap(CElement::CalculateYGap(y));
      //--- Store the object pointer
      CElementBase::AddToArray(m_pictures[i]);
     }
//--- Adjusting height of the control
   int area_y2 =m_pictures[0].Y()+m_pictures[0].YSize()+10;
   int y_size  =area_y2-m_area.Y();
   m_area.YSize(y_size);
   m_area.Y_Size(y_size);
   CElementBase::YSize(y_size);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates group of radio buttons                                   |
//+------------------------------------------------------------------+
bool CPicturesSlider::CreateRadioButtons(void)
  {
   int pictures_total=PicturesTotal();
//--- Store the window pointer
   m_radio_buttons.WindowPointer(m_wnd);
//--- Coordinates
   int x =CElement::CalculateXGap(CElementBase::X()+m_radio_buttons_x_gap);
   int y =CElement::CalculateYGap(CElementBase::Y()+m_radio_buttons_y_gap);
//--- Properties
   int buttons_x_offset[];
//--- Set the array sizes
   ::ArrayResize(buttons_x_offset,pictures_total);
//--- Margins between the radio buttons
   for(int i=0; i<pictures_total; i++)
      buttons_x_offset[i]=(i>0)? buttons_x_offset[i-1]+m_radio_buttons_x_offset : 0;
//--- Background color
   m_radio_buttons.AreaColor(m_area_color);
//--- Add buttons to the group
   for(int i=0; i<pictures_total; i++)
      m_radio_buttons.AddButton(buttons_x_offset[i],0,"",m_radio_button_width);
//--- Create a group of buttons
   if(!m_radio_buttons.CreateRadioButtons(m_chart_id,m_subwin,x,y))
      return(false);
//--- Show picture at the selected radio button
   SelectPicture(0);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates button with left arrow                                   |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Controls\\ArrowLeft.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\ArrowLeft_blue.bmp"
//---
bool CPicturesSlider::CreateLeftArrow(void)
  {
//--- Store the window pointer
   m_left_arrow.WindowPointer(m_wnd);
//--- Coordinates
   int x =CElement::CalculateXGap(CElementBase::X()+m_arrows_x_gap);
   int y =CElement::CalculateYGap(CElementBase::Y()+m_arrows_y_gap);
//--- Set properties before creation
   m_left_arrow.Index(0);
   m_left_arrow.TwoState(false);
   m_left_arrow.OnlyIcon(true);
   m_left_arrow.IconFileOn("Images\\EasyAndFastGUI\\Controls\\ArrowLeft_blue.bmp");
   m_left_arrow.IconFileOff("Images\\EasyAndFastGUI\\Controls\\ArrowLeft.bmp");
//--- Create control
   if(!m_left_arrow.CreateIconButton(m_chart_id,m_subwin,"\n",x,y))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates button with right arrow                                  |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Controls\\ArrowRight.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\ArrowRight_blue.bmp"
//---
bool CPicturesSlider::CreateRightArrow(void)
  {
//--- Store the window pointer
   m_right_arrow.WindowPointer(m_wnd);
//--- The number of pictures
   int pictures_total=PicturesTotal();
//--- Calculating coordinates keeping symmetry
   int radio_button_width =pictures_total*m_radio_buttons_x_offset-(m_radio_buttons_x_offset-m_radio_button_width);
   int different          =m_radio_buttons.X()-m_left_arrow.X2();
   int x                  =CElement::CalculateXGap(m_radio_buttons.X()+radio_button_width+different);
   int y                  =CElement::CalculateYGap(CElementBase::Y()+m_arrows_y_gap);
//--- Set properties before creation
   m_right_arrow.Index(1);
   m_right_arrow.TwoState(false);
   m_right_arrow.OnlyIcon(true);
   m_right_arrow.IconFileOn("Images\\EasyAndFastGUI\\Controls\\ArrowRight_blue.bmp");
   m_right_arrow.IconFileOff("Images\\EasyAndFastGUI\\Controls\\ArrowRight.bmp");
//--- Create control
   if(!m_right_arrow.CreateIconButton(m_chart_id,m_subwin,"\n",x,y))
      return(false);
//--- Adjusting width of the control
   int area_x2 =m_right_arrow.X2()+(m_left_arrow.X()-m_area.X());
   int x_size  =area_x2-m_area.X();
   m_area.XSize(x_size);
   m_area.X_Size(x_size);
   CElementBase::XSize(x_size);
//--- Adjusting the X coordinate of pictures (aligned to the center of the control area)
   for(int i=0; i<pictures_total; i++)
     {
      int pic_d2=(m_area.XSize()/2)-(m_pictures[i].XSize()/2);
      x=m_area.X()+pic_d2;
      m_pictures[i].X(x);
      m_pictures[i].X_Distance(x);
      m_pictures[i].XGap(x-m_wnd.X());
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Add picture                                                      |
//+------------------------------------------------------------------+
void CPicturesSlider::AddPicture(const string file_path="")
  {
//--- Increase the array size by one element
   int array_size=::ArraySize(m_pictures);
   int new_size=array_size+1;
   ::ArrayResize(m_pictures,new_size);
   ::ArrayResize(m_file_path,new_size);
//--- Store the values of passed parameters
   m_file_path[array_size]=(file_path=="")? m_default_path : file_path;
  }
//+------------------------------------------------------------------+
//| Specifies the picture to be displayed                            |
//+------------------------------------------------------------------+
void CPicturesSlider::SelectPicture(const int index)
  {
//--- Get the number of pictures
   int pictures_total=PicturesTotal();
//--- If there is no picture in the group, report
   if(pictures_total<1)
     {
      ::Print(__FUNCTION__," > This method is to be called, "
              "if a group contains at least one picture! Use the CPicturesSlider::AddPicture() method");
      return;
     }
//--- Adjust the index value if the array range is exceeded
   uint correct_index=(index>=pictures_total)? pictures_total-1 :(index<0)? 0 : index;
//--- Select the radio button at this index
   m_radio_buttons.SelectRadioButton(correct_index);
//--- Switch to picture
   for(int i=0; i<pictures_total; i++)
     {
      if(i==correct_index)
         m_pictures[i].Timeframes(OBJ_ALL_PERIODS);
      else
         m_pictures[i].Timeframes(OBJ_NO_PERIODS);
     }
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CPicturesSlider::Moving(const int x,const int y,const bool moving_mode=false)
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
     }
   else
     {
      CElementBase::X(x+XGap());
      m_area.X(x+m_area.XGap());
     }
//--- If the anchored to the bottom
   if(m_anchor_bottom_window_side)
     {
      CElementBase::Y(m_wnd.Y2()-YGap());
      m_area.Y(m_wnd.Y2()-m_area.YGap());
     }
   else
     {
      CElementBase::Y(y+YGap());
      m_area.Y(y+m_area.YGap());
     }
//--- Updating coordinates of graphical objects
   m_area.X_Distance(m_area.X());
   m_area.Y_Distance(m_area.Y());
//---
   int pictures_total=PicturesTotal();
   for(int i=0; i<pictures_total; i++)
     {
      //--- If the anchored to the right
      if(m_anchor_right_window_side)
         m_pictures[i].X(m_wnd.X2()-m_pictures[i].XGap());
      else
         m_pictures[i].X(x+m_pictures[i].XGap());
      //--- If the anchored to the bottom
      if(m_anchor_bottom_window_side)
         m_pictures[i].Y(m_wnd.Y2()-m_pictures[i].YGap());
      else
         m_pictures[i].Y(y+m_pictures[i].YGap());
      //--- Updating coordinates of graphical objects
      m_pictures[i].X_Distance(m_pictures[i].X());
      m_pictures[i].Y_Distance(m_pictures[i].Y());
     }
  }
//+------------------------------------------------------------------+
//| Shows the element                                                |
//+------------------------------------------------------------------+
void CPicturesSlider::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElementBase::IsVisible())
      return;
//--- Make all the objects visible
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_ALL_PERIODS);
//--- Show all elements
   m_radio_buttons.Show();
   m_left_arrow.Show();
   m_right_arrow.Show();
//--- Display only the selected picture
   SelectPicture(m_radio_buttons.SelectedButtonIndex());
//--- Visible state
   CElementBase::IsVisible(true);
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
//| Hides the element                                                |
//+------------------------------------------------------------------+
void CPicturesSlider::Hide(void)
  {
//--- Leave, if the element is already visible
   if(!CElementBase::IsVisible())
      return;
//--- Hide all objects
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_NO_PERIODS);
//--- Hide all controls
   m_radio_buttons.Hide();
   m_left_arrow.Hide();
   m_right_arrow.Hide();
//--- Visible state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CPicturesSlider::Reset(void)
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
void CPicturesSlider::Delete(void)
  {
//--- Delete background
   m_area.Delete();
//--- Delete pictures
   int pictures_total=PicturesTotal();
   for(int i=0; i<pictures_total; i++)
      m_pictures[i].Delete();
//--- Emptying the control arrays
   ::ArrayFree(m_pictures);
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
//--- Initializing of variables by default values
   CElementBase::MouseFocus(false);
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Clicking the left mouse button                                   |
//+------------------------------------------------------------------+
bool CPicturesSlider::OnClickLeftArrow(const string clicked_object)
  {
//--- Leave, if clicking was not on the button
   if(::StringFind(clicked_object,CElementBase::ProgramName()+"_icon_button_",0)<0)
      return(false);
//--- Get the identifier of the control from the object name
   int id=CElementBase::IdFromObjectName(clicked_object);
//--- Get the index of the control from the object name
   int index=CElementBase::IndexFromObjectName(clicked_object);
//--- Exit if identifiers of elements don't match
   if(id!=CElementBase::Id())
      return(false);
//--- Leave, if control indexes do not match
   if(index!=0)
      return(false);
//--- Get the current index of the selected radio button
   int selected_radio_button=m_radio_buttons.SelectedButtonIndex();
//--- Switch the picture
   SelectPicture(--selected_radio_button);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_CLICK_BUTTON,CElementBase::Id(),CElementBase::Index(),"");
   return(true);
  }
//+------------------------------------------------------------------+
//| Clicking the right button                                        |
//+------------------------------------------------------------------+
bool CPicturesSlider::OnClickRightArrow(const string clicked_object)
  {
//--- Leave, if clicking was not on the button
   if(::StringFind(clicked_object,CElementBase::ProgramName()+"_icon_button_",0)<0)
      return(false);
//--- Get the identifier of the control from the object name
   int id=CElementBase::IdFromObjectName(clicked_object);
//--- Get the index of the control from the object name
   int index=CElementBase::IndexFromObjectName(clicked_object);
//--- Exit if identifiers of elements don't match
   if(id!=CElementBase::Id())
      return(false);
//--- Leave, if control indexes do not match
   if(index!=1)
      return(false);
//--- Get the current index of the selected radio button
   int selected_radio_button=m_radio_buttons.SelectedButtonIndex();
//--- Switch the picture
   SelectPicture(++selected_radio_button);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_CLICK_BUTTON,CElementBase::Id(),CElementBase::Index(),"");
   return(true);
  }
//+------------------------------------------------------------------+
