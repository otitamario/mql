//+------------------------------------------------------------------+
//|                                                     Junio_v3.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "3.00"
enum ENUM_RENKO_TYPE
  {
   RENKO_TYPE_TICKS, //Ticks
   RENKO_TYPE_PIPS, //Pips
   RENKO_TYPE_POINTS //Points
  };



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
CiMA *mastop;


// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_H1;
input ulong Magic_Number =180218;
input ulong deviation_points=0;//Deviation in Points
input double Lot = 1;//Lotes
sinput string Lucro="Lucro para fechamento";
input bool UsarLucro=true;
input double lucro=3000.0;
input double prejuizo=500.0;
input bool UsarRealizParc=false;//Usar Realização Parcial
input double DistanceRealizeParcial = 90;
input double LotesParcial = 0;
input bool UseTimer = true;
input int StartHour = 9;
input int StartMinute = 5;
input int EndHour = 17;
input int EndMinute = 30;
input bool Daytrade=true;// Fechar posicoes Daytrade fim do dia
input double _Stop=300;//Stop Loss
input double _TakeProfit=2000; //Take Profit
input bool UseBreakEven=false;//Usar BreakEven
input int BreakEvenPoint1=200;//Pontos para BreakEven 1
input int ProfitPoint1=130;//Pontos de Lucro da Posicao 1
input int BreakEvenPoint2=400;//Pontos para BreakEven 2
input int ProfitPoint2=250;//Pontos de Lucro da Posicao 2
input bool   Use_TraillingStop =false;
input int TraillingStart = 0;//Lucro minimo Inicio do trailing stop
input int TraillingDistance=250;// Distancia do STOP movel para o preço
input int TraillingStep=20;// Passo para atualizar STOP movel
input bool UseSTOPMEDIA=false;//Usar Stop na media movel
input double DistSTOPMedia=100;//Distancia para media do stop movel
input bool StopCandle=true;//Usar Stop Candle
input double DistSTOPCandle=60;//Distancia para Candle Anterior
input ENUM_RENKO_TYPE RenkoType = RENKO_TYPE_POINTS; //Renko Type
input double RenkoSize = 90; //Renko Size (Ticks, Pips or Points)
input bool RenkoWicks = true; //Show Wicks
input int RenkoHistory = 10080; //Bars History (0 = full history)
// There are 10080 minutes in one week
input int HMA_Period=13;  // Moving average period
input int HMA_Shift=0;    // Horizontal shift of the average in bars


double ask,bid;
double ma_compra[],ma_venda[];
bool work_time;
int BreakEvenPoint[2],ProfitPoint[2];
double lucro_total,profit,saldo_inicial;
bool tradeOn;
double StopLoss,TakeProfit;
double preco,ponto,ticksize,digits,lotes_trade,stop_movel;
long posicao;
double high[],low[],open[],close[];
long curChartID,newChartID,secChartID;
double price_open;
long num_tick_anterior=0;
long num_tick_atual=0;
datetime time_inicio,time_novodia;
MqlDateTime inicio_struct;
ulong BuyTicket=0,SellTicket=0,Hedge_Buy_Ticket=0,Hedge_Sell_Ticket=0;
double stop_compra,stop_venda;
double stop_ordem_buy,take_ordem_buy,stop_ordem_sell,take_ordem_sell,preco_compra,preco_venda;
int renko_handle,hma_handle;
double renko_open[],renko_close[],renko_low[],renko_high[],hma_buffer[],hma_color[];
double renko_anterior,renko_atual,hma_anterior,hma_atual,hma_slope;
double low_anterior,low_atual,high_anterior,high_atual;
double cor_anterior,cor_atual;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
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
   renko_handle=iCustom(Symbol(),_Period,"renko2",RenkoType,RenkoSize,RenkoWicks,RenkoHistory);
   hma_handle=iCustom(Symbol(),_Period,"colorhma",HMA_Period,HMA_Shift,renko_handle);
   
  mastop=new CiMA;
  mastop.Create(NULL,periodoRobo,10,0,MODE_EMA,renko_handle);
  
  renko_anterior=EMPTY_VALUE;
  hma_anterior=EMPTY_VALUE;
  low_anterior=EMPTY_VALUE;
  high_anterior=EMPTY_VALUE;
  cor_anterior=EMPTY_VALUE;
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
   ArraySetAsSeries(ma_compra,true);
   ArraySetAsSeries(ma_venda,true);   
   ArraySetAsSeries(renko_open,true);   
   ArraySetAsSeries(renko_close,true);
   ArraySetAsSeries(renko_low,true);
   ArraySetAsSeries(renko_high,true);
   ArraySetAsSeries(hma_buffer,true);
   ArraySetAsSeries(hma_color,true);
  curChartID = ChartID();
  ChartSetInteger(curChartID,CHART_MODE,CHART_LINE);
  ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
  ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
 ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);
  ChartIndicatorAdd(curChartID,0,renko_handle);
  ChartIndicatorAdd(curChartID,0,hma_handle);

   mastop.AddToChart(curChartID,0);
 
  // newChartID=ChartOpen(Symbol(),PERIOD_H1);
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
  delete(mastop);
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
mastop.Refresh();

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
lucro_total=myaccount.Equity()-saldo_inicial;

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
renko_atual=renko_open[0];
hma_atual=hma_buffer[0];
cor_atual=hma_color[0];
if (hma_anterior==EMPTY_VALUE)hma_slope=EMPTY_VALUE;
else hma_slope=hma_atual-hma_anterior;
if (renko_atual!=renko_anterior && renko_anterior!=EMPTY_VALUE)
{
bool buy_renko=hma_slope!=EMPTY_VALUE&&hma_slope>0&&cor_atual==1&&cor_anterior==2;
bool sell_renko=hma_slope!=EMPTY_VALUE&&hma_slope<0&&cor_atual==2&&cor_anterior==1;
if(buy_renko&&!Buy_opened())    // Open long position
     {
      DeleteOrders(ORDER_TYPE_BUY_STOP);
      DeleteOrders(ORDER_TYPE_SELL_STOP);
     
      if (Sell_opened())mytrade.PositionClose(Symbol(),deviation_points);
      lotes_trade=Lot;
     if (_Stop>0) StopLoss=NormalizeDouble(bid-_Stop*ponto,digits);
     else StopLoss=0;
     if (_TakeProfit>0)TakeProfit=NormalizeDouble(ask+_TakeProfit*ponto,digits);
     else TakeProfit=0;
     mytrade.Buy(lotes_trade,NULL,0,StopLoss,TakeProfit,"Sinal COMPRA");
    // mytrade.BuyStop(lotes_trade,NormalizeDouble(fractalUP_Buffer[1]+30*ponto,digits),NULL,StopLoss,TakeProfit,0,0,"Sinal COMPRA");
    
     BuyTicket=mytrade.ResultOrder();


      }// End By Condition 
   
       
 
 //------------------------------------------------------------------
      
   if(sell_renko&& !Sell_opened())   // Open short position
     { 
       DeleteOrders(ORDER_TYPE_BUY_STOP);
       DeleteOrders(ORDER_TYPE_SELL_STOP);
       if (Buy_opened())mytrade.PositionClose(Symbol(),deviation_points);
       lotes_trade=Lot;
       if (_Stop>0)StopLoss=NormalizeDouble(ask+_Stop*ponto,digits);
       else StopLoss=0;
       if (_TakeProfit>0)TakeProfit=NormalizeDouble(bid-_TakeProfit*ponto,digits);
       else TakeProfit=0;
       mytrade.Sell(lotes_trade,NULL,0,StopLoss,TakeProfit,"Sinal VENDA");
      //mytrade.SellStop(lotes_trade,NormalizeDouble(fractalDOWN_Buffer[1]-30*ponto,digits),NULL,StopLoss,TakeProfit,0,0,"Sinal VENDA");
 
       SellTicket=mytrade.ResultOrder();           
      }// End Sell COndition
      //------------------------------------------------------------------
}//Fim NewBar
renko_anterior=renko_atual;
hma_anterior=hma_atual;
cor_anterior=cor_atual;
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
//Realizacao Parcial
if (UsarRealizParc)RealizacaoParcial();

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
if (UseBreakEven)
{
if(Buy_opened())BreakEven(Symbol(),UseBreakEven,myposition.Ticket(),BreakEvenPoint,ProfitPoint);
if(Sell_opened())BreakEven(Symbol(),UseBreakEven,myposition.Ticket(),BreakEvenPoint,ProfitPoint);

}
if(UseSTOPMEDIA)
{
stop_movel=NormalizeDouble(DistSTOPMedia*ponto,digits);
if (Buy_opened())
{
double curSTP=myposition.StopLoss();
double curTake=myposition.TakeProfit();
double stop_med=NormalizeDouble(MathRound(mastop.Main(0)/ticksize)*ticksize,digits);
double stp_compra=stop_med-stop_movel;
if (bid>mastop.Main(0)&&stp_compra>curSTP)mytrade.PositionModify(Symbol(),stp_compra,curTake);

}




if (Sell_opened())
{
double curSTP=myposition.StopLoss();
double curTake=myposition.TakeProfit();
double stop_med=NormalizeDouble(MathRound(mastop.Main(0)/ticksize)*ticksize,digits);
double stp_venda=stop_med+stop_movel;
if (ask<mastop.Main(0)&&stp_venda<curSTP)mytrade.PositionModify(Symbol(),stp_venda,curTake);

}

}

low_atual=renko_open[0];
high_atual=renko_open[0];
if(StopCandle)
{
stop_movel=NormalizeDouble(DistSTOPCandle*ponto,digits);
if (Buy_opened())
{
double curSTP=myposition.StopLoss();
double curTake=myposition.TakeProfit();
double stp_compra=low_anterior!=EMPTY_VALUE&&low_anterior!=low_atual?low_anterior-stop_movel:LowestLow(Symbol(),periodoRobo,1,1)-stop_movel;
if (bid>mastop.Main(0)&&stp_compra>curSTP)mytrade.PositionModify(Symbol(),stp_compra,curTake);

}




if (Sell_opened())
{
double curSTP=myposition.StopLoss();
double curTake=myposition.TakeProfit();
double stp_venda=high_anterior!=EMPTY_VALUE&&high_anterior!=high_atual?high_anterior+stop_movel:HighestHigh(Symbol(),periodoRobo,1,1)+stop_movel;
if (ask<mastop.Main(0)&&stp_venda<curSTP)mytrade.PositionModify(Symbol(),stp_venda,curTake);

}

}
low_anterior=low_atual;
high_anterior=high_atual;


 
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

//------------------------------------------------------------------------
//------------------------------------------------------------------------


//+-------------ROTINAS----------------------------------------------+


bool Buy_opened()
{
if(myposition.SelectByMagic(Symbol(),Magic_Number)==true && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY)
        {
         return(true);  //It is a Buy
        }
      else return(false); 
}

bool Sell_opened()
{
if(myposition.SelectByMagic(Symbol(),Magic_Number)==true && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL)
        {
         return(true);  //It is a Sell
        }
      else return(false); 
}




//+------------------------------------------------------------------+


bool BuySignal()
  {
  bool b_signal,buy_1,buy_2,buy_3,buy_4;
   
  return b_signal;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
  bool s_signal,sell_1,sell_2,sell_3,sell_4;
  return s_signal;
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
   b_get=CopyBuffer(renko_handle,0,0,10,renko_open)<=0||
   CopyBuffer(renko_handle,1,0,10,renko_high)<=0||
   CopyBuffer(renko_handle,2,0,10,renko_low)<=0||
   CopyBuffer(renko_handle,3,0,10,renko_close)<=0||
   CopyBuffer(hma_handle,0,0,10,hma_buffer)<=0||
   CopyBuffer(hma_handle,1,0,10,hma_color)<=0||
   CopyHigh(Symbol(),periodoRobo,0,5,high)<=0||
   CopyOpen(Symbol(),periodoRobo,0,5,open)<=0||
   CopyLow(Symbol(),periodoRobo,0,5,low)<=0||
   CopyClose(Symbol(),periodoRobo,0,5,close)<=0;
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
    // delete the pending Sell Stop order
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
double currentProfit;

if (myposition.SelectByMagic(Symbol(),Magic_Number))
{
if(myposition.PositionType()==POSITION_TYPE_BUY && myposition.Volume()==Lot)
{
currentProfit = bid - myposition.PriceOpen();
if(currentProfit>=DistanceRealizeParcial*_Point)
{
  Print("Venda Saída Parcial : ");
  mytrade.PositionClosePartial(myposition.Ticket(),LotesParcial,deviation_points);
}                
}                           

if(myposition.PositionType()==POSITION_TYPE_SELL && myposition.Volume()==Lot)
{
currentProfit = myposition.PriceOpen()-ask;

if(currentProfit>=DistanceRealizeParcial*_Point)
{
  Print("Compra Saída Parcial : ");
  mytrade.PositionClosePartial(myposition.Ticket(),LotesParcial,deviation_points);    
}                
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

//Break Even

void BreakEven(string pSymbol,bool usarbreak,ulong pticket,int &pBreakEven[],int &pLockProfit[])
{
	if(myposition.SelectByTicket(pticket) && usarbreak==true)
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
				mytrade.PositionModify(Symbol(),breakEvenStop,currentTP);
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
				mytrade.PositionModify(Symbol(),breakEvenStop,currentTP);
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
		
		
		
	}
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
HistorySelect(time_inicio,time_novodia);
uint total_deals=HistoryDealsTotal();
ulong ticket=0;
double profit=0;
for(int i=0;i<total_deals;i++) // returns the number of current orders
    {
    ticket=HistoryDealGetTicket(i);
    mydeal.Ticket(ticket);
    if(ticket>0) 
    if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number)
    profit+=mydeal.Profit();
    }
return(profit); 
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
