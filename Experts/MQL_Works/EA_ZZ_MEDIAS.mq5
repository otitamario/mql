//+------------------------------------------------------------------+
//|                                           TEST_SignalDeltaZZ.mq5 |
//|                                      Copyright 2014, PunkBASSter |
//|                      https://login.mql5.com/en/users/punkbasster |
//+------------------------------------------------------------------+
#property copyright "Copyright 2014, PunkBASSter"
#property link      "https://login.mql5.com/en/users/punkbasster"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\MySignals\SignalDeltaZZ.mqh>
#include <Expert\Signal\SignalMA.mqh>

//--- available trailing
#include <Expert\Trailing\TrailingNone.mqh>
//--- available money management
#include <Expert\Money\MoneyFixedLot.mqh>
#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include <Auxiliares.mqh>
#include<Trade\AccountInfo.mqh>
#include <Controls\Dialog.mqh>
CLabel            m_label[500];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CControlsDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {

   int xx1=INDENT_LEFT;
   int yy1=INDENT_TOP;
   int xx2=x1+BUTTON_WIDTH;
   int yy2=INDENT_TOP+BUTTON_HEIGHT;

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);

//--- create dependent controls 

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"RESULTADO: "+DoubleToString(lucro_total,2),xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;



   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"HORÁRIO PERMITIDO: "+timerOn,xx1,yy1,xx2,yy2))
      return(false);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*(BUTTON_HEIGHT+CONTROLS_GAP_Y);
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],DayofWeek()+" "+TimeToString(TimeCurrent(),TIME_SECONDS),xx1,yy1,xx2,yy2))
      return(false);



//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CControlsDialog::OnTick(void)
  {
   m_label[0].Text("RESULTADO: "+DoubleToString(lucro_total,2));
   m_label[1].Text("HORÁRIO PERMITIDO: "+timerOn);
   m_label[2].Text(DayofWeek()+" "+TimeToString(TimeCurrent(),TIME_SECONDS));

  }
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(CControlsDialog)

EVENT_MAP_END(CAppDialog)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMyExpert : public CExpert
  {
protected:
   CSymbolInfo      *mytradesymbol;         // pointer to the object-symbol

public:

   bool InitTrade(string simbolo,ulong magic,CExpertTrade *trade=NULL)
     {
      //--- óäàëÿåì ñóùåñòâóþùèé îáúåêò
      if(m_trade!=NULL)
         delete m_trade;
      //---
      if(trade==NULL)
        {
         if((m_trade=new CExpertTrade)==NULL)
            return(false);
        }
      else
         m_trade=trade;
      //--- tune trade object
      mytradesymbol=new CSymbolInfo;
      mytradesymbol.Name(simbolo);
      m_trade.SetSymbol(mytradesymbol);
      m_trade.SetExpertMagicNumber(magic);
      m_trade.SetMarginMode();
      //--- set default deviation for trading in adjusted points
      m_trade.SetDeviationInPoints((ulong)(3*m_adjusted_point/m_symbol.Point()));
      //--- ok
      return(true);
     }
  };

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
//--- inputs for expert
input string Expert_Title="TEST_SignalDeltaZZ"; // Document name
input string    original_symbol="";//Simbolo Original
input ulong        Magic_Number=24614;                //Numero Magico 
input bool         Expert_EveryTick=false;                // Every tick
//--- inputs for main signal
input int                Signal_ThresholdOpen          =10;                         // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose         =10;                         // Signal threshold value to close [0...100]
input double             Signal_PriceLevel             =0.0;                        // Price level to execute a deal
input double             Signal_StopLevel              =50.0;                       // Stop Loss level (in points)
input double             Signal_TakeLevel              =50.0;                       // Take Profit level (in points)
input int                Signal_Expiration             =4;                          // Expiration of pending orders (in bars)
input int                Signal_DeltaZZ_SM_setAppPrice =1;                          // DeltaZZ Signal Module(1,1,...) Applied price: 0 - Close
input int                Signal_DeltaZZ_SM_setRevMode  =1;                          // DeltaZZ Signal Module(1,1,...) Reversal mode: 0 - Pips
input int                Signal_DeltaZZ_SM_setPips     =300;                        // DeltaZZ Signal Module(1,1,...) Reverse in pips
input double             Signal_DeltaZZ_SM_setPercent  =0.42;                       // DeltaZZ Signal Module(1,1,...) Reverse in percent
input int                Signal_DeltaZZ_SM_setLevels   =2;                          // DeltaZZ Signal Module(1,1,...) Peaks number
input double             Signal_DeltaZZ_SM_setPattern0 =50;                         // DeltaZZ Signal Module(1,1,...) Trend direction according to DZZ
input double             Signal_DeltaZZ_SM_Weight      =1.0;                        // DeltaZZ Signal Module(1,1,...) Weight [0...1.0]
input int                Signal_0_MA_PeriodMA          =10;                         // Moving Average(10,0,...) Period of averaging
input int                Signal_0_MA_Shift             =0;                          // Moving Average(10,0,...) Time shift
input ENUM_MA_METHOD     Signal_0_MA_Method            =MODE_EMA;                   // Moving Average(10,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_0_MA_Applied           =PRICE_CLOSE;                // Moving Average(10,0,...) Prices series
input double             Signal_0_MA_Weight            =1.0;                        // Moving Average(10,0,...) Weight [0...1.0]
input int                Signal_1_MA_PeriodMA          =20;                         // Moving Average(20,0,...) Period of averaging
input int                Signal_1_MA_Shift             =0;                          // Moving Average(20,0,...) Time shift
input ENUM_MA_METHOD     Signal_1_MA_Method            =MODE_EMA;                   // Moving Average(20,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_1_MA_Applied           =PRICE_CLOSE;                // Moving Average(20,0,...) Prices series
input double             Signal_1_MA_Weight            =1.0;                        // Moving Average(20,0,...) Weight [0...1.0]
//--- inputs for money
input double             Money_FixLot_Percent          =10.0;                       // Percent
input double             Money_FixLot_Lots             =1.0;                        // Fixed volume

sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes no Dia
sinput string shorario="############------FILTRO DE HORARIO------#################";
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="09:00";//Horario Inicial
input string end_hour_entr="17:00";//Horario Final Entradas
input string end_hour="17:30";//Horario Fechamento Diario
input bool daytrade=true;//Fechar Posicao Fim do Dia

double lucro_total;
bool timerOn,tradeOn,timerEnt;
datetime hora_inicial,hora_final,hora_final_entradas;

//+------------------------------------------------------------------+
//| Global expert object                                             |
//+------------------------------------------------------------------+
CMyExpert ExtExpert;
//CExpert ExtExpert;
CControlsDialog ExtDialog;
CAccountInfo myaccount;
CDealInfo mydeal;
CTrade mytrade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {
   tradeOn=true;
   mysymbol.Name(original_symbol);

//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Magic_Number))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }

   ExtExpert.InitTrade(original_symbol,Magic_Number);

   mytrade.SetExpertMagicNumber(Magic_Number);
//  mytrade.SetDeviationInPoints();
   mytrade.LogLevel(LOG_LEVEL_ERRORS);
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      Print("ORDER_FILLING_FOK");
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      Print("ORDER_FILLING_IOC");
   else
      Print("ORDER_FILLING_RETURN");
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      mytrade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      mytrade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      mytrade.SetTypeFilling(ORDER_FILLING_RETURN);

//--- Creating signal
   CExpertSignal *signal=new CExpertSignal;
   if(signal==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating signal");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//---
   ExtExpert.InitSignal(signal);
   signal.ThresholdOpen(Signal_ThresholdOpen);
   signal.ThresholdClose(Signal_ThresholdClose);
   signal.PriceLevel(Signal_PriceLevel);
   signal.StopLevel(Signal_StopLevel);
   signal.TakeLevel(Signal_TakeLevel);
   signal.Expiration(Signal_Expiration);
//--- Creating filter CSignalDeltaZZ
   CSignalDeltaZZ *filter0=new CSignalDeltaZZ;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.setAppPrice(Signal_DeltaZZ_SM_setAppPrice);
   filter0.setRevMode(Signal_DeltaZZ_SM_setRevMode);
   filter0.setPips(Signal_DeltaZZ_SM_setPips);
   filter0.setPercent(Signal_DeltaZZ_SM_setPercent);
   filter0.setLevels(Signal_DeltaZZ_SM_setLevels);
   filter0.setPattern0(Signal_DeltaZZ_SM_setPattern0);
   filter0.Weight(Signal_DeltaZZ_SM_Weight);
//--- Creating filter CSignalMA
   CSignalMA *filter1=new CSignalMA;
   if(filter1==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter1");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter1);
//--- Set filter parameters
   filter1.PeriodMA(Signal_0_MA_PeriodMA);
   filter1.Shift(Signal_0_MA_Shift);
   filter1.Method(Signal_0_MA_Method);
   filter1.Applied(Signal_0_MA_Applied);
   filter1.Weight(Signal_0_MA_Weight);
//--- Creating filter CSignalMA
   CSignalMA *filter2=new CSignalMA;
   if(filter2==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter2");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter2);
//--- Set filter parameters
   filter2.PeriodMA(Signal_1_MA_PeriodMA);
   filter2.Shift(Signal_1_MA_Shift);
   filter2.Method(Signal_1_MA_Method);
   filter2.Applied(Signal_1_MA_Applied);
   filter2.Weight(Signal_1_MA_Weight);
//--- Creation of trailing object
   CTrailingNone *trailing=new CTrailingNone;
   if(trailing==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add trailing to expert (will be deleted automatically))
   if(!ExtExpert.InitTrailing(trailing))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing trailing");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set trailing parameters
//--- Creation of money object
   CMoneyFixedLot *money=new CMoneyFixedLot;
   if(money==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Add money to expert (will be deleted automatically))
   if(!ExtExpert.InitMoney(money))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing money");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Set money parameters
   money.Percent(Money_FixLot_Percent);
   money.Lots(Money_FixLot_Lots);
//--- Check all trading objects parameters
   if(!ExtExpert.ValidationSettings())
     {
      //--- failed
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
//--- Tuning of all necessary indicators
   if(!ExtExpert.InitIndicators())
     {
      //--- failed
      printf(__FUNCTION__+": error initializing indicators");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   if(hora_inicial>=hora_final)
     {
      string erro="Hora Inicial deve ser Menor que Hora Final";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,220,170))

      return(INIT_FAILED);
//--- run application 

   ExtDialog.Run();

//--- ok
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deinitialization function of the expert                          |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ExtExpert.Deinit();
  }
//+------------------------------------------------------------------+
//| "Tick" event handler function                                    |
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtDialog.OnTick();

   lucro_total=LucroOrdens()+LucroPositions();

   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      tradeOn=false;
     }

   timerOn=true;
   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   if(UseTimer)
     {
      timerOn=TimeCurrent()>=hora_inicial && TimeCurrent()<=hora_final;
     }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(!timerOn && daytrade)
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();

     }

   if(tradeOn && timerOn) ExtExpert.OnTick();
  }
//+------------------------------------------------------------------+
//| "Trade" event handler function                                   |
//+------------------------------------------------------------------+
void OnTrade()
  {
   ExtExpert.OnTrade();
  }
//+------------------------------------------------------------------+
//| "Timer" event handler function                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtExpert.OnTimer();
  }
//+------------------------------------------------------------------+

void DeleteALL()
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
     {
      ulong o_ticket=OrderGetTicket(j);
      if(o_ticket!=0)
        {
         myorder.Select(o_ticket);
         if(myorder.Magic()==Magic_Number && myorder.Symbol()==mysymbol.Name()) mytrade.OrderDelete(o_ticket);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseALL()
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
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
string DayofWeek()
  {
   string filter;
   MqlDateTime TimeNow;
   TimeToStruct(TimeCurrent(),TimeNow);
   switch(TimeNow.day_of_week)
     {
      case 0:
         filter="Domingo";
         break;
      case 1:
         filter="Segunda-feira";
         break;
      case 2:
         filter="Terça-feira";
         break;
      case 3:
         filter="Quarta-feira";
         break;
      case 4:
         filter="Quinta-feira";
         break;
      case 5:
         filter="Sexta-feira";
         break;
      case 6:
         filter="Sábado";
         break;

     }
   return filter;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsFillingTypeAllowed(int fill_type)
  {
//--- Obtain the value of the property that describes allowed filling modes 
   int filling=mysymbol.TradeFillFlags();
//--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LucroOrdens()
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
   uint total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
      //+------------------------------------------------------------------+
      //|                                                                  |
      //+------------------------------------------------------------------+
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Symbol()==mysymbol.Name() && mydeal.Magic()==Magic_Number && (mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY))
            profit+=mydeal.Profit();
     }
   return(profit);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LucroPositions()
  {
   double profit=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Magic()==Magic_Number && myposition.Symbol()==mysymbol.Name())
         profit+=myposition.Profit();
   return profit;
  }
//+------------------------------------------------------------------+
