//+------------------------------------------------------------------+
//|                                           BillWilliamsSystem.mqh |
//|                      Copyright 2015, ForexInside AlgoTrading Lab |
//|                                            http://forexinside.me |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, ForexInside AlgoTrading Lab"
#property link      "http://forexinside.me"

#include <Trade\Trade.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct TBillWilliamsTSParams
  {
   int               AnalyzerBarCount;
   bool              AnalyzerShowSignals;
   bool              AnalyzerShowAllSignals;
   bool              AlligatorShow;
   int               AlligatorJawPeriod;
   int               AlligatorJawShift;
   int               AlligatorTeethPeriod;
   int               AlligatorTeethShift;
   int               AlligatorLipsPeriod;
   int               AlligatorLipsShift;
   ENUM_MA_METHOD    AlligatorMAMethod;
   ENUM_APPLIED_PRICE AlligatorAppliedPrice;
   bool              FractalShow;
   bool              FractalEnableTrade;
   bool              AOShow;
   bool              AOEnableTrade;
   bool              ACShow;
   bool              ACEnableTrade;
   bool              ZoneShow;
   bool              ZoneEnableTrade;
   bool              BalanceLineShow;
   bool              BalanceLineEnableTrade;
   double            TradeLot;
   color             ViewColor;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum EBillWilliamsTSAlligatorMode
  {
   EBillWilliamsTSAlligatorModeSleep,
   EBillWilliamsTSAlligatorModeBuy,
   EBillWilliamsTSAlligatorModeSell
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum EBillWilliamsTSFractalType
  {
   EBillWilliamsTSFractalTypeNone,
   EBillWilliamsTSFractalTypeBuy,
   EBillWilliamsTSFractalTypeSell
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum EBillWilliamsTSAOSignalType
  {
   EBillWilliamsTSAOSignalTypeNone,
   EBillWilliamsTSAOSignalTypeBuyDish,
   EBillWilliamsTSAOSignalTypeSellDish,
   EBillWilliamsTSAOSignalTypeBuyCross,
   EBillWilliamsTSAOSignalTypeSellCross,
   EBillWilliamsTSAOSignalTypeBuy2Peak,
   EBillWilliamsTSAOSignalTypeSell2Peak
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum EBillWilliamsTSACSignalType
  {
   EBillWilliamsTSACSignalTypeNone,
   EBillWilliamsTSACSignalTypeBuy,
   EBillWilliamsTSACSignalTypeSell
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum EBillWilliamsTSZoneSignalType
  {
   EBillWilliamsTSZoneSignalTypeNone,
   EBillWilliamsTSZoneSignalTypeBuy,
   EBillWilliamsTSZoneSignalTypeSell
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum EBillWilliamsTSBalanceSignalType
  {
   EBillWilliamsTSBalanceSignalTypeNone,
   EBillWilliamsTSBalanceSignalTypeBuyAboveBalance,
   EBillWilliamsTSBalanceSignalTypeBuyBelowBalance,
   EBillWilliamsTSBalanceSignalTypeSellBelowBalance,
   EBillWilliamsTSBalanceSignalTypeSellAboveBalance
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CBillWilliamsTS
  {
public:
                     CBillWilliamsTS(TBillWilliamsTSParams &_params,bool _tradeDisabled=false,bool _drawDisabled=false);
                    ~CBillWilliamsTS();
   void              ProcessTick();
   bool              closeBuySignal;
   bool              closeSellSignal;
   double            openBuySignal;
   double            openSellSignal;
private:
   bool              drawDisabled;
   bool              tradeDisabled;
   string            symbol;
   ENUM_TIMEFRAMES   timeframe;
   TBillWilliamsTSParams params;
   int               hAlligator;
   int               hFractals;
   int               hAO;
   int               hAC;
   int               hATR;
   int               subwindowAO;
   int               subwindowAC;
   CTrade            trade;
   CSymbolInfo       symbolInfo;
   string            baseGraphName;
   long              textObjectCounter;
   long              arrowObjectCounter;
   bool              first;
   datetime          prevTime;
   EBillWilliamsTSAlligatorMode alligatorMode;
   double            lastAOPeak;
   EBillWilliamsTSZoneSignalType lastZoneSignalType;
   int               lastZoneSignalCount;

   datetime          lastBalanceSignalTime;
   bool              lastBalanceSignalBuy;
   double            lastBalanceSignalPrice;

   double            firstFractalPrice;
   bool              firstFractalCompleted;
   double            zoneStopLoss;
   ulong             lastBalanceTicket;

   void              ProcessBars(int begin,int end);
   void              ProcessBar(int index);
   void              TextCreate(int sub_window,datetime time,double price,string text,const ENUM_ANCHOR_POINT anchor);
   void              ArrowedLineCreate(int sub_window,datetime time1,double price1,datetime time2,double price2);
   void              MarkCandle(int index,string text,bool fromDownToUp,double price);
   void              MarkLevel(int index,string text,double price,bool up);
   void              MarkIndicator(int subwindow,int index,string text,bool fromDownToUp,double level,double k);
   EBillWilliamsTSAlligatorMode DetectAlligatorMode(int index,double &jaw,double &teeth,double &lips);
   EBillWilliamsTSFractalType DetectFractalType(int index,double &price,datetime &time);
   EBillWilliamsTSAOSignalType DetectAOType(int index);
   EBillWilliamsTSACSignalType DetectACType(int index);
   EBillWilliamsTSZoneSignalType DetectZoneType(int index,int &count);
   EBillWilliamsTSBalanceSignalType DetectBalanceSignal(int index,double &price,datetime &time,int &bindex);

   void              closePosition(long positionType);
   void              closePendingOrders(bool closeBuy,bool closeSell);
  };
// ---------------- Implementation ------------------------- //
CBillWilliamsTS::CBillWilliamsTS(TBillWilliamsTSParams &_params,bool _tradeDisabled,bool _drawDisabled)
  {
   closeBuySignal=false;
   closeSellSignal=false;
   openBuySignal=0;
   openSellSignal=0;
//---
   tradeDisabled=_tradeDisabled;
   drawDisabled=_drawDisabled;
   symbol=Symbol();
   timeframe=Period();
   textObjectCounter=0;
   arrowObjectCounter=0;
   baseGraphName="BillWilliamsTSObject_";
   params=_params;
   hAlligator=iAlligator(symbol,timeframe,
                         params.AlligatorJawPeriod,params.AlligatorJawShift,
                         params.AlligatorTeethPeriod,params.AlligatorTeethShift,
                         params.AlligatorLipsPeriod,params.AlligatorLipsShift,
                         params.AlligatorMAMethod,params.AlligatorAppliedPrice);
   hFractals=iFractals(symbol,timeframe);
   hAO = iAO(symbol,timeframe);
   hAC = iAC(symbol,timeframe);
   hATR= iATR(symbol,timeframe,100);
   if(params.AlligatorShow && !drawDisabled) ChartIndicatorAdd(0,0,hAlligator);
   if(params.FractalShow && !drawDisabled) ChartIndicatorAdd(0,0,hFractals);
   if(params.AOShow && !drawDisabled)
     {
      subwindowAO=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
      ChartIndicatorAdd(0,subwindowAO,hAO);
     }
   if(params.ACShow && !drawDisabled)
     {
      subwindowAC=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
      ChartIndicatorAdd(0,subwindowAC,hAC);
     }
   first=true;
   prevTime=0;
   lastAOPeak=0;
   lastZoneSignalType = EBillWilliamsTSZoneSignalTypeNone;
   lastZoneSignalCount= 0;
   lastBalanceSignalTime=0;
//---
   alligatorMode=EBillWilliamsTSAlligatorModeSleep;
   firstFractalPrice=0;
   firstFractalCompleted=false;
   zoneStopLoss=0;
   lastBalanceTicket=0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBillWilliamsTS::~CBillWilliamsTS()
  {
   if(!drawDisabled)
     {
      if(params.ACShow) ChartIndicatorDelete(0,subwindowAC,"AC");
      if(params.AOShow) ChartIndicatorDelete(0,subwindowAO,"AO");
      if(params.FractalShow) ChartIndicatorDelete(0,0,"Fractals");
      if(params.AlligatorShow)
        {
         int index=-1;
         int count= ChartIndicatorsTotal(0,0);
         for(int i=0;i<count;i++)
           {
            string name=ChartIndicatorName(0,0,i);
            if(StringFind(name,"Alligator")==0) index=i;
           }
         if(index>=0) ChartIndicatorDelete(0,0,ChartIndicatorName(0,0,index));
        }
     }
   IndicatorRelease(hAlligator);
   IndicatorRelease(hFractals);
   IndicatorRelease(hAO);
   IndicatorRelease(hAC);
   IndicatorRelease(hATR);
//---
   if(!drawDisabled)
     {
      int n=ObjectsTotal(0);
      for(int i=n-1;i>=0;i--)
        {
         string oname=ObjectName(0,i);
         if(StringFind(oname,baseGraphName)==0)
           {
            ObjectDelete(0,oname);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsTS::TextCreate(int sub_window,datetime time,double price,string text,const ENUM_ANCHOR_POINT anchor=ANCHOR_CENTER)
  {
   if(!drawDisabled)
     {
      string name=baseGraphName+"text_"+IntegerToString(textObjectCounter++);
      ObjectCreate(0,name,OBJ_TEXT,sub_window,time,price);
      ObjectSetString(0,name,OBJPROP_TEXT,text);
      ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
      ObjectSetInteger(0,name,OBJPROP_COLOR,params.ViewColor);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsTS::ArrowedLineCreate(int sub_window,datetime time1,double price1,datetime time2,double price2)
  {
   if(!drawDisabled)
     {
      string name=baseGraphName+"line_"+IntegerToString(arrowObjectCounter++);
      ObjectCreate(0,name,OBJ_ARROWED_LINE,sub_window,time1,price1,time2,price2);
      ObjectSetInteger(0,name,OBJPROP_COLOR,params.ViewColor);
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
      ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
      ObjectSetInteger(0,name,OBJPROP_BACK,true);
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsTS::MarkCandle(int index,string text,bool fromDownToUp,double price)
  {
   double atr[1];
   double high[1];
   double low[1];
   datetime date[1];
   CopyBuffer(hATR,0,index,1,atr);
   CopyTime(symbol,timeframe,index,1,date);
   CopyHigh(symbol,timeframe,index,1,high);
   CopyLow(symbol,timeframe,index,1,low);
   if(fromDownToUp)
     {
      double price1=price-atr[0]*2;
      double price2=price;
      ArrowedLineCreate(0,date[0],price1,date[0],price2);
      TextCreate(0,date[0],price1-atr[0],text);
     }
   else
     {
      double price1=price+atr[0]*2;
      double price2=price;
      ArrowedLineCreate(0,date[0],price1,date[0],price2);
      TextCreate(0,date[0],price1+atr[0],text);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsTS::MarkLevel(int index,string text,double price,bool up)
  {
   double atr[1];
   CopyBuffer(hATR,0,index,1,atr);
   double price1=price+0.75*atr[0];
   if(!up) price1=price-0.75*atr[0];
   datetime date0[1];
   datetime date1[1];
   CopyTime(symbol,timeframe,index+5,1,date0);
   CopyTime(symbol,timeframe,index,1,date1);
//---
   ArrowedLineCreate(0,date0[0],price,date1[0],price);
   if(StringLen(text)>0) TextCreate(0,date0[0],price1,text,ANCHOR_LEFT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsTS::MarkIndicator(int subwindow,int index,string text,bool fromDownToUp,double level,double k)
  {
   double atr[1];
   CopyBuffer(hATR,0,index,1,atr);
   datetime date[1];
   CopyTime(symbol,timeframe,index,1,date);
   double dy=atr[0]*k;
   if(fromDownToUp)
     {
      double price1=level-dy;
      double price2=level;
      ArrowedLineCreate(subwindow,date[0],price1,date[0],price2);
      TextCreate(subwindow,date[0],price1-dy/3,text);
     }
   else
     {
      double price1=level+dy;
      double price2=level;
      ArrowedLineCreate(subwindow,date[0],price1,date[0],price2);
      TextCreate(subwindow,date[0],price1+dy/3,text);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EBillWilliamsTSAlligatorMode CBillWilliamsTS::DetectAlligatorMode(int index,double &jaw,double &teeth,double &lips)
  {
   EBillWilliamsTSAlligatorMode mode=EBillWilliamsTSAlligatorModeSleep;
   double _jaw[1];
   double _teeth[1];
   double _lips[1];
   CopyBuffer(hAlligator,0,index,1,_jaw);
   CopyBuffer(hAlligator,1,index,1,_teeth);
   CopyBuffer(hAlligator,2,index,1,_lips);
   jaw=_jaw[0];
   teeth=_teeth[0];
   lips=_lips[0];
   if(lips>teeth && teeth>jaw) mode=EBillWilliamsTSAlligatorModeBuy;
   if(lips<teeth && teeth<jaw) mode=EBillWilliamsTSAlligatorModeSell;
//---
   return mode;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EBillWilliamsTSFractalType CBillWilliamsTS::DetectFractalType(int index,double &price,datetime &time)
  {
   EBillWilliamsTSFractalType type=EBillWilliamsTSFractalTypeNone;
   double fractalUp[1];
   double fractalDown[1];
   double high[1];
   double low[1];
   datetime date[1];
   if(CopyBuffer(hFractals,0,index,1,fractalUp)<=0) return type;
   if(CopyBuffer(hFractals,1,index,1,fractalDown)<=0) return type;
   if(CopyHigh(symbol,timeframe,index,1,high)<=0) return type;
   if(CopyLow(symbol,timeframe,index,1,low)<=0) return type;
   if(CopyTime(symbol,timeframe,index,1,date)<=0) return type;
   if(fractalUp[0]!=EMPTY_VALUE) {type=EBillWilliamsTSFractalTypeBuy; price=high[0]; time=date[0]; }
   if(fractalDown[0]!=EMPTY_VALUE) {type=EBillWilliamsTSFractalTypeSell; price=low[0]; time=date[0]; }
   return type;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EBillWilliamsTSAOSignalType CBillWilliamsTS::DetectAOType(int index)
  {
   EBillWilliamsTSAOSignalType type=EBillWilliamsTSAOSignalTypeNone;
   double ao[3];
   if(CopyBuffer(hAO,0,index,3,ao)<3) return type;
//---
   if(ao[2]>ao[1] && ao[1]<ao[0] && ao[0]<0)
     {
      if(lastAOPeak<0 && lastAOPeak<ao[2])
        {
         lastAOPeak=ao[2];
         return EBillWilliamsTSAOSignalTypeBuy2Peak;
        }
      else
        {
         lastAOPeak=ao[2];
        }
     }
   if(ao[2]<ao[1] && ao[1]>ao[0] && ao[0]>0)
     {
      if(lastAOPeak>0 && lastAOPeak>ao[2])
        {
         lastAOPeak=ao[2];
         return EBillWilliamsTSAOSignalTypeSell2Peak;
        }
      else
        {
         lastAOPeak=ao[2];
        }
     }
//---
   if(ao[0]>0 && ao[1]>0 && ao[2]>0 && ao[0]>ao[1] && ao[1]<ao[0] && ao[2]>ao[1]) return EBillWilliamsTSAOSignalTypeBuyDish;
   if(ao[0]<0 && ao[1]<0 && ao[2]<0 && ao[0]<ao[1] && ao[1]>ao[0] && ao[2]<ao[1]) return EBillWilliamsTSAOSignalTypeSellDish;
   if(ao[0]<=0 && ao[1]>0) return EBillWilliamsTSAOSignalTypeBuyCross;
   if(ao[0]>=0 && ao[1]<0) return EBillWilliamsTSAOSignalTypeSellCross;
   return type;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EBillWilliamsTSACSignalType CBillWilliamsTS::DetectACType(int index)
  {
   EBillWilliamsTSACSignalType type=EBillWilliamsTSACSignalTypeNone;
   double ac[4];
   if(CopyBuffer(hAC,0,index,3,ac)<3) return type;
//---
   if(ac[0]>0 && ac[1]>0 && ac[2]>0 && ac[1]>ac[0] && ac[2]>ac[1]) return EBillWilliamsTSACSignalTypeBuy;
   if(ac[0]<0 && ac[1]<0 && ac[2]<0 && ac[1]<ac[0] && ac[2]<ac[1]) return EBillWilliamsTSACSignalTypeSell;
//---
   if(ac[0]>0 && (ac[1]<0 || ac[2]<0) && ac[1]<ac[0] && ac[2]<ac[1]) return EBillWilliamsTSACSignalTypeSell;
   if(ac[0]<0 && (ac[1]>0 || ac[2]>0) && ac[1]>ac[0] && ac[2]>ac[1]) return EBillWilliamsTSACSignalTypeBuy;
//---
   if(CopyBuffer(hAC,0,index,4,ac)<4) return type;
//---
   if(ac[0]>0 && ac[1]>0 && ac[2]>0 && ac[3]>0 && ac[1]<ac[0] && ac[2]<ac[1] && ac[3]<ac[2]) return EBillWilliamsTSACSignalTypeSell;
   if(ac[0]<0 && ac[1]<0 && ac[2]<0 && ac[3]<0 && ac[1]>ac[0] && ac[2]>ac[1] && ac[3]>ac[2]) return EBillWilliamsTSACSignalTypeBuy;
//---
   return type;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EBillWilliamsTSZoneSignalType CBillWilliamsTS::DetectZoneType(int index,int &count)
  {
   EBillWilliamsTSZoneSignalType type=EBillWilliamsTSZoneSignalTypeNone;
   double _ao[2];
   double _ac[2];
   if(CopyBuffer(hAO,0,index,2,_ao)<2) return type;
   if(CopyBuffer(hAC,0,index,2,_ac)<2) return type;
   double aoPrev=_ao[0];
   double acPrev=_ac[0];
   double ao=_ao[1];
   double ac=_ac[1];
   if(ao>aoPrev && ac>acPrev)
     {
      type=EBillWilliamsTSZoneSignalTypeBuy;
     }
   if(ao<aoPrev && ac<acPrev)
     {
      type=EBillWilliamsTSZoneSignalTypeSell;
     }
   if(type!=lastZoneSignalType)
     {
      lastZoneSignalType=type;
      lastZoneSignalCount=1;
      count=lastZoneSignalCount;
      return type;
     }
   lastZoneSignalCount++;
   count=lastZoneSignalCount;
   return type;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EBillWilliamsTSBalanceSignalType CBillWilliamsTS::DetectBalanceSignal(int index,double &price,datetime &time,int &bindex)
  {
   double low[3];
   double high[3];
   datetime tm[3];
   EBillWilliamsTSBalanceSignalType type=EBillWilliamsTSBalanceSignalTypeNone;
   if(CopyLow(symbol,timeframe,index,3,low)<3) return type;
   if(CopyHigh(symbol,timeframe,index,3,high)<3) return type;
   if(CopyTime(symbol,timeframe,index,3,tm)<3) return type;
   if(alligatorMode==EBillWilliamsTSAlligatorModeBuy)
     {
      if(high[1]>high[2])
        {
         price=high[1];
         time=tm[1];
         bindex=index+1;
         return EBillWilliamsTSBalanceSignalTypeBuyAboveBalance;
        }
      if(low[0]<low[1] && low[1]<low[2])
        {
         price=low[0];
         time=tm[0];
         bindex=index+2;
         return EBillWilliamsTSBalanceSignalTypeSellAboveBalance;
        }
     }
   if(alligatorMode==EBillWilliamsTSAlligatorModeSell)
     {
      if(low[1]<low[2])
        {
         price=low[1];
         time=tm[1];
         bindex=index+1;
         return EBillWilliamsTSBalanceSignalTypeSellBelowBalance;
        }
      if(high[0]>high[1] && high[1]>high[2])
        {
         price=high[0];
         time=tm[0];
         bindex=index+2;
         return EBillWilliamsTSBalanceSignalTypeBuyBelowBalance;
        }
     }
   return type;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsTS::ProcessTick()
  {
   datetime time[1];
   if(CopyTime(symbol,timeframe,0,1,time)<=0) return;
   int bars=Bars(symbol,timeframe);
   if(bars<2) return;
//---
   if(first)
     {
      first=false;
      prevTime=time[0];
      int firstBar=params.AnalyzerBarCount==0 ? bars :(params.AnalyzerBarCount+1);
      if(firstBar>(bars-1)) firstBar=bars-1;
      double jaw,teeth,lips;
      alligatorMode=DetectAlligatorMode(firstBar,jaw,teeth,lips);
      ProcessBars(firstBar,1);
      closeBuySignal=false;
      closeSellSignal=false;
      openBuySignal=0;
      openSellSignal=0;
      return;
     }
   if(time[0]>prevTime)
     {
      closeBuySignal=false;
      closeSellSignal=false;
      openBuySignal=0;
      openSellSignal=0;
      ProcessBars(1,1);
      prevTime=time[0];
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsTS::ProcessBars(int begin,int end)
  {
   for(int i=begin;i>=end;i--)
     {
      ProcessBar(i);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsTS::ProcessBar(int index)
  {
//--- candle
   double closearray[1],openarray[1],lowarray[1],higharray[1];
   CopyClose(symbol,timeframe,index,1,closearray);
   CopyOpen(symbol,timeframe,index,1,openarray);
   CopyLow(symbol,timeframe,index,1,lowarray);
   CopyHigh(symbol,timeframe,index,1,higharray);
   double close=closearray[0];
   double open=openarray[0];
   double low=lowarray[0];
   double high=higharray[0];
//--- alligator
   double jaw,teeth,lips;
   EBillWilliamsTSAlligatorMode newAlligatorMode=DetectAlligatorMode(index,jaw,teeth,lips);
   if(newAlligatorMode!=alligatorMode)
     {
      alligatorMode=newAlligatorMode;
      if(params.AnalyzerShowSignals && params.AnalyzerShowAllSignals)
        {
         if(alligatorMode == EBillWilliamsTSAlligatorModeSleep) MarkCandle(index,"N",true,jaw);
         if(alligatorMode == EBillWilliamsTSAlligatorModeBuy) MarkCandle(index,"B",true,jaw);
         if(alligatorMode == EBillWilliamsTSAlligatorModeSell) MarkCandle(index,"S",false,jaw);
        }
      if(index<=1)
        {
         closePendingOrders(true,true);
         closePosition(POSITION_TYPE_BUY);
         closePosition(POSITION_TYPE_SELL);
         closeBuySignal|=true;
         closeSellSignal|=true;
        }
      firstFractalCompleted=false;
      firstFractalPrice=0;
      zoneStopLoss=0;
      lastBalanceTicket=0;
     }
//--- check first fractal completed
   if(!firstFractalCompleted && firstFractalPrice>0)
     {
      if(alligatorMode==EBillWilliamsTSAlligatorModeBuy)
        {
         if(high>=firstFractalPrice) firstFractalCompleted=true;
        }
      if(alligatorMode==EBillWilliamsTSAlligatorModeSell)
        {
         if(low<=firstFractalPrice) firstFractalCompleted=true;
        }
     }
//---
   double buyprice=0;
   double sellprice=0;
   bool balancetrade=false;
//--- 1. fractals-dimension
   double fractalPrice;
   datetime fractalTime;
   EBillWilliamsTSFractalType fractal=DetectFractalType(index+2,fractalPrice,fractalTime);
   if(fractal==EBillWilliamsTSFractalTypeBuy && fractalPrice>teeth)
     {
      if(params.AnalyzerShowSignals && params.FractalShow)
        {
         if(alligatorMode==EBillWilliamsTSAlligatorModeBuy || params.AnalyzerShowAllSignals)
           {
            MarkLevel(index+2,"FrB",fractalPrice,true);
           }
        }
      if(alligatorMode==EBillWilliamsTSAlligatorModeBuy)
        {
         if(firstFractalPrice==0)
           {
            firstFractalPrice=fractalPrice;
           }
         else
           {
            if(!firstFractalCompleted)
              {
               if(fractalPrice<firstFractalPrice) firstFractalPrice=fractalPrice;
              }
           }
         if(params.FractalEnableTrade) buyprice=fractalPrice;
        }
     }
   if(fractal==EBillWilliamsTSFractalTypeSell && fractalPrice<teeth)
     {
      if(params.AnalyzerShowSignals && params.FractalShow)
        {
         if(alligatorMode==EBillWilliamsTSAlligatorModeSell || params.AnalyzerShowAllSignals)
           {
            MarkLevel(index+2,"FrS",fractalPrice,false);
           }
        }
      if(alligatorMode==EBillWilliamsTSAlligatorModeSell)
        {
         if(firstFractalPrice==0)
           {
            firstFractalPrice=fractalPrice;
           }
         else
           {
            if(!firstFractalCompleted)
              {
               if(fractalPrice>firstFractalPrice) firstFractalPrice=fractalPrice;
              }
           }
         if(params.FractalEnableTrade) sellprice=fractalPrice;
        }
     }
//---
   bool canBuy=firstFractalCompleted && alligatorMode==EBillWilliamsTSAlligatorModeBuy;
   bool canSell=firstFractalCompleted && alligatorMode==EBillWilliamsTSAlligatorModeSell;
//--- 2. ao-dimension
   EBillWilliamsTSAOSignalType ao=DetectAOType(index);
   if(ao==EBillWilliamsTSAOSignalTypeBuyDish)
     {
      if(params.AnalyzerShowSignals && params.AOShow && (canBuy || params.AnalyzerShowAllSignals))
        {
         MarkIndicator(subwindowAO,index,"DiB",true,0,1.0);
        }
      if(params.AOEnableTrade && canBuy) buyprice=high;
     }
   if(ao==EBillWilliamsTSAOSignalTypeSellDish)
     {
      if(params.AnalyzerShowSignals && params.AOShow && (canSell || params.AnalyzerShowAllSignals))
        {
         MarkIndicator(subwindowAO,index,"DiS",false,0,1.0);
        }
      if(params.AOEnableTrade && canSell) sellprice=low;
     }
   if(ao==EBillWilliamsTSAOSignalTypeBuyCross)
     {
      if(params.AnalyzerShowSignals && params.AOShow && (canBuy || params.AnalyzerShowAllSignals))
        {
         MarkIndicator(subwindowAO,index,"CrB",true,0,1.3);
        }
      if(params.AOEnableTrade && canBuy) buyprice=high;
     }
   if(ao==EBillWilliamsTSAOSignalTypeSellCross && (canSell || params.AnalyzerShowAllSignals))
     {
      if(params.AnalyzerShowSignals && params.AOShow && (canSell || params.AnalyzerShowAllSignals))
        {
         MarkIndicator(subwindowAO,index,"CrS",false,0,1.3);
        }
      if(params.AOEnableTrade && canSell) sellprice=low;
     }
   if(ao==EBillWilliamsTSAOSignalTypeBuy2Peak)
     {
      if(params.AnalyzerShowSignals && params.AOShow && (canBuy || params.AnalyzerShowAllSignals))
        {
         MarkIndicator(subwindowAO,index,"2pB",true,0,1.5);
        }
      if(params.AOEnableTrade && canBuy) buyprice=high;
     }
   if(ao==EBillWilliamsTSAOSignalTypeSell2Peak)
     {
      if(params.AnalyzerShowSignals && params.AOShow && (canSell || params.AnalyzerShowAllSignals))
        {
         MarkIndicator(subwindowAO,index,"2pS",false,0,1.5);
        }
      if(params.AOEnableTrade && canSell) sellprice=low;
     }
//--- 3. ac-dimension
   EBillWilliamsTSACSignalType ac=DetectACType(index);
   if(ac==EBillWilliamsTSACSignalTypeBuy)
     {
      if(params.AnalyzerShowSignals && params.ACShow && (canBuy || params.AnalyzerShowAllSignals))
        {
         MarkIndicator(subwindowAC,index,"B",true,0,0.4);
        }
      if(params.ACEnableTrade && canBuy) buyprice=high;
     }
   if(ac==EBillWilliamsTSACSignalTypeSell)
     {
      if(params.AnalyzerShowSignals && params.ACShow && (canSell || params.AnalyzerShowAllSignals))
        {
         MarkIndicator(subwindowAC,index,"S",false,0,0.4);
        }
      if(params.ACEnableTrade && canSell) sellprice=low;
     }
//--- 4. zone-dimension
   int zoneCount=0;
   EBillWilliamsTSZoneSignalType zone=DetectZoneType(index,zoneCount);
   if(zone==EBillWilliamsTSZoneSignalTypeBuy && zoneCount>=2 && zoneCount<=5)
     {
      if(params.AnalyzerShowSignals && params.ZoneShow && (canBuy || params.AnalyzerShowAllSignals))
        {
         if(params.ACShow) MarkIndicator(subwindowAC,index,"ZB",true,0,0.2);
        }
      if(params.ZoneEnableTrade && canBuy) buyprice=high;
     }
   if(zone==EBillWilliamsTSZoneSignalTypeSell && zoneCount>=2 && zoneCount<=5)
     {
      if(params.AnalyzerShowSignals && params.ZoneShow && (canSell || params.AnalyzerShowAllSignals))
        {
         if(params.ACShow) MarkIndicator(subwindowAC,index,"ZS",false,0,0.2);
        }
      if(params.ZoneEnableTrade && canSell) sellprice=low;
     }
   if(zoneCount>=5)
     {
      if(zone == EBillWilliamsTSZoneSignalTypeBuy) zoneStopLoss=low;
      if(zone == EBillWilliamsTSZoneSignalTypeSell) zoneStopLoss=high;
     }
//--- 5. balance-dimension
   double bprice=0;
   datetime btime=0;
   int bindex=0;
   EBillWilliamsTSBalanceSignalType balance=DetectBalanceSignal(index,bprice,btime,bindex);
   if(balance==EBillWilliamsTSBalanceSignalTypeBuyAboveBalance)
     {
      if(params.AnalyzerShowSignals && params.BalanceLineShow)
        {
         MarkLevel(bindex,"",bprice,true);
        }
      if(lastBalanceTicket>0) { trade.OrderDelete(lastBalanceTicket); lastBalanceTicket=0; }
      if(buyprice==0) { buyprice=bprice; balancetrade=true;}
     }
   if(balance==EBillWilliamsTSBalanceSignalTypeBuyBelowBalance)
     {
      if(params.AnalyzerShowSignals && params.BalanceLineShow)
        {
         MarkLevel(bindex,"",bprice,true);
        }
      if(lastBalanceTicket>0) { trade.OrderDelete(lastBalanceTicket); lastBalanceTicket=0; }
      if(buyprice==0) { buyprice=bprice; balancetrade=true;}
     }
   if(balance==EBillWilliamsTSBalanceSignalTypeSellBelowBalance)
     {
      if(params.AnalyzerShowSignals && params.BalanceLineShow)
        {
         MarkLevel(bindex,"",bprice,false);
        }
      if(lastBalanceTicket>0) { trade.OrderDelete(lastBalanceTicket); lastBalanceTicket=0; }
      if(sellprice==0) { sellprice=bprice; balancetrade=true;}
     }
   if(balance==EBillWilliamsTSBalanceSignalTypeSellAboveBalance)
     {
      if(params.AnalyzerShowSignals && params.BalanceLineShow)
        {
         MarkLevel(bindex,"",bprice,false);
        }
      if(lastBalanceTicket>0) { trade.OrderDelete(lastBalanceTicket); lastBalanceTicket=0; }
      if(sellprice==0) { sellprice=bprice; balancetrade=true;}
     }
//--- close positions
   if(index<=1)
     {
      bool closeBuy=false;
      bool closeSell=false;
      closeBuy|=close<teeth;
      closeSell|=close>teeth;
      if(zoneStopLoss>0)
        {
         if(canBuy) closeBuy=(low<zoneStopLoss);
         if(canSell) closeSell=(high>zoneStopLoss);
        }
      //---
      if(!tradeDisabled)
        {
         if(closeBuy) closePosition(POSITION_TYPE_BUY);
         if(closeSell) closePosition(POSITION_TYPE_SELL);
         closePendingOrders(closeBuy,closeSell);
        }
      closeBuySignal|=closeBuy;
      closeSellSignal|=closeSell;
     }
//--- open positions
   if(index<=1)
     {
      if(!tradeDisabled)
        {
         if(buyprice>0)
           {
            if(buyprice>close) trade.BuyStop(params.TradeLot,NormalizeDouble(buyprice,_Digits),symbol);
            else trade.BuyLimit(params.TradeLot,NormalizeDouble(buyprice,_Digits));
           }
         if(sellprice>0)
           {
            if(sellprice<close) trade.SellStop(params.TradeLot,NormalizeDouble(sellprice,_Digits));
            else trade.SellLimit(params.TradeLot,NormalizeDouble(sellprice,_Digits));
           }
        }
      openBuySignal=buyprice;
      openSellSignal=sellprice;
      if(balancetrade) lastBalanceTicket=trade.ResultDeal();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsTS::closePosition(long positionType)
  {
   if(PositionSelect(symbol))
     {
      if(PositionGetInteger(POSITION_TYPE)==positionType) trade.PositionClose(symbol);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsTS::closePendingOrders(bool closeBuy,bool closeSell)
  {
   int n=OrdersTotal();
   for(int i=n-1; i>=0; i--)
     {
      ulong orderTicket=OrderGetTicket(i);
      if(orderTicket>0)
        {
         if(OrderGetString(ORDER_SYMBOL)==symbol)
           {
            long type=OrderGetInteger(ORDER_TYPE);
            bool close=false;
            close|= closeSell && (type == ORDER_TYPE_SELL_LIMIT || type==ORDER_TYPE_SELL_STOP);
            close|= closeBuy && (type==ORDER_TYPE_BUY_LIMIT || type==ORDER_TYPE_BUY_STOP);
            if(close)
              {
               trade.OrderDelete(orderTicket);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
