//+------------------------------------------------------------------+
//|                                                    CisNewBar.mqh |
//|                                            Copyright 2010, Lizar |
//|                                               Lizar-2010@mail.ru |
//|                                              Revision 2010.09.27 |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Class CisNewBar.                                                 |
//| Appointment: Class with methods of detecting new bars            |
//+------------------------------------------------------------------+
class CisNewBar
  {
protected:
   datetime          m_lastbar_time;   // Opening time of the last bar

   string            m_symbol;         // Symbol name
   ENUM_TIMEFRAMES   m_period;         // Chart timeframe

   uint              m_retcode;        // Result code of detecting new bar 
   int               m_new_bars;       // Number of new bars
   string            m_comment;        // Comment of execution

public:
   void              CisNewBar();      // CisNewBar constructor  
   void              operator=(const CisNewBar &_src_new_bar);

   //--- Methods of access to protected data:
   uint              GetRetCode() const      {return(m_retcode);     }  // Result code of detecting new bar 
   datetime          GetLastBarTime() const  {return(m_lastbar_time);}  // Time of opening new bar
   int               GetNewBars() const      {return(m_new_bars);    }  // Number of new bars
   string            GetComment() const      {return(m_comment);     }  // Execution comment
   string            GetSymbol() const       {return(m_symbol);      }  // Symbol name
   ENUM_TIMEFRAMES   GetPeriod() const       {return(m_period);      }  // Chart timeframe
   //--- Methods of initializing of protected data:
   void              SetLastBarTime(datetime lastbar_time){m_lastbar_time=lastbar_time;                            }
   void              SetSymbol(string symbol)             {m_symbol=(symbol==NULL || symbol=="")?Symbol():symbol;  }
   void              SetPeriod(ENUM_TIMEFRAMES period)    {m_period=(period==PERIOD_CURRENT)?Period():period;      }
   //--- Methods of a new bar detection:
   bool              isNewBar(datetime new_Time);                       // First type of request for new bar
   int               isNewBar();                                        // Second type of request for new bar 
  };
//+------------------------------------------------------------------+
//| CisNewBar constructor.                                           |
//| INPUT:  no.                                                      |
//| OUTPUT: no.                                                      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
void CisNewBar::CisNewBar()
  {
   m_retcode=0;         // Result code of detecting a new bar 
   m_lastbar_time=0;    // Opening time of the last bar
   m_new_bars=0;        // Number of new bars
   m_comment="";        // Comment of execution
   m_symbol=Symbol();   // Symbol name, by default the symbol of the current chart
   m_period=Period();   // Chart timeframe, by default the symbol of the current chart    
  }
//+------------------------------------------------------------------+
//| Assignment operator                                            |
//+------------------------------------------------------------------+
void CisNewBar:: operator=(const CisNewBar &_src_new_bar)
  {
   m_lastbar_time=_src_new_bar.m_lastbar_time;   // Opening time of the last bar
   m_symbol=_src_new_bar.m_symbol;               // Symbol name
   m_period=_src_new_bar.m_period;               // Chart timeframe
   m_retcode=_src_new_bar.m_retcode;             // Result code of detecting a new bar 
   m_new_bars=_src_new_bar.m_new_bars;           // Number of new bars
   m_comment=_src_new_bar.m_comment;             // Comment of execution
  }
//+------------------------------------------------------------------+
//| First type of request for a new bar.                     |
//| INPUT:  newbar_time - time of opening (hypothetically) new bar|
//| OUTPUT: true   - if new bar(s) appeared                          |
//|         false  - if there is no new bar or in case of error      |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
bool CisNewBar::isNewBar(datetime newbar_time)
  {
//--- Initialization of protected variables
   m_new_bars = 0;      // Number of new bars
   m_retcode  = 0;      // Result code of detecting a new bar: 0 - no error encountered
   m_comment  =__FUNCTION__+" Successful check for a new bar";
//---

//--- Just to be sure, check: is the time of (hypothetically) new bar m_newbar_time less than time of last bar m_lastbar_time? 
   if(m_lastbar_time>newbar_time)
     { // If the new bar is older than the last bar, then print an error message
      m_comment=__FUNCTION__+" Synchronization error: time of the previous bar "+TimeToString(m_lastbar_time)+
                ", time of new bar request "+TimeToString(newbar_time);
      m_retcode=-1;     // Result code of detecting a new bar: return -1 - synchronization error
      return(false);
     }
//---

//--- if it's the first call 
   if(m_lastbar_time==0)
     {
      m_lastbar_time=newbar_time; //--- set time of last bar and exit
      m_comment=__FUNCTION__+" Initialization of lastbar_time="+TimeToString(m_lastbar_time);
      return(false);
     }
//---

//--- Check for a new bar: 
   if(m_lastbar_time<newbar_time)
     {
      m_new_bars=1;               // Number of new bars
      m_lastbar_time=newbar_time; // remember time of last bar
      return(true);
     }
//---

//--- if we made it to this point, then the bar is not new or error encountered, return false
   return(false);
  }
//+------------------------------------------------------------------+
//| Second type of the new bar query.                     |
//| INPUT:  no.                                                      |
//| OUTPUT: m_new_bars - Number of new bars                          |
//| REMARK: no.                                                      |
//+------------------------------------------------------------------+
int CisNewBar::isNewBar()
  {
   datetime newbar_time;
   datetime lastbar_time=m_lastbar_time;

//--- Query the opening time of the last bar:
   ResetLastError(); // Set the value of the predefined variable _LastError to zero.
   if(!SeriesInfoInteger(m_symbol,m_period,SERIES_LASTBAR_DATE,newbar_time))
     { // If request has failed, print error message:
      m_retcode=GetLastError();  // Result code of detecting new bar: write value of variable _LastError
      m_comment=__FUNCTION__+" Error when getting time of last bar opening: "+IntegerToString(m_retcode);
      return(0);
     }
//---

//---Next use first type of request for new bar, to complete analysis:
   if(!isNewBar(newbar_time)) return(0);

//---Correct number of new bars:
   m_new_bars=Bars(m_symbol,m_period,lastbar_time,newbar_time)-1;

//--- if we've reached this line - then there is(are) new bar(s), return their number:
   return(m_new_bars);
  }
//+------------------------------------------------------------------+
