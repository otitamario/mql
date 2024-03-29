//+------------------------------------------------------------------+
//|                                                      EA_DLLs.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Mostrar
  {
   SIM,//Sim
   NAO//Não

  };

#import "Class1.dll"
#import "BCB.dll"
#include<ChartObjects\ChartObjectsLines.mqh>
#include <ChartObjects\ChartObjectsArrows.mqh>      


CChartObjectHLine LinhaAjuste[];
CChartObjectHLine LinhaOpen[];
CChartObjectHLine LinhaInt1[];
CChartObjectHLine LinhaInt2[];
CChartObjectHLine LinhaInt3[];
CChartObjectHLine LinhaClose[];
CChartObjectArrowCheck arrow[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
struct PTAX
  {
   double            open;     // Abertura
   double            int1;    // Intermediário 1 
   double            int2;    // Intermediário 2 
   double            int3;    // Intermediário 3
   double            close; //Final 

  };

input int DIAS=2;// Dias de Histórico
input string vencimento="F19";//Vencimento para Ajuste
sinput string scolors="-------------Opções------------------";//Cores
input color cor_ajuste=clrDarkTurquoise;//Cor Ajuste
input ENUM_LINE_STYLE style_aj=STYLE_SOLID,// Estilo da linha 
input int  width_aj=1,// Largura da linha 
input Mostrar mostrar_aj=SIM;//Mostrar Ajuste
input color cor_open=clrLime;//Cor PTAX Open
input ENUM_LINE_STYLE style_open=STYLE_SOLID,// Estilo da linha 
input int  width_open=1,// Largura da linha 
input Mostrar mostrar_open=SIM;//Mostrar PTAX Open
input color cor_int1=clrBlue;//Cor PTAX Intermediário 1
input ENUM_LINE_STYLE style_int1=STYLE_SOLID,// Estilo da linha 
input int  width_int1=1,// Largura da linha 
input Mostrar mostrar_int1=SIM;//Mostrar PTAX Intermediário 1
input color cor_int2=clrBlue;//Cor PTAX Intermediário 2
input ENUM_LINE_STYLE style_int2=STYLE_SOLID,// Estilo da linha 
input int  width_int2=1,// Largura da linha 
input Mostrar mostrar_int2=SIM;//Mostrar PTAX Intermediário 2
input color cor_int3=clrBlue;//Cor PTAX Intermediário 3
input ENUM_LINE_STYLE style_int3=STYLE_SOLID,// Estilo da linha 
input int  width_int3=1,// Largura da linha 
input Mostrar mostrar_int3=SIM;//Mostrar PTAX Intermediário 3
input color cor_close=clrRed;//Cor PTAX Close
input ENUM_LINE_STYLE style_close=STYLE_SOLID,// Estilo da linha 
input int  width_close=1,// Largura da linha 
input Mostrar mostrar_close=SIM;//Mostrar Ajuste

string data_ptax;
string data_ajuste;

double Ajuste[];
PTAX ptax[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(TimeCurrent()>D'2018.12.30 23:59:59')
     {
      string erro="Data de Validade Expirou";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

//---
   ArrayResize(Ajuste,DIAS);
   ArrayResize(ptax,DIAS);
   ArrayResize(LinhaAjuste,DIAS);
   ArrayResize(LinhaOpen,DIAS);
   ArrayResize(LinhaInt1,DIAS);
   ArrayResize(LinhaInt2,DIAS);
   ArrayResize(LinhaInt3,DIAS);
   ArrayResize(LinhaClose,DIAS);
   ArrayResize(arrow,DIAS);

   for(int i=0;i<DIAS;i++)
     {
      GetValues(i);
     }

   ChartRedraw();
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   ObjectsDeleteAll(ChartID(),0,OBJ_TREND);
   ObjectsDeleteAll(ChartID(),0,OBJ_ARROW_CHECK);

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   static datetime LastBar=0;
   datetime ThisBar=iTime(Symbol(),PERIOD_M30,0);
   if(LastBar!=ThisBar)
     {
      LastBar=ThisBar;

      for(int i=0;i<DIAS;i++)
        {
         GetValues(i);
        }

      ChartRedraw();

     }

  }
//+------------------------------------------------------------------+
void GetValues(const int idx)
  {

   int replaced;
   double media;
   string compra,venda;
   string sep="#";                // Um separador como um caractere 
   ushort u_sep;                  // O código do caractere separador 
   string result[];               // Um array para obter strings 


   string aj_aux;
   datetime tm_today;
   MqlDateTime stm_today;

   tm_today=iTime(Symbol(),PERIOD_D1,idx);
   TimeToStruct(tm_today,stm_today);
   data_ptax=IntegerToString(stm_today.day)+"/"+IntegerToString(stm_today.mon)+"/"+IntegerToString(stm_today.year);

   string to_split=BCB::getDados(data_ptax);

   tm_today=iTime(Symbol(),PERIOD_D1,idx+1);
   TimeToStruct(tm_today,stm_today);
   data_ajuste=IntegerToString(stm_today.day)+"/"+IntegerToString(stm_today.mon)+"/"+IntegerToString(stm_today.year);

   aj_aux=Class1::getPrecoAjuste(vencimento,data_ajuste);
   replaced=StringReplace(aj_aux,".","");
   replaced=StringReplace(aj_aux,",",".");

   Ajuste[idx]=StringToDouble(aj_aux);
   datetime hora_in=StringToTime(TimeToString(iTime(Symbol(),PERIOD_D1,idx),TIME_DATE)+" "+"9:00");
   datetime hora_fin=StringToTime(TimeToString(iTime(Symbol(),PERIOD_D1,idx),TIME_DATE)+" "+"18:30");

   string bcb=BCB::getDados(data_ptax);

//--- Obtém o código do separador 
   u_sep=StringGetCharacter(sep,0);
//--- Divide a string em substrings 
   int k=StringSplit(to_split,u_sep,result);
//--- Exibe um comentário 
//--- Agora imprime todos os resultados obtidos 
   if(k>0)
     {
      for(int j=0;j<k;j++)
        {
         if(StringFind(result[j],"compra")>=0 && StringFind(result[j],"venda")>=0)
           {
            compra=StringSubstr(result[j],StringFind(result[j],"compra")+7,6);
            venda=StringSubstr(result[j],StringFind(result[j],"venda")+6,6);
            replaced=StringReplace(compra,",",".");
            replaced=StringReplace(venda,",",".");
            media=0.5*(StringToDouble(compra)+StringToDouble(venda));
            media=media*1000;
            if(j==0)ptax[idx].open=media;
            if(j==1)ptax[idx].int1=media;
            if(j==2)ptax[idx].int2=media;
            if(j==3)ptax[idx].int3=media;
            if(j==4)ptax[idx].close=media;
           }
         else
           {
            if(j==0)ptax[idx].open=0;
            if(j==1)ptax[idx].int1=0;
            if(j==2)ptax[idx].int2=0;
            if(j==3)ptax[idx].int3=0;
            if(j==4)ptax[idx].close=0;

           }

        }

     }
   if(mostrar_aj==SIM)
     {
      LinhaAjuste[idx].Create(ChartID(),"Ajuste"+IntegerToString(idx),0,Ajuste[idx]);
      //LinhaAjuste[idx].Create(ChartID(),"Ajuste"+IntegerToString(idx),0,hora_in,Ajuste[idx],hora_fin,Ajuste[idx]);
      LinhaAjuste[idx].Width(width_aj);
      LinhaAjuste[idx].Style(style_aj);
      LinhaAjuste[idx].Color(cor_ajuste);
      LinhaAjuste[idx].Tooltip("Ajuste "+DoubleToString(Ajuste[idx],SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));
     }

   LinhaOpen[idx].Create(ChartID(),"Open"+IntegerToString(idx),0,hora_in,ptax[idx].open,hora_fin,ptax[idx].open);
   LinhaOpen[idx].RayLeft(false);
   LinhaOpen[idx].RayRight(false);
   LinhaOpen[idx].Color(cor_open);
   LinhaOpen[idx].Tooltip("PTAX Open "+DoubleToString(ptax[idx].open,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));

   LinhaInt1[idx].Create(ChartID(),"Int1"+IntegerToString(idx),0,hora_in,ptax[idx].int1,hora_fin,ptax[idx].int1);
   LinhaInt1[idx].RayLeft(false);
   LinhaInt1[idx].RayRight(false);
   LinhaInt1[idx].Color(cor_int1);
   LinhaInt1[idx].Tooltip("PTAX Intermediário 1 "+DoubleToString(ptax[idx].int1,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));

   LinhaInt2[idx].Create(ChartID(),"Int2"+IntegerToString(idx),0,hora_in,ptax[idx].int2,hora_fin,ptax[idx].int2);
   LinhaInt2[idx].RayLeft(false);
   LinhaInt2[idx].RayRight(false);
   LinhaInt2[idx].Color(cor_int2);
   LinhaInt2[idx].Tooltip("PTAX Intermediário 2 "+DoubleToString(ptax[idx].int2,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));

   LinhaInt3[idx].Create(ChartID(),"Int3"+IntegerToString(idx),0,hora_in,ptax[idx].int3,hora_fin,ptax[idx].int3);
   LinhaInt3[idx].RayLeft(false);
   LinhaInt3[idx].RayRight(false);
   LinhaInt3[idx].Color(cor_int3);
   LinhaInt3[idx].Tooltip("PTAX Intermediário 3 "+DoubleToString(ptax[idx].int3,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));

   LinhaClose[idx].Create(ChartID(),"Close"+IntegerToString(idx),0,hora_in,ptax[idx].close,hora_fin,ptax[idx].close);
   LinhaClose[idx].RayLeft(false);
   LinhaClose[idx].RayRight(false);
   LinhaClose[idx].Color(cor_close);
   LinhaClose[idx].Tooltip("PTAX Close "+DoubleToString(ptax[idx].close,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));

   arrow[idx].Create(ChartID(),"arrow"+IntegerToString(idx),0,hora_in,iLow(Symbol(),PERIOD_D1,idx)-5*SymbolInfoDouble(Symbol(),SYMBOL_TRADE_TICK_SIZE),38);
   arrow[idx].Color(clrYellow);
   arrow[idx].Width(3);
   string tip="Ajuste "+DoubleToString(Ajuste[idx],SymbolInfoInteger(Symbol(),SYMBOL_DIGITS))+"\n"
              +"PTAX Open "+DoubleToString(ptax[idx].open,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS))+"\n"
              +"PTAX Intermediário 1 "+DoubleToString(ptax[idx].int1,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS))+"\n"
              +"PTAX Intermediário 2 "+DoubleToString(ptax[idx].int2,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS))+"\n"
              +"PTAX Intermediário 3 "+DoubleToString(ptax[idx].int3,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS))+"\n"
              "PTAX Close "+DoubleToString(ptax[idx].close,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS));
   arrow[idx].Tooltip(tip);

  }
//+------------------------------------------------------------------+
