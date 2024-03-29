//+------------------------------------------------------------------+
//|                                                     Dunnigan.mq5 |
//|                                                  Henrique Vilela |
//|                                               http://vilela.one/ |
//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 12
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

// INPUT---------------------------------
input ENUM_TIMEFRAMES Periodo=PERIOD_CURRENT;
input bool   drawIndicatorTrendLines = false;
input bool   drawPriceTrendLines     = false;
input bool   displayAlert            = false;
// MACD----------------------------------
//CCI
input int cci_period=9; // CCI period
//OBV
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_TICK; // Volumes
//Moment
input int moment_period=9; // Moment period

double         VendaBuffer[];
double         CompraBuffer[];
double cci_bull[],obv_bull[],moment_bull[];
double cci_bear[],obv_bear[],moment_bear[];
double total_div[];
double cci_tmp[2],obv_tmp[2],moment_tmp[2];
int cci_handle,obv_handle,moment_handle;
double cci_aux[],obv_aux[],moment_aux[];

double soma_compra,soma_venda;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   cci_handle=iCustom(_Symbol,Periodo,"Divergencias\\cci_divergence",cci_period,drawIndicatorTrendLines,drawPriceTrendLines,displayAlert);
   obv_handle=iCustom(_Symbol,Periodo,"Divergencias\\obv_divergence",InpVolumeType,drawIndicatorTrendLines,drawPriceTrendLines,displayAlert);
   moment_handle=iCustom(_Symbol,Periodo,"Divergencias\\moment_divergence",moment_period,drawIndicatorTrendLines,drawPriceTrendLines,displayAlert);
   
   
   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,total_div,INDICATOR_DATA);
   SetIndexBuffer(3,cci_bull,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,cci_bear,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,obv_bull,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,obv_bear,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,moment_bull,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,moment_bear,INDICATOR_CALCULATIONS);
   
   SetIndexBuffer(9,cci_aux,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,obv_aux,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,moment_aux,INDICATOR_CALCULATIONS);
   
   
   
   
   
   
   //ArraySetAsSeries(macd_bull,true);
   //ArraySetAsSeries(macd_bear,true);
   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE); 
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);

   //PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   //PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);
   string indicatorName="Divergencias";
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+2);
   IndicatorSetString(INDICATOR_SHORTNAME,indicatorName);

   return(INIT_SUCCEEDED);
  }
  
 void OnDeinit(const int reason)
  {
   Comment("");
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
   
   for(int i=MathMax(1,prev_calculated-1); i<rates_total; i++)
     {
     soma_compra=0;
     soma_venda=0;
     
     
      CopyBuffer(cci_handle,0,BarsCalculated(cci_handle)-i+1,2,cci_tmp);
      CopyBuffer(obv_handle,0,BarsCalculated(obv_handle)-i+1,2,obv_tmp);
      CopyBuffer(moment_handle,0,BarsCalculated(moment_handle)-i+1,2,moment_tmp);
      
      cci_bull[i-1]=cci_tmp[0];
      obv_bull[i-1]=obv_tmp[0];
      moment_bull[i-1]=moment_tmp[0];
      cci_bull[i]=cci_tmp[1];
      obv_bull[i]=obv_tmp[1];
      moment_bull[i]=moment_tmp[1];
      
      
      
      CopyBuffer(cci_handle,1,BarsCalculated(cci_handle)-i+1,2,cci_tmp);
      CopyBuffer(obv_handle,1,BarsCalculated(obv_handle)-i+1,2,obv_tmp);
      CopyBuffer(moment_handle,1,BarsCalculated(moment_handle)-i+1,2,moment_tmp);
      
      
     
      
      cci_bear[i-1]=cci_tmp[0];
      obv_bear[i-1]=obv_tmp[0];
      moment_bear[i-1]=moment_tmp[0];
      
      cci_bear[i]=cci_tmp[1];
      obv_bear[i]=obv_tmp[1];
      moment_bear[i]=moment_tmp[1];
      
      
      
      
      
      
      
      //---------------------------------------------------------------
      if (cci_bull[i]==EMPTY_VALUE && cci_bear[i]==EMPTY_VALUE) cci_aux[i]=cci_aux[i-1];
      else 
      {
      if (cci_bear[i]==EMPTY_VALUE) cci_aux[i]=1;
      else cci_aux[i]=-1;
      }
      //---------------------------------------------------------------
      //---------------------------------------------------------------
      if (obv_bull[i]==EMPTY_VALUE && obv_bear[i]==EMPTY_VALUE) obv_aux[i]=obv_aux[i-1];
      else 
      {
      if (obv_bear[i]==EMPTY_VALUE) obv_aux[i]=1;
      else obv_aux[i]=-1;
      }
      //---------------------------------------------------------------
      //---------------------------------------------------------------
      if (moment_bull[i]==EMPTY_VALUE && moment_bear[i]==EMPTY_VALUE) moment_aux[i]=moment_aux[i-1];
      else 
      {
      if (moment_bear[i]==EMPTY_VALUE) moment_aux[i]=1;
      else moment_aux[i]=-1;
      }
                
      
      total_div[i]=cci_aux[i]+obv_aux[i]+moment_aux[i];
      soma_compra=(total_div[i]+3)/2;
      soma_venda=3-soma_compra;
      Comment("Divergencias altistas ",soma_compra," Divergencias baixistas ",soma_venda, "Total ", total_div[i]);
      
      if (total_div[i]<0) 
      {
      VendaBuffer[i]=high[i];
      CompraBuffer[i]=0;
      }
      else if (total_div[i]>0)
      {
      CompraBuffer[i]=low[i];
      VendaBuffer[i]=0;
      
      }
      
     
      
  }// end for i
   return(rates_total);
  }
//+------------------------------------------------------------------+
