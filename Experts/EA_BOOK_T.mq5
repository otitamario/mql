//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
struct infobook
  {
   double            price;
   double            volume;
  };
//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>
#include <Controls\Dialog.mqh>
CLabel            m_label[80];
CControlsDialog ExtDialog;
CPanel painel_ativo;
CPanel painel_lado;
CLabel label_info[20];

#define TENTATIVAS 10 // Tentativas envio ordem
#define ORDENS_SIZE 16 // Tentativas envio ordem
#define TOTAL_PRECOS 16 // Tentativas envio ordem

#define x1_Dialog 0// x1 da Caixa de Diálogo 
#define y1_Dialog 0// y1 da Caixa de Diálogo
#define x2_Dialog 350// x2 da Caixa de Diálogo 
#define y2_Dialog 700// y2 da Caixa de Diálogo
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {

   int xx1,yy1,xx2,yy2;
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);
   if(!CreatePanel(chart,subwin,painel_ativo,x1,y1,0.4*x2-CONTROLS_GAP_X,y2-INDENT_BOTTOM))
      return(false);
   painel_ativo.ColorBackground(clrLightSkyBlue);
   Add(painel_ativo);
   painel_ativo.Show();
   if(!CreatePanel(chart,subwin,painel_lado,0.4*x2,y1,x2-CONTROLS_GAP_X,y2-INDENT_BOTTOM))
      return(false);
   painel_lado.ColorBackground(clrLightSteelBlue);
   Add(painel_lado);
   painel_lado.Show();

//--- create dependent controls 

   for(int i=0;i<ORDENS_SIZE;i++)
     {
      xx1=INDENT_LEFT;
      yy1=INDENT_TOP+i*(0.5*BUTTON_HEIGHT+CONTROLS_GAP_Y);
      xx2=xx1+BUTTON_WIDTH;
      yy2=yy1+0.5*BUTTON_HEIGHT;


      if(!CreateLabel(m_chart_id,m_subwin,m_label[i],DoubleToString(opc1_sell_book[ORDENS_SIZE-i-1].price,SymbolInfoInteger(original_symbol,SYMBOL_DIGITS))+"        "+DoubleToString(opc1_sell_book[ORDENS_SIZE-i-1].volume,0),xx1,yy1,xx2,yy2))
         return(false);
      m_label[i].Color(clrRed);
      m_label[i].FontSize(9);


     }

   for(int i=0;i<ORDENS_SIZE;i++)
     {
      xx1=INDENT_LEFT;
      yy1=INDENT_TOP+(i+ORDENS_SIZE)*(0.5*BUTTON_HEIGHT+CONTROLS_GAP_Y);
      xx2=xx1+BUTTON_WIDTH;
      yy2=yy1+0.5*BUTTON_HEIGHT;

      if(!CreateLabel(m_chart_id,m_subwin,m_label[i+ORDENS_SIZE],DoubleToString(opc1_buy_book[i].price,SymbolInfoInteger(original_symbol,SYMBOL_DIGITS))+"        "+DoubleToString(opc1_buy_book[i].volume,0),xx1,yy1,xx2,yy2))
         return(false);
      m_label[i+ORDENS_SIZE].Color(clrBlue);
      m_label[i+ORDENS_SIZE].FontSize(9);

     }

   xx1=0.4*x2+INDENT_LEFT;
   yy1=y1+INDENT_TOP;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(chart,subwin,label_info[0],"Soma Compra "+DoubleToString(soma_compra,2),xx1,yy1,xx2,yy2))
      return(false);
   label_info[0].Font("Arial");
   label_info[0].FontSize(10);


   xx1=0.4*x2+INDENT_LEFT;
   yy1=y1+INDENT_TOP+BUTTON_HEIGHT;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(chart,subwin,label_info[1],"Soma Venda "+DoubleToString(soma_venda,2),xx1,yy1,xx2,yy2))
      return(false);
   label_info[1].Font("Arial");
   label_info[1].FontSize(10);

   xx1=0.4*x2+INDENT_LEFT;
   yy1=y1+INDENT_TOP+2*BUTTON_HEIGHT;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(chart,subwin,label_info[2],"Variação "+DoubleToString(variacao_total,2)+"%",xx1,yy1,xx2,yy2))
      return(false);
   label_info[2].Font("Arial");
   label_info[2].FontSize(10);

   xx1=0.4*x2+INDENT_LEFT;
   yy1=y1+INDENT_TOP+3*BUTTON_HEIGHT;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;


   if(!CreateLabel(m_chart_id,m_subwin,label_info[3],"RESULTADO: "+DoubleToString(lucro_total,2),xx1,yy1,xx2,yy2))
      return(false);

   xx1=0.4*x2+INDENT_LEFT;
   yy1=y1+INDENT_TOP+4*BUTTON_HEIGHT;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,label_info[4],"ENTRADAS NO DIA: "+IntegerToString(ENTRADAS_TOTAL),xx1,yy1,xx2,yy2))
      return(false);

   xx1=0.4*x2+INDENT_LEFT;
   yy1=y1+INDENT_TOP+5*BUTTON_HEIGHT;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   string str_pos;
   if(!PosicaoAberta())str_pos="ZERADO";
   if(Buy_opened()&&myposition.SelectByTicket(compra1_ticket))str_pos="COMPRADO";
   if(Sell_opened()&&myposition.SelectByTicket(venda1_ticket))str_pos="VENDIDO";

   if(!CreateLabel(m_chart_id,m_subwin,label_info[5],"POSIÇÃO: "+str_pos,xx1,yy1,xx2,yy2))
      return(false);




//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnTick(void)
  {

   for(int i=0;i<ORDENS_SIZE;i++) m_label[i+ORDENS_SIZE].Text(DoubleToString(opc1_buy_book[i].price,SymbolInfoInteger(original_symbol,SYMBOL_DIGITS))+"          "+DoubleToString(opc1_buy_book[i].volume,0));

   for(int i=0;i<ORDENS_SIZE;i++) m_label[i].Text(DoubleToString(opc1_sell_book[ORDENS_SIZE-i-1].price,SymbolInfoInteger(original_symbol,SYMBOL_DIGITS))+"          "+DoubleToString(opc1_sell_book[ORDENS_SIZE-i-1].volume,0));
   label_info[0].Text("Soma Compra "+DoubleToString(soma_compra,2));
   label_info[1].Text("Soma Venda "+DoubleToString(soma_venda,2));
   if(variacao_total<0)label_info[2].Color(clrRed);
   else label_info[2].Color(clrBlue);
   label_info[2].Text("Variação "+DoubleToString(variacao_total,2)+"%");
   label_info[3].Text("RESULTADO: "+DoubleToString(lucro_total,2));
   label_info[4].Text("ENTRADAS NO DIA: "+IntegerToString(ENTRADAS_TOTAL));
   string str_pos;
   if(!PosicaoAberta())str_pos="ZERADO";
   if(Buy_opened()&&myposition.SelectByTicket(compra1_ticket))str_pos="COMPRADO";
   if(Sell_opened()&&myposition.SelectByTicket(venda1_ticket))str_pos="VENDIDO";

   label_info[5].Text("POSIÇÃO: "+str_pos);

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

// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=16072018;
input double Lot=1;//Lote Entrada
sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";
input bool UsarLucro=true;//Usar Lucro para Fechamento True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes

sinput string shorario="############------FILTRO DE HORARIO------#################";

input bool UseTimer = true;
input int StartHour = 9;//Hora de Inicio
input int StartMinute=5;//Minuto de Inicio

sinput string horafech="HORARIO PARA FECHAMENTO DE POSICOES E ORDENS";
input int EndHour=17;//Hora de Fechamento
input int EndMinute=30;//Minuto de Fechamento
input bool Daytrade=true;// Fechar posicoes Daytrade fim do dia
sinput string sestrategia="------------------ESTRATÉGIA-----------";
input double var_entry=80;//Variação para entradas
input double _Stop=150;//Stop Loss em Pontos
input double _TakeProfit=2500; //Take Profit em Pontos

sinput string spesos="-----------------------PESOS---------------------";
input double Inpeso0=5;//Peso 1
input double Inpeso1=4.5;//Peso 2
input double Inpeso2=4;//Peso 3
input double Inpeso3=3.5;//Peso 4
input double Inpeso4=3;//Peso 5
input double Inpeso5=2.5;//Peso 6
input double Inpeso6=2;//Peso 7
input double Inpeso7=1.5;//Peso 8
input double Inpeso8=1;//Peso 9
input double Inpeso9=0.5;//Peso 10
input double Inpeso10=0.4;//Peso 11
input double Inpeso11=0.4;//Peso 12
input double Inpeso12=0.4;//Peso 13
input double Inpeso13=0.4;//Peso 14
input double Inpeso14=0.4;//Peso 15
input double Inpeso15=0.4;//Peso 16

                          //Variaveis 
double ask,bid;
double lucro_total,pontos_total,lucro_liquido;
bool timerOn,tradeOn;
double ponto,ticksize,digits;
long curChartID;
double high[],low[],open[],close[];
ulong ENTRADAS_TOTAL;
ulong trade_ticket,compra1_ticket,venda1_ticket,stp_venda_ticket,stp_compra_ticket,tp_venda_ticket,tp_compra_ticket;
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
datetime iTime[1],iTimeD[1];
double preco_take;
infobook opc1_buy_book[ORDENS_SIZE],opc1_sell_book[ORDENS_SIZE];
string original_symbol;
double pesos[TOTAL_PRECOS];
double soma_compra,soma_venda,variacao_total;
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

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

   pesos[0]=Inpeso0;pesos[1]=Inpeso1;pesos[2]=Inpeso2;pesos[3]=Inpeso3;
   pesos[4]=Inpeso4;pesos[5]=Inpeso5;pesos[6]=Inpeso6;pesos[7]=Inpeso7;
   pesos[8]=Inpeso8;pesos[9]=Inpeso9;pesos[10]=Inpeso10;pesos[11]=Inpeso11;
   pesos[12]=Inpeso12;pesos[13]=Inpeso13;pesos[14]=Inpeso14;pesos[15]=Inpeso15;

// parametros incorretos desnecessarios na otimizacao

   if(Lot<=0)
     {
      string erro="Lote deve ser maior que 0";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);

     }

//Global Variables Check

   if(!GlobalVariableCheck(glob_entr_tot))GlobalVariableSet(glob_entr_tot,0);
   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0);
   if(!GlobalVariableCheck(stp_vd_tick))GlobalVariableSet(stp_vd_tick,0);
   if(!GlobalVariableCheck(stp_cp_tick))GlobalVariableSet(stp_cp_tick,0);
   if(!GlobalVariableCheck(tp_vd_tick))GlobalVariableSet(tp_vd_tick,0);
   if(!GlobalVariableCheck(tp_cp_tick))GlobalVariableSet(tp_cp_tick,0);

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,x1_Dialog,y1_Dialog,x2_Dialog,y2_Dialog))
      return(INIT_FAILED);

//--- run application 

   ExtDialog.Run();

   MarketBookAdd(original_symbol);
   AtualizarBook(original_symbol,opc1_buy_book,opc1_sell_book);

   if(TimeCurrent()>D'2018.09.29')
     {
      string erro="Data de Validade Expirou";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);

     }

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

   Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");
   MarketBookRelease(original_symbol);
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

   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      ulong order_ticket=trans.order;

      if(order_ticket==trade_ticket && trans.deal_type!=DEAL_TYPE_BALANCE)
        {
         ENTRADAS_TOTAL++;
         GlobalVariableSet(glob_entr_tot,(double)ENTRADAS_TOTAL);
        }

     }//End TRANSACTIONS DEAL ADD
   if(type==TRADE_TRANSACTION_HISTORY_ADD)
     {

      ulong order_ticket=trans.order;
      myorder.Select(order_ticket);
      myposition.SelectByTicket(trans.position);

      if(order_ticket==compra1_ticket && trans.order_state==ORDER_STATE_FILLED)

        {
         myposition.SelectByTicket(compra1_ticket);
         buyprice=myposition.PriceOpen();
         Print("compra ticket ",compra1_ticket," price open",buyprice);
         sl_position=NormalizeDouble(buyprice-_Stop*ponto,digits);
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
            mytrade.SellStop(Lot,sellprice,Symbol(),0,0,0,0,"STOP"+exp_name);
            stp_venda_ticket=mytrade.ResultOrder();
            GlobalVariableSet(stp_vd_tick,(double)stp_venda_ticket);
           }

        }
      //--------------------------------------------------

      if(order_ticket==venda1_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         myposition.SelectByTicket(venda1_ticket);
         sellprice=myposition.PriceOpen();
         Print("venda ticket ",venda1_ticket," price open",sellprice);
         sl_position=NormalizeDouble(sellprice+_Stop*ponto,digits);
         tp_position=NormalizeDouble(sellprice-_TakeProfit*ponto,digits);
         mytrade.BuyLimit(Lot,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT");
         tp_compra_ticket=mytrade.ResultOrder();
         GlobalVariableSet(tp_cp_tick,(double)tp_compra_ticket);
         buyprice=sl_position;
         oldprice=PriceLastStopOrder(ORDER_TYPE_BUY_STOP);
         if(oldprice==-1 || buyprice<oldprice && Sell_opened()) // No order or New price is better
           {
            DeleteOrders(ORDER_TYPE_BUY_STOP);
            mytrade.BuyStop(Lot,buyprice,Symbol(),0,0,0,0,"STOP"+exp_name);
            stp_compra_ticket=mytrade.ResultOrder();
            GlobalVariableSet(stp_cp_tick,(double)stp_compra_ticket);
           }

        }
      //--------------------------------------------------

      // Fechar Ordens e Posicoes

      if(order_ticket==stp_compra_ticket && trans.order_type==ORDER_TYPE_BUY_STOP && trans.order_state==ORDER_STATE_FILLED)
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

      if(order_ticket==stp_venda_ticket && trans.order_type==ORDER_TYPE_SELL_STOP && trans.order_state==ORDER_STATE_FILLED)
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

      if(order_ticket==tp_compra_ticket && trans.order_state==ORDER_STATE_FILLED)
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
      if(order_ticket==tp_venda_ticket && trans.order_state==ORDER_STATE_FILLED)
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

     }//End TRANSACTIONS HISTORY ADD

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| BookEvent function                                               |
//+------------------------------------------------------------------+
void OnBookEvent(const string &symbol)
  {
   if(symbol==original_symbol)
     {
      AtualizarBook(original_symbol,opc1_buy_book,opc1_sell_book);
     }
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
   mysymbol.Refresh();
   mysymbol.RefreshRates();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

   bool novodia;

   if(CopyTime(Symbol(),PERIOD_D1,0,1,iTimeD)<=0)
     {
      Print(" Failed to get time value . "+
            "\nNext attempt to get indicator values will be made on the next tick.",GetLastError());
      return;
     }
//novodia=NewBar.CheckNewBar(simbolo,PERIOD_D1);
   novodia=newbar_ind.isNewBar(iTime[0]);
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

   timerOn=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer==true)
     {
      timerOn=Timer.DailyTimer(StartHour,StartMinute,EndHour,EndMinute);
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
   if(timerOn==false)
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
   if(CopyTime(Symbol(),_Period,0,1,iTime)<=0)
     {
      Print(" Failed to get time value . "+
            "\nNext attempt to get indicator values will be made on the next tick.",GetLastError());
      return;
     }
//--- Detect the next tick candlestick:
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
   if(!PosicaoAberta())DeleteALL();
   if(tradeOn && timerOn)

     {// inicio Trade On

      if(BuySignal() && !Buy_opened())
        {
         if(PositionsTotal()>0)CloseALL();
         if(OrdersTotal()>0)DeleteALL();
       //  mytrade.Buy(Lot,Symbol(),0,0,0,"BUY"+exp_name);
         trade_ticket=mytrade.ResultOrder();
         compra1_ticket=trade_ticket;
         GlobalVariableSet(cp_tick,(double)compra1_ticket);
        }

      if(SellSignal() && !Sell_opened())
        {
         if(PositionsTotal()>0)CloseALL();
         if(OrdersTotal()>0)DeleteALL();
        // mytrade.Sell(Lot,Symbol(),0,0,0,"SELL"+exp_name);
         trade_ticket=mytrade.ResultOrder();
         venda1_ticket=trade_ticket;
         GlobalVariableSet(vd_tick,(double)venda1_ticket);

        }

      if(newbar_ind.isNewBar(iTime[0]))
        {
        }//Fim NewBar

     }//End Trade On
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      if(Daytrade==true)
        {
         DeleteALL();
         CloseALL();
        }
     } // fechou ordens pendentes no Day trade fora do horario

//Comentarios();

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
   bool b_signal=variacao_total>var_entry;
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
   bool s_signal=variacao_total<-var_entry;
   return s_signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckSellClose()
  {
   bool signal;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Buy Close conditions                                                  |
//+------------------------------------------------------------------+
bool CheckBuyClose()
  {
   bool signal;
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
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Corretagem(double custo)
  {
   double corretagem;
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
   double vol=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_IN || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            vol+=mydeal.Volume();
     }

   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
         vol+=myposition.Volume();
   corretagem=custo*vol;
   return corretagem;
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void AtualizarBook(string ativo,infobook &arrayBuy[],infobook &arraySell[])
  {
   int cont_buy;
   int cont_sell;
   int tamanhobook;
   int contador;
   soma_compra=0;
   soma_venda=0;
   variacao_total=0;
//--- select the symbol
//Print("Book event for: "+symbol);

//--- array of the DOM structures
   MqlBookInfo last_bookArray[];

//--- get the book
   if(MarketBookGet(ativo,last_bookArray))
     {
      //--- process book data
      cont_buy=0;
      cont_sell=0;
      tamanhobook=ArraySize(last_bookArray);
      for(int idx=0;idx<tamanhobook;idx++)
        {
         if(last_bookArray[idx].type==BOOK_TYPE_BUY)cont_buy+=1;
         if(last_bookArray[idx].type==BOOK_TYPE_SELL)cont_sell+=1;
        }
      if(cont_buy>0 && cont_sell>0)
        {
         contador=0;
         for(int i=tamanhobook-cont_buy;i<=MathMin(ORDENS_SIZE,cont_buy)+tamanhobook-cont_buy-1;i++)
           {
            arrayBuy[contador].price=last_bookArray[i].price;
            arrayBuy[contador].volume=last_bookArray[i].volume;
            contador+=1;
           }
         contador=0;
         for(int i=tamanhobook-cont_buy-1;i>=tamanhobook-cont_buy-MathMin(ORDENS_SIZE,cont_sell);i--)
           {
            arraySell[contador].price=last_bookArray[i].price;
            arraySell[contador].volume=last_bookArray[i].volume;
            contador+=1;

           }

        }
      else if(cont_buy>0 && cont_sell==0)
        {
         for(int i=0;i<ORDENS_SIZE;i++)
           {
            if(i<cont_buy)
              {
               arrayBuy[i].price=last_bookArray[i].price;
               arrayBuy[i].volume=last_bookArray[i].volume;
              }
            else
              {
               arrayBuy[i].price=0;
               arrayBuy[i].volume=0;
              }
           }
         for(int i=0;i<ORDENS_SIZE;i++)
           {
            arraySell[i].price=0;
            arraySell[i].volume=0;
           }
        }

      else if(cont_buy==0 && cont_sell>0)
        {
         for(int i=0;i<ORDENS_SIZE;i++)
           {
            if(i<cont_sell)
              {
               arraySell[i].price=last_bookArray[i].price;
               arraySell[i].volume=last_bookArray[i].volume;
              }
            else
              {
               arraySell[i].price=0;
               arraySell[i].volume=0;
              }
           }
         for(int i=0;i<ORDENS_SIZE;i++)
           {
            arrayBuy[i].price=0;
            arrayBuy[i].volume=0;
           }

        }
      else
        {
         for(int i=0;i<ORDENS_SIZE;i++)
           {
            arraySell[i].price=0;
            arraySell[i].volume=0;
            arrayBuy[i].price=0;
            arrayBuy[i].volume=0;
           }

        }
      for(int i=0;i<ORDENS_SIZE;i++)
        {
         soma_compra+=arrayBuy[i].volume*pesos[i];
         soma_venda+=arraySell[i].volume*pesos[i];
        }
      if(soma_compra>=soma_venda && soma_venda>0)
        {
         variacao_total=(soma_compra-soma_venda)/soma_venda;
         variacao_total=variacao_total*100;
        }

      if(soma_venda>soma_compra && soma_compra>0)
        {
         variacao_total=(soma_venda-soma_compra)/soma_compra;
         variacao_total=-variacao_total*100;
        }
      //   Print( " compra ",soma_compra,"venda ",soma_venda);
      ExtDialog.OnTick();
     }//Fim MarketbookGet

  }
//+------------------------------------------------------------------+
bool PosicaoAberta()
  {
   if(myposition.SelectByMagic(original_symbol,Magic_Number)==true)
      return(myposition.PositionType()== POSITION_TYPE_BUY||myposition.PositionType()== POSITION_TYPE_SELL);
   else return(false);
  }
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
