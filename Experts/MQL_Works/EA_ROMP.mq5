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
enum EnumAlvo
  {
   x1=1,
   x2=2,
   x3=3
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TipoStop
  {
   StFract,//Stop Topos e Fundos
   StMovel,//Stop Movel
   StNenhum//Nenhum
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Operacoes
  {
   Op1,//1 Operação no Dia
   Op2 //2 Operações no Dia
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

/*                                      //color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel
#define Filelog 
#ifdef Filelog

string filelog=MQLInfoString(MQL_PROGRAM_NAME)+"\\"+_Symbol+"_DIA_"+TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)+"*";
int _kss=StringReplace(filelog,".","_");
int _jss=StringReplace(filelog,":","_");
int _iss=StringReplace(filelog," ","HORA");
int _hss=StringReplace(filelog,"*",".txt");

#endif 
*/

#define CONTROLS_DIALOG_COLOR_BG          borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg

#include <Expert_Class_New.mqh>
MyPanel ExtDialog;

CLabel            m_label[50];

#define LARGURA_PAINEL 260 // Largura Painel
#define ALTURA_PAINEL 150 // Altura Painel




// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
//input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO 
ulong MAGIC_NUMBER;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
sinput string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input int nbarrasinit=5;//Barras para Iniciar Operações
input ENUM_TIMEFRAMES TF_INIT=PERIOD_M1;//TIMEFRAME para Iniciar Operações
input double            StopFinanceiro    = 1000;                    //Valor do stop financeiro
input int               StopInicial       = 70;                      //Amplitude do stop loss, em %
input EnumAlvo          Alvo              = 2;                       //Alvo do gain
input ENUM_TIMEFRAMES TF_FRAC=PERIOD_M5;//TIMEFRAME Fractal
input TipoStop tipostop=StFract;//Tipo de Stop Móvel
input double porc_stop=3;//Porc. Atualizaçõ Stop
sinput string Sentlim="############---------Entrada Limitada------########";//Entrada Limitada
input ushort             VariacaoEntrada=4;                       //Variacao do gatilho de entrada, em ticks
sinput string Stimeentlim="############-------Tempo=Minutos+Segundos------########";//Tempo Execução Ent
input ushort             MinutosExEnt=1;                       //Tempo em Minutos para Executar Ordem de Entrada
input ushort             SegundosExEnt=30;                       //Tempo em Segundos para Executar Ordem de Entrada
input int ticksclose=1;//Ticks nos envios para fechar ordens pentendes
input int nsecondsclose=3;//Segundos para reenviar ordens de fechamento

                          //input int               VariacaoEntrada   = 4;                       //Variacao do gatilho de entrada, em ticks
//input int               VariacaoLoss      = 4;                       //Variacao do preço stop loss, em ticks
sinput string Lucro="###---------------------Usar Lucro/Prejuizo para Fechamento-----------------------#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia

sinput string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="10:00";//Horario Inicial
input string end_hour="16:50";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario
sinput string sdias="FILTRO DOS DIAS DA SEMANA";//Dias da Semana
input bool trade0=true;// Operar Domingo
input bool trade1=true;// Operar Segunda
input bool trade2=true;// Operar Terça
input bool trade3=true;// Operar Quarta
input bool trade4=true;// Operar Quinta
input bool trade5=true;// Operar Sexta
input bool trade6=true;// Operar Sábado

string filelog=MQLInfoString(MQL_PROGRAM_NAME)+"\\"+_Symbol+"_DIA_"+TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)+"*";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//string filelog=MQLInfoString(MQL_PROGRAM_NAME)+"\\"+_Symbol+TimeToString(TimeLocal(),TIME_DATE|TIME_SECONDS)+".txt";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyRobot: public MyExpert
  {
private:
   CChartObjectHLine HLine_Stop,HLine_Take;
   string            currency_symbol;
   double            sl,tp,price_open;
   double            max_dia,min_dia;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   CiFractals       *fractal;
   double            vol_pos,vol_stp,preco_stp;
   double            sl_position,tp_position;
   double            Buyprice,Sellprice;
   double            lote,tamanho,maxima,minima;
   int               val_index;
   double            trail_step;
   double            limit_buy,limit_sell;
   int               tempo_execucao;
   ulong             ticket_comment;
   ushort            contador;
   datetime          hora_envio;
   datetime          hora_envio_buy_lim,hora_envio_sell_lim;
   string            mensagens;
   double            price_order;
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
   bool              IsFinishedBars(int nbars,ENUM_TIMEFRAMES tf);
   int               LastFractalUp();
   int               LastFractalDown();
   void              TrailingFractal();
   void              TrailingStopPerc(double pStep);
   void              OnTradeTransaction(const MqlTradeTransaction &trans,
                                        const MqlTradeRequest &request,
                                        const MqlTradeResult &result);
   void              ExecOrdPend(ENUM_POSITION_TYPE ptype,double price,int time_exec,string ord_comm,int ticks_close,int sleeptime,int tries);
   void              AtualPosStopTake();
   ulong             MyRobot::iMakeExpertId();
   ulong             MyRobot::iMakeHash(string s1,string s2="",string s3="",string s4="",string s5=""
                                        ,string s6="",string s7="",string s8="",string s9="",string s10="");
   bool              WriteToFile(const string fileName,const string text);
   bool              VerificaPreco(double price,ENUM_POSITION_TYPE ptype);

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

   int _kss=StringReplace(filelog,".","_");
   int _jss=StringReplace(filelog,":","_");
   int _iss=StringReplace(filelog," ","HORA");
   int _hss=StringReplace(filelog,"*",".txt");

   EventSetTimer(nsecondsclose+2);
   tempo_execucao=MinutosExEnt*60+SegundosExEnt;
   tradeOn=true;
   setExpName();
   setSymbol(Symbol());
   setOriginalSymbol(Symbol());
   setMagic(MAGIC_NUMBER);
   setPeriod(PERIOD_CURRENT);
/*if(SymbolInfoInteger(original_symbol,SYMBOL_EXPIRATION_MODE)==2)order_time_type=1;
   else order_time_type=0;
   */
   order_time_type=1;
   mysymbol.Name(original_symbol);
   mytrade.SetExpertMagicNumber(Magic_Number);
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
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   setNameGvOrder();

   long curChartID=ChartID();

   fractal=new CiFractals;
   fractal.Create(original_symbol,TF_FRAC);
   fractal.AddToChart(ChartID(),0);

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

   if(porc_stop<=0 || porc_stop>100)
     {
      string erro="A porcentagem de ajuste do Stop Móvel deve ser >0 e <100";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   mensagens="EA Iniciado com Sucesso.";
   WriteToFile(filelog,mensagens);
   Print(mensagens);

   return(INIT_SUCCEEDED);


  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTimer()
  {
   mysymbol.Refresh();
   mysymbol.RefreshRates();
   if(mysymbol.Bid()==0 || mysymbol.Ask()==0)
     {
      mensagens=__FUNCSIG__+" BID ou ASK=0 ";
      WriteToFile(filelog,mensagens);
      Print(mensagens);
      return;
     }

   if(!TerminalInfoInteger(TERMINAL_CONNECTED))return;
   if(mysymbol.Bid()>=mysymbol.Ask())return;
   if(!PosicaoAberta())return;
   AtualPosStopTake();
   Sleep(1000);
   if(TotalOrdens()==0)return;
   double price_ord_sl;
   double price_ord_tp;
   ExecOrdPend(POSITION_TYPE_BUY,gv.Get("maxima")+ticksize,tempo_execucao,"BUY"+exp_name,nsecondsclose,ticksclose*1000,20);
   ExecOrdPend(POSITION_TYPE_SELL,gv.Get("minima")-ticksize,tempo_execucao,"SELL"+exp_name,nsecondsclose,ticksclose*1000,20);

   if(Buy_opened() && !Sell_opened())
     {
      price_ord_sl=OrdemPriceComent("STOP LOSS");
      price_ord_tp=OrdemPriceComent("TAKE PROFIT");

      if(price_ord_sl>0)ExecOrdPend(POSITION_TYPE_SELL,price_ord_sl,tempo_execucao,"STOP LOSS",nsecondsclose,ticksclose*1000,20);
      if(price_ord_tp>0) ExecOrdPend(POSITION_TYPE_SELL,price_ord_tp,tempo_execucao,"TAKE PROFIT",nsecondsclose,ticksclose*1000,20);

     }
   if(Sell_opened() && !Buy_opened())
     {
      price_ord_sl=OrdemPriceComent("STOP LOSS");
      price_ord_tp=OrdemPriceComent("TAKE PROFIT");

      if(price_ord_sl>0)ExecOrdPend(POSITION_TYPE_BUY,price_ord_sl,tempo_execucao,"STOP LOSS",nsecondsclose,ticksclose*1000,20);
      if(price_ord_tp>0) ExecOrdPend(POSITION_TYPE_BUY,price_ord_tp,tempo_execucao,"TAKE PROFIT",nsecondsclose,ticksclose*1000,20);

     }

   for(int i=OrdersTotal()-1;i>=0;i--) // returns the number of current orders
     {
      if(myorder.SelectByIndex(i)) // selects the pending order by index for further access to its properties
        {
         if(myorder.Symbol()!=mysymbol.Name() || myorder.Magic()!=Magic_Number)continue;
         if(myorder.OrderType()!=ORDER_TYPE_BUY_STOP_LIMIT && myorder.OrderType()!=ORDER_TYPE_SELL_STOP_LIMIT)continue;
         if(myorder.OrderType()==ORDER_TYPE_BUY_STOP_LIMIT)
           {
            price_order=OrderGetDouble(ORDER_PRICE_OPEN);
            if(SymbolInfoDouble(_Symbol,SYMBOL_BID)>price_order+2*ticksize)
              {
               DeleteALL();
               CloseALL();
               mensagens=__FUNCSIG__+" Ordem BUY STOP LIMIT aberta não executada. Fechando Posições."+"\n"
                         +"BID "+DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits)+
                         " Preço da Ordem "+DoubleToString(price_order,_Digits);
               WriteToFile(filelog,mensagens);
               Print(mensagens);
               return;
              }

           }
         if(myorder.OrderType()==ORDER_TYPE_SELL_STOP_LIMIT)
           {
            price_order=OrderGetDouble(ORDER_PRICE_OPEN);
            if(SymbolInfoDouble(_Symbol,SYMBOL_ASK)<price_order-2*ticksize)
              {
               DeleteALL();
               CloseALL();
               mensagens=__FUNCSIG__+" Ordem SELL STOP LIMIT aberta não executada. Fechando Posições."+"\n"
                         +"ASK "+DoubleToString(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits)+
                         " Preço da Ordem "+DoubleToString(price_order,_Digits);
               WriteToFile(filelog,mensagens);
               Print(mensagens);
               return;
              }

           }

        }//Order Select
     }//Fim for

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
   delete(fractal);
   DeletaIndicadores();
   EventKillTimer();
   mensagens="EA Finalizado ou Reiniciado.";
   WriteToFile(filelog,mensagens);
   Print(mensagens);

  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTick(void)
  {

   if(!TerminalInfoInteger(TERMINAL_CONNECTED))return;

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
   if(gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      filelog=MQLInfoString(MQL_PROGRAM_NAME)+"\\"+_Symbol+"_DIA_"+TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)+"*";
      int _kss=StringReplace(filelog,".","_");
      int _jss=StringReplace(filelog,":","_");
      int _iss=StringReplace(filelog," ","HORA");
      int _hss=StringReplace(filelog,"*",".txt");
     }

   gv.Set("gv_today_prev",gv.Get("gv_today"));

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   fractal.Refresh();
   bid=mysymbol.Bid();
   ask=mysymbol.Ask();
   if(bid==0 || ask==0)
     {
      mensagens=__FUNCSIG__+" BID ou ASK=0 : "+DoubleToString(bid,_Digits)+" "+DoubleToString(ask,_Digits);
      WriteToFile(filelog,mensagens);
      Print(mensagens);
      return;
     }

   if(bid>=ask)return;//Leilão

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   if(GetIndValue())
     {
      mensagens=__FUNCSIG__+"Error in obtain indicators buffers or price rates";
      WriteToFile(filelog,mensagens);
      Print(mensagens);
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
   if(!PosicaoAberta() && OrdersTotal()>0)DeleteOrdersExEntry();

   if(tradeOn && timerOn)

     {// inicio Trade On
      // SegurancaPos(10);

      if(Bar_NovaBarra.CheckNewBar(Symbol(),TF_INIT))
        {
         if(IsFinishedBars(nbarrasinit,TF_INIT))
           {
            maxima=iHigh(original_symbol,PERIOD_D1,0);
            minima=iLow(original_symbol,PERIOD_D1,0);
            gv.Set("maxima",maxima);
            gv.Set("minima",minima);
            Buyprice=gv.Get("maxima")+ticksize;
            Sellprice=gv.Get("minima")-ticksize;
            tamanho=Buyprice-Sellprice;
            gv.Set("tamanho",tamanho);
            trail_step=NormalizeDouble(MathRound(gv.Get("tamanho")*0.1/ticksize)*ticksize,digits);
            lote=NormalizeDouble(MathRound((StopFinanceiro/gv.Get("tamanho"))/mysymbol.LotsStep())*mysymbol.LotsStep(),2);
            sl_position=Buyprice-(gv.Get("tamanho") *0.01*StopInicial);
            sl_position=NormalizeDouble(MathRound(sl_position/ticksize)*ticksize,digits);
            tp_position=Buyprice+(gv.Get("tamanho")*Alvo);
            tp_position=NormalizeDouble(MathRound(tp_position/ticksize)*ticksize,digits);
            limit_buy=NormalizeDouble(Buyprice+ticksize*VariacaoEntrada,digits);

            mensagens=__FUNCSIG__+" MAXIMA: "+DoubleToString(maxima,_Digits)+"\n"+
                      " MINIMA: "+DoubleToString(minima,_Digits)+"\n"+
                      " TAMANHO: "+DoubleToString(tamanho,_Digits)+"\n"+
                      " BUYPRICE: "+DoubleToString(Buyprice,_Digits)+"\n"+
                      " SELLPRICE: "+DoubleToString(Sellprice,_Digits)+"\n";
            WriteToFile(filelog,mensagens);
            Print(mensagens);

            mensagens=__FUNCSIG__+" STOP LOSS BUY : "+DoubleToString(sl_position,_Digits)+"\n"+
                      " TAKE PROFIT BUY: "+DoubleToString(tp_position,_Digits)+"\n";
            WriteToFile(filelog,mensagens);
            Print(mensagens);

            if(Buyprice>ask)
              {

               if(mytrade.OrderOpen(_Symbol,ORDER_TYPE_BUY_STOP_LIMIT,lote,limit_buy,Buyprice,0,0,order_time_type,0,"BUY"+exp_name))
                 {
                  if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                    {
                     gv.Set("cp_tick",(double)mytrade.ResultOrder());
                     mensagens=__FUNCSIG__+" Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
                     WriteToFile(filelog,mensagens);
                     Print(mensagens);
                    }
                  else
                    {
                     mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                     WriteToFile(filelog,mensagens);
                     Print(mensagens);
                    }
                 }
               else
                 {
                  mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                 }
              }
            else
              {
               limit_buy=mysymbol.NormalizePrice(ask+ticksize*VariacaoEntrada);
               if(mytrade.BuyLimit(lote,limit_buy,original_symbol,0,0,order_time_type,0,"BUY"+exp_name))
                 {
                  if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                    {
                     gv.Set("cp_tick",(double)mytrade.ResultOrder());
                     mensagens=__FUNCSIG__+" Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
                     WriteToFile(filelog,mensagens);
                     Print(mensagens);
                    }
                  else
                    {
                     mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                     WriteToFile(filelog,mensagens);
                     Print(mensagens);
                    }
                 }
               else
                 {
                  mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                 }
              }
            sl_position=Sellprice+(gv.Get("tamanho") *0.01*StopInicial);
            sl_position=NormalizeDouble(MathRound(sl_position/ticksize)*ticksize,digits);
            tp_position=Sellprice-(gv.Get("tamanho")*Alvo);
            tp_position=NormalizeDouble(MathRound(tp_position/ticksize)*ticksize,digits);
            limit_sell=NormalizeDouble(Sellprice-ticksize*VariacaoEntrada,digits);
            mensagens=__FUNCSIG__+" STOP LOSS SELL : "+DoubleToString(sl_position,_Digits)+"\n"+
                      " TAKE PROFIT SELL: "+DoubleToString(tp_position,_Digits)+"\n";
            WriteToFile(filelog,mensagens);
            Print(mensagens);

            if(Sellprice<bid)
              {
               if(mytrade.OrderOpen(_Symbol,ORDER_TYPE_SELL_STOP_LIMIT,lote,limit_sell,Sellprice,0,0,order_time_type,0,"SELL"+exp_name))
                 {
                  if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                    {
                     gv.Set("vd_tick",(double)mytrade.ResultOrder());
                     mensagens=__FUNCSIG__+" Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
                     WriteToFile(filelog,mensagens);
                     Print(mensagens);
                    }
                  else
                    {
                     mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                     WriteToFile(filelog,mensagens);
                     Print(mensagens);
                    }
                 }
               else
                 {
                  mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                 }
              }

            else
              {
               limit_sell=mysymbol.NormalizePrice(bid-ticksize*VariacaoEntrada);
               if(mytrade.SellLimit(lote,limit_sell,original_symbol,0,0,order_time_type,0,"SELL"+exp_name))
                 {
                  if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                    {
                     gv.Set("vd_tick",(double)mytrade.ResultOrder());
                     mensagens=__FUNCSIG__+" Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
                     WriteToFile(filelog,mensagens);
                     Print(mensagens);
                    }
                  else
                    {
                     mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                     WriteToFile(filelog,mensagens);
                     Print(mensagens);
                    }
                 }
               else
                 {
                  mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                 }
              }

           }
         if(PosicaoAberta())
           {
            if(tipostop==StFract)TrailingFractal();
           }

        }//End NewBar

      if(PosicaoAberta())
        {
         if(tipostop==StMovel)TrailingStopPerc(trail_step);
        }

     }//End Trade On

  }//Fim Ontick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MyRobot::IsFinishedBars(int nbars,ENUM_TIMEFRAMES tf)
  {
   datetime hora0=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+"00:00");
   int barras=Bars(_Symbol,tf,hora0,TimeCurrent());
   if(barras==nbars+1)return true;
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MyRobot::ExecOrdPend(ENUM_POSITION_TYPE ptype,double price,int time_exec,string ord_comm,int ticks_close,int sleeptime,int tries)
  {
   int cont;
   double _Buyprice,_Sellprice;
   bool condition_buy,condition_sell;
   bool condition_time_buy,condition_time_sell;
   bool ordem_aberta=OrdemAbertaComent(ord_comm);
   if(!ordem_aberta)return;

   mysymbol.Refresh();
   mysymbol.RefreshRates();
   if(mysymbol.Bid()==0 || mysymbol.Ask()==0)
     {
      mensagens=__FUNCSIG__+" BID ou ASK=0 ";
      WriteToFile(filelog,mensagens);
      Print(mensagens);
      return;
     }
   if(!TerminalInfoInteger(TERMINAL_CONNECTED))return;
   if(mysymbol.Bid()>=mysymbol.Ask())return;

   ticket_comment=GetTickOrdComent(ord_comm);
   if(!OrderSelect(ticket_comment))return;
   if(OrderGetInteger(ORDER_TYPE)!=ORDER_TYPE_BUY_LIMIT && OrderGetInteger(ORDER_TYPE)!=ORDER_TYPE_SELL_LIMIT)return;

   if(ptype==POSITION_TYPE_BUY)
     {
      if(ord_comm!="TAKE PROFIT") condition_buy=iClose(original_symbol,PERIOD_CURRENT,0)>price;
      else
        {
         condition_buy=iClose(original_symbol,PERIOD_CURRENT,0)<=price+10*ticksize && iLow(original_symbol,PERIOD_M3,0)<=price;
        }

      if(condition_buy && ordem_aberta)
        {
         ticket_comment=GetTickOrdComent(ord_comm);
         myorder.Select(ticket_comment);
         if(ord_comm!="TAKE PROFIT") condition_time_buy=TimeCurrent()-hora_envio_buy_lim>=time_exec;
         else condition_time_buy=true;
         if(condition_time_buy)
           {
            cont=0;
            while(OrdemAbertaComent(ord_comm) && !IsStopped() && cont<tries)
              {
               _Buyprice=mysymbol.NormalizePrice(mysymbol.Ask()+(ticks_close*(cont+1))*ticksize);
               if(!VerificaPreco(_Buyprice,POSITION_TYPE_BUY))
                 {
                  mensagens=__FUNCSIG__+" Preço "+DoubleToString(_Buyprice,_Digits)+" muito distante do range. Ordem não enviada";
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                  break;
                 }

               mensagens=__FUNCSIG__+" Buyprice "+DoubleToString(_Buyprice,_Digits)+" Ask "+DoubleToString(mysymbol.Ask(),_Digits);
               WriteToFile(filelog,mensagens);
               Print(mensagens);

               if(mytrade.OrderModify(ticket_comment,_Buyprice,0,0,order_time_type,0,0))
                 {
                  mensagens=__FUNCSIG__+" Ordem Modificada com sucesso ";
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                 }
               else
                 {
                  mensagens=__FUNCSIG__+" Erro Modificar Ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                 }
               Sleep(sleeptime);
               cont+=1;
              }
            if(OrdemAbertaComent(ord_comm) && cont==tries)
              {
               CloseALL();
               DeleteALL();
               mensagens=__FUNCSIG__+" EA não conseguiu executar a ordem limitada. Fechando Posições";
               WriteToFile(filelog,mensagens);
               Print(mensagens);
              }
           }
        }
     }
   if(ptype==POSITION_TYPE_SELL)
     {

      if(ord_comm!="TAKE PROFIT") condition_sell=iClose(original_symbol,PERIOD_CURRENT,0)<price;
      else
        {
         condition_sell=iClose(original_symbol,PERIOD_CURRENT,0)>=price-10*ticksize && iHigh(original_symbol,PERIOD_M3,0)>=price;
        }

      if(condition_sell && ordem_aberta)
        {
         ticket_comment=GetTickOrdComent(ord_comm);
         myorder.Select(ticket_comment);
         datetime timecurrent=TimeCurrent();
         if(ord_comm!="TAKE PROFIT") condition_time_sell=TimeCurrent()-hora_envio_sell_lim>=time_exec;
         else condition_time_sell=true;

         if(condition_time_sell)
           {
            cont=0;
            while(OrdemAbertaComent(ord_comm) && !IsStopped() && cont<tries)
              {
               _Sellprice=mysymbol.NormalizePrice(mysymbol.Bid()-(ticks_close*(cont+1))*ticksize);
               if(!VerificaPreco(_Sellprice,POSITION_TYPE_SELL))
                 {
                  mensagens=__FUNCSIG__+" Preço "+DoubleToString(_Sellprice,_Digits)+" muito distante do range. Ordem não enviada";
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                  break;
                 }
               mensagens=__FUNCSIG__+" Sellprice "+DoubleToString(_Sellprice,_Digits)+" BID "+DoubleToString(mysymbol.Bid(),_Digits);
               WriteToFile(filelog,mensagens);
               Print(mensagens);

               if(mytrade.OrderModify(ticket_comment,_Sellprice,0,0,order_time_type,0,0))
                 {
                  mensagens=__FUNCSIG__+" Ordem Modificada com sucesso";
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                 }
               else
                 {
                  mensagens=__FUNCSIG__+" Erro Modificar Ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                 }
               Sleep(sleeptime);
               cont+=1;
              }
            if(OrdemAbertaComent(ord_comm) && cont==tries)
              {
               CloseALL();
               DeleteALL();
               mensagens=__FUNCSIG__+" EA não conseguiu executar a ordem limitada. Fechando Posições";
               WriteToFile(filelog,mensagens);
               Print(mensagens);
              }

           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

bool MyRobot::WriteToFile(const string fileName,const string text)
  {
   ResetLastError();
   string fullText=TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS)+"--"+Symbol()+"--:"+text;
   int fileHandle=FileOpen(fileName,FILE_TXT|FILE_READ|FILE_WRITE);
   bool result=true;
//---
   if(fileHandle!=INVALID_HANDLE)
     {
      //--- tentar colocar o ponteiro do arquivo no arquivo final            
      if(!FileSeek(fileHandle,0,SEEK_END))
        {
         Print("Logger: FileSeek() is failed, error #",GetLastError(),"; text = \"",fullText,"\"; fileName = \"",fileName,"\"");
         result=false;
        }
      //--- tentar registrar o texto no arquivo
      if(result)
        {
         if(FileWrite(fileHandle,fullText)==0)
           {
            Print("Logger: FileWrite() is failed, error #",GetLastError(),"; text = \"",fullText,"\"; fileName = \"",fileName,"\"");
            result=false;
           }
        }
      //---
      FileClose(fileHandle);
     }
   else
     {
      Print("Logger: FileOpen() is failed, error #",GetLastError(),"; text = \"",fullText,"\"; fileName = \"",fileName,"\"");
      result=false;
     }
//---
   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::LastFractalUp()
  {
   int i=1;
   while(fractal.Upper(i)==EMPTY_VALUE && !IsStopped())i+=1;
   return i;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::LastFractalDown()
  {
   int i=1;
   while(fractal.Lower(i)==EMPTY_VALUE && !IsStopped())i+=1;
   return i;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::VerificaPreco(double price,ENUM_POSITION_TYPE ptype)
  {
   bool signal=true;
   double _high=iHigh(original_symbol,PERIOD_D1,0);
   double _low=iLow(original_symbol,PERIOD_D1,0);
   double range=_high-_low;
   if(ptype==POSITION_TYPE_BUY)
     {
      if(price>_high+5*range)signal=false;
     }

   if(ptype==POSITION_TYPE_SELL)
     {
      if(price<_low-5*range)signal=false;
     }
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::TrailingFractal()
  {
   myposition.Select(original_symbol);
   ENUM_POSITION_TYPE postype=myposition.PositionType();
   double newstop,limit_price;
   if(postype==POSITION_TYPE_BUY)
     {
      if(iTime(original_symbol,TF_FRAC,LastFractalDown())<iTime(original_symbol,PERIOD_D1,0))return;
      newstop=fractal.Lower(LastFractalDown());
      newstop=NormalizeDouble(MathRound(newstop/ticksize)*ticksize,digits);
      sl_position=OrdemPriceComent("STOP LOSS");
      if((newstop>sl_position || sl_position==0.0) && newstop<mysymbol.Bid())
        {
         if(OrdemAberta(ORDER_TYPE_SELL_STOP_LIMIT))limit_price=mysymbol.NormalizePrice(newstop-ticksize*VariacaoEntrada);
         else limit_price=0.0;
         mytrade.OrderModify(GetTickOrdComent("STOP LOSS"),newstop,0,0,order_time_type,0,limit_price);
        }
      return;
     }
   if(postype==POSITION_TYPE_SELL)
     {
      if(iTime(original_symbol,TF_FRAC,LastFractalUp())<iTime(original_symbol,PERIOD_D1,0))return;
      newstop=fractal.Upper(LastFractalUp());
      newstop=NormalizeDouble(MathRound(newstop/ticksize)*ticksize,digits);
      sl_position=OrdemPriceComent("STOP LOSS");
      if((newstop<sl_position || sl_position==0.0) && newstop>mysymbol.Ask())
        {
         if(OrdemAberta(ORDER_TYPE_BUY_STOP_LIMIT))limit_price=mysymbol.NormalizePrice(newstop+ticksize*VariacaoEntrada);
         else limit_price=0.0;
         mytrade.OrderModify(GetTickOrdComent("STOP LOSS"),newstop,0,0,order_time_type,0,limit_price);
        }
      return;
     }

  }
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
ulong MyRobot::iMakeExpertId()
  {
/*   MathSrand(GetTickCount());
   string ss[7];
   for(int i=0;i<7;i++)ss[i]=IntegerToString(MathRand());
return( iMakeHash(_Symbol,EnumToString(_Period),MQLInfoString(MQL_PROGRAM_NAME),
          ss[0],ss[1],ss[2],ss[3],ss[4],ss[5],ss[6]));
*/
   return( iMakeHash(_Symbol,EnumToString(_Period),MQLInfoString(MQL_PROGRAM_NAME)));


  }
//+------------------------------------------------------------------+
//
ulong MyRobot::iMakeHash(string s1,string s2="",string s3="",string s4="",string s5=""
                         ,string s6="",string s7="",string s8="",string s9="",string s10="")
  {
/*
  Produce 32bit int hash code from  a string composed of up to TEN concatenated input strings.
  WebRef: http://www.cse.yorku.ca/~oz/hash.html
  KeyWrd: "djb2"
  FirstParaOnPage:
  "  Hash Functions
  A comprehensive collection of hash functions, a hash visualiser and some test results [see Mckenzie
  et al. Selecting a Hashing Algorithm, SP&E 20(2):209-224, Feb 1990] will be available someday. If
  you just want to have a good hash function, and cannot wait, djb2 is one of the best string hash
  functions i know. it has excellent distribution and speed on many different sets of keys and table
  sizes. you are not likely to do better with one of the "well known" functions such as PJW, K&R[1],
  etc. Also see tpop pp. 126 for graphing hash functions.
  "

  NOTES: 
  0. WARNING - mql4 strings maxlen=255 so... unless code changed to deal with up to 10 string parameters
     the total length of contactenated string must be <=255
  1. C source uses "unsigned [char|long]", not in MQL4 syntax
  2. When you hash a value, you cannot 'unhash' it. Hashing is a one-way process.
     Using traditional symetric encryption techniques (such as Triple-DES) provide the reversible encryption behaviour you require.
     Ref:http://forums.asp.net/t/886426.aspx subj:Unhash password when using NT Security poster:Participant
  //
  Downside?
  original code uses UNSIGNED - MQL4 not support this, presume could use type double and then cast back to type int.
*/
   string s;
   int k=StringConcatenate(s,s1,s2,s3,s4,s5,s6,s7,s8,s9,s10);
   int iHash = 5381;
   int iLast = StringLen(s)-1;
   int iPos=0;

   while(iPos<=iLast) //while (c = *str++)	[ consume str bytes until EOS hit {myWord! isn't C concise! Pity MQL4 is"!"} ]
     {
      //original C code: hash = ((hash << 5) + hash) + c; /* hash * 33 + c */
      iHash=((iHash<<5)+iHash)+StringGetCharacter(s,iPos);      //StringGetChar() returns int
      iPos++;
     }
   return(MathAbs(iHash));
  }//+------------------------------------------------------------------+
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
//--- if transaction is result of addition of the transaction in history

   mensagens="\n---===Transaction===---"+
             "\n"+"Ticket of the deal: "+DoubleToString(trans.deal,_Digits)+"\n"+
             "Type of the deal: "+EnumToString(trans.deal_type)+"\n"+
             "Ticket of the order: "+IntegerToString(trans.order)+"\n"+
             "Status of the order: "+EnumToString(trans.order_state)+"\n"+
             "Type of the order: "+EnumToString(trans.order_type)+"\n"+
             "Price: "+DoubleToString(trans.price,_Digits)+"\n"+
             "Level of Stop Loss: ."+DoubleToString(trans.price_sl,_Digits)+"\n"+
             "Level of Take Profit: "+DoubleToString(trans.price_tp,_Digits)+"\n"+
             "Price that triggers the Stop Limit order: "+DoubleToString(trans.price_trigger,_Digits)+"\n"+
             "Trade symbol: "+trans.symbol+"\n"+
             "Pending order expiration time: "+TimeToString(trans.time_expiration)+"\n"+
             "Order expiration type: "+EnumToString(trans.time_type)+"\n"+
             "Type of the trade transaction: "+EnumToString(trans.type)+"\n"+
             "Volume in lots: "+DoubleToString(trans.volume,2);
   WriteToFile(filelog,mensagens);
   Print(mensagens);

//--- if a request was sent
   if(trans.type==TRADE_TRANSACTION_REQUEST)
     {
      //--- displays information on the request
      mensagens="\n---===Request===---"+"\n"+
                "Type of the trade operation: "+EnumToString(request.action)+"\n"+
                "Comment to the order: "+request.comment+"\n"+
                "Deviation from the requested price: "+DoubleToString(request.deviation,_Digits)+"\n"+
                "Order expiration time: "+TimeToString(request.expiration)+"\n"+
                "Magic number of the EA: "+IntegerToString(request.magic)+"\n"+
                "Ticket of the order: "+IntegerToString(request.order)+"\n"+
                "Price: "+DoubleToString(request.price,_Digits)+"\n"+
                "Stop Loss level of the order: "+DoubleToString(request.sl,_Digits)+"\n"+
                "Take Profit level of the order: "+DoubleToString(request.tp)+"\n"+
                "StopLimit level of the order: "+DoubleToString(request.stoplimit,_Digits)+"\n"+
                "Trade symbol: "+request.symbol+"\n"+
                "Type of the order: "+EnumToString(request.type)+"\n"+
                "Order execution type: "+EnumToString(request.type_filling)+"\n"+
                "Order expiration type: "+EnumToString(request.type_time)+"\n"+
                "Volume in lots: "+DoubleToString(request.volume,2)+"\n";
      WriteToFile(filelog,mensagens);
      Print(mensagens);

      //--- displays information about result
      mensagens="\n---===Result===---"+"\n"+
                "Code of the operation result: "+IntegerToString(result.retcode)+"\n"+
                "Ticket of the deal: "+IntegerToString(result.deal)+"\n"+
                "Ticket of the order: "+IntegerToString(result.order)+"\n"+
                "Volume of the deal: "+ DoubleToString(result.volume,2) + "\n" +
                "Price of the deal: " + DoubleToString(result.price,_Digits) + "\n" +
                "Bid: " + DoubleToString(result.bid, _Digits) + "\n" +
                "Ask: " + DoubleToString(result.ask, _Digits) + "\n" +
                "Comment to the operation: "+result.comment+"\n"+
                "Request ID: "+IntegerToString(result.request_id)+"\n";
      WriteToFile(filelog,mensagens);
      Print(mensagens);

     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(type==TRADE_TRANSACTION_ORDER_UPDATE)
     {
      myorder.Select(trans.order);
      if(myorder.OrderType()==ORDER_TYPE_BUY_LIMIT) hora_envio_buy_lim=TimeCurrent();
      if(myorder.OrderType()==ORDER_TYPE_SELL_LIMIT) hora_envio_sell_lim=TimeCurrent();
     }

   if(type==TRADE_TRANSACTION_HISTORY_UPDATE)
     {
      myhistory.Ticket(trans.order);
      if(myhistory.Comment()=="TAKE PROFIT")
        {
         if(myhistory.OrderType()==ORDER_TYPE_BUY_LIMIT) hora_envio_buy_lim=TimeCurrent();
         if(myhistory.OrderType()==ORDER_TYPE_SELL_LIMIT) hora_envio_sell_lim=TimeCurrent();
        }
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
               AtualPosStopTake();
              }

            if(deal_comment=="SELL"+exp_name)
              {
               DeleteOrdersComment("BUY"+exp_name);
               AtualPosStopTake();
              }
            if((deal_type==DEAL_TYPE_BUY || deal_type==DEAL_TYPE_SELL) && (deal_entry==DEAL_ENTRY_OUT || deal_entry==DEAL_ENTRY_OUT_BY))
              {
               if(deal_profit<0)
                 {
                  mensagens="Saída por STOP LOSS";
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                  DeleteALL();
                 }
               if(deal_profit>0)
                 {
                  mensagens="Saída no GAIN";
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                  DeleteALL();
                 }
              }

            lucro_orders=LucroOrdens();
            lucro_orders_mes = LucroOrdensMes();
            lucro_orders_sem = LucroOrdensSemana();

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

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::AtualPosStopTake()
  {
   double vol_stop,vol_take,_vol_pos;
   double _buyprice,_sellprice,_SL,_TP;
   double _limit_stp_buy,_limit_stp_sell;
   double pos_price;
   ulong tick_order;
   if(!PosicaoAberta())return;
   mysymbol.Refresh();
   mysymbol.RefreshRates();
   if(mysymbol.Bid()==0 || mysymbol.Ask()==0)
     {
      mensagens=__FUNCSIG__+" BID ou ASK=0 ";
      WriteToFile(filelog,mensagens);
      Print(mensagens);
      return;
     }
   if(mysymbol.Bid()>=mysymbol.Ask())return;

   if(!TerminalInfoInteger(TERMINAL_CONNECTED))return;


   if(Buy_opened() && !Sell_opened())
     {
      pos_price=PrecoMedio(POSITION_TYPE_BUY);
      _vol_pos = VolPosType(POSITION_TYPE_BUY);
      vol_stop = VolumeOrdensCmt("STOP LOSS");
      vol_take=VolumeOrdensCmt("TAKE PROFIT");
      _buyprice=mysymbol.NormalizePrice(MathRound(pos_price/ticksize)*ticksize);
      // if(!OrdemAbertaComent("STOP LOSS"))
      if(vol_stop==0.0)
        {
         _SL=_buyprice-(gv.Get("tamanho") *0.01*StopInicial);
         _SL=mysymbol.NormalizePrice(MathRound(_SL/ticksize)*ticksize);
        }
      else _SL=OrdemPriceComent("STOP LOSS");
      _TP=_buyprice+(gv.Get("tamanho")*Alvo);
      _TP=mysymbol.NormalizePrice(MathRound(_TP/ticksize)*ticksize);

      if(vol_take!=_vol_pos)
        {
         mensagens=__FUNCSIG__+" Posição Selecionada. Ticket: "+IntegerToString(PositionGetInteger(POSITION_TICKET))+"\n"+
                   "Preço de Abertura da Posição: "+DoubleToString(pos_price,_Digits)+"\n"+
                   "Enviando ou Atualizando ordem de Take Profit :"+"Preço da Posição: "+DoubleToString(_buyprice,_Digits)+"\n"+
                   "Tamanho: "+DoubleToString(gv.Get("tamanho"),_Digits)+" Alvo: "+EnumToString(Alvo)+"\n"+
                   "Take Profit solicitado para envio: "+DoubleToString(_TP,_Digits);
         WriteToFile(filelog,mensagens);
         Print(mensagens);

         tick_order=GetTickOrdComent("TAKE PROFIT");
         if(!OrderSelect(tick_order) && tick_order>0)Print("Ordem não selecionada");
         if((tick_order>0 && OrderGetInteger(ORDER_STATE)!=ORDER_STATE_PARTIAL) || vol_take==0.0)
           {
            DeleteOrdersComment("TAKE PROFIT");
            if(!VerificaPreco(_TP,POSITION_TYPE_SELL))
              {

               mensagens=__FUNCSIG__+" Preço "+DoubleToString(_TP,_Digits)+" muito distante do range. Ordem não enviada"+"\n"+
                         "Ajustando preço de envio do Take Profit";
               WriteToFile(filelog,mensagens);
               Print(mensagens);
               _TP=gv.Get("maxima")+ticksize+(gv.Get("tamanho")*Alvo);
               _TP=mysymbol.NormalizePrice(_TP);
               mensagens=__FUNCSIG__+" Novo TP ajustao"+DoubleToString(_TP,_Digits);
               WriteToFile(filelog,mensagens);
               Print(mensagens);

              }
            mensagens=__FUNCSIG__+" Position Price Open "+DoubleToString(pos_price,_Digits)+" TP "+DoubleToString(_TP,_Digits);
            WriteToFile(filelog,mensagens);
            Print(mensagens);
            if(mytrade.SellLimit(_vol_pos,_TP,original_symbol,0,0,order_time_type,0,"TAKE PROFIT"))
              {
               if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                 {
                  gv.Set("tp_vd_tick",(double)mytrade.ResultOrder());
                  mensagens=__FUNCSIG__+" Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                 }
               else
                 {
                  mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                 }

              }
            else
              {
               mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
               WriteToFile(filelog,mensagens);
               Print(mensagens);
              }
           }//Fim Order State
        }

      if(vol_stop!=_vol_pos)
        {
         tick_order=GetTickOrdComent("STOP LOSS");
         if(!OrderSelect(tick_order) && tick_order>0)Print("Ordem não selecionada");
         bool tipo_ordem=OrderGetInteger(ORDER_TYPE)!=ORDER_TYPE_BUY_LIMIT && OrderGetInteger(ORDER_TYPE)!=ORDER_TYPE_SELL_LIMIT;

         if((tick_order>0 && OrderGetInteger(ORDER_STATE)!=ORDER_STATE_PARTIAL && tipo_ordem) || vol_stop==0.0)
           {

            DeleteOrdersComment("STOP LOSS");
            _limit_stp_sell=mysymbol.NormalizePrice(_SL-ticksize*VariacaoEntrada);

            mensagens=__FUNCSIG__+" Posição Selecionada. Ticket: "+IntegerToString(PositionGetInteger(POSITION_TICKET))+"\n"+
                      "Preço de Abertura da Posição: "+DoubleToString(pos_price,_Digits)+"\n"+
                      "Enviando ou Atualizando ordem de Stop Loss :"+"Preço da Posição: "+DoubleToString(_buyprice,_Digits)+"\n"+
                      "Tamanho: "+DoubleToString(gv.Get("tamanho"),_Digits)+" Alvo: "+EnumToString(Alvo)+"\n"+
                      "Stop Loss solicitado para envio: "+DoubleToString(_SL,_Digits)+"\n"+
                      "Limit sell price: "+DoubleToString(_limit_stp_sell,_Digits);
            WriteToFile(filelog,mensagens);
            Print(mensagens);

            if(!VerificaPreco(_limit_stp_sell,POSITION_TYPE_SELL))
              {
               mensagens=__FUNCSIG__+" Preço "+DoubleToString(_limit_stp_sell,_Digits)+" muito distante do range. Ordem não enviada."+"\n"+
                         "Ajustando Stop Loss";
               WriteToFile(filelog,mensagens);
               Print(mensagens);
               _SL=gv.Get("maxima")+ticksize-(gv.Get("tamanho") *0.01*StopInicial);
               _SL=mysymbol.NormalizePrice(_SL);
               _limit_stp_sell=mysymbol.NormalizePrice(_SL-ticksize*VariacaoEntrada);
               mensagens=__FUNCSIG__+" Novo SL ajustao"+DoubleToString(_SL,_Digits)+"\n"+
                         "Limit sell: "+DoubleToString(_limit_stp_sell,_Digits);
               WriteToFile(filelog,mensagens);
               Print(mensagens);
              }
            if(_SL<mysymbol.Bid())
              {
               // if(mytrade.BuyStop(lote,Buyprice,original_symbol,sl_position,tp_position,order_time_type,0,"BUY"+exp_name))
               mensagens=__FUNCSIG__+" Position Price Open "+DoubleToString(pos_price,_Digits)+" SL "+DoubleToString(_SL,_Digits)+
                         " limit sell "+DoubleToString(_limit_stp_sell,_Digits);
               WriteToFile(filelog,mensagens);
               Print(mensagens);

               if(mytrade.OrderOpen(_Symbol,ORDER_TYPE_SELL_STOP_LIMIT,_vol_pos,_limit_stp_sell,_SL,0,0,order_time_type,0,"STOP LOSS"))
                 {
                  if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                    {
                     mensagens=__FUNCSIG__+" Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
                     WriteToFile(filelog,mensagens);
                     Print(mensagens);
                    }
                  else
                    {
                     mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                     WriteToFile(filelog,mensagens);
                     Print(mensagens);
                    }
                 }
               else
                 {
                  mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                 }
              }
            else
              {
               _limit_stp_sell=mysymbol.NormalizePrice(mysymbol.Bid()-ticksize*VariacaoEntrada);

               mensagens=__FUNCSIG__+" Posição Selecionada. Ticket: "+IntegerToString(PositionGetInteger(POSITION_TICKET))+"\n"+
                         "Preço de Abertura da Posição: "+DoubleToString(pos_price,_Digits)+"\n"+
                         "Enviando ou Atualizando ordem de Stop Loss :"+"Preço da Posição: "+DoubleToString(_buyprice,_Digits)+"\n"+
                         "Tamanho: "+DoubleToString(gv.Get("tamanho"),_Digits)+" Alvo: "+EnumToString(Alvo)+"\n"+
                         "Stop Loss solicitado para envio: "+DoubleToString(_SL,_Digits)+"\n"+
                         "Limit sell price: "+DoubleToString(_limit_stp_sell,_Digits);
               WriteToFile(filelog,mensagens);
               Print(mensagens);

               mensagens=__FUNCSIG__+"Position Price Open "+DoubleToString(pos_price,_Digits)+" BID "+DoubleToString(mysymbol.Bid(),_Digits)+
                         " limit sell "+DoubleToString(_limit_stp_sell,_Digits);
               WriteToFile(filelog,mensagens);
               Print(mensagens);

               if(!VerificaPreco(_limit_stp_sell,POSITION_TYPE_SELL))
                 {
                  mensagens=__FUNCSIG__+" Preço "+DoubleToString(_limit_stp_sell,_Digits)+" muito distante do range. Ordem não enviada"+"\n"+
                            "Ajustando Limit Sell";
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                  _limit_stp_sell=mysymbol.NormalizePrice(SymbolInfoDouble(_Symbol,SYMBOL_BID)-ticksize*VariacaoEntrada);
                  mensagens=__FUNCSIG__+"Novo limit sell "+DoubleToString(_limit_stp_sell,_Digits);
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);

                 }

               if(mytrade.SellLimit(_vol_pos,_limit_stp_sell,original_symbol,0,0,order_time_type,0,"STOP LOSS"))
                 {
                  if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                    {
                     mensagens=__FUNCSIG__+" Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
                     WriteToFile(filelog,mensagens);
                     Print(mensagens);
                    }
                  else
                    {
                     mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                     WriteToFile(filelog,mensagens);
                     Print(mensagens);
                    }
                 }
               else
                 {
                  mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                 }

              }
           }//Fim Order State
        }

     }
   if(Sell_opened() && !Buy_opened())
     {
      pos_price=PrecoMedio(POSITION_TYPE_SELL);
      _vol_pos = VolPosType(POSITION_TYPE_SELL);
      vol_stop = VolumeOrdensCmt("STOP LOSS");
      vol_take=VolumeOrdensCmt("TAKE PROFIT");
      _sellprice=mysymbol.NormalizePrice(MathRound(pos_price/ticksize)*ticksize);
      if(vol_stop==0.0)
        {
         _SL=_sellprice+(gv.Get("tamanho") *0.01*StopInicial);
         _SL=mysymbol.NormalizePrice(MathRound(_SL/ticksize)*ticksize);
        }
      else _SL=OrdemPriceComent("STOP LOSS");

      _TP=_sellprice-(gv.Get("tamanho")*Alvo);
      _TP=mysymbol.NormalizePrice(MathRound(_TP/ticksize)*ticksize);
      if(vol_take!=_vol_pos)
        {
         tick_order=GetTickOrdComent("TAKE PROFIT");
         if(!OrderSelect(tick_order) && tick_order>0)Print("Ordem não selecionada");
         if((tick_order>0 && OrderGetInteger(ORDER_STATE)!=ORDER_STATE_PARTIAL) || vol_take==0.0)
           {
            mensagens=__FUNCSIG__+" Posição Selecionada. Ticket: "+IntegerToString(PositionGetInteger(POSITION_TICKET))+"\n"+
                      "Preço de Abertura da Posição: "+DoubleToString(pos_price,_Digits)+"\n"+
                      "Enviando ou Atualizando ordem de Take Profit :"+"Preço da Posição: "+DoubleToString(_sellprice,_Digits)+"\n"+
                      "Tamanho: "+DoubleToString(gv.Get("tamanho"),_Digits)+" Alvo: "+EnumToString(Alvo)+"\n"+
                      "Take Profit solicitado para envio: "+DoubleToString(_TP,_Digits);
            WriteToFile(filelog,mensagens);
            Print(mensagens);
            DeleteOrdersComment("TAKE PROFIT");
            if(!VerificaPreco(_TP,POSITION_TYPE_BUY))
              {
               mensagens=__FUNCSIG__+" Preço "+DoubleToString(_TP,_Digits)+" muito distante do range. Ordem não enviada"+"\n"+
                         "Ajustando preço de envio do Take Profit";
               WriteToFile(filelog,mensagens);
               Print(mensagens);
               _TP=gv.Get("minima")-ticksize-(gv.Get("tamanho")*Alvo);
               _TP=mysymbol.NormalizePrice(_TP);
               mensagens=__FUNCSIG__+" Novo TP ajustao"+DoubleToString(_TP,_Digits);
               WriteToFile(filelog,mensagens);
               Print(mensagens);
              }

            mensagens=__FUNCSIG__+"Position Price Open "+DoubleToString(pos_price,_Digits)+" TP "+DoubleToString(_TP,_Digits);
            WriteToFile(filelog,mensagens);
            Print(mensagens);

            if(mytrade.BuyLimit(_vol_pos,_TP,original_symbol,0,0,order_time_type,0,"TAKE PROFIT"))
              {
               if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                 {
                  mensagens=__FUNCSIG__+"Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                 }
               else
                 {
                  mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                 }
              }
            else
              {
               mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
               WriteToFile(filelog,mensagens);
               Print(mensagens);
              }
           }//Fim ordem contitions

        }

      if(vol_stop!=_vol_pos)
        {
         tick_order=GetTickOrdComent("STOP LOSS");
         if(!OrderSelect(tick_order) && tick_order>0)Print("Ordem não selecionada");
         bool tipo_ordem=OrderGetInteger(ORDER_TYPE)!=ORDER_TYPE_BUY_LIMIT && OrderGetInteger(ORDER_TYPE)!=ORDER_TYPE_SELL_LIMIT;
         if((tick_order>0 && OrderGetInteger(ORDER_STATE)!=ORDER_STATE_PARTIAL && tipo_ordem) || vol_stop==0.0)
           {
            _limit_stp_buy=mysymbol.NormalizePrice(_SL+ticksize*VariacaoEntrada);
            mensagens=__FUNCSIG__+" Posição Selecionada. Ticket: "+IntegerToString(PositionGetInteger(POSITION_TICKET))+"\n"+
                      "Preço de Abertura da Posição: "+DoubleToString(pos_price,_Digits)+"\n"+
                      "Enviando ou Atualizando ordem de Stop Loss :"+"Preço da Posição: "+DoubleToString(_sellprice,_Digits)+"\n"+
                      "Tamanho: "+DoubleToString(gv.Get("tamanho"),_Digits)+" Alvo: "+EnumToString(Alvo)+"\n"+
                      "Stop Loss solicitado para envio: "+DoubleToString(_SL,_Digits)+"\n"+
                      "Limit buy price: "+DoubleToString(_limit_stp_buy,_Digits);
            WriteToFile(filelog,mensagens);
            Print(mensagens);
            DeleteOrdersComment("STOP LOSS");

            if(!VerificaPreco(_limit_stp_buy,POSITION_TYPE_BUY))
              {

               mensagens=__FUNCSIG__+" Preço "+DoubleToString(_limit_stp_buy,_Digits)+" muito distante do range. Ordem não enviada."+"\n"+
                         "Ajustando Stop Loss";
               WriteToFile(filelog,mensagens);
               Print(mensagens);
               _SL=gv.Get("minima")-ticksize+(gv.Get("tamanho") *0.01*StopInicial);
               _SL=mysymbol.NormalizePrice(_SL);
               _limit_stp_buy=mysymbol.NormalizePrice(_SL+ticksize*VariacaoEntrada);
               mensagens=__FUNCSIG__+" Novo SL ajustao"+DoubleToString(_SL,_Digits)+"\n"+
                         "Limit buy: "+DoubleToString(_limit_stp_buy,_Digits);
               WriteToFile(filelog,mensagens);
               Print(mensagens);

              }

            if(_SL>mysymbol.Ask())
              {
               mensagens=__FUNCSIG__+"Position Price Open "+DoubleToString(pos_price,_Digits)+" SL "+DoubleToString(_SL,_Digits)+
                         " limit buy "+DoubleToString(_limit_stp_buy,_Digits);
               WriteToFile(filelog,mensagens);
               Print(mensagens);

               if(mytrade.OrderOpen(_Symbol,ORDER_TYPE_BUY_STOP_LIMIT,_vol_pos,_limit_stp_buy,_SL,0,0,order_time_type,0,"STOP LOSS"))
                 {
                  if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                    {
                     mensagens=__FUNCSIG__+" Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
                     WriteToFile(filelog,mensagens);
                     Print(mensagens);
                    }
                  else
                    {
                     mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                     WriteToFile(filelog,mensagens);
                     Print(mensagens);
                    }
                 }
               else
                 {
                  mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                 }
              }
            else
              {
               _limit_stp_buy=mysymbol.NormalizePrice(mysymbol.Ask()+ticksize*VariacaoEntrada);
               mensagens=__FUNCSIG__+" Posição Selecionada. Ticket: "+IntegerToString(PositionGetInteger(POSITION_TICKET))+"\n"+
                         "Preço de Abertura da Posição: "+DoubleToString(pos_price,_Digits)+"\n"+
                         "Enviando ou Atualizando ordem de Stop Loss :"+"Preço da Posição: "+DoubleToString(_sellprice,_Digits)+"\n"+
                         "Tamanho: "+DoubleToString(gv.Get("tamanho"),_Digits)+" Alvo: "+EnumToString(Alvo)+"\n"+
                         "Stop Loss solicitado para envio: "+DoubleToString(_SL,_Digits)+"\n"+
                         "Limit buy price: "+DoubleToString(_limit_stp_buy,_Digits);

               mensagens=__FUNCSIG__+"Position Price Open "+DoubleToString(pos_price,_Digits)+" ASK "+DoubleToString(mysymbol.Ask(),_Digits)+
                         " limit buy "+DoubleToString(_limit_stp_buy,_Digits);
               WriteToFile(filelog,mensagens);
               Print(mensagens);

               if(!VerificaPreco(_limit_stp_buy,POSITION_TYPE_BUY))
                 {

                  mensagens=__FUNCSIG__+" Preço "+DoubleToString(_limit_stp_buy,_Digits)+" muito distante do range. Ordem não enviada"+"\n"+
                            "Ajustando Limit Buy";
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                  _limit_stp_buy=mysymbol.NormalizePrice(SymbolInfoDouble(_Symbol,SYMBOL_ASK)+ticksize*VariacaoEntrada);
                  mensagens=__FUNCSIG__+"Novo limit buy "+DoubleToString(_limit_stp_buy,_Digits);
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);

                 }

               if(mytrade.BuyLimit(_vol_pos,_limit_stp_buy,original_symbol,0,0,order_time_type,0,"STOP LOSS"))
                 {
                  if(mytrade.ResultRetcode()==10008 || mytrade.ResultRetcode()==10009)
                    {
                     mensagens=__FUNCSIG__+" Ordem Enviada ou Executada com Sucesso. Ticket "+IntegerToString(mytrade.ResultOrder());
                     WriteToFile(filelog,mensagens);
                     Print(mensagens);
                    }
                  else
                    {
                     mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                     WriteToFile(filelog,mensagens);
                     Print(mensagens);
                    }
                 }
               else
                 {
                  mensagens="__FUNCSIG__ = "+__FUNCSIG__+"  __LINE__ = "+IntegerToString(__LINE__)+" Erro enviar ordem "+IntegerToString(GetLastError())+" "+mytrade.ResultRetcodeDescription();
                  WriteToFile(filelog,mensagens);
                  Print(mensagens);
                 }
              }
           }//Fim order condition
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

   MAGIC_NUMBER=MyEA.iMakeExpertId();

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
   Print(__FUNCSIG__," UninitializeReason() = ",getUninitReasonText(UninitializeReason()));
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

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Número Mágico: "+IntegerToString(MAGIC_NUMBER),xx1,yy1,xx2,yy2))
      return(false);
   m_label[0].Color(clrDeepSkyBlue);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;



   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"RESULTADO MENSAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[1].Color(clrYellow);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"RESULTADO SEMANAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[2].Color(clrMediumSpringGreen);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+3*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"RESULTADO DIÁRIO: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[3].Color(clrMediumSpringGreen);

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
   m_label[0].Text("Número Mágico: "+IntegerToString(MAGIC_NUMBER));
   m_label[1].Text("RESULTADO MENSAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2));
   m_label[2].Text("RESULTADO SEMANAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2));
   m_label[3].Text("RESULTADO DIÁRIO: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2));
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
//+------------------------------------------------------------------+

void MyRobot::TrailingStopPerc(double pStep)
  {
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number)
        {
         long posType=myposition.PositionType();
         double currentStop;
         double openPrice=myposition.PriceOpen();
         double step=pStep;

         double trailStop;
         double trailStopPrice;
         double currentProfit;
         double limit_price;
         if(posType==POSITION_TYPE_BUY)
           {

            currentProfit=bid-openPrice;
            if(currentProfit>=0)
              {
               trailStop= 0.01*gv.Get("tamanho")*(StopInicial-((bid-openPrice)/step)*porc_stop);
               trailStop=NormalizeDouble(MathRound(trailStop/ticksize)*ticksize,digits);
               trailStopPrice = bid - trailStop;
               trailStopPrice = NormalizeDouble(trailStopPrice,digits);
               currentStop=OrdemPriceComent("STOP LOSS");
               if((trailStopPrice>currentStop+step || currentStop==0.0) && trailStopPrice<mysymbol.Bid())
                 {
                  if(OrdemAberta(ORDER_TYPE_SELL_STOP_LIMIT))limit_price=mysymbol.NormalizePrice(trailStopPrice-ticksize*VariacaoEntrada);
                  else limit_price=0.0;
                  mytrade.OrderModify(GetTickOrdComent("STOP LOSS"),trailStopPrice,0,0,order_time_type,0,limit_price);

                 }
              }
           }
         else if(posType==POSITION_TYPE_SELL)
           {
            currentProfit=openPrice-ask;
            if(currentProfit>=0)
              {
               trailStop=0.01*gv.Get("tamanho")*(StopInicial-((openPrice-ask)/step)*porc_stop);
               trailStop=NormalizeDouble(MathRound(trailStop/ticksize)*ticksize,digits);
               trailStopPrice = ask + trailStop;
               trailStopPrice = NormalizeDouble(trailStopPrice,digits);
               currentStop=OrdemPriceComent("STOP LOSS");
               if((trailStopPrice<currentStop-step || currentStop==0) && trailStopPrice>mysymbol.Ask())
                 {
                  if(OrdemAberta(ORDER_TYPE_BUY_STOP_LIMIT))limit_price=mysymbol.NormalizePrice(trailStopPrice+ticksize*VariacaoEntrada);
                  else limit_price=0.0;
                  mytrade.OrderModify(GetTickOrdComent("STOP LOSS"),trailStopPrice,0,0,order_time_type,0,limit_price);
                 }
              }
           }
        }

     }
  }
//+------------------------------------------------------------------+
