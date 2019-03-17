//+------------------------------------------------------------------+
//|                                                    SignalBollingerPercent.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of oscilator 'Bollinger Bands Percent and ADX'             |
//| Type=SignalAdvanced                                              |
//| Name=Bollinger Bands Percent and ADX  v2                                  |
//| ShortName=BB_ADX_v2                                                    |
//| Class=CSignalBB_ADX                                                 |
//|  Parameter=TimeFrameBB,ENUM_TIMEFRAMES,PERIOD_M10,TimeFrame BB      |
//| Parameter=PeriodBB,int,18,Period of calculation                  |
//| Parameter=Shift,int,0,shift                  |
//| Parameter=Deviation,double,1.5,deviation                  |
//| Parameter=Applied,ENUM_APPLIED_PRICE,PRICE_CLOSE,Prices series   |
//| Parameter=PeriodADX,int,14,Period of calculation                 |
//| Parameter=MIN_ADX,double,20.0,ADX minimo                       |
//| Parameter=D_ADX_min,double,-17.0,Variacao ADX minimo            |
//| Parameter=D_ADX_max,double,17.0,Variacao ADX maximo             |
//| Parameter=Pattern_0,int,60,peso padrao 0   |
//| Parameter=Pattern_1,int,60,peso padrao 1   |
//| Parameter=Pattern_2,int,60,peso padrao 2   |
//| Parameter=Pattern_3,int,60,peso padrao 3   |
//| Parameter=Pattern_4,int,60,peso padrao 4   |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalBB_ADX.                                                |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'Commodity Channel Index' oscillator.               |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
class CSignalBB_ADX : public CExpertSignal
  {
protected:
   CiBands             m_BB;            // object-oscillator
   //--- adjusted parameters
   ENUM_TIMEFRAMES   m_timeframeBB;    //TimeFrame Bollinger Bands   
   int               m_period_BB;      // the "period of calculation" parameter of the oscillator
   int               m_shift;
   double            m_deviation;
   ENUM_APPLIED_PRICE m_applied;       // the "prices series" parameter of the oscillator
    CiADX             m_adx;            // object-oscillator
   //--- adjusted parameters
   int               m_PeriodADX;      // the "period of calculation" parameter of the oscillator
    double            ADX_minimum;      //Valor Minimo ADX
   double            Diff_ADX_min;      //Valor Minimo da variacao ADX
    double            Diff_ADX_max;      //Valor Maximo da variacao ADX


   //--- "weights" of market models (0-100)
   int               m_pattern_0;      // model 0 "the oscillator has required direction"
   int               m_pattern_1;      // model 1 "reverse behind the level of overbuying/overselling"
   int               m_pattern_2;      // model 2 "divergence of the oscillator and price"
   int               m_pattern_3;      // model 3 "double divergence of the oscillator and price"
   int               m_pattern_4;      // model 4 "cruzou a linha 0.5"
  
   //--- variables
   double            m_extr_osc[10];   // array of values of extremums of the oscillator
   double            m_extr_pr[10];    // array of values of the corresponding extremums of price
   int               m_extr_pos[10];   // array of shifts of extremums (in bars)
   uint              m_extr_map;       // resulting bit-map of ratio of extremums of the oscillator and the price

public:
                     CSignalBB_ADX(void);
                    ~CSignalBB_ADX(void);
   //--- methods of setting adjustable parameters
   void              TimeFrameBB(ENUM_TIMEFRAMES value) {m_timeframeBB=value;} 
   void               PeriodBB(int value)        { m_period_BB=value;           }
   void              Shift(int value)         { m_shift=value;           }
   void            Deviation(double value)        { m_deviation=value;           }
   void              Applied(ENUM_APPLIED_PRICE value) { m_applied=value;             }
    void              PeriodADX(int value)              { m_PeriodADX=value;           }
   //---Ajustar ADX minimo
    void              MIN_ADX(double value)            {ADX_minimum=value;}
    void           D_ADX_min(double value)             {Diff_ADX_min=value;}      
    void           D_ADX_max(double value)            {Diff_ADX_max=value;}      


   //--- methods of adjusting "weights" of market models
   void              Pattern_0(int value)              { m_pattern_0=value;           }
   void              Pattern_1(int value)              { m_pattern_1=value;           }
   void              Pattern_2(int value)              { m_pattern_2=value;           }
   void              Pattern_3(int value)              { m_pattern_3=value;           }
   void              Pattern_4(int value)              { m_pattern_4=value;           }
 
   //--- method of verification of settings
   virtual bool      ValidationSettings(void);
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- methods of checking if the market models are formed
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);

protected:
   //--- method of initialization of the oscillator
   bool              InitStoch(CIndicators *indicators);
   //--- methods of getting data
   //double            BBP(int ind)                      { return((Close(ind)-m_BB.Lower(ind))/(m_BB.Upper(ind)-m_BB.Lower(ind)));     }
   double            Diff(int ind)                     { return(BBP(ind)-BBP(ind+1)); }
   double            BBP(int ind);                   
   //double            Diff(int ind);                  
   double            Close(int ind)              { return(m_close.GetData(ind)); }
double            High(int ind)              { return(m_high.GetData(ind)); }
double            Low(int ind)              { return(m_low.GetData(ind)); }
   
   double            ADX(int ind)                      { return(m_adx.Main(ind));     }
   double            DiffADX(int ind)                     { return(ADX(ind)-ADX(ind+1)); }
   double            Diff_PLUS(int ind)                     { return(ADX_PLUS(ind)-ADX_PLUS(ind+1)); }
   double            Diff_MINUS(int ind)                     { return(ADX_MINUS(ind)-ADX_MINUS(ind+1)); }
   double            Diff_PL_MIN(int ind)                     { return(ADX_PLUS(ind)-ADX_MINUS(ind)); }
   double            DX_PL_MIN(int ind)                     { return(Diff_PL_MIN(ind)-Diff_PL_MIN(ind+1)); }
   

   double            ADX_PLUS(int ind)                      { return(m_adx.Plus(ind));     }
   double            ADX_MINUS(int ind)                      { return(m_adx.Minus(ind));     }
   bool              DunnBuy(int ind) {return(Low(ind)>Low(ind+1)&&High(ind)>High(ind+1));}
   bool              DunnSell(int ind) {return(Low(ind)<Low(ind+1)&&High(ind)<High(ind+1));}

   int               State(int ind);
   bool              ExtState(int ind);
   bool              CompareMaps(int map,int count,bool minimax=false,int start=0);
  };
  
double CSignalBB_ADX::BBP(int ind)
{
//Print("Close",Close(ind),"BB UP",m_BB.Upper(ind),"BB LOW",m_BB.Lower(ind));
return((Close(ind)-m_BB.Lower(ind))/(m_BB.Upper(ind)-m_BB.Lower(ind)));
}  
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalBB_ADX::CSignalBB_ADX(void) :m_timeframeBB(PERIOD_M10),
                               m_period_BB(18),
                               m_shift(0),
                               m_deviation(1.5),
                               m_applied(PRICE_CLOSE),
                                m_PeriodADX(14),
                                ADX_minimum(20.0),
                                Diff_ADX_min(-17.0),
                                Diff_ADX_max(17.0),                              
                               m_pattern_0(60),
                               m_pattern_1(60),
                               m_pattern_2(60),
                               m_pattern_3(60),
                               m_pattern_4(60)
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_HIGH+USE_SERIES_LOW+USE_SERIES_CLOSE;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalBB_ADX::~CSignalBB_ADX(void)
  {
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CSignalBB_ADX::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//--- initial data checks
   if(m_period_BB<=0)
     {
      printf(__FUNCTION__+": period of the BBP oscillator must be greater than 0");
      return(false);
     }
     if(m_PeriodADX<=0)
     {
      printf(__FUNCTION__+": period of the ADX oscillator must be greater than 0");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool CSignalBB_ADX::InitIndicators(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize BB_Percent oscillator
   if(!InitStoch(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize BBP oscillators.                                      |
//+------------------------------------------------------------------+
bool CSignalBB_ADX::InitStoch(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- add object to collection
   if(!indicators.Add(GetPointer(m_BB)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize object
   if(!m_BB.Create(m_symbol.Name(),m_timeframeBB,m_period_BB,m_shift,m_deviation,m_applied))
                           
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
     if(!indicators.Add(GetPointer(m_adx)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize object
   if(!m_adx.Create(m_symbol.Name(),m_period,m_PeriodADX))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Check of the oscillator state.                                   |
//+------------------------------------------------------------------+
int CSignalBB_ADX::State(int ind)
  {
   int    res=0;
   double var;
//---
   for(int i=ind;;i++)
     {
      if(BBP(i+1)==EMPTY_VALUE)
         break;
      var=Diff(i);
      if(res>0)
        {
         if(var<0)
            break;
         res++;
         continue;
        }
      if(res<0)
        {
         if(var>0)
            break;
         res--;
         continue;
        }
      if(var>0)
         res++;
      if(var<0)
         res--;
     }
//--- return the result
   return(res);
  }
//+------------------------------------------------------------------+
//| Extended check of the oscillator state consists                  |
//| in forming a bit-map according to certain rules,                 |
//| which shows ratios of extremums of the oscillator and price.     |
//+------------------------------------------------------------------+
bool CSignalBB_ADX::ExtState(int ind)
  {
//--- operation of this method results in a bit-map of extremums
//--- practically, the bit-map of extremums is an "array" of 4-bit fields
//--- each "element of the array" definitely describes the ratio
//--- of current extremums of the oscillator and the price with previous ones
//--- purpose of bits of an element of the analyzed bit-map
//--- bit 3 - not used (always 0)
//--- bit 2 - is equal to 1 if the current extremum of the oscillator is "more extreme" than the previous one
//---         (a higher peak or a deeper valley), otherwise - 0
//--- bit 1 - not used (always 0)
//--- bit 0 - is equal to 1 if the current extremum of price is "more extreme" than the previous one
//---         (a higher peak or a deeper valley), otherwise - 0
//--- in addition to them, the following is formed:
//--- array of values of extremums of the oscillator,
//--- array of values of price extremums and
//--- array of "distances" between extremums of the oscillator (in bars)
//--- it should be noted that when using the results of the extended check of state,
//--- you should consider, which extremum of the oscillator (peak or valley)
//--- is the "reference point" (i.e. was detected first during the analysis)
//--- if a peak is detected first then even elements of all arrays
//--- will contain information about peaks, and odd elements will contain information about valleys
//--- if a valley is detected first, then respectively in reverse
   int    pos=ind,off,index;
   uint   map;                 // intermediate bit-map for one extremum
//---
   m_extr_map=0;
   for(int i=0;i<10;i++)
     {
      off=State(pos);
      if(off>0)
        {
         //--- minimum of the oscillator is detected
         pos+=off;
         m_extr_pos[i]=pos;
         m_extr_osc[i]=BBP(pos);
         if(i>1)
           {
            m_extr_pr[i]=m_low.MinValue(pos-2,5,index);
            //--- form the intermediate bit-map
            map=0;
            if(m_extr_pr[i-2]<m_extr_pr[i])
               map+=1;  // set bit 0
            if(m_extr_osc[i-2]<m_extr_osc[i])
               map+=4;  // set bit 2
            //--- add the result
            m_extr_map+=map<<(4*(i-2));
           }
         else
            m_extr_pr[i]=m_low.MinValue(pos-1,3,index);
        }
      else
        {
         //--- maximum of the oscillator is detected
         pos-=off;
         m_extr_pos[i]=pos;
         m_extr_osc[i]=BBP(pos);
         if(i>1)
           {
            m_extr_pr[i]=m_high.MaxValue(pos-2,5,index);
            //--- form the intermediate bit-map
            map=0;
            if(m_extr_pr[i-2]>m_extr_pr[i])
               map+=1;  // set bit 0
            if(m_extr_osc[i-2]>m_extr_osc[i])
               map+=4;  // set bit 2
            //--- add the result
            m_extr_map+=map<<(4*(i-2));
           }
         else
            m_extr_pr[i]=m_high.MaxValue(pos-1,3,index);
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Comparing the bit-map of extremums with pattern.                 |
//+------------------------------------------------------------------+
bool CSignalBB_ADX::CompareMaps(int map,int count,bool minimax,int start)
  {
   int step =(minimax)?4:8;
   int total=step*(start+count);
//--- check input parameters for a possible going out of range of the bit-map
   if(total>32)
      return(false);
//--- bit-map of the patter is an "array" of 4-bit fields
//--- each "element of the array" definitely describes the desired ratio
//--- of current extremums of the oscillator and the price with previous ones
//--- purpose of bits of an elements of the pattern of the bit-map pattern
//--- bit 3 - is equal to if the ratio of extremums of the oscillator is insignificant for us
//---         is equal to 0 if we want to "find" the ratio of extremums of the oscillator determined by the value of bit 2
//--- bit 2 - is equal to 1 if we want to "discover" the situation when the current extremum of the "oscillator" is "more extreme" than the previous one
//---         (current peak is higher or current valley is deeper)
//---         is equal to 0 if we want to "discover" the situation when the current extremum of the oscillator is "less extreme" than the previous one
//---         (current peak is lower or current valley is less deep)
//--- bit 1 - is equal to 1 if the ratio of extremums is insignificant for us
//---         it is equal to 0 if we want to "find" the ratio of price extremums determined by the value of bit 0
//--- bit 0 - is equal to 1 if we want to "discover" the situation when the current price extremum is "more extreme" than the previous one
//---         (current peak is higher or current valley is deeper)
//---         it is equal to 0 if we want to "discover" the situation when the current price extremum is "less extreme" than the previous one
//---         (current peak is lower or current valley is less deep)
   uint inp_map,check_map;
   int  i,j;
//--- loop by extremums (4 minimums and 4 maximums)
//--- price and the oscillator are checked separately (thus, there are 16 checks)
   for(i=step*start,j=0;i<total;i+=step,j+=4)
     {
      //--- "take" two bits - patter of the corresponding extremum of the price
      inp_map=(map>>j)&3;
      //--- if the higher-order bit=1, then any ratio is suitable for us
      if(inp_map<2)
        {
         //--- "take" two bits of the corresponding extremum of the price (higher-order bit is always 0)
         check_map=(m_extr_map>>i)&3;
         if(inp_map!=check_map)
            return(false);
        }
      //--- "take" two bits - pattern of the corresponding oscillator extremum
      inp_map=(map>>(j+2))&3;
      //--- if the higher-order bit=1, then any ratio is suitable for us
      if(inp_map>=2)
         continue;
      //--- "take" two bits of the corresponding oscillator extremum (higher-order bit is always 0)
      check_map=(m_extr_map>>(i+2))&3;
      if(inp_map!=check_map)
         return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalBB_ADX::LongCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//---
   
//    if(Diff(idx)>0.0&& ADX(idx)>ADX_minimum)
    if(Diff(idx)>0.0&& ADX(idx)>ADX_minimum && DX_PL_MIN(idx)>0.0&& Diff_PL_MIN(idx)<Diff_ADX_max)//&&(Diff_PLUS(idx)>0.0||Diff_MINUS(idx)<0.0))

     {
      //--- the oscillator is directed upwards confirming the possibility of price growth
      if(IS_PATTERN_USAGE(0)&&BBP(idx)>1.0&&DunnBuy(idx)&&Close(idx)>m_BB.Upper(idx))
         {result=m_pattern_0;      // "confirming" signal number 0
         Print("Padrao 0 Compra");}
      //--- if the model 1 is used, search for a reverse of the oscillator upwards behind the level of overselling
      if(IS_PATTERN_USAGE(1) && Diff(idx+1)<0.0 && BBP(idx+1)<0.0&&Close(idx)>m_BB.Lower(idx))
         {result=m_pattern_1;      // signal number 1
         Print("Padrao 1 Compra");}
      //--- if the model 2 or 3 is used, perform the extended analysis of the oscillator state
      if(IS_PATTERN_USAGE(2) || IS_PATTERN_USAGE(3))
        {
         ExtState(idx);
         //--- if the model 2 is used, search for the "divergence" signal
         if(IS_PATTERN_USAGE(2) && CompareMaps(1,1)) // 00000001b
           { result=m_pattern_2;   // signal number 2
           Print("Padrao 2 Compra");}
         //--- if the model 3 is used, search for the "double divergence" signal
         if(IS_PATTERN_USAGE(3) && CompareMaps(0x11,2)) // 00010001b
            {return(m_pattern_3);  // signal number 3
            Print("Padrao 3 Compra");}
        }
        if(IS_PATTERN_USAGE(4) && BBP(idx+1)<0.5 && BBP(idx)>0.5&& DunnBuy(idx))
       { result=m_pattern_4;      // signal number 4
       Print("Padrao 4 Compra");}

     }
//--- return the result
//Print("Result Compra",result);
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalBB_ADX::ShortCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//---
   if(Diff(idx)<0.0&& ADX(idx)>ADX_minimum &&DX_PL_MIN(idx)<0.0&&Diff_PL_MIN(idx)>Diff_ADX_min)//&&(Diff_MINUS(idx)>0.0||Diff_PLUS(idx)<0.0))
     {
      //--- the oscillator is directed downwards confirming the possibility of falling of price
      if(IS_PATTERN_USAGE(0)&& BBP(idx)<0.0&&DunnSell(idx)&&Close(idx)<m_BB.Lower(idx))
         {result=m_pattern_0;      // "confirming" signal number 0
         Print("Padrao 0 Venda","result",result);}
      //--- if the model 1 is used, search for a reverse of the oscillator downwards behind the level of overbuying
      if(IS_PATTERN_USAGE(1) && Diff(idx+1)>0.0 && BBP(idx+1)>1.0&&Close(idx)<m_BB.Upper(idx))
         {result=m_pattern_1;      // signal number 1
         Print("Padrao 1 Venda","result",result);}
      //--- if the model 2 or 3 is used, perform the extended analysis of the oscillator state
      if(IS_PATTERN_USAGE(2) || IS_PATTERN_USAGE(3))
        {
         ExtState(idx);
         //--- if the model 2 is used, search for the "divergence" signal
         if(IS_PATTERN_USAGE(2) && CompareMaps(1,1)) // 00000001b
            {result=m_pattern_2;   // signal number 2
            Print("Padrao 2 Venda","result",result);}
         //--- if the model 3 is used, search for the "double divergence" signal
         if(IS_PATTERN_USAGE(3) && CompareMaps(0x11,2)) // 00010001b
            {return(m_pattern_3);  // signal number 3
            Print("Padrao 3 Venda","result",result);}
        }
        if(IS_PATTERN_USAGE(4) && BBP(idx+1)>0.5 && BBP(idx)<0.5&&DunnSell(idx))
        {result=m_pattern_4;      // signal number 4
        Print("Padrao 4 Venda","result",result);}
     }
//--- return the result
//Print("Result Venda",result);
   return(result);
  }
//+------------------------------------------------------------------+
