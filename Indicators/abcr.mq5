//+------------------------------------------------------------------+
//|                                                         ABCR.mq5 |
//|                                   Azotskiy Aktiniy ICQ:695710750 |
//|                          https://login.mql5.com/ru/users/Aktiniy |
//+------------------------------------------------------------------+
//--- Auto Build Chart Renko
#property copyright "Azotskiy Aktiniy ICQ:695710750"
#property link      "https://login.mql5.com/ru/users/Aktiniy"
#property version   "1.00"
#property description "Auto Build Chart Renko"
#property description "   "
#property description "This indicator makes drawing a chart Renko as a matter of indicator window, and in the main chart window"
#property indicator_separate_window
#property indicator_buffers 9
#property indicator_plots   1
//--- plot RENKO
#property indicator_label1  "RENKO"
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  clrBlue,clrRed,C'0,0,0',C'0,0,0',C'0,0,0',C'0,0,0',C'0,0,0',C'0,0,0'
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- charting principle
enum type_step_renko
  {
   point=0,   // Point
   percent=1, // Percent
  };
//--- type of price for charting
enum type_price_renko
  {
   close=0, // Close
   open=1,  // Open
   high=2,  // High
   low=3,   // Low
  };
//--- input parameters
input double           step=10;                                 // Step
input type_step_renko  type_step=point;                         // Type of step
input long             magic_numb=65758473787389;               // magic number
input int              levels_number=1000;                      // Number of levels (0-no levels)
input color            levels_color=clrLavender;                // Color of levels
input ENUM_TIMEFRAMES  time_frame=PERIOD_CURRENT;               // Enumeration period
input ENUM_TIMEFRAMES  time_redraw=PERIOD_M1;                   // Time for redrawing the chart
input datetime         first_date_start=D'2013.09.13 00:00:00'; // Start date
input type_price_renko type_price=close;                        // type of the price for charting
input bool             shadow_print=true;                       // If to display shadows (prices created several bricks)
input int              filter_number=0;                         // Value for number of bricks for reversal
input bool             zig_zag=true;                            // Draw ZigZag on the main chart
input bool             zig_zag_shadow=true;                     // Draw ZigZag on maximum and minimum prices
input int              zig_zag_width=2;                         // ZigZag line width
input color            zig_zag_color_up=clrBlue;                // ZigZag upwards line color
input color            zig_zag_color_down=clrRed;               // ZigZag downwards line color
input bool             square_draw=true;                        // If to draw bricks on the main chart
input color            square_color_up=clrBlue;                 // Brick color on the main upwards chart
input color            square_color_down=clrRed;                // Brick color on the main downwards chart
input bool             square_fill=true;                        // Brick coloring on the main chart
input int              square_width=2;                          // Brick line width on the main chart
input bool             frame_draw=true;                         // If to draw frames of the bricks
input int              frame_width=2;                           // The brick frame line width
input color            frame_color_up=clrBlue;                  // Color of upwards bricks frames
input color            frame_color_down=clrRed;                 // Color of downwards bricks frames
//--- indicator buffers
double         RENKO_open[];
double         RENKO_high[];
double         RENKO_low[];
double         RENKO_close[];
double         RENKO_color[];

double         Price[];      // Buffer for storing the copied prices
double         Date[];       // Buffer for storing the copied dates
double         Price_high[]; // Buffer for storing the copied high prices
double         Price_low[];  // Buffer for storing the copied low prices
//--- Calculating buffers arrays
double         up_price[];    // Up price of the brick
double         down_price[];  // Low price of the brick
char           type_box[];    // Type of the brick (upside, downside)
datetime       time_box[];    // Time of closing the brick
double         shadow_up[];   // Limit up
double         shadow_down[]; // Limit down
int            number_id[];   // Index of the Price_high and Price_low arrays
//--- Global variables for calculations
int obj=0;           // variable for storing the number of graphical objects
int a=0;             // Variable for the calculation of bricks
int bars;            // Number of bars
datetime date_stop;  // Current date
datetime date_start; // Variable of the start date, for calculations
bool date_change;    // Variable for storing information about changes of time
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,RENKO_open,INDICATOR_DATA);
   ArraySetAsSeries(RENKO_open,true);
   SetIndexBuffer(1,RENKO_high,INDICATOR_DATA);
   ArraySetAsSeries(RENKO_high,true);
   SetIndexBuffer(2,RENKO_low,INDICATOR_DATA);
   ArraySetAsSeries(RENKO_low,true);
   SetIndexBuffer(3,RENKO_close,INDICATOR_DATA);
   ArraySetAsSeries(RENKO_close,true);
   SetIndexBuffer(4,RENKO_color,INDICATOR_COLOR_INDEX);
   ArraySetAsSeries(RENKO_color,true);
//---
   SetIndexBuffer(5,Price,INDICATOR_CALCULATIONS);      // Initialize buffer for prices
   SetIndexBuffer(6,Date,INDICATOR_CALCULATIONS);       // Initialize buffer for dates
   SetIndexBuffer(7,Price_high,INDICATOR_CALCULATIONS); // Initialize buffer for high prices
   SetIndexBuffer(8,Price_low,INDICATOR_CALCULATIONS);  // Initialize buffer for low prices
//--- Set what values are not to be drawn
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
//--- Set the appearance of the indicator
   IndicatorSetString(INDICATOR_SHORTNAME,"ABCR "+IntegerToString(magic_numb)); // name of the indicator
//--- Accuracy of the display
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- prohibit display of the current indicator values results
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
//--- assign the value of the start date variable
   date_start=first_date_start;
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
      func_concolidation();
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| OnChartEvent                                                     |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // Event identificator  
                  const long& lparam,   // The long event parameter
                  const double& dparam, // The double event parameter
                  const string& sparam) // The string event parameter
  {
//--- keyboard press event
   if(id==CHARTEVENT_KEYDOWN)
     {
      if(lparam==82) //--- "R" key was pressed
        {
         //--- The consolidation function call
         func_concolidation();
        }
      if(lparam==67) //--- "C" key was pressed
        {
         //--- clear the chart from the indicator objects
         func_all_delete();
        }
     }
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+ 
void OnDeinit(const int reason)
  {
//--- clear the chart from the indicator objects
   func_all_delete();
  }
//+------------------------------------------------------------------+
//| Func All Delete                                                  |
//+------------------------------------------------------------------+
void func_all_delete()
  {
//--- calculate the graphical objects
   obj=ObjectsTotal(0,-1,-1);
//--- Delete graphical objects of the indicator
   func_delete_objects(IntegerToString(magic_numb)+"_Line_",obj);
   func_delete_objects(IntegerToString(magic_numb)+"_Square_",obj);
   func_delete_objects(IntegerToString(magic_numb)+"_Frame_",obj);
//--- Redraw the chart
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Func Consolidation                                               |
//+------------------------------------------------------------------+
void func_concolidation()
  {
//--- Delete graphical objects of the indicator
   func_all_delete();
//--- Get the current date
   date_stop=TimeCurrent();
//--- change the start date due to the limited size of the buffer
   if((bars=Bars(_Symbol,time_frame,date_start,date_stop))>ArraySize(Price))
     {
      date_start=func_calc_date_start(date_start,date_stop);
      Alert("The start date was changed by the system due to the lack of the chart size");
      date_change=true;
      //--- calculate number of bars on the timeframe
      bars=Bars(_Symbol,time_frame,date_start,date_stop);
     }
//---
   bool result_copy_price=func_copy_price(Price,time_frame,date_start,date_stop,type_price);
   bool result_copy_date=func_copy_date(Date,time_frame,date_start,date_stop);
//--- Change the parameter of the date change
   if(result_copy_price=true && result_copy_date==true)date_change=false;
//---
   if(zig_zag_shadow==true)
     {
      func_copy_price(Price_high,time_frame,date_start,date_stop,2);
      func_copy_price(Price_low,time_frame,date_start,date_stop,3);
     }
//---
   func_draw_renko(Price,Date,filter_number,shadow_print,type_step,step);
   if(zig_zag==true)func_draw_zig_zag(zig_zag_shadow,zig_zag_width,zig_zag_color_up,zig_zag_color_down);
//---
   func_draw_renko_main_chart(square_color_up,square_color_down,frame_color_up,frame_color_down,square_width,frame_width,square_draw,square_fill,frame_draw);
   func_create_levels(levels_number,levels_color);
//--- Redrawing the chart
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//| Func Calculate Date Start                                        |
//+------------------------------------------------------------------+
datetime func_calc_date_start(datetime input_data_start,// initially assigned start date
                              datetime data_stop)       // Date to stop the calculations (current date)
//---
  {
   int Array_Size=ArraySize(Price);
   int Bars_Size=Bars(_Symbol,time_frame,input_data_start,data_stop);
   for(;Bars_Size>Array_Size;input_data_start+=864000) // 864000 = 10 days
     {
      Bars_Size=Bars(_Symbol,time_frame,input_data_start,data_stop);
     }
   return(input_data_start);
//---
  }
//+------------------------------------------------------------------+
//| Func Copy Price                                                  |
//+------------------------------------------------------------------+
bool func_copy_price(double &result_array[],
                     ENUM_TIMEFRAMES period,// Time frame
                     datetime data_start,
                     datetime data_stop,
                     char price_type) // 0-Close, 1-Open, 2-High, 3-Low
  {
//---
   int x=false;        // Variable for answer
   int result_copy=-1; // Number of copied data
//---
   static double price_interim[]; // temporary dynamic array for storing the copied data
   static int bars_to_copy;       // Number of bars for copying
   static int bars_copied_0;      // Number of copied bars from the Close start date
   static int bars_copied_1;      // Number of copied bars from the Open start date
   static int bars_copied_2;      // Number of copied bars from the High start date
   static int bars_copied_3;      // Number of copied bars from the Low start date
   static int bars_copied;        // Number of copied bars from the common variable date
//--- zeroing out the variables due to the start date changes
   if(date_change==true)
     {
      ZeroMemory(price_interim);
      ZeroMemory(bars_to_copy);
      ZeroMemory(bars_copied_0);
      ZeroMemory(bars_copied_1);
      ZeroMemory(bars_copied_2);
      ZeroMemory(bars_copied_3);
      ZeroMemory(bars_copied);
     }
//--- find out the current number of bars on the timeframe
   bars_to_copy=Bars(_Symbol,period,data_start,data_stop);
//--- Assign the common variable value of one of the copied variables
   switch(price_type)
     {
      case 0:
         //--- Close
         bars_copied=bars_copied_0;
         break;
      case 1:
         //--- Open
         bars_copied=bars_copied_1;
         break;
      case 2:
         //--- High
         bars_copied=bars_copied_2;
         break;
      case 3:
         //--- Low
         bars_copied=bars_copied_3;
         break;
     }
//--- calculate number of bars not to be copied
   bars_to_copy-=bars_copied;
//--- If it is not the first time the data has been copied
   if(bars_copied!=0)
     {
      bars_copied--;
      bars_to_copy++;
     }
//--- Change the size of the receiving array
   ArrayResize(price_interim,bars_to_copy);
//--- Copy the data to the temporary array
   switch(price_type)
     {
      case 0:
         //--- Close
        {
         result_copy=CopyClose(_Symbol,period,0,bars_to_copy,price_interim);
        }
      break;
      case 1:
         //--- Open
        {
         result_copy=CopyOpen(_Symbol,period,0,bars_to_copy,price_interim);
        }
      break;
      case 2:
         //--- High
        {
         result_copy=CopyHigh(_Symbol,period,0,bars_to_copy,price_interim);
        }
      break;
      case 3:
         //--- Low
        {
         result_copy=CopyLow(_Symbol,period,0,bars_to_copy,price_interim);
        }
      break;
     }
//--- Check the result of the copied data
   if(result_copy!=-1) // If copying to the intermediate array is successful
     {
      ArrayCopy(result_array,price_interim,bars_copied,0,WHOLE_ARRAY); // Copy the data from the temporary array to the main one
      x=true;                   // assign the positive answer to the function
      bars_copied+=result_copy; // Increase the value of the processed data
     }
//--- reset the copied data information with one of the processed variables
   switch(price_type)
     {
      case 0:
         //--- Close
         bars_copied_0=bars_copied;
         break;
      case 1:
         //--- Open
         bars_copied_1=bars_copied;
         break;
      case 2:
         //--- High
         bars_copied_2=bars_copied;
         break;
      case 3:
         //--- Low
         bars_copied_3=bars_copied;
         break;
     }
//---
   return(x);
  }
//+------------------------------------------------------------------+
//| Func Copy Date                                                   |
//+------------------------------------------------------------------+
bool func_copy_date(double &result_array[],
                    ENUM_TIMEFRAMES period,// timeframe
                    datetime data_start,
                    datetime data_stop)
  {
//---
   int x=false;                    // variable for answer
   int result_copy=-1;             // number of copied data
   static datetime time_interim[]; // temporary dynamic array for storing the copied data
   static int bars_to_copy;        // number of bars for copying
   static int bars_copied;         // number of copied bars with the start date
//--- zeroing out the variables due to the start date changes
   if(date_change==true)
     {
      ZeroMemory(time_interim);
      ZeroMemory(bars_to_copy);
      ZeroMemory(bars_copied);
     }
//---
   // Find out the current number of bars on the timeframe
   //calculate number of bars not to be copied
//---
   // If it is not the first time the data has been copied
     {
      bars_copied--;
      bars_to_copy++;
     }
//---
   // Change the size of the receiving array
   result_copy=CopyTime(_Symbol,period,0,bars_to_copy,time_interim);
//---
   if(result_copy!=-1) // If copying to the intermediate array is successful
     {
      ArrayCopy(result_array,time_interim,bars_copied,0,WHOLE_ARRAY); // Copy the data from the temporary array to the main one
      x=true; // assign the positive answer to the function
      bars_copied+=result_copy; // Increase the value of the processed data
     }
//---
   return(x);
  }
//+------------------------------------------------------------------+
//| Func Calculate Doorstep                                          |
//+------------------------------------------------------------------+
int func_calc_dorstep(double price,      // price
                      char type_doorstep,// type of step
                      double doorstep)   // step
  {
   double x=0; // variable for answer

   if(type_doorstep==0) // If the calculation is to be performed in points
     {
      x=doorstep;
     }

   if(type_doorstep==1) // If the calculation is to be performed in percentage
     {
      x=price/_Point*doorstep/100;
     }

   return((int)x);
  }
//+------------------------------------------------------------------+
//| Func Draw Renko                                                  |
//+------------------------------------------------------------------+
void func_draw_renko(double &price[],   // Prices array
                     double &date[],    // Dates array
                     int number_filter, // Number of bricks for reversal
                     bool draw_shadow,  // Draw the shadow
                     char type_doorstep,// type of step
                     double doorstep)   // step
  {
//--- Zeroing out the arrays
//--- Drawing buffers arrays
   ZeroMemory(RENKO_close);
   ZeroMemory(RENKO_color);
   ZeroMemory(RENKO_high);
   ZeroMemory(RENKO_low);
   ZeroMemory(RENKO_open);
//--- auxiliary variables for calculations
   int doorstep_now; // Current step
   int point_go;     // passed points
//--- Auxiliary variables for calculating number of bricks
   a=0;
   double up_price_calc=price[0];
   double down_price_calc=price[0];
   char type_box_calc=0;

   for(int z=0; z<bars; z++) //---> loop for bricks calculating
     {
      //--- calculate the step size considering the current price
      doorstep_now=func_calc_dorstep(price[z],type_doorstep,doorstep);
      //--- If the price moves upwards
      if((price[z]-up_price_calc)/_Point>=doorstep_now)
        {
         //--- Calculate number of passed points
         point_go=int((price[z]-up_price_calc)/_Point);
         //--- The price has moved upwards before that and its direction is unknown
         if(type_box_calc==1 || type_box_calc==0)
           {
            for(int y=point_go; y>=doorstep_now; y-=doorstep_now)
              {
               //--- Add the next brick
               a++;
               //--- Set the value for the low price of the next brick
               down_price_calc=up_price_calc;
               //--- Set the value for the high price of the next brick
               up_price_calc=down_price_calc+(doorstep_now*_Point);
               //--- Set the brick type (upwards)
               type_box_calc=1;
              }
           }
         //--- the price moved downwards
         if(type_box_calc==-1)
           {
            if((point_go/doorstep_now)>=number_filter)
              {
               for(int y=point_go; y>=doorstep_now; y-=doorstep_now)
                 {
                  //--- Add the next brick
                  a++;
                  //--- Set the value for the low price of the next brick
                  down_price_calc=up_price_calc;
                  //--- Set the value for the high price of the next brick
                  up_price_calc=down_price_calc+(doorstep_now*_Point);
                  //--- Set the brick type (upwards)
                  type_box_calc=1;
                 }
              }
           }
        }
      //--- if the price moves upwards
      if((down_price_calc-price[z])/_Point>=doorstep_now)
        {
         //--- Calculate number of passed points
         point_go=int((down_price_calc-price[z])/_Point);
         //--- the price has moved downwards before that or the previous direction is unknown
         if(type_box_calc==-1 || type_box_calc==0)
           {
            for(int y=point_go; y>=doorstep_now; y-=doorstep_now)
              {
               //--- Add the next brick
               a++;
               //--- Set the value for the low price of the next brick
               up_price_calc=down_price_calc;
               //--- Set the value for the high price of the next brick
               down_price_calc=up_price_calc-(doorstep_now*_Point);
               //--- Set the brick type (upwards)
               type_box_calc=-1;
              }
           }
         //--- the price moved upwards
         if(type_box_calc==1)
           {
            if((point_go/doorstep_now)>=number_filter)
              {
               for(int y=point_go; y>=doorstep_now; y-=doorstep_now)
                 {
                  //--- Add the next brick
                  a++;
                  //--- Set the value for the low price of the next brick
                  up_price_calc=down_price_calc;
                  //--- Set the value for the high price of the next brick
                  down_price_calc=up_price_calc-(doorstep_now*_Point);
                  //--- Set the brick type (upwards)
                  type_box_calc=-1;
                 }
              }
           }
        }
     } //---< Bricks calculating loop
//--- calculate the number of the displayed bars
   int b=Bars(_Symbol,PERIOD_CURRENT);
//--- change sizes of the arrays
   ArrayResize(up_price,b);
   ArrayResize(down_price,b);
   ArrayResize(type_box,b);
   ArrayResize(time_box,b);
   ArrayResize(shadow_up,b);
   ArrayResize(shadow_down,b);
   ArrayResize(number_id,b);
//--- zeroing out the calculating buffers arrays
   ZeroMemory(up_price);
   ZeroMemory(down_price);
   ZeroMemory(type_box);
   ZeroMemory(time_box);
   ZeroMemory(shadow_up);
   ZeroMemory(shadow_down);
   ZeroMemory(number_id);
//--- filling the arrays with the initial values
   up_price[0]=price[0];
   down_price[0]=price[0];
   type_box[0]=0;
//--- calculate number of extra bricks
   int l=a-b;
   int turn_cycle=l/(b-1);
   int turn_rest=(int)MathMod(l,(b-1))+2;
   int turn_var=0;
//--- Display the message of the partially mapped bricks
   if(a>b)Alert("Bricks number is more than can be put on the chart, the possibility of the small step");

   a=0; //--- Zeroing out the bricks calculating variable
   for(int z=0; z<bars; z++) //---> Main loop
     {
      //--- calculate the step size considering the current price
      doorstep_now=func_calc_dorstep(price[z],type_doorstep,doorstep);
      //--- If the price moves upwards
      if((price[z]-up_price[a])/_Point>=doorstep_now)
        {
         //--- Calculate number of passed points
         point_go=int((price[z]-up_price[a])/_Point);
         //--- The price has moved upwards before that and its direction is unknown
         if(type_box[a]==1 || type_box[a]==0)
           {
            for(int y=point_go; y>=doorstep_now; y-=doorstep_now)
              {
               a++; //--- add the next brick
               if((a==b && turn_var<turn_cycle) || (turn_var==turn_cycle && turn_rest==a))
                 {
                  up_price[0]=up_price[a-1];
                  a=1;        // reset the bricks counter
                  turn_var++; // counter of the reset loops
                 }
               //--- Set the value for the low price of the next brick
               down_price[a]=up_price[a-1];
               //--- Set the value for the high price of the next brick
               up_price[a]=down_price[a]+(doorstep_now*_Point);

               //--- set the up shadow value
               if(shadow_print==true) shadow_up[a]=price[z]; // to the level of the last highest price 
               else shadow_up[a]=up_price[a];                // to the level of the brick up price 

               //--- set the value of the down price (the brick price level)
               shadow_down[a]=down_price[a];
               //--- set the brick closing time value
               time_box[a]=(datetime)Date[z];
               //--- Set the brick type (upwards)
               type_box[a]=1;
               //--- index setting
               number_id[a]=z;
              }
           }
         //--- the price moved downwards
         if(type_box[a]==-1)
           {
            if((point_go/doorstep_now)>=number_filter)
              {
               for(int y=point_go; y>=doorstep_now; y-=doorstep_now)
                 {
                  a++; //--- add the next brick

                  if((a==b && turn_var<turn_cycle) || (turn_var==turn_cycle && turn_rest==a))
                    {
                     up_price[0]=up_price[a-1];
                     a=1;        // reset the bricks counter
                     turn_var++; // counter of the reset loops
                    }
                  //--- Set the value for the low price of the next brick
                  down_price[a]=up_price[a-1];
                  //--- Set the value for the high price of the next brick
                  up_price[a]=down_price[a]+(doorstep_now*_Point);

                  //--- set the up shadow value
                  if(shadow_print==true) shadow_up[a]=price[z]; // to the level of the last highest price
                  else shadow_up[a]=up_price[a];                // to the level of the brick up price

                  //--- set the value of the down price (the brick price level)
                  shadow_down[a]=down_price[a];
                  //--- set the brick closing time value
                  time_box[a]=(datetime)Date[z];
                  //--- Set the brick type (upwards)
                  type_box[a]=1;
                  //--- index setting
                  number_id[a]=z;
                 }
              }
           }
        }

      //--- if the price moves upwards
      if((down_price[a]-price[z])/_Point>=doorstep_now)
        {
         //--- Calculate number of passed points
         point_go=int((down_price[a]-price[z])/_Point);
         //--- the price has moved downwards before that or the previous direction is unknown
         if(type_box[a]==-1 || type_box[a]==0)
           {
            for(int y=point_go; y>=doorstep_now; y-=doorstep_now)
              {
               a++; //--- add the next brick
               if((a==b && turn_var<turn_cycle) || (turn_var==turn_cycle && turn_rest==a))
                 {
                  down_price[0]=down_price[a-1];
                  a=1;        // reset the bricks counter
                  turn_var++; // counter of the reset loops
                 }
               //--- Set the value for the low price of the next brick
               up_price[a]=down_price[a-1];
               //--- Set the value for the high price of the next brick
               down_price[a]=up_price[a]-(doorstep_now*_Point);

               //--- set the down shadow value 
               if(shadow_print==true) shadow_down[a]=price[z]; // to the level of the last lowest price
               else shadow_down[a]=down_price[a];              // to the level of the low price of the brick

               //--- set the up price value (the brick price level)
               shadow_up[a]=up_price[a];
               //--- set the brick closing time value
               time_box[a]=(datetime)Date[z];
               //--- set the brick type (down)
               type_box[a]=-1;
               //--- index setting
               number_id[a]=z;
              }
           }
         //--- the price moved upwards
         if(type_box[a]==1)
           {
            if((point_go/doorstep_now)>=number_filter)
              {
               for(int y=point_go; y>=doorstep_now; y-=doorstep_now)
                 {
                  a++; //--- add the next brick
                  if((a==b && turn_var<turn_cycle) || (turn_var==turn_cycle && turn_rest==a))
                    {
                     down_price[0]=down_price[a-1];
                     a=1;        // reset the bricks counter
                     turn_var++; // counter of the reset loops
                    }

                  //--- Set the value for the low price of the next brick
                  up_price[a]=down_price[a-1];
                  //--- Set the value for the high price of the next brick
                  down_price[a]=up_price[a]-(doorstep_now*_Point);

                  //--- set the down shadow value 
                  if(shadow_print==true) shadow_down[a]=price[z]; // to the level of the last lowest price
                  else shadow_down[a]=down_price[a];              // to the level of the low price of the brick

                  //--- set the up price value (the brick price level)
                  shadow_up[a]=up_price[a];
                  //--- set the brick closing time value
                  time_box[a]=(datetime)Date[z];
                  //--- set the brick type (down)
                  type_box[a]=-1;
                  //--- index setting
                  number_id[a]=z;
                 }
              }
           }
        }
     } //---< main loop

//--- fill the drawing buffers
   int y=a;
   for(int z=0; z<a; z++)
     {
      if(type_box[y]==1)RENKO_color[z]=0;
      else RENKO_color[z]=1;
      RENKO_open[z]=down_price[y];
      RENKO_close[z]=up_price[y];
      RENKO_high[z]=shadow_up[y];
      RENKO_low[z]=shadow_down[y];
      y--;
     }
  }
//+------------------------------------------------------------------+
//| Func Create Trend Line                                           |
//+------------------------------------------------------------------+
void func_create_trend_line(string name,
                            double price1,
                            double price2,
                            datetime time1,
                            datetime time2,
                            int width,
                            color color_line)
  {
   ObjectCreate(0,name,OBJ_TREND,0,time1,price1,time2,price2);
//--- set the line color
   ObjectSetInteger(0,name,OBJPROP_COLOR,color_line);
//--- set the line display style
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
//--- set the line width
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
//--- display on the foreground (false) or the background (true)
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
//--- enable (true) or disable (false) the mode of the line displaying to the left
   ObjectSetInteger(0,name,OBJPROP_RAY_LEFT,false);
//--- enable (true) or disable (false) the mode of the line displaying to the right
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
  }
//+------------------------------------------------------------------+
//| Func Draw Zig Zag                                                |
//+------------------------------------------------------------------+
void func_draw_zig_zag(bool price_shadow,
                       int line_width,
                       color line_color_up,
                       color line_color_down)
  {
   double price_1=0;
   double price_2=0;
   datetime date_1=0;
   datetime date_2=0;

   if(type_box[1]==1)price_1=down_price[1];
   if(type_box[1]==-1)price_1=up_price[1];
   date_1=time_box[1];
   int id=0; // variable to store the Low & High array identificator
   int n=0;  // variable for naming

   string name_line; //--- variable responsible for the "trend line" object name

   for(int z=2; z<=a; z++)
     {
      if(type_box[z]!=type_box[z-1])
        {
         n++;
         name_line=IntegerToString(magic_numb)+"_Line_"+IntegerToString(n);
         if(type_box[z]==1)
           {
            if(price_shadow==true)
              {
               id=number_id[z-1];
               if((id-1)>0 && Price_low[id-1]<Price_low[id])id--;
               if(Price_low[id+1]<Price_low[id])id++;
               price_2=Price_low[id];
               date_2=(datetime)Date[id];
              }
            else
              {
               price_2=down_price[z-1];
               date_2=time_box[z-1];
              }
            func_create_trend_line(name_line,price_1,price_2,date_1,date_2,line_width,line_color_down);
            price_1=price_2;
            date_1=date_2;
           }
         if(type_box[z]==-1)
           {
            if(price_shadow==true)
              {
               id=number_id[z-1];
               if((id-1)>0 && Price_high[id-1]>Price_high[id])id--;
               if(Price_high[id+1]>Price_high[id])id++;
               price_2=Price_high[id];
               date_2=(datetime)Date[id];
              }
            else
              {
               price_2=up_price[z-1];
               date_2=time_box[z-1];
              }
            func_create_trend_line(name_line,price_1,price_2,date_1,date_2,line_width,line_color_up);
            price_1=price_2;
            date_1=date_2;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Func Create Square or Rectangle                                  |
//+------------------------------------------------------------------+
void func_create_square_or_rectangle(string name,
                                     double price1,
                                     double price2,
                                     datetime time1,
                                     datetime time2,
                                     int width,
                                     color color_square,
                                     bool fill)
  {
//--- create the rectangle on the set points 
   ObjectCreate(0,name,OBJ_RECTANGLE,0,time1,price1,time2,price2);
//--- set the rectangle color
   ObjectSetInteger(0,name,OBJPROP_COLOR,color_square);
//--- Set the style of the rectangle lines
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
//--- set the width of the rectangle lines
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
//--- enable (true) or disable (false) the mode for filling the rectangle
   ObjectSetInteger(0,name,OBJPROP_FILL,fill);
//--- display on the foreground (false) or the background (true)
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
  }
//+------------------------------------------------------------------+
//| Func Draw Renko Main Chart                                       |
//+------------------------------------------------------------------+
void func_draw_renko_main_chart(color color_square_up,
                                color color_square_down,
                                color color_frame_up,
                                color color_frame_down,
                                int width_square,
                                int width_frame,
                                bool square,
                                bool fill,
                                bool frame)
  {
   string name_square;
   string name_frame;

   for(int z=2; z<=a; z++)
     {
      name_square=IntegerToString(magic_numb)+"_Square_"+IntegerToString(z);
      name_frame=IntegerToString(magic_numb)+"_Frame_"+IntegerToString(z);
      if(type_box[z]==1)
        {
         if(square==true)func_create_square_or_rectangle(name_square,up_price[z],down_price[z],time_box[z-1],time_box[z],width_square,color_square_up,fill);
         if(frame==true)func_create_square_or_rectangle(name_frame,up_price[z],down_price[z],time_box[z-1],time_box[z],width_frame,color_frame_up,false);
        }
      if(type_box[z]==-1)
        {
         if(square==true)func_create_square_or_rectangle(name_square,up_price[z],down_price[z],time_box[z-1],time_box[z],width_square,color_square_down,fill);
         if(frame==true)func_create_square_or_rectangle(name_frame,up_price[z],down_price[z],time_box[z-1],time_box[z],width_frame,color_frame_down,false);
        }
     }
  }
//+------------------------------------------------------------------+
//| Func Create Levels                                               |
//+------------------------------------------------------------------+
void func_create_levels(int level_number,
                        color level_color)
  {
//--- set number of levels in the indicator window
   IndicatorSetInteger(INDICATOR_LEVELS,level_number);
//--- from which brick to start drawing levels
   int k=0;
   if(a>level_number)k=a-level_number;
//--- assign prices of the levels
   for(int z=0;(z<=level_number && k<=a); z++,k++)
     {
      IndicatorSetDouble(INDICATOR_LEVELVALUE,z,up_price[k]);
      IndicatorSetInteger(INDICATOR_LEVELCOLOR,z,level_color);
     }
  }
//+------------------------------------------------------------------+
//| Func Delete Objects                                              |
//+------------------------------------------------------------------+
void func_delete_objects(string name,
                         int number)
  {
   string name_del;
   for(int x=0; x<=number; x++)
     {
      name_del=name+IntegerToString(x);
      ObjectDelete(0,name_del);
     }
  }
//+------------------------------------------------------------------+
//| Func New Bar                                                     |
//+------------------------------------------------------------------+
bool func_new_bar(ENUM_TIMEFRAMES period_time)
  {
//---
   static datetime old_times; // variable for storing old values
   bool res=false;            // variable for the analysis result  
   datetime new_time[1];      // time of a new bar
//---
   int copied=CopyTime(_Symbol,period_time,0,1,new_time); // copy the last bar time into the new_time cell  
//---
   if(copied>0) // все ок. Data have been copied
     {
      if(old_times!=new_time[0]) // if the old time of the bar is not equal to new one
        {
         if(old_times!=0) res=true; // if it is not the fisrt launch, true = new bar
         old_times=new_time[0];     // store the bar's time
        }
     }
//---
   return(res);
  }
//+------------------------------------------------------------------+
