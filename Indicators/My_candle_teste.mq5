//+------------------------------------------------------------------+
//|                                         Candlestick Patterns.mq5 |
//|                                                         VDV Soft |
//|                                                 vdv_2001@mail.ru |
//+------------------------------------------------------------------+
#property copyright "VDV Soft"
#property link      "vdv_2001@mail.ru"
#property version   "1.00"

#include <candlesticktype.mqh>

#property indicator_chart_window

#property indicator_label1  "Venda"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Compra"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1



//--- plot 3
#property indicator_label3  ""
#property indicator_type3   DRAW_LINE
#property indicator_color3  Blue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
#property indicator_buffers 7
#property indicator_plots   3


//--- input parameters
input int   InpPeriodSMA   =12;         // Period of averaging
input bool  InpAlert       =true;       // Enable. signal
input int   InpCountBars   =1000;       // Amount of bars for calculation
input color InpColorBull   =DodgerBlue; // Color of bullish models
input color InpColorBear   =Tomato;     // Color of bearish models
input bool  InpCommentOn   =true;       // Enable comment
input int   InpTextFontSize=10;         // Font size
//---- indicator buffers
//--- indicator handles
//--- list global variable
string prefix="Patterns ";
datetime CurTime=0;
double  VendaBuffer[];
double  CompraBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);

   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);

   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);

   return(INIT_SUCCEEDED);

  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

//--- We wait for a new bar
   if(rates_total==prev_calculated)
     {
      return(rates_total);
     }

////--- delete object
   string objname,comment;
//   for(int i=ObjectsTotal(0,0,-1)-1;i>=0;i--)
//     {
//      objname=ObjectName(0,i);
//      if(StringFind(objname,prefix)==-1)
//         continue;
//      else
//         ObjectDelete(0,objname);
//     }
   int objcount=0;
//---
   int limit;
   if(prev_calculated==0)
     {
      if(InpCountBars<=0 || InpCountBars>=rates_total)
         limit=InpPeriodSMA*2;
      else
         limit=rates_total-InpCountBars;
     }
   else
      limit=prev_calculated-1;
   if(!SeriesInfoInteger(Symbol(),0,SERIES_SYNCHRONIZED))
      return(0);
// Variable of time when the signal should be given
   CurTime=time[rates_total-2];
// Determine the market (forex or not)

   bool _forex=false;
   if(SymbolInfoInteger(Symbol(),SYMBOL_TRADE_CALC_MODE)==(int)SYMBOL_CALC_MODE_FOREX) _forex=true;
   bool _language=(TerminalInfoString(TERMINAL_LANGUAGE)=="Russian") ? true : false; // Russian language of the terminal
//--- calculate Candlestick Patterns
   for(int i=limit;i<rates_total-1;i++)
     {

      CANDLE_STRUCTURE cand1;
      if(!RecognizeCandle(_Symbol,_Period,time[i],InpPeriodSMA,cand1))
         continue;
/* Check patterns on one candlestick */

      //------      
      // Inverted Hammer, the bullish model
      if(cand1.trend==DOWN && // check direction of trend
         cand1.type==CAND_INVERT_HAMMER) // the "Inverted Hammer" check
        {
         CompraBuffer[i]=low[i];
         VendaBuffer[i]=EMPTY_VALUE;

         comment=_language?"Inverted Hammer (Bull)":"Inverted Hammer";
         DrawSignal(prefix+"Invert Hammer the bull model"+string(objcount++),cand1,InpColorBull,comment);
        }

      // Hanging Man, the bearish model
      if(cand1.trend==UPPER && // check direction of trend
         cand1.type==CAND_HAMMER) // the "Hammer" check
        {
         VendaBuffer[i]=high[i];
         CompraBuffer[i]=EMPTY_VALUE;

         comment=_language?"Hanging Man (Bear)":"Hanging Man";
         DrawSignal(prefix+"Hanging Man the bear model"+string(objcount++),cand1,InpColorBear,comment);
        }
      //------      
      // Hammer, the bullish model
      if(cand1.trend==DOWN && // check direction of trend
         cand1.type==CAND_HAMMER) // the "Hammer" check
        {
         CompraBuffer[i]=low[i];
         VendaBuffer[i]=EMPTY_VALUE;

         comment=_language?"Hammer (Bull)":"Hammer";
         DrawSignal(prefix+"Hammer, the bull model"+string(objcount++),cand1,InpColorBull,comment);
        }

/* Check of patters with two candlesticks */

      CANDLE_STRUCTURE cand2;
      cand2=cand1;
      if(!RecognizeCandle(_Symbol,_Period,time[i-1],InpPeriodSMA,cand1))
         continue;

      // Engulfing, the bullish model
      if(cand1.trend==DOWN && !cand1.bull && cand2.trend==DOWN && cand2.bull && // check direction of trend and direction of candlestick
         cand1.bodysize<cand2.bodysize) // body of the third candlestick is bigger than that of the second one
        {
         CompraBuffer[i]=low[i];
         VendaBuffer[i]=EMPTY_VALUE;

         comment=_language?"Engulfing (Bull)":"Engulfing";
         if(_forex)// if it's forex
           {
            if(cand1.close>=cand2.open && cand1.open<cand2.close) // body of the first candlestick is inside of body of the second one
              {
               DrawSignal(prefix+"Engulfing the bull model"+string(objcount++),cand1,cand2,InpColorBull,comment);
              }
           }
         else
           {
            if(cand1.close>cand2.open && cand1.open<cand2.close) // body of the first candlestick inside of body of the second candlestick
              {
               DrawSignal(prefix+"Engulfing the bull model"+string(objcount++),cand1,cand2,InpColorBull,comment);
              }
           }
        }
      // Engulfing, the bearish model
      if(cand1.trend==UPPER && cand1.bull && cand2.trend==UPPER && !cand2.bull && // check direction and direction of candlestick
         cand1.bodysize<cand2.bodysize) // body of the third candlestick is bigger than that of the second one
        {
         VendaBuffer[i]=high[i];
         CompraBuffer[i]=EMPTY_VALUE;
         comment=_language?"Engulfing (Bear)":"Engulfing";
         if(_forex)// if it's forex
           {
            if(cand1.close<=cand2.open && cand1.open>cand2.close) // body of the first candlestick is inside of body of the second one
              {
               DrawSignal(prefix+"Engulfing the bear model"+string(objcount++),cand1,cand2,InpColorBear,comment);
              }
           }
         else
           {
            if(cand1.close<cand2.open && cand1.open>cand2.close) // close 1 is lower or equal to open 2; or open 1 is higher or equal to close 2
              {
               DrawSignal(prefix+"Engulfing the bear model"+string(objcount++),cand1,cand2,InpColorBear,comment);
              }
           }
        }
      //------      

     } // end of cycle of checks
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----
   string objname;
   for(int i=ObjectsTotal(0,0,-1)-1;i>=0;i--)
     {
      objname=ObjectName(0,i);
      if(StringFind(objname,prefix)==-1)
         continue;
      else
         ObjectDelete(0,objname);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSignal(string objname,CANDLE_STRUCTURE &cand,color Col,string comment)
  {
   string objtext=objname+"text";
   if(ObjectFind(0,objtext)>=0) ObjectDelete(0,objtext);
   if(ObjectFind(0,objname)>=0) ObjectDelete(0,objname);

   if(InpAlert && cand.time>=CurTime)
     {
      Alert(Symbol()," ",PeriodToString(_Period)," ",comment);
     }
   if(Col==InpColorBull)
     {
      ObjectCreate(0,objname,OBJ_ARROW_BUY,0,cand.time,cand.low);
      ObjectSetInteger(0,objname,OBJPROP_ANCHOR,ANCHOR_TOP);
      if(InpCommentOn)
        {
         ObjectCreate(0,objtext,OBJ_TEXT,0,cand.time,cand.low);
         ObjectSetInteger(0,objtext,OBJPROP_ANCHOR,ANCHOR_LEFT);
         ObjectSetDouble(0,objtext,OBJPROP_ANGLE,-90);
        }
     }
   else
     {
      ObjectCreate(0,objname,OBJ_ARROW_SELL,0,cand.time,cand.high);
      ObjectSetInteger(0,objname,OBJPROP_ANCHOR,ANCHOR_BOTTOM);
      if(InpCommentOn)
        {
         ObjectCreate(0,objtext,OBJ_TEXT,0,cand.time,cand.high);
         ObjectSetInteger(0,objtext,OBJPROP_ANCHOR,ANCHOR_LEFT);
         ObjectSetDouble(0,objtext,OBJPROP_ANGLE,90);
        }
     }
   ObjectSetInteger(0,objname,OBJPROP_COLOR,Col);
   ObjectSetInteger(0,objname,OBJPROP_BACK,false);
   ObjectSetString(0,objname,OBJPROP_TEXT,comment);
   if(InpCommentOn)
     {
      ObjectSetInteger(0,objtext,OBJPROP_COLOR,Col);
      ObjectSetString(0,objtext,OBJPROP_FONT,"Tahoma");
      ObjectSetInteger(0,objtext,OBJPROP_FONTSIZE,InpTextFontSize);
      ObjectSetString(0,objtext,OBJPROP_TEXT,"    "+comment);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSignal(string objname,CANDLE_STRUCTURE &cand1,CANDLE_STRUCTURE &cand2,color Col,string comment)
  {
   string objtext=objname+"text";
   double price_low=MathMin(cand1.low,cand2.low);
   double price_high=MathMax(cand1.high,cand2.high);

   if(ObjectFind(0,objtext)>=0) ObjectDelete(0,objtext);
   if(ObjectFind(0,objname)>=0) ObjectDelete(0,objname);
   if(InpAlert && cand2.time>=CurTime)
     {
      Alert(Symbol()," ",PeriodToString(_Period)," ",comment);
     }

   ObjectCreate(0,objname,OBJ_RECTANGLE,0,cand1.time,price_low,cand2.time,price_high);
   if(Col==InpColorBull)
     {
      if(InpCommentOn)
        {
         ObjectCreate(0,objtext,OBJ_TEXT,0,cand1.time,price_low);
         ObjectSetInteger(0,objtext,OBJPROP_ANCHOR,ANCHOR_LEFT);
         ObjectSetDouble(0,objtext,OBJPROP_ANGLE,-90);
        }
     }
   else
     {
      if(InpCommentOn)
        {
         ObjectCreate(0,objtext,OBJ_TEXT,0,cand1.time,price_high);
         ObjectSetInteger(0,objtext,OBJPROP_ANCHOR,ANCHOR_LEFT);
         ObjectSetDouble(0,objtext,OBJPROP_ANGLE,90);
        }
     }
   ObjectSetInteger(0,objname,OBJPROP_COLOR,Col);
   ObjectSetInteger(0,objname,OBJPROP_BACK,false);
   ObjectSetString(0,objname,OBJPROP_TEXT,comment);
   if(InpCommentOn)
     {
      ObjectSetInteger(0,objtext,OBJPROP_COLOR,Col);
      ObjectSetString(0,objtext,OBJPROP_FONT,"Tahoma");
      ObjectSetInteger(0,objtext,OBJPROP_FONTSIZE,InpTextFontSize);
      ObjectSetString(0,objtext,OBJPROP_TEXT,"    "+comment);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawSignal(string objname,CANDLE_STRUCTURE &cand1,CANDLE_STRUCTURE &cand2,CANDLE_STRUCTURE &cand3,color Col,string comment)
  {
   string objtext=objname+"text";
   double price_low=MathMin(cand1.low,MathMin(cand2.low,cand3.low));
   double price_high=MathMax(cand1.high,MathMax(cand2.high,cand3.high));

   if(ObjectFind(0,objtext)>=0) ObjectDelete(0,objtext);
   if(ObjectFind(0,objname)>=0) ObjectDelete(0,objname);
   if(InpAlert && cand3.time>=CurTime)
     {
      Alert(Symbol()," ",PeriodToString(_Period)," ",comment);
     }
   ObjectCreate(0,objname,OBJ_RECTANGLE,0,cand1.time,price_low,cand3.time,price_high);
   if(Col==InpColorBull)
     {
      if(InpCommentOn)
        {
         ObjectCreate(0,objtext,OBJ_TEXT,0,cand3.time,price_low);
         ObjectSetInteger(0,objtext,OBJPROP_ANCHOR,ANCHOR_LEFT);
         ObjectSetDouble(0,objtext,OBJPROP_ANGLE,-90);
        }
     }
   else
     {
      if(InpCommentOn)
        {
         ObjectCreate(0,objtext,OBJ_TEXT,0,cand3.time,price_high);
         ObjectSetInteger(0,objtext,OBJPROP_ANCHOR,ANCHOR_LEFT);
         ObjectSetDouble(0,objtext,OBJPROP_ANGLE,90);
        }
     }
   ObjectSetInteger(0,objname,OBJPROP_COLOR,Col);
   ObjectSetInteger(0,objname,OBJPROP_BACK,false);
   ObjectSetInteger(0,objname,OBJPROP_WIDTH,2);
   ObjectSetString(0,objname,OBJPROP_TEXT,comment);
   if(InpCommentOn)
     {
      ObjectSetInteger(0,objtext,OBJPROP_COLOR,Col);
      ObjectSetString(0,objtext,OBJPROP_FONT,"Tahoma");
      ObjectSetInteger(0,objtext,OBJPROP_FONTSIZE,InpTextFontSize);
      ObjectSetString(0,objtext,OBJPROP_TEXT,"    "+comment);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string PeriodToString(ENUM_TIMEFRAMES period)
  {
   switch(period)
     {
      case PERIOD_M1: return("M1");
      case PERIOD_M2: return("M2");
      case PERIOD_M3: return("M3");
      case PERIOD_M4: return("M4");
      case PERIOD_M5: return("M5");
      case PERIOD_M6: return("M6");
      case PERIOD_M10: return("M10");
      case PERIOD_M12: return("M12");
      case PERIOD_M15: return("M15");
      case PERIOD_M20: return("M20");
      case PERIOD_M30: return("M30");
      case PERIOD_H1: return("H1");
      case PERIOD_H2: return("H2");
      case PERIOD_H3: return("H3");
      case PERIOD_H4: return("H4");
      case PERIOD_H6: return("H6");
      case PERIOD_H8: return("H8");
      case PERIOD_H12: return("H12");
      case PERIOD_D1: return("D1");
      case PERIOD_W1: return("W1");
      case PERIOD_MN1: return("MN1");
     }
   return(NULL);
  };
//+------------------------------------------------------------------+
