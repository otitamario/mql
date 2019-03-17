//+------------------------------------------------------------------+
//|                                                        Price.mqh |
//|                                           Copyright 2016, melnik |
//|                             https://www.mql5.com/ru/users/melnik |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, melnik"
#property link      "https://www.mql5.com/ru/users/melnik"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CPrice
  {
private:

public:
                     CPrice();
                    ~CPrice();
   double            Open(int i=0);
   double            Open(string symbol,ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0);
   double            Open(ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0);
   double            Close(int i=0);
   double            Close(string symbol,ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0);
   double            Close(ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0);
   double            High(int i=0);
   double            High(string symbol,ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0);
   double            High(ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0);
   double            Low(int i=0);
   double            Low(string symbol,ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0);
   double            Low(ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0);
   datetime          Time(int i=0);
   datetime          Time(string symbol,ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0);
   datetime          Time(ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0);
   double            Bid(){MqlTick _tick; SymbolInfoTick(_Symbol, _tick); return NormalizeDouble(_tick.bid, _Digits);}
   double            Ask(){MqlTick _tick; SymbolInfoTick(_Symbol, _tick); return NormalizeDouble(_tick.ask, _Digits);}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPrice::CPrice()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CPrice::~CPrice()
  {
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
double CPrice::High(int i=0)
  {
   double _high[];
   ArraySetAsSeries(_high,true);
   if(CopyHigh(_Symbol,_Period,0,i+1,_high)==-1)
      printf("Can't copy highs price");
   return NormalizeDouble(_high[i], _Digits);
  }
//+------------------------------------------------------------------+
double CPrice::High(string symbol,ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0)
  {
   double _high[];
   ArraySetAsSeries(_high,true);
   if(CopyHigh(symbol,period,0,shift+1,_high)==-1)
      printf("Can't copy highs price");
   return NormalizeDouble(_high[shift], _Digits);
  }
//+------------------------------------------------------------------+
double CPrice::High(ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0)
  {
   double _high[];
   ArraySetAsSeries(_high,true);
   if(CopyHigh(_Symbol,period,0,shift+1,_high)==-1)
      printf("Can't copy highs price");
   return NormalizeDouble(_high[shift], _Digits);
  }
//+------------------------------------------------------------------+
double CPrice::Low(int i=0)
  {
   double _low[];
   ArraySetAsSeries(_low,true);
   if(CopyLow(_Symbol,_Period,0,i+1,_low)==-1)
      printf("Can't copy low price");
   return NormalizeDouble(_low[i], _Digits);
  }
//+------------------------------------------------------------------+
double CPrice::Low(string symbol,ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0)
  {
   double _low[];
   ArraySetAsSeries(_low,true);
   if(CopyLow(symbol,period,0,shift+1,_low)==-1)
      printf("Can't copy low price");
   return NormalizeDouble(_low[shift], _Digits);
  }
//+------------------------------------------------------------------+
double CPrice::Low(ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0)
  {
   double _low[];
   ArraySetAsSeries(_low,true);
   if(CopyLow(_Symbol,period,0,shift+1,_low)==-1)
      printf("Can't copy low price");
   return NormalizeDouble(_low[shift], _Digits);
  }
//+------------------------------------------------------------------+
double CPrice::Open(int i=0)
  {
   double _open[];
   ArraySetAsSeries(_open,true);
   if(CopyOpen(_Symbol,_Period,0,i+1,_open)==-1)
      printf("Can't copy low price");
   return NormalizeDouble(_open[i], _Digits);
  }
//+------------------------------------------------------------------+
double CPrice::Open(string symbol,ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0)
  {
   double _open[];
   ArraySetAsSeries(_open,true);
   if(CopyOpen(symbol,period,0,shift+1,_open)==-1)
      printf("Can't copy low price");
   return NormalizeDouble(_open[shift], _Digits);
  }
//+------------------------------------------------------------------+
double CPrice::Open(ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0)
  {
   double _open[];
   ArraySetAsSeries(_open,true);
   if(CopyOpen(_Symbol,period,0,shift+1,_open)==-1)
      printf("Can't copy low price");
   return NormalizeDouble(_open[shift], _Digits);
  }
//+------------------------------------------------------------------+
double CPrice::Close(int i=0)
  {
   double _close[];
   ArraySetAsSeries(_close,true);
   if(CopyClose(_Symbol,_Period,0,i+1,_close)==-1)
      printf("Can't copy low price");
   return NormalizeDouble(_close[i], _Digits);
  }
//+------------------------------------------------------------------+
double CPrice::Close(string symbol,ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0)
  {
   double _close[];
   ArraySetAsSeries(_close,true);
   if(CopyClose(symbol,period,0,shift+1,_close)==-1)
      printf("Can't copy low price");
   return NormalizeDouble(_close[shift], _Digits);
  }
//+------------------------------------------------------------------+
double CPrice::Close(ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0)
  {
   double _close[];
   ArraySetAsSeries(_close,true);
   if(CopyClose(_Symbol,period,0,shift+1,_close)==-1)
      printf("Can't copy low price");
   return NormalizeDouble(_close[shift], _Digits);
  }
//+------------------------------------------------------------------+
datetime CPrice::Time(int i=0)
  {
   datetime _time[];
   ArraySetAsSeries(_time,true);
   if(CopyTime(_Symbol,_Period,0,i+1,_time)==-1)
      printf("Can't copy time open");
   return _time[i];
  }
//+------------------------------------------------------------------+
datetime CPrice::Time(string symbol,ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0)
  {
   datetime _time[];
   ArraySetAsSeries(_time,true);
   if(CopyTime(symbol,period,0,shift+1,_time)==-1)
      printf("Can't copy time open");
   return _time[shift];
  }
//+------------------------------------------------------------------+
datetime CPrice::Time(ENUM_TIMEFRAMES period=PERIOD_CURRENT,int shift=0)
  {
   datetime _time[];
   ArraySetAsSeries(_time,true);
   if(CopyTime(_Symbol,period,0,shift+1,_time)==-1)
      printf("Can't copy time open");
   return _time[shift];
  }
//+------------------------------------------------------------------+
