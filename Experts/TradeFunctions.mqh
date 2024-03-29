//+------------------------------------------------------------------+
//|                                               TradeFunctions.mqh |
//|                                     Copyright 2017, Alex Fedosov |
//|                           https://www.mql5.com/en/users/alex2356 |
//+------------------------------------------------------------------+
//|  Trading operations algorithms                                   |
//+------------------------------------------------------------------+

#property copyright "Copyright 2017, Alex Fedosov"
#property link      "https://www.mql5.com/en/users/alex2356"
#property version   "1.51"
#include <Trade\PositionInfo.mqh>
//+------------------------------------------------------------------+
//|  Calculated lots variants enumeration                            |
//+------------------------------------------------------------------+
enum MarginMode
  {
   FREEMARGIN=0,     //MM Free Margin
   BALANCE,          //MM Balance
   LOT               //Constant Lot
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CTradeBase
  {
protected:

public:
                     CTradeBase(void);
                    ~CTradeBase(void);
   CPositionInfo     m_position;                   // trade position object
   bool              BuyPositionOpen(bool BUY_Signal,const string symbol,double Money_Management,int Margin_Mode,uint deviation,int StopLoss,int Takeprofit,int MagicNumber,string  TradeComm);
   bool              SellPositionOpen(bool SELL_Signal,const string symbol,double Money_Management,int Margin_Mode,uint deviation,int StopLoss,int Takeprofit,int MagicNumber,string  TradeComm);
   bool              IsOpened(int magic_num);
   double            Dig(void);
private:

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CTradeBase::CTradeBase(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CTradeBase::~CTradeBase(void)
  {
  }
//+------------------------------------------------------------------+
//| Open a long position                                             |
//+------------------------------------------------------------------+
bool CTradeBase::BuyPositionOpen
(
 bool BUY_Signal,// deal permission flag
 const string symbol,        // deal trading pair
 double Money_Management,    // MM
 int Margin_Mode,            // lot size calculation method
 uint deviation,             // slippage
 int StopLoss,               // Stop Loss in points
 int Takeprofit,             // Take Profit in points
 int MagicNumber,            // Magic
 string  TradeComm=""        // Comment
 )
  {
//----
   if(!BUY_Signal) return(true);

   ENUM_POSITION_TYPE PosType=POSITION_TYPE_BUY;
//---- Checking for the time limit expiration for the previous deal and volume completeness
//if(!TradeTimeLevelCheck(symbol,PosType,TimeLevel)) return(true);

//---- Check for an open position
//if(PositionSelect(symbol)) return(true);

//----
  // double volume=BuyLotCount(symbol,Money_Management,Margin_Mode,StopLoss,deviation);
   double volume=Money_Management;
   
   if(volume<=0)
     {
      volume=SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN);
     }

//---- Declare structures of trade request and result of a trade request
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Declaration of the structure of a trade request checking result 
   MqlTradeCheckResult check;

//---- nulling the structures
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

   long digit;
   double point,Ask;
//----   
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit)) return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point)) return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_ASK,Ask)) return(true);

//---- Initializing structure of the MqlTradeRequest to open BUY position
   request.type   = ORDER_TYPE_BUY;
   request.price  = Ask;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
   request.magic  = MagicNumber;
   request.comment= TradeComm;

//---- Determine distance to Stop Loss in price chart units
   if(StopLoss)
     {
      if(!StopCorrect(symbol,StopLoss))return(false);
      double dStopLoss=StopLoss*point;
      request.sl=NormalizeDouble(request.price-dStopLoss,int(digit));
     }
   else
      request.sl=0.0;

//---- Determine distance to Take Profit in price chart units
   if(Takeprofit)
     {
      if(!StopCorrect(symbol,Takeprofit))return(false);
      double dTakeprofit=Takeprofit*point;
      request.tp=NormalizeDouble(request.price+dTakeprofit,int(digit));
     }
   else
      request.tp=0.0;

//----
   request.deviation=deviation;
   uint filling=(uint)SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE);

   if(filling==1)
      request.type_filling=ORDER_FILLING_FOK;
   else if(filling==2)
      request.type_filling=ORDER_FILLING_IOC;

//---- Checking correctness of a trade request
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Incorrect data structure for trade request!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment," ============ Open Buy position to ",symbol," ============");
   Print(comment);

//---- open BUY position and check the result of trade request
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else
   if(result.retcode==TRADE_RETCODE_DONE)
     {
      //TradeTimeLevelSet(symbol,PosType,TimeLevel);
      BUY_Signal=false;
      comment="";
      StringConcatenate(comment,"============ Buy position to ",symbol," opened ============");
      Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Open a short position                                            |
//+------------------------------------------------------------------+
bool CTradeBase::SellPositionOpen
(
 bool SELL_Signal,// deal permission flag
 const string symbol,        // deal trading pair
 double Money_Management,    // MM
 int Margin_Mode,            // lot size calculation method
 uint deviation,             // slippage
 int StopLoss,               // Stop Loss in points
 int Takeprofit,             // Take Profit in points
 int MagicNumber,            // Magic
 string  TradeComm=""        // Comment  
 )
//SellPositionOpen(SELL_Signal,symbol,TimeLevel,Money_Management,deviation,Margin_Mode,StopLoss,Takeprofit);
  {
//----
   if(!SELL_Signal) return(true);

   ENUM_POSITION_TYPE PosType=POSITION_TYPE_SELL;
//---- Checking for the time limit expiration for the previous deal and volume completeness
//if(!TradeTimeLevelCheck(symbol,PosType,TimeLevel)) return(true);

//---- Check for an open position
   if(PositionSelect(symbol)) return(true);

//----
  // double volume=SellLotCount(symbol,Money_Management,Margin_Mode,StopLoss,deviation);
   double volume=Money_Management;
   if(volume<=0)
     {
      Print(__FUNCTION__,"(): Invalid volume for the trade request structure");
      return(false);
     }

//---- Declare structures of trade request and result of a trade request
   MqlTradeRequest request;
   MqlTradeResult result;
//---- Declaration of the structure of a trade request checking result 
   MqlTradeCheckResult check;

//---- nulling the structures
   ZeroMemory(request);
   ZeroMemory(result);
   ZeroMemory(check);

   long digit;
   double point,Bid;
//----
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit)) return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point)) return(true);
   if(!SymbolInfoDouble(symbol,SYMBOL_BID,Bid)) return(true);

//---- Initializing structure of the MqlTradeRequest to open SELL position
   request.type   = ORDER_TYPE_SELL;
   request.price  = Bid;
   request.action = TRADE_ACTION_DEAL;
   request.symbol = symbol;
   request.volume = volume;
   request.magic=MagicNumber;
   request.comment=TradeComm;

//---- Determine distance to Stop Loss in price chart units
   if(StopLoss!=0)
     {
      if(!StopCorrect(symbol,StopLoss))return(false);
      double dStopLoss=StopLoss*point;
      request.sl=NormalizeDouble(request.price+dStopLoss,int(digit));
     }
   else request.sl=0.0;

//---- Determine distance to Take Profit in price chart units
   if(Takeprofit!=0)
     {
      if(!StopCorrect(symbol,Takeprofit))return(false);
      double dTakeprofit=Takeprofit*point;
      request.tp=NormalizeDouble(request.price-dTakeprofit,int(digit));
     }
   else request.tp=0.0;
//----
   request.deviation=deviation;
   uint filling=(uint)SymbolInfoInteger(_Symbol,SYMBOL_FILLING_MODE);

   if(filling==1)
      request.type_filling=ORDER_FILLING_FOK;
   else if(filling==2)
      request.type_filling=ORDER_FILLING_IOC;

//---- Checking correctness of a trade request
   if(!OrderCheck(request,check))
     {
      Print(__FUNCTION__,"(): Incorrect data structure for trade request!");
      Print(__FUNCTION__,"(): OrderCheck(): ",ResultRetcodeDescription(check.retcode));
      return(false);
     }

   string comment="";
   StringConcatenate(comment,"============ Open Sell position to ",symbol," ============");
   Print(comment);

//---- Open SELL position and check the result of trade request
   if(!OrderSend(request,result) || result.retcode!=TRADE_RETCODE_DONE)
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
      return(false);
     }
   else
   if(result.retcode==TRADE_RETCODE_DONE)
     {
      //TradeTimeLevelSet(symbol,PosType,TimeLevel);
      SELL_Signal=false;
      comment="";
      StringConcatenate(comment,"============ Sell position to ",symbol," opened ============");
      Print(comment);
     }
   else
     {
      Print(__FUNCTION__,"(): You can not make a deal!");
      Print(__FUNCTION__,"(): OrderSend(): ",ResultRetcodeDescription(result.retcode));
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//|  Defining decimal places                                         |
//+------------------------------------------------------------------+
double CTradeBase::Dig(void)
  {
//--- tuning for 3 or 5 digits
   long digits=SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
   int digits_adjust=1;
   digits_adjust=((digits==5 || digits==3 || digits==1)?10:1);
   return(Point()*digits_adjust);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CTradeBase:: IsOpened(int m_magic)
  {
   int pos=0;
   for(int i=PositionsTotal()-1;i>=0;i--) // returns the number of open positions
     {
      if(m_position.SelectByIndex(i))
         if(m_position.Symbol()==Symbol() && m_position.Magic()==m_magic)
            pos++;
     }

   return((pos>0)?true:false);
  }
//+===================================================================================+
//|   Other auxiliary functions                                                       |
//+===================================================================================+

//+------------------------------------------------------------------+
//| Lot size calculation for opening a long position                 |  
//+------------------------------------------------------------------+
double BuyLotCount
(
 string symbol,
 double Money_Management,
 int Margin_Mode,
 int STOPLOSS,
 uint Slippage_
 )
  {
//----
   double margin,Lot;

//--- LOT SIZE CALCULATION FOR OPENING A POSITION
   if(Money_Management<0) Lot=MathAbs(Money_Management);
   else
   switch(Margin_Mode)
     {
      //---- Lot calculation considering account free funds
      case  0:
         margin=AccountInfoDouble(ACCOUNT_FREEMARGIN)*Money_Management;
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_BUY,margin);
         break;

         //---- Lot calculation considering account balance
      case  1:
         margin=AccountInfoDouble(ACCOUNT_BALANCE)*Money_Management;
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_BUY,margin);
         break;

         //Lot calculation should be unchanged
      case  2:
        {
         Lot=MathAbs(Money_Management);
         break;
        }

      //---- Lot calculation considering account free funds by default
      default:
        {
         margin=AccountInfoDouble(ACCOUNT_FREEMARGIN)*Money_Management;
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_BUY,margin);
        }
     }

//---- lot size normalization to the nearest standard value 
   if(!LotCorrect(symbol,Lot,POSITION_TYPE_BUY)) return(-1);
//----
   return(Lot);
  }
//+------------------------------------------------------------------+
//| Lot size calculation for opening a short position                |  
//+------------------------------------------------------------------+
/*                                                                   |
 The Margin_Mode external variable determines the lot size           | 
 calculation method                                                  |
 0 - MM for an account free funds                                    |
 1 - MM for an account balance                                       |
 2 - MM for losses share from an account free funds                  |
 3 - MM based on losses on the account balance                       |
 by default - MM for an account free funds                           |
//+ - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -+
 if Money_Management is below zero,  trade function                  | 
 uses Money_Management absolute value rounded to the                 |
  nearest standard value as a lot size.                              |
*///                                                                 |
//+------------------------------------------------------------------+
double SellLotCount
(
 string symbol,
 double Money_Management,
 int Margin_Mode,
 int STOPLOSS,
 uint Slippage_
 )
// (string symbol, double Money_Management, int Margin_Mode, int STOPLOSS)
  {
//----
   double margin,Lot;

//---1+ LOT SIZE CALCULATION FOR OPENING A POSITION
   if(Money_Management<0) Lot=MathAbs(Money_Management);
   else
   switch(Margin_Mode)
     {
      //---- Lot calculation considering account free funds
      case  0:
         margin=AccountInfoDouble(ACCOUNT_FREEMARGIN)*Money_Management;
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_SELL,margin);
         break;

         //---- Lot calculation considering account balance
      case  1:
         margin=AccountInfoDouble(ACCOUNT_BALANCE)*Money_Management;
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_SELL,margin);
         break;

         //Lot calculation should be unchanged
      case  2:
        {
         Lot=MathAbs(Money_Management);
         break;
        }

      //---- Lot calculation considering account free funds by default
      default:
        {
         margin=AccountInfoDouble(ACCOUNT_FREEMARGIN)*Money_Management;
         Lot=GetLotForOpeningPos(symbol,POSITION_TYPE_SELL,margin);
        }
     }
//---1+ 

//---- lot size normalization to the nearest standard value 
   if(!LotCorrect(symbol,Lot,POSITION_TYPE_SELL)) return(-1);
//----
   return(Lot);
  }
//+------------------------------------------------------------------+
//| lot size calculation for opening a position with lot_margin      |
//+------------------------------------------------------------------+
double GetLotForOpeningPos(string symbol,ENUM_POSITION_TYPE direction,double lot_margin)
  {
//----
   double price=0.0,n_margin;
   if(direction==POSITION_TYPE_BUY)  if(!SymbolInfoDouble(symbol,SYMBOL_ASK,price)) return(0);
   if(direction==POSITION_TYPE_SELL) if(!SymbolInfoDouble(symbol,SYMBOL_BID,price)) return(0);
   if(!price) return(NULL);
   Print("marg ",OrderCalcMargin(ENUM_ORDER_TYPE(direction),symbol,1,price,n_margin));
   if(!OrderCalcMargin(ENUM_ORDER_TYPE(direction),symbol,1,price,n_margin) || !n_margin) return(0);
   double lot=lot_margin/n_margin;

//---- getting trade constants
   double LOTSTEP,MaxLot,MinLot;
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP,LOTSTEP)) return(0);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX,MaxLot)) return(0);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN,MinLot)) return(0);

//---- lot size normalization to the nearest standard value 
   lot=LOTSTEP*MathFloor(lot/LOTSTEP);

//---- checking the lot for the minimum allowable value
   if(lot<MinLot) lot=0;
//---- checking the lot for the maximum allowable value       
   if(lot>MaxLot) lot=MaxLot;
//----
   return(lot);
  }
//+------------------------------------------------------------------+
//| correction of a pending order size to an acceptable value        |
//+------------------------------------------------------------------+
bool StopCorrect(string symbol,int &Stop)
  {
//----
   long Extrem_Stop;
   if(!SymbolInfoInteger(symbol,SYMBOL_TRADE_STOPS_LEVEL,Extrem_Stop)) return(false);
   if(Stop<Extrem_Stop) Stop=int(Extrem_Stop);
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| correction of a pending order size to an acceptable value        |
//+------------------------------------------------------------------+
bool dStopCorrect
(
 string symbol,
 double &dStopLoss,
 double &dTakeprofit,
 ENUM_POSITION_TYPE trade_operation
 )
// dStopCorrect(symbol,dStopLoss,dTakeprofit,trade_operation)
  {
//----
   if(!dStopLoss && !dTakeprofit) return(true);

   if(dStopLoss<0)
     {
      Print(__FUNCTION__,"(): A negative value stoploss!");
      return(false);
     }

   if(dTakeprofit<0)
     {
      Print(__FUNCTION__,"(): A negative value takeprofit!");
      return(false);
     }
//---- 
   int Stop;
   long digit;
   double point,dStop,ExtrStop,ExtrTake;

//---- getting the minimum distance to a pending order 
   Stop=0;
   if(!StopCorrect(symbol,Stop))return(false);
//----   
   if(!SymbolInfoInteger(symbol,SYMBOL_DIGITS,digit)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_POINT,point)) return(false);
   dStop=Stop*point;

//---- correction of a pending order size for a long position
   if(trade_operation==POSITION_TYPE_BUY)
     {
      double Ask;
      if(!SymbolInfoDouble(symbol,SYMBOL_ASK,Ask)) return(false);

      ExtrStop=NormalizeDouble(Ask-dStop,int(digit));
      ExtrTake=NormalizeDouble(Ask+dStop,int(digit));

      if(dStopLoss>ExtrStop && dStopLoss) dStopLoss=ExtrStop;
      if(dTakeprofit<ExtrTake && dTakeprofit) dTakeprofit=ExtrTake;
     }

//---- correction of a pending order size for a short position
   if(trade_operation==POSITION_TYPE_SELL)
     {
      double Bid;
      if(!SymbolInfoDouble(symbol,SYMBOL_BID,Bid)) return(false);

      ExtrStop=NormalizeDouble(Bid+dStop,int(digit));
      ExtrTake=NormalizeDouble(Bid-dStop,int(digit));

      if(dStopLoss<ExtrStop && dStopLoss) dStopLoss=ExtrStop;
      if(dTakeprofit>ExtrTake && dTakeprofit) dTakeprofit=ExtrTake;
     }
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| Returning a string result of a trading operation by its code     |
//+------------------------------------------------------------------+
string ResultRetcodeDescription(int retcode)
  {
   string str;
//----
   switch(retcode)
     {
      case TRADE_RETCODE_REQUOTE: str="Requote"; break;
      case TRADE_RETCODE_REJECT: str="Request rejected"; break;
      case TRADE_RETCODE_CANCEL: str="Request canceled by trader"; break;
      case TRADE_RETCODE_PLACED: str="Order placed"; break;
      case TRADE_RETCODE_DONE: str="Request completed"; break;
      case TRADE_RETCODE_DONE_PARTIAL: str="Only part of the request was completed"; break;
      case TRADE_RETCODE_ERROR: str="Request processing error"; break;
      case TRADE_RETCODE_TIMEOUT: str="Request canceled by timeout";break;
      case TRADE_RETCODE_INVALID: str="Invalid request"; break;
      case TRADE_RETCODE_INVALID_VOLUME: str="Invalid volume in the request"; break;
      case TRADE_RETCODE_INVALID_PRICE: str="Invalid price in the request"; break;
      case TRADE_RETCODE_INVALID_STOPS: str="Invalid stops in the request"; break;
      case TRADE_RETCODE_TRADE_DISABLED: str="Trade is disabled"; break;
      case TRADE_RETCODE_MARKET_CLOSED: str="Market is closed"; break;
      case TRADE_RETCODE_NO_MONEY: str="There is not enough money to complete the request"; break;
      case TRADE_RETCODE_PRICE_CHANGED: str="Prices changed"; break;
      case TRADE_RETCODE_PRICE_OFF: str="There are no quotes to process the request"; break;
      case TRADE_RETCODE_INVALID_EXPIRATION: str="Invalid order expiration date in the request"; break;
      case TRADE_RETCODE_ORDER_CHANGED: str="Order state changed"; break;
      case TRADE_RETCODE_TOO_MANY_REQUESTS: str="Too frequent requests"; break;
      case TRADE_RETCODE_NO_CHANGES: str="No changes in request"; break;
      case TRADE_RETCODE_SERVER_DISABLES_AT: str="Autotrading disabled by server"; break;
      case TRADE_RETCODE_CLIENT_DISABLES_AT: str="Autotrading disabled by client terminal"; break;
      case TRADE_RETCODE_LOCKED: str="Request locked for processing"; break;
      case TRADE_RETCODE_FROZEN: str="Order or position frozen"; break;
      case TRADE_RETCODE_INVALID_FILL: str="Invalid order filling type"; break;
      case TRADE_RETCODE_CONNECTION: str="No connection with the trade server"; break;
      case TRADE_RETCODE_ONLY_REAL: str="Operation is allowed only for live accounts"; break;
      case TRADE_RETCODE_LIMIT_ORDERS: str="The number of pending orders has reached the limit"; break;
      case TRADE_RETCODE_LIMIT_VOLUME: str="The volume of orders and positions for the symbol has reached the limit"; break;
      default: str="Unknown result";
     }
//----
   return(str);
  }
//+------------------------------------------------------------------+
//| Correction of a lot size to the nearest acceptable value         |
//+------------------------------------------------------------------+
bool LotCorrect
(
 string symbol,
 double &Lot,
 ENUM_POSITION_TYPE trade_operation
 )
//LotCorrect(string symbol, double& Lot, ENUM_POSITION_TYPE trade_operation)
  {
//---- getting calculation data   
   double Step,MaxLot,MinLot;
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP,Step)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX,MaxLot)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN,MinLot)) return(false);

//---- lot size normalization to the nearest standard value 
   Lot=Step*MathFloor(Lot/Step);

//---- checking the lot for the minimum allowable value
   if(Lot<MinLot) Lot=MinLot;
//---- checking the lot for the maximum allowable value       
   if(Lot>MaxLot) Lot=MaxLot;

//---- checking the funds sufficiency
   if(!LotFreeMarginCorrect(symbol,Lot,trade_operation))return(false);
//----
   return(true);
  }
//+------------------------------------------------------------------+
//| limitation of a lot size by a deposit capacity                   |
//+------------------------------------------------------------------+
bool LotFreeMarginCorrect
(
 string symbol,
 double &Lot,
 ENUM_POSITION_TYPE trade_operation
 )
//(string symbol, double& Lot, ENUM_POSITION_TYPE trade_operation)
  {
//---- checking the funds sufficiency
   double freemargin=AccountInfoDouble(ACCOUNT_FREEMARGIN);
   if(freemargin<=0) return(false);

//---- getting calculation data   
   double Step,MaxLot,MinLot;
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP,Step)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX,MaxLot)) return(false);
   if(!SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN,MinLot)) return(false);

   double ExtremLot=GetLotForOpeningPos(symbol,trade_operation,freemargin);
//---- lot size normalization to the nearest standard value 
   ExtremLot=Step*MathFloor(ExtremLot/Step);

   if(ExtremLot<MinLot) return(false); // funds are insufficient even for a minimum lot!
   if(Lot>ExtremLot) Lot=ExtremLot; // cutting the lot size down to the deposit capacity!
   if(Lot>MaxLot) Lot=MaxLot; // cutting the lot size down to the maximum permissible one
//----
   return(true);
  }
//+------------------------------------------------------------------+
