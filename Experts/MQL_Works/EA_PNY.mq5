//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2019, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#resource "\\Indicators\\Prince NY.ex5"

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

#define LARGURA_PAINEL 250 // Largura Painel
#define ALTURA_PAINEL 150 // Altura Painel




// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO 
input ulong MAGIC_NUMBER=26032019;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
sinput string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input double Lot=1;//Lote Fixo de Entrada
input double _Stop=100;//SL em Pontos 
input double _TakeProfit=100;//TP em Pontos 
input double pts_romp=50;//Pontos Rompimento para Entrada
input double Multiplier=2;//Multiplicador Martingale - "0" Não usar
sinput string sind="###----------Indicadores-----------------------#####";    //Indicadores
input int per_principe=30;//Período Príncipe NY
sinput string STrailing="############---------------Trailing Stop----------########";//Trailing
input bool   Use_TraillingStop=true; //Usar Trailing 
input double TraillingStart=100;//Lucro Minimo Iniciar trailing stop
input double TraillingDistance=90;// Distancia em Pontos do Stop Loss
input double TraillingStep=10;// Passo para atualizar Stop Loss

sinput string srealp="############------------------------Realização Parcial-------------------------------#################";//Realização Parcial
input double rp1=50;//Pontos R.P 1 (0 Não Usar)
input double _lts_rp1=50;//% Porcentagem Lotes R.P 1
input double rp2=100;//Pontos R.P 2 (0 Não Usar)
input double _lts_rp2=25;//% Porcentagem Lotes R.P 2
input double rp3=0;//Pontos R.P 3 (0 Não Usar)
input double _lts_rp3=0;//% Porcentagem Lotes R.P 3

sinput string Lucro="###---------------------Usar Lucro/Prejuizo para Fechamento-----------------------#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia

sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="10:00";//Horario Inicial
input string end_hour="17:20";//Horario Final
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
   double            price_buy,price_sell;
   int               prince_handle;
   double            PrinceBuy[],PrinceSell[];
   double            preco_par1,preco_par2,preco_par3;
   bool              Exec_parc1,Exec_parc2,Exec_parc3;
   bool              isHedge;
   double            lts_rp1,lts_rp2,lts_rp3;
   int               val_index;
   double            Buyprice,Sellprice;
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
   void              Real_Parc_Buy(double vol,double preco);
   void              Real_Parc_Sell(double vol,double preco);
   void              ExecucaoParcial();
   int               LossDay();
   double            CalcLot();

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
   isHedge=myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING;
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
   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   setNameGvOrder();

   long curChartID=ChartID();

   prince_handle=iCustom(Symbol(),periodoRobo,"::Indicators\\Prince NY.ex5",per_principe);
   ChartIndicatorAdd(curChartID,0,prince_handle);

   ArraySetAsSeries(PrinceBuy,true);
   ArraySetAsSeries(PrinceSell,true);

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
   IndicatorRelease(prince_handle);
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
   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
   if(bid==0 || ask==0)
     {
      Print("BID ou ASK=0 : ",bid," ",ask);
      return;
     }

   if(bid>=ask)return;//Leilão

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

   if(!PosicaoAberta())
     {
      preco_par1=0.0;preco_par2=0.0;preco_par3=0.0;
      Exec_parc1=false;Exec_parc2=false;Exec_parc3=false;
      lts_rp1=0;
      lts_rp2=0;
      lts_rp3=0;

     }

   if(tradeOn && timerOn)

     {// inicio Trade On
      // SegurancaPos(10);

      if(close[0]<low[1])DeleteOrders(ORDER_TYPE_BUY_STOP);
      if(close[0]>high[1])DeleteOrders(ORDER_TYPE_SELL_STOP);

      if(Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo))
        {
         if(BuySignal() && !Buy_opened())
           {
            DeleteALL();
            ClosePosType(POSITION_TYPE_SELL);
            Buyprice=mysymbol.NormalizePrice(high[1]+pts_romp*ponto);
            if(Buyprice>close[0])
              {

               sl_position=mysymbol.NormalizePrice(Buyprice-_Stop*ponto);
               tp_position=mysymbol.NormalizePrice(Buyprice+_TakeProfit*ponto);
               if(mytrade.BuyStop(CalcLot(),Buyprice,original_symbol,sl_position,tp_position,order_time_type,0,"BUY"+exp_name))
                 {
                  gv.Set(cp_tick,mytrade.ResultOrder());
                 }
               else Print("Erro enviar Ordem: ",GetLastError());
              }
            else
              {
               sl_position=mysymbol.NormalizePrice(bid-_Stop*ponto);
               tp_position=mysymbol.NormalizePrice(ask+_TakeProfit*ponto);
               if(mytrade.Buy(CalcLot(),original_symbol,0,sl_position,tp_position,"BUY"+exp_name))
                 {
                  gv.Set(cp_tick,mytrade.ResultOrder());
                 }
               else Print("Erro enviar Ordem: ",GetLastError());
              }

           }

         if(SellSignal() && !Sell_opened())
           {
            DeleteALL();
            ClosePosType(POSITION_TYPE_BUY);
            Sellprice=mysymbol.NormalizePrice(low[1]-pts_romp*ponto);

            if(Sellprice<close[0])
              {

               sl_position=mysymbol.NormalizePrice(Sellprice+_Stop*ponto);
               tp_position=mysymbol.NormalizePrice(Sellprice-_TakeProfit*ponto);
               if(mytrade.SellStop(CalcLot(),Sellprice,original_symbol,sl_position,tp_position,order_time_type,0,"SELL"+exp_name))
                 {
                  gv.Set(vd_tick,mytrade.ResultOrder());
                 }
               else Print("Erro enviar Ordem: ",GetLastError());
              }
            else
              {
               sl_position=mysymbol.NormalizePrice(ask+_Stop*ponto);
               tp_position=mysymbol.NormalizePrice(bid-_TakeProfit*ponto);
               if(mytrade.Sell(CalcLot(),original_symbol,0,sl_position,tp_position,"SELL"+exp_name))
                 {
                  gv.Set(vd_tick,mytrade.ResultOrder());
                 }
               else Print("Erro enviar Ordem: ",GetLastError());
              }

           }

        }//End NewBar
      ExecucaoParcial();

      if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);

     }//End Trade On

  }//Fim Ontick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MyRobot::Real_Parc_Buy(double vol,double preco)
  {
   lts_rp1=0;
   lts_rp2=0;
   lts_rp3=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
/*
      if(rp1>0&&lts_rp1>0)mytrade.SellLimit(lts_rp1,NormalizeDouble(MathRound((preco+rp1*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 1");
      if(rp2>0&&lts_rp2>0)mytrade.SellLimit(lts_rp2,NormalizeDouble(MathRound((preco+rp2*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 2");
      if(rp3>0&&lts_rp3>0)mytrade.SellLimit(lts_rp3,NormalizeDouble(MathRound((preco+rp3*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 3");
*/

      if(rp1>0&&lts_rp1>0)preco_par1=NormalizeDouble(MathRound((preco+rp1*ponto)/ticksize)*ticksize,digits);
      if(rp2>0&&lts_rp2>0)preco_par2=NormalizeDouble(MathRound((preco+rp2*ponto)/ticksize)*ticksize,digits);
      if(rp3>0&&lts_rp3>0)preco_par3=NormalizeDouble(MathRound((preco+rp3*ponto)/ticksize)*ticksize,digits);



     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::Real_Parc_Sell(double vol,double preco)
  {
   lts_rp1=0;
   lts_rp2=0;
   lts_rp3=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
/*    if(rp1>0&&lts_rp1>0)mytrade.BuyLimit(lts_rp1,NormalizeDouble(MathRound((preco-rp1*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 1");
      if(rp2>0&&lts_rp2>0)mytrade.BuyLimit(lts_rp2,NormalizeDouble(MathRound((preco-rp2*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 2");
      if(rp3>0&&lts_rp3>0)mytrade.BuyLimit(lts_rp3,NormalizeDouble(MathRound((preco-rp3*ponto)/ticksize)*ticksize,digits),original_symbol,0,0,order_time_type,0,"PARCIAL 3");
*/
      if(rp1>0&&lts_rp1>0)preco_par1=NormalizeDouble(MathRound((preco-rp1*ponto)/ticksize)*ticksize,digits);
      if(rp2>0&&lts_rp2>0)preco_par2=NormalizeDouble(MathRound((preco-rp2*ponto)/ticksize)*ticksize,digits);
      if(rp3>0&&lts_rp3>0)preco_par3=NormalizeDouble(MathRound((preco-rp3*ponto)/ticksize)*ticksize,digits);


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::ExecucaoParcial(void)
  {

   if(Buy_opened())
     {
      //---------------------------------Parcial 1--------------------------------------------
      if(preco_par1>0 && lts_rp1>0 && Exec_parc1==false && mysymbol.Bid()>=preco_par1)
        {
         if(mytrade.Sell(lts_rp1,original_symbol))
           {
            if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
              {
               Print("Execução Parcial 1 Enviada com Sucesso");
               Exec_parc1=true;
              }
            else Print("Erro no envio da Execução Parcial 1 :",GetLastError()," ",mytrade.ResultRetcodeDescription());
           }
         else Print("Erro no envio da Execução Parcial 1 :",GetLastError()," ",mytrade.ResultRetcodeDescription());
        }
      //---------------------------------Parcial 2--------------------------------------------

      if(preco_par2>0 && lts_rp2>0 && (Exec_parc1==true || preco_par1==0.0) && Exec_parc2==false && mysymbol.Bid()>=preco_par2)
        {
         if(mytrade.Sell(lts_rp2,original_symbol))
           {
            if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
              {
               Print("Execução Parcial 2 Enviada com Sucesso");
               Exec_parc2=true;
              }
            else Print("Erro no envio da Execução Parcial 2 :",GetLastError()," ",mytrade.ResultRetcodeDescription());
           }
         else Print("Erro no envio da Execução Parcial 2 :",GetLastError()," ",mytrade.ResultRetcodeDescription());
        }

      //---------------------------------Parcial 3--------------------------------------------

      if(preco_par3>0 && lts_rp3>0 && (Exec_parc1==true || preco_par1==0.0) && (Exec_parc2==true || preco_par2==0.0) && Exec_parc3==false && mysymbol.Bid()>=preco_par3)
        {
         if(mytrade.Sell(lts_rp3,original_symbol))
           {
            if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
              {
               Print("Execução Parcial 3 Enviada com Sucesso");
               Exec_parc3=true;
              }
            else Print("Erro no envio da Execução Parcial 3 :",GetLastError()," ",mytrade.ResultRetcodeDescription());
           }
         else Print("Erro no envio da Execução Parcial 3 :",GetLastError()," ",mytrade.ResultRetcodeDescription());
        }

     }//Fim Buy Oppened

   if(Sell_opened())
     {
      //---------------------------------Parcial 1--------------------------------------------
      if(preco_par1>0 && lts_rp1>0 && Exec_parc1==false && mysymbol.Ask()<=preco_par1)
        {
         if(mytrade.Buy(lts_rp1,original_symbol))
           {
            if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
              {
               Print("Execução Parcial 1 Enviada com Sucesso");
               Exec_parc1=true;
              }
            else Print("Erro no envio da Execução Parcial 1 :",GetLastError()," ",mytrade.ResultRetcodeDescription());
           }
         else Print("Erro no envio da Execução Parcial 1 :",GetLastError()," ",mytrade.ResultRetcodeDescription());
        }
      //---------------------------------Parcial 2--------------------------------------------

      if(preco_par2>0 && lts_rp2>0 && (Exec_parc1==true || preco_par1==0.0) && Exec_parc2==false && mysymbol.Ask()<=preco_par2)
        {
         if(mytrade.Buy(lts_rp2,original_symbol))
           {
            if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
              {
               Print("Execução Parcial 2 Enviada com Sucesso");
               Exec_parc2=true;
              }
            else Print("Erro no envio da Execução Parcial 2 :",GetLastError()," ",mytrade.ResultRetcodeDescription());
           }
         else Print("Erro no envio da Execução Parcial 2 :",GetLastError()," ",mytrade.ResultRetcodeDescription());
        }

      //---------------------------------Parcial 3--------------------------------------------

      if(preco_par3>0 && lts_rp3>0 && (Exec_parc1==true || preco_par1==0.0) && (Exec_parc2==true || preco_par2==0.0) && Exec_parc3==false && mysymbol.Ask()<=preco_par3)
        {
         if(mytrade.Buy(lts_rp3,original_symbol))
           {
            if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
              {
               Print("Execução Parcial 3 Enviada com Sucesso");
               Exec_parc3=true;
              }
            else Print("Erro no envio da Execução Parcial 3 :",GetLastError()," ",mytrade.ResultRetcodeDescription());
           }
         else Print("Erro no envio da Execução Parcial 3 :",GetLastError()," ",mytrade.ResultRetcodeDescription());
        }

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::LossDay()
  {
   int cnt=0;
   if(HistorySelect(iTime(_Symbol,PERIOD_D1,0),TimeCurrent()))
     {
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
     }
   return(cnt);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::CalcLot()
  {
   double lots=Lot;
   int loss=LossDay();
   double lot_step=mysymbol.LotsStep();
   if(loss>0 && Multiplier>0){ lots=NormalizeDouble(lots*MathPow(Multiplier,loss),2);}
   return( NormalizeDouble(MathRound(lots/lot_step)*lot_step,2) );
  }
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool MyRobot::GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(prince_handle,3,0,5,PrinceBuy)<=0 || 
         CopyBuffer(prince_handle,4,0,5,PrinceSell)<=0 || 
         CopyHigh(Symbol(),period,0,5,high)<=0 ||
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
   signal=PrinceBuy[1]>0;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal=false;
   signal=PrinceSell[1]>0;
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
//--- if transaction is result of addition of the transaction in history

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(type==TRADE_TRANSACTION_ORDER_UPDATE)
     {
      myorder.Select(trans.order);

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

         if(deal_symbol!=original_symbol) return;
         if(deal_magic==Magic_Number)
           {
            gv.Set("last_deal_time",(double)deal_time);

            if(deal_comment=="BUY"+exp_name)
              {
               DeleteOrders(ORDER_TYPE_SELL_STOP);
               Real_Parc_Buy(deal_volume,deal_price);
              }

            if(deal_comment=="SELL"+exp_name)
              {
               DeleteOrders(ORDER_TYPE_BUY_STOP);
               Real_Parc_Sell(deal_volume,deal_price);
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
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {


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
