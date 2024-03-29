//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Kiss Trend"
#property version   "1.000"
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

#include <TradingBoxingDialog.mqh>
CTrade mytrade;
//--- input parameters
input ulong          m_magic=335685240;         // magic number
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
CTradingBoxingDialog ExtDialog;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   ChartSetInteger(0,CHART_SHIFT,0,true);
   ChartSetDouble(0,CHART_SHIFT_SIZE,10);

//--- create application dialog
   if(!ExtDialog.Create(0,"RenkoTradePanel",0,0,0,234,430,m_magic))

      //   if(!ExtDialog.Create(0,"TradingBoxing",0,280,20,514,450,m_magic))
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
   ObjectDelete(0,"RET");
   ObjectDelete(0,"TLAB");
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
//--- o botão esquerdo do mouse foi pressionado no gráfico 
   if(id==CHARTEVENT_CLICK)
     {
      Print("As coordenadas do clique do mouse sobre o gráfico são: x = ",lparam,"  y = ",dparam);
     }

   if(id==CHARTEVENT_OBJECT_CHANGE)
     {
      Print("Obj modificado: x = ",lparam,"  y = ",dparam);
     }

//--- o mouse foi clicado sobre o objeto gráfico 
   if(id==CHARTEVENT_OBJECT_CLICK)
     {
      Print("O mouse foi clicado sobre o objeto com o nome '"+sparam+"'");
      double value;
      ObjectGetDouble(0,sparam,OBJPROP_PRICE,0,value);
      Print(value); // Old Value

     }
//--- a tecla foi pressionada 
   if(id==CHARTEVENT_KEYDOWN)
     {
      switch(lparam)
        {
         case KEY_NUMLOCK_LEFT:  Print("O KEY_NUMLOCK_LEFT foi pressionado");   break;
         case KEY_LEFT:          Print("O KEY_LEFT foi pressionado");           break;
         case KEY_NUMLOCK_UP:    Print("O KEY_NUMLOCK_UP foi pressionado");     break;
         case KEY_UP:            Print("O KEY_UP foi pressionado");             break;
         case KEY_NUMLOCK_RIGHT: Print("O KEY_NUMLOCK_RIGHT foi pressionado");  break;
         case KEY_RIGHT:         Print("O KEY_RIGHT foi pressionado");          break;
         case KEY_NUMLOCK_DOWN:  Print("O KEY_NUMLOCK_DOWN foi pressionado");   break;
         case KEY_DOWN:          Print("O KEY_DOWN foi pressionado");           break;
         case KEY_NUMPAD_5:      Print("O KEY_NUMPAD_5 foi pressionado");       break;
         case KEY_NUMLOCK_5:     Print("O KEY_NUMLOCK_5 foi pressionado");      break;
         default:                Print("Algumas teclas não listadas foram pressionadas");
        }
      ChartRedraw();
     }

   if(id==CHARTEVENT_MOUSE_MOVE)
     {
      // Print("O objeto foi movido ",sparam,"");
     }
//-
//--- o objeto foi excluído 
   if(id==CHARTEVENT_OBJECT_DELETE)
     {
      // Print("O objeto com o nome ",sparam," foi excluído");
     }
//--- o objeto foi criado 
   if(id==CHARTEVENT_OBJECT_CREATE)
     {
      //  Print("O objeto com o nome ",sparam," foi criado");
     }
//--- o objeto foi movido ou suas coordenadas de ponto de ancoragem foram alteradas 
  /* if(id==CHARTEVENT_OBJECT_DRAG)
     {
      double value;
      ObjectGetDouble(0,sparam,OBJPROP_PRICE,0,value);
      Print(value); // Old Value
      HLineMove(0,sparam,value);
      mytrade.OrderModify((ulong)GlobalVariableGet(tp_vd_tick),value,0,0,0,0,0);

      Print("O ponto de ancoragem das coordenadas do objeto com o nome ",sparam," foi alterado");
     }*/
//--- o texto na Edição do objeto foi alterado 
   if(id==CHARTEVENT_OBJECT_ENDEDIT)
     {
      Print("O texto no campo da Edição do objeto com o nome ",sparam," foi alterado");
     }
  }
//+------------------------------------------------------------------+
bool HLineMove(const long   chart_ID=0,// ID do gráfico 
               const string name="HLine", // nome da linha 
               double       price=0)      // preço da linha 
  {
//--- se o preço não está definido, defina-o no atual nível de preço Bid 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- redefine o valor de erro 
   ResetLastError();
//--- mover um linha horizontal  
   if(!ObjectMove(chart_ID,name,0,0,price))
     {
      Print(__FUNCTION__,
            ": falha ao mover um linha horizontal! Código de erro = ",GetLastError());
      return(false);
     }
//--- sucesso na execução 
   return(true);
  }
//+------------------------------------------------------------------+
