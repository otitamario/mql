//+------------------------------------------------------------------+
//|                                                     Dunnigan.mq5 |
//|                                                  Henrique Vilela |
//|                                               http://vilela.one/ |
//+------------------------------------------------------------------+
#property copyright "Mario"
#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 30
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
input int    fastEMA                 = 12;
input int    slowEMA                 = 26;
input int    signalSMA               = 9;
//CCI
input int cci_period=14; // CCI period
//OBV
input ENUM_APPLIED_VOLUME InpVolumeType=VOLUME_REAL; // Volumes
//MFI
input int mfi_period=14; // MFI period
//AD = OBV
//CHAIKIN
input int chaikin_rapida=3; // CHAIKIN rapida
input int chaikin_lenta=10;// CHAIKIN lenta
input ENUM_MA_METHOD InpMAMethod=MODE_EMA;// Metodo MA
// IFR
input int ifr_period=9; // IFR period
//Moment
input int moment_period=14; // Moment period
//Williams
input int williams_period=14; // Williams period

double         VendaBuffer[];
double         CompraBuffer[];
double macd_bull[],cci_bull[],obv_bull[],mfi_bull[],ad_bull[],chaikin_bull[],ifr_bull[],moment_bull[],williams_bull[];
double macd_bear[],cci_bear[],obv_bear[],mfi_bear[],ad_bear[],chaikin_bear[],ifr_bear[],moment_bear[],williams_bear[];
double total_div[];
double macd_tmp[2],cci_tmp[2],obv_tmp[2],mfi_tmp[2],ad_tmp[2],chaikin_tmp[2],ifr_tmp[2],moment_tmp[2],williams_tmp[2];
int macd_handle,cci_handle,obv_handle,mfi_handle,ad_handle,chaikin_handle,ifr_handle,moment_handle,williams_handle;
double macd_aux[],cci_aux[],obv_aux[],mfi_aux[],ad_aux[],chaikin_aux[],ifr_aux[],moment_aux[],williams_aux[];

double soma_compra,soma_venda;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   macd_handle=iCustom(_Symbol,Periodo,"Divergencias\\macd_divergence",fastEMA,slowEMA,signalSMA,drawIndicatorTrendLines,drawPriceTrendLines,displayAlert);
   cci_handle=iCustom(_Symbol,Periodo,"Divergencias\\cci_divergence",cci_period,drawIndicatorTrendLines,drawPriceTrendLines,displayAlert);
   obv_handle=iCustom(_Symbol,Periodo,"Divergencias\\obv_divergence",InpVolumeType,drawIndicatorTrendLines,drawPriceTrendLines,displayAlert);
   mfi_handle=iCustom(_Symbol,Periodo,"Divergencias\\mfi_divergence",mfi_period,InpVolumeType,drawIndicatorTrendLines,drawPriceTrendLines,displayAlert);
   ad_handle=iCustom(_Symbol,Periodo,"Divergencias\\AD_divergence",InpVolumeType,drawIndicatorTrendLines,drawPriceTrendLines,displayAlert);
   ifr_handle=iCustom(_Symbol,Periodo,"Divergencias\\ifr_divergence",ifr_period,drawIndicatorTrendLines,drawPriceTrendLines,displayAlert);
   chaikin_handle=iCustom(_Symbol,Periodo,"Divergencias\\chaikin_divergence",chaikin_rapida,chaikin_lenta,InpVolumeType,InpMAMethod,drawIndicatorTrendLines,drawPriceTrendLines,displayAlert);
   moment_handle=iCustom(_Symbol,Periodo,"Divergencias\\moment_divergence",moment_period,drawIndicatorTrendLines,drawPriceTrendLines,displayAlert);
   williams_handle=iCustom(_Symbol,Periodo,"Divergencias\\williams_divergence",williams_period,drawIndicatorTrendLines,drawPriceTrendLines,displayAlert);
   
   
   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,total_div,INDICATOR_DATA);
   SetIndexBuffer(3,macd_bull,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,macd_bear,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,cci_bull,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,cci_bear,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,obv_bull,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,obv_bear,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,mfi_bull,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,mfi_bear,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,ad_bull,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,ad_bear,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,ifr_bull,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,ifr_bear,INDICATOR_CALCULATIONS);
   SetIndexBuffer(15,chaikin_bull,INDICATOR_CALCULATIONS);
   SetIndexBuffer(16,chaikin_bear,INDICATOR_CALCULATIONS);
   SetIndexBuffer(17,moment_bull,INDICATOR_CALCULATIONS);
   SetIndexBuffer(18,moment_bear,INDICATOR_CALCULATIONS);
   SetIndexBuffer(19,williams_bull,INDICATOR_CALCULATIONS);
   SetIndexBuffer(20,williams_bear,INDICATOR_CALCULATIONS);
   
   SetIndexBuffer(21,macd_aux,INDICATOR_CALCULATIONS);
   SetIndexBuffer(22,cci_aux,INDICATOR_CALCULATIONS);
   SetIndexBuffer(23,obv_aux,INDICATOR_CALCULATIONS);
   SetIndexBuffer(24,mfi_aux,INDICATOR_CALCULATIONS);
   SetIndexBuffer(25,ad_aux,INDICATOR_CALCULATIONS);
   SetIndexBuffer(26,ifr_aux,INDICATOR_CALCULATIONS);
   SetIndexBuffer(27,chaikin_aux,INDICATOR_CALCULATIONS);
   SetIndexBuffer(28,moment_aux,INDICATOR_CALCULATIONS);
   SetIndexBuffer(29,williams_aux,INDICATOR_CALCULATIONS);
   
   
   
   
   
   
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
     
     
      CopyBuffer(macd_handle,0,BarsCalculated(macd_handle)-i+1,2,macd_tmp);
      CopyBuffer(cci_handle,0,BarsCalculated(cci_handle)-i+1,2,cci_tmp);
      CopyBuffer(obv_handle,0,BarsCalculated(obv_handle)-i+1,2,obv_tmp);
      CopyBuffer(mfi_handle,0,BarsCalculated(mfi_handle)-i+1,2,mfi_tmp);
      CopyBuffer(ad_handle,0,BarsCalculated(ad_handle)-i+1,2,ad_tmp);
      CopyBuffer(ifr_handle,0,BarsCalculated(ifr_handle)-i+1,2,ifr_tmp);
      CopyBuffer(chaikin_handle,0,BarsCalculated(chaikin_handle)-i+1,2,chaikin_tmp);
      CopyBuffer(moment_handle,0,BarsCalculated(moment_handle)-i+1,2,moment_tmp);
      CopyBuffer(williams_handle,0,BarsCalculated(williams_handle)-i+1,2,williams_tmp);
      
      macd_bull[i-1]=macd_tmp[0];
      cci_bull[i-1]=cci_tmp[0];
      obv_bull[i-1]=obv_tmp[0];
      mfi_bull[i-1]=mfi_tmp[0];
      ad_bull[i-1]=ad_tmp[0];
      ifr_bull[i-1]=ifr_tmp[0];
      chaikin_bull[i-1]=chaikin_tmp[0];
      moment_bull[i-1]=moment_tmp[0];
      williams_bull[i-1]=williams_tmp[0];
      
      macd_bull[i]=macd_tmp[1];
      cci_bull[i]=cci_tmp[1];
      obv_bull[i]=obv_tmp[1];
      mfi_bull[i]=mfi_tmp[1];
      ad_bull[i]=ad_tmp[1];
      ifr_bull[i]=ifr_tmp[1];
      chaikin_bull[i]=chaikin_tmp[1];
      moment_bull[i]=moment_tmp[1];
      williams_bull[i]=williams_tmp[1];
      
      
      
       CopyBuffer(macd_handle,1,BarsCalculated(macd_handle)-i+1,2,macd_tmp);
      CopyBuffer(cci_handle,1,BarsCalculated(cci_handle)-i+1,2,cci_tmp);
      CopyBuffer(obv_handle,1,BarsCalculated(obv_handle)-i+1,2,obv_tmp);
      CopyBuffer(mfi_handle,1,BarsCalculated(mfi_handle)-i+1,2,mfi_tmp);
      CopyBuffer(ad_handle,1,BarsCalculated(ad_handle)-i+1,2,ad_tmp);
      CopyBuffer(ifr_handle,1,BarsCalculated(ifr_handle)-i+1,2,ifr_tmp);
      CopyBuffer(chaikin_handle,1,BarsCalculated(chaikin_handle)-i+1,2,chaikin_tmp);
      CopyBuffer(moment_handle,1,BarsCalculated(moment_handle)-i+1,2,moment_tmp);
      CopyBuffer(williams_handle,1,BarsCalculated(williams_handle)-i+1,2,williams_tmp);
     
      
     
      
      macd_bear[i-1]=macd_tmp[0];
      cci_bear[i-1]=cci_tmp[0];
      obv_bear[i-1]=obv_tmp[0];
      mfi_bear[i-1]=mfi_tmp[0];
      ad_bear[i-1]=ad_tmp[0];
      ifr_bear[i-1]=ifr_tmp[0];
      chaikin_bear[i-1]=chaikin_tmp[0];
      moment_bear[i-1]=moment_tmp[0];
      williams_bear[i-1]=williams_tmp[0];
      
      macd_bear[i]=macd_tmp[1];
      cci_bear[i]=cci_tmp[1];
      obv_bear[i]=obv_tmp[1];
      mfi_bear[i]=mfi_tmp[1];
      ad_bear[i]=ad_tmp[1];
      ifr_bear[i]=ifr_tmp[1];
      chaikin_bear[i]=chaikin_tmp[1];
      moment_bear[i]=moment_tmp[1];
      williams_bear[i]=williams_tmp[1];
      
      
      
      
      
      
      //---------------------------------------------------------------
      if (macd_bull[i]==EMPTY_VALUE && macd_bear[i]==EMPTY_VALUE) macd_aux[i]=macd_aux[i-1];
      else 
      {
      if (macd_bear[i]==EMPTY_VALUE) macd_aux[i]=1;
      else macd_aux[i]=-1;
      }
      //---------------------------------------------------------------

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
      if (mfi_bull[i]==EMPTY_VALUE && mfi_bear[i]==EMPTY_VALUE) mfi_aux[i]=mfi_aux[i-1];
      else 
      {
      if (mfi_bear[i]==EMPTY_VALUE) mfi_aux[i]=1;
      else mfi_aux[i]=-1;
      }
      //---------------------------------------------------------------
      //---------------------------------------------------------------
      if (ad_bull[i]==EMPTY_VALUE && ad_bear[i]==EMPTY_VALUE) ad_aux[i]=ad_aux[i-1];
      else 
      {
      if (ad_bear[i]==EMPTY_VALUE) ad_aux[i]=1;
      else ad_aux[i]=-1;
      }
      //---------------------------------------------------------------
      //---------------------------------------------------------------
      if (ifr_bull[i]==EMPTY_VALUE && ifr_bear[i]==EMPTY_VALUE) ifr_aux[i]=ifr_aux[i-1];
      else 
      {
      if (ifr_bear[i]==EMPTY_VALUE) ifr_aux[i]=1;
      else ifr_aux[i]=-1;
      }
      //---------------------------------------------------------------
      if (chaikin_bull[i]==EMPTY_VALUE && chaikin_bear[i]==EMPTY_VALUE) chaikin_aux[i]=chaikin_aux[i-1];
      else 
      {
      if (chaikin_bear[i]==EMPTY_VALUE) chaikin_aux[i]=1;
      else chaikin_aux[i]=-1;
      }
      //---------------------------------------------------------------
      if (moment_bull[i]==EMPTY_VALUE && moment_bear[i]==EMPTY_VALUE) moment_aux[i]=moment_aux[i-1];
      else 
      {
      if (moment_bear[i]==EMPTY_VALUE) moment_aux[i]=1;
      else moment_aux[i]=-1;
      }
      //---------------------------------------------------------------
      if (williams_bull[i]==EMPTY_VALUE && williams_bear[i]==EMPTY_VALUE) williams_aux[i]=williams_aux[i-1];
      else 
      {
      if (williams_bear[i]==EMPTY_VALUE) williams_aux[i]=1;
      else williams_aux[i]=-1;
      }
      //---------------------------------------------------------------
                
      
      total_div[i]=macd_aux[i]+cci_aux[i]+obv_aux[i]+mfi_aux[i]+ad_aux[i];
      total_div[i]+=ifr_aux[i]+chaikin_aux[i]+moment_aux[i]+williams_aux[i];
      soma_compra=(total_div[i]+9)/2;
      soma_venda=9-soma_compra;
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
