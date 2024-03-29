//+------------------------------------------------------------------+
//|                                              EventProcessor9.mq5 |
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
//| Iputs                                                            |
//+------------------------------------------------------------------+
sinput string Info_trade="+===--Trade--====+";   // +===--Trade--====+
input double InpLot=0.02;                        // Lot
input int InpStopLoss=125;                       // Stop Loss
input int InpTakeProfit=250;                     // Take Profit
input int InpSlippage=50;                        // Slippage

//--- name of text field
string gEdit_name="Text_edit";
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- create the text field      
   if(ObjectCreate(0,gEdit_name,OBJ_EDIT,0,0,0))
      //--- set the initial text
      if(ObjectSetString(0,gEdit_name,OBJPROP_TEXT,"Text"))
         //--- set font
         if(ObjectSetInteger(0,gEdit_name,OBJPROP_FONTSIZE,14))
            //--- enable text editing
            if(ObjectSetInteger(0,gEdit_name,OBJPROP_READONLY,false))
               //--- set coordinates 
               if(ObjectSetInteger(0,gEdit_name,OBJPROP_XDISTANCE,50))
                  if(ObjectSetInteger(0,gEdit_name,OBJPROP_YDISTANCE,50))
                     //--- set dimensions
                     if(ObjectSetInteger(0,gEdit_name,OBJPROP_XSIZE,150))
                        if(ObjectSetInteger(0,gEdit_name,OBJPROP_YSIZE,50))
                           //--- set text color
                           if(ObjectSetInteger(0,gEdit_name,OBJPROP_COLOR,clrGray))
                              //--- set background color
                              if(ObjectSetInteger(0,gEdit_name,OBJPROP_BGCOLOR,clrWhite))
                                 //--- set object's accessibility
                                 if(ObjectSetInteger(0,gEdit_name,OBJPROP_SELECTABLE,false))
                                    //--- set text alignment
                                    if(ObjectSetInteger(0,gEdit_name,OBJPROP_ALIGN,ALIGN_CENTER))
                                      {
                                       //--- redraw chart
                                       ChartRedraw();
                                       //---
                                       return INIT_SUCCEEDED;
                                      }

//---
   return INIT_FAILED;
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(ObjectFind(0,gEdit_name)>-1)
      ObjectDelete(0,gEdit_name);
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
         //---
         break;
        }
      //--- 9
      case CHARTEVENT_OBJECT_ENDEDIT:
        {
         comment+="9) finish editing text in the text field";
         //---
         string curr_obj_name=sparam;
         //--- if specified text field is being edited
         if(!StringCompare(curr_obj_name,gEdit_name))
           {
            //--- get object description
            string obj_text=NULL;
            if(ObjectGetString(0,curr_obj_name,OBJPROP_TEXT,0,obj_text))
              {
               //--- check value
               if(!StringCompare(obj_text,"Buy",false))
                 {
                  if(TryToBuy())
                     //--- set text color
                     ObjectSetInteger(0,gEdit_name,OBJPROP_COLOR,clrBlue);
                 }
               else if(!StringCompare(obj_text,"Sell",false))
                 {
                  if(TryToSell())
                     //--- set text color
                     ObjectSetInteger(0,gEdit_name,OBJPROP_COLOR,clrRed);
                 }
               else
                 {
                  //--- set text color
                  ObjectSetInteger(0,gEdit_name,OBJPROP_COLOR,clrGray);
                 }
               //--- redraw chart
               ChartRedraw();
              }
           }
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
