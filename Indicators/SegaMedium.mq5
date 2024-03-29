//+------------------------------------------------------------------+
//|                                                    MeanPrice.mq5 |
//|                                                       chizhijing |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#resource "\\Indicators\\Amplitude.ex5"

#property copyright "Mario"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property  indicator_buffers 2
#property  indicator_plots 1

#property   indicator_label1 "Preço Médio"
#property   indicator_color1 clrYellow
#property   indicator_type1   DRAW_LINE

input int InpMAPeriod=10; // Período Amplitude

double mean_price[];
double Ampl[];
int ampl_handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   int min_rates_total=InpMAPeriod;

//--- indicator buffers mapping
   SetIndexBuffer(0,mean_price,INDICATOR_DATA);
   SetIndexBuffer(1,Ampl,INDICATOR_CALCULATIONS);

   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total+1);


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
   int i,limit;
//--- check for rates
//--- preliminary calculations
   if(rates_total<InpMAPeriod+1)return(0);
//---
   if(rates_total<prev_calculated || prev_calculated<=0)
     {
      limit=InpMAPeriod;
     }
   else
      limit=rates_total-prev_calculated;
//--- get MA
//--- main cycle
//--- the main loop of calculations

double preco=iHigh(NULL,PERIOD_D1,0)+iLow(NULL,PERIOD_D1,0);
  for(i=limit;i<rates_total && !IsStopped();i++)

     {


/* ampl_handle=iCustom(Symbol(),PERIOD_D1,"::Indicators\\Amplitude.ex5",InpMAPeriod);

      if(CopyBuffer(ampl_handle,0,1,1,Ampl)<=0)
        {
         Print("Erro copiar Indicador Amplitude: ",GetLastError());
         return(0);
        }
      */
      // range=MultRange*Amplit[0];

      mean_price[i]=0.5*(preco);

     }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
  }
//+------------------------------------------------------------------+
