//+------------------------------------------------------------------+
//|                                                     DHMA.mq5     |
//|                                                  Junio Cesar     |
//|                                              http://jcfilmes.com |
//+------------------------------------------------------------------+
#property copyright "Junio Cesar"
#property link      "http://jcfilmes.com"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 6  
#property indicator_plots   4  

#property indicator_label1  "Venda"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Compra"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- plot HMA
#property indicator_label3  "HMA"
#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrRed,clrBlue
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2


//--- plot AMA
#property indicator_label4  "AMA"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1


//--- input parameters
input int PeriodoRSI=9; // Periodo do RSI
input int HMA_Period=14;  // HMA periodo 23



int HMA_Shift=0;    // HMA Horizontal shift
double         VendaBuffer[];
double         CompraBuffer[];
int hma_handle;
int rsi_handle;
int AMAHandle;
double hma_buffer[],hma_colors[],IFRBuffer[];
double         AMABuffer[];


//Media 1
input string MEDIA_1="######MEDIA RAPIDA#####"; 
input int                AMA_PeriodMA1                  =7;          // Adaptive Moving Average(10,...) Period of averaging
input int                AMA_PeriodFast1                =5;           // Adaptive Moving Average(10,...) Period of fast EMA
input int                AMA_PeriodSlow1                =30;          // Adaptive Moving Average(10,...) Period of slow EMA
input int                AMA_Shift1                     =0;           // Adaptive Moving Average(10,...) Time shift
input ENUM_APPLIED_PRICE Applied_Price_MA_1            =PRICE_MEDIAN; // Adaptive Moving Average(10,...) Prices series


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,hma_buffer,INDICATOR_DATA);
   SetIndexBuffer(3,hma_colors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,AMABuffer,INDICATOR_DATA);
   SetIndexBuffer(5,IFRBuffer,INDICATOR_CALCULATIONS);


   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);

   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);
   
   hma_handle=iCustom(Symbol(),_Period,"hma",HMA_Period,HMA_Shift);
   rsi_handle=iRSI(Symbol(),_Period,PeriodoRSI,PRICE_CLOSE);
   AMAHandle=iAMA(NULL,0,AMA_PeriodMA1,AMA_PeriodFast1,AMA_PeriodSlow1,AMA_Shift1,Applied_Price_MA_1);


   return(INIT_SUCCEEDED);
  }
   void OnDeinit(const int reason)
{
IndicatorRelease(hma_handle);
IndicatorRelease(rsi_handle);
IndicatorRelease(AMAHandle);

}
//+------------------------------------------------------------------+
//|                                                                  |
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
  
  int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
   CopyBuffer(hma_handle,0,0,to_copy,hma_buffer);
   CopyBuffer (rsi_handle,0,0,to_copy,IFRBuffer);
      CopyBuffer(AMAHandle,0,0,to_copy,AMABuffer);

   
  
   for(int i=MathMax(4,prev_calculated-1); i<rates_total;i++)
     {
     
      if (hma_buffer[i]< hma_buffer[i-1]) hma_colors[i]=0;
      else hma_colors[i]=1;
      if( IFRBuffer[i-2]>65 && IFRBuffer[i]<65  && high[i-2]>high[i]  )// hma_buffer[i-1]>hma_buffer[i]
        {
         VendaBuffer[i]=high[i];
        }
      else
        {
         VendaBuffer[i]=0;
        }

      if(  IFRBuffer[i-2]<32 && IFRBuffer[i]>32 && low[i-2]<low[i] )//&& hma_buffer[i-1]<hma_buffer[i]
        {
         CompraBuffer[i]=low[i];
        }
      else
        {
         CompraBuffer[i]=0;
        }
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
