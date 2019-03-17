//+------------------------------------------------------------------+
//|                                                      Volumes.mq5 |
//|                   Copyright 2009-2017, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "2009-2017, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
//---- indicator settings
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_type1   DRAW_CANDLES 
#property indicator_label1 "Open;High;Low;Close"
#property indicator_color1  clrBlack,clrGreen,clrRed
#property indicator_style1 STYLE_SOLID
#property indicator_width1  5
//#property indicator_minimum 0.0
//--- input data
//input int horas_trade=9; // Horas de trade por dia
                         //input string          InpLoadedSymbol="DOLV17";   // Ativo a ser carregado 
//input ENUM_TIMEFRAMES periodo=PERIOD_M5;

//---- indicator buffers
double Volume_Open_Buffer[],Volume_High_Buffer[],Volume_Low_Buffer[],Volume_Close_Buffer[];
int periodo=_Period;
int horas_trade=Bars(Symbol(),PERIOD_H1,iTime(Symbol(),PERIOD_D1,1),iTime(Symbol(),PERIOD_D1,2));

#define TENTATIVAS 10
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
   SetIndexBuffer(0,Volume_Open_Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,Volume_High_Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,Volume_Low_Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,Volume_Close_Buffer,INDICATOR_DATA);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);

//---- name for DataWindow and indicator subwindow label
//  PlotIndexSetString(0,PLOT_LABEL," Open;"+" High;"+" Low;"+" Close"); 
   string symbol=_Symbol;
//--- Definir a exibição do símbolo 
   PlotIndexSetString(0,PLOT_LABEL,symbol+" Open;"+symbol+" High;"+symbol+" Low;"+symbol+" Close");


   IndicatorSetString(INDICATOR_SHORTNAME,"Saldo Agressão");
//---- indicator digits
   IndicatorSetInteger(INDICATOR_DIGITS,0);

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
   int bars;
   int count,copied;
   datetime d1=D'2017.09.27 00:00:01';
   datetime d2=D'2017.09.27 23:59:59';
//-
   ulong data_inicio,data_fim;
   data_inicio=d1;
   data_fim=d2;
//bars=Bars(_Symbol,_Period,data_inicio,data_fim);
   if(periodo<=30) bars=(60*horas_trade)/periodo; //M1 ate M30
  if(periodo==16385) bars=horas_trade;//Periodo H1

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
      if(periodo<=30) tempo=atual*1000+periodo*60*1000;//M1 ate M30
      if(periodo==16385) tempo=atual*1000+60*60*1000;//Periodo H1

      copied=0;
      count=0;
      while(copied<=0 && count<=TENTATIVAS)
        {
         copied=CopyTicksRange(_Symbol,tick_array,COPY_TICKS_TRADE,atual*1000,tempo);
         count+=1;
        }
      //  int copied=CopyTicks(_Symbol,tick_array,COPY_TICKS_TRADE,atual*1000,tick_volume[i]);
      // Print("Volume ticks ",tick_volume[i]);
      ArraySetAsSeries(tick_array,true);
      int size=ArraySize(tick_array);
      //---
      if(copied>0)
        {
         // Print("Copiados ",copied);
         compra=0;
         venda=0;
         total=0;
         maximo=-10000000.0;
         minimo=10000000.0;

         for(int k=0;k<copied;k++)
           {
            MqlTick tick=tick_array[k];

            bool buy       = (tick.flags & TICK_FLAG_BUY    ) == TICK_FLAG_BUY && tick.last >= tick.ask;
            bool sell      = (tick.flags & TICK_FLAG_SELL    ) == TICK_FLAG_SELL && tick.last <= tick.bid;

            // bool buy       = (tick.flags & TICK_FLAG_BUY    ) == TICK_FLAG_BUY;
            //bool sell      = (tick.flags & TICK_FLAG_SELL    ) == TICK_FLAG_SELL;

            if(buy)
              {
               total=total+tick.volume;
               compra=compra+tick.volume;
              }
            if(sell)
              {
               total=total-tick.volume;
               venda+=tick.volume;
              }
            if(k==0) abertura=total;
            if(total>= maximo) maximo=total;
            if(total<=minimo) minimo=total;


           }

         ZeroMemory(tick_array);
        }
      else Print("Ticks could not be loaded. GetLastError()=",GetLastError());
      //   Print("Compra "+compra+" Venda "+venda);
      Volume_Open_Buffer[i]=abertura;
      Volume_High_Buffer[i]=maximo;
      Volume_Low_Buffer[i]=minimo;
      Volume_Close_Buffer[i]=total;
      //Print("Compra ",compra," Venda ",venda," Total ",compra+venda," Volume ",volume[i]);

     }

   return(rates_total);

  }
//+------------------------------------------------------------------+
