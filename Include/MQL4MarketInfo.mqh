//+------------------------------------------------------------------+
//|                                               MQL4MarketInfo.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+

#ifndef _MQL4_MARKET_INFO_INCLUDED
#define _MQL4_MARKET_INFO_INCLUDED

#define MODE_OPEN 0
#define MODE_LOW 1
#define MODE_HIGH 2
#define MODE_CLOSE 3
#define MODE_VOLUME 4 
#define MODE_TIME 5
#define MODE_BID 9
#define MODE_ASK 10
#define MODE_POINT 11
#define MODE_DIGITS 12
#define MODE_SPREAD 13
#define MODE_STOPLEVEL 14
#define MODE_LOTSIZE 15
#define MODE_TICKVALUE 16
#define MODE_TICKSIZE 17
#define MODE_SWAPLONG 18
#define MODE_SWAPSHORT 19
#define MODE_STARTING 20
#define MODE_EXPIRATION 21
#define MODE_TRADEALLOWED 22
#define MODE_MINLOT 23
#define MODE_LOTSTEP 24
#define MODE_MAXLOT 25
#define MODE_MARGINCALCMODE 28
#define MODE_MARGININIT 29
#define MODE_MARGINMAINTENANCE 30
#define MODE_MARGINHEDGED 31
#define MODE_MARGINREQUIRED 32
#define MODE_FREEZELEVEL 33

//---
ENUM_TIMEFRAMES TFMigrate(int tf)
{
   switch(tf)
     {
      case 0: return(PERIOD_CURRENT);
      case 1: return(PERIOD_M1);
      case 5: return(PERIOD_M5);
      case 15: return(PERIOD_M15);
      case 30: return(PERIOD_M30);
      case 60: return(PERIOD_H1);
      case 240: return(PERIOD_H4);
      case 1440: return(PERIOD_D1);
      case 10080: return(PERIOD_W1);
      case 43200: return(PERIOD_MN1);
      
      case 2: return(PERIOD_M2);
      case 3: return(PERIOD_M3);
      case 4: return(PERIOD_M4);      
      case 6: return(PERIOD_M6);
      case 10: return(PERIOD_M10);
      case 12: return(PERIOD_M12);
      case 16385: return(PERIOD_H1);
      case 16386: return(PERIOD_H2);
      case 16387: return(PERIOD_H3);
      case 16388: return(PERIOD_H4);
      case 16390: return(PERIOD_H6);
      case 16392: return(PERIOD_H8);
      case 16396: return(PERIOD_H12);
      case 16408: return(PERIOD_D1);
      case 32769: return(PERIOD_W1);
      case 49153: return(PERIOD_MN1);      
      default: return(PERIOD_CURRENT);
     }
}

//-- For a Symbol
double BidCurrent(string symbol)
{
    MqlTick last_tick;
    SymbolInfoTick(symbol,last_tick);
    return last_tick.bid;
}

double AskCurrent(string symbol)
{
    MqlTick last_tick;
    SymbolInfoTick(symbol,last_tick);
    return last_tick.ask;
}

//---Current symbol
double BidCurrent()
{
    MqlTick last_tick;
    SymbolInfoTick(_Symbol,last_tick);
    return last_tick.bid;
}

double AskCurrent()
{
    MqlTick last_tick;
    SymbolInfoTick(_Symbol,last_tick);
    return last_tick.ask;
}

double MarketInfo(string symbol,
                  int type)

{
   switch(type)
     {
      case MODE_LOW:
         return(SymbolInfoDouble(symbol,SYMBOL_LASTLOW));
      case MODE_HIGH:
         return(SymbolInfoDouble(symbol,SYMBOL_LASTHIGH));
      case MODE_BID:
         return(BidCurrent(symbol));
      case MODE_ASK:
         return(AskCurrent(symbol));
      case MODE_POINT:
         return(SymbolInfoDouble(symbol,SYMBOL_POINT));
      case MODE_DIGITS:
         return((double)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
      case MODE_SPREAD:
         return((double)SymbolInfoInteger(symbol,SYMBOL_SPREAD));
      case MODE_STOPLEVEL:
         return((double)SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL));
      case MODE_LOTSIZE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_CONTRACT_SIZE));
      case MODE_TICKVALUE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_VALUE));
      case MODE_TICKSIZE:
         return(SymbolInfoDouble(symbol,SYMBOL_TRADE_TICK_SIZE));
      case MODE_SWAPLONG:
         return(SymbolInfoDouble(symbol,SYMBOL_SWAP_LONG));
      case MODE_SWAPSHORT:
         return(SymbolInfoDouble(symbol,SYMBOL_SWAP_SHORT));
      case MODE_STARTING:
         return(0);
      case MODE_EXPIRATION:
         return(0);
      case MODE_TRADEALLOWED:
         return(0);
      case MODE_MINLOT:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN));
      case MODE_LOTSTEP:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP));
      case MODE_MAXLOT:
         return(SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX));
      case MODE_MARGINCALCMODE:
         return(0);
      case MODE_MARGININIT:
         return(0);
      case MODE_MARGINMAINTENANCE:
         return(0);
      case MODE_MARGINHEDGED:
         return(0);
      case MODE_MARGINREQUIRED:
         return(0);
      case MODE_FREEZELEVEL:
         return((double)SymbolInfoInteger(symbol,SYMBOL_TRADE_FREEZE_LEVEL));

      default: return(0);
     }
   return(0);
}

int iBars(string symbol,int tf)
{
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   return(Bars(symbol,timeframe));
}

int iBarShift(string symbol,
                  int tf,
                  datetime time,
                  bool exact=false)
{
   if(time<0) return(-1);
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   datetime Arr[],time1;
   CopyTime(symbol,timeframe,0,1,Arr);
   time1=Arr[0];
   if(CopyTime(symbol,timeframe,time,time1,Arr)>0)
   {
      if(ArraySize(Arr)>2) return(ArraySize(Arr)-1);
      if(time<time1) return(1);
      else return(0);
   }
   else return(-1);
}
  
double iClose(string symbol,int tf,int index)
{
   if(index < 0) return(-1);
   double Arr[];
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   if(CopyClose(symbol,timeframe, index, 1, Arr)>0) 
        return(Arr[0]);
   else return(-1);
}

double iOpen(string symbol,int tf,int index)

{   
   if(index < 0) return(-1);
   double Arr[];
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   if(CopyOpen(symbol,timeframe, index, 1, Arr)>0) 
        return(Arr[0]);
   else return(-1);
}

double iHigh(string symbol,int tf,int index)

{
   if(index < 0) return(-1);
   double Arr[];
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   if(CopyHigh(symbol,timeframe, index, 1, Arr)>0) 
        return(Arr[0]);
   else return(-1);
}

double iLow(string symbol,int tf,int index)

{
   if(index < 0) return(-1);
   double Arr[];
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   if(CopyLow(symbol,timeframe, index, 1, Arr)>0)
        return(Arr[0]);
   else return(-1);
}

int iHighest(string symbol,
             int tf,
             int type,
             int count=WHOLE_ARRAY,
             int start=0)
{
   if(start<0) return(-1);
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   if(count<=0) count=Bars(symbol,timeframe);
   if(type<=MODE_OPEN)
     {
      double Open1[];
      ArraySetAsSeries(Open1,true);
      CopyOpen(symbol,timeframe,start,count,Open1);
      return(ArrayMaximum(Open1,0,count)+start);
     }
   if(type==MODE_LOW)
     {
      double Low1[];
      ArraySetAsSeries(Low1,true);
      CopyLow(symbol,timeframe,start,count,Low1);
      return(ArrayMaximum(Low1,0,count)+start);
     }
   if(type==MODE_HIGH)
     {
      double High1[];
      ArraySetAsSeries(High1,true);
      CopyHigh(symbol,timeframe,start,count,High1);
      return(ArrayMaximum(High1,0,count)+start);
     }
   if(type==MODE_CLOSE)
     {
      double Close1[];
      ArraySetAsSeries(Close1,true);
      CopyClose(symbol,timeframe,start,count,Close1);
      return(ArrayMaximum(Close1,0,count)+start);
     }
   if(type==MODE_VOLUME)
     {
      long Volume1[];
      ArraySetAsSeries(Volume1,true);
      CopyTickVolume(symbol,timeframe,start,count,Volume1);
      return(ArrayMaximum(Volume1,0,count)+start);
     }
   if(type>=MODE_TIME)
     {
      datetime Time1[];
      ArraySetAsSeries(Time1,true);
      CopyTime(symbol,timeframe,start,count,Time1);
      return(ArrayMaximum(Time1,0,count)+start);
      //---
     }
   return(0);
}

int iLowest(string symbol,
            int tf,
            int type,
            int count=WHOLE_ARRAY,
            int start=0)
{
if(start<0) return(-1);
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   if(count<=0) count=Bars(symbol,timeframe);
   if(type<=MODE_OPEN)
     {
      double Open1[];
      ArraySetAsSeries(Open1,true);
      CopyOpen(symbol,timeframe,start,count,Open1);
      return(ArrayMinimum(Open1,0,count)+start);
     }
   if(type==MODE_LOW)
     {
      double Low1[];
      ArraySetAsSeries(Low1,true);
      CopyLow(symbol,timeframe,start,count,Low1);
      return(ArrayMinimum(Low1,0,count)+start);
     }
   if(type==MODE_HIGH)
     {
      double High1[];
      ArraySetAsSeries(High1,true);
      CopyHigh(symbol,timeframe,start,count,High1);
      return(ArrayMinimum(High1,0,count)+start);
     }
   if(type==MODE_CLOSE)
     {
      double Close1[];
      ArraySetAsSeries(Close1,true);
      CopyClose(symbol,timeframe,start,count,Close1);
      return(ArrayMinimum(Close1,0,count)+start);
     }
   if(type==MODE_VOLUME)
     {
      long Volume1[];
      ArraySetAsSeries(Volume1,true);
      CopyTickVolume(symbol,timeframe,start,count,Volume1);
      return(ArrayMinimum(Volume1,0,count)+start);
     }
   if(type>=MODE_TIME)
     {
      datetime Time1[];
      ArraySetAsSeries(Time1,true);
      CopyTime(symbol,timeframe,start,count,Time1);
      return(ArrayMinimum(Time1,0,count)+start);
     }
//---
   return(0);
}

datetime iTime(string symbol,
               int tf,
               int shift)
{
   if(shift < 0) return(-1);
   ENUM_TIMEFRAMES timeframe=TFMigrate(tf);
   datetime Arr[];
   if(CopyTime(symbol, timeframe, shift, 1, Arr)>0)
        return(Arr[0]);
   else return(-1);
}

long iVolume(string symbol,
               int tf,
               int shift)
{
   if(shift < 0) return(-1);
   long Arr[];
   ENUM_TIMEFRAMES timeframe = TFMigrate(tf);
   if(CopyTickVolume(symbol, timeframe, shift, 1, Arr)>0)
        return(Arr[0]);
   else
        return(-1);
}

#endif 