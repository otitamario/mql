
//+--------------------------------------------------------------------+
//|                                                SaldoAgressao.mq5   |
//|                                                Antonio Guglielmi   |
//|             RobotCrowd - Crowdsourcing para trading automatizado   |
//|                                    https://www.robotcrowd.com.br   |
//|                                                                    |
//+--------------------------------------------------------------------+
//   Copyright 2018 Antonio Guglielmi - RobotCrowd
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
#property version       "1.0"
#property description   "Saldo de Agressoes"
#property description   "  "
#property description   "Este indicador e distribuido gratuitamente para membros da comunidade RobotCrowd."
#property description   "A utilizacao em contas reais e de inteira responsabilidade do usuario e o site RobotCrowd nao se"
#property description   "responsabiliza por eventuais perdas decorrentes da utilizacao de qualquer um dos robos."
#property description   "  "
#property description   "RobotCrowd - Crowdsourcing para trading automatizado"


#property indicator_separate_window
#property indicator_buffers 6
#property indicator_plots   5
#property indicator_type1   DRAW_COLOR_HISTOGRAM
#property indicator_color1  Blue,Red
#property indicator_width1  6
#property indicator_label1  "Saldo Barra" 

#property indicator_type2   DRAW_NONE
#property indicator_label2  "Vol Compra"
#property indicator_type3   DRAW_NONE
#property indicator_label3  "Vol Venda"
#property indicator_type4   DRAW_NONE
#property indicator_label4  "Saldo Hora"
#property indicator_type5   DRAW_NONE
#property indicator_label5  "Saldo Dia"


input string AtivoPrincipal = "WING19"; //Digite o nome do ativo como aparece na observação de mercado
input ENUM_TIMEFRAMES TimePrincipal=PERIOD_M1;//Selecione o Time Frame que deseja medir a agressão

input int     inNumDaysBack=0;                 // Numero de dias passados para calculo (lento)
input bool    inShowDayBalance=true;           // Mostrar saldo acumulado no dia
input bool    inShowHourBalance=true;          // Mostrar saldo acumulado na hora


double CurrentBalance[];
double BalanceColor[];
double BuyVolume[];
double SellVolume[];
double HourBalance[];
double DayBalance[];

int    startBar;


datetime roundTimeToStartPeriod(datetime tm, ENUM_TIMEFRAMES tf) {
   
   MqlDateTime timestruct;
   
   switch (tf) {
      case PERIOD_MN1:
         TimeToStruct(tm, timestruct);
         return (tm - (tm % 86400) - ((timestruct.day - 1) * 86400));
      case PERIOD_W1:
         TimeToStruct(tm, timestruct);
         return (tm - (tm % 86400) - (timestruct.day_of_week * 86400));
      default:
         return (tm - (tm % (PeriodSeconds(tf))));
   }
}


int OnInit() {

   SetIndexBuffer(0, CurrentBalance, INDICATOR_DATA);
   SetIndexBuffer(1, BalanceColor,   INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2, BuyVolume,      INDICATOR_DATA);
   SetIndexBuffer(3, SellVolume,     INDICATOR_DATA);
   SetIndexBuffer(4, HourBalance,    INDICATOR_DATA);
   SetIndexBuffer(5, DayBalance,     INDICATOR_DATA);

   
   if (inShowDayBalance) {
      
      ObjectCreate(0, "DayBalance", OBJ_LABEL, ChartWindowFind(), 0, 0.0);
      ObjectSetInteger(0, "DayBalance", OBJPROP_XDISTANCE, 2);
      ObjectSetInteger(0, "DayBalance", OBJPROP_YDISTANCE, 15);
      ObjectSetInteger(0, "DayBalance", OBJPROP_FONTSIZE, 8);
      ObjectSetString (0, "DayBalance", OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, "DayBalance", OBJPROP_BACK, false);
      ObjectSetInteger(0, "DayBalance", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, "DayBalance", OBJPROP_COLOR, clrBlue);
      ObjectSetString (0, "DayBalance", OBJPROP_TEXT, "Saldo Dia: ");
   
   }


   if (inShowHourBalance) {
      
      ObjectCreate(0, "HourBalance", OBJ_LABEL, ChartWindowFind(), 0, 0.0);
      ObjectSetInteger(0, "HourBalance", OBJPROP_XDISTANCE, 2);
      ObjectSetInteger(0, "HourBalance", OBJPROP_YDISTANCE, 30);
      ObjectSetInteger(0, "HourBalance", OBJPROP_FONTSIZE, 8);
      ObjectSetString (0, "HourBalance", OBJPROP_FONT, "Arial");
      ObjectSetInteger(0, "HourBalance", OBJPROP_BACK, false);
      ObjectSetInteger(0, "HourBalance", OBJPROP_SELECTABLE, false);
      ObjectSetInteger(0, "HourBalance", OBJPROP_COLOR, clrBlue);
      ObjectSetString (0, "HourBalance", OBJPROP_TEXT, "Saldo Hora: ");
   
   }

   
   // Calcula so a partir do dia anterior para nao ocupar muito processamento
   
   datetime curTime  = TimeCurrent();
   datetime startDay = roundTimeToStartPeriod(curTime, PERIOD_D1) - (inNumDaysBack * PeriodSeconds(PERIOD_D1));

   startBar = Bars(AtivoPrincipal, TimePrincipal) - Bars(AtivoPrincipal, TimePrincipal, startDay, curTime);
   
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, (startBar));
   IndicatorSetInteger(INDICATOR_DIGITS, 0);
   
   
   if (TimePrincipal > PERIOD_H4) {
      Alert("Este indicador so pode ser usado para graficos intraday (<= H4)");
   }
   
   
   return(INIT_SUCCEEDED);
}



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
   
   if (TimePrincipal > PERIOD_H4) return(rates_total);


   //if (rates_total == prev_calculated) return (rates_total);
   
   if (prev_calculated > rates_total || prev_calculated <= 0) first = startBar;
   else first = prev_calculated - 1;

   
   for (int i = first; i < rates_total && !IsStopped(); i++) {
      
      MqlTick barTicks[];
      double  hour, day;
      
      if (roundTimeToStartPeriod(time[i], PERIOD_H1) > roundTimeToStartPeriod(time[i-1], PERIOD_H1)) {
         hour = 0.0;
      }
      else {
         hour = HourBalance[i-1];
      }

      if (roundTimeToStartPeriod(time[i], PERIOD_D1) > roundTimeToStartPeriod(time[i-1], PERIOD_D1)) {
         day = 0.0;
      }
      else {
         day = DayBalance[i-1];
      }
      
   
      int numTicks;
      numTicks = CopyTicksRange(AtivoPrincipal, barTicks, COPY_TICKS_TRADE, time[i] * 1000, ((time[i] + PeriodSeconds(TimePrincipal)) * 1000) - 1);

      CurrentBalance[i] = 0.0;
      BuyVolume[i] = 0.0;
      SellVolume[i] = 0.0;
      HourBalance[i] = 0.0;
      DayBalance[i] = 0.0;
      
      if (numTicks > 0) {
         for (int tick = 0; tick < numTicks; tick++) {
            if (((barTicks[tick].flags & TICK_FLAG_LAST) > 0) && ((barTicks[tick].flags & TICK_FLAG_BUY) > 0) && ((barTicks[tick].flags & TICK_FLAG_SELL) == 0)) {
               BuyVolume[i] += (double) barTicks[tick].volume;
            }
            else if (((barTicks[tick].flags & TICK_FLAG_LAST) > 0) && ((barTicks[tick].flags & TICK_FLAG_BUY) == 0) && ((barTicks[tick].flags & TICK_FLAG_SELL) > 0)) {
               SellVolume[i] +=  (double) barTicks[tick].volume;
            }
         }
         // Calcula o saldo da barra
         CurrentBalance[i] = BuyVolume[i] - SellVolume[i];
         
         // Muda a cor dependendo do lado mais forte
         if (CurrentBalance[i] >= 0) BalanceColor[i] = 0.0;
         else BalanceColor[i] = 1.0;
         
         // Saldos acumulados
         HourBalance[i] = hour + CurrentBalance[i];
         DayBalance[i]  = day  + CurrentBalance[i];
         
      }
   } 

   if (inShowDayBalance) {
      ObjectSetString (0, "DayBalance", OBJPROP_TEXT, "Saldo Dia: " + DoubleToString(DayBalance[rates_total-1], 0));
      if (DayBalance[rates_total-1] >= 0.0) {
         ObjectSetInteger(0, "DayBalance", OBJPROP_COLOR, clrBlue);
      }
      else {
         ObjectSetInteger(0, "DayBalance", OBJPROP_COLOR, clrRed);
      }
   }
  
   if (inShowHourBalance) {
      ObjectSetString (0, "HourBalance", OBJPROP_TEXT, "Saldo Hora: " + DoubleToString(HourBalance[rates_total-1], 0));
      if (HourBalance[rates_total-1] >= 0.0) {
         ObjectSetInteger(0, "HourBalance", OBJPROP_COLOR, clrBlue);
      }
      else {
         ObjectSetInteger(0, "HourBalance", OBJPROP_COLOR, clrRed);
      }
   }
   
   return(rates_total);
}
//+------------------------------------------------------------------+
