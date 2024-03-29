//+------------------------------------------------------------------+
//|                                               Barra Elefante.mq5 |
//|                                                  Henrique Vilela |
//|                                               http://vilela.one/ |
//+------------------------------------------------------------------+
#property copyright "Henrique Vilela"
#property link      "http://vilela.one/"
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

input int rsi_sobrevenda=30;//Nível RSI Sobrevendido
input int rsi_sobrecompra=60;//Nível RSI Sobrecomprado
input double laguerre_venda=0.15;//Nivel Laguerre Venda
input double laguerre_compra=0.8;//Nivel Laguerre Compra
input int rsi_period=9;//Periodo RSI
//+-----------------------------------+
//|  LAGUERRE INPUT PARAMETERS       |
//+-----------------------------------+
input double gamma=0.618;                          //smoothing ratio
input ENUM_APPLIED_VOLUME VolumeType=VOLUME_TICK;  //volume
input int Shift=0;                                 //horizontal shift of the indicator in bars
input double inHighLevel=0.75;
input double inMiddleLevel=0.50;
input double inLowLevel=0.25;



int h_rsi,h_laguerre;
double         VendaBuffer[];
double         CompraBuffer[];
double rsi_buffer[],laguerre_buffer[];
int sinal;
int min_rates_total;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,rsi_buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,laguerre_buffer,INDICATOR_CALCULATIONS);

   
   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);

   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);
   
   
   
    PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE); 
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

   min_rates_total=2;

   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,MathMax(rsi_period,min_rates_total));
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,MathMax(rsi_period,min_rates_total));

   
   h_rsi=iRSI(Symbol(),Period(),rsi_period,PRICE_CLOSE);
   h_laguerre=iCustom(Symbol(),Period(),"laguerrevolume",gamma,VolumeType,Shift,inHighLevel,inMiddleLevel,inLowLevel);
   
  ChartIndicatorAdd(ChartID(),1,h_laguerre);
 
  ChartIndicatorAdd(ChartID(),2,h_rsi);
 
   
   return(INIT_SUCCEEDED);
  }
  
  
  void OnDeinit(const int reason)
  {
   IndicatorRelease(h_rsi);
   IndicatorRelease(h_laguerre);
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
  
  int first;
    int to_copy;
     to_copy=rates_total-prev_calculated+(prev_calculated<=0 ? 0 : 1);

     CopyBuffer(h_rsi,0,0,to_copy,rsi_buffer);
     CopyBuffer(h_laguerre,0,0,to_copy,laguerre_buffer);
 
     
//--- the main loop of calculations
 if(prev_calculated==0) // check for the first start of the indicator
 {
 first=MathMax(rsi_period,min_rates_total); // start index for all the bars// min_rates_total é o minimo de barras do laguerre=2
 ArrayInitialize(CompraBuffer,EMPTY_VALUE);   // divergence buffers must be initialized
 ArrayInitialize(VendaBuffer,EMPTY_VALUE);
  
 }
 else first=prev_calculated-1;
  // start index for the new bars

   for(int i = first; i < rates_total-1; i++)
 
   {
   
   //Compra
       if(
       rsi_buffer[i-1]<rsi_sobrevenda && rsi_buffer[i]>rsi_sobrevenda && laguerre_buffer[i]>laguerre_compra
       ||(rsi_buffer[i-1]<rsi_sobrevenda && rsi_buffer[i]>rsi_sobrevenda && laguerre_buffer[i]<0.12 )
       )
      {
     
      CompraBuffer[i]=low[i];
      }
      else
      {
      CompraBuffer[i]=EMPTY_VALUE;
      }
      
      //Venda
    if(rsi_buffer[i-1]>rsi_sobrecompra && rsi_buffer[i]<rsi_sobrecompra && laguerre_buffer[i]<laguerre_venda
    ||(rsi_buffer[i-1]>rsi_sobrecompra && rsi_buffer[i]<rsi_sobrecompra && laguerre_buffer[i]<0.80 )
    )
      {
      VendaBuffer[i]=high[i];
      }
   else 
  {
   
   VendaBuffer[i]=EMPTY_VALUE;
   }

            
      }
   return(rates_total);
  }
//+------------------------------------------------------------------+




