//+------------------------------------------------------------------+
//|                                              EventProcessor5.mq5 |
//|                                           Copyright 2014, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, denkir"
#property link      "https://login.mql5.com/en/users/denkir"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_BOOL
  {
   No=0,  // No
   Yes=1, // Yes
  };
//+------------------------------------------------------------------+
//| Iputs                                                            |
//+------------------------------------------------------------------+
sinput string Info_flags="+===--Process events--====+";   // +===--Process events--====+
input ENUM_BOOL InpIsEventObjectDelete=Yes;      // Process "Object delete"?

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- object delete
   bool is_obj_delete=false;
   if(InpIsEventObjectDelete)
      is_obj_delete=true;
   ChartSetInteger(0,CHART_EVENT_OBJECT_DELETE,is_obj_delete);

//---
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,// event identifier:
                  const long   &lparam,
                  const double &dparam,
                  const string &sparam
                  )
  {
   string comment="Last event: ";

//--- select event on chart
   switch(id)
     {
      //--- 1
      case CHARTEVENT_KEYDOWN:
        {
         comment+="1) keystroke";
         //---
         break;
        }
      //--- 2
      case CHARTEVENT_MOUSE_MOVE:
        {
         comment+="2) mouse";
         //---
         break;
        }
      //--- 3
      case CHARTEVENT_OBJECT_CREATE:
        {
         comment+="3) create graphical object";
         //---
         break;
        }
      //--- 4
      case CHARTEVENT_OBJECT_CHANGE:
        {
         comment+="4) change object properties via properties dialog";
         //---
         break;
        }
      //--- 5
      case CHARTEVENT_OBJECT_DELETE:
        {
         comment+="5) delete graphical object";
         //--- if graphical object removal event is processed
         if(InpIsEventObjectDelete)
           {
            int vert_lines_num=ObjectsTotal(0,0,OBJ_VLINE);
            PrintFormat("Vertical lines before removal: %d",vert_lines_num);

            //---
            string curr_obj_name=sparam;
            //--- no object
            if(ObjectFind(0,curr_obj_name)<0)
              {
               //--- delete all vertical lines
               int deleted_vert_lines_num=ObjectsDeleteAll(0,0,OBJ_VLINE);
               PrintFormat("Vertical lines removed from chart: %d",deleted_vert_lines_num);
               //--- redraw chart
               Sleep(125);
               ChartRedraw();
               //---
               vert_lines_num=ObjectsTotal(0,0,OBJ_VLINE);
               PrintFormat("Vertical lines after removal: %d",vert_lines_num);
              }
           }
         //---
         break;
        }
      //--- 6
      case CHARTEVENT_CLICK:
        {
         comment+="6) mouse click on chart";
         //---
         break;
        }
      //--- 7
      case CHARTEVENT_OBJECT_CLICK:
        {
         comment+="7) mouse click on graphical object";
         //---
         break;
        }
      //--- 8
      case CHARTEVENT_OBJECT_DRAG:
        {
         comment+="8) move graphical object with mouse";
         //---
         break;
        }
      //--- 9
      case CHARTEVENT_OBJECT_ENDEDIT:
        {
         comment+="9) finish editing text";
         //---
         break;
        }
      //--- 10
      case CHARTEVENT_CHART_CHANGE:
        {
         comment+="10) modify chart";
         //---
         break;
        }
     }

//---
   Comment(comment);
  }
//+------------------------------------------------------------------+
