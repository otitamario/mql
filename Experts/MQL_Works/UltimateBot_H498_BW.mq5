//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#define VERSION "1.0"// Mudar aqui as Versões

#property copyright "UltimabteBot <contato@ultimatebot.com.br>"
#property version   VERSION
#property link      "https://www.ultimatebot.com.br"
#property description   "AVISO: Você usará este EA em renda variável, portanto é um estratégia com risco alto,"
#property description   "ou seja, pode ter ganhos altos , mas também perdas."
#property description   "Antes de utilizar, encontre uma configuração adequada para seus objetivos."
#property description   "seus objetivos de investimento, nível de experiência e tolerância ao risco."
#property icon "\\Files\\UltimateBot.ico"


#resource "\\Indicators\\CAPZACK v1.2.ex5"
#resource "\\Indicators\\bw-wiseman-1.ex5"
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
MyPanel ExtDialog;

CLabel            m_label[50];

#define LARGURA_PAINEL 200 // Largura Painel
#define ALTURA_PAINEL 130 // Altura Painel




// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong MAGIC_NUMBER=1;//Número Mágico
ulong deviation_points=50;//Deviation em Pontos(Padrao)
input string SEstrateg="############-------------Estratégia----------########";//Estratégia
input double Lot=0.01;//Lote Entrada
input double _Stop=300;//Stop Loss em Pontos
input double _TakeProfit=300;//Take Profit em Pontos
input double Multiplier=2;//Multiplicado Martingale
input double pts_grid=400;//Diferença em Pontos Entradas
sinput string strailprof="###------------------------Trailing Profit---------------------#####";    //Trailing Profit
input bool UsarTrailingProfit=false;//Usar Trailing Profit
input double TrailProfitMin1=100;//Lucro Mínimo em Moeda para Iniciar Trailing Profit
input double TrailPerc1=20;//Porcentagem Retração do Lucro para Fechar Posição
input double TrailStep=10;//Atualização em Moeda do Trailinng

sinput string Lucro="###---------------------Usar Lucro/Prejuizo para Fechamento-----------------------#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia
sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="10:00";//Horario Inicial
input string end_hour="16:50";//Horario Final
input bool daytrade=false;//DAYTRADE - Fechar Posicao Fim do Horario
sinput string sdias="FILTRO DOS DIAS DA SEMANA";//Dias da Semana
input bool trade0=true;// Operar Domingo
input bool trade1=true;// Operar Segunda
input bool trade2=true;// Operar Terça
input bool trade3=true;// Operar Quarta
input bool trade4=true;// Operar Quinta
input bool trade5=true;// Operar Sexta
input bool trade6=true;// Operar Sábado
sinput string sind="----------Indicadores------------------";//Indicadores
sinput string sindmed="---------------------------------------";//Médias
input int period_mfast=200;               // Período Média 
input ENUM_MA_METHOD modo_mfast=MODE_EMA;               // Modo Média Rápida
input ENUM_APPLIED_PRICE app_mfast=PRICE_CLOSE;//Applied Price Média Rápida
sinput string SEstbw="----Bw-Wiseman-----";//Bw-Wiseman
input uint                    _back=2;                       // Number of bars for analysis
input uint                    _jaw_period=13;                // Period for calculating jaws
input uint                    _jaw_shift=8;                  // Horizontal shift of jaws
input uint                    _teeth_period=8;               // Teeth calculation period
input uint                    _teeth_shift=5;                // Horizontal shift of teeth
input uint                    _lips_period=5;                // Period for calculating lips
input uint                    _lips_shift=3;                 // Horizontal shift of lips
input ENUM_MA_METHOD          _ma_method=MODE_SMMA;          // Smoothing type
input ENUM_APPLIED_PRICE      _applied_price=PRICE_MEDIAN;   // Price type or handle

sinput string SEstCAP="----CAPZACK-----";//Estratégia CAPZACK
input int center_period=100;//Centered TMA hal period
input int average_period=100;//Average true range period
input double average_mult=2.4;//Average true range multiplier
input int center_angle=4;//Centered TMA angle
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyRobot: public MyExpert
  {
private:
   CChartObjectBmpLabel FotoUltimate;
   CiMA             *mfast;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   double            sl_position,tp_position;
   int               bw_handle;
   double            BW_Sell[],BW_Buy[];
   int               cap_handle;
   double            CAP_Sell[],CAP_Buy[];

public:
   void              MyRobot();
   void             ~MyRobot();
   int               OnInit();
   void              OnDeinit(const int reason);
   void              OnTick();
   void              OnTimer();
   bool              TimeDayFilter();
   virtual bool      GetIndValue();
   virtual bool      BuySignal();
   virtual bool      SellSignal();
   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);
   int               Loss();
   double            LastEntryPrice(ENUM_POSITION_TYPE ptype);
   int               CountPositions(ENUM_POSITION_TYPE ptype);
   double            CalcLot(ENUM_POSITION_TYPE ptype);

  };

MyRobot MyEA;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::MyRobot()
  {

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::~MyRobot()
  {
   gv.Deinit();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::OnInit(void)
  {

   tradeOn=true;
   setExpName();
   setSymbol(Symbol());
   setOriginalSymbol(Symbol());
   setMagic(MAGIC_NUMBER);
   setPeriod(periodoRobo);
   if(SymbolInfoInteger(original_symbol,SYMBOL_EXPIRATION_MODE)==2)order_time_type=1;
   else order_time_type=0;
   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.SetDeviationInPoints(50);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
   mytrade.SetTypeFillingBySymbol(original_symbol);
   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);

   int find_wdo=StringFind(original_symbol,"WDO");
   int find_dol=StringFind(original_symbol,"DOL");
   if(find_dol>=0|| find_wdo>=0) ponto=1.0;
   gv.Init(symbol,Magic_Number);
   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today_prev",(double)TimeNow.day_of_year);
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   setNameGvOrder();

   ulong curChartID=ChartID();

   mfast=new CiMA;
   mfast.Create(Symbol(),periodoRobo,period_mfast,0,modo_mfast,app_mfast);
   mfast.AddToChart(curChartID,0);

   cap_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\CAPZACK v1.2.ex5",
                      center_period,0,average_period,average_mult,center_angle);

   ChartIndicatorAdd(curChartID,0,cap_handle);

   ArraySetAsSeries(CAP_Buy,true);
   ArraySetAsSeries(CAP_Sell,true);

   bw_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\bw-wiseman-1.ex5",
                     _back,_jaw_period,_jaw_shift,_teeth_period,_teeth_shift,_lips_period,_lips_shift,_ma_method,_applied_price);

   ChartIndicatorAdd(curChartID,0,bw_handle);

   ArraySetAsSeries(BW_Buy,true);
   ArraySetAsSeries(BW_Sell,true);

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(ChartID(),CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_FAILED);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Lot<mysymbol.LotsMin())
     {
      string erro="Lote deve ser maior ou igual a "+DoubleToString(mysymbol.LotsMin(),2);
      MessageBox(erro);
      Print(erro);
      return(INIT_FAILED);
     }

// parametros incorretos desnecessarios na otimizacao

   FotoUltimate.Create(ChartID(),"FotoUltimate",0,0,0);
   FotoUltimate.BmpFileOn("::Files\\UltimateBotLitlle.bmp");
   FotoUltimate.SetInteger(OBJPROP_XSIZE,80);
   FotoUltimate.SetInteger(OBJPROP_YSIZE,60);
   FotoUltimate.SetInteger(OBJPROP_XDISTANCE,100);
   FotoUltimate.SetInteger(OBJPROP_YDISTANCE, 30);

   FotoUltimate.Corner(CORNER_RIGHT_UPPER);

//ChartGetInteger(0,CHART_WIDTH_IN_PIXELS)-160),(i+1)*Y_LABEL+10)

   return(INIT_SUCCEEDED);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTimer()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   delete(mfast);
   DeletaIndicadores();
   EventKillTimer();

  };
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
void MyRobot::OnTick(void)
  {

   static double profit=0.0;
   static double profit_prev=0.0;
   static double stop_partial_profit=0.0;

   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today",(double)TimeNow.day_of_year);

   bool novodia;
   novodia=Bar_NovoDia.CheckNewBar(original_symbol,PERIOD_D1);

   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      gv.Set("glob_entr_tot",0.0);
      gv.Set("deals_total_prev",0.0);
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

   mfast.Refresh();

   if(bid>=ask)return;//Leilão

   if(!TerminalInfoInteger(TERMINAL_CONNECTED))return;


   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   lucro_total=LucroTotal();
   lucro_total_semana=LucroTotalSemana();
   lucro_total_mes=LucroTotalMes();
   lucro_positions=LucroPositions();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
     }

   profit=lucro_positions;

   if(UsarTrailingProfit && profit>=TrailProfitMin1 && profit>=TrailStep+profit_prev)
      stop_partial_profit=profit*(1-TrailPerc1*0.01);

   if(UsarTrailingProfit && profit_prev>stop_partial_profit && profit<=stop_partial_profit && stop_partial_profit>0)
     {
      if(OrdersTotal()>0)
         DeleteALL();
      CloseALL();
      Print("EA encerrado na meta parcial");
     }

   profit_prev=profit;

   if(!PosicaoAberta())stop_partial_profit=0.0;

   timerOn=true;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!timerOn && daytrade)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
      return;
     }

   if(!tradeOn)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
      return;
     }

   if(tradeOn && timerOn)

     {// inicio Trade On

      if(Buy_opened())
        {
         if(bid>=mfast.Main(0))ClosePosType(POSITION_TYPE_BUY);
        }
      if(Sell_opened())
        {
         if(ask<=mfast.Main(0))ClosePosType(POSITION_TYPE_SELL);
        }

      if(Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo))
        {

         if(BuySignal())
           {
            sl_position=0.0;
            tp_position=0.0;
            if(_Stop>0)sl_position=NormalizeDouble(bid-_Stop*ponto,digits);
            if(_TakeProfit>0)tp_position=NormalizeDouble(ask+_TakeProfit*ponto,digits);
            if(!mytrade.Buy(CalcLot(POSITION_TYPE_BUY),original_symbol,0,sl_position,tp_position,"BUY"+exp_name))
               Print("Erro enviar ordem ",GetLastError());
           }

         if(SellSignal())
           {
            sl_position=0.0;
            tp_position=0.0;
            if(_Stop>0)sl_position=NormalizeDouble(ask+_Stop*ponto,digits);
            if(_TakeProfit>0)tp_position=NormalizeDouble(bid-_TakeProfit*ponto,digits);
            if(!mytrade.Sell(CalcLot(POSITION_TYPE_SELL),original_symbol,0,sl_position,tp_position,"SELL"+exp_name))
               Print("Erro enviar ordem ",GetLastError());
           }

        }//End NewBar

     }//End Trade On

  }//Fim Ontick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(cap_handle,9,0,5,CAP_Buy)<=0 || 
         CopyBuffer(cap_handle,8,0,5,CAP_Sell)<=0 || 
         CopyBuffer(bw_handle,1,0,5,BW_Buy)<=0 || 
         CopyBuffer(bw_handle,0,0,5,BW_Sell)<=0 || 
         CopyHigh(Symbol(),period,0,3,high)<=0 ||
         CopyOpen(Symbol(),period,0,3,open)<=0 ||
         CopyLow(Symbol(),period,0,3,low)<=0 || 
         CopyClose(Symbol(),period,0,3,close)<=0;
   return(b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::TimeDayFilter()
  {
   bool filter=false;
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

     }
   return filter;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::BuySignal()
  {
   bool signal;
   signal=close[1]<mfast.Main(1) && close[1]<open[1];
   if(Buy_opened())signal=signal && close[1]<=LastEntryPrice(POSITION_TYPE_BUY)-pts_grid*ponto;
   else signal=signal && close[1]<=mfast.Main(1)-pts_grid*ponto;
   signal=signal && ((CAP_Buy[2]==EMPTY_VALUE && CAP_Buy[1]!=EMPTY_VALUE) || (BW_Buy[2]==0.0 && BW_Buy[1]>0.0));
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal;
   signal=close[1]>mfast.Main(1) && close[1]>open[1];
   if(Sell_opened())signal=signal && close[1]>=LastEntryPrice(POSITION_TYPE_SELL)+pts_grid*ponto;
   else signal=signal && close[1]>=mfast.Main(1)+pts_grid*ponto;
   signal=signal && ((BW_Sell[2]==0.0 && BW_Sell[1]>0.0) || (CAP_Sell[2]==EMPTY_VALUE && CAP_Sell[1]!=EMPTY_VALUE));

   return signal;
  }
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

   if(trans.symbol!=original_symbol)return;
   double buyprice,sellprice;
   int TENTATIVAS=10;

//--- get transaction type as enumeration value
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- if transaction is result of addition of the transaction in history

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(type==TRADE_TRANSACTION_ORDER_UPDATE)
     {
      myorder.Select(trans.order);

     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

         if(deal_symbol!=original_symbol) return;
         if(deal_magic==Magic_Number)
           {
            gv.Set("last_deal_time",(double)deal_time);

/*            if(deal_comment=="BUY"+exp_name)
              {
               DeleteOrders(ORDER_TYPE_SELL_STOP);
               Real_Parc_Buy(deal_volume,deal_price);
              }

            if(deal_comment=="SELL"+exp_name)
              {
               DeleteOrders(ORDER_TYPE_BUY_STOP);
               Real_Parc_Sell(deal_volume,deal_price);
              }
              */
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
           } //Fim deal magic

        }
      else
         return;
     }
   if(type==TRADE_TRANSACTION_HISTORY_ADD)
     {
      myhistory.Ticket(trans.order);
      if(myhistory.Magic()!=(long)Magic_Number)return;

      if((myhistory.Comment()=="BUY"+exp_name || myhistory.Comment()=="SELL"+exp_name) && trans.order_state==ORDER_STATE_FILLED)
        {
         gv.Set("glob_entr_tot",gv.Get("glob_entr_tot")+1);
        }

      if(myhistory.Comment()=="BUY"+exp_name && trans.order_state==ORDER_STATE_FILLED)

        {

         myposition.SelectByTicket(trans.order);
         int cont = 0;
         buyprice = 0;
         while(buyprice==0 && cont<TENTATIVAS)
           {
            buyprice=myposition.PriceOpen();
            cont+=1;
           }
         if(buyprice==0)
            buyprice=mysymbol.Ask();

        }
      //--------------------------------------------------

      if(myhistory.Comment()=="SELL"+exp_name && trans.order_state==ORDER_STATE_FILLED)

        {
         myposition.SelectByTicket(trans.order);
         int cont=0;
         sellprice=0;
         while(sellprice==0 && cont<TENTATIVAS)
           {
            sellprice=myposition.PriceOpen();
            cont+=1;
           }
         if(sellprice==0)
            sellprice=mysymbol.Bid();

        }

      lucro_orders=LucroOrdens();
      lucro_orders_mes = LucroOrdensMes();
      lucro_orders_sem = LucroOrdensSemana();


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::Loss()
  {
   int cnt=0;

   if(HistorySelect(0,TimeCurrent()))
     {
      for(int x=HistoryDealsTotal()-1; x>=0; x--)
        {
         ulong ticket=HistoryDealGetTicket(x);
         string _symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         ulong type=HistoryDealGetInteger(ticket,DEAL_TYPE);
         ulong magic = HistoryDealGetInteger(ticket,DEAL_MAGIC);
         ulong entry = HistoryDealGetInteger(ticket,DEAL_ENTRY);
         double profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
         string comment=HistoryDealGetString(ticket,DEAL_COMMENT);
         if(_symbol!=_Symbol) continue;
         if(magic== Magic_Number && entry== DEAL_ENTRY_OUT && profit>0) break;
         if(magic==Magic_Number && entry==DEAL_ENTRY_OUT)
            if(type==DEAL_TYPE_BUY || type==DEAL_TYPE_SELL) cnt++;
        }
     }
   return(cnt);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::LastEntryPrice(ENUM_POSITION_TYPE ptype)
  {
   double price=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
        {
         if(myposition.PositionType()==ptype)
           {
            price=myposition.PriceOpen();
            break;
           }
        }
     }
   return price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::CountPositions(ENUM_POSITION_TYPE ptype)
  {
   int cnt=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
        {
         if(myposition.PositionType()!=ptype) continue;
         if(myposition.PositionType()==ptype)cnt+=1;
        }
     }
   return cnt;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MyRobot::CalcLot(ENUM_POSITION_TYPE ptype)
  {
   double lots=Lot;
   int cnt_pos=CountPositions(ptype);
   double lot_step=mysymbol.LotsStep();
   if(cnt_pos>0){ lots=NormalizeDouble(lots*MathPow(Multiplier,cnt_pos),2);}
   return( NormalizeDouble(MathRound(lots/lot_step)*lot_step,2) );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/*
double MyRobot::CalcLot(ENUM_POSITION_TYPE ptype)
  {
   double lots=Lot;
   int cnt_pos=CountPositions(ptype);
   double lot_step=mysymbol.LotsStep();
   if(cnt_pos>0 && cnt_pos%5==0){ lots=NormalizeDouble(VolPosType(ptype)*Multiplier,2);}
   return( NormalizeDouble(MathRound(lots/lot_step)*lot_step,2) );
  }
*/
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      //      if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
      //       return(INIT_FAILED);

      if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,ChartHeightInPixelsGet()-ALTURA_PAINEL,LARGURA_PAINEL,ChartHeightInPixelsGet()))
         return(INIT_FAILED);

      //--- run application 

      ExtDialog.Run();
     }

   if(!ChartSetInteger(ChartID(),CHART_SHIFT,0,50))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }

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

   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.Destroy(reason);

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
   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      ExtDialog.OnTick();
      if(TimeCurrent()%10==0)
        {
         ChartRedraw();
         ExtDialog.Move(0,ChartHeightInPixelsGet()-ALTURA_PAINEL);
        }
     }
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyPanel::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {

   int xx1=INDENT_LEFT;
   int yy1=INDENT_TOP;
   int xx2=x1+BUTTON_WIDTH;
   int yy2=INDENT_TOP+BUTTON_HEIGHT;

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);

//--- create dependent controls 

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Resultado Mensal: "+DoubleToString(MyEA.LucroTotalMes(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[0].Color(clrYellowGreen);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"Resultado Semanal: "+DoubleToString(MyEA.LucroTotalSemana(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[1].Color(clrYellowGreen);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"Resultado Diário: "+DoubleToString(MyEA.LucroTotal(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[2].Color(clrYellowGreen);

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyPanel::OnTick(void)
  {
   m_label[0].Text("Resultado Mensal: "+DoubleToString(MyEA.LucroTotalMes(),2));
   m_label[1].Text("Resultado Semanal: "+DoubleToString(MyEA.LucroTotalSemana(),2));
   m_label[2].Text("Resultado Diário: "+DoubleToString(MyEA.LucroTotal(),2));
  }
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
