//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#define DEF_VER "1.16"

#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link "https://www.mql5.com"
#property version DEF_VER
#resource "\\Indicators\\GoldRat_OFB_V2.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eType
{
	CumulativeDelta,//Cumulative Delta
	DeltaCandles,//Delta Candles
	Delta,//Delta
	Delta2,//Delta 2
	VolumePP //Volume ++ 
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eMode
{
	Auto,
	Raw
};

#include <GoldRat_Renko.mqh>
#include <ChartObjects\ChartObjectsLines.mqh>
#include <Controls\Defines.mqh>
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
//#undef CONTROLS_LABEL_COLOR  

color borda_bg = clrNONE;//Cor Borda
color painel_bg = clrBlack;//Cor Painel 
color cor_txt_borda_bg = clrYellowGreen;//Cor Texto Borda
//color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR cor_txt_pn_bg

#include <Expert_Class_New.mqh>
MyPanel ExtDialog;

CLabel m_label[50];

#define LARGURA_PAINEL 375 // Largura Painel
#define ALTURA_PAINEL 180 // Altura Painel


// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo = PERIOD_CURRENT;//TIMEFRAME ROBO
input string simbolo = "";//Símbolo Original (vazio = atual)
input int MAGIC_NUMBER = 7022019;
input ulong deviation_points = 50;//Deviation em Pontos(Padrao)
input string SEstrateg = "############-----------------------------Estratégia---------------------------########";//Estratégia
input double Lot = 1;//Lote Entrada
input double _Stop = 100;//Stop Loss em Pontos
input double _TakeProfit = 100;//Take Profit em Pontos

input string Lucro = "###----Usar Lucro/Prejuizo para Fechamento----#####"; //Lucro
input bool UsarLucro = false;//Usar Lucro para Fechamento Diário True/False
input double lucro = 1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo = 500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia

input string shorario = "############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer = true;//Usar Filtro de Horário: True/False
input string start_hour = "9:04";//Horario Inicial
input string end_hour = "17:20";//Horario Final
input bool daytrade = true;//Fechar Posicao Fim do Horario
sinput string sdias = "FILTRO DOS DIAS DA SEMANA";//Dias da Semana
input bool trade0 = true;// Operar Domingo
input bool trade1 = true;// Operar Segunda
input bool trade2 = true;// Operar Terça
input bool trade3 = true;// Operar Quarta
input bool trade4 = true;// Operar Quinta
input bool trade5 = true;// Operar Sexta
input bool trade6 = true;// Operar Sábado
sinput string sind = "----------Indicadores-----------------------";//Indicadores
sinput string sindvols = "-------------------Volumes-----------------------";//Volumes
input int per_media_vol = 9; // Período Média dos Volumes
sinput string sindmacd = "-------------------MACD-----------------------";//MACD
input int InpFastEMA = 12; // Fast EMA period
input int InpSlowEMA = 26; // Slow EMA period
input int InpSignalSMA = 9; // Signal SMA period
input ENUM_APPLIED_PRICE InpAppliedPrice = PRICE_CLOSE; // Applied price

sinput string sindagress = "-------------------Agressão-----------------------";//Agressão
input double limsup_agress = 400; // Limite Superior Agressão
input double liminf_agress = -400;// Limite Inferior Agressão
input int BarCalc = 1; //Bars

sinput bool Trailing = true;
/*
input double TrailProfitMin = 0;//Lucro Mínimo em Moeda para Iniciar Trailing
input double TrailPerc = 1;//Porcentagem Retração do Lucro para Fechar Posição
input double TrailStep = 0;
*/

sinput string Renko_ = "-------------------Renko-----------------------";//Renko
input int RenkoSize = 100; //Brick Size in Points
input bool RenkoWicks = true; //Show Wicks
input int RenkoUpdateSeconds = 5; //Update Seconds

string RenkoSymbol;
bool RenkoStarted = false;

CRenko Renko();

/*input int BarCalc=1; //Bars
input eType Type=Delta; //Indicator type
input eMode Mode=Auto; //Analysis mode
*/

eType Type = Delta; //Indicator type
eMode Mode = Auto; //Analysis mode
/*
input string DB_="-------------- Daily Balance Settings --------------"; //-------------- Daily Balance Settings --------------
input color DB_PositiveColor=clrLimeGreen; //Positive balance color
input color DB_NegativeColor=clrRed; //Negative balance color
input int DB_Width=4; //Width

input string VD_="-------------- Volume Delta Settings --------------"; //-------------- Volume Delta Settings --------------
input color VD_PositiveColor=clrLimeGreen; //Positive Delta color
input color VD_NegativeColor=clrRed; //Negative Delta color
input int VD_Width=4; //Width

input string VPP_="-------------- Volume++ Settings --------------"; //-------------- Volume++ Settings --------------
input color VPP_Color=clrSilver; //Volume color
input int VPP_Width=5; //Width
input color VPP_BuyColor=clrBlue; //Buyers volume color
input int VPP_BuyWidth=4; //Width
input color VPP_SellColor=clrMagenta; //Sellers volume color
input int VPP_SellWidth=3; //Width
input color VPP_NeutralColor=clrLime; //Neutrals volume color
input int VPP_NeutralWidth=2; //Width
*/

string DB_ = "-------------- Daily Balance Settings --------------"; //-------------- Daily Balance Settings --------------
color DB_PositiveColor = clrLimeGreen; //Positive balance color
color DB_NegativeColor = clrRed; //Negative balance color
int DB_Width = 4; //Width

string VD_ = "-------------- Volume Delta Settings --------------"; //-------------- Volume Delta Settings --------------
color VD_PositiveColor = clrLimeGreen; //Positive Delta color
color VD_NegativeColor = clrRed; //Negative Delta color
int VD_Width = 4; //Width

string VPP_ = "-------------- Volume++ Settings --------------"; //-------------- Volume++ Settings --------------
color VPP_Color = clrSilver; //Volume color
int VPP_Width = 5; //Width
color VPP_BuyColor = clrBlue; //Buyers volume color
int VPP_BuyWidth = 4; //Width
color VPP_SellColor = clrMagenta; //Sellers volume color
int VPP_SellWidth = 3; //Width
color VPP_NeutralColor = clrLime; //Neutrals volume color
int VPP_NeutralWidth = 2; //Width


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyRobot: public MyExpert
{
private:
	CChartObjectHLine HLine_Sup, HLine_Inf;
	string currency_symbol;
	double sl, tp, price_open;
	int goldrat_handle;
	long agress_chart;
	CiMACD* macd;
	CiVolumes* volumes;
	CiMA* media_vol;
	CNewBar Bar_NovoDia;
	CNewBar Bar_NovaBarra;
	double CumDeltBuff[], DeltCOpen[], DeltCClose[], DeltCHigh[], DeltCLow[];
	double DeltaBuff[], Delta2BuyBuff[], Delta2SellBuff[];
	double VolPPBuff[], VolPPBuyBuff[], VolPPSellBuff[], VolPPNeut[];

public:
	
	void MyRobot();
	void ~MyRobot();
	int OnInit();
	void OnDeinit(const int reason);
	void OnTick();

	string GetCurrency()
	{
		return SymbolInfoString(original_symbol, SYMBOL_CURRENCY_BASE);
	}

	bool TimeDayFilter();
	virtual bool GetIndValue();
	virtual bool BuySignal();
	virtual bool SellSignal();
	virtual void MytradeTransaction();
	void TrailingProfit(double pTrailPerc, double pMinProfit, double pStep);
	void TrailingBox();

	int GetOFBHandle() { return (goldrat_handle); }
	long GetOFBChart() { return (agress_chart); }
	
};

MyRobot MyEA;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::MyRobot()
{
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::~MyRobot()
{
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::OnInit(void)
{
	Print("Version ", DEF_VER);

	tradeOn = true;
	setExpName();
	setSymbol(Symbol());
	if (simbolo == "") setOriginalSymbol(Symbol());
	else setOriginalSymbol(simbolo);
	setMagic(MAGIC_NUMBER);
	if (SymbolInfoInteger(original_symbol, SYMBOL_EXPIRATION_MODE) == 2)order_time_type = 1;
	else order_time_type = 0;
	mysymbol.Name(original_symbol);
	mytrade.SetExpertMagicNumber(MAGIC_NUMBER);
	mytrade.SetDeviationInPoints(50);
	mytrade.LogLevel(LOG_LEVEL_ERRORS);
	mytrade.SetTypeFillingBySymbol(original_symbol);
	ponto = SymbolInfoDouble(original_symbol, SYMBOL_POINT);
	ticksize = SymbolInfoDouble(original_symbol, SYMBOL_TRADE_TICK_SIZE);
	digits = (int)SymbolInfoInteger(original_symbol, SYMBOL_DIGITS);

	int find_wdo = StringFind(original_symbol, "WDO");
	int find_dol = StringFind(original_symbol, "DOL");
	if (find_dol >= 0 || find_wdo >= 0) ponto = 1.0;
	gv.Init(symbol, Magic_Number);
	TimeToStruct(TimeCurrent(), TimeNow);
	gv.Set("gv_today_prev", (double)TimeNow.day_of_year);
	hora_inicial = StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " + start_hour);
	hora_final = StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " + end_hour);
	setNameGvOrder();

	long curChartID = ChartID();
	agress_chart = ChartGetInteger(curChartID, CHART_WINDOWS_TOTAL);
	goldrat_handle = iCustom(Symbol(), periodoRobo, "::Indicators\\GoldRat_OFB_V2.ex5", original_symbol, BarCalc, Type, Mode, "", DB_PositiveColor, DB_NegativeColor, DB_Width, "",
	                         VD_PositiveColor, VD_NegativeColor, VD_Width, "", VPP_Color, VPP_Width, VPP_BuyColor, VPP_BuyWidth, VPP_SellColor,
	                         VPP_SellWidth, VPP_NeutralColor, VPP_NeutralWidth);

	ChartIndicatorAdd(curChartID, (int)agress_chart, goldrat_handle);

	volumes = new CiVolumes;
	volumes.Create(Symbol(), periodoRobo, VOLUME_REAL);
	long volChartID = ChartGetInteger(curChartID, CHART_WINDOWS_TOTAL);
	volumes.AddToChart(curChartID, (int)volChartID);

	media_vol = new CiMA;
	media_vol.Create(Symbol(), periodoRobo, per_media_vol, 0, MODE_EMA, volumes.Handle());
	media_vol.AddToChart(curChartID, (int)volChartID);


	macd = new CiMACD;
	macd.Create(Symbol(), periodoRobo, InpFastEMA, InpSlowEMA, InpSignalSMA, InpAppliedPrice);
	macd.AddToChart(curChartID, (int)ChartGetInteger(curChartID, CHART_WINDOWS_TOTAL));


	ArraySetAsSeries(close, true);
	ArraySetAsSeries(high, true);
	ArraySetAsSeries(low, true);
	ArraySetAsSeries(open, true);

	ArraySetAsSeries(CumDeltBuff, true);
	ArraySetAsSeries(DeltCOpen, true);
	ArraySetAsSeries(DeltCClose, true);
	ArraySetAsSeries(DeltCHigh, true);
	ArraySetAsSeries(DeltCLow, true);
	ArraySetAsSeries(DeltaBuff, true);
	ArraySetAsSeries(Delta2BuyBuff, true);
	ArraySetAsSeries(Delta2SellBuff, true);
	ArraySetAsSeries(VolPPBuff, true);
	ArraySetAsSeries(VolPPBuyBuff, true);
	ArraySetAsSeries(VolPPSellBuff, true);
	ArraySetAsSeries(VolPPNeut, true);

	ChartSetInteger(ChartID(), CHART_SHOW_TRADE_LEVELS, true);
	ChartSetInteger(ChartID(), CHART_DRAG_TRADE_LEVELS, true);
	ChartSetInteger(ChartID(), CHART_COLOR_STOP_LEVEL, clrRed);

	//+------------------------------------------------------------------+
	//|                                                                  |
	//+------------------------------------------------------------------+

	if (hora_inicial >= hora_final)
	{
		string erro = "Hora Inicial deve ser Menor que Hora Final";
		MessageBox(erro);
		Print(erro);
		return (INIT_PARAMETERS_INCORRECT);
	}

	if (limsup_agress <= 0)
	{
		string erro = "Limite Superior de Agressão deve ser >0";
		MessageBox(erro);
		Print(erro);
		return (INIT_PARAMETERS_INCORRECT);
	}

	if (liminf_agress >= 0)
	{
		string erro = "Limite Inferior de Agressão deve ser <0";
		MessageBox(erro);
		Print(erro);
		return (INIT_PARAMETERS_INCORRECT);
	}

	HLine_Sup.Create(0, "Lim Sup Agressão", (int)agress_chart, limsup_agress);
	HLine_Inf.Create(0, "Lim Inf Agressão", (int)agress_chart, liminf_agress);
	HLine_Inf.Color(clrBlue);
	HLine_Sup.Color(clrBlue);
	//+------------------------------------------------------------------+
	//|                                                                  |
	//+------------------------------------------------------------------+
	if (Lot < mysymbol.LotsMin())
	{
		string erro = "Lote deve ser maior ou igual a " + DoubleToString(mysymbol.LotsMin(), 2);
		MessageBox(erro);
		Print(erro);
		return (INIT_PARAMETERS_INCORRECT);
	}

	if (HistorySelect(iTime(original_symbol, PERIOD_D1, 0), TimeCurrent() + PeriodSeconds(PERIOD_D1)))
	{
		int total_deals = HistoryDealsTotal();
		ulong ticket_history_deal = 0;
		int cont_deals = 0;
		for (int i = 0; i < total_deals; i++)
		{
			//--- try to get deals ticket_history_deal
			if ((ticket_history_deal = HistoryDealGetTicket(i)) > 0)
			{
				long deal_magic = HistoryDealGetInteger(ticket_history_deal, DEAL_MAGIC);
				if (deal_magic == Magic_Number && HistoryDealGetString(ticket_history_deal, DEAL_SYMBOL) == mysymbol.Name())cont_deals += 1;
			}
		}
		gv.Set("deals_total_prev", (double)cont_deals);
	}

	return (INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(const int reason)
{
	gv.Deinit();
	delete(volumes);
	delete(macd);
	delete(media_vol);
	IndicatorRelease(goldrat_handle);
	DeletaIndicadores();
	int k = ObjectsDeleteAll(0, "", 0, OBJ_HLINE);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTick(void)
{
	TimeToStruct(TimeCurrent(), TimeNow);
	gv.Set("gv_today", (double)TimeNow.day_of_year);

	bool novodia;
	novodia = Bar_NovoDia.CheckNewBar(original_symbol, PERIOD_D1);
	if (novodia || gv.Get("gv_today") != gv.Get("gv_today_prev"))
	{
		gv.Set("glob_entr_tot", 0.0);
		gv.Set("deals_total_prev", 0.0);
		tradeOn = true;
	}

	gv.Set("gv_today_prev", gv.Get("gv_today"));

	MytradeTransaction();

	mysymbol.Refresh();
	mysymbol.RefreshRates();
	if (CheckPointer(volumes) != POINTER_INVALID) volumes.Refresh();
	if (CheckPointer(macd) != POINTER_INVALID) macd.Refresh();
	if (CheckPointer(media_vol) != POINTER_INVALID) media_vol.Refresh();
	bid = mysymbol.Bid();
	ask = mysymbol.Ask();
	if (bid == 0 || ask == 0)
	{
		//Print("BID ou ASK=0 : ", bid, " ", ask);
		return;
	}

	//   ExtDialog.OnTick();

	hora_inicial = StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " + start_hour);
	hora_final = StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " + end_hour);

	if (GetIndValue())
	{
		Print("Error in obtain indicators buffers or price rates");
		return;
	}

	//+------------------------------------------------------------------+
	//|                                                                  |
	//+------------------------------------------------------------------+

	lucro_total = LucroTotal();
	lucro_total_semana = LucroTotalSemana();
	lucro_total_mes = LucroTotalMes();

	//+------------------------------------------------------------------+
	//|                                                                  |
	//+------------------------------------------------------------------+
	if (UsarLucro && (lucro_total >= lucro || lucro_total <= -prejuizo))
	{
		CloseALL();
		if (OrdersTotal() > 0)DeleteALL();
		tradeOn = false;
	}

	timerOn = true;

	//+------------------------------------------------------------------+
	//|                                                                  |
	//+------------------------------------------------------------------+
	if (UseTimer)
	{
		timerOn = TimeCurrent() >= hora_inicial && TimeCurrent() <= hora_final && TimeDayFilter();
	}

	if (!PosicaoAberta())
	{
		DeleteOrdersExEntry();
	}

	//+------------------------------------------------------------------+
	//|                                                                  |
	//+------------------------------------------------------------------+


	if (!timerOn && daytrade)
	{
		if (OrdersTotal() > 0)DeleteALL();
		if (PositionsTotal() > 0)CloseALL();
	}
	if (Buy_opened() && Sell_opened())CloseByPosition();

	if (tradeOn && timerOn)
	{// inicio Trade On
		static bool gotIndVal = true;
		if (!gotIndVal || Bar_NovaBarra.CheckNewBar(symbol, periodoRobo))
		{
			gotIndVal = false;
			Sleep(5000);
			// Update indicators values
			if (GetIndValue()) return;
			gotIndVal = true;

			if (BuySignal() && !Buy_opened())
			{
				if (Sell_opened())ClosePosType(POSITION_TYPE_SELL);
				sl = NormalizeDouble(mysymbol.Ask() - _Stop * ponto, digits);
				tp = NormalizeDouble(mysymbol.Ask() + _TakeProfit * ponto, digits);
				if (mytrade.Buy(Lot, original_symbol, 0, sl, tp, "BUY" + exp_name))gv.Set(cp_tick, (double)mytrade.ResultOrder());
				else Print("Erro enviar ordem Compra: ", GetLastError());
			}

			if (SellSignal() && !Sell_opened())
			{
				if (Buy_opened())ClosePosType(POSITION_TYPE_BUY);
				sl = NormalizeDouble(mysymbol.Bid() + _Stop * ponto, digits);
				tp = NormalizeDouble(mysymbol.Bid() - _TakeProfit * ponto, digits);
				if (mytrade.Sell(Lot, original_symbol, 0, sl, tp, "SELL" + exp_name))gv.Set(vd_tick, (double)mytrade.ResultOrder());
				else Print("Erro enviar ordem Venda: ", GetLastError());
			}
			
			//Trailing
			if (Trailing) TrailingBox();
			
		}//End NewBar
	}//End Trade On

	//if (TrailPerc > 0) TrailingProfit(TrailPerc, TrailProfitMin, TrailStep);
}//Fim Ontick
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool MyRobot::GetIndValue()
{
	bool b_get, b_agress;
	b_get = CopyHigh(Symbol(), period, 0, 5, high) <= 0 ||
		CopyOpen(Symbol(), period, 0, 5, open) <= 0 ||
		CopyLow(Symbol(), period, 0, 5, low) <= 0 ||
		CopyClose(Symbol(), period, 0, 5, close) <= 0;
	b_agress = false;
	switch (Type)
	{
	case CumulativeDelta:
		b_agress = CopyBuffer(goldrat_handle, 0, 0, 5, CumDeltBuff) <= 0;
		break;
	case DeltaCandles:
		b_agress = CopyBuffer(goldrat_handle, 0, 0, 5, DeltCOpen) <= 0 ||
			CopyBuffer(goldrat_handle, 1, 0, 5, DeltCHigh) <= 0 ||
			CopyBuffer(goldrat_handle, 2, 0, 5, DeltCLow) <= 0 ||
			CopyBuffer(goldrat_handle, 3, 0, 5, DeltCClose) <= 0;
		break;
	case Delta:
		b_agress = CopyBuffer(goldrat_handle, 0, 0, 5, DeltaBuff) <= 0;
		break;
	case Delta2:
		b_agress = CopyBuffer(goldrat_handle, 0, 0, 5, Delta2BuyBuff) <= 0 ||
			CopyBuffer(goldrat_handle, 1, 0, 5, Delta2SellBuff) <= 0;
		break;
	case VolumePP:
		b_agress = CopyBuffer(goldrat_handle, 0, 0, 5, VolPPBuff) <= 0 ||
			CopyBuffer(goldrat_handle, 1, 0, 5, VolPPBuyBuff) <= 0 ||
			CopyBuffer(goldrat_handle, 2, 0, 5, VolPPSellBuff) <= 0 ||
			CopyBuffer(goldrat_handle, 3, 0, 5, VolPPNeut) <= 0;
		break;
	}
	b_get = b_get || b_agress;
	return(b_get);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::TimeDayFilter()
{
	bool filter;
	MqlDateTime TimeToday;
	TimeToStruct(TimeCurrent(), TimeToday);
	switch (TimeToday.day_of_week)
	{
	case 0:
		filter = trade0;
		break;
	case 1:
		filter = trade1;
		break;
	case 2:
		filter = trade2;
		break;
	case 3:
		filter = trade3;
		break;
	case 4:
		filter = trade4;
		break;
	case 5:
		filter = trade5;
		break;
	case 6:
		filter = trade6;
		break;
	default:
		filter = false;
		break;
	}
	return filter;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::BuySignal()
{
	bool signal;
	datetime dt = iTime(_Symbol, _Period, 1);
	double v = volumes.Main(0);
	double mv = media_vol.Main(0);
	double main = macd.Main(0);
	double sig = macd.Signal(0);
	signal = v > mv && close[1] > open[1] && main > sig && DeltaBuff[1] > limsup_agress;
Print("BuySignal=", signal, ": vol=", v, ", MAvol=", mv, ", MACD=", main, ", Signal=", sig, ", Open=", open[1], ", Close=", close[1], ", Delta=", DeltaBuff[1]);
	return signal;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
{
	bool signal;
	datetime dt = iTime(_Symbol, _Period, 1);
	double v = volumes.Main(0);
	double mv = media_vol.Main(0);
	double main = macd.Main(0);
	double sig = macd.Signal(0);
	signal = v > mv && close[1] < open[1] && main < sig && DeltaBuff[1] < liminf_agress;
Print("SellSignal=", signal, ": vol=", v, ", MAvol=", mv, ", MACD=", main, ", Signal=", sig, ", Open=", open[1], ", Close=", close[1], ", Delta=", DeltaBuff[1]);
	return signal;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::MytradeTransaction()
{
	ulong order_ticket;
	ulong deals_ticket;
	uint total_deals, cont_deals;
	ulong ticket_history_deal, deal_magic;
	double buyprice, sellprice;
	int TENTATIVAS = 10;

	if (HistorySelect(iTime(original_symbol, PERIOD_D1, 0), TimeCurrent()))
	{
		total_deals = HistoryDealsTotal();
		ticket_history_deal = 0;
		deals_ticket = 0;
		cont_deals = 0;
		for (uint i = 0; i < total_deals; i++)
		{
			ticket_history_deal = HistoryDealGetTicket(i);

			//--- try to get deals ticket_history_deal
			if ((ticket_history_deal = HistoryDealGetTicket(i)) > 0)
			{
				deal_magic = HistoryDealGetInteger(ticket_history_deal, DEAL_MAGIC);
				if (deal_magic == Magic_Number && HistoryDealGetString(ticket_history_deal, DEAL_SYMBOL) == mysymbol.Name())
				{
					cont_deals += 1;
					deals_ticket = ticket_history_deal;
				}
			}
		}

		gv.Set("deals_total", (double)cont_deals);

		if (gv.Get("deals_total") > gv.Get("deals_total_prev"))
		{
			if (deals_ticket > 0)
			{
				mydeal.Ticket(deals_ticket);
				order_ticket = mydeal.Order();

				if (mydeal.Comment() == "BUY" + exp_name || mydeal.Comment() == "SELL" + exp_name)
				{
					gv.Set("glob_entr_tot", gv.Get("glob_entr_tot") + 1);
				}

				if (mydeal.Comment() == "BUY" + exp_name)
				{
					DeleteOrdersComment("BUY" + exp_name);
					myposition.SelectByTicket(order_ticket);
					int cont = 0;
					buyprice = 0;
					while (buyprice == 0 && cont < TENTATIVAS)
					{
						buyprice = myposition.PriceOpen();
						cont += 1;
					}
					if (buyprice == 0)buyprice = mysymbol.Ask();
				}
				//--------------------------------------------------

				if (mydeal.Comment() == "SELL" + exp_name)
				{
					DeleteOrdersComment("SELL" + exp_name);
					myposition.SelectByTicket(order_ticket);
					sellprice = myposition.PriceOpen();
					int cont = 0;
					sellprice = 0;
					while (sellprice == 0 && cont < TENTATIVAS)
					{
						sellprice = myposition.PriceOpen();
						cont += 1;
					}
					if (sellprice == 0)sellprice = mysymbol.Bid();
				}

				if ((mydeal.DealType() == DEAL_TYPE_BUY || mydeal.DealType() == DEAL_TYPE_SELL) && mydeal.Entry() == DEAL_ENTRY_OUT)
				{
					if (mydeal.Profit() < 0)
					{
						Print("Saída por STOP LOSS");
					}

					if (mydeal.Profit() > 0)
					{
						Print("Saída no GAIN");
					}
				}
			}// if dealsticket>0
		}//Fim deals>prev
	}//Fim HistorySelect
	gv.Set("deals_total_prev", gv.Get("deals_total"));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::TrailingProfit(double pTrailPerc, double pMinProfit, double pStep)
{
	for (int i = PositionsTotal() - 1; i >= 0; i--)
	{
		if (myposition.SelectByIndex(i) && myposition.Symbol() == mysymbol.Name() && myposition.Magic() == Magic_Number)
		{
			long posType = myposition.PositionType();
			double lots = myposition.Volume();
			double currentStop = myposition.StopLoss();
			double openPrice = NormalizeDouble(MathRound(myposition.PriceOpen() / ticksize) * ticksize, digits);
			double point = ponto;
			digits = mysymbol.Digits();

			double trailStopPrice;
			double trailStop;
			double currentProfit = myposition.Profit();
			if (posType == POSITION_TYPE_BUY)
			{
				trailStopPrice = (bid - currentStop) * myposition.Volume() * ponto * mysymbol.TickValue() / ticksize;

				if ((1 - pTrailPerc * 0.01) * currentProfit < trailStopPrice + (1 - pTrailPerc * 0.01) * pStep && currentProfit >= pMinProfit)
				{
					trailStop = (currentProfit * pTrailPerc * 0.01 * ticksize / mysymbol.TickValue()) * ponto;
					trailStop = trailStop / myposition.Volume();
					trailStop = MathRound(trailStop / ticksize) * ticksize;
					trailStopPrice = NormalizeDouble(bid - trailStop * ponto, digits);
					if (trailStopPrice > currentStop) mytrade.PositionModify(myposition.Ticket(), trailStopPrice, myposition.TakeProfit());
				}
			}
			else if (posType == POSITION_TYPE_SELL)
			{
				trailStopPrice = (currentStop - ask) * myposition.Volume() * ponto * mysymbol.TickValue() / ticksize;
				if ((1 - pTrailPerc * 0.01) * currentProfit < trailStopPrice + (1 - pTrailPerc * 0.01) * pStep && currentProfit >= pMinProfit)
				{
					trailStop = (currentProfit * pTrailPerc * 0.01 * ticksize / mysymbol.TickValue()) * ponto;
					trailStop = trailStop / myposition.Volume();
					trailStop = MathRound(trailStop / ticksize) * ticksize;
					trailStopPrice = NormalizeDouble(ask + trailStop * ponto, digits);
					if (trailStopPrice < currentStop) mytrade.PositionModify(myposition.Ticket(), trailStopPrice, myposition.TakeProfit());
				}
			}
		}
	}
}


void MyRobot::TrailingBox()
{
	bool up = iOpen(_Symbol, _Period, 1) < iClose(_Symbol, _Period, 1);
	double stop = (up ? MathMin(iOpen(_Symbol, _Period, 2), iClose(_Symbol, _Period, 2)) : MathMax(iOpen(_Symbol, _Period, 2), iClose(_Symbol, _Period, 2)));
	if ((up && stop >= iOpen(_Symbol, _Period, 1)) || (!up && stop <= iClose(_Symbol, _Period, 1))) return;
	for (int i = PositionsTotal() - 1; i >= 0; i--)
	{
		if (myposition.SelectByIndex(i) && myposition.Symbol() == mysymbol.Name() && myposition.Magic() == Magic_Number)
		{
			long posType = myposition.PositionType();
			double currentStop = myposition.StopLoss();
			if (posType == POSITION_TYPE_BUY && up)
			{
				if (stop > currentStop) mytrade.PositionModify(myposition.Ticket(), stop, myposition.TakeProfit());
			}
			else if (posType == POSITION_TYPE_SELL && !up)
			{
				if (currentStop == 0 || stop < currentStop) mytrade.PositionModify(myposition.Ticket(), stop, myposition.TakeProfit());
			}
		}
	}
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
	if (ChartPeriod(0) != PERIOD_M1)
	{
		ChartSetSymbolPeriod(0, _Symbol, PERIOD_M1);
		return(INIT_SUCCEEDED);
	}
	if (!RenkoStarted)
	{
		//Check Symbol
		string symb = simbolo == "" ? _Symbol : simbolo;
		if (!Renko.ValidateSymbol(symb))
		{
			MessageBox("Symbol " + symb + " is invalid. Select a valid symbol!", __FILE__, MB_OK);
			return(INIT_FAILED);
		}
		//Setup Renko
		if (!Renko.Setup(symb, RenkoSize, RenkoWicks))
		{
			MessageBox("Renko setup error. Check error log!", __FILE__, MB_OK);
			return(INIT_FAILED);
		}
		
		//Create Custom Symbol
		Renko.CreateCustomSymbol();
		Renko.ClearCustomSymbol();
		RenkoSymbol = Renko.GetSymbolName();
		//Load History
		Renko.UpdateRates();
		Renko.ReplaceCustomSymbol();
		Renko.Start();
		RenkoStarted = true;
	}
	else
	{
		//Renko.Refresh();
	}
	
	EventSetTimer(RenkoUpdateSeconds);
	
	if (!ExtDialog.Create(0, MQL5InfoString(MQL5_PROGRAM_NAME), 0, 0, 0,LARGURA_PAINEL,ALTURA_PAINEL))
		return(INIT_FAILED);
	//--- run application 

	ExtDialog.Run();

	MyEA.OnInit();

	return INIT_SUCCEEDED;
	//---

	//---
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
	EventKillTimer();
	//---
	MyEA.OnDeinit(reason);
	if (!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.Destroy(reason);
	
	if (reason != REASON_CHARTCHANGE)
	{
		RenkoStarted = false;
		Renko.Stop();
	}
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
{
	if (!IsStopped()) Renko.Refresh();
	
	OnTick();
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
	//---

	MyEA.OnTick();
	if (!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.OnTick();

	//ChartRedraw();
}

//+------------------------------------------------------------------+
void OnChartEvent(const int id, // event ID   
                  const long& lparam, // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
{
	if (!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.ChartEvent(id, lparam, dparam, sparam);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyPanel::Create(const long chart, const string name, const int subwin, const int x1, const int y1, const int x2, const int y2)
{
	int xx1 = INDENT_LEFT;
	int yy1 = INDENT_TOP;
	int xx2 = x1 + BUTTON_WIDTH;
	int yy2 = INDENT_TOP + BUTTON_HEIGHT;

	if (!CAppDialog::Create(chart, name, subwin, x1, y1, x2, y2))
		return(false);

	//--- create dependent controls 

	if (!CreateLabel(m_chart_id, m_subwin, m_label[0], "Nome: " + AccountInfoString(ACCOUNT_NAME), xx1, yy1, xx2, yy2))
		return(false);
	m_label[0].Color(clrDeepSkyBlue);

	xx1 = INDENT_LEFT;
	yy1 = INDENT_TOP + BUTTON_HEIGHT + CONTROLS_GAP_Y;
	xx2 = xx1 + BUTTON_WIDTH;
	yy2 = yy1 + BUTTON_HEIGHT;


	if (!CreateLabel(m_chart_id, m_subwin, m_label[1], "RESULTADO MENSAL: " + MyEA.GetCurrency() + " " + DoubleToString(MyEA.LucroTotalMes(), 2), xx1, yy1, xx2, yy2))
		return(false);

	m_label[1].Color(clrYellow);

	xx1 = INDENT_LEFT;
	yy1 = INDENT_TOP + 2 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
	xx2 = xx1 + BUTTON_WIDTH;
	yy2 = yy1 + BUTTON_HEIGHT;

	if (!CreateLabel(m_chart_id, m_subwin, m_label[2], "RESULTADO SEMANAL: " + MyEA.GetCurrency() + " " + DoubleToString(MyEA.LucroTotalSemana(), 2), xx1, yy1, xx2, yy2))
		return(false);

	m_label[2].Color(clrMediumSpringGreen);

	xx1 = INDENT_LEFT;
	yy1 = INDENT_TOP + 3 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
	xx2 = xx1 + BUTTON_WIDTH;
	yy2 = yy1 + BUTTON_HEIGHT;

	if (!CreateLabel(m_chart_id, m_subwin, m_label[3], "RESULTADO DIÁRIO: " + MyEA.GetCurrency() + " " + DoubleToString(MyEA.LucroTotal(), 2), xx1, yy1, xx2, yy2))
		return(false);
	m_label[3].Color(clrMediumSpringGreen);

	xx1 = INDENT_LEFT;
	yy1 = INDENT_TOP + 4 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
	xx2 = xx1 + BUTTON_WIDTH;
	yy2 = yy1 + BUTTON_HEIGHT;


	//--- succeed 
	return(true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyPanel::OnTick(void)
{
	m_label[0].Text("Nome: " + AccountInfoString(ACCOUNT_NAME));
	m_label[1].Text("RESULTADO MENSAL: " + MyEA.GetCurrency() + " " + DoubleToString(MyEA.LucroTotalMes(), 2));
	m_label[2].Text("RESULTADO SEMANAL: " + MyEA.GetCurrency() + " " + DoubleToString(MyEA.LucroTotalSemana(), 2));
	m_label[3].Text("RESULTADO DIÁRIO: " + MyEA.GetCurrency() + " " + DoubleToString(MyEA.LucroTotal(), 2));
}

//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN (MyPanel)
EVENT_MAP_END (CAppDialog)
//+------------------------------------------------------------------+
