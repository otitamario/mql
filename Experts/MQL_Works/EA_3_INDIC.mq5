//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
enum Applied_price_ //Type od constant
  {
   PRICE_CLOSE_ = 1,     //Close
   PRICE_OPEN_,          //Open
   PRICE_HIGH_,          //High
   PRICE_LOW_,           //Low
   PRICE_MEDIAN_,        //Median Price (HL/2)
   PRICE_TYPICAL_,       //Typical Price (HLC/3)
   PRICE_WEIGHTED_,      //Weighted Close (HLCC/4)
   PRICE_SIMPLE_,//Simple Price (OC/2)
   PRICE_QUARTER_,       //Quarted Price (HLOC/4) 
   PRICE_TRENDFOLLOW0_,  //TrendFollow_1 Price 
   PRICE_TRENDFOLLOW1_   //TrendFollow_2 Price 
  };

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>
#include <Controls\Dialog.mqh>
#include <SmoothAlgorithms.mqh> 


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
input double Lot=1;//Lote Entrada
input double _Stop=100; //Stop Loss em Pontos
input double _TakeProfit=100; //Take Profit em Pontos
sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes no Dia
sinput string shorario="############------FILTRO DE HORARIO------#################";
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:30";//Horario Inicial
input string end_hour="16:50";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario
sinput string STrailing="############---------------Trailing Stop----------########";
input bool   Use_TraillingStop=true; //Usar Trailing 
input int TraillingStart=100;//Lucro Minimo Iniciar trailing stop
input int TraillingDistance=90;// Distanccia em Pontos do Stop Loss
input int TraillingStep=10;// Passo para atualizar Stop Loss

sinput string SEstrategia="############-------------Estratégia----------########";
input bool UseSchaff=true; //Usar SchaffTrend
input int schaff_sobrecompr=80;//Nível Schaff SobreCompra
input int schaff_sobrevend=20;//Nível Schaff SobreVenda

input bool UseAvSpeed=true; //Usar Average Speed
input double nivel_speed=0.2;//Nivel Average Speed
input bool UseSuper=true; //Usar Super Woodies CCI

sinput string SEst_Med="############-------------Indicadores----------########";
//Schaff
input Smooth_Method MA_SMethod=MODE_EMA_; //Schaff Histogram smoothing method
input int Fast_XMA = 23; //Schaff Fast moving average period
input int Slow_XMA = 50; //Schaff Slow moving average period
input int SmPhase= 100;  //SchaffMoving averages smoothing parameter
input Applied_price_ AppliedPrice=PRICE_CLOSE_;//Price constant
input int Cycle=10; //Stochastic oscillator period


                         //Average Speed
input int      nn=3;// n Average Speed
input ENUM_APPLIED_PRICE  priceAvSpeed=PRICE_CLOSE;//Average Speed Applied Price
                                                   //Super Woodies
input uint CCI_Period=50;//CCI Period Super Woodies
input uint TCCI_Period=10;//TCCI Period Super Woodies
input ENUM_APPLIED_PRICE  applied_price=PRICE_TYPICAL;  // price type or handle Super Woodies
input int ShiftSuper=0;                                      // horizontal shift of the indicator in bars Super Woodies

                                                             //Variaveis 

string original_symbol;
double ask,bid;
double lucro_total,pontos_total,lucro_entry;
bool timerOn,tradeOn;
double ponto,ticksize,digits;
long curChartID;
int schaf_handle,avspeed_handle,super_handle;
double Schaf_Buffer[],AvSpeed_Buffer[],Super_CCI[],Turbo_CCI[];
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
datetime hora_inicial,hora_final;
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

   schaf_handle=iCustom(Symbol(),periodoRobo,"schafftrendcycle",MA_SMethod,Fast_XMA,Slow_XMA,SmPhase,AppliedPrice,Cycle);
   avspeed_handle=iCustom(Symbol(),periodoRobo,"average_speed",nn,priceAvSpeed);
   super_handle=iCustom(Symbol(),periodoRobo,"superwoodiescci",CCI_Period,TCCI_Period,applied_price,ShiftSuper);

  ChartIndicatorAdd(ChartID(),ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),schaf_handle);
  ChartIndicatorAdd(ChartID(),ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),avspeed_handle);
  ChartIndicatorAdd(ChartID(),ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL),super_handle);
  

  
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ArraySetAsSeries(Schaf_Buffer,true);
   ArraySetAsSeries(AvSpeed_Buffer,true);
   ArraySetAsSeries(Super_CCI,true);
   ArraySetAsSeries(Turbo_CCI,true);

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

   if(!UseSchaff && !UseAvSpeed && !UseSuper)
     {
      string erro="Escolha pelo menos um Indicador na Estratégia";
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
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(schaf_handle);
   IndicatorRelease(avspeed_handle);
   IndicatorRelease(super_handle);

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

   if(tradeOn && timerOn)

     {// inicio Trade On

      if(NewBar.CheckNewBar(Symbol(),periodoRobo))
        {

         if(BuySignal() && !Buy_opened())
           {
            if(Sell_opened())ClosePosType(POSITION_TYPE_SELL);
            if(mytrade.Buy(Lot,original_symbol,0,NormalizeDouble(bid-_Stop*ponto,digits),NormalizeDouble(ask+_TakeProfit*ponto,digits),"BUY"+exp_name))
              {
               GlobalVariableSet(cp_tick,(double)mytrade.ResultOrder());
              }
            else Print("Erro enviar ordem ",GetLastError());
           }

         if(SellSignal() && !Sell_opened())
           {
            if(Buy_opened())ClosePosType(POSITION_TYPE_BUY);
            DeleteALL();
            if(mytrade.Sell(Lot,original_symbol,0,NormalizeDouble(ask+_Stop*ponto,digits),NormalizeDouble(bid-_TakeProfit*ponto,digits),"SELL"+exp_name))
              {
               GlobalVariableSet(vd_tick,(double)mytrade.ResultOrder());
              }
            else Print("Erro enviar ordem ",GetLastError());

           }

        }//End NewBar

      MytradeTransaction();

      if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);

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
bool BuySignal()
  {
   bool b_signal,av_sig,cci_sig,schaf_sig;
   av_sig=true;
   if(UseAvSpeed)av_sig=AvSpeed_Buffer[1]>nivel_speed;
   cci_sig=true;
   if(UseSuper)cci_sig=Super_CCI[1]>0 && Turbo_CCI[1]>0;
   schaf_sig=true;
   if(UseSchaff)schaf_sig=Schaf_Buffer[2]<schaff_sobrevend && Schaf_Buffer[1]>schaff_sobrevend;
   b_signal=av_sig && cci_sig && schaf_sig;
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
   bool s_signal,av_sig,cci_sig,schaf_sig;
   av_sig=true;
   if(UseAvSpeed)av_sig=AvSpeed_Buffer[1]>nivel_speed;
   cci_sig=true;
   if(UseSuper)cci_sig=Super_CCI[1]<0 && Turbo_CCI[1]<0;
   schaf_sig=true;
   if(UseSchaff)schaf_sig=Schaf_Buffer[2]>schaff_sobrecompr && Schaf_Buffer[1]<schaff_sobrecompr;
   s_signal=av_sig && cci_sig && schaf_sig;

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
   b_get=CopyBuffer(schaf_handle,0,0,5,Schaf_Buffer)<=0 || 
         CopyBuffer(avspeed_handle,0,0,5,AvSpeed_Buffer)<=0 || 
         CopyBuffer(super_handle,0,0,5,Super_CCI)<=0 ||
         CopyBuffer(super_handle,1,0,5,Turbo_CCI)<=0 ||
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
