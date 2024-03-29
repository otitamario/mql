

#define  InpNome  "Ricardo Almeida Branco"
#define  InpNome_  "Thiago Alessandro da Costa"

#define TmpDataValidade D'2019.10.30 00:00'  // Data de validade do robô  //ano.mes.dia

#property copyright   "2019, White Trader - Programmer && Developer"
#property link      "https://www.mql5.com/pt/users/rycke.br"
#property description "\n Ultimate Signal"
//---- drawing the indicator in the main window
#property indicator_chart_window
//----four buffers are used for calculation of drawing of the indicator
#property indicator_buffers 10
//---- four plots are used in total
#property indicator_plots   10
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
#property indicator_label1  "Sell"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Buy"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDarkTurquoise
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_type3  DRAW_LINE
#property indicator_color3  DodgerBlue
#property indicator_style3 STYLE_DASHDOTDOT
#property indicator_width3  1
#property indicator_label3  "Ultimate Upper"
#property indicator_type4   DRAW_LINE
#property indicator_color4  Magenta
#property indicator_style4 STYLE_DASHDOTDOT
#property indicator_width4  1
#property indicator_label4 "Ultimate Lower"
#property indicator_type5   DRAW_LINE
#property indicator_color5  Lime
#property indicator_style5 STYLE_SOLID
#property indicator_width5  4
#property indicator_label5  "Ultimate Stop Buy"
#property indicator_type6   DRAW_LINE
#property indicator_color6  Red
#property indicator_style6 STYLE_SOLID
#property indicator_width6  4
#property indicator_label6 "Ultimate Stop Sel"

#property indicator_type7   DRAW_NONE
#property indicator_label7 "Shadow High"

#property indicator_type8   DRAW_NONE
#property indicator_label8 "Counter High"

#property indicator_type9   DRAW_NONE
#property indicator_label9 "Shadow Low"

#property indicator_type10   DRAW_NONE
#property indicator_label10 "Counter Low"
//+----------------------------------------------+
//|  Declaration of constants                    |
//+----------------------------------------------+
#define RESET 0 // the constant for getting the command for the indicator recalculation back to the terminal
//+----------------------------------------------+
//|  declaration of enumeration                  |
//+----------------------------------------------+
enum IndMode //Type of constant
  {
   ATR,     //ATR indicator
   StDev    //StDev indicator
  };
//+----------------------------------------------+
//|  declaration of enumeration                  |
//+----------------------------------------------+
enum PriceMode //Type of constant
  {
   HighLow_, //High/Low
   Close_    //Close
  };
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input double K=1; //multiplier
input IndMode Indicator=ATR; //indicator to calculate
input uint VltPeriod=10; // period of volatility
input PriceMode Price=HighLow_; //price calculation method
input uint WideMin=100; // the minimum thickness of a brick in points
input double   ShadowMin=50; //the minimum shadow to autorize signal
input uint     CountMin=3; //the minimum count box to autorize signal

//+----------------------------------------------+
double sens;
//---- declaration of dynamic arrays that further
//---- will be used as indicator buffers
double SellBuffer[], BuyBuffer[];
double DnBuffer[],UpBuffer[];
double StopBuyBuffer[],StopSellBuffer[];
double CounterBufferHigh[],ShadowBufferHigh[];
double CounterBufferLow[],ShadowBufferLow[];

//---- declaration of the integer variables for the start of data calculation
int  min_rates_total;
//----Declaration of variables for storing the indicators handles
int Ind_Handle;

double sombrahigh=0;double sombralow=0;
uint   counthigh=0; uint countlow=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  
//Comment("");

//---- Initialization of variables    
   min_rates_total=int(VltPeriod);
   sens=WideMin*_Point;

   if(Indicator==ATR) Ind_Handle=iATR(NULL,0,VltPeriod);
   else  Ind_Handle=iStdDev(NULL,0,VltPeriod,0,MODE_SMA,PRICE_CLOSE);
   if(Ind_Handle==INVALID_HANDLE) Print(" Failed to get handle of the indicator");

int index=0;
   SetIndexBuffer(index,SellBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(index,PLOT_DRAW_BEGIN,min_rates_total);
   ArraySetAsSeries(SellBuffer,true);
   PlotIndexSetDouble(index,PLOT_EMPTY_VALUE,0);
index ++;
   SetIndexBuffer(index,BuyBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(index,PLOT_DRAW_BEGIN,min_rates_total);
   ArraySetAsSeries(BuyBuffer,true);
   PlotIndexSetDouble(index,PLOT_EMPTY_VALUE,0);
index ++;
   SetIndexBuffer(index,UpBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(index,PLOT_DRAW_BEGIN,min_rates_total);
   ArraySetAsSeries(UpBuffer,true);
   PlotIndexSetDouble(index,PLOT_EMPTY_VALUE,0);
index ++;
   SetIndexBuffer(index,DnBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(index,PLOT_DRAW_BEGIN,min_rates_total);
   ArraySetAsSeries(DnBuffer,true);
   PlotIndexSetDouble(index,PLOT_EMPTY_VALUE,0);
index ++;
   SetIndexBuffer(index,StopBuyBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(index,PLOT_DRAW_BEGIN,min_rates_total);
   ArraySetAsSeries(StopBuyBuffer,true);
   PlotIndexSetDouble(index,PLOT_EMPTY_VALUE,0);
index ++;
   SetIndexBuffer(index,StopSellBuffer,INDICATOR_DATA);
   PlotIndexSetInteger(index,PLOT_DRAW_BEGIN,min_rates_total);
   ArraySetAsSeries(StopSellBuffer,true);
   PlotIndexSetDouble(index,PLOT_EMPTY_VALUE,0);
index ++;
   SetIndexBuffer(index,ShadowBufferHigh,INDICATOR_DATA);
   PlotIndexSetInteger(index,PLOT_DRAW_BEGIN,min_rates_total);
   ArraySetAsSeries(ShadowBufferHigh,true);
   PlotIndexSetDouble(index,PLOT_EMPTY_VALUE,0);
index ++;
   SetIndexBuffer(index,CounterBufferHigh,INDICATOR_DATA);
   PlotIndexSetInteger(index,PLOT_DRAW_BEGIN,min_rates_total);
   ArraySetAsSeries(CounterBufferHigh,true);
   PlotIndexSetDouble(index,PLOT_EMPTY_VALUE,0);
index ++;
   SetIndexBuffer(index,ShadowBufferLow,INDICATOR_DATA);
   PlotIndexSetInteger(index,PLOT_DRAW_BEGIN,min_rates_total);
   ArraySetAsSeries(ShadowBufferLow,true);
   PlotIndexSetDouble(index,PLOT_EMPTY_VALUE,0);
index ++;
   SetIndexBuffer(index,CounterBufferLow,INDICATOR_DATA);
   PlotIndexSetInteger(index,PLOT_DRAW_BEGIN,min_rates_total);
   ArraySetAsSeries(CounterBufferLow,true);
   PlotIndexSetDouble(index,PLOT_EMPTY_VALUE,0);
//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- name for the data window and the label for sub-windows
   string short_name="Ultimate Signal";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   
      PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);

   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-20);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,20);
   
//----  
return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate
(const int rates_total,
const int prev_calculated,
const datetime &Time[],
const double &Open[],
const double &High[],
const double &Low[],
const double &Close[],
const long &Tick_Volume[],
const long &Volume[],
const int &Spread[]
)
  {
//---- checking the number of bars to be enough for calculation
   if(BarsCalculated(Ind_Handle)<rates_total || rates_total<min_rates_total) return(RESET);

//---- declaration of local variables
   int to_copy,limit,bar,trend;
   double Hi,Lo,vlt,Brick,Up,Dn;
   double IndArray[];
   static double Brick_,Up_,Dn_;
   static int trend_;

//---- indexing elements in arrays as timeseries  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(Open,true);
   
   ArraySetAsSeries(IndArray,true);

//--- calculations of the necessary amount of data to be copied and
//----the limit starting number for loop of bars recalculation
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of calculation of an indicator
     {
      limit=rates_total-min_rates_total-1; // starting index for calculation of all bars
      if(Price==Close_) {Hi=Close[limit]; Lo=Hi;}
      else {Hi=High[limit]; Lo=Low[limit];}
      Brick_=MathMax(K*(Hi-Lo),sens);
      Up_=Hi;
      Dn_=Lo;
      trend_=0;
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars
//----  
   to_copy=limit+1;

//---- copy newly appeared data into the arrays
   if(CopyBuffer(Ind_Handle,0,0,to_copy,IndArray)<=0) return(RESET);
  
//---- restoring the values of the variables
   Up=Up_;
   Dn=Dn_;
   Brick=Brick_;
   trend=trend_;

//---- first indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
     SellBuffer[bar]=BuyBuffer[bar]=0;
     
      if(Price==Close_) {Hi=Close[bar]; Lo=Hi;}
      else {Hi=High[bar]; Lo=Low[bar];}

      vlt=MathMax(K*IndArray[bar],sens);

      if(Hi>Up+Brick)
        {
         if(Brick) Up+=MathFloor((Hi-Up)/Brick)*Brick;
         Brick=vlt;
         Dn=Up-Brick;
        }

      if(Lo<Dn-Brick)
        {
         if(Brick) Dn-=MathFloor((Dn-Lo)/Brick)*Brick;
         Brick=vlt;
         Up=Dn+Brick;
        }

      UpBuffer[bar]=Up;
      DnBuffer[bar]=Dn;
      StopBuyBuffer[bar]=0.0;
      StopSellBuffer[bar]=0.0;

      if(UpBuffer[bar+1]<UpBuffer[bar]) trend=+1;
      if(DnBuffer[bar+1]>DnBuffer[bar]) trend=-1;

      if(trend>0) StopBuyBuffer[bar]=DnBuffer[bar]-Brick;
      if(trend<0) StopSellBuffer[bar]=UpBuffer[bar]+Brick;
//Ricardo Sinal de Venda
if(UpBuffer[bar]<UpBuffer[bar+1]) {sombrahigh=0; counthigh=0;} else if (UpBuffer[bar]>UpBuffer[bar+1]) counthigh ++;
CounterBufferHigh[bar]=counthigh;

if(trend>0)
{
if(High[bar]-UpBuffer[bar]>sombrahigh)sombrahigh=High[bar]-UpBuffer[bar];

ShadowBufferHigh[bar]=sombrahigh;
}
else
{
ShadowBufferHigh[bar]=0;
sombrahigh=0;
}
if(CounterBufferHigh[bar]>=CountMin && sombrahigh>ShadowMin && Close[bar]<Open[bar] && Low[bar]<DnBuffer[bar])SellBuffer[bar]=High[bar]; else SellBuffer[bar]=0;


//Ricardo Sinal de Compra
if(DnBuffer[bar]>DnBuffer[bar+1]) {sombralow=0; countlow=0;} else if (DnBuffer[bar]<DnBuffer[bar+1]) countlow ++;
CounterBufferLow[bar]=countlow;

if(trend<0)
{
if(DnBuffer[bar]-Low[bar]>sombralow)sombralow=DnBuffer[bar]-Low[bar];

ShadowBufferLow[bar]=sombralow;
}
else
{
ShadowBufferLow[bar]=0;
sombralow=0;
}
if(CounterBufferLow[bar]>=CountMin && sombralow>ShadowMin && Close[bar]>Open[bar] && High[bar]>UpBuffer[bar])BuyBuffer[bar]=Low[bar]; else BuyBuffer[bar]=0;


      //---- memorize values of the variables before the multiple running at the current bar
      if(bar)
        {
         Up_=Up;
         Dn_=Dn;
         Brick_=Brick;
         trend_=trend;
        }
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
