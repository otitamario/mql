//+------------------------------------------------------------------+
//|                                            ZigZagOnParabolic.mq5 |
//|                                      Copyright © 2009, EarnForex |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
//---- авторство индикатора
#property copyright "Copyright © 2009, EarnForex"
//---- ссылка на сайт автора
#property link      "http://www.earnforex.com"
//---- номер версии индикатора
#property version   "1.01"
#property description "ZigZag on Parabolic"
//+----------------------------------------------+ 
//|  Параметры отрисовки индикатора              |
//+----------------------------------------------+ 
//---- отрисовка индикатора в главном окне
#property indicator_chart_window 
//---- для расчёта и отрисовки индикатора использовано 3 буфера
#property indicator_buffers 3
//---- использовано всего 1 графическое построение
#property indicator_plots   1

//---- в качестве индикатора использован ZIGZAG
#property indicator_type1   DRAW_COLOR_ZIGZAG
//---- отображение метки индикатора
#property indicator_label1  "ZigZag"
//---- в качестве цветов линии индикатора использованы
#property indicator_color1 clrDarkSalmon,clrDodgerBlue
//---- линия индикатора - длинный пунктир
#property indicator_style1  STYLE_DASH
//---- толщина линии индикатора равна 1
#property indicator_width1  1

//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
input double Step=0.02; //SAR шаг
input double Maximum=0.2; //SAR максимум
input bool ExtremumsShift=true; //флаг сдвига вершины
//+----------------------------------------------+

//---- объявление динамических массивов, которые будут в 
// дальнейшем использованы в качестве индикаторных буферов
double LowestBuffer[];
double HighestBuffer[];
double ColorBuffer[];

//---- Объявление целых переменных
int EShift;
//---- Объявление целых переменных начала отсчёта данных
int min_rates_total;
//---- Объявление целых переменных для хендлов индикаторов
int SAR_Handle;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Инициализация переменных начала отсчёта данных
   min_rates_total=1;

//---- Инициализация констант   
   if(ExtremumsShift) EShift=1;
   else               EShift=0;

//---- получение хендла индикатора SAR
   SAR_Handle=iSAR(NULL,0,Step,Maximum);
   if(SAR_Handle==INVALID_HANDLE)Print(" Не удалось получить хендл индикатора SAR");

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighestBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- создание меток для отображения в Окне данных
   PlotIndexSetString(0,PLOT_LABEL,"ZigZag Lowest");
   PlotIndexSetString(1,PLOT_LABEL,"ZigZag Highest");
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
   ArraySetAsSeries(ColorBuffer,true);
//---- установка позиции, с которой начинается отрисовка уровней Боллинджера
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- имя для окон данных и лэйба для субъокон 
   string shortname;
   StringConcatenate(shortname,"ZigZag on Parabolic(",
           double(Step), ", ", double(Maximum), ", ", bool(ExtremumsShift), ")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
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
//---- проверка количества баров на достаточность для расчёта
   if(BarsCalculated(SAR_Handle)<rates_total || rates_total<min_rates_total)return(0);

//---- объявления локальных переменных 
   static int j_,lastcolor_;
   static bool dir_;
   static double h_,l_;
   int j,limit,climit,to_copy,bar,shift,NewBar,lastcolor;
   double h,l,mid0,mid1,SAR[];
   bool dir;

//---- расчёт стартового номера limit для цикла пересчёта баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1-min_rates_total; // стартовый номер для расчёта всех баров

      h_=0.0;
      l_=999999999;
      dir_=false;
      j_=0;
      lastcolor_=0;
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }
     
   climit=limit; // стартовый номер для раскраски индикатора

   to_copy=limit+2;
   if(limit==0) NewBar=1;
   else         NewBar=0;

//---- индексация элементов в массивах как в таймсериях 
   ArraySetAsSeries(SAR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   
//---- копируем вновь появившиеся данные в массив
   if(CopyBuffer(SAR_Handle,0,0,to_copy,SAR)<=0) return(0);

//---- восстанавливаем значения переменных
   j=j_;
   dir=dir_;
   h=h_;
   l=l_;
   lastcolor=lastcolor_;

//---- Первый большой цикл расчёта индикатора
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- запоминаем значения переменных перед прогонами на текущем баре
      if(rates_total!=prev_calculated && bar==0)
        {
         j_=j;
         dir_=dir;
         h_=h;
         l_=l;
        }

      mid0=(high[bar]+low[bar])/2;
      mid1=(high[bar+1]+low[bar+1])/2;
      
      HighestBuffer[bar]=0.0;
      LowestBuffer[bar]=0.0;

      if(bar>0) j++;

      if(dir)
        {
         if(h<high[bar])
           {
            h=high[bar];
            j=NewBar;
           }
         if(SAR[bar+1]<=mid1 && SAR[bar]>mid0)
           {
            shift=bar+EShift *(j+NewBar);
            if(shift>rates_total-1) shift=rates_total-1;
            HighestBuffer[shift]=h;
            dir=false;
            l=low[bar];
            j=0;
            if(shift>climit) climit=shift;
           }
        }
      else
        {
         if(l>low[bar])
           {
            l=low[bar];
            j=NewBar;
           }
         if(SAR[bar+1]>=mid1 && SAR[bar]<mid0)
           {
            shift=bar+EShift *(j+NewBar);
            if(shift>rates_total-1) shift=rates_total-1;
            LowestBuffer[shift]=l;
            dir=true;
            h=high[bar];
            j=0;
            if(shift>climit) climit=shift;
           }
        }
     }

//---- Третий большой цикл раскраски индикатора
   for(bar=climit; bar>=0 && !IsStopped(); bar--)
     {
      if(rates_total!=prev_calculated && !bar) lastcolor_=lastcolor;

      if(!HighestBuffer[bar] || !LowestBuffer[bar]) ColorBuffer[bar]=lastcolor;

      if(HighestBuffer[bar] || LowestBuffer[bar])
        {
         if(lastcolor==0)
           {
            ColorBuffer[bar]=1;
            lastcolor=1;
           }
         else
           {
            ColorBuffer[bar]=0;
            lastcolor=0;
           }
        }

      if(!HighestBuffer[bar] || !LowestBuffer[bar])
        {
         ColorBuffer[bar]=1;
         lastcolor=1;
        }

      if(HighestBuffer[bar] || LowestBuffer[bar])
        {
         ColorBuffer[bar]=0;
         lastcolor=0;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
