//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
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

//BOM RESULTADO EM TREND; - DOL E IND
//+------------------------------------------------------------------+
//|                              INCLUDES                            +                                 
//+------------------------------------------------------------------+ 
#include <Expert\Expert.mqh>
#include <Expert\Signal\SignalMA.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\Trade.mqh>
#include <Indicators\Oscilators.mqh>
#include <Expert\Signal\SignalStoch.mqh>
//+------------------------------------------------------------------+ 
//+------------------------------------------------------------------+ 

CiStochastic   stochastic;
CSymbolInfo   _symbol;
CTrade        t;
CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;

//+------------------------------------------------------------------+ 
input ENUM_TIMEFRAMES  time_frame=PERIOD_M1;
input string Simbolo="";//Símbolo Original para Ordens - "" Vazio= Simbolo do Gráfico
input ulong Magic_Number=1;//Número Mágico

input   PRICE_TYPE  Price_Type          = CLOSE;
input   bool        Calc_Every_Tick     = false;
input   bool        Enable_Daily        = true;
input   bool        Show_Daily_Value    = true;
input   bool        Enable_Weekly       = false;
input   bool        Show_Weekly_Value   = false;
input   bool        Enable_Monthly      = false;
input   bool        Show_Monthly_Value  = false;

//+------------------------------------------------------------------+ 
//+------------------------------------------------------------------+
//|                  HFT - BUY AND SELL ORDER                        +                                
//+------------------------------------------------------------------+ 
string original_symbol;
double lucro_total;
int handle_vwap;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Buy(double volume)
  {
   MqlTradeRequest req={0};
   req.action      =TRADE_ACTION_DEAL;
   req.symbol      =original_symbol;
   req.volume      =1;
   req.price       =SymbolInfoDouble(req.symbol,SYMBOL_ASK);
   req.sl          = NULL;
   req.tp          = NULL;
   req.deviation   =0;
   req.type        =ORDER_TYPE_BUY;
   req.magic=Magic_Number;
   MqlTradeResult  res={0};
   if(!OrderSend(req,res))
      PrintFormat("OrderSend error %d",GetLastError());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Sell(double volume)
  {
   MqlTradeRequest req={0};
   req.action      =TRADE_ACTION_DEAL;
   req.symbol      =original_symbol;
   req.volume      =1;
   req.price       =SymbolInfoDouble(req.symbol,SYMBOL_BID);
   req.sl          = NULL;
   req.tp          = NULL;
   req.deviation   =0;
   req.type        =ORDER_TYPE_SELL;
   req.magic=Magic_Number;
   MqlTradeResult  res={0};
   if(!OrderSend(req,res))
      PrintFormat("OrderSend error %d",GetLastError());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(Simbolo=="")original_symbol=_Symbol;
   else original_symbol=Simbolo;
   _symbol.Name(original_symbol);
   mysymbol.Name(original_symbol);
   t.SetTypeFilling(ORDER_FILLING_RETURN);
   t.SetExpertMagicNumber(Magic_Number);

   handle_vwap=iCustom(_Symbol,PERIOD_CURRENT,"vwap_lite",Price_Type,Calc_Every_Tick,Enable_Daily,Show_Daily_Value,Enable_Weekly,Show_Weekly_Value,Enable_Monthly,Show_Monthly_Value);

   ChartIndicatorAdd(0,0,handle_vwap);

   return INIT_SUCCEEDED;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   double open,open1,open2,close,close1,close2,low,low1,low2,high,high1,high2;

   lucro_total=LucroOrdens()+LucroPositions();
   Comment("\n"+"\n"+"\n"+"Lucro Total: "+DoubleToString(lucro_total,2));

   open=iOpen(_Symbol,0,0);
   open1 = iOpen(_Symbol,0,1);
   open2 = iOpen(_Symbol,0,2);
   close = iClose(_Symbol,0,0);
   close1 = iClose(_Symbol,0,1);
   close2 = iClose(_Symbol,0,2);
   low=iLow(_Symbol,0,0);
   low1 = iLow(_Symbol,0,1);
   low2 = iLow(_Symbol,0,2);
   high=iHigh(_Symbol,0,0);
   high1 = iHigh(_Symbol,0,1);
   high2 = iHigh(_Symbol,0,2);

//ESTOCÁSTICO         
   string signal=" ";

   double K[];
   double D[];

   ArraySetAsSeries(K,true);
   ArraySetAsSeries(D,true);

   int StochasticDefinition=iStochastic(_Symbol,PERIOD_H1,18,9,3,MODE_SMA,STO_LOWHIGH);

   CopyBuffer(StochasticDefinition,0,0,3,K);
   CopyBuffer(StochasticDefinition,1,0,3,D);

   double K0=K[0];
   double D0=D[0];

   double K1=K[1];
   double D1=D[1];

   double K2=K[2];
   double D2=D[2];

   double m1[],m2[],m3[];

//MÉDIAS
   int definem1 = iMA(_Symbol, _Period,9,0, MODE_SMA, PRICE_CLOSE);
   int definem2 = iMA(_Symbol, _Period,20,0, MODE_EMA, PRICE_CLOSE);
   int definem3 = iMA(_Symbol, _Period,3,0, MODE_EMA, PRICE_CLOSE);

   ArraySetAsSeries(m1,true);
   ArraySetAsSeries(m2,true);
   ArraySetAsSeries(m3,true);

   CopyBuffer(definem1,0,0,3,m1);
   CopyBuffer(definem2,0,0,3,m2);
   CopyBuffer(definem3,0,0,3,m3);

//COMPRA  
   if(!PosicaoAberta()
      && close1>open1
      && (K2<20 || K2>80) //inócuo  
      )
     {
      t.Buy(1,original_symbol);
     }
//STOPA 
   if(Sell_opened()
      && close1>open1 && (K1<10 || K1>50)
      )
     {
      t.PositionClose(original_symbol);
      t.Buy(1,original_symbol);
     }

/*/VENDA  
   if(!PosicaoAberta()
      // && (K1<D1 && K2>D2|| K1 == 0 //piora o resultado
      && close1<open1 && (K1>45 || K1<25)

      )

     {
      t.Sell(1,original_symbol);
     }

//STOPA
   if(Buy_opened()
      && close1<open1 && (K1>45 || K1<25)
      )
     {
     t.PositionClose(original_symbol);
      t.Sell(1,original_symbol);
     
     }*/
  }
//+------------------------------------------------------------------+
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
   for(uint i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LucroPositions()
  {
   double profit=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
         profit+=myposition.Profit();
   return profit;
  }
//+------------------------------------------------------------------+
bool Buy_opened()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_BUY)
         return(true);  //It is a Buy
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Sell_opened()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_SELL)
         return(true);  //It is a Buy
     }
   return(false);
  }
//+------------------------------------------------------------------+
bool PosicaoAberta()
  {
   if(myposition.SelectByMagic(original_symbol,Magic_Number)==true)
      return(myposition.PositionType()== POSITION_TYPE_BUY||myposition.PositionType()== POSITION_TYPE_SELL);
   else return(false);
  }
//+------------------------------------------------------------------+
