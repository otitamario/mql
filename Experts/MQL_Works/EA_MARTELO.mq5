//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+


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


   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"ENTRADAS NO DIA: "+IntegerToString(ENTRADAS_TOTAL),xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;
   string str_pos;
   if(!PosicaoAberta())str_pos="ZERADO";
   if(Buy_opened()&&myposition.SelectByTicket(compra1_ticket))str_pos="COMPRADO";
   if(Sell_opened()&&myposition.SelectByTicket(venda1_ticket))str_pos="VENDIDO";

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
   m_label[1].Text("ENTRADAS NO DIA: "+IntegerToString(ENTRADAS_TOTAL));
   string str_pos;
   if(!PosicaoAberta())str_pos="ZERADO";
   if(Buy_opened()&&myposition.SelectByTicket(compra1_ticket))str_pos="COMPRADO";
   if(Sell_opened()&&myposition.SelectByTicket(venda1_ticket))str_pos="VENDIDO";

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
CControlsDialog ExtDialog;
// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=20082018;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input double Lot=2;//Lote Entrada
input double _TakeProfit=20000; //Take Profit em Pontos

sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes no Dia

sinput string shorario="############------FILTRO DE HORARIO------#################";

input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:00";//Horario Inicial
input string end_hour="17:30";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario

sinput string sindicators="############------Martelo------#################";
input double mult_sombra=1.5;//Sombra vezes corpo

sinput string STrailing="############---------------Trailing Stop----------########";

input bool   Use_TraillingStop=true; //Usar Trailing 
input int TraillingStart=2000;//Lucro Minimo Iniciar trailing stop
input int TraillingDistance=2000;// Distanccia em Pontos do Stop Loss
input int TraillingStep=500;// Passo para atualizar Stop Loss

input bool UsarRealizParc=true;//Usar Realização Parcial
input double DistanceRealizeParcial=2000;//Distância Realização Parcial em Pontos
input double porc_parcial=0.5;//Porcentagem Lotes Realização Parcial

                              //Variaveis 
string original_symbol;
double ask,bid;
double lucro_total,pontos_total,lucro_entry;
bool timerOn,tradeOn;
double ponto,ticksize,digits;
long curChartID;
double high[],low[],open[],close[];
ulong ENTRADAS_TOTAL,MART_LEVEL;
ulong trade_ticket,compra1_ticket,venda1_ticket,stp_venda_ticket,stp_compra_ticket,tp_venda_ticket,tp_compra_ticket;
double price_open;
string glob_entr_tot="ENT_TOT"+Symbol()+IntegerToString(Magic_Number);
string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string tp_vd_tick="tp_vd_tick"+Symbol()+IntegerToString(Magic_Number),tp_cp_tick="tp_cp_tick"+Symbol()+IntegerToString(Magic_Number);
string stp_vd_tick="stp_vd_tick"+Symbol()+IntegerToString(Magic_Number),stp_cp_tick="stp_cp_tick"+Symbol()+IntegerToString(Magic_Number);

double buyprice,sellprice,oldprice;
string informacoes=" ";
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
int PrevPositions;
datetime time_novodia[4];
double lotes_stop;
int res_code;
int cont;
datetime hora_inicial,hora_final;
double preco_take;
double tp_position,sl_position;
int OrdersPrev=0;
int PositionsPrev=0;
ulong LastOrderTicket=0; // Ingresso da última ordem processada
int _GetLastError=0;       // Erro no código
long state=0;              // Estado da ordem
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   original_symbol=Symbol();
   tradeOn=true;
   trade_ticket=0;
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
   OrdersPrev=OrdersTotal();
   PositionsPrev=PositionsTotal();
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

   if(Lot<=0)
     {
      string erro="Lote deve ser maior que 0";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);

     }
   if(UsarRealizParc && Lot<=mysymbol.LotsMin())
     {
      string erro="Para Usar Realização Parcial o Lote deve ser maior que 1";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

//Global Variables Check

   if(!GlobalVariableCheck(glob_entr_tot))GlobalVariableSet(glob_entr_tot,0.0);
   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0.0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0.0);
   if(!GlobalVariableCheck(stp_vd_tick))GlobalVariableSet(stp_vd_tick,0);
   if(!GlobalVariableCheck(stp_cp_tick))GlobalVariableSet(stp_cp_tick,0);
   if(!GlobalVariableCheck(tp_vd_tick))GlobalVariableSet(tp_vd_tick,0);
   if(!GlobalVariableCheck(tp_cp_tick))GlobalVariableSet(tp_cp_tick,0);

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
void OnTimer()
  {
   if(myorder.Select(compra1_ticket))mytrade.OrderDelete(compra1_ticket);
   if(myorder.Select(venda1_ticket))mytrade.OrderDelete(venda1_ticket);
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeletaIndicadores();
   ExtDialog.Destroy(reason);
   HLineDelete(0,"Abertura");
   HLineDelete(0,"Stop Loss");
   HLineDelete(0,"Take Profit");
   Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");

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
//| TradeTransaction function                                        | 
//+------------------------------------------------------------------+ 
void MytradeTransaction()
  {

   double sl_position,tp_position;
//requisita o histórico para os últimos 2 dias 
   if(!GetTradeHistory(2))
     {
      //--- notificar sobre chamada sem sucesso e retorno -1 
      Print(__FUNCTION__," HistorySelect() retornou false");
     }

   if(OrdersPrev<OrdersTotal())
     {
      // Ordem apareceu
      LastOrderTicket=GetLastOrderTicket();

     }
   else if(OrdersPrev>OrdersTotal() || PositionsPrev<PositionsTotal())
     {
      // Ordem desaparaceu
      LastOrderTicket=GetLastOrderTicket();

      state=HistoryOrderGetInteger(LastOrderTicket,ORDER_STATE);

      // Se a ordem não for encontrado, gerar um erro
      _GetLastError=GetLastError();
      if(_GetLastError!=0){Alert("Erro #",_GetLastError," ordem não encontrada!");LastOrderTicket=0;}
      Print("Erro #",_GetLastError," state: ",state);ResetLastError();

      // Se a ordem foi totalmente executada
      if(state==ORDER_STATE_FILLED)
        {
         // Então analise o último negócio
         // --
         if(LastOrderTicket==compra1_ticket || LastOrderTicket==venda1_ticket)
           {
            ENTRADAS_TOTAL++;
            GlobalVariableSet(glob_entr_tot,(double)ENTRADAS_TOTAL);
           }

         if(LastOrderTicket==compra1_ticket && state==ORDER_STATE_FILLED)

           {
            HLineDelete(0,"Abertura");
            HLineDelete(0,"Stop Loss");
            HLineDelete(0,"Take Profit");

            if(myorder.Select(venda1_ticket))mytrade.OrderDelete(venda1_ticket);
            myposition.SelectByTicket(compra1_ticket);
            buyprice=myposition.PriceOpen();
            sl_position=NormalizeDouble(low[1]-ticksize,digits);
            tp_position=NormalizeDouble(buyprice+_TakeProfit*ponto,digits);
            mytrade.SellLimit(Lot,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT");
            tp_venda_ticket=mytrade.ResultOrder();
            GlobalVariableSet(tp_vd_tick,(double)tp_venda_ticket);
            //Stop para posição comprada
            sellprice=sl_position;
            oldprice=PriceLastStopOrder(ORDER_TYPE_SELL_STOP);
            if(oldprice==-1 || sellprice>oldprice && Buy_opened()) // No order or New price is better
              {
               DeleteOrders(ORDER_TYPE_SELL_STOP);
               mytrade.SellStop(Lot,sellprice,original_symbol,0,0,0,0,"STOP"+exp_name);
               stp_venda_ticket=mytrade.ResultOrder();
               GlobalVariableSet(stp_vd_tick,(double)stp_venda_ticket);
              }
            HLineCreate(0,"Abertura",0,buyprice,clrAqua,STYLE_SOLID,2,false,false,true,0);
            HLineCreate(0,"Stop Loss",0,sellprice,clrRed,STYLE_SOLID,2,false,false,true,0);
            HLineCreate(0,"Take Profit",0,tp_position,clrLime,STYLE_SOLID,2,false,false,true,0);

           }
         //--------------------------------------------------

         if(LastOrderTicket==venda1_ticket && state==ORDER_STATE_FILLED)
           {

            HLineDelete(0,"Abertura");
            HLineDelete(0,"Stop Loss");
            HLineDelete(0,"Take Profit");

            if(myorder.Select(compra1_ticket))mytrade.OrderDelete(compra1_ticket);
            myposition.SelectByTicket(venda1_ticket);
            sellprice=myposition.PriceOpen();
            sl_position=NormalizeDouble(high[1]+ticksize,digits);
            tp_position=NormalizeDouble(sellprice-_TakeProfit*ponto,digits);
            mytrade.BuyLimit(Lot,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT");
            tp_compra_ticket=mytrade.ResultOrder();
            GlobalVariableSet(tp_cp_tick,(double)tp_compra_ticket);
            buyprice=sl_position;
            oldprice=PriceLastStopOrder(ORDER_TYPE_BUY_STOP);
            if(oldprice==-1 || buyprice<oldprice && Sell_opened()) // No order or New price is better
              {
               DeleteOrders(ORDER_TYPE_BUY_STOP);
               mytrade.BuyStop(Lot,buyprice,original_symbol,0,0,0,0,"STOP"+exp_name);
               stp_compra_ticket=mytrade.ResultOrder();
               GlobalVariableSet(stp_cp_tick,(double)stp_compra_ticket);
              }

            HLineCreate(0,"Abertura",0,sellprice,clrAqua,STYLE_SOLID,2,false,false,true,0);
            HLineCreate(0,"Stop Loss",0,buyprice,clrRed,STYLE_SOLID,2,false,false,true,0);
            HLineCreate(0,"Take Profit",0,tp_position,clrLime,STYLE_SOLID,2,false,false,true,0);

           }
         //--------------------------------------------------

         // Fechar Ordens e Posicoes

         if(LastOrderTicket==stp_compra_ticket && state==ORDER_STATE_FILLED)
           {
            informacoes="Posicao Fechada por Ordem Buy Stop";
            DeleteALL();;
            Print(informacoes);
            if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
              {
               res_code=-1;
               cont=0;
               while(res_code<=0 && cont<TENTATIVAS)
                 {
                  mytrade.PositionCloseBy(venda1_ticket,stp_compra_ticket);
                  res_code=mytrade.ResultOrder();
                  Print("RES_CODE ",res_code);
                  cont+=1;;
                 }
              }

           }

         if(LastOrderTicket==stp_venda_ticket && state==ORDER_STATE_FILLED)
           {
            informacoes="Posicao Fechada por Ordem Sell Stop";
            DeleteALL();;
            Print(informacoes);
            if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
              {
               res_code=-1;
               cont=0;
               while(res_code<=0 && cont<TENTATIVAS)
                 {
                  mytrade.PositionCloseBy(compra1_ticket,stp_venda_ticket);
                  res_code=mytrade.ResultOrder();
                  Print("RES_CODE ",res_code);
                  cont+=1;;
                 }
              }
           }

         if(LastOrderTicket==tp_compra_ticket && state==ORDER_STATE_FILLED)
           {
            informacoes="Posicao Fechada por Take Profit";
            DeleteALL();
            Print(informacoes);
            if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
              {
               res_code=-1;
               cont=0;
               while(res_code<=0 && cont<TENTATIVAS)
                 {
                  mytrade.PositionCloseBy(venda1_ticket,tp_compra_ticket);
                  res_code=mytrade.ResultOrder();
                  Print("RES_CODE ",res_code);
                  cont+=1;
                 }
              }
           }
         if(LastOrderTicket==tp_venda_ticket && state==ORDER_STATE_FILLED)
           {
            informacoes="Posicao Fechada por Take Profit";
            DeleteALL();
            Print(informacoes);
            if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
              {
               res_code=-1;
               cont=0;
               while(res_code<=0 && cont<TENTATIVAS)
                 {
                  mytrade.PositionCloseBy(compra1_ticket,tp_venda_ticket);
                  res_code=mytrade.ResultOrder();
                  Print("RES_CODE ",res_code);
                  cont+=1;
                 }
              }

           }

        }

     }
   OrdersPrev=OrdersTotal();
   PositionsPrev=PositionsTotal();

  }
//+------------------------------------------------------------------+ 
//| Retorna o último ticket de ordem em histórico ou -1              | 
//+------------------------------------------------------------------+ 
ulong GetLastOrderTicket()
  {
//requisita o histórico para os últimos 2 dias 
   if(!GetTradeHistory(2))
     {
      //--- notificar sobre chamada sem sucesso e retorno -1 
      Print(__FUNCTION__," HistorySelect() retornou false");
      return -1;
     }
//---  
   ulong first_order,last_order,orders=HistoryOrdersTotal();
//--- trabalhar com ordens se houver alguma 
   if(orders>0)
     {
      Print("Ordens = ",orders);
      first_order=HistoryOrderGetTicket(0);
      PrintFormat("first_order = %d",first_order);
      if(orders>1)
        {
         last_order=HistoryOrderGetTicket((int)orders-1);
         PrintFormat("last_order = %d",last_order);
         return last_order;
        }
      return first_order;
     }
//--- nenhuma ordem encontrada, retornar -1 
   return -1;
  }
//+---------------------------------------------------------------------------------+ 
//| Solicitações de histórico para os últimos dias e retorna false em caso de falha | 
//+---------------------------------------------------------------------------------+ 
bool GetTradeHistory(int days)
  {
//--- define um período da semana para solicitar histórico da operação 
   datetime to=TimeCurrent();
   datetime from=to-days*PeriodSeconds(PERIOD_D1);
   ResetLastError();
//--- fazer um pedido e verificar o resultado 
   if(!HistorySelect(from,to))
     {
      Print(__FUNCTION__," HistorySelect=false. Código de erro=",GetLastError());
      return false;
     }
//--- histórico recebido com sucesso 
   return true;
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
   MytradeTransaction();
   mysymbol.Refresh();
   mysymbol.RefreshRates();
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
      GlobalVariableSet(glob_entr_tot,0);

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
      HLineDelete(0,"Abertura");
      HLineDelete(0,"Stop Loss");
      HLineDelete(0,"Take Profit");

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

      HLineDelete(0,"Abertura");
      HLineDelete(0,"Stop Loss");
      HLineDelete(0,"Take Profit");

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


   ENTRADAS_TOTAL=(int)GlobalVariableGet(glob_entr_tot);
   compra1_ticket=(int) GlobalVariableGet(cp_tick);
   venda1_ticket=(int) GlobalVariableGet(vd_tick);
   stp_compra_ticket=(int) GlobalVariableGet(stp_cp_tick);
   stp_venda_ticket=(int) GlobalVariableGet(stp_vd_tick);
   tp_compra_ticket=(int) GlobalVariableGet(tp_cp_tick);
   tp_venda_ticket=(int) GlobalVariableGet(tp_vd_tick);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(tradeOn && timerOn)

     {// inicio Trade On

      if(!PosicaoAberta())
        {
         HLineDelete(0,"Abertura");
         HLineDelete(0,"Stop Loss");
         HLineDelete(0,"Take Profit");
        }
      if(NewBar.CheckNewBar(Symbol(),periodoRobo))
        {

         if(BuySignal() && !Buy_opened())
           {
            if(Sell_opened())ClosePosType(POSITION_TYPE_SELL);
            DeleteALL();
            mytrade.BuyStop(Lot,NormalizeDouble(high[1]+ticksize,digits),original_symbol,0,0,0,0,"BUY"+exp_name);
            compra1_ticket=mytrade.ResultOrder();
            GlobalVariableSet(cp_tick,(double)compra1_ticket);
            EventSetTimer(3*PeriodSeconds());
           }

         if(SellSignal() && !Sell_opened())
           {
            if(Buy_opened())ClosePosType(POSITION_TYPE_BUY);
            DeleteALL();
            mytrade.SellStop(Lot,NormalizeDouble(low[1]-ticksize,digits),original_symbol,0,0,0,0,"SELL"+exp_name);
            venda1_ticket=mytrade.ResultOrder();
            GlobalVariableSet(vd_tick,(double)venda1_ticket);
            EventSetTimer(3*PeriodSeconds());

           }
        }//End NewBar
      if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);
      if(UsarRealizParc)RealizacaoParcial();

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

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   b_signal=low[1]<low[2] && MarteloUp();
   return b_signal;
  }
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   bool s_signal;
   s_signal=high[1]>high[2] && MarteloDown();
   return s_signal;
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
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

void CloseALL()
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//------------------------------------------------------------------------

void ClosePosType(ENUM_POSITION_TYPE ptype)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
//| Criar a linha horizontal                                         | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long            chart_ID=0,// ID de gráfico 
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
//| Excluir uma linha horizontal                                     | 
//+------------------------------------------------------------------+ 
bool HLineDelete(const long   chart_ID=0,// ID do gráfico 
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool HLineMove(const long   chart_ID=0,// ID do gráfico 
               const string name="HLine", // nome da linha 
               double       price=0)      // preço da linha 
  {
//--- se o preço não está definido, defina-o no atual nível de preço Bid 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- redefine o valor de erro 
   ResetLastError();
//--- mover um linha horizontal  
   if(!ObjectMove(chart_ID,name,0,0,price))
     {
      Print(__FUNCTION__,
            ": falha ao mover um linha horizontal! Código de erro = ",GetLastError());
      return(false);
     }
//--- sucesso na execução 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Corpo()
  {
   return MathAbs(open[1]-close[1]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SombraUp()
  {
   return high[1]-MathMax(open[1],close[1]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double SombraDown()
  {
   return MathMin(open[1],close[1])-low[1];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MarteloUp()
  {
   return SombraDown()>=mult_sombra*Corpo()&&SombraUp()==0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MarteloDown()
  {
   return SombraUp()>=mult_sombra*Corpo()&&SombraDown()==0;
  }
//+------------------------------------------------------------------+

void RealizacaoParcial()
  {
   double currentProfit,currentStop,preco,novostop;
   double sellprice,buyprice,tp_position;
   double lote_parcial;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
        {
         currentStop=myposition.StopLoss();
         preco=myposition.PriceOpen();
         if(myposition.PositionType()==POSITION_TYPE_BUY)
           {
            currentProfit=bid-preco;
            if(currentProfit>=DistanceRealizeParcial*_Point && myposition.Volume()==Lot)
              {
               lote_parcial=MathMax(mysymbol.LotsMin(),MathFloor(porc_parcial*myposition.Volume()));
               if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)mytrade.PositionClosePartial(myposition.Ticket(),lote_parcial);
               else mytrade.Sell(lote_parcial);
               Print("Venda Saída Parcial : ");
               myorder.Select(stp_venda_ticket);
               sellprice=myorder.PriceOpen();
               mytrade.OrderDelete(stp_venda_ticket);
               mytrade.SellStop(Lot-lote_parcial,sellprice,Symbol(),0,0,0,0,"STOP"+exp_name);
               stp_venda_ticket=mytrade.ResultOrder();
               GlobalVariableSet(stp_vd_tick,(double)stp_venda_ticket);
               myorder.Select(tp_venda_ticket);
               tp_position=myorder.PriceOpen();
               mytrade.OrderDelete(tp_venda_ticket);
               mytrade.SellLimit(Lot-lote_parcial,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT");
               tp_venda_ticket=mytrade.ResultOrder();
               GlobalVariableSet(tp_vd_tick,(double)tp_venda_ticket);
              }
           }

         if(myposition.PositionType()==POSITION_TYPE_SELL)
           {
            currentProfit=preco-ask;

            if(currentProfit>=DistanceRealizeParcial*_Point && myposition.Volume()==Lot)
              {
               lote_parcial=MathMax(mysymbol.LotsMin(),MathFloor(porc_parcial*myposition.Volume()));
               if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)mytrade.PositionClosePartial(myposition.Ticket(),lote_parcial);
               else mytrade.Buy(lote_parcial);
               Print("Compra Saída Parcial : ");
               myorder.Select(stp_compra_ticket);
               buyprice=myorder.PriceOpen();
               mytrade.OrderDelete(stp_compra_ticket);
               mytrade.BuyStop(Lot-lote_parcial,buyprice,Symbol(),0,0,0,0,"STOP"+exp_name);
               stp_compra_ticket=mytrade.ResultOrder();
               GlobalVariableSet(stp_cp_tick,(double)stp_compra_ticket);
               myorder.Select(tp_compra_ticket);
               tp_position=myorder.PriceOpen();
               mytrade.OrderDelete(tp_compra_ticket);
               mytrade.BuyLimit(Lot-lote_parcial,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT");
               tp_compra_ticket=mytrade.ResultOrder();
               GlobalVariableSet(tp_cp_tick,(double)tp_compra_ticket);

              }
           }
        }//Fim myposition Select
     }//Fim for
  }
// Trailing stop (points)
void TrailingStop(int pTrailPoints,int pMinProfit=0,int pStep=10)
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
            myorder.Select(stp_venda_ticket);
            currentStop=myorder.PriceOpen();
            trailStopPrice = bid - trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=bid-openPrice;

            if(trailStopPrice>currentStop+step && currentProfit>=minProfit)
              {
               // mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
               if(myorder.Select(stp_venda_ticket))
                 {
                  mytrade.OrderModify(stp_venda_ticket,trailStopPrice,0,0,0,0,0);
                 }
              }

           }
         else if(posType==POSITION_TYPE_SELL)
           {
            myorder.Select(stp_compra_ticket);
            currentStop=myorder.PriceOpen();
            trailStopPrice = ask + trailStop;
            trailStopPrice = NormalizeDouble(trailStopPrice,digits);
            currentProfit=openPrice-ask;

            if((trailStopPrice<currentStop-step || currentStop==0) && currentProfit>=minProfit)
              {
               //mytrade.PositionModify(myposition.Ticket(),trailStopPrice,currentTakeProfit);
               if(myorder.Select(stp_compra_ticket))
                 {
                  mytrade.OrderModify(stp_compra_ticket,trailStopPrice,0,0,0,0,0);
                 }

              }

           }
        }

     }
  }
//+------------------------------------------------------------------+
