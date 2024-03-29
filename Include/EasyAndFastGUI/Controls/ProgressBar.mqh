//+------------------------------------------------------------------+
//|                                                  ProgressBar.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
//+------------------------------------------------------------------+
//| Class for creating a progress bar                                |
//+------------------------------------------------------------------+
class CProgressBar : public CElement
  {
private:
   //--- Objects for creating the element
   CRectLabel        m_area;
   CBmpLabel         m_icon;
   CLabel            m_label;
   CRectLabel        m_bar_bg;
   CRectLabel        m_indicator;
   CLabel            m_percent;
   //--- Color of the control background
   color             m_area_color;
   //--- Control icons in the active and blocked states
   string            m_icon_file;
   //--- Icon margins
   int               m_icon_x_gap;
   int               m_icon_y_gap;
   //--- Description of the displayed process
   string            m_label_text;
   //--- Text color
   color             m_label_color;
   //--- Offset of the text label along the two axes
   int               m_label_x_gap;
   int               m_label_y_gap;
   //--- Color of the progress bar background and background frame
   color             m_bar_area_color;
   color             m_bar_border_color;
   //--- Progress bar sizes
   int               m_bar_x_size;
   int               m_bar_y_size;
   //--- Offset of the progress bar along the two axes
   int               m_bar_x_gap;
   int               m_bar_y_gap;
   //--- Frame width of the progress bar
   int               m_bar_border_width;
   //--- Color of the indicator
   color             m_indicator_color;
   //--- Offset of the percentage indication label
   int               m_percent_x_gap;
   int               m_percent_y_gap;
   //--- Number of decimal places
   int               m_digits;
   //--- Priorities of the left mouse button press
   int               m_zorder;
   //--- The number of range steps
   double            m_steps_total;
   //--- The current position of the indicator
   double            m_current_index;
   //---
public:
                     CProgressBar(void);
                    ~CProgressBar(void);
   //--- Methods for creating the control
   bool              CreateProgressBar(const long chart_id,const int subwin,const string text,const int x_gap,const int y_gap);
   //---
private:
   bool              CreateArea(void);
   bool              CreateIcon(void);
   bool              CreateLabel(void);
   bool              CreateBarArea(void);
   bool              CreateIndicator(void);
   bool              CreatePercent(void);
   //---
public:
   //--- Icon margins
   void              IconXGap(const int x_gap)          { m_icon_x_gap=x_gap;              }
   void              IconYGap(const int y_gap)          { m_icon_y_gap=y_gap;              }
   //--- (1) Background color, (2) name of the process and (3) text color
   void              AreaColor(const color clr)         { m_area_color=clr;                }
   string            LabelText(void)              const { return(m_label.Description());   }
   void              LabelText(const string text)       { m_label.Description(text);       }
   void              LabelColor(const color clr)        { m_label_color=clr;               }
   //--- Offset of the text label (name of the process)
   void              LabelXGap(const int x_gap)         { m_label_x_gap=x_gap;             }
   void              LabelYGap(const int y_gap)         { m_label_y_gap=y_gap;             }
   //--- Color (1) of the background and (2) the progress bar frame, (3) indicator color
   void              BarAreaColor(const color clr)      { m_bar_area_color=clr;            }
   void              BarBorderColor(const color clr)    { m_bar_border_color=clr;          }
   void              IndicatorColor(const color clr)    { m_indicator_color=clr;           }
   //--- (1) Border width, (2) Y-size of the indicator area
   void              BarBorderWidth(const int width)    { m_bar_border_width=width;        }
   void              BarYSize(const int y_size)         { m_bar_y_size=y_size;             }
   //--- (1) Offset of the progress bar along the two axes, (2) Offset of the percentage indication label
   void              BarXGap(const int x_gap)           { m_bar_x_gap=x_gap;               }
   void              BarYGap(const int y_gap)           { m_bar_y_gap=y_gap;               }
   //--- (1) Offset of the text label (percentage of the process), (2) the number of decimal places
   void              PercentXGap(const int x_gap)       { m_percent_x_gap=x_gap;           }
   void              PercentYGap(const int y_gap)       { m_percent_y_gap=y_gap;           }
   void              SetDigits(const int digits)        { m_digits=::fabs(digits);         }
   //--- Setting icons for the control in the active and blocked states
   void              IconFile(const string file_path);
   //--- Update the indicator with the specified values
   void              Update(const int index,const int total);
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
   //--- (1) Set, (2) reset priorities of the left mouse button click
   virtual void      SetZorders(void);
   virtual void      ResetZorders(void);
   //---
private:
   //--- Set new values ​​for the indicator
   void              CurrentIndex(const int index);
   void              StepsTotal(const int total);

   //--- Change the width at the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CProgressBar::CProgressBar(void) : m_digits(0),
                                   m_steps_total(1),
                                   m_current_index(0),
                                   m_area_color(clrNONE),
                                   m_icon_x_gap(0),
                                   m_icon_y_gap(0),
                                   m_icon_file(""),
                                   m_label_x_gap(0),
                                   m_label_y_gap(1),
                                   m_bar_x_gap(0),
                                   m_bar_y_gap(0),
                                   m_bar_border_width(0),
                                   m_percent_x_gap(7),
                                   m_percent_y_gap(1),
                                   m_label_text("Progress:"),
                                   m_label_color(clrBlack),
                                   m_bar_area_color(C'225,225,225'),
                                   m_bar_border_color(C'225,225,225'),
                                   m_indicator_color(clrMediumSeaGreen)
  {
//--- Store the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
//--- Set priorities of the left mouse button click
   m_zorder=0;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CProgressBar::~CProgressBar(void)
  {
  }
//+------------------------------------------------------------------+
//| Create the "Progress bar" control                                |
//+------------------------------------------------------------------+
bool CProgressBar::CreateProgressBar(const long chart_id,const int subwin,const string text,const int x_gap,const int y_gap)
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
//--- Create the control objects
   if(!CreateArea())
      return(false);
   if(!CreateIcon())
      return(false);
   if(!CreateLabel())
      return(false);
   if(!CreateBarArea())
      return(false);
   if(!CreateIndicator())
      return(false);
   if(!CreatePercent())
      return(false);
//--- Hide the element if the window is a dialog one or is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the common background of the control                      |
//+------------------------------------------------------------------+
bool CProgressBar::CreateArea(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_progress_area_"+(string)CElementBase::Id();
//--- Coordinates
   int x=CElementBase::X();
   int y=CElementBase::Y();
   m_x_size=(m_x_size<1)? m_wnd.X2()-x-m_auto_xresize_right_offset : m_x_size;
//--- Set the object
   if(!m_area.Create(m_chart_id,name,m_subwin,x,y,m_x_size,m_y_size))
      return(false);
//--- Set properties
   m_area.BackColor(m_area_color);
   m_area.Color(m_area_color);
   m_area.BorderType(BORDER_FLAT);
   m_area.Corner(m_corner);
   m_area.Selectable(false);
   m_area.Z_Order(m_zorder);
   m_area.Tooltip("\n");
//--- Coordinates
   m_area.X(x);
   m_area.Y(y);
//--- Coordinates
   m_area.XSize(m_x_size);
   m_area.YSize(m_y_size);
//--- Margins from the edge
   m_area.XGap(CElement::CalculateXGap(x));
   m_area.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_area);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the control icon                                         |
//+------------------------------------------------------------------+
bool CProgressBar::CreateIcon(void)
  {
//--- Leave, if the icon is not needed
   if(m_icon_file=="")
      return(true);
//--- Formation of the window name
   string name="";
   if(m_index==WRONG_VALUE)
      name=CElementBase::ProgramName()+"_progress_bmp_"+(string)CElementBase::Id();
   else
      name=CElementBase::ProgramName()+"_progress_bmp_"+(string)CElementBase::Index()+"__"+(string)CElementBase::Id();
//--- Calculate the coordinates
   int x =m_x+m_icon_x_gap;
   int y =m_y+m_icon_y_gap;
//--- Set the object
   if(!m_icon.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_icon.BmpFileOn("::"+m_icon_file);
   m_icon.BmpFileOff("::"+m_icon_file);
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
//| Create label with the process name                               |
//+------------------------------------------------------------------+
bool CProgressBar::CreateLabel(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_progress_lable_"+(string)CElementBase::Id();
//--- Coordinates
   int x=CElementBase::X()+m_label_x_gap;
   int y=CElementBase::Y()+m_label_y_gap;
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
//--- Coordinates
   m_label.X(x);
   m_label.Y(y);
//--- Margins from the edge
   m_label.XGap(CElement::CalculateXGap(x));
   m_label.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_label);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create background of the progress bar                            |
//+------------------------------------------------------------------+
bool CProgressBar::CreateBarArea(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_progress_bar_area_"+(string)CElementBase::Id();
//--- Coordinates and sizes
   int x=CElementBase::X()+m_bar_x_gap;
   int y=CElementBase::Y()+m_bar_y_gap;
   m_bar_x_size=m_area.X2()-x-40;
//--- Set the object
   if(!m_bar_bg.Create(m_chart_id,name,m_subwin,x,y,m_bar_x_size,m_bar_y_size))
      return(false);
//--- Set properties
   m_bar_bg.BackColor(m_bar_area_color);
   m_bar_bg.Color(m_bar_border_color);
   m_bar_bg.BorderType(BORDER_FLAT);
   m_bar_bg.Corner(m_corner);
   m_bar_bg.Selectable(false);
   m_bar_bg.Z_Order(m_zorder);
   m_bar_bg.Tooltip("\n");
//--- Coordinates
   m_bar_bg.X(x);
   m_bar_bg.Y(y);
//--- Coordinates
   m_bar_bg.XSize(m_bar_x_size);
   m_bar_bg.YSize(m_bar_y_size);
//--- Margins from the edge
   m_bar_bg.XGap(CElement::CalculateXGap(x));
   m_bar_bg.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_bar_bg);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create progress indicator                                        |
//+------------------------------------------------------------------+
bool CProgressBar::CreateIndicator(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_progress_bar_indicator_"+(string)CElementBase::Id();
//--- Coordinates
   int x=m_bar_bg.X()+m_bar_border_width;
   int y=m_bar_bg.Y()+m_bar_border_width;
//--- Sizes
   int x_size=1;
   int y_size=m_bar_bg.YSize()-(m_bar_border_width*2);
//--- Set the object
   if(!m_indicator.Create(m_chart_id,name,m_subwin,x,y,x_size,y_size))
      return(false);
//--- Set properties
   m_indicator.BackColor(m_indicator_color);
   m_indicator.Color(m_indicator_color);
   m_indicator.BorderType(BORDER_FLAT);
   m_indicator.Corner(m_corner);
   m_indicator.Selectable(false);
   m_indicator.Z_Order(m_zorder);
   m_indicator.Tooltip("\n");
//--- Coordinates
   m_indicator.X(x);
   m_indicator.Y(y);
//--- Coordinates
   m_indicator.XSize(x_size);
   m_indicator.YSize(y_size);
//--- Margins from the edge
   m_indicator.XGap(CElement::CalculateXGap(x));
   m_indicator.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_indicator);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create label with indication of the progress percentage          |
//+------------------------------------------------------------------+
bool CProgressBar::CreatePercent(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_progress_percent_"+(string)CElementBase::Id();
//--- Coordinates
   int x=m_bar_bg.X2()+m_percent_x_gap;
   int y=CElementBase::Y()+m_percent_y_gap;
//--- Set the object
   if(!m_percent.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_percent.Description("0%");
   m_percent.Font(CElementBase::Font());
   m_percent.FontSize(CElementBase::FontSize());
   m_percent.Color(m_label_color);
   m_percent.Corner(m_corner);
   m_percent.Anchor(m_anchor);
   m_percent.Selectable(false);
   m_percent.Z_Order(m_zorder);
   m_percent.Tooltip("\n");
//--- Margins from the edge
   m_percent.XGap(CElement::CalculateXGap(x));
   m_percent.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_percent);
   return(true);
  }
//+------------------------------------------------------------------+
//| The number of progress bar steps                                 |
//+------------------------------------------------------------------+
void CProgressBar::StepsTotal(const int total)
  {
//--- Adjust if less than 0
   m_steps_total=(total<1)? 1 : total;
//--- Adjust the index, if out of range
   if(m_current_index>m_steps_total)
      m_current_index=m_steps_total;
  }
//+------------------------------------------------------------------+
//| The current position of the indicator                            |
//+------------------------------------------------------------------+
void CProgressBar::CurrentIndex(const int index)
  {
//--- Adjust if less than 0
   if(index<0)
      m_current_index=1;
//--- Adjust the index, if out of range
   else
      m_current_index=(index>m_steps_total)? m_steps_total : index;
  }
//+------------------------------------------------------------------+
//| Set the picture                                                  |
//+------------------------------------------------------------------+
void CProgressBar::IconFile(const string file_path)
  {
   m_icon_file=file_path;
   m_icon.BmpFileOn("::"+file_path);
   m_icon.BmpFileOff("::"+file_path);
  }
//+------------------------------------------------------------------+
//| Update the progress bar                                          |
//+------------------------------------------------------------------+
void CProgressBar::Update(const int index,const int total)
  {
//--- Set the new index
   CurrentIndex(index);
//--- Set the new range
   StepsTotal(total);
//--- Calculate the indicator width
   double new_width=(m_current_index/m_steps_total)*m_bar_bg.XSize();
//--- Adjust if less than 1
   if((int)new_width<1)
      new_width=1;
   else
     {
      //--- Adjust with consideration of the frame width
      int x_size=m_bar_bg.XSize()-(m_bar_border_width*2);
      //--- Adjust, if out of range
      if((int)new_width>=x_size)
         new_width=x_size;
     }
//--- Set the new width to the indicator
   m_indicator.X_Size((int)new_width);
//--- Calculate the percentage and generate a string
   double percent =m_current_index/m_steps_total*100;
   string desc    =::DoubleToString((percent>100)? 100 : percent,m_digits)+"%";
//--- Set the new value
   m_percent.Description(desc);
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CProgressBar::Moving(const int x,const int y,const bool moving_mode=false)
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
      m_bar_bg.X(m_wnd.X2()-m_bar_bg.XGap());
      m_indicator.X(m_wnd.X2()-m_indicator.XGap());
      m_percent.X(m_wnd.X2()-m_percent.XGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::X(x+XGap());
      //--- Storing coordinates in the fields of the objects
      m_area.X(x+m_area.XGap());
      m_icon.X(x+m_icon.XGap());
      m_label.X(x+m_label.XGap());
      m_bar_bg.X(x+m_bar_bg.XGap());
      m_indicator.X(x+m_indicator.XGap());
      m_percent.X(x+m_percent.XGap());
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
      m_bar_bg.Y(m_wnd.Y2()-m_bar_bg.YGap());
      m_indicator.Y(m_wnd.Y2()-m_indicator.YGap());
      m_percent.Y(m_wnd.Y2()-m_percent.YGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::Y(y+YGap());
      //--- Storing coordinates in the fields of the objects
      m_area.Y(y+m_area.YGap());
      m_icon.Y(y+m_icon.YGap());
      m_label.Y(y+m_label.YGap());
      m_bar_bg.Y(y+m_bar_bg.YGap());
      m_indicator.Y(y+m_indicator.YGap());
      m_percent.Y(y+m_percent.YGap());
     }
//--- Updating coordinates of graphical objects
   m_area.X_Distance(m_area.X());
   m_area.Y_Distance(m_area.Y());
   m_icon.X_Distance(m_icon.X());
   m_icon.Y_Distance(m_icon.Y());
   m_label.X_Distance(m_label.X());
   m_label.Y_Distance(m_label.Y());
   m_bar_bg.X_Distance(m_bar_bg.X());
   m_bar_bg.Y_Distance(m_bar_bg.Y());
   m_indicator.X_Distance(m_indicator.X());
   m_indicator.Y_Distance(m_indicator.Y());
   m_percent.X_Distance(m_percent.X());
   m_percent.Y_Distance(m_percent.Y());
  }
//+------------------------------------------------------------------+
//| Shows a menu item                                                |
//+------------------------------------------------------------------+
void CProgressBar::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElementBase::IsVisible())
      return;
//--- Make all the objects visible
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_ALL_PERIODS);
//--- Visible state
   CElementBase::IsVisible(true);
//--- Update the control location on the form
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
//| Hides a menu item                                                |
//+------------------------------------------------------------------+
void CProgressBar::Hide(void)
  {
//--- Leave, if the element is already hidden
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
void CProgressBar::Reset(void)
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
void CProgressBar::Delete(void)
  {
   m_area.Delete();
   m_icon.Delete();
   m_label.Delete();
   m_bar_bg.Delete();
   m_indicator.Delete();
   m_percent.Delete();
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
//--- Visible state
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Seth the priorities                                              |
//+------------------------------------------------------------------+
void CProgressBar::SetZorders(void)
  {
   m_area.Z_Order(m_zorder);
   m_icon.Z_Order(m_zorder);
   m_label.Z_Order(m_zorder);
   m_bar_bg.Z_Order(m_zorder);
   m_indicator.Z_Order(m_zorder);
   m_percent.Z_Order(m_zorder);
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CProgressBar::ResetZorders(void)
  {
   m_area.Z_Order(0);
   m_icon.Z_Order(0);
   m_label.Z_Order(0);
   m_bar_bg.Z_Order(0);
   m_indicator.Z_Order(0);
   m_percent.Z_Order(0);
  }
//+------------------------------------------------------------------+
//| Change the width at the right edge of the form                   |
//+------------------------------------------------------------------+
void CProgressBar::ChangeWidthByRightWindowSide(void)
  {
//--- Coordinates
   int x=0;
//--- Sizes
   int x_size=0;
//--- Calculate and set the new size to the control background
   x_size=m_wnd.X2()-m_area.X()-m_auto_xresize_right_offset;
   m_area.XSize(x_size);
   m_area.X_Size(x_size);
//--- Calculate and set the new size to the indicator background
   x_size=m_area.X2()-m_bar_bg.X()-40;
   m_bar_bg.XSize(x_size);
   m_bar_bg.X_Size(x_size);
//--- Calculate and set the new coordinate for the percentage label
   x=m_bar_bg.X2()+m_percent_y_gap;
   m_percent.X(x);
   m_percent.X_Distance(x);
   m_percent.XGap(CElement::CalculateXGap(x));
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
