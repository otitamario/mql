//+------------------------------------------------------------------+
//|                                                     TreeView.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "TreeItem.mqh"
#include "Scrolls.mqh"
#include "Pointer.mqh"
//+------------------------------------------------------------------+
//| Class for creating a tree view                                   |
//+------------------------------------------------------------------+
class CTreeView : public CElement
  {
private:
   //--- Objects for creating the element
   CRectLabel        m_area;
   CRectLabel        m_content_area;
   CTreeItem         m_items[];
   CTreeItem         m_content_items[];
   CScrollV          m_scrollv;
   CScrollV          m_content_scrollv;
   CPointer          m_x_resize;
   //--- Structure of the controls attached to each tab item
   struct TVElements
     {
      CElement         *elements[];
      int               list_index;
     };
   TVElements        m_tab_items[];
   //--- Arrays for all items of the tree view (full list)
   int               m_t_list_index[];
   int               m_t_prev_node_list_index[];
   string            m_t_item_text[];
   string            m_t_path_bmp[];
   int               m_t_item_index[];
   int               m_t_node_level[];
   int               m_t_prev_node_item_index[];
   int               m_t_items_total[];
   int               m_t_folders_total[];
   bool              m_t_item_state[];
   bool              m_t_is_folder[];
   //--- Arrays for the list of displayed items of the tree view
   int               m_td_list_index[];
   //--- Arrays for the content list of the items selected in the tree view (full list)
   int               m_c_list_index[];
   int               m_c_tree_list_index[];
   string            m_c_item_text[];
   //--- Arrays for the list of displayed items in the content list
   int               m_cd_list_index[];
   int               m_cd_tree_list_index[];
   string            m_cd_item_text[];
   //--- Total number of items and the number of lists in the visible part
   int               m_items_total;
   int               m_content_items_total;
   int               m_visible_items_total;
   //--- Indices of the selected items in the lists
   int               m_selected_item_index;
   int               m_selected_content_item_index;
   //--- Text of the item selected in the list. 
   //    Only for files in the case of using a class for creating a file navigator.
   //    If not a file is selected in the list, then this field must contain an empty string "".
   string            m_selected_item_file_name;
   //--- Tree view area width
   int               m_treeview_area_width;
   //--- Background and background frame color
   color             m_area_color;
   color             m_area_border_color;
   //--- Content area width
   int               m_content_area_width;
   //--- Height of the items
   int               m_item_y_size;
   //--- Colors of the items in different states
   color             m_item_back_color_hover;
   color             m_item_back_color_selected;
   //--- Color of the text in different states
   color             m_item_text_color;
   color             m_item_text_color_hover;
   color             m_item_text_color_selected;
   //--- Icons for arrows
   string            m_item_arrow_file_on;
   string            m_item_arrow_file_off;
   string            m_item_arrow_selected_file_on;
   string            m_item_arrow_selected_file_off;
   //--- Priorities of the left mouse button press
   int               m_zorder;
   //--- File navigator mode
   ENUM_FILE_NAVIGATOR_MODE m_file_navigator_mode;
   //--- Mode of highlighting when the cursor is hovering over
   bool              m_lights_hover;
   //--- Mode of displaying the item content in the working area
   bool              m_show_item_content;
   //--- Mode of changing the list widths
   bool              m_resize_list_area_mode;
   //--- Mode of tab items
   bool              m_tab_items_mode;
   //--- Timer counter for fast forwarding the list view
   int               m_timer_counter;
   //--- (1) Minimum and (2) maximum level of node
   int               m_min_node_level;
   int               m_max_node_level;
   //--- The number of items in the root directory
   int               m_root_items_total;
   //--- To determine the moment of mouse cursor transition from one item to another
   int               m_prev_t_item_index_focus;
   int               m_prev_c_item_index_focus;
   //---
public:
                     CTreeView(void);
                    ~CTreeView(void);
   //--- Methods for creating a tree view
   bool              CreateTreeView(const long chart_id,const int subwin,const int x_gap,const int y_gap);
   //---
private:
   bool              CreateArea(void);
   bool              CreateContentArea(void);
   bool              CreateItems(void);
   bool              CreateScrollV(void);
   bool              CreateContentItems(void);
   bool              CreateContentScrollV(void);
   bool              CreateXResizePointer(void);
   //---
public:
   //--- Pointers to list scrollbars
   CScrollV         *GetScrollVPointer(void)                            { return(::GetPointer(m_scrollv));          }
   CScrollV         *GetContentScrollVPointer(void)                     { return(::GetPointer(m_content_scrollv));  }
   //--- Returns the (1) pointer of the tree view item, (2) pointer of the content list item, 
   CTreeItem        *ItemPointer(const int index);
   CTreeItem        *ContentItemPointer(const int index);
   //--- (1) File navigator mode, (2) mode of highlighting when hovered, 
   //    (3) mode of displaying the item content, (4) mode of changing the list widths, (5) tab items mode
   void              NavigatorMode(const ENUM_FILE_NAVIGATOR_MODE mode) { m_file_navigator_mode=mode;               }
   void              LightsHover(const bool state)                      { m_lights_hover=state;                     }
   void              ShowItemContent(const bool state)                  { m_show_item_content=state;                }
   void              ResizeListAreaMode(const bool state)               { m_resize_list_area_mode=state;            }
   void              TabItemsMode(const bool state)                     { m_tab_items_mode=state;                   }
   //--- The number of items (1) in the tree view, (2) in the content list and (3) visible number of items
   int               ItemsTotal(void)                             const { return(::ArraySize(m_items));             }
   int               ContentItemsTotal(void)                      const { return(::ArraySize(m_content_items));     }
   void              VisibleItemsTotal(const int total)                 { m_visible_items_total=total;              }
   //--- (1) The height of the item, (2) the width of the tree view and (3) the content list
   void              ItemYSize(const int y_size)                        { m_item_y_size=y_size;                     }
   void              TreeViewAreaWidth(const int x_size)                { m_treeview_area_width=x_size;             }
   void              ContentAreaWidth(const int x_size)                 { m_content_area_width=x_size;              }
   //--- Control background and background frame color
   void              AreaBackColor(const color clr)                     { m_area_color=clr;                         }
   void              AreaBorderColor(const color clr)                   { m_area_border_color=clr;                  }
   //--- Colors of the items in different states
   void              ItemBackColorHover(const color clr)                { m_item_back_color_hover=clr;              }
   void              ItemBackColorSelected(const color clr)             { m_item_back_color_selected=clr;           }
   //--- Color of the text in different states
   void              ItemTextColor(const color clr)                     { m_item_text_color=clr;                    }
   void              ItemTextColorHover(const color clr)                { m_item_text_color_hover=clr;              }
   void              ItemTextColorSelected(const color clr)             { m_item_text_color_selected=clr;           }
   //--- Icons for the item arrow
   void              ItemArrowFileOn(const string file_path)            { m_item_arrow_file_on=file_path;           }
   void              ItemArrowFileOff(const string file_path)           { m_item_arrow_file_off=file_path;          }
   void              ItemArrowSelectedFileOn(const string file_path)    { m_item_arrow_selected_file_on=file_path;  }
   void              ItemArrowSelectedFileOff(const string file_path)   { m_item_arrow_selected_file_off=file_path; }
   //--- (1) Selects the item by index and (2) returns the index of the selected item, (3) return the name of the file
   void              SelectedItemIndex(const int index)                 { m_selected_item_index=index;              }
   int               SelectedItemIndex(void)                      const { return(m_selected_item_index);            }
   string            SelectedItemFileName(void)                   const { return(m_selected_item_file_name);        }

   //--- Add item to the tree view
   void              AddItem(const int list_index,const int list_id,const string item_name,const string path_bmp,const int item_index,
                             const int node_number,const int item_number,const int items_total,const int folders_total,const bool item_state,const bool is_folder=true);
   //--- Add control to the tab item array
   void              AddToElementsArray(const int item_index,CElement &object);
   //--- Show controls of the selected tab item only
   void              ShowTabElements(void);
   //--- Returns the full path of the selected item
   string            CurrentFullPath(void);
   //--- Changing the color
   void              ChangeObjectsColor(void);
   //--- Changing color in the tree view area
   void              ChangeTreeViewObjectsColor(void);
   //--- Changing color in the content area
   void              ChangeContentObjectsColor(void);
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
   //--- Handle clicking the item list minimization/maximization button
   bool              OnClickItemArrow(const string clicked_object);
   //--- Handling clicking the tree view item
   bool              OnClickItem(const string clicked_object);
   //--- Handling clicking the item in the content list
   bool              OnClickContentListItem(const string clicked_object);

   //--- Generates an array of tab items
   void              GenerateTabItemsArray(void);
   //--- Determine and set (1) the node borders and (2) the size of the root directory
   void              SetNodeLevelBoundaries(void);
   void              SetRootItemsTotal(void);
   //--- Shift of the lists
   void              ShiftTreeList(void);
   void              ShiftContentList(void);
   //--- Fast forward of the list view
   void              FastSwitching(void);

   //--- Controls the width of the lists
   void              ResizeListArea(const int x,const int y);
   //--- Check readiness to change the width of lists
   void              CheckXResizePointer(const int x,const int y);
   //--- Checking for exceeding the limits
   bool              CheckOutOfArea(const int x,const int y);
   //--- Update the tree view width
   void              UpdateTreeListWidth(const int x);
   //--- Update the list width in the content area
   void              UpdateContentListWidth(const int x);

   //--- Add the item to the list in the content area
   void              AddDisplayedTreeItem(const int list_index);
   //--- Update (1) the tree view and (2) the content list
   void              UpdateTreeViewList(void);
   void              UpdateContentList(void);
   //--- Redraw the tree view
   void              RedrawTreeList(void);
   //--- Resetting color in the tree view area
   void              ResetTreeViewColors(void);
   //--- Resetting color in the content area
   void              ResetContentAreaColors(void);

   //--- Checking for the index of the selected item exceeding the array range
   void              CheckSelectedItemIndex(void);

   //--- Change the width at the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTreeView::CTreeView(void) : m_treeview_area_width(180),
                             m_content_area_width(WRONG_VALUE),
                             m_item_y_size(20),
                             m_visible_items_total(13),
                             m_tab_items_mode(false),
                             m_lights_hover(false),
                             m_show_item_content(true),
                             m_resize_list_area_mode(false),
                             m_selected_item_index(WRONG_VALUE),
                             m_selected_content_item_index(WRONG_VALUE),
                             m_area_color(clrWhite),
                             m_area_border_color(clrLightGray),
                             m_item_back_color_hover(C'240,240,240'),
                             m_item_back_color_selected(C'51,153,255'),
                             m_item_text_color(clrBlack),
                             m_item_text_color_hover(clrBlack),
                             m_item_text_color_selected(clrWhite),
                             m_item_arrow_file_on(""),
                             m_item_arrow_file_off(""),
                             m_item_arrow_selected_file_on(""),
                             m_item_arrow_selected_file_off(""),
                             m_prev_t_item_index_focus(WRONG_VALUE),
                             m_prev_c_item_index_focus(WRONG_VALUE)
  {
//--- Store the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
//--- Set priorities of the left mouse button click
   m_zorder=0;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTreeView::~CTreeView(void)
  {
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CTreeView::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Handling of the cursor movement event
   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      //--- Leave, if the control is hidden
      if(!CElementBase::IsVisible())
         return;
      //--- Leave, if numbers of subwindows do not match
      if(!CElementBase::CheckSubwindowNumber())
         return;
      //--- Checking the focus over element
      CElementBase::CheckMouseFocus();
      //--- Move the tree view if the management of the slider is enabled
      if(m_scrollv.ScrollBarControl())
        {
         ShiftTreeList();
         return;
        }
      //--- Enter only if there is a list
      if(m_t_items_total[m_selected_item_index]>0)
        {
         //--- Move the content list if the management of the slider is enabled
         if(m_content_scrollv.ScrollBarControl())
           {
            ShiftContentList();
            return;
           }
        }
      //--- Leave, if the form is blocked by another control
      if(m_wnd.IsLocked() && !CElement::CheckIdActivatedElement())
         return;
      //--- Management of the content area width
      ResizeListArea(m_mouse.X(),m_mouse.Y());
      //--- Reset color of the element, if not in focus and the left mouse button is released
      if(!CElementBase::MouseFocus() && !m_mouse.LeftButtonState())
        {
         if(m_prev_t_item_index_focus!=WRONG_VALUE && m_prev_c_item_index_focus!=WRONG_VALUE)
           {
            ResetColors();
            m_prev_t_item_index_focus=WRONG_VALUE;
            m_prev_c_item_index_focus=WRONG_VALUE;
           }
         return;
        }
      //--- Checking the focus over elements
      m_area.MouseFocus(m_mouse.X()>m_area.X() && m_mouse.X()<m_area.X2() && 
                        m_mouse.Y()>m_area.Y() && m_mouse.Y()<m_area.Y2());
      m_content_area.MouseFocus(m_mouse.X()>m_content_area.X() && m_mouse.X()<m_content_area.X2() && 
                                m_mouse.Y()>m_content_area.Y() && m_mouse.Y()<m_content_area.Y2());
      //--- Change the color on mouseover
      ChangeObjectsColor();
      return;
     }
//--- Handling the left mouse button click on the object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- Leave, if the mode of changing the size of the content list area is active
      if(m_x_resize.IsVisible() || m_x_resize.State())
         return;
      //--- Handle clicking on the item arrow
      if(OnClickItemArrow(sparam))
         return;
      //--- Handling clicking the tree view item
      if(OnClickItem(sparam))
         return;
      //--- Handling clicking the item in the content list
      if(OnClickContentListItem(sparam))
         return;
      //--- Moves the list along the scrollbar
      if(m_scrollv.OnClickScrollInc(sparam) || m_scrollv.OnClickScrollDec(sparam))
         ShiftTreeList();
      if(m_content_scrollv.OnClickScrollInc(sparam) || m_content_scrollv.OnClickScrollDec(sparam))
         ShiftContentList();
      //---
      return;
     }
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CTreeView::OnEventTimer(void)
  {
//--- If the element is a drop-down
   if(CElementBase::IsDropdown())
     {
      ChangeObjectsColor();
      FastSwitching();
     }
   else
     {
      //--- Track the change of color and fast switching values, 
      //    only if the form is not blocked
      if(!m_wnd.IsLocked())
        {
         ChangeObjectsColor();
         FastSwitching();
        }
     }
  }
//+------------------------------------------------------------------+
//| Creates a context menu                                           |
//+------------------------------------------------------------------+
bool CTreeView::CreateTreeView(const long chart_id,const int subwin,const int x_gap,const int y_gap)
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
   m_y_size   =m_item_y_size*m_visible_items_total+2-(m_visible_items_total-1);
//--- Checking for the index of the selected item exceeding the array range
   CheckSelectedItemIndex();
//--- Margins from the edge
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
//--- Creating an element
   if(!CreateArea())
      return(false);
   if(!CreateContentArea())
      return(false);
   if(!CreateItems())
      return(false);
   if(!CreateScrollV())
      return(false);
   if(!CreateContentItems())
      return(false);
   if(!CreateContentScrollV())
      return(false);
   if(!CreateXResizePointer())
      return(false);
//--- Generates an array of tab items
   GenerateTabItemsArray();
//--- Determine and set (1) the node borders and (2) the size of the root directory
   SetNodeLevelBoundaries();
   SetRootItemsTotal();
//--- Update lists
   UpdateTreeViewList();
   UpdateContentList();
//--- Hide the element if the window is a dialog one or is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      Hide();
//--- Send a message to generate a directory in the file editor
   ::EventChartCustom(m_chart_id,ON_CHANGE_TREE_PATH,0,0,"");
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the list view background                                  |
//+------------------------------------------------------------------+
bool CTreeView::CreateArea(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_treeview_area_"+(string)CElementBase::Id();
//--- Creating the object
   if(!m_area.Create(m_chart_id,name,m_subwin,m_x,m_y,m_treeview_area_width,m_y_size))
      return(false);
//--- Setting up properties
   m_area.BackColor(m_area_color);
   m_area.Color(m_area_border_color);
   m_area.BorderType(BORDER_FLAT);
   m_area.Corner(m_corner);
   m_area.Selectable(false);
   m_area.Z_Order(m_zorder);
   m_area.Tooltip("\n");
//--- Store coordinates
   m_area.X(CElementBase::X());
   m_area.Y(CElementBase::Y());
//--- Store the size
   m_area.XSize(m_treeview_area_width);
   m_area.YSize(CElementBase::YSize());
//--- Margins from the edge
   m_area.XGap(CElement::CalculateXGap(m_x));
   m_area.YGap(CElement::CalculateYGap(m_y));
//--- Store the object pointer
   CElementBase::AddToArray(m_area);
//--- Hide the element if the window is a dialog one or is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      m_area.Timeframes(OBJ_NO_PERIODS);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a background for the item content                         |
//+------------------------------------------------------------------+
bool CTreeView::CreateContentArea(void)
  {
//--- Leave, if the content area is not needed
   if(m_content_area_width<0)
     {
      //--- Store the total width of the control and leave
      CElementBase::XSize(m_treeview_area_width);
      return(true);
     }
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_treeview_content_area_"+(string)CElementBase::Id();
//--- Coordinates
   int x=m_area.X2()-1;
   int y=CElementBase::Y();
//--- Size along the X axis
   if(m_auto_xresize_mode)
      m_content_area_width=m_wnd.X2()-x-m_auto_xresize_right_offset;
   else
      m_content_area_width=(m_content_area_width!=0)? m_content_area_width : m_wnd.X2()-x-m_auto_xresize_right_offset;
//--- Store the total width of the control
   CElementBase::XSize(m_treeview_area_width+m_content_area_width-1);
//--- Creating the object
   if(!m_content_area.Create(m_chart_id,name,m_subwin,x,y,m_content_area_width,m_y_size))
      return(false);
//--- Setting up properties
   m_content_area.BackColor(m_area_color);
   m_content_area.Color(m_area_border_color);
   m_content_area.BorderType(BORDER_FLAT);
   m_content_area.Corner(m_corner);
   m_content_area.Selectable(false);
   m_content_area.Z_Order(m_zorder);
   m_content_area.Tooltip("\n");
//--- Store coordinates
   m_content_area.X(x);
   m_content_area.Y(y);
//--- Store the size
   m_content_area.XSize(m_content_area_width);
   m_content_area.YSize(CElementBase::YSize());
//--- Margins from the edge
   m_content_area.XGap(CElement::CalculateXGap(x));
   m_content_area.YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_content_area);
//--- Hide the element if the window is a dialog one or is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      m_content_area.Timeframes(OBJ_NO_PERIODS);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the tree view                                            |
//+------------------------------------------------------------------+
bool CTreeView::CreateItems(void)
  {
//--- Coordinates
   int x =m_x+1;
   int y =m_y+1;
//---
   int items_total=::ArraySize(m_items);
   for(int i=0; i<items_total; i++)
     {
      //--- Calculation of the Y coordinate
      y=(i>0)? y+m_item_y_size-1 : y;
      //--- Pass the form pointer
      m_items[i].WindowPointer(m_wnd);
      //--- Set properties before creation
      m_items[i].Index(0);
      m_items[i].Id(CElementBase::Id());
      m_items[i].XSize(CElementBase::XSize());
      m_items[i].YSize(m_item_y_size);
      m_items[i].IconFile(m_t_path_bmp[i]);
      m_items[i].ItemBackColor(m_area_color);
      m_items[i].ItemBackColorHover(m_item_back_color_hover);
      m_items[i].ItemBackColorSelected(m_item_back_color_selected);
      m_items[i].ItemTextColor(m_item_text_color);
      m_items[i].ItemTextColorHover(m_item_text_color_hover);
      m_items[i].ItemTextColorSelected(m_item_text_color_selected);
      m_items[i].ItemArrowFileOn(m_item_arrow_file_on);
      m_items[i].ItemArrowFileOff(m_item_arrow_file_off);
      m_items[i].ItemArrowSelectedFileOn(m_item_arrow_selected_file_on);
      m_items[i].ItemArrowSelectedFileOff(m_item_arrow_selected_file_off);
      m_items[i].AnchorRightWindowSide(m_anchor_right_window_side);
      m_items[i].AnchorBottomWindowSide(m_anchor_bottom_window_side);
      //--- Determine the item type
      ENUM_TYPE_TREE_ITEM type=TI_SIMPLE;
      if(m_file_navigator_mode==FN_ALL)
         type=(m_t_items_total[i]>0)? TI_HAS_ITEMS : TI_SIMPLE;
      else // FN_ONLY_FOLDERS
      type=(m_t_folders_total[i]>0)? TI_HAS_ITEMS : TI_SIMPLE;
      //--- Adjustment of the initial state of the item
      m_t_item_state[i]=(type==TI_HAS_ITEMS)? m_t_item_state[i]: false;
      //--- Creating an element
      if(!m_items[i].CreateTreeItem(m_chart_id,m_subwin,CElement::CalculateXGap(x),CElement::CalculateYGap(y),type,
         m_t_list_index[i],m_t_node_level[i],m_t_item_text[i],m_t_item_state[i]))
         return(false);
      //--- Set the color of the selected item
      if(i==m_selected_item_index)
         m_items[i].HighlightItemState(true);
      //--- Hide the element
      m_items[i].Hide();
      //--- The item will be a drop-down control
      m_items[i].IsDropdown(true);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the vertical scrollbar                                   |
//+------------------------------------------------------------------+
bool CTreeView::CreateScrollV(void)
  {
//--- Store the form pointer
   m_scrollv.WindowPointer(m_wnd);
//--- Coordinates
   int x=CElement::CalculateXGap(m_area.X2()-m_scrollv.ScrollWidth());
   int y=CElement::CalculateYGap(CElementBase::Y());
//--- Set properties
   m_scrollv.Index(0);
   m_scrollv.Id(CElementBase::Id());
   m_scrollv.XSize(m_scrollv.ScrollWidth());
   m_scrollv.YSize(m_item_y_size*m_visible_items_total+2-(m_visible_items_total-1));
   m_scrollv.AnchorRightWindowSide(m_anchor_right_window_side);
   m_scrollv.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating the scrollbar
   if(!m_scrollv.CreateScroll(m_chart_id,m_subwin,x,y,m_items_total,m_visible_items_total))
      return(false);
//--- Hide the element
   m_scrollv.Hide();
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a content list of the selected item                       |
//+------------------------------------------------------------------+
bool CTreeView::CreateContentItems(void)
  {
//--- Leave, if showing the item content is not needed or
//    if the content area is disabled
   if(!m_show_item_content || m_content_area_width<0)
      return(true);
//--- Reserve size of the array
   int reserve_size=10000;
//--- Coordinates and width
   int x =m_content_area.X()+1;
   int y =m_y+1;
   int w =m_content_area.X2()-x-1;
//--- Counter of the number of items
   int c=0;
//--- 
   int items_total=::ArraySize(m_items);
   for(int i=0; i<items_total; i++)
     {
      //--- This list must include items from the root directory, 
      //    therefore, if the node level is less than 1, go to the next
      if(m_t_node_level[i]<1)
         continue;
      //--- Increase the sizes of arrays by one element
      int new_size=c+1;
      ::ArrayResize(m_content_items,new_size,reserve_size);
      ::ArrayResize(m_c_item_text,new_size,reserve_size);
      ::ArrayResize(m_c_tree_list_index,new_size,reserve_size);
      ::ArrayResize(m_c_list_index,new_size,reserve_size);
      //--- Calculation of the Y coordinate
      y=(c>0)? y+m_item_y_size-1 : y;
      //--- Pass the panel object
      m_content_items[c].WindowPointer(m_wnd);
      //--- Set properties before creation
      m_content_items[c].Index(1);
      m_content_items[c].Id(CElementBase::Id());
      m_content_items[c].XSize(w);
      m_content_items[c].YSize(m_item_y_size);
      m_content_items[c].IconFile(m_t_path_bmp[i]);
      m_content_items[c].ItemBackColor(m_area_color);
      m_content_items[c].ItemBackColorHover(m_item_back_color_hover);
      m_content_items[c].ItemBackColorSelected(m_item_back_color_selected);
      m_content_items[c].ItemTextColor(m_item_text_color);
      m_content_items[c].ItemTextColorHover(m_item_text_color_hover);
      m_content_items[c].ItemTextColorSelected(m_item_text_color_selected);
      m_content_items[c].AnchorRightWindowSide(m_anchor_right_window_side);
      m_content_items[c].AnchorBottomWindowSide(m_anchor_bottom_window_side);
      //--- Creating the object
      if(!m_content_items[c].CreateTreeItem(m_chart_id,m_subwin,
                                            CElement::CalculateXGap(x),CElement::CalculateYGap(y),TI_SIMPLE,c,0,m_t_item_text[i],false))
         return(false);
      //--- Hide the element
      m_content_items[c].Hide();
      //--- The item will be a drop-down control
      m_content_items[c].IsDropdown(true);
      //--- Store (1) index of the general content list, (2) index of the tree view and (3) item text
      m_c_list_index[c]      =c;
      m_c_tree_list_index[c] =m_t_list_index[i];
      m_c_item_text[c]       =m_t_item_text[i];
      //---
      c++;
     }
//--- Store the size of the list
   m_content_items_total=::ArraySize(m_content_items);
   return(true);
  }
//+------------------------------------------------------------------+
//| Create vertical scrollbar for working area                       |
//+------------------------------------------------------------------+
bool CTreeView::CreateContentScrollV(void)
  {
//--- Leave, if showing the item content is not needed or
//    if the content area is disabled
   if(!m_show_item_content || m_content_area_width<0)
      return(true);
//--- Store the form pointer
   m_content_scrollv.WindowPointer(m_wnd);
//--- Coordinates
   int x=CElement::CalculateXGap(m_content_area.X()+m_content_area.X_Size()-m_content_scrollv.ScrollWidth());
   int y=CElement::CalculateYGap(CElementBase::Y());
//--- Set sizes
   m_content_scrollv.Index(1);
   m_content_scrollv.Id(CElementBase::Id());
   m_content_scrollv.XSize(m_content_scrollv.ScrollWidth());
   m_content_scrollv.YSize(m_item_y_size*m_visible_items_total+2-(m_visible_items_total-1));
   m_content_scrollv.AnchorRightWindowSide(m_anchor_right_window_side);
   m_content_scrollv.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating the scrollbar
   if(!m_content_scrollv.CreateScroll(m_chart_id,m_subwin,x,y,m_content_items_total,m_visible_items_total))
      return(false);
//--- Hide the element
   m_content_scrollv.Hide();
   return(true);
  }
//+------------------------------------------------------------------+
//| Create cursor of changing the width                              |
//+------------------------------------------------------------------+
bool CTreeView::CreateXResizePointer(void)
  {
//--- Leave, if changing the width of the content area is not needed or
//    tab items mode is enabled
   if(!m_resize_list_area_mode || m_tab_items_mode)
      return(true);
//--- Setting up properties
   m_x_resize.XGap(12);
   m_x_resize.YGap(9);
   m_x_resize.Id(CElementBase::Id());
   m_x_resize.Type(MP_X_RESIZE);
//--- Creating an element
   if(!m_x_resize.CreatePointer(m_chart_id,m_subwin))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Returns tree view item pointer by the index                      |
//+------------------------------------------------------------------+
CTreeItem *CTreeView::ItemPointer(const int index)
  {
   int array_size=::ArraySize(m_items);
//--- If there is no item in the context menu, report
   if(array_size<1)
     {
      ::Print(__FUNCTION__," > This method is to be called, "
              "if the context menu has at least one item!");
     }
//--- Adjustment in case the range has been exceeded
   int i=(index>=array_size)? array_size-1 :(index<0)? 0 : index;
//--- Return the pointer
   return(::GetPointer(m_items[i]));
  }
//+------------------------------------------------------------------+
//| Returns content area item pointer by the index                   |
//+------------------------------------------------------------------+
CTreeItem *CTreeView::ContentItemPointer(const int index)
  {
   int array_size=::ArraySize(m_content_items);
//--- If there is no item in the context menu, report
   if(array_size<1)
     {
      ::Print(__FUNCTION__," > This method is to be called, "
              "if the context menu has at least one item!");
     }
//--- Adjustment in case the range has been exceeded
   int i=(index>=array_size)? array_size-1 :(index<0)? 0 : index;
//--- Return the pointer
   return(::GetPointer(m_content_items[i]));
  }
//+------------------------------------------------------------------+
//| Add item to the common array of the tree view                    |
//+------------------------------------------------------------------+
void CTreeView::AddItem(const int list_index,const int prev_node_list_index,const string item_text,const string path_bmp,const int item_index,
                        const int node_level,const int prev_node_item_index,const int items_total,const int folders_total,const bool item_state,const bool is_folder)
  {
//--- Reserve size of the array
   int reserve_size=10000;
//--- Increase the array size by one element
   int array_size =::ArraySize(m_items);
   m_items_total  =array_size+1;
   ::ArrayResize(m_items,m_items_total,reserve_size);
   ::ArrayResize(m_t_list_index,m_items_total,reserve_size);
   ::ArrayResize(m_t_prev_node_list_index,m_items_total,reserve_size);
   ::ArrayResize(m_t_item_text,m_items_total,reserve_size);
   ::ArrayResize(m_t_path_bmp,m_items_total,reserve_size);
   ::ArrayResize(m_t_item_index,m_items_total,reserve_size);
   ::ArrayResize(m_t_node_level,m_items_total,reserve_size);
   ::ArrayResize(m_t_prev_node_item_index,m_items_total,reserve_size);
   ::ArrayResize(m_t_items_total,m_items_total,reserve_size);
   ::ArrayResize(m_t_folders_total,m_items_total,reserve_size);
   ::ArrayResize(m_t_item_state,m_items_total,reserve_size);
   ::ArrayResize(m_t_is_folder,m_items_total,reserve_size);
//--- Store the values of passed parameters
   m_t_list_index[array_size]           =list_index;
   m_t_prev_node_list_index[array_size] =prev_node_list_index;
   m_t_item_text[array_size]            =item_text;
   m_t_path_bmp[array_size]             =path_bmp;
   m_t_item_index[array_size]           =item_index;
   m_t_node_level[array_size]           =node_level;
   m_t_prev_node_item_index[array_size] =prev_node_item_index;
   m_t_items_total[array_size]          =items_total;
   m_t_folders_total[array_size]        =folders_total;
   m_t_item_state[array_size]           =item_state;
   m_t_is_folder[array_size]            =is_folder;
  }
//+------------------------------------------------------------------+
//| Add control to the array of the specified tab                    |
//+------------------------------------------------------------------+
void CTreeView::AddToElementsArray(const int tab_index,CElement &object)
  {
//--- Checking for exceeding the array range
   int array_size=::ArraySize(m_tab_items);
   if(array_size<1 || tab_index<0 || tab_index>=array_size)
      return;
//--- Add pointer of the passed control to array of the specified tab
   int size=::ArraySize(m_tab_items[tab_index].elements);
   ::ArrayResize(m_tab_items[tab_index].elements,size+1);
   m_tab_items[tab_index].elements[size]=::GetPointer(object);
  }
//+------------------------------------------------------------------+
//| Show controls of the selected tab item only                      |
//+------------------------------------------------------------------+
void CTreeView::ShowTabElements(void)
  {
//--- Leave, if the control is hidden or tab item mode is disabled
   if(!CElementBase::IsVisible() || !m_tab_items_mode)
      return;
//--- Index of the selected tab
   int tab_index=WRONG_VALUE;
//--- Determine the index of the selected tab
   int tab_items_total=::ArraySize(m_tab_items);
   for(int i=0; i<tab_items_total; i++)
     {
      if(m_tab_items[i].list_index==m_selected_item_index)
        {
         tab_index=i;
         break;
        }
     }
//--- Show controls of the selected tab only
   for(int i=0; i<tab_items_total; i++)
     {
      //--- Get the number of controls attached to the tab
      int tab_elements_total=::ArraySize(m_tab_items[i].elements);
      //--- If this tab item is selected
      if(i==tab_index)
        {
         //--- Display the controls
         for(int j=0; j<tab_elements_total; j++)
            m_tab_items[i].elements[j].Reset();
        }
      else
        {
         //--- Hide the controls
         for(int j=0; j<tab_elements_total; j++)
            m_tab_items[i].elements[j].Hide();
        }
     }
  }
//+------------------------------------------------------------------+
//| return the current full path                                     |
//+------------------------------------------------------------------+
string CTreeView::CurrentFullPath(void)
  {
//--- To generate a directory to the selected item
   string path="";
//--- Index of the selected item
   int li=m_selected_item_index;
//--- Array for generating the directory
   string path_parts[];
//--- Get the description (text) of the selected tree view item,
//    but only if it is a folder
   if(m_t_is_folder[li])
     {
      ::ArrayResize(path_parts,1);
      path_parts[0]=m_t_item_text[li];
     }
//--- Iterate over the full list
   int total=::ArraySize(m_t_list_index);
   for(int i=0; i<total; i++)
     {
      //--- Only folders are considered.
      //    If it is a file, go to the next item.
      if(!m_t_is_folder[i])
         continue;
      //--- If (1) index of the general list matches the index of the general list of the previous node and
      //    (2) index of the local list item matches the index of the previous node item and
      //    (3) the sequence of node levels is maintained
      if(m_t_list_index[i]==m_t_prev_node_list_index[li] &&
         m_t_item_index[i]==m_t_prev_node_item_index[li] &&
         m_t_node_level[i]==m_t_node_level[li]-1)
        {
         //--- Increase the array by one element and store the item description
         int sz=::ArraySize(path_parts);
         ::ArrayResize(path_parts,sz+1);
         path_parts[sz]=m_t_item_text[i];
         //--- Store the index for subsequent checking
         li=i;
         //--- If the zero level of the node is reached, leave the cycle
         if(m_t_node_level[i]==0 || i<=0)
            break;
         // --- Reset the cycle counter
         i=-1;
        }
     }
//--- Generate a string - the full path to the selected item in the tree view
   total=::ArraySize(path_parts);
   for(int i=total-1; i>=0; i--)
      ::StringAdd(path,path_parts[i]+"\\");
//--- If the selected item in the tree view is a folder
   if(m_t_is_folder[m_selected_item_index])
     {
      m_selected_item_file_name="";
      //--- If the item in the content area is selected
      if(m_selected_content_item_index>0)
        {
         //--- If the selected item is a file, store its name
         if(!m_t_is_folder[m_c_tree_list_index[m_selected_content_item_index]])
            m_selected_item_file_name=m_c_item_text[m_selected_content_item_index];
        }
     }
//--- If the selected item in the tree view is a file
   else
//--- Store its name
      m_selected_item_file_name=m_t_item_text[m_selected_item_index];
//--- Return directory
   return(path);
  }
//+------------------------------------------------------------------+
//| Changing the object color when the cursor is hovering over it    |
//+------------------------------------------------------------------+
void CTreeView::ChangeObjectsColor(void)
  {
//--- Leave, if the mode of highlighting on mouseover is disabled or 
//    the left mouse button is pressed
   if(!m_lights_hover || m_mouse.LeftButtonState())
      return;
//--- If the focus is on the area of changing the content area
   if(m_x_resize.IsVisible())
     {
      //--- Reset the item colors and leave
      ResetColors();
      return;
     }
//--- Changing color in the tree view area
   ChangeTreeViewObjectsColor();
//--- Changing color in the content area
   ChangeContentObjectsColor();
  }
//+------------------------------------------------------------------+
//| Changing color in the tree view area                             |
//+------------------------------------------------------------------+
void CTreeView::ChangeTreeViewObjectsColor(void)
  {
//--- If not in focus, reset colors and leave
   if(!m_area.MouseFocus())
     {
      ResetTreeViewColors();
      m_prev_t_item_index_focus=WRONG_VALUE;
      return;
     }
//--- If entered the list view again
   if(m_prev_t_item_index_focus==WRONG_VALUE)
     {
      //--- The color of items in the tree view
      int items_total=::ArraySize(m_td_list_index);
      for(int i=0; i<items_total; i++)
        {
         int li=m_td_list_index[i];
         if(li==m_selected_item_index)
            continue;
         //--- If the item is in focus, change the color
         if(m_items[li].MouseFocus())
           {
            m_items[li].ChangeObjectsColor();
            //--- Store the row
            m_prev_t_item_index_focus=li;
            break;
           }
        }
     }
   else
     {
      //--- Check the focus on the current row
      bool condition=m_items[m_prev_t_item_index_focus].MouseFocus();
      //--- If moved to another item
      if(!condition)
        {
         //--- Reset the color of the previous item, if the item is not selected
         if(m_prev_t_item_index_focus!=m_selected_item_index)
            m_items[m_prev_t_item_index_focus].ChangeObjectsColor();
         //---
         m_prev_t_item_index_focus=WRONG_VALUE;
        }
     }
  }
//+------------------------------------------------------------------+
//| Changing color in the content area                               |
//+------------------------------------------------------------------+
void CTreeView::ChangeContentObjectsColor(void)
  {
//--- Leave, if the content area is not needed
   if(m_content_area_width<0 || !m_show_item_content)
      return;
//--- If not in focus, reset colors and leave
   if(!m_content_area.MouseFocus())
     {
      ResetContentAreaColors();
      m_prev_c_item_index_focus=WRONG_VALUE;
      return;
     }
//--- If entered the list view again
   if(m_prev_c_item_index_focus==WRONG_VALUE)
     {
      //--- The color of items in the content list
      int cd_items_total=::ArraySize(m_cd_list_index);
      for(int i=0; i<cd_items_total; i++)
        {
         int li=m_cd_list_index[i];
         if(li==m_selected_content_item_index)
            continue;
         //--- If the item is in focus, change the color
         if(m_content_items[li].MouseFocus())
           {
            m_content_items[li].ChangeObjectsColor();
            //--- Store the row
            m_prev_c_item_index_focus=li;
            break;
           }
        }
     }
   else
     {
      //--- Check the focus on the current row
      bool condition=m_content_items[m_prev_c_item_index_focus].MouseFocus();
      //--- If moved to another item
      if(!condition)
        {
         //--- Reset the color of the previous item, if the item is not selected
         if(m_prev_c_item_index_focus!=m_selected_content_item_index)
            m_content_items[m_prev_c_item_index_focus].ChangeObjectsColor();
         //---
         m_prev_c_item_index_focus=WRONG_VALUE;
        }
     }
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CTreeView::Moving(const int x,const int y,const bool moving_mode=false)
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
      m_content_area.X(m_wnd.X2()-m_content_area.XGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::X(x+XGap());
      //--- Storing coordinates in the fields of the objects
      m_area.X(x+m_area.XGap());
      m_content_area.X(x+m_content_area.XGap());
     }
//--- If the anchored to the bottom
   if(m_anchor_bottom_window_side)
     {
      //--- Storing coordinates in the element fields
      CElementBase::Y(m_wnd.Y2()-YGap());
      //--- Storing coordinates in the fields of the objects
      m_area.Y(m_wnd.Y2()-m_area.YGap());
      m_content_area.Y(m_wnd.Y2()-m_content_area.YGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::Y(y+YGap());
      //--- Storing coordinates in the fields of the objects
      m_area.Y(y+m_area.YGap());
      m_content_area.Y(y+m_content_area.YGap());
     }
//--- Updating coordinates of graphical objects
   m_area.X_Distance(m_area.X());
   m_area.Y_Distance(m_area.Y());
   m_content_area.X_Distance(m_content_area.X());
   m_content_area.Y_Distance(m_content_area.Y());
  }
//+------------------------------------------------------------------+
//| Shows the element                                                |
//+------------------------------------------------------------------+
void CTreeView::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElementBase::IsVisible())
      return;
//--- Visible state
   CElementBase::IsVisible(true);
//--- Update coordinates of objects
   CTreeView::Moving(m_wnd.X(),m_wnd.Y(),true);
//--- Make all the objects visible
   m_area.Timeframes(OBJ_ALL_PERIODS);
   m_content_area.Timeframes(OBJ_ALL_PERIODS);
//--- Show the scrollbar if the number of list items does not fit
   if(m_items_total>m_visible_items_total)
      m_scrollv.Show();
//--- Update coordinates and sizes of lists
   ShiftTreeList();
   ShiftContentList();
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
//| Hides the element                                                |
//+------------------------------------------------------------------+
void CTreeView::Hide(void)
  {
//--- Leave, if the element is already hidden
   if(!CElementBase::IsVisible())
      return;
//--- Hide all objects
   m_area.Timeframes(OBJ_NO_PERIODS);
   m_content_area.Timeframes(OBJ_NO_PERIODS);
//--- Hide tree view items
   int total=::ArraySize(m_items);
   for(int i=0; i<total; i++)
      m_items[i].Hide();
//--- Hide content list items
   total=::ArraySize(m_content_items);
   for(int i=0; i<total; i++)
      m_content_items[i].Hide();
//--- Hide the scrollbars
   m_scrollv.Hide();
   m_content_scrollv.Hide();
//--- Adjust the scrollbar size
   m_scrollv.ChangeThumbSize(m_items_total,m_visible_items_total);
//--- Visible state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CTreeView::Reset(void)
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
void CTreeView::Delete(void)
  {
//--- Delete graphical objects
   m_area.Delete();
   m_content_area.Delete();
//---
   int total=::ArraySize(m_items);
   for(int i=0; i<total; i++)
      m_items[i].Delete();
//---
   total=::ArraySize(m_content_items);
   for(int i=0; i<total; i++)
      m_content_items[i].Delete();
//---
   m_x_resize.Delete();
//--- Emptying the control arrays
   ::ArrayFree(m_items);
   ::ArrayFree(m_content_items);
//---
   total=::ArraySize(m_tab_items);
   for(int i=0; i<total; i++)
      ::ArrayFree(m_tab_items[i].elements);
   ::ArrayFree(m_tab_items);
//---
   ::ArrayFree(m_t_prev_node_list_index);
   ::ArrayFree(m_t_list_index);
   ::ArrayFree(m_t_item_text);
   ::ArrayFree(m_t_path_bmp);
   ::ArrayFree(m_t_item_index);
   ::ArrayFree(m_t_node_level);
   ::ArrayFree(m_t_prev_node_item_index);
   ::ArrayFree(m_t_items_total);
   ::ArrayFree(m_t_folders_total);
   ::ArrayFree(m_t_item_state);
   ::ArrayFree(m_t_is_folder);
//---
   ::ArrayFree(m_td_list_index);
//---
   ::ArrayFree(m_c_list_index);
   ::ArrayFree(m_c_item_text);
//---
   ::ArrayFree(m_cd_item_text);
   ::ArrayFree(m_cd_list_index);
   ::ArrayFree(m_cd_tree_list_index);
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
//--- Initializing of variables by default values
   CElementBase::IsVisible(true);
   m_selected_item_index=WRONG_VALUE;
   m_selected_content_item_index=WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Seth the priorities                                              |
//+------------------------------------------------------------------+
void CTreeView::SetZorders(void)
  {
   m_area.Z_Order(m_zorder);
   int items_total=::ArraySize(m_t_list_index);
   for(int i=0; i<items_total; i++)
      m_items[i].SetZorders();
//--- Leave, if showing the item content is not needed or
//    if the content area is disabled
   if(!m_show_item_content || m_content_area_width<0)
      return;
//---
   int content_items_total=::ArraySize(m_c_list_index);
   for(int i=0; i<content_items_total; i++)
      m_content_items[i].SetZorders();
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CTreeView::ResetZorders(void)
  {
   m_area.Z_Order(0);
   int items_total=::ArraySize(m_t_list_index);
   for(int i=0; i<items_total; i++)
      m_items[i].ResetZorders();
//--- Leave, if there is no content list
   if(!m_show_item_content)
      return;
//---
   int content_items_total=::ArraySize(m_c_list_index);
   for(int i=0; i<content_items_total; i++)
      m_content_items[i].ResetZorders();
  }
//+------------------------------------------------------------------+
//| Reset color                                                      |
//+------------------------------------------------------------------+
void CTreeView::ResetColors(void)
  {
   ResetTreeViewColors();
   ResetContentAreaColors();
  }
//+------------------------------------------------------------------+
//| Resetting color in the tree view area                            |
//+------------------------------------------------------------------+
void CTreeView::ResetTreeViewColors(void)
  {
   int items_total=::ArraySize(m_td_list_index);
   for(int i=0; i<items_total; i++)
     {
      int li=m_td_list_index[i];
      if(li!=m_selected_item_index)
         m_items[li].ResetColors();
     }
  }
//+------------------------------------------------------------------+
//| Resetting color in the content area                              |
//+------------------------------------------------------------------+
void CTreeView::ResetContentAreaColors(void)
  {
//--- Leave, if showing the item content is not needed or
//    if the content area is disabled
   if(!m_show_item_content || m_content_area_width<0)
      return;
//---
   int content_items_total=::ArraySize(m_cd_list_index);
   for(int i=0; i<content_items_total; i++)
     {
      int li=m_cd_list_index[i];
      if(li!=m_selected_content_item_index)
         m_content_items[li].ResetColors();
     }
  }
//+------------------------------------------------------------------+
//| Clicking the item list minimization/maximization button          |
//+------------------------------------------------------------------+
bool CTreeView::OnClickItemArrow(const string clicked_object)
  {
//--- Leave, if it has a different object name
   if(::StringFind(clicked_object,CElementBase::ProgramName()+"_0_treeitem_arrow_",0)<0)
      return(false);
//--- Get the identifier from the object name
   int id=CElementBase::IdFromObjectName(clicked_object);
//--- Leave, if the identifiers do not match
   if(id!=CElementBase::Id())
      return(false);
//--- Get the index of the item in the general list
   int list_index=CElementBase::IndexFromObjectName(clicked_object);
//--- Get the state of the item arrow and set the opposite one
   m_t_item_state[list_index]=!m_t_item_state[list_index];
   ((CChartObjectBmpLabel*)m_items[list_index].Object(1)).State(m_t_item_state[list_index]);
//--- Update the tree view
   UpdateTreeViewList();
//--- Calculate the location of teh scrollbar slider
   m_scrollv.MovingThumb(m_scrollv.CurrentPos());
//--- Show controls of the selected tab item
   ShowTabElements();
   return(true);
  }
//+------------------------------------------------------------------+
//| Clicking a tree view item                                        |
//+------------------------------------------------------------------+
bool CTreeView::OnClickItem(const string clicked_object)
  {
//--- Leave, if the scrollbar is active
   if(m_scrollv.ScrollState() || m_content_scrollv.ScrollState())
      return(false);
//--- Leave, if it has a different object name
   if(::StringFind(clicked_object,CElementBase::ProgramName()+"_0_treeitem_area_",0)<0)
      return(false);
//--- Get the identifier from the object name
   int id=CElementBase::IdFromObjectName(clicked_object);
//--- Leave, if the identifiers do not match
   if(id!=CElementBase::Id())
      return(false);
//--- Get the current position of the scrollbar slider
   int v=m_scrollv.CurrentPos();
//--- Iterate over the list
   for(int r=0; r<m_visible_items_total; r++)
     {
      //--- Check to prevent exceeding the array range
      if(v>=0 && v<m_items_total)
        {
         //--- Get the general index of the item
         int li=m_td_list_index[v];
         //--- If this list view item was selected
         if(m_items[li].Object(0).Name()==clicked_object)
           {
            //--- Leave, if this item was already highlighted
            if(li==m_selected_item_index)
               return(false);
            //--- If the tab items mode is enabled and the content display mode is disabled,
            //    do not highlight the items without a list
            if(m_tab_items_mode && !m_show_item_content)
              {
               //--- If the current item does not contain a list, stop the cycle
               if(m_t_items_total[li]>0)
                  break;
              }
            //--- Set the color to the previous highlighted item
            m_items[m_selected_item_index].HighlightItemState(false);
            //--- Store the index for the current item and change its color
            m_selected_item_index=li;
            m_items[li].HighlightItemState(true);
            break;
           }
         v++;
        }
     }
//--- Reset colors in the content area
   if(m_selected_content_item_index>=0)
      m_content_items[m_selected_content_item_index].HighlightItemState(false);
//--- Reset the highlighted item
   m_selected_content_item_index=WRONG_VALUE;
//--- Update the content list
   UpdateContentList();
//--- Calculate the location of teh scrollbar slider
   m_scrollv.MovingThumb(m_scrollv.CurrentPos());
//--- Adjust the content list
   ShiftContentList();
//--- Show controls of the selected tab item
   ShowTabElements();
//--- Send a message about selecting a new directory in the tree view
   ::EventChartCustom(m_chart_id,ON_CHANGE_TREE_PATH,0,0,"");
   return(true);
  }
//+------------------------------------------------------------------+
//| Clicking the item in the content list                            |
//+------------------------------------------------------------------+
bool CTreeView::OnClickContentListItem(const string clicked_object)
  {
//--- Leave, if the content area is disabled
   if(m_content_area_width<0)
      return(false);
//--- Leave, if the scrollbar is active
   if(m_scrollv.ScrollState() || m_content_scrollv.ScrollState())
      return(false);
//--- Leave, if it has a different object name
   if(::StringFind(clicked_object,CElementBase::ProgramName()+"_1_treeitem_area_",0)<0)
      return(false);
//--- Get the identifier from the object name
   int id=CElementBase::IdFromObjectName(clicked_object);
//--- Leave, if the identifiers do not match
   if(id!=CElementBase::Id())
      return(false);
//--- Get the number of items in the content list
   int content_items_total=::ArraySize(m_cd_list_index);
//--- Get the current position of the scrollbar slider
   int v=m_content_scrollv.CurrentPos();
//--- Iterate over the list
   for(int r=0; r<m_visible_items_total; r++)
     {
      //--- Check to prevent exceeding the array range
      if(v>=0 && v<content_items_total)
        {
         //--- Get the general index of the list
         int li=m_cd_list_index[v];
         //--- If this list view item was selected
         if(m_content_items[li].Object(0).Name()==clicked_object)
           {
            //--- Set the color to the previous highlighted item
            if(m_selected_content_item_index>=0)
               m_content_items[m_selected_content_item_index].HighlightItemState(false);
            //--- Store the index for the current item and change the color
            m_selected_content_item_index=li;
            m_content_items[li].HighlightItemState(true);
           }
         v++;
        }
     }
//--- Send a message about selecting a new directory in the tree view
   ::EventChartCustom(m_chart_id,ON_CHANGE_TREE_PATH,0,0,"");
   return(true);
  }
//+------------------------------------------------------------------+
//| Generates an array of tab items                                  |
//+------------------------------------------------------------------+
void CTreeView::GenerateTabItemsArray(void)
  {
//--- Leave, if the tab item mode is disabled
   if(!m_tab_items_mode)
      return;
//--- Add only empty items to the array of tab items
   int items_total=::ArraySize(m_items);
   for(int i=0; i<items_total; i++)
     {
      //--- If this item contains other items, go to the next\
      if(m_t_items_total[i]>0)
         continue;
      //--- Increase the size of the tab items array by one element
      int array_size=::ArraySize(m_tab_items);
      ::ArrayResize(m_tab_items,array_size+1);
      //--- Store the general index of the item
      m_tab_items[array_size].list_index=i;
     }
//--- If item content display is disabled
   if(!m_show_item_content)
     {
      //--- Get the size of the tab items array
      int tab_items_total=::ArraySize(m_tab_items);
      //--- Adjust the index if out of range
      if(m_selected_item_index>=tab_items_total)
         m_selected_item_index=tab_items_total-1;
      //--- Disable highlighting the current item in the list
      m_items[m_selected_item_index].HighlightItemState(false);
      //--- Index of the selected tab
      int tab_index=m_tab_items[m_selected_item_index].list_index;
      m_selected_item_index=tab_index;
      //--- Highlight this item
      m_items[tab_index].HighlightItemState(true);
     }
  }
//+------------------------------------------------------------------+
//| Determine and set the node borders                               |
//+------------------------------------------------------------------+
void CTreeView::SetNodeLevelBoundaries(void)
  {
//--- Determine the minimum and maximum node levels
   m_min_node_level =m_t_node_level[::ArrayMinimum(m_t_node_level)];
   m_max_node_level =m_t_node_level[::ArrayMaximum(m_t_node_level)];
  }
//+------------------------------------------------------------------+
//| Determine and set the size of the root directory                 |
//+------------------------------------------------------------------+
void CTreeView::SetRootItemsTotal(void)
  {
//--- Determine the number of items in the root directory
   int items_total=::ArraySize(m_items);
   for(int i=0; i<items_total; i++)
     {
      //--- If this is the minimum level, increase the counter
      if(m_t_node_level[i]==m_min_node_level)
         m_root_items_total++;
     }
  }
//+------------------------------------------------------------------+
//| Moves the tree view along the scrollbar                          |
//+------------------------------------------------------------------+
void CTreeView::ShiftTreeList(void)
  {
//--- Hide all items in the tree view
   int items_total=ItemsTotal();
   for(int i=0; i<items_total; i++)
      m_items[i].Hide();
//--- If a scrollbar is required
   bool is_scroll=m_items_total>m_visible_items_total;
//--- Calculating the width of the list view items
   int w=(is_scroll)? m_area.XSize()-m_scrollv.ScrollWidth()-1 : m_area.XSize()-2;
//--- Determine the scrollbar position
   int v=(is_scroll)? m_scrollv.CurrentPos() : 0;
   m_scrollv.CurrentPos(v);
//--- X coordinate
   int x=m_area.X()+1;
//--- The Y coordinate of the first item of the tree view
   int y=m_y+1;
//---
   for(int r=0; r<m_visible_items_total; r++)
     {
      //--- Check to prevent exceeding the array range
      if(v>=0 && v<m_items_total)
        {
         //--- Calculate the Y coordinate
         y=(r>0)? y+m_item_y_size-1 : y;
         //--- Get the general index of the tree view item
         int li=m_td_list_index[v];
         //--- Set the coordinates and width
         m_items[li].UpdateX(CElement::CalculateXGap(x));
         m_items[li].UpdateY(CElement::CalculateYGap(y));
         m_items[li].UpdateWidth(w);
         //--- Highlight the selected row
         if(li==m_selected_item_index)
            m_items[li].HighlightItemState(true);
         //--- Show the item
         m_items[li].Show();
         v++;
        }
     }
//--- Redraw the scrollbar
   if(is_scroll)
      m_scrollv.Reset();
  }
//+------------------------------------------------------------------+
//| Moves the tree view along the scrollbar                          |
//+------------------------------------------------------------------+
void CTreeView::ShiftContentList(void)
  {
//--- Leave, if (1) showing the item content is not needed or
//    (2) if the content area is disabled
   if(!m_show_item_content || m_content_area_width<0)
      return;
//--- Hide all content list items
   m_content_items_total=ContentItemsTotal();
   for(int i=0; i<m_content_items_total; i++)
      m_content_items[i].Hide();
//--- Redraw the content area background
   m_content_area.Timeframes(OBJ_NO_PERIODS);
   m_content_area.Timeframes(OBJ_ALL_PERIODS);
//--- Get the number of items displayed in the content list
   int total=::ArraySize(m_cd_list_index);
//--- If a scrollbar is required
   bool is_scroll=total>m_visible_items_total;
//--- Calculating the width of the list view items
   int w=(is_scroll) ? m_content_area.XSize()-m_content_scrollv.ScrollWidth()-1 : m_content_area.XSize()-2;
//--- Determine the scrollbar position
   int v=(is_scroll) ?  m_content_scrollv.CurrentPos() : 0;
   m_content_scrollv.CurrentPos(v);
//--- X coordinate
   int x=m_content_area.X()+1;
//--- The Y coordinate of the first item of the tree view
   int y=m_y+1;
//--- 
   for(int r=0; r<m_visible_items_total; r++)
     {
      //--- Check to prevent exceeding the array range
      if(v>=0 && v<total)
        {
         //--- Calculate the Y coordinate
         y=(r>0)? y+m_item_y_size-1 : y;
         //--- Get the general index of the tree view item
         int li=m_cd_list_index[v];
         //--- Set the coordinates and width
         m_content_items[li].UpdateX(CElement::CalculateXGap(x));
         m_content_items[li].UpdateY(CElement::CalculateYGap(y));
         m_content_items[li].UpdateWidth(w);
         //--- Highlight the selected row
         if(li==m_selected_content_item_index)
            m_content_items[li].HighlightItemState(true);
         //--- Show the item
         m_content_items[li].Show();
         v++;
        }
     }
//--- Redraw the scrollbar
   if(is_scroll)
      m_content_scrollv.Reset();
  }
//+------------------------------------------------------------------+
//| Fast forward of the lists                                        |
//+------------------------------------------------------------------+
void CTreeView::FastSwitching(void)
  {
//--- Leave, if outside of the element area or the mode of changing the content area width is activated
   if(!CElementBase::MouseFocus() || m_x_resize.State())
      return;
//--- Return counter to initial value if the mouse button is released если кнопка мыши отжата
   if(!m_mouse.LeftButtonState())
      m_timer_counter=SPIN_DELAY_MSC;
//--- If the mouse button is pressed down
   else
     {
      //--- Increase the counter by the set step
      m_timer_counter+=TIMER_STEP_MSC;
      //--- Exit if below zero
      if(m_timer_counter<0)
         return;
      //--- If scrolling up
      if(m_scrollv.ScrollIncState())
        {
         m_scrollv.OnClickScrollInc(m_scrollv.ScrollIncName());
         ShiftTreeList();
        }
      //--- If scrolling down
      else if(m_scrollv.ScrollDecState())
        {
         m_scrollv.OnClickScrollDec(m_scrollv.ScrollDecName());
         ShiftTreeList();
        }
      //--- Leave, if the content area is disabled
      if(m_content_area_width<0)
         return;
      //--- If scrolling up
      if(m_content_scrollv.ScrollIncState())
        {
         m_content_scrollv.OnClickScrollInc(m_content_scrollv.ScrollIncName());
         ShiftContentList();
        }
      //--- If scrolling down
      else if(m_content_scrollv.ScrollDecState())
        {
         m_content_scrollv.OnClickScrollDec(m_content_scrollv.ScrollDecName());
         ShiftContentList();
        }
     }
  }
//+------------------------------------------------------------------+
//| Controls the width of the lists                                  |
//+------------------------------------------------------------------+
void CTreeView::ResizeListArea(const int x,const int y)
  {
//--- Leave, (1) if changing the width of the content area is not needed or
//    (2) if the content area is disabled or (3) tab items mode is enabled
   if(!m_resize_list_area_mode || m_content_area_width<0 || m_tab_items_mode)
      return;
//--- Leave, if the scrollbar is active
   if(m_scrollv.ScrollState())
      return;
//--- Check readiness to change the width of lists
   CheckXResizePointer(x,y);
//--- If the cursor is disabled, unblock the form
   if(!m_x_resize.State())
     {
      //--- The form can be unblocked only by the one who has blocked it
      if(m_wnd.IsLocked() && CElement::CheckIdActivatedElement())
        {
         m_wnd.IsLocked(false);
         m_wnd.IdActivatedElement(WRONG_VALUE);
         return;
        }
     }
   else
     {
      //--- Checking for exceeding the specified limits 
      if(!CheckOutOfArea(x,y))
         return;
      //--- Block the form and store the active element identifier
      m_wnd.IsLocked(true);
      m_wnd.IdActivatedElement(CElementBase::Id());
      //--- Set the X-coordinate to the object at the center of the mouse cursor
      m_x_resize.UpdateX(x);
      //--- The Y-coordinate is set only if the control area was not exceeded
      if(y>m_area.Y() && y<m_area.Y2())
         m_x_resize.UpdateY(y);
      //--- Update the tree view width
      UpdateTreeListWidth(x);
      //--- Update the width of the content list
      UpdateContentListWidth(x);
      //--- Update coordinates and sizes of lists
      ShiftTreeList();
      ShiftContentList();
      //--- Redraw cursor
      m_x_resize.Reset();
     }
  }
//+------------------------------------------------------------------+
//| Check readiness to change the width of lists                     |
//+------------------------------------------------------------------+
void CTreeView::CheckXResizePointer(const int x,const int y)
  {
//--- If the pointer is not activated, but the mouse cursor is in its area
   if(!m_x_resize.State() && 
      y>m_area.Y() && y<m_area.Y2() && x>m_area.X2()-2 && x<m_area.X2()+3)
     {
      //--- Update the cursor coordinates and make it visible
      m_x_resize.Moving(x,y);
      m_x_resize.Show();
      //--- If the mouse left button is pressed, activate the pointer
      if(m_mouse.LeftButtonState())
         m_x_resize.State(true);
     }
   else
     {
      //--- If the left mouse button is released
      if(!m_mouse.LeftButtonState())
        {
         //--- Deactivate and hide the pointer
         m_x_resize.State(false);
         m_x_resize.Hide();
        }
     }
  }
//+------------------------------------------------------------------+
//| Checking for exceeding the limits                                |
//+------------------------------------------------------------------+
bool CTreeView::CheckOutOfArea(const int x,const int y)
  {
//--- Limit
   int area_limit=80;
//--- If the horizontal limit of the control is exceeded ...
   if(x<m_area.X()+area_limit || x>m_content_area.X2()-area_limit)
     {
      // ... move the pointer vertically only, without exceeding the limits
      if(y>m_area.Y() && y<m_area.Y2())
         m_x_resize.UpdateY(y);
      //--- Do not change the width of the lists
      return(false);
     }
//--- Change the width of the lists
   return(true);
  }
//+------------------------------------------------------------------+
//| Update the tree view width                                       |
//+------------------------------------------------------------------+
void CTreeView::UpdateTreeListWidth(const int x)
  {
//--- Calculate and set the width of the tree view
   m_area.X_Size(x-m_area.X());
   m_area.XSize(m_area.X_Size());
//--- Calculate and set the width of the items in the tree view, taking the scrollbars into account
   int l_w=(m_items_total>m_visible_items_total) ? m_area.XSize()-m_scrollv.ScrollWidth()-4 : m_area.XSize()-1;
   int items_total=::ArraySize(m_items);
   for(int i=0; i<items_total; i++)
      m_items[i].UpdateWidth(l_w);
//--- Calculate and set the coordinates for the scrollbar of the tree view
   m_scrollv.XDistance(m_area.X2()-m_scrollv.ScrollWidth());
  }
//+------------------------------------------------------------------+
//| Update the list width in the content area                        |
//+------------------------------------------------------------------+
void CTreeView::UpdateContentListWidth(const int x)
  {
//--- Calculate and set the X coordinate, indent and width for the content area
   int l_x=m_area.X2()-1;
   m_content_area.X(l_x);
   m_content_area.X_Distance(l_x);
   m_content_area.XGap(CElement::CalculateXGap(l_x));
   m_content_area.XSize(CElementBase::X2()-m_content_area.X());
   m_content_area.X_Size(m_content_area.XSize());
//--- Calculate and set the X coordinate and width for items in the content list
   l_x=m_content_area.X()+1;
   int l_w=(m_content_items_total>m_visible_items_total) ? m_content_area.XSize()-m_content_scrollv.ScrollWidth()-4 : m_content_area.XSize()-2;
   int total=::ArraySize(m_content_items);
   for(int i=0; i<total; i++)
     {
      m_content_items[i].UpdateX(CElement::CalculateXGap(l_x));
      m_content_items[i].UpdateWidth(l_w);
     }
  }
//+------------------------------------------------------------------+
//| Add item to the array of the items displayed                     |
//| in the tree view                                                 |
//+------------------------------------------------------------------+
void CTreeView::AddDisplayedTreeItem(const int list_index)
  {
//--- Increase the array size by one element
   int array_size=::ArraySize(m_td_list_index);
   ::ArrayResize(m_td_list_index,array_size+1);
//--- Store the values of passed parameters
   m_td_list_index[array_size]=list_index;
  }
//+------------------------------------------------------------------+
//| Update the tree view                                             |
//+------------------------------------------------------------------+
void CTreeView::UpdateTreeViewList(void)
  {
//--- Arrays to control the sequence of items:
   int l_prev_node_list_index[]; // general index of the list of the previous node
   int l_item_index[];           // local index of the item
   int l_items_total[];          // the number of items in a node
   int l_folders_total[];        // the number of folders in a node
//--- Define the initial size of the arrays
   int begin_size=m_max_node_level+2;
   ::ArrayResize(l_prev_node_list_index,begin_size);
   ::ArrayResize(l_item_index,begin_size);
   ::ArrayResize(l_items_total,begin_size);
   ::ArrayResize(l_folders_total,begin_size);
//--- Initialization of arrays
   ::ArrayInitialize(l_prev_node_list_index,-1);
   ::ArrayInitialize(l_item_index,-1);
   ::ArrayInitialize(l_items_total,-1);
   ::ArrayInitialize(l_folders_total,-1);
//--- Release the array of displayed tree view items
   ::ArrayFree(m_td_list_index);
//--- Counter of the local item indices
   int ii=0;
//--- To set the flag of the last item in the root directory
   bool end_list=false;
//--- Gather the displayed items to the array. The cycle will run as long as: 
//    1: the node counter is not greater than maximum;
//    2: the last item has not been reached (after checking all items nested in it);
//    3: program is not deleted by user.
   int items_total=::ArraySize(m_items);
   for(int nl=m_min_node_level; nl<=m_max_node_level && !end_list; nl++)
     {
      for(int i=0; i<items_total && !::IsStopped(); i++)
        {
         //--- If the "Show only folders" mode is enabled
         if(m_file_navigator_mode==FN_ONLY_FOLDERS)
           {
            //--- If this is a file, go to the next item
            if(!m_t_is_folder[i])
               continue;
           }
         //--- If (1) this is a different node or (2) the sequence of the local indices is not maintained,
         //    go to the next
         if(nl!=m_t_node_level[i] || m_t_item_index[i]<=l_item_index[nl])
            continue;
         //--- Go to the next point, if (1) currently not in the root directory and 
         //    (2) the general index of the list of the previous node is not equal to the one in memory
         if(nl>m_min_node_level && m_t_prev_node_list_index[i]!=l_prev_node_list_index[nl])
            continue;
         //--- Store the local item index, if the next is not less than the size of the local list
         if(m_t_item_index[i]+1>=l_items_total[nl])
            ii=m_t_item_index[i];
         //--- If the list of the current item is open
         if(m_t_item_state[i])
           {
            //--- Add the item to the array of the displayed tree view items
            AddDisplayedTreeItem(i);
            //--- Store the current values and go to the next node
            int n=nl+1;
            l_prev_node_list_index[n] =m_t_list_index[i];
            l_item_index[nl]          =m_t_item_index[i];
            l_items_total[n]          =m_t_items_total[i];
            l_folders_total[n]        =m_t_folders_total[i];
            //--- Zero the counter of the local indices of items
            ii=0;
            //--- Go to the next node
            break;
           }
         //--- Add the item to the array of the displayed tree view items
         AddDisplayedTreeItem(i);
         //--- Increase the counter of the local indices of items
         ii++;
         //--- If the last item in the root directory has been reached
         if(nl==m_min_node_level && ii>=m_root_items_total)
           {
            //--- Set the flag and complete the current cycle
            end_list=true;
            break;
           }
         //--- If the last item in the root directory has not been reached yet
         else if(nl>m_min_node_level)
           {
            //--- Get the number of items in the current node
            int total=(m_file_navigator_mode==FN_ONLY_FOLDERS)? l_folders_total[nl]: l_items_total[nl];
            //--- If this is not the last local index of the item, go to the next
            if(ii<total)
               continue;
            //--- If the last local index is reached, then 
            //    it is necessary to return to the previous node and continue from the item it left off
            while(true)
              {
               //--- Reset the values of the current node in the arrays listed below
               l_prev_node_list_index[nl] =-1;
               l_item_index[nl]           =-1;
               l_items_total[nl]          =-1;
               //--- Decrease the node counter, while the equality in the number of items in the local lists is preserved 
               //    or until the root directory is reached
               if(l_item_index[nl-1]+1>=l_items_total[nl-1])
                 {
                  if(nl-1==m_min_node_level)
                     break;
                  //---
                  nl--;
                  continue;
                 }
               //---
               break;
              }
            //--- Go to the previous node
            nl=nl-2;
            //--- Zero the counter of the local indices of items and go to the next node
            ii=0;
            break;
           }
        }
     }
//--- Redrawing control:
   RedrawTreeList();
  }
//+------------------------------------------------------------------+
//| Update the content list                                          |
//+------------------------------------------------------------------+
void CTreeView::UpdateContentList(void)
  {
//--- Index of the selected item
   int li=m_selected_item_index;
//--- Release the content list arrays
   ::ArrayFree(m_cd_item_text);
   ::ArrayFree(m_cd_list_index);
   ::ArrayFree(m_cd_tree_list_index);
//--- Generate a content list
   int items_total=::ArraySize(m_items);
   for(int i=0; i<items_total; i++)
     {
      //--- If the (1) node levels and (2) local indices of the items, and also
      //    (3) the index of the previous node match the index of the selected item
      if(m_t_node_level[i]==m_t_node_level[li]+1 && 
         m_t_prev_node_item_index[i]==m_t_item_index[li] &&
         m_t_prev_node_list_index[i]==li)
        {
         //--- Increase the arrays of the displayed content list items
         int size     =::ArraySize(m_cd_list_index);
         int new_size =size+1;
         ::ArrayResize(m_cd_item_text,new_size);
         ::ArrayResize(m_cd_list_index,new_size);
         ::ArrayResize(m_cd_tree_list_index,new_size);
         //--- Store the item text and the general index of the tree view to the arrays
         m_cd_item_text[size]       =m_t_item_text[i];
         m_cd_tree_list_index[size] =m_t_list_index[i];
        }
     }
//--- If the resulting list is not empty, fill the array of general indices of the content list
   int cd_items_total=::ArraySize(m_cd_list_index);
   if(cd_items_total>0)
     {
      //--- Item counter
      int c=0;
      //--- Iterate over the list
      int c_items_total=::ArraySize(m_c_list_index);
      for(int i=0; i<c_items_total; i++)
        {
         //--- If the description and general indices of the tree view items match
         if(m_c_item_text[i]==m_cd_item_text[c] && 
            m_c_tree_list_index[i]==m_cd_tree_list_index[c])
           {
            //--- Store the general content list index and go to the next
            m_cd_list_index[c]=m_c_list_index[i];
            c++;
            //--- Leave the cycle, if reached the end of the displayed list
            if(c>=cd_items_total)
               break;
           }
        }
     }
//--- Adjust the size of the scrollbar slider
   m_content_scrollv.ChangeThumbSize(cd_items_total,m_visible_items_total);
//--- Adjust the content list of the item
   ShiftContentList();
  }
//+------------------------------------------------------------------+
//| Redrawing control                                                |
//+------------------------------------------------------------------+
void CTreeView::RedrawTreeList(void)
  {
//--- Hide the element
   Hide();
//--- The Y coordinate of the first item of the tree view
   int y=m_y+1;
//--- Get the number of items
   m_items_total=::ArraySize(m_td_list_index);
//--- Adjust the scrollbar size
   m_scrollv.ChangeThumbSize(m_items_total,m_visible_items_total);
//--- Calculating the width of the tree view items
   int w=(m_items_total>m_visible_items_total) ? CElementBase::XSize()-m_scrollv.ScrollWidth() : CElementBase::XSize()-2;
//--- Set new values
   for(int i=0; i<m_items_total; i++)
     {
      //--- Calculate the Y coordinate for each item
      y=(i>0)? y+m_item_y_size-1 : y;
      //--- Get the general index of the list item
      int li=m_td_list_index[i];
      //--- Update coordinates and sizes
      m_items[li].UpdateY(CElement::CalculateYGap(y));
      m_items[li].UpdateWidth(w);
     }
//--- Display the control
   Show();
  }
//+------------------------------------------------------------------+
//| Checking for index of the selected item exceeding array range    |
//+------------------------------------------------------------------+
void CTreeView::CheckSelectedItemIndex(void)
  {
//--- If the index is not defined
   if(m_selected_item_index==WRONG_VALUE)
     {
      //--- The first list item will be selected
      m_selected_item_index=0;
      return;
     }
//--- Checking for exceeding the array range
   int array_size=::ArraySize(m_items);
   if(array_size<1 || m_selected_item_index<0 || m_selected_item_index>=array_size)
     {
      //--- The first list item will be selected
      m_selected_item_index=0;
      return;
     }
  }
//+------------------------------------------------------------------+
//| Change the width at the right edge of the form                   |
//+------------------------------------------------------------------+
void CTreeView::ChangeWidthByRightWindowSide(void)
  {
//--- Leave, if anchoring mode to the right side of the window is enabled
   if(m_anchor_right_window_side)
      return;
//--- Coordinates and sizes
   int x=0,w=0;
//--- Sizes
   int x_size=0;
//--- Calculate and set the new size
   x_size=m_wnd.X2()-m_content_area.X()-m_auto_xresize_right_offset;
   m_content_area_width=x_size;
   m_content_area.XSize(x_size);
   m_content_area.X_Size(x_size);
//--- Store the total width of the control
   CElementBase::XSize(m_area.XSize()+m_content_area.XSize()-1);
//--- Calculate and set the new coordinate for the vertical scrollbar
   x=m_content_area.X2()-m_content_scrollv.ScrollWidth();
   m_content_scrollv.XDistance(x);
//--- Get the number of items displayed in the content list
   int total=::ArraySize(m_cd_list_index);
//--- If a scrollbar is required
   bool is_scroll=total>m_visible_items_total;
//--- Calculate and set the width for items in the content list
   w=(is_scroll) ? m_content_area.XSize()-m_content_scrollv.ScrollWidth()-1 : m_content_area.XSize()-2;
   total=::ArraySize(m_content_items);
   for(int i=0; i<total; i++)
      m_content_items[i].UpdateWidth(w);
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
