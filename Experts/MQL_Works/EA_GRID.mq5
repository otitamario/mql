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
#include <Tools\DateTime.mqh>


CDateTime datas;
CLabel            m_label[500];
CComboBox comboCompras;
CComboBox comboVendas;
CButton ExcluiCompra;
CButton ExcluiVenda;
CEdit OrdemCompra;
CEdit OrdemVenda;
CButton EnviarCompra;
CButton EnviarVenda;

#define TENTATIVAS 10 // Tentativas envio ordem
#define TOTAL_ORD 30 // Tentativas envio ordem

#define x1_Dialog 0// x1 da Caixa de Diálogo 
#define y1_Dialog 0// y1 da Caixa de Diálogo
#define x2_Dialog 400// x2 da Caixa de Diálogo 
#define y2_Dialog 300// y2 da Caixa de Diálogo
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

   xx1=0.4*x2+INDENT_LEFT;
   yy1=INDENT_TOP;
   xx2=x1+BUTTON_WIDTH;
   yy2=INDENT_TOP+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"Compras: ",xx1,yy1,xx2,yy2))
      return(false);


   xx1=0.4*x2+INDENT_LEFT+0.75*GROUP_WIDTH+CONTROLS_GAP_X;
   yy1=INDENT_TOP+CONTROLS_GAP_Y;
   xx2=x1+BUTTON_WIDTH;
   yy2=INDENT_TOP+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"Vendas: ",xx1,yy1,xx2,yy2))
      return(false);



   if(!CreateComboBox(chart,"comboCompras",subwin,comboCompras,0.4*x2+INDENT_LEFT,INDENT_TOP,0.4*x2+INDENT_LEFT+0.5*GROUP_WIDTH,INDENT_TOP+EDIT_HEIGHT))
      return(false);

   if(!Add(comboCompras))
      return(false);


   if(!CreateComboBox(chart,"comboVendas",subwin,comboVendas,0.4*x2+INDENT_LEFT+0.75*GROUP_WIDTH+CONTROLS_GAP_X,INDENT_TOP,0.4*x2+INDENT_LEFT+1.25*GROUP_WIDTH+CONTROLS_GAP_X,INDENT_TOP+EDIT_HEIGHT))
      return(false);


   if(!Add(comboVendas))
      return(false);




   xx1=0.4*x2+INDENT_LEFT;
   yy1=INDENT_TOP+EDIT_HEIGHT+BUTTON_HEIGHT+3*CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+1.5*BUTTON_HEIGHT;

   if(!CreateButton(m_chart_id,m_subwin,ExcluiCompra,"Excluir Compra",xx1,yy1,xx2,yy2))
      return(false);
   ExcluiCompra.ColorBackground(clrBlueViolet);
   ExcluiCompra.Color(clrYellow);


   xx1=0.4*x2+INDENT_LEFT+0.75*GROUP_WIDTH+CONTROLS_GAP_X;
   yy1=INDENT_TOP+EDIT_HEIGHT+BUTTON_HEIGHT+3*CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+1.5*BUTTON_HEIGHT;

   if(!CreateButton(m_chart_id,m_subwin,ExcluiVenda,"Excluir Venda",xx1,yy1,xx2,yy2))
      return(false);
   ExcluiVenda.ColorBackground(clrBlueViolet);
   ExcluiVenda.Color(clrYellow);


   xx1=0.4*x2+INDENT_LEFT;
   yy1=INDENT_TOP+2*EDIT_HEIGHT+2*BUTTON_HEIGHT+4*CONTROLS_GAP_Y;
   xx2=xx1+0.75*BUTTON_WIDTH;
   yy2=yy1+1.5*BUTTON_HEIGHT;

   if(!CreateEdit(m_chart_id,m_subwin,OrdemCompra,xx1,yy1,xx2,yy2))
      return(false);


   xx1=0.4*x2+INDENT_LEFT+0.75*GROUP_WIDTH+CONTROLS_GAP_X;
   yy1=INDENT_TOP+2*EDIT_HEIGHT+2*BUTTON_HEIGHT+4*CONTROLS_GAP_Y;
   xx2=xx1+0.75*BUTTON_WIDTH;
   yy2=yy1+1.5*BUTTON_HEIGHT;

   if(!CreateEdit(m_chart_id,m_subwin,OrdemVenda,xx1,yy1,xx2,yy2))
      return(false);


   xx1=0.4*x2+INDENT_LEFT;
   yy1=INDENT_TOP+3*(EDIT_HEIGHT+BUTTON_HEIGHT)+5*CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+1.5*BUTTON_HEIGHT;

   if(!CreateButton(m_chart_id,m_subwin,EnviarCompra,"Enviar Compra",xx1,yy1,xx2,yy2))
      return(false);
   EnviarCompra.ColorBackground(clrAquamarine);
   EnviarCompra.Color(clrBlue);


   xx1=0.4*x2+INDENT_LEFT+0.75*GROUP_WIDTH+CONTROLS_GAP_X;
   yy1=INDENT_TOP+3*(EDIT_HEIGHT+BUTTON_HEIGHT)+5*CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+1.5*BUTTON_HEIGHT;

   if(!CreateButton(m_chart_id,m_subwin,EnviarVenda,"Enviar Venda",xx1,yy1,xx2,yy2))
      return(false);
   EnviarVenda.ColorBackground(clrAquamarine);
   EnviarVenda.Color(clrBlue);




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

  }
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(CControlsDialog)
ON_EVENT(ON_CHANGE,comboCompras,OnChangeComboBoxCompra)
ON_EVENT(ON_CHANGE,comboVendas,OnChangeComboBoxVenda)
ON_EVENT(ON_CLICK,ExcluiCompra,OnClickExcluiCompra)
ON_EVENT(ON_CLICK,ExcluiVenda,OnClickExcluiVenda)
ON_EVENT(ON_CLICK,EnviarCompra,OnClickEnviarCompra)
ON_EVENT(ON_CLICK,EnviarVenda,OnClickEnviarVenda)

EVENT_MAP_END(CAppDialog)

void OnChangeComboBoxCompra()
  {
   price_del_buy=NormalizeDouble(StringToDouble(comboCompras.Select()),digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChangeComboBoxVenda()
  {
   price_del_sell=NormalizeDouble(StringToDouble(comboVendas.Select()),digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AtualizaCompras()
  {
   comboCompras.ItemsClear();
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==ORDER_TYPE_BUY_LIMIT && myorder.Comment()=="BUY"+exp_name)
               comboCompras.AddItem(DoubleToString(myorder.PriceOpen(),digits));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AtualizaVendas()
  {
   comboVendas.ItemsClear();
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==ORDER_TYPE_SELL_LIMIT && myorder.Comment()=="SELL"+exp_name)
               comboVendas.AddItem(DoubleToString(myorder.PriceOpen(),digits));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool VerificaCompras(double price)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==ORDER_TYPE_BUY_LIMIT && myorder.Comment()=="BUY"+exp_name && myorder.PriceOpen()==price)
               return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool VerificaVendas(double price)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==ORDER_TYPE_SELL_LIMIT && myorder.Comment()=="SELL"+exp_name && myorder.PriceOpen()==price)
               return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnClickExcluiCompra()
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
     {
      ulong o_ticket=OrderGetTicket(j);
      if(o_ticket!=0)
        {
         myorder.Select(o_ticket);
         if(myorder.Magic()==Magic_Number && myorder.Symbol()==mysymbol.Name() && myorder.PriceOpen()==price_del_buy && myorder.OrderType()==ORDER_TYPE_BUY_LIMIT) mytrade.OrderDelete(o_ticket);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnClickExcluiVenda()
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
     {
      ulong o_ticket=OrderGetTicket(j);
      if(o_ticket!=0)
        {
         myorder.Select(o_ticket);
         if(myorder.Magic()==Magic_Number && myorder.Symbol()==mysymbol.Name() && myorder.PriceOpen()==price_del_sell && myorder.OrderType()==ORDER_TYPE_SELL_LIMIT)mytrade.OrderDelete(o_ticket);
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnClickEnviarCompra()
  {
   double preco=StringToDouble(OrdemCompra.Text());
   preco=NormalizeDouble(preco,digits);
   if(VerificaCompras(preco)) MessageBox("Ordem neste preço já existe");
   else mytrade.BuyLimit(Lot,preco,original_symbol,0,0,0,0,"BUY"+exp_name);
   OrdemCompra.Text("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnClickEnviarVenda()
  {
   double preco=StringToDouble(OrdemVenda.Text());
   preco=NormalizeDouble(preco,digits);
   if(VerificaVendas(preco)) MessageBox("Ordem neste preço já existe");
   else  mytrade.SellLimit(Lot,preco,original_symbol,0,0,0,0,"SELL"+exp_name);
   OrdemVenda.Text("");

  }

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
input ulong Magic_Number=1111;
input double Lot=1;//Lote Entrada
input double _TakeProfit=500; //Intervalo (Take Profit em Pontos)

sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";
input bool UsarLucro=true;//Usar Lucro para Fechamento True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes

sinput string shorario="############------FILTRO DE HORARIO------#################";

input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:00";//Horario Inicial
input string end_hour="17:30";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario

                         //Variaveis 
string original_symbol;
double ask,bid;
double lucro_total,pontos_total,lucro_liquido;
bool timerOn,tradeOn;
double ponto,ticksize,digits;
double high[],low[],open[],close[];

long curChartID;
ulong ENTRADAS_TOTAL;
ulong trade_ticket,compra1_ticket,venda1_ticket;
string glob_entr_tot="ENT_TOT"+Symbol()+IntegerToString(Magic_Number);
string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string informacoes=" ";
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
datetime time_novodia[4];
int res_code;
int cont;
datetime hora_inicial,hora_final;
double ord_buy[TOTAL_ORD],ord_sell[TOTAL_ORD];
double price_del_buy,price_del_sell;
double price_send_buy,price_send_sell;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   original_symbol=Symbol();
   trade_ticket=0;
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

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   curChartID=ChartID();

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

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,x1_Dialog,y1_Dialog,x2_Dialog,y2_Dialog))

      return(INIT_FAILED);
//--- run application 

   ExtDialog.Run();
   AtualizaCompras();
   AtualizaVendas();

//---

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

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

   Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");

//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   string comment;
//--- if transaction is result of addition of the transaction in history
   AtualizaCompras();
   AtualizaVendas();
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      ulong order_ticket=trans.order;

      if((order_ticket==compra1_ticket || order_ticket==venda1_ticket) && trans.deal_type!=DEAL_TYPE_BALANCE)
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
      comment=myposition.Comment();
      string comment2=result.comment;
      Print("coment 2 ",comment2);
      if(comment=="BUY"+exp_name && trans.order_state==ORDER_STATE_FILLED && trans.symbol==mysymbol.Name())
        {
         mytrade.SellLimit(Lot,NormalizeDouble(trans.price+_TakeProfit*ponto,digits),Symbol(),0,0,0,0,"TAKE PROFIT SELL");
        }
      //--------------------------------------------------

      if(comment=="SELL"+exp_name && trans.order_state==ORDER_STATE_FILLED && trans.symbol==mysymbol.Name())
        {
         mytrade.BuyLimit(Lot,NormalizeDouble(trans.price-_TakeProfit*ponto,digits),Symbol(),0,0,0,0,"TAKE PROFIT BUY");

        }
      //--------------------------------------------------
      mydeal.SelectByIndex(trans.deal);
      comment=mydeal.Comment();

      if(comment=="SELL"+exp_name && trans.order_state==ORDER_STATE_FILLED && trans.order_type==ORDER_TYPE_BUY_LIMIT && trans.symbol==mysymbol.Name())
        {

         mytrade.SellLimit(Lot,NormalizeDouble(trans.price+_TakeProfit*ponto,digits),Symbol(),0,0,0,0,"SELL"+exp_name);
        }
      //--------------------------------------------------

      if(comment=="BUY"+exp_name && trans.order_state==ORDER_STATE_FILLED && trans.order_type==ORDER_TYPE_SELL_LIMIT && trans.symbol==mysymbol.Name())
        {
         mytrade.BuyLimit(Lot,NormalizeDouble(trans.price-_TakeProfit*ponto,digits),Symbol(),0,0,0,0,"BUY"+exp_name);

        }
      //--------------------------------------------------
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


   ENTRADAS_TOTAL=(int)GlobalVariableGet(glob_entr_tot);
   compra1_ticket=(int) GlobalVariableGet(cp_tick);
   venda1_ticket=(int) GlobalVariableGet(vd_tick);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(tradeOn && timerOn)

     {// inicio Trade On

      if(NewBar.CheckNewBar(Symbol(),periodoRobo))
        {
         AtualizaCompras();
         AtualizaVendas();

        }//Fim NewBar

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
//------------------------------------------------------------------------

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
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
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
bool PosicaoAberta()
  {
   if(myposition.SelectByMagic(original_symbol,Magic_Number)==true)
      return(myposition.PositionType()== POSITION_TYPE_BUY||myposition.PositionType()== POSITION_TYPE_SELL);
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
