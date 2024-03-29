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
enum CapVersion
  {
   Vers31,        //Versão 3.1
   Vers5,         //VErsão 5.0
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Sentido
  {
   Compra,        //Operar Comprado
   Venda,         //Operar Vendido
   Compra_e_Venda //Operar Comprado e Vendido
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TipoEnt
  {
   EntSinSeta,//Sinal da Seta
   EntDistX//Distância Eixo X
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
enum ModOper
  {
   ModDayT,//Day Trade
   ModSwiT//Swing Trade
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum QuantAument
  {
   Aum0=0,//0
   Aum1=1,//1
   Aum2=2//2
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TipoTake
  {
   TakeTotal,//Total
   TakeParcial//Parcial
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum SaidaTake
  {
   SaidTkCentral,//Saída Banda Central
   SaidTkOposta//Saída Banda Oposta
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

#define LARGURA_PAINEL 260 // Largura Painel
#define ALTURA_PAINEL 130 // Altura Painel
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input string Simbolo="";//Digite Símbolo para Ordens
input CapVersion cap_version=Vers31;//Versão do Indicador
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO 
input ulong MAGIC_NUMBER=26032019;//Número Mágico
ulong deviation_points=500;//Deviation em Pontos(Padrao)
sinput string SEstrateg="############-----------------------------Estratégia---------------------------########";//Estratégia
input Sentido sentido=Compra_e_Venda;//Tipo de Operação
input double Lot=1;//Tamanho do Lote
input ModOper mod_oper=ModDayT;//Modo de Operação
input TipoEnt tipo_ent=EntSinSeta;//Tipo da Entrada
sinput string SAum="############---------------------------Aumento de posição-------------------------########";//Aumento de posição contrária a posição
input ENUM_BOOLEANO Inp_AumPos=BOOL_YES;// Aumento de Posição Contrária
input TipoEnt opcao_aumento=EntSinSeta;//Opção de Aumento
input QuantAument quant_aumentos=Aum2;//Quantidade de Aumentos
input double coef_aument=2;//Coeficiente de Aumento * Lot Inicial
sinput string STakeProf="############-----------------------Take Profit-------------------------########";//Take Profit
input TipoTake tipo_take=TakeTotal;//Tipo Take Profit
input SaidaTake saida_take=SaidTkCentral;//Tipo de Saída se Total

input ENUM_BOOLEANO RevertPos=BOOL_YES;//Saída pelo sinal Oposto Seta

sinput string SSLOSS="############---------------------Stop Loss-------------------------########";//Stop Loss

input ENUM_BOOLEANO UsarStopLoss=BOOL_YES;//Saída por Stop Loss
input double _Stop=3;//Stop Loss vezes a distância X
sinput string Lucro="###---------------------Usar Lucro/Prejuizo para Fechamento-----------------------#####";    //Lucro
input ENUM_BOOLEANO UsarLucro=BOOL_YES;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes no Dia

sinput string Sind="############----------------------------CAP CHANNEL---------------------------########";//Cap Channel
input double desvio=2.0;//Desvio CAP Channel
input int barras=100;//Barras CAP Channel 

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
   bool              partialSellMidd;
   bool              partialBuyMidd;
   int               aumSell,aumBuy;
   CChartObjectHLine HLine_Stop,HLine_Take;
   double            distX;
   string            currency_symbol;
   double            sl,tp,price_open_day;
   CNewBar           Bar_NovoDia;
   CNewBar           Bar_NovaBarra;
   double            sl_position,tp_position;
   double            Buyprice,Sellprice;
   int               cap_handle;
   double            Cap_Lower[],Cap_Upper[],Cap_Buy[],Cap_Sell[],Cap_Middle[];
   bool              tradebarra,novabarra;
   bool              buysignal,sellsignal;
   datetime          hora_fin_entrad;
   bool              timeEnt;
   double            preco_medio;
   double            vol_pos,vol_stp,preco_stp;
   double            lote_parcial,lote_aumento;
   bool              pos_open;

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
   void              CheckBuyClose();
   void              CheckSellClose();
   void              EntrParcBuy();
   void              EntrParcSell();
   bool GetPosOpen(){return pos_open;};

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
   setOriginalSymbol(Simbolo);
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

   tradebarra=false;
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
   if(UsarStopLoss==BOOL_YES && (_Stop>3 || _Stop<=0))
     {
      string erro="O Multiplicador para o Stop deve ser menor ou igual a 3 e maior que zero";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(Inp_AumPos==BOOL_YES && (quant_aumentos==Aum0 || coef_aument<=0))
     {
      string erro="O Coeficiente de aumento e quantidades de aumentos devem ser maiores que zero ";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(UsarStopLoss==BOOL_YES && Inp_AumPos==BOOL_YES)
     {

      if(quant_aumentos==Aum1 && _Stop<=1)
        {
         string erro="Você tem 1 aumento e Stop Loss <=1. Aumente o stop Loss ou diminua os aumentos";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);
        }

      if(quant_aumentos==Aum2 && _Stop<=2)
        {
         string erro="Você tem 2 aumentos e Stop Loss <=2. Aumente o stop Loss ou diminua os aumentos";
         MessageBox(erro);
         Print(erro);
         return(INIT_PARAMETERS_INCORRECT);
        }
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

   lote_aumento=NormalizeDouble(MathRound(coef_aument*Lot/mysymbol.LotsStep())*mysymbol.LotsStep(),2);
   lote_aumento=MathMax(lote_aumento,mysymbol.LotsMin());

   long curChartID=ChartID();

   if(cap_version==Vers31)
     {
      cap_handle=iCustom(Symbol(),periodoRobo,"Market\\CAP Channel Trading MT5","",desvio,barras,false,false,
                         clrPurple,clrLimeGreen,"","",false,false,false,false,"alert2.wav","email.wav");
     }

   else
     {
      cap_handle=iCustom(Symbol(),periodoRobo,"Market\\CAP Channel Trading MT5","",desvio,barras,false,false,
                         clrPurple,clrLimeGreen,"","",1,false,false,false,false,"alert2.wav","email.wav");

     }

   ChartIndicatorAdd(curChartID,0,cap_handle);

   ArraySetAsSeries(Cap_Lower,true);
   ArraySetAsSeries(Cap_Upper,true);
   ArraySetAsSeries(Cap_Buy,true);
   ArraySetAsSeries(Cap_Sell,true);
   ArraySetAsSeries(Cap_Middle,true);

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
   IndicatorRelease(cap_handle);
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
   if(!timerOn && mod_oper==ModDayT)
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

   if(tradeOn && timerOn)
     {// inicio Trade On

/*  Comment("\n"+"Bid "+DoubleToString(bid,2)+" Ask "+DoubleToString(ask,2)+"\n"+
              " Middle "+DoubleToString(Cap_Middle[0],2)+"\n"+
              "Partial Buy "+partialBuyMidd+"\n"+
              "Partial Sell "+partialSellMidd);*/

      if(close[0]>Cap_Middle[0])
         distX=Cap_Upper[0]-Cap_Middle[0];
      else
         distX=Cap_Middle[0]-Cap_Lower[0];
      distX=mysymbol.NormalizePrice(MathRound(distX/ticksize)*ticksize);
      EntrParcBuy();
      EntrParcSell();
      CheckBuyClose();
      CheckSellClose();
      if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING && Buy_opened() && Sell_opened()) CloseByPosition();

      if(UsarStopLoss==BOOL_YES)
        {
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
        }
      novabarra=Bar_NovaBarra.CheckNewBar(Symbol(),periodoRobo);
      if(novabarra)
        {
         tradebarra=true;
        }//End NewBar

      switch(tipo_ent)
        {
         case EntSinSeta:
            buysignal=BuySignal() && novabarra;
            sellsignal=SellSignal() && novabarra;
            break;
         case EntDistX:
            buysignal=BuySignal() && tradebarra;
            sellsignal=SellSignal() && tradebarra;
            break;
         default:
            break;
        }

      buysignal=buysignal && !Buy_opened();
      sellsignal=sellsignal && !Sell_opened();

      if(timeEnt)
        {
         if(buysignal && sentido!=Venda)
           {
            tradebarra=false;
            CloseALL();
            sl_position=0.0;
            if(UsarStopLoss==BOOL_YES)
               sl_position=mysymbol.NormalizePrice(MathRound((bid-_Stop*distX)/ticksize)*ticksize);
            gv.Set("sl_position",sl_position);
            if(mytrade.Buy(Lot,original_symbol,0,gv.Get("sl_position"),0,"BUY"+exp_name))
              {
               gv.Set(cp_tick,(double)mytrade.ResultOrder());
               Buyprice=ask;
              }
            else Print(__FUNCSIG__+" "+IntegerToString(__LINE__)+" Erro Enviar Ordem: "+IntegerToString(GetLastError()));

           }

         if(sellsignal && sentido!=Compra)
           {
            tradebarra=false;
            CloseALL();
            sl_position=0.0;
            if(UsarStopLoss==BOOL_YES)
               sl_position=mysymbol.NormalizePrice(MathRound((ask+_Stop*distX)/ticksize)*ticksize);
            gv.Set("sl_position",sl_position);
            if(mytrade.Sell(Lot,original_symbol,0,gv.Get("sl_position"),0,"SELL"+exp_name))
              {
               gv.Set(vd_tick,(double)mytrade.ResultOrder());
               Sellprice=bid;
              }
            else Print(__FUNCSIG__+" "+IntegerToString(__LINE__)+" Erro Enviar Ordem: "+IntegerToString(GetLastError()));
           }
        }

     }//End Trade On

  }//Fim Ontick
//+------------------------------------------------------------------+
//| Getting the current values of indicators                         |
//+------------------------------------------------------------------+
bool MyRobot::GetIndValue()
  {
   bool b_get;
   b_get=CopyBuffer(cap_handle,0,0,5,Cap_Middle)<=0 || 
         CopyBuffer(cap_handle,1,0,5,Cap_Upper)<=0 ||
         CopyBuffer(cap_handle,4,0,5,Cap_Lower)<=0 ||
         CopyBuffer(cap_handle,13,0,5,Cap_Buy)<=0 || //13
         CopyBuffer(cap_handle,14,0,5,Cap_Sell)<=0 || //14
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
   switch(tipo_ent)
     {
      case EntSinSeta:
         signal=signal=Cap_Buy[3]==EMPTY_VALUE && Cap_Buy[2]!=EMPTY_VALUE && ask<Cap_Middle[0];
         break;
      case EntDistX:
         signal=ask<=Cap_Lower[0]-distX;
         break;
      default:
         break;
     }
   return signal;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::SellSignal()
  {
   bool signal=false;

   switch(tipo_ent)
     {
      case EntSinSeta:
         signal=signal=Cap_Sell[3]==EMPTY_VALUE && Cap_Sell[2]!=EMPTY_VALUE && ask>Cap_Middle[0];
         break;
      case EntDistX:
         signal=bid>=Cap_Upper[0]+distX;
         break;
      default:
         break;
     }

   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::EntrParcBuy()
  {
   if(Inp_AumPos==BOOL_NO)return;
   if(!Buy_opened())
     {
      aumBuy=0;
      Buyprice=0;
      return;
     }
   if(quant_aumentos==Aum0)return;
   if(aumBuy>=(int)quant_aumentos)return;
   if(opcao_aumento==EntSinSeta && Cap_Buy[2]!=EMPTY_VALUE)
     {
/*sl_position=0.0;
      if(UsarStopLoss==BOOL_YES)
         sl_position=mysymbol.NormalizePrice(MathRound((bid-_Stop*distX)/ticksize)*ticksize);*/
      if(mytrade.Buy(lote_aumento,original_symbol,0,gv.Get("sl_position"),0,IntegerToString(aumBuy+1)+"-o"+" Ent Parcial"+exp_name))
        {
         aumBuy++;
         partialBuyMidd=false;
         Print(IntegerToString(aumBuy)+"-o"+" Aumento Parcial");
        }
      else Print(__FUNCSIG__+" "+IntegerToString(__LINE__)+" Erro Enviar Ordem: "+IntegerToString(GetLastError()));

     }

   if(opcao_aumento==EntDistX && Buyprice>0 && SymbolInfoDouble(_Symbol,SYMBOL_ASK)<=Buyprice-(aumBuy+1)*distX)
     {
/* sl_position=0.0;
      if(UsarStopLoss==BOOL_YES)
         sl_position=mysymbol.NormalizePrice(MathRound((bid-_Stop*distX)/ticksize)*ticksize);*/
      if(mytrade.Buy(lote_aumento,original_symbol,0,gv.Get("sl_position"),0,IntegerToString(aumBuy+1)+"-o"+" Ent Parcial"+exp_name))
        {
         aumBuy++;
         partialBuyMidd=false;
         Print(IntegerToString(aumBuy)+"-o"+" Aumento Parcial");
        }
      else Print(__FUNCSIG__+" "+IntegerToString(__LINE__)+" Erro Enviar Ordem: "+IntegerToString(GetLastError()));
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::EntrParcSell()
  {

   if(Inp_AumPos==BOOL_NO)return;
   if(!Sell_opened())
     {
      aumSell=0;
      Sellprice=0;
      return;
     }
   if(quant_aumentos==Aum0)return;
   if(aumSell>=(int)quant_aumentos)return;
   if(opcao_aumento==EntSinSeta && Cap_Sell[2]!=EMPTY_VALUE)
     {
/* sl_position=0.0;
      if(UsarStopLoss==BOOL_YES)
         sl_position=mysymbol.NormalizePrice(MathRound((SymbolInfoDouble(_Symbol,SYMBOL_ASK)+_Stop*distX)/ticksize)*ticksize);*/
      if(mytrade.Sell(lote_aumento,original_symbol,0,gv.Get("sl_position"),0,IntegerToString(aumSell+1)+"-o"+" Ent Parcial"+exp_name))
        {
         aumSell++;
         partialSellMidd=false;
         Print(IntegerToString(aumSell)+"-o"+" Aumento Parcial");
        }
      else Print(__FUNCSIG__+" "+IntegerToString(__LINE__)+" Erro Enviar Ordem: "+IntegerToString(GetLastError()));

     }

   if(opcao_aumento==EntDistX && Sellprice>0 && SymbolInfoDouble(_Symbol,SYMBOL_BID)>=Sellprice+(aumSell+1)*distX)
     {
/*if(UsarStopLoss==BOOL_YES)
         sl_position=mysymbol.NormalizePrice(MathRound((SymbolInfoDouble(_Symbol,SYMBOL_ASK)+_Stop*distX)/ticksize)*ticksize);*/
      if(mytrade.Sell(lote_aumento,original_symbol,0,gv.Get("sl_position"),0,IntegerToString(aumSell+1)+"-o"+" Ent Parcial"+exp_name))
        {
         aumSell++;
         partialSellMidd=false;
         Print(IntegerToString(aumSell)+"-o"+" Aumento Parcial");
        }
      else Print(__FUNCSIG__+" "+IntegerToString(__LINE__)+" Erro Enviar Ordem: "+IntegerToString(GetLastError()));
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::CheckBuyClose()
  {

   if(Buy_opened())
     {
      if(RevertPos==BOOL_YES && Cap_Sell[2]!=EMPTY_VALUE)
        {
         ClosePosType(POSITION_TYPE_BUY);
         partialBuyMidd=false;
         return;
        }

      switch(tipo_take)
        {
         case TakeTotal:
            if(saida_take==SaidTkCentral && ask>=Cap_Middle[0])
              {
               ClosePosType(POSITION_TYPE_BUY);
               Print("Take Profit Total na Banda Central");
              }
            if(saida_take==SaidTkOposta && ask>=Cap_Upper[0])
              {
               ClosePosType(POSITION_TYPE_BUY);
               Print("Take Profit Total na Banda Oposta");
              }
            break;
         case TakeParcial:

            if(ask>=Cap_Middle[0] && (!partialBuyMidd) && Lot>mysymbol.LotsMin())
              {
               lote_parcial=NormalizeDouble(MathRound(0.5*VolPosType(POSITION_TYPE_BUY)/mysymbol.LotsStep())*mysymbol.LotsStep(),2);
               lote_parcial=MathMax(lote_parcial,mysymbol.LotsMin());
               if(mytrade.Sell(lote_parcial,original_symbol))
                 {
                  partialBuyMidd=true;
                  aumBuy=(int)quant_aumentos;
                  Print("Take Profit Parcial na Banda Central");
                 }
               else Print(__FUNCSIG__+" "+IntegerToString(__LINE__)+" Erro fechamento Parcial "+IntegerToString(GetLastError()));

              }
            if(ask>=Cap_Upper[0])
              {
               ClosePosType(POSITION_TYPE_BUY);
               Print("Take Profit Parcial Finalizado na Banda Oposta");
              }
            break;
        }
     }

   else
     {
      partialBuyMidd=false;
     }

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
void MyRobot::CheckSellClose()
  {

   if(Sell_opened())
     {
      if(RevertPos==BOOL_YES && Cap_Buy[2]!=EMPTY_VALUE)
        {
         ClosePosType(POSITION_TYPE_SELL);
         partialSellMidd=false;
         return;
        }

      switch(tipo_take)
        {
         case TakeTotal:
            if(saida_take==SaidTkCentral && bid<=Cap_Middle[0])
              {
               ClosePosType(POSITION_TYPE_SELL);
               Print("Take Profit Total na Banda Central");
              }
            if(saida_take==SaidTkOposta && bid<=Cap_Lower[0])
              {
               ClosePosType(POSITION_TYPE_SELL);
               Print("Take Profit Total na Banda Oposta");
              }
            break;
         case TakeParcial:

            if(bid<=Cap_Middle[0] && (!partialSellMidd) && Lot>mysymbol.LotsMin())
              {
               lote_parcial=NormalizeDouble(MathRound(0.5*VolPosType(POSITION_TYPE_SELL)/mysymbol.LotsStep())*mysymbol.LotsStep(),2);
               lote_parcial=MathMax(lote_parcial,mysymbol.LotsMin());
               if(mytrade.Buy(lote_parcial,original_symbol))
                 {
                  partialSellMidd=true;
                  aumSell=(int)quant_aumentos;
                  Print("Take Profit Parcial na Banda Central");
                 }
               else Print(__FUNCSIG__+" "+IntegerToString(__LINE__)+" Erro fechamento Parcial "+IntegerToString(GetLastError()));

              }
            if(bid<=Cap_Lower[0])
              {
               ClosePosType(POSITION_TYPE_SELL);
               Print("Take Profit Parcial Finalizado na Banda Oposta");
              }
            break;
        }
     }

   else
     {
      partialSellMidd=false;
     }

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

/*            if(deal_comment=="BUY"+exp_name && deal_entry==DEAL_ENTRY_IN)
              {
               if(trans.price>0)Buyprice=trans.price;
              }

            if(deal_comment=="SELL"+exp_name && deal_entry==DEAL_ENTRY_IN)
              {
               if(trans.price>0)Sellprice=trans.price;
              }
              */

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
            if(trans.price>0)
              {
               if(myhistory.Comment()=="BUY"+exp_name)Buyprice=trans.price;
               if(myhistory.Comment()=="SELL"+exp_name)Sellprice=trans.price;
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

// if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.Destroy(reason);

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
      if(MyEA.GetPosOpen())ExtDialog.OnTick();
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
