//+------------------------------------------------------------------+
//|                                                SignalDeltaZZ.mqh |
//|                                      Copyright 2014, PunkBASSter |
//|                      https://login.mql5.com/en/users/punkbasster |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=DeltaZZ Signal Module                                      |
//| Type=SignalAdvanced                                              |
//| Name=DeltaZZ Signal Module                                       |
//| ShortName=DeltaZZ_SM                                             |
//| Class=CSignalDeltaZZ                                             |
//| Page=not used                                                    |
//| Parameter=setAppPrice,int,1, Applied price: 0 - Close, 1 - H/L   |
//| Parameter=setRevMode,int,1, Reversal mode: 0 - Pips, 1 - Percent |
//| Parameter=setPips,int,300,Reverse in pips                        |
//| Parameter=setPercent,double,0.42,Reverse in percent              |
//| Parameter=setLevels,int,2,Peaks number                           |
//| Parameter=setPattern0,double,50,Trend direction according to DZZ |
//+------------------------------------------------------------------+
// wizard description end

//+------------------------------------------------------------------+
//| Class CSignalDeltaZZ                                             |
//| Purpose: Class of generator of trend direction based on          |
//|          the 'DeltaZZ' indicator.                                |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
class CSignalDeltaZZ : public CExpertSignal
  {
protected:
   //--- indicator objects
   CiCustom          m_deltazz;           //DeltaZZ indicator object
   //--- module settings
   int               m_app_price;
   int               m_rev_mode;
   int               m_pips;
   double            m_percent;
   int               m_levels;
   double            m_pattern0;          //Trend is detected

   //--- indicator init method
   bool              InitDeltaZZ(CIndicators *indicators);
   
public:
                     CSignalDeltaZZ();
                    ~CSignalDeltaZZ();
   //--- settings adjustment methods
   void              setAppPrice(int ap)           { m_app_price=ap; }
   void              setRevMode(int rm)            { m_rev_mode=rm;  }
   void              setPips(int pips)             { m_pips=pips;    }
   void              setPercent(double perc)       { m_percent=perc; }
   void              setLevels(int rnum)           { m_levels=rnum;  }
   void              setPattern0(double p0)        { m_pattern0=p0;  }

   //--- method of settings validation
   virtual bool      ValidationSettings(void);
   //--- method of creating indicators and time series
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- main method of the module calculating price levels
   virtual double    Direction();            //the main method of the signal module based on Delta ZigZag
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSignalDeltaZZ::CSignalDeltaZZ() : m_app_price(1),
                                 m_rev_mode(0),
                                 m_pips(300),
                                 m_percent(0.5),
                                 m_levels(2)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CSignalDeltaZZ::~CSignalDeltaZZ()
  {
  }
//+------------------------------------------------------------------+
//| Validation of protected settings                                 |
//+------------------------------------------------------------------+
bool CSignalDeltaZZ::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//--- initial data checks
   if(m_app_price<0 || m_app_price>1)
     {
      printf(__FUNCTION__+": Applied price must be 0 or 1");
      return(false);
     }
   if(m_rev_mode<0 || m_rev_mode>1)
     {
      printf(__FUNCTION__+": Reversal mode must be 0 or 1");
      return(false);
     }
   if(m_pips<10)
     {
      printf(__FUNCTION__+": Number of pips in a ray must be at least 10");
      return(false);
     }
   if(m_percent<=0)
     {
      printf(__FUNCTION__+": Percent must be greater than 0");
      return(false);
     }
   if(m_levels<1)
     {
      printf(__FUNCTION__+": Levels must be at least 1");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| Indicator creation                                               |
//+------------------------------------------------------------------+
bool CSignalDeltaZZ::InitIndicators(CIndicators *indicators)
  {
//--- check of pointer is performed in the method of the parent class
//---
//--- initialization of indicators and time series of filters
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- creation and initialization of custom indicators
   if(!InitDeltaZZ(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| DeltaZZ initialization                                           |
//+------------------------------------------------------------------+
bool CSignalDeltaZZ::InitDeltaZZ(CIndicators *indicators)
  {
//--- adding an object to the collection
   if(!indicators.Add(GetPointer(m_deltazz)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- indicator parameters assignment
   MqlParam parameters[6];
//---
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="deltazigzag.ex5";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=m_app_price;
   parameters[2].type=TYPE_INT;
   parameters[2].integer_value=m_rev_mode;
   parameters[3].type=TYPE_INT;
   parameters[3].integer_value=m_pips;
   parameters[4].type=TYPE_DOUBLE;
   parameters[4].double_value=m_percent;
   parameters[5].type=TYPE_INT;
   parameters[5].integer_value=m_levels;
//--- object initialization
   if(!m_deltazz.Create(m_symbol.Name(),m_period,IND_CUSTOM,6,parameters))
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- buffers quantity
   if(!m_deltazz.NumBuffers(5)) return(false);
//--- ok
   return(true);
  }

//+------------------------------------------------------------------+
//| Signal module main function                                      |
//+------------------------------------------------------------------+
double CSignalDeltaZZ::Direction(void)
  {
   double openbuy =m_deltazz.GetData(3,0);//getting latest indicator value from buffer 3
   double opensell=m_deltazz.GetData(4,0);//getting latest indicator value from buffer 4
//---checking buy pattern
   if(openbuy>0)//if buystop level buffer in not empty
     {
      return(-m_pattern0);
     }
//---checking sell pattern
   if(opensell>0)//if sellstop level buffer is not empty
     {
      return(m_pattern0);
     }
   return(0);
  }
//+------------------------------------------------------------------+