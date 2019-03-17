//+------------------------------------------------------------------+
//|                                                Expert_ADX_BB.mq5 |
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
#include <Expert\Signal\SignalBBPerc_ADX.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingMA.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string             Expert_Title               ="Expert_ADX_BB"; // Document name
ulong                    Expert_MagicNumber         =31460;           // 
bool                     Expert_EveryTick           =false;           // 
//--- inputs for main signal
input int                Signal_ThresholdOpen       =10;              // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose      =10;              // Signal threshold value to close [0...100]
input double             Signal_PriceLevel          =0.0;             // Price level to execute a deal
input double             Signal_StopLevel           =250.0;            // Stop Loss level (in points)
input double             Signal_TakeLevel           =1000.0;            // Take Profit level (in points)
input int                Signal_Expiration          =4;               // Expiration of pending orders (in bars)
input int                Signal_BBPerc_ADX_PeriodBB =18;              // Bollinger Bands Percent and ADX Period of calculation
input int                Signal_BBPerc_ADX_Shift    =0;               // Bollinger Bands Percent and ADX shift
input double             Signal_BBPerc_ADX_Deviation=1.5;             // Bollinger Bands Percent and ADX deviation
input ENUM_APPLIED_PRICE Signal_BBPerc_ADX_Applied  =PRICE_CLOSE;     // Bollinger Bands Percent and ADX Prices series
input int                Signal_BBPerc_ADX_PeriodADX=14;              // Bollinger Bands Percent and ADX Period of calculation
input double             Signal_BBPerc_ADX_MIN_ADX  =20.0;            // Bollinger Bands Percent and ADX ADX minimo
input int                Signal_BBPerc_ADX_Pattern_0=10;              // Bollinger Bands Percent and ADX peso padrao 0
input int                Signal_BBPerc_ADX_Pattern_1=30;              // Bollinger Bands Percent and ADX peso padrao 1
input int                Signal_BBPerc_ADX_Pattern_2=30;              // Bollinger Bands Percent and ADX peso padrao 2
input int                Signal_BBPerc_ADX_Pattern_3=30;              // Bollinger Bands Percent and ADX peso padrao 3
input int                Signal_BBPerc_ADX_Pattern_4=30;              // Bollinger Bands Percent and ADX peso padrao 4
input double             Signal_BBPerc_ADX_Weight   =1.0;             // Bollinger Bands Percent and ADX Weight [0...1.0]
//--- inputs for trailing
input int                Trailing_MA_Period         =60;              // Period of MA
input int                Trailing_MA_Shift          =0;               // Shift of MA
input ENUM_MA_METHOD     Trailing_MA_Method         =MODE_EMA;        // Method of averaging
input ENUM_APPLIED_PRICE Trailing_MA_Applied        =PRICE_CLOSE;     // Prices series
//--- inputs for money
input double             Money_FixLot_Percent       =10.0;            // Percent
input double             Money_FixLot_Lots          =1.0;            // Fixed volume
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
//--- Creating filter CSignalBBPerc_ADX
   CSignalBBPerc_ADX *filter0=new CSignalBBPerc_ADX;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodBB(Signal_BBPerc_ADX_PeriodBB);
   filter0.Shift(Signal_BBPerc_ADX_Shift);
   filter0.Deviation(Signal_BBPerc_ADX_Deviation);
   filter0.Applied(Signal_BBPerc_ADX_Applied);
   filter0.PeriodADX(Signal_BBPerc_ADX_PeriodADX);
   filter0.MIN_ADX(Signal_BBPerc_ADX_MIN_ADX);
   filter0.Pattern_0(Signal_BBPerc_ADX_Pattern_0);
   filter0.Pattern_1(Signal_BBPerc_ADX_Pattern_1);
   filter0.Pattern_2(Signal_BBPerc_ADX_Pattern_2);
   filter0.Pattern_3(Signal_BBPerc_ADX_Pattern_3);
   filter0.Pattern_4(Signal_BBPerc_ADX_Pattern_4);
   filter0.Weight(Signal_BBPerc_ADX_Weight);
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
