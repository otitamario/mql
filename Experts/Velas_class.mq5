#include <velascolor.mqh>
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
//#include <Mql5Book\Indicators.mqh>

#include<Trade\AccountInfo.mqh>
CAccountInfo myaccount;

enum price_types
  {
   Bid,
   Ask
  };
//+------------------------------------------------------------------+
//|                                                  Velas_class.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

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
//input bool UseBreakEven=true;
input double _Stop=500;//Stop Loss
input double _TakeProfit=500; //Take Profit
input bool Use_ADX=true;//Usar Filtro ADX M1
input int adx_period=14;//Periodo ADX
input double ADX_min=20.0;//ADX mínimo
input bool UseTrailingStop = false;//Usar Trailing
input int TrailingStop = 33;//Distancia do Stop
input int MinimumProfit = 1; //Lucro Minimo pra ativar o Stop
input int Step = 6; //Passo pra atualizar o STOP
input bool Use_STOP_ATR=false;// Usar Stop loss/gain movel STOPATR
input int periodo_ATR=14;// Periodo da ATR
input double vz_ATR=4;//  Vezes a ATR(0 p/ nao usar TakeProfit)
input double dist_ATR=50;// Distancia do STOP LOSS para o STOP ATR
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

sinput string s_velas="-------------------VELAS COLORIDAS------------------------------";
input ENUM_TIMEFRAMES period_velas=PERIOD_CURRENT;//Período das Velas
input bool pMedia1=true;// Usar Media 1
input bool pPlot1=true;//Plotar Media 1
input int pperiodo1=17;// Periodo Media 1
input bool pMedia2=false;// Usar Media 2
input bool pPlot2=true;//Plotar Media 2
input int pperiodo2=34;//Periodo Media 2
input bool pMedia3=false;// Usar Media 3
input bool pPlot3=true;//Plotar Media 3
input int pperiodo3=34;//Periodo Media 3
input bool pMedia4=false;// Usar Media 4
input bool pPlot4=true;//Plotar Media 4
input int pperiodo4=42;//Periodo Media 4
input bool pATRSTOP=false;// Usar ATRSTOP
input bool pPlot_atr=true;//Plotar ATRSTOP
input uint pLength=10;           // Indicator period
input uint pATRPeriod=5;         // Period of ATR
input double pKv=2.5;              // Volatility by ATR
input int pShift=0;       // Shift
input bool pUsar_VWAP=false; //Usar VWAP
input bool pPlot_VWAP=true;//Plotar VWAP
input PRICE_TYPE  pPrice_Type=CLOSE;
input bool pCalc_Every_Tick=false;
input bool pEnable_Daily=true;
input bool pShow_Daily_Value=true;
input bool pEnable_Weekly=false;
input bool pShow_Weekly_Value=false;
input bool pEnable_Monthly=false;
input bool pShow_Monthly_Value=false;
input bool pUsar_Hilo=false;// Usar Hilo
input bool pPlot_hilo=true;//Plotar hilo
input int pperiod_hilo=14;//Periodo Hilo
input int pshift_hilo=0;// Deslocar Hilo
sinput string s_tend="------------TENDENCIA------------------------------------";
input bool Use_TEND=true;//Usar Tendência;
input ENUM_TIMEFRAMES tend_period=PERIOD_M30;//TimeFrame da Tendência
input bool Media1_T=true;// Usar Media 1
input bool Plot1_T=true;//Plotar Media 1
input int periodo1_T=17;// Periodo Media 1
input bool Media2_T=false;// Usar Media 2
input bool Plot2_T=true;//Plotar Media 2
input int periodo2_T=34;//Periodo Media 2
input bool Media3_T=false;// Usar Media 3
input bool Plot3_T=true;//Plotar Media 3
input int periodo3_T=34;//Periodo Media 3
input bool Media4_T=false;// Usar Media 4
input bool Plot4_T=true;//Plotar Media 4
input int periodo4_T=42;//Periodo Media 4
input bool ATRSTOP_T=false;// Usar ATRSTOP
input bool Plot_atr_T=true;//Plotar ATRSTOP
input uint   Length_T=10;           // Indicator period
input uint   ATRPeriod_T=5;         // Period of ATR
input double Kv_T=2.5;              // Volatility by ATR
input int    Shift_T=0;       // Shift
input bool Usar_VWAP_T=false; //Usar VWAP
input bool Plot_VWAP_T=true;//Plotar VWAP
input   PRICE_TYPE  Price_Type_T          = CLOSE;
input   bool        Calc_Every_Tick_T     = false;
input   bool        Enable_Daily_T        = true;
input   bool        Show_Daily_Value_T    = true;
input   bool        Enable_Weekly_T       = false;
input   bool        Show_Weekly_Value_T   = false;
input   bool        Enable_Monthly_T      = false;
input   bool        Show_Monthly_Value_T  = false;
input bool Usar_Hilo_T=false;// Usar Hilo
input bool Plot_hilo_T=true;//Plotar hilo
input int period_hilo_T=14;//Periodo Hilo
input int shift_hilo_T=0;// Deslocar Hilo


long curChartID,newChartID;
int handle_ma1_T,handle_ma2_T,handle_ma3_T,handle_ma4_T,handle_atr_T,handle_vwap_T,handle_hilo_T;           //Handle for the MA indicators
int ATR_Handle,stop_atr_Handle,ADX_Handle;  //

double ATR_buffer[],LOWER_STOP_ATR_buffer[],UPPER_STOP_ATR_buffer[];//buffer do ATR normal
double ADX_buffer[],ADX_P_buffer[],ADX_N_buffer[],close[];


CiVelas *ciVelas;
CiVelas *ciVelasTend;

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double lotes,pponto,ticksize,sl_aux,tp_aux;
double StopLoss,TakeProfit;
long pdigits;
bool tradeOn;
bool a_compra,a_venda;
double lucro_total,profit,saldo_inicial;
datetime currentTime;
double preco_abertura;
int win;
long posicao;
double pask,pbid,preco;

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



int OnInit()
  {
    curChartID= ChartID();
   ChartRedraw(curChartID);
   ciVelas=new CiVelas;
   ciVelas.Create(_Symbol,period_velas,pMedia1,pPlot1,pperiodo1,pMedia2,pPlot2,
 pperiodo2,pMedia3,pPlot3,pperiodo3,pMedia4,pPlot4,pperiodo4,pATRSTOP,
 pPlot_atr,pLength,pATRPeriod,pKv,pShift,pUsar_VWAP,pPlot_VWAP,pPrice_Type,
 pCalc_Every_Tick,pEnable_Daily,pShow_Daily_Value,pEnable_Weekly,
 pShow_Weekly_Value,pEnable_Monthly,pShow_Monthly_Value,pUsar_Hilo,
 pPlot_hilo,pperiod_hilo,pshift_hilo);
  ciVelas.AddToChart(curChartID,0);
 
  if (Use_TEND)
{
ciVelasTend=new CiVelas;
newChartID= ChartOpen(Symbol(),tend_period);
ChartRedraw(newChartID);
ciVelasTend.Create(_Symbol,tend_period,Media1_T,Plot1_T,periodo1_T,Media2_T,Plot2_T,
 periodo2_T,Media3_T,Plot3_T,periodo3_T,Media4_T,Plot4_T,periodo4_T,ATRSTOP_T,
 Plot_atr_T,Length_T,ATRPeriod_T,Kv_T,Shift_T,Usar_VWAP_T,Plot_VWAP_T,Price_Type_T,
 Calc_Every_Tick_T,Enable_Daily_T,Show_Daily_Value_T,Enable_Weekly_T,
 Show_Weekly_Value_T,Enable_Monthly_T,Show_Monthly_Value_T,Usar_Hilo_T,
 Plot_hilo_T,period_hilo_T,shift_hilo_T);
ciVelasTend.AddToChart(newChartID,0);

handle_ma1_T=iMA(Symbol(),tend_period,periodo1_T,0,MODE_EMA,PRICE_CLOSE);
   handle_ma2_T=iMA(Symbol(),tend_period,periodo2_T,0,MODE_EMA,PRICE_CLOSE);
   handle_ma3_T=iMA(Symbol(),tend_period,periodo3_T,0,MODE_EMA,PRICE_CLOSE);
   handle_ma4_T=iMA(Symbol(),tend_period,periodo4_T,0,MODE_EMA,PRICE_CLOSE);
   handle_atr_T=iCustom(Symbol(),tend_period,"atrstops_v1",Length_T,ATRPeriod_T,Kv_T,Shift_T);
   handle_vwap_T=iCustom(Symbol(),tend_period,"vwap_lite",Price_Type_T,Calc_Every_Tick_T,Enable_Daily_T,
   Show_Daily_Value_T,Enable_Weekly_T,Show_Weekly_Value_T,Enable_Monthly_T,Show_Monthly_Value_T);
   handle_hilo_T=iCustom(Symbol(),tend_period,"hilo_escada",period_hilo_T,MODE_EMA,shift_hilo_T);

if (Media1_T && Plot1_T) ChartIndicatorAdd(newChartID,0,handle_ma1_T);
   if (Media2_T&& Plot2_T) ChartIndicatorAdd(newChartID,0,handle_ma2_T);
   if (Media3_T&& Plot3_T)ChartIndicatorAdd(newChartID,0,handle_ma3_T);
   if (Media4_T&& Plot4_T) ChartIndicatorAdd(newChartID,0,handle_ma4_T);
   if (ATRSTOP_T&& Plot_atr_T) ChartIndicatorAdd(newChartID,0,handle_atr_T);
   if (Usar_VWAP_T && Plot_VWAP_T) ChartIndicatorAdd(newChartID,0,handle_vwap_T);
   if (Usar_Hilo_T && Plot_hilo_T) ChartIndicatorAdd(newChartID,0,handle_hilo_T);


}// End if TEND

pponto=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  ticksize=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE);
  pdigits =(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
      
      
  
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

if (Use_STOP_ATR)
     {
     ATR_Handle=iATR(Symbol(),period_velas,periodo_ATR);
     stop_atr_Handle=iCustom(Symbol(),period_velas,"atrstops_v1",pLength,pATRPeriod,pKv,pShift);
     
     if(ATR_Handle==INVALID_HANDLE)
     {
      Print(": Falha em obter o indicador ATR");
      Print("Handle = ",ATR_Handle,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
     if(stop_atr_Handle==INVALID_HANDLE)
     {
      Print(": Falha em obter o indicador STOP ATR");
      Print("Handle = ",stop_atr_Handle,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
     
     
     }//Fim ATR
     
     if (Use_ADX)
     {
     ADX_Handle=iADX(Symbol(),PERIOD_M1,adx_period);
     if(ADX_Handle==INVALID_HANDLE)
     {
      Print(": Falha em obter o indicador ADX");
      Print("Handle = ",ADX_Handle,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
     ArrayInitialize(ADX_buffer,0.0);
     ArraySetAsSeries(ADX_buffer,true);
     ArrayInitialize(ADX_P_buffer,0.0);
     ArraySetAsSeries(ADX_P_buffer,true);
     ArrayInitialize(ADX_N_buffer,0.0);
     ArraySetAsSeries(ADX_N_buffer,true);
     
     }// Fim ADX
//-----------------------------------------------------------------

  if (Use_STOP_ATR) 
{
ChartIndicatorAdd(curChartID,0,stop_atr_Handle);
//short_STOP_ATR_name="";
//StringConcatenate(short_STOP_ATR_name,"ATRStops_v1(",Length,", ",ATRPeriod,", ",DoubleToString(Kv,4),", ",Shift,")");
ArrayInitialize(LOWER_STOP_ATR_buffer,0.0);
ArraySetAsSeries(LOWER_STOP_ATR_buffer,true);
ArrayInitialize(UPPER_STOP_ATR_buffer,0.0);
ArraySetAsSeries(UPPER_STOP_ATR_buffer,true);
}    

ArrayInitialize(close,0.0);
ArraySetAsSeries(close,true);
       
    
   
   

  
  
  //------------------------------------------------------------------------
  lotes=0.0;
  lucro_total=0.0;
  saldo_inicial=AccountInfoDouble(ACCOUNT_BALANCE);
 
  

 
   return(0);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   delete(ciVelas);
   if(Use_TEND) delete(ciVelasTend);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {   
   //--- refresh data
   ciVelas.Refresh();
   if (Use_TEND)ciVelasTend.Refresh();
  
  bool novodia;
//double saldo;
//novodia=CheckNovoDia(Symbol(),PERIOD_M1);
novodia=NewBar.CheckNewBar(_Symbol,PERIOD_D1);

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
   MqlTick last_tick;
   if (SymbolInfoTick(Symbol(),last_tick)) 
     { 
      pbid = last_tick.bid;
      pask=last_tick.ask;
      preco=last_tick.last; 
       
     }
    else {Print("Falhou obter o tick");}
   double spread=pask-pbid; 
   
   
//----------------------------------------------------------------------------
 
//------------------------------------------------------------------------------
if (tradeOn && timerOn)
  {// inicio Trade On
 
   
     //posicao=PositionGetInteger(POSITION_TYPE);
     posicao=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);

     bool Buy_opened=false,Sell_opened=false; // variables to hold the result of the opened position
     //Verifica se tem posicao aberta
     if(PositionSelect(_Symbol)==true) // we have an opened position
     {
      if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         Buy_opened=true;  //It is a Buy
        }
      else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         Sell_opened=true; // It is a Sell
        }
     }
//Fim verificacao
    
//------------------------------------------------------------------
      

if(BuySignal()&&(!Buy_opened))    // Open long position
     {
     // Adicionar StopLoss e TakeProfit
       if (_Stop>0) StopLoss=NormalizeDouble(pbid-_Stop*pponto,pdigits);
       else StopLoss=0;
       if (_TakeProfit>0)TakeProfit=NormalizeDouble(pask+_TakeProfit*pponto,pdigits);
       else TakeProfit=0;
       
       LongPositionOpen(StopLoss,TakeProfit);
               	   	
      }// End By Condition 
   
       
 
 //------------------------------------------------------------------
      
   if(SellSignal()&&(!Sell_opened))   // Open short position
     { 
         // Adicionar StopLoss e TakeProfit
       if (_Stop>0)StopLoss=NormalizeDouble(pask+_Stop*pponto,pdigits);
       else StopLoss=0;
       if (_TakeProfit>0)TakeProfit=NormalizeDouble(pbid-_TakeProfit*pponto,pdigits);
       else TakeProfit=0;
       ShortPositionOpen(StopLoss,TakeProfit);
              	   	
      
      }// End Sell COndition
      //------------------------------------------------------------------

      
      
//------------------------------------------------------------------

if ((PositionType(Symbol()) != -1)&& ciVelas.CorVela(1)==2.0) Trade.Close(Symbol());//Fechar no candle amarelo
//if (TREND=="NEUTRO" &&(PositionType(Symbol()) != -1))Trade.Close(Symbol());//Fechar na TENDENCIA NEUTRA


// STOP Movel pelo STOP ATR + vz*ATR
if (Use_STOP_ATR==true && PositionType(Symbol()) != -1)  Stop_ATR();


//---------------------------------------------------------------------     
// Trailing stop
	if(UseTrailingStop == true && PositionType(Symbol()) != -1) Trail.TrailingStop(Symbol(),TrailingStop,MinimumProfit,Step);
	
 
 }// Fim tradeOn
 
 else
{
if (Daytrade==true &&PositionType(Symbol()) != -1) Trade.Close(Symbol());
} // fechou ordens pendentes no Day trade fora do horario


Comentarios();


   
return;
  

  
 }//Fim OnTick

//+------------------------------------------------------------------+
//+-------------ROTINAS----------------------------------------------+
//+------------------------------------------------------------------+
//| Buy conditions                                                   |
//+------------------------------------------------------------------+
bool BuySignal()
  {bool b_signal;
  b_signal=ciVelas.CorVela(1)==0.0 && ciVelas.CorVela(2)!=0.0;
  if (Use_ADX)b_signal=b_signal&&(ADX_buffer[0]>ADX_min)&&(ADX_P_buffer[0]>ADX_N_buffer[0]);
  if (Use_TEND) 
  {
  if (Tendencia()=="COMPRA")b_signal=b_signal ||(ciVelasTend.CorVela(0)==0 && ciVelasTend.CorVela(1)!=0);
  else b_signal=false;
  }
  //Prints
  
  return b_signal;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {bool s_signal;
  s_signal=ciVelas.CorVela(1)==1.0 && ciVelas.CorVela(2)!=1.0;
  if (Use_ADX)s_signal=s_signal&&(ADX_buffer[0]>ADX_min)&&(ADX_P_buffer[0]<ADX_N_buffer[0]);
  
  if (Use_TEND) 
  {
  if (Tendencia()=="VENDA")s_signal=s_signal ||(ciVelasTend.CorVela(0)==1 && ciVelasTend.CorVela(1)!=1);
  else s_signal=false;
  }
  
  
  
  return s_signal;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
  
// Tendência
string Tendencia()
{
string s_t="";
if(ciVelasTend.CorVela(0)==0) s_t="COMPRA";
 else if (ciVelasTend.CorVela(0)==1) s_t="VENDA";
 else s_t="NEUTRO";
 return(s_t);

}  
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void Comentarios()
{
string s_usar_adx,s_usar_tend;
if (Use_ADX) s_usar_adx="SIM";
else s_usar_adx="NÃO";
if (Use_TEND)s_usar_tend="TENDENCIA: "+Tendencia();
else s_usar_tend="";
string s_adx;
if (Use_ADX) 
{
s_adx=s_usar_tend+" "+"USAR ADX: "+s_usar_adx+" ADX M1: "+DoubleToString(ADX_buffer[0],2)+"\n"+
" "+"ADX+ :"+DoubleToString(ADX_P_buffer[0],2)+" "+"ADX- :"+DoubleToString(ADX_N_buffer[0],2);
}
else 
{
s_adx=s_usar_tend+" "+"USAR ADX: "+s_usar_adx;
}
string s_coment=""+"\n"+"RESULTADO DIÁRIO: "+DoubleToString(lucro_total,2)+"\n"+s_adx+"\n";
Comment(s_coment);   

} 
  
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   bool b_get,i_atr,i_adx;
   if (Use_STOP_ATR)
   {
   i_atr=CopyBuffer(stop_atr_Handle,0,0,3,UPPER_STOP_ATR_buffer)<=0 ||
   CopyBuffer(stop_atr_Handle,1,0,3,LOWER_STOP_ATR_buffer)<=0 ||
   CopyBuffer(ATR_Handle,0,0,3,ATR_buffer)<=0;
   }
   else i_atr=false;
   if (Use_ADX)
   {
   i_adx=CopyBuffer(ADX_Handle,0,0,3,ADX_buffer)<=0||
   CopyBuffer(ADX_Handle,1,0,3,ADX_P_buffer)<=0||
   CopyBuffer(ADX_Handle,2,0,3,ADX_N_buffer)<=0;
   }
   else i_adx=false;
   
   b_get=CopyClose(Symbol(),period_velas,0,3,close)<=0;
   if (b_get)Print("Erro em obter fechamentos close");
   
    if (i_atr)Print("Erro em obter ATR buffer");
    if (i_adx)Print("Erro em obter ADX buffer");
   
   b_get=b_get||i_atr||i_adx;
   return(b_get);
   
    
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
  
      
   //   mrequest.volume = lotes;                             // Number of lots to trade
      mrequest.magic = 0;                                // Magic Number
      mrequest.type = ORDER_TYPE_BUY;                    // Buy Order
      mrequest.type_filling = ORDER_FILLING_FOK;         // Order execution type
      mrequest.deviation=5;                              // Deviation from current price
      OrderSend(mrequest,mresult);
      Print(__FUNCTION__,":",mresult.comment); 
 
      lotes=0;                      // Send order
  } 
  
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
      Print(__FUNCTION__,":",mresult.comment); 
 
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




void Stop_ATR()
{
 pdigits = (int) SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
 preco_abertura=PositionGetDouble(POSITION_PRICE_OPEN);
 posicao=PositionGetInteger(POSITION_TYPE);
 if (posicao==POSITION_TYPE_BUY)
 {
 
 if ((close[0]>=UPPER_STOP_ATR_buffer[1])&& UPPER_STOP_ATR_buffer[1]!=EMPTY_VALUE) 
 {
 StopLoss=NormalizeDouble(MathRound(UPPER_STOP_ATR_buffer[1]/ticksize)*ticksize-dist_ATR*pponto,pdigits);
 TakeProfit=NormalizeDouble(MathRound((preco_abertura+vz_ATR*ATR_buffer[1])/ticksize)*ticksize,pdigits);
 }
 else if ((close[0]<LOWER_STOP_ATR_buffer[1])&& LOWER_STOP_ATR_buffer[1]!=EMPTY_VALUE)
 {
StopLoss=NormalizeDouble(preco_abertura-(15.0*ATR_buffer[1]/ticksize)*ticksize,pdigits);
TakeProfit=NormalizeDouble(preco_abertura+(15.0*ATR_buffer[1]/ticksize)*ticksize,pdigits);
 }			
 double stop_atual=PositionGetDouble(POSITION_SL);
 if (stop_atual!=0 && StopLoss< stop_atual) StopLoss=stop_atual;
 double take_atual=PositionGetDouble(POSITION_TP);
 if (StopLoss>0 && TakeProfit>0 && StopLoss<pbid && TakeProfit>pask && StopLoss!=stop_atual && TakeProfit!=take_atual) Trade.ModifyPosition(Symbol(),StopLoss,TakeProfit);
 
 }  
 
 if (posicao==POSITION_TYPE_SELL)
 {

 if ((close[0]<=LOWER_STOP_ATR_buffer[1])&& LOWER_STOP_ATR_buffer[1]!=EMPTY_VALUE) 
 {
 StopLoss=NormalizeDouble(MathRound(LOWER_STOP_ATR_buffer[1]/ticksize)*ticksize+dist_ATR*pponto,pdigits);
 TakeProfit=NormalizeDouble(MathRound((preco_abertura-vz_ATR*ATR_buffer[1])/ticksize)*ticksize,pdigits);
 }
 else if((close[0]>=UPPER_STOP_ATR_buffer[1])) 
 {
 StopLoss=NormalizeDouble(preco_abertura+(15.0*ATR_buffer[1]/ticksize)*ticksize,pdigits);
TakeProfit=NormalizeDouble(preco_abertura-(15.0*ATR_buffer[1]/ticksize)*ticksize,pdigits);
}			
double stop_atual=PositionGetDouble(POSITION_SL);
double take_atual=PositionGetDouble(POSITION_TP);
if (vz_ATR==0) TakeProfit=0;
if (stop_atual!=0 && StopLoss> stop_atual) StopLoss=stop_atual;
if (StopLoss>0 && TakeProfit>0&& StopLoss>pbid && TakeProfit<pask && StopLoss!=stop_atual && TakeProfit!=take_atual) Trade.ModifyPosition(Symbol(),StopLoss,TakeProfit);
if (StopLoss>0 && TakeProfit==0&& StopLoss>pbid && StopLoss!=stop_atual && TakeProfit!=take_atual)Trade.ModifyPosition(Symbol(),StopLoss,TakeProfit);
 }    
}
	
