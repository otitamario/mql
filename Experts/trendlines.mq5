//+------------------------------------------------------------------+
//|                                                   TrendLines.mq5 |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
input color Resistance_Color=Red;
input ENUM_LINE_STYLE Resistance_Style;
input int Resistance_Width=1;
input color Support_Color=Red;
input ENUM_LINE_STYLE Support_Style;
input int Support_Width=1;
//--- handle of the iFractals indicator 
int Fractal;
ENUM_TIMEFRAMES per_fractal=PERIOD_M15;
ENUM_TIMEFRAMES per_menor=PERIOD_M1;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
//--- get handle of the iFractals indicator
   Fractal=iFractals(Symbol(),per_fractal);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0,"TL_Resistance");
   ObjectDelete(0,"TL_Support");
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//--- declaration of variables
   int n,UpperFractal_1,UpperFractal_2,LowerFractal_1,LowerFractal_2;
//--- declaration of arrays to write values of iFractal buffers
   double FractalDown[],FractalUp[];
   double UpFractal_1,UpFractal_2,LowFractal_1,LowFractal_2;
//--- first write values of Fractal buffers in arrays
//--- fill the buffer with data
   CopyBuffer(Fractal,0,TimeCurrent(),Bars(Symbol(),per_fractal),FractalUp);
   CopyBuffer(Fractal,1,TimeCurrent(),Bars(Symbol(),per_fractal),FractalDown);
//--- indexing as in timeseries
   ArraySetAsSeries(FractalUp,true);
   ArraySetAsSeries(FractalDown,true);
//--- then use for loop statement to search the first upper fractal
   for(n=0; n<Bars(Symbol(),per_fractal); n++)
     {
      //--- break the cycle is the value is not blank
      if(FractalUp[n]!=EMPTY_VALUE)
         break;
     }
//--- write price value of the first fractal in variable
   UpFractal_1=FractalUp[n];
//--- write the first fractal index in variable
   UpperFractal_1=n;
//--- search for the second upper fractal 
   for(n=UpperFractal_1+1; n<Bars(Symbol(),per_fractal); n++)
     {
      if(FractalUp[n]!=EMPTY_VALUE) //break the cycle is the value is not blank
         break;
     }
//--- write price value of the first fractal in variable
   UpFractal_2=FractalUp[n];
//--- write the first fractal index in variable
   UpperFractal_2=n;
//--- search for values of the lower fractals
//--- search for the first lower fractal
   for(n=0; n<Bars(Symbol(),per_fractal); n++)
     {
      //--- break the cycle if the value is not blank
      if(FractalDown[n]!=EMPTY_VALUE)
         break;
     }
//--- write price value of the first fractal in variable
   LowFractal_1=FractalDown[n];
//--- write the first fractal index in variable
   LowerFractal_1=n;
//--- search for the second lower fractal 
   for(n=LowerFractal_1+1; n<Bars(Symbol(),per_fractal); n++)
     {
      if(FractalDown[n]!=EMPTY_VALUE)
         break;
     }
//--- write price value of the second fractal in variable
   LowFractal_2=FractalDown[n];
//--- write the second fractal index in variable
   LowerFractal_2=n;
   
//--- Step 1. Determining extremum time value on a higher timeframe:    
//--- declaration of an array to store time of the corresponding bar index on a higher timeframe
   datetime UpFractalTime_1[],LowFractalTime_1[],UpFractalTime_2[],LowFractalTime_2[];
//--- determining fractal time on a higher timeframe
   CopyTime(Symbol(),per_fractal,UpperFractal_1,1,UpFractalTime_1);
   CopyTime(Symbol(),per_fractal,LowerFractal_1,1,LowFractalTime_1);
   CopyTime(Symbol(),per_fractal,UpperFractal_2,1,UpFractalTime_2);
   CopyTime(Symbol(),per_fractal,LowerFractal_2,1,LowFractalTime_2);

//--- Step 2. Determining time of the next day bar formation:
//--- determining time of the next day bar formation (stop point for CopyHigh(), CopyLow() and CopyTime())
   datetime UpFractalTime_1_15=UpFractalTime_1[0]+900;
   datetime UpFractalTime_2_15=UpFractalTime_2[0]+900;
   datetime LowFractalTime_1_15=LowFractalTime_1[0]+900;
   datetime LowFractalTime_2_15=LowFractalTime_2[0]+900;

//--- Step 3. Declaration of arrays to store price and time data about M1; filling these arrays:   
//--- declaration of arrays to store data about maximum and minimum price values
   double High_1_15[],Low_1_15[],High_2_15[],Low_2_15[];
//--- filling arrays with data using CopyHigh() and CopyLow()
   CopyHigh(Symbol(),per_menor,UpFractalTime_1[0],UpFractalTime_1_15,High_1_15);
   CopyHigh(Symbol(),per_menor,UpFractalTime_2[0],UpFractalTime_2_15,High_2_15);
   CopyLow(Symbol(),per_menor,LowFractalTime_1[0],LowFractalTime_1_15,Low_1_15);
   CopyLow(Symbol(),per_menor,LowFractalTime_2[0],LowFractalTime_2_15,Low_2_15);
//--- declare arrays to store time values which correspond to price extremum bar indexes  
   datetime High_1_15_time[],High_2_15_time[],Low_1_15_time[],Low_2_15_time[];
//--- filling arrays with data
   CopyTime(Symbol(),per_menor,UpFractalTime_1[0],UpFractalTime_1_15,High_1_15_time);
   CopyTime(Symbol(),per_menor,UpFractalTime_2[0],UpFractalTime_2_15,High_2_15_time);
   CopyTime(Symbol(),per_menor,LowFractalTime_1[0],LowFractalTime_1_15,Low_1_15_time);
   CopyTime(Symbol(),per_menor,LowFractalTime_2[0],LowFractalTime_2_15,Low_2_15_time);
   
//--- Step 4. Search for the lowest and the highest price values. Time values of corrected extremums:
//--- find the lowest and the highest price and time values using ArrayMaximum и ArrayMinimum
   int Max_M15_1=ArrayMaximum(High_1_15,0,15);
   int Max_M15_2=ArrayMaximum(High_2_15,0,15);
   int Min_M15_1=ArrayMinimum(Low_1_15,0,15);
   int Min_M15_2=ArrayMinimum(Low_2_15,0,15);
/*determine time values for the lowest and the highest extremums
   High_1_15[Max_M15_1],
   Low_1_15[Min_M15_1],
   High_2_15[Max_M15_2],
   Low_2_15[Min_M15_2].
   High_1_15_time[Max_M15_1],
   High_2_15_time[Max_M15_2],
   Low_1_15_time[Min_M15_1],
   Low_2_15_time[Min_M15_2].
   */
//--- create support line
   ObjectCreate(0,"TL_Support",OBJ_TREND,0,Low_2_15_time[Min_M15_2],Low_2_15[Min_M15_2],Low_1_15_time[Min_M15_1],Low_1_15[Min_M15_1]);
   ObjectSetInteger(0,"TL_Support",OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(0,"TL_Support",OBJPROP_COLOR,Support_Color);
   ObjectSetInteger(0,"TL_Support",OBJPROP_STYLE,Support_Style);
   ObjectSetInteger(0,"TL_Support",OBJPROP_WIDTH,Support_Width);
//--- create resistance line
   ObjectCreate(0,"TL_Resistance",OBJ_TREND,0,High_2_15_time[Max_M15_2],High_2_15[Max_M15_2],High_1_15_time[Max_M15_1],High_1_15[Max_M15_1]);
   ObjectSetInteger(0,"TL_Resistance",OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(0,"TL_Resistance",OBJPROP_COLOR,Resistance_Color);
   ObjectSetInteger(0,"TL_Resistance",OBJPROP_STYLE,Resistance_Style);
   ObjectSetInteger(0,"TL_Resistance",OBJPROP_WIDTH,Resistance_Width);
//--- redraw support line
//--- write values of support line temporal coordinates to variables
   datetime TL_TimeLow2=(datetime)ObjectGetInteger(0,"TL_Support",OBJPROP_TIME,0);
   datetime TL_TimeLow1=(datetime)ObjectGetInteger(0,"TL_Support",OBJPROP_TIME,1);
//--- if line coordinates do not coincide with current coordinates
   if(TL_TimeLow2!=Low_2_15_time[Min_M15_2] && TL_TimeLow1!=Low_1_15_time[Min_M15_1])
     {
      //--- remove the line
      ObjectDelete(0,"TL_Support");
     }
//--- redraw resistance line
//--- write values of resistance line time coordinates to variables
   datetime TL_TimeUp2=(datetime)ObjectGetInteger(0,"TL_Resistance",OBJPROP_TIME,0);
   datetime TL_TimeUp1=(datetime)ObjectGetInteger(0,"TL_Resistance",OBJPROP_TIME,1);
//--- if line coordinates do not coincide with current coordinates
   if(TL_TimeUp2!=High_2_15_time[Max_M15_2] && TL_TimeUp1!=High_1_15_time[Max_M15_1])
     {
      //--- remove the line
      ObjectDelete(0,"TL_Resistance");
     }
//--- control of bar load in history
//--- 1. determine number of bars on the specified time interval
   int High_M15_1=Bars(Symbol(),per_menor,UpFractalTime_1[0],UpFractalTime_1_15);
   int High_M15_2=Bars(Symbol(),per_menor,UpFractalTime_2[0],UpFractalTime_2_15);
   int Low_M15_1=Bars(Symbol(),per_menor,LowFractalTime_1[0],LowFractalTime_1_15);
   int Low_M15_2=Bars(Symbol(),per_menor,LowFractalTime_2[0],LowFractalTime_2_15);
//--- 2. condition in case that loaded history is not enough for correct line drawing
//--- if there is no at least one bar
   if(High_M15_1==0 || High_M15_2==0 || Low_M15_1==0 || Low_M15_2==0)
     {
      Alert("Not enough history for proper operation!");
     }

//--- getting trend line price parameters
   double Close[];
   CopyClose(Symbol(),per_menor,TimeCurrent(),10,Close);
//--- set order of the array indexing
   ArraySetAsSeries(Close,true);
//---
   datetime Close_time[];
   CopyTime(Symbol(),per_menor,TimeCurrent(),10,Close_time);
//--- set order of the array indexing
   ArraySetAsSeries(Close_time,true);
//---
   double Price_Support_H4=ObjectGetValueByTime(0,"TL_Support",Close_time[1]);
   double Price_Resistance_H4=ObjectGetValueByTime(0,"TL_Resistance",Close_time[1]);

//--- conditions for trend line breakthrough
   bool breakdown=(Close[1]<Price_Support_H4);
   bool breakup=(Close[1]>Price_Resistance_H4);

//--- sending push notification
   if(breakdown==true)
     {
      //--- send no more than once in every 4 hours
      int SleepMinutes=5;
      static int LastTime=0;
      if(TimeCurrent()>LastTime+SleepMinutes*60)
        {
         LastTime=(int)TimeCurrent();
         SendNotification(Symbol()+"Support line breakthrough");
        }
     }
   if(breakup==true)
     {
      //--- send no more than once in every 4 hours
      int SleepMinutes=5;
      static int LastTime=0;
      if(TimeCurrent()>LastTime+SleepMinutes*60)
        {
         LastTime=(int)TimeCurrent();
         SendNotification(Symbol()+"Resistance line breakthrough");
        }
     }
  }

