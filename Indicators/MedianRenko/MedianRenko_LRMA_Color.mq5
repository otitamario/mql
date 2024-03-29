//+------------------------------------------------------------------+
//|                                                         LRMA.mq5 |
//|                                            Copyright 2014, Vinin |
//|                                                    vinin@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, Vinin"
#property link      "vinin@mail.ru"
#property version   "1.00"
#property description "Ëèíåéíàÿ ðåãðåññèÿ ÿâëÿåòñÿ ñòàòèñòè÷åñêèì èíñòðóìåíòîì, èñïîëüçóåìûì äëÿ"
#property description "ïðîãíîçèðîâàíèÿ áóäóùèõ öåí èñõîäÿ èç ïðîøëûõ äàííûõ. Èñïîëüçóåòñÿ ìåòîä "
#property description "íàèìåíüøèõ êâàäðàòîâ äëÿ ïîñòðîåíèÿ «íàèáîëåå ïîäõîäÿùåé» ïðÿìîé ëèíèè "
#property description "÷åðåç ðÿä òî÷åê öåíîâûõ çíà÷åíèé. Â êà÷åñòâå âõîäíûõ ïàðàìåòðîâ èñïîëüçóåòñÿ "
#property description "êîëè÷åñòâî ðàñ÷åòíûõ áàðîâ (ñâå÷åé). Äàííûé èíäèêàòîð õîðîøî èñïîëüçîâàòü äëÿ ðó÷íîé òîðãîâëè"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot LRMA
#property indicator_label1  "LRMA"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrYellow,clrLime,clrRed,C'0,0,0',C'0,0,0',C'0,0,0',C'0,0,0',C'0,0,0'
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- input parameters
input int      LRMAPeriod=14; // Period LRMA
//--- indicator buffers
double         LRMABuffer[];
double         LRMAColors[];

#include <AZ-INVEST/SDK/MedianRenkoIndicator.mqh>
MedianRenkoIndicator medianRenkoIndicator;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,LRMABuffer,INDICATOR_DATA);
   SetIndexBuffer(1,LRMAColors,INDICATOR_COLOR_INDEX);
   ArraySetAsSeries(LRMABuffer,true);
   ArraySetAsSeries(LRMAColors,true);
//---
   return(INIT_SUCCEEDED);
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

   if(!medianRenkoIndicator.OnCalculate(rates_total,prev_calculated,time))
      return(0);
   int _prev_calculated=medianRenkoIndicator.GetPrevCalculated();

//---
   if(rates_total<=LRMAPeriod) return(0);
   ArraySetAsSeries(medianRenkoIndicator.Close,true);
   int limit1=rates_total-_prev_calculated;
   int limit2=limit1;
   if(limit1>1)
     {
      limit1=rates_total-LRMAPeriod-1;
      limit2=limit1-1;
     }
   for(int pos=limit1;pos>=0;pos--)
     {
      LRMABuffer[pos]=LRMA(pos,LRMAPeriod,medianRenkoIndicator.Close);
      LRMAColors[pos]=0;
     }
   for(int pos=limit2;pos>=0;pos--)
     {
      if(LRMABuffer[pos]>LRMABuffer[pos+1])
        {
         LRMAColors[pos]=1;
         LRMAColors[pos+1]=1;
        }
      else if(LRMABuffer[pos]<LRMABuffer[pos+1])
        {
         LRMAColors[pos]=2;
         LRMAColors[pos+1]=2;
        }
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+\\
// Calculate LRMA
//+------------------------------------------------------------------+\\

double LRMA(const int pos,const int period,const double  &price[])
  {
   double Res=0;
   double tmpS=0,tmpW=0,wsum=0;;
   for(int i=0;i<period;i++)
     {
      tmpS+=price[pos+i];
      tmpW+=price[pos+i]*(period-i);
      wsum+=(period-i);
     }
   tmpS/=period;
   tmpW/=wsum;
   Res=3.0*tmpW-2.0*tmpS;

   return(Res);
  }
//+------------------------------------------------------------------+
