//+------------------------------------------------------------------+
//|                                                   SignalDIDI.mqh |
//|                                      Copyright 2016, Genes Luna. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=DIDI Index Signal                                          |
//| Type=SignalAdvanced                                              |
//| Name=DIDI Index                                                  |
//| ShortName=DIDI                                                   |
//| Class=CSignalDIDI                                                |
//| Page=signal_didi                                                 |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalDIDI.                                               |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'DIDI' indicator.                                   |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
class CSignalDIDI : public CExpertSignal
  {
protected:
   CiMA              m_ma3,m_ma8,m_ma20;             // object-indicator

public:
                     CSignalDIDI(void);
                    ~CSignalDIDI(void);

   //--- method of verification of settings
   virtual bool      ValidationSettings(void);
   //--- method of creating the indicator and timeseries
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- methods of checking if the market models are formed
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);

protected:
   //--- method of initialization of the indicator
   bool              InitMA(CIndicators *indicators);
   double            MA3(int ind)                         { return(m_ma3.Main(ind));     }
   double            MA8(int ind)                         { return(m_ma8.Main(ind));     }
   double            MA20(int ind)                        { return(m_ma20.Main(ind));    }
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSignalDIDI::CSignalDIDI(void)
  {
//--- initialization of protected data
   m_used_series=USE_SERIES_OPEN+USE_SERIES_HIGH+USE_SERIES_LOW+USE_SERIES_CLOSE;
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalDIDI::~CSignalDIDI(void)
  {
  }
//+------------------------------------------------------------------+
//| Validation settings protected data.                              |
//+------------------------------------------------------------------+
bool CSignalDIDI::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);

   return(true);
  }
//+------------------------------------------------------------------+
//| Create indicators.                                               |
//+------------------------------------------------------------------+
bool CSignalDIDI::InitIndicators(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- initialization of indicators and timeseries of additional filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- create and initialize MA indicator
   if(!InitMA(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize MA indicators.                                        |
//+------------------------------------------------------------------+
bool CSignalDIDI::InitMA(CIndicators *indicators)
  {
//--- check pointer
   if(indicators==NULL)
      return(false);
//--- add object to collection
   if(!indicators.Add(GetPointer(m_ma3)) || !indicators.Add(GetPointer(m_ma8)) || !indicators.Add(GetPointer(m_ma20)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- initialize object
   if(!m_ma3.Create(m_symbol.Name(),PERIOD_CURRENT,3,0,MODE_SMA,PRICE_CLOSE)||
      !m_ma8.Create(m_symbol.Name(),PERIOD_CURRENT,8,0,MODE_SMA,PRICE_CLOSE)||
      !m_ma20.Create(m_symbol.Name(),PERIOD_CURRENT,20,0,MODE_SMA,PRICE_CLOSE))
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
int CSignalDIDI::LongCondition(void)
  {
   int result=0;
   int idx   =StartIndex();

   if(MA3(idx)<Close(idx) && MA3(idx)>Open(idx) && MA8(idx)<Close(idx) && 
      MA8(idx)>Open(idx) && MA20(idx)<Close(idx) && MA20(idx)>Open(idx) && 
      MA3(idx)>MA8(idx) && MA8(idx)>MA20(idx)) result=100;
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int CSignalDIDI::ShortCondition(void)
  {
   int result=0;
   int idx   =StartIndex();

   if(MA3(idx)<Open(idx) && MA3(idx)>Close(idx) && MA8(idx)<Open(idx) && 
      MA8(idx)>Close(idx) && MA20(idx)<Open(idx) && MA20(idx)>Close(idx) && 
      MA3(idx)<MA8(idx) && MA8(idx)<MA20(idx)) result=100;

//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
