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
enum TipoMart
  {
   MartFibo,//Martingale Fibonacci
   MartExp//Martingale Exponencial
  };

string keystr="892fb7a2097d7f0183c4c56498a36b00";
datetime data_validade;
string Only_Demo;
#include <Bcrypt.mqh>
CBcrypt B;

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
sinput string senha="";//Cole a senha
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO 
input ulong MAGIC_NUMBER=26032019;
ulong deviation_points=50;//Deviation em Pontos(Padrao)
sinput string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input double pts_entry=70;//Pontos para Execução de Ordem

input double Lot=1;//Lote Fixo de Entrada
input double _Stop=100;//SL em Pontos 
input double _TakeProfit=100;//TP em Pontos
input TipoMart tipomart=MartExp;//Opção de Martingale
input ushort num_mart=5;//Quantidade de Martingale
sinput string Lucro="###---------------------Usar Lucro/Prejuizo para Fechamento-----------------------#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia

sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input uchar start_hour=9;//INICIO (HORA) 
input bool first_tick=false;//Entrar no primeiro tick Dia?
input uchar end_hour=17;//TERMINO (HORA)
input bool daytrade=true;//DAYTRADE - Fechar Posicao Fim do Horario
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
   CChartObjectHLine HLine_Stop,HLine_Take;
   string            currency_symbol;
   double            sl,tp,price_open;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   double            sl_position,tp_position;
   double            Buyprice,Sellprice,limit_buy,limit_sell;
   string            mensagens;
   bool              tradebarra;
   ushort            total_loss;

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
   void              SegurancaPos(int nsec);
   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);
   int               LossDay();
   double            CalcLot();
   double            FibolLot(int num_loss);
   bool              isNewBar(datetime newbar_time);

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

   total_loss=0;
   tradeOn=true;
   setExpName();
   setSymbol(Symbol());
   setOriginalSymbol(Symbol());
   setMagic(MAGIC_NUMBER);
   setPeriod(PERIOD_CURRENT);
   if(SymbolInfoInteger(original_symbol,SYMBOL_EXPIRATION_MODE)==2)order_time_type=1;
   else order_time_type=0;

   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(MAGIC_NUMBER);
   mytrade.SetDeviationInPoints(50);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
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

   if(start_hour>23 || end_hour>23)
     {
      string erro="Hora Inicial ou Final Inválida";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+IntegerToString(start_hour)+":00");
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+IntegerToString(end_hour)+":00");

   long curChartID=ChartID();

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
   static bool acima_abertura=false;
   static bool acima_abertura_prev=false;

   bool novodia;
   novodia=Bar_NovoDia.CheckNewBar(original_symbol,PERIOD_D1);

   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      gv.Set("glob_entr_tot",0.0);
      gv.Set("deals_total_prev",0.0);
      tradeOn=true;
      _first_tick=true;
      total_loss=0;
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

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+IntegerToString(start_hour)+":00:00");
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+IntegerToString(end_hour)+":00");

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
      if(hora_inicial<hora_final)
         timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();

      else
         timerOn=(TimeCurrent()>=hora_inicial || TimeCurrent()<=hora_final) && TimeDayFilter();
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
   bool isnewbar=Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo);

   if(tradeOn && timerOn)

     {// inicio Trade On
      // SegurancaPos(10);

      //  if(Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo))
      if(isnewbar || (first_tick && _first_tick))
        {
         tradebarra=true;
         if(_first_tick)_first_tick=false;
         DeleteALL();
         CloseALL();
         price_open=iOpen(original_symbol,periodoRobo,0);
         Buyprice=price_open+pts_entry*ponto;
         Sellprice=price_open-pts_entry*ponto;
         sl_position=mysymbol.NormalizePrice(Buyprice-_Stop*ponto);
         tp_position=mysymbol.NormalizePrice(Buyprice+_TakeProfit*ponto);
         limit_buy=Buyprice;
         if(Buyprice>ask)
           {

            if(mytrade.OrderOpen(_Symbol,ORDER_TYPE_BUY_STOP_LIMIT,CalcLot(),limit_buy,Buyprice,sl_position,tp_position,order_time_type,0,"BUY"+exp_name))
              {
               if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                 {
                  gv.Set("cp_tick",(double)mytrade.ResultOrder());
                  mensagens=__FUNCTION__+" Ordem Enviada ou Executada com Sucesso. Preço "+DoubleToString(mytrade.ResultPrice(),_Digits);
                  Print(mensagens);
                 }
               else
                 {
                  mensagens="__FUNCTION__ = "+__FUNCTION__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  Print(mensagens);
                 }
              }
            else
              {
               mensagens="__FUNCTION__ = "+__FUNCTION__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
               Print(mensagens);
              }
           }
         else
           {
            limit_buy=ask;
            sl_position=mysymbol.NormalizePrice(ask-_Stop*ponto);
            tp_position=mysymbol.NormalizePrice(ask+_TakeProfit*ponto);
            if(mytrade.BuyLimit(CalcLot(),limit_buy,original_symbol,sl_position,tp_position,order_time_type,0,"BUY"+exp_name))
              {
               if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                 {
                  gv.Set("cp_tick",(double)mytrade.ResultOrder());
                  mensagens=__FUNCTION__+" Ordem Enviada ou Executada com Sucesso. Preço "+DoubleToString(mytrade.ResultPrice(),_Digits);
                  Print(mensagens);
                 }
               else
                 {
                  mensagens="__FUNCTION__ = "+__FUNCTION__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  Print(mensagens);
                 }
              }
            else
              {
               mensagens="__FUNCTION__ = "+__FUNCTION__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
               Print(mensagens);
              }
           }
         sl_position=mysymbol.NormalizePrice(Sellprice+_Stop*ponto);
         tp_position=mysymbol.NormalizePrice(Sellprice-_TakeProfit*ponto);
         limit_sell=Sellprice;

         if(Sellprice<bid)
           {
            if(mytrade.OrderOpen(_Symbol,ORDER_TYPE_SELL_STOP_LIMIT,CalcLot(),limit_sell,Sellprice,sl_position,tp_position,order_time_type,0,"SELL"+exp_name))
              {
               if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                 {
                  gv.Set("vd_tick",(double)mytrade.ResultOrder());
                  mensagens=__FUNCTION__+" Ordem Enviada ou Executada com Sucesso. Preço "+DoubleToString(mytrade.ResultPrice(),_Digits);
                  Print(mensagens);
                 }
               else
                 {
                  mensagens="__FUNCTION__ = "+__FUNCTION__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  Print(mensagens);
                 }
              }
            else
              {
               mensagens="__FUNCTION__ = "+__FUNCTION__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
               Print(mensagens);
              }
           }

         else
           {
            limit_sell=bid;
            sl_position=mysymbol.NormalizePrice(bid+_Stop*ponto);
            tp_position=mysymbol.NormalizePrice(bid-_TakeProfit*ponto);

            if(mytrade.SellLimit(CalcLot(),limit_sell,original_symbol,sl_position,tp_position,order_time_type,0,"SELL"+exp_name))
              {
               if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                 {
                  gv.Set("vd_tick",(double)mytrade.ResultOrder());
                  mensagens=__FUNCTION__+" Ordem Enviada ou Executada com Sucesso. Preço "+DoubleToString(mytrade.ResultPrice(),_Digits);
                  Print(mensagens);
                 }
               else
                 {
                  mensagens="__FUNCTION__ = "+__FUNCTION__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  Print(mensagens);
                 }
              }
            else
              {
               mensagens="__FUNCTION__ = "+__FUNCTION__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
               Print(mensagens);
              }
           }

        }//End NewBar

      if(close[0]>=price_open)acima_abertura=true;
      else acima_abertura=false;

      if(acima_abertura!=acima_abertura_prev)
        {

         if(!PosicaoAberta() && TotalOrdens()==0 && tradebarra)
           {

            Buyprice=price_open+pts_entry*ponto;
            Sellprice=price_open-pts_entry*ponto;
            sl_position=mysymbol.NormalizePrice(Buyprice-_Stop*ponto);
            tp_position=mysymbol.NormalizePrice(Buyprice+_TakeProfit*ponto);
            limit_buy=Buyprice;
            if(Buyprice>ask)
              {

               if(mytrade.OrderOpen(_Symbol,ORDER_TYPE_BUY_STOP_LIMIT,CalcLot(),limit_buy,Buyprice,sl_position,tp_position,order_time_type,0,"BUY"+exp_name))
                 {
                  if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                    {
                     gv.Set("cp_tick",(double)mytrade.ResultOrder());
                     mensagens=__FUNCTION__+" Ordem Enviada ou Executada com Sucesso. Preço "+DoubleToString(mytrade.ResultPrice(),_Digits);
                     Print(mensagens);
                    }
                  else
                    {
                     mensagens="__FUNCTION__ = "+__FUNCTION__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                     Print(mensagens);
                    }
                 }
               else
                 {
                  mensagens="__FUNCTION__ = "+__FUNCTION__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  Print(mensagens);
                 }
              }
            else
              {
               limit_buy=ask;
               sl_position=mysymbol.NormalizePrice(ask-_Stop*ponto);
               tp_position=mysymbol.NormalizePrice(ask+_TakeProfit*ponto);
               if(mytrade.BuyLimit(CalcLot(),limit_buy,original_symbol,sl_position,tp_position,order_time_type,0,"BUY"+exp_name))
                 {
                  if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                    {
                     gv.Set("cp_tick",(double)mytrade.ResultOrder());
                     mensagens=__FUNCTION__+" Ordem Enviada ou Executada com Sucesso. Preço "+DoubleToString(mytrade.ResultPrice(),_Digits);
                     Print(mensagens);
                    }
                  else
                    {
                     mensagens="__FUNCTION__ = "+__FUNCTION__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                     Print(mensagens);
                    }
                 }
               else
                 {
                  mensagens="__FUNCTION__ = "+__FUNCTION__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  Print(mensagens);
                 }
              }
            sl_position=mysymbol.NormalizePrice(Sellprice+_Stop*ponto);
            tp_position=mysymbol.NormalizePrice(Sellprice-_TakeProfit*ponto);
            limit_sell=Sellprice;

            if(Sellprice<bid)
              {
               if(mytrade.OrderOpen(_Symbol,ORDER_TYPE_SELL_STOP_LIMIT,CalcLot(),limit_sell,Sellprice,sl_position,tp_position,order_time_type,0,"SELL"+exp_name))
                 {
                  if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                    {
                     gv.Set("vd_tick",(double)mytrade.ResultOrder());
                     mensagens=__FUNCTION__+" Ordem Enviada ou Executada com Sucesso. Preço "+DoubleToString(mytrade.ResultPrice(),_Digits);
                     Print(mensagens);
                    }
                  else
                    {
                     mensagens="__FUNCTION__ = "+__FUNCTION__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                     Print(mensagens);
                    }
                 }
               else
                 {
                  mensagens="__FUNCTION__ = "+__FUNCTION__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  Print(mensagens);
                 }
              }

            else
              {
               limit_sell=bid;
               sl_position=mysymbol.NormalizePrice(bid+_Stop*ponto);
               tp_position=mysymbol.NormalizePrice(bid-_TakeProfit*ponto);

               if(mytrade.SellLimit(CalcLot(),limit_sell,original_symbol,sl_position,tp_position,order_time_type,0,"SELL"+exp_name))
                 {
                  if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                    {
                     gv.Set("vd_tick",(double)mytrade.ResultOrder());
                     mensagens=__FUNCTION__+" Ordem Enviada ou Executada com Sucesso. Preço "+DoubleToString(mytrade.ResultPrice(),_Digits);
                     Print(mensagens);
                    }
                  else
                    {
                     mensagens="__FUNCTION__ = "+__FUNCTION__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                     Print(mensagens);
                    }
                 }
               else
                 {
                  mensagens="__FUNCTION__ = "+__FUNCTION__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  Print(mensagens);
                 }
              }

           }

        }

      acima_abertura_prev=acima_abertura;

     }//End Trade On

  }//Fim Ontick
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

   if(trans.symbol!=original_symbol)return;
   double buyprice,sellprice;
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
      long deal_id=-1;
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
         deal_id=HistoryDealGetInteger(trans.deal,DEAL_POSITION_ID);
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
               DeleteALL();
              }

            if(deal_comment=="SELL"+exp_name)
              {
               DeleteALL();
              }
            if((deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL) && (deal_entry==DEAL_ENTRY_OUT || deal_entry==DEAL_ENTRY_OUT_BY))
              {
               if(deal_profit<0)
                 {
                  Print("Saída por STOP LOSS. Position ID: "+IntegerToString(deal_id));
                  total_loss++;
                 }
               if(deal_profit>0)
                 {
                  Print("Saída no GAIN. Position ID: "+IntegerToString(deal_id));
                  tradebarra=false;
                  total_loss=0;
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

int MyRobot::LossDay()
  {
   int cnt=0;
   long deal_id=-1;
   long deal_id_prev=-1;
   if(HistorySelect(iTime(_Symbol,PERIOD_D1,0),TimeCurrent()))
     {
      for(int x=HistoryDealsTotal()-1; x>=0; x--)
        {
         deal_id_prev=deal_id;
         ulong ticket=HistoryDealGetTicket(x);
         string _symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
         ulong type=HistoryDealGetInteger(ticket,DEAL_TYPE);
         ulong magic = HistoryDealGetInteger(ticket,DEAL_MAGIC);
         ulong entry = HistoryDealGetInteger(ticket,DEAL_ENTRY);
         double profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
         string comment=HistoryDealGetString(ticket,DEAL_COMMENT);
         long deal_reason=HistoryDealGetInteger(ticket,DEAL_REASON);
         deal_id=HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
         if(_symbol!=_Symbol) continue;
         if(magic== Magic_Number && entry== DEAL_ENTRY_OUT && profit>0) break;
         if(magic==Magic_Number && deal_reason==DEAL_REASON_TP)break;
         if(magic==Magic_Number && entry==DEAL_ENTRY_OUT && deal_reason==DEAL_REASON_SL && profit<0)
            if(deal_id!=deal_id_prev)
               cnt++;

        }
     }
   return(cnt);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::FibolLot(int num_loss)
  {

   int  c,first=0,second=1,next=0;
//   for(c=0; c<Numeros; c++)
   for(c=0; c<num_loss+3; c++)
     {
      if(c<=1)
         next=c;
      else
        {
         next=first+second;
         first=second;
         second=next;
        }
     }

   return ((double)next);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::CalcLot()
  {
   double lots=Lot;
   int loss=0;
   double lot_step=mysymbol.LotsStep();

   switch(tipomart)
     {
      case MartExp:
         loss=LossDay();
         //loss=total_loss;
         if(loss>0 && loss<=num_mart){ lots=NormalizeDouble(lots*MathPow(2.0,loss),2);}
         break;
      case MartFibo:
         loss=LossDay();
         //loss=total_loss;
         if(loss>0 && loss<=num_mart){ lots=FibolLot(loss);}
         break;
     }
   return( NormalizeDouble(MathRound(lots/lot_step)*lot_step,2) );
  }
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
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.OnTick();
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
bool MyRobot::isNewBar(datetime newbar_time)
  {
//--- Initialization of protected variables
   m_new_bars = 0;      // Number of new bars
   m_retcode  = 0;      // Result code of detecting new bar: 0 - no error
   m_comment  =__FUNCTION__+" Successful check for new bar";
//---

//--- Just to be sure, check: is the time of (hypothetically) new bar m_newbar_time less than time of last bar m_lastbar_time? 
   if(m_lastbar_time>newbar_time)
     { // If new bar is older than last bar, print error message
      m_comment=__FUNCTION__+" Synchronization error: time of previous bar "+TimeToString(m_lastbar_time)+
                ", time of new bar request "+TimeToString(newbar_time);
      m_retcode=-1;     // Result code of detecting new bar: return -1 - synchronization error
      return(false);
     }
//---

//--- if it's the first call 
   if(m_lastbar_time==0)
     {
      m_lastbar_time=newbar_time; //--- set time of last bar and exit
      m_comment=__FUNCTION__+" Initialization of lastbar_time = "+TimeToString(m_lastbar_time);
      return(false);
     }
//---

//--- Check for new bar: 
   if(m_lastbar_time<newbar_time)
     {
      m_new_bars=1;               // Number of new bars
      m_lastbar_time=newbar_time; // remember time of last bar
      return(true);
     }
//---

//--- if we've reached this line, then the bar is not new; return false
   return(false);
  }
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
