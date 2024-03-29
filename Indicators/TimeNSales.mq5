//+------------------------------------------------------------------+
//|                                                TimesAndSales.mqh |
//|                               Copyright © 2016, Evandro Teixeira |
//|                                   http://www.evandroteixeira.com | 
//+------------------------------------------------------------------+
#property copyright                 "Evandro Teixeira © 2016"
#property link                      "www.evandroteixeira.com"
#property version                   "3.60"
#property description               "Times and Sales"
#property indicator_plots 0
#property indicator_chart_window

//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include <comment.mqh>

//+------------------------------------------------------------------+
//| Global parameters                                                |
//+------------------------------------------------------------------+
int                     panelXX     =  4;
int                     panelYY     =  4;

input string                     _INPativo            = "INDV17";                  // Symbol
input int                        _INPvolHIGH          = 25;                       // Highlighted Volume
input color                      _INPbuyLetterTS      = clrForestGreen;          // Buy Color
input color                      _INPsellLetterTS     = clrFireBrick;           // Sell Color
input color                      _INPbuyHighL         = clrGold;               // Buy Highlighted Volume Color
input color                      _INPsellHighL        = clrDarkOrange;        // Sell Highlighted Volume Color
input color                      _INPbetweenTS        = clrSteelBlue;        // Spread Color
input color                      _INPchangeTickTS     = clrDimGray;         // Bid/Ask Color
input color                      _INPcolorDefaultB    = clrSilver;         // Window Border Color
input color                      _INPcolorDefault     = clrBlack;         // Window Color
input uchar                      _alpha               = 224;             // Window Transparency
input int                        _INPfsize            = 14;             // Font Size
input string                     _INPfont             = "Verdana";     // Font
input double                     _INPfontInterval     = 1;            // Font Interval
input int                        _INPticks            = 38;          // Number of Requested Ticks

CComment timesandsales;

color       clrAgr;

//+------------------------------------------------------------------+
//| On Init                                                          |
//+------------------------------------------------------------------+
int OnInit() 
  {
      timesandsales.Create("TimesNSales",panelXX,panelYY);
      //timesandsales.SetAutoColors(true);
      timesandsales.SetColor(_INPcolorDefaultB,_INPcolorDefault,_alpha);
      timesandsales.SetFont(_INPfont,_INPfsize,false,_INPfontInterval);
      timesandsales.SetGraphMode(true);
      timesandsales.SetText(0,"Waiting Update",_INPchangeTickTS);
      //(color)ChartGetInteger(0,CHART_COLOR_BACKGROUND)

//--- Define frequência do timer
   EventSetTimer(1);
   return(0);
  }

//+------------------------------------------------------------------+
//| On DeInit                                                        |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Destroy panel
   timesandsales.Destroy();
  }
//+------------------------------------------------------------------+
//| On Calculate                                                     |
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
//--- requesting ticks
   MqlTick tick_array[];
   int copied=CopyTicks(_INPativo,tick_array,COPY_TICKS_TRADE,0,_INPticks);
   ArraySetAsSeries(tick_array,true);
   
   string typeTrade;
//---

   if(copied>0)
     {
         for(int i=0;i<_INPticks;i++)
            {
               MqlTick tick   = tick_array[i];
               bool buy       = tick.flags == 24 && tick.last >= tick.ask;
               bool sell      = tick.flags == 24 && tick.last <= tick.bid;
               bool between   = tick.flags == 24 && tick.last < tick.ask && tick.last > tick.bid;

               if(buy)
                  {
                     typeTrade = "BUY "; if(tick.volume >= (double)_INPvolHIGH) clrAgr = _INPbuyHighL; else clrAgr = _INPbuyLetterTS;
                  }
               else if(sell)
                     {
                        typeTrade = "SELL"; if(tick.volume >= (double)_INPvolHIGH) clrAgr = _INPsellHighL; else clrAgr = _INPsellLetterTS;
                     }
                     else if(between)
                            {
                                 typeTrade = "SPR "; clrAgr = _INPbetweenTS;
                            }
                            else
                                {
                                    typeTrade = "        "; clrAgr = _INPchangeTickTS;
                                }

               timesandsales.SetText(i,TimeToString(tick.time,TIME_MINUTES|TIME_SECONDS)+"    "+
                                  DoubleToString(tick.last,Digits())+"    "+
                                  typeTrade+"    "+
                                  IntegerToString(tick.volume,1,'0'),clrAgr);

            }
            timesandsales.SetText(_INPticks,"",_INPchangeTickTS);
            timesandsales.Show();
            ZeroMemory(tick_array);
     }
   else // report an error that occurred when receiving ticks
     {
         timesandsales.SetText(0,"Waiting for update or",_INPchangeTickTS);
         timesandsales.SetText(1,"data could not be loaded (CHECK EXPERT TAB)",_INPchangeTickTS);
         timesandsales.SetText(2," ",_INPchangeTickTS);
         timesandsales.Show();
         //Print("Ticks could not be loaded. GetLastError()=",GetLastError());
     }

//---
      return(rates_total);
  }

//+------------------------------------------------------------------+
//| On Chart Event                                                   |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {

   int res=timesandsales.OnChartEvent(id,lparam,dparam,sparam);
//--- move panel event
   if(res==EVENT_MOVE)
      return;
//--- change background color
   if(res==EVENT_CHANGE)
      timesandsales.Show();
  }
//+------------------------------------------------------------------+
