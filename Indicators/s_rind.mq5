//+------------------------------------------------------------------+
//|                                                      s_r_ind.mq5 |
//|                                                         Shion.bd |
//|                                            https://investmany.ru |
//+------------------------------------------------------------------+
#property copyright "Shion.bd"
#property link      "https://investmany.ru"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot support
#property indicator_label1  "support"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot resistance
#property indicator_label2  "resistance"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrMediumBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- indicator buffers
double         supportBuffer[];
double         resistanceBuffer[];
double K,B;
int Dig;
//---
input uchar Period_RSI=8;     // RSI period 
input int Analyze_Bars= 300;  // How many bars in history to analyze 
input double Low_RSI = 35.0;  // Lower RSI level for finding extremum 
input double High_RSI= 65.0;  // Higher RSI level for finding extremum 
input float Distans=13.0;     // Deviation of RSI level 
ENUM_TIMEFRAMES Period_Trade; // Period of chart
string Trade_Symbol;          // Symbol
bool First_Ext;               // Type of first extremum 
int h_RSI; // Handle of RSI indicator
int Bars_H; // Number of bars for analysis
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct st_Bars //structure initialization
  {
   int               Bar_1;
   int               Bar_2;
   int               Bar_3;
   int               Bar_4;
  };
st_Bars Bars_Ext; // declaration of structure type variable 
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Trade_Symbol=Symbol();
   Period_Trade=Period();
   Dig=(int)SymbolInfoInteger(Trade_Symbol,SYMBOL_DIGITS);//number of decimal places in current symbol
//--- indicator buffers mapping
   SetIndexBuffer(0,supportBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,resistanceBuffer,INDICATOR_DATA);
   h_RSI=iRSI(Trade_Symbol,Period_Trade,Period_RSI,PRICE_CLOSE); //return handle of RSI indicator
   if(h_RSI<0) Print("Incorrect handle of RSI ");
   if(Analyze_Bars>Bars(Trade_Symbol,Period_Trade)) //if less bars in history for analysis,
     {
      Print("The history of the less",Analyze_Bars,"bar"); // than specified in bars parameter, then you need to tell this
      Bars_H=Bars(Trade_Symbol,Period_Trade);
      Print("Number of bars in history = ",Bars_H);
     }
   else
     {
      Bars_H=Analyze_Bars;
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(h_RSI); // remove handle at deinitialization  
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
   ArraySetAsSeries(supportBuffer,true);
   ArraySetAsSeries(resistanceBuffer,true);
   Bars_Ext.Bar_1=Ext_1(Low_RSI,High_RSI,Bars_H,h_RSI,Trade_Symbol,
                        Distans,Period_Trade); // find bar index of first extremum 
   if(Bars_Ext.Bar_1<0)
     {
      Print("Insufficient bars in history for analysis");
      return(0);
     }
   if(Bars_Ext.Bar_1>0) First_Ext=One_ext(Bars_Ext,Trade_Symbol,h_RSI,Low_RSI,Period_Trade);
   Bars_Ext.Bar_2=Ext_2(Low_RSI,High_RSI,Bars_H,h_RSI,Trade_Symbol,
                        Bars_Ext,2,Distans,First_Ext,Period_Trade); // find bar index of second extremum 
   if(Bars_Ext.Bar_2<0)
     {
      Print("Insufficient bars in history for analysis");
      return(0);
     }
   Bars_Ext.Bar_3=Ext_2(Low_RSI,High_RSI,Bars_H,h_RSI,Trade_Symbol,
                        Bars_Ext,3,Distans,First_Ext,Period_Trade); // find bar index of third extremum 
   if(Bars_Ext.Bar_3<0)
     {
      Print("Insufficient bars in history for analysis");
      return(0);
     }
   Bars_Ext.Bar_4=Ext_2(Low_RSI,High_RSI,Bars_H,h_RSI,Trade_Symbol,
                        Bars_Ext,4,Distans,First_Ext,Period_Trade); // find bar index of last extremum 
   if(Bars_Ext.Bar_4<0)
     {
      Print("Insufficient bars in history for analysis");
      return(0);
     }
   Level(true,First_Ext,Bars_Ext,Trade_Symbol,Period_Trade); // get coefficients k and b for resistance line 
   for(int i=0;i<Bars_H;i++)
     {
      resistanceBuffer[i]=NormalizeDouble(K*i+B,Dig);
     }
   Level(false,First_Ext,Bars_Ext,Trade_Symbol,Period_Trade); // get coefficients k and b for support line
   for(int i=0;i<Bars_H;i++)
     {
      supportBuffer[i]=NormalizeDouble(K*i+B,Dig);
     }
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Level(bool _line,              // parameter that defines resistance/support line, which coefficients have to be found
           bool _first_ext,         // type of first extremum (already familiar to you)
           st_Bars  &bars_ext,      // structure that contains bar indexes
           string _symbol,          // symbol
           ENUM_TIMEFRAMES _period) // period of chart
  {
   int bars=Bars_H; // number of analyzed bars
   double m_high[],m_low[]; // initialization of arrays
   ArraySetAsSeries(m_high,true); // arrays are indexed from first element
   ArraySetAsSeries(m_low,true);
   int h_high = CopyHigh (_symbol,_period, 0, bars, m_high); //fill array of High candle prices
   int h_low = CopyLow(_symbol, _period, 0, bars, m_low);    //fill array of Low candle prices
   double price_1,price_2;
   int _bar1,_bar2;
   int digits=(int)SymbolInfoInteger(_symbol,SYMBOL_DIGITS);//number of decimal places in current symbol
   if(_line==true) // if resistance line is required
     {
      if(_first_ext==true) // if first extremum is maximum
        {
         price_1 = NormalizeDouble(m_high[bars_ext.Bar_1], digits);
         price_2 = NormalizeDouble(m_high[bars_ext.Bar_3], digits);
         _bar1 = bars_ext.Bar_1;
         _bar2 = bars_ext.Bar_3;
        }
      else                                                  //if minimum
        {
         price_1 = NormalizeDouble(m_high[bars_ext.Bar_2], digits);
         price_2 = NormalizeDouble(m_high[bars_ext.Bar_4], digits);
         _bar1 = bars_ext.Bar_2;
         _bar2 = bars_ext.Bar_4;
        }
     }
   else                                                     //if support line is required
     {
      if(_first_ext==true) // if first extremum is maximum
        {
         price_1 = NormalizeDouble(m_low[bars_ext.Bar_2], digits);
         price_2 = NormalizeDouble(m_low[bars_ext.Bar_4], digits);
         _bar1 = bars_ext.Bar_2;
         _bar2 = bars_ext.Bar_4;
        }
      else                                                  //if minimum
        {
         price_1 = NormalizeDouble(m_low[bars_ext.Bar_1], digits);
         price_2 = NormalizeDouble(m_low[bars_ext.Bar_3], digits);
         _bar1 = bars_ext.Bar_1;
         _bar2 = bars_ext.Bar_3;
        }
     }
   K=(price_2-price_1)/(_bar2-_bar1);  //find coefficient K
   B=price_1-K*_bar1;                  //find coefficient B
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Ext_1 (double low,        //lower RSI level, oversold level
           double high,       //higher RSI level, overbought level
           int bars,          //number of analyzed bars, to avoid copying unnecessary data into arrays 
                              //possible to set bars = 300
           int h_rsi,         //handle of RSI indicator 
           string symbol,     //symbol of chart
           float distans,     //distance for deviation of one of indicator levels
                              // allows to define search boundaries of first bar - extremum
           ENUM_TIMEFRAMES period_trade) //period of chart
  {
   double m_rsi[],m_high[],m_low[]; // initialization of arrays
   ArraySetAsSeries(m_rsi,true); // arrays are indexed from first element
   ArraySetAsSeries(m_high,true);
   ArraySetAsSeries(m_low,true);
   int h_high = CopyHigh (symbol,period_trade, 0, bars, m_high); //fill array of High candle prices
   int h_low = CopyLow(symbol, period_trade, 0, bars, m_low);    //fill array of Low candle prices
   if(CopyBuffer (h_rsi,0,0, bars, m_rsi) <bars)                 //fill array with indicator RSI data
     {
      Print("Failed to copy indicator buffer!");
     }
   int index_bar= -1; // initialization of variable that will contain index of desired bar
   bool flag = false; // this variable is needed to avoid analyzing candles on current unfinished trend
   bool ext_max=true; // variables of bool type are used to stop bar analysis at the right moment 
   bool ext_min= true;
   double min=100000.0; // variables to identify maximum and minimum prices
   double max= 0.0;
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);//number of decimal places in current symbol
   for(int i=0; i<bars;i++) //bar loop
     {
      double rsi=m_rsi[i]; // get RSI indicator value 
      double price_max = NormalizeDouble(m_high[i], digits);   //High prices
      double price_min = NormalizeDouble(m_low[i], digits);    //Low prices of selected bar
      if(flag==false) // condition to avoid searching for extremum on incomplete trend 
        {
         if(rsi<=low || rsi>=high) //if first bars in overbought zones or oversold zones,
            continue; // then move to next bar
         else flag=true;       //if not, proceed with analysis
        }
      if(rsi<low) //if found crossing of RSI with low level
        {
         if(ext_min==true) // if RSI hasn't crossed high level
           {
            if(ext_max==true) // if searching for maximum extremum hasn't been disabled yet,
              {
               ext_max=false; // then disable searching for maximum extremum
               if(distans>=0) high=high-distans; //change high level, on which then
              }                                  //second bar search  will be executed 
            if(price_min<min) //search and memorise first bar index
              {// comparing Low candle prices
               min=price_min;
               index_bar=i;
              }
           }
         else break; /*Exit loop since searching for minimum extremum is already prohibited,
         it means the maximum is found*/
        }
      if(rsi>high) //further, algorithm is the same, only in search for maximum extremum
        {
         if(ext_max==true)
           {
            if(ext_min==true)
              {
               ext_min=false; //if necessary, disable searching for minimum extremum 
               if(distans>=0) low=low+distans;
              }
            if(price_max>max) //search and memorize extremum
              {
               max=price_max;
               index_bar=i;
              }
           }
         else break; /*Exit loop since maximum extremum search is disabled,
         then minimum is found*/
        }
     }
   return(index_bar);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Ext_2(double low,    //low RSI level, oversold level
          double high,   //high RSI level, overbought level
          int bars,      //number of analyzed bars, to avoid copying unnecessary data into arrays
                         //possible to set bars = 300
          int h_rsi,     //handle of RSI indicator
          string symbol, //symbol of chart
          st_Bars  &bars_ext,// structure containing codes of found bars
          char n_bar,     // ordinal number of bar required to find (2, 3 or 4)
          float distans,  // distance for deviation of one of indicator levels
          bool first_ext, // type of first bar
          ENUM_TIMEFRAMES period_trade)//period of chart
  {
   double m_rsi[],m_high[],m_low[]; // initialization of arrays
   ArraySetAsSeries(m_rsi,true); // arrays are indexed from first element
   ArraySetAsSeries(m_high,true);
   ArraySetAsSeries(m_low,true);
   int h_high= CopyHigh(symbol,period_trade,0,bars,m_high);    //fill array of High price candles
   int h_low = CopyLow(symbol, period_trade, 0, bars, m_low);  //fill arrays of Low price candles
   if(CopyBuffer(h_rsi,0,0,bars,m_rsi)<bars)                   //fill arrays with RSI indicator data
     {
      Print("Failed to copy indicator buffer!");
      //return(0);
     }
   int index_bar=-1;
   int bar_1=-1; // index of desired bar code, index of previous bar
   bool high_level=false; // variables to determine type of desired bar
   bool low_level = false;
   bool _start=false; // variables of type bool are used to stop bar analysis at the right moment
   double rsi,min,max,price_max,price_min;
   min=10000.0; max=0.0;
   int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
// --- in this block we determine on which (support or resistance) line should desired extremum be positioned 
   if(n_bar!=3)
     {
      if(first_ext==true) // if first point was maximum
        {
         low_level=true;//then this should be minimum
         if(distans>=0) low=low+distans;
        }
      else //if minimum
        {
         high_level = true;
         if(distans>=0) high = high-distans;
        }
     }
   else
     {
      if(first_ext==false)//if first point was minimum
        {
         low_level=true;//then this should be minimum
         if(distans>=0) high=high-distans;
        }
      else //if maximum
        {
         high_level = true;
         if(distans>=0) low = low+distans;
        }
     }
//---
   switch(n_bar) // find index of previous bar
     {
      case 2: bar_1 = bars_ext.Bar_1; break;
      case 3: bar_1 = bars_ext.Bar_2; break;
      case 4: bar_1 = bars_ext.Bar_3; break;
     }
   for(int i=bar_1; i<bars;i++) //analyze remaining bars
     {
      rsi=m_rsi[i];
      price_max = NormalizeDouble(m_high[i], digits);
      price_min = NormalizeDouble(m_low[i], digits);
      if(_start==true && ((low_level==true && rsi>=high) || (high_level==true && rsi<=low)))
        {
         break; // exit loop if second extremum is found, and RSI crossed opposite level
        }
      if(low_level==true) // if looking for minimum extremum
        {
         if(rsi<=low)
           {
            if(_start==false) _start=true;
            if(price_min<min)
              {
               min=price_min;
               index_bar=i;
              }
           }
        }
      else //if looking for maximum extremum
        {
         if(rsi>=high)
           {
            if(_start==false) _start=true;
            if(price_max>=max)
              {
               max=price_max;
               index_bar=i;
              }
           }
        }
     }
   return(index_bar);
  }
//+------------------------------------------------------------------+
//| Determine whether first bar was max or min                       |
//+------------------------------------------------------------------+
bool One_ext(st_Bars &bars_ext, //variable of structure type to get index of first bar
             string symbol,     //symbol of chart
             int h_rsi,         //handle of indicator
             double low,        //set oversold level of RSI (high level can be used)
             ENUM_TIMEFRAMES period_trade) //period of chart
  {
   double m_rsi[]; // array initialization of indicator data
   ArraySetAsSeries(m_rsi,true); // indexing
   CopyBuffer(h_rsi,0,0,bars_ext.Bar_1+1,m_rsi); // fill array with RSI data
   double rsi=m_rsi[bars_ext.Bar_1]; //define RSI value on bar with first extremum
   if(rsi<=low)                      //if value is below low level,
      return(false);                 //then first extremum is minimum
   else                              //if not,
   return(true);                     //then maximum 
  }
//+------------------------------------------------------------------+
