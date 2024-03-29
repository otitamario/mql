//+------------------------------------------------------------------+
//|                                                      TextBox.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "Scrolls.mqh"
#include "..\Keys.mqh"
#include "..\Element.mqh"
#include "..\TimeCounter.mqh"
#include <Charts\Chart.mqh>
//+------------------------------------------------------------------+
//| Class for creating a multiline text box                          |
//+------------------------------------------------------------------+
class CTextBox : public CElement
  {
private:
   //--- Instance of the class for working with the keyboard
   CKeys             m_keys;
   //--- Class instance for managing the chart
   CChart            m_chart;
   //--- Object for working with the time counter
   CTimeCounter      m_counter;
   //--- Objects for creating the element
   CRectCanvas       m_canvas;
   CScrollV          m_scrollv;
   CScrollH          m_scrollh;
   //--- Characters and their properties
   struct StringOptions
     {
      string            m_symbol[];    // Символы
      int               m_width[];     // Ширина символов
      bool              m_end_of_line; // Признак окончания строки
     };
   StringOptions     m_lines[];
   //--- Total size and size of the visible part of the control
   int               m_area_x_size;
   int               m_area_y_size;
   int               m_area_visible_x_size;
   int               m_area_visible_y_size;
   //--- Background color
   color             m_area_color;
   color             m_area_color_locked;
   //--- Text color
   color             m_text_color;
   color             m_text_color_locked;
   //--- Default text color
   color             m_default_text_color;
   //--- Frame color
   color             m_border_color;
   color             m_border_color_hover;
   color             m_border_color_locked;
   color             m_border_color_activated;
   //--- Default text
   string            m_default_text;
   //--- Variable for working with a string
   string            m_temp_input_string;
   //--- Text offsets from the text box edges
   int               m_text_x_offset;
   int               m_text_y_offset;
   //--- Current coordinates of the text cursor
   int               m_text_cursor_x;
   int               m_text_cursor_y;
   //--- Current position of the text cursor
   uint              m_text_cursor_x_pos;
   uint              m_text_cursor_y_pos;
   //--- For calculation of the boundaries of the visible area of the text box
   int               m_x_limit;
   int               m_y_limit;
   int               m_x2_limit;
   int               m_y2_limit;
   //--- Multiline mode
   bool              m_multi_line_mode;
   //--- Режим "Перенос по словам"
   bool              m_word_wrap_mode;
   //--- Read-only mode
   bool              m_read_only_mode;
   //--- State of the text edit box
   bool              m_text_edit_state;
   //--- Control state
   bool              m_text_box_state;
   //--- Timer counter for fast forwarding the list view
   int               m_timer_counter;
   //--- Priorities of the left mouse button press
   int               m_text_edit_zorder;
   //---
public:
                     CTextBox(void);
                    ~CTextBox(void);
   //--- Methods for creating the control
   bool              CreateTextBox(const long chart_id,const int subwin,const int x_gap,const int y_gap);
   //---
private:
   bool              CreateCanvas(void);
   bool              CreateScrollV(void);
   bool              CreateScrollH(void);
   //---
public:
   //--- Returns pointers to the scrollbars
   CScrollV         *GetScrollVPointer(void)                   { return(::GetPointer(m_scrollv));  }
   CScrollH         *GetScrollHPointer(void)                   { return(::GetPointer(m_scrollh));  }
   //--- (1) State of the text edit box, (2) get/set the availability state of the control
   bool              TextEditState(void)                 const { return(m_text_edit_state);        }
   bool              TextBoxState(void)                  const { return(m_text_box_state);         }
   void              TextBoxState(const bool state);
   //--- Color of the background in different states
   void              AreaColor(const color clr)                { m_area_color=clr;                 }
   void              AreaColorLocked(const color clr)          { m_area_color_locked=clr;          }
   //--- Color of the text in different states
   void              TextColor(const color clr)                { m_text_color=clr;                 }
   void              TextColorLocked(const color clr)          { m_text_color_locked=clr;          }
   //--- Colors of the frame in different states
   void              BorderColor(const color clr)              { m_border_color=clr;               }
   void              BorderColorHover(const color clr)         { m_border_color_hover=clr;         }
   void              BorderColorLocked(const color clr)        { m_border_color_locked=clr;        }
   void              BorderColorActivated(const color clr)     { m_border_color_activated=clr;     }
   //--- (1) Default text and (2) default text color
   void              DefaultText(const string text)            { m_default_text=text;              }
   void              DefaultTextColor(const color clr)         { m_default_text_color=clr;         }
   //--- (1) Многострочный режим, (2) режим "Перенос по словам"
   void              MultiLineMode(const bool mode)            { m_multi_line_mode=mode;           }
   void              WordWrapMode(const bool mode)             { m_word_wrap_mode=mode;            }
   //--- Read-only mode
   bool              ReadOnlyMode(void)                  const { return(m_read_only_mode);         }
   void              ReadOnlyMode(const bool mode)             { m_read_only_mode=mode;            }
   //--- Text offsets from the text box edges
   void              TextXOffset(const int x_offset)           { m_text_x_offset=x_offset;         }
   void              TextYOffset(const int y_offset)           { m_text_y_offset=y_offset;         }
   //--- Returns the index of the (1) line, (2) character where the text cursor is located,
   //    (3) the number of lines, (4) the number of characters in the specified line
   uint              TextCursorLine(void)                      { return(m_text_cursor_y_pos);      }
   uint              TextCursorColumn(void)                    { return(m_text_cursor_x_pos);      }
   uint              LinesTotal(void)                          { return(::ArraySize(m_lines));     }
   uint              ColumnsTotal(const uint line_index);
   //--- Information about the text cursor (line/number of lines, column/number of columns)
   string            TextCursorInfo(void);
   //--- Adds a line 
   void              AddLine(const string added_text="");
   //--- Adds text to the specified line 
   void              AddText(const uint line_index,const string added_text);
   //--- Clears the text edit box
   void              ClearTextBox(void);
   //--- Table scrolling: (1) vertical and (2) horizontal
   void              VerticalScrolling(const int pos=WRONG_VALUE);
   void              HorizontalScrolling(const int pos=WRONG_VALUE);
   //--- Shift the data relative to the positions of scrollbars
   void              ShiftData(void);
   //--- Updates the text edit box to display the recent changes
   void              UpdateTextBox(void);
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
   virtual void      ResetColors(void) {}
   //---
private:
   //--- Handling of the press on the element
   bool              OnClickTextBox(const string clicked_object);

   //--- Handling a keypress
   bool              OnPressedKey(const long key_code);
   //--- Handling the pressing of the Backspace key
   bool              OnPressedKeyBackspace(const long key_code);
   //--- Handling the pressing of the Enter key
   bool              OnPressedKeyEnter(const long key_code);
   //--- Handling the pressing of the Left key
   bool              OnPressedKeyLeft(const long key_code);
   //--- Handling the pressing of the Right key
   bool              OnPressedKeyRight(const long key_code);
   //--- Handling the pressing of the Up key
   bool              OnPressedKeyUp(const long key_code);
   //--- Handling the pressing of the Down key
   bool              OnPressedKeyDown(const long key_code);
   //--- Handling the pressing of the Home key
   bool              OnPressedKeyHome(const long key_code);
   //--- Handling the pressing of the End key
   bool              OnPressedKeyEnd(const long key_code);

   //--- Handling the pressing of the Ctrl + Left keys
   bool              OnPressedKeyCtrlAndLeft(const long key_code);
   //--- Handling the pressing of the Ctrl + Right keys
   bool              OnPressedKeyCtrlAndRight(const long key_code);
   //--- Handling the simultaneous pressing of the Ctrl + Home keys
   bool              OnPressedKeyCtrlAndHome(const long key_code);
   //--- Handling the simultaneous pressing of the Ctrl + End keys
   bool              OnPressedKeyCtrlAndEnd(const long key_code);

   //--- Обработка нажатия на клавише Ctrl + Shift + Left
   bool              OnPressedKeyCtrlShiftAndLeft(const long key_code);
   //--- Обработка нажатия на клавише Ctrl + Shift + Right
   bool              OnPressedKeyCtrlShiftAndRight(const long key_code);
   //--- Обработка нажатия на клавише Ctrl + Shift + Up
   bool              OnPressedKeyCtrlShiftAndUp(const long key_code);
   //--- Обработка нажатия на клавише Ctrl + Shift + Down
   bool              OnPressedKeyCtrlShiftAndDown(const long key_code);
   //--- Обработка нажатия на клавише Ctrl + Shift + Home
   bool              OnPressedKeyCtrlShiftAndHome(const long key_code);
   //--- Обработка нажатия на клавише Ctrl + Shift + End
   bool              OnPressedKeyCtrlShiftAndEnd(const long key_code);
   //---
private:
   //--- Deactivates the text box
   void              DeactivateTextBox(void);
   //--- Fast scrolling of the text box
   void              FastSwitching(void);

   //--- Output text to canvas
   void              TextOut(void);
   //--- Draw text
   void              DrawText(void);
   //--- Draws the text cursor
   void              DrawCursor(void);
   //--- Displays the text and blinking cursor
   void              DrawTextAndCursor(const bool show_state=false);
   //--- Draws the frame
   void              DrawBorder(void);

   //--- Returns the current background color
   uint              AreaColorCurrent(void);
   //--- Returns the current text color
   uint              TextColorCurrent(void);
   //--- Returns the current frame color
   uint              BorderColorCurrent(void);
   //--- Changing the object colors
   void              ChangeObjectsColor(void);

   //--- Builds a string from characters
   string            CollectString(const uint line_index,const uint symbols_total=0);
   //--- Adds a character and its properties to the arrays of the structure
   void              AddSymbol(const string key_symbol);
   //--- Deletes a character
   void              DeleteSymbol(void);

   //--- Returns the line height
   uint              LineHeight(void);
   //--- Возвращает ширину строки от указанного символа в пикселях
   uint              LineWidth(const uint symbol_index,const uint line_index);
   //--- Returns the maximum line width
   uint              MaxLineWidth(void);

   //--- Shifts the lines up by one position
   void              ShiftOnePositionUp(void);
   //--- Shifts the lines down by one position
   void              ShiftOnePositionDown(void);

   //--- Check for presence of the mandatory first line
   uint              CheckFirstLine(void);
   //--- Resizes the arrays of properties for the specified line
   void              ArraysResize(const uint line_index,const uint new_size);
   //--- Makes a copy of the specified (source) line to a new location (destination)
   void              LineCopy(const uint destination,const uint source);
   //--- Clears the specified line
   void              ClearLine(const uint line_index);

   //--- Set the cursor at the specified position
   void              SetTextCursor(const uint x_pos,const uint y_pos);
   //--- Adjusting the text cursor along the X axis
   void              CorrectingTextCursorXPos(const int x_pos=WRONG_VALUE);

   //--- Calculation of coordinates for the text cursor
   void              CalculateTextCursorX(void);
   void              CalculateTextCursorY(void);

   //--- Calculation of the text box boundaries
   void              CalculateBoundaries(void);
   void              CalculateXBoundaries(void);
   void              CalculateYBoundaries(void);
   //--- Calculation of the X position of the scrollbar thumb on the left edge of the text box
   int               CalculateScrollThumbX(void);
   //--- Calculation of the X position of the scrollbar thumb on the right edge of the text box
   int               CalculateScrollThumbX2(void);
   //--- Calculation of the Y position of the scrollbar thumb on the top edge of the text box
   int               CalculateScrollThumbY(void);
   //--- Calculation of the Y position of the scrollbar thumb on the bottom edge of the text box
   int               CalculateScrollThumbY2(void);

   //--- Calculates the size of the text box
   void              CalculateTextBoxSize(void);
   bool              CalculateTextBoxXSize(void);
   bool              CalculateTextBoxYSize(void);
   //--- Change the main size of the control
   void              ChangeMainSize(const int x_size,const int y_size);
   //--- Resize the text box
   void              ChangeTextBoxSize(const bool x_offset=false,const bool y_offset=false);
   //--- Resize the scrollbars
   void              ChangeScrollsSize(void);

   //--- Перенос по словам
   void              WordWrap(void);
   //--- Возвращает индексы первых видимых символа и пробела
   bool              CheckForOverflow(const uint line_index,int &symbol_index,int &space_index);
   //--- Количество слов в указанной строке
   uint              WordsTotal(const uint line_index);
   //--- Возвращает количество переносимых символов
   bool              WrapSymbolsTotal(const uint line_index,uint &wrap_symbols_total);
   //--- Возвращает индекс символа пробела по его номеру 
   uint              SymbolIndexBySpaceNumber(const uint line_index,const uint space_index);
   //--- Перемещает строки
   void              MoveLines(const uint from_index,const uint to_index,const bool to_down=true);
   //--- Перемещение символов в указанной строке
   void              MoveSymbols(const uint line_index,const uint from_pos,const uint to_pos,const bool to_left=true);
   //--- Добавление текста в указанную строку
   void              AddToString(const uint line_index,const string text);
   //--- Копирует в переданный массив символы для переноса на другую строку
   void              CopyWrapSymbols(const uint line_index,const uint start_pos,const uint symbols_total,string &array[]);
   //--- Вставляет символы из переданного массива в указанную строку
   void              PasteWrapSymbols(const uint line_index,const uint start_pos,string &array[]);
   //--- Перенос текста на следующую строку
   void              WrapTextToNewLine(const uint curr_line_index,const uint symbol_index,const bool by_pressed_enter=false);
   //--- Перенос текста из указанной строки в предыдущую
   void              WrapTextToPrevLine(const uint next_line_index,const uint wrap_symbols_total,const bool is_all_text=false);

   //--- Change the width at the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
   //--- Change the height at the bottom edge of the window
   virtual void      ChangeHeightByBottomWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTextBox::CTextBox(void) : m_area_color(clrWhite),
                           m_area_color_locked(clrWhiteSmoke),
                           m_text_color(clrBlack),
                           m_text_color_locked(clrSilver),
                           m_border_color(clrGray),
                           m_border_color_hover(clrBlack),
                           m_border_color_locked(clrSilver),
                           m_border_color_activated(clrCornflowerBlue),
                           m_default_text_color(clrTomato),
                           m_default_text(""),
                           m_temp_input_string(""),
                           m_text_x_offset(5),
                           m_text_y_offset(4),
                           m_multi_line_mode(false),
                           m_word_wrap_mode(false),
                           m_read_only_mode(false),
                           m_text_box_state(true),
                           m_text_edit_state(false),
                           m_text_cursor_x_pos(0),
                           m_text_cursor_y_pos(0)
  {
//--- Store the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
//--- The initial coordinates of the text cursor
   m_text_cursor_x=m_text_x_offset;
   m_text_cursor_y=m_text_y_offset;
//--- Setting parameters for the timer counter
   m_counter.SetParameters(16,200);
//--- The mandatory first line of the multiline text box
   ::ArrayResize(m_lines,1);
//--- Установим признак окончания строки
   m_lines[0].m_end_of_line=true;
//--- Set priorities of the left mouse button click
   m_text_edit_zorder=2;
//--- Get the ID of the current chart
   m_chart.Attach();
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTextBox::~CTextBox(void)
  {
//--- Detach from the chart
   m_chart.Detach();
  }
//+------------------------------------------------------------------+
//| Chart event handler                                              |
//+------------------------------------------------------------------+
void CTextBox::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
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
      //--- Check for the status of the scrollbars
      bool is_scroll_state=m_scrollv.ScrollBarControl() || m_scrollh.ScrollBarControl();
      //--- If (1) not in focus and (2) the left mouse button is pressed and (3) not in the mode of moving the scrollbars
      if(!CElementBase::MouseFocus() && m_mouse.LeftButtonState() && !is_scroll_state)
        {
         //--- Send a message about the end of the line editing mode in the text box, if the text box was active
         if(m_text_edit_state)
            ::EventChartCustom(m_chart_id,ON_END_EDIT,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
         //--- Deactivate the text box
         DeactivateTextBox();
        }
      //--- Changing the object colors
      ChangeObjectsColor();
      //--- Leave, if the multiline mode is disabled
      if(!m_multi_line_mode)
         return;
      //--- If the scrollbar is active
      if(is_scroll_state)
        {
         //--- Shift the data relative to the scrollbars
         ShiftData();
         //--- Deactivate the text box
         DeactivateTextBox();
        }
      //--- If one of the scrollbar buttons is pressed
      if(m_mouse.LeftButtonState() && 
         (m_scrollv.ScrollIncState() || m_scrollv.ScrollDecState() || 
         m_scrollh.ScrollIncState() || m_scrollh.ScrollDecState()))
        {
         //--- Deactivate the text box
         DeactivateTextBox();
        }
      //---
      return;
     }
//--- Handling the left mouse button click on the object
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      //--- Pressing the text box
      if(OnClickTextBox(sparam))
         return;
      //--- If the scrollbar button was pressed
      if(m_scrollv.OnClickScrollInc(sparam) || m_scrollv.OnClickScrollDec(sparam) ||
         m_scrollh.OnClickScrollInc(sparam) || m_scrollh.OnClickScrollDec(sparam))
        {
         //--- Shift the data
         ShiftData();
        }
      //---
      return;
     }
//--- Handling the pressing of keyboard button
   if(id==CHARTEVENT_KEYDOWN)
     {
      //--- Pressing a character key
      if(OnPressedKey(lparam))
         return;
      //--- Pressing the Backspace key
      if(OnPressedKeyBackspace(lparam))
         return;
      //--- Pressing the Enter key
      if(OnPressedKeyEnter(lparam))
         return;
      //--- Pressing the Left key
      if(OnPressedKeyLeft(lparam))
         return;
      //--- Pressing the Right key
      if(OnPressedKeyRight(lparam))
         return;
      //--- Pressing the Up key
      if(OnPressedKeyUp(lparam))
         return;
      //--- Pressing the Down key
      if(OnPressedKeyDown(lparam))
         return;
      //--- Pressing the Home key
      if(OnPressedKeyHome(lparam))
         return;
      //--- Pressing the End key
      if(OnPressedKeyEnd(lparam))
         return;
      //--- Simultaneous pressing of the Ctrl + Left keys
      if(OnPressedKeyCtrlAndLeft(lparam))
         return;
      //--- Simultaneous pressing of the Ctrl + Right keys
      if(OnPressedKeyCtrlAndRight(lparam))
         return;
      //--- Simultaneous pressing of the Ctrl + Home keys
      if(OnPressedKeyCtrlAndHome(lparam))
         return;
      //--- Simultaneous pressing of the Ctrl + End keys
      if(OnPressedKeyCtrlAndEnd(lparam))
         return;
      //--- Одновременное нажатие клавиш Ctrl + Shift + Left
      if(OnPressedKeyCtrlShiftAndLeft(lparam))
         return;
      //--- Одновременное нажатие клавиш Ctrl + Shift + Right
      if(OnPressedKeyCtrlShiftAndRight(lparam))
         return;
      //--- Одновременное нажатие клавиш Ctrl + Shift + Up
      if(OnPressedKeyCtrlShiftAndUp(lparam))
         return;
      //--- Одновременное нажатие клавиш Ctrl + Shift + Down
      if(OnPressedKeyCtrlShiftAndDown(lparam))
         return;
      //--- Одновременное нажатие клавиш Ctrl + Shift + Home
      if(OnPressedKeyCtrlShiftAndHome(lparam))
         return;
      //--- Одновременное нажатие клавиш Ctrl + Shift + End
      if(OnPressedKeyCtrlShiftAndEnd(lparam))
         return;
      //---
      return;
     }
//--- Handling the window maximization
   if(id==CHARTEVENT_CUSTOM+ON_WINDOW_UNROLL)
     {
      //--- Set the previous size to the text box
      ChangeTextBoxSize(true,true);
      return;
     }
  }
//+------------------------------------------------------------------+
//| Timer                                                            |
//+------------------------------------------------------------------+
void CTextBox::OnEventTimer(void)
  {
//--- If this is a drop-down element
   if(CElementBase::IsDropdown())
      FastSwitching();
//--- If this is not a drop-down element, take current availability of the form into consideration
   else
     {
      //--- Track the fast forward only if the form is not blocked
      if(!m_wnd.IsLocked())
         FastSwitching();
     }
//--- Pause between updates of the text cursor
   if(m_counter.CheckTimeCounter())
     {
      //--- Update the text cursor if the control is visible and the text box is activated
      if(CElementBase::IsVisible() && m_text_edit_state)
         DrawTextAndCursor();
     }
  }
//+------------------------------------------------------------------+
//| Creates the Tooltip object                                       |
//+------------------------------------------------------------------+
bool CTextBox::CreateTextBox(const long chart_id,const int subwin,const int x_gap,const int y_gap)
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
   m_x_size   =(m_x_size<0 || m_auto_xresize_mode)? m_wnd.X2()-CElementBase::X()-m_auto_xresize_right_offset : m_x_size;
   m_y_size   =(m_y_size<0 || m_auto_yresize_mode)? m_wnd.Y2()-CElementBase::Y()-m_auto_yresize_bottom_offset : m_y_size;
//--- Margins from the edge
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
//--- Calculate the size of the text box
   CalculateTextBoxSize();
//--- Creates the tooltip
   if(!CreateCanvas())
      return(false);
   if(!CreateScrollV())
      return(false);
   if(!CreateScrollH())
      return(false);
//--- Change the size of the text box
   ChangeTextBoxSize();
//--- В режиме переноса слов нужно повторно пересчитать и установить размеры
   if(m_word_wrap_mode)
     {
      CalculateTextBoxSize();
      ChangeTextBoxSize();
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the canvas for drawing                                   |
//+------------------------------------------------------------------+
bool CTextBox::CreateCanvas(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_text_box_canvas_"+(string)CElementBase::Id();
//--- Creates the tooltip
   if(!m_canvas.CreateBitmapLabel(m_chart_id,m_subwin,name,m_x,m_y,m_area_x_size,m_area_y_size,COLOR_FORMAT_ARGB_NORMALIZE))
      return(false);
//--- Attach to the chart
   if(!m_canvas.Attach(m_chart_id,name,m_subwin,1))
      return(false);
//--- Set properties
   m_canvas.Background(false);
   m_canvas.Tooltip("\n");
   m_canvas.Z_Order(m_text_edit_zorder);
//--- Margins from the edge
   m_canvas.XGap(CElement::CalculateXGap(m_x));
   m_canvas.YGap(CElement::CalculateYGap(m_y));
//--- Store the object pointer
   CElementBase::AddToArray(m_canvas);
//--- Set the size of the visible area
   m_canvas.SetInteger(OBJPROP_XSIZE,m_area_visible_x_size);
   m_canvas.SetInteger(OBJPROP_YSIZE,m_area_visible_y_size);
//--- Set the frame offset within the image along the X and Y axes
   m_canvas.SetInteger(OBJPROP_XOFFSET,0);
   m_canvas.SetInteger(OBJPROP_YOFFSET,0);
//--- Check for presence of the mandatory first line
   CheckFirstLine();
//--- Draw text
   DrawText();
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the vertical scrollbar                                   |
//+------------------------------------------------------------------+
bool CTextBox::CreateScrollV(void)
  {
//--- Store the form pointer
   m_scrollv.WindowPointer(m_wnd);
//--- If the multiline mode is enabled
   if(!m_multi_line_mode)
     {
      //--- Initialize the vertical scrollbar
      m_scrollv.Reinit(m_area_y_size,m_area_visible_y_size);
      return(true);
     }
//--- Coordinates
   int x=CElement::CalculateXGap(CElementBase::X2()-m_scrollv.ScrollWidth()-1);
   int y=CElement::CalculateYGap(CElementBase::Y()+1);
//--- Set properties
   m_scrollv.Id(CElementBase::Id());
   m_scrollv.IsDropdown(CElementBase::IsDropdown());
   m_scrollv.XSize(m_scrollv.ScrollWidth());
   m_scrollv.YSize(m_y_size-m_scrollv.ScrollWidth()-1);
   m_scrollv.AnchorRightWindowSide(m_anchor_right_window_side);
   m_scrollv.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating the scrollbar
   if(!m_scrollv.CreateScroll(m_chart_id,m_subwin,x,y,m_area_y_size,m_area_visible_y_size))
      return(false);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the horizontal scrollbar                                 |
//+------------------------------------------------------------------+
bool CTextBox::CreateScrollH(void)
  {
//--- Store the form pointer
   m_scrollh.WindowPointer(m_wnd);
//--- If the multiline mode is enabled
   if(!m_multi_line_mode)
     {
      //--- Initialize the horizontal scrollbar
      m_scrollh.Reinit(m_area_x_size,m_area_visible_x_size);
      return(true);
     }
//--- Coordinates
   int x=CElement::CalculateXGap(CElementBase::X()+1);
   int y=CElement::CalculateYGap(CElementBase::Y2()-m_scrollh.ScrollWidth()-1);
//--- Set properties
   m_scrollh.Id(CElementBase::Id());
   m_scrollh.IsDropdown(CElementBase::IsDropdown());
   m_scrollh.XSize(CElementBase::XSize()-m_scrollh.ScrollWidth()-1);
   m_scrollh.YSize(m_scrollh.ScrollWidth());
   m_scrollh.AnchorRightWindowSide(m_anchor_right_window_side);
   m_scrollh.AnchorBottomWindowSide(m_anchor_bottom_window_side);
//--- Creating the scrollbar
   if(!m_scrollh.CreateScroll(m_chart_id,m_subwin,x,y,m_area_x_size,m_area_visible_x_size))
      return(false);
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Setting the availability state of the control                    |
//+------------------------------------------------------------------+
void CTextBox::TextBoxState(const bool state)
  {
   m_text_box_state=state;
//--- Setting in relation of the current state
   if(!m_text_box_state)
     {
      //--- Priorities
      m_canvas.Z_Order(-1);
      //--- The edit box in the Read-only mode
      m_read_only_mode=true;
     }
   else
     {
      //--- Priorities
      m_canvas.Z_Order(m_text_edit_zorder);
      //--- The edit control in the edit mode
      m_read_only_mode=false;
     }
//--- Update the text box
   DrawText();
  }
//+------------------------------------------------------------------+
//| Returns the number of characters in the specified line           |
//+------------------------------------------------------------------+
uint CTextBox::ColumnsTotal(const uint line_index)
  {
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- Prevention of exceeding the array size
   uint check_index=(line_index<lines_total)? line_index : lines_total-1;
//--- Get the size of the array of characters in the line
   uint symbols_total=::ArraySize(m_lines[check_index].m_symbol);
//--- Return the number of characters
   return(symbols_total);
  }
//+------------------------------------------------------------------+
//| Information about the text cursor                                |
//+------------------------------------------------------------------+
string CTextBox::TextCursorInfo(void)
  {
//--- String components
   string lines_total        =(string)LinesTotal();
   string columns_total      =(string)ColumnsTotal(TextCursorLine());
   string text_cursor_line   =string(TextCursorLine()+1);
   string text_cursor_column =string(TextCursorColumn()+1);
//--- Generate the string
   string text_box_info="Ln "+text_cursor_line+"/"+lines_total+", "+"Col "+text_cursor_column+"/"+columns_total;
//--- Return the string
   return(text_box_info);
  }
//+------------------------------------------------------------------+
//| Adds a line                                                      |
//+------------------------------------------------------------------+
void CTextBox::AddLine(const string added_text="")
  {
//--- Leave, if the multiline mode is disabled
   if(!m_multi_line_mode)
      return;
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- Set the size of the arrays of the structure
   ::ArrayResize(m_lines,lines_total+1);
//--- Установим признак окончания строки
   m_lines[lines_total].m_end_of_line=true;
//--- Set the text
   m_canvas.FontSet(CElementBase::Font(),-CElementBase::FontSize()*10,FW_NORMAL);
//--- Добавим текст в строку
   AddToString(lines_total,added_text);
  }
//+------------------------------------------------------------------+
//| Adds text to the specified line                                  |
//+------------------------------------------------------------------+
void CTextBox::AddText(const uint line_index,const string added_text)
  {
//--- Leave, if an empty string is passed
   if(added_text=="")
      return;
//--- Get the size of the lines array, with a check for presence of the mandatory first line
   uint lines_total=CheckFirstLine();
//--- Prevention of exceeding the array size
   uint l=(line_index<lines_total)? line_index : lines_total-1;
//--- Корректировка индекса с учётом режима переноса по словам
   if(m_word_wrap_mode)
     {
      for(uint i=0,j=0; i<lines_total; i++)
        {
         //--- Считаем строки по признаку окончания
         if(m_lines[i].m_end_of_line)
           {
            //---
            if(l==j || i+1>=lines_total)
              {
               l=i;
               break;
              }
            //---
            j++;
           }
        }
     }
//--- Set the text
   m_canvas.FontSet(CElementBase::Font(),-CElementBase::FontSize()*10,FW_NORMAL);
//--- Добавим текст в строку
   AddToString(l,added_text);
  }
//+------------------------------------------------------------------+
//| Clears the text edit box                                         |
//+------------------------------------------------------------------+
void CTextBox::ClearTextBox(void)
  {
//--- Delete all lines except the first
   ::ArrayResize(m_lines,1);
//--- Clear the first line
   ClearLine(0);
  }
//+------------------------------------------------------------------+
//| Horizontal scrollbar of the text box                             |
//+------------------------------------------------------------------+
void CTextBox::HorizontalScrolling(const int pos=WRONG_VALUE)
  {
//--- To determine the position of the thumb
   int index=0;
//--- Index of the last position
   int last_pos_index=int(m_area_x_size-m_area_visible_x_size);
//--- Adjustment in case the range has been exceeded
   if(pos<0)
      index=last_pos_index;
   else
      index=(pos>last_pos_index)? last_pos_index : pos;
//--- Move the scrollbar thumb
   m_scrollh.MovingThumb(index);
//--- Shift the text box
   ShiftData();
  }
//+------------------------------------------------------------------+
//| Vertical scrollbar of the text box                               |
//+------------------------------------------------------------------+
void CTextBox::VerticalScrolling(const int pos=WRONG_VALUE)
  {
//--- To determine the position of the thumb
   int index=0;
//--- Index of the last position
   int last_pos_index=int(m_area_y_size-m_area_visible_y_size);
//--- Adjustment in case the range has been exceeded
   if(pos<0)
      index=last_pos_index;
   else
      index=(pos>last_pos_index)? last_pos_index : pos;
//--- Move the scrollbar thumb
   m_scrollv.MovingThumb(index);
//--- Shift the text box
   ShiftData();
  }
//+------------------------------------------------------------------+
//| Shifts the data relative to the scrollbars                       |
//+------------------------------------------------------------------+
void CTextBox::ShiftData(void)
  {
//--- Get the current positions of sliders of the vertical and horizontal scrollbars
   int h=m_scrollh.CurrentPos();
   int v=m_scrollv.CurrentPos();
//--- Calculation of the data position relative to the scrollbar thumbs
   long x=(m_area_x_size>m_area_visible_x_size && !m_word_wrap_mode)? h : 0;
   long y=(m_area_y_size>m_area_visible_y_size)? v : 0;
//--- Shift the data
   m_canvas.SetInteger(OBJPROP_XOFFSET,x);
   m_canvas.SetInteger(OBJPROP_YOFFSET,y);
//--- Draw text
   DrawText();
  }
//+------------------------------------------------------------------+
//| Update the text box to display the recent changes                |
//+------------------------------------------------------------------+
void CTextBox::UpdateTextBox(void)
  {
//--- Draw text
   DrawText();
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CTextBox::Moving(const int x,const int y,const bool moving_mode=false)
  {
//--- Leave, if the control is hidden
   if(!CElementBase::IsVisible())
      return;
//--- If the management is delegated to the window, identify its location
   if(!moving_mode)
      if(!CElement::CheckPressedInsideHeader())
         return;
//--- Storing coordinates in the element fields
   CElementBase::X(x+CElementBase::XGap());
   CElementBase::Y(y+CElementBase::YGap());
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
void CTextBox::Show(void)
  {
//--- Leave, if the element is already visible
   if(CElementBase::IsVisible())
      return;
//--- Make all the objects visible
   m_canvas.Timeframes(OBJ_ALL_PERIODS);
   m_scrollv.Show();
   m_scrollh.Show();
//--- Visible state
   CElementBase::IsVisible(true);
//--- Moving the element
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
//| Hides the element                                                |
//+------------------------------------------------------------------+
void CTextBox::Hide(void)
  {
//--- Leave, if the control is hidden
   if(!CElementBase::IsVisible())
      return;
//--- Hide all objects
   m_canvas.Timeframes(OBJ_NO_PERIODS);
   m_scrollv.Hide();
   m_scrollh.Hide();
//--- Visible state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CTextBox::Reset(void)
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
void CTextBox::Delete(void)
  {
//--- Removing objects
   m_canvas.Delete();
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- Emptying the control arrays
   for(uint i=0; i<lines_total; i++)
     {
      ::ArrayFree(m_lines[i].m_width);
      ::ArrayFree(m_lines[i].m_symbol);
     }
//---
   ::ArrayFree(m_lines);
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
//--- Initializing of variables by default values
   m_text_edit_state=false;
   CElementBase::IsVisible(true);
   CElementBase::MouseFocus(false);
  }
//+------------------------------------------------------------------+
//| Seth the priorities                                              |
//+------------------------------------------------------------------+
void CTextBox::SetZorders(void)
  {
//--- Leave, if the element is blocked
   if(!m_text_box_state)
      return;
//--- Set the priorities
   m_canvas.Z_Order(m_text_edit_zorder);
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CTextBox::ResetZorders(void)
  {
//--- Leave, if the element is blocked
   if(!m_text_box_state)
      return;
//--- Reset the priorities
   m_canvas.Z_Order(-1);
  }
//+------------------------------------------------------------------+
//| Handling clicking the control                                    |
//+------------------------------------------------------------------+
bool CTextBox::OnClickTextBox(const string clicked_object)
  {
//--- Leave, if it has a different object name
   if(m_canvas.Name()!=clicked_object)
     {
      //--- Send a message about the end of the line editing mode in the text box, if the text box was active
      if(m_text_edit_state)
         ::EventChartCustom(m_chart_id,ON_END_EDIT,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
      //--- Deactivate the text box
      DeactivateTextBox();
      return(false);
     }
//--- Leave, if (1) the Read-only mode is enabled or if (2) the control is blocked
   if(m_read_only_mode || !m_text_box_state)
      return(true);
//--- Leave, if the scrollbar is active
   if(m_scrollv.ScrollState() || m_scrollh.ScrollState())
      return(false);
//--- Disable chart management
   m_chart.SetInteger(CHART_KEYBOARD_CONTROL,false);
//--- Get the offset along the X and Y axes
   int xoffset=(int)m_canvas.GetInteger(OBJPROP_XOFFSET);
   int yoffset=(int)m_canvas.GetInteger(OBJPROP_YOFFSET);
//--- Determine the text edit box coordinates below the mouse cursor
   int x =m_mouse.X()-m_canvas.X()+xoffset;
   int y =m_mouse.Y()-m_canvas.Y()+yoffset;
//--- Get the line height
   int line_height=(int)LineHeight();
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- Determine the clicked character
   for(uint l=0; l<lines_total; l++)
     {
      //--- Set the initial coordinates for checking the condition
      int x_offset=m_text_x_offset;
      int y_offset=m_text_y_offset+((int)l*line_height);
      //--- Checking the condition along the Y axis
      bool y_pos_check=(l<lines_total-1)?(y>=y_offset && y<y_offset+line_height) : y>=y_offset;
      //--- If the click was not on this line, go to the next
      if(!y_pos_check)
         continue;
      //--- Get the size of the array of characters
      uint symbols_total=::ArraySize(m_lines[l].m_width);
      //--- If this is an empty line, move the cursor to the specified position and leave the cycle
      if(symbols_total<1)
        {
         SetTextCursor(0,l);
         HorizontalScrolling(0);
         break;
        }
      //--- Find the character that was clicked
      for(uint s=0; s<symbols_total; s++)
        {
         //--- If the character is found, move the cursor to the specified position and leave the cycle
         if(x>=x_offset && x<x_offset+m_lines[l].m_width[s])
           {
            SetTextCursor(s,l);
            l=lines_total;
            break;
           }
         //--- Add the width of the current character for the next check
         x_offset+=m_lines[l].m_width[s];
         //--- If this is the last character, move the cursor to the end of the line and leave the cycle
         if(s==symbols_total-1 && x>x_offset)
           {
            SetTextCursor(s+1,l);
            l=lines_total;
            break;
           }
        }
     }
//--- If the multiline text box mode is enabled
   if(m_multi_line_mode)
     {
      //--- Get the boundaries of the visible portion of the text box
      CalculateYBoundaries();
      //--- Get the Y coordinate of the cursor
      CalculateTextCursorY();
      //--- Move the scrollbar if the text cursor leaves the visible part
      if(m_text_cursor_y<=m_y_limit)
         VerticalScrolling(CalculateScrollThumbY());
      else
        {
         if(m_text_cursor_y+(int)LineHeight()>=m_y2_limit)
            VerticalScrolling(CalculateScrollThumbY2());
        }
     }
//--- Activate the text box
   m_text_edit_state=true;
//--- Update the text and the cursor
   DrawTextAndCursor(true);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_CLICK_TEXT_BOX,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
//| Handling a keypress                                              |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKey(const long key_code)
  {
//--- Leave, if the text box is not activated
   if(!m_text_edit_state)
      return(false);
//--- Get the key character
   string pressed_key=m_keys.KeySymbol(key_code);
//--- Leave, if there is no character
   if(pressed_key=="")
      return(false);
//--- Add the character and its properties
   AddSymbol(pressed_key);
//--- Calculate the size of the text box
   CalculateTextBoxSize();
//--- Set the new size to the text box
   ChangeTextBoxSize(true,true);
//--- Get the boundaries of the visible portion of the text box
   CalculateXBoundaries();
//--- Get the X coordinate of the cursor
   CalculateTextCursorX();
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_x>=m_x2_limit)
      HorizontalScrolling(CalculateScrollThumbX2());
//--- Если режим переноса слов включен
   if(m_word_wrap_mode)
     {
      //--- Get the boundaries of the visible portion of the text box
      CalculateYBoundaries();
      //--- Get the Y coordinate of the cursor
      CalculateTextCursorY();
      //--- Move the scrollbar if the text cursor leaves the visible part
      if(m_text_cursor_y+(int)LineHeight()>=m_y2_limit)
         VerticalScrolling(CalculateScrollThumbY2());
     }
//--- Update the text in the text box
   DrawTextAndCursor(true);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
//| Handling the pressing of the Backspace key                       |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyBackspace(const long key_code)
  {
//--- Leave, if it is not the Backspace key of if the text box is not activated
   if(key_code!=KEY_BACKSPACE || !m_text_edit_state)
      return(false);
//--- Delete the character, if the position is greater than zero
   if(m_text_cursor_x_pos>0)
      DeleteSymbol();
//--- Delete the line, if the position is zero and it is not the first line
   else if(m_text_cursor_y_pos>0)
     {
      //--- Shift the lines up by one position
      ShiftOnePositionUp();
     }
//--- Calculate the size of the text box
   CalculateTextBoxSize();
//--- Set the new size to the text box
   ChangeTextBoxSize(true,true);
//--- Get the boundaries of the visible portion of the text box
   CalculateBoundaries();
//--- Get the X and Y coordinates of the cursor
   CalculateTextCursorX();
   CalculateTextCursorY();
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_x<=m_x_limit)
      HorizontalScrolling(CalculateScrollThumbX());
   else
     {
      if(m_text_cursor_x>=m_x2_limit)
         HorizontalScrolling(CalculateScrollThumbX2());
     }
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_y<=m_y_limit)
      VerticalScrolling(CalculateScrollThumbY());
   else
      VerticalScrolling(m_scrollv.CurrentPos());
//--- Update the text in the text box
   DrawTextAndCursor(true);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
//| Handling the pressing of the Enter key                           |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyEnter(const long key_code)
  {
//--- Leave, if it is not the Enter key of if the text box is not activated
   if(key_code!=KEY_ENTER || !m_text_edit_state)
      return(false);
//--- If the multiline mode is disabled
   if(!m_multi_line_mode)
     {
      //--- Deactivate the text box
      DeactivateTextBox();
      //--- Send a message about it
      ::EventChartCustom(m_chart_id,ON_END_EDIT,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
      return(false);
     }
//--- Shift the lines down by one position
   ShiftOnePositionDown();
//--- Calculate the size of the text box
   CalculateTextBoxSize();
//--- Set the new size to the text box
   ChangeTextBoxSize();
//--- Get the boundaries of the visible portion of the text box
   CalculateYBoundaries();
//--- Get the Y coordinate of the cursor
   CalculateTextCursorY();
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_y+(int)LineHeight()>=m_y2_limit)
      VerticalScrolling(CalculateScrollThumbY2());
//--- Move the cursor to the beginning of the line
   SetTextCursor(0,m_text_cursor_y_pos);
//--- Move the scrollbar to the beginning
   HorizontalScrolling(0);
//--- Update the text in the text box
   DrawTextAndCursor(true);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
//| Обработка нажатия на клавише 'Left'                              |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyLeft(const long key_code)
  {
//--- Выйти, если (1) это не клавиша 'Left' или (2) нажата клавиша 'Ctrl' или (3) клавиша 'Shift' нажата или (4) поле ввода не активировано
   if(key_code!=KEY_LEFT || m_keys.KeyCtrlState() || m_keys.KeyShiftState() || !m_text_edit_state)
      return(false);
//--- If the text cursor position is greater than zero
   if(m_text_cursor_x_pos>0)
     {
      //--- Shift it to the previous character
      m_text_cursor_x-=m_lines[m_text_cursor_y_pos].m_width[m_text_cursor_x_pos-1];
      //--- Decrease the characters counter
      m_text_cursor_x_pos--;
     }
   else
     {
      //--- If this is not the first line
      if(m_text_cursor_y_pos>0)
        {
         //--- Move to the end of the previous line
         m_text_cursor_y_pos--;
         CorrectingTextCursorXPos();
        }
     }
//--- Get the boundaries of the visible portion of the text box
   CalculateBoundaries();
//--- Get the Y coordinate of the cursor
   CalculateTextCursorY();
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_x<=m_x_limit)
      HorizontalScrolling(CalculateScrollThumbX());
   else
     {
      //--- Get the size of the array of characters
      uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
      //---
      if(m_text_cursor_x_pos==symbols_total && m_text_cursor_x>=m_x2_limit)
         HorizontalScrolling(CalculateScrollThumbX2());
     }
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_y<=m_y_limit)
      VerticalScrolling(CalculateScrollThumbY());
//--- Update the text in the text box
   DrawTextAndCursor(true);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
//| Обработка нажатия на клавише 'Right'                             |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyRight(const long key_code)
  {
//--- Выйти, если (1) это не клавиша 'Right' или (2) нажата клавиша 'Ctrl' или (3) клавиша 'Shift' нажата или (4) поле ввода не активировано
   if(key_code!=KEY_RIGHT || m_keys.KeyCtrlState() || m_keys.KeyShiftState() || !m_text_edit_state)
      return(false);
//--- Get the size of the array of characters
   uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_width);
//--- If this is the end of the line
   if(m_text_cursor_x_pos<symbols_total)
     {
      //--- Shift the position of the text cursor to the next character
      m_text_cursor_x+=m_lines[m_text_cursor_y_pos].m_width[m_text_cursor_x_pos];
      //--- Increase the character counter
      m_text_cursor_x_pos++;
     }
   else
     {
      //--- Get the size of the lines array
      uint lines_total=::ArraySize(m_lines);
      //--- If this is not the last line
      if(m_text_cursor_y_pos<lines_total-1)
        {
         //--- Move the cursor to the beginning of the next line
         m_text_cursor_x=m_text_x_offset;
         SetTextCursor(0,++m_text_cursor_y_pos);
        }
     }
//--- Get the boundaries of the visible portion of the text box
   CalculateBoundaries();
//--- Get the Y coordinate of the cursor
   CalculateTextCursorY();
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_x>=m_x2_limit)
      HorizontalScrolling(CalculateScrollThumbX2());
   else
     {
      if(m_text_cursor_x_pos==0)
         HorizontalScrolling(0);
     }
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_y+(int)LineHeight()>=m_y2_limit)
      VerticalScrolling(CalculateScrollThumbY2());
//--- Update the text in the text box
   DrawTextAndCursor(true);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
//| Обработка нажатия на клавише 'Up'                                |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyUp(const long key_code)
  {
//--- Leave, if the multiline mode is disabled
   if(!m_multi_line_mode)
      return(false);
//--- Выйти, если (1) это не клавиша 'Up' или (2) клавиша 'Shift' нажата или (3) поле ввода не активировано
   if(key_code!=KEY_UP || m_keys.KeyShiftState() || !m_text_edit_state)
      return(false);
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- If not exceeding the array range
   if(m_text_cursor_y_pos-1<lines_total)
     {
      //--- Move to the previous line
      m_text_cursor_y_pos--;
      //--- Adjusting the text cursor along the X axis
      CorrectingTextCursorXPos(m_text_cursor_x_pos);
     }
//--- Get the boundaries of the visible portion of the text box
   CalculateBoundaries();
//--- Get the Y coordinate of the cursor
   CalculateTextCursorY();
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_x<=m_x_limit)
      HorizontalScrolling(CalculateScrollThumbX());
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_y<=m_y_limit)
      VerticalScrolling(CalculateScrollThumbY());
//--- Update the text in the text box
   DrawTextAndCursor(true);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
//| Обработка нажатия на клавише 'Down'                              |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyDown(const long key_code)
  {
//--- Leave, if the multiline mode is disabled
   if(!m_multi_line_mode)
      return(false);
//--- Выйти, если (1) это не клавиша 'Down' или (2) клавиша 'Shift' нажата или (3) поле ввода не активировано
   if(key_code!=KEY_DOWN || m_keys.KeyShiftState() || !m_text_edit_state)
      return(false);
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- If not exceeding the array range
   if(m_text_cursor_y_pos+1<lines_total)
     {
      //--- Move to the next line
      m_text_cursor_y_pos++;
      //--- Adjusting the text cursor along the X axis
      CorrectingTextCursorXPos(m_text_cursor_x_pos);
     }
//--- Get the boundaries of the visible portion of the text box
   CalculateBoundaries();
//--- Get the Y coordinate of the cursor
   CalculateTextCursorY();
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_x<=m_x_limit)
      HorizontalScrolling(CalculateScrollThumbX());
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_y+(int)LineHeight()>=m_y2_limit)
      VerticalScrolling(CalculateScrollThumbY2());
//--- Update the text in the text box
   DrawTextAndCursor(true);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
//| Обработка нажатия на клавише 'Home'                              |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyHome(const long key_code)
  {
//--- Выйти, если (1) это не клавиша 'Home' или (2) клавиша 'Ctrl' нажата или (3) клавиша 'Shift' нажата или (4) поле ввода не активировано
   if(key_code!=KEY_HOME || m_keys.KeyCtrlState() || m_keys.KeyShiftState() || !m_text_edit_state)
      return(false);
//--- Move the cursor to the beginning of the current line
   SetTextCursor(0,m_text_cursor_y_pos);
//--- Move the scrollbar to the first position
   HorizontalScrolling(0);
//--- Update the text in the text box
   DrawTextAndCursor(true);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
//| Обработка нажатия на клавише 'End'                               |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyEnd(const long key_code)
  {
//--- Выйти, если (1) это не клавиша 'End' или (2) клавиша 'Ctrl' нажата или (3) клавиша 'Shift' нажата или (4) поле ввода не активировано
   if(key_code!=KEY_END || m_keys.KeyCtrlState() || m_keys.KeyShiftState() || !m_text_edit_state)
      return(false);
//--- Get the number of characters in the current line
   uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
//--- Move the cursor to the end of the current line
   SetTextCursor(symbols_total,m_text_cursor_y_pos);
//--- Get the X coordinate of the cursor
   CalculateTextCursorX();
//--- Get the boundaries of the visible portion of the text box
   CalculateXBoundaries();
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_x>=m_x2_limit)
      HorizontalScrolling(CalculateScrollThumbX2());
//--- Update the text in the text box
   DrawTextAndCursor(true);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
//| Handling the simultaneous pressing of the Ctrl + Left keys       |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlAndLeft(const long key_code)
  {
//--- Выйти, если (1) это не клавиша 'Left' и (2) клавиша 'Ctrl' не нажата или (3) клавиша 'Shift' нажата или (4) поле ввода не активировано
   if(!(key_code==KEY_LEFT && m_keys.KeyCtrlState()) || m_keys.KeyShiftState() || !m_text_edit_state)
      return(false);
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- Get the number of characters in the current line
   uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
//--- If the cursor is at the beginning of the current line, and this is not the first line,
//    move the cursor to the end of the previous line
   if(m_text_cursor_x_pos==0 && m_text_cursor_y_pos>0)
     {
      //--- Get the index of the previous line
      uint prev_line_index=m_text_cursor_y_pos-1;
      //--- Get the number of characters in the previous line
      symbols_total=::ArraySize(m_lines[prev_line_index].m_symbol);
      //--- Move the cursor to the end of the previous line
      SetTextCursor(symbols_total,prev_line_index);
     }
// --- If the cursor is at the beginning of the current line or the cursor is on the first line
   else
     {
      //--- Find the beginning of a continuous sequence of characters (from right to left)
      for(uint i=m_text_cursor_x_pos; i<=symbols_total; i--)
        {
         //--- Go to the next, if the cursor is at the end of the line
         if(i==symbols_total)
            continue;
         //--- If this is the first character of the line
         if(i==0)
           {
            //--- Set the cursor to the beginning of the line
            SetTextCursor(0,m_text_cursor_y_pos);
            break;
           }
         //--- If this is not the first character of the line
         else
           {
            //--- If found the beginning of a continuous sequence for the first time.
            //    The beginning is considered to be the space at the next index.
            if(i!=m_text_cursor_x_pos && 
               m_lines[m_text_cursor_y_pos].m_symbol[i]!=SPACE && 
               m_lines[m_text_cursor_y_pos].m_symbol[i-1]==SPACE)
              {
               //--- Set the cursor to the beginning of a new continuous sequence
               SetTextCursor(i,m_text_cursor_y_pos);
               break;
              }
           }
        }
     }
//--- Get the boundaries of the visible portion of the text box
   CalculateBoundaries();
//--- Get the X coordinate of the cursor
   CalculateTextCursorX();
//--- Get the Y coordinate of the cursor
   CalculateTextCursorY();
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_x<=m_x_limit)
      HorizontalScrolling(CalculateScrollThumbX());
   else
     {
      //--- Get the size of the array of characters
      symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
      //---
      if(m_text_cursor_x_pos==symbols_total && m_text_cursor_x>=m_x2_limit)
         HorizontalScrolling(CalculateScrollThumbX2());
     }
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_y<=m_y_limit)
      VerticalScrolling(CalculateScrollThumbY());
//--- Update the text in the text box
   DrawTextAndCursor(true);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
//| Handling the simultaneous pressing of the Ctrl + Right keys      |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlAndRight(const long key_code)
  {
//--- Выйти, если (1) это не клавиша 'Right' и (2) клавиша 'Ctrl' не нажата или (3) клавиша 'Shift' нажата или (4) поле ввода не активировано
   if(!(key_code==KEY_RIGHT && m_keys.KeyCtrlState()) || m_keys.KeyShiftState() || !m_text_edit_state)
      return(false);
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- Get the number of characters in the current line
   uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
//--- If the cursor is at the end of the line and this is not the last line
   if(m_text_cursor_x_pos==symbols_total && m_text_cursor_y_pos<lines_total-1)
     {
      //--- Move the cursor to the beginning of the next line
      SetTextCursor(0,m_text_cursor_y_pos+1);
     }
//--- If the cursor is not at the end of the line or this is the last line
   else
     {
      //--- Find the beginning of a continuous sequence of characters (from left to right)
      for(uint i=m_text_cursor_x_pos; i<=symbols_total; i++)
        {
         //--- Если это первый символ, перейти к следующему
         if(i==0)
            continue;
         //--- If reached the end of the line, move the cursor to the end
         if(i>=symbols_total-1)
           {
            SetTextCursor(symbols_total,m_text_cursor_y_pos);
            break;
           }
         //--- If found the beginning of a continuous sequence for the first time.
         //    The beginning is considered to be the space at the previous index.
         if(i!=m_text_cursor_x_pos && 
            m_lines[m_text_cursor_y_pos].m_symbol[i]!=SPACE && 
            m_lines[m_text_cursor_y_pos].m_symbol[i-1]==SPACE)
           {
            //--- Set the cursor to the end of a new continuous sequence
            SetTextCursor(i,m_text_cursor_y_pos);
            break;
           }
        }
     }
//--- Get the boundaries of the visible portion of the text box
   CalculateBoundaries();
//--- Получим X- и Y-координаты курсора
   CalculateTextCursorX();
   CalculateTextCursorY();
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_x>=m_x2_limit)
     {
      HorizontalScrolling(CalculateScrollThumbX2());
     }
   else if(m_text_cursor_x_pos==0)
      HorizontalScrolling(0);
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_y+(int)LineHeight()>=m_y2_limit)
      VerticalScrolling(CalculateScrollThumbY2());
//--- Update the text in the text box
   DrawTextAndCursor(true);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
//| Handling the simultaneous pressing of the Ctrl + Home keys       |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlAndHome(const long key_code)
  {
//--- Выйти, если (1) это не клавиша 'Home' и (2) клавиша 'Ctrl' не нажата или (3) клавиша 'Shift' нажата или (4) поле ввода не активировано
   if(!(key_code==KEY_HOME && m_keys.KeyCtrlState()) || m_keys.KeyShiftState() || !m_text_edit_state)
      return(false);
//--- Move the cursor to the beginning of the first line
   SetTextCursor(0,0);
//--- Get the boundaries of the visible portion of the text box
   CalculateBoundaries();
//--- Move the scrollbars to the beginning of the text box
   VerticalScrolling(0);
   HorizontalScrolling(0);
//--- Update the text in the text box
   DrawTextAndCursor(true);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
//| Handling the simultaneous pressing of the Ctrl + End keys        |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlAndEnd(const long key_code)
  {
//--- Выйти, если (1) это не клавиша 'End' и (2) клавиша 'Ctrl' не нажата или (3) клавиша 'Shift' нажата или (4) поле ввода не активировано
   if(!(key_code==KEY_END && m_keys.KeyCtrlState()) || m_keys.KeyShiftState() || !m_text_edit_state)
      return(false);
//--- Get the number of lines and characters in the last line
   uint lines_total   =::ArraySize(m_lines);
   uint symbols_total =::ArraySize(m_lines[lines_total-1].m_symbol);
//--- Move the cursor to the end of the last line
   SetTextCursor(symbols_total,lines_total-1);
//--- Get the boundaries of the visible portion of the text box
   CalculateBoundaries();
//--- Получим X- и Y-координаты курсора
   CalculateTextCursorX();
   CalculateTextCursorY();
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_x<=m_x_limit)
      HorizontalScrolling(CalculateScrollThumbX());
   else
     {
      if(m_text_cursor_x>=m_x2_limit)
         HorizontalScrolling(CalculateScrollThumbX2());
     }
//--- Move the scrollbar if the text cursor leaves the visible part
   if(m_text_cursor_y+(int)LineHeight()>=m_y2_limit)
      VerticalScrolling(CalculateScrollThumbY2());
//--- Update the text in the text box
   DrawTextAndCursor(true);
//--- Send a message about it
   ::EventChartCustom(m_chart_id,ON_MOVE_TEXT_CURSOR,CElementBase::Id(),CElementBase::Index(),TextCursorInfo());
   return(true);
  }
//+------------------------------------------------------------------+
//| Обработка нажатия на клавише Ctrl + Shift + Left                 |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlShiftAndLeft(const long key_code)
  {
//--- Выйти, если (1) это не клавиша 'Left' и (2) клавиша 'Ctrl' не нажата и (3) клавиша 'Shift' нажата или (4) поле ввода не активировано
   if(!(key_code==KEY_LEFT && m_keys.KeyCtrlState() && m_keys.KeyShiftState()) || !m_text_edit_state)
      return(false);
//---
   Print(__FUNCTION__," > Ctrl + Shift + Left");
   return(true);
  }
//+------------------------------------------------------------------+
//| Обработка нажатия на клавише Ctrl + Shift + Right                |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlShiftAndRight(const long key_code)
  {
//--- Выйти, если (1) это не клавиша 'Right' и (2) клавиша 'Ctrl' не нажата и (3) клавиша 'Shift' нажата или (4) поле ввода не активировано
   if(!(key_code==KEY_RIGHT && m_keys.KeyCtrlState() && m_keys.KeyShiftState()) || !m_text_edit_state)
      return(false);
//---
   Print(__FUNCTION__," > Ctrl + Shift + Right");
   return(true);
  }
//+------------------------------------------------------------------+
//| Обработка нажатия на клавише Ctrl + Shift + Up                   |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlShiftAndUp(const long key_code)
  {
//--- Выйти, если (1) это не клавиша 'Up' и (2) клавиша 'Ctrl' не нажата и (3) клавиша 'Shift' нажата или (4) поле ввода не активировано
   if(!(key_code==KEY_UP && m_keys.KeyCtrlState() && m_keys.KeyShiftState()) || !m_text_edit_state)
      return(false);
//---
   Print(__FUNCTION__," > Ctrl + Shift + Up");
   return(true);
  }
//+------------------------------------------------------------------+
//| Обработка нажатия на клавише Ctrl + Shift + Down                 |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlShiftAndDown(const long key_code)
  {
//--- Выйти, если (1) это не клавиша 'Down' и (2) клавиша 'Ctrl' не нажата и (3) клавиша 'Shift' нажата или (4) поле ввода не активировано
   if(!(key_code==KEY_DOWN && m_keys.KeyCtrlState() && m_keys.KeyShiftState()) || !m_text_edit_state)
      return(false);
//---
   Print(__FUNCTION__," > Ctrl + Shift + Down");
   return(true);
  }
//+------------------------------------------------------------------+
//| Обработка нажатия на клавише Ctrl + Shift + Home                 |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlShiftAndHome(const long key_code)
  {
//--- Выйти, если (1) это не клавиша 'Home' и (2) клавиша 'Ctrl' не нажата и (3) клавиша 'Shift' нажата или (4) поле ввода не активировано
   if(!(key_code==KEY_HOME && m_keys.KeyCtrlState() && m_keys.KeyShiftState()) || !m_text_edit_state)
      return(false);
//---
   Print(__FUNCTION__," > Ctrl + Shift + Home");
   return(true);
  }
//+------------------------------------------------------------------+
//| Обработка нажатия на клавише Ctrl + Shift + End                  |
//+------------------------------------------------------------------+
bool CTextBox::OnPressedKeyCtrlShiftAndEnd(const long key_code)
  {
//--- Выйти, если (1) это не клавиша 'End' и (2) клавиша 'Ctrl' не нажата и (3) клавиша 'Shift' нажата или (4) поле ввода не активировано
   if(!(key_code==KEY_END && m_keys.KeyCtrlState() && m_keys.KeyShiftState()) || !m_text_edit_state)
      return(false);
//---
   Print(__FUNCTION__," > Ctrl + Shift + End");
   return(true);
  }
//+------------------------------------------------------------------+
//| Deactivation of the text box                                     |
//+------------------------------------------------------------------+
void CTextBox::DeactivateTextBox(void)
  {
//--- Leave, if it is already deactivated
   if(!m_text_edit_state)
      return;
//--- Deactivate
   m_text_edit_state=false;
//--- Enable chart management
   m_chart.SetInteger(CHART_KEYBOARD_CONTROL,true);
//--- Draw text
   DrawText();
//--- If the multiline mode is disabled
   if(!m_multi_line_mode)
     {
      //--- Move the cursor to the beginning of the line
      SetTextCursor(0,0);
      //--- Move the scrollbar to the beginning of the line
      HorizontalScrolling(0);
     }
  }
//+------------------------------------------------------------------+
//| Fast forward of the scrollbar                                    |
//+------------------------------------------------------------------+
void CTextBox::FastSwitching(void)
  {
//--- Leave, if the focus is not on the control
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
      //--- Shifts the text box
      ShiftData();
     }
  }
//+------------------------------------------------------------------+
//| Output text to canvas                                            |
//+------------------------------------------------------------------+
void CTextBox::TextOut(void)
  {
//--- Clear canvas
   m_canvas.Erase(AreaColorCurrent());
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- Adjustment in case the range has been exceeded
   m_text_cursor_y_pos=(m_text_cursor_y_pos>=lines_total)? lines_total-1 : m_text_cursor_y_pos;
//--- Get the size of the array of characters
   uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
//--- If multiline mode is enabled or if the number of characters is greater than zero
   if(m_multi_line_mode || symbols_total>0)
     {
      //--- Get the line height
      int line_height=(int)LineHeight();
      //---
      for(uint i=0; i<lines_total; i++)
        {
         //--- Get the coordinates for the text
         int x=m_text_x_offset;
         int y=m_text_y_offset+((int)i*line_height);
         //--- Build a string from the array of characters
         CollectString(i);
         //--- Draw text
         m_canvas.TextOut(x,y,m_temp_input_string,TextColorCurrent(),TA_LEFT);
        }
     }
//--- If the multiline mode is disabled and there is no character, the default text will be displayed
   else
     {
      //--- Draw text, if specified
      if(m_default_text!="")
         m_canvas.TextOut(m_area_x_size/2,m_area_y_size/2,m_default_text,::ColorToARGB(m_default_text_color),TA_CENTER|TA_VCENTER);
     }
  }
//+------------------------------------------------------------------+
//| Draw text                                                        |
//+------------------------------------------------------------------+
void CTextBox::DrawText(void)
  {
//--- Leave, if the control is hidden
   if(!CElementBase::IsVisible())
      return;
//--- Output the text
   CTextBox::TextOut();
//--- Draw the frame
   DrawBorder();
//--- Update the text box
   m_canvas.Update();
  }
//+------------------------------------------------------------------+
//| Draws the text cursor                                            |
//+------------------------------------------------------------------+
void CTextBox::DrawCursor(void)
  {
//--- Get the line height
   int line_height=(int)LineHeight();
//--- Get the X coordinate of the cursor
   CalculateTextCursorX();
//--- Draw the text cursor
   for(int i=0; i<line_height; i++)
     {
      //--- Get the Y coordinate of the pixel
      int y=m_text_y_offset+((int)m_text_cursor_y_pos*line_height)+i;
      //--- Get the current color of the pixel
      uint pixel_color=m_canvas.PixelGet(m_text_cursor_x,y);
      //--- Invert color for the cursor
      pixel_color=m_clr.Negative((color)pixel_color);
      m_canvas.PixelSet(m_text_cursor_x,y,::ColorToARGB(pixel_color));
     }
  }
//+------------------------------------------------------------------+
//| Displays the text and blinking cursor                            |
//+------------------------------------------------------------------+
void CTextBox::DrawTextAndCursor(const bool show_state=false)
  {
//--- Determine the state for the text cursor (show/hide)
   static bool state=false;
   state=(!show_state)? !state : show_state;
//--- Output the text
   CTextBox::TextOut();
//--- Draw the text cursor
   if(state)
      DrawCursor();
//--- Draw the frame
   DrawBorder();
//--- Update the text box
   m_canvas.Update();
//--- Reset the counter
   m_counter.ZeroTimeCounter();
  }
//+------------------------------------------------------------------+
//| Draws the frame of the Text box                                  |
//+------------------------------------------------------------------+
void CTextBox::DrawBorder(void)
  {
//--- Get the frame color relative to current state of control
   uint clr=BorderColorCurrent();
//--- Get the offset along the X axis
   int xo=(int)m_canvas.GetInteger(OBJPROP_XOFFSET);
   int yo=(int)m_canvas.GetInteger(OBJPROP_YOFFSET);
//--- Boundaries
   int x_size =m_canvas.X_Size()-1;
   int y_size =m_canvas.Y_Size()-1;
//--- Coordinates: top/right/bottom/left
   int x1[4]; x1[0]=xo;         x1[1]=x_size+xo; x1[2]=xo;        x1[3]=xo;
   int y1[4]; y1[0]=yo;         y1[1]=yo;        y1[2]=y_size+yo; y1[3]=yo;
   int x2[4]; x2[0]=x_size+xo;  x2[1]=x_size+xo; x2[2]=x_size+xo; x2[3]=xo;
   int y2[4]; y2[0]=yo;         y2[1]=y_size+yo; y2[2]=y_size+yo; y2[3]=y_size+yo;
//--- Draw the frame by specified coordinates
   for(int i=0; i<4; i++)
      m_canvas.Line(x1[i],y1[i],x2[i],y2[i],clr);
  }
//+------------------------------------------------------------------+
//| Returns background color relative to current state of control    |
//+------------------------------------------------------------------+
uint CTextBox::AreaColorCurrent(void)
  {
   uint clr=::ColorToARGB((m_text_box_state)? m_area_color : m_area_color_locked);
//--- Return the color
   return(clr);
  }
//+------------------------------------------------------------------+
//| Returns text color relative to current state of control          |
//+------------------------------------------------------------------+
uint CTextBox::TextColorCurrent(void)
  {
   uint clr=::ColorToARGB((m_text_box_state)? m_text_color : m_text_color_locked);
//--- Return the color
   return(clr);
  }
//+------------------------------------------------------------------+
//| Returns frame color relative to current state of control         |
//+------------------------------------------------------------------+
uint CTextBox::BorderColorCurrent(void)
  {
   uint clr=clrBlack;
//--- If the element is not blocked
   if(m_text_box_state)
     {
      //--- If the text box is activated
      if(m_text_edit_state)
         clr=m_border_color_activated;
      //--- If not activated, check the control focus
      else
         clr=(CElementBase::IsMouseFocus())? m_border_color_hover : m_border_color;
     }
//--- If the control is blocked
   else
      clr=m_border_color_locked;
//--- Return the color
   return(::ColorToARGB(clr));
  }
//+------------------------------------------------------------------+
//| Changing the object colors                                       |
//+------------------------------------------------------------------+
void CTextBox::ChangeObjectsColor(void)
  {
//--- Track the change of color only if the form is not blocked
   if(m_wnd.IsLocked())
      return;
//--- If not in focus
   if(!CElementBase::MouseFocus())
     {
      //--- If not yet indicated that not in focus
      if(CElementBase::IsMouseFocus())
        {
         //--- Set the flag
         CElementBase::IsMouseFocus(false);
         //--- Change the color
         DrawBorder();
         m_canvas.Update();
        }
     }
   else
     {
      //--- If not yet indicated that in focus
      if(!CElementBase::IsMouseFocus())
        {
         //--- Set the flag
         CElementBase::IsMouseFocus(true);
         //--- Change the color
         DrawBorder();
         m_canvas.Update();
        }
     }
  }
//+------------------------------------------------------------------+
//| Builds a string from characters                                  |
//+------------------------------------------------------------------+
string CTextBox::CollectString(const uint line_index,const uint symbols_total=0)
  {
   m_temp_input_string="";
//--- Получим размер строки
   uint string_length=::ArraySize(m_lines[line_index].m_symbol);
//---
   for(uint i=0; i<string_length; i++)
     {
      if(symbols_total>0)
        {
         if(i==symbols_total)
            break;
        }
      //---
      ::StringAdd(m_temp_input_string,m_lines[line_index].m_symbol[i]);
     }
//--- Вернуть собранную строку
   return(m_temp_input_string);
  }
//+------------------------------------------------------------------+
//| Adds character and its properties to the arrays of the structure |
//+------------------------------------------------------------------+
void CTextBox::AddSymbol(const string key_symbol)
  {
//--- Get the size of the array of characters
   uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
//--- Resize the arrays
   ArraysResize(m_text_cursor_y_pos,symbols_total+1);
//--- Shift all characters from the end of the array to the index of the added character
   MoveSymbols(m_text_cursor_y_pos,0,m_text_cursor_x_pos,false);
//--- Get the width of the character
   int width=m_canvas.TextWidth(key_symbol);
//--- Add the character to the vacated element
   m_lines[m_text_cursor_y_pos].m_symbol[m_text_cursor_x_pos] =key_symbol;
   m_lines[m_text_cursor_y_pos].m_width[m_text_cursor_x_pos]  =width;
//--- Increase the cursor position counter
   m_text_cursor_x_pos++;
  }
//+------------------------------------------------------------------+
//| Deletes a character                                              |
//+------------------------------------------------------------------+
void CTextBox::DeleteSymbol(void)
  {
//--- Get the size of the array of characters
   uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
//--- If the array is empty
   if(symbols_total<1)
     {
      //--- Set the cursor to the zero position of the cursor line
      SetTextCursor(0,m_text_cursor_y_pos);
      return;
     }
//--- Get the position of the previous character
   int check_pos=(int)m_text_cursor_x_pos-1;
//--- Leave, if out of range
   if(check_pos<0)
      return;
//--- Сместить все символы на один элемент влево от индекса удаляемого символа
   MoveSymbols(m_text_cursor_y_pos,m_text_cursor_x_pos,check_pos);
//--- Decrease the cursor position counter
   m_text_cursor_x_pos--;
//--- Resize the arrays
   ArraysResize(m_text_cursor_y_pos,symbols_total-1);
  }
//+------------------------------------------------------------------+
//| Returns the line height                                          |
//+------------------------------------------------------------------+
uint CTextBox::LineHeight(void)
  {
//--- Set the font to be displayed on the canvas (required for getting the line height)
   m_canvas.FontSet(CElementBase::Font(),-CElementBase::FontSize()*10,FW_NORMAL);
//--- Return the line height
   return(m_canvas.TextHeight("|"));
  }
//+------------------------------------------------------------------+
//| Returns line width from beginning to the specified position      |
//+------------------------------------------------------------------+
uint CTextBox::LineWidth(const uint symbol_index,const uint line_index)
  {
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- Prevention of exceeding the array size
   uint l=(line_index<lines_total)? line_index : lines_total-1;
//--- Get the size of the array of characters for the specified line
   uint symbols_total=::ArraySize(m_lines[l].m_symbol);
//--- Prevention of exceeding the array size
   uint s=(symbol_index<symbols_total)? symbol_index : symbols_total;
//--- Sum the width of all characters
   uint width=0;
   for(uint i=0; i<s; i++)
      width+=m_lines[l].m_width[i];
//--- Return the line width
   return(width);
  }
//+------------------------------------------------------------------+
//| Returns the maximum line width                                   |
//+------------------------------------------------------------------+
uint CTextBox::MaxLineWidth(void)
  {
   uint max_line_width=0;
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
   for(uint i=0; i<lines_total; i++)
     {
      //--- Get the size of the array of characters
      uint symbols_total=::ArraySize(m_lines[i].m_symbol);
      //--- Get the line width
      uint line_width=LineWidth(symbols_total,i);
      //--- Store the maximum width
      if(line_width>max_line_width)
         max_line_width=line_width;
     }
//--- Return the maximum line width
   return(max_line_width);
  }
//+------------------------------------------------------------------+
//| Shifts the lines up by one position                              |
//+------------------------------------------------------------------+
void CTextBox::ShiftOnePositionUp(void)
  {
//--- Если включен перенос слов
   if(m_word_wrap_mode)
     {
      //--- Index of the previous row
      uint prev_line_index=m_text_cursor_y_pos-1;
      //--- Get the size of the array of characters
      uint symbols_total=::ArraySize(m_lines[prev_line_index].m_symbol);
      //--- Если предыдущая строка имеет признак окончания
      if(m_lines[prev_line_index].m_end_of_line)
        {
         //--- (1) Уберём признак окончания и (2) переместим текстовый курсор в конец строки
         m_lines[prev_line_index].m_end_of_line=false;
         SetTextCursor(symbols_total,prev_line_index);
        }
      else
        {
         //--- (1) Переместим текстовый курсор в конец строки и (2) удалим символ
         SetTextCursor(symbols_total,prev_line_index);
         DeleteSymbol();
        }
      return;
     }
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- Get the size of the array of characters
   uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
//--- If there are characters in this line, store them in order to append to the previous line
   m_temp_input_string=(symbols_total>0)? CollectString(m_text_cursor_y_pos) : "";
//--- Shift the lines up starting from the next element by one position
   MoveLines(m_text_cursor_y_pos,lines_total-1,false);
//--- Resize the lines array
   ::ArrayResize(m_lines,lines_total-1);
//--- Decrease the lines counter
   m_text_cursor_y_pos--;
//--- Get the size of the array of characters
   symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_symbol);
//--- Move the cursor to the end
   m_text_cursor_x_pos=symbols_total;
//--- Get the X coordinate of the cursor
   CalculateTextCursorX();
//--- If there is a line that must be appended to the previous one
   if(m_temp_input_string!="")
      AddToString(m_text_cursor_y_pos,m_temp_input_string);
  }
//+------------------------------------------------------------------+
//| Shifts the lines down by one position                            |
//+------------------------------------------------------------------+
void CTextBox::ShiftOnePositionDown(void)
  {
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- Increase the array by one element
   uint new_size=lines_total+1;
   ::ArrayResize(m_lines,new_size);
//--- Shift the lines down starting from the current position by one item (from the end of the array)
   MoveLines(lines_total,m_text_cursor_y_pos+1);
//--- Перенесём текст на новую строку
   WrapTextToNewLine(m_text_cursor_y_pos,m_text_cursor_x_pos,true);
  }
//+------------------------------------------------------------------+
//| Check for presence of the mandatory first line                   |
//+------------------------------------------------------------------+
uint CTextBox::CheckFirstLine(void)
  {
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- if there are no lines, set the size of the arrays of the structure
   if(lines_total<1)
      ::ArrayResize(m_lines,++lines_total);
//--- Return the number of lines
   return(lines_total);
  }
//+------------------------------------------------------------------+
//| Resizes the arrays of properties for the specified line          |
//+------------------------------------------------------------------+
void CTextBox::ArraysResize(const uint line_index,const uint new_size)
  {
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- Prevention of exceeding the array size
   uint l=(line_index<lines_total)? line_index : lines_total-1;
//--- Set the size of the arrays of the structure
   ::ArrayResize(m_lines[line_index].m_width,new_size);
   ::ArrayResize(m_lines[line_index].m_symbol,new_size);
  }
//+------------------------------------------------------------------+
//| Makes a copy of specified (source) line to new location(dest.)   |
//+------------------------------------------------------------------+
void CTextBox::LineCopy(const uint destination,const uint source)
  {
   ::ArrayCopy(m_lines[destination].m_width,m_lines[source].m_width);
   ::ArrayCopy(m_lines[destination].m_symbol,m_lines[source].m_symbol);
   m_lines[destination].m_end_of_line=m_lines[source].m_end_of_line;
  }
//+------------------------------------------------------------------+
//| Clears the specified line                                        |
//+------------------------------------------------------------------+
void CTextBox::ClearLine(const uint line_index)
  {
   ::ArrayFree(m_lines[line_index].m_width);
   ::ArrayFree(m_lines[line_index].m_symbol);
  }
//+------------------------------------------------------------------+
//| Set the cursor at the specified position                         |
//+------------------------------------------------------------------+
void CTextBox::SetTextCursor(const uint x_pos,const uint y_pos)
  {
   m_text_cursor_x_pos=x_pos;
   m_text_cursor_y_pos=(!m_multi_line_mode)? 0 : y_pos;
  }
//+------------------------------------------------------------------+
//| Adjusting the text cursor along the X axis                       |
//+------------------------------------------------------------------+
void CTextBox::CorrectingTextCursorXPos(const int x_pos=WRONG_VALUE)
  {
//--- Get the size of the array of characters
   uint symbols_total=::ArraySize(m_lines[m_text_cursor_y_pos].m_width);
//--- Determine the cursor position
   uint text_cursor_x_pos=0;
//--- If the position is available
   if(x_pos!=WRONG_VALUE)
      text_cursor_x_pos=(x_pos>(int)symbols_total-1)? symbols_total : x_pos;
//--- If the position is not available, set the cursor to the end of the line
   else
      text_cursor_x_pos=symbols_total;
//--- Zero position, if the line contains no characters
   m_text_cursor_x_pos=(symbols_total<1)? 0 : text_cursor_x_pos;
//--- Get the X coordinate of the cursor
   CalculateTextCursorX();
  }
//+------------------------------------------------------------------+
//| Calculation of the X coordinate for the text cursor              |
//+------------------------------------------------------------------+
void CTextBox::CalculateTextCursorX(void)
  {
//--- Get the line width
   int line_width=(int)LineWidth(m_text_cursor_x_pos,m_text_cursor_y_pos);
//--- Calculate and store the X coordinate of the cursor
   m_text_cursor_x=m_text_x_offset+line_width;
  }
//+------------------------------------------------------------------+
//| Calculation of the Y coordinate for the text cursor              |
//+------------------------------------------------------------------+
void CTextBox::CalculateTextCursorY(void)
  {
//--- Get the line height
   int line_height=(int)LineHeight();
//--- Get the Y coordinate of the cursor
   m_text_cursor_y=m_text_y_offset+int(line_height*m_text_cursor_y_pos);
  }
//+------------------------------------------------------------------+
//| Calculation of the text box boundaries along the two axes        |
//+------------------------------------------------------------------+
void CTextBox::CalculateBoundaries(void)
  {
   CalculateXBoundaries();
   CalculateYBoundaries();
  }
//+------------------------------------------------------------------+
//| Calculation of the text box boundaries along the X axis          |
//+------------------------------------------------------------------+
void CTextBox::CalculateXBoundaries(void)
  {
//--- Get the X coordinate and offset along the X axis
   int x       =(int)m_canvas.GetInteger(OBJPROP_XDISTANCE);
   int xoffset =(int)m_canvas.GetInteger(OBJPROP_XOFFSET);
//--- Calculate the boundaries of the visible portion of the text box
   m_x_limit  =(x+xoffset)-x;
   m_x2_limit =(m_multi_line_mode)? (x+xoffset+m_x_size-m_scrollv.ScrollWidth()-m_text_x_offset)-x : (x+xoffset+m_x_size-m_text_x_offset)-x;
  }
//+------------------------------------------------------------------+
//| Calculation of the text box boundaries along the Y axis          |
//+------------------------------------------------------------------+
void CTextBox::CalculateYBoundaries(void)
  {
//--- Leave, if the multiline mode is disabled
   if(!m_multi_line_mode)
      return;
//--- Get the Y coordinate and offset along the Y axis
   int y       =(int)m_canvas.GetInteger(OBJPROP_YDISTANCE);
   int yoffset =(int)m_canvas.GetInteger(OBJPROP_YOFFSET);
//--- Calculate the boundaries of the visible portion of the text box
   m_y_limit  =(y+yoffset)-y;
   m_y2_limit =(y+yoffset+m_y_size-m_scrollh.ScrollWidth())-y;
  }
//+------------------------------------------------------------------+
//| Calculate X position of scrollbar on left edge of the text box   |
//+------------------------------------------------------------------+
int CTextBox::CalculateScrollThumbX(void)
  {
   return(m_text_cursor_x-m_text_x_offset);
  }
//+------------------------------------------------------------------+
//| Calculate X position of scrollbar on right edge of the text box  |
//+------------------------------------------------------------------+
int CTextBox::CalculateScrollThumbX2(void)
  {
   return((m_multi_line_mode)? m_text_cursor_x-m_x_size+m_scrollv.ScrollWidth()+m_text_x_offset : m_text_cursor_x-m_x_size+m_text_x_offset*2);
  }
//+------------------------------------------------------------------+
//| Calculate Y position of scrollbar on top edge of the text box    |
//+------------------------------------------------------------------+
int CTextBox::CalculateScrollThumbY(void)
  {
   return(m_text_cursor_y-m_text_y_offset);
  }
//+------------------------------------------------------------------+
//| Calculate Y position of scrollbar on bottom edge of the text box |
//+------------------------------------------------------------------+
int CTextBox::CalculateScrollThumbY2(void)
  {
//--- Set the font to be displayed on the canvas (required for getting the line height)
   m_canvas.FontSet(CElementBase::Font(),-CElementBase::FontSize()*10,FW_NORMAL);
//--- Get the line height
   int line_height=m_canvas.TextHeight("|");
//--- Calculate and return the value
   return(m_text_cursor_y-m_y_size+m_scrollh.ScrollWidth()+m_text_y_offset+line_height);
  }
//+------------------------------------------------------------------+
//| Calculates the size of the text box                              |
//+------------------------------------------------------------------+
void CTextBox::CalculateTextBoxSize(void)
  {
   CalculateTextBoxXSize();
   CalculateTextBoxYSize();
  }
//+------------------------------------------------------------------+
//| Calculates the width of the text box                             |
//+------------------------------------------------------------------+
bool CTextBox::CalculateTextBoxXSize(void)
  {
//--- Store the current size
   int area_x_size_curr=m_area_x_size;
//--- Get the maximum line width from the text box
   int max_line_width=int((m_text_x_offset*2)+MaxLineWidth()+m_scrollv.ScrollWidth());
//--- Determine the total width
   m_area_x_size=(max_line_width>m_x_size)? max_line_width : m_x_size;
//--- Determine the visible width
   m_area_visible_x_size=m_x_size;
//--- Sign that the sizes did not change
   if(area_x_size_curr==m_area_x_size)
      return(false);
//--- Sign that the sizes changed
   return(true);
  }
//+------------------------------------------------------------------+
//| Calculates the height of the text box                            |
//+------------------------------------------------------------------+
bool CTextBox::CalculateTextBoxYSize(void)
  {
//--- Store the current size
   int area_y_size_curr=m_area_y_size;
//--- Get the line height
   int line_height=(int)LineHeight();
//--- Get the size of the lines array
   int lines_total=::ArraySize(m_lines);
//--- Calculate the total height of the control
   int lines_height=int((m_text_y_offset*2)+(line_height*lines_total)+m_scrollh.ScrollWidth());
//--- Determine the total height
   m_area_y_size=(m_multi_line_mode && lines_height>m_y_size)? lines_height : m_y_size;
//--- Determine the visible height
   m_area_visible_y_size=m_y_size;
//--- Sign that the sizes did not change
   if(area_y_size_curr==m_area_y_size)
      return(false);
//--- Sign that the sizes changed
   return(true);
  }
//+------------------------------------------------------------------+
//| Change the main size of the control                              |
//+------------------------------------------------------------------+
void CTextBox::ChangeMainSize(const int x_size,const int y_size)
  {
//--- Set the new size
   CElementBase::XSize(x_size);
   CElementBase::YSize(y_size);
  }
//+------------------------------------------------------------------+
//| Resize the text box                                              |
//+------------------------------------------------------------------+
void CTextBox::ChangeTextBoxSize(const bool is_x_offset=false,const bool is_y_offset=false)
  {
//--- Resize the table
   m_canvas.XSize(m_area_x_size);
   m_canvas.YSize(m_area_y_size);
   m_canvas.Resize(m_area_x_size,m_area_y_size);
//--- Set the size of the visible area
   m_canvas.SetInteger(OBJPROP_XSIZE,m_area_visible_x_size);
   m_canvas.SetInteger(OBJPROP_YSIZE,m_area_visible_y_size);
//--- Difference between the total width and visible area
   int x_different=m_area_x_size-m_area_visible_x_size;
   int y_different=m_area_y_size-m_area_visible_y_size;
//--- Set the frame offset within the image along the X and Y axes
   int x_offset=(int)m_canvas.GetInteger(OBJPROP_XOFFSET);
   int y_offset=(int)m_canvas.GetInteger(OBJPROP_YOFFSET);
   m_canvas.SetInteger(OBJPROP_XOFFSET,(!is_x_offset)? 0 : (x_offset<=x_different)? x_offset : x_different);
   m_canvas.SetInteger(OBJPROP_YOFFSET,(!is_y_offset)? 0 : (y_offset<=y_different)? y_offset : y_different);
//--- Resize the scrollbars
   ChangeScrollsSize();
//--- Перенос по словам
   WordWrap();
//--- Adjust the data
   ShiftData();
  }
//+------------------------------------------------------------------+
//| Resize the scrollbars                                            |
//+------------------------------------------------------------------+
void CTextBox::ChangeScrollsSize(void)
  {
//--- Check for presence of a scrollbar
   bool is_scrollh=m_area_x_size>m_area_visible_x_size;
   bool is_scrollv=m_area_y_size>m_area_visible_y_size;
//--- Calculate the sizes of the scrollbars
   m_scrollh.Reinit(m_area_x_size,m_area_visible_x_size);
   m_scrollv.Reinit(m_area_y_size,m_area_visible_y_size);
//--- Если (1) горизонтальная полоса прокрутки не нужна или (2) включен перенос по словам
   if(!is_scrollh || m_word_wrap_mode)
     {
      //--- Hide the horizontal scrollbar
      m_scrollh.Hide();
      //--- Change the height of the vertical scrollbar
      m_scrollv.ChangeYSize(CElementBase::YSize()-2);
     }
   else
     {
      //--- Show the horizontal scrollbar
      if(CElementBase::IsVisible() && m_word_wrap_mode)
         m_scrollh.Show();
      //--- Calculate and change the height of the vertical scrollbar
      m_scrollv.ChangeYSize(CElementBase::YSize()-m_scrollh.ScrollWidth()-1);
     }
//--- If the vertical scrollbar is not required
   if(!is_scrollv)
     {
      //--- Hide the vertical scrollbar
      m_scrollv.Hide();
      //--- Изменить ширину горизонтальной полосы прокрутки, если отключен перенос по словам
      if(!m_word_wrap_mode)
         m_scrollh.ChangeXSize(CElementBase::XSize()-2);
     }
   else
     {
      //--- Show the vertical scrollbar
      if(CElementBase::IsVisible())
         m_scrollv.Show();
      //--- Изменить ширину горизонтальной полосы прокрутки, если отключен перенос по словам
      if(!m_word_wrap_mode)
         m_scrollh.ChangeXSize(CElementBase::XSize()-m_scrollv.ScrollWidth()-1);
     }
  }
//+------------------------------------------------------------------+
//| Перенос по словам                                                |
//+------------------------------------------------------------------+
void CTextBox::WordWrap(void)
  {
//--- Выйти, если режимы (1) многострочного поля ввода или (2) переноса по словам отключены
   if(!m_multi_line_mode || !m_word_wrap_mode)
      return;
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- Проверим, нужно ли выровнять текст по ширине поля ввода
   for(uint i=0; i<lines_total; i++)
     {
      //--- Для определения первых видимых индексов (1) символа и (2) пробела
      int symbol_index =WRONG_VALUE;
      int space_index  =WRONG_VALUE;
      //--- Index of the next row
      uint next_line_index=i+1;
      //--- Если строка не помещается, то перенесём часть текущей строки на новую строку
      if(CheckForOverflow(i,symbol_index,space_index))
        {
         //--- Если пробел найден, то он переносится не будет
         if(space_index!=WRONG_VALUE)
            space_index++;
         //--- Увеличим массив строк на один элемент
         ::ArrayResize(m_lines,++lines_total);
         //--- Сместим строки от текущей позиции на один пункт вниз
         MoveLines(lines_total-1,next_line_index);
         //--- Проверим индекс символа, от которого будет перенос текста
         int check_index=(space_index==WRONG_VALUE && symbol_index!=WRONG_VALUE)? symbol_index : space_index;
         //--- Перенесём текст на новую строку
         WrapTextToNewLine(i,check_index);
        }
      //--- Если строка помещается, то проверим, не нужно ли осуществить обратный перенос
      else
        {
         //--- Пропускаем, если (1) это строка с окончанием или (2) это последняя строка
         if(m_lines[i].m_end_of_line || next_line_index>=lines_total)
            continue;
         //--- Определим количество символов для переноса
         uint wrap_symbols_total=0;
         //--- Если нужно перенести оставшийся текст следующей строки на текущую
         if(WrapSymbolsTotal(i,wrap_symbols_total))
           {
            WrapTextToPrevLine(next_line_index,wrap_symbols_total,true);
            //--- Обновить размер массива для дальнейшего использования в цикле
            lines_total=::ArraySize(m_lines);
            //--- Шаг назад, чтобы избежать пропуск строки для следующей проверки
            i--;
           }
         //--- Перенести только то, что помещается
         else
            WrapTextToPrevLine(next_line_index,wrap_symbols_total);
        }
     }
  }
//+------------------------------------------------------------------+
//| Проверка на переполнение строки                                  |
//+------------------------------------------------------------------+
bool CTextBox::CheckForOverflow(const uint line_index,int &symbol_index,int &space_index)
  {
//--- Get the size of the array of characters
   uint symbols_total=::ArraySize(m_lines[line_index].m_symbol);
//--- Indents
   uint x_offset_plus=m_text_x_offset+m_scrollv.ScrollWidth();
//--- Получим полную ширину строки
   uint full_line_width=LineWidth(symbols_total,line_index)+x_offset_plus;
//--- Если ширина этой строки помещается в поле
   if(full_line_width<(uint)m_area_visible_x_size)
      return(false);
//--- Определим индексы символов переполнения
   for(uint s=symbols_total-1; s>0; s--)
     {
      //--- Получим (1) ширину подстроки от начала до текущего символа и (2) символ
      uint   line_width =LineWidth(s,line_index)+x_offset_plus;
      string symbol     =m_lines[line_index].m_symbol[s];
      //--- Если ещё не нашли видимый символ
      if(symbol_index==WRONG_VALUE)
        {
         //--- Если ширина подстроки помещается в область поля ввода, запомним индекс символа
         if(line_width<(uint)m_area_visible_x_size)
            symbol_index=(int)s;
         //--- Перейти к следующему символу
         continue;
        }
      //--- Если это пробел, запомним его индекс и остановим цикл
      if(symbol==SPACE)
        {
         space_index=(int)s;
         break;
        }
     }
//--- Выполнение условия означает, что строка не помещается
   bool is_overflow=(symbol_index!=WRONG_VALUE || space_index!=WRONG_VALUE);
//--- Вернуть результат
   return(is_overflow);
  }
//+------------------------------------------------------------------+
//| Возвращает количество слов в указанной строке                    |
//+------------------------------------------------------------------+
uint CTextBox::WordsTotal(const uint line_index)
  {
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- Prevention of exceeding the array size
   uint l=(line_index<lines_total)? line_index : lines_total-1;
//--- Get the size of the array of characters for the specified line
   uint symbols_total=::ArraySize(m_lines[l].m_symbol);
//--- Счётчик слов
   uint words_counter=0;
//--- Ищем пробел по указанному индексу
   for(uint s=1; s<symbols_total; s++)
     {
      //--- Считаем, если (2) дошли до конца строки или (2) нашли пробел (конец слова)
      if(s+1==symbols_total || (m_lines[l].m_symbol[s]!=SPACE && m_lines[l].m_symbol[s-1]==SPACE))
         words_counter++;
     }
//--- Вернуть количество слов
   return((words_counter<1)? 1 : words_counter);
  }
//+------------------------------------------------------------------+
//| Возвращает количество переносимых символов с признаком объёма    |
//+------------------------------------------------------------------+
bool CTextBox::WrapSymbolsTotal(const uint line_index,uint &wrap_symbols_total)
  {
//--- Признаки (1) количества символов для переноса и (2) строки без пробелов
   bool is_all_text=false,is_solid_row=false;
//--- Get the size of the array of characters
   uint symbols_total=::ArraySize(m_lines[line_index].m_symbol);
//--- Indents
   uint x_offset_plus=m_text_x_offset+m_scrollv.ScrollWidth();
//--- Получим полную ширину строки
   uint full_line_width=LineWidth(symbols_total,line_index)+x_offset_plus;
//--- Получим ширину свободного пространства
   uint free_space=m_area_visible_x_size-full_line_width;
//--- Получим количество слов в следующей строке
   uint next_line_index =line_index+1;
   uint words_total     =WordsTotal(next_line_index);
//--- Get the size of the array of characters
   uint next_line_symbols_total=::ArraySize(m_lines[next_line_index].m_symbol);
//--- Определить количество слов, которые можно перенести со следующей строки (поиск по пробелу)
   for(uint w=0; w<words_total; w++)
     {
      //--- Получим (1) индекс пробела и (2) ширину подстроки от начала до пробела
      uint ss_index        =SymbolIndexBySpaceNumber(next_line_index,w);
      uint substring_width =LineWidth(ss_index,next_line_index);
      //--- Если подстрока помещается в свободное пространство текущей строки
      if(substring_width<free_space)
        {
         //--- ...проверим, можно ли добавить ещё одно слово
         wrap_symbols_total=ss_index;
         //--- Остановиться, если это вся строка
         if(next_line_symbols_total==wrap_symbols_total)
           {
            is_all_text=true;
            break;
           }
        }
      else
        {
         //--- Если это сплошная строка без пробела
         if(ss_index==next_line_symbols_total)
            is_solid_row=true;
         //---
         break;
        }
     }
//--- Сразу вернуть результат, если (1) это строка с пробелом или (2) нет свободного места
   if(!is_solid_row || free_space<1)
      return(is_all_text);
//--- Получим полную ширину следующей строки
   full_line_width=LineWidth(next_line_symbols_total,next_line_index)+x_offset_plus;
//--- Если (1) строка не помещается и нет пробелов в конце (2) текущей и (3) предыдущей строках
   if(full_line_width>free_space && 
      m_lines[line_index].m_symbol[symbols_total-1]!=SPACE && 
      m_lines[next_line_index].m_symbol[next_line_symbols_total-1]!=SPACE)
     {
      //--- Определить количество символов, которые можно перенести со следующей строки
      for(uint s=next_line_symbols_total-1; s>=0; s--)
        {
         //--- Получим ширину подстроки от начала до указанного символа
         uint substring_width=LineWidth(s,next_line_index);
         //--- Если подстрока не помещается в свободное пространство указанного контейнера, перейти к следующему символу
         if(substring_width>=free_space)
            continue;
         //--- Если подстрока помещается, запомним значение и остановимся
         wrap_symbols_total=s;
         break;
        }
     }
//--- Вернуть истину, если нужно перенести весь текст
   return(is_all_text);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс символа пробела по его номеру                  |
//+------------------------------------------------------------------+
uint CTextBox::SymbolIndexBySpaceNumber(const uint line_index,const uint space_index)
  {
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- Prevention of exceeding the array size
   uint l=(line_index<lines_total)? line_index : lines_total-1;
//--- Get the size of the array of characters for the specified line
   uint symbols_total=::ArraySize(m_lines[l].m_symbol);
//--- (1) Для определения индекса символа пробела и (2) счётчик пробелов
   uint symbol_index  =0;
   uint space_counter =0;
//--- Ищем пробел по указанному индексу
   for(uint s=1; s<symbols_total; s++)
     {
      //--- Если нашли пробел
      if(m_lines[l].m_symbol[s]!=SPACE && m_lines[l].m_symbol[s-1]==SPACE)
        {
         //--- Если счётчик равен указанному индексу пробела, запомним его и остановим цикл
         if(space_counter==space_index)
           {
            symbol_index=s;
            break;
           }
         //--- Увеличим счётчик пробелов
         space_counter++;
        }
     }
//--- Вернуть размер строки, если не нашли индекс пробела
   return((symbol_index<1)? symbols_total : symbol_index);
  }
//+------------------------------------------------------------------+
//| Перемещение строк                                                |
//+------------------------------------------------------------------+
void CTextBox::MoveLines(const uint from_index,const uint to_index,const bool to_down=true)
  {
//--- Смещение строк по направлению вниз
   if(to_down)
     {
      for(uint i=from_index; i>to_index; i--)
        {
         //--- Index of the previous element of the lines array
         uint prev_index=i-1;
         //--- Get the size of the array of characters
         uint symbols_total=::ArraySize(m_lines[prev_index].m_symbol);
         //--- Resize the arrays
         ArraysResize(i,symbols_total);
         //--- make a copy of the line
         LineCopy(i,prev_index);
         //--- Если это последняя итерация
         if(prev_index==to_index)
           {
            //--- Выйти, если это первая строка
            if(to_index<1)
               break;
           }
        }
     }
//--- Смещение строк по направлению вверх
   else
     {
      for(uint i=from_index; i<to_index; i++)
        {
         //--- Index of the next element of the lines array
         uint next_index=i+1;
         //--- Get the size of the array of characters
         uint symbols_total=::ArraySize(m_lines[next_index].m_symbol);
         //--- Resize the arrays
         ArraysResize(i,symbols_total);
         //--- make a copy of the line
         LineCopy(i,next_index);
        }
     }
  }
//+------------------------------------------------------------------+
//| Перемещение символов в указанной строке                          |
//+------------------------------------------------------------------+
void CTextBox::MoveSymbols(const uint line_index,const uint from_pos,const uint to_pos,const bool to_left=true)
  {
//--- Get the size of the array of characters
   uint symbols_total=::ArraySize(m_lines[line_index].m_symbol);
//--- Разница
   uint offset=from_pos-to_pos;
//--- Если нужно сместить символы влево
   if(to_left)
     {
      for(uint s=to_pos; s<symbols_total-offset; s++)
        {
         uint i=s+offset;
         m_lines[line_index].m_symbol[s] =m_lines[line_index].m_symbol[i];
         m_lines[line_index].m_width[s]  =m_lines[line_index].m_width[i];
        }
     }
//--- Если нужно сместить символы вправо
   else
     {
      for(uint s=symbols_total-1; s>to_pos; s--)
        {
         uint i=s-1;
         m_lines[line_index].m_symbol[s] =m_lines[line_index].m_symbol[i];
         m_lines[line_index].m_width[s]  =m_lines[line_index].m_width[i];
        }
     }
  }
//+------------------------------------------------------------------+
//| Adds text to the specified line                                  |
//+------------------------------------------------------------------+
void CTextBox::AddToString(const uint line_index,const string text)
  {
//--- Transfer the line to array
   uchar array[];
   int total=::StringToCharArray(text,array)-1;
//--- Get the size of the array of characters
   uint symbols_total=::ArraySize(m_lines[line_index].m_symbol);
//--- Resize the arrays
   uint new_size=symbols_total+total;
   ArraysResize(line_index,new_size);
//--- Add the data to the arrays of the structure
   for(uint i=symbols_total; i<new_size; i++)
     {
      m_lines[line_index].m_symbol[i] =::CharToString(array[i-symbols_total]);
      m_lines[line_index].m_width[i]  =m_canvas.TextWidth(m_lines[line_index].m_symbol[i]);
     }
  }
//+------------------------------------------------------------------+
//| Копирует в переданный массив символы для переноса                |
//+------------------------------------------------------------------+
void CTextBox::CopyWrapSymbols(const uint line_index,const uint start_pos,const uint symbols_total,string &array[])
  {
//--- Установим размер массиву
   ::ArrayResize(array,symbols_total);
//--- Скопируем в массив символы, которые нужно перенести
   for(uint i=0; i<symbols_total; i++)
      array[i]=m_lines[line_index].m_symbol[start_pos+i];
  }
//+------------------------------------------------------------------+
//| Вставляет символы в указанную строку                             |
//+------------------------------------------------------------------+
void CTextBox::PasteWrapSymbols(const uint line_index,const uint start_pos,string &array[])
  {
   uint array_size=::ArraySize(array);
//--- Add the data to the arrays of the structure for the new line
   for(uint i=0; i<array_size; i++)
     {
      uint s=start_pos+i;
      m_lines[line_index].m_symbol[s] =array[i];
      m_lines[line_index].m_width[s]  =m_canvas.TextWidth(array[i]);
     }
  }
//+------------------------------------------------------------------+
//| Перенос текста на новую строку                                   |
//+------------------------------------------------------------------+
void CTextBox::WrapTextToNewLine(const uint line_index,const uint symbol_index,const bool by_pressed_enter=false)
  {
//--- Получим размер массива символов из строки
   uint symbols_total=::ArraySize(m_lines[line_index].m_symbol);
//--- Последний индекс символа
   uint last_symbol_index=symbols_total-1;
//--- Корректировка в случае пустой строки
   uint check_symbol_index=(symbol_index>last_symbol_index && symbol_index!=symbols_total)? last_symbol_index : symbol_index;
//--- Index of the next row
   uint next_line_index=line_index+1;
//--- Количество символов, которые нужно перенести на новую строку
   uint new_line_size=symbols_total-check_symbol_index;
//--- Скопируем в массив символы, которые нужно перенести
   string array[];
   CopyWrapSymbols(line_index,check_symbol_index,new_line_size,array);
//--- Установим новый размер массивам структуры в строке
   ArraysResize(line_index,symbols_total-new_line_size);
//--- Resize the arrays of the structure for the new line
   ArraysResize(next_line_index,new_line_size);
//--- Add the data to the arrays of the structure for the new line
   PasteWrapSymbols(next_line_index,0,array);
//--- Определим новое положение текстового курсора
   int x_pos=int(new_line_size-(symbols_total-m_text_cursor_x_pos));
   m_text_cursor_x_pos =(x_pos<0)? (int)m_text_cursor_x_pos : x_pos;
   m_text_cursor_y_pos =(x_pos<0)? (int)line_index : (int)next_line_index;
//--- Если указано, что вызов по нажатию на клавише Enter
   if(by_pressed_enter)
     {
      //--- Если строка имела признак окончания, то ставим признак окончания текущей и следующей
      if(m_lines[line_index].m_end_of_line)
        {
         m_lines[line_index].m_end_of_line      =true;
         m_lines[next_line_index].m_end_of_line =true;
        }
      //--- Если нет, то только текущей
      else
        {
         m_lines[line_index].m_end_of_line      =true;
         m_lines[next_line_index].m_end_of_line =false;
        }
     }
   else
     {
      //--- Если строка имела признак окончания, то продолжаем и устанавливаем признак на следующей строке
      if(m_lines[line_index].m_end_of_line)
        {
         m_lines[line_index].m_end_of_line      =false;
         m_lines[next_line_index].m_end_of_line =true;
        }
      //--- Если строка не имела признак окончания, то продолжаем в обеих строках
      else
        {
         m_lines[line_index].m_end_of_line      =false;
         m_lines[next_line_index].m_end_of_line =false;
        }
     }
  }
//+------------------------------------------------------------------+
//| Перенос текста из следующей строки в текущую                     |
//+------------------------------------------------------------------+
void CTextBox::WrapTextToPrevLine(const uint next_line_index,const uint wrap_symbols_total,const bool is_all_text=false)
  {
//--- Получим размер массива символов из строки
   uint symbols_total=::ArraySize(m_lines[next_line_index].m_symbol);
//--- Index of the previous row
   uint prev_line_index=next_line_index-1;
//--- Скопируем в массив символы, которые нужно перенести
   string array[];
   CopyWrapSymbols(next_line_index,0,wrap_symbols_total,array);
//--- Получим размер массива символов из предыдущей строки
   uint prev_line_symbols_total=::ArraySize(m_lines[prev_line_index].m_symbol);
//--- Увеличим размер массива предыдущей строки на добавляемое количество символов
   uint new_prev_line_size=prev_line_symbols_total+wrap_symbols_total;
   ArraysResize(prev_line_index,new_prev_line_size);
//--- Add the data to the arrays of the structure for the new line
   PasteWrapSymbols(prev_line_index,new_prev_line_size-wrap_symbols_total,array);
//--- Сместим символы на освободившееся место в текущей строке
   MoveSymbols(next_line_index,wrap_symbols_total,0);
//--- Уменьшим размер массива текущей строки на извлечённое из неё количество символов
   ArraysResize(next_line_index,symbols_total-wrap_symbols_total);
//--- Скорректировать текстовый курсор
   if((is_all_text && next_line_index==m_text_cursor_y_pos) || 
      (!is_all_text && next_line_index==m_text_cursor_y_pos && wrap_symbols_total>0))
     {
      m_text_cursor_x_pos=new_prev_line_size-(wrap_symbols_total-m_text_cursor_x_pos);
      m_text_cursor_y_pos--;
     }
//--- Выйти, если это не весь оставшийся текст строки
   if(!is_all_text)
      return;
//--- Добавить признак оконачания для предыдущей строки, если у текущей строки он тоже есть
   if(m_lines[next_line_index].m_end_of_line)
      m_lines[next_line_index-1].m_end_of_line=true;
//--- Get the size of the lines array
   uint lines_total=::ArraySize(m_lines);
//--- Сместим строки на одну вверх
   MoveLines(next_line_index,lines_total-1,false);
//--- Resize the lines array
   ::ArrayResize(m_lines,lines_total-1);
  }
//+------------------------------------------------------------------+
//| Change the width at the right edge of the form                   |
//+------------------------------------------------------------------+
void CTextBox::ChangeWidthByRightWindowSide(void)
  {
//--- Leave, if the anchoring mode to the right side of the form is enabled
   if(m_anchor_right_window_side)
      return;
//--- Coordinates
   int x=0;
//--- Sizes
   int x_size=m_wnd.X2()-CElementBase::X()-m_auto_xresize_right_offset;
   int y_size=(m_auto_yresize_mode)? m_wnd.Y2()-CElementBase::Y()-m_auto_yresize_bottom_offset : m_y_size;
//--- Set the new size
   ChangeMainSize(x_size,y_size);
//--- Calculate the size of the text box
   CalculateTextBoxSize();
//--- Calculate and set the new coordinate for the vertical scrollbar
   x=CElementBase::X2()-m_scrollv.ScrollWidth()-1;
   m_scrollv.XDistance(x);
//--- Set the new size to the text box
   ChangeTextBoxSize();
//--- В режиме переноса слов нужно повторно пересчитать и установить размеры
   if(m_word_wrap_mode)
     {
      CalculateTextBoxSize();
      ChangeTextBoxSize();
     }
//--- Нарисовать текст и дезактивировать поле ввода
   DeactivateTextBox();
  }
//+------------------------------------------------------------------+
//| Change the height at the bottom edge of the window               |
//+------------------------------------------------------------------+
void CTextBox::ChangeHeightByBottomWindowSide(void)
  {
//--- Leave, if the anchoring mode to the bottom of the form is enabled  
   if(m_anchor_bottom_window_side)
      return;
//--- Coordinates
   int y=0;
//--- Sizes
   int x_size=(m_auto_xresize_mode)? m_wnd.X2()-CElementBase::X()-m_auto_xresize_right_offset : m_x_size;
   int y_size=m_wnd.Y2()-CElementBase::Y()-m_auto_yresize_bottom_offset;
//--- Set the new size
   ChangeMainSize(x_size,y_size);
//--- Calculate the size of the text box
   CalculateTextBoxSize();
//--- Calculate and set the new coordinate for the vertical scrollbar
   y=CElementBase::Y2()-m_scrollh.ScrollWidth()-1;
   m_scrollh.YDistance(y);
//--- Set the new size to the text box
   ChangeTextBoxSize();
//--- Нарисовать текст и дезактивировать поле ввода
   DeactivateTextBox();
  }
//+------------------------------------------------------------------+
