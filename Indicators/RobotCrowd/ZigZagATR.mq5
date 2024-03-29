//+------------------------------------------------------------------+
//|                                                    ZigZagATR.mq5 |
//|                                                Antonio Guglielmi |
//|             RobotCrowd - Crowdsourcing para trading automatizado |
//|                                    https://www.robotcrowd.com.br |
//|                                                                  |
//| * Este indicador e baseado no fastzz criado por Yurich e         |
//|   modificado para usar o ATR como medida de desvio.              |
//|   O indicador original pode ser encontrado em:                   |
//|   https://www.mql5.com/pt/code/1027                              |
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
#property description   "ZigZag com ATR"
#property description   "  "
#property description   "Este indicador e distribuido gratuitamente para membros da comunidade RobotCrowd."
#property description   "A utilizacao em contas reais e de inteira responsabilidade do usuario e o site RobotCrowd nao se"
#property description   "responsabiliza por eventuais perdas decorrentes da utilizacao de qualquer um dos robos."
#property description   "  "
#property description   "RobotCrowd - Crowdsourcing para trading automatizado"



enum HiLoType {
   barClose,       // Fechamento
   barHiLo         // Maxima e Minima
};

#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots 1
#property indicator_label1  "ZigZagATR"
#property indicator_type1   DRAW_ZIGZAG
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//+------------------------------------------------------------------+
input int ATR_Period=34;        // Periodo ATR
input double ATR_Multiplier=3;  // Multiplicador para profundidade
input HiLoType HiLo=barClose;   // Dados usados no calculo
//+------------------------------------------------------------------+
double zzH[],zzL[],atr[];
//double depth;//, deviation;
int last,direction,atrHandle;
//+------------------------------------------------------------------+
void OnInit()
  {
   atrHandle = iATR(_Symbol, _Period, ATR_Period);
   if (atrHandle < 0) {
      Alert("Erro criando indicador ATR");
   }
   SetIndexBuffer(0,zzH,INDICATOR_DATA);
   SetIndexBuffer(1,zzL,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,Digits());
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   //depth=Depth*_Point;
//deviation=10*_Point;
   direction=1;
   last=0;
  }
//+------------------------------------------------------------------+
int OnCalculate(const int total,
                const int calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick[],
                const long &real[],
                const int &spread[])
  {
   if(calculated==0) { 
      last=0;
      ArrayInitialize(zzH, 0.0);
      ArrayInitialize(zzL, 0.0);
      ArrayInitialize(atr, 0.0);
   }
   if (CopyBuffer(atrHandle, 0, 0, total, atr) < 0) {
      Print("Erro copiando buffer do ATR - error: ", GetLastError());
   }
   for(int i=calculated>0?calculated-1:0; i<total-1; i++)
     {
      bool set=false;
      double thisHigh = 0.0;
      double lastHigh = 0.0;
      double thisLow = 0.0;
      double lastLow = 0.0;

      if (HiLo == barClose) {
         thisHigh = thisLow = close[i];
         lastHigh = lastLow = close[last];
      }
      else {
         thisHigh = high[i];
         thisLow = low[i];
         lastHigh = high[last];
         lastLow = low[last];
      }

      zzL[i]=0;
      zzH[i]=0;
      //---
      if(direction > 0)
        {
         if(thisHigh > zzH[last])//-deviation)
           {
            zzH[last]=0;
            zzH[i]=thisHigh;
            if(thisLow < lastHigh-(atr[last] * ATR_Multiplier))
              {
               if(open[i]<close[i]) zzH[last]=lastHigh; else direction=-1;
               zzL[i]=thisLow;
              }
            last=i;
            set=true;
           }
         if(thisLow<zzH[last]-(atr[last] * ATR_Multiplier) && (!set || open[i]>close[i]))
           {
            zzL[i]=thisLow;
            if(thisHigh>zzL[i]+(atr[last] * ATR_Multiplier) && open[i]<close[i]) zzH[i]=thisHigh; else direction=-1;
            last=i;
           }
        }
      else
        {
         if(thisLow<zzL[last])//+deviation)
           {
            zzL[last]=0;
            zzL[i]=thisLow;
            if(thisHigh > lastLow +(atr[last] * ATR_Multiplier))
              {
               if(open[i]>close[i]) zzL[last]=lastLow; else direction=1;
               zzH[i]=thisHigh;
              }
            last=i;
            set=true;
           }
         if(thisHigh > zzL[last] + (atr[last] * ATR_Multiplier) && (!set || open[i]<close[i]))
           {
            zzH[i]=thisHigh;
            if(thisLow < zzH[i] - (atr[last] * ATR_Multiplier) && open[i]>close[i]) zzL[i]=thisLow; else direction=1;
            last=i;
           }
        }
     }
//----
   zzH[total-1]=0;
   zzL[total-1]=0;
   return(total);
  }
//+------------------------------------------------------------------+
