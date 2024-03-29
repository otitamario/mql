//+------------------------------------------------------------------+
//|                                                    my_oop_ea.mq5 |
//|                        Copyright 2010, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2010, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#property version   "1.00"
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>
CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
#define N_ACOES 13 // Número de Ações
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct Datetime
  {
   datetime          time[1];
  };
Datetime lastbar_time[N_ACOES];
//--- Array for checking the new bar for each symbol
datetime new_bar[N_ACOES];

//--- input parameters
input ulong Magic_Number=28122018;//Número Mágico
input string data_compra="2018.12.28";//Data no formato yyyy.mm.dd ANO.MÊS.DIA
input double   Lot=200;          // Lote de Entrada
input string end_hour="17:30";//Horario Fechamento de Posições

//string Acoes[N_ACOES]={"ALUP11","BEEF3","BRIN3","CVCB3","DTEX3","EZTC3","FLRY3","MILS3","QUAL3","RDNI3","SANB11","SGPS3","SUZB3","TAEE11"};
string Acoes[N_ACOES]={"ALUP11","BEEF3","CVCB3","DTEX3","EZTC3","FLRY3","MILS3","QUAL3","RDNI3","SANB11","SGPS3","SUZB3","TAEE11"};

datetime hora_final;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
 
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.SetTypeFilling(ORDER_FILLING_RETURN);

   return(INIT_SUCCEEDED);
   for(int i=0;i<N_ACOES;i++)SymbolSelect(Acoes[i],true);
   InitializeArrayNewBar();
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {

   if(TimeToString(TimeCurrent(),TIME_DATE)==data_compra)
     {

      for(int i=0;i<N_ACOES;i++)
        {
         if(CheckNewBar(i,PERIOD_M2))//Nova Barra
           {
            mytrade.Buy(Lot,Acoes[i]);
           }

        }

      hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
      if(TimeCurrent()>=hora_final && PositionsTotal()>0)CloseALL();

     }
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

void CloseALL()
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
        {
         if(!mytrade.PositionClose(PositionGetTicket(i)))
           {
            Print(PositionGetTicket(i),"PositionClose() method failed. Return code=",mytrade.ResultRetcode(),
                  ". Code description: ",mytrade.ResultRetcodeDescription());
           }
         else
           {
            Print(PositionGetTicket(i),"PositionClose() method executed successfully. Return code=",mytrade.ResultRetcode(),
                  " (",mytrade.ResultRetcodeDescription(),")");
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Checking for the new bar                                         |
//+------------------------------------------------------------------+
bool CheckNewBar(int number_symbol,ENUM_TIMEFRAMES _period)
  {
//--- Get the opening time of the current bar
//    If an error occurred when getting the time, print the relevant message
   if(CopyTime(Acoes[number_symbol],_period,0,1,lastbar_time[number_symbol].time)==-1)
      Print(__FUNCTION__,": Error copying the opening time of the bar: "+IntegerToString(GetLastError()));
//--- If this is a first function call
   if(new_bar[number_symbol]==NULL)
     {
      //--- Set the time
      new_bar[number_symbol]=lastbar_time[number_symbol].time[0];
      Print(__FUNCTION__,": Initialization ["+Acoes[number_symbol]+"][TF: "+TimeframeToString(_period)+"]["
            +TimeToString(lastbar_time[number_symbol].time[0],TIME_DATE|TIME_MINUTES|TIME_SECONDS)+"]");
      return(false);
     }
//--- If the time is different
   if(new_bar[number_symbol]!=lastbar_time[number_symbol].time[0])
     {
      //--- Set the time and exit
      new_bar[number_symbol]=lastbar_time[number_symbol].time[0];
      return(true);
     }
//--- If we have reached this line, then the bar is not new, so return false
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitializeArrayNewBar()
  {
//--- Initialize to zeros
   ArrayInitialize(new_bar,0);
//---
   for(int s=0; s<N_ACOES; s++)
     {
      //--- If trading for this symbol is allowed
      if(Acoes[s]!="")
         //--- Initialize the time of the current bar
         CheckNewBar(s,PERIOD_D1);
     }
  }
//+------------------------------------------------------------------+


string TimeframeToString(ENUM_TIMEFRAMES timeframe)
  {
   string str="";
//--- If the passed value is incorrect, take the time frame of the current chart
   if(timeframe==WRONG_VALUE|| timeframe== NULL)
      timeframe= Period();
   switch(timeframe)
     {
      case PERIOD_M1  : str="M1";  break;
      case PERIOD_M2  : str="M2";  break;
      case PERIOD_M3  : str="M3";  break;
      case PERIOD_M4  : str="M4";  break;
      case PERIOD_M5  : str="M5";  break;
      case PERIOD_M6  : str="M6";  break;
      case PERIOD_M10 : str="M10"; break;
      case PERIOD_M12 : str="M12"; break;
      case PERIOD_M15 : str="M15"; break;
      case PERIOD_M20 : str="M20"; break;
      case PERIOD_M30 : str="M30"; break;
      case PERIOD_H1  : str="H1";  break;
      case PERIOD_H2  : str="H2";  break;
      case PERIOD_H3  : str="H3";  break;
      case PERIOD_H4  : str="H4";  break;
      case PERIOD_H6  : str="H6";  break;
      case PERIOD_H8  : str="H8";  break;
      case PERIOD_H12 : str="H12"; break;
      case PERIOD_D1  : str="D1";  break;
      case PERIOD_W1  : str="W1";  break;
      case PERIOD_MN1 : str="MN1"; break;
     }
//---
   return(str);
  }
