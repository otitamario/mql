//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#resource "\\Indicators\\MinMax.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum CalcDist
  {
   CalcPont,        //Pontos
   CalcTick         //Ticks
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_BOOLEANO
  {
   BOOL_NO,//Não
   BOOL_YES//Sim
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <ChartObjects\ChartObjectsLines.mqh>
#include <ChartObjects\ChartObjectsTxtControls.mqh>
#include <ChartObjects\ChartObjectsBmpControls.mqh>

#include <Controls\Defines.mqh>
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
//#undef CONTROLS_LABEL_COLOR  

color borda_bg=clrNONE;//Cor Borda
color painel_bg=clrBlack;//Cor Painel 
color cor_txt_borda_bg=clrYellowGreen;//Cor Texto Borda
                                      //color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG          borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg

#include <Expert_Class_New.mqh>
MyPanel ExtDialog;

CLabel            m_label[50];

#define LARGURA_PAINEL 260 // Largura Painel
#define ALTURA_PAINEL 350 // Altura Painel
#define X_LABEL 11
#define Y_LABEL 15

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input string Simbolo="";//Digite Símbolo para Ordens
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO 
ulong MAGIC_NUMBER;
ulong deviation_points=500;//Deviation em Pontos(Padrao)
sinput string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input double Lot=1;//Tamanho do Lote
input CalcDist calcdist=CalcPont;//Modo Cálculo Distância
input double _Stop=200;//Stop Loss 
input double _TakeProfit=300;//Take Profit 
input double spread_max=0;//SPREAD MÁXIMO (Pontos/Ticks)
sinput string Lucro="###---------------------Lucro/Prejuizo para Fechamento (Pontos/Ticks)-----------------------#####";//Lucro
input double lucro=0;//Lucro Fechar Posicoes no Dia
input double prejuizo=0;//Prejuizo Fechar Posicoes no Dia

sinput string STrailing="############---------------Trailing Stop----------########";//Stop Móvel
input ENUM_BOOLEANO  Use_TraillingStop=BOOL_NO; //Usar Stop Móvel
input double TraillingStart=50;//Trailing Start
input double TraillingDistance=100;// Trailing Distance
input double TraillingStep=10;// Trailing Step
sinput string sbreak="########---------BreakOut---------------###############";//BreakOut

input ENUM_BOOLEANO  UseBreakEven=BOOL_NO;//Usar BreakOut
input double  BreakEvenPoint=100; //BreakOut Start
input double  ProfitPoint=10; //BreakOut

sinput string Sind="############--------------Indicador--------------########";//Indicador
input int                inpPeriod = 25;          // MinMax period
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price



sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário
input string start_hour="9:04";//Horario Inicial
input string end_hour_ent="17:00";//Horario Final Entradas
input string end_hour="17:20";//Horario Encerramento
sinput string sdias="FILTRO DOS DIAS DA SEMANA";//Dias da Semana
input bool trade0=true;// Operar Domingo
input bool trade1=true;// Operar Segunda
input bool trade2=true;// Operar Terça
input bool trade3=true;// Operar Quarta
input bool trade4=true;// Operar Quinta
input bool trade5=true;// Operar Sexta
input bool trade6=true;// Operar Sábado
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class MyRobot: public MyExpert
  {
private:
   // CChartObjectEdit LabelPanel;
   CChartObjectHLine HLine_Stop,HLine_Take;
   //   CChartObjectRectLabel Retangulo;
   bool              opt_tester;
   CChartObjectVLine VLine_Init;
   CChartObjectHLine HLine_Price,HLine_SL,HLine_TP;
   string            currency_symbol;
   double            sl,tp,price_open_day;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   double            sl_position,tp_position;
   double            Buyprice,Sellprice;
   int               minmax_handle;
   double            MinMaxBuf[];
   bool              novabarra;
   bool              buysignal,sellsignal;
   datetime          hora_fin_entrad;
   bool              timeEnt;
   double            preco_medio;
   double            vol_pos,vol_stp,preco_stp;
   bool              pos_open;
   double            lucro_pontos,lucro_ticks;
   double            spread;
   string            COMMY;
   string            acc_type;
   string            program;
public:
   void              MyRobot();
   void             ~MyRobot();
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
   virtual void      Atual_vol_Stop_Take();
   bool GetPosOpen(){return pos_open;};
   void              PanelUpdate();
   double            LucroPontos();
   double            LucroTicks();
   bool              BreakOut(const double pBreakOutStart,const double pBreakOut,const CalcDist _pcalcdist);
   void              TrailingStopMoabi(double pTrailPoints,double pMinProfit=0,double pStep=10,const CalcDist _pcalcdist=CalcPont);
   ulong             MyRobot::iMakeExpertId();
   ulong             MyRobot::iMakeHash(string s1,string s2="",string s3="",string s4="",string s5=""
                                        ,string s6="",string s7="",string s8="",string s9="",string s10="");
   double            CalcPontos(const double profit,const double vol);
   double            CalcTicks(const double profit,const double vol);

   double            LucroOrdensPts();
   double            LucroOrdensTicks();
   double            LucroOrdensPts_V2();
   double            LucroOrdensTicks_V2();
   bool              ArrowSellCreate(const long            chart_ID=0,// ID do gráfico
                                     const string          name="ArrowSell",  // nome do sinal
                                     const int             sub_window=0,      // índice da sub-janela
                                     datetime              time=0,            // ponto de ancoragem do tempo
                                     double                price=0,           // ponto de ancoragem do preço
                                     const color           clr=clrRed,// cor do sinal
                                     const ENUM_LINE_STYLE style=STYLE_SOLID, // estilo de linha (quando destacado)
                                     const int             width=1,           // tamanho da linha (quando destacada)
                                     const bool            back=false,        // no fundo
                                     const bool            selection=false,   // destaque para mover
                                     const bool            hidden=true,       // ocultar na lista de objetos
                                     const long            z_order=0);         // prioridade para clique do mouse

   bool              ArrowBuyCreate(const long            chart_ID=0,// ID do gráfico
                                    const string          name="ArrowBuy",// nome do sinal
                                    const int             sub_window=0,      // índice da sub-janela
                                    datetime              time=0,            // ponto de ancoragem do tempo
                                    double                price=0,           // ponto de ancoragem do preço
                                    const color           clr=clrBlue,// cor do sinal
                                    const ENUM_LINE_STYLE style=STYLE_SOLID, // estilo de linha (quando destacado)
                                    const int             width=1,           // tamanho da linha (quando destacada)
                                    const bool            back=false,        // no fundo
                                    const bool            selection=false,   // destaque para mover
                                    const bool            hidden=true,       // ocultar na lista de objetos
                                    const long            z_order=0);         // prioridade para clique do mouse

   void              ChangeArrowEmptyPoint(datetime &time,double &price);
   void              RemovePanel();

  };

MyRobot MyEA;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::MyRobot()
  {
//  preco_par1=0.0;preco_par2=0.0;preco_par3=0.0;
// Exec_parc1=false;Exec_parc2=false;Exec_parc3=false;

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::~MyRobot()
  {
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::OnInit(void)
  {

   Conexao=IsConnect();
   EventSetMillisecondTimer(200);
   tradeOn=true;
   setExpName();
   setSymbol(Symbol());
   if(Simbolo!="")setOriginalSymbol(Simbolo);
   else
     {
      setOriginalSymbol(Symbol());
      string erro="Símbolo De Ordens não específicado! Usando o Símbolo Atual";
      Alert(erro);
      Print(erro);
     }
   setMagic(MAGIC_NUMBER);
   setPeriod(periodoRobo);
   if(SymbolInfoInteger(original_symbol,SYMBOL_EXPIRATION_MODE)==2)order_time_type=1;
   else order_time_type=0;
   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(MAGIC_NUMBER);
   mytrade.SetDeviationInPoints(50);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
//   mytrade.SetTypeFillingBySymbol(original_symbol);
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

   acc_type=(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)?"HEDGE":"NETTING";
   program=MQLInfoString(MQL_PROGRAM_NAME);
   opt_tester=MQLInfoInteger(MQL_OPTIMIZATION);

   hora_inicial=0;
   hora_fin_entrad=0;
   hora_final=0;
   if(start_hour!="" && start_hour!="x" && start_hour!="X")hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   if(end_hour!="" && end_hour!="x" && end_hour!="X") hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   if(end_hour_ent!="" && end_hour_ent!="x" && end_hour_ent!="X") hora_fin_entrad=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_ent);

   if(hora_inicial>0 && hora_fin_entrad>0 && hora_final>0)
     {
      if(hora_inicial>=hora_final)
        {
         string erro="Hora Inicial deve ser Menor que Hora de Encerramento";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);
        }

      if(hora_inicial>=hora_fin_entrad)
        {
         string erro="Hora Inicial deve ser Menor que Hora Final de Entradas";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);
        }

      if(hora_fin_entrad>hora_final)
        {
         string erro="Hora Final de Entradas deve ser Menor ou igual que Hora de Encerramento";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);
        }
     }
   long curChartID=ChartID();

   minmax_handle=iCustom(_Symbol,periodoRobo,"::Indicators\\MinMax.ex5",inpPeriod,inpPrice);

   ChartIndicatorAdd(0,0,minmax_handle);

   ArraySetAsSeries(MinMaxBuf,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(ChartID(),CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

   PanelUpdate();
   return(INIT_SUCCEEDED);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTimer()
  {
   CheckConnection();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   IndicatorRelease(minmax_handle);
   DeletaIndicadores();
   VLine_Init.Delete();
   EventKillTimer();
   int k=ObjectsDeleteAll(0,"",0,OBJ_HLINE);
   HLine_Price.Delete();
   HLine_SL.Delete();
   HLine_TP.Delete();
   RemovePanel();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTick(void)
  {
   static bool first_tick=false;
   static bool breakout_ativado=false;
   static double sloss_atual=0;
   static double sloss_prev=0;

   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today",(double)TimeNow.day_of_year);
   gv.Set("gv_mes",(double)TimeNow.mon);


   bool novodia;
   novodia=Bar_NovoDia.CheckNewBar(original_symbol,PERIOD_D1);

   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      gv.Set("glob_entr_tot",0.0);
      tradeOn=true;
      first_tick=false;
      hora_inicial=0;
      hora_fin_entrad=0;
      hora_final=0;
      if(start_hour!="" && start_hour!="x" && start_hour!="X")hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
      if(end_hour!="" && end_hour!="x" && end_hour!="X") hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
      if(end_hour_ent!="" && end_hour_ent!="x" && end_hour_ent!="X") hora_fin_entrad=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_ent);

     }

   gv.Set("gv_today_prev",gv.Get("gv_today"));

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
   spread=ask-bid;
   switch(calcdist)
     {
      case CalcPont:
         spread=spread/ponto;
         break;
      case CalcTick:
         spread=spread/ticksize;
         break;
     }
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }

   if(bid>=ask)return;//Leilão

   if(!TerminalInfoInteger(TERMINAL_CONNECTED))return;



   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   pos_open=PosicaoAberta();
   if(!pos_open)breakout_ativado=false;
   if(UseBreakEven==BOOL_NO)breakout_ativado=true;

   switch(calcdist)
     {
      case CalcPont:
         lucro_pontos=LucroPontos();
         lucro_orders=LucroOrdensPts_V2();
         lucro_total=lucro_pontos+lucro_orders;
         break;
      case CalcTick:
         lucro_ticks=LucroTicks();
         lucro_orders=LucroOrdensTicks_V2();
         lucro_total=lucro_ticks+lucro_orders;
         break;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(pos_open)
     {
      if((lucro>0 && lucro_total>=lucro) || (prejuizo>0 && lucro_total<=-prejuizo))
        {
         CloseALL();
         if(OrdersTotal()>0)DeleteALL();
         Print("EA finalizado por Lucro ou Prejuízo");
         tradeOn=false;
        }
     }
   timerOn=true;
   timeEnt=true;
   if(hora_final>0)timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final;
   if(hora_fin_entrad>0)timeEnt=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_fin_entrad;
   timerOn=timerOn && TimeDayFilter();
   timeEnt=timeEnt && TimeDayFilter();

   if((!timerOn || !tradeOn))
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
      return;
     }

   if(tradeOn && timerOn)
     {// inicio Trade On

      if(pos_open)
        {
         if(Buy_opened() && Sell_opened())CloseByPosition();

         if(Use_TraillingStop==BOOL_YES && breakout_ativado)
            TrailingStopMoabi(TraillingDistance,TraillingStart,TraillingStep,calcdist);

         if(UseBreakEven==BOOL_YES)
           {
            if(BreakOut(BreakEvenPoint,ProfitPoint,calcdist))
               breakout_ativado=true;
           }

         if(!opt_tester)
           {
            if(Buy_opened())myposition.SelectByTicket(TickecBuyPos());
            if(Sell_opened())myposition.SelectByTicket(TickecSellPos());
            sloss_atual=myposition.StopLoss();
            if(sloss_atual!=sloss_prev)
              {
               HLine_SL.Delete();
               HLine_SL.Create(0, "SL", 0, myposition.StopLoss());
               HLine_SL.Color(clrRed);
              }
           }
        }//Fim Posição Aberta

      else
        {
         HLine_Price.Delete();
         HLine_SL.Delete();
         HLine_TP.Delete();
         sloss_atual=0;
        }
      sloss_prev=sloss_atual;

      novabarra=Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo);

      buysignal=BuySignal() && !Buy_opened();
      sellsignal=SellSignal() && !Sell_opened();

      buysignal=buysignal && novabarra;
      sellsignal=sellsignal && novabarra;

      if(spread_max>0)
        {
         if(spread>spread_max)
           {
            Print("Spread Atual: "+DoubleToString(spread,2)+" maior que o spread máximo: "+DoubleToString(spread_max,2));
            return;
           }
        }
      if(timeEnt)
        {

         if((!first_tick) && novabarra)
           {
            first_tick=true;
            buysignal=MinMaxBuf[1]==1 && !Buy_opened();
            sellsignal=MinMaxBuf[1]==2 && !Sell_opened();
            VLine_Init.Delete();
            VLine_Init.Create(ChartID(),"Primeiro Tick",0,TimeCurrent());
            VLine_Init.Description(TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
           }
         if(buysignal)
           {
            DeleteALL();
            CloseALL();
            sl_position=0;
            tp_position=0;
            switch(calcdist)
              {
               case CalcPont:
                  if(_Stop>0)sl_position=NormalizeDouble(bid-_Stop*ponto,digits);
                  if(_TakeProfit>0)tp_position=NormalizeDouble(ask+_TakeProfit*ponto,digits);
                  break;
               case CalcTick:
                  if(_Stop>0)sl_position=NormalizeDouble(bid-_Stop*ticksize,digits);
                  if(_TakeProfit>0)tp_position=NormalizeDouble(ask+_TakeProfit*ticksize,digits);
                  break;
              }

            if(mytrade.Buy(Lot,original_symbol,0,sl_position,tp_position,"BUY"+exp_name))
              {
               gv.Set("cp_tick",(double)mytrade.ResultOrder());
               HLine_Price.Delete();
               HLine_SL.Delete();
               HLine_TP.Delete();
               myposition.SelectByTicket((ulong)gv.Get("cp_tick"));
               HLine_Price.Create(0,"Entrada",0,myposition.PriceOpen());
               HLine_SL.Create(0, "SL", 0, myposition.StopLoss());
               HLine_TP.Create(0, "TP", 0, myposition.TakeProfit());
               HLine_Price.Color(clrAqua);
               HLine_SL.Color(clrRed);
               HLine_TP.Color(clrLime);
              }
            else
               Print("Erro enviar ordem ",GetLastError());

           }

         if(sellsignal)
           {
            DeleteALL();
            CloseALL();
            sl_position=0;
            tp_position=0;

            switch(calcdist)
              {
               case CalcPont:
                  if(_Stop>0)sl_position=NormalizeDouble(ask+_Stop*ponto,digits);
                  if(_TakeProfit>0)tp_position=NormalizeDouble(bid-_TakeProfit*ponto,digits);
                  break;
               case CalcTick:
                  if(_Stop>0)sl_position=NormalizeDouble(ask+_Stop*ticksize,digits);
                  if(_TakeProfit>0)tp_position=NormalizeDouble(bid-_TakeProfit*ticksize,digits);
                  break;
              }

            if(mytrade.Sell(Lot,original_symbol,0,sl_position,tp_position,"SELL"+exp_name))
              {
               gv.Set("vd_tick",(double)mytrade.ResultOrder());
               HLine_Price.Delete();
               HLine_SL.Delete();
               HLine_TP.Delete();
               myposition.SelectByTicket((ulong)gv.Get("vd_tick"));
               HLine_Price.Create(0,"Entrada",0,myposition.PriceOpen());
               HLine_SL.Create(0, "SL", 0, myposition.StopLoss());
               HLine_TP.Create(0, "TP", 0, myposition.TakeProfit());
               HLine_Price.Color(clrAqua);
               HLine_SL.Color(clrRed);
               HLine_TP.Color(clrLime);
              }
            else
               Print("Erro enviar ordem ",GetLastError());

           }
        }

     }//End Trade On

  }//Fim Ontick
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool MyRobot::GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(minmax_handle,5,0,5,MinMaxBuf)<=0 || 
         CopyHigh(Symbol(),period,0,5,high)<=0 ||
         CopyOpen(Symbol(),period,0,5,open)<=0 ||
         CopyLow(Symbol(),period,0,5,low)<=0 || 
         CopyClose(Symbol(),period,0,5,close)<=0;

   return(b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::TimeDayFilter()
  {
   bool filter=false;
   MqlDateTime TimeToday;
   TimeToStruct(TimeCurrent(),TimeToday);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::BuySignal()
  {
   bool signal=false;
   signal=MinMaxBuf[1]==1 && MinMaxBuf[2]!=1;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal=false;
   signal=MinMaxBuf[1]==2 && MinMaxBuf[2]!=2;
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

            if(deal_comment=="BUY"+exp_name || deal_comment=="SELL"+exp_name)
              {
               gv.Set("glob_entr_tot",gv.Get("glob_entr_tot")+1);

               if(!opt_tester)
                 {
                  int k=ObjectsDeleteAll(0,0,OBJ_HLINE);
                  HLine_Price.Delete();
                  HLine_SL.Delete();
                  HLine_TP.Delete();
                  myposition.SelectByTicket(trans.order);
                  HLine_Price.Create(0, "Entrada", 0, trans.price);
                  HLine_Price.Color(clrAqua);
                  HLine_SL.Create(0, "Stop Loss", 0, myposition.StopLoss());
                  HLine_SL.Color(clrRed);
                  HLine_TP.Create(0, "Take Profit", 0, myposition.TakeProfit());
                  HLine_TP.Color(clrLime);
                 }

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
               if(deal_type==DEAL_TYPE_SELL)
                  ArrowSellCreate(0,"ArrowSell_"+TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),0,TimeCurrent(),deal_price);
               if(deal_type==DEAL_TYPE_BUY)
                  ArrowBuyCreate(0,"ArrowBuy_"+TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),0,TimeCurrent(),deal_price);

              }
           } //Fim deal magic

        }
      else
         return;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(type==TRADE_TRANSACTION_HISTORY_ADD)
     {
      if(HistoryOrderSelect(trans.order))
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

            buyprice=mysymbol.NormalizePrice(MathRound(buyprice/ticksize)*ticksize);

            sl_position=0;
            tp_position=0;
            switch(calcdist)
              {
               case CalcPont:
                  if(_Stop>0)sl_position=NormalizeDouble(buyprice-_Stop*ponto,digits);
                  if(_TakeProfit>0)tp_position=NormalizeDouble(buyprice+_TakeProfit*ponto,digits);
                  break;
               case CalcTick:
                  if(_Stop>0)sl_position=NormalizeDouble(buyprice-_Stop*ticksize,digits);
                  if(_TakeProfit>0)tp_position=NormalizeDouble(buyprice+_TakeProfit*ticksize,digits);
                  break;
              }
            if(mytrade.PositionModify(trans.order,sl_position,tp_position))
               Print("Stops Ajustados");

            ArrowBuyCreate(0,"ArrowBuy_"+TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),0,TimeCurrent(),buyprice);

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
            sellprice=mysymbol.NormalizePrice(MathRound(sellprice/ticksize)*ticksize);
            sl_position=0;
            tp_position=0;

            switch(calcdist)
              {
               case CalcPont:
                  if(_Stop>0)sl_position=NormalizeDouble(sellprice+_Stop*ponto,digits);
                  if(_TakeProfit>0)tp_position=NormalizeDouble(sellprice-_TakeProfit*ponto,digits);
                  break;
               case CalcTick:
                  if(_Stop>0)sl_position=NormalizeDouble(sellprice+_Stop*ticksize,digits);
                  if(_TakeProfit>0)tp_position=NormalizeDouble(sellprice-_TakeProfit*ticksize,digits);
                  break;
              }

            if(mytrade.PositionModify(trans.order,sl_position,tp_position))
               Print("Stops Ajustados");

            ArrowSellCreate(0,"ArrowSell_"+TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS),0,TimeCurrent(),sellprice);

           }

        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::Atual_vol_Stop_Take()
  {
   double vol_ent_contra,vol_ent_fav,vol_parc;
   vol_ent_contra=VolumeOrdensCmt("Saída Aumento");
   vol_ent_fav=VolumeOrdensCmt("Saída Favor");
   vol_parc=VolumeOrdensCmt("PARCIAL 1")+VolumeOrdensCmt("PARCIAL 2")+VolumeOrdensCmt("PARCIAL 3");

   if(Buy_opened())
     {
      if(myposition.SelectByTicket((ulong)gv.Get("cp_tick")) && myorder.Select((ulong)gv.Get("tp_vd_tick")))
        {
         vol_pos = VolPosType(POSITION_TYPE_BUY)-vol_ent_contra-vol_ent_fav-vol_parc;
         vol_stp = myorder.VolumeInitial();
         // preco_stp=myorder.PriceOpen();
         preco_stp=NormalizeDouble(PrecoMedio(POSITION_TYPE_BUY)+_TakeProfit*ponto,digits);

         if(vol_pos!=vol_stp)
           {
            mytrade.OrderDelete((ulong)gv.Get("tp_vd_tick"));
            mytrade.SellLimit(vol_pos, preco_stp, original_symbol, 0, 0, order_time_type, 0, "TAKE PROFIT");
            gv.Set("tp_vd_tick",(double)mytrade.ResultOrder());
           }
        }
     }
   if(Sell_opened())
     {

      if(myposition.SelectByTicket((ulong)gv.Get("vd_tick")) && myorder.Select((ulong)gv.Get("tp_cp_tick")))
        {
         vol_pos = VolPosType(POSITION_TYPE_SELL)-vol_ent_contra-vol_ent_fav-vol_parc;
         vol_stp = myorder.VolumeInitial();
         //  preco_stp=myorder.PriceOpen();
         preco_stp=NormalizeDouble(PrecoMedio(POSITION_TYPE_SELL)-_TakeProfit*ponto,digits);

         if(vol_pos!=vol_stp)
           {
            mytrade.OrderDelete((ulong)gv.Get("tp_cp_tick"));
            mytrade.BuyLimit(vol_pos, preco_stp, original_symbol, 0, 0, order_time_type, 0, "TAKE PROFIT");
            gv.Set("tp_cp_tick",(double)mytrade.ResultOrder());
           }
        }
     }

  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   MAGIC_NUMBER=MyEA.iMakeExpertId();

//--- Obtemos o número da compilação do programa 
   Print(MQL5InfoString(MQL5_PROGRAM_NAME),"--- MT5 Build #",__MQLBUILD__);
   Print("Número Mágico Gerado: "+IntegerToString(MAGIC_NUMBER));
   return MyEA.OnInit();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
void OnTimer()
  {
   MyEA.OnTimer();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   MyEA.OnTick();
   MyEA.PanelUpdate();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void OnChartEvent(const int id,// event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
//|                                                                  |
//+------------------------------------------------------------------+

void MyRobot::PanelUpdate()
  {
   static string s_spread=calcdist==CalcPont?" Points":" Ticks";
   string exp_ativo=(tradeOn && timerOn)?" STARTED":" FINISHED";
   string s_pend_prof=calcdist==CalcPont?DoubleToString(lucro_pontos,2):DoubleToString(lucro_ticks,2);

   COMMY="\n\n"+
         "\n ------------------------------------------------------ "+
         "\n"+" "+program+":   "+exp_ativo+
         "\n"+" "+original_symbol+"  Magic N. "+IntegerToString(MAGIC_NUMBER)+
         "\n ------------------------------------------------------ "+
         "\n LEVERAGE:   "+"1:"+IntegerToString(myaccount.Leverage())+
         "\n ACCOUNT CURRENCY:   "+myaccount.Currency()+
         "\n ACCOUNT TYPE:   "+acc_type+
         "\n ------------------------------------------------------ "+
         "\n BROKER TIME:   "+TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)+
         "\n LOCAL TIME:   "+TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS)+
         "\n TIME DIFFERENCE:   "+TimeToString(MathAbs(TimeLocal()-TimeCurrent()),TIME_SECONDS)+
         "\n ------------------------------------------------------ "+
         "\n ASK:   "+DoubleToString(SymbolInfoDouble(original_symbol,SYMBOL_ASK),_Digits)+
         "\n BID:   "+DoubleToString(SymbolInfoDouble(original_symbol,SYMBOL_BID),_Digits)+
         "\n SPREAD:   "+DoubleToString(spread,_Digits)+s_spread+
         "\n ------------------------------------------------------ "+
         "\n SWAP LONG:   "+DoubleToString(SymbolInfoDouble(original_symbol,SYMBOL_SWAP_LONG),_Digits)+
         "\n SWAP SHORT:   "+DoubleToString(SymbolInfoDouble(original_symbol,SYMBOL_SWAP_SHORT),_Digits)+
         "\n ------------------------------------------------------ "+
         "\n NR. OF ACTIVE ORDERS:   "+IntegerToString(PositionsTotal())+
         "\n ACCOUNT BALANCE:   "+DoubleToString(myaccount.Balance(),2)+
         "\n ACCOUNT EQUITY:   "+DoubleToString(myaccount.Equity(),2)+
         "\n FREE MARGIN:   "+DoubleToString(myaccount.FreeMargin(),2)+
         "\n USED MARGIN:   "+DoubleToString(myaccount.Balance()-myaccount.FreeMargin(),2)+
         "\n PENDING PROFIT/LOSS:   "+s_pend_prof+s_spread+
         "\n DAYLY PROFIT/LOSS:   "+DoubleToString(lucro_total,2)+s_spread+

         "\n ------------------------------------------------------ ";

   Comment(COMMY);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::RemovePanel()
  {

   string   _COMMY=""+"\n"+""+"\n"+""+"\n"+""+"\n"+
                   ""+"\n"+""+"\n"+""+"\n"+""+"\n"+
                   ""+"\n"+""+"\n"+""+"\n"+""+"\n"+
                   ""+"\n"+""+"\n"+""+"\n"+""+"\n"+
                   ""+"\n"+""+"\n"+""+"\n"+""+"\n"+
                   ""+"\n"+""+"\n"+""+"\n"+""+"\n";
   Comment(_COMMY);

  }
//+------------------------------------------------------------------+
double MyRobot::LucroPontos()
  {
   if(!mysymbol.Refresh())
      return (0);
   double profit=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
        {
         if(myposition.PositionType()==POSITION_TYPE_BUY)
            profit+=SymbolInfoDouble(Simbolo,SYMBOL_BID)-myposition.PriceOpen();
         if(myposition.PositionType()==POSITION_TYPE_SELL)
            profit+=myposition.PriceOpen()-SymbolInfoDouble(Simbolo,SYMBOL_ASK);
        }
     }
   return ((profit)/ponto);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::LucroTicks()
  {
   if(!mysymbol.Refresh())
      return (0);
   double profit=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
        {
         if(myposition.PositionType()==POSITION_TYPE_BUY)
            profit+=SymbolInfoDouble(Simbolo,SYMBOL_BID)-myposition.PriceOpen();
         if(myposition.PositionType()==POSITION_TYPE_SELL)
            profit+=myposition.PriceOpen()-SymbolInfoDouble(Simbolo,SYMBOL_ASK);
        }
     }
   return ((profit)/ticksize);
  }
//+------------------------------------------------------------------+

bool MyRobot::BreakOut(const double pBreakOutStart,const double pBreakOut,const CalcDist _pcalcdist)
  {
   bool signal=false;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number)
        {

         long posType=myposition.PositionType();
         ulong posTicket=myposition.Ticket();
         double currentSL = myposition.StopLoss();
         double openPrice = NormalizeDouble(MathRound(myposition.PriceOpen() / ticksize) * ticksize, digits);
         double currentTP = myposition.TakeProfit();
         double breakEvenStop=0;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            currentProfit=bid-openPrice;
            switch(_pcalcdist)
              {
               case CalcPont:
                  currentProfit=currentProfit/ponto;
                  break;
               case CalcTick:
                  currentProfit=currentProfit/ticksize;
                  break;
              }
            if(currentProfit>=pBreakOutStart)
              {
               switch(_pcalcdist)
                 {
                  case CalcPont:
                     breakEvenStop = openPrice + pBreakOut * ponto;
                     breakEvenStop =mysymbol.NormalizePrice( MathRound(breakEvenStop / ticksize) * ticksize);
                     break;
                  case CalcTick:
                     breakEvenStop = openPrice + pBreakOut * ticksize;
                     breakEvenStop =mysymbol.NormalizePrice( MathRound(breakEvenStop / ticksize) * ticksize);
                     break;
                 }

               if(currentSL<breakEvenStop || currentSL==0)
                 {
                  if(mytrade.PositionModify(posTicket,breakEvenStop,currentTP))
                    {
                     signal=true;
                     Print("BreakOut Ativado");
                    }
                 }
              }

           }
         if(posType==POSITION_TYPE_SELL)
           {
            currentProfit=openPrice-ask;
            switch(_pcalcdist)
              {
               case CalcPont:
                  currentProfit=currentProfit/ponto;
                  break;
               case CalcTick:
                  currentProfit=currentProfit/ticksize;
                  break;
              }

            if(currentProfit>=pBreakOutStart)
              {

               switch(_pcalcdist)
                 {
                  case CalcPont:
                     breakEvenStop = openPrice - pBreakOut * ponto;
                     breakEvenStop =mysymbol.NormalizePrice( MathRound(breakEvenStop / ticksize) * ticksize);
                     break;
                  case CalcTick:
                     breakEvenStop = openPrice - pBreakOut * ticksize;
                     breakEvenStop =mysymbol.NormalizePrice( MathRound(breakEvenStop / ticksize) * ticksize);
                     break;
                 }

               if(currentSL>breakEvenStop || currentSL==0)
                 {
                  if(mytrade.PositionModify(posTicket,breakEvenStop,currentTP))
                    {
                     signal=true;
                     Print("BreakOut Ativado");
                    }
                 }
              }

           }

        } //Fim Position Select

     } //Fim for
   return signal;
  }
//+------------------------------------------------------------------+
ulong MyRobot::iMakeExpertId()
  {
/*   MathSrand(GetTickCount());
   string ss[7];
   for(int i=0;i<7;i++)ss[i]=IntegerToString(MathRand());
return( iMakeHash(_Symbol,EnumToString(_Period),MQLInfoString(MQL_PROGRAM_NAME),
          ss[0],ss[1],ss[2],ss[3],ss[4],ss[5],ss[6]));
*/
   return( iMakeHash(_Symbol,EnumToString(_Period),MQLInfoString(MQL_PROGRAM_NAME)));


  }
//+------------------------------------------------------------------+
//
ulong MyRobot::iMakeHash(string s1,string s2="",string s3="",string s4="",string s5=""
                         ,string s6="",string s7="",string s8="",string s9="",string s10="")
  {
/*
  Produce 32bit int hash code from  a string composed of up to TEN concatenated input strings.
  WebRef: http://www.cse.yorku.ca/~oz/hash.html
  KeyWrd: "djb2"
  FirstParaOnPage:
  "  Hash Functions
  A comprehensive collection of hash functions, a hash visualiser and some test results [see Mckenzie
  et al. Selecting a Hashing Algorithm, SP&E 20(2):209-224, Feb 1990] will be available someday. If
  you just want to have a good hash function, and cannot wait, djb2 is one of the best string hash
  functions i know. it has excellent distribution and speed on many different sets of keys and table
  sizes. you are not likely to do better with one of the "well known" functions such as PJW, K&R[1],
  etc. Also see tpop pp. 126 for graphing hash functions.
  "

  NOTES: 
  0. WARNING - mql4 strings maxlen=255 so... unless code changed to deal with up to 10 string parameters
     the total length of contactenated string must be <=255
  1. C source uses "unsigned [char|long]", not in MQL4 syntax
  2. When you hash a value, you cannot 'unhash' it. Hashing is a one-way process.
     Using traditional symetric encryption techniques (such as Triple-DES) provide the reversible encryption behaviour you require.
     Ref:http://forums.asp.net/t/886426.aspx subj:Unhash password when using NT Security poster:Participant
  //
  Downside?
  original code uses UNSIGNED - MQL4 not support this, presume could use type double and then cast back to type int.
*/
   string s;
   int k=StringConcatenate(s,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10);
   int iHash = 5381;
   int iLast = StringLen(s)-1;
   int iPos=0;

   while(iPos<=iLast) //while (c = *str++)	[ consume str bytes until EOS hit {myWord! isn't C concise! Pity MQL4 is"!"} ]
     {
      //original C code: hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
      iHash=((iHash<<5)+iHash)+StringGetCharacter(s,iPos);      //StringGetChar() returns int
      iPos++;
     }
   return(MathAbs(iHash));
  }
//+------------------------------------------------------------------+
double MyRobot::LucroOrdensPts()
  {
//--- request trade history 
   static int total_deals=0;
   static int total_deals_prev=0;
   static double profit=0;
   ulong ticket=0;
   datetime tm_end=TimeCurrent();
   MqlDateTime stm_end,time_aux;
   TimeToStruct(tm_end,stm_end);
   time_aux=stm_end;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);
   HistorySelect(tm_start,tm_end);
   total_deals=HistoryDealsTotal();
   if(total_deals>total_deals_prev)
     {
      profit=0;
      for(int i=0;i<total_deals;i++) // returns the number of current orders
        {
         ticket=HistoryDealGetTicket(i);
         mydeal.Ticket(ticket);
         if(ticket>0)
           {
            if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
              {
               profit+=mydeal.Profit();
               profit=CalcPontos(profit,mydeal.Volume());
              }
           }
        }
     }
   total_deals_prev=total_deals;

   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::LucroOrdensPts_V2()
  {
//--- request trade history 
   static int total_deals=0;
   static int total_deals_prev=0;
   static double profit=0;
   ulong ticket=0;
   long pos_id=-1;
   double price_in=0,price_out=0;
   datetime tm_end=TimeCurrent();
   MqlDateTime stm_end,time_aux;
   TimeToStruct(tm_end,stm_end);
   time_aux=stm_end;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);
   HistorySelect(tm_start,tm_end);
   total_deals=HistoryDealsTotal();
   if(total_deals>total_deals_prev)
     {
      profit=0;
      for(int i=0;i<total_deals;i++) // returns the number of current orders
        {
         ticket=HistoryDealGetTicket(i);
         mydeal.Ticket(ticket);
         if(ticket>0)
           {
            //    ulong deal_entry=mydeal.Entry();
            //  Print(mydeal.EntryDescription()," ",IntegerToString(mydeal.PositionId())," ",DoubleToString(mydeal.Price(),2));
            //        if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && mydeal.Entry()==DEAL_ENTRY_IN)
              {
               pos_id=mydeal.PositionId();
               price_in=mydeal.Price();
              }
            if(mydeal.PositionId()==pos_id && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
              {
               price_out=mydeal.Price();
               if(mydeal.DealType()==DEAL_TYPE_BUY)
                  profit+=price_in-price_out;
               if(mydeal.DealType()==DEAL_TYPE_SELL)
                  profit+=price_out-price_in;
              }

           }
        }
     }
   total_deals_prev=total_deals;

   return(profit/ponto);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::LucroOrdensTicks_V2()
  {
//--- request trade history 
   static int total_deals=0;
   static int total_deals_prev=0;
   static double profit=0;
   ulong ticket=0;
   long pos_id=-1;
   double price_in=0,price_out=0;
   datetime tm_end=TimeCurrent();
   MqlDateTime stm_end,time_aux;
   TimeToStruct(tm_end,stm_end);
   time_aux=stm_end;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);
   HistorySelect(tm_start,tm_end);
   total_deals=HistoryDealsTotal();
   if(total_deals>total_deals_prev)
     {
      profit=0;
      for(int i=0;i<total_deals;i++) // returns the number of current orders
        {
         ticket=HistoryDealGetTicket(i);
         mydeal.Ticket(ticket);
         if(ticket>0)
           {
            //    ulong deal_entry=mydeal.Entry();
            //  Print(mydeal.EntryDescription()," ",IntegerToString(mydeal.PositionId())," ",DoubleToString(mydeal.Price(),2));
            //        if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && mydeal.Entry()==DEAL_ENTRY_IN)
              {
               pos_id=mydeal.PositionId();
               price_in=mydeal.Price();
              }
            if(mydeal.PositionId()==pos_id && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
              {
               price_out=mydeal.Price();
               if(mydeal.DealType()==DEAL_TYPE_BUY)
                  profit+=price_in-price_out;
               if(mydeal.DealType()==DEAL_TYPE_SELL)
                  profit+=price_out-price_in;
              }

           }
        }
     }
   total_deals_prev=total_deals;

   return(profit/ticksize);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MyRobot::LucroOrdensTicks()
  {
//--- request trade history 
   static int total_deals=0;
   static int total_deals_prev=0;
   static double profit=0;
   ulong ticket=0;
   datetime tm_end=TimeCurrent();
   MqlDateTime stm_end,time_aux;
   TimeToStruct(tm_end,stm_end);
   time_aux=stm_end;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);
   HistorySelect(tm_start,tm_end);
   total_deals=HistoryDealsTotal();
   if(total_deals>total_deals_prev)
     {
      profit=0;
      for(int i=0;i<total_deals;i++) // returns the number of current orders
        {
         ticket=HistoryDealGetTicket(i);
         mydeal.Ticket(ticket);
         if(ticket>0)
           {
            if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
              {
               profit+=mydeal.Profit();
               profit=CalcTicks(profit,mydeal.Volume());
              }
           }
        }
     }
   total_deals_prev=total_deals;

   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::TrailingStopMoabi(double pTrailPoints,double pMinProfit=0,double pStep=10,const CalcDist _pcalcdist=CalcPont)
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number && pTrailPoints>0)
        {

         double currentTakeProfit=myposition.TakeProfit();
         long posType=myposition.PositionType();
         double currentStop=myposition.StopLoss();
         double openPrice=myposition.PriceOpen();
         double _tick=SymbolInfoDouble(myposition.Symbol(),SYMBOL_TRADE_TICK_SIZE);
         if(pStep<_tick) pStep=_tick;
         double step=_pcalcdist==CalcPont?pStep*ponto:pStep*ticksize;
         double minProfit = _pcalcdist==CalcPont?pMinProfit * ponto:pMinProfit * ticksize;
         double trailStop = _pcalcdist==CalcPont?pTrailPoints * ponto:pTrailPoints * ticksize;
         minProfit=MathRound(minProfit/ticksize)*ticksize;
         trailStop=MathRound(trailStop/ticksize)*ticksize;
         currentTakeProfit=NormalizeDouble(currentTakeProfit,digits);
         double trailStopPrice;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            trailStopPrice = bid - trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=bid-openPrice;

            if(trailStopPrice>currentStop+step && currentProfit>=minProfit)
              {
               mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);

              }

           }
         else if(posType==POSITION_TYPE_SELL)
           {
            trailStopPrice = ask + trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=openPrice-ask;

            if((trailStopPrice<currentStop-step || currentStop==0) && currentProfit>=minProfit)
              {
               mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);

              }

           }
        }

     }
  }
//+------------------------------------------------------------------+
bool MyRobot::ArrowSellCreate(const long            chart_ID=0,// ID do gráfico
                              const string          name="ArrowSell",  // nome do sinal
                              const int             sub_window=0,      // índice da sub-janela
                              datetime              time=0,            // ponto de ancoragem do tempo
                              double                price=0,           // ponto de ancoragem do preço
                              const color           clr=clrRed,// cor do sinal
                              const ENUM_LINE_STYLE style=STYLE_SOLID, // estilo de linha (quando destacado)
                              const int             width=1,           // tamanho da linha (quando destacada)
                              const bool            back=false,        // no fundo
                              const bool            selection=false,   // destaque para mover
                              const bool            hidden=true,       // ocultar na lista de objetos
                              const long            z_order=0)         // prioridade para clique do mouse
  {
//--- definir as coordenadas de pontos de ancoragem, se eles não estão definidos
   ChangeArrowEmptyPoint(time,price);
//--- redefine o valor de erro
   ResetLastError();
//--- criar o sinal
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_SELL,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": falha ao criar sinal \"Sell\"! Código de erro = ",GetLastError());
      return(false);
     }
//--- definir uma cor de sinal
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- definir um estilo de linha (quando destacado)
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- definir um tamanho de linha (quando destacado)
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- exibir em primeiro plano (false) ou fundo (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- permitir (true) ou desabilitar (false) o modo de movimento do sinal com o mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- ocultar (true) ou exibir (false) o nome do objeto gráfico na lista de objeto 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- definir a prioridade para receber o evento com um clique do mouse no gráfico
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- sucesso na execução
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::ArrowBuyCreate(const long            chart_ID=0,// ID do gráfico
                             const string          name="ArrowBuy",// nome do sinal
                             const int             sub_window=0,      // índice da sub-janela
                             datetime              time=0,            // ponto de ancoragem do tempo
                             double                price=0,           // ponto de ancoragem do preço
                             const color           clr=clrBlue,// cor do sinal
                             const ENUM_LINE_STYLE style=STYLE_SOLID, // estilo de linha (quando destacado)
                             const int             width=1,           // tamanho da linha (quando destacada)
                             const bool            back=false,        // no fundo
                             const bool            selection=false,   // destaque para mover
                             const bool            hidden=true,       // ocultar na lista de objetos
                             const long            z_order=0)         // prioridade para clique do mouse
  {
//--- definir as coordenadas de pontos de ancoragem, se eles não estão definidos
   ChangeArrowEmptyPoint(time,price);
//--- redefine o valor de erro
   ResetLastError();
//--- criar o sinal
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_BUY,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": falha ao criar sinal \"Buy\"! Código de erro = ",GetLastError());
      return(false);
     }
//--- definir uma cor de sinal
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- definir um estilo de linha (quando destacado)
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- definir um tamanho de linha (quando destacado)
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- exibir em primeiro plano (false) ou fundo (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- permitir (true) ou desabilitar (false) o modo de movimento do sinal com o mouse
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- ocultar (true) ou exibir (false) o nome do objeto gráfico na lista de objeto 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- definir a prioridade para receber o evento com um clique do mouse no gráfico
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- sucesso na execução
   return(true);
  }
//+------------------------------------------------------------------+
void MyRobot::ChangeArrowEmptyPoint(datetime &time,double &price)
  {
//--- se o tempo do ponto não está definido, será na barra atual
   if(!time)
      time=TimeCurrent();
//--- se o preço do ponto não está definido, ele terá valor Bid
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
//+------------------------------------------------------------------+
