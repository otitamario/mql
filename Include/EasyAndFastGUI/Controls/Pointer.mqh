//+------------------------------------------------------------------+
//|                                                      Pointer.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
//--- Resources
#resource "\\Images\\EasyAndFastGUI\\Controls\\pointer_x_rs.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\pointer_x_rs_blue.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\pointer_y_rs.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\pointer_y_rs_blue.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\pointer_xy1_rs.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\pointer_xy1_rs_blue.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\pointer_xy2_rs.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\pointer_xy2_rs_blue.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\pointer_x_rs_rel.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\pointer_y_rs_rel.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\pointer_x_scroll.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\pointer_x_scroll_blue.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\pointer_y_scroll.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\pointer_y_scroll_blue.bmp"
#resource "\\Images\\EasyAndFastGUI\\Controls\\pointer_text_select.bmp"
//+------------------------------------------------------------------+
//| Class for creating the mouse cursor                              |
//+------------------------------------------------------------------+
class CPointer : public CElement
  {
private:
   //--- Object for creating the control
   CBmpLabel         m_pointer_bmp;
   //--- Icons for cursor
   string            m_file_on;
   string            m_file_off;
   //--- Cursor type
   ENUM_MOUSE_POINTER m_type;
   //---
public:
                     CPointer(void);
                    ~CPointer(void);
   //--- Create cursor icon
   bool              CreatePointer(const long chart_id,const int subwin);
   //--- Set icons for cursor
   void              FileOn(const string file_path)       { m_file_on=file_path;           }
   void              FileOff(const string file_path)      { m_file_off=file_path;          }
   //--- Get and set the cursor type
   ENUM_MOUSE_POINTER Type(void)                    const { return(m_type);                }
   void              Type(ENUM_MOUSE_POINTER type)        { m_type=type;                   }
   //--- Get and set the cursor state
   bool              State(void)                    const { return(m_pointer_bmp.State()); }
   void              State(const bool state)              { m_pointer_bmp.State(state);    }
   //--- Update coordinates
   void              UpdateX(const int mouse_x)           { m_pointer_bmp.X_Distance(mouse_x-CElementBase::XGap()); }
   void              UpdateY(const int mouse_y)           { m_pointer_bmp.Y_Distance(mouse_y-CElementBase::YGap()); }
   //---
public:
   //--- Moving the element
   virtual void      Moving(const int mouse_x,const int mouse_y);
   //--- (1) Show, (2) hide, (3) reset, (4) delete
   virtual void      Show(void);
   virtual void      Hide(void);
   virtual void      Reset(void);
   virtual void      Delete(void);
   //---
private:
   //--- Set images for the mouse cursor
   void              SetPointerBmp(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CPointer::CPointer(void) : m_file_on(""),
                           m_file_off(""),
                           m_type(MP_X_RESIZE)
  {
   //--- Default index of the control
   CElement::Index(0);
//--- Visible state
   CElement::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CPointer::~CPointer(void)
  {
  }
//+------------------------------------------------------------------+
//| Create cursor                                                    |
//+------------------------------------------------------------------+
bool CPointer::CreatePointer(const long chart_id,const int subwin)
  {
//--- Formation of the window name
   string name=CElement::ProgramName()+"_pointer_bmp_"+(string)CElement::Index()+"__"+(string)CElement::Id();
//--- Set images for cursor
   SetPointerBmp();
//--- Creating the object
   if(!m_pointer_bmp.Create(chart_id,name,subwin,0,0))
      return(false);
//--- Setting up properties
   m_pointer_bmp.BmpFileOn("::"+m_file_on);
   m_pointer_bmp.BmpFileOff("::"+m_file_off);
   m_pointer_bmp.Corner(m_corner);
   m_pointer_bmp.Selectable(false);
   m_pointer_bmp.Z_Order(0);
   m_pointer_bmp.Tooltip("\n");
//--- Hide the object
   m_pointer_bmp.Timeframes(OBJ_NO_PERIODS);
   return(true);
  }
//+------------------------------------------------------------------+
//| Moving the element                                               |
//+------------------------------------------------------------------+
void CPointer::Moving(const int mouse_x,const int mouse_y)
  {
   UpdateX(mouse_x);
   UpdateY(mouse_y);
  }
//+------------------------------------------------------------------+
//| Shows the element                                                |
//+------------------------------------------------------------------+
void CPointer::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElementBase::IsVisible())
      return;
//--- Make all the objects visible  
   m_pointer_bmp.Timeframes(OBJ_ALL_PERIODS);
//--- Visible state
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Hides the element                                                |
//+------------------------------------------------------------------+
void CPointer::Hide(void)
  {
//--- Leave, if the control is hidden
   if(!CElementBase::IsVisible())
      return;
//--- Hide the objects
   m_pointer_bmp.Timeframes(OBJ_NO_PERIODS);
//--- Visible state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CPointer::Reset(void)
  {
//--- Hide and show
   Hide();
   Show();
  }
//+------------------------------------------------------------------+
//| Remove                                                         |
//+------------------------------------------------------------------+
void CPointer::Delete(void)
  {
   m_pointer_bmp.Delete();
  }
//+------------------------------------------------------------------+
//| Set the cursor images based on cursor type                       |
//+------------------------------------------------------------------+
void CPointer::SetPointerBmp(void)
  {
   switch(m_type)
     {
      case MP_X_RESIZE :
         m_file_on  ="Images\\EasyAndFastGUI\\Controls\\pointer_x_rs_blue.bmp";
         m_file_off ="Images\\EasyAndFastGUI\\Controls\\pointer_x_rs.bmp";
         break;
      case MP_Y_RESIZE :
         m_file_on  ="Images\\EasyAndFastGUI\\Controls\\pointer_y_rs_blue.bmp";
         m_file_off ="Images\\EasyAndFastGUI\\Controls\\pointer_y_rs.bmp";
         break;
      case MP_XY1_RESIZE :
         m_file_on  ="Images\\EasyAndFastGUI\\Controls\\pointer_xy1_rs_blue.bmp";
         m_file_off ="Images\\EasyAndFastGUI\\Controls\\pointer_xy1_rs.bmp";
         break;
      case MP_XY2_RESIZE :
         m_file_on  ="Images\\EasyAndFastGUI\\Controls\\pointer_xy2_rs_blue.bmp";
         m_file_off ="Images\\EasyAndFastGUI\\Controls\\pointer_xy2_rs.bmp";
         break;
      case MP_X_RESIZE_RELATIVE :
         m_file_on  ="Images\\EasyAndFastGUI\\Controls\\pointer_x_rs_rel.bmp";
         m_file_off ="Images\\EasyAndFastGUI\\Controls\\pointer_x_rs_rel.bmp";
         break;
      case MP_Y_RESIZE_RELATIVE :
         m_file_on  ="Images\\EasyAndFastGUI\\Controls\\pointer_y_rs_rel.bmp";
         m_file_off ="Images\\EasyAndFastGUI\\Controls\\pointer_y_rs_rel.bmp";
         break;
      case MP_X_SCROLL :
         m_file_on  ="Images\\EasyAndFastGUI\\Controls\\pointer_x_scroll_blue.bmp";
         m_file_off ="Images\\EasyAndFastGUI\\Controls\\pointer_x_scroll.bmp";
         break;
      case MP_Y_SCROLL :
         m_file_on  ="Images\\EasyAndFastGUI\\Controls\\pointer_y_scroll_blue.bmp";
         m_file_off ="Images\\EasyAndFastGUI\\Controls\\pointer_y_scroll.bmp";
         break;
      case MP_TEXT_SELECT :
         m_file_on  ="Images\\EasyAndFastGUI\\Controls\\pointer_text_select.bmp";
         m_file_off ="Images\\EasyAndFastGUI\\Controls\\pointer_text_select.bmp";
         break;
     }
//--- If custom type (MP_CUSTOM) is specified
   if(m_file_on=="" || m_file_off=="")
      ::Print(__FUNCTION__," > Both images must be set for the cursor!");
  }
//+------------------------------------------------------------------+
