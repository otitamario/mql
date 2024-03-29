//+------------------------------------------------------------------+

#property copyright "r"
#property link ""
#property description ""
//---- íîìåð âåðñèè èíäèêàòîðà
#property version   "1.00"
//---- îòðèñîâêà èíäèêàòîðà â ãëàâíîì îêíå
#property indicator_chart_window
//---- äëÿ ðàñ÷åòà è îòðèñîâêè èíäèêàòîðà èñïîëüçîâàíî ïÿòü áóôåðîâ
#property indicator_buffers 5
//---- èñïîëüçîâàíî âñåãî îäíî ãðàôè÷åñêîå ïîñòðîåíèå
#property indicator_plots   1
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè èíäèêàòîðà               |
//+----------------------------------------------+
//---- â êà÷åñòâå èíäèêàòîðà èñïîëüçîâàíû öâåòíûå ñâå÷è
#property indicator_type1   DRAW_COLOR_CANDLES
#property indicator_color1   clrAzure,clrBlue,clrDarkSeaGreen,clrRed,clrYellow,clrAzure
//---- îòîáðàæåíèå ìåòêè èíäèêàòîðà
#property indicator_label1  "CandlesticksBW/Open;High;Low;Close"
//+----------------------------------------------+
//| Îáúÿâëåíèå êîíñòàíò                          |
//+----------------------------------------------+
#define RESET  0 // êîíñòàíòà äëÿ âîçâðàòà òåðìèíàëó êîìàíäû íà ïåðåñ÷åò èíäèêàòîðà
//+----------------------------------------------+
//| Âõîäíûå ïàðàìåòðû èíäèêàòîðà                 |
//+----------------------------------------------+

//+----------------------------------------------+
//---- îáúÿâëåíèå äèíàìè÷åñêèõ ìàññèâîâ, êîòîðûå áóäóò â 
//---- äàëüíåéøåì èñïîëüçîâàíû â êà÷åñòâå èíäèêàòîðíûõ áóôåðîâ
double ExtOpenBuffer[];
double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtCloseBuffer[];
double ExtColorBuffer[];
//---- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
int min_rates_total;
//---- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ äëÿ õåíäëîâ èíäèêàòîðîâ
int AC_Handle,AO_Handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//---- èíèöèàëèçàöèÿ ãëîáàëüíûõ ïåðåìåííûõ 
   min_rates_total=34+2;
//---- ïîëó÷åíèå õåíäëà èíäèêàòîðà   Awesome oscillator 
   AO_Handle=iAO(Symbol(),PERIOD_CURRENT);
   if(AO_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà   Awesome oscillator");
      return(INIT_FAILED);
     }
//---- ïîëó÷åíèå õåíäëà èíäèêàòîðà  Accelerator Oscillator 
   AC_Handle=iAC(Symbol(),PERIOD_CURRENT);
   if(AC_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà  Accelerator Oscillator");
      return(INIT_FAILED);
     }

//---- ïðåâðàùåíèå äèíàìè÷åñêèõ ìàññèâîâ â èíäèêàòîðíûå áóôåðû
   SetIndexBuffer(0,ExtOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ExtCloseBuffer,INDICATOR_DATA);
//---- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â öâåòîâîé, èíäåêñíûé áóôåð   
   SetIndexBuffer(4,ExtColorBuffer,INDICATOR_COLOR_INDEX);
//---- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðàõ êàê â òàéìñåðèÿõ
   ArraySetAsSeries(ExtOpenBuffer,true);
   ArraySetAsSeries(ExtHighBuffer,true);
   ArraySetAsSeries(ExtLowBuffer,true);
   ArraySetAsSeries(ExtCloseBuffer,true);
   ArraySetAsSeries(ExtColorBuffer,true);
//---- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà 1
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,min_rates_total);
//---- óñòàíîâêà ôîðìàòà òî÷íîñòè îòîáðàæåíèÿ èíäèêàòîðà
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- èìÿ äëÿ îêîí äàííûõ è ìåòêà äëÿ ñóáúîêîí 
   string short_name="CandlesticksBW";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//--- çàâåðøåíèå èíèöèàëèçàöèè
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
//---- ïðîâåðêà êîëè÷åñòâà áàðîâ íà äîñòàòî÷íîñòü äëÿ ðàñ÷åòà
   if(BarsCalculated(AO_Handle)<rates_total
      || BarsCalculated(AC_Handle)<rates_total
      || rates_total<min_rates_total)
      return(RESET);
//---- îáúÿâëåíèÿ ëîêàëüíûõ ïåðåìåííûõ 
   int to_copy,limit,bar;
   double AO[],AC[];
//---- ðàñ÷åòû íåîáõîäèìîãî êîëè÷åñòâà êîïèðóåìûõ äàííûõ è ñòàðòîâîãî íîìåðà limit äëÿ öèêëà ïåðåñ÷åòà áàðîâ
   if(prev_calculated>rates_total || prev_calculated<=0)// ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷åòà èíäèêàòîðà
     {
      limit=rates_total-min_rates_total-1; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà âñåõ áàðîâ
     }
   else
     {
      limit=rates_total-prev_calculated; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà íîâûõ áàðîâ
     }
//---
   to_copy=limit+1;
//---- êîïèðóåì âíîâü ïîÿâèâøèåñÿ äàííûå â ìàññèâû
   if(CopyOpen(Symbol(),PERIOD_CURRENT,0,to_copy,ExtOpenBuffer)<=0) return(RESET);
   if(CopyHigh(Symbol(),PERIOD_CURRENT,0,to_copy,ExtHighBuffer)<=0) return(RESET);
   if(CopyLow(Symbol(),PERIOD_CURRENT,0,to_copy,ExtLowBuffer)<=0) return(RESET);
   if(CopyClose(Symbol(),PERIOD_CURRENT,0,to_copy,ExtCloseBuffer)<=0) return(RESET);
   to_copy++;
   if(CopyBuffer(AO_Handle,0,0,to_copy,AO)<=0) return(RESET);
   if(CopyBuffer(AC_Handle,0,0,to_copy,AC)<=0) return(RESET);

//---- èíäåêñàöèÿ ýëåìåíòîâ â ìàññèâàõ êàê â òàéìñåðèÿõ  
   ArraySetAsSeries(AO,true);
   ArraySetAsSeries(AC,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);

//---- îñíîâíîé öèêë èñïðàâëåíèÿ è îêðàøèâàíèÿ ñâå÷åé
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      int clr;
      
      if(AO[bar]>=AO[bar+1] && AC[bar]>=AC[bar+1])
        {
         if(open[bar]<=close[bar]) clr=0;
         else clr=1;
        }
      else
      if(AO[bar]<=AO[bar+1] && AC[bar]<=AC[bar+1])
        {
         if(open[bar]>=close[bar]) clr=5;
         else clr=4;
        }
      else
        {
         if(open[bar]<=close[bar]) clr=2;
         else clr=3;        
        }
      ExtColorBuffer[bar]=clr;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
