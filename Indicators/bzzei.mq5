//+------------------------------------------------------------------+
//|                     Out of Price Walk, Nonparametric Zig Zag.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property description "Zig Zag indicator with following uptrend monotonicity condition:"
#property description "subsequent High shouldn't be lower than any previous Low."
#property description "Similar logic applies for downtrend."
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot ZigZagLine
#property indicator_label1  "ZigZagLine"
#property indicator_type1   DRAW_SECTION
#property indicator_color1  Yellow
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot High
#property indicator_label2  "High"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  Blue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Low
#property indicator_label3  "Low"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  Red
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- indicator buffers
double         ZigZagLineBuffer[];
double         HighBuffer[];
double         LowBuffer[];
//--- custom variables
int iz=0,imaxhigh=0,iminlow=0,lastlow=0,lasthigh=0;
double zhigh=0,zlow=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ZigZagLineBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,LowBuffer,INDICATOR_DATA);
//--- set short name and digits   
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- set empty value
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- set OBJ_ARROW value
   PlotIndexSetInteger(1,PLOT_ARROW,217);
   PlotIndexSetInteger(2,PLOT_ARROW,218);
//---
   return(0);
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
//--- initializing
   if(prev_calculated==0)
     {
      ArrayInitialize(ZigZagLineBuffer,0.0);
      ArrayInitialize(HighBuffer,0.0);
      ArrayInitialize(LowBuffer, 0.0);
      iz=imaxhigh=iminlow=lastlow=lasthigh=0;
      zhigh=zlow=0;
     }
   else if(rates_total-prev_calculated>=2) Print(rates_total-prev_calculated);

   int shift,ihigh,ilow;
   ilow=ihigh=shift=iz+1;

   int last_bar=rates_total-1;
   ZigZagLineBuffer[last_bar]=0.0;
   LowBuffer[last_bar]=0.0;
   HighBuffer[last_bar]=0.0;
//---
//--- searching High and Low
//---   
   while(ihigh<last_bar)
     {
      //--- searching for peak
      if(zlow!=0) // search for peak
        {
         while(ihigh<last_bar && low[ihigh]<=high[iz]) ihigh++;

         if(ihigh<last_bar)
           {
            ilow=ihigh+1;
            while(ilow<last_bar && high[ilow]>=low[ihigh])
              {
               if(low[ihigh]<low[ilow]) ihigh=ilow;
               ilow++;
              }
            if(ilow<last_bar && high[ilow]<low[ihigh])
              {
               lastlow=iz;
               iz=ihigh;
               zhigh=low[iz];
               ZigZagLineBuffer[iz]=zhigh;
               zlow=0.0;
               iminlow=shift=iz;
               while(--shift>lasthigh) if(low[iminlow]>=low[shift]) iminlow=shift;
               LowBuffer[iminlow]=low[iminlow];
              }
            ihigh=ilow;
           }
        }
      //--- searching for lawn
      else if(zhigh!=0) // search for lawn
        {
         while(ilow<last_bar && high[ilow]>=low[iz]) ilow++;

         if(ilow<last_bar)
           {
            ihigh=ilow+1;
            while(ihigh<last_bar && low[ihigh]<=high[ilow])
              {
               if(high[ilow]>high[ihigh]) ilow=ihigh;
               ihigh++;
              }
            if(ihigh<last_bar && low[ihigh]>high[ilow])
              {
               lasthigh=iz;
               iz=ilow;
               zlow=high[iz];
               ZigZagLineBuffer[iz]=zlow;
               zhigh=0.0;
               imaxhigh=shift=iz;
               while(--shift>lastlow) if(high[imaxhigh]<=high[shift]) imaxhigh=shift;
               HighBuffer[imaxhigh]=high[imaxhigh];
              }
            ilow=ihigh;
           }
        }
      //--- searching for lawn or peak
      else // search for lawn or peak
        {
         while(++shift<last_bar && low[ihigh]<high[ilow])
           {
            if(low[ihigh] < low[shift]) ihigh = shift;
            if(high[ilow] > high[shift]) ilow = shift;
           }
         if(shift<last_bar)
            if(ihigh<ilow)
              {
               iz=ihigh;
               zhigh=low[iz];
               ihigh++;
               ilow=ihigh;
              }
         else
           {
            iz=ilow;
            zlow=high[iz];
            ilow++;
            ihigh=ilow;
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
