//+------------------------------------------------------------------+
//|                                               Pico de Volume.mq5 |
//|                                                  Henrique Vilela |
//|                                               http://vilela.one/ |
//+------------------------------------------------------------------+
#property copyright "Henrique Vilela"
#property link      "http://vilela.one/"
#property version   "1.00"


#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots 1


#property indicator_label1  "MMLO"
#property indicator_type1   DRAW_COLOR_HISTOGRAM 
#property indicator_color1  clrLime,clrSpringGreen,clrLimeGreen,clrGreen,clrSaddleBrown,clrChocolate,clrTan,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_maximum 1.0
#property indicator_minimum -1.0




//:::::::::::::::::::::::::::::::::::::::::::::::

input int Length=20;//Length
input double Multiplier=0.125;//Multiplieriplier
input bool Show_Lines=true;//Show Lines

double Murray[],MurrayColor[];
int  min_rates_total;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   min_rates_total=Length;

   SetIndexBuffer(0,Murray,INDICATOR_DATA);
   SetIndexBuffer(1,MurrayColor,INDICATOR_COLOR_INDEX);

//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   if(Show_Lines)
     {
      int niveis=int((1/Multiplier));
      IndicatorSetInteger(INDICATOR_LEVELS,niveis);
      for(int i=0;i<=niveis;i++)
        {
         if(i%2==0)IndicatorSetDouble(INDICATOR_LEVELVALUE,i,i*Multiplier);
         if(i%2==1)IndicatorSetDouble(INDICATOR_LEVELVALUE,i,-(i+1)*Multiplier);

        }
     }
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   if(rates_total<Length+1) return(0);

   int first,bar;
   double Min,Max,Range,multiplier,MidLine,oscillator;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated==0) // checking for the first start of the indicator calculation
     {
      first=Length;    // starting number for calculation of all bars
     }
   else
     {
      first=prev_calculated-1; // starting number for calculation of new bars
     }

//---- Main cycle of calculation of the channel
   for(bar=first; bar<rates_total; bar++)
     {
      Max=high[iHighest(high,Length,bar)];
      Min=low[iLowest(low,Length,bar)];
      Range=Max-Min;
      multiplier=Range*Multiplier;
      MidLine=Min+multiplier*4.;
      double cc=close[bar];
      oscillator=2*(close[bar]-MidLine)/(Range);

      if(oscillator>=0 && oscillator<Multiplier*2)MurrayColor[bar]=0.0;
      else if( oscillator > 0 && oscillator < Multiplier*4)MurrayColor[bar]=1.0;
      else if( oscillator > 0 && oscillator < Multiplier*6)MurrayColor[bar]=2.0;
      else if(oscillator>0 && oscillator<=Multiplier*8)MurrayColor[bar]=3.0;

      else if( oscillator < 0 && oscillator > -Multiplier*2)MurrayColor[bar]=4.0;
      else if( oscillator < 0 && oscillator > -Multiplier*4)MurrayColor[bar]=5.0;
      else if( oscillator < 0 && oscillator > -Multiplier*6)MurrayColor[bar]=6.0;
      else if(oscillator<0 && oscillator>=-Multiplier*8)MurrayColor[bar]=7.0;

      Murray[bar]=oscillator;

     }
   return(rates_total);
  }
//+------------------------------------------------------------------+

int iHighest(
             const double &array[],   // array for searching for maximum element index
             int count,               // the number of the array elements (from a current bar to the index descending), 
             // along which the searching must be performed.
             int startPos             // the initial bar index (shift relative to a current bar), 
             // the search for the greatest value begins from
             )
  {
//----
   int index=startPos;

//----checking correctness of the initial index
   if(startPos<0)
     {
      Print("Bad value in the function iHighest, startPos = ",startPos);
      return(0);
     }
//---- checking correctness of startPos value
   if(startPos-count<0)
      count=startPos;

   double max=array[startPos];
//---- searching for an index
   for(int i=startPos; i>startPos-count; i--)
     {
      if(array[i]>max)
        {
         index=i;
         max=array[i];
        }
     }
//---- returning of the greatest bar index
   return(index);
  }
//+------------------------------------------------------------------+
//|  searching index of the lowest bar                               |
//+------------------------------------------------------------------+
int iLowest(
            const double &array[],// array for searching for minimum element index
            int count,// the number of the array elements (from a current bar to the index descending), 
            // along which the searching must be performed.
            int startPos //the initial bar index (shift relative to a current bar), 
            // the search for the lowest value begins from
            )
  {
//----
   int index=startPos;

//----checking correctness of the initial index
   if(startPos<0)
     {
      Print("Bad value in the function iLowest, startPos = ",startPos);
      return(0);
     }

//---- checking correctness of startPos value
   if(startPos-count<0)
      count=startPos;

   double min=array[startPos];

//---- searching for an index
   for(int i=startPos; i>startPos-count; i--)
     {
      if(array[i]<min)
        {
         index=i;
         min=array[i];
        }
     }
//---- returning of the lowest bar index
   return(index);
  }
//+------------------------------------------------------------------+
