//+------------------------------------------------------------------+
//|                                              EventProcessor2.mq5 |
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
input ENUM_BOOL InpIsEventMouseMove=Yes;         // Process "Mouse move"?
//---
sinput string Info_trade="+===--Trade--====+";   // +===--Trade--====+
input double InpLot=0.02;                        // Lot
input int InpStopLoss=125;                       // Stop Loss
input int InpTakeProfit=250;                     // Take Profit
input int InpSlippage=50;                        // Slippage

//---
sinput string Info_chart="+===--Chart--====+";   // +===--Chart--====+
input double InpChartShiftSize=25.5;             // Chart shift size,%

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- mouse move
   bool is_mouse=false;
   if(InpIsEventMouseMove)
      is_mouse=true;
   ChartSetInteger(0,CHART_EVENT_MOUSE_MOVE,is_mouse);
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
         //--- if a mouse event is processed
         if(InpIsEventMouseMove)
           {
            long static last_mouse_x;

            //--- enable shift
            if(ChartShiftSet(true))
               //--- set shift size 
               if(ChartShiftSizeSet(InpChartShiftSize))
                 {
                  //--- chart width
                  int chart_width=ChartWidthInPixels();

                  //--- calculate X coordinate of shift border
                  int chart_shift_x=(int)(chart_width-chart_width*InpChartShiftSize/100.);

                  //--- border crossing condition
                  if(lparam>chart_shift_x && last_mouse_x<chart_shift_x)
                    {
                     int res=MessageBox("Yes: buy / No: sell","Trading operation",MB_YESNO);
                     //--- buy
                     if(res==IDYES)
                        TryToBuy();
                     //--- sell
                     else if(res==IDNO)
                        TryToSell();
                    }

                  //--- store mouse X coordinate
                  last_mouse_x=lparam;
                 }
           }

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
//| Returns the width of chart in pixels                             |
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
//| Try to buy by market                                             |
//+------------------------------------------------------------------+
bool TryToBuy(void)
  {
   bool is_done=false;
//---
   CTrade myTrade;
   MqlTick last_tick;
//--- get current prices
   if(SymbolInfoTick(_Symbol,last_tick))
     {
      myTrade.SetDeviationInPoints(InpSlippage);
      //--- prices
      double open_pr,sl_pr,tp_pr;
      open_pr=sl_pr=tp_pr=WRONG_VALUE;
      //---
      open_pr=NormalizeDouble(last_tick.ask,_Digits);
      sl_pr=NormalizeDouble(open_pr-_Point*InpStopLoss,_Digits);
      tp_pr=NormalizeDouble(open_pr+_Point*InpTakeProfit,_Digits);

      //--- buy by market
      is_done=myTrade.Buy(InpLot,_Symbol,open_pr,sl_pr,tp_pr);
     }
//---
   return is_done;
  }
//+------------------------------------------------------------------+
//| Try to sell by market                                            |
//+------------------------------------------------------------------+
bool TryToSell(void)
  {
   bool is_done=false;
//---
   CTrade myTrade;
   MqlTick last_tick;
//--- get current prices
   if(SymbolInfoTick(_Symbol,last_tick))
     {
      myTrade.SetDeviationInPoints(InpSlippage);
      //--- prices
      double open_pr,sl_pr,tp_pr;
      open_pr=sl_pr=tp_pr=WRONG_VALUE;
      //---
      open_pr=NormalizeDouble(last_tick.bid,_Digits);
      sl_pr=NormalizeDouble(open_pr+_Point*InpStopLoss,_Digits);
      tp_pr=NormalizeDouble(open_pr-_Point*InpTakeProfit,_Digits);

      //--- sell by market
      is_done=myTrade.Sell(InpLot,_Symbol,open_pr,sl_pr,tp_pr);
     }
//---
   return is_done;
  }
//+------------------------------------------------------------------+
