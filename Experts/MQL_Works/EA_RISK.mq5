//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Risco
  {
   r2=2,//2
   r3=3,//3
   r4=4,//4
   r5=5,//5
   r6=6,//6
   r7=7,//7
   r8=8,//8
   r9=9//9
  };

string keystr="892fb7a2097d7f0183c4c56498a36b00";
datetime data_validade;
string Only_Demo;

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

#include <Bcrypt.mqh>
CBcrypt B;

#include <Expert_Class_New.mqh>
MyPanel ExtDialog;

CLabel            m_label[50];

#define LARGURA_PAINEL 260 // Largura Painel
#define ALTURA_PAINEL 130 // Altura Painel
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
sinput string senha="";//Cole a senha
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO 
input ulong MAGIC_NUMBER=26032019;//Número Mágico
ulong deviation_points=500;//Deviation em Pontos(Padrao)
sinput string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input double Lot=1;//Lote de Entrada
input double _Stop=200;//Stop Loss em Pontos
input double _TakeProfit=300;//Take Profit em Pontos
input Risco risco=r2;//Risco
input ushort seg_fec_ord=10;//Segundos Fechar Ordem Entrada
sinput string Lucro="###---------------------Usar Lucro/Prejuizo para Fechamento-----------------------#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia
sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:04";//Horario Inicial
input string end_hour_ent="17:00";//Horario Final Entradas
input string end_hour="17:20";//Horario Encerramento
input bool daytrade=true;//Fechar Posicao Fim do Horario
sinput string sdias="FILTRO DOS DIAS DA SEMANA";//Dias da Semana
input bool trade0=true;// Operar Domingo
input bool trade1=true;// Operar Segunda
input bool trade2=true;// Operar Terça
input bool trade3=true;// Operar Quarta
input bool trade4=true;// Operar Quinta
input bool trade5=true;// Operar Sexta
input bool trade6=true;// Operar Sábado

sinput string SAumento="############----Aumento de Posição Contra----########";//Aumento Contra
input double pts_saida_aumento=0;//Pontos de Saída Dos Aumentos(0 não sair)
input double Lot_entry1=0;//Lotes Entrada 1 (0 não entrar)
input double pts_entry1=0;//Pontos Entrada 1
input double Lot_entry2=0;//Lotes Entrada 2 (0 não entrar)
input double pts_entry2=0;//Pontos Entrada 2 
input double Lot_entry3=0;//Lotes Entrada 3 (0 não entrar)
input double pts_entry3=0;//Pontos Entrada 3


sinput string STrailing="############---------------Trailing Stop----------########";//Stop Móvel
input bool   Use_TraillingStop=false; //Usar Stop Móvel
input double TraillingStart=50;//Lucro Minimo Em Pontos Iniciar Stop Móvel
input double TraillingDistance=100;// Distancia em Pontos do Stop Loss
input double TraillingStep=10;// Passo para atualizar Stop Loss

sinput string sbreak="########---------Break Even---------------###############";//BreakEven
input    bool              UseBreakEven=false;                          //Usar BreakEven
input    double               BreakEvenPoint1=100;                            //Pontos para BreakEven 1
input    double               ProfitPoint1=10;                             //Pontos de Lucro da Posicao 1
input    double               BreakEvenPoint2=150;                            //Pontos para BreakEven 2
input    double               ProfitPoint2=80;                            //Pontos de Lucro da Posicao 2
input    double               BreakEvenPoint3=200;                            //Pontos para BreakEven 3
input    double               ProfitPoint3=130;                            //Pontos de Lucro da Posicao 3
input    double               BreakEvenPoint4=300;                            //Pontos para BreakEven 4
input    double               ProfitPoint4=230;                            //Pontos de Lucro da Posicao 4
input    double               BreakEvenPoint5         =500;                            //Pontos para BreakEven 5
input    double               ProfitPoint5            =400;                            //Pontos de Lucro da Posicao 5
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class MyRobot: public MyExpert
  {
private:
   CChartObjectHLine HLine_Stop,HLine_Take;
   string            currency_symbol;
   double            sl,tp,price_open_day;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   double            sl_position,tp_position;
   double            Buyprice,Sellprice;
   bool              novabarra;
   bool              buysignal,sellsignal;
   datetime          hora_fin_entrad;
   bool              timeEnt;
   double            preco_medio;
   double            vol_pos,vol_stp,preco_stp;
   int               cand_buy,cand_sell;
   double            PointBreakEven[5];
   double            PointProfit[5];
   bool              pos_open;

public:
   void              MyRobot();
   void             ~MyRobot();
   int               OnInit();
   void              OnDeinit(const int reason);
   void              OnTick();
   void              OnTimer();
   string GetCurrency(){return currency_symbol;};
   bool              TimeDayFilter();
   virtual bool      GetIndValue();
   virtual bool      BuySignal();
   virtual bool      SellSignal();
   void              Entr_Parcial_Buy(const double preco);
   void              Entr_Parcial_Sell(const double preco);
   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);
   virtual void      Atual_vol_Stop_Take();
   void              ContaCandles(const Risco total_cand);
   bool GetPosOpen(){return pos_open;};

  };

MyRobot MyEA;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::MyRobot()
  {
//  preco_par1=0.0;preco_par2=0.0;preco_par3=0.0;
// Exec_parc1=false;Exec_parc2=false;Exec_parc3=false;

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

   tradeOn=true;
   setExpName();
   setSymbol(Symbol());
   setOriginalSymbol(Symbol());
   setMagic(MAGIC_NUMBER);
   setPeriod(periodoRobo);
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

   setNameGvOrder();
   currency_symbol=SymbolInfoString(original_symbol,SYMBOL_CURRENCY_BASE);
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   hora_fin_entrad=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_ent);

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora de Encerramento";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(hora_inicial>=hora_fin_entrad)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final de Entradas";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(hora_fin_entrad>hora_final)
     {
      string erro="Hora Final de Entradas deve ser Menor ou igual que Hora de Encerramento";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   long curChartID=ChartID();

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(ChartID(),CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

   PointBreakEven[0]=BreakEvenPoint1; PointBreakEven[1]=BreakEvenPoint2; PointBreakEven[2]=BreakEvenPoint3;
   PointBreakEven[3]=BreakEvenPoint4; PointBreakEven[4]=BreakEvenPoint5;
   PointProfit[0]=ProfitPoint1; PointProfit[1]=ProfitPoint2; PointProfit[2]=ProfitPoint3;
   PointProfit[3]=ProfitPoint4; PointProfit[4]=ProfitPoint5;


// parametros incorretos desnecessarios na otimizacao

   for(int i=0;i<5;i++)
     {
      if(PointBreakEven[i]<PointProfit[i])
        {
         string erro="Profit do Break Even deve ser menor que o Ponto de Break Even";
         MessageBox(erro);
         Print(erro);
         return false;
        }

     }

   for(int i=0;i<4;i++)
     {
      if(PointBreakEven[i+1]<=PointBreakEven[i])
        {
         string erro="Pontos de Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return false;

        }
     }

   for(int i=0;i<4;i++)
     {
      if(PointProfit[i+1]<=PointProfit[i])
        {
         string erro="Pontos de Profit do Break Even devem estar em ordem crescente";
         MessageBox(erro);
         Print(erro);
         return false;
        }

     }

   return(INIT_SUCCEEDED);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTimer()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   DeletaIndicadores();
   EventKillTimer();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
      tradeOn=true;
      hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
      hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
      hora_fin_entrad=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_ent);

     }

   gv.Set("gv_today_prev",gv.Get("gv_today"));

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }

   if(bid>=ask)return;//Leilão

   if(!TerminalInfoInteger(TERMINAL_CONNECTED))return;



   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   pos_open=PosicaoAberta();
   novabarra=Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo);
   if((!pos_open) &&(!novabarra))return;

   lucro_total=LucroTotal();
   lucro_total_semana=LucroTotalSemana();
   lucro_total_mes=LucroTotalMes();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
     }

   timerOn=true;
   timeEnt=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
      timeEnt=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_fin_entrad && TimeDayFilter();
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!timerOn && daytrade)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
     }

   if(tradeOn && timerOn)
     {// inicio Trade On

      if(OrdemAbertaComent("BUY"+exp_name))
        {
         ulong tick_ordem=GetTickOrdComent("BUY"+exp_name);
         myorder.Select(tick_ordem);
         if(tick_ordem>0 && TimeCurrent()>=myorder.TimeSetup()+seg_fec_ord)
           {
            DeleteOrdersComment("BUY"+exp_name);
            Print("Ordem Pendente Cancelada pelo tempo expirado");
           }
        }

      if(OrdemAbertaComent("SELL"+exp_name))
        {
         ulong tick_ordem=GetTickOrdComent("SELL"+exp_name);
         myorder.Select(tick_ordem);
         if(tick_ordem>0 && TimeCurrent()>=myorder.TimeSetup()+seg_fec_ord)
           {
            DeleteOrdersComment("SELL"+exp_name);
            Print("Ordem Pendente Cancelada pelo tempo expirado");
           }
        }

      if(pos_open)
        {

         Atual_vol_Stop_Take();
         if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);
         if(UseBreakEven)BreakEven(original_symbol,UseBreakEven,PointBreakEven,PointProfit);

         if(myposition.SelectByTicket((ulong)gv.Get(cp_tick)))
           {
            if(myposition.StopLoss()>0)gv.Set("sl_position",myposition.StopLoss());
           }
         if(myposition.SelectByTicket((ulong)gv.Get(vd_tick)))
           {
            if(myposition.StopLoss()>0)gv.Set("sl_position",myposition.StopLoss());
           }

         if(Buy_opened() && Sell_opened())CloseByPosition();
         for(int i=PositionsTotal()-1; i>=0; i--)
           {
            if(myposition.SelectByIndex(i))
              {
               if(myposition.Symbol()!=mysymbol.Name())continue;
               if(myposition.Magic()!=Magic_Number)continue;
               if(myposition.StopLoss()>0)continue;
               if(myposition.Comment()=="TAKE PROFIT")continue;
               if(myposition.Comment()=="BUY"+exp_name||myposition.Comment()=="SELL"+exp_name)continue;
               if(myposition.StopLoss()==0)
                  mytrade.PositionModify(myposition.Ticket(),gv.Get("sl_position"),0);
              }
           }

         for(int i=PositionsTotal()-1; i>=0; i--)
           {
            if(myposition.SelectByIndex(i))
              {
               if(myposition.Symbol()!=mysymbol.Name())continue;
               if(myposition.Magic()!=Magic_Number)continue;
               if(myposition.StopLoss()>0)continue;
               if(myposition.StopLoss()==0)
                  mytrade.PositionClose(myposition.Ticket());
              }
           }

        }//Fim Posição Aberta
      else
        {
         if(OrdersTotal()>0)DeleteOrdersExEntry();
        }
      if(novabarra)
        {
         ContaCandles(risco);
         buysignal=BuySignal() && !Buy_opened();
         sellsignal=SellSignal() && !Sell_opened();

         if(timeEnt)
           {
            if(buysignal)
              {
               DeleteALL();
               CloseALL();
               sl_position=NormalizeDouble(bid-_Stop*ponto,digits);
               tp_position=NormalizeDouble(ask+_TakeProfit*ponto,digits);
               if(mytrade.BuyLimit(Lot,bid,original_symbol,sl_position,tp_position,order_time_type,0,"BUY"+exp_name))
                 {
                  gv.Set("cp_tick",(double)mytrade.ResultOrder());
                 }
               else
                  Print("Erro enviar ordem ",GetLastError());

              }

            if(sellsignal)
              {
               DeleteALL();
               CloseALL();
               sl_position=NormalizeDouble(ask+_Stop*ponto,digits);
               tp_position=NormalizeDouble(bid-_TakeProfit*ponto,digits);
               if(mytrade.SellLimit(Lot,ask,original_symbol,sl_position,tp_position,order_time_type,0,"SELL"+exp_name))
                 {
                  gv.Set("vd_tick",(double)mytrade.ResultOrder());
                 }
               else
                  Print("Erro enviar ordem ",GetLastError());

              }
           }//TimeEnt
        }//End NewBar

     }//End Trade On

  }//Fim Ontick
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::BuySignal()
  {
   bool signal=false;
   signal=cand_buy==(int)risco;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal=false;
   signal=cand_sell==(int)risco;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTradeTransaction(const MqlTradeTransaction &trans,
                                 const MqlTradeRequest &request,
                                 const MqlTradeResult &result)
  {

   if(trans.symbol!=original_symbol)return;
   int TENTATIVAS=10;

//--- get transaction type as enumeration value
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
         deal_entry = (ENUM_DEAL_ENTRY)HistoryDealGetInteger(trans.deal, DEAL_ENTRY);
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

         if(deal_symbol!=original_symbol) return;
         if(deal_magic==Magic_Number)
           {
            gv.Set("last_deal_time",(double)deal_time);

            if(deal_comment=="BUY"+exp_name || deal_comment=="SELL"+exp_name)
               gv.Set("glob_entr_tot",gv.Get("glob_entr_tot")+1);

            if((deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL) && (deal_entry==DEAL_ENTRY_OUT || deal_entry==DEAL_ENTRY_OUT_BY))
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
           } //Fim deal magic

        }
      else
         return;
     }
   if(type==TRADE_TRANSACTION_HISTORY_ADD)
     {
      if(HistoryOrderSelect(trans.order))
        {
         myhistory.Ticket(trans.order);
         if(myhistory.Magic()!=(long)Magic_Number)return;

         if((myhistory.Comment()=="BUY"+exp_name || myhistory.Comment()=="SELL"+exp_name) && trans.order_state==ORDER_STATE_FILLED)
           {
            gv.Set("glob_entr_tot",gv.Get("glob_entr_tot")+1);
           }

         if(myhistory.Comment()=="BUY"+exp_name && trans.order_state==ORDER_STATE_FILLED)
           {
            myposition.SelectByTicket(trans.order);
            int cont = 0;
            Buyprice = 0;
            while(Buyprice==0 && cont<TENTATIVAS)
              {
               Buyprice=myposition.PriceOpen();
               cont+=1;
              }
            if(Buyprice== 0)
               Buyprice= mysymbol.Ask();

            sl_position = NormalizeDouble(Buyprice - _Stop * ponto, digits);
            tp_position = NormalizeDouble(Buyprice + _TakeProfit * ponto, digits);
            if(mytrade.SellLimit(Lot,tp_position,original_symbol,0,0,order_time_type,0,"TAKE PROFIT"))
              {
               gv.Set("tp_vd_tick",(double)mytrade.ResultOrder());
               mytrade.PositionModify(trans.order,sl_position,0);
              }
            else
               Print("Erro enviar ordem: ",GetLastError());

            Entr_Parcial_Buy(Buyprice);
           }

         if(myhistory.Comment()=="SELL"+exp_name && trans.order_state==ORDER_STATE_FILLED)
           {
            myposition.SelectByTicket(trans.order);
            Sellprice= myposition.PriceOpen();
            int cont = 0;
            Sellprice= 0;
            while(Sellprice==0 && cont<TENTATIVAS)
              {
               Sellprice=myposition.PriceOpen();
               cont+=1;
              }
            if(Sellprice== 0)
               Sellprice= mysymbol.Bid();
            sl_position = NormalizeDouble(Sellprice + _Stop * ponto, digits);
            tp_position = NormalizeDouble(Sellprice - _TakeProfit * ponto, digits);
            if(mytrade.BuyLimit(Lot,tp_position,original_symbol,0,0,order_time_type,0,"TAKE PROFIT"))
              {
               gv.Set("tp_cp_tick",(double)mytrade.ResultOrder());
               mytrade.PositionModify(trans.order,sl_position,0);
              }
            else
               Print("Erro enviar ordem: ",GetLastError());

            Entr_Parcial_Sell(Sellprice);

           }

         if(StringFind(myhistory.Comment(),"Entrada Parcial")>=0 && trans.order_state==ORDER_STATE_FILLED)
           {
            if(Buy_opened())
              {
               sl_position=gv.Get("sl_position");
               myposition.SelectByTicket((ulong)gv.Get("cp_tick"));
               if(myposition.StopLoss()==0)
                  mytrade.PositionModify(myposition.Ticket(),sl_position,0);

               if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
                 {
                  for(int i=PositionsTotal()-1; i>=0; i--)
                    {
                     if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_BUY && myposition.Symbol()==mysymbol.Name())
                       {
                        if(myposition.StopLoss()==0)
                           mytrade.PositionModify(myposition.Ticket(),sl_position,0);
                       }
                    }
                 }
               if(pts_saida_aumento>0)
                  mytrade.SellLimit(myhistory.VolumeInitial(),NormalizeDouble(myhistory.PriceOpen()+pts_saida_aumento*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Aumento");
              }

            if(Sell_opened())
              {
               sl_position=gv.Get("sl_position");
               myposition.SelectByTicket((ulong)gv.Get("vd_tick"));
               if(myposition.StopLoss()==0)
                  mytrade.PositionModify(myposition.Ticket(),sl_position,0);

               if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
                 {
                  for(int i=PositionsTotal()-1; i>=0; i--)
                    {
                     if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.PositionType()==POSITION_TYPE_SELL && myposition.Symbol()==mysymbol.Name())
                       {
                        if(myposition.StopLoss()==0)
                           mytrade.PositionModify(myposition.Ticket(),sl_position,0);
                       }
                    }
                 }

               if(pts_saida_aumento>0)
                  mytrade.BuyLimit(myhistory.VolumeInitial(),NormalizeDouble(myhistory.PriceOpen()-pts_saida_aumento*ponto,digits),original_symbol,0,0,order_time_type,0,"Saída Aumento");
              }
           }

         lucro_orders=LucroOrdens();
         lucro_orders_mes = LucroOrdensMes();
         lucro_orders_sem = LucroOrdensSemana();
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MyRobot::Entr_Parcial_Buy(const double preco)
  {
   if(Lot_entry1>0 && pts_entry1>0) mytrade.BuyLimit(Lot_entry1,NormalizeDouble(preco-pts_entry1*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 1");
   if(Lot_entry2>0 && pts_entry2>0) mytrade.BuyLimit(Lot_entry2,NormalizeDouble(preco-pts_entry2*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 2");
   if(Lot_entry3>0 && pts_entry3>0) mytrade.BuyLimit(Lot_entry3,NormalizeDouble(preco-pts_entry3*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 3");
  }
//+------------------------------------------------------------------+
void MyRobot::Entr_Parcial_Sell(const double preco)
  {
   if(Lot_entry1>0 && pts_entry1>0) mytrade.SellLimit(Lot_entry1,NormalizeDouble(preco+pts_entry1*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 1");
   if(Lot_entry2>0 && pts_entry2>0) mytrade.SellLimit(Lot_entry2,NormalizeDouble(preco+pts_entry2*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 2");
   if(Lot_entry3>0 && pts_entry3>0) mytrade.SellLimit(Lot_entry3,NormalizeDouble(preco+pts_entry3*ponto,digits),original_symbol,0,0,order_time_type,0,"Entrada Parcial 3");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::ContaCandles(const Risco total_cand)
  {
   cand_buy=0;
   cand_sell=0;
   int total=(int)total_cand;

   for(int i=total;i>=1;i--)
     {
      if(iTime(original_symbol,periodoRobo,i)<iTime(original_symbol,PERIOD_D1,0))return;
      if(iClose(original_symbol,periodoRobo,i)>iOpen(original_symbol,periodoRobo,i))
         cand_buy++;
      if(iClose(original_symbol,periodoRobo,i)<iOpen(original_symbol,periodoRobo,i))
         cand_sell++;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::Atual_vol_Stop_Take()
  {
   double vol_ent_contra,vol_ent_fav,vol_parc;
   vol_ent_contra=VolumeOrdensCmt("Saída Aumento");
   vol_ent_fav=VolumeOrdensCmt("Saída Favor");
   vol_parc=VolumeOrdensCmt("PARCIAL 1")+VolumeOrdensCmt("PARCIAL 2")+VolumeOrdensCmt("PARCIAL 3");

   if(Buy_opened())
     {
      if(myposition.SelectByTicket((ulong)gv.Get("cp_tick")) && myorder.Select((ulong)gv.Get("tp_vd_tick")))
        {
         vol_pos = VolPosType(POSITION_TYPE_BUY)-vol_ent_contra-vol_ent_fav-vol_parc;
         vol_stp = myorder.VolumeInitial();
         // preco_stp=myorder.PriceOpen();
         preco_stp=NormalizeDouble(PrecoMedio(POSITION_TYPE_BUY)+_TakeProfit*ponto,digits);

         if(vol_pos!=vol_stp)
           {
            mytrade.OrderDelete((ulong)gv.Get("tp_vd_tick"));
            mytrade.SellLimit(vol_pos, preco_stp, original_symbol, 0, 0, order_time_type, 0, "TAKE PROFIT");
            gv.Set("tp_vd_tick",(double)mytrade.ResultOrder());
           }
        }
     }
   if(Sell_opened())
     {

      if(myposition.SelectByTicket((ulong)gv.Get("vd_tick")) && myorder.Select((ulong)gv.Get("tp_cp_tick")))
        {
         vol_pos = VolPosType(POSITION_TYPE_SELL)-vol_ent_contra-vol_ent_fav-vol_parc;
         vol_stp = myorder.VolumeInitial();
         //  preco_stp=myorder.PriceOpen();
         preco_stp=NormalizeDouble(PrecoMedio(POSITION_TYPE_SELL)-_TakeProfit*ponto,digits);

         if(vol_pos!=vol_stp)
           {
            mytrade.OrderDelete((ulong)gv.Get("tp_cp_tick"));
            mytrade.BuyLimit(vol_pos, preco_stp, original_symbol, 0, 0, order_time_type, 0, "TAKE PROFIT");
            gv.Set("tp_cp_tick",(double)mytrade.ResultOrder());
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(!MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_TESTER))
     {
      if(!ValidarSenha(senha))
         return INIT_FAILED;
     }
   if(!ChartSetInteger(ChartID(),CHART_SHIFT,0,50))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }

//--- Obtemos o número da compilação do programa 
   Print(MQL5InfoString(MQL5_PROGRAM_NAME),"--- MT5 Build #",__MQLBUILD__);
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   MyEA.OnTimer();
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
   if(!MQLInfoInteger(MQL_OPTIMIZATION))
      if(MyEA.GetPosOpen())ExtDialog.OnTick();
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,// event ID   
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

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"RESULTADO MENSAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[0].Color(clrAqua);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"RESULTADO SEMANAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[1].Color(clrAqua);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;
   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"RESULTADO DIÁRIO: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[2].Color(clrAqua);

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyPanel::OnTick(void)
  {
   m_label[0].Text("RESULTADO MENSAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.GetLucroMes(),2));
   m_label[1].Text("RESULTADO SEMANAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.GetLucroSem(),2));
   m_label[2].Text("RESULTADO DIÁRIO: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.GetLucro(),2));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(MyPanel)

EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+

string getUninitReasonText(int reasonCode)
  {
   string text="";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
bool ValidarSenha(string password)
  {
   int trim;
   trim=StringTrimLeft(password);
   trim=StringTrimRight(password);
   ulong conta_usuario;
   B.Init(keystr);
   string decoded=B.Decrypt(password);
   string to_split = decoded; // Um string para dividir em substrings
   string sep = "_";          // Um separador como um caractere
   ushort u_sep;              // O código do caractere separador
   string result[];           // Um array para obter strings
//--- Obtém o código do separador
   u_sep=StringGetCharacter(sep,0);
//--- Divide a string em substrings
   int k=StringSplit(to_split,u_sep,result);
//--- Exibe um comentário
//--- Agora imprime todos os resultados obtidos
   if(k>0)
     {
      conta_usuario = StringToInteger(result[0]);
      data_validade = StringToTime(result[1]);
      Only_Demo=result[2];

      if(TimeCurrent()>data_validade)
        {
         string erro="Data de Validade Expirada";
         MessageBox(erro);
         Print(erro);
         return false;
        }
      if(AccountInfoInteger(ACCOUNT_LOGIN)!=conta_usuario)
        {
         string erro="Usuário Não Permitido";
         MessageBox(erro);
         Print(erro);
         return false;
        }

      if(Only_Demo=="Sim" && (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO)
        {
         string erro="EA permitido apenas em conta DEMO";
         MessageBox(erro);
         Print(erro);
         return false;
        }

     }
   else
      return false;
   return true;
  }
//+------------------------------------------------------------------+
