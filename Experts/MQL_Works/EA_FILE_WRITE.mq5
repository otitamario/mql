//+------------------------------------------------------------------+ 
//|                                          Demo_FileWriteArray.mq5 | 
//|                        Copyright 2013, MetaQuotes Software Corp. | 
//|                                              https://www.mql5.com | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright 2013, MetaQuotes Software Corp." 
#property link      "https://www.mql5.com" 
#property version   "1.00" 
//--- parâmetros de entrada 
input string InpFileName="dados.bin"; 
//+------------------------------------------------------------------+ 
//| Estrutura para armazenamento de dados de preços                  | 
//+------------------------------------------------------------------+ 
//--- variáveis globais 
int    count=0; 
int    size=20; 
string path=InpFileName; 

double arr[]; 
//+------------------------------------------------------------------+ 
//| Função de inicialização do Expert                                | 
//+------------------------------------------------------------------+ 
int OnInit() 
  { 
//--- alocar memória para o array 
   ArrayResize(arr,size); 
//--- 
   return(INIT_SUCCEEDED); 
  } 
//+------------------------------------------------------------------+ 
//| Função de Desinicialização do Expert                             | 
//+------------------------------------------------------------------+ 
void OnDeinit(const int reason) 
  { 
//--- escrever a contagem restante de strings se count < n 
   WriteData(count); 
  } 
//+------------------------------------------------------------------+ 
//| Função tick (ponto) de um Expert                                 | 
//+------------------------------------------------------------------+ 
void OnTick() 
  { 
//--- salvar dados para array 
   arr[count]=SymbolInfoDouble(Symbol(),SYMBOL_BID); 
//--- mostra dados correntes 
   Print(" Bid = ",arr[count]); 
//--- aumentar o contador 
   count++; 
//--- se array é arquivada, gravar dados no arquivo e zerá-lo 
   if(count==size) 
     { 
      WriteData(size);
      ExpertRemove();
      count=0; 
     } 
  } 
//+------------------------------------------------------------------+ 
//| Escrever n elementos array para arquivo                          | 
//+------------------------------------------------------------------+ 
void WriteData(const int n) 
  { 
//--- abre o arquivo 
   ResetLastError(); 
   int handle=FileOpen(path,FILE_READ|FILE_WRITE|FILE_BIN); 
   if(handle!=INVALID_HANDLE) 
     { 
      //--- escrever os dados array para o final do arquivo 
      FileSeek(handle,0,SEEK_END); 
      FileWriteArray(handle,arr,0,n); 
      //--- fechar o arquivo 
      FileClose(handle); 
     } 
   else 
      Print("Falha para abrir o arquivo, erro ",GetLastError()); 
  }

