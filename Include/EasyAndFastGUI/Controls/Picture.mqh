//+------------------------------------------------------------------+
//|                                                      Picture.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
//--- Resources
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp64\\no_image.bmp"
//+------------------------------------------------------------------+
//| Class for creating picture                                       |
//+------------------------------------------------------------------+
class CPicture : public CElement
  {
private:
   //--- Objects for creating a picture
   CBmpLabel         m_picture;
   //--- Path to the picture
   string            m_path;
   //--- Priorities of the left mouse button press
   int               m_zorder;
   //---
public:
                     CPicture(void);
                    ~CPicture(void);
   //--- Methods for creating the picture
   bool              CreatePicture(const long chart_id,const int subwin,const int x_gap,const int y_gap);
   //---
private:
   bool              CreateBmpLabel(void);
   //---
public:
   //--- Gets/sets the path to the picture
   string            Path(void) const { return(m_path); }
   void              Path(const string path);
   //---
public:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {}
   //--- Timer
   virtual void      OnEventTimer(void) {}
   //--- Moving the element
   virtual void      Moving(const int x,const int y,const bool moving_mode=false);
   //--- (1) Show, (2) hide, (3) reset, (4) delete
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Reset(void);
   virtual void      Delete(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPicture::CPicture(void) : m_path("Images\\EasyAndFastGUI\\Icons\\bmp64\\no_image.bmp")

  {
//--- Store the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
//--- Set priorities of the left mouse button click
   m_zorder=0;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPicture::~CPicture(void)
  {
  }
//+------------------------------------------------------------------+
//| Create Picture control                                           |
//+------------------------------------------------------------------+
bool CPicture::CreatePicture(const long chart_id,const int subwin,const int x_gap,const int y_gap)
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
//--- Margins from the edge
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
//--- Creating an element
   if(!CreateBmpLabel())
      return(false);
//--- Hide the element if the window is a dialog one or is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates icon                                                     |
//+------------------------------------------------------------------+
bool CPicture::CreateBmpLabel(void)
  {
//--- Formation of the window name
   string name="";
   if(m_index==WRONG_VALUE)
      name=CElementBase::ProgramName()+"_picture_bmp_"+(string)CElementBase::Id();
   else
      name=CElementBase::ProgramName()+"_picture_bmp_"+(string)CElementBase::Index()+"__"+(string)CElementBase::Id();
//--- Coordinates
   int x=CElementBase::X();
   int y=CElementBase::Y();
//--- Set the object
   if(!m_picture.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_picture.BmpFileOn("::"+m_path);
   m_picture.BmpFileOff("::"+m_path);
   m_picture.Color(m_wnd.CaptionBgColor());
   m_picture.Corner(m_corner);
   m_picture.Selectable(false);
   m_picture.Z_Order(m_zorder);
   m_picture.Tooltip("\n");
//--- Margins from the edge
   m_picture.XGap(CElement::CalculateXGap(x));
   m_picture.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_picture);
   return(true);
  }
//+------------------------------------------------------------------+
//| Set the picture                                                  |
//+------------------------------------------------------------------+
void CPicture::Path(const string path)
  {
   m_path=path;
   m_picture.BmpFileOn("::"+path);
   m_picture.BmpFileOff("::"+path);
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CPicture::Moving(const int x,const int y,const bool moving_mode=false)
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
      m_picture.X(m_wnd.X2()-m_picture.XGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::X(x+XGap());
      //--- Storing coordinates in the fields of the objects
      m_picture.X(x+m_picture.XGap());
     }
//--- If the anchored to the bottom
   if(m_anchor_bottom_window_side)
     {
      //--- Storing coordinates in the element fields
      CElementBase::Y(m_wnd.Y2()-YGap());
      //--- Storing coordinates in the fields of the objects
      m_picture.Y(m_wnd.Y2()-m_picture.YGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::Y(y+YGap());
      //--- Storing coordinates in the fields of the objects
      m_picture.Y(y+m_picture.YGap());
     }
//--- Updating coordinates of graphical objects
   m_picture.X_Distance(m_picture.X());
   m_picture.Y_Distance(m_picture.Y());
  }
//+------------------------------------------------------------------+
//| Shows combobox                                                   |
//+------------------------------------------------------------------+
void CPicture::Show(void)
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
void CPicture::Hide(void)
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
void CPicture::Reset(void)
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
void CPicture::Delete(void)
  {
//--- Removing objects
   m_picture.Delete();
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
//--- Initializing of variables by default values
   CElementBase::MouseFocus(false);
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
