//+------------------------------------------------------------------+
//|                                              Didi_Index_Sign.mq5 |
//|                              Copyright © 2016, Rudinei Felipetto |
//|                                         http://www.conttinua.com |
//+------------------------------------------------------------------+
//--- àâòîðñòâî èíäèêàòîðà
#property copyright "Copyright © 2016, Rudinei Felipetto"
//--- ññûëêà íà ñàéò àâòîðà
#property link      "http://www.conttinua.com"
//--- íîìåð âåðñèè èíäèêàòîðà
#property version   "1.00"
//--- îòðèñîâêà èíäèêàòîðà â ãëàâíîì îêíå
#property indicator_chart_window 
//--- äëÿ ðàñ÷åòà è îòðèñîâêè èíäèêàòîðà èñïîëüçîâàíî äâà áóôåðà
#property indicator_buffers 2
//--- èñïîëüçîâàíî âñåãî äâà ãðàôè÷åñêèõ ïîñòðîåíèÿ
#property indicator_plots   2
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè ìåäâåæüåãî èíäèêàòîðà    |
//+----------------------------------------------+
//--- îòðèñîâêà èíäèêàòîðà 1 â âèäå ñèìâîëà
#property indicator_type1   DRAW_ARROW
//--- â êà÷åñòâå öâåòà ìåäâåæüåé ëèíèè èíäèêàòîðà èñïîëüçîâàí ðîçîâûé öâåò
#property indicator_color1  clrMagenta
//--- òîëùèíà ëèíèè èíäèêàòîðà 1 ðàâíà 4
#property indicator_width1  4
//--- îòîáðàæåíèå ìåäâåæüåé ìåòêè èíäèêàòîðà
#property indicator_label1  "Didi_Index Sell"
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè áû÷üåãî èíäèêàòîðà       |
//+----------------------------------------------+
//--- îòðèñîâêà èíäèêàòîðà 2 â âèäå ñèìâîëà
#property indicator_type2   DRAW_ARROW
//--- â êà÷åñòâå öâåòà áû÷üåé ëèíèè èíäèêàòîðà èñïîëüçîâàí çåëåíûé öâåò
#property indicator_color2  clrLime
//--- òîëùèíà ëèíèè èíäèêàòîðà 2 ðàâíà 4
#property indicator_width2  4
//--- îòîáðàæåíèå áû÷üåé ìåòêè èíäèêàòîðà
#property indicator_label2 "Didi_Index Buy"
//+----------------------------------------------+
//| Îáúÿâëåíèå êîíñòàíò                          |
//+----------------------------------------------+
#define RESET  0 // êîíñòàíòà äëÿ âîçâðàòà òåðìèíàëó êîìàíäû íà ïåðåñ÷åò èíäèêàòîðà
//+----------------------------------------------+
//| Âõîäíûå ïàðàìåòðû èíäèêàòîðà                 |
//+----------------------------------------------+
input uint      Curta=17;
input uint      Longa=48;
input ENUM_MA_METHOD MA_Method=MODE_SMA; // Ìåòîä óñðåäíåíèÿ èíäèêàòîðà
input ENUM_APPLIED_PRICE MA_Price=PRICE_CLOSE;// Öåíîâàÿ êîíñòàíòà
//+----------------------------------------------+
//--- îáúÿâëåíèå äèíàìè÷åñêèõ ìàññèâîâ, êîòîðûå â äàëüíåéøåì
//--- áóäóò èñïîëüçîâàíû â êà÷åñòâå èíäèêàòîðíûõ áóôåðîâ
double SellBuffer[];
double BuyBuffer[];
//---
int K,C_Handle,L_Handle,ATR_Handle,min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- èíèöèàëèçàöèÿ ãëîáàëüíûõ ïåðåìåííûõ 
   int ATR_Period=15;
   min_rates_total=int(MathMax(Curta,Longa));
   min_rates_total=MathMax(min_rates_total,ATR_Period)+1;
//--- ïîëó÷åíèå õåíäëà èíäèêàòîðà iMA Curta
   C_Handle=iMA(NULL,0,Curta,0,MA_Method,MA_Price);
   if(C_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà iMA Curta");
      return(INIT_FAILED);
     }
//--- ïîëó÷åíèå õåíäëà èíäèêàòîðà iMA Longa
   L_Handle=iMA(NULL,0,Longa,0,MA_Method,MA_Price);
   if(L_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà iMA Longa");
      return(INIT_FAILED);
     }
//--- ïîëó÷åíèå õåíäëà èíäèêàòîðà ATR
   ATR_Handle=iATR(NULL,0,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà ATR");
      return(INIT_FAILED);
     }
//--- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- ñèìâîë äëÿ èíäèêàòîðà
   PlotIndexSetInteger(0,PLOT_ARROW,170);
//--- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(SellBuffer,true);
//--- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- ñèìâîë äëÿ èíäèêàòîðà
   PlotIndexSetInteger(1,PLOT_ARROW,170);
//--- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(BuyBuffer,true);
//--- óñòàíîâêà ôîðìàòà òî÷íîñòè îòîáðàæåíèÿ èíäèêàòîðà
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- èìÿ äëÿ îêîí äàííûõ è ìåòêà äëÿ ïîäîêîí 
   string short_name="Didi_Index_Sig";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
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
//--- ïðîâåðêà êîëè÷åñòâà áàðîâ íà äîñòàòî÷íîñòü äëÿ ðàñ÷åòà
   if(BarsCalculated(ATR_Handle)<rates_total
      || BarsCalculated(C_Handle)<rates_total
      || BarsCalculated(L_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//--- îáúÿâëåíèÿ ëîêàëüíûõ ïåðåìåííûõ 
   int to_copy,limit,bar;
   double trend,Cur[],Lon[],ATR[];
   static double prev_trend;
//--- ðàñ÷åòû íåîáõîäèìîãî êîëè÷åñòâà êîïèðóåìûõ äàííûõ è
//--- ñòàðòîâîãî íîìåðà limit äëÿ öèêëà ïåðåñ÷åòà áàðîâ
   if(prev_calculated>rates_total || prev_calculated<=0)// ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷åòà èíäèêàòîðà
     {
      limit=rates_total-min_rates_total; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà âñåõ áàðîâ
      prev_trend=0;
     }
   else
     {
      limit=rates_total-prev_calculated; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà íîâûõ áàðîâ
     }
   to_copy=limit+1;
//--- êîïèðóåì âíîâü ïîÿâèâøèåñÿ äàííûå â ìàññèâû
   if(CopyBuffer(C_Handle,0,0,to_copy,Cur)<=0) return(RESET);
   if(CopyBuffer(L_Handle,0,0,to_copy,Lon)<=0) return(RESET);
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
//--- èíäåêñàöèÿ ýëåìåíòîâ â ìàññèâàõ êàê â òàéìñåðèÿõ  
   ArraySetAsSeries(Cur,true);
   ArraySetAsSeries(Lon,true);
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- îñíîâíîé öèêë ðàñ÷åòà èíäèêàòîðà
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      trend=Cur[bar]-Lon[bar];
      if(!trend) trend=prev_trend;
      //---
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---
      if(prev_trend<0 && trend>0) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
      if(prev_trend>0 && trend<0) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
      //---
      if(bar) prev_trend=trend;
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
