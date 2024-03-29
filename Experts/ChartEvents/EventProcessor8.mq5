//+------------------------------------------------------------------+
//|                                              EventProcessor8.mq5 |
//|                                           Copyright 2014, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, denkir"
#property link      "https://login.mql5.com/en/users/denkir"
#property version   "1.00"

//+------------------------------------------------------------------+
//| Easy access to the trade functions                               |
//+------------------------------------------------------------------+
#include <Trade\Trade.mqh>
#include<Indicators\TimeSeries.mqh>
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

//--- CiTime object
CiTime myTime;
//--- names of vertical lines
string gTimeLimit1_name="TimeLimit1_vert_line";
string gTimeLimit2_name="TimeLimit2_vert_line";
//--- names of rectangles
string gRectLimit1_name="TimeLimit1_rect";
string gRectLimit2_name="TimeLimit2_rect";
//--- properties of rectangles
datetime gRec1_time1,gRec1_time2;
double gRec1_pr1,gRec1_pr2;
datetime gRec2_time1,gRec2_time2;
double gRec2_pr1,gRec2_pr2;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- minimum 20 bars on chart
   int all_bars=ChartVisibleBars();
   if(all_bars>19)
      if(myTime.Create(_Symbol,_Period))
        {
         myTime.Refresh(-1);
         //--- create vertical lines
         datetime start_time=myTime.GetData(18);
         datetime finish_time=myTime.GetData(1);
         if(ObjectCreate(0,gTimeLimit1_name,OBJ_VLINE,0,start_time,0.0))
            if(ObjectCreate(0,gTimeLimit2_name,OBJ_VLINE,0,finish_time,0.0))
               //--- set properties
               if(ObjectSetInteger(0,gTimeLimit1_name,OBJPROP_ZORDER,1))
                  if(ObjectSetInteger(0,gTimeLimit1_name,OBJPROP_COLOR,clrGreen))
                     if(ObjectSetInteger(0,gTimeLimit1_name,OBJPROP_SELECTABLE,true))
                        if(ObjectSetInteger(0,gTimeLimit1_name,OBJPROP_WIDTH,4))
                           if(ObjectSetInteger(0,gTimeLimit2_name,OBJPROP_ZORDER,1))
                              if(ObjectSetInteger(0,gTimeLimit2_name,OBJPROP_COLOR,clrRed))
                                 if(ObjectSetInteger(0,gTimeLimit2_name,OBJPROP_SELECTABLE,true))
                                    if(ObjectSetInteger(0,gTimeLimit2_name,OBJPROP_WIDTH,4))
                                       if(RefreshRecPoints(start_time,finish_time))
                                         {
                                          //--- create rectangles
                                          if(ObjectCreate(0,gRectLimit1_name,OBJ_RECTANGLE,0,gRec1_time1,gRec1_pr1,
                                             gRec1_time2,gRec1_pr2))
                                             if(ObjectCreate(0,gRectLimit2_name,OBJ_RECTANGLE,0,gRec2_time1,gRec2_pr1,
                                                gRec2_time2,gRec2_pr2))
                                               {
                                                //--- color
                                                ObjectSetInteger(0,gRectLimit1_name,OBJPROP_COLOR,clrGray);
                                                ObjectSetInteger(0,gRectLimit2_name,OBJPROP_COLOR,clrGray);
                                                //--- fill
                                                ObjectSetInteger(0,gRectLimit1_name,OBJPROP_FILL,true);
                                                ObjectSetInteger(0,gRectLimit2_name,OBJPROP_FILL,true);
                                                //--- on background
                                                ObjectSetInteger(0,gRectLimit1_name,OBJPROP_BACK,true);
                                                ObjectSetInteger(0,gRectLimit2_name,OBJPROP_BACK,true);
                                                //--- redraw chart
                                                ChartRedraw();

                                                //---
                                                return INIT_SUCCEEDED;
                                               }
                                         }
        }

//---
   return INIT_FAILED;
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(ObjectFind(0,gTimeLimit1_name)>-1)
      ObjectDelete(0,gTimeLimit1_name);
   if(ObjectFind(0,gTimeLimit2_name)>-1)
      ObjectDelete(0,gTimeLimit2_name);
   if(ObjectFind(0,gRectLimit1_name)>-1)
      ObjectDelete(0,gRectLimit1_name);
   if(ObjectFind(0,gRectLimit2_name)>-1)
      ObjectDelete(0,gRectLimit2_name);
//---
   ChartRedraw();
//---
   Comment("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
         //---
         break;
        }
      //--- 6
      case CHARTEVENT_CLICK:
        {
         comment+="6) mouse click on chart";
         //--- check the moment of creation
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
         string curr_obj_name=sparam;
         //--- if one of the vertical lines is moved
         if(!StringCompare(curr_obj_name,gTimeLimit1_name) || 
            !StringCompare(curr_obj_name,gTimeLimit2_name))
           {
            //--- the time coordinate of vertical lines
            datetime time_limit1=0;
            datetime time_limit2=0;
            //--- find the first vertical line
            if(ObjectFind(0,gTimeLimit1_name)>-1)
               time_limit1=(datetime)ObjectGetInteger(0,gTimeLimit1_name,OBJPROP_TIME);
            //--- find the second vertical line
            if(ObjectFind(0,gTimeLimit2_name)>-1)
               time_limit2=(datetime)ObjectGetInteger(0,gTimeLimit2_name,OBJPROP_TIME);

            //--- if vertical lines are found
            if(time_limit1>0 && time_limit2>0)
               if(time_limit1<time_limit2)
                 {
                  //--- update properties of rectangles
                  datetime start_time=time_limit1;
                  datetime finish_time=time_limit2;
                  //---
                  if(RefreshRecPoints(start_time,finish_time))
                    {
                     //---
                     if(!ObjectMove(0,gRectLimit1_name,0,gRec1_time1,gRec1_pr1))
                       {
                        Print("Failed to move the 1st point!");
                        return;
                       }
                     if(!ObjectMove(0,gRectLimit1_name,1,gRec1_time2,gRec1_pr2))
                       {
                        Print("Failed to move the 2nd point!");
                        return;
                       }
                     //---
                     if(!ObjectMove(0,gRectLimit2_name,0,gRec2_time1,gRec2_pr1))
                       {
                        Print("Failed to move the 1st point!");
                        return;
                       }
                     if(!ObjectMove(0,gRectLimit2_name,1,gRec2_time2,gRec2_pr2))
                       {
                        Print("Failed to move the 2nd point!");
                        return;
                       }
                     //--- redraw chart
                     ChartRedraw();
                    }
                 }
           }
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
//| Функция получает значение ширины графика в пикселях.             |
//+------------------------------------------------------------------+
int ChartWidthInPixels(const long chart_ID=0)
  {
//--- prepare the variable to get the property value
   long result=-1;
//--- reset the error value
   ResetLastError();
//--- get the property value
   if(!ChartGetInteger(chart_ID,CHART_WIDTH_IN_PIXELS,0,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return((int)result);
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
//| Returns the height of chart in pixels                            |
//+------------------------------------------------------------------+
int ChartHeightInPixelsGet(const long chart_ID=0,const int sub_window=0)
  {
//--- prepare the variable to get the property value
   long result=-1;
//--- reset the error value
   ResetLastError();
//--- get the property value
   if(!ChartGetInteger(chart_ID,CHART_HEIGHT_IN_PIXELS,sub_window,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return((int)result);
  }
//+------------------------------------------------------------------+
//| Returns the value of the chart maximum in main window or in a    |
//| subwindow.                                                         |
//+------------------------------------------------------------------+
double ChartPriceMax(const long chart_ID=0,const int sub_window=0)
  {
//--- prepare the variable to get the result
   double result=EMPTY_VALUE;
//--- reset the error value
   ResetLastError();
//--- get the property value
   if(!ChartGetDouble(chart_ID,CHART_PRICE_MAX,sub_window,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return(result);
  }
//+------------------------------------------------------------------+
//| Returns the value of the chart minimum in main window or in a    |
//| subwindow.                                                         |
//+------------------------------------------------------------------+
double ChartPriceMin(const long chart_ID=0,const int sub_window=0)
  {
//--- prepare the variable to get the result
   double result=EMPTY_VALUE;
//--- reset the error value
   ResetLastError();
//--- get the property value
   if(!ChartGetDouble(chart_ID,CHART_PRICE_MIN,sub_window,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return(result);
  }
//+------------------------------------------------------------------+
//| Refreshes the anchor points for rectangles                       |
//+------------------------------------------------------------------+
bool RefreshRecPoints(const datetime _start_time,const datetime _finish_time)
  {
   int sub_window=0;
   int ch_width=ChartWidthInPixels();
   int ch_height=ChartHeightInPixelsGet();

//--- values of the first rectangle properties
//--- first anchor point
   if(!ChartXYToTimePrice(0,0,0,sub_window,gRec1_time1,gRec1_pr1))
      return false;
//--- second anchor point
   gRec1_time2=_start_time;
   gRec1_pr2=ChartPriceMin();

//--- values of the second rectangle properties
//--- first anchor point
   gRec2_time1=_finish_time;
   gRec2_pr1=gRec1_pr1;
//--- second anchor point
   if(!ChartXYToTimePrice(0,ch_width,ch_height,sub_window,gRec2_time2,gRec2_pr2))
      return false;

   return true;
  }
//+------------------------------------------------------------------+
