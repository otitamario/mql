//+------------------------------------------------------------------+
//|                                                     DHMA.mq5     |
//|                                                  Junio Cesar     |
//|                                              http://jcfilmes.com |
//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 5   //4
#property indicator_plots   2   //3

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




//--- input parameters
input int LRMAPeriod=14; // Period LRMA
input int HMA_Period=13;  // HMA period 


double         VendaBuffer[];
double         CompraBuffer[];
int HMA_Shift=0;    // HMA Horizontal shift
int hma_handle;
int lrma_handle;
double hma_buffer[],LRMABuffer[],LRMA_Color[];




//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,hma_buffer,INDICATOR_DATA);
   SetIndexBuffer(3,LRMABuffer,INDICATOR_DATA);
   SetIndexBuffer(4,LRMA_Color,INDICATOR_CALCULATIONS);
   

   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);

   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);
   
   hma_handle=iCustom(Symbol(),_Period,"colorhma",HMA_Period,HMA_Shift);
   lrma_handle=iCustom(Symbol(),_Period,"LRMA_Color",LRMAPeriod);
   ChartIndicatorAdd(ChartID(),0,hma_handle);
   ChartIndicatorAdd(ChartID(),0,lrma_handle);
   return(INIT_SUCCEEDED);
  }
   void OnDeinit(const int reason)
{
IndicatorRelease(hma_handle);
IndicatorRelease(lrma_handle);
//-

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
   CopyBuffer(hma_handle,1,0,to_copy,hma_buffer);
   CopyBuffer (lrma_handle,0,0,to_copy,LRMABuffer);
      CopyBuffer (lrma_handle,1,0,to_copy,LRMA_Color);   
  
   for(int i=MathMax(1,prev_calculated-1); i<rates_total;i++)
     {
     
      if( hma_buffer[i]==2 && LRMA_Color[i]==2 )

      {
         VendaBuffer[i]=high[i];
        }
      else
        {
         VendaBuffer[i]=0;
        }

      if(  hma_buffer[i]==1 && LRMA_Color[i]==1 )

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
