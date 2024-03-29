//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#define VALIDADE   D'2100.12.31 23:59:59'//Data de Validade ano.mes.dia horas:minutos:segundos(opcional)
#define NUMERO_CONTA 9011600   //Numero da conta
#define ONLY_DEMO "NAO" //"SIM"- Somente em Demo,"NAO"- liberado para conta Real



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include<ChartObjects\ChartObjectsLines.mqh>
#include <Controls\Defines.mqh>
#undef CONTROLS_DIALOG_COLOR_BG
#undef CONTROLS_DIALOG_COLOR_CLIENT_BG
#undef CONTROLS_DIALOG_COLOR_CAPTION_TEXT
//#undef CONTROLS_LABEL_COLOR  

color borda_bg=clrWhite;//Cor Borda
color painel_bg=clrWhite;//Cor Painel 
color cor_txt_borda_bg=clrBlack;//Cor Texto Borda
                                //color cor_txt_pn_bg=clrBlueViolet;//Cor Texto Painel

#define CONTROLS_DIALOG_COLOR_BG          borda_bg
#define CONTROLS_DIALOG_COLOR_CLIENT_BG   painel_bg
#define  CONTROLS_DIALOG_COLOR_CAPTION_TEXT cor_txt_borda_bg
//#define CONTROLS_LABEL_COLOR                cor_txt_pn_bg

#include <EA_Igor\Params.mqh>
#include <EA_Igor\AfastMedia.mqh>
#include <EA_Igor\BolWprStoc.mqh>
#include <EA_Igor\DidiExp.mqh>
#include <EA_Igor\TresMedias.mqh>
#include <EA_Igor\AtrStpExp.mqh>
#include <EA_Igor\PTLRSOExp.mqh>
#include <EA_Igor\LinearRegExp.mqh>
#include <EA_Igor\HiLoPrNY.mqh>
#include <EA_Igor\FPChannel.mqh>
#include <EA_Igor\Bollinger.mqh>

MyPanel ExtDialog;
CAccountInfo      myaccount;
AfastMedia MyAfastMed;
BolWprStoRobot MyBolWprSt;
DidiRobot MyDidiExp;
TresMedRobot MyTresMedExp;
ATRStpRobot MyAtrStpExp;
PTLRSORobot MyPTLRSOExp;
LinearRegRobot MyLinRegExp;
HiLoPrNYRobot MyHiLoPrNY;
FPChannelRobot MyFPRobot;
BollRobot MyBollingerRobot;

CLabel            m_label[50];
CLabel            label_cotacao[50];
CLabel            label_porc[50];
CLabel label_setup;

#define LARGURA_PAINEL 310 // Largura Painel
#define ALTURA_PAINEL 440 // Altura Painel

datetime hora_ent;
CiADX *adx;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(UsarADX)
     {
      adx=new CiADX;
      adx.Create(_Symbol,periodoRobo,per_adx);
      if(PlotADX)adx.AddToChart(0,(int)ChartGetInteger(ChartID(),CHART_WINDOWS_TOTAL));
     }
   TimeEnt=false;
   AdxAllow=true;

   ulong numero_conta=NUMERO_CONTA;
   datetime expiracao = VALIDADE;
   string msg_validade= "Validade até "+TimeToString(expiracao)+" para a conta "+IntegerToString(numero_conta)+" "+myaccount.Server();
   MessageBox(msg_validade);
   Print(msg_validade);
   bool licenca=TimeCurrent()>expiracao || myaccount.Login()!=numero_conta;
   if(licenca)
     {
      string erro="Licença Inválida";
      MessageBox(erro);
      Print(erro);
      return (INIT_FAILED);
     }

   if(ONLY_DEMO=="SIM" && AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO)
     {
      string erro="EA permitido apenas em conta DEMO";
      MessageBox(erro);
      Print(erro);
      return (INIT_FAILED);
     }

   if(!FecharPainel)
     {
      if(!ExtDialog.Create(0,MQL5InfoString(MQL5_PROGRAM_NAME),0,0,0,LARGURA_PAINEL,ALTURA_PAINEL))
         return(INIT_FAILED);
     }
//--- run application 

   ExtDialog.Run();
   ExtDialog.Caption(Symbol()+" - "+SymbolInfoString(Symbol(),SYMBOL_DESCRIPTION));

   ChartSetInteger(ChartID(),CHART_COLOR_BACKGROUND,clrDarkBlue);
   ChartSetInteger(ChartID(),CHART_COLOR_FOREGROUND,clrWhite);
   ChartSetInteger(ChartID(),CHART_COLOR_GRID,clrLightSlateGray);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_UP,clrMediumSpringGreen);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_DOWN,clrOrangeRed);
   ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BULL,clrMediumSpringGreen);
   ChartSetInteger(ChartID(),CHART_COLOR_CANDLE_BEAR,clrOrangeRed);
   ChartSetInteger(ChartID(),CHART_COLOR_CHART_LINE,clrLime);
   ChartSetInteger(ChartID(),CHART_COLOR_VOLUME,clrLimeGreen);
   ChartSetInteger(ChartID(),CHART_COLOR_BID,clrLightSlateGray);
   ChartSetInteger(ChartID(),CHART_COLOR_ASK,clrRed);
   ChartSetInteger(ChartID(),CHART_COLOR_LAST,C'0,192,0');
   ChartSetInteger(ChartID(),CHART_COLOR_STOP_LEVEL,clrRed);

   if(!ChartSetInteger(ChartID(),CHART_SHIFT,0,50))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }

   switch(Estrategia)
     {
      case Afast:
         return MyAfastMed.OnInit();
         break;
      case BolaWprSt:
         return MyBolWprSt.OnInit();
         break;
      case Didi:
         return MyDidiExp.OnInit();
         break;
      case TresMed:
         return MyTresMedExp.OnInit();
         break;
      case ATRStp:
         return MyAtrStpExp.OnInit();
         break;

      case PTLRSO:
         return MyPTLRSOExp.OnInit();
         break;

      case Regress:
         return MyLinRegExp.OnInit();
         break;

      case HiLoPrNY:
         return MyHiLoPrNY.OnInit();
         break;

      case FPCHANN:
         return MyFPRobot.OnInit();
         break;
      case BollingEst:
         return MyBollingerRobot.OnInit();
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
   if(UsarADX)
      delete(adx);
//---
   if(!FecharPainel)
      if(!MQLInfoInteger(MQL_OPTIMIZATION)) ExtDialog.Destroy(reason);

   switch(Estrategia)
     {
      case Afast:
         MyAfastMed.OnDeinit(reason);
         break;
      case BolaWprSt:
         MyBolWprSt.OnDeinit(reason);
         break;
      case Didi:
         MyDidiExp.OnDeinit(reason);
         break;
      case TresMed:
         MyTresMedExp.OnDeinit(reason);
         break;
      case ATRStp:
         MyAtrStpExp.OnDeinit(reason);
         break;
      case PTLRSO:
         MyPTLRSOExp.OnDeinit(reason);
         break;
      case Regress:
         MyLinRegExp.OnDeinit(reason);
         break;
      case HiLoPrNY:
         MyHiLoPrNY.OnDeinit(reason);
         break;
      case FPCHANN:
         MyFPRobot.OnDeinit(reason);
         break;
      case BollingEst:
         MyBollingerRobot.OnDeinit(reason);
         break;

      default:
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
      case BolaWprSt:
         MyBolWprSt.OnTimer();
         break;
      case Didi:
         MyDidiExp.OnTimer();
         break;
      case TresMed:
         MyTresMedExp.OnTimer();
         break;
      case ATRStp:
         MyAtrStpExp.OnTimer();
         break;

      case PTLRSO:
         MyPTLRSOExp.OnTimer();
         break;
      case Regress:
         MyLinRegExp.OnTimer();
         break;

      case HiLoPrNY:
         MyHiLoPrNY.OnTimer();
         break;

      case FPCHANN:
         MyFPRobot.OnTimer();
         break;

      case BollingEst:
         MyBollingerRobot.OnTimer();
         break;

      default:
         break;

     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {

   switch(Estrategia)
     {
      case Afast:
         MyAfastMed.OnTradeTransaction(trans,request,result);
         break;
      case BolaWprSt:
         MyBolWprSt.OnTradeTransaction(trans,request,result);
         break;
      case Didi:
         MyDidiExp.OnTradeTransaction(trans,request,result);
         break;
      case TresMed:
         MyTresMedExp.OnTradeTransaction(trans,request,result);
         break;
      case ATRStp:
         MyAtrStpExp.OnTradeTransaction(trans,request,result);
         break;
      case PTLRSO:
         MyPTLRSOExp.OnTradeTransaction(trans,request,result);
         break;
      case Regress:
         MyLinRegExp.OnTradeTransaction(trans,request,result);
         break;
      case HiLoPrNY:
         MyHiLoPrNY.OnTradeTransaction(trans,request,result);
         break;
      case FPCHANN:
         MyFPRobot.OnTradeTransaction(trans,request,result);
         break;
      case BollingEst:
         MyBollingerRobot.OnTradeTransaction(trans,request,result);
         break;

      default:
         break;

     }

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   hora_ent=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)+" "+end_hour_ent);
   if(TimeCurrent()>hora_ent)TimeEnt=false;
   else TimeEnt=true;
   if(UsarADX)
     {
      adx.Refresh();

      switch(Estrategia)
        {
         case Afast:
            if(operacao==Favor)
              {
               if(adx.Main(0)>=adxmin)AdxAllow=true;
               else AdxAllow=false;
              }
            if(operacao==Contra)
              {
               if(adx.Main(0)<=adx_lim)AdxAllow=true;
               else AdxAllow=false;
              }

            break;
         case BolaWprSt:
            if(adx.Main(0)>=adxmin)AdxAllow=true;
            else AdxAllow=false;
            break;
         case Didi:
            if(adx.Main(0)>=adxmin)AdxAllow=true;
            else AdxAllow=false;
            break;
         case TresMed:
            if(adx.Main(0)>=adxmin)AdxAllow=true;
            else AdxAllow=false;
            break;

         case ATRStp:
            if(adx.Main(0)>=adxmin)AdxAllow=true;
            else AdxAllow=false;
            break;
         case PTLRSO:
            if(adx.Main(0)>=adxmin)AdxAllow=true;
            else AdxAllow=false;
            break;
         case Regress:
            if(adx.Main(0)<=adx_lim)AdxAllow=true;
            else AdxAllow=false;
            break;
         case HiLoPrNY:
            if(adx.Main(0)>=adxmin)AdxAllow=true;
            else AdxAllow=false;
            break;

         case FPCHANN:
            if(adx.Main(0)<=adx_lim)AdxAllow=true;
            else AdxAllow=false;
            break;

         case BollingEst:

            if(entr_Boll==EntBFFFD || entr_Boll==EntBTick)
              {
               if(adx.Main(0)<=adx_lim)AdxAllow=true;
               else AdxAllow=false;
              }

            if(entr_Boll==EntBTickFav || entr_Boll==EntBFav)
              {
               if(adx.Main(0)>=adxmin)AdxAllow=true;
               else AdxAllow=false;
              }

            break;

         default:
            if(adx.Main(0)>=adxmin)AdxAllow=true;
            else AdxAllow=false;

            break;

        }
     }
   switch(Estrategia)
     {
      case Afast:
         MyAfastMed.OnTick();
         if((!MQLInfoInteger(MQL_OPTIMIZATION)) && (!FecharPainel)) ExtDialog.OnTick(MyAfastMed);
         break;
      case BolaWprSt:
         MyBolWprSt.OnTick();
         if((!MQLInfoInteger(MQL_OPTIMIZATION)) && (!FecharPainel)) ExtDialog.OnTick(MyBolWprSt);
         break;
      case Didi:
         MyDidiExp.OnTick();
         if((!MQLInfoInteger(MQL_OPTIMIZATION)) && (!FecharPainel)) ExtDialog.OnTick(MyDidiExp);
         break;
      case TresMed:
         MyTresMedExp.OnTick();
         if((!MQLInfoInteger(MQL_OPTIMIZATION)) && (!FecharPainel)) ExtDialog.OnTick(MyTresMedExp);
         break;

      case ATRStp:
         MyAtrStpExp.OnTick();
         if((!MQLInfoInteger(MQL_OPTIMIZATION)) && (!FecharPainel)) ExtDialog.OnTick(MyAtrStpExp);
         break;
      case PTLRSO:
         MyPTLRSOExp.OnTick();
         if((!MQLInfoInteger(MQL_OPTIMIZATION)) && (!FecharPainel)) ExtDialog.OnTick(MyPTLRSOExp);
         break;
      case Regress:
         MyLinRegExp.OnTick();
         if((!MQLInfoInteger(MQL_OPTIMIZATION)) && (!FecharPainel)) ExtDialog.OnTick(MyLinRegExp);
         break;
      case HiLoPrNY:
         MyHiLoPrNY.OnTick();
         if((!MQLInfoInteger(MQL_OPTIMIZATION)) && (!FecharPainel)) ExtDialog.OnTick(MyHiLoPrNY);
         break;

      case FPCHANN:
         MyFPRobot.OnTick();
         if((!MQLInfoInteger(MQL_OPTIMIZATION)) && (!FecharPainel)) ExtDialog.OnTick(MyFPRobot);
         break;

      case BollingEst:
         MyBollingerRobot.OnTick();
         if((!MQLInfoInteger(MQL_OPTIMIZATION)) && (!FecharPainel)) ExtDialog.OnTick(MyBollingerRobot);
         break;

      default:
         break;

     }
  }
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
   if(!FecharPainel)
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
bool MyPanel::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {

   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2))
      return(false);

   int xx1=INDENT_LEFT;
   int yy1=INDENT_TOP;
   int xx2=x1+BUTTON_WIDTH;
   int yy2=INDENT_TOP+BUTTON_HEIGHT;


   if(!CreateLabel(m_chart_id,m_subwin,label_setup,"Setup: "+setup_name,xx1,yy1,xx2,yy2))
      return(false);


   xx1=INDENT_LEFT;
   yy1=INDENT_TOP+BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;



   int cotx1,cotx2,porcx1,porcx2;

   int col1=INDENT_LEFT;
   int col2=(int) (0.4*LARGURA_PAINEL)+INDENT_LEFT;
   int col3=(int) (0.7*LARGURA_PAINEL)+INDENT_LEFT;


   cotx1=col2;
   cotx2=col3-INDENT_LEFT;

   porcx1=col3;
   porcx2=LARGURA_PAINEL-INDENT_LEFT;

   double price_last,price_high,price_low,price_open,price_mean;
   double porc_last,porc_high,porc_low,porc_open;
   double fech_ant=iClose(Symbol(),PERIOD_D1,1);
   double dist_ant,amp_dia;
   dist_ant=iClose(Symbol(),PERIOD_D1,0)-fech_ant;
   price_last=SymbolInfoDouble(Symbol(),SYMBOL_LAST);
   price_high=SymbolInfoDouble(Symbol(),SYMBOL_LASTHIGH);
   price_low=SymbolInfoDouble(Symbol(),SYMBOL_LASTLOW);
   price_open=iOpen(Symbol(),PERIOD_D1,0);
   price_mean=MathRound((0.5)*(price_high+price_low)/SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE))*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE);
   price_mean=NormalizeDouble(price_mean,_Digits);
   amp_dia=price_high-price_low;
   porc_last=((price_last-fech_ant)/fech_ant)*100;
   porc_high=((price_high-fech_ant)/fech_ant)*100;
   porc_low=((price_low-fech_ant)/fech_ant)*100;
   porc_open=((price_open-fech_ant)/fech_ant)*100;

//--- create dependent controls 

   if(!CreateLabel(m_chart_id,m_subwin,m_label[0],"Último: ",xx1,yy1,xx2,yy2))
      return(false);


   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[0],DoubleToString(price_last,_Digits),cotx1,yy1,cotx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_porc[0],DoubleToString(porc_last,2)+"%",porcx1,yy1,porcx2,yy2))
      return(false);


   xx1=col1;
   yy1=INDENT_TOP+2*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;


   if(!CreateLabel(m_chart_id,m_subwin,m_label[1],"Abertura: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[1],DoubleToString(price_open,_Digits),cotx1,yy1,cotx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_porc[1],DoubleToString(porc_open,2)+"%",porcx1,yy1,porcx2,yy2))
      return(false);


   xx1=col1;
   yy1=INDENT_TOP+3*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[2],"Máxima: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[2],DoubleToString(price_high,_Digits),cotx1,yy1,cotx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_porc[2],DoubleToString(porc_high,2)+"%",porcx1,yy1,porcx2,yy2))
      return(false);

   xx1=col1;
   yy1=INDENT_TOP+4*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[3],"Mínima: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[3],DoubleToString(price_low,_Digits),cotx1,yy1,cotx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_porc[3],DoubleToString(porc_low,2)+"%",porcx1,yy1,porcx2,yy2))
      return(false);


   xx1=col1;
   yy1=INDENT_TOP+5*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[4],"Média: ",xx1,yy1,xx2,yy2))
      return(false);


   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[4],DoubleToString(price_mean,_Digits),cotx1,yy1,cotx2,yy2))
      return(false);


   xx1=col1;
   yy1=2*INDENT_TOP+6*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[5],"Fechamento Dia Anterior: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[5],DoubleToString(fech_ant,_Digits),porcx1,yy1,porcx2,yy2))
      return(false);




   xx1=col1;
   yy1=2*INDENT_TOP+7*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[6],"Distância Dia Anterior: ",xx1,yy1,xx2,yy2))
      return(false);


   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[6],DoubleToString(dist_ant,_Digits),porcx1,yy1,porcx2,yy2))
      return(false);




   xx1=col1;
   yy1=2*INDENT_TOP+8*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[7],"Amplitude Dia: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[7],DoubleToString(amp_dia,_Digits),porcx1,yy1,porcx2,yy2))
      return(false);


   xx1=col1;
   yy1=3*INDENT_TOP+9*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[8],"Posição: ",xx1,yy1,xx2,yy2))
      return(false);


   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[8],"",cotx1,yy1,cotx2,yy2))
      return(false);



   xx1=col1;
   yy1=3*INDENT_TOP+10*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[9],"Preço: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[9],"",cotx1,yy1,cotx2,yy2))
      return(false);
   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[10],"",porcx1,yy1,porcx2,yy2))
      return(false);



   xx1=col1;
   yy1=3*INDENT_TOP+11*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[10],"Volume: ",xx1,yy1,xx2,yy2))
      return(false);
   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[11],"",cotx1,yy1,cotx2,yy2))
      return(false);


   xx1=col1;
   yy1=3*INDENT_TOP+12*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[11],"Profit: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[12],"",cotx1,yy1,cotx2,yy2))
      return(false);
   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[13],"",porcx1,yy1,porcx2,yy2))
      return(false);



   xx1=col1;
   yy1=3*INDENT_TOP+13*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[12],"Pontos: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[14],"",cotx1,yy1,cotx2,yy2))
      return(false);
   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[15],"",porcx1,yy1,porcx2,yy2))
      return(false);


   xx1=col1;
   yy1=4*INDENT_TOP+14*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[13],"Volume Ordens Pedentes: ",xx1,yy1,xx2,yy2))
      return(false);

   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[16],"",porcx1,yy1,porcx2,yy2))
      return(false);



   xx1=col1;
   yy1=5*INDENT_TOP+15*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[14],"Resultado Mensal: ",xx1,yy1,xx2,yy2))
      return(false);
   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[17],"",porcx1,yy1,porcx2,yy2))
      return(false);


   xx1=col1;
   yy1=5*INDENT_TOP+16*BUTTON_HEIGHT+CONTROLS_GAP_Y;
   xx2=xx1+BUTTON_WIDTH;
   yy2=yy1+BUTTON_HEIGHT;

   if(!CreateLabel(m_chart_id,m_subwin,m_label[15],"Resultado Diário: ",xx1,yy1,xx2,yy2))
      return(false);
   if(!CreateLabel(m_chart_id,m_subwin,label_cotacao[18],"",porcx1,yy1,porcx2,yy2))
      return(false);


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

template<typename T>
void MyPanel::OnTick(T &MyEA)
  {
   double price_last,price_high,price_low,price_open,price_mean;
   double porc_last,porc_high,porc_low,porc_open;
   double fech_ant=iClose(Symbol(),PERIOD_D1,1);
   double dist_ant,amp_dia;
   bool PanelBuyOpened=false;
   bool PanelSellOpened=false;
   double preco_medio=0.0;
   double vol_pos=0.0;
   bool PanelPosOpen = false;
   double profit_pos = 0.0;
   double PanelStopLoss=0.0;
   double PanelTakeProfit=0.0;
   double PanelVolOrdAb=0.0;
   double PanelLucroTotMes= 0.0;
   double PanelLucroTotal = 0.0;

   PanelBuyOpened=MyEA.Buy_opened();
   PanelSellOpened=MyEA.Sell_opened();
   PanelPosOpen=MyEA.PosicaoAberta();
   PanelStopLoss=MyEA.StopLoss();
   PanelTakeProfit=MyEA.TakeProfit();
   PanelVolOrdAb=MyEA.VolOrdAbert();
   PanelLucroTotMes= MyEA.LucroTotalMes();
   PanelLucroTotal = MyEA.LucroTotal();
   preco_medio=MyEA.PrecoMedio(POSITION_TYPE_BUY)+MyEA.PrecoMedio(POSITION_TYPE_SELL);
   PanelPosOpen=MyEA.PosicaoAberta();
   if(PanelPosOpen)vol_pos=MyEA.VolPosType(POSITION_TYPE_BUY)+MyEA.VolPosType(POSITION_TYPE_SELL);
   profit_pos=MyEA.LucroPositions();
   PanelStopLoss=MyEA.StopLoss();
   PanelTakeProfit=MyEA.TakeProfit();
   PanelVolOrdAb=MyEA.VolOrdAbert();
   PanelLucroTotMes= MyEA.LucroTotalMes();
   PanelLucroTotal = MyEA.LucroTotal();


   dist_ant=iClose(Symbol(),PERIOD_D1,0)-fech_ant;
   price_last = SymbolInfoDouble(Symbol(), SYMBOL_LAST);
   price_high = SymbolInfoDouble(Symbol(), SYMBOL_LASTHIGH);
   price_low=SymbolInfoDouble(Symbol(),SYMBOL_LASTLOW);
   price_open = iOpen(Symbol(), PERIOD_D1, 0);
   price_mean = MathRound((0.5) * (price_high + price_low) / SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE)) * SymbolInfoDouble(Symbol(), SYMBOL_TRADE_TICK_SIZE);
   price_mean = NormalizeDouble(price_mean, _Digits);
   amp_dia=price_high-price_low;
   porc_last = ((price_last - fech_ant) / fech_ant) * 100;
   porc_high = ((price_high - fech_ant) / fech_ant) * 100;
   porc_low=((price_low-fech_ant)/fech_ant)*100;
   porc_open = ((price_open - fech_ant) / fech_ant) * 100;
   for(int i = 0; i < 8; i++)
      label_cotacao[i].Color(clrGreen);

   for(int i=0; i<4; i++)
      label_porc[i].Color(clrGreen);
   label_cotacao[0].Text(DoubleToString(price_last,_Digits));
   if(price_last<fech_ant)
      label_cotacao[0].Color(clrRed);
   label_porc[0].Text(DoubleToString(porc_last,2)+"%");
   if(porc_last<0)
      label_porc[0].Color(clrRed);
   label_cotacao[1].Text(DoubleToString(price_open,_Digits));
   if(price_open<fech_ant)
      label_cotacao[1].Color(clrRed);
   label_porc[1].Text(DoubleToString(porc_open,2)+"%");
   if(porc_open<0)
      label_porc[1].Color(clrRed);
   label_cotacao[2].Text(DoubleToString(price_high,_Digits));
   if(price_high<fech_ant)
      label_cotacao[2].Color(clrRed);
   label_porc[2].Text(DoubleToString(porc_high,2)+"%");
   if(porc_high<0)
      label_porc[2].Color(clrRed);
   label_cotacao[3].Text(DoubleToString(price_low,_Digits));
   if(price_low<fech_ant)
      label_cotacao[3].Color(clrRed);
   label_porc[3].Text(DoubleToString(porc_low,2)+"%");
   if(porc_low<0)
      label_porc[3].Color(clrRed);
   label_cotacao[4].Text(DoubleToString(price_mean,_Digits));
   if(price_mean<fech_ant)
      label_cotacao[4].Color(clrRed);
   label_cotacao[5].Text(DoubleToString(fech_ant, _Digits));
   label_cotacao[6].Text(DoubleToString(dist_ant, _Digits));
   if(dist_ant<0)
      label_cotacao[6].Color(clrRed);
   label_cotacao[7].Text(DoubleToString(amp_dia,_Digits));
   if(price_last<fech_ant)
      label_cotacao[7].Color(clrRed);

   string s_pos;
   if(PanelBuyOpened)
     {
      s_pos="COMPRA";
      label_cotacao[8].Color(clrGreen);
     }
   else if(PanelSellOpened)
     {
      s_pos="VENDA";
      label_cotacao[8].Color(clrRed);
     }
   else s_pos="ZERADO";

   label_cotacao[8].Text(s_pos);
   string s_medio=DoubleToString(preco_medio,_Digits);
   label_cotacao[9].Text(s_medio);
   label_cotacao[9].Color(clrGreen);
   double por_preco_medio=0.0;
   if(preco_medio!=0) por_preco_medio=((preco_medio-fech_ant)/fech_ant)*100;

   label_cotacao[10].Text(DoubleToString(por_preco_medio,2)+"%");
   if(por_preco_medio>=0)label_cotacao[10].Color(clrGreen);
   else  label_cotacao[10].Color(clrRed);

   label_cotacao[11].Text(DoubleToString(vol_pos,2));
   label_cotacao[11].Color(clrGreen);
   label_cotacao[12].Text(DoubleToString(profit_pos,2));
   if(profit_pos>=0)label_cotacao[12].Color(clrGreen);
   else label_cotacao[12].Color(clrRed);

   label_cotacao[13].Text("SL: "+DoubleToString(PanelStopLoss,_Digits));
   label_cotacao[13].Color(clrRed);
   double s_pontos=0;
   if(PanelBuyOpened)s_pontos=price_last-preco_medio;
   if(PanelSellOpened)s_pontos=preco_medio-price_last;

   label_cotacao[14].Text(DoubleToString(s_pontos,_Digits));
   if(s_pontos>=0)label_cotacao[14].Color(clrGreen);
   else label_cotacao[14].Color(clrRed);
   label_cotacao[15].Text("TP: "+DoubleToString(PanelTakeProfit,_Digits));
   label_cotacao[15].Color(clrGreen);
   label_cotacao[16].Text(DoubleToString(PanelVolOrdAb,2));
   label_cotacao[17].Text(DoubleToString(PanelLucroTotMes,2));
   label_cotacao[18].Text(DoubleToString(PanelLucroTotal,2));
  }
//+------------------------------------------------------------------+ 
//| Event Handling                                                   | 
//+------------------------------------------------------------------+ 
EVENT_MAP_BEGIN(MyPanel)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
