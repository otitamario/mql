//+------------------------------------------------------------------+
//|                                      Expert_RSI_BBPct_Signal.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\SignalBollingerPercent.mqh>
#include <Expert\Signal\SignalRSI.mqh>
#include <Expert\Signal\SignalCCI.mqh>
#include <Expert\Signal\SignalMA.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingMA.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title         ="Expert_RSI_BBPct_Signal"; // Document name
ulong                    Expert_MagicNumber   =17368;                     // 
bool                     Expert_EveryTick     =false;                     // 
//--- inputs for main signal
input int                Signal_ThresholdOpen =55;                        // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose=35;                        // Signal threshold value to close [0...100]
input double             Signal_PriceLevel    =0.0;                       // Price level to execute a deal
input double             Signal_StopLevel     =250.0;                      // Stop Loss level (in points)
input double             Signal_TakeLevel     =1000.0;                      // Take Profit level (in points)
input int                Signal_Expiration    =4;                         // Expiration of pending orders (in bars)
input int                Signal__Period       =15;                        // Bollinger Bands Percent(15,...) Period of calculation
input int                Signal__Shift        =0;                         // Bollinger Bands Percent(15,...) shift
input double             Signal__Deviation    =1.5;                       // Bollinger Bands Percent(15,...) 
input ENUM_APPLIED_PRICE Signal__Applied      =PRICE_CLOSE;               // Bollinger Bands Percent(15,...) Prices series
input double             Signal__Weight       =0.7;                       // Bollinger Bands Percent(15,...) Weight [0...1.0]
input int                Signal_RSI_PeriodRSI =9;                         // Relative Strength Index(9,...) Period of calculation
input ENUM_APPLIED_PRICE Signal_RSI_Applied   =PRICE_CLOSE;               // Relative Strength Index(9,...) Prices series
input double             Signal_RSI_Weight    =0.7;                       // Relative Strength Index(9,...) Weight [0...1.0]
input int                Signal_CCI_PeriodCCI =14;                        // Commodity Channel Index(14,...) Period of calculation
input ENUM_APPLIED_PRICE Signal_CCI_Applied   =PRICE_CLOSE;               // Commodity Channel Index(14,...) Prices series
input double             Signal_CCI_Weight    =0.7;                       // Commodity Channel Index(14,...) Weight [0...1.0]
input int                Signal_MA_PeriodMA   =12;                        // Moving Average(12,0,...) Period of averaging
input int                Signal_MA_Shift      =0;                         // Moving Average(12,0,...) Time shift
input ENUM_MA_METHOD     Signal_MA_Method     =MODE_EMA;                  // Moving Average(12,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_MA_Applied    =PRICE_CLOSE;               // Moving Average(12,0,...) Prices series
input double             Signal_MA_Weight     =0.3;                       // Moving Average(12,0,...) Weight [0...1.0]
//--- inputs for trailing
input int                Trailing_MA_Period   =60;                        // Period of MA
input int                Trailing_MA_Shift    =0;                         // Shift of MA
input ENUM_MA_METHOD     Trailing_MA_Method   =MODE_EMA;                  // Method of averaging
input ENUM_APPLIED_PRICE Trailing_MA_Applied  =PRICE_CLOSE;               // Prices series
//--- inputs for money
input double             Money_FixLot_Percent =10.0;                      // Percent
input double             Money_FixLot_Lots    =1.0;                       // Fixed volume
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
//--- Creating filter CSignalBBPercent
   CSignalBBPercent *filter0=new CSignalBBPercent;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodBB(Signal__Period);
   filter0.Shift(Signal__Shift);
   filter0.Deviation(Signal__Deviation);
   filter0.Applied(Signal__Applied);
   filter0.Weight(Signal__Weight);
//--- Creating filter CSignalRSI
   CSignalRSI *filter1=new CSignalRSI;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodRSI(Signal_RSI_PeriodRSI);
   filter1.Applied(Signal_RSI_Applied);
   filter1.Weight(Signal_RSI_Weight);
//--- Creating filter CSignalCCI
   CSignalCCI *filter2=new CSignalCCI;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.PeriodCCI(Signal_CCI_PeriodCCI);
   filter2.Applied(Signal_CCI_Applied);
   filter2.Weight(Signal_CCI_Weight);
//--- Creating filter CSignalMA
   CSignalMA *filter3=new CSignalMA;
   if(filter3==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter3");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter3);
//--- Set filter parameters
   filter3.PeriodMA(Signal_MA_PeriodMA);
   filter3.Shift(Signal_MA_Shift);
   filter3.Method(Signal_MA_Method);
   filter3.Applied(Signal_MA_Applied);
   filter3.Weight(Signal_MA_Weight);
//--- Creation of trailing object
   CTrailingMA *trailing=new CTrailingMA;
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
   trailing.Period(Trailing_MA_Period);
   trailing.Shift(Trailing_MA_Shift);
   trailing.Method(Trailing_MA_Method);
   trailing.Applied(Trailing_MA_Applied);
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
     
     //Plotagem dos Indicadores e Trailing
     
     
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
