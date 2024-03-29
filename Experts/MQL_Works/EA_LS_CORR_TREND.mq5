//+------------------------------------------------------------------+
//|                                             EA_Cruz_Med_Will.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"

#resource "\\Indicators\\LSRatio.ex5"
#resource "\\Indicators\\PPMCC.ex5"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Operacao
  {
   Diferenca=1,  //Diferenca
   Razao=2       //Razao
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TipoLote
  {
   Valor,//Lote por valor
   Fixo//Lote fixo
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum enColorMode
  {
   clm_displayColorLine,      // Display two colored line
   clm_displaySingleColorLine // Display single colored line
  };

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

#include <Expert_Class.mqh>
MyPanel ExtDialog;

CLabel            m_label[50];

#define LARGURA_PAINEL 360 // Largura Painel
#define ALTURA_PAINEL 190 // Altura Painel




// gestão financeira, quantas entradas pode fazer por dia, perda máxima e ganho máximo do dia 
input ENUM_TIMEFRAMES periodoRobo=PERIOD_CURRENT;//TIMEFRAME ROBO
input ulong Magic_Number=20082018;
input ulong deviation_points=50;//Deviation em Pontos(Padrao)
input string SEstrateg="############-------------Estratégia----------########";//Estratégia

input string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";    //Lucro
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes no Dia
input string shorario="############------FILTRO DE HORARIO------#################";//Horário
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="9:04";//Horario Inicial
input string end_entry="16:00";//Horário Final para Entradas
input string end_hour="17:20";//Horario Final
input bool daytrade=true;//Fechar Posicao Fim do Horario
sinput string sindicators="############------INDICADORES------#################";//Indicadores
input datetime BeginTime      =  D'2016.01.01'; //Data inicial
input string   Symbol1        =  "PETR4";       //Papel 1
input string   Symbol2        =  "VALE3";       //Papel 2
input double   Multi1         =  1;             //Multiplicador papel 1
input double   Multi2         =  1;             //Multiplicador papel 2
input bool     Invert1        =  false;         //Inverter papel 1
input bool     Invert2        =  false;         //Inverter papel 2
input Operacao Action         =  Razao;         //Entrada por Razao/Diferença
input uint     Window         =  100;           //Numero de barras considerado
input bool     ShowBands      =  true;          //Mostrar Bandas de Bollinger

input TipoLote calcLotes=Fixo;//Cálculo de Lotes por Valor ou Fixo
input double val_lotes=50000;//Valor Financeiro Cálculo Lotes;se por Valor
input double Lot1=1000;//Lote Entrada Papel 1;se Lote Fixo
input double Lot2=1000;//Lote Entrada Papel 2;se Lote Fixo
input ENUM_TIMEFRAMES TIMEF_IN=PERIOD_D1;//Time Frame ENTRADA

input int      BandsPeriod    =  20;            //Periodo para as BB Entrada
input double   BandsDev       =  2.0;           //Desvio Padrao para as BB Entrada
input bool abreclosebar=true;//Abre posição somente no fechamento da barra

input ENUM_TIMEFRAMES TIMEF_OUT=PERIOD_H1;//Time Frame Saída
input int      BandsPeriod_Saida    =  30;            //Periodo para as BB Saída
input double   BandsDev_Saida       =  0.5;           //Desvio Padrao para as BB Saída
input bool fechaclosebar=true;//Fecha posição somente no fechamento da barra
sinput string sindicorrel="############--------------------------#################";//Correlação
input uint                 InpPeriod=50;            // Period
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MyRobot: public MyExpert
  {
private:
   double            ask_sb1,bid_sb1,ask_sb2,bid_sb2;
   bool              timerEnt;
   double            ponto1,ticksize1,digits1;
   double            ponto2,ticksize2,digits2;
   int               lsratio_handle,lsratio_saida_handle,corr_handle;
   double            LS_Ent[],UB_Ent[],ML_Ent[],LB_Ent[];
   double            LS_Said[],UB_Said[],ML_Said[],LB_Said[];
   double            Corr_Buffer[];
   long              curChartID,newChartID,secChartID;
   double            close_sb1[],close_sb2[];
   uint              nsubwindows;
   string            glob_bar_entry;
   string            glob_bar_exit;
   datetime          hora_ent;
   double            lote1,lote2;
public:
   void              MyRobot();
   void             ~MyRobot();
   int               OnInit();
   void              OnDeinit();
   void              OnTick();
   bool              UpperSignalEntry();
   bool              LowerSignalEntry();
   bool              UpperSignalExit();
   bool              LowerSignalExit();
   virtual bool      GetIndValue();
   bool              PosicaoAberta_Symbol1();
   bool              PosicaoAberta_Symbol2();
   double            CalculoLote(double valor,double price,double lotemin);
   virtual double    LucroOrdens();
   virtual double    LucroOrdensMes();
   virtual double    LucroOrdensSemana();
   virtual double    LucroPositions();
   void              CloseALL_LS();
   void              DeleteALL_LS();

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
   gv.Deinit();
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int MyRobot::OnInit(void)
  {
   int find_wdo,find_dol;

   if(Symbol()!=Symbol2)
     {
      string erro="EA deve ser anexado ao gráfico do Ativo "+Symbol2;
      MessageBox(erro);
      Print(erro);
      return(INIT_FAILED);
     }
   setMagic(Magic_Number);
   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.SetDeviationInPoints(50);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
   mytrade.SetTypeFilling(ORDER_FILLING_RETURN);

   gv.Init(symbol,Magic_Number);
   TimeToStruct(TimeCurrent(),TimeNow);
   gv.Set("gv_today_prev",(double)TimeNow.day_of_year);
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   setNameGvOrder();

   mytrade.SetExpertMagicNumber(Magic_Number);
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
   mytrade.SetTypeFilling(ORDER_FILLING_RETURN);
   ponto1=SymbolInfoDouble(Symbol1,SYMBOL_POINT);
   ticksize1=SymbolInfoDouble(Symbol1,SYMBOL_TRADE_TICK_SIZE);
   digits1=(int)SymbolInfoInteger(Symbol1,SYMBOL_DIGITS);
   ponto2=SymbolInfoDouble(Symbol2,SYMBOL_POINT);
   ticksize2=SymbolInfoDouble(Symbol2,SYMBOL_TRADE_TICK_SIZE);
   digits2=(int)SymbolInfoInteger(Symbol2,SYMBOL_DIGITS);

   find_wdo=StringFind(Symbol1,"WDO");
   find_dol=StringFind(Symbol1,"DOL");
   if(find_dol>=0 || find_wdo>=0) ponto1=1.0;
   find_wdo=StringFind(Symbol2,"WDO");
   find_dol=StringFind(Symbol2,"DOL");
   if(find_dol>=0 || find_wdo>=0) ponto2=1.0;

   curChartID=ChartID();
   newChartID=ChartOpen(Symbol2,TIMEF_IN);
   corr_handle=iCustom(Symbol2,TIMEF_IN,"::Indicators\\PPMCC.ex5",InpPeriod,Symbol1,PRICE_CLOSE,Symbol2,PRICE_CLOSE);

   int corrChartID=ChartGetInteger(newChartID,CHART_WINDOWS_TOTAL);
   ChartIndicatorAdd(newChartID,corrChartID,corr_handle);

   lsratio_handle=iCustom(Symbol2,TIMEF_IN,"::Indicators\\LSRatio.ex5",BeginTime,Symbol1,Symbol2,Action,Invert1,Invert2,Multi1,Multi2,Window,ShowBands,BandsPeriod,BandsDev,false,0.1,0.5);
   nsubwindows=ChartGetInteger(newChartID,CHART_WINDOWS_TOTAL);
   ChartIndicatorAdd(newChartID,nsubwindows,lsratio_handle);

   lsratio_saida_handle=iCustom(Symbol2,TIMEF_OUT,"::Indicators\\LSRatio.ex5",BeginTime,Symbol1,Symbol2,Action,Invert1,Invert2,Multi1,Multi2,Window,ShowBands,BandsPeriod_Saida,BandsDev_Saida,false,0.1,0.5);
   secChartID=ChartOpen(Symbol2,TIMEF_OUT);
   nsubwindows=ChartGetInteger(secChartID,CHART_WINDOWS_TOTAL);
   ChartIndicatorAdd(secChartID,nsubwindows,lsratio_saida_handle);

   ArraySetAsSeries(Corr_Buffer,true);
   ArraySetAsSeries(LS_Ent,true);
   ArraySetAsSeries(UB_Ent,true);
   ArraySetAsSeries(ML_Ent,true);
   ArraySetAsSeries(LB_Ent,true);
   ArraySetAsSeries(LS_Said,true);
   ArraySetAsSeries(UB_Said,true);
   ArraySetAsSeries(ML_Said,true);
   ArraySetAsSeries(LB_Said,true);

   ArraySetAsSeries(close_sb1,true);
   ArraySetAsSeries(close_sb2,true);

   ChartSetInteger(curChartID,CHART_SHOW_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_DRAG_TRADE_LEVELS,true);
   ChartSetInteger(curChartID,CHART_COLOR_STOP_LEVEL,clrRed);

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   hora_ent=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_entry);
   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(hora_ent>hora_final)
     {
      string erro="Hora Fina de Entradas deve ser Menor ou igual a Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

//Global Variables Check

   if(abreclosebar)GlobalVariableSet(glob_bar_entry,1.0);
   else GlobalVariableSet(glob_bar_entry,0.0);

   if(fechaclosebar)GlobalVariableSet(glob_bar_exit,1.0);
   else GlobalVariableSet(glob_bar_exit,0.0);

//--- run application 

//---
   return(INIT_SUCCEEDED);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::OnDeinit(void)
  {
   gv.Deinit();
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
   novodia=isNewBar(iTime(original_symbol,PERIOD_D1,0));

   if(novodia || gv.Get("gv_today")!=gv.Get("gv_today_prev"))
     {
      gv.Set("glob_entr_tot",0.0);
      gv.Set("deals_total_prev",0.0);
      tradeOn=true;

     }

   gv.Set("gv_today_prev",gv.Get("gv_today"));

   MytradeTransaction();
   if(GetIndValue())
     {
      Print("Error in obtain indicators buffers or price rates");
      return;
     }

//lucro_total=LucroOrdens()+LucroPositions();
   lucro_total=LucroPositions();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      CloseALL_LS();
      if(OrdersTotal()>0)DeleteALL_LS();

     }

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   hora_ent=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_entry);

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final;
      timerEnt=TimeCurrent()<=hora_ent;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   else
     {
      timerOn=true;
      timerEnt=true;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UseTimer && !timerOn && daytrade)
     {
      if(OrdersTotal()>0)DeleteALL_LS();
      if(PositionsTotal()>0)CloseALL_LS();
     }

//Atualizacao das Cotacoes----ticks
   MqlTick last_tick_sb1;
   MqlTick last_tick_sb2;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(SymbolInfoTick(Symbol1,last_tick_sb1))
     {
      bid_sb1= last_tick_sb1.bid;
      ask_sb1=last_tick_sb1.ask;
     }
   else
     {
      Print("Falhou obter o tick Simbolo 1");
      return;
     }

   if(SymbolInfoTick(Symbol2,last_tick_sb2))
     {
      bid_sb2= last_tick_sb2.bid;
      ask_sb2=last_tick_sb2.ask;
     }
   else
     {
      Print("Falhou obter o tick Simbolo 2");
      return;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(bid_sb1==0 || ask_sb1==0)
     {
      Print("BID ou ASK=0 Simbolo 1: ",bid_sb1," ",ask_sb1);
      return;
     }
   if(bid_sb2==0 || ask_sb2==0)
     {
      Print("BID ou ASK=0 Simbolo 2 : ",bid_sb2," ",ask_sb2);
      return;
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

   if(timerOn)

     {// inicio Trade On

      if(PosicaoAberta_Symbol1() && PosicaoAberta_Symbol2())
        {
         if(UpperSignalExit())
           {
            if(myposition.SelectByTicket((ulong)gv.Get(cp_tick)) && myposition.Symbol()==Symbol1)
              {
               mytrade.PositionClose((ulong)gv.Get(cp_tick));
               mytrade.PositionClose((ulong)gv.Get(vd_tick));

              }
           }
         if(LowerSignalExit())
           {
            if(myposition.SelectByTicket((ulong)gv.Get(cp_tick)) && myposition.Symbol()==Symbol2)
              {
               mytrade.PositionClose((ulong)gv.Get(cp_tick));
               mytrade.PositionClose((ulong)gv.Get(vd_tick));
              }
           }
        }

      else
        {
         if(UpperSignalEntry() && timerEnt)
           {
            if(calcLotes==Valor)
              {
               lote2=CalculoLote(val_lotes,ask_sb2,SymbolInfoDouble(Symbol2,SYMBOL_VOLUME_MIN));
               lote1=CalculoLote(val_lotes,bid_sb1,SymbolInfoDouble(Symbol1,SYMBOL_VOLUME_MIN));
              }
            else
              {
               lote1=Lot1;
               lote2=Lot2;
              }

            mytrade.Buy(lote2,Symbol2,0,0,0,"BUY_UPPER"+exp_name);
            gv.Set(cp_tick,(double)mytrade.ResultOrder());
            mytrade.Sell(lote1,Symbol1,0,0,0,"SELL_UPPER"+exp_name);
            gv.Set(vd_tick,(double)mytrade.ResultOrder());
           }

         if(LowerSignalEntry() && timerEnt)
           {

            if(calcLotes==Valor)
              {
               lote2=CalculoLote(val_lotes,bid_sb2,SymbolInfoDouble(Symbol2,SYMBOL_VOLUME_MIN));
               lote1=CalculoLote(val_lotes,ask_sb1,SymbolInfoDouble(Symbol1,SYMBOL_VOLUME_MIN));
              }
            else
              {
               lote1=Lot1;
               lote2=Lot2;
              }

            mytrade.Buy(lote1,Symbol1,0,0,0,"BUY_LOWER"+exp_name);
            gv.Set(cp_tick,(double)mytrade.ResultOrder());
            mytrade.Sell(lote2,Symbol2,0,0,0,"SELL_LOWER"+exp_name);
            gv.Set(vd_tick,(double)mytrade.ResultOrder());

           }
        }

     }//End Timer On

  }//Fim Ontick
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::UpperSignalEntry()
  {
   bool signal;
   int barra=(int)GlobalVariableGet(glob_bar_entry);
//   signal=LS_Ent[barra+1]>UB_Ent[barra+1] && LS_Ent[barra]<UB_Ent[barra];
   signal=LS_Said[barra]<LB_Said[barra]&&LS_Said[barra]<LS_Said[barra+1];
   signal=signal && Corr_Buffer[1]<0&& Corr_Buffer[2]>0;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::LowerSignalEntry()
  {
   bool signal;
   int barra=(int)GlobalVariableGet(glob_bar_entry);
//   signal=LS_Ent[barra+1]<LB_Ent[barra+1] && LS_Ent[barra]>LB_Ent[barra];
   signal=LS_Said[barra]>UB_Said[barra]&&LS_Said[barra]>LS_Said[barra+1];
   signal=signal && Corr_Buffer[1]<0&& Corr_Buffer[2]>0;
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::UpperSignalExit()
  {
   bool signal;
   int barra=(int)GlobalVariableGet(glob_bar_exit);
   signal=LS_Said[barra+1]>UB_Said[barra+1] && LS_Said[barra]<UB_Said[barra];
   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::LowerSignalExit()
  {
   bool signal;
   int barra=(int)GlobalVariableGet(glob_bar_exit);
   signal=LS_Said[barra+1]<LB_Said[barra+1] && LS_Said[barra]>LB_Said[barra];
   return signal;
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
   b_get=CopyBuffer(corr_handle,0,0,5,Corr_Buffer)<=0 || 
         CopyBuffer(lsratio_handle,0,0,5,LS_Ent)<=0 ||
         CopyBuffer(lsratio_handle,1,0,5,UB_Ent)<=0||
         CopyBuffer(lsratio_handle,2,0,5,ML_Ent)<=0||
         CopyBuffer(lsratio_handle,3,0,5,LB_Ent)<=0||
         CopyBuffer(lsratio_saida_handle,0,0,5,LS_Said)<=0||
         CopyBuffer(lsratio_saida_handle,1,0,5,UB_Said)<=0||
         CopyBuffer(lsratio_saida_handle,2,0,5,ML_Said)<=0||
         CopyBuffer(lsratio_saida_handle,3,0,5,LB_Said)<=0||
         CopyClose(Symbol1,PERIOD_CURRENT,0,5,close_sb1)<=0||
         CopyClose(Symbol2,PERIOD_CURRENT,0,5,close_sb2)<=0;

   return(b_get);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::PosicaoAberta_Symbol1()
  {
   if(myposition.SelectByMagic(Symbol1,Magic_Number))
      return true;
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MyRobot::PosicaoAberta_Symbol2()
  {
   if(myposition.SelectByMagic(Symbol2,Magic_Number))
      return true;
   else return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::CalculoLote(double valor,double price,double lotemin)
  {
   double lotes=MathRound(valor/(price*lotemin))*lotemin;
   return lotes;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::LucroOrdens()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   MqlDateTime stm_end,time_aux;
   TimeToStruct(tm_end,stm_end);
   time_aux=stm_end;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);
   HistorySelect(tm_start,tm_end);
   int total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::LucroOrdensMes()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   MqlDateTime stm_end,time_aux;
   TimeToStruct(tm_end,stm_end);
   time_aux=stm_end;
   time_aux.day=1;
   time_aux.hour=0;
   time_aux.min=0;
   time_aux.sec=0;
   datetime tm_start=StructToTime(time_aux);

   HistorySelect(tm_start,tm_end);
   int total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::LucroOrdensSemana()
  {
//--- request trade history 
   datetime tm_end=TimeCurrent();
   datetime tm_start=WeekStartTime(TimeCurrent());
   HistorySelect(tm_start,tm_end);
   int total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double MyRobot::LucroPositions()
  {
   double profit=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
         profit+=myposition.Profit();
   return profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::CloseALL_LS()
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number)
        {
         if(!mytrade.PositionClose(PositionGetTicket(i)))
           {
            Print(PositionGetTicket(i),"PositionClose() method failed. Return code=",mytrade.ResultRetcode(),
                  ". Code description: ",mytrade.ResultRetcodeDescription());
           }
         else
           {
            Print(PositionGetTicket(i),"PositionClose() method executed successfully. Return code=",mytrade.ResultRetcode(),
                  " (",mytrade.ResultRetcodeDescription(),")");
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyRobot::DeleteALL_LS()
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
     {
      ulong o_ticket=OrderGetTicket(j);
      if(o_ticket!=0)
        {
         myorder.Select(o_ticket);
         if(myorder.Magic()==Magic_Number) mytrade.OrderDelete(o_ticket);
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

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
      return(INIT_FAILED);
//--- run application 

   ExtDialog.Run();

   return MyEA.OnInit();


//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   MyEA.OnDeinit();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   MyEA.OnTick();
   ExtDialog.OnTick();
  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID   
                  const long& lparam,   // event parameter of the long type 
                  const double& dparam, // event parameter of the double type 
                  const string& sparam) // event parameter of the string type 
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
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

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"RESULTADO MENSAL: "+DoubleToString(MyEA.LucroTotalMes(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[2].Color(clrYellow);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+3*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"RESULTADO SEMANAL: "+DoubleToString(MyEA.LucroTotalSemana(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[3].Color(clrMediumSpringGreen);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+4*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],"RESULTADO DIÁRIO: "+DoubleToString(MyEA.LucroTotal(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[4].Color(clrMediumSpringGreen);

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void MyPanel::OnTick(void)
  {
   m_label[0].Text("Nome: "+AccountInfoString(ACCOUNT_NAME));
   m_label[1].Text("Servidor: "+AccountInfoString(ACCOUNT_SERVER)+" Login: "+IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)));
   m_label[2].Text("RESULTADO MENSAL: "+DoubleToString(MyEA.LucroTotalMes(),2));
   m_label[3].Text("RESULTADO SEMANAL: "+DoubleToString(MyEA.LucroTotalSemana(),2));
   m_label[4].Text("RESULTADO DIÁRIO: "+DoubleToString(MyEA.LucroTotal(),2));

  }
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(MyPanel)

EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
