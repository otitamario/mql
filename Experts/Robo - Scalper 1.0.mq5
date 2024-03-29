//+------------------------------------------------------------------+
//|                                           Robo - Scalper FMS.mq5 |
//|                                         Felipe Miguel dos Santos |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Felipe Miguel dos Santos"
#property link      "https://www.mql5.com"
#property version   "1.00"
   
 
   
//Inclusão de bibliotecas
#include <Trade\Trade.mqh>
#include <Trade\AccountInfo.mqh>
#include <Trade\OrderInfo.mqh>
#include <Trade\PositionInfo.mqh>
#include <Trade\SymbolInfo.mqh>
#include <Trade\\Trade.mqh>
#include <Price.mqh>

CAccountInfo   conta_info;    //CAccountInfo classe fornece acesso fácil às propriedades da conta de negociação atualmente abertas.
COrderInfo     ordem_info;    //A classe COrderInfo fornece acesso às propriedades das ordens pendente.
CPositionInfo  posicao_info;  //A clase CPositionInfo possibilita o fácil acesso às propriedades de abertura de posição.
CTrade Trade;
CPrice cprice;

double BuyBuffer[];
double SellBuffer[];
double MALentaBuffer[];
double MAMediaBuffer[];
double MARapidaBuffer[];
double IFRBuffer[];
double CCIBuffer[];
double MAColorBuffer[];

bool check;
bool compra;
bool venda;
bool lockVenda;
bool lockCompra;

int MAColor;
int HandleBrainTrendSig;
int RSI;
int CCI;
int MARapida;
int MAMedia;
int MALenta;
int HILOHigh;
int HILOLow;
double high;
double low;

//Inputs
input long order_magic = 55555;
input double StopLoss = 300;
input double TakeProfit = 10;
input double Lote = 1;

input string MS01 = "INDICADOR MÉDIA MÓVEL";
input int Periodo_MA_Lenta = 36;
input ENUM_MA_METHOD Metodo_MA_Lenta = MODE_EMA;

input int Periodo_MA_Rapida = 20;
input ENUM_MA_METHOD Metodo_MA_Rapida = MODE_SMMA;

input string MS02 = "INDICADOR ÍNDICE DE FORÇA RELATIVA";
input int Periodo_IFR = 14;






int OnInit()
  {
  
   HandleBrainTrendSig = iCustom(Symbol(), Period(), "braintrend1sig");
   MARapida  = iMA(Symbol(), Period(), Periodo_MA_Rapida, 0, Metodo_MA_Rapida, PRICE_CLOSE);
   MALenta   = iMA(Symbol(), Period(), Periodo_MA_Lenta, 0, Metodo_MA_Lenta, PRICE_CLOSE);

   check = false;
   compra = false;
   venda = false;
   lockVenda = false;
   lockCompra = false;
   
   return(INIT_SUCCEEDED);
   
  }

void OnDeinit(const int reason){}


//Verificar os Buffers  
void checkCopyBuffers(int copyBufferSell, int copyBufferBuy, int copyBufferMA){
   
   if(copyBufferSell == INVALID_HANDLE)
     {
      Print("ERROR CopyBufferSell = ", GetLastError());
      return;
     }
   
   if(copyBufferBuy == INVALID_HANDLE)
     {
      Print("ERROR CopyBufferBuy = ", GetLastError());
      return;
     }
   if(copyBufferMA == INVALID_HANDLE)
     {
      Print("ERROR CopyBufferMA = ", GetLastError());
      return;
     }
  
   
   
}

void OnTick()
   {
   
     mensagemGrafico();
   
     ArraySetAsSeries(SellBuffer, true);
     ArraySetAsSeries(BuyBuffer, true);
     ArraySetAsSeries(MARapidaBuffer, true);
     ArraySetAsSeries(MALentaBuffer, true);
 
     

   //Buffer: 0 = Sell
   //Buffer: 1 = Buy
   
     //Copiando Buffers 
     int cb1 = CopyBuffer(HandleBrainTrendSig, 0, 0, 50, SellBuffer);
     int cb2 = CopyBuffer(HandleBrainTrendSig, 1, 0, 50, BuyBuffer);
     int cb7 = CopyBuffer(MARapida, 0, 0, 50,  MARapidaBuffer);
     int cb8 = CopyBuffer(MALenta, 0, 0, 50,  MALentaBuffer);
      
     checkCopyBuffers(cb1, cb2, cb7);   
     
  
     checkEntry();
     
    
      
     
    
   }

//Função de ordem de compra   
void order_buy(){

     bool buy_opened = false;
     bool sell_opened = false;             
     double SL = SymbolInfoDouble(_Symbol,SYMBOL_ASK) - StopLoss;
     double TP = SymbolInfoDouble(_Symbol,SYMBOL_ASK) + TakeProfit;  
     double open_price = SymbolInfoDouble(Symbol(), SYMBOL_ASK);   
     
     Trade.SetExpertMagicNumber(order_magic);
     Trade.SetTypeFilling(ORDER_FILLING_RETURN);
     
    
     
     if(getIsExistOrderBuyOpened() == false && getIsExistOrderSellOpened() == false)
       {
          if(!Trade.Buy(Lote, Symbol(), cprice.Ask(), SL, TP, "BUY"))
          {
           Print("Compra não sucedida. Erro: ", Trade.ResultRetcode(), " Descrição: ", Trade.ResultRetcodeDescription());
           return;
          
          }else
             {
               Print("Compra Sucedida! Ordem: ",Trade.ResultRetcode(),"\t", Trade.ResultRetcodeDescription());
               lockCompra = true;
             }
       }

}

//Função de ordem de venda   
void order_sell(){

     bool buy_opened = false;
     bool sell_opened = false;         
     double SL = SymbolInfoDouble(_Symbol,SYMBOL_BID) + StopLoss;
     double TP = SymbolInfoDouble(_Symbol,SYMBOL_BID) - TakeProfit;  
     double open_price = SymbolInfoDouble(_Symbol, SYMBOL_BID);   
     
     Trade.SetExpertMagicNumber(order_magic);
     Trade.SetTypeFilling(ORDER_FILLING_RETURN);
   
     
     if(getIsExistOrderBuyOpened() == false && getIsExistOrderSellOpened() == false)
       {
          if(!Trade.Sell(Lote, Symbol(), cprice.Bid(), SL, TP, "SELL"))
          {
           Print("Venda não sucedida. Erro: ", Trade.ResultRetcode(), " Descrição: ", Trade.ResultRetcodeDescription());
           return;
          
          }else
             {
               Print("Venda Sucedida! Ordem: ",Trade.ResultRetcode(),"\t", Trade.ResultRetcodeDescription());
               lockVenda = true;
               
             }
       }

}


bool getIsExistOrderSellOpened(){

    if(PositionSelect(Symbol()) == true)
       {
         if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL)
           {
            return(true);
           }
       }
   return(false);
}   

bool getIsExistOrderBuyOpened(){

    if(PositionSelect(Symbol()) == true)
       {
        if(PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY)
          {
           return(true);
          }
       }
    return(false);
}

void checkEntry(){


      if(lockVenda == false)
        {
         if(SellBuffer[1] > 0)
            {
               for(int i = PositionsTotal() - 1; i >= 0; i--)
                 {
                     ulong ticket = PositionGetTicket(i);
                    Trade.PositionClose(ticket);
                 }
             
               
               lockCompra = false;
               
              
                  if(cprice.Open(Period(), 0) < MARapidaBuffer[0])
                 {
                     order_sell();
                 } 
               
           
            } 
            
        }
         
         
      if(lockCompra == false)
         {
          if(BuyBuffer[1] > 0)
            {
               
              for(int i = PositionsTotal() - 1; i >= 0; i--)
                 {
                     ulong ticket = PositionGetTicket(i);
                     Trade.PositionClose(ticket);
                 } 
               
              lockVenda = false;
              
              
                  if(cprice.Open(Period(), 0) > MARapidaBuffer[0])
                 {
                     order_buy();      
                 }  
                
            }         
         
         }       
 
} 



// Receber o número das atuais ordens atuais com especificação   
int GetOrdersTotalByMagic(long const magic_number){

   ulong order_ticket;
   int total = 0;
   
   for(int i = 0; i < OrdersTotal(); i++)
     {
      if((order_ticket = OrderGetTicket(i)) > 0)
        {
         if(magic_number == OrderGetInteger(ORDER_MAGIC))
           {
            total++;
           }
        }
     }
   return(total);
}

void mensagemGrafico()
{
    string temp = "\n"
    + "------------------------------------------------\n"
    + "ACCOUNT INFORMATION:\n"
    + "\n"
    + "Account Name:     " + AccountInfoString(ACCOUNT_NAME) + "\n"
    + "Account Leverage:     " + IntegerToString(AccountInfoInteger(ACCOUNT_LEVERAGE)) + "\n"
    + "Account Balance:     " + DoubleToString(AccountInfoDouble(ACCOUNT_BALANCE), 2)+ "\n"
    + "Account Equity:     " + DoubleToString(AccountInfoDouble(ACCOUNT_EQUITY), 2)+ "\n"
    + "Free Margin:     " + DoubleToString(AccountInfoDouble(ACCOUNT_FREEMARGIN), 2)+ "\n"
    + "Used Margin:     " + DoubleToString(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL), 2)+ "\n"
    + "------------------------------------------------\n";
    Comment(temp);
  
}







