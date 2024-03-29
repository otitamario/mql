//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
#resource "\\Indicators\\DidiIndex.ex5"
#resource "\\Indicators\\macd_histogram_mc.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum colorswitch                                         // use single or multi-color display of Histogram
  {
   MultiColor=0,
   SingleColor=1
  };

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>
#include <Controls\Dialog.mqh>

CLabel            m_label[500];

#define TENTATIVAS 10 // Tentativas envio ordem
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {

   int xx1=INDENT_LEFT;
   int yy1=INDENT_TOP;
   int xx2=x1+BUTTON_WIDTH;
   int yy2=INDENT_TOP+BUTTON_HEIGHT;

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);

//--- create dependent controls 

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"RESULTADO: "+DoubleToString(lucro_total,2),xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;


   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"ENTRADAS NO DIA: "+DoubleToString(GlobalVariableGet(glob_entr_tot),0),xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;
   string str_pos;
   if(!PosicaoAberta())str_pos="ZERADO";
   if(Buy_opened() && myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick)))str_pos="COMPRADO";
   if(Sell_opened() && myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick)))str_pos="VENDIDO";

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"POSIÇÃO: "+str_pos,xx1,yy1,xx2,yy2))
      return(false);

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnTick(void)
  {
   m_label[0].Text("RESULTADO: "+DoubleToString(lucro_total,2));
   m_label[1].Text("ENTRADAS NO DIA: "+DoubleToString(GlobalVariableGet(glob_entr_tot),0));
   string str_pos;
   if(!PosicaoAberta())str_pos="ZERADO";
   if(Buy_opened() && myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick)))str_pos="COMPRADO";
   if(Sell_opened() && myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick)))str_pos="VENDIDO";

   m_label[2].Text("POSIÇÃO: "+str_pos);
  }

//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(CControlsDialog)

EVENT_MAP_END(CAppDialog)

//Classes
CNewBar NewBar;
CisNewBar newbar_ind; // instance of the CisNewBar class: detect new tick candlestick
CTimer Timer;
CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
CiStochastic *stoch;
CiMA *media_high;
CiMA *media_low;
CControlsDialog ExtDialog;
// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=11;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input double Lot=1;//Lote Entrada
input double Inp_Stop=5.0; //Stop Loss  em Pontos
input double Inp_TakeProfit=10.0; //Take Profit em Pontos
double _Stop,_TakeProfit;

sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes no Dia
sinput string shorario="############------FILTRO DE HORARIO------#################";
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:00";//Horario Inicial
input string end_hour="17:30";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario

sinput string SEst_Med="############-------------Indicadores----------########";
sinput string SEst_Medias="############-------------Médias----------########";
input int per_media_high=8;// Periodo Média High
input int per_media_low=8;// Periodo Média Low

sinput string SEst_MACD="############-------------MACD----------########";
input bool UsarMACD=true;//Usar indicador MACD
input int                  InpFastEMA=12;                // Fast EMA period
input int                  InpSlowEMA=26;                // Slow EMA period
input int                  InpSignalMA=9;                // Signal MA period
input ENUM_MA_METHOD       InpAppliedSignalMA=MODE_SMA;  // Applied MA method for signal line
input colorswitch          InpUseMultiColor=MultiColor;  // Use multi-color or single-color histogram
input ENUM_APPLIED_PRICE   InpAppliedPrice=PRICE_CLOSE;  // Applied price
sinput string SEst_DIDI="############-------------DIDI----------########";
input bool UsarDidi=true;//Usar indicador Didi
input int                  InpDidi_curta=3;                // Curta
input int                  InpDidi_media=8;                // Média
input int                  InpDidi_longa=20;                // Longa
sinput string SEst_Stoch="############------------Estocástico----------########";
input bool UsarStoch=true;//Usar indicador Estocástico
input int                  Kperiod=14;                 // o período K ( o número de barras para cálculo) 
input int                  Dperiod=3;                 // o período D (o período da suavização primária) 
input int                  slowing=3;                 // período final da suavização 
input ENUM_MA_METHOD       ma_method=MODE_SMA;        // tipo de suavização 
input ENUM_STO_PRICE       price_field=STO_LOWHIGH;   // método de cálculo do Estocástico 

                                                      //Variaveis 
sinput string sestr="############------Estratégia------#################";
input double _dist_entr=1.0;//Distância da Média para entrada 2o Candle
sinput string srealp="############------Realização Parcial------#################";
input double _rp1=2.0;//Pontos R.P 1 (0 Não Usar)
input double _lts_rp1=50;//Porcentagem Lotes R.P 1
input double _rp2=0;//Pontos R.P 2 (0 Não Usar)
input double _lts_rp2=25;//Porcentagem Lotes R.P 2

sinput string STrailing="############---------------Trailing Stop----------########";
input bool   Use_TraillingStop=true; //Usar Trailing 
input double _TraillingStart=2.0;//Lucro Minimo Iniciar trailing stop
input double _TraillingDistance=3.5;// Distancia em Pontos do Stop Loss
input double _TraillingStep=0.5;// Passo para atualizar Stop Loss
sinput string sbreak="########---------Break Even---------------###############";
input    bool              UseBreakEven=true;                          //Usar BreakEven
input    double               _BreakEvenPoint1=2.5;                            //Pontos para BreakEven 1
input    double               _ProfitPoint1=1.0;                             //Pontos de Lucro da Posicao 1
input    double               _BreakEvenPoint2         =4.0;                            //Pontos para BreakEven 2
input    double               _ProfitPoint2            =2.0;                            //Pontos de Lucro da Posicao 2
input    double               _BreakEvenPoint3         =6.0;                            //Pontos para BreakEven 3
input    double               _ProfitPoint3            =4.0;                            //Pontos de Lucro da Posicao 3


string original_symbol;
double ask,bid;
double lucro_total,pontos_total,lucro_entry;
bool timerOn,tradeOn;
double ponto,ticksize,digits;
long curChartID;
int macd_handle,didi_handle;
double MACD_Buffer[],MACD_Signal[];
double Didi_Fast[],Didi_Slow[];
double high[],low[],open[],close[];
double price_open;
string glob_entr_tot="ENT_TOT"+Symbol()+IntegerToString(Magic_Number);
string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string deals_total="deals_total"+Symbol()+IntegerToString(Magic_Number),deals_total_prev="deals_total_prev"+Symbol()+IntegerToString(Magic_Number);

double buyprice,sellprice,oldprice;
string informacoes=" ";
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
int PrevPositions;
datetime time_novodia[4];
double lotes_stop;
int res_code;
int cont;
datetime hora_inicial,hora_final;
bool tradebarra;
double rp1,rp2,lts_rp1,lts_rp2;
double   PointBreakEven[3],PointProfit[3];
double BreakEvenPoint1,ProfitPoint1,BreakEvenPoint2,ProfitPoint2,BreakEvenPoint3,ProfitPoint3;
double TraillingStart,TraillingDistance,TraillingStep;
double dist_entr;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   tradebarra=false;
   original_symbol=Symbol();
   int find_wdo=StringFind(original_symbol,"WDO");
   int find_dol=StringFind(original_symbol,"DOL");
   if(find_dol>=0|| find_wdo>=0)
     {
      _Stop=1000*Inp_Stop;
      _TakeProfit=1000*Inp_TakeProfit;
      rp1=1000*_rp1;
      rp2=1000*_rp2;
      BreakEvenPoint1=1000*_BreakEvenPoint1;
      ProfitPoint1=1000*_ProfitPoint1;
      BreakEvenPoint2=1000*_BreakEvenPoint2;
      ProfitPoint2=1000*_ProfitPoint2;
      BreakEvenPoint3=1000*_BreakEvenPoint3;
      ProfitPoint3=1000*_ProfitPoint3;
      TraillingStart=1000*_TraillingStart;
      TraillingDistance=1000*_TraillingDistance;
      TraillingStep=1000*_TraillingStep;
      dist_entr=1000*_dist_entr;
     }
   else
     {
      _Stop=Inp_Stop;
      _TakeProfit=Inp_TakeProfit;
      rp1=_rp1;
      rp2=_rp2;

      BreakEvenPoint1=_BreakEvenPoint1;
      ProfitPoint1=_ProfitPoint1;
      BreakEvenPoint2=_BreakEvenPoint2;
      ProfitPoint2=_ProfitPoint2;
      BreakEvenPoint3=_BreakEvenPoint3;
      ProfitPoint3=_ProfitPoint3;
      TraillingStart=_TraillingStart;
      TraillingDistance=_TraillingDistance;
      TraillingStep=_TraillingStep;
      dist_entr=_dist_entr;

     }

   tradeOn=true;
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

   curChartID=ChartID();

   media_high=new CiMA;
   media_low=new CiMA;

   media_high.Create(Symbol(),periodoRobo,per_media_high,0,MODE_SMA,PRICE_HIGH);
   media_low.Create(Symbol(),periodoRobo,per_media_low,0,MODE_SMA,PRICE_LOW);
   media_high.AddToChart(curChartID,0);
   media_low.AddToChart(curChartID,0);
   macd_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\macd_histogram_mc",InpFastEMA,InpSlowEMA,InpSignalMA,InpAppliedSignalMA,InpUseMultiColor,InpAppliedPrice);
   didi_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\DidiIndex",periodoRobo,MODE_SMA,PRICE_CLOSE,0,InpDidi_curta,InpDidi_media,InpDidi_longa);
   stoch=new CiStochastic;
   stoch.Create(Symbol(),periodoRobo,Kperiod,Dperiod,slowing,ma_method,price_field);
   ChartIndicatorAdd(ChartID(),ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),didi_handle);
   ChartIndicatorAdd(ChartID(),ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),macd_handle);
   stoch.AddToChart(curChartID,ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL));

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ArraySetAsSeries(Didi_Fast,true);
   ArraySetAsSeries(Didi_Slow,true);

   ArraySetAsSeries(MACD_Buffer,true);
   ArraySetAsSeries(MACD_Signal,true);

   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

   PointBreakEven[0]=BreakEvenPoint1; PointBreakEven[1]=BreakEvenPoint2; PointBreakEven[2]=BreakEvenPoint3;
   PointProfit[0]=ProfitPoint1; PointProfit[1]=ProfitPoint2; PointProfit[2]=ProfitPoint3;
   for(int i=0;i<3;i++)
     {
      if(PointBreakEven[i]<PointProfit[i])
        {
         string erro="Profit do Break Even deve ser menor que o Ponto de Break Even";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);

        }

     }

   for(int i=0;i<2;i++)
     {
      if(PointBreakEven[i+1]<=PointBreakEven[i])
        {
         string erro="Pontos de Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);

        }

     }

   for(int i=0;i<2;i++)
     {
      if(PointProfit[i+1]<=PointProfit[i])
        {
         string erro="Pontos de Profit do Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);

        }

     }

// parametros incorretos desnecessarios na otimizacao
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

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

   if(!UsarDidi && !UsarMACD && !UsarStoch)
     {
      string erro="Escolhe pelo menos um indicador para usar";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(rp1<0 || rp2<0)
     {
      string erro="Realização Parcial em Pontos deve ser>=0";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(rp1>=rp2 && rp2>0)
     {
      string erro="Realização Parcial  1 deve ser Menor que Realização Parcial 2";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(rp1+rp2>0 && _lts_rp1+_lts_rp2>100)
     {
      string erro="Soma das Porcentagens dos Lotes de Realização Parcial deve ser Menor ou igual a 100%";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(rp2>=_TakeProfit)
     {
      string erro="Realização Parcial  2 deve ser Menor que TakeProfit";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

//Global Variables Check

   if(!GlobalVariableCheck(glob_entr_tot))GlobalVariableSet(glob_entr_tot,0.0);
   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0.0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0.0);

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,200,150))

      return(INIT_FAILED);
//--- run application 

   ExtDialog.Run();

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   delete(media_high);
   delete(media_low);
   delete(stoch);
   DeletaIndicadores();
   ExtDialog.Destroy(reason);

//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
   Main_Program();

  }// fim OnTick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



//+-------------ROTINAS----------------------------------------------+

void Main_Program()
  {
   mysymbol.Refresh();
   mysymbol.RefreshRates();
   media_high.Refresh();
   media_low.Refresh();
   stoch.Refresh();
   ExtDialog.OnTick();
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

   bool novodia;
   novodia=NewBar.CheckNewBar(original_symbol,PERIOD_D1);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(novodia)
     {
      GlobalVariableSet(glob_entr_tot,0.0);
      tradeOn=true;
      Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");
      informacoes=" ";

     }

   lucro_total=LucroOrdens()+LucroPositions();
   lucro_entry=LucroPositions();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
      informacoes="EA encerrado lucro ou prejuizo";

     }

   timerOn=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer==true)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      timerOn=true;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!timerOn && daytrade)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();

     }

//Atualizacao das Cotacoes----ticks
   MqlTick last_tick;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(SymbolInfoTick(Symbol(),last_tick))
     {
      bid= last_tick.bid;
      ask=last_tick.ask;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      Print("Falhou obter o tick");
      return;
     }
   double spread=ask-bid;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!PosicaoAberta() && OrdersTotal()>0)DeleteALL();
   if(Buy_opened() && Sell_opened())CloseByPosition();

   if(tradeOn && timerOn)

     {// inicio Trade On

      if(NewBar.CheckNewBar(Symbol(),periodoRobo))
        {
         tradebarra=true;
        }

      if(BuySignal() && !PosicaoAberta() && tradebarra)
        {
         if(mytrade.Buy(Lot,original_symbol,0,NormalizeDouble(bid-_Stop*ponto,digits),NormalizeDouble(ask+_TakeProfit*ponto,digits),"BUY"+exp_name))
           {
            GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
           }
         else Print("Erro enviar ordem ",GetLastError());
        }

      if(SellSignal() && !PosicaoAberta() && tradebarra)
        {
         if(mytrade.Sell(Lot,original_symbol,0,NormalizeDouble(ask+_Stop*ponto,digits),NormalizeDouble(bid-_TakeProfit*ponto,digits),"SELL"+exp_name))
           {
            GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
           }
         else Print("Erro enviar ordem ",GetLastError());

        }

      if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);
      if(UseBreakEven && PosicaoAberta())BreakEven(original_symbol,UseBreakEven,PointBreakEven,PointProfit);

      MytradeTransaction();

     }//End Trade On

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      DeleteALL();
      CloseALL();
     }
//Comentarios();

   MqlDateTime stm_end,time_aux;
   TimeToStruct(TimeCurrent(),stm_end);
   time_aux=stm_end;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);

   if(HistorySelect(tm_start,TimeCurrent()))
     {
      GlobalVariableSet(deals_total_prev,(double)HistoryDealsTotal());
     }

  }//End Main Program
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Buy conditions                                                   |
//+------------------------------------------------------------------+
bool Buy_opened()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   bool b_signal,bs_2;
   b_signal=open[0]<media_high.Main(0) && close[0]>media_high.Main(0);
   if(UsarMACD)b_signal=b_signal && MACD_Buffer[0]>MACD_Signal[0];
   if(UsarStoch)b_signal=b_signal && stoch.Main(0)>stoch.Signal(0);
   if(UsarDidi)b_signal=b_signal && Didi_Fast[0]>Didi_Slow[0];
   bs_2=close[2]<media_high.Main(2) && close[1]>media_high.Main(1) && close[1]>open[1];
   if(UsarMACD)bs_2=bs_2 && MACD_Buffer[0]>MACD_Signal[0];
   if(UsarStoch)bs_2=bs_2 && stoch.Main(0)>stoch.Signal(0);
   if(UsarDidi)bs_2=bs_2 && Didi_Fast[0]>Didi_Slow[0];
   bs_2=bs_2 && close[0]>media_high.Main(0) && close[0]-media_high.Main(0)<=dist_entr && close[0]>open[0];
   b_signal=b_signal || bs_2;
   return b_signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   bool s_signal,ss_2;
   s_signal=open[0]>media_low.Main(0) && close[0]<media_low.Main(0);
   if(UsarMACD)s_signal=s_signal && MACD_Buffer[0]<MACD_Signal[0];
   if(UsarStoch)s_signal=s_signal && stoch.Main(0)<stoch.Signal(0);
   if(UsarDidi)s_signal=s_signal && Didi_Fast[0]<Didi_Slow[0];
   ss_2=close[2]>media_low.Main(2) && close[1]<media_low.Main(1) && close[1]<open[1];
   if(UsarMACD)ss_2=ss_2 && MACD_Buffer[0]<MACD_Signal[0];
   if(UsarStoch)ss_2=ss_2 && stoch.Main(0)<stoch.Signal(0);
   if(UsarDidi)ss_2=ss_2 && Didi_Fast[0]<Didi_Slow[0];
   ss_2=ss_2 && close[0]<media_low.Main(0) && media_low.Main(0)-close[0]<=dist_entr && close[0]<open[0];

   s_signal=s_signal || ss_2;

   return s_signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(macd_handle,0,0,5,MACD_Buffer)<=0 || 
         CopyBuffer(macd_handle,1,0,5,MACD_Signal)<=0 || 
         CopyBuffer(didi_handle,0,0,5,Didi_Fast)<=0 ||
         CopyBuffer(didi_handle,2,0,5,Didi_Slow)<=0||
         CopyHigh(Symbol(),periodoRobo,0,5,high)<=0 ||
         CopyOpen(Symbol(),periodoRobo,0,5,open)<=0 ||
         CopyLow(Symbol(),periodoRobo,0,5,low)<=0 || 
         CopyClose(Symbol(),periodoRobo,0,5,close)<=0;
   return(b_get);


  }
//+------------------------------------------------------------------+
//|                                                                  |
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

void ClosePosType(ENUM_POSITION_TYPE ptype)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//------------------------------------------------------------------------
// Select total orders in history and get total pending orders
// (as shown within the COrderInfo class section). 
void DeleteALL()
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAbertas(double distancia)
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Delete Orders                                                    |
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Ordens Abertas                                                    |
//+------------------------------------------------------------------+
bool OrdemAberta(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               return true;
   return false;
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
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
bool PosicaoAberta()
  {
   if(myposition.SelectByMagic(original_symbol,Magic_Number)==true)
      return(myposition.PositionType()== POSITION_TYPE_BUY||myposition.PositionType()== POSITION_TYPE_SELL);
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
// Trailing stop (points)
void TrailingStop(double pTrailPoints,double pMinProfit=0,double pStep=10)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number && pTrailPoints>0)
        {

         double currentTakeProfit=myposition.TakeProfit();
         long posType=myposition.PositionType();
         double currentStop;
         double openPrice=myposition.PriceOpen();
         double point=mysymbol.Point();
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
            currentStop=myposition.StopLoss();
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
            currentStop=myposition.StopLoss();
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void MytradeTransaction()
  {

   if(!PosicaoAberta() && OrdersTotal()>0)DeleteALL();

   ulong order_ticket;
   MqlDateTime stm_end,time_aux;
   TimeToStruct(TimeCurrent(),stm_end);
   time_aux=stm_end;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);

   if(HistorySelect(tm_start,TimeCurrent()))
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
              }

            if(order_ticket==(ulong)GlobalVariableGet(cp_tick))

              {
               myposition.SelectByTicket(order_ticket);
               mytrade.PositionModify(order_ticket,NormalizeDouble(myposition.PriceOpen()-_Stop*ponto,digits),NormalizeDouble(myposition.PriceOpen()+_TakeProfit*ponto,digits));
               Real_Parc_Buy();
              }
            //--------------------------------------------------

            if(order_ticket==(ulong)GlobalVariableGet(vd_tick))
              {
               myposition.SelectByTicket(order_ticket);
               mytrade.PositionModify(order_ticket,NormalizeDouble(myposition.PriceOpen()+_Stop*ponto,digits),NormalizeDouble(myposition.PriceOpen()-_TakeProfit*ponto,digits));
               Real_Parc_Sell();
              }

           }//Fim mydeal symbol
        }//Fim deals>prev
     }//Fim HistorySelect
  }
//+------------------------------------------------------------------+
void Real_Parc_Buy()
  {

   if(Lot>mysymbol.LotsMin())
     {
      myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick));
      lts_rp1=MathMin(MathCeil(0.01*_lts_rp1*Lot/mysymbol.LotsStep())*mysymbol.LotsStep(),Lot);
      lts_rp1=MathMax(lts_rp1,mysymbol.LotsMin());
      lts_rp2=MathCeil(0.01*_lts_rp2*Lot/mysymbol.LotsStep())*mysymbol.LotsStep();
      if(lts_rp1+lts_rp2>Lot || lts_rp1+lts_rp2==Lot)
        {
         lts_rp2=Lot-lts_rp1;
         mytrade.PositionModify((ulong)GlobalVariableGet(cp_tick),myposition.StopLoss(),0);
        }
      if(rp1>0&&lts_rp1>0)mytrade.SellLimit(lts_rp1,NormalizeDouble(myposition.PriceOpen()+rp1*ponto,digits),original_symbol,0,0,0,0,"PARCIAL 1");
      if(rp2>0&&lts_rp2>0)mytrade.SellLimit(lts_rp2,NormalizeDouble(myposition.PriceOpen()+rp2*ponto,digits),original_symbol,0,0,0,0,"PARCIAL 2");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Real_Parc_Sell()
  {
   if(Lot>mysymbol.LotsMin())
     {
      myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick));
      lts_rp1=MathMin(MathCeil(0.01*_lts_rp1*Lot/mysymbol.LotsStep())*mysymbol.LotsStep(),Lot);
      lts_rp1=MathMax(lts_rp1,mysymbol.LotsMin());
      lts_rp2=MathCeil(0.01*_lts_rp2*Lot/mysymbol.LotsStep())*mysymbol.LotsStep();
      if(lts_rp1+lts_rp2>Lot || lts_rp1+lts_rp2==Lot)
        {
         lts_rp2=Lot-lts_rp1;
         mytrade.PositionModify((ulong)GlobalVariableGet(vd_tick),myposition.StopLoss(),0);
        }
      if(rp1>0&&lts_rp1>0)mytrade.BuyLimit(lts_rp1,NormalizeDouble(myposition.PriceOpen()-rp1*ponto,digits),original_symbol,0,0,0,0,"PARCIAL 1");
      if(rp2>0&&lts_rp2>0)mytrade.BuyLimit(lts_rp2,NormalizeDouble(myposition.PriceOpen()-rp2*ponto,digits),original_symbol,0,0,0,0,"PARCIAL 2");
     }
  }
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

//+------------------------------------------------------------------+
//| Break even stop                                                  |
//+------------------------------------------------------------------+
//Break Even

void BreakEven(string pSymbol,bool usarbreak,double &pBreakEven[],double &pLockProfit[])
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && usarbreak==true)
        {

         long posType=myposition.PositionType();
         long posTicket=myposition.Ticket();
         double currentSL;
         double openPrice= MathRound(myposition.PriceOpen()/ticksize)*ticksize;
         double currentTP=myposition.TakeProfit();
         double breakEvenStop;
         double currentProfit;
         double ponto=SymbolInfoDouble(pSymbol,SYMBOL_POINT);
         double bid,ask;

         if(posType==POSITION_TYPE_BUY)
           {
            //           myorder.Select(stp_venda_ticket);
            //  currentSL=myorder.PriceOpen();
            currentSL=myposition.StopLoss();
            bid=SymbolInfoDouble(pSymbol,SYMBOL_BID);
            currentProfit=bid-openPrice;
            //Break Even 0 a 1
            for(int k=0;k<2;k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop=openPrice+pLockProfit[k]*ponto;
                  breakEvenStop=MathRound(breakEvenStop/ticksize)*ticksize;
                  if(currentSL<breakEvenStop || currentSL==0)
                    {
                     Print("Break even stop:");
                     mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                     // mytrade.OrderModify(stp_venda_ticket,breakEvenStop,0,0,0,0,0);

                    }
                 }
              }
            //----------------------
            //Break Even 2
            if(currentProfit>=pBreakEven[2]*ponto)
              {
               breakEvenStop=openPrice+pLockProfit[2]*ponto;
               breakEvenStop=MathRound(breakEvenStop/ticksize)*ticksize;
               if(currentSL<breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop:");
                  mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                  // mytrade.OrderModify(stp_venda_ticket,breakEvenStop,0,0,0,0,0);

                 }
              }
           }
         //----------------------

         //----------------------

         if(posType==POSITION_TYPE_SELL)
           {
            //  myorder.Select(stp_compra_ticket);
            // currentSL=myorder.PriceOpen();
            currentSL=myposition.StopLoss();
            ask=SymbolInfoDouble(pSymbol,SYMBOL_ASK);
            currentProfit=openPrice-ask;
            //Break Even 0 a 1
            for(int k=0;k<2;k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop=openPrice-pLockProfit[k]*ponto;
                  breakEvenStop=MathRound(breakEvenStop/ticksize)*ticksize;
                  if(currentSL>breakEvenStop || currentSL==0)
                    {
                     Print("Break even stop:");
                     mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                     // mytrade.OrderModify(stp_compra_ticket,breakEvenStop,0,0,0,0,0);

                    }
                 }
              }
            //----------------------
            //Break Even 2
            if(currentProfit>=pBreakEven[2]*ponto)
              {
               breakEvenStop=openPrice-pLockProfit[2]*ponto;
               breakEvenStop=MathRound(breakEvenStop/ticksize)*ticksize;
               if(currentSL>breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop:");
                  mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                  //  mytrade.OrderModify(stp_compra_ticket,breakEvenStop,0,0,0,0,0);

                 }

              }
            //----------------------

           }

        } //Fim Position Select

     }//Fim for
  }
//+------------------------------------------------------------------+
