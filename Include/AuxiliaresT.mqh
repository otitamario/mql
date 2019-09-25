//+------------------------------------------------------------------+
//|                                                   Auxiliares.mqh |
//|                        Copyright 2017,  Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
//+------------------------------------------------------------------+

class CCandle
{
public:
double copen,chigh,clow,cclose,cbodysize;
datetime ctime;
bool bull;
public:
     CCandle(void);
   //--- methods of setting adjustable parameters
    
   void    Open(double value)        {copen=value;}
   void    High(double value)         {chigh=value;}
   void    Low(double value)        {clow=value;}
   void    Close(double value) {cclose=value;}
    void  BodySize(void)   {cbodysize=MathAbs(copen-cclose);}
   void Time(datetime value) {ctime=value;}
   void Bull(void){bull=copen<cclose;} 

};
//Constructor
CCandle::CCandle(void) 
{
Open(0);High(0);Low(0);Close(0);
Time(TimeCurrent());
}

//+------------------------------------------------------------------+
//| Check for New Bar                                                |
//+------------------------------------------------------------------+

class CNewBar
{
	private:
		datetime Time[], LastTime;
	
	public:
		void CNewBar();
		bool CheckNewBar(string pSymbol, ENUM_TIMEFRAMES pTimeframe);
};


void CNewBar::CNewBar(void)
{
	ArraySetAsSeries(Time,true);
}


bool CNewBar::CheckNewBar(string pSymbol,ENUM_TIMEFRAMES pTimeframe)
{
	bool firstRun = false, newBar = false;
	CopyTime(pSymbol,pTimeframe,0,2,Time);
	
	if(LastTime == 0) firstRun = true;
	
	if(Time[0] > LastTime)
	{
		if(firstRun == false) newBar = true;
		LastTime = Time[0];
	}
	
	return(newBar);
}



//------------------------------------------------------------------------

//------------------------------------------------------------------------

//------------------------------------------------------------------------
// Timer
#define TIME_ADD_MINUTE 60
#define TIME_ADD_HOUR 3600
#define TIME_ADD_DAY	86400
#define TIME_ADD_WEEK 604800

class CTimer
{
	private:
		bool TimerStarted;
		datetime StartTime, EndTime;
		void PrintTimerMessage(bool pTimerOn);



	public:
		bool CheckTimer(datetime pStartTime, datetime pEndTime, bool pLocalTime = false);
		bool DailyTimer(int pStartHour, int pStartMinute, int pEndHour, int pEndMinute, bool pLocalTime = false);
		
};


// Daily timer
bool CTimer::DailyTimer(int pStartHour, int pStartMinute, int pEndHour, int pEndMinute, bool pLocalTime=false)
{
	datetime currentTime;
	if(pLocalTime == true) currentTime = TimeLocal();
	else currentTime = TimeCurrent();
	
	StartTime = CreateDateTime(pStartHour,pStartMinute);	
	EndTime = CreateDateTime(pEndHour,pEndMinute);
	
	if(EndTime <= StartTime)	
	{
		StartTime -= TIME_ADD_DAY;
		
		if(currentTime > EndTime)
		{
			StartTime += TIME_ADD_DAY;
			EndTime += TIME_ADD_DAY;
		}
	} 
	
	bool timerOn = CheckTimer(StartTime,EndTime,pLocalTime);
	PrintTimerMessage(timerOn);
	
	return(timerOn);
}


// Check timer
bool CTimer::CheckTimer(datetime pStartTime, datetime pEndTime, bool pLocalTime=false)
{
	if(pStartTime >= pEndTime)
	{
		Alert("Error: Invalid start or end time");
		return(false);
	}
	
	datetime currentTime;
	if(pLocalTime == true) currentTime = TimeLocal();
	else currentTime = TimeCurrent();
	
	bool timerOn = false;
	if(currentTime >= pStartTime && currentTime < pEndTime) 
	{
		timerOn = true;
	}
	
	return(timerOn);
}

//---------------------
// Print a message to the screen
void CTimer::PrintTimerMessage(bool pTimerOn)
{
	if(pTimerOn == true && TimerStarted == false)
	{
		string message = "Timer started";
		Print(message);
		Comment(message);
		TimerStarted = true;
	}
	else if(pTimerOn == false && TimerStarted == true)
	{
		string message = "Timer stopped";
		Print(message);
		Comment(message);
		TimerStarted = false;
	}
}

// Create datetime value
datetime CreateDateTime(int pHour = 0, int pMinute = 0) 
{
	MqlDateTime timeStruct;
	TimeToStruct(TimeCurrent(),timeStruct);
	
	timeStruct.hour = pHour;
	timeStruct.min = pMinute;
	
	datetime useTime = StructToTime(timeStruct);
	
	return(useTime);
}

//------------------------------------------------
//------------------------------------------------
//------------------------------------------------