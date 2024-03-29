//+------------------------------------------------------------------+
//|                                                  ContextMenu.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "MenuItem.mqh"
#include "SeparateLine.mqh"
//+------------------------------------------------------------------+
//| Class for creating a context menu                                |
//+------------------------------------------------------------------+
class CContextMenu : public CElement
  {
private:
   //--- Objects for creating a menu item
   CRectLabel        m_area;
   CMenuItem         m_items[];
   CSeparateLine     m_sep_line[];
   //--- Pointer to the previous node
   CMenuItem        *m_prev_node;
   //--- Background properties
   int               m_area_zorder;
   color             m_area_color;
   color             m_area_border_color;
   color             m_area_color_hover;
   color             m_area_color_array[];
   //--- Menu item properties
   int               m_item_y_size;
   color             m_item_back_color;
   color             m_item_back_color_hover;
   color             m_item_back_color_hover_off;
   color             m_item_border_color;
   color             m_label_color;
   color             m_label_color_hover;
   string            m_right_arrow_file_on;
   string            m_right_arrow_file_off;
   //--- Separation line properties
   color             m_sepline_dark_color;
   color             m_sepline_light_color;
   //--- Arrays of the menu item properties:
   //    (1) Text, (2) label of the available item, (3) label of the blocked item
   string            m_label_text[];
   string            m_path_bmp_on[];
   string            m_path_bmp_off[];
   //--- Array of index numbers of menu items after which a separation line is to be set
   int               m_sep_line_index[];
   //--- State of the context menu
   bool              m_context_menu_state;
   //--- Attachment side of the context menu
   ENUM_FIX_CONTEXT_MENU m_fix_side;
   //--- The detached context menu mode. This means that there is no attachment to the previous node.
   bool              m_free_context_menu;
   //---
public:
                     CContextMenu(void);
                    ~CContextMenu(void);
   //--- Methods for creating a context menu
   bool              CreateContextMenu(const long chart_id,const int window,const int x_gap=0,const int y_gap=0);
   //---
private:
   bool              CreateArea(void);
   bool              CreateItems(void);
   bool              CreateSeparateLine(const int item_index,const int line_index);
   //---
public:
   //--- (1) Get and (2) store the pointer of the previous node, (3) set the free context menu mode
   CMenuItem        *PrevNodePointer(void)                    const { return(m_prev_node);                  }
   void              PrevNodePointer(CMenuItem &object)             { m_prev_node=::GetPointer(object);     }
   void              FreeContextMenu(const bool flag)               { m_free_context_menu=flag;             }
   //--- Returns the item pointer from the context menu
   CMenuItem        *ItemPointerByIndex(const int index);

   //--- Methods for setting up the appearance of the context menu:
   //    Color of the context menu background
   void              AreaBackColor(const color clr)                 { m_area_color=clr;                     }
   void              AreaBorderColor(const color clr)               { m_area_border_color=clr;              }

   //--- (1) Number of menu items, (2) height, (3) background color and (4) color of the menu item frame 
   int               ItemsTotal(void)                         const { return(::ArraySize(m_items));         }
   void              ItemYSize(const int y_size)                    { m_item_y_size=y_size;                 }
   void              ItemBackColor(const color clr)                 { m_item_back_color=clr;                }
   void              ItemBorderColor(const color clr)               { m_item_border_color=clr;              }
   //--- Background color of (1) the available and (2) the blocked menu item when hovering the mouse cursor over it
   void              ItemBackColorHover(const color clr)            { m_item_back_color_hover=clr;          }
   void              ItemBackColorHoverOff(const color clr)         { m_item_back_color_hover_off=clr;      }
   //--- (1) Standard and (2) in-focus text color 
   void              LabelColor(const color clr)                    { m_label_color=clr;                    }
   void              LabelColorHover(const color clr)               { m_label_color_hover=clr;              }
   //--- Defining an icon for indicating the presence of a context menu in the item
   void              RightArrowFileOn(const string file_path)       { m_right_arrow_file_on=file_path;      }
   void              RightArrowFileOff(const string file_path)      { m_right_arrow_file_off=file_path;     }
   //--- (1) Dark and (2) light color of the separation line
   void              SeparateLineDarkColor(const color clr)         { m_sepline_dark_color=clr;             }
   void              SeparateLineLightColor(const color clr)        { m_sepline_light_color=clr;            }
   //--- (1) Getting and (2) setting the context menu state, (3) setting the context menu attachment mode
   bool              ContextMenuState(void)                   const { return(m_context_menu_state);         }
   void              ContextMenuState(const bool flag)              { m_context_menu_state=flag;            }
   void              FixSide(const ENUM_FIX_CONTEXT_MENU side)      { m_fix_side=side;                      }

   //--- Adds a menu item with specified properties before the creation of a context menu
   void              AddItem(const string text,const string path_bmp_on,const string path_bmp_off,const ENUM_TYPE_MENU_ITEM type);
   //--- Adds a separation line after the specified item before the creation of the context menu
   void              AddSeparateLine(const int item_index);
   //--- Returns description (displayed text)
   string            DescriptionByIndex(const uint index);
   //--- Returns a menu item type
   ENUM_TYPE_MENU_ITEM TypeMenuItemByIndex(const uint index);
   //--- (1) Getting and (2) setting the checkbox state
   bool              CheckBoxStateByIndex(const uint index);
   void              CheckBoxStateByIndex(const uint index,const bool state);
   //--- (1) Returns and (2) sets the id of the radio item by the index
   int               RadioItemIdByIndex(const uint index);
   void              RadioItemIdByIndex(const uint item_index,const int radio_id);
   //--- (1) Returns selected radio item, (2) switches the radio item
   int               SelectedRadioItem(const int radio_id);
   void              SelectedRadioItem(const int radio_index,const int radio_id);
   //--- Changes the color of menu items when the cursor is hovering over them
   void              ChangeObjectsColor(void);
   //---
public:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Timer
   virtual void      OnEventTimer(void);
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
   //--- Zero the color
   virtual void      ResetColors(void);
   //---
private:
   //--- Condition check for closing all context menus
   void              CheckHideContextMenus(void);
   //--- Condition check for closing all context menus which were open after this one
   void              CheckHideBackContextMenus(void);
   //--- Handling clicking on the item to which this context menu is attached
   bool              OnClickMenuItem(const string clicked_object);
   //--- Receiving the message from the menu item for handling
   void              ReceiveMessageFromMenuItem(const int id_item,const int index_item,const string message_item);
   //--- Getting (1) an identifier and (2) index from the radio item message
   int               RadioIdFromMessage(const string message);
   int               RadioIndexByItemIndex(const int index);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CContextMenu::CContextMenu(void) : m_context_menu_state(false),
                                   m_free_context_menu(false),
                                   m_fix_side(FIX_RIGHT),
                                   m_item_y_size(24),
                                   m_area_color(C'240,240,240'),
                                   m_area_color_hover(C'51,153,255'),
                                   m_area_border_color(clrSilver),
                                   m_item_back_color(clrNONE),
                                   m_item_back_color_hover(C'51,153,255'),
                                   m_item_back_color_hover_off(clrLightGray),
                                   m_item_border_color(clrNONE),
                                   m_label_color(clrBlack),
                                   m_label_color_hover(clrWhite),
                                   m_sepline_dark_color(C'160,160,160'),
                                   m_sepline_light_color(clrWhite),
                                   m_right_arrow_file_on(""),
                                   m_right_arrow_file_off("")
  {
//--- Store the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
//--- Set priorities of the left mouse button click
   m_area_zorder=0;
//--- Context menu is a drop-down element
   CElementBase::IsDropdown(true);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CContextMenu::~CContextMenu(void)
  {
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CContextMenu::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Handling the mouse cursor movement
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      //--- Leave, if the control is hidden
      if(!CElementBase::IsVisible())
         return;
      //--- Leave, if numbers of subwindows do not match
      if(!CElementBase::CheckSubwindowNumber())
         return;
      //--- Checking the focus over elements
      CElementBase::CheckMouseFocus();
      //--- Leave, if this is a detached context menu
      if(m_free_context_menu)
         return;
      //--- If the context menu is enabled and the left mouse button is pressed
      if(m_context_menu_state && m_mouse.LeftButtonState())
        {
         //--- Check conditions for closing all context menus
         CheckHideContextMenus();
         return;
        }
      //--- Check conditions for closing all context menus which were open after that
      CheckHideBackContextMenus();
      return;
     }
//--- Handling the left mouse button click on the object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      if(OnClickMenuItem(sparam))
         return;
     }
//--- Handling the ON_CLICK_MENU_ITEM event
   if(id==CHARTEVENT_CUSTOM+ON_CLICK_MENU_ITEM)
     {
      //--- Leave, if this is a detached context menu
      if(m_free_context_menu)
         return;
      //---
      int    item_id      =int(lparam);
      int    item_index   =int(dparam);
      string item_message =sparam;
      //--- Receiving the message from the menu item for handling
      ReceiveMessageFromMenuItem(item_id,item_index,item_message);
      return;
     }
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CContextMenu::OnEventTimer(void)
  {
//--- Changing the color of menu items when the cursor is hovering over them
   ChangeObjectsColor();
  }
//+------------------------------------------------------------------+
//| Creates a context menu                                           |
//+------------------------------------------------------------------+
bool CContextMenu::CreateContextMenu(const long chart_id,const int subwin,const int x_gap=0,const int y_gap=0)
  {
//--- Exit if there is no pointer to the form
   if(!CElement::CheckWindowPointer())
      return(false);
//--- If this is an attached context menu
   if(!m_free_context_menu)
     {
      //--- Leave, if there is no pointer to the previous node 
      if(::CheckPointer(m_prev_node)==POINTER_INVALID)
        {
         ::Print(__FUNCTION__," > Before creating a context menu it has to be passed "
                 "a pointer to the previous node using the CContextMenu::PrevNodePointer(CMenuItem &object) method.");
         return(false);
        }
     }
//--- Initializing variables
   m_id       =m_wnd.LastId()+1;
   m_chart_id =chart_id;
   m_subwin   =subwin;
//--- If coordinates are not specified
   if(x_gap==0 || y_gap==0)
     {
      if(m_fix_side==FIX_RIGHT)
         m_x=(m_anchor_right_window_side)? m_prev_node.X()-m_prev_node.XSize()+3 : m_prev_node.X2()-3;
      else
         m_x=(m_anchor_right_window_side)? m_prev_node.X()-1 : m_prev_node.X()+1;
      //---
      if(m_fix_side==FIX_RIGHT)
         m_y=(m_anchor_bottom_window_side)? m_prev_node.Y()+1 : m_prev_node.Y()-1;
      else
         m_y=(m_anchor_bottom_window_side)? m_prev_node.Y()-m_prev_node.YSize()+1 : m_prev_node.Y2()-1;
     }
//--- If coordinates have been specified
   else
     {
      m_x =CElement::CalculateX(x_gap);
      m_y =CElement::CalculateY(y_gap);
     }
//--- Margins from the edge
   CElementBase::XGap(CElement::CalculateXGap(m_x));
   CElementBase::YGap(CElement::CalculateYGap(m_y));
//--- Creating a context menu
   if(!CreateArea())
      return(false);
   if(!CreateItems())
      return(false);
//--- Hide the element
   Hide();
//--- Reset the color of objects
   ResetColors();
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the common area of a context menu                        |
//+------------------------------------------------------------------+
bool CContextMenu::CreateArea(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_contextmenu_bg_"+(string)CElementBase::Id();
//--- Calculation of the context menu height depends on the number of menu items and separation lines
   int items_total =ItemsTotal();
   int sep_y_size  =::ArraySize(m_sep_line)*9;
   m_y_size        =(m_item_y_size*items_total+2)+sep_y_size-(items_total-1);
//--- Set up the context menu background
   if(!m_area.Create(m_chart_id,name,m_subwin,m_x,m_y,m_x_size,m_y_size))
      return(false);
//--- Set properties
   m_area.BackColor(m_area_color);
   m_area.Color(m_area_border_color);
   m_area.BorderType(BORDER_FLAT);
   m_area.Corner(m_corner);
   m_area.Selectable(false);
   m_area.Z_Order(m_area_zorder);
   m_area.Tooltip("\n");
//--- Background size
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
//| Creates a list of menu items                                     |
//+------------------------------------------------------------------+
bool CContextMenu::CreateItems(void)
  {
//--- For identification of the location of separation lines
   int s=0;
//--- Coordinates
   int x =CElement::CalculateXGap(m_x+1);
   int y =0;
//--- Number of separation lines
   int sep_lines_total=::ArraySize(m_sep_line_index);
//---
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      //--- Calculation of the Y coordinate
      y=(i>0) ? y+m_item_y_size-1 : m_y+1;
      //--- Store the form pointer
      m_items[i].WindowPointer(m_wnd);
      //--- If the context menu has an attachment, add the pointer to the previous node
      if(!m_free_context_menu)
         m_items[i].PrevNodePointer(m_prev_node);
      //--- Set properties
      m_items[i].XSize(m_x_size-2);
      m_items[i].YSize(m_item_y_size);
      m_items[i].IconFileOn(m_path_bmp_on[i]);
      m_items[i].IconFileOff(m_path_bmp_off[i]);
      m_items[i].AreaBackColor(m_area_color);
      m_items[i].AreaBackColorHoverOff(m_item_back_color_hover_off);
      m_items[i].AreaBorderColor(m_area_color);
      m_items[i].LabelColor(m_label_color);
      m_items[i].LabelColorHover(m_label_color_hover);
      m_items[i].RightArrowFileOn(m_right_arrow_file_on);
      m_items[i].RightArrowFileOff(m_right_arrow_file_off);
      m_items[i].IsDropdown(m_is_dropdown);
      m_items[i].AnchorRightWindowSide(m_anchor_right_window_side);
      m_items[i].AnchorBottomWindowSide(m_anchor_bottom_window_side);
      //--- Margins from the edge of the panel
      m_items[i].XGap(CElement::CalculateXGap(x));
      m_items[i].YGap(CElement::CalculateYGap(y));
      //--- Creating a menu item
      if(!m_items[i].CreateMenuItem(m_chart_id,m_subwin,i,m_label_text[i],x,CElement::CalculateYGap(y)))
         return(false);
      //--- Zero the focus
      CElementBase::MouseFocus(false);
      //--- Move to the following one if all separation lines have been set
      if(s>=sep_lines_total)
         continue;
      //--- If all indices match, then a separation line can be set up after this item
      if(i==m_sep_line_index[s])
        {
         if(!CreateSeparateLine(i,s))
            return(false);
         //--- Adjustment of the Y coordinate for the following item
         y=y+9;
         //--- Increase the counter for separation lines
         s++;
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a separation line                                        |
//+------------------------------------------------------------------+
bool CContextMenu::CreateSeparateLine(const int item_index,const int line_index)
  {
   int x=CElement::CalculateXGap(m_items[item_index].X()+5);
   int y=CElement::CalculateYGap(m_items[item_index].Y2()+2);
//--- Store the form pointer
   m_sep_line[line_index].WindowPointer(m_wnd);
//--- Set properties
   m_sep_line[line_index].TypeSepLine(H_SEP_LINE);
   m_sep_line[line_index].DarkColor(m_sepline_dark_color);
   m_sep_line[line_index].LightColor(m_sepline_light_color);
   m_sep_line[line_index].AnchorRightWindowSide(m_anchor_right_window_side);
   m_sep_line[line_index].AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating a separation line
   if(!m_sep_line[line_index].CreateSeparateLine(m_chart_id,m_subwin,line_index,x,y,m_x_size-10,2))
      return(false);
//--- Store the object pointer
   CElementBase::AddToArray(m_sep_line[line_index].Object(0));
   return(true);
  }
//+------------------------------------------------------------------+
//| Returns a menu item pointer by the index                         |
//+------------------------------------------------------------------+
CMenuItem *CContextMenu::ItemPointerByIndex(const int index)
  {
   int array_size=::ArraySize(m_items);
//--- If there is no item in the context menu, report
   if(array_size<1)
      ::Print(__FUNCTION__," > This method is to be called, if the context menu has at least one item!");
//--- Adjustment in case the range has been exceeded
   int i=(index>=array_size)? array_size-1 :(index<0)? 0 : index;
//--- Return the pointer
   return(::GetPointer(m_items[i]));
  }
//+------------------------------------------------------------------+
//| Adds a menu item                                                 |
//+------------------------------------------------------------------+
void CContextMenu::AddItem(const string text,const string path_bmp_on,const string path_bmp_off,const ENUM_TYPE_MENU_ITEM type)
  {
//--- Increase the array size by one element
   int array_size=::ArraySize(m_items);
   ::ArrayResize(m_items,array_size+1);
   ::ArrayResize(m_label_text,array_size+1);
   ::ArrayResize(m_path_bmp_on,array_size+1);
   ::ArrayResize(m_path_bmp_off,array_size+1);
//--- Store the values of passed parameters
   m_label_text[array_size]   =text;
   m_path_bmp_on[array_size]  =path_bmp_on;
   m_path_bmp_off[array_size] =path_bmp_off;
//--- Setting the type of the menu item
   m_items[array_size].TypeMenuItem(type);
  }
//+------------------------------------------------------------------+
//| Adds a separation line                                           |
//+------------------------------------------------------------------+
void CContextMenu::AddSeparateLine(const int item_index)
  {
//--- Increase the array size by one element
   int array_size=::ArraySize(m_sep_line);
   ::ArrayResize(m_sep_line,array_size+1);
   ::ArrayResize(m_sep_line_index,array_size+1);
//--- Store the index number
   m_sep_line_index[array_size]=item_index;
  }
//+------------------------------------------------------------------+
//| Returns the item name by the index                               |
//+------------------------------------------------------------------+
string CContextMenu::DescriptionByIndex(const uint index)
  {
   uint array_size=::ArraySize(m_items);
//--- If there is no item in the context menu, report
   if(array_size<1)
      ::Print(__FUNCTION__," > This method is to be called, if the context menu has at least one item!");
//--- Adjustment in case the range has been exceeded
   uint i=(index>=array_size)? array_size-1 : index;
//--- Return the item description
   return(m_items[i].LabelText());
  }
//+------------------------------------------------------------------+
//| Returns the item type by the index                               |
//+------------------------------------------------------------------+
ENUM_TYPE_MENU_ITEM CContextMenu::TypeMenuItemByIndex(const uint index)
  {
   uint array_size=::ArraySize(m_items);
//--- If there is no item in the context menu, report
   if(array_size<1)
      ::Print(__FUNCTION__," > This method is to be called, if the context menu has at least one item!");
//--- Adjustment in case the range has been exceeded
   uint i=(index>=array_size)? array_size-1 : index;
//--- Return the item type
   return(m_items[i].TypeMenuItem());
  }
//+------------------------------------------------------------------+
//| Returns the checkbox state by the index                          |
//+------------------------------------------------------------------+
bool CContextMenu::CheckBoxStateByIndex(const uint index)
  {
   uint array_size=::ArraySize(m_items);
//--- If there is no item in the context menu, report
   if(array_size<1)
      ::Print(__FUNCTION__," > This method is to be called, if the context menu has at least one item!");
//--- Adjustment in case the range has been exceeded
   uint i=(index>=array_size)? array_size-1 : index;
//--- Return the item state
   return(m_items[i].CheckBoxState());
  }
//+------------------------------------------------------------------+
//| Sets the checkbox state by the index                             |
//+------------------------------------------------------------------+
void CContextMenu::CheckBoxStateByIndex(const uint index,const bool state)
  {
//--- Checking for exceeding the array range
   uint array_size=::ArraySize(m_items);
//--- If there is no item in the context menu, report
   if(array_size<1)
      return;
//--- Adjustment in case the range has been exceeded
   uint i=(index>=array_size)? array_size-1 : index;
//--- Set the state
   m_items[i].CheckBoxState(state);
  }
//+------------------------------------------------------------------+
//| Returns the radio item id by the index                           |
//+------------------------------------------------------------------+
int CContextMenu::RadioItemIdByIndex(const uint index)
  {
   uint array_size=::ArraySize(m_items);
//--- If there is no item in the context menu, report
   if(array_size<1)
      ::Print(__FUNCTION__," > This method is to be called, if the context menu has at least one item!");
//--- Adjustment in case the range has been exceeded
   uint i=(index>=array_size)? array_size-1 : index;
//--- Return the identifier
   return(m_items[i].RadioButtonID());
  }
//+------------------------------------------------------------------+
//| Sets the radio item id by the index                              |
//+------------------------------------------------------------------+
void CContextMenu::RadioItemIdByIndex(const uint index,const int id)
  {
//--- Checking for exceeding the array range
   uint array_size=::ArraySize(m_items);
//--- If there is no item in the context menu, report
   if(array_size<1)
      return;
//--- Adjustment in case the range has been exceeded
   uint i=(index>=array_size)? array_size-1 : index;
//--- Set the identifier
   m_items[i].RadioButtonID(id);
  }
//+------------------------------------------------------------------+
//| Returns the radio item index by the id                           |
//+------------------------------------------------------------------+
int CContextMenu::SelectedRadioItem(const int radio_id)
  {
//--- Radio item counter
   int count_radio_id=0;
//--- Iterate over the list of context menu items
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      //--- Move to the following if this is not a radio item
      if(m_items[i].TypeMenuItem()!=MI_RADIOBUTTON)
         continue;
      //--- If identifiers match
      if(m_items[i].RadioButtonID()==radio_id)
        {
         //--- If this is an active radio item, leave the loop
         if(m_items[i].RadioButtonState())
            break;
         //--- Increase the counter of radio items
         count_radio_id++;
        }
     }
//--- Return the index
   return(count_radio_id);
  }
//+------------------------------------------------------------------+
//| Switches the radio item by the index and id                      |
//+------------------------------------------------------------------+
void CContextMenu::SelectedRadioItem(const int radio_index,const int radio_id)
  {
//--- Radio item counter
   int count_radio_id=0;
//--- Iterate over the list of context menu items
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      //--- Move to the following if this is not a radio item
      if(m_items[i].TypeMenuItem()!=MI_RADIOBUTTON)
         continue;
      //--- If identifiers match
      if(m_items[i].RadioButtonID()==radio_id)
        {
         //--- Switch the radio item
         if(count_radio_id==radio_index)
            m_items[i].RadioButtonState(true);
         else
            m_items[i].RadioButtonState(false);
         //--- Increase the counter of radio items
         count_radio_id++;
        }
     }
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CContextMenu::Moving(const int x,const int y,const bool moving_mode=false)
  {
//--- Leave, if the control is hidden
   if(!CElementBase::IsVisible())
      return;
//--- If the management is delegated to the window, identify its location
   if(!moving_mode)
      if(m_wnd.ClampingAreaMouse()!=PRESSED_INSIDE_HEADER)
         return;
//---
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
      //--- Storing coordinates in the fields of the objects
      CElementBase::X(x+XGap());
      //--- Storing coordinates in the fields of the objects
      m_area.X(x+m_area.XGap());
     }
//--- If the anchored to the bottom
   if(m_anchor_bottom_window_side)
     {
      //--- Storing coordinates in the element fields
      CElementBase::Y(m_wnd.Y2()-YGap());
      //--- Storing coordinates in the fields of the objects
      m_area.Y(m_wnd.Y2()-m_area.YGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::Y(y+YGap());
      //--- Storing coordinates in the fields of the objects
      m_area.Y(y+m_area.YGap());
     }
//--- Updating coordinates of graphical objects
   m_area.X_Distance(m_area.X());
   m_area.Y_Distance(m_area.Y());
//--- Moving menu items
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
      m_items[i].Moving(x,y);
//--- Moving separation lines
   int sep_total=::ArraySize(m_sep_line);
   for(int i=0; i<sep_total; i++)
      m_sep_line[i].Moving(x,y);
  }
//+------------------------------------------------------------------+
//| Shows a context menu                                             |
//+------------------------------------------------------------------+
void CContextMenu::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElementBase::IsVisible())
      return;
//--- Show the objects of the context menu
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_ALL_PERIODS);
//--- Show the menu items
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
      m_items[i].Show();
//--- Show the separation line
   int sep_total=::ArraySize(m_sep_line);
   for(int i=0; i<sep_total; i++)
      m_sep_line[i].Show();
//--- Reset the color of objects
   ResetColors();
//--- Assign the status of a visible control
   CElementBase::IsVisible(true);
//--- State of the context menu
   m_context_menu_state=true;
//--- Register the state in the previous node
   if(!m_free_context_menu)
      m_prev_node.ContextMenuState(true);
//--- Block the form
   m_wnd.IsLocked(true);
//--- Send a signal for zeroing priorities of the left mouse click
   ::EventChartCustom(m_chart_id,ON_ZERO_PRIORITIES,CElementBase::Id(),0.0,"");
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
//| Hides a context menu                                             |
//+------------------------------------------------------------------+
void CContextMenu::Hide(void)
  {
//--- Leave, if the control is hidden
   if(!CElementBase::IsVisible())
      return;
//--- Hide the objects of the context menu
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_NO_PERIODS);
//--- Hide the menu items
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
      m_items[i].Hide();
//--- Hide the separation line
   int sep_total=::ArraySize(m_sep_line);
   for(int i=0; i<sep_total; i++)
      m_sep_line[i].Hide();
//--- Zero the focus
   CElementBase::MouseFocus(false);
//--- Assign the status of a hidden element
   CElementBase::IsVisible(false);
//--- State of the context menu
   m_context_menu_state=false;
//--- Register the state in the previous node
   if(!m_free_context_menu)
      m_prev_node.ContextMenuState(false);
//--- Send a signal to restore the priorities of the left mouse click
   ::EventChartCustom(m_chart_id,ON_SET_PRIORITIES,CElementBase::Id(),0.0,CElementBase::ClassName());
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CContextMenu::Reset(void)
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
void CContextMenu::Delete(void)
  {
//--- Removing objects  
   m_area.Delete();
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
      m_items[i].Delete();
//--- Removing separation lines
   int sep_total=::ArraySize(m_sep_line);
   for(int i=0; i<sep_total; i++)
      m_sep_line[i].Delete();
//--- Emptying the control arrays
   ::ArrayFree(m_items);
   ::ArrayFree(m_sep_line);
   ::ArrayFree(m_sep_line_index);
   ::ArrayFree(m_label_text);
   ::ArrayFree(m_path_bmp_on);
   ::ArrayFree(m_path_bmp_off);
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
//--- Initializing of variables by default values
   m_context_menu_state=false;
   CElementBase::MouseFocus(false);
   CElementBase::IsVisible(true);
  }
//+------------------------------------------------------------------+
//| Seth the priorities                                              |
//+------------------------------------------------------------------+
void CContextMenu::SetZorders(void)
  {
   m_area.Z_Order(m_area_zorder);
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CContextMenu::ResetZorders(void)
  {
   m_area.Z_Order(0);
  }
//+------------------------------------------------------------------+
//| Reset the color of the element objects                           |
//+------------------------------------------------------------------+
void CContextMenu::ResetColors(void)
  {
//--- Iterate over all menu items
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      //--- Reset the color of the menu item
      m_items[i].ResetColors();
     }
  }
//+------------------------------------------------------------------+
//| Checking conditions for closing all context menus                |
//+------------------------------------------------------------------+
void CContextMenu::CheckHideContextMenus(void)
  {
//--- Leave, if the cursor is in the context menu area or in the previous node area
   if(CElementBase::MouseFocus() || m_prev_node.MouseFocus())
      return;
//--- If the cursor is outside of the area of these elements, then ...
//    ... a check is required if there are open context menus which were activated after that
//--- For that iterate over the list of this context menu ...
//    ... for identification if there is a menu item containing a context menu
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      //--- If there is such an item, check if its context menu is open.
      //    It this is open, do not send a signal for closing all context menus from this element as...
      //    ... it is possible that the cursor is in the area of the following one and this has to be checked.
      if(m_items[i].TypeMenuItem()==MI_HAS_CONTEXT_MENU)
         if(m_items[i].ContextMenuState())
            return;
     }
//--- Unblock the form
   m_wnd.IsLocked(false);
//--- Send a signal for hiding all context menus
   ::EventChartCustom(m_chart_id,ON_HIDE_CONTEXTMENUS,0,0,"");
  }
//+------------------------------------------------------------------+
//| Checking conditions for closing all context menus,               |
//| which were open after that                                       |
//+------------------------------------------------------------------+
void CContextMenu::CheckHideBackContextMenus(void)
  {
//--- Iterate over all menu items
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      //--- If the item contains a context menu and this is enabled
      if(m_items[i].TypeMenuItem()==MI_HAS_CONTEXT_MENU && m_items[i].ContextMenuState())
        {
         //--- If the focus is in the context menu but not in this item
         if(CElementBase::MouseFocus() && !m_items[i].MouseFocus())
           {
            //--- Send a signal to hide all context menus which were open after this one
            ::EventChartCustom(m_chart_id,ON_HIDE_BACK_CONTEXTMENUS,CElementBase::Id(),0,"");
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Changing the object color when the cursor is hovering over it    |
//+------------------------------------------------------------------+
void CContextMenu::ChangeObjectsColor(void)
  {
//--- Leave, if the context menu is disabled
   if(!m_context_menu_state)
      return;
//--- Iterate over all menu items
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      //--- Change the color of the menu item
      m_items[i].ChangeObjectsColor();
     }
  }
//+------------------------------------------------------------------+
//| Handling clicking on the menu item                               |
//+------------------------------------------------------------------+
bool CContextMenu::OnClickMenuItem(const string clicked_object)
  {
//--- Leave, if this context menu has a previous node and is already open
   if(!m_free_context_menu && m_context_menu_state)
      return(true);
//--- Leave, if the clicking was not on the menu item
   if(::StringFind(clicked_object,CElementBase::ProgramName()+"_menuitem_",0)<0)
      return(false);
//--- Get the identifier and index from the object name
   int id    =CElementBase::IdFromObjectName(clicked_object);
   int index =CElementBase::IndexFromObjectName(clicked_object);
//--- If the context menu has a previous node
   if(!m_free_context_menu)
     {
      //--- Leave, if the clicking was not on the menu item to which this context menu is attached
      if(id!=m_prev_node.Id() || index!=m_prev_node.Index())
         return(false);
      //--- Show the context menu
      Show();
     }
//--- If this is a detached context menu
   else
     {
      //--- Find in a loop the menu item which was pressed
      int total=ItemsTotal();
      for(int i=0; i<total; i++)
        {
         if(m_items[i].Object(0).Name()!=clicked_object)
            continue;
         //--- Send a message about it
         ::EventChartCustom(m_chart_id,ON_CLICK_FREEMENU_ITEM,CElementBase::Id(),i,DescriptionByIndex(i));
         break;
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Receiving a message from the menu item for handling              |
//+------------------------------------------------------------------+
void CContextMenu::ReceiveMessageFromMenuItem(const int id_item,const int index_item,const string message_item)
  {
//--- If there is an indication that the message was received from this program and the element id matches
   if(::StringFind(message_item,CElementBase::ProgramName(),0)>-1 && id_item==CElementBase::Id())
     {
      //--- If clicking was on the radio item
      if(::StringFind(message_item,"radioitem",0)>-1)
        {
         //--- Get the radio item id from the passed message
         int radio_id=RadioIdFromMessage(message_item);
         //--- Get the radio item index by the general index
         int radio_index=RadioIndexByItemIndex(index_item);
         //--- Switch the radio item
         SelectedRadioItem(radio_index,radio_id);
        }
      //--- Send a message about it
      ::EventChartCustom(m_chart_id,ON_CLICK_CONTEXTMENU_ITEM,id_item,index_item,DescriptionByIndex(index_item));
     }
//--- Hide the context menu
   Hide();
//--- Unblock the form
   m_wnd.IsLocked(false);
//--- Send a signal for hiding all context menus
   ::EventChartCustom(m_chart_id,ON_HIDE_CONTEXTMENUS,0,0,"");
  }
//+------------------------------------------------------------------+
//| Extracts the identifier from the message for the radio item      |
//+------------------------------------------------------------------+
int CContextMenu::RadioIdFromMessage(const string message)
  {
   ushort u_sep=0;
   string result[];
   int    array_size=0;
//--- Get the code of the separator
   u_sep=::StringGetCharacter("_",0);
//--- Split the string
   ::StringSplit(message,u_sep,result);
   array_size=::ArraySize(result);
//--- If the message structure differs from the expected one
   if(array_size!=3)
     {
      ::Print(__FUNCTION__," > Wrong structure in the message for the radio item! message: ",message);
      return(WRONG_VALUE);
     }
//--- Prevention of exceeding the array size
   if(array_size<3)
     {
      ::Print(PREVENTING_OUT_OF_RANGE);
      return(WRONG_VALUE);
     }
//--- Return the radio item id
   return((int)result[2]);
  }
//+------------------------------------------------------------------+
//| Returns the radio item index by general index                    |
//+------------------------------------------------------------------+
int CContextMenu::RadioIndexByItemIndex(const int index)
  {
   int radio_index=0;
//--- Get the radio item id by the general index
   int radio_id=RadioItemIdByIndex(index);
//--- Item counter from the required group
   int count_radio_id=0;
//--- Iterate over the list
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
     {
      //--- If this is not a radio item, move to the next one
      if(m_items[i].TypeMenuItem()!=MI_RADIOBUTTON)
         continue;
      //--- If identifiers match
      if(m_items[i].RadioButtonID()==radio_id)
        {
         //--- If the indices match 
         //    store the current counter value and complete the loop
         if(m_items[i].Index()==index)
           {
            radio_index=count_radio_id;
            break;
           }
         //--- Increase the counter
         count_radio_id++;
        }
     }
//--- Return the index
   return(radio_index);
  }
//+------------------------------------------------------------------+
