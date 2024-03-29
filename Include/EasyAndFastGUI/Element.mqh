//+------------------------------------------------------------------+
//|                                                      Element.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "ElementBase.mqh"
#include "Controls\Window.mqh"
//+------------------------------------------------------------------+
//| Class for getting the mouse parameters                           |
//+------------------------------------------------------------------+
class CElement : public CElementBase
  {
protected:
   //--- Pointer to the form to which the element is attached
   CWindow          *m_wnd;
   //---
public:
                     CElement(void);
                    ~CElement(void);
   //--- Store pointer to the form
   void              WindowPointer(CWindow &object) { m_wnd=::GetPointer(object); }
   //---
protected:
   //--- Check if there is a form pointer
   bool              CheckWindowPointer(void);
   //--- Check the identifier of the activated control
   bool              CheckIdActivatedElement(void);
   //--- Check if the left mouse button is pressed on the form header
   bool              CheckPressedInsideHeader(void);
   
   //--- Calculation of absolute coordinates
   int               CalculateX(const int x_gap);
   int               CalculateY(const int y_gap);
   //--- Calculation of the relative coordinates from the edge of the form
   int               CalculateXGap(const int x);
   int               CalculateYGap(const int y);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CElement::CElement(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CElement::~CElement(void)
  {
  }
//+------------------------------------------------------------------+
//| Check if there is a form pointer                                 |
//+------------------------------------------------------------------+
bool CElement::CheckWindowPointer(void)
  {
//--- If there is no form pointer
   if(::CheckPointer(m_wnd)==POINTER_INVALID)
     {
      //--- Output the message to the terminal journal
      ::Print(__FUNCTION__+" > Before creating a control, it needs to be passed the form pointer: "+CElementBase::ClassName()+"::WindowPointer(CWindow &object)");
      //--- Terminate building the graphical interface of the application
      return(false);
     }
//--- Send the flag of pointer presence
   return(true);
  }
//+------------------------------------------------------------------+
//| Check the identifier of the activated control                    |
//+------------------------------------------------------------------+
bool CElement::CheckIdActivatedElement(void)
  {
   return(m_wnd.IdActivatedElement()==CElementBase::Id());
  }
//+------------------------------------------------------------------+
//| Check if the left mouse button is pressed on the form header     |
//+------------------------------------------------------------------+
bool CElement::CheckPressedInsideHeader(void)
  {
   return(m_wnd.ClampingAreaMouse()==PRESSED_INSIDE_HEADER);
  }
//+------------------------------------------------------------------+
//| Calculate the absolute X coordinate                              |
//+------------------------------------------------------------------+
int CElement::CalculateX(const int x_gap)
  {
   return((CElementBase::AnchorRightWindowSide())? m_wnd.X2()-x_gap : m_wnd.X()+x_gap);
  }
//+------------------------------------------------------------------+
//| Calculate the absolute Y coordinate                              |
//+------------------------------------------------------------------+
int CElement::CalculateY(const int y_gap)
  {
   return((CElementBase::AnchorBottomWindowSide())? m_wnd.Y2()-y_gap : m_wnd.Y()+y_gap);
  }
//+------------------------------------------------------------------+
//| Calculate the relative X coordinate from the edge of the form    |
//+------------------------------------------------------------------+
int CElement::CalculateXGap(const int x)
  {
   return((CElementBase::AnchorRightWindowSide())? m_wnd.X2()-x : x-m_wnd.X());
  }
//+------------------------------------------------------------------+
//| Calculate the relative Y coordinate from the edge of the form    |
//+------------------------------------------------------------------+
int CElement::CalculateYGap(const int y)
  {
   return((CElementBase::AnchorBottomWindowSide())? m_wnd.Y2()-y : y-m_wnd.Y());
  }
//+------------------------------------------------------------------+
