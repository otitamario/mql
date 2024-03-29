input int MagicNumber=1234567;
 
//--- habilita a classe de negociação CTrade e declara a variável desta classe 
#include <Trade\Trade.mqh> 
CTrade trade; 
//--- flags para instalação e exclusão de ordens pendentes 
bool pending_done=false; 
bool pending_deleted=false; 
//--- bilhetagem da ordem pendente será armazenada aqui 
ulong order_ticket; 
//+------------------------------------------------------------------+ 
//| Função de inicialização do Expert                                | 
//+------------------------------------------------------------------+ 
int OnInit() 
  { 
//--- define o MagicNumber para marcar todas as nossas ordens 
   trade.SetExpertMagicNumber(MagicNumber); 
//--- solicitações de negociação serão enviadas em modo assíncrono usando a função OrderSendAsync() 
   trade.SetAsyncMode(true); 
//--- inicializa a variável em zero 
   order_ticket=0; 
//--- 
   return(INIT_SUCCEEDED); 
  } 
//+------------------------------------------------------------------+ 
//| Função tick (ponto) de um Expert                                 | 
//+------------------------------------------------------------------+ 
void OnTick() 
  { 
//---instalando uma ordem pendente 
   if(!pending_done) 
     { 
      double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK); 
      double buy_stop_price=NormalizeDouble(ask+1000*_Point,(int)SymbolInfoInteger(_Symbol,SYMBOL_DIGITS)); 
      bool res=trade.BuyStop(0.1,buy_stop_price,_Symbol); 
      //--- caso a função BuyStop() executou com sucesso 
      if(res) 
        { 
         pending_done=true; 
         //--- obtém um resultado da solicitação enviando para CTrade 
         MqlTradeResult trade_result; 
         trade.Result(trade_result); 
         //--- obtém o request_id para a solicitações enviada 
         uint request_id=trade_result.request_id; 
         Print("Pedido foi enviado para definir uma ordem pendente. Request_ID=",request_id); 
         //--- armazena a bilhetagem da ordem (será zero se usar o modo assíncrono de envio para CTrade) 
         order_ticket=trade_result.order; 
         //--- tudo está feito, saí cedo do handler OnTick() 
         return; 
        } 
     } 
//--- exclui a ordem pendente 
   if(!pending_deleted) 
      //--- verificação adicional 
      if(pending_done && (order_ticket!=0)) 
        { 
         //--- tenda excluir a ordem pendente 
         bool res=trade.OrderDelete(order_ticket); 
         Print("OrderDelete=",res); 
         //--- quando solicitação de exclusão é enviada com sucesso 
         if(res) 
           { 
            pending_deleted=true; 
            //--- obtém o resultado da execução da solicitação 
            MqlTradeResult trade_result; 
            trade.Result(trade_result); 
            //--- peque o ID da solicitação proveniente do resultado 
            uint request_id=trade_result.request_id; 
            //--- exibe no Diário 
            Print("O pedido foi enviado para eliminar uma ordem pendente #",order_ticket, 
                  ". Request_ID=",request_id, 
                  "\r\n"); 
            //--- fixa a bilhetagem da ordem proveniente do resultado da solicitação 
            order_ticket=trade_result.order; 
           } 
        } 
//---         
  } 
//+------------------------------------------------------------------+ 
//| Função TradeTransaction                                          | 
//+------------------------------------------------------------------+ 
void OnTradeTransaction(const MqlTradeTransaction &trans, 
                        const MqlTradeRequest &request, 
                        const MqlTradeResult &result) 
  { 
//--- obtém o tipo de transação como valor de enumeração 
   ENUM_TRADE_TRANSACTION_TYPE type=(ENUM_TRADE_TRANSACTION_TYPE)trans.type; 
//--- se a transação é a solicitação de manipulação do resultado, somente seu nome é exibido 
   if(type==TRADE_TRANSACTION_REQUEST) 
     { 
      Print(EnumToString(type)); 
      //--- exibe o a string do nome da solicitação manipulada 
      Print("------------RequestDescription\r\n",RequestDescription(request)); 
      //--- exibe a descrição do resultado da solicitação 
      Print("------------ResultDescription\r\n",TradeResultDescription(result)); 
      //--- armazena a bilhetagem da ordem para sua exclusão na próxima manipulação em OnTick() 
      if(result.order!=0) 
        { 
         //--- exclui esta ordem através de sua bilhetagem na próxima chamada de OnTick() 
         order_ticket=result.order; 
         Print(" Bilhetagem da ordem pendente ",order_ticket,"\r\n"); 
        } 
     } 
   else // exibe a descrição completa para transações de um outro tipo 
//--- exibe a descriçaõ da transação recebida no Diário 
      Print("------------TransactionDescription\r\n",TransactionDescription(trans));
 
//---      
  } 
//+------------------------------------------------------------------+ 
//| Retorna a descrição textual da transação                         | 
//+------------------------------------------------------------------+ 
string TransactionDescription(const MqlTradeTransaction &trans) 
  { 
//---  
   string desc=EnumToString(trans.type)+"\r\n"; 
   desc+="Ativo: "+trans.symbol+"\r\n"; 
   desc+="Bilhetagem (ticket) da operação: "+(string)trans.deal+"\r\n"; 
   desc+="Tipo de operação: "+EnumToString(trans.deal_type)+"\r\n"; 
   desc+="Bilhetagem (ticket) da ordem: "+(string)trans.order+"\r\n"; 
   desc+="Tipo de ordem: "+EnumToString(trans.order_type)+"\r\n"; 
   desc+="Estado da ordem: "+EnumToString(trans.order_state)+"\r\n"; 
   desc+="Ordem do tipo time: "+EnumToString(trans.time_type)+"\r\n"; 
   desc+="Expiração da ordem: "+TimeToString(trans.time_expiration)+"\r\n"; 
   desc+="Preço: "+StringFormat("%G",trans.price)+"\r\n"; 
   desc+="Gatilho do preço: "+StringFormat("%G",trans.price_trigger)+"\r\n"; 
   desc+="Stop Loss: "+StringFormat("%G",trans.price_sl)+"\r\n"; 
   desc+="Take Profit: "+StringFormat("%G",trans.price_tp)+"\r\n"; 
   desc+="Volume: "+StringFormat("%G",trans.volume)+"\r\n"; 
//--- retorna a string obtida 
   return desc; 
  } 
//+------------------------------------------------------------------+ 
//| Retorna a descrição textual da solicitação de negociação         | 
//+------------------------------------------------------------------+ 
string RequestDescription(const MqlTradeRequest &request) 
  { 
//--- 
   string desc=EnumToString(request.action)+"\r\n"; 
   desc+="Ativo: "+request.symbol+"\r\n"; 
   desc+="Número mágico: "+StringFormat("%d",request.magic)+"\r\n"; 
   desc+="Bilhetagem (ticket) da ordem: "+(string)request.order+"\r\n"; 
   desc+="Tipo de ordem: "+EnumToString(request.type)+"\r\n"; 
   desc+="Preenchimento da ordem: "+EnumToString(request.type_filling)+"\r\n"; 
   desc+="Ordem do tipo time: "+EnumToString(request.type_time)+"\r\n"; 
   desc+="Expiração da ordem: "+TimeToString(request.expiration)+"\r\n"; 
   desc+="Preço: "+StringFormat("%G",request.price)+"\r\n"; 
   desc+="Pontos de desvio: "+StringFormat("%G",request.deviation)+"\r\n"; 
   desc+="Stop Loss: "+StringFormat("%G",request.sl)+"\r\n"; 
   desc+="Take Profit: "+StringFormat("%G",request.tp)+"\r\n"; 
   desc+="Stop Limit: "+StringFormat("%G",request.stoplimit)+"\r\n"; 
   desc+="Volume: "+StringFormat("%G",request.volume)+"\r\n"; 
   desc+="Comentário: "+request.comment+"\r\n"; 
//--- retorna a string obtida 
   return desc; 
  } 
//+------------------------------------------------------------------+ 
//| Retorna a desc. textual do resultado da manipulação da solic.    | 
//+------------------------------------------------------------------+ 
string TradeResultDescription(const MqlTradeResult &result) 
  { 
//--- 
   string desc="Retcode "+(string)result.retcode+"\r\n"; 
   desc+="ID da solicitação: "+StringFormat("%d",result.request_id)+"\r\n"; 
   desc+="Bilhetagem (ticket) da ordem: "+(string)result.order+"\r\n"; 
   desc+="Bilhetagem (ticket) da operação: "+(string)result.deal+"\r\n"; 
   desc+="Volume: "+StringFormat("%G",result.volume)+"\r\n"; 
   desc+="Preço: "+StringFormat("%G",result.price)+"\r\n"; 
   desc+="Compra: "+StringFormat("%G",result.ask)+"\r\n"; 
   desc+="Venda: "+StringFormat("%G",result.bid)+"\r\n"; 
   desc+="Comentário: "+result.comment+"\r\n"; 
//--- retorna a string obtida 
   return desc; 
  }