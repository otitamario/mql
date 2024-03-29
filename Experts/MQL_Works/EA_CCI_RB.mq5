//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum _TimeFrames
  {
   _TF_Current,//PERIOD_CURRENT
   _TF_M1,//PERIOD_M1
   _TF_M5,//PERIOD_M5
   _TF_M15,//PERIOD_M15
   _TF_M30,//PERIOD_M30
   _TF_H1,//PERIOD_H1
   _TF_H4//PERIOD_H4
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include<ChartObjects\ChartObjectsLines.mqh>
#include <Controls\Defines.mqh>
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
//#undef CONTROLS_LABEL_COLOR  

color borda_bg=clrNONE;//Cor Borda
color painel_bg=clrBlack;//Cor Painel 
color cor_txt_borda_bg=clrYellowGreen;//Cor Texto Borda
                                      //color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG          borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg

#include <Expert_Class_New.mqh>
MyPanel ExtDialog;

CLabel            m_label[50];
CButton BotaoFechar;

#define LARGURA_PAINEL 270 // Largura Painel
#define ALTURA_PAINEL 130 // Altura Painel




// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input _TimeFrames _PeriodoRoboTF=_TF_Current;//TIMEFRAME ROBO
input int MAGIC_NUMBER=26032019;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
sinput string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input double Lot=0.01;//Lote Entrada
input double Multiplier=2;//Multiplicador Das Entradas
sinput string Sind="############----------------------------CCI---------------------------########";//CCI
input int per_cci=14;//Período CCI
input double sobrecompra_cci=100.0;//Nível SobreCompra CCI 
input double sobrevenda_cci=-100.0;//Nível SobreVenda CCI 

sinput string Lucro="###---------------------Usar Lucro/Prejuizo para Fechamento-----------------------#####";    //Lucro
input double lucro=5.0;//Lucro em Moeda para Fechar Posicoes 
input double prejuizo=20.0;//Prejuizo em Moeda para Fechar Posicoes

input bool UsarLucro=false;//Usar Lucro Mensal para Fechamento  True/False
input double _lucro_mes=1000.0;//Lucro Mensal em Moeda para Fechar Posicoes 
input double _prejuizo_mes=500.0;//Prejuizo Mensal em Moeda para Fechar Posicoes 

sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=false;//Usar Filtro de Horário: True/False
input string start_hour="9:04";//Horario Inicial
input string end_hour="17:20";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario
sinput string sdias="FILTRO DOS DIAS DA SEMANA";//Dias da Semana
input bool trade0=true;// Operar Domingo
input bool trade1=true;// Operar Segunda
input bool trade2=true;// Operar Terça
input bool trade3=true;// Operar Quarta
input bool trade4=true;// Operar Quinta
input bool trade5=true;// Operar Sexta
input bool trade6=true;// Operar Sábado
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyRobot: public MyExpert
  {
private:
   CChartObjectHLine HLine_SobComp,HLine_SobVend;
   ENUM_TIMEFRAMES   periodoRobo;
   string            currency_symbol;
   double            sl,tp,price_open;
   double            max_dia,min_dia;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   CNewBar           Bar_NovoMes;
   bool              novomes;
   bool              tradeOnMes;
   double            vol_pos,vol_stp,preco_stp;
   double            sl_position,tp_position;
   double            Buyprice,Sellprice;
   CiCCI            *cci;
   int               subchartCCI;
   //  double            Cap_Buf0[],Cap_Buf1[],Cap_Buf2[],Cap_Buf3[],Cap_Buf4[],Cap_Buf5[],Cap_Buf6[];
   // double            Cap_Buf7[],Cap_Buf8[],Cap_Buf9[],Cap_Buf10[],Cap_Buf11[],Cap_Buf12[],Cap_Buf13[];

public:
   void              MyRobot();
   void             ~MyRobot();
   int               OnInit();
   void              OnDeinit(const int reason);
   void              OnTick();
   string GetCurrency(){return SymbolInfoString(original_symbol,SYMBOL_CURRENCY_BASE);}
   bool              TimeDayFilter();
   virtual bool      GetIndValue();
   virtual bool      BuySignal();
   virtual bool      SellSignal();
   virtual void      MytradeTransaction();
   bool              IsFinishedBar1(void);
   void              SegurancaPos(int nsec);
   void              SelecionaTF();
   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);
   int               Loss();
   double            CalcLot();
   int               TotalPosBuy();
   int               TotalPosSell();
   double            CalcLotBuy();
   double            CalcLotSell();
  };

MyRobot MyEA;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::MyRobot()
  {
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::~MyRobot()
  {
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::OnInit(void)
  {
   SelecionaTF();
   tradeOn=true;
   tradeOnMes=true;
   setExpName();
   setSymbol(Symbol());
   setOriginalSymbol(Symbol());
   setMagic(MAGIC_NUMBER);
   if(SymbolInfoInteger(original_symbol,SYMBOL_EXPIRATION_MODE)==2)order_time_type=1;
   else order_time_type=0;
   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(MAGIC_NUMBER);
   mytrade.SetDeviationInPoints(50);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
   mytrade.SetTypeFillingBySymbol(original_symbol);
   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);

   int find_wdo=StringFind(original_symbol,"WDO");
   int find_dol=StringFind(original_symbol,"DOL");
   if(find_dol>=0|| find_wdo>=0) ponto=1.0;
   gv.Init(symbol,Magic_Number);
   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today_prev",(double)TimeNow.day_of_year);
   gv.Set("gv_mes_prev",(double)TimeNow.mon);
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   if(hora_inicial>hora_final)
      hora_final=hora_final+PeriodSeconds(PERIOD_D1);

   setNameGvOrder();

   long curChartID=ChartID();
   cci=new CiCCI;
   cci.Create(Symbol(),periodoRobo,per_cci,PRICE_CLOSE);
   subchartCCI=(int)ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL);
   if(!cci.AddToChart(curChartID,subchartCCI))
      Print("Erro Anexar Indicador CCI no Gráfico: ",GetLastError());

   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      if(!HLine_SobComp.Create(curChartID,"SobreCompra",subchartCCI,sobrecompra_cci))
         Print("Erro Criar Linha SobComp: ",GetLastError());
      HLine_SobComp.Color(clrRed);
      if(!HLine_SobVend.Create(curChartID,"SobreVenda",subchartCCI,sobrevenda_cci))
         Print("Erro Criar Linha SobVend: ",GetLastError());
      HLine_SobVend.Color(clrBlue);

     }
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(ChartID(),CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(Lot<mysymbol.LotsMin())
     {
      string erro="Lote deve ser maior ou igual a "+DoubleToString(mysymbol.LotsMin(),2);
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(sobrecompra_cci<sobrevenda_cci)
     {
      string erro="CCI SobreCompra deve ser maior que SobreVenda";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(HistorySelect(iTime(original_symbol,PERIOD_D1,0),TimeCurrent()+PeriodSeconds(PERIOD_D1)))
     {
      int total_deals=HistoryDealsTotal();
      int ticket_history_deal=0;
      int cont_deals=0;
      for(int i=0;i<total_deals;i++)
        {
         //--- try to get deals ticket_history_deal
         if((ticket_history_deal=(int)HistoryDealGetTicket(i))>0)
           {
            int deal_magic=(int)HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
            if(deal_magic==Magic_Number && HistoryDealGetString(ticket_history_deal,DEAL_SYMBOL)==mysymbol.Name())cont_deals+=1;
           }
        }
      gv.Set("deals_total_prev",(double)cont_deals);

     }

   return(INIT_SUCCEEDED);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   delete(cci);
   DeletaIndicadores();
   int k=ObjectsDeleteAll(0,-1,OBJ_HLINE);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTick(void)
  {

   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today",(double)TimeNow.day_of_year);
   gv.Set("gv_mes",(double)TimeNow.mon);

   bool novodia;
   novodia=Bar_NovoDia.CheckNewBar(original_symbol,PERIOD_D1);

   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      gv.Set("glob_entr_tot",0.0);
      gv.Set("deals_total_prev",0.0);
      tradeOn=true;
     }

   gv.Set("gv_today_prev",gv.Get("gv_today"));

   novomes=Bar_NovoMes.CheckNewBar(original_symbol,PERIOD_MN1);

   if(novomes || gv.Get("gv_mes")!=gv.Get("gv_mes_prev"))
     {
      tradeOnMes=true;
     }
   gv.Set("gv_mes_prev",gv.Get("gv_mes"));

// MytradeTransaction();

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   cci.Refresh();
   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
   if(bid>ask)return; //Leilao
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   if(hora_inicial>hora_final)
      hora_final=hora_final+PeriodSeconds(PERIOD_D1);

   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   lucro_total=LucroTotal();
   lucro_total_semana=LucroTotalSemana();
   lucro_total_mes=LucroTotalMes();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(LucroPositions()>=lucro || LucroPositions()<=-prejuizo)
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      return;
     }

   if(UsarLucro && (lucro_total_mes>=_lucro_mes || lucro_total_mes<=-_prejuizo_mes))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
      tradeOnMes=false;
      return;
     }

   timerOn=true;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!timerOn && daytrade)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
     }

   if(tradeOn && tradeOnMes && timerOn)

     {// inicio Trade On

      if(!Buy_opened())gv.Set("low_buy",0.0);
      if(!Sell_opened())gv.Set("high_sell",0.0);
      if(Bar_NovaBarra.CheckNewBar(original_symbol,periodoRobo))
        {
         if(BuySignal())
           {
            if(!Buy_opened())gv.Set("low_buy",close[1]);
            if(close[1]<=gv.Get("low_buy"))
              {
               if(mytrade.Buy(CalcLotBuy(),original_symbol,0,0,0,"BUY"+exp_name))
                 {
                  gv.Set(cp_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Erro enviar ordem ",GetLastError());
              }
           }

         if(SellSignal())
           {
            if(!Sell_opened())gv.Set("high_sell",close[1]);
            if(close[1]>=gv.Get("high_sell"))
              {
               if(mytrade.Sell(CalcLotSell(),original_symbol,0,0,0,"SELL"+exp_name))
                 {
                  gv.Set(vd_tick,(double)mytrade.ResultOrder());
                 }
               else Print("Erro enviar ordem ",GetLastError());
              }
           }

        }//End NewBar

     }//End Trade On

  }//Fim Ontick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MyRobot::SelecionaTF(void)
  {
   switch(_PeriodoRoboTF)
     {
      case   _TF_Current:
         periodoRobo=PERIOD_CURRENT;
         break;
      case  _TF_M1:
         periodoRobo=PERIOD_M1;
         break;
      case  _TF_M5:
         periodoRobo=PERIOD_M5;
         break;
      case  _TF_M15:
         periodoRobo=PERIOD_M15;
         break;
      case _TF_M30:
         periodoRobo=PERIOD_M30;
         break;
      case _TF_H1:
         periodoRobo=PERIOD_H1;
         break;
      case _TF_H4:
         periodoRobo=PERIOD_H4;
         break;
      default:
         periodoRobo=PERIOD_CURRENT;
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::CalcLot()
  {
   double lots=Lot;
   int loss=Loss();
   double lot_step=mysymbol.LotsStep();
   if(loss>0){ lots=NormalizeDouble(lots*MathPow(Multiplier,loss),2);}
   return( NormalizeDouble(MathRound(lots/lot_step)*lot_step,2) );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::CalcLotBuy(void)
  {
   double lots=Lot;
   int total_buy=TotalPosBuy();
   double lot_step=mysymbol.LotsStep();
   if(total_buy>0){ lots=NormalizeDouble(lots*MathPow(Multiplier,total_buy),2);}
   return( NormalizeDouble(MathRound(lots/lot_step)*lot_step,2) );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::CalcLotSell(void)
  {
   double lots=Lot;
   int total_sell=TotalPosSell();
   double lot_step=mysymbol.LotsStep();
   if(total_sell>0){ lots=NormalizeDouble(lots*MathPow(Multiplier,total_sell),2);}
   return( NormalizeDouble(MathRound(lots/lot_step)*lot_step,2) );
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::Loss()
  {
   int cnt=0;

   if(HistorySelect(0,TimeCurrent()))

      for(int x=HistoryDealsTotal()-1; x>=0; x--)
        {
         ulong ticket=HistoryDealGetTicket(x);
         string _symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         ulong type=HistoryDealGetInteger(ticket,DEAL_TYPE);
         ulong magic = HistoryDealGetInteger(ticket,DEAL_MAGIC);
         ulong entry = HistoryDealGetInteger(ticket,DEAL_ENTRY);
         double profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
         string comment=HistoryDealGetString(ticket,DEAL_COMMENT);
         if(_symbol!=_Symbol) continue;
         if(magic== Magic_Number && entry== DEAL_ENTRY_OUT && profit>0) break;
         if(magic==Magic_Number && entry==DEAL_ENTRY_OUT)
            if(type==DEAL_TYPE_BUY || type==DEAL_TYPE_SELL) cnt++;
        }
   return(cnt);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::IsFinishedBar1(void)
  {
   datetime hora0=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+"00:00");
   int barras=Bars(_Symbol,periodoRobo,hora0,TimeCurrent());
   if(barras==2)return true;
   return false;
  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool MyRobot::GetIndValue()
  {
   bool b_get;
   b_get=CopyHigh(Symbol(),period,0,5,high)<=0 || 
         CopyOpen(Symbol(),period,0,5,open)<=0 || 
         CopyLow(Symbol(),period,0,5,low)<=0 || 
         CopyClose(Symbol(),period,0,5,close)<=0;

   return(b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::TimeDayFilter()
  {
   bool filter=false;
   MqlDateTime TimeToday;
   TimeToStruct(TimeCurrent(),TimeToday);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   switch(TimeToday.day_of_week)
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
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::BuySignal()
  {
   bool signal=false;
   signal=close[1]<close[2] && cci.Main(1)<=sobrevenda_cci;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal=false;
   signal=close[1]>close[2] && cci.Main(1)>=sobrecompra_cci;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::TotalPosBuy()
  {
   int cnt=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
        {
         if(myposition.PositionType()==POSITION_TYPE_BUY)
            cnt+=1;
        }

     }
   return cnt;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::TotalPosSell()
  {
   int cnt=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
        {
         if(myposition.PositionType()==POSITION_TYPE_SELL)
            cnt+=1;
        }

     }
   return cnt;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::MytradeTransaction()
  {
   ulong order_ticket;
   ulong deals_ticket;
   uint total_deals,cont_deals;
   ulong ticket_history_deal,deal_magic;
   double buyprice,sellprice;
   int TENTATIVAS=10;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
         if(ticket_history_deal>0)
           {
            deal_magic=HistoryDealGetInteger(ticket_history_deal,DEAL_MAGIC);
            if(deal_magic==Magic_Number && HistoryDealGetString(ticket_history_deal,DEAL_SYMBOL)==mysymbol.Name())
              {
               cont_deals+=1;
               deals_ticket=ticket_history_deal;
              }
           }
        }

      gv.Set("last_deal_time",(double)HistoryDealGetInteger(deals_ticket,DEAL_TIME));
      gv.Set("deals_total",(double)cont_deals);

      if(gv.Get("deals_total")>gv.Get("deals_total_prev"))
        {

         if(deals_ticket>0)
           {
            mydeal.Ticket(deals_ticket);
            order_ticket=mydeal.Order();

            if(mydeal.Comment()=="BUY"+exp_name || mydeal.Comment()=="SELL"+exp_name)
              {
               gv.Set("glob_entr_tot",gv.Get("glob_entr_tot")+1);
              }

            if(mydeal.Comment()=="BUY"+exp_name)

              {
               myposition.SelectByTicket(order_ticket);
               int cont=0;
               buyprice=0;
               while(buyprice==0 && cont<TENTATIVAS)
                 {
                  buyprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(buyprice==0)buyprice=mysymbol.Ask();

              }
            //--------------------------------------------------

            if(mydeal.Comment()=="SELL"+exp_name)
              {
               myposition.SelectByTicket(order_ticket);
               sellprice=myposition.PriceOpen();
               int cont=0;
               sellprice=0;
               while(sellprice==0 && cont<TENTATIVAS)
                 {
                  sellprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(sellprice==0)sellprice=mysymbol.Bid();
              }

            if((mydeal.DealType()==DEAL_TYPE_BUY || mydeal.DealType()==DEAL_TYPE_SELL) && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))

              {
               if(mydeal.Profit()<0)
                 {
                  Print("Saída por STOP LOSS");
                 }

               if(mydeal.Profit()>0)
                 {
                  Print("Saída no GAIN");
                 }

              }

            lucro_orders=LucroOrdens();

           }// if dealsticket>0
        }//Fim deals>prev
     }//Fim HistorySelect
   gv.Set("deals_total_prev",gv.Get("deals_total"));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MyRobot::OnTradeTransaction(const MqlTradeTransaction &trans,
                                 const MqlTradeRequest &request,
                                 const MqlTradeResult &result)
  {
   double buyprice,sellprice;
   int TENTATIVAS=10;
   int cont;

//--- get transaction type as enumeration value

   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;

//--- if transaction is result of addition of the transaction in history
   if(type==TRADE_TRANSACTION_DEAL_ADD)
     {
      long deal_ticket= 0;
      long deal_order = 0;
      long deal_time=0;
      long deal_time_msc=0;
      ENUM_DEAL_TYPE deal_type=-1;
      long deal_entry=-1;
      ulong deal_magic = 0;
      long deal_reason = -1;
      long deal_position_id=0;
      double deal_volume= 0.0;
      double deal_price = 0.0;
      double deal_commission=0.0;
      double deal_swap=0.0;
      double deal_profit = 0.0;
      string deal_symbol = "";
      string deal_comment= "";
      string deal_external_id="";
      if(HistoryDealSelect(trans.deal))
        {
         deal_ticket= HistoryDealGetInteger(trans.deal,DEAL_TICKET);
         deal_order = HistoryDealGetInteger(trans.deal,DEAL_ORDER);
         deal_time=HistoryDealGetInteger(trans.deal,DEAL_TIME);
         deal_time_msc=HistoryDealGetInteger(trans.deal,DEAL_TIME_MSC);
         deal_type=(ENUM_DEAL_TYPE)HistoryDealGetInteger(trans.deal,DEAL_TYPE);
         deal_entry = HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
         deal_magic = HistoryDealGetInteger(trans.deal, DEAL_MAGIC);
         deal_reason= HistoryDealGetInteger(trans.deal,DEAL_REASON);
         deal_position_id=HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);

         deal_volume= HistoryDealGetDouble(trans.deal,DEAL_VOLUME);
         deal_price = HistoryDealGetDouble(trans.deal,DEAL_PRICE);
         deal_commission=HistoryDealGetDouble(trans.deal,DEAL_COMMISSION);
         deal_swap=HistoryDealGetDouble(trans.deal,DEAL_SWAP);
         deal_profit=HistoryDealGetDouble(trans.deal,DEAL_PROFIT);

         deal_symbol=HistoryDealGetString(trans.deal,DEAL_SYMBOL);
         deal_comment=HistoryDealGetString(trans.deal,DEAL_COMMENT);
         deal_external_id=HistoryDealGetString(trans.deal,DEAL_EXTERNAL_ID);

         if(deal_magic==Magic_Number)
           {
            GlobalVariableSet("last_deal_time",deal_time);

            if((deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL) && (deal_entry==DEAL_ENTRY_OUT))
              {
               if(deal_profit<0)
                 {
                  Print("Saída por STOP LOSS");
                 }

               if(deal_profit>0)
                 {
                  Print("Saída no GAIN");
                 }
              }

            if(deal_comment==start_hour+"_"+"BUY"+exp_name || deal_comment==start_hour+"_"+"SELL"+exp_name)
               gv.Set("glob_entr_tot",gv.Get("glob_entr_tot")+1);

            if(deal_comment=="BUY"+exp_name)

              {
               myposition.SelectByTicket(deal_order);
               cont=0;
               buyprice=0;
               while(buyprice==0 && cont<TENTATIVAS)
                 {
                  buyprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(buyprice==0)
                  buyprice= mysymbol.Ask();

              }
            //--------------------------------------------------

            if(deal_comment==start_hour+"_"+"SELL"+exp_name)
              {
               myposition.SelectByTicket(deal_order);
               cont=0;
               sellprice=0;
               while(sellprice==0 && cont<TENTATIVAS)
                 {
                  sellprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(sellprice== 0)
                  sellprice= mysymbol.Bid();

              }
           }

         lucro_orders=LucroOrdens();
         lucro_orders_mes = LucroOrdensMes();
         lucro_orders_sem = LucroOrdensSemana();
        }
      else
         return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::SegurancaPos(int nsec)
  {
   if(PosicaoAberta())
     {
      for(int i=PositionsTotal()-1; i>=0; i--)
        {
         if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
           {
            if(myposition.StopLoss()==0 && TimeCurrent()-((datetime)gv.Get("last_deal_time"))>=nsec)
              {
               mytrade.PositionClose(myposition.Ticket());
               Print(__FUNCTION__," Fechando Posição Por Segurança");
              }
           }
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

/*   if(TimeCurrent()>D'2019.04.19 23:59:59')
     {
      string erro="Data de Validade Expirou";
      MessageBox(erro);
      Print(erro);
      return(INIT_FAILED);
     }
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO)
     {
      string erro="EA permitido apenas em conta DEMO";
      MessageBox(erro);
      Print(erro);
      return(INIT_FAILED);
     }

*/
//--- Obtemos o número da compilação do programa 
   Print(MQL5InfoString(MQL5_PROGRAM_NAME),"--- MT5 Build #",__MQLBUILD__);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
         return(INIT_FAILED);
      //--- run application 

      ExtDialog.Run();
     }
   return MyEA.OnInit();

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.Destroy(reason);

//--- Código de motivo de desinicialização   
   Print(__FUNCTION__," UninitializeReason() = ",getUninitReasonText(UninitializeReason()));
   MyEA.OnDeinit(reason);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   MyEA.OnTradeTransaction(trans,request,result);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   MyEA.OnTick();
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.OnTick();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  {
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyPanel::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {

   int xx1=INDENT_LEFT;
   int yy1=INDENT_TOP;
   int xx2=x1+BUTTON_WIDTH;
   int yy2=INDENT_TOP+BUTTON_HEIGHT;

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);

//--- create dependent controls 

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Res Mensal: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[0].Color(clrDeepSkyBlue);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"Res Semanal: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[1].Color(clrYellow);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"Res Diário: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[2].Color(clrYellow);

   xx1=(int)(LARGURA_PAINEL-INDENT_RIGHT-0.7*BUTTON_WIDTH-CONTROLS_GAP_X);
   yy1=INDENT_TOP;
   xx2=(int)(xx1+0.7*BUTTON_WIDTH);
   yy2=(int)(yy1+1.5*BUTTON_HEIGHT);

   if(!CreateButton(m_chart_id,m_subwin,BotaoFechar,"ZERAR",xx1,yy1,xx2,yy2))
      return(false);
   BotaoFechar.ColorBackground(clrLime);

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MyPanel::OnTick(void)
  {
   m_label[0].Text("Res Mensal: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2));
   m_label[1].Text("Res Semanal: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2));
   m_label[2].Text("Res Diário: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(MyPanel)
ON_EVENT(ON_CLICK,BotaoFechar,OnClickBotaoFechar)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
void OnClickBotaoFechar()
  {
   MyEA.DeleteALL();
   MyEA.CloseALL();
  }
//+------------------------------------------------------------------+

string getUninitReasonText(int reasonCode)
  {
   string text="";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//--- 
   switch(reasonCode)
     {
      case REASON_ACCOUNT:
         text="Account was changed";break;
      case REASON_CHARTCHANGE:
         text="Symbol or timeframe was changed";break;
      case REASON_CHARTCLOSE:
         text="Chart was closed";break;
      case REASON_PARAMETERS:
         text="Input-parameter was changed";break;
      case REASON_RECOMPILE:
         text="Program "+__FILE__+" was recompiled";break;
      case REASON_REMOVE:
         text="Program "+__FILE__+" was removed from chart";break;
      case REASON_TEMPLATE:
         text="New template was applied to chart";break;
      default:text="Another reason";
     }
//--- 
   return text;
  }
//+------------------------------------------------------------------+
