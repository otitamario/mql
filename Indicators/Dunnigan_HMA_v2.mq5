//+------------------------------------------------------------------+
//|                                                     Dunnigan.mq5 |
//|                                                  Henrique Vilela |
//|                                               http://vilela.one/ |
//+------------------------------------------------------------------+
#property copyright "Henrique Vilela"
#property link      "http://vilela.one/"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   3

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


input int HMA_Period=13;  // HMA period
input int HMA_Shift=0;    // HMA Horizontal shift


double         VendaBuffer[];
double         CompraBuffer[];
int hma_handle;
double hma_buffer[],hma_colors[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,hma_buffer,INDICATOR_DATA);
   SetIndexBuffer(3,hma_colors,INDICATOR_COLOR_INDEX);


   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);

   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);
   
   hma_handle=iCustom(Symbol(),_Period,"hma",HMA_Period,HMA_Shift);

   return(INIT_SUCCEEDED);
  }
   void OnDeinit(const int reason)
{
IndicatorRelease(hma_handle);
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
   
  
   for(int i=MathMax(2,prev_calculated-1); i<rates_total;i++)
     {
     
      if (hma_buffer[i]< hma_buffer[i-1]) hma_colors[i]=0;
      else hma_colors[i]=1;
      if((low[i]<low[i-1] && high[i]<high[i-1])&&(low[i-1]>=low[i-2] || high[i-1]>=high[i-2])&& hma_buffer[i]< hma_buffer[i-1])
        {
         VendaBuffer[i]=high[i];
        }
      else
        {
         VendaBuffer[i]=0;
        }

      if((low[i]>low[i-1] && high[i]>high[i-1])&& (low[i-1]<=low[i-2] || high[i-1]<=high[i-2])&& hma_buffer[i]> hma_buffer[i-1])
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
