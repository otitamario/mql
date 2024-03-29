//+------------------------------------------------------------------+
//|                                                       BB_RSI.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 5 
#property indicator_plots   1 
//--- plotar linha superior 
#property indicator_label1  "BB_OBV_percent" 
#property indicator_type1   DRAW_LINE 
#property indicator_color1  clrRed 
#property indicator_style1  STYLE_SOLID 
#property indicator_width1  1 
#property indicator_level1 0.0
#property indicator_level2 0.5
#property indicator_level3 1.0


//--- input parameters
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; // Volumes
input int      periodo_BB=40;
input int      shift=0;
input double   desvio_BB=2.0;
int BBHandle,OBVHandle,limit;





//--- buffers do indicador 
double UpperBuffer[],LowerBuffer[],MiddleBuffer[],OBVBuffer[],BLGBuffer[];

//+------------------------------------------------------------------+ 
//| Função de inicialização do indicador customizado                 | 
//+------------------------------------------------------------------+ 
int OnInit() 
  { 
//--- atribuição de arrays para buffers do indicador 
   SetIndexBuffer(0,BLGBuffer,INDICATOR_DATA); 
   SetIndexBuffer(1,UpperBuffer,INDICATOR_CALCULATIONS); 
   SetIndexBuffer(2,LowerBuffer,INDICATOR_CALCULATIONS); 
   SetIndexBuffer(3,MiddleBuffer,INDICATOR_CALCULATIONS); 
   SetIndexBuffer(4,OBVBuffer,INDICATOR_CALCULATIONS);
   IndicatorSetInteger(INDICATOR_DIGITS,2); 

//--- criar manipulador do indicador 
      OBVHandle=iOBV(NULL,0,InpVolumeType);
      BBHandle=iBands(NULL,0,periodo_BB,shift,desvio_BB,OBVHandle); 
  
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
//ArraySetAsSeries(UpperBuffer,true);
//ArraySetAsSeries(LowerBuffer,true);
//ArraySetAsSeries(MiddleBuffer,true);
//ArraySetAsSeries(OBVBuffer,true);
//ArraySetAsSeries(BLGBuffer,true);

   
   int calculated=BarsCalculated(BBHandle);
   if(calculated<rates_total)
     {
      Print("Not all data of BB is calculated (",calculated,"bars ). Error",GetLastError());
      return(0);
     }

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
   CopyBuffer(BBHandle,0,0,to_copy,MiddleBuffer)<=0||CopyBuffer(OBVHandle,0,0,to_copy,OBVBuffer)<=0)
     {
      Print("Getting data is failed! Error",GetLastError());
      return(0);
     }
  
//--- the main loop of calculations
if (prev_calculated<=0) limit=rates_total-BarsCalculated(BBHandle);
else limit=prev_calculated-1;

     for(int i=rates_total; i>limit; i--)

       {
      BLGBuffer[i]=(OBVBuffer[i]-LowerBuffer[i])/(UpperBuffer[i]-LowerBuffer[i]);
     }
     
   return(rates_total);
  }

//+------------------------------------------------------------------+
