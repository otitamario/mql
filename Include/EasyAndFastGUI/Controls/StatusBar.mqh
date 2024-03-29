//+------------------------------------------------------------------+
//|                                                    StatusBar.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "SeparateLine.mqh"
//+------------------------------------------------------------------+
//| Class for creating the status bar                                |
//+------------------------------------------------------------------+
class CStatusBar : public CElement
  {
private:
   //--- Object for creating a button
   CRectLabel        m_area;
   CEdit             m_items[];
   CSeparateLine     m_sep_line[];
   //--- Properties:
   //    Arrays for unique properties
   int               m_width[];
   //--- (1) Color of the background and (2) background frame
   color             m_area_color;
   color             m_area_border_color;
   //--- Text color
   color             m_label_color;
   //--- Priority of the left mouse button click
   int               m_zorder;
   //--- Colors for separation lines
   color             m_sepline_dark_color;
   color             m_sepline_light_color;
   //---
public:
                     CStatusBar(void);
                    ~CStatusBar(void);
   //--- Methods for creating the status bar
   bool              CreateStatusBar(const long chart_id,const int subwin,const int x_gap,const int y_gap);
   //---
private:
   bool              CreateArea(void);
   bool              CreateItems(void);
   bool              CreateSeparateLine(const int line_index);
   //---
public:
   //--- (1) The number of items, color of (2) the background, (3) the background frame and (4) the text
   int               ItemsTotal(void)                           const { return(::ArraySize(m_items)); }
   void              AreaColor(const color clr)                       { m_area_color=clr;             }
   void              AreaBorderColor(const color clr)                 { m_area_border_color=clr;      }
   void              LabelColor(const color clr)                      { m_label_color=clr;            }
   //--- Colors of the separation lines
   void              SeparateLineDarkColor(const color clr)           { m_sepline_dark_color=clr;     }
   void              SeparateLineLightColor(const color clr)          { m_sepline_light_color=clr;    }

   //--- Adds the item with specified properties before creating the status bar
   void              AddItem(const int width);
   //--- Setting the value by the specified index
   void              ValueToItem(const uint index,const string value);
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
   //--- (1) Set, (2) reset priorities of the left mouse button click
   virtual void      SetZorders(void);
   virtual void      ResetZorders(void);
   //---
private:
   //--- Calculating the width of control
   int               CalculationXSize(void);
   //--- Calculating the width of the first item
   int               CalculationFirstItemXSize(void);
   //--- Calculation of the X coordinate of the item
   int               CalculationItemX(const int item_index=0);
   //--- Change the width at the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CStatusBar::CStatusBar(void) : m_area_color(C'225,225,225'),
                               m_area_border_color(C'225,225,225'),
                               m_label_color(clrBlack),
                               m_sepline_dark_color(C'160,160,160'),
                               m_sepline_light_color(clrWhite)
  {
//--- Store the name of the element class in the base class  
   CElementBase::ClassName(CLASS_NAME);
//--- Set priorities of the left mouse button click
   m_zorder=2;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CStatusBar::~CStatusBar(void)
  {
  }
//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void CStatusBar::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
  }
//+------------------------------------------------------------------+
//| Creates the status bar                                           |
//+------------------------------------------------------------------+
bool CStatusBar::CreateStatusBar(const long chart_id,const int subwin,const int x_gap,const int y_gap)
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
   m_x_size   =CalculationXSize();
//--- Margins from the edge
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
//--- Creates the status bar
   if(!CreateArea())
      return(false);
   if(!CreateItems())
      return(false);
//--- Hide the element if the window is minimized
   if(m_wnd.IsMinimized())
      Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the common area                                          |
//+------------------------------------------------------------------+
bool CStatusBar::CreateArea(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_statusbar_bg_"+(string)CElementBase::Id();
//--- Set the background of the status bar
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
//--- Store the size
   m_area.XSize(m_x_size);
   m_area.YSize(m_y_size);
//--- Margins from the edge
   m_area.XGap(CElement::CalculateXGap(m_x));
   m_area.YGap(CElement::CalculateYGap(m_y));
//--- Store the object pointer
   CElementBase::AddToArray(m_area);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a list of status bar items                               |
//+------------------------------------------------------------------+
bool CStatusBar::CreateItems(void)
  {
   int x=0,y=CElementBase::Y()+1;
//--- Get the number of items
   int items_total=ItemsTotal();
//--- If there are no items in the group, report and leave
   if(items_total<1)
     {
      ::Print(__FUNCTION__," > This method is to be called, "
              "if a group contains at least one item! Use the CStatusBar::AddItem() method");
      return(false);
     }
//--- If the width of the first item is not set, then calculate it in relation to the total width of other items
   if(m_width[0]<1)
      m_width[0]=CalculationFirstItemXSize();
//--- Create specified number of items
   for(int i=0; i<items_total; i++)
     {
      //--- Formation of the window name
      string name=CElementBase::ProgramName()+"_statusbar_edit_"+string(i)+"__"+(string)CElementBase::Id();
      //--- X coordinate
      x=CalculationItemX(i);
      //--- Creating the object
      if(!m_items[i].Create(m_chart_id,name,m_subwin,x,y,m_width[i],m_y_size-2))
         return(false);
      //--- Setting up properties
      m_items[i].Description("");
      m_items[i].TextAlign(ALIGN_LEFT);
      m_items[i].Font(CElementBase::Font());
      m_items[i].FontSize(CElementBase::FontSize());
      m_items[i].Color(m_label_color);
      m_items[i].BorderColor(m_area_color);
      m_items[i].BackColor(m_area_color);
      m_items[i].Corner(m_corner);
      m_items[i].Anchor(m_anchor);
      m_items[i].Selectable(false);
      m_items[i].Z_Order(m_zorder);
      m_items[i].ReadOnly(true);
      m_items[i].Tooltip("\n");
      //--- Coordinates
      m_items[i].X(x);
      m_items[i].Y(y);
      //--- Sizes
      m_items[i].XSize(m_width[i]);
      m_items[i].YSize(m_y_size-2);
      //--- Margins from the edge of the panel
      m_items[i].XGap(CElement::CalculateXGap(x));
      m_items[i].YGap(CElement::CalculateYGap(y));
      //--- Store the object pointer
      CElementBase::AddToArray(m_items[i]);
     }
//--- Creating separation lines
   for(int i=1; i<items_total; i++)
      CreateSeparateLine(i);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a separation line                                        |
//+------------------------------------------------------------------+
bool CStatusBar::CreateSeparateLine(const int line_index)
  {
//--- Lines are set starting from the second (1) item
   if(line_index<1)
      return(false);
//--- Coordinates
   int x =CElement::CalculateXGap(m_items[line_index].X());
   int y =CElement::CalculateYGap(CElementBase::Y()+3);
//--- Adjustment of the index
   int i=line_index-1;
//--- Increasing the array of lines per element
   int array_size=::ArraySize(m_sep_line);
   ::ArrayResize(m_sep_line,array_size+1);
//--- Store the window pointer
   m_sep_line[i].WindowPointer(m_wnd);
//--- Setting up properties
   m_sep_line[i].TypeSepLine(V_SEP_LINE);
   m_sep_line[i].DarkColor(m_sepline_dark_color);
   m_sep_line[i].LightColor(m_sepline_light_color);
   m_sep_line[i].AnchorRightWindowSide(m_anchor_right_window_side);
   m_sep_line[i].AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating a line
   if(!m_sep_line[i].CreateSeparateLine(m_chart_id,m_subwin,line_index,x,y,2,m_y_size-6))
      return(false);
//--- Store the object pointer
   CElementBase::AddToArray(m_sep_line[i].Object(0));
   return(true);
  }
//+------------------------------------------------------------------+
//| Adds a menu item                                                 |
//+------------------------------------------------------------------+
void CStatusBar::AddItem(const int width)
  {
//--- Increase the array size by one element
   int array_size=::ArraySize(m_items);
   ::ArrayResize(m_items,array_size+1);
   ::ArrayResize(m_width,array_size+1);
//--- Store the values of passed parameters
   m_width[array_size]=width;
  }
//+------------------------------------------------------------------+
//| Setting the value by the specified index                         |
//+------------------------------------------------------------------+
void CStatusBar::ValueToItem(const uint index,const string value)
  {
//--- Checking for exceeding the array range
   uint array_size=::ArraySize(m_items);
   if(array_size<1)
      return;
//--- Adjust the index value if the array range is exceeded
   uint correct_index=(index>=array_size)? array_size-1 : index;
//--- Setting the passed text
   m_items[correct_index].Description(value);
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CStatusBar::Moving(const int x,const int y,const bool moving_mode=false)
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
//--- Storing coordinates in the fields of the objects
   m_area.X((m_anchor_right_window_side)? m_wnd.X2()-m_area.XGap() : x+m_area.XGap());
   m_area.Y((m_anchor_bottom_window_side)? m_wnd.Y2()-m_area.YGap() : y+m_area.YGap());
//--- Updating coordinates of graphical objects
   m_area.X_Distance(m_area.X());
   m_area.Y_Distance(m_area.Y());
//---
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      //--- Storing coordinates in the fields of the objects
      m_items[i].X((m_anchor_right_window_side)? m_wnd.X2()-m_items[i].XGap() : x+m_items[i].XGap());
      m_items[i].Y((m_anchor_bottom_window_side)? m_wnd.Y2()-m_items[i].YGap() : y+m_items[i].YGap());
      //--- Updating coordinates of graphical objects
      m_items[i].X_Distance(m_items[i].X());
      m_items[i].Y_Distance(m_items[i].Y());
     }
//--- Moving separation lines
   int sep_total=::ArraySize(m_sep_line);
   for(int i=0; i<sep_total; i++)
      m_sep_line[i].Moving(x,y,true);
  }
//+------------------------------------------------------------------+
//| Shows the element                                                |
//+------------------------------------------------------------------+
void CStatusBar::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElementBase::IsVisible())
      return;
//--- Make all the objects visible
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_ALL_PERIODS);
//--- Show the separation line
   int sep_total=::ArraySize(m_sep_line);
   for(int i=0; i<sep_total; i++)
      m_sep_line[i].Show();
//--- Visible state
   CElementBase::IsVisible(true);
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
//| Hides the element                                                |
//+------------------------------------------------------------------+
void CStatusBar::Hide(void)
  {
//--- Leave, if the control is hidden
   if(!CElementBase::IsVisible())
      return;
//--- Hide all objects
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_NO_PERIODS);
//--- Hide the separation line
   int sep_total=::ArraySize(m_sep_line);
   for(int i=0; i<sep_total; i++)
      m_sep_line[i].Hide();
//--- Visible state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CStatusBar::Reset(void)
  {
//--- Leave, if this is a drop-down control 
   if(CElementBase::IsDropdown())
      return;
//--- Hide and show
   Hide();
   Show();
  }
//+------------------------------------------------------------------+
//| Remove                                                         |
//+------------------------------------------------------------------+
void CStatusBar::Delete(void)
  {
//--- Removing objects
   m_area.Delete();
//--- Emptying the control arrays
   ::ArrayFree(m_items);
   ::ArrayFree(m_sep_line);
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
//--- Initializing of variables by default values
   CElementBase::MouseFocus(false);
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Seth the priorities                                              |
//+------------------------------------------------------------------+
void CStatusBar::SetZorders(void)
  {
   m_area.Z_Order(m_zorder);
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
      m_items[i].Z_Order(m_zorder);
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CStatusBar::ResetZorders(void)
  {
   m_area.Z_Order(0);
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
      m_items[i].Z_Order(0);
  }
//+------------------------------------------------------------------+
//| Calculating the width of control                                 |
//+------------------------------------------------------------------+
int CStatusBar::CalculationXSize(void)
  {
   return((m_x_size<1 || m_auto_xresize_mode)? m_wnd.X2()-m_x-m_auto_xresize_right_offset : m_x_size);
  }
//+------------------------------------------------------------------+
//| Calculating the width of the first item                          |
//+------------------------------------------------------------------+
int CStatusBar::CalculationFirstItemXSize(void)
  {
   int width=0;
//--- Get the number of items
   int items_total=ItemsTotal();
   if(items_total<1)
      return(0);
//--- Calculate the width relative to the total width of the other items
   for(int i=1; i<items_total; i++)
      width+=m_width[i];
//---
   return(m_x_size-width-items_total);
  }
//+------------------------------------------------------------------+
//| Calculation of the X coordinate of the item                      |
//+------------------------------------------------------------------+
int CStatusBar::CalculationItemX(const int item_index=0)
  {
   return((item_index>0)? m_items[item_index-1].X2()-1 : CElementBase::X()+1);
  }
//+------------------------------------------------------------------+
//| Change the width at the right edge of the form                   |
//+------------------------------------------------------------------+
void CStatusBar::ChangeWidthByRightWindowSide(void)
  {
//--- Coordinates and width
   int x=m_area.X();
//--- Calculate and set the new total size
   int x_size=CalculationXSize();
   m_area.XSize(x_size);
   m_area.X_Size(x_size);
   CElementBase::XSize(x_size);
//--- Calculate and set the new size of the first item
   m_width[0]=CalculationFirstItemXSize();
   m_items[0].XSize(m_width[0]);
   m_items[0].X_Size(m_width[0]);
//--- Get the number of items
   int items_total=ItemsTotal();
//--- Set the coordinate and offset for all items except the first
   for(int i=1; i<items_total; i++)
     {
      x=x+m_width[i-1]+1;
      m_items[i].X(x);
      m_items[i].XGap(x-m_wnd.X());
     }
//--- Set the coordinate and offset for the separation lines
   for(int i=1; i<items_total; i++)
     {
      x=m_items[i].X();
      ((CRectCanvas *)m_sep_line[i-1].Object(0)).X(x);
      ((CRectCanvas *)m_sep_line[i-1].Object(0)).XGap(x-m_wnd.X());
     }
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
