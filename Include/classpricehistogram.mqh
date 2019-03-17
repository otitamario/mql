//+------------------------------------------------------------------+
//|                                         ClassPriceHistogramA.mqh |
//|                                      Copyright vdv_2001 Software |
//|                                                 vdv_2001@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Dmitry Voronkov"
#property link      "vdv_2001@mail.ru"

#include <Object.mqh>
#include <Arrays\List.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>

// Количество попыток запроса данных / Amount of attempts of inquiry of the data
const int         AMOUNT_OF_ATTEMPTS=10;
//+------------------------------------------------------------------+
//|   Класс CPriceHistogram                                          |
//|   Описание класса                                                |
//+------------------------------------------------------------------+
class CPriceHistogram : public CObject
  {
private:
   // Переменные класса / Class variables
   double            high_day,low_day;
   bool              Init_passed;      // Флаг, инициализация пройдена / Flag, initialization it is passed
   CChartObjectTrend *POCLine;
   CChartObjectTrend *SecondTopPOCLine,*SecondBottomPOCLine;
   CChartObjectText  *POCLable;
   CList             ListHistogramInner;// для хранения линий гистограммы Inner / for storage of lines of the histogram Inner
   CList             ListHistogramOuter;// для хранения линий гистограммы Outer / for storage of lines of the histogram Outer
   bool              show_level;       // показать значения уровня / to show values of level
   bool              virgin;           // это девственный уровень / it is virgin level
   bool              show_second_poc;  // показывать вторичные уровни POCs / to show secondary levels POCs
   double            second_poc_top;   // значение верхнего уровня вторичной POCs / value of top level secondary POCs
   double            second_poc_bottom;// значение нижнего уровня вторичной POCs / value of the bottom level secondary POCs
   double            poc_value;        // значение уровня POCs / value of level POCs
   color             poc_color;        // цвет уровня POCs / сolour of level POCs
   datetime          poc_start_time;
   datetime          poc_end_time;
   bool              show_histogram;   // показывать гистограмму  /  to show the histogram
   color             inner_color;      // внутренний цвет гистограммы / inner colour of the histogram
   color             outer_color;      // внешний цвет гистограммы / outer colour of the histogram
   uint              range_percent;    // процент диапазона / range percent
   datetime          time_start;       // время для начала построения / time to start construction
   datetime          time_end;         // время завершения построения / time of end of construction
public:
   // Конструктор класса / Class constructor
                     CPriceHistogram();
   // Диструктор класса / Class destructor
                    ~CPriceHistogram(){Delete();}
   // Инициализация класса / Class initialization
   bool              Init(datetime time_open,datetime time_close,bool showhistogram);
   // Показать значение уровня / To show value of level
   void              ShowLevel(bool show){show_level=show; if(Init_passed) RefreshPOCs();}
   bool              ShowLevel(){return(show_level);}
   // Показать гистограмму / To show the histogram
   void              ShowHistogram(bool show);
   bool              ShowHistogram(){return(show_histogram);}
   // Показать Вторичные уровни POCs / To show Secondary levels POCs
   void              ShowSecondaryPOCs(bool show){show_second_poc=show;if(Init_passed)RefreshPOCs();}
   bool              ShowSecondaryPOCs(){return(show_second_poc);}
   // Установить цвет уровней POCs / To establish colour of levels POCs
   void              ColorPOCs(color col){poc_color=col; if(Init_passed)RefreshPOCs();}
   color             ColorPOCs(){return(poc_color);}
   // Установить внутренний цвет гистограммы / To establish internal colour of the histogram
   void              ColorInner(color col);
   color             ColorInner(){return(inner_color);}
   // Установить внешний цвет гистограммы / To establish outer colour of the histogram
   void              ColorOuter(color col);
   color             ColorOuter(){return(outer_color);}
   // Установить процент диапазона / To establish range percent
   void              RangePercent(uint percent){range_percent=percent; if(Init_passed)calculationPOCs();}
   uint              RangePercent(){return(range_percent);}
   // Возвращает значение девственности уровня POCs / Returns value of virginity of level POCs
   bool              VirginPOCs(){return(virgin);}
   // Возвращает стартовое время построения гистограммы / Returns starting time of construction of the histogram
   datetime          GetStartDateTime(){return(time_start);}
   // Обновление уровней POCs / Updating of levels POCs
   bool              RefreshPOCs();
private:
   // Расчеты гистограммы и уровней POCs / Calculations of the histogram and levels POCs
   bool              calculationPOCs();
   // Удаление класса / Class removal
   void              Delete();
  };
//+------------------------------------------------------------------+
//|   Конструктор класса / Class constructor                         |
//+------------------------------------------------------------------+
CPriceHistogram::CPriceHistogram()
  {
   Init_passed=false;
   POCLine=NULL;
   SecondTopPOCLine=NULL;
   SecondBottomPOCLine=NULL;
   POCLable=NULL;
   show_level=true;
   show_second_poc=false;
   show_histogram=false;
   virgin=false;
   poc_color=Orange;
   inner_color=Indigo;
   outer_color=Magenta;
   range_percent=70;
  }
//+------------------------------------------------------------------+
//|   Инициализация класса / Class initialization                    |
//+------------------------------------------------------------------+
bool CPriceHistogram::Init(datetime time_open,datetime time_close,bool showhistogram)
  {
   time_start=time_open;
   time_end=time_close;
   show_histogram=showhistogram;
   calculationPOCs();
   RefreshPOCs();
   Init_passed=true;
   return(true);
  }
//+------------------------------------------------------------------+
//|   Показать гистограмму / To show the histogram                   |
//+------------------------------------------------------------------+
void CPriceHistogram::ShowHistogram(bool show)
  {
   if(show_histogram==show) return;
   show_histogram=show;
   if(show_histogram)
      calculationPOCs();
   else
     {
      ListHistogramInner.Clear();
      ListHistogramOuter.Clear();
     }
  }
//+------------------------------------------------------------------------------------------+
//|   Установить внутренний цвет гистограммы / To establish internal colour of the histogram |
//+------------------------------------------------------------------------------------------+
void CPriceHistogram::ColorInner(color col)
  {
   inner_color=col;
   if(Init_passed)
     {
      if(!show_histogram) return;
      for(int i=0;i<ListHistogramInner.Total();i++)
        {
         CChartObjectTrend *obj=ListHistogramInner.GetNodeAtIndex(i);
         obj.Color(inner_color);
        }
     }
  }
//+------------------------------------------------------------------------------------+
//|   Установить внешний цвет гистограммы / To establish outer colour of the histogram |
//+------------------------------------------------------------------------------------+
void CPriceHistogram::ColorOuter(color col)
  {
   outer_color=col;
   if(Init_passed)
     {
      if(!show_histogram) return;
      for(int i=0;i<ListHistogramOuter.Total();i++)
        {
         CChartObjectTrend *obj=ListHistogramOuter.GetNodeAtIndex(i);
         obj.Color(outer_color);
        }
     }
  }
//+---------------------------------------------------------------------------------------+
//|   Расчеты гистограммы и уровней POCs / Calculations of the histogram and levels POCs  |
//+---------------------------------------------------------------------------------------+
bool CPriceHistogram::calculationPOCs()
  {
   int rates_total,rates_high,rates_time,index;
   double iHigh[],iLow[];
   datetime iTime[];
// Получаем данные за период с time_start до time_end / We obtain the data from time_start to time_end
   int err=0;
   do
     {
      rates_time=CopyTime(NULL,PERIOD_M1,time_start,time_end,iTime);
      rates_high=CopyHigh(NULL,PERIOD_M1,time_start,time_end,iHigh);
      rates_total=CopyLow(NULL,PERIOD_M1,time_start,time_end,iLow);
      err++;
     }
   while((rates_time<=0 || (rates_total!=rates_high && rates_total!=rates_time)) && err<AMOUNT_OF_ATTEMPTS);
   if(err>=AMOUNT_OF_ATTEMPTS)
     {
      return(false);
     }
   poc_start_time=iTime[0];
   high_day=iHigh[ArrayMaximum(iHigh,0,rates_total)];
   low_day=iLow[ArrayMinimum(iLow,0,rates_total)];
   int count=int((high_day-low_day)/_Point)+1;
// Подсчет длительности нахождения цены на каждом уровне / Count of duration of a finding of the price at each level
   int ThicknessOfLevel[];    // создаем массив для подсчета тиков / we create an array for count of tics
   ArrayResize(ThicknessOfLevel,count);
   ArrayInitialize(ThicknessOfLevel,0);
   for(int i=0;i<rates_total;i++)
     {
      double C=iLow[i];
      while(C<iHigh[i])
        {
         int Index=int((C-low_day)/_Point);
         ThicknessOfLevel[Index]++;
         C+=_Point;
        }
     }
   int MaxLevel=ArrayMaximum(ThicknessOfLevel,0,count);
   poc_value=low_day+_Point*MaxLevel;
// Находим вторичные POCs / We find secondary POCs
   int range_min=int(ThicknessOfLevel[MaxLevel]-ThicknessOfLevel[MaxLevel]*range_percent/100);
   int DownLine=0;
   int UpLine=0;
   for(int i=0;i<count;i++)
     {
      if(ThicknessOfLevel[i]>=range_min)
        {
         DownLine=i;
         break;
        }
     }
   for(int i=count-1;i>0;i--)
     {
      if(ThicknessOfLevel[i]>=range_min)
        {
         UpLine=i;
         break;
        }
     }
   if(DownLine==0)
      DownLine=MaxLevel;
   if(UpLine==0)
      UpLine=MaxLevel;
   second_poc_top=low_day+_Point*UpLine;
   second_poc_bottom=low_day+_Point*DownLine;
// Формирование гистограммы / Histogram formation 
   if(show_histogram)
     {
      datetime Delta=(iTime[rates_total-1]-iTime[0]-PeriodSeconds(PERIOD_H1))/ThicknessOfLevel[MaxLevel];
      int step=1;
      
      if(count>100)
         step=count/100;   // Задаем шаг гистограммы максимум 100 линий / We set a step of the histogram a maximum of 100 lines

      ListHistogramInner.Clear();
      ListHistogramOuter.Clear();
      for(int i=0;i<count;i+=step)
        {
         string name=TimeToString(time_start)+" "+IntegerToString(i);
         double StartY= low_day+_Point*i;
         datetime EndX= iTime[0]+(ThicknessOfLevel[i])*Delta;

         CChartObjectTrend *obj=new CChartObjectTrend();
         obj.Create(0,name,0,poc_start_time,StartY,EndX,StartY);
         obj.Background(true);
         if(i>=DownLine && i<=UpLine)
           {
            obj.Color(inner_color);
            ListHistogramInner.Add(obj);
           }
         else
           {
            obj.Color(outer_color);
            ListHistogramOuter.Add(obj);
           }
        }
     }
// Проверяем является данный уровень девственным POC или нет
// We check the given level is virgin POC or not
   MqlTick last_tick; // Структура для хранения последних цен по символу / Structure for storage of final prices on a symbol
   SymbolInfoTick(Symbol(),last_tick); // Получаем текущие цены / We receive current prices
   // Если время текущего тика равно 0, устанавливаем время сервера
   // If time of a current tic equally 0, we establish server time
   if(last_tick.time==0)
      last_tick.time=TimeTradeServer(); 


// Получаем массивы данных начиная конечного времени гистограммы и до текущего времени
// We receive data files beginning final time of the histogram and till current time
   err=0;
   do
     {
      rates_time=CopyTime(NULL,PERIOD_M1,time_end,last_tick.time,iTime);
      rates_high=CopyHigh(NULL,PERIOD_M1,time_end,last_tick.time,iHigh);
      rates_total=CopyLow(NULL,PERIOD_M1,time_end,last_tick.time,iLow);
      err++;
     }
   while((rates_time<=0 || (rates_total!=rates_high && rates_total!=rates_time)) && err<AMOUNT_OF_ATTEMPTS);
// Если истории нет, текущий день, уровень является девственным, поднимаем флаг
// If the history are not present, the present day, level is virgin, we hoist the colours
   if(rates_time==0)
     {
      virgin=true;
     }
   else
// Иначе проверяем историю / Otherwise we check history
     {
      for(index=0;index<rates_total;index++)
         if(poc_value<iHigh[index] && poc_value>iLow[index]) break;

      if(index<rates_total)   // если уровень пересечен ценой / If level is crossed by
         poc_end_time=iTime[index];
      else
         virgin=true;
     }
   if(POCLine==NULL)
     {     
      POCLine=new CChartObjectTrend();
      POCLine.Create(0,TimeToString(time_start)+" POC ",0,poc_start_time,poc_value,0,0);
     }
   POCLine.Color(poc_color);
   RefreshPOCs();
   return(true);
  }
//+------------------------------------------------------------------+
//|   Обновление уровней POCs / Updating of levels POCs              |
//+------------------------------------------------------------------+
bool CPriceHistogram::RefreshPOCs()
  {
   if(POCLine==NULL) return(false);
   if(virgin)
     {
      MqlTick last_tick;
      if(SymbolInfoTick(Symbol(),last_tick))
         poc_end_time=last_tick.time;
      if(poc_end_time==0)
         poc_end_time=TimeTradeServer();;
      POCLine.SetPoint(1,poc_end_time,poc_value);
      if(show_level)
        {
         if(POCLable==NULL)
           {
            POCLable=new CChartObjectText();
            POCLable.Create(0,POCLine.Name()+"L",0,0,0);
            POCLable.Anchor(ANCHOR_LEFT);
            POCLable.FontSize(7);
            POCLable.Font("Tahoma");
            POCLable.Color(poc_color);
           }
         POCLable.Description(DoubleToString(poc_value,_Digits));
         POCLable.SetPoint(0,poc_end_time+PeriodSeconds(PERIOD_CURRENT),poc_value);
        }
      else
         if(POCLable!=NULL) delete POCLable;
     }
   else
      POCLine.SetPoint(1,poc_end_time,poc_value);
// Вывод на экран Вспомогательных уровней POCs / Output on the screen of Auxiliary levels POCs
   if(show_second_poc)
     {
      if(SecondTopPOCLine==NULL)
        {
         SecondTopPOCLine=new CChartObjectTrend();
         SecondTopPOCLine.Create(0,TimeToString(time_start)+" SecondTopPOC ",0,poc_start_time, second_poc_top,0,0);
         SecondTopPOCLine.Color(poc_color);
         SecondTopPOCLine.Style(STYLE_DOT);
        }
      SecondTopPOCLine.SetPoint(1,poc_end_time,second_poc_top);
      if(SecondBottomPOCLine==NULL)
        {
         SecondBottomPOCLine=new CChartObjectTrend();
         SecondBottomPOCLine.Create(0,TimeToString(time_start)+" SecondBottomPOC ",0,poc_start_time, second_poc_bottom,0,0);
         SecondBottomPOCLine.Color(poc_color);
         SecondBottomPOCLine.Style(STYLE_DOT);
        }
      SecondBottomPOCLine.SetPoint(1,poc_end_time,second_poc_bottom);
     }
   else
     {
      if(SecondTopPOCLine!=NULL) {delete SecondTopPOCLine; SecondTopPOCLine=NULL;};
      if(SecondBottomPOCLine!=NULL) {delete SecondBottomPOCLine;SecondBottomPOCLine=NULL;}
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|   Удаление класса / Class removal                                |
//+------------------------------------------------------------------+
CPriceHistogram::Delete()
  {
   if(POCLine!=NULL) delete POCLine;
   if(POCLable!=NULL) delete POCLable;
   if(SecondTopPOCLine!=NULL) delete SecondTopPOCLine;
   if(SecondBottomPOCLine!=NULL) delete SecondBottomPOCLine;
  }
//+------------------------------------------------------------------+
