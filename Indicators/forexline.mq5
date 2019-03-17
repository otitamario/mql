//+------------------------------------------------------------------+
//|                                                    ForexLine.mq5 |
//|                              Copyright 2016,  3rjfx ~ 24/01/2016 |
//|                              https://www.mql5.com/en/users/3rjfx |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016,  3rjfx ~ 24/01/2016"
#property link      "https://www.mql5.com/en/users/3rjfx"
#property version   "1.00"
#property description "ForexLine is the indicator for the MT5, base on ForexLine indicator on MT4."
#property description "ForexLine indicator provides signals for trade,"
#property description "white line (sell signal) and the blue line (buy signal)."
//--
#include <MovingAverages.mqh>
//--
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   6
//--
#property indicator_type1   DRAW_NONE
//--
#property indicator_type2   DRAW_NONE
//--
#property indicator_type3   DRAW_NONE
//--
#property indicator_type4   DRAW_NONE
//--
#property indicator_type5   DRAW_LINE
#property indicator_style5  STYLE_SOLID 
#property indicator_width5  3
#property indicator_label5  "Rice Above: "
//--
#property indicator_type6   DRAW_LINE
#property indicator_style6  STYLE_SOLID 
#property indicator_width6  3
#property indicator_label6  "Down Below: "
//--
#property indicator_type7   DRAW_NONE
//--
#property indicator_type8   DRAW_NONE
//--
//---
input bool      SoundAlerts = true;
input bool      MsgAlerts   = true;
input bool      eMailAlerts = false;
input string SoundAlertFile = "alert.wav";
input color ForexLineColor1=clrBlue;   // Line Up
input color ForexLineColor2=clrRed;  // Line Down
//----
//-- buffers
double lwma05Buffers[];
double lwma10Buffers[];
double lwma20Buffers[];
double line20Buffers[];
double uplineBuffers[];
double dnlineBuffers[];
double macdMnBuffers[];
double macdSgBuffers[];
//-
int curMnt;
int prvMnt;
int mafast=5;
int maslow=10;
int mdma20=20;
int cural,prval;
int prvAlertBar;
//--- MA & MACD handles
int ExtMaFastHandle;
int ExtMaSlowHandle;
int ExtMACDHandle;
//--
bool lup,ldn;
//--
string short_name;
string alBase,alSubj,alMsg;
//--
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
//-- Checking the Digits Point
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--
//--- indicator buffers mapping
//--
   SetIndexBuffer(0,lwma05Buffers,INDICATOR_CALCULATIONS);
   SetIndexBuffer(1,lwma10Buffers,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,lwma20Buffers,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,line20Buffers,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,uplineBuffers,INDICATOR_DATA);
   SetIndexBuffer(5,dnlineBuffers,INDICATOR_DATA);
   SetIndexBuffer(6,macdMnBuffers,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,macdSgBuffers,INDICATOR_CALCULATIONS);
//---
//-- indicator drawing shape styles
   PlotIndexSetInteger(4,PLOT_LINE_COLOR,ForexLineColor1);
   PlotIndexSetInteger(5,PLOT_LINE_COLOR,ForexLineColor2);
//--
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,maslow);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,maslow);
//--
   short_name="FXLine,"+string(_Symbol)+","+"TF:"+strTF(_Period);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--
//---
   ExtMaFastHandle=iMA(_Symbol,PERIOD_CURRENT,mafast,0,MODE_LWMA,PRICE_MEDIAN);
   if(ExtMaFastHandle==INVALID_HANDLE)
     {
      printf("Error creating indicator Fast(5) LWMA for ",_Symbol);
      return(INIT_FAILED);
     }
//--
   ExtMaSlowHandle=iMA(_Symbol,PERIOD_CURRENT,mdma20,0,MODE_SMA,PRICE_MEDIAN);
   if(ExtMaSlowHandle==INVALID_HANDLE)
     {
      printf("Error creating indicator Slow(20) SMA Median Price for ",_Symbol);
      return(INIT_FAILED);
     }
//--
   ExtMACDHandle=iMACD(_Symbol,PERIOD_CURRENT,12,26,9,PRICE_CLOSE);
   if(ExtMACDHandle==INVALID_HANDLE)
     {
      printf("Failed to create handle of the iMACD indicator for ",_Symbol);
      return(INIT_FAILED);
     }
//--
//---
//--- initialization done
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----  
//--
   ObjectsDeleteAll(ChartID(),0,-1);
   GlobalVariablesDeleteAll();
//----
   return;
  }
//----
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
//---
   int i,xlimit;
   cural=-1;
   lup=false;
   ldn=false;
   double FLOpen;
   double FLClos;
//--- check for bars count
   if(rates_total<=maslow) return(0);
//--- Set Last error value to Zero
   ResetLastError();
//--
//--- counting from rates_total to 0
   ArraySetAsSeries(lwma05Buffers,true);
   ArraySetAsSeries(lwma10Buffers,true);
   ArraySetAsSeries(lwma20Buffers,true);
   ArraySetAsSeries(line20Buffers,true);
   ArraySetAsSeries(uplineBuffers,true);
   ArraySetAsSeries(dnlineBuffers,true);
   ArraySetAsSeries(macdMnBuffers,true);
   ArraySetAsSeries(macdSgBuffers,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(close,true);
//--
//--- not all data may be calculated
   int calculated=BarsCalculated(ExtMaFastHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtMaFastHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
//--
   calculated=BarsCalculated(ExtMaSlowHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtSlowMaHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
//--
   calculated=BarsCalculated(ExtMACDHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of ExtMACDHandle is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }
//---
//--- we can copy not all data
   int to_copy;
   int values_to_copy;
   if(prev_calculated>rates_total || prev_calculated<0)
     {
      to_copy=values_to_copy=rates_total;
     }
   else
     {
      to_copy=values_to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++; values_to_copy++;
     }
//--
//--
//--- get ExtMaFastHandle buffers
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ExtMaFastHandle,0,0,to_copy,lwma05Buffers)<0)
     {
      Print("Getting ExtMaFastHandle buffers is failed! Error",GetLastError());
      return(0);
     }
//--- get ExtMaSlowHandle buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ExtMaSlowHandle,0,0,to_copy,line20Buffers)<0)
     {
      Print("Getting ExtMaSlowHandle buffers is failed! Error",GetLastError());
      return(0);
     }
//--- get ExtMACDHandle buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(ExtMACDHandle,0,0,values_to_copy,macdMnBuffers)<0)
     {
      Print("Getting MACD Main buffers is failed! Error",GetLastError());
      return(0);
     }
//--
   if(CopyBuffer(ExtMACDHandle,1,0,values_to_copy,macdSgBuffers)<0)
     {
      Print("Getting MACD Signal buffers is failed! Error",GetLastError());
      return(0);
     }
//--
//--- last counted bar will be recounted
   xlimit=rates_total-prev_calculated;
   if(prev_calculated>0)
      xlimit++;
//----
//--
//--- get LWMA 10 Buffers
   LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,maslow,lwma05Buffers,lwma10Buffers,to_copy);
//--- get LWMA 20 Buffers
   LinearWeightedMAOnBuffer(rates_total,prev_calculated,0,mdma20,lwma10Buffers,lwma20Buffers,to_copy);
//--
//---- main cycle
//--
   for(i=xlimit-1; i>=0; i--)
     {
      //--
      if((lwma05Buffers[i]>lwma20Buffers[i])) {lup=true; ldn=false;}
      if((lwma05Buffers[i]<lwma20Buffers[i])) {ldn=true; lup=false;}
      if(lup==true)
        {uplineBuffers[i]=line20Buffers[i]; dnlineBuffers[i]=EMPTY_VALUE;}
      if(ldn==true)
        {dnlineBuffers[i]=line20Buffers[i]; uplineBuffers[i]=EMPTY_VALUE;}
      //--
      if(i==0)
        {
         //--
         double flmacd0=macdMnBuffers[i]-macdSgBuffers[i];
         double flmacd1=macdMnBuffers[i+1]-macdSgBuffers[i+1];
         double macdfm0=macdMnBuffers[i];
         double macdfm1=macdMnBuffers[i+1];
         FLOpen=(high[i+1]+low[i+1]+close[i+1]+close[i+1])/4;
         FLClos=(high[i]+low[i]+close[i]+close[i])/4;
         bool flmacdup=((flmacd0>flmacd1)&&(macdfm0>macdfm1));
         bool flmacddn=((flmacd0<flmacd1)&&(macdfm0<macdfm1));
         //--
         if((lup==true) && (lwma05Buffers[0]>lwma05Buffers[1]) && (flmacdup) && (FLClos>FLOpen) && 
            (close[0]>open[0]) && (close[0]>lwma05Buffers[0])) {cural=3;} // goes up
         //-
         if((lup==true) && (lwma05Buffers[0]>lwma05Buffers[1]) && (flmacddn) && (FLClos<FLOpen) && 
            (close[0]<lwma05Buffers[0])) {cural=1;} // feasibility down
         //-
         if((lup==true) && (lwma05Buffers[0]<=lwma05Buffers[1]) && (flmacddn) && (FLClos<FLOpen) && 
            (close[0]<lwma05Buffers[0])) {cural=5;} // began to down
         //--
         if((ldn==true) && (lwma05Buffers[0]<lwma05Buffers[1]) && (flmacddn) && (FLClos<FLOpen) && 
            (close[0]<open[0]) && (close[0]<lwma05Buffers[0])) {cural=2;} // goes down
         //-
         if((ldn==true) && (lwma05Buffers[0]<lwma05Buffers[1]) && (flmacdup) && (FLClos>FLOpen) && 
            (close[0]>lwma05Buffers[0])) {cural=0;} // feasibility up
         //-
         if((ldn==true) && (lwma05Buffers[0]>=lwma05Buffers[1]) && (flmacdup) && (FLClos>FLOpen) && 
            (close[0]>lwma05Buffers[0])) {cural=4;} // began to up
         //--
        }
      //--
     }
//---
   ChartRedraw(0);
   posAlerts(cural);
//---
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//---//

//---/
void doAlerts(string msgText,string eMailSub)
  {
//--
   if(MsgAlerts) Alert(msgText);
   if(SoundAlerts) PlaySound(SoundAlertFile);
   if(eMailAlerts) SendMail(eMailSub,msgText);
//--
  }
//---/

//---/
string strTF(ENUM_TIMEFRAMES tf)
  {
   switch(tf)
     {
      case PERIOD_M1: return "M1";
      case PERIOD_M5: return "M5";
      case PERIOD_M15: return "M15";
      case PERIOD_M30: return "M30";
      case PERIOD_H1: return "H1";
      case PERIOD_H4: return "H4";
      case PERIOD_D1: return "D1";
      case PERIOD_W1: return "W1";
      case PERIOD_MN1: return "MN1";
     }
   return "Unknown TF";
//--
  }
//---/

//---/
void posAlerts(int alerts)
  {
//--
   curMnt=TIME_MINUTES;
   if(curMnt!=prvMnt)
     {
      //--
      if((cural!=prval) && (alerts==3))
        {
         alBase=short_name+" @ "+TimeToString(TimeLocal(),TIME_MINUTES|TIME_SECONDS);
         alSubj=alBase+". The Price Goes Up,";
         alMsg=alSubj+" Action: Open BUY.!!";
         prvMnt=curMnt;
         prval=cural;
         doAlerts(alMsg,alSubj);
        }
      //--
      if((cural!=prval) && (alerts==2))
        {
         alBase=short_name+" @ "+TimeToString(TimeLocal(),TIME_MINUTES|TIME_SECONDS);
         alSubj=alBase+". The Price Goes Down,";
         alMsg=alSubj+" Action: Open SELL.!!";
         prvMnt=curMnt;
         prval=cural;
         doAlerts(alMsg,alSubj);
        }
      //--
      if((cural!=prval) && (alerts==0))
        {
         alBase=short_name+" @ "+TimeToString(TimeLocal(),TIME_MINUTES|TIME_SECONDS);
         alSubj=alBase+". The Price Feasibility Up,";
         alMsg=alSubj+" Action: Wait and See.!!";
         prvMnt=curMnt;
         prval=cural;
         doAlerts(alMsg,alSubj);
        }
      //--
      if((cural!=prval) && (alerts==1))
        {
         alBase=short_name+" @ "+TimeToString(TimeLocal(),TIME_MINUTES|TIME_SECONDS);
         alSubj=alBase+". The Price Feasibility Down,";
         alMsg=alSubj+" Action: Wait and See.!!";
         prvMnt=curMnt;
         prval=cural;
         doAlerts(alMsg,alSubj);
        }
      //--
      if((cural!=prval) && (alerts==4))
        {
         alBase=short_name+" @ "+TimeToString(TimeLocal(),TIME_MINUTES|TIME_SECONDS);
         alSubj=alBase+" The Price Began to Up,";
         alMsg=alSubj+" Action: Wait and See.!!";
         prvMnt=curMnt;
         prval=cural;
         doAlerts(alMsg,alSubj);
        }
      //--
      if((cural!=prval) && (alerts==5))
        {
         alBase=short_name+" @ "+TimeToString(TimeLocal(),TIME_MINUTES|TIME_SECONDS);
         alSubj=alBase+" The Price Began to Down,";
         alMsg=alSubj+" Action: Wait and See.!!";
         prvMnt=curMnt;
         prval=cural;
         doAlerts(alMsg,alSubj);
        }
      //--
     }
//--
   return;
//--
//----
  } //-end posAlerts()
//---/
//+------------------------------------------------------------------+
