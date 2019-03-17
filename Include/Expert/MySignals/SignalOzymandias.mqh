//+------------------------------------------------------------------+
//|                                             SignalOzymadnias.mqh |
//|                                     Copyright 2014, PunkBASSter. |
//|                      https://login.mql5.com/en/users/punkbasster |
//+------------------------------------------------------------------+
#include <Expert\ExpertSignal.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Ozymadnias                                                 |
//| Type=SignalAdvanced                                              |
//| Name=SignalOzymadnias                                            |
//| ShortName=Ozymadnias                                             |
//| Class=CSignalOzymadnias                                          |
//| Page=not used                                                    |
//| Parameter=Length,int,2,MA period                                 |
//| Parameter=Method,ENUM_MA_METHOD,MODE_SMA,Method of averaging     |
//| Parameter=Pattern_0,int,50,Weight of the right color             |
//+------------------------------------------------------------------+
// wizard description end
//+------------------------------------------------------------------+
//| Class CSignalOzymadnias                                          |
//| Purpose: Class of generator of trade signals based on            |
//|          the 'Ozymadnias' indicator.                             |
//| Is derived from the CExpertSignal class.                         |
//+------------------------------------------------------------------+
class CSignalOzymadnias : public CExpertSignal
  {
protected:
   CiCustom          m_ozymandias;     // объект-индикатор "Ozymadnias"

   int               m_length;         // ATR period
   ENUM_MA_METHOD    m_method;          // coefficient

   int               m_pattern_0;      // model 0 "the indicator has required direction"
   int               m_pattern_1;      // reserved, not used

public:
                     CSignalOzymadnias(void);
                    ~CSignalOzymadnias(void);
   //--- методы установки настраиваемых параметров
   void              Length(int value)             { m_length=value;}
   void              Method(ENUM_MA_METHOD value)  { m_method=value;}
   
   //--- методы настраивани€ "весов" рыночных моделей
   void              Pattern_0(int value)          { m_pattern_0=value;}
   //--- метод проверки настроек
   virtual bool      ValidationSettings(void);
   //--- метод создани€ индикатора и таймсерий
   virtual bool      InitIndicators(CIndicators *indicators);
   //--- методы проверки, если модели рынка сформированы
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);

protected:
   //--- метод инициализации индикатора
   bool              InitOzymandias(CIndicators *indicators);
   //--- методы получени€ данных
   //- получение значени€ индикатора
   double            Trend(int ind){return(m_ozymandias.GetData(1,ind));}

  };
//+------------------------------------------------------------------+
//|  онструктор                                                      |
//+------------------------------------------------------------------+
CSignalOzymadnias::CSignalOzymadnias(void) : m_length(2),
                                           m_method(MODE_SMA),
                                           m_pattern_0(50),
                                           m_pattern_1(0)
  {
//--- initialization of protected data
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSignalOzymadnias::~CSignalOzymadnias(void)
  {
  }
//+------------------------------------------------------------------+
//| ѕроверка параметров защищенных данных                            |
//+------------------------------------------------------------------+
bool CSignalOzymadnias::ValidationSettings(void)
  {
//--- validation settings of additional filters
   if(!CExpertSignal::ValidationSettings())
      return(false);
//--- initial data checks
   if(m_length<1)
     {
      printf(__FUNCTION__+": MA period must be greater than 0");
      return(false);
     }
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| —оздание индикаторов.                                            |
//+------------------------------------------------------------------+
bool CSignalOzymadnias::InitIndicators(CIndicators *indicators)
  {
//--- инициализаци€ индикаторов и таймсерий дополнительных фильтров
   if(!CExpertSignal::InitIndicators(indicators))
      return(false);
//--- создание и инициализаци€ пользовательского индикатора
   if(!InitOzymandias(indicators))
      return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| »нициализаци€ индикаторов.                                       |
//+------------------------------------------------------------------+
bool CSignalOzymadnias::InitOzymandias(CIndicators *indicators)
  {
//--- добавление объекта в коллекцию
   if(!indicators.Add(GetPointer(m_ozymandias)))
     {
      printf(__FUNCTION__+": error adding object");
      return(false);
     }
//--- задание параметров индикатора
   MqlParam parameters[4];
//---
   parameters[0].type=TYPE_STRING;
   parameters[0].string_value="Ozymandias_Lite.ex5";
   parameters[1].type=TYPE_INT;
   parameters[1].integer_value=m_length;
   parameters[2].type=TYPE_INT;
   parameters[2].double_value=m_method;
   parameters[3].type=TYPE_INT;
   parameters[3].double_value=0;

//--- инициализаци€ объекта
   if(!m_ozymandias.Create(m_symbol.Name(),m_period,IND_CUSTOM,4,parameters))/////maybe 0 instead of m_period
     {
      printf(__FUNCTION__+": error initializing object");
      return(false);
     }
//--- количество буферов
   if(!m_ozymandias.NumBuffers(2)) return(false);
//--- ok
   return(true);
  }
//+------------------------------------------------------------------+
//| "√олосование" за то, что цена будет расти.                       |
//+------------------------------------------------------------------+
int CSignalOzymadnias::LongCondition(void)
  {
   int result=0;
   int idx   =StartIndex();

//--- check direction of the main line

//--- pattern_0: the indicator is above zero
   if(IS_PATTERN_USAGE(0) && Trend(idx)==1)
   {
      result =MathMax(result,m_pattern_0); //choosing the maximum value to output
      //--- assign price levels if required
   }
//--- return the result
   //Print("Handle: ",m_atr_stop.Handle()," SW(i): ",DoubleToString(SW(idx),Digits()));
   return(result);
  }
//+------------------------------------------------------------------+
//| "√олосование" за то, что цена упадет.                            |
//+------------------------------------------------------------------+
int CSignalOzymadnias::ShortCondition(void)
  {
   int result=0;
   int idx   =StartIndex();
   
//--- check direction of the main line

//--- pattern_0: the indicator is below zero   
   if(IS_PATTERN_USAGE(0) && Trend(idx)==0)
   {
      result =MathMax(result,m_pattern_0); //choosing the maximum value to output
      //--- assign price levels if required
   }

//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
