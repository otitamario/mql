//+------------------------------------------------------------------+
#property copyright "Luis"
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

CLabel            m_label[500];

#define TENTATIVAS 10 // Tentativas envio ordem
#define VALIDADE   D'2018.10.31 23:59:59'//Data de Validade Validade
#define NUMERO_CONTA 9011600   //Numero da conta
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

   string str_pos;
   if(!PosicaoAberta())str_pos="ZERADO";
   if(Buy_opened() && myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick)))str_pos="COMPRADO";
   if(Sell_opened() && myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick)))str_pos="VENDIDO";

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"POSIÇÃO DAY TRADE: "+str_pos,xx1,yy1,xx2,yy2))
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

   string qtd;
   if(!PosicaoAberta())qtd="-";
   else
     {
      myposition.SelectByMagic(Symbol(),Magic_Number);
      qtd=DoubleToString(myposition.Volume(),2);
     }

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"QUANTIDADE: "+qtd,xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+3*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   string medio;
   if(!PosicaoAberta())medio="-";
   else
     {
      myposition.SelectByMagic(Symbol(),Magic_Number);
      medio=DoubleToString(myposition.PriceOpen(),mysymbol.Digits());
     }

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"MÉDIO: "+medio,xx1,yy1,xx2,yy2))
      return(false);


   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],"RESULTADO ABERTO: "+DoubleToString(LucroPositions(),2),xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+5*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[5],"RESULTADO TOTAL: "+DoubleToString(lucro_total,2),xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+6*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[6],"GAP LIMITE: "+DoubleToString(pts_gap,mysymbol.Digits())+" ATINGIDO: "+Gap(),xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+7*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[7],"PONTOS GAP: "+DoubleToString(Pts_Gap(),mysymbol.Digits()),xx1,yy1,xx2,yy2))
      return(false);


//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnTick(void)
  {
   string str_pos;
   if(!PosicaoAberta())str_pos="ZERADO";
   if(Buy_opened() && myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick)))str_pos="COMPRADO";
   if(Sell_opened() && myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick)))str_pos="VENDIDO";

   m_label[0].Text("POSIÇÃO DAY TRADE: "+str_pos);
   m_label[1].Text("ENTRADAS NO DIA: "+DoubleToString(GlobalVariableGet(glob_entr_tot),0));
   string qtd;
   if(!PosicaoAberta())qtd="-";
   else
     {
      myposition.SelectByMagic(Symbol(),Magic_Number);
      qtd=DoubleToString(myposition.Volume(),2);
     }
   m_label[2].Text("QUANTIDADE: "+qtd);

   string medio;
   if(!PosicaoAberta())medio="-";
   else
     {
      myposition.SelectByMagic(Symbol(),Magic_Number);
      medio=DoubleToString(myposition.PriceOpen(),mysymbol.Digits());
     }

   m_label[3].Text("MÉDIO: "+medio);

   m_label[4].Text("RESULTADO ABERTO: "+DoubleToString(LucroPositions(),2));
   m_label[5].Text("RESULTADO TOTAL: "+DoubleToString(lucro_total,2));
   m_label[6].Text("GAP LIMITE: "+DoubleToString(pts_gap,mysymbol.Digits())+" ATINGIDO: "+Gap());
   m_label[7].Text("PONTOS GAP: "+DoubleToString(Pts_Gap(),mysymbol.Digits()));



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
CiMA *media;
CiMA *media_sec;

CControlsDialog ExtDialog;
// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=11;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input double Lot=1;//Lote Entrada
input double _Stop=16; //Stop Loss Máximo em Pontos
input double _TakeProfit=2.0; //Take Profit em Pontos

sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes no Dia
sinput string shorario="############------FILTRO DE HORARIO------#################";
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:00";//Horario Inicial
input string end_hour_entr="17:00";//Horario Final Entradas
input string end_hour="17:30";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario

sinput string SEst_Med="############-------------Estratégia----------########";
input int   period_media=7;//Periodo da Media
input ENUM_MA_METHOD modo_media=MODE_EMA;//Modo da Média
input double dist_media=2.0;//Distância da Média em Pontos
sinput string Spontos_aumento="############-----------Pontos Aumento de Posição----------########";
input double pt_aum1=2.0;//Pontos Aumento de Posição 1 (0 Não usar)
input double pt_aum2=4.0;//Pontos Aumento de Posição 2 (0 Não usar)
input double pt_aum3=6.0;//Pontos Aumento de Posição 3 (0 Não usar)
input double pt_aum4=8.0;//Pontos Aumento de Posição 4 (0 Não usar)
input double pt_aum5=10.0;//Pontos Aumento de Posição 5 (0 Não usar)
input double pt_aum6=12.0;//Pontos Aumento de Posição 6 (0 Não usar)

sinput string Slotes_aumento="############-----------Lotes Aumento de Posição----------########";
input double lote_aum1=1.0;//Lotes Aumento de Posição 1 (0 Não usar)
input double lote_aum2=1.0;//Lotes Aumento de Posição 2 (0 Não usar)
input double lote_aum3=2.0;//Lotes Aumento de Posição 3 (0 Não usar)
input double lote_aum4=2.0;//Lotes Aumento de Posição 4 (0 Não usar)
input double lote_aum5=4.0;//Lotes Aumento de Posição 5 (0 Não usar)
input double lote_aum6=4.0;//Lotes Aumento de Posição 6 (0 Não usar)

sinput string SsaidSec="-------Saída Média Secundária-------------";
input int period_med_sec=5;//Período Média Secundária
input ulong saida_sec=4;//Aum de Pos p acionar Fech Média Sec/ 0 Não Sair na Secundária
sinput string SGap="--------Filtro de Gap----------";
input OpcaoGap UsarGap=Operar_Apos_Toque_Media;//Opção de Gap
input double pts_gap=10;//Gap em Pontos para Filtrar Entradas

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
string tp_vd_tick="tp_vd_tick"+Symbol()+IntegerToString(Magic_Number),tp_cp_tick="tp_cp_tick"+Symbol()+IntegerToString(Magic_Number);

string deals_total="deals_total"+Symbol()+IntegerToString(Magic_Number),deals_total_prev="deals_total_prev"+Symbol()+IntegerToString(Magic_Number);
string close_buy_sec="close_buy_sec"+Symbol()+IntegerToString(Magic_Number),close_sell_sec="close_sell_sec"+Symbol()+IntegerToString(Magic_Number);
string gv_today="gv_today"+Symbol()+IntegerToString(Magic_Number),gv_today_prev="gv_today_prev"+Symbol()+IntegerToString(Magic_Number);

double buyprice,sellprice,oldprice;
string informacoes=" ";
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
int PrevPositions;
datetime time_novodia[4];
double lotes_stop;
int res_code;
int cont;
datetime hora_inicial,hora_final,hora_final_ent;
bool Conexao;
ulong time_conex=200;// Tempo em Milissegundos para testar conexão
double sl_position,tp_position;
double vol_pos,vol_stp,preco_stp;
MqlDateTime TimeNow;
uint total_deals,cont_deals;
ulong ticket_history_deal,deal_magic;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   ulong numero_conta=NUMERO_CONTA;
   datetime expiracao=VALIDADE;
   string msg_validade="Validade até "+TimeToString(expiracao)+" para a conta "+IntegerToString(numero_conta)+" "+myaccount.Server();
   MessageBox(msg_validade);
   Print(msg_validade);
   bool licenca=TimeCurrent()>expiracao || myaccount.Login()!=numero_conta;
   if(licenca)
     {
      string erro="Licença Inválida";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   Conexao=IsConnect();
   EventSetMillisecondTimer(time_conex);
   TimeToStruct(TimeCurrent(),TimeNow);
   GlobalVariableSet(gv_today_prev,(double)TimeNow.day_of_year);

   original_symbol=Symbol();

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
   if(find_dol>=0|| find_wdo>=0)ponto=1.0;

   curChartID=ChartID();

   media=new CiMA;
   media.Create(Symbol(),periodoRobo,period_media,0,modo_media,PRICE_CLOSE);
   media.AddToChart(curChartID,0);

   media_sec=new CiMA;
   media_sec.Create(Symbol(),periodoRobo,period_med_sec,0,modo_media,PRICE_CLOSE);
   media_sec.AddToChart(curChartID,0);


   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   hora_final_ent=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_entr);

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(hora_final_ent<=hora_inicial || hora_final_ent>=hora_final)
     {
      string erro="Hora Final das Entradas deve estar entre  Horário Inicial e Final";
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

   if(_Stop<=pt_aum1 || _Stop<=pt_aum2 || _Stop<=pt_aum3 || _Stop<=pt_aum4 || _Stop<=pt_aum5 || _Stop<=pt_aum6)

     {
      string erro="O Stop Máximo deve ser maior que todos pontos de aumento entrada ";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);

     }

//Global Variables Check

   if(!GlobalVariableCheck(glob_entr_tot))GlobalVariableSet(glob_entr_tot,0.0);
   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0.0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0.0);
   if(!GlobalVariableCheck(tp_cp_tick))GlobalVariableSet(tp_cp_tick,0.0);
   if(!GlobalVariableCheck(tp_vd_tick))GlobalVariableSet(tp_vd_tick,0.0);

   if(!GlobalVariableCheck(close_buy_sec))GlobalVariableSet(close_buy_sec,0.0);
   if(!GlobalVariableCheck(close_sell_sec))GlobalVariableSet(close_sell_sec,0.0);

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,240,270))
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
   delete(media);
   delete(media_sec);
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
   mysymbol.Refresh();
   mysymbol.RefreshRates();
   media.Refresh();
   media_sec.Refresh();
   ExtDialog.OnTick();
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   hora_final_ent=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_entr);

   TimeToStruct(TimeCurrent(),TimeNow);
   GlobalVariableSet(gv_today,(double)TimeNow.day_of_year);

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
   if(novodia || GlobalVariableGet(gv_today)!=GlobalVariableGet(gv_today_prev))
     {
      GlobalVariableSet(glob_entr_tot,0.0);
      tradeOn=true;

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
   if(UseTimer==true)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final;
      timerEnt=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final_ent;

     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened())
     {
      DeleteALL();
      CloseByPosition();
     }
   if(!PosicaoAberta() && OrdersTotal()>0)DeleteALL();
   if(!PosicaoAberta())
     {
      GlobalVariableSet(close_buy_sec,0.0);
      GlobalVariableSet(close_sell_sec,0.0);
     }
   if(tradeOn && timerOn)

     {// inicio Trade On

      Atual_vol_Stop_Take();

      if(timerEnt && gapOn)
        {

         if(BuySignal() && !Buy_opened())
           {
            if(Sell_opened())ClosePosType(POSITION_TYPE_SELL);
            DeleteALL();
            if(mytrade.Buy(Lot,original_symbol,0,NormalizeDouble(bid-_Stop*ponto,digits),0,"BUY"+exp_name))
              {
               GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
              }
            else Print("Erro enviar ordem ",GetLastError());
           }

         if(SellSignal() && !Sell_opened())
           {
            if(Buy_opened())ClosePosType(POSITION_TYPE_BUY);
            DeleteALL();
            if(mytrade.Sell(Lot,original_symbol,0,NormalizeDouble(ask+_Stop*ponto,digits),0,"SELL"+exp_name))
              {
               GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
              }
            else Print("Erro enviar ordem ",GetLastError());

           }
        }// Fim Time Entradas
      MytradeTransaction();

      if(CheckBuyClose() && Buy_opened())
        {
         ClosePosType(POSITION_TYPE_BUY);
         DeleteOrders(ORDER_TYPE_BUY_LIMIT);
        }
      if(CheckSellClose() && Sell_opened())
        {
         ClosePosType(POSITION_TYPE_SELL);
         DeleteOrders(ORDER_TYPE_SELL_LIMIT);
        }

     }//End Trade On

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
            if(deal_magic==Magic_Number)cont_deals+=1;
           }
        }
     }
   GlobalVariableSet(deals_total_prev,(double)cont_deals);

   TimeToStruct(TimeCurrent(),TimeNow);
   GlobalVariableSet(gv_today_prev,(double)TimeNow.day_of_year);

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
   bool b_signal=media.Main(0)-ask>=dist_media*ponto;
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
   bool s_signal=bid-media.Main(0)>=dist_media*ponto;
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
            if(deal_magic==Magic_Number)cont_deals+=1;
           }
        }

      GlobalVariableSet(deals_total,(double)cont_deals);

      if(GlobalVariableGet(deals_total)>GlobalVariableGet(deals_total_prev))
        {
         for(uint i=total_deals-1;i>=0;i--)
           {
            if(HistoryDealGetTicket(i)>0)
              {
               ulong deals_ticket=HistoryDealGetTicket(i);
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
                     buyprice=myposition.PriceOpen();
                     sl_position=NormalizeDouble(buyprice-_Stop*ponto,digits);
                     tp_position=NormalizeDouble(buyprice+_TakeProfit*ponto,digits);
                     mytrade.PositionModify(order_ticket,sl_position,0);
                     if(mytrade.SellLimit(Lot,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT"))
                       {
                        GlobalVariableSet(tp_vd_tick,(double)mytrade.ResultOrder());
                       }
                     else Print("Erro enviar ordem: ",GetLastError());

                     Aumento_Buy();
                    }
                  //--------------------------------------------------

                  if(order_ticket==(ulong)GlobalVariableGet(vd_tick))
                    {
                     myposition.SelectByTicket(order_ticket);
                     sellprice=myposition.PriceOpen();
                     sl_position=NormalizeDouble(sellprice+_Stop*ponto,digits);
                     tp_position=NormalizeDouble(sellprice-_TakeProfit*ponto,digits);
                     mytrade.PositionModify(order_ticket,sl_position,0);
                     if(mytrade.BuyLimit(Lot,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT"))
                       {
                        GlobalVariableSet(tp_cp_tick,(double)mytrade.ResultOrder());
                       }
                     else Print("Erro enviar ordem: ",GetLastError());
                     Aumento_Sell();
                    }
                  if(saida_sec>0)
                    {
                     if(mydeal.Comment()=="BUY_"+IntegerToString(saida_sec)+exp_name)
                       {
                        Print("Ativado Saída pela Média Secundária");
                        GlobalVariableSet(close_buy_sec,1.0);
                       }
                     if(mydeal.Comment()=="SELL_"+IntegerToString(saida_sec)+exp_name)
                       {
                        Print("Ativado Saída pela Média Secundária");
                        GlobalVariableSet(close_sell_sec,1.0);
                       }
                    }

                  return;
                 }//Fim mydeal symbol
              }// if histoticket>0
           }//Fim for total_deals
        }//Fim deals>prev
     }//Fim HistorySelect
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void Aumento_Buy()
  {
   myposition.SelectByTicket((ulong)GlobalVariableGet(cp_tick));
   double preco_entr=myposition.PriceOpen();
   double preco_stop=myposition.StopLoss();
   double preco_take=myposition.TakeProfit();
   if(pt_aum1>0)mytrade.BuyLimit(lote_aum1,NormalizeDouble(preco_entr-pt_aum1*ponto,digits),original_symbol,preco_stop,preco_take,0,0,"BUY_1"+exp_name);
   if(pt_aum2>0)mytrade.BuyLimit(lote_aum2,NormalizeDouble(preco_entr-pt_aum2*ponto,digits),original_symbol,preco_stop,preco_take,0,0,"BUY_2"+exp_name);
   if(pt_aum3>0)mytrade.BuyLimit(lote_aum3,NormalizeDouble(preco_entr-pt_aum3*ponto,digits),original_symbol,preco_stop,preco_take,0,0,"BUY_3"+exp_name);
   if(pt_aum4>0)mytrade.BuyLimit(lote_aum4,NormalizeDouble(preco_entr-pt_aum4*ponto,digits),original_symbol,preco_stop,preco_take,0,0,"BUY_4"+exp_name);
   if(pt_aum5>0)mytrade.BuyLimit(lote_aum5,NormalizeDouble(preco_entr-pt_aum5*ponto,digits),original_symbol,preco_stop,preco_take,0,0,"BUY_5"+exp_name);
   if(pt_aum6>0)mytrade.BuyLimit(lote_aum6,NormalizeDouble(preco_entr-pt_aum6*ponto,digits),original_symbol,preco_stop,preco_take,0,0,"BUY_6"+exp_name);

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
void Aumento_Sell()
  {
   myposition.SelectByTicket((ulong)GlobalVariableGet(vd_tick));
   double preco_entr=myposition.PriceOpen();
   double preco_stop=myposition.StopLoss();
   double preco_take=myposition.TakeProfit();
   if(pt_aum1>0)mytrade.SellLimit(lote_aum1,NormalizeDouble(preco_entr+pt_aum1*ponto,digits),original_symbol,preco_stop,preco_take,0,0,"SELL_1"+exp_name);
   if(pt_aum2>0)mytrade.SellLimit(lote_aum2,NormalizeDouble(preco_entr+pt_aum2*ponto,digits),original_symbol,preco_stop,preco_take,0,0,"SELL_2"+exp_name);
   if(pt_aum3>0)mytrade.SellLimit(lote_aum3,NormalizeDouble(preco_entr+pt_aum3*ponto,digits),original_symbol,preco_stop,preco_take,0,0,"SELL_3"+exp_name);
   if(pt_aum4>0)mytrade.SellLimit(lote_aum4,NormalizeDouble(preco_entr+pt_aum4*ponto,digits),original_symbol,preco_stop,preco_take,0,0,"SELL_4"+exp_name);
   if(pt_aum5>0)mytrade.SellLimit(lote_aum5,NormalizeDouble(preco_entr+pt_aum5*ponto,digits),original_symbol,preco_stop,preco_take,0,0,"SELL_5"+exp_name);
   if(pt_aum6>0)mytrade.SellLimit(lote_aum6,NormalizeDouble(preco_entr+pt_aum6*ponto,digits),original_symbol,preco_stop,preco_take,0,0,"SELL_6"+exp_name);

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

bool CheckSellClose()
  {
   bool dist=ask<=media.Main(0);
   bool sec=false;
   if(GlobalVariableGet(close_sell_sec)==1.0)sec=ask<=media_sec.Main(0);
   return (dist||sec);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckBuyClose()
  {
   bool dist=bid>=media.Main(0);
   bool sec=false;
   if(GlobalVariableGet(close_buy_sec)==1.0)sec=bid>=media_sec.Main(0);
   return (dist||sec);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//|                                                                  |
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
void Atual_vol_Stop_Take()
  {

   if(PosicaoAberta())
     {
      if(Buy_opened())
        {
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

        }
      if(Sell_opened())
        {

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
        }
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
