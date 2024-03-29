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
enum TipoEnt
  {
   TVar,//Variação
   TAb         //Abertura
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_BOOLEANO
  {
   BOOL_NO,//Não
   BOOL_YES//Sim
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string keystr="892fb7a2097d7f0183c4c56498a36b00";
datetime data_validade;
string Only_Demo;
#include <Bcrypt.mqh>
CBcrypt B;
string _erro;

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

#define LARGURA_PAINEL 260 // Largura Painel
#define ALTURA_PAINEL 130 // Altura Painel
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
sinput string senha="";//Cole a senha
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong MAGIC_NUMBER=26032019;//Número Mágico
ulong deviation_points=500;//Deviation em Pontos(Padrao)
sinput string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input double Divisor=3000;//Divisor
input double Lot=1;//Tamanho do Lote
input TipoEnt tipo_ent=TVar;//Tipo da Entrada
input ushort num_ordens=5;//Número de Ordens Grid Anterior
input double dist_ordens=2.0;//Distância Entre Ordens Grid Anterior
input double TP_Ordens=20.0;//Take Profit Ordens
input double SL_Ordens=20.0;//Stop Loss  Ordens

sinput string SVarsPos="############-------------------------Variações Positivas---------------------------########";//Variações Positivas
input ENUM_BOOLEANO UsarPos=BOOL_YES;//Usar Variações Positivas
input double Var1=1.0;
input double Var2=1.25;
input double Var3=1.5;
input double Var4=2.0;
input double Var5=2.25;
sinput string SVarsNeg="############-------------------------Variações Negativas---------------------------########";//Variações Negativas
input ENUM_BOOLEANO UsarNeg=BOOL_YES;//Usar Variações Negativas
input double Var6=-1.0;
input double Var7=-1.25;
input double Var8=-1.5;
input double Var9=-2.0;
input double Var10=-2.25;

sinput string SAbs="############-------------------------Variações Abertura---------------------------########";//Variações Abertura
input ENUM_BOOLEANO UsarAb=BOOL_YES;//Usar Variações Abertura
input double Ab1=1.0;//Ab%1 >0 Sell
input double Ab2=-1.25;//Ab%2 <0 Buy

sinput string Lucro="###---------------------Usar Lucro/Prejuizo para Fechamento-----------------------#####";    //Lucro
input ENUM_BOOLEANO UsarLucro=BOOL_YES;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia

sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário
input ENUM_BOOLEANO UseTimer=BOOL_YES;//Usar Filtro de Horário: True/False
input string start_hour="9:04";//Horario Inicial
input string end_hour_ent="17:00";//Horario Final Entradas
input string end_hour="17:20";//Horario Encerramento
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
   CChartObjectHLine HLineSL_Ordens,HLine_Take;
   string            currency_symbol;
   double            sl,tp,price_open_day;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   bool              novabarra;
   string            mensagens;
   double            sl_position,tp_position;
   double            Buyprice,Sellprice;
   bool              buysignal,sellsignal;
   datetime          hora_fin_entrad;
   bool              timeEnt;
   double            preco_medio;
   double            vol_pos,vol_stp,preco_stp;
   bool              pos_open;
   double            prices_VarPos[5],prices_VarNeg[5];
   double            price_gain,price_Stop;
   string            tp_comment;
   ushort            nticks_stop;
   double            price_open;
public:
   void              MyRobot();
   void             ~MyRobot();
   int               OnInit();
   void              OnDeinit(const int reason);
   void              OnTick();
   void              OnTimer();
   string GetCurrency(){return SymbolInfoString(original_symbol,SYMBOL_CURRENCY_BASE);}
   bool              TimeDayFilter();
   virtual bool      GetIndValue();
   virtual bool      BuySignal();
   virtual bool      SellSignal();
   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);
   void              EnviaBuyLimit(const double price_limit);
   void              EnviaSellLimit(const double price_limit);
   void              Entr_Parcial_Buy(const double preco);
   void              Entr_Parcial_Sell(const double preco);
   void              CloseTPByPosition();
   void              DeleteOrdersWithComment(const string comm);

  };

//bool MyRobot::partialSellMidd=false;
//bool MyRobot::partialBuyMidd=false;

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
   setOriginalSymbol(_Symbol);
   setMagic(MAGIC_NUMBER);
   setPeriod(periodoRobo);
   if(SymbolInfoInteger(original_symbol,SYMBOL_EXPIRATION_MODE)==2)order_time_type=1;
   else order_time_type=0;

   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(MAGIC_NUMBER);
   mytrade.SetDeviationInPoints(deviation_points);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
// mytrade.SetTypeFillingBySymbol(original_symbol);
   mytrade.SetTypeFilling(ORDER_FILLING_RETURN);
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

   if(find_dol>=0 || find_wdo>=0)
      nticks_stop=4;
   else
      nticks_stop=20;

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

   if(UsarPos)
     {
      if(Var1<=0 || Var2<=0 || Var3<=0 || Var4<=0 || Var5<=0)
        {
         string erro="Variações Positivas devem ser >0";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);
        }

      if(Var1>=Var2 || Var2>=Var3 || Var3>=Var4 || Var4>=Var5)
        {
         string erro="Variações Positivas devem estar em Ordem Crescente";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);
        }

     }

   if(UsarNeg)
     {
      if(Var6>=0 || Var7>=0 || Var8>=0 || Var9>=0 || Var10>=0)
        {
         string erro="Variações Negativas devem ser <0";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);
        }

      if(Var6<=Var7 || Var7<=Var8 || Var8<=Var9 || Var9<=Var10)
        {
         string erro="Variações Negativas devem estar em Ordem Decrescente";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);
        }

     }

   if(UsarAb)
     {
      if(Ab1<=0 || Ab2>=0)
        {
         string erro="Variações De Abertura estão erradas. Tem que ser: Ab1>0 e Ab2<0";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);

        }
     }

   long curChartID=ChartID();

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(ChartID(),CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

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

   static bool _first_tick=true;
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
      _first_tick=true;

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

   lucro_total=LucroTotal();
   lucro_total_semana=LucroTotalSemana();
   lucro_total_mes=LucroTotalMes();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UsarLucro==BOOL_YES && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
      tradeOn=false;
     }

   timerOn=true;
   timeEnt=true;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer==BOOL_YES)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
      timeEnt=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_fin_entrad && TimeDayFilter();
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!timerOn)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
     }

   if((!tradeOn) || (!timerOn))
     {
      if(!tradeOn)
        {
         if(OrdersTotal()>0)DeleteALL();
         if(PositionsTotal()>0)CloseALL();
        }
      return;
     }

   if(!PosicaoAberta())
     {
      if(OrdersTotal()>0)
         DeleteOrdersExEntry();
     }

   if(tradeOn && timerOn)
     {// inicio Trade On

      if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened()) CloseByPosition();

      if(timeEnt)
        {

         if(PosicaoAberta())
           {
            myposition.Select(original_symbol);
            price_open=myposition.PriceOpen();
            if(Buy_opened())
              {
               sl_position=price_open-SL_Ordens*ponto-nticks_stop*ticksize;
               tp_position=price_open+TP_Ordens*ponto+nticks_stop*ticksize;
               if((SL_Ordens>0 && ask<=sl_position) || (TP_Ordens>0 && bid>=tp_position))
                 {
                  DeleteOrdersExEntry();
                  CloseALL();
                 }
              }

            if(Sell_opened())
              {
               sl_position=price_open+SL_Ordens*ponto+nticks_stop*ticksize;
               tp_position=price_open-TP_Ordens*ponto-nticks_stop*ticksize;
               if((SL_Ordens>0 && bid>=sl_position) || (TP_Ordens>0 && ask<=tp_position))
                 {
                  DeleteOrdersExEntry();
                  CloseALL();
                 }
              }

           }

         if(_first_tick)
           {
            _first_tick=false;

            prices_VarPos[0]=mysymbol.NormalizePrice(MathRound(((1+0.01*Var1)*Divisor)/ticksize)*ticksize);
            prices_VarPos[1]=mysymbol.NormalizePrice(MathRound(((1+0.01*Var2)*Divisor)/ticksize)*ticksize);
            prices_VarPos[2]=mysymbol.NormalizePrice(MathRound(((1+0.01*Var3)*Divisor)/ticksize)*ticksize);
            prices_VarPos[3]=mysymbol.NormalizePrice(MathRound(((1+0.01*Var4)*Divisor)/ticksize)*ticksize);
            prices_VarPos[4]=mysymbol.NormalizePrice(MathRound(((1+0.01*Var5)*Divisor)/ticksize)*ticksize);

            prices_VarNeg[0]=mysymbol.NormalizePrice(MathRound(((1+0.01*Var6)*Divisor)/ticksize)*ticksize);
            prices_VarNeg[1]=mysymbol.NormalizePrice(MathRound(((1+0.01*Var7)*Divisor)/ticksize)*ticksize);
            prices_VarNeg[2]=mysymbol.NormalizePrice(MathRound(((1+0.01*Var8)*Divisor)/ticksize)*ticksize);
            prices_VarNeg[3]=mysymbol.NormalizePrice(MathRound(((1+0.01*Var9)*Divisor)/ticksize)*ticksize);
            prices_VarNeg[4]=mysymbol.NormalizePrice(MathRound(((1+0.01*Var10)*Divisor)/ticksize)*ticksize);


            if(tipo_ent==TVar)
              {

               if(UsarPos)
                 {
                  if(ask<prices_VarPos[0])
                    {
                     for(int i=0;i<5;i++) EnviaSellLimit(prices_VarPos[i]);
                    }

                  if(ask>=prices_VarPos[0])
                    {
                     for(int i=2;i<5;i++) EnviaSellLimit(prices_VarPos[i]);
                    }
                 }
               if(UsarNeg)
                 {
                  if(bid>prices_VarNeg[0])
                    {
                     for(int i=0;i<5;i++) EnviaBuyLimit(prices_VarNeg[i]);
                    }

                  if(bid<=prices_VarNeg[0])
                    {
                     for(int i=2;i<5;i++) EnviaBuyLimit(prices_VarNeg[i]);
                    }
                 }
              }
            if(tipo_ent==TAb)
              {
               price_open_day=iOpen(original_symbol,PERIOD_D1,0);
               double price_AbBuy=mysymbol.NormalizePrice(MathRound(((1+0.01*Ab2)*price_open_day)/ticksize)*ticksize);
               double price_AbSell=mysymbol.NormalizePrice(MathRound(((1+0.01*Ab1)*price_open_day)/ticksize)*ticksize);
               if(UsarAb)
                 {
                  EnviaBuyLimit(price_AbBuy);
                  EnviaSellLimit(price_AbSell);
                 }
              }

           }//Fim first tick

        }//Fim TimeEnt

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
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal=false;

   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTradeTransaction(const MqlTradeTransaction &trans,
                                 const MqlTradeRequest &request,
                                 const MqlTradeResult &result)
  {
   if(trans.symbol!=original_symbol)
      return;

   int TENTATIVAS=10;

//--- get transaction type as enumeration value
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history

//--- if a request was sent
   if(trans.type==TRADE_TRANSACTION_REQUEST)
     {
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(type==TRADE_TRANSACTION_ORDER_UPDATE)
     {
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(type==TRADE_TRANSACTION_HISTORY_UPDATE)
     {
     }
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

         if(deal_symbol!=_Symbol)
            return;
         if(deal_magic==Magic_Number)
           {
            if(deal_comment=="BUY"+exp_name && (deal_entry==DEAL_ENTRY_IN || deal_entry==DEAL_ENTRY_INOUT))

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
                  Buyprice= SymbolInfoDouble(original_symbol,SYMBOL_ASK);
               if(SL_Ordens>0)
                 {
                  sl_position=NormalizeDouble(Buyprice-SL_Ordens,digits);
                  if(sl_position<SymbolInfoDouble(original_symbol,SYMBOL_BID))
                    {
                     if(!mytrade.SellStop(Lot,sl_position,original_symbol,0,0,order_time_type,0,"STOP_"+IntegerToString(trans.order)))
                       {
                        Print("Erro enviar ordem Stop: ",GetLastError());
                        if(!mytrade.Sell(Lot,mysymbol.Name(),0,0,0,"STOP_"+IntegerToString(trans.order)))
                           Print("Erro enviar Fechar Ordem: ",GetLastError());

                       }
                    }
                  else
                    {
                     if(!mytrade.Sell(Lot,mysymbol.Name(),0,0,0,"STOP_"+IntegerToString(trans.order)))
                        Print("Erro enviar Fechar Ordem: ",GetLastError());
                    }
                 }
               if(TP_Ordens>0)
                 {
                  tp_position=NormalizeDouble(Buyprice+TP_Ordens,digits);
                  if(mytrade.SellLimit(Lot,tp_position,original_symbol,0,0,order_time_type,0,"GAIN_"+IntegerToString(trans.order)))
                    {
                     gv.Set("tp_vd_tick",(double)mytrade.ResultOrder());
                    }
                  else
                     Print("Erro enviar ordem Gain: ",GetLastError());
                 }
               Entr_Parcial_Buy(Buyprice);

              }
            //--------------------------------------------------

            if(deal_comment=="SELL"+exp_name && (deal_entry==DEAL_ENTRY_IN || deal_entry==DEAL_ENTRY_INOUT))
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
               if(Sellprice==0)
                  Sellprice=SymbolInfoDouble(original_symbol,SYMBOL_BID);
               sl_position=NormalizeDouble(Sellprice+SL_Ordens,digits);
               if(sl_position>SymbolInfoDouble(original_symbol,SYMBOL_ASK))
                 {
                  if(!mytrade.BuyStop(Lot,sl_position,original_symbol,0,0,order_time_type,0,"STOP_"+IntegerToString(trans.order)))
                    {
                     Print("Erro enviar ordem Stop: ",GetLastError());
                     if(!mytrade.Buy(Lot,mysymbol.Name(),0,0,0,"STOP_"+IntegerToString(trans.order)))
                        Print("Erro enviar Fechar Ordem: ",GetLastError());
                    }
                 }
               else
                 {
                  if(!mytrade.Buy(Lot,mysymbol.Name(),0,0,0,"STOP_"+IntegerToString(trans.order)))
                     Print("Erro enviar Fechar Ordem: ",GetLastError());
                 }

               tp_position=NormalizeDouble(Sellprice-TP_Ordens,digits);
               if(mytrade.BuyLimit(Lot,tp_position,original_symbol,0,0,order_time_type,0,"GAIN_"+IntegerToString(trans.order)))
                 {
                  gv.Set("tp_cp_tick",(double)mytrade.ResultOrder());
                 }
               else
                  Print("Erro enviar ordem Gain: ",GetLastError());

               Entr_Parcial_Sell(Sellprice);

              }

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

            lucro_orders=LucroOrdens();

/*            lucro_orders=LucroOrdens();
            lucro_orders_mes = LucroOrdensMes();
            lucro_orders_sem = LucroOrdensSemana();*/

           } //Fim deal magic
        }
      else
         return;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(type==TRADE_TRANSACTION_HISTORY_ADD)
     {

      if(HistoryOrderSelect(trans.order))
        {
         myhistory.Ticket(trans.order);
         if(myhistory.Magic()!=(ulong)Magic_Number)
            return;
         if(myhistory.Symbol()!=mysymbol.Name())return;
         if((myhistory.Comment()=="BUY"+exp_name || myhistory.Comment()=="SELL"+exp_name) && trans.order_state==ORDER_STATE_FILLED)
           {
            //   gv.Set("glob_entr_tot",gv.Get("glob_entr_tot")+1);
           }

         if((StringFind(myhistory.Comment(),"GAIN")==0 || StringFind(myhistory.Comment(),"STOP")==0) && trans.order_state==ORDER_STATE_FILLED)
           {
            if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)CloseTPByPosition();
            tradeOn=false;
           }
         if(StringFind(myhistory.Comment(),"Entrada Parcial")>=0 && trans.order_state==ORDER_STATE_FILLED)
           {
            if(Buy_opened())
              {
               if(TP_Ordens>0)
                 {
                  price_gain=myhistory.PriceOpen();
                  int cont=0;
                  while(price_gain==0 && cont<TENTATIVAS)
                    {
                     price_gain=myhistory.PriceOpen();
                     cont+=1;
                    }
                  if(price_gain==0)
                     price_gain=SymbolInfoDouble(original_symbol,SYMBOL_ASK);

                  price_gain=MathRound(price_gain/ticksize)*ticksize;
                  price_gain=NormalizeDouble(price_gain+TP_Ordens*ponto,digits);
                  if(mytrade.SellLimit(myhistory.VolumeInitial(),price_gain,original_symbol,0,0,order_time_type,0,"TP_"+IntegerToString(trans.order)))
                    {
                     Print("Gain Parcial Enviado");
                    }
                  else Print("Erro enviar Gain Parcial: ",GetLastError());
                 }

               price_Stop=myhistory.PriceOpen();
               int cont=0;
               while(price_Stop==0 && cont<TENTATIVAS)
                 {
                  price_Stop=myhistory.PriceOpen();
                  cont+=1;
                 }
               if(price_Stop==0)
                  price_Stop=SymbolInfoDouble(original_symbol,SYMBOL_ASK);

               price_Stop=MathRound(price_Stop/ticksize)*ticksize;
               sl_position=NormalizeDouble(price_Stop-SL_Ordens*ponto,digits);
               if(sl_position<SymbolInfoDouble(original_symbol,SYMBOL_BID))
                 {
                  if(!mytrade.SellStop(Lot,sl_position,original_symbol,0,0,order_time_type,0,"SL_"+IntegerToString(trans.order)))
                    {
                     Print("Erro enviar ordem Stop: ",GetLastError());
                     if(!mytrade.Sell(Lot,mysymbol.Name(),0,0,0,"SL_"+IntegerToString(trans.order)))
                        Print("Erro enviar Fechar Ordem: ",GetLastError());

                    }
                 }
               else
                 {
                  if(!mytrade.Sell(Lot,mysymbol.Name(),0,0,0,"SL_"+IntegerToString(trans.order)))
                     Print("Erro enviar Fechar Ordem: ",GetLastError());
                 }

              }

            if(Sell_opened())
              {
               if(TP_Ordens>0)
                 {

                  price_gain=myhistory.PriceOpen();
                  int cont=0;
                  while(price_gain==0 && cont<TENTATIVAS)
                    {
                     price_gain=myhistory.PriceOpen();
                     cont+=1;
                    }
                  if(price_gain==0)
                     price_gain=SymbolInfoDouble(original_symbol,SYMBOL_BID);

                  price_gain=MathRound(price_gain/ticksize)*ticksize;
                  price_gain=NormalizeDouble(price_gain-TP_Ordens*ponto,digits);

                  if(mytrade.BuyLimit(myhistory.VolumeInitial(),price_gain,original_symbol,0,0,order_time_type,0,"TP_"+IntegerToString(trans.order)))
                    {
                     Print("Gain Parcial Enviado");
                    }
                  else Print("Erro enviar Gain Parcial: ",GetLastError());
                 }

               price_Stop=myhistory.PriceOpen();
               int cont=0;
               while(price_Stop==0 && cont<TENTATIVAS)
                 {
                  price_Stop=myhistory.PriceOpen();
                  cont+=1;
                 }
               if(price_Stop==0)
                  price_Stop=SymbolInfoDouble(original_symbol,SYMBOL_BID);
               price_Stop=MathRound(price_Stop/ticksize)*ticksize;
               sl_position=NormalizeDouble(price_Stop+SL_Ordens*ponto,digits);
               if(sl_position>SymbolInfoDouble(original_symbol,SYMBOL_ASK))
                 {
                  if(!mytrade.BuyStop(Lot,sl_position,original_symbol,0,0,order_time_type,0,"SL_"+IntegerToString(trans.order)))
                    {
                     Print("Erro enviar ordem Stop: ",GetLastError());
                     if(!mytrade.Buy(Lot,mysymbol.Name(),0,0,0,"SL_"+IntegerToString(trans.order)))
                        Print("Erro enviar Fechar Ordem: ",GetLastError());

                    }
                 }
               else
                 {
                  if(!mytrade.Buy(Lot,mysymbol.Name(),0,0,0,"SL_"+IntegerToString(trans.order)))
                     Print("Erro enviar Fechar Ordem: ",GetLastError());
                 }

              }

           }

         if((StringFind(myhistory.Comment(),"TP_")==0 || StringFind(myhistory.Comment(),"SL")==0) && trans.order_state==ORDER_STATE_FILLED)
           {
            if(StringFind(myhistory.Comment(),"TP_")==0)DeleteOrdersComment("SL_"+StringSubstr(myhistory.Comment(),3));
            if(StringFind(myhistory.Comment(),"SL_")==0)DeleteOrdersComment("TP_"+StringSubstr(myhistory.Comment(),3));

            DeleteOrdersWithComment("Entrada Parcial");
            if(Buy_opened())
              {
               preco_medio=PrecoMedio(POSITION_TYPE_BUY);
               Entr_Parcial_Buy(preco_medio);
              }

            if(Sell_opened())
              {
               preco_medio=PrecoMedio(POSITION_TYPE_SELL);
               Entr_Parcial_Sell(preco_medio);
              }

           }

        }//Fim History Select
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

   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      _erro="Para usar em conta HEDGE contate o desenvolvedor";
      Print(_erro);
      Alert(_erro);
      MessageBox(_erro);
      return INIT_FAILED;

     }

   if(!MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_TESTER))
     {
      if(!ValidarSenha(senha))
        {
         _erro="Licença Inválida";
         Print(_erro);
         Alert(_erro);
         MessageBox(_erro);
         return INIT_FAILED;
        }
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
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   MyEA.OnTradeTransaction(trans,request,result);
  }
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
      ExtDialog.OnTick();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
void MyPanel::OnTick(void)
  {
   m_label[0].Text("RESULTADO MENSAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.GetLucroMes(),2));
   m_label[1].Text("RESULTADO SEMANAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.GetLucroSem(),2));
   m_label[2].Text("RESULTADO DIÁRIO: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.GetLucro(),2));
  }
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
void MyRobot::EnviaBuyLimit(const double price_limit)
  {
   if(mytrade.BuyLimit(Lot,price_limit,mysymbol.Name(),0,0,order_time_type,0,"BUY"+exp_name))
     {
      if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
        {
         mensagens=__FUNCSIG__+" Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
         Print(mensagens);
        }
      else
        {
         mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
         Print(mensagens);
        }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::EnviaSellLimit(const double price_limit)
  {
   if(mytrade.SellLimit(Lot,price_limit,mysymbol.Name(),0,0,order_time_type,0,"SELL"+exp_name))
     {
      if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
        {
         mensagens=__FUNCSIG__+" Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
         Print(mensagens);
        }
      else
        {
         mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
         Print(mensagens);
        }
     }

  }
//+------------------------------------------------------------------+
void MyRobot::Entr_Parcial_Buy(const double preco)
  {
   if(num_ordens<=0)return;
   double preco_ent;
   for(int i=0;i<num_ordens;i++)
     {
      preco_ent=preco-(i+1)*dist_ordens*ponto;
      preco_ent=NormalizeDouble(preco_ent,digits);
      mytrade.BuyLimit(Lot,preco_ent,original_symbol,0,0,order_time_type,0,"Entrada Parcial "+IntegerToString(i+1));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void MyRobot::Entr_Parcial_Sell(const double preco)
  {
   if(num_ordens<=0)return;
   double preco_ent;
   for(int i=0;i<num_ordens;i++)
     {
      preco_ent=preco+(i+1)*dist_ordens*ponto;
      preco_ent=NormalizeDouble(preco_ent,digits);
      mytrade.SellLimit(Lot,preco_ent,original_symbol,0,0,order_time_type,0,"Entrada Parcial "+IntegerToString(i+1));
     }
  }
//+------------------------------------------------------------------+
void MyRobot::CloseTPByPosition()
  {
   int total=PositionsTotal();
   for(int i=total-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i))
        {
         ulong ticket=myposition.Ticket();
         if(ticket<=0 || myposition.Symbol()!=original_symbol)
            continue;
         //---
         if(myposition.Magic()!=Magic_Number)
            continue;

         tp_comment=myposition.Comment();
         if(StringFind(tp_comment,"TP")==0 || StringFind(tp_comment,"GAIN")==0 || StringFind(tp_comment,"STOP")==0 || StringFind(tp_comment,"SL")==0)
           {
            int start=StringFind(tp_comment,"_");
            if(start>0)
              {
               long ticket_by=StringToInteger(StringSubstr(tp_comment,start+1));
               //      ENUM_POSITION_TYPE type=myposition.PositionType();
               //    if(ticket_by>0 && myposition.SelectByTicket(ticket_by) && type!=myposition.PositionType())
               if(ticket_by>0)
                 {
                  if(mytrade.PositionCloseBy(ticket,ticket_by))
                     continue;
                 }
              }
           }
        }
     }

  }
//+------------------------------------------------------------------+
void MyRobot::DeleteOrdersWithComment(const string comm)
  {
   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
         if(myorder.Symbol()==mysymbol.Name() && myorder.Magic()==Magic_Number)
            if(StringFind(myorder.Comment(),comm)>=0)
               mytrade.OrderDelete(myorder.Ticket());
  }
//+------------------------------------------------------------------+


bool ValidarSenha(string password)
  {
   if(password=="")return false;
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
