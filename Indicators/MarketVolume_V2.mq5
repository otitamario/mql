//+------------------------------------------------------------------+
//|                                                      Volumes.mq5 |
//|                   Copyright 2009-2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009-2017, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//---- indicator settings
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrAqua
#property indicator_width1 2


#define TAM_MAX_PRECOS 1000 //Tamanho Maximo Array de PRECOS ACIMA ou ABAIXO
#define bars 120// Barras para plotar
//#property indicator_minimum 0.0
//--- input data

//input string          InpLoadedSymbol="DOLV17";   // Ativo a ser carregado 
//input ENUM_TIMEFRAMES periodo=PERIOD_M5;

//---- indicator buffers
double MaisNegociado[];
double preco_acima[TAM_MAX_PRECOS],preco_abaixo[TAM_MAX_PRECOS],precos[2*TAM_MAX_PRECOS];
double preco_compra,preco_venda,preco_max;

double ponto,ticksize,digits;
MqlTick tick_array[];

int periodo=_Period;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   SetIndexBuffer(0,MaisNegociado,INDICATOR_DATA);

//---- name for DataWindow and indicator subwindow label
//  PlotIndexSetString(0,PLOT_LABEL," Open;"+" High;"+" Low;"+" Close"); 
   string symbol=_Symbol;
   
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Bars(Symbol(),Period())-bars);


   ponto=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
   ticksize=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);

  }
//+------------------------------------------------------------------+
//|  Volumes                                                         |
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

   double maximo,minimo,abertura,total,compra,venda;
   ulong tempo;

   datetime d1=D'2017.09.27 00:00:01';
   datetime d2=D'2017.09.27 23:59:59';
//-
   ulong data_inicio,data_fim;
   data_inicio=d1;
   data_fim=d2;
//bars=Bars(_Symbol,_Period,data_inicio,data_fim);

   if(rates_total<2)
      return(0);
//--- starting work

   int start=rates_total-bars;
//--- Se já foi calculado durante os inícios anteriores do OnCalculate 
   if(prev_calculated>0) start=prev_calculated-1;
//for(int i=MathMax(1,start);i<rates_total &&!IsStopped();i++)
// for(int i=MathMax(1,prev_calculated-1); i<rates_total &&!IsStopped();i++)
   for(int i=start; i<rates_total && !IsStopped();i++)

     {
      //--- requesting ticks

      ulong atual;
      MqlTick tick_array[];
      atual=time[i];
      if(periodo<=30) tempo=atual*1000+periodo*60*1000;
      if(periodo==16385) tempo=atual*1000+60*60*1000;//Periodo H1

      int copied=CopyTicksRange(_Symbol,tick_array,COPY_TICKS_TRADE,atual*1000,tempo);
      //  int copied=CopyTicks(_Symbol,tick_array,COPY_TICKS_TRADE,atual*1000,tick_volume[i]);
      ArraySetAsSeries(tick_array,true);
      int size=ArraySize(tick_array);
      //---

      //------------Histograma---------------------------------

      //---
      if(copied>0)
        {

         for(int k=0;k<copied;k++)
           {
            double last;
            int numb_tick;
            MqlTick tick=tick_array[k];

            if(tick.last>0)
               last=tick.last;
            numb_tick=(int)((last-open[i])/ticksize);
            if(numb_tick>=0)
              {
               preco_acima[numb_tick]+=1;
              }
            else
              {
               preco_abaixo[-numb_tick-1]+=1;
              }
           }

         ZeroMemory(tick_array);
        }
      else Print("Ticks could not be loaded. GetLastError()=",GetLastError());

      int total_acima,total_abaixo;
      double value_tick;
      double soma;
      int id_max;
      int size_acima,size_abaixo;
      size_acima=ArraySize(preco_acima);
      size_abaixo=ArraySize(preco_abaixo);
      soma=0;
      int cont=0;
      value_tick=preco_acima[cont];
      while(value_tick!=0)
        {
         cont+=1;
         value_tick=preco_acima[cont];
        }
      total_acima=cont;
      cont=0;
      value_tick=preco_abaixo[cont];
      while(value_tick!=0)
        {
         cont+=1;
         value_tick=preco_abaixo[cont];

        }
      total_abaixo=cont;
      for(int j=0;j<total_abaixo;j++)precos[j]=preco_abaixo[total_abaixo-1-j];
      for(int j=total_abaixo;j<total_abaixo+total_acima;j++)precos[j]=preco_acima[j-total_abaixo];
      double media=0;
      id_max=ArrayMaximum(precos,0);
      preco_max=low[i]+id_max*ticksize;

      //------------Histograma---------------------------------

      MaisNegociado[i]=preco_max;
      ArrayInitialize(preco_abaixo,0.0);
      ArrayInitialize(preco_acima,0.0);
      ArrayInitialize(precos,0.0);

     }

   return(rates_total);

  }
//+------------------------------------------------------------------+
