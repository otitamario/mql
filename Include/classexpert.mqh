//+------------------------------------------------------------------+
//|                                                  ClassExpert.mqh |
//|                                      Copyright vdv_2001 Software |
//|                                                 vdv_2001@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Dmitry Voronkov"
#property link      "vdv_2001@mail.ru"

#include <Arrays\List.mqh>
#include <ClassPriceHistogram.mqh>
#include <ClassProgressBar.mqh>
//+------------------------------------------------------------------+
//|   Class CExpert                                                  |
//|   Description                                                    |
//+------------------------------------------------------------------+
class CExpert
  {
public:
   int               DaysForCalculation; // Days for calculation(-1 all)
   int               DayTheHistogram;    // Days for histogram
   int               RangePercent;       // Percent range
   color             InnerRange;         // Inner range color
   color             OuterRange;         // Outer range color
   color             ControlPoint;       // Point of Control color
   bool              ShowValue;          // Show Values
                                         // Private class variables
private:
   CList             list_object;        // The dynamic list of CObject class copies  
   string            name_symbol;        // Symbol name
   int               count_bars;         // Number of daily bars
   bool              event_on;           // Flag of events processing

public:
   // Class constructor
                     CExpert();
   // Class destructor
                    ~CExpert(){Deinit(REASON_CHARTCLOSE);}
   // Initialization method
   bool              Init();
   // Deinitialization method
   void              Deinit(const int reason);
   // Tick processing method
   void              OnTick();
   // OnChartEvent() event processing method
   void              OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   // OnTimer() event processing method
   void              OnTimer();
  };
//+------------------------------------------------------------------+
//|   Class constructor                                              |
//+------------------------------------------------------------------+
CExpert::CExpert()
  {
   name_symbol=NULL;
   count_bars=0;
   RangePercent=70;
   InnerRange=Indigo;
   OuterRange=Magenta;
   ControlPoint=Orange;
   ShowValue=true;
   DaysForCalculation=100;
   DayTheHistogram=10;
   event_on=false;
  }
//+------------------------------------------------------------------+
//|   Initialization method                                          |
//+------------------------------------------------------------------+
bool CExpert::Init()
  {
   int   rates_total,count;
   datetime day_time_open[];

// Check for the symbol changes
   if(name_symbol==NULL || name_symbol!=Symbol())
     {
      list_object.Clear();
      event_on=false;   // Disable event processing flag
      Sleep(100);
      name_symbol=Symbol();
      // Get opening time for the daily bars
      int err=0;
      do
        {        
         // Calculation of days available in history
         count_bars=Bars(NULL,PERIOD_D1);
         if(DaysForCalculation+1<count_bars)
            count=DaysForCalculation+1;
         else
            count=count_bars;
         if(DaysForCalculation<=0) count=count_bars;
         rates_total=CopyTime(NULL,PERIOD_D1,0,count,day_time_open);
         Sleep(1);
         err++;
        }
      while(rates_total<=0 && err<AMOUNT_OF_ATTEMPTS);
      if(err>=AMOUNT_OF_ATTEMPTS)
        {
         Print("There is no accessible history PERIOD_D1");
         name_symbol=NULL;
         return(false);
        }

      // We check 0 day is current or not (for shares and Friday)
      if(day_time_open[rates_total-1]+PeriodSeconds(PERIOD_D1)>=TimeTradeServer())
         rates_total--;

      // Creating object for the output of the loading process
      CProgressBar   *progress=new CProgressBar;
      progress.Create(0,"Loading",0,150,20);
      progress.Text("Calculation:");
      progress.Maximum=rates_total;
      // In this cycle there is a CPriceHistogram object creation its initialization and adding into the list of objects
      for(int i=0;i<rates_total;i++)
        {
         CPriceHistogram  *hist_obj=new CPriceHistogram();
         //         hist_obj.StepHistigram(step);
         // Setting flag to show text labels
         hist_obj.ShowLevel(ShowValue);
         // Setting color for POCs
         hist_obj.ColorPOCs(ControlPoint);
         // Setting colour for the inner range
         hist_obj.ColorInner(InnerRange);
         // Setting colour for the outer range
         hist_obj.ColorOuter(OuterRange);
         // Setting range percent
         hist_obj.RangePercent(RangePercent);
         //         hist_obj.ShowSecondaryPOCs((i>=rates_total-DayTheHistogram),PeriodSeconds(PERIOD_D1));
         if(hist_obj.Init(day_time_open[i],day_time_open[i]+PeriodSeconds(PERIOD_D1),(i>=rates_total-DayTheHistogram)))
            list_object.Add(hist_obj);
         else
            delete hist_obj; // We delete it if there was an error
         progress.Value(i);
        }
      delete progress;
      ChartRedraw(0);
      event_on=true;    // Enable events flag
     }
   else
      OnTick();
//---
   return(true);
  }
//+------------------------------------------------------------------+
//|   OnTick() processing method                                     |
//+------------------------------------------------------------------+
void CExpert::OnTick(void)
  {
   int count;
// Check for presence of the new day
   if(count_bars!=Bars(NULL,PERIOD_D1))
     {
      name_symbol=NULL;
      Init();
     }
   else
     {
      count=list_object.Total();
      for(int i=0;i<count;i++)
        {
         CPriceHistogram  *hist_obj=list_object.GetNodeAtIndex(i);
         if(hist_obj.VirginPOCs())
            hist_obj.RefreshPOCs();
        }
     }
   return;
  }
//+------------------------------------------------------------------+
//|   ����� ��������������� / Deinitialization method                |
//+------------------------------------------------------------------+
void CExpert::Deinit(const int reason)
  {
   switch(reason)
     {
      case REASON_PARAMETERS: //Input parameters has been changed by user
         name_symbol=NULL;
         break;
      case REASON_ACCOUNT:    //Account has changed
      case REASON_CHARTCLOSE: //Chart was closed
      case REASON_INITFAILED: //OnInit() returned nonzero value
      case REASON_RECOMPILE:  //Program has been recompiled
      case REASON_REMOVE:     //Expert has been removed from the chart
      case REASON_TEMPLATE:   //New template has been applied
      case REASON_CHARTCHANGE://Symbol or timeframe has been changed
         break;
     }
   return;
  }
//+------------------------------------------------------------------------------------------+
//|   OnChartEvent() processing method                                                       |
//+------------------------------------------------------------------------------------------+
void CExpert::OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam)
  {
   if(event_on)   
     {            // If there is no class initialization now
      switch(id)
        {
         case CHARTEVENT_KEYDOWN:
            // Keyboard press event when chart is in focus
            break;
         case CHARTEVENT_OBJECT_CLICK:
            // Mouse click event on the graphic object on the chart
            if(list_object.Total()!=0)
              {
               datetime serch=StringToTime(sparam);
               int count=list_object.Total();
               for(int i=0;i<count;i++)
                 {
                  CPriceHistogram  *hist_obj=list_object.GetNodeAtIndex(i);
                  if(hist_obj.GetStartDateTime()==serch)
                    {
                     hist_obj.ShowSecondaryPOCs(!hist_obj.ShowSecondaryPOCs());
                     color col=hist_obj.ColorInner();
                     hist_obj.ColorInner(hist_obj.ColorOuter());
                     hist_obj.ColorOuter(col);
                     ChartRedraw(0);
                     break;
                    }
                 }
              }
            break;
         case CHARTEVENT_OBJECT_DRAG:
            // Event of graphic object moving using the mouse
            break;
         case CHARTEVENT_OBJECT_ENDEDIT:
            // Event of the text editing end in the input field of the LabelEdit graphic object 
            break;
         default:
            // if something new :)
            break;
        }
     }
  }
//+---------------------------------------------------------------------------------+
//|   OnTimer() processing method                                                   |
//+---------------------------------------------------------------------------------+
void CExpert::OnTimer(void)
  {
   if(event_on)
     {
      // Before use it is necessary to add to the class constuctor the following line:
      // EventSetTimer(time in seconds); and in a destructor a line: EventKillTimer();
     }
  }
//+------------------------------------------------------------------+
