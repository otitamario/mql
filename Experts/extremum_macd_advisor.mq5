//+------------------------------------------------------------------+
//|                                            scale_factor_macd.mq5 |
//|                                                         Aternion |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Aternion"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//--- input parameters
input int      bars=900;            //  extreme points search range
input double   delta_points=190;    //  variation range defining the minimum distance between a peak and a bottom in points
input double   first_extrem=0.7;    //  additional ratio for searching for the first extreme value
input int      orderr_size=1;     //  risk per each trade
input double   macd_t=0.00004;      //  minimum MACD histogram deviation 
input double   trend=30;           //  minimum price deviation for the nearest two peaks/bottoms
input double   guard_points=30;     //  shift the stop loss
input int      time=0;              //  time delay in seconds
input int      show_info=0;         //  display data about extreme points
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Function-event handler "tick"                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   Sleep(1000*time);                 //  introduce the time delay
   double High[],Low[];
   datetime Time[];

   ArraySetAsSeries(Low,true);
   int copied1=CopyLow(Symbol(),0,0,bars+2,Low);
   ArraySetAsSeries(High,true);
   int copied2=CopyHigh(Symbol(),0,0,bars+2,High);
   ArraySetAsSeries(Time,true);
   int copied3=CopyTime(Symbol(),0,0,bars+2,Time);

   double delta=delta_points*Point();     //  variation value in absolute terms
   double first=delta*(1-first_extrem);
   double trendd=trend*Point();           //  minimum price deviation for the nearest two peaks/bottoms in absolute terms
   double guard=guard_points*Point();     //  stop loss shift in absolute terms
   bool openedorder=false;

   int j,k,l;
   int j2,k2,l2;
   double  j1,k1,l1;
//--- array defining bottoms if the first detected extreme value is a bottom
   int min[10];         // the value corresponds to the bar index for a detected extreme point  
//--- array defining peaks if the first detected extreme value is a bottom
   int max[10];         // the value corresponds to the bar index for a detected extreme point
//--- array defining bottoms if the first detected extreme value is a peak
   int Min[10];         // the value corresponds to the bar index for a detected extreme point
//--- array defining peaks if the first detected extreme value is a peak
   int Max[10];         // the value corresponds to the bar index for a detected extreme point

   int mag1=bars;
   int mag2=bars;
   int mag3=bars;
   int mag4=bars;
//--- extreme points are defined first if the first of them is a bottom
   j1=SymbolInfoDouble(Symbol(),SYMBOL_BID)+(1-first_extrem)*delta_points*Point();
//--- when searching for the first extreme point, the additional ratio defines the minimum price, below which the first bottom is to be located
   j2=0;                         // at the first iteration, the search is performed beginning from the last history bar
//--- loop defining the first bottom - min[1]
   for(j=0;j<=15;j++)
     {
      min[1]=minimum(j2,bars,j1);  // define the nearest bottom within the specified interval
      j2=min[1]+1;                 // at the next iteration, the search is performed from the already detected bottom min[1]
      j1=Low[min[1]]+delta;        // Low price for the bottom detected on the subsequent iteration should be lower 
                                   // than the Low price for the bottom found at the current iteration 
      k1=Low[min[1]];              // Low price for the bottom when searching for the next extreme point defines the High price,
                                   // above which the peak should be located
      k2=min[1];                   // search for the peak located after the bottom is performed from the detected bottom min[1]

      //--- loop defining the first peak - max[1]
      for(k=0;k<=12;k++)
        {
         max[1]=maximum(k2,bars,k1);   // define the nearest peak in a specified interval
         k1=High[max[1]]-delta;        // High price for the peak detected on the subsequent iteration should be higher
                                       // than the High price for the peak found at the current iteration 
         k2=max[1]+1;                  // at the next iteration, the search is performed from the already detected peak max[1]
         l1=High[max[1]];              // High price for the extreme point when searching for the next bottom defines the Low price,
                                       // below which the bottom should be located
         l2=max[1];                    // search for the bottom located after the peak is performed from the detected peak max[1]
         //--- loop defining the second bottom - min[2] and the second peak max[2]
         for(l=0;l<=10;l++)
           {
            min[2]=minimum(l2,bars,l1);                 // define the nearest bottom within the specified interval
            l1=Low[min[2]]+delta;                       // Low price for the bottom detected on the subsequent iteration should be lower
                                                        // than the Low price for the bottom found at the current iteration 
            l2=min[2]+1;                                // at the next iteration, the search is performed from the already detected bottom min[2]
            max[2]=maximum(min[2],bars,Low[min[2]]);    // define the nearest peak in a specified interval

            //--- sort out coinciding extreme values and special cases
            if(max[1]>min[1] && min[1]>1 && min[2]>max[1] && min[2]<max[2] && max[2]<mag4)
              {
               mag1=min[1];      // at each iteration, locations of the detected extreme values are saved if the condition is met
               mag2=max[1];
               mag3=min[2];
               mag4=max[2];
              }
           }
        }
     }
   min[1]=mag1;                  // extreme points are defined, otherwise the 'bars' value is assigned to all variables
   max[1]=mag2;
   min[2]=mag3;
   max[2]=mag4;

   min[1]=check_min(min[1],max[1]);    //verify and correct the position of the extreme points within the specified interval 
   max[1]=check_max(max[1],min[2]);
   min[2]=check_min(min[2],max[2]);

   mag1=bars;
   mag2=bars;
   mag3=bars;
   mag4=bars;
//---  extreme points are defined similarly if the first of them is a peak
   j1=SymbolInfoDouble(Symbol(),SYMBOL_BID)-(1-first_extrem)*delta_points*Point();
//--- when searching for the first extreme point, the additional ratio defines the maximum price, above which the first peak is to be located
   j2=0;                         // at the first iteration, the search is performed beginning from the last history bar
//--- loop defining the first peak - Max[1]
   for(j=0;j<=15;j++)
     {
      Max[1]=maximum(j2,bars,j1);  // define the nearest peak in a specified interval
      j1=High[Max[1]]-delta;       // High price for the peak detected on the subsequent iteration should be higher
                                   // than the High price for the peak found at the current iteration 
      j2=Max[1]+1;                 // at the next iteration, the search is performed from the already detected peak Max[1]
      k1=High[Max[1]];             // High price for the extreme point when searching for the next bottom defines the Low price,
                                   // below which the bottom should be located
      k2=Max[1];                   // search for the bottom located after the peak is performed from the detected peak Max[1]
      //--- loop defining the first peak - Min[1]
      for(k=0;k<=12;k++)
        {
         Min[1]=minimum(k2,bars,k1);   // define the nearest bottom within the specified interval
         k1=Low[Min[1]]+delta;         // Low price for the bottom detected on the subsequent iteration should be lower
                                       // than the Low price for the bottom found at the current iteration 
         k2=Min[1]+1;                  // at the next iteration, the search is performed from the already detected bottom Min[1]
         l1=Low[Min[1]];               // Low price for the bottom when searching for the next extreme point defines the High price,
                                       // above which the peak should be located
         l2=Min[1];                    // search for the peak located after the bottom is performed from the detected bottom Min[1]
         //--- loop defining the second peak - Max[2] and the second bottom Min[2]
         for(l=0;l<=10;l++)
           {
            Max[2]=maximum(l2,bars,l1);      // define the nearest peak in a specified interval
            l1=High[Max[2]]-delta;           // High price for the peak detected on the subsequent iteration should be higher,
                                             // than the High price for the peak found at the current iteration 
            l2=Max[2]+1;                     // at the next iteration, the search is performed from the already detected peak Max[2]
            //--- define the nearest bottom within the specified interval
            Min[2]=minimum(Max[2],bars,High[Max[2]]);
            //--- sort out coinciding extreme values and special cases
            if(Max[2]>Min[1] && Min[1]>Max[1] && Max[1]>0 && Max[2]<Min[2] && Min[2]<bars)
              {
               mag1=Max[1];      // at each iteration, locations of the detected extreme values are saved if the condition is met
               mag2=Min[1];
               mag3=Max[2];
               mag4=Min[2];
              }
           }
        }
     }
//--- extreme points are defined, otherwise the 'bars' value is assigned to all variables
   Max[1]=mag1;
   Min[1]=mag2;
   Max[2]=mag3;
   Min[2]=mag4;
//--- verify and correct the extreme points position within the specified interval
   Max[1]=check_max(Max[1],Min[1]);
   Min[1]=check_min(Min[1],Max[2]);
   Max[2]=check_max(Max[2],Min[2]);

//--- calculate the lot when buying
int lot_buy,lot_sell;
   if (PositionSelect(_Symbol) ==true && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL) lot_buy=2*orderr_size;
   if (PositionSelect(_Symbol) ==false) lot_buy=orderr_size;
//--- calculate the lot when selling
   if (PositionSelect(_Symbol) ==true && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) lot_sell=2*orderr_size;
   if (PositionSelect(_Symbol) ==false) lot_sell=orderr_size;
  Print("lote buy , sell", lot_buy," ",lot_sell);
   int index_handle=iMACD(NULL,PERIOD_CURRENT,17,72,34,PRICE_MEDIAN);
   double MACD_all[];
   ArraySetAsSeries(MACD_all,true);
   int copied4=CopyBuffer(index_handle,0,0,bars+2,MACD_all);
//--- calculate the indicator values corresponding to the extreme points if the first extreme point is a bottom
   double index_min1=MACD_all[min[1]];
   double index_min2=MACD_all[min[2]];
//--- calculate the indicator values corresponding to the extreme points if the first extreme point is a peak
   double index_Max1=MACD_all[Max[1]];
   double index_Max2=MACD_all[Max[2]];
//--- The condition for correct extreme points detection
   bool flag_1=(min[2]<bars && min[2]!=0 && max[1]<bars && max[1]!=0 && max[2]<bars && max[2]!=0);  
   bool flag_2=(Min[1]<bars && Min[1]!=0 && Max[2]<bars && Max[2]!=0 && Min[2]<bars && Min[2]!=0);
//--- difference between extreme points price values should not be less than a set value   
   bool trend_down=(Low[min[1]]<(Low[min[2]]-trendd));
   bool trend_up=(High[Max[1]]>(High[Max[2]]+trendd));
//--- verify the condition for the absence of open positions
   openedorder=PositionSelect(Symbol());
   
//--- if the first extreme point is a bottom, a buy trade is opened
   if(min[1]<Max[1] && trend_down && flag_1 && !openedorder && (index_min1>(index_min2+macd_t)))
      // difference between MACD values for extreme points is not less than the value of macd_t set as an input 
      // trade is opened in case of an oppositely directed movements of the price and the indicator calculated based on extreme points
     {
      //--- display data on extreme points
      if(show_info==1) Alert("For the last",bars," bars, the distance in bars to the nearest bottom and extreme points",min[1]," ",max[1]," ",min[2]);

      MqlTradeResult result={0};
      MqlTradeRequest request={0};
      request.action=TRADE_ACTION_DEAL;
      request.magic=123456;
      request.symbol=_Symbol;
      request.volume=lot_buy;
      request.price=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
      request.sl=Low[min[1]]-guard;
      request.tp=MathAbs(2*SymbolInfoDouble(Symbol(),SYMBOL_BID)-Low[min[1]])+guard;
      request.type=ORDER_TYPE_BUY;
      request.deviation=50;
      request.type_filling=ORDER_FILLING_FOK;

      if(!OrderSend(request,result))
         PrintFormat("OrderSend error %d",GetLastError());
     }
//--- if the first extreme point is a peak, a sell trade is opened
   if(min[1]>Max[1] && trend_up && flag_2 && !openedorder && (index_Max1<(index_Max2-macd_t)))
      // difference between MACD values for extreme points is not less than the value of macd_t set as an input
      // trade is opened in case of an oppositely directed movements of the price and the indicator calculated based on extreme points
     {
     //--- display data on extreme points
      if(show_info==1) Alert("For the last ",bars," bars, the distance in bars to the nearest peak and extreme points",Max[1]," ",Min[1]," ",Max[2]);
      
      MqlTradeResult result={0};
      MqlTradeRequest request={0};
      request.action=TRADE_ACTION_DEAL;
      request.magic=123456;
      request.symbol=_Symbol;
      request.volume=lot_sell;
      request.price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
      request.sl=High[Max[1]]+guard;
      request.tp=MathAbs(High[Max[1]]-2*(High[Max[1]]-SymbolInfoDouble(Symbol(),SYMBOL_ASK)))-guard;
      request.type=ORDER_TYPE_SELL;
      request.deviation=50;
      request.type_filling=ORDER_FILLING_FOK;

      if(!OrderSend(request,result))
         PrintFormat("OrderSend error %d",GetLastError());
     }
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//----

//----
   return;
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
// ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
// ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+
//| Define the nearest bottom within the specified interval          |
//| located above price0 at a distance < the variation range         |
//+------------------------------------------------------------------+
int minimum(int a,int b,double price0)
  {
   double High[],Low[];
   ArraySetAsSeries(Low,true);
   int copied4=CopyLow(Symbol(),0,0,bars+2,Low);

   int i,e;
   e=bars;
//--- the price, below which the bottom with the added variation range should be located
   double pr=price0-delta_points*Point();
   for(i=a;i<=b;i++) // search for the bottom within the range specified by a and b parameters
     {
      //--- define the nearest bottom, after which the price growth starts
      if(Low[i]<pr && Low[i]<Low[i+1])
        {
         e=i;
         break;
        }
     }
//---
   return(e);
  }
//+------------------------------------------------------------------+
//| Define the nearest peak within the specified interval            |
//| located above price1 at a distance > the variation range         |
//+------------------------------------------------------------------+
int maximum(int a,int b,double price1)
  {
   double High[],Low[];
   ArraySetAsSeries(High,true);
   int copied5=CopyHigh(Symbol(),0,0,bars+2,High);

   int i,e;
   e=bars;
//--- the price, above which the peak with the added variation range should be located
   double pr1=price1+delta_points*Point();
   for(i=a;i<=b;i++) // search for the peak within the range specified by a and b parameters
     {
      //--- define the nearest peak, after which the price fall starts
      if(High[i]>pr1 && High[i]>High[i+1])
        {
         e=i;
         break;
        }
     }
//---
   return(e);
  }
//+-----------------------------------------------------------------------------+
//| Verifying and correcting the bottom position within the specified interval  |
//+-----------------------------------------------------------------------------+
int check_min(int a,int b)
  {

   double High[],Low[];
   ArraySetAsSeries(Low,true);
   int copied6=CopyLow(Symbol(),0,0,bars+1,Low);
   int i,c;
   c=a;
//--- when searching for the bottom, all bars specified by the range are verified
   for(i=a+1;i<b;i++)
     {
      //--- if the bottom located lower is found
      if(Low[i]<Low[a] && Low[i]<Low[c])
         c=i;   // the bottom location is redefined
     }
//---
   return(c);
  }
//+---------------------------------------------------------------------------+
//| Verifying and correcting the peak position within the specified interval  |
//+---------------------------------------------------------------------------+
int check_max(int a,int b)
  {
   double High[],Low[];
   ArraySetAsSeries(High,true);
   int copied7=CopyHigh(Symbol(),0,0,bars+1,High);
   int i,d;
   d=a;
//--- when searching for the bottom, all bars specified by the range are verified
   for(i=(a+1);i<b;i++)
     {
      //--- if the peak located above is found
      if(High[i]>High[a] && High[i]>High[d])
         d=i;   // the peak location is redefined
     }
//---
   return(d);
  }
//+------------------------------------------------------------------+
