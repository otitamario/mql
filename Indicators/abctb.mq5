//+------------------------------------------------------------------+
//|                                                        ABCTB.mq5 |
//|                                 "Azotskiy Aktiniy ICQ:695710750" |
//|                        "https://login.mql5.com/ru/users/Aktiniy" |
//+------------------------------------------------------------------+
// ABCTB - Auto Build Chart Three Line Break
#property copyright "Azotskiy Aktiniy ICQ:695710750"
#property link      "https://login.mql5.com/ru/users/Aktiniy"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   2
//--- plot ABCTB
#property indicator_label1  "ABCTB"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrBlue,clrRed,clrSilver
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot LINE_TLB
#property indicator_label2  "LINE_TLB"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- price type for calculation
enum type_price
  {
   close=0, // Close
   open=1,  // Open
   high=2,  // Hight
   low=3,   // Low
  };
//--- type of chart construction
enum type_build
  {
   classic=0,  // Classic
   modified=1, // Modified
  };
//--- priority
enum priority
  {
   highest_t=4, // Highest
   high_t=3,    // High
   medium_t=2,  // Medium
   low_t=1,     // Low
  };
//--- input parameters
input long               magic_numb=65758473787389;                // Magic number
input ENUM_TIMEFRAMES    time_frame=PERIOD_CURRENT;                // Calculation time range
input ENUM_TIMEFRAMES    time_redraw=PERIOD_M1;                    // Period of chart updates
input datetime           first_date_start=D'2013.03.13 00:00:00';  // Start date
input type_price         chart_price=close;                        // Price type for calculation (0-Close, 1-Open, 2-High, 3-Low)
input int                step_min_f=4;                             // Minimum step for a new column (>0)
input int                line_to_back_f=3;                         // Number of lines to display a reversal(>0)
input type_build         chart_type=classic;                       // Type of chart construction (0-classic, 1-modified)
input bool               chart_color_period=true;                  // Changing color for a new period
input bool               chart_synchronization=true;               // Constructing a chart only upon complete synchronization
input priority           chart_priority_close=highest_t;           // Priority of the closing price
input priority           chart_priority_open=highest_t;            // Priority of the opening price
input priority           chart_priority_high=highest_t;            // Priority of the maximum price
input priority           chart_priority_low=highest_t;             // Priority of the minimum price
input bool               ma_draw=true;                             // Draw the average
input ENUM_APPLIED_PRICE ma_price=PRICE_CLOSE;                     // Price type for constructing the average
input ENUM_MA_METHOD     ma_method=MODE_EMA;                       // Construction type
input int                ma_period=14;                             // Averaging period
//--- indicator buffers
//--- buffer of the chart
double         ABCTBBuffer1[];
double         ABCTBBuffer2[];
double         ABCTBBuffer3[];
double         ABCTBBuffer4[];
double         ABCTBColors[];
//--- buffer of the average
double         LINE_TLBBuffer[];
//--- variables
MqlRates rates_array[];// bar data array for analysis
datetime date_stop;// current date
datetime date_start;// start date variable for calculation
//+------------------------------------------------------------------+
//| Struct Line Price                                                |
//+------------------------------------------------------------------+
struct line_price// structure for storing information about the past lines
  {
   double            up;// value of the high price
   double            down;// value of the low price
  };
//+------------------------------------------------------------------+
//| Struct Line Information                                          |
//+------------------------------------------------------------------+
struct line_info// structure of storing information about the shared lines
  {
   double            up;
   double            down;
   char              type;
   datetime          time;
  };
line_info line_main_open[];// data on the opening prices chart
line_info line_main_high[];// data on the maximum prices chart
line_info line_main_low[];// data on the minimum prices chart
line_info line_main_close[];// data on the closing prices chart
//+------------------------------------------------------------------+
//| Struct Buffer Info                                               |
//+------------------------------------------------------------------+
struct buffer_info// structure for storing data for filling a buffer
  {
   double            open;
   double            high;
   double            low;
   double            close;
   char              type;
   datetime          time;
  };
buffer_info data_for_buffer[];// data for filling the modified construction buffer
datetime array_datetime[];// array for storing information of the time for every line
int time_array[3];// array for the function func_date_color
datetime time_variable;// variable for the function func_date_color
bool latch=false;// variable-latch for the function func_date_color
int handle;// handle of the indicator iMA
int step_min;// variable of the minimum step
int line_to_back;// variable of the number of lines to display a reversal
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
//--- buffers for a chart
   SetIndexBuffer(0,ABCTBBuffer1,INDICATOR_DATA);
   ArraySetAsSeries(ABCTBBuffer1,true);
   SetIndexBuffer(1,ABCTBBuffer2,INDICATOR_DATA);
   ArraySetAsSeries(ABCTBBuffer2,true);
   SetIndexBuffer(2,ABCTBBuffer3,INDICATOR_DATA);
   ArraySetAsSeries(ABCTBBuffer3,true);
   SetIndexBuffer(3,ABCTBBuffer4,INDICATOR_DATA);
   ArraySetAsSeries(ABCTBBuffer4,true);
   SetIndexBuffer(4,ABCTBColors,INDICATOR_COLOR_INDEX);
   ArraySetAsSeries(ABCTBColors,true);
//--- buffer for constructing the average
   SetIndexBuffer(5,LINE_TLBBuffer,INDICATOR_DATA);
   ArraySetAsSeries(LINE_TLBBuffer,true);
//--- set the values that are not going to be reflected on the chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);// for the chart
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);// for the average
//--- set the indicator appearance
   IndicatorSetString(INDICATOR_SHORTNAME,"ABCTB "+IntegerToString(magic_numb)); // name of the indicator
//--- accuracy of display
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- prohibit displaying the results of the indicator current values
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
//---
   handle=iMA(_Symbol,time_frame,ma_period,0,ma_method,ma_price);
   if(step_min_f<1)
     {
      step_min=1;
      Alert("Minimum step for a new column must be greater than zero");
     }
   else step_min=step_min_f;
//---
   if(line_to_back_f<1)
     {
      line_to_back=1;
      Alert("The number of lines to display a reversal must be greater than zero");
     }
   else line_to_back=line_to_back_f;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
   if(func_new_bar(time_redraw)==true)
     {
      func_consolidation();
     };
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//--- event of a keystroke
   if(id==CHARTEVENT_KEYDOWN)
     {
      if(lparam==82) //--- the key "R" has been pressed
        {
         func_consolidation();
        }
     }
  }
//+------------------------------------------------------------------+
//| Func Consolidation                                               |
//+------------------------------------------------------------------+
void func_consolidation()
  {
//--- defining the current date
   date_stop=TimeCurrent();
//--- copying data for analysis
   func_all_copy(rates_array,time_frame,first_date_start,date_stop);
//--- basic construction of the chart
   func_chart_build(chart_price,chart_type);
   ChartRedraw();
  }
//+------------------------------------------------------------------+
//| Func All Copy                                                    |
//+------------------------------------------------------------------+
bool func_all_copy(
                   MqlRates &result_array[],// response array
                   ENUM_TIMEFRAMES period,// timeframe
                   datetime data_start,// start date
                   datetime data_stop// end date
                   )
  {
//--- declaration of auxiliary variables
   bool x=false;       // variable for the function response
   int result_copy=-1; // copied data count
//--- adding variables and arrays for calculation
   static MqlRates interim_array[]; // temporary dynamic array for storing copied data
   static int bars_to_copy;         // number of bars for copying
   static int bars_copied;          // number of copied bars since the start date
//--- find out the current number of bars in the time range
   bars_to_copy=Bars(_Symbol,period,data_start,data_stop);
//--- count the number of bars to be copied
   bars_to_copy-=bars_copied;
//--- if it is not the first time when data is being copied
   if(bars_copied>0)
     {
      bars_copied--;
      bars_to_copy++;
     }
//--- change the size of the receiving array
   ArrayResize(interim_array,bars_to_copy);
//--- copy data into a temporary array
   result_copy=CopyRates(_Symbol,period,0,bars_to_copy,interim_array);
//--- check the result of copying data
   if(result_copy!=-1) // if copying to the temporary array was successful
     {
      ArrayCopy(result_array,interim_array,bars_copied,0,WHOLE_ARRAY); // copy the data from the temporary array into the main one
      x=true;                   // assign the positive response to the function
      bars_copied+=result_copy; // increase the value of the copied data
     }
//---
   return(x);
  }
//+------------------------------------------------------------------+
//| Func Build Three Line Break                                      |
//+------------------------------------------------------------------+
void func_build_three_line_break(
                                 MqlRates &input_array[],// array for analysis
                                 char price_type,// type of the price under analysis (0-Close, 1-Open, 2-High, 3-Low)
                                 int min_step,// minimum step for drawing a line
                                 int line_back,// number of lines for a reversal
                                 line_info &line_main_array[]// array for return (response) of the function
                                 )
  {
//--- calculate the size of the array for analysis
   int array_size=ArraySize(input_array);
//--- extract data required for calculation into an intermediate array
   double interim_array[];// intermediate array
   ArrayResize(interim_array,array_size);// adjust the intermediate array to the size of the data
   switch(price_type)
     {
      case 0: // Close
        {
         for(int x=0; x<array_size; x++)
           {
            interim_array[x]=input_array[x].close;
           }
        }
      break;
      case 1: // Open
        {
         for(int x=0; x<array_size; x++)
           {
            interim_array[x]=input_array[x].open;
           }
        }
      break;
      case 2: // High
        {
         for(int x=0; x<array_size; x++)
           {
            interim_array[x]=input_array[x].high;
           }
        }
      break;
      case 3: // Low
        {
         for(int x=0; x<array_size; x++)
           {
            interim_array[x]=input_array[x].low;
           }
        }
      break;
     }
//--- enter the variables for storing information about current situation
   line_price passed_line[];// array for storing information about the latest prices of the lines (type structure line_price)
   ArrayResize(passed_line,line_back+1);
   int line_calc=0;// number of lines
   int line_up=0;// number of the last ascending lines
   int line_down=0;// number of the last descending lines
   double limit_up=0;// upper limit necessary to pass
   double limit_down=0;// lower limit necessary to pass
/* Fill variables informing of the current situation with the first values */
   passed_line[0].up=interim_array[0];
   passed_line[0].down=interim_array[0];
//--- start the first loop to calculate received data for filling a buffer for drawing
   for(int x=0; x<array_size; x++)
     {
      if(line_calc==0)// no lines have been drawn
        {
         limit_up=passed_line[0].up;
         limit_down=passed_line[0].down;
         if(interim_array[x]>=limit_up+min_step*_Point)// the upper limit has been passed
           {
            func_regrouping(passed_line,interim_array[x],1);// regroup
            line_calc++;// update the line counter
            line_up++;
           }
         if(interim_array[x]<=limit_down-min_step*_Point)// the lower limit has been passed
           {
            func_regrouping(passed_line,interim_array[x],-1);// regroup
            line_calc++;// update the line counter
            line_down++;
           }
        }
      if(line_up>line_down)// last ascending line (lines)
        {
         limit_up=passed_line[0].up;
         limit_down=passed_line[(int)MathMin(line_up,line_back-1)].down;
         if(interim_array[x]>=limit_up+min_step*_Point)// the upper limit has been passed
           {
            func_regrouping(passed_line,interim_array[x],1);// regroup
            line_calc++;// update the line counter
            line_up++;
           }
         if(interim_array[x]<limit_down)// the lower limit has been passed
           {
            func_regrouping(passed_line,interim_array[x],-1);// regroup
            line_calc++;// update the line counter
            line_up=0;
            line_down++;
           }
        }
      if(line_down>line_up)// last descending line (lines)
        {
         limit_up=passed_line[(int)MathMin(line_down,line_back-1)].up;
         limit_down=passed_line[0].down;
         if(interim_array[x]>limit_up)// the upper limit has been passed
           {
            func_regrouping(passed_line,interim_array[x],1);// regroup
            line_calc++;// update the line counter
            line_down=0;
            line_up++;
           }
         if(interim_array[x]<=limit_down-min_step*_Point)// the lower limit has been passed
           {
            func_regrouping(passed_line,interim_array[x],-1);// regroup
            line_calc++;// update the line counter
            line_down++;
           }
        }
     }
   ArrayResize(line_main_array,line_calc);// change the size of the target array
//--- zeroise variables and fill with the the initial data
   line_calc=0;
   line_up=0;
   line_down=0;
   passed_line[0].up=interim_array[0];
   passed_line[0].down=interim_array[0];
//--- start the second loop to fill a buffer for drawing
   for(int x=0; x<array_size; x++)
     {
      if(line_calc==0)// no lines have been drawn
        {
         limit_up=passed_line[0].up;
         limit_down=passed_line[0].down;
         if(interim_array[x]>=limit_up+min_step*_Point)// the upper limit has been passed
           {
            func_regrouping(passed_line,interim_array[x],1);// regroup
            func_insert(line_main_array,passed_line,line_calc,1,input_array[x].time);
            line_calc++;// update the line counter
            line_up++;
           }
         if(interim_array[x]<=limit_down-min_step*_Point)// the lower limit has been passed
           {
            func_regrouping(passed_line,interim_array[x],-1);// regroup
            func_insert(line_main_array,passed_line,line_calc,-1,input_array[x].time);
            line_calc++;// update the line counter
            line_down++;
           }
        }
      if(line_up>line_down)// last ascending line (lines)
        {
         limit_up=passed_line[0].up;
         limit_down=passed_line[(int)MathMin(line_up,line_back-1)].down;
         if(interim_array[x]>=limit_up+min_step*_Point)// the upper limit has been passed
           {
            func_regrouping(passed_line,interim_array[x],1);// regroup
            func_insert(line_main_array,passed_line,line_calc,1,input_array[x].time);
            line_calc++;// update the line counter
            line_up++;
           }
         if(interim_array[x]<limit_down)// the lower limit has been passed
           {
            func_regrouping(passed_line,interim_array[x],-1);// regroup
            func_insert(line_main_array,passed_line,line_calc,-1,input_array[x].time);
            line_calc++;// update the line counter
            line_up=0;
            line_down++;
           }
        }
      if(line_down>line_up)// last descending line (lines)
        {
         limit_up=passed_line[(int)MathMin(line_down,line_back-1)].up;
         limit_down=passed_line[0].down;
         if(interim_array[x]>limit_up)// the upper limit has been passed
           {
            func_regrouping(passed_line,interim_array[x],1);// regroup
            func_insert(line_main_array,passed_line,line_calc,1,input_array[x].time);
            line_calc++;// update the line counter
            line_down=0;
            line_up++;
           }
         if(interim_array[x]<=limit_down-min_step*_Point)// the lower limit has been passed
           {
            func_regrouping(passed_line,interim_array[x],-1);// regroup
            func_insert(line_main_array,passed_line,line_calc,-1,input_array[x].time);
            line_calc++;// update the line counter
            line_down++;
           }
        }
     }
  }
//+------------------------------------------------------------------+
// Func Regrouping                                                   |
//+------------------------------------------------------------------+
void func_regrouping(
                     line_price &input_array[],// array for regrouping
                     double new_price,// new price value
                     char type// type of movement
                     )
  {
   int x=ArraySize(input_array);// find out the size of the array for regrouping
   for(x--; x>0; x--)// regrouping loop
     {
      input_array[x].up=input_array[x-1].up;
      input_array[x].down=input_array[x-1].down;
     }
   if(type==1)
     {
      input_array[0].up=new_price;
      input_array[0].down=input_array[1].up;
     }
   if(type==-1)
     {
      input_array[0].down=new_price;
      input_array[0].up=input_array[1].down;
     }
  }
//+------------------------------------------------------------------+
// Func Insert                                                       |
//+------------------------------------------------------------------+
void func_insert(
                 line_info &line_m[],// target array
                 line_price &line_i[],// source array
                 int index,// array element being inserted
                 char type,// type of the target column
                 datetime time// date
                 )
  {
   line_m[index].up=line_i[0].up;
   line_m[index].down=line_i[0].down;
   line_m[index].type=type;
   line_m[index].time=time;
  }
//+------------------------------------------------------------------+
// Func Chart Build                                                  |
//+------------------------------------------------------------------+
void func_chart_build(
                      char price,// price type for chart construction
                      char type// type of chart construction
                      )
  {
//--- Zeroise the buffers
   ZeroMemory(ABCTBBuffer1);
   ZeroMemory(ABCTBBuffer2);
   ZeroMemory(ABCTBBuffer3);
   ZeroMemory(ABCTBBuffer4);
   ZeroMemory(ABCTBColors);
   ZeroMemory(LINE_TLBBuffer);
   if(type==1)// construct a modified chart (based on all price types)
     {
      func_build_three_line_break(rates_array,0,step_min,line_to_back,line_main_close);// data on closing prices
      func_build_three_line_break(rates_array,1,step_min,line_to_back,line_main_open);// data on opening prices
      func_build_three_line_break(rates_array,2,step_min,line_to_back,line_main_high);// data on maximum prices
      func_build_three_line_break(rates_array,3,step_min,line_to_back,line_main_low);// data on minimum prices
      //--- calculate data arrays
      int line_main_calc[4];
      line_main_calc[0]=ArraySize(line_main_close);
      line_main_calc[1]=ArraySize(line_main_open);
      line_main_calc[2]=ArraySize(line_main_high);
      line_main_calc[3]=ArraySize(line_main_low);
      //--- gather the date array
      int all_elements=line_main_calc[0]+line_main_calc[1]+line_main_calc[2]+line_main_calc[3];// find out the number of all elements
      datetime datetime_array[];// enter the array for copying
      ArrayResize(datetime_array,all_elements);
      int y[4];
      ZeroMemory(y);
      for(int x=0;x<ArraySize(datetime_array);x++)// copy data to the array
        {
         if(x<line_main_calc[0])
           {
            datetime_array[x]=line_main_close[y[0]].time;
            y[0]++;
           }
         if(x<line_main_calc[0]+line_main_calc[1] && x>=line_main_calc[0])
           {
            datetime_array[x]=line_main_open[y[1]].time;
            y[1]++;
           }
         if(x<line_main_calc[0]+line_main_calc[1]+line_main_calc[2] && x>=line_main_calc[0]+line_main_calc[1])
           {
            datetime_array[x]=line_main_high[y[2]].time;
            y[2]++;
           }
         if(x>=line_main_calc[0]+line_main_calc[1]+line_main_calc[2])
           {
            datetime_array[x]=line_main_low[y[3]].time;
            y[3]++;
           }
        }
      ArraySort(datetime_array);// sort the array
      //--- delete replicated data from the array
      int good_info=1;
      for(int x=1;x<ArraySize(datetime_array);x++)// count useful information
        {
         if(datetime_array[x-1]!=datetime_array[x])good_info++;
        }
      ArrayResize(array_datetime,good_info);
      array_datetime[0]=datetime_array[0];// copy the first element as it is the pattern in the beginning of comparison
      good_info=1;
      for(int x=1;x<ArraySize(datetime_array);x++)// fill the new array with the useful data
        {
         if(datetime_array[x-1]!=datetime_array[x])
           {
            array_datetime[good_info]=datetime_array[x];
            good_info++;
           }
        }
      //--- fill the buffer for drawing (colored candles)
      int end_of_calc[4];// variables of storing information about the last comparison
      ZeroMemory(end_of_calc);
      ZeroMemory(data_for_buffer);
      ArrayResize(data_for_buffer,ArraySize(array_datetime));// change the size of the declared global array for storing data before passing it to a buffer
      for(int x=0; x<ArraySize(array_datetime); x++)
        {
         data_for_buffer[x].time=array_datetime[x];
         for(int s=end_of_calc[0]; s<line_main_calc[0]; s++)
           {
            if(array_datetime[x]==line_main_close[s].time)
              {
               end_of_calc[0]=s;
               if(line_main_close[s].type==1)data_for_buffer[x].close=line_main_close[s].up;
               else data_for_buffer[x].close=line_main_close[s].down;
               break;
              }
           }
         for(int s=end_of_calc[1]; s<line_main_calc[1]; s++)
           {
            if(array_datetime[x]==line_main_open[s].time)
              {
               end_of_calc[1]=s;
               if(line_main_open[s].type==1)data_for_buffer[x].open=line_main_open[s].down;
               else data_for_buffer[x].open=line_main_open[s].up;
               break;
              }
           }
         for(int s=end_of_calc[2]; s<line_main_calc[2]; s++)
           {
            if(array_datetime[x]==line_main_high[s].time)
              {
               end_of_calc[2]=s;
               data_for_buffer[x].high=line_main_high[s].up;
               break;
              }
           }
         for(int s=end_of_calc[3]; s<line_main_calc[3]; s++)
           {
            if(array_datetime[x]==line_main_low[s].time)
              {
               end_of_calc[3]=s;
               data_for_buffer[x].low=line_main_low[s].down;
               break;
              }
           }
        }
      //--- start the function of synchronizing data
      func_synchronization(data_for_buffer,chart_synchronization,chart_priority_close,chart_priority_open,chart_priority_high,chart_priority_low);
      //--- preparatory actions before starting the function func_date_color
      ZeroMemory(time_array);
      time_variable=0;
      latch=false;
      //--- fill the buffer for drawing candles
      for(int x=ArraySize(data_for_buffer)-1,z=0; x>=0; x--)
        {
         ABCTBBuffer1[z]=data_for_buffer[x].open;
         ABCTBBuffer2[z]=data_for_buffer[x].high;
         ABCTBBuffer3[z]=data_for_buffer[x].low;
         ABCTBBuffer4[z]=data_for_buffer[x].close;
         if(ABCTBBuffer1[z]<=ABCTBBuffer4[z])ABCTBColors[z]=0;
         if(ABCTBBuffer1[z]>=ABCTBBuffer4[z])ABCTBColors[z]=1;
         if(func_date_color(data_for_buffer[x].time)==true && chart_color_period==true)ABCTBColors[z]=2;
         if(ma_draw==true)LINE_TLBBuffer[z]=func_ma(data_for_buffer[x].time);
         z++;
        }
     }
   else// construct a classic chart (based on one price type)
     {
      func_build_three_line_break(rates_array,price,step_min,line_to_back,line_main_close);// find data on selected prices
      ArrayResize(array_datetime,ArraySize(line_main_close));
      //--- preparatory actions before starting the function func_date_color
      ZeroMemory(time_array);
      time_variable=0;
      latch=false;
      //--- fill the buffer for drawing candles
      for(int x=ArraySize(line_main_close)-1,z=0; x>=0; x--)
        {
         ABCTBBuffer1[z]=line_main_close[x].up;
         ABCTBBuffer2[z]=line_main_close[x].up;
         ABCTBBuffer3[z]=line_main_close[x].down;
         ABCTBBuffer4[z]=line_main_close[x].down;
         if(line_main_close[x].type==1)ABCTBColors[z]=0;
         else ABCTBColors[z]=1;
         if(func_date_color(line_main_close[x].time)==true && chart_color_period==true)ABCTBColors[z]=2;
         if(ma_draw==true)LINE_TLBBuffer[z]=func_ma(line_main_close[x].time);
         z++;
        }
     }
  }
//+------------------------------------------------------------------+
// Func Date Color                                                   |
//+------------------------------------------------------------------+
bool func_date_color(
                     datetime date_time// input date
                     )
  {
   bool x=false;// response variable
   int seconds=PeriodSeconds(time_frame);// find out the calculation time range
   MqlDateTime date;
   TimeToStruct(date_time,date);// convert data
   if(latch==false)// check the state of the latch
     {
      MqlDateTime date_0;
      date_0=date;
      date_0.hour=0;
      date_0.min=0;
      date_0.sec=0;
      int difference=date_0.day_of_week-1;
      datetime date_d=StructToTime(date_0);
      date_d=date_d-86400*difference;
      time_variable=date_d;
      latch=true;// lock the latch
     }
   if(seconds<=7200)// period is less than or equal to H2
     {
      if(time_array[0]!=date.day)
        {
         x=true;
         time_array[0]=date.day;
        }
     }
   if(seconds>7200 && seconds<=43200)// period is greater than H2 but less than or equal to H12
     {
      if(time_variable>=date_time)
        {
         x=true;
         time_variable=time_variable-604800;
        }
     }
   if(seconds>43200 && seconds<=86400)// period is greater than H12 but less than or equal to D1
     {
      if(time_array[1]!=date.mon)
        {
         x=true;
         time_array[1]=date.mon;
        }
     }
   if(seconds>86400)// period W1 or MN
     {
      if(time_array[2]!=date.year)
        {
         x=true;
         time_array[2]=date.year;
        }
     }
   return(x);
  }
//+------------------------------------------------------------------+
// Func Synchronization                                              |
//+------------------------------------------------------------------+
void func_synchronization(
                          buffer_info &info[],
                          bool synchronization,
                          char close,
                          char open,
                          char high,
                          char low
                          )
  {
   if(synchronization==true)// carry out a complete synchronization
     {
      int calc=0;// count variable
      for(int x=0; x<ArraySize(info); x++)// count complete data
        {
         if(info[x].close!=0 && info[x].high!=0 && info[x].low!=0 && info[x].open!=0)calc++;
        }
      buffer_info i_info[];// enter a temporary array for copying
      ArrayResize(i_info,calc);// change the size of the temporary array
      calc=0;
      for(int x=0; x<ArraySize(info); x++)// copy data into the temporary array
        {
         if(info[x].close!=0 && info[x].high!=0 && info[x].low!=0 && info[x].open!=0)
           {
            i_info[calc]=info[x];
            calc++;
           }
        }
      ZeroMemory(info);// clear the target array
      ArrayResize(info,calc);// change the size of the main array
      for(int x=0; x<calc; x++)// copy data from the temporary array into the main one
        {
         info[x]=i_info[x];
        }
     }
   if(synchronization==false)// change zero values to priority ones
     {
      int size=ArraySize(info);// measure the size of the array
      double buffer[][4];// create a temporary array for calculation
      ArrayResize(buffer,size);// change the size of the temporary array
      for(int x=0; x<size; x++)// copy data into the temporary array
        {
         buffer[x][0]=info[x].close;
         buffer[x][1]=info[x].open;
         buffer[x][2]=info[x].high;
         buffer[x][3]=info[x].low;
        }
      char p[4];// enter an array for sorting by the order
      p[0]=close; p[1]=open; p[2]=high; p[3]=low;// assign variables for further sorting
      ArraySort(p);// sort
      int z=0,v=0;// initialize frequently used variables
      for(int x=0; x<4; x++)// taking into account the results of the sorting, look through all variables and substitute them according to the priority
        {
         if(p[x]==close)// priority is for the closing prices
           {
            for(z=0; z<size; z++)
              {
               for(v=1; v<4; v++)
                 {
                  if(buffer[z][v]==0)buffer[z][v]=buffer[z][0];
                 }
              }
           }
         if(p[x]==open)// priority is for the opening prices
           {
            for(z=0; z<size; z++)
              {
               for(v=0; v<4; v++)
                 {
                  if(v!=1 && buffer[z][v]==0)buffer[z][v]=buffer[z][1];
                 }
              }
           }
         if(p[x]==high)// priority is for the maximum prices
           {
            for(z=0; z<size; z++)
              {
               for(v=0; v<4; v++)
                 {
                  if(v!=2 && buffer[z][v]==0)buffer[z][v]=buffer[z][2];
                 }
              }
           }
         if(p[x]==low)// priority is for the minimum prices
           {
            for(z=0; z<size; z++)
              {
               for(v=0; v<3; v++)
                 {
                  if(buffer[z][v]==0)buffer[z][v]=buffer[z][3];
                 }
              }
           }
        }
      for(int x=0; x<size; x++)// copy data from the temporary array back
        {
         info[x].close=buffer[x][0];
         info[x].open=buffer[x][1];
         info[x].high=buffer[x][2];
         info[x].low=buffer[x][3];
        }
     }
  }
//+------------------------------------------------------------------+
// Func MA                                                           |
//+------------------------------------------------------------------+
double func_ma(
               datetime date
               )
  {
   double x[1];
   CopyBuffer(handle,0,date,1,x);
   return(x[0]);
  }
//+------------------------------------------------------------------+
//| Func New Bar                                                     |
//+------------------------------------------------------------------+
bool func_new_bar(ENUM_TIMEFRAMES period_time)
  {
//---
   static datetime old_times; // variable of storing old values
   bool res=false;            // variable of the analysis result  
   datetime new_time[1];      // time of a new bar
//---
   int copied=CopyTime(_Symbol,period_time,0,1,new_time); // copy the time of the last bar into the cell new_time  
//---
   if(copied>0) // everything is ок. data copied
     {
      if(old_times!=new_time[0]) // if the old time of the bar is not equal to the new one
        {
         if(old_times!=0) res=true; // if it is not the first start, then new bar = true
         old_times=new_time[0];     // remember the time of the bar
        }
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
