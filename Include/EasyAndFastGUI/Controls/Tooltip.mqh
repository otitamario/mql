//+------------------------------------------------------------------+
//|                                                      Tooltip.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
//+------------------------------------------------------------------+
//| Class for creating the tooltip                                   |
//+------------------------------------------------------------------+
class CTooltip : public CElement
  {
private:
   //--- Pointer to the element to which the tooltip is attached
   CElement         *m_element;
   //--- Object for creating the tooltip
   CRectCanvas       m_canvas;
   //--- Properties:
   //    Header
   string            m_header;
   //--- Array of lines of the tooltip text
   string            m_tooltip_lines[];
   //--- Value of the alpha channel (transparency of the tooltip)
   uchar             m_alpha;
   //--- Colors of (1) text, (2) the header and (3) the background frame
   color             m_text_color;
   color             m_header_color;
   color             m_border_color;
   //--- Gradient color of the background
   color             m_gradient_top_color;
   color             m_gradient_bottom_color;
   //--- Array of background gradient
   color             m_array_color[];
   //---
public:
                     CTooltip(void);
                    ~CTooltip(void);
   //--- Method for creating the tooltip
   bool              CreateTooltip(const long chart_id,const int subwin);
   //---
private:
   //--- Creates the canvas for the tooltip
   bool              CreateCanvas(void);
   //--- (1) Draw the vertical gradient and (2) the frame
   void              VerticalGradient(const uchar alpha);
   void              Border(const uchar alpha);
   //---
public:
   //--- (1) Stores the control pointer, (2) the tooltip header
   void              ElementPointer(CElement &object) { m_element=::GetPointer(object); }
   void              Header(const string text)        { m_header=text;                  }
   //--- Adds the line for the tooltip
   void              AddString(const string text);

   //--- (1) Shows and (2) hides the toopltip
   void              ShowTooltip(void);
   void              FadeOutTooltip(void);
   //---
public:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
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
CTooltip::CTooltip(void) : m_header(""),
                           m_alpha(0),
                           m_text_color(clrDimGray),
                           m_header_color(C'50,50,50'),
                           m_border_color(C'118,118,118'),
                           m_gradient_top_color(clrWhite),
                           m_gradient_bottom_color(C'208,208,235')
  {
//--- Store the name of the element class in the base class  
   CElement::ClassName(CLASS_NAME);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTooltip::~CTooltip(void)
  {
  }
//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void CTooltip::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Handling of the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      //--- Leave, if the control is hidden
      if(!CElement::IsVisible())
         return;
      //--- Leave, if the tooltip button on the form is disabled
      if(!m_wnd.TooltipButtonState())
         return;
      //--- If the form is blocked
      if(m_wnd.IsLocked())
        {
         //--- Hide the tooltip
         FadeOutTooltip();
         return;
        }
      //--- If the focus is on the element
      if(m_element.MouseFocus())
         //--- Show the tooltip
         ShowTooltip();
      //--- If there is no focus
      else
      //--- Hide the tooltip
         FadeOutTooltip();
      //---
      return;
     }
  }
//+------------------------------------------------------------------+
//| Creates the Tooltip object                                       |
//+------------------------------------------------------------------+
bool CTooltip::CreateTooltip(const long chart_id,const int subwin)
  {
//--- Exit if there is no pointer to the form
   if(!CElement::CheckWindowPointer())
      return(false);
//--- Leave, if there is no element pointer
   if(::CheckPointer(m_element)==POINTER_INVALID)
     {
      ::Print(__FUNCTION__," > Before creating the tooltip, the class must be passed "
              "the element pointer: CTooltip::ElementPointer(CElement &object).");
      return(false);
     }
//--- Initializing variables
   m_id       =m_wnd.LastId()+1;
   m_chart_id =chart_id;
   m_subwin   =subwin;
   m_x        =m_element.X();
   m_y        =m_element.Y2()+1;
//--- Margins from the edge
   CElement::XGap(m_x-m_wnd.X());
   CElement::YGap(m_y-m_wnd.Y());
//--- Creates the tooltip
   if(!CreateCanvas())
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the canvas for drawing                                   |
//+------------------------------------------------------------------+
bool CTooltip::CreateCanvas(void)
  {
//--- Formation of the window name
   string name=CElement::ProgramName()+"_help_tooltip_"+(string)CElement::Id();
//--- Creates the tooltip
   if(!m_canvas.CreateBitmapLabel(m_chart_id,m_subwin,name,m_x,m_y,m_x_size,m_y_size,COLOR_FORMAT_ARGB_NORMALIZE))
      return(false);
//--- Attach to the chart
   if(!m_canvas.Attach(m_chart_id,name,m_subwin,1))
      return(false);
//--- Set properties
   m_canvas.Background(false);
   m_canvas.Tooltip("\n");
//--- Margins from the edge
   m_canvas.XGap(m_x-m_wnd.X());
   m_canvas.YGap(m_y-m_wnd.Y());
//--- Setting the array size of the tooltip background gradient
   CElement::GradientColorsTotal(m_y_size);
   ::ArrayResize(m_array_color,m_y_size);
//--- Initializing the array gradient
   CElement::InitColorArray(m_gradient_top_color,m_gradient_bottom_color,m_array_color);
//--- Clearing the canvas
   m_canvas.Erase(::ColorToARGB(clrNONE,0));
   m_canvas.Update();
   m_alpha=0;
//--- Store the object pointer
   CElement::AddToArray(m_canvas);
   return(true);
  }
//+------------------------------------------------------------------+
//| Adds a line                                                      |
//+------------------------------------------------------------------+
void CTooltip::AddString(const string text)
  {
//--- Increase the array size by one element
   int array_size=::ArraySize(m_tooltip_lines);
   ::ArrayResize(m_tooltip_lines,array_size+1);
//--- Store the values of passed parameters
   m_tooltip_lines[array_size]=text;
  }
//+------------------------------------------------------------------+
//| Vertical gradient                                                |
//+------------------------------------------------------------------+
void CTooltip::VerticalGradient(const uchar alpha)
  {
//--- X coordinates
   int x1=0;
   int x2=m_x_size;
//--- Draw the gradient
   for(int y=0; y<m_y_size; y++)
      m_canvas.Line(x1,y,x2,y,::ColorToARGB(m_array_color[y],alpha));
  }
//+------------------------------------------------------------------+
//| Frame                                                            |
//+------------------------------------------------------------------+
void CTooltip::Border(const uchar alpha)
  {
//--- Frame color
   color clr=m_border_color;
//--- Boundaries
   int x_size =m_canvas.X_Size()-1;
   int y_size =m_canvas.Y_Size()-1;
//--- Coordinates: top/right/bottom/left
   int x1[4]; x1[0]=0;      x1[1]=x_size; x1[2]=0;      x1[3]=0;
   int y1[4]; y1[0]=0;      y1[1]=0;      y1[2]=y_size; y1[3]=0;
   int x2[4]; x2[0]=x_size; x2[1]=x_size; x2[2]=x_size; x2[3]=0;
   int y2[4]; y2[0]=0;      y2[1]=y_size; y2[2]=y_size; y2[3]=y_size;
//--- Draw the frame by specified coordinates
   for(int i=0; i<4; i++)
      m_canvas.Line(x1[i],y1[i],x2[i],y2[i],::ColorToARGB(clr,alpha));
//--- Round the corners by one pixel
   clr=clrBlack;
   m_canvas.PixelSet(0,0,::ColorToARGB(clr,0));
   m_canvas.PixelSet(0,m_y_size-1,::ColorToARGB(clr,0));
   m_canvas.PixelSet(m_x_size-1,0,::ColorToARGB(clr,0));
   m_canvas.PixelSet(m_x_size-1,m_y_size-1,::ColorToARGB(clr,0));
//--- Adding pixels by specified coordinates
   clr=C'180,180,180';
   m_canvas.PixelSet(1,1,::ColorToARGB(clr,alpha));
   m_canvas.PixelSet(1,m_y_size-2,::ColorToARGB(clr,alpha));
   m_canvas.PixelSet(m_x_size-2,1,::ColorToARGB(clr,alpha));
   m_canvas.PixelSet(m_x_size-2,m_y_size-2,::ColorToARGB(clr,alpha));
  }
//+------------------------------------------------------------------+
//| Shows the tooltip                                                |
//+------------------------------------------------------------------+
void CTooltip::ShowTooltip(void)
  {
   if(m_wnd.ClampingAreaMouse()==PRESSED_INSIDE_HEADER)
     return;
//--- Leave, if the tooltip is 100% visible
   if(m_alpha>=255)
      return;
//--- Coordinates and margins for the header
   int  x        =5;
   int  y        =5;
   int  y_offset =15;
//--- Draw the gradient
   VerticalGradient(255);
//--- Draw the frame
   Border(255);
//--- Draw the header (if specified)
   if(m_header!="")
     {
      //--- Set font parameters
      m_canvas.FontSet(CElement::Font(),-CElement::FontSize()*10,FW_BLACK);
      //--- Draw the header text
      m_canvas.TextOut(x,y,m_header,::ColorToARGB(m_header_color),TA_LEFT|TA_TOP);
     }
//--- Coordinates for the main text of the tooltip (considering the presence of the header)
   x=(m_header!="")? 15 : 5;
   y=(m_header!="")? 25 : 5;
//--- Set font parameters
   m_canvas.FontSet(CElement::Font(),-CElement::FontSize()*10,FW_THIN);
//--- Draw the main text of the tooltip
   int lines_total=::ArraySize(m_tooltip_lines);
   for(int i=0; i<lines_total; i++)
     {
      m_canvas.TextOut(x,y,m_tooltip_lines[i],::ColorToARGB(m_text_color),TA_LEFT|TA_TOP);
      y=y+y_offset;
     }
//--- Update the canvas
   m_canvas.Update();
//--- Indication of a completely visible tooltip
   m_alpha=255;
  }
//+------------------------------------------------------------------+
//| Gradual fading of the tooltip                                    |
//+------------------------------------------------------------------+
void CTooltip::FadeOutTooltip(void)
  {
//--- Leave, if the tooltip is 100% hidden
   if(m_alpha<1)
      return;
//--- Margin for the header
   int y_offset=15;
//--- Transparency step
   uchar fadeout_step=7;
//--- Gradual fading of the tooltip
   for(uchar a=m_alpha; a>=0; a-=fadeout_step)
     {
      //--- If the next step makes it negative, stop the loop
      if(a-fadeout_step<0)
        {
         a=0;
         m_canvas.Erase(::ColorToARGB(clrNONE,0));
         m_canvas.Update();
         m_alpha=0;
         break;
        }
      //--- Coordinates for the header
      int x =5;
      int y =5;
      //--- Draw the gradient and the frame
      VerticalGradient(a);
      Border(a);
      //--- Draw the header (if specified)
      if(m_header!="")
        {
         //--- Set font parameters
         m_canvas.FontSet(CElement::Font(),-CElement::FontSize()*10,FW_BLACK);
         //--- Draw the header text
         m_canvas.TextOut(x,y,m_header,::ColorToARGB(m_header_color,a),TA_LEFT|TA_TOP);
        }
      //--- Coordinates for the main text of the tooltip (considering the presence of the header)
      x=(m_header!="")? 15 : 5;
      y=(m_header!="")? 25 : 5;
      //--- Set font parameters
      m_canvas.FontSet(CElement::Font(),-CElement::FontSize()*10,FW_THIN);
      //--- Draw the main text of the tooltip
      int lines_total=::ArraySize(m_tooltip_lines);
      for(int i=0; i<lines_total; i++)
        {
         m_canvas.TextOut(x,y,m_tooltip_lines[i],::ColorToARGB(m_text_color,a),TA_LEFT|TA_TOP);
         y=y+y_offset;
        }
      //--- Update the canvas
      m_canvas.Update();
     }
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CTooltip::Moving(const int x,const int y,const bool moving_mode=false)
  {
//--- Leave, if the control is hidden
   if(!CElement::IsVisible())
      return;
//--- If the management is delegated to the window, identify its location
   if(!moving_mode)
      if(m_wnd.ClampingAreaMouse()!=PRESSED_INSIDE_HEADER)
         return;
//--- Storing coordinates in the element fields
   CElement::X(x+CElement::XGap());
   CElement::Y(y+CElement::YGap());
//--- Storing coordinates in the fields of the objects
   m_canvas.X(x+m_canvas.XGap());
   m_canvas.Y(y+m_canvas.YGap());
//--- Updating coordinates of graphical objects
   m_canvas.X_Distance(m_canvas.X());
   m_canvas.Y_Distance(m_canvas.Y());
  }
//+------------------------------------------------------------------+
//| Shows the element                                                |
//+------------------------------------------------------------------+
void CTooltip::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElement::IsVisible())
      return;
//--- Make all the objects visible
   m_canvas.Timeframes(OBJ_ALL_PERIODS);
//--- Visible state
   CElement::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Hides the element                                                |
//+------------------------------------------------------------------+
void CTooltip::Hide(void)
  {
//--- Leave, if the control is hidden
   if(!CElement::IsVisible())
      return;
//--- Hide all objects
   m_canvas.Timeframes(OBJ_NO_PERIODS);
//--- Visible state
   CElement::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CTooltip::Reset(void)
  {
   Hide();
   Show();
  }
//+------------------------------------------------------------------+
//| Remove                                                         |
//+------------------------------------------------------------------+
void CTooltip::Delete(void)
  {
//--- Removing objects
   m_canvas.Delete();
//--- Emptying the control arrays
   ::ArrayFree(m_tooltip_lines);
//--- Emptying the array of the objects
   CElement::FreeObjectsArray();
  }
//+------------------------------------------------------------------+
