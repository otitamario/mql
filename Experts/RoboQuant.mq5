//+------------------------------------------------------------------+
//|                                               socketclientEA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

sinput int lrlenght=150;
int socket;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit() 
  {
   socket=SocketCreate();
   EventSetTimer(1);
   return(INIT_SUCCEEDED); 
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) 
  {
   SocketClose(socket);
   EventKillTimer(); 
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void OnTimer() 
  {
  if(TimeLocal()%(30*60)==0)
  {
   socket=SocketCreate();
   if(socket!=INVALID_HANDLE) 
     {
      if(SocketConnect(socket,"127.0.0.1",8888,1000)) 
        {
         Print("Connected to "," 127.0.0.1",":",8888);

         
         string tosend="30 segundos";
         string received=socksend(socket,tosend) ? socketreceive(socket,10) : "";
         Print(received);
        }

      else Print("Connection ","127.0.0.1",":",8888," error ",GetLastError());
      SocketClose(socket); 
     }
   else Print("Socket creation error ",GetLastError()); 
  }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool socksend(int sock,string request) 
  {
   char req[];
   int  len=StringToCharArray(request,req)-1;
   if(len<0) return(false);
   return(SocketSend(sock,req,len)==len); 
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string socketreceive(int sock,int timeout) 
  {
   char rsp[];
   string result="";
   uint len;
   uint timeout_check=GetTickCount()+timeout;
   do 
     {
      len=SocketIsReadable(sock);
      if(len) 
        {
         int rsp_len;
         rsp_len=SocketRead(sock,rsp,len,timeout);
         if(rsp_len>0) 
           {
            result+=CharArrayToString(rsp,0,rsp_len); 
           }
        }
     }
   while((GetTickCount()<timeout_check) && !IsStopped());
   return result; 
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void drawlr(string points) 
  {
   string res[];
   StringSplit(points,' ',res);

   if(ArraySize(res)==2) 
     {
      Print(StringToDouble(res[0]));
      Print(StringToDouble(res[1]));
      datetime temp[];
      CopyTime(Symbol(),Period(),TimeCurrent(),lrlenght,temp);
      ObjectCreate(0,"regrline",OBJ_TREND,0,TimeCurrent(),NormalizeDouble(StringToDouble(res[0]),_Digits),temp[0],NormalizeDouble(StringToDouble(res[1]),_Digits)); 
     }
  }
//+------------------------------------------------------------------+
