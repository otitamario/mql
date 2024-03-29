//+------------------------------------------------------------------+
//|                                                   SinalAmaok.mq5 |
//|                                          Junior Cesar 01-12-2017 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Junior Cesar 01-12-2017"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   4
//Media 1
input string MEDIA_1="######MEDIA RAPIDA#####"; 
input int                AMA_PeriodMA1                  =7;          // Adaptive Moving Average(10,...) Period of averaging
input int                AMA_PeriodFast1                =5;           // Adaptive Moving Average(10,...) Period of fast EMA
input int                AMA_PeriodSlow1                =30;          // Adaptive Moving Average(10,...) Period of slow EMA
input int                AMA_Shift1                     =0;           // Adaptive Moving Average(10,...) Time shift
input ENUM_APPLIED_PRICE Applied_Price_MA_1            =PRICE_MEDIAN; // Adaptive Moving Average(10,...) Prices series

//media 2
input string MEDIA_2="######MEDIA LENTA#####"; 
input int                AMA_PeriodMA2                  =10;          // Adaptive Moving Average(10,...) Period of averaging
input int                AMA_PeriodFast2                =6;           // Adaptive Moving Average(10,...) Period of fast EMA
input int                AMA_PeriodSlow2                =70;          // Adaptive Moving Average(10,...) Period of slow EMA
input int                AMA_Shift2                     =0;           // Adaptive Moving Average(10,...) Time shift
input ENUM_APPLIED_PRICE Applied_Price_MA_2            =PRICE_MEDIAN; // Adaptive Moving Average(10,...) Prices series
//Controle da distância do candle da média rápida
input int      distancia=300;
//--- plot Venda
#property indicator_label1  "Venda"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Compra
#property indicator_label2  "Compra"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrMediumBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot AMA1
#property indicator_label3  "AMA1"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot AMA2
#property indicator_label4  "AMA2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrYellow
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters

//--- indicator buffers
double         VendaBuffer[];
double         CompraBuffer[];
double         AMA1Buffer[];
double         AMA2Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,AMA1Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,AMA2Buffer,INDICATOR_DATA);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);
   
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
//---
   CopyBuffer(iAMA(NULL,0,AMA_PeriodMA1,AMA_PeriodFast1,AMA_PeriodSlow1,AMA_Shift1,Applied_Price_MA_1),0,0,rates_total,AMA1Buffer);
   CopyBuffer(iAMA(NULL,0,AMA_PeriodMA1,AMA_PeriodFast2,AMA_PeriodSlow2,AMA_Shift2,Applied_Price_MA_2),0,0,rates_total,AMA2Buffer);
   
   //Escrever condição e lógica para o indicador 
   for(int i=3; i<rates_total; i++)
   {
      if(
      (AMA1Buffer[i-1]>AMA2Buffer[i-1]
          && low[i-1]>AMA1Buffer[i-1] && low[i]<AMA1Buffer[i]) 
          || (AMA1Buffer[i-1]<AMA2Buffer[i-1] 
          && AMA1Buffer[i]>AMA2Buffer[i]))
          
         {
         CompraBuffer[i]=low[i];
         }
       else
         {
          CompraBuffer[i]=0;
         }
         // Condição para Venda original 
         
   if(
       (AMA1Buffer[i-1]>AMA2Buffer[i-1] && AMA1Buffer[i]<AMA2Buffer[i])
       || (close[i-1]-AMA1Buffer[i-1]>distancia && high[i-3]<high[i-2] && high[i-2]>high[1]
       && low[i-3]>low[i-2] && high[i-3]>high[i] )
       || (high[i-3]<AMA1Buffer[i-3] && high[i-2]<AMA1Buffer[i-2] 
       && high[i-1]<AMA1Buffer[i-1] && high[i]>AMA1Buffer[i] && AMA1Buffer[i-1]<AMA2Buffer[i-1])
      
      
      
      )
         {
         VendaBuffer[i]=high[i]+20;
         }
       else
         {
          VendaBuffer[i]=0;
         }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//VendaBuffer[i]=AMA2Buffer[i]>AMA1Buffer[i] high[i] : 0;
// Uma possibilidade com o duningan if(AMA1Buffer[i-1]>AMA2Buffer[i-1] && low[i-1]<AMA1Buffer[i-1] && high[i]<high[i-1])