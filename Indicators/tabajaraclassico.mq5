//+------------------------------------------------------------------+
//|                                                    tabajara2.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Patrick Corrêa Muniz"
#property version   "1.01"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   2
//--- plot media
#property indicator_label1  "media"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrRed,clrForestGreen,clrYellow,C'0,0,0',C'0,0,0',C'0,0,0',C'0,0,0',C'0,0,0'
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- plot candles
#property indicator_label2  "candles"
#property indicator_type2   DRAW_COLOR_CANDLES
#property indicator_color2  clrRed,clrForestGreen,clrBlack,clrGray,C'0,0,0',C'0,0,0',C'0,0,0',C'0,0,0'
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- indicator buffers
double         mediaBuffer[];
double         mediaColors[];
double         candlesOpenBuffer[];
double         candlesHighBuffer[];
double         candlesLowBuffer[];
double         candlesCloseBuffer[];
double         candlesColors[];
double         mediavalue[];
int            mediaHandle;
input int      PeriodoMedia=20;
input ENUM_MA_METHOD      TipoMedia=MODE_SMA;
//+------------------------------------------------------------------+
//|                      |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,mediaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,mediaColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,candlesOpenBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,candlesHighBuffer,INDICATOR_DATA);
   SetIndexBuffer(4,candlesLowBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,candlesCloseBuffer,INDICATOR_DATA);
   SetIndexBuffer(6,candlesColors,INDICATOR_COLOR_INDEX);
   mediaHandle=iMA(_Symbol,_Period,PeriodoMedia,0,TipoMedia,PRICE_CLOSE);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                               |
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
   int start;
   if(prev_calculated==0)
     {
      start=1;
        }else{
      start=prev_calculated-1;
     }

   CopyBuffer(mediaHandle,0,0,rates_total,mediaBuffer);
   CopyBuffer(mediaHandle,0,0,rates_total,mediavalue);
   for(int i=start; i<rates_total; i++)
     {
      DefineColorMedia(mediavalue,i,close);
      DefineColorCandle(mediavalue,i,close,open,high,low);
     }
   return(rates_total);

  }
//+------------------------------------------------------------------+
//|Colors
//| 0 = Red
//| 1 = Green
//| 2 = yellow                                                                  |
//+------------------------------------------------------------------+
void DefineColorMedia(double &mediavalue[],int index,const double &close[])
  {
   bool fechamentoMaiorQueMediaeMediaAscendente=(close[index]>mediavalue[index] && mediavalue[index]>mediavalue[index-1]);
   bool fechamentoMenorQueMediaeMediaDescendente=(close[index]<mediavalue[index] && mediavalue[index]<mediavalue[index-1]);
   if(fechamentoMaiorQueMediaeMediaAscendente)
     {
      mediaColors[index]=1;
        }else if(fechamentoMenorQueMediaeMediaDescendente) {
      mediaColors[index]=0;
        }else{
      mediaColors[index]=2;
     }
  }
//+------------------------------------------------------------------+
//|Colors
//|0 = Red
//|1 = Green
//|2 = Black
//|3 = Gray                                                                 |
//+------------------------------------------------------------------+
void DefineColorCandle(double &mediavalue[],int index,const double &close[],const double &open[],const double &high[],const double &low[])
  {
   DefineBuffersCandle(index,close,open,high,low);
   bool candleDeForcaMediaAscendente=close[index]>close[index-1] && close[index]>mediavalue[index] && mediavalue[index]>mediavalue[index-1];
   bool candleDeCorrecaoMediaAscendente=close[index]<close[index-1] && close[index]>mediavalue[index] && mediavalue[index]>mediavalue[index-1];
   bool candleDeForcaMediaDescendente=close[index]<close[index-1] && close[index]<mediavalue[index] && mediavalue[index]<mediavalue[index-1];
   bool candleDeCorrecaoMediaDescendente=close[index]>close[index-1] && close[index]<mediavalue[index] && mediavalue[index]<mediavalue[index-1];
   if(candleDeForcaMediaAscendente)
     {
      candlesColors[index]=1;
        }else if(candleDeCorrecaoMediaAscendente){
      candlesColors[index]=2;
        }else if(candleDeForcaMediaDescendente){
      candlesColors[index]=0;
        }else if(candleDeCorrecaoMediaDescendente){
      candlesColors[index]=3;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DefineBuffersCandle(int index,const double &close[],const double &open[],const double &high[],const double &low[])
  {
   candlesOpenBuffer[index] = open[index];
   candlesHighBuffer[index] = high[index];
   candlesLowBuffer[index]=low[index];
   candlesCloseBuffer[index]=close[index];
  }
//+------------------------------------------------------------------+
