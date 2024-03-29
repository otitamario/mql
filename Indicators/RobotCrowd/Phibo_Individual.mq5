//+------------------------------------------------------------------+
//|                                             Phibo_Individual.mq5 |
//|                                                Antonio Guglielmi |
//|             RobotCrowd - Crowdsourcing para trading automatizado |
//|                                    https://www.robotcrowd.com.br |
//|                                                                  |
//+------------------------------------------------------------------+
//   Copyright 2017 Antonio Guglielmi - RobotCrowd
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
   
#property copyright     "Antonio Guglielmi - RobotCrowd"
#property link          "https://www.robotcrowd.com.br"
#property version       "1.00"
#property description   "Phibo"
#property description   "  "
#property description   "Este indicador e distribuido gratuitamente para membros da comunidade RobotCrowd."
#property description   "A utilizacao em contas reais e de inteira responsabilidade do usuario e o site RobotCrowd nao se"
#property description   "responsabiliza por eventuais perdas decorrentes da utilizacao de qualquer um dos robos."
#property description   "  "
#property description   "RobotCrowd - Crowdsourcing para trading automatizado"


#include "LibPhibo.mqh"


#property indicator_chart_window 
#property indicator_buffers 7 
#property indicator_plots   7

//+-----------------------------------+
//|  parameters of indicator drawing  |
//+-----------------------------------+
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrOrange
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_label1  "100%"

#property indicator_type2   DRAW_LINE
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
#property indicator_label2  "78.6%"

#property indicator_type3   DRAW_LINE
#property indicator_color3  clrOrange
#property indicator_style3  STYLE_DASH
#property indicator_width3  1
#property indicator_label3  "61.8%"

#property indicator_type4   DRAW_LINE
#property indicator_color4  clrOrange
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
#property indicator_label4  "50%"

#property indicator_type5   DRAW_LINE
#property indicator_color5  clrOrange
#property indicator_style5  STYLE_DASH
#property indicator_width5  1
#property indicator_label5  "38.2%"

#property indicator_type6   DRAW_LINE
#property indicator_color6  clrRed
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
#property indicator_label6  "21.4%"

#property indicator_type7   DRAW_LINE
#property indicator_color7  clrOrange
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
#property indicator_label7  "0%"



//+-----------------------------------+
//|  INPUT PARAMETERS OF THE INDICATOR|
//+-----------------------------------+
input int PhiboPeriod=72;               //Periodo Phibo


LibPhibo phibo;

void OnInit()
  {
   phibo.SetPhiboPeriod(PhiboPeriod);
      
   
   phibo.SetIndicatorBuffer_All(0);

   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,PhiboPeriod-1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,PhiboPeriod-1);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,PhiboPeriod-1);
   PlotIndexSetInteger(3,PLOT_DRAW_BEGIN,PhiboPeriod-1);
   PlotIndexSetInteger(4,PLOT_DRAW_BEGIN,PhiboPeriod-1);
   PlotIndexSetInteger(5,PLOT_DRAW_BEGIN,PhiboPeriod-1);
   PlotIndexSetInteger(6,PLOT_DRAW_BEGIN,PhiboPeriod-1);


   string shortname;
   StringConcatenate(shortname,"Phibo( PhiboPeriod = ",PhiboPeriod,")");

   IndicatorSetString(INDICATOR_SHORTNAME,shortname);

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

   
   phibo.CalculatePhibo(rates_total, prev_calculated, open, high, low, close);

   return(rates_total);

}
//+------------------------------------------------------------------+