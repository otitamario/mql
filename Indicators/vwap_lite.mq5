//+------------------------------------------------------------------+
//|                                                    VWAP_Lite.mq5 |
//|                     Copyright 2016, SOL Digital Consultoria LTDA |
//|                          http://www.soldigitalconsultoria.com.br |
//+------------------------------------------------------------------+
#property copyright         "Copyright 2016, SOL Digital Consultoria LTDA"
#property link              "http://www.soldigitalconsultoria.com.br"
#property version           "1.49"

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3

#property indicator_label1  "VWAP Daily"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_DASH
#property indicator_width1  2

#property indicator_label2  "VWAP Weekly"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrBlue
#property indicator_style2  STYLE_DASH
#property indicator_width2  2

#property indicator_label3  "VWAP Monthly"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrGreen
#property indicator_style3  STYLE_DASH
#property indicator_width3  2
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum DATE_TYPE 
  {
   DAILY,
   WEEKLY,
   MONTHLY
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum PRICE_TYPE 
  {
   OPEN,
   CLOSE,
   HIGH,
   LOW,
   OPEN_CLOSE,
   HIGH_LOW,
   CLOSE_HIGH_LOW,
   OPEN_CLOSE_HIGH_LOW
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CreateDateTime(DATE_TYPE nReturnType=DAILY,datetime dtDay=D'2000.01.01 00:00:00',int pHour=0,int pMinute=0,int pSecond=0) 
  {
   datetime    dtReturnDate;
   MqlDateTime timeStruct;

   TimeToStruct(dtDay,timeStruct);
   timeStruct.hour = pHour;
   timeStruct.min  = pMinute;
   timeStruct.sec  = pSecond;
   dtReturnDate=(StructToTime(timeStruct));

   if(nReturnType==WEEKLY) 
     {
      while(timeStruct.day_of_week!=0) 
        {
         dtReturnDate=(dtReturnDate-86400);
         TimeToStruct(dtReturnDate,timeStruct);
        }
     }

   if(nReturnType==MONTHLY) 
     {
      timeStruct.day=1;
      dtReturnDate=(StructToTime(timeStruct));
     }

   return dtReturnDate;
  }

//sinput  string      Indicator_Name      = "Volume Weighted Average Price (VWAP)";
input   PRICE_TYPE  Price_Type          = CLOSE;
input   bool        Calc_Every_Tick     = false;
input   bool        Enable_Daily        = true;
input   bool        Show_Daily_Value    = true;
input   bool        Enable_Weekly       = false;
input   bool        Show_Weekly_Value   = false;
input   bool        Enable_Monthly      = false;
input   bool        Show_Monthly_Value  = false;

double          VWAP_Buffer_Daily[],VWAP_Buffer_Weekly[],VWAP_Buffer_Monthly[];
double          nPriceArr[],nTotalTPV[],nTotalVol[];
double          nSumDailyTPV = 0, nSumWeeklyTPV = 0, nSumMonthlyTPV = 0;
double          nSumDailyVol = 0, nSumWeeklyVol = 0, nSumMonthlyVol = 0;
int             nIdxDaily=0,nIdxWeekly=0,nIdxMonthly=0,nIdx=0;
bool            bIsFirstRun=true;
string          sDailyStr = "", sWeeklyStr  = "", sMonthlyStr = "";
datetime        dtLastDay = CreateDateTime(DAILY), dtLastWeek = CreateDateTime(WEEKLY), dtLastMonth = CreateDateTime(MONTHLY);
ENUM_TIMEFRAMES LastTimePeriod=PERIOD_MN1;
int             nStringYDistance=40;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() 
  {
   IndicatorSetString(INDICATOR_SHORTNAME,"vwap_lite");

   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

   SetIndexBuffer(0,VWAP_Buffer_Daily,INDICATOR_DATA);
   SetIndexBuffer(1,VWAP_Buffer_Weekly,INDICATOR_DATA);
   SetIndexBuffer(2,VWAP_Buffer_Monthly,INDICATOR_DATA);

   if(Show_Daily_Value) 
     {
      ObjectCreate(0,"VWAP_Daily",OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,"VWAP_Daily",OBJPROP_CORNER,3);
      ObjectSetInteger(0,"VWAP_Daily",OBJPROP_XDISTANCE,180);
      ObjectSetInteger(0,"VWAP_Daily",OBJPROP_YDISTANCE,nStringYDistance);
      ObjectSetInteger(0,"VWAP_Daily",OBJPROP_COLOR,indicator_color1);
      ObjectSetInteger(0,"VWAP_Daily",OBJPROP_FONTSIZE,7);
      ObjectSetString(0,"VWAP_Daily",OBJPROP_FONT,"Verdana");
      ObjectSetString(0,"VWAP_Daily",OBJPROP_TEXT," ");
      nStringYDistance=nStringYDistance+20;
     }

   if(Show_Weekly_Value) 
     {
      ObjectCreate(0,"VWAP_Weekly",OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,"VWAP_Weekly",OBJPROP_CORNER,3);
      ObjectSetInteger(0,"VWAP_Weekly",OBJPROP_XDISTANCE,180);
      ObjectSetInteger(0,"VWAP_Weekly",OBJPROP_YDISTANCE,nStringYDistance);
      ObjectSetInteger(0,"VWAP_Weekly",OBJPROP_COLOR,indicator_color2);
      ObjectSetInteger(0,"VWAP_Weekly",OBJPROP_FONTSIZE,7);
      ObjectSetString(0,"VWAP_Weekly",OBJPROP_FONT,"Verdana");
      ObjectSetString(0,"VWAP_Weekly",OBJPROP_TEXT," ");
      nStringYDistance=nStringYDistance+20;
     }

   if(Show_Monthly_Value) 
     {
      ObjectCreate(0,"VWAP_Monthly",OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,"VWAP_Monthly",OBJPROP_CORNER,3);
      ObjectSetInteger(0,"VWAP_Monthly",OBJPROP_XDISTANCE,180);
      ObjectSetInteger(0,"VWAP_Monthly",OBJPROP_YDISTANCE,nStringYDistance);
      ObjectSetInteger(0,"VWAP_Monthly",OBJPROP_COLOR,indicator_color3);
      ObjectSetInteger(0,"VWAP_Monthly",OBJPROP_FONTSIZE,7);
      ObjectSetString(0,"VWAP_Monthly",OBJPROP_FONT,"Verdana");
      ObjectSetString(0,"VWAP_Monthly",OBJPROP_TEXT," ");
     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int pReason) 
  {
   if(Show_Daily_Value) ObjectDelete(0,"VWAP_Daily");
   if(Show_Weekly_Value) ObjectDelete(0,"VWAP_Weekly");
   if(Show_Monthly_Value) ObjectDelete(0,"VWAP_Monthly");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int       rates_total,
                const int       prev_calculated,
                const datetime  &time[],
                const double    &open[],
                const double    &high[],
                const double    &low[],
                const double    &close[],
                const long      &tick_volume[],
                const long      &volume[],
                const int       &spread[]) 
  {

   if(PERIOD_CURRENT!=LastTimePeriod) 
     {
      bIsFirstRun=true;
      LastTimePeriod=PERIOD_CURRENT;
     }

   if(rates_total>prev_calculated || bIsFirstRun || Calc_Every_Tick) 
     {
      ArrayResize(nPriceArr,rates_total);
      ArrayResize(nTotalTPV,rates_total);
      ArrayResize(nTotalVol,rates_total);

      if(Enable_Daily)   {nIdx = nIdxDaily;   nSumDailyTPV = 0;   nSumDailyVol = 0;}
      if(Enable_Weekly)  {nIdx = nIdxWeekly;  nSumWeeklyTPV = 0;  nSumWeeklyVol = 0;}
      if(Enable_Monthly) {nIdx = nIdxMonthly; nSumMonthlyTPV = 0; nSumMonthlyVol = 0;}

      for(; nIdx<rates_total; nIdx++) 
        {
         VWAP_Buffer_Daily[nIdx]=EMPTY_VALUE;
         VWAP_Buffer_Weekly[nIdx]=EMPTY_VALUE;
         VWAP_Buffer_Monthly[nIdx]=EMPTY_VALUE;

         if(CreateDateTime(DAILY,time[nIdx])!=dtLastDay) 
           {
            nIdxDaily=nIdx;
            nSumDailyTPV = 0;
            nSumDailyVol = 0;
           }
         if(CreateDateTime(WEEKLY,time[nIdx])!=dtLastWeek) 
           {
            nIdxWeekly=nIdx;
            nSumWeeklyTPV = 0;
            nSumWeeklyVol = 0;
           }
         if(CreateDateTime(MONTHLY,time[nIdx])!=dtLastMonth) 
           {
            nIdxMonthly=nIdx;
            nSumMonthlyTPV = 0;
            nSumMonthlyVol = 0;
           }

         nPriceArr[nIdx] = 0;
         nTotalTPV[nIdx] = 0;
         nTotalVol[nIdx] = 0;

         switch(Price_Type) 
           {
            case OPEN:
               nPriceArr[nIdx]=open[nIdx];
               break;
            case CLOSE:
               nPriceArr[nIdx]=close[nIdx];
               break;
            case HIGH:
               nPriceArr[nIdx]=high[nIdx];
               break;
            case LOW:
               nPriceArr[nIdx]=low[nIdx];
               break;
            case HIGH_LOW:
               nPriceArr[nIdx]=(high[nIdx]+low[nIdx])/2;
               break;
            case OPEN_CLOSE:
               nPriceArr[nIdx]=(open[nIdx]+close[nIdx])/2;
               break;
            case CLOSE_HIGH_LOW:
               nPriceArr[nIdx]=(close[nIdx]+high[nIdx]+low[nIdx])/3;
               break;
            case OPEN_CLOSE_HIGH_LOW:
               nPriceArr[nIdx]=(open[nIdx]+close[nIdx]+high[nIdx]+low[nIdx])/4;
               break;
            default:
               nPriceArr[nIdx]=(close[nIdx]+high[nIdx]+low[nIdx])/3;
               break;
           }

         if(tick_volume[nIdx]) 
           {
            nTotalTPV[nIdx] = (nPriceArr[nIdx] * tick_volume[nIdx]);
            nTotalVol[nIdx] = (double)tick_volume[nIdx];
              } else if(volume[nIdx]) {
            nTotalTPV[nIdx] = (nPriceArr[nIdx] * volume[nIdx]);
            nTotalVol[nIdx] = (double)volume[nIdx];
           }

         if(Enable_Daily && (nIdx>=nIdxDaily)) 
           {
            nSumDailyTPV += nTotalTPV[nIdx];
            nSumDailyVol += nTotalVol[nIdx];

            if(nSumDailyVol)
               VWAP_Buffer_Daily[nIdx]=(nSumDailyTPV/nSumDailyVol);

            if((sDailyStr!="VWAP Daily: "+(string)NormalizeDouble(VWAP_Buffer_Daily[nIdx],_Digits)) && Show_Daily_Value) 
              {
               sDailyStr="VWAP Daily: "+(string)NormalizeDouble(VWAP_Buffer_Daily[nIdx],_Digits);
               ObjectSetString(0,"VWAP_Daily",OBJPROP_TEXT,sDailyStr);
              }
           }

         if(Enable_Weekly && (nIdx>=nIdxWeekly)) 
           {
            nSumWeeklyTPV += nTotalTPV[nIdx];
            nSumWeeklyVol += nTotalVol[nIdx];

            if(nSumWeeklyVol)
               VWAP_Buffer_Weekly[nIdx]=(nSumWeeklyTPV/nSumWeeklyVol);

            if((sWeeklyStr!="VWAP Weekly: "+(string)NormalizeDouble(VWAP_Buffer_Weekly[nIdx],_Digits)) && Show_Weekly_Value) 
              {
               sWeeklyStr="VWAP Weekly: "+(string)NormalizeDouble(VWAP_Buffer_Weekly[nIdx],_Digits);
               ObjectSetString(0,"VWAP_Weekly",OBJPROP_TEXT,sWeeklyStr);
              }
           }

         if(Enable_Monthly && (nIdx>=nIdxMonthly)) 
           {
            nSumMonthlyTPV += nTotalTPV[nIdx];
            nSumMonthlyVol += nTotalVol[nIdx];

            if(nSumMonthlyVol)
               VWAP_Buffer_Monthly[nIdx]=(nSumMonthlyTPV/nSumMonthlyVol);

            if((sMonthlyStr!="VWAP Monthly: "+(string)NormalizeDouble(VWAP_Buffer_Monthly[nIdx],_Digits)) && Show_Monthly_Value) 
              {
               sMonthlyStr="VWAP Monthly: "+(string)NormalizeDouble(VWAP_Buffer_Monthly[nIdx],_Digits);
               ObjectSetString(0,"VWAP_Monthly",OBJPROP_TEXT,sMonthlyStr);
              }
           }

         dtLastDay=CreateDateTime(DAILY,time[nIdx]);
         dtLastWeek=CreateDateTime(WEEKLY,time[nIdx]);
         dtLastMonth=CreateDateTime(MONTHLY,time[nIdx]);
        }

      bIsFirstRun=false;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
