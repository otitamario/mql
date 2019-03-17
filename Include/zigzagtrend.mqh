//+------------------------------------------------------------------+
//|                              Include\Indicators\Custom\Trend.mqh |
//|                  Copyright 2013, Laplacianlab - Jordi Bassagañas |
//|                     https://login.mql5.com/en/users/laplacianlab |
//+------------------------------------------------------------------+
#include <..\Include\Indicators\Indicator.mqh>
//+------------------------------------------------------------------+
//| Class CiZigZag.                                                  |
//| Purpose: Class of the "ZigZag" indicator.                        |
//|          Derives from class CIndicator.                          |
//+------------------------------------------------------------------+
class CiZigZag : public CIndicator
  {
protected:
   int               m_depth;
   int               m_deviation;
   int               m_backstep;

public:
                     CiZigZag(void);
                    ~CiZigZag(void);
   //--- methods of access to protected data
   int               Depth(void)          const { return(m_depth);      }
   int               Deviation(void)      const { return(m_deviation);  }
   int               Backstep(void)       const { return(m_backstep);   }
   //--- method of creation
   bool              Create(const string symbol,const ENUM_TIMEFRAMES period,
                            const int depth,const int deviation_create,const int backstep);
   //--- methods of access to indicator data
   double            ZigZag(const int index) const;
   double            High(const int index) const;
   double            Low(const int index) const;
   //--- method of identifying
   virtual int       Type(void) const { return(IND_CUSTOM); }

protected:
   //--- methods of tuning
   virtual bool      Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int num_params,const MqlParam &params[]);
   bool              Initialize(const string symbol,const ENUM_TIMEFRAMES period,
                                const int depth,const int deviation_init,const int backstep);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CiZigZag::CiZigZag(void) : m_depth(-1),
                         m_deviation(-1),
                         m_backstep(-1)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CiZigZag::~CiZigZag(void)
  {
  }
//+------------------------------------------------------------------+
//| Create indicator "Zig Zag"                                       |
//+------------------------------------------------------------------+
bool CiZigZag::Create(const string symbol,const ENUM_TIMEFRAMES period,
                      const int depth,const int deviation_create,const int backstep)
  {
//--- check history
   if(!SetSymbolPeriod(symbol,period))
      return(false);
//--- create
   m_handle=iCustom(symbol,period,"zigzag",depth,deviation_create,backstep);
//--- check result
   if(m_handle==INVALID_HANDLE)
      return(false);
//--- indicator successfully created
   if(!Initialize(symbol,period,depth,deviation_create,backstep))
     {
      //--- initialization failed
      IndicatorRelease(m_handle);
      m_handle=INVALID_HANDLE;
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Initialize the indicator with universal parameters               |
//+------------------------------------------------------------------+
bool CiZigZag::Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int num_params,const MqlParam &params[])
  {
   return(Initialize(symbol,period,(int)params[0].integer_value,(int)params[1].integer_value,(int)params[2].integer_value));
  }
//+------------------------------------------------------------------+
//| Initialize indicator with the special parameters                 |
//+------------------------------------------------------------------+
bool CiZigZag::Initialize(const string symbol,const ENUM_TIMEFRAMES period,
                        const int depth,const int deviation_init,const int backstep)
  {
   if(CreateBuffers(symbol,period,3))
     {
      //--- string of status of drawing
      m_name  ="ZigZag";
      m_status="("+symbol+","+PeriodDescription()+","+
               IntegerToString(depth)+","+IntegerToString(deviation_init)+","+
               IntegerToString(backstep)+") H="+IntegerToString(m_handle);
      //--- save settings
      m_depth=depth;
      m_deviation=deviation_init;
      m_backstep=backstep;       
      //--- create buffers
      ((CIndicatorBuffer*)At(0)).Name("ZIGZAG");
      ((CIndicatorBuffer*)At(1)).Name("HIGH");
      ((CIndicatorBuffer*)At(2)).Name("LOW");
      //--- ok
      return(true);
     }
//--- error
   return(false);
  }
//+------------------------------------------------------------------+
//| Access to ZigZag buffer of "Zig Zag"                             |
//+------------------------------------------------------------------+
double CiZigZag::ZigZag(const int index) const
  {
   CIndicatorBuffer *buffer=At(0);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }
//+------------------------------------------------------------------+
//| Access to High buffer of "Zig Zag"                               |
//+------------------------------------------------------------------+
double CiZigZag::High(const int index) const
  {
   CIndicatorBuffer *buffer=At(1);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }
//+------------------------------------------------------------------+
//| Access to Low buffer of "Zig Zag"                                |
//+------------------------------------------------------------------+
double CiZigZag::Low(const int index) const
  {
   CIndicatorBuffer *buffer=At(2);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }
//+------------------------------------------------------------------+
