//+------------------------------------------------------------------+
//|                                                    MeanPrice.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Mario"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window

#property  indicator_buffers 1
#property  indicator_plots 1

#property   indicator_label1 "Amplitude Média"
#property   indicator_color1 clrYellow
#property   indicator_type1   DRAW_LINE

input int InpMAPeriod=10; // Period

double mean_price[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  
    int min_rates_total=InpMAPeriod;


//--- indicator buffers mapping
   SetIndexBuffer(0,mean_price,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+1);

//---
   return(INIT_SUCCEEDED);
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
   int i,limit;
//--- check for rates
   if(rates_total<InpMAPeriod)
      return(0);
//--- preliminary calculations

   if(prev_calculated==0)// first calculation
     {
      limit=InpMAPeriod;
      //--- set empty value for first limit bars
      for(i=0;i<limit-1;i++) mean_price[i]=0.0;
      //--- calculate first visible value
      double firstValue=0;
      for(i=0;i<limit;i++)
         firstValue=firstValue+high[i]-low[i];
      firstValue/=InpMAPeriod;
      mean_price[limit-1]=firstValue;
     }
   else limit=prev_calculated-1;

//--- the main loop of calculations
   for(i=limit;i<rates_total && !IsStopped();i++)
     {
      mean_price[i]=mean_price[i-1]+(high[i]-low[i]-high[i-InpMAPeriod]+low[i-InpMAPeriod])/InpMAPeriod;
     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+

