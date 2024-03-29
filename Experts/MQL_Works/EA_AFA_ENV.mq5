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

#include <EA_AF_ENV\Params.mqh>
#include <EA_AF_ENV\AfastMedia.mqh>

MyPanel ExtDialog;
CAccountInfo      myaccount;
AfastMedia MyAfastMed;

CLabel            m_label[50];

#define LARGURA_PAINEL 280 // Largura Painel
#define ALTURA_PAINEL 150 // Altura Painel
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(TimeCurrent()>D'2019.05.15')
     {
      string erro="Data de Validade Expirou";
      MessageBox(erro);
      Print(erro);
      return(INIT_FAILED);
     }

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

   if(!ChartSetInteger(ChartID(),CHART_SHIFT,0,50))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }

   return MyAfastMed.OnInit();

//---
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
//---
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.Destroy(reason);

   MyAfastMed.OnDeinit(reason);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   MyAfastMed.OnTradeTransaction(trans,request,result);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {

   MyAfastMed.OnTimer();

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   MyAfastMed.OnTick();
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.OnTick(MyAfastMed);

  }
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID   
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

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"RESULTADO MENSAL: "+MyAfastMed.GetCurrency()+" "+DoubleToString(MyAfastMed.LucroTotalMes(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[0].Color(clrMediumSpringGreen);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"RESULTADO SEMANAL: "+MyAfastMed.GetCurrency()+" "+DoubleToString(MyAfastMed.LucroTotalSemana(),2),xx1,yy1,xx2,yy2))
      return(false);

   m_label[1].Color(clrMediumSpringGreen);

   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"RESULTADO DIÁRIO: "+MyAfastMed.GetCurrency()+" "+DoubleToString(MyAfastMed.LucroTotal(),2),xx1,yy1,xx2,yy2))
      return(false);
   m_label[2].Color(clrMediumSpringGreen);

//--- succeed 
   return(true);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
void MyPanel::OnTick(T &MyEA)
  {
   m_label[0].Text("RESULTADO MENSAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2));
   m_label[1].Text("RESULTADO SEMANAL: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2));
   m_label[2].Text("RESULTADO DIÁRIO: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2));
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
