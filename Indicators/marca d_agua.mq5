//+------------------------------------------------------------------+
//|                                                 marca d'água.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                     MARCA D'AGUA |
//|                                                      Marcus Mota |
//+------------------------------------------------------------------+
#property copyright "Marcus Mota"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
#property strict

//--- inputs
input string   inputFonte="Tahoma";    //Fonte
input ushort   inputTamanho=100;       //Tamanho
input color    inputCor=clrGray;       //Cor
input double   inputAlpha=0.2;         //Transparência

//--- variáveis
long Altura,Comprimento;
//+------------------------------------------------------------------+
//| Inicialização                                                    |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- possíveis erros
   if(inputTamanho<=0
      || inputAlpha<0
      || inputAlpha>1)
     {
      printf("Erro nos parâmetros de entrada!");
      return INIT_FAILED;
     }

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Deletar a marca d'água                                           |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0,"Marca D'Água");
  }
//+------------------------------------------------------------------+
//| Criação da marca d'água                                          |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//--- dimensões do gráfico
   Altura=ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS,0);
   Comprimento=ChartGetInteger(0,CHART_WIDTH_IN_PIXELS,0);

//--- criação da marca d'água
   ObjectCreate(0,"Marca D'Água",OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,"Marca D'Água",OBJPROP_COLOR,0,CorDaMarcaDAgua());
   ObjectSetInteger(0,"Marca D'Água",OBJPROP_FONTSIZE,inputTamanho);
   ObjectSetString(0,"Marca D'Água",OBJPROP_FONT,inputFonte);
   ObjectSetInteger(0,"Marca D'Água",OBJPROP_BACK,true);
   ObjectSetString(0,"Marca D'Água",OBJPROP_TEXT,Symbol()+", "+Periodo());
   ObjectSetInteger(0,"Marca D'Água",OBJPROP_ANCHOR,ANCHOR_CENTER);
   ObjectSetInteger(0,"Marca D'Água",OBJPROP_XDISTANCE,(Comprimento/2));
   ObjectSetInteger(0,"Marca D'Água",OBJPROP_YDISTANCE,(Altura/2));

   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Cor da marca d'água, com cálculo da transparência                |
//+------------------------------------------------------------------+
color CorDaMarcaDAgua()
  {
//--- processo de transparência 
   color ChartBackColorGet=(color)ChartGetInteger(0,CHART_COLOR_BACKGROUND,0);
   uchar blueBack=(uchar)MathFloor(ChartBackColorGet/65536);
   uchar greenBack=(uchar)MathFloor((ChartBackColorGet-(blueBack*65536))/256);
   uchar redBack=(uchar)(ChartBackColorGet -(blueBack*65536) -(greenBack*256));
   uchar blueObject=(uchar)MathFloor(inputCor/65536);
   uchar greenObject=(uchar)MathFloor((inputCor-(blueObject*65536))/256);
   uchar redObject=(uchar)(inputCor -(blueObject*65536) -(greenObject*256));

   uchar redAlpha=(uchar)(redBack*(1-inputAlpha)+redObject*inputAlpha);
   uchar greenAlpha=(uchar)(greenBack*(1-inputAlpha)+greenObject*inputAlpha);
   uchar blueAlpha = (uchar)(blueBack*(1 - inputAlpha) + blueObject*inputAlpha);
   string ClrAlpha = (string)redAlpha+", "+(string)greenAlpha+", "+(string)blueAlpha;

   return (color)ClrAlpha;
  }
//+------------------------------------------------------------------+
//| Período na marca d'água                                          |
//+------------------------------------------------------------------+
string Periodo()
  {
   string Periodo;
   int timeframe=Period();
   switch(timeframe)
     {
      case PERIOD_M1  : Periodo="M1";   break;
      case PERIOD_M2  : Periodo="M2";   break;
      case PERIOD_M3  : Periodo="M3";   break;
      case PERIOD_M4  : Periodo="M4";   break;
      case PERIOD_M5  : Periodo="M5";   break;
      case PERIOD_M6  : Periodo="M6";   break;
      case PERIOD_M10 : Periodo="M10";  break;
      case PERIOD_M12 : Periodo="M12";  break;
      case PERIOD_M15 : Periodo="M15";  break;
      case PERIOD_M20 : Periodo="M20";  break;
      case PERIOD_M30 : Periodo="M30";  break;
      case PERIOD_H1  : Periodo="H1";   break;
      case PERIOD_H2  : Periodo="H2";   break;
      case PERIOD_H3  : Periodo="H3";   break;
      case PERIOD_H4  : Periodo="H4";   break;
      case PERIOD_H6  : Periodo="H6";   break;
      case PERIOD_H8  : Periodo="H8";   break;
      case PERIOD_H12 : Periodo="H12";  break;
      case PERIOD_D1  : Periodo="D1";   break;
      case PERIOD_W1  : Periodo="W1";   break;
      case PERIOD_MN1 : Periodo="MN1";  break;
     }

   return(Periodo);
  }
//+------------------------------------------------------------------+
 
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   
  }
//+------------------------------------------------------------------+
