

//+------------------------------------------------------------------+
//|                                         detect a doubleclick.mq4 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                        http://www.metaquotes.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "http://www.metaquotes.net"




//**************************************************************************************************************
//**************************************************************************************************************   

int init()
  {

   return(0);
  }
//**************************************************************************************************************
//**************************************************************************************************************

int deinit()
  {

   return(0);
  }
//**************************************************************************************************************
//**************************************************************************************************************

int start()
  {

   return(0);
  }
//**************************************************************************************************************
//**************************************************************************************************************

void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_OBJECT_CLICK) //custom defined Buttons for example
     {
      Print("l: "+lparam+"      d: "+dparam+"        s: "+sparam);

      return;
     }//end of: if(id == CHARTEVENT_OBJECT_CLICK) 

//********************************************************
//********************************************************

   if(id==CHARTEVENT_KEYDOWN) //keystrokes
     {
      Print("l: "+lparam+"      d: "+dparam+"        s: "+sparam);

      return;
     }//end of: if(id==CHARTEVENT_KEYDOWN)

//********************************************************
//********************************************************


   return;
  }//end of: void OnChartEvent(...)
