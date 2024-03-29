//+------------------------------------------------------------------+
//|                                                Delta_article.mq5 |
//|                                                         Tapochun |
//|                           https://www.mql5.com/en/users/tapochun |
//+------------------------------------------------------------------+
#property copyright "Tapochun"
#property link      "https://www.mql5.com/en/users/tapochun"
#property version   "1.00"
#property indicator_separate_window
#property indicator_plots 3
#property indicator_buffers 4
//+------------------------------------------------------------------+
//| Include files																	   |
//+------------------------------------------------------------------+
#include <Ticks_article.mqh>
//+------------------------------------------------------------------+
//| Input parameters																   |
//+------------------------------------------------------------------+
sinput    datetime          inpHistoryDate=0;                     // History start time
sinput    color             inpColorUp=clrDodgerBlue;             // Buy delta color
sinput    color             inpColorDn=clrRed;                    // Sell delta color
sinput    uchar             inpDeltaWidth=2;                      // Delta column width		
sinput    bool                inpLog=false;                           // Keep the log?
//+------------------------------------------------------------------+
//| Global variables															      |
//+------------------------------------------------------------------+
//--- Indicator buffers
double bufDelta[];               // Delta values 
double bufDeltaColor[];          // Delta color values
double bufBuyVol[];               // Buy volume on a candle
double bufSellVol[];               // Sell volume on a candle
//--- Object for working with ticks 
CTicks _ticks(_Symbol,_Period,COPY_TICKS_TRADE,-1,-1,UINT_MAX,0,inpLog);
//--- Repeated control parameters
bool _repeatedControl = false;   // Flag
int _controlNum = WRONG_VALUE;   // Candle index
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- Check the indicator input parameters
   if(!CheckInputParameters())
      return( INIT_PARAMETERS_INCORRECT );
//--- Set the indicator parameters
   if(!SetIndicatorParameters() )            // If unsuccessful
      return( INIT_PARAMETERS_INCORRECT );   // Exit
//---
   return( INIT_SUCCEEDED );
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- Check for the first launch
   if(prev_calculated>0) // If not the first launch
     {
      //--- 1. Check the new bar formation
      if(rates_total>prev_calculated) // In case of a new bar
        {
         //--- Initialize the rates_total-1 buffer indices with empty values
         BuffersIndexInitialize(rates_total-1,EMPTY_VALUE);
         //--- 2. Check if the volume on the rates_total-2 bar should be tracked
         if(_repeatedControl && _controlNum==rates_total-2)
           {
            //--- 3. Performing a re-check
            RepeatedControl(_controlNum,time[_controlNum]);
           }
         //--- 4. Reset re-check values
         _repeatedControl=false;
         _controlNum=WRONG_VALUE;
        }
      //--- 5. Download new ticks
      if(!_ticks.GetTicks() )                  // If unsuccessful
         return( prev_calculated );            // Exit with the error
      //--- 6. Remember the time of the obtained history's last tick
      _ticks.SetFrom();
      //--- 7. Calculation
      CalculateCurrentBar(false,rates_total,time,volume);
     }
   else                                        // If the first launch
     {
      //--- 1. Initialize the indicator buffers by initial values
      BuffersInitialize(EMPTY_VALUE);
      //--- 2. Reset the values of repeated control parameters
      _repeatedControl=false;
      _controlNum=WRONG_VALUE;
      //--- 3. Reset time of the bar the ticks are saved into (clicking the Refresh button)
      _ticks.SetTime(0);
      //--- 4. Set the moment of starting the download of ticks of the formed bars
      _ticks.SetFrom(inpHistoryDate);
      //--- 5. Check the download start moment
      if(_ticks.GetFrom()<=0) // If the moment is not defined
         return(0);                           // Exit
      //--- 6. Set the moment of completing the download of the formed bars history
      _ticks.SetTo(long(time[rates_total-1]*MS_KOEF-1));
      //--- 7. Download history by formed bars
      if(!_ticks.GetTicksRange())             // If unsuccessful
         return(0);                           // Exit with the error
      //--- 8. Calculating history on formed bars
      CalculateHistoryBars(rates_total,time,volume);
      //--- 9. Reset time of the bar the ticks are saved into
      _ticks.SetTime(0);
      //--- 10. Set the moment of starting the download of the last bar ticks
      _ticks.SetFrom(long(time[rates_total-1]*MS_KOEF));
      //--- 11. Set the moment the ticks of the last bar finish downloading
      _ticks.SetTo(long(TimeCurrent()*MS_KOEF));
      //--- 12. Download the current bar history
      if(!_ticks.GetTicksRange())             // If unsuccessful
         return(0);                           // Exit with the error
      //--- 13. Reset the moment copying ends
      _ticks.SetTo(ULONG_MAX);
      //--- 14. Remember the time of the obtained history's last tick
      _ticks.SetFrom();
      //--- 15. Current bar calculation
      CalculateCurrentBar(true,rates_total,time,volume);
      //--- 16. Set the number of ticks for subsequent copying in real time
      _ticks.SetCount(4000);
     }
//---
   return( rates_total );
  }
//+------------------------------------------------------------------+
//| Function of calculating the current candle					         |
//+------------------------------------------------------------------+
void CalculateCurrentBar(const bool firstLaunch,// Function first launch flag
                         const int rates_total,// Number of calculated bars
                         const datetime& time[],   // Array of bar open times 
                         const long& volume[]      // Array of real volume values
                         )
  {
//--- Total volumes
   static long sumVolBuy=0;
   static long sumVolSell=0;
//--- Bar index for writing to the buffer
   static int bNum=WRONG_VALUE;
//--- Check the first launch flag
   if(firstLaunch) // In case of the first launch
     {
      //--- Reset static parameters
      sumVolBuy=0;
      sumVolSell=0;
      bNum=WRONG_VALUE;
     }
//--- Get the index of the penultimate tick in the array
   const int limit=_ticks.GetSize()-1;
//--- 'limit' tick time
   const ulong limitTime=_ticks.GetFrom();
//--- Loop on all ticks (except the last one)
   for(int i=0; i<limit && !IsStopped(); i++)
     {
      //--- 1. Compare the i th tick time with the limit tick one (check the loop completion)
      if( _ticks.GetTickTimeMs( i ) == limitTime )          // If the tick time is equal to the limit tick one
         return;                                            // Exit
      //--- 2. Check if the candle not present on the chart starts forming
      if(_ticks.GetTickTime(i)>=time[rates_total-1]+PeriodSeconds())                // If the candle started forming
        {
         //--- Check if the log is maintained
         if(inpLog)
            Print(__FUNCTION__,": ATTENTION! Future tick ["+GetMsToStringTime(_ticks.GetTickTimeMs(i))+"]. Tick time "+TimeToString(_ticks.GetTickTime(i))+
                  ", time[ rates_total-1 ]+PerSec() = "+TimeToString(time[rates_total-1]+PeriodSeconds()));
         //--- 2.1. Set (correct) the time of the next tick request
         _ticks.SetFrom(_ticks.GetTickTimeMs(i));
         //--- Exit
         return;
        }
      //--- 3. Define the candle the ticks are saved to
      if(_ticks.IsNewCandle(i))                         // If the next candle starts forming
        {
         //--- 3.1. Check if the formed (complete) candle index is saved
         if(bNum>=0) // If the index is saved
           {
            //--- Check if the volume values are saved
            if(sumVolBuy>0 || sumVolSell>0) // If all parameters are saved
              {
               //--- 3.1.1. Manage the total candle volume
               VolumeControl(true,bNum,volume[bNum],time[bNum],sumVolBuy,sumVolSell);
              }
           }
         //--- 3.2. Reset the previous candle volumes
         sumVolBuy=0;
         sumVolSell=0;
         //--- 3.3. Remember the current candle index
         bNum=rates_total-1;
        }
      //--- 4. Add the volume on a tick to the necessary component
      AddVolToSum(_ticks.GetTick(i),sumVolBuy,sumVolSell);
      //--- 5. Enter the values into the buffers
      DisplayValues(bNum,sumVolBuy,sumVolSell,__LINE__);
     }
  }
//+------------------------------------------------------------------+
//| Function for calculating formed history bars                     |
//+------------------------------------------------------------------+
bool CalculateHistoryBars(const int rates_total,// Number of calculated bars
                          const datetime& time[],   // Array of bar open times 
                          const long& volume[]      // Array of real volume values
                          )
  {
//--- Total volumes
   long sumVolBuy=0;
   long sumVolSell=0;
//--- Bar index for writing to the buffer
   int bNum=WRONG_VALUE;
//--- Get the number of ticks in the array
   const int limit=_ticks.GetSize();
//--- Loop by all ticks
   for(int i=0; i<limit && !IsStopped(); i++)
     {
      //--- Define the candle the ticks are saved to
      if(_ticks.IsNewCandle(i))                         // If the next candle starts forming
        {
         //--- Check if the formed (complete) candle index is saved
         if(bNum>=0) // If the index is saved
           {
            //--- Check if the volume values are saved
            if(sumVolBuy>0 || sumVolSell>0) // If all parameters are saved
              {
               //--- Manage the total candle volume
               VolumeControl(false,bNum,volume[bNum],time[bNum],sumVolBuy,sumVolSell);
              }
            //--- Enter the values into the buffers
            DisplayValues(bNum,sumVolBuy,sumVolSell,__LINE__);
           }
         //--- Reset the previous candle volumes
         sumVolBuy=0;
         sumVolSell=0;
         //--- Set the candle index according to its opening time
         bNum=_ticks.GetNumByTime(false);
         //--- Check if the index is correct
         if(bNum>=rates_total || bNum<0) // If the index is incorrect	
           {
            //--- Exit without calculating history
            return( false );
           }
        }
      //--- Add the volume on a tick to the necessary component
      AddVolToSum(_ticks.GetTick(i),sumVolBuy,sumVolSell);
     }
//--- Check if the volumes values of the last formed candle are saved
   if(sumVolBuy>0 || sumVolSell>0) // If all parameters are saved
     {
      //--- Manage the total candle volume
      VolumeControl(false,bNum,volume[bNum],time[bNum],sumVolBuy,sumVolSell);
     }
//--- Enter the values into the buffers
   DisplayValues(bNum,sumVolBuy,sumVolSell,__LINE__);
//--- Calculation complete
   return( true );
  }
//+------------------------------------------------------------------+
//| Repeated volume control														|
//+------------------------------------------------------------------+
bool RepeatedControl(const int num,// Tracked candle index
                     const datetime time           // Candle open time
                     )
  {
//--- Create an object for working with ticks
   CTicks cTicks(_Symbol,_Period,COPY_TICKS_TRADE,time*1000,(time+PeriodSeconds())*1000-1);
//--- Download history
   if(!cTicks.GetTicksRange()) // If unsuccessful
      return(false);                                 // Exit with the error
//--- Delta recalculation and repeated control 
   if( CandleRecalculation( cTicks,num, time ) )     // If the control is passed
      return( true );                                // Return 'true'
   else                                              // Otherwise
   return(false);                                 // Return 'false'
  }
//+------------------------------------------------------------------+
//| num candle delta recalculation											   |
//+------------------------------------------------------------------+
bool CandleRecalculation(const CTicks &ticks,      // Candle ticks
                         const int num,            // Candle index
                         const datetime time         // Candle time
                         )
  {
//--- Reference volume
   long controlVolume[1];
//--- Get the volume reference value
   if(!GetVolumeData(_Symbol,_Period,time,1,controlVolume)) // If no data are obtained
      return(false);                                                   // Exit with the error
//--- Get the index of the last tick in the array
   const int limit=ticks.GetSize()-1;
//--- Total volumes
   long sumVolBuy=0;
   long sumVolSell=0;
//--- Loop on all ticks (including the last one)
   for(int i=0; i<=limit; i++)
     {
      //--- Add the volume on a tick to the appropriate sum
      AddVolToSum(ticks.GetTick(i),sumVolBuy,sumVolSell);
     }
//--- Display chart values
   DisplayValues(num,sumVolBuy,sumVolSell,__LINE__);
//--- Repeated volume control
   if(controlVolume[0]!=sumVolBuy+sumVolSell) // If control is NOT passed
     {
      //--- Check if the log is maintained
      if(inpLog)
         Print(__FUNCTION__,": Repeated control "+TimeToString(time)+" NOT passed! (",controlVolume[0]," = ",sumVolBuy," + ",sumVolSell,")");
      //--- Return 'false'
      return( false );
     }
   else                                            // If the control is passed
   return( true );
  }
//+------------------------------------------------------------------+
//| Get rates data															      |
//+------------------------------------------------------------------+
bool GetVolumeData(const string symbol,// Symbol
                   const ENUM_TIMEFRAMES timeframe,// Timeframe
                   const datetime startTime,         // Copying start time
                   const int count,                  // Number of elements for copying
                   long &vol[]// Data receiver array (out)
                   )
  {
//--- Reset the last error code
   ResetLastError();
//--- Copy data
   const int num=CopyRealVolume(symbol,timeframe,startTime,count,vol);
//--- Check the number of copied elements
   if(num>0) // If data obtained
     {
      //--- Check the error code
      if(GetLastError()==0) // If there is no error
         return(true );                              // Return 'true'
      else                                           // In case of an error
        {
         Print(__FUNCTION__,": ERROR #",GetLastError()," when copying "+symbol+" data.");
         return(false);                              // Exit
        }
     }
   else                                              // If no data obtained
     {
      Print(__FUNCTION__,": ERROR #",GetLastError(),": Failed to obtain "+symbol+" volume data!");
      return(false);                                 // Exit with the error
     }
  }
//+------------------------------------------------------------------+
//| Display the indicator values												   |
//+------------------------------------------------------------------+
void DisplayValues(const int index,// Candle index
                   const long sumVolBuy,// Total buy volume
                   const long sumVolSell,          // Total sell volume
                   const int line                  // Function call string index
                   )
  {
//--- Check if the candle index is correct
   if(index<0) // If the index is incorrect
     {
      Print(__FUNCTION__,": ERROR! Incorrect candle index '",index,"'");
      return;                                       // Exit
     }
//--- Calculate delta
   const double delta=double(sumVolBuy-sumVolSell);
//--- Enter the values into the buffers
   bufDelta[ index ]= delta;                       // Write delta value
   bufDeltaColor[ index ] =(delta>0) ?  0 : 1;     // Write the value color
   bufBuyVol[ index ] = (double)sumVolBuy;         // Write the sum of buys
   bufSellVol[ index ]=(double)sumVolSell;         // Write the sum of sells
  }
//+------------------------------------------------------------------+
//| Set the total volume value 									            |
//+------------------------------------------------------------------+
void AddVolToSum(const MqlTick &tick,// Checked tick parameters
                 long& sumVolBuy,            // Total buy volume (out)
                 long& sumVolSell            // Total sell volume (out)
                 )
  {
//--- Check the tick direction
   if(( tick.flags&TICK_FLAG_BUY)==TICK_FLAG_BUY && (tick.flags&TICK_FLAG_SELL)==TICK_FLAG_SELL) // If the tick is of both directions
      Print(__FUNCTION__,": ERROR! Tick '"+GetMsToStringTime(tick.time_msc)+"' is of unknown direction!");
   else if(( tick.flags&TICK_FLAG_BUY)==TICK_FLAG_BUY) // In case of a buy tick
   sumVolBuy+=(long)tick.volume;
   else if(( tick.flags&TICK_FLAG_SELL)==TICK_FLAG_SELL) // In case of a sell tick
   sumVolSell+=(long)tick.volume;
   else                                                  // If it is not a trading tick
   Print(__FUNCTION__,": ERROR! Tick '"+GetMsToStringTime(tick.time_msc)+"' is not a trading one!");
  }
//+------------------------------------------------------------------+
//| Volume control																	|
//+------------------------------------------------------------------+
void VolumeControl(const bool useControl,// First launch flag
                   const int num,// Tracked candle index
                   const long vol,// Reference volume
                   const datetime time,      // Reference volume candle time
                   const long sumVolBuy,     // Total buys on the candle
                   const long sumVolSell     // Total sells on the candle
                   )
  {
//--- Control
   if(vol==(sumVolBuy+sumVolSell)) // If control is passed
      return;                                // Exit
   else                                      // Otherwise
     {
      //--- Check if the log is maintained
      if(inpLog)
         Print(__FUNCTION__,": ERROR! Candle control "+TimeToString(time)+" не пройден: ",vol," != ",sumVolBuy,"+",sumVolSell);
      //--- Check the volume control necessity
      if(useControl)
        {
         //--- Repeated control
         if(RepeatedControl(num,time)) // If repeated control is passed
            return;                          // Exit
         //--- Set the repeated control flag on the next tick
         _repeatedControl=true;
         //--- Set the candle index for the repeated control
         _controlNum=num;
        }
     }
  }
//+------------------------------------------------------------------+
//| Get the level color depending on the color ID			            |
//+------------------------------------------------------------------+
color GetLevelColor(const int id) // Color ID
  {
//--- Return color depending on the ID
   switch(id)
     {
      case 0: return( inpColorUp );
      case 1: return( inpColorDn );
      default:
         Print(__FUNCTION__,": ERROR! Unknown '",id,"' color ID");
         return( WRONG_VALUE );
     }
  }
//+------------------------------------------------------------------+
//| Get the time string from milliseconds 									|
//+------------------------------------------------------------------+
string GetMsToStringTime(const ulong ms)
  {
   return( TimeToString( ms/MS_KOEF, TIME_DATE|TIME_SECONDS )+"."+string( ms%MS_KOEF ) );
  }
//+------------------------------------------------------------------+
//| Set the indicator parameters											      |
//+------------------------------------------------------------------+
bool SetIndicatorParameters()
  {
//--- Buffer of colors for delta values
   color colors[2];
//--- Mark the color array
   colors[ 0 ]= inpColorUp;
   colors[ 1 ]= inpColorDn;
//--- Set the graphical series parameters
   SetPlotParametersColorHistogram(0,0,bufDelta,bufDeltaColor,false,"DELTA "+_Symbol,colors,EMPTY_VALUE,inpDeltaWidth);
   SetPlotParametersNONE(1,2,bufBuyVol,false,"Buy volume",EMPTY_VALUE);
   SetPlotParametersNONE(2,3,bufSellVol,false,"Sell volume",EMPTY_VALUE);
//--- Short name in the subwindow
   IndicatorSetString(INDICATOR_SHORTNAME,"DELTA '"+_Symbol+"'");
//--- Set the accuracy of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- If all is completed without errors
   return( true );
  }
//+-------------------------------------------------------------------+
//| Graphical construction parameters: color histogram from the line 0|
//+-------------------------------------------------------------------+
void SetPlotParametersColorHistogram(const int plotIndex,// Graphical series index
                                     const int bufferNum,// The series' first buffer index
                                     double &value[],// Buffer of values
                                     double& clr[],                                 // Color buffer
                                     const bool asSeries,                           // Numbering flag as in time series
                                     const string label,                           // Series name
                                     const color& colors[],                        // Line colors
                                     const double emptyValue = EMPTY_VALUE,         // Series' empty values
                                     const int width = 0,                           // Line width
                                     const ENUM_LINE_STYLE style = STYLE_SOLID,      // Line style
                                     const int drawBegin = 0,                        // Number of bars that are not drawn
                                     const int shift=0                           // Construction shift in bars
                                     )
  {
//--- Bind the buffers
   SetIndexBuffer(bufferNum,value,INDICATOR_DATA);
   SetIndexBuffer(bufferNum+1,clr,INDICATOR_COLOR_INDEX);
//--- Set the numbering order in the array buffers
   ArraySetAsSeries(value,asSeries);
   ArraySetAsSeries(clr,asSeries);
//--- Set the graphical construction type
   PlotIndexSetInteger(plotIndex,PLOT_DRAW_TYPE,DRAW_COLOR_HISTOGRAM);
//--- Set the graphical series name
   PlotIndexSetString(plotIndex,PLOT_LABEL,label);
//--- Set empty values in the buffers
   PlotIndexSetDouble(plotIndex,PLOT_EMPTY_VALUE,emptyValue);
//--- Set the number of indicator colors
   const int size=ArraySize(colors);
   PlotIndexSetInteger(plotIndex,PLOT_COLOR_INDEXES,size);
//--- Set the indicator colors
   for(int i=0; i<size; i++)
      PlotIndexSetInteger(plotIndex,PLOT_LINE_COLOR,i,colors[i]);
//--- Set the line width
   PlotIndexSetInteger(plotIndex,PLOT_LINE_WIDTH,width);
//--- Set the line style
   PlotIndexSetInteger(plotIndex,PLOT_LINE_STYLE,style);
//--- Set the number of bars that are not drawn and values in DataWindow
   PlotIndexSetInteger(plotIndex,PLOT_DRAW_BEGIN,drawBegin);
//--- Set the graphical construction shift by time axis in bars
   PlotIndexSetInteger(plotIndex,PLOT_SHIFT,shift);
  }
//+------------------------------------------------------------------+
//| Graphical construction parameters: no display					      |
//+------------------------------------------------------------------+
void SetPlotParametersNONE(const int plotIndex,// Graphical series index
                           const int bufferNum,// The series' first buffer index
                           double &value[],// Buffer of values
                           const bool asSeries,// Numbering flag as in time series
                           const string label,                        // Series name
                           const double emptyValue = EMPTY_VALUE      // Series' empty values
                           )
  {
//--- Bind the buffers
   SetIndexBuffer(bufferNum,value,INDICATOR_DATA);
//--- Set the numbering order in the array buffers
   ArraySetAsSeries(value,asSeries);
//--- Set the graphical construction type
   PlotIndexSetInteger(plotIndex,PLOT_DRAW_TYPE,DRAW_NONE);
//--- Set the graphical series name
   PlotIndexSetString(plotIndex,PLOT_LABEL,label);
//--- Set empty values in the buffers
   PlotIndexSetDouble(plotIndex,PLOT_EMPTY_VALUE,emptyValue);
  }
//+------------------------------------------------------------------+
//| Initialize the buffers' num index with 'value'					      |
//+------------------------------------------------------------------+
void BuffersIndexInitialize(const int num,// Initialization index
                            const double value      // Initialization value
                            )
  {
   bufDelta[num]=value;
   bufDeltaColor[num]=value;
   bufBuyVol[num]=value;
   bufSellVol[num]=value;
  }
//+------------------------------------------------------------------+
//| Initialize indicator buffers with initial values			         |
//+------------------------------------------------------------------+
void BuffersInitialize(const double value) // Initialization value
  {
   ArrayInitialize(bufDelta,value);
   ArrayInitialize(bufDeltaColor,value);
   ArrayInitialize(bufBuyVol,value);
   ArrayInitialize(bufSellVol,value);
  }
//+------------------------------------------------------------------+
//| Check the indicator inputs									            |
//+------------------------------------------------------------------+
bool CheckInputParameters()
  {
//--- Time of the last quote for a symbol
   const datetime tm=(datetime)SymbolInfoInteger(_Symbol,SYMBOL_TIME);
//--- Compare the last quote time with copying start one
   if(tm<inpHistoryDate)
     {
      Print(__FUNCTION__,": ERROR! Copying start time ("+TimeToString(inpHistoryDate,TIME_DATE|TIME_SECONDS)+") > last quote time  ("+TimeToString(tm,TIME_DATE|TIME_SECONDS)+")");
      return( false );
     }
//--- If all checks are passed
   return( true );
  }
//+------------------------------------------------------------------+
