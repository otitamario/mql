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
#property indicator_label2 "Bull"
#property indicator_label3 "Bear"

#property indicator_plots 3                     //Number of graphic plots
#property indicator_type1 DRAW_COLOR_CANDLES    //Drawing style - color candles
#property indicator_width1 3                    //Width of the graphic plot (optional)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



input int periodo=14;// Periodo Bull e Bears

                     //Declaration of buffers
double buffer_open[],buffer_high[],buffer_low[],buffer_close[]; //Buffers for data
double buffer_color_line[]; //Buffer for color indexes
double buffer_bull[];        //Indicator buffer for MA 1
double buffer_bear[];        //Indicator buffer for MA 2

double buffer_tmp1[1],buffer_tmp2[1];       //Temporary buffers for the Bull and Bears data copying
int handle_bull,handle_bear;           //Handle for the  indicators
string s_media1,s_media2;
long curChartID;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   curChartID=ChartID();
   IndicatorSetString(INDICATOR_SHORTNAME,"Bull Bear");

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
   SetIndexBuffer(5,buffer_bull,INDICATOR_DATA);
   SetIndexBuffer(6,buffer_bear,INDICATOR_DATA);

//Define the number of color indexes, used for a graphic plot
   PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,3);

//Set color for each index
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,clrMediumBlue);   //Compra
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,clrRed); //Venda
   PlotIndexSetInteger(0,PLOT_LINE_COLOR,2,clrSilver); //Neutro

                                                          //Get handle of MA indicators, it's necessary to get the MA indicator values
   handle_bull=iBullsPower(Symbol(),Period(),periodo);
   handle_bear=iBearsPower(Symbol(),Period(),periodo);



   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ChartRedraw(ChartID());
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
      CopyBuffer(handle_bull,0,BarsCalculated(handle_bull)-i-1,1,buffer_tmp1);
      CopyBuffer(handle_bear,0,BarsCalculated(handle_bear)-i-1,1,buffer_tmp2);

      //Copying the values from the temporary buffer to the indicator's buffer
      buffer_bull[i]=buffer_tmp1[0];
      buffer_bear[i]=buffer_tmp2[0];
      //Set data for plotting
      buffer_open[i]=open[i];  //Open price
      buffer_high[i]=high[i];  //High price
      buffer_low[i]=low[i];    //Low price
      buffer_close[i]=close[i];//Close price

      bool acima=true;
      bool abaixo=true;
      bool meio=true;
      acima=acima && MathAbs(buffer_bull[i])>2*MathAbs(buffer_bear[i]);
      abaixo=abaixo && 2*MathAbs(buffer_bull[i])<MathAbs(buffer_bear[i]);
      meio=(!acima) && (!abaixo);
      //Add a simple condition -> If RSI less 50%:
      if(acima) buffer_color_line[i]=0.0;
      if(abaixo) buffer_color_line[i]=1.0;
      if(meio) buffer_color_line[i]=2.0;
     }
   return(rates_total-1); //Return the number of calculated bars, 
                          //Subtract 1 for the last bar recalculation
  }
//+------------------------------------------------------------------+
