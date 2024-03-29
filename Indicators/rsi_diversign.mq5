//+------------------------------------------------------------------+
//|                                                RSI_DiverSign.mq5 | 
//|                                       Copyright © 2015, olegok83 | 
//|                           https://www.mql5.com/ru/users/olegok83 | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2015, olegok83"
#property link "https://www.mql5.com/ru/users/olegok83"
//--- íîìåð âåðñèè èíäèêàòîðà
#property version   "1.00"
//--- îòðèñîâêà èíäèêàòîðà â ãëàâíîì îêíå
#property indicator_chart_window 
//--- äëÿ ðàñ÷åòà è îòðèñîâêè èíäèêàòîðà èñïîëüçîâàíî äâà áóôåðà
#property indicator_buffers 2
//--- èñïîëüçîâàíî äâà ãðàôè÷åñêèõ ïîñòðîåíèÿ
#property indicator_plots   2
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè ìåäâåæüåãî èíäèêàòîðà    |
//+----------------------------------------------+
//--- îòðèñîâêà èíäèêàòîðà 1 â âèäå ñèìâîëà
#property indicator_type1   DRAW_ARROW
//--- â êà÷åñòâå öâåòà ìåäâåæüåé ëèíèè èíäèêàòîðà èñïîëüçîâàí Tomato öâåò
#property indicator_color1  clrTomato
//--- òîëùèíà ëèíèè èíäèêàòîðà 1 ðàâíà 4
#property indicator_width1  4
//--- îòîáðàæåíèå áû÷åé ìåòêè èíäèêàòîðà
#property indicator_label1  "RSI_DiverSign Sell"
//+----------------------------------------------+
//| Ïàðàìåòðû îòðèñîâêè áû÷üãî èíäèêàòîðà        |
//+----------------------------------------------+
//--- îòðèñîâêà èíäèêàòîðà 2 â âèäå ñèìâîëà
#property indicator_type2   DRAW_ARROW
//--- â êà÷åñòâå öâåòà áû÷åé ëèíèè èíäèêàòîðà èñïîëüçîâàí DarkTurquoise öâåò
#property indicator_color2  clrDarkTurquoise
//--- òîëùèíà ëèíèè èíäèêàòîðà 2 ðàâíà 4
#property indicator_width2  4
//--- îòîáðàæåíèå ìåäâåæüåé ìåòêè èíäèêàòîðà
#property indicator_label2 "RSI_DiverSign Buy"
//+-----------------------------------+
//| îáúÿâëåíèå êîíñòàíò               |
//+-----------------------------------+
#define RESET  0 // Êîíñòàíòà äëÿ âîçâðàòà òåðìèíàëó êîìàíäû íà ïåðåñ÷åò èíäèêàòîðà
//+-----------------------------------+
//| Âõîäíûå ïàðàìåòðû èíäèêàòîðà      |
//+-----------------------------------+
input uint iPeriod1=9;                            // Ïåðèîä áûñòðîãî èíäèêàòîðà
input ENUM_APPLIED_PRICE   RSIPrice1=PRICE_CLOSE; // Öåíà áûñòðîãî èíäèêàòîðà
input uint iPeriod2=14;                            // Ïåðèîä ìåäëåíîãî èíäèêàòîðà
input ENUM_APPLIED_PRICE   RSIPrice2=PRICE_CLOSE; // Öåíà ìåäëåíîãî èíäèêàòîðà
input int Shift=0;                                // Ñäâèã èíäèêàòîðà ïî ãîðèçîíòàëè â áàðàõ
//+-----------------------------------+
//--- îáúÿâëåíèå äèíàìè÷åñêèõ ìàññèâîâ, êîòîðûå â äàëüíåéøåì
//--- áóäóò èñïîëüçîâàíû â êà÷åñòâå èíäèêàòîðíûõ áóôåðîâ
double SellBuffer[],BuyBuffer[];
//--- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ äëÿ õåíäëîâ èíäèêàòîðîâ
int ATR_Handle,Ind_Handle1,Ind_Handle2;
//--- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
int min_rates_total,min_rates_;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- èíèöèàëèçàöèÿ ãëîáàëüíûõ ïåðåìåííûõ 
   int ATR_Period=10;
//--- èíèöèàëèçàöèÿ ïåðåìåííûõ íà÷àëà îòñ÷åòà äàííûõ
   min_rates_=int(MathMax(iPeriod1,iPeriod2));
   min_rates_total=min_rates_+int(MathMax(iPeriod1,iPeriod2))+5;
   min_rates_total=int(MathMax(min_rates_total,ATR_Period));
//--- ïîëó÷åíèå õåíäëà èíäèêàòîðà ATR
   ATR_Handle=iATR(Symbol(),PERIOD_CURRENT,ATR_Period);
   if(ATR_Handle==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà ATR");
      return(INIT_FAILED);
     }
//--- ïîëó÷åíèå õåíäëà èíäèêàòîðà RSI1
   Ind_Handle1=iRSI(Symbol(),PERIOD_CURRENT,iPeriod1,RSIPrice1);
   if(Ind_Handle1==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà RSI1");
      return(INIT_FAILED);
     }
//--- ïîëó÷åíèå õåíäëà èíäèêàòîðà RSI2
   Ind_Handle2=iRSI(Symbol(),PERIOD_CURRENT,iPeriod2,RSIPrice2);
   if(Ind_Handle2==INVALID_HANDLE)
     {
      Print(" Íå óäàëîñü ïîëó÷èòü õåíäë èíäèêàòîðà RSI2");
      return(INIT_FAILED);
     }
//--- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(0,SellBuffer,INDICATOR_DATA);
//--- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà 1
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//--- ñèìâîë äëÿ èíäèêàòîðà
   PlotIndexSetInteger(0,PLOT_ARROW,174);
//--- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà 1 ïî ãîðèçîíòàëè
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//--- óñòàíîâêà çíà÷åíèé èíäèêàòîðà, êîòîðûå íå áóäóò âèäèìû íà ãðàôèêå
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//--- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(SellBuffer,true);
//--- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â èíäèêàòîðíûé áóôåð
   SetIndexBuffer(1,BuyBuffer,INDICATOR_DATA);
//--- îñóùåñòâëåíèå ñäâèãà íà÷àëà îòñ÷åòà îòðèñîâêè èíäèêàòîðà 2
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//--- ñèìâîë äëÿ èíäèêàòîðà
   PlotIndexSetInteger(1,PLOT_ARROW,174);
//--- îñóùåñòâëåíèå ñäâèãà èíäèêàòîðà 1 ïî ãîðèçîíòàëè
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
//--- óñòàíîâêà çíà÷åíèé èíäèêàòîðà, êîòîðûå íå áóäóò âèäèìû íà ãðàôèêå
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//--- èíäåêñàöèÿ ýëåìåíòîâ â áóôåðå êàê â òàéìñåðèè
   ArraySetAsSeries(BuyBuffer,true);
//--- èíèöèàëèçàöèè ïåðåìåííîé äëÿ êîðîòêîãî èìåíè èíäèêàòîðà
   string shortname="RSI_DiverSign";
//--- ñîçäàíèå èìåíè äëÿ îòîáðàæåíèÿ â îòäåëüíîì ïîäîêíå è âî âñïëûâàþùåé ïîäñêàçêå
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- îïðåäåëåíèå òî÷íîñòè îòîáðàæåíèÿ çíà÷åíèé èíäèêàòîðà
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- çàâåðøåíèå èíèöèàëèçàöèè
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // êîëè÷åñòâî èñòîðèè â áàðàõ íà òåêóùåì òèêå
                const int prev_calculated,// êîëè÷åñòâî èñòîðèè â áàðàõ íà ïðåäûäóùåì òèêå
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
      || BarsCalculated(Ind_Handle1)<rates_total
      || BarsCalculated(Ind_Handle2)<rates_total
      || rates_total<min_rates_total) return(RESET);
//--- îáúÿâëåíèå ïåðåìåííûõ ñ ïëàâàþùåé òî÷êîé  
   double Ind1[],Ind2[],ATR[];
//--- îáúÿâëåíèå öåëî÷èñëåííûõ ïåðåìåííûõ è ïîëó÷åíèå óæå ïîäñ÷èòàííûõ áàðîâ
   int to_copy,limit,bar;
//--- ðàñ÷åò ñòàðòîâîãî íîìåðà limit äëÿ öèêëà ïåðåñ÷åòà áàðîâ
   if(prev_calculated>rates_total || prev_calculated<=0)// ïðîâåðêà íà ïåðâûé ñòàðò ðàñ÷åòà èíäèêàòîðà
     {
      limit=rates_total-min_rates_total-1; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà âñåõ áàðîâ
     }
   else limit=rates_total-prev_calculated; // ñòàðòîâûé íîìåð äëÿ ðàñ÷åòà íîâûõ áàðîâ
//---
   to_copy=limit+1;
//--- èíäåêñàöèÿ ýëåìåíòîâ â ìàññèâàõ, êàê â òàéìñåðèÿõ  
   ArraySetAsSeries(ATR,true);
   ArraySetAsSeries(Ind1,true);
   ArraySetAsSeries(Ind2,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
//--- êîïèðóåì âíîâü ïîÿâèâøèåñÿ äàííûå â ìàññèâû
   if(CopyBuffer(ATR_Handle,0,0,to_copy,ATR)<=0) return(RESET);
   to_copy+=4;
   if(CopyBuffer(Ind_Handle1,0,0,to_copy,Ind1)<=0) return(RESET);
   if(CopyBuffer(Ind_Handle2,0,0,to_copy,Ind2)<=0) return(RESET);
//--- îñíîâíîé öèêë ðàñ÷åòà èíäèêàòîðà
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      BuyBuffer[bar]=0.0;
      SellBuffer[bar]=0.0;
      //---      
      if(SellCheck(open,close,bar))
         if(Ind1[bar+4]<Ind1[bar+3] && Ind1[bar+3]>Ind1[bar+2] && Ind1[bar+2]<Ind1[bar+1])
            if(Ind2[bar+4]<Ind2[bar+3] && Ind2[bar+3]>Ind2[bar+2] && Ind2[bar+2]<Ind2[bar+1])
              {
               if((Ind1[bar+3]>Ind1[bar+1] && Ind2[bar+3]<Ind2[bar+1])
                  || (Ind1[bar+3]<Ind1[bar+1] && Ind2[bar+3]>Ind2[bar+1])) SellBuffer[bar]=high[bar]+ATR[bar]*3/8;
              }
      //---  
      if(BuyCheck(open,close,bar))
         if(Ind1[bar+4]>Ind1[bar+3] && Ind1[bar+3]<Ind1[bar+2] && Ind1[bar+2]>Ind1[bar+1])
            if(Ind2[bar+4]>Ind2[bar+3] && Ind2[bar+3]<Ind2[bar+2] && Ind2[bar+2]>Ind2[bar+1])
              {
               if((Ind1[bar+3]>Ind1[bar+1] && Ind2[bar+3]<Ind2[bar+1])
                  || (Ind1[bar+3]<Ind1[bar+1] && Ind2[bar+3]>Ind2[bar+1])) BuyBuffer[bar]=low[bar]-ATR[bar]*3/8;
              }
     }
//---     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Ïðîâåðêà íà íàëè÷èå êðàñíîé ñâå÷è ìåæäó çåëåíûìè ñâå÷êàìè        |
//+------------------------------------------------------------------+  
bool SellCheck(const double &Open[],const double &Close[],int index)
  {
//--- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â öâåòîâîé èíäåêñíûé áóôåð   
   if(Open[index+3]<Close[index+3] && Open[index+2]>Close[index+2] && Open[index+1]<Close[index+1]) return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+
//| Ïðîâåðêà íà íàëè÷èå çåëåíîé ñâå÷è ìåæäó êðàñíûìè ñâå÷êàìè        |
//+------------------------------------------------------------------+  
bool BuyCheck(const double &Open[],const double &Close[],int index)
  {
//--- ïðåâðàùåíèå äèíàìè÷åñêîãî ìàññèâà â öâåòîâîé èíäåêñíûé áóôåð   
   if(Open[index+3]>Close[index+3] && Open[index+2]<Close[index+2] && Open[index+1]>Close[index+1]) return(true);
//---
   return(false);
  }
//+------------------------------------------------------------------+