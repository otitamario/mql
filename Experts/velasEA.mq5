// Utils
#include <Utils.mqh>
Utils OpUtils;

// Trade
#include <Mql5Book\Trade.mqh>
//CTrade Trade;

// Price
#include <Mql5Book\Price.mqh>
CBars Price;

// Money management
#include <Mql5Book\MoneyManagement.mqh>

// Trailing stops
#include <Mql5Book\TrailingStops.mqh>
CTrailing Trail;

// Timer
#include <Mql5Book\Timer.mqh>
CTimer Timer;
CNewBar NewBar;

// Indicators 
#include <Mql5Book\Indicators.mqh>

#include<Trade\AccountInfo.mqh>
CAccountInfo myaccount;






//+------------------------------------------------------------------+
//|                                                       TickEA.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
// Declaration of the enumeration

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



enum price_types
  {
   Bid,
   Ask
  };
//-----------------------------------------------------------------------------

//--- input parameters

sinput string Volume;
input double   Lot=0.01;            // Lots to trade
sinput string Lucro="Lucro para fechamento";
input double lucro=300.0;
sinput string TI; 	// Timer
//input bool UseTimer = false;
//input int StartHour = 9;
//input int StartMinute = 0;
//input int EndHour = 23;
//input int EndMinute = 30;
input bool UseBreakEven=true;
input int pStop=500;//Stop Loss
input int pTakeProfit=500; //Take Profit
sinput string TS;		// Trailing Stop
input bool UseTrailingStop = true;
input int TrailingStop = 33;
input int MinimumProfit = 1;
input int Step = 6; 

input bool UseTimer = false;// Usar Horario para Trade
input bool UseLocalTime = false;// Usar Horario Local
input bool Daytrade=true;// Fechar posicoes Daytrade fim do dia
input bool Segunda=true;
input bool Terca=true;
input bool Quarta=true;
input bool Quinta=true;
input bool Sexta=true;
input int StartHour = 3;
input int StartMinute = 2;
input int EndHour = 8;
input int EndMinute = 0;
input int StartHour2 = 10;
input int StartMinute2 = 2;
input int EndHour2 = 22;
input int EndMinute2 = 0;

//---------------------------------------------
input bool Media1=true;// Usar Media 1
input bool Plot1=true;//Plotar Media 1
input int periodo1=17;// Periodo Media 1
input bool Media2=true;// Usar Media 2
input bool Plot2=true;//Plotar Media 2
input int periodo2=34;//Periodo Media 2
input bool Media3=false;// Usar Media 3
input bool Plot3=true;//Plotar Media 3
input int periodo3=34;//Periodo Media 3
input bool Media4=false;// Usar Media 4
input bool Plot4=true;//Plotar Media 4
input int periodo4=42;//Periodo Media 4
input bool ATRSTOP=false;// Usar ATRSTOP
input bool Plot_atr=true;//Plotar ATRSTOP
input uint   Length=10;           // Indicator period
input uint   ATRPeriod=5;         // Period of ATR
input double Kv=2.5;              // Volatility by ATR
input int    Shift=0;       // Shift
input bool Usar_VWAP=false; //Usar VWAP
input bool Plot_VWAP=true;//Plotar VWAP
input   PRICE_TYPE  Price_Type          = CLOSE;
input   bool        Calc_Every_Tick     = false;
input   bool        Enable_Daily        = true;
input   bool        Show_Daily_Value    = true;
input   bool        Enable_Weekly       = false;
input   bool        Show_Weekly_Value   = false;
input   bool        Enable_Monthly      = false;
input   bool        Show_Monthly_Value  = false;
input bool Usar_Hilo=false;// Usar Hilo
input bool Plot_hilo=true;//Plotar hilo
input int period_hilo=14;//Periodo Hilo
input int shift_hilo=0;// Deslocar Hilo



//----------------------------------------------------------------------

int velas_Handle;  //
double buffer_color_line[],buffer_ma1[],buffer_ma2[],buffer_ma3[],buffer_ma4[],buffer_atr[],buffer_vwap[],buffer_hilo[],close[];

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double lotes,ponto;
double StopLoss,TakeProfit;
long digits,ticksize;
bool tradeOn;
bool a_compra,a_venda;
double lucro_total,profit,saldo_inicial;
datetime currentTime;
double preco_abertura;

TimerBlock block[10];

ENUM_DAY_OF_WEEK StartDay = 1;
ENUM_DAY_OF_WEEK EndDay = 1;
ENUM_DAY_OF_WEEK StartDay2 = 2;
ENUM_DAY_OF_WEEK EndDay2 = 2;
ENUM_DAY_OF_WEEK StartDay3 = 3;
ENUM_DAY_OF_WEEK EndDay3 = 3;
ENUM_DAY_OF_WEEK StartDay4 = 4;
ENUM_DAY_OF_WEEK EndDay4 = 4;
ENUM_DAY_OF_WEEK StartDay5 = 5;
ENUM_DAY_OF_WEEK EndDay5 = 5;







//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+


int OnInit()
  {
  
  //Block Time
	block[0].enabled = Segunda;
   block[0].start_day = StartDay;
   block[0].start_hour = StartHour;
   block[0].start_min = StartMinute;
   block[0].end_day = EndDay;
   block[0].end_hour = EndHour;
   block[0].end_min = EndMinute;
   
   block[1].enabled = Segunda;
   block[1].start_day = StartDay;
   block[1].start_hour = StartHour2;
   block[1].start_min = StartMinute2;
   block[1].end_day = EndDay;
   block[1].end_hour = EndHour2;
   block[1].end_min = EndMinute2;
	
	block[2].enabled = Terca;
   block[2].start_day = StartDay2;
   block[2].start_hour = StartHour;
   block[2].start_min = StartMinute;
   block[2].end_day = EndDay2;
   block[2].end_hour = EndHour;
   block[2].end_min = EndMinute;
   
   block[3].enabled = Terca;
   block[3].start_day = StartDay2;
   block[3].start_hour = StartHour2;
   block[3].start_min = StartMinute2;
   block[3].end_day = EndDay2;
   block[3].end_hour = EndHour2;
   block[3].end_min = EndMinute2;
	
	block[4].enabled = Quarta;
   block[4].start_day = StartDay3;
   block[4].start_hour = StartHour;
   block[4].start_min = StartMinute;
   block[4].end_day = EndDay3;
   block[4].end_hour = EndHour;
   block[4].end_min = EndMinute;
   
   block[5].enabled = Quarta;
   block[5].start_day = StartDay3;
   block[5].start_hour = StartHour2;
   block[5].start_min = StartMinute2;
   block[5].end_day = EndDay3;
   block[5].end_hour = EndHour2;
   block[5].end_min = EndMinute2;
	
	block[6].enabled = Quinta;
   block[6].start_day = StartDay4;
   block[6].start_hour = StartHour;
   block[6].start_min = StartMinute;
   block[6].end_day = EndDay4;
   block[6].end_hour = EndHour;
   block[6].end_min = EndMinute;
   
   block[7].enabled = Quinta;
   block[7].start_day = StartDay4;
   block[7].start_hour = StartHour2;
   block[7].start_min = StartMinute2;
   block[7].end_day = EndDay4;
   block[7].end_hour = EndHour2;
   block[7].end_min = EndMinute2;
	
	block[8].enabled = Sexta;
   block[8].start_day = StartDay5;
   block[8].start_hour = StartHour;
   block[8].start_min = StartMinute;
   block[8].end_day = EndDay5;
   block[8].end_hour = EndHour;
   block[8].end_min = EndMinute;
   
   block[9].enabled = Sexta;
   block[9].start_day = StartDay5;
   block[9].start_hour = StartHour2;
   block[9].start_min = StartMinute2;
   block[9].end_day = EndDay5;
   block[9].end_hour = EndHour2;
   block[9].end_min = EndMinute2;


  
  
  
  //------------------------------------------------------------------------
  lotes=0.0;
  lucro_total=0.0;
  saldo_inicial=AccountInfoDouble(ACCOUNT_BALANCE);

  
//-------------------------------------------------------
      velas_Handle=iCustom(NULL,_Period,"velas_coloridas",
      Media1,Plot1,periodo1,Media2,Plot2,periodo2,
      Media3,Plot3,periodo3,Media4,Plot4,periodo4,
      ATRSTOP,Plot_atr,Length,ATRPeriod,Kv,Shift,
      Usar_VWAP,Plot_VWAP,Price_Type,
      Calc_Every_Tick,Enable_Daily,Show_Daily_Value,
      Enable_Weekly,Show_Weekly_Value,Enable_Monthly,Show_Monthly_Value,
      Usar_Hilo,Plot_hilo,period_hilo,shift_hilo);
      if(velas_Handle==INVALID_HANDLE)
     {
      Print(": Falha em obter o indicador velas_coloridas");
      Print("Handle = ",velas_Handle,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
//-----------------------------------------------------------------

ChartIndicatorAdd(0,0,velas_Handle);
    
    
    
   ArrayInitialize(buffer_color_line,2.0);
   ArrayInitialize(buffer_ma1,0.0);
   ArrayInitialize(buffer_ma2,0.0);
   ArrayInitialize(buffer_ma3,0.0);
   ArrayInitialize(buffer_ma4,0.0);
   ArrayInitialize(buffer_atr,0.0);
   ArrayInitialize(buffer_vwap,0.0);
   ArrayInitialize(buffer_hilo,0.0);
   ArrayInitialize(close,0.0);

   
   ArraySetAsSeries(buffer_color_line,true);
   ArraySetAsSeries(buffer_ma1,true);
   ArraySetAsSeries(buffer_ma2,true);
   ArraySetAsSeries(buffer_ma3,true);
   ArraySetAsSeries(buffer_ma4,true);
   ArraySetAsSeries(buffer_atr,true);
   ArraySetAsSeries(buffer_vwap,true);
   ArraySetAsSeries(buffer_hilo,true);
   ArraySetAsSeries(close,true);
   
   
   

   //   TickHandle=iCustom(NULL,_Period,"tickcolorcandles",ticks_in_candle,applied_price,path_prefix);
      //ChartIndicatorAdd(0,1,DemaHandle);
     //---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
ChartIndicatorDelete(0,0,"velas_coloridas");
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

 if(!GetIndValue()) return;
         

ticksize=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE);
 
 
bool novodia;
double saldo;
novodia=CheckNovoDia(Symbol(),PERIOD_M1);
if (novodia) 
{
saldo_inicial=AccountInfoDouble(ACCOUNT_BALANCE);
lucro_total=AccountInfoDouble(ACCOUNT_BALANCE)-saldo_inicial;

tradeOn=true;
}

if (PositionType(Symbol()) != -1)
{ lucro_total=PositionGetDouble(POSITION_PROFIT)+myaccount.Balance()-saldo_inicial;
}
else lucro_total=AccountInfoDouble(ACCOUNT_BALANCE)-saldo_inicial;

if (lucro_total>=lucro) 
{
if (PositionType(Symbol()) != -1)Trade.Close(Symbol());
tradeOn=false;
}
else tradeOn=true;

bool timerOn = true;
if(UseTimer == true)
	{
		//timerOn = Timer.DailyTimer(StartHour,StartMinute,EndHour,EndMinute,UseLocalTime);
		timerOn = Timer.BlockTimer(block,UseLocalTime);

	}
if (timerOn==false &&PositionType(Symbol()) != -1) Trade.Close(Symbol());	
 
 MqlTradeRequest request;
 MqlTradeResult result;
 ZeroMemory(request);
  
   static datetime Old_Time;
   datetime New_Time[1];
   bool IsNewBar=false;
long posicao;
  double ask,bid,preco;
   MqlTick last_tick;
   if (SymbolInfoTick(Symbol(),last_tick)) 
     { 
      bid = last_tick.bid;
      ask=last_tick.ask;
      preco=last_tick.last; 
       
     }
    else {Print("Falhou obter o tick");}
   double spread=ask-bid; 
   ponto=_Point;
   
   
//----------------------------------------------------------------------------
 
//------------------------------------------------------------------------------

if (tradeOn && timerOn)
  {// inicio Trade On
     
     
    if(BuySignal())    // Open long position
     { 
     posicao=PositionGetInteger(POSITION_TYPE);
     if (posicao!=POSITION_TYPE_BUY)
      {
      // Adicionar StopLoss e TakeProfit
       digits = SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
       StopLoss=NormalizeDouble(bid-pStop*ponto,(int)digits);
       TakeProfit=NormalizeDouble(ask+pTakeProfit*ponto,(int)digits);
       LongPositionOpen(StopLoss,TakeProfit); 
      }        	   	
       }
       // End By Condition
   
       
   if(SellSignal())   // Open short position
     {                                                    
     
     
     posicao=PositionGetInteger(POSITION_TYPE);
     if (posicao!=POSITION_TYPE_SELL)
      {
      // Adicionar StopLoss e TakeProfit
       digits = SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
       StopLoss=NormalizeDouble(ask+pStop*ponto,(int)digits);
       TakeProfit=NormalizeDouble(bid-pTakeProfit*ponto,(int)digits);
       ShortPositionOpen(StopLoss,TakeProfit); 
      }        	   	
     
      
      }// End Sell COndition
 
     
     
    if ((PositionType(Symbol()) != -1)&& buffer_color_line[1]==2) Trade.Close(Symbol());


    
     
// Trailing stop
	if(UseTrailingStop == true && PositionType(Symbol()) != -1)
	{
		Trail.TrailingStop(Symbol(),TrailingStop,MinimumProfit,Step);
	}
 
 }// Fim tradeOn
 
 else
{
if (Daytrade==true &&PositionType(Symbol()) != -1) Trade.Close(Symbol());
} // fechou ordens pendentes no Day trade fora do horario

   return;
  
  
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+-------------ROTINAS----------------------------------------------+
//+------------------------------------------------------------------+
//| Buy conditions                                                   |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   return(buffer_color_line[1]==0 && (buffer_color_line[2]==1 || buffer_color_line[2]==2))?true:false;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   return(buffer_color_line[1]==1 && (buffer_color_line[2]==0 || buffer_color_line[2]==2))?true:false;
  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   
   
    
   
   
   return(
   CopyBuffer(velas_Handle,4,0,3,buffer_color_line)<=0 ||
   CopyBuffer(velas_Handle,5,0,3,buffer_ma1)<=0 ||
   CopyBuffer(velas_Handle,6,0,3,buffer_ma2)<=0 ||
   CopyBuffer(velas_Handle,7,0,3,buffer_ma3)<=0 ||
   CopyBuffer(velas_Handle,8,0,3,buffer_ma4)<=0 ||
   CopyBuffer(velas_Handle,9,0,3,buffer_atr)<=0 ||
   CopyBuffer(velas_Handle,10,0,3,buffer_vwap)<=0 ||
   CopyBuffer(velas_Handle,11,0,3,buffer_hilo)<=0 ||
   CopyClose(Symbol(),_Period,0,3,close)<=0

    )?false:true;
  }
//+------------------------------------------------------------------+



bool CheckNovoDia(string pSymbol,ENUM_TIMEFRAMES pTimeframe)
{
   bool newBar;
   datetime Time[],LastTime;
	ArraySetAsSeries(Time,true);
	MqlDateTime hoje,ontem;
	LastTime=TimeCurrent();
	CopyTime(pSymbol,pTimeframe,0,2,Time);
	TimeToStruct(LastTime,hoje);
	TimeToStruct(Time[1],ontem);
	newBar=false;
	if(hoje.day_of_year != ontem.day_of_year) newBar = true;
	
	return(newBar);
}


//+------------------------------------------------------------------+
//| Open Long position                                               |
//+------------------------------------------------------------------+
void LongPositionOpen(double stop=0.0,double take=0.0)
  {
   MqlTradeRequest mrequest;                             // Will be used for trade requests
   MqlTradeResult mresult;                               // Will be used for results of trade requests
   
   ZeroMemory(mrequest);
   ZeroMemory(mresult);
   
   double Ask = SymbolInfoDouble(Symbol(),SYMBOL_ASK);    // Ask price
   double Bid = SymbolInfoDouble(Symbol(),SYMBOL_BID);    // Bid price
   if(!PositionSelect(Symbol()))
{
     
      mrequest.action = TRADE_ACTION_DEAL;               // Immediate order execution
      mrequest.price = NormalizeDouble(Ask,_Digits);     // Lastest Ask price
      mrequest.sl = stop;                                   // Stop Loss
      mrequest.tp = take;                                   // Take Profit
      mrequest.symbol = Symbol();                         // Symbol
      
    mrequest.volume =Lot;
  }
      
   //   mrequest.volume = lotes;                             // Number of lots to trade
      mrequest.magic = 0;                                // Magic Number
      mrequest.type = ORDER_TYPE_BUY;                    // Buy Order
      mrequest.type_filling = ORDER_FILLING_FOK;         // Order execution type
      mrequest.deviation=5;                              // Deviation from current price
      OrderSend(mrequest,mresult); 
      lotes=0;                      // Send order
   
  
  if(PositionSelect(Symbol())&& PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
{
 mrequest.action = TRADE_ACTION_DEAL;               // Immediate order execution
      mrequest.price = NormalizeDouble(Ask,_Digits);     // Lastest Ask price
      mrequest.sl = stop;                                   // Stop Loss
      mrequest.tp = take;                                   // Take Profit
      mrequest.symbol = Symbol();                         // Symbol
      
     mrequest.volume =2*Lot;
  
      
   //   mrequest.volume = lotes;                             // Number of lots to trade
      mrequest.magic = 0;                                // Magic Number
      mrequest.type = ORDER_TYPE_BUY;                    // Buy Order
      mrequest.type_filling = ORDER_FILLING_FOK;         // Order execution type
      mrequest.deviation=5;                              // Deviation from current price
      OrderSend(mrequest,mresult); 
      lotes=0;                      // Send order
}
}
//+------------------------------------------------------------------+
//| Open Short position                                              |
//+------------------------------------------------------------------+
void ShortPositionOpen(double stop=0.0,double take=0.0)
  {
   MqlTradeRequest mrequest;                             // Will be used for trade requests
   MqlTradeResult mresult;                               // Will be used for results of trade requests
   
   ZeroMemory(mrequest);
   ZeroMemory(mresult);
   
   double Ask = SymbolInfoDouble(Symbol(),SYMBOL_ASK);    // Ask price
   double Bid = SymbolInfoDouble(Symbol(),SYMBOL_BID);    // Bid price
   
   if(!PositionSelect(Symbol()))
   {
      mrequest.action = TRADE_ACTION_DEAL;               // Immediate order execution
      mrequest.price = NormalizeDouble(Bid,_Digits);     // Lastest Bid price
      mrequest.sl = stop;                                   // Stop Loss
      mrequest.tp = take;                                   // Take Profit
      mrequest.symbol = Symbol();                         // Symbol
   
  mrequest.volume =Lot;
  
      
     // mrequest.volume = lotes;                             // Number of lots to trade
      mrequest.magic = 0;                                // Magic Number
      mrequest.type= ORDER_TYPE_SELL;                    // Sell order
      mrequest.type_filling = ORDER_FILLING_FOK;         // Order execution type
      mrequest.deviation=5;                              // Deviation from current price
      OrderSend(mrequest,mresult);                       // Send order
  lotes=0; 
  
  }

   if(PositionSelect(Symbol())&& PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)

   {
      mrequest.action = TRADE_ACTION_DEAL;               // Immediate order execution
      mrequest.price = NormalizeDouble(Bid,_Digits);     // Lastest Bid price
      mrequest.sl = stop;                                   // Stop Loss
      mrequest.tp = take;                                   // Take Profit
      mrequest.symbol = Symbol();                         // Symbol
   
  mrequest.volume =2*Lot;
      
     // mrequest.volume = lotes;                             // Number of lots to trade
      mrequest.magic = 0;                                // Magic Number
      mrequest.type= ORDER_TYPE_SELL;                    // Sell order
      mrequest.type_filling = ORDER_FILLING_FOK;         // Order execution type
      mrequest.deviation=5;                              // Deviation from current price
      OrderSend(mrequest,mresult);                       // Send order
  lotes=0; 
  
  }


  }



	
