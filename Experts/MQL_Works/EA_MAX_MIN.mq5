//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>
#include <Controls\Dialog.mqh>

CLabel            m_label[50];

#define TENTATIVAS 10 // Tentativas envio ordem
#define LARGURA_PAINEL 200 // Largura Painel
#define ALTURA_PAINEL 220 // Altura Painel
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

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+3*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;
   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"MARTINGALE NÍVEL: "+DoubleToString(GlobalVariableGet(glob_mart),0),xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;
   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],"Loss Consecutivos: "+DoubleToString(GlobalVariableGet(total_pr),0),xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+5*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;
   if(!CreateLabel(m_chart_id,m_subwin,m_label[5],"Gains Consecutivos: "+DoubleToString(GlobalVariableGet(total_g),0),xx1,yy1,xx2,yy2))
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
   m_label[3].Text("MARTINGALE NÍVEL: "+DoubleToString(GlobalVariableGet(glob_mart),0));
   m_label[4].Text("Loss Consecutivos: "+DoubleToString(GlobalVariableGet(total_pr),0));
   m_label[5].Text("Gains Consecutivos: "+DoubleToString(GlobalVariableGet(total_g),0));

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

CControlsDialog ExtDialog;
// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=20082018;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input double Lot=1;//Lote Fixo de Entrada
input double _Stop=200;//Valor Stop Loss em Pontos
input double _TakeProfit=100; //Valor Take Profit em Pontos
sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";
input bool UsarLucro=false;//Usar Lucro/Prejuízo para Fechamento Diário True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes no Dia
sinput string shorario="############------FILTRO DE HORARIO------#################";
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:00";//Horario Inicial
input string end_hour="17:30";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario
sinput string SEst="############-------------Estratégia----------########";
input bool Martingale=true;//Usar Martingale
input double mult_mart=1.5;//Multiplicador Martingale 
input bool LimitTotGainLoss=true;//Limitar Número Trades Gains/Loss Consecutivos
input int max_loss=3;//Máximo Loss Consecutivos
input int max_gain=3;//Máximo Gains Consecutivos

sinput string srealp="############------Realização Parcial------#################";
input double rp1=40;//Pontos R.P 1 (0 Não Usar)
input double _lts_rp1=25;//Porcentagem Lotes R.P 1
input double rp2=70;//Pontos R.P 2 (0 Não Usar)
input double _lts_rp2=25;//Porcentagem Lotes R.P 2
input double rp3=100;//Pontos R.P 3 (0 Não Usar)
input double _lts_rp3=25;//Porcentagem Lotes R.P 3

sinput string sbreak="########---------Break Even---------------###############";
input    bool              UseBreakEven=true;                          //Usar BreakEven
input    double               BreakEvenPoint1=100;                            //Pontos para BreakEven 1
input    double               ProfitPoint1=20;                             //Pontos de Lucro da Posicao 1
input    double               BreakEvenPoint2=150;                            //Pontos para BreakEven 2
input    double               ProfitPoint2=70;                            //Pontos de Lucro da Posicao 2
input    double               BreakEvenPoint3=200;                            //Pontos para BreakEven 3
input    double               ProfitPoint3=130;                            //Pontos de Lucro da Posicao 3
sinput string STrailing="############---------------Trailing Stop----------########";
input bool   Use_TraillingStop=true; //Usar Trailing 
input double TraillingStart=0;//Lucro Minimo Iniciar trailing stop
input double TraillingDistance=200;// Distanccia em Pontos do Stop Loss
input double TraillingStep=10;// Passo para atualizar Stop Loss

                              //Variaveis 
double Marting2[27];

string original_symbol;
double ask,bid;
double lucro_total,pontos_total,lucro_entry;
bool timerOn,tradeOn;
double ponto,ticksize,digits;
long curChartID;
double high[],low[],open[],close[];
double price_open;
string glob_entr_tot="ENT_TOT"+Symbol()+IntegerToString(Magic_Number);
string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string tp_cp_tick="tp_cp_tick"+Symbol()+IntegerToString(Magic_Number),tp_vd_tick="tp_vd_tick"+Symbol()+IntegerToString(Magic_Number);
string stp_cp_tick="stp_cp_tick"+Symbol()+IntegerToString(Magic_Number),stp_vd_tick="stp_vd_tick"+Symbol()+IntegerToString(Magic_Number);
string deals_total="deals_total"+Symbol()+IntegerToString(Magic_Number),deals_total_prev="deals_total_prev"+Symbol()+IntegerToString(Magic_Number);
string glob_mart="glob_mart"+Symbol()+IntegerToString(Magic_Number);
string gv_today="gv_today"+Symbol()+IntegerToString(Magic_Number),gv_today_prev="gv_today_prev"+Symbol()+IntegerToString(Magic_Number);
string tradebuy="tradebuy"+Symbol()+IntegerToString(Magic_Number);
string tradesell="tradesell"+Symbol()+IntegerToString(Magic_Number);
string last_deal_pr="last_deal_pr"+Symbol()+IntegerToString(Magic_Number);
string total_pr="total_pr"+Symbol()+IntegerToString(Magic_Number);
string total_g="total_g"+Symbol()+IntegerToString(Magic_Number);

double buyprice,sellprice,oldprice,price_stop;
string informacoes=" ";
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
int PrevPositions;
datetime time_novodia[4];
double lotes_stop;
int res_code;
int cont;
datetime hora_inicial,hora_final;
string msg_erro;
bool Conexao;
bool updatedata;
bool tradebarra;
double take_price,stop_price;
double _lucro,_prejuizo;
uint total_deals,cont_deals;
ulong ticket_history_deal,deal_magic;
double lts_rp1,lts_rp2,lts_rp3,lots_take;
double vol_pos,vol_stp,preco_stp,preco_medio;
MqlDateTime TimeNow;
double   PointBreakEven[3],PointProfit[3];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   TimeToStruct(TimeCurrent(),TimeNow);
   GlobalVariableSet(gv_today_prev,(double)TimeNow.day_of_year);
   original_symbol=Symbol();
   Conexao=IsConnect();
   updatedata=true;
   EventSetTimer(1);
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
   if(find_dol>=0|| find_wdo>=0) ponto=1.0;

   curChartID=ChartID();

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

   if(rp1<0 || rp2<0 || rp3<0)
     {
      string erro="Realização Parcial em Pontos deve ser>=0";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if((rp1>=rp2 && rp2>0) || (rp1>=rp3 && rp3>0) || (rp2>=rp3 && rp3>0))
     {
      string erro="As Realizações Parciais devem estar em ordem crescente";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(rp1+rp2+rp3>0 && _lts_rp1+_lts_rp2+_lts_rp3>100)
     {
      string erro="Soma das Porcentagens dos Lotes de Realização Parcial deve ser Menor ou igual a 100%";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(rp3>=_TakeProfit)
     {
      string erro="Realização Parcial  3 deve ser Menor que TakeProfit";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

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

//Global Variables Check

   if(!GlobalVariableCheck(glob_entr_tot))GlobalVariableSet(glob_entr_tot,0.0);
   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0.0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0.0);
   if(!GlobalVariableCheck(tp_cp_tick))GlobalVariableSet(tp_cp_tick,0.0);
   if(!GlobalVariableCheck(tp_vd_tick))GlobalVariableSet(tp_vd_tick,0.0);
   if(!GlobalVariableCheck(glob_mart))GlobalVariableSet(glob_mart,0.0);
   if(!GlobalVariableCheck(tradebuy))GlobalVariableSet(tradebuy,0.0);
   if(!GlobalVariableCheck(tradesell))GlobalVariableSet(tradesell,0.0);
   if(!GlobalVariableCheck(last_deal_pr))GlobalVariableSet(last_deal_pr,0.0);
   if(!GlobalVariableCheck(total_pr))GlobalVariableSet(total_pr,0.0);
   if(!GlobalVariableCheck(total_g))GlobalVariableSet(total_g,0.0);

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
      return(INIT_FAILED);
//--- run application 

   ExtDialog.Run();

   if(HistorySelect(iTime(original_symbol,PERIOD_D1,0),TimeCurrent()))
     {
      total_deals=HistoryDealsTotal();
      ticket_history_deal=0;
      cont_deals=0;
      for(uint i=0;i<total_deals;i++)
        {
         //--- try to get deals ticket_history_deal
         if((ticket_history_deal=HistoryDealGetTicket(i))>0)
           {
            deal_magic=HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
            if(deal_magic==Magic_Number && HistoryDealGetString(ticket_history_deal,DEAL_SYMBOL)==mysymbol.Name())cont_deals+=1;
           }
        }
     }
   GlobalVariableSet(deals_total_prev,(double)cont_deals);

   Marting2[0]=0;Marting2[1]=1;Marting2[2]=1;Marting2[3]=1;Marting2[4]=1;Marting2[5]=1;Marting2[6]=2;Marting2[7]=2;Marting2[8]=2;
   Marting2[9]=3;Marting2[10]=3;Marting2[11]=4;Marting2[12]=5;Marting2[13]=6;Marting2[14]=7;Marting2[15]=8;Marting2[16]=9;Marting2[17]=10;
   Marting2[18]=12;Marting2[19]=14;Marting2[20]=16;Marting2[21]=18;Marting2[22]=21;Marting2[23]=25;Marting2[24]=29;Marting2[25]=34;Marting2[26]=39;

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
void OnTimer()
  {
   CheckConnection();
  }
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

   TimeToStruct(TimeCurrent(),TimeNow);
   GlobalVariableSet(gv_today,(double)TimeNow.day_of_year);

   bool novodia;
   novodia=NewBar.CheckNewBar(original_symbol,PERIOD_D1);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(novodia || GlobalVariableGet(gv_today)!=GlobalVariableGet(gv_today_prev))
     {
      GlobalVariableSet(glob_entr_tot,0.0);
      GlobalVariableSet(deals_total_prev,0.0);
      GlobalVariableSet(tradebuy,0.0);
      GlobalVariableSet(tradesell,0.0);
      GlobalVariableSet(glob_mart,0.0);
      GlobalVariableSet(last_deal_pr,0.0);
      GlobalVariableSet(total_pr,0.0);
      GlobalVariableSet(total_g,0.0);

      tradeOn=true;
     }

   GlobalVariableSet(gv_today_prev,GlobalVariableGet(gv_today));

   MytradeTransaction();
   ProtectPosition();
   CheckConnection();
   RefreshRates();
   if(GetIndValue())
     {
      msg_erro="Error in obtain indicators buffers or price rates";
      Print(msg_erro);
      Alert(msg_erro);
      return;
     }

   ExtDialog.OnTick();
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   lucro_total=LucroOrdens()+LucroPositions();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      if(OrdersTotal()>0)DeleteALL();
      CloseALL();
      tradeOn=false;
      informacoes="EA encerrado lucro ou prejuizo";
     }

   if(LimitTotGainLoss)
     {
      if(GlobalVariableGet(total_g)>=max_gain || GlobalVariableGet(total_pr)>=max_loss)
        {

         if(OrdersTotal()>0)DeleteALL();
         CloseALL();
         tradeOn=false;
         informacoes="EA encerrado Número de Loss ou Gains Consecutivos";
        }
     }
   timerOn=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final;
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
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened())CloseByPosition();
   if(!PosicaoAberta())DeleteOrdersExEntry();
   Atual_vol_Stop_Take();

   if(tradeOn && timerOn)

     {// inicio Trade On

      static datetime LastBar=0;
      datetime ThisBar=iTime(Symbol(),periodoRobo,0);
      if(LastBar!=ThisBar)
        {
         PrintFormat("New bar. Opening time: %s  Time of last tick: %s",
                     TimeToString((datetime)ThisBar,TIME_SECONDS),
                     TimeToString(TimeCurrent(),TIME_SECONDS));
         LastBar=ThisBar;

         GlobalVariableSet(tradebuy,0.0);
         GlobalVariableSet(tradesell,0.0);
         if(!PosicaoAberta())DeleteALL();

         if(myorder.Select((ulong)GlobalVariableGet(cp_tick)))mytrade.OrderDelete((ulong)GlobalVariableGet(cp_tick));
         if(myorder.Select((ulong)GlobalVariableGet(vd_tick)))mytrade.OrderDelete((ulong)GlobalVariableGet(vd_tick));

        }//End NewBar

      if(BuySignal() && !Buy_opened())
        {

         if(Sell_opened())
           {
            myorder.Select((ulong)GlobalVariableGet(stp_cp_tick));
            price_stop=myorder.PriceOpen();
           }
         else price_stop=0;
         if(GlobalVariableGet(tradebuy)==0.0 && high[1]+ticksize>price_stop)
           {
            if(ask<high[1]+ticksize)
              {

               if(mytrade.BuyStop(CalcLote(),NormalizeDouble(high[1]+ticksize,digits),Symbol(),0,0,0,0,"BUY"+exp_name))
                 {
                  GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
                  GlobalVariableSet(tradebuy,1.0);
                  GlobalVariableSet(tradesell,1.0);
                 }
               else Print("ERROR ",GetLastError());
              }
            else
              {
               mytrade.Buy(CalcLote(),Symbol(),0,0,0,"BUY"+exp_name);

               GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
               GlobalVariableSet(tradebuy,1.0);
               GlobalVariableSet(tradesell,1.0);
              }

           }
        }
      //---- Getting sell signals
      if(SellSignal() && !Sell_opened())
        {

         if(Buy_opened())
           {
            myorder.Select((ulong)GlobalVariableGet(stp_vd_tick));
            price_stop=myorder.PriceOpen();
           }
         else price_stop=0;

         if(GlobalVariableGet(tradesell)==0.0 && (low[1]-ticksize<price_stop || price_stop==0))
           {
            if(bid>low[1]-ticksize)
              {
               if(mytrade.SellStop(CalcLote(),NormalizeDouble(low[1]-ticksize,digits),Symbol(),0,0,0,0,"SELL"+exp_name))
                 {
                  GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
                  GlobalVariableSet(tradesell,1.0);
                  GlobalVariableSet(tradebuy,1.0);

                 }
               else Print("ERROR ",GetLastError());
              }

            else
              {
               mytrade.Sell(CalcLote(),Symbol(),0,0,0,"SELL"+exp_name);
               GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
               GlobalVariableSet(tradesell,1.0);
               GlobalVariableSet(tradebuy,1.0);

              }
           }
        }

      if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);
      if(UseBreakEven && PosicaoAberta())BreakEven(original_symbol,UseBreakEven,PointBreakEven,PointProfit);

     }//End Trade On

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
   bool signal=low[0]<low[1];
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   bool signal=high[0]>high[1];
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
         double openPrice=NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
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
                  mytrade.OrderModify((ulong)GlobalVariableGet(stp_vd_tick),trailStopPrice,0,0,0,0,0);
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

            if((trailStopPrice<currentStop-step || currentStop==0) && currentProfit>=minProfit)
              {
               //mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
               if(myorder.Select((ulong)GlobalVariableGet(stp_cp_tick)))
                 {
                  mytrade.OrderModify((ulong)GlobalVariableGet(stp_cp_tick),trailStopPrice,0,0,0,0,0);
                 }

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
   ulong deals_ticket;

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

      GlobalVariableSet(deals_total,(double)cont_deals);

      if(GlobalVariableGet(deals_total)>GlobalVariableGet(deals_total_prev))
        {
         GlobalVariableSet(deals_total_prev,GlobalVariableGet(deals_total));
         if(deals_ticket>0)
           {
            mydeal.Ticket(deals_ticket);
            order_ticket=mydeal.Order();
            if(mydeal.Comment()=="BUY"+exp_name || mydeal.Comment()=="SELL"+exp_name)
              {
               GlobalVariableSet(glob_entr_tot,GlobalVariableGet(glob_entr_tot)+1);
              }

            if(order_ticket==(ulong)GlobalVariableGet(cp_tick))

              {

               Real_Parc_Buy(CalcLote());
               myposition.SelectByTicket(order_ticket);
               buyprice=NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
               lots_take=CalcLote()-lts_rp1-lts_rp2-lts_rp3;
               if(lots_take>0)
                 {
                  mytrade.SellLimit(lots_take,NormalizeDouble(buyprice+_TakeProfit*ponto,digits),original_symbol,0,0,0,0,"TAKE PROFIT");
                  GlobalVariableSet(tp_vd_tick,(double)mytrade.ResultOrder());
                 }
               mytrade.SellStop(CalcLote(),NormalizeDouble(buyprice-_Stop*ponto,digits),original_symbol,0,0,0,0,"STOP");
               GlobalVariableSet(stp_vd_tick,(double)mytrade.ResultOrder());
              }
            //--------------------------------------------------

            if(order_ticket==(ulong)GlobalVariableGet(vd_tick))
              {
               Real_Parc_Sell(CalcLote());
               myposition.SelectByTicket(order_ticket);
               sellprice=NormalizeDouble(MathRound(myposition.PriceOpen()/ticksize)*ticksize,digits);
               lots_take=CalcLote()-lts_rp1-lts_rp2-lts_rp3;
               if(lots_take>0)
                 {
                  mytrade.BuyLimit(lots_take,NormalizeDouble(sellprice-_TakeProfit*ponto,digits),original_symbol,0,0,0,0,"TAKE PROFIT");
                  GlobalVariableSet(tp_cp_tick,(double)mytrade.ResultOrder());
                 }
               mytrade.BuyStop(CalcLote(),NormalizeDouble(sellprice+_Stop*ponto,digits),original_symbol,0,0,0,0,"STOP");
               GlobalVariableSet(stp_cp_tick,(double)mytrade.ResultOrder());
              }

            Print(mydeal.Comment());
            if(mydeal.Comment()=="STOP")
              {
               if(GlobalVariableGet(last_deal_pr)==-1.0)GlobalVariableSet(total_pr,GlobalVariableGet(total_pr)+1);
               GlobalVariableSet(glob_mart,GlobalVariableGet(glob_mart)+1);
               GlobalVariableSet(last_deal_pr,-1.0);
               GlobalVariableSet(total_g,0.0);

               if(order_ticket==(ulong)GlobalVariableGet(stp_vd_tick) && mydeal.Price()<low[1])
                 {
                  DeleteALL();
                  if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened())CloseByPosition();

                  mytrade.Sell(CalcLote(),original_symbol,0,0,0,"SELL"+exp_name);
                  GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
                 }

               if(order_ticket==(ulong)GlobalVariableGet(stp_cp_tick) && mydeal.Price()>high[1])
                 {
                  DeleteALL();
                  if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened())CloseByPosition();
                  mytrade.Buy(CalcLote(),original_symbol,0,0,0,"BUY"+exp_name);
                  GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
                 }

              }

            if(lots_take>0 && mydeal.Comment()=="TAKE PROFIT")
              {
               if(GlobalVariableGet(last_deal_pr)==1.0)GlobalVariableSet(total_g,GlobalVariableGet(total_g)+1);
               GlobalVariableSet(glob_mart,0.0);
               GlobalVariableSet(last_deal_pr,1.0);
               GlobalVariableSet(total_pr,0.0);
              }

            if(lots_take==0)
              {
               if(lts_rp3>0 && mydeal.Comment()=="PARCIAL 3")
                 {
                  if(GlobalVariableGet(last_deal_pr)==1.0)GlobalVariableSet(total_g,GlobalVariableGet(total_g)+1);
                  GlobalVariableSet(glob_mart,0.0);
                  GlobalVariableSet(last_deal_pr,1.0);
                  GlobalVariableSet(total_pr,0.0);
                 }
               if(lts_rp3==0 && lts_rp2>0 && mydeal.Comment()=="PARCIAL 2")
                 {
                  if(GlobalVariableGet(last_deal_pr)==1.0)GlobalVariableSet(total_g,GlobalVariableGet(total_g)+1);
                  GlobalVariableSet(glob_mart,0.0);
                  GlobalVariableSet(last_deal_pr,1.0);
                  GlobalVariableSet(total_pr,0.0);
                 }
               if(lts_rp3==0 && lts_rp2==0 && lts_rp1>0 && mydeal.Comment()=="PARCIAL 1")
                 {
                  if(GlobalVariableGet(last_deal_pr)==1.0)GlobalVariableSet(total_g,GlobalVariableGet(total_g)+1);
                  GlobalVariableSet(glob_mart,0.0);
                  GlobalVariableSet(last_deal_pr,1.0);
                  GlobalVariableSet(total_pr,0.0);
                 }

              }

           }// if dealsticket>0
        }//Fim deals>prev
     }//Fim HistorySelect

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
     }
   updatedata=symbol_refresh;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Atual_vol_Stop_Take()
  {

   if(PosicaoAberta())
     {
      if(Buy_opened())
        {
         if(myposition.SelectByTicket((int)GlobalVariableGet(cp_tick)) && myorder.Select((int)GlobalVariableGet(stp_vd_tick)))
           {
            vol_pos=VolPosType(POSITION_TYPE_BUY);
            vol_stp=myorder.VolumeInitial();
            preco_stp=myorder.PriceOpen();

            if(vol_pos!=vol_stp)
              {
               mytrade.OrderDelete((int)GlobalVariableGet(stp_vd_tick));
               mytrade.SellStop(vol_pos,preco_stp,Symbol(),0,0,0,0,"STOP");
               GlobalVariableSet(stp_vd_tick,(double)mytrade.ResultOrder());
              }
           }
/*
         if(myposition.SelectByTicket((int)GlobalVariableGet(cp_tick)) && myorder.Select((int)GlobalVariableGet(tp_vd_tick)))
           {
            vol_pos=VolPosType(POSITION_TYPE_BUY);
            vol_stp=myorder.VolumeInitial();
            preco_stp=myorder.PriceOpen();

            if(vol_pos!=vol_stp)
              {
               mytrade.OrderDelete((int)GlobalVariableGet(tp_vd_tick));
               mytrade.SellLimit(vol_pos,preco_stp,original_symbol,0,0,0,0,"TAKE PROFIT");
               GlobalVariableSet(tp_vd_tick,(double)mytrade.ResultOrder());
              }
           }
           */

        }
      if(Sell_opened())
        {
         if(myposition.SelectByTicket((int)GlobalVariableGet(vd_tick)) && myorder.Select((int)GlobalVariableGet(stp_cp_tick)))
           {
            vol_pos=VolPosType(POSITION_TYPE_SELL);
            vol_stp=myorder.VolumeInitial();
            preco_stp=myorder.PriceOpen();

            if(vol_pos!=vol_stp)
              {
               mytrade.OrderDelete((int)GlobalVariableGet(stp_cp_tick));
               mytrade.BuyStop(vol_pos,preco_stp,Symbol(),0,0,0,0,"STOP");
               GlobalVariableSet(stp_cp_tick,(double)mytrade.ResultOrder());

              }
           }
/*
         if(myposition.SelectByTicket((int)GlobalVariableGet(vd_tick)) && myorder.Select((int)GlobalVariableGet(tp_cp_tick)))
           {
            vol_pos=VolPosType(POSITION_TYPE_SELL);
            vol_stp=myorder.VolumeInitial();
            preco_stp=myorder.PriceOpen();

            if(vol_pos!=vol_stp)
              {
               mytrade.OrderDelete((int)GlobalVariableGet(tp_cp_tick));
               mytrade.BuyLimit(vol_pos,preco_stp,original_symbol,0,0,0,0,"TAKE PROFIT");
               GlobalVariableSet(tp_cp_tick,(double)mytrade.ResultOrder());

              }
           }
           */
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
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
void DeleteOrdersExEntry()
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.Comment()!="SELL"+exp_name && myorder.Comment()!="BUY"+exp_name)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+
double PrecoMedio(ENUM_POSITION_TYPE ptype)
  {
   double vol=0;
   double preco=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype && myposition.Symbol()==mysymbol.Name())
        {
         vol+=myposition.Volume();
         preco+=myposition.Volume()*myposition.PriceOpen();
        }
     }
   preco=preco/VolPosType(ptype);
   preco=NormalizeDouble(MathRound(preco/ticksize)*ticksize,digits);
   return preco;
  }
//+------------------------------------------------------------------+
double CalcLote()
  {
   double lote=Lot;
   if(Martingale && GlobalVariableGet(glob_mart)>0)lote=NormalizeDouble(MathRound((pow(mult_mart,GlobalVariableGet(glob_mart)))*Lot/mysymbol.LotsStep())*mysymbol.LotsStep(),2);

   return lote;
  }
//+------------------------------------------------------------------+
void Real_Parc_Buy(double vol)
  {
   lts_rp1=0;
   lts_rp2=0;
   lts_rp3=0;
   if(vol>mysymbol.LotsMin())
     {
      myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick));
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
         // mytrade.PositionModify((ulong)GlobalVariableGet(cp_tick),myposition.StopLoss(),0);
         //  mytrade.OrderDelete((ulong)GlobalVariableGet(tp_vd_tick));
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
            //  mytrade.PositionModify((ulong)GlobalVariableGet(cp_tick),myposition.StopLoss(),0);
            //       mytrade.OrderDelete((ulong)GlobalVariableGet(tp_vd_tick));

           }
        }

      if(rp1>0&&lts_rp1>0)mytrade.SellLimit(lts_rp1,NormalizeDouble(MathRound((myposition.PriceOpen()+rp1*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,0,0,"PARCIAL 1");
      if(rp2>0&&lts_rp2>0)mytrade.SellLimit(lts_rp2,NormalizeDouble(MathRound((myposition.PriceOpen()+rp2*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,0,0,"PARCIAL 2");
      if(rp3>0&&lts_rp3>0)mytrade.SellLimit(lts_rp3,NormalizeDouble(MathRound((myposition.PriceOpen()+rp3*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,0,0,"PARCIAL 3");


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Real_Parc_Sell(double vol)
  {
   lts_rp1=0;
   lts_rp2=0;
   lts_rp3=0;
   if(vol>mysymbol.LotsMin())
     {
      myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick));
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
         // mytrade.PositionModify((ulong)GlobalVariableGet(cp_tick),myposition.StopLoss(),0);
         //  mytrade.OrderDelete((ulong)GlobalVariableGet(tp_cp_tick));
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
            //  mytrade.PositionModify((ulong)GlobalVariableGet(cp_tick),myposition.StopLoss(),0);
            //   mytrade.OrderDelete((ulong)GlobalVariableGet(tp_cp_tick));

           }
        }
      if(rp1>0&&lts_rp1>0)mytrade.BuyLimit(lts_rp1,NormalizeDouble(MathRound((myposition.PriceOpen()-rp1*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,0,0,"PARCIAL 1");
      if(rp2>0&&lts_rp2>0)mytrade.BuyLimit(lts_rp2,NormalizeDouble(MathRound((myposition.PriceOpen()-rp2*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,0,0,"PARCIAL 2");
      if(rp3>0&&lts_rp3>0)mytrade.BuyLimit(lts_rp3,NormalizeDouble(MathRound((myposition.PriceOpen()-rp3*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,0,0,"PARCIAL 3");


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
            for(int k=0;k<2;k++)
              {
               if(currentProfit>=pBreakEven[k]*ponto && currentProfit<pBreakEven[k+1]*ponto)
                 {
                  breakEvenStop=openPrice+pLockProfit[k]*ponto;
                  breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
                  if(currentSL<breakEvenStop || currentSL==0)
                    {
                     if(k==0)Print("Break even stop 1:");
                     else Print("Break even stop 2:");
                     // mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                     mytrade.OrderModify((ulong)GlobalVariableGet(stp_vd_tick),breakEvenStop,0,0,0,0,0);
                     Print("");

                    }
                 }
              }
            //----------------------
            //Break Even 2
            if(currentProfit>=pBreakEven[2]*ponto)
              {
               breakEvenStop=openPrice+pLockProfit[2]*ponto;
               breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
               if(currentSL<breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop 3:");
                  // mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                  mytrade.OrderModify((ulong)GlobalVariableGet(stp_vd_tick),breakEvenStop,0,0,0,0,0);
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
            for(int k=0;k<2;k++)
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
                     mytrade.OrderModify((ulong)GlobalVariableGet(stp_cp_tick),breakEvenStop,0,0,0,0,0);
                     Print("");

                    }
                 }
              }
            //----------------------
            //Break Even 2
            if(currentProfit>=pBreakEven[2]*ponto)
              {
               breakEvenStop=openPrice-pLockProfit[2]*ponto;
               breakEvenStop=NormalizeDouble(MathRound(breakEvenStop/ticksize)*ticksize,digits);
               if(currentSL>breakEvenStop || currentSL==0)
                 {
                  Print("Break even stop 3:");
                  // mytrade.PositionModify(posTicket,breakEvenStop,currentTP);
                  mytrade.OrderModify((ulong)GlobalVariableGet(stp_cp_tick),breakEvenStop,0,0,0,0,0);

                 }

              }
            //----------------------

           }

        } //Fim Position Select

     }//Fim for
  }
//+------------------------------------------------------------------+
void ProtectPosition()
  {
   ulong ticket;
   if(mysymbol.Bid()==0||mysymbol.Ask()==0) return;
   if(Buy_opened() && !Sell_opened())
     {
      ticket=TickecBuyPos();
      myposition.SelectByTicket(ticket);
      if(mysymbol.Ask()<=NormalizeDouble(myposition.PriceOpen()-_Stop*ponto-6*ticksize,digits))
        {
         DeleteALL();
         mytrade.PositionClose(ticket);
        }

      if(mysymbol.Bid()>=NormalizeDouble(myposition.PriceOpen()+_TakeProfit*ponto+6*ticksize,digits))
        {
         DeleteALL();
         mytrade.PositionClose(ticket);
        }
     }
   if(Sell_opened() && !Buy_opened())
     {
      ticket=TickecSellPos();
      myposition.SelectByTicket(ticket);
      if(mysymbol.Bid()>=NormalizeDouble(myposition.PriceOpen()+_Stop*ponto+6*ticksize,digits))
        {
         DeleteALL();
         mytrade.PositionClose(ticket);
        }

      if(mysymbol.Ask()<=NormalizeDouble(myposition.PriceOpen()-_TakeProfit*ponto-6*ticksize,digits))
        {
         DeleteALL();
         mytrade.PositionClose(ticket);
        }

     }
  }
//+------------------------------------------------------------------+
