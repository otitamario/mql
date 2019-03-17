//+------------------------------------------------------------------+
//|                                     ExpertSignalZigZagMedias.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\MySignals\SignalDeltaZZ.mqh>
#include <Expert\Signal\SignalMA.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingFixedPips.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title                  ="ExpertSignalZigZagMedias"; // Document name
ulong                    Expert_MagicNumber            =21305;                      // 
bool                     Expert_EveryTick              =false;                      // 
//--- inputs for main signal
input int                Signal_ThresholdOpen          =10;                         // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose         =10;                         // Signal threshold value to close [0...100]
input double             Signal_PriceLevel             =0.0;                        // Price level to execute a deal
input double             Signal_StopLevel              =50.0;                       // Stop Loss level (in points)
input double             Signal_TakeLevel              =50.0;                       // Take Profit level (in points)
input int                Signal_Expiration             =4;                          // Expiration of pending orders (in bars)
input int                Signal_DeltaZZ_SM_setAppPrice =1;                          // DeltaZZ Signal Module(1,1,...) Applied price: 0 - Close
input int                Signal_DeltaZZ_SM_setRevMode  =1;                          // DeltaZZ Signal Module(1,1,...) Reversal mode: 0 - Pips
input int                Signal_DeltaZZ_SM_setPips     =300;                        // DeltaZZ Signal Module(1,1,...) Reverse in pips
input double             Signal_DeltaZZ_SM_setPercent  =0.42;                       // DeltaZZ Signal Module(1,1,...) Reverse in percent
input int                Signal_DeltaZZ_SM_setLevels   =2;                          // DeltaZZ Signal Module(1,1,...) Peaks number
input double             Signal_DeltaZZ_SM_setPattern0 =50;                         // DeltaZZ Signal Module(1,1,...) Trend direction according to DZZ
input double             Signal_DeltaZZ_SM_Weight      =1.0;                        // DeltaZZ Signal Module(1,1,...) Weight [0...1.0]
input int                Signal_0_MA_PeriodMA          =10;                         // Moving Average(10,0,...) Period of averaging
input int                Signal_0_MA_Shift             =0;                          // Moving Average(10,0,...) Time shift
input ENUM_MA_METHOD     Signal_0_MA_Method            =MODE_EMA;                   // Moving Average(10,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_0_MA_Applied           =PRICE_CLOSE;                // Moving Average(10,0,...) Prices series
input double             Signal_0_MA_Weight            =1.0;                        // Moving Average(10,0,...) Weight [0...1.0]
input int                Signal_1_MA_PeriodMA          =20;                         // Moving Average(20,0,...) Period of averaging
input int                Signal_1_MA_Shift             =0;                          // Moving Average(20,0,...) Time shift
input ENUM_MA_METHOD     Signal_1_MA_Method            =MODE_EMA;                   // Moving Average(20,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_1_MA_Applied           =PRICE_CLOSE;                // Moving Average(20,0,...) Prices series
input double             Signal_1_MA_Weight            =1.0;                        // Moving Average(20,0,...) Weight [0...1.0]
//--- inputs for trailing
input int                Trailing_FixedPips_StopLevel  =150;                        // Stop Loss trailing level (in points)
input int                Trailing_FixedPips_ProfitLevel=100;                        // Take Profit trailing level (in points)
//--- inputs for money
input double             Money_FixLot_Percent          =10.0;                       // Percent
input double             Money_FixLot_Lots             =1.0;                        // Fixed volume
//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CExpert ExtExpert;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Expert_MagicNumber))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
//--- Creating filter CSignalDeltaZZ
   CSignalDeltaZZ *filter0=new CSignalDeltaZZ;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.setAppPrice(Signal_DeltaZZ_SM_setAppPrice);
   filter0.setRevMode(Signal_DeltaZZ_SM_setRevMode);
   filter0.setPips(Signal_DeltaZZ_SM_setPips);
   filter0.setPercent(Signal_DeltaZZ_SM_setPercent);
   filter0.setLevels(Signal_DeltaZZ_SM_setLevels);
   filter0.setPattern0(Signal_DeltaZZ_SM_setPattern0);
   filter0.Weight(Signal_DeltaZZ_SM_Weight);
//--- Creating filter CSignalMA
   CSignalMA *filter1=new CSignalMA;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodMA(Signal_0_MA_PeriodMA);
   filter1.Shift(Signal_0_MA_Shift);
   filter1.Method(Signal_0_MA_Method);
   filter1.Applied(Signal_0_MA_Applied);
   filter1.Weight(Signal_0_MA_Weight);
//--- Creating filter CSignalMA
   CSignalMA *filter2=new CSignalMA;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.PeriodMA(Signal_1_MA_PeriodMA);
   filter2.Shift(Signal_1_MA_Shift);
   filter2.Method(Signal_1_MA_Method);
   filter2.Applied(Signal_1_MA_Applied);
   filter2.Weight(Signal_1_MA_Weight);
//--- Creation of trailing object
   CTrailingFixedPips *trailing=new CTrailingFixedPips;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
   trailing.StopLevel(Trailing_FixedPips_StopLevel);
   trailing.ProfitLevel(Trailing_FixedPips_ProfitLevel);
//--- Creation of money object
   CMoneyFixedLot *money=new CMoneyFixedLot;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
   money.Percent(Money_FixLot_Percent);
   money.Lots(Money_FixLot_Lots);
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
