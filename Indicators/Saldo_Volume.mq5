//+------------------------------------------------------------------+
//|                                               PainelADVolume.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot buy
#property indicator_label1  "buy"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  5
//--- plot sell
#property indicator_label2  "sell"
#property indicator_type2   DRAW_HISTOGRAM
#property indicator_color2  clrRed
#property indicator_style2  STYLE_SOLID
#property indicator_width2  5


input bool INPShowSeparated         = true;     //Show Buy/Sell separated


//--- indicator buffers
double         buyBuffer[];
double         sellBuffer[];

ulong          today;


int            start =0;
int            end   =0;
ulong          startTime=0;
ulong          endTime=0;




//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,buyBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,sellBuffer,INDICATOR_DATA);
  
   // Config initial day
   MqlDateTime auxTime;
   TimeToStruct( TimeCurrent(), auxTime );
   auxTime.hour = 9;
   auxTime.min  = 0;
   auxTime.sec  = 0;
   today = DateToInteger(StructToTime(auxTime));  
  
   EventSetTimer( 2 );
  
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

   start = 0;
   end = rates_total-1;
   startTime = DateToInteger(time[rates_total-1]);
   endTime = DateToInteger(TimeCurrent());
   if ( prev_calculated<=rates_total ){
       start = prev_calculated-1;
       startTime  = (ulong)time[rates_total-1];
       endTime    = DateToInteger(TimeCurrent());
   }


   //Print( rates_total, " ", prev_calculated , "  ", (datetime)startTime, "  " , (datetime) endTime );
   //Print(start, " ", end, "  ", (datetime)startTime , "  ",(datetime) endTime );
  
  
   for( int i=rates_total; endTime >= startTime && today < startTime ; i--) {  
   //Print( rates_total, " ", prev_calculated , "  ", (datetime)startTime, "  " , (datetime) endTime );
      if ( INPShowSeparated )  VolumeBuySell( i , prev_calculated, startTime, endTime);
      else VolumeTotal( i , prev_calculated, startTime, endTime);
      startTime   = time[i-2];
      endTime     = time[i-1];
      if ( rates_total == prev_calculated ) break;
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

void OnTimer(){

  
}

void VolumeTotal(int _rates_total, int _prev_calculated , datetime _startTime, datetime _endTime){

   long buyTotal=0;
   long sellTotal=0;
   long balance=0;
   int iT = 0;

   MqlTick _ticks[];
  
   int copied = CopyTicksRange(_Symbol,_ticks,COPY_TICKS_TRADE,DateToInteger(_startTime)*1000, DateToInteger(_endTime)*1000);
   if( copied == 0) return;
   //Print("Copied: ", copied);
   ArraySetAsSeries( _ticks, true );
  

        while(  iT < copied   ) {
               if ( TradeType( _ticks[iT] )==BUY ) buyTotal = buyTotal + _ticks[ iT].volume;
               if ( TradeType( _ticks[iT] )==SELL ) sellTotal= sellTotal+ _ticks[ iT].volume;
               //if ( TradeType( _ticks[iT] )==INNER ) innerTotal= innerTotal+ _ticks[ iT].volume;
            iT++;
        }
              balance = buyTotal - sellTotal;
            
              buyBuffer[_rates_total-1] = buyTotal+sellTotal ;
              sellBuffer[_rates_total-1] = 0;
              Comment("Balance : ", balance,
                   "\n",
                   "Buy : " , buyTotal, "   Sell : " , sellTotal , "   Vol"
                    );

}


void VolumeBuySell(int _rates_total, int _prev_calculated , datetime _startTime, datetime _endTime){

   long buyTotal=0;
   long sellTotal=0;
   long balance=0;
   int iT = 0;

   MqlTick _ticks[];
  
   int copied = CopyTicksRange(_Symbol,_ticks,COPY_TICKS_TRADE,DateToInteger(_startTime)*1000, DateToInteger(_endTime)*1000);
   if( copied == 0) return;
   //Print("Copied: ", copied);
   ArraySetAsSeries( _ticks, true );
  

        while(  iT < copied   ) {
               if ( TradeType( _ticks[iT] )==BUY ) buyTotal = buyTotal + _ticks[ iT].volume;
               if ( TradeType( _ticks[iT] )==SELL ) sellTotal= sellTotal+ _ticks[ iT].volume;
               //if ( TradeType( _ticks[iT] )==INNER ) innerTotal= innerTotal+ _ticks[ iT].volume;
            iT++;
        }
              balance = buyTotal - sellTotal;
            
              buyBuffer[_rates_total-1] = buyTotal ;
              sellBuffer[_rates_total-1] = sellTotal*-1;
              Comment("Balance : ", balance,
                   "\n",
                   "Buy : ",NormalizeDouble((double) buyTotal/(buyTotal+sellTotal+0.0001)*100,0),
                   "  Sell : ", NormalizeDouble((double) sellTotal/(buyTotal+sellTotal+0.0001)*100,0), "  %"
                   "\n",
                   "Buy : " , buyTotal, "   Sell : " , sellTotal , "   Vol"
                    );

}



ulong DateToInteger( datetime _datetime ){
   return (ulong) (_datetime -  ((datetime) 0));
}  
  
datetime IntegerToDate( ulong _time ){
    return (datetime) _time;
}

enum TRADE_TYPE { BUY, SELL, INNER };
TRADE_TYPE TradeType( MqlTick &tick ) {

      bool buy       = tick.flags == 24 && tick.last >= tick.ask;
      bool sell      = tick.flags == 24 && tick.last <= tick.bid;
      bool between   = tick.flags == 24 && tick.last < tick.ask && tick.last > tick.bid;

      if ( buy ) return BUY;
      if ( sell) return SELL;
      
    
      return INNER;
}  

void OnDeinit(const int reason){
   EventKillTimer();
}  


