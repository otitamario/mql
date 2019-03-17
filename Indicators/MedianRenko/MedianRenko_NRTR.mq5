

//+------------------------------------------------------------------+
//|                                                        iNRTR.mq5 |
//|                                        MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   4
//--- plot Support
#property indicator_label1  "Support"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  DodgerBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot Resistance
#property indicator_label2  "Resistance"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  Red
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2
//--- plot UpTarget
#property indicator_label3  "UpTarget"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  RoyalBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//--- plot DnTarget
#property indicator_label4  "DnTarget"
#property indicator_type4   DRAW_ARROW
#property indicator_color4  Crimson
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
//--- input parameters
input int      period   =  40;   /*period*/  // ATR period in bars
input double   k        =  2.0;  /*k*/       // ATR change coefficient
//--- indicator buffers
double         SupportBuffer[];
double         ResistanceBuffer[];
double         UpTargetBuffer[];
double         DnTargetBuffer[];
double         Trend[];
double         ATRBuffer[];
int Handle;

//
// Initialize MedianRenko indicator for data processing 
// according to settings of the MedianRenko indicator already on chart
//

#include <AZ-INVEST/SDK/MedianRenkoIndicator.mqh>
MedianRenkoIndicator medianRenkoIndicator;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,SupportBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(0,PLOT_ARROW,159);

   SetIndexBuffer(1,ResistanceBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(1,PLOT_ARROW,159);

   SetIndexBuffer(2,UpTargetBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(2,PLOT_ARROW,158);

   SetIndexBuffer(3,DnTargetBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(3,PLOT_ARROW,158);

   SetIndexBuffer(4,Trend,INDICATOR_DATA);
   SetIndexBuffer(5,ATRBuffer,INDICATOR_CALCULATIONS);

   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(5,PLOT_EMPTY_VALUE,0);

   Handle=iATR(_Symbol,PERIOD_CURRENT,period);

//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime  &time[],
                const double  &open[],
                const double  &high[],
                const double  &low[],
                const double  &close[],
                const long  &tick_volume[],
                const long  &volume[],
                const int  &spread[]
                )
  {
   //
   // Process data through MedianRenko indicator
   //
   
   if(!medianRenkoIndicator.OnCalculate(rates_total,prev_calculated,time))
      return(0);
   
   //
   // Make the following modifications in the code below:
   //
   // medianRenkoIndicator.GetPrevCalculated() should be used instead of prev_calculated
   //
   // medianRenkoIndicator.Open[] should be used instead of open[]
   // medianRenkoIndicator.Low[] should be used instead of low[]
   // medianRenkoIndicator.High[] should be used instead of high[]
   // medianRenkoIndicator.Close[] should be used instead of close[]
   //
   // medianRenkoIndicator.IsNewBar (true/false) informs you if a renko brick completed
   //
   // medianRenkoIndicator.Time[] shold be used instead of Time[] for checking the renko bar time.
   // (!) medianRenkoIndicator.SetGetTimeFlag() must be called in OnInit() for medianRenkoIndicator.Time[] to be used
   //
   // medianRenkoIndicator.Tick_volume[] should be used instead of TickVolume[]
   // medianRenkoIndicator.Real_volume[] should be used instead of Volume[]
   // (!) medianRenkoIndicator.SetGetVolumesFlag() must be called in OnInit() for Tick_volume[] & Real_volume[] to be used
   //
   // medianRenkoIndicator.Price[] should be used instead of Price[]
   // (!) medianRenkoIndicator.SetUseAppliedPriceFlag(ENUM_APPLIED_PRICE _applied_price) must be called in OnInit() for medianRenkoIndicator.Price[] to be used
   //
   
   int _prev_calculated = medianRenkoIndicator.GetPrevCalculated();
   
   //
   //
   //  
     
   static bool error=true;
   int start;
   if(_prev_calculated==0)
     {
      error=true;
     }
   if(error)
     {
      ArrayInitialize(Trend,0);
      ArrayInitialize(UpTargetBuffer,0);
      ArrayInitialize(DnTargetBuffer,0);
      ArrayInitialize(SupportBuffer,0);
      ArrayInitialize(ResistanceBuffer,0);
      start=period;
      error=false;
     }
   else
     {
      start=_prev_calculated-1;
     }
   if(CopyBuffer(Handle,0,0,rates_total-start,ATRBuffer)==-1)
     {
      error=true;
      return(0);
     }
   for(int i=start;i<rates_total;i++)
     {
      Trend[i]=Trend[i-1];
      UpTargetBuffer[i]=UpTargetBuffer[i-1];
      DnTargetBuffer[i]=DnTargetBuffer[i-1];
      SupportBuffer[i]=SupportBuffer[i-1];
      ResistanceBuffer[i]=ResistanceBuffer[i-1];
      switch((int)Trend[i])
        {
         case 2:
            if(medianRenkoIndicator.Low[i]>UpTargetBuffer[i])
              {
               UpTargetBuffer[i]=medianRenkoIndicator.Close[i];
               SupportBuffer[i]=medianRenkoIndicator.Close[i]-k*ATRBuffer[i];
              }
            if(medianRenkoIndicator.Close[i]<SupportBuffer[i])
              {
               DnTargetBuffer[i]=medianRenkoIndicator.Close[i];
               ResistanceBuffer[i]=medianRenkoIndicator.Close[i]+k*ATRBuffer[i];
               Trend[i]=3;
               UpTargetBuffer[i]=0;
               SupportBuffer[i]=0;
              }
            break;
         case 3:
            if(medianRenkoIndicator.High[i]<DnTargetBuffer[i])
              {
               DnTargetBuffer[i]=medianRenkoIndicator.Close[i];
               ResistanceBuffer[i]=medianRenkoIndicator.Close[i]+k*ATRBuffer[i];
              }
            if(medianRenkoIndicator.Close[i]>ResistanceBuffer[i])
              {
               UpTargetBuffer[i]=medianRenkoIndicator.Close[i];
               SupportBuffer[i]=medianRenkoIndicator.Close[i]-k*ATRBuffer[i];
               Trend[i]=2;
               DnTargetBuffer[i]=0;
               ResistanceBuffer[i]=0;
              }
            break;
         case 0:
            UpTargetBuffer[i]=medianRenkoIndicator.Close[i];
            DnTargetBuffer[i]=medianRenkoIndicator.Close[i];
            Trend[i]=1;
            break;
         case 1:
            if(medianRenkoIndicator.Low[i]>UpTargetBuffer[i])
              {
               UpTargetBuffer[i]=medianRenkoIndicator.Close[i];
               SupportBuffer[i]=medianRenkoIndicator.Close[i]-k*ATRBuffer[i];
               Trend[i]=2;
               DnTargetBuffer[i]=0;
              }
            if(medianRenkoIndicator.High[i]<DnTargetBuffer[i])
              {
               DnTargetBuffer[i]=medianRenkoIndicator.Close[i];
               ResistanceBuffer[i]=medianRenkoIndicator.Close[i]+k*ATRBuffer[i];
               Trend[i]=3;
               UpTargetBuffer[i]=0;
              }
            break;
        }

     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
