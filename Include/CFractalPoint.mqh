//+------------------------------------------------------------------+
//|                                                CFractalPoint.mqh |
//|                                           Copyright 2016, denkir |
//|                           https://login.mql5.com/en/users/denkir |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, denkir"
#property link      "https://login.mql5.com/en/users/denkir"
//--- include
#include <Arrays\ArrayDouble.mqh>
#include <Arrays\ArrayInt.mqh>
#include <ChartObjects\ChartObjectsChannels.mqh>
#include <Arrays\ArrayObj.mqh>
#include <User\CisNewBar.mqh>
//+------------------------------------------------------------------+
//| Extremum type                                                    |
//+------------------------------------------------------------------+
enum ENUM_EXTREMUM_TYPE
  {
   EXTREMUM_TYPE_MIN=0, // minimum
   EXTREMUM_TYPE_MAX=1, // maximum
  };
//+------------------------------------------------------------------+
//| Type of extremum points' set                                     |
//+------------------------------------------------------------------+
enum ENUM_SET_TYPE
  {
   SET_TYPE_NONE=0,     // not set
   SET_TYPE_MINMAX=1,   // min-max-min
   SET_TYPE_MAXMIN=2,   // max-min-max                       
  };
//+------------------------------------------------------------------+
//| Type of relevant point                                           |
//+------------------------------------------------------------------+
enum ENUM_RELEVANT_EXTREMUM
  {
   RELEVANT_EXTREMUM_PREV=0, // previous
   RELEVANT_EXTREMUM_LAST=1, // last
  };
//+------------------------------------------------------------------+
//| Base data of the fractal                                         |
//+------------------------------------------------------------------+
struct SFracData
  {
   double            value; // value
   int               index; // bar index
   datetime          time;  // bar time
   //--- constructor
   void SFracData::SFracData(void)
     {
      value=EMPTY_VALUE;
      index=WRONG_VALUE;
      time=WRONG_VALUE;
     }
  };
//+------------------------------------------------------------------+
//| Class of a fractal point                                         |
//+------------------------------------------------------------------+
class CFractalPoint : public CObject
  {
   //--- === Data members === --- 
private:
   datetime          m_date;           // date and time
   double            m_value;          // value
   ENUM_EXTREMUM_TYPE m_extreme_type;  // extremum type
   int               m_idx;            // index (from 0 to 2)
   //---
   CisNewBar         m_new_bar;            // new bar's object

   //--- === Methods === --- 
public:
   //--- Constructor/destructor
   void              CFractalPoint(void);
   void              CFractalPoint(datetime _date,double _value,
                                   ENUM_EXTREMUM_TYPE _extreme_type,int _idx);
   void             ~CFractalPoint(void){};
   //--- get-methods
   datetime          Date(void) const {return m_date;};
   double            Value(void) const {return m_value;};
   ENUM_EXTREMUM_TYPE FractalType(void) const {return m_extreme_type;};
   int               Index(void) const {return m_idx;};
   //--- set-methods
   void              Date(const datetime _date) {m_date=_date;};
   void              Value(const double _value) {m_value=_value;};
   void              FractalType(const ENUM_EXTREMUM_TYPE extreme_type) {m_extreme_type=extreme_type;};
   void              Index(const int _bar_idx){m_idx=_bar_idx;};
   //--- service
   void              Copy(const CFractalPoint &_source_frac);
   void              Print(void);
  };
//+------------------------------------------------------------------+
//| Default constructor                                              |
//+------------------------------------------------------------------+
void CFractalPoint::CFractalPoint(void)
  {
   m_date=0;
   m_value=0.;
   m_extreme_type=-1;
   m_idx=WRONG_VALUE;
  };
//+------------------------------------------------------------------+
//| Constructor with the initialization list                         |
//+------------------------------------------------------------------+
void CFractalPoint::CFractalPoint(datetime _date,double _value,
                                  ENUM_EXTREMUM_TYPE _extreme_type,int _idx):
                                  m_date(_date),
                                  m_value(_value),
                                  m_extreme_type(_extreme_type),
                                  m_idx(_idx){};
//+------------------------------------------------------------------+
//| Copying                                                          |
//+------------------------------------------------------------------+
void CFractalPoint::Copy(const CFractalPoint &_source_frac)
  {
   m_date=_source_frac.m_date;
   m_value=_source_frac.m_value;
   m_extreme_type=_source_frac.m_extreme_type;
   m_idx=_source_frac.m_idx;
  };
//+------------------------------------------------------------------+
//| Printing                                                         |
//+------------------------------------------------------------------+
void CFractalPoint::Print(void)
  {
   Print("\n---=== Data of a fractal point ===---");
   Print("Date: ",TimeToString(m_date));
   Print("Price: ",DoubleToString(m_value,_Digits));
   Print("Type: ",EnumToString(m_extreme_type));
   Print("Index: ",IntegerToString(m_idx));
  }
//+------------------------------------------------------------------+
//| Class of fractal points' set                                     |
//+------------------------------------------------------------------+
class CFractalSet : protected CArrayObj
  {
   //--- === Data members === --- 
private:
   ENUM_SET_TYPE     m_set_type;           // type of points' set
   int               m_fractal_num;        // fixed number of points
   int               m_fractals_ha;        // handle of a fractal indicator 
   CisNewBar         m_new_bar;            // new bar's object
   bool              m_is_init;            // initialization flag
   //--- channel settings of
   int               m_prev_frac_num;      // previous fractals
   int               m_bars_beside;        // bars on the left/right of fractal
   int               m_bars_between;       // number of intermediate bars  
   ENUM_RELEVANT_EXTREMUM m_rel_frac;      // relevant point
   int               m_line_wid;           // line width
   bool              m_to_log;             // keep the log?
   //---
   datetime          m_last_frac_date;     // date/time of the last fractal in the set
   //--- === Methods === --- 
public:
   //--- Constructor/destructor
   void              CFractalSet(void);
   void              CFractalSet(const CFractalSet &_src_frac_set);
   void             ~CFractalSet(void){};
   //---
   void              operator=(const CFractalSet &_src_frac_set);
   //--- handlers
   bool              Init(
                          int _prev_frac_num,
                          int _bars_beside,
                          int _bars_between=0,
                          ENUM_RELEVANT_EXTREMUM _rel_frac=RELEVANT_EXTREMUM_PREV,
                          int _line_wid=3,
                          bool _to_log=true
                          );
   void              Calculate(
                               const double &_up_frac_buffer[],
                               const double &_down_frac_buffer[],
                               const datetime &_time_arr[],
                               double &_up_buffer[],
                               double &_down_buffer[],
                               double &_new_ch_buffer[]
                               );
   //--- service
   bool              IsInit(void) const {return m_is_init;};
   ENUM_SET_TYPE     GetTypeOfSet(void) const {return m_set_type;};
   //---
private:
   int               CheckSet(const SFracData &_fractals[]);
   void              SetTypeOfSet(const ENUM_SET_TYPE _set_type) {m_set_type=_set_type;};
   bool              Crop(const uint _num_to_crop);
   void              BubbleSort(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
void CFractalSet::CFractalSet(void)
  {
   m_set_type=WRONG_VALUE;
   m_fractal_num=3;
   m_prev_frac_num=m_bars_beside=m_bars_between=m_line_wid=0;
   m_rel_frac=WRONG_VALUE;
   m_is_init=false;
   m_to_log=false;
   m_last_frac_date=0;
  };
//+------------------------------------------------------------------+
//| Initialization                                                   |
//+------------------------------------------------------------------+
bool CFractalSet::Init(
                       int _prev_frac_num,
                       int _bars_beside,
                       int _bars_between=0,
                       ENUM_RELEVANT_EXTREMUM _rel_frac=RELEVANT_EXTREMUM_PREV,
                       int _line_wid=3,
                       bool _to_log=true
                       )
  {

//--- check the number of the previous fractal points
   if((_prev_frac_num<0) || (_prev_frac_num>3))
     {
      Print("Wrong number of the previous fractal points!");
      return false;
     }
//--- check the number of bars beside the fractal
   if(_bars_beside<1)
     {
      Print("Wrong number of bars beside the fractal!");
      return false;
     }

//--- memory management
   if(!this.FreeMode())
      this.FreeMode(true);
//--- data members
   m_prev_frac_num=_prev_frac_num;
   m_bars_between=_bars_between;
   m_rel_frac=_rel_frac;
   m_line_wid=_line_wid;
   m_bars_beside=_bars_beside;
   m_to_log=_to_log;
   if(m_to_log)
     {
      Print("Enabled logging for indicator \"EquidistantChannels\".");
     }
//--- when started on a chart, consider the bar new
   m_new_bar.SetLastBarTime(1);
   m_is_init=true;
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Processing in indicator                                          |
//+------------------------------------------------------------------+
void CFractalSet::Calculate(
                            const double &_up_frac_buffer[],
                            const double &_down_frac_buffer[],
                            const datetime &_time_arr[],
                            double &_up_buffer[],
                            double &_down_buffer[],
                            double &_new_ch_buffer[]
                            )
  {
//--- as time-series
   ArraySetAsSeries(_up_frac_buffer,true);
   ArraySetAsSeries(_down_frac_buffer,true);
   ArraySetAsSeries(_time_arr,true);
   ArraySetAsSeries(_up_buffer,true);
   ArraySetAsSeries(_down_buffer,true);
   ArraySetAsSeries(_new_ch_buffer,true);
//--- If it's a new bar
   if(m_new_bar.isNewBar(_time_arr[0]))
     {
      int frac_num=this.Total();
      //--- if previous fractal points are not to be added
      if(m_prev_frac_num==0)
         if(m_last_frac_date==0)
           {
            m_last_frac_date=_time_arr[0];
            return;
           }
      //--- call during initialization?
      bool is_history_add=false;
      if(m_prev_frac_num>0)
         if(!this.IsSorted(1))
            is_history_add=true;
      //--- find points
      for(int bar=0;bar<ArraySize(_up_frac_buffer);bar++)
        {
         SFracData fracs[2]; //  array of fractal data: [0]-lower, [1]-upper               
         double curr_up_val,curr_down_val;
         curr_up_val=_up_frac_buffer[bar];
         curr_down_val=_down_frac_buffer[bar];
         datetime curr_bar_time=_time_arr[bar];
         bool is_new_down=false,is_new_up=false;
         //--- check for presence of a lower fractal
         if((curr_down_val<DBL_MAX) && (curr_down_val>0.))
           {
            is_new_down=true;
            fracs[0].index=bar;
            fracs[0].time=curr_bar_time;
           }
         if((curr_up_val<DBL_MAX) && (curr_up_val>0.))
           {
            is_new_up=true;
            fracs[1].index=bar;
            fracs[1].time=curr_bar_time;
           }
         //--- If there is a new fractal
         if(is_new_down || is_new_up)
           {
            bool to_add=false;
            //--- total in set
            frac_num=this.Total();
            //--- Conditions for adding fractal points:            
            //--- 1) if added during initialization
            if(is_history_add)
              {
               //--- if added ones are not enough
               if(frac_num<m_prev_frac_num)
                  //--- if the current bar is taken deeper
                  if((curr_bar_time<m_last_frac_date) || (m_last_frac_date==0))
                    {
                     if(m_last_frac_date==0)
                        m_last_frac_date=curr_bar_time;
                     to_add=true;
                    }
              }
            //--- 2) if added during the process
            else
              {
               //--- if the occurrence time of the new fractal is older than the time of the last 
               if(curr_bar_time>m_last_frac_date)
                 {
                  m_last_frac_date=curr_bar_time;
                  to_add=true;
                 }
              }
            //--- if added
            if(to_add)
              {
               if(m_to_log)
                 {
                  if(is_new_down)
                    {
                     Print("\n---== Lower fractal ==---");
                     PrintFormat("Price: %."+IntegerToString(_Digits)+"f",curr_down_val);
                    }
                  if(is_new_up)
                    {
                     Print("\n---== Upper fractal ==---");
                     PrintFormat("Price: %."+IntegerToString(_Digits)+"f",curr_up_val);
                    }
                  PrintFormat("Time: %s",TimeToString(curr_bar_time));
                  PrintFormat("Bar index: %d",bar);
                 }
               //---
               fracs[0].value=curr_down_val;
               fracs[1].value=curr_up_val;
               //--- check the state of the set
               frac_num=this.CheckSet(fracs);
               //--- if insufficient points
               if(frac_num==3)
                 {
                  //--- store the bar where a new channel appeared
                  _new_ch_buffer[0]=1.;
                  break;
                 }
              }
           }
        }
      //--- sorting
      if(is_history_add)
         if(frac_num>0)
            if(!this.IsSorted(1))
              {
               this.BubbleSort();
               //--- sorting
               if(!this.IsSorted(1))
                 {
                  Print("Fractal points sorting error.");
                  this.Clear();
                  return;
                 }
               m_prev_frac_num=0; // reset the number of added fractals during initialization
               //--- to the Journal        
               if(m_to_log)
                  PrintFormat("Previous fractals added: %d",frac_num);
               //}
              }
      //--- channel calculation
      if(frac_num==3)
        {
         //--- empty the buffers
         ArrayInitialize(_up_buffer,0.);     // upper border buffer
         ArrayInitialize(_down_buffer,0.);   // lower border buffer
         //--- time-price coordinates
         double prices[3];
         datetime times[3];
         ArrayInitialize(times,0);
         ArrayInitialize(prices,0.);
         bool is_1_point=false;
         ENUM_SET_TYPE curr_set_type=this.GetTypeOfSet();
         if(curr_set_type<=SET_TYPE_NONE)
           {
            Print("Channel will not be drawn: the type of extremum points set is not defined!");
            return;
           }
         for(int idx=0;idx<ArraySize(prices);idx++)
           {
            //--- get the fractal point
            CFractalPoint *ptr_curr_frac=this.At(idx);
            if(CheckPointer(ptr_curr_frac)!=POINTER_DYNAMIC)
              {
               Print("Error of obtaining the object of the fractal point from the set!");
               return;
              }
            ENUM_EXTREMUM_TYPE curr_frac_type=ptr_curr_frac.FractalType();
            datetime curr_point_time=ptr_curr_frac.Date();
            double curr_point_price=ptr_curr_frac.Value();
            //--- searching for points
            if(curr_set_type==SET_TYPE_MINMAX)
              {
               if(curr_frac_type==EXTREMUM_TYPE_MIN)
                 {
                  //--- 1st minimum
                  if(!is_1_point)
                    {
                     times[0]=curr_point_time;
                     prices[0]=curr_point_price;
                     is_1_point=true;
                    }
                  //--- 2nd minimum
                  else
                    {
                     times[1]=curr_point_time;
                     prices[1]=curr_point_price;
                    }
                 }
               //--- the only maximum
               else
                 {
                  times[2]=curr_point_time;
                  prices[2]=curr_point_price;
                 }
              }
            else if(curr_set_type==SET_TYPE_MAXMIN)
              {
               if(curr_frac_type==EXTREMUM_TYPE_MAX)
                 {
                  //--- 1st maximum 
                  if(!is_1_point)
                    {
                     times[0]=curr_point_time;
                     prices[0]=curr_point_price;
                     is_1_point=true;
                    }
                  //--- 2nd maximum
                  else
                    {
                     times[1]=curr_point_time;
                     prices[1]=curr_point_price;
                    }
                 }
               //--- the only minimum
               else
                 {
                  times[2]=curr_point_time;
                  prices[2]=curr_point_price;
                 }
              }
           }
         //--- 1) time coordinates
         //--- beginning of the channel
         int first_date_idx=ArrayMinimum(times);
         if(first_date_idx<0)
           {
            Print("Error in obtaining time coordinate!");
            return;
           }
         datetime first_point_date=times[first_date_idx];
         //--- end of the channel
         datetime last_point_date=_time_arr[0];
         //--- 2) price coordinates
         //--- 2.1 incline of the line
         //--- bars between first and second points
         datetime bars_dates[];
         int bars_between=CopyTime(_Symbol,_Period,
                                   times[0],times[1],bars_dates
                                   );
         if(bars_between<2)
           {
            Print("Error in obtaining the number of bars between points!");
            return;
           }
         bars_between-=1;
         //--- common differential
         double price_differential=MathAbs(prices[0]-prices[1]);
         //--- price speed (price speed on the first bar)
         double price_speed=price_differential/bars_between;
         //--- direction of channel
         bool is_up=(prices[0]<prices[1]);
         //--- 2.2 new price of the first or third points  
         if(times[0]!=times[2])
           {
            datetime start,end;
            start=times[0];
            end=times[2];
            //--- if the third point is earlier than the first
            bool is_3_point_earlier=false;
            if(times[2]<times[0])
              {
               start=times[2];
               end=times[0];
               is_3_point_earlier=true;
              }
            //--- bars between first and third points
            int bars_between_1_3=CopyTime(_Symbol,_Period,
                                          start,end,bars_dates
                                          );
            if(bars_between_1_3<2)
              {
               Print("Error in obtaining the number of bars between points!");
               return;
              }
            bars_between_1_3-=1;
            //--- if the ascending channel
            if(is_up)
              {
               //--- if the third point was earlier
               if(is_3_point_earlier)
                  prices[0]-=(bars_between_1_3*price_speed);
               else
                  prices[2]-=(bars_between_1_3*price_speed);
              }
            //--- or if the descending channel
            else
              {
               //--- if the third point was earlier
               if(is_3_point_earlier)
                  prices[0]+=(bars_between_1_3*price_speed);
               else
                  prices[2]+=(bars_between_1_3*price_speed);
              }
           }
         //--- 2.3 new price of the 2 point 
         if(times[1]<last_point_date)
           {
            datetime dates_for_last_bar[];
            //--- bars between the 2 point and the last bar
            bars_between=CopyTime(_Symbol,_Period,times[1],last_point_date,dates_for_last_bar);
            if(bars_between<2)
              {
               Print("Error in obtaining the number of bars between points!");
               return;
              }
            bars_between-=1;
            //--- if the ascending channel
            if(is_up)
               prices[1]+=(bars_between*price_speed);
            //--- or if the descending channel
            else
               prices[1]-=(bars_between*price_speed);
           }
         //--- final time coordinates 
         times[0]=times[2]=first_point_date;
         times[1]=last_point_date;
         //--- length of channel in bars
         int bars_len=CopyTime(_Symbol,_Period,
                               first_point_date,last_point_date,bars_dates
                               );
         //--- if min-max-min
         if(curr_set_type==SET_TYPE_MINMAX)
           {
            //--- if ascending
            if(is_up)
              {
               for(int idx=bars_len-1,jdx=0;idx>=0;idx--,jdx++)
                 {
                  //--- upper border buffer
                  _up_buffer[idx]=prices[2]+jdx*price_speed;
                  //--- lower border buffer
                  _down_buffer[idx]=prices[0]+jdx*price_speed;
                 }
              }
            //--- if descending
            else
              {
               for(int idx=bars_len-1,jdx=0;idx>=0;idx--,jdx++)
                 {
                  //--- upper border buffer
                  _up_buffer[idx]=prices[2]-jdx*price_speed;
                  //--- lower border buffer
                  _down_buffer[idx]=prices[0]-jdx*price_speed;
                 }
              }
           }
         //--- if max-min-max
         else if(curr_set_type==SET_TYPE_MAXMIN)
           {
            //--- if ascending
            if(is_up)
              {
               for(int idx=bars_len-1,jdx=0;idx>=0;idx--,jdx++)
                 {
                  //--- upper border buffer
                  _up_buffer[idx]=prices[0]+jdx*price_speed;
                  //--- lower border buffer
                  _down_buffer[idx]=prices[2]+jdx*price_speed;
                 }
              }
            //--- if descending
            else
              {
               for(int idx=bars_len-1,jdx=0;idx>=0;idx--,jdx++)
                 {
                  //--- upper border buffer
                  _up_buffer[idx]=prices[0]-jdx*price_speed;
                  //--- lower border buffer
                  _down_buffer[idx]=prices[2]-jdx*price_speed;
                 }
              }
           }
        }
     }
//--- as regular arrays
   ArraySetAsSeries(_up_frac_buffer,false);
   ArraySetAsSeries(_down_frac_buffer,false);
   ArraySetAsSeries(_time_arr,false);
   ArraySetAsSeries(_up_buffer,false);
   ArraySetAsSeries(_down_buffer,false);
   ArraySetAsSeries(_new_ch_buffer,false);
  }
//+------------------------------------------------------------------+
//| Determine the type                                               |
//+------------------------------------------------------------------+
int CFractalSet::CheckSet(const SFracData &_fractals[])
  {
//--- Adding fractal points to a temporary set
   CArrayObj temp_add_set;
   for(int idx=0;idx<ArraySize(_fractals);idx++)
      if((_fractals[idx].value<DBL_MAX) && (_fractals[idx].value>0.))
        {
         //--- create a fractal point object
         CFractalPoint *ptr_new_fractal=new CFractalPoint;
         if(CheckPointer(ptr_new_fractal)!=POINTER_DYNAMIC)
            return -1;
         //---
         ENUM_EXTREMUM_TYPE new_fractal_type=WRONG_VALUE;
         //--- Collect data for fractal point
         //--- 1) time
         ptr_new_fractal.Date(_fractals[idx].time);
         //--- 2) price
         double frac_pr=_fractals[idx].value;
         ptr_new_fractal.Value(frac_pr);
         //--- 3) type
         if(idx==1)
            new_fractal_type=EXTREMUM_TYPE_MAX;
         else
            new_fractal_type=EXTREMUM_TYPE_MIN;
         ptr_new_fractal.FractalType(new_fractal_type);
         //--- adding to set
         if(!temp_add_set.Add(ptr_new_fractal))
           {
            Print("Error adding a fractal point!");
            delete ptr_new_fractal;
            return -1;
           }
        }
//--- check the number of added points to the temporary set
   int frac_num_to_add=temp_add_set.Total();
   if(frac_num_to_add<1)
      return -1;
//---
   bool is_emptied=false; // is the set emptied?
   int curr_fractal_num=0;
//--- adding point to set
   for(int frac_idx=0;frac_idx<frac_num_to_add;frac_idx++)
     {
      CFractalPoint *ptr_temp_frac=temp_add_set.At(frac_idx);
      if(CheckPointer(ptr_temp_frac)!=POINTER_DYNAMIC)
        {
         Print("Error of obtaining the object of the fractal point from the temporary set!");
         return -1;
        }
      //--- if checking the number of bars between the last and current points
      if(m_bars_between>0)
        {
         curr_fractal_num=this.Total();
         if(curr_fractal_num>0)
           {
            CFractalPoint *ptr_prev_frac=this.At(curr_fractal_num-1);
            if(CheckPointer(ptr_prev_frac)!=POINTER_DYNAMIC)
              {
               Print("Error of obtaining the object of the fractal point from the set!");
               return -1;
              }
            datetime time1,time2;
            time1=ptr_prev_frac.Date();
            time2=ptr_temp_frac.Date();
            //--- bars between points
            datetime bars_dates[];
            int bars_between=CopyTime(_Symbol,_Period,
                                      time1,time2,bars_dates
                                      );
            if(bars_between<0)
              {
               Print("Errors of obtaining data for the bar opening time!");
               return -1;
              }
            bars_between-=2;
            //--- if on various bars
            if(bars_between>=0)
               //--- if interim bars are not sufficient 
               if(bars_between<m_bars_between)
                 {
                  bool to_delete_frac=false;
                  if(m_to_log)
                     Print("Intermediate bars are not sufficient. One point will be skipped.");
                  //--- if the previous point is relevant
                  if(m_rel_frac==RELEVANT_EXTREMUM_PREV)
                    {
                     datetime curr_frac_date=time2;
                     //--- if there was initialization
                     if(m_is_init)
                       {
                        continue;
                       }
                     //--- if there was not initialization
                     else
                       {
                        //--- remove current point
                        to_delete_frac=true;
                        curr_frac_date=time1;
                       }
                     if(m_to_log)
                       {
                        PrintFormat("Current point will be skipped: %s",
                                    TimeToString(curr_frac_date));
                       }
                    }
                  //--- if the last point is relevant
                  else
                    {
                     datetime curr_frac_date=time1;
                     //--- if there was initialization
                     if(m_is_init)
                       {
                        //--- remove previous point
                        to_delete_frac=true;
                       }
                     //--- if there was not initialization
                     else
                       {
                        curr_frac_date=time2;
                       }
                     if(m_to_log)
                        PrintFormat("Previous point will be skipped: %s",
                                    TimeToString(curr_frac_date));
                     if(curr_frac_date==time2)
                        continue;

                    }
                  //--- if delete the point
                  if(to_delete_frac)
                    {
                     if(!this.Delete(curr_fractal_num-1))
                       {
                        Print("Error of deleting the last point in the set!");
                        return -1;
                       }
                    }
                 }
           }
        }
      //--- adding fractal point to the current set - copying
      CFractalPoint *ptr_new_fractal=new CFractalPoint;
      if(CheckPointer(ptr_new_fractal)==POINTER_DYNAMIC)
        {
         ptr_new_fractal.Copy(ptr_temp_frac);
         if(!this.Add(ptr_new_fractal))
           {
            Print("Error adding a fractal point to the current set!");
            delete ptr_new_fractal;
            return -1;
           }
         //--- point index
         ptr_new_fractal.Index(this.Total()-1);
        }
     }
//--- validation of set
   curr_fractal_num=this.Total();
//--- if there are unnecessary points
   if(curr_fractal_num>m_fractal_num)
     {
      uint num_to_crop=curr_fractal_num-m_fractal_num;
      //--- trim the set
      if(!this.Crop(num_to_crop))
        {
         Print("Error of deleting the unnecessary points from the set!");
         return -1;
        }
      //--- update the number of points in the set
      curr_fractal_num=this.Total();
     }
//--- if insufficient points
   if(curr_fractal_num==m_fractal_num)
     {
      //--- determine the type of the set
      int min_cnt,max_cnt; // counters
      min_cnt=max_cnt=0;
      for(int frac_idx=0;frac_idx<curr_fractal_num;frac_idx++)
        {
         //--- get the point
         CFractalPoint *ptr_curr_frac=this.At(frac_idx);
         if(CheckPointer(ptr_curr_frac)!=POINTER_DYNAMIC)
           {
            Print("Error of obtaining the object of the fractal point from the set!");
            return -1;
           }
         //--- determine the type
         ENUM_EXTREMUM_TYPE curr_frac_type=ptr_curr_frac.FractalType();
         if(curr_frac_type==EXTREMUM_TYPE_MIN)
            min_cnt++;
         else if(curr_frac_type==EXTREMUM_TYPE_MAX)
            max_cnt++;
        }
      //--- if there are 2 minimums and 1 maximum
      if((min_cnt==2) && (max_cnt==1))
         this.SetTypeOfSet(SET_TYPE_MINMAX);
      //--- if there are 1 minimum and 2 maximums
      else if((min_cnt==1) && (max_cnt==2))
         this.SetTypeOfSet(SET_TYPE_MAXMIN);
      //--- else remove the first or last point, if the type is not defined
      else
        {
         //--- if there was an initialization - delete the first
         if(m_is_init)
           {
            if(!this.Crop(1))
              {
               Print("Error of deleting the first point in the uniform set!");
               this.Clear();
               return false;
              }
            if(m_to_log)
               Print("Deleted the first point in the uniform set.");
           }
         //--- if there was no initialization - delete the last
         else
           {
            if(!this.Delete(curr_fractal_num-1))
              {
               Print("Error of deleting the last point in the uniform set!");
               this.Clear();
               return false;
              }
            if(m_to_log)
               Print("Deleted the last point in the uniform set.");
           }
        }
     }
//---
   return this.Total();
  }
//+------------------------------------------------------------------+
//| Trimming the set                                                 |
//+------------------------------------------------------------------+
bool CFractalSet::Crop(const uint _num_to_crop)
  {
//--- if the number of points to be deleted is not defined
   if(_num_to_crop<1)
      return false;
//---
   if(!this.DeleteRange(0,_num_to_crop-1))
     {
      Print("Error of deleting fractal points!");
      return false;
     }
//---
   return true;
  }
//+------------------------------------------------------------------+
//| Bubble sorting                                                   |
//+------------------------------------------------------------------+
void CFractalSet::BubbleSort(void)
  {
   m_sort_mode=-1;
//---
   uint arr_size=this.Total();
   for(uint passes=0;passes<arr_size-1;passes++)
      for(uint j=0;j<(arr_size-passes-1);j++)
        {
         CFractalPoint *ptr_p1=this.At(j);
         CFractalPoint *ptr_p2=this.At(j+1);
         //--- compare values (by date)
         if(ptr_p1.Date()>ptr_p2.Date())
           {
            CFractalPoint *ptr_temp_p=new CFractalPoint;
            if(CheckPointer(ptr_temp_p)==POINTER_DYNAMIC)
              {
               ptr_temp_p.Copy(ptr_p2);
               if(!this.Insert(ptr_temp_p,j))
                  return;
               if(!this.Delete(j+2))
                  return;
              }
            else
               return;
           }
        }
   m_sort_mode=1;
  }
//+------------------------------------------------------------------+
