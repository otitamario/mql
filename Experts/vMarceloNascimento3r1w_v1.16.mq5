//+------------------------------------------------------------------+
//|                                         Marcelo Nascimento 3.mq5 |
//|                 Copyright © 2014-2019, Evilanio de Souza Almeida |
//|                                 evilaniodesouzaalmeida@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Developer 2014-2019, Evilanio de Souza Almeida"
#property link      "evilaniodesouzaalmeida@gmail.com"
#property version   "1.16"
//#property icon "pro.ico"
#property description "Contato: evilaniodesouzaalmeida@gmail.com"
#property strict

#include <Trade\PositionInfo.mqh>
#include <Trade\HistoryOrderInfo.mqh>
#include <Trade\Trade.mqh>
CPositionInfo  positionInfo;
CHistoryOrderInfo historyInfo;
CTrade trade;
CPositionInfo myposition;
CSymbolInfo mysymbol;
COrderInfo myorder;
enum ENUM_HEADER{};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum TipoLucPontos
  {
   LucPont,//Lucro Pontos
   LucPontMed//Lucro Ponto Médio
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
enum ENUM_BAR
  {
   BAR_CURRENT,//Durante formação do candle
   BAR_PREVIOUS//Após formação do candle
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_TRADING_TYPE
  {
   TRADING_BUY_SELL,//Comprado e Vendido
   TRADING_BUY_ONLY,//Só Comprado
   TRADING_SELL_ONLY//Só Vendido
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_GATILHO
  {
   GATILHO_NONE,//Nenhum
   GATILHO_MA,//Médias
   GATILHO_ADX//ADX   
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_BB_EXIT
  {
   BB_NONE,//Não usar
   BB_MA,//Sair na média
   BB_OPOSITE//Banda oposta
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_ENVELOPES_EXIT
  {
   ENVELOPES_NONE,//Não usar
   ENVELOPES_MIDLINE,//Sair na midline
   ENVELOPES_OPOSITE//Banda oposta
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_MURREY_LINES
  {
   MURREY_PLUS_2_8P=12,//+2/8P
   MURREY_PLUS_1_8P=11,//+1/8P
   MURREY_8_8P=10,//8/8P
   MURREY_7_8P=9,//7/8P
   MURREY_6_8P=8,//6/8P
   MURREY_5_8P=7,//5/8P
   MURREY_4_8P=6,//4/8P
   MURREY_3_8P=5,//3/8P
   MURREY_2_8P=4,//2/8P
   MURREY_1_8P=3,//1/8P
   MURREY_0_8P=2,//0/8P
   MURREY_MINUS_1_8P=1,//-1/8P
   MURREY_MINUS_2_8P=0//-2/8P
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum ENUM_TUNNEL_OF_VEGAS_LINES
  {
   TOV_7=7, // +7
   TOV_6=6, // +6
   TOV_5=5, // +5
   TOV_4=4, // +4
   TOV_3=3, // +3
   TOV_2=2, // +2
   TOV_1=1, // +1
   TOV_0=0, // 0
   TOV__1=-1, // -1
   TOV__2=-2, // -2
   TOV__3=-3, // -3
   TOV__4=-4, // -4
   TOV__5=-5, // -5
   TOV__6=-6, // -6
   TOV__7=-7, // -7
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct ORDER
  {
   ulong             ticket;
   int               trailing;
   bool              breakeven;
   datetime          openTime;
   double            pointCross;
                     ORDER(): pointCross(0){}
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct BACKUP
  {
   datetime          once;
   bool              murreyUp;
   bool              murreyDn;
   bool              tunnelOfVegasUp;
   bool              tunnelOfVegasDn;
   bool              sobrecomprado;
   bool              sobrevendido;
   bool              buy;
   bool              sell;
                     BACKUP(): once(0){}
   void Reset()
     {
      buy=0;
      sell=0;
      murreyDn=0;
      murreyUp=0;
      tunnelOfVegasUp=0;
      tunnelOfVegasDn=0;
     }
  }
backup;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct virtualSLStruct
  {
   ulong             ticket;
   double            sL;
   string            symbol;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct partialCloseTicketsStruct
  {
   ulong             ticket;
   int               num;
  };
//---
enum ELotsMod
  {
   LOT_ADD     =0,   //Lots To Add
   LOT_MULT    =1    //Lot Multiplier
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input string Simbolo="EURUSD"; // Symbol For Trading (Chart For Data)
input ENUM_TRADING_TYPE TradingType=TRADING_BUY_SELL;//Operar
input ENUM_BAR Bar=BAR_PREVIOUS;//Analisar
input double Lot=0.01;

input    ELotsMod       LotMod=LOT_MULT;  //Second Order Lots Mode;

input double secondOrderLotValue=2.0;   // Second Order Lots Value
input int afterSecondOrderTradesToAddLots=0; // After Second Order, Trades To Add Lots
input int TakeProfit=300;
input int StopLoss=100;
input int minimumMovementAfterTrade=0; // Minimum Movement After Trade (Points)

input    double      MultStep=1.5;    //Minimum movement multiplier factor

input int partialCloseOffset=0;  // Partial Close Offset (Points)
input double partialCloseLots=0.01; // Partial Close Lots
input int maximumPartialCloses=0;   // Maximum Partial Closes (0=Unlimited)
input ENUM_BOOLEANO virtualTrailingStop=BOOL_NO;   // Virtual Trailing Stop
input color virtualTrailingStopColor=clrRed; // Virtual Trailing Stop Color
input int TralingStart=100;// Início do trailing
input int TrailingStop=100;// Trailing Stop Distance (Points)
input int TrailingStep=5;//Passo do trailing
input ENUM_BOOLEANO virtualBreakeven=BOOL_NO;   // Virtual Breakeven
input color virtualBreakevenColor=clrRed;  // Virtual Breakeven Color
input int BreakevenStart=50;//Ativar breakeven
input int BreakevenProfit=20;//Pontos pra avançar
input int MaxOrders=5;//Máximo de ordens abertas
input int MaxSpread=10;//Spread máximo
input ENUM_BOOLEANO Domingo=BOOL_NO;
input ENUM_BOOLEANO Segunda=BOOL_YES;
input ENUM_BOOLEANO Terca=BOOL_YES;//Terça
input ENUM_BOOLEANO Quarta=BOOL_YES;
input ENUM_BOOLEANO Quinta=BOOL_YES;
input ENUM_BOOLEANO Sexta=BOOL_YES;
input ENUM_BOOLEANO UseSession=BOOL_NO;//Usar sessão de negociação
input string SessionStart="09:00";//Início da sessão de negociação
input string SessionEnd="17:00";//Fim da sessão de negociação
input ENUM_BB_EXIT UseCloseBB=BB_MA;//Fechar ordens pelo Bollinger Bands
input ENUM_ENVELOPES_EXIT UseCloseEnvelopes=ENVELOPES_NONE;//Fechar ordens pelo Envelopes
input ENUM_BOOLEANO UseCloseTunnelOfVegas=BOOL_NO; // Close Orders At Tunnel Of Vegas Midline
sinput ENUM_HEADER _00;//### Gatilhos ###
input ENUM_BOOLEANO invertSignal=BOOL_NO; // Invert Signal?
input ENUM_GATILHO GatilhoType=GATILHO_MA;//Tipo do gatilho
input ENUM_BOOLEANO StopTrade=BOOL_NO;//Stop trade
input int CheckBarStart=3;//Início da verificação 
input int CheckBarEnd=10;//Fim da verificação 
input int PointsStopTrade=50;//Pontos depois do rompimento
sinput ENUM_HEADER _0;//=== Médias ===
sinput ENUM_HEADER _1;//--- Média Rápida ---
input int MAPeriod=4;//Período
input ENUM_MA_METHOD MAMetodo=MODE_SMA;//Método
input ENUM_APPLIED_PRICE MAAplicado=PRICE_CLOSE;//Aplicado
sinput ENUM_HEADER _2;//--- Média Lenta ---
input int MAPeriod2=8;//Período
input ENUM_MA_METHOD MAMetodo2=MODE_SMA;//Método
input ENUM_APPLIED_PRICE MAAplicado2=PRICE_CLOSE;//Aplicado
sinput ENUM_HEADER _3;//=== ADX ===
input double ADXLevelTrend=20;//Nível de tendência
input int ADXPeriod=14;//Período
sinput ENUM_HEADER _01;//### Filtros ###
sinput ENUM_HEADER _4;//=== RSI ===
input ENUM_BOOLEANO UseRSI=BOOL_YES;//Usar RSI
input int RsiPeriod=14;//Período
input ENUM_APPLIED_PRICE RsiAplicado=PRICE_CLOSE;//Aplicado
input double RSISobrecompra=70;
input double RSISobrevenda=30;
sinput ENUM_HEADER _4b;//=== CCI ===
input ENUM_BOOLEANO UseCCI=BOOL_NO;//Usar CCI
input int CCIPeriod=14;//Período
input ENUM_APPLIED_PRICE CCIAplicado=PRICE_TYPICAL;//Aplicado
input double CCISobrecompra=100;
input double CCISobrevenda=-100;
input ENUM_HEADER _5;//=== Stochastic === 
input ENUM_BOOLEANO UseStoc=BOOL_YES;//Usar Stochastic
input int StocPeriodK=5;//Período %K
input int StocRetardar=3;//Retardar
input int StocPeriodD=3;//Período %D
input ENUM_STO_PRICE StocPrice=STO_LOWHIGH;//Campo do preço
input ENUM_MA_METHOD StocMetodo=MODE_SMA;//Método
input double StocSobrecompra=80;
input double StocSobrevenda=20;
input ENUM_HEADER _6;//=== Bollinger Bands ===
input ENUM_BOOLEANO UseBB=BOOL_YES;//Usar Bollinger Bands
input int BBPeriod=20;//Período
input int BBDeslocar=0;//Deslocar
input double BBDesvios=2;//Desvios
input ENUM_APPLIED_PRICE BBAplicado=PRICE_CLOSE;//Aplicado
input ENUM_HEADER _6b;//=== Envelopes ===
input ENUM_BOOLEANO UseEnvelopes=BOOL_NO;//Usar Envelopes
input int EnvelopesPeriod=14;//Período
input int EnvelopesDeslocar=0;//Deslocar
input double EnvelopesDesvios=0.1;//Desvios
input ENUM_MA_METHOD EnvelopesMetodo=MODE_SMA;//Método
input ENUM_APPLIED_PRICE EnvelopesAplicado=PRICE_CLOSE;//Aplicado
input ENUM_HEADER _7;//=== Filtro Linhas de Murrey ===
input ENUM_BOOLEANO UseMurrey=BOOL_YES;//Habilitar o filtro de linhas de murrey
input ENUM_MURREY_LINES MurreyUp=MURREY_8_8P;//Linha superior
input ENUM_MURREY_LINES MurreyDn=MURREY_1_8P;//Linha inferior
input int P=90;
input ENUM_TIMEFRAMES MMPeriod=PERIOD_D1;
input int StepBack=0;                    // Bar index for levels calculation
input ENUM_HEADER _8;   //=== Tunnel Of Vegas ===
input ENUM_BOOLEANO UseTunnelOfVegas=BOOL_NO;   // Use Tunnel Of Vegas?
input ENUM_TUNNEL_OF_VEGAS_LINES tunnelOfVegasUpperLine=5;   // Upper Line
input ENUM_TUNNEL_OF_VEGAS_LINES tunnelOfVegasLowerLine=-5;   // Lower Line
input ENUM_HEADER _9; // === Tunnel Of Vegas Parameters ===
input int tunnelOfVegasMAPeriod=200; // Tunnel Of Vegas MA Period
input ENUM_MA_METHOD tunnelOfVegasMAMethod=MODE_SMMA; // Tunnel Of Vegas MA Method
input ENUM_APPLIED_PRICE tunnelOfVegasAppliedPrice=PRICE_CLOSE; // Tunnel Of Vegas Applied Price
input int tunnelOfVegasMAShift=0; // Tunnel Of Vegas MA Shift
input int tunnelOfVegasLevel1=550; // Tunnel Of Vegas Level +/- 1
input int tunnelOfVegasLevel2=890; // Tunnel Of Vegas Level +/- 2
input int tunnelOfVegasLevel3=1440; // Tunnel Of Vegas Level +/- 3
input int tunnelOfVegasLevel4=2330; // Tunnel Of Vegas Level +/- 4
input int tunnelOfVegasLevel5=3770; // Tunnel Of Vegas Level +/- 5
input int tunnelOfVegasLevel6=6100; // Tunnel Of Vegas Level +/- 6
input int tunnelOfVegasLevel7=9870; // Tunnel Of Vegas Level +/- 7
input string BackupName="0";
input int magicNumber=77777; // Magic Number
sinput color ColorBottonSell=clrTomato; // BUY button color 
sinput color ColorBottonBuy=clrDodgerBlue; // SELL button color
sinput color ColorBottonFont=clrWhite; // Button text color
sinput string Lucro="#####################################################"; //Usar Lucro/Prejuizo para Fechamento
input ENUM_BOOLEANO UsarLucroMoeda=BOOL_NO;//Usar Filtro Lucro em Moeda
input double lucro=1000.0;//Lucro em Moeda para Fechar Posicoes a
input double prejuizo=500.0;//Prejuizo em Moeda para Fechar Posicoes
input ENUM_BOOLEANO UsarLucroPontos=BOOL_NO;//Usar Filtro Lucro em Pontos
input TipoLucPontos tipoLucPont=LucPont;//Tipo de Lucro em Pontos
input double lucro_pontos=1000.0;//Lucro em Pontos para Fechar Posicoes 
input double prejuizo_pontos=500.0;//Prejuizo em Pontos para Fechar Posicoes 
input ushort n_minutes=5;//Minutos de Pausa Após Fechamento pelo Filtro - 0 Não tem Pausa
bool tradeOn=true;
double lucro_total,lucro_totalpontos,ponto,lucro_totalpontosmedio;
double ticksize=SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);

string _EAPrefix="MN_EA_";

int maHandles[2],adxHandle,rsiHandle,cciHandle,stocHandle,bbHandle,envelopesHandle,murHandle,tunnelOfVegasHandle;

int lotDigits=2,sessionStart,sessionEnd,o,tradeDirection=0,numVirtualSL=0,numOpenTickets=0,numPartialCloseTickets=0;
double lotStep,maxLot,minLot,tickSize,lastMovementPrice=0;
string program=MQLInfoString(MQL_PROGRAM_NAME);
string backupName1,backupName2,ermsg;
bool waitForMovement=false;
ORDER orders[];
virtualSLStruct virtualSL[]={};
ulong openTickets[]={};
partialCloseTicketsStruct partialCloseTickets[]={};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(!LicenseValidation())
      return(INIT_FAILED);

   mysymbol.Name(Simbolo);
   ponto=SymbolInfoDouble(Simbolo,SYMBOL_POINT);
   int find_wdo=StringFind(Simbolo,"WDO");
   int find_dol=StringFind(Simbolo,"DOL");
   if(find_dol>=0|| find_wdo>=0) ponto=1.0;

   numVirtualSL=0;
   ArrayResize(virtualSL,0);
   ObjectsDeleteAll(0,"Virtual SL ");
   ObjectsDeleteAll(0,_EAPrefix);
   lotStep=mysymbol.LotsStep();
   maxLot=mysymbol.LotsMax();
   minLot=mysymbol.LotsMin();;
   tickSize=SymbolInfoDouble(Simbolo,SYMBOL_TRADE_TICK_SIZE);

   if(lotStep==0.1) lotDigits=1;
   if(lotStep==1) lotDigits=0;
   if(((Lot/lotStep)-floor(Lot/lotStep))!=0)
     {
      Alert("O Contrato precisa ser múltiplo de "+DoubleToString(lotStep,lotDigits));
      return INIT_PARAMETERS_INCORRECT;
     }
   if(Lot>maxLot)
     {
      Alert("O Contrato precisa ser igual/abaixo de "+DoubleToString(maxLot,lotDigits));
      return INIT_PARAMETERS_INCORRECT;
     }
   if(partialCloseOffset>0 && !ValidLotSize(partialCloseLots,Simbolo)) { Alert("Invalid Partial Close Lot Size ("+(string)partialCloseLots+") "+ermsg); return(INIT_PARAMETERS_INCORRECT); }
//if(secondOrderLotMultiplier>0 && secondOrderLotsToAdd>0) { Alert("You Can Only Set Either \"Second Order Lot Multiplier\" Or \"Second Order Lots To Add\""); return(INIT_PARAMETERS_INCORRECT); }
//if(secondOrderLotsToAdd>0 && !ValidLotSize(secondOrderLotsToAdd,Simbolo)) { Alert("Invalid Second Order Lots To Add ("+(string)secondOrderLotsToAdd+") "+ermsg); return(INIT_PARAMETERS_INCORRECT); }

   trade.SetExpertMagicNumber(magicNumber);
   int fill=(int)SymbolInfoInteger(Simbolo,SYMBOL_FILLING_MODE);
   trade.SetTypeFilling((ENUM_ORDER_TYPE_FILLING)(fill==0?2:fill-1));

   if(GatilhoType==GATILHO_MA)
     {
      maHandles[0]=iMA(_Symbol,0,MAPeriod,0,MAMetodo,MAAplicado);
      maHandles[1]=iMA(_Symbol,0,MAPeriod2,0,MAMetodo2,MAAplicado2);
     }
   else if(GatilhoType==GATILHO_ADX) adxHandle=iADX(_Symbol,0,ADXPeriod);
   if(UseRSI) rsiHandle=iRSI(_Symbol,0,RsiPeriod,RsiAplicado);
   if(UseCCI) cciHandle=iCCI(_Symbol,0,CCIPeriod,CCIAplicado);
   if(UseStoc) stocHandle=iStochastic(_Symbol,0,StocPeriodK,StocPeriodD,StocRetardar,StocMetodo,StocPrice);
   if(UseBB) bbHandle=iBands(_Symbol,0,BBPeriod,BBDeslocar,BBDesvios,BBAplicado);
   if(UseEnvelopes) envelopesHandle=iEnvelopes(_Symbol,0,EnvelopesPeriod,EnvelopesDeslocar,EnvelopesMetodo,EnvelopesAplicado,EnvelopesDesvios);
//if(UseMurrey) murHandle=iCustom(_Symbol,0,"mmlevls_vg(1)",P,MMPeriod,StepBack,Gray,Gray,Aqua,Yellow,Red,Green,Blue,Green,Red,Yellow,Aqua,Gray,Gray,
//   STYLE_SOLID,STYLE_DASHDOTDOT,STYLE_DASHDOTDOT,STYLE_DASHDOTDOT,STYLE_DASHDOTDOT,STYLE_DASHDOTDOT,STYLE_DASHDOTDOT,
//   STYLE_DASHDOTDOT,STYLE_DASHDOTDOT,STYLE_DASHDOTDOT,STYLE_DASHDOTDOT,STYLE_DASHDOTDOT,STYLE_SOLID,1,1,1,1,1,1,1,1,1,
//   1,1,1,1,Red,217,"Arial",11);
   if(UseTunnelOfVegas || UseCloseTunnelOfVegas) tunnelOfVegasHandle=iMA(_Symbol,0,tunnelOfVegasMAPeriod,tunnelOfVegasMAShift,tunnelOfVegasMAMethod,tunnelOfVegasAppliedPrice);
   if((GatilhoType==GATILHO_MA?maHandles[0]==INVALID_HANDLE || maHandles[1]==INVALID_HANDLE:false) || (GatilhoType==GATILHO_ADX?adxHandle==INVALID_HANDLE:false) || 
      (UseRSI?rsiHandle==INVALID_HANDLE:false) || (UseCCI?cciHandle==INVALID_HANDLE:false) || (UseStoc?stocHandle==INVALID_HANDLE:false) || 
      (UseBB?bbHandle==INVALID_HANDLE:false) || (UseEnvelopes?envelopesHandle==INVALID_HANDLE:false) || (UseMurrey?murHandle==INVALID_HANDLE:false) || 
      (UseTunnelOfVegas || UseCloseTunnelOfVegas?tunnelOfVegasHandle==INVALID_HANDLE:false))
     {
      Print("Falha ao carregar indicadores");
      return INIT_FAILED;
     }

   MqlDateTime sStart,sEnd;
   TimeToStruct(StringToTime(SessionStart),sStart);
   TimeToStruct(StringToTime(SessionEnd),sEnd);

   sessionStart=sStart.hour*60+sStart.min;
   sessionEnd=sEnd.hour*60+sEnd.min;

   backupName1=_Symbol+"\\1 "+MQLInfoString(MQL_PROGRAM_NAME)+" "+BackupName+".bcp";
   backupName2=_Symbol+"\\2 "+MQLInfoString(MQL_PROGRAM_NAME)+" "+BackupName+".bcp";
   if(!MQLInfoInteger(MQL_TESTER))
     {
      LoadBackup();
     }
   InitPartialCloses();
   InitMovementAfterTrade();

   int chart_center=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)/2;
   string obj_name;
   ButtonCreate(0,0,obj_name=_EAPrefix+"BUTTON_Buy",20,chart_center-34,90,24,CORNER_LEFT_UPPER,"BUY","Arial Black",10,ColorBottonFont,ColorBottonBuy);
   ObjectSetString(0,obj_name,OBJPROP_TOOLTIP,"Open a long trade by market");
   ButtonCreate(0,0,obj_name=_EAPrefix+"BUTTON_Sell",20,chart_center+10,90,24,CORNER_LEFT_UPPER,"SELL","Arial Black",10,ColorBottonFont,ColorBottonSell);
   ObjectSetString(0,obj_name,OBJPROP_TOOLTIP,"Open a short trade by market");

   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   tradeOn=true;
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

   lucro_total=LucroPositions();
   lucro_totalpontos=LucroPontos();
   lucro_totalpontosmedio=LucroPontosMedio();
   Comment("Profit: "+DoubleToString(lucro_total,2)+"\n"+"Pontos: "+DoubleToString(lucro_totalpontos,2)
           +"\n"+"Pontos Médio: "+DoubleToString(lucro_totalpontosmedio,2));

   if(!tradeOn)return;

   if(UsarLucroMoeda && (lucro_total>=lucro || lucro_total<=-prejuizo))
     {
      CloseALL();
      if(OrdersTotal()>0)DeleteALL();
      if(n_minutes>0)
        {
         tradeOn=false;
         EventSetTimer(n_minutes*60);
        }
      Print("Posições Fechadas no lucro ou prejuizo em MOEDA");
     }

   if(UsarLucroPontos)
     {
      if(tipoLucPont==LucPont && (lucro_totalpontos>=lucro_pontos || lucro_totalpontos<=-prejuizo_pontos))
        {
         CloseALL();
         if(OrdersTotal()>0)DeleteALL();
         if(n_minutes>0)
           {
            tradeOn=false;
            EventSetTimer(n_minutes*60);
           }
         Print("Posições Fechadas no lucro ou prejuizo de PONTOS");
        }

      if(tipoLucPont==LucPontMed && (lucro_totalpontosmedio>=lucro_pontos || lucro_totalpontosmedio<=-prejuizo_pontos))
        {
         CloseALL();
         if(OrdersTotal()>0)DeleteALL();
         if(n_minutes>0)
           {
            tradeOn=false;
            EventSetTimer(n_minutes*60);
           }
         Print("Posições Fechadas no lucro ou prejuizo de PONTOS");
        }

     }

   int direction=0;
   double newSL=0,ma,upper,lower,mid,line=0;
   string symbol;
   ulong ticket;
   numOpenTickets=0;
   ArrayResize(openTickets,0);
   for(int i=o-1; i>=0 && o!=0; i--)
     {
      if(PositionSelectByTicket(ticket=orders[i].ticket))
        {
         symbol=PositionGetString(POSITION_SYMBOL);
         if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY) direction=tradeDirection=1;
         else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL) direction=tradeDirection=-1;
         else direction=tradeDirection=0;
         //Modify
         if((TakeProfit && !PositionGetDouble(POSITION_TP)) || (StopLoss && !PositionGetDouble(POSITION_SL)))
           {
            double tp=0,sl=0;
            if(TakeProfit) tp=NormalizeTick(PositionGetDouble(POSITION_PRICE_OPEN)+(!PositionGetInteger(POSITION_TYPE)?1:-1)*TakeProfit*PointSize(symbol));
            if(StopLoss) sl=NormalizeTick(PositionGetDouble(POSITION_PRICE_OPEN)+(!PositionGetInteger(POSITION_TYPE)?-1:1)*StopLoss*PointSize(symbol));
            if(tp || sl) trade.PositionModify(orders[i].ticket,sl,tp);
           }
         string comentario=PositionGetString(POSITION_COMMENT);
         if(!invertSignal && StringFind(comentario,"MANUAL")<0)
           {
            //Close bb
            if(UseCloseBB)
              {
               if(direction==1)
                 {
                  if(UseCloseBB==BB_MA)
                    {
                     ma=GetInd(bbHandle,0,"Bollinger Bands",Bar);
                     if(ma!=-1 && iClose(_Symbol,0,int(Bar))>ma)
                       {
                        CloseAll(0);
                        continue;
                       }
                    }
                  else if(UseCloseBB==BB_OPOSITE)
                    {
                     upper=GetInd(bbHandle,1,"Bollinger Bands",Bar);
                     if(upper!=-1 && iClose(_Symbol,0,int(Bar))>=upper)
                       {
                        CloseAll(0);
                        continue;
                       }
                    }
                 }
               if(direction==-1)
                 {
                  if(UseCloseBB==BB_MA)
                    {
                     ma=GetInd(bbHandle,0,"Bollinger Bands",Bar);
                     if(ma!=-1 && iClose(_Symbol,0,int(Bar))<ma)
                       {
                        CloseAll(1);
                        continue;
                       }
                    }
                  else if(UseCloseBB==BB_OPOSITE)
                    {
                     lower=GetInd(bbHandle,2,"Bollinger Bands",Bar);
                     if(lower!=-1 && iClose(_Symbol,0,int(Bar))<=lower)
                       {
                        CloseAll(1);
                        continue;
                       }
                    }
                 }
              }
            //Close Envelopes
            if(UseCloseEnvelopes)
              {
               if(direction==1)
                 {
                  if(UseCloseEnvelopes==ENVELOPES_MIDLINE)
                    {
                     mid=(GetInd(envelopesHandle,UPPER_LINE,"Envelopes",Bar)+GetInd(envelopesHandle,LOWER_LINE,"Envelopes",Bar))/2.0;
                     if(mid!=-1 && iClose(_Symbol,0,int(Bar))>mid)
                       {
                        CloseAll(0);
                        continue;
                       }
                    }
                  else if(UseCloseEnvelopes==ENVELOPES_OPOSITE)
                    {
                     upper=GetInd(envelopesHandle,UPPER_LINE,"Envelopes",Bar);
                     if(upper!=-1 && iClose(_Symbol,0,int(Bar))>=upper)
                       {
                        CloseAll(0);
                        continue;
                       }
                    }
                 }
               if(direction==-1)
                 {
                  if(UseCloseEnvelopes==ENVELOPES_MIDLINE)
                    {
                     mid=(GetInd(envelopesHandle,UPPER_LINE,"Envelopes",Bar)+GetInd(envelopesHandle,LOWER_LINE,"Envelopes",Bar))/2.0;
                     if(mid!=-1 && iClose(_Symbol,0,int(Bar))<mid)
                       {
                        CloseAll(1);
                        continue;
                       }
                    }
                  else if(UseCloseEnvelopes==ENVELOPES_OPOSITE)
                    {
                     lower=GetInd(envelopesHandle,LOWER_LINE,"Envelopes",Bar);
                     if(lower!=-1 && iClose(_Symbol,0,int(Bar))<=lower)
                       {
                        CloseAll(1);
                        continue;
                       }
                    }
                 }
              }
            //Close Tunnel Of Vegas Midline
            if(UseCloseTunnelOfVegas)
              {
               line=GetTunnelOfVegasLine(0);
               if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY && iClose(_Symbol,0,int(Bar))>=line){ CloseAll(0); continue; }
               else if(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_SELL && iClose(_Symbol,0,int(Bar))<=line){ CloseAll(1); continue; }
              }
           }//fim invertSignal
         //Stop trade
         if(StopTrade)
           {
            if(NumBars(orders[i].openTime)>=CheckBarStart && NumBars(orders[i].openTime)<CheckBarEnd)
              {
               if(!PositionGetInteger(POSITION_TYPE))
                 {
                  if(!orders[i].pointCross)
                    {
                     if(GatilhoType==GATILHO_MA)
                       {
                        ma=GetInd(maHandles[1],0,"Média",Bar);
                        if(ma!=-1 && ma>=iClose(_Symbol,0,int(Bar))) orders[i].pointCross=ma;
                       }
                     else if(GatilhoType==GATILHO_ADX && CrossADX()==0) orders[i].pointCross=CurrentBid(symbol);
                    }
                  if(orders[i].pointCross && CurrentBid(symbol)-orders[i].pointCross>=PointsStopTrade*PointSize(symbol))
                    {
                     ClosePosition(orders[i].ticket);
                     continue;
                    }
                 }
               else
                 {
                  if(!orders[i].pointCross)
                    {
                     if(GatilhoType==GATILHO_MA)
                       {
                        ma=GetInd(maHandles[1],0,"Média",Bar);
                        if(ma!=-1 && ma<=iClose(_Symbol,0,int(Bar)))
                           orders[i].pointCross=ma;
                       }
                     else if(GatilhoType==GATILHO_ADX && CrossADX(1)==1) orders[i].pointCross=CurrentBid(symbol);
                    }
                  if(orders[i].pointCross && orders[i].pointCross-CurrentBid(symbol)>=PointsStopTrade*PointSize(symbol))
                    {
                     ClosePosition(orders[i].ticket);
                     continue;
                    }
                 }
              }
           }
         //Breakeven
         if(BreakevenStart && !orders[i].breakeven)
           {
            if(!PositionGetInteger(POSITION_TYPE))
              {
               if(PositionGetDouble(POSITION_PRICE_CURRENT)-PositionGetDouble(POSITION_PRICE_OPEN)>=BreakevenStart*PointSize(symbol))
                 {
                  newSL=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)+BreakevenProfit*PointSize(symbol),TradeDigits(symbol));
                  if(direction*newSL>direction*PositionGetDouble(POSITION_SL) && OrderModifyVirtual(virtualBreakeven,virtualBreakevenColor,symbol,orders[i].ticket,newSL,PositionGetDouble(POSITION_TP)))
                     orders[i].breakeven=1;
                 }
              }
            else
              {
               if(PositionGetDouble(POSITION_PRICE_OPEN)-PositionGetDouble(POSITION_PRICE_CURRENT)>=BreakevenStart*PointSize(symbol))
                 {
                  newSL=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)-BreakevenProfit*PointSize(symbol),TradeDigits(symbol));
                  if(direction*newSL>direction*PositionGetDouble(POSITION_SL) && OrderModifyVirtual(virtualBreakeven,virtualBreakevenColor,symbol,orders[i].ticket,newSL,PositionGetDouble(POSITION_TP)))
                     orders[i].breakeven=1;
                 }
              }
           }
         //Trailing
         if(TralingStart>0 && TrailingStop>0)
           {
            if(!PositionGetInteger(POSITION_TYPE))
              {
               double degrau=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)+(double)TralingStart*PointSize(symbol),TradeDigits(symbol)),newSLBuy=NormalizeDouble(CurrentBid(symbol)-(double)TrailingStop*PointSize(symbol),TradeDigits(symbol));
               if(CurrentBid(symbol)>=degrau && newSLBuy>NormalizeDouble(PositionGetDouble(POSITION_SL)+TrailingStep*PointSize(symbol),TradeDigits(symbol)))
                 {
                  OrderModifyVirtual(virtualTrailingStop,virtualTrailingStopColor,symbol,orders[i].ticket,newSLBuy,PositionGetDouble(POSITION_TP));
                 }
              }
            else
              {
               double degra=NormalizeDouble(PositionGetDouble(POSITION_PRICE_OPEN)-TralingStart*PointSize(symbol),TradeDigits(symbol)),newSLSell=NormalizeDouble(CurrentAsk(symbol)+(double)TrailingStop*PointSize(symbol),TradeDigits(symbol));
               if(CurrentAsk(symbol)<=degra && newSLSell<NormalizeDouble(PositionGetDouble(POSITION_SL)-TrailingStep*PointSize(symbol),TradeDigits(symbol)))
                 {
                  OrderModifyVirtual(virtualTrailingStop,virtualTrailingStopColor,symbol,orders[i].ticket,newSLSell,PositionGetDouble(POSITION_TP));
                 }
              }
           }
         if(OrderCloseVirtual(ticket,PositionGetDouble(POSITION_VOLUME)) && ArrDelete(orders,o,i)) { if(i!=o) i++; continue; }
         if(PartialClose(ticket,symbol,PositionGetDouble(POSITION_PRICE_OPEN),PositionGetDouble(POSITION_VOLUME)) && ArrDelete(orders,o,i)) { if(i!=o) i++; continue; }
         numOpenTickets++;
         ArrayResize(openTickets,numOpenTickets,10);
         openTickets[(numOpenTickets-1)]=orders[i].ticket;
           } else if(ArrDelete(orders,o,i)) { if(i!=o) i++; continue;
        }
     }
   CleanVirtual();
   CleanPartialCloseTickets();
   if(IsTime() && DayAllowed())
     {
      if(TotalPositions()<MaxOrders && CurrentAsk(Simbolo)-CurrentBid(Simbolo)<=MaxSpread*PointSize(Simbolo) && backup.once<iTime(Simbolo,0,0) && MinimumMovementAfterTrade())
        {
         if(Gatilho()==(invertSignal ? 1 : 0))
           {
            Buy(program);
           }
         else if(Gatilho()==(invertSignal ? 0 : 1))
           {
            Sell(program);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   int chart_center;

   switch(id)
     {
      case CHARTEVENT_CHART_CHANGE:

         chart_center=(int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS)/2;
         ObjectSetInteger(0,_EAPrefix+"BUTTON_Buy",OBJPROP_YDISTANCE,chart_center-34);
         ObjectSetInteger(0,_EAPrefix+"BUTTON_Sell",OBJPROP_YDISTANCE,chart_center+10);
         break;

      case  CHARTEVENT_OBJECT_CLICK:

         if(sparam==_EAPrefix+"BUTTON_Buy")
           {
            ButtonClickUp(0,sparam);
            if(MessageBox("Open BUY by market ?","Attention !!!",MB_YESNO|MB_ICONEXCLAMATION|MB_DEFBUTTON2)==IDYES)
              {
               Buy("MANUAL"+program);
              }
            break;
           }

         if(sparam==_EAPrefix+"BUTTON_Sell")
           {
            ButtonClickUp(0,sparam);
            if(MessageBox("Open SELL by market ?","Attention !!!",MB_YESNO|MB_ICONEXCLAMATION|MB_DEFBUTTON2)==IDYES)
              {
               Sell("MANUAL"+program);
              }
            break;
           }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ButtonCreate(const long              chart_ID=0,
                  const int               sub_window=0,
                  const string            name="Button",
                  const int               x=0,
                  const int               y=0,
                  const int               width=50,
                  const int               height=18,
                  const ENUM_BASE_CORNER  corner=CORNER_LEFT_UPPER,
                  const string            text="Button",
                  const string            font="Arial",
                  const int               font_size=10,
                  const color             clr=clrDarkBlue,
                  const color             back_clr=clrLightBlue,
                  const color             border_clr=clrNONE,
                  const bool              state=false,
                  const bool              back=false,
                  const bool              selection=false,
                  const bool              hidden=true,
                  const long              z_order=0)
  {
   ResetLastError();
   if(ObjectFind(chart_ID,name)==-1)
     {
      if(!ObjectCreate(chart_ID,name,OBJ_BUTTON,sub_window,0,0))
        {
         Print(__FUNCTION__,": failed to create a button! Error code =",GetLastError());
         return(false);
        }
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_XDISTANCE,x);
   ObjectSetInteger(chart_ID,name,OBJPROP_YDISTANCE,y);
   ObjectSetInteger(chart_ID,name,OBJPROP_XSIZE,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_YSIZE,height);
   ObjectSetInteger(chart_ID,name,OBJPROP_CORNER,corner);
   ObjectSetString(chart_ID,name,OBJPROP_TEXT,text);
   ObjectSetString(chart_ID,name,OBJPROP_FONT,font);
   ObjectSetInteger(chart_ID,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BGCOLOR,back_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BORDER_COLOR,border_clr);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
   ObjectSetInteger(chart_ID,name,OBJPROP_STATE,state);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ButtonClickUp(const long   chart_ID=0,
                   const string name="Button")
  {
   Sleep(100);
   ObjectSetInteger(chart_ID, name,OBJPROP_STATE,false);                            //--- вернем кнопку в ненажатое состояние
   ChartRedraw();                                                                   //--- перерисуем график
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int NumBars(datetime startTime)
  {
   for(int i=0; i<iBars(_Symbol,0); i++)
     {
      if(iTime(_Symbol,0,i)<=startTime)
         return i;
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ClosePosition(ulong ticket)
  {
   if(PositionSelectByTicket(ticket))
     {
      trade.PositionClose(ticket);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseAll(int cmd=-1)
  {
   for(int i=PositionsTotal()-1; i>=0; i--)
     {
      if(PositionGetSymbol(i)==Simbolo && PositionGetInteger(POSITION_MAGIC)==magicNumber && (cmd==-1?true:PositionGetInteger(POSITION_TYPE)==cmd))
        {
         if(trade.PositionClose((ulong)PositionGetInteger(POSITION_TICKET)))
           {
            Print(Simbolo+(PositionGetInteger(POSITION_TYPE)==POSITION_TYPE_BUY?" Buy":" Sell")+": Posição fechada");
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetInd(int handle,int buffer,string name,int index=0)
  {
   double ind[1];
   if(BarsCalculated(handle)>0)
     {
      if(CopyBuffer(handle,buffer,index,1,ind)!=1)
        {
         Print("Falha ao copiar "+name+" - ",GetLastError());
         return -1;
        }
     }
   else return -1;
   return ind[0];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CrossMA(int cmd=0)
  {
   double ma1=GetInd(maHandles[0],0,"Média",Bar),
   ma2=GetInd(maHandles[1],0,"Média",Bar),
   prevma1=GetInd(maHandles[0],0,"Média",Bar+1),
   prevma2=GetInd(maHandles[1],0,"Média",Bar+1);

   if(ma1!=-1 && ma2!=-1 && prevma1!=-1 && prevma2!=-1)
     {
      if(!cmd)
        {
         if(prevma1<=prevma2&&ma1>ma2) return 0;
        }
      else if(prevma1>=prevma2&&ma1<ma2) return 1;
      return -1;
     }
   return -2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CrossADX(int cmd=0)
  {
   double adxMain=GetInd(adxHandle,0,"ADX",Bar),
   diplus=GetInd(adxHandle,1,"ADX",Bar),
   diminus=GetInd(adxHandle,2,"ADX",Bar),
   prevdiplus=GetInd(adxHandle,1,"ADX",Bar+1),
   prevdiminus=GetInd(adxHandle,2,"ADX",Bar+1);

   if(adxMain!=-1 && diplus!=-1 && diminus!=-1 && prevdiplus!=-1 && prevdiminus!=-1)
     {
      if(adxMain>ADXLevelTrend)
        {
         if(!cmd)
           {
            if(prevdiplus<=prevdiminus&&diplus>diminus) return 0;
           }
         else if(prevdiplus>=prevdiminus&&diplus<diminus) return 1;
        }
      return -1;
     }
   return -2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Gatilho()
  {
   Filtros();

   if(backup.buy && PassedTunnelOfVegas(1))
     {
      if(GatilhoType==GATILHO_NONE) return 0;
      if(GatilhoType==GATILHO_MA) return CrossMA();
      return CrossADX();
     }
   if(backup.sell && PassedTunnelOfVegas(-1))
     {
      if(GatilhoType==GATILHO_NONE) return 1;
      if(GatilhoType==GATILHO_MA) return CrossMA(1);
      return CrossADX(1);
     }
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetMurreyLine(ENUM_MURREY_LINES line)
  {
//GetInd(murHandle,0,"Murrey Math");
   return ObjectGetDouble(0,"mml"+string(int(line)),OBJPROP_PRICE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTunnelOfVegasLine(ENUM_TUNNEL_OF_VEGAS_LINES line)
  {
   double mA0=GetInd(tunnelOfVegasHandle,0,"Tunnel Of Vegas Moving Average",0);
   if(mA0<=0) return(0);
   int level=0,num=(int)MathAbs((double)line);
   if(num==1) level=tunnelOfVegasLevel1;
   else if(num==2) level=tunnelOfVegasLevel2;
   else if(num==3) level=tunnelOfVegasLevel3;
   else if(num==4) level=tunnelOfVegasLevel4;
   else if(num==5) level=tunnelOfVegasLevel5;
   else if(num==6) level=tunnelOfVegasLevel6;
   else if(num==7) level=tunnelOfVegasLevel7;
   if(line<0) level*=-1;
   return (NormalizeDouble(mA0+level*_Point,_Digits));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FilterMurrey()
  {
   if(!UseMurrey)
     {
      backup.murreyUp=true;
      backup.murreyDn=true;
      return;
     }
   if(!backup.murreyUp && iClose(_Symbol,0,int(Bar))>GetMurreyLine(MurreyUp))
     {
      backup.murreyUp=true;
      backup.murreyDn=false;
      return;
     }
   if(!backup.murreyDn && iClose(_Symbol,0,int(Bar))<GetMurreyLine(MurreyDn))
     {
      backup.murreyDn=true;
      backup.murreyUp=false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FilterTunnelOfVegas()
  {
   if(!UseTunnelOfVegas){ backup.tunnelOfVegasUp=backup.tunnelOfVegasDn=true; return; }
   if(iClose(_Symbol,0,int(Bar))>GetTunnelOfVegasLine(tunnelOfVegasUpperLine))
     {
      backup.tunnelOfVegasUp=true;
      backup.tunnelOfVegasDn=false;
        } else if(iClose(_Symbol,0,int(Bar))<GetTunnelOfVegasLine(tunnelOfVegasLowerLine)){
      backup.tunnelOfVegasDn=true;
      backup.tunnelOfVegasUp=false;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PassedTunnelOfVegas(int direction=0)
  {
   if(!UseTunnelOfVegas) return(true);
   if(direction==0) return(false);
   return(direction*iClose(_Symbol,0,int(Bar))<direction*GetTunnelOfVegasLine(direction==1 ? tunnelOfVegasLowerLine : tunnelOfVegasUpperLine));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int FilterRSI()
  {
   double rsi=GetInd(rsiHandle,0,"RSI",Bar);
   if(rsi!=-1)
     {
      if(rsi<=RSISobrevenda) return 0;
      if(rsi>=RSISobrecompra) return 1;
      return -1;
     }
   return -2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int FilterCCI()
  {
   double val=GetInd(cciHandle,0,"CCI",Bar);
   if(val!=-1)
     {
      if(val<=CCISobrevenda) return 0;
      if(val>=CCISobrecompra) return 1;
      return -1;
     }
   return -2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int FilterStochastic()
  {
   double stocMain=GetInd(stocHandle,0,"Stochastic",Bar);
   if(stocMain!=-1)
     {
      if(stocMain<=StocSobrevenda) return 0;
      if(stocMain>=StocSobrecompra) return 1;
      return -1;
     }
   return -2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int FilterBollinger()
  {
   double bbUp=GetInd(bbHandle,1,"Bollinger Bands",Bar),
   bbDn=GetInd(bbHandle,2,"Bollinger Bands",Bar);
   if(bbDn!=-1)
     {
      if(bbDn>=iClose(_Symbol,0,int(Bar))) return 0;
     }
   else return -2;
   if(bbUp!=-1)
     {
      if(bbUp<=iClose(_Symbol,0,int(Bar))) return 1;
     }
   else return -2;
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int FilterEnvelopes()
  {
   double envelopesUp=GetInd(envelopesHandle,UPPER_LINE,"Envelopes",Bar),
   envelopesDn=GetInd(envelopesHandle,LOWER_LINE,"Envelopes",Bar);
   if(envelopesDn!=-1)
     {
      if(envelopesDn>=iClose(_Symbol,0,int(Bar))) return 0;
     }
   else return -2;
   if(envelopesUp!=-1)
     {
      if(envelopesUp<=iClose(_Symbol,0,int(Bar))) return 1;
     }
   else return -2;
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Filtros()
  {
   FilterMurrey();
   FilterTunnelOfVegas();
   int s1=-1,s2=-1,s3=-1,s4=-1,s5=-1;
   if(UseRSI) s1=FilterRSI();
   if(UseStoc) s2=FilterStochastic();
   if(UseBB) s3=FilterBollinger();
   if(UseEnvelopes) s4=FilterEnvelopes();
   if(UseCCI) s5=FilterCCI();
   if((TradingType==0 || TradingType==1))
     {
      if(!backup.sobrevendido)
        {
         if(backup.murreyDn && backup.tunnelOfVegasDn && (UseRSI?s1==0:true) && (UseStoc?s2==0:true) && (UseBB?s3==0:true) && (UseEnvelopes?s4==0:true) && (UseCCI?s5==0:true))
           {
            backup.sobrevendido=1;
            backup.buy=1;
            backup.sell=0;
           }
        }
      else
        {
         if((UseRSI?s1==1 || s1==-1:true) && (UseStoc?s2==1 || s2==-1:true) && (UseBB?s3==1 || s3==-1:true) && (UseEnvelopes?s4==1 || s4==-1:true) && (UseCCI?s5==1 || s5==-1:true))
           {
            backup.sobrevendido=0;
            backup.murreyDn=backup.tunnelOfVegasDn=0;
           }
        }
     }
   if((TradingType==0 || TradingType==2))
     {
      if(!backup.sobrecomprado)
        {
         if(backup.murreyUp && backup.tunnelOfVegasUp && (UseRSI?s1==1:true) && (UseStoc?s2==1:true) && (UseBB?s3==1:true) && (UseEnvelopes?s4==1:true) && (UseCCI?s5==1:true))
           {
            backup.sobrecomprado=1;
            backup.sell=1;
            backup.buy=0;
           }
        }
      else
        {
         if((UseRSI?s1==0 || s1==-1:true) && (UseStoc?s2==0 || s2==-1:true) && (UseBB?s3==0 || s3==-1:true) && (UseEnvelopes?s4==0 || s4==-1:true) && (UseCCI?s5==0 || s5==-1:true))
           {
            backup.sobrecomprado=0;
            backup.murreyUp=backup.tunnelOfVegasUp=0;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormalizeTick(double num)
  {
   return ceil(num/tickSize)*tickSize;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TotalPositions()
  {
   int cnt=0;
   for(int i=PositionsTotal()-1; i>=0; i--)
      if(PositionGetSymbol(i)==Simbolo && PositionGetInteger(POSITION_MAGIC)==magicNumber)
         cnt++;
   return cnt;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FillOrder()
  {
   ArrResize(orders,o);
   orders[o-1].ticket=trade.ResultOrder();
   orders[o-1].trailing=TralingStart;
   orders[o-1].breakeven=0;
   orders[o-1].openTime=iTime(_Symbol,0,0);
   backup.once=iTime(_Symbol,0,0);
   backup.Reset();
   waitForMovement=true;
   positionInfo.SelectByTicket(orders[o-1].ticket);
   lastMovementPrice=positionInfo.PriceOpen();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Buy(string comment)
  {
   double thisLot=GetLot(Simbolo);
   if(trade.Buy(thisLot,Simbolo,CurrentAsk(Simbolo),0,0,comment))
     {
      FillOrder();
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Sell(string comment)
  {
   double thisLot=GetLot(Simbolo);
   if(trade.Sell(thisLot,Simbolo,CurrentBid(Simbolo),0,0,comment))
     {
      FillOrder();
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetLot(string symbol)
  {
   double thisLot=Lot;
   if(secondOrderLotValue>0)
     {
      int num=TotalPositions();
      thisLot=((LotMod==LOT_ADD) ? Lot+secondOrderLotValue*num : ((num>0) ?Lot*pow(secondOrderLotValue,num) :Lot));
     }
   return(NormL(thisLot));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsExist(int mod=0)
  {
   if(!mod)
     {
      for(int i=PositionsTotal()-1; i>=0; i--)
        {
         if(PositionGetSymbol(i)==Simbolo && PositionGetInteger(POSITION_MAGIC)==magicNumber)
           {
            return true;
           }
        }
      return false;
     }
   else
     {
      for(int i=OrdersTotal()-1; i>=0; i--)
         if(OrderGetTicket(i))
            if(OrderGetString(ORDER_SYMBOL)==Simbolo && OrderGetInteger(ORDER_MAGIC)==magicNumber)
               if(OrderGetInteger(ORDER_TYPE)>1)
                  return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool DayAllowed()
  {
   MqlDateTime now;
   TimeToStruct(TimeCurrent(),now);
   switch(now.day_of_week)
     {
      case 0: if(Domingo) return true;break;
      case 1: if(Segunda) return true;break;
      case 2: if(Terca) return true;break;
      case 3: if(Quarta) return true;break;
      case 4: if(Quinta) return true;break;
      case 5: if(Sexta) return true;
     };
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsTime()
  {
   if(!UseSession) return true;
   MqlDateTime time;
   TimeToStruct(TimeCurrent(),time);
   int mt5Hour=time.hour*60+time.min;
   if(sessionEnd>sessionStart)
     {
      if(mt5Hour>=sessionStart && mt5Hour<sessionEnd)
         return true;
      return false;
     }
   if(mt5Hour>=sessionEnd && mt5Hour<sessionStart)
     {
      return false;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
void ArrResize(T &arr[],int &ind)
  {
   ArrayResize(arr,ind+1);
   ind++;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
bool ArrDelete(T &arr[],int &size,int ind)
  {
   int cc=0;
   if(size>1)
     {
      size--;
      for(int i=0; i<size; i++)
        {
         if(i==ind) cc++;
         arr[i]=arr[i+cc];
         if(i+cc>=size) break;
        }
      ArrayResize(arr,size);
     }
   else
     {
      ArrayFree(arr);
      size=0;
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SaveBackup()
  {
   int handle=FileOpen(backupName1,FILE_WRITE|FILE_SHARE_READ|FILE_BIN);
   if(handle!=INVALID_HANDLE)
     {
      FileWriteArray(handle,orders);
      FileClose(handle);
      Print("Backup: "+backupName1+" criado com sucesso");
     }
   else
     {
      Print("Backup: falha ao criar "+backupName1);
      return false;
     }
   handle=FileOpen(backupName2,FILE_WRITE|FILE_SHARE_READ|FILE_BIN);
   if(handle!=INVALID_HANDLE)
     {
      FileWriteStruct(handle,backup);
      FileClose(handle);
      Print("Backup: "+backupName2+" criado com sucesso");
      return true;
     }
   Print("Backup: falha ao criar "+backupName2);
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool LoadBackup()
  {
   int handle=0;
   if(IsExist() || IsExist(1))
     {
      handle=FileOpen(backupName1,FILE_SHARE_READ|FILE_BIN);
      if(handle!=INVALID_HANDLE)
        {
         FileReadArray(handle,orders);
         o=ArraySize(orders);
         FileClose(handle);
         Print("Backup: "+backupName1+" carregado com sucesso");
        }
      else
        {
         Print("Backup: falha ao carregar "+backupName1);
         return false;
        }
     }
   else FileDelete(backupName1);
   handle=FileOpen(backupName2,FILE_SHARE_READ|FILE_BIN);
   if(handle!=INVALID_HANDLE)
     {;
      FileReadStruct(handle,backup);
      FileClose(handle);
      Print("Backup: "+backupName2+" carregado com sucesso");
      return true;
     }
   Print("Backup: falha ao carregar "+backupName2);
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0,"Virtual SL ");
   ObjectsDeleteAll(0,_EAPrefix);
   if(!MQLInfoInteger(MQL_TESTER))
     {
      SaveBackup();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitMovementAfterTrade()
  {
   waitForMovement=false;
   lastMovementPrice=0;
   if(minimumMovementAfterTrade==0) return;
   int ordersTotal=PositionsTotal(),orderI;
   datetime lastOpen=0;
   if(ordersTotal==0) return;
   if((orderI=0)==0) while(orderI<ordersTotal && positionInfo.SelectByIndex(orderI))
     {
      orderI++;
      if(!IsOpenOrder()) continue;
      if(lastOpen==0 || positionInfo.Time()>lastOpen) { lastOpen=positionInfo.Time(); lastMovementPrice=positionInfo.PriceOpen(); waitForMovement=true; }
     }
   if(lastOpen==0) return;
   int bars=ShiftByTime(lastOpen,Period(),Simbolo);
//---
   int   cnt=TotalPositions();
   double   dist=(cnt>1) ?minimumMovementAfterTrade*pow(MultStep,cnt-1) :minimumMovementAfterTrade;
//---
   if(MathAbs(lastMovementPrice-iHigh(NULL,0,iHighest(NULL,0,MODE_HIGH,bars)))>=dist*PointSize(Simbolo)
      || MathAbs(lastMovementPrice-iLow(NULL,0,iLowest(NULL,0,MODE_HIGH,bars)))>=dist*PointSize(Simbolo)
      ) { waitForMovement=false; lastMovementPrice=0; }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MinimumMovementAfterTrade()
  {
   if(minimumMovementAfterTrade==0 || !waitForMovement || lastMovementPrice==0)
      return(true);
//---
   int   cnt=TotalPositions();
   double   dist=(cnt>1) ?minimumMovementAfterTrade*pow(MultStep,cnt-1) :minimumMovementAfterTrade;
//---
   if(MathAbs(CurrentBid(Simbolo)-lastMovementPrice)>=dist*PointSize(Simbolo))
     {
      waitForMovement=false;
      lastMovementPrice=0;
     }
   return(!waitForMovement);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool PartialClose(ulong &ticket,string symbol,double openPrice,double orderLots)
  {
   int pCOffset=partialCloseOffset,maximumPC=maximumPartialCloses;
   double pCLots=partialCloseLots;
   if(pCOffset==0) return(false);
   double closePrice=(tradeDirection==1 ? CurrentBid(symbol) : CurrentAsk(symbol)),profit=tradeDirection*(closePrice-openPrice),nextClosePrice=0,closeLots=pCLots;
   if(profit<=0) return(false);
   int num=NumPartialCloses(ticket);
   if(maximumPC>0 && num>=maximumPC) return(false);
   nextClosePrice=openPrice+tradeDirection*((double)num+1.0)*(double)pCOffset*PointSize(symbol);
   if(tradeDirection*closePrice<tradeDirection*nextClosePrice) return(false);
   if(closeLots>orderLots) closeLots=orderLots;
   if(!trade.PositionClosePartial(ticket,closeLots)) return(false);
   if(closeLots==orderLots) return(true);
   ulong closedTicket=ticket;
   PartialCloseUpdateTickets(closedTicket);
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void PartialCloseUpdateTickets(ulong closedTicket)
  {
   if(closedTicket<0) return;
   int i;
   bool found=false;
   for(i=0; i<numPartialCloseTickets; i++) if(partialCloseTickets[i].ticket==closedTicket)
     {
      partialCloseTickets[i].num++;
      found=true;
     }
   if(!found)
     {
      numPartialCloseTickets++;
      ArrayResize(partialCloseTickets,numPartialCloseTickets,10);
      partialCloseTickets[numPartialCloseTickets-1].num=1;
      partialCloseTickets[numPartialCloseTickets-1].ticket=closedTicket;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int NumPartialCloses(ulong ticket)
  {
   int i,num=0;
   for(i=0; i<numPartialCloseTickets; i++) if(partialCloseTickets[i].ticket==ticket) { num=partialCloseTickets[i].num; break; }
   return(num);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void InitPartialCloses()
  {
   numPartialCloseTickets=0;
   ArrayResize(partialCloseTickets,0);
   int ordersTotal=PositionsTotal(),orderI,num;
   if(ordersTotal==0) return;
   if((orderI=0)==0) while(orderI<ordersTotal && positionInfo.SelectByIndex(orderI))
     {
      orderI++;
      if(!IsOpenOrder()) continue;
      num=PartialCloses(orderI-1);
      numPartialCloseTickets++;
      ArrayResize(partialCloseTickets,numPartialCloseTickets,10);
      partialCloseTickets[numPartialCloseTickets-1].num=num;
      partialCloseTickets[numPartialCloseTickets-1].ticket=positionInfo.Ticket();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CleanPartialCloseTickets()
  {
   if(numPartialCloseTickets==0) return;
   partialCloseTicketsStruct temp[]={};
   int i,j,numTemp=0;
   bool found=false,changed=false;
   for(i=0; i<numPartialCloseTickets; i++)
     {
      found=false;
      for(j=0; j<numOpenTickets; j++) if(openTickets[j]==partialCloseTickets[i].ticket) { found=true; break; }
      if(!found) changed=true;
      else
        {
         numTemp++;
         ArrayResize(temp,numTemp,10);
         temp[numTemp-1].ticket=partialCloseTickets[i].ticket;
         temp[numTemp-1].num=partialCloseTickets[i].num;
        }
     }
   if(!changed) return;
   numPartialCloseTickets=0;
   ArrayResize(partialCloseTickets,0);
   for(i=0; i<numTemp; i++)
     {
      numPartialCloseTickets++;
      ArrayResize(partialCloseTickets,numPartialCloseTickets,10);
      partialCloseTickets[i].ticket=temp[i].ticket;
      partialCloseTickets[i].num=temp[i].num;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CleanVirtual()
  {
   if(numVirtualSL==0) return;
   virtualSLStruct temp[]={};
   int i,j,numTemp=0;
   bool found=false,changed=false;
   for(i=0; i<numVirtualSL; i++)
     {
      found=false;
      for(j=0; j<numOpenTickets; j++) if(openTickets[j]==virtualSL[i].ticket) { found=true; break; }
      if(!found)
        {
         changed=true;
         ObjectDelete(0,"Virtual SL "+(string)virtualSL[i].ticket);
           } else {
         numTemp++;
         ArrayResize(temp,numTemp,10);
         temp[(numTemp-1)].ticket=virtualSL[i].ticket;
         temp[(numTemp-1)].sL=virtualSL[i].sL;
         temp[(numTemp-1)].symbol=virtualSL[i].symbol;
        }
     }
   if(!changed) return;
   numVirtualSL=0;
   ArrayResize(virtualSL,0);
   for(i=0; i<numTemp; i++)
     {
      numVirtualSL++;
      ArrayResize(virtualSL,numVirtualSL,10);
      virtualSL[i].ticket=temp[i].ticket;
      virtualSL[i].sL=temp[i].sL;
      virtualSL[i].symbol=temp[i].symbol;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderModifyVirtual(bool isVirtual=false,color lineColor=clrRed,string symbol="",long ticket=-1,double stoploss=0,double takeprofit=0)
  {
   if(!isVirtual) return(trade.PositionModify(ticket,stoploss,takeprofit));
   if(ticket==-1) return(false);
   int i;
   bool found=false;
   for(i=0; i<numVirtualSL; i++) if(virtualSL[i].ticket==ticket) { found=true; break; }
   if(!found)
     {
      i=numVirtualSL;
      numVirtualSL++;
      ArrayResize(virtualSL,numVirtualSL,10);
      virtualSL[i].ticket=ticket;
      virtualSL[i].symbol=symbol;
     }
   else if(found && tradeDirection*virtualSL[i].sL>=tradeDirection*stoploss) return(true);
   virtualSL[i].sL=stoploss;
   MoveLine("Virtual SL "+(string)ticket,stoploss,lineColor);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool OrderCloseVirtual(long ticket,double lots)
  {
   if(numVirtualSL==0 || tradeDirection==0) return(false);
   int i;
   bool found=false;
   for(i=0; i<numVirtualSL; i++) if(virtualSL[i].ticket==ticket) { found=true; break; }
   if(!found) return(false);
   string symbol=virtualSL[i].symbol;
   double sL=virtualSL[i].sL,closePrice=(tradeDirection==1 ? CurrentBid(symbol) : CurrentAsk(symbol));
   if(tradeDirection*closePrice<=tradeDirection*sL) return(trade.PositionClose(ticket));
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool MoveLine(string name,double price,color lineColor=clrRed)
  {
   if((ObjectFind(0,name)<0 && !CreateLine(name,price,lineColor)) || !ObjectMove(0,name,0,0,price)) return(false);
   ObjectSetInteger(0,name,OBJPROP_COLOR,lineColor);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CreateLine(string name,double price,color lineColor)
  {
   if(!ObjectCreate(0,name,OBJ_HLINE,0,0,price)) return(false);
   ObjectSetInteger(0,name,OBJPROP_COLOR,lineColor);
   ObjectSetInteger(0,name,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_BACK,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,0);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CurrentBid(string symbol)
  {
   return (SymbolInfoDouble(symbol,SYMBOL_BID));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CurrentAsk(string symbol)
  {
   return (SymbolInfoDouble(symbol,SYMBOL_ASK));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PointSize(string symbol)
  {
   return (SymbolInfoDouble(symbol,SYMBOL_POINT));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TradeDigits(string symbol)
  {
   return ((int)SymbolInfoInteger(symbol,SYMBOL_DIGITS));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsOpenOrder()
  {
   int orderType=positionInfo.PositionType();
   if((orderType!=POSITION_TYPE_BUY && orderType!=POSITION_TYPE_SELL) || positionInfo.Symbol()!=Simbolo || positionInfo.Magic()!=magicNumber) return(false);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsClosedOrder(datetime closedAfter=0)
  {
   int orderType=historyInfo.OrderType();
   if((orderType!=ORDER_TYPE_BUY && orderType!=ORDER_TYPE_SELL) || historyInfo.Symbol()!=Simbolo || historyInfo.Magic()!=magicNumber
      || (closedAfter>0 && historyInfo.TimeDone()<closedAfter)
      ) return(false);
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int PartialCloses(int orderI)
  {
   int i=0,num=0;
   ulong ticket=positionInfo.Ticket();
   double initialLot=0,currentLot=positionInfo.Volume(),pLot;
   long iD=positionInfo.Identifier();
   if(!HistorySelectByPosition(iD)) return(0);
   HistoryOrderGetTicket(0);
   initialLot=HistoryOrderGetDouble(ticket,ORDER_VOLUME_INITIAL);
   if(currentLot==initialLot) return(0);
   pLot=partialCloseLots;
   num=(int)MathRound((initialLot-currentLot)/pLot);
   positionInfo.SelectByIndex(orderI);
   return(num);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ValidLotSize(double lot,string symbol)
  {
   if(lot<=0 || lot<SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN) || lot>SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX) || LotStepFloor(lot,symbol)!=lot)
     {
      ermsg="Min:"+(string)SymbolInfoDouble(symbol,SYMBOL_VOLUME_MIN)+" Max:"+(string)SymbolInfoDouble(symbol,SYMBOL_VOLUME_MAX)+" Step:"+(string)SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LotStepFloor(double lot,string symbol)
  {
   double symbolLotStep=SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   if(symbolLotStep==0) return(lot);
   lot=NormalizeDouble(MathFloor(NormalizeDouble(lot/symbolLotStep,LotSizeDigits(symbol)))*symbolLotStep,LotSizeDigits(symbol));
   return(lot);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int LotSizeDigits(string symbol)
  {
   string step=(string)SymbolInfoDouble(symbol,SYMBOL_VOLUME_STEP);
   int len;
   while(StringSubstr(step,(len=StringLen(step))-1,1)=="0") step=StringSubstr(step,0,len-1);
   len=(StringLen(step)-2);
   if(len<0) len=0;
   return(len);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int ShiftByTime(datetime time,ENUM_TIMEFRAMES tF,string symbol)
  {
   int i=DoCandleByTime(time,tF,symbol);
   if(i>0) i--;
   return(i);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int DoCandleByTime(datetime time,ENUM_TIMEFRAMES tF,string symbol)
  {
   if(tF==PERIOD_CURRENT) tF=(ENUM_TIMEFRAMES)Period();
   int doCandle,inc,i,weekends,thisYear=Year(),tFS=0;
   tFS=tF*60;
   datetime thisOpen=CandleTime(0,tF,symbol),holiday;
   weekends=(int)MathFloor(((double)((int)thisOpen-(int)time))/(60.0*60.0*24.0*7.0));
   if(TimeDayOfWeek(time)>TimeDayOfWeek(thisOpen)) weekends++;
   doCandle=(int)MathCeil((double)((int)thisOpen-(int)time-weekends*49*60*60)/(double)tFS);
   for(i=0; i<=1; i++)
     {
      if(time<(holiday=StringToTime(string(thisYear-i)+".12.25 00:00:00")) && thisOpen>holiday) doCandle-=(int)MathCeil((double)(24*60*60)/(double)tFS);
     }
   if(doCandle<0) doCandle=0;
   if(CandleTime(doCandle,tF,symbol)>time || (doCandle>0 && CandleTime(doCandle-1,tF,symbol)<time))
     {
      if(doCandle>0 && CandleTime(doCandle-1,tF,symbol)<time) inc=-1; else inc=1;
      if(inc==-1)
        {
         for(i=doCandle; i>=0; i--) if(CandleTime(i,tF,symbol)<=time && (i==0 || CandleTime(i-1,tF,symbol)>time)) { doCandle=i; break; }
           } else {
         for(i=doCandle; i<=doCandle+15000; i++) if(CandleTime(i,tF,symbol)<=time && CandleTime(i-1,tF,symbol)>time) { doCandle=i; break; }
        }
      if(CandleTime(doCandle,tF,symbol)>time) { LPrint("Symbol:"+symbol+" Candle "+IntegerToString(doCandle)+" Open Time "+(string)CandleTime(doCandle,tF,symbol)+" Is After Time ("+(string)time+") In "+TFToStr(tF)); return(-1); }
      if(doCandle>0 && CandleTime(doCandle-1,tF,symbol)<time) { LPrint("Symbol:"+symbol+" Next Candle "+IntegerToString(doCandle-1)+" Open Time "+(string)CandleTime(doCandle-1,tF,symbol)+" Is Before Time ("+(string)time+") In "+TFToStr(tF)); return(-1); }
     }
   doCandle++;
   return(doCandle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Year()
  {
   MqlDateTime tm;
   TimeCurrent(tm);
   return(tm.year);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int TimeDayOfWeek(datetime date)
  {
   MqlDateTime tm;
   TimeToStruct(date,tm);
   return(tm.day_of_week);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TFToStr(ENUM_TIMEFRAMES tF=PERIOD_CURRENT)
  {
   if(tF==PERIOD_CURRENT) tF=(ENUM_TIMEFRAMES)Period();
   if(tF==43200) return "MN";
   if(MathMod(tF,43200)==0) return ("MN"+DoubleToString(tF/43200,0));
   if(MathMod(tF,10080)==0) return ("W"+DoubleToString(tF/10080,0));
   if(MathMod(tF,1440)==0) return ("D"+DoubleToString(tF/1440,0));
   if(MathMod(tF,60)==0) return ("H"+DoubleToString(tF/60,0));
   return ("M"+IntegerToString(tF));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime CandleTime(int i,ENUM_TIMEFRAMES tF,string symbol)
  {
   if(i<0) i=0;
   if(tF==PERIOD_CURRENT) tF=(ENUM_TIMEFRAMES)Period();
   return iTime(symbol,tF,i);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void EPrint(string msg="")
  {
   static string lastMsg="";
   if(lastMsg==msg) return;
   Print(msg);
   lastMsg=msg;
  }
void LPrint(string msg="") { EPrint(msg); }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double NormL(double lo)
  {
   double lotstep=SymbolInfoDouble(Simbolo,SYMBOL_VOLUME_STEP);
   if(lotstep==NULL)
     {
      return(NULL);
     }
   return(((fmin(fmax(ceil(lo/lotstep)*lotstep,SymbolInfoDouble(Simbolo,SYMBOL_VOLUME_MIN)),SymbolInfoDouble(Simbolo,SYMBOL_VOLUME_MAX)))));
  }
//+------------------------------------------------------------------+
//---
//---
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//---
#define LIC_NAME           ""
#define LIC_TEST           false
#define LIC_MAXIMAL_DATE   D'27.04.2219'  // Максимальная дата работы советника, если 0=откл  | Maximum date of the expert advisor, 0 = off
#define LIC_KEY            0              // Ключ, если 0=откл                                | The key, 0 = off
#define LIC_ACCOUNT_NUMBER 0              // Номер счёта, если 0=откл                         | Account number, 0 = off
//---
bool LicenseValidation(int mag=0,int key=0)
  {
   bool     ru=(StringFind(TerminalInfoString(TERMINAL_LANGUAGE),"Russian",0)>-1) ?true :false;
   string   title=(MQLInfoString(MQL_PROGRAM_NAME)+" ("+Symbol()+((mag>0) ?(", ID-"+IntegerToString(mag)) :(""))+")");
   if(LIC_TEST && !MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_TESTER))
     {
      Alert(title,((ru) ?"  Только для тестера!" :"  Only for tester!"));
      return(false);
     }
   if(LIC_MAXIMAL_DATE>0 && TimeLocal()>LIC_MAXIMAL_DATE)
     {
      Alert(title,((ru) ?"  Время демонстрации истекло!" :"  The demonstration has expired!"));
      return(false);
     }
   if(LIC_KEY>0 && LIC_KEY!=key)
     {
      Alert(title,((ru) ?"  Неверный ключ лицензии!" :"  Invalid license key!"));
      return(false);
     }
   if(LIC_ACCOUNT_NUMBER>0 && LIC_ACCOUNT_NUMBER!=AccountInfoInteger(ACCOUNT_LOGIN))
     {
      Alert(title,((ru) ?"  Нелицензированный аккаунт!" :"  Invalid account number!"));
      return(false);
     }
   if(StringLen(IntegerToString(mag))>6)
     {
      Alert(title,((ru) ?"  Некорректное значение ID советника, установите значение не более 6 цифр!"
            :"  Incorrect value ID Advisor, set this value to no more than 6 digits!"));
      return(false);
     }
   if(!MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_TESTER) && LIC_NAME!="" && StringFind(AccountInfoString(ACCOUNT_NAME),LIC_NAME)<0)
     {
      Alert(title,((ru) ?"  Нелицензированный владелец!" :"  Invalid account nick name!"));
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//---
//---


double LucroPositions()
  {
   double profit=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
      if(myposition.SelectByIndex(i) && myposition.Magic()==magicNumber && myposition.Symbol()==mysymbol.Name())
         profit+=myposition.Profit();
   return profit;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LucroPontos()
  {
   double profit=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==magicNumber && myposition.Symbol()==mysymbol.Name())
        {
         if(myposition.PositionType()==POSITION_TYPE_BUY)
            profit+=SymbolInfoDouble(Simbolo,SYMBOL_BID)-myposition.PriceOpen();
         if(myposition.PositionType()==POSITION_TYPE_SELL)
            profit+=myposition.PriceOpen()-SymbolInfoDouble(Simbolo,SYMBOL_ASK);
        }
     }
   return (profit/ponto);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LucroPontosMedio()
  {
   double profit=0;
   double profitSell=0;
   double profitBuy=0;
   double volbuy=VolPosType(POSITION_TYPE_BUY);
   double volsell=VolPosType(POSITION_TYPE_SELL);
   if(volbuy>0)profitBuy=(SymbolInfoDouble(Simbolo,SYMBOL_BID)-PrecoMedio(POSITION_TYPE_BUY))/ponto;
   if(volsell>0)profitSell=(PrecoMedio(POSITION_TYPE_SELL)-SymbolInfoDouble(Simbolo,SYMBOL_ASK))/ponto;
   profit=profitBuy+profitSell;
   return (profit);
  }
//+------------------------------------------------------------------+
double VolPosType(ENUM_POSITION_TYPE ptype)
  {
   double vol=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==magicNumber && myposition.PositionType()==ptype && myposition.Symbol()==mysymbol.Name())
        {
         vol+=myposition.Volume();
        }
     }
   return vol;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double PrecoMedio(ENUM_POSITION_TYPE ptype)
  {
   double vol=0;
   double preco=0;
   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==magicNumber && myposition.PositionType()==ptype && myposition.Symbol()==mysymbol.Name())
        {
         vol+=myposition.Volume();
         preco+=myposition.Volume()*myposition.PriceOpen();
        }
     }
   if(vol>0)preco=preco/vol;
   preco=NormalizeDouble(MathRound(preco/ticksize)*ticksize,_Digits);
   return preco;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CloseALL()
  {

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i) && myposition.Magic()==magicNumber && myposition.Symbol()==mysymbol.Name())
        {
         if(!trade.PositionClose(PositionGetTicket(i)))
           {
            Print(PositionGetTicket(i),"PositionClose() method failed. Return code=",trade.ResultRetcode(),
                  ". Code description: ",trade.ResultRetcodeDescription());
           }
         else
           {
            Print(PositionGetTicket(i),"PositionClose() method executed successfully. Return code=",trade.ResultRetcode(),
                  " (",trade.ResultRetcodeDescription(),")");
           }
        }
     }
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
         if(myorder.Magic()==magicNumber && myorder.Symbol()==mysymbol.Name()) trade.OrderDelete(o_ticket);
        }
     }
  }
//+------------------------------------------------------------------+
