//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
enum OpcaoGap
  {
   Nao_Operar,//Não Operar
   Operar_Apos_Toque_Media,//Operar Após Toque na Média
   Operacoes_Normais //Operar Normalmente
  };

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>
#include <Controls\Dialog.mqh>
#include <Expert\Signal\SignalEnvelopes.mqh>


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

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"RESULTADO MENSAL: "+DoubleToString(LucroOrdensMes()+LucroPositions(),2),xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"RESULTADO DIÁRIO: "+DoubleToString(lucro_total,2),xx1,yy1,xx2,yy2))
      return(false);



   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"ENTRADAS NO DIA: "+DoubleToString(GlobalVariableGet(glob_entr_tot),0),xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+3*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   string str_pos;
   if(!PosicaoAberta())str_pos="ZERADO";
   if(Buy_opened() && myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick)))str_pos="COMPRADO";
   if(Sell_opened() && myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick)))str_pos="VENDIDO";

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"POSIÇÃO: "+str_pos,xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],"GAP LIMITE: "+Gap(),xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+5*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[5],"PONTOS GAP: "+DoubleToString(Pts_Gap(),mysymbol.Digits()),xx1,yy1,xx2,yy2))
      return(false);




//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnTick(void)
  {

   m_label[0].Text("RESULTADO MENSAL: "+DoubleToString(   LucroOrdensMes()+LucroPositions(),2));
   m_label[1].Text("RESULTADO DIÁRIO: "+DoubleToString(lucro_total,2));
   m_label[2].Text("ENTRADAS NO DIA: "+DoubleToString(GlobalVariableGet(glob_entr_tot),0));
   string str_pos;
   if(!PosicaoAberta())str_pos="ZERADO";
   if(Buy_opened() && myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick)))str_pos="COMPRADO";
   if(Sell_opened() && myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick)))str_pos="VENDIDO";

   m_label[3].Text("POSIÇÃO: "+str_pos);
   m_label[4].Text("GAP LIMITE: "+Gap());
   m_label[5].Text("PONTOS GAP: "+DoubleToString(Pts_Gap(),mysymbol.Digits()));
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
CiEnvelopes *envelope;
CiMA *media;
CiStochastic *stoch;

//CSignalEnvelopes *signal=new CSignalEnvelopes;

CControlsDialog ExtDialog;
// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input bool every_tick=true;//Entradas a cada tick
input ulong time_conex=200;// Tempo em Milissegundos para testar conexão
input ulong Magic_Number=12092018;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input double Lot=1;//Lote Entrada
input double _Stop=100; //Stop Loss em Pontos
input double _TakeProfit=100; //Take Profit em Pontos
sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes no Dia
sinput string shorario="############------FILTRO DE HORARIO------#################";
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input int StartHour = 9;// Hora inicial
input int StartMinute=0;// Minuto inicial
sinput string hora_limit_ent="HORARIO LIMITE PARA ENTRADAS";
input int EndHour_Ent=17;//Hora limite para entradas
input int EndMinute_Ent=00;// Minuto limite para entradas

sinput string horafech="HORARIO PARA FECHAMENTO DE POSICOES E ORDENS";
input int EndHour=17;//Hora para fechamento daytrade
input int EndMinute=30;//Minuto fechamento daytrade

input bool daytrade=true;//Fechar Posicao Fim do Horario
sinput string STrailing="############---------------Trailing Stop----------########";
input bool   Use_TraillingStop=true; //Usar Trailing 
input double TraillingStart=0;//Lucro Minimo Iniciar trailing stop
input double TraillingDistance=150;// Distancia em Pontos do Stop Loss
input double TraillingStep=10;// Passo para atualizar Stop Loss
sinput string sbreak="########---------Break Even---------------###############";
input    bool              UseBreakEven=false;                          //Usar BreakEven
input    double               BreakEvenPoint1         =100;                            //Pontos para BreakEven 1
input    double               ProfitPoint1            =80;                             //Pontos de Lucro da Posicao 1
input    double               BreakEvenPoint2         =200;                            //Pontos para BreakEven 2
input    double               ProfitPoint2            =150;                            //Pontos de Lucro da Posicao 2
input    double               BreakEvenPoint3         =300;                            //Pontos para BreakEven 3
input    double               ProfitPoint3            =250;                            //Pontos de Lucro da Posicao 3
input    double               BreakEvenPoint4         =500;                            //Pontos para BreakEven 4
input    double               ProfitPoint4            =400;                            //Pontos de Lucro da Posicao 4
input    double               BreakEvenPoint5         =700;                            //Pontos para BreakEven 5
input    double               ProfitPoint5            =550;                            //Pontos de Lucro da Posicao 5
                                                                                       //Variaveis 

sinput string SEst_Med="############-------------Indicador Envelopes----------########";
input int                InpMAPeriod=14;              // Period
input int                InpMAShift=0;                // Shift
input ENUM_MA_METHOD     InpMAMethod=MODE_SMA;        // Method
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE; // Applied price
input double             InpDeviation=0.1;            // Deviation
sinput string SEst_Stoch="############------------Estocástico----------########";
input int                  Kperiod=14;                 // o período K ( o número de barras para cálculo) 
input int                  Dperiod=3;                 // o período D (o período da suavização primária) 
input int                  slowing=3;                 // período final da suavização 
input ENUM_MA_METHOD       ma_method=MODE_SMA;        // tipo de suavização 
input ENUM_STO_PRICE       price_field=STO_LOWHIGH;   // método de cálculo do Estocástico 
sinput string sestrateg="########---------Estratégia---------------###############";
input bool Usar_Env=true;//Usar Envelope
input bool Usar_Estoc=true;//Usar Estocástico
input double sobrecomprado=80;//Nível Sobrecomprado Estocástico
input double sobrevendido=20;//Nível Sobrevendido Estocástoco
input bool fech_lin_meio=false;//Fechar Posição Na Linha Central do Estocástico(50)
input bool fech_media_env=false;//Fechar Na Média Central do Envelope
input int entr_dia=10;//Máximo de Entradas no Dia
input OpcaoGap UsarGap=Operar_Apos_Toque_Media;//Opção de Gap
input double pts_gap=150;//Gap em Pontos para Filtrar Entradas

                         //Variaveis 

string original_symbol;
double ask,bid;
double lucro_total,pontos_total,lucro_entry;
bool timerOn,tradeOn,timerEnt,gapOn;
double ponto,ticksize,digits;
long curChartID;
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
datetime hora_inicial,hora_final,hora_final_entradas;
double   PointBreakEven[5],PointProfit[5];

string start_hour=IntegerToString(StartHour)+":"+IntegerToString(StartMinute);
string end_hour=IntegerToString(EndHour)+":"+IntegerToString(EndMinute);
string end_hour_entries=IntegerToString(EndHour_Ent)+":"+IntegerToString(EndMinute_Ent);
bool tradebarra;
bool Conexao;
bool updatedata;
string msg_erro;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   original_symbol=Symbol();
   Conexao=IsConnect();
   updatedata=true;
   EventSetMillisecondTimer(time_conex);
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

   int find_wdo=StringFind(original_symbol,"WDO");
   int find_dol=StringFind(original_symbol,"DOL");
   if(find_dol>=0|| find_wdo>=0) ponto=ponto*1000;

   curChartID=ChartID();
   envelope=new CiEnvelopes;
   envelope.Create(Symbol(),periodoRobo,InpMAPeriod,InpMAShift,InpMAMethod,InpAppliedPrice,InpDeviation);
   envelope.AddToChart(curChartID,0);
   media=new CiMA;
   media.Create(Symbol(),periodoRobo,InpMAPeriod,0,InpMAMethod,PRICE_CLOSE);
   media.AddToChart(curChartID,0);
   stoch=new CiStochastic;
   stoch.Create(Symbol(),periodoRobo,Kperiod,Dperiod,slowing,ma_method,price_field);
   stoch.AddToChart(curChartID,ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL));


   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

// parametros incorretos desnecessarios na otimizacao
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   hora_final_entradas=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_entries);

   PointBreakEven[0]=BreakEvenPoint1; PointBreakEven[1]=BreakEvenPoint2; PointBreakEven[2]=BreakEvenPoint3;
   PointBreakEven[3]=BreakEvenPoint4; PointBreakEven[4]=BreakEvenPoint5;
   PointProfit[0]=ProfitPoint1; PointProfit[1]=ProfitPoint2; PointProfit[2]=ProfitPoint3;
   PointProfit[3]=ProfitPoint4; PointProfit[4]=ProfitPoint5;


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

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(hora_final_entradas>hora_final || hora_final_entradas<hora_inicial)
     {
      string erro="Hora Final de Entradas deve estar dentro do horário de operações";
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

//Global Variables Check

   if(!GlobalVariableCheck(glob_entr_tot))GlobalVariableSet(glob_entr_tot,0.0);
   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0.0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0.0);

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,220,190))

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
   if(reason!=5) GlobalVariableSet(glob_entr_tot,0.0);

   delete(envelope);
   delete(media);
   delete(stoch);
   DeletaIndicadores();
   ExtDialog.Destroy(reason);
   EventKillTimer();

//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   CheckConnection();
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
   CheckConnection();
   RefreshRates();
   if(GetIndValue())
     {
      msg_erro="Error in obtain indicators buffers or price rates";
      Print(msg_erro);
      Alert(msg_erro);
      if(TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(msg_erro);

      return;
     }
   envelope.Refresh();
   media.Refresh();
   stoch.Refresh();
   ExtDialog.OnTick();
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   hora_final_entradas=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_entries);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   bool novodia;
   novodia=NewBar.CheckNewBar(original_symbol,PERIOD_D1);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(novodia)
     {
      GlobalVariableSet(glob_entr_tot,0.0);
      tradeOn=true;
      informacoes=" ";

     }
   if(Gap())
     {
      gapOn=false;
      if(UsarGap==Operacoes_Normais) gapOn=true;
      if(UsarGap==Operar_Apos_Toque_Media&&CrossToday())gapOn=true;
     }
   else gapOn=true;

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

   timerOn=true;
   timerEnt=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final;
      timerEnt=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final_entradas;
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

   if(tradeOn && timerOn && gapOn)

     {// inicio Trade On
      if(Buy_opened() && Sell_opened())CloseByPosition();

      if(Buy_opened() && CheckBuyClose())ClosePosType(POSITION_TYPE_BUY);
      if(Sell_opened() && CheckSellClose())ClosePosType(POSITION_TYPE_SELL);

      bool cada_tick;
      cada_tick=NewBar.CheckNewBar(Symbol(),periodoRobo);
      if(cada_tick)
        {
         tradebarra=true;
        }//End NewBar
      if(every_tick)cada_tick=true;

      if(cada_tick && timerEnt && GlobalVariableGet(glob_entr_tot)<entr_dia)
        {
         if(BuySignal() && !PosicaoAberta() && tradebarra)
           {
            if(mytrade.Buy(Lot,original_symbol,0,NormalizeDouble(bid-_Stop*ponto,digits),NormalizeDouble(ask+_TakeProfit*ponto,digits),"BUY"+exp_name))
              {
               GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
               tradebarra=false;
              }
            else Print("Erro enviar ordem ",GetLastError());
           }

         if(SellSignal() && !PosicaoAberta() && tradebarra)
           {
            if(Buy_opened())ClosePosType(POSITION_TYPE_BUY);
            DeleteALL();
            if(mytrade.Sell(Lot,original_symbol,0,NormalizeDouble(ask+_Stop*ponto,digits),NormalizeDouble(bid-_TakeProfit*ponto,digits),"SELL"+exp_name))
              {
               GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
               tradebarra=false;
              }
            else Print("Erro enviar ordem ",GetLastError());

           }
        }//Fim timerEnt

      MytradeTransaction();

      if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);
      if(UseBreakEven && PosicaoAberta())BreakEven(original_symbol,UseBreakEven,PointBreakEven,PointProfit);

     }//End Trade On
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      DeleteALL();
      CloseALL();
     }

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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Sell_opened()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
   bool b_signal;
   bool env=false;
   bool st=false;
   int idx;
   if(every_tick)idx=0;
   else idx=1;
   if(Usar_Env) env=close[0]<envelope.Lower(0) && high[0]>envelope.Lower(0);
   if(Usar_Estoc) st=stoch.Main(idx+1)<stoch.Signal(idx+1) && stoch.Main(idx)>stoch.Signal(idx) && stoch.Main(idx+1)<=sobrevendido;
   b_signal=env || st;
   return b_signal;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   bool s_signal;
   bool env=false;
   bool st=false;
   int idx;
   if(every_tick)idx=0;
   else idx=1;
   if(Usar_Env)env=close[0]>envelope.Upper(0) && low[0]<envelope.Upper(0);
   if(Usar_Estoc)st=stoch.Main(idx+1)>stoch.Signal(idx+1) && stoch.Main(idx)<stoch.Signal(idx) && stoch.Main(idx+1)>=sobrecomprado;
   s_signal=env || st;
   return s_signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckBuyClose()
  {
   bool signal;
   bool env=false;
   bool st=false;
   if(fech_lin_meio) st=stoch.Main(0)>=50;
   if(fech_media_env)env=close[0]>=media.Main(0);
   signal=env || st;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckSellClose()
  {
   bool signal;
   bool env=false;
   bool st=false;
   if(fech_lin_meio) st=stoch.Main(0)<=50;
   if(fech_media_env)env=close[0]<=media.Main(0);
   signal=env || st;
   return signal;
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
   b_get=CopyHigh(Symbol(),periodoRobo,0,5,high)<=0 || 
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
         int digits=mysymbol.Digits();
         if(pStep<10) pStep=10;
         double step=pStep*ponto;

         double minProfit = pMinProfit * ponto;
         double trailStop = pTrailPoints * ponto;
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
              }
            //--------------------------------------------------

            if(order_ticket==(ulong)GlobalVariableGet(vd_tick))
              {
               myposition.SelectByTicket(order_ticket);
               mytrade.PositionModify(order_ticket,NormalizeDouble(myposition.PriceOpen()+_Stop*ponto,digits),NormalizeDouble(myposition.PriceOpen()-_TakeProfit*ponto,digits));
              }

           }//Fim mydeal symbol
        }//Fim deals>prev
     }//Fim HistorySelect
  }
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
         double bid,ask;

         if(posType==POSITION_TYPE_BUY)
           {
            //           myorder.Select(stp_venda_ticket);
            //  currentSL=myorder.PriceOpen();
            currentSL=myposition.StopLoss();
            bid=SymbolInfoDouble(pSymbol,SYMBOL_BID);
            currentProfit=bid-openPrice;
            //Break Even 0 a 3
            for(int k=0;k<4;k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop=openPrice+pLockProfit[k]*ponto;
                  breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
                  if(currentSL<breakEvenStop || currentSL==0)
                    {
                     Print("Break even stop:");
                     mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                     // mytrade.OrderModify(stp_venda_ticket,breakEvenStop,0,0,0,0,0);

                    }
                 }
              }
            //----------------------
            //Break Even 4
            if(currentProfit>=pBreakEven[4]*ponto)
              {
               breakEvenStop=openPrice+pLockProfit[4]*ponto;
               breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
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
            //Break Even 0 a 3
            for(int k=0;k<4;k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop=openPrice-pLockProfit[k]*ponto;
                  breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
                  if(currentSL>breakEvenStop || currentSL==0)
                    {
                     Print("Break even stop:");
                     mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                     // mytrade.OrderModify(stp_compra_ticket,breakEvenStop,0,0,0,0,0);

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
int LongCondition(void)
  {
   int result=0;
   int idx   =0;
   double upper=envelope.Upper(idx);
   double lower=envelope.Lower(idx);
   double width=upper-lower;
//--- if the model 0 is used and price is in the rollback zone, then there is a condition for buying
   if(close[0]<lower+0.2*width && close[0]>lower-0.2*width)
      result=90;
//--- if the model 1 is used and price is above the rollback zone, then there is a condition for buying
   if(close[0]>upper+0.2*width)
      result=70;
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
//| "Voting" that price will fall.                                   |
//+------------------------------------------------------------------+
int ShortCondition(void)
  {
   int result  =0;
   int idx     =0;
   double upper=envelope.Upper(idx);
   double lower=envelope.Lower(idx);
   double width=upper-lower;
//--- if the model 0 is used and price is in the rollback zone, then there is a condition for selling
   if(close[0]>upper-0.2*width && close[0]<upper+0.2*width)
      result=90;
//--- if the model 1 is used and price is above the rollback zone, then there is a condition for selling
   if(close[0]<lower-0.2*width)
      result=70;
//--- return the result
   return(result);
  }
//+------------------------------------------------------------------+
int Direction()
  {
   return LongCondition()-ShortCondition();
  }
//+------------------------------------------------------------------+
double LucroOrdensMes()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   MqlDateTime stm_end,time_aux;
   TimeToStruct(tm_end,stm_end);
   time_aux=stm_end;
   time_aux.day=1;
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
bool Gap()
  {
   return MathAbs(iClose(Symbol(),PERIOD_D1,1)-iOpen(Symbol(),PERIOD_D1,0))>=pts_gap*ponto;
  }
//+------------------------------------------------------------------+
double Pts_Gap()
  {
   return MathAbs(iClose(Symbol(),PERIOD_D1,1)-iOpen(Symbol(),PERIOD_D1,0));
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

int PriceCrossDown()
  {
   bool signal;
   int i;
   signal=false;
   i=0;
   while(!signal && !IsStopped())
     {
      signal=iClose(Symbol(),periodoRobo,i+1)>media.Main(i+1) && iClose(Symbol(),periodoRobo,i)<media.Main(i);
      i=i+1;
     }
   return i-1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PriceCrossUp()
  {
   bool signal;
   int i;
   signal=false;
   i=0;
   while(!signal && !IsStopped())
     {
      signal=iClose(Symbol(),periodoRobo,i+1)<media.Main(i+1) && iClose(Symbol(),periodoRobo,i)>media.Main(i);
      i=i+1;
     }
   return i-1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CrossUpToday()
  {
   int lastcross=PriceCrossUp();
   datetime timecross=iTime(Symbol(),periodoRobo,lastcross);
   MqlDateTime TimeCross;
   TimeToStruct(timecross,TimeCross);
   MqlDateTime TimeNow;
   TimeToStruct(TimeCurrent(),TimeNow);
   if(TimeCross.day==TimeNow.day)return true;
   return false;
  }
//+------------------------------------------------------------------+
bool CrossDownToday()
  {
   int lastcross=PriceCrossDown();
   datetime timecross=iTime(Symbol(),periodoRobo,lastcross);
   MqlDateTime TimeCross;
   TimeToStruct(timecross,TimeCross);
   MqlDateTime TimeNow;
   TimeToStruct(TimeCurrent(),TimeNow);
   if(TimeCross.day==TimeNow.day)return true;
   return false;
  }
//+------------------------------------------------------------------+
bool CrossToday()
  {
   return CrossDownToday()||CrossUpToday();
  }
//+------------------------------------------------------------------+
bool IsConnect()
  {
   return TerminalInfoInteger(TERMINAL_CONNECTED);
  }
//+------------------------------------------------------------------+
void CheckConnection()
  {
   string msg;
   if(!(MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_OPTIMIZATION) || IsStopped()))
     {
      if(Conexao!=IsConnect())
        {
         if(IsConnect())msg="Conexão Reestabelecida";
         else msg="Conexão Perdida";
         Print(msg);
         Alert(msg);
         if(TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(msg);
        }
      Conexao=IsConnect();
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void RefreshRates()
  {
   string msg;
   bool symbol_refresh=mysymbol.Refresh() && mysymbol.RefreshRates() && mysymbol.IsSynchronized();
   if(updatedata!=symbol_refresh)
     {
      if(symbol_refresh)msg="Dados do Símbolo "+Symbol()+" Normalizados";
      else msg="Dados do Símbolo "+Symbol()+" não atualizados ou não sincronizados";
      Print(msg);
      Alert(msg);
      if(TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED)) SendNotification(msg);
     }
   updatedata=symbol_refresh;

  }
//+------------------------------------------------------------------+
