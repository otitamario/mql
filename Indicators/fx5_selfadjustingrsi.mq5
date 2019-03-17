//+------------------------------------------------------------------+
//|                                         FX5_SelfAdjustingRSI.mq5 | 
//|                                            Copyright © 2008, FX5 | 
//|                                                    hazem@uk2.net | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2008, FX5"
#property link "hazem@uk2.net"
#property description ""
//---- номер версии индикатора
#property version   "1.00"
//---- отрисовка индикатора в отдельном окне
#property indicator_separate_window
//---- количество индикаторных буферов 4
#property indicator_buffers 4 
//---- использовано всего три графических построения
#property indicator_plots   3
//+-----------------------------------+
//| Параметры отрисовки индикатора    |
//+-----------------------------------+
//---- отрисовка индикатора в виде линии
#property indicator_type1   DRAW_LINE
//---- в качестве цвета линии индикатора использован DodgerBlue цвет
#property indicator_color1 clrDodgerBlue
//---- линия индикатора - сплошная кривая
#property indicator_style1  STYLE_SOLID
//---- толщина линии индикатора равна 2
#property indicator_width1  2
//---- отображение метки индикатора
#property indicator_label1  "RSI"
//+--------------------------------------------+
//| Параметры отрисовки индикатора BB уровней  |
//+--------------------------------------------+
//---- отрисовка уровней Боллинджера в виде линий
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- ввыбор цветов уровней Боллинджера
#property indicator_color2  clrMediumSeaGreen
#property indicator_color3  clrMagenta
//---- уровни Боллинджера - сплошные кривые
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- толщина уровней Боллинджера равна 2
#property indicator_width2  2
#property indicator_width3  2
//---- отображение меток уровней Боллинджера
#property indicator_label2  "OverBought"
#property indicator_label3  "OverSold"
//+----------------------------------------------+
//| Параметры отображения горизонтальных уровней |
//+----------------------------------------------+
#property indicator_level1 80.0
#property indicator_level2 50.0
#property indicator_level3 20.0
#property indicator_levelcolor clrBlueViolet
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//| Объявление констант               |
//+-----------------------------------+
#define RESET  0 // константа для возврата терминалу команды на пересчет индикатора
//+-----------------------------------+
//| Входные параметры индикатора      |
//+-----------------------------------+
input uint Length=12; // Период RSI
input ENUM_APPLIED_PRICE   RSIPrice=PRICE_CLOSE; // Цена таймсерии RSI
input double BandsDeviation=2.0; // Девиация
input bool MA_Method=true; // Использовать сглаживание для Боллинджера
input int Shift=0; // Сдвиг индикатора по горизонтали в барах
//+-----------------------------------+
//---- объявление динамических массивов, которые будут в 
//---- дальнейшем использованы в качестве индикаторных буферов
double ExtLineBuffer[],ExtLineBuffer1[],ExtLineBuffer2[],ExtCalcBuffer[];
//---- объявление целочисленных переменных начала отсчета данных
int min_rates_total,min_rates_;
//---- объявление целочисленных переменных для хендлов индикаторов
int RSI_Handle,STD_Handle;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- инициализация переменных начала отсчета данных
   min_rates_=int(Length);
   min_rates_total=int(min_rates_+2*Length);
//---- получение хендла индикатора iRSI
   RSI_Handle=iRSI(NULL,PERIOD_CURRENT,Length,RSIPrice);
   if(RSI_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iRSI");
//---- получение хендла индикатора iStdDev
   if(!MA_Method)
     {
      STD_Handle=iStdDev(NULL,PERIOD_CURRENT,Length,0,MODE_SMA,RSI_Handle);
      if(STD_Handle==INVALID_HANDLE) Print(" Не удалось получить хендл индикатора iStdDev");
     }
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- осуществление сдвига индикатора 1 по горизонтали
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- осуществление сдвига начала отсчета отрисовки индикатора
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- установка значений индикатора, которые не будут видимы на графике
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer,true);
//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
//---- установка позиции, с которой начинается отрисовка уровней Боллинджера
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буфере как в таймсерии
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
//---- превращение динамического массива в индикаторный буфер
   SetIndexBuffer(3,ExtCalcBuffer,INDICATOR_CALCULATIONS);
//---- инициализация переменной для короткого имени индикатора
   string shortname;
   StringConcatenate(shortname,"FX5_SelfAdjustingRSI(",Length,")");
//--- создание имени для отображения в отдельном подокне и во всплывающей подсказке
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- определение точности отображения значений индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- завершение инициализации
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // количество истории в барах на текущем тике
                const int prev_calculated,// количество истории в барах на предыдущем тике
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- проверка количества баров на достаточность для расчета
   if(BarsCalculated(RSI_Handle)<rates_total
      || (!MA_Method && BarsCalculated(STD_Handle)<rates_total)
      || rates_total<min_rates_total)
      return(RESET);
//---- объявления локальных переменных 
   int to_copy,limit,bar;
   double STD[];
//---- расчеты необходимого количества копируемых данных и стартового номера limit для цикла пересчета баров
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчета индикатора
     {
      limit=rates_total-min_rates_-1; // стартовый номер для расчета всех баров
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчета новых баров
     }
//----
   to_copy=limit+1;
//---- копируем вновь появившиеся данные в массивы
   if(CopyBuffer(RSI_Handle,0,0,to_copy,ExtLineBuffer)<=0) return(RESET);
   if(!MA_Method)if(CopyBuffer(STD_Handle,0,0,to_copy,STD)<=0) return(RESET);
//---- индексация элементов в массивах как в таймсериях  
   ArraySetAsSeries(STD,true);
//---- основной цикл расчета индикатора
   if(MA_Method==true)
     {
      for(bar=limit; bar>=0 && !IsStopped(); bar--)
        {
         double smoothedRSI=GetSmoothedRSI(bar);
         ExtCalcBuffer[bar]=MathAbs(ExtLineBuffer[bar]-smoothedRSI);
         double kDiviation=BandsDeviation*GetAbsDiviationAverage(bar);
         ExtLineBuffer1[bar]=50+kDiviation;
         ExtLineBuffer2[bar]=50-kDiviation;
        }
     }
   else
     {
      for(bar=limit; bar>=0 && !IsStopped(); bar--)
        {
         double kDiviation=BandsDeviation*STD[bar];
         ExtLineBuffer1[bar]=50+kDiviation;
         ExtLineBuffer2[bar]=50-kDiviation;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetSmoothedRSI(int shift)
  {
//----
   double sum=0;
   for(int iii=int(shift+Length-1); iii>=shift; iii--) sum+=ExtLineBuffer[iii];
//----
   return(sum/Length);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetAbsDiviationAverage(int shift)
  {
//----
   double sum=0;
   for(int iii=int(shift+Length-1); iii>=shift; iii--) sum+=ExtCalcBuffer[iii];
//----
   return(sum/Length);
  }
//+------------------------------------------------------------------+
