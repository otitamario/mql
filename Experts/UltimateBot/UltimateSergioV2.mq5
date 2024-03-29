//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#define VERSION "1.0"// Mudar aqui as Versões

#property copyright "UltimabteBot <contato@ultimatebot.com.br>"
#property version   VERSION
#property link      "https://www.ultimatebot.com.br"
#property description   "https://www.ultimatebot.com.br"
#property description   "AVISO: Você usará este EA em renda variável, portanto é um estratégia com risco alto,"
#property description   "ou seja, pode ter ganhos altos , mas também perdas."
#property description   "Antes de utilizar, encontre uma configuração adequada para seus objetivos."
#property description   "seus objetivos de investimento, nível de experiência e tolerância ao risco."
#property icon "\\Files\\UltimateBot.ico"


#resource "\\Files\\UltimateBotLitlle.bmp"
string keystr="892fb7a2097d7f0183c4c56498a36b00";
datetime data_validade;
string Only_Demo;
#include <Bcrypt.mqh>
CBcrypt B;

#define KEY_NUMPAD_5       12 
#define KEY_LEFT           37 
#define KEY_UP             38 
#define KEY_RIGHT          39 
#define KEY_DOWN           40 
#define KEY_NUMLOCK_DOWN   98 
#define KEY_NUMLOCK_LEFT  100 
#define KEY_NUMLOCK_5     101 
#define KEY_NUMLOCK_RIGHT 102 
#define KEY_NUMLOCK_UP    104 

#include <TradingBoxingSergio.mqh>
CTrade mytrade;
CChartObjectBmpLabel FotoUltimate;

//--- input parameters
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
Boleta ExtDialog;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      string erro="Para usar em conta HEDGE contate o desenvolvedor";
      Print(erro);
      Alert(erro);
      MessageBox(erro);
      return INIT_FAILED;

     }
   if(!MQLInfoInteger(MQL_OPTIMIZATION) && !MQLInfoInteger(MQL_TESTER))
     {
      if(!ValidarSenha(senha))
         return INIT_FAILED;
     }

//--- create application dialog
   if(!ExtDialog.Create(0,"Boleta",0,0,0,234,310,MAGIC_NUMBER))
      return(INIT_FAILED);
//--- run application
   ExtDialog.Run();

   if(!ChartSetInteger(ChartID(),CHART_SHIFT,0,50))
     {
      //--- display the error message in Experts journal
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }

   ChartSetInteger(ChartID(),CHART_EVENT_OBJECT_CREATE,true);
//--- Ativar eventos de exclusão de objetos 
   ChartSetInteger(ChartID(),CHART_EVENT_OBJECT_DELETE,true);
//--- A atualização forçada das propriedades do gráfico garante a prontidão para o processamento de eventos 

   ChartSetInteger(ChartID(),CHART_EVENT_MOUSE_MOVE,true);

   ChartRedraw();
   FotoUltimate.Create(ChartID(),"FotoUltimate",0,0,0);
   FotoUltimate.BmpFileOn("::Files\\UltimateBotLitlle.bmp");
   FotoUltimate.SetInteger(OBJPROP_XSIZE,80);
   FotoUltimate.SetInteger(OBJPROP_YSIZE,60);
   FotoUltimate.SetInteger(OBJPROP_XDISTANCE,100);
   FotoUltimate.SetInteger(OBJPROP_YDISTANCE, 30);

   FotoUltimate.Corner(CORNER_RIGHT_UPPER);

   return ExtDialog.OnInit();


//--- succeed
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)

  {
   ChartSetInteger(0,CHART_SHIFT,0,false);

//--- destroy dialog
   ExtDialog.Destroy(reason);
   ExtDialog.OnDeinit(reason);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
   ExtDialog.OnTimer();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {
   ExtDialog.OnTradeTransaction(trans,request,result);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   ExtDialog.OnTick();

  }
//+------------------------------------------------------------------+
//| Expert chart event function                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // event ID  
                  const long& lparam,   // event parameter of the long type
                  const double& dparam, // event parameter of the double type
                  const string& sparam) // event parameter of the string type
  {
   ExtDialog.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
bool ValidarSenha(string password)
  {
   int trim;
   trim=StringTrimLeft(password);
   trim=StringTrimRight(password);
   ulong conta_usuario;
   B.Init(keystr);
   string decoded=B.Decrypt(password);
   string to_split = decoded; // Um string para dividir em substrings
   string sep = "_";          // Um separador como um caractere
   ushort u_sep;              // O código do caractere separador
   string result[];           // Um array para obter strings
//--- Obtém o código do separador
   u_sep=StringGetCharacter(sep,0);
//--- Divide a string em substrings
   int k=StringSplit(to_split,u_sep,result);
//--- Exibe um comentário
//--- Agora imprime todos os resultados obtidos
   if(k>0)
     {
      conta_usuario = StringToInteger(result[0]);
      data_validade = StringToTime(result[1]);
      Only_Demo=result[2];

      if(TimeCurrent()>data_validade)
        {
         string erro="Data de Validade Expirada";
         MessageBox(erro);
         Print(erro);
         return false;
        }
      if(AccountInfoInteger(ACCOUNT_LOGIN)!=conta_usuario)
        {
         string erro="Usuário Não Permitido";
         MessageBox(erro);
         Print(erro);
         return false;
        }

      if(Only_Demo=="Sim" && (ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE)!=ACCOUNT_TRADE_MODE_DEMO)
        {
         string erro="EA permitido apenas em conta DEMO";
         MessageBox(erro);
         Print(erro);
         return false;
        }

     }
   else
      return false;
   return true;
  }
//+------------------------------------------------------------------+
