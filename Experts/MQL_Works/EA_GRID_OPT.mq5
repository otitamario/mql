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
enum TipoOrdem
  {
   Compra,//Compra
   Venda//Venda
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

#define LARGURA_PAINEL 360 // Largura Painel
#define ALTURA_PAINEL 200 // Altura Painel
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct Estr_Ord
  {
   double            distancia;
   double            lote;
   TipoOrdem         tipo_ordem;
   double            stop;
   double            take;
   double            price;
  };

// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO 
input ulong MAGIC_NUMBER=26032019;
ulong deviation_points=50;//Deviation em Pontos(Padrao)
sinput string STrailing="############---------------Trailing Stop----------########";//Stop Móvel
input bool   Use_TraillingStop=false; //Usar Stop Móvel
input double TraillingStart=50;//Lucro Minimo Em Pontos Iniciar Stop Móvel
input double TraillingDistance=100;// Distancia em Pontos do Stop Loss
input double TraillingStep=10;// Passo para atualizar Stop Loss
sinput string STrailingloss="############---------------Stop Loss Móvel----------########";//Stop Loss Móvel
input bool   Use_TraillingStopLoss=false; //Usar Stop Loss Móvel
input double TraillingStartLoss=300;//Prejuízo em Pontos Para Iniciar Stop Loss Móvel
input double TraillingDistanceLoss=50;// Distancia em Pontos Para Fechar Posições

sinput string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input double pts_interval=300;//Pontos de Intervalo Após SL/TP
sinput string soralta="#############################";//Ordens Acima Abertura
input double distUP1=100;//Distância Abertura Ordem Acima 1
input double LotUP1=1;//Lote Ordem Acima 1
input TipoOrdem TP_Ord_UP1=Compra;//Tipo da Ordem Acima 1
input double _SL_UP1=100;//Stop Loss Ordem Acima 1
input double _TP_UP1=100;//Take Profit Ordem Acima 1
sinput string sstr_up2="#############################";//---------------------
input double distUP2=150;//Distância Abertura Ordem Acima 2
input double LotUP2=1;//Lote Ordem Acima 2
input TipoOrdem TP_Ord_UP2=Venda;//Tipo da Ordem Acima 2
input double _SL_UP2=100;//Stop Loss Ordem Acima 2
input double _TP_UP2=100;//Take Profit Ordem Acima 2
sinput string sstr_up3="#############################";//---------------------
input double distUP3=200;//Distância Abertura Ordem Acima 3
input double LotUP3=1;//Lote Ordem Acima 3
input TipoOrdem TP_Ord_UP3=Compra;//Tipo da Ordem Acima 3
input double _SL_UP3=100;//Stop Loss Ordem Acima 3
input double _TP_UP3=100;//Take Profit Ordem Acima 3
sinput string sstr_up4="#############################";//---------------------
input double distUP4=250;//Distância Abertura Ordem Acima 4
input double LotUP4=1;//Lote Ordem Acima 4
input TipoOrdem TP_Ord_UP4=Venda;//Tipo da Ordem Acima 4
input double _SL_UP4=100;//Stop Loss Ordem Acima 4
input double _TP_UP4=100;//Take Profit Ordem Acima 4
sinput string sstr_up5="#############################";//---------------------
input double distUP5=300;//Distância Abertura Ordem Acima 5
input double LotUP5=1;//Lote Ordem Acima 5
input TipoOrdem TP_Ord_UP5=Compra;//Tipo da Ordem Acima 5
input double _SL_UP5=100;//Stop Loss Ordem Acima 5
input double _TP_UP5=100;//Take Profit Ordem Acima 5
sinput string sstr_up6="#############################";//---------------------
input double distUP6=350;//Distância Abertura Ordem Acima 6
input double LotUP6=1;//Lote Ordem Acima 6
input TipoOrdem TP_Ord_UP6=Venda;//Tipo da Ordem Acima 6
input double _SL_UP6=100;//Stop Loss Ordem Acima 6
input double _TP_UP6=100;//Take Profit Ordem Acima 6
sinput string sstr_up7="#############################";//---------------------
input double distUP7=400;//Distância Abertura Ordem Acima 7
input double LotUP7=1;//Lote Ordem Acima 7
input TipoOrdem TP_Ord_UP7=Compra;//Tipo da Ordem Acima 7
input double _SL_UP7=100;//Stop Loss Ordem Acima 7
input double _TP_UP7=100;//Take Profit Ordem Acima 7
sinput string sstr_up8="#############################";//---------------------
input double distUP8=450;//Distância Abertura Ordem Acima 8
input double LotUP8=1;//Lote Ordem Acima 8
input TipoOrdem TP_Ord_UP8=Venda;//Tipo da Ordem Acima 8
input double _SL_UP8=100;//Stop Loss Ordem Acima 8
input double _TP_UP8=100;//Take Profit Ordem Acima 8
sinput string sstr_up9="#############################";//---------------------
input double distUP9=500;//Distância Abertura Ordem Acima 9
input double LotUP9=1;//Lote Ordem Acima 9
input TipoOrdem TP_Ord_UP9=Compra;//Tipo da Ordem Acima 9
input double _SL_UP9=100;//Stop Loss Ordem Acima 9
input double _TP_UP9=100;//Take Profit Ordem Acima 9
sinput string sstr_up10="#############################";//---------------------
input double distUP10=550;//Distância Abertura Ordem Acima 10
input double LotUP10=1;//Lote Ordem Acima 10
input TipoOrdem TP_Ord_UP10=Venda;//Tipo da Ordem Acima 10
input double _SL_UP10=100;//Stop Loss Ordem Acima 10
input double _TP_UP10=100;//Take Profit Ordem Acima 10




sinput string sorbaixa="#############################";//Ordens Abaixo Abertura
input double distdown1=100;//Distância Abertura Ordem Abaixo 1
input double Lotdown1=1;//Lote Ordem Abaixo 1
input TipoOrdem TP_Ord_down1=Compra;//Tipo da Ordem Abaixo 1
input double _SL_down1=100;//Stop Loss Ordem Abaixo 1
input double _TP_down1=100;//Take Profit Ordem Abaixo 1
sinput string sstr_down2="#############################";//---------------------
input double distdown2=150;//Distância Abertura Ordem Abaixo 2
input double Lotdown2=1;//Lote Ordem Abaixo 2
input TipoOrdem TP_Ord_down2=Venda;//Tipo da Ordem Abaixo 2
input double _SL_down2=100;//Stop Loss Ordem Abaixo 2
input double _TP_down2=100;//Take Profit Ordem Abaixo 2
sinput string sstr_down3="#############################";//---------------------
input double distdown3=200;//Distância Abertura Ordem Abaixo 3
input double Lotdown3=1;//Lote Ordem Abaixo 3
input TipoOrdem TP_Ord_down3=Compra;//Tipo da Ordem Abaixo 3
input double _SL_down3=100;//Stop Loss Ordem Abaixo 3
input double _TP_down3=100;//Take Profit Ordem Abaixo 3
sinput string sstr_down4="#############################";//---------------------
input double distdown4=250;//Distância Abertura Ordem Abaixo 4
input double Lotdown4=1;//Lote Ordem Abaixo 4
input TipoOrdem TP_Ord_down4=Venda;//Tipo da Ordem Abaixo 4
input double _SL_down4=100;//Stop Loss Ordem Abaixo 4
input double _TP_down4=100;//Take Profit Ordem Abaixo 4
sinput string sstr_down5="#############################";//---------------------
input double distdown5=300;//Distância Abertura Ordem Abaixo 5
input double Lotdown5=1;//Lote Ordem Abaixo 5
input TipoOrdem TP_Ord_down5=Compra;//Tipo da Ordem Abaixo 5
input double _SL_down5=100;//Stop Loss Ordem Abaixo 5
input double _TP_down5=100;//Take Profit Ordem Abaixo 5
sinput string sstr_down6="#############################";//---------------------
input double distdown6=350;//Distância Abertura Ordem Abaixo 6
input double Lotdown6=1;//Lote Ordem Abaixo 6
input TipoOrdem TP_Ord_down6=Venda;//Tipo da Ordem Abaixo 6
input double _SL_down6=100;//Stop Loss Ordem Abaixo 6
input double _TP_down6=100;//Take Profit Ordem Abaixo 6
sinput string sstr_down7="#############################";//---------------------
input double distdown7=400;//Distância Abertura Ordem Abaixo 7
input double Lotdown7=1;//Lote Ordem Abaixo 7
input TipoOrdem TP_Ord_down7=Compra;//Tipo da Ordem Abaixo 7
input double _SL_down7=100;//Stop Loss Ordem Abaixo 7
input double _TP_down7=100;//Take Profit Ordem Abaixo 7
sinput string sstr_down8="#############################";//---------------------
input double distdown8=450;//Distância Abertura Ordem Abaixo 8
input double Lotdown8=1;//Lote Ordem Abaixo 8
input TipoOrdem TP_Ord_down8=Venda;//Tipo da Ordem Abaixo 8
input double _SL_down8=100;//Stop Loss Ordem Abaixo 8
input double _TP_down8=100;//Take Profit Ordem Abaixo 8
sinput string sstr_down9="#############################";//---------------------
input double distdown9=500;//Distância Abertura Ordem Abaixo 9
input double Lotdown9=1;//Lote Ordem Abaixo 9
input TipoOrdem TP_Ord_down9=Compra;//Tipo da Ordem Abaixo 9
input double _SL_down9=100;//Stop Loss Ordem Abaixo 9
input double _TP_down9=100;//Take Profit Ordem Abaixo 9
sinput string sstr_down10="#############################";//---------------------
input double distdown10=550;//Distância Abertura Ordem Abaixo 10
input double Lotdown10=1;//Lote Ordem Abaixo 10
input TipoOrdem TP_Ord_down10=Venda;//Tipo da Ordem Abaixo 10
input double _SL_down10=100;//Stop Loss Ordem Abaixo 10
input double _TP_down10=100;//Take Profit Ordem Abaixo 10



sinput string Lucro="###---------------------Usar Lucro/Prejuizo para Fechamento-----------------------#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia
input bool UsarLucroMes=false;//Usar Lucro Mensal para Fechamento  True/False
input double lucroMes=1000.0;//Lucro Mensal em Moeda para Fechar Posicoes 
input double prejuizoMes=500.0;//Prejuizo Mensal em Moeda para Fechar Posicoes 

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
   CChartObjectHLine HLine_Stop,HLine_Take;
   string            currency_symbol;
   double            sl,tp,price_open_day;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   CNewBar           Bar_NovoMes;
   bool              novomes;
   bool              tradeOnMes;
   double            sl_position,tp_position;
   double            Buyprice,Sellprice;
   string            mensagens;
   Estr_Ord          Acima_Ord[10],Abaixo_Ord[10];
   bool              first_run;
   int               idx_entry;
   double            preco_saida;
   bool              signal_entry;
   double            lucro_pontos;
   bool              start_close_loss;
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
   double            LucroPontos();

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

   first_run=true;
   tradeOn=true;
   tradeOnMes=true;
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

   setNameGvOrder();

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   Acima_Ord[0].distancia=distUP1;Acima_Ord[0].lote=LotUP1;Acima_Ord[0].tipo_ordem=TP_Ord_UP1;
   Acima_Ord[0].stop=_SL_UP1;Acima_Ord[0].take=_TP_UP1;
   Acima_Ord[1].distancia=distUP2;Acima_Ord[1].lote=LotUP2;Acima_Ord[1].tipo_ordem=TP_Ord_UP2;
   Acima_Ord[1].stop=_SL_UP2;Acima_Ord[1].take=_TP_UP2;
   Acima_Ord[2].distancia=distUP3;Acima_Ord[2].lote=LotUP3;Acima_Ord[2].tipo_ordem=TP_Ord_UP3;
   Acima_Ord[2].stop=_SL_UP3;Acima_Ord[2].take=_TP_UP3;
   Acima_Ord[3].distancia=distUP4;Acima_Ord[3].lote=LotUP4;Acima_Ord[3].tipo_ordem=TP_Ord_UP4;
   Acima_Ord[3].stop=_SL_UP4;Acima_Ord[3].take=_TP_UP4;
   Acima_Ord[4].distancia=distUP5;Acima_Ord[4].lote=LotUP5;Acima_Ord[4].tipo_ordem=TP_Ord_UP5;
   Acima_Ord[4].stop=_SL_UP5;Acima_Ord[4].take=_TP_UP5;

   Acima_Ord[5].distancia=distUP6;Acima_Ord[5].lote=LotUP6;Acima_Ord[5].tipo_ordem=TP_Ord_UP6;
   Acima_Ord[5].stop=_SL_UP6;Acima_Ord[5].take=_TP_UP6;
   Acima_Ord[6].distancia=distUP7;Acima_Ord[6].lote=LotUP7;Acima_Ord[6].tipo_ordem=TP_Ord_UP7;
   Acima_Ord[6].stop=_SL_UP7;Acima_Ord[6].take=_TP_UP7;
   Acima_Ord[7].distancia=distUP8;Acima_Ord[7].lote=LotUP8;Acima_Ord[7].tipo_ordem=TP_Ord_UP8;
   Acima_Ord[7].stop=_SL_UP8;Acima_Ord[7].take=_TP_UP8;
   Acima_Ord[8].distancia=distUP9;Acima_Ord[8].lote=LotUP9;Acima_Ord[8].tipo_ordem=TP_Ord_UP9;
   Acima_Ord[8].stop=_SL_UP9;Acima_Ord[8].take=_TP_UP9;
   Acima_Ord[9].distancia=distUP10;Acima_Ord[9].lote=LotUP10;Acima_Ord[9].tipo_ordem=TP_Ord_UP10;
   Acima_Ord[9].stop=_SL_UP10;Acima_Ord[9].take=_TP_UP10;

   Abaixo_Ord[0].distancia=distdown1;Abaixo_Ord[0].lote=Lotdown1;Abaixo_Ord[0].tipo_ordem=TP_Ord_down1;
   Abaixo_Ord[0].stop=_SL_down1;Abaixo_Ord[0].take=_TP_down1;
   Abaixo_Ord[1].distancia=distdown2;Abaixo_Ord[1].lote=Lotdown2;Abaixo_Ord[1].tipo_ordem=TP_Ord_down2;
   Abaixo_Ord[1].stop=_SL_down2;Abaixo_Ord[1].take=_TP_down2;
   Abaixo_Ord[2].distancia=distdown3;Abaixo_Ord[2].lote=Lotdown3;Abaixo_Ord[2].tipo_ordem=TP_Ord_down3;
   Abaixo_Ord[2].stop=_SL_down3;Abaixo_Ord[2].take=_TP_down3;
   Abaixo_Ord[3].distancia=distdown4;Abaixo_Ord[3].lote=Lotdown4;Abaixo_Ord[3].tipo_ordem=TP_Ord_down4;
   Abaixo_Ord[3].stop=_SL_down4;Abaixo_Ord[3].take=_TP_down4;
   Abaixo_Ord[4].distancia=distdown5;Abaixo_Ord[4].lote=Lotdown5;Abaixo_Ord[4].tipo_ordem=TP_Ord_down5;
   Abaixo_Ord[4].stop=_SL_down5;Abaixo_Ord[4].take=_TP_down5;

   Abaixo_Ord[5].distancia=distdown6;Abaixo_Ord[5].lote=Lotdown6;Abaixo_Ord[5].tipo_ordem=TP_Ord_down6;
   Abaixo_Ord[5].stop=_SL_down6;Abaixo_Ord[5].take=_TP_down6;
   Abaixo_Ord[6].distancia=distdown7;Abaixo_Ord[6].lote=Lotdown7;Abaixo_Ord[6].tipo_ordem=TP_Ord_down7;
   Abaixo_Ord[6].stop=_SL_down7;Abaixo_Ord[6].take=_TP_down7;
   Abaixo_Ord[7].distancia=distdown8;Abaixo_Ord[7].lote=Lotdown8;Abaixo_Ord[7].tipo_ordem=TP_Ord_down8;
   Abaixo_Ord[7].stop=_SL_down8;Abaixo_Ord[7].take=_TP_down8;
   Abaixo_Ord[8].distancia=distdown9;Abaixo_Ord[8].lote=Lotdown9;Abaixo_Ord[8].tipo_ordem=TP_Ord_down9;
   Abaixo_Ord[8].stop=_SL_down9;Abaixo_Ord[8].take=_TP_down9;
   Abaixo_Ord[9].distancia=distdown10;Abaixo_Ord[9].lote=Lotdown10;Abaixo_Ord[9].tipo_ordem=TP_Ord_down10;
   Abaixo_Ord[9].stop=_SL_down10;Abaixo_Ord[9].take=_TP_down10;

   for(int i=1;i<10;i++)
     {
      if(Acima_Ord[i].distancia<=Acima_Ord[i-1].distancia)
        {
         string erro="Distâncias Acima Não Estão em Ordem Crescente";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);
        }

      if(Abaixo_Ord[i].distancia<=Abaixo_Ord[i-1].distancia)
        {
         string erro="Distâncias Abaixo Não Estão em Ordem Crescente";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);
        }
     }

   for(int i=0;i<10;i++)
     {
      Acima_Ord[i].price=0.0;
      Abaixo_Ord[i].price=0.0;
     }
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

   static double preco_atual=0;
   static double preco_prev=0;
   static double profit_loss=0.0;
   static double profit_loss_prev=0.0;

   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today",(double)TimeNow.day_of_year);
   gv.Set("gv_mes",(double)TimeNow.mon);

   static bool acima_abertura=false;
   static bool acima_abertura_prev=false;

   bool novodia;
   novodia=Bar_NovoDia.CheckNewBar(original_symbol,PERIOD_D1);

   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      gv.Set("glob_entr_tot",0.0);
      tradeOn=true;
      first_run=true;
      preco_saida=0.0;
     }

   gv.Set("gv_today_prev",gv.Get("gv_today"));

   novomes=Bar_NovoMes.CheckNewBar(original_symbol,PERIOD_MN1);

   if(novomes || gv.Get("gv_mes")!=gv.Get("gv_mes_prev"))
     {
      tradeOnMes=true;
     }
   gv.Set("gv_mes_prev",gv.Get("gv_mes"));

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

   if(UsarLucroMes && (lucro_total_mes>=lucroMes || lucro_total_mes<=-prejuizoMes))
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

   if(tradeOn && tradeOnMes && timerOn)

     {// inicio Trade On
      // SegurancaPos(10);
      if(Buy_opened() && Sell_opened())CloseByPosition();

      price_open_day=iOpen(original_symbol,PERIOD_D1,0);

      if(first_run)
        {

         Acima_Ord[0].distancia=distUP1;Acima_Ord[0].lote=LotUP1;Acima_Ord[0].tipo_ordem=TP_Ord_UP1;
         Acima_Ord[0].stop=_SL_UP1;Acima_Ord[0].take=_TP_UP1;
         Acima_Ord[1].distancia=distUP2;Acima_Ord[1].lote=LotUP2;Acima_Ord[1].tipo_ordem=TP_Ord_UP2;
         Acima_Ord[1].stop=_SL_UP2;Acima_Ord[1].take=_TP_UP2;
         Acima_Ord[2].distancia=distUP3;Acima_Ord[2].lote=LotUP3;Acima_Ord[2].tipo_ordem=TP_Ord_UP3;
         Acima_Ord[2].stop=_SL_UP3;Acima_Ord[2].take=_TP_UP3;
         Acima_Ord[3].distancia=distUP4;Acima_Ord[3].lote=LotUP4;Acima_Ord[3].tipo_ordem=TP_Ord_UP4;
         Acima_Ord[3].stop=_SL_UP4;Acima_Ord[3].take=_TP_UP4;
         Acima_Ord[4].distancia=distUP5;Acima_Ord[4].lote=LotUP5;Acima_Ord[4].tipo_ordem=TP_Ord_UP5;
         Acima_Ord[4].stop=_SL_UP5;Acima_Ord[4].take=_TP_UP5;

         Acima_Ord[5].distancia=distUP6;Acima_Ord[5].lote=LotUP6;Acima_Ord[5].tipo_ordem=TP_Ord_UP6;
         Acima_Ord[5].stop=_SL_UP6;Acima_Ord[5].take=_TP_UP6;
         Acima_Ord[6].distancia=distUP7;Acima_Ord[6].lote=LotUP7;Acima_Ord[6].tipo_ordem=TP_Ord_UP7;
         Acima_Ord[6].stop=_SL_UP7;Acima_Ord[6].take=_TP_UP7;
         Acima_Ord[7].distancia=distUP8;Acima_Ord[7].lote=LotUP8;Acima_Ord[7].tipo_ordem=TP_Ord_UP8;
         Acima_Ord[7].stop=_SL_UP8;Acima_Ord[7].take=_TP_UP8;
         Acima_Ord[8].distancia=distUP9;Acima_Ord[8].lote=LotUP9;Acima_Ord[8].tipo_ordem=TP_Ord_UP9;
         Acima_Ord[8].stop=_SL_UP9;Acima_Ord[8].take=_TP_UP9;
         Acima_Ord[9].distancia=distUP10;Acima_Ord[9].lote=LotUP10;Acima_Ord[9].tipo_ordem=TP_Ord_UP10;
         Acima_Ord[9].stop=_SL_UP10;Acima_Ord[9].take=_TP_UP10;

         Abaixo_Ord[0].distancia=distdown1;Abaixo_Ord[0].lote=Lotdown1;Abaixo_Ord[0].tipo_ordem=TP_Ord_down1;
         Abaixo_Ord[0].stop=_SL_down1;Abaixo_Ord[0].take=_TP_down1;
         Abaixo_Ord[1].distancia=distdown2;Abaixo_Ord[1].lote=Lotdown2;Abaixo_Ord[1].tipo_ordem=TP_Ord_down2;
         Abaixo_Ord[1].stop=_SL_down2;Abaixo_Ord[1].take=_TP_down2;
         Abaixo_Ord[2].distancia=distdown3;Abaixo_Ord[2].lote=Lotdown3;Abaixo_Ord[2].tipo_ordem=TP_Ord_down3;
         Abaixo_Ord[2].stop=_SL_down3;Abaixo_Ord[2].take=_TP_down3;
         Abaixo_Ord[3].distancia=distdown4;Abaixo_Ord[3].lote=Lotdown4;Abaixo_Ord[3].tipo_ordem=TP_Ord_down4;
         Abaixo_Ord[3].stop=_SL_down4;Abaixo_Ord[3].take=_TP_down4;
         Abaixo_Ord[4].distancia=distdown5;Abaixo_Ord[4].lote=Lotdown5;Abaixo_Ord[4].tipo_ordem=TP_Ord_down5;
         Abaixo_Ord[4].stop=_SL_down5;Abaixo_Ord[4].take=_TP_down5;

         Abaixo_Ord[5].distancia=distdown6;Abaixo_Ord[5].lote=Lotdown6;Abaixo_Ord[5].tipo_ordem=TP_Ord_down6;
         Abaixo_Ord[5].stop=_SL_down6;Abaixo_Ord[5].take=_TP_down6;
         Abaixo_Ord[6].distancia=distdown7;Abaixo_Ord[6].lote=Lotdown7;Abaixo_Ord[6].tipo_ordem=TP_Ord_down7;
         Abaixo_Ord[6].stop=_SL_down7;Abaixo_Ord[6].take=_TP_down7;
         Abaixo_Ord[7].distancia=distdown8;Abaixo_Ord[7].lote=Lotdown8;Abaixo_Ord[7].tipo_ordem=TP_Ord_down8;
         Abaixo_Ord[7].stop=_SL_down8;Abaixo_Ord[7].take=_TP_down8;
         Abaixo_Ord[8].distancia=distdown9;Abaixo_Ord[8].lote=Lotdown9;Abaixo_Ord[8].tipo_ordem=TP_Ord_down9;
         Abaixo_Ord[8].stop=_SL_down9;Abaixo_Ord[8].take=_TP_down9;
         Abaixo_Ord[9].distancia=distdown10;Abaixo_Ord[9].lote=Lotdown10;Abaixo_Ord[9].tipo_ordem=TP_Ord_down10;
         Abaixo_Ord[9].stop=_SL_down10;Abaixo_Ord[9].take=_TP_down10;

         for(int i=0;i<10;i++)
           {
            Acima_Ord[i].price=mysymbol.NormalizePrice(price_open_day+Acima_Ord[i].distancia*ponto);
            Abaixo_Ord[i].price=mysymbol.NormalizePrice(price_open_day-Abaixo_Ord[i].distancia);

            if(Acima_Ord[i].tipo_ordem==Compra)
              {
               Acima_Ord[i].stop=mysymbol.NormalizePrice(Acima_Ord[i].price-Acima_Ord[i].stop*ponto);
               Acima_Ord[i].take=mysymbol.NormalizePrice(Acima_Ord[i].price+Acima_Ord[i].take*ponto);
              }
            else
              {
               Acima_Ord[i].stop=mysymbol.NormalizePrice(Acima_Ord[i].price+Acima_Ord[i].stop*ponto);
               Acima_Ord[i].take=mysymbol.NormalizePrice(Acima_Ord[i].price-Acima_Ord[i].take*ponto);
              }

            if(Abaixo_Ord[i].tipo_ordem==Compra)
              {
               Abaixo_Ord[i].stop=mysymbol.NormalizePrice(Abaixo_Ord[i].price-Abaixo_Ord[i].stop*ponto);
               Abaixo_Ord[i].take=mysymbol.NormalizePrice(Abaixo_Ord[i].price+Abaixo_Ord[i].take*ponto);
              }
            else
              {
               Abaixo_Ord[i].stop=mysymbol.NormalizePrice(Abaixo_Ord[i].price+Abaixo_Ord[i].stop*ponto);
               Abaixo_Ord[i].take=mysymbol.NormalizePrice(Abaixo_Ord[i].price-Abaixo_Ord[i].take*ponto);
              }
           }
         first_run=false;
        }

      preco_atual=close[0];

      if(!PosicaoAberta())
        {
         if(preco_atual>price_open_day)
           {
            idx_entry=-1;
            for(int i=0;i<10;i++)
              {
               signal_entry=(preco_atual==Acima_Ord[i].price && preco_prev<Acima_Ord[i].price) || (preco_atual==Acima_Ord[i].price && preco_prev>Acima_Ord[i].price);
               if(gv.Get("glob_entr_tot")>0)signal_entry=signal_entry && (preco_atual<=preco_saida-pts_interval*ponto || preco_atual>=preco_saida+pts_interval*ponto);
               if(signal_entry)
                 {
                  idx_entry=i;
                  break;
                 }
              }
            if(idx_entry>-1)
              {
               if(Acima_Ord[idx_entry].tipo_ordem==Compra)
                 {
                  mytrade.Buy(Acima_Ord[idx_entry].lote,original_symbol,0,Acima_Ord[idx_entry].stop,Acima_Ord[idx_entry].take,"BUY"+exp_name);
                 }
               else
                 {
                  mytrade.Sell(Acima_Ord[idx_entry].lote,original_symbol,0,Acima_Ord[idx_entry].stop,Acima_Ord[idx_entry].take,"SELL"+exp_name);
                 }
              }
           }

         //---------------------------Abaixo-----------------------------------

         if(preco_atual<price_open_day)
           {
            idx_entry=-1;
            for(int i=0;i<10;i++)
              {
               signal_entry=(preco_atual==Abaixo_Ord[i].price && preco_prev<Abaixo_Ord[i].price) || (preco_atual==Abaixo_Ord[i].price && preco_prev>Abaixo_Ord[i].price);
               if(gv.Get("glob_entr_tot")>0)signal_entry=signal_entry && (preco_atual<=preco_saida-pts_interval*ponto || preco_atual>=preco_saida+pts_interval*ponto);
               if(signal_entry)
                 {
                  idx_entry=i;
                  break;
                 }
              }
            if(idx_entry>-1)
              {
               if(Abaixo_Ord[idx_entry].tipo_ordem==Compra)
                 {
                  mytrade.Buy(Abaixo_Ord[idx_entry].lote,original_symbol,0,Abaixo_Ord[idx_entry].stop,Abaixo_Ord[idx_entry].take,"BUY"+exp_name);
                 }
               else
                 {
                  mytrade.Sell(Abaixo_Ord[idx_entry].lote,original_symbol,0,Abaixo_Ord[idx_entry].stop,Abaixo_Ord[idx_entry].take,"SELL"+exp_name);
                 }
              }
           }

        }
      preco_prev=preco_atual;

      if(Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo))
        {

        }//End NewBar

      if(PosicaoAberta())
        {
         if(Use_TraillingStop) TrailingStop(TraillingDistance,TraillingStart,TraillingStep);
         if(Use_TraillingStopLoss)
           {
            lucro_pontos=LucroPontos();
            if(!start_close_loss)profit_loss=-TraillingStartLoss+TraillingDistanceLoss;
            if(lucro_pontos<=-TraillingStartLoss)
              {
               start_close_loss=true;
               if(lucro_pontos+TraillingDistanceLoss<profit_loss_prev)profit_loss=lucro_pontos+TraillingDistanceLoss;
              }
            if(start_close_loss && lucro_pontos>=profit_loss)
              {
               DeleteALL();
               CloseALL();
               Print("Posição Fechada por Stop Loss Móvel");
              }
           }
        }

      else
        {
         start_close_loss=false;
         profit_loss=0.0;
        }
      profit_loss_prev=profit_loss;
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
               preco_saida=deal_price;
               Print("Novas entradas permitidas se preço ficar abaixo de "+DoubleToString(preco_saida-pts_interval*ponto,_Digits)+" ou acima de "+DoubleToString(preco_saida+pts_interval*ponto,_Digits));

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
double MyRobot::LucroPontos()
  {
   double profit=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
        {
         if(myposition.PositionType()==POSITION_TYPE_BUY)
            profit+=SymbolInfoDouble(original_symbol,SYMBOL_BID)-myposition.PriceOpen();
         if(myposition.PositionType()==POSITION_TYPE_SELL)
            profit+=myposition.PriceOpen()-SymbolInfoDouble(original_symbol,SYMBOL_ASK);
        }
     }
   return (profit/ponto);
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
