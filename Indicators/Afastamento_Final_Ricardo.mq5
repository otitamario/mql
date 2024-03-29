//+------------------------------------------------------------------+
//| Indic_Afastamento_Media_MATS_Ricardo_V4.mq5.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                 https://mql5.com |
//+------------------------------------------------------------------+


#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://mql5.com"
#property version   "1.00"
#property description   ""
#property indicator_separate_window
#property indicator_buffers 5
#property indicator_plots   3
//--- plot HistEMA

#property indicator_label1  "Media +"
#property indicator_type1   DRAW_LINE
#property indicator_color1   clrGreen
#property indicator_style1  STYLE_DASH
#property indicator_width1  2



#property indicator_label2  "Media -"
#property indicator_type2   DRAW_LINE
#property indicator_color2   clrRed
#property indicator_style2  STYLE_DASH
#property indicator_width2  2


#property indicator_label3  "Afastamento Media"
#property indicator_type3   DRAW_COLOR_HISTOGRAM
#property indicator_color3  clrGreen,clrRed,clrYellow
#property indicator_style3  STYLE_SOLID
#property indicator_width3  4
//--- input parameters
input int      period_media=15;   // Periodo Média
input ENUM_MA_METHOD modo_media=MODE_EMA;//Modo Média
input ENUM_APPLIED_PRICE app_media=PRICE_CLOSE;//Appliedd Price
input uint period_delta=10; // Período da média das distâncias:
input double filtro_afastamento_positivo=150; //Calcular a média das distâncias maiores que:
input double   filtro_afastamento_negativo=0; //Calcular a média das distâncias menores que:
input uint  hora_inicio=8;
input uint hora_fim=19;
bool   gravar_dados=false;

//--- indicator buffers
double         BufferPositivo[];
double         BufferNegativo[];
double         BufferDist[];
double         BufferDistColors[];
double         BufferTMP[];
//--- global variables
int            period;
int            handle_ema;
uint           maior_periodo = MathMax(period_media,period_delta);
int text=0;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  

SymbolSelect(NULL,true);
  
//--- set parameters
   period=(period_media<1 ? 1 : period_media);
   handle_ema=iMA(NULL,0,period,0,modo_media,app_media);
   if(handle_ema==INVALID_HANDLE)
     {
      Print("Failed to create an EMA handle");
      return INIT_FAILED;
     }
//--- indicator buffers mapping
   SetIndexBuffer(0,BufferPositivo,INDICATOR_DATA);
   SetIndexBuffer(1,BufferNegativo,INDICATOR_DATA);
   SetIndexBuffer(2,BufferDist,INDICATOR_DATA);
   SetIndexBuffer(3,BufferDistColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,BufferTMP,INDICATOR_CALCULATIONS);
//--- colors parameters
   PlotIndexSetInteger(3,PLOT_LINE_COLOR,0,clrGreen);
   PlotIndexSetInteger(3,PLOT_LINE_COLOR,1,clrRed);
   PlotIndexSetInteger(3,PLOT_LINE_COLOR,2,clrYellow);
   
   
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, maior_periodo+2);
   PlotIndexSetInteger(1, PLOT_DRAW_BEGIN, maior_periodo+2);
   PlotIndexSetInteger(2, PLOT_DRAW_BEGIN, maior_periodo+2);
   PlotIndexSetInteger(3, PLOT_DRAW_BEGIN, maior_periodo+2);
   PlotIndexSetInteger(3, PLOT_DRAW_BEGIN, maior_periodo+2);           
   
   
   
//--- strings parameters
   string params="("+(string)period+")";
   IndicatorSetString(INDICATOR_SHORTNAME,"Afastamento Media"+params);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(handle_ema);
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
  
   if (Bars(_Symbol,_Period)<rates_total) return(0);
  
//--- Checking for minimum number of bars
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0)
   {
   to_copy=rates_total;
   ArrayInitialize(BufferPositivo,EMPTY_VALUE);
   ArrayInitialize(BufferNegativo,EMPTY_VALUE);   
   }
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
   CopyBuffer(handle_ema,0,0,to_copy,BufferTMP);
   


   for(int i=MathMax(2,prev_calculated-1); i<rates_total;i++)
     {






      if(high[i]-BufferTMP[i]>BufferTMP[i]-low[i])BufferDist[i]=high[i]-BufferTMP[i];
      else BufferDist[i]=low[i]-BufferTMP[i];
      if(BufferDist[i]>=0)
         BufferDistColors[i]=0;
      else BufferDistColors[i]=1;



if(i > maior_periodo)
{     if (text==0) text=i; //usado para gravar os dados

         double Pos=0.0; double Neg=0.0; int Cont_Pos=0; int Cont_Neg=0;
         
         int j=0;
         //Usar while
         while(j<i-maior_periodo && Cont_Pos<period_delta  && !IsStopped())         
           {
         MqlDateTime hora_atual;
         TimeToStruct(time[i-j], hora_atual);
            if(BufferDist[i-j]>filtro_afastamento_positivo && BufferDist[i-j]!=0 && hora_atual.hour >=hora_inicio && hora_atual.hour<=hora_fim)
            {
            Pos+=BufferDist[i-j]; 
            Cont_Pos++;
            }
           j++;

           }
         if(Cont_Pos!=0 && Pos!=0)BufferPositivo[i]=Pos/Cont_Pos; else BufferPositivo[i]=EMPTY_VALUE;
 
j=0;         
         while(j<i-maior_periodo && Cont_Neg<period_delta && !IsStopped())         
           {
         MqlDateTime hora_atual;
         TimeToStruct(time[i-j], hora_atual);
            if(BufferDist[i-j]<-filtro_afastamento_negativo && BufferDist[i-j]!=0 && hora_atual.hour >=hora_inicio && hora_atual.hour<=hora_fim)
            {
            Neg+=BufferDist[i-j]; 
            Cont_Neg++;
            }
           j++;
         }
         if(Cont_Neg!=0 && Neg!=0)BufferNegativo[i]=Neg/Cont_Neg; else BufferNegativo[i]=EMPTY_VALUE;

     
}
else BufferPositivo[i]=BufferNegativo[i]=EMPTY_VALUE;

if(gravar_dados)
{
text=i+1;
int h = FileOpen("DadosTeste.txt",FILE_READ|FILE_WRITE|FILE_ANSI|FILE_TXT);   
string aux = string(BufferDist[i]) + ";"+string(BufferNegativo[i])+";"+string(BufferPositivo[i]);
FileSeek(h,0,SEEK_END);
FileWrite(h,aux);
FileClose(h);
}

     }
     

     
     

   return(rates_total);
  }
//+------------------------------------------------------------------+
