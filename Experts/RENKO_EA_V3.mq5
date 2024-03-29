//+------------------------------------------------------------------+
//|                                                     Junio_v3.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "3.00"
//+-----------------------------------+
enum Applied_price_      // Type of constant
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   // TrendFollow_2 Price 
  };


#define SHOW_INDICATOR_INPUTS

//
// You need to include the MedianRenko.mqh header file
//
#include <AZ-INVEST/SDK/TradeFunctions.mqh>

#include <AZ-INVEST/SDK/MedianRenko.mqh>
#include <SmoothAlgorithms.mqh> 

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>
#include <CustomOptimisation.mqh>
//Classes
TCustomCriterionArray  *criterion_Ptr;
CNewBar NewBar;
CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
CTimer Timer;

MedianRenko*medianRenko;

// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input Smooth_Method xMA_Method=MODE_EMA_; // Averaging method
input int TrLength1=3;   // 1 trader averaging period 
input int TrLength2=5;   // 2 trader averaging period 
input int TrLength3=8;   // 3 trader averaging period 
input int TrLength4=10;  // 4 trader averaging period 
input int TrLength5=12;  // 5 trader averaging period
input int TrLength6=15;  // 6 trader averaging period 
input int InvLength1=30; // 1 investor averaging period
input int InvLength2=35; // 2 investor averaging period
input int InvLength3=40; // 3 investor averaging period
input int InvLength4=45; // 4 investor averaging period
input int InvLength5=50; // 5 investor averaging period
input int InvLength6=60; // 6 investor averaging period
input Applied_price_ IPC=PRICE_CLOSE_; // Price constant



long curChartID;
int gmma_handle;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   
   medianRenko=new MedianRenko();
   if(medianRenko==NULL)
      return(INIT_FAILED);

   medianRenko.Init();
   if(medianRenko.GetHandle()==INVALID_HANDLE)
      return(INIT_FAILED);
   gmma_handle=iCustom(Symbol(),_Period,"MedianRenko\\MedianRenko_gmma",true,xMA_Method,TrLength1,TrLength2,TrLength3,TrLength4,TrLength5,
                       TrLength6,InvLength1,InvLength2,InvLength3,InvLength4,InvLength5,InvLength6,100,IPC,0);

   
   
   ChartIndicatorAdd(ChartID(),0,gmma_handle);
   
   
   
//---
   return(INIT_SUCCEEDED);
  }
//---------------------------------------------------------------------

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   if(medianRenko!=NULL)
     {
      medianRenko.Deinit();
      delete medianRenko;
     }

   //---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
  }