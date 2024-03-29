//+------------------------------------------------------------------+
//|                                                       BB_RSI.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 4 
#property indicator_plots   4 
//--- plotar linha superior 
#property indicator_label1  "Upper" 
#property indicator_type1   DRAW_LINE 
#property indicator_color1  clrMediumSeaGreen 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
//--- plotar linha inferior 
#property indicator_label2  "Lower" 
#property indicator_type2   DRAW_LINE 
#property indicator_color2  clrMediumSeaGreen 
#property indicator_style2  STYLE_SOLID 
#property indicator_width2  1 
//--- plotar linha média 
#property indicator_label3  "Middle" 
#property indicator_type3   DRAW_LINE 
#property indicator_color3  clrYellow
#property indicator_style3  STYLE_SOLID 
#property indicator_width3  1 

//--- plotar RSI 
#property indicator_label4  "RSI" 
#property indicator_type4  DRAW_LINE 
#property indicator_color4  clrRed 
#property indicator_style4  STYLE_SOLID 
#property indicator_width4  1 
#property indicator_level1 30
#property indicator_level2 70


//--- input parameters
input int      periodo_rsi=9;
input int      periodo_BB=40;
input int      shift=0;
input double   desvio_BB=2.0;
int BBHandle,RSIHandle;





//--- buffers do indicador 
double         UpperBuffer[]; 
double         LowerBuffer[]; 
double         MiddleBuffer[]; 
double RSIBuffer[];
//+------------------------------------------------------------------+ 
//| Função de inicialização do indicador customizado                 | 
//+------------------------------------------------------------------+ 
int OnInit() 
  { 
//--- atribuição de arrays para buffers do indicador 
   SetIndexBuffer(0,UpperBuffer,INDICATOR_DATA); 
   SetIndexBuffer(1,LowerBuffer,INDICATOR_DATA); 
   SetIndexBuffer(2,MiddleBuffer,INDICATOR_DATA); 
   SetIndexBuffer(3,RSIBuffer,INDICATOR_DATA);
//--- definir o deslocamento de cada linha 
   PlotIndexSetInteger(0,PLOT_SHIFT,shift); 
   PlotIndexSetInteger(1,PLOT_SHIFT,shift);       
   PlotIndexSetInteger(2,PLOT_SHIFT,shift);       
//--- criar manipulador do indicador 
      RSIHandle=iRSI(NULL,0,periodo_rsi,PRICE_CLOSE);
      BBHandle=iBands(NULL,0,periodo_BB,shift,desvio_BB,RSIHandle); 
  
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
  
  int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
//---- get ma buffer
   if(IsStopped()) return(0); //Checking for stop flag
   if(CopyBuffer(BBHandle,1,0,to_copy,UpperBuffer)<=0||CopyBuffer(BBHandle,2,0,to_copy,LowerBuffer)<=0||
   CopyBuffer(BBHandle,0,0,to_copy,MiddleBuffer)<=0||CopyBuffer(RSIHandle,0,0,to_copy,RSIBuffer)<=0)
     {
      Print("Getting data is failed! Error",GetLastError());
      return(0);
     }
//--- preliminary calculations
   //limit=prev_calculated-1;
   //--- the main loop of calculations
   //for(i=limit;i<rates_total && !IsStopped();i++)
    // {
     // BLGBuffer[i]=(close[i]-LowerBuffer[i])/(UpperBuffer[i]-LowerBuffer[i]);
     //}
     
  
  
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
