#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

void fObjTrend(   string  aObjName,
                  datetime aTime_1,
                  double   aPrice_1,
                  datetime aTime_2,
                  double   aPrice_2,
                  color    aColor      =  clrRed, 
                  int      aWindow     =  0
               ){
   
   if(ObjectFind(0,aObjName)==-1){  
      ObjectCreate(0,aObjName,OBJ_TREND,aWindow,aTime_1,aPrice_1,aTime_2,aPrice_2);
   }
   
   ObjectMove(0,aObjName,0,aTime_1,aPrice_1);
   ObjectMove(0,aObjName,1,aTime_2,aPrice_2);     
   ObjectSetInteger(0,aObjName,OBJPROP_BACK,true);
   ObjectSetInteger(0,aObjName,OBJPROP_COLOR,aColor);
   ObjectSetInteger(0,aObjName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,aObjName,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,aObjName,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);
   ObjectSetString(0,aObjName,OBJPROP_TEXT,"");
   ObjectSetInteger(0,aObjName,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,aObjName,OBJPROP_STYLE,0);
   ObjectSetInteger(0,aObjName,OBJPROP_RAY_LEFT,false);   
   ObjectSetInteger(0,aObjName,OBJPROP_RAY_RIGHT,false);

}

void fObjArrow(   string            aObjName,
                  datetime          aTime,
                  double            aPrice,
                  uchar             aCode,
                  color             aColor, 
                  ENUM_ANCHOR_POINT aAnchor
               ){
               
   if(ObjectFind(0,aObjName)==-1){                 
      ObjectCreate(0,aObjName,OBJ_TEXT,0,aTime,aPrice);
   }
   ObjectMove(0,aObjName,0,aTime,aPrice);    
   ObjectSetInteger(0,aObjName,OBJPROP_COLOR,aColor);   
   ObjectSetString(0,aObjName,OBJPROP_TEXT,CharToString(aCode));
   ObjectSetString(0,aObjName,OBJPROP_FONT,"Wingdings");    
   ObjectSetInteger(0,aObjName,OBJPROP_FONTSIZE,8);  
   ObjectSetInteger(0,aObjName,OBJPROP_ANCHOR,aAnchor);     
   ObjectSetInteger(0,aObjName,OBJPROP_BACK,false);
   ObjectSetInteger(0,aObjName,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,aObjName,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,aObjName,OBJPROP_TIMEFRAMES,OBJ_ALL_PERIODS);

}