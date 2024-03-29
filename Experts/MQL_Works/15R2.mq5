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

//+------------------------------------------------------------------+ 
input ENUM_TIMEFRAMES  time_frame=PERIOD_M1; 
//+------------------------------------------------------------------+ 
//+------------------------------------------------------------------+
//|                  HFT - BUY AND SELL ORDER                        +                                
//+------------------------------------------------------------------+   
void Buy(double volume)   
   { 
   MqlTradeRequest req={0}; 
   req.action      =TRADE_ACTION_DEAL; 
   req.symbol      =_Symbol; 
   req.volume      =1;
   req.price       =SymbolInfoDouble(req.symbol,SYMBOL_ASK); 
   req.sl          = NULL;
   req.tp          = NULL;
   req.deviation   =0;
   req.type        =ORDER_TYPE_BUY;   
   MqlTradeResult  res={0};
   if(!OrderSend(req,res))
      PrintFormat("OrderSend error %d",GetLastError());  
   }  
void Sell(double volume)   
   {
   MqlTradeRequest req={0}; 
   req.action      =TRADE_ACTION_DEAL; 
   req.symbol      =_Symbol; 
   req.volume      =1;
   req.price       =SymbolInfoDouble(req.symbol,SYMBOL_ASK); 
   req.sl          = NULL;
   req.tp          = NULL;
   req.deviation   =0;
   req.type        =ORDER_TYPE_SELL; 
   MqlTradeResult  res={0};
   if(!OrderSend(req,res))
   PrintFormat("OrderSend error %d",GetLastError()); 
   }

void OnTick()
   {
   
double open,open1,open2,close, close1,close2, low, low1, low2, high, high1, high2;
  
         open = iOpen(_symbol.Name(),0,0);
         open1 = iOpen(_symbol.Name(),0,1);  
         open2 = iOpen(_symbol.Name(),0,2); 
         close = iClose(_symbol.Name(),0,0);
         close1 = iClose(_symbol.Name(),0,1); 
         close2 = iClose(_symbol.Name(),0,2);
         low = iLow(_symbol.Name(),0,0); 
         low1 = iLow(_symbol.Name(),0,1);          
         high = iHigh(_symbol.Name(),0,0); 
         high1 = iHigh(_symbol.Name(),0,1); 
         high2 = iHigh(_symbol.Name(),0,2); 
  
//ESTOCÁSTICO         
string signal=" "; 
 
double K[];
double D[];

ArraySetAsSeries(K, true);
ArraySetAsSeries(D, true);

int StochasticDefinition=iStochastic(_Symbol,_Period,14,3,3,MODE_SMA,STO_LOWHIGH);

CopyBuffer(StochasticDefinition,0,0,3,K);
CopyBuffer(StochasticDefinition,1,0,3,D);

double K0=K[0];
double D0=D[0];

double K1=K[1];
double D1=D[1];

double K2=K[2];
double D2=D[2];           
 
double m1[], m2[], m3[];

//MÉDIAS
int definem1 = iMA(_Symbol, _Period,9,0, MODE_SMA, PRICE_CLOSE); 
int definem2 = iMA(_Symbol, _Period,20,0, MODE_EMA, PRICE_CLOSE);  
int definem3 = iMA(_Symbol, _Period,3,0, MODE_EMA, PRICE_CLOSE);

ArraySetAsSeries(m1, true);
ArraySetAsSeries(m2, true);
ArraySetAsSeries(m3, true);

CopyBuffer(definem1,0,0,3,m1);
CopyBuffer(definem2,0,0,3,m2);
CopyBuffer(definem3,0,0,3,m3);

//COMPRA  
         if (PositionsTotal() ==0       
            && close1>open1            
            && (K1 <10 ||K1 >50 )   //inócuo  
         )     
         {
               t.Buy(1);  
         }
//STOPA 
         if (PositionSelect(_Symbol)==true 
            && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL            
            && close1>open1 && (K1 <10 ||K1 >50  ) 
         )
         {
              t.Buy(2);
         }
         
//VENDA  
         if (PositionsTotal() ==0
              // && (K1<D1 && K2>D2|| K1 == 0 //piora o resultado
               && close1<open1   &&( K1>45 || K1<25)    
                             
         )
           
         {
            t.Sell(1);        
         }              
         
//STOPA
         if( PositionSelect(_Symbol)==true 
             && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY          
             && close1<open1 && (K1>45 || K1<25)   
         )                  
         {
            t.Sell (2);
         }
}