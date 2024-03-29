//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

enum ModoOp
  {
   CadaTick,//Tick
   NovaVela //Vela Cerrada
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TipoSL
  {
   SLPips,//Stop Pips Fijo
   SLVelas //Stop X Velas
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum FiltroEst
  {
   Filtro1,//Filtro 1
   Filtro2 //Filtro 2
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Operaciones
  {
   Compra,//Compra
   Venda, //Venta
   Ambos//Ambos
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum EscEst
  {
   Est1,//Estocástico 1
   Est2,//Estocástico 2
   EstTodos //Ambos Estocástico
  };

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

#include <Expert_Class_New.mqh>
MyPanel ExtDialog;

CLabel            m_label[50];

CButton BotaoBuy;
CButton BotaoSell;

#define LARGURA_PAINEL 320 // Largura Painel
#define ALTURA_PAINEL 200 // Altura Painel




// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input int MAGIC_NUMBER=26032019;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
sinput string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input double Lot=0.01;//Lot 
input int nmaxop=0;//Numero Maximo Operaciones( 0 Desactiva)
input Operaciones operacoes=Ambos;//Operaciones
input TipoSL tipostop=SLPips;//Tipo Stop
input int xvelas=0;// X Velas Atrás para STOP
input double _xPipsStop=5;//X Pips Stop - X Velas
input double _Stop=20;//Stop Loss Fijo en Pips
input double _TakeProfit=0;//Take Profit en Pips
sinput string SEst_StochEntr="############------------Estocásticos Entrada----------########";//Estocásticos Entrada
input EscEst est_ent=EstTodos;//Elegir Estocásticos Entrada
input FiltroEst filtro_ent=Filtro1;//Filtro Entrada
input int xvelas_2_ent=0;//X velas para Filtro 2 Entrada
sinput string SEst_Stoch1="############------------Estocástico 1 Entrada----------########";//Estocástico 1 Entrada
input ENUM_TIMEFRAMES period_ent1=PERIOD_CURRENT;//TIMEFRAME 
input bool ShowStocEnt1=false;//Show Escocastico Chart
input ModoOp modo_op_ent1=NovaVela;//Modo Operacion
input int                  Kperiod1=14;                 // o período K ( o número de barras para cálculo) 
input int                  Dperiod1=3;                 // o período D (o período da suavização primária) 
input int                  slowing1=3;                 // período final da suavização 
input ENUM_MA_METHOD       ma_method1=MODE_SMA;        // tipo de suavização 
input ENUM_STO_PRICE       price_field1=STO_LOWHIGH;   // método de cálculo do Estocástico 
sinput string SEst_Stoch2="############------------Estocástico 2 Entrada----------########";//Estocástico 2 Entrada
input ENUM_TIMEFRAMES period_ent2=PERIOD_CURRENT;//TIMEFRAME 
input bool ShowStocEnt2=false;//Show Escocastico Chart
input ModoOp modo_op_ent2=NovaVela;//Modo Operacion
input int                  Kperiod2=14;                 // o período K ( o número de barras para cálculo) 
input int                  Dperiod2=3;                 // o período D (o período da suavização primária) 
input int                  slowing2=3;                 // período final da suavização 
input ENUM_MA_METHOD       ma_method2=MODE_SMA;        // tipo de suavização 
input ENUM_STO_PRICE       price_field2=STO_LOWHIGH;   // método de cálculo do Estocástico 

sinput string SEst_StochPar="############------------Estocásticos Parcial----------########";//Estocásticos Parcial
input EscEst est_parc=EstTodos;//Elegir Estocásticos Parcial
input double perc_parc=0;//Porcentagem Cierre Parcial - "0" No Hacer Parcial
input FiltroEst filtro_parc=Filtro1;//Filtro Parcial
input int xvelas_2_parc=0;//X velas para Filtro 2 Parcial

sinput string SEst_Stoch3="############------------Estocástico 1 Parcial----------########";//Estocástico 1 Parcial
input ENUM_TIMEFRAMES period_parc1=PERIOD_CURRENT;//TIMEFRAME 
input bool ShowStocPar1=false;//Show Escocastico Chart
input ModoOp modo_op_par1=NovaVela;//Modo Operacion

input int                  Kperiod3=14;                 // o período K ( o número de barras para cálculo) 
input int                  Dperiod3=3;                 // o período D (o período da suavização primária) 
input int                  slowing3=3;                 // período final da suavização 
input ENUM_MA_METHOD       ma_method3=MODE_SMA;        // tipo de suavização 
input ENUM_STO_PRICE       price_field3=STO_LOWHIGH;   // método de cálculo do Estocástico 
sinput string SEst_Stoch4="############------------Estocástico 2 Parcial----------########";//Estocástico 2 Parcial
input ENUM_TIMEFRAMES period_parc2=PERIOD_CURRENT;//TIMEFRAME 
input bool ShowStocPar2=false;//Show Escocastico Chart
input ModoOp modo_op_par2=NovaVela;//Modo Operacion

input int                  Kperiod4=14;                 // o período K ( o número de barras para cálculo) 
input int                  Dperiod4=3;                 // o período D (o período da suavização primária) 
input int                  slowing4=3;                 // período final da suavização 
input ENUM_MA_METHOD       ma_method4=MODE_SMA;        // tipo de suavização 
input ENUM_STO_PRICE       price_field4=STO_LOWHIGH;   // método de cálculo do Estocástico 

sinput string SEst_StochFech="############------------Estocásticos Cierre----------########";//Estocásticos Cierre
input EscEst est_cierre=EstTodos;//Elegir Estocásticos Cierre
input FiltroEst filtro_cierre=Filtro1;//Filtro Cierre
input int xvelas_2_cierre=0;//X velas para Filtro 2 Cierre

sinput string SEst_Stoch5="############------------Estocástico 1 Cierre----------########";//Estocástico 1 Cierre
input ENUM_TIMEFRAMES period_cierre1=PERIOD_CURRENT;//TIMEFRAME 
input bool ShowStocCierre1=false;//Show Escocastico Chart
input ModoOp modo_op_cierre1=NovaVela;//Modo Operacion

input int                  Kperiod5=14;                 // o período K ( o número de barras para cálculo) 
input int                  Dperiod5=3;                 // o período D (o período da suavização primária) 
input int                  slowing5=3;                 // período final da suavização 
input ENUM_MA_METHOD       ma_method5=MODE_SMA;        // tipo de suavização 
input ENUM_STO_PRICE       price_field5=STO_LOWHIGH;   // método de cálculo do Estocástico 

sinput string SEst_Stoch6="############------------Estocástico 2 Cierre----------########";//Estocástico 2 Cierre
input ENUM_TIMEFRAMES period_cierre2=PERIOD_CURRENT;//TIMEFRAME 
input bool ShowStocCierre2=false;//Show Escocastico Chart
input ModoOp modo_op_cierre2=NovaVela;//Modo Operacion
input int                  Kperiod6=14;                 // o período K ( o número de barras para cálculo) 
input int                  Dperiod6=3;                 // o período D (o período da suavização primária) 
input int                  slowing6=3;                 // período final da suavização 
input ENUM_MA_METHOD       ma_method6=MODE_SMA;        // tipo de suavização 
input ENUM_STO_PRICE       price_field6=STO_LOWHIGH;   // método de cálculo do Estocástico 




sinput string Lucro="###---------------------Usar Lucro/Prejuizo para Cierro-----------------------#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Cierre Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Cierre  Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Cierre Dia

sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=false;//Usar Filtro de Horário: True/False
input string start_hour="9:00";//Horario Inicial
input string end_hour="18:00";//Horario Final
input bool daytrade=true;//Cierre Posicao Fim do Horario
sinput string sdias="FILTRO DIAS DA SEMANA";//Dias da Semana
input bool trade0=true;// Sunday
input bool trade1=true;// Monday
input bool trade2=true;// Tuesday
input bool trade3=true;// Wednesday
input bool trade4=true;// Thursday
input bool trade5=true;// Friday
input bool trade6=true;// Saturday
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyRobot: public MyExpert
  {
private:
   string            currency_symbol;
   double            sl,tp,price_open;
   double            max_dia,min_dia;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   CNewBar           Bar_NovaBarraEnt1;
   CNewBar           Bar_NovaBarraEnt2;
   CNewBar           Bar_NovaBarraCierre1;
   CNewBar           Bar_NovaBarraCierre2;
   CNewBar           Bar_NovaBarraParc1;
   CNewBar           Bar_NovaBarraParc2;
   double            vol_pos,vol_stp,preco_stp;
   double            sl_position,tp_position;
   double            Buyprice,Sellprice;
   CiStochastic     *estent1;
   CiStochastic     *estent2;
   CiStochastic     *estpar1;
   CiStochastic     *estpar2;
   CiStochastic     *estcierre1;
   CiStochastic     *estcierre2;
   long              chartstochent1,chartstochpar1,chartstochcierre1;
   long              chartstochent2,chartstochpar2,chartstochcierre2;
   bool              buysignal,sellsignal,novabarra;
   bool              newbar_ent1,newbar_ent2;
   bool              newbar_par1,newbar_par2;
   bool              newbar_cierre1,newbar_cierre2;
   int               glob_entr_tot;
   double            riesgo,riesgo_porc,riesgo_buy,riesgo_sell;
public:
   void              MyRobot();
   void             ~MyRobot();
   int               OnInit();
   void              OnDeinit(const int reason);
   void              OnTick();
   string GetCurrency(){return SymbolInfoString(original_symbol,SYMBOL_CURRENCY_BASE);}
   bool              TimeDayFilter();
   virtual bool      GetIndValue();
   virtual bool      BuySignal();
   virtual bool      SellSignal();
   bool              BuyClose();
   bool              SellClose();
   bool              PartialBuy();
   bool              PartialSell();
   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);
   double            MaximaXBar(const int xbars);
   double            MinimaXBar(const int xbars);
   double            CalcStop(ENUM_ORDER_TYPE order_entrada);
   void              PartialClosePosType(ENUM_POSITION_TYPE ptype);
   void              OpenBuy();
   void              OpenSell();
   int GetEntTot(){return glob_entr_tot;};
   double GetRiesgo(){return riesgo;};
   double GetRiesgoPorc(){return riesgo_porc;};
   double GetRiesgoBuy(){return riesgo_buy;};
   double GetRiesgoSell(){return riesgo_sell;};

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
   glob_entr_tot=0;
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
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
   mytrade.SetTypeFillingBySymbol(original_symbol);
   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   if(SymbolInfoInteger(original_symbol,SYMBOL_DIGITS)==3 || SymbolInfoInteger(original_symbol,SYMBOL_DIGITS)==5)
      ponto=10*ponto;
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

   if(hora_inicial>hora_final)hora_final=hora_final+PeriodSeconds(PERIOD_D1);

   setNameGvOrder();

   long curChartID=ChartID();
   if(ShowStocEnt1) chartstochent1=ChartOpen(_Symbol,period_ent1);
   estent1=new CiStochastic;
   estent1.Create(Symbol(),periodoRobo,Kperiod1,Dperiod1,slowing1,ma_method1,price_field1);
   if(ShowStocEnt1)estent1.AddToChart(chartstochent1,(int)ChartGetInteger(chartstochent1,CHART_WINDOWS_TOTAL));
   if(ShowStocEnt2) chartstochent2=ChartOpen(_Symbol,period_ent2);
   estent2=new CiStochastic;
   estent2.Create(Symbol(),periodoRobo,Kperiod2,Dperiod2,slowing2,ma_method2,price_field2);
   if(ShowStocEnt2) estent2.AddToChart(chartstochent2,(int)ChartGetInteger(chartstochent2,CHART_WINDOWS_TOTAL));

   if(ShowStocPar1)chartstochpar1=ChartOpen(_Symbol,period_parc1);
   estpar1=new CiStochastic;
   estpar1.Create(Symbol(),periodoRobo,Kperiod3,Dperiod3,slowing3,ma_method3,price_field3);
   if(ShowStocPar1) estpar1.AddToChart(chartstochpar1,(int)ChartGetInteger(chartstochpar1,CHART_WINDOWS_TOTAL));
   if(ShowStocPar2)chartstochpar2=ChartOpen(_Symbol,period_parc2);
   estpar2=new CiStochastic;
   estpar2.Create(Symbol(),periodoRobo,Kperiod4,Dperiod4,slowing4,ma_method4,price_field4);
   if(ShowStocPar2) estpar2.AddToChart(chartstochpar2,(int)ChartGetInteger(chartstochpar2,CHART_WINDOWS_TOTAL));

   if(ShowStocCierre1) chartstochcierre1=ChartOpen(_Symbol,period_cierre1);
   estcierre1=new CiStochastic;
   estcierre1.Create(Symbol(),periodoRobo,Kperiod5,Dperiod5,slowing5,ma_method5,price_field5);
   if(ShowStocCierre1) estcierre1.AddToChart(chartstochcierre1,(int)ChartGetInteger(chartstochcierre1,CHART_WINDOWS_TOTAL));
   if(ShowStocCierre2) chartstochcierre2=ChartOpen(_Symbol,period_cierre2);
   estcierre2=new CiStochastic;
   estcierre2.Create(Symbol(),periodoRobo,Kperiod6,Dperiod6,slowing6,ma_method6,price_field6);
   if(ShowStocCierre2)estcierre2.AddToChart(chartstochcierre2,(int)ChartGetInteger(chartstochcierre2,CHART_WINDOWS_TOTAL));

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


   if(tipostop==SLVelas && xvelas==0)
     {
      string erro="En Stop Loss por Velas el numero X Velas Atrás para STOP deve ser>0";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Lot<mysymbol.LotsMin())
     {
      string erro="Lote deve ser maior ou igual a "+DoubleToString(mysymbol.LotsMin(),2);
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(_Stop<0)
     {
      string erro="Stop deve ser um número>=0";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(_TakeProfit<0)
     {
      string erro="TakeProfit deve ser um número>=0";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(perc_parc<0 && perc_parc>100)
     {
      string erro="Porcentagem Parcial  deve ser um número>=0 y <=100";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(HistorySelect(iTime(original_symbol,PERIOD_D1,0),TimeCurrent()+PeriodSeconds(PERIOD_D1)))
     {
      int total_deals=HistoryDealsTotal();
      int ticket_history_deal=0;
      int cont_deals=0;
      for(int i=0;i<total_deals;i++)
        {
         //--- try to get deals ticket_history_deal
         if((ticket_history_deal=(int)HistoryDealGetTicket(i))>0)
           {
            int deal_magic=(int)HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
            if(deal_magic==Magic_Number && HistoryDealGetString(ticket_history_deal,DEAL_SYMBOL)==mysymbol.Name())cont_deals+=1;
           }
        }
      gv.Set("deals_total_prev",(double)cont_deals);

     }

   return(INIT_SUCCEEDED);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   DeletaIndicadores();
   delete(estent1);
   delete(estent2);
   delete(estpar1);
   delete(estpar2);
   delete(estcierre1);
   delete(estcierre2);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTick(void)
  {

   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today",(double)TimeNow.day_of_year);

   bool novodia;
   novodia=Bar_NovoDia.CheckNewBar(original_symbol,PERIOD_D1);

   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      gv.Set("deals_total_prev",0.0);
      tradeOn=true;
     }

   gv.Set("gv_today_prev",gv.Get("gv_today"));

   mysymbol.Refresh();
   mysymbol.RefreshRates();

   estent1.Refresh();
   estent2.Refresh();
   estpar1.Refresh();
   estpar2.Refresh();
   estcierre1.Refresh();
   estcierre2.Refresh();

   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   if(hora_inicial>hora_final)hora_final=hora_final+PeriodSeconds(PERIOD_D1);

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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!timerOn && daytrade)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
     }

   if(tradeOn && timerOn)

     {// inicio Trade On

      novabarra=Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo);// NewBar

      newbar_ent1=Bar_NovaBarraEnt1.CheckNewBar(Symbol(),period_ent1);// NewBar
      newbar_ent2=Bar_NovaBarraEnt2.CheckNewBar(Symbol(),period_ent2);// NewBar
      newbar_par1=Bar_NovaBarraParc1.CheckNewBar(Symbol(),period_parc1);// NewBar
      newbar_par2=Bar_NovaBarraParc2.CheckNewBar(Symbol(),period_parc2);// NewBar
      newbar_cierre1=Bar_NovaBarraCierre1.CheckNewBar(Symbol(),period_cierre1);// NewBar
      newbar_cierre2=Bar_NovaBarraCierre2.CheckNewBar(Symbol(),period_cierre2);// NewBar


      buysignal=BuySignal() && !PosicaoAberta() && operacoes!=Venda;
      sellsignal=SellSignal() && !PosicaoAberta() && operacoes!=Compra;
      if(buysignal)
        {
         OpenBuy();
        }

      if(sellsignal)
        {
         OpenSell();
        }

      if(!OrderCalcProfit(ORDER_TYPE_SELL,_Symbol,Lot,mysymbol.Ask(),CalcStop(ORDER_TYPE_BUY),riesgo_buy))
         riesgo_buy=0.0;
      if(!OrderCalcProfit(ORDER_TYPE_BUY,_Symbol,Lot,mysymbol.Bid(),CalcStop(ORDER_TYPE_SELL),riesgo_sell))
         riesgo_sell=0.0;

         riesgo_buy=100*(riesgo_buy/myaccount.Equity());
         riesgo_sell=100*(riesgo_sell/myaccount.Equity());


      if(Buy_opened())
        {
         myposition.Select(_Symbol);
         if(!OrderCalcProfit(ORDER_TYPE_SELL,_Symbol,myposition.Volume(),myposition.PriceOpen(),myposition.StopLoss(),riesgo))riesgo=0.0;
         riesgo_porc=100*(riesgo/myaccount.Equity());
         if(BuyClose())
           {
            ClosePosType(POSITION_TYPE_BUY);
            Print("Cierre por Estocasticos");
           }
         if(PartialBuy() && perc_parc>0)
           {
            PartialClosePosType(POSITION_TYPE_BUY);
            Print("Cierre Parcial");
           }
        }

      if(Sell_opened())
        {
         myposition.Select(_Symbol);
         if(!OrderCalcProfit(ORDER_TYPE_BUY,_Symbol,myposition.Volume(),myposition.PriceOpen(),myposition.StopLoss(),riesgo))riesgo=0.0;
         riesgo_porc=100*(riesgo/myaccount.Equity());
         if(SellClose())
           {
            ClosePosType(POSITION_TYPE_SELL);
            Print("Cierre por Estocasticos");
           }
         if(PartialSell() && perc_parc>0)
           {
            PartialClosePosType(POSITION_TYPE_SELL);
            Print("Cierre Parcial");
           }
        }

      if(!PosicaoAberta())
        {
         riesgo=0.0;
         riesgo_porc=0.0;
        }

     }//End Trade On

  }//Fim Ontick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MyRobot::OpenBuy()
  {
   sl_position=CalcStop(ORDER_TYPE_BUY);
   tp_position=0;
   if(_TakeProfit>0)tp_position=NormalizeDouble(ask+_TakeProfit*ponto,digits);
   if(mytrade.Buy(Lot,original_symbol,0,sl_position,tp_position,"BUY"+exp_name))
     {
      gv.Set(cp_tick,(double)mytrade.ResultOrder());
     }
   else Print("Erro enviar ordem ",GetLastError());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OpenSell()
  {
   sl_position=CalcStop(ORDER_TYPE_SELL);
   tp_position=0;
   if(_TakeProfit>0)tp_position=NormalizeDouble(bid-_TakeProfit*ponto,digits);
   if(mytrade.Sell(Lot,original_symbol,0,sl_position,tp_position,"SELL"+exp_name))
     {
      gv.Set(vd_tick,(double)mytrade.ResultOrder());
     }
   else Print("Erro enviar ordem ",GetLastError());
  }//+------------------------------------------------------------------+
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

double MyRobot::MaximaXBar(const int xbars)
  {
   double val=0;
   int val_index=iHighest(NULL,0,MODE_HIGH,xbars,1);
   if(val_index!=-1)
      val=iHigh(NULL,periodoRobo,val_index);
   else
      PrintFormat("Erro ao chamar iHighest(). Código de erro=%d",GetLastError());
   return val;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::MinimaXBar(const int xbars)
  {
   double val=0;
   int val_index=iLowest(original_symbol,0,MODE_LOW,xbars,1);
   if(val_index!=-1)
      val=iLow(original_symbol,periodoRobo,val_index);
   else
      PrintFormat("Erro ao chamar iHighest(). Código de erro=%d",GetLastError());
   return val;
  }
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
   bool signal=false;
   bool signal1,signal2;
   int barras_ent1=0;
   if(modo_op_ent1==NovaVela)barras_ent1=1;
   int barras_ent2=0;
   if(modo_op_ent2==NovaVela)barras_ent2=1;


   switch(est_ent)
     {
      case Est1:
         if(filtro_ent==Filtro1)signal=estent1.Main(barras_ent1)==0.0;
         else signal=estent1.Main(barras_ent1)>=20 && estent1.Main(barras_ent1+1)<20 && estent1.Main(xvelas_2_ent)==0.0;
         if(modo_op_ent1==NovaVela)signal=signal && newbar_ent1;
         break;
      case Est2:
         if(filtro_ent==Filtro1)signal=estent2.Main(barras_ent2)==0.0;
         else signal=estent2.Main(barras_ent2)>=20 && estent2.Main(barras_ent2+1)<20 && estent2.Main(xvelas_2_ent)==0.0;
         if(modo_op_ent2==NovaVela)signal=signal && newbar_ent2;
         break;
      case EstTodos:
         if(filtro_ent==Filtro1)
           {
            signal1=estent1.Main(barras_ent1)==0.0;
            if(modo_op_ent1==NovaVela)signal1=signal1 && newbar_ent1;
            signal2=estent2.Main(barras_ent2)==0.0;
            if(modo_op_ent2==NovaVela)signal2=signal2 && newbar_ent2;
            signal=signal1 && signal2;
           }
         else
           {
            signal1=(estent1.Main(barras_ent1)>=20 && estent1.Main(barras_ent1+1)<20 && estent1.Main(xvelas_2_ent)==0.0);
            if(modo_op_ent1==NovaVela)signal1=signal1 && newbar_ent1;
            signal2=(estent2.Main(barras_ent2)>=20 && estent2.Main(barras_ent2+1)<20 && estent2.Main(xvelas_2_ent)==0.0);
            if(modo_op_ent2==NovaVela)signal2=signal2 && newbar_ent2;
            signal=signal1 && signal2;
           }
         break;
     }
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellClose()
  {
   bool signal=false;
   int barras_ent1=0;
   if(modo_op_cierre1==NovaVela)barras_ent1=1;
   int barras_ent2=0;
   if(modo_op_cierre2==NovaVela)barras_ent2=1;
   bool signal1,signal2;
   switch(est_cierre)
     {
      case Est1:
         if(filtro_cierre==Filtro1)signal=estcierre1.Main(barras_ent1)==0.0;
         else signal=estcierre1.Main(barras_ent1)>=20 && estcierre1.Main(barras_ent1+1)<20 && estcierre1.Main(xvelas_2_cierre)==0.0;
         if(modo_op_cierre1==NovaVela)signal=signal && newbar_cierre1;
         break;
      case Est2:
         if(filtro_cierre==Filtro1)signal=estcierre2.Main(barras_ent2)==0.0;
         else signal=estcierre2.Main(barras_ent2)>=20 && estcierre2.Main(barras_ent2+1)<20 && estcierre2.Main(xvelas_2_cierre)==0.0;
         if(modo_op_cierre2==NovaVela)signal=signal && newbar_cierre2;
         break;
      case EstTodos:
         if(filtro_cierre==Filtro1)
           {
            signal1=estcierre1.Main(barras_ent1)==0.0;
            if(modo_op_cierre1==NovaVela)signal1=signal1 && newbar_cierre1;
            signal2=estcierre2.Main(barras_ent2)==0.0;
            if(modo_op_cierre2==NovaVela)signal2=signal2 && newbar_cierre2;
            signal=signal1 && signal2;
           }
         else
           {
            signal1=(estcierre1.Main(barras_ent1)>=20 && estcierre1.Main(barras_ent1+1)<20 && estcierre1.Main(xvelas_2_cierre)==0.0);
            if(modo_op_cierre1==NovaVela)signal1=signal1 && newbar_cierre1;
            signal2=(estcierre2.Main(barras_ent2)>=20 && estcierre2.Main(barras_ent2+1)<20 && estcierre2.Main(xvelas_2_cierre)==0.0);
            if(modo_op_cierre2==NovaVela)signal2=signal2 && newbar_cierre2;
            signal=signal1 && signal2;

           }
         break;
     }
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::PartialSell()
  {
   bool signal=false;
   int barras_ent1=0;
   if(modo_op_par1==NovaVela)barras_ent1=1;
   int barras_ent2=0;
   if(modo_op_par2==NovaVela)barras_ent2=1;
   bool signal1,signal2;

   switch(est_parc)
     {
      case Est1:
         if(filtro_parc==Filtro1)signal=estpar1.Main(barras_ent1)==0.0;
         else signal=estpar1.Main(barras_ent1)>=20 && estpar1.Main(barras_ent1+1)<20 && estpar1.Main(xvelas_2_parc)==0.0;
         if(modo_op_par1==NovaVela)signal=signal && newbar_par1;

         break;
      case Est2:
         if(filtro_parc==Filtro1)signal=estpar2.Main(barras_ent2)==0.0;
         else signal=estpar2.Main(barras_ent2)>=20 && estpar2.Main(barras_ent2+1)<20 && estpar2.Main(xvelas_2_parc)==0.0;
         if(modo_op_par2==NovaVela)signal=signal && newbar_par2;

         break;
      case EstTodos:
         if(filtro_parc==Filtro1)
           {
            signal1=estpar1.Main(barras_ent1)==0.0;
            if(modo_op_par1==NovaVela)signal1=signal1 && newbar_par1;
            signal2=estpar2.Main(barras_ent2)==0.0;
            if(modo_op_par2==NovaVela)signal2=signal2 && newbar_par2;
            signal=signal1 && signal2;
           }

         else
           {
            signal1=(estpar1.Main(barras_ent1)>=20 && estpar1.Main(barras_ent1+1)<20 && estpar1.Main(xvelas_2_parc)==0.0);
            if(modo_op_par1==NovaVela)signal1=signal1 && newbar_par1;
            signal2=(estpar2.Main(barras_ent2)>=20 && estpar2.Main(barras_ent2+1)<20 && estpar2.Main(xvelas_2_parc)==0.0);
            if(modo_op_par2==NovaVela)signal2=signal2 && newbar_par2;
            signal=signal1 && signal2;
           }
         break;
     }
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal=false;
   int barras_ent1=0;
   if(modo_op_ent1==NovaVela)barras_ent1=1;
   int barras_ent2=0;
   if(modo_op_ent2==NovaVela)barras_ent2=1;
   bool signal1,signal2;

   switch(est_ent)
     {
      case Est1:
         if(filtro_ent==Filtro1)signal=estent1.Main(barras_ent1)==100.0;
         else signal=estent1.Main(barras_ent1)<=80 && estent1.Main(barras_ent1+1)>80 && estent1.Main(xvelas_2_ent)==100.0;
         if(modo_op_ent1==NovaVela)signal=signal && newbar_ent1;
         break;
      case Est2:
         if(filtro_ent==Filtro1)signal=estent2.Main(barras_ent2)==100.0;
         else signal=estent2.Main(barras_ent2)<=80 && estent2.Main(barras_ent2+1)>80 && estent2.Main(xvelas_2_ent)==100.0;
         if(modo_op_ent2==NovaVela)signal=signal && newbar_ent2;
         break;
      case EstTodos:
         if(filtro_ent==Filtro1)
           {
            signal1=estent1.Main(barras_ent1)==100.0;
            if(modo_op_ent1==NovaVela)signal1=signal1 && newbar_ent1;
            signal2=estent2.Main(barras_ent2)==100.0;
            if(modo_op_ent2==NovaVela)signal2=signal2 && newbar_ent2;
            signal=signal1 && signal2;
           }
         else
           {
            signal1=(estent1.Main(barras_ent1)<=80 && estent1.Main(barras_ent1+1)>80 && estent1.Main(xvelas_2_ent)==0.0);
            if(modo_op_ent1==NovaVela)signal1=signal1 && newbar_ent1;
            signal2=(estent2.Main(barras_ent2)<=80 && estent2.Main(barras_ent2+1)>80 && estent2.Main(xvelas_2_ent)==0.0);
            if(modo_op_ent2==NovaVela)signal2=signal2 && newbar_ent2;
            signal=signal1 && signal2;

           }
         break;
     }
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::BuyClose()
  {
   bool signal=false;
   int barras_ent1=0;
   if(modo_op_cierre1==NovaVela)barras_ent1=1;
   int barras_ent2=0;
   if(modo_op_cierre2==NovaVela)barras_ent2=1;
   bool signal1,signal2;

   switch(est_cierre)
     {
      case Est1:
         if(filtro_cierre==Filtro1)signal=estcierre1.Main(barras_ent1)==100.0;
         else signal=estcierre1.Main(barras_ent1)<=80 && estcierre1.Main(barras_ent1+1)>80 && estcierre1.Main(xvelas_2_cierre)==100.0;
         if(modo_op_cierre1==NovaVela)signal=signal && newbar_cierre1;
         break;
      case Est2:
         if(filtro_cierre==Filtro1)signal=estcierre2.Main(barras_ent2)==100.0;
         else signal=estcierre2.Main(barras_ent2)<=80 && estcierre2.Main(barras_ent2+1)>80 && estcierre2.Main(xvelas_2_cierre)==100.0;
         if(modo_op_cierre2==NovaVela)signal=signal && newbar_cierre2;
         break;
      case EstTodos:
         if(filtro_cierre==Filtro1)
           {
            signal1=estcierre1.Main(barras_ent1)==100.0;
            if(modo_op_cierre1==NovaVela)signal1=signal1 && newbar_cierre1;
            signal2=estcierre2.Main(barras_ent2)==100.0;
            if(modo_op_cierre2==NovaVela)signal2=signal2 && newbar_cierre2;
            signal=signal1 && signal2;
           }
         else
           {
            signal1=(estcierre1.Main(barras_ent1)<=80 && estcierre1.Main(barras_ent1+1)>80 && estcierre1.Main(xvelas_2_cierre)==0.0);
            if(modo_op_cierre1==NovaVela)signal1=signal1 && newbar_cierre1;
            signal2=(estcierre2.Main(barras_ent2)<=80 && estcierre2.Main(barras_ent2+1)>80 && estcierre2.Main(xvelas_2_cierre)==0.0);
            if(modo_op_cierre2==NovaVela)signal2=signal2 && newbar_cierre2;
            signal=signal1 && signal2;
           }
         break;
     }
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::PartialBuy()
  {
   bool signal=false;
   int barras_ent1=0;
   if(modo_op_par1==NovaVela)barras_ent1=1;
   int barras_ent2=0;
   if(modo_op_par2==NovaVela)barras_ent2=1;
   bool signal1,signal2;

   switch(est_parc)
     {
      case Est1:
         if(filtro_parc==Filtro1)signal=estpar1.Main(barras_ent1)==100.0;
         else signal=estpar1.Main(barras_ent1)<=80 && estpar1.Main(barras_ent1+1)>80 && estpar1.Main(xvelas_2_parc)==100.0;
         if(modo_op_par1==NovaVela)signal=signal && newbar_par1;
         break;
      case Est2:
         if(filtro_parc==Filtro1)signal=estpar2.Main(barras_ent2)==100.0;
         else signal=estpar2.Main(barras_ent2)<=80 && estpar2.Main(barras_ent2+1)>80 && estpar2.Main(xvelas_2_parc)==100.0;
         if(modo_op_par2==NovaVela)signal=signal && newbar_par2;
         break;
      case EstTodos:
         if(filtro_parc==Filtro1)
           {
            signal1=estpar1.Main(barras_ent1)==100.0;
            if(modo_op_par1==NovaVela)signal1=signal1 && newbar_par1;
            signal2=estpar2.Main(barras_ent2)==100.0;
            if(modo_op_par2==NovaVela)signal2=signal2 && newbar_par2;
            signal=signal1 && signal2;
           }
         else
           {
            signal1=(estpar1.Main(barras_ent1)<=80 && estpar1.Main(barras_ent1+1)>80 && estpar1.Main(xvelas_2_parc)==0.0);
            if(modo_op_par1==NovaVela)signal1=signal1 && newbar_par1;
            signal2=(estpar2.Main(barras_ent2)<=80 && estpar2.Main(barras_ent2+1)>80 && estpar2.Main(xvelas_2_parc)==0.0);
            if(modo_op_par2==NovaVela)signal2=signal2 && newbar_par2;
            signal=signal1 && signal2;
           }
         break;
     }
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::CalcStop(ENUM_ORDER_TYPE order_entrada)
  {
   double sloss=0;
   if(order_entrada==ORDER_TYPE_BUY)
     {
      if(tipostop==SLPips)
         sloss=NormalizeDouble(mysymbol.Bid()-_Stop*ponto,digits);
      else sloss=NormalizeDouble(MinimaXBar(xvelas)-_xPipsStop*ponto,digits);

     }

   if(order_entrada==ORDER_TYPE_SELL)
     {
      if(tipostop==SLPips)
         sloss=NormalizeDouble(mysymbol.Ask()+_Stop*ponto,digits);
      else sloss=NormalizeDouble(MaximaXBar(xvelas)+_xPipsStop*ponto,digits);
     }

   return sloss;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::PartialClosePosType(ENUM_POSITION_TYPE ptype)
  {
   double vol_parcial;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && myposition.Symbol()==mysymbol.Name())
        {
         vol_parcial=NormalizeDouble(MathRound(perc_parc*myposition.Volume()/mysymbol.LotsStep())*mysymbol.LotsStep(),2);
         if(!mytrade.PositionClosePartial(PositionGetTicket(i),vol_parcial,deviation_points))
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTradeTransaction(const MqlTradeTransaction &trans,
                                 const MqlTradeRequest &request,
                                 const MqlTradeResult &result)
  {
   int TENTATIVAS=10;

//--- get transaction type as enumeration value

   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;

//--- if transaction is result of addition of the transaction in history
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
         deal_entry = HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
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

         if(deal_magic==Magic_Number)
           {
            GlobalVariableSet("last_deal_time",deal_time);

            if((deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL) && (deal_entry==DEAL_ENTRY_OUT || deal_entry==DEAL_ENTRY_OUT_BY))
              {
               if(deal_profit<0)
                 {
                  Print("Cierre por STOP LOSS");
                 }

               if(deal_profit>0)
                 {
                  Print("Cierre por Take Profit");
                 }
              }

            if(deal_comment=="BUY"+exp_name || deal_comment=="SELL"+exp_name)
              {
               glob_entr_tot+=1;
               if(nmaxop>0 && glob_entr_tot>=nmaxop)tradeOn=false;
              }

            //--------------------------------------------------

           }

        }
      else
         return;
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- Obtemos o número da compilação do programa 
   Print(MQL5InfoString(MQL5_PROGRAM_NAME),"--- MT5 Build #",__MQLBUILD__);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
         return(INIT_FAILED);
      //--- run application 

      ExtDialog.Run();
     }
   return MyEA.OnInit();

  }
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

   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.Destroy(reason);

//--- Código de motivo de desinicialização   
   Print(__FUNCTION__," UninitializeReason() = ",getUninitReasonText(UninitializeReason()));
   MyEA.OnDeinit(reason);

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
//|                                                                  |
//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"RESULTADO MENSAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[0].Color(clrYellow);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"RESULTADO SEMANAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[1].Color(clrYellow);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"RESULTADO DIÁRIO: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[2].Color(clrYellow);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+3*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"NUM. ENTRADAS: "+IntegerToString(MyEA.GetEntTot()),xx1,yy1,xx2,yy2))
      return(false);
   m_label[3].Color(clrYellow);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+4*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],"RIESGO: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.GetRiesgo(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[4].Color(clrYellow);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+5*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[5],"RIESGO PORC: "+DoubleToString(MyEA.GetRiesgoPorc(),4)+" %",xx1,yy1,xx2,yy2))
      return(false);
   m_label[5].Color(clrYellow);


   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+6*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[6],"R. BUY: "+DoubleToString(MyEA.GetRiesgoBuy(),4)+" %"+" "+"R. SELL: "+DoubleToString(MyEA.GetRiesgoSell(),4)+" %",xx1,yy1,xx2,yy2))
      return(false);
   m_label[6].Color(clrYellow);


   xx1=(int)(LARGURA_PAINEL-2*INDENT_RIGHT-0.5*BUTTON_WIDTH);
   yy1=INDENT_TOP+CONTROLS_GAP_Y;

   xx2 = (int)(xx1 + 0.5*BUTTON_WIDTH);
   yy2 = yy1 + BUTTON_HEIGHT;



   if(!CreateButton(m_chart_id,m_subwin,BotaoBuy,"BUY",xx1,yy1,xx2,yy2))
      return(false);
   BotaoBuy.ColorBackground(clrLime);

   xx1 = (int)(LARGURA_PAINEL-2*INDENT_RIGHT-0.5*BUTTON_WIDTH);
   yy1 = (int)(INDENT_TOP +  1.5*BUTTON_HEIGHT + 3*CONTROLS_GAP_Y);

   xx2 = (int)(xx1 + 0.5*BUTTON_WIDTH);
   yy2 = yy1 + BUTTON_HEIGHT;

   if(!CreateButton(m_chart_id,m_subwin,BotaoSell,"SELL",xx1,yy1,xx2,yy2))
      return(false);
   BotaoSell.ColorBackground(clrLime);

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyPanel::OnTick(void)
  {
   m_label[0].Text("RESULTADO MENSAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2));
   m_label[1].Text("RESULTADO SEMANAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2));
   m_label[2].Text("RESULTADO DIÁRIO: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2));
   m_label[3].Text("NUM. ENTRADAS: "+IntegerToString(MyEA.GetEntTot()));
   m_label[4].Text("RIESGO: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.GetRiesgo(),2));
   m_label[5].Text("RIESGO PORC: "+DoubleToString(MyEA.GetRiesgoPorc(),4)+" %");
   m_label[6].Text("R. BUY: "+DoubleToString(MyEA.GetRiesgoBuy(),4)+" %"+" "+"R. SELL: "+DoubleToString(MyEA.GetRiesgoSell(),4)+" %");

  }
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
ON_EVENT(ON_CLICK,BotaoBuy,OnClickBotaoBuy)
ON_EVENT(ON_CLICK,BotaoSell,OnClickBotaoSell)

EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
void OnClickBotaoBuy()
  {
   MyEA.OpenBuy();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnClickBotaoSell()
  {
   MyEA.OpenSell();
  }
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
