//+------------------------------------------------------------------+
//|                                                MarketProfile.mq5 |
//| 				                 Copyright © 2010-2018, EarnForex.com |
//|                                       https://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "Market Profile BR"
#property link      "https://youtu.be/DqBJVJgdgQM"
#property version   "1.08"

#property description "Indicador gráfico de Market Profile para uso no intraday, Diario, semanal, ou sessões mensais de trade."
#property description " "
#property description "Recomendações: "
#property description "Diário - deve ser anexado em timeframes M5-M30. Recomendado M30."
#property description " "
#property description "Semanal - deve ser anexado em timeframes M30-H4. Recomendado H1."
#property description " "
#property description "Mensal - deve ser anexado em timeframes H1-D1. Recomendado H4."
#property description " "
#property description "Intraday - deve ser anexado em timeframes M1-M15. Recomendado M5.\r\n"
#property description " "
#property description "Código Fonte Original www.EarnForex.com"
#property description " "

#property indicator_chart_window
#property indicator_plots 0

enum color_scheme
{
   Azul_para_Vermelho,
   Vermelho_para_Verde,
   Verde_para_Azul,
   Amarelo_para_Ciano,
   Magenta_para_Amarelo,
   Ciano_para_Magenta,
   Cor_Simples
};

enum session_period
{
	Diario,
	Semanal,
	Mensal,
	Intraday
};

input session_period Session                 = Diario; // Sessão
input datetime       StartFromDate           = __DATE__; // Iniciar pela data: baixa prioridade.
input bool           StartFromCurrentSession = true;     // Iniciar pela Sessão Atual: alta prioridade.
input int            SessionsToCount         = 5;        // Número de sessões: Number of sessions to count Market Profile.
input color_scheme   ColorScheme             = Azul_para_Vermelho; //Esquema de Cores
input color          SingleColor             = clrBlue;  // Cor Simples: Se Esquema de Cores está ajustada para Cor_Simples.
input color          MedianColor             = clrRed; //Cor da Média - POC
input color          ValueAreaColor          = clrWhite; // Cor da Área de valor
input bool           ShowValueAreaRays       = false;    // Mostrar Área de Valor Anterior
input bool           ShowMedianRays          = false;    // Mostrar Linha Média - POC Anterior.
int            TimeShiftMinutes        = 0;        // TimeShiftMinutes: shift session + to the left, - to the right.
input int            PointMultiplier         = 10;        // Densidade Gráfica (Recomendações: Ações=1, WIN=10, WDO=100)
input int            ThrottleRedraw          = 0;        // ThrottleRedraw: delay em seg. para update do Market Profile.

input bool           EnableIntradaySession1      = true; //Ativar Sessão Intraday 1
input string         IntradaySession1StartTime   = "00:00";//Início da Sessão 1
input string         IntradaySession1EndTime     = "06:00";//Fim da Sessão 1
input color_scheme   IntradaySession1ColorScheme = Azul_para_Vermelho;//Esquema de cores da Sessão 1

input bool           EnableIntradaySession2      = true; //Ativar Sessão Intraday 2
input string         IntradaySession2StartTime   = "06:00";//Início da Sessão 2
input string         IntradaySession2EndTime     = "12:00";//Fim da Sessão 2
input color_scheme   IntradaySession2ColorScheme = Vermelho_para_Verde;//Esquema de cores da Sessão 2

input bool           EnableIntradaySession3      = true; //Ativar Sessão Intraday 3
input string         IntradaySession3StartTime   = "12:00";//Início da Sessão 3
input string         IntradaySession3EndTime     = "18:00";//Fim da Sessão 3
input color_scheme   IntradaySession3ColorScheme = Verde_para_Azul;//Esquema de cores da Sessão 3

input bool           EnableIntradaySession4      = true; //Ativar Sessão Intraday 4
input string         IntradaySession4StartTime   = "18:00";//Início da Sessão 4
input string         IntradaySession4EndTime     = "00:00";//Fim da Sessão 4
input color_scheme   IntradaySession4ColorScheme = Amarelo_para_Ciano;//Esquema de cores da Sessão 4

int DigitsM; 					// Number of digits normalized based on TickMultiplier.
bool InitFailed;           // Used for soft INIT_FAILED. Hard INIT_FAILED resets input parameters.
datetime StartDate; 			// Will hold either StartFromDate or Time[0].
double onetick; 				// One normalized pip.
bool FirstRunDone = false; // If true - OnCalculate() was already executed once.
string Suffix = "";			// Will store object name suffix depending on timeframe.
color_scheme CurrentColorScheme; // Required due to intraday sessions.
int Max_number_of_bars_in_a_session = 1;
int Timer = 0; 			   // For throttling updates of market profiles in slow systems.

// For intraday sessions' start and end times.
int IDStartHours[4];
int IDStartMinutes[4];
int IDStartTime[4]; // Stores IDStartHours x 60 + IDStartMinutes for comparison purposes.
int IDEndHours[4];
int IDEndMinutes[4];
int IDEndTime[4]; // Stores IDEndHours x 60 + IDEndMinutes for comparison purposes.
color_scheme IDColorScheme[4];
bool IntradayCheckPassed = false;
int IntradaySessionCount = 0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
{
	InitFailed = false;
	
	if (Session == Diario)
	{
		Suffix = "_D";
		if ((PeriodSeconds() < PeriodSeconds(PERIOD_M5)) || (PeriodSeconds() > PeriodSeconds(PERIOD_M30)))
		{
			Alert("Timeframe deve ser entre M5 e M30 para sessão Diária.");
			InitFailed = true; // Soft INIT_FAILED.
		}
	}
	else if (Session == Semanal)
	{
		Suffix = "_W";
		if ((PeriodSeconds() < PeriodSeconds(PERIOD_M30)) || (PeriodSeconds() > PeriodSeconds(PERIOD_H4)))
		{
			Alert("Timeframe deve ser entre M30 e H4 para sessão Semanal.");
			InitFailed = true; // Soft INIT_FAILED.
		}
	}
	else if (Session == Mensal)
	{
		Suffix = "_M";
		if ((PeriodSeconds() < PeriodSeconds(PERIOD_H1)) || (PeriodSeconds() > PeriodSeconds(PERIOD_D1)))
		{
			Alert("Timeframe deve ser entre H1 e D1 para sessão Mensal.");
			InitFailed = true; // Soft INIT_FAILED.
		}
	}
	else if (Session == Intraday)
	{
		if (PeriodSeconds() > PeriodSeconds(PERIOD_M15))
		{
			Alert("Timeframe não deve ser maior que M15 para sessão Intraday.");
			InitFailed = true; // Soft INIT_FAILED.
		}

		IntradaySessionCount = 0;
		if (!CheckIntradaySession(EnableIntradaySession1, IntradaySession1StartTime, IntradaySession1EndTime, IntradaySession1ColorScheme)) return(INIT_PARAMETERS_INCORRECT);
		if (!CheckIntradaySession(EnableIntradaySession2, IntradaySession2StartTime, IntradaySession2EndTime, IntradaySession2ColorScheme)) return(INIT_PARAMETERS_INCORRECT);
		if (!CheckIntradaySession(EnableIntradaySession3, IntradaySession3StartTime, IntradaySession3EndTime, IntradaySession3ColorScheme)) return(INIT_PARAMETERS_INCORRECT);
		if (!CheckIntradaySession(EnableIntradaySession4, IntradaySession4StartTime, IntradaySession4EndTime, IntradaySession4ColorScheme)) return(INIT_PARAMETERS_INCORRECT);
		
		if (IntradaySessionCount == 0)
		{
			Alert("Enable at least one intraday session if you want to use Intraday mode.");
			InitFailed = true; // Soft INIT_FAILED.
		}
	}

   IndicatorSetString(INDICATOR_SHORTNAME, "MarketProfile " + EnumToString(Session));

	// Based on number of digits in TickMultiplier. -1 because if TickMultiplier < 10, it does not modify the number of digits.
	DigitsM = _Digits - (StringLen(IntegerToString(PointMultiplier)) - 1);
	
	onetick = NormalizeDouble(_Point * PointMultiplier, DigitsM);
	
	CurrentColorScheme = ColorScheme;
	
	// To clean up potential leftovers when applying a chart template.
	ObjectCleanup();
	
	return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
   ObjectCleanup();
}

//+------------------------------------------------------------------+
//| Custom Market Profile main iteration function                    |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &open[],
                const double &High[],
                const double &Low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
	if (InitFailed)
	{
	   Print("Initialization failed. Please see the alert message for details.");
	   return(0);
	}
	
   ArraySetAsSeries(High, true);
   ArraySetAsSeries(Low, true);
   ArraySetAsSeries(Time, true);
	
	if (StartFromCurrentSession) StartDate = Time[0];
	else StartDate = StartFromDate;
	
	// If we calculate profiles for the past sessions, no need to run it again.
	if ((FirstRunDone) && (StartDate != Time[0])) return(rates_total);

   // Delay the update of Market Profile if ThrottleRedraw is given.
   if ((ThrottleRedraw > 0) && (Timer > 0))
   {
      if ((int)TimeLocal() - Timer < ThrottleRedraw) return(rates_total);
   }

   // Recalculate everything if there were missing bars or something like that.
   if (rates_total - prev_calculated > 1)
   {
      FirstRunDone = false;
      ObjectCleanup();
   }

	// Get start and end bar numbers of the given session.
	int sessionend = FindSessionEndByDate(Time, StartDate, rates_total);
	int sessionstart = FindSessionStart(Time, sessionend, rates_total);

	int SessionToStart = 0;
	// If all sessions have already been counted, jump to the current one.
	if (FirstRunDone) SessionToStart = SessionsToCount - 1;
	else
	{
		// Move back to the oldest session to count to start from it.
		for (int i = 1; i < SessionsToCount; i++)
		{
			sessionend = sessionstart + 1;
			sessionstart = FindSessionStart(Time, sessionend, rates_total);
		}
	}

	// We begin from the oldest session coming to the current session or to StartFromDate.
	for (int i = SessionToStart; i < SessionsToCount; i++)
	{
      if (Session == Intraday)
      {
         if (!ProcessIntradaySession(sessionstart, sessionend, i, High, Low, Time, rates_total)) return(0);
      }
      else
      {
         if (Session == Diario) Max_number_of_bars_in_a_session = PeriodSeconds(PERIOD_D1) / PeriodSeconds();
         else if (Session == Semanal) Max_number_of_bars_in_a_session = 604800 / PeriodSeconds();
         else if (Session == Mensal) Max_number_of_bars_in_a_session = 2678400 / PeriodSeconds();
         if (!ProcessSession(sessionstart, sessionend, i, High, Low, Time, rates_total)) return(0);
      }
		
		// Go to the newer session only if there is one or more left.
		if (SessionsToCount - i > 1)
		{
			sessionstart = sessionend - 1;
			sessionend = FindSessionEndByDate(Time, Time[sessionstart], rates_total);
		}
	}

	FirstRunDone = true;

   Timer = (int)TimeLocal();

	return(rates_total);
}

//+------------------------------------------------------------------+
//| Finds the session's starting bar number for any given bar number.|
//| n - bar number for which to find starting bar. 					   |
//+------------------------------------------------------------------+
int FindSessionStart(const datetime &Time[], const int n, const int rates_total)
{
	if (Session == Diario) return(FindDayStart(Time, n, rates_total));
	else if (Session == Semanal) return(FindWeekStart(Time, n, rates_total));
	else if (Session == Mensal) return(FindMonthStart(Time, n, rates_total));
	else if (Session == Intraday) return(FindDayStart(Time, n, rates_total));
	
	return(-1);
}

//+------------------------------------------------------------------+
//| Finds the day's starting bar number for any given bar number.    |
//| n - bar number for which to find starting bar. 					   |
//+------------------------------------------------------------------+
int FindDayStart(const datetime &Time[], const int n, const int rates_total)
{
	MqlDateTime dt1, dt2;
	int x = n;
	TimeToStruct(Time[n] + TimeShiftMinutes * 60, dt1);
	TimeToStruct(Time[x] + TimeShiftMinutes * 60, dt2);
	while ((x < rates_total) && (dt1.day_of_year == dt2.day_of_year))
	{  
		x++;
		TimeToStruct(Time[x] + TimeShiftMinutes * 60, dt2);
	}
	return(x - 1);
}

//+------------------------------------------------------------------+
//| Finds the week's starting bar number for any given bar number.   |
//| n - bar number for which to find starting bar. 					   |
//+------------------------------------------------------------------+
int FindWeekStart(const datetime &Time[], const int n, const int rates_total)
{
	int x = n;
	while ((x < rates_total) && (SameWeek(Time[n] + TimeShiftMinutes * 60, Time[x] + TimeShiftMinutes * 60)))
		x++;
	return(x - 1);
}

//+------------------------------------------------------------------+
//| Finds the month's starting bar number for any given bar number.  |
//| n - bar number for which to find starting bar. 					   |
//+------------------------------------------------------------------+
int FindMonthStart(const datetime &Time[], const int n, const int rates_total)
{
	MqlDateTime dt1, dt2;
	int x = n;
	TimeToStruct(Time[n] + TimeShiftMinutes * 60, dt1);
	TimeToStruct(Time[x] + TimeShiftMinutes * 60, dt2);
	while ((x < rates_total) && (dt1.mon == dt2.mon))
	{
		x++;
		TimeToStruct(Time[x] + TimeShiftMinutes * 60, dt2);
	}
	
	return(x - 1);
}

//+------------------------------------------------------------------+
//| Finds the session's end bar by the session's date.					|
//+------------------------------------------------------------------+
int FindSessionEndByDate(const datetime &Time[], const datetime date, const int rates_total)
{
	if (Session == Diario) return(FindDayEndByDate(Time, date, rates_total));
	else if (Session == Semanal) return(FindWeekEndByDate(Time, date, rates_total));
	else if (Session == Mensal) return(FindMonthEndByDate(Time, date, rates_total));
	else if (Session == Intraday) return(FindDayEndByDate(Time, date, rates_total));
	
	return(-1);
}

//+------------------------------------------------------------------+
//| Finds the day's end bar by the day's date.								|
//+------------------------------------------------------------------+
int FindDayEndByDate(const datetime &Time[], const datetime date, const int rates_total)
{
	MqlDateTime dt1, dt2;
	int x = 0;
	TimeToStruct(date + TimeShiftMinutes * 60, dt1);
	TimeToStruct(Time[x] + TimeShiftMinutes * 60, dt2);
	while ((x < rates_total) && (dt1.day_of_year < dt2.day_of_year))
	{  
		x++;
		TimeToStruct(Time[x] + TimeShiftMinutes * 60, dt2);
	}
	return(x);
}

//+------------------------------------------------------------------+
//| Finds the week's end bar by the week's date.							|
//+------------------------------------------------------------------+
int FindWeekEndByDate(const datetime &Time[], const datetime date, const int rates_total)
{
	int x = 0;

	while ((x < rates_total) && (SameWeek(date + TimeShiftMinutes * 60, Time[x] + TimeShiftMinutes * 60) != true))
		x++;

	return(x);
}

//+------------------------------------------------------------------+
//| Finds the month's end bar by the month's date.							|
//+------------------------------------------------------------------+
int FindMonthEndByDate(const datetime &Time[], const datetime date, const int rates_total)
{
	int x = 0;

	while ((x < rates_total) && (SameMonth(date + TimeShiftMinutes * 60, Time[x] + TimeShiftMinutes * 60) != true))
		x++;

	return(x);
}

//+------------------------------------------------------------------+
//| Check if two dates are in the same week.									|
//+------------------------------------------------------------------+
int SameWeek(const datetime date1, const datetime date2)
{
	MqlDateTime dt1, dt2;

	TimeToStruct(date1, dt1);
	TimeToStruct(date2, dt2);

	int seconds_from_start = dt1.day_of_week * 24 * 3600 + dt1.hour * 3600 + dt1.min * 60 + dt1.sec;
	
	if (date1 == date2) return(true);
	else if (date2 < date1)
	{
		if (date1 - date2 <= seconds_from_start) return(true);
	}
	// 604800 - seconds in one week.
	else if (date2 - date1 < 604800 - seconds_from_start) return(true);

	return(false);
}

//+------------------------------------------------------------------+
//| Check if two dates are in the same month.								|
//+------------------------------------------------------------------+
int SameMonth(const datetime date1, const datetime date2)
{
	MqlDateTime dt1, dt2;

	TimeToStruct(date1, dt1);
	TimeToStruct(date2, dt2);

	if ((dt1.mon == dt2.mon) && (dt1.year == dt2.year)) return(true);
	return(false);
}

//+------------------------------------------------------------------+
//| Puts a dot (rectangle) at a given position and color. 			   |
//| price and time are coordinates.								 			   |
//| range is for the second coordinate.						 			   |
//| bar is to determine the color of the dot.				 			   |
//+------------------------------------------------------------------+
void PutDot(const double price, const int start_bar, const int range, const int bar, const datetime &Time[])
{
	double divisor, color_shift;
	string LastName = " " + IntegerToString(Time[start_bar - range]) + " " + DoubleToString(price, _Digits);
	if (ObjectFind(0, "MP" + Suffix + LastName) >= 0) return;

	// Protection from 'Array out of range' error.
	if (start_bar - (range + 1) < 0) return;

	ObjectCreate(0, "MP" + Suffix + LastName, OBJ_RECTANGLE, 0, Time[start_bar - range], price, Time[start_bar - (range + 1)], price + onetick);
	
	// Color switching depending on the distance of the bar from the session's beginning.
	int colour, offset1, offset2;
	switch(CurrentColorScheme)
	{
		case Azul_para_Vermelho:
			colour = 0x00FF0000; // clrBlue;
			offset1 = 0x00010000;
			offset2 = 0x00000001;
		break;
		case Vermelho_para_Verde:
			colour = 0x000000FF; // clrDarkRed;
			offset1 = 0x00000001;
			offset2 = 0x00000100;
		break;
		case Verde_para_Azul:
			colour = 0x0000FF00; // clrDarkGreen;
			offset1 = 0x00000100;
			offset2 = 0x00010000;
		break;
		case Amarelo_para_Ciano:
			colour = 0x0000FFFF; // clrYellow;
			offset1 = 0x00000001;
			offset2 = 0x00010000;
		break;
		case Magenta_para_Amarelo:
			colour = 0x00FF00FF; // clrMagenta;
			offset1 = 0x00010000;
			offset2 = 0x00000100;
		break;
		case Ciano_para_Magenta:
			colour = 0x00FFFF00; // clrCyan;
			offset1 = 0x00000100;
			offset2 = 0x00000001;
		break;
		case Cor_Simples:
			colour = SingleColor;
			offset1 = 0;
			offset2 = 0;
		break;
		default:
			colour = SingleColor;
			offset1 = 0;
			offset2 = 0;
		break;
	}

   // No need to do these calculations if plain color is used.
	if (CurrentColorScheme != Cor_Simples)
	{
   	divisor = 1.0 / 0xFF * (double)Max_number_of_bars_in_a_session;
   
   	// bar is negative.
   	color_shift = MathFloor((double)bar / divisor);
   
      // Prevents color overflow.
      if ((int)color_shift < -0xFF) color_shift = -0xFF;
   
   	colour += (int)color_shift * offset1;
   	colour -= (int)color_shift * offset2;
   }

	ObjectSetInteger(0, "MP" + Suffix + LastName, OBJPROP_COLOR, colour);
	// Fills rectangle.
	ObjectSetInteger(0, "MP" + Suffix + LastName, OBJPROP_FILL, true);
	ObjectSetInteger(0, "MP" + Suffix + LastName, OBJPROP_SELECTABLE, false);
	ObjectSetInteger(0, "MP" + Suffix + LastName, OBJPROP_HIDDEN, true);
}

//+------------------------------------------------------------------+
//| Deletes all chart objects created by the indicator.              |
//+------------------------------------------------------------------+
void ObjectCleanup()
{
	// Delete all rectangles with set prefix.
	ObjectsDeleteAll(0, "MP" + Suffix, -1, OBJ_RECTANGLE);
	ObjectsDeleteAll(0, "Median" + Suffix, -1, OBJ_RECTANGLE);
	ObjectsDeleteAll(0, "Value Area" + Suffix, -1, OBJ_RECTANGLE);
	if (ShowValueAreaRays)
	{
	   // Delete all trendlines with set prefix.
	   ObjectsDeleteAll(0, "Value Area HighRay" + Suffix, -1, OBJ_TREND);
	   ObjectsDeleteAll(0, "Value Area LowRay" + Suffix, -1, OBJ_TREND);
	}
	if (ShowMedianRays)
	{
	   // Delete all trendlines with set prefix.
	   ObjectsDeleteAll(0, "Median HighRay" + Suffix, -1, OBJ_TREND);
	   ObjectsDeleteAll(0, "Median LowRay" + Suffix, -1, OBJ_TREND);
	}
}

//+------------------------------------------------------------------+
//| Extract hours and minutes from a time string.                    |
//| Returns false in case of an error.                               |
//+------------------------------------------------------------------+
bool GetHoursAndMinutes(string time_string, int& hours, int& minutes, int& time)
{
	if (StringLen(time_string) == 4) time_string = "0" + time_string;
	
	if ( 
		// Wrong length.
		(StringLen(time_string) != 5) ||
		// Wrong separator.
		(time_string[2] != ':') ||
		// Wrong first number (only 24 hours in a day).
		((time_string[0] < '0') || (time_string[0] > '2')) ||
		// 00 to 09 and 10 to 19.
		(((time_string[0] == '0') || (time_string[0] == '1')) && ((time_string[1] < '0') || (time_string[1] > '9'))) ||
		// 20 to 23.
		((time_string[0] == '2') && ((time_string[1] < '0') || (time_string[1] > '3'))) ||
		// 0M to 5M.
		((time_string[3] < '0') || (time_string[3] > '5')) ||
		// M0 to M9.
		((time_string[4] < '0') || (time_string[4] > '9'))
		)
   {
      Print("Wrong time string: ", time_string, ". Please use HH:MM format.");
      return(false);
   }

   string result[];
   int number_of_substrings = StringSplit(time_string, ':', result);
   hours = (int)StringToInteger(result[0]);
   minutes = (int)StringToInteger(result[1]);
   time = hours * 60 + minutes;
   
   return(true);
}

//+------------------------------------------------------------------+
//| Extract hours and minutes from a time string.                    |
//| Returns false in case of an error.                               |
//+------------------------------------------------------------------+
bool CheckIntradaySession(const bool enable, const string start_time, const string end_time, const color_scheme cs)
{
	if (enable)
	{
		if (!GetHoursAndMinutes(start_time, IDStartHours[IntradaySessionCount], IDStartMinutes[IntradaySessionCount], IDStartTime[IntradaySessionCount]))
		{
		   Alert("Wrong time string format: ", start_time, ".");
		   return(false);
		}
		if (!GetHoursAndMinutes(end_time, IDEndHours[IntradaySessionCount], IDEndMinutes[IntradaySessionCount], IDEndTime[IntradaySessionCount]))
		{
		   Alert("Wrong time string format: ", end_time, ".");
		   return(false);
		}
		// Special case of the intraday session ending at "00:00".
		if (IDEndTime[IntradaySessionCount] == 0)
		{
		   // Turn it into "24:00".
		   IDEndHours[IntradaySessionCount] = 24;
		   IDEndMinutes[IntradaySessionCount] = 0;
		   IDEndTime[IntradaySessionCount] = 24 * 60;
		}
		
		IDColorScheme[IntradaySessionCount] = cs;
		IntradaySessionCount++;
	}
	return(true);
}

//+------------------------------------------------------------------+
//| Main procedure to draw the Market Profile based on a session     |
//| start bar and session end bar.                                   |
//+------------------------------------------------------------------+
bool ProcessSession(const int sessionstart, const int sessionend, const int i, const double& High[], const double& Low[], const datetime& Time[], const int rates_total)
{
   if (sessionstart + 16 >= rates_total) return(false); // Data not yet ready.

	double SessionMax = DBL_MIN, SessionMin = DBL_MAX;

	// Find the session's high and low. 
	for (int bar = sessionstart; bar >= sessionend; bar--)
	{
		if (High[bar] > SessionMax) SessionMax = High[bar];
		if (Low[bar] < SessionMin) SessionMin = Low[bar];
	}
	SessionMax = NormalizeDouble(SessionMax, DigitsM);
	SessionMin = NormalizeDouble(SessionMin, DigitsM);
			
	int TPOperPrice[];
	// Possible price levels if multiplied to integer.
	int max = (int)MathRound(SessionMax / onetick + 2); // + 2 because further we will be possibly checking array at SessionMax + 1.
	ArrayResize(TPOperPrice, max);
	ArrayInitialize(TPOperPrice, 0);

	int MaxRange = 0; // Maximum distance from session start to the drawn dot.
	double PriceOfMaxRange = 0; // Level of the maximum range, required to draw Median.
	double DistanceToCenter = DBL_MAX; // Closest distance to center for the Median.
	
	int TotalTPO = 0; // Total amount of dots (TPO's).
	
	// Going through all possible quotes from session's High to session's Low.
	for (double price = SessionMax; price >= SessionMin; price -= onetick)
	{
		int range = 0; // Distance from first bar to the current bar

		// Going through all bars of the session to see if the price was encountered here.
		for (int bar = sessionstart; bar >= sessionend; bar--)
		{
			// Price is encountered in the given bar.
			if ((price >= Low[bar]) && (price <= High[bar]))
			{
				// Update maximum distance from session's start to the found bar (needed for Median).
            // Using the center-most Median if there are more than one.
				if ((MaxRange < range) || ((MaxRange == range) && (MathAbs(price - (SessionMin + (SessionMax - SessionMin) / 2)) < DistanceToCenter)))
				{
					MaxRange = range;
					PriceOfMaxRange = price;
					DistanceToCenter = MathAbs(price - (SessionMin + (SessionMax - SessionMin) / 2));
				}
				// Draws rectangle.
				PutDot(price, sessionstart, range, bar - sessionstart, Time);
				// Remember the number of encountered bars for this price.
				TPOperPrice[(int)(price / onetick)]++;
				range++;
				TotalTPO++;
			}
		}
	}

	// Calculate amount of TPO's in the Value Area.
	int ValueControlTPO = (int)((double)TotalTPO * 0.7);
	// Start with the TPO's of the Median.
	int TPOcount = TPOperPrice[(int)(PriceOfMaxRange / onetick)];

	// Go through the price levels above and below median adding the biggest to TPO count until the 70% of TPOs are inside the Value Area.
	int up_offset = 1;
	int down_offset = 1;
	while (TPOcount < ValueControlTPO)
	{
		double abovePrice = PriceOfMaxRange + up_offset * onetick;
		double belowPrice = PriceOfMaxRange - down_offset * onetick;
		// If belowPrice is out of the session's range then we should add only abovePrice's TPO's, and vice versa.
		if (((TPOperPrice[(int)(abovePrice / onetick)] >= TPOperPrice[(int)(belowPrice / onetick)]) || (belowPrice < SessionMin)) && (abovePrice <= SessionMax))
		{
			TPOcount += TPOperPrice[(int)(abovePrice / onetick)];
			up_offset++;
		}
		else
		{
			TPOcount += TPOperPrice[(int)(belowPrice / onetick)];
			down_offset++;
		}
	}
	string LastName = " " + TimeToString(Time[sessionstart], TIME_DATE);
	// Delete old Median.
	if (ObjectFind(0, "Median" + Suffix + LastName) >= 0) ObjectDelete(0, "Median" + Suffix + LastName);
	// Draw a new one.
	ObjectCreate(0, "Median" + Suffix + LastName, OBJ_RECTANGLE, 0, Time[sessionstart + 16], PriceOfMaxRange, Time[(int)(MathMax(sessionstart - MaxRange - 5, 0))], PriceOfMaxRange + _Point);
	ObjectSetInteger(0, "Median" + Suffix + LastName, OBJPROP_COLOR, MedianColor);
	ObjectSetInteger(0, "Median" + Suffix + LastName, OBJPROP_STYLE, STYLE_SOLID);
	ObjectSetInteger(0, "Median" + Suffix + LastName, OBJPROP_SELECTABLE, false);
	ObjectSetInteger(0, "Median" + Suffix + LastName, OBJPROP_HIDDEN, true);

   // If the median rays have to be created and it is the last session before the most recent one:
   if ((ShowMedianRays) && (SessionsToCount - i == 2))
   {
   	// Delete old Median Rays.
   	if (ObjectFind(0, "Median HighRay" + Suffix) >= 0) ObjectDelete(0, "Median HighRay" + Suffix);
   	if (ObjectFind(0, "Median LowRay" + Suffix) >= 0) ObjectDelete(0, "Median LowRay" + Suffix);
   	// Draw a new Median High Ray.
   	ObjectCreate(0, "Median HighRay" + Suffix, OBJ_TREND, 0, Time[sessionstart], PriceOfMaxRange + _Point, Time[sessionstart - (MaxRange + 1)], PriceOfMaxRange + _Point);
   	ObjectSetInteger(0, "Median HighRay" + Suffix, OBJPROP_COLOR, MedianColor);
   	ObjectSetInteger(0, "Median HighRay" + Suffix, OBJPROP_STYLE, STYLE_DASH);
   	ObjectSetInteger(0, "Median HighRay" + Suffix, OBJPROP_BACK, false);
   	ObjectSetInteger(0, "Median HighRay" + Suffix, OBJPROP_SELECTABLE, false);
   	ObjectSetInteger(0, "Median HighRay" + Suffix, OBJPROP_RAY_RIGHT, true);
   	ObjectSetInteger(0, "Median HighRay" + Suffix, OBJPROP_HIDDEN, true);
   	// Draw a new Median Low Ray.
   	ObjectCreate(0, "Median LowRay" + Suffix, OBJ_TREND, 0, Time[sessionstart], PriceOfMaxRange, Time[sessionstart - (MaxRange + 1)], PriceOfMaxRange);
   	ObjectSetInteger(0, "Median LowRay" + Suffix, OBJPROP_COLOR, MedianColor);
   	ObjectSetInteger(0, "Median LowRay" + Suffix, OBJPROP_STYLE, STYLE_DASH);
   	ObjectSetInteger(0, "Median LowRay" + Suffix, OBJPROP_BACK, false);
   	ObjectSetInteger(0, "Median LowRay" + Suffix, OBJPROP_SELECTABLE, false);
   	ObjectSetInteger(0, "Median LowRay" + Suffix, OBJPROP_RAY_RIGHT, true);
   	ObjectSetInteger(0, "Median LowRay" + Suffix, OBJPROP_HIDDEN, true);
   }
	
	// Protection from 'Array out of range' error.
	if (sessionstart - (MaxRange + 1) < 0) return(true);

	// Delete old Value Area.
	if (ObjectFind(0, "Value Area" + Suffix + LastName) >= 0) ObjectDelete(0, "Value Area" + Suffix + LastName);
	// Draw a new one.
	ObjectCreate(0, "Value Area" + Suffix + LastName, OBJ_RECTANGLE, 0, Time[sessionstart], PriceOfMaxRange + up_offset * onetick, Time[sessionstart - (MaxRange + 1)], PriceOfMaxRange - down_offset * onetick);
	ObjectSetInteger(0, "Value Area" + Suffix + LastName, OBJPROP_COLOR, ValueAreaColor);
	ObjectSetInteger(0, "Value Area" + Suffix + LastName, OBJPROP_FILL, false);
	ObjectSetInteger(0, "Value Area" + Suffix + LastName, OBJPROP_SELECTABLE, false);
	ObjectSetInteger(0, "Value Area" + Suffix + LastName, OBJPROP_HIDDEN, true);

   // If value area rays have to be created and it is the last session before the most recent one:
   if ((ShowValueAreaRays) && (SessionsToCount - i == 2))
   {
   	// Delete old Value Area Rays.
   	if (ObjectFind(0, "Value Area HighRay" + Suffix) >= 0) ObjectDelete(0, "Value Area HighRay" + Suffix);
   	if (ObjectFind(0, "Value Area LowRay" + Suffix) >= 0) ObjectDelete(0, "Value Area LowRay" + Suffix);
   	// Draw a new Value Area High Ray.
   	ObjectCreate(0, "Value Area HighRay" + Suffix, OBJ_TREND, 0, Time[sessionstart], PriceOfMaxRange + up_offset * onetick, Time[sessionstart - (MaxRange + 1)], PriceOfMaxRange + up_offset * onetick);
   	ObjectSetInteger(0, "Value Area HighRay" + Suffix, OBJPROP_COLOR, ValueAreaColor);
   	ObjectSetInteger(0, "Value Area HighRay" + Suffix, OBJPROP_STYLE, STYLE_DOT);
   	ObjectSetInteger(0, "Value Area HighRay" + Suffix, OBJPROP_BACK, false);
   	ObjectSetInteger(0, "Value Area HighRay" + Suffix, OBJPROP_SELECTABLE, false);
   	ObjectSetInteger(0, "Value Area HighRay" + Suffix, OBJPROP_RAY_RIGHT, true);
   	ObjectSetInteger(0, "Value Area HighRay" + Suffix, OBJPROP_HIDDEN, true);   	
   	// Draw a new Value Area Low Ray.
   	ObjectCreate(0, "Value Area LowRay" + Suffix, OBJ_TREND, 0, Time[sessionstart], PriceOfMaxRange - down_offset * onetick, Time[sessionstart - (MaxRange + 1)], PriceOfMaxRange - down_offset * onetick);
   	ObjectSetInteger(0, "Value Area LowRay" + Suffix, OBJPROP_COLOR, ValueAreaColor);
   	ObjectSetInteger(0, "Value Area LowRay" + Suffix, OBJPROP_STYLE, STYLE_DOT);
   	ObjectSetInteger(0, "Value Area LowRay" + Suffix, OBJPROP_BACK, false);
   	ObjectSetInteger(0, "Value Area LowRay" + Suffix, OBJPROP_SELECTABLE, false);
   	ObjectSetInteger(0, "Value Area LowRay" + Suffix, OBJPROP_RAY_RIGHT, true);
   	ObjectSetInteger(0, "Value Area LowRay" + Suffix, OBJPROP_HIDDEN, true);
   }
   return(true);
}

//+------------------------------------------------------------------+
//| A cycle through intraday sessions with necessary checks.         |
//| Returns true on success, false - on failure.                     |
//+------------------------------------------------------------------+
bool ProcessIntradaySession(int sessionstart, int sessionend, const int i, const double& High[], const double& Low[], const datetime& Time[], const int rates_total)
{
   int remember_sessionstart = sessionstart;
   int remember_sessionend = sessionend;
   
   // Start a cycle through intraday sessions if needed.
   // For each intraday session, find its own sessionstart and sessionend.
   for (int intraday_i = 0; intraday_i < IntradaySessionCount; intraday_i++)
   {
      Suffix = "_ID" + IntegerToString(intraday_i);
      CurrentColorScheme = IDColorScheme[intraday_i];
      // Get minutes.
      Max_number_of_bars_in_a_session = IDEndTime[intraday_i] - IDStartTime[intraday_i];
      // If end is less than beginning:
      if (Max_number_of_bars_in_a_session < 0) Max_number_of_bars_in_a_session = 24 * 60 + Max_number_of_bars_in_a_session;
      Max_number_of_bars_in_a_session = Max_number_of_bars_in_a_session / (PeriodSeconds() / 60);
      
      // If it is the updating stage, we need to recalculate only those intraday sessions that include the current bar.
      int hour, minute, time;
      if (FirstRunDone)
      {
         //sessionstart = day_start;
         MqlDateTime Time0;
         TimeToStruct(Time[0], Time0);
         hour = Time0.hour;
         minute = Time0.min;
         time = hour * 60 + minute;
      
         // For example, 13:00-18:00.
         if (IDStartTime[intraday_i] < IDEndTime[intraday_i])
         {
            if ((time < IDEndTime[intraday_i]) && (time >= IDStartTime[intraday_i]))
            {
               sessionstart = 0;
               MqlDateTime Time_sessionstart;
               TimeToStruct(Time[sessionstart], Time_sessionstart);
               int sessiontime = Time_sessionstart.hour * 60 + Time_sessionstart.min;
               while((sessiontime > IDStartTime[intraday_i]) 
               // Prevents problems when the day has partial data (e.g. Sunday).
               && (Time_sessionstart.day_of_year == Time0.day_of_year))
               {
                  sessionstart++;
                  TimeToStruct(Time[sessionstart], Time_sessionstart);
                  sessiontime = Time_sessionstart.hour * 60 + Time_sessionstart.min;
               }
            }
            else continue;
         }
         // For example, 22:00-6:00.
         else if (IDStartTime[intraday_i] > IDEndTime[intraday_i])
         {
            if ((time < IDEndTime[intraday_i]) || (time >= IDStartTime[intraday_i]))
            {
               sessionstart = 0;
               MqlDateTime Time_sessionstart;
               TimeToStruct(Time[sessionstart], Time_sessionstart);
               int sessiontime = Time_sessionstart.hour * 60 + Time_sessionstart.min;
               // Within 24 hours of the current time - but can be today or yesterday.
               while(((sessiontime > IDStartTime[intraday_i]) && (Time[0] - Time[sessionstart] <= 3600 * 24)) 
               // Same day only.
               || ((sessiontime < IDEndTime[intraday_i]) && (Time_sessionstart.day_of_year == Time0.day_of_year)))
               {
                  sessionstart++;
                  TimeToStruct(Time[sessionstart], Time_sessionstart);
                  sessiontime = Time_sessionstart.hour * 60 + Time_sessionstart.min;
               }
            }
            else continue;
         }
         // If start time equals end time, we can skip the session.
         else continue;
         
         // Because apparently, we are still inside the session.
         sessionend = 0;
         if (sessionend == sessionstart) continue; // No need to process such an intraday session.

         if (!ProcessSession(sessionstart, sessionend, i, High, Low, Time, rates_total)) return(false);
      }
      // If it is the first run.
      else
      {
         sessionend = remember_sessionend;
         
         // Process the sessions that start today.
         // For example, 13:00-18:00.
         if (IDStartTime[intraday_i] < IDEndTime[intraday_i])
         {
            // Intraday session starts after the today's actual session ended (for Friday/Saturday cases).
            MqlDateTime Time_remember_sessionend;
            TimeToStruct(Time[remember_sessionend], Time_remember_sessionend);
            if (Time_remember_sessionend.hour * 60 + Time_remember_sessionend.min < IDStartTime[intraday_i]) continue;
            // Intraday session ends before the today's actual session starts (for Sunday cases).
            MqlDateTime Time_remember_sessionstart;
            TimeToStruct(Time[remember_sessionstart], Time_remember_sessionstart);
            if (Time_remember_sessionstart.hour * 60 + Time_remember_sessionstart.min >= IDEndTime[intraday_i]) continue;
            
            MqlDateTime Time_sessionend;
            TimeToStruct(Time[sessionend], Time_sessionend);
            while((sessionend < rates_total) && (Time_sessionend.hour * 60 + Time_sessionend.min > IDEndTime[intraday_i]))
            {
               sessionend++;
               if (sessionend < rates_total) TimeToStruct(Time[sessionend], Time_sessionend);
            }
            if (sessionend == rates_total) sessionend--;

            sessionstart = sessionend;
            MqlDateTime Time_sessionstart;
            TimeToStruct(Time[sessionstart], Time_sessionstart);
            TimeToStruct(Time[sessionend], Time_sessionend);
            while((sessionstart < rates_total) && (Time_sessionstart.hour * 60 + Time_sessionstart.min >= IDStartTime[intraday_i])
            // Same day - for cases when the day does not contain intraday session start time.
            && (Time_sessionstart.day_of_year == Time_sessionend.day_of_year))
            {
               sessionstart++;
               if (sessionstart < rates_total) TimeToStruct(Time[sessionstart], Time_sessionstart);
            }
            sessionstart--;
         }
         // For example, 22:00-6:00.
         else if (IDStartTime[intraday_i] > IDEndTime[intraday_i])
         {
            // Today's intraday session starts after the end of the actual session (for Friday/Saturday cases).
            MqlDateTime Time_remember_sessionend;
            TimeToStruct(Time[remember_sessionend], Time_remember_sessionend);
            if (Time_remember_sessionend.hour * 60 + Time_remember_sessionend.min < IDStartTime[intraday_i]) continue;

            sessionstart = remember_sessionend; // Start from the end.
            MqlDateTime Time_sessionstart;
            TimeToStruct(Time[sessionstart], Time_sessionstart);
            while(((sessionstart < rates_total) && (Time_sessionstart.hour * 60 + Time_sessionstart.min >= IDStartTime[intraday_i]))
            // Same day - for cases when the day does not contain intraday session start time.
            && (Time_sessionstart.day_of_year == Time_remember_sessionend.day_of_year))
            {
               sessionstart++;
               if (sessionstart < rates_total) TimeToStruct(Time[sessionstart], Time_sessionstart);
            }
            sessionstart--;

            int sessionlength = (24 * 60 - IDStartTime[intraday_i] + IDEndTime[intraday_i]) * 60; // In seconds.
            while((sessionend >= 0) && (Time[sessionend] - Time[sessionstart] < sessionlength))
            {
               sessionend--;
            }
            sessionend++;
         }
         // If start time equals end time, we can skip the session.
         else continue;
         
         if (sessionend == sessionstart) continue; // No need to process such an intraday session.
         
         if (!ProcessSession(sessionstart, sessionend, i, High, Low, Time, rates_total)) return(false);
      }
   }
   Suffix = "_ID";
   
   return(true);
}
//+------------------------------------------------------------------+//+------------------------------------------------------------------+