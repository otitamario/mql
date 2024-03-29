//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#define VERSION "1.0"// Mudar aqui as Versões

#property copyright "UltimabteBot <contato@ultimatebot.com.br>"
#property version   VERSION
#property link      "https://www.ultimatebot.com.br"
#property description "https://www.ultimatebot.com.br"
#property description   "AVISO: Você usará este EA em renda variável, portanto é um estratégia com risco alto,"
#property description   "ou seja, pode ter ganhos altos , mas também perdas."
#property description   "Antes de utilizar, encontre uma configuração adequada para seus objetivos."
#property description   "seus objetivos de investimento, nível de experiência e tolerância ao risco."

#property icon "\\Files\\UltimateBot.ico"

#resource "\\Files\\UltimateBotLitlle.bmp"

#include <Controls\Defines.mqh>
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
//#undef CONTROLS_LABEL_COLOR  

color borda_bg=clrBlack;//Cor Borda
color painel_bg=clrDarkBlue;//Cor Painel 
color cor_txt_borda_bg=clrYellowGreen;//Cor Texto Borda
                                      //color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG          borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg

#include <Expert_Class_New.mqh>
#include <Arrays\ArrayObj.mqh>


CChartObjectBmpLabel FotoUltimate;

input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input int MAGIC_NUMBER=1111;//Número Mágico
ulong deviation_points=500;//Deviation em Pontos(Padrao)
sinput string SComum="############---------Comum--------########";//Comum
input double Lot=0.01;//Lote Entrada
input double _TakeProfit=300;//Take Profit em Pontos
input double prejuizo=500.0;//Prejuizo em Moeda para Abrir nova Posição

                            //Fim Parametros

//+------------------------------------------------------------------+
//|                                                   MyRobot.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <ChartObjects\ChartObjectsLines.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyPositions : public CObject
  {
protected:
   ulong             pos_id;
   double            pos_profit;
   bool              profit_start;
public:
                     MyPositions(void);
                    ~MyPositions(void);
   void SetPosProfit(double profit){pos_profit=profit;};
   void SetPosId(ulong id){pos_id=id;};
   void SetPosId(bool start){profit_start=start;};

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MyPositions::MyPositions(void) : pos_id(0),
                                 pos_profit(0),
                                 profit_start(false)

  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
MyPositions::~MyPositions(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyRobot : public MyExpert
  {
private:
   CChartObjectVLine VLine[];
   CArrayObj         LongArray;
   CArrayObj         ShortArray;
   MyPositions       PosSample;
   CArrayLong        LongStartProf;
   CArrayLong        ShortStartProf;
   string            informacoes;
   double            sl_position,tp_position;
   double            vol_pos,vol_stp;
   ushort            TotalBuys,TotalSells;
   bool              buyopen,sellopen;
   double            preco_stp;
   double            preco_medio;
   bool              opt_tester;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   bool              buysignal,sellsignal;
   double            Buyprice,Sellprice;
   int               idx_barra;
public:
                     MyRobot();
                    ~MyRobot();
   int               OnInit();
   void              OnDeinit(const int reason);
   void              OnTick();
   void              OnTimer();
   string GetCurrency(){return SymbolInfoString(original_symbol,SYMBOL_CURRENCY_BASE);}
   virtual bool      GetIndValue();
   virtual bool      BuySignal();
   virtual bool      SellSignal();
   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);

  };

MyRobot MyEA;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MyRobot::MyRobot()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MyRobot::~MyRobot()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTimer()
  {
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int MyRobot::OnInit()
  {
   tradeOn=true;
   setExpName();
   setSymbol(Symbol());
   setOriginalSymbol(Symbol());
   setMagic(MAGIC_NUMBER);
   if(SymbolInfoInteger(original_symbol,SYMBOL_EXPIRATION_MODE)==2)order_time_type=1;
   else order_time_type=0;
   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(MAGIC_NUMBER);
   mytrade.SetDeviationInPoints(deviation_points);
   if(!opt_tester) mytrade.LogLevel(LOG_LEVEL_NO);
   else mytrade.LogLevel(LOG_LEVEL_ERRORS);
   lucro_orders=LucroOrdens();
   if(!opt_tester)
     {
      lucro_orders_mes=LucroOrdensMes();
      lucro_orders_sem=LucroOrdensSemana();
     }
   mytrade.SetTypeFilling(ORDER_FILLING_RETURN);
   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);

   int find_wdo=StringFind(original_symbol,"WDO");
   int find_dol=StringFind(original_symbol,"DOL");
   if(find_dol>=0|| find_wdo>=0) ponto=1.0;
   gv.Init(symbol,Magic_Number);
   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today_prev",(double)TimeNow.day_of_year);
   setNameGvOrder();

   ulong curChartID=ChartID();

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(ChartID(),CHART_SHOW_TRADE_LEVELS,false);
   ChartSetInteger(ChartID(),CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

   if(Lot<mysymbol.LotsMin())
     {
      string erro="Lote deve ser maior ou igual a "+DoubleToString(mysymbol.LotsMin(),2);
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(prejuizo<=0)
     {
      string erro="Digite um prejuízo >0";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   DeletaIndicadores();
   EventKillTimer();
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+-------------ROTINAS----------------------------------------------+

void MyRobot::OnTick()
  {

   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today",(double)TimeNow.day_of_year);

   bool novodia;
   novodia=Bar_NovoDia.CheckNewBar(original_symbol,PERIOD_D1);

   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      gv.Set("glob_entr_tot",0.0);
      gv.Set("deals_total_prev",0.0);
      gv.Set("last_stop",0.0);
      tradeOn=true;

     }

   gv.Set("gv_today_prev",gv.Get("gv_today"));

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

   buyopen=Buy_opened();
   sellopen=Sell_opened();

   if(!buyopen)
     {
      tp_position=mysymbol.NormalizePrice(mysymbol.Ask()+_TakeProfit*ponto);
      if(mytrade.Buy(Lot,original_symbol,0,0,tp_position,"BUY"+exp_name))
        {
         gv.Set(cp_tick,(double)mytrade.ResultOrder());
        }
      else Print("Erro enviar ordem ",GetLastError());
     }

   if(!sellopen)
     {
      tp_position=mysymbol.NormalizePrice(mysymbol.Bid()-_TakeProfit*ponto);
      if(mytrade.Sell(Lot,original_symbol,0,0,tp_position,"SELL"+exp_name))
        {
         gv.Set(vd_tick,(double)mytrade.ResultOrder());
        }
      else Print("Erro enviar ordem ",GetLastError());
     }

  } //End OnTick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal=false;
   return signal;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool MyRobot::BuySignal()
  {
   bool signal=false;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool MyRobot::GetIndValue()
  {
   bool b_get;
   b_get=CopyHigh(Symbol(),periodoRobo,0,5,high)<=0 || 
         CopyOpen(Symbol(),periodoRobo,0, 5, open) <= 0 ||
         CopyLow(Symbol(), periodoRobo, 0, 5, low) <= 0 ||
         CopyClose(Symbol(),periodoRobo,0,5,close) <= 0;
   return (b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


void MyRobot::OnTradeTransaction(const MqlTradeTransaction &trans,
                                 const MqlTradeRequest &request,
                                 const MqlTradeResult &result)
  {

   if(trans.symbol!=original_symbol)
      return;
   int TENTATIVAS=10;

//--- get transaction type as enumeration value
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history

//--- if a request was sent
   if(trans.type==TRADE_TRANSACTION_REQUEST)
     {
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(type==TRADE_TRANSACTION_ORDER_UPDATE)
     {
     }

   if(type==TRADE_TRANSACTION_HISTORY_UPDATE)
     {
     }

   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long deal_ticket= 0;
      long deal_order = 0;
      long deal_time=0;
      long deal_time_msc=0;
      ENUM_DEAL_TYPE deal_type=-1;
      long deal_entry=-1;
      ulong deal_magic = 0;
      long deal_reason = -1;
      long deal_position_id=0;
      double deal_volume= 0.0;
      double deal_price = 0.0;
      double deal_commission=0.0;
      double deal_swap=0.0;
      double deal_profit = 0.0;
      string deal_symbol = "";
      string deal_comment= "";
      string deal_external_id="";
      if(HistoryDealSelect(trans.deal))
        {
         deal_ticket= HistoryDealGetInteger(trans.deal,DEAL_TICKET);
         deal_order = HistoryDealGetInteger(trans.deal,DEAL_ORDER);
         deal_time=HistoryDealGetInteger(trans.deal,DEAL_TIME);
         deal_time_msc=HistoryDealGetInteger(trans.deal,DEAL_TIME_MSC);
         deal_type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
         deal_magic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
         deal_reason= HistoryDealGetInteger(trans.deal,DEAL_REASON);
         deal_position_id=HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);

         deal_volume= HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_price = HistoryDealGetDouble(trans.deal,DEAL_PRICE);
         deal_commission=HistoryDealGetDouble(trans.deal,DEAL_COMMISSION);
         deal_swap=HistoryDealGetDouble(trans.deal,DEAL_SWAP);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);

         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_comment=HistoryDealGetString(trans.deal,DEAL_COMMENT);
         deal_external_id=HistoryDealGetString(trans.deal,DEAL_EXTERNAL_ID);

         if(deal_symbol!=original_symbol)
            return;
         if(deal_magic==Magic_Number)
           {
            gv.Set("last_deal_time",(double)deal_time);

            if(deal_comment=="BUY"+exp_name)

              {
               myposition.SelectByTicket(trans.order);
               int cont = 0;
               Buyprice = 0;
               while(Buyprice==0 && cont<TENTATIVAS)
                 {
                  Buyprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(Buyprice== 0)
                  Buyprice= mysymbol.Ask();

               tp_position=NormalizeDouble(Buyprice+_TakeProfit*ponto,digits);
               mytrade.PositionModify(trans.order,0,tp_position);
              }
            //--------------------------------------------------

            if(deal_comment=="SELL"+exp_name)
              {
               myposition.SelectByTicket(trans.order);
               Sellprice= myposition.PriceOpen();
               int cont = 0;
               Sellprice= 0;
               while(Sellprice==0 && cont<TENTATIVAS)
                 {
                  Sellprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(Sellprice== 0)
                  Sellprice= mysymbol.Bid();
               tp_position = NormalizeDouble(Sellprice - _TakeProfit * ponto, digits);
               mytrade.PositionModify(trans.order,0,tp_position);

              }

            if((deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL) && (deal_entry==DEAL_ENTRY_OUT || deal_entry==DEAL_ENTRY_OUT_BY))
              {

               if(deal_profit<0)
                 {
                  Print("Saída por STOP LOSS");
                 }

               if(deal_profit>0)
                 {
                  Print("Saída no GAIN");
                 }
              }

            lucro_orders=LucroOrdens();
            lucro_orders_mes = LucroOrdensMes();
            lucro_orders_sem = LucroOrdensSemana();

           } //Fim deal magic
        }
      else
         return;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(type==TRADE_TRANSACTION_HISTORY_ADD)
     {
      myhistory.Ticket(trans.order);
      if(myhistory.Magic()!=(ulong)Magic_Number)
         return;

      if((myhistory.Comment()=="BUY"+exp_name || myhistory.Comment()=="SELL"+exp_name) && trans.order_state==ORDER_STATE_FILLED)
        {
         gv.Set("glob_entr_tot",gv.Get("glob_entr_tot")+1);
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   MyEA.OnTradeTransaction(trans,request,result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(!ChartSetInteger(ChartID(),CHART_SHIFT,0,50))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }

   FotoUltimate.Create(ChartID(),"FotoUltimate",0,0,0);
   FotoUltimate.BmpFileOn("::Files\\UltimateBotLitlle.bmp");
   FotoUltimate.SetInteger(OBJPROP_XSIZE,80);
   FotoUltimate.SetInteger(OBJPROP_YSIZE,60);
   FotoUltimate.SetInteger(OBJPROP_XDISTANCE,100);
   FotoUltimate.SetInteger(OBJPROP_YDISTANCE, 30);

   FotoUltimate.Corner(CORNER_RIGHT_UPPER);

   return MyEA.OnInit();

//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   MyEA.OnTimer();
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

//--- Código de motivo de desinicialização   
   Print(__FUNCTION__," UninitializeReason() = ",getUninitReasonText(UninitializeReason()));
   MyEA.OnDeinit(reason);

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   MyEA.OnTick();

  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int ChartWidthInPixels(const long chart_ID=0)
  {
//--- prepare the variable to get the property value
   long result=-1;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetInteger(chart_ID,CHART_WIDTH_IN_PIXELS,0,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return((int)result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ChartHeightInPixelsGet(const long chart_ID=0,const int sub_window=0)
  {
//--- prepare the variable to get the property value
   long result=-1;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetInteger(chart_ID,CHART_HEIGHT_IN_PIXELS,sub_window,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return((int)result);
  }
//+------------------------------------------------------------------+
string getUninitReasonText(int reasonCode)
  {
   string text="";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- 
   switch(reasonCode)
     {
      case REASON_ACCOUNT:
         text="Account was changed";break;
      case REASON_CHARTCHANGE:
         text="Symbol or timeframe was changed";break;
      case REASON_CHARTCLOSE:
         text="Chart was closed";break;
      case REASON_PARAMETERS:
         text="Input-parameter was changed";break;
      case REASON_RECOMPILE:
         text="Program "+__FILE__+" was recompiled";break;
      case REASON_REMOVE:
         text="Program "+__FILE__+" was removed from chart";break;
      case REASON_TEMPLATE:
         text="New template was applied to chart";break;
      default:text="Another reason";
     }
//--- 
   return text;
  }
//+------------------------------------------------------------------+
