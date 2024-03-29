//+------------------------------------------------------------------+
//|                                                       BB_RSI.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 11 
#property indicator_plots   2 
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


//--- input parameters
input int      periodo_rsi=9;
input int      periodo_BB=40;
input int      shift=0;
input double   desvio_BB=2.0;
input int  periodo_ADX=14;
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; // Volumes

int BBHandle,RSIHandle,ADXHandle,OBVHandle,BBOBVHandle,limit;





//--- buffers do indicador 
double VendaBuffer[],CompraBuffer[],UpperBuffer[],LowerBuffer[],MiddleBuffer[],RSIBuffer[],ADXBuffer[],OBVBuffer[];
double UpperOBVBuffer[],LowerOBVBuffer[],MiddleOBVBuffer[];
//+------------------------------------------------------------------+ 
//| Função de inicialização do indicador customizado                 | 
//+------------------------------------------------------------------+ 
int OnInit() 
  { 
//--- atribuição de arrays para buffers do indicador
   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,UpperBuffer,INDICATOR_CALCULATIONS); 
   SetIndexBuffer(3,LowerBuffer,INDICATOR_CALCULATIONS); 
   SetIndexBuffer(4,MiddleBuffer,INDICATOR_CALCULATIONS); 
   SetIndexBuffer(5,RSIBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,ADXBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,OBVBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,UpperOBVBuffer,INDICATOR_CALCULATIONS); 
   SetIndexBuffer(9,LowerOBVBuffer,INDICATOR_CALCULATIONS); 
   SetIndexBuffer(10,MiddleOBVBuffer,INDICATOR_CALCULATIONS); 

   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);
   
   
//--- criar manipulador do indicador 
      RSIHandle=iRSI(NULL,0,periodo_rsi,PRICE_CLOSE);
      BBHandle=iBands(NULL,0,periodo_BB,shift,desvio_BB,RSIHandle);
      ADXHandle=iCustom(NULL,0,"DifADX",periodo_ADX); 
      OBVHandle=iOBV(NULL,0,InpVolumeType);
      BBOBVHandle=iBands(NULL,0,periodo_BB,shift,desvio_BB,OBVHandle);


  
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
if (prev_calculated<=0)
{
ArrayInitialize(VendaBuffer,0.0);
ArrayInitialize(CompraBuffer,0.0);
}
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
   CopyBuffer(BBHandle,0,0,to_copy,MiddleBuffer)<=0||CopyBuffer(RSIHandle,0,0,to_copy,RSIBuffer)<=0||
   CopyBuffer(ADXHandle,0,0,to_copy,ADXBuffer)<=0||CopyBuffer(OBVHandle,0,0,to_copy,OBVBuffer)<=0||
   CopyBuffer(BBOBVHandle,1,0,to_copy,UpperOBVBuffer)<=0||CopyBuffer(BBOBVHandle,2,0,to_copy,LowerOBVBuffer)<=0||
   CopyBuffer(BBOBVHandle,0,0,to_copy,MiddleOBVBuffer)<=0)
     {
      Print("Getting data is failed! Error",GetLastError());
      return(0);
     }
  
//--- the main loop of calculations
//if (prev_calculated<=0) limit=rates_total-BarsCalculated(BBHandle);
//else limit=rates_total;

     for(int i=MathMax(1,prev_calculated-1); i<rates_total; i++)

       {
       //BLGBuffer[i]=(RSIBuffer[i]-LowerBuffer[i])/(UpperBuffer[i]-LowerBuffer[i]);
       //if(RSIBuffer[i-1]<MiddleBuffer[i-1]&&RSIBuffer[i]>MiddleBuffer[i])CompraBuffer[i]=low[i];
       //if(RSIBuffer[i-1]>MiddleBuffer[i-1]&&RSIBuffer[i]<MiddleBuffer[i])VendaBuffer[i]=high[i];
       //if(RSIBuffer[i-1]<LowerBuffer[i-1]&&RSIBuffer[i]>LowerBuffer[i])CompraBuffer[i]=low[i];
       //if(RSIBuffer[i-1]>UpperBuffer[i-1]&&RSIBuffer[i]<UpperBuffer[i])VendaBuffer[i]=high[i];
       //Compra
       if(RSIBuffer[i-1]<MiddleBuffer[i-1]&&RSIBuffer[i]>MiddleBuffer[i]&& ADXBuffer[i-1]<ADXBuffer[i])CompraBuffer[i]=low[i];
       if(RSIBuffer[i-1]<LowerBuffer[i-1]&&RSIBuffer[i]>LowerBuffer[i]&& ADXBuffer[i-1]<ADXBuffer[i])CompraBuffer[i]=low[i];
       if (ADXBuffer[i-1]<0 &&ADXBuffer[i]>0)CompraBuffer[i]=low[i];
       if(OBVBuffer[i-1]<MiddleOBVBuffer[i-1]&&OBVBuffer[i]>MiddleOBVBuffer[i])CompraBuffer[i]=low[i];
       //Venda
       if(RSIBuffer[i-1]>MiddleBuffer[i-1]&&RSIBuffer[i]<MiddleBuffer[i]&&ADXBuffer[i-1]>ADXBuffer[i])VendaBuffer[i]=high[i];
       if(RSIBuffer[i-1]>UpperBuffer[i-1]&&RSIBuffer[i]<UpperBuffer[i]&&ADXBuffer[i-1]>ADXBuffer[i])VendaBuffer[i]=high[i];
       if (ADXBuffer[i-1]>0 &&ADXBuffer[i]<0)VendaBuffer[i]=high[i];
       if(OBVBuffer[i-1]>MiddleOBVBuffer[i-1]&&OBVBuffer[i]<MiddleOBVBuffer[i])VendaBuffer[i]=low[i];


     
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
