const int MS_KOEF = 1000;

class CTicks
{
protected:
	string m_symbol;
	ENUM_TIMEFRAMES m_period;
	uint m_flags;
	MqlTick m_ticks[];
	int m_size;
	ulong m_from;
	ulong m_to;
	uint m_count;
	datetime m_time;
	
public:
	bool GetTicks();
	bool GetTicksRange();
	void SetFrom(const datetime from);
	void SetFrom();
	bool SetTime(const int rates_total, const datetime& time[]);
	int GetNumByTime(const bool asSeries) const;
	bool IsNewCandle(const int num);
	void ResetTicks();
	string GetStringTickMsTime(const long time) const;
	string GetStringFlags() const;

	void SetSymbol(const string symbol)
	{
		m_symbol = symbol;
	}

	void SetPeriod(const ENUM_TIMEFRAMES period)
	{
		m_period = period;
	}

	void SetFlags(const uint flags)
	{
		m_flags = flags;
	}

	void SetSize(const int size)
	{
		m_size = size;
	}

	void SetSize()
	{
		m_size = ArraySize(m_ticks);
	}

	void SetFrom(const long from)
	{
		m_from = from;
	}

	void SetCount(const uint count)
	{
		m_count = count;
	}

	void SetTime(const datetime time)
	{
		m_time = time;
	}

	string GetSymbol() const
	{
		return(m_symbol);
	}

	ENUM_TIMEFRAMES GetPeriod() const
	{
		return(m_period);
	}

	uint GetFlags() const
	{
		return(m_flags);
	}

	int GetSize() const
	{
		return(m_size);
	}

	ulong GetFrom() const
	{
		return(m_from);
	}

	void SetTo(const long to)
	{
		m_to = to;
	}

	ulong GetTo() const
	{
		return(m_to);
	}

	uint GetCount() const
	{
		return(m_count);
	}

	datetime GetTime() const
	{
		return(m_time);
	}

	MqlTick GetTick(const int num) const
	{
		return(m_ticks[num]);
	}

	datetime GetTickTime(const int num) const
	{
		return(m_ticks[num].time);
	}

	double GetTickBid(const int num) const
	{
		return(m_ticks[num].bid);
	}

	double GetTickAsk(const int num) const
	{
		return(m_ticks[num].ask);
	}

	double GetTickLast(const int num) const
	{
		return(m_ticks[num].last);
	}

	ulong GetTickVolume(const int num) const
	{
		return(m_ticks[num].volume);
	}

	ulong GetTickTimeMs(const int num) const
	{
		return(m_ticks[num].time_msc);
	}

	uint GetTickFlags(const int num) const
	{
		return(m_ticks[num].flags);
	}

	CTicks()
	{
	}

	CTicks(string symbol, ENUM_TIMEFRAMES period, uint flags, ulong from = ULONG_MAX, ulong to = ULONG_MAX, uint count = UINT_MAX, datetime m_time = 0);

	~CTicks()
	{
	}
};


string CTicks::GetStringFlags(void) const
{
	switch (m_flags)
	{
	case COPY_TICKS_ALL: return("ALL");
	case COPY_TICKS_INFO: return("INFO");
	case COPY_TICKS_TRADE: return("TRADE");
	default:
		Print(__FUNCTION__, ": Error! Unknown tick type ", m_flags);
		return("UNKNOWN");
	}
}


int CTicks::GetNumByTime(const bool asSeries) const
{
	const int rates_total = Bars(_Symbol, m_period);
	if (rates_total <= 0) return(WRONG_VALUE);
	const datetime stopTime = (datetime)SymbolInfoInteger(m_symbol, SYMBOL_TIME);
	const int barsFromTo = Bars(_Symbol, m_period, m_time, stopTime);
	if (barsFromTo <= 0) return(WRONG_VALUE);
	return((asSeries) ? barsFromTo - 1 : rates_total - barsFromTo);
}


void CTicks::CTicks(const string symbol,
                    const ENUM_TIMEFRAMES period,
                    const uint flags,
                    ulong from = ULONG_MAX,
                    ulong to = ULONG_MAX,
                    uint count = UINT_MAX,
                    datetime time = 0
)
{
	m_symbol = symbol;
	m_period = period;
	m_flags = flags;
	m_from = from;
	m_to = to;
	m_count = count;
	m_time = time;
	ResetTicks();
}


bool CTicks::GetTicksRange()
{
	if (m_from == ULONG_MAX || m_to == ULONG_MAX)
	{
		Print(__FUNCTION__, ": Error! The start/end of loading history is not set: m_from = "
		                  + GetStringTickMsTime(m_from) + ", m_to = " + GetStringTickMsTime(m_to));
		return(false);
	}
	ResetTicks();
	ResetLastError();
	int copied = CopyTicksRange(m_symbol, m_ticks, m_flags, m_from, m_to);
	switch (GetLastError())
	{
	case 0:
		if (copied <= 0)
		{
			Print(__FUNCTION__, ": Received 0 ticks of ", m_symbol, " from " + GetStringTickMsTime(m_from) + " to " + GetStringTickMsTime(m_to));
			return(false);
		}
		SetSize(copied);
		return(true);
	case ERR_HISTORY_SMALL_BUFFER:
		//Print(__FUNCTION__, ": Error #", _LastError, ": insufficient array size! Received ", copied, " elements!");
		break;
	case ERR_HISTORY_TIMEOUT:
		break;
	case ERR_NOT_ENOUGH_MEMORY:
		//Print(__FUNCTION__, ": Error #", _LastError, ": Not enough memory to get a range of ticks from " + GetStringTickMsTime(m_from) + " to " + GetStringTickMsTime(m_to));
		break;
	case ERR_HISTORY_NOT_FOUND:
		break;
	default:
		//Print(__FUNCTION__, ": Error #", _LastError, ": received ", copied, " ticks. Ticks are not yet synchronized!");
		break;
	}
	ResetTicks();
	return(false);
}


bool CTicks::GetTicks()
{
	if (m_from == ULONG_MAX || m_count == UINT_MAX)
	{
		Print(__FUNCTION__, ": Error! The start time of the download / number of ticks history is not set: m_from = " + GetStringTickMsTime(m_from) + ", m_count = ", m_count);
		return(false);
	}
	ResetTicks();
	ResetLastError();
	const int copied = CopyTicks(m_symbol, m_ticks, m_flags, m_from, m_count);
	if (copied > 0)
	{
		if (GetLastError() == 0)
		{
			SetSize(copied);
			return(true);
		}
		else
		{
			//Print(__FUNCTION__, ": Error #", _LastError, ": received ", copied, " ticks. Ticks are not yet synchronized!");
			ResetTicks();
		}
	}
	/*else if (copied == 0)
	{
		Print(__FUNCTION__, ": Attention! 0 ticks received. An incorrect parameter may be set: from (" +
		                  GetStringTickMsTime(m_from) + ") or count (", m_count, "). Current time " + TimeToString(TimeCurrent()));
	}
	else
	{
		Print(__FUNCTION__, ": Error #", _LastError, ": Ticks not received!");
	}*/
	return(false);
}


void CTicks::SetFrom()
{
	if (m_size <= 0)
	{
		Print(__FUNCTION__, ": Error! Ticks array size = 0");
		return;
	}
	m_from = m_ticks[m_size - 1].time_msc;
}


void CTicks::SetFrom(const datetime from)
{
	datetime dtFrom = from;
	const datetime dayOpenTime = (datetime)SeriesInfoInteger(_Symbol, PERIOD_D1, SERIES_LASTBAR_DATE);
	if (dtFrom > dayOpenTime)
	{
	 	dtFrom = dayOpenTime;
	}
	else
	{
		const datetime firstDate = (datetime)SeriesInfoInteger(_Symbol, m_period, SERIES_FIRSTDATE);
		if (dtFrom < firstDate) dtFrom = firstDate;
	}
	m_from = dtFrom * MS_KOEF;
}


void CTicks::ResetTicks(void)
{
	ArrayFree(m_ticks);
	m_size = 0;
}

bool CTicks::SetTime(const int rates_total, const datetime& time[])
{
	if (m_size <= 0) return(false);
	datetime firstTickTime = m_ticks[0].time;
	const int modulo = (int)(firstTickTime % PeriodSeconds(m_period));
	if (modulo > 0) firstTickTime -= modulo;
	// first candle
	for (int i = 0; i < rates_total; i++)
	{
		if (time[i] == firstTickTime)
		{
			// first candle time
			m_time = time[i];
			return(true);
		}
		else if (time[i] > firstTickTime)
		{
			Print(__FUNCTION__, ": Error! Tick time " + TimeToString(firstTickTime, TIME_DATE | TIME_SECONDS) +
			                  " should be equal to the candle open time " + TimeToString(time[i], TIME_DATE | TIME_SECONDS));
			return(false);
		}
	}
	Print(__FUNCTION__, ": Error! No candle found covering a tick story! FirstTickTime = " + TimeToString(firstTickTime, TIME_DATE | TIME_SECONDS));
	return(false);
}


bool CTicks::IsNewCandle(const int num)
{
	if (m_size <= 0) return(false);
	if (num >= m_size)
	{
		Print(__FUNCTION__, ": Error! Bad tick array index passed ", num, ". Array size = ", m_size);
		return(false);
	}
	const int perSec = PeriodSeconds(m_period);
	const datetime nextTime = m_time + perSec;
	if (m_ticks[num].time_msc >= nextTime * MS_KOEF)
	{
		// next candle time, sec
		m_time = datetime((m_ticks[num].time_msc - m_ticks[num].time_msc % MS_KOEF) / MS_KOEF);
		// next candle time, min
		m_time = m_time - m_time % perSec;
		return(true);
	}
	return(false);
}


string CTicks::GetStringTickMsTime(const long time) const
{
	return(TimeToString(time / MS_KOEF, TIME_DATE | TIME_SECONDS) + "." + string(time % MS_KOEF));
}