//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#include <MovingAverages.mqh>

#property indicator_separate_window
#property indicator_buffers   9
#property indicator_plots     6
#property indicator_label1    "Ratio";
#property indicator_color1    clrBlue
#property indicator_style1    STYLE_SOLID
#property indicator_type1     DRAW_LINE
#property indicator_width1    2
#property indicator_label2    "Mean Line";
#property indicator_color2    clrAqua
#property indicator_style2    STYLE_SOLID
#property indicator_type2     DRAW_LINE
#property indicator_width2    1
#property indicator_label3    "Upper Band";
#property indicator_color3    clrAqua
#property indicator_style3    STYLE_SOLID
#property indicator_type3    DRAW_LINE
#property indicator_width3    1
#property indicator_label4    "Lower Band";
#property indicator_color4    clrAqua
#property indicator_style4    STYLE_SOLID
#property indicator_type4     DRAW_LINE
#property indicator_width4    1
#property indicator_level1    0
#property indicator_type5  DRAW_LINE
#property indicator_color5 clrOrangeRed
#property indicator_style5 STYLE_DOT
#property indicator_width5 2
#property indicator_label5 "H2 Band"

#property indicator_type6  DRAW_LINE
#property indicator_color6 clrOrangeRed
#property indicator_style6 STYLE_DOT
#property indicator_width6 2
#property indicator_label6 "L2 Band"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

enum Operacao
  {
   Subtract=1,  //Diferença
   Add=2,       //Soma
   Multiply=3,  //Produto
   Divizion=4,//Razão
   Log=5//Diferença de Logaritmos
  };

input datetime BeginTime      =  D'2008.01.01'; //Data inicial
input string   Symbol1        =  "PETR4";       //Papel 1
input string   Symbol2        =  "PETR3";       //Papel 2
input Operacao Action=  Divizion;         //Operacao
bool     Invert1        =  false;         //Inverter papel 1
bool     Invert2        =  false;         //Inverter papel 2
double   Multi1         =  1;             //Multiplicador papel 1
double   Multi2         =  1;             //Multiplicador papel 2
uint     Window         =  100;           //Numero de barras considerado
bool     ShowBands=true;          //Mostrar Bandas de Bollinger
input int      BandsPeriod    =  20;            //Periodo para as BB
input double   BandsDev       =  2.0;           //Desvio Padrao para as BB
input double   DesvioPerna2=3; // Desvio Perna2
bool     PushNotify     =  false;         //Enviar notificacoes push
double   LoLevelNotify  =  0.1;           //Limite inferior para envio de notificacao
double   HiLevelNotify  =  5.0;           //Limite superior para envio de notificacao

bool           Error_Init=true;
bool           notifySent;
datetime       BeginDate=0;

double         BF[],
PR1[],PR2[],// Arrays intermediarios para processamento
UB[],ML[],LB[],STDDEV[],Sup_Buffer2[],Inf_Buffer2[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   Error_Init=true;
   LOAD_DATA();
   IndicatorSetString(INDICATOR_SHORTNAME,"L&S");

   int smb=(int(Window))+BandsPeriod+1;
   string txt;
   if(Bars(Symbol1,PERIOD_CURRENT)<=smb)
     {
      txt=txt+"\nNot enough data of the first symbol";
      Comment(txt);
      //  return(INIT_FAILED);
     }
   if(Bars(Symbol2,PERIOD_CURRENT)<=smb)
     {
      txt=txt+"\nNot enough data of the second symbol";
      Comment(txt);
      // return(INIT_FAILED);
     }

   SetIndexBuffer(0,BF,INDICATOR_DATA);
   SetIndexBuffer(1,ML,INDICATOR_DATA);
   SetIndexBuffer(2,UB,INDICATOR_DATA);
   SetIndexBuffer(3,LB,INDICATOR_DATA);
   SetIndexBuffer(4,Sup_Buffer2,INDICATOR_DATA);
   SetIndexBuffer(5,Inf_Buffer2,INDICATOR_DATA);
   SetIndexBuffer(6,PR1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,PR2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,STDDEV,INDICATOR_CALCULATIONS);
   IndicatorSetInteger(INDICATOR_DIGITS,7);
//---
   ZeroMemory(BF);
   ZeroMemory(UB);
   ZeroMemory(ML);
   ZeroMemory(LB);
   ZeroMemory(STDDEV);
   ZeroMemory(Sup_Buffer2);
   ZeroMemory(Inf_Buffer2);

   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,smb);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,smb);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,smb);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,smb);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,smb);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,smb);

   notifySent=false;
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment(""+"\n"+"");
   ChartRedraw();
   ZeroMemory(BF);
   ZeroMemory(UB);
   ZeroMemory(ML);
   ZeroMemory(LB);
   ZeroMemory(STDDEV);
   ZeroMemory(Sup_Buffer2);
   ZeroMemory(Inf_Buffer2);

  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   if(Error_Init) LOAD_DATA();
   if(Error_Init) return(INIT_FAILED); //Initialization error

   double pr1[1],pr2[1];
   int x1,x2;
   int limit=prev_calculated;

   if(limit>1) limit=limit-2;

//--- step 1 - data preparation
   for(int pos=1+limit;pos<rates_total;pos++)
     {//preparing initial data
      if(time[pos]<BeginDate)
        {
         EMTF(pos);
         continue;
        }
      //---
      x1=CopyClose(Symbol1,PERIOD_CURRENT,time[pos],1,pr1);
      x2=CopyClose(Symbol2,PERIOD_CURRENT,time[pos],1,pr2);
      if(x1<=0 || x2<=0)
        {
         EMTF(pos);
         // Print("Sem cotacao: "+string(time[pos]));
         continue;
        }
      if(pr1[0]==0 || pr2[0]==0)
        {
         EMTF(pos);
         //Print("Nenhum dado recebido: "+string(time[pos]));
         continue;
        }

      PR1[pos]=MODIFY(pr1[0],Invert1,Multi1);
      PR2[pos]=MODIFY(pr2[0],Invert2,Multi2);
     }//preparing initial data

//--- merge two arrays into one
   for(int pos=1+limit;pos<rates_total;pos++) BF[pos]=ACTION(PR1[pos],PR2[pos]);

   if(ShowBands)
     {

      for(int pos=1+limit;pos<rates_total;pos++)
        {
         //--- middle line
         ML[pos]=SimpleMA(pos,BandsPeriod,BF);
         //--- calculate and write down StdDev
         STDDEV[pos]=StdDev_Func(pos,BF,ML,BandsPeriod);
         //--- upper line
         UB[pos]=ML[pos]+BandsDev*STDDEV[pos];
         //--- lower line
         LB[pos]=ML[pos]-BandsDev*STDDEV[pos];

         Sup_Buffer2[pos]=ML[pos]+DesvioPerna2*STDDEV[pos];
         //--- lower line
         Inf_Buffer2[pos]=ML[pos]-DesvioPerna2*STDDEV[pos];

        }

     }
   else
     {
      for(int pos=1+limit;pos<rates_total;pos++) LCLEAR(pos);
     }

// Verifica se deve enviar notificacao para o ultimo valor calculado
   if(PushNotify && (!notifySent))
     {
      if(BF[rates_total-1]<LoLevelNotify)
        {
         SendNotification(StringFormat("Ratio para L&S de %s/%s esta abaixo de %s",Symbol1,Symbol2,DoubleToString(LoLevelNotify,3)));
         notifySent=true;
        }
      else if(BF[rates_total-1]>HiLevelNotify)
        {
         SendNotification(StringFormat("Ratio para L&S de %s/%s esta acima de %s",Symbol1,Symbol2,DoubleToString(HiLevelNotify,3)));
         notifySent=true;
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Changing the price                                               |
//+------------------------------------------------------------------+
double MODIFY(double in,bool inv,double ml)
  {
   if(inv) in=1/in;
   in=in*ml;
   return(in);
  }
//+------------------------------------------------------------------+
//| Mathematical action                                              |
//+------------------------------------------------------------------+
double ACTION(double in1,double in2)
  {
   if(in1==EMPTY_VALUE || in2==EMPTY_VALUE) return(EMPTY_VALUE);
   switch(Action)
     {
      case 1: return(in1-in2);
      case 2: return(in1+in2);
      case 3: return(in1*in2);
      case 4: return(in1/in2);
      case 5: return(log(in1)-log(in2));
     }
   return(in1/in2);
  }
//+------------------------------------------------------------------+
//| Loading the required data                                        |
//+------------------------------------------------------------------+
void LOAD_DATA()
  {
   datetime first_date;
   SeriesInfoInteger(Symbol1,_Period,SERIES_FIRSTDATE,first_date);

   int res=CheckLoadHistory(Symbol1,_Period,first_date);
   switch(res)
     {
      case -1 : Print("Unknown symbol ",Symbol1); Error_Init=true;  break;
      case -2 : Print("Requested bars more than max bars in chart"); Error_Init=true;  break;
      case -3 : Print("Program was stopped");   Error_Init=true;                break;
      case -4 : Print("Indicator shouldn't load its own data");  Error_Init=true;    break;
      case -5 : Print("Load failed");                 Error_Init=true;               break;
      case  0 : Print("Loaded OK");                 Error_Init=false;                 break;
      case  1 : Print("Loaded previously");             Error_Init=false;             break;
      case  2 : Print("Loaded previously and built");          Error_Init=false;      break;
      default : Print("Unknown result");Error_Init=true;
     }

   SeriesInfoInteger(Symbol2,_Period,SERIES_FIRSTDATE,first_date);

   res=CheckLoadHistory(Symbol2,_Period,first_date);
   switch(res)
     {
      case -1 : Print("Unknown symbol ",Symbol2); Error_Init=true;  break;
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
//| Assigning an empty value to all arrays at the current position   |
//+------------------------------------------------------------------+
void EMTF(int i)
  {
   BF[i]=EMPTY_VALUE;
   PR1[i]=EMPTY_VALUE;
   PR2[i]=EMPTY_VALUE;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void LCLEAR(int i)
  {
   UB[i]=EMPTY_VALUE;
   ML[i]=EMPTY_VALUE;
   LB[i]=EMPTY_VALUE;
   Sup_Buffer2[i]=EMPTY_VALUE;
   Inf_Buffer2[i]=EMPTY_VALUE;

  }
//+------------------------------------------------------------------+
//| Make up the indicator name                                       |
//+------------------------------------------------------------------+
string NAME()
  {
   string name="";
   if(Invert1) name="(inv)"+Symbol1;
   else name=Symbol1;
   switch(Action)
     {
      case 1: name=name+"-";break;
      case 2: name=name+"/";break;
     }
   if(Invert2) name=name+"(inv)"+Symbol2;
   else name=name+Symbol2;
   return(name);
  }
//+------------------------------------------------------------------+

double StdDev_Func(int position,const double &price[],const double &MAprice[],int period)
  {
//--- variables
   double StdDev_dTmp=0.0;
//--- check for position
   if(position<period) return(StdDev_dTmp);
//--- calcualte StdDev
   for(int i=0;i<period;i++) StdDev_dTmp+=MathPow(price[position-i]-MAprice[position],2);
   StdDev_dTmp=MathSqrt(StdDev_dTmp/period);
//--- return calculated value
   return(StdDev_dTmp);
  }
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
//+------------------------------------------------------------------+
