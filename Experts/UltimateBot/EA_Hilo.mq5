//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#define VERSION "1.0"// Mudar aqui as Versões

#property copyright "UltimabteBot <contato@ultimatebot.com.br>"
#property version   VERSION
/*#property link      "https://www.ultimatebot.com.br"
#property description   "AVISO: Você usará este EA em renda variável, portanto é um estratégia com risco alto,"
#property description   "ou seja, pode ter ganhos altos , mas também perdas."
#property description   "Antes de utilizar, encontre uma configuração adequada para seus objetivos."
#property description   "seus objetivos de investimento, nível de experiência e tolerância ao risco."
*/

#resource "\\Indicators\\hilo.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <Controls\Defines.mqh>
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
//#undef CONTROLS_LABEL_COLOR  

color borda_bg=clrNONE;//Cor Borda
color painel_bg=clrNONE;//Cor Painel 
color cor_txt_borda_bg=clrYellowGreen;//Cor Texto Borda
                                      //color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG          borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg

#include <Expert_Class_New.mqh>
MyPanel ExtDialog;

CLabel            m_label[50];
CPanel painel;

#define LARGURA_PAINEL 140 // Largura Painel
#define ALTURA_PAINEL 100 // Altura Painel



input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME para Verificar Entradas
input int MAGIC_NUMBER=20082018;//Número Mágico
ulong deviation_points=50;//Deviation em Pontos(Padrao)
sinput string SComum="############---------Comum--------########";//Comum
input double Lot=1;//Lote Entrada
input double _TakeProfit=30;//Take Profit em Pontos
sinput string SInd="############---------Indicadores--------########";//Indicadores
input uint           InpPeriod=13;       // Period
input ENUM_MA_METHOD InpMethod=MODE_SMMA;// Method
sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia
input string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:04";//Horario Inicial
input string end_hour="17:20";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario
sinput string sdias="FILTRO DOS DIAS DA SEMANA";//Dias da Semana
input bool trade0=true;// Operar Domingo
input bool trade1=true;// Operar Segunda
input bool trade2=true;// Operar Terça
input bool trade3=true;// Operar Quarta
input bool trade4=true;// Operar Quinta
input bool trade5=true;// Operar Sexta
input bool trade6=true;// Operar Sábado



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

struct DescPositions
  {
   ulong             pos_ticket;
   int               line_number;

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyPositions: public CObject
  {
public:
   ulong             pos_ticket;
   int               line_number;
   void SetNumber(int n){line_number=n;}
   void SetTicket(ulong t){pos_ticket=t;}
   int GetNumber(){return line_number;}
   ulong GetTicket(){return pos_ticket;}
   void              MyPositions(void);
   void             ~MyPositions(void);
  };
//+------------------------------------------------------------------+ 
//| Constructor                                                      | 
//+------------------------------------------------------------------+ 
MyPositions::MyPositions(void)
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
   MyPositions       PosAtual;
   MyPositions      *item;
   CArrayObj         PosAbertas;
   DescPositions     DescPosAtual;
   ulong             ticket_pos;
   int               positions_total;
   int               hilo_handle;
   double            HiLoBuffer[],HiLoColor[];
   string            informacoes;
   double            sl_position,tp_position;
   double            vol_pos,vol_stp;
   double            preco_stp;
   double            preco_medio;
   bool              opt_tester;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   bool              buysignal,sellsignal;
   double            Buyprice,Sellprice;

public:
                     MyRobot();
                    ~MyRobot();
   int               OnInit();
   void              OnDeinit(const int reason);
   void              OnTick();
   void              OnTimer();
   string GetCurrency(){return SymbolInfoString(original_symbol,SYMBOL_CURRENCY_BASE);}
   bool              TimeDayFilter();
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
//  EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int MyRobot::OnInit()
  {
   EventSetTimer(1);
   tradeOn=true;
   setExpName();
   setSymbol(Symbol());
   setOriginalSymbol(Symbol());
   setMagic(MAGIC_NUMBER);
   if(SymbolInfoInteger(original_symbol,SYMBOL_EXPIRATION_MODE)==2)order_time_type=1;
   else order_time_type=0;
   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(MAGIC_NUMBER);
   mytrade.SetDeviationInPoints(50);
   opt_tester=(MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_PROFILER)) && !MQLInfoInteger(MQL_VISUAL_MODE);
   if(!opt_tester) mytrade.LogLevel(LOG_LEVEL_NO);
   else mytrade.LogLevel(LOG_LEVEL_ERRORS);
   lucro_orders=LucroOrdens();
   if(!opt_tester)
     {
      lucro_orders_mes=LucroOrdensMes();
      lucro_orders_sem=LucroOrdensSemana();
     }
//mytrade.SetTypeFillingBySymbol(original_symbol);
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

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   ulong curChartID=ChartID();

   hilo_handle=iCustom(_Symbol,periodoRobo,"::Indicators\\hilo.ex5",InpPeriod,InpMethod);
   ChartIndicatorAdd(curChartID,0,hilo_handle);

   ArraySetAsSeries(HiLoBuffer,true);
   ArraySetAsSeries(HiLoColor,true);

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(ChartID(),CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(Lot<mysymbol.LotsMin())
     {
      string erro="Lote deve ser maior ou igual a "+DoubleToString(mysymbol.LotsMin(),2);
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
   IndicatorRelease(hilo_handle);
   DeletaIndicadores();
   EventKillTimer();
//---
  }
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
      hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
      hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

      lucro_orders=LucroOrdens();
      if(!opt_tester)
        {
         lucro_orders_mes=LucroOrdensMes();
         lucro_orders_sem=LucroOrdensSemana();
        }
     }

   timerOn=true;

   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
     }

   if(!timerOn)
     {
      if(daytrade)
        {
         if(OrdersTotal()>0)DeleteALL();
         if(PositionsTotal()>0)CloseALL();
        }
      return;
     }

   if(!tradeOn)return;


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

   if(PosicaoAberta())lucro_positions=LucroPositions();
   else lucro_positions=0;
   lucro_total=lucro_orders+lucro_positions;
   if(!opt_tester)
     {
      lucro_total_semana=lucro_orders_sem+lucro_positions;
      lucro_total_mes=lucro_orders_mes+lucro_positions;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      if(OrdersTotal()>0)
         DeleteALL();
      CloseALL();
      tradeOn=false;
      informacoes="EA encerrado lucro ou prejuizo";
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened()) CloseByPosition();

   if(tradeOn && timerOn)

     { // inicio Trade On
      
      if(Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo))
        {

/*     Print("pos Ab ",PosAbertas.Total());
         //iterate over orders within MyOrders
         positions_total=PosAbertas.Total();
         int cont=0;
         while(cont<positions_total)
           {
            cont++;
            item=new MyPositions;
            item=PosAbertas.At(0); //get order object at index i
            if(!myposition.SelectByTicket(item.GetTicket()))
              {
               PosAbertas.Delete(0);
               continue;
              }
            Print(item.GetNumber()); //print ticket of order object at index i
            Print(item.GetTicket()); //print ticket of order object at index i
           }*/

         buysignal=BuySignal() && !Buy_opened();
         sellsignal=SellSignal()  && !Sell_opened();

         if(buysignal)
           {

            sl_position=NormalizeDouble(MathRound(HiLoBuffer[1]/ticksize)*ticksize-ticksize,digits);
            tp_position=NormalizeDouble(ask+_TakeProfit*ponto,digits);
            if(mytrade.Buy(Lot,original_symbol,0,sl_position,tp_position,"BUY"+exp_name))
              {

               ticket_pos=mytrade.ResultOrder();
              gv.Set("cp_tick",(double)ticket_pos);

              }
            else
               Print("Erro enviar ordem ",GetLastError());
           }

         if(sellsignal)
           {
            sl_position=NormalizeDouble(MathRound(HiLoBuffer[1]/ticksize)*ticksize+ticksize,digits);
            tp_position=NormalizeDouble(bid-_TakeProfit*ponto,digits);
            if(mytrade.Sell(Lot,original_symbol,0,sl_position,tp_position,"SELL"+exp_name))
              {
               ticket_pos=mytrade.ResultOrder();
               gv.Set("vd_tick",(double)ticket_pos);
              }
            else
               Print("Erro enviar ordem ",GetLastError());
           }
        } //Fim Nova Barra

     } //End Trade On

  } //End OnTick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::BuySignal()
  {
   bool signal=false;
   signal=HiLoColor[1]==0.0 && HiLoColor[2]!=0.0;
   return signal;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal=false;
   signal=HiLoColor[1]==1.0 && HiLoColor[2]!=1.0;
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
   b_get=CopyBuffer(hilo_handle,0,0,5,HiLoBuffer)<=0 || 
         CopyBuffer(hilo_handle,1,0,5,HiLoColor)<=0 || 
         CopyHigh(Symbol(),PERIOD_CURRENT,0,5,high)<=0 || 
         CopyOpen(Symbol(),PERIOD_CURRENT,0, 5, open) <= 0 ||
         CopyLow(Symbol(), PERIOD_CURRENT, 0, 5, low) <= 0 ||
         CopyClose(Symbol(),PERIOD_CURRENT,0,5,close) <= 0;
   return (b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
               if(Buyprice==0)
                  Buyprice=mysymbol.Ask();

               sl_position=myposition.StopLoss();
               tp_position = NormalizeDouble(Buyprice + _TakeProfit * ponto, digits);
               mytrade.PositionModify(trans.order,sl_position,tp_position);
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
               if(Sellprice==0)
                  Sellprice=mysymbol.Bid();
               sl_position = myposition.StopLoss();
               tp_position = NormalizeDouble(Sellprice - _TakeProfit * ponto, digits);
               mytrade.PositionModify(trans.order,sl_position,tp_position);

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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
bool MyRobot::TimeDayFilter()
  {
   bool filter;
   MqlDateTime TimeToday;
   TimeToStruct(TimeCurrent(),TimeToday);
   switch(TimeToday.day_of_week)
     {
      case 0:
         filter=trade0;
         break;
      case 1:
         filter=trade1;
         break;
      case 2:
         filter=trade2;
         break;
      case 3:
         filter=trade3;
         break;
      case 4:
         filter=trade4;
         break;
      case 5:
         filter=trade5;
         break;
      case 6:
         filter=trade6;
         break;
      default:
         filter=false;
         break;

     }
   return filter;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

/* if(TimeCurrent()>D'2019.06.15 23:59:59')
     {
      string erro="Data de Validade Expirou";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO)
     {
      string erro="EA permitido apenas em conta DEMO";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }
*/
   if(!ChartSetInteger(ChartID(),CHART_SHIFT,0,LARGURA_PAINEL+30))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }

   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      //      if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
      //       return(INIT_FAILED);

      //  if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,ChartHeightInPixelsGet()-ALTURA_PAINEL,LARGURA_PAINEL,ChartHeightInPixelsGet()))

      if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,ChartWidthInPixels()-LARGURA_PAINEL,
         50,ChartWidthInPixels(),50+ALTURA_PAINEL))
         return(INIT_FAILED);


      //--- run application 

      ExtDialog.Run();
     }

   return MyEA.OnInit();

//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   MyEA.OnTimer();
   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      ExtDialog.OnTick();
/*if(ExtDialog.Height()!=ChartHeightInPixelsGet()-ALTURA_PAINEL)
        {
         ExtDialog.Move(0,ChartHeightInPixelsGet()-ALTURA_PAINEL);
         painel.Move(0,ChartHeightInPixelsGet()-ALTURA_PAINEL);
        }*/
      //ExtDialog.Minimized(false);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      ExtDialog.Destroy(reason);
      painel.Destroy(reason);
     }

//--- Código de motivo de desinicialização   
   Print(__FUNCTION__," UninitializeReason() = ",getUninitReasonText(UninitializeReason()));
   MyEA.OnDeinit(reason);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   MyEA.OnTick();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void OnChartEvent(const int id,// event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyPanel::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {

   int xx1=int(0.7*INDENT_LEFT);
   int yy1=INDENT_TOP;
   int xx2=int(xx1+0.7*BUTTON_WIDTH);
   int yy2=int(yy1+0.5*BUTTON_HEIGHT);

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);

   if(!CreatePanel(chart,subwin,painel,x1,y1,x2,y2))
      return (false);

//--- create dependent controls 

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Lucro Mês: "+DoubleToString(MyEA.LucroTotalMes(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[0].Color(clrYellowGreen);
   m_label[0].FontSize(8);

   xx1=int(0.7*INDENT_LEFT);
   yy1=int(INDENT_TOP+0.5*BUTTON_HEIGHT+0.6*CONTROLS_GAP_Y);
   xx2=int(xx1+0.7*BUTTON_WIDTH);
   yy2=int(yy1+0.5*BUTTON_HEIGHT);

   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"Lucro Semana: "+DoubleToString(MyEA.LucroTotalSemana(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[1].Color(clrYellowGreen);
   m_label[1].FontSize(8);

   xx1=int(0.7*INDENT_LEFT);
   yy1=int(INDENT_TOP+1.2*BUTTON_HEIGHT+0.6*CONTROLS_GAP_Y);
   xx2=int(xx1+0.7*BUTTON_WIDTH);
   yy2=int(yy1+0.5*BUTTON_HEIGHT);

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"Lucro Dia: "+DoubleToString(MyEA.LucroTotal(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[2].Color(clrYellowGreen);
   m_label[2].FontSize(8);

// Minimized(false);//Mudar Se nao quiser minimizar

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyPanel::OnTick(void)
  {
   m_label[0].Text("Lucro Mês: "+DoubleToString(MyEA.LucroTotalMes(),2));
   m_label[1].Text("Lucro Semana: "+DoubleToString(MyEA.LucroTotalSemana(),2));
   m_label[2].Text("Lucro Dia: "+DoubleToString(MyEA.LucroTotal(),2));
//Maximize();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(MyPanel)

EVENT_MAP_END(CAppDialog)
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
