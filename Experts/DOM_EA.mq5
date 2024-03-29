//+------------------------------------------------------------------+
//|                                                       DOM EA.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                                    NurudeenAmedu |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "NurudeenAmedu"
#property version   "1.00"
MqlBookInfo priceArray[];
#include<Trade\Trade.mqh>
CTrade  trade;
enum trades{Buy=1, Sell=2, Buy_and_Sell=3};

input string timeP       = "Time Parameters";
input string StartHour   = "09:00";
input string EndHour     = "17:30";

input ENUM_TIMEFRAMES   TimeFrame   = PERIOD_CURRENT;
input int      Magic_Number      = 56252;
input int      Deviation         = 50;
input double   Entry_Percentage  = 60;
input int      Entry_Level       = 3;
input double   Entry_Volume      = 0.1;
input double   TakeProfit        = 0;
input double   StopLoss          = 0;
input trades   Trade_Mode        = Buy_and_Sell;
input bool     Trade_Constantly  = true;
input int      Repeat_Trades     = 3;
input bool     Trade_Extreme     = true;  // Don't Trade Highest & Lowest

int tradenow, totalTrades, bLevel, sLevel;
double Ask, Bid, Open[], High[], Low[], Close[];
double bsl, btp, ssl, stp, highP, lowP, buyPct, sellPct;
double price1, price2, price3, price4, vol1, vol2, vol3, vol4;
datetime start_time_ea;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   start_time_ea=TimeCurrent();
   RectLabelCreate(Symbol()+"bg",8,28,223,190,clrGray);
   CreateTLabel(0,Symbol()+"tbV",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,31,(string)("Total Buy Volume: "+(string)totalBuy+" "+(string)buyPct+"%"),"Total Buy",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"tsV",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,46,(string)("Total Sell Volume: "+(string)totalSell+" "+(string)sellPct+"%"),"Total Sell",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"ttV",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,61,(string)("Total Volume: "+(string)totalVolume),"Total Volume",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"hhP",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,76,(string)("High Price: "+(string)highP),"High Price",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"lwP",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,91,(string)("Low Price: "+(string)lowP),"Low Price",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"ttT",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,106,(string)("Total Trades: "+(string)totalTrades),"Total Trades",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"ttL",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,121,(string)("Total Profit: "+(string)todaysLoss()),"Todays Profit",clrDarkBlue,"Arial Bold",9);
   
   CreateTLabel(0,Symbol()+"tp1",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,136,(string)("Price 1: "+(string)price1+" Volume: "+(string)vol1),"price1",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"tp2",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,151,(string)("Price 2: "+(string)price2+" Volume: "+(string)vol2),"price2",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"tp3",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,166,(string)("Price 3: "+(string)price3+" Volume: "+(string)vol3),"price3",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"tp4",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,181,(string)("Price 4: "+(string)price4+" Volume: "+(string)vol4),"price4",clrDarkBlue,"Arial Bold",9);
   
   
   //--- set MagicNumber for your orders identification
   trade.SetExpertMagicNumber(Magic_Number);
   
   //--- set available slippage in points when buying/selling
   //int deviation=50;
   trade.SetDeviationInPoints(Deviation);
  
   //--- logging mode: it would be better not to declare this method at all, the class will set the best mode on its own
   trade.LogLevel(1); 
   
   //--- what function is to be used for trading: true - OrderSendAsync(), false - OrderSend()
   trade.SetAsyncMode(false);
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll(0,-1,OBJ_RECTANGLE_LABEL);
   ObjectsDeleteAll(0,-1,OBJ_TEXT);
   ObjectsDeleteAll(0,-1,OBJ_LABEL);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   getBookContent();
   setTP();
//   Print("Buy Entry: ",bLevel," ",bLevelPrice," ","Sell Entry: ",sLevel," ",sLevelPrice);
//         
   
   if(OpenOrdersThisPair(Symbol())>=2){
      DelAll(0);DelAll(1);
      CLOSEALL();
      totalTrades++;
      }
     
   Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
   Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
   
   int counte=10;
   ArraySetAsSeries(Low,true);
   CopyLow(_Symbol,_Period,0,counte,Low);
   ArraySetAsSeries(High,true);
   CopyHigh(_Symbol,_Period,0,counte,High);
   ArraySetAsSeries(Open,true);
   CopyOpen(_Symbol,_Period,0,counte,Open);
   ArraySetAsSeries(Close,true);
   CopyClose(_Symbol,_Period,0,counte,Close);
   
   if(IsNewCandle())tradenow=1;
   
   if(totalBuy>0 && totalVolume>0){
   buyPct=(totalBuy/totalVolume)*100;
   buyPct=NormalizeDouble(buyPct,2);}
   
   if(totalSell>0 && totalVolume>0){
   sellPct=(totalSell/totalVolume)*100;
   sellPct=NormalizeDouble(sellPct,2);}
   
   //Comment("Total Buy Volume: ",totalBuy," ",buyPct,"%","\n",
   //        "Total Sell Volume: ",totalSell," ",sellPct,"%","\n",
   //        "Total Volume: ",totalVolume,"\n",
   //        "Highest Price: ",highP,"\n",
   //        "Lowest Price: ",lowP,"\n",
   //        "Total Trades: ",totalTrades,"\n",
   //        "Total Profit: ",todaysLoss(),"\n");
           
   CreateTLabel(0,Symbol()+"tbV",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,31,(string)("Total Buy Volume: "+(string)totalBuy+" "+(string)buyPct+"%"),"Total Buy",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"tsV",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,46,(string)("Total Sell Volume: "+(string)totalSell+" "+(string)sellPct+"%"),"Total Sell",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"ttV",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,61,(string)("Total Volume: "+(string)totalVolume),"Total Volume",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"hhP",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,76,(string)("High Price: "+(string)highP),"High Price",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"lwP",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,91,(string)("Low Price: "+(string)lowP),"Low Price",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"ttT",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,106,(string)("Total Trades: "+(string)totalTrades),"Total Trades",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"ttL",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,121,(string)("Total Profit: "+(string)todaysLoss()),"Todays Profit",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"tp1",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,136,(string)("Price 1: "+(string)price1+" Volume: "+(string)vol1),"price1",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"tp2",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,151,(string)("Price 2: "+(string)price2+" Volume: "+(string)vol2),"price2",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"tp3",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,166,(string)("Price 3: "+(string)price3+" Volume: "+(string)vol3),"price3",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"tp4",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,181,(string)("Price 4: "+(string)price4+" Volume: "+(string)vol4),"price4",clrDarkBlue,"Arial Bold",9);
   
   if(totalBuy>0 && totalVolume>0){
   if((totalBuy/totalVolume)*100>=Entry_Percentage){
      CLOSEALL(1);
      DelAll(1);
      
      if((bLevelPrice!=highP && bLevelPrice!=lowP)||!Trade_Extreme){OrderEntry(0,bLevelPrice);}
         }
      }
   if(totalSell>0 && totalVolume>0){
   if((totalSell/totalVolume)*100>=Entry_Percentage){
      CLOSEALL(0);
      DelAll(0);
      
      if((sLevelPrice!=highP && sLevelPrice!=lowP)||!Trade_Extreme){OrderEntry(1,sLevelPrice);}
         }
      }
  }
//+------------------------------------------------------------------+

double totalVolume, bLevelPrice, sLevelPrice;
double totalSell, totalBuy;
int bcnt=0, scnt=0;
double lastBp=0, lastSp=0;
void getBookContent(){
   bcnt=0; scnt=0;
   lastBp=0; lastSp=0;
   totalSell=0;
   totalBuy=0;
   totalVolume=0;
   highP=0;
   lowP=0;
   vol1=0;
   price1=0;
   vol2=0;
   price2=0;
   vol3=0;
   price3=0;
   vol4=0;
   price4=0;
   
   bool getBook=MarketBookGet(Symbol(),priceArray); 
   if(getBook) 
     { 
      bLevel=0;
      sLevel=0;
      int size=ArraySize(priceArray);
      int n=1; 
      //Print("MarketBookInfo for ",Symbol()); 
      
      for(int i=size-1; i>=0; i--) 
        { 
         
         if((priceArray[i].type==1)){
            
             if(n==Entry_Level){
               
               sLevelPrice=priceArray[i].price;
               sLevel=i;
            }
            n++;            
        }
      }
      
      n=1;
      for(int i=0;i<size;i++) 
        { 
   
         if((priceArray[i].type==2)){
            if(n==Entry_Level){
               bLevelPrice=priceArray[i].price;
               bLevel=i;
            }
            n++;               
         }
         
         //Print((string)i+":",(string)priceArray[i].price 
         //       +" Volume = "+(string)priceArray[i].volume, 
         //        " type = ",(string)priceArray[i].type); 
                 
            totalVolume+=priceArray[i].volume;
            
            if(priceArray[i].volume>vol1){
               vol1=priceArray[i].volume;
               price1=priceArray[i].price;
            }
            if(priceArray[i].volume>vol2 && priceArray[i].volume<vol1){
               vol2=priceArray[i].volume;
               price2=priceArray[i].price;
            }
            if(priceArray[i].volume>vol3 && priceArray[i].volume<vol1 && priceArray[i].volume<vol2){
               vol3=priceArray[i].volume;
               price3=priceArray[i].price;
            }
            if(priceArray[i].volume>vol4 && priceArray[i].volume<vol1 && priceArray[i].volume<vol2 && priceArray[i].volume<vol3){
               vol4=priceArray[i].volume;
               price4=priceArray[i].price;
            }
            
            if(priceArray[i].price>highP){
               highP=priceArray[i].price;
            }
            if(priceArray[i].price<lowP||lowP==0){
               lowP=priceArray[i].price;
            }
            
            if((priceArray[i].type==BOOK_TYPE_BUY||priceArray[i].type==BOOK_TYPE_BUY_MARKET)){
               
               //bLevelPrice=priceArray[i].price;
               totalBuy+=priceArray[i].volume;
               
                  
               if(bcnt<Entry_Level && (priceArray[i].price>lastBp)){
                  bcnt++;
                  lastBp=priceArray[i].price;
                  }
               }
            if((priceArray[i].type==BOOK_TYPE_SELL||priceArray[i].type==BOOK_TYPE_SELL_MARKET)){
               
               //sLevelPrice=priceArray[i].price;
               totalSell+=priceArray[i].volume;
               
               if(scnt<Entry_Level && (priceArray[i].price<lastSp||lastSp==0)){
                  scnt++;
                  lastSp=priceArray[i].price;
               }
            }
        } 
     } 
   else 
     { 
      Print("Could not get contents of the symbol DOM ",Symbol()); 
     }
}

//+------------------------------------------------------------------+
double lastLot;
int lastEntry;
void OrderEntry(int direction, double eprice){
   double lotsize=Entry_Volume;
   
   lotsize=NormalizeDouble(lotsize,2);
 
   if(OpenOrdersThisPair(Symbol())+OpenPendThisPair(Symbol())<1 && WorkingHour() && (totalTrades<Repeat_Trades||Trade_Constantly)){
   //Print("here4"," ",eprice," ",tradenow);
   if((direction==0) && (Trade_Mode==Buy||Trade_Mode==Buy_and_Sell)){
      
      //Print("here1"," ",eprice);
      if(StopLoss>0){bsl=eprice-StopLoss*Point();}else{bsl=0;}
      if(TakeProfit>0){btp=eprice+TakeProfit*Point();}else{btp=0;}
      
      if(eprice>Ask)trade.BuyStop(lotsize,eprice,NULL,0,0,0,0,"EA Trade");
      if(eprice<Ask)trade.BuyLimit(lotsize,eprice,NULL,0,0,0,0,"EA Trade");
      //totalTrades++;
      tradenow=0;
      
   }
   
   if((direction==1) && (Trade_Mode==Sell||Trade_Mode==Buy_and_Sell)){
      //Print("here2"," ",eprice);
      if(StopLoss>0){ssl=eprice+StopLoss*Point();}else{ssl=0;}
      if(TakeProfit>0){stp=eprice-TakeProfit*Point();}else{stp=0;}
      
      if(eprice>Bid){trade.SellLimit(lotsize,eprice,NULL,0,0,0,0,"EA Trade");}
      if(eprice<Bid)trade.SellStop(lotsize,eprice,NULL,0,0,0,0,"EA Trade");
      //totalTrades++;
      tradenow=0;
   } 
   }
}


//+-------------------------------
//+ Check Open Orders
//+-------------------------------

int OpenOrdersThisPair(string pair)
{
  int tnum =0;
   int _tp=PositionsTotal();
   
   for(int i=_tp-1; i>=0; i--)
     {
      string _p_symbol=PositionGetSymbol(i);
      ulong tick = PositionGetTicket(i);
      
      if(PositionSelectByTicket(tick)){
      long posMag=PositionGetInteger(POSITION_MAGIC);
      string posCom=PositionGetString(POSITION_COMMENT);
      
      if(_p_symbol==Symbol()){
      if(Magic_Number==posMag){
         tnum++;
         }
    }
    }
    }
return(tnum);
}


double lastclose;
//+------------------------------------------------------------------+
//insuring its a new candle function
//+------------------------------------------------------------------+
bool IsNewCandle()
{
   if(Close[1]==lastclose){return(false);}
   if(Close[1]!=lastclose){lastclose=Close[1];return(true);}
	return(true);
}

void CLOSEALL(int type){
   int _tp=PositionsTotal();
   for(int i=_tp-1; i>=0; i--)
     {
      string _p_symbol=PositionGetSymbol(i);
      ulong tick=PositionGetTicket(i);
      
      if(PositionSelectByTicket(tick)){
      
      if(Magic_Number==PositionGetInteger(POSITION_MAGIC)){
      
      if(type==0 && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY){
         
         trade.PositionClose(tick,-1);
         totalTrades++;
         }
      if(type==1 && PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL){
         
         trade.PositionClose(tick,-1);
         totalTrades++;
         }
  }
}
}
}


void DelAll(int type){
   int _tp=OrdersTotal();
   for(int i=_tp-1; i>=0; i--)
     {
      string _p_symbol=OrderGetString(ORDER_SYMBOL);
      ulong tick=OrderGetTicket(i);
      
      if(OrderSelect(tick)){
      int posType=OrderGetInteger(ORDER_TYPE);
      if(Magic_Number==OrderGetInteger(ORDER_MAGIC)){
         
         if(type==0 && (posType==ORDER_TYPE_BUY_STOP||posType==ORDER_TYPE_BUY_LIMIT)){
         trade.OrderDelete(tick);        
         }
         if(type==1 && (posType==ORDER_TYPE_SELL_STOP||posType==ORDER_TYPE_SELL_LIMIT)){
         trade.OrderDelete(tick);        
         }
    }
  }
  }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool WorkingHour() 
  {
   datetime gi_time_01 = StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " + StartHour);
   datetime gi_time_02 = StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " + EndHour);
   datetime datetime_0 = TimeCurrent();

   if( gi_time_01 < gi_time_02 && gi_time_01 <= datetime_0 && datetime_0 <= gi_time_02 ) return (true);
   if( gi_time_01 > gi_time_02 && (datetime_0 >= gi_time_01 || datetime_0 <= gi_time_02) ) return (true);


   return (false);
}

void setTP(){
   int _tp=PositionsTotal();

   if((OpenPend("TakeProfit")==0 || OpenPend("StopLoss")==0) && OpenOrdersThisPair(Symbol())>=1){
     
     for(int i=_tp; i>=0; i--)
      {
      string _p_symbol=PositionGetSymbol(i);
      ulong tick=PositionGetTicket(i);
      
      if(PositionSelectByTicket(tick)){
      double ordOp=PositionGetDouble(POSITION_PRICE_OPEN);
      int ordType=(int)PositionGetInteger(POSITION_TYPE);
         if(ordType==POSITION_TYPE_BUY){
            if(StopLoss>0){bsl=ordOp-StopLoss*Point();}else{bsl=0;}
            if(TakeProfit>0){btp=ordOp+TakeProfit*Point();}else{btp=0;}
            
            if(OpenPend("TakeProfit")==0)trade.SellLimit(Entry_Volume,btp,NULL,0,0,0,0,"TakeProfit");
            if(OpenPend("StopLoss")==0)trade.SellStop(Entry_Volume,bsl,NULL,0,0,0,0,"StopLoss");
            }
         if(ordType==POSITION_TYPE_SELL){
            if(StopLoss>0){ssl=ordOp+StopLoss*Point();}else{ssl=0;}
            if(TakeProfit>0){stp=ordOp-TakeProfit*Point();}else{stp=0;}
            
            if(OpenPend("TakeProfit")==0)trade.BuyLimit(Entry_Volume,stp,NULL,0,0,0,0,"TakeProfit");
            if(OpenPend("StopLoss")==0)trade.BuyStop(Entry_Volume,ssl,NULL,0,0,0,0,"StopLoss");
            }
         }
      }      
   }
}


int OpenPend(string comment){
   int tnum =0;
   int _tp=OrdersTotal();
   
   for(int i=_tp-1; i>=0; i--)
     {
      string _p_symbol=OrderGetString(ORDER_SYMBOL);
      ulong tick = OrderGetTicket(i);
      
      if(OrderSelect(tick)){
      string pcomm=OrderGetString(ORDER_COMMENT);
      
      if(_p_symbol==Symbol() && comment==pcomm){
      if(Magic_Number==PositionGetInteger(POSITION_MAGIC)){
         tnum++;
         }
    }
    }
    }
return(tnum);
}
int OpenPendThisPair(string symbol){
   int tnum =0;
   int _tp=OrdersTotal();
   
   for(int i=_tp-1; i>=0; i--)
     {
      string _p_symbol=OrderGetString(ORDER_SYMBOL);
      ulong tick = OrderGetTicket(i);
      
      if(OrderSelect(tick)){
      if(_p_symbol==symbol){
      if(Magic_Number==OrderGetInteger(ORDER_MAGIC)){
         tnum++;
         }
    }
    }
    }
return(tnum);
}


double todaysLoss(){
double val=0;
   

//--- set the start and end date to request the history of deals 
   datetime from_date=0;         // from the very beginning 
   datetime to_date=TimeCurrent();// till the current moment 
//--- request the history of deals in the specified period 
   HistorySelect(from_date,to_date); 
//--- total number in the list of deals 
   int deals=HistoryDealsTotal(); 
//--- now process each trade 
   for(int i=0;i<deals;i++) 
     { 
      
      ulong deal_tickettt=               HistoryDealGetTicket(i); 
      datetime transaction_timett= (datetime)HistoryDealGetInteger(deal_tickettt,DEAL_TIME);
      double profittt   =                 HistoryDealGetDouble(deal_tickettt,DEAL_PROFIT); 
      string symboltt   =                 HistoryDealGetString(deal_tickettt,DEAL_SYMBOL);
      int deal_typett    =(int)         HistoryDealGetInteger(deal_tickettt,DEAL_TYPE);
      datetime CurClosedTime=(datetime)HistoryDealGetInteger(deal_tickettt,DEAL_TIME);
 
      
      MqlDateTime hari;
      //Comment(TimeDayMQL4(transaction_timett), " ", TimeDayMQL4(TimeCurrent()));
      if(deal_tickettt>0 && symboltt==Symbol() && (deal_typett==1||deal_typett==0) 
         && TimeDayMQL4(transaction_timett)==TimeDayMQL4(TimeCurrent()) && transaction_timett>start_time_ea){
         
         val+=profittt;
         
            }
      }
return(val);
}

int TimeDayMQL4(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_week);
  }
  
  
void CLOSEALL(){

   int _tp=PositionsTotal();
   for(int i=_tp-1; i>=0; i--)
     {
      string _p_symbol=PositionGetSymbol(i);
      ulong tick=PositionGetTicket(i);
      
      
      if(PositionSelectByTicket(tick)){
      int typer=(int)PositionGetInteger(POSITION_TYPE);
      int posmag=(int)PositionGetInteger(POSITION_MAGIC);
      
      if(Magic_Number==posmag){
           
         trade.PositionClose(tick,-1);
         
             

  }
}
}
}


//--------------------------------------------------------------------+
//      Create RECTANGLE_LABEL                                        |
//--------------------------------------------------------------------+
void RectLabelCreate(const string           name="RectLabel",  
                     const int              x=0,                     
                     const int              y=0,                    
                     const int              width=50,              
                     const int              height=18,
                     const color            back_clr=clrWhite) {               
   
   if(name=="MOVE"){
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrDimGray); 
   }
   if(ObjectFind(0,name)!=-1){
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x); 
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y); 
      ObjectSetInteger(0,name,OBJPROP_XSIZE,width); 
      ObjectSetInteger(0,name,OBJPROP_YSIZE,height); 
   }
   if(ObjectFind(0,name)==-1){
      ResetLastError(); 
      if(!ObjectCreate(0,name,OBJ_RECTANGLE_LABEL,0,0,0)) 
        { 
         Print(__FUNCTION__," ",GetLastError()); 
         return; 
        } 
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x); 
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y); 
      ObjectSetInteger(0,name,OBJPROP_XSIZE,width); 
      ObjectSetInteger(0,name,OBJPROP_YSIZE,height); 
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,back_clr); 
      ObjectSetInteger(0,name,OBJPROP_BORDER_TYPE,BORDER_SUNKEN); 
      ObjectSetInteger(0,name,OBJPROP_CORNER,CORNER_LEFT_UPPER); 
      ObjectSetInteger(0,name,OBJPROP_COLOR,clrWhite); 
      ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID); 
      ObjectSetInteger(0,name,OBJPROP_WIDTH,1); 
      ObjectSetInteger(0,name,OBJPROP_BACK,false); 
      ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false); 
      ObjectSetInteger(0,name,OBJPROP_SELECTED,false); 
      ObjectSetInteger(0,name,OBJPROP_HIDDEN,false); 
      ObjectSetInteger(0,name,OBJPROP_ZORDER,0); 
   }
}




//+------------------------------------------------------------------+
//|  Создание текстовой метки                                        |
//+------------------------------------------------------------------+
void CreateTLabel(long   chart_id,         // идентификатор графика
                  string name,             // имя объекта
                  int    nwin,             // индекс окна
                  ENUM_BASE_CORNER corner, // положение угла привязки
                  ENUM_ANCHOR_POINT point, // положение точки привязки
                  int    X,                // дистанция в пикселях по оси X от угла привязки
                  int    Y,                // дистанция в пикселях по оси Y от угла привязки
                  string text,             // текст
                  string textTT,           // текст всплывающей подсказки
                  color  Color,            // цвет текста
                  string Font,             // шрифт текста
                  int    Size)             // размер шрифта
  {
//----
   ObjectCreate(chart_id,name,OBJ_LABEL,0,0,0);
   ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);
   ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,point);
   ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,X);
   ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,Y);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetString(chart_id,name,OBJPROP_FONT,Font);
   ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,Size);
   ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,textTT);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,false); //объект на заднем плане
//----
  }