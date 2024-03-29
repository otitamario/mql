//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
enum Sentido
  {
   Compra,// Compra
   Venda        //Venda
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum FiltroLucro
  {
   ProfitRobo,//Lucro Apenas do Robô
   ProfitGlob//Lucro de Todos Robôs
  };

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>
#include <Controls\Dialog.mqh>

CLabel            m_label[50];
CButton BotaoFechar;
CButton BotaoFecharGrupo;

#define LARGURA_PAINEL 310 // Largura Painel
#define ALTURA_PAINEL 160 // Altura Painel

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


   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"MART LEVEL: "+DoubleToString(MathMax(GlobalVariableGet(glob_mart_level)-1,0),0),xx1,yy1,xx2,yy2))
      return(false);
   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;
   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"ENTRADAS NO DIA: "+IntegerToString(ENTRADAS_TOTAL),xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+3*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;
   string str_pos;
   if(!PosicaoAberta())str_pos="ZERADO";
   if(Buy_opened()&&myposition.SelectByTicket(compra1_ticket))str_pos="COMPRADO";
   if(Sell_opened()&&myposition.SelectByTicket(venda1_ticket))str_pos="VENDIDO";

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"POSIÇÃO: "+str_pos,xx1,yy1,xx2,yy2))
      return(false);


   xx1=LARGURA_PAINEL-2*INDENT_RIGHT-BUTTON_WIDTH;
//yy1 = INDENT_TOP +  BUTTON_HEIGHT + CONTROLS_GAP_Y;
   yy1=INDENT_TOP+CONTROLS_GAP_Y;

   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;



   if(!CreateButton(m_chart_id,m_subwin,BotaoFechar,"ZERAR",xx1,yy1,xx2,yy2))
      return(false);
   BotaoFechar.ColorBackground(clrLime);

   xx1 = LARGURA_PAINEL-2*INDENT_RIGHT-BUTTON_WIDTH;
   yy1 = INDENT_TOP +  BUTTON_HEIGHT + 3*CONTROLS_GAP_Y;

   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;



   if(!CreateButton(m_chart_id,m_subwin,BotaoFecharGrupo,"ZERAR Robô",xx1,yy1,xx2,yy2))
      return(false);
   BotaoFecharGrupo.ColorBackground(clrLime);

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnTick(void)
  {
   m_label[0].Text("RESULTADO: "+DoubleToString(lucro_total,2));
   m_label[1].Text("MART LEVEL: "+DoubleToString(MathMax(GlobalVariableGet(glob_mart_level)-1,0),0));
   m_label[2].Text("ENTRADAS NO DIA: "+IntegerToString(ENTRADAS_TOTAL));
   string str_pos;
   if(!PosicaoAberta())str_pos="ZERADO";
   if(Buy_opened()&&myposition.SelectByTicket(compra1_ticket))str_pos="COMPRADO";
   if(Sell_opened()&&myposition.SelectByTicket(venda1_ticket))str_pos="VENDIDO";

   m_label[3].Text("POSIÇÃO: "+str_pos);
  }
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(CControlsDialog)
ON_EVENT(ON_CLICK,BotaoFechar,OnClickBotaoFechar)
ON_EVENT(ON_CLICK,BotaoFecharGrupo,OnClickBotaoFecharGrupo)

EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
void OnClickBotaoFechar()
  {
   DeleteALLGlobal();
   CloseALLGlobal();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnClickBotaoFecharGrupo()
  {
   DeleteALL();
   CloseALL();
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
input ulong Magic_Number=15072018;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input Sentido sentido=Compra;//Primeira Entrada
input double Lot=1;//Lote Entrada
input double Lot_st_ini=3;//Lote Inicial Stops
input double _Stop=12;//Stop Loss em Pontos
input double _TakeProfit=6; //Take Profit em Pontos
input string start_hour="9:04";//Horario da Entrada Inicial
sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";
input bool UsarLucro=false;//Usar Lucro para Fechamento True/False
input FiltroLucro filtrolucro=ProfitGlob;//Tipo de Filtro Lucro
input double lucro=1000.0;//Lucro para Fechar Posicoes
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes
sinput string STrailing="############---------------Trailing Stop----------########";

sinput string shorario="############------FILTRO DE HORARIO------#################";

input bool UseTimer=false;//Usar Filtro de Horário: True/False
input int StartHour = 9;//Hora de Inicio
input int StartMinute=0;//Minuto de Inicio

sinput string horafech="HORARIO PARA FECHAMENTO DE POSICOES E ORDENS";
input int EndHour=17;//Hora de Fechamento
input int EndMinute=30;//Minuto de Fechamento

sinput string sindicators="############------INDICADORES------#################";
input int per_ma_fast=10;//Período Média Rápida
input ENUM_MA_METHOD mode_fast=MODE_EMA;//Modo Média Rápida
input int per_ma_sLow=40;//Período Média Lenta
input ENUM_MA_METHOD mode_sLow=MODE_EMA;//Modo Média Lenta

                                        //Variaveis 
string original_symbol;
double Ask,Bid;
double lucro_total,pontos_total,lucro_liquido;
bool TimerOn,tradeOn;
double ponto,ticksize;
int _digits;
long curChartID;
double High[],Low[],Open[],Close[];
ulong ENTRADAS_TOTAL,MART_LEVEL;
ulong trade_ticket,compra1_ticket,venda1_ticket,mart_sell_ticket,mart_buy_ticket,tp_venda_ticket,tp_compra_ticket;
ulong tp_mt_venda_ticket,tp_mt_compra_ticket;
double price_Open;
string glob_entr_tot="ENT_TOT"+Symbol()+IntegerToString(Magic_Number);
string glob_mart_level="MART_LEVEL"+Symbol()+IntegerToString(Magic_Number);
string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string mart_cp_tick="mart_cp_tick"+Symbol()+IntegerToString(Magic_Number),mart_vd_tick="mart_vd_tick"+Symbol()+IntegerToString(Magic_Number);
string glob_buy_price="buy_price"+Symbol()+IntegerToString(Magic_Number);
string glob_sell_price="sell_price"+Symbol()+IntegerToString(Magic_Number);
string tp_vd_tick="tp_vd_tick"+Symbol()+IntegerToString(Magic_Number),tp_cp_tick="tp_cp_tick"+Symbol()+IntegerToString(Magic_Number);
string tp_mt_vd_tick="tp_vd_tick"+Symbol()+IntegerToString(Magic_Number),tp_mt_cp_tick="tp_cp_tick"+Symbol()+IntegerToString(Magic_Number);

double buyprice,sellprice,oldprice;
string informacoes=" ";
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
int PrevPositions;
datetime time_novodia[4];
double lotes_stop;
ulong res_code;
int cont;
double preco_take;
double tp_position,sl_position;
datetime hora_inicial;
bool buy_sent,sell_sent;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   buy_sent=false;
   sell_sent=false;
   EventSetMillisecondTimer(200);
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);

   original_symbol=Symbol();
   tradeOn=true;
   trade_ticket=0;
   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.SetDeviationInPoints(deviation_points);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
   if(IsFillingTypeAlLowed(SYMBOL_FILLING_FOK))
      Print("ORDER_FILLING_FOK");
   else if(IsFillingTypeAlLowed(SYMBOL_FILLING_IOC))
      Print("ORDER_FILLING_IOC");
   else
      Print("ORDER_FILLING_RETURN");
   if(IsFillingTypeAlLowed(SYMBOL_FILLING_FOK))
      mytrade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAlLowed(SYMBOL_FILLING_IOC))
      mytrade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      mytrade.SetTypeFilling(ORDER_FILLING_RETURN);
   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
   _digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);

   int find_wdo=StringFind(original_symbol,"WDO");
   int find_dol=StringFind(original_symbol,"DOL");
   if(find_dol>=0|| find_wdo>=0) ponto=1.0;

   lucro_total=0.0;
   pontos_total=0.0;
   informacoes=" ";

   curChartID=ChartID();

   ArraySetAsSeries(Close,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Open,true);

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

   if(!GlobalVariableCheck(glob_entr_tot))GlobalVariableSet(glob_entr_tot,0.0);
   if(!GlobalVariableCheck(glob_mart_level))GlobalVariableSet(glob_mart_level,0.0);
   if(!GlobalVariableCheck(glob_buy_price))GlobalVariableSet(glob_buy_price,0.0);
   if(!GlobalVariableCheck(glob_sell_price))GlobalVariableSet(glob_sell_price,0.0);
   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0.0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0.0);
   if(!GlobalVariableCheck(mart_cp_tick))GlobalVariableSet(mart_cp_tick,0.0);
   if(!GlobalVariableCheck(mart_vd_tick))GlobalVariableSet(mart_vd_tick,0.0);
   if(!GlobalVariableCheck(tp_cp_tick))GlobalVariableSet(tp_cp_tick,0.0);
   if(!GlobalVariableCheck(tp_vd_tick))GlobalVariableSet(tp_vd_tick,0.0);
   if(!GlobalVariableCheck(tp_mt_cp_tick))GlobalVariableSet(tp_mt_cp_tick,0.0);
   if(!GlobalVariableCheck(tp_mt_vd_tick))GlobalVariableSet(tp_mt_vd_tick,0.0);

   if(!PosicaoAberta() && GlobalVariableGet(glob_mart_level)>0)GlobalVariableSet(glob_mart_level,0.0);

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
      return(INIT_FAILED);
//--- run application 

   ExtDialog.Run();

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeletaIndicadores();
   ExtDialog.Destroy(reason);
   HLineDelete(0,"Stop Loss");
   HLineDelete(0,"Take Profit");
   Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");
   EventKillTimer();

//---

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   if(mysymbol.Bid()==0 || mysymbol.Ask()==0)
     {
      Print(" BID ou ASK=0 ");
      return;
     }

   if(!TerminalInfoInteger(TERMINAL_CONNECTED))return;
   if(mysymbol.Bid()>=mysymbol.Ask())return;

   if(TimeCurrent()==hora_inicial)
     {
      if(BuySignal() && !Buy_opened() && !buy_sent)
        {
         buy_sent=true;
         sl_position=NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_BID)-_Stop*ponto,_digits);
         tp_position=NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_ASK)+_TakeProfit*ponto,_digits);

         if(mytrade.Buy(Lot,original_symbol,0,sl_position,tp_position,start_hour+"_"+"BUY"+exp_name))
           {
            trade_ticket=mytrade.ResultOrder();
            compra1_ticket=trade_ticket;
            GlobalVariableSet(cp_tick,(double)compra1_ticket);
           }
         else Print("Erro enviar ordem ",GetLastError());
        }

      if(SellSignal() && !Sell_opened() && !sell_sent)
        {
         sell_sent=true;
         sl_position=NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_ASK)+_Stop*ponto,_digits);
         tp_position=NormalizeDouble(SymbolInfoDouble(Symbol(),SYMBOL_BID)-_TakeProfit*ponto,_digits);

         if(mytrade.Sell(Lot,original_symbol,0,sl_position,tp_position,start_hour+"_"+"SELL"+exp_name))
           {
            trade_ticket=mytrade.ResultOrder();
            venda1_ticket=trade_ticket;
            GlobalVariableSet(vd_tick,(double)venda1_ticket);
           }
         else Print("Erro enviar ordem ",GetLastError());
        }
     }
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
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {

   if(trans.symbol!=original_symbol)return;

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
         GlobalVariableSet(glob_buy_price,buyprice);
         sl_position=NormalizeDouble(buyprice-_Stop*ponto,_digits);
         tp_position=NormalizeDouble(buyprice+_TakeProfit*ponto,_digits);
         mytrade.PositionModify(compra1_ticket,sl_position,0);
         mytrade.SellLimit(Lot,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT");
         tp_venda_ticket=mytrade.ResultOrder();
         GlobalVariableSet(tp_vd_tick,(double)tp_venda_ticket);
         HLineCreate(0,"Take Profit",0,tp_position,clrLime,STYLE_DASH,2,false,false,true,0);
         HLineCreate(0,"Stop Loss",0,sl_position,clrRed,STYLE_DASH,2,false,false,true,0);
         sellprice=NormalizeDouble(buyprice-_TakeProfit*ponto,_digits);
         GlobalVariableSet(glob_sell_price,sellprice);
         mytrade.SellStop(Lot_st_ini,sellprice,original_symbol,tp_position,0,0,0,"1_Level_Martingale");
         mart_sell_ticket=mytrade.ResultOrder();
         GlobalVariableSet(mart_vd_tick,(double)mart_sell_ticket);
         MART_LEVEL+=1;
         GlobalVariableSet(glob_mart_level,(double)MART_LEVEL);

        }
      //--------------------------------------------------

      if(order_ticket==venda1_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         myposition.SelectByTicket(venda1_ticket);
         sellprice=myposition.PriceOpen();
         GlobalVariableSet(glob_sell_price,sellprice);
         sl_position=NormalizeDouble(sellprice+_Stop*ponto,_digits);
         tp_position=NormalizeDouble(sellprice-_TakeProfit*ponto,_digits);
         mytrade.PositionModify(venda1_ticket,sl_position,0);
         mytrade.BuyLimit(Lot,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT");
         tp_compra_ticket=mytrade.ResultOrder();
         GlobalVariableSet(tp_cp_tick,(double)tp_compra_ticket);
         HLineCreate(0,"Take Profit",0,tp_position,clrLime,STYLE_DASH,2,false,false,true,0);
         HLineCreate(0,"Stop Loss",0,sl_position,clrRed,STYLE_DASH,2,false,false,true,0);
         buyprice=NormalizeDouble(sellprice+_TakeProfit*ponto,_digits);
         GlobalVariableSet(glob_buy_price,buyprice);
         mytrade.BuyStop(Lot_st_ini,buyprice,original_symbol,tp_position,0,0,0,"1_Level_Martingale");
         mart_buy_ticket=mytrade.ResultOrder();
         GlobalVariableSet(mart_cp_tick,(double)mart_buy_ticket);
         MART_LEVEL+=1;
         GlobalVariableSet(glob_mart_level,(double)MART_LEVEL);

        }
      //--------------------------------------------------

      if(order_ticket==mart_sell_ticket && trans.order_type==ORDER_TYPE_SELL_STOP && trans.order_state==ORDER_STATE_FILLED)
        {
         if(MART_LEVEL==1)
           {
            mytrade.BuyLimit(Lot_st_ini,NormalizeDouble(sellprice-_TakeProfit*ponto,_digits),original_symbol,0,0,0,0,"MT_TAKEPROFIT");
            tp_mt_compra_ticket=mytrade.ResultOrder();
            GlobalVariableSet(tp_mt_cp_tick,(double)tp_mt_compra_ticket);
           }
         MART_LEVEL+=1;
         GlobalVariableSet(glob_mart_level,(double)MART_LEVEL);

         if(buyprice>Ask)
           {
            mytrade.BuyStop((pow(2,MART_LEVEL-1))*Lot_st_ini,buyprice,original_symbol,NormalizeDouble(buyprice-_Stop*ponto,_digits),NormalizeDouble(buyprice+_TakeProfit*ponto,_digits),0,0,IntegerToString(MART_LEVEL)+"_Level_Martingale");
            mart_buy_ticket=mytrade.ResultOrder();
            GlobalVariableSet(mart_cp_tick,(double)mart_buy_ticket);
           }
        }

      if(order_ticket==mart_buy_ticket && trans.order_type==ORDER_TYPE_BUY_STOP && trans.order_state==ORDER_STATE_FILLED)
        {

         if(MART_LEVEL==1)
           {
            mytrade.SellLimit(Lot_st_ini,NormalizeDouble(buyprice+_TakeProfit*ponto,_digits),original_symbol,0,0,0,0,"MT_TAKEPROFIT");
            tp_mt_venda_ticket=mytrade.ResultOrder();
            GlobalVariableSet(tp_mt_vd_tick,(double)tp_mt_venda_ticket);
           }
         MART_LEVEL+=1;
         GlobalVariableSet(glob_mart_level,(double)MART_LEVEL);

         if(Bid>sellprice)
           {
            mytrade.SellStop((pow(2,MART_LEVEL-1))*Lot_st_ini,sellprice,original_symbol,NormalizeDouble(sellprice+_Stop*ponto,_digits),NormalizeDouble(sellprice-_TakeProfit*ponto,_digits),0,0,IntegerToString(MART_LEVEL)+"_Level_Martingale");
            mart_sell_ticket=mytrade.ResultOrder();
            GlobalVariableSet(mart_vd_tick,(double)mart_sell_ticket);
           }
        }

      // Fechar Ordens e Posicoes

      if(order_ticket==tp_compra_ticket && trans.order_state==ORDER_STATE_FILLED)
        {

         MART_LEVEL=0;
         GlobalVariableSet(glob_mart_level,(double)MART_LEVEL);
         res_code=-1;
         cont=0;
         while(res_code<=0 && cont<TENTATIVAS)
           {
            mytrade.PositionCloseBy(venda1_ticket,tp_compra_ticket);
            res_code=mytrade.ResultOrder();
            Print("RES_CODE ",res_code);
            cont+=1;;
           }
         CloseALL();
         DeleteALL();
        }
      if(order_ticket==tp_venda_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         MART_LEVEL=0;
         GlobalVariableSet(glob_mart_level,(double)MART_LEVEL);
         res_code=-1;
         cont=0;
         while(res_code<=0 && cont<TENTATIVAS)
           {
            mytrade.PositionCloseBy(compra1_ticket,tp_venda_ticket);
            res_code=mytrade.ResultOrder();
            Print("RES_CODE ",res_code);
            cont+=1;;
           }
         CloseALL();
         DeleteALL();

        }

      if(order_ticket==tp_mt_compra_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         MART_LEVEL=0;
         GlobalVariableSet(glob_mart_level,(double)MART_LEVEL);
         res_code=-1;
         cont=0;
         while(res_code<=0 && cont<TENTATIVAS)
           {
            mytrade.PositionCloseBy(mart_sell_ticket,tp_mt_compra_ticket);
            res_code=mytrade.ResultOrder();
            Print("RES_CODE ",res_code);
            cont+=1;;
           }
         CloseALL();
         DeleteALL();
        }
      if(order_ticket==tp_mt_venda_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         MART_LEVEL=0;
         GlobalVariableSet(glob_mart_level,(double)MART_LEVEL);
         res_code=-1;
         cont=0;
         while(res_code<=0 && cont<TENTATIVAS)
           {
            mytrade.PositionCloseBy(mart_buy_ticket,tp_mt_venda_ticket);
            res_code=mytrade.ResultOrder();
            Print("RES_CODE ",res_code);
            cont+=1;;
           }
         CloseALL();
         DeleteALL();
        }

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



//+-------------ROTINAS----------------------------------------------+

void Main_Program()
  {
   mysymbol.Refresh();
   mysymbol.RefreshRates();
   ExtDialog.OnTick();

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
      buy_sent=false;
      sell_sent=false;

     }

   if(filtrolucro==ProfitRobo) lucro_total=LucroOrdens()+LucroPositions();
   else lucro_total=LucroGlobal();
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

   TimerOn=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer==true)
     {
      TimerOn=Timer.DailyTimer(StartHour,StartMinute,EndHour,EndMinute);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      TimerOn=true;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(TimerOn==false)
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
      Bid= last_tick.bid;
      Ask=last_tick.ask;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      Print("Falhou obter o tick");
      return;
     }
   double spread=Ask-Bid;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Bid==0 || Ask==0)
     {
      Print("Bid ou Ask=0 : ",Bid," ",Ask);
      return;
     }
   if(Bid>=Ask)return; //Leilão
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))return;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(!PosicaoAberta() && GlobalVariableGet(glob_sell_price)>0)GlobalVariableSet(glob_sell_price,0.0);
   if(!PosicaoAberta()  &&  GlobalVariableGet(glob_buy_price)>0)GlobalVariableSet(glob_buy_price,0.0);
   if(!PosicaoAberta())
     {
      DeleteALL();
      if(GlobalVariableGet(glob_mart_level)>0)GlobalVariableSet(glob_mart_level,0.0);
     }

   ENTRADAS_TOTAL=(int)GlobalVariableGet(glob_entr_tot);
   MART_LEVEL=(int)GlobalVariableGet(glob_mart_level);
   compra1_ticket=(int) GlobalVariableGet(cp_tick);
   venda1_ticket=(int) GlobalVariableGet(vd_tick);
   mart_buy_ticket=(int) GlobalVariableGet(mart_cp_tick);
   mart_sell_ticket=(int) GlobalVariableGet(mart_vd_tick);
   tp_compra_ticket=(int) GlobalVariableGet(tp_cp_tick);
   tp_venda_ticket=(int) GlobalVariableGet(tp_vd_tick);
   tp_mt_compra_ticket=(int) GlobalVariableGet(tp_mt_cp_tick);
   tp_mt_venda_ticket=(int) GlobalVariableGet(tp_mt_vd_tick);

   if(PosicaoAberta())buyprice=GlobalVariableGet(glob_buy_price);
   if(PosicaoAberta())sellprice=GlobalVariableGet(glob_sell_price);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(tradeOn && TimerOn)

     {// inicio Trade On

      if(!PosicaoAberta())
        {
         HLineDelete(0,"Stop Loss");
         HLineDelete(0,"Take Profit");
        }

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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   bool signal=false;
   signal=sentido==Compra && (bool)TerminalInfoInteger(TERMINAL_CONNECTED);
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SellSignal()
  {
   bool signal=false;
   signal=sentido==Venda && (bool)TerminalInfoInteger(TERMINAL_CONNECTED);
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
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   bool b_get;
   b_get=CopyHigh(Symbol(),periodoRobo,0,5,High)<=0 || 
         CopyOpen(Symbol(),periodoRobo,0,5,Open)<=0 || 
         CopyLow(Symbol(),periodoRobo,0,5,Low)<=0 || 
         CopyClose(Symbol(),periodoRobo,0,5,Close)<=0;
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
         if(myorder.Magic()==Magic_Number && myorder.Symbol()==mysymbol.Name() && MathAbs(myorder.PriceOpen()-Ask)>distancia*ponto)
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

//| Checks if the specified filling mode is alLowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAlLowed(int fill_type)
  {
//--- Obtain the value of the property that describes alLowed filling modes 
   int filling=mysymbol.TradeFillFlags();
//--- Return true, if mode fill_type is alLowed 
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
   int total_deals=HistoryDealsTotal();
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
//+------------------------------------------------------------------+
double LucroOrdensGlob()
  {
//--- request trade history
   datetime tm_end=TimeCurrent();
   MqlDateTime stm_end,time_aux;
   TimeToStruct(tm_end,stm_end);
   time_aux=stm_end;
   time_aux.hour= 0;
   time_aux.min = 0;
   time_aux.sec = 0;
   datetime tm_start=StructToTime(time_aux);
   HistorySelect(tm_start,tm_end);
   int total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0; i<total_deals; i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY)
            profit+=mydeal.Profit();
     }
   return (profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LucroPositionsGlob()
  {
   double profit=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(myposition.SelectByIndex(i))
         profit+=myposition.Profit();
   return profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LucroGlobal()
  {
   return LucroOrdensGlob() + LucroPositionsGlob();
  }
//+------------------------------------------------------------------+

void CloseALLGlobal()
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i))
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
void DeleteALLGlobal()
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
     {
      ulong o_ticket=OrderGetTicket(j);
      if(o_ticket!=0)
        {
         myorder.Select(o_ticket);
         mytrade.OrderDelete(o_ticket);
        }
     }
  }
//+------------------------------------------------------------------+
