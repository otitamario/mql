//+--------------------------------------------------------------------+
//|                                                  masterTrend.mq5   |
//|                                                Antonio Guglielmi   |
//|             RobotCrowd - Crowdsourcing para trading automatizado   |
//|                                    https://www.robotcrowd.com.br   |
//|                                                                    |
//| * Este indicador e baseado no TrendMagic criado por Sergey Gritsay |
//|   O indicador original pode ser encontrado em:                     |
//|   https://www.mql5.com/pt/code/284                                 |
//|                                                                    |
//+--------------------------------------------------------------------+
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
#property version       "1.2"
#property description   "MasterTrend"
#property description   "  "
#property description   "Este indicador e distribuido gratuitamente para membros da comunidade RobotCrowd."
#property description   "A utilizacao em contas reais e de inteira responsabilidade do usuario e o site RobotCrowd nao se"
#property description   "responsabiliza por eventuais perdas decorrentes da utilizacao de qualquer um dos robos."
#property description   "  "
#property description   "RobotCrowd - Crowdsourcing para trading automatizado"

//--- indicator properties
#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots   1
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1 Blue,Red
#property indicator_width1 2

//--- input parameters
input int    CCI_Period = 10;     // Periodo CCI
input int    ATR_Period = 5;      // Periodo ATR
input double ATR_Rate = 1.0;      // Multiplicador ATR
input int    MA_Period = 40;      // Periodo Media Movel Simples

//--- arrays for indicator buffers
double Buffer[];
double Color[];
double CCI[];
double ATR[];
double MA[];
double StdDev[];

//--- variables to store handles of the indicators
int Hcci = INVALID_HANDLE;
int Hatr = INVALID_HANDLE;
int Hma = INVALID_HANDLE;
int Hstddev = INVALID_HANDLE; 

int trend = 1;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- prepare buffers
   SetIndexBuffer(0,Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,Color,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,CCI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,ATR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(4,MA,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,StdDev, INDICATOR_CALCULATIONS);
//--- initialize buffers
   ArrayInitialize(Buffer,0.0);
   ArrayInitialize(CCI,0.0);
   ArrayInitialize(ATR,0.0);
   ArrayInitialize(MA,0.0);
   ArrayInitialize(StdDev,0.0);
//--- indicator buffers mapping
   Hcci=iCCI(_Symbol,_Period,CCI_Period,PRICE_TYPICAL);
   Hatr=iATR(_Symbol,_Period,ATR_Period);
   Hma=iMA(_Symbol,_Period,MA_Period, 0, MODE_SMA, PRICE_CLOSE);
   Hstddev=iStdDev(_Symbol,_Period,MA_Period,0,MODE_SMA,PRICE_CLOSE);
//---
   return(0);
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
//--- check number of bars, necessary for the calculation
   if(rates_total<CCI_Period || rates_total<ATR_Period || rates_total<MA_Period) return(rates_total);
   else if (rates_total == prev_calculated) return (rates_total);
   
//--- check handles of the indicators
   if(Hcci==INVALID_HANDLE || Hcci==0)
     {
      Hcci=iCCI(_Symbol,_Period,CCI_Period,PRICE_TYPICAL);
      return(rates_total);
     }
   if(Hatr==INVALID_HANDLE || Hatr==0)
     {
      Hatr=iATR(_Symbol,_Period,ATR_Period);
      return(rates_total);
     }
   if(Hma==INVALID_HANDLE || Hma==0)
     {
      Hma=iMA(_Symbol,_Period,MA_Period, 0, MODE_LWMA, PRICE_CLOSE);
      return(rates_total);
     }
   if(Hstddev==INVALID_HANDLE || Hstddev==0)
     {
      Hstddev=iStdDev(_Symbol,_Period,MA_Period,0,MODE_SMA,PRICE_CLOSE);
      return(rates_total);
     }
     
     

//--- check number of calculated data
   int calculated1=BarsCalculated(Hcci);
   int calculated2=BarsCalculated(Hatr);
   int calculated3=BarsCalculated(Hma);
   int calculated4=BarsCalculated(Hstddev);
//--- synchronize data
   int to_copy=MathMin(calculated1,calculated2);
   to_copy=MathMin(to_copy,calculated3);
   to_copy=MathMin(to_copy,calculated4);
   if(to_copy<0)return(rates_total);
   
   
//--- copy data of the indicators
   if (CopyBuffer(Hcci, 0, 0, to_copy, CCI) < to_copy) return(rates_total);
   if (CopyBuffer(Hatr, 0, 0, to_copy, ATR) < to_copy) return(rates_total);
   if (CopyBuffer(Hma, 0, 0, to_copy, MA) < to_copy) return(rates_total);
   if (CopyBuffer(Hstddev, 0, 0, to_copy, StdDev) < to_copy) return(rates_total);
   

//--- calculate and write data to the indicator's buffer

   
   for(int i=2; i < rates_total; i++)
     {

      if ((CCI[i] > 100.0) && (MA[i] > MA[i-2]) && (StdDev[i] > ATR[i]) && (low[i] > Buffer[i-1])) { 
         // Tendencia mudou para alta
         trend = 1;
      }
      else if ((CCI[i] < 100.0) && (MA[i] < MA[i-2]) && (StdDev[i] > ATR[i]) && (high[i] < Buffer[i-1])) { 
         // Tendencia mudou para baixa
         trend = -1;
      }
     
      if(trend == 1)
        {
         Buffer[i] = low[i] - (ATR[i] * ATR_Rate);
         //Buffer[i] = HiLo[i] - (ATR[i] * ATR_Rate);
         if(Buffer[i]<Buffer[i-1])Buffer[i]=Buffer[i-1];
         Color[i]=0.0;
        }
      else if(trend == -1)
        {
         Buffer[i] = high[i] + (ATR[i] * ATR_Rate);
         //Buffer[i] = HiLo[i] + (ATR[i] * ATR_Rate);
         if(Buffer[i]>Buffer[i-1])Buffer[i]=Buffer[i-1];
         Color[i]=1.0;
        }
     }
     
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
