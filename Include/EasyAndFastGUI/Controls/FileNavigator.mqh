//+------------------------------------------------------------------+
//|                                                FileNavigator.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include "..\Element.mqh"
#include "TreeView.mqh"
//+------------------------------------------------------------------+
//| Class for creating file navigator                                |
//+------------------------------------------------------------------+
class CFileNavigator : public CElement
  {
private:
   //--- Objects for creating the element
   CRectCanvas       m_address_bar;
   CTreeView         m_treeview;
   //--- Main arrays for data storage
   int               m_g_list_index[];           // general index
   int               m_g_prev_node_list_index[]; // general index of the previous node
   string            m_g_item_text[];            // file/folder name
   int               m_g_item_index[];           // local index
   int               m_g_node_level[];           // node level
   int               m_g_prev_node_item_index[]; // local index of the previous node
   int               m_g_items_total[];          // total number of elements in folder
   int               m_g_folders_total[];        // total number of folders in folder
   bool              m_g_is_folder[];            // folder attribute
   bool              m_g_item_state[];           // item state (minimized/open)
   //--- Auxiliary arrays for data collection
   int               m_l_prev_node_list_index[];
   string            m_l_item_text[];
   string            m_l_path[];
   int               m_l_item_index[];
   int               m_l_item_total[];
   int               m_l_folders_total[];
   //--- Tree view area width
   int               m_treeview_area_width;
   //--- Content area width
   int               m_content_area_width;
   //--- Background and background frame color
   color             m_area_color;
   color             m_area_border_color;
   //--- Address bar background color
   color             m_address_bar_back_color;
   //--- Address bar text color
   color             m_address_bar_text_color;
   //--- Address bar height
   int               m_address_bar_y_size;
   //--- Icons for (1) folders and (2) files
   string            m_file_icon;
   string            m_folder_icon;
   //--- Current path relative to the file "sandbox" of the terminal
   string            m_current_path;
   //--- Current path relative to the file system, including the hard drive volume label
   string            m_current_full_path;
   //--- Area of the current directory
   int               m_directory_area;
   //--- Priorities of the left mouse button press
   int               m_zorder;
   //--- File navigator content mode
   ENUM_FILE_NAVIGATOR_CONTENT m_navigator_content;
   //---
public:
                     CFileNavigator(void);
                    ~CFileNavigator(void);
   //--- Methods for creating file navigator
   bool              CreateFileNavigator(const long chart_id,const int subwin,const int x_gap,const int y_gap);
   //---
private:
   bool              CreateAddressBar(void);
   bool              CreateTreeView(void);
   //---
public:
   //--- (1) Returns pointer to the tree view, 
   //    (2) navigator mode (Show all/Only folders), (3) navigator content (Common Folder/Local/All)
   CTreeView        *TreeViewPointer(void)                                    { return(::GetPointer(m_treeview));          }
   void              NavigatorMode(const ENUM_FILE_NAVIGATOR_MODE mode)       { m_treeview.NavigatorMode(mode);            }
   void              NavigatorContent(const ENUM_FILE_NAVIGATOR_CONTENT mode) { m_navigator_content=mode;                  }
   //--- (1) Address bar height, (2) width of the tree view and (3) the content list
   void              AddressBarYSize(const int y_size)                        { m_address_bar_y_size=y_size;               }
   void              TreeViewAreaWidth(const int x_size)                      { m_treeview_area_width=x_size;              }
   void              ContentAreaWidth(const int x_size)                       { m_content_area_width=x_size;               }
   //--- (1) Color of the background and (2) background frame
   void              AreaBackColor(const color clr)                           { m_area_color=clr;                          }
   void              AreaBorderColor(const color clr)                         { m_area_border_color=clr;                   }
   //--- Color of (1) the background and (2) address bar text
   void              AddressBarBackColor(const color clr)                     { m_address_bar_back_color=clr;              }
   void              AddressBarTextColor(const color clr)                     { m_address_bar_text_color=clr;              }
   //--- Set the file paths to the (1) files and (2) folders
   void              FileIcon(const string file_path)                         { m_file_icon=file_path;                     }
   void              FolderIcon(const string file_path)                       { m_folder_icon=file_path;                   }
   //--- Returns (1) the current path and (2) the full path, (3) the selected file
   string            CurrentPath(void)                                  const { return(m_current_path);                    }
   string            CurrentFullPath(void)                              const { return(m_current_full_path);               }
   //--- Returns (1) directory area and (2) the selected file
   int               DirectoryArea(void)                                const { return(m_directory_area);                  }
   string            SelectedFile(void)                                 const { return(m_treeview.SelectedItemFileName()); }
   //---
public:
   //--- Chart event handler
   virtual void      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   //--- Timer
   virtual void      OnEventTimer(void) {}
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
   //--- Handle event of selecting a new path in the tree view
   void              OnChangeTreePath(void);

   //--- Draws a border for the address bar
   void              Border(void);
   //--- Displays the current path in the address bar
   void              UpdateAddressBar(void);

   //--- Fills arrays with parameters of the terminal file system elements
   void              FillArraysData(void);
   //--- Reads the file system and writes parameters to arrays
   void              FileSystemScan(const int root_index,int &list_index,int &node_level,int &item_index,int search_area);
   //--- Changes the size of the auxiliary arrays relative to the current node level 
   void              AuxiliaryArraysResize(const int node_level);
   //--- Determines if a file or folder name was passed
   bool              IsFolder(const string file_name);
   //--- Returns the number of (1) items and (2) folders in the specified directory
   int               ItemsTotal(const string search_path,const int mode);
   int               FoldersTotal(const string search_path,const int mode);
   //--- Returns the local index of the previous node relative to the parameters passed
   int               PrevNodeItemIndex(const int root_index,const int node_level);

   //--- Adds item to the array
   void              AddItem(const int list_index,const string item_text,const int node_level,const int prev_node_item_index,
                             const int item_index,const int items_total,const int folders_total,const bool is_folder);
   //--- Go to the next node
   void              ToNextNode(const int root_index,int list_index,int &node_level,
                                int &item_index,long &handle,const string item_text,const int search_area);

   //--- Change the width at the right edge of the window
   virtual void      ChangeWidthByRightWindowSide(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CFileNavigator::CFileNavigator(void) : m_current_path(""),
                                       m_current_full_path(""),
                                       m_directory_area(FILE_COMMON),
                                       m_address_bar_y_size(20),
                                       m_treeview_area_width(300),
                                       m_content_area_width(0),
                                       m_navigator_content(FN_ONLY_MQL),
                                       m_area_border_color(clrLightGray),
                                       m_address_bar_back_color(clrWhiteSmoke),
                                       m_address_bar_text_color(clrBlack),
                                       m_file_icon("Images\\EasyAndFastGUI\\Icons\\bmp16\\text_file_w10.bmp"),
                                       m_folder_icon("Images\\EasyAndFastGUI\\Icons\\bmp16\\folder_w10.bmp")
  {
//--- Store the name of the element class in the base class
   CElementBase::ClassName(CLASS_NAME);
//--- Set priorities of the left mouse button click
   m_zorder=0;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CFileNavigator::~CFileNavigator(void)
  {
  }
//+------------------------------------------------------------------+
//| Event handler                                                    |
//+------------------------------------------------------------------+
void CFileNavigator::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
//--- Handle event of "Change in the path of the tree view"
   if(id==CHARTEVENT_CUSTOM+ON_CHANGE_TREE_PATH)
     {
      OnChangeTreePath();
      return;
     }
  }
//+------------------------------------------------------------------+
//| Create file navigator                                            |
//+------------------------------------------------------------------+
bool CFileNavigator::CreateFileNavigator(const long chart_id,const int subwin,const int x_gap,const int y_gap)
  {
//--- Exit if there is no pointer to the form
   if(!CElement::CheckWindowPointer())
      return(false);
//--- Scan the file system of the terminal and store data in arrays
   FillArraysData();
//--- Initializing variables
   m_id       =m_wnd.LastId()+1;
   m_chart_id =chart_id;
   m_subwin   =subwin;
   m_x        =CElement::CalculateX(x_gap);
   m_y        =CElement::CalculateY(y_gap);
//--- Margins from the edge
   CElementBase::XGap(x_gap);
   CElementBase::YGap(y_gap);
//--- Creating an element
   if(!CreateAddressBar())
      return(false);
   if(!CreateTreeView())
      return(false);
//--- Hide the element if the window is a dialog one or is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      Hide();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Create address bar                                               |
//+------------------------------------------------------------------+
bool CFileNavigator::CreateAddressBar(void)
  {
//--- Formation of the window name
   string name=CElementBase::ProgramName()+"_file_navigator_address_bar_"+(string)CElementBase::Id();
//--- Coordinates
   int x =CElementBase::X();
   int y =CElementBase::Y();
//--- Sizes:
//    Calculate the width
   int x_size=0;
//--- If there is no content area
   if(m_content_area_width<0)
      x_size=m_treeview_area_width;
   else
     {
      //--- If a specific width of the content area is defined
      if(m_content_area_width>0)
         //--- Calculation considering the anchor point of the right side of the navigator to the right edge of the form
         x_size=(m_auto_xresize_mode)? m_wnd.X2()-x-m_auto_xresize_right_offset : m_treeview_area_width+m_content_area_width-1;
      //--- If the right edge of the content area must be at the right edge of the form
      else
         x_size=m_wnd.X2()-x-m_auto_xresize_right_offset;
     }
//--- Height
   int y_size=m_address_bar_y_size;
//---
   CElementBase::XSize(x_size);
//--- Creating the object
   if(!m_address_bar.CreateBitmapLabel(m_chart_id,m_subwin,name,x,y,x_size,y_size,COLOR_FORMAT_XRGB_NOALPHA))
      return(false);
//--- Attach to the chart
   if(!m_address_bar.Attach(m_chart_id,name,m_subwin,1))
      return(false);
//--- Set properties
   m_address_bar.Background(false);
   m_address_bar.Z_Order(m_zorder);
   m_address_bar.Tooltip("\n");
//--- Store the size
   m_address_bar.X(x);
   m_address_bar.Y(y);
//--- Store the size
   m_address_bar.XSize(x_size);
   m_address_bar.YSize(y_size);
//--- Margins from the edge
   m_address_bar.XGap(CElement::CalculateXGap(x));
   m_address_bar.YGap(CElement::CalculateYGap(y));
//--- Update the address bar
   UpdateAddressBar();
//--- Store the object pointer
   CElementBase::AddToArray(m_address_bar);
//--- Hide the element if the window is a dialog one or is minimized
   if(m_wnd.WindowType()==W_DIALOG || m_wnd.IsMinimized())
      m_address_bar.Timeframes(OBJ_NO_PERIODS);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Creates the tree view                                            |
//+------------------------------------------------------------------+
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\folder_w10.bmp"
#resource "\\Images\\EasyAndFastGUI\\Icons\\bmp16\\text_file_w10.bmp"
//---
bool CFileNavigator::CreateTreeView(void)
  {
//--- Coordinates
   int x =CElement::CalculateXGap(CElementBase::X());
   int y =CElement::CalculateYGap(CElementBase::Y()+m_address_bar_y_size);
//--- Store the window pointer
   m_treeview.WindowPointer(m_wnd);
//--- Set properties
   m_treeview.Id(CElementBase::Id());
   m_treeview.ResizeListAreaMode(true);
   m_treeview.TreeViewAreaWidth(m_treeview_area_width);
   m_treeview.ContentAreaWidth(m_content_area_width);
   m_treeview.AutoXResizeMode(CElementBase::AutoXResizeMode());
   m_treeview.AutoXResizeRightOffset(CElementBase::AutoXResizeRightOffset());
   m_treeview.AnchorRightWindowSide(CElementBase::AnchorRightWindowSide());
   m_treeview.AnchorBottomWindowSide(CElementBase::AnchorBottomWindowSide());
//--- Form the tree view arrays
   int items_total=::ArraySize(m_g_item_text);
   for(int i=0; i<items_total; i++)
     {
      //--- Set icon for the item (folder/file)
      string icon_path=(m_g_is_folder[i])? m_folder_icon : m_file_icon;
      //--- If it is a folder, delete the last character ('\') in the string 
      if(m_g_is_folder[i])
         m_g_item_text[i]=::StringSubstr(m_g_item_text[i],0,::StringLen(m_g_item_text[i])-1);
      //--- Add item to the tree view
      m_treeview.AddItem(i,m_g_prev_node_list_index[i],m_g_item_text[i],icon_path,m_g_item_index[i],
                         m_g_node_level[i],m_g_prev_node_item_index[i],m_g_items_total[i],m_g_folders_total[i],false,m_g_is_folder[i]);
     }
//--- Create the tree view
   if(!m_treeview.CreateTreeView(m_chart_id,m_subwin,x,y))
      return(false);
//--- Store the navigator sizes
   CElementBase::XSize(m_treeview.XSize());
   CElementBase::YSize(m_treeview.YSize()+m_address_bar_y_size);
   return(true);
  }
//+------------------------------------------------------------------+
//| Handle event of selecting a new path in the tree view            |
//+------------------------------------------------------------------+
void CFileNavigator::OnChangeTreePath(void)
  {
//--- Get the current path
   string path=m_treeview.CurrentFullPath();
//--- If this is the terminals common folder
   if(::StringFind(path,"Common\\Files\\",0)>-1)
     {
      //--- Get the address of the terminals common folder
      string common_path=::TerminalInfoString(TERMINAL_COMMONDATA_PATH);
      //--- Delete the "Common\" prefix in the string (received in the event)
      path=::StringSubstr(path,7,::StringLen(common_path)-7);
      //--- Generate the path (short and full version)
      m_current_path      =::StringSubstr(path,6,::StringLen(path)-6);
      m_current_full_path =common_path+"\\"+path;
      //--- Store the directory area
      m_directory_area=FILE_COMMON;
     }
//--- If this is the local folder of the terminal
   else if(::StringFind(path,"MQL5\\Files\\",0)>-1)
     {
      //--- Get the address of data in the local folder of the terminal
      string local_path=::TerminalInfoString(TERMINAL_DATA_PATH);
      //--- Generate the path (short and full version)
      m_current_path      =::StringSubstr(path,11,::StringLen(path)-11);
      m_current_full_path =local_path+"\\"+path;
      //--- Store the directory area
      m_directory_area=0;
     }
//--- Display the current path in the address bar
   UpdateAddressBar();
  }
//+------------------------------------------------------------------+
//| Draws a border for the address bar                               |
//+------------------------------------------------------------------+
void CFileNavigator::Border(void)
  {
//--- Coordinates
   int  x1=0,x2=0,y1=0,y2=0;
//--- Background color
   uint clr=::ColorToARGB(m_area_border_color);
//--- Sizes
   int x_size =m_x_size;
   int y_size =m_address_bar_y_size;
//--- Left
   for(int i=y_size; i>=0; i--)
     {
      //--- Coordinates
      x1=0; x2=i; y1=0; y2=i;
      //--- Draw a line
      m_address_bar.Line(x1,x2,y1,y2,clr);
     }
//--- Top
   for(int i=0; i<x_size; i++)
     {
      //--- Coordinates
      x1=i; x2=0; y1=i; y2=0;
      //--- Draw a line
      m_address_bar.Line(x1,x2,y1,y2,clr);
     }
//--- Right
   for(int i=0; i<y_size; i++)
     {
      //--- Coordinates
      x1=x_size-1; x2=i; y1=x_size-1; y2=i;
      //--- Draw a line
      m_address_bar.Line(x1,x2,y1,y2,clr);
     }
  }
//+------------------------------------------------------------------+
//| Display the current path in the address bar                      |
//+------------------------------------------------------------------+
void CFileNavigator::UpdateAddressBar(void)
  {
//--- Coordinates
   int x=5;
   int y=m_address_bar_y_size/2;
//--- Clear background
   m_address_bar.Erase(::ColorToARGB(m_address_bar_back_color,0));
//--- Draw the background frame
   Border();
//--- Text properties
   m_address_bar.FontSet(CElementBase::Font(),-CElementBase::FontSize()*10,FW_NORMAL);
//--- If the path is not set, show the default string
   if(m_current_full_path=="")
      m_current_full_path="Loading. Please wait...";
//--- Output the path to the address bar of the file navigator
   m_address_bar.TextOut(x,y,m_current_full_path,::ColorToARGB(m_address_bar_text_color),TA_LEFT|TA_VCENTER);
//--- Update the canvas for drawing
   m_address_bar.Update();
  }
//+------------------------------------------------------------------+
//| Fills arrays with parameters of the file system elements         |
//+------------------------------------------------------------------+
void CFileNavigator::FillArraysData(void)
  {
//--- Counters of (1) general indices, (2) node levels, (3) local indices
   int list_index =0;
   int node_level =0;
   int item_index =0;
//--- If both directories must be displayed (Common (0)/Local (1))
   int begin=0,end=1;
//--- If only the content of the local directory must be displayed
   if(m_navigator_content==FN_ONLY_MQL)
      begin=1;
//--- If only the content of the common directory must be displayed
   else if(m_navigator_content==FN_ONLY_COMMON)
      begin=end=0;
//--- Iterate over the specified directories
   for(int root_index=begin; root_index<=end; root_index++)
     {
      //--- Determine the directory for scanning the file structure
      int search_area=(root_index>0) ? 0 : FILE_COMMON;
      //--- Reset the counter of the local indices
      item_index=0;
      //--- Increase the array size by one element (relative to the node level)
      AuxiliaryArraysResize(node_level);
      //--- Get the number of files and folders in the specified directory (* - scan all files/folders)
      string search_path   =m_l_path[0]+"*";
      m_l_item_total[0]    =ItemsTotal(search_path,search_area);
      m_l_folders_total[0] =FoldersTotal(search_path,search_area);
      //--- Add item with the name of the root directory to the top of the list
      string item_text=(root_index>0)? "MQL5\\Files\\" : "Common\\Files\\";
      AddItem(list_index,item_text,0,0,root_index,m_l_item_total[0],m_l_folders_total[0],true);
      //--- Increase the counters of general indices and node levels
      list_index++;
      node_level++;
      //--- Increase the array size by one element (relative to the node level)
      AuxiliaryArraysResize(node_level);
      //--- Initialize the first items for the directory of the local folder of the terminal
      if(root_index>0)
        {
         m_l_item_index[0]           =root_index;
         m_l_prev_node_list_index[0] =list_index-1;
        }
      //--- Scan the directories and store data in arrays
      FileSystemScan(root_index,list_index,node_level,item_index,search_area);
     }
  }
//+------------------------------------------------------------------+
//| Reads the file system and writes item parameters                 |
//| in arrays                                                        |
//+------------------------------------------------------------------+
void CFileNavigator::FileSystemScan(const int root_index,int &list_index,int &node_level,int &item_index,int search_area)
  {
   long   search_handle =INVALID_HANDLE; // Folder/file search handle
   string file_name     ="";             // Name of the found item (file/folder)
   string filter        ="*";            // Search filter (* - check all files/folders)
//--- Scan the directories and store data in arrays
   while(!::IsStopped())
     {
      // --- If this is the beginning of the directory list
      if(item_index==0)
        {
         //--- Path for searching for all items
         string search_path=m_l_path[node_level]+filter;
         //--- Get the handle and name of the first file
         search_handle=::FileFindFirst(search_path,file_name,search_area);
         //--- Get the number of files and folders in the specified directory
         m_l_item_total[node_level]    =ItemsTotal(search_path,search_area);
         m_l_folders_total[node_level] =FoldersTotal(search_path,search_area);
        }
      //--- If the index of this node had already been used, go to the next file
      if(m_l_item_index[node_level]>-1 && item_index<=m_l_item_index[node_level])
        {
         // --- Increase the counter of local indices
         item_index++;
         //--- Go to the next item
         ::FileFindNext(search_handle,file_name);
         continue;
        }
      //--- If reached the end of list in the root node, end the loop
      if(node_level==1 && item_index>=m_l_item_total[node_level])
         break;
      //--- If reached the end of list in any node, except the root node
      else if(item_index>=m_l_item_total[node_level])
        {
         //--- Set the node counter one level back
         node_level--;
         //--- Zero the counter of local indices
         item_index=0;
         //--- Close the search handle
         ::FileFindClose(search_handle);
         continue;
        }
      //--- If this is folder
      if(IsFolder(file_name))
        {
         //--- Go to the next node
         ToNextNode(root_index,list_index,node_level,item_index,search_handle,file_name,search_area);
         //--- Increase the counter of general indices and start a new iteration
         list_index++;
         continue;
        }
      //--- Get the local index of the previous node
      int prev_node_item_index=PrevNodeItemIndex(root_index,node_level);
      //--- Add item with the specified data to the general arrays
      AddItem(list_index,file_name,node_level,prev_node_item_index,item_index,0,0,false);
      // --- Increase the counter of general indices
      list_index++;
      // --- Increase the counter of local indices
      item_index++;
      //--- Go to the next item
      ::FileFindNext(search_handle,file_name);
     }
//--- Close the search handle
   ::FileFindClose(search_handle);
  }
//+------------------------------------------------------------------+
//| Change the size of the auxiliary arrays                          |
//| relative to the current node level                               |
//+------------------------------------------------------------------+
void CFileNavigator::AuxiliaryArraysResize(const int node_level)
  {
   int new_size=node_level+1;
   ::ArrayResize(m_l_prev_node_list_index,new_size);
   ::ArrayResize(m_l_item_text,new_size);
   ::ArrayResize(m_l_path,new_size);
   ::ArrayResize(m_l_item_index,new_size);
   ::ArrayResize(m_l_item_total,new_size);
   ::ArrayResize(m_l_folders_total,new_size);
//--- Initialize the last value
   m_l_prev_node_list_index[node_level] =0;
   m_l_item_text[node_level]            ="";
   m_l_path[node_level]                 ="";
   m_l_item_index[node_level]           =-1;
   m_l_item_total[node_level]           =0;
   m_l_folders_total[node_level]        =0;
  }
//+------------------------------------------------------------------+
//| Determine if a file or folder was passed                         |
//+------------------------------------------------------------------+
bool CFileNavigator::IsFolder(const string file_name)
  {
//--- If the name contains "\\", characters, then it is a folder
   if(::StringFind(file_name,"\\",0)>-1)
      return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Count the number of files in the current directory               |
//+------------------------------------------------------------------+
int CFileNavigator::ItemsTotal(const string search_path,const int search_area)
  {
   int    counter       =0;              // item counter 
   string file_name     ="";             // file name
   long   search_handle =INVALID_HANDLE; // search handle
//--- Get the first file in the current directory
   search_handle=::FileFindFirst(search_path,file_name,search_area);
//-- If the directory is not empty
   if(search_handle!=INVALID_HANDLE && file_name!="")
     {
      //--- Count the number of objects in the current directory
      counter++;
      while(::FileFindNext(search_handle,file_name))
         counter++;
     }
//--- Close the search handle
   ::FileFindClose(search_handle);
   return(counter);
  }
//+------------------------------------------------------------------+
//| Count the number of folders in the current directory             |
//+------------------------------------------------------------------+
int CFileNavigator::FoldersTotal(const string search_path,const int search_area)
  {
   int    counter       =0;              // item counter 
   string file_name     ="";             // file name
   long   search_handle =INVALID_HANDLE; // search handle
//--- Get the first file in the current directory
   search_handle=::FileFindFirst(search_path,file_name,search_area);
//--- If not empty, count the number of objects in the current directory in a loop
   if(search_handle!=INVALID_HANDLE && file_name!="")
     {
      //--- If this is folder, increase the counter
      if(IsFolder(file_name))
         counter++;
      //--- Iterate over the list further and count the other folders
      while(::FileFindNext(search_handle,file_name))
        {
         if(IsFolder(file_name))
            counter++;
        }
     }
//--- Close the search handle
   ::FileFindClose(search_handle);
   return(counter);
  }
//+------------------------------------------------------------------+
//| Return the local index of the previous node                      |
//| relative to the passed parameters                                |
//+------------------------------------------------------------------+
int CFileNavigator::PrevNodeItemIndex(const int root_index,const int node_level)
  {
   int prev_node_item_index=0;
//--- If not the root directory
   if(node_level>1)
      prev_node_item_index=m_l_item_index[node_level-1];
   else
     {
      //--- If not the first item in the list
      if(root_index>0)
         prev_node_item_index=m_l_item_index[node_level-1];
     }
//--- Return the local index of the previous node
   return(prev_node_item_index);
  }
//+------------------------------------------------------------------+
//| Add item with the specified parameters to the arrays             |
//+------------------------------------------------------------------+
void CFileNavigator::AddItem(const int list_index,const string item_text,const int node_level,const int prev_node_item_index,
                             const int item_index,const int items_total,const int folders_total,const bool is_folder)
  {
//--- Reserve size of the array
   int reserve_size=100000;
//--- Increase the array size by one element
   int array_size =::ArraySize(m_g_list_index);
   int new_size   =array_size+1;
   ::ArrayResize(m_g_prev_node_list_index,new_size,reserve_size);
   ::ArrayResize(m_g_list_index,new_size,reserve_size);
   ::ArrayResize(m_g_item_text,new_size,reserve_size);
   ::ArrayResize(m_g_item_index,new_size,reserve_size);
   ::ArrayResize(m_g_node_level,new_size,reserve_size);
   ::ArrayResize(m_g_prev_node_item_index,new_size,reserve_size);
   ::ArrayResize(m_g_items_total,new_size,reserve_size);
   ::ArrayResize(m_g_folders_total,new_size,reserve_size);
   ::ArrayResize(m_g_is_folder,new_size,reserve_size);
//--- Store the values of passed parameters
   m_g_prev_node_list_index[array_size] =(node_level==0)? -1 : m_l_prev_node_list_index[node_level-1];
   m_g_list_index[array_size]           =list_index;
   m_g_item_text[array_size]            =item_text;
   m_g_item_index[array_size]           =item_index;
   m_g_node_level[array_size]           =node_level;
   m_g_prev_node_item_index[array_size] =prev_node_item_index;
   m_g_items_total[array_size]          =items_total;
   m_g_folders_total[array_size]        =folders_total;
   m_g_is_folder[array_size]            =is_folder;
  }
//+------------------------------------------------------------------+
//| Go to the next node                                              |
//+------------------------------------------------------------------+
void CFileNavigator::ToNextNode(const int root_index,int list_index,int &node_level,
                                int &item_index,long &handle,const string item_text,const int search_area)
  {
//--- Search filter (* - check all files/folders)
   string filter="*";
//--- Generate the path
   string search_path=m_l_path[node_level]+item_text+filter;
//--- Get and store data
   m_l_item_total[node_level]           =ItemsTotal(search_path,search_area);
   m_l_folders_total[node_level]        =FoldersTotal(search_path,search_area);
   m_l_item_text[node_level]            =item_text;
   m_l_item_index[node_level]           =item_index;
   m_l_prev_node_list_index[node_level] =list_index;
//--- Get the index of the previous node item
   int prev_node_item_index=PrevNodeItemIndex(root_index,node_level);
//--- Add item with the specified data to the general arrays
   AddItem(list_index,item_text,node_level,prev_node_item_index,
           item_index,m_l_item_total[node_level],m_l_folders_total[node_level],true);
//--- Increase the node counter
   node_level++;
//--- Increase the array size by one element
   AuxiliaryArraysResize(node_level);
//--- Get and store data
   m_l_path[node_level]          =m_l_path[node_level-1]+item_text;
   m_l_item_total[node_level]    =ItemsTotal(m_l_path[node_level]+filter,search_area);
   m_l_folders_total[node_level] =FoldersTotal(m_l_path[node_level]+item_text+filter,search_area);
//--- Zero the counter of local indices
   item_index=0;
//--- Close the search handle
   ::FileFindClose(handle);
  }
//+------------------------------------------------------------------+
//| Moving elements                                                  |
//+------------------------------------------------------------------+
void CFileNavigator::Moving(const int x,const int y,const bool moving_mode=false)
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
      m_address_bar.X(m_wnd.X2()-m_address_bar.XGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::X(x+XGap());
      //--- Storing coordinates in the fields of the objects
      m_address_bar.X(x+m_address_bar.XGap());
     }
//--- If the anchored to the bottom
   if(m_anchor_bottom_window_side)
     {
      //--- Storing coordinates in the element fields
      CElementBase::Y(m_wnd.Y2()-YGap());
      //--- Storing coordinates in the fields of the objects
      m_address_bar.Y(m_wnd.Y2()-m_address_bar.YGap());
     }
   else
     {
      //--- Storing coordinates in the fields of the objects
      CElementBase::Y(y+YGap());
      //--- Storing coordinates in the fields of the objects
      m_address_bar.Y(y+m_address_bar.YGap());
     }
//--- Updating coordinates of graphical objects
   m_address_bar.X_Distance(m_address_bar.X());
   m_address_bar.Y_Distance(m_address_bar.Y());
  }
//+------------------------------------------------------------------+
//| Shows the element                                                |
//+------------------------------------------------------------------+
void CFileNavigator::Show(void)
  {
   m_address_bar.Timeframes(OBJ_ALL_PERIODS);
   m_treeview.Show();
//--- Visible state
   CElementBase::IsVisible(true);
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
//| Hides the element                                                |
//+------------------------------------------------------------------+
void CFileNavigator::Hide(void)
  {
   m_address_bar.Timeframes(OBJ_NO_PERIODS);
   m_treeview.Hide();
//--- Visible state
   CElementBase::IsVisible(false);
  }
//+------------------------------------------------------------------+
//| Redrawing                                                        |
//+------------------------------------------------------------------+
void CFileNavigator::Reset(void)
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
void CFileNavigator::Delete(void)
  {
//--- Delete graphical objects
   m_address_bar.Delete();
   m_treeview.Delete();
//--- Emptying the control arrays
   ::ArrayFree(m_g_prev_node_list_index);
   ::ArrayFree(m_g_list_index);
   ::ArrayFree(m_g_item_text);
   ::ArrayFree(m_g_item_index);
   ::ArrayFree(m_g_node_level);
   ::ArrayFree(m_g_prev_node_item_index);
   ::ArrayFree(m_g_items_total);
   ::ArrayFree(m_g_folders_total);
   ::ArrayFree(m_g_item_state);
//---
   ::ArrayFree(m_l_prev_node_list_index);
   ::ArrayFree(m_l_item_text);
   ::ArrayFree(m_l_path);
   ::ArrayFree(m_l_item_index);
   ::ArrayFree(m_l_item_total);
   ::ArrayFree(m_l_folders_total);
//--- Emptying the array of the objects
   CElementBase::FreeObjectsArray();
//--- Zero variables
   m_current_path="";
  }
//+------------------------------------------------------------------+
//| Seth the priorities                                              |
//+------------------------------------------------------------------+
void CFileNavigator::SetZorders(void)
  {
   m_address_bar.Z_Order(m_zorder);
   m_treeview.SetZorders();
  }
//+------------------------------------------------------------------+
//| Reset the priorities                                             |
//+------------------------------------------------------------------+
void CFileNavigator::ResetZorders(void)
  {
   m_address_bar.Z_Order(0);
   m_treeview.ResetZorders();
  }
//+------------------------------------------------------------------+
//| Change the width at the right edge of the form                   |
//+------------------------------------------------------------------+
void CFileNavigator::ChangeWidthByRightWindowSide(void)
  {
//--- Leave, if anchoring mode to the right side of the window is enabled
   if(m_anchor_right_window_side)
      return;
//--- Sizes
   int x_size=0;
//--- Calculate and set the new size to the control background
   x_size=m_wnd.X2()-m_address_bar.X()-m_auto_xresize_right_offset;
   CElementBase::XSize(x_size);
   m_address_bar.XSize(x_size);
   m_address_bar.Resize(x_size,m_address_bar.YSize());
//--- Update the address bar
   UpdateAddressBar();
//--- Update the position of objects
   Moving(m_wnd.X(),m_wnd.Y(),true);
  }
//+------------------------------------------------------------------+
