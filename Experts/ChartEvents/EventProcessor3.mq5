//+------------------------------------------------------------------+
//|                                              EventProcessor3.mq5 |
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
input ENUM_BOOL InpIsEventObjectCreate=Yes;      // Process "Object create"?
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- object create
   bool is_obj_create=false;
   if(InpIsEventObjectCreate)
      is_obj_create=true;
   ChartSetInteger(0,CHART_EVENT_OBJECT_CREATE,is_obj_create);

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
         //--- if graphical object creation event is processed
         if(InpIsEventObjectCreate)
           {
            //--- capture creation of horizontal line
            int all_hor_lines=ObjectsTotal(0,0,OBJ_HLINE);

            //--- if this is the only line
            if(all_hor_lines==1)
              {
               string hor_line_name1=NULL;
               //--- find object name
               int all_objects=ObjectsTotal(0);
               for(int obj_idx=0;obj_idx<all_objects;obj_idx++)
                 {
                  string obj_name=ObjectName(0,obj_idx);
                  ENUM_OBJECT obj_type=(ENUM_OBJECT)ObjectGetInteger(0,obj_name,OBJPROP_TYPE);
                  //---
                  if(obj_type==OBJ_HLINE)
                    {
                     hor_line_name1=obj_name;
                     break;
                    }
                 }
               //--- if line is found
               if(hor_line_name1!=NULL)
                 {
                  //--- calculate levels
                  int visible_bars_num=ChartVisibleBars();

                  //--- arrays for high and low prices
                  double highs[],lows[];
                  //---
                  int copied=CopyHigh(_Symbol,_Period,0,visible_bars_num-1,highs);
                  if(copied!=visible_bars_num-1)
                    {
                     Print("Failed to copy highs!");
                     return;
                    }
                  copied=CopyLow(_Symbol,_Period,0,visible_bars_num-1,lows);
                  if(copied!=visible_bars_num-1)
                    {
                     Print("Failed to copy lows!");
                     return;
                    }
                  //--- high and low prices
                  double ch_high_pr,ch_low_pr,ch_mid_pr;
                  //---
                  ch_high_pr=NormalizeDouble(highs[ArrayMaximum(highs)],_Digits);
                  ch_low_pr=NormalizeDouble(lows[ArrayMinimum(lows)],_Digits);
                  ch_mid_pr=NormalizeDouble((ch_high_pr+ch_low_pr)/2.,_Digits);

                  //--- place created line on high
                  if(ObjectFind(0,hor_line_name1)>-1)
                     if(!ObjectMove(0,hor_line_name1,0,0,ch_high_pr))
                       {
                        Print("Failed to move!");
                        return;
                       }
                  //--- create line on low
                  string hor_line_name2="Hor_line_min";
                  //---
                  if(!ObjectCreate(0,hor_line_name2,OBJ_HLINE,0,0,ch_low_pr))
                    {
                     Print("Failed to create the 2nd horizontal line!");
                     return;
                    }
                  //--- create line between high and low 
                  string hor_line_name3="Hor_line_mid";
                  //---
                  if(!ObjectCreate(0,hor_line_name3,OBJ_HLINE,0,0,ch_mid_pr))
                    {
                     Print("Failed to create the 3rd horizontal line!");
                     return;
                    }
                 }
              }
           }
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
//| Returns the number of (visible) bars displayed in                |
//| chart window.                                                    |
//+------------------------------------------------------------------+
int ChartVisibleBars(const long chart_ID=0)
  {
//--- prepare the variable to get the property value
   long result=-1;
//--- reset the error value
   ResetLastError();
//--- get the property value
   if(!ChartGetInteger(chart_ID,CHART_VISIBLE_BARS,0,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return((int)result);
  }
//+------------------------------------------------------------------+
