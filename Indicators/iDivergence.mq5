//+------------------------------------------------------------------+
//|                                                  iDivergence.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
//--- plot Label1
#property indicator_label1  "osc"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Label2
#property indicator_label2  "buy"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrAqua
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot Label3
#property indicator_label3  "sell"
#property indicator_type3   DRAW_ARROW
#property indicator_color3  clrDeepPink
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

//--- input parameters

#include <UniOsc/UniOscDefines.mqh>
#include <UniDiver/UniDiverDefines.mqh>
#include <UniDiver/CUniDiverExtremums.mqh>

input EAlerts              Alerts            =  Alerts_off;
input int                  Number            =  3;
input EExtrType            ExtremumType      =  ExtrBars;
input int                  LeftBars          =  2;
input int                  RightBars         =  -1;
input double               MinMaxThreshold   =  5;
input double               IndLevel          =  0;
input int                  PriceLevel        =  0;
input bool                 Auto5Digits       =  true;
input bool                 ArrowsOnChart     =  true;
input bool                 DrawLines         =  true;
input color                ColBuy            =  clrAqua;
input color                ColSell           =  clrDeepPink;

input EOscUniType          Type              =  OscUni_RSI;
input int                  Period1           =  14;
input int                  Period2           =  14;
input int                  Period3           =  14;
input ENUM_MA_METHOD       MaMethod          =  MODE_EMA;
input ENUM_APPLIED_PRICE   Price             =  PRICE_CLOSE;   
input ENUM_APPLIED_VOLUME  Volume            =  VOLUME_TICK;   
input ENUM_STO_PRICE       StPrice           =  STO_LOWHIGH;   
      color                ColorLine1        =  clrLightSeaGreen;
      color                ColorLine2        =  clrRed;
      color                ColorHisto        =  clrGray;

int h;

CDiverBase * diver;

//--- indicator buffers
double buf_osc[];
double buf_buy[];
double buf_sell[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){

   h=iCustom(Symbol(),Period(),"iUniOsc", Type,
                                          Period1,
                                          Period2,
                                          Period3,
                                          MaMethod,
                                          Price,
                                          Volume,
                                          StPrice,
                                          ColorLine1,
                                          ColorLine2,
                                          ColorHisto);
   if(h==INVALID_HANDLE){
      Alert("Can't load indicator");
      return(INIT_FAILED);
   }

   //===

   switch(ExtremumType){
      case ExtrBars:
         diver=new CDiverBars(LeftBars,RightBars);
      break;
      case ExtrThreshold:
         diver=new CDiverThreshold(MinMaxThreshold);
      break;      
      case ExtrMiddle:
         diver=new CDiverMiddle(Type);
      break;      
   }
   
   int pl=PriceLevel;   
   if(Auto5Digits && (Digits()==5 || Digits()==3)){
      pl*=10;
   }
   
   diver.SetConditions(Number,Point()*pl,IndLevel);
   diver.SetDrawParmeters(ArrowsOnChart,DrawLines,ColBuy,ColSell);

//--- indicator buffers mapping
   SetIndexBuffer(0,buf_osc,INDICATOR_DATA);
   SetIndexBuffer(1,buf_buy,INDICATOR_DATA);
   SetIndexBuffer(2,buf_sell,INDICATOR_DATA);
   
   PlotIndexSetInteger(1,PLOT_ARROW,233);
   PlotIndexSetInteger(2,PLOT_ARROW,234);
   
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);
   PlotIndexSetInteger(2,PLOT_ARROW_SHIFT,-10);   
//---

   return(INIT_SUCCEEDED);
}

void OnDeinit(const int reason){
   if(CheckPointer(diver)==POINTER_DYNAMIC){
      delete(diver);
   } 
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
                const int &spread[]){
   
   int cnt;   
   
   if(prev_calculated==0){
      cnt=rates_total;
   }
   else{ 
      cnt=rates_total-prev_calculated+1; 
   }
   
   if(CopyBuffer(h,0,0,cnt,buf_osc)<=0){
      return(0);
   }   

   diver.Calculate(  rates_total,
                     prev_calculated,
                     time,
                     high,
                     low,
                     buf_osc,
                     buf_buy,
                     buf_sell);
                     
   if(ArrowsOnChart || DrawLines){
      ChartRedraw();
   }

   return(rates_total);                
}   

void CheckAlerts(int rates_total,const datetime & time[]){
   if(Alerts!=Alerts_off){
      static datetime tm0=0;
      static datetime tm1=0;
      if(tm0==0){
         tm0=time[rates_total-1];
         tm1=time[rates_total-1];
      }
      string mes="";
      if(buf_buy[rates_total-Alerts]!=EMPTY_VALUE && 
         tm0!=time[rates_total-1]
      ){
         tm0=time[rates_total-1];
         mes=mes+" buy";
      }
      if(buf_sell[rates_total-Alerts]!=EMPTY_VALUE && 
         tm1!=time[rates_total-1]
      ){
         tm1=time[rates_total-1];
         mes=mes+" sell";
      } 
      if(mes!=""){
         Alert(MQLInfoString(MQL_PROGRAM_NAME)+"("+Symbol()+","+IntegerToString(PeriodSeconds()/60)+"):"+mes);
      }        
   }   
}