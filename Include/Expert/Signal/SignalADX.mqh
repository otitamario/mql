//+------------------------------------------------------------------+
//|                                                    SignalCCI.mqh |
//|                   Copyright 2009-2013, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signals of oscilator 'ADX'                                 |
//| Type=SignalAdvanced                                              |
//| Name=Average Directional Index                                                         |
//| ShortName=ADX                                                    |
//| Class=CSignalADX                                                 |
//| Parameter=PeriodADX,int,14,Period of calculation                 |
//| Parameter=MIN_ADX,double,20.0,ADX minimo                       |
//| Parameter=Pattern_0,int,30,peso padrao 0   |

//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalADX.                                                |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'ADX' oscillator.                                   |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
class CSignalADX : public CExpertSignal
  {
protected:
   CiADX             m_adx;            // object-oscillator
   //--- adjusted parameters
   int               m_PeriodADX;      // the "period of calculation" parameter of the oscillator
   //--- "weights" of market models (0-100)
   int               m_pattern_0;      // model 0 "the oscillator has required direction"
   //variables
   double            ADX_minimum;      //Valor Minimo ADX

public:
                     CSignalADX(void);
                    ~CSignalADX(void);
   //--- methods of setting adjustable parameters
   void              PeriodADX(int value)              { m_PeriodADX=value;           }
   //--- methods of adjusting "weights" of market models
   void              Pattern_0(int value)              { m_pattern_0=value;           }
   //---Ajustar ADX minimo
   void              MIN_ADX(double value)            {ADX_minimum=value;}
  
   //--- method of verification of settings
   virtual bool      ValidationSettings(void);
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- methods of checking if the market models are formed
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);

protected:
   //--- method of initialization of the oscillator
   bool              InitADX(CIndicators *indicators);
   //--- methods of getting data
   double            ADX(int ind)                      { return(m_adx.Main(ind));     }
   double            Diff(int ind)                     { return(ADX(ind)-ADX(ind+1)); }
   double            Diff_PLUS(int ind)                     { return(ADX_PLUS(ind)-ADX_PLUS(ind+1)); }
   double            Diff_MINUS(int ind)                     { return(ADX_MINUS(ind)-ADX_MINUS(ind+1)); }

   double            ADX_PLUS(int ind)                      { return(m_adx.Plus(ind));     }
   double            ADX_MINUS(int ind)                      { return(m_adx.Minus(ind));     }
                
   

  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalADX::CSignalADX(void) : m_PeriodADX(21),
                               m_pattern_0(30),
                               ADX_minimum(20.0)
                              
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_HIGH+USE_SERIES_LOW;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalADX::~CSignalADX(void)
  {
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CSignalADX::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//--- initial data checks
   if(m_PeriodADX<=0)
     {
      printf(__FUNCTION__+": period of the CCI oscillator must be greater than 0");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool CSignalADX::InitIndicators(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize CCI oscillator
   if(!InitADX(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize CCI oscillators.                                      |
//+------------------------------------------------------------------+
bool CSignalADX::InitADX(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- add object to collection
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
//| "Voting" that price will grow.                                   |
//+------------------------------------------------------------------+
int CSignalADX::LongCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//---
    if(ADX(idx)>ADX_minimum)
     {
      //--- if the model 0 is used, search for a reverse of the oscillator downwards behind the level of overbuying
      if(IS_PATTERN_USAGE(0) && (Diff_PLUS(idx+1)>0.0||Diff_MINUS(idx+1)<0.0))
         result=m_pattern_0;      // signal number 0
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalADX::ShortCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
//---
   if(ADX(idx)>ADX_minimum)
     {
      //--- if the model 0 is used, search for a reverse of the oscillator downwards behind the level of overbuying
      if(IS_PATTERN_USAGE(0) && (Diff_MINUS(idx+1)>0.0||Diff_PLUS(idx+1)<0.0))
         result=m_pattern_0;      // signal number 0
     }
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
