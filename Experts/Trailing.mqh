//+------------------------------------------------------------------+
//|                                                     Trailing.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Trailing stop                                                    |
//+------------------------------------------------------------------+
enum   TrallMethod
  {
   b=1,     //Based on candlestick extrema
   c=2,     //Using fractals
   d=3,     //Based on the ATR indicator
   e=4,     //Based on the Parabolic indicator
   f=5,     //Based on the MA indicator
   g=6,     //% of profit]
   i=7,     //Using points
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTrailing
  {
protected:
   //--- The flag of the virtual trailing stop
   bool              m_virtual_stop;
   //--- Trailing stop method
   TrallMethod       m_trall_method;
   //--- Timeframe of indicators (0-current)
   ENUM_TIMEFRAMES   m_tf_tralling;
   //--- Offset from the calculated Stop Loss level
   int               m_delta;
   //--- Trailing step and minimum trailing profit in points
   int               m_step_trall;
   int               m_start_trall;
   //--- ATR period (method #3)
   int               m_atr_period;
   //--- Parabolic Step Parabolic Maximum (method #4)
   double            m_step;
   double            m_maximum;
   //--- Magic of orders for trailing (-1 all)
   int               m_magic;
   //--- MA period, method of averaging, price type (method #5)
   int               m_ma_period;
   ENUM_MA_METHOD    m_ma_method;
   ENUM_APPLIED_PRICE m_applied_price;
   //--- Percent of profit (method #6)
   double            m_percent_profit;
   //---
   MqlTradeRequest   request;
   MqlTradeResult    result;
   MqlTradeCheckResult check;
   //---
   int               m_slippage;
   int               m_stop_level;
   //---
   double            SlLastBar(int tip,double price,double OOP);
public:
                     CTrailing(void);
                    ~CTrailing(void);
   //--- 
   void              IsVirtualStop(const bool v)            { m_virtual_stop=v;        }
   void              SetTrallMethod(const TrallMethod t)    { m_trall_method=t;        }

   void              SetTimeframe(const ENUM_TIMEFRAMES tf) { m_tf_tralling=tf;        }

   void              SetStepTrall(const int step)           { m_step_trall=step;       }
   void              SetStartTrall(const int start)         { m_start_trall=start;     }

   void              SetATR(const int atr)                  { m_atr_period=atr;        }

   void              SetPSAR_Step(const double step)        { m_step=step;             }
   void              SetPSAR_Max(const double max)          { m_maximum=max;           }
   void              SetMagicNumber(const int mgc)          { m_magic=mgc;             }

   void              SetMA_Period(int period)               { m_ma_period=period;      }
   void              SetMA_Method(ENUM_MA_METHOD method)    { m_ma_method=method;      }
   void              SetMA_Price(ENUM_APPLIED_PRICE price)  { m_applied_price=price;   }

   void              SetPercProfit(double profit)           { m_percent_profit=profit; }
   void              SetSlippage(int slpg)                  { m_slippage=slpg;         }

   void              TrailingStop(void);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrailing::CTrailing(void): m_virtual_stop(false),
                            m_trall_method(7),
                            m_tf_tralling(PERIOD_CURRENT),
                            m_delta(0),
                            m_step_trall(5),
                            m_start_trall(10),
                            m_atr_period(14),
                            m_step(0.02),
                            m_maximum(0.2),
                            m_magic(-1),
                            m_ma_period(34),
                            m_ma_method(MODE_SMA),
                            m_applied_price(PRICE_CLOSE),
                            m_slippage(100)

  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrailing::~CTrailing(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CTrailing::TrailingStop(void)
  {
   long OT;
   int n=0;
   double OOP=0;
   double Bid,Ask,SLB=0,SLS=0;
//----
   if(!m_virtual_stop)
      m_stop_level=(int)SymbolInfoInteger(_Symbol,SYMBOL_TRADE_STOPS_LEVEL);
   double sl,SL;
   Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   int i,b=0,s=0;
   double PB=0,PS=0,OL=0,NLb=0,NLs=0,LS=0,LB=0;
//----
   for(i=0; i<PositionsTotal(); i++)
     {
      if(SelectByIndex(i))
        {
         if(PositionGetString(POSITION_SYMBOL)==Symbol() && PositionGetInteger(POSITION_MAGIC)==m_magic)
           {
            OL  = PositionGetDouble(POSITION_VOLUME);
            OOP = PositionGetDouble(POSITION_PRICE_OPEN);
            OT  = PositionGetInteger(POSITION_TYPE);
            if(OT==POSITION_TYPE_BUY ) {PB += OOP*OL; LB+=OL; b++;}
            if(OT==POSITION_TYPE_SELL) {PS += OOP*OL; LS+=OL; s++;}
           }
        }
     }
//----
   if(LB!=0)
     {
      NLb=PB/LB;
     }
   if(LS!=0)
     {
      NLs=PS/LS;
     }
//----
   request.symbol=_Symbol;
   for(i=0; i<PositionsTotal(); i++)
     {
      if(SelectByIndex(i))
        {
         if(PositionGetString(POSITION_SYMBOL)==Symbol() && PositionGetInteger(POSITION_MAGIC)==m_magic)
           {
            OL  = PositionGetDouble(POSITION_VOLUME);
            OOP = PositionGetDouble(POSITION_PRICE_OPEN);
            OT  = PositionGetInteger(POSITION_TYPE);
            sl=PositionGetDouble(POSITION_SL);
            if(OT==POSITION_TYPE_BUY)
              {
               if(m_virtual_stop)
                 {
                  SL=SlLastBar(POSITION_TYPE_BUY,Bid,NLb);
                  if(SL!=-1 && NLb+m_start_trall*_Point<SL && SLB<SL) SLB=SL;
                  if(SLB!=0)
                    {
                     if(Bid<=SLB)
                       {
                        request.deviation=m_slippage;
                        request.volume=PositionGetDouble(POSITION_VOLUME);
                        request.position=PositionGetInteger(POSITION_TICKET);
                        request.action=TRADE_ACTION_DEAL;
                        request.type_filling=ORDER_FILLING_FOK;
                        request.type=ORDER_TYPE_SELL;
                        request.price=Bid;
                        request.comment="";
                        if(!OrderSend(request,result)) Print("error ",GetLastError());
                       }
                    }
                 }
               else
                 {
                  SL=SlLastBar(POSITION_TYPE_BUY,Bid,OOP);
                  if(SL!=-1 && sl+m_step_trall*_Point<SL && SL>=OOP+m_start_trall*_Point)
                    {
                     request.action    = TRADE_ACTION_SLTP;
                     request.position  = PositionGetInteger(POSITION_TICKET);
                     request.sl        = SL;
                     request.tp        = PositionGetDouble(POSITION_TP);
                     if(!OrderSend(request,result)) Print("error ",GetLastError());
                    }
                 }
              }
            if(OT==POSITION_TYPE_SELL)
              {
               if(m_virtual_stop)
                 {
                  SL=SlLastBar(POSITION_TYPE_SELL,Ask,NLs);
                  if(SL!=-1 && (SLS==0 || SLS>SL) && SL<=NLs-m_start_trall*_Point) SLS=SL;
                  if(SLS!=0)
                    {
                     if(Ask>=SLS)
                       {
                        request.volume=PositionGetDouble(POSITION_VOLUME);
                        request.position=PositionGetInteger(POSITION_TICKET);
                        request.action=TRADE_ACTION_DEAL;
                        request.type_filling=ORDER_FILLING_FOK;
                        request.type=ORDER_TYPE_BUY;
                        request.price=Ask;
                        request.comment="";
                        if(!OrderSend(request,result)) Print("error ",GetLastError());
                       }
                    }
                 }
               else
                 {
                  SL=SlLastBar(POSITION_TYPE_SELL,Ask,OOP);
                  if(SL!=-1 && (sl==0 || sl-m_step_trall*_Point>SL) && SL<=OOP-m_start_trall*_Point)
                    {
                     request.action    = TRADE_ACTION_SLTP;
                     request.position  = PositionGetInteger(POSITION_TICKET);
                     request.sl        = SL;
                     request.tp        = PositionGetDouble(POSITION_TP);
                     if(OrderCheck(request,check)) if(!OrderSend(request,result)) Print("error ",GetLastError());
                     else Print("error ",GetLastError());
                    }
                 }
              }
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CTrailing::SlLastBar(int tip,double price,double OOP)
  {
   double prc=0;
   int i;
   int maHandle=0;    // Moving Average indicator handle
   double maVal[];  // dynamic array to store values of Moving Average indicator for each bar
   int atrHandle=0;    // Moving Average indicator handle
   double atrVal[];  // dynamic array to store values of Moving Average indicator for each bar
   int sarHandle=0;    // Moving Average indicator handle
   double sarVal[];  // dynamic array to store values of Moving Average indicator for each bar
   switch(m_trall_method)
     {
      case 1: // Based on candlestick extrema
         if(tip==POSITION_TYPE_BUY)
           {
            for(i=1; i<500; i++)
              {
               prc=NormalizeDouble(iLow(Symbol(),m_tf_tralling,i)-m_delta*_Point,_Digits);
               if(prc!=0) if(price-m_stop_level*_Point>prc) break;
               else prc=0;
              }
           }
         if(tip==POSITION_TYPE_SELL)
           {
            for(i=1; i<500; i++)
              {
               prc=NormalizeDouble(iHigh(Symbol(),m_tf_tralling,i)+m_delta*_Point,_Digits);
               if(prc!=0) if(price+m_stop_level*_Point<prc) break;
               else prc=0;
              }
           }
         break;

      case 2: // Using fractals
         if(tip==POSITION_TYPE_BUY)
           {
            for(i=2; i<100; i++)
              {
               if(iLow(Symbol(),m_tf_tralling,i)<iLow(Symbol(),m_tf_tralling,i+1) && 
                  iLow(Symbol(),m_tf_tralling,i)<iLow(Symbol(),m_tf_tralling,i-1) && 
                  iLow(Symbol(),m_tf_tralling,i)<iLow(Symbol(),m_tf_tralling,i+2))
                 {
                  prc=iLow(Symbol(),m_tf_tralling,i);
                  if(prc!=0)
                    {
                     prc=NormalizeDouble(prc-m_delta*_Point,_Digits);
                     if(price-m_stop_level*_Point>prc) break;
                    }
                  else prc=0;
                 }
              }
           }
         if(tip==POSITION_TYPE_SELL)
           {
            for(i=2; i<100; i++)
              {
               if(iHigh(Symbol(),m_tf_tralling,i)>iHigh(Symbol(),m_tf_tralling,i+1) && 
                  iHigh(Symbol(),m_tf_tralling,i)>iHigh(Symbol(),m_tf_tralling,i-1) && 
                  iHigh(Symbol(),m_tf_tralling,i)>iHigh(Symbol(),m_tf_tralling,i+2))
                 {
                  prc=iHigh(Symbol(),m_tf_tralling,i);
                  if(prc!=0)
                    {
                     prc=NormalizeDouble(prc+m_delta*_Point,_Digits);
                     if(price+m_stop_level*_Point<prc) break;
                    }
                  else prc=0;
                 }
              }
           }
         break;
      case 3: // by ATR
         ArraySetAsSeries(atrVal,true);
         if(CopyBuffer(atrHandle,0,0,3,atrVal)<0)
           {
            Print("Ошибка ATR :",GetLastError());
            prc=-1;
            break;
           }
         prc=atrVal[1];
         if(tip==POSITION_TYPE_BUY)
           {
            prc=NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_BID)-prc-m_delta*_Point,_Digits);
           }
         if(tip==POSITION_TYPE_SELL)
           {
            prc=NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_ASK)+prc+m_delta*_Point,_Digits);
           }
         break;

      case 4: // by Parabolic
         ArraySetAsSeries(sarVal,true);
         if(CopyBuffer(sarHandle,0,0,3,sarVal)<0)
           {
            Print("Ошибка Parabolic SAR :",GetLastError());
            prc=-1;
            break;
           }
         prc=sarVal[1];
         if(tip==POSITION_TYPE_BUY)
           {
            prc=NormalizeDouble(prc-m_delta*_Point,_Digits);
            if(price-m_stop_level*_Point<prc) prc=0;
           }
         if(tip==POSITION_TYPE_SELL)
           {
            prc=NormalizeDouble(prc+m_delta*_Point,_Digits);
            if(price+m_stop_level*_Point>prc) prc=0;
           }
         break;

      case 5: // by MA
         ArraySetAsSeries(maVal,true);
         if(CopyBuffer(maHandle,0,0,3,maVal)<0)
           {
            Print("Error of Moving Average :",GetLastError());
            prc=-1;
            break;
           }
         prc=maVal[1];
         if(tip==POSITION_TYPE_BUY)
           {
            prc=NormalizeDouble(prc-m_delta*_Point,_Digits);
            if(price-m_stop_level*_Point<prc) prc=0;
           }
         if(tip==POSITION_TYPE_SELL)
           {
            prc=NormalizeDouble(prc+m_delta*_Point,_Digits);
            if(price+m_stop_level*_Point>prc) prc=0;
           }
         break;
      case 6: // % of profit
         if(tip==POSITION_TYPE_BUY)
           {
            prc=NormalizeDouble(OOP+(price-OOP)/100*m_percent_profit,_Digits);
           }
         if(tip==POSITION_TYPE_SELL)
           {
            prc=NormalizeDouble(OOP-(OOP-price)/100*m_percent_profit,_Digits);
           }
         break;
      default: // in points
         if(tip==POSITION_TYPE_BUY)
           {
            prc=NormalizeDouble(price-m_stop_level*_Point,_Digits);
           }
         if(tip==POSITION_TYPE_SELL)
           {
            prc=NormalizeDouble(price+m_stop_level*_Point,_Digits);
           }
         break;
     }
   return(prc);
  }
//+------------------------------------------------------------------+
//| Select a position on the index                                   |
//+------------------------------------------------------------------+
bool SelectByIndex(const int index)
  {
   ENUM_ACCOUNT_MARGIN_MODE margin_mode=(ENUM_ACCOUNT_MARGIN_MODE)AccountInfoInteger(ACCOUNT_MARGIN_MODE);
//---
   if(margin_mode==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      ulong ticket=PositionGetTicket(index);
      if(ticket==0)
         return(false);
     }
   else
     {
      string name=PositionGetSymbol(index);
      if(name=="")
         return(false);
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
