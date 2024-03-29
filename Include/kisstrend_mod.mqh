//+------------------------------------------------------------------+
//| Version 01 (03-Feb-2018):                                        |
//|   01(a) Calling input parameters optimized, ind_candles_V01 indi |
//+------------------------------------------------------------------+
#include <Indicators\Indicator.mqh>
//+------------------------------------------------------------------+
enum DATE_TYPE 
  {
   DAILY,
   WEEKLY,
   MONTHLY
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum PRICE_TYPE 
  {
   OPEN,
   CLOSE,
   HIGH,
   LOW,
   OPEN_CLOSE,
   HIGH_LOW,
   CLOSE_HIGH_LOW,
   OPEN_CLOSE_HIGH_LOW
  };


//+------------------------------------------------------------------+
class CiVelas : public CIndicator
  {
protected:
 ENUM_TIMEFRAMES m_periodo;
 bool m_Media1;// Usar Media 1
 bool m_Media2;// Usar Media 2
 bool m_Media3;// Usar Media 3
 bool m_Media4;// Usar Media 4
 bool m_Media5;// Usar Media 5
 //
 bool m_Media6;// Usar Media 6
 bool m_Media7;// Usar Media 7
 bool m_Media8;// Usar Media 8
 bool m_Media9;// Usar Media 9
 bool m_Media10;// Usar Media 10
 //
 bool m_Media11;// Usar Media 11
 bool m_Media12;// Usar Media 12
 bool m_Media13;// Usar Media 13
 bool m_Media14;// Usar Media 14
 bool m_Media15;// Usar Media 15
 //
 
 bool m_ATRSTOP;// Usar ATRSTOP
 bool m_Plot_atr;//Plotar ATRSTOP
 uint m_Length;           // Indicator period
 uint m_ATRPeriod;         // Period of ATR
 double m_Kv;              // Volatility by ATR
 int m_Shift;       // Shift
 bool m_Usar_VWAP; //Usar VWAP
 bool m_Plot_VWAP;//Plotar VWAP
 PRICE_TYPE  m_Price_Type;
 bool m_Calc_Every_Tick;
 bool m_Enable_Daily;
 bool m_Show_Daily_Value;
 bool m_Enable_Weekly;
 bool m_Show_Weekly_Value;
 bool m_Enable_Monthly;
 bool m_Show_Monthly_Value;
 bool m_Usar_Hilo;// Usar Hilo
 bool m_Plot_hilo;//Plotar hilo
 int m_period_hilo;//Periodo Hilo
 int m_shift_hilo;// Deslocar Hilo
 
public:
                     CiVelas(void);
                    ~CiVelas(void);
   //--- methods of access to protected data
   //int               Depth(void)          const { return(m_depth);      }
   //int               Deviation(void)      const { return(m_deviation);  }
   //int               Backstep(void)       const { return(m_backstep);   }
   //--- method of creation
 bool Create(const string symbol,const ENUM_TIMEFRAMES period,
 const bool Media1,
 const bool Media2,
 const bool Media3,
 const bool Media4,
 const bool Media5,
 const bool Media6,
 const bool Media7,
 const bool Media8,
 const bool Media9,
 const bool Media10,
 const bool Media11,
 const bool Media12,
 const bool Media13,
 const bool Media14,
 const bool Media15,
 const bool ATRSTOP,
 const bool Plot_atr,const uint Length,const uint ATRPeriod,const double Kv,const int Shift,
 const bool Usar_VWAP,const bool Plot_VWAP,const PRICE_TYPE Price_Type,
 const bool Calc_Every_Tick,const bool Enable_Daily,const bool Show_Daily_Value,const bool Enable_Weekly,
 const bool Show_Weekly_Value,const bool Enable_Monthly,const bool Show_Monthly_Value,const bool Usar_Hilo,
 const bool Plot_hilo,const int period_hilo,const int shift_hilo);

   //--- methods of access to indicator data
   double            CorVela(const int index) const;
   //--- method of identifying
   virtual int       Type(void) const { return(IND_CUSTOM); }

protected:
   //--- methods of tuning
 bool Initialize(const string symbol,const ENUM_TIMEFRAMES period,
 const bool Media1,
 const bool Media2,
 const bool Media3,
 const bool Media4,
 const bool Media5,
 const bool Media6,
 const bool Media7,
 const bool Media8,
 const bool Media9,
 const bool Media10,
 const bool Media11,
 const bool Media12,
 const bool Media13,
 const bool Media14,
 const bool Media15,
 const bool ATRSTOP,
 const bool Plot_atr,const uint Length,const uint ATRPeriod,const double Kv,const int Shift,
 const bool Usar_VWAP,const bool Plot_VWAP,const PRICE_TYPE Price_Type,
 const bool Calc_Every_Tick,const bool Enable_Daily,const bool Show_Daily_Value,const bool Enable_Weekly,
 const bool Show_Weekly_Value,const bool Enable_Monthly,const bool Show_Monthly_Value,const bool Usar_Hilo,
 const bool Plot_hilo,const int period_hilo,const int shift_hilo);
                        
                                
                                
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CiVelas::CiVelas(void) : 
m_periodo(PERIOD_CURRENT),m_Media1(true),
 m_Media2(false),
 m_Media3(false),
 m_Media4(false),
 m_Media5(false),
 m_Media6(false),
 m_Media7(false),
 m_Media8(false),
 m_Media9(false),
 m_Media10(false),
 m_Media11(false),
 m_Media12(false),
 m_Media13(false),
 m_Media14(false),
 m_Media15(false),
 m_ATRSTOP(false),
 m_Plot_atr(false),m_Length(10),m_ATRPeriod(5),m_Kv(2.5),m_Shift(0),
  m_Usar_VWAP(false),m_Plot_VWAP(false),m_Price_Type(CLOSE),
  m_Calc_Every_Tick(false),m_Enable_Daily(false),m_Show_Daily_Value(false),
  m_Enable_Weekly(false),m_Show_Weekly_Value(false),m_Enable_Monthly(false),
  m_Show_Monthly_Value(false),m_Usar_Hilo(false),m_Plot_hilo(false),
  m_period_hilo(14),m_shift_hilo(0)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CiVelas::~CiVelas(void)
  {
  ChartIndicatorDelete(ChartID(),0,"KISS TREND INDICATOR MOD"); // remoção do indicador
  IndicatorRelease(m_handle);
  }
//+------------------------------------------------------------------+
//| Create indicator "Velas"                                       |
//+------------------------------------------------------------------+
bool CiVelas::Create(const string symbol,const ENUM_TIMEFRAMES period,
 const bool Media1,
 const bool Media2,
 const bool Media3,
 const bool Media4,
 const bool Media5,
 const bool Media6,
 const bool Media7,
 const bool Media8,
 const bool Media9,
 const bool Media10,
 const bool Media11,
 const bool Media12,
 const bool Media13,
 const bool Media14,
 const bool Media15,
 const bool ATRSTOP,
 const bool Plot_atr,const uint Length,const uint ATRPeriod,const double Kv,const int Shift,
 const bool Usar_VWAP,const bool Plot_VWAP,const PRICE_TYPE Price_Type,
 const bool Calc_Every_Tick,const bool Enable_Daily,const bool Show_Daily_Value,const bool Enable_Weekly,
 const bool Show_Weekly_Value,const bool Enable_Monthly,const bool Show_Monthly_Value,const bool Usar_Hilo,
 const bool Plot_hilo,const int period_hilo,const int shift_hilo)

  {
//--- check history
   if(!SetSymbolPeriod(symbol,period))
      return(false);
//--- create
   m_handle=iCustom(symbol,period,"KISS TREND INDICATOR MOD",period,
   Media1,
   Media2,
   Media3,
   Media4,
   Media5,
   Media6,
   Media7,
   Media8,
   Media9,
   Media10,
   Media11,
   Media12,
   Media13,
   Media14,
   Media15,
   ATRSTOP,
Plot_atr,Length,ATRPeriod,Kv,Shift,Usar_VWAP,Plot_VWAP,Price_Type,
Calc_Every_Tick,Enable_Daily,Show_Daily_Value,Enable_Weekly,
Show_Weekly_Value,Enable_Monthly,Show_Monthly_Value,Usar_Hilo,
Plot_hilo,period_hilo,shift_hilo);
//--- check result
   if(m_handle==INVALID_HANDLE)
      return(false);
//--- indicator successfully created
   if(!Initialize(symbol,period,
   Media1,
   Media2,
   Media3,
   Media4,
   Media5,
   Media6,
   Media7,
   Media8,
   Media9,
   Media10,
   Media11,
   Media12,
   Media13,
   Media14,
   Media15,
   ATRSTOP,
Plot_atr,Length,ATRPeriod,Kv,Shift,Usar_VWAP,Plot_VWAP,Price_Type,
Calc_Every_Tick,Enable_Daily,Show_Daily_Value,Enable_Weekly,
Show_Weekly_Value,Enable_Monthly,Show_Monthly_Value,Usar_Hilo,
Plot_hilo,period_hilo,shift_hilo))
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
bool CiVelas::Initialize(const string symbol,const ENUM_TIMEFRAMES period,
 const bool Media1,
 const bool Media2,
 const bool Media3,
 const bool Media4,
 const bool Media5,
 const bool Media6,
 const bool Media7,
 const bool Media8,
 const bool Media9,
 const bool Media10,
 const bool Media11,
 const bool Media12,
 const bool Media13,
 const bool Media14,
 const bool Media15,
 const bool ATRSTOP,
 const bool Plot_atr,const uint Length,const uint ATRPeriod,const double Kv,const int Shift,
 const bool Usar_VWAP,const bool Plot_VWAP,const PRICE_TYPE Price_Type,
 const bool Calc_Every_Tick,const bool Enable_Daily,const bool Show_Daily_Value,const bool Enable_Weekly,
 const bool Show_Weekly_Value,const bool Enable_Monthly,const bool Show_Monthly_Value,const bool Usar_Hilo,
 const bool Plot_hilo,const int period_hilo,const int shift_hilo)
  {
   if(CreateBuffers(symbol,period,5))
     {
      //--- string of status of drawing
      m_name="KISS TREND INDICATOR MOD";
      m_status="("+symbol+","+PeriodDescription()+","+") H="+IntegerToString(m_handle);
         
      //--- save settings
      
 m_periodo=period;
 m_Media1=Media1;
 m_Media2=Media2;
 m_Media3=Media3;
 m_Media4=Media4;
 m_Media5=Media5;
 //
 m_Media6=Media6;
 m_Media7=Media7;
 m_Media8=Media8;
 m_Media9=Media9;
 m_Media10=Media10;
 //
 m_Media11=Media11;
 m_Media12=Media12;
 m_Media13=Media13;
 m_Media14=Media14;
 m_Media15=Media15;
 //
 //
 m_ATRSTOP=ATRSTOP;
 m_Plot_atr=Plot_atr;
 m_Length=Length;           
 m_ATRPeriod=ATRPeriod;        
 m_Kv=Kv;              
 m_Shift=Shift;       
 m_Usar_VWAP=Usar_VWAP;
 m_Plot_VWAP=Plot_VWAP;
 m_Price_Type=Price_Type;
 m_Calc_Every_Tick=Calc_Every_Tick;
 m_Enable_Daily=Enable_Daily;
 m_Show_Daily_Value=Show_Daily_Value;
 m_Enable_Weekly=Enable_Weekly;
 m_Show_Weekly_Value=Show_Weekly_Value;
 m_Enable_Monthly=Enable_Monthly;
 m_Show_Monthly_Value=Show_Monthly_Value;
 m_Usar_Hilo=Usar_Hilo;
 m_Plot_hilo=Plot_hilo;
 m_period_hilo=period_hilo;
 m_shift_hilo=shift_hilo;
 
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
//| Access to Cor da Vela buffer of "ind_candles_V01"                             |
//+------------------------------------------------------------------+
double CiVelas::CorVela(const int index)const
  {
   CIndicatorBuffer *buffer=At(4);
//--- check
   if(buffer==NULL)
      return(EMPTY_VALUE);
//---
   return(buffer.At(index));
  }
//+------------------------------------------------------------------+
