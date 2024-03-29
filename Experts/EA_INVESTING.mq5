//+------------------------------------------------------------------+
//|                                                      EA_DLLs.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Moeda
  {
   EUR,//Europa
   CAN,//Canadá
   USD,//Estados Unidos
   BRL//Brasil
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Touros
  {
   Touro_1,//1 Touro
   Touro_2,//2 Touros
   Touro_3//3 Touros
  };

#import "Investing.dll"

sinput string sinvest="############------Notícias Investig.com------#################";//Notícias
input bool UsarNew=true;//Usar filtro de Notícias
input Moeda Inp_pais=USD;//País das Notícias
input Touros Inp_touros=Touro_3;//Touros
input uint minutos_news=15;//Tempo em Minutos para pausar o EA antes e depois da notícia

string pais;
int touros;
bool investing_filter;
datetime Hora_in[],Hora_fin[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

int OnInit()
  {

   switch(Inp_pais)
     {
      case EUR:
         pais="EUR";break;
      case CAN:
         pais="CAN";break;
      case USD:
         pais="USD";break;
      case BRL:
         pais="BRL";break;
     }

   switch(Inp_touros)
     {
      case Touro_1:
         touros=1;break;
      case Touro_2:
         touros=2;break;
      case Touro_3:
         touros=3;break;
     }
   investing_filter=GetInvesting(pais,touros);
   string investing=NewsInvesting(pais,touros);
   MessageBox(investing);
//---
   if(HorasInvesting(pais,touros))
     {
      for(int i=0;i<ArraySize(Hora_fin);i++)
        {
         Print("inicio "+TimeToString(Hora_in[i])+" fim "+TimeToString(Hora_fin[i]));
        }

      return(INIT_SUCCEEDED);
     }
     else
     {
     Alert("Sem notícias filtradas");
     }
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
bool GetInvesting(string _pais,int _touros)
  {
//Tentative
   datetime hora_init_news,hora_fin_news,hora_news;
   bool timer_news;
   string str_time_new;
   string to_split=Investing::getDados(_pais,_touros); // Um string para dividir em substrings
   string sep="#";                // Um separador como um caractere
   ushort u_sep;                  // O código do caractere separador
   string result[];               // Um array para obter strings
//--- Obtém o código do separador
   u_sep=StringGetCharacter(sep,0);
//--- Divide a string em substrings
   int k=StringSplit(to_split,u_sep,result);
//--- Exibe um comentário
// PrintFormat("Strings obtidos: %d. Usado separador '%s' com o código %d",k,sep,u_sep);
//--- Agora imprime todos os resultados obtidos
   timer_news=false;
   if(k>0)
     {
      for(int i=0;i<k;i++)
        {
         //PrintFormat("result[%d]=\"%s\"",i,result[i]);
         str_time_new=StringSubstr(result[i],0,5);
         if(str_time_new!="Tentative")
           {
            hora_news=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+str_time_new);
            hora_init_news=hora_news-minutos_news*60;
            hora_fin_news=hora_news+minutos_news*60;
            // Print("Hora início pausa news: "+TimeToString(hora_init_news)+" Hora final pausa news: "+TimeToString(hora_fin_news));
            timer_news=timer_news || (TimeCurrent()>=hora_init_news && TimeCurrent()<=hora_fin_news);
           }
        }
     }
   return timer_news;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string NewsInvesting(string _pais,int _touros)
  {
//Tentative
   datetime hora_init_news,hora_fin_news,hora_news;
   string str_time_new;
   string to_split=Investing::getDados(_pais,_touros); // Um string para dividir em substrings
   string sep="#";                // Um separador como um caractere
   ushort u_sep;                  // O código do caractere separador
   string result[];               // Um array para obter strings
//--- Obtém o código do separador
   u_sep=StringGetCharacter(sep,0);
//--- Divide a string em substrings
   int k=StringSplit(to_split,u_sep,result);
//--- Exibe um comentário
//  PrintFormat("Strings obtidos: %d. Usado separador '%s' com o código %d",k,sep,u_sep);
//--- Agora imprime todos os resultados obtidos
   string timer_news="-----------------Filtro de Notícias-------------"+"\n";
   if(k>0)
     {
      for(int i=0;i<k;i++)
        {
         //PrintFormat("result[%d]=\"%s\"",i,result[i]);
         timer_news=timer_news+result[i]+"\n";
         str_time_new=StringSubstr(result[i],0,5);
         if(str_time_new!="Tentative")
           {
            hora_news=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+str_time_new);
            hora_init_news=hora_news-minutos_news*60;
            hora_fin_news=hora_news+minutos_news*60;
            timer_news=timer_news+"Hora início pausa news: "+TimeToString(hora_init_news)+" Hora final pausa news: "+TimeToString(hora_fin_news)+"\n";
            timer_news=timer_news+"-------------------------------------------------------------------"+"\n";
           }
        }
     }
   return timer_news;
  }
//+------------------------------------------------------------------+
bool HorasInvesting(string _pais,int _touros)
  {
//Tentative
   datetime hora_init_news,hora_fin_news,hora_news;
   string str_time_new;
   string to_split=Investing::getDados(_pais,_touros); // Um string para dividir em substrings
   string sep="#";                // Um separador como um caractere
   ushort u_sep;                  // O código do caractere separador
   string result[];               // Um array para obter strings
//--- Obtém o código do separador
   u_sep=StringGetCharacter(sep,0);
//--- Divide a string em substrings
   int k=StringSplit(to_split,u_sep,result);
//--- Exibe um comentário
//  PrintFormat("Strings obtidos: %d. Usado separador '%s' com o código %d",k,sep,u_sep);
//--- Agora imprime todos os resultados obtidos
   if(k>0)
     {
      ArrayResize(Hora_in,k);
      ArrayResize(Hora_fin,k);
      ArrayInitialize(Hora_in,0);
      ArrayInitialize(Hora_fin,0);
      for(int i=0;i<k;i++)
        {
         //PrintFormat("result[%d]=\"%s\"",i,result[i]);
         str_time_new=StringSubstr(result[i],0,5);
         if(str_time_new!="Tentative")
           {
            hora_news=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+str_time_new);
            hora_init_news=hora_news-minutos_news*60;
            hora_fin_news=hora_news+minutos_news*60;
            Hora_in[i]=hora_init_news;
            Hora_fin[i]=hora_fin_news;
           }
        }
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
