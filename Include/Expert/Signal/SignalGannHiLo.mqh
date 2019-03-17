//+------------------------------------------------------------------+
//|                                                   SignalHILO.mqh |
//|                                 Copyright 2009-2016, Genes Luna. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
#resource "\\Indicators\\HILO.ex5"
// wizard description start
//+-------------------------------------------------------------------------+
//| Description of the class                                                |
//| Title=GANN HILO Signal.                                                 |
//| Type=SignalAdvanced                                                     |
//| Name=GANN_HILO                                                          |
//| ShortName=HILO                                                          |
//| Class=CSignalHILO                                                       |
//| Page=signal_hilo                                                        |
//| Parameter=PeriodHILO,int,13,Period of averaging                         |
//| Parameter=Method,ENUM_MA_METHOD,MODE_SMA,Method of averaging            |
//| Parameter=SignalMode,int,1,Signal Mode(1-Both/2-Trigger/3-Continuous)   |
//+-------------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalHILO.                                               |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'GANN HILO' indicator.                              |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
class CSignalHILO : public CExpertSignal
  {
protected:
   CiCustom          m_hilo;             // object-indicator
   //--- adjusted parameters
   int               m_hilo_period;      // the "period of averaging" parameter of the indicator
   ENUM_MA_METHOD    m_hilo_method;      // the "method of averaging" parameter of the indicator
   //--- "weights" of market models (0-100)
   int               m_pattern_0;        // model 0 "price is on the necessary side from the indicator"
   int               m_pattern_1;        // model 2 "price crossed the indicator"
   int               m_pattern_2;        // model 3 "piercing"
   int               m_signal_mode;      // signal mode
public:
                     CSignalHILO(void);
                    ~CSignalHILO(void);
   //--- methods of setting adjustable parameters
   void              PeriodHILO(int value)               { m_hilo_period=value;          }
   void              Method(ENUM_MA_METHOD value)        { m_hilo_method=value;          }

   //--- methods of adjusting "weights" of market models
   void              Pattern_0(int value)                { m_pattern_0=value;          }
   void              Pattern_1(int value)                { m_pattern_1=value;          }
   void              Pattern_2(int value)                { m_pattern_2=value;          }
   void              SignalMode(int value)               { m_signal_mode=value;        }
   //--- method of verification of settings
   virtual bool      ValidationSettings(void);
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- methods of checking if the market models are formed
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);

protected:
   //--- method of initialization of the indicator
   bool              InitHILO(CIndicators *indicators);
   //--- methods of getting data
   double            HI(int ind)                           { return(m_hilo.GetData(2,ind));   }
   double            LO(int ind)                           { return(m_hilo.GetData(3,ind));   }
   double            Trend(int ind)                        { return(m_hilo.GetData(4,ind));   }
   double            DiffTrend(int ind)                    { return(Trend(ind)-Trend(ind+1)); }
   double            DiffHighLO(int ind)                   { return(High(ind)-LO(ind));       }
   double            DiffLowHI(int ind)                    { return(Low(ind)-HI(ind));        }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalHILO::CSignalHILO(void) : m_hilo_period(12),
                                 m_hilo_method(MODE_SMA),
                                 m_pattern_0(80),
                                 m_pattern_1(100),
                                 m_pattern_2(60),
                                 m_signal_mode(1)
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_HIGH+USE_SERIES_LOW;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalHILO::~CSignalHILO(void)
  {
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CSignalHILO::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//--- initial data checks
   if(m_hilo_period<=0)
     {
      printf(__FUNCTION__+": period HILO must be greater than 0");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool CSignalHILO::InitIndicators(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize HILO indicator
   if(!InitHILO(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize HILO indicators.                                        |
//+------------------------------------------------------------------+
bool CSignalHILO::InitHILO(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- add object to collection
   if(!indicators.Add(GetPointer(m_hilo)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- set parameters of the indicator
   MqlParam parameters[3];
//---
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="::Indicators\\HILO.ex5";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=m_hilo_period;
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=m_hilo_method;

//--- initialize object
   if(!m_hilo.Create(m_symbol.Name(),m_period,IND_CUSTOM,3,parameters))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalHILO::LongCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//--- analyze positional relationship of the close price and the indicator at the first analyzed bar
   if(Trend(idx)>0.0)
     {
      //--- the close price is above the indicator (the indicator has no objections to buying)
      if(IS_PATTERN_USAGE(0))
         if(m_signal_mode==3 || m_signal_mode==1)
            result=m_pattern_0;

      if(DiffTrend(idx)!=0)
        {
         //--- if the model 2 is used
         if(IS_PATTERN_USAGE(1) && (m_signal_mode==1 || m_signal_mode==2))
           {
            //--- the open price is below the indicator (i.e. there was an intersection)
            result=m_pattern_1;

           }
        }
      else
        {
         //--- if the model 3 is used and the open price is above the indicator
         if(IS_PATTERN_USAGE(2) && DiffLowHI(idx)<0.0 && (m_signal_mode==1 || m_signal_mode==2))
           {
            //--- the low price is below the indicator
            result=m_pattern_2;
           }
        }
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalHILO::ShortCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//--- analyze positional relationship of the close price and the indicator at the first analyzed bar
   if(Trend(idx)<0.0)
     {
      //--- the close price is below the indicator (the indicator has no objections to buying)
      if(IS_PATTERN_USAGE(0))
         if(m_signal_mode==3 || m_signal_mode==1)
            result=m_pattern_0;

      if(DiffTrend(idx)!=0)
        {
         //--- if the model 2 is used
         if(IS_PATTERN_USAGE(1) && (m_signal_mode==1 || m_signal_mode==2))
           {
            //--- the open price is above the indicator (i.e. there was an intersection)
            result=m_pattern_1;

           }
        }
      else
        {
         //--- if the model 3 is used and the open price is below the indicator
         if(IS_PATTERN_USAGE(2) && DiffHighLO(idx)>0.0 && (m_signal_mode==1 || m_signal_mode==2))
           {
            //--- the high price is above the indicator
            result=m_pattern_2;

           }
        }
     }
//--- return the result
   return(result);
  }

//+------------------------------------------------------------------+
