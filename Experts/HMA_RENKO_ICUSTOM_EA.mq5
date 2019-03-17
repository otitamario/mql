#property copyright "Copyright 2017, AZ-iNVEST"
#property link      "http://www.az-invest.eu"
#property version   "2.05"
#property description "Example EA showing the way to use the MedianRenko class defined in MedianRenko.mqh" 

enum BufferDataType
{
   Close = 0,
   Open = 1,
   High = 2,
   Low = 3,
   Median_Price = 4,
   Typical_Price = 5,
   Weighted_Close = 6,
};
 
enum MaMethodType
{
   Simple = 0,
   Exponential = 1,
   Smoothed = 2,
   LinearWeighted = 3,
};



//
// SHOW_INDICATOR_INPUTS *NEEDS* to be defined, if the EA needs to be *tested in MT5's backtester*
// -------------------------------------------------------------------------------------------------
// Using '#define SHOW_INDICATOR_INPUTS' will show the MedianRenko indicator's inputs 
// NOT using the '#define SHOW_INDICATOR_INPUTS' statement will read the settigns a chart with 
// the MedianRenko indicator attached.
//
input double   InpLotSize = 1;
input int      InpSLPoints = 200;
input int      InpTPPoints = 600;

input ulong    InpMagicNumber=5150;
input ulong    InpDeviationPoints = 0;
input int      InpNumberOfRetries = 50;
input int      InpBusyTimeout_ms = 1000; 
input int      InpRequoteTimeout_ms = 250;
input int HMA_Period=13;  // Moving average period
input int HMA_Shift=0;    // Horizontal shift of the average in bars

//
//  Globa variables
//

ulong currentTicket;


#define SHOW_INDICATOR_INPUTS

//
// You need to include the MedianRenko.mqh header file
//
#include <AZ-INVEST/SDK/TradeFunctions.mqh>

#include <AZ-INVEST/SDK/MedianRenko.mqh>
//
//  To use the MedainRenko indicator in your EA you need do instantiate the indicator class (MedianRenko)
//  and call the Init() method in your EA's OnInit() function.
//  Don't forget to release the indicator when you're done by calling the Deinit() method.
//  Example shown in OnInit & OnDeinit functions below:
//

MedianRenko * medianRenko;
CMarketOrder * marketOrder;

int hma_handle;
double hma_buffer[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()

{

  int Renko = iCustom(Symbol(),_Period,RENKO_INDICATOR_NAME, 
                                       s.barSizeInTicks,
                                       s.retracementFactor,
                                       s.symetricalReversals,
                                       s.showWicks,
                                       s.atrEnabled,
                                       //s.atrTimeFrame,
                                       s.atrPeriod,
                                       s.atrPercentage,
                                       s.showNumberOfDays,
                                       s.applyOffsetToFirstBar,
                                       s.offsetValue,
                                       s.resetOpenOnNewTradingDay,
                                       TopBottomPaddingPercentage,
                                       showPivots,
                                       pivotPointCalculationType,
                                       RColor,
                                       PColor,
                                       SColor,
                                       PDHColor,
                                       PDLColor,
                                       PDCColor,   
                                       showNextBarLevels,
                                       HighThresholdIndicatorColor,
                                       LowThresholdIndicatorColor,
                                       showCurrentBarOpenTime,
                                       InfoTextColor,
                                       UseSoundSignalOnNewBar,
                                       OnlySignalReversalBars,
                                       UseAlertWindow,
                                       SendPushNotifications,
                                       SoundFileBull,
                                       SoundFileBear,
                                       cis.MA1on, 
                                       cis.MA1period,
                                       cis.MA1method,
                                       cis.MA1applyTo,
                                       cis.MA1shift,
                                       cis.MA2on,
                                       cis.MA2period,
                                       cis.MA2method,
                                       cis.MA2applyTo,
                                       cis.MA2shift,
                                       cis.MA3on,
                                       cis.MA3period,
                                       cis.MA3method,
                                       cis.MA3applyTo,
                                       cis.MA3shift,
                                       cis.ShowChannel,
                                       "",
                                       cis.DonchianPeriod,
                                       cis.BBapplyTo,
                                       cis.BollingerBandsPeriod,
                                       cis.BollingerBandsDeviations,
                                       cis.SuperTrendPeriod,
                                       cis.SuperTrendMultiplier,
                                       "",
                                       DisplayAsBarChart,
                                       UsedInEA);

    hma_handle=iCustom(Symbol(),_Period,"colorhma",HMA_Period,HMA_Shift,Renko);
      ChartIndicatorAdd(ChartID(),0,Renko);

   ChartIndicatorAdd(ChartID(),0,hma_handle);
   ArraySetAsSeries(hma_buffer,true);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   
   //
   //  your custom code goes here...
   //
}

//
//  At this point you may use the renko data fetching methods in your EA.
//  Brief demonstration presented below in the OnTick() function:
//

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick()
{
  
   }