//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   2

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



input double BandsDeviations=2;//Deviations
input int HalfLength=100;//Minimum Bar Redraw

double         VendaBuffer[];
double         CompraBuffer[];
int cap_handle;
double cap_compra[],cap_venda[];
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,cap_venda,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,cap_compra,INDICATOR_CALCULATIONS);

   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);

   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);

   cap_handle=iCustom(Symbol(),_Period,"Market\\CAP Channel Trading MT5"," ",BandsDeviations,HalfLength,true,true,clrPurple,clrMagenta," "," ",
                      false,false,false,false,"alert2.wav","email.wav");
   ChartIndicatorAdd(ChartID(),0,cap_handle);
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(cap_handle);
   ChartIndicatorDelete(ChartID(),0,"CAPChannelTrading");

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
   CopyBuffer(cap_handle,13,0,to_copy,cap_compra);
   CopyBuffer(cap_handle,14,0,to_copy,cap_venda);

   for(int i=MathMax(2,prev_calculated-1); i<rates_total;i++)
     {
      VendaBuffer[i]=cap_venda[i];
      CompraBuffer[i]=cap_compra[i];
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
