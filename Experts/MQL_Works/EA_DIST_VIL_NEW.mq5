//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
#resource "\\Indicators\\Indic_Afastamento_Media_MATS.ex5"
#resource "\\Indicators\\Afastamento_Final_Ricardo.ex5"
#resource "\\Indicators\\bbandwidth_interv.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum OpcaoGap
  {
   Nao_Operar,//Não Operar
   Operar_Apos_Toque_Media,//Operar Após Toque na Média
   Operacoes_Normais //Operar Normalmente
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Operacao
  {
   Contra,//Contra-Tendência
   Favor //Favor da Tendência
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Sentido
  {
   Compra,//Operar Comprado
   Venda,//Operar Vendido
   Compra_e_Venda //Operar Comprado e Vendido
  };

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include<Trade\AccountInfo.mqh>
#include <Controls\Defines.mqh>

#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
#undef CONTROLS_LABEL_COLOR  

color borda_bg=clrLightCyan;//Cor Borda
color painel_bg=clrBlack;//Cor Painel
color cor_txt_borda_bg=clrBlack;//Cor Texto Borda
color cor_txt_pn_bg=clrWhite;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG          borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg

#include <Auxiliares.mqh>
//#include <Controls\Dialog.mqh>

CLabel            m_label[50];
CEdit          edit_painel;
#define TENTATIVAS 10 // Tentativas envio ordem
#define LARGURA_PAINEL 250 // Largura Painel
#define ALTURA_PAINEL 200 // Altura Painel
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

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"GAP LIMITE: "+DoubleToString(pts_gap,mysymbol.Digits())+" ATINGIDO: "+Gap(),xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],"PONTOS GAP: "+DoubleToString(Pts_Gap(),mysymbol.Digits()),xx1,yy1,xx2,yy2))
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
   m_label[3].Text("GAP LIMITE: "+DoubleToString(pts_gap,mysymbol.Digits())+" ATINGIDO: "+Gap());
   m_label[4].Text("PONTOS GAP: "+DoubleToString(Pts_Gap(),mysymbol.Digits()));

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
CiMA *media;
COrderInfo myorder;
CiRSI *rsi;

CControlsDialog ExtDialog;
// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=20082018;
input ulong deviation_points=5;//Deviation em Pontos(Padrao)
input OpcaoGap UsarGap=Operar_Apos_Toque_Media;//Opção de Gap
input double pts_gap=10;//Gap em Pontos para Filtrar Entradas
input double Lot=1;//Lote Fixo de Entrada
input double _Stop=5.0;//Stop Loss em Pontos
input double _TakeProfit=2.0; //Take Profit em Pontos
sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";//Lucro
input bool UsarLucro=false;//Usar Lucro/Prejuízo para Fechamento Diário True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes no Dia
sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:00";//Horario Inicial
input string end_hour="17:30";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario
sinput string SEst_Med="############-------------Estratégia----------########";//Estratégia
input int   period_media=7;//Periodo da Media
input ENUM_MA_METHOD modo_media=MODE_EMA;//Modo da Média
                                         //input double dist_media=2.0;//Distância da Média em Pontos
input Operacao operacao=Favor;//Operar a Favor ou Contra a Tendência
input Sentido operar=Compra_e_Venda;// Operar Comprado, Vendido
sinput string Srsi="############-------------IFR----------########";//IFR
input bool UsarRSI=true;// Usar Filtro IFR
input bool InvIFR=false;//Invertar IFR
input int   period_rsi=14;//Periodo IFR
input double sob_comp=70;//IFR Sobrecomprado
input double sob_vend=30;//IFR Sobrevendido
sinput string Safast="############-------------Afastamentos Ricardo----------########";//Afastamentos Ricardo
input uint period_delta=10; // Período da média das distâncias:
input double filtro_afastamento_positivo=150; //Calcular a média das distâncias maiores que:
input double   filtro_afastamento_negativo=-150; //Calcular a média das distâncias menores que:
uint  hora_inicio=8;
uint hora_fim=19;
sinput string Sbbandw="############-------------BBANDWIDTH----------########";//BBANDWIDTH
input int     InpBandsPeriod=20;       // Period
input int     InpBandsShift=0;         // Shift
input double  InpBandsDeviations=2.0;  // Deviation

input double  InpNivel1=0.002;  // Nível 1
input double  InpNivel2=0.006;  // Nível 2

sinput string Spontos_aumento="############-----------Pontos Aumento de Posição----------########";//Aumento
input double pt_aum1=1.0;//Pontos Aumento de Posição 1 (0 Não usar)
input double pt_aum2=2.0;//Pontos Aumento de Posição 2 (0 Não usar)
input double pt_aum3=3.0;//Pontos Aumento de Posição 3 (0 Não usar)
input double pt_aum4=0;//Pontos Aumento de Posição 4 (0 Não usar)
input double pt_aum5=0;//Pontos Aumento de Posição 5 (0 Não usar)
input double pt_aum6=0;//Pontos Aumento de Posição 6 (0 Não usar)

sinput string Slotes_aumento="############-----------Lotes Aumento de Posição----------########";//Lotes
input double lote_aum1=1.0;//Lotes Aumento de Posição 1 (0 Não usar)
input double lote_aum2=2.0;//Lotes Aumento de Posição 2 (0 Não usar)
input double lote_aum3=3.0;//Lotes Aumento de Posição 3 (0 Não usar)
input double lote_aum4=0;//Lotes Aumento de Posição 4 (0 Não usar)
input double lote_aum5=0;//Lotes Aumento de Posição 5 (0 Não usar)
input double lote_aum6=0;//Lotes Aumento de Posição 6 (0 Não usar)



                         //Variaveis 

string original_symbol;
double ask,bid;
double lucro_total,pontos_total,lucro_entry;
bool timerOn,tradeOn,gapOn;
double ponto,ticksize,digits;
long curChartID;
double high[],low[],open[],close[];
double price_open;
string glob_entr_tot="ENT_TOT"+Symbol()+IntegerToString(Magic_Number);
string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string tp_vd_tick="tp_vd_tick"+Symbol()+IntegerToString(Magic_Number),tp_cp_tick="tp_cp_tick"+Symbol()+IntegerToString(Magic_Number);
string stp_vd_tick="stp_vd_tick"+Symbol()+IntegerToString(Magic_Number),stp_cp_tick="stp_cp_tick"+Symbol()+IntegerToString(Magic_Number);
string deals_total="deals_total"+Symbol()+IntegerToString(Magic_Number),deals_total_prev="deals_total_prev"+Symbol()+IntegerToString(Magic_Number);
string gv_today="gv_today"+Symbol()+IntegerToString(Magic_Number),gv_today_prev="gv_today_prev"+Symbol()+IntegerToString(Magic_Number);
string last_stop="last_stop"+Symbol()+IntegerToString(Magic_Number);
string pos_stop="pos_stop"+Symbol()+IntegerToString(Magic_Number);

double buyprice,sellprice,oldprice;
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
ulong time_conex=200;// Tempo em Milissegundos para testar conexão
bool updatedata;
bool tradebarra;
double take_price,stop_price;
double _lucro,_prejuizo;
double vol_pos,vol_stp,preco_stp;
uint total_deals,cont_deals;
ulong ticket_history_deal,deal_magic;
MqlDateTime TimeNow;
int media_mat_handle,ricardo_handle,bb_handle;
double MediaPlus[],MediaMinus[];
double BBWD_Buffer[];
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
   EventSetTimer(time_conex);
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
   media=new CiMA;
   media.Create(Symbol(),periodoRobo,period_media,0,modo_media,PRICE_CLOSE);
   media.AddToChart(curChartID,0);
   rsi=new CiRSI;
   rsi.Create(Symbol(),periodoRobo,period_rsi,PRICE_CLOSE);
   rsi.AddToChart(curChartID,ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL));
/*
   media_mat_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\Indic_Afastamento_Media_MATS.ex5",period_media,modo_media,PRICE_CLOSE);

   ChartIndicatorAdd(curChartID,ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),media_mat_handle);
*/

   ricardo_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\Afastamento_Final_Ricardo.ex5",period_media,modo_media,PRICE_CLOSE,period_delta,filtro_afastamento_positivo,filtro_afastamento_negativo,hora_inicio,hora_fim);

   ChartIndicatorAdd(curChartID,ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),ricardo_handle);

   bb_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\bbandwidth_interv.ex5",InpBandsPeriod,InpBandsShift,InpBandsDeviations,InpNivel1,InpNivel2);
   ChartIndicatorAdd(curChartID,ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),bb_handle);

   ArraySetAsSeries(BBWD_Buffer,true);
   ArraySetAsSeries(MediaPlus,true);
   ArraySetAsSeries(MediaMinus,true);

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

   if(InpNivel1>=InpNivel2)
     {
      string erro="Nivel 1 do BBANDWIDTH deve ser menor que o Nível 2";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(InpNivel1<=0 || InpNivel2<=0)
     {
      string erro="Nivel 1 e Nivel 2 do BBANDWIDTH devem ser >0";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if((_Stop<=pt_aum1 && lote_aum1>0) || (_Stop<=pt_aum2 && lote_aum2>0) || (_Stop<=pt_aum3 && lote_aum3>0) || (_Stop<=pt_aum4 && lote_aum4>0) || (_Stop<=pt_aum5 && lote_aum5>0) || (_Stop<=pt_aum6 && lote_aum6>0))

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
   if(!GlobalVariableCheck(stp_cp_tick))GlobalVariableSet(stp_cp_tick,0.0);
   if(!GlobalVariableCheck(stp_vd_tick))GlobalVariableSet(stp_vd_tick,0.0);



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
   delete(rsi);
   DeletaIndicadores();
   ExtDialog.Destroy(reason);

   if(reason!=5)
     {
      GlobalVariableSet(glob_entr_tot,0.0);
     }

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
   MytradeTransaction();
   CheckConnection();
   RefreshRates();
   media.Refresh();
   rsi.Refresh();
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
   TimeToStruct(TimeCurrent(),TimeNow);
   GlobalVariableSet(gv_today,(double)TimeNow.day_of_year);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   bool novodia;
   novodia=NewBar.CheckNewBar(original_symbol,PERIOD_D1);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(novodia || GlobalVariableGet(gv_today)!=GlobalVariableGet(gv_today_prev))
     {
      GlobalVariableSet(glob_entr_tot,0.0);
      GlobalVariableSet(deals_total_prev,0.0);
      GlobalVariableSet(last_stop,0.0);

      tradeOn=true;
     }

   GlobalVariableSet(gv_today_prev,GlobalVariableGet(gv_today));

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
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened())
     {
      DeleteALL();
      CloseByPosition();
     }
   if(!PosicaoAberta() && OrdersTotal()>0)DeleteALL();

   if(tradeOn && timerOn && gapOn)

     {// inicio Trade On
      ProtectPosition();
      Atual_vol_Stop_Take();

      if(operacao==Contra)
        {
         if(CheckCloseBuy() && Buy_opened())
           {
            DeleteALL();
            ClosePosType(POSITION_TYPE_BUY);
           }
         if(CheckCloseSell() && Sell_opened())
           {
            DeleteALL();
            ClosePosType(POSITION_TYPE_SELL);
           }
        }

      if(NewBar.CheckNewBar(Symbol(),periodoRobo))
        {
         tradebarra=true;
        }//Fim New Bar

      if(BuySignal() && !Buy_opened() && tradebarra && operar!=Venda && TradeStop())
        {
         if(Sell_opened())ClosePosType(POSITION_TYPE_SELL);
         if(mytrade.Buy(Lot,original_symbol,0,0,0,"BUY"+exp_name))
           {
            GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
            tradebarra=false;
           }
         else Print("Erro enviar ordem ",GetLastError());
        }

      if(SellSignal() && !Sell_opened() && tradebarra && operar!=Compra && TradeStop())
        {
         if(Buy_opened())ClosePosType(POSITION_TYPE_BUY);
         DeleteALL();
         if(mytrade.Sell(Lot,original_symbol,0,0,0,"SELL"+exp_name))
           {
            GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
            tradebarra=false;
           }
         else Print("Erro enviar ordem ",GetLastError());

        }

     }//End Trade On
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

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
bool CheckCloseBuy()
  {
   bool signal=false;
   if(operacao==Contra) signal=close[0]>=media.Main(0);
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckCloseSell()
  {
   bool signal=false;
   if(operacao==Contra) signal=close[0]<=media.Main(0);
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool BuySignal()
  {
   bool b_signal;
   double medias=0.5*(MathAbs(MediaMinus[0])+MediaPlus[0]);
/* if(operacao==Favor)b_signal=bid-media.Main(0)>=dist_media*ponto;
   else b_signal=media.Main(0)-ask>=dist_media*ponto;
   */
   if(operacao==Favor)b_signal=bid-media.Main(0)>=medias;
   else b_signal=media.Main(0)-ask>=medias;

   if(UsarRSI)
     {
      if(InvIFR) b_signal=b_signal && rsi.Main(0)<sob_vend;
      else b_signal=b_signal && rsi.Main(0)>=sob_vend && rsi.Main(0)<=sob_comp;
     }
   b_signal=b_signal && BBWD_Buffer[0]>=InpNivel1 && BBWD_Buffer[0]<=InpNivel2;
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
   bool s_signal;
   double medias=0.5*(MathAbs(MediaMinus[0])+MediaPlus[0]);
/* if(operacao==Favor) s_signal=media.Main(0)-ask>=dist_media*ponto;
   else s_signal=bid-media.Main(0)>=dist_media*ponto;
   */
   if(operacao==Favor) s_signal=media.Main(0)-ask>=medias;
   else s_signal=bid-media.Main(0)>=medias;

   if(UsarRSI)
     {
      if(InvIFR) s_signal=s_signal && rsi.Main(0)>sob_comp;
      else s_signal=s_signal && rsi.Main(0)>=sob_vend && rsi.Main(0)<=sob_comp;
     }
   s_signal=s_signal && BBWD_Buffer[0]>=InpNivel1 && BBWD_Buffer[0]<=InpNivel2;
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
   b_get=CopyBuffer(ricardo_handle,0,0,5,MediaPlus)<=0 || 
         CopyBuffer(ricardo_handle,1,0,5,MediaMinus)<=0 || 
         CopyBuffer(bb_handle,0,0,5,BBWD_Buffer)<=0 ||
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
         if(deals_ticket>0)
           {
            mydeal.Ticket(deals_ticket);
            order_ticket=mydeal.Order();

            if((order_ticket==(ulong)GlobalVariableGet(cp_tick) || order_ticket==(ulong)GlobalVariableGet(vd_tick)))
              {
               GlobalVariableSet(glob_entr_tot,GlobalVariableGet(glob_entr_tot)+1);
              }

            if(order_ticket==(ulong)GlobalVariableGet(cp_tick))
              {
               myposition.SelectByTicket(order_ticket);
               if(mytrade.SellLimit(Lot,NormalizeDouble(myposition.PriceOpen()+_TakeProfit*ponto,digits),Symbol(),0,0,0,0,"TAKE PROFIT"+exp_name))
                 {
                  GlobalVariableSet(tp_vd_tick,(double)mytrade.ResultOrder());
                 }
               else
                 {
                  Print("Erro enviar ordem ",GetLastError());
                  mytrade.SellLimit(Lot,mysymbol.Ask(),Symbol(),0,0,0,0,"TAKE PROFIT"+exp_name);
                 }
               if(mytrade.SellStop(Lot,NormalizeDouble(myposition.PriceOpen()-_Stop*ponto,digits),Symbol(),0,0,0,0,"STOP"+exp_name))
                 {
                  GlobalVariableSet(stp_vd_tick,(double)mytrade.ResultOrder());
                 }
               else
                 {
                  Print("Erro enviar ordem ",GetLastError());
                  mytrade.Sell(Lot);
                 }
               Aumento_Buy();
              }
            //--------------------------------------------------

            if(order_ticket==(ulong)GlobalVariableGet(vd_tick))
              {
               myposition.SelectByTicket(order_ticket);
               if(mytrade.BuyLimit(Lot,NormalizeDouble(myposition.PriceOpen()-_TakeProfit*ponto,digits),Symbol(),0,0,0,0,"TAKE PROFIT"+exp_name))
                 {
                  GlobalVariableSet(tp_cp_tick,(double)mytrade.ResultOrder());
                 }
               else
                 {
                  Print("Erro enviar ordem ",GetLastError());
                  mytrade.BuyLimit(Lot,mysymbol.Bid(),Symbol(),0,0,0,0,"TAKE PROFIT"+exp_name);
                 }

               if(mytrade.BuyStop(Lot,NormalizeDouble(myposition.PriceOpen()+_Stop*ponto,digits),Symbol(),0,0,0,0,"STOP"+exp_name))
                 {
                  GlobalVariableSet(stp_cp_tick,(double)mytrade.ResultOrder());
                 }
               else
                 {
                  Print("Erro enviar ordem ",GetLastError());
                  mytrade.Buy(Lot);
                 }
               Aumento_Sell();
              }

            if((mydeal.DealType()==DEAL_TYPE_BUY || mydeal.DealType()==DEAL_TYPE_SELL) && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
              {
               Print("Saída da Operação. Aguardar Toque na Média");
               GlobalVariableSet(last_stop,1.0);
               GlobalVariableSet(pos_stop,mydeal.Price()-media.Main(0));
              }
            if(mydeal.Comment()=="TAKE PROFIT"+exp_name || mydeal.Comment()=="STOP"+exp_name)
              {
               DeleteALL();
               if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened())CloseByPosition();
               Print("Saída da Operação. Aguardar Toque na Média");
               GlobalVariableSet(last_stop,1.0);
               GlobalVariableSet(pos_stop,mydeal.Price()-media.Main(0));
              }

           }// if dealsticket>0
        }//Fim deals>prev
     }//Fim HistorySelect
   GlobalVariableSet(deals_total_prev,GlobalVariableGet(deals_total));

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

void ProtectPosition()
  {
   ulong tick_pos;
   double cont_size,den;
   cont_size=mysymbol.ContractSize();
   if(Buy_opened() && !Sell_opened())
     {
      tick_pos=TickecBuyPos();
      myposition.SelectByTicket(tick_pos);
      den=((mysymbol.TickValue()*myposition.Volume())/mysymbol.TickSize());

      if(myposition.Profit()<-den*(_Stop+10*ticksize)/cont_size || myposition.Profit()>den*(_TakeProfit+10*ticksize)/cont_size)
        {
         DeleteALL();
         ClosePosType(POSITION_TYPE_BUY);
        }

     }
   if(Sell_opened() && !Buy_opened())
     {
      tick_pos=TickecSellPos();
      myposition.SelectByTicket(tick_pos);
      den=((mysymbol.TickValue()*myposition.Volume())/mysymbol.TickSize());

      if(myposition.Profit()<-den*(_Stop+10*ticksize)/cont_size || myposition.Profit()>den*(_TakeProfit+10*ticksize)/cont_size)
        {
         DeleteALL();
         ClosePosType(POSITION_TYPE_SELL);
        }

     }
  }
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
               mytrade.SellStop(vol_pos,preco_stp,Symbol(),0,0,0,0,"STOP"+exp_name);
               GlobalVariableSet(stp_vd_tick,(double)mytrade.ResultOrder());
              }
           }

         if(myposition.SelectByTicket((int)GlobalVariableGet(cp_tick)) && myorder.Select((int)GlobalVariableGet(tp_vd_tick)))
           {
            vol_pos=VolPosType(POSITION_TYPE_BUY);
            vol_stp=myorder.VolumeInitial();
            preco_stp=myorder.PriceOpen();

            if(vol_pos!=vol_stp)
              {
               mytrade.OrderDelete((int)GlobalVariableGet(tp_vd_tick));
               mytrade.SellLimit(vol_pos,preco_stp,original_symbol,0,0,0,0,"TAKE PROFIT"+exp_name);
               GlobalVariableSet(tp_vd_tick,(double)mytrade.ResultOrder());
              }
           }

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
               mytrade.BuyStop(vol_pos,preco_stp,Symbol(),0,0,0,0,"STOP"+exp_name);
               GlobalVariableSet(stp_cp_tick,(double)mytrade.ResultOrder());

              }
           }

         if(myposition.SelectByTicket((int)GlobalVariableGet(vd_tick)) && myorder.Select((int)GlobalVariableGet(tp_cp_tick)))
           {
            vol_pos=VolPosType(POSITION_TYPE_SELL);
            vol_stp=myorder.VolumeInitial();
            preco_stp=myorder.PriceOpen();

            if(vol_pos!=vol_stp)
              {
               mytrade.OrderDelete((int)GlobalVariableGet(tp_cp_tick));
               mytrade.BuyLimit(vol_pos,preco_stp,original_symbol,0,0,0,0,"TAKE PROFIT"+exp_name);
               GlobalVariableSet(tp_cp_tick,(double)mytrade.ResultOrder());

              }
           }
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
bool TradeStop()
  {
   if(GlobalVariableGet(last_stop)==1.0)
     {
      if(GlobalVariableGet(pos_stop)*(close[0]-media.Main(0))<=0)
        {
         GlobalVariableSet(last_stop,0.0);
         return true;
        }
      else return false;
     }
   else return true;
  }
//+------------------------------------------------------------------+
