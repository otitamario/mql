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
enum TipoTake
  {
   TkPontos,// TP - Pontos
   TkAmplitude // TP - Porcentagem da Amplitude Martelo
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum UsoFiltro
  {
   Sim,//Sim
   Nao//Não
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <statistics.mqh>
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

#define LARGURA_PAINEL 360 // Largura Painel
#define ALTURA_PAINEL 200 // Altura Painel




// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong MAGIC_NUMBER=26032019;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
sinput string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input double Lot=100;//Lote Entrada
input TipoTake tipotake=TkAmplitude;// Tipo de Take Profit
input double _TakeProfit=30;//Take Profit em Pontos
input double _TakeProfitvezes=100;//TP Procentagem da Amplitude

input double _distancia=10;// Distância Fechamento Candle para Alligator
sinput string Sind="############-----------------------------Indicadores---------------------------########";//Indicadores
sinput string Sindall="############-----------Alligator----------------########";//Alligator
input int                InpJawsPeriod=13;               // Período Mandíbula
input int                InpJawsShift=8;                 // Shift Mandíbula 
input int                InpTeethPeriod=8;               // Período Dentes
input int                InpTeethShift=5;                // Shift Dentes  
input int                InpLipsPeriod=5;                // Período Lábios
input int                InpLipsShift=3;                 // Shift Lábios
input ENUM_MA_METHOD     InpMAMethod=MODE_SMMA;          // Moving average method
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_MEDIAN;   // Applied price

sinput string Sindmart="############-----------Martelo----------------########";//Martelo
input double max_sombra_cont=2;//Tamanho máximo Sombra Contrária em Pontos
input double InpAmpMinima=8; // Tamanho mínimo  Amplitude (Alta-Baixa) em pontos
                             //input double InpAmpMaxima=20; // Tamanho máximo Amplitude (Alta-Baixa)em pontos
input double _Sombra=30; // Sombra maior que (%) da Amplitude

sinput string Sindvol="############-----------Volumes----------------########";//Volumes
input UsoFiltro UsarVolume=Nao;//Usar Filtro de Volume
input ENUM_APPLIED_VOLUME tipo_vol=VOLUME_REAL;//VOLUME APLICADO

sinput string Lucro="###---------------------Usar Lucro/Prejuizo para Fechamento-----------------------#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia

sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="10:05";//Horario Inicial
input string end_hour="16:40";//Horario Final
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
   CChartObjectHLine HLine_PriceMed,HLine_Buy,HLine_Sell,HLine_GainBuy,HLine_GainSell;
   string            currency_symbol;
   double            sl,tp,price_open,oldprice;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   CiAlligator      *alligator;
   CiVolumes        *Volumes;
   double            sl_position,tp_position;
   double            Buyprice,Sellprice;
   double            tp_amplitude;
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
   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);
   double            SombraUp();
   double            SombraDown();
   bool              MarteloUp();
   bool              MarteloDown();
   double            Amplitude();

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

   tradeOn=true;
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
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   setNameGvOrder();

   long curChartID=ChartID();
   alligator=new CiAlligator;
   alligator.Create(original_symbol,periodoRobo,InpJawsPeriod,InpJawsShift,InpTeethPeriod,InpTeethShift,InpLipsPeriod,InpLipsShift,InpMAMethod,InpAppliedPrice);
   alligator.AddToChart(curChartID,0);


   Volumes=new CiVolumes;
   Volumes.Create(Symbol(),periodoRobo,tipo_vol);
   Volumes.AddToChart(curChartID,(int)ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL));



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

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

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

   return(INIT_SUCCEEDED);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   delete(alligator);
   delete(Volumes);
   DeletaIndicadores();

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTick(void)
  {

   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today",(double)TimeNow.day_of_year);

   bool novodia;
   novodia=Bar_NovoDia.CheckNewBar(original_symbol,PERIOD_D1);

   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      gv.Set("glob_entr_tot",0.0);
      gv.Set("deals_total_prev",0.0);
      tradeOn=true;
     }

   gv.Set("gv_today_prev",gv.Get("gv_today"));

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   alligator.Refresh();
   Volumes.Refresh();
   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }

   if(bid>ask)return;//Leilão

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

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
   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
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
   if(Buy_opened() && Sell_opened())CloseByPosition();

   if(tradeOn && timerOn)

     {// inicio Trade On

      if(Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo))
        {
         if(BuySignal() && !Buy_opened())
           {
            DeleteOrders(ORDER_TYPE_SELL_STOP);
            ClosePosType(POSITION_TYPE_SELL);
            Buyprice=high[1]+ticksize;
            sl_position=low[1];
            tp_position=mysymbol.NormalizePrice(Buyprice+_TakeProfit*ponto);
            if(tipotake==TkAmplitude)
              {
               tp_amplitude=MathRound(_TakeProfitvezes*0.01*Amplitude()/ticksize)*ticksize;
               tp_position=mysymbol.NormalizePrice(Buyprice+tp_amplitude);
              }
            if(Buyprice>ask)
              {
               oldprice=PriceLastStopOrder(ORDER_TYPE_BUY_STOP);
               if(Buyprice<oldprice || oldprice==-1.0)
                 {
                  DeleteOrders(ORDER_TYPE_BUY_STOP);
                  if(mytrade.BuyStop(Lot,Buyprice,original_symbol,sl_position,tp_position,order_time_type,0,"BUY"+exp_name))
                    {
                     if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                       {
                        gv.Set("cp_tick",(double)mytrade.ResultOrder());
                        Print("Ordem Enviada ou Executada com Sucesso");
                       }
                     else
                        Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());
                    }
                  else
                     Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());

                 }
              }
            else
              {
               DeleteOrders(ORDER_TYPE_BUY_STOP);
               tp_position=mysymbol.NormalizePrice(ask+_TakeProfit*ponto);
               if(tipotake==TkAmplitude)
                 {
                  tp_amplitude=MathRound(_TakeProfitvezes*0.01*Amplitude()/ticksize)*ticksize;
                  tp_position=mysymbol.NormalizePrice(ask+tp_amplitude);
                 }

               if(mytrade.Buy(Lot,original_symbol,0,sl_position,tp_position,"BUY"+exp_name))
                 {
                  if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                    {
                     gv.Set("cp_tick",(double)mytrade.ResultOrder());
                     Print("Ordem Enviada ou Executada com Sucesso");
                    }
                  else
                     Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());
                 }
               else
                  Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());

              }

           }

         if(SellSignal() && !Sell_opened())
           {
            DeleteOrders(ORDER_TYPE_BUY_STOP);
            ClosePosType(POSITION_TYPE_BUY);
            Sellprice=low[1]-ticksize;
            sl_position=high[1];
            tp_position=mysymbol.NormalizePrice(Sellprice-_TakeProfit*ponto);
            if(tipotake==TkAmplitude)
              {
               tp_amplitude=MathRound(_TakeProfitvezes*0.01*Amplitude()/ticksize)*ticksize;
               tp_position=mysymbol.NormalizePrice(Sellprice-tp_amplitude);
              }

            if(Sellprice<bid)
              {
               oldprice=PriceLastStopOrder(ORDER_TYPE_SELL_STOP);
               if(Sellprice>oldprice || oldprice==-1.0)
                 {
                  DeleteOrders(ORDER_TYPE_SELL_STOP);
                  if(mytrade.SellStop(Lot,Sellprice,original_symbol,sl_position,tp_position,order_time_type,0,"SELL"+exp_name))
                    {
                     if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                       {
                        gv.Set("vd_tick",(double)mytrade.ResultOrder());
                        Print("Ordem Enviada ou Executada com Sucesso");
                       }
                     else
                        Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());
                    }
                  else
                     Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());

                 }
              }
            else
              {
               DeleteOrders(ORDER_TYPE_SELL_STOP);
               tp_position=mysymbol.NormalizePrice(bid-_TakeProfit*ponto);
               if(tipotake==TkAmplitude)
                 {
                  tp_amplitude=MathRound(_TakeProfitvezes*0.01*Amplitude()/ticksize)*ticksize;
                  tp_position=mysymbol.NormalizePrice(bid-tp_amplitude);
                 }

               if(mytrade.Sell(Lot,original_symbol,0,sl_position,tp_position,"SELL"+exp_name))
                 {
                  if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                    {
                     gv.Set("cp_tick",(double)mytrade.ResultOrder());
                     Print("Ordem Enviada ou Executada com Sucesso");
                    }
                  else
                     Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());
                 }
               else
                  Print("Erro enviar ordem ",GetLastError()," ",mytrade.ResultRetcodeDescription());

              }

           }

        }//End NewBar

     }//End Trade On

  }//Fim Ontick
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::BuySignal()
  {
   bool signal=false;
   double dist;
   dist=MathMin(close[1]-alligator.Jaw(1),close[1]-alligator.Teeth(1));
   dist=MathMin(dist,close[1]-alligator.Lips(1));
   signal=MarteloUp() && dist>=_distancia*ponto;
   signal=signal && alligator.Lips(1)>alligator.Teeth(1) && alligator.Teeth(1)>alligator.Jaw(1);
   if(UsarVolume==Sim)
      signal=signal && Volumes.Main(1)>Volumes.Main(2);
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal=false;
   double dist;
   dist=MathMin(alligator.Jaw(1)-close[1],alligator.Teeth(1)-close[1]);
   dist=MathMin(dist,alligator.Lips(1)-close[1]);
   signal=MarteloDown() && dist>=_distancia*ponto;
   signal=signal && alligator.Lips(1)<alligator.Teeth(1) && alligator.Teeth(1)<alligator.Jaw(1);
   if(UsarVolume==Sim)
      signal=signal && Volumes.Main(1)>Volumes.Main(2);

   return signal;
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

void MyRobot::OnTradeTransaction(const MqlTradeTransaction &trans,
                                 const MqlTradeRequest &request,
                                 const MqlTradeResult &result)
  {

   if(trans.symbol!=original_symbol)return;
   double buyprice,sellprice;
   int TENTATIVAS=10;

//--- get transaction type as enumeration value
   ENUM_TRADE_TRANSACTION_TYPE type=trans.type;
//--- if transaction is result of addition of the transaction in history

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(type==TRADE_TRANSACTION_ORDER_UPDATE)
     {
      myorder.Select(trans.order);

     }

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

            if(deal_comment=="BUY"+exp_name)
              {
               DeleteOrdersComment("SELL"+exp_name);
              }

            if(deal_comment=="SELL"+exp_name)
              {
               DeleteOrdersComment("BUY"+exp_name);
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
         buyprice = 0;
         while(buyprice==0 && cont<TENTATIVAS)
           {
            buyprice=myposition.PriceOpen();
            cont+=1;
           }
         if(buyprice==0)
            buyprice=mysymbol.Ask();

        }
      //--------------------------------------------------

      if(myhistory.Comment()=="SELL"+exp_name && trans.order_state==ORDER_STATE_FILLED)

        {
         myposition.SelectByTicket(trans.order);
         int cont=0;
         sellprice=0;
         while(sellprice==0 && cont<TENTATIVAS)
           {
            sellprice=myposition.PriceOpen();
            cont+=1;
           }
         if(sellprice==0)
            sellprice=mysymbol.Bid();
        }

      lucro_orders=LucroOrdens();
      lucro_orders_mes = LucroOrdensMes();
      lucro_orders_sem = LucroOrdensSemana();


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MyRobot::SombraUp()
  {
   return high[1]-MathMax(open[1],close[1]);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::SombraDown()
  {
   return MathMin(open[1],close[1])-low[1];
  }
//+------------------------------------------------------------------+
bool MyRobot::MarteloUp()
  {
   bool signal=false;
   signal=SombraDown()/MathMax(Amplitude(),ticksize)>=_Sombra*0.01 && SombraUp()<=max_sombra_cont*ponto;
   signal=signal && Amplitude()>=InpAmpMinima*ponto;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::MarteloDown()
  {
   bool signal=false;
   signal=SombraUp()/MathMax(Amplitude(),ticksize)>=_Sombra*0.01 && SombraDown()<=max_sombra_cont*ponto;
   signal=signal&&Amplitude()>=InpAmpMinima*ponto;
   return signal;
  }
//+------------------------------------------------------------------+
double MyRobot::Amplitude()
  {
   return (high[1]-low[1]);
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
bool MyPanel::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {

   int xx1=INDENT_LEFT;
   int yy1=INDENT_TOP;
   int xx2=x1+BUTTON_WIDTH;
   int yy2=INDENT_TOP+BUTTON_HEIGHT;

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);

//--- create dependent controls 

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Nome: "+AccountInfoString(ACCOUNT_NAME),xx1,yy1,xx2,yy2))
      return(false);
   m_label[0].Color(clrDeepSkyBlue);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"Servidor: "+AccountInfoString(ACCOUNT_SERVER)+" Login: "+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)),xx1,yy1,xx2,yy2))
      return(false);
   m_label[1].Color(clrYellow);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"RESULTADO MENSAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[2].Color(clrYellow);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+3*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"RESULTADO SEMANAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[3].Color(clrMediumSpringGreen);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+4*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],"RESULTADO DIÁRIO: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[4].Color(clrMediumSpringGreen);

//--- succeed 
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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyPanel::OnTick(void)
  {
   m_label[0].Text("Nome: "+AccountInfoString(ACCOUNT_NAME));
   m_label[1].Text("Servidor: "+AccountInfoString(ACCOUNT_SERVER)+" Login: "+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)));
   m_label[2].Text("RESULTADO MENSAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2));
   m_label[3].Text("RESULTADO SEMANAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2));
   m_label[4].Text("RESULTADO DIÁRIO: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2));
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
