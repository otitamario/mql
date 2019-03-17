//+------------------------------------------------------------------+
//|                                              Moment_Divergence.mq5 |
//|                                                   Alain Verleyen |
//|                                             http://www.alamga.be |
//+------------------------------------------------------------------+
#property copyright     "Alain Verleyen (mql5) - Original author FX5 (mql4)"
#property link          "http://codebase.mql4.com/1115"
#property version       "1.01"
#property description   "The original indicator was totally rewrite to improve performance and"
#property description   "to correct a little bug. Also it's more funny that simply converting it."

#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3

//--- Plot 1 : Bullish 
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrGreen
#property indicator_label1  "Bullish divergence"
//--- Plot 2 : Bearish
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrRed
#property indicator_label2  "Bearish divergence"
//--- Plot 3 : Moment Main
#property indicator_type3   DRAW_LINE
#property indicator_style3  STYLE_SOLID
#property indicator_width3   1
#property indicator_color3  clrBlue
#property indicator_label3  "Main"
//--- input parameters
input int moment_period=14; // Moment period
input bool   drawIndicatorTrendLines = true;
input bool   drawPriceTrendLines     = true;
input bool   displayAlert            = true;
//--- constants
#define OBJECT_PREFIX       "Moment_DivergenceLine"
#define ARROWS_DISPLACEMENT 0.0001
//--- buffers
double bullishDivergence[];
double bearishDivergence[];
double momentBuffer[];
//--- handles
int    momentHandle=INVALID_HANDLE;
//--- globals variables
static datetime lastAlertTime;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator handle 
   momentHandle=iMomentum(NULL,_Period,moment_period,PRICE_CLOSE); 
   if(momentHandle==INVALID_HANDLE)
     {
      Print("The iMoment handle is not created: Error ",GetLastError());
      return(INIT_FAILED);
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,bullishDivergence);
   SetIndexBuffer(1,bearishDivergence);
   SetIndexBuffer(2,momentBuffer);
//--- arrow code see http://www.mql5.com/en/docs/constants/objectconstants/wingdings
   PlotIndexSetInteger(0,PLOT_ARROW,233);
   PlotIndexSetInteger(1,PLOT_ARROW,234);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE); 
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//--- indicator properties
   string indicatorName="Moment_Divergence";
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+2);
   IndicatorSetString(INDICATOR_SHORTNAME,indicatorName);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Cleaning of chart                                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDeleteByName("Moment_DivergenceLine");
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
//--- indicator updated only on new candle except total redraw
   static datetime lastCandleTime=0;
   if(lastCandleTime==time[rates_total-1])
      return(rates_total);
   else
      lastCandleTime=time[rates_total-1];
//--- first calculation or number of bars was changed
   int start;
   if(prev_calculated<=0)
     {
      start=moment_period;
      ArrayInitialize(bullishDivergence,EMPTY_VALUE);   // divergence buffers must be initialized
      ArrayInitialize(bearishDivergence,EMPTY_VALUE);
     }
   else
     {
      start=prev_calculated-2;
      bullishDivergence[rates_total-1]=EMPTY_VALUE;
      bearishDivergence[rates_total-1]=EMPTY_VALUE;
     }
//--- data (Moment buffers) count to copy     
   int toCopy=rates_total-prev_calculated+(prev_calculated<=0 ? 0 : 1);
//--- not all data may be calculated
   int calculated=BarsCalculated(momentHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of momentHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
//--- get OBV buffer
   if(IsStopped()) return(0); //Checking for stop flag
  
   if(CopyBuffer(momentHandle,0,0,toCopy,momentBuffer)<=0)
     {
      Print("Getting Moment Main is failed! Error : ",GetLastError());
      return(0);
     }
//--- main loop of calculations
   for(int shift=start; shift<rates_total-2; shift++)
     {
      int currentExtremum,lastExtremum;
      bool isBullishDivergence,isBearishDivergence;
      string divergenceMsg;
      ENUM_LINE_STYLE divergenceStyle=0;

      //--- Catch Bullish Divergence
      isBullishDivergence=false;

      if(momentBuffer[shift]<=momentBuffer[shift-1] && 
         momentBuffer[shift]<momentBuffer[shift-2] && 
         momentBuffer[shift]<momentBuffer[shift+1])
         //--- if current Moment main is a bottom (lower than 2 previous and 1 next)
        {
         currentExtremum=shift;
         lastExtremum=GetIndicatorLastTrough(shift);
         //--- 
         if(momentBuffer[currentExtremum]>momentBuffer[lastExtremum] && 
            low[currentExtremum]<low[lastExtremum])
           {
            isBullishDivergence=true;
            divergenceMsg="Classical bullish divergence on: ";
            divergenceStyle=STYLE_SOLID;
           }
         //---   
         if(momentBuffer[currentExtremum]<momentBuffer[lastExtremum] && 
            low[currentExtremum]>low[lastExtremum])
           {
            isBullishDivergence=true;
            divergenceMsg="Reverse bullish divergence on: ";
            divergenceStyle=STYLE_DOT;
           }
         //--- Bullish divergence is found
         if(isBullishDivergence)
           {
            bullishDivergence[currentExtremum]=momentBuffer[currentExtremum]-ARROWS_DISPLACEMENT;
            //---
            if(drawPriceTrendLines==true)
               DrawTrendLine(TRENDLINE_MAIN,time[currentExtremum],time[lastExtremum],low[currentExtremum],low[lastExtremum],Green,divergenceStyle);
            //---
            if(drawIndicatorTrendLines==true)
               DrawTrendLine(TRENDLINE_INDICATOR,time[currentExtremum],time[lastExtremum],momentBuffer[currentExtremum],momentBuffer[lastExtremum],Green,divergenceStyle);
            //---
            if(displayAlert==true && shift>=rates_total-3 && time[currentExtremum]!=lastAlertTime)
               DisplayAlert(divergenceMsg,time[currentExtremum]);
           }
        }
      //--- Catch Bearish Divergence
      isBearishDivergence=false;

      if(momentBuffer[shift]>=momentBuffer[shift-1] && 
         momentBuffer[shift]>momentBuffer[shift-2] && 
         momentBuffer[shift]>momentBuffer[shift+1])
         //--- if current Moment main is a top (higher than 2 previous and 1 next)
        {
         currentExtremum=shift;
         lastExtremum=GetIndicatorLastPeak(shift);
         //---   
         if(momentBuffer[currentExtremum]<momentBuffer[lastExtremum] && 
            high[currentExtremum]>high[lastExtremum])
           {
            isBearishDivergence=true;
            divergenceMsg="Classical bearish divergence on: ";
            divergenceStyle=STYLE_SOLID;
           }
         if(momentBuffer[currentExtremum]>momentBuffer[lastExtremum] && 
            high[currentExtremum]<high[lastExtremum])
           {
            isBearishDivergence=true;
            divergenceMsg="Reverse bearish divergence on: ";
            divergenceStyle=STYLE_DOT;
           }
         //--- Bearish divergence is found
         if(isBearishDivergence)
           {
            bearishDivergence[currentExtremum]=momentBuffer[currentExtremum]+ARROWS_DISPLACEMENT;
            //---
            if(drawPriceTrendLines==true)
               DrawTrendLine(TRENDLINE_MAIN,time[currentExtremum],time[lastExtremum],high[currentExtremum],high[lastExtremum],Red,STYLE_SOLID);
            //---
            if(drawIndicatorTrendLines==true)
               DrawTrendLine(TRENDLINE_INDICATOR,time[currentExtremum],time[lastExtremum],momentBuffer[currentExtremum],momentBuffer[lastExtremum],Red,STYLE_SOLID);
            //---
            if(displayAlert==true && shift>=rates_total-3 && time[currentExtremum]!=lastAlertTime)
               DisplayAlert(divergenceMsg,time[currentExtremum]);
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Search last trough                                               |
//+------------------------------------------------------------------+
int GetIndicatorLastTrough(int shift)
  {
   for(int i=shift-5; i>=2; i--)
     {
      
           
            if(momentBuffer[i] <= momentBuffer[i-1] && momentBuffer[i] < momentBuffer[i-2] &&
               momentBuffer[i] <= momentBuffer[i+1] && momentBuffer[i] < momentBuffer[i+2])
               return(i);
           
     }
     
   return(0);
  }
//+------------------------------------------------------------------+
//| Search last peak                                                 |
//+------------------------------------------------------------------+
int GetIndicatorLastPeak(int shift)
  {
   for(int i=shift-5; i>=2; i--)
     {
        
            if(momentBuffer[i] >= momentBuffer[i-1] && momentBuffer[i] > momentBuffer[i-2] &&
               momentBuffer[i] >= momentBuffer[i+1] && momentBuffer[i] > momentBuffer[i+2])
               return(i);
           
        
     }
   return(0);
  }
//+------------------------------------------------------------------+
//| ENUM_TRENDLINE_TYPE used by DrawTrendLine                        |
//+------------------------------------------------------------------+
enum ENUM_TRENDLINE_TYPE
  {
   TRENDLINE_MAIN,
   TRENDLINE_INDICATOR
  };
//+------------------------------------------------------------------+
//| Draw a trend line on main chart or on indicator                  |
//+------------------------------------------------------------------+
void DrawTrendLine(ENUM_TRENDLINE_TYPE window,datetime x1,datetime x2,double y1,double y2,color lineColor,ENUM_LINE_STYLE style)
  {
   string label=OBJECT_PREFIX+"#"+IntegerToString(window)+DoubleToString(x1,0);
   int subwindow=(window==TRENDLINE_MAIN) ? 0 : ChartWindowFind();
   ObjectDelete(0,label);
   ObjectCreate(0,label,OBJ_TREND,subwindow,x1,y1,x2,y2,0,0);
   ObjectSetInteger(0,label,OBJPROP_RAY,false);
   ObjectSetInteger(0,label,OBJPROP_COLOR,lineColor);
   ObjectSetInteger(0,label,OBJPROP_STYLE,style);
  }
//+------------------------------------------------------------------+
//| Display alert when divergence is found                           |
//+------------------------------------------------------------------+
void DisplayAlert(string message,const datetime alertTime)
  {
   lastAlertTime=alertTime;
   Alert(message,Symbol()," , ",EnumToString(Period())," minutes chart");
  }
//+------------------------------------------------------------------+
//| Delete all objects drawn by the indicator                        |
//+------------------------------------------------------------------+
void ObjectDeleteByName(string prefix)
  {
   int total=ObjectsTotal(0),
   length=StringLen(prefix);

//--- Deletion of all objects used by indicator
   for(int i=total-1; i>=0; i--)
     {
      string objName=ObjectName(0,i);
      if(StringSubstr(objName,0,length)==prefix)
        {
         ObjectDelete(0,objName);
        }
     }
  }
//+------------------------------------------------------------------+