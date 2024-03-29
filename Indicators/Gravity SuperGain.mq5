
//+------------------------------------------------------------------+
//|                                               Gravity SuperGain.mq5 |
//|                        SG - SuperGain. |
//|                                                 Ricardo |
//+------------------------------------------------------------------+
#property copyright "Indicador modifidado do site mql5."
#property link      "https://mql5.com"
#property version   "1.00"
#property description "VolumedeExaustao"
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2
//--- plot UP
#property indicator_label1  "Venda"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrViolet
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot DN
#property indicator_label2  "Compra"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrAqua
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_type3   DRAW_NONE
//#property indicator_type4   DRAW_NONE

//--- input parameters
input ushort     InpPeriod   =  20;   // Período Volume
input ushort     PeriodoMedia   =  250;   // Período Media
input ushort      Afastamento = 600; //Afastamento mínimo


ENUM_MA_METHOD    SuavizacaoMedia=MODE_SMA; // Suavizacão da média:
ENUM_APPLIED_PRICE TipoPreco=PRICE_CLOSE;// Escolha o tipo de cálculo:
int ManipuladorMedia;
string MeuSimbolo = _Symbol; // Guardando O Papel do gráfico para não consultar diversas vezes
ENUM_TIMEFRAMES MeuTimeFrame = PERIOD_CURRENT; // Guardando o período para não consultar diversas 



double         VendaBuffer[]; // Seta (Sinal) de Venda
double         CompraBuffer[]; // Seta (Sinal) de Compra
double         MediaBuffer[]; // Media Multiframe


//--- indicator buffers
//double         BufferUP[];
//double         BufferDN[];
//--- global variables
int            period;
ushort maiorPeriodo=MathMax(InpPeriod, PeriodoMedia);

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- set global variables

   period=int(InpPeriod<1 ? 1 : InpPeriod);
//--- indicator buffers mapping
   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,MediaBuffer,INDICATOR_CALCULATIONS);
   
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
PlotIndexSetInteger(0,PLOT_ARROW,234);
PlotIndexSetInteger(1,PLOT_ARROW,233);

PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);

ManipuladorMedia=iMA(MeuSimbolo,MeuTimeFrame,PeriodoMedia,0,SuavizacaoMedia,TipoPreco);
   
   
   
//--- setting indicator parameters
   IndicatorSetString(INDICATOR_SHORTNAME,"Gravity Reversal("+(string)period+")");
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
//--- setting buffer arrays as timeseries
   ArraySetAsSeries(CompraBuffer,true);
   ArraySetAsSeries(VendaBuffer,true);
   ArraySetAsSeries(MediaBuffer,true);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//--- Проверка на минимальное колиество баров для расчёта
   if(rates_total<maiorPeriodo) return 0;
//--- Установка массивов буферов как таймсерий
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(open,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
//--- Проверка и расчёт количества просчитываемых баров
   int limit=rates_total-prev_calculated;
   if(limit>1)
     {
      limit=rates_total-maiorPeriodo-1;
      ArrayInitialize(CompraBuffer,EMPTY_VALUE);
      ArrayInitialize(VendaBuffer,EMPTY_VALUE);
      CopyBuffer(ManipuladorMedia,0,0,limit,MediaBuffer);
      //ArrayInitialize(MediaBuffer,EMPTY_VALUE);
      
     }
//--- Расчёт индикатора
   for(int i=limit; i>=0 && !IsStopped(); i--)
     {
      //int min=VolLowest(period,i);
      int max=VolHighest(period,i);
      VendaBuffer[i]=((i==max && close[i]-Afastamento>MediaBuffer[i] && close[i]>=open[i]) ? high[i] : EMPTY_VALUE);
      CompraBuffer[i]=((i==max && close[i]+Afastamento<MediaBuffer[i] && close[i]<=open[i]) ? low[i] : EMPTY_VALUE);
     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|  tick_volume   |
//+------------------------------------------------------------------+
int VolHighest(const int count,const int start)
  {
   long array[];
   ArraySetAsSeries(array,true);
   if(CopyTickVolume(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMaximum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+
//| tick_volume    |
//+------------------------------------------------------------------+
int VolLowest(const int count,const int start)
  {
   long array[];
   ArraySetAsSeries(array,true);
   if(CopyTickVolume(Symbol(),PERIOD_CURRENT,start,count,array)==count)
      return ArrayMinimum(array)+start;
   return WRONG_VALUE;
  }
//+------------------------------------------------------------------+