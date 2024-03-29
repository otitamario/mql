//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Operacao
  {
   Diferenca=1,  //Diferenca
   Razao=2       //Razao
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TipoLote
  {
   Valor,//Lote por valor
   Fixo//Lote fixo
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

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"LUCRO POSIÇÕES: "+DoubleToString(lucro_total,2),xx1,yy1,xx2,yy2))
      return(false);



//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnTick(void)
  {
   m_label[0].Text("LUCRO POSIÇÕES: "+DoubleToString(lucro_total,2));
   string str_pos;
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
//CSymbolInfo mysymbol;
COrderInfo myorder;
CControlsDialog ExtDialog;
input ulong Magic_Number=22072018;//Número Mágico
sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";
input bool UsarLucro=true;//Usar Lucro para Fechamento True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes

sinput string shorario="############------FILTRO DE HORARIO------#################";
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="10:05";//Horario Inicial
input string end_hour="16:30";//Horario Final
input string end_entry="16:00";//Horário Final para Entradas
input bool Daytrade=false;//Fechar Posicao Fim do Dia

sinput string sindicators="############------INDICADORES------#################";
input datetime BeginTime      =  D'2016.01.01'; //Data inicial
input string   Symbol1        =  "PETR4";       //Papel 1
input string   Symbol2        =  "VALE3";       //Papel 2
input double   Multi1         =  1;             //Multiplicador papel 1
input double   Multi2         =  1;             //Multiplicador papel 2
input bool     Invert1        =  false;         //Inverter papel 1
input bool     Invert2        =  false;         //Inverter papel 2
input Operacao Action         =  Razao;         //Entrada por Razao/Diferença
input uint     Window         =  100;           //Numero de barras considerado
input bool     ShowBands      =  true;          //Mostrar Bandas de Bollinger

input TipoLote calcLotes=Fixo;//Cálculo de Lotes por Valor ou Fixo
input double val_lotes=50000;//Valor Financeiro Cálculo Lotes;se por Valor
input double Lot1=1000;//Lote Entrada Papel 1;se Lote Fixo
input double Lot2=1000;//Lote Entrada Papel 2;se Lote Fixo
input ENUM_TIMEFRAMES TIMEF_IN=PERIOD_D1;//Time Frame ENTRADA

input int      BandsPeriod    =  20;            //Periodo para as BB Entrada
input double   BandsDev       =  2.0;           //Desvio Padrao para as BB Entrada
input bool abreclosebar=true;//Abre posição somente no fechamento da barra

input ENUM_TIMEFRAMES TIMEF_OUT=PERIOD_H1;//Time Frame Saída
input int      BandsPeriod_Saida    =  30;            //Periodo para as BB Saída
input double   BandsDev_Saida       =  0.5;           //Desvio Padrao para as BB Saída
input bool fechaclosebar=true;//Fecha posição somente no fechamento da barra

                              //Variaveis 
double ask_sb1,bid_sb1,ask_sb2,bid_sb2;
double lucro_total;
bool timerOn,timerEnt;
double ponto1,ticksize1,digits1;
double ponto2,ticksize2,digits2;

int lsratio_handle,lsratio_saida_handle;
double LS_Ent[],UB_Ent[],ML_Ent[],LB_Ent[];
double LS_Said[],UB_Said[],ML_Said[],LB_Said[];

long curChartID,newChartID,secChartID;
double close_sb1[],close_sb2[];
uint nsubwindows;
ulong ENTRADAS_TOTAL;
ulong trade_ticket,compra1_ticket,venda1_ticket;
string cp_tick="cp_tick"+Symbol()+IntegerToString(Magic_Number),vd_tick="vd_tick"+Symbol()+IntegerToString(Magic_Number);
string glob_bar_entry="bar_entry"+Symbol1+Symbol2+IntegerToString(Magic_Number);
string glob_bar_exit="bar_exit"+Symbol1+Symbol2+IntegerToString(Magic_Number);

string informacoes=" ";
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
datetime time_novodia[4];
datetime hora_inicial,hora_final,hora_ent;
double lote1,lote2;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

// original_symbol=Symbol();
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
   mytrade.SetTypeFilling(ORDER_FILLING_RETURN);
   ponto1=SymbolInfoDouble(Symbol1,SYMBOL_POINT);
   ticksize1=SymbolInfoDouble(Symbol1,SYMBOL_TRADE_TICK_SIZE);
   digits1=(int)SymbolInfoInteger(Symbol1,SYMBOL_DIGITS);
   ponto2=SymbolInfoDouble(Symbol2,SYMBOL_POINT);
   ticksize2=SymbolInfoDouble(Symbol2,SYMBOL_TRADE_TICK_SIZE);
   digits2=(int)SymbolInfoInteger(Symbol2,SYMBOL_DIGITS);
   informacoes=" ";
   curChartID=ChartID();
   newChartID=ChartOpen(Symbol2,TIMEF_IN);
   lsratio_handle=iCustom(Symbol2,TIMEF_IN,"LSRatio",BeginTime,Symbol1,Symbol2,Action,Invert1,Invert2,Multi1,Multi2,Window,ShowBands,BandsPeriod,BandsDev,false,0.1,0.5);
   nsubwindows=ChartGetInteger(newChartID,CHART_WINDOWS_TOTAL);
   ChartIndicatorAdd(newChartID,nsubwindows,lsratio_handle);

   lsratio_saida_handle=iCustom(Symbol2,TIMEF_OUT,"LSRatio",BeginTime,Symbol1,Symbol2,Action,Invert1,Invert2,Multi1,Multi2,Window,ShowBands,BandsPeriod_Saida,BandsDev_Saida,false,0.1,0.5);
   secChartID=ChartOpen(Symbol2,TIMEF_OUT);
   nsubwindows=ChartGetInteger(secChartID,CHART_WINDOWS_TOTAL);
   ChartIndicatorAdd(secChartID,nsubwindows,lsratio_saida_handle);

   ArraySetAsSeries(LS_Ent,true);
   ArraySetAsSeries(UB_Ent,true);
   ArraySetAsSeries(ML_Ent,true);
   ArraySetAsSeries(LB_Ent,true);
   ArraySetAsSeries(LS_Said,true);
   ArraySetAsSeries(UB_Said,true);
   ArraySetAsSeries(ML_Said,true);
   ArraySetAsSeries(LB_Said,true);

   ArraySetAsSeries(close_sb1,true);
   ArraySetAsSeries(close_sb2,true);

   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   hora_ent=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_entry);
   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(hora_ent>hora_final)
     {
      string erro="Hora Fina de Entradas deve ser Menor ou igual a Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

//Global Variables Check

   if(!GlobalVariableCheck(cp_tick))GlobalVariableSet(cp_tick,0.0);
   if(!GlobalVariableCheck(vd_tick))GlobalVariableSet(vd_tick,0.0);
   if(!GlobalVariableCheck(glob_bar_entry))GlobalVariableSet(glob_bar_entry,0.0);
   if(!GlobalVariableCheck(glob_bar_exit))GlobalVariableSet(glob_bar_exit,0.0);

   if(abreclosebar)GlobalVariableSet(glob_bar_entry,1.0);
   else GlobalVariableSet(glob_bar_entry,0.0);

   if(fechaclosebar)GlobalVariableSet(glob_bar_exit,1.0);
   else GlobalVariableSet(glob_bar_exit,0.0);

   
   if(!Buy_opened() && !Sell_opened())
        {
         GlobalVariableSet(cp_tick,0);
         GlobalVariableSet(vd_tick,0);
        }

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,200,150))

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
   IndicatorRelease(lsratio_handle);
   IndicatorRelease(lsratio_saida_handle);
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
   novodia=NewBar.CheckNewBar(Symbol(),PERIOD_D1);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(novodia)
     {
      Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");
      informacoes=" ";

      if(!Buy_opened() && !Sell_opened())
        {
         GlobalVariableSet(cp_tick,0);
         GlobalVariableSet(vd_tick,0);
        }

     }

//lucro_total=LucroOrdens()+LucroPositions();
   lucro_total=LucroPositions();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      informacoes="Posições fechadas por lucro ou prejuizo";
      Print(informacoes);
      GlobalVariableSet(cp_tick,0);
      GlobalVariableSet(vd_tick,0);

     }

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   hora_ent=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_entry);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final;
      timerEnt=TimeCurrent()<=hora_ent;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      timerOn=true;
      timerEnt=true;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer && !timerOn && Daytrade)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
     }

//Atualizacao das Cotacoes----ticks
   MqlTick last_tick_sb1;
   MqlTick last_tick_sb2;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(SymbolInfoTick(Symbol1,last_tick_sb1))
     {
      bid_sb1= last_tick_sb1.bid;
      ask_sb1=last_tick_sb1.ask;
     }
   else
     {
      Print("Falhou obter o tick Simbolo 1");
      return;
     }

   if(SymbolInfoTick(Symbol2,last_tick_sb2))
     {
      bid_sb2= last_tick_sb2.bid;
      ask_sb2=last_tick_sb2.ask;
     }
   else
     {
      Print("Falhou obter o tick Simbolo 2");
      return;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(bid_sb1==0 || ask_sb1==0)
     {
      Print("BID ou ASK=0 Simbolo 1: ",bid_sb1," ",ask_sb1);
      return;
     }
   if(bid_sb2==0 || ask_sb2==0)
     {
      Print("BID ou ASK=0 Simbolo 2 : ",bid_sb2," ",ask_sb2);
      return;
     }

   compra1_ticket=(int) GlobalVariableGet(cp_tick);
   venda1_ticket=(int) GlobalVariableGet(vd_tick);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(timerOn)

     {// inicio Trade On

      if(PosicaoAberta_Symbol1() && PosicaoAberta_Symbol2())
        {
         if(UpperSignalExit())
           {
            if(myposition.SelectByTicket(compra1_ticket) && myposition.Symbol()==Symbol1)
              {
               mytrade.PositionClose(compra1_ticket);
               mytrade.PositionClose(venda1_ticket);
               GlobalVariableSet(cp_tick,0);
               GlobalVariableSet(vd_tick,0);
              }
           }
         if(LowerSignalExit())
           {
            if(myposition.SelectByTicket(compra1_ticket) && myposition.Symbol()==Symbol2)
              {
               mytrade.PositionClose(compra1_ticket);
               mytrade.PositionClose(venda1_ticket);
               GlobalVariableSet(cp_tick,0);
               GlobalVariableSet(vd_tick,0);

              }
           }
        }

      else
        {
         if(UpperSignalEntry() && !Buy_opened() && GlobalVariableGet(cp_tick)==0.0 && timerEnt)
           {
            if(calcLotes==Valor)
              {
               lote2=CalculoLote(val_lotes,ask_sb2,SymbolInfoDouble(Symbol2,SYMBOL_VOLUME_MIN));
               lote1=CalculoLote(val_lotes,bid_sb1,SymbolInfoDouble(Symbol1,SYMBOL_VOLUME_MIN));
              }
            else
              {
               lote1=Lot1;
               lote2=Lot2;
              }

            mytrade.Buy(lote2,Symbol2,0,0,0,"BUY_UPPER"+exp_name);
            compra1_ticket=mytrade.ResultOrder();
            GlobalVariableSet(cp_tick,(double)compra1_ticket);
            mytrade.Sell(lote1,Symbol1,0,0,0,"SELL_UPPER"+exp_name);
            venda1_ticket=mytrade.ResultOrder();
            GlobalVariableSet(vd_tick,(double)venda1_ticket);
           }

         if(LowerSignalEntry() && !Buy_opened() && GlobalVariableGet(cp_tick)==0.0 && timerEnt)
           {

            if(calcLotes==Valor)
              {
               lote2=CalculoLote(val_lotes,bid_sb2,SymbolInfoDouble(Symbol2,SYMBOL_VOLUME_MIN));
               lote1=CalculoLote(val_lotes,ask_sb1,SymbolInfoDouble(Symbol1,SYMBOL_VOLUME_MIN));
              }
            else
              {
               lote1=Lot1;
               lote2=Lot2;
              }

            mytrade.Buy(lote1,Symbol1,0,0,0,"BUY_LOWER"+exp_name);
            compra1_ticket=mytrade.ResultOrder();
            GlobalVariableSet(cp_tick,(double)compra1_ticket);
            mytrade.Sell(lote2,Symbol2,0,0,0,"SELL_LOWER"+exp_name);
            venda1_ticket=mytrade.ResultOrder();
            GlobalVariableSet(vd_tick,(double)venda1_ticket);

           }
        }

     }//End Timer On

  }
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
bool UpperSignalEntry()
  {
   bool signal;
   int barra=(int)GlobalVariableGet(glob_bar_entry);
   signal=LS_Ent[barra+1]>UB_Ent[barra+1] && LS_Ent[barra]<UB_Ent[barra];
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LowerSignalEntry()
  {
   bool signal;
   int barra=(int)GlobalVariableGet(glob_bar_entry);
   signal=LS_Ent[barra+1]<LB_Ent[barra+1] && LS_Ent[barra]>LB_Ent[barra];
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool UpperSignalExit()
  {
   bool signal;
   int barra=(int)GlobalVariableGet(glob_bar_exit);
   signal=LS_Said[barra+1]>UB_Said[barra+1] && LS_Said[barra]<UB_Said[barra];
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LowerSignalExit()
  {
   bool signal;
   int barra=(int)GlobalVariableGet(glob_bar_exit);
   signal=LS_Said[barra+1]<LB_Said[barra+1] && LS_Said[barra]>LB_Said[barra];
   return signal;
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
   b_get=CopyBuffer(lsratio_handle,0,0,5,LS_Ent)<=0 || 
         CopyBuffer(lsratio_handle,1,0,5,UB_Ent)<=0||
         CopyBuffer(lsratio_handle,2,0,5,ML_Ent)<=0||
         CopyBuffer(lsratio_handle,3,0,5,LB_Ent)<=0||
         CopyBuffer(lsratio_saida_handle,0,0,5,LS_Said)<=0||
         CopyBuffer(lsratio_saida_handle,1,0,5,UB_Said)<=0||
         CopyBuffer(lsratio_saida_handle,2,0,5,ML_Said)<=0||
         CopyBuffer(lsratio_saida_handle,3,0,5,LB_Said)<=0||
         CopyClose(Symbol1,PERIOD_CURRENT,0,5,close_sb1)<=0||
         CopyClose(Symbol2,PERIOD_CURRENT,0,5,close_sb2)<=0;

   return(b_get);
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
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
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
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==ptype)
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
         if(myorder.Magic()==Magic_Number) mytrade.OrderDelete(o_ticket);
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
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Magic()==Magic_Number)
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
//| Delete Orders                                                    |
//+------------------------------------------------------------------+
void DeleteOrders(const ENUM_ORDER_TYPE order_type)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               mytrade.OrderDelete(myorder.Ticket());
  }
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
         if(mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
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
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
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
bool PosicaoAberta_Symbol1()
  {
   if(myposition.SelectByMagic(Symbol1,Magic_Number))
      return true;
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PosicaoAberta_Symbol2()
  {
   if(myposition.SelectByMagic(Symbol2,Magic_Number))
      return true;
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculoLote(double valor,double price,double lotemin)
  {
   double lotes=MathRound(valor/(price*lotemin))*lotemin;
   return lotes;
  }
//+------------------------------------------------------------------+
