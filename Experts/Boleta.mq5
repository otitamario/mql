//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Kiss Trend"
#property version   "1.000"

#define VALIDADE   D'2100.12.31 23:59:59'//Data de Validade ano.mes.dia horas:minutos:segundos(opcional)
#define NUMERO_CONTA 9011600   //Numero da conta
#define ONLY_DEMO "NAO" //"SIM"- Somente em Demo,"NAO"- liberado para conta Real



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

#include <TradingBoxingDialogBoleta.mqh>
CTrade mytrade;
//--- input parameters
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CTradingBoxingDialog ExtDialog;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   ulong numero_conta=NUMERO_CONTA;
   datetime expiracao = VALIDADE;
   string msg_validade= "Validade até "+TimeToString(expiracao)+" para a conta "+IntegerToString(numero_conta)+" "+AccountInfoString(ACCOUNT_SERVER);
   MessageBox(msg_validade);
   Print(msg_validade);
   bool licenca=TimeCurrent()>expiracao || AccountInfoInteger(ACCOUNT_LOGIN)!=numero_conta;
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

   ChartSetInteger(0,CHART_SHIFT,0,true);
   ChartSetDouble(0,CHART_SHIFT_SIZE,10);

//--- create application dialog
   if(!ExtDialog.Create(0,"Boleta",0,0,0,234,350,MAGIC_NUMBER))

      //   if(!ExtDialog.Create(0,"TradingBoxing",0,280,20,514,450,MAGIC_NUMBER))
      return(INIT_FAILED);
//--- run application
   ExtDialog.Run();

   ChartSetInteger(ChartID(),CHART_EVENT_OBJECT_CREATE,true);
//--- Ativar eventos de exclusão de objetos 
   ChartSetInteger(ChartID(),CHART_EVENT_OBJECT_DELETE,true);
//--- A atualização forçada das propriedades do gráfico garante a prontidão para o processamento de eventos 

   ChartSetInteger(ChartID(),CHART_EVENT_MOUSE_MOVE,true);

   ChartRedraw();

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
