#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include <velascolor.mqh>
#include<Trade\AccountInfo.mqh>


// ------------Classes-----------------------
CNewBar NewBar;
CAccountInfo myaccount;
#include <Trade\Trade.mqh>
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
CTimer Timer;
CiVelas *ciVelas;
CiVelas *ciVelasTend;

//+------------------------------------------------------------------+
//|                                                  Velas_class.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

//--- input parameters

input int Magic_Number =281217;// Numero Magico
input ulong deviation_points=100;//Deviation in Points
sinput string Volume;
input double   Lot=1;            // Lots to trade
sinput string Lucro="Lucro para fechamento";
input double lucro=1000.0;
input bool UseTimer = true;
input int StartHour = 9;
input int StartMinute = 5;
input int EndHour = 17;
input int EndMinute = 30;
input bool Daytrade=true;// Fechar posicoes Daytrade fim do dia
input double _Stop=500;//Stop Loss
input double _TakeProfit=3000; //Take Profit
input bool UsarRompimento=false;//Usar Rompimento para Entradas
input int BarrasExpirarOrdem=2;//Número de Barras até ordem aberta expirar
input int BarrasVerificarEntrada=4;//Numero de Barras p/ verificar rompimento max e min
input int Dist_Rompimento=10;//Distancia de rompimento para entradas
input bool UsarRealizParc=false;//Usar Realização Parcial
input double DistanceRealizeParcial = 45;
input double LotesParcial = 1;
input bool BarraAtual=false;//True:Barra Atual, False Espera Fechamento
input bool UseBreakEven=false;//Usar BreakEven
input int BreakEvenPoint1=100;//Pontos para BreakEven 1
input int ProfitPoint1=80;//Pontos de Lucro da Posicao 1
input int BreakEvenPoint2=200;//Pontos para BreakEven 2
input int ProfitPoint2=150;//Pontos de Lucro da Posicao 2
input int BreakEvenPoint3=300;//Pontos para BreakEven 3
input int ProfitPoint3=250;//Pontos de Lucro da Posicao 3
input int BreakEvenPoint4=500;//Pontos para BreakEven 4
input int ProfitPoint4=400;//Pontos de Lucro da Posicao 4
input int BreakEvenPoint5=700;//Pontos para BreakEven 5
input int ProfitPoint5=550;//Pontos de Lucro da Posicao 5
input bool Filtro_ADX=false;//Usar Filtro ADX
input int adx_period=14;//Periodo ADX
input double ADX_min=20.0;//ADX mínimo
input bool UseTrailingStop = false;//Usar Trailing
input int TrailingStop = 250;//Distancia do Stop
input int MinimumProfit = 0; //Lucro Minimo pra ativar o Stop
input int Step = 20; //Passo pra atualizar o STOP
input bool Use_STOP_ATR=true;// Usar Stop loss/gain movel STOPATR
input int dist_STOP_ATR=250;//Distância em pontos para STOP ATR

sinput string s_velas="-------------------VELAS COLORIDAS------------------------------";
input ENUM_TIMEFRAMES period_velas=PERIOD_CURRENT;//Período das Velas
input bool pMedia1=true;// Usar Media 1
input bool pPlot1=true;//Plotar Media 1
input int pperiodo1=50;// Periodo Media 1
input bool pMedia2=true;// Usar Media 2
input bool pPlot2=true;//Plotar Media 2
input int pperiodo2=200;//Periodo Media 2
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
input ENUM_TIMEFRAMES tend_period=PERIOD_M1;//TimeFrame da Tendência
input bool Media1_T=false;// Usar Media 1
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
input bool Usar_Hilo_T=true;// Usar Hilo
input bool Plot_hilo_T=true;//Plotar hilo
input int period_hilo_T=144;//Periodo Hilo
input int shift_hilo_T=0;// Deslocar Hilo


long curChartID,newChartID;
int handle_ma1_T,handle_ma2_T,handle_ma3_T,handle_ma4_T,handle_atr_T,handle_vwap_T,handle_hilo_T;           //Handle for the MA indicators
int ATR_Handle,stop_atr_Handle,ADX_Handle;  //
int barra_trade;
int BreakEvenPoint[5],ProfitPoint[5];

double ATR_buffer[],LOWER_STOP_ATR_buffer[],UPPER_STOP_ATR_buffer[];//buffer do ATR normal
double ADX_buffer[],ADX_P_buffer[],ADX_N_buffer[],close[];



//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+
double lotes,ponto,ticksize,sl_aux,tp_aux;
double StopLoss,TakeProfit;
double lotes_trade;

long digits;
bool tradeOn;
bool a_compra,a_venda;
double lucro_total,profit,saldo_inicial;
double ask,bid,preco;
datetime currentTime;
double preco_abertura;
int win;
long posicao;




int OnInit()
  {
mysymbol.Name(Symbol());
mytrade.SetExpertMagicNumber(Magic_Number);
mytrade.SetTypeFilling(ORDER_FILLING_FOK);
mytrade.SetDeviationInPoints(deviation_points);
if (BarraAtual)barra_trade=0;
    else barra_trade=1;


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

  ponto=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  ticksize=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE);
  digits =(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
      
      
  
  
if (Use_STOP_ATR)
     {
     stop_atr_Handle=iCustom(Symbol(),period_velas,"atrstops_v1",pLength,pATRPeriod,pKv,pShift);
     
     
     if(stop_atr_Handle==INVALID_HANDLE)
     {
      Print(": Falha em obter o indicador STOP ATR");
      Print("Handle = ",stop_atr_Handle,"  error = ",GetLastError());
      return(INIT_FAILED);
     }
     
     
     }//Fim ATR
     
     if (Filtro_ADX)
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
 
  
 BreakEvenPoint[0]=BreakEvenPoint1;BreakEvenPoint[1]=BreakEvenPoint2;BreakEvenPoint[2]=BreakEvenPoint3;
 BreakEvenPoint[3]=BreakEvenPoint4;BreakEvenPoint[4]=BreakEvenPoint5;      
ProfitPoint[0]=ProfitPoint1;ProfitPoint[1]=ProfitPoint2;ProfitPoint[2]=ProfitPoint3;
 ProfitPoint[3]=ProfitPoint4;ProfitPoint[4]=ProfitPoint5;      

 
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
   mysymbol.Refresh();
  mysymbol.RefreshRates();
   ciVelas.Refresh();
   if (Use_TEND)ciVelasTend.Refresh();
if(GetIndValue()) 
{
Print("Erro em obter os dados dos buffers de indicadores na funcao GET");
return;
}
  

bool novodia;
novodia=NewBar.CheckNewBar(_Symbol,PERIOD_D1);
if (novodia) 
{
saldo_inicial=AccountInfoDouble(ACCOUNT_BALANCE);
lucro_total=AccountInfoDouble(ACCOUNT_BALANCE)-saldo_inicial;

tradeOn=true;
}

if (PosicaoAberta())
{ lucro_total=PositionGetDouble(POSITION_PROFIT)+myaccount.Balance()-saldo_inicial;
}
else lucro_total=AccountInfoDouble(ACCOUNT_BALANCE)-saldo_inicial;

if (lucro_total>=lucro) 
{
if (PosicaoAberta())
{
DeleteALL();
CloseALL();
}
tradeOn=false;
}
else tradeOn=true;

bool timerOn = true;
if(UseTimer == true)
	{
		timerOn = Timer.DailyTimer(StartHour,StartMinute,EndHour,EndMinute);
		//timerOn = Timer.BlockTimer(block,UseLocalTime);

	}
if (timerOn==false &&PosicaoAberta()) 
{
DeleteALL();
CloseALL();
}	
 
   MqlTick last_tick;
   if (SymbolInfoTick(Symbol(),last_tick)) 
     { 
      bid = last_tick.bid;
      ask=last_tick.ask;
      preco=last_tick.last; 
       
     }
    else {Print("Falhou obter o tick");}
   double spread=ask-bid; 
   
   
   
//----------------------------------------------------------------------------
 
//------------------------------------------------------------------------------
if (tradeOn && timerOn)
  {// inicio Trade On
 
   
     //posicao=PositionGetInteger(POSITION_TYPE);
     posicao=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
     if (NewBar.CheckNewBar(Symbol(),PERIOD_CURRENT))
     {
     double cor=ciVelas.CorVela(1);
     Print("COR ",ciVelas.CorVela(1));
     }
       
//------------------------------------------------------------------
if(BuySignal()&&(!Buy_opened()))    // Open long position
     {
     
     DeleteOrders(ORDER_TYPE_SELL_STOP);
     // Adicionar StopLoss e TakeProfit
     if (Sell_opened())lotes_trade=myposition.Volume()+Lot;
     else lotes_trade=Lot;
       if (_Stop>0) StopLoss=NormalizeDouble(_Stop,digits);
       else StopLoss=0;
       if (_TakeProfit>0)TakeProfit=NormalizeDouble(_TakeProfit,digits);
       else TakeProfit=0;
       if (UsarRompimento)OpenBuyStop(BarrasVerificarEntrada,Dist_Rompimento,lotes_trade,StopLoss,TakeProfit,Expiration(BarrasExpirarOrdem));
       else
       {
       double vol=PositionGetDouble(POSITION_VOLUME);
       if (_Stop>0) StopLoss=NormalizeDouble(bid-_Stop*ponto,digits);
       else StopLoss=0;
       if (_TakeProfit>0)TakeProfit=NormalizeDouble(ask+_TakeProfit*ponto,digits);
       else TakeProfit=0;
       
       mytrade.Buy(Lot+vol,NULL,0,StopLoss,TakeProfit,"");
       }
               	   	
      }// End By Condition 
   
       
 
 //------------------------------------------------------------------
      
   if(SellSignal()&&(!Sell_opened()))   // Open short position
     { 
       DeleteOrders(ORDER_TYPE_BUY_STOP);
       // Adicionar StopLoss e TakeProfit
       if (Buy_opened())lotes_trade=myposition.Volume()+Lot;
       else lotes_trade=Lot;
       if (_Stop>0)StopLoss=NormalizeDouble(_Stop,digits);
       else StopLoss=0;
       if (_TakeProfit>0)TakeProfit=NormalizeDouble(_TakeProfit,digits);
       else TakeProfit=0;
       if (UsarRompimento)OpenSellStop(BarrasVerificarEntrada,Dist_Rompimento,lotes_trade,StopLoss,TakeProfit,Expiration(BarrasExpirarOrdem));
       else
       {
       double vol=PositionGetDouble(POSITION_VOLUME);
       if (_Stop>0)StopLoss=NormalizeDouble(ask+_Stop*ponto,digits);
       else StopLoss=0;
       if (_TakeProfit>0)TakeProfit=NormalizeDouble(bid-_TakeProfit*ponto,digits);
       else TakeProfit=0;

       
       mytrade.Sell(Lot+vol,NULL,0,StopLoss,TakeProfit,"");
      
       }
       
      }// End Sell COndition
      //------------------------------------------------------------------
 


//Ajustar Volume
if (myposition.Volume()>Lot)AjusteVolumePosicao(Lot);    




     
      

if (PosicaoAberta() && ciVelas.CorVela(1)==2.0)CloseALL();//Fechar no candle amarelo


// STOP Movel pelo STOP ATR + vz*ATR
if (Use_STOP_ATR==true && PosicaoAberta())  Stop_ATR();


if(UseTrailingStop) TrailingStop(Symbol(),TrailingStop,MinimumProfit, Step);	
if (UsarRealizParc)RealizacaoParcial();

//BrakeEven
if (UseBreakEven==true && PosicaoAberta() ) BreakEven(Symbol(),UseBreakEven,BreakEvenPoint,ProfitPoint);

 
 }// Fim tradeOn
 
 else
{
if (Daytrade==true &&PosicaoAberta()) 
{
DeleteALL();
CloseALL();
}
} // fechou ordens pendentes no Day trade fora do horario


Comentarios();


   
   return;
  
  
 }// fim OnTick



//+------------------------------------------------------------------+
//+-------------ROTINAS----------------------------------------------+
//+------------------------------------------------------------------+
//| Buy conditions                                                   |
//+------------------------------------------------------------------+
bool IsExpirationTypeAllowed(string symbol,int exp_type) 
  { 
//--- Obtém o valor da propriedade que descreve os modos de expiração permitidos 
   int expiration=(int)SymbolInfoInteger(symbol,SYMBOL_EXPIRATION_MODE); 
//--- Retorna true, se o modo exp_type é permitido 
   return((expiration&exp_type)==exp_type); 
  }

bool IsFillingTypeAllowed(string symbol,int fill_type) 
  { 
//--- Obtém o valor da propriedade que descreve os modos de preenchimento permitidos 
   int filling=(int)SymbolInfoInteger(symbol,SYMBOL_FILLING_MODE); 
//--- Retorna true, se o modo fill_type é permitido 
   return((filling & fill_type)==fill_type); 
  }

bool Buy_opened()
{
if(PositionSelect(_Symbol)==true && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         return(true);  //It is a Buy
        }
      else return(false); 
}

bool Sell_opened()
{
if(PositionSelect(_Symbol)==true && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         return(true);  //It is a Sell
        }
      else return(false); 
}



bool BuySignal()
  {bool b_signal;
  b_signal=ciVelas.CorVela(barra_trade)==0.0 && ciVelas.CorVela(barra_trade+1)!=0.0;
  if (Filtro_ADX)b_signal=b_signal&&(ADX_buffer[0]>ADX_min);
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
  s_signal=ciVelas.CorVela(barra_trade)==1.0 && ciVelas.CorVela(barra_trade+1)!=1.0;
  if (Filtro_ADX)s_signal=s_signal&&(ADX_buffer[0]>ADX_min);
  
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
if (Filtro_ADX) s_usar_adx="SIM";
else s_usar_adx="NÃO";
if (Use_TEND)s_usar_tend="TENDENCIA: "+Tendencia();
else s_usar_tend="";
string s_adx;
if (Filtro_ADX) 
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
   CopyBuffer(stop_atr_Handle,1,0,3,LOWER_STOP_ATR_buffer)<=0;
   }
   else i_atr=false;
   if (Filtro_ADX)
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




// Trailing stop (points)
void TrailingStop(string pSymbol,int pTrailPoints,int pMinProfit=0,int pStep=10)
{
  MqlTradeRequest request;
  MqlTradeResult result;
  if(PositionSelect(pSymbol) == true && pTrailPoints > 0)
	{
		double currentTakeProfit=PositionGetDouble(POSITION_TP);         
      long posType = PositionGetInteger(POSITION_TYPE);
		double currentStop = PositionGetDouble(POSITION_SL);
		double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
		
		double point = SymbolInfoDouble(pSymbol,SYMBOL_POINT);
		int digits = (int)SymbolInfoInteger(pSymbol,SYMBOL_DIGITS);
		
		if(pStep < 10) pStep = 10;
		double step = pStep * point;
		
		double minProfit = pMinProfit * point;
		double trailStop = pTrailPoints * point;
		currentStop = NormalizeDouble(currentStop,digits);
		currentTakeProfit=NormalizeDouble(currentTakeProfit,digits);
		double trailStopPrice;
		double currentProfit;
		
		
		
			if(posType == POSITION_TYPE_BUY)
			{
				trailStopPrice = SymbolInfoDouble(pSymbol,SYMBOL_BID) - trailStop;
				trailStopPrice = NormalizeDouble(trailStopPrice,digits);
				currentProfit = SymbolInfoDouble(pSymbol,SYMBOL_BID) - openPrice;
				
				if(trailStopPrice > currentStop + step && currentProfit >= minProfit)
				{
				mytrade.PositionModify(Symbol(),trailStopPrice,currentTakeProfit);	
				}
				
			}
			else if(posType == POSITION_TYPE_SELL)
			{
				trailStopPrice = SymbolInfoDouble(pSymbol,SYMBOL_ASK) + trailStop;
				trailStopPrice = NormalizeDouble(trailStopPrice,digits);
				currentProfit = openPrice - SymbolInfoDouble(pSymbol,SYMBOL_ASK);
				
				if((trailStopPrice < currentStop - step || currentStop == 0) && currentProfit >= minProfit)
				{	
					mytrade.PositionModify(Symbol(),trailStopPrice,currentTakeProfit);
				}
				
			}
}			

}





bool PosicaoAberta()
{
return(PositionGetInteger(POSITION_TYPE)== POSITION_TYPE_BUY||PositionGetInteger(POSITION_TYPE)== POSITION_TYPE_SELL);
}
//------------------------------------------------------------------------
void CloseALL()
{

   for (int i=PositionsTotal()-1;i>=0; i--) 
   { 
      if(PositionGetInteger(POSITION_MAGIC)==Magic_Number){
         if(!mytrade.PositionClose(PositionGetSymbol(i))) 
         {
            Print(PositionGetSymbol(i), "PositionClose() method failed. Return code=",mytrade.ResultRetcode(),
            ". Code description: ",mytrade.ResultRetcodeDescription());
         }
         else
         {
            Print(PositionGetSymbol(i), "PositionClose() method executed successfully. Return code=",mytrade.ResultRetcode(),
            " (",mytrade.ResultRetcodeDescription(),")");
         }
      }   
   }
}
//------------------------------------------------------------------------
//------------------------------------------------------------------------
// Select total orders in history and get total pending orders
// (as shown within the COrderInfo class section). 
void DeleteALL()
{
int o_total=OrdersTotal();
for(int j=o_total-1; j>=0; j--)
{
   ulong o_ticket = OrderGetTicket(j);
   if(o_ticket != 0)
   {
    // delete the pending Sell Stop order
    mytrade.OrderDelete(o_ticket);
   }
}
}
//------------------------------------------------------------------------
//------------------------------------------------------------------------
int Expiration(int barras)
{
return(TimeTradeServer()+barras*PeriodSeconds(period_velas));
}
//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
void OpenBuyStop(int barras,int distancia,double lotes,int stoploss,int takeprofit,int expiration)
{
 double oldprice=0.0;
 double bprice =HighestHigh(Symbol(),period_velas,barras,1) + distancia*ponto;
 oldprice=PriceLastStopOrder(ORDER_TYPE_BUY_STOP);
if(oldprice==-1 || bprice<oldprice) // No order or New price is better
{
DeleteOrders(ORDER_TYPE_BUY_STOP);  
 double mprice=NormalizeDouble(bprice,_Digits); 
 double stloss = NormalizeDouble(bprice - stoploss*ponto,_Digits);
 double tprofit = NormalizeDouble(bprice+ takeprofit*ponto,_Digits);
if (bprice>mysymbol.Ask()) 
{
if(mytrade.BuyStop(lotes,mprice,_Symbol,stloss,tprofit,ORDER_TIME_SPECIFIED,expiration))
        {
         Print("Орen Buy Stop:",mytrade.ResultOrder(),"!!");
         return;
        }
      else
        {
         Print("Erro Ordem Buy Stop:",mytrade.RequestVolume(), ", sl:", mytrade.RequestSL(),", tp:",mytrade.RequestTP(), ", price:", mytrade.RequestPrice(), " Erro:",mytrade.ResultRetcodeDescription());
         return;
        }
}
else mytrade.Buy(lotes,NULL,0,stloss,tprofit,"");
}
}

//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
void OpenSellStop(int barras,int distancia,double lotes,int stoploss,int takeprofit,int expiration)
{


double bprice =LowestLow(Symbol(),period_velas,barras,1)- distancia*ponto;
double oldprice=0.0;
oldprice=PriceLastStopOrder(ORDER_TYPE_SELL_STOP);
if(oldprice==-1 || bprice>oldprice) // No order or New price is better
{
DeleteOrders(ORDER_TYPE_SELL_STOP);
 double mprice=NormalizeDouble(bprice,_Digits); 
 double stloss = NormalizeDouble(bprice + stoploss*ponto,_Digits);
 double tprofit = NormalizeDouble(bprice- takeprofit*ponto,_Digits);
 string comentario="Enviada Ordem SellStop";

if (bprice<mysymbol.Bid())
{
 if(mytrade.SellStop(lotes,mprice,_Symbol,stloss,tprofit,ORDER_TIME_SPECIFIED,expiration))
        {
         Print("Орen Sell Stop:",mytrade.ResultOrder(),"!!");
        return; 
        }
      else
        {
         Print("Erro Ordem Sell Stop:",mytrade.RequestVolume(), ", sl:", mytrade.RequestSL(),", tp:",mytrade.RequestTP(), ", price:", mytrade.RequestPrice(), " Erro:",mytrade.ResultRetcodeDescription());
         return;
        }
}
else mytrade.Sell(lotes,NULL,0,stloss,tprofit,"");
}
}
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------

void AjusteVolumePosicao(double lotes)
{
double volume=PositionGetDouble(POSITION_VOLUME);
long posType = PositionGetInteger(POSITION_TYPE);
double lot_aux=volume-lotes;
if(posType == POSITION_TYPE_BUY && lot_aux>0)mytrade.Sell(lot_aux);
if(posType == POSITION_TYPE_SELL && lot_aux>0)mytrade.Buy(lot_aux);

}

bool Dunn_Compra()
{
MqlRates mrate[3];         
ArraySetAsSeries(mrate,true);
if (CopyRates(_Symbol,period_velas,0,3,mrate)<0)
     {
      Alert("Error copying rates/history data in Dunn_Compra Function - error:",GetLastError(),"!!");
      return(false);
     }

if (mrate[2].low<mrate[1].low && mrate[1].low<mrate[0].low && mrate[2].high<mrate[1].high && mrate[1].low<mrate[0].high)return(true);
else return(false);

}

bool Dunn_Venda()
{
MqlRates mrate[3];         
ArraySetAsSeries(mrate,true);
if (CopyRates(_Symbol,period_velas,0,3,mrate)<0)
     {
      Alert("Error copying rates/history data in Dunn_Compra Function - error:",GetLastError(),"!!");
      return(false);
     }

if (mrate[2].low>mrate[1].low && mrate[1].low>mrate[0].low && mrate[2].high>mrate[1].high && mrate[1].low>mrate[0].high)return(true);
else return(false);

}


//+------------------------------------------------------------------+
//| Highest High & Lowest Low                                        |
//+------------------------------------------------------------------+

double HighestHigh(string pSymbol, ENUM_TIMEFRAMES pPeriod, int pBars, int pStart = 0)
{
	double high[];
	ArraySetAsSeries(high,true);
	
	int copied = CopyHigh(pSymbol,pPeriod,pStart,pBars,high);
	if(copied == -1) return(copied);
	
	int maxIdx = ArrayMaximum(high);
	double highest = high[maxIdx];
	
	return(highest);
}


double LowestLow(string pSymbol, ENUM_TIMEFRAMES pPeriod, int pBars, int pStart = 0)
{
	double low[];
	ArraySetAsSeries(low,true);
	
	int copied = CopyLow(pSymbol,pPeriod,pStart,pBars,low);
	if(copied == -1) return(copied);
	
	int minIdx = ArrayMinimum(low);
	double lowest = low[minIdx];
	
	return(lowest);
}


void RealizacaoParcial()
{

double price=PositionGetDouble(POSITION_PRICE_OPEN);
double volume=PositionGetDouble(POSITION_VOLUME);
long posType = PositionGetInteger(POSITION_TYPE);
double currentProfit;
double bid = SymbolInfoDouble(_Symbol,SYMBOL_BID);
double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
if(posType == POSITION_TYPE_BUY && volume==Lot)
{
currentProfit = bid - price;
		
if(currentProfit>=DistanceRealizeParcial*_Point)
{
  mytrade.Sell(LotesParcial);
  
}                
}                           

if(posType == POSITION_TYPE_SELL && volume==Lot)
{
currentProfit = price-ask;
		
if(currentProfit>=DistanceRealizeParcial*_Point)
{
  mytrade.Buy(LotesParcial);
    
}                
}                           


}


double PriceLastStopOrder(const ENUM_ORDER_TYPE pending_order_type)
  {
   datetime last_time=0;
   double last_price=-1.0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==pending_order_type)
               if(myorder.TimeSetup()>last_time)
                 {
                  last_time=myorder.TimeSetup();
                  last_price=myorder.PriceOpen();
                 }
//---
   return(last_price);
  }

//+------------------------------------------------------------------+
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void DeleteOrders(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+

void Stop_ATR()
{
 digits = (int) SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
 preco_abertura=PositionGetDouble(POSITION_PRICE_OPEN);
 posicao=PositionGetInteger(POSITION_TYPE);
 if (posicao==POSITION_TYPE_BUY)
 {
 
 if ((close[0]>=UPPER_STOP_ATR_buffer[1])&& UPPER_STOP_ATR_buffer[1]!=EMPTY_VALUE) 
 {
 StopLoss=NormalizeDouble(MathRound(UPPER_STOP_ATR_buffer[1]/ticksize)*ticksize-dist_STOP_ATR*ponto,digits);
 }
 			
 double stop_atual=PositionGetDouble(POSITION_SL);
 double take_atual=PositionGetDouble(POSITION_TP);
 if (stop_atual!=0 && StopLoss< stop_atual) StopLoss=stop_atual;
 if (StopLoss>0 && StopLoss<bid && StopLoss!=stop_atual) mytrade.PositionModify(Symbol(),StopLoss,take_atual);
 
 }  
 
 if (posicao==POSITION_TYPE_SELL)
 {

 if ((close[0]<=LOWER_STOP_ATR_buffer[1])&& LOWER_STOP_ATR_buffer[1]!=EMPTY_VALUE) 
 {
 StopLoss=NormalizeDouble(MathRound(LOWER_STOP_ATR_buffer[1]/ticksize)*ticksize+dist_STOP_ATR*ponto,digits);
 }
 			
double stop_atual=PositionGetDouble(POSITION_SL);
double take_atual=PositionGetDouble(POSITION_TP);
if (stop_atual!=0 && StopLoss> stop_atual) StopLoss=stop_atual;
if (StopLoss>0 && StopLoss>ask && StopLoss!=stop_atual) mytrade.PositionModify(Symbol(),StopLoss,take_atual);
 }    
}



// Break even stop
void BreakEven(string pSymbol,bool usarbreak,int &pBreakEven[],int &pLockProfit[])
{
	if(PositionSelect(pSymbol) == true && usarbreak==true)
	{
		
		 long posType = PositionGetInteger(POSITION_TYPE);
		double currentSL = PositionGetDouble(POSITION_SL);
		double openPrice = PositionGetDouble(POSITION_PRICE_OPEN);
		double currentTP=PositionGetDouble(POSITION_TP);
		double breakEvenStop;
		double currentProfit;
		double ponto=SymbolInfoDouble(pSymbol,SYMBOL_POINT);
		int retryCount = 0;
		int checkRes = 0;
		
		double bid = 0, ask = 0;
		
			if(posType == POSITION_TYPE_BUY)
			{
				bid = SymbolInfoDouble(pSymbol,SYMBOL_BID);
				currentProfit = bid - openPrice;
				//Break Even 0
				if (currentProfit>=pBreakEven[0]* ponto && currentProfit<pBreakEven[1]*ponto)
				{
				breakEvenStop = openPrice + pLockProfit[0] * ponto;
				if(currentSL < breakEvenStop || currentSL == 0)mytrade.PositionModify(pSymbol,breakEvenStop,currentTP);
				
				}
				//----------------------
				//Break Even 1
				else if (currentProfit>=pBreakEven[1]* ponto && currentProfit<pBreakEven[2]*ponto)
				{
				breakEvenStop = openPrice + pLockProfit[1] * ponto;
				if(currentSL < breakEvenStop || currentSL == 0)mytrade.PositionModify(pSymbol,breakEvenStop,currentTP);
				
				}
				//----------------------
            //Break Even 2
				else if (currentProfit>=pBreakEven[2]* ponto && currentProfit<pBreakEven[3]*ponto)
				{
				breakEvenStop = openPrice + pLockProfit[2] * ponto;
				if(currentSL < breakEvenStop || currentSL == 0)mytrade.PositionModify(pSymbol,breakEvenStop,currentTP);
				
				}
				//----------------------
            //Break Even 3
				else if (currentProfit>=pBreakEven[3]* ponto && currentProfit<pBreakEven[4]*ponto)
				{
				breakEvenStop = openPrice + pLockProfit[3] * ponto;
				if(currentSL < breakEvenStop || currentSL == 0)mytrade.PositionModify(pSymbol,breakEvenStop,currentTP);
				
				}
				//----------------------
				//Break Even 4
				else if (currentProfit>=pBreakEven[4]* ponto)
				{
				breakEvenStop = openPrice + pLockProfit[4] * ponto;
				if(currentSL < breakEvenStop || currentSL == 0)mytrade.PositionModify(pSymbol,breakEvenStop,currentTP);
				
				}
				//----------------------
                    				
							
			}// End Position Buy
			
			else if(posType == POSITION_TYPE_SELL)
			{
				ask = SymbolInfoDouble(pSymbol,SYMBOL_ASK);
				currentProfit = openPrice - ask;
				//Break Even 0
				if (currentProfit>=pBreakEven[0]* ponto && currentProfit<pBreakEven[1]*ponto)
				{
				breakEvenStop = openPrice - pLockProfit[0] * ponto;
				if(currentSL > breakEvenStop || currentSL == 0)mytrade.PositionModify(pSymbol,breakEvenStop,currentTP);
				
				}
				//----------------------
				//Break Even 1
				else if (currentProfit>=pBreakEven[1]* ponto && currentProfit<pBreakEven[2]*ponto)
				{
				breakEvenStop = openPrice - pLockProfit[1] * ponto;
				if(currentSL > breakEvenStop || currentSL == 0)mytrade.PositionModify(pSymbol,breakEvenStop,currentTP);
				
				}
				//----------------------
            //Break Even 2
				else if (currentProfit>=pBreakEven[2]* ponto && currentProfit<pBreakEven[3]*ponto)
				{
				breakEvenStop = openPrice - pLockProfit[2] * ponto;
				if(currentSL > breakEvenStop || currentSL == 0)mytrade.PositionModify(pSymbol,breakEvenStop,currentTP);
				
				}
				//----------------------
            //Break Even 3
				else if (currentProfit>=pBreakEven[3]* ponto && currentProfit<pBreakEven[4]*ponto)
				{
				breakEvenStop = openPrice - pLockProfit[3] * ponto;
				if(currentSL > breakEvenStop || currentSL == 0)mytrade.PositionModify(pSymbol,breakEvenStop,currentTP);
				
				}
				//----------------------
				//Break Even 4
				else if (currentProfit>=pBreakEven[4]* ponto)
				{
				breakEvenStop = openPrice - pLockProfit[4] * ponto;
				if(currentSL > breakEvenStop || currentSL == 0)mytrade.PositionModify(pSymbol,breakEvenStop,currentTP);
				
				}
				//----------------------
     
									
				
			}//End Position SELL
			
			
				
	}//End Usar break
	
}
