//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#define VERSION "1.2"// Mudar aqui as Versões

#property version   VERSION

#resource "\\Indicators\\CassioLines_USDJPY_Rev_L.ex5"
#include <Arrays\ArrayObj.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum EnPosic
  {
   P_Abaixo=0,//Abaixo
   P_Acima=1//Acima
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Operacoes
  {
   OpBuy,//Compra
   OpSell//Venda
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TipoTrade
  {
   TipoDay,//Daytrade
   TipoSwing//SwingTrade
  };

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include <Controls\Defines.mqh>
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
//#undef CONTROLS_LABEL_COLOR  

color borda_bg=clrNONE;//Cor Borda
color painel_bg=clrNONE;//Cor Painel 
color cor_txt_borda_bg=clrYellowGreen;//Cor Texto Borda
                                      //color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG          borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg

#include <Expert_Class_New.mqh>

CLabel            m_label[50];
CPanel painel;
CEdit edit_painel;

#define LARGURA_PAINEL 140 // Largura Painel
#define ALTURA_PAINEL 100 // Altura Painel



input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME para Verificar Entradas
input int MAGIC_NUMBER=20082018;//Número Mágico
ulong deviation_points=50;//Deviation em Pontos(Padrao)
sinput string SComum="############---------Comum--------########";//Comum
input Operacoes operacoes=OpBuy;//Entradas
input double Lot=0.1;//Lote Entrada Inicial
input double LotG=0.1;//Lote Entradas Grid
input double _Stop=0.500;//Stop Loss em Pontos Adicional ao Extremo
input ushort pos_max=0;//Posições Simultâneas ( 0 Ilimitado)
input ushort num_ord_grid=0;//Número de Ordens no Grid
                            //input double dist_ord=300;//Distância das Ordens do Grid
sinput string SInd="############---------Indicadores--------########";//Indicadores
input EnPosic InpPosicao=0;
input double InpOffsetFixo=0.54;
input datetime InpTime1=D'2019.05.31 17:30:00';
input double InpPrice1=0.274;
input datetime InpTime2=D'2019.06.11 09:00:00';
input double InpPrice2=0.725;
input color CorInferior=clrAqua;
input short Tamanho=3;
input ENUM_LINE_STYLE Estilo=STYLE_SOLID;

sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia
input string shorario="############------FILTRO DE HORARIO------#################";//Horário
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



                       //Fim Parametros

//+------------------------------------------------------------------+
//|                                                   MyRobot.mqh |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#include <ChartObjects\ChartObjectsLines.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyPositions: public CObject
  {
public:
   ulong             pos_ticket;
   int               line_number;
   void SetNumber(int n){line_number=n;}
   void SetTicket(ulong t){pos_ticket=t;}
   int GetNumber(){return line_number;}
   ulong GetTicket(){return pos_ticket;}
   void              MyPositions(void);
   void             ~MyPositions(void);
  };
//+------------------------------------------------------------------+ 
//| Constructor                                                      | 
//+------------------------------------------------------------------+ 
MyPositions::MyPositions(void)
  {
   pos_ticket=0;
   line_number=0;
  }
//+------------------------------------------------------------------+ 
//| Destructor                                                       | 
//+------------------------------------------------------------------+ 
MyPositions::~MyPositions(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyOrders: public CObject
  {
public:
   ulong             ord_ticket;
   double            ord_price;
   void SetPrice(double n){ord_price=n;}
   void SetTicket(ulong t){ord_ticket=t;}
   double GetPrice(){return ord_price;}
   ulong GetTicket(){return ord_ticket;}
   void              MyOrders(void);
   void             ~MyOrders(void);
  };
//+------------------------------------------------------------------+ 
//| Constructor                                                      | 
//+------------------------------------------------------------------+ 
MyOrders::MyOrders(void)
  {
   ord_ticket=0;
   ord_price=0.0;
  }
//+------------------------------------------------------------------+ 
//| Destructor                                                       | 
//+------------------------------------------------------------------+ 
MyOrders::~MyOrders(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyRobot : public MyExpert
  {
private:
   CChartObjectVLine VLine[];
   // MyPositions       PosAtual;
   MyPositions      *item;
   MyOrders         *order_item;
   int               total_itens;
   CArrayObj        *PosAbertas;
   CArrayObj        *OrdensAbertas;
   bool              tradebarra;
   ulong             ticket_pos;
   bool              posicaoaberta;
   int               positions_total;
   double            dist_ord,tp_fixo,tp_novo;
   int               cassio_handle;
   double            CLDaily[],CLNumber[],CLMain[];
   string            informacoes;
   double            sl_position,tp_position;
   double            vol_pos,vol_stp;
   double            preco_stp;
   double            preco_cl;
   bool              opt_tester;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   bool              buysignal,sellsignal;
   double            Buyprice,Sellprice;
   double            lastprice,lastprice_prev,minposprice,maxposprice;
   double            coef_ang,tp_atual,tp_inicial;
   datetime          timebarra,time_op;
   double            price_open;

public:
                     MyRobot();
                    ~MyRobot();
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
   void              Entr_Parcial_Buy(ushort norders,double dist);
   void              Entr_Parcial_Sell(ushort norders,double dist);
   double            NormalizaPreco(double preco);
   void              Painel(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   double            LowerPosition();
   double            HigherPosition();
   double            PrecoAtual(datetime hora_agora,datetime hora_op,double preco_op,double inclinacao);

  };

MyRobot MyEA;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MyRobot::MyRobot()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
MyRobot::~MyRobot()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnTimer()
  {
//  EventKillTimer();
   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      Painel(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,ChartWidthInPixels()-LARGURA_PAINEL-30,
             50,ChartWidthInPixels()-20,50+ALTURA_PAINEL);
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int MyRobot::OnInit()
  {
   static bool first_acess=true;
   Print("first_acess ",first_acess);
   if(first_acess)
     {
      PosAbertas=new CArrayObj;
      OrdensAbertas=new CArrayObj;
      first_acess=false;
     }

   lastprice=0.0;
   lastprice_prev=0.0;

      if(InpTime1==InpTime2)
        {
         string erro="InpTime1 e InpTime2 devem ser diferentes InpTime2 ";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);

        }
      if(InpPrice1==InpPrice2)
        {
         string erro="InpPrice1 e InpPrice2 devem ser diferentes ";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);
        }
     

   coef_ang=(InpPrice2-InpPrice1)/(InpTime2-InpTime1);

   if(!MQLInfoInteger(MQL_OPTIMIZATION))
     {
      Painel(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,ChartWidthInPixels()-LARGURA_PAINEL-30,
             50,ChartWidthInPixels()-20,50+ALTURA_PAINEL);
     }

   EventSetTimer(1);
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
   opt_tester=(MQLInfoInteger(MQL_OPTIMIZATION) || MQLInfoInteger(MQL_TESTER) || MQLInfoInteger(MQL_PROFILER)) && !MQLInfoInteger(MQL_VISUAL_MODE);
   if(!opt_tester) mytrade.LogLevel(LOG_LEVEL_NO);
   else mytrade.LogLevel(LOG_LEVEL_ERRORS);
   lucro_orders=LucroOrdens();
   if(!opt_tester)
     {
      lucro_orders_mes=LucroOrdensMes();
      lucro_orders_sem=LucroOrdensSemana();
     }
//mytrade.SetTypeFillingBySymbol(original_symbol);
   mytrade.SetTypeFilling(ORDER_FILLING_RETURN);
   ponto=SymbolInfoDouble(original_symbol,SYMBOL_POINT);
   ticksize=SymbolInfoDouble(original_symbol,SYMBOL_TRADE_TICK_SIZE);
   digits=(int)SymbolInfoInteger(original_symbol,SYMBOL_DIGITS);

   int find_wdo=StringFind(original_symbol,"WDO");
   int find_dol=StringFind(original_symbol,"DOL");
   if(find_dol>=0|| find_wdo>=0) ponto=1.0;
   dist_ord=(InpOffsetFixo)/ponto;
   tp_fixo=(InpOffsetFixo)/ponto;

   gv.Init(symbol,Magic_Number);
   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today_prev",(double)TimeNow.day_of_year);
   setNameGvOrder();

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   ulong curChartID=ChartID();

   cassio_handle=iCustom(_Symbol,PERIOD_CURRENT,"::Indicators\\CassioLines_USDJPY_Rev_L.ex5",InpPosicao,InpOffsetFixo,InpTime1,InpPrice1,InpTime2,InpPrice2,CorInferior,Tamanho,Estilo);

   ChartIndicatorAdd(curChartID,0,cassio_handle);

   ArraySetAsSeries(CLDaily,true);
   ArraySetAsSeries(CLNumber,true);
   ArraySetAsSeries(CLMain,true);

   ArraySetAsSeries(close,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(open,true);

   ChartSetInteger(ChartID(),CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

   if(pos_max>0 && num_ord_grid>pos_max)
     {
      string erro="Número deOrdens no Grid deve ser Menor que Posições Máximas";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);

     }

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(Lot<mysymbol.LotsMin())
     {
      string erro="Lote deve ser maior ou igual a "+DoubleToString(mysymbol.LotsMin(),2);
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   return (INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(const int reason)
  {
   gv.Deinit();
   IndicatorRelease(cassio_handle);
   DeletaIndicadores();
   ObjectsDeleteAll(0);
   EventKillTimer();
//---
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

//+-------------ROTINAS----------------------------------------------+

void MyRobot::OnTick()
  {
   static bool first_tick=true;
   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today",(double)TimeNow.day_of_year);

   bool novodia;
   novodia=Bar_NovoDia.CheckNewBar(original_symbol,PERIOD_D1);

   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      gv.Set("glob_entr_tot",0.0);
      gv.Set("deals_total_prev",0.0);
      gv.Set("last_stop",0.0);
      tradeOn=true;
      hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
      hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

      lucro_orders=LucroOrdens();
      if(!opt_tester)
        {
         lucro_orders_mes=LucroOrdensMes();
         lucro_orders_sem=LucroOrdensSemana();
        }
      first_tick=true;
      lastprice=0.0;
      lastprice_prev=0.0;

     }

   timerOn=true;

   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final && TimeDayFilter();
     }

   if(!timerOn)
     {
      if(daytrade)
        {
         if(OrdersTotal()>0)DeleteALL();
         if(PositionsTotal()>0)CloseALL();
        }
      return;
     }

   if(!tradeOn)return;


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


   if(bid>ask) return;//Leilão


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

   if(PosicaoAberta())lucro_positions=LucroPositions();
   else lucro_positions=0;
   lucro_total=lucro_orders+lucro_positions;
   if(!opt_tester)
     {
      lucro_total_semana=lucro_orders_sem+lucro_positions;
      lucro_total_mes=lucro_orders_mes+lucro_positions;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      if(OrdersTotal()>0)
         DeleteALL();
      CloseALL();
      tradeOn=false;
      informacoes="EA encerrado lucro ou prejuizo";
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(tradeOn && timerOn)

     { // inicio Trade On
      posicaoaberta=PosicaoAberta();
      if(posicaoaberta)
         if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened()) CloseByPosition();

      if(operacoes==OpBuy)
        {
         minposprice=MinPositionPrice();
         lastprice=minposprice>0?MathMin(CLDaily[0],minposprice):CLDaily[0];
        }
      if(operacoes==OpSell)
        {
         maxposprice=MaxPositionPrice();
         lastprice=maxposprice>0?MathMax(CLDaily[0],maxposprice):CLDaily[0];
        }

      if(first_tick)
        {
         lastprice=CLDaily[0];
         first_tick=false;
         timebarra=TimeCurrent();
         for(int i=PositionsTotal()-1;i>=0; i--)
           {
            if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
              {
               price_open=myposition.PriceOpen();
               time_op=myposition.Time();
               tp_atual=myposition.TakeProfit();

               if(myposition.PositionType()==POSITION_TYPE_BUY)
                 {
                  tp_inicial=NormalizaPreco(price_open+tp_fixo*ponto);
                  tp_novo=NormalizaPreco(PrecoAtual(timebarra,time_op,tp_inicial,coef_ang));
                  if(tp_novo-price_open>=2*tp_fixo*ponto)
                    {
                     informacoes="Tp da Posição "+IntegerToString(myposition.Ticket())+" voltando para 1 TP";
                     Print(informacoes);
                     mytrade.PositionModify(myposition.Ticket(),myposition.StopLoss(),tp_inicial);
                    }

                  if(tp_novo>tp_inicial && tp_novo-price_open<2*tp_fixo*ponto)
                    {
                     informacoes="Atualizando Tp da Posição "+IntegerToString(myposition.Ticket());
                     Print(informacoes);
                     mytrade.PositionModify(myposition.Ticket(),myposition.StopLoss(),tp_novo);
                    }

                 }

               if(myposition.PositionType()==POSITION_TYPE_SELL)
                 {
                  tp_inicial=NormalizaPreco(price_open-tp_fixo*ponto);
                  tp_novo=NormalizaPreco(PrecoAtual(timebarra,time_op,tp_inicial,coef_ang));
                  if(price_open-tp_novo>=2*tp_fixo*ponto)
                    {
                     informacoes="Tp da Posição "+IntegerToString(myposition.Ticket())+" voltando para 1 TP";
                     Print(informacoes);
                     mytrade.PositionModify(myposition.Ticket(),myposition.StopLoss(),tp_inicial);
                    }

                  if(tp_novo<tp_inicial && price_open-tp_novo<2*tp_fixo*ponto)
                    {
                     informacoes="Atualizando Tp da Posição "+IntegerToString(myposition.Ticket());
                     Print(informacoes);
                     mytrade.PositionModify(myposition.Ticket(),myposition.StopLoss(),tp_novo);
                    }

                 }

              }
           }

/*    for(int i=0;i<PosAbertas.Total();i++)
           {
            item=new MyPositions;
            item=PosAbertas.At(i); //get order object at index i
            if(myposition.SelectByTicket(item.GetTicket()))
              {
               tp_position=myposition.TakeProfit();
               if(operacoes==OpBuy)
                 {
                  tp_novo=NormalizaPreco(CLDaily[0]+tp_fixo*ponto);
                  if(tp_position-tp_novo>=2*tp_fixo*ponto)
                    {
                     informacoes="Tp da Posição "+IntegerToString(myposition.Ticket())+" alterado para: "+DoubleToString(tp_novo,digits);
                     Print(informacoes);
                     Comment(informacoes);
                     mytrade.PositionModify(myposition.Ticket(),myposition.StopLoss(),tp_novo);
                    }
                 }
               if(operacoes==OpSell)
                 {
                  tp_novo=NormalizaPreco(CLDaily[0]-tp_fixo*ponto);
                  if(tp_novo-tp_position>=2*tp_fixo*ponto)
                    {
                     informacoes="Tp da Posição "+IntegerToString(myposition.Ticket())+" alterado para: "+DoubleToString(tp_novo,digits);
                     Print(informacoes);
                     Comment(informacoes);
                     mytrade.PositionModify(myposition.Ticket(),myposition.StopLoss(),tp_novo);
                    }
                 }

              }
           }*/

        }//Fim first tick

      if(lastprice!=lastprice_prev)
        {

         if(posicaoaberta)
           {
            if(Buy_opened())
              {
               informacoes="Novo Dia. Ordens do Grid reenviadas";
               Print(informacoes);
               Comment(informacoes);
               DeleteALL();
               Entr_Parcial_Buy(num_ord_grid,dist_ord);
              }
            if(Sell_opened())
              {
               informacoes="Novo Dia. Ordens do Grid reenviadas";
               Print(informacoes);
               Comment(informacoes);
               DeleteALL();
               Entr_Parcial_Sell(num_ord_grid,dist_ord);
              }
           }

        }

      lastprice_prev=lastprice;

      if(!posicaoaberta)DeleteOrdersExEntry();

      positions_total=PosAbertas.Total();
      int cont=0;
      string rodape="\n"+"||"+"_____________________________________________"+"||"+"\n";
      informacoes="";

      while(cont<positions_total)
        {
         item=new MyPositions;
         item=PosAbertas.At(0); //get order object at index i
         if(!myposition.SelectByTicket(item.GetTicket()))
           {
            PosAbertas.Delete(0);
            cont++;

            continue;
           }
         cont++;
        }

      for(int i=0;i<PosAbertas.Total();i++)
        {
         item=new MyPositions;
         item=PosAbertas.At(i); //get order object at index i
         informacoes+="\n"+rodape+"|| Ticket: "+IntegerToString(item.GetTicket())+"             ||"+" N. Cassio Line: "+
                      IntegerToString(item.GetNumber());
        }

      informacoes+="\n"+rodape+"|| Total Posições: "+IntegerToString(PosAbertas.Total())+"\n"+rodape;
      Comment(informacoes);
      if(Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo))
        {
         tradebarra=true;

         DeleteALL();
         if(Buy_opened()&& operacoes==OpBuy)
           {
            Entr_Parcial_Buy(num_ord_grid,dist_ord);
           }

         if(Sell_opened() && operacoes==OpSell)
           {
            Entr_Parcial_Sell(num_ord_grid,dist_ord);
           }

        } //Fim Nova Barra

      if(!posicaoaberta)
        {
         buysignal=BuySignal() && operacoes==OpBuy && !Buy_opened();
         sellsignal=SellSignal() && operacoes==OpSell && !Sell_opened();
         positions_total=PosAbertas.Total();
         bool allowed_pos=(pos_max>0 && positions_total<pos_max) || pos_max==0;
         buysignal=buysignal && allowed_pos;
         sellsignal=sellsignal && allowed_pos;

         if(buysignal && tradebarra)
           {
            DeleteALL();
            tradebarra=false;
            tp_position=NormalizaPreco(ask+tp_fixo*ponto);
            sl_position=NormalizaPreco(bid-_Stop);
            if(mytrade.Buy(Lot,original_symbol,0,sl_position,tp_position,"BUY"+exp_name))
              {

               ticket_pos=mytrade.ResultOrder();
               gv.Set("cp_tick",(double)ticket_pos);
               item=new MyPositions;
               item.SetNumber((int)CLNumber[0]);
               item.SetTicket(ticket_pos);
               PosAbertas.Add(item);

              }
            else
               Print("Erro enviar ordem ",GetLastError());
           }

         if(sellsignal && tradebarra)
           {
            DeleteALL();
            tradebarra=false;
            tp_position=NormalizaPreco(bid-tp_fixo*ponto);
            sl_position=NormalizaPreco(ask+_Stop);
            if(mytrade.Sell(Lot,original_symbol,0,sl_position,tp_position,"SELL"+exp_name))
              {
               ticket_pos=mytrade.ResultOrder();
               gv.Set("vd_tick",(double)ticket_pos);
               item=new MyPositions;
               item.SetNumber((int)CLNumber[0]);
               item.SetTicket(ticket_pos);
               PosAbertas.Add(item);
              }
            else
               Print("Erro enviar ordem ",GetLastError());
           }
        }//Fim ! posicao aberta

     } //End Trade On

  } //End OnTick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::Painel(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {

   int xx1=x1+int(0.7*INDENT_LEFT);
   int yy1=y1+INDENT_TOP;
   int xx2=int(xx1+0.7*BUTTON_WIDTH);
   int yy2=int(yy1+BUTTON_HEIGHT);

   edit_painel.Create(chart,name,subwin,x1,y1,x2,y2);
   edit_painel.ColorBackground(clrBlack);
//--- create dependent controls

   m_label[0].Create(chart,"labelmensal",subwin,xx1,yy1,xx2,yy2);
   m_label[0].Color(clrDeepSkyBlue);
   m_label[0].FontSize(9);
   m_label[0].Text("Lucro Mensal: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2));

   xx1=x1+int(0.7*INDENT_LEFT);
   yy1=y1+int(INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=int(xx1+0.7*BUTTON_WIDTH);
   yy2=int(yy1+BUTTON_HEIGHT);


   m_label[1].Create(chart,"labelsemanal",subwin,xx1,yy1,xx2,yy2);
   m_label[1].Color(clrDeepSkyBlue);
   m_label[1].FontSize(9);
   m_label[1].Text("Lucro Semanal: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2));

   xx1=x1+int(0.7*INDENT_LEFT);
   yy1=y1+int(INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=int(xx1+0.7*BUTTON_WIDTH);
   yy2=int(yy1+BUTTON_HEIGHT);

   m_label[2].Create(chart,"labeldiario",subwin,xx1,yy1,xx2,yy2);
   m_label[2].Color(clrDeepSkyBlue);
   m_label[2].FontSize(9);
   m_label[2].Text("Lucro Diário: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2));
//--- succeed 

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
   signal=low[0]<=CLDaily[0];
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Sell conditions                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal=false;
   signal=high[0]>=CLDaily[0];
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::NormalizaPreco(double preco)
  {
   return NormalizeDouble(MathRound(preco/ticksize)*ticksize,digits);
  }
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
   b_get=CopyBuffer(cassio_handle,0,0,5,CLDaily)<=0 || 
         CopyBuffer(cassio_handle,1,0,5,CLNumber)<=0 || 
         CopyBuffer(cassio_handle,2,0,5,CLMain)<=0 || 
         CopyHigh(Symbol(),PERIOD_CURRENT,0,5,high)<=0 || 
         CopyOpen(Symbol(),PERIOD_CURRENT,0, 5, open) <= 0 ||
         CopyLow(Symbol(), PERIOD_CURRENT, 0, 5, low) <= 0 ||
         CopyClose(Symbol(),PERIOD_CURRENT,0,5,close) <= 0;
   return (b_get);
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

   if(type==TRADE_TRANSACTION_HISTORY_UPDATE)
     {
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

         if(deal_symbol!=original_symbol)
            return;
         if(deal_magic==Magic_Number)
           {
            gv.Set("last_deal_time",(double)deal_time);

            if(deal_comment=="BUY"+exp_name)

              {
               myposition.SelectByTicket(trans.order);
               int cont = 0;
               Buyprice = 0;
               while(Buyprice==0 && cont<TENTATIVAS)
                 {
                  Buyprice=myposition.PriceOpen();
                  cont+=1;
                 }
               if(Buyprice==0)
                  Buyprice=mysymbol.Ask();
              }
            //--------------------------------------------------

            if(deal_comment=="SELL"+exp_name)
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
                  Sellprice=mysymbol.Bid();

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
               DeleteALL();
               if(Buy_opened())
                 {
                  Entr_Parcial_Buy(num_ord_grid,dist_ord);
                 }
               if(Sell_opened())
                 {
                  Entr_Parcial_Sell(num_ord_grid,dist_ord);
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
         if(Buyprice==0)
            Buyprice=mysymbol.Ask();

         gv.Set("Buyprice",Buyprice);
         sl_position=NormalizaPreco(Buyprice-_Stop);
         // tp_position = NormalizeDouble(Buyprice + _TakeProfit * ponto, digits);
         tp_position=myposition.TakeProfit();
         mytrade.PositionModify(trans.order,sl_position,tp_position);
         DeleteALL();
         Entr_Parcial_Buy(num_ord_grid,dist_ord);

        }
      //--------------------------------------------------

      if(myhistory.Comment()=="SELL"+exp_name && trans.order_state==ORDER_STATE_FILLED)

        {
         myposition.SelectByTicket(trans.order);
         int cont=0;
         Sellprice=0;
         while(Sellprice==0 && cont<TENTATIVAS)
           {
            Sellprice=myposition.PriceOpen();
            cont+=1;
           }
         if(Sellprice==0)
            Sellprice=mysymbol.Bid();
         gv.Set("Sellprice",Sellprice);
         sl_position=NormalizaPreco(Sellprice+_Stop);
         //tp_position = NormalizeDouble(Sellprice - _TakeProfit * ponto, digits);
         tp_position=myposition.TakeProfit();
         mytrade.PositionModify(trans.order,sl_position,tp_position);
         DeleteALL();
         Entr_Parcial_Sell(num_ord_grid,dist_ord);

        }

      if(StringFind(myhistory.Comment(),"Entrada Parcial")>=0 && trans.order_state==ORDER_STATE_FILLED)
        {
         myposition.SelectByTicket(trans.order);
         item=new MyPositions;
         item.SetNumber((int)CLNumber[0]);
         item.SetTicket(trans.order);
         PosAbertas.Add(item);
        }

      lucro_orders=LucroOrdens();
      lucro_orders_mes = LucroOrdensMes();
      lucro_orders_sem = LucroOrdensSemana();


     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


void MyRobot::Entr_Parcial_Buy(ushort norders,double dist)
  {
   double preco=LowerPosition();
   double price_order;
   int total_ordens=(int)norders;
   int total_pos=TotalPositions();
   if(pos_max>0)
      total_ordens=int(MathMin(pos_max-total_pos,norders-total_pos));
   if(total_ordens<=0 || dist==0.0)return;
   for(int i=0;i<total_ordens;i++)
     {
      price_order=NormalizaPreco(lastprice-(i+1)*dist*ponto);
      tp_position=NormalizaPreco(price_order+tp_fixo*ponto);
      if(price_order>preco-0.5*dist*ponto)continue;
      sl_position=NormalizaPreco(price_order-_Stop);
      mytrade.BuyLimit(LotG,price_order,original_symbol,sl_position,tp_position,order_time_type,0,"Entrada Parcial "+IntegerToString(i+1));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
void MyRobot::Entr_Parcial_Sell(ushort norders,double dist)
  {
   double preco=HigherPosition();
   double price_order;
   int total_ordens=(int)norders;
   int total_pos=TotalPositions();
   if(pos_max>0)
      total_ordens=int(MathMin(pos_max-total_pos,norders-total_pos));
   if(total_ordens<=0 || dist==0.0)return;
   for(int i=0;i<total_ordens;i++)
     {
      price_order=NormalizaPreco(lastprice+(i+1)*dist*ponto);
      tp_position=NormalizaPreco(price_order-tp_fixo*ponto);
      if(price_order<preco+0.5*dist*ponto)
         sl_position=NormalizaPreco(price_order+_Stop);
      mytrade.SellLimit(LotG,price_order,original_symbol,sl_position,tp_position,order_time_type,0,"Entrada Parcial "+IntegerToString(i+1));
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

double MyRobot::PrecoAtual(datetime hora_agora,datetime hora_op,double preco_op,double inclinacao)
  {
   double price=preco_op+inclinacao*(hora_agora-hora_op);
   return price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::LowerPosition()
  {
   double price=EMPTY_VALUE;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i)) // selects the pending order by index for further access to its properties
        {
         if(myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number)
           {
            price=MathMin(myposition.PriceOpen(),price);
           }
        }
     }
   return price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::HigherPosition()
  {
   double price=0.0;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i)) // selects the pending order by index for further access to its properties
        {
         if(myposition.Symbol()==mysymbol.Name() && myposition.Magic()==Magic_Number)
           {
            price=MathMax(myposition.PriceOpen(),price);
           }
        }
     }
   return price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::TimeDayFilter()
  {
   bool filter;
   MqlDateTime TimeToday;
   TimeToStruct(TimeCurrent(),TimeToday);
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
      default:
         filter=false;
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
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

/* if(TimeCurrent()>D'2019.06.15 23:59:59')
     {
      string erro="Data de Validade Expirou";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }
   if(AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO)
     {
      string erro="EA permitido apenas em conta DEMO";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }
*/
   if(!ChartSetInteger(ChartID(),CHART_SHIFT,0,LARGURA_PAINEL+30))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }

   return MyEA.OnInit();

//---

//---
   return(INIT_SUCCEEDED);
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
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

//--- Código de motivo de desinicialização   
   Print(__FUNCTION__," UninitializeReason() = ",getUninitReasonText(UninitializeReason()));
   MyEA.OnDeinit(reason);

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

   int xx1=int(0.7*INDENT_LEFT);
   int yy1=INDENT_TOP;
   int xx2=int(xx1+0.7*BUTTON_WIDTH);
   int yy2=int(yy1+0.5*BUTTON_HEIGHT);

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);

   if(!CreatePanel(chart,subwin,painel,x1,y1,x2,y2))
      return (false);

//--- create dependent controls 

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Lucro Mês: "+DoubleToString(MyEA.LucroTotalMes(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[0].Color(clrYellowGreen);
   m_label[0].FontSize(8);

   xx1=int(0.7*INDENT_LEFT);
   yy1=int(INDENT_TOP+0.5*BUTTON_HEIGHT+0.6*CONTROLS_GAP_Y);
   xx2=int(xx1+0.7*BUTTON_WIDTH);
   yy2=int(yy1+0.5*BUTTON_HEIGHT);

   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"Lucro Semana: "+DoubleToString(MyEA.LucroTotalSemana(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[1].Color(clrYellowGreen);
   m_label[1].FontSize(8);

   xx1=int(0.7*INDENT_LEFT);
   yy1=int(INDENT_TOP+1.2*BUTTON_HEIGHT+0.6*CONTROLS_GAP_Y);
   xx2=int(xx1+0.7*BUTTON_WIDTH);
   yy2=int(yy1+0.5*BUTTON_HEIGHT);

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"Lucro Dia: "+DoubleToString(MyEA.LucroTotal(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[2].Color(clrYellowGreen);
   m_label[2].FontSize(8);

// Minimized(false);//Mudar Se nao quiser minimizar

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
   m_label[0].Text("Lucro Mês: "+DoubleToString(MyEA.LucroTotalMes(),2));
   m_label[1].Text("Lucro Semana: "+DoubleToString(MyEA.LucroTotalSemana(),2));
   m_label[2].Text("Lucro Dia: "+DoubleToString(MyEA.LucroTotal(),2));
//Maximize();

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

int ChartWidthInPixels(const long chart_ID=0)
  {
//--- prepare the variable to get the property value
   long result=-1;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetInteger(chart_ID,CHART_WIDTH_IN_PIXELS,0,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return((int)result);
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
int ChartHeightInPixelsGet(const long chart_ID=0,const int sub_window=0)
  {
//--- prepare the variable to get the property value
   long result=-1;
//--- reset the error value
   ResetLastError();
//--- receive the property value
   if(!ChartGetInteger(chart_ID,CHART_HEIGHT_IN_PIXELS,sub_window,result))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- return the value of the chart property
   return((int)result);
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
