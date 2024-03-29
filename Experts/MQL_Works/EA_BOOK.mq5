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
//|                                                                  |
//+------------------------------------------------------------------+
struct desc_opcao
  {
   string            codigo;
   string            descricao;
   double            strike;
  };

//+------------------------------------------------------------------+

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>
#include <Controls\Dialog.mqh>
CLabel            m_label[500];
CControlsDialog ExtDialog;
CPanel painel_opc1;
CPanel painel_opc2;
CPanel painel_abaixo;
CComboBox comboAcao;
CComboBox comboSerie;
CComboBox ComboListOpcCompra;
CComboBox ComboListOpcVenda;
CLabel label_info[20];
string Acoes[]={"BBDC4","BOVA11","CSNA3","CIEL3","ITSA4","ITUB4","PETR4","USIM5","VALE3"};
string SeriesOpc[24]={"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X"};
#define TENTATIVAS 10 // Tentativas envio ordem
#define ORDENS_SIZE 5 // Tentativas envio ordem
#define x1_Dialog 0// x1 da Caixa de Diálogo 
#define y1_Dialog 0// y1 da Caixa de Diálogo
#define x2_Dialog 700// x2 da Caixa de Diálogo 
#define y2_Dialog 300// y2 da Caixa de Diálogo
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
   if(!CreatePanel(chart,subwin,painel_opc1,x1,y1,0.25*x2-CONTROLS_GAP_X,y2-INDENT_BOTTOM))
      return(false);
   painel_opc1.ColorBackground(clrLightSkyBlue);
   Add(painel_opc1);
   painel_opc1.Show();
   if(!CreatePanel(chart,subwin,painel_opc2,0.25*x2,y1,0.5*x2-CONTROLS_GAP_X,y2-INDENT_BOTTOM))
      return(false);
   painel_opc2.ColorBackground(clrMistyRose);
   Add(painel_opc2);
   painel_opc2.Show();
   if(!CreatePanel(chart,subwin,painel_abaixo,0.5*x2,y1,x2-CONTROLS_GAP_X,y2-INDENT_BOTTOM))
      return(false);
   painel_abaixo.ColorBackground(clrLightSteelBlue);
   Add(painel_abaixo);
   painel_abaixo.Show();

   if(!CreateComboBox(chart,"comboAcao",subwin,comboAcao,0.5*x2+INDENT_LEFT,INDENT_TOP,0.5*x2+INDENT_LEFT+0.5*GROUP_WIDTH,INDENT_TOP+EDIT_HEIGHT))
      return(false);

   if(!Add(comboAcao))
      return(false);
//--- fill out with strings
   ArraySort(Acoes);
   for(int i=0;i<ArraySize(Acoes);i++)
      if(!comboAcao.ItemAdd(Acoes[i]))
         return(false);
   comboAcao.SelectByText("PETR4");
   ativo=comboAcao.Select();

   if(!CreateComboBox(chart,"comboOpcao",subwin,comboSerie,0.5*x2+INDENT_LEFT+0.5*GROUP_WIDTH+CONTROLS_GAP_X,INDENT_TOP,0.5*x2+INDENT_LEFT+0.5*GROUP_WIDTH+CONTROLS_GAP_X+0.5*BUTTON_WIDTH,INDENT_TOP+EDIT_HEIGHT))
      return(false);

   if(!Add(comboSerie))
      return(false);
   for(int i=0;i<ArraySize(SeriesOpc);i++)
      if(!comboSerie.ItemAdd(SeriesOpc[i]))
         return(false);
   comboSerie.SelectByText("H");
   serie=comboSerie.Select();

   if(!CreateComboBox(chart,"ComboListOpcCompra",subwin,ComboListOpcCompra,0.5*x2+INDENT_LEFT,INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y,0.5*x2+INDENT_LEFT+GROUP_WIDTH,INDENT_TOP+EDIT_HEIGHT+2*BUTTON_HEIGHT+CONTROLS_GAP_Y))
      return(false);
   if(!Add(ComboListOpcCompra))
      return(false);

   if(!CreateComboBox(chart,"ComboListOpcVenda",subwin,ComboListOpcVenda,0.5*x2+INDENT_LEFT+GROUP_WIDTH+CONTROLS_GAP_X,INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y,0.5*x2+INDENT_LEFT+2*GROUP_WIDTH+CONTROLS_GAP_X,INDENT_TOP+EDIT_HEIGHT+2*BUTTON_HEIGHT+CONTROLS_GAP_Y))
      return(false);
   if(!Add(ComboListOpcVenda))
      return(false);


   BuscaOpcoes(ativo,serie,opcao_compra,total_opcoes);
   BuscaOpcoes(ativo,serie,opcao_venda,total_opcoes);
   for(int i=0;i<total_opcoes;i++)
      if(!ComboListOpcCompra.ItemAdd(opcao_compra[i].descricao))
         return(false);
   ComboListOpcCompra.SelectByText(opcao_compra[0].descricao);
   for(int i=0;i<total_opcoes;i++)
      if(!ComboListOpcVenda.ItemAdd(opcao_venda[i].descricao))
         return(false);
   ComboListOpcVenda.SelectByText(opcao_venda[1].descricao);
   opcaocompra=opcao_compra[0].codigo;
   opcaovenda=opcao_venda[1].codigo;

//--- create dependent controls 

   xx1=INDENT_LEFT+0.4*BUTTON_WIDTH;
   yy1=INDENT_TOP;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(chart,subwin,label_info[0],opcaocompra,xx1,yy1,xx2,yy2))
      return(false);
   label_info[0].Font("Arial");
   label_info[0].FontSize(10);

   xx1=0.25*x2+INDENT_LEFT+0.4*BUTTON_WIDTH;
   yy1=INDENT_TOP;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(chart,subwin,label_info[1],opcaovenda,xx1,yy1,xx2,yy2))
      return(false);
   label_info[1].Font("Arial");
   label_info[1].FontSize(10);


   if(!CreateLabel(chart,subwin,label_info[2],"Escolha Ação e Série",0.5*x2+INDENT_LEFT,CONTROLS_GAP_Y,0.5*x2+INDENT_LEFT+0.5*GROUP_WIDTH,INDENT_TOP))
      return(false);


   if(!CreateLabel(chart,subwin,label_info[3],"Opção p/ Comprar",0.5*x2+INDENT_LEFT,2*CONTROLS_GAP_Y+2*BUTTON_HEIGHT+CONTROLS_GAP_Y,0.5*x2+INDENT_LEFT+GROUP_WIDTH,2*CONTROLS_GAP_Y+EDIT_HEIGHT+2*BUTTON_HEIGHT+CONTROLS_GAP_Y))
      return(false);


   if(!CreateLabel(chart,subwin,label_info[4],"Opção p/ Vender",0.5*x2+INDENT_LEFT+GROUP_WIDTH+CONTROLS_GAP_X,2*CONTROLS_GAP_Y+2*BUTTON_HEIGHT+CONTROLS_GAP_Y,0.5*x2+INDENT_LEFT+2*GROUP_WIDTH+CONTROLS_GAP_X,2*CONTROLS_GAP_Y+EDIT_HEIGHT+2*BUTTON_HEIGHT+CONTROLS_GAP_Y))
      return(false);



   for(int i=0;i<ORDENS_SIZE;i++)
     {
      xx1=INDENT_LEFT;
      yy1=INDENT_TOP+(i+1)*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
      xx2=xx1+BUTTON_WIDTH;
      yy2=yy1+BUTTON_HEIGHT;


      if(!CreateLabel(m_chart_id,m_subwin,m_label[i],DoubleToString(opc1_sell_book[ORDENS_SIZE-i-1].price,SymbolInfoInteger(opcaocompra,SYMBOL_DIGITS))+"          "+DoubleToString(opc1_sell_book[ORDENS_SIZE-i-1].volume,0),xx1,yy1,xx2,yy2))
         return(false);
      m_label[i].Color(clrRed);

     }

   for(int i=0;i<ORDENS_SIZE;i++)
     {
      xx1=INDENT_LEFT;
      yy1=INDENT_TOP+(i+1+ORDENS_SIZE)*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
      xx2=xx1+BUTTON_WIDTH;
      yy2=yy1+BUTTON_HEIGHT;

      if(!CreateLabel(m_chart_id,m_subwin,m_label[i+ORDENS_SIZE],DoubleToString(opc1_buy_book[i].price,SymbolInfoInteger(opcaocompra,SYMBOL_DIGITS))+"          "+DoubleToString(opc1_buy_book[i].volume,0),xx1,yy1,xx2,yy2))
         return(false);
      m_label[i+ORDENS_SIZE].Color(clrBlue);
     }
// Segundo Book
   int label_init_2book=ORDENS_SIZE*2;
   for(int i=0;i<ORDENS_SIZE;i++)
     {
      xx1=0.25*x2+INDENT_LEFT;
      yy1=INDENT_TOP+(i+1)*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
      xx2=xx1+BUTTON_WIDTH;
      yy2=yy1+BUTTON_HEIGHT;


      if(!CreateLabel(m_chart_id,m_subwin,m_label[label_init_2book+i],DoubleToString(opc2_sell_book[ORDENS_SIZE-i-1].price,SymbolInfoInteger(opcaovenda,SYMBOL_DIGITS))+"          "+DoubleToString(opc2_sell_book[ORDENS_SIZE-i-1].volume,0),xx1,yy1,xx2,yy2))
         return(false);
      m_label[label_init_2book+i].Color(clrRed);

     }

   for(int i=0;i<ORDENS_SIZE;i++)
     {
      xx1=0.25*x2+INDENT_LEFT;
      yy1=INDENT_TOP+(i+1+ORDENS_SIZE)*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
      xx2=xx1+BUTTON_WIDTH;
      yy2=yy1+BUTTON_HEIGHT;

      if(!CreateLabel(m_chart_id,m_subwin,m_label[label_init_2book+i+ORDENS_SIZE],DoubleToString(opc2_buy_book[i].price,SymbolInfoInteger(opcaovenda,SYMBOL_DIGITS))+"          "+DoubleToString(opc2_buy_book[i].volume,0),xx1,yy1,xx2,yy2))
         return(false);
      m_label[label_init_2book+i+ORDENS_SIZE].Color(clrBlue);
     }

   if(!CreateLabel(chart,subwin,label_info[5],"SPREAD PARA ENTRAR ATUAL "+DoubleToString(opc1_sell_book[0].price-opc2_buy_book[0].price,2),0.5*x2+INDENT_LEFT,INDENT_TOP+5*BUTTON_HEIGHT+CONTROLS_GAP_Y,0.5*x2+3*INDENT_LEFT+GROUP_WIDTH,INDENT_TOP+EDIT_HEIGHT+5*BUTTON_HEIGHT+CONTROLS_GAP_Y))
      return(false);
   label_info[5].Color(clrBlue);

   if(!CreateLabel(chart,subwin,label_info[6],"SPREAD PARA SAIR ATUAL "+DoubleToString(opc1_buy_book[0].price-opc2_sell_book[0].price,2),0.5*x2+INDENT_LEFT,INDENT_TOP+6*BUTTON_HEIGHT+CONTROLS_GAP_Y,0.5*x2+3*INDENT_LEFT+GROUP_WIDTH,INDENT_TOP+EDIT_HEIGHT+6*BUTTON_HEIGHT+CONTROLS_GAP_Y))
      return(false);
   label_info[6].Color(clrRed);

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChangeComboBoxAcao()
  {
   ativo=comboAcao.Select();
   BuscaOpcoes(ativo,serie,opcao_compra,total_opcoes);
   BuscaOpcoes(ativo,serie,opcao_venda,total_opcoes);
   ComboListOpcCompra.ItemsClear();
   ComboListOpcVenda.ItemsClear();
   for(int i=0;i<total_opcoes;i++)
      ComboListOpcCompra.ItemAdd(opcao_compra[i].descricao);
   ComboListOpcCompra.SelectByText(opcao_compra[0].descricao);
   for(int i=0;i<total_opcoes;i++)
      ComboListOpcVenda.ItemAdd(opcao_venda[i].descricao);
   ComboListOpcVenda.SelectByText(opcao_venda[1].descricao);

   MarketBookRelease(opcaovenda);
   opcaovenda=FindCodigo(opcao_venda,ComboListOpcVenda.Select());
   MarketBookAdd(opcaovenda);

   AtualizarBook(opcaovenda,opc2_buy_book,opc2_sell_book);

   MarketBookRelease(opcaocompra);
   opcaocompra=FindCodigo(opcao_compra,ComboListOpcCompra.Select());
   MarketBookAdd(opcaocompra);
   AtualizarBook(opcaocompra,opc1_buy_book,opc1_sell_book);
   label_info[0].Text(opcaocompra);
   label_info[1].Text(opcaovenda);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChangeComboBoxSerie()
  {
   serie=comboSerie.Select();
   BuscaOpcoes(ativo,serie,opcao_compra,total_opcoes);
   BuscaOpcoes(ativo,serie,opcao_venda,total_opcoes);
   ComboListOpcCompra.ItemsClear();
   ComboListOpcVenda.ItemsClear();
   for(int i=0;i<total_opcoes;i++)
      ComboListOpcCompra.ItemAdd(opcao_compra[i].descricao);
   ComboListOpcCompra.SelectByText(opcao_compra[0].descricao);
   for(int i=0;i<total_opcoes;i++)
      ComboListOpcVenda.ItemAdd(opcao_venda[i].descricao);
   ComboListOpcVenda.SelectByText(opcao_venda[1].descricao);

   MarketBookRelease(opcaovenda);
   opcaovenda=FindCodigo(opcao_venda,ComboListOpcVenda.Select());
   MarketBookAdd(opcaovenda);

   AtualizarBook(opcaovenda,opc2_buy_book,opc2_sell_book);

   MarketBookRelease(opcaocompra);
   opcaocompra=FindCodigo(opcao_compra,ComboListOpcCompra.Select());
   MarketBookAdd(opcaocompra);
   AtualizarBook(opcaocompra,opc1_buy_book,opc1_sell_book);
   label_info[0].Text(opcaocompra);
   label_info[1].Text(opcaovenda);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChangeComboBoxOpcVenda()
  {
   MarketBookRelease(opcaovenda);
   opcaovenda=FindCodigo(opcao_venda,ComboListOpcVenda.Select());
   MarketBookAdd(opcaovenda);
   AtualizarBook(opcaovenda,opc2_buy_book,opc2_sell_book);
   label_info[1].Text(opcaovenda);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChangeComboBoxOpcCompra()
  {
   MarketBookRelease(opcaocompra);
   opcaocompra=FindCodigo(opcao_compra,ComboListOpcCompra.Select());
   MarketBookAdd(opcaocompra);
   AtualizarBook(opcaocompra,opc1_buy_book,opc1_sell_book);
   label_info[0].Text(opcaocompra);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnTick(void)
  {
   int label_init_2book=ORDENS_SIZE*2;

   for(int i=0;i<ORDENS_SIZE;i++) m_label[i+ORDENS_SIZE].Text(DoubleToString(opc1_buy_book[i].price,SymbolInfoInteger(opcaocompra,SYMBOL_DIGITS))+"          "+DoubleToString(opc1_buy_book[i].volume,0));

   for(int i=0;i<ORDENS_SIZE;i++) m_label[i].Text(DoubleToString(opc1_sell_book[ORDENS_SIZE-i-1].price,SymbolInfoInteger(opcaocompra,SYMBOL_DIGITS))+"          "+DoubleToString(opc1_sell_book[ORDENS_SIZE-i-1].volume,0));

   for(int i=0;i<ORDENS_SIZE;i++) m_label[label_init_2book+i+ORDENS_SIZE].Text(DoubleToString(opc2_buy_book[i].price,SymbolInfoInteger(opcaovenda,SYMBOL_DIGITS))+"          "+DoubleToString(opc2_buy_book[i].volume,0));

   for(int i=0;i<ORDENS_SIZE;i++) m_label[label_init_2book+i].Text(DoubleToString(opc2_sell_book[ORDENS_SIZE-i-1].price,SymbolInfoInteger(opcaovenda,SYMBOL_DIGITS))+"          "+DoubleToString(opc2_sell_book[ORDENS_SIZE-i-1].volume,0));

   label_info[5].Text("SPREAD PARA ENTRAR ATUAL "+DoubleToString(opc1_sell_book[0].price-opc2_buy_book[0].price,2));
   label_info[6].Text("SPREAD PARA SAIR ATUAL "+DoubleToString(opc1_buy_book[0].price-opc2_sell_book[0].price,2));

  }
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(CControlsDialog)
ON_EVENT(ON_CHANGE,comboAcao,OnChangeComboBoxAcao)
ON_EVENT(ON_CHANGE,comboSerie,OnChangeComboBoxSerie)
ON_EVENT(ON_CHANGE,ComboListOpcCompra,OnChangeComboBoxOpcCompra)
ON_EVENT(ON_CHANGE,ComboListOpcVenda,OnChangeComboBoxOpcVenda)

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
                                                 //input string opcaocompra="PETRH18";//OPCAO 1
//input string opcaovenda="PETRH69";//OPCAO 2
input ulong Magic_Number=17072018;
input double Lot=5000;//Lote Entrada
input double spread_entry=0.10;//Spread para Entrar Operação;
input double spread_exit=0.10;//Spread para Sair Operação;
sinput string shorario="############------FILTRO DE HORARIO------#################";

input bool UseTimer = true;
input int StartHour = 9;//Hora de Inicio
input int StartMinute=5;//Minuto de Inicio

sinput string horafech="HORARIO LIMITE PARA ORDENS";
input int EndHour=16;//Hora de Fechamento
input int EndMinute=30;//Minuto de Fechamento

                       //Variaveis 
double ask,bid;
double lucro_total,pontos_total,lucro_liquido;
bool timerOn,tradeOn;
double ponto,ticksize,digits;
long curChartID;
double high[],low[],open[],close[];
ulong ENTRADAS_TOTAL;
ulong compra_in_ticket,venda_in_ticket,compra_out_ticket,venda_out_ticket;
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
infobook opc1_buy_book[ORDENS_SIZE],opc1_sell_book[ORDENS_SIZE],opc2_buy_book[ORDENS_SIZE],opc2_sell_book[ORDENS_SIZE];
string ativo,serie;
desc_opcao opcao_compra[200],opcao_venda[200];
int total_opcoes;
string opcaocompra,opcaovenda;
string cp_in_tick,vd_in_tick,cp_out_tick,vd_out_tick;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   tradeOn=true;
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
   lucro_total=0.0;
   pontos_total=0.0;
   informacoes=" ";

   curChartID=ChartID();

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

// parametros incorretos desnecessarios na otimizacao

   if(Lot<=0)
     {
      string erro="Lote deve ser maior que 0";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);

     }

//Global Variables Check

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,x1_Dialog,y1_Dialog,x2_Dialog,y2_Dialog))
      return(INIT_FAILED);

//--- run application 

   ExtDialog.Run();

   MarketBookAdd(opcaocompra);
   MarketBookAdd(opcaovenda);
   AtualizarBook(opcaocompra,opc1_buy_book,opc1_sell_book);
   AtualizarBook(opcaovenda,opc2_buy_book,opc2_sell_book);
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
   MarketBookRelease(opcaocompra);
   MarketBookRelease(opcaovenda);
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
//--- if transaction is result of addition of the transaction in history

   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      ulong order_ticket=trans.order;

     }//End TRANSACTIONS DEAL ADD
   if(type==TRADE_TRANSACTION_HISTORY_ADD)
     {

      ulong order_ticket=trans.order;
      myorder.Select(order_ticket);
      myposition.SelectByTicket(trans.position);

      //Stop para posição comprada
      if(order_ticket==compra_in_ticket && trans.order_state==ORDER_STATE_FILLED)

        {
         mytrade.SellLimit(Lot,opc2_buy_book[0].price,opcaovenda,0,0,0,0,"VENDA IN");
         venda_in_ticket=mytrade.ResultOrder();

        }

      if(order_ticket==compra_out_ticket && trans.order_state==ORDER_STATE_FILLED)

        {
         mytrade.SellLimit(Lot,opc1_buy_book[0].price,opcaocompra,0,0,0,0,"VENDA OUT");
         venda_out_ticket=mytrade.ResultOrder();

        }

      //--------------------------------------------------

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
   if(symbol==opcaocompra)
     {
      AtualizarBook(opcaocompra,opc1_buy_book,opc1_sell_book);
     }
   if(symbol==opcaovenda)
     {
      AtualizarBook(opcaovenda,opc2_buy_book,opc2_sell_book);
     }

   if(EntrarOperacao() && !Buy_opened() && !OrdemAberta(ORDER_TYPE_BUY_LIMIT)&&!OrdemAberta(ORDER_TYPE_SELL_LIMIT))
     {
      mytrade.BuyLimit(Lot,opc1_sell_book[0].price,opcaocompra,0,0,0,0,"COMPRA IN");
      compra_in_ticket=mytrade.ResultOrder();

     }

   if(SairOperacao() && Sell_opened() && !OrdemAberta(ORDER_TYPE_BUY_LIMIT)&&!OrdemAberta(ORDER_TYPE_SELL_LIMIT))
     {
      mytrade.BuyLimit(Lot,opc2_sell_book[0].price,opcaovenda,0,0,0,0,"COMPRA OUT");
      compra_out_ticket=mytrade.ResultOrder();

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

      tradeOn=true;

     }

   lucro_total=LucroOrdens()+LucroPositions();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

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
//   if(timerOn==false)
//     {
//      if(OrdersTotal()>0)DeleteALL();
//      if(PositionsTotal()>0)CloseALL();
//
//     }

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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(tradeOn && timerOn)

     {// inicio Trade On

      if(newbar_ind.isNewBar(iTime[0]))
        {

        }//Fim NewBar

     }//End Trade On
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//else
//  {
//   if(Daytrade==true)
//     {
//      DeleteALL();
//      CloseALL();
//     }
//  } // fechou ordens pendentes no Day trade fora do horario

  }
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


bool EntrarOperacao()
  {
   bool signal=opc1_sell_book[0].price-opc2_buy_book[0].price<=spread_entry && opc2_buy_book[0].price>0 && opc1_sell_book[0].price>0;
   bool s_vol=opc2_buy_book[0].volume>=Lot && opc1_sell_book[0].volume>=Lot;
   return signal&&s_vol;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SairOperacao()
  {
   bool signal=opc1_buy_book[0].price-opc2_sell_book[0].price>=spread_exit && opc1_buy_book[0].price>0 && opc2_sell_book[0].price>0;
   bool s_vol=opc1_buy_book[0].volume>=Lot&opc2_sell_book[0].volume>=Lot;
   return signal&&s_vol;

  }
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
//------------------------------------------------------------------------
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
         if(myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool OrdemAbertaOpcao(const ENUM_ORDER_TYPE order_type,string simbolo)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==simbolo && myorder.Magic()==Magic_Number)
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

void AtualizarBook(string ativo,infobook &arrayBuy[],infobook &arraySell[])
  {
   int cont_buy;
   int cont_sell;
   int tamanhobook;
   int contador;

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
         ExtDialog.OnTick();

     }//Fim MarketbookGet

  }
//+------------------------------------------------------------------+

void BuscaOpcoes(string ativo_base,string serie_opc,desc_opcao &array_lista[],int  &cont)
  {
   string cod_opc;
   int k;
   datetime expiracao;
   string opcao;

   int total=SymbolsTotal(false);
   cont=0;
   for(int i=0;i<total;i++)
     {
      cod_opc=SymbolName(i,false);
      expiracao=SymbolInfoInteger(Symbol(),SYMBOL_EXPIRATION_TIME);

      if(StringFind(SymbolInfoString(cod_opc,SYMBOL_ISIN),ativo_base)!=-1 && StringSubstr(SymbolInfoString(cod_opc,SYMBOL_ISIN),7,1)==serie_opc)
        {
         opcao=SymbolInfoString(cod_opc,SYMBOL_DESCRIPTION);

         string strike=StringSubstr(opcao,17,-1);
         k=StringReplace(strike,",",".");
         double valor_strike=StringToDouble(strike);
         valor_strike=NormalizeDouble(valor_strike,2);
         array_lista[cont].codigo=cod_opc;
         array_lista[cont].descricao=cod_opc+"  "+strike;
         array_lista[cont].strike=valor_strike;
         cont+=1;

        }

     }

//---
  }
//+------------------------------------------------------------------+
string FindCodigo(desc_opcao &array_lista[],string descricao)
  {
   for(int i=0;i<200;i++)
      if(array_lista[i].descricao==descricao)return array_lista[i].codigo;
   return("");
  }
//+------------------------------------------------------------------+
