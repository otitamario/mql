//+------------------------------------------------------------------+
//|                                                Ticks_article.mqh |
//|                                                         Tapochun |
//|                           https://www.mql5.com/en/users/tapochun |
//+------------------------------------------------------------------+
//| Description: Base class for receiving ticks								|
//+------------------------------------------------------------------+
#property copyright "Tapochun"
#property link      "https://www.mql5.com/en/users/tapochun"
#property version   "1.11"
//+------------------------------------------------------------------+
//| Global variables															      |
//+------------------------------------------------------------------+
const int MS_KOEF = 1000;					// Ratio of converting seconds into milliseconds
//+------------------------------------------------------------------+
//| Class for working with ticks													|
//+------------------------------------------------------------------+
class CTicks
   {
protected:
	 string				m_symbol;			// Symbol
	 ENUM_TIMEFRAMES	m_period;			// Timeframes
	 uint					m_flags;				// Type of received ticks
	 MqlTick				m_ticks[];			// Array - receiver of ticks
	 int					m_size;				// Tick array size
	 ulong				m_from;				// Date the ticks are requested from (ms)
	 ulong				m_to;					// Date the ticks are requested to (ms)
	 uint					m_count;				// Number of requested ticks
	 datetime			m_time;				// Opening time of the candle ticks are saved into
	 bool					m_log;				// Log maintenance flag
public:
	 //--- Get ticks 
	 bool					GetTicks();
	 bool					GetTicksRange();
	 //--- Set the class fields
	 void					SetSymbol( const string symbol )				{ m_symbol = symbol; 	}
	 void					SetPeriod( const ENUM_TIMEFRAMES period ) { m_period = period; 	}
	 void					SetFlags( const uint flags )					{ m_flags = flags; 		}
	 void					SetSize( const int size )						{ m_size = size;			}
	 void					SetSize()											{ m_size = ArraySize( m_ticks ); }
	 void					SetFrom( const long from );
	 void					SetFrom( const datetime from );
	 void					SetFrom();	
	 void					SetTo( const long to );
	 void					SetCount( const uint count )					{ m_count = count; 		}
	 void					SetTime( const datetime time )				{ m_time = time; 			}
	 bool					SetTime( const int rates_total, const datetime& time[] );
	 //--- Get the parameters
	 string				GetSymbol() const	{ return( m_symbol ); 	}
	 ENUM_TIMEFRAMES	GetPeriod() const	{ return( m_period ); 	}
	 uint					GetFlags()	const	{ return( m_flags ); 	}
	 int 					GetSize()   const { return( m_size );		}
	 ulong				GetFrom()	const	{ return( m_from ); 		}
	 ulong				GetTo() 		const { return( m_to ); 		}
	 uint					GetCount() 	const	{ return( m_count ); 	}
	 datetime 			GetTime()	const	{ return( m_time ); 		}
	 //--- Get/check the candle index by its open time
	 int					GetNumByTime( const bool asSeries ) const;
	 bool					IsNewCandle( const int num );
	 //--- Get the tick parameters
	 MqlTick				GetTick( const int num ) const				{ return( m_ticks[ num ] ); }
	 datetime			GetTickTime( const int num ) const			{ return( m_ticks[ num ].time ); }
	 double				GetTickBid( const int num ) const			{ return( m_ticks[ num ].bid ); 	}
	 double				GetTickAsk( const int num ) const			{ return( m_ticks[ num ].ask );	}
	 double				GetTickLast( const int num ) const			{ return( m_ticks[ num ].last );	}
	 ulong				GetTickVolume( const int num ) const		{ return( m_ticks[ num ].volume ); }
	 ulong				GetTickTimeMs( const int num ) const		{ return( m_ticks[ num ].time_msc ); }
	 uint					GetTickFlags( const int num ) const			{ return( m_ticks[ num ].flags ); }
	 //--- Clear the tick array
	 void					ResetTicks();
	 //--- String value of the tick time with milliseconds
	 string				GetStringTickMsTime( const long time ) const;
	 //--- String value of the tick flag
	 string				GetStringFlags() const;
	 //--- Constructors/destructors
                     CTicks() {}
                     CTicks( string symbol, ENUM_TIMEFRAMES period, uint flags, ulong from = ULONG_MAX, ulong to = ULONG_MAX, 
                     		  uint count = UINT_MAX, datetime m_time = 0, bool writeLog = false );
                    ~CTicks() {}
   };
//+------------------------------------------------------------------+
//| Set the moment ticks copying starts							         |
//+------------------------------------------------------------------+
void CTicks::SetFrom( const long from )
	{
	 //--- Save the moment the data copying starts
	 m_from = from; 
	 //--- Check if the log is maintained
	 if( m_log )
	 	 Print( __FUNCTION__,": Moment of history download start m_from is set to "+GetStringTickMsTime( m_from ) );
	}
//+------------------------------------------------------------------+
//| Set the moment the ticks copying ends							         |
//+------------------------------------------------------------------+
void CTicks::SetTo( const long to )
	{
	 //--- Save the moment the data copying ends
	 m_to = to;
	 //--- Check if the log is maintained
	 if( m_log )
	 	 Print( __FUNCTION__,": Moment of history download end m_to is set to "+GetStringTickMsTime( m_to ) );
	}
//+------------------------------------------------------------------+
//| Get the string value of the tick flag									   |
//+------------------------------------------------------------------+
string CTicks::GetStringFlags(void) const
	{
	 switch( m_flags )
	 	{
	 	 case COPY_TICKS_ALL: 	return( "ALL" );
	 	 case COPY_TICKS_INFO:	return( "INFO" );
	 	 case COPY_TICKS_TRADE:	return( "TRADE" );
	 	 default:
	 	 	 Print( __FUNCTION__,": ERROR! Unknown tick type ",m_flags );
	 	 	 return( "UNKNOWN" );
	 	}
	}
//+------------------------------------------------------------------+
//| Get candle index by its open time							            |
//+------------------------------------------------------------------+
int CTicks::GetNumByTime( const bool asSeries ) const	// Time series flag
	{
	 //--- Get the number of calculated bars (of the chart the display is performed from)
	 const int rates_total = Bars( m_symbol, m_period );
	 //--- Check if the number is correct
	 if( rates_total <= 0 )										// If the value is incorrect
	 	{
	 	 //--- Check if the log is maintained
	 	 if( m_log )												// If we maintain the log
	 	 	 Print( __FUNCTION__,": ERROR #",GetLastError(),". Bars("+m_symbol+","+EnumToString( m_period )+") returns '",rates_total,"' value" );
	 	 //--- Return -1
	 	 return( WRONG_VALUE );									
	 	}
	 //--- Get the time of the last quote for a symbol
	 const datetime stopTime = (datetime)SymbolInfoInteger( m_symbol, SYMBOL_TIME );
	 //--- Get the number of bars since the moment the m_time candle opening up to the last quote time
	 const int barsFromTo = Bars( m_symbol, m_period, m_time, stopTime );
	 //--- Check if the number is correct
	 if( barsFromTo <= 0 )										// If the value is incorrect
	 	{
	 	 //--- Check if the log is maintained
	 	 if( m_log )												// If we maintain the log
	 	 	 Print( __FUNCTION__,": ERROR #",GetLastError(),". Bars("+m_symbol+","+EnumToString( m_period )+","+TimeToString( m_time )+","+TimeToString( stopTime )+") returned '",barsFromTo,"' value" );
	 	 //--- Return -1
	 	 return( WRONG_VALUE );
	 	}
	 //--- Return the bar index by m_time
	 return( ( asSeries ) ? barsFromTo-1 : rates_total-barsFromTo );
	}
//+------------------------------------------------------------------+
//| Custom constructor													         |
//+------------------------------------------------------------------+
void CTicks::CTicks( const string symbol,
							const ENUM_TIMEFRAMES period,
							const uint flags, 
							ulong from = ULONG_MAX,
							ulong to = ULONG_MAX,
							uint count = UINT_MAX,
							datetime time = 0,
							bool writeLog = false
						 )
	{
	 m_symbol = symbol;
	 m_period = period;
	 m_flags = flags;
	 m_from = from;
	 m_to = to;
	 m_count = count;
	 m_time = time;
	 m_log = writeLog;
	 //--- Clear the tick array
	 ResetTicks();
	}
//+------------------------------------------------------------------+
//| Get ticks																	      |
//+------------------------------------------------------------------+
bool CTicks::GetTicksRange()
	{
	 //--- Check if the download limits are set
	 if( m_from == ULONG_MAX || m_to == ULONG_MAX )		// If one of the borders is not set
	 	{
	 	 Print( __FUNCTION__,": ERROR! History download start/end moments are not set: m_from = "
	 	 								+GetStringTickMsTime( m_from )+", m_to = "+GetStringTickMsTime( m_to ) );
	 	 //--- Exit with the error
	 	 return( false );
	 	}
	 //--- Preliminarily clear the tick array
	 ResetTicks();
	 //--- Reset the last error code
	 ResetLastError(); 
	 //--- Request tick history
	 int copied = CopyTicksRange( m_symbol, m_ticks, m_flags, m_from, m_to );
	 //--- Analyze the error code
	 switch( GetLastError() )					// Depending on the obtained error code
	 	{
	 	 case 0:										// If there is no error, all ticks are received
	 	 	 //--- Check how many ticks are received
	 	 	 if( copied <= 0 )					// If not more than 0 ticks are received
	 	 	 	{
	 	 	 	 Print( __FUNCTION__,": ERROR! 0 ticks received with "+GetStringTickMsTime( m_from )+" до "+GetStringTickMsTime( m_to ) );
	 	 	 	 //--- Exit with the error
	 	 	 	 return( false );
	 	 	 	}
	 	 	 //--- Save the tick array size
	       SetSize( copied );
	       //--- Check if the log is maintained
	       if( m_log )
	       	 Print( __FUNCTION__,": Received ",copied," "+GetStringFlags()+" ticks in the range "+GetStringTickMsTime( m_ticks[ 0 ].time_msc )+" to "+GetStringTickMsTime( m_ticks[ copied-1 ].time_msc ) );
	       //--- Return 'true'
	 	 	 return( true );						
	 	 case ERR_HISTORY_SMALL_BUFFER:		// If the array size is insufficient
	 	 	 Print( __FUNCTION__,": ERROR #",_LastError,": insufficient array size! Received ",copied," elements!" );
	 	 	 break;
	 	 case ERR_HISTORY_TIMEOUT:				// In case of a waiting time error
	 	 	 //--- Check if the log is maintained
	 	 	 if( m_log )
		 	 	 Print( __FUNCTION__,": ERROR #",GetLastError(),". Received ",copied," ticks. Ticks are not synchronized yet!" );
	 	 	 break;
	 	 case ERR_NOT_ENOUGH_MEMORY:			// In case of a memory error
	 	 	 Print( __FUNCTION__,": ERROR #",_LastError,": Insufficient memory for receiving the tick range from "+GetStringTickMsTime( m_from )+" to "+GetStringTickMsTime( m_to ) );
	 	 	 break;
	 	 case ERR_HISTORY_NOT_FOUND:			// If no history is found
	 	 	 break;									
	 	 default:									// In case of another error
	 	 	 Print( __FUNCTION__,": ERROR #",_LastError,": received ",copied," ticks. Ticks are not synchronized yet!" );
	 	 	 break;
	 	}
	 //--- Clear the tick array in case of an error
    ResetTicks();
	 //--- Tick history is not received yet
	 return( false );
	}
//+------------------------------------------------------------------+
//| Get ticks																	      |
//+------------------------------------------------------------------+
bool CTicks::GetTicks()
	{
	 //--- Check if the necessary copying parameters are set
	 if( m_from == ULONG_MAX || m_count == UINT_MAX )		// If the limit or the number of ticks is not set
	 	{
	 	 Print( __FUNCTION__,": ERROR! History ticks number/download start is not set: m_from = "
	 	 								+GetStringTickMsTime( m_from )+", m_count = ",m_count );
	 	 //--- Exit with the error
	 	 return( false );
	 	}
	 //--- Preliminarily clear the tick array
	 ResetTicks();
	 //--- Reset the last error code
	 ResetLastError();
	 ////--- Measure start time before receiving the ticks 
	 //const ulong start = GetMicrosecondCount(); 
	 //--- Request tick history
	 const int copied = CopyTicks( m_symbol, m_ticks, m_flags, m_from, m_count ); 
	 ////--- Calculate the time the history has been obtained in ms
	 //const ulong msc = GetMicrosecondCount() - start;
	 //--- Check the number of copied ticks
	 if( copied > 0 )										// If history is received
	   { 
	    //--- Check tick history synchronization
	    if( GetLastError() == 0 ) 					// If history is synchronized
	    	{
	       //--- Save the tick array size
	       SetSize( copied );
	       //--- Check if the log is maintained
	       if( m_log )
	       	 Print( __FUNCTION__,": Received ",copied," "+GetStringFlags()+" ticks with "+GetStringTickMsTime( m_ticks[ 0 ].time_msc )+" to "+GetStringTickMsTime( m_ticks[ copied-1 ].time_msc )+". Request ",m_count," ticks" );
	       //--- Return 'true'
	       return( true ); 								
	      }
	    else 												// If If history is out of sync - message
	    	{
          Print( __FUNCTION__,": ERROR #",_LastError,": received ",copied," ticks. Ticks are not synchronized yet!" );															
          //--- Clear the tick array
          ResetTicks();
         }
	   } 
	 else if( copied == 0 )								// If 0 ticks are received - message
	 	{
	 	 Print( __FUNCTION__,": ATTENTION! 0 ticks received. Possible incorrect from ("+
	 	 								GetStringTickMsTime( m_from )+") or count (",m_count,") parameter. Current time "+TimeToString( TimeCurrent() ) );
	 	}
	 else 													// If ticks are not received - error
	    Print( __FUNCTION__,": ERROR #",_LastError,": Ticks not received!" );
	 //--- Tick history is not received yet
	 return( false );
	}
//+------------------------------------------------------------------+
//| Set initial time of the next tick request				            |
//+------------------------------------------------------------------+
void CTicks::SetFrom()
	{
	 //--- Check the tick array size
	 if( m_size <= 0 )							// If the size is not set
	 	{
	 	 Print( __FUNCTION__,": ERROR! Tick array size = 0" );
	 	 return;										// Exit
	 	}
	 //--- Remember the time of the last tick from the array
	 m_from = m_ticks[ m_size-1 ].time_msc;
	 //--- Check if the log is maintained
	 if( m_log )
	 	 Print( __FUNCTION__,": Set the copying start time m_from = "+GetStringTickMsTime( m_from ) );
	}
//+------------------------------------------------------------------+
//| Set the moment of starting the download of history, ms			   |
//+------------------------------------------------------------------+
void CTicks::SetFrom( const datetime from )			// Time, s
	{
	 //--- Check if the time is set 
	 if( from <= 0 )											// If no time is set
	 	{ 
	 	 //--- Get the current day start time
	 	 const datetime dayOpenTime = (datetime)SeriesInfoInteger( m_symbol, PERIOD_D1, SERIES_LASTBAR_DATE );
	 	 //--- Check the day start time
	 	 if( dayOpenTime <= 0 )								// If open time is invalid
	 	 	{
	 	 	 //Print( __FUNCTION__,": ERROR! Current day open time = "+TimeToString( dayOpenTime ) );
	 	 	 //--- Download start moment = 0
	 	 	 m_from = 0;										
	 	 	 //--- Check if the log is maintained
			 if( m_log )
			 	 Print( __FUNCTION__,": ERROR! Current day start time is not received ("+TimeToString( dayOpenTime )+"). History download start moment m_from = 0!" );
	 	 	}
	 	 else 													// If open time is correct
	 	 	{
	 	 	 //--- Set the moment of starting the download of history from the start of the current day
	 	 	 m_from = dayOpenTime*MS_KOEF;				
	 	 	 //--- Check if the log is maintained
			 if( m_log )
			 	 Print( __FUNCTION__,": Moment of history download start m_from is set to the current day start "+GetStringTickMsTime( m_from ) );
	 	 	}
	 	}
	 else 														// If the time is set
	   {
	    //--- Check if it falls into the available history
	    const datetime firstDate = (datetime)SeriesInfoInteger( m_symbol, m_period, SERIES_FIRSTDATE );
	    //--- Compare data of the first available bar from 'from'
	    if( from >= firstDate )							// If the time falls within the available history
	    	{
	    	 //--- Download start time = passed time
	    	 m_from = from*MS_KOEF;							
	    	 //--- Check if the log is maintained
			 if( m_log )
			 	 Print( __FUNCTION__,": Moment of history download start m_from is set to "+GetStringTickMsTime( m_from ) );
	    	}
	    else 													// If the time does not fall within the available history
	    	{
	    	 Print( __FUNCTION__," "+m_symbol+": first date for "+EnumToString( m_period )+" = "+TimeToString( firstDate )+". Calculation for the current day only!" );
	    	 //--- History is downloaded from the start of the day
	    	 m_from = SeriesInfoInteger( m_symbol, PERIOD_D1, SERIES_LASTBAR_DATE )*MS_KOEF;
	    	}
	   }
	}
//+------------------------------------------------------------------+
//| Clear the tick array															|
//+------------------------------------------------------------------+
void CTicks::ResetTicks(void)
	{
	 //--- Clear the tick array
	 ArrayFree( m_ticks );
	 //--- Reset the saved array size
	 m_size = 0;
	 //--- Check if the log is maintained
	 if( m_log )
	 	 Print( __FUNCTION__,": Tick array cleared! Array size reset to 0!" );
	}
//+------------------------------------------------------------------+
//| Set the candle time for synchronizing ticks						      |
//+------------------------------------------------------------------+
bool CTicks::SetTime( const int rates_total, 		// Total number of calculated candles
							 const datetime& time[]			// Array of candle open times
						  )
	{
	 //--- Check the tick array size
	 if( m_size <= 0 )										// If no size is set
	 	 return( false );										// Exit
	 //--- Find time of the oldest tick
	 datetime firstTickTime = m_ticks[ 0 ].time;
	 //--- Correct the tick time on the first second
	 const int modulo = (int)( firstTickTime%PeriodSeconds( m_period ) );	// Excess
	 if( modulo > 0 )											// If the candle's first tick arrived not during the first second
	 	 firstTickTime -= modulo;							// Equate the time of the first tick to the candle opening time
	 //--- Cycle of defining the index of the first candle with the full tick history
	 for( int i = 0; i < rates_total; i++ )
	 	{
	 	 if( time[ i ] == firstTickTime )				// If the candle open time is equal to the first tick one	
	 	 	{						
	 	 	 //--- Save the candle opening time		  
	 	 	 m_time = time[ i ];	
	 	 	 //--- Check if the log is maintained
			 if( m_log )
			 	 Print( __FUNCTION__,": m_time candle opening time for "+EnumToString( m_period )+" is set = "+TimeToString( m_time )+" by the tick "+TimeToString( firstTickTime ) );
	 	 	 //---							
	 	 	 return( true );									// Exit the cycle
	 	 	}
	 	 else if( time[ i ] > firstTickTime )			// If the opening time exceeds the first tick one
	 	 	{ 
	 	 	 Print( __FUNCTION__,": ERROR! Tick time '"+TimeToString( firstTickTime, TIME_DATE|TIME_SECONDS )+
	 	 	 							"' should be equal to candle open time '"+TimeToString( time[ i ], TIME_DATE|TIME_SECONDS ) );
	 	 	 return( false );									// Exit with the error
	 	 	}
	 	}
	 //--- In case of a logic error
	 Print( __FUNCTION__,": ERROR! Candle covering the tick history not found! FirstTickTime = "+TimeToString( firstTickTime, TIME_DATE|TIME_SECONDS ) );
	 return( false );											// Exit with the error
	}
//+------------------------------------------------------------------+
//| Check the index change of the candle the ticks are saved to	   |
//+------------------------------------------------------------------+
bool CTicks::IsNewCandle( const int num )					// Checked tick index
	{
	 //--- Check the array size
	 if( m_size <= 0 )										// If no size is set
	 	 return( false );										// Return 'false'
	 //--- Check if the array index is correct
	 if( num >= m_size )										// If the tick index is out of the array range
	 	{
	 	 Print( __FUNCTION__,": ERROR! Incorrect '",num,"' tick array index passed. Array size = ",m_size );
	 	 return( false );										// Exit with the error
	 	}
	 //--- Define the open time of the next candle from the m_time time
	 const int perSec = PeriodSeconds( m_period );
	 const datetime nextTime = m_time+perSec;
	 //--- Check if the tick falls into the next candle
	 if( m_ticks[ num ].time_msc >= nextTime*MS_KOEF )	// If the tick time is out of the current candle range
	 	{
	 	 //--- Define the time of the next candle (up to seconds)
	 	 m_time = datetime( ( m_ticks[ num ].time_msc - m_ticks[ num ].time_msc%MS_KOEF )/MS_KOEF );
	 	 //--- Correct the time up to minutes
	 	 m_time = m_time - m_time%perSec;
	 	 //--- Check if the log is maintained
		 if( m_log )
		 	 Print( __FUNCTION__,": Time of the next candle for writing ticks = "+TimeToString( m_time ) );
	 	 //--- Return 'true'
	 	 return( true );										// Return 'true'
	 	}
	 else 														// If the tick time is within the current candle range
	 	 return( false );										// Return 'false'
	}
//+------------------------------------------------------------------+
//| Return the time string value with milliseconds					      |
//+------------------------------------------------------------------+
string CTicks::GetStringTickMsTime( const long time ) const
	{
	 return( TimeToString( time/MS_KOEF, TIME_DATE|TIME_SECONDS )+"."+string( time%MS_KOEF ) );
	}

