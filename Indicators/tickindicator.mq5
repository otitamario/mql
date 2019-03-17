//+------------------------------------------------------------------+
//|                                                    TickIndicator |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Denis Zyatkevich"
#property description "The indicator plots a tick chart of the price."
#property version   "1.00"
// indicator in a separate window
#property indicator_separate_window
// two graphic plots are used: for Bid and Ask lines
#property indicator_plots 2
// two indicator's buffers
#property indicator_buffers 2
// drawing type of a Bid line
#property indicator_type1 DRAW_LINE
// drawing color of a Bid line
#property indicator_color1 Red
// drawing style of a Bid line
#property indicator_style1 STYLE_SOLID
// text label of a Bid line
#property indicator_label1 "Bid"
// drawing type of an Ask line
#property indicator_type2 DRAW_LINE
// drawing color of an Ask line
#property indicator_color2 Blue
// drawing style of an Ask line
#property indicator_style2 STYLE_SOLID
// text label of an Ask line
#property indicator_label2 "Ask"

// the BidLineEnable indicates showing of a Bid line
input bool BidLineEnable=true; // Show Bid Line
// the AskLineEnable indicates showing of an Ask line
input bool AskLineEnable=true; // Show Ask Line
// the path_prefix defines a path and file name prefix
input string path_prefix=""; // FileName Prefix

// the tick_stored variable is a number of served quotes
int ticks_stored;
// the BidBuffer[] and AskBuffer[] arrays - are indicator's buffers
double BidBuffer[],AskBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   // the BidBuffer[] is an indicator buffer
   SetIndexBuffer(0,BidBuffer,INDICATOR_DATA);
   // the AskBuffer[] is an indicator buffer
   SetIndexBuffer(1,AskBuffer,INDICATOR_DATA);
   // setting EMPTY_VALUE for a Bid line
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   // setting EMPTY_VALUE for an Ask line
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
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
   // the line_string_len is a length of a string, read from the file, i is a loop counter;
   int file_handle,BidPosition,AskPosition,line_string_len,i;
   // the last_price_bid is the last Bid quote
   double last_price_bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   // the last_price_ask is the last Ask quote
   double last_price_ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   // the filename is a name of a file, the file_buffer is a string, 
   // used as a buffer for reading and writing of string data
   string filename,file_buffer;
   // File name formation from the path_prefix variable, name
   // of financial instrument and ".Txt" symbols
   StringConcatenate(filename,path_prefix,Symbol(),".txt");
   // Opening a file for reading and writing, codepage ANSI, shared reading mode
   file_handle=FileOpen(filename,FILE_READ|FILE_WRITE|FILE_ANSI|FILE_SHARE_READ);
   // At first execution of OnCalculate function, we reading the quotes from a file
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
         // Reading a string from the file
         file_buffer=FileReadString(file_handle);
         // Processing of string if its length is larger than 6 characters
         if(StringLen(file_buffer)>6)
           {
            // Finding the start position of Bid price in the line
            BidPosition=StringFind(file_buffer," ",StringFind(file_buffer," ")+1)+1;
            // Finding the start position of Ask price in the line
            AskPosition=StringFind(file_buffer," ",BidPosition)+1;
            // If the Bid line should be plotted, adding this value to BidBuffer[] array
            if(BidLineEnable) BidBuffer[ticks_stored]=StringToDouble(StringSubstr(file_buffer,BidPosition,AskPosition-BidPosition-1));
            // If the Ask line should be plotted, adding this value to AskBuffer[] array
            if(AskLineEnable) AskBuffer[ticks_stored]=StringToDouble(StringSubstr(file_buffer,AskPosition));
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
      // If the Bid line should be plotted, adding the last Bid price to the BidBuffer[] array
      if(BidLineEnable) BidBuffer[ticks_stored]=last_price_bid;
      // If the Ask line should be plotted, adding the last Ask price to the AskBuffer[] array
      if(AskLineEnable) AskBuffer[ticks_stored]=last_price_ask;
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
         // If the Bid line should be plotted, shifting the values of BidBuffer[] array on tick_stored/2
         if(BidLineEnable) BidBuffer[i-ticks_stored/2]=BidBuffer[i];
         // If the Ask line should be plotted, shifting the values of AskBuffer[] array on tick_stored/2
         if(AskLineEnable) AskBuffer[i-ticks_stored/2]=AskBuffer[i];
        }
      // Changing the value of a counter
      ticks_stored-=ticks_stored/2;
     }
   // Shifting the Bid line to align with the price chart
   PlotIndexSetInteger(0,PLOT_SHIFT,rates_total-ticks_stored);
   // Shifting the Ask line to align with the price chart
   PlotIndexSetInteger(1,PLOT_SHIFT,rates_total-ticks_stored);
   // If the Bid line should be plotted, placing the value to the last element 
   // of BidBuffer [] array to show the last Bid price in the indicator's window  
   if(BidLineEnable) BidBuffer[rates_total-1]=last_price_bid;
   // If the Ask line should be plotted, placing the value to the last element 
   // of AskBuffer [] array to show the last Ask price in the indicator's window
   if(AskLineEnable) AskBuffer[rates_total-1]=last_price_ask;
   // Return from OnCalculate(), return a value, different from zero   
   return(rates_total);
  }
//+------------------------------------------------------------------+