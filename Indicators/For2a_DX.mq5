//+------------------------------------------------------------------+
//|                                                  FORÇA DX 
//|                                           luis Carlos Machado 
//|                                            |
//+------------------------------------------------------------------+
#define VALIDADE   D'2018.10.19 23:59:59'//Data de Validade Validade
#define NUMERO_CONTA 10726877   //Numero da conta
#include<Trade\AccountInfo.mqh>


#property copyright "ROBO TRADER ONE"
#property link      "JOINVILLETOOLS@OI.COM.BR"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   1
//--- plot distance
#property indicator_label1  "distance"
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  clrDodgerBlue,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
#property indicator_level1 -0.5
#property indicator_level2 0.5
//---
enum PRICE_METHOD
  {
   Close,
   Open,
   High,
   Low,
   Median,  // Median Price (HL/2)
   Typical, // Typical Price (HLC/3)
   Weighted // Weighted Close (HLCC/4)
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum SHOW_TYPE
  {
   Porcentagem,
   Absoluto     // Valor Absoluto
  };
//--- input parameters
input int                 maPeriod   = 20;            // Período da média móvel
input ENUM_MA_METHOD      maMethod   = MODE_SMA;      // Método de Cálculo
input ENUM_APPLIED_PRICE  maApply_to = PRICE_TYPICAL; // Aplicar média a:
input PRICE_METHOD        priceType  = Median;        // Preço para cálculo de distância
input SHOW_TYPE           showType   = Porcentagem;   // Apresentar distância em:
//--- indicator buffers
double         distanceBuffer[];
double         distanceColors[];
double         MaBuffer[];
//--- global variables
int            Handler;
CAccountInfo myaccount;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   ulong numero_conta=NUMERO_CONTA;
   datetime expiracao=VALIDADE;
   string msg_validade="Validade até "+TimeToString(expiracao)+" para a conta "+IntegerToString(numero_conta)+" "+myaccount.Server();
   Alert(msg_validade);
   Print(msg_validade);
   bool licenca=TimeCurrent()>expiracao || myaccount.Login()!=numero_conta;
   if(licenca)
     {
      string erro="Licença Inválida";
      Alert(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

//--- indicator buffers mapping
   SetIndexBuffer(0,distanceBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,distanceColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(3,MaBuffer,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,3);
   Handler=iMA(NULL,0,maPeriod,0,maMethod,maApply_to);
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
//---
   if(prev_calculated<rates_total) CopyBuffer(Handler,0,0,rates_total,MaBuffer);
   for(int i=(int)MathMax(0,(double)prev_calculated-2); i<rates_total; i++)
     {
      distanceBuffer[i]=Price(open,high,low,close,i)-MaBuffer[i];
      if(showType==Porcentagem) distanceBuffer[i]/=MaBuffer[i]/100;
      if(distanceBuffer[i]>0) distanceColors[i]=0;
      else distanceColors[i]=1;
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
double Price(const double &iOpen[],
             const double &iHigh[],
             const double &iLow[],
             const double &iClose[],
             int          index)
  {
   double output;
   switch(priceType)
     {
      case Open:     output=iOpen[index]; break;
      case High:     output=iHigh[index]; break;
      case Low:      output=iLow[index]; break;
      case Median:   output=(iHigh[index]+iLow[index])/2; break;
      case Typical:  output=(iHigh[index]+iLow[index]+iClose[index])/3; break;
      case Weighted: output=(iHigh[index]+iLow[index]+iClose[index]+iClose[index])/4; break;
      default:       output=iClose[index]; break;
     }
   return(output);
  }
//+------------------------------------------------------------------+
