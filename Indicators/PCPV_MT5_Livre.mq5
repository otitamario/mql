//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
   
#property copyright     ""
#property version       "1.00"
#property description   "PC/PV"

#include <LibPhibo.mqh>

#property indicator_chart_window 
#property indicator_buffers 31 
#property indicator_plots   6

//+-----------------------------------+
//|  parameters of indicator drawing  |
//+-----------------------------------+
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrNONE,clrLime
#property indicator_style1  STYLE_DOT
#property indicator_width1  1
#property indicator_label1  "PV1"

#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrNONE, clrRed
#property indicator_style2  STYLE_DOT
#property indicator_width2  1
#property indicator_label2  "PC1"

#property indicator_type3   DRAW_COLOR_LINE
#property indicator_color3  clrNONE,clrLime
#property indicator_style3  STYLE_DASH
#property indicator_width3  2
#property indicator_label3  "PV2"

#property indicator_type4   DRAW_COLOR_LINE
#property indicator_color4  clrNONE, clrRed
#property indicator_style4  STYLE_DASH
#property indicator_width4  2
#property indicator_label4  "PC2"

#property indicator_type5   DRAW_LINE
#property indicator_color5  clrLime
#property indicator_style5  STYLE_DASH
#property indicator_width5  3
#property indicator_label5  "PV3"

#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRed
#property indicator_style6  STYLE_DASH
#property indicator_width6  3
#property indicator_label6  "PC3"


input int  InpPV1PC1Period= 72;    //PV1 PC1
input int  InpPV2PC2Period= 305;   //PV2 PC2
input int  InpPV3PC3Period= 1292;  //PV3 PC3

double BufferPV1[];
double BufferPV1Color[];
double BufferPC1[];
double BufferPC1Color[];
double BufferPV2[];
double BufferPV2Color[];
double BufferPC2[];
double BufferPC2Color[];
double BufferPV3[];
double BufferPC3[];


LibPhibo phibo72;
LibPhibo phibo305;
LibPhibo phibo1292;

void OnInit()  {
/*
//Expiry date setting 
string ExpiryDate="2018.05.31";
if(TimeCurrent() >= StringToTime(ExpiryDate)){
Alert("PCPV_MT5 Trial expirou.");
ChartIndicatorDelete(0,0,"PCPV_MT5");
ExpertRemove();
Alert("Indicador removido devido ao periodo de utilização haver vencido. Nos contate para solicitar sua licença de uso!");
//return(0);
}
else{
Alert("PCPV_MT5 Trial liberado para uso até 31/05/2018");
  }
     IndicatorSetString(INDICATOR_SHORTNAME,"PCPV_MT5");*/

   int bufindex = 0;
   
   phibo72.SetPhiboPeriod(InpPV1PC1Period);
   phibo305.SetPhiboPeriod(InpPV2PC2Period);
   phibo1292.SetPhiboPeriod(InpPV3PC3Period);
      
   SetIndexBuffer(bufindex++, BufferPV1, INDICATOR_DATA);
   SetIndexBuffer(bufindex++, BufferPV1Color, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(bufindex++, BufferPC1, INDICATOR_DATA);
   SetIndexBuffer(bufindex++, BufferPC1Color, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(bufindex++, BufferPV2, INDICATOR_DATA);
   SetIndexBuffer(bufindex++, BufferPV2Color, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(bufindex++, BufferPC2, INDICATOR_DATA);
   SetIndexBuffer(bufindex++, BufferPC2Color, INDICATOR_COLOR_INDEX);
   SetIndexBuffer(bufindex++, BufferPV3, INDICATOR_DATA);
   SetIndexBuffer(bufindex++, BufferPC3, INDICATOR_DATA);
   
   bufindex = phibo72.SetIntermediateBuffer(bufindex);
   bufindex = phibo305.SetIntermediateBuffer(bufindex);
   bufindex = phibo1292.SetIntermediateBuffer(bufindex);

   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,InpPV1PC1Period-1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,InpPV1PC1Period-1);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,InpPV2PC2Period-1);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,InpPV2PC2Period-1);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,InpPV3PC3Period-1);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,InpPV3PC3Period-1);


   IndicatorSetString(INDICATOR_SHORTNAME,"PCPV_MT5");

   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);

  }
//+------------------------------------------------------------------+  
//| Donchian Channel iteration function                              | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])  {

   
   phibo72.CalculatePhibo(rates_total, prev_calculated, open, high, low, close);
   phibo305.CalculatePhibo(rates_total, prev_calculated, open, high, low, close);
   phibo1292.CalculatePhibo(rates_total, prev_calculated, open, high, low, close);

   int limit;
   
   if (prev_calculated==0) limit=0;
   else limit=prev_calculated-1;


   for(int i=limit; i<rates_total && !IsStopped(); i++) {

      BufferPV1[i] = phibo72.Get786Value(i, false);
      BufferPC1[i] = phibo72.Get214Value(i, false);
      if (close[i] > BufferPV1[i]) {
         BufferPV1Color[i] = 1.0;
         BufferPC1Color[i] = 0.0;
      }
      else if (close[i] < BufferPC1[i]) {
         BufferPC1Color[i] = 1.0;
         BufferPV1Color[i] = 0.0;
      }
      else {
         BufferPC1Color[i] = 0.0;
         BufferPV1Color[i] = 0.0;
      }

      BufferPV2[i] = phibo305.Get786Value(i, false);
      BufferPC2[i] = phibo305.Get214Value(i, false);
      if (close[i] > BufferPV2[i]) {
         BufferPV2Color[i] = 1.0;
         BufferPC2Color[i] = 0.0;
      }
      else if (close[i] < BufferPC2[i]) {
         BufferPC2Color[i] = 1.0;
         BufferPV2Color[i] = 0.0;
      }
      else {
         BufferPC2Color[i] = 0.0;
         BufferPV2Color[i] = 0.0;
      }

      BufferPV3[i] = phibo1292.Get786Value(i, false);
      BufferPC3[i] = phibo1292.Get214Value(i, false);
      

   }

   return(rates_total);

}
//+------------------------------------------------------------------+