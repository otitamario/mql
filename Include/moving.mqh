//+------------------------------------------------------------------+
//|                                                       moving.mqh |
//|                        Copyright 2011, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//+------------------------------------------------------------------+
//| Класс my_expert                                                  |
//+------------------------------------------------------------------+
class my_expert
  {                                                  // Creating a class
   // Closed class members
private:
   int               ma_red_per,ma_yel_per;          // Periods of MAs
   int               ma_red_han,ma_yel_han,macd_han; // Handles
   double            sl,ts;                          // Stop orders
   double            lots;                           // Lot
   double            MA_RED[],MA_YEL[],MACD[];       // Arrays for the indicator values
   MqlTradeRequest   request;                        // Structure of a trade request
   MqlTradeResult    result;                         // Structure of a server response
                                                     // Open class members   
public:
   void              ma_expert();                                    // Constructor
   void get_lot(double lot){lots=lot;}                               // Receiving a lot  
   void get_periods(int red,int yel){ma_red_per=red;ma_yel_per=yel;} // Receiving the periods of MAs
   void get_stops(double SL,double TS){sl=SL;ts=TS;}                 // Receiving the values of stops
   void              init();                                         // Receiving the indicator values
   bool              check_for_buy();                                // Checking for buy
   bool              check_for_sell();                               // Checking for sell
   void              open_buy();                                     // Open buy
   void              open_sell();                                    // Open sell
   void              position_modify();                              // Position modification
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/* Function definition */
//---Constructor---
void my_expert::ma_expert(void)
  {
//--- Reset the values of variables
   ZeroMemory(ma_red_han);
   ZeroMemory(ma_yel_han);
   ZeroMemory(macd_han);
   ZeroMemory(request);
  }
//---The function for receiving the indicator values---
void  my_expert::init(void)
  {
   ma_red_han=iMA(_Symbol,_Period,ma_red_per,0,MODE_EMA,PRICE_CLOSE); // Handle of the slow MA
   ma_yel_han=iMA(_Symbol,_Period,ma_yel_per,0,MODE_EMA,PRICE_CLOSE); // Handle of the fast MA
   macd_han=iMACD(_Symbol,_Period,12,26,9,PRICE_CLOSE);               // Handle of MACDaka
//---Copy data into arrays and set indexing like in a time-series---
   CopyBuffer(ma_red_han,0,0,4,MA_RED);
   CopyBuffer(ma_yel_han,0,0,4,MA_YEL);
   CopyBuffer(macd_han,0,0,2,MACD);
   ArraySetAsSeries(MA_RED,true);
   ArraySetAsSeries(MA_YEL,true);
   ArraySetAsSeries(MACD,true);
  }
//---Function to check conditions to open buy---   
bool my_expert::check_for_buy(void)
  {
   init();  //Receive values of indicator buffers
/* If the fast MA has crossed the slow MA from bottom up between 2nd and 3rd bars, 
   and there was no crossing back. MACD-hist is below zero */
   if(MA_RED[3]>MA_YEL[3] && MA_RED[1]<MA_YEL[1] && MA_RED[0]<MA_YEL[0] && MACD[1]<0)
     {
      return(true);
     }
   return(false);
  }
//----Function to check conditions to open sell---
bool my_expert::check_for_sell(void)
  {
   init();  //Receive values of indicator buffers
/* If the fast MA has crossed the slow MA from up downwards between 2nd and 3rd bars,
  and there was no crossing back. MACD-hist is above zero */
   if(MA_RED[3]<MA_YEL[3] && MA_RED[1]>MA_YEL[1] && MA_RED[0]>MA_YEL[0] && MACD[1]>0)
     {
      return(true);
     }
   return(false);
  }
//---Open buy---
/* Form a standard trade request to buy */
void my_expert::open_buy(void)
  {
   request.action=TRADE_ACTION_DEAL;
   request.symbol=_Symbol;
   request.volume=lots;
   request.price=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   request.sl=request.price-sl*_Point;
   request.tp=0;
   request.deviation=10;
   request.type=ORDER_TYPE_BUY;
   request.type_filling=ORDER_FILLING_FOK;
   OrderSend(request,result);
   return;
  }
//---Open sell---
/* Form a standard trade request to sell */
void my_expert::open_sell(void)
  {
   request.action=TRADE_ACTION_DEAL;
   request.symbol=_Symbol;
   request.volume=lots;
   request.price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   request.sl=request.price+sl*_Point;
   request.tp=0;
   request.deviation=10;
   request.type=ORDER_TYPE_SELL;
   request.type_filling=ORDER_FILLING_FOK;
   OrderSend(request,result);
   return;
  }
//---Position modification---
void my_expert::position_modify(void)
  {
   if(PositionGetSymbol(0)==_Symbol)
     {     //If a position is for our symbol
      request.action=TRADE_ACTION_SLTP;
      request.symbol=_Symbol;
      request.deviation=10;
      //---If a buy position---
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
/* if distance from price to stop loss is more than trailing stop
   and the new stop loss is not less than the previous one */
         if(SymbolInfoDouble(Symbol(),SYMBOL_BID)-PositionGetDouble(POSITION_SL)>_Point*ts)
           {
            if(PositionGetDouble(POSITION_SL)<SymbolInfoDouble(Symbol(),SYMBOL_BID)-_Point*ts)
              {
               request.sl=SymbolInfoDouble(Symbol(),SYMBOL_BID)-_Point*ts;
               request.tp=PositionGetDouble(POSITION_TP);
               OrderSend(request,result);
              }
           }
        }
      //---If it is a sell position---                
      else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
/*  if distance from price to stop loss is more than the trailing stop value
   and the new stop loss is not above the previous one. 
   Or the stop loss from the moment of opening is equal to zero */
         if((PositionGetDouble(POSITION_SL)-SymbolInfoDouble(Symbol(),SYMBOL_ASK))>(_Point*ts))
           {
            if((PositionGetDouble(POSITION_SL)>(SymbolInfoDouble(Symbol(),SYMBOL_ASK)+_Point*ts)) || 
               (PositionGetDouble(POSITION_SL)==0))
              {
               request.sl=SymbolInfoDouble(Symbol(),SYMBOL_ASK)+_Point*ts;
               request.tp=PositionGetDouble(POSITION_TP);
               OrderSend(request,result);
              }
           }
        }
     }
  }
//+------------------------------------------------------------------