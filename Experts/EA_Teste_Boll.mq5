//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
#resource "\\Indicators\\LS3RATIO_V2.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Operacao
  {
   Subtract=1,  //Diferença
   Add=2,       //Soma
   Multiply=3,  //Produto
   Divizion=4   //Razão
  };

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <statistics.mqh>
#include<Trade\AccountInfo.mqh>
#include <Controls\Dialog.mqh>

CSymbolInfo mysymbolA;
CSymbolInfo mysymbolB;

datetime BeginTime=D'1970.01.01'; //Data inicial para Indicador
input string   SimboloPapelA="PETR4";//Ativo Adicional 

input Operacao Action=Divizion;         //Operacao

input int   Periodo=40; // Período da MM.

input double   DesvioPerna1=2; // Desvio Perna1
input double   DesvioPerna2=3; // Desvio Perna2
input double   DesvioPerna3=4; // Desvio Perna3




string SimboloPapelB=Symbol();

int handleBollinger; //
double closeA[],closeB[],ratio[];
double media,desviopadrao;
double Boll_Sup,Boll_Inf,Boll_Sup2,Boll_Inf2,Boll_Sup3,Boll_Inf3;

bool Error_Init=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   LOAD_DATA();

   mysymbolA.Name(SimboloPapelA);
   mysymbolB.Name(SimboloPapelB);

   handleBollinger=iCustom(_Symbol,PERIOD_CURRENT,"::Indicators\\LS3RATIO_V2.ex5",BeginTime,SimboloPapelA,SimboloPapelB,Action,
                           Periodo,DesvioPerna1,DesvioPerna2,DesvioPerna3);


   ChartIndicatorAdd(ChartID(),(int)ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),handleBollinger);

   ArraySetAsSeries(closeA,true);
   ArraySetAsSeries(closeB,true);
   ArraySetAsSeries(ratio,true);

   ArrayResize(closeA,Periodo);
   ArrayResize(closeB,Periodo);
   ArrayResize(ratio,Periodo);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeletaIndicadores();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   mysymbolA.Refresh();
   mysymbolA.RefreshRates();

   mysymbolB.Refresh();
   mysymbolB.RefreshRates();

   if(CopyClose(SimboloPapelA,PERIOD_CURRENT,0,Periodo,closeA)<Periodo || CopyClose(SimboloPapelB,PERIOD_CURRENT,0,Periodo,closeB)<Periodo)
     {
      Print("Erro copy rates ");
      return;
     }

   switch(Action)
     {
      case   Subtract:
         for(int i=0;i<Periodo;i++)ratio[i]=closeA[i]-closeB[i];
         break;

      case   Add:
         for(int i=0;i<Periodo;i++)ratio[i]=closeA[i]+closeB[i];
         break;

      case   Multiply:
         for(int i=0;i<Periodo;i++)ratio[i]=closeA[i]*closeB[i];
         break;

      case   Divizion:
         for(int i=0;i<Periodo;i++)ratio[i]=closeA[i]/closeB[i];
         break;
     }
   media=mean(ratio);
   desviopadrao=std(ratio);
   Boll_Sup=media+DesvioPerna1*desviopadrao;
   Boll_Inf=media-DesvioPerna1*desviopadrao;

   Boll_Sup2=media+DesvioPerna2*desviopadrao;
   Boll_Inf2=media-DesvioPerna2*desviopadrao;

   Boll_Sup3=media+DesvioPerna3*desviopadrao;
   Boll_Inf3=media-DesvioPerna3*desviopadrao;

   string comentario="Ratio : "+DoubleToString(ratio[0],4)+"\n"+" Medía : "+DoubleToString(media,4)+"\n"+" Banda Superior : "+
                     DoubleToString(Boll_Sup,4)+"\n"+" Banda Inferior : "+DoubleToString(Boll_Inf,4)+"\n";

   comentario+="----------------------------------------"+"\n";
   comentario+=" Banda Superior 2 : "+
               DoubleToString(Boll_Sup2,4)+"\n"+" Banda Inferior 2 : "+DoubleToString(Boll_Inf2,4)+"\n";

   comentario+="----------------------------------------"+"\n";
   comentario+=" Banda Superior 3 : "+
               DoubleToString(Boll_Sup3,4)+"\n"+" Banda Inferior 3 : "+DoubleToString(Boll_Inf3,4);

   Comment(comentario);

  }// fim OnTick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


bool CheckNewBar(ENUM_TIMEFRAMES tf)
  {

   static datetime LastBar=0;
   datetime ThisBar=iTime(Symbol(),tf,0);
   if(LastBar!=ThisBar)
     {
      PrintFormat("New bar. Opening time: %s  Time of last tick: %s",
                  TimeToString((datetime)ThisBar,TIME_SECONDS),
                  TimeToString(TimeCurrent(),TIME_SECONDS));
      LastBar=ThisBar;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Loading the required data                                        |
//+------------------------------------------------------------------+
void LOAD_DATA()
  {
   datetime first_date;
   SeriesInfoInteger(SimboloPapelA,_Period,SERIES_FIRSTDATE,first_date);

   int res=CheckLoadHistory(SimboloPapelA,_Period,first_date);
   switch(res)
     {
      case -1 : Print("Unknown symbol ",SimboloPapelA); Error_Init=true;  break;
      case -2 : Print("Requested bars more than max bars in chart"); Error_Init=true;  break;
      case -3 : Print("Program was stopped");   Error_Init=true;                break;
      case -4 : Print("Indicator shouldn't load its own data");  Error_Init=true;    break;
      case -5 : Print("Load failed");                 Error_Init=true;               break;
      case  0 : Print("Loaded OK");                 Error_Init=false;                 break;
      case  1 : Print("Loaded previously");             Error_Init=false;             break;
      case  2 : Print("Loaded previously and built");          Error_Init=false;      break;
      default : Print("Unknown result");Error_Init=true;
     }

   SeriesInfoInteger(SimboloPapelB,_Period,SERIES_FIRSTDATE,first_date);

   res=CheckLoadHistory(SimboloPapelB,_Period,first_date);
   switch(res)
     {
      case -1 : Print("Unknown symbol ",SimboloPapelB); Error_Init=true;  break;
      case -2 : Print("Requested bars more than max bars in chart"); Error_Init=true;  break;
      case -3 : Print("Program was stopped");   Error_Init=true;                break;
      case -4 : Print("Indicator shouldn't load its own data");  Error_Init=true;    break;
      case -5 : Print("Load failed");                 Error_Init=true;               break;
      case  0 : Print("Loaded OK");                 Error_Init=false;                 break;
      case  1 : Print("Loaded previously");             Error_Init=false;             break;
      case  2 : Print("Loaded previously and built");          Error_Init=false;      break;
      default : Print("Unknown result");Error_Init=true;
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


void DeletaIndicadores()
  {
   string name;
//--- O número de janelas no gráfico (ao menos uma janela principal está sempre presente) 
   int windows=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
//--- Verifique todas as janelas 
   for(int w=windows-1;w>=0;w--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      //--- o número de indicadores nesta janela/sub-janela 
      int total=ChartIndicatorsTotal(0,w);
      //--- Passar por todos os indicadores na janela 
      for(int i=total-1;i>=0;i--)
        {
         //--- obtém o nome abreviado do indicador 
         name=ChartIndicatorName(0,w,i);
         ChartIndicatorDelete(0,w,name);
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CheckLoadHistory(string symbol,ENUM_TIMEFRAMES period,datetime start_date)
  {
   datetime first_date=0;
   datetime times[100];
//--- verifica ativo e período 
   if(symbol==NULL || symbol=="") symbol=Symbol();
   if(period==PERIOD_CURRENT)     period=Period();
//--- verifica se o ativo está selecionado no Observador de Mercado 
   if(!SymbolInfoInteger(symbol,SYMBOL_SELECT))
     {
      if(GetLastError()==ERR_MARKET_UNKNOWN_SYMBOL) return(-1);
      SymbolSelect(symbol,true);
     }
//--- verifica se os dados estão presentes 
   SeriesInfoInteger(symbol,period,SERIES_FIRSTDATE,first_date);
   if(first_date>0 && first_date<=start_date) return(1);
//--- não pede para carregar seus próprios dados se ele for um indicador 
   if(MQL5InfoInteger(MQL5_PROGRAM_TYPE)==PROGRAM_INDICATOR && Period()==period && Symbol()==symbol)
      return(-4);
//--- segunda tentativa 
   if(SeriesInfoInteger(symbol,PERIOD_M1,SERIES_TERMINAL_FIRSTDATE,first_date))
     {
      //--- existe dados carregados para construir a série de tempo 
      if(first_date>0)
        {
         //--- força a construção da série de tempo 
         CopyTime(symbol,period,first_date+PeriodSeconds(period),1,times);
         //--- verifica 
         if(SeriesInfoInteger(symbol,period,SERIES_FIRSTDATE,first_date))
            if(first_date>0 && first_date<=start_date) return(2);
        }
     }
//--- máximo de barras em um gráfico a partir de opções do terminal 
   int max_bars=TerminalInfoInteger(TERMINAL_MAXBARS);
//--- carrega informações de histórico do ativo 
   datetime first_server_date=0;
   while(!SeriesInfoInteger(symbol,PERIOD_M1,SERIES_SERVER_FIRSTDATE,first_server_date) && !IsStopped())
      Sleep(5);
//--- corrige data de início para carga 
   if(first_server_date>start_date) start_date=first_server_date;
   if(first_date>0 && first_date<first_server_date)
      Print("Aviso: primeira data de servidor ",first_server_date," para ",symbol,
            " não coincide com a primeira data de série ",first_date);
//--- carrega dados passo a passo 
   int fail_cnt=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   while(!IsStopped())
     {
      //--- espera pela construção da série de tempo 
      while(!SeriesInfoInteger(symbol,period,SERIES_SYNCHRONIZED) && !IsStopped())
         Sleep(5);
      //--- pede por construir barras 
      int bars=Bars(symbol,period);
      if(bars>0)
        {
         if(bars>=max_bars) return(-2);
         //--- pede pela primeira data 
         if(SeriesInfoInteger(symbol,period,SERIES_FIRSTDATE,first_date))
            if(first_date>0 && first_date<=start_date) return(0);
        }
      //--- cópia da próxima parte força carga de dados 
      int copied=CopyTime(symbol,period,bars,100,times);
      if(copied>0)
        {
         //--- verifica dados 
         if(times[0]<=start_date)  return(0);
         if(bars+copied>=max_bars) return(-2);
         fail_cnt=0;
        }
      else
        {
         //--- não mais que 100 tentativas com falha 
         fail_cnt++;
         if(fail_cnt>=100) return(-5);
         Sleep(10);
        }
     }
//--- interrompido 
   return(-3);
  }
