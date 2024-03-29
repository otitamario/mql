//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"


#include<ChartObjects\ChartObjectsLines.mqh>
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

#include <Expert_Class.mqh>
MyPanel ExtDialog;

CLabel            m_label[50];
CRadioGroup radio_ativar;

#define LARGURA_PAINEL 375 // Largura Painel
#define ALTURA_PAINEL 180 // Altura Painel




// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=20082018;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input double Lot=3;//Lote Entrada
input double _Stop=300;//Stop Loss em Pontos
input double _TakeProfit=300;//Take Profit em Pontos

input string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia
sinput string strail="###------------------------Trailing Proit---------------------#####";    //Trailing
input bool UsarTrailing=false;//Usar Trailing

input double TrailProfitMin1=20;//Lucro Mínimo 1 em Moeda para Iniciar Trailing
input double TrailPerc1=90;//Porcentagem Retração 1 do Lucro para Fechar Posição

input double TrailProfitMin2=50;//Lucro Mínimo 2 em Moeda para Iniciar Trailing
input double TrailPerc2=20;//Porcentagem Retração 2 do Lucro para Fechar Posição

input double TrailStep=10;//Atualização em Moeda do Trailinng

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
sinput string sind="----------Indicadores-----------------------";//Indicadores
input int InpBearsPeriod=13; // Período Bears
input int InpBullsPeriod=13; // Período Bulls
sinput string sindcand="-------------------Candle Time-----------------------";//Candle Time
input color Clock_Color=clrAqua;//Cor
input ENUM_BASE_CORNER Corner=CORNER_RIGHT_UPPER;//Posição
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyRobot: public MyExpert
  {
private:
   string            currency_symbol;
   double            sl,tp,price_open;
   CiBearsPower     *bears;
   CiBullsPower     *bulls;
   double            TrailProfitMin;//Lucro Mínimo em Moeda para Iniciar Trailing
   double            TrailPerc;//Porcentagem Retração do Lucro para Fechar Posição

public:
   void              MyRobot();
   void             ~MyRobot();
   int               OnInit();
   void              OnDeinit();
   void              OnTick();
   string GetCurrency(){return SymbolInfoString(original_symbol,SYMBOL_CURRENCY_BASE);}
   bool              TimeDayFilter();
   virtual bool      GetIndValue();
   virtual bool      BuySignal();
   virtual bool      SellSignal();
   virtual void      MytradeTransaction();
   void              TrailingProfit(double pTrailPerc,double pMinProfit,double pStep);

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
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::OnInit(void)
  {


   if(TrailProfitMin1>=TrailProfitMin2)
     {
      string erro="Lucro Mínimo 1 em Moeda deve ser menor que Lucro Mínimo 2 em Moeda";
      MessageBox(erro);
      Print(erro);
      return (INIT_FAILED);
     }

   tradeOn=true;
   setExpName();
   setSymbol(Symbol());
   setOriginalSymbol(Symbol());
   setMagic(Magic_Number);
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

   bears=new CiBearsPower;
   bears.Create(Symbol(),periodoRobo,InpBearsPeriod);
   bears.AddToChart(curChartID,ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL));


   bulls=new CiBullsPower;
   bulls.Create(Symbol(),periodoRobo,InpBullsPeriod);
   bulls.AddToChart(curChartID,ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL));


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
      return (INIT_FAILED);
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Lot<mysymbol.LotsMin())
     {
      string erro="Lote deve ser maior ou igual a "+DoubleToString(mysymbol.LotsMin(),2);
      MessageBox(erro);
      Print(erro);
      return (INIT_FAILED);
     }

   if(HistorySelect(iTime(original_symbol,PERIOD_D1,0),TimeCurrent()+PeriodSeconds(PERIOD_D1)))
     {
      int total_deals=HistoryDealsTotal();
      int ticket_history_deal=0;
      int cont_deals=0;
      for(uint i=0;i<total_deals;i++)
        {
         //--- try to get deals ticket_history_deal
         if((ticket_history_deal=HistoryDealGetTicket(i))>0)
           {
            int deal_magic=HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
            if(deal_magic==Magic_Number && HistoryDealGetString(ticket_history_deal,DEAL_SYMBOL)==mysymbol.Name())cont_deals+=1;
           }
        }
      gv.Set("deals_total_prev",(double)cont_deals);

     }

   return (INIT_SUCCEEDED);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(void)
  {
   gv.Deinit();
   DeletaIndicadores();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTick(void)
  {

   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today",(double)TimeNow.day_of_year);

   bool novodia;
   novodia=isNewBar(iTime(original_symbol,PERIOD_D1,0));

   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      gv.Set("glob_entr_tot",0.0);
      gv.Set("deals_total_prev",0.0);
      tradeOn=true;
     }

   gv.Set("gv_today_prev",gv.Get("gv_today"));

   MytradeTransaction();

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   bears.Refresh();
   bulls.Refresh();
   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }

//   ExtDialog.OnTick();

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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
     }

   timerOn=true;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
     }

   if(!PosicaoAberta())
     {
      DeleteOrdersExEntry();
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(radio_ativar.Value()==1)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
     }

   if(!timerOn && daytrade)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
     }
   if(Buy_opened() && Sell_opened())CloseByPosition();

   if(tradeOn && timerOn && radio_ativar.Value()==0)

     {// inicio Trade On

      if(isNewBar(iTime(Symbol(),periodoRobo,0)))
        {

         if(Buy_opened())
           {
            myposition.SelectByTicket((ulong)gv.Get(cp_tick));
            int  k=Bars(Symbol(),periodoRobo,myposition.Time(),TimeCurrent());
            if(k>3)
              {
               double media=0;
               for(int i=1;i<=k;i++)media+=bulls.Main(i);
               media=media/k;
               if(bulls.Main(1)<media && myposition.Volume()==Lot)
                 {
                  double lotes=MathRound(0.5*myposition.Volume()/mysymbol.LotsStep())*mysymbol.LotsStep();
                  mytrade.Sell(lotes);
                  Print("Saída Metade dos Lotes --- Indicador Menor que a Média");
                 }

              }
           }

         if(Sell_opened())
           {
            myposition.SelectByTicket((ulong)gv.Get(vd_tick));
            int  k=Bars(Symbol(),periodoRobo,myposition.Time(),TimeCurrent());
            if(k>3)
              {
               double media=0;
               for(int i=1;i<=k;i++)media+=bears.Main(i);
               media=media/k;
               if(bears.Main(1)>media && myposition.Volume()==Lot)
                 {
                  double lotes=MathRound(0.5*myposition.Volume()/mysymbol.LotsStep())*mysymbol.LotsStep();
                  mytrade.Buy(lotes);
                  Print("Saída Metade dos Lotes --- Indicador Menor que a Média");
                 }

              }
           }

         if(BuySignal() && !Buy_opened())
           {
            if(Sell_opened())ClosePosType(POSITION_TYPE_SELL);
            sl=NormalizeDouble(mysymbol.Ask()-_Stop*ponto,digits);
            tp=NormalizeDouble(mysymbol.Ask()+_TakeProfit*ponto,digits);
            if(mytrade.Buy(Lot,original_symbol,0,sl,tp,"BUY"+exp_name))gv.Set(cp_tick,(double)mytrade.ResultOrder());
            else Print("Erro enviar ordem Compra: ",GetLastError());

           }

         if(SellSignal() && !Sell_opened())
           {
            if(Buy_opened())ClosePosType(POSITION_TYPE_BUY);
            sl=NormalizeDouble(mysymbol.Bid()+_Stop*ponto,digits);
            tp=NormalizeDouble(mysymbol.Bid()-_TakeProfit*ponto,digits);
            if(mytrade.Sell(Lot,original_symbol,0,sl,tp,"SELL"+exp_name))gv.Set(vd_tick,(double)mytrade.ResultOrder());
            else Print("Erro enviar ordem Venda: ",GetLastError());

           }

        }//End NewBar

      if(PosicaoAberta())
        {
         if(LucroPositions()>=TrailProfitMin1 && LucroPositions()<TrailProfitMin2)
           {
            TrailPerc=TrailPerc1;
            TrailProfitMin=TrailProfitMin1;
           }
         else if(LucroPositions()>=TrailProfitMin2)
           {
            TrailPerc=TrailPerc2;
            TrailProfitMin=TrailProfitMin2;
           }
         else TrailPerc=-1000.0;

         if(UsarTrailing && TrailPerc!=-1000.0)TrailingProfit(TrailPerc,TrailProfitMin,TrailStep);

        }
     }//End Trade On

  }//Fim Ontick
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool MyRobot::GetIndValue()
  {
   bool b_get;
   b_get=CopyHigh(Symbol(),period,0,5,high)<=0 || 
         CopyOpen(Symbol(),period,0,5,open)<=0 || 
         CopyLow(Symbol(),period,0,5,low)<=0 || 
         CopyClose(Symbol(),period,0,5,close)<=0;

   return(b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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

     }
   return filter;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::BuySignal()
  {
   bool signal;
//   signal=MathAbs(bulls.Main(1))>MathAbs(bears.Main(1))&& MathAbs(bulls.Main(2))<MathAbs(bears.Main(2)) && bulls.Main(1)>0;
   signal=MathAbs(bulls.Main(1))>MathAbs(bears.Main(1));
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal;
//   signal=MathAbs(bulls.Main(1))<MathAbs(bears.Main(1)) && MathAbs(bulls.Main(2))>MathAbs(bears.Main(2)) && bears.Main(1)<0;
   signal=MathAbs(bulls.Main(1))<MathAbs(bears.Main(1));
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::MytradeTransaction()
  {
   ulong order_ticket;
   ulong deals_ticket;
   uint total_deals,cont_deals;
   ulong ticket_history_deal,deal_magic;
   double buyprice,sellprice;
   int TENTATIVAS=10;

   if(HistorySelect(iTime(original_symbol,PERIOD_D1,0),TimeCurrent()))
     {
      total_deals=HistoryDealsTotal();
      ticket_history_deal=0;
      deals_ticket=0;
      cont_deals=0;
      for(uint i=0;i<total_deals;i++)
        {
         ticket_history_deal=HistoryDealGetTicket(i);

         //--- try to get deals ticket_history_deal
         if((ticket_history_deal=HistoryDealGetTicket(i))>0)
           {
            deal_magic=HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
            if(deal_magic==Magic_Number && HistoryDealGetString(ticket_history_deal,DEAL_SYMBOL)==mysymbol.Name())
              {
               cont_deals+=1;
               deals_ticket=ticket_history_deal;
              }
           }
        }

      gv.Set("deals_total",(double)cont_deals);

      if(gv.Get("deals_total")>gv.Get("deals_total_prev"))
        {

         if(deals_ticket>0)
           {
            mydeal.Ticket(deals_ticket);
            order_ticket=mydeal.Order();

            if(mydeal.Comment()=="BUY"+exp_name || mydeal.Comment()=="SELL"+exp_name)
              {
               gv.Set("glob_entr_tot",gv.Get("glob_entr_tot")+1);
              }

            if(mydeal.Comment()=="BUY"+exp_name)
              {
               DeleteOrdersComment("BUY"+exp_name);
               myposition.SelectByTicket(order_ticket);
               int cont=0;
               buyprice=0;
               while(buyprice==0 && cont<TENTATIVAS)
                 {
                  buyprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(buyprice==0)buyprice=mysymbol.Ask();
              }
            //--------------------------------------------------

            if(mydeal.Comment()=="SELL"+exp_name)
              {
               DeleteOrdersComment("SELL"+exp_name);
               myposition.SelectByTicket(order_ticket);
               sellprice=myposition.PriceOpen();
               int cont=0;
               sellprice=0;
               while(sellprice==0 && cont<TENTATIVAS)
                 {
                  sellprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(sellprice==0)sellprice=mysymbol.Bid();
              }

            if((mydeal.DealType()==DEAL_TYPE_BUY || mydeal.DealType()==DEAL_TYPE_SELL) && mydeal.Entry()==DEAL_ENTRY_OUT)
              {
               if(mydeal.Profit()<0)
                 {
                  Print("Saída por STOP LOSS");
                 }

               if(mydeal.Profit()>0)
                 {
                  Print("Saída no GAIN");
                 }

              }
           }// if dealsticket>0
        }//Fim deals>prev
     }//Fim HistorySelect
   gv.Set("deals_total_prev",gv.Get("deals_total"));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::TrailingProfit(double pTrailPerc,double pMinProfit,double pStep)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number)
        {

         long posType=myposition.PositionType();
         double lots=myposition.Volume();
         double currentStop=myposition.StopLoss();
         double openPrice=NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
         double point=ponto;
         int digits=mysymbol.Digits();

         double trailStopPrice;
         double trailStop;
         double currentProfit=myposition.Profit();
         if(posType==POSITION_TYPE_BUY)
           {
            trailStopPrice=(bid-currentStop)*myposition.Volume()*ponto*mysymbol.TickValue()/ticksize;

            if((1-pTrailPerc*0.01)*currentProfit<trailStopPrice+(1-pTrailPerc*0.01)*pStep && currentProfit>=pMinProfit)
              {
               trailStop=(currentProfit*pTrailPerc*0.01*ticksize/mysymbol.TickValue())*ponto;
               trailStop=trailStop/myposition.Volume();
               trailStop=MathRound(trailStop/ticksize)*ticksize;
               trailStopPrice=NormalizeDouble(bid-trailStop*ponto,digits);
               if(trailStopPrice>currentStop) mytrade.PositionModify(myposition.Ticket(),trailStopPrice,myposition.TakeProfit());
              }

           }
         else if(posType==POSITION_TYPE_SELL)
           {
            trailStopPrice=(currentStop-ask)*myposition.Volume()*ponto*mysymbol.TickValue()/ticksize;
            if((1-pTrailPerc*0.01)*currentProfit<trailStopPrice+(1-pTrailPerc*0.01)*pStep && currentProfit>=pMinProfit)
              {
               trailStop=(currentProfit*pTrailPerc*0.01*ticksize/mysymbol.TickValue())*ponto;
               trailStop=trailStop/myposition.Volume();
               trailStop=MathRound(trailStop/ticksize)*ticksize;
               trailStopPrice=NormalizeDouble(ask+trailStop*ponto,digits);
               if(trailStopPrice<currentStop) mytrade.PositionModify(myposition.Ticket(),trailStopPrice,myposition.TakeProfit());
              }

           }
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
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
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   MyEA.OnDeinit();
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.Destroy(reason);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   MyEA.OnTick();
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.OnTick();
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  {
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.ChartEvent(id,lparam,dparam,sparam);
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

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Nome: "+AccountInfoString(ACCOUNT_NAME),xx1,yy1,xx2,yy2))
      return(false);
   m_label[0].Color(clrDeepSkyBlue);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;


   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"RESULTADO MENSAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[1].Color(clrYellow);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"RESULTADO SEMANAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[2].Color(clrMediumSpringGreen);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+3*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"RESULTADO DIÁRIO: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[3].Color(clrMediumSpringGreen);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+4*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],MyEA.CandleTime(),xx1,yy1,xx2,yy2))
      return(false);
   m_label[4].Color(clrAqua);

   xx1=0.65*x2+INDENT_LEFT;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+2*CONTROLS_GAP_Y;
   xx2=xx1+0.7*GROUP_WIDTH;
   yy2=yy1+RADIO_HEIGHT;

//--- create 
   if(!CreateRadioGroup(m_chart_id,"Radio Group",m_subwin,radio_ativar,xx1,yy1,xx2,yy2))
      return(false);
   radio_ativar.AddItem("Ativar EA",0);
   radio_ativar.AddItem("Desativar EA",1);
   radio_ativar.BorderType(BORDER_FLAT);
   radio_ativar.ColorBorder(clrAqua);
   radio_ativar.Value(0);
   radio_ativar.Show();

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyPanel::OnTick(void)
  {
   m_label[0].Text("Nome: "+AccountInfoString(ACCOUNT_NAME));
   m_label[1].Text("RESULTADO MENSAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2));
   m_label[2].Text("RESULTADO SEMANAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2));
   m_label[3].Text("RESULTADO DIÁRIO: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2));
   m_label[4].Text(MyEA.CandleTime());
  }
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(MyPanel)
ON_EVENT(ON_CHANGE,radio_ativar,OnChangeRadioGroup)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
void OnChangeRadioGroup(void)
  {
   Print(__FUNCTION__+" : Value="+IntegerToString(radio_ativar.Value()));
   if(radio_ativar.Value()==0) Alert("EA Ativado");
   else Alert("EA Desativado");
  }
//+------------------------------------------------------------------+
