//+------------------------------------------------------------------+
//|                                                  ProgressBar.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
//+------------------------------------------------------------------+
//| Class for creating a progress bar                                |
//+------------------------------------------------------------------+
class CIndicatorBar : public CElement
  {
private:
   //--- Objects for creating the element
   CRectLabel        m_area;
   CLabel            m_label;
   CRectLabel        m_bar_bg;
   CRectLabel        m_indicator;
   //--- Блоки
   CRectLabel        m_block1;
   CRectLabel        m_block2;
   CRectLabel        m_block3;
   CRectLabel        m_block4;
   CRectLabel        m_block5;
   //---
   CBmpLabel         m_icon;
   //--- Form label
   string            m_icon_file;
   //---
   color             m_block1_color;
   color             m_block2_color;
   color             m_block3_color;
   color             m_block4_color;
   color             m_block5_color;
   CLabel            m_percent;
   //--- Color of the control background
   color             m_area_color;
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
   //---
public:
                     CIndicatorBar(void);
                    ~CIndicatorBar(void);
   //--- Methods for creating the control
   bool              CreateProgressBar(const long chart_id,const int subwin,const int x_gap,const int y_gap);
   //---
private:
   bool              CreateArea(void);
   bool              CreateLabel(void);
   bool              CreateBarArea(void);
   bool              CreateIndicator(void);
   bool              CreateBlock1(void);
   bool              CreateBlock2(void);
   bool              CreateBlock3(void);
   bool              CreateBlock4(void);
   bool              CreateBlock5(void);
   bool              CreatePercent(void);
   bool              CreateIcon(int type);
   void              HideIcon(CBmpLabel &icon);
   void              ShowIcon(CBmpLabel &icon);
   void              HideBlock(CRectLabel &block);
   void              ShowBlock(CRectLabel &block,color c_block);
   //---
public:
   //--- (1) Background color, (2) name of the process and (3) text color
   void              AreaColor(const color clr)         { m_area_color=clr;                }
   string            LabelText(void)              const { return(m_label_text);            }
   void              LabelText(const string text)       { m_label_text =text;              }
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
   void              BarXSize(const int x_size)         { m_bar_x_size=x_size;             }
   void              BarYSize(const int y_size)         { m_bar_y_size=y_size;             }
   //--- (1) Offset of the progress bar along the two axes, (2) Offset of the percentage indication label
   void              BarXGap(const int x_gap)           { m_bar_x_gap=x_gap;               }
   void              BarYGap(const int y_gap)           { m_bar_y_gap=y_gap;               }
   //--- (1) Offset of the text label (percentage of the process), (2) the number of decimal places
   void              PercentXGap(const int x_gap)       { m_percent_x_gap=x_gap;           }
   void              PercentYGap(const int y_gap)       { m_percent_y_gap=y_gap;           }
   void              SetDigits(const int digits)        { m_digits=::fabs(digits);         }
   //--- Update the indicator with the specified values
   void              SetUpdate(const int Value,const int Level1,const int Level2,const int Level3,const int Level4,const int MaxLevel);
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
   //--- Change the width at the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CIndicatorBar::CIndicatorBar(void) : m_digits(0),
                                     m_area_color(clrNONE),
                                     m_label_x_gap(-70),
                                     m_label_y_gap(3),
                                     m_bar_x_gap(0),
                                     m_bar_y_gap(0),
                                     m_bar_y_size(20),
                                     m_bar_border_width(0),
                                     m_percent_x_gap(7),
                                     m_percent_y_gap(3),
                                     m_label_text("Progress:"),
                                     m_label_color(clrBlack),
                                     m_bar_area_color(C'225,225,225'),
                                     m_bar_border_color(C'225,225,225'),
                                     m_indicator_color(clrMediumSeaGreen),
                                     m_block1_color(C'0,0,225'),
                                     m_block2_color(C'0,150,0'),
                                     m_block3_color(C'225,225,0'),
                                     m_block4_color(C'225,100,0'),
                                     m_block5_color(C'204,0,0'),
                                     m_icon_file("")
  {
//--- Store the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
//--- Set priorities of the left mouse button click
   m_zorder=0;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CIndicatorBar::~CIndicatorBar(void)
  {
  }
//+------------------------------------------------------------------+
//| Create the "Progress bar" control                                |
//+------------------------------------------------------------------+
bool CIndicatorBar::CreateProgressBar(const long chart_id,const int subwin,const int x_gap,const int y_gap)
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
   m_area_color =(m_area_color!=clrNONE)? m_area_color : m_wnd.WindowBgColor();
//--- Margins from the edge
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
//--- Create the control objects
   if(!CreateArea())
      return(false);
   if(!CreateLabel())
      return(false);
   if(!CreateBarArea())
      return(false);
   //if(!CreateIcon(1))
   //   return(false);
   if(!CreateBlock1())
      return(false);
   if(!CreateBlock2())
      return(false);
   if(!CreateBlock3())
      return(false);
   if(!CreateBlock4())
      return(false);
   if(!CreateBlock5())
      return(false);
//if(!CreatePercent())
//   return(false);
//--- Hide the element if the window is a dialog one or is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the common background of the control                      |
//+------------------------------------------------------------------+
bool CIndicatorBar::CreateArea(void)
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
//| Create label with the process name                               |
//+------------------------------------------------------------------+
bool CIndicatorBar::CreateLabel(void)
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
bool CIndicatorBar::CreateBarArea(void)
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
bool CIndicatorBar::CreateIndicator(void)
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
//| Create progress indicator                                        |
//+------------------------------------------------------------------+
bool CIndicatorBar::CreateBlock1(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_block_bar1_indicator_"+(string)CElementBase::Id();
//--- Coordinates
   int x=m_bar_bg.X();
   int y=m_bar_bg.Y()+m_bar_border_width;
//--- Sizes
   int x_size=int(MathCeil(m_bar_bg.X_Size()*0.18));
   int y_size=m_bar_bg.YSize()-(m_bar_border_width*2);
//--- Set the object
   if(!m_block1.Create(m_chart_id,name,m_subwin,x,y,x_size,y_size))
      return(false);
//--- Set properties
   m_block1.BackColor(m_block1_color);
   m_block1.Color(clrBlack);
   m_block1.BorderType(BORDER_FLAT);
   m_block1.Corner(m_corner);
   m_block1.Selectable(false);
   m_block1.Z_Order(m_zorder);
   m_block1.Tooltip("\n");
//--- Coordinates
   m_block1.X(x);
   m_block1.Y(y);
//--- Coordinates
   m_block1.XSize(x_size);
   m_block1.YSize(y_size);
//--- Margins from the edge
   m_block1.XGap(CElement::CalculateXGap(x));
   m_block1.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_block1);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create progress indicator                                        |
//+------------------------------------------------------------------+
bool CIndicatorBar::CreateBlock2(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_block_bar2_indicator_"+(string)CElementBase::Id();
//--- Coordinates
   int x=int(1.025*m_bar_bg.X()+m_block1.X_Size());
   int y=m_bar_bg.Y()+m_bar_border_width;
//--- Sizes
   int x_size=int(MathCeil(m_bar_bg.X_Size()*0.18));
   int y_size=m_bar_bg.YSize()-(m_bar_border_width*2);
//--- Set the object
   if(!m_block2.Create(m_chart_id,name,m_subwin,x,y,x_size,y_size))
      return(false);
//--- Set properties
   m_block2.BackColor(m_block2_color);
   m_block2.Color(clrBlack);
   m_block2.BorderType(BORDER_FLAT);
   m_block2.Corner(m_corner);
   m_block2.Selectable(false);
   m_block2.Z_Order(m_zorder);
   m_block2.Tooltip("\n");
//--- Coordinates
   m_block2.X(x);
   m_block2.Y(y);
//--- Coordinates
   m_block2.XSize(x_size);
   m_block2.YSize(y_size);
//--- Margins from the edge
   m_block2.XGap(CElement::CalculateXGap(x));
   m_block2.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_block2);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create progress indicator                                        |
//+------------------------------------------------------------------+
bool CIndicatorBar::CreateBlock3(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_block_bar3_indicator_"+(string)CElementBase::Id();
//--- Coordinates
   int x=int(1.05*m_bar_bg.X()+2*m_block1.X_Size());
   int y=m_bar_bg.Y()+m_bar_border_width;
//--- Sizes
   int x_size=int(MathCeil(m_bar_bg.X_Size()*0.18));
   int y_size=m_bar_bg.YSize()-(m_bar_border_width*2);
//--- Set the object
   if(!m_block3.Create(m_chart_id,name,m_subwin,x,y,x_size,y_size))
      return(false);
//--- Set properties
   m_block3.BackColor(m_block3_color);
   m_block3.Color(clrBlack);
   m_block3.BorderType(BORDER_FLAT);
   m_block3.Corner(m_corner);
   m_block3.Selectable(false);
   m_block3.Z_Order(m_zorder);
   m_block3.Tooltip("\n");
//--- Coordinates
   m_block3.X(x);
   m_block3.Y(y);
//--- Coordinates
   m_block3.XSize(x_size);
   m_block3.YSize(y_size);
//--- Margins from the edge
   m_block3.XGap(CElement::CalculateXGap(x));
   m_block3.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_block3);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create progress indicator                                        |
//+------------------------------------------------------------------+
bool CIndicatorBar::CreateBlock4(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_block_bar4_indicator_"+(string)CElementBase::Id();
//--- Coordinates
   int x=int(1.075*m_bar_bg.X()+3*m_block1.X_Size());
   int y=m_bar_bg.Y()+m_bar_border_width;
//--- Sizes
   int x_size=int(MathCeil(m_bar_bg.X_Size()*0.18));
   int y_size=m_bar_bg.YSize()-(m_bar_border_width*2);
//--- Set the object
   if(!m_block4.Create(m_chart_id,name,m_subwin,x,y,x_size,y_size))
      return(false);
//--- Set properties
   m_block4.BackColor(m_block4_color);
   m_block4.Color(clrBlack);
   m_block4.BorderType(BORDER_FLAT);
   m_block4.Corner(m_corner);
   m_block4.Selectable(false);
   m_block4.Z_Order(m_zorder);
   m_block4.Tooltip("\n");
//--- Coordinates
   m_block4.X(x);
   m_block4.Y(y);
//--- Coordinates
   m_block4.XSize(x_size);
   m_block4.YSize(y_size);
//--- Margins from the edge
   m_block4.XGap(CElement::CalculateXGap(x));
   m_block4.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_block4);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create progress indicator                                        |
//+------------------------------------------------------------------+
bool CIndicatorBar::CreateBlock5(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_block_bar5_indicator_"+(string)CElementBase::Id();
//--- Coordinates
   int x=int(1.1*m_bar_bg.X()+4*m_block1.X_Size());
   int y=m_bar_bg.Y()+m_bar_border_width;
//--- Sizes
   int x_size=int(MathCeil(m_bar_bg.X_Size()*0.18));
   int y_size=m_bar_bg.YSize()-(m_bar_border_width*2);
//--- Set the object
   if(!m_block5.Create(m_chart_id,name,m_subwin,x,y,x_size,y_size))
      return(false);
//--- Set properties
   m_block5.BackColor(m_block5_color);
   m_block5.Color(clrBlack);
   m_block5.BorderType(BORDER_FLAT);
   m_block5.Corner(m_corner);
   m_block5.Selectable(false);
   m_block5.Z_Order(m_zorder);
   m_block5.Tooltip("\n");
//--- Coordinates
   m_block5.X(x);
   m_block5.Y(y);
//--- Coordinates
   m_block5.XSize(x_size);
   m_block5.YSize(y_size);
//--- Margins from the edge
   m_block5.XGap(CElement::CalculateXGap(x));
   m_block5.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_block5);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create label with indication of the progress percentage          |
//+------------------------------------------------------------------+
bool CIndicatorBar::CreatePercent(void)
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
   m_percent.Description("0");
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
//|                                                                  |
//+------------------------------------------------------------------+
void CIndicatorBar::SetUpdate(const int Value,const int Level1,const int Level2,const int Level3,const int Level4,const int MaxLevel)
  {
   if(Value<Level1)
      HideBlock(m_block1);
   else if(Value>=Level1)
                  ShowBlock(m_block1,m_block1_color);
   if(Value<Level2)
      HideBlock(m_block2);
   else if(Value>=Level2)
                  ShowBlock(m_block2,m_block2_color);
   if(Value<Level3)
      HideBlock(m_block3);
   else if(Value>=Level3)
                  ShowBlock(m_block3,m_block3_color);
   if(Value<Level4)
      HideBlock(m_block4);
   else if(Value>=Level4)
                  ShowBlock(m_block4,m_block4_color);
   if(Value<MaxLevel)
      HideBlock(m_block5);
   else if(Value>=MaxLevel)
                  ShowBlock(m_block5,m_block5_color);
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CIndicatorBar::Moving(const int x,const int y,const bool moving_mode=false)
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
      m_bar_bg.X(m_wnd.X2()-m_bar_bg.XGap());
      m_block1.X(m_wnd.X2()-m_block1.XGap());
      m_block2.X(m_wnd.X2()-m_block2.XGap());
      m_block3.X(m_wnd.X2()-m_block3.XGap());
      m_block4.X(m_wnd.X2()-m_block4.XGap());
      m_block5.X(m_wnd.X2()-m_block5.XGap());
      m_percent.X(m_wnd.X2()-m_percent.XGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::X(x+XGap());
      //--- Storing coordinates in the fields of the objects
      m_area.X(x+m_area.XGap());
      m_label.X(x+m_label.XGap());
      m_bar_bg.X(x+m_bar_bg.XGap());
      m_percent.X(x+m_percent.XGap());
      m_block1.X(x+m_block1.XGap());
      m_block2.X(x+m_block2.XGap());
      m_block3.X(x+m_block3.XGap());
      m_block4.X(x+m_block4.XGap());
      m_block5.X(x+m_block5.XGap());
     }
//--- If the anchored to the bottom
   if(m_anchor_bottom_window_side)
     {
      //--- Storing coordinates in the element fields
      CElementBase::Y(m_wnd.Y2()-YGap());
      //--- Storing coordinates in the fields of the objects
      m_area.Y(m_wnd.Y2()-m_area.YGap());
      m_label.Y(m_wnd.Y2()-m_label.YGap());
      m_bar_bg.Y(m_wnd.Y2()-m_bar_bg.YGap());
      m_percent.Y(m_wnd.Y2()-m_percent.YGap());
      m_block1.Y(m_wnd.Y2()-m_block1.YGap());
      m_block2.Y(m_wnd.Y2()-m_block2.YGap());
      m_block3.Y(m_wnd.Y2()-m_block3.YGap());
      m_block4.Y(m_wnd.Y2()-m_block4.YGap());
      m_block5.Y(m_wnd.Y2()-m_block5.YGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::Y(y+YGap());
      //--- Storing coordinates in the fields of the objects
      m_area.Y(y+m_area.YGap());
      m_label.Y(y+m_label.YGap());
      m_bar_bg.Y(y+m_bar_bg.YGap());
      m_percent.Y(y+m_percent.YGap());
      m_block1.Y(y+m_block1.YGap());
      m_block2.Y(y+m_block2.YGap());
      m_block3.Y(y+m_block3.YGap());
      m_block4.Y(y+m_block4.YGap());
      m_block5.Y(y+m_block5.YGap());
     }
//--- Updating coordinates of graphical objects
   m_area.X_Distance(m_area.X());
   m_area.Y_Distance(m_area.Y());
   m_label.X_Distance(m_label.X());
   m_label.Y_Distance(m_label.Y());
   m_bar_bg.X_Distance(m_bar_bg.X());
   m_bar_bg.Y_Distance(m_bar_bg.Y());
   m_percent.X_Distance(m_percent.X());
   m_percent.Y_Distance(m_percent.Y());
   m_block1.X_Distance(m_block1.X());
   m_block1.Y_Distance(m_block1.Y());
   m_block2.X_Distance(m_block2.X());
   m_block2.Y_Distance(m_block2.Y());
   m_block3.X_Distance(m_block3.X());
   m_block3.Y_Distance(m_block3.Y());
   m_block4.X_Distance(m_block4.X());
   m_block4.Y_Distance(m_block4.Y());
   m_block5.X_Distance(m_block5.X());
   m_block5.Y_Distance(m_block5.Y());
  }
//+------------------------------------------------------------------+
//| Shows a menu item                                                |
//+------------------------------------------------------------------+
void CIndicatorBar::Show(void)
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
void CIndicatorBar::Hide(void)
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
void CIndicatorBar::Reset(void)
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
void CIndicatorBar::Delete(void)
  {
   m_area.Delete();
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
void CIndicatorBar::SetZorders(void)
  {
   m_area.Z_Order(m_zorder);
   m_label.Z_Order(m_zorder);
   m_bar_bg.Z_Order(m_zorder);
   m_indicator.Z_Order(m_zorder);
   m_percent.Z_Order(m_zorder);
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CIndicatorBar::ResetZorders(void)
  {
   m_area.Z_Order(0);
   m_label.Z_Order(0);
   m_bar_bg.Z_Order(0);
   m_indicator.Z_Order(0);
   m_percent.Z_Order(0);
  }
//+------------------------------------------------------------------+
//| Change the width at the right edge of the form                   |
//+------------------------------------------------------------------+
void CIndicatorBar::ChangeWidthByRightWindowSide(void)
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
//|                                                                  |
//+------------------------------------------------------------------+
void CIndicatorBar::HideBlock(CRectLabel &block)
  {
   block.BackColor(m_bar_area_color);
   block.Color(m_bar_area_color);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CIndicatorBar::ShowBlock(CRectLabel &block,color c_block)
  {
   block.BackColor(c_block);
   block.Color(clrBlack);
  }
//+------------------------------------------------------------------+
//| Creates the program label                                        |
//+------------------------------------------------------------------+
//--- Icons (by default) symbolizing the program type
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\arrow_down.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\arrow_up.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\stop_gray.bmp"
//---
bool CIndicatorBar::CreateIcon(int type)
  {
   string name=CElementBase::ProgramName()+"_window_icon_"+(string)CElementBase::Id();
//--- Object coordinates
   int x=355;
   int y=50;
//--- Set the window icon
   if(!m_icon.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Default icon, if not specified by the user
   switch(type)
     {
      case 0:
        {
         m_icon_file="Images\\EasyAndFastGUI\\Icons\\bmp16\\stop_gray.bmp";
         break;
        }
      case 1:
        {
         m_icon_file="Images\\EasyAndFastGUI\\Icons\\bmp16\\arrow_up.bmp";
         break;
        }
      case 2:
        {
         m_icon_file="Images\\EasyAndFastGUI\\Icons\\bmp16\\arrow_down.bmp";
         break;
        }
     }
//--- Set properties
   m_icon.BmpFileOn("::"+m_icon_file);
   m_icon.BmpFileOff("::"+m_icon_file);
   m_icon.Corner(m_corner);
   m_icon.Selectable(false);
   m_icon.Z_Order(2);
   m_icon.Tooltip("\n");
//--- Store coordinates
   m_icon.X(x);
   m_icon.Y(y);
//--- Margins from the edge
   m_icon.XGap(x-m_x);
   m_icon.YGap(y-m_y);
//--- Store the size
   m_icon.XSize(m_icon.X_Size());
   m_icon.YSize(m_icon.Y_Size());
//--- Store the object pointer
   CElementBase::AddToArray(m_icon);
   return(true);
  }
//+------------------------------------------------------------------+
