//+------------------------------------------------------------------+
//|                                                   Auxiliares.mqh |
//|                        Copyright 2017,  Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Check for New Bar                                                |
//+------------------------------------------------------------------+
#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Label.mqh>
#include <Controls\ComboBox.mqh> 
#include <Controls\Edit.mqh>
#include <Controls\RadioGroup.mqh> 
#include <Controls\Picture.mqh>
#include <Controls\ListView.mqh>
#include <Controls\Rect.mqh>

//+------------------------------------------------------------------+ 
//| defines                                                          | 
//+------------------------------------------------------------------+ 
//--- indents and gaps 
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width) 
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width) 
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width) 
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width) 
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate 
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate 
//--- for buttons 
#define BUTTON_WIDTH                        (100)     // size by X coordinate 
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate 
//--- for the indication area 
#define EDIT_HEIGHT                         (20)      // size by Y coordinate 
//--- for group controls 
#define GROUP_WIDTH                         (150)     // size by X coordinate 
#define LIST_HEIGHT                         (179)     // size by Y coordinate 
#define RADIO_HEIGHT                        (56)      // size by Y coordinate 
#define CHECK_HEIGHT                        (93)      // size by Y coordinate //+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+ 
//| Class MyPanel                                            | 
//| Usage: main dialog of the Controls application                   | 
//+------------------------------------------------------------------+ 
class MyPanel : public CAppDialog
  {

public:
                     MyPanel(void);
                    ~MyPanel(void);
   //--- create 
   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   virtual void      OnTick(void);
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

protected:
   //--- create dependent controls 
   bool              CreateLabel(const long chart,const int subwindow,CLabel &object,const string text,const uint x1,const uint y1,const uint x2,const uint y2);
   bool              CreateEdit(const long chart,const int subwindow,CEdit &object,const uint x1,const uint y1,const uint x2,const uint y2);
   bool              CreateButton(const long chart,const int subwindow,CButton &object,const string text,const uint x1,const uint y1,const uint x2,const uint y2);
   bool              CreatePicture(const long chart,const int subwindow,CPicture &object,const uint x1,const uint y1,const uint x2,const uint y2,string path);
   bool              CreatePanel(const long chart,const int subwindow,CPanel &object,const uint x1,const uint y1,const uint x2,const uint y2);
   bool              CreateComboBox(const long chart,const string name,const int subwindow,CComboBox &object,const uint x1,const uint y1,const uint x2,const uint y2);
   bool              CreateListView(const long chart,const string name,const int subwindow,CListView &object,const uint x1,const uint y1,const uint x2,const uint y2);
   bool              CreateRadioGroup(const long chart,const string name,const int subwindow,CRadioGroup &object,const uint x1,const uint y1,const uint x2,const uint y2);

  };
//+------------------------------------------------------------------+ 
//| Constructor                                                      | 
//+------------------------------------------------------------------+ 
MyPanel::MyPanel(void)
  {
  }
//+------------------------------------------------------------------+ 
//| Destructor                                                       | 
//+------------------------------------------------------------------+ 
MyPanel::~MyPanel(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyPanel::CreateLabel(const long chart,const int subwindow,CLabel &object,const string text,const uint x1,const uint y1,const uint x2,const uint y2)
  {
// All objects mast to have separate name
   string name="Label"+(string)ObjectsTotal(chart,-1,OBJ_LABEL);
//--- Call Create function
   if(!object.Create(chart,name,subwindow,x1,y1,x2,y2))
     {
      return false;
     }
//--- Addjust text
   if(!object.Text(text))
     {
      return false;
     }
//--- Add object to controls
   if(!Add(object))
     {
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyPanel::CreateEdit(const long chart,const int subwindow,CEdit &object,const uint x1,const uint y1,const uint x2,const uint y2)
  {
// All objects mast to have separate name
   string name="Edit"+(string)ObjectsTotal(chart,-1,OBJ_EDIT);
//--- Call Create function
   if(!object.Create(chart,name,subwindow,x1,y1,x2,y2))
     {
      return false;
     }

   if(!object.ReadOnly(false))
      return(false);

   if(!object.TextAlign(ALIGN_CENTER))
      return(false);

//--- Add object to controls
   if(!Add(object))
     {
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyPanel::CreateButton(const long chart,const int subwindow,CButton &object,const string text,const uint x1,const uint y1,const uint x2,const uint y2)
  {

// All objects mast to have separate name
   string name="Button"+(string)ObjectsTotal(chart,-1,OBJ_BUTTON);

//--- create 

   if(!object.Create(chart,name,subwindow,x1,y1,x2,y2))
      return(false);
   if(!object.Text(text))
      return(false);
   if(!Add(object))
      return(false);
//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyPanel::CreatePicture(const long chart,const int subwindow,CPicture &object,const uint x1,const uint y1,const uint x2,const uint y2,string path)
  {
// All objects mast to have separate name
   string name="Picture"+(string)ObjectsTotal(chart,-1,OBJ_BITMAP_LABEL);

//--- create 

   if(!object.Create(chart,name,subwindow,x1,y1,x2,y2))
      return(false);
   object.BmpName(path);
   if(!Add(object))
      return(false);
//--- definimos o nome dos arquivos bmp para exibir os controles CPicture 

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+

bool MyPanel::CreatePanel(const long chart,const int subwindow,CPanel &object,const uint x1,const uint y1,const uint x2,const uint y2)
  {
// All objects mast to have separate name
   string name="Panel"+(string)ObjectsTotal(chart,-1,OBJ_RECTANGLE_LABEL);

//--- create 
   if(!object.Create(chart,name,subwindow,x1,y1,x2,y2))
      return(false);
//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
bool MyPanel::CreateComboBox(const long chart,const string name,const int subwindow,CComboBox &object,const uint x1,const uint y1,const uint x2,const uint y2)

  {

//--- create 
   if(!object.Create(chart,name,subwindow,x1,y1,x2,y2))
      return(false);
   if(!Add(object))
      return(false);
//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
bool MyPanel::CreateRadioGroup(const long chart,const string name,const int subwindow,CRadioGroup &object,const uint x1,const uint y1,const uint x2,const uint y2)
  {
//--- create 
   if(!object.Create(chart,name,subwindow,x1,y1,x2,y2))
      return(false);
   if(!Add(object))
      return(false);
//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyPanel::CreateListView(const long chart,const string name,const int subwindow,CListView &object,const uint x1,const uint y1,const uint x2,const uint y2)

  {
//--- coordinates 
   if(!object.Create(chart,name,subwindow,x1,y1,x2,y2))
      return(false);
   if(!Add(object))
      return(false);
//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
