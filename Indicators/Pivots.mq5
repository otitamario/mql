//+------------------------------------------------------------------+
//|                                                       Pivots.mq5 |
//|                                           Copyright 2017, denkir |
//|                             https://www.mql5.com/ru/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, denkir"
#property link      "https://www.mql5.com/ru/users/denkir"
#property version   "1.00"
//--- include
#include "CisNewBar.mqh"
#include "UserDateTime.mqh"
//---
#property indicator_chart_window
//--- число буферов
#define BUF_NUM 13         
#property indicator_plots BUF_NUM        
#property indicator_buffers BUF_NUM
//+------------------------------------------------------------------+
//| Структура индикаторного буфера                                   |
//+------------------------------------------------------------------+
struct SBuffer
  {
   double            data[];
   ENUM_INDEXBUFFER_TYPE type;
  };
//+------------------------------------------------------------------+
//| Логическое перечисление                                          |
//+------------------------------------------------------------------+
enum ENUM_SET_LOGIC
  {
   No=0,  // Нет
   Yes=1, // Да
  };
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
sinput string Info_pivot="+===-- Уровень пивота --====+"; // +===-- Уровень пивота --====+
input color InpPivotColor=clrOrangeRed;                      // Цвет
input ENUM_LINE_STYLE InpPivotStyle=STYLE_SOLID;             // Стиль линии
input int InpPivotWidth=3;                                   // Толщина линии
//---
sinput string Info_lvl_0_5="+===-- Уровни 0.5 --====+"; // +===-- Уровни 0.5 --====+
input ENUM_SET_LOGIC InpToPlot_0_5=Yes;                      // Отображать?
input color InpResColor_0_5=clrLightSkyBlue;                 // Цвет сопротивления
input color InpSupColor_0_5=clrHotPink;                      // Цвет поддержки
input ENUM_LINE_STYLE InpPivotStyle_0_5=STYLE_DOT;           // Стиль линии
input int InpPivotWidth_0_5=1;                               // Толщина линии                              
//---
sinput string Info_lvl_1_0="+===-- Уровни 1.0 --====+"; // +===-- Уровни 1.0 --====+
input ENUM_SET_LOGIC InpToPlot_1_0=Yes;                      // Отображать?
input color InpResColor_1_0=clrLightSeaGreen;                // Цвет сопротивления
input color InpSupColor_1_0=clrPlum;                         // Цвет поддержки
input ENUM_LINE_STYLE InpPivotStyle_1_0=STYLE_SOLID;         // Стиль линии
input int InpPivotWidth_1_0=2;                               // Толщина линии
//---
sinput string Info_lvl_1_5="+===-- Уровни 1.5 --====+"; // +===-- Уровни 1.5 --====+
input ENUM_SET_LOGIC InpToPlot_1_5=Yes;                      // Отображать?
input color InpResColor_1_5=clrSteelBlue;                    // Цвет сопротивления
input color InpSupColor_1_5=clrRed;                          // Цвет поддержки
input ENUM_LINE_STYLE InpPivotStyle_1_5=STYLE_DOT;           // Стиль линии
input int InpPivotWidth_1_5=1;                               // Толщина линии
//---
sinput string Info_lvl_2_0="+===-- Уровни 2.0 --====+"; // +===-- Уровни 2.0 --====+
input ENUM_SET_LOGIC InpToPlot_2_0=Yes;                      // Отображать?
input color InpResColor_2_0=clrLightBlue;                    // Цвет сопротивления
input color InpSupColor_2_0=clrPink;                         // Цвет поддержки
input ENUM_LINE_STYLE InpPivotStyle_2_0=STYLE_SOLID;         // Стиль линии
input int InpPivotWidth_2_0=2;                               // Толщина линии
//---
sinput string Info_lvl_2_5="+===-- Уровни 2.5 --====+"; // +===-- Уровни 2.5 --====+
input ENUM_SET_LOGIC InpToPlot_2_5=Yes;                      // Отображать?
input color InpResColor_2_5=clrSteelBlue;                    // Цвет сопротивления
input color InpSupColor_2_5=clrDeepPink;                     // Цвет поддержки
input ENUM_LINE_STYLE InpPivotStyle_2_5=STYLE_DOT;           // Стиль линии
input int InpPivotWidth_2_5=1;                               // Толщина линии
//---
sinput string Info_lvl_3_0="+===-- Уровни 3.0 --====+"; // +===-- Уровни 3.0 --====+
input ENUM_SET_LOGIC InpToPlot_3_0=Yes;                      // Отображать?
input color InpResColor_3_0=clrBlack;                        // Цвет сопротивления
input color InpSupColor_3_0=clrBrown;                        // Цвет поддержки
input ENUM_LINE_STYLE InpPivotStyle_3_0=STYLE_SOLID;         // Стиль линии
input int InpPivotWidth_3_0=2;                               // Толщина линии

//+------------------------------------------------------------------+
//| Globals                                                          |
//+------------------------------------------------------------------+
//---- индикаторные буферы
SBuffer gBuffers[BUF_NUM];
ENUM_SET_LOGIC gToPlotBuffer[BUF_NUM];
//--- новый день
CisNewBar gNewDay;
CisNewBar gNewMinute;
//--- границы дня: время
datetime gDayStart;
datetime gDayEnd;
//--- границы дня: бары
int gBarStart;
//--- цены
double gYesterdayHigh;
double gYesterdayLow;
double gYesterdayClose;
//--- значения уровней
double gPivotVal;    //  1)
double gResVal_0_5;  //  2)
double gSupVal_0_5;  //  3)
double gResVal_1_0;  //  4)
double gSupVal_1_0;  //  5)
double gResVal_1_5;  //  6)
double gSupVal_1_5;  //  7)
double gResVal_2_0;  //  8)
double gSupVal_2_0;  //  9)
double gResVal_2_5;  //  10)
double gSupVal_2_5;  //  11)
double gResVal_3_0;  //  12)
double gSupVal_3_0;  //  13)
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- проверить активный ТФ
   if(_Period>PERIOD_H1)
     {
      Print("Неправильно задан активный тайм-фрейм: он не должен быть старше Н1!");
      return INIT_FAILED;
     }
//--- проверить число буферов
   if(ArraySize(gBuffers)!=BUF_NUM)
     {
      Print("Неправильно задано число буферов!");
      return INIT_FAILED;
     }
//--- Свойства [start]
//--- 1) описание
   string labels[]=
     {
      "Pivot",
      "Res0.5","Sup0.5",
      "Res1.0","Sup1.0",
      "Res1.5","Sup1.5",
      "Res2.0","Sup2.0",
      "Res2.5","Sup2.5",
      "Res3.0","Sup3.0",
     };
//--- 2) стиль линии
   ENUM_LINE_STYLE line_styles[BUF_NUM];
   line_styles[0]=InpPivotStyle;
   line_styles[1]=line_styles[2]=InpPivotStyle_0_5;
   line_styles[3]=line_styles[4]=InpPivotStyle_1_0;
   line_styles[5]=line_styles[6]=InpPivotStyle_1_5;
   line_styles[7]=line_styles[8]=InpPivotStyle_2_0;
   line_styles[9]=line_styles[10]=InpPivotStyle_2_5;
   line_styles[11]=line_styles[12]=InpPivotStyle_3_0;
//--- 3) толщина линии
   int line_widths[BUF_NUM];
   line_widths[0]=InpPivotWidth;
   line_widths[1]=line_widths[2]=InpPivotWidth_0_5;
   line_widths[3]=line_widths[4]=InpPivotWidth_1_0;
   line_widths[5]=line_widths[6]=InpPivotWidth_1_5;
   line_widths[7]=line_widths[8]=InpPivotWidth_2_0;
   line_widths[9]=line_widths[10]=InpPivotWidth_2_5;
   line_widths[11]=line_widths[12]=InpPivotWidth_3_0;
//--- 4) цвета
   color line_colors[BUF_NUM];
   line_colors[0]=InpPivotColor;
   line_colors[1]=InpResColor_0_5;
   line_colors[2]=InpSupColor_0_5;
   line_colors[3]=InpResColor_1_0;
   line_colors[4]=InpSupColor_1_0;
   line_colors[5]=InpResColor_1_5;
   line_colors[6]=InpSupColor_1_5;
   line_colors[7]=InpResColor_2_0;
   line_colors[8]=InpSupColor_2_0;
   line_colors[9]=InpResColor_2_5;
   line_colors[10]=InpSupColor_2_5;
   line_colors[11]=InpResColor_3_0;
   line_colors[12]=InpSupColor_3_0;
//--- 5) флаги отрисовки   
   gToPlotBuffer[0]=Yes;
   gToPlotBuffer[1]=gToPlotBuffer[2]=InpToPlot_0_5;
   gToPlotBuffer[3]=gToPlotBuffer[4]=InpToPlot_1_0;
   gToPlotBuffer[5]=gToPlotBuffer[6]=InpToPlot_1_5;
   gToPlotBuffer[7]=gToPlotBuffer[8]=InpToPlot_2_0;
   gToPlotBuffer[9]=gToPlotBuffer[10]=InpToPlot_2_5;
   gToPlotBuffer[11]=gToPlotBuffer[12]=InpToPlot_3_0;
//--- Свойства [end]

//--- работа с буферами
   for(int buff_idx=0;buff_idx<BUF_NUM;buff_idx++)
     {
      //--- маппинг
      SetIndexBuffer(buff_idx,gBuffers[buff_idx].data);
      //--- пустое значение
      PlotIndexSetDouble(buff_idx,PLOT_EMPTY_VALUE,0.);
      //--- линия
      PlotIndexSetInteger(buff_idx,PLOT_DRAW_TYPE,DRAW_LINE);
      //--- если не отрисовывать
      if(!gToPlotBuffer[buff_idx])
         PlotIndexSetInteger(buff_idx,PLOT_DRAW_TYPE,DRAW_NONE);
      //--- толщина линии
      PlotIndexSetInteger(buff_idx,PLOT_LINE_WIDTH,line_widths[buff_idx]);
      //--- описание линии
      PlotIndexSetString(buff_idx,PLOT_LABEL,labels[buff_idx]);
      //--- цвет линии
      PlotIndexSetInteger(buff_idx,PLOT_LINE_COLOR,line_colors[buff_idx]);
      //--- стиль линии
      PlotIndexSetInteger(buff_idx,PLOT_LINE_STYLE,line_styles[buff_idx]);
      //--- как тайм-серия
      ArraySetAsSeries(gBuffers[buff_idx].data,true);
     }
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   gDayStart=gDayEnd=0;
   gBarStart=WRONG_VALUE;
   gPivotVal=0.;
//---
   return INIT_SUCCEEDED;
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
   ArraySetAsSeries(time,true);
//--- локальный счётчик посчитанных баров
   static int prev_calc;
   prev_calc=prev_calculated;
//--- если первый запуск
   if(prev_calc==0)
     {
      for(int buff_idx=0;buff_idx<BUF_NUM;buff_idx++)
         //--- опустошить буферы
         ArrayInitialize(gBuffers[buff_idx].data,0.);
      Print("Все буферы опустошены.");
      //--- считать последний бар новым
      gNewDay.SetLastBarTime(1);
      gNewMinute.SetLastBarTime(1);
     }
//--- текущий день
   SUserDateTime user_date;
   user_date.DateTime(time[0]);
   datetime today=user_date.DateOfDay();
//--- дневные котировки
   MqlRates daily_rates[];
   bool rates_copied=false;
   for(int att=0;att<5;att++)
     {
      int copied=CopyRates(_Symbol,PERIOD_D1,0,2,daily_rates);
      if(copied==2)
        {
         rates_copied=true;
         break;
        }
      Sleep(100);
     }
   if(!rates_copied)
     {
      Print("Не подгружены котировки из истории для дневного ТФ.");
      return prev_calculated;
     }
   ArraySetAsSeries(daily_rates,false);
   if(today!=daily_rates[1].time)
     {
      Print("Котировки не подгружены.");
      PrintFormat("День последнего бара на текущем ТФ: %s",TimeToString(today));
      PrintFormat("Последний день в истории: %s",TimeToString(daily_rates[1].time));
      return prev_calculated;
     }
//--- если есть новый день
   if(gNewDay.isNewBar(today))
     {
      PrintFormat("Новый день: %s",TimeToString(today));
      //--- нормализация цен
      double d_high=NormalizeDouble(daily_rates[0].high,_Digits);
      double d_low=NormalizeDouble(daily_rates[0].low,_Digits);
      double d_close=NormalizeDouble(daily_rates[0].close,_Digits);
      //--- запомнить цены
      gYesterdayHigh=d_high;
      gYesterdayLow=d_low;
      gYesterdayClose=d_close;
      //--- 1) пивот: PP = (HIGH + LOW + CLOSE) / 3        
      gPivotVal=NormalizeDouble((gYesterdayHigh+gYesterdayLow+gYesterdayClose)/3.,_Digits);
      //--- 4) RES1.0 = 2*PP - LOW
      gResVal_1_0=NormalizeDouble(2.*gPivotVal-gYesterdayLow,_Digits);
      //--- 5) SUP1.0 = 2*PP – HIGH
      gSupVal_1_0=NormalizeDouble(2.*gPivotVal-gYesterdayHigh,_Digits);
      //--- 8) RES2.0 = PP + (HIGH -LOW)
      gResVal_2_0=NormalizeDouble(gPivotVal+(gYesterdayHigh-gYesterdayLow),_Digits);
      //--- 9) SUP2.0 = PP - (HIGH – LOW)
      gSupVal_2_0=NormalizeDouble(gPivotVal-(gYesterdayHigh-gYesterdayLow),_Digits);
      //--- 12) RES3.0 = 2*PP + (HIGH – 2*LOW)
      gResVal_3_0=NormalizeDouble(2.*gPivotVal+(gYesterdayHigh-2.*gYesterdayLow),_Digits);
      //--- 13) SUP3.0 = 2*PP - (2*HIGH – LOW)
      gSupVal_3_0=NormalizeDouble(2.*gPivotVal-(2.*gYesterdayHigh-gYesterdayLow),_Digits);
      //--- 2) RES0.5 = (PP + RES1.0) / 2
      gResVal_0_5=NormalizeDouble((gPivotVal+gResVal_1_0)/2.,_Digits);
      //--- 3) SUP0.5 = (PP + SUP1.0) / 2
      gSupVal_0_5=NormalizeDouble((gPivotVal+gSupVal_1_0)/2.,_Digits);
      //--- 6) RES1.5 = (RES1.0 + RES2.0) / 2
      gResVal_1_5=NormalizeDouble((gResVal_1_0+gResVal_2_0)/2.,_Digits);
      //--- 7) SUP1.5 = (SUP1.0 + SUP2.0) / 2
      gSupVal_1_5=NormalizeDouble((gSupVal_1_0+gSupVal_2_0)/2.,_Digits);
      //--- 10) RES2.5 = (RES2.0 + RES3.0) / 2
      gResVal_2_5=NormalizeDouble((gResVal_2_0+gResVal_3_0)/2.,_Digits);
      //--- 11) SUP2.5 = (SUP2.0 + SUP3.0) / 2
      gSupVal_2_5=NormalizeDouble((gSupVal_2_0+gSupVal_3_0)/2.,_Digits);
      //--- бар начала текущего дня
      gDayStart=today;
      //--- найти стартовый бар активного ТФ
      //--- как тайм-серия
      for(int bar=0;bar<rates_total;bar++)
        {
         //--- время выбранного бара
         datetime curr_bar_time=time[bar];
         user_date.DateTime(curr_bar_time);
         //--- день выбранного бара
         datetime curr_bar_time_of_day=user_date.DateOfDay();
         //--- если текущий бар был днём ранее
         if(curr_bar_time_of_day<gDayStart)
           {
            //--- зафиксировать стартовый бар
            gBarStart=bar-1;
            break;
           }
        }
      //--- сбросить локальный счётчик
      prev_calc=0;
     }
//--- если новый бар на активном ТФ
   if(gNewMinute.isNewBar(time[0]))
     {
      //--- по какой бар считать 
      int bar_limit=gBarStart;
      //--- если не первый запуск
      if(prev_calc>0)
         bar_limit=rates_total-prev_calc;
      //--- обсчёт буферов 
      for(int bar=0;bar<=bar_limit;bar++)
        {
         //--- 1) пивот
         gBuffers[0].data[bar]=gPivotVal;
         //--- 2) RES0.5
         if(gToPlotBuffer[1])
            gBuffers[1].data[bar]=gResVal_0_5;
         //--- 3) SUP0.5
         if(gToPlotBuffer[2])
            gBuffers[2].data[bar]=gSupVal_0_5;
         //--- 4) RES1.0
         if(gToPlotBuffer[3])
            gBuffers[3].data[bar]=gResVal_1_0;
         //--- 5) SUP1.0
         if(gToPlotBuffer[4])
            gBuffers[4].data[bar]=gSupVal_1_0;
         //--- 6) RES1.5
         if(gToPlotBuffer[5])
            gBuffers[5].data[bar]=gResVal_1_5;
         //--- 7) SUP1.5
         if(gToPlotBuffer[6])
            gBuffers[6].data[bar]=gSupVal_1_5;
         //--- 8) RES2.0
         if(gToPlotBuffer[7])
            gBuffers[7].data[bar]=gResVal_2_0;
         //--- 9) SUP2.0
         if(gToPlotBuffer[8])
            gBuffers[8].data[bar]=gSupVal_2_0;
         //--- 10) RES2.5
         if(gToPlotBuffer[9])
            gBuffers[9].data[bar]=gResVal_2_5;
         //--- 11) SUP2.5
         if(gToPlotBuffer[10])
            gBuffers[10].data[bar]=gSupVal_2_5;
         //--- 12) RES3.0
         if(gToPlotBuffer[11])
            gBuffers[11].data[bar]=gResVal_3_0;
         //--- 13) SUP3.0
         if(gToPlotBuffer[12])
            gBuffers[12].data[bar]=gSupVal_3_0;
        }
     }
//---
   return rates_total;
  }
//+------------------------------------------------------------------+

//--- [EOF]
