//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#resource "\\Indicators\\Iguana.ex5"

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

#define LARGURA_PAINEL 360 // Largura Painel
#define ALTURA_PAINEL 200 // Altura Painel




// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=20082018;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input double Lot=3;//Lote Entrada
input double _TakeProfit=300;//Take Profit em Pontos

input string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia

sinput string srealp="############------------------------Realização Parcial-------------------------------#################";//Realização Parcial
input double rp1=50;//Pontos R.P 1 (0 Não Usar)
input double _lts_rp1=25;//Porcentagem Lotes R.P 1
input double rp2=100;//Pontos R.P 2 (0 Não Usar)
input double _lts_rp2=25;//Porcentagem Lotes R.P 2
input double rp3=0;//Pontos R.P 3 (0 Não Usar)
input double _lts_rp3=25;//Porcentagem Lotes R.P 3

sinput string STrailing="############---------------Trailing Stop----------########";//Trailing
input bool   Use_TraillingStop=false; //Usar Trailing 
input double TraillingStart=0;//Lucro Minimo Iniciar trailing stop
input double TraillingDistance=200;// Distancia em Pontos do Stop Loss
input double TraillingStep=10;// Passo para atualizar Stop Loss

sinput string sbreak="########---------Break Even---------------###############";//BreakEven
input    bool              UseBreakEven=false;                          //Usar BreakEven
input    double               BreakEvenPoint1=2;                            //Pontos para BreakEven 1
input    double               ProfitPoint1=0.5;                             //Pontos de Lucro da Posicao 1
input    double               BreakEvenPoint2         =70;                            //Pontos para BreakEven 2
input    double               ProfitPoint2            =10;                            //Pontos de Lucro da Posicao 2
input    double               BreakEvenPoint3=120;                            //Pontos para BreakEven 3
input    double               ProfitPoint3=50;                            //Pontos de Lucro da Posicao 3
input    double               BreakEvenPoint4=150;                            //Pontos para BreakEven 4
input    double               ProfitPoint4=90;                            //Pontos de Lucro da Posicao 4
input    double               BreakEvenPoint5         =250;                            //Pontos para BreakEven 5
input    double               ProfitPoint5            =180;                            //Pontos de Lucro da Posicao 5


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
sinput string sindmed="---------------------------------------";//Renko Colors
input int period_mfast=5;               // Período Média Rápida
input int period_mslow=15;               // Período Média Lenta
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyRobot: public MyExpert
  {
private:
   double            PointBreakEven[5];
   double            PointProfit[5];
   string            currency_symbol;
   double            sl,tp,price_open;
   int               iguana_handle;
   double            IguanaCompra[],IguanaVenda[];
public:
   void              MyRobot();
   void             ~MyRobot();
   bool              OnInit();
   void              OnDeinit();
   void              OnTick();
   bool              CandlesAlta(const int ncandles);
   bool              CandlesBaixa(const int ncandles);
   string GetCurrency(){return SymbolInfoString(original_symbol,SYMBOL_CURRENCY_BASE);}
   bool              TimeDayFilter();
   virtual bool      GetIndValue();
   virtual bool      BuySignal();
   virtual bool      SellSignal();
   virtual void      MytradeTransaction();
   void              Real_Parc_Buy(double vol,double preco);
   void              Real_Parc_Sell(double vol,double preco);
   bool              IguanaAlta();
   bool              IguanaBaixa();
   bool              Is4Low();
   bool              Is4High();

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
bool MyRobot::OnInit(void)
  {

   if(TimeCurrent()>D'2019.01.15 23:59:59')
     {
      string erro="Data de Validade Expirou";
      MessageBox(erro);
      Print(erro);
      return false;
     }
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO)
     {
      string erro="EA permitido apenas em conta DEMO";
      MessageBox(erro);
      Print(erro);
      return false;
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
   iguana_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\Iguana.ex5");
   ChartIndicatorAdd(curChartID,0,iguana_handle);
   ArraySetAsSeries(IguanaVenda,true);
   ArraySetAsSeries(IguanaCompra,true);
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
      return false;
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Lot<mysymbol.LotsMin())
     {
      string erro="Lote deve ser maior ou igual a "+DoubleToString(mysymbol.LotsMin(),2);
      MessageBox(erro);
      Print(erro);
      return false;
     }

   PointBreakEven[0]=BreakEvenPoint1; PointBreakEven[1]=BreakEvenPoint2; PointBreakEven[2]=BreakEvenPoint3;
   PointBreakEven[3]=BreakEvenPoint4; PointBreakEven[4]=BreakEvenPoint5;
   PointProfit[0]=ProfitPoint1; PointProfit[1]=ProfitPoint2; PointProfit[2]=ProfitPoint3;
   PointProfit[3]=ProfitPoint4; PointProfit[4]=ProfitPoint5;


// parametros incorretos desnecessarios na otimizacao

   for(int i=0;i<5;i++)
     {
      if(PointBreakEven[i]<PointProfit[i])
        {
         string erro="Profit do Break Even deve ser menor que o Ponto de Break Even";
         MessageBox(erro);
         Print(erro);
         return false;
        }

     }

   for(int i=0;i<4;i++)
     {
      if(PointBreakEven[i+1]<=PointBreakEven[i])
        {
         string erro="Pontos de Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return false;

        }
     }

   for(int i=0;i<4;i++)
     {
      if(PointProfit[i+1]<=PointProfit[i])
        {
         string erro="Pontos de Profit do Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return false;
        }

     }

   if(HistorySelect(iTime(original_symbol,PERIOD_D1,0),TimeCurrent()))
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

   return true;


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(void)
  {
   gv.Deinit();
   DeletaIndicadores();
   int k=ObjectsDeleteAll(0,0,OBJ_HLINE);
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
   if(!timerOn && daytrade)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
     }
   if(Buy_opened() && Sell_opened())CloseByPosition();

   if(tradeOn && timerOn)

     {// inicio Trade On

      if(isNewBar(iTime(Symbol(),periodoRobo,0)))
        {

         if(BuySignal() && !PosicaoAberta())
           {
            price_open=high[1]+ticksize;
            sl=low[1]-ticksize;
            tp=NormalizeDouble(price_open+_TakeProfit*ponto,digits);
            if(!mytrade.BuyStop(Lot,price_open,original_symbol,sl,tp,order_time_type,0,"BUY"+exp_name))
               Print("Erro enviar ordem BuyStop ",GetLastError());

            price_open=low[1]+0.5*(high[1]-low[1]);
            price_open=NormalizeDouble(MathRound(price_open/ticksize)*ticksize,digits);
            sl=high[1]-0.618*(high[1]-low[1]);
            sl=NormalizeDouble(MathRound(sl/ticksize)*ticksize,digits);
            tp=NormalizeDouble(price_open+_TakeProfit*ponto,digits);
            if(!mytrade.BuyLimit(Lot,price_open,original_symbol,sl,tp,order_time_type,0,"BUY"+exp_name))
               Print("Erro enviar ordem BuyLimit ",GetLastError());
           }

         if(SellSignal() && !PosicaoAberta())
           {
            price_open=low[1]-ticksize;
            sl=high[1]+ticksize;
            tp=NormalizeDouble(price_open-_TakeProfit*ponto,digits);
            if(!mytrade.SellStop(Lot,price_open,original_symbol,sl,tp,order_time_type,0,"SELL"+exp_name))
               Print("Erro enviar ordem SellStop ",GetLastError());

            price_open=low[1]+0.5*(high[1]-low[1]);
            price_open=NormalizeDouble(MathRound(price_open/ticksize)*ticksize,digits);
            sl=low[1]+0.618*(high[1]-low[1]);
            sl=NormalizeDouble(MathRound(sl/ticksize)*ticksize,digits);
            tp=NormalizeDouble(price_open-_TakeProfit*ponto,digits);
            if(!mytrade.SellLimit(Lot,price_open,original_symbol,sl,tp,order_time_type,0,"SELL"+exp_name))
               Print("Erro enviar ordem SellLimit ",GetLastError());

           }

        }//End NewBar

      if(PosicaoAberta() && Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);
      if(PosicaoAberta() && UseBreakEven)BreakEven(original_symbol,UseBreakEven,PointBreakEven,PointProfit);

     }//End Trade On

  }//Fim Ontick
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool MyRobot::GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(iguana_handle,0,0,5,IguanaVenda)<=0 || 
         CopyBuffer(iguana_handle,1,0,5,IguanaCompra)<=0 || 
         CopyHigh(Symbol(),period,0,5,high)<=0 ||
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
   signal=IguanaCompra[1]!=EMPTY_VALUE;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal;
   signal=IguanaVenda[1]!=EMPTY_VALUE;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::Real_Parc_Buy(double vol,double preco)
  {
   double lts_rp1=0;
   double lts_rp2=0;
   double lts_rp3=0;
   if(vol>mysymbol.LotsMin())
     {
      myposition.SelectByTicket((ulong)gv.Get(cp_tick));
      if(rp1>0 && _lts_rp1>0)
        {
         lts_rp1=MathMin(MathFloor(0.01*_lts_rp1*vol/mysymbol.LotsStep())*mysymbol.LotsStep(),vol);
         lts_rp1=MathMax(lts_rp1,mysymbol.LotsMin());
        }
      if(rp2>0 && _lts_rp2>0)
        {
         lts_rp2=MathFloor(0.01*_lts_rp2*vol/mysymbol.LotsStep())*mysymbol.LotsStep();
         lts_rp2=MathMax(lts_rp2,mysymbol.LotsMin());
        }
      if(lts_rp1+lts_rp2>=vol)
        {
         lts_rp2=vol-lts_rp1;
         lts_rp3=0;
         mytrade.PositionModify((ulong)gv.Get(cp_tick),myposition.StopLoss(),0);
        }
      else
        {

         if(rp3>0 && _lts_rp3>0)
           {
            lts_rp3=MathFloor(0.01*_lts_rp3*vol/mysymbol.LotsStep())*mysymbol.LotsStep();
            lts_rp3=MathMax(lts_rp3,mysymbol.LotsMin());
           }
         if(lts_rp1+lts_rp2+lts_rp3>=vol)
           {
            lts_rp3=vol-lts_rp1-lts_rp2;
            mytrade.PositionModify((ulong)gv.Get(cp_tick),myposition.StopLoss(),0);

           }
        }

      if(rp1>0&&lts_rp1>0)mytrade.SellLimit(lts_rp1,NormalizeDouble(MathRound((preco+rp1*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 1");
      if(rp2>0&&lts_rp2>0)mytrade.SellLimit(lts_rp2,NormalizeDouble(MathRound((preco+rp2*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 2");
      if(rp3>0&&lts_rp3>0)mytrade.SellLimit(lts_rp3,NormalizeDouble(MathRound((preco+rp3*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 3");


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::Real_Parc_Sell(double vol,double preco)
  {
   double lts_rp1=0;
   double lts_rp2=0;
   double lts_rp3=0;
   if(vol>mysymbol.LotsMin())
     {
      myposition.SelectByTicket((ulong)gv.Get(vd_tick));
      if(rp1>0 && _lts_rp1>0)
        {
         lts_rp1=MathMin(MathFloor(0.01*_lts_rp1*vol/mysymbol.LotsStep())*mysymbol.LotsStep(),vol);
         lts_rp1=MathMax(lts_rp1,mysymbol.LotsMin());
        }
      if(rp2>0 && _lts_rp2>0)
        {
         lts_rp2=MathFloor(0.01*_lts_rp2*vol/mysymbol.LotsStep())*mysymbol.LotsStep();
         lts_rp2=MathMax(lts_rp2,mysymbol.LotsMin());
        }
      if(lts_rp1+lts_rp2>=vol)
        {
         lts_rp2=vol-lts_rp1;
         lts_rp3=0;
         mytrade.PositionModify((ulong)gv.Get(cp_tick),myposition.StopLoss(),0);
         //mytrade.OrderDelete((ulong)GlobalVariableGet(tp_cp_tick));
        }
      else
        {

         if(rp3>0 && _lts_rp3>0)
           {
            lts_rp3=MathFloor(0.01*_lts_rp3*vol/mysymbol.LotsStep())*mysymbol.LotsStep();
            lts_rp3=MathMax(lts_rp3,mysymbol.LotsMin());
           }
         if(lts_rp1+lts_rp2+lts_rp3>=vol)
           {
            lts_rp3=vol-lts_rp1-lts_rp2;
            mytrade.PositionModify((ulong)gv.Get(cp_tick),myposition.StopLoss(),0);
            // mytrade.OrderDelete((ulong)GlobalVariableGet(tp_cp_tick));

           }
        }
      if(rp1>0&&lts_rp1>0)mytrade.BuyLimit(lts_rp1,NormalizeDouble(MathRound((preco-rp1*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 1");
      if(rp2>0&&lts_rp2>0)mytrade.BuyLimit(lts_rp2,NormalizeDouble(MathRound((preco-rp2*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 2");
      if(rp3>0&&lts_rp3>0)mytrade.BuyLimit(lts_rp3,NormalizeDouble(MathRound((preco-rp3*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 3");


     }
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
               Real_Parc_Buy(Lot,buyprice);
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
               Real_Parc_Sell(Lot,sellprice);

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
bool MyRobot::Is4High()
  {
   int val_index=iHighest(Symbol(),periodoRobo,MODE_CLOSE,4,1);
   if(val_index==1)return true;
   else return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::Is4Low()
  {
   int val_index=iLowest(Symbol(),periodoRobo,MODE_CLOSE,4,1);
   if(val_index==1)return true;
   else return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::IguanaBaixa()
  {
   double corpo=iHigh(Symbol(),periodoRobo,1)-iLow(Symbol(),periodoRobo,1);
   double open25cents=iLow(Symbol(),periodoRobo,1)+0.25*corpo;
   bool open_close25=iOpen(Symbol(),periodoRobo,1)<=open25cents && iClose(Symbol(),periodoRobo,1)<=open25cents;
   return open_close25&&corpo>=10*ticksize&&Is4High();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::IguanaAlta()
  {
   double corpo=iHigh(Symbol(),periodoRobo,1)-iLow(Symbol(),periodoRobo,1);
   double open75cents=iLow(Symbol(),periodoRobo,1)+0.75*corpo;
   bool open_close75=iOpen(Symbol(),periodoRobo,1)>=open75cents && iClose(Symbol(),periodoRobo,1)>=open75cents;
   return open_close75&&corpo>=10*ticksize&&Is4Low();
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- Obtemos o número da compilação do programa 
   Print(__FUNCTION__," Build #",__MQLBUILD__);
//--- Código de motivo de reinicialização pode ser obtido na OnInit() 
   Print(__FUNCTION__," Ao reinicializar o EA, você pode obter o código de motivo da desinicialização");
//--- Primeira maneira de obter o código de motivo de desinicialização 
   Print(__FUNCTION__," _UninitReason = ",getUninitReasonText(_UninitReason));
//--- Segunda maneira de obter o código de motivo de desinicialização   
   Print(__FUNCTION__," UninitializeReason() = ",getUninitReasonText(UninitializeReason()));
//--- 

   if(!MyEA.OnInit())
      return(INIT_FAILED);

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
      return(INIT_FAILED);
//--- run application 

   ExtDialog.Run();



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

   Print(__FUNCTION__," Código de motivo da desinicialização = ",reason);
//--- Segunda maneira de obter o código de motivo de desinicialização 
   Print(__FUNCTION__," _UninitReason = ",getUninitReasonText(_UninitReason));
//--- Terceira maneira de obter o código de motivo de desinicialização   
   Print(__FUNCTION__," UninitializeReason() = ",getUninitReasonText(UninitializeReason()));

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   MyEA.OnTick();
   ExtDialog.OnTick();
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

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Nome: "+AccountInfoString(ACCOUNT_NAME),xx1,yy1,xx2,yy2))
      return(false);
   m_label[0].Color(clrDeepSkyBlue);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"Servidor: "+AccountInfoString(ACCOUNT_SERVER)+" Login: "+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)),xx1,yy1,xx2,yy2))
      return(false);
   m_label[1].Color(clrYellow);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"RESULTADO MENSAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[2].Color(clrYellow);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+3*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"RESULTADO SEMANAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[3].Color(clrMediumSpringGreen);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+4*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],"RESULTADO DIÁRIO: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[4].Color(clrMediumSpringGreen);

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyPanel::OnTick(void)
  {
   m_label[0].Text("Nome: "+AccountInfoString(ACCOUNT_NAME));
   m_label[1].Text("Servidor: "+AccountInfoString(ACCOUNT_SERVER)+" Login: "+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)));
   m_label[2].Text("RESULTADO MENSAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2));
   m_label[3].Text("RESULTADO SEMANAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2));
   m_label[4].Text("RESULTADO DIÁRIO: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2));
  }
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(MyPanel)

EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+

string getUninitReasonText(int reasonCode)
  {
   string text="";
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
