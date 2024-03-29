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
CChartObjectHLine LinhaMax[];
CChartObjectHLine LinhaMin[];
CChartObjectHLine LinhaDayOpen[];
CChartObjectHLine LinhaDayClose[];

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
sinput string scolors="-------------Opções------------------";//Opções
sinput string smaxmin="-------------Máximas e Mínimas------------------";//Máximas e Mínimas
input color cor_max=clrLime;//Cor Máxima
input ENUM_LINE_STYLE style_max=STYLE_SOLID;// Estilo da linha 
input int  width_max=1;// Largura da linha 
input Mostrar mostrar_max=SIM;//Mostrar Máximas
input color cor_min=clrLime;//Cor Mínima
input ENUM_LINE_STYLE style_min=STYLE_SOLID;// Estilo da linha 
input int  width_min=1;// Largura da linha 
input Mostrar mostrar_min=SIM;//Mostrar Mínimas
sinput string sabfech="-------------Abertura e Fechamento------------------";//Abertura e Fechamento
input color cor_aber=clrMaroon;//Cor Abertura
input ENUM_LINE_STYLE style_aber=STYLE_SOLID;// Estilo da linha 
input int  width_aber=1;// Largura da linha 
input Mostrar mostrar_aber=SIM;//Mostrar Abertura
input color cor_fech=clrMaroon;//Cor Fechamento
input ENUM_LINE_STYLE style_fech=STYLE_SOLID;// Estilo da linha 
input int  width_fech=1;// Largura da linha 
input Mostrar mostrar_fech=SIM;//Mostrar fechamento

sinput string sajuste="-------------Ajuste------------------";//Ajuste
input color cor_ajuste=clrDarkTurquoise;//Cor Ajuste
input ENUM_LINE_STYLE style_aj=STYLE_SOLID;// Estilo da linha 
input int  width_aj=1;// Largura da linha 
input Mostrar mostrar_aj=SIM;//Mostrar Ajuste
sinput string sptax="-------------PTAX------------------";//PTAX
input color cor_open=clrLime;//Cor PTAX Open
input ENUM_LINE_STYLE style_open=STYLE_SOLID;// Estilo da linha 
input int  width_open=1;// Largura da linha 
input Mostrar mostrar_open=SIM;//Mostrar PTAX Open
input color cor_int1=clrBlue;//Cor PTAX Intermediário 1
input ENUM_LINE_STYLE style_int1=STYLE_SOLID;// Estilo da linha 
input int  width_int1=1;// Largura da linha 
input Mostrar mostrar_int1=SIM;//Mostrar PTAX Intermediário 1
input color cor_int2=clrBlue;//Cor PTAX Intermediário 2
input ENUM_LINE_STYLE style_int2=STYLE_SOLID;// Estilo da linha 
input int  width_int2=1;// Largura da linha 
input Mostrar mostrar_int2=SIM;//Mostrar PTAX Intermediário 2
input color cor_int3=clrBlue;//Cor PTAX Intermediário 3
input ENUM_LINE_STYLE style_int3=STYLE_SOLID;// Estilo da linha 
input int  width_int3=1;// Largura da linha 
input Mostrar mostrar_int3=SIM;//Mostrar PTAX Intermediário 3
input color cor_close=clrRed;//Cor PTAX Close
input ENUM_LINE_STYLE style_close=STYLE_SOLID;// Estilo da linha 
input int  width_close=1;// Largura da linha 
input Mostrar mostrar_close=SIM;//Mostrar Ajuste

string data_ptax;
string data_ajuste;

double Ajuste[];
PTAX ptax[];
string datamaxmin;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

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
   ArrayResize(LinhaMax,DIAS);
   ArrayResize(LinhaMin,DIAS);
   ArrayResize(LinhaDayClose,DIAS);
   ArrayResize(LinhaDayOpen,DIAS);

   for(int i=0;i<DIAS;i++)
     {
      GetValues(i);
      if(mostrar_max==SIM)
        {
         LinhaMax[i].Create(ChartID(),"MAX"+IntegerToString(i),0,iHigh(Symbol(),PERIOD_D1,i));
         LinhaMax[i].Width(width_max);
         LinhaMax[i].Style(style_max);
         LinhaMax[i].Color(cor_max);
         datamaxmin=TimeToString(iTime(Symbol(),PERIOD_D1,i),TIME_DATE);
         LinhaMax[i].Tooltip(datamaxmin+" Máxima "+DoubleToString(iHigh(Symbol(),PERIOD_D1,i),SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));

        }
      if(mostrar_min==SIM)
        {
         LinhaMin[i].Create(ChartID(),"MIN"+IntegerToString(i),0,iLow(Symbol(),PERIOD_D1,i));
         LinhaMin[i].Width(width_min);
         LinhaMin[i].Style(style_min);
         LinhaMin[i].Color(cor_min);
         datamaxmin=TimeToString(iTime(Symbol(),PERIOD_D1,i),TIME_DATE);
         LinhaMin[i].Tooltip(datamaxmin+" Mínima "+DoubleToString(iLow(Symbol(),PERIOD_D1,i),SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));
        }

      if(mostrar_aber==SIM)
        {
         LinhaDayOpen[i].Create(ChartID(),"Abertura"+IntegerToString(i),0,iOpen(Symbol(),PERIOD_D1,i));
         LinhaDayOpen[i].Width(width_aber);
         LinhaDayOpen[i].Style(style_aber);
         LinhaDayOpen[i].Color(cor_aber);
         datamaxmin=TimeToString(iTime(Symbol(),PERIOD_D1,i),TIME_DATE);
         LinhaDayOpen[i].Tooltip(datamaxmin+" Abertura "+DoubleToString(iOpen(Symbol(),PERIOD_D1,i),SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));

        }
      if(mostrar_fech==SIM)
        {
         LinhaDayClose[i].Create(ChartID(),"Fechamento"+IntegerToString(i),0,iClose(Symbol(),PERIOD_D1,i));
         LinhaDayClose[i].Width(width_fech);
         LinhaDayClose[i].Style(style_fech);
         LinhaDayClose[i].Color(cor_fech);
         datamaxmin=TimeToString(iTime(Symbol(),PERIOD_D1,i),TIME_DATE);
         LinhaDayClose[i].Tooltip(datamaxmin+" Fechamento "+DoubleToString(iClose(Symbol(),PERIOD_D1,i),SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));
        }

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
   ObjectsDeleteAll(ChartID(),0,OBJ_HLINE);
   ObjectsDeleteAll(ChartID(),0,OBJ_ARROW_CHECK);

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

   static datetime LastBarMin=0;
   datetime ThisBarMin=iTime(Symbol(),PERIOD_M1,0);
   if(LastBarMin!=ThisBarMin)
     {
      LastBarMin=ThisBarMin;
      ObjectsDeleteAll(ChartID(),"MAX");
      ObjectsDeleteAll(ChartID(),"MIN");
      ObjectsDeleteAll(ChartID(),"Abertura");
      ObjectsDeleteAll(ChartID(),"Fechamento");

      for(int i=0;i<DIAS;i++)
        {
         if(mostrar_max==SIM)
           {
            LinhaMax[i].Create(ChartID(),"MAX"+IntegerToString(i),0,iHigh(Symbol(),PERIOD_D1,i));
            LinhaMax[i].Width(width_max);
            LinhaMax[i].Style(style_max);
            LinhaMax[i].Color(cor_max);
            datamaxmin=TimeToString(iTime(Symbol(),PERIOD_D1,i),TIME_DATE);
            LinhaMax[i].Tooltip(datamaxmin+" Máxima "+DoubleToString(iHigh(Symbol(),PERIOD_D1,i),SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));
           }
         if(mostrar_min==SIM)
           {
            LinhaMin[i].Create(ChartID(),"MIN"+IntegerToString(i),0,iLow(Symbol(),PERIOD_D1,i));
            LinhaMin[i].Width(width_min);
            LinhaMin[i].Style(style_min);
            LinhaMin[i].Color(cor_min);
            datamaxmin=TimeToString(iTime(Symbol(),PERIOD_D1,i),TIME_DATE);
            LinhaMin[i].Tooltip(datamaxmin+" Mínima "+DoubleToString(iLow(Symbol(),PERIOD_D1,i),SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));
           }

         if(mostrar_aber==SIM)
           {
            LinhaDayOpen[i].Create(ChartID(),"Abertura"+IntegerToString(i),0,iOpen(Symbol(),PERIOD_D1,i));
            LinhaDayOpen[i].Width(width_aber);
            LinhaDayOpen[i].Style(style_aber);
            LinhaDayOpen[i].Color(cor_aber);
            datamaxmin=TimeToString(iTime(Symbol(),PERIOD_D1,i),TIME_DATE);
            LinhaDayOpen[i].Tooltip(datamaxmin+" Abertura "+DoubleToString(iOpen(Symbol(),PERIOD_D1,i),SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));

           }
         if(mostrar_fech==SIM)
           {
            LinhaDayClose[i].Create(ChartID(),"Fechamento"+IntegerToString(i),0,iClose(Symbol(),PERIOD_D1,i));
            LinhaDayClose[i].Width(width_fech);
            LinhaDayClose[i].Style(style_fech);
            LinhaDayClose[i].Color(cor_fech);
            datamaxmin=TimeToString(iTime(Symbol(),PERIOD_D1,i),TIME_DATE);
            LinhaDayClose[i].Tooltip(datamaxmin+" Fechamento "+DoubleToString(iClose(Symbol(),PERIOD_D1,i),SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));
           }

        }
      ChartRedraw();

     }

   static datetime LastBar=0;
   datetime ThisBar=iTime(Symbol(),PERIOD_M1,0);
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
   string mes,dia;
   tm_today=iTime(Symbol(),PERIOD_D1,idx);
   TimeToStruct(tm_today,stm_today);
   data_ptax=IntegerToString(stm_today.day)+"/"+IntegerToString(stm_today.mon)+"/"+IntegerToString(stm_today.year);

   string to_split=BCB::getDados(data_ptax);

   tm_today=iTime(Symbol(),PERIOD_D1,idx+1);
   TimeToStruct(tm_today,stm_today);
   if(stm_today.day<10)dia="0"+IntegerToString(stm_today.day);
   else dia=IntegerToString(stm_today.day);
   if(stm_today.mon<10)mes="0"+IntegerToString(stm_today.mon);
   else mes=IntegerToString(stm_today.mon);
// data_ajuste=IntegerToString(stm_today.day)+"/"+IntegerToString(stm_today.mon)+"/"+IntegerToString(stm_today.year);
   data_ajuste=dia+"/"+mes+"/"+IntegerToString(stm_today.year);

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
   ptax[idx].open=0;
   ptax[idx].int1=0;
   ptax[idx].int2=0;
   ptax[idx].int3=0;
   ptax[idx].close=0;

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
      LinhaAjuste[idx].Tooltip(data_ajuste+" Ajuste "+DoubleToString(Ajuste[idx],SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));
     }

   if(mostrar_open==SIM)
     {
      LinhaOpen[idx].Create(ChartID(),"Open"+IntegerToString(idx),0,ptax[idx].open);
      //LinhaOpen[idx].Create(ChartID(),"Open"+IntegerToString(idx),0,hora_in,ptax[idx].open,hora_fin,ptax[idx].open);
      LinhaOpen[idx].Width(width_open);
      LinhaOpen[idx].Style(style_open);
      LinhaOpen[idx].Color(cor_open);
      LinhaOpen[idx].Tooltip(data_ptax+" PTAX Open "+DoubleToString(ptax[idx].open,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));
     }
   if(mostrar_int1==SIM)
     {
      LinhaInt1[idx].Create(ChartID(),"Int1"+IntegerToString(idx),0,ptax[idx].int1);
      //LinhaInt1[idx].Create(ChartID(),"Int1"+IntegerToString(idx),0,hora_in,ptax[idx].int1,hora_fin,ptax[idx].int1);
      LinhaInt1[idx].Width(width_int1);
      LinhaInt1[idx].Style(style_int1);
      LinhaInt1[idx].Color(cor_int1);
      LinhaInt1[idx].Tooltip(data_ptax+" PTAX Intermediário 1 "+DoubleToString(ptax[idx].int1,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));
     }
   if(mostrar_int2==SIM)
     {
      LinhaInt2[idx].Create(ChartID(),"Int2"+IntegerToString(idx),0,ptax[idx].int2);
      //      LinhaInt2[idx].Create(ChartID(),"Int2"+IntegerToString(idx),0,hora_in,ptax[idx].int2,hora_fin,ptax[idx].int2);
      LinhaInt2[idx].Width(width_int2);
      LinhaInt2[idx].Style(style_int2);
      LinhaInt2[idx].Color(cor_int2);
      LinhaInt2[idx].Tooltip(data_ptax+" PTAX Intermediário 2 "+DoubleToString(ptax[idx].int2,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));
     }
   if(mostrar_int3==SIM)
     {
      LinhaInt3[idx].Create(ChartID(),"Int3"+IntegerToString(idx),0,ptax[idx].int3);
      //      LinhaInt3[idx].Create(ChartID(),"Int3"+IntegerToString(idx),0,hora_in,ptax[idx].int3,hora_fin,ptax[idx].int3);
      LinhaInt3[idx].Width(width_int3);
      LinhaInt3[idx].Style(style_int3);
      LinhaInt3[idx].Color(cor_int3);
      LinhaInt3[idx].Tooltip(data_ptax+" PTAX Intermediário 3 "+DoubleToString(ptax[idx].int3,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));
     }
   if(mostrar_close==SIM)
     {
      LinhaClose[idx].Create(ChartID(),"Close"+IntegerToString(idx),0,ptax[idx].close);
      //      LinhaClose[idx].Create(ChartID(),"Close"+IntegerToString(idx),0,hora_in,ptax[idx].close,hora_fin,ptax[idx].close);
      LinhaClose[idx].Width(width_close);
      LinhaClose[idx].Style(style_close);
      LinhaClose[idx].Color(cor_close);
      LinhaClose[idx].Tooltip(data_ptax+" PTAX Close "+DoubleToString(ptax[idx].close,SymbolInfoInteger(Symbol(),SYMBOL_DIGITS)));
     }
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
