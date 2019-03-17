//+------------------------------------------------------------------+
//|                                                TSIsCDiCreate.mq5 |
//|                                        MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
//--- plot TSIsCD
#property indicator_label1  "TSIsCD"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  Green,Red
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

//--- input parameters
input int r=25;
input int s=13;
input int sp=5;
input ENUM_MA_METHOD sm=MODE_EMA;
//--- indicator buffers
double         TSIsCDBuffer[];
double         TSIsCDColors[];
double         TsiBuffer[];
double         TsiSignalBuffer[];

int Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,TSIsCDBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,TSIsCDColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,TsiBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,TsiSignalBuffer,INDICATOR_CALCULATIONS);

   MqlParam Params[5];
   Params[0].type=TYPE_STRING;
   Params[0].string_value="TSIs";
   Params[1].type=TYPE_INT;
   Params[1].integer_value=r;
   Params[2].type=TYPE_INT;
   Params[2].integer_value=s;   
   Params[3].type=TYPE_INT;
   Params[3].integer_value=sp;      
   Params[4].type=TYPE_INT;
   Params[4].integer_value=sm;  
   
   Handle=IndicatorCreate(_Symbol,PERIOD_CURRENT,IND_CUSTOM,5,Params);
   
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,r+s+sp);
   IndicatorSetInteger(INDICATOR_DIGITS,2);      
//---
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // size of the price[] array
                const int prev_calculated,// number of bars processed at the previous call
                const int begin,          // where the significant data start from
                const double &price[]     // array for calculation
                )
  {

   static bool error=true;
   int start;
   if(prev_calculated==0)
     {
      error=true;
     }
   if(error)
     {
      start=begin+1;
      error=false;
     }
   else
     {
      start=prev_calculated-1;
     }

   if(CopyBuffer(Handle,0,0,rates_total-start,TsiBuffer)==-1)
     {
      error=true;
      return(0);
     }
   if(CopyBuffer(Handle,1,0,rates_total-start,TsiSignalBuffer)==-1)
     {
      error=true;
      return(0);
     }

   for(int i=start;i<rates_total;i++)
     {
      TSIsCDBuffer[i]=TsiBuffer[i]-TsiSignalBuffer[i];
      TSIsCDColors[i]=TSIsCDColors[i-1];
      if(TSIsCDBuffer[i]>TSIsCDBuffer[i-1])TSIsCDColors[i]=0;
      if(TSIsCDBuffer[i]<TSIsCDBuffer[i-1])TSIsCDColors[i]=1;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
