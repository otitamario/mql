//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

struct posicao
  {
   ulong             pos_compra;
   ulong             pos_stop;
   ulong             pos_take;
  };

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>
#include <Controls\Dialog.mqh>

#define INFOPANEL_SIZE 3 // Size of the array for info panel objects
#define EXPERT_NAME MQL5InfoString(MQL5_PROGRAM_NAME) // Name of the Expert Advisor


//Classes
CNewBar NewBar;
CTimer Timer;
CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;

// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=9072018;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input double Lot=1000;//Lote Entrada
input double _Stop=0.10;//Valor do Stop Loss  em Reais e Centavos
input bool UseTake1=true;//Usar Take Profit 1
input double _TakeProfit1=0.02; //Valor do Take Profit 1 em Reais e Centavos
input bool UseTake2=false;//Usar Take Profit 2
input double var_TakeProfit2=1.10; //Variação Positiva em Porcentagem para o Take Profit 2
input double _TakeProfit2=0.05; //Valor em centavos acima da Variação do Take Profit 2
input double var_neg_hist=0.70;//Variacao Percentual Negativa Historica(digitar>0)
input double dist_ask=0.02;//Distancia da Entrada para o ASK em centavos

sinput string horarios_ordens="###----Horario Ordens: Digite os horarios em ordem crescente----#####";
input bool usar_h0=true;// Usar Horario 1
input string hora0="9:30:05";//Horario Ordem 1
input bool usar_h1=true;// Usar Horario 2
input string hora1="10:30:05";//Horario Ordem 2
input bool usar_h2=true;// Usar Horario 3
input string hora2="11:30:05";//Horario Ordem 3
input bool usar_h3=true;// Usar Horario 4
input string hora3="12:30:05";//Horario Ordem 4
input bool usar_h4=true;// Usar Horario 5
input string hora4="13:30:05";//Horario Ordem 5
input bool usar_h5=true;// Usar Horario 6
input string hora5="14:30:05";//Horario Ordem 6
input bool usar_h6=true;// Usar Horario 7
input string hora6="14:50:05";//Horario Ordem 7
input bool usar_h7=true;// Usar Horario 8
input string hora7="15:30:05";//Horario Ordem 8
input bool usar_h8=true;// Usar Horario 9
input string hora8="16:00:05";//Horario Ordem 9
input bool usar_h9=true;// Usar Horario 10
input string hora9="16:45:05";//Horario Ordem 10

sinput string shorario="############------FILTRO DE HORARIO------#################";

input bool UseTimer = true;
input int StartHour = 9;//Hora de Inicio
input int StartMinute=0;//Minuto de Inicio

sinput string horafech="HORARIO PARA FECHAMENTO DE POSICOES E ORDENS";
input int EndHour=17;//Hora de Fechamento
input int EndMinute=00;//Minuto de Fechamento
input bool Daytrade=true;// Fechar posicoes Daytrade fim do dia

                         //Variaveis 
string original_symbol;
double ask,bid;
double lucro_total,pontos_total,lucro_liquido;
bool timerOn;
double ponto,ticksize,digits;
long curChartID;
double high[],low[],open[],close[];
ulong ENTRADAS_TOTAL;
ulong trade_ticket,compra1_ticket,venda1_ticket,stp_venda_ticket,stp_compra_ticket,tkp_venda_ticket,tkp_compra_ticket;

double buyprice,sellprice,oldprice;
string informacoes=" ";
string exp_name="_"+MQLInfoString(MQL_PROGRAM_NAME);
int PrevPositions;
datetime time_novodia[4];
int res_code;
double preco_take;

datetime hor_ordens[10];
posicao posicao_atual;
int dim_horarios;
//--- GLOBAL VARIABLES
string             pos_resultado=" ";           // Resultado
string            pos_entradas=" ";     // Entradas
string               pos_variacao=" ";         // Variacao

//--- Array of names of objects that display the names of position properties
string pos_prop_names[INFOPANEL_SIZE]=
  {
   "name_resultado",
   "name_entradas",
   "name_variacao"
  };
// Array of names of objects that display values of position properties
string pos_prop_values[INFOPANEL_SIZE]=
  {
   "value_resultado",
   "value_entradas",
   "value_variacao"
  };
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   original_symbol=Symbol();
   trade_ticket=0;
   ENTRADAS_TOTAL=0;
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
   lucro_total=0.0;
   pontos_total=0.0;
   informacoes=" ";

   hor_ordens[0]=usar_h0?StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+hora0):INT_MAX;
   hor_ordens[1]=usar_h1?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora1):INT_MAX;
   hor_ordens[2]=usar_h2?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora2):INT_MAX;
   hor_ordens[3]=usar_h3?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora3):INT_MAX;
   hor_ordens[4]=usar_h4?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora4):INT_MAX;
   hor_ordens[5]=usar_h5?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora5):INT_MAX;
   hor_ordens[6]=usar_h6?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora6):INT_MAX;
   hor_ordens[7]=usar_h7?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora7):INT_MAX;
   hor_ordens[8]=usar_h8?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora8):INT_MAX;
   hor_ordens[9]=usar_h9?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora9):INT_MAX;


   ArraySort(hor_ordens);
//
//   for(int i=0;i<9;i++)
//     {
//      if(hor_ordens[i+1]<hor_ordens[i])
//        {
//         string erro="Horário das ordens não está ordenado";
//         MessageBox(erro);
//         Print(erro);
//         return(INIT_PARAMETERS_INCORRECT);
//
//        }
//     }

   HLineCreate(0,"Compra",0,PrecoLinhaCompra(),clrLime,STYLE_SOLID,2,false,false,true,0);

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
   if(var_neg_hist<=0)
     {
      string erro="Digite na Variação Negativa Histórica um numero >0";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);

     }
   if(UseTake1 && UseTake2)
     {
      string erro="Usar apenas um dos dois TakeProfit";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);

     }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

   Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");

   if(reason==REASON_REMOVE)
      //--- Delete all objects relating to the info panel from the chart
      DeleteInfoPanel();
   HLineDelete(0,"Compra");

//---

  }
//+------------------------------------------------------------------+ 
//| TradeTransaction function                                        | 
//+------------------------------------------------------------------+ 
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {

//--- get transaction type as enumeration value 
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
   double price_deal;
//--- if transaction is result of addition of the transaction in history

   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      ulong order_ticket=trans.order;

      if(order_ticket==trade_ticket && trans.deal_type!=DEAL_TYPE_BALANCE)ENTRADAS_TOTAL++;

      if(StringSubstr(mydeal.Comment(),0,2)=="sl" || StringSubstr(mydeal.Comment(),0,2)=="tp")
        {
         DeleteOrders(ORDER_TYPE_SELL_STOP);
         DeleteOrders(ORDER_TYPE_BUY_STOP);
         informacoes="Posicao Fechada por "+StringSubstr(mydeal.Comment(),0,2)=="sl"?"Stop Loss":"Take Profit";
         Print(informacoes);
        }

     }//End TRANSACTIONS DEAL ADD
   if(type==TRADE_TRANSACTION_HISTORY_ADD)
     {

      ulong order_ticket=trans.order;
      myorder.Select(order_ticket);
      myposition.SelectByTicket(trans.position);

      //Stop para posição comprada
      if(order_ticket==compra1_ticket && trans.order_state==ORDER_STATE_FILLED)

        {

         sellprice=NormalizeDouble(myposition.PriceOpen()-_Stop,digits);
         oldprice=PriceLastStopOrder(ORDER_TYPE_SELL_STOP);
         if(oldprice==-1 || sellprice>oldprice && Buy_opened()) // No order or New price is better
           {
            DeleteOrders(ORDER_TYPE_SELL_STOP);
            res_code=-1;
            while(res_code<=0)
              {

               mytrade.SellStop(Lot,sellprice,original_symbol,0,0,0,0,"STOP"+exp_name);
               stp_venda_ticket=mytrade.ResultOrder();
               res_code=mytrade.ResultOrder();
               Print("RES_CODE ",res_code);
               if(res_code==0)
                 {
                  myposition.SelectByTicket(compra1_ticket);
                  sellprice=NormalizeDouble(myposition.PriceOpen()-_Stop*ponto,digits);

                 }
              }
           }

         //Saida TakeProfit
         if(UseTake1) preco_take=NormalizeDouble(myposition.PriceOpen()+_TakeProfit1,digits);
         if(UseTake2)
           {
            if(VarDiaria()>=var_TakeProfit2) preco_take=NormalizeDouble(myposition.PriceOpen()+_TakeProfit2,digits);
            else preco_take=NormalizeDouble(myposition.PriceOpen()+_TakeProfit1,digits);
           }

         mytrade.SellLimit(Lot,preco_take,NULL,0,0,0,0,"TAKE PROFIT");
         tkp_compra_ticket=mytrade.ResultOrder();

        }
      //--------------------------------------------------
      if(order_ticket==stp_venda_ticket && trans.order_type==ORDER_TYPE_SELL_STOP && trans.order_state==ORDER_STATE_FILLED)
        {
         informacoes="Posicao Fechada por Ordem Sell Stop";
         Print(informacoes);
         DeleteALL();
         if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
           {
            res_code=-1;
            while(res_code<=0)
              {
               mytrade.PositionCloseBy(compra1_ticket,stp_venda_ticket);
               res_code=mytrade.ResultOrder();
               Print("RES_CODE ",res_code);

              }
           }

        }

      if(order_ticket==tkp_compra_ticket && trans.order_state==ORDER_STATE_FILLED)
        {
         informacoes="Take Profit atingido";
         DeleteALL();
         Print(informacoes);
         if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING) mytrade.PositionCloseBy(compra1_ticket,tkp_compra_ticket);

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
//+------------------------------------------------------------------+



//+-------------ROTINAS----------------------------------------------+

void Main_Program()
  {

   mysymbol.Refresh();
   mysymbol.RefreshRates();

   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }
   GetPositionProperties();

   bool novodia;
   novodia=NewBar.CheckNewBar(original_symbol,PERIOD_D1);
   if(novodia)
     {
      ENTRADAS_TOTAL=0;
      Comment(""+"\n"+""+"\n"+""+"\n"+""+"\n"+""+"\n");
      informacoes=" ";

      hor_ordens[0]=usar_h0?StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+hora0):INT_MAX;
      hor_ordens[1]=usar_h1?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora1):INT_MAX;
      hor_ordens[2]=usar_h2?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora2):INT_MAX;
      hor_ordens[3]=usar_h3?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora3):INT_MAX;
      hor_ordens[4]=usar_h4?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora4):INT_MAX;
      hor_ordens[5]=usar_h5?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora5):INT_MAX;
      hor_ordens[6]=usar_h6?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora6):INT_MAX;
      hor_ordens[7]=usar_h7?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora7):INT_MAX;
      hor_ordens[8]=usar_h8?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora8):INT_MAX;
      hor_ordens[9]=usar_h9?StringToTime(TimeToString(TimeCurrent(), TIME_DATE) + " " +hora9):INT_MAX;

      ArraySort(hor_ordens);

     }

   lucro_total=LucroOrdens()+LucroPositions();

   timerOn=false;
   if(UseTimer==true)
     {
      timerOn=Timer.DailyTimer(StartHour,StartMinute,EndHour,EndMinute);
     }
   else
     {
      timerOn=true;
     }
   if(timerOn==false)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
     }

//Atualizacao das Cotacoes----ticks
   MqlTick last_tick;
   if(SymbolInfoTick(Symbol(),last_tick))
     {
      bid= last_tick.bid;
      ask=last_tick.ask;
     }
   else
     {
      Print("Falhou obter o tick");
      return;
     }
   double spread=ask-bid;
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }

//----------------------------------------------------------------------------

//------------------------------------------------------------------------------

   if(timerOn)

     {// inicio Timer On

      int pos_ent=PosicaoEntrada();
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(!PosicaoAberta() && OrdemAberta(ORDER_TYPE_BUY_LIMIT) && TimeCurrent()<=hor_ordens[pos_ent]-4 && TimeCurrent()>hor_ordens[pos_ent]-5)DeleteALL();
      if(TimeCurrent()==hor_ordens[pos_ent] && !Buy_opened() && !OrdemAberta(ORDER_TYPE_BUY_LIMIT) && ask>=PrecoLinhaCompra())
        {
         mytrade.BuyLimit(Lot,NormalizeDouble(ask-dist_ask,digits),original_symbol,0,0,0,0,"BUY");
         compra1_ticket=mytrade.ResultOrder();
        }
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
      if(NewBar.CheckNewBar(Symbol(),periodoRobo))
        {

        }//Fim NewBar

     }//End Timer On
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      if(Daytrade==true)
        {
         DeleteALL();
         CloseALL();
        } // fechou ordens pendentes no Day trade fora do horario
     }
  }
//+------------------------------------------------------------------+
//| Rotinas                                                   |
//+------------------------------------------------------------------+
bool Buy_opened()
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name() && myposition.PositionType()==POSITION_TYPE_BUY)
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
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name() && myposition.PositionType()==POSITION_TYPE_SELL)
         return(true);  //It is a Buy
     }
   return(false);
  }
//+------------------------------------------------------------------+

int PosicaoEntrada()
  {
   for(int i=0;i<10;i++)
      if(TimeCurrent()<=hor_ordens[i]) return i;
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void Comentarios()
  {
   string s_coment=""+"\n"+"RESULTADO DIÁRIO $: "+DoubleToString(lucro_total,2)+"\n";
   s_coment+="ENTRADAS NO DIA: "+IntegerToString(ENTRADAS_TOTAL)+"\n";
   s_coment+=original_symbol+": "+DoubleToString(VarDiaria(),2)+" %"+"\n";

   s_coment+=informacoes;
   Comment(s_coment);

  }
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
//------------------------------------------------------------------------
// Select total orders in history and get total pending orders
// (as shown within the COrderInfo class section). 
void DeleteALL()
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
     {
      ulong o_ticket=OrderGetTicket(j);
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
     {
      ulong o_ticket=OrderGetTicket(j);
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
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
      if(myorder.SelectByIndex(i))     // selects the pending order by index for further access to its properties
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
      if(myorder.SelectByIndex(i))     // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(myorder.OrderType()==order_type)
               return true;
   return false;
  }
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
double VarDiaria()
  {
   double fec_ant[1];
   double variacao;
   CopyClose(original_symbol,PERIOD_D1,1,1,fec_ant);
   variacao=(close[0]-fec_ant[0])/fec_ant[0];
   variacao=variacao*100;
   return variacao;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PrecoLinhaCompra()
  {
   double fec_ant[1];
   double preco;
   CopyClose(original_symbol,PERIOD_D1,1,1,fec_ant);
   preco=MathRound((fec_ant[0]*(1-var_neg_hist/100))/ticksize)*ticksize;
   return preco;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+ 
//| Criar a linha horizontal                                         | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long            chart_ID=0,        // ID de gráfico 
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
//| Excluir uma linha horizontal                                     | 
//+------------------------------------------------------------------+ 
bool HLineDelete(const long   chart_ID=0,   // ID do gráfico 
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
//|                                                                  |
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| CREATING THE EDIT OBJECT                                         |
//+------------------------------------------------------------------+
void CreateEdit(long             chart_id,         // chart id
                int              sub_window,       // (sub)window number
                string           name,             // object name
                string           text,             // displayed text
                ENUM_BASE_CORNER corner,           // chart corner
                string           font_name,        // font
                int              font_size,        // font size
                color            font_color,       // font color
                int              x_size,           // width
                int              y_size,           // height
                int              x_distance,       // X-coordinate
                int              y_distance,       // Y-coordinate
                long             z_order,          // Z-order
                color            background_color, // background color
                bool             read_only)        // Read Only flag
  {
// If the object has been created successfully...
   if(ObjectCreate(chart_id,name,OBJ_EDIT,sub_window,0,0))
     {
      // ...set its properties
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);                 // displayed text
      ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);            // set the chart corner
      ObjectSetString(chart_id,name,OBJPROP_FONT,font_name);            // set the font
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,font_size);       // set the font size
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,font_color);         // font color
      ObjectSetInteger(chart_id,name,OBJPROP_BGCOLOR,background_color); // background color
      ObjectSetInteger(chart_id,name,OBJPROP_XSIZE,x_size);             // width
      ObjectSetInteger(chart_id,name,OBJPROP_YSIZE,y_size);             // height
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,x_distance);     // set the X-coordinate
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,y_distance);     // set the Y-coordinate
      ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,false);         // cannot select the object if FALSE
      ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,z_order);           // Z-order of the object
      ObjectSetInteger(chart_id,name,OBJPROP_READONLY,read_only);       // Read Only
      ObjectSetInteger(chart_id,name,OBJPROP_ALIGN,ALIGN_LEFT);         // align left
      ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n");              // no tooltip if "\n"
     }
  }
//+------------------------------------------------------------------+
//| CREATING THE LABEL OBJECT                                        |
//+------------------------------------------------------------------+
void CreateLabel(long               chart_id,   // chart id
                 int                sub_window, // (sub)window number
                 string             name,       // object name
                 string             text,       // displayed text
                 ENUM_ANCHOR_POINT  anchor,     // anchor point
                 ENUM_BASE_CORNER   corner,     // chart corner
                 string             font_name,  // font
                 int                font_size,  // font size
                 color              font_color, // font color
                 int                x_distance, // X-coordinate
                 int                y_distance, // Y-coordinate
                 long               z_order)    // Z-order
  {
// If the object has been created successfully...
   if(ObjectCreate(chart_id,name,OBJ_LABEL,sub_window,0,0))
     {
      // ...set its properties
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);              // displayed text
      ObjectSetString(chart_id,name,OBJPROP_FONT,font_name);         // set the font
      ObjectSetInteger(chart_id,name,OBJPROP_COLOR,font_color);      // set the font color
      ObjectSetInteger(chart_id,name,OBJPROP_ANCHOR,anchor);         // set the anchor point
      ObjectSetInteger(chart_id,name,OBJPROP_CORNER,corner);         // set the chart corner
      ObjectSetInteger(chart_id,name,OBJPROP_FONTSIZE,font_size);    // set the font size
      ObjectSetInteger(chart_id,name,OBJPROP_XDISTANCE,x_distance);  // set the X-coordinate
      ObjectSetInteger(chart_id,name,OBJPROP_YDISTANCE,y_distance);  // set the Y-coordinate
      ObjectSetInteger(chart_id,name,OBJPROP_SELECTABLE,false);      // cannot select the object if FALSE
      ObjectSetInteger(chart_id,name,OBJPROP_ZORDER,z_order);        // Z-order of the object
      ObjectSetString(chart_id,name,OBJPROP_TOOLTIP,"\n");           // no tooltip if "\n"
     }
  }
//+------------------------------------------------------------------+
//| DELETING THE OBJECT BY NAME                                      |
//+------------------------------------------------------------------+
void DeleteObjectByName(string name)
  {
   int  sub_window=0;      // Returns the number of the subwindow where the object is located
   bool res       =false;  // Result following an attempt to delete the object
//--- Find the object by name
   sub_window=ObjectFind(ChartID(),name);
//---
   if(sub_window>=0) // If it has been found,..
     {
      res=ObjectDelete(ChartID(),name); // ...delete it
      //---
      // If an error occurred when deleting the object, print the relevant message
      if(!res)
         Print("Error deleting the object: ("+IntegerToString(GetLastError())+") ");
     }
  }
//+------------------------------------------------------------------+
//| GETTING POSITION PROPERTIES                                      |
//+------------------------------------------------------------------+
void GetPositionProperties()
  {
   pos_resultado=DoubleToString(lucro_total,2);
   pos_entradas=IntegerToString(ENTRADAS_TOTAL);
   pos_variacao=DoubleToString(VarDiaria(),2);
//---
   SetInfoPanel(); // Set/update the info panel
  }
//+------------------------------------------------------------------+
//| SETTING THE INFO PANEL                                           |
//|------------------------------------------------------------------+
void SetInfoPanel()
  {
   int               y_bg=18;             // Y-coordinate for the background and header
   int               y_property=32;       // Y-coordinate for the list of properties and their values
   int               line_height=12;      // Line height
//---
   int               font_size=8;         // Font size
   string            font_name="Calibri"; // Font
   color             font_color=clrBlack; // Font color
//---
   ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT_UPPER; // Anchor point in the top left corner
   ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER; // Origin of coordinates in the top left corner of the chart
//--- X-coordinates
   int               x_first_column=20;  // First column (names of properties)
   int               x_second_column=85;  // Second column (values of properties)
//--- Array of Y-coordinates for the names of position properties and their values
   int               y_prop_array[INFOPANEL_SIZE]={0};
//--- Fill the array with coordinates for each line on the info panel
   for(int i=0; i<INFOPANEL_SIZE; i++)
     {
      if(i==0) y_prop_array[i]=y_property;
      else     y_prop_array[i]=y_property+line_height*i;
     }
//--- Background of the info panel
   CreateEdit(0,0,"InfoPanelBackground","",corner,font_name,8,clrBlack,170,100,10,y_bg,0,clrCornflowerBlue,true);
//--- Header of the info panel
   CreateEdit(0,0,"InfoPanelHeader",MQLInfoString(MQL_PROGRAM_NAME),corner,font_name,8,clrWhite,170,14,10,y_bg,1,clrFireBrick,true);
//--- List of the names of position properties and their values
//    Property name
   CreateLabel(0,0,pos_prop_names[0],"Resultado Diario :",anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[0],2);
//    Property value
   CreateLabel(0,0,pos_prop_values[0],GetPropertyValue(0),anchor,corner,font_name,font_size,font_color,x_second_column+30,y_prop_array[0],2);
//---

   CreateLabel(0,0,pos_prop_names[1],"Entradas :",anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[1],2);
   CreateLabel(0,0,pos_prop_values[1],GetPropertyValue(1),anchor,corner,font_name,font_size,font_color,x_second_column,y_prop_array[1],2);
//---
   CreateLabel(0,0,pos_prop_names[2],"Variacao "+original_symbol+" : ",anchor,corner,font_name,font_size,font_color,x_first_column,y_prop_array[2],2);
   CreateLabel(0,0,pos_prop_values[2],GetPropertyValue(2),anchor,corner,font_name,font_size,font_color,x_second_column+30,y_prop_array[2],2);
//---

//---
   ChartRedraw(); // Redraw the chart
  }
//+------------------------------------------------------------------+
//| DELETING THE INFO PANEL                                          |
//+------------------------------------------------------------------+
void DeleteInfoPanel()
  {
   DeleteObjectByName("InfoPanelBackground");   // Delete the panel background
   DeleteObjectByName("InfoPanelHeader");       // Delete the panel header
//--- Delete position properties and their values
   for(int i=0; i<INFOPANEL_SIZE; i++)
     {
      DeleteObjectByName(pos_prop_names[i]);    // Delete the property
      DeleteObjectByName(pos_prop_values[i]);   // Delete the value
     }
//---
   ChartRedraw(); // Redraw the chart
  }
//+------------------------------------------------------------------+
//| RETURNING THE STRING WITH POSITION PROPERTY VALUE                |
//+------------------------------------------------------------------+
string GetPropertyValue(int number)
  {
//--- Sign indicating the lack of an open position or a certain property
//    E.g. the lack of a comment, Stop Loss or Take Profit
   string empty="-";

   switch(number)
     {
      case 0  : return(DoubleToString(lucro_total,2));      break;
      case 1  : return(IntegerToString(ENTRADAS_TOTAL));    break;
      case 2  : return(DoubleToString(VarDiaria(),2));      break;

      default : return(empty);

     }
  }
//+------------------------------------------------------------------+
