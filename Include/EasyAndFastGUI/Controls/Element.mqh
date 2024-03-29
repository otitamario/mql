//+------------------------------------------------------------------+
//|                                                      Element.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Mouse.mqh"
#include "Objects.mqh"
//+------------------------------------------------------------------+
//| Base class of control                                            |
//+------------------------------------------------------------------+
class CElement
  {
protected:
   //--- Class instance for working with the color
   CColors           m_clr;
   //--- Class instance for getting the mouse parameters
   CMouse           *m_mouse;
   //--- Common array of pointers to all objects in this control
   CChartObject     *m_objects[];

   //--- (1) Name of class and (2) program, (3) program type
   string            m_class_name;
   string            m_program_name;
   ENUM_PROGRAM_TYPE m_program_type;
   //--- Identifier and window number of the chart
   long              m_chart_id;
   int               m_subwin;
   //--- Identifier and index of the element
   int               m_id;
   int               m_index;
   //--- Coordinates and boundaries
   int               m_x;
   int               m_y;
   int               m_x2;
   int               m_y2;
   //--- Size
   int               m_x_size;
   int               m_y_size;
   //--- Indents
   int               m_x_gap;
   int               m_y_gap;
   //--- Control states
   bool              m_is_visible;
   bool              m_is_dropdown;
   //--- Focus
   bool              m_mouse_focus;
   //--- Chart corner and anchor point of objects
   ENUM_BASE_CORNER  m_corner;
   ENUM_ANCHOR_POINT m_anchor;
   //--- Number of colors in the gradient
   int               m_gradient_colors_total;
   //--- Mode of automatic control resizing
   bool              m_auto_xresize_mode;
   bool              m_auto_yresize_mode;
   //--- Offset from the right/bottom edge of the form in the mode of automatic control width/height changing
   int               m_auto_xresize_right_offset;
   int               m_auto_yresize_bottom_offset;
   //--- Anchor points of the control in the right and bottom of the window
   bool              m_anchor_right_window_side;
   bool              m_anchor_bottom_window_side;
   //---
public:
                     CElement(void);
                    ~CElement(void);
   //--- (1) Stores and (2) returns the mouse pointer
   void              MousePointer(CMouse &object)                    { m_mouse=::GetPointer(object);         }
   CMouse           *MousePointer(void)                        const { return(::GetPointer(m_mouse));        }
   //--- (1) Get and set the class name
   string            ClassName(void)                           const { return(m_class_name);                 }
   void              ClassName(const string class_name)              { m_class_name=class_name;              }
   //--- (1) Getting the program name, (2) getting the program type, (3) setting the number of the chart window
   string            ProgramName(void)                         const { return(m_program_name);               }
   ENUM_PROGRAM_TYPE ProgramType(void)                         const { return(m_program_type);               }
   void              SubwindowNumber(const int number)               { m_subwin=number;                      }
   //--- Getting the object pointer by the specified index
   CChartObject     *Object(const int index);
   //--- (1) Getting the number of the control objects, (2) emptying the object array
   int               ObjectsElementTotal(void)                 const { return(::ArraySize(m_objects));       }
   void              FreeObjectsArray(void)                          { ::ArrayFree(m_objects);               }
   //--- Setting and getting the element identifier
   void              Id(const int id)                                { m_id=id;                              }
   int               Id(void)                                  const { return(m_id);                         }
   //--- Setting and getting the element index
   void              Index(const int index)                          { m_index=index;                        }
   int               Index(void)                               const { return(m_index);                      }
   //--- Coordinates and boundaries
   int               X(void)                                   const { return(m_x);                          }
   void              X(const int x)                                  { m_x=x;                                }
   int               Y(void)                                   const { return(m_y);                          }
   void              Y(const int y)                                  { m_y=y;                                }
   int               X2(void)                                  const { return(m_x+m_x_size);                 }
   int               Y2(void)                                  const { return(m_y+m_y_size);                 }
   //--- Size
   int               XSize(void)                               const { return(m_x_size);                     }
   void              XSize(const int x_size)                         { m_x_size=x_size;                      }
   int               YSize(void)                               const { return(m_y_size);                     }
   void              YSize(const int y_size)                         { m_y_size=y_size;                      }
   //--- Margins from the edge point (xy)
   int               XGap(void)                                const { return(m_x_gap);                      }
   void              XGap(const int x_gap)                           { m_x_gap=x_gap;                        }
   int               YGap(void)                                const { return(m_y_gap);                      }
   void              YGap(const int y_gap)                           { m_y_gap=y_gap;                        }
   //--- Visibility state of control
   void              IsVisible(const bool flag)                      { m_is_visible=flag;                    }
   bool              IsVisible(void)                           const { return(m_is_visible);                 }
   //--- Indication of a drop-down control
   void              IsDropdown(const bool flag)                     { m_is_dropdown=flag;                   }
   bool              IsDropdown(void)                          const { return(m_is_dropdown);                }
   //--- (1) Focus, (2) setting the gradient size
   bool              MouseFocus(void)                          const { return(m_mouse_focus);                }
   void              MouseFocus(const bool focus)                    { m_mouse_focus=focus;                  }
   void              GradientColorsTotal(const int total)            { m_gradient_colors_total=total;        }
   //--- (1) Mode of auto-changing the control width, (2) get/set the offset from the right edge of the form
   bool              AutoXResizeMode(void)                     const { return(m_auto_xresize_mode);          }
   void              AutoXResizeMode(const bool flag)                { m_auto_xresize_mode=flag;             }
   int               AutoXResizeRightOffset(void)              const { return(m_auto_xresize_right_offset);  }
   void              AutoXResizeRightOffset(const int offset)        { m_auto_xresize_right_offset=offset;   }
   //--- (1) Mode of auto-changing the control height, (2) gets/sets the offset from the bottom edge of the form
   bool              AutoYResizeMode(void)                     const { return(m_auto_yresize_mode);          }
   void              AutoYResizeMode(const bool flag)                { m_auto_yresize_mode=flag;             }
   int               AutoYResizeBottomOffset(void)             const { return(m_auto_yresize_bottom_offset); }
   void              AutoYResizeBottomOffset(const int offset)       { m_auto_yresize_bottom_offset=offset;  }
   //--- Mode (getting/setting) of control anchor point to the (1) right and (2) bottom edge of the window
   bool              AnchorRightWindowSide(void)               const { return(m_anchor_right_window_side);   }
   void              AnchorRightWindowSide(const bool flag)          { m_anchor_right_window_side=flag;      }
   bool              AnchorBottomWindowSide(void)              const { return(m_anchor_bottom_window_side);  }
   void              AnchorBottomWindowSide(const bool flag)         { m_anchor_bottom_window_side=flag;     }
   //---
public:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam) {}
   //--- Timer
   virtual void      OnEventTimer(void) {}
   //--- Moving the element
   virtual void      Moving(const int x,const int y) {}
   //--- (1) Show, (2) hide, (3) reset, (4) delete
   virtual void      Show(void) {}
   virtual void      Hide(void) {}
   virtual void      Reset(void) {}
   virtual void      Delete(void) {}
   //--- (1) Setting, (2) resetting of priorities for left clicking on mouse
   virtual void      SetZorders(void) {}
   virtual void      ResetZorders(void) {}
   //--- Zeroing the element color
   virtual void      ResetColors(void) {}
   //--- Change the width at the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void) {}
   //--- Change the height at the bottom edge of the window
   virtual void      ChangeHeightByBottomWindowSide(void) {}
   //---
protected:
   //--- Check if there is a form pointer
   bool              CheckWindowPointer(ENUM_POINTER_TYPE pointer_type);
   //--- Method to add pointers of primitive objects to the common array
   void              AddToArray(CChartObject &object);
   //--- Initializing the array gradient
   void              InitColorArray(const color outer_color,const color hover_color,color &color_array[]);
   //--- Changing the object color
   void              ChangeObjectColor(const string name,const bool mouse_focus,const ENUM_OBJECT_PROPERTY_INTEGER property,
                                       const color outer_color,const color hover_color,const color &color_array[]);

   //--- Getting the identifier from the button name
   int               IdFromObjectName(const string object_name);
   //--- Getting the index from the menu item name
   int               IndexFromObjectName(const string object_name);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CElement::CElement(void) : m_x(0),
                           m_y(0),
                           m_x2(0),
                           m_y2(0),
                           m_x_size(0),
                           m_y_size(0),
                           m_x_gap(0),
                           m_y_gap(0),
                           m_is_visible(true),
                           m_is_dropdown(false),
                           m_mouse_focus(false),
                           m_id(WRONG_VALUE),
                           m_index(WRONG_VALUE),
                           m_gradient_colors_total(3),
                           m_corner(CORNER_LEFT_UPPER),
                           m_anchor(ANCHOR_LEFT_UPPER),
                           m_program_name(PROGRAM_NAME),
                           m_program_type(PROGRAM_TYPE),
                           m_class_name(""),
                           m_auto_xresize_mode(false),
                           m_auto_yresize_mode(false),
                           m_auto_xresize_right_offset(0),
                           m_auto_yresize_bottom_offset(0),
                           m_anchor_right_window_side(false),
                           m_anchor_bottom_window_side(false)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CElement::~CElement(void)
  {
  }
//+------------------------------------------------------------------+
//| Returns the element object pointer by the index                  |
//+------------------------------------------------------------------+
CChartObject *CElement::Object(const int index)
  {
   int array_size=::ArraySize(m_objects);
//--- Verifying the size of the object array
   if(array_size<1)
     {
      ::Print(__FUNCTION__," > No ("+m_class_name+") objects in this control!");
      return(NULL);
     }
//--- Adjustment in case the range has been exceeded
   int i=(index>=array_size)? array_size-1 :(index<0)? 0 : index;
//--- Return the object pointer
   return(m_objects[i]);
  }
//+------------------------------------------------------------------+
//| Check if there is a form pointer                                 |
//+------------------------------------------------------------------+
bool CElement::CheckWindowPointer(ENUM_POINTER_TYPE pointer_type)
  {
//--- If there is no form pointer
   if(pointer_type==POINTER_INVALID)
     {
      //--- Generate a message
      string message=__FUNCTION__+" > Before creating a control, it needs to be passed the form pointer: "+ClassName()+"::WindowPointer(CWindow &object)";
      //--- Output the message to the terminal journal
      ::Print(message);
      //--- Terminate building the graphical interface of the application
      return(false);
     }
//--- Send the flag of pointer presence
   return(true);
  }
//+------------------------------------------------------------------+
//| Adds object pointer to an array                                  |
//+------------------------------------------------------------------+
void CElement::AddToArray(CChartObject &object)
  {
   int size=ObjectsElementTotal();
   ::ArrayResize(m_objects,size+1);
   m_objects[size]=::GetPointer(object);
  }
//+------------------------------------------------------------------+
//| Initialization of the gradient array                             |
//+------------------------------------------------------------------+
void CElement::InitColorArray(const color outer_color,const color hover_color,color &color_array[])
  {
//--- Array of the gradient colors
   color colors[2];
   colors[0]=outer_color;
   colors[1]=hover_color;
//--- Forming the color array
   m_clr.Gradient(colors,color_array,m_gradient_colors_total);
  }
//+------------------------------------------------------------------+
//| Changing the object color when the cursor is hovering over it    |
//+------------------------------------------------------------------+
void CElement::ChangeObjectColor(const string name,const bool mouse_focus,const ENUM_OBJECT_PROPERTY_INTEGER property,
                                 const color outer_color,const color hover_color,const color &color_array[])
  {
   if(::ArraySize(color_array)<1)
      return;
//--- Get the current object color
   color current_color=(color)::ObjectGetInteger(m_chart_id,name,property);
//--- If the cursor is over the object
   if(mouse_focus)
     {
      //--- Leave, if the specified color has been reached
      if(current_color==hover_color)
         return;
      //--- Move from the first to the last one
      for(int i=0; i<m_gradient_colors_total; i++)
        {
         //--- If colors do not match, move to the following
         if(color_array[i]!=current_color)
            continue;
         //---
         color new_color=(i+1==m_gradient_colors_total)? color_array[i]: color_array[i+1];
         //--- Change color
         ::ObjectSetInteger(m_chart_id,name,property,new_color);
         break;
        }
     }
//--- If the cursor is not in the object area
   else
     {
      //--- Leave, if the specified color has been reached
      if(current_color==outer_color)
         return;
      //--- Move from the last to the first one
      for(int i=m_gradient_colors_total-1; i>=0; i--)
        {
         //--- If colors do not match, move to the following
         if(color_array[i]!=current_color)
            continue;
         //---
         color new_color=(i-1<0)? color_array[i]: color_array[i-1];
         //--- Change color
         ::ObjectSetInteger(m_chart_id,name,property,new_color);
         break;
        }
     }
  }
//+------------------------------------------------------------------+
//| Extract the identifier from the object name                      |
//+------------------------------------------------------------------+
int CElement::IdFromObjectName(const string object_name)
  {
//--- Get the id from the object name
   int    length =::StringLen(object_name);
   int    pos    =::StringFind(object_name,"__",0);
   string id     =::StringSubstr(object_name,pos+2,length-1);
//--- Return the item id
   return((int)id);
  }
//+------------------------------------------------------------------+
//| Extracts the index from the object name                          |
//+------------------------------------------------------------------+
int CElement::IndexFromObjectName(const string object_name)
  {
   ushort u_sep=0;
   string result[];
   int    array_size=0;
//--- Get the code of the separator
   u_sep=::StringGetCharacter("_",0);
//--- Split the string
   ::StringSplit(object_name,u_sep,result);
   array_size=::ArraySize(result)-1;
//--- Checking for exceeding the array range
   if(array_size-2<0)
     {
      ::Print(PREVENTING_OUT_OF_RANGE);
      return(WRONG_VALUE);
     }
//--- Return the item index
   return((int)result[array_size-2]);
  }
//+------------------------------------------------------------------+
