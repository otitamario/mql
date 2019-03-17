//+------------------------------------------------------------------+
//|                                                     MySignal.mqh |
//|                              Copyright © 2012, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signal of the 'Custom Indicator' indicator                 |
//| Type=SignalAdvanced                                              |
//| Name=MyCustomIndicator                                           |
//| ShortName=MyCustomIndicator                                      |
//| Class=CSignalMyCustInd                                           |
//| Page=signal_envelopes                                            |
//| Parameter=PeriodFast,int,12,Period of fast EMA                   |
//| Parameter=PeriodSlow,int,24,Period of slow EMA                   |
//| Parameter=PeriodSignal,int,9,Period of averaging of difference   |
//| Parameter=Applied,ENUM_APPLIED_PRICE,PRICE_CLOSE,Prices series   |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalMyCustInd.                                          |
//| Purpose: Class of trading signal generator based on              |
//|          custom indicator.                                       |
//| It is derived from the CExpertSignal class.                      |
//+------------------------------------------------------------------+
class CSignalMyCustInd : public CExpertSignal
  {
protected:
   CiCustom          m_mci;            // indicator object "MyCustomIndicator"
   //--- adjustable parameters
   int               m_period_fast;    // "fast EMA period"
   int               m_period_slow;    // "slow EMA period"
   int               m_period_signal;  // "difference averaging period"
   ENUM_APPLIED_PRICE m_applied;       // "price type"
   //--- "weights" of market models (0-100)
   int               m_pattern_0;      // model 0 "the oscillator has required direction"
   int               m_pattern_1;      // model 1 "the indicator is gaining momentum - buy; the indicator is falling - sell"

public:
                     CSignalMyCustInd(void);
                    ~CSignalMyCustInd(void);
   //--- methods of setting adjustable parameters
   void              PeriodFast(int value)               { m_period_fast=value;           }
   void              PeriodSlow(int value)               { m_period_slow=value;           }
   void              PeriodSignal(int value)             { m_period_signal=value;         }
   void              Applied(ENUM_APPLIED_PRICE value)   { m_applied=value;               }
   //--- methods of adjusting "weights" of market models
   void              Pattern_0(int value)                { m_pattern_0=value;        }
   void              Pattern_1(int value)                { m_pattern_1=value;        }
   //--- method of verification of settings
   virtual bool      ValidationSettings(void);
   //--- method of creating the indicator and time series
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- methods of checking if the market models are generated
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);

protected:
   //--- indicator initialization method
   bool              InitMyCustomIndicator(CIndicators *indicators);
   //--- methods of getting data
   //- getting the indicator value
   double            Main(int ind) { return(m_mci.GetData(0,ind));      }
   //- getting the signal line value
   double            Signal(int ind) { return(m_mci.GetData(1,ind));    }
   //- difference between two successive indicator values
   double            DiffMain(int ind) { return(Main(ind)-Main(ind+1)); }
   int               StateMain(int ind);
   double            State(int ind) { return(Main(ind)-Signal(ind)); }
   //- preparing data for the search
   bool              ExtState(int ind);
   //- searching the market model with the specified parameters
   bool              CompareMaps(int map,int count,bool minimax=false,int start=0);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalMyCustInd::CSignalMyCustInd(void) : m_period_fast(12),
                                           m_period_slow(24),
                                           m_period_signal(9),
                                           m_applied(PRICE_CLOSE),
                                           m_pattern_0(10),
                                           m_pattern_1(50)
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_HIGH+USE_SERIES_LOW;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalMyCustInd::~CSignalMyCustInd(void)
  {
  }
//+------------------------------------------------------------------+
//| Checking parameters of protected data                            |
//+------------------------------------------------------------------+
bool CSignalMyCustInd::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//--- initial data checks
   if(m_period_fast>=m_period_slow)
     {
      printf(__FUNCTION__+": slow period must be greater than fast period");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Creation of indicators.                                          |
//+------------------------------------------------------------------+
bool CSignalMyCustInd::InitIndicators(CIndicators *indicators)
  {
//--- check of pointer is performed in the method of the parent class
//---
//--- initialization of indicators and time series of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- creation and initialization of the custom indicator
   if(!InitMyCustomIndicator(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialization of indicators.                                    |
//+------------------------------------------------------------------+
bool CSignalMyCustInd::InitMyCustomIndicator(CIndicators *indicators)
  {
//--- add an object to the collection
   if(!indicators.Add(GetPointer(m_mci)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- set parameters of the indicator
   MqlParam parameters[4];
//---
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="Examples\\MACD.ex5";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=m_period_fast;
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=m_period_slow;
   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=m_period_signal;
//--- object initialization
   if(!m_mci.Create(m_symbol.Name(),0,IND_CUSTOM,4,parameters))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- number of buffers
   if(!m_mci.NumBuffers(4)) return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| "Voting" that the price will grow.                               |
//+------------------------------------------------------------------+
int CSignalMyCustInd::LongCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//--- check direction of the main line
   if(DiffMain(idx)>0.0)
     {
      //--- the main line goes upwards, which confirms the possibility of the price growth
      if(IS_PATTERN_USAGE(0))
         result=m_pattern_0;      // "confirming" signal number 0
      //--- if the model 1 is used, look for a reverse of the main line
      if(IS_PATTERN_USAGE(1) && DiffMain(idx+1)<0.0)
         result=m_pattern_1;      // signal number 1
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that the price will fall.                               |
//+------------------------------------------------------------------+
int CSignalMyCustInd::ShortCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//--- check direction of the main line
   if(DiffMain(idx)<0.0)
     {
            //--- the main line goes downwards, which confirms the possibility of the price fall
      if(IS_PATTERN_USAGE(0))
         result=m_pattern_0;      // "confirming" signal number 0
      //--- if the model 1 is used, look for a reverse of the main line
      if(IS_PATTERN_USAGE(1) && DiffMain(idx+1)>0.0)
         result=m_pattern_1;      // signal number 1
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
