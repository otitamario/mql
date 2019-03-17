//+------------------------------------------------------------------+
//|                                                 TickColorCandles |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Denis Zyatkevich"
#property description "The indicator plots the 'Tick Candles'"
#property version   "1.00"
// Indicator is plotted in a separate window
#property indicator_separate_window
// One graphic plot is used, color candles
#property indicator_plots 1
// We need 4 buffers for OHLC prices and one - for the index of color
#property indicator_buffers 5
// Specifying the drawing type - color candles
#property indicator_type1 DRAW_COLOR_CANDLES
// Specifying the colors for the candles
#property indicator_color1 Gray,Red,Green
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// Declaration of the enumeration
enum price_types
  {
   Bid,
   Ask
  };
// The ticks_in_candle input variable specifies the number of ticks,
// corresponding to one candle
input int ticks_in_candle=16; //Tick Count in Candles
// The applied_price input variable of price_types type indicates 
// the type of the data, that is used in the indicator: Bid or Ask prices.
input price_types applied_price=0; // Price
// The path_prefix input variable specifies the path and prefix to the file name
input string path_prefix=""; // FileName Prefix

// The ticks_stored variable contains the number of stored quotes
int ticks_stored;
// The TicksBuffer [] array is used to store the incoming prices
// The OpenBuffer [], HighBuffer [], LowBuffer [] and CloseBuffer [] arrays
// are used to store the OHLC prices of the candles
// The ColorIndexBuffer [] array is used to store the index of color candles

double TicksBuffer[],OpenBuffer[],HighBuffer[],LowBuffer[],CloseBuffer[],ColorIndexBuffer[];
//+------------------------------------------------------------------+
//| Indicator initialization function                                |
//+------------------------------------------------------------------+
void OnInit()
  {
   // The OpenBuffer[] array is an indicator buffer
   SetIndexBuffer(0,OpenBuffer,INDICATOR_DATA);
   // The HighBuffer[] array is an indicator buffer
   SetIndexBuffer(1,HighBuffer,INDICATOR_DATA);
   // The LowBuffer[] array is an indicator buffer
   SetIndexBuffer(2,LowBuffer,INDICATOR_DATA);
   // The CloseBuffer[] array is an indicator buffer
   SetIndexBuffer(3,CloseBuffer,INDICATOR_DATA);
   // The ColorIndexBuffer[] array is the buffer of the color index
   SetIndexBuffer(4,ColorIndexBuffer,INDICATOR_COLOR_INDEX);
   // The TicksBuffer[] array is used for intermediate calculations
   SetIndexBuffer(5,TicksBuffer,INDICATOR_CALCULATIONS);
   // The indexation of OpenBuffer[] array as timeseries
   ArraySetAsSeries(OpenBuffer,true);
   // The indexation of HighBuffer[] array as timeseries
   ArraySetAsSeries(HighBuffer,true);
   // The indexation of LowBuffer[] array as timeseries
   ArraySetAsSeries(LowBuffer,true);
   // The indexation of CloseBuffer[] array as timeseries
   ArraySetAsSeries(CloseBuffer,true);
   // The indexation of the ColorIndexBuffer [] array as timeseries
   ArraySetAsSeries(ColorIndexBuffer,true);
   // The null values of Open prices (0th graphic plot) should not be plotted
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   // The null values of High prices (1st graphic plot) should not be plotted
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   // The null values of Low prices (2nd graphic plot) should not be plotted
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
   // The null values of Close prices (3rd graphic plot) should not be plotted
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
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
   // the file_handle variable is a file handle
   // the BidPosition and AskPosition - are positions of Bid and Ask prices in the string;
   // the line_string_len is a length of a string, read from the file, 
   // CandleNumber - number of candle, for which the prices OHLC are determined,
   // i - loop counter;
   int file_handle,BidPosition,AskPosition,line_string_len,CandleNumber,i;
   // The last_price_bid variable is the recent received Bid price
   double last_price_bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   // The last_price_ask variable is the recent received Ask price
   double last_price_ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   // the filename is a name of a file, the file_buffer is a string, 
   // used as a buffer for reading and writing of string data
   string filename,file_buffer;
   // Setting the size of TicksBuffer[] array
   ArrayResize(TicksBuffer,ArraySize(CloseBuffer));
   // File name formation from the path_prefix variable, name
   // of financial instrument and ".Txt" symbols
   StringConcatenate(filename,path_prefix,Symbol(),".txt");
   // Opening a file for reading and writing, codepage ANSI, shared reading mode
   file_handle=FileOpen(filename,FILE_READ|FILE_WRITE|FILE_ANSI|FILE_SHARE_READ);
   if(prev_calculated==0)
     {
      // Reading the first line from the file and determine the length of a string
      line_string_len=StringLen(FileReadString(file_handle))+2;
      // if file is large (contains more quotes than rates_total/2)
      if(FileSize(file_handle)>(ulong)line_string_len*rates_total/2)
        {
         // Setting file pointer to read the latest rates_total/2 quotes
         FileSeek(file_handle,-line_string_len*rates_total/2,SEEK_END);
         // Moving file pointer to the beginning of the next line
         FileReadString(file_handle);
        }
      // if file size is small
      else
        {
         // Moving file pointer at the beginning of a file
         FileSeek(file_handle,0,SEEK_SET);
        }
      // Reset the counter of stored quotes
      ticks_stored=0;
      // Reading until the end of the file
      while(FileIsEnding(file_handle)==false)
        {
         // Reading a string from thefile
         file_buffer=FileReadString(file_handle);
         // Processing of string if its length is larger than 6 characters
         if(StringLen(file_buffer)>6)
           {
            // Finding the start position of Bid price in the line
            BidPosition=StringFind(file_buffer," ",StringFind(file_buffer," ")+1)+1;
             //Finding the start position of Ask price in the line
            AskPosition=StringFind(file_buffer," ",BidPosition)+1;
            // If the Bid prices are used, adding the Bid price to TicksBuffer[] array
            if(applied_price==0) TicksBuffer[ticks_stored]=StringToDouble(StringSubstr(file_buffer,BidPosition,AskPosition-BidPosition-1));
            // If the Ask prices are used, adding the Ask price to TicksBuffer[] array
            if(applied_price==1) TicksBuffer[ticks_stored]=StringToDouble(StringSubstr(file_buffer,AskPosition));
            // Increasing the counter of stored quotes
            ticks_stored++;
           }
        }
     }
   // If the data have been read before
   else
     {
      // Moving file pointer at the end of the file
      FileSeek(file_handle,0,SEEK_END);
      // Forming a string, that should be written to the file
      StringConcatenate(file_buffer,TimeCurrent()," ",DoubleToString(last_price_bid,_Digits)," ",DoubleToString(last_price_ask,_Digits));
      // Writing a string to the file
      FileWrite(file_handle,file_buffer);
      // If the Bid prices are used, adding the last Bid price to TicksBuffer[] array
      if(applied_price==0) TicksBuffer[ticks_stored]=last_price_bid;
      // If the Ask prices are used, adding the last Ask price to TicksBuffer[] array
      if(applied_price==1) TicksBuffer[ticks_stored]=last_price_ask;
      // Increasing the quotes counter
      ticks_stored++;
     }
   // Closing the file
   FileClose(file_handle);
   // If number of quotes is more or equal than number of bars in the chart
   if(ticks_stored>=rates_total)
     {
      // Removing the first tick_stored/2 quotes and shifting remaining quotes
      for(i=ticks_stored/2;i<ticks_stored;i++)
        {
         // Shifting the data to the beginning in the TicksBuffer[] array on tick_stored/2
         TicksBuffer[i-ticks_stored/2]=TicksBuffer[i];
        }
      // Changing the quotes counter
      ticks_stored-=ticks_stored/2;
     }
   // We assign the CandleNumber with a number of invalid candle
   CandleNumber=-1;
   // Search for all the price data available for candle formation
   for(i=0;i<ticks_stored;i++)
     {
      // If this candle is forming already
      if(CandleNumber==(int)(MathFloor((ticks_stored-1)/ticks_in_candle)-MathFloor(i/ticks_in_candle)))
        {
         // The current quote is still closing price of the current candle
         CloseBuffer[CandleNumber]=TicksBuffer[i];
         // If the current price is greater than the highest price of the current candle, it will be a new highest price of the candle
         if(TicksBuffer[i]>HighBuffer[CandleNumber]) HighBuffer[CandleNumber]=TicksBuffer[i];
         // If the current price is lower than the lowest price of the current candle, it will be a new lowest price of the candle
         if(TicksBuffer[i]<LowBuffer[CandleNumber]) LowBuffer[CandleNumber]=TicksBuffer[i];
         // If the candle is bullish, it will have a color with index 2 (green)
         if(CloseBuffer[CandleNumber]>OpenBuffer[CandleNumber]) ColorIndexBuffer[CandleNumber]=2;
         // If the candle is bearish, it will have a color with index 1 (red)
         if(CloseBuffer[CandleNumber]<OpenBuffer[CandleNumber]) ColorIndexBuffer[CandleNumber]=1;
         // If the opening and closing prices are equal, then the candle will have a color with index 0 (grey)
         if(CloseBuffer[CandleNumber]==OpenBuffer[CandleNumber]) ColorIndexBuffer[CandleNumber]=0;
        }
      // If this candle hasn't benn calculated yet
      else
        {
         // Let's determine the index of a candle
         CandleNumber=(int)(MathFloor((ticks_stored-1)/ticks_in_candle)-MathFloor(i/ticks_in_candle));
         // The current quote will be the opening price of a candle
         OpenBuffer[CandleNumber]=TicksBuffer[i];
         // The current quote will be the highest price of a candle
         HighBuffer[CandleNumber]=TicksBuffer[i];
         // The current quote will be the lowest price of a candle
         LowBuffer[CandleNumber]=TicksBuffer[i];
         // The current quote will be the closing price of a candle
         CloseBuffer[CandleNumber]=TicksBuffer[i];
         // The candle will have a color with index 0 (gray)
         ColorIndexBuffer[CandleNumber]=0;
        }
     }
   // Return from OnCalculate(), return a value, different from zero   
   return(rates_total);
  }
//+------------------------------------------------------------------+