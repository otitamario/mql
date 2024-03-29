//+------------------------------------------------------------------+
//|                                                      LSRatio.mq5 |
//|                                                Antonio Guglielmi |
//|             RobotCrowd - Crowdsourcing para trading automatizado |
//|                                    https://www.robotcrowd.com.br |
//|                                                                  |
//| * Este indicador e baseado no iSpread criado por Alexey Oreshkin |
//|   e modificado com algumas simplificacoes e acrescimo das Bandas |
//|   de Bollinger e notificacoes push.                              |
//|   O indicador original pode ser encontrado em:                   |
//|   https://www.mql5.com/en/code/2197                              |
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
#property description   "L&S Ratio"
#property description   "  "
#property description   "Este indicador e distribuido gratuitamente para membros da comunidade RobotCrowd."
#property description   "A utilizacao em contas reais e de inteira responsabilidade do usuario e o site RobotCrowd nao se"
#property description   "responsabiliza por eventuais perdas decorrentes da utilizacao de qualquer um dos robos."
#property description   "  "
#property description   "RobotCrowd - Crowdsourcing para trading automatizado"

#include <MovingAverages.mqh>

#property indicator_separate_window
#property indicator_buffers   7
#property indicator_plots     4
#property indicator_label1    "Ratio";
#property indicator_color1    clrBlue
#property indicator_style1    STYLE_SOLID
#property indicator_type1     DRAW_LINE
#property indicator_width1    2
#property indicator_label2    "Upper Band";
#property indicator_color2    clrAqua
#property indicator_style2    STYLE_SOLID
#property indicator_type2     DRAW_LINE
#property indicator_width2    1
#property indicator_label3    "Mean Line";
#property indicator_color3    clrAqua
#property indicator_style3    STYLE_SOLID
#property indicator_type3     DRAW_LINE
#property indicator_width3    1
#property indicator_label4    "Lower Band";
#property indicator_color4    clrAqua
#property indicator_style4    STYLE_SOLID
#property indicator_type4     DRAW_LINE
#property indicator_width4    1
#property indicator_level1    0


enum Operacao
  {
   Diferenca=1,  //Diferenca
   Razao=2       //Razao
  };

input datetime BeginTime      =  D'2017.01.01'; //Data inicial
input string   Symbol1        =  "PETR4";       //Papel 1
input string   Symbol2        =  "PETR3";       //Papel 2
input Operacao Action         =  Razao;         //Operacao
input bool     Invert1        =  false;         //Inverter papel 1
input bool     Invert2        =  false;         //Inverter papel 2
input double   Multi1         =  1;             //Multiplicador papel 1
input double   Multi2         =  1;             //Multiplicador papel 2
input uint     Window         =  100;           //Numero de barras considerado
input bool     ShowBands      =  true;          //Mostrar Bandas de Bollinger
input int      BandsPeriod    =  20;            //Periodo para as BB
input double   BandsDev       =  2.0;           //Desvio Padrao para as BB
input bool     PushNotify     =  false;         //Enviar notificacoes push
input double   LoLevelNotify  =  0.1;           //Limite inferior para envio de notificacao
input double   HiLevelNotify  =  5.0;           //Limite superior para envio de notificacao

bool           Error_Init=true;
bool           notifySent;
datetime       BeginDate=0;

double         BF[],
               PR1[],PR2[],                // Arrays intermediarios para processamento
               UB[], ML[], LB[], STDDEV[]; // Arrays para as bandas de bollinger
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   Error_Init=true;
   LOAD_DATA();
   IndicatorSetString(INDICATOR_SHORTNAME,NAME());
   SetIndexBuffer(0,BF,INDICATOR_DATA);
   SetIndexBuffer(1,UB,INDICATOR_DATA);
   SetIndexBuffer(2,ML,INDICATOR_DATA);
   SetIndexBuffer(3,LB,INDICATOR_DATA);
   SetIndexBuffer(4,PR1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,PR2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,STDDEV,INDICATOR_CALCULATIONS);
//---
   ZeroMemory(BF);
   ZeroMemory(UB);
   ZeroMemory(ML);
   ZeroMemory(LB);
   ZeroMemory(STDDEV);
   
   notifySent = false;
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
   if(Error_Init) LOAD_DATA();
   if(Error_Init) return(INIT_FAILED); //Initialization error

   double pr1[1],pr2[1];
   int x1,x2;
   int limit=prev_calculated;
   if(limit>1) limit=limit-2;

//--- step 1 - data preparation
   for(int pos=1+limit;pos<rates_total;pos++)
     {//preparing initial data
      if(time[pos]<BeginDate)
        {
         EMTF(pos);
         continue;
        }
      //---
      x1=CopyClose(Symbol1,PERIOD_CURRENT,time[pos],1,pr1);
      x2=CopyClose(Symbol2,PERIOD_CURRENT,time[pos],1,pr2);
      if(x1<=0 || x2<=0)
        {
         EMTF(pos);
         Print("Sem cotacao: "+string(time[pos]));
         continue;
        }
      if(pr1[0]==0 || pr2[0]==0)
        {
         EMTF(pos);
         Print("Nenhum dado recebido: "+string(time[pos]));
         continue;
        }

      PR1[pos]=MODIFY(pr1[0],Invert1,Multi1);
      PR2[pos]=MODIFY(pr2[0],Invert2,Multi2);
     }//preparing initial data

//--- merge two arrays into one
   for(int pos=1+limit;pos<rates_total;pos++) BF[pos]=ACTION(PR1[pos],PR2[pos]);

   if (ShowBands) {
   
      for(int pos=1+limit;pos<rates_total;pos++) {
          //--- middle line
         ML[pos]=SimpleMA(pos,BandsPeriod,BF);
         //--- calculate and write down StdDev
         STDDEV[pos]=StdDev_Func(pos,BF,ML,BandsPeriod);
         //--- upper line
         UB[pos]=ML[pos]+BandsDev*STDDEV[pos];
         //--- lower line
         LB[pos]=ML[pos]-BandsDev*STDDEV[pos];     
      }
   
   }
   else {
      for(int pos=1+limit;pos<rates_total;pos++) LCLEAR(pos);
   }

    // Verifica se deve enviar notificacao para o ultimo valor calculado
   if (PushNotify && (!notifySent)) {
      if (BF[rates_total - 1] < LoLevelNotify) {
         SendNotification(StringFormat("Ratio para L&S de %s/%s esta abaixo de %s", Symbol1, Symbol2, DoubleToString(LoLevelNotify, 3)));
         notifySent = true;
      }
      else if (BF[rates_total - 1] > HiLevelNotify) {
         SendNotification(StringFormat("Ratio para L&S de %s/%s esta acima de %s", Symbol1, Symbol2, DoubleToString(HiLevelNotify, 3)));
         notifySent = true;
      }
   }


   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Changing the price                                               |
//+------------------------------------------------------------------+
double MODIFY(double in,bool inv,double ml)
  {
   if(inv) in=1/in;
   in=in*ml;
   return(in);
  }
//+------------------------------------------------------------------+
//| Mathematical action                                              |
//+------------------------------------------------------------------+
double ACTION(double in1,double in2)
  {
   if(in1==EMPTY_VALUE || in2==EMPTY_VALUE) return(EMPTY_VALUE);
   switch(Action)
     {
      case 1: return(in1-in2);
      case 2: return(in1/in2);
     }
   return(in1/in2);
  }
//+------------------------------------------------------------------+
//| Loading the required data                                        |
//+------------------------------------------------------------------+
bool LOAD_DATA()
  {
   string txt=TimeToString(TimeLocal(),TIME_SECONDS);
   if(!SymbolSelect(Symbol1,true))
     {
      txt=txt+"\nNao disponivel "+Symbol1;
      Comment(txt);
      return(true);
     }
   if(!SymbolSelect(Symbol2,true))
     {
      txt=txt+"\nNao disponivel "+Symbol2;
      Comment(txt);
      return(true);
     }
   int smb=int(Window)*2;
   if(Bars(Symbol1,PERIOD_CURRENT)<=smb)
     {
      txt=txt+"\nSem dados suficientes para o papel 1";
      Comment(txt);
      return(true);
     }
   if(Bars(Symbol2,PERIOD_CURRENT)<=smb)
     {
      txt=txt+"\nSem dados suficientes para o papel 2";
      Comment(txt);
      return(true);
     }
   datetime temp[1];
   if(CopyTime(Symbol1,PERIOD_CURRENT,Bars(Symbol1,PERIOD_CURRENT)-1,1,temp)<=0)
     {
      txt=txt+"\nObtendo data/hora do papel 1";
      Comment(txt);
      return(true);
     }
   BeginDate=MathMax(BeginTime,temp[0]);
   if(CopyTime(Symbol2,PERIOD_CURRENT,Bars(Symbol2,PERIOD_CURRENT)-1,1,temp)<=0)
     {
      txt=txt+"\nObtendo data/hora do papel 2";
      Comment(txt);
      return(true);
     }
   BeginDate=MathMax(BeginDate,temp[0]);
   Comment("");
   Error_Init=false;
   return(false);
  }
//+------------------------------------------------------------------+
//| Assigning an empty value to all arrays at the current position   |
//+------------------------------------------------------------------+
void EMTF(int i)
  {
   BF[i]=EMPTY_VALUE;
   PR1[i]=EMPTY_VALUE;
   PR2[i]=EMPTY_VALUE;
  }
  
void LCLEAR(int i)
  {
   UB[i]=EMPTY_VALUE;
   ML[i]=EMPTY_VALUE;
   LB[i]=EMPTY_VALUE;
  }
  
//+------------------------------------------------------------------+
//| Make up the indicator name                                       |
//+------------------------------------------------------------------+
string NAME()
  {
   string name="";
   if(Invert1) name="(inv)"+Symbol1;
   else name=Symbol1;
   switch(Action)
     {
      case 1: name=name+"-";break;
      case 2: name=name+"/";break;
     }
   if(Invert2) name=name+"(inv)"+Symbol2;
   else name=name+Symbol2;
   return(name);
  }
//+------------------------------------------------------------------+



double StdDev_Func(int position,const double &price[],const double &MAprice[],int period)
  {
//--- variables
   double StdDev_dTmp=0.0;
//--- check for position
   if(position<period) return(StdDev_dTmp);
//--- calcualte StdDev
   for(int i=0;i<period;i++) StdDev_dTmp+=MathPow(price[position-i]-MAprice[position],2);
   StdDev_dTmp=MathSqrt(StdDev_dTmp/period);
//--- return calculated value
   return(StdDev_dTmp);
  }
  
  
  