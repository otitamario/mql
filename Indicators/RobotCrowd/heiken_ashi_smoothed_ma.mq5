//+------------------------------------------------------------------+
//|                                         Heiken_Ashi_Smoothed.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
#property description "Heiken Ashi Smoothed"
//---- indicator version
#property version   "1.1"


//+------------------------------------------------------------------+
//|                                 Modificado por Antonio Guglielmi |
//|             RobotCrowd - Crowdsourcing para trading automatizado |
//|                                    https://www.robotcrowd.com.br |
//|  Indicador original modificado para incluir uma media movel do   |
//|  proprio Heinken Ashi Suavizado para implementar o EA.           |
//+------------------------------------------------------------------+

//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- five buffers are used for calculation of drawing of the indicator
#property indicator_buffers 6
//---- only one plot is used
#property indicator_plots   2
//---- color candlesticks are used as an indicator
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1  DodgerBlue, Red
//---- displaying the indicator label
#property indicator_label1  "Heiken Ashi Open;Heiken Ashi High;Heiken Ashi Low;Heiken Ashi Close"

//---- plotagem da media movel do heiken ashi
#property indicator_type2  DRAW_LINE
#property indicator_color2 clrGreen
#property indicator_label2 "Media movel do Heiken Ashi"

//+-----------------------------------+
//|  Smoothings classes description   |
//+-----------------------------------+
#include "include/SmoothAlgorithms.mqh" 
#include "include/MovingAverages.mqh" 
//+-----------------------------------+
//---- declaration of the CXMA class variables from the SmoothAlgorithms.mqh file
CXMA XMAO,XMAL,XMAH,XMAC;
//+-----------------------------------+
//|  declaration of enumerations      |
//+-----------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPL_,         //Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };
/*enum Smooth_Method - enumeration is declared in the SmoothAlgorithms.mqh file
  {
   MODE_SMA_,  //SMA
   MODE_EMA_,  //EMA
   MODE_SMMA_, //SMMA
   MODE_LWMA_, //LWMA
   MODE_JJMA,  //JJMA
   MODE_JurX,  //JurX
   MODE_ParMA, //ParMA
   MODE_T3,    //T3
   MODE_VIDYA, //VIDYA
   MODE_AMA,   //AMA
  }; */
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input Smooth_Method        MA_SMethod=MODE_EMA_; //Smoothing method
input int                  SmLength=35;          //Smoothing depth                    
input int                  SmPhase=100;          //Smoothing parameter (JJMA, T3, VIDYA, AMA)
                                                 //for JJMA that can change withing the range -100 ... +100. It impacts the quality of the intermediate process of smoothing;
                                                 // for VIDIA it is a CMO period, for AMA it is a slow average period
input ENUM_MA_METHOD       MAMethod=MODE_SMA;    //Moving Average Method
input int                  MAPeriod=2;           //Moving Average Period
input ENUM_APPLIED_PRICE   MAPrice=PRICE_OPEN;   //Moving Average Applied Price
input int                  MAShift=1;            //Moving Average Shift
//input double               MADiscount=0.07;      //Moving Average Discount (%)
//+----------------------------------------------+

//---- declaration of dynamic arrays that further 
// will be used as indicator buffers
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
double ExtMABuffer[];
//----
int StartBars;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- initialization of global variables 
   StartBars=XMAO.GetStartBars(MA_SMethod,SmLength,SmPhase)+1;

//---- setting up alerts for unacceptable values of external variables
   XMAO.XMALengthCheck("Length", SmLength);
   XMAO.XMAPhaseCheck("Phase", SmPhase, MA_SMethod);

//---- converting dynamic arrays into the indicator buffers
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- set dynamic array as a color index buffer   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- shifting the start of drawing of the indicator 1
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,StartBars);

   SetIndexBuffer(5,ExtMABuffer,INDICATOR_DATA);
   PlotIndexSetInteger(5, PLOT_SHIFT, MAShift);


//---- Setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows 
   string short_name="Heiken Ashi Smoothed";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//----   
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
//---- checking the number of bars to be enough for the calculation
   if(rates_total<StartBars) return(0);

//---- declarations of local variables 
   int first,bar;
   double XmaOpen,XmaHigh,XmaLow,XmaClose;

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      first=0; // starting index for calculation of all bars
     }
   else first=prev_calculated-1; // starting index for calculation of new bars

//---- Main indicator calculation loop
   for(bar=first; bar<rates_total && !IsStopped(); bar++)
     {
      //---- Four calls of the XMASeries function.  
      XmaOpen  = XMAO.XMASeries(0, prev_calculated, rates_total, MA_SMethod, SmPhase, SmLength, open [bar], bar, false);
      XmaClose = XMAC.XMASeries(0, prev_calculated, rates_total, MA_SMethod, SmPhase, SmLength, close[bar], bar, false);
      XmaHigh  = XMAH.XMASeries(0, prev_calculated, rates_total, MA_SMethod, SmPhase, SmLength, high [bar], bar, false);
      XmaLow   = XMAL.XMASeries(0, prev_calculated, rates_total, MA_SMethod, SmPhase, SmLength, low  [bar], bar, false);

      if(bar<=StartBars)
        {
         ExtOpenBuffer [bar]=XmaOpen;
         ExtCloseBuffer[bar]=XmaClose;
         ExtHighBuffer [bar]=XmaHigh;
         ExtLowBuffer  [bar]=XmaLow;

         continue;
        }

      ExtOpenBuffer [bar]=(ExtOpenBuffer[bar-1]+ExtCloseBuffer[bar-1])/2;
      ExtCloseBuffer[bar]=(XmaOpen+XmaHigh+XmaLow+XmaClose)/4;
      ExtHighBuffer [bar]=MathMax(XmaHigh,MathMax(ExtOpenBuffer[bar],ExtCloseBuffer[bar]));
      ExtLowBuffer  [bar]=MathMin(XmaLow,MathMin(ExtOpenBuffer[bar],ExtCloseBuffer[bar]));

      //--- Coloring of candlesticks
      if(ExtOpenBuffer[bar]<ExtCloseBuffer[bar]) ExtColorBuffer[bar]=0.0;
      else                                       ExtColorBuffer[bar]=1.0;

   
      // Calculo da media movel
      if ((bar+MAShift) < rates_total) {
         
         switch (MAPrice) {
            case PRICE_OPEN:
               switch (MAMethod) {
                  case MODE_SMA:
                     ExtMABuffer[bar+MAShift] = SimpleMA(bar, MAPeriod, ExtOpenBuffer);
                     break;
                  case MODE_EMA:
                     ExtMABuffer[bar+MAShift] = ExponentialMA(bar, MAPeriod, ExtMABuffer[bar+MAShift-1], ExtOpenBuffer);
                     break;
                  case MODE_LWMA:
                     ExtMABuffer[bar+MAShift] = LinearWeightedMA(bar, MAPeriod, ExtOpenBuffer);
                     break;
                  case MODE_SMMA:
                     ExtMABuffer[bar+MAShift] = SmoothedMA(bar, MAPeriod, ExtMABuffer[bar+MAShift-1], ExtOpenBuffer);
                     break;
               }
               break;
            case PRICE_HIGH:
               switch (MAMethod) {
                  case MODE_SMA:
                     ExtMABuffer[bar+MAShift] = SimpleMA(bar, MAPeriod, ExtHighBuffer);
                     break;
                  case MODE_EMA:
                     ExtMABuffer[bar+MAShift] = ExponentialMA(bar, MAPeriod, ExtMABuffer[bar+MAShift-1], ExtHighBuffer);
                     break;
                  case MODE_LWMA:
                     ExtMABuffer[bar+MAShift] = LinearWeightedMA(bar, MAPeriod, ExtHighBuffer);
                     break;
                  case MODE_SMMA:
                     ExtMABuffer[bar+MAShift] = SmoothedMA(bar, MAPeriod, ExtMABuffer[bar+MAShift-1], ExtHighBuffer);
                     break;
               }
               break;
            case PRICE_LOW:
               switch (MAMethod) {
                  case MODE_SMA:
                     ExtMABuffer[bar+MAShift] = SimpleMA(bar, MAPeriod, ExtLowBuffer);
                     break;
                  case MODE_EMA:
                     ExtMABuffer[bar+MAShift] = ExponentialMA(bar, MAPeriod, ExtMABuffer[bar+MAShift-1], ExtLowBuffer);
                     break;
                  case MODE_LWMA:
                     ExtMABuffer[bar+MAShift] = LinearWeightedMA(bar, MAPeriod, ExtLowBuffer);
                     break;
                  case MODE_SMMA:
                     ExtMABuffer[bar+MAShift] = SmoothedMA(bar, MAPeriod, ExtMABuffer[bar+MAShift-1], ExtLowBuffer);
                     break;
               }
               break;
            case PRICE_CLOSE:
            default:
               switch (MAMethod) {
                  case MODE_SMA:
                     ExtMABuffer[bar+MAShift] = SimpleMA(bar, MAPeriod, ExtCloseBuffer);
                     break;
                  case MODE_EMA:
                     ExtMABuffer[bar+MAShift] = ExponentialMA(bar, MAPeriod, ExtMABuffer[bar+MAShift-1], ExtCloseBuffer);
                     break;
                  case MODE_LWMA:
                     ExtMABuffer[bar+MAShift] = LinearWeightedMA(bar, MAPeriod, ExtCloseBuffer);
                     break;
                  case MODE_SMMA:
                     ExtMABuffer[bar+MAShift] = SmoothedMA(bar, MAPeriod, ExtMABuffer[bar+MAShift-1], ExtCloseBuffer);
                     break;
               }
               break;
         }

      }
     }
     
   //SimpleMAOnBuffer(rates_total, prev_calculated, first, MAPeriod, ExtOpenBuffer, ExtMABuffer);
   
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+

