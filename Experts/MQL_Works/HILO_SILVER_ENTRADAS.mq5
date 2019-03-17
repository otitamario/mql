//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
enum Usar_Indic
  {
   Nao=0,
   Sim=1
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Sentido
  {
   Compra,
   Venda,
   Compra_e_Venda
  };

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>

#define TENTATIVAS 10 // Tentativas envio ordem


//Classes
CNewBar NewBar;
CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
CTimer Timer;
CiMA *ema;
CiMA *ma1;
CiMA *ma2;
CiMA *ma3;
CiMomentum *momentum;
CiADX *adx;

// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=26062018;
input Sentido operar=Compra_e_Venda;//Modo de Operação
input double Lot=1;//Lote Entrada
input double _Stop=150;//Stop Loss em Pontos
input double _TakeProfit=1000; //Take Profit em Pontos

sinput string STrailing="############---------------Trailing Stop----------########";//Trailing

input bool   Use_TraillingStop=true; //Usar Trailing Stop True/False
input int TraillingStart=0;//Lucro Minimo ativar trailing stop
input int TraillingDistance=100;// Distancia do Stop loss para o preço
input int TraillingStep=10;// Passo Para atualizar o Stop Loss

sinput string sbreak="########---------Break Even---------------###############";//Break Even
input    bool              UseBreakEven=false;                          //Usar BreakEven
input    int               BreakEvenPoint1         =100;                            //Pontos para BreakEven 1
input    int               ProfitPoint1            =80;                             //Pontos de Lucro da Posicao 1
input    int               BreakEvenPoint2         =200;                            //Pontos para BreakEven 2
input    int               ProfitPoint2            =150;                            //Pontos de Lucro da Posicao 2
input    int               BreakEvenPoint3         =300;                            //Pontos para BreakEven 3
input    int               ProfitPoint3            =250;                            //Pontos de Lucro da Posicao 3
input    int               BreakEvenPoint4         =500;                            //Pontos para BreakEven 4
input    int               ProfitPoint4            =400;                            //Pontos de Lucro da Posicao 4
input    int               BreakEvenPoint5         =700;                            //Pontos para BreakEven 5
input    int               ProfitPoint5            =550;                            //Pontos de Lucro da Posicao 5




sinput string Lucro="Lucro para fechamento";
input bool UsarLucro=true;
input double lucro=1000.0;//Lucro para Fechamento de Posições/Operações
input double prejuizo=500.0;//Prejuízo para Fechamento de Posições/Operações

sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário

input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:00";//Horario Inicial
input string end_hour="17:30";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario

input bool UsePause1=false;//Usar Pausa 1
input string start_hour1="8:30";//Initial Pause Hour 1
input string end_hour1="10:30";//Final Pause Hour 1
input bool UsePause2=false;//Usar Pausa 2
input string start_hour2="18:00";//Initial Pause Hour 2
input string end_hour2="20:30";//Final Pause Hour 2
input bool UsePause3=false;//Usar Pausa 3
input string start_hour3="23:00";//Initial Pause Hour 3
input string end_hour3="03:00";//Final Pause Hour 3
sinput string hora_limit_ent="-----------------------";//HORARIO LIMITE PARA ENTRADAS
input string end_hour_entry="17:00";//Hora Limite Entradas

sinput string sdias="FILTRO DOS DIAS DA SEMANA";//Dias da Semana
input bool trade0=true;// Operar Domingo
input bool trade1=true;// Operar Segunda
input bool trade2=true;// Operar Terça
input bool trade3=true;// Operar Quarta
input bool trade4=true;// Operar Quinta
input bool trade5=true;// Operar Sexta
input bool trade6=true;// Operar Sábado




sinput string sindic="############------Indicadores------#################";//Indicadores
sinput string shilo="############------HiLo------#################";//HiLo
input int period_hilo=14;//Periodo HiLo
input ENUM_MA_METHOD InpMethod=MODE_SMMA;// Method Hilo
sinput string smedias="############------Medias------#################";//Médias
input bool Use_MA1=true;//Usar Media Rapida
input int period_ma1=9;//Periodo Media Rapida
input ENUM_MA_METHOD mode_ma1=MODE_EMA;//Modo Media Rapida
input bool Use_MA2=true;//Usar Media Intermediaria
input int period_ma2=20;//Periodo Media Intermediaria
input ENUM_MA_METHOD mode_ma2=MODE_EMA;//Modo Media Intermediaria
input bool Use_MA3=true;//Usar Media Lenta
input int period_ma3=60;//Periodo Media Lenta
input ENUM_MA_METHOD mode_ma3=MODE_EMA;//Modo Media Lenta
sinput string sadx="############------ADX------#################";//ADX
input int period_adx=21;//ADX Period
input double valor_adx=25.0;// Valor Limite ADX Main
input double valor_adx_plus=25.0;// Valor Limite ADX Plus(DI+)
input double valor_adx_minus=25.0;// Valor Limite ADX Minus(DI-)
input double dif_adx=0.5;//Valor minimo Diferenca adx crescente
input double dif_adx_plus=0.5;//Valor minimo Diferenca adx Plus crescente
input double dif_adx_minus=0.5;//Valor minimo Diferenca adx Minus crescente
input double dif_adx_dec=-0.5;//Valor Limite Diferenca adx Decrescente
input double dif_adx_plus_dec=-0.5;//Valor Limite Diferenca adx Plus Decrescente
input double dif_adx_minus_dec=-0.5;//Valor Limite Diferenca adx Minus Decrescente

sinput string ssilver="############------Silver Trend------#################";//Siver Trend
input int RISK=3;
input int NumberofAlerts=0;
sinput string smoment="############------Momentum------#################";//Momentum
input int period_mom=14;//Periodo Momentum
input double valor_compra_mom=100.2;//Valor Limite Compra
input double valor_venda_mom=99.8;//Valor Limite Venda
sinput string satrstop="############------ATR_STOP------#################";//ATR STOP
input uint   Length=10;           // Indicator period
input uint   ATRPeriod=5;         // Period of ATR
input double Kv=2.5;              // Volatility by ATR
input int    Shift=0;             // Horizontal shift of the indicator in bars

sinput string sindent="############------Indicadores Entrada------#################";//Indicadores Entrada
input Usar_Indic entr_hilo=Sim;// Usar HiLo Entrada 
input Usar_Indic entr_medias=Sim;// Usar Medias Entrada
input Usar_Indic entr_adx=Sim;// Usar ADX Entrada 
input Usar_Indic entr_silver=Sim;// Usar Silver Entrada
input Usar_Indic entr_moment=Sim;// Usar Momentum Entrada
input Usar_Indic entr_atr=Sim;// Usar ATR_STOP Entrada 

sinput string sindsaida="############------Indicadores Saida------#################";//Indicadores Saída
input Usar_Indic saida_hilo=Sim;// Usar HiLo Saída 
input Usar_Indic saida_medias=Sim;// Usar Medias Saída
input Usar_Indic saida_adx=Sim;// Usar ADX Saída 
input Usar_Indic saida_silver=Sim;// Usar Silver Saída
input Usar_Indic saida_moment=Sim;// Usar Momentum Saída
input Usar_Indic saida_atr=Sim;// Usar ATR_STOP Saída 

sinput string sindplot="############------Plotar Indicadores------#################";//Plotar 
input Usar_Indic plot_hilo=Sim;// Usar HiLo Saída 
input Usar_Indic plot_medias=Sim;// Usar Medias Saída
input Usar_Indic plot_adx=Sim;// Usar ADX Saída 
input Usar_Indic plot_silver=Sim;// Usar Silver Saída
input Usar_Indic plot_moment=Sim;// Usar Momentum Saída
input Usar_Indic plot_atr=Sim;// Usar ATR_STOP Saída 

sinput string ssaidas="########-------Saídas Parciais--------------#############";//Saídas
input double saida1=40;//Pontos Saída Parcial 1 (0 Não usar)
input double vol_saida1=1;//Lotes Saída Parcial 1
input double saida2=60;//Pontos Saída Parcial 2 (0 Não usar)
input double vol_saida2=1;//Lotes Saída Parcial 2
input double saida3=80;//Pontos Saída Parcial 3 (0 Não usar)
input double vol_saida3=1;//Lotes Saída Parcial 3
input double saida4=100;//Pontos Saída Parcial 4 (0 Não usar)
input double vol_saida4=1;//Lotes Saída Parcial 4
input double saida5=200;//Pontos Saída Parcial 5 (0 Não usar)
input double vol_saida5=1;//Lotes Saída Parcial 5

sinput string Spontos_aumento="############-----------Pontos Aumento de Posição----------########";//Entradas
input double pt_aum1=20;//Pontos Aumento de Posição 1 (0 Não usar)
input double pt_aum2=40;//Pontos Aumento de Posição 2 (0 Não usar)
input double pt_aum3=70;//Pontos Aumento de Posição 3 (0 Não usar)
input double pt_aum4=100;//Pontos Aumento de Posição 4 (0 Não usar)
input double pt_aum5=0;//Pontos Aumento de Posição 5 (0 Não usar)
input double pt_aum6=0;//Pontos Aumento de Posição 6 (0 Não usar)

sinput string Slotes_aumento="############-----------Lotes Aumento de Posição----------########";//Pontos Entrada
input double lote_aum1=1.0;//Lotes Aumento de Posição 1 (0 Não usar)
input double lote_aum2=1.0;//Lotes Aumento de Posição 2 (0 Não usar)
input double lote_aum3=2.0;//Lotes Aumento de Posição 3 (0 Não usar)
input double lote_aum4=2.0;//Lotes Aumento de Posição 4 (0 Não usar)
input double lote_aum5=4.0;//Lotes Aumento de Posição 5 (0 Não usar)
input double lote_aum6=4.0;//Lotes Aumento de Posição 6 (0 Não usar)


                           //Variaveis 
string original_symbol;
double ask,bid;
double lucro_total;
bool tradeOn,timerOn,timerPaus,timerEnt;
double ponto,ticksize,digits;
long curChartID;
//Indicadores
int atr_handle;
double ATR_High[],ATR_Low[];
int hilo_handle,silver_handle,silver_htf_handle;
double hilo_color[],hilo_buffer[],SilverSell[],SilverBuy[];
double high[],low[],open[],close[];
//---------------------------------------
ulong ENTRADAS_TOTAL;

ulong trade_ticket,compra1_ticket,venda1_ticket,stp_venda_ticket,stp_compra_ticket;
ulong tkp_compra1_ticket,tkp_compra2_ticket,tkp_compra3_ticket,tkp_compra4_ticket,tkp_compra5_ticket;
ulong tkp_venda1_ticket,tkp_venda2_ticket,tkp_venda3_ticket,tkp_venda4_ticket,tkp_venda5_ticket;
string glob_entr_tot="ENT_TOT"+Symbol()+IntegerToString(Magic_Number);
string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string stp_vd_tick="stp_vd_tick"+Symbol()+IntegerToString(Magic_Number),stp_cp_tick="stp_cp_tick"+Symbol()+IntegerToString(Magic_Number);
string stop_price="stop_price"+Symbol()+IntegerToString(Magic_Number);

ulong nsubwindows,nchart_adx;
double buyprice,sellprice,oldprice;
string informacoes;
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME)+"_"+Symbol();
int PrevPositions;
double deviation_points=100.0;
double   PointBreakEven[5],PointProfit[5];
double vol_pos,vol_stp,preco_stp;
datetime hora_inicial,hora_final;
datetime hora_inicial1,hora_final1,hora_inicial2,hora_final2,hora_inicial3,hora_final3,hora_final_entradas;
bool timer1,timer2,timer3;
double open_price;
ENUM_ORDER_TYPE_TIME order_time_type;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   original_symbol=Symbol();
   if(SymbolInfoInteger(original_symbol,SYMBOL_EXPIRATION_MODE)==2)order_time_type=1;
   else order_time_type=0;

   tradeOn=true;
   trade_ticket=0;
   ENTRADAS_TOTAL=0;
   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.SetDeviationInPoints(deviation_points);
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
   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);
   lucro_total=0.0;
   int find_wdo=StringFind(original_symbol,"WDO");
   int find_dol=StringFind(original_symbol,"DOL");
   if(find_dol>=0|| find_wdo>=0)ponto=1.0;

//-------------------------------INDICADORES------------------------------------------
   curChartID=ChartID();

   ma1=new CiMA;
   ma1.Create(NULL,periodoRobo,period_ma1,0,mode_ma1,PRICE_CLOSE);
   if(plot_medias && Use_MA1) ma1.AddToChart(curChartID,0);
   ma2=new CiMA;
   ma2.Create(NULL,periodoRobo,period_ma2,0,mode_ma2,PRICE_CLOSE);
   if(plot_medias && Use_MA2) ma2.AddToChart(curChartID,0);
   ma3=new CiMA;
   ma3.Create(NULL,periodoRobo,period_ma3,0,mode_ma3,PRICE_CLOSE);
   if(plot_medias && Use_MA3) ma3.AddToChart(curChartID,0);

   nsubwindows=ChartGetInteger(curChartID,CHART_WINDOWS_TOTAL);
   nchart_adx=nsubwindows;
   adx=new CiADX;
   adx.Create(NULL,periodoRobo,period_adx);
   if(plot_adx==Sim) adx.AddToChart(curChartID,ChartGetInteger(curChartID,CHART_WINDOWS_TOTAL));
   momentum=new CiMomentum;
   momentum.Create(NULL,periodoRobo,period_mom,PRICE_CLOSE);
   if(plot_moment==Sim)momentum.AddToChart(curChartID,ChartGetInteger(curChartID,CHART_WINDOWS_TOTAL));
   hilo_handle=iCustom(NULL,periodoRobo,"gann_hi_lo_activator_ssl",period_hilo,InpMethod);
   if(plot_hilo==Sim)ChartIndicatorAdd(ChartID(),0,hilo_handle);

   silver_handle=iCustom(NULL,periodoRobo,"silvertrend_signal",RISK,NumberofAlerts);
   if(plot_silver==Sim)ChartIndicatorAdd(ChartID(),0,silver_handle);
   atr_handle=iCustom(Symbol(),periodoRobo,"atrstops_v1",Length,ATRPeriod,Kv,Shift);
   if(plot_atr==Sim)ChartIndicatorAdd(ChartID(),0,atr_handle);

//-------------------------------FIM INDICADORES------------------------------------------

   ArraySetAsSeries(hilo_color,true);
   ArraySetAsSeries(hilo_buffer,true);
   ArraySetAsSeries(SilverBuy,true);
   ArraySetAsSeries(SilverSell,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

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
         return(INIT_PARAMETERS_INCORRECT);

        }

     }

   if(_Stop<=pt_aum1 || _Stop<=pt_aum2 || _Stop<=pt_aum3 || _Stop<=pt_aum4 || _Stop<=pt_aum5 || _Stop<=pt_aum6)

     {
      string erro="O Stop Máximo deve ser maior que todos pontos de aumento entrada ";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);

     }

   for(int i=0;i<4;i++)
     {
      if(PointBreakEven[i+1]<=PointBreakEven[i])
        {
         string erro="Pontos de Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);

        }

     }

   for(int i=0;i<4;i++)
     {
      if(PointProfit[i+1]<=PointProfit[i])
        {
         string erro="Pontos de Profit do Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);

        }

     }

   if(Lot<=0)
     {
      string erro="Lote deve ser maior que 0";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);

     }
   if(period_ma1>=period_ma2 || period_ma1>=period_ma3 || period_ma2>=period_ma3)
     {
      string erro="Periodo das Medias errado: Rapida<Intermediaria<Lenta";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);

     }

   if((saida1/MathMax(saida1,0.00000001))*vol_saida1+(saida2/MathMax(saida2,0.00000001))*vol_saida2+(saida3/MathMax(saida3,0.00000001))*vol_saida3+(saida4/MathMax(saida4,0.00000001))*vol_saida4+(saida5/MathMax(saida5,0.00000001))*vol_saida5>Lot)
     {
      string erro="Total de Lotes saída Parcial deve ser menor que Lote de entrada";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);

     }

   if(!GlobalVariableCheck(glob_entr_tot))GlobalVariableSet(glob_entr_tot,0.0);
   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0.0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0.0);
   if(!GlobalVariableCheck(stp_vd_tick))GlobalVariableSet(stp_vd_tick,0);
   if(!GlobalVariableCheck(stp_cp_tick))GlobalVariableSet(stp_cp_tick,0);

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   hora_inicial1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour1);
   hora_final1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour1);
   hora_inicial2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour2);
   hora_final2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour2);
   hora_inicial3=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour3);
   hora_final3=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour3);
   hora_final_entradas=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_entry);

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeletaIndicadores();

   delete(ma1);
   delete(ma2);
   delete(ma3);
   delete(momentum);
   delete(adx);
   IndicatorRelease(hilo_handle);
   IndicatorRelease(silver_handle);
   IndicatorRelease(atr_handle);
   Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");

//---

  }
//+------------------------------------------------------------------+ 
//| TradeTransaction function                                        | 
//+------------------------------------------------------------------+ 
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {

//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history

   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      ulong order_ticket=trans.order;

      if(order_ticket==trade_ticket && trans.deal_type!=DEAL_TYPE_BALANCE)
        {
         ENTRADAS_TOTAL++;
         GlobalVariableSet(glob_entr_tot,(double)ENTRADAS_TOTAL);
        }

      if(StringSubstr(mydeal.Comment(),0,2)=="sl" || StringSubstr(mydeal.Comment(),0,2)=="tp")
        {
         DeleteOrders(ORDER_TYPE_SELL_STOP);
         DeleteOrders(ORDER_TYPE_BUY_STOP);
         informacoes="Posicao Fechada por "+StringSubstr(mydeal.Comment(),0,2)=="sl"?"Stop Loss":"Take Profit";
         Print(informacoes);
        }

     }//End TRANSACTIONS DEAL ADD
   if(type==TRADE_TRANSACTION_HISTORY_ADD)
     {

      ulong order_ticket=trans.order;
      myorder.SelectByIndex(order_ticket);
      mydeal.SelectByIndex(trans.deal);
      myposition.SelectByTicket(trans.position);

      if(order_ticket==compra1_ticket && trans.order_state==ORDER_STATE_FILLED)
        {

         //Stop para posição comprada
         int cont=0;
         open_price=0;
         while(open_price==0 && cont<TENTATIVAS)
           {
            open_price=myposition.PriceOpen();
            cont+=1;
           }
         if(open_price==0)open_price=mysymbol.Ask();

         sellprice=NormalizeDouble(open_price-_Stop*ponto,digits);
         oldprice=PriceLastStopOrder(ORDER_TYPE_SELL_STOP);
         if(oldprice==-1 || sellprice>oldprice && Buy_opened()) // No order or New price is better
           {
            DeleteOrders(ORDER_TYPE_SELL_STOP);
            mytrade.SellStop(Lot,sellprice,Symbol(),0,0,order_time_type,0,"STOP"+exp_name);
            stp_venda_ticket=mytrade.ResultOrder();
            GlobalVariableSet(stp_vd_tick,(double)stp_venda_ticket);
            GlobalVariableSet(stop_price,sellprice);
           }

         Aumento_Buy(open_price);
         // Saidas Parciais
         Saida_Sell(open_price);

         HLineCreate(0,"Entrada",0,open_price,clrAqua,STYLE_DASH,1,false,false,true,0);
         HLineCreate(0,"Take Profit",0,myposition.TakeProfit(),clrLime,STYLE_DASH,1,false,false,true,0);
         HLineCreate(0,"Stop Loss",0,sellprice,clrRed,STYLE_DASH,1,false,false,true,0);

         if(UseBreakEven)
           {
            HLineCreate(0,"BE1",0,NormalizeDouble(open_price+BreakEvenPoint1*ponto,digits),clrBlueViolet,STYLE_DASHDOTDOT,1,false,false,true,0);
            HLineCreate(0,"BE2",0,NormalizeDouble(open_price+BreakEvenPoint2*ponto,digits),clrBlueViolet,STYLE_DASHDOTDOT,1,false,false,true,0);
            HLineCreate(0,"BE3",0,NormalizeDouble(open_price+BreakEvenPoint3*ponto,digits),clrBlueViolet,STYLE_DASHDOTDOT,1,false,false,true,0);
            HLineCreate(0,"BE4",0,NormalizeDouble(open_price+BreakEvenPoint4*ponto,digits),clrBlueViolet,STYLE_DASHDOTDOT,1,false,false,true,0);
            HLineCreate(0,"BE5",0,NormalizeDouble(open_price+BreakEvenPoint5*ponto,digits),clrBlueViolet,STYLE_DASHDOTDOT,1,false,false,true,0);
           }

        }

      //--------------------------------------------------
      if(order_ticket==stp_venda_ticket && trans.order_type==ORDER_TYPE_SELL_STOP && trans.order_state==ORDER_STATE_FILLED)
        {
         informacoes="Posicao Fechada por Ordem Sell Stop";
         DeleteOrders(ORDER_TYPE_SELL_LIMIT);
         Print(informacoes);
         if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) mytrade.PositionCloseBy(compra1_ticket,stp_venda_ticket);

        }

      if(order_ticket==tkp_compra1_ticket && trans.order_state==ORDER_STATE_FILLED && myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
         mytrade.PositionCloseBy(compra1_ticket,tkp_compra1_ticket);
      if(order_ticket==tkp_compra2_ticket && trans.order_state==ORDER_STATE_FILLED && myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
         mytrade.PositionCloseBy(compra1_ticket,tkp_compra2_ticket);
      if(order_ticket==tkp_compra3_ticket && trans.order_state==ORDER_STATE_FILLED && myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
         mytrade.PositionCloseBy(compra1_ticket,tkp_compra3_ticket);
      if(order_ticket==tkp_compra4_ticket && trans.order_state==ORDER_STATE_FILLED && myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
         mytrade.PositionCloseBy(compra1_ticket,tkp_compra4_ticket);
      if(order_ticket==tkp_compra5_ticket && trans.order_state==ORDER_STATE_FILLED && myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
         mytrade.PositionCloseBy(compra1_ticket,tkp_compra5_ticket);

      if(order_ticket==venda1_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         //Stop para posição vendida
         int cont=0;
         open_price=0;
         while(open_price==0 && cont<TENTATIVAS)
           {
            open_price=myposition.PriceOpen();
            cont+=1;
           }
         if(open_price==0)open_price=mysymbol.Bid();

         buyprice=NormalizeDouble(open_price+_Stop*ponto,digits);
         oldprice=PriceLastStopOrder(ORDER_TYPE_BUY_STOP);
         if(oldprice==-1 || buyprice<oldprice && Sell_opened()) // No order or New price is better
           {
            DeleteOrders(ORDER_TYPE_BUY_STOP);
            mytrade.BuyStop(Lot,buyprice,Symbol(),0,0,order_time_type,0,"STOP"+exp_name);
            stp_compra_ticket=mytrade.ResultOrder();
            GlobalVariableSet(stp_cp_tick,(double)stp_compra_ticket);
            GlobalVariableSet(stop_price,buyprice);
           }
         Aumento_Sell(open_price);
         Saida_Buy(open_price);
         HLineCreate(0,"Entrada",0,open_price,clrAqua,STYLE_DASH,1,false,false,true,0);
         HLineCreate(0,"Take Profit",0,myposition.TakeProfit(),clrLime,STYLE_DASH,1,false,false,true,0);
         HLineCreate(0,"Stop Loss",0,buyprice,clrRed,STYLE_DASH,1,false,false,true,0);

         if(UseBreakEven)
           {
            HLineCreate(0,"BE1",0,NormalizeDouble(open_price-BreakEvenPoint1*ponto,digits),clrBlueViolet,STYLE_DASHDOTDOT,1,false,false,true,0);
            HLineCreate(0,"BE2",0,NormalizeDouble(open_price-BreakEvenPoint2*ponto,digits),clrBlueViolet,STYLE_DASHDOTDOT,1,false,false,true,0);
            HLineCreate(0,"BE3",0,NormalizeDouble(open_price-BreakEvenPoint3*ponto,digits),clrBlueViolet,STYLE_DASHDOTDOT,1,false,false,true,0);
            HLineCreate(0,"BE4",0,NormalizeDouble(open_price-BreakEvenPoint4*ponto,digits),clrBlueViolet,STYLE_DASHDOTDOT,1,false,false,true,0);
            HLineCreate(0,"BE5",0,NormalizeDouble(open_price-BreakEvenPoint5*ponto,digits),clrBlueViolet,STYLE_DASHDOTDOT,1,false,false,true,0);
           }

        }
      //--------------------------------------------------
      if(order_ticket==stp_compra_ticket && trans.order_type==ORDER_TYPE_BUY_STOP && trans.order_state==ORDER_STATE_FILLED)
        {
         informacoes="Posicao Fechada por Ordem Buy Stop";
         DeleteOrders(ORDER_TYPE_BUY_LIMIT);
         Print(informacoes);
         if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) mytrade.PositionCloseBy(venda1_ticket,stp_compra_ticket);

        }

      if(order_ticket==tkp_venda1_ticket && trans.order_state==ORDER_STATE_FILLED && myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
         mytrade.PositionCloseBy(venda1_ticket,tkp_venda1_ticket);
      if(order_ticket==tkp_venda2_ticket && trans.order_state==ORDER_STATE_FILLED && myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
         mytrade.PositionCloseBy(venda1_ticket,tkp_venda2_ticket);
      if(order_ticket==tkp_venda3_ticket && trans.order_state==ORDER_STATE_FILLED && myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
         mytrade.PositionCloseBy(venda1_ticket,tkp_venda3_ticket);
      if(order_ticket==tkp_venda4_ticket && trans.order_state==ORDER_STATE_FILLED && myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
         mytrade.PositionCloseBy(venda1_ticket,tkp_venda4_ticket);
      if(order_ticket==tkp_venda5_ticket && trans.order_state==ORDER_STATE_FILLED && myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
         mytrade.PositionCloseBy(venda1_ticket,tkp_venda5_ticket);

     }//End TRANSACTIONS HISTORY ADD

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   Main_Program();

  }// fim OnTick
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//------------------------------------------------------------------------
//------------------------------------------------------------------------


//+-------------ROTINAS----------------------------------------------+

void Main_Program()
  {

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   ma1.Refresh();
   ma2.Refresh();
   ma3.Refresh();
   momentum.Refresh();
   adx.Refresh();
   ProtectPosition();
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   hora_inicial1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour1);
   hora_final1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour1);

   hora_inicial2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour2);
   hora_final2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour2);

   hora_inicial3=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour3);
   hora_final3=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour3);
   hora_final_entradas=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_entry);

   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

   bool novodia;
   novodia=NewBar.CheckNewBar(Symbol(),PERIOD_D1);
   if(novodia)
     {
      GlobalVariableSet(glob_entr_tot,0);
      tradeOn=true;
      Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");
      informacoes="";
     }

   lucro_total=LucroOrdens()+LucroPositions();
   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
     }

   timerOn=true;
   timerEnt=true;

   if(UseTimer)
     {
      timer1=UsePause1&&TimeCurrent()>=hora_inicial1 && TimeCurrent()<=hora_final1;
      timer2=UsePause2&&TimeCurrent()>=hora_inicial2 && TimeCurrent()<=hora_final2;
      timer3=UsePause3&&TimeCurrent()>=hora_inicial3 && TimeCurrent()<=hora_final3;
      timerPaus=!timer1 && !timer2 && !timer3;
      timerOn=timerPaus && TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
      timerEnt=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final_entradas && TimeDayFilter();

     }

   if(timerOn==false)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
     }

//Atualizacao das Cotacoes----ticks
   MqlTick last_tick;
   if(SymbolInfoTick(Symbol(),last_tick))
     {
      bid= last_tick.bid;
      ask=last_tick.ask;
     }
   else
     {
      Print("Falhou obter o tick");
      return;
     }
   double spread=ask-bid;
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }
   ENTRADAS_TOTAL=(int)GlobalVariableGet(glob_entr_tot);
   compra1_ticket=(int) GlobalVariableGet(cp_tick);
   venda1_ticket=(int) GlobalVariableGet(vd_tick);
   stp_compra_ticket=(int) GlobalVariableGet(stp_cp_tick);
   stp_venda_ticket=(int) GlobalVariableGet(stp_vd_tick);

//----------------------------------------------------------------------------

//------------------------------------------------------------------------------
   if(!PosicaoAberta())
     {
      HLineDelete(0,"Entrada");
      HLineDelete(0,"Stop Loss");
      HLineDelete(0,"Take Profit");
      HLineDelete(0,"BE1");
      HLineDelete(0,"BE2");
      HLineDelete(0,"BE3");
      HLineDelete(0,"BE4");
      HLineDelete(0,"BE5");
     }
   if(tradeOn && timerOn)//Begin Trade On
     {

      if(!PosicaoAberta() && OrdersTotal()>0)DeleteALL();
      if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened())CloseByPosition();
      if(PosicaoAberta()) Atual_vol_Stop();

      if(NewBar.CheckNewBar(Symbol(),periodoRobo))
        {
         if(CheckSellClose() && Sell_opened())ClosePosType(POSITION_TYPE_SELL);
         if(CheckBuyClose() && Buy_opened())ClosePosType(POSITION_TYPE_BUY);
         if(timerEnt)
           {

            if(BuySignal() && !PosicaoAberta() && operar!=Venda)
              {
               if(PositionsTotal()>0)CloseALL();
               if(OrdersTotal()>0)DeleteALL();
               mytrade.Buy(Lot,Symbol(),0,0,NormalizeDouble(ask+_TakeProfit*ponto,digits),"BUY"+exp_name);
               trade_ticket=mytrade.ResultOrder();
               compra1_ticket=trade_ticket;
               GlobalVariableSet(cp_tick,(double)compra1_ticket);
              }

            if(SellSignal() && !PosicaoAberta() && operar!=Compra)
              {
               if(PositionsTotal()>0)CloseALL();
               if(OrdersTotal()>0)DeleteALL();
               mytrade.Sell(Lot,Symbol(),0,0,NormalizeDouble(bid-_TakeProfit*ponto,digits),"SELL"+exp_name);
               trade_ticket=mytrade.ResultOrder();
               venda1_ticket=trade_ticket;
               GlobalVariableSet(vd_tick,(double)venda1_ticket);
              }
           }//Fim Time Entradas

        }//Fim NewBar

      // Trailing stop

      if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);
      //BrakeEven
      if(UseBreakEven && PosicaoAberta())BreakEven(original_symbol,UseBreakEven,PointBreakEven,PointProfit);                       //chng_V02: _Symbol For Base Symbol

     }//End Trade On

  }
//+------------------------------------------------------------------+
//| Buy conditions                                                   |
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int SilverSignal()
  {
   int signal;
   signal=0;
   if(SilverBuy[1]>0)signal=1;
   if(SilverSell[1]>0)signal=-1;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ATRSignal()
  {
   int signal;
   signal=0;
   if(close[1]>ATR_High[1])signal=1;
   if(close[1]<ATR_Low[1])signal=-1;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int HiloSignal()
  {
   int signal;
   signal=0;
   if(hilo_color[1]==0.0 && hilo_color[2]==1.0)signal=1;
   if(hilo_color[1]==1.0 && hilo_color[2]==0.0)signal=-1;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ADXSignal()
  {
   int signal;
   signal=0;
   bool b1,b2,b3,b4,s1,s2,s3,s4;
   b1=adx.Main(1)>valor_adx  &&  adx.Plus(1)>valor_adx_plus;
   b2=adx.Main(0)-adx.Main(1)>dif_adx;
   b3=adx.Plus(0)-adx.Plus(1)>dif_adx_plus;
   b4=adx.Minus(0)-adx.Minus(1)>dif_adx_minus;
   s1=adx.Main(1)>valor_adx && adx.Minus(1)>valor_adx_minus;
   s2=adx.Main(0)-adx.Main(1)<dif_adx_dec;
   s3=adx.Plus(0)-adx.Plus(1)<dif_adx_plus_dec;
   s4=adx.Minus(0)-adx.Minus(1)<dif_adx_minus_dec;
   if(b1&&b2&&b3&&b4)signal=1;
   if(s1&&s2&&s3&&s4)signal=-1;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MomentumSignal()
  {
   int signal;
   signal=0;
   if(momentum.Main(1)>valor_compra_mom)signal=1;
   if(momentum.Main(1)<valor_compra_mom)signal=-1;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MediasSignal()
  {
   bool cross3_up,cross3_down,cross2_up,cross2_down;
   int signal;
   signal=0;
   if(Use_MA1 && Use_MA2 && Use_MA3)
     {
      cross3_up=(ma1.Main(2)<ma2.Main(2) && ma1.Main(1)>ma2.Main(1)) && (ma2.Main(2)<ma3.Main(2) && ma2.Main(1)>ma3.Main(1));
      cross3_down=(ma1.Main(2)>ma2.Main(2) && ma1.Main(1)<ma2.Main(1)) && (ma2.Main(2)>ma3.Main(2) && ma2.Main(1)<ma3.Main(1));
      if(cross3_up)signal=1;
      if(cross3_down)signal=-1;
     }
   else if(Use_MA1 && Use_MA2 && !Use_MA3)
     {
      cross2_up=(ma1.Main(2)<ma2.Main(2) && ma1.Main(1)>ma2.Main(1));
      cross2_down=(ma1.Main(2)>ma2.Main(2) && ma1.Main(1)<ma2.Main(1));
      if(cross2_up)signal=1;
      if(cross2_down)signal=-1;
     }
   else if(Use_MA1 && Use_MA3 && !Use_MA2)
     {
      cross2_up=(ma1.Main(2)<ma3.Main(2) && ma1.Main(1)>ma3.Main(1));
      cross2_down=(ma1.Main(2)>ma3.Main(2) && ma1.Main(1)<ma3.Main(1));
      if(cross2_up)signal=1;
      if(cross2_down)signal=-1;
     }
   else if(Use_MA2 && Use_MA3 && !Use_MA1)
     {
      cross2_up=(ma2.Main(2)<ma3.Main(2) && ma2.Main(1)>ma3.Main(1));
      cross2_down=(ma2.Main(2)>ma3.Main(2) && ma2.Main(1)<ma3.Main(1));
      if(cross2_up)signal=1;
      if(cross2_down)signal=-1;
     }
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   bool signal;
   int valor=entr_hilo+entr_medias+entr_adx+entr_silver+entr_moment+entr_atr;
   int soma=0;
   if(entr_hilo==1)soma+=HiloSignal();
   if(entr_medias==1)soma+=MediasSignal();
   if(entr_adx==1)soma+=ADXSignal();
   if(entr_silver==1)soma+=SilverSignal();
   if(entr_moment==1)soma+=MomentumSignal();
   if(entr_atr==1)soma+=ATRSignal();

   if(soma==valor)signal=true;
   else signal=false;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   bool signal;
   int valor=entr_hilo+entr_medias+entr_adx+entr_silver+entr_moment+entr_atr;
   int soma=0;
   if(entr_hilo==1)soma+=HiloSignal();
   if(entr_medias==1)soma+=MediasSignal();
   if(entr_adx==1)soma+=ADXSignal();
   if(entr_silver==1)soma+=SilverSignal();
   if(entr_moment==1)soma+=MomentumSignal();
   if(entr_atr==1)soma+=ATRSignal();
   if(soma==-valor)signal=true;
   else signal=false;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckSellClose()
  {
   bool signal;
   int valor=saida_hilo+saida_medias+saida_adx+saida_silver+saida_moment+saida_atr;
   int soma=0;
   if(saida_hilo==1)soma+=HiloSignal();
   if(saida_medias==1)soma+=MediasSignal();
   if(saida_adx==1)soma+=ADXSignal();
   if(saida_silver==1)soma+=SilverSignal();
   if(saida_moment==1)soma+=MomentumSignal();
   if(saida_atr==1)soma+=ATRSignal();

   if(soma>0 && soma==valor)signal=true;
   else signal=false;
   return signal;
  }
//+------------------------------------------------------------------+
//| Buy Close conditions                                                  |
//+------------------------------------------------------------------+
bool CheckBuyClose()
  {
   bool signal;
   int valor=saida_hilo+saida_medias+saida_adx+saida_silver+saida_moment+saida_atr;
   int soma=0;
   if(saida_hilo==1)soma+=HiloSignal();
   if(saida_medias==1)soma+=MediasSignal();
   if(saida_adx==1)soma+=ADXSignal();
   if(saida_silver==1)soma+=SilverSignal();
   if(saida_moment==1)soma+=MomentumSignal();
   if(saida_atr==1)soma+=ATRSignal();

   if(soma<0 && soma==-valor)signal=true;
   else signal=false;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Comentarios()
  {
   string s_coment=""+"\n"+"RESULTADO DIÁRIO $: "+DoubleToString(lucro_total,2)+"\n";
   s_coment+="ENTRADAS NO DIA: "+IntegerToString(ENTRADAS_TOTAL)+"\n";

   s_coment+=informacoes;
   Comment(s_coment);

  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(atr_handle,0,0,5,ATR_High)<=0 || 
         CopyBuffer(atr_handle,1,0,5,ATR_Low)<=0 || 
         CopyBuffer(silver_handle,0,0,5,SilverSell)<=0 || 
         CopyBuffer(silver_handle,1,0,5,SilverBuy)<=0 ||
         CopyBuffer(hilo_handle,0,0,5,hilo_buffer)<=0 ||
         CopyBuffer(hilo_handle,1,0,5,hilo_color)<=0 || 
         CopyHigh(Symbol(),periodoRobo,0,5,high)<=0 ||
         CopyOpen(Symbol(),periodoRobo,0,5,open)<=0 ||
         CopyLow(Symbol(),periodoRobo,0,5,low)<=0 || 
         CopyClose(Symbol(),periodoRobo,0,5,close)<=0;
   return(b_get);


  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void CloseALL()
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
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
//------------------------------------------------------------------------

void ClosePosType(ENUM_POSITION_TYPE ptype)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype)
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
//------------------------------------------------------------------------
// Select total orders in history and get total pending orders
// (as shown within the COrderInfo class section). 
void DeleteALL()
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
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
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAbertas(double distancia)
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
     {
      ulong o_ticket=OrderGetTicket(j);
      if(o_ticket!=0)
        {
         myorder.Select(o_ticket);
         if(myorder.Magic()==Magic_Number && myorder.Symbol()==mysymbol.Name() && MathAbs(myorder.PriceOpen()-ask)>distancia*ponto)
           {
            if(myorder.Type()==ORDER_TYPE_BUY_LIMIT || myorder.Type()==ORDER_TYPE_SELL_LIMIT)
               mytrade.OrderDelete(o_ticket);
           }
        }
     }
  }
//------------------------------------------------------------------------
//+------------------------------------------------------------------+
//| Highest High & Lowest Low                                        |
//+------------------------------------------------------------------+

double HighestHigh(string pSymbol,ENUM_TIMEFRAMES pPeriod,int pBars,int pStart=0)
  {
   double high[];
   ArraySetAsSeries(high,true);

   int copied= CopyHigh(pSymbol,pPeriod,pStart,pBars,high);
   if(copied == -1) return(copied);

   int maxIdx=ArrayMaximum(high);
   double highest=high[maxIdx];

   return(highest);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LowestLow(string pSymbol,ENUM_TIMEFRAMES pPeriod,int pBars,int pStart=0)
  {
   double low[];
   ArraySetAsSeries(low,true);

   int copied= CopyLow(pSymbol,pPeriod,pStart,pBars,low);
   if(copied == -1) return(copied);

   int minIdx=ArrayMinimum(low);
   double lowest=low[minIdx];

   return(lowest);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PriceLastStopOrder(const ENUM_ORDER_TYPE pending_order_type)
  {
   datetime last_time=0;
   double last_price=-1.0;
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==pending_order_type)
               if(myorder.TimeSetup()>last_time)
                 {
                  last_time=myorder.TimeSetup();
                  last_price=myorder.PriceOpen();
                 }
//---
   return(last_price);
  }
//+------------------------------------------------------------------+
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void DeleteOrders(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+
//| Ordens Abertas                                                    |
//+------------------------------------------------------------------+
bool OrdemAberta(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               return true;
   return false;
  }
//+------------------------------------------------------------------+

//| Checks if the specified filling mode is allowed                  | 
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
double LucroOrdens()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   MqlDateTime stm_end,time_aux;
   TimeToStruct(tm_end,stm_end);
   time_aux=stm_end;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);
   HistorySelect(tm_start,tm_end);
   uint total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LucroPositions()
  {
   double profit=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
         profit+=myposition.Profit();
   return profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void DeletaIndicadores()
  {
   string name;
//--- O número de janelas no gráfico (ao menos uma janela principal está sempre presente) 
   int windows=(int)ChartGetInteger(0,CHART_WINDOWS_TOTAL);
//--- Verifique todas as janelas 
   for(int w=windows-1;w>=0;w--)
     {
      //--- o número de indicadores nesta janela/sub-janela 
      int total=ChartIndicatorsTotal(0,w);
      //--- Passar por todos os indicadores na janela 
      for(int i=total-1;i>=0;i--)
        {
         //--- obtém o nome abreviado do indicador 
         name=ChartIndicatorName(0,w,i);
         ChartIndicatorDelete(0,w,name);
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TimeDayFilter()
  {
   bool filter;
   MqlDateTime TimeNow;
   TimeToStruct(TimeCurrent(),TimeNow);
   switch(TimeNow.day_of_week)
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
bool PosicaoAberta()
  {
   if(myposition.SelectByMagic(Symbol(),Magic_Number)==true)
      return(myposition.PositionType()== POSITION_TYPE_BUY||myposition.PositionType()== POSITION_TYPE_SELL);
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void TrailingStop(double pTrailPoints,double pMinProfit=0,double pStep=10)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number && pTrailPoints>0)
        {

         double currentTakeProfit=myposition.TakeProfit();
         long posType=myposition.PositionType();
         double currentStop;
         double openPrice=NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
         double point=ponto;
         int digits=mysymbol.Digits();
         if(pStep<10) pStep=10;
         double step=pStep*point;

         double minProfit = pMinProfit * point;
         double trailStop = pTrailPoints * point;
         currentTakeProfit=NormalizeDouble(currentTakeProfit,digits);
         double trailStopPrice;
         double currentProfit;

         if(posType==POSITION_TYPE_BUY)
           {
            myorder.Select((ulong)GlobalVariableGet(stp_vd_tick));
            currentStop=myorder.PriceOpen();
            trailStopPrice = mysymbol.Bid() - trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=mysymbol.Bid()-openPrice;

            if(trailStopPrice>currentStop+step && currentProfit>=minProfit)
              {
               // mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
               if(myorder.Select((ulong)GlobalVariableGet(stp_vd_tick)))
                 {
                  GlobalVariableSet(stop_price,trailStopPrice);
                  mytrade.OrderModify((ulong)GlobalVariableGet(stp_vd_tick),trailStopPrice,0,0,order_time_type,0,0);
                  HLineDelete(0,"Stop Loss");
                  HLineCreate(0,"Stop Loss",0,trailStopPrice,clrRed,STYLE_DASH,1,false,false,true,0);
                 }
              }

           }
         else if(posType==POSITION_TYPE_SELL)
           {
            myorder.Select((ulong)GlobalVariableGet(stp_cp_tick));
            currentStop=myorder.PriceOpen();
            trailStopPrice = mysymbol.Ask() + trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=openPrice-mysymbol.Ask();

            if((trailStopPrice<currentStop-step && currentStop>0) && currentProfit>=minProfit)
              {
               //mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
               if(myorder.Select((ulong)GlobalVariableGet(stp_cp_tick)))
                 {
                  GlobalVariableSet(stop_price,trailStopPrice);
                  mytrade.OrderModify((ulong)GlobalVariableGet(stp_cp_tick),trailStopPrice,0,0,order_time_type,0,0);
                  HLineDelete(0,"Stop Loss");
                  HLineCreate(0,"Stop Loss",0,trailStopPrice,clrRed,STYLE_DASH,1,false,false,true,0);
                 }

              }

           }
        }

     }
  }
//+------------------------------------------------------------------+

void BreakEven(string pSymbol,bool usarbreak,double &pBreakEven[],double &pLockProfit[])
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && usarbreak==true)
        {

         long posType=myposition.PositionType();
         long posTicket=myposition.Ticket();
         double currentSL;
         double openPrice= NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
         double currentTP=myposition.TakeProfit();
         double breakEvenStop;
         double currentProfit;
         double bid,ask;

         if(posType==POSITION_TYPE_BUY)
           {
            myorder.Select((ulong)GlobalVariableGet(stp_vd_tick));
            currentSL=myorder.PriceOpen();
            //currentSL=myposition.StopLoss();
            bid=SymbolInfoDouble(pSymbol,SYMBOL_BID);
            currentProfit=mysymbol.Bid()-openPrice;
            //Break Even 0 a 1
            for(int k=0;k<4;k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop=openPrice+pLockProfit[k]*ponto;
                  breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
                  if(currentSL<breakEvenStop && currentSL>0)
                    {
                     if(k==0)Print("Break even stop 1:");
                     else Print("Break even stop 2:");
                     // mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                     mytrade.OrderModify((ulong)GlobalVariableGet(stp_vd_tick),breakEvenStop,0,0,order_time_type,0,0);
                     HLineDelete(0,"Stop Loss");
                     HLineCreate(0,"Stop Loss",0,breakEvenStop,clrRed,STYLE_DASH,1,false,false,true,0);

                    }
                 }
              }
            //----------------------
            //Break Even 2
            if(currentProfit>=pBreakEven[4]*ponto)
              {
               breakEvenStop=openPrice+pLockProfit[4]*ponto;
               breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
               if(currentSL<breakEvenStop && currentSL>0)
                 {
                  Print("Break even stop 3:");
                  // mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                  mytrade.OrderModify((ulong)GlobalVariableGet(stp_vd_tick),breakEvenStop,0,0,order_time_type,0,0);
                  HLineDelete(0,"Stop Loss");
                  HLineCreate(0,"Stop Loss",0,breakEvenStop,clrRed,STYLE_DASH,1,false,false,true,0);

                 }
              }
           }
         //----------------------

         //----------------------

         if(posType==POSITION_TYPE_SELL)
           {
            myorder.Select((ulong)GlobalVariableGet(stp_cp_tick));
            currentSL=myorder.PriceOpen();
            // currentSL=myposition.StopLoss();
            ask=SymbolInfoDouble(pSymbol,SYMBOL_ASK);
            currentProfit=openPrice-mysymbol.Ask();
            //Break Even 0 a 1
            for(int k=0;k<4;k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop=openPrice-pLockProfit[k]*ponto;
                  breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
                  if(currentSL>breakEvenStop || currentSL==0)
                    {
                     if(k==0)Print("Break even stop 1:");
                     else Print("Break even stop 2:");
                     //    mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                     mytrade.OrderModify((ulong)GlobalVariableGet(stp_cp_tick),breakEvenStop,0,0,order_time_type,0,0);
                     HLineDelete(0,"Stop Loss");
                     HLineCreate(0,"Stop Loss",0,breakEvenStop,clrRed,STYLE_DASH,1,false,false,true,0);
                    }
                 }
              }
            //----------------------
            //Break Even 4
            if(currentProfit>=pBreakEven[4]*ponto)
              {
               breakEvenStop=openPrice-pLockProfit[4]*ponto;
               breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
               if(currentSL>breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop 4:");
                  // mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                  mytrade.OrderModify((ulong)GlobalVariableGet(stp_cp_tick),breakEvenStop,0,0,order_time_type,0,0);
                  HLineDelete(0,"Stop Loss");
                  HLineCreate(0,"Stop Loss",0,breakEvenStop,clrRed,STYLE_DASH,1,false,false,true,0);
                 }

              }
            //----------------------

           }

        } //Fim Position Select

     }//Fim for
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalcPontos(double profit)

  {
   double pontos;
   double cont_size=mysymbol.ContractSize();
   double den=((mysymbol.TickValue()*Lot)/mysymbol.TickSize());
   pontos=cont_size*profit/den;
   return(pontos);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
void Aumento_Buy(double preco_entr)
  {
   myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick));
   double preco_stop=myposition.StopLoss();
   double preco_take=myposition.TakeProfit();
   if(pt_aum1>0)mytrade.BuyLimit(lote_aum1,NormalizeDouble(preco_entr-pt_aum1*ponto,digits),original_symbol,preco_stop,preco_take,order_time_type,0,"BUY_1"+exp_name);
   if(pt_aum2>0)mytrade.BuyLimit(lote_aum2,NormalizeDouble(preco_entr-pt_aum2*ponto,digits),original_symbol,preco_stop,preco_take,order_time_type,0,"BUY_2"+exp_name);
   if(pt_aum3>0)mytrade.BuyLimit(lote_aum3,NormalizeDouble(preco_entr-pt_aum3*ponto,digits),original_symbol,preco_stop,preco_take,order_time_type,0,"BUY_3"+exp_name);
   if(pt_aum4>0)mytrade.BuyLimit(lote_aum4,NormalizeDouble(preco_entr-pt_aum4*ponto,digits),original_symbol,preco_stop,preco_take,order_time_type,0,"BUY_4"+exp_name);
   if(pt_aum5>0)mytrade.BuyLimit(lote_aum5,NormalizeDouble(preco_entr-pt_aum5*ponto,digits),original_symbol,preco_stop,preco_take,order_time_type,0,"BUY_5"+exp_name);
   if(pt_aum6>0)mytrade.BuyLimit(lote_aum6,NormalizeDouble(preco_entr-pt_aum6*ponto,digits),original_symbol,preco_stop,preco_take,order_time_type,0,"BUY_6"+exp_name);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Aumento_Sell(double preco_entr)
  {
   myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick));
   double preco_stop=myposition.StopLoss();
   double preco_take=myposition.TakeProfit();
   if(pt_aum1>0)mytrade.SellLimit(lote_aum1,NormalizeDouble(preco_entr+pt_aum1*ponto,digits),original_symbol,preco_stop,preco_take,order_time_type,0,"SELL_1"+exp_name);
   if(pt_aum2>0)mytrade.SellLimit(lote_aum2,NormalizeDouble(preco_entr+pt_aum2*ponto,digits),original_symbol,preco_stop,preco_take,order_time_type,0,"SELL_2"+exp_name);
   if(pt_aum3>0)mytrade.SellLimit(lote_aum3,NormalizeDouble(preco_entr+pt_aum3*ponto,digits),original_symbol,preco_stop,preco_take,order_time_type,0,"SELL_3"+exp_name);
   if(pt_aum4>0)mytrade.SellLimit(lote_aum4,NormalizeDouble(preco_entr+pt_aum4*ponto,digits),original_symbol,preco_stop,preco_take,order_time_type,0,"SELL_4"+exp_name);
   if(pt_aum5>0)mytrade.SellLimit(lote_aum5,NormalizeDouble(preco_entr+pt_aum5*ponto,digits),original_symbol,preco_stop,preco_take,order_time_type,0,"SELL_5"+exp_name);
   if(pt_aum6>0)mytrade.SellLimit(lote_aum6,NormalizeDouble(preco_entr+pt_aum6*ponto,digits),original_symbol,preco_stop,preco_take,order_time_type,0,"SELL_6"+exp_name);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Saida_Sell(double price)
  {

   if(saida1>0)
     {
      mytrade.SellLimit(vol_saida1,NormalizeDouble(price+saida1*ponto,digits),NULL,0,0,order_time_type,0,"Saía Parcial 1");
      tkp_compra1_ticket=mytrade.ResultOrder();
     }
   if(saida2>0)
     {
      mytrade.SellLimit(vol_saida2,NormalizeDouble(price+saida2*ponto,digits),NULL,0,0,order_time_type,0,"Saía Parcial 2");
      tkp_compra2_ticket=mytrade.ResultOrder();
     }
   if(saida3>0)
     {
      mytrade.SellLimit(vol_saida3,NormalizeDouble(price+saida3*ponto,digits),NULL,0,0,order_time_type,0,"Saía Parcial 3");
      tkp_compra3_ticket=mytrade.ResultOrder();
     }
   if(saida4>0)
     {
      mytrade.SellLimit(vol_saida4,NormalizeDouble(price+saida4*ponto,digits),NULL,0,0,order_time_type,0,"Saía Parcial 4");
      tkp_compra4_ticket=mytrade.ResultOrder();
     }
   if(saida5>0)
     {
      mytrade.SellLimit(vol_saida5,NormalizeDouble(price+saida5*ponto,digits),NULL,0,0,order_time_type,0,"Saía Parcial 5");
      tkp_compra5_ticket=mytrade.ResultOrder();
     }

  }
//+------------------------------------------------------------------+
void Saida_Buy(double price)
  {
   if(saida1>0)
     {
      mytrade.BuyLimit(vol_saida1,NormalizeDouble(price-saida1*ponto,digits),NULL,0,0,order_time_type,0,"Saía Parcial 1");
      tkp_venda1_ticket=mytrade.ResultOrder();
     }
   if(saida2>0)
     {
      mytrade.BuyLimit(vol_saida2,NormalizeDouble(price-saida2*ponto,digits),NULL,0,0,order_time_type,0,"Saía Parcial 2");
      tkp_venda2_ticket=mytrade.ResultOrder();
     }
   if(saida3>0)
     {
      mytrade.BuyLimit(vol_saida3,NormalizeDouble(price-saida3*ponto,digits),NULL,0,0,order_time_type,0,"Saía Parcial 3");
      tkp_venda3_ticket=mytrade.ResultOrder();
     }
   if(saida4>0)
     {
      mytrade.BuyLimit(vol_saida4,NormalizeDouble(price-saida4*ponto,digits),NULL,0,0,order_time_type,0,"Saía Parcial 4");
      tkp_venda4_ticket=mytrade.ResultOrder();
     }
   if(saida5>0)
     {
      mytrade.BuyLimit(vol_saida5,NormalizeDouble(price-saida5*ponto,digits),NULL,0,0,order_time_type,0,"Saía Parcial 5");
      tkp_venda5_ticket=mytrade.ResultOrder();
     }

  }
//+------------------------------------------------------------------+
double VolPosType(ENUM_POSITION_TYPE ptype)
  {
   double vol=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && myposition.Symbol()==mysymbol.Name())
        {
         vol+=myposition.Volume();
        }
     }
   return vol;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double VolOrderType(ENUM_ORDER_TYPE otype)
  {
   double vol=0;

   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==otype)
               vol+=myorder.VolumeCurrent();

   return vol;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Atual_vol_Stop()
  {

   if(PosicaoAberta())
     {
      if(Buy_opened())
        {
         if(myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick)) && myorder.Select((ulong)GlobalVariableGet(stp_vd_tick)))
           {
            vol_pos=VolPosType(POSITION_TYPE_BUY);
            vol_stp=myorder.VolumeInitial();

            if(vol_pos!=vol_stp)
              {
               mytrade.OrderDelete((ulong)GlobalVariableGet(stp_vd_tick));
               mytrade.SellStop(vol_pos,GlobalVariableGet(stop_price),Symbol(),0,0,order_time_type,0,"STOP");
               GlobalVariableSet(stp_vd_tick,(double)mytrade.ResultOrder());
              }
           }

        }
      if(Sell_opened())
        {
         if(myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick)) && myorder.Select((ulong)GlobalVariableGet(stp_cp_tick)))
           {
            vol_pos=VolPosType(POSITION_TYPE_SELL);
            vol_stp=myorder.VolumeInitial();

            if(vol_pos!=vol_stp)
              {
               mytrade.OrderDelete((ulong)GlobalVariableGet(stp_cp_tick));
               mytrade.BuyStop(vol_pos,GlobalVariableGet(stop_price),Symbol(),0,0,order_time_type,0,"STOP");
               GlobalVariableSet(stp_cp_tick,(double)mytrade.ResultOrder());

              }
           }

        }
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
//|                                                                  |
//+------------------------------------------------------------------+
void CloseByPosition()
  {
   ulong tick_sell,tick_buy;
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
ulong TickecBuyPos()
  {
   ulong tick=0;
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
//+------------------------------------------------------------------+ 
//| Criar a linha horizontal                                         | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long            chart_ID=0,        // ID de gráfico 
                 const string          name="HLine",      // nome da linha 
                 const int             sub_window=0,      // índice da sub-janela 
                 double                price=0,           // line price 
                 const color           clr=clrRed,        // cor da linha 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // estilo da linha 
                 const int             width=1,           // largura da linha 
                 const bool            back=false,        // no fundo 
                 const bool            selection=true,    // destaque para mover 
                 const bool            hidden=true,       //ocultar na lista de objetos 
                 const long            z_order=0)         // prioridade para clique do mouse 
  {
//--- se o preço não está definido, defina-o no atual nível de preço Bid 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- redefine o valor de erro 
   ResetLastError();
//--- criar um linha horizontal 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": falha ao criar um linha horizontal! Código de erro = ",GetLastError());
      return(false);
     }
//--- definir cor da linha 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- definir o estilo de exibição da linha 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- definir a largura da linha 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- exibir em primeiro plano (false) ou fundo (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- habilitar (true) ou desabilitar (false) o modo do movimento da seta com o mouse 
//--- ao criar um objeto gráfico usando a função ObjectCreate, o objeto não pode ser 
//--- destacado e movimentado por padrão. Dentro deste método, o parâmetro de seleção 
//--- é verdade por padrão, tornando possível destacar e mover o objeto 
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
//| Excluir uma linha horizontal                                     | 
//+------------------------------------------------------------------+ 
bool HLineDelete(const long   chart_ID=0,   // ID do gráfico 
                 const string name="HLine") // nome da linha 
  {
//--- redefine o valor de erro 
   ResetLastError();
//--- excluir uma linha horizontal 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": falha ao Excluir um linha horizontal! Código de erro = ",GetLastError());
      return(false);
     }
//--- sucesso na execução 
   return(true);
  }
//+------------------------------------------------------------------+
