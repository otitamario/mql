//+------------------------------------------------------------------+
//|                                                     Junio_v3.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "3.00"
enum Applied_price_      // Type of constant
  {
   PRICE_CLOSE_ = 1,     // Close
   PRICE_OPEN_,          // Open
   PRICE_HIGH_,          // High
   PRICE_LOW_,           // Low
   PRICE_MEDIAN_,        // Median Price (HL/2)
   PRICE_TYPICAL_,       // Typical Price (HLC/3)
   PRICE_WEIGHTED_,      // Weighted Close (HLCC/4)
   PRICE_SIMPLE,         // Simple Price (OC/2)
   PRICE_QUARTER_,       // Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  // TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   // TrendFollow_2 Price 
  };



#include <SmoothAlgorithms.mqh> 

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>
#include <CustomOptimisation.mqh>
//Classes
TCustomCriterionArray*  criterion_Ptr;
CNewBar NewBar;
CAccountInfo myaccount;
CDealInfo mydeal; 
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
CTimer Timer;



// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_M1;
input ulong Magic_Number =2018;
input int num_ordens=2;//Número de ordens
input ulong deviation_points=50;//Deviation in Points
input double Lot = 2;//Lotes
sinput string Lucro="Lucro para fechamento";
input bool UsarLucro=true;
input double lucro=3000.0;
input double prejuizo=500.0;
input bool UsarRealizParc=true;//Usar Realização Parcial
input double DistanceRealizeParcial = 60;
input double LotesParcial = 1;
input bool UseTimer = true;
input int StartHour = 9;
input int StartMinute = 5;
input int EndHour = 17;
input int EndMinute = 30;
input bool Daytrade=true;// Fechar posicoes Daytrade fim do dia
input double _Stop=300;//Stop Loss
input double _TakeProfit=2000; //Take Profit
input bool UseBreakEven=true;//Usar BreakEven
input int BreakEvenPoint1=120;//Pontos para BreakEven 1
input int ProfitPoint1=50;//Pontos de Lucro da Posicao 1
input int BreakEvenPoint2=400;//Pontos para BreakEven 2
input int ProfitPoint2=250;//Pontos de Lucro da Posicao 2
input bool   Use_TraillingStop =false;
input int TraillingStart = 0;//Lucro minimo Inicio do trailing stop
input int TraillingDistance=250;// Distancia do STOP movel para o preço
input int TraillingStep=20;// Passo para atualizar STOP movel
input bool UseSTOPMEDIA=true;//Usar Stop na media movel
input double DistSTOPMedia=40;//Distancia para media do stop movel
input bool StopCandle=true;//Usar Stop Candle
input double DistSTOPCandle=40;//Distancia para Candle Anterior
input double brickrenco=60;//Brick Renko
input ENUM_APPLIED_PRICE InpApplyToPrice= PRICE_CLOSE; // Apply to
input Smooth_Method xMA_Method=MODE_EMA_; // Averaging method
input int TrLength1=3;   // 1 trader averaging period 
input int TrLength2=5;   // 2 trader averaging period 
input int TrLength3=8;   // 3 trader averaging period 
input int TrLength4=10;  // 4 trader averaging period 
input int TrLength5=12;  // 5 trader averaging period
input int TrLength6=15;  // 6 trader averaging period 
input int InvLength1=30; // 1 investor averaging period
input int InvLength2=35; // 2 investor averaging period
input int InvLength3=40; // 3 investor averaging period
input int InvLength4=45; // 4 investor averaging period
input int InvLength5=50; // 5 investor averaging period
input int InvLength6=60; // 6 investor averaging period
input Applied_price_ IPC=PRICE_CLOSE_; // Price constant




double ask,bid;
double ma_compra[],ma_venda[];
double TakeProfit_v = 0;
double StopLoss_v = 0;
bool work_time;
string NUMBER_ORDER = "NUMBER_ORDER_"+Magic_Number;
int ORDERS = 0;
int BreakEvenPoint[2],ProfitPoint[2];
double lucro_total,profit,saldo_inicial;
bool tradeOn;
double StopLoss,TakeProfit;
double preco,ponto,ticksize,digits,lotes_trade,stop_movel;
long posicao;
double high[],low[],open[],close[];
long curChartID,newChartID,secChartID;
int hma_handle;
int fractal_handle;
int gmma_handle;

double MA_RAP1[],MA_RAP2[],MA_RAP3[],MA_RAP4[],MA_RAP5[],MA_RAP6[];
double MA_LEN1[],MA_LEN2[],MA_LEN3[],MA_LEN4[],MA_LEN5[],MA_LEN6[];
double price_open;
long num_tick_anterior=0;
long num_tick_atual=0;
datetime time_inicio,time_novodia;
MqlDateTime inicio_struct;
ulong BuyTicket=0,SellTicket=0,Hedge_Buy_Ticket=0,Hedge_Sell_Ticket=0;
double stop_compra,stop_venda;
double stop_ordem_buy,take_ordem_buy,stop_ordem_sell,take_ordem_sell,preco_compra,preco_venda;
double renko_low,renko_high;
bool wick_buy=false,wick_sell=false;
bool medias_up=false,medias_down=false;
bool rap_atual=false,rap_anterior=false;
bool lenta_atual=false,lenta_anterior=false;
double total_ma_rap,total_ma_len,total_ma_rap_ant,total_ma_len_ant;
int OrdersPrev = 0;        // Número de ordens  no momento da chamada anterior da OnTrade()

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
  
  OrdersPrev = OrdersTotal();
  mysymbol.Name(Symbol());
 mytrade.SetExpertMagicNumber(Magic_Number);
 mytrade.SetDeviationInPoints(deviation_points);
 if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      Print("ORDER_FILLING_FOK");
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      Print("ORDER_FILLING_IOC");
   else
      Print("ORDER_FILLING_RETURN");
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      mytrade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      mytrade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      mytrade.SetTypeFilling(ORDER_FILLING_RETURN);
  ponto=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  ticksize=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE);
  digits =(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);
 
    inicio_struct.hour=0;
    inicio_struct.min=0;
    inicio_struct.sec=0;
    time_inicio=StructToTime(inicio_struct);
    lucro_total=0.0;
    saldo_inicial=AccountInfoDouble(ACCOUNT_BALANCE);
    BreakEvenPoint[0]=BreakEvenPoint1;BreakEvenPoint[1]=BreakEvenPoint2;ProfitPoint[0]=ProfitPoint1;ProfitPoint[1]=ProfitPoint2;


  
   
    gmma_handle=iCustom(Symbol(),_Period,"gmma",xMA_Method,TrLength1,TrLength2,TrLength3,TrLength4,TrLength5,
                       TrLength6,InvLength1,InvLength2,InvLength3,InvLength4,InvLength5,InvLength6,100,IPC,0);

    
   ChartIndicatorAdd(ChartID(),0,gmma_handle);
  
 
   ArraySetAsSeries(MA_RAP1,true);
   ArraySetAsSeries(MA_RAP2,true);
   ArraySetAsSeries(MA_RAP3,true);
   ArraySetAsSeries(MA_RAP4,true);
   ArraySetAsSeries(MA_RAP5,true);
   ArraySetAsSeries(MA_RAP6,true);
   ArraySetAsSeries(MA_LEN1,true);
   ArraySetAsSeries(MA_LEN2,true);
   ArraySetAsSeries(MA_LEN3,true);
   ArraySetAsSeries(MA_LEN4,true);
   ArraySetAsSeries(MA_LEN5,true);
   ArraySetAsSeries(MA_LEN6,true);
     

  
   ArrayInitialize(close,0.0);
   ArraySetAsSeries(close,true);
   ArrayInitialize(high,0.0);
   ArraySetAsSeries(high,true);
   ArrayInitialize(low,0.0);
   ArraySetAsSeries(low,true);
   ArrayInitialize(open,0.0);
   ArraySetAsSeries(open,true);
   ArrayInitialize(ma_compra,0.0);
   ArrayInitialize(ma_venda,0.0);
   ArraySetAsSeries(ma_compra, true);
   ArraySetAsSeries(ma_venda, true);   
   

  curChartID = ChartID();
  ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
  ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
 ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

 
  
 //--------------------Criterios de Otimizacao
criterion_Ptr = new TCustomCriterionArray();
  if(CheckPointer(criterion_Ptr) == POINTER_INVALID)
  {
    return(-1);
  }

 //criterion_Ptr.Add(new TSimpleCriterion(STAT_PROFIT));
 // criterion_Ptr.Add(new TSimpleDivCriterion(STAT_BALANCE_DD));
  criterion_Ptr.Add(new TSimpleMinCriterion(STAT_TRADES, 600.0));
 //criterion_Ptr.Add(new TBalanceSlopeCriterion(Symbol( ), 10000.0));

    criterion_Ptr.Add(new TTSSFCriterion());
    
 // parametros incorretos desnecessarios na otimizacao
 
 if (Lot<=LotesParcial)
 {
 Print("Lote Parcial >= Lotes");
  return(INIT_PARAMETERS_INCORRECT);

 }     
//---
   return(INIT_SUCCEEDED);
  }


  
//---------------------------------------------------------------------
//  The handler of the event of completion of another test pass:
//---------------------------------------------------------------------
double OnTester()
{
 return(criterion_Ptr.GetCriterion());

}  


//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  
  IndicatorRelease(gmma_handle);
  
  Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");

if(CheckPointer(criterion_Ptr) == POINTER_DYNAMIC)
  {
    delete(criterion_Ptr);
  }
ChartIndicatorDelete(curChartID,0,"SinalAmaok");




//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
mysymbol.Refresh();
mysymbol.RefreshRates();  

if(GetIndValue()) 
{
Print("Erro em obter os dados dos buffers de indicadores na funcao GET");
return;
}
//---
//--------------------------------
   
   
   
 bool novodia;
double saldo;
//novodia=CheckNovoDia(Symbol(),PERIOD_M1);
novodia=NewBar.CheckNewBar(_Symbol,PERIOD_D1);
if (novodia) 
{
saldo_inicial=myaccount.Balance();
tradeOn=true;
}
/*
if (PosicaoAberta()) lucro_total=PositionGetDouble(POSITION_PROFIT)+myaccount.Balance()-saldo_inicial;
else lucro_total=AccountInfoDouble(ACCOUNT_BALANCE)-saldo_inicial;
*/

time_novodia=TimeCurrent(inicio_struct);
//lucro_total=myaccount.Equity()-saldo_inicial;
lucro_total=LucroOrdens()+LucroTotal();
if (UsarLucro &&(lucro_total>=lucro|| lucro_total<=-prejuizo)) 
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
   
        
//------------------------------------------------------------------
    
//------------------------------------------------------------------

EnviarStops();



if (NewBar.CheckNewBar(Symbol(),periodoRobo))
{
 
       
 
 if(StopCandle)
{

stop_movel=NormalizeDouble(DistSTOPCandle*ponto,digits);
for (int i=PositionsTotal()-1;i>=0; i--) 
{ 
if(myposition.SelectByIndex(i)&& myposition.Magic()==Magic_Number)
{
if (myposition.PositionType()==POSITION_TYPE_BUY)
{
double curSTP=myposition.StopLoss();
double curTake=myposition.TakeProfit();
double stp_compra=low[1]-stop_movel;
if (stp_compra>curSTP)mytrade.PositionModify(myposition.Ticket(),MathRound(stp_compra/ticksize)*ticksize,curTake);

}

if (myposition.PositionType()==POSITION_TYPE_SELL)
{
double curSTP=myposition.StopLoss();
double curTake=myposition.TakeProfit();
double stp_venda=high[1]+stop_movel;
if (stp_venda<curSTP)mytrade.PositionModify(myposition.Ticket(),MathRound(stp_venda/ticksize)*ticksize,curTake);
}
}//Fim if PositionSelect

}//Fim for

}      //Fim Stop Candle      



if(UseSTOPMEDIA)
{

stop_movel=NormalizeDouble(DistSTOPMedia*ponto,digits);
double stop_med=NormalizeDouble(MathRound(MA_RAP6[1]/ticksize)*ticksize,digits);

for (int i=PositionsTotal()-1;i>=0; i--) 
{ 
if(myposition.SelectByIndex(i)&& myposition.Magic()==Magic_Number)
{
if (myposition.PositionType()==POSITION_TYPE_BUY&&bid>MA_RAP6[1])
{
double curSTP=myposition.StopLoss();
double curTake=myposition.TakeProfit();
double stp_compra=stop_med-stop_movel;
if (stp_compra>curSTP)mytrade.PositionModify(myposition.Ticket(),MathRound(stp_compra/ticksize)*ticksize,curTake);

}

if (myposition.PositionType()==POSITION_TYPE_SELL&&ask<MA_RAP6[1])
{
double curSTP=myposition.StopLoss();
double curTake=myposition.TakeProfit();
double stp_venda=stop_med+stop_movel;
if (stp_venda<curSTP)mytrade.PositionModify(myposition.Ticket(),MathRound(stp_venda/ticksize)*ticksize,curTake);
}
}//Fim if PositionSelect

}//Fim for

}  //Fim STOP MEDIA

      
      
}//Fim NewBar




if (CheckBuyClose()) 
{
CloseALL();
DeleteALL();
}

if (CheckSellClose()) 
{
CloseALL();
DeleteALL();
}
//DeleteAbertas(2*brickrenco);
//Realizacao Parcial
if (UsarRealizParc)RealizacaoParcial();
//Reentrada();

//----------------------------------------------------------
//----------------------------------------------------------
//Ajustar Posicao

//Diminuir lote se prejuizo sem Hedge

  
//---------------------------------------------------------------------     
// Trailing stop
      
if(Use_TraillingStop)
{
if (Buy_opened())
{
stop_compra=myposition.StopLoss();
TrailingStop(Symbol(),myposition.Ticket(),TraillingDistance,TraillingStart, TraillingStep);
if (myposition.StopLoss()>stop_compra)stop_compra=myposition.StopLoss();
}	
if (Sell_opened())
{
stop_venda=myposition.StopLoss();
TrailingStop(Symbol(),myposition.Ticket(),TraillingDistance,TraillingStart, TraillingStep);
if (myposition.StopLoss()<stop_venda)stop_venda=myposition.StopLoss();
}	
}
//----------------------------------------------------------------------
if (UseBreakEven) BreakEven(Symbol(),UseBreakEven,BreakEvenPoint,ProfitPoint);





 
 }// Fim tradeOn
 
else
{
if (Daytrade==true) 
{
DeleteALL();
CloseALL();
}
} // fechou ordens pendentes no Day trade fora do horario



Comentarios();


   
   return;
  
  
 }// fim OnTick

 //+------------------------------------------------------------------+

//------------------------------------------------------------------------
//------------------------------------------------------------------------


//+-------------ROTINAS----------------------------------------------+
//+------------------------------------------------------------------+
//| Buy conditions                                                   |
//+------------------------------------------------------------------+
bool Buy_opened()
{
for (int i=PositionsTotal()-1;i>=0; i--) 
{ 
if(myposition.SelectByIndex(i)&& myposition.Magic()==Magic_Number&&myposition.PositionType()==POSITION_TYPE_BUY)
return(true);  //It is a Buy
}        
return(false); 
}

bool Sell_opened()
{
for (int i=PositionsTotal()-1;i>=0; i--) 
{ 
if(myposition.SelectByIndex(i)&& myposition.Magic()==Magic_Number&&myposition.PositionType()==POSITION_TYPE_SELL)
return(true);  //It is a Buy
}        
return(false); 
}




//+------------------------------------------------------------------+


bool BuySignal()
  {
  bool b_signal,buy_1,buy_2,buy_3,buy_4,cross_super;
  
  return b_signal;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
  bool s_signal,sell_1,sell_2,sell_3,sell_4,cross_super;
  return s_signal;
  }


double MaiorLenta(int k)
{
double len[6];
double maior;
len[0]=MA_LEN1[1];len[1]=MA_LEN2[k];len[2]=MA_LEN3[k];len[3]=MA_LEN4[k];len[4]=MA_LEN5[k];len[5]=MA_LEN6[k];
maior=len[0];
for (int i=1;i<6;i++)
if (len[i]>maior)maior=len[i];
return maior;
}

double MenorLenta(int k)
{
double len[6];
double menor;
len[0]=MA_LEN1[1];len[1]=MA_LEN2[k];len[2]=MA_LEN3[k];len[3]=MA_LEN4[k];len[4]=MA_LEN5[k];len[5]=MA_LEN6[k];
menor=len[0];
for (int i=1;i<6;i++)
if (len[i]<menor)menor=len[i];
return menor;
}




void EnviarStops()
{
 //BuyStops
 double oldprice=0;
 double bprice;
double maior_ma,menor_ma;
maior_ma=MaiorLenta(1);
menor_ma=MenorLenta(1);

if (close[0]<menor_ma)
{
oldprice=0;
bprice =NormalizeDouble(MathRound(maior_ma/ticksize)*ticksize + 25*ponto,digits);
oldprice=PriceLastStopOrder(ORDER_TYPE_BUY_STOP);
//Print("OLDPRICE ",oldprice," BPRICE ",bprice);
if(oldprice==-1 || bprice<oldprice) // No order or New price is better
{
DeleteOrders(ORDER_TYPE_BUY_STOP);  
double stloss = NormalizeDouble(MathRound(menor_ma/ticksize)*ticksize - 25*ponto,_Digits);
double tprofit = NormalizeDouble(bprice+ _TakeProfit*ponto,_Digits);
mytrade.BuyStop(Lot,bprice,NULL,stloss,tprofit,0,0,"BUY STOP");
}
}
if (close[0]>maior_ma)
{

oldprice=0;
bprice =NormalizeDouble(MathRound(menor_ma/ticksize)*ticksize - 25*ponto,digits);
oldprice=PriceLastStopOrder(ORDER_TYPE_SELL_STOP);
if(oldprice==-1 || bprice>oldprice) // No order or New price is better
{
DeleteOrders(ORDER_TYPE_SELL_STOP);  
double stloss = NormalizeDouble(MathRound(maior_ma/ticksize)*ticksize + 25*ponto,_Digits);
double tprofit = NormalizeDouble(bprice-_TakeProfit*ponto,_Digits);
mytrade.SellStop(Lot,bprice,NULL,stloss,tprofit,0,0,"SELL STOP");
}
}
 


}



bool rapidas(int k)
{
double rap[6];
double len[6];
rap[0]=MA_RAP1[k];rap[1]=MA_RAP2[k];rap[2]=MA_RAP3[k];rap[3]=MA_RAP4[k];rap[4]=MA_RAP5[k];rap[5]=MA_RAP6[k];
len[0]=MA_LEN1[1];len[1]=MA_LEN2[k];len[2]=MA_LEN3[k];len[3]=MA_LEN4[k];len[4]=MA_LEN5[k];len[5]=MA_LEN6[k];
for(int i=0;i<6;i++)
{
for (int j=0;j<6;j++)
{
if (rap[i]<=len[j])
{
return false;}
}
}
return true;
}
bool lentas(int k)
{
double rap[6];
double len[6];
rap[0]=MA_RAP1[k];rap[1]=MA_RAP2[k];rap[2]=MA_RAP3[k];rap[3]=MA_RAP4[k];rap[4]=MA_RAP5[k];rap[5]=MA_RAP6[k];
len[0]=MA_LEN1[1];len[1]=MA_LEN2[k];len[2]=MA_LEN3[k];len[3]=MA_LEN4[k];len[4]=MA_LEN5[k];len[5]=MA_LEN6[k];
for(int i=0;i<6;i++)
{
for (int j=0;j<6;j++)
{
if (rap[i]>=len[j])
{

return false;}
}
}
return true;

}
 



double VolumeBuyTotal()
{
 double vol=0;
   for (int i=PositionsTotal()-1;i>=0; i--) 
   if(myposition.SelectByIndex(i)&& myposition.Magic()==Magic_Number&&myposition.PositionType()==POSITION_TYPE_BUY)
   vol+=myposition.Volume();
         
   return vol;   
   
}

double VolumeSellTotal()
{
 double vol=0;
   for (int i=PositionsTotal()-1;i>=0; i--) 
   if(myposition.SelectByIndex(i)&& myposition.Magic()==Magic_Number&&myposition.PositionType()==POSITION_TYPE_SELL)
   vol+=myposition.Volume();
         
   return vol;   
   
}




//+------------------------------------------------------------------+
bool CheckSellClose()
  {
  return false;
  }
//+------------------------------------------------------------------+
//| Buy Close conditions                                                  |
//+------------------------------------------------------------------+
bool CheckBuyClose()
  {
  
  return false;
  
  }
  
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void Comentarios()
{

string s_coment=""+"\n"+"RESULTADO DIÁRIO: "+DoubleToString(lucro_total,2)+"\n";
Comment(s_coment);   

} 
  
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   bool b_get;
   b_get=CopyHigh(Symbol(),periodoRobo,0,5,high)<=0||
   CopyOpen(Symbol(),periodoRobo,0,5,open)<=0||
   CopyLow(Symbol(),periodoRobo,0,5,low)<=0||
   CopyClose(Symbol(),periodoRobo,0,5,close)<=0||
   CopyBuffer(gmma_handle,0,0,3,MA_RAP1)<=0||
   CopyBuffer(gmma_handle,1,0,3,MA_RAP2)<=0||
   CopyBuffer(gmma_handle,2,0,3,MA_RAP3)<=0||
   CopyBuffer(gmma_handle,3,0,3,MA_RAP4)<=0||
   CopyBuffer(gmma_handle,4,0,3,MA_RAP5)<=0||
   CopyBuffer(gmma_handle,5,0,3,MA_RAP6)<=0||
   CopyBuffer(gmma_handle,6,0,3,MA_LEN1)<=0||
   CopyBuffer(gmma_handle,7,0,3,MA_LEN2)<=0||
   CopyBuffer(gmma_handle,8,0,3,MA_LEN3)<=0||
   CopyBuffer(gmma_handle,9,0,3,MA_LEN4)<=0||
   CopyBuffer(gmma_handle,10,0,3,MA_LEN5)<=0||
   CopyBuffer(gmma_handle,11,0,3,MA_LEN6)<=0;

   if (b_get)Print("Erro em obter os buffers");
   
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
void TrailingStop(string pSymbol,ulong pticket,int pTrailPoints,int pMinProfit=0,int pStep=10)
{
  MqlTradeRequest request;
  MqlTradeResult result;
  if(myposition.SelectByTicket(pticket)&& pTrailPoints > 0)
	{
		double currentTakeProfit=myposition.TakeProfit();         
      long posType = myposition.PositionType();
		double currentStop = myposition.StopLoss();
		double openPrice = myposition.PriceOpen();
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
if(myposition.SelectByMagic(Symbol(),Magic_Number)==true)
return(myposition.PositionType()== POSITION_TYPE_BUY||myposition.PositionType()== POSITION_TYPE_SELL);
else return(false);
}
//------------------------------------------------------------------------
void CloseALL()
{

   for (int i=PositionsTotal()-1;i>=0; i--) 
   { 
   if(myposition.SelectByIndex(i)&& myposition.Magic()==Magic_Number||myposition.Magic()==0){
         if(!mytrade.PositionClose(PositionGetTicket(i))) 
         {
            Print(PositionGetTicket(i), "PositionClose() method failed. Return code=",mytrade.ResultRetcode(),
            ". Code description: ",mytrade.ResultRetcodeDescription());
         }
         else
         {
            Print(PositionGetTicket(i), "PositionClose() method executed successfully. Return code=",mytrade.ResultRetcode(),
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
   myorder.Select(o_ticket);
   if(myorder.Magic()==Magic_Number&&myorder.Symbol()==mysymbol.Name()) mytrade.OrderDelete(o_ticket);
   }
}
}

void DeleteAbertas(double distancia)
{
int o_total=OrdersTotal();
for(int j=o_total-1; j>=0; j--)
{
   ulong o_ticket = OrderGetTicket(j);
   if(o_ticket != 0)
   {
    myorder.Select(o_ticket);
    if (myorder.Magic()==Magic_Number&&myorder.Symbol()==mysymbol.Name()&&MathAbs(myorder.PriceOpen()-mysymbol.Ask())>distancia*ponto)
  // if (myorder.Type()==ORDER_TYPE_BUY_LIMIT||myorder.Type()==ORDER_TYPE_SELL_LIMIT)
    mytrade.OrderDelete(o_ticket);
   }
}
}

//------------------------------------------------------------------------
//------------------------------------------------------------------------
int Expiration(int barras)
{
return(TimeTradeServer()+barras*PeriodSeconds(periodoRobo));
}

//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
void OpenBuyStop(int barras,double distancia,double lotes,double stoploss,double takeprofit)
{
 double oldprice=0.0;
 double bprice =NormalizeDouble(HighestHigh(Symbol(),periodoRobo,barras,1) + distancia*ponto,digits);
 oldprice=PriceLastStopOrder(ORDER_TYPE_BUY_STOP);
if(oldprice==-1 || bprice<oldprice) // No order or New price is better
{
DeleteOrders(ORDER_TYPE_BUY_STOP);  
 double mprice=NormalizeDouble(bprice,_Digits); 
 double stloss = NormalizeDouble(bprice - stoploss*ponto,_Digits);
 double tprofit = NormalizeDouble(bprice+ takeprofit*ponto,_Digits);
if (bprice>mysymbol.Ask()) 
{
if(mytrade.BuyStop(lotes,mprice,_Symbol,stloss,tprofit,0,0,"Open Buy Stop"))
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
else mytrade.Buy(lotes,NULL,0,stloss,tprofit,"Open Buy");
}
}

//-------------------------------------------------------------------------------
//-------------------------------------------------------------------------------
void OpenSellStop(int barras,double distancia,double lotes,double stoploss,double takeprofit)
{


double bprice =NormalizeDouble(LowestLow(Symbol(),periodoRobo,barras,1)- distancia*ponto,digits);
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
 if(mytrade.SellStop(lotes,mprice,_Symbol,stloss,tprofit,0,0,"Open Sell Stop"))
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
else mytrade.Sell(lotes,NULL,0,stloss,tprofit,"Open Sell");
}
}
//-------------------------------------------------------------------------------------
//-------------------------------------------------------------------------------------
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

bool Dunn_Compra(ENUM_TIMEFRAMES dperiod)
{
MqlRates mrate[3];         
ArraySetAsSeries(mrate,true);
if (CopyRates(_Symbol,dperiod,0,3,mrate)<0)
     {
      Alert("Error copying rates/history data in Dunn_Compra Function - error:",GetLastError(),"!!");
      return(false);
     }

if (mrate[2].low<mrate[1].low && mrate[1].low<mrate[0].low && mrate[2].high<mrate[1].high && mrate[1].low<mrate[0].high)return(true);
else return(false);

}

bool Dunn_Venda(ENUM_TIMEFRAMES dperiod)
{
MqlRates mrate[3];         
ArraySetAsSeries(mrate,true);
if (CopyRates(_Symbol,dperiod,0,3,mrate)<0)
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
double currentProfit,currentStop,preco,novostop;

for (int i=PositionsTotal()-1;i>=0; i--) 
{ 
if(myposition.SelectByIndex(i)&& myposition.Magic()==Magic_Number)
{
currentStop=myposition.StopLoss();
preco=myposition.PriceOpen();
if (myposition.PositionType()==POSITION_TYPE_BUY&& myposition.Volume()>=Lot)
{
currentProfit = bid - preco;
if(currentProfit>=DistanceRealizeParcial*_Point)
{
  Print("Venda Saída Parcial : ");
  mytrade.PositionClosePartial(myposition.Ticket(),myposition.Volume()-LotesParcial,deviation_points);
 novostop=NormalizeDouble(preco-(DistanceRealizeParcial-15)*_Point,digits);
 if (novostop>currentStop)mytrade.PositionModify(myposition.Ticket(),novostop,myposition.TakeProfit());
}                
}                           

if(myposition.PositionType()==POSITION_TYPE_SELL && myposition.Volume()>=Lot)
{
currentProfit = preco-ask;

if(currentProfit>=DistanceRealizeParcial*_Point)
{
  Print("Compra Saída Parcial : ");
  mytrade.PositionClosePartial(myposition.Ticket(),myposition.Volume()-LotesParcial,deviation_points);    
 novostop=NormalizeDouble(preco+(DistanceRealizeParcial-15)*_Point,digits);
 if (novostop<currentStop)mytrade.PositionModify(myposition.Ticket(),novostop,myposition.TakeProfit());
}                
}                           
}//Fim myposition Select
}//Fim for
}

void ConjuntoOrdens(int n, double comprimento,ENUM_POSITION_TYPE side)
{

if (side==POSITION_TYPE_BUY)
{
if (_Stop>0)StopLoss=NormalizeDouble(mysymbol.Bid()-_Stop*ponto,digits);
else StopLoss=0;
       
if (_TakeProfit>0)TakeProfit=NormalizeDouble(mysymbol.Ask()+_TakeProfit*ponto,digits);
else TakeProfit=0;
mytrade.Buy(Lot,NULL,0,StopLoss,TakeProfit,"COMPRA");
double hedge_stop=NormalizeDouble(mysymbol.Ask()+DistanceRealizeParcial*ponto,digits);
double hedge_take=NormalizeDouble(mysymbol.Bid()-MathRound((1.5*comprimento)/ticksize)*ticksize*ponto,digits);
//mytrade.SellStop(2*LotesParcial,NormalizeDouble(mysymbol.Bid()-MathRound((0.75*comprimento)/ticksize)*ticksize*ponto,digits),NULL,hedge_stop,0,0,0,"Sell Hedge");
//mytrade.SellLimit(LotesParcial,ask,NULL,hedge_stop,NormalizeDouble(bid-MathRound((0.5*comprimento)/ticksize)*ticksize*ponto,digits),0,0,"Sell Hedge");
          
for (int i=1;i<n;i++) mytrade.BuyLimit(Lot,NormalizeDouble(mysymbol.Bid()-MathRound((i*comprimento/ n)/ticksize)*ticksize*ponto,digits),NULL,StopLoss,TakeProfit,0,0,"Buy Limit");
//mytrade.SellStop(2*Lot,NormalizeDouble(bid-comprimento*ponto,digits),NULL,hedge_stop,0,0,0,"Sell Hedge");


}

if (side==POSITION_TYPE_SELL)

{
if (_Stop>0)StopLoss=NormalizeDouble(mysymbol.Ask()+_Stop*ponto,digits);
else StopLoss=0;
if (_TakeProfit>0)TakeProfit=NormalizeDouble(mysymbol.Bid()-_TakeProfit*ponto,digits);
else TakeProfit=0;
mytrade.Sell(Lot,NULL,0,StopLoss,TakeProfit,"VENDA");
double hedge_stop=NormalizeDouble(mysymbol.Bid()-DistanceRealizeParcial*ponto,digits);
double hedge_take=NormalizeDouble(mysymbol.Ask()+MathRound((1.5*comprimento)/ticksize)*ticksize*ponto,digits);

//mytrade.BuyStop(2*LotesParcial,NormalizeDouble(mysymbol.Ask()+MathRound((0.75*comprimento)/ticksize)*ticksize*ponto,digits),NULL,hedge_stop,0,0,0,"Buy Hedge");
//mytrade.BuyLimit(LotesParcial,bid,NULL,hedge_stop,NormalizeDouble(ask+MathRound((0.5*comprimento)/ticksize)*ticksize*ponto,digits),0,0,"Buy Hedge");

for (int i=1;i<n;i++)mytrade.SellLimit(Lot,NormalizeDouble(mysymbol.Ask()+MathRound((i*comprimento/ n)/ticksize)*ticksize*ponto,digits),NULL,StopLoss,TakeProfit,0,0,"Sell Limit");
//mytrade.BuyStop(2*Lot,NormalizeDouble(ask+comprimento*ponto,digits),NULL,hedge_stop,0,0,0,"Buy Hedge");
          
}

}

void Reentrada()
{
double currentProfit,currentStop,currentTake,preco,novostop;
bool openbuy,opensell;
openbuy=Buy_opened();
opensell=Sell_opened();
for (int i=PositionsTotal()-1;i>=0; i--) 
{ 
if(myposition.SelectByIndex(i)&& myposition.Magic()==Magic_Number)
{
currentStop=myposition.StopLoss();
currentTake=myposition.TakeProfit();
preco=myposition.PriceOpen();
if (myposition.PositionType()==POSITION_TYPE_BUY)
{
currentProfit = bid - preco;

if(currentProfit>=2*brickrenco*_Point||currentProfit>=4*brickrenco*_Point||currentProfit>=6*brickrenco*_Point)
{
  Print("Reentrada Compra : ");
  //mytrade.PositionClose(myposition.Ticket(),deviation_points);
  mytrade.BuyLimit(LotesParcial,NormalizeDouble(bid-40*ponto,digits),NULL,currentStop,currentTake,0,0,"Reentrada Compra");
  mytrade.Buy(LotesParcial,NULL,0,currentStop,currentTake,"Reentrada Compra");
  
}                
}                           

if(myposition.PositionType()==POSITION_TYPE_SELL)
{
currentProfit = preco-ask;

if(currentProfit>=2*brickrenco*_Point||currentProfit>=4*brickrenco*_Point||currentProfit>=6*brickrenco*_Point)

{
  Print("Reentrada Venda : ");
 // mytrade.PositionClose(myposition.Ticket(),deviation_points);
  mytrade.SellLimit(LotesParcial,NormalizeDouble(ask+40*ponto,digits),NULL,currentStop,currentTake,0,0,"Reentrada Venda");
  mytrade.Sell(LotesParcial,NULL,0,currentStop,currentTake,"Reentrada Compra");
  
}                
}                           
}//Fim myposition Select
}//Fim for

}


void AtualizaStopSaida(ENUM_POSITION_TYPE Side)
{
double novoTake,novostop;
double ajuste=MathRound(0.5*brickrenco/ticksize)*ticksize;
Print("$$$$$$$$$ Ajuste $$$$$$$", ajuste," POSITIONS TOTAL ",PositionsTotal());
for (int i=PositionsTotal()-1;i>=0; i--) 
{ 
if(myposition.SelectByIndex(i)&& myposition.Magic()==Magic_Number&&myposition.PositionType()==Side)
{
Print("ENTROU SELECAO AJUSTE");
if (Side==POSITION_TYPE_BUY)
{
  novostop=NormalizeDouble(bid-ajuste*_Point,digits);
  novoTake=NormalizeDouble(ask+ajuste*_Point,digits);
  Print("ajuste ",ajuste,"stp ",novostop," tp ",novoTake);
  mytrade.PositionModify(myposition.Ticket(),novostop,novoTake);
                
}                           

if(Side==POSITION_TYPE_SELL)
{


  novostop=NormalizeDouble(ask+ajuste*_Point,digits);
  novoTake=NormalizeDouble(bid-ajuste*_Point,digits);
  Print("ajuste ",ajuste,"stp ",novostop," tp ",novoTake);  
  mytrade.PositionModify(myposition.Ticket(),novostop,novoTake);
}                           
}//Fim myposition Select
}//Fim for
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

//Break Even

void BreakEven(string pSymbol,bool usarbreak,int &pBreakEven[],int &pLockProfit[])
{
	for (int i=PositionsTotal()-1;i>=0; i--) 
{ 
   if(myposition.SelectByIndex(i)&& myposition.Magic()==Magic_Number&& usarbreak==true)
   {
	
	
		
		long posType = myposition.PositionType();
		double currentSL = myposition.StopLoss();
		double openPrice = myposition.PriceOpen();
		double currentTP=myposition.TakeProfit();
		double breakEvenStop;
		double currentProfit;
		double ponto=SymbolInfoDouble(pSymbol,SYMBOL_POINT);
		double bid,ask;
		
			if(posType == POSITION_TYPE_BUY)
			{
				bid = SymbolInfoDouble(pSymbol,SYMBOL_BID);
				currentProfit = bid - openPrice;
				//Break Even 0
				if (currentProfit>=pBreakEven[0]* ponto && currentProfit<pBreakEven[1]*ponto)
				{
				breakEvenStop = openPrice + pLockProfit[0] * ponto;
				if(currentSL < breakEvenStop || currentSL == 0)
				{
				Print("Break even stop:");
				mytrade.PositionModify(myposition.Ticket(),breakEvenStop,currentTP);
				}
				}
				//----------------------
				//Break Even 1
				else if (currentProfit>=pBreakEven[1]* ponto)
				{
				breakEvenStop = openPrice + pLockProfit[1] * ponto;
				if(currentSL < breakEvenStop || currentSL == 0)
				{
				Print("Break even stop:");
				mytrade.PositionModify(myposition.Ticket(),breakEvenStop,currentTP);
				}
				}
			}	
				//----------------------
    
				//----------------------
                    				
				
				
			else if(posType == POSITION_TYPE_SELL)
			{
				ask = SymbolInfoDouble(pSymbol,SYMBOL_ASK);
				currentProfit = openPrice - ask;
				//Break Even 0
				if (currentProfit>=pBreakEven[0]* ponto && currentProfit<pBreakEven[1]*ponto)
				{
				breakEvenStop = openPrice - pLockProfit[0] * ponto;
				if(currentSL > breakEvenStop || currentSL == 0)
				{
				Print("Break even stop:");
				mytrade.PositionModify(Symbol(),breakEvenStop,currentTP);
				}
				}
				//----------------------
				//Break Even 1
				else if (currentProfit>=pBreakEven[1]* ponto)
				{
				breakEvenStop = openPrice - pLockProfit[1] * ponto;
				if(currentSL > breakEvenStop || currentSL == 0)
				{
				Print("Break even stop:");
				mytrade.PositionModify(Symbol(),breakEvenStop,currentTP);
				}
				
				}
				//----------------------
            
			}
		
	}	//Fim Position Select
		
	}//Fim for
	}


//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=mysymbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }



double LucroOrdens()
  {
//--- request trade history 
datetime tm_end=TimeCurrent();
MqlDateTime stm_end,time_aux;
TimeToStruct(tm_end,stm_end);
time_aux=stm_end;
time_aux.hour=0;
time_aux.min=0;
time_aux.sec=0;
datetime tm_start=StructToTime(time_aux);
HistorySelect(tm_start,tm_end);
uint total_deals=HistoryDealsTotal();
ulong ticket=0;
double profit=0;
for(int i=0;i<total_deals;i++) // returns the number of current orders
    {
    ticket=HistoryDealGetTicket(i);
    mydeal.Ticket(ticket);
    if(ticket>0) 
    if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number&&mydeal.Entry()==DEAL_ENTRY_OUT)
    profit+=mydeal.Profit();
    }
return(profit); 
 } 
 
 
double LucroTotal()
{
double profit=0;
for (int i=PositionsTotal()-1;i>=0; i--) 
if(myposition.SelectByIndex(i)&& myposition.Magic()==Magic_Number&&myposition.Symbol()==mysymbol.Name())
profit+=myposition.Profit();
return profit;
} 
  
long LastDealTicket()
{
ulong ticket;
HistorySelect(time_inicio,time_novodia);
for(int i=HistoryDealsTotal();i>=0;i--)
{ 
   ticket=HistoryDealGetTicket(i);
    mydeal.Ticket(ticket);
    if(ticket>0) 
    if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number)
    return(mydeal.Ticket());         
 }
return(0);
}
  
  
double LastDealPrice()
{
HistorySelect(time_inicio,time_novodia);
ulong ticket=0;
for(int i=HistoryDealsTotal();i>=0;i--) // returns the number of current orders
    {
    ticket=HistoryDealGetTicket(i);
    mydeal.Ticket(ticket);
    if(ticket>0) 
    if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number)
    return(mydeal.Price());         
    }
return(0);
}
