//+------------------------------------------------------------------+
//|                                                        Utils.mqh |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#include <Mql5Book\Trade.mqh>
CTrade Trade;
class Utils
  {
private:
   MqlTick           precoRecente;    // To be used for gettinf recent/latest price quotes
   int               _NumeroMagico;   // Código do Expert Advisor.
protected:
		MqlTradeRequest request;
		

		
		
public: 
   /*Propriedades*/  
   MqlTradeResult result;                   
   bool SaidaParcial(string simbolo /*Simbolo */,
                     int tpOrdem /*Tipo de ordem*/,                     
                     double loteSaida /*Valor acima da entrada*/,
                     double valorSaida);
                     
     };


// Saida Parcial
bool Utils::SaidaParcial(string simbolo,int tpOrdem, double loteSaida,double valorSaida)
{
   //if(_Symbol != simbolo && clTrade.RequestMagic() != _NumeroMagico) return(false);
   if(_Symbol != simbolo) return(false);
   
      
   if(PositionSelect(simbolo))
   {
   
      double posisao_tp    = PositionGetDouble(POSITION_TP);
      double posisao_sl    = PositionGetDouble(POSITION_SL); 
      double precoEntrada  = NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN),_Digits);
      double qtdLoteAberto = PositionGetDouble(POSITION_VOLUME); // Tamanho da posição atual
      double ask=SymbolInfoDouble(simbolo,SYMBOL_ASK);
      double bid=SymbolInfoDouble(simbolo,SYMBOL_BID);
      if(tpOrdem == POSITION_TYPE_BUY)
      {    
           if ((bid >=  precoEntrada + valorSaida*_Point) && (loteSaida < qtdLoteAberto))
         {             Trade.Close(simbolo,loteSaida);
                       return(true);     
         }               
      }
      else if(tpOrdem == POSITION_TYPE_SELL)
      {
       if ((ask <=  precoEntrada - valorSaida*_Point) && (loteSaida < qtdLoteAberto))
         {                                 
             Trade.Close(simbolo,loteSaida);
             return(true);  
         }
      }
   }
   return(false);
}