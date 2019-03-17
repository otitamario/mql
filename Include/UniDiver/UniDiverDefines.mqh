#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

enum EExtrType{
   ExtrBars,
   ExtrThreshold,
   ExtrMiddle
};

struct SExtremum{
   int SignalBar;
   int ExtremumBar;
   datetime ExtremumTime;
   double IndicatorValue;
   double PriceValue;
};

struct SPseudoBuffers1{
   int UpperCnt;
   int LowerCnt;
   void Reset(){
      UpperCnt=0;
      LowerCnt=0;  
   }   
};

struct SPseudoBuffers2{
   int UpperCnt;
   int LowerCnt;
   double MinMaxVal;
   int MinMaxBar;   
   int Trend;
   void Reset(){
      UpperCnt=0;
      LowerCnt=0;  
      MinMaxVal=0;
      MinMaxBar=0;
      Trend=1;
   }   
};

enum EAlerts{
   Alerts_off=0,
   Alerts_Bar0=1,
   Alerts_Bar1=2
};