//+------------------------------------------------------------------+
//|                                    FractalZigZagNoRepaintMt5.mq5 |
//written by Ufranco derived from indicator by pointzero-trading.com |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "pointzero-trading.com"
#property link      "http://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2
//---reference zigzag indicator
#resource "\\Indicators\\Examples\\ZigzagColor.ex5"
//--- plot Upper
#property indicator_label1  "Upper"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrBlue
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Lower
#property indicator_label2  "Lower"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- input parameters
input bool     CalculateOnBarClose=true;
input int      ZZDepth=12;
input int      ZZDev=5;
input int      nShift=5;
//--- indicator buffers
double UpperBuffer[];
double LowerBuffer[];
double zzup[],zzdwn[];
double zzhigh= 0;
double zzlow = 0;
int zzhandle;
//---
double fr_resistance       = 0;
double fr_support          = 0;
bool fr_resistance_change  = EMPTY_VALUE;
bool fr_support_change     = EMPTY_VALUE;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---initialize indicator handle
   zzhandle=iCustom(Symbol(),Period(),"::Indicators\\Examples\\ZigzagColor.ex5",ZZDepth,ZZDev,1);
   if(zzhandle==INVALID_HANDLE)
     {
      Print("Error, invalid handle for indicator values");
      return(INIT_FAILED);
     }

//--- indicator buffers mapping
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LowerBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,zzup,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,zzdwn,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);
//---
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,2);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,2);
//---   
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);

//---
   ArraySetAsSeries(UpperBuffer,true);
   ArraySetAsSeries(LowerBuffer,true);
   ArraySetAsSeries(zzup,true);
   ArraySetAsSeries(zzdwn,true);
//---

   return(INIT_SUCCEEDED);
  }
//--------FUNCTION DEFINITIONS---------------
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
   int limit,i,first=0;
//---
   if(prev_calculated<=0)limit=rates_total-1;
   else limit=1;
//---fill buffers with indicator values
   if(CopyBuffer(zzhandle,3,0,limit,zzup)<=0)return(0);
   if(CopyBuffer(zzhandle,4,0,limit,zzdwn)<=0)return(0);
//---   
   if(CalculateOnBarClose) first=1;
//---main loop
   for(i=limit;i>=first;i--)
     {
      if(zzup[i]!=0)zzhigh=zzup[i];
      if(zzdwn[i]!=0)zzlow=zzdwn[i];
      //---
      double resistance=upper_fractal(i);
      double support=lower_fractal(i);
      //---
      if(fr_support_change==true && fr_support==zzlow)
        {
         LowerBuffer[i+2] = fr_support - (2*nShift)*_Point;
         UpperBuffer[i+2] = 0.0;
        }
      else if(fr_resistance_change==true && fr_resistance==zzhigh)
        {
         UpperBuffer[i+2] = fr_resistance + (2*nShift)*_Point;
         LowerBuffer[i+2] = 0.0;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
double upper_fractal(int shift=1)
  {
   double middle=iHigh(Symbol(),0,shift+2);
   double v1 = iHigh(Symbol(), 0, shift);
   double v2 = iHigh(Symbol(), 0, shift+1);
   double v3 = iHigh(Symbol(), 0, shift + 3);
   double v4 = iHigh(Symbol(), 0, shift + 4);
   if(middle>v1 && middle>v2 && middle>v3 && middle>v4)
     {
      fr_resistance=middle;
      fr_resistance_change=true;
        } else {
      fr_resistance_change=false;
     }
   return(fr_resistance);
  }
//+--------------------------------------------------------------------------------------+

double lower_fractal(int shift=1)
  {
   double middle=iLow(Symbol(),0,shift+2);
   double v1 = iLow(Symbol(), 0, shift);
   double v2 = iLow(Symbol(), 0, shift+1);
   double v3 = iLow(Symbol(), 0, shift + 3);
   double v4 = iLow(Symbol(), 0, shift + 4);
   if(middle<v1 && middle<v2 && middle<v3 && middle<v4)
     {
      fr_support=middle;
      fr_support_change=true;
        } else {
      fr_support_change=false;
     }
   return(fr_support);
  }

//+------------------------------------------------------------------+
