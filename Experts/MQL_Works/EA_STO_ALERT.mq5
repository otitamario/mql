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
   Est3,//Estocástico 3
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

CLabel            m_label[50];

CButton BotaoBuy;
CButton BotaoSell;

#define LARGURA_PAINEL 320 // Largura Painel
#define ALTURA_PAINEL 200 // Altura Painel




// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input int MAGIC_NUMBER=26032019;
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

sinput string SEst_Stoch3="############------------Estocástico 3 Entrada----------########";//Estocástico 3 Entrada
input ENUM_TIMEFRAMES period_ent3=PERIOD_CURRENT;//TIMEFRAME 
input bool ShowStocEnt3=false;//Show Escocastico Chart
input ModoOp modo_op_ent3=NovaVela;//Modo Operacion
input int                  Kperiod3=14;                 // o período K ( o número de barras para cálculo) 
input int                  Dperiod3=3;                 // o período D (o período da suavização primária) 
input int                  slowing3=3;                 // período final da suavização 
input ENUM_MA_METHOD       ma_method3=MODE_SMA;        // tipo de suavização 
input ENUM_STO_PRICE       price_field3=STO_LOWHIGH;   // método de cálculo do Estocástico 
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
   CNewBar           Bar_NovaBarraEnt3;
   double            vol_pos,vol_stp,preco_stp;
   double            sl_position,tp_position;
   double            Buyprice,Sellprice;
   CiStochastic     *estent1;
   CiStochastic     *estent2;
   CiStochastic     *estent3;
   long              chartstochent1,chartstochent2,chartstochent3;
   bool              buysignal,sellsignal,novabarra;
   bool              newbar_ent1,newbar_ent2,newbar_ent3;
   int               glob_entr_tot;
   double            riesgo,riesgo_porc,riesgo_buy,riesgo_sell;
public:
   void              MyRobot();
   void             ~MyRobot();
   int               OnInit();
   void              OnDeinit(const int reason);
   void              OnTick();
   virtual bool      GetIndValue();
   virtual bool      BuySignal();
   virtual bool      SellSignal();

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

   if(ShowStocEnt2) chartstochent3=ChartOpen(_Symbol,period_ent3);
   estent3=new CiStochastic;
   estent3.Create(Symbol(),periodoRobo,Kperiod3,Dperiod3,slowing3,ma_method3,price_field3);
   if(ShowStocEnt3) estent2.AddToChart(chartstochent3,(int)ChartGetInteger(chartstochent3,CHART_WINDOWS_TOTAL));

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



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


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
   delete(estent3);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTick(void)
  {

   mysymbol.Refresh();
   mysymbol.RefreshRates();

   estent1.Refresh();
   estent2.Refresh();
   estent3.Refresh();

   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }

   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


   novabarra=Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo);// NewBar

   newbar_ent1=Bar_NovaBarraEnt1.CheckNewBar(Symbol(),period_ent1);// NewBar
   newbar_ent2=Bar_NovaBarraEnt2.CheckNewBar(Symbol(),period_ent2);// NewBar
   newbar_ent3=Bar_NovaBarraEnt3.CheckNewBar(Symbol(),period_ent3);// NewBar


   buysignal=BuySignal();
   sellsignal=SellSignal();
   if(buysignal)
     {
     }

   if(sellsignal)
     {
     }

  }//Fim Ontick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::BuySignal()
  {
   bool signal=false;
   bool signal1,signal2,signal3;
   int barras_ent1=0;
   if(modo_op_ent1==NovaVela)barras_ent1=1;
   int barras_ent2=0;
   if(modo_op_ent2==NovaVela)barras_ent2=1;
   int barras_ent3=0;
   if(modo_op_ent3==NovaVela)barras_ent3=1;

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
      case Est3:
         if(filtro_ent==Filtro1)signal=estent3.Main(barras_ent3)==0.0;
         else signal=estent3.Main(barras_ent3)>=20 && estent3.Main(barras_ent3+1)<20 && estent3.Main(xvelas_2_ent)==0.0;
         if(modo_op_ent3==NovaVela)signal=signal && newbar_ent3;
         break;

      case EstTodos:
         if(filtro_ent==Filtro1)
           {
            signal1=estent1.Main(barras_ent1)==0.0;
            if(modo_op_ent1==NovaVela)signal1=signal1 && newbar_ent1;
            signal2=estent2.Main(barras_ent2)==0.0;
            if(modo_op_ent2==NovaVela)signal2=signal2 && newbar_ent2;
            signal3=estent3.Main(barras_ent3)==0.0;
            if(modo_op_ent3==NovaVela)signal3=signal3 && newbar_ent3;
            signal=signal1 && signal2 && signal3;
           }
         else
           {
            signal1=(estent1.Main(barras_ent1)>=20 && estent1.Main(barras_ent1+1)<20 && estent1.Main(xvelas_2_ent)==0.0);
            if(modo_op_ent1==NovaVela)signal1=signal1 && newbar_ent1;
            signal2=(estent2.Main(barras_ent2)>=20 && estent2.Main(barras_ent2+1)<20 && estent2.Main(xvelas_2_ent)==0.0);
            if(modo_op_ent2==NovaVela)signal2=signal2 && newbar_ent2;
            signal3=(estent3.Main(barras_ent3)>=20 && estent3.Main(barras_ent3+1)<20 && estent3.Main(xvelas_2_ent)==0.0);
            if(modo_op_ent3==NovaVela)signal3=signal3 && newbar_ent3;
            signal=signal1 && signal2 && signal3;
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
   int barras_ent3=0;
   if(modo_op_ent3==NovaVela)barras_ent3=1;

   bool signal1,signal2,signal3;

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

      case Est3:
         if(filtro_ent==Filtro1)signal=estent3.Main(barras_ent3)==100.0;
         else signal=estent3.Main(barras_ent3)<=80 && estent3.Main(barras_ent3+1)>80 && estent3.Main(xvelas_2_ent)==100.0;
         if(modo_op_ent3==NovaVela)signal=signal && newbar_ent3;
         break;

      case EstTodos:
         if(filtro_ent==Filtro1)
           {
            signal1=estent1.Main(barras_ent1)==100.0;
            if(modo_op_ent1==NovaVela)signal1=signal1 && newbar_ent1;
            signal2=estent2.Main(barras_ent2)==100.0;
            if(modo_op_ent2==NovaVela)signal2=signal2 && newbar_ent2;
            signal3=estent3.Main(barras_ent3)==100.0;
            if(modo_op_ent3==NovaVela)signal3=signal3 && newbar_ent3;
            signal=signal1 && signal2 && signal3;
           }
         else
           {
            signal1=(estent1.Main(barras_ent1)<=80 && estent1.Main(barras_ent1+1)>80 && estent1.Main(xvelas_2_ent)==0.0);
            if(modo_op_ent1==NovaVela)signal1=signal1 && newbar_ent1;
            signal2=(estent2.Main(barras_ent2)<=80 && estent2.Main(barras_ent2+1)>80 && estent2.Main(xvelas_2_ent)==0.0);
            if(modo_op_ent2==NovaVela)signal2=signal2 && newbar_ent2;
            signal3=(estent3.Main(barras_ent3)<=80 && estent3.Main(barras_ent3+1)>80 && estent3.Main(xvelas_2_ent)==0.0);
            if(modo_op_ent3==NovaVela)signal2=signal3 && newbar_ent3;

            signal=signal1 && signal2 && signal3;

           }
         break;
     }
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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

//--- Código de motivo de desinicialização   
   Print(__FUNCTION__," UninitializeReason() = ",getUninitReasonText(UninitializeReason()));
   MyEA.OnDeinit(reason);

  }
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
