//+------------------------------------------------------------------+
//|                                                   cand_color.mq5 |
//|                                                             ProF |
//|                                                          http:// |
//+------------------------------------------------------------------+
#property copyright "Mario"                      //Author
#property indicator_chart_window                //Indicator in separate window

                                                //Specify the number of buffers
//4 buffer for the candles + 1 color buffer + 4 buffer to serve the Medias data
#property indicator_buffers 7

//Specify the names, shown in the Data Window
#property indicator_label1 "Open;High;Low;Close"

#property indicator_plots 1                     //Number of graphic plots
#property indicator_type1 DRAW_COLOR_CANDLES    //Drawing style - color candles
#property indicator_width1 3                    //Width of the graphic plot (optional)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

enum ENUM_RENKO_TYPE
  {
   RENKO_TYPE_TICKS, //Ticks
   RENKO_TYPE_PIPS, //Pips
   RENKO_TYPE_POINTS //Points
  };

input ENUM_RENKO_TYPE RenkoType=RENKO_TYPE_TICKS; //Renko Type
input double RenkoSize=5; //Renko Size (Ticks, Pips or Points)
input bool RenkoWicks= true; //Show Wicks
input int RenkoRedraw = 200; //Renko chart redraw (Less bars is faster)



input int periodo1=10;// Periodo Media 1
input int periodo2=20;// Periodo Media 2


                                                //Declaration of buffers
double buffer_open[],buffer_high[],buffer_low[],buffer_close[]; //Buffers for data
double buffer_color_line[]; //Buffer for color indexes
double buffer_ma1[];        //Indicator buffer for MA 1
double buffer_ma2[];        //Indicator buffer for MA 2

double buffer_tmp1[1],buffer_tmp2[1];       //Temporary buffers for the Medias data copying
int handle_ma1,handle_ma2,renko_handle;           //Handle for the MA indicators
string s_media1,s_media2;
long curChartID;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  
  curChartID=ChartID();
     IndicatorSetString(INDICATOR_SHORTNAME,"velas exponenciais");

/**
        *       The order of the buffers assign is VERY IMPORTANT!
        *  The data buffers are first
        *       The color buffers are next
        *       And finally, the buffers for the internal calculations.
        */
//Assign the arrays with the indicator's buffers
   SetIndexBuffer(0,buffer_open,INDICATOR_DATA);
   SetIndexBuffer(1,buffer_high,INDICATOR_DATA);
   SetIndexBuffer(2,buffer_low,INDICATOR_DATA);
   SetIndexBuffer(3,buffer_close,INDICATOR_DATA);

//Assign the array with color indexes with the indicator's color indexes buffer
   SetIndexBuffer(4,buffer_color_line,INDICATOR_COLOR_INDEX);

//Assign the array with the buffer of MA indicator data
   SetIndexBuffer(5,buffer_ma1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,buffer_ma2,INDICATOR_CALCULATIONS);
   
//Define the number of color indexes, used for a graphic plot
   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,3);

//Set color for each index
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,White);   //Zeroth index -> Branco ( ACIMA das medias)
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,Magenta); //First index  -> Rosa (ABAIXO das medias)
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,2,Yellow); //Second index  -> Amarelo (caso contrário)


                                                    //Get handle of MA indicators, it's necessary to get the MA indicator values
   renko_handle=iCustom(Symbol(),PERIOD_CURRENT,"renko2",RenkoType,RenkoSize,RenkoWicks,RenkoRedraw);

   handle_ma1=iMA(Symbol(),PERIOD_CURRENT,periodo1,0,MODE_EMA,PRICE_CLOSE);
   handle_ma2=iMA(Symbol(),PERIOD_CURRENT,periodo2,0,MODE_EMA,PRICE_CLOSE);
   
   ChartIndicatorAdd(curChartID,0,handle_ma1);
   ChartIndicatorAdd(curChartID,0,handle_ma2);
   
   
   s_media1="MA("+string(periodo1)+")";
   s_media2="MA("+string(periodo2)+")";
   
   
   return(INIT_SUCCEEDED);
  }
  
  void OnDeinit(const int reason)
  {
  Comment("");
    ChartIndicatorDelete(curChartID,0,s_media1);
  
  ChartIndicatorDelete(curChartID,0,s_media2);
  //IndicatorRelease(handle_ma2);
  
  
  }
  
 
//+------------------------------------------------------------------+
//| Custom indicator calculation function                            |
//+-----------------------------------------------------------------+
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
//In the loop we fill the data buffers and color indexes buffers for each bar
   for(int i=prev_calculated;i<=rates_total-1;i++)
     {
      //Copying the MA indicator's data to the temporary buffer - buffer_tmp
      CopyBuffer(handle_ma1,0,BarsCalculated(handle_ma1)-i-1,1,buffer_tmp1);
      CopyBuffer(handle_ma2,0,BarsCalculated(handle_ma2)-i-1,1,buffer_tmp2);
      
      //Copying the values from the temporary buffer to the indicator's buffer
      buffer_ma1[i]=buffer_tmp1[0];
      buffer_ma2[i]=buffer_tmp2[0];
      //Set data for plotting
      buffer_open[i]=open[i];  //Open price
      buffer_high[i]=high[i];  //High price
      buffer_low[i]=low[i];    //Low price
      buffer_close[i]=close[i];//Close price

      bool acima_media=true;
      bool abaixo_media=true;
      
       acima_media=acima_media&& (close[i]>buffer_ma1[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_ma1[i]);
      
       acima_media=acima_media&& (close[i]>buffer_ma2[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_ma2[i]);
      
      
      bool meio=(!acima_media) && (!abaixo_media);
      
                               //Add a simple condition -> If RSI less 50%:
      if(acima_media) buffer_color_line[i]=0; 
      if (abaixo_media) buffer_color_line[i]=1;
      if (meio) buffer_color_line[i]=2;
     }
   return(rates_total-1); //Return the number of calculated bars, 
                          //Subtract 1 for the last bar recalculation
  }
//+------------------------------------------------------------------+
