#property copyright "© GoldRat 2016"
#property version "1.1"
#property link "https://www.mql5.com/en/users/goldrat"
#property strict

#property indicator_separate_window

#property indicator_buffers 5
#property indicator_plots 4

#include <GoldRat_CTicks_V2.mqh>

enum eType
{
	CumulativeDelta, //Cumulative Delta
	DeltaCandles, //Delta Candles
	Delta, //Delta
	Delta2, //Delta 2
	VolumePP //Volume ++ 
};

enum eMode
{
	Auto,
	Raw
};


input string TicksSymbol = ""; //Ticks symbol (empty - current)
input int BarCalc = 1; //Bars
input eType Type = Delta; //Indicator type
input eMode Mode = Auto; //Analysis mode

input string DB_ = "-------------- Daily Balance Settings --------------"; //-------------- Daily Balance Settings --------------
input color DB_PositiveColor = clrLimeGreen; //Positive balance color
input color DB_NegativeColor = clrRed; //Negative balance color
input int DB_Width = 4; //Width

input string VD_ = "-------------- Volume Delta Settings --------------"; //-------------- Volume Delta Settings --------------
input color VD_PositiveColor = clrLimeGreen; //Positive Delta color
input color VD_NegativeColor = clrRed; //Negative Delta color
input int VD_Width = 4; //Width

input string VPP_ = "-------------- Volume++ Settings --------------"; //-------------- Volume++ Settings --------------
input color VPP_Color = clrSilver; //Volume color
input int VPP_Width = 5; //Width
input color VPP_BuyColor = clrBlue; //Buyers volume color
input int VPP_BuyWidth = 4; //Width
input color VPP_SellColor = clrMagenta; //Sellers volume color
input int VPP_SellWidth = 3; //Width
input color VPP_NeutralColor = clrLime; //Neutrals volume color
input int VPP_NeutralWidth = 2; //Width


double Buf0[], Buf1[], Buf2[], Buf3[], Buf4[];
string TicksSymbol_;
CTicks Ticks(_Symbol, _Period, COPY_TICKS_TRADE, -1, -1, UINT_MAX, 0);
bool RepeatControl;
int ControlNum;
int RatesTotal;

int OnInit()
{
	TicksSymbol_ = TicksSymbol;
	StringTrimRight(TicksSymbol_);
	StringTrimLeft(TicksSymbol_);
	if (TicksSymbol_ == "") TicksSymbol_ = _Symbol;
	RepeatControl = false;
	ControlNum = WRONG_VALUE;
	Ticks.SetSymbol(TicksSymbol_);
	RatesTotal = 0;
	
	IndicatorSetInteger(INDICATOR_DIGITS, 0);

	// indicator buffers
	SetIndexBuffer(0, Buf0, INDICATOR_DATA);
   ArraySetAsSeries(Buf0, false);
	
	SetIndexBuffer(1, Buf1, INDICATOR_DATA);
   ArraySetAsSeries(Buf1, false);
	
	SetIndexBuffer(2, Buf2, INDICATOR_DATA);
   ArraySetAsSeries(Buf2, false);
	
	SetIndexBuffer(3, Buf3, INDICATOR_DATA);
   ArraySetAsSeries(Buf3, false);

	SetIndexBuffer(4, Buf4, INDICATOR_COLOR_INDEX);
   ArraySetAsSeries(Buf4, false);
	
	switch (Type)
	{
		case CumulativeDelta:
			IndicatorSetString(INDICATOR_SHORTNAME, "OFB Cumulative Delta(" + _Symbol + ")");
			PlotIndexSetString(0, PLOT_LABEL, "OFB");
			PlotIndexSetInteger(0, PLOT_SHOW_DATA, true);
			PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_COLOR_HISTOGRAM);
			PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 2);
			PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, DB_PositiveColor);
			PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, DB_NegativeColor);
			PlotIndexSetInteger(0, PLOT_LINE_WIDTH, DB_Width);
			SetIndexBuffer(1, Buf1, INDICATOR_COLOR_INDEX);
			PlotIndexSetInteger(1, PLOT_SHOW_DATA, false);
			PlotIndexSetInteger(2, PLOT_SHOW_DATA, false);
			PlotIndexSetInteger(3, PLOT_SHOW_DATA, false);
			SetIndexBuffer(4, Buf4, INDICATOR_CALCULATIONS);
			break;
		case DeltaCandles:
			IndicatorSetString(INDICATOR_SHORTNAME, "OFB Delta Candles(" + _Symbol + ")");
			PlotIndexSetString(0, PLOT_LABEL, "Delta Open;Delta High;Delta Low;Delta Close");
			PlotIndexSetInteger(0, PLOT_SHOW_DATA, true);
			PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_COLOR_CANDLES);
			PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 2);
			PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, VD_PositiveColor);
			PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, VD_NegativeColor);
			PlotIndexSetInteger(0, PLOT_LINE_WIDTH, VD_Width);
			break;
		case Delta:
			IndicatorSetString(INDICATOR_SHORTNAME, "OFB Delta(" + _Symbol + ")");
			PlotIndexSetString(0, PLOT_LABEL, "OFB Delta");
			PlotIndexSetInteger(0, PLOT_SHOW_DATA, true);
			PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_COLOR_HISTOGRAM);
			PlotIndexSetInteger(0, PLOT_COLOR_INDEXES, 2);
			PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, VD_PositiveColor);
			PlotIndexSetInteger(0, PLOT_LINE_COLOR, 1, VD_NegativeColor);
			PlotIndexSetInteger(0, PLOT_LINE_WIDTH, VD_Width);
			PlotIndexSetInteger(1, PLOT_SHOW_DATA, false);
			PlotIndexSetInteger(2, PLOT_SHOW_DATA, false);
			PlotIndexSetInteger(3, PLOT_SHOW_DATA, false);
			break;
		case Delta2:
			IndicatorSetString(INDICATOR_SHORTNAME, "OFB Delta 2(" + _Symbol + ")");
			PlotIndexSetString(0, PLOT_LABEL, "OFB Buyers");
			PlotIndexSetInteger(0, PLOT_SHOW_DATA, true);
			PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
			PlotIndexSetInteger(0, PLOT_LINE_COLOR, VD_PositiveColor);
			PlotIndexSetInteger(0, PLOT_LINE_WIDTH, VD_Width);
			PlotIndexSetString(1, PLOT_LABEL, "OFB Sellers");
			PlotIndexSetInteger(1, PLOT_SHOW_DATA, true);
			PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
			PlotIndexSetInteger(1, PLOT_LINE_COLOR, VD_NegativeColor);
			PlotIndexSetInteger(1, PLOT_LINE_WIDTH, VD_Width);
			PlotIndexSetInteger(2, PLOT_SHOW_DATA, false);
			PlotIndexSetInteger(3, PLOT_SHOW_DATA, false);
			break;
		case VolumePP:
			IndicatorSetString(INDICATOR_SHORTNAME, "OFB Volume ++(" + _Symbol + ")");
			PlotIndexSetString(0, PLOT_LABEL, "OFB Volume");
			PlotIndexSetInteger(0, PLOT_SHOW_DATA, true);
			PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
			PlotIndexSetInteger(0, PLOT_LINE_COLOR, VPP_Color);
			PlotIndexSetInteger(0, PLOT_LINE_WIDTH, VPP_Width);
			PlotIndexSetString(1, PLOT_LABEL, "OFB Buyers");
			PlotIndexSetInteger(1, PLOT_SHOW_DATA, true);
			PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
			PlotIndexSetInteger(1, PLOT_LINE_COLOR, VPP_BuyColor);
			PlotIndexSetInteger(1, PLOT_LINE_WIDTH, VPP_BuyWidth);
			PlotIndexSetString(2, PLOT_LABEL, "OFB Sellers");
			PlotIndexSetInteger(2, PLOT_SHOW_DATA, true);
			PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
			PlotIndexSetInteger(2, PLOT_LINE_COLOR, VPP_SellColor);
			PlotIndexSetInteger(2, PLOT_LINE_WIDTH, VPP_SellWidth);
			PlotIndexSetString(3, PLOT_LABEL, "OFB Neutral");
			PlotIndexSetInteger(3, PLOT_SHOW_DATA, true);
			PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_HISTOGRAM);
			PlotIndexSetInteger(3, PLOT_LINE_COLOR, VPP_NeutralColor);
			PlotIndexSetInteger(3, PLOT_LINE_WIDTH, VPP_NeutralWidth);
			break;
	}
	return(INIT_SUCCEEDED);
}


int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
	RatesTotal = rates_total;

	if (prev_calculated > 0) 
	{
		// current
		if (rates_total > prev_calculated)
		{
			// new bar
			if (RepeatControl && ControlNum == rates_total - 2)
			{
				CheckRepeated(ControlNum, time[ControlNum], ControlNum + 1 < rates_total ? time[ControlNum + 1] : TimeCurrent());
			}
			RepeatControl = false;
			ControlNum = WRONG_VALUE;
		}
		if (!Ticks.GetTicks()) return(prev_calculated);
		Ticks.SetFrom();
		CalcCurrentBar(false, rates_total, time, volume);
	}
	else if (RatesTotal > 0)
	{
		// initialize
		ArrayInitialize(Buf0, 0);
		ArrayInitialize(Buf1, 0);
		ArrayInitialize(Buf2, 0);
		ArrayInitialize(Buf3, 0);
		ArrayInitialize(Buf4, EMPTY_VALUE);
		
		RepeatControl = false;
		ControlNum = WRONG_VALUE;
		//Ticks.SetSymbol(TicksSymbol_);
		
		// history
		Ticks.SetTime(0);
		datetime dFrom = BarCalc > 1 ? time[rates_total - BarCalc - 1] : StringToTime(TimeToString(TimeCurrent(), TIME_DATE));
		Ticks.SetFrom(long(dFrom) * MS_KOEF);
		if (Ticks.GetFrom() <= 0) return(0);
		Ticks.SetTo(long(time[rates_total - 1] * MS_KOEF - 1));
		if (!Ticks.GetTicksRange()) return(0);
		CalcHistoryBars(rates_total, time, volume);

		// current
		Ticks.SetTime(0);
		Ticks.SetFrom(long(time[rates_total - 1] * MS_KOEF));
		Ticks.SetTo(long(TimeCurrent() * MS_KOEF));
		if (!Ticks.GetTicksRange()) return(0);
		Ticks.SetTo(ULONG_MAX);
		Ticks.SetFrom();
		CalcCurrentBar(true, rates_total, time, volume);
		
		Ticks.SetCount(2000);
	}
	ChartRedraw();
	return (rates_total);
}


void CalcCurrentBar(const bool firstLaunch, const int rates_total, const datetime& time[], const long& volume[])
{
	static long sumVolBuy = 0, sumVolSell = 0, sumVolNeutral = 0;
	static int lastBNum = WRONG_VALUE;
	if (firstLaunch)
	{
		sumVolBuy = 0;
		sumVolSell = 0;
		sumVolNeutral = 0;
		lastBNum = WRONG_VALUE;
	}
	
	const int limit = Ticks.GetSize() - 1;
	const ulong limitTime = Ticks.GetFrom();
	
	for (int i = 0; i < limit && !IsStopped(); i++)
	{
		MqlTick tick = Ticks.GetTick(i);
		int bNum = rates_total - iBarShift(_Symbol, _Period, tick.time) - 1;
		if (bNum > lastBNum)
		{
			if (bNum >= 0)
			{
				if (sumVolBuy > 0 || sumVolSell > 0 || sumVolNeutral)
				{
					CheckVolume(true, lastBNum, volume[lastBNum], time[lastBNum], sumVolBuy, sumVolSell, sumVolNeutral);
				}
			}
			sumVolBuy = 0;
			sumVolSell = 0;
			sumVolNeutral = 0;
			lastBNum = bNum;
		}
		AddVolume(Ticks.GetTick(i), bNum, sumVolBuy, sumVolSell, sumVolNeutral);
	}
}


bool CalcHistoryBars(const int rates_total, const datetime& time[], const long& volume[])
{
	long sumVolBuy = 0;
	long sumVolSell = 0;
	long sumVolNeutral = 0;
	int lastBNum = WRONG_VALUE;
	const int limit = Ticks.GetSize();
	for (int i = 0; i < limit && !IsStopped(); i++)
	{
		MqlTick tick = Ticks.GetTick(i);
		int bNum = rates_total - iBarShift(_Symbol, _Period, tick.time) - 1;
		if (bNum > lastBNum)
		{
			if (lastBNum >= 0)
			{
				if (sumVolBuy > 0 || sumVolSell > 0 || sumVolNeutral)
				{
					CheckVolume(false, lastBNum, volume[lastBNum], time[lastBNum], sumVolBuy, sumVolSell, sumVolNeutral);
				}
			}
			sumVolBuy = 0;
			sumVolSell = 0;
			sumVolNeutral = 0;
			lastBNum = bNum;
			if (bNum >= rates_total || bNum < 0) return(false);
		}
		AddVolume(Ticks.GetTick(i), bNum, sumVolBuy, sumVolSell, sumVolNeutral);
	}
	if (sumVolBuy > 0 || sumVolSell > 0 || sumVolNeutral > 0)
	{
		CheckVolume(false, lastBNum, volume[lastBNum], time[lastBNum], sumVolBuy, sumVolSell, sumVolNeutral);
	}
	return(true);
}


bool CheckRepeated(const int num, const datetime time, const datetime time_1)
{
	CTicks cTicks(TicksSymbol_, _Period, COPY_TICKS_TRADE, time * 1000, time_1 * 1000 - 1);
	if (!cTicks.GetTicksRange()) return(false);
	return (RecalcCandle(cTicks, num, time));
}


bool RecalcCandle(const CTicks& ticks, const int num, const datetime time)
{
	long controlVolume[];
	if (!GetVolumeData(_Symbol, _Period, time, 1, controlVolume)) return(false);
	const int limit = ticks.GetSize() - 1;
	long sumVolBuy = 0, sumVolSell = 0, sumVolNeutral = 0;
	for (int i = 0; i <= limit; i++)
	{
		AddVolume(ticks.GetTick(i), num, sumVolBuy, sumVolSell, sumVolNeutral);
	}
	return (controlVolume[0] != sumVolBuy + sumVolSell + sumVolNeutral);
}


bool GetVolumeData(const string symbol, const ENUM_TIMEFRAMES timeframe, const datetime startTime, const int count, long& vol[])
{
	int num;
	for (int i = 0; i < 3; i++)
	{
		ResetLastError();
		num = CopyRealVolume(symbol, timeframe, startTime, count, vol);
		if (num > 0) return(true);
		Sleep(1000);
	}
	ResetLastError();
	num = CopyRealVolume(TicksSymbol_, timeframe, startTime, count, vol);
	if (num > 0) return(true);
	Print(__FUNCTION__, ": Error #", GetLastError(), " while getting ", TicksSymbol_, " data from ", startTime, " next ", count, " (", num, ")");
	return(false);
}


void AddVolume(const MqlTick& tick, const int num, long& sumVolBuy, long& sumVolSell, long& sumVolNeutral)
{
	if (num >= RatesTotal) return;
	double 
		vol = (double)tick.volume,
		volBuy = 0, 
		volSell = 0, 
		volNeutral = 0;
	if ((tick.flags & TICK_FLAG_BUY) == TICK_FLAG_BUY && (tick.flags & TICK_FLAG_SELL) == TICK_FLAG_SELL)
	{
		volNeutral = vol;
		sumVolNeutral+= (long)vol;
	}
	else if ((tick.flags & TICK_FLAG_BUY) == TICK_FLAG_BUY)
	{
		volBuy = vol;
		sumVolBuy+= (long)vol;
	}
	else if ((tick.flags & TICK_FLAG_SELL) == TICK_FLAG_SELL)
	{
		volSell = vol;
		sumVolSell+= (long)vol;
	}

	double delta = volBuy - volSell;
	datetime time, time1;  
	MqlDateTime t, t1;
	
	switch (Type)
	{
		case CumulativeDelta:
			time = iTime(_Symbol, _Period, RatesTotal - num - 1);
			time1 = iTime(_Symbol, _Period, RatesTotal - num - 2);
   		TimeToStruct(time, t);
   		TimeToStruct(time1, t1);
   		if (Buf4[num] == EMPTY_VALUE) Buf4[num] = 0;
			Buf4[num]+= delta;
			// day started
   		if (time1 == 0 || t1.day_of_year < t.day_of_year)
   		{
   			Buf0[num] = Buf4[num]; 
   		}
   		else
   		{
   			if (Buf4[num - 1] != EMPTY_VALUE)
   			{
   				Buf0[num] = Buf0[num - 1] + Buf4[num];
   			}
   			else
   			{
   				Buf0[num] = Buf4[num];
   			}
   		}
			Buf1[num] = Buf0[num] > 0 ? 0 : 1;
			break;
		case DeltaCandles:
			if (delta > Buf1[num]) Buf1[num] = delta;
			if (Buf2[num] == 0 || delta < Buf2[num]) Buf2[num] = delta;
			Buf3[num] = delta;
			Buf4[num] = delta > 0 ? 0 : 1;
			break;
		case Delta:
			Buf0[num]+= delta;
			Buf1[num] = Buf0[num] > 0 ? 0 : 1;
			break;
		case Delta2:
			Buf0[num]+= volBuy;
			Buf1[num]-= volSell;
			break;
		case VolumePP:
			Buf0[num]+= volBuy + volSell + volNeutral;
			Buf1[num]+= volBuy;
			Buf2[num]+= volSell;
			Buf3[num]+= volNeutral;
			break;
	}
}


void CheckVolume(const bool useControl, const int num, const long vol, const datetime time, const long sumVolBuy, const long sumVolSell, const long sumVolNeutral)
{
	if (vol == (sumVolBuy + sumVolSell + sumVolNeutral)) return;
	if (useControl)
	{
		datetime time_1 = num + 1 < RatesTotal ? iTime(_Symbol, _Period, RatesTotal - num - 2) : TimeCurrent();
		if (CheckRepeated(num, time, time_1)) return;
		RepeatControl = true;
		ControlNum = num;
	}
}