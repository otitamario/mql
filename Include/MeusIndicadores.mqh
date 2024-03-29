
//+------------------------------------------------------------------+
#include <Indicators\Indicator.mqh>
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Class CiBBPercent.                                                   |
//| Purpose: Class of the "Bollinger Bands Percent" indicator.               |
//|          Derives from class CIndicator.                          |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
class CiBBPercent : public CIndicator
  {
protected:
   int               m_ma_period;
   int               m_ma_shift;
   double            m_deviation;
   int               m_applied;
   

public:
                     CiBBPercent(void);
                    ~CiBBPercent(void);
  //--- methods of access to protected data
   int               MaPeriod(void)         const { return(m_ma_period); }
   int               MaShift(void)          const { return(m_ma_shift);  }
   double            Deviation(void)        const { return(m_deviation); }
   int               Applied(void)          const { return(m_applied);   }
   //--- method of creation
   bool              Create(const string symbol,const ENUM_TIMEFRAMES period,
                            const int ma_period,const int ma_shift,
                            const double deviation,const int applied);

   //--- methods of access to indicator data
   double            Main(const int index) const;
   //--- method of identifying
   virtual int       Type(void) const { return(IND_CUSTOM); }

protected:
   //--- methods of tuning
   bool              Initialize(const string symbol,const ENUM_TIMEFRAMES period,
                                const int ma_period,const int ma_shift,
                                const double deviation,const int applied);

                         
                                
                                
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CiBBPercent::CiBBPercent(void) : 
                         m_ma_period(-1),
                         m_ma_shift(-1),
                         m_deviation(EMPTY_VALUE),
                         m_applied(-1)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CiBBPercent::~CiBBPercent(void)
  {
  IndicatorRelease(m_handle);
  
  }
//+------------------------------------------------------------------+
//| Create indicator "Velas"                                       |
//+------------------------------------------------------------------+
bool CiBBPercent::Create(const string symbol,const ENUM_TIMEFRAMES period,
                            const int ma_period,const int ma_shift,
                            const double deviation,const int applied)

  {
//--- check history
   if(!SetSymbolPeriod(symbol,period))
      return(false);
//--- create
   m_handle=iCustom(symbol,period,"Bollinger_bands_1b",ma_period,ma_shift,deviation,applied);
//--- check result
   if(m_handle==INVALID_HANDLE)
      return(false);
//--- indicator successfully created
   if(!Initialize(symbol,period,ma_period,ma_shift,deviation,applied))
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





//+------------------------------------------------------------------+
//| Initialize indicator with the special parameters                 |
//+------------------------------------------------------------------+
bool CiBBPercent::Initialize(const string symbol,const ENUM_TIMEFRAMES period,
                         const int ma_period,const int ma_shift,
                         const double deviation,const int applied)
  
  {
   if(CreateBuffers(symbol,period,1))
     {
      //--- string of status of drawing
      m_name="BB_percent";
      m_status="("+symbol+","+PeriodDescription()+","+") H="+IntegerToString(m_handle);
         
      //--- save settings
      
      m_ma_period=ma_period;
      m_ma_shift =ma_shift;
      m_deviation=deviation;
      m_applied  =applied;
      
//--- create buffers
((CIndicatorBuffer*)At(0)).Name("Bollinger bands %b");
 
      
//--- ok
  return(true);
}
//--- error
   return(false);
}
//+------------------------------------------------------------------+
//| Access to Bollinger Bands Percent buffer                         |
//+------------------------------------------------------------------+
double CiBBPercent::Main(const int index)const
  {
   CIndicatorBuffer *buffer=At(0);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

// Bollinger Bands Width


class CiBBWidth : public CIndicator
  {
protected:
   int               m_ma_period;
   int               m_ma_shift;
   double            m_deviation;
   

public:
                     CiBBWidth(void);
                    ~CiBBWidth(void);
  //--- methods of access to protected data
   int               MaPeriod(void)         const { return(m_ma_period); }
   int               MaShift(void)          const { return(m_ma_shift);  }
   double            Deviation(void)        const { return(m_deviation); }
   //--- method of creation
   bool              Create(const string symbol,const ENUM_TIMEFRAMES period,
                            const int ma_period,const int ma_shift,
                            const double deviation);

   //--- methods of access to indicator data
   double            Main(const int index) const;
   //--- method of identifying
   virtual int       Type(void) const { return(IND_CUSTOM); }

protected:
   //--- methods of tuning
   bool              Initialize(const string symbol,const ENUM_TIMEFRAMES period,
                                const int ma_period,const int ma_shift,
                                const double deviation);

                         
                                
                                
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CiBBWidth::CiBBWidth(void) : 
                         m_ma_period(-1),
                         m_ma_shift(-1),
                         m_deviation(EMPTY_VALUE)
                     
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CiBBWidth::~CiBBWidth(void)
  {
  IndicatorRelease(m_handle);
  
  }
//+------------------------------------------------------------------+
//| Create indicator "Velas"                                       |
//+------------------------------------------------------------------+
bool CiBBWidth::Create(const string symbol,const ENUM_TIMEFRAMES period,
                            const int ma_period,const int ma_shift,
                            const double deviation)

  {
//--- check history
   if(!SetSymbolPeriod(symbol,period))
      return(false);
//--- create
   m_handle=iCustom(symbol,period,"bbandwidth",ma_period,ma_shift,deviation);
//--- check result
   if(m_handle==INVALID_HANDLE)
      return(false);
//--- indicator successfully created
   if(!Initialize(symbol,period,ma_period,ma_shift,deviation))
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





//+------------------------------------------------------------------+
//| Initialize indicator with the special parameters                 |
//+------------------------------------------------------------------+
bool CiBBWidth::Initialize(const string symbol,const ENUM_TIMEFRAMES period,
                         const int ma_period,const int ma_shift,
                         const double deviation)
  
  {
   if(CreateBuffers(symbol,period,1))
     {
      //--- string of status of drawing
      m_name="BB_percent";
      m_status="("+symbol+","+PeriodDescription()+","+") H="+IntegerToString(m_handle);
         
      //--- save settings
      
      m_ma_period=ma_period;
      m_ma_shift =ma_shift;
      m_deviation=deviation;
      
      
//--- create buffers
((CIndicatorBuffer*)At(0)).Name("Bollinger bands Width");
 
      
//--- ok
  return(true);
}
//--- error
   return(false);
}
//+------------------------------------------------------------------+
//| Access to Bollinger Bands Percent buffer                         |
//+------------------------------------------------------------------+
double CiBBWidth::Main(const int index)const
  {
   CIndicatorBuffer *buffer=At(0);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
class CiVelasExp : public CIndicator
  {
protected:
 int m_periodo1;// Periodo Media 1
 int m_periodo2;//Periodo Media 2
   

public:
                     CiVelasExp(void);
                    ~CiVelasExp(void);
   //--- methods of access to protected data
   //int               Depth(void)          const { return(m_depth);      }
   //int               Deviation(void)      const { return(m_deviation);  }
   //int               Backstep(void)       const { return(m_backstep);   }
   //--- method of creation
 bool Create(const string symbol,const ENUM_TIMEFRAMES period,const int periodo1,const int periodo2);

   //--- methods of access to indicator data
   double            CorVela(const int index) const;
   //--- method of identifying
   virtual int       Type(void) const { return(IND_CUSTOM); }

protected:
   //--- methods of tuning
 bool Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int periodo1,const int periodo2);
                        
                                
                                
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CiVelasExp::CiVelasExp(void) : 
m_periodo1(9),m_periodo2(10)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CiVelasExp::~CiVelasExp(void)
  {
  ChartIndicatorDelete(ChartID(),0,"velas exponenciais"); // remoção do indicador
  IndicatorRelease(m_handle);
  
  }
//+------------------------------------------------------------------+
//| Create indicator "Velas"                                       |
//+------------------------------------------------------------------+
bool CiVelasExp::Create(const string symbol,const ENUM_TIMEFRAMES period,const int periodo1,const int periodo2)

  {
//--- check history
   if(!SetSymbolPeriod(symbol,period))
      return(false);
//--- create
   m_handle=iCustom(symbol,period,"velas_exponenciais",periodo1,periodo2);
//--- check result
   if(m_handle==INVALID_HANDLE)
      return(false);
//--- indicator successfully created
   if(!Initialize(symbol,period,periodo1,periodo2))
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





//+------------------------------------------------------------------+
//| Initialize indicator with the special parameters                 |
//+------------------------------------------------------------------+
bool CiVelasExp::Initialize(const string symbol,const ENUM_TIMEFRAMES period,const int periodo1, const int periodo2)
  {
   if(CreateBuffers(symbol,period,5))
     {
      //--- string of status of drawing
      m_name="velas exponenciais";
      m_status="("+symbol+","+PeriodDescription()+","+") H="+IntegerToString(m_handle);
         
      //--- save settings
      
 m_periodo1=periodo1;
 m_periodo2=periodo2;

//--- create buffers
((CIndicatorBuffer*)At(0)).Name("Open");
((CIndicatorBuffer*)At(1)).Name("High");
((CIndicatorBuffer*)At(2)).Name("Low");
((CIndicatorBuffer*)At(3)).Name("Close");
((CIndicatorBuffer*)At(4)).Name("Cor da Vela");
 
      
//--- ok
  return(true);
}
//--- error
   return(false);
}
//+------------------------------------------------------------------+
//| Access to Cor da Vela buffer of "velas_coloridas"                             |
//+------------------------------------------------------------------+
double CiVelasExp::CorVela(const int index)const
  {
   CIndicatorBuffer *buffer=At(4);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }
//+------------------------------------------------------------------+
