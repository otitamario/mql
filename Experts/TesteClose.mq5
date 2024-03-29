//+------------------------------------------------------------------+
//|                                                   AutoTrader.mq5 |
//|                                              Copyright 2016, AM2 |
//|                                      http://www.forexsystems.biz |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, AM2"
#property link      "http://www.forexsystems.biz"
#property version   "1.00"

#define VK_CONTROL 0x11 //CTRL key
#define KEY_CODE   'E'

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
CButton BotaoFechar;

#define LARGURA_PAINEL 250 // Largura Painel
#define ALTURA_PAINEL 80 // Altura Painel

sinput string Lucro="###---------------------Usar Lucro/Prejuizo para Fechamento-----------------------#####";    //Lucro
input bool UsarLucro=true;//Usar Lucro para Fechamento  True/False
input double lucro=1000.0;//Lucro Mensal em Moeda para Fechar Posicoes 
input double prejuizo=500.0;//Prejuizo Mensal em Moeda para Fechar Posicoes 

sinput string shorario="############------FILTRO DE HORARIO------#################";
input bool UseTimer=true;//Usar Filtro de Horário: True/False
input string start_hour="09:00";//Horario Inicial
input string end_hour="17:20";//Horario Fechamento Diario
input bool daytrade=true;//Fechar Posicao Fim do Dia

#import "user32.dll"
void  keybd_event(int bVk,int bScan,int dwFlags,int dwExtraInfo);
#import




// Используем класс CTrade
#include<Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include<Trade\AccountInfo.mqh>
CAccountInfo      myaccount;
CDealInfo         mydeal;
CTrade            mytrade;
CPositionInfo     myposition;
CSymbolInfo       mysymbol;
COrderInfo        myorder;
MqlDateTime       TimeNow;
double lucro_total;
datetime hora_inicial,hora_final;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   
   if(TimeCurrent()>D'2019.04.30 23:59:59')
     {
      string erro="Data de Validade Expirou";
      MessageBox(erro);
      Print(erro);
      return(INIT_FAILED);
     }
   
   EventSetMillisecondTimer(500);

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);

   TimeToStruct(TimeCurrent(),TimeNow);
   GlobalVariableSet("gv_today_prev",(double)TimeNow.day_of_year);

   if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
      return(INIT_FAILED);
//--- run application 

   ExtDialog.Run();

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   Comment("");
   EventKillTimer();
   ExtDialog.Destroy(reason);

  }
//+------------------------------------------------------------------+
//|  Нажимаем клавиши Ctrl+E                                         |
//+------------------------------------------------------------------+
void Key()
  {
   keybd_event(VK_CONTROL,0,0,0);
   Sleep(10);
   keybd_event(KEY_CODE,0,0,0);
   Sleep(10);
   keybd_event(KEY_CODE,0,2,0);
   Sleep(10);
   keybd_event(VK_CONTROL,0,2,0);
  }
//+------------------------------------------------------------------+
//|   Проверка времени торговли                                      |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTimer()
  {

   GlobalVariableSet("gv_today",(double)TimeNow.day_of_year);

   if(GlobalVariableGet("gv_today")!=GlobalVariableGet("gv_today_prev"))
     {
      if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)==0)
        {
         Key();
         Comment("\n Enable: ",TerminalInfoInteger(TERMINAL_TRADE_ALLOWED),
                 "\n Time: ",TimeCurrent());
        }

     }

   GlobalVariableSet("gv_today_prev",GlobalVariableGet("gv_today"));

   hora_inicial=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+start_hour);
   hora_final=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour);
   if(UseTimer && (TimeCurrent()<hora_inicial || TimeCurrent()>hora_final))
     {
      if(daytrade)
        {
         if(OrdersTotal()>0)DeleteALL();
         if(PositionsTotal()>0)CloseALL();
        }
      return;
     }

   lucro_total=LucroTotal();

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(UsarLucro && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      if(OrdersTotal()>0)DeleteALL();
      if(PositionsTotal()>0)CloseALL();
      if(TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)==1)
        {
         Key();
         Comment("\n Enable: ",TerminalInfoInteger(TERMINAL_TRADE_ALLOWED),
                 "\n Time: ",TimeCurrent());
        }
      return;

     }

  }
//+------------------------------------------------------------------+
void OnTick()
  {
   ExtDialog.OnTick();
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   int total_deals=HistoryDealsTotal();
   ulong ticket=0;
   double profit=0;
   for(int i=0;i<total_deals;i++) // returns the number of current orders
     {
      ticket=HistoryDealGetTicket(i);
      mydeal.Ticket(ticket);
      if(ticket>0)
         if(mydeal.Entry()==DEAL_ENTRY_OUT || mydeal.Entry()==DEAL_ENTRY_OUT_BY)
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
      if(myposition.SelectByIndex(i))
         profit+=myposition.Profit();
   return profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LucroTotal()
  {
   return (LucroOrdens()+LucroPositions());
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseALL()
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i))
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
void DeleteALL()
  {
   int o_total=OrdersTotal();
   for(int j=o_total-1; j>=0; j--)
     {
      ulong o_ticket=OrderGetTicket(j);
      if(o_ticket!=0)
        {
         myorder.Select(o_ticket);
         mytrade.OrderDelete(o_ticket);
        }
     }
  }
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

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Res Diário: "+DoubleToString(LucroTotal(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[0].Color(clrYellow);

   xx1=(int)(LARGURA_PAINEL-INDENT_RIGHT-0.7*BUTTON_WIDTH-CONTROLS_GAP_X);
   yy1=INDENT_TOP;
   xx2=(int)(xx1+0.7*BUTTON_WIDTH);
   yy2=(int)(yy1+1.5*BUTTON_HEIGHT);

   if(!CreateButton(m_chart_id,m_subwin,BotaoFechar,"ZERAR",xx1,yy1,xx2,yy2))
      return(false);
   BotaoFechar.ColorBackground(clrLime);

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

void MyPanel::OnTick(void)
  {
   m_label[0].Text("Res Diário: "+DoubleToString(LucroTotal(),2));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(MyPanel)
ON_EVENT(ON_CLICK,BotaoFechar,OnClickBotaoFechar)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
void OnClickBotaoFechar()
  {
   DeleteALL();
   CloseALL();
  }
//+------------------------------------------------------------------+
