//+------------------------------------------------------------------+
//|                                                   Supertrend.mq5 |
//|                   Copyright © 2005, Jason Robinson (jnrtrading). | 
//+------------------------------------------------------------------+ 
#property copyright "Mario" 
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- number of indicator buffers 4
#property indicator_buffers 2 
//---- four plots are used in total
#property indicator_plots   2
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1 DRAW_LINE
//---- lime color is used for the indicator
#property indicator_color1 Lime
//---- indicator line is a solid one
#property indicator_style1 STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width1 2
//---- displaying the signal line label
#property indicator_label1  "PCPV Up"
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type2 DRAW_LINE
//---- three colors are used for the indicator
#property indicator_color2 Red
//---- indicator line is a solid one
#property indicator_style2 STYLE_SOLID
//---- indicator line width is equal to 2
#property indicator_width2 2
//---- displaying the signal line label
#property indicator_label2  "PCPV Down"
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int   currentPeriod=72; //Indicator period 
//+----------------------------------------------+
//---- declaration of dynamic arrays that further 
//---- will be used as indicator buffers
double TrendUp[],TrendDown[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
double  hl,ll,dist,hf,cfh,cfl,lf;
int  nIndex;
int pcpv1=72;
int  pcpv2 = 305;
int  pcpv3 = 1292;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
  
  min_rates_total=currentPeriod;
//---- initialization of variables of the start of data calculation
// min_rates_total=MathMax(CCIPeriod,ATRPeriod);
//---- getting handle of the CCI indicator
//---- initializations of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"PCPV(",string(currentPeriod),")");
//---- creating a name for displaying in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);

//---- set ExtBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(0,TrendUp,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(TrendUp,true);

//---- set ExtBuffer[] dynamic array as an indicator buffer
   SetIndexBuffer(1,TrendDown,INDICATOR_DATA);
//---- performing the shift of the beginning of the indicator drawing
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- indexing the elements in buffers as timeseries   
   ArraySetAsSeries(TrendDown,true);

  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the indicator calculation
                const double& low[],      // price array of minimums of price for the indicator calculation
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
  int limit,bar;
//---- checking the number of bars to be enough for the calculation
//---- indexing elements in arrays as timeseries  
   
//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total;                 // starting index for calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated;                 // starting index for calculation of new bars
     }

//---- main indicator calculation loop
   for(bar=limit; bar>=0; bar--)
     {
      TrendUp[bar]=0.0;
      TrendDown[bar]=0.0;

      hl=HighestHigh(Symbol(),_Period,currentPeriod,0);
      ll=LowestLow(Symbol(),_Period,currentPeriod,0);
      dist=hl-ll;          //range of the channel
      hf=hl-dist*0.214;    //Highest Fibonacci line
      lf=hl-dist*0.786;     //Lowest Fibonacci line
      if(open[bar]<lf)
        {
         if(currentPeriod==pcpv1 || currentPeriod==pcpv2) TrendDown[bar]=lf;
        }

      if(close[bar]>hf)
        {
         if(currentPeriod==pcpv1 || currentPeriod==pcpv2) TrendUp[bar]=hf;
        }



      // sempre exibe
      if(currentPeriod==pcpv3) 
       { 
       TrendUp[bar]=hf;
       TrendDown[bar]=lf;
      }

     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Highest High & Lowest Low                                        |
//+------------------------------------------------------------------+

double HighestHigh(string pSymbol,ENUM_TIMEFRAMES pPeriod,int pBars,int pStart=0)
  {
   double high[];
   ArraySetAsSeries(high,true);

   int copied= CopyHigh(pSymbol,pPeriod,pStart,pBars,high);
   if(copied == -1) return(copied);

   int maxIdx=ArrayMaximum(high);
   double highest=high[maxIdx];

   return(highest);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LowestLow(string pSymbol,ENUM_TIMEFRAMES pPeriod,int pBars,int pStart=0)
  {
   double low[];
   ArraySetAsSeries(low,true);

   int copied= CopyLow(pSymbol,pPeriod,pStart,pBars,low);
   if(copied == -1) return(copied);

   int minIdx=ArrayMinimum(low);
   double lowest=low[minIdx];

   return(lowest);
  }
//+------------------------------------------------------------------+
