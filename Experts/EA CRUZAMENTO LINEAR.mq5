//+------------------------------------------------------------------+
//|                                         EA CRUZAMENTO LINEAR.mq5 |
//|                                             Samuel Sousa Barbosa |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Samuel Sousa Barbosa"
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//| Include                                                          |
//+------------------------------------------------------------------+
#include <Expert\Expert.mqh>
//--- available signals
#include <Expert\Signal\SignalMA.mqh>
//--- available trailing
#include <Expert\Trailing\TrailingFixedPips.mqh>
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
input string             Expert_Title="EA CRUZAMENTO LINEAR"; // Document name
input string    original_symbol="";//Simbolo Original

input ulong                    Magic_Number=7233;                   // 
bool                     Expert_EveryTick=false;                  // 
//--- inputs for main signal
input int                Signal_ThresholdOpen          =10;                     // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose         =10;                     // Signal threshold value to close [0...100]
input double             Signal_PriceLevel             =0.0;                    // Price level to execute a deal
input double             Signal_StopLevel              =50.0;                   // Stop Loss level (in points)
input double             Signal_TakeLevel              =50.0;                   // Take Profit level (in points)
input int                Signal_Expiration             =4;                      // Expiration of pending orders (in bars)
input int                Signal_0_MA_PeriodMA          =1;                      // Moving Average(1,0,...) Period of averaging
input int                Signal_0_MA_Shift             =0;                      // Moving Average(1,0,...) Time shift
input ENUM_MA_METHOD     Signal_0_MA_Method            =MODE_LWMA;              // Moving Average(1,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_0_MA_Applied           =PRICE_CLOSE;            // Moving Average(1,0,...) Prices series
input double             Signal_0_MA_Weight            =1.0;                    // Moving Average(1,0,...) Weight [0...1.0]
input int                Signal_1_MA_PeriodMA          =5;                      // Moving Average(5,0,...) Period of averaging
input int                Signal_1_MA_Shift             =0;                      // Moving Average(5,0,...) Time shift
input ENUM_MA_METHOD     Signal_1_MA_Method            =MODE_LWMA;              // Moving Average(5,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_1_MA_Applied           =PRICE_CLOSE;            // Moving Average(5,0,...) Prices series
input double             Signal_1_MA_Weight            =1.0;                    // Moving Average(5,0,...) Weight [0...1.0]
//--- inputs for trailing
input int                Trailing_FixedPips_StopLevel  =30;                     // Stop Loss trailing level (in points)
input int                Trailing_FixedPips_ProfitLevel=50;                     // Take Profit trailing level (in points)
//--- inputs for money
input double             Money_FixLot_Percent          =10.0;                   // Percent
input double             Money_FixLot_Lots             =0.1;                    // Fixed volume

sinput string Lucro="###----Usar Lucro/Prejuizo para Fechamento----#####";
input bool UsarLucro=false;//Usar Lucro para Fechamento Diário True/False
input double lucro=1000.0;//Lucro para Fechar Posicoes no Dia
input double prejuizo=500.0;//Prejuizo para Fechar Posicoes no Dia
sinput string shorario="############------TIME FILTER------#################";
input bool UseTimer=true;//Use Time Filter
input string start_hour1="8:30";//Initial Pause Hour 1
input string end_hour1="10:30";//Final Pause Hour 1
input string start_hour2="18:00";//Initial Pause Hour 2
input string end_hour2="20:30";//Final Pause Hour 2
input string start_hour3="23:00";//Initial Pause Hour 3
input string end_hour3="02:00";//Final Pause Hour 3
input string start_hour4="03:40";//Initial Pause Hour 3
input string end_hour4="04:20";//Final Pause Hour 3


input bool daytrade=true;//Close Positions on Time Pauses

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

double lucro_total;
bool timerOn,tradeOn,timerEnt;
datetime hora_inicial1,hora_final1,hora_inicial2,hora_final2,hora_inicial3,hora_final3,hora_inicial4,hora_final4;
bool timer1,timer2,timer3,timer4;
//+------------------------------------------------------------------+
//| Initialization function of the expert                            |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(TimeCurrent()>D'2018.10.8')
     {
      string erro="Data de Validade Expirou";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }
   tradeOn=true;
   mysymbol.Name(original_symbol);
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

//--- Initializing expert
   if(!ExtExpert.Init(Symbol(),Period(),Expert_EveryTick,Magic_Number))
     {
      //--- failed
      printf(__FUNCTION__+": error initializing expert");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   ExtExpert.InitTrade(original_symbol,Magic_Number);
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
//--- Creating filter CSignalMA
   CSignalMA *filter0=new CSignalMA;
   if(filter0==NULL)
     {
      //--- failed
      printf(__FUNCTION__+": error creating filter0");
      ExtExpert.Deinit();
      return(INIT_FAILED);
     }
   signal.AddFilter(filter0);
//--- Set filter parameters
   filter0.PeriodMA(Signal_0_MA_PeriodMA);
   filter0.Shift(Signal_0_MA_Shift);
   filter0.Method(Signal_0_MA_Method);
   filter0.Applied(Signal_0_MA_Applied);
   filter0.Weight(Signal_0_MA_Weight);
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
   filter1.PeriodMA(Signal_1_MA_PeriodMA);
   filter1.Shift(Signal_1_MA_Shift);
   filter1.Method(Signal_1_MA_Method);
   filter1.Applied(Signal_1_MA_Applied);
   filter1.Weight(Signal_1_MA_Weight);
//--- Creation of trailing object
   CTrailingFixedPips *trailing=new CTrailingFixedPips;
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
   trailing.StopLevel(Trailing_FixedPips_StopLevel);
   trailing.ProfitLevel(Trailing_FixedPips_ProfitLevel);
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

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,190,130))

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
   hora_inicial1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour1);
   hora_final1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour1);

   hora_inicial2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour2);
   hora_final2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour2);

   hora_inicial3=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour3);
   hora_final3=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour3);

   hora_inicial4=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour4);
   hora_final4=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour4);

   if(hora_inicial1>hora_final1)
     {
      if(TimeCurrent()>hora_inicial1) hora_final1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+"23:59:59");
      if(TimeCurrent()<hora_final1)hora_inicial1=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+"00:00");
     }

   if(hora_inicial2>hora_final2)
     {
      if(TimeCurrent()>hora_inicial2) hora_final2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+"23:59:59");
      if(TimeCurrent()<hora_final2)hora_inicial2=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+"00:00");
     }

   if(hora_inicial3>hora_final3)
     {
      if(TimeCurrent()>hora_inicial3) hora_final3=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+"23:59:59");
      if(TimeCurrent()<hora_final3)hora_inicial3=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+"00:00");
     }

   if(hora_inicial4>hora_final4)
     {
      if(TimeCurrent()>hora_inicial4) hora_final4=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+"23:59:59");
      if(TimeCurrent()<hora_final4)hora_inicial4=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+"00:00");
     }


   if(UseTimer)
     {
      timer1=TimeCurrent()>=hora_inicial1 && TimeCurrent()<=hora_final1;
      timer2=TimeCurrent()>=hora_inicial2 && TimeCurrent()<=hora_final2;
      timer3=TimeCurrent()>=hora_inicial3 && TimeCurrent()<=hora_final3;
      timer4=TimeCurrent()>=hora_inicial4 && TimeCurrent()<=hora_final4;

      timerOn=!timer1 && !timer2 && !timer3 && !timer4;
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
