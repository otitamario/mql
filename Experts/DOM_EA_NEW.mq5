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
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;

CTrade  trade;
enum trades{Buy=1,Sell=2,Buy_and_Sell=3};

input string timeP       = "Time Parameters";
input string StartHour   = "09:00";
input string EndHour     = "17:30";

input ENUM_TIMEFRAMES   TimeFrame= PERIOD_CURRENT;
input int      Magic_Number      = 56252;
input int      Deviation         = 50;
input double   Entry_Percentage  = 60;
input int      Entry_Level       = 3;
input double   Entry_Volume      = 0.1;
input double   _TakeProfit=0;
input double   _Stop=0;
input trades   Trade_Mode        = Buy_and_Sell;
input bool     Trade_Constantly  = true;
input int      Repeat_Trades     = 3;
input bool     Trade_Extreme=true;  // Don't Trade Highest & Lowest

int tradenow,totalTrades,bLevel,sLevel;
double Ask,Bid,Open[],High[],Low[],Close[];
double bsl,btp,ssl,stp,highP,lowP,buyPct,sellPct;
double price1,price2,price3,price4,vol1,vol2,vol3,vol4;
datetime start_time_ea;
double ponto,ticksize,digits;
string glob_entr_tot="ENT_TOT"+Symbol()+IntegerToString(Magic_Number);
string deals_total="deals_total"+Symbol()+IntegerToString(Magic_Number),deals_total_prev="deals_total_prev"+Symbol()+IntegerToString(Magic_Number);
string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string tp_vd_tick="tp_vd_tick"+Symbol()+IntegerToString(Magic_Number),tp_cp_tick="tp_cp_tick"+Symbol()+IntegerToString(Magic_Number);
string stp_vd_tick="stp_vd_tick"+Symbol()+IntegerToString(Magic_Number),stp_cp_tick="stp_cp_tick"+Symbol()+IntegerToString(Magic_Number);
bool Conexao;
ulong time_conex=200;// Tempo em Milissegundos para testar conexão
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   Conexao=IsConnect();
   EventSetMillisecondTimer(time_conex);

   datetime expiracao=D'2018.10.24 23:59:59';
   MessageBox("Validade até "+TimeToString(expiracao));
   if(TimeCurrent()>expiracao)
     {
      string erro="Data de Validade Expirou";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   mysymbol.Name(Symbol());
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.SetDeviationInPoints(500);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      Print("ORDER_FILLING_FOK");
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      Print("ORDER_FILLING_IOC");
   else
      Print("ORDER_FILLING_RETURN");
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      mytrade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      mytrade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      mytrade.SetTypeFilling(ORDER_FILLING_RETURN);
   ponto=SymbolInfoDouble(Symbol(),SYMBOL_POINT);
   ticksize=SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(Symbol(),SYMBOL_DIGITS);

   if(!GlobalVariableCheck(glob_entr_tot))GlobalVariableSet(glob_entr_tot,0.0);
   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0.0);
   if(!GlobalVariableCheck(tp_cp_tick))GlobalVariableSet(tp_cp_tick,0.0);
   if(!GlobalVariableCheck(stp_cp_tick))GlobalVariableSet(stp_cp_tick,0.0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0.0);
   if(!GlobalVariableCheck(tp_vd_tick))GlobalVariableSet(tp_vd_tick,0.0);
   if(!GlobalVariableCheck(stp_vd_tick))GlobalVariableSet(stp_vd_tick,0.0);

//---
   start_time_ea=TimeCurrent();
   RectLabelCreate(Symbol()+"bg",8,28,223,190,clrGray);
   CreateTLabel(0,Symbol()+"tbV",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,31,(string)("Total Buy Volume: "+(string)totalBuy+" "+(string)buyPct+"%"),"Total Buy",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"tsV",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,46,(string)("Total Sell Volume: "+(string)totalSell+" "+(string)sellPct+"%"),"Total Sell",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"ttV",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,61,(string)("Total Volume: "+(string)totalVolume),"Total Volume",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"hhP",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,76,(string)("High Price: "+(string)highP),"High Price",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"lwP",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,91,(string)("Low Price: "+(string)lowP),"Low Price",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"ttT",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,106,(string)("Total Trades: "+DoubleToString(GlobalVariableGet(glob_entr_tot),2)),"Total Trades",clrDarkBlue,"Arial Bold",9);
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
   EventKillTimer();
   if(reason!=5)
     {
      GlobalVariableSet(glob_entr_tot,0.0);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   CheckConnection();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+

void OnTick()
  {
   ProtectPosition();
   mysymbol.Refresh();
   mysymbol.RefreshRates();
//---
   getBookContent();
//   Print("Buy Entry: ",bLevel," ",bLevelPrice," ","Sell Entry: ",sLevel," ",sLevelPrice);
//         


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

   if(totalBuy>0 && totalVolume>0)
     {
      buyPct=(totalBuy/totalVolume)*100;
      buyPct=NormalizeDouble(buyPct,2);
     }

   if(totalSell>0 && totalVolume>0)
     {
      sellPct=(totalSell/totalVolume)*100;
      sellPct=NormalizeDouble(sellPct,2);
     }

   if(!WorkingHour())
     {
      CloseALL();
      DeleteALL();
     }

   if(!PosicaoAberta())
     {
      DeleteOrdersComment("STOP");
      DeleteOrdersComment("TAKE PROFIT");
     }

   if(Buy_opened() && Sell_opened())
     {
      DeleteALL();
      CloseByPosition();
     }

   if(WorkingHour() && (GlobalVariableGet(glob_entr_tot)<Repeat_Trades || Trade_Constantly))
     {
      if(BuySignal() && !Buy_opened() && !myorder.Select((ulong)GlobalVariableGet(cp_tick)))
        {
         CloseALL();
         DeleteALL();
         if(mytrade.BuyLimit(Entry_Volume,bLevelPrice,Symbol(),0,0,0,0,"BUY"))
           {
            GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
           }
         else Print("Erro enviar ordem ",GetLastError());

        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+


      if(SellSignal() && !Sell_opened() && !myorder.Select((ulong)GlobalVariableGet(vd_tick)))
        {
         CloseALL();
         DeleteALL();
         if(mytrade.SellLimit(Entry_Volume,sLevelPrice,Symbol(),0,0,0,0,"SELL"))
           {
            GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
           }
         else Print("Erro enviar ordem ",GetLastError());
        }
     }
   MytradeTransaction();

/*
   MqlDateTime stm_end,time_aux;
   TimeToStruct(TimeCurrent(),stm_end);
   time_aux=stm_end;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);
*/
   datetime tm_end=TimeCurrent();
   datetime tm_start=iTime(Symbol(),PERIOD_D1,0);
   if(HistorySelect(tm_start,tm_end))
     {
      GlobalVariableSet(deals_total_prev,(double)HistoryDealsTotal());
     }

   CreateTLabel(0,Symbol()+"tbV",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,31,(string)("Total Buy Volume: "+(string)totalBuy+" "+(string)buyPct+"%"),"Total Buy",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"tsV",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,46,(string)("Total Sell Volume: "+(string)totalSell+" "+(string)sellPct+"%"),"Total Sell",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"ttV",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,61,(string)("Total Volume: "+(string)totalVolume),"Total Volume",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"hhP",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,76,(string)("High Price: "+(string)highP),"High Price",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"lwP",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,91,(string)("Low Price: "+(string)lowP),"Low Price",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"ttT",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,106,(string)("Total Trades: "+DoubleToString(GlobalVariableGet(glob_entr_tot),2)),"Total Trades",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"ttL",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,121,(string)("Total Profit: "+(string)todaysLoss()),"Todays Profit",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"tp1",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,136,(string)("Price 1: "+(string)price1+" Volume: "+(string)vol1),"price1",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"tp2",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,151,(string)("Price 2: "+(string)price2+" Volume: "+(string)vol2),"price2",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"tp3",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,166,(string)("Price 3: "+(string)price3+" Volume: "+(string)vol3),"price3",clrDarkBlue,"Arial Bold",9);
   CreateTLabel(0,Symbol()+"tp4",0,CORNER_LEFT_UPPER,ANCHOR_LEFT_UPPER,11,181,(string)("Price 4: "+(string)price4+" Volume: "+(string)vol4),"price4",clrDarkBlue,"Arial Bold",9);

  }
//+------------------------------------------------------------------+

double totalVolume,bLevelPrice,sLevelPrice;
double totalSell,totalBuy;
int bcnt=0,scnt=0;
double lastBp=0,lastSp=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getBookContent()
  {
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(getBook)
     {
      bLevel=0;
      sLevel=0;
      int size=ArraySize(priceArray);
      int n=1;
      //Print("MarketBookInfo for ",Symbol()); 

      for(int i=size-1; i>=0; i--)
        {

         if((priceArray[i].type==1))
           {

            if(n==Entry_Level)
              {

               sLevelPrice=priceArray[i].price;
               sLevel=i;
              }
            n++;
           }
        }

      n=1;
      for(int i=0;i<size;i++)
        {

         if((priceArray[i].type==2))
           {
            if(n==Entry_Level)
              {
               bLevelPrice=priceArray[i].price;
               bLevel=i;
              }
            n++;
           }

         //Print((string)i+":",(string)priceArray[i].price 
         //       +" Volume = "+(string)priceArray[i].volume, 
         //        " type = ",(string)priceArray[i].type); 

         totalVolume+=priceArray[i].volume;

         if(priceArray[i].volume>vol1)
           {
            vol1=priceArray[i].volume;
            price1=priceArray[i].price;
           }
         if(priceArray[i].volume>vol2 && priceArray[i].volume<vol1)
           {
            vol2=priceArray[i].volume;
            price2=priceArray[i].price;
           }
         if(priceArray[i].volume>vol3 && priceArray[i].volume<vol1 && priceArray[i].volume<vol2)
           {
            vol3=priceArray[i].volume;
            price3=priceArray[i].price;
           }
         if(priceArray[i].volume>vol4 && priceArray[i].volume<vol1 && priceArray[i].volume<vol2 && priceArray[i].volume<vol3)
           {
            vol4=priceArray[i].volume;
            price4=priceArray[i].price;
           }

         if(priceArray[i].price>highP)
           {
            highP=priceArray[i].price;
           }
         if(priceArray[i].price<lowP || lowP==0)
           {
            lowP=priceArray[i].price;
           }

         if((priceArray[i].type==BOOK_TYPE_BUY || priceArray[i].type==BOOK_TYPE_BUY_MARKET))
           {

            //bLevelPrice=priceArray[i].price;
            totalBuy+=priceArray[i].volume;

            if(bcnt<Entry_Level && (priceArray[i].price>lastBp))
              {
               bcnt++;
               lastBp=priceArray[i].price;
              }
           }
         if((priceArray[i].type==BOOK_TYPE_SELL || priceArray[i].type==BOOK_TYPE_SELL_MARKET))
           {

            //sLevelPrice=priceArray[i].price;
            totalSell+=priceArray[i].volume;

            if(scnt<Entry_Level && (priceArray[i].price<lastSp || lastSp==0))
              {
               scnt++;
               lastSp=priceArray[i].price;
              }
           }
        }
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      Print("Could not get contents of the symbol DOM ",Symbol());
     }
  }

//+------------------------------------------------------------------+
double lastLot;
int lastEntry;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double todaysLoss()
  {
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
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {

      ulong deal_tickettt=HistoryDealGetTicket(i);
      datetime transaction_timett=(datetime)HistoryDealGetInteger(deal_tickettt,DEAL_TIME);
      double profittt   =                 HistoryDealGetDouble(deal_tickettt,DEAL_PROFIT);
      string symboltt   =                 HistoryDealGetString(deal_tickettt,DEAL_SYMBOL);
      int deal_typett=(int) HistoryDealGetInteger(deal_tickettt,DEAL_TYPE);
      datetime CurClosedTime=(datetime)HistoryDealGetInteger(deal_tickettt,DEAL_TIME);

      MqlDateTime hari;
      //Comment(TimeDayMQL4(transaction_timett), " ", TimeDayMQL4(TimeCurrent()));
      if(deal_tickettt>0 && symboltt==Symbol() && (deal_typett==1 || deal_typett==0)
         && TimeDayMQL4(transaction_timett)==TimeDayMQL4(TimeCurrent()) && transaction_timett>start_time_ea)
        {

         val+=profittt;

        }
     }
   return(val);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDayMQL4(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_week);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--------------------------------------------------------------------+
//      Create RECTANGLE_LABEL                                        |
//--------------------------------------------------------------------+
void RectLabelCreate(const string           name="RectLabel",
                     const int              x=0,
                     const int              y=0,
                     const int              width=50,
                     const int              height=18,
                     const color            back_clr=clrWhite)
  {

   if(name=="MOVE")
     {
      ObjectSetInteger(0,name,OBJPROP_BGCOLOR,clrDimGray);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(ObjectFind(0,name)!=-1)
     {
      ObjectSetInteger(0,name,OBJPROP_XDISTANCE,x);
      ObjectSetInteger(0,name,OBJPROP_YDISTANCE,y);
      ObjectSetInteger(0,name,OBJPROP_XSIZE,width);
      ObjectSetInteger(0,name,OBJPROP_YSIZE,height);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(ObjectFind(0,name)==-1)
     {
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseByPosition()
  {
   ulong tick_sell,tick_buy;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      while(Buy_opened() && Sell_opened())
        {
         tick_buy=TickecBuyPos();
         tick_sell=TickecSellPos();
         if(tick_buy>0 && tick_sell>0)mytrade.PositionCloseBy(tick_buy,tick_sell);
        }

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
ulong TickecBuyPos()
  {
   ulong tick=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Buy_opened())
     {

      for(int i=PositionsTotal()-1;i>=0; i--)
        {
         if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
           {
            if(myposition.PositionType()==POSITION_TYPE_BUY)
              {
               tick=myposition.Ticket();
               break;
              }
           }
        }

     }
   return tick;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
ulong TickecSellPos()
  {
   ulong tick=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Sell_opened())
     {
      for(int i=PositionsTotal()-1;i>=0; i--)
        {
         if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
           {
            if(myposition.PositionType()==POSITION_TYPE_SELL)
              {
               tick=myposition.Ticket();
               break;
              }
           }
        }

     }
   return tick;
  }
//+------------------------------------------------------------------+
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=mysymbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Buy_opened()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_BUY)
         return(true);  //It is a Buy
     }
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Sell_opened()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_SELL)
         return(true);  //It is a Buy
     }
   return(false);
  }
//+------------------------------------------------------------------+
bool PosicaoAberta()
  {
   if(myposition.SelectByMagic(Symbol(),Magic_Number)==true)
      return(myposition.PositionType()== POSITION_TYPE_BUY||myposition.PositionType()== POSITION_TYPE_SELL);
   else return(false);
  }
//+------------------------------------------------------------------+
void CloseALL()
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
        {
         if(!mytrade.PositionClose(PositionGetTicket(i)))
           {
            Print(PositionGetTicket(i),"PositionClose() method failed. Return code=",mytrade.ResultRetcode(),
                  ". Code description: ",mytrade.ResultRetcodeDescription());
           }
         else
           {
            Print(PositionGetTicket(i),"PositionClose() method executed successfully. Return code=",mytrade.ResultRetcode(),
                  " (",mytrade.ResultRetcodeDescription(),")");
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteALL()
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      ulong o_ticket=OrderGetTicket(j);
      if(o_ticket!=0)
        {
         myorder.Select(o_ticket);
         if(myorder.Magic()==Magic_Number && myorder.Symbol()==mysymbol.Name()) mytrade.OrderDelete(o_ticket);
        }
     }
  }
//+------------------------------------------------------------------+
void ClosePosType(ENUM_POSITION_TYPE ptype)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && myposition.Symbol()==mysymbol.Name())
        {
         if(!mytrade.PositionClose(PositionGetTicket(i)))
           {
            Print(PositionGetTicket(i),"PositionClose() method failed. Return code=",mytrade.ResultRetcode(),
                  ". Code description: ",mytrade.ResultRetcodeDescription());
           }
         else
           {
            Print(PositionGetTicket(i),"PositionClose() method executed successfully. Return code=",mytrade.ResultRetcode(),
                  " (",mytrade.ResultRetcodeDescription(),")");
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteOrders(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   bool signal;
   signal=totalBuy>0 && totalVolume>0;
   signal= signal&&((totalBuy/totalVolume)*100>=Entry_Percentage);
   signal=signal && ((bLevelPrice!=highP && bLevelPrice!=lowP) || !Trade_Extreme);
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   bool signal;
   signal=totalSell>0 && totalVolume>0;
   signal= signal&& ((totalSell/totalVolume)*100>=Entry_Percentage);
   signal=signal && ((sLevelPrice!=highP && sLevelPrice!=lowP) || !Trade_Extreme);
   return signal;
  }
//+------------------------------------------------------------------+
void MytradeTransaction()
  {
   ulong order_ticket;
/*   MqlDateTime stm_end,time_aux;
   TimeToStruct(TimeCurrent(),stm_end);
   time_aux=stm_end;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);
  */
   datetime tm_end=TimeCurrent();
   datetime tm_start=iTime(Symbol(),PERIOD_D1,0);
   if(HistorySelect(tm_start,tm_end))
     {
      GlobalVariableSet(deals_total,(double)HistoryDealsTotal());
      if(GlobalVariableGet(deals_total)>GlobalVariableGet(deals_total_prev))
        {
         ulong deals_ticket=HistoryDealGetTicket((ulong)GlobalVariableGet(deals_total)-1);
         mydeal.Ticket(deals_ticket);
         order_ticket=mydeal.Order();
         //         Print("order ",order_ticket);
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number)
           {
            if((order_ticket==(ulong)GlobalVariableGet(cp_tick) || order_ticket==(ulong)GlobalVariableGet(vd_tick)))
              {
               GlobalVariableSet(glob_entr_tot,GlobalVariableGet(glob_entr_tot)+1);
               totalTrades++;
              }

            if(order_ticket==(ulong)GlobalVariableGet(cp_tick))
              {
               myposition.SelectByTicket(order_ticket);
               if(mytrade.SellLimit(Entry_Volume,NormalizeDouble(myposition.PriceOpen()+_TakeProfit*ponto,digits),Symbol(),0,0,0,0,"TAKE PROFIT"))
                 {
                  GlobalVariableSet(tp_vd_tick,(double)mytrade.ResultOrder());
                 }
               else
                 {
                  Print("Erro enviar ordem ",GetLastError());
                  mytrade.SellLimit(Entry_Volume,mysymbol.Ask(),Symbol(),0,0,0,0,"TAKE PROFIT");
                 }
               if(mytrade.SellStop(Entry_Volume,NormalizeDouble(myposition.PriceOpen()-_Stop*ponto,digits),Symbol(),0,0,0,0,"STOP"))
                 {
                  GlobalVariableSet(stp_vd_tick,(double)mytrade.ResultOrder());
                 }
               else
                 {
                  Print("Erro enviar ordem ",GetLastError());
                  mytrade.Sell(Entry_Volume);
                 }

              }
            //--------------------------------------------------

            if(order_ticket==(ulong)GlobalVariableGet(vd_tick))
              {
               myposition.SelectByTicket(order_ticket);
               if(mytrade.BuyLimit(Entry_Volume,NormalizeDouble(myposition.PriceOpen()-_TakeProfit*ponto,digits),Symbol(),0,0,0,0,"TAKE PROFIT"))
                 {
                  GlobalVariableSet(tp_cp_tick,(double)mytrade.ResultOrder());
                 }
               else
                 {
                  Print("Erro enviar ordem ",GetLastError());
                  mytrade.BuyLimit(Entry_Volume,mysymbol.Bid(),Symbol(),0,0,0,0,"TAKE PROFIT");
                 }

               if(mytrade.BuyStop(Entry_Volume,NormalizeDouble(myposition.PriceOpen()+_Stop*ponto,digits),Symbol(),0,0,0,0,"STOP"))
                 {
                  GlobalVariableSet(stp_cp_tick,(double)mytrade.ResultOrder());
                 }
               else
                 {
                  Print("Erro enviar ordem ",GetLastError());
                  mytrade.Buy(Entry_Volume);
                 }

              }

           }//Fim mydeal symbol
        }//Fim deals>prev
     }//Fim HistorySelect
  }
//+------------------------------------------------------------------+
void DeleteOrdersComment(string comment)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.Comment()==comment)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+
bool IsConnect()
  {
   return TerminalInfoInteger(TERMINAL_CONNECTED);
  }
//+------------------------------------------------------------------+
void CheckConnection()
  {
   string msg;
   if(!(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_OPTIMIZATION) || IsStopped()))
     {
      if(Conexao!=IsConnect())
        {
         if(IsConnect())msg="Conexão Reestabelecida";
         else msg="Conexão Perdida";
         Print(msg);
         Alert(msg);
         if(TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(msg);
        }
      Conexao=IsConnect();
     }

  }
//+------------------------------------------------------------------+
void ProtectPosition()
  {
   ulong tick_pos;
   double cont_size,den;
   cont_size=mysymbol.ContractSize();
   if(Buy_opened() && !Sell_opened())
     {
      tick_pos=TickecBuyPos();
      myposition.SelectByTicket(tick_pos);
      den=((mysymbol.TickValue()*myposition.Volume())/mysymbol.TickSize());

      if(myposition.Profit()<-den*(_Stop+10*ticksize)/cont_size || myposition.Profit()>den*(_TakeProfit+10*ticksize)/cont_size)
        {
         DeleteALL();
         ClosePosType(POSITION_TYPE_BUY);
        }

     }
   if(Sell_opened() && !Buy_opened())
     {
      tick_pos=TickecSellPos();
      myposition.SelectByTicket(tick_pos);
      den=((mysymbol.TickValue()*myposition.Volume())/mysymbol.TickSize());

      if(myposition.Profit()<-den*(_Stop+10*ticksize)/cont_size || myposition.Profit()>den*(_TakeProfit+10*ticksize)/cont_size)
        {
         DeleteALL();
         ClosePosType(POSITION_TYPE_SELL);
        }

     }
  }
//+------------------------------------------------------------------+
