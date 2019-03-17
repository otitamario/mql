//=====================================================================
//	Trend indicator.
//=====================================================================
//---------------------------------------------------------------------
#include <MovingAverages.mqh>
//---------------------------------------------------------------------
#property copyright 	"Dima S."
#property link      	"dimascub@mail.com"
#property version   	"1.00"
#property description "Trend indicator based on fan of moving averages."
//---------------------------------------------------------------------
#property indicator_separate_window
//---------------------------------------------------------------------
#property indicator_applied_price	PRICE_CLOSE
#property indicator_minimum				-1.4
#property indicator_maximum				+1.4
//---------------------------------------------------------------------
#property indicator_buffers 	1
#property indicator_plots   	1
//---------------------------------------------------------------------
#property indicator_type1   	DRAW_HISTOGRAM
#property indicator_color1  	Red
#property indicator_width1		2
//---------------------------------------------------------------------
//	External parameters:
//---------------------------------------------------------------------
input int   MA1Period = 200; // period value of senior moving average
input int   MA2Period = 50;  // period value of medium moving average
input int   MA3Period = 21;  // period value of junior moving average
//---------------------------------------------------------------------
double      TrendBuffer[];
//---------------------------------------------------------------------
//	Initialization event handler:
//---------------------------------------------------------------------
void OnInit()
  {
//	Displayed indicator buffer:
   SetIndexBuffer(0,TrendBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,MA1Period);
   PlotIndexSetString(0,PLOT_LABEL,"FanTrendDetector( "+(string)MA1Period+
                      ", "+(string)MA2Period+", "+(string) MA3Period+" )");
  }
//---------------------------------------------------------------------
//	Need for indicator recalculation event handler:
//---------------------------------------------------------------------
int OnCalculate(const int _rates_total,
                const int _prev_calculated,
                const int _begin,
                const double &_price[])
  {
   int start,i;

//	If number of bars on the screen is less than averaging period, calculations can't be made:
   if(_rates_total<MA1Period)
     {
      return(0);
     }

//	Determine the initial bar for indicator buffer calculation:
   if(_prev_calculated==0)
     {
      start=MA1Period;
     }
   else
     {
      start=_prev_calculated-1;
     }

//	Loop of calculating the indicator buffer values:
   for(i=start; i<_rates_total; i++)
     {
      TrendBuffer[i]=TrendDetector(i,_price);
     }

   return(_rates_total);
  }
//---------------------------------------------------------------------
//	Determine the current trend direction:
//---------------------------------------------------------------------
//	Returns:
//		-1 - Down trend
//		+1 - Up trend
//		 0 - trend is not defined
//---------------------------------------------------------------------
int TrendDetector(int _shift,const double &_price[])
  {
   double current_ma1,current_ma2,current_ma3;
   int trend_direction=0;

   current_ma1 = SimpleMA( _shift, MA1Period, _price );
   current_ma2 = SimpleMA( _shift, MA2Period, _price );
   current_ma3 = SimpleMA( _shift, MA3Period, _price );

   if(current_ma3>current_ma2 && current_ma2>current_ma1)
     {
      trend_direction=1;
     }
   else if(current_ma3<current_ma2 && current_ma2<current_ma1)
     {
      trend_direction=-1;
     }

   return(trend_direction);
  }
//+------------------------------------------------------------------+