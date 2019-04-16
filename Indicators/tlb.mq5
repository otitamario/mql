//+------------------------------------------------------------------+
//|                                                          TLB.mq5 |
//|                                            Copyright 2012, Rone. |
//|                                            rone.sergey@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, Rone."
#property link      "rone.sergey@gmail.com"
#property version   "1.00"
#property description "Chart of (three)linear breakthrough."
//---
#property indicator_separate_window
#property indicator_buffers 7
#property indicator_plots   1
//--- plot Lb
#property indicator_label1  "Line Break"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrRed,clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int      InpLines = 3;  // Number of lines
//--- indicator buffers
double         LbBuffer1[];
double         LbBuffer2[];
double         LbBuffer3[];
double         LbBuffer4[];
double         LbColors[];
double         LbMax[];
double         LbMin[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {
//--- indicator buffers mapping
   SetIndexBuffer(0, LbBuffer1, INDICATOR_DATA);
   SetIndexBuffer(1, LbBuffer2, INDICATOR_DATA);
   SetIndexBuffer(2, LbBuffer3, INDICATOR_DATA);
   SetIndexBuffer(3, LbBuffer4, INDICATOR_DATA);
   SetIndexBuffer(4, LbColors, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5, LbMax, INDICATOR_CALCULATIONS);
   SetIndexBuffer(6, LbMin, INDICATOR_CALCULATIONS);
//---
   IndicatorSetInteger(INDICATOR_LEVELS, 1);
   IndicatorSetInteger(INDICATOR_LEVELCOLOR, clrGray);
   IndicatorSetInteger(INDICATOR_LEVELSTYLE, STYLE_SOLID);
//---
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
//---
   IndicatorSetString(INDICATOR_SHORTNAME, (string)InpLines+" Line Break");
//---
   return(0);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double getLinePrice(int line, int &lineShift, bool up=true) {
//---
   double price;
//---
   if ( up ) {
      price = LbMax[lineShift];
      for ( int i = 1; i < line; i++ ) {
         if ( LbMax[lineShift-i] > price ) {
            price = LbMax[lineShift-i];
         }
      }
   } else {
      price = LbMin[lineShift];
      for ( int i = 1; i < line; i++ ) {
         if ( LbMin[lineShift-i] < price ) {
            price = LbMin[lineShift-i];
         }
      }
   }
//---
   return(price);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void processPrice(double price, int i, int &lineShift) {
//---
   if ( price > LbMax[i-1] ) {
      LbMax[i] = price;
      LbMin[i] = LbMax[i-1];
      lineShift += 1;
   } else if ( price < LbMin[i-1] ) {
      LbMin[i] = price;
      LbMax[i] = LbMin[i-1];
      lineShift += 1;
   }   
//---
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
{
//---
   int barShift = 1;
   int lineShift = 0;
//---
   for ( ; price[0] == price[barShift]; barShift++);
   
   if ( price[0] > price[barShift] ) {
      LbMax[0] = price[0];
      LbMin[0] = price[barShift];
   } else {
      LbMax[0] = price[barShift];
      LbMin[0] = price[0];
   }
//---
   //lbBuffShift = 0;
   for ( int i = 1; i < InpLines; i++ ) {
      for ( ; price[barShift] <= getLinePrice(i, lineShift) && price[barShift] >= getLinePrice(i, lineShift, false); barShift++ );
      
      processPrice(price[barShift], i, lineShift);
   }
//---
   for ( int i = InpLines; i < rates_total; i++ ) {
      for ( ; barShift < rates_total && price[barShift] <= getLinePrice(InpLines, lineShift) && 
         price[barShift] >= getLinePrice(InpLines, lineShift, false); barShift++ );
      
      if ( barShift < rates_total ) {
         processPrice(price[barShift], i, lineShift);
      }
   }
//---
   for ( int i = 1; i <= lineShift; i++ ) {
      int bar = rates_total - lineShift - 1 + i;
      //---
      if ( LbMax[i] > LbMax[i-1] ) {
         LbBuffer4[bar] = LbBuffer2[bar] = LbMax[i];
         LbBuffer1[bar] = LbBuffer3[bar] = LbMin[i];
         LbColors[bar] = 1;
      }
      if ( LbMax[i] < LbMax[i-1] ) {
         LbBuffer4[bar] = LbBuffer2[bar] = LbMin[i];
         LbBuffer1[bar] = LbBuffer3[bar] = LbMax[i];
         LbColors[bar] = 0;
      }
   }
//---
   IndicatorSetDouble(INDICATOR_LEVELVALUE, 0, price[rates_total-1]);
//--- return value of prev_calculated for next call
   return(rates_total);
}
//+------------------------------------------------------------------+
