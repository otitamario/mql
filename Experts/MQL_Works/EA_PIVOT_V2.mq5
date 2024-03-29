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
#resource "\\Indicators\\pivotpointuniversal.ex5"
#resource "\\Indicators\\gann_hi_lo_activator_ssl.ex5"
#resource "\\Indicators\\Custom Moving Average Input Color.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TipoTend
  {
   TendContra,//Contra-Tendência
   TendFavor//Favor da Tendência
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum BarraEntrada
  {
   Barra_Fechar,//Esperar Barra Fechar
   Cada_tick //Cada Tick
  };

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


// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO 
input ulong MAGIC_NUMBER=26032019;//Número Mágico
ulong deviation_points=500;//Deviation em Pontos(Padrao)
sinput string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input BarraEntrada barra_entry=Barra_Fechar;//Momento de Entrada
input bool RevertPos=false;//Reverter Posições no Sinal Contrário
input double Lot=1;//Lote de Entrada
input double _Stop=200;//Stop Loss em Pontos
input double _TakeProfit=300;//Take Profit em Pontos
input bool UsarHilo=false;//Usar filtro HiLo
input bool UsarMACD=false;//Usar filtro MACD
sinput string Sind="############-----------------Indicadores------------------########";//Indicadores
sinput string Sindhilo="############-----------------HiLo------------------########";//HiLo
input int period_hilo=25;//Periodo Hilo
input ENUM_MA_METHOD InpMethod=MODE_SMMA;// Método Hilo
sinput string Sindmed="############-----------------Médias-----------------########";//Médias
input int period_mfast=17;//Periodo Média Rápida
input ENUM_MA_METHOD modo_mfast=MODE_EMA;//Modo Média Rápida
input int period_mslow=34;//Periodo Média Lenta
input ENUM_MA_METHOD modo_mslow=MODE_EMA;//Modo Média Lenta
sinput string smacd="############------MACD------#################";//MACD
input int                InpFastEMA=12;               // Fast EMA period
input int                InpSlowEMA=26;               // Slow EMA period
input int                InpSignalSMA=9;              // Signal SMA period
input ENUM_APPLIED_PRICE InpAppliedPrice=PRICE_CLOSE; // Applied price


sinput string STrailing="############---------------Trailing Stop----------########";//Stop Móvel
input bool   Use_TraillingStop=false; //Usar Stop Móvel
input double TraillingStart=50;//Lucro Minimo Em Pontos Iniciar Stop Móvel
input double TraillingDistance=100;// Distancia em Pontos do Stop Loss
input double TraillingStep=10;// Passo para atualizar Stop Loss

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
sinput string srealp="############----Realização Parcial------#################";//Realização Parcial
input double rp1=0;//Pontos R.P 1 (0 Não Usar)
input double _lts_rp1=25;//Porcentagem Lotes R.P 1
input double rp2=0;//Pontos R.P 2 (0 Não Usar)
input double _lts_rp2=25;//Porcentagem Lotes R.P 2
input double rp3=0;//Pontos R.P 3 (0 Não Usar)
input double _lts_rp3=0;//Porcentagem Lotes R.P 3
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

class MyRobot: public MyExpert
  {
private:
   CChartObjectHLine HLine_Stop,HLine_Take;
   CiMACD           *macd;
   string            currency_symbol;
   double            sl,tp,price_open_day;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   double            sl_position,tp_position;
   double            Buyprice,Sellprice;
   int               pivo_handle,hilo_handle;
   int               mfast_handle,mslow_handle;
   double            mfast[],mslow[];
   double            hilo_color[];
   double            Pivo[],Pivo_S1[],Pivo_S2[],Pivo_S3[],Pivo_S4[],Pivo_R1[],Pivo_R2[],Pivo_R3[],Pivo_R4[];
   bool              tradebarra,novabarra;
   uchar             idx_barra;
   bool              buysignal,sellsignal;
   datetime          hora_fin_entrad;
   bool              timeEnt;
   double            preco_medio;
   double            vol_pos,vol_stp,preco_stp;

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
   virtual void      Atual_vol_Stop_Take();
   void              Real_Parc_Sell(double vol,double preco);
   void              Real_Parc_Buy(double vol,double preco);

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

   if(barra_entry==Barra_Fechar)idx_barra=1;
   else idx_barra=0;
   tradebarra=false;

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

   if(_lts_rp1*rp1+_lts_rp2*rp2+_lts_rp3*rp3>0 && _lts_rp1+_lts_rp2+_lts_rp3>=100)
     {
      string erro="A soma das porcentagems de realização parcial devem ser menor que 100";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(_lts_rp1*rp1+_lts_rp2*rp2+_lts_rp3*rp3>0 && (rp1>=_TakeProfit || rp2>=_TakeProfit || rp3>=_TakeProfit))
     {
      string erro="Os pontos de realização parcial devem ser menores que o Take Profit";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   long curChartID=ChartID();

   pivo_handle=iCustom(_Symbol,periodoRobo,"::Indicators\\pivotpointuniversal.ex5",0,0,0);

   ChartIndicatorAdd(0,0,pivo_handle);

   hilo_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\gann_hi_lo_activator_ssl.ex5",period_hilo,InpMethod);
   if(UsarHilo) ChartIndicatorAdd(0,0,hilo_handle);

   mfast_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\Custom Moving Average Input Color.ex5",period_mfast,0,modo_mfast,clrLime);
   ChartIndicatorAdd(0,0,mfast_handle);

   mslow_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\Custom Moving Average Input Color.ex5",period_mslow,0,modo_mslow,clrWhite);
   ChartIndicatorAdd(0,0,mslow_handle);

   macd=new CiMACD;
   macd.Create(NULL,periodoRobo,InpFastEMA,InpSlowEMA,InpSignalSMA,InpAppliedPrice);
   if(UsarMACD) macd.AddToChart(curChartID,(int)ChartGetInteger(curChartID,CHART_WINDOWS_TOTAL));

   ArraySetAsSeries(hilo_color,true);
   ArraySetAsSeries(mfast,true);
   ArraySetAsSeries(mslow,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ArraySetAsSeries(Pivo,true);
   ArraySetAsSeries(Pivo_R1,true);
   ArraySetAsSeries(Pivo_R2,true);
   ArraySetAsSeries(Pivo_R3,true);
   ArraySetAsSeries(Pivo_R4,true);
   ArraySetAsSeries(Pivo_S1,true);
   ArraySetAsSeries(Pivo_S2,true);
   ArraySetAsSeries(Pivo_S3,true);
   ArraySetAsSeries(Pivo_S4,true);

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
   IndicatorRelease(pivo_handle);
   IndicatorRelease(hilo_handle);
   IndicatorRelease(mfast_handle);
   IndicatorRelease(mslow_handle);
   delete(macd);
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
     }

   gv.Set("gv_today_prev",gv.Get("gv_today"));

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
   macd.Refresh();
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }

   if(bid>=ask)return;//Leilão

   if(!TerminalInfoInteger(TERMINAL_CONNECTED))return;


   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   hora_fin_entrad=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_ent);

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

      if(PosicaoAberta())
        {

         Atual_vol_Stop_Take();
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
      novabarra=Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo);
      if(novabarra)
        {
         tradebarra=true;
        }//End NewBar

      if(RevertPos)
        {
         buysignal=BuySignal() && !Buy_opened();
         sellsignal=SellSignal() && !Sell_opened();
        }
      else
        {
         buysignal=BuySignal() && !PosicaoAberta();
         sellsignal=SellSignal() && !PosicaoAberta();
        }

      if(barra_entry==Cada_tick)
        {
         buysignal=buysignal && tradebarra;
         sellsignal=sellsignal && tradebarra;
        }
      else
        {
         buysignal=buysignal && novabarra;
         sellsignal=sellsignal && novabarra;
        }
      if(timeEnt)
        {
         if(buysignal)
           {
            tradebarra=false;
            DeleteALL();
            CloseALL();
            sl_position=NormalizeDouble(bid-_Stop*ponto,digits);
            tp_position=NormalizeDouble(ask+_TakeProfit*ponto,digits);
            if(mytrade.Buy(Lot,original_symbol,0,sl_position,tp_position,"BUY"+exp_name))
              {
               gv.Set("cp_tick",(double)mytrade.ResultOrder());
               tradebarra=false;
              }
            else
               Print("Erro enviar ordem ",GetLastError());

           }

         if(sellsignal)
           {
            tradebarra=false;
            DeleteALL();
            CloseALL();
            sl_position=NormalizeDouble(ask+_Stop*ponto,digits);
            tp_position=NormalizeDouble(bid-_TakeProfit*ponto,digits);
            if(mytrade.Sell(Lot,original_symbol,0,sl_position,tp_position,"SELL"+exp_name))
              {
               gv.Set("vd_tick",(double)mytrade.ResultOrder());
               tradebarra=false;
              }
            else
               Print("Erro enviar ordem ",GetLastError());

           }
        }

      if(PosicaoAberta())
        {
         if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);
        }

     }//End Trade On

  }//Fim Ontick
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool MyRobot::GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(mfast_handle,0,0,5,mfast)<=0 || 
         CopyBuffer(hilo_handle,1,0,5,hilo_color)<=0 || 
         CopyBuffer(mslow_handle,0,0,5,mslow)<=0 || 
         CopyBuffer(pivo_handle,0,0,5,Pivo)<=0 || 
         CopyBuffer(pivo_handle,1,0,5,Pivo_S1)<=0 ||
         CopyBuffer(pivo_handle,2,0,5,Pivo_R1)<=0 ||
         CopyBuffer(pivo_handle,3,0,5,Pivo_S2)<=0 ||
         CopyBuffer(pivo_handle,4,0,5,Pivo_R2)<=0 ||
         CopyBuffer(pivo_handle,5,0,5,Pivo_S3)<=0 ||
         CopyBuffer(pivo_handle,6,0,5,Pivo_R3)<=0 ||
         CopyBuffer(pivo_handle,7,0,5,Pivo_S4)<=0 ||
         CopyBuffer(pivo_handle,8,0,5,Pivo_R4)<=0 ||
         CopyHigh(Symbol(),period,0,5,high)<=0 ||
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

   signal=(close[idx_barra]>Pivo[idx_barra] && mfast[idx_barra]>mslow[idx_barra] && 
           mfast[idx_barra+1]<mslow[idx_barra+1] && close[idx_barra]>=Pivo_R1[idx_barra]
           && close[idx_barra]<Pivo_R2[idx_barra]) || 
           (close[idx_barra]<Pivo[idx_barra] && mfast[idx_barra]>mslow[idx_barra] && 
           mfast[idx_barra+1]<mslow[idx_barra+1] && close[idx_barra]<Pivo_S2[idx_barra]);

   if(UsarHilo)signal=signal && hilo_color[idx_barra]==0.0;
   if(UsarMACD) signal=signal && macd.Main(idx_barra)>macd.Signal(idx_barra);

   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal=false;
   signal=(close[idx_barra]<Pivo[idx_barra] && mfast[idx_barra]<mslow[idx_barra] && 
           mfast[idx_barra+1]>mslow[idx_barra+1] && close[idx_barra]>Pivo_S2[idx_barra]
           && close[idx_barra]<=Pivo_S1[idx_barra]) || 
           (close[idx_barra]>Pivo[idx_barra] && mfast[idx_barra]<mslow[idx_barra] && 
           mfast[idx_barra+1]>mslow[idx_barra+1] && close[idx_barra]>Pivo_R2[idx_barra]);
   if(UsarHilo)signal=signal && hilo_color[idx_barra]==1.0;
   if(UsarMACD) signal=signal && macd.Main(idx_barra)<macd.Signal(idx_barra);

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
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
            buyprice = 0;
            while(buyprice==0 && cont<TENTATIVAS)
              {
               buyprice=myposition.PriceOpen();
               cont+=1;
              }
            if(buyprice==0)
               buyprice=mysymbol.Ask();

            sl_position=NormalizeDouble(buyprice-_Stop*ponto,digits);
            tp_position=NormalizeDouble(buyprice+_TakeProfit*ponto,digits);
            mytrade.PositionModify(trans.order,sl_position,0);
            if(mytrade.SellLimit(Lot,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT"))
              {
               gv.Set("tp_vd_tick",(double)mytrade.ResultOrder());
              }
            else
               Print("Erro enviar ordem: ",GetLastError());

            Real_Parc_Buy(Lot,buyprice);

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

            sl_position=NormalizeDouble(sellprice+_Stop*ponto,digits);
            tp_position=NormalizeDouble(sellprice-_TakeProfit*ponto,digits);
            mytrade.PositionModify(trans.order,sl_position,0);
            if(mytrade.BuyLimit(Lot,tp_position,original_symbol,0,0,0,0,"TAKE PROFIT"))
              {
               gv.Set("tp_cp_tick",(double)mytrade.ResultOrder());
              }
            else
               Print("Erro enviar ordem: ",GetLastError());

            Real_Parc_Sell(Lot,sellprice);

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
void MyRobot::Real_Parc_Buy(double vol,double preco)
  {
   double lts_rp1=0;
   double lts_rp2=0;
   double lts_rp3=0;
   if(vol>mysymbol.LotsMin())
     {
      myposition.SelectByTicket((ulong)gv.Get(cp_tick));
      if(rp1>0 && _lts_rp1>0)
        {
         lts_rp1=MathMin(MathFloor(0.01*_lts_rp1*vol/mysymbol.LotsStep())*mysymbol.LotsStep(),vol);
         lts_rp1=MathMax(lts_rp1,mysymbol.LotsMin());
        }
      if(rp2>0 && _lts_rp2>0)
        {
         lts_rp2=MathFloor(0.01*_lts_rp2*vol/mysymbol.LotsStep())*mysymbol.LotsStep();
         lts_rp2=MathMax(lts_rp2,mysymbol.LotsMin());
        }
      if(lts_rp1+lts_rp2>=vol)
        {
         lts_rp2=vol-lts_rp1;
         lts_rp3=0;
         mytrade.PositionModify((ulong)gv.Get(cp_tick),myposition.StopLoss(),0);
        }
      else
        {

         if(rp3>0 && _lts_rp3>0)
           {
            lts_rp3=MathFloor(0.01*_lts_rp3*vol/mysymbol.LotsStep())*mysymbol.LotsStep();
            lts_rp3=MathMax(lts_rp3,mysymbol.LotsMin());
           }
         if(lts_rp1+lts_rp2+lts_rp3>=vol)
           {
            lts_rp3=vol-lts_rp1-lts_rp2;
            mytrade.PositionModify((ulong)gv.Get(cp_tick),myposition.StopLoss(),0);

           }
        }

      if(rp1>0&&lts_rp1>0)mytrade.SellLimit(lts_rp1,NormalizeDouble(MathRound((preco+rp1*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 1");
      if(rp2>0&&lts_rp2>0)mytrade.SellLimit(lts_rp2,NormalizeDouble(MathRound((preco+rp2*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 2");
      if(rp3>0&&lts_rp3>0)mytrade.SellLimit(lts_rp3,NormalizeDouble(MathRound((preco+rp3*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 3");


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::Real_Parc_Sell(double vol,double preco)
  {
   double lts_rp1=0;
   double lts_rp2=0;
   double lts_rp3=0;
   if(vol>mysymbol.LotsMin())
     {
      myposition.SelectByTicket((ulong)gv.Get(vd_tick));
      if(rp1>0 && _lts_rp1>0)
        {
         lts_rp1=MathMin(MathFloor(0.01*_lts_rp1*vol/mysymbol.LotsStep())*mysymbol.LotsStep(),vol);
         lts_rp1=MathMax(lts_rp1,mysymbol.LotsMin());
        }
      if(rp2>0 && _lts_rp2>0)
        {
         lts_rp2=MathFloor(0.01*_lts_rp2*vol/mysymbol.LotsStep())*mysymbol.LotsStep();
         lts_rp2=MathMax(lts_rp2,mysymbol.LotsMin());
        }
      if(lts_rp1+lts_rp2>=vol)
        {
         lts_rp2=vol-lts_rp1;
         lts_rp3=0;
         mytrade.PositionModify((ulong)gv.Get(cp_tick),myposition.StopLoss(),0);
         //mytrade.OrderDelete((ulong)GlobalVariableGet(tp_cp_tick));
        }
      else
        {

         if(rp3>0 && _lts_rp3>0)
           {
            lts_rp3=MathFloor(0.01*_lts_rp3*vol/mysymbol.LotsStep())*mysymbol.LotsStep();
            lts_rp3=MathMax(lts_rp3,mysymbol.LotsMin());
           }
         if(lts_rp1+lts_rp2+lts_rp3>=vol)
           {
            lts_rp3=vol-lts_rp1-lts_rp2;
            mytrade.PositionModify((ulong)gv.Get(cp_tick),myposition.StopLoss(),0);
            // mytrade.OrderDelete((ulong)GlobalVariableGet(tp_cp_tick));

           }
        }
      if(rp1>0&&lts_rp1>0)mytrade.BuyLimit(lts_rp1,NormalizeDouble(MathRound((preco-rp1*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 1");
      if(rp2>0&&lts_rp2>0)mytrade.BuyLimit(lts_rp2,NormalizeDouble(MathRound((preco-rp2*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 2");
      if(rp3>0&&lts_rp3>0)mytrade.BuyLimit(lts_rp3,NormalizeDouble(MathRound((preco-rp3*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 3");


     }
  }
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(TimeCurrent()>D'2019.07.20 23:59:59')
     {
      string erro="Data de Validade Expirou";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO)
     {
      string erro="EA permitido apenas em conta DEMO";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
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
   m_label[0].Text("RESULTADO MENSAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2));
   m_label[1].Text("RESULTADO SEMANAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2));
   m_label[2].Text("RESULTADO DIÁRIO: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2));
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
