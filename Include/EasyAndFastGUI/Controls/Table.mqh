//+------------------------------------------------------------------+
//|                                                        Table.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "Scrolls.mqh"
//+------------------------------------------------------------------+
//| Class for creating an edit box table                             |
//+------------------------------------------------------------------+
class CTable : public CElement
  {
private:
   //--- Objects for creating a table
   CRectLabel        m_area;
   CScrollV          m_scrollv;
   CScrollH          m_scrollh;
   CBmpLabel         m_sort_arrow;
   //--- Array of objects for the visible part of the table
   struct TEdits
     {
      CEdit             m_rows[];
     };
   TEdits            m_columns[];
   //--- Array of table values and properties
   struct TOptions
     {
      ENUM_DATATYPE     m_type;
      string            m_vrows[];
      uint              m_digits[];
      ENUM_ALIGN_MODE   m_text_align[];
      color             m_text_color[];
      color             m_cell_color[];
     };
   TOptions          m_vcolumns[];
   //--- The number of columns and rows (total and of visible part) of the table
   uint              m_rows_total;
   uint              m_columns_total;
   uint              m_visible_rows_total;
   uint              m_visible_columns_total;
   //--- Height of table rows
   int               m_row_y_size;
   //--- (1) Color of the background and (2) background frame of the table
   color             m_area_color;
   color             m_area_border_color;
   //--- Grid color
   color             m_grid_color;
   //--- Header background color
   color             m_headers_color;
   color             m_headers_color_hover;
   color             m_headers_color_pressed;
   //--- Header text color
   color             m_headers_text_color;
   //--- Icons for the sign of sorted data
   string            m_sort_arrow_file_on;
   string            m_sort_arrow_file_off;
   //--- Icon margins
   int               m_sort_arrow_x_gap;
   int               m_sort_arrow_y_gap;
   //--- Color of cells in different states
   color             m_cell_color;
   color             m_cell_color_hover;
   //--- Default color of cell texts
   color             m_cell_text_color;
   //--- Color of (1) the background and (2) selected row text
   color             m_selected_row_color;
   color             m_selected_row_text_color;
   //--- (1) Index and (2) text of the selected row
   int               m_selected_item;
   string            m_selected_item_text;
   //--- Editable table mode
   bool              m_read_only;
   //--- Mode of formatting in Zebra style
   color             m_is_zebra_format_rows;
   //--- Mode of highlighting rows when hovered
   bool              m_lights_hover;
   //--- Mode of sorting data according to columns
   bool              m_is_sort_mode;
   //--- Index of the sorted column (WRONG_VALUE – table is not sorted)
   int               m_is_sorted_column_index;
   //--- Last sorting direction
   ENUM_SORT_MODE    m_last_sort_direction;
   //--- Selectable row mode
   bool              m_selectable_row;
   //--- Fixation mode of the first row
   bool              m_fix_first_row;
   //--- Fixation mode of the first column
   bool              m_fix_first_column;
   //--- Default text alignment mode in edit boxes
   ENUM_ALIGN_MODE   m_align_mode;
   //--- Priorities of the left mouse button press
   int               m_zorder;
   int               m_cell_zorder;
   //--- Timer counter for fast forwarding the list view
   int               m_timer_counter;
   //--- To determine the moment of mouse cursor transition from one item to another
   int               m_prev_item_index_focus;
   //---
public:
                     CTable(void);
                    ~CTable(void);
   //--- Methods for creating table
   bool              CreateTable(const long chart_id,const int subwin,const int x,const int y);
   //---
private:
   bool              CreateCell(const int column_index,const int row_index,const int x,const int y,const int width);
   bool              CreateArea(void);
   bool              CreateCells(void);
   bool              CreateScrollV(void);
   bool              CreateScrollH(void);
   bool              CreateSignSortedData(void);
   //---
public:
   //--- Returns pointers to the scrollbars
   CScrollV         *GetScrollVPointer(void)                                    { return(::GetPointer(m_scrollv)); }
   CScrollH         *GetScrollHPointer(void)                                    { return(::GetPointer(m_scrollh)); }
   //--- Color of the (1) background and (2) frame of the table
   void              AreaColor(const color clr)                                 { m_area_color=clr;                }
   void              BorderColor(const color clr)                               { m_area_border_color=clr;         }
   //--- (1) Get and (2) set the fixation mode of the first row
   bool              FixFirstRow(void)                                    const { return(m_fix_first_row);         }
   void              FixFirstRow(const bool flag)                               { m_fix_first_row=flag;            }
   //--- (1) Get and (2) set the fixation mode of the first column
   bool              FixFirstColumn(void)                                 const { return(m_fix_first_column);      }
   void              FixFirstColumn(const bool flag)                            { m_fix_first_column=flag;         }
   //--- Colors of the (1) header background, (2) header text and (3) table grid
   void              HeadersColor(const color clr)                              { m_headers_color=clr;             }
   void              HeadersColorHover(const color clr)                         { m_headers_color_hover=clr;       }
   void              HeadersColorPressed(const color clr)                       { m_headers_color_pressed=clr;     }
   void              HeadersTextColor(const color clr)                          { m_headers_text_color=clr;        }
   void              GridColor(const color clr)                                 { m_grid_color=clr;                }
   //--- (1) Size of the rows along the Y axis, (2) color of the cells in different states
   void              RowYSize(const int y_size)                                 { m_row_y_size=y_size;             }
   void              CellColor(const color clr)                                 { m_cell_color=clr;                }
   void              CellColorHover(const color clr)                            { m_cell_color_hover=clr;          }
   //--- (1) "Read only" mode, (2) mode of formatting rows in Zebra style
   void              ReadOnly(const bool flag)                                  { m_read_only=flag;                }
   void              IsZebraFormatRows(const color clr)                         { m_is_zebra_format_rows=clr;      }
   //--- (1) Row highlighting when hovered, (2) sorting data, (3) selectable row modes
   void              LightsHover(const bool flag)                               { m_lights_hover=flag;             }
   void              IsSortMode(const bool flag)                                { m_is_sort_mode=flag;             }
   void              SelectableRow(const bool flag)                             { m_selectable_row=flag;           }
   //--- Returns the total number of (1) rows and (2) columns, (3) state of the scrollbar
   uint              RowsTotal(void)                                      const { return(m_rows_total);            }
   uint              ColumnsTotal(void)                                   const { return(::ArraySize(m_vcolumns)); }
   //--- Returns the number of (1) rows and (2) columns of the visible part of the table
   uint              VisibleRowsTotal(void)                               const { return(m_visible_rows_total);    }
   uint              VisibleColumnsTotal(void)                            const { return(::ArraySize(m_columns));  }
   //--- Returns the (1) index and (2) text of the selected row in the table, (3) text alignment mode in the cells
   int               SelectedItem(void)                                   const { return(m_selected_item);         }
   string            SelectedItemText(void)                               const { return(m_selected_item_text);    }
   void              TextAlign(const ENUM_ALIGN_MODE align_mode)                { m_align_mode=align_mode;         }
   //--- Set the (1) size of the table and (2) size of its visible part
   void              TableSize(const uint columns_total,const uint rows_total);
   void              VisibleTableSize(const uint visible_columns_total,const uint visible_rows_total);
   //--- Rebuilding the table
   void              Rebuilding(const int columns_total,const int visible_columns_total,const int rows_total,const int visible_rows_total);
   //--- Adds a column to the table
   void              AddColumn(void);
   //--- Adds a row to the table
   void              AddRow(void);
   //--- Clears the table (deletes all rows and columns)
   void              Clear(void);
   //--- Table scrolling: (1) vertical and (2) horizontal
   void              VerticalScrolling(const int pos=WRONG_VALUE);
   void              HorizontalScrolling(const int pos=WRONG_VALUE);

   //--- Set (1) the text alignment mode, (2) text color, (3) cell background color
   void              TextAlign(const uint column_index,const uint row_index,const ENUM_ALIGN_MODE mode);
   void              TextColor(const uint column_index,const uint row_index,const color clr);
   void              CellColor(const uint column_index,const uint row_index,const color clr);
   void              SetCellParameters(const uint column,const uint row,const string text,const color cell_color,const color text_color,const ENUM_ALIGN_MODE text_align);
   //--- Get/set the data type
   ENUM_DATATYPE     DataType(const uint column_index);
   void              DataType(const uint column_index,const ENUM_DATATYPE type);
   //--- Set the value to the specified table cell
   void              SetValue(const uint column_index,const uint row_index,const string value="",const uint digits=0);
   //--- Get the value from the specified table cell
   string            GetValue(const uint column_index,const uint row_index);
   //--- Select the specified row of the table
   void              SelectRow(const uint row_index);
   //--- Sort the data according to the specified column
   void              SortData(const uint column_index=0);
   //--- Update table data with consideration of the recent changes
   void              UpdateTable(void);
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
   //--- Handling clicking on the table headers
   bool              OnClickTableHeaders(const string clicked_object);
   //--- Handling the pressing on the table row
   bool              OnClickTableRow(const string clicked_object);
   //--- Handling entering the value in the table cell
   bool              OnEndEditCell(const string edited_object);
   //--- Retrieve column index from the object name
   int               ColumnIndexFromObjectName(const string object_name);
   //--- Retrieve row index from the object name
   int               RowIndexFromObjectName(const string object_name);
   //--- Highlight the selected row
   void              HighlightSelectedItem(void);

   //--- Quicksort method
   void              QuickSort(uint beg,uint end,uint column,const ENUM_SORT_MODE mode=SORT_ASCEND);
   //--- Checking the sorting conditions
   bool              CheckSortCondition(uint column_index,uint row_index,const string check_value,const bool direction);
   //--- Swap the values in the specified cells
   void              Swap(uint c,uint r1,uint r2);
   //--- Shifting the arrow-sign of sorted data
   void              ShiftSortArrow(const uint column);

   //--- Changing the table header color when hovered by mouse cursor
   void              HeaderColorByHover(void);
   //--- Change the table row color when hovered
   void              RowColorByHover(void);
   //--- Checking the focus of list view items when the cursor is hovering
   void              CheckItemFocus(void);
   //--- Formats the table in Zebra style
   void              ZebraFormatRows(void);

   //--- Fast forward the table data
   void              FastSwitching(void);
   
   //--- Checking for exceeding the range of columns
   bool              CheckOutOfColumnRange(const uint column_index);
   //--- Checking for exceeding the range of columns and rows
   bool              CheckOutOfRange(const uint column_index,const uint row_index);

   //--- Resizing the arrays of row
   void              RowResize(const uint column_index,const uint new_size);
   //--- Initialization of cells with default values
   void              CellInitialize(const uint column_index,const int row_index=WRONG_VALUE);
   //--- Calculation of the table size along the X axis
   int               CalculationXSize(void);
   //--- Calculation of the table size along the Y axis
   int               CalculationYSize(void);
   //--- Calculation of the X coordinate of the cell
   int               CalculationCellX(const int column_index=0);
   //--- Calculation of the Y coordinate of the cell
   int               CalculationCellY(const int row_index=0);
   //--- Calculation of the column width
   int               CalculationColumnWidth(const bool is_last_column=false);
   //--- Changing the width of columns
   void              ColumnsXResize(void);
   //--- Changing the table size along the Y axis
   void              YResize(void);

   //--- Change the width at the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTable::CTable(void) : m_row_y_size(18),
                       m_fix_first_row(false),
                       m_fix_first_column(false),
                       m_read_only(true),
                       m_is_sort_mode(false),
                       m_last_sort_direction(SORT_ASCEND),
                       m_is_sorted_column_index(WRONG_VALUE),
                       m_sort_arrow_x_gap(20),
                       m_sort_arrow_y_gap(6),
                       m_sort_arrow_file_on(""),
                       m_sort_arrow_file_off(""),
                       m_is_zebra_format_rows(clrNONE),
                       m_lights_hover(false),
                       m_selectable_row(false),
                       m_align_mode(ALIGN_LEFT),
                       m_rows_total(1),
                       m_columns_total(1),
                       m_visible_rows_total(1),
                       m_visible_columns_total(1),
                       m_selected_item(WRONG_VALUE),
                       m_selected_item_text(""),
                       m_headers_color(C'255,244,213'),
                       m_headers_color_hover(C'245,234,203'),
                       m_headers_color_pressed(C'235,224,193'),
                       m_headers_text_color(clrBlack),
                       m_area_color(clrLightGray),
                       m_area_border_color(C'240,240,240'),
                       m_grid_color(clrLightGray),
                       m_cell_color(clrWhite),
                       m_cell_color_hover(C'240,240,240'),
                       m_cell_text_color(clrBlack),
                       m_selected_row_color(C'51,153,255'),
                       m_selected_row_text_color(clrWhite),
                       m_prev_item_index_focus(WRONG_VALUE)
  {
//--- Store the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
//--- Set priorities of the left mouse button click
   m_zorder      =1;
   m_cell_zorder =2;
//--- Set the size of the table and its visible part
   TableSize(m_columns_total,m_rows_total);
   VisibleTableSize(m_visible_columns_total,m_visible_rows_total);
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTable::~CTable(void)
  {
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CTable::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
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
      //--- Checking the focus over elements
      CElementBase::CheckMouseFocus();
      //--- Shift the data, if the scrollbar is active
      if(m_scrollv.ScrollBarControl() || m_scrollh.ScrollBarControl())
         UpdateTable();
      //--- Highlight the selected row
      HighlightSelectedItem();
      //--- Reset color of the element, if not in focus and the left mouse button is released
      if(!CElementBase::MouseFocus() && !m_mouse.LeftButtonState())
        {
         ResetColors();
         return;
        }
      //--- Leave, if the form is blocked
      if(m_wnd.IsLocked())
         return;
      //--- Leave, if the scrollbar is in the process of moving
      if(m_scrollv.ScrollState() || m_scrollh.ScrollState())
         return;
      //--- Change the table row color when hovered
      RowColorByHover();
      //--- Change the table header color when hovered by mouse cursor
      HeaderColorByHover();
      return;
     }
//--- Handling the pressing on objects
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- Leave, if the form is blocked
      if(m_wnd.IsLocked())
         return;
      //--- Leave, if the scrollbar is active
      if(m_scrollv.ScrollState() || m_scrollh.ScrollState())
         return;
      //--- If table header is pressed
      if(OnClickTableHeaders(sparam))
         return;
      //--- If table row is pressed
      if(OnClickTableRow(sparam))
        {
         //--- Reset the focus
         m_prev_item_index_focus=WRONG_VALUE;
         //--- Highlight the selected row
         HighlightSelectedItem();
         return;
        }
      //--- If the scrollbar button was pressed
      if(m_scrollv.OnClickScrollInc(sparam) || m_scrollv.OnClickScrollDec(sparam) ||
         m_scrollh.OnClickScrollInc(sparam) || m_scrollh.OnClickScrollDec(sparam))
        {
         //--- Update table data with consideration of the recent changes
         UpdateTable();
         //--- Highlight the selected row
         HighlightSelectedItem();
         return;
        }
      return;
     }
//--- Handling the value change in edit event
   if(id==CHARTEVENT_OBJECT_ENDEDIT)
     {
      OnEndEditCell(sparam);
      //--- Reset table colors
      ResetColors();
      return;
     }
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CTable::OnEventTimer(void)
  {
//--- If this is a drop-down element
   if(CElementBase::IsDropdown())
      FastSwitching();
//--- If this is not a drop-down element, take current availability of the form into consideration
   else
     {
      //--- Track the fast forward of the table only if the form is not blocked
      if(!m_wnd.IsLocked())
         FastSwitching();
     }
  }
//+------------------------------------------------------------------+
//| Create edit box table                                            |
//+------------------------------------------------------------------+
bool CTable::CreateTable(const long chart_id,const int subwin,const int x_gap,const int y_gap)
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
   m_y_size   =CalculationYSize();
//--- Margins from the edge
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
//--- Create the table
   if(!CreateArea())
      return(false);
   if(!CreateCells())
      return(false);
   if(!CreateScrollV())
      return(false);
   if(!CreateScrollH())
      return(false);
   if(!CreateSignSortedData())
      return(false);
//--- Hide the element if the window is a dialog one or is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the table background                                      |
//+------------------------------------------------------------------+
bool CTable::CreateArea(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_table_area_"+(string)CElementBase::Id();
//--- If there is a horizontal scrollbar, adjust the table size along the Y axis
   m_y_size=(m_columns_total>m_visible_columns_total) ? m_y_size+m_scrollh.ScrollWidth()-1 : m_y_size;
//--- Creating the object
   if(!m_area.Create(m_chart_id,name,m_subwin,m_x,m_y,m_x_size,m_y_size))
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
   m_area.XSize(CElementBase::XSize());
   m_area.YSize(CElementBase::YSize());
//--- Margins from the edge
   m_area.XGap(CElement::CalculateXGap(m_x));
   m_area.YGap(CElement::CalculateYGap(m_y));
//--- Store the object pointer
   CElementBase::AddToArray(m_area);
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates a table cell                                             |
//+------------------------------------------------------------------+
bool CTable::CreateCell(const int column_index,const int row_index,const int x,const int y,const int width)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_table_edit_"+(string)column_index+"_"+(string)row_index+"__"+(string)CElementBase::Id();
//--- Create object
   if(!m_columns[column_index].m_rows[row_index].Create(m_chart_id,name,m_subwin,x,y,width,m_row_y_size))
      return(false);
//--- Setting up properties
   m_columns[column_index].m_rows[row_index].Description("");
   m_columns[column_index].m_rows[row_index].TextAlign(m_align_mode);
   m_columns[column_index].m_rows[row_index].Font(CElementBase::Font());
   m_columns[column_index].m_rows[row_index].FontSize(CElementBase::FontSize());
   m_columns[column_index].m_rows[row_index].Color(m_cell_text_color);
   m_columns[column_index].m_rows[row_index].BackColor(m_cell_color);
   m_columns[column_index].m_rows[row_index].BorderColor(m_grid_color);
   m_columns[column_index].m_rows[row_index].Corner(m_corner);
   m_columns[column_index].m_rows[row_index].Anchor(m_anchor);
   m_columns[column_index].m_rows[row_index].Selectable(false);
   m_columns[column_index].m_rows[row_index].Z_Order(m_cell_zorder);
   m_columns[column_index].m_rows[row_index].ReadOnly(m_read_only);
   m_columns[column_index].m_rows[row_index].Tooltip("\n");
//--- Coordinates
   m_columns[column_index].m_rows[row_index].X(x);
   m_columns[column_index].m_rows[row_index].Y(y);
//--- Sizes
   m_columns[column_index].m_rows[row_index].XSize(width);
   m_columns[column_index].m_rows[row_index].YSize(m_row_y_size);
//--- Margins from the edge of the panel
   m_columns[column_index].m_rows[row_index].XGap(CElement::CalculateXGap(x));
   m_columns[column_index].m_rows[row_index].YGap(CElement::CalculateYGap(y));
//--- Store the object pointer
   CElementBase::AddToArray(m_columns[column_index].m_rows[row_index]);
//--- Hide the item, if the control is hidden
   if(!CElementBase::IsVisible())
      m_columns[column_index].m_rows[row_index].Timeframes(OBJ_NO_PERIODS);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates table cells                                              |
//+------------------------------------------------------------------+
bool CTable::CreateCells(void)
  {
//--- Coordinates and width of the table cells
   int x=0,y=0,w=CalculationColumnWidth();
//--- Columns
   for(uint c=0; c<m_columns_total && c<m_visible_columns_total; c++)
     {
      //--- Calculation of the X coordinate
      x=CalculationCellX(c);
      //--- Adjust the width of the last column
      if(c+1>=m_visible_columns_total)
         w=CalculationColumnWidth(true);
      //--- Rows
      for(uint r=0; r<m_rows_total && r<m_visible_rows_total; r++)
        {
         //--- Calculation of the Y coordinate
         y=CalculationCellY(r);
         //--- Creating the object
         if(!CreateCell(c,r,x,y,w))
            return(false);
        }
     }
//--- Formatting of rows in Zebra style
   ZebraFormatRows();
//--- Highlight the selected row
   HighlightSelectedItem();
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a vertical scrollbar                                      |
//+------------------------------------------------------------------+
bool CTable::CreateScrollV(void)
  {
//--- Store the form pointer
   m_scrollv.WindowPointer(m_wnd);
//--- Coordinates
   int x=CElement::CalculateXGap(CElementBase::X2()-m_scrollv.ScrollWidth());
   int y=CElement::CalculateYGap(CElementBase::Y());
//--- Set sizes
   m_scrollv.Id(CElementBase::Id());
   m_scrollv.IsDropdown(CElementBase::IsDropdown());
   m_scrollv.XSize(m_scrollv.ScrollWidth());
   m_scrollv.YSize((m_columns_total>m_visible_columns_total)? m_y_size-m_scrollv.ScrollWidth()+1 : m_y_size);
   m_scrollv.AnchorRightWindowSide(m_anchor_right_window_side);
   m_scrollv.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating the scrollbar
   if(!m_scrollv.CreateScroll(m_chart_id,m_subwin,x,y,m_rows_total,m_visible_rows_total))
      return(false);
//--- Hide, if it is not required now
   if(m_rows_total<=m_visible_rows_total)
      m_scrollv.Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create a horizontal scrollbar                                    |
//+------------------------------------------------------------------+
bool CTable::CreateScrollH(void)
  {
//--- Store the form pointer
   m_scrollh.WindowPointer(m_wnd);
//--- Coordinates
   int x=CElement::CalculateXGap(CElementBase::X());
   int y=CElement::CalculateYGap(CElementBase::Y2()-m_scrollh.ScrollWidth());
//--- Set sizes
   m_scrollh.Id(CElementBase::Id());
   m_scrollh.IsDropdown(CElementBase::IsDropdown());
   m_scrollh.XSize((m_rows_total>m_visible_rows_total)? m_area.XSize()-m_scrollh.ScrollWidth()+1 : m_area.XSize());
   m_scrollh.YSize(m_scrollh.ScrollWidth());
   m_scrollh.AnchorRightWindowSide(m_anchor_right_window_side);
   m_scrollh.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating the scrollbar
   if(!m_scrollh.CreateScroll(m_chart_id,m_subwin,x,y,m_columns_total,m_visible_columns_total))
      return(false);
//--- Hide, if it is not required now
   if(m_columns_total<=m_visible_columns_total)
      m_scrollh.Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates an arrow icon as a sign of sorted data                   |
//+------------------------------------------------------------------+
bool CTable::CreateSignSortedData(void)
  {
//--- Leave, if the sorting mode is disabled
   if(!m_is_sort_mode)
      return(true);
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_table_sort_array_"+(string)CElementBase::Id();
//--- Coordinates
   int x =m_columns[0].m_rows[0].X2()-m_sort_arrow_x_gap;
   int y =CElementBase::Y()+m_sort_arrow_y_gap;
//--- If the icon for the arrow is not specified, then set the default one
   if(m_sort_arrow_file_on=="")
      m_sort_arrow_file_on="Images\\EasyAndFastGUI\\Controls\\SpinInc.bmp";
   if(m_sort_arrow_file_off=="")
      m_sort_arrow_file_off="Images\\EasyAndFastGUI\\Controls\\SpinDec.bmp";
//--- Set the object
   if(!m_sort_arrow.Create(m_chart_id,name,m_subwin,x,y))
      return(false);
//--- Set properties
   m_sort_arrow.BmpFileOn("::"+m_sort_arrow_file_on);
   m_sort_arrow.BmpFileOff("::"+m_sort_arrow_file_off);
   m_sort_arrow.Corner(m_corner);
   m_sort_arrow.GetInteger(OBJPROP_ANCHOR,m_anchor);
   m_sort_arrow.Selectable(false);
   m_sort_arrow.Z_Order(m_zorder);
   m_sort_arrow.Tooltip("\n");
//--- Store coordinates
   m_sort_arrow.X(x);
   m_sort_arrow.Y(y);
//--- Store sizes (in object)
   m_sort_arrow.XSize(m_sort_arrow.X_Size());
   m_sort_arrow.YSize(m_sort_arrow.Y_Size());
//--- Margins from the edge
   m_sort_arrow.XGap(CElement::CalculateXGap(x));
   m_sort_arrow.YGap(CElement::CalculateYGap(y));
//--- Hide the object
   m_sort_arrow.Timeframes(OBJ_NO_PERIODS);
//--- Store the object pointer
   CElementBase::AddToArray(m_sort_arrow);
   return(true);
  }
//+------------------------------------------------------------------+
//| Fills the array by the specified indexes                         |
//+------------------------------------------------------------------+
void CTable::SetValue(const uint column_index,const uint row_index,const string value="",const uint digits=0)
  {
//--- Checking for exceeding the array range
   if(!CheckOutOfRange(column_index,row_index))
     return;
//--- Store the value into the array:
//    String
   if(m_vcolumns[column_index].m_type==TYPE_STRING || (m_fix_first_row && row_index==0))
      m_vcolumns[column_index].m_vrows[row_index]=value;
//--- Double
   else if(m_vcolumns[column_index].m_type==TYPE_DOUBLE)
     {
      m_vcolumns[column_index].m_digits[row_index]=digits;
      double type_value=::StringToDouble(value);
      m_vcolumns[column_index].m_vrows[row_index]=::DoubleToString(type_value,digits);
     }
//--- Time
   else if(m_vcolumns[column_index].m_type==TYPE_DATETIME)
     {
      datetime type_value=::StringToTime(value);
      m_vcolumns[column_index].m_vrows[row_index]=::TimeToString(type_value);
     }
//--- Any other type will be stored as a string
   else
      m_vcolumns[column_index].m_vrows[row_index]=value;
  }
//+------------------------------------------------------------------+
//| Return value at the specified index                              |
//+------------------------------------------------------------------+
string CTable::GetValue(const uint column_index,const uint row_index)
  {
//--- Checking for exceeding the array range
   if(!CheckOutOfRange(column_index,row_index))
     return("");
//--- Return the value
   return(m_vcolumns[column_index].m_vrows[row_index]);
  }
//+------------------------------------------------------------------+
//| Fills the array of text alignment modes                          |
//+------------------------------------------------------------------+
void CTable::TextAlign(const uint column_index,const uint row_index,const ENUM_ALIGN_MODE mode)
  {
//--- Checking for exceeding the array range
   if(!CheckOutOfRange(column_index,row_index))
     return;
//--- Store the text color in the common array
   m_vcolumns[column_index].m_text_align[row_index]=mode;
  }
//+------------------------------------------------------------------+
//| Fill the text color array                                        |
//+------------------------------------------------------------------+
void CTable::TextColor(const uint column_index,const uint row_index,const color clr)
  {
//--- Checking for exceeding the array range
   if(!CheckOutOfRange(column_index,row_index))
     return;
//--- Store the text color in the common array
   m_vcolumns[column_index].m_text_color[row_index]=clr;
  }
//+------------------------------------------------------------------+
//| Fill the cell color array                                        |
//+------------------------------------------------------------------+
void CTable::CellColor(const uint column_index,const uint row_index,const color clr)
  {
//--- Leave, if Zebra mode is enabled
   if(m_is_zebra_format_rows!=clrNONE)
      return;
//--- Checking for exceeding the array range
   if(!CheckOutOfRange(column_index,row_index))
     return;
//--- Store the cell background color in the common array
   m_vcolumns[column_index].m_cell_color[row_index]=clr;
  }
//+------------------------------------------------------------------+
//| Get the data type of the specified column                        |
//+------------------------------------------------------------------+
ENUM_DATATYPE CTable::DataType(const uint column_index)
  {
//--- Checking for exceeding the column range
   if(!CheckOutOfColumnRange(column_index))
     return(WRONG_VALUE);
//--- Return the data type for the specified column
   return(m_vcolumns[column_index].m_type);
  }
//+------------------------------------------------------------------+
//| Set the data type of the specified column                        |
//+------------------------------------------------------------------+
void CTable::DataType(const uint column_index,const ENUM_DATATYPE type)
  {
//--- Checking for exceeding the column range
   if(!CheckOutOfColumnRange(column_index))
     return;
//--- Set the data type for the specified column
   m_vcolumns[column_index].m_type=type;
  }
//+------------------------------------------------------------------+
//| Set the size of the table                                        |
//+------------------------------------------------------------------+
void CTable::TableSize(const uint columns_total,const uint rows_total)
  {
//--- There must be at least one column
   m_columns_total=(columns_total<1) ? 0 : columns_total;
//--- There must be at least two rows
   m_rows_total=(rows_total<1) ? 0 : rows_total;
//--- Set the size of the columns array
   ::ArrayResize(m_vcolumns,m_columns_total);
//--- Set the size of the rows arrays
   for(uint c=0; c<m_columns_total; c++)
     {
      RowResize(c,m_rows_total);
      //--- Initialize the arrays with the default values
      CellInitialize(c);
     }
  }
//+------------------------------------------------------------------+
//| Set the size of the visible part of the table                    |
//+------------------------------------------------------------------+
void CTable::VisibleTableSize(const uint visible_columns_total,const uint visible_rows_total)
  {
//--- There must be at least one column
   m_visible_columns_total=(visible_columns_total<1) ? 0 : visible_columns_total;
//--- There must be at least two rows
   m_visible_rows_total=(visible_rows_total<1) ? 0 : visible_rows_total;
//--- Set the size of the columns array
   ::ArrayResize(m_columns,m_visible_columns_total);
//--- Set the size of the rows arrays
   for(uint i=0; i<m_visible_columns_total; i++)
      ::ArrayResize(m_columns[i].m_rows,m_visible_rows_total);
  }
//+------------------------------------------------------------------+
//| Rebuilding the table                                             |
//+------------------------------------------------------------------+
void CTable::Rebuilding(const int columns_total,const int visible_columns_total,const int rows_total,const int visible_rows_total)
  {
//--- Clearing the table
   Clear();
//--- Set the size of the table and its visible part
   TableSize(columns_total,rows_total);
   VisibleTableSize(visible_columns_total,visible_rows_total);
//--- Adjust the sizes of the scrollbars
   m_scrollv.ChangeThumbSize(rows_total,visible_rows_total);
   m_scrollh.ChangeThumbSize(columns_total,visible_columns_total);
//--- Check for presence of a vertical scrollbar
   bool is_scrollv=m_rows_total>m_visible_rows_total;
//--- Check for presence of a horizontal scrollbar
   bool is_scrollh=m_columns_total>m_visible_columns_total;
//--- Calculate the table size along the Y axis
   int y_size=CalculationYSize();
//--- Resize the vertical scrollbar
   m_scrollv.ChangeYSize(y_size);
//--- Resize the table
   m_y_size=(is_scrollh)? y_size+m_scrollh.ScrollWidth()-1 : y_size;
   m_area.YSize(m_y_size);
   m_area.Y_Size(m_y_size);
//--- Adjust the location of the horizontal scrollbar along the Y axis
   m_scrollh.YDistance(CElementBase::Y2()-m_scrollh.ScrollWidth());
//--- If a horizontal scrollbar is required
   if(is_scrollh)
     {
      //--- Set the size according to the presence of a vertical scrollbar
      if(!is_scrollv)
         m_scrollh.ChangeXSize(m_x_size);
      else
        {
         //--- Calculate and change the width of the horizontal scrollbar
         int x_size=m_area.XSize()-m_scrollh.ScrollWidth()+1;
         m_scrollh.ChangeXSize(x_size);
        }
     }
//--- Create table cells
   CreateCells();
//--- Display the scrollbar, if necessary
   if(rows_total>visible_rows_total)
     {
      if(CElementBase::IsVisible())
         m_scrollv.Show();
     }
   if(columns_total>visible_columns_total)
     {
      if(CElementBase::IsVisible())
         m_scrollh.Show();
     }
  }
//+------------------------------------------------------------------+
//| Adds a column to the table                                       |
//+------------------------------------------------------------------+
void CTable::AddColumn(void)
  {
//--- Increase the array size by one element
   uint array_size=ColumnsTotal();
   m_columns_total=array_size+1;
   ::ArrayResize(m_vcolumns,m_columns_total);
//--- Set the size of the rows arrays
   RowResize(array_size,m_rows_total);
//--- Initialize the arrays with the default values
   CellInitialize(array_size);
//--- If the total number of columns is greater than the visible amount
   if(m_columns_total>m_visible_columns_total)
     {
      //--- Adjust the table size along the Y axis
      YResize();
      //--- If there is no vertical scrollbar, make the horizontal scrollbar occupy the full width of the table
      if(m_rows_total<=m_visible_rows_total)
         m_scrollh.ChangeXSize(m_x_size);
      //--- Adjust the size of the thumb and display the scrollbar
      m_scrollh.ChangeThumbSize(m_columns_total,m_visible_columns_total);
      //--- Show the scrollbar
      if(CElementBase::IsVisible())
         m_scrollh.Show();
      //--- Formatting of rows in Zebra style
      ZebraFormatRows();
      //--- Update the table
      UpdateTable();
      return;
     }
//--- Calculation of column widths
   int width=CalculationColumnWidth();
//--- Adjust the width of the last column
   if(m_columns_total>=m_visible_columns_total)
      width=CalculationColumnWidth(true);
//--- Calculation of the X coordinate
   int x=CalculationCellX(array_size);
//---
   for(uint r=0; r<m_rows_total && r<m_visible_rows_total; r++)
     {
      //--- Calculation of the Y coordinate
      int y=CalculationCellY(r);
      //--- Creating the object
      CreateCell(array_size,r,x,y,width);
      //--- Set the corresponding color to the header
      if(m_fix_first_row && r==0)
         m_columns[array_size].m_rows[r].BackColor(m_headers_color);
     }
//--- Formatting of rows in Zebra style
   ZebraFormatRows();
//--- Update the table
   UpdateTable();
  }
//+------------------------------------------------------------------+
//| Adds a row to the table                                          |
//+------------------------------------------------------------------+
void CTable::AddRow(void)
  {
//--- Increase the array size by one element
   uint array_size=RowsTotal();
   m_rows_total=array_size+1;
//--- Set the size of the rows arrays
   for(uint i=0; i<m_columns_total; i++)
     {
      RowResize(i,m_rows_total);
      //--- Initialize the last cell with the default values
      CellInitialize(i,array_size);
     }
//--- If the total number of rows is greater than the visible
   if(m_rows_total>m_visible_rows_total)
     {
      //--- Adjust the size of the thumb and display the scrollbar
      m_scrollv.ChangeThumbSize(m_rows_total,m_visible_rows_total);
      if(CElementBase::IsVisible())
         m_scrollv.Show();
      //--- Leave, if the array has less than one element
      if(m_visible_rows_total<1)
         return;
      //--- Calculation of column widths
      ColumnsXResize();
      //--- Calculate and change the width of the horizontal scrollbar
      int x_size=m_area.XSize()-m_scrollh.ScrollWidth()+1;
      m_scrollh.ChangeXSize(x_size);
      //--- Formatting of rows in Zebra style
      ZebraFormatRows();
      //--- Update the table
      UpdateTable();
      return;
     }
//--- Calculation of the Y coordinate
   int y=CalculationCellY(array_size);
//--- Calculation of column widths
   int width=CalculationColumnWidth();
//---
   for(uint c=0; c<m_columns_total && c<m_visible_columns_total; c++)
     {
      //--- Calculation of the X coordinate
      int x=CalculationCellX(c);
      //--- Adjust the width of the last column
      if(c+1>=m_visible_columns_total)
         width=CalculationColumnWidth(true);
      //--- Creating the object
      CreateCell(c,array_size,x,y,width);
      //--- Set the corresponding color to the header
      if(m_fix_first_row && array_size==0)
         m_columns[c].m_rows[array_size].BackColor(m_headers_color);
     }
//--- Check for presence of a horizontal scrollbar
   bool is_scrollh=m_columns_total>m_visible_columns_total;
//--- Adjust the table size along the Y axis
   if(m_rows_total>=m_visible_rows_total && is_scrollh)
      YResize();
//--- Formatting of rows in Zebra style
   ZebraFormatRows();
//--- Update the table
   UpdateTable();
  }
//+------------------------------------------------------------------+
//| Clears the table (deletes all rows and columns)                  |
//+------------------------------------------------------------------+
void CTable::Clear(void)
  {
//--- Delete the cell objects
   for(uint c=0; c<m_visible_columns_total; c++)
     {
      for(uint r=0; r<m_visible_rows_total; r++)
         m_columns[c].m_rows[r].Delete();
     }
//--- Clear the array of pointers to objects
   CElementBase::FreeObjectsArray();
//--- Set the default values
   m_selected_item_text     ="";
   m_selected_item          =WRONG_VALUE;
   m_last_sort_direction    =SORT_ASCEND;
   m_is_sorted_column_index =WRONG_VALUE;
//--- Set the zero size to the table
   TableSize(0,0);
//--- Calculate the table height
   m_y_size=CalculationYSize();
   m_area.YSize(m_y_size);
   m_area.Y_Size(m_y_size);
//--- Reset the scrollbar values
   m_scrollv.Hide();
   m_scrollh.Hide();
   m_scrollv.MovingThumb(0);
   m_scrollh.MovingThumb(0);
//--- Hide the sorting arrow
   m_sort_arrow.Timeframes(OBJ_NO_PERIODS);
//--- Add the list background to the array of pointers to objects of the control
   CElementBase::AddToArray(m_area);
   CElementBase::AddToArray(m_sort_arrow);
  }
//+------------------------------------------------------------------+
//| Vertical scrolling of the table                                  |
//+------------------------------------------------------------------+
void CTable::VerticalScrolling(const int pos=WRONG_VALUE)
  {
//--- Leave, if the scrollbar is not required
   if(m_rows_total<=m_visible_rows_total)
      return;
//--- To determine the position of the thumb
   int index=0;
//--- Index of the last position
   int last_pos_index=int(m_rows_total-m_visible_rows_total);
//--- Adjustment in case the range has been exceeded
   if(pos<0)
      index=last_pos_index;
   else
      index=(pos>last_pos_index)? last_pos_index : pos;
//--- Move the scrollbar thumb
   m_scrollv.MovingThumb(index);
//--- Shift the table
   UpdateTable();
  }
//+------------------------------------------------------------------+
//| Horizontal scrolling of the table                                |
//+------------------------------------------------------------------+
void CTable::HorizontalScrolling(const int pos=WRONG_VALUE)
  {
//--- Leave, if the scrollbar is not required
   if(m_columns_total<=m_visible_columns_total)
      return;
//--- To determine the position of the thumb
   int index=0;
//--- Index of the last position
   int last_pos_index=int(m_columns_total-m_visible_columns_total);
//--- Adjustment in case the range has been exceeded
   if(pos<0)
      index=last_pos_index;
   else
      index=(pos>last_pos_index)? last_pos_index : pos;
//--- Move the scrollbar thumb
   m_scrollh.MovingThumb(index);
//--- Shift the table
   UpdateTable();
  }
//+------------------------------------------------------------------+
//| Select the specified row of the table                            |
//+------------------------------------------------------------------+
void CTable::SelectRow(const uint row_index)
  {
//--- Adjustment in case the range has been exceeded
   uint index=(row_index>=(uint)m_rows_total)? m_rows_total-1 : row_index;
//--- If this row is selected already, deselect
   bool is_selected=(index==m_selected_item);
//--- Store the row index
   m_selected_item=(is_selected)? WRONG_VALUE :(int)index;
//--- Store the cell row
   m_selected_item_text=(is_selected)? "" : m_vcolumns[0].m_vrows[index];
//--- Generate a string with the cell parameters
   string cell_params=string(0)+"_"+string(index)+"_"+m_vcolumns[0].m_vrows[index];
//--- Reset the focus
   m_prev_item_index_focus=WRONG_VALUE;
//--- Update the table
   UpdateTable();
//--- Highlight the selected row
   HighlightSelectedItem();
  }
//+------------------------------------------------------------------+
//| Sort the data according to the specified column                  |
//+------------------------------------------------------------------+
void CTable::SortData(const uint column_index=0)
  {
//--- Index (taking into account the presence of headers) to start sorting from
   uint first_index=(m_fix_first_row) ? 1 : 0;
//--- The last index
   uint last_index=m_rows_total-1;
//--- The first time it will be sorted in ascending order, every time after that it will be sorted in the opposite direction
   if(m_is_sorted_column_index==WRONG_VALUE || column_index!=m_is_sorted_column_index || m_last_sort_direction==SORT_DESCEND)
      m_last_sort_direction=SORT_ASCEND;
   else
      m_last_sort_direction=SORT_DESCEND;
//--- Store the index of the last sorted data column
   m_is_sorted_column_index=(int)column_index;
//--- Sorting
   QuickSort(first_index,last_index,column_index,m_last_sort_direction);
//--- Update the table
   UpdateTable();
//--- Set the icon according to the sorting direction
   m_sort_arrow.State((m_last_sort_direction==SORT_ASCEND)? true : false);
  }
//+------------------------------------------------------------------+
//| Shifting the arrow to the sorted table column                    |
//+------------------------------------------------------------------+
void CTable::ShiftSortArrow(const uint column)
  {
//--- Show the object if the control is not hidden
   if(CElementBase::IsVisible())
      m_sort_arrow.Timeframes(OBJ_ALL_PERIODS);
//--- Calculate and set the coordinate
   int x=m_columns[column].m_rows[0].X2()-m_sort_arrow_x_gap;
   m_sort_arrow.X(x);
   m_sort_arrow.X_Distance(x);
//--- Margin from the edge
   m_sort_arrow.XGap(CalculateXGap(x));
  }
//+------------------------------------------------------------------+
//| Update table data with consideration of the recent changes       |
//+------------------------------------------------------------------+
void CTable::UpdateTable(void)
  {
//--- Shift by one index, if the fixed header mode is enabled
   uint t=(m_fix_first_row) ? 1 : 0;
   uint l=(m_fix_first_column) ? 1 : 0;
//--- Get the current positions of sliders of the vertical and horizontal scrollbars
   uint h=m_scrollh.CurrentPos()+l;
   uint v=m_scrollv.CurrentPos()+t;
//--- Set the properties for the first cell, if the header fixation modes are enabled
   if(m_fix_first_column && m_fix_first_row)
     {
      //--- Adjusts the (1) values, (2) background color, (3) text color and (4) text alignment in cells
      SetCellParameters(0,0,m_vcolumns[0].m_vrows[0],m_headers_color,m_headers_text_color,m_vcolumns[0].m_text_align[0]);
     }
//--- Shift of the headers in the left column
   if(m_fix_first_column)
     {
      //--- Rows
      for(uint r=t; r<m_visible_rows_total; r++)
        {
         if(r>=t && r<m_rows_total)
            //--- Adjusts the (1) values, (2) background color, (3) text color and (4) text alignment in cells
            SetCellParameters(0,r,m_vcolumns[0].m_vrows[v],m_headers_color,m_headers_text_color,m_vcolumns[0].m_text_align[v]);
         //---
         v++;
        }
     }
//--- Shift of the headers in the top row
   if(m_fix_first_row && m_rows_total>0)
     {
      //--- For determining the shift of the sorting icon
      bool is_shift_sort_arrow=false;
      //--- Columns
      for(uint c=l; c<m_visible_columns_total; c++)
        {
         //--- If not exceeding the array range
         if(h>=l && h<m_columns_total)
           {
            //--- If found the sorted column
            if(!is_shift_sort_arrow && m_is_sort_mode && h==m_is_sorted_column_index)
              {
               is_shift_sort_arrow=true;
               //--- Adjust the sorting icon
               uint column=h-(h-c);
               if(column>=l && column<m_visible_columns_total)
                  ShiftSortArrow(column);
              }
            //--- Adjusts the (1) values, (2) background color, (3) text color and (4) text alignment in cells
            SetCellParameters(c,0,m_vcolumns[h].m_vrows[0],m_headers_color,m_headers_text_color,m_vcolumns[h].m_text_align[0]);
           }
         //---
         h++;
        }
      //--- If the sorted table exists, but was not found
      if(!is_shift_sort_arrow && m_is_sort_mode && m_is_sorted_column_index!=WRONG_VALUE)
        {
         //--- Hide, if the index is greater than zero
         if(m_is_sorted_column_index>0 || !m_fix_first_column)
            m_sort_arrow.Timeframes(OBJ_NO_PERIODS);
         //--- Set to the header of the first column
         else
            ShiftSortArrow(0);
        }
     }
//--- Get the current position of slider of the horizontal scrollbar
   h=m_scrollh.CurrentPos()+l;
//--- Columns
   for(uint c=l; c<m_visible_columns_total; c++)
     {
      //--- Get the current position of slider of the vertical scrollbar
      v=m_scrollv.CurrentPos()+t;
      //--- Rows
      for(uint r=t; r<m_visible_rows_total; r++)
        {
         //--- Shift of the table data
         if(v>=t && v<m_rows_total && h>=l && h<m_columns_total)
           {
            //--- Adjustment with consideration of the selected row
            color back_color=(m_selected_item==v) ? m_selected_row_color : m_vcolumns[h].m_cell_color[v];
            color text_color=(m_selected_item==v) ? m_selected_row_text_color : m_vcolumns[h].m_text_color[v];
            //--- Adjusts the (1) values, (2) background color, (3) text color and (4) text alignment in cells
            SetCellParameters(c,r,m_vcolumns[h].m_vrows[v],back_color,text_color,m_vcolumns[h].m_text_align[v]);
            v++;
           }
        }
      //---
      h++;
     }
  }
//+------------------------------------------------------------------+
//| Setting the table cell parameters                                |
//+------------------------------------------------------------------+
void CTable::SetCellParameters(const uint column,const uint row,const string text,const color cell_color,const color text_color,const ENUM_ALIGN_MODE text_align)
  {
   m_columns[column].m_rows[row].Description(text);
   m_columns[column].m_rows[row].BackColor(cell_color);
   m_columns[column].m_rows[row].Color(text_color);
   m_columns[column].m_rows[row].TextAlign(text_align);
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CTable::Moving(const int x,const int y,const bool moving_mode=false)
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
      m_sort_arrow.X(m_wnd.X2()-m_sort_arrow.XGap());
     }
   else
     {
      CElementBase::X(x+XGap());
      m_area.X(x+m_area.XGap());
      m_sort_arrow.X(x+m_sort_arrow.XGap());
     }
//--- If the anchored to the bottom
   if(m_anchor_bottom_window_side)
     {
      CElementBase::Y(m_wnd.Y2()-YGap());
      m_area.Y(m_wnd.Y2()-m_area.YGap());
      m_sort_arrow.Y(m_wnd.Y2()-m_sort_arrow.YGap());
     }
   else
     {
      CElementBase::Y(y+YGap());
      m_area.Y(y+m_area.YGap());
      m_sort_arrow.Y(y+m_sort_arrow.YGap());
     }
//--- Updating coordinates of graphical objects
   m_area.X_Distance(m_area.X());
   m_area.Y_Distance(m_area.Y());
   m_sort_arrow.X_Distance(m_sort_arrow.X());
   m_sort_arrow.Y_Distance(m_sort_arrow.Y());
//--- 
   for(uint c=0; c<m_visible_columns_total; c++)
     {
      for(uint r=0; r<m_visible_rows_total; r++)
        {
         //--- Storing coordinates in the fields of the objects
         m_columns[c].m_rows[r].X((m_anchor_right_window_side)? m_wnd.X2()-m_columns[c].m_rows[r].XGap() : x+m_columns[c].m_rows[r].XGap());
         m_columns[c].m_rows[r].Y((m_anchor_bottom_window_side)? m_wnd.Y2()-m_columns[c].m_rows[r].YGap() : y+m_columns[c].m_rows[r].YGap());
         //--- Updating coordinates of graphical objects
         m_columns[c].m_rows[r].X_Distance(m_columns[c].m_rows[r].X());
         m_columns[c].m_rows[r].Y_Distance(m_columns[c].m_rows[r].Y());
        }
     }
  }
//+------------------------------------------------------------------+
//| Shows the element                                                |
//+------------------------------------------------------------------+
void CTable::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElementBase::IsVisible())
      return;
//--- Make all the objects visible
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_ALL_PERIODS);
//--- Do not show the arrow, if the data is not sorted
   if(m_is_sorted_column_index==WRONG_VALUE)
      m_sort_arrow.Timeframes(OBJ_NO_PERIODS);
   else
     {
      m_sort_arrow.Timeframes(OBJ_NO_PERIODS);
      m_sort_arrow.Timeframes(OBJ_ALL_PERIODS);
     }
//--- Show the scrollbars
   if(m_rows_total>m_visible_rows_total)
      m_scrollv.Show();
   if(m_columns_total>m_visible_columns_total)
      m_scrollh.Show();
//--- Visible state
   CElementBase::IsVisible(true);
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
//| Hides the element                                                |
//+------------------------------------------------------------------+
void CTable::Hide(void)
  {
//--- Leave, if the element is already hidden
   if(!CElementBase::IsVisible())
      return;
//--- Hide all objects
   for(int i=0; i<CElementBase::ObjectsElementTotal(); i++)
      CElementBase::Object(i).Timeframes(OBJ_NO_PERIODS);
//--- Hide the scrollbars
   m_scrollv.Hide();
   m_scrollh.Hide();
//--- Visible state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CTable::Reset(void)
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
void CTable::Delete(void)
  {
//--- Leave, if deletion is repeated
   if(ArraySize(m_columns)<1)
      return;
//--- Delete graphical objects
   m_area.Delete();
   m_sort_arrow.Delete();
   for(uint c=0; c<m_visible_columns_total; c++)
     {
      for(uint r=0; r<m_visible_rows_total; r++)
         m_columns[c].m_rows[r].Delete();
      //--- Emptying the control arrays
      ::ArrayFree(m_columns[c].m_rows);
     }
//--- Emptying the control arrays
   for(uint c=0; c<m_columns_total; c++)
     {
      ::ArrayFree(m_vcolumns[c].m_vrows);
      ::ArrayFree(m_vcolumns[c].m_digits);
      ::ArrayFree(m_vcolumns[c].m_text_align);
      ::ArrayFree(m_vcolumns[c].m_text_color);
      ::ArrayFree(m_vcolumns[c].m_cell_color);
     }
//---
   ::ArrayFree(m_columns);
   ::ArrayFree(m_vcolumns);
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
//--- Initializing of variables by default values
   CElementBase::IsVisible(true);
   m_visible_columns_total  =1;
   m_visible_rows_total     =2;
   m_is_sorted_column_index =WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| Seth the priorities                                              |
//+------------------------------------------------------------------+
void CTable::SetZorders(void)
  {
   m_area.Z_Order(m_zorder);
   m_scrollv.SetZorders();
   m_scrollh.SetZorders();
//---
   for(uint c=0; c<m_visible_columns_total; c++)
     {
      for(uint r=0; r<m_visible_rows_total; r++)
         m_columns[c].m_rows[r].Z_Order(m_cell_zorder);
     }
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CTable::ResetZorders(void)
  {
   m_area.Z_Order(0);
   m_scrollv.ResetZorders();
   m_scrollh.ResetZorders();
//---
   for(uint c=0; c<m_visible_columns_total; c++)
     {
      for(uint r=0; r<m_visible_rows_total; r++)
         m_columns[c].m_rows[r].Z_Order(0);
     }
  }
//+------------------------------------------------------------------+
//| Reset the color of the element objects                           |
//+------------------------------------------------------------------+
void CTable::ResetColors(void)
  {
//--- Reset the header colors
   if(m_fix_first_row)
      for(uint c=0; c<m_visible_columns_total; c++)
         m_columns[c].m_rows[0].BackColor(m_headers_color);
//--- Reset the header colors
   if(m_fix_first_column)
      for(uint r=0; r<m_visible_rows_total; r++)
         m_columns[0].m_rows[r].BackColor(m_headers_color);
//---
   if(m_prev_item_index_focus!=WRONG_VALUE)
     {
      //--- Shift by one index, if the fixed header mode is enabled
      uint t=(m_fix_first_row) ? 1 : 0;
      uint l=(m_fix_first_column) ? 1 : 0;
      //--- Get the current position of slider of the horizontal scrollbar
      uint h=m_scrollh.CurrentPos()+l;
      //--- Columns
      for(uint c=l; c<m_visible_columns_total; c++)
        {
         if(!(h>=l && h<m_columns_total))
            continue;
         //--- Get the current position of slider of the vertical scrollbar
         uint v=m_scrollv.CurrentPos()+t;
         //--- Rows
         for(uint r=t; r<m_visible_rows_total; r++)
           {
            //--- Check to prevent exceeding the array range
            if(v>=t && v<m_rows_total)
              {
               //--- Skip if the selected item is reached and it is in "Read only" mode
               if(m_selected_item==v && m_read_only)
                 {
                  v++;
                  continue;
                 }
               //--- Adjust the cell background color
               m_columns[c].m_rows[r].BackColor(m_vcolumns[h].m_cell_color[v]);
               v++;
              }
           }
         //---
         h++;
        }
      //---
      m_scrollv.ResetColors();
      m_scrollh.ResetColors();
      m_prev_item_index_focus=WRONG_VALUE;
     }
  }
//+------------------------------------------------------------------+
//| Handling clicking on the table header                            |
//+------------------------------------------------------------------+
bool CTable::OnClickTableHeaders(const string clicked_object)
  {
//--- Leave, is sorting mode or fixed header mode is disabled
   if(!m_is_sort_mode || !m_fix_first_row)
      return(false);
//--- Leave, if the pressing was not on the table cell
   if(::StringFind(clicked_object,CElementBase::ProgramName()+"_table_edit_",0)<0)
      return(false);
//--- Get the identifier from the object name
   int id=CElementBase::IdFromObjectName(clicked_object);
//--- Leave, if the identifier does not match
   if(id!=CElementBase::Id())
      return(false);
//--- Leave, if this is not a table header
   if(RowIndexFromObjectName(clicked_object)>0)
      return(false);
//--- For determining the column index
   uint column_index=0;
//--- Shift by one index, if the fixed header mode is enabled
   int l=(m_fix_first_column) ? 1 : 0;
//--- Get the current position of slider of the horizontal scrollbar
   int h=m_scrollh.CurrentPos()+l;
//--- Columns
   for(uint c=l; c<m_visible_columns_total; c++)
     {
      //--- If the pressing was not on this cell
      if(m_columns[c].m_rows[0].Name()==clicked_object)
        {
         //--- Get the index of the column
         column_index=(m_fix_first_column && c==0) ? 0 : h;
         break;
        }
      //---
      h++;
     }
//--- Sort the data according to the specified column
   SortData(column_index);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_SORT_DATA,CElementBase::Id(),m_is_sorted_column_index,::EnumToString(DataType(column_index)));
   return(true);
  }
//+------------------------------------------------------------------+
//| Handling the pressing on the table row                           |
//+------------------------------------------------------------------+
bool CTable::OnClickTableRow(const string clicked_object)
  {
//--- Leave, if editable table mode is enabled
   if(!m_read_only)
      return(false);
//--- Leave, if the pressing was not on the table cell
   if(::StringFind(clicked_object,CElementBase::ProgramName()+"_table_edit_",0)<0)
      return(false);
//--- Get the identifier from the object name
   int id=CElementBase::IdFromObjectName(clicked_object);
//--- Leave, if the identifier does not match
   if(id!=CElementBase::Id())
      return(false);
//--- Search for the row index
   uint row_index=0;
//--- To stop the cycle
   bool stop=false;
//--- Cell parameters (column_row_text)
   string cell_params="";
//--- Shift by one index, if the fixed header mode is enabled
   uint t=(m_fix_first_row) ? 1 : 0;
//--- Columns
   for(uint c=0; c<m_visible_columns_total; c++)
     {
      //--- Get the current position of slider of the vertical scrollbar
      uint v=m_scrollv.CurrentPos()+t;
      //--- Rows
      for(uint r=t; r<m_visible_rows_total; r++)
        {
         //--- If the pressing was not on this cell
         if(m_columns[c].m_rows[r].Name()==clicked_object)
           {
            //--- If clicked on a selected item, deselect
            if(v==m_selected_item)
              {
               m_selected_item      =WRONG_VALUE;
               m_selected_item_text ="";
               cell_params          =string(c)+"_"+string(r)+"_"+m_columns[c].m_rows[r].Description();
               //--- Send a message about it
               ::EventChartCustom(m_chart_id,ON_CLICK_LIST_ITEM,CElementBase::Id(),m_selected_item,cell_params);
               //--- Stop the cycle
               stop=true;
               break;
              }
            //--- Store the row index
            row_index=v;
            m_selected_item=(int)row_index;
            //--- Store the cell row
            m_selected_item_text=m_columns[c].m_rows[r].Description();
            //--- Generate a string with the cell parameters
            cell_params=string(c)+"_"+string(r)+"_"+m_selected_item_text;
            //--- Stop the cycle
            stop=true;
            break;
           }
         //--- Increase the row counter
         if(v>=t && v<m_rows_total)
            v++;
        }
      //---
      if(stop)
         break;
     }
//--- Leave, if a header was pressed
   if(m_fix_first_row && row_index<1)
      return(false);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_CLICK_LIST_ITEM,CElementBase::Id(),m_selected_item,cell_params);
   return(true);
  }
//+------------------------------------------------------------------+
//| Event of finishing editing a cell value                          |
//+------------------------------------------------------------------+
bool CTable::OnEndEditCell(const string edited_object)
  {
//--- Leave, if the editable table mode is disabled
   if(m_read_only)
      return(false);
//--- Leave, if the pressing was not on the table cell
   if(::StringFind(edited_object,CElementBase::ProgramName()+"_table_edit_",0)<0)
      return(false);
//--- Get the identifier from the object name
   int id=CElementBase::IdFromObjectName(edited_object);
//--- Leave, if the identifier does not match
   if(id!=CElementBase::Id())
      return(false);
//--- Get the column and row indexes of the cell
   int c =ColumnIndexFromObjectName(edited_object);
   int r =RowIndexFromObjectName(edited_object);
//--- Get the column and row indexes in the data array
   int vc =c+m_scrollh.CurrentPos();
   int vr =r+m_scrollv.CurrentPos();
//--- Adjust the row index, if a header was pressed
   if(m_fix_first_row && r==0)
      vr=0;
//--- Get the entered value
   string cell_text=m_columns[c].m_rows[r].Description();
//--- If the cell value has been changed
   if(cell_text!=m_vcolumns[vc].m_vrows[vr])
     {
      //--- Store the value in the array
      SetValue(vc,vr,cell_text);
      //--- Send a message about it
      ::EventChartCustom(m_chart_id,ON_END_EDIT,CElementBase::Id(),0,string(vc)+"_"+string(vr)+"_"+cell_text);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Retrieve column index from the object name                       |
//+------------------------------------------------------------------+
int CTable::ColumnIndexFromObjectName(const string object_name)
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
   if(array_size-3<0)
     {
      ::Print(PREVENTING_OUT_OF_RANGE);
      return(WRONG_VALUE);
     }
//--- Return the item index
   return((int)result[array_size-3]);
  }
//+------------------------------------------------------------------+
//| Retrieve row index from the object name                          |
//+------------------------------------------------------------------+
int CTable::RowIndexFromObjectName(const string object_name)
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
//| Highlight the selected row                                       |
//+------------------------------------------------------------------+
void CTable::HighlightSelectedItem(void)
  {
//return;
//--- Leave, if one of the modes ("Read only", "Selectable row") is disabled
   if(!m_read_only || !m_selectable_row)
      return;
//--- Shift by one index, if the fixed header mode is enabled
   uint t=(m_fix_first_row) ? 1 : 0;
   uint l=(m_fix_first_column) ? 1 : 0;
//--- Get the current position of slider of the horizontal scrollbar
   uint h=m_scrollh.CurrentPos()+l;
//--- Columns
   for(uint c=l; c<m_visible_columns_total; c++)
     {
      if(!(h>=l && h<m_columns_total))
         continue;
      //--- Get the current position of slider of the vertical scrollbar
      uint v=m_scrollv.CurrentPos()+t;
      //--- Rows
      for(uint r=t; r<m_visible_rows_total; r++)
        {
         if(r==m_prev_item_index_focus)
           {
            v++;
            continue;
           }
         //--- Shift of the table data
         if(v>=t && v<m_rows_total)
           {
            //--- Adjustment with consideration of the selected row
            color back_color=(m_selected_item==v) ? m_selected_row_color : m_vcolumns[h].m_cell_color[v];
            color text_color=(m_selected_item==v) ? m_selected_row_text_color : m_vcolumns[h].m_text_color[v];
            //--- Adjust the text and background color of the cell
            m_columns[c].m_rows[r].Color(text_color);
            m_columns[c].m_rows[r].BackColor(back_color);
            v++;
           }
        }
      //---
      h++;
     }
  }
//+------------------------------------------------------------------+
//| Quicksort algorithm                                              |
//+------------------------------------------------------------------+
void CTable::QuickSort(uint beg,uint end,uint column,const ENUM_SORT_MODE mode=SORT_ASCEND)
  {
   uint   r1         =beg;
   uint   r2         =end;
   uint   c          =column;
   string temp       =NULL;
   string value      =NULL;
   uint   data_total =m_rows_total-1;
//--- Run the algorithm while the left index is less than the rightmost index
   while(r1<end)
     {
      //--- Get the value from the middle of the row
      value=m_vcolumns[c].m_vrows[(beg+end)>>1];
      //--- Run the algorithm while the left index is less than the found right index
      while(r1<r2)
        {
         //--- Shift the index to the right while finding the value on the specified condition
         while(CheckSortCondition(c,r1,value,(mode==SORT_ASCEND)? false : true))
           {
            //--- Checking for exceeding the array range
            if(r1==data_total)
               break;
            r1++;
           }
         //--- Shift the index to the left while finding the value on the specified condition
         while(CheckSortCondition(c,r2,value,(mode==SORT_ASCEND)? true : false))
           {
            //--- Checking for exceeding the array range
            if(r2==0)
               break;
            r2--;
           }
         //--- If the left index is still not greater than the right index
         if(r1<=r2)
           {
            //--- Swap the values
            Swap(c,r1,r2);
            //--- If the left limit has been reached
            if(r2==0)
              {
               r1++;
               break;
              }
            //---
            r1++;
            r2--;
           }
        }
      //--- Recursive continuation of the algorithm, until the beginning of the range is reached
      if(beg<r2)
         QuickSort(beg,r2,c,mode);
      //--- Narrow the range for the next iteration
      beg=r1;
      r2=end;
     }
  }
//+------------------------------------------------------------------+
//| Comparing the values on the specified sorting condition          |
//+------------------------------------------------------------------+
//| direction: true (>), false (<)                                   |
//+------------------------------------------------------------------+
bool CTable::CheckSortCondition(uint column_index,uint row_index,const string check_value,const bool direction)
  {
   bool condition=false;
//---
   switch(m_vcolumns[column_index].m_type)
     {
      case TYPE_STRING :
        {
         string v1=m_vcolumns[column_index].m_vrows[row_index];
         string v2=check_value;
         condition=(direction)? v1>v2 : v1<v2;
         break;
        }
      //---
      case TYPE_DOUBLE :
        {
         double v1=double(m_vcolumns[column_index].m_vrows[row_index]);
         double v2=double(check_value);
         condition=(direction)? v1>v2 : v1<v2;
         break;
        }
      //---
      case TYPE_DATETIME :
        {
         datetime v1=::StringToTime(m_vcolumns[column_index].m_vrows[row_index]);
         datetime v2=::StringToTime(check_value);
         condition=(direction)? v1>v2 : v1<v2;
         break;
        }
      //---
      default :
        {
         long v1=(long)m_vcolumns[column_index].m_vrows[row_index];
         long v2=(long)check_value;
         condition=(direction)? v1>v2 : v1<v2;
         break;
        }
     }
//---
   return(condition);
  }
//+------------------------------------------------------------------+
//| Swap the elements                                                |
//+------------------------------------------------------------------+
void CTable::Swap(uint c,uint r1,uint r2)
  {
//--- Iterate over all columns in a loop
   for(uint i=0; i<m_columns_total; i++)
     {
      //--- Swap the text
      string temp_text          =m_vcolumns[i].m_vrows[r1];
      m_vcolumns[i].m_vrows[r1] =m_vcolumns[i].m_vrows[r2];
      m_vcolumns[i].m_vrows[r2] =temp_text;
      //--- Swap the number of decimal places
      uint temp_digits           =m_vcolumns[i].m_digits[r1];
      m_vcolumns[i].m_digits[r1] =m_vcolumns[i].m_digits[r2];
      m_vcolumns[i].m_digits[r2] =temp_digits;
      //--- Swap the text alignment
      ENUM_ALIGN_MODE temp_text_align =m_vcolumns[i].m_text_align[r1];
      m_vcolumns[i].m_text_align[r1]  =m_vcolumns[i].m_text_align[r2];
      m_vcolumns[i].m_text_align[r2]  =temp_text_align;
      //--- Swap the text color
      color temp_text_color          =m_vcolumns[i].m_text_color[r1];
      m_vcolumns[i].m_text_color[r1] =m_vcolumns[i].m_text_color[r2];
      m_vcolumns[i].m_text_color[r2] =temp_text_color;
      //--- If the Zebra mode is disabled
      if(m_is_zebra_format_rows==clrNONE)
        {
         //--- Swap the cell color
         color temp_cell_color          =m_vcolumns[i].m_cell_color[r1];
         m_vcolumns[i].m_cell_color[r1] =m_vcolumns[i].m_cell_color[r2];
         m_vcolumns[i].m_cell_color[r2] =temp_cell_color;
        }
     }
  }
//+------------------------------------------------------------------+
//| Changing the table header color when hovered by mouse cursor     |
//+------------------------------------------------------------------+
void CTable::HeaderColorByHover(void)
  {
//--- Leave, if the column sorting mode is disabled
   if(!m_is_sort_mode || !m_fix_first_row)
      return;
//---
   for(uint c=0; c<m_visible_columns_total; c++)
     {
      //--- Check the focus on the current header
      bool condition=m_mouse.X()>m_columns[c].m_rows[0].X() && m_mouse.X()<m_columns[c].m_rows[0].X2() && 
                     m_mouse.Y()>m_columns[c].m_rows[0].Y() && m_mouse.Y()<m_columns[c].m_rows[0].Y2();
      //---
      if(!condition)
         m_columns[c].m_rows[0].BackColor(m_headers_color);
      else
        {
         if(!m_mouse.LeftButtonState())
            m_columns[c].m_rows[0].BackColor(m_headers_color_hover);
         else
            m_columns[c].m_rows[0].BackColor(m_headers_color_pressed);
        }
     }
  }
//+------------------------------------------------------------------+
//| Change the table row color when hovered                          |
//+------------------------------------------------------------------+
void CTable::RowColorByHover(void)
  {
//--- Leave, if row highlighting when hovered is disabled
   if(!m_lights_hover || !m_read_only)
      return;
//--- The last index of columns (to save computations)
   uint last_index=(m_columns_total<m_visible_columns_total)? m_columns_total-1 : m_visible_columns_total-1;
//--- Shift by one index, if the fixed header mode is enabled
   uint l=(m_fix_first_column) ? 1 : 0;
//--- If entered the table again
   if(m_prev_item_index_focus==WRONG_VALUE)
     {
      //--- Check the focus on the current row
      CheckItemFocus();
     }
   else
     {
      //--- Check the focus on the current row
      uint p=m_prev_item_index_focus;
      bool condition=m_mouse.X()>m_columns[0].m_rows[p].X() && m_mouse.X()<m_columns[last_index].m_rows[p].X2() && 
                     m_mouse.Y()>m_columns[0].m_rows[p].Y() && m_mouse.Y()<m_columns[0].m_rows[p].Y2();
      //--- If moved to another row
      if(!condition)
        {
         //--- Get the current position of slider of the vertical scrollbar
         uint v=m_scrollv.CurrentPos();
         //--- Get the color of the previous cell in focus
         uint i=p+v;
         //--- Reset the color of the previous row
         for(uint c=l; c<m_columns_total && c<m_visible_columns_total; c++)
            m_columns[c].m_rows[p].BackColor(m_vcolumns[c].m_cell_color[i]);
         //--- Reset the focus
         m_prev_item_index_focus=WRONG_VALUE;
         //--- Check the focus on the current row
         CheckItemFocus();
        }
     }
  }
//+------------------------------------------------------------------+
//| Check the focus of list view row when the cursor is hovering     |
//+------------------------------------------------------------------+
void CTable::CheckItemFocus(void)
  {
//--- The last index of columns (to save computations)
   uint last_index=(m_columns_total<m_visible_columns_total)? m_columns_total-1 : m_visible_columns_total-1;
//--- Flag for found selected row
   bool is_find_selected_item=false;
//--- Shift by one index, if the fixed header mode is enabled
   uint t=(m_fix_first_row) ? 1 : 0;
   uint l=(m_fix_first_column) ? 1 : 0;
//--- Get the current position of slider of the vertical scrollbar
   uint v=m_scrollv.CurrentPos()+t;
//--- Rows
   for(uint r=t; r<m_visible_rows_total; r++)
     {
      //--- Check to prevent exceeding the array range
      if(!(v>=t && v<m_rows_total))
         continue;
      //--- If the selected row is not found yet
      if(!is_find_selected_item)
        {
         //--- Skip, if in the "Read only" mode, row selecting is enabled and the selected item is reached
         if(m_selected_item==v && m_read_only && m_selectable_row)
           {
            v++;
            is_find_selected_item=true;
            continue;
           }
        }
      //--- Highlight the row, if it is hovered
      if(m_mouse.X()>m_columns[0].m_rows[r].X() && m_mouse.X()<m_columns[last_index].m_rows[r].X2() &&
         m_mouse.Y()>m_columns[0].m_rows[r].Y() && m_mouse.Y()<m_columns[0].m_rows[r].Y2())
        {
         for(uint c=l; c<m_visible_columns_total; c++)
            m_columns[c].m_rows[r].BackColor(m_cell_color_hover);
         //--- Store the row
         m_prev_item_index_focus=(int)r;
         break;
        }
      //---
      v++;
     }
  }
//+------------------------------------------------------------------+
//| Formats the table in Zebra style                                 |
//+------------------------------------------------------------------+
void CTable::ZebraFormatRows(void)
  {
//--- Leave, if the mode is disabled
   if(m_is_zebra_format_rows==clrNONE)
      return;
//--- The default color
   color clr=m_cell_color;
//--- 
   for(uint c=0; c<m_columns_total; c++)
     {
      for(uint r=0; r<m_rows_total; r++)
        {
         if(m_fix_first_row)
           {
            if(r==0)
               continue;
            //---
            clr=(r%2==0)? m_is_zebra_format_rows : m_cell_color;
           }
         else
            clr=(r%2==0)? m_cell_color : m_is_zebra_format_rows;
         //--- Store the cell background color in the common array
         m_vcolumns[c].m_cell_color[r]=clr;
        }
     }
  }
//+------------------------------------------------------------------+
//| Fast forward the table data                                      |
//+------------------------------------------------------------------+
void CTable::FastSwitching(void)
  {
//--- Leave, if there is no focus on the list view
   if(!CElementBase::MouseFocus())
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
         m_scrollv.OnClickScrollInc(m_scrollv.ScrollIncName());
      //--- If scrolling down
      else if(m_scrollv.ScrollDecState())
         m_scrollv.OnClickScrollDec(m_scrollv.ScrollDecName());
      //--- If scrolling left
      else if(m_scrollh.ScrollIncState())
         m_scrollh.OnClickScrollInc(m_scrollh.ScrollIncName());
      //--- If scrolling right
      else if(m_scrollh.ScrollDecState())
         m_scrollh.OnClickScrollDec(m_scrollh.ScrollDecName());
      //--- Update data and properties
      UpdateTable();
      //--- Highlighting the item
      HighlightSelectedItem();
     }
  }
//+------------------------------------------------------------------+
//| Checking for exceeding the range of columns                      |
//+------------------------------------------------------------------+
bool CTable::CheckOutOfColumnRange(const uint column_index)
  {
//--- Checking for exceeding the column range
   uint csize=::ArraySize(m_vcolumns);
   if(csize<1 || column_index>=csize)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Checking for exceeding the range of columns and rows             |
//+------------------------------------------------------------------+
bool CTable::CheckOutOfRange(const uint column_index,const uint row_index)
  {
//--- Checking for exceeding the column range
   uint csize=::ArraySize(m_vcolumns);
   if(csize<1 || column_index>=csize)
      return(false);
//--- Checking for exceeding the row range
   uint rsize=::ArraySize(m_vcolumns[column_index].m_vrows);
   if(rsize<1 || row_index>=rsize)
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Resizing the arrays of row                                       |
//+------------------------------------------------------------------+
void CTable::RowResize(const uint column_index,const uint new_size)
  {
   ::ArrayResize(m_vcolumns[column_index].m_vrows,new_size);
   ::ArrayResize(m_vcolumns[column_index].m_digits,new_size);
   ::ArrayResize(m_vcolumns[column_index].m_text_align,new_size);
   ::ArrayResize(m_vcolumns[column_index].m_text_color,new_size);
   ::ArrayResize(m_vcolumns[column_index].m_cell_color,new_size);
  }
//+------------------------------------------------------------------+
//| Initialization of cells with default values                      |
//+------------------------------------------------------------------+
void CTable::CellInitialize(const uint column_index,const int row_index=WRONG_VALUE)
  {
   if(row_index==WRONG_VALUE)
     {
      m_vcolumns[column_index].m_type=TYPE_STRING;
      ::ArrayInitialize(m_vcolumns[column_index].m_digits,0);
      ::ArrayInitialize(m_vcolumns[column_index].m_text_align,m_align_mode);
      ::ArrayInitialize(m_vcolumns[column_index].m_cell_color,m_cell_color);
      ::ArrayInitialize(m_vcolumns[column_index].m_text_color,m_cell_text_color);
     }
   else
     {
      m_vcolumns[column_index].m_digits[row_index]     =0;
      m_vcolumns[column_index].m_text_align[row_index] =m_align_mode;
      m_vcolumns[column_index].m_cell_color[row_index] =m_cell_color;
      m_vcolumns[column_index].m_text_color[row_index] =m_cell_text_color;
     }
  }
//+------------------------------------------------------------------+
//| Calculation of the table size along the X axis                   |
//+------------------------------------------------------------------+
int CTable::CalculationXSize(void)
  {
   return((m_x_size<1 || m_auto_xresize_mode)? m_wnd.X2()-m_x-m_auto_xresize_right_offset : m_x_size);
  }
//+------------------------------------------------------------------+
//| Calculation of the table size along the Y axis                   |
//+------------------------------------------------------------------+
int CTable::CalculationYSize(void)
  {
   return(m_row_y_size*(int)m_visible_rows_total-((int)m_visible_rows_total-1)+2);
  }
//+------------------------------------------------------------------+
//| Calculation of the X coordinate of the cell                      |
//+------------------------------------------------------------------+
int CTable::CalculationCellX(const int column_index=0)
  {
   return((column_index>0)? m_columns[column_index-1].m_rows[0].X2()-1 : CElementBase::X()+1);
  }
//+------------------------------------------------------------------+
//| Calculation of the Y coordinate of the cell                      |
//+------------------------------------------------------------------+
int CTable::CalculationCellY(const int row_index=0)
  {
   return((row_index>0)? m_columns[0].m_rows[row_index-1].Y2()-1 : CElementBase::Y()+1);
  }
//+------------------------------------------------------------------+
//| Calculation of the column width                                  |
//+------------------------------------------------------------------+
int CTable::CalculationColumnWidth(const bool is_last_column=false)
  {
   int width=0;
//--- Check for presence of a vertical scrollbar
   bool is_scrollv=m_rows_total>m_visible_rows_total;
//---
   if(!is_last_column)
     {
      if(m_visible_columns_total==1)
         width=(is_scrollv)? m_x_size-m_scrollv.ScrollWidth() : width=m_x_size-2;
      else
        {
         if(is_scrollv)
            width=(m_x_size-m_scrollv.ScrollWidth())/int(m_visible_columns_total);
         else
            width=m_x_size/(int)m_visible_columns_total+1;
        }
     }
   else
     {
      width=CalculationColumnWidth();
      int last_column=(int)m_visible_columns_total-1;
      int w=m_x_size-(width*last_column-last_column);
      width=(is_scrollv) ? w-m_scrollv.ScrollWidth()-1 : w-2;
     }
//---
   return(width);
  }
//+------------------------------------------------------------------+
//| Changing the width of columns                                    |
//+------------------------------------------------------------------+
void CTable::ColumnsXResize(void)
  {
//--- Calculation of column widths
   int width=CalculationColumnWidth();
//--- Columns
   for(uint c=0; c<m_columns_total && c<m_visible_columns_total; c++)
     {
      //--- Calculation of the X coordinate
      int x=CalculationCellX(c);
      //--- Adjust the width of the last column
      if(c+1>=m_visible_columns_total)
         width=CalculationColumnWidth(true);
      //--- Rows
      for(uint r=0; r<m_rows_total && r<m_visible_rows_total; r++)
        {
         //--- Coordinates
         m_columns[c].m_rows[r].X(x);
         m_columns[c].m_rows[r].X_Distance(x);
         //--- Width
         m_columns[c].m_rows[r].XSize(width);
         m_columns[c].m_rows[r].X_Size(width);
         //--- Margins from the edge of the panel
         m_columns[c].m_rows[r].XGap(CalculateXGap(x));
        }
     }
//--- Leave, if table is not sorted
   if(m_is_sorted_column_index==WRONG_VALUE)
      return;
//--- Shift by one index, if the fixed header mode is enabled
   int l=(m_fix_first_column) ? 1 : 0;
//--- Get the current positions of sliders of the vertical and horizontal scrollbars
   int h=m_scrollh.CurrentPos()+l;
//--- If not exceeding the array range
   if(m_is_sorted_column_index>=h && m_is_sorted_column_index<(int)m_visible_columns_total)
     {
      //--- Shifting the arrow to the sorted table column
      ShiftSortArrow(m_is_sorted_column_index);
     }
  }
//+------------------------------------------------------------------+
//| Changing the table size along the Y axis                         |
//+------------------------------------------------------------------+
void CTable::YResize(void)
  {
   if(m_y_size<=CalculationYSize())
     {
      m_y_size=m_y_size+m_scrollh.ScrollWidth()-1;
      m_area.YSize(m_y_size);
      m_area.Y_Size(m_y_size);
      m_scrollh.YDistance(CElementBase::Y2()-m_scrollh.ScrollWidth());
     }
  }
//+------------------------------------------------------------------+
//| Change the width at the right edge of the form                   |
//+------------------------------------------------------------------+
void CTable::ChangeWidthByRightWindowSide(void)
  {
//--- Leave, if anchoring mode to the right side of the window is enabled
   if(m_anchor_right_window_side)
      return;
//--- Calculate and set the new size to the table background
   int x_size=m_wnd.X2()-m_area.X()-m_auto_xresize_right_offset;
   CElementBase::XSize(x_size);
   m_area.XSize(x_size);
   m_area.X_Size(x_size);
//--- Calculate and set the new coordinate for the vertical scrollbar
   int x=m_area.X2()-m_scrollv.ScrollWidth();
   m_scrollv.XDistance(x);
//--- Calculate and change the width of the horizontal scrollbar
   x_size=CElementBase::XSize()-m_scrollh.ScrollWidth()+1;
   m_scrollh.ChangeXSize(x_size);
//--- Calculation of column widths
   ColumnsXResize();
//--- Synchronize the table data with the position of the scrollbar thumb
   HorizontalScrolling(m_scrollh.CurrentPos());
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
