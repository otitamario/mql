//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

#resource "\\Indicators\\pvt.ex5"

enum TipoHorario //Tipo de Filtro de Horario
  {
   Diario,
   Semanal
  };

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

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"HORÁRIO PERMITIDO: "+timerOn,xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+4*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],DayofWeek()+" "+TimeToString(TimeCurrent(),TIME_SECONDS),xx1,yy1,xx2,yy2))
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
   m_label[3].Text("HORÁRIO PERMITIDO: "+timerOn);
   m_label[4].Text(DayofWeek()+" "+TimeToString(TimeCurrent(),TIME_SECONDS));

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
CiMA *mpvt;
CiMA *msaida;
CControlsDialog ExtDialog;
// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=20082018;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input double Lot=1;//Lote Entrada
input double _Stop=200; //Stop Loss em Pontos(Stop Gain)
input double _TakeProfit=200; //Take Profit em Pontos(Stop Gain)
sinput string SEstrategia="############---------------Estratégia----------########";
input int entr_dia=10;//Máximo de Entradas no Dia
input bool every_tick=false;//Fazer entradas sem Fechamento da Barra
input bool fechar_media=true;//Fechar Posições na Média
sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes no Dia
sinput string shorario="############------FILTRO DE HORARIO------#################";
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="00:00";//Horario Inicial
input string end_hour_entr="21:00";//Horario Final Entradas
input TipoHorario tipo_hor=Diario;//Tipo Fechamento
input string end_hour="17:30";//Horario Fechamento Diario
input string end_hour_friday="21:30";//Horario Fechamento Semanal(Sexta-Feira)
input bool trade0=true;// Operar Domingo
input bool trade1=true;// Operar Segunda
input bool trade2=true;// Operar Terça
input bool trade3=true;// Operar Quarta
input bool trade4=true;// Operar Quinta
input bool trade5=true;// Operar Sexta
input bool trade6=true;// Operar Sábado



input bool daytrade=true;//Fechar Posicao Fim do Dia
sinput string sIndic="############------Indicadores------#################";
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; // Volumes TYPE PVT
input int per_med_pvt=50;//Periodo Media PVT
input ENUM_MA_METHOD mode_pvt=MODE_EMA;//Modo Media PVT
input int Shift_PVT=0;//Deslocamento Media PVT
input int per_med_saida=20;//Periodo Media Saída
input ENUM_MA_METHOD mode_saida=MODE_EMA;//Modo Media Saída
input int Shift_saida=0;//Deslocamento Media Saída

                        //Variaveis 

string original_symbol;
double ask,bid;
double lucro_total,pontos_total,lucro_entry;
bool timerOn,tradeOn,timerEnt;
double ponto,ticksize,digits;
long curChartID;
int pvt_handle;
double PVT[];
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
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   

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

   curChartID=ChartID();

   pvt_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\pvt.ex5",InpVolumeType);
   ulong nchartpvt=ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL);
   ChartIndicatorAdd(ChartID(),nchartpvt,pvt_handle);

   mpvt=new CiMA;
   mpvt.Create(Symbol(),periodoRobo,per_med_pvt,Shift_PVT,mode_pvt,pvt_handle);
   mpvt.AddToChart(ChartID(),nchartpvt);

   msaida=new CiMA;
   msaida.Create(Symbol(),periodoRobo,per_med_saida,Shift_saida,mode_saida,PRICE_CLOSE);
   msaida.AddToChart(ChartID(),0);


   ArraySetAsSeries(PVT,true);

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

// parametros incorretos desnecessarios na otimizacao
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);

   if(tipo_hor==Diario)hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   if(tipo_hor==Semanal && IsFriday()) hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_friday);

   if(hora_inicial>=hora_final && tipo_hor==Diario)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(hora_inicial>=hora_final && IsFriday() && tipo_hor==Semanal)
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

//Global Variables Check

   if(!GlobalVariableCheck(glob_entr_tot))GlobalVariableSet(glob_entr_tot,0.0);
   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0.0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0.0);

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,220,170))

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
   IndicatorRelease(pvt_handle);
   delete(mpvt);
   delete(msaida);
   DeletaIndicadores();
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
   mpvt.Refresh();
   msaida.Refresh();
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
      GlobalVariableSet(glob_entr_tot,0.0);
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

     }

   timerOn=true;
   timerEnt=true;
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   if(tipo_hor==Diario)hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   if(tipo_hor==Semanal && IsFriday()) hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_friday);
   hora_final_entradas=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_entr);
   if(UseTimer)
     {
      if(tipo_hor==Diario)timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
      if(tipo_hor==Semanal)
        {
         if(IsFriday())timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
         else timerOn=true;
        }
      timerEnt=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final_entradas && TimeDayFilter();
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

   if(tradeOn && timerOn)

     {// inicio Trade On
      if(timerEnt)
        {
         if(!every_tick)
           {
            if(NewBar.CheckNewBar(Symbol(),periodoRobo))
              {
               if(BuySignal() && !PosicaoAberta() && Num_Entr_Permitida())
                 {
                  if(mytrade.Buy(Lot,original_symbol,0,NormalizeDouble(bid-_Stop*ponto,digits),NormalizeDouble(ask+_TakeProfit*ponto,digits),"BUY"+exp_name))
                    {
                     GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
                    }
                  else Print("Error send order",GetLastError());
                 }

               if(SellSignal() && !PosicaoAberta() && Num_Entr_Permitida())
                 {
                  if(mytrade.Sell(Lot,original_symbol,0,NormalizeDouble(ask+_Stop*ponto,digits),NormalizeDouble(bid-_TakeProfit*ponto,digits),"SELL"+exp_name))
                    {
                     GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
                    }
                  else Print("Error send order ",GetLastError());

                 }

              }//End NewBar
           }

         else
           {
            if(BuySignal() && !PosicaoAberta() && Num_Entr_Permitida())
              {
               if(mytrade.Buy(Lot,original_symbol,0,NormalizeDouble(bid-_Stop*ponto,digits),NormalizeDouble(ask+_TakeProfit*ponto,digits),"BUY"+exp_name))
                 {
                  GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Error send order",GetLastError());
              }

            if(SellSignal() && !PosicaoAberta() && Num_Entr_Permitida())
              {
               if(mytrade.Sell(Lot,original_symbol,0,NormalizeDouble(ask+_Stop*ponto,digits),NormalizeDouble(bid-_TakeProfit*ponto,digits),"SELL"+exp_name))
                 {
                  GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Error send order ",GetLastError());

              }

           }
        }//Fim Timer Ent
      if(fechar_media) SaidaMedia();
      MytradeTransaction();

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
   bool b_signal;
   int idx=1;
   if(every_tick)idx=0;
   b_signal=mpvt.Main(idx+1)>PVT[idx+1] && mpvt.Main(idx)<PVT[idx];
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
   int idx=1;
   if(every_tick)idx=0;
   s_signal=mpvt.Main(idx+1)<PVT[idx+1] && mpvt.Main(idx)>PVT[idx];
   return s_signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SaidaMedia()
  {
   if(Buy_opened() && ask<=msaida.Main(0))
     {
      ClosePosType(POSITION_TYPE_BUY);
      Print("Fechou Posição na Média");
     }
   if(Sell_opened() && bid>=msaida.Main(0))
     {
      ClosePosType(POSITION_TYPE_SELL);
      Print("Fechou Posição na Média");
     }
  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(pvt_handle,0,0,5,PVT)<=0 || 
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
bool Num_Entr_Permitida()
  {
   bool signal;
   if(entr_dia<=0)signal=true;
   else signal=GlobalVariableGet(glob_entr_tot)<entr_dia;
   return signal;

  }
//+------------------------------------------------------------------+
bool IsFriday()
  {
   MqlDateTime TimeNow;
   TimeToStruct(TimeCurrent(),TimeNow);
   if( UseTimer && TimeNow.day_of_week == 5) return true;
   return false;

  }
//+------------------------------------------------------------------+
bool TimeDayFilter()
  {
   bool filter;
   MqlDateTime TimeNow;
   TimeToStruct(TimeCurrent(),TimeNow);
   switch(TimeNow.day_of_week)
     {
      case 0:
         filter=trade0;
         break;
      case 1:
         filter=trade1;
         break;
      case 2:
         filter=trade2;
         break;
      case 3:
         filter=trade3;
         break;
      case 4:
         filter=trade4;
         break;
      case 5:
         filter=trade5;
         break;
      case 6:
         filter=trade6;
         break;

     }
   return filter;
  }
//+------------------------------------------------------------------+

string DayofWeek()
  {
   string filter;
   MqlDateTime TimeNow;
   TimeToStruct(TimeCurrent(),TimeNow);
   switch(TimeNow.day_of_week)
     {
      case 0:
         filter="Domingo";
         break;
      case 1:
         filter="Segunda-feira";
         break;
      case 2:
         filter="Terça-feira";
         break;
      case 3:
         filter="Quarta-feira";
         break;
      case 4:
         filter="Quinta-feira";
         break;
      case 5:
         filter="Sexta-feira";
         break;
      case 6:
         filter="Sábado";
         break;

     }
   return filter;
  }
//+------------------------------------------------------------------+
