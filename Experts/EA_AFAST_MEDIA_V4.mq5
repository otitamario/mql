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

   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"ENTRADAS DO DIA: "+IntegerToString(ENTRADAS_TOTAL),xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;


   string str_pausa;
   if(timerPausa)str_pausa="EA em PAUSA";
   if(timerOn && !timerPausa)str_pausa="EA ativado";
   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],str_pausa,xx1,yy1,xx2,yy2))
      return(false);



//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnTick(void)
  {
   m_label[0].Text("RESULTADO DO DIA: "+DoubleToString(lucro_total,2));
   m_label[1].Text("ENTRADAS NO DIA: "+IntegerToString(ENTRADAS_TOTAL));
   string str_pausa;
   if(timerPausa)
     {
      str_pausa="EA em PAUSA";
      m_label[2].Color(clrRed);
     }
   if(timerOn && !timerPausa)
     {
      str_pausa="EA ATIVADO";
      m_label[2].Color(clrBlue);
     }
   m_label[2].Text(str_pausa);

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
CiMA *media;
// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=16072018;
input double Lot=1;//Lote Entrada
input double dist_entr=60;//Distância Media entrada (pontos)
input double dist_outras=30;//Distância próximas entradas (pontos)

sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";
input bool UsarLucro=true;//Usar Lucro para Fechamento True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes

sinput string shorario="############------FILTRO DE HORARIO------#################";

input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:05";//Horario Inicial
input string end_hour="17:30";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario
sinput string shorpausa="############------Horário de Pausa de Entradas------#################";
input string start_hour_pausa="21:00";//Horario Inicial Pausa
input string end_hour_pausa="23:59";//Horario Final Pausa

sinput string sindicators="############------INDICADORES------#################";
input int per_media=7;//Período Média
input ENUM_MA_METHOD modo_media=MODE_EMA;//Modo Média

                                         //Variaveis 
string original_symbol;
double ask,bid;
double lucro_total,pontos_total,lucro_liquido;
bool timerOn,tradeOn,timerPausa;
double ponto,ticksize,digits;
long curChartID;
double close[];
ulong ENTRADAS_TOTAL;
ulong compra1_ticket,venda1_ticket,ord_compra_ticket,ord_venda_ticket;
string glob_entr_tot="ENT_TOT"+Symbol()+IntegerToString(Magic_Number);
string glob_ord_cp="ORD_CP"+Symbol()+IntegerToString(Magic_Number);
string glob_ord_vd="ORD_VD"+Symbol()+IntegerToString(Magic_Number);
string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string ord_cp_tick="ord_cp_tick"+Symbol()+IntegerToString(Magic_Number),ord_vd_tick="ord_vd_tick"+Symbol()+IntegerToString(Magic_Number);

double buyprice,sellprice,oldprice;
string informacoes=" ";
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
int PrevPositions;
datetime time_novodia[4];
double lotes_stop;
int res_code;
int cont;
double preco_take;
double tp_position,sl_position;
datetime hora_inicial,hora_final;
datetime hora_inicial_pausa,hora_final_pausa;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   original_symbol=Symbol();
   tradeOn=true;
   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.SetDeviationInPoints(100*SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE));
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
   pontos_total=0.0;
   informacoes=" ";

   curChartID=ChartID();

   media=new CiMA;
   media.Create(Symbol(),periodoRobo,per_media,0,modo_media,PRICE_CLOSE);
   media.AddToChart(curChartID,0);


   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

   if(Lot<=0)
     {
      string erro="Lote deve ser maior que 0";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);

     }

//Global Variables Check

   if(!GlobalVariableCheck(glob_entr_tot))GlobalVariableSet(glob_entr_tot,0.0);
   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0.0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0.0);
   if(!GlobalVariableCheck(ord_cp_tick))GlobalVariableSet(ord_cp_tick,0.0);
   if(!GlobalVariableCheck(ord_vd_tick))GlobalVariableSet(ord_vd_tick,0.0);
   if(!GlobalVariableCheck(glob_ord_cp))GlobalVariableSet(glob_ord_cp,0.0);
   if(!GlobalVariableCheck(glob_ord_vd))GlobalVariableSet(glob_ord_vd,0.0);

   if(!Buy_opened())GlobalVariableSet(glob_ord_cp,0.0);
   if(!Sell_opened())GlobalVariableSet(glob_ord_vd,0.0);

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,200,150))

      return(INIT_FAILED);
//--- run application 

   ExtDialog.Run();

//---

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   hora_inicial_pausa=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour_pausa);
   hora_final_pausa=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_pausa);
   if(hora_final_pausa<hora_inicial_pausa)hora_final_pausa=hora_final_pausa+PeriodSeconds(PERIOD_D1);

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

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
   DeletaIndicadores();
   ExtDialog.Destroy(reason);
   delete(media);
   EventKillTimer();
   Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");

//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,// event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
//| TradeTransaction function                                        | 
//+------------------------------------------------------------------+ 
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {

//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
   double sl_position,tp_position;
//--- if transaction is result of addition of the transaction in history

   if(type==TRADE_TRANSACTION_HISTORY_ADD)
     {

      ulong order_ticket=trans.order;
      myorder.Select(order_ticket);
      myposition.SelectByTicket(trans.position);

      if(order_ticket==compra1_ticket && trans.order_state==ORDER_STATE_FILLED)

        {
         ENTRADAS_TOTAL++;
         GlobalVariableSet(glob_entr_tot,(double)ENTRADAS_TOTAL);
         GlobalVariableSet(glob_ord_cp,GlobalVariableGet(glob_ord_cp)+1);
         myposition.SelectByTicket(compra1_ticket);
         buyprice=myposition.PriceOpen();
         tp_position=NormalizeDouble(myposition.PriceOpen()-dist_outras*ponto,digits);
         mytrade.BuyLimit(GlobalVariableGet(glob_ord_cp)*Lot,NormalizeDouble(myposition.PriceOpen()-dist_outras*ponto,digits),NULL,0,0,0,0,"BUY"+DoubleToString(GlobalVariableGet(glob_ord_cp),0)+"Level"+exp_name);
         ord_compra_ticket=mytrade.ResultOrder();
         GlobalVariableSet(ord_cp_tick,(double)ord_compra_ticket);
        }

      //--------------------------------------------------

      if(order_ticket==venda1_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         ENTRADAS_TOTAL++;
         GlobalVariableSet(glob_entr_tot,(double)ENTRADAS_TOTAL);
         GlobalVariableSet(glob_ord_vd,GlobalVariableGet(glob_ord_vd)+1);
         myposition.SelectByTicket(venda1_ticket);
         tp_position=NormalizeDouble(myposition.PriceOpen()+dist_outras*ponto,digits);
         mytrade.SellLimit(GlobalVariableGet(glob_ord_vd)*Lot,NormalizeDouble(myposition.PriceOpen()+dist_outras*ponto,digits),NULL,0,0,0,0,"SELL"+DoubleToString(GlobalVariableGet(glob_ord_vd),0)+"Level"+exp_name);
         ord_venda_ticket=mytrade.ResultOrder();
         GlobalVariableSet(ord_vd_tick,(double)ord_venda_ticket);
        }

      if(order_ticket==ord_compra_ticket && trans.order_state==ORDER_STATE_FILLED)

        {
         ENTRADAS_TOTAL++;
         GlobalVariableSet(glob_entr_tot,(double)ENTRADAS_TOTAL);
         GlobalVariableSet(glob_ord_cp,GlobalVariableGet(glob_ord_cp)+1);
         myposition.SelectByTicket(ord_compra_ticket);
         buyprice=myposition.PriceOpen();
         tp_position=NormalizeDouble(myposition.PriceOpen()-dist_outras*ponto,digits);
         mytrade.BuyLimit(GlobalVariableGet(glob_ord_cp)*Lot,NormalizeDouble(myposition.PriceOpen()-dist_outras*ponto,digits),NULL,0,0,0,0,"BUY"+DoubleToString(GlobalVariableGet(glob_ord_cp),0)+"Level"+exp_name);
         ord_compra_ticket=mytrade.ResultOrder();
         GlobalVariableSet(ord_cp_tick,(double)ord_compra_ticket);
        }

      //--------------------------------------------------

      if(order_ticket==ord_venda_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         ENTRADAS_TOTAL++;
         GlobalVariableSet(glob_entr_tot,(double)ENTRADAS_TOTAL);
         GlobalVariableSet(glob_ord_vd,GlobalVariableGet(glob_ord_vd)+1);
         myposition.SelectByTicket(ord_venda_ticket);
         tp_position=NormalizeDouble(myposition.PriceOpen()-dist_outras*ponto,digits);
         sellprice=myposition.PriceOpen();

         mytrade.SellLimit(GlobalVariableGet(glob_ord_vd)*Lot,NormalizeDouble(myposition.PriceOpen()+dist_outras*ponto,digits),NULL,0,0,0,0,"SELL"+DoubleToString(GlobalVariableGet(glob_ord_vd),0)+"Level"+exp_name);
         ord_venda_ticket=mytrade.ResultOrder();
         GlobalVariableSet(ord_vd_tick,(double)ord_venda_ticket);
        }

     }//End TRANSACTIONS HISTORY ADD

  }
//+------------------------------------------------------------------+
//|                                                                  |
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+



//+-------------ROTINAS----------------------------------------------+

void Main_Program()
  {
   mysymbol.Refresh();
   mysymbol.RefreshRates();
   ExtDialog.OnTick();
   media.Refresh();

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   hora_inicial_pausa=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour_pausa);
   hora_final_pausa=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_pausa);

   if(hora_final_pausa<hora_inicial_pausa)hora_final_pausa=hora_final_pausa+PeriodSeconds(PERIOD_D1);

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
   timerPausa=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final;
      timerPausa=TimeCurrent()>=hora_inicial_pausa && TimeCurrent()<=hora_final_pausa;
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(timerOn==false && daytrade)
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

   if(!Buy_opened())
     {
      DeleteOrders(ORDER_TYPE_BUY_LIMIT);
      GlobalVariableSet(glob_ord_cp,0.0);
      GlobalVariableSet(cp_tick,0.0);
      GlobalVariableSet(ord_cp_tick,0.0);

     }
   if(!Sell_opened())
     {
      DeleteOrders(ORDER_TYPE_SELL_LIMIT);
      GlobalVariableSet(glob_ord_vd,0.0);
      GlobalVariableSet(vd_tick,0.0);
      GlobalVariableSet(ord_vd_tick,0.0);

     }

   ENTRADAS_TOTAL=(int)GlobalVariableGet(glob_entr_tot);
   compra1_ticket=(int) GlobalVariableGet(cp_tick);
   venda1_ticket=(int) GlobalVariableGet(vd_tick);
   ord_compra_ticket=(int) GlobalVariableGet(ord_cp_tick);
   ord_venda_ticket=(int) GlobalVariableGet(ord_vd_tick);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(tradeOn && timerOn)

     {// inicio Trade On

      if(!timerPausa)
        {
         if(distMediaCompra() && !Buy_opened())
           {
            mytrade.Buy(Lot,NULL,0,0,0,"BUY"+exp_name);
            compra1_ticket=mytrade.ResultOrder();
            GlobalVariableSet(cp_tick,(double)compra1_ticket);
           }

         if(distMediaVenda() && !Sell_opened())
           {
            mytrade.Sell(Lot,NULL,0,0,0,"SELL"+exp_name);
            venda1_ticket=mytrade.ResultOrder();
            GlobalVariableSet(vd_tick,(double)venda1_ticket);
           }

        }//Fim Timer Pausa

      if(CheckBuyClose() && Buy_opened())
        {
         ClosePosType(POSITION_TYPE_BUY);
         DeleteOrders(ORDER_TYPE_BUY_LIMIT);
         GlobalVariableSet(glob_ord_cp,0);
         ord_compra_ticket=0;
        }
      if(CheckSellClose() && Sell_opened())
        {
         ClosePosType(POSITION_TYPE_SELL);
         DeleteOrders(ORDER_TYPE_SELL_LIMIT);
         GlobalVariableSet(glob_ord_vd,0);
         ord_venda_ticket=0;
        }
     }//End Trade On

  }//End Main Program
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   bool signal;
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
   bool signal;
   return signal;
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   bool b_get;
   b_get=CopyClose(Symbol(),PERIOD_M1,0,5,close)<=0;
   return(b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
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
bool PosicaoAberta()
  {
   if(myposition.SelectByMagic(original_symbol,Magic_Number)==true)
      return(myposition.PositionType()== POSITION_TYPE_BUY||myposition.PositionType()== POSITION_TYPE_SELL);
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool distMediaVenda()
  {
   bool dist=bid-media.Main(0)>=dist_entr*ponto;
   return dist;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool distMediaCompra()
  {
   bool dist=media.Main(0)-ask>=dist_entr*ponto;
   return dist;

  }
//+------------------------------------------------------------------+
bool CheckSellClose()
  {
   bool dist=ask<=media.Main(0);
   return dist;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckBuyClose()
  {
   bool dist=bid>=media.Main(0);
   return dist;

  }
//+------------------------------------------------------------------+
