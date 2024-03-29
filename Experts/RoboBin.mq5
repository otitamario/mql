//+------------------------------------------------------------------+
//|                                               socketclientEA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#resource "\\Indicators\\colorhma.ex5"
#include <Expert\Expert.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TipoEst
  {
   EstHMA,//Média HMA
   EstCan,//Canal
   EstBolCont,//Bollinger Contra-Tendência
   EstBolFav//Bollinger Favor da Tendência
  };

int HMA_Period=3;  // Moving average period
int per_med=14;//Periodo Media

input TipoEst estrategia=EstCan;//SeLecione a Estratégia
int lrlenght=150;
int socket;
int hma_handle;
double hma_buffer[];
string tosend;
CiMA *mediaHigh;
CiMA *mediaLow;
CiBands *banda;
double _price_close;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   socket=SocketCreate();
   EventSetMillisecondTimer(200);
   return(INIT_SUCCEEDED);
   ArraySetAsSeries(hma_buffer,true);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   SocketClose(socket);
   EventKillTimer();
   IndicatorRelease(hma_handle);
   delete(mediaHigh);
   delete(mediaLow);
   delete(banda);

  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void OnTimer()
  {
   if(TimeLocal()%(5)==0)
     {
      socket=SocketCreate();
      if(socket!=INVALID_HANDLE)
        {
         if(SocketConnect(socket,"127.0.0.1",8888,1000))
           {
            if(TimeCurrent()%10==0)
               Print("Connected to "," 127.0.0.1",":",8888);

            string received=socketreceive(socket,10);
            Print(received);

            switch(estrategia)
              {
               case EstHMA:
                 {
                  hma_handle=iCustom(received,PERIOD_M5,"::Indicators\\colorhma.ex5",HMA_Period,0);
                  if(hma_handle!=INVALID_HANDLE)
                    {
                     if(CopyBuffer(hma_handle,1,0,4,hma_buffer)==4)
                       {
                        tosend=DoubleToString(hma_buffer[0],0);
                        socksend(socket,tosend);
                       }
                     else
                       {
                        tosend="0";
                        socksend(socket,tosend);
                       }
                    }
                  else
                    {
                     tosend="0";
                     socksend(socket,tosend);
                    }
                  break;
                 }
               case EstCan:
                 {
                  mediaHigh=new CiMA;
                  mediaHigh.Create(received,PERIOD_M5,per_med,0,MODE_EMA,PRICE_HIGH);

                  mediaLow=new CiMA;
                  mediaLow.Create(received,PERIOD_M5,per_med,0,MODE_EMA,PRICE_LOW);
                  mediaHigh.Refresh();
                  mediaLow.Refresh();
                  _price_close=iClose(received,PERIOD_M5,1);
                  tosend="0";
                  if(_price_close>mediaHigh.Main(1))
                     tosend="2";
                  if(_price_close<mediaLow.Main(1))
                     tosend="1";

                  socksend(socket,tosend);
                  delete(mediaHigh);
                  delete(mediaLow);
                  break;
                 }
               case EstBolCont:
                 {
                  banda=new CiBands;
                  banda.Create(received,PERIOD_M5,20,0,2.0,PRICE_CLOSE);
                  banda.Refresh();
                  _price_close=iClose(received,PERIOD_M5,1);
                  tosend="0";
                  if(_price_close>banda.Upper(1))
                     tosend="2";
                  if(_price_close<banda.Lower(1))
                     tosend="1";
                  socksend(socket,tosend);
                  delete(banda);
                  break;
                 }
               case EstBolFav:
                 {
                  banda=new CiBands;
                  banda.Create(received,PERIOD_M5,20,0,2.0,PRICE_CLOSE);
                  banda.Refresh();
                  _price_close=iClose(received,PERIOD_M5,1);
                  tosend="0";
                  if(_price_close>banda.Upper(1))
                     tosend="1";
                  if(_price_close<banda.Lower(1))
                     tosend="2";
                  socksend(socket,tosend);
                  delete(banda);
                  break;
                 }
              }
           }

         //  else Print("Connection ","127.0.0.1",":",8888," error ",GetLastError());
         SocketClose(socket);
        }
      else Print("Socket creation error ",GetLastError());
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
