//+------------------------------------------------------------------+
//|                                                      Defines.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
//--- "Expert in subwindow" mode
#define EXPERT_IN_SUBWINDOW false
//--- Class name
#define CLASS_NAME ::StringSubstr(__FUNCTION__,0,::StringFind(__FUNCTION__,"::"))
//--- Program name
#define PROGRAM_NAME ::MQLInfoString(MQL_PROGRAM_NAME)
//--- Program type
#define PROGRAM_TYPE (ENUM_PROGRAM_TYPE)::MQLInfoInteger(MQL_PROGRAM_TYPE)
//--- Prevention of exceeding the array size
#define PREVENTING_OUT_OF_RANGE __FUNCTION__," > Prevention of exceeding the array size."

//--- Timer step (milliseconds)
#define TIMER_STEP_MSC (16)
//--- Delay before enabling the fast forward of the counter (milliseconds)
#define SPIN_DELAY_MSC (-450)
//--- Space character
#define SPACE          (" ")

//--- To present any names in string format
#define TO_STRING(A) #A
//--- Print the event data
#define PRINT_EVENT(SID,ID,L,D,S) \
::Print(__FUNCTION__," > id: ",TO_STRING(SID)," (",ID,"); lparam: ",L,"; dparam: ",D,"; sparam: ",S);

//--- Event identifiers
#define ON_WINDOW_UNROLL            (1)  // Maximizing the form
#define ON_WINDOW_ROLLUP            (2)  // Minimizing the form
#define ON_WINDOW_CHANGE_XSIZE      (3)  // Change in the window size along the X axis
#define ON_WINDOW_CHANGE_YSIZE      (4)  // Change in the window size along the Y axis
#define ON_CLICK_MENU_ITEM          (5)  // Clicking on the menu item
#define ON_CLICK_CONTEXTMENU_ITEM   (6)  // Clicking on the menu item in a context menu
#define ON_HIDE_CONTEXTMENUS        (7)  // Hide all context menus
#define ON_HIDE_BACK_CONTEXTMENUS   (8)  // Hide context menus below the current menu item
#define ON_CLICK_BUTTON             (9)  // Pressing the button
#define ON_CLICK_FREEMENU_ITEM      (10) // Clicking on the item of a detached context menu
#define ON_CLICK_LABEL              (11) // Pressing of the text label
#define ON_OPEN_DIALOG_BOX          (12) // The opening of a dialog box event
#define ON_CLOSE_DIALOG_BOX         (13) // Closing of a dialog box event
#define ON_RESET_WINDOW_COLORS      (14) // Resetting the window color
#define ON_ZERO_PRIORITIES          (15) // Resetting priorities of the left mouse button
#define ON_SET_PRIORITIES           (16) // Restoring priorities of the left mouse click
#define ON_CLICK_LIST_ITEM          (17) // Selecting the list view item
#define ON_CLICK_COMBOBOX_ITEM      (18) // Selecting an item in the combobox list view
#define ON_END_EDIT                 (19) // Final editing of the value in the edit
#define ON_CLICK_INC                (20) // Changing the counter up
#define ON_CLICK_DEC                (21) // Changing the counter down
#define ON_CLICK_COMBOBOX_BUTTON    (22) // Clicking on the button of combo box
#define ON_CHANGE_DATE              (23) // Changing the date in the calendar
#define ON_CHANGE_TREE_PATH         (24) // The path in the tree view changed
#define ON_CHANGE_COLOR             (25) // Changing the color using the color picker
#define ON_SUBWINDOW_CHANGE_HEIGHT  (26) // Changing the subwindow height
#define ON_CLICK_TAB                (27) // Switching tabs
#define ON_CLICK_SUB_CHART          (28) // Pressing the subchart
#define ON_WINDOW_TOOLTIPS          (29) // Pressing the Tooltips button
#define ON_SORT_DATA                (30) // Sorting the data
#define ON_CLICK_TEXT_BOX           (31) // Activation of the text edit box
#define ON_MOVE_TEXT_CURSOR         (32) // Moving the text cursor
#define ON_CHANGE_MOUSE_LEFT_BUTTON (33) // Changing the state of the left mouse button
#define ON_DOUBLE_CLICK             (34) // Left mouse button double click
#define ON_CLICK_CHECKBOX           (35) // Pressing the checkbox
//+------------------------------------------------------------------+
