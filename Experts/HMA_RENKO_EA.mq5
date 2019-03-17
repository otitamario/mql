#property copyright "Copyright 2017, AZ-iNVEST"
#property link      "http://www.az-invest.eu"
#property version   "2.05"
#property description "Example EA showing the way to use the MedianRenko class defined in MedianRenko.mqh" 

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

input ulong    Magic_Number=5150;
input ulong    InpDeviationPoints = 0;
input int      InpNumberOfRetries = 50;
input int      InpBusyTimeout_ms = 1000; 
input int      InpRequoteTimeout_ms = 250;
input int HMA_Period=13;  // Moving average period
input int HMA_Shift=0;    // Horizontal shift of the average in bars
input ENUM_APPLIED_PRICE InpApplyToPrice= PRICE_CLOSE; // Apply to
input bool StopCandle=true;//Usar Stop Candle
input double DistSTOPCandle=60;//Distancia para Candle Anterior
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
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>
#include <CustomOptimisation.mqh>
//Classes
CAccountInfo myaccount;
CDealInfo mydeal; 
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
CTimer Timer;

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
double stop_movel,ponto,ticksize,digits,renko_low,renko_high;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  mysymbol.Name(Symbol());
 mytrade.SetExpertMagicNumber(Magic_Number);

if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      Print("ORDER_FILLING_FOK");
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      Print("ORDER_FILLING_IOC");
   else
      Print("ORDER_FILLING_RETURN");
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      mytrade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      mytrade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      mytrade.SetTypeFilling(ORDER_FILLING_RETURN);
  ponto=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  ticksize=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE);
  digits =(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
 

   medianRenko = new MedianRenko(); 
   if(medianRenko == NULL)
      return(INIT_FAILED);
   
   medianRenko.Init();
   if(medianRenko.GetHandle() == INVALID_HANDLE)
      return(INIT_FAILED);
      
   CMarketOrderParameters params;
   {
      params.m_async_mode = false;
      params.m_magic = Magic_Number;
      params.m_deviation = InpDeviationPoints;
      params.m_type_filling = ORDER_FILLING_FOK;
      
      params.numberOfRetries = InpNumberOfRetries;
      params.busyTimeout_ms = InpBusyTimeout_ms; 
      params.requoteTimeout_ms = InpRequoteTimeout_ms;         
   }
   marketOrder = new CMarketOrder(params);
     
   
   //
   //  your custom code goes here...
   //
hma_handle=iCustom(Symbol(),_Period,"MedianRenko\\MedianRenko_ColorHMA",HMA_Period,HMA_Shift,InpApplyToPrice,true);
ChartIndicatorAdd(ChartID(),0,hma_handle);

   ArraySetAsSeries(hma_buffer,true);
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   if(medianRenko != NULL)
   {
      medianRenko.Deinit();
      delete medianRenko;
   }
    if(marketOrder != NULL)
   {
      delete marketOrder;
   }
   
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
  
   // It is considered good trading & EA coding practice to perform calculations
   // when a new bar is fully formed. 
   // The IsNewBar() method is used for checking if a new renko bar has formed 
   //
   
   if(medianRenko.IsNewBar())
   {

      
      
      MqlRates RenkoRatesInfoArray[];  // This array will store the MqlRates data for renkos
      int startAtBar = 0;                  // get values starting from the last completed bar.
      int numberOfBars = 3;                // gat a total of 3 MqlRates values (for 3 bars starting from bar 0 (current uncompleted))
      
      
         //
         // Read signal bar's time for optional debug log
         //

               if(medianRenko.GetMqlRates(RenkoRatesInfoArray,startAtBar,numberOfBars))
      {         
         //
         //  Check if a renko reversal bar has formed
         //
       
         string infoString;
         
         if((RenkoRatesInfoArray[1].open < RenkoRatesInfoArray[1].close) &&
            (RenkoRatesInfoArray[2].open > RenkoRatesInfoArray[2].close))
         {
            // bullish reversal
            infoString = "Previous bar formed bullish reversal";
         }
         else if((RenkoRatesInfoArray[1].open > RenkoRatesInfoArray[1].close) &&
            (RenkoRatesInfoArray[2].open < RenkoRatesInfoArray[2].close))
         {
            // bearish reversal
            infoString = "Previous bar formed bearish reversal";
         }
         else
         {
            infoString = "";
         }
      
         //
         //  Output some data to chart
         //
      
         Comment("\nNew bar opened on "+(string)RenkoRatesInfoArray[0].time+
                 "\nPrevious bar OPEN price:"+DoubleToString(RenkoRatesInfoArray[1].open,_Digits)+", bar opened on "+(string)RenkoRatesInfoArray[1].time+
                 "\n"+infoString+ 
                 "\n");
      }
         //
         //
       
               
            //
            // Trade signal on the SuperTrend indicator
            // Open trade only if there are currntly no active trades
            //
           if(CopyBuffer(hma_handle,0,0,3,hma_buffer)<=0)Print("ERRO HMA buffer");
  
            
               if(hma_buffer[1]>hma_buffer[2]&&!Buy_opened())
               {
                 if(Sell_opened())marketOrder.Close(currentTicket);
            
                  if(marketOrder.Long(_Symbol,InpLotSize,InpSLPoints,InpTPPoints))
                     Print("Long position opened.");
               }  
               else if(hma_buffer[1]<hma_buffer[2]&&!Sell_opened())
               {
                  if(Buy_opened())marketOrder.Close(currentTicket);
                  if(marketOrder.Short(_Symbol,InpLotSize,InpSLPoints,InpTPPoints))
                     Print("Short position opened.");
               }
            

            
    if(StopCandle)
{
if(medianRenko.GetMqlRates(RenkoRatesInfoArray,0,2))
{
renko_low=RenkoRatesInfoArray[1].low;
renko_high=RenkoRatesInfoArray[1].high;
}

stop_movel=NormalizeDouble(DistSTOPCandle*ponto,digits);
if (Buy_opened())
{
double curSTP=myposition.StopLoss();
double curTake=myposition.TakeProfit();
double stp_compra=renko_low-stop_movel;
if (stp_compra>curSTP)mytrade.PositionModify(Symbol(),stp_compra,curTake);

}




if (Sell_opened())
{
double curSTP=myposition.StopLoss();
double curTake=myposition.TakeProfit();
double stp_venda=renko_high+stop_movel;
if (stp_venda<curSTP)mytrade.PositionModify(Symbol(),stp_venda,curTake);

}

}            
      
      
   }//Fim NewBarRenko 
}

//
// Function determines the trade signal on the SuperTrend indicator
//


bool Buy_opened()
{
if(myposition.SelectByMagic(Symbol(),Magic_Number)==true && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         return(true);  //It is a Buy
        }
      else return(false); 
}

bool Sell_opened()
{
if(myposition.SelectByMagic(Symbol(),Magic_Number)==true && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         return(true);  //It is a Sell
        }
      else return(false); 
}

bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=mysymbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
