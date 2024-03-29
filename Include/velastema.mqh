
//+------------------------------------------------------------------+
#include <Indicators\Indicator.mqh>
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
class CiVTema : public CIndicator
  {
protected:
 ENUM_TIMEFRAMES m_periodo;
 bool m_Media1;// Usar Media 1
 bool m_Plot1;//Plotar Media 1
 int m_periodo1;// Periodo Media 1
 bool m_Media2;// Usar Media 2
 bool m_Plot2;//Plotar Media 2
 int m_periodo2;//Periodo Media 2
    

public:
                     CiVTema(void);
                    ~CiVTema(void);
   //--- methods of access to protected data
   //int               Depth(void)          const { return(m_depth);      }
   //int               Deviation(void)      const { return(m_deviation);  }
   //int               Backstep(void)       const { return(m_backstep);   }
   //--- method of creation
 bool Create(const string symbol,const ENUM_TIMEFRAMES period,
 const bool Media1, const bool Plot1,const int periodo1,const bool Media2,const bool Plot2,
 const int periodo2);

   //--- methods of access to indicator data
   double            CorVela(const int index) const;
   //--- method of identifying
   virtual int       Type(void) const { return(IND_CUSTOM); }

protected:
   //--- methods of tuning
 bool Initialize(const string symbol,const ENUM_TIMEFRAMES period,
 const bool Media1, const bool Plot1,const int periodo1,const bool Media2,const bool Plot2,
 const int periodo2);
                        
                                
                                
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CiVTema::CiVTema(void) : 
m_periodo(PERIOD_CURRENT),m_Media1(true),m_Plot1(true),m_periodo1(9),
 m_Media2(false),m_Plot2(false),m_periodo2(10)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CiVTema::~CiVTema(void)
  {
  ChartIndicatorDelete(ChartID(),0,"velas_tema"); // remoção do indicador
  IndicatorRelease(m_handle);
  
  }
//+------------------------------------------------------------------+
//| Create indicator "Velas"                                       |
//+------------------------------------------------------------------+
bool CiVTema::Create(const string symbol,const ENUM_TIMEFRAMES period,
 const bool Media1, const bool Plot1,const int periodo1,const bool Media2,const bool Plot2,
 const int periodo2)

  {
//--- check history
   if(!SetSymbolPeriod(symbol,period))
      return(false);
//--- create
   m_handle=iCustom(symbol,period,"velas_tema",period,Media1,Plot1,periodo1,
   Media2,Plot2,periodo2);
//--- check result
   if(m_handle==INVALID_HANDLE)
      return(false);
//--- indicator successfully created
   if(!Initialize(symbol,period,Media1,Plot1,periodo1,
   Media2,Plot2,periodo2))
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
bool CiVTema::Initialize(const string symbol,const ENUM_TIMEFRAMES period,
 const bool Media1, const bool Plot1,const int periodo1,const bool Media2,const bool Plot2,
 const int periodo2)
  {
   if(CreateBuffers(symbol,period,5))
     {
      //--- string of status of drawing
      m_name="velas_coloridas";
      m_status="("+symbol+","+PeriodDescription()+","+") H="+IntegerToString(m_handle);
         
      //--- save settings
      
 m_periodo=period;
 m_Media1=Media1;
 m_Plot1=Plot1;
 m_periodo1=periodo1;
 m_Media2=Media2;
 m_Plot2=Plot2;
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
double CiVTema::CorVela(const int index)const
  {
   CIndicatorBuffer *buffer=At(4);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }
//+------------------------------------------------------------------+
