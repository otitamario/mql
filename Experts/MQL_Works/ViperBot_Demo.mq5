//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#define VALIDADE   D'2100.12.31 23:59:59'//Data de Validade ano.mes.dia horas:minutos:segundos(opcional)
#define VERSION "1.0"// Mudar aqui as Versões

#property copyright "Autor da Estratégia: Messias da Silva <trendbot@bol.com.br>"
#property version   VERSION
#property description   "AVISO DE ALTO RISCO: a negociação tem um alto nível de risco que pode não"
#property description   "ser adequado para todos os investidores. A alavancagem cria risco adicional"
#property description   "e exposição à perda. Antes de tomar qualquer decisão, considere cuidadosamente"
#property description   "seus objetivos de investimento, nível de experiência e tolerância ao risco."
#property description   "Você pode perder algum ou todo seu investimento inicial."
#property description   "Não invista dinheiro que não pode perder."



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include<ChartObjects\ChartObjectsLines.mqh>
#include <Controls\Defines.mqh>
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
//#undef CONTROLS_LABEL_COLOR  

color borda_bg=clrLightCyan;//Cor Borda
color painel_bg=clrBlack;//Cor Painel 
color cor_txt_borda_bg=clrBlue;//Cor Texto Borda
                               //color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG          borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg

#include <EAMessias\Params_Viper.mqh>
#include <EAMessias\AfastMedia_Viper.mqh>
#include <EAMessias\HiLoExp.mqh>

CAccountInfo      myaccount;
AfastMedia MyAfastMed;
HiLoRobot MyHiLoExp;
MyPanel ExtDialog;

CLabel            m_label[50];
CLabel            label_cotacao[50];
CLabel            label_porc[50];
CButton BotaoFechar;

#define LARGURA_PAINEL 310 // Largura Painel
#define ALTURA_PAINEL 200 // Altura Painel
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   datetime expiracao=VALIDADE;
   string msg_validade="Validade até "+TimeToString(expiracao); MessageBox(msg_validade);
   Print(msg_validade);
   bool licenca=TimeCurrent()>expiracao;
   if(licenca)
     {
      string erro="Licença Inválida";
      MessageBox(erro);
      Print(erro);
      return(INIT_FAILED);
     }

   if(AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO)
     {
      string erro="EA permitido apenas em conta DEMO";
      MessageBox(erro);
      Print(erro);
      return(INIT_FAILED);
     }

   if(!ChartSetInteger(ChartID(),CHART_SHIFT,0,50))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }

   switch(Estrategia)
     {
      case Afast:
         if(!ExtDialog.Create(MyAfastMed,0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
         return(INIT_FAILED);
         //--- run application 
         ExtDialog.Run();
         return MyAfastMed.OnInit();
         break;
      case HiLo:
         if(!ExtDialog.Create(MyHiLoExp,0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
         return(INIT_FAILED);
         //--- run application 
         ExtDialog.Run();
         return MyHiLoExp.OnInit();
         break;
      default:
         return INIT_FAILED;
         break;
     }

//---
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.Destroy(reason);

//---
   switch(Estrategia)
     {
      case Afast:
         MyAfastMed.OnDeinit(reason);
         break;
      case HiLo:
         MyHiLoExp.OnDeinit(reason);
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {

   switch(Estrategia)
     {
      case Afast:
         MyAfastMed.OnTimer();
         break;
      case HiLo:
         MyHiLoExp.OnTimer();
         break;
     }

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   switch(Estrategia)
     {
      case Afast:
         MyAfastMed.OnTick();
         if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.OnTick(MyAfastMed);
         break;
      case HiLo:
         MyHiLoExp.OnTick();
         if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.OnTick(MyHiLoExp);
         break;
     }

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
template<typename T>
bool MyPanel::Create(T &MyEA,const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {

   int xx1 = INDENT_LEFT;
   int yy1 = INDENT_TOP;
   int xx2 = x1 + BUTTON_WIDTH;
   int yy2 = INDENT_TOP + BUTTON_HEIGHT;

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return (false);

//--- create dependent controls

   string s_estrateg="";
   if(Estrategia == Afast)
      s_estrateg = "Afastamento da Média";
   if(Estrategia == HiLo)
      s_estrateg = "HiLo";

   color cor_labels=clrDeepSkyBlue;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Estratégia: "+s_estrateg,xx1,yy1,xx2,yy2))
      return (false);

   m_label[0].Color(cor_labels);

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;

   string str_pos;
   if(!MyEA.PosicaoAberta())
      str_pos="Zerado";
   if(MyEA.Buy_opened())
      str_pos="Comprado";
   if(MyEA.Sell_opened())
      str_pos="Vendido";
   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"Posição: "+str_pos,xx1,yy1,xx2,yy2))
      return (false);
   m_label[1].Color(cor_labels);

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + 2 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;

   string str_vol_pos;
   if(!MyEA.PosicaoAberta())
      str_vol_pos="-";
   if(MyEA.Buy_opened())
      str_vol_pos=DoubleToString(MyEA.VolPosType(POSITION_TYPE_BUY),2);
   if(MyEA.Sell_opened())
      str_vol_pos=DoubleToString(MyEA.VolPosType(POSITION_TYPE_SELL),2);

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"Volume: "+str_vol_pos,xx1,yy1,xx2,yy2))
      return (false);
   m_label[2].Color(cor_labels);

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + 3 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"Resultado Mensal: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalMes(),2),xx1,yy1,xx2,yy2))
      return (false);

   m_label[3].Color(cor_labels);

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + 4 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],"Resultado Semanal: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotalSemana(),2),xx1,yy1,xx2,yy2))
      return (false);

   m_label[4].Color(cor_labels);

   xx1 = INDENT_LEFT;
   yy1 = INDENT_TOP + 5 * BUTTON_HEIGHT + CONTROLS_GAP_Y;
   xx2 = xx1 + BUTTON_WIDTH;
   yy2 = yy1 + BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[5],"Resultado Diário: "+MyEA.GetCurrency()+" "+DoubleToString(MyEA.LucroTotal(),2),xx1,yy1,xx2,yy2))
      return (false);
   m_label[5].Color(cor_labels);

   xx1=(int)(LARGURA_PAINEL-INDENT_RIGHT-0.7*BUTTON_WIDTH-CONTROLS_GAP_X);
   yy1=INDENT_TOP;
   xx2=(int)(xx1+0.7*BUTTON_WIDTH);
   yy2=(int)(yy1+1.5*BUTTON_HEIGHT);

   if(!CreateButton(m_chart_id,m_subwin,BotaoFechar,"ZERAR",xx1,yy1,xx2,yy2))
      return(false);
   BotaoFechar.ColorBackground(clrLime);

//--- succeed
   return (true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
void MyPanel::OnTick(T &MyEA)
  {

   string s_estrateg="";
   if(Estrategia == Afast)
      s_estrateg = "Afastamento da Média";
   if(Estrategia == HiLo)
      s_estrateg = "HiLo";

   string str_pos;
   if(!MyEA.PosicaoAberta())
      str_pos="Zerado";
   if(MyEA.Buy_opened())
      str_pos="Comprado";
   if(MyEA.Sell_opened())
      str_pos="Vendido";

   string str_vol_pos;
   if(!MyEA.PosicaoAberta())
      str_vol_pos="-";
   if(MyEA.Buy_opened())
      str_vol_pos=DoubleToString(MyEA.VolPosType(POSITION_TYPE_BUY),2);
   if(MyEA.Sell_opened())
      str_vol_pos=DoubleToString(MyEA.VolPosType(POSITION_TYPE_SELL),2);

   m_label[0].Text("Estratégia: " + s_estrateg);
   m_label[1].Text("Posição: " + str_pos);
   m_label[2].Text("Volume: " + str_vol_pos);
   m_label[3].Text("Resultado Mensal: " + MyEA.GetCurrency() + " " + DoubleToString(MyEA.LucroTotalMes(), 2));
   m_label[4].Text("Resultado Semanal: " + MyEA.GetCurrency() + " " + DoubleToString(MyEA.LucroTotalSemana(), 2));
   m_label[5].Text("Resultado Diário: " + MyEA.GetCurrency() + " " + DoubleToString(MyEA.LucroTotal(), 2));
  }
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(MyPanel)
ON_EVENT(ON_CLICK,BotaoFechar,OnClickBotaoFechar)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
void OnClickBotaoFechar()
  {
   switch(Estrategia)
     {
      case Afast:
         MyAfastMed.DeleteALL();
         MyAfastMed.CloseALL();
         break;
      case HiLo:
         MyHiLoExp.DeleteALL();
         MyHiLoExp.CloseALL();
         break;
      default:
         break;
     }

  }
//+------------------------------------------------------------------+
