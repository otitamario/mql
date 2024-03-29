//+------------------------------------------------------------------+
//|                                              EventProcessor7.mq5 |
//|                                           Copyright 2014, denkir |
//|                           https://login.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, denkir"
#property link      "https://login.mql5.com/en/users/denkir"
#property version   "1.00"

//---
uint gLastTime;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
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
         //---
         break;
        }
      //--- 6
      case CHARTEVENT_CLICK:
        {
         comment+="6) mouse click on chart";
         //--- check the moment of creation
         uint lastTime=GetTickCount();
         if((lastTime-gLastTime)>250)
           {
            //--- objects counter 
            static uint sign_obj_cnt;
            string buy_sign_name="buy_sign_"+IntegerToString(sign_obj_cnt+1);
            //--- coordinates 
            int mouse_x=(int)lparam;
            int mouse_y=(int)dparam;
            //--- time and price
            datetime obj_time;
            double obj_price;
            int sub_window;
            //--- convert the X and Y coordinates to the time and price values
            if(ChartXYToTimePrice(0,mouse_x,mouse_y,sub_window,obj_time,obj_price))
              {
               //--- create object
               if(!ObjectCreate(0,buy_sign_name,OBJ_ARROW_BUY,0,obj_time,obj_price))
                 {
                  Print("Failed to create buy sign!");
                  return;
                 }
               //--- redraw chart
               ChartRedraw();
               //--- increment objects counter
               sign_obj_cnt++;
              }
           }
         //---
         break;
        }
      //--- 7
      case CHARTEVENT_OBJECT_CLICK:
        {
         comment+="7) mouse click on graphical object";
         //---
         string sign_name=sparam;

         //--- delete buy arrow
         if(ObjectDelete(0,sign_name))
           {
            //--- redraw chart
            ChartRedraw();
            //---
            static uint sign_obj_cnt;
            string sell_sign_name="sell_sign_"+IntegerToString(sign_obj_cnt+1);

            //--- coordinates 
            int mouse_x=(int)lparam;
            int mouse_y=(int)dparam;
            //--- time and price
            datetime obj_time;
            double obj_price;
            int sub_window;
            //--- convert the X and Y coordinates to the time and price values
            if(ChartXYToTimePrice(0,mouse_x,mouse_y,sub_window,obj_time,obj_price))
              {
               //--- create object
               if(!ObjectCreate(0,sell_sign_name,OBJ_ARROW_SELL,0,obj_time,obj_price))
                 {
                  Print("Failed to create sell sign!");
                  return;
                 }
               //--- store the moment of creation
               gLastTime=GetTickCount();
               //--- redraw chart
               ChartRedraw();
               //--- increment objects counter
               sign_obj_cnt++;
              }
           }
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
//| Enables/Disables displaying of price chart with shift            |
//| from the right border.                                           |
//+------------------------------------------------------------------+
bool ChartShiftSet(const bool value,const long chart_ID=0)
  {
//--- reset the error value
   ResetLastError();
//--- set the property value
   if(!ChartSetInteger(chart_ID,CHART_SHIFT,0,value))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }
//+------------------------------------------------------------------+
//| Sets the value of zeroth bar shift from the right border         |
//| of chart in percent (from 10% to 50%).    To disable shift,      |
//| set the value of the CHART_SHIFT property to                     |
//| true.                                                            |
//+------------------------------------------------------------------+
bool ChartShiftSizeSet(const double value,const long chart_ID=0)
  {
//--- reset the error value
   ResetLastError();
//--- set the property value
   if(!ChartSetDouble(chart_ID,CHART_SHIFT_SIZE,value))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
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
