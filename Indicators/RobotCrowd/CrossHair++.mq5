//+------------------------------------------------------------------+
//|                                                  CrossHair++.mq5 |
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
#property description   "CrossHair ++"
#property description   "  "
#property description   "Este indicador e distribuido gratuitamente para membros da comunidade RobotCrowd."
#property description   "A utilizacao em contas reais e de inteira responsabilidade do usuario e o site RobotCrowd nao se"
#property description   "responsabiliza por eventuais perdas decorrentes da utilizacao de qualquer um dos robos."
#property description   "  "
#property description   "RobotCrowd - Crowdsourcing para trading automatizado"

#property indicator_chart_window

//--- input parameters
input color    UpColor=clrDarkGreen; // Positive color
input color    DownColor=clrRed;     // Negative color
input int      fontSize=12;          // Font Size
input bool     ShowPercent=true;     // Show percent value
input bool     ShowPoints=true;      // Show graph points
input bool     ShowValue=true;       // Show money value

bool crossHairMode;
bool percentEnable;
double startPrice, stopPrice;
int  chConfCount;
double tickValue, tickSize;
double percentValue;
double pointsValue;
double moneyValue;
string labelText;
datetime dt;
int x, y;



//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
      
   crossHairMode = false;
   percentEnable = true;
   startPrice = stopPrice = 0.0;
   chConfCount = 0;
   percentValue = moneyValue = pointsValue = 0.0;
      
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
   
   ObjectCreate(0, "EnableButton", OBJ_BUTTON, 0, 0, 0.0);
   ObjectSetInteger(0, "EnableButton", OBJPROP_YSIZE, 20);
   ObjectSetInteger(0, "EnableButton", OBJPROP_XSIZE, 70);
   ObjectSetInteger(0, "EnableButton", OBJPROP_XDISTANCE, 5);
   ObjectSetInteger(0, "EnableButton", OBJPROP_YDISTANCE, (ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0) - 50));
   ObjectSetInteger(0, "EnableButton", OBJPROP_STATE, 1);
   ObjectSetString(0, "EnableButton", OBJPROP_TEXT, "Disable %");

   return(INIT_SUCCEEDED);
  }
  
void OnDeinit(const int reason) 
  {

   ObjectDelete(0, "EnableButton");
   ChartRedraw();
  
  }  
  
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
//---
   
   tickValue = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   
  
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
   int window = 0;

   switch (id) {
   
      case CHARTEVENT_MOUSE_MOVE:
         if ((sparam == "1") && !crossHairMode) {
            chConfCount++;
            if (chConfCount == 1) {
               ChartXYToTimePrice(0, (int) lparam, (int) dparam, window, dt, startPrice);
            }
            else if (chConfCount >= 10) {
               crossHairMode = true;
               ObjectCreate(0, "percentLabel", OBJ_LABEL, 0, dt, startPrice);
               ObjectSetInteger(0, "percentLabel", OBJPROP_FONTSIZE, fontSize);
            }
         }
         else if ((sparam == "0") && crossHairMode) {
            crossHairMode = false;
            chConfCount = 0;
            ObjectDelete(0, "percentLabel");
         }
         break;
         
      case CHARTEVENT_CHART_CHANGE:
         chConfCount = 0;
         crossHairMode = false;
         ObjectDelete(0, "percentLabel");
         ObjectSetInteger(0, "EnableButton", OBJPROP_XDISTANCE, 5);
         ObjectSetInteger(0, "EnableButton", OBJPROP_YDISTANCE, (ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0) - 50));
         break;
         
      case CHARTEVENT_CLICK:
      case CHARTEVENT_OBJECT_DRAG:
         chConfCount = 0;
         crossHairMode = false;
         ObjectDelete(0, "percentLabel");
         ChartRedraw();
         break;
         
      case CHARTEVENT_OBJECT_CLICK:
         if (sparam == "EnableButton") {
            if (percentEnable) {
               ObjectSetString(0, "EnableButton", OBJPROP_TEXT, "Enable %");
               ObjectSetInteger(0, "EnableButton", OBJPROP_STATE, 0);
               ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 0);
               percentEnable = false;
            }
            else {
               ObjectSetString(0, "EnableButton", OBJPROP_TEXT, "Disable %");
               ObjectSetInteger(0, "EnableButton", OBJPROP_STATE, 1);
               ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, 1);
               percentEnable = true;
            }
         }  
         break;
      
   }

   if (crossHairMode) {
      ChartXYToTimePrice(0, (int) lparam, (int) dparam, window, dt, stopPrice);
      percentValue = NormalizeDouble((((stopPrice - startPrice) / startPrice) * 100), 2);
      pointsValue = NormalizeDouble((stopPrice - startPrice), 2);
      moneyValue = NormalizeDouble((pointsValue / tickSize) * tickValue, 2);

      labelText = "";
      if (ShowPercent) {
         labelText = DoubleToString(percentValue, 2) + "%  ";
      }
      
      if (ShowPoints) {
         labelText = labelText + DoubleToString(pointsValue, _Digits) + "pts  ";
      }
      
      if (ShowValue) {
         labelText = labelText + "$" + DoubleToString(moneyValue, 2);
      }
      
      ChartTimePriceToXY(0, 0, dt, stopPrice, x, y);

      ObjectSetString(0, "percentLabel", OBJPROP_TEXT, labelText);

      if (percentValue < 0.0) {
         ObjectSetInteger(0, "percentLabel", OBJPROP_COLOR, DownColor);
      }
      else {
         ObjectSetInteger(0, "percentLabel", OBJPROP_COLOR, UpColor);
      }
      
      ObjectSetInteger(0, "percentLabel", OBJPROP_XDISTANCE, (long) x);
      ObjectSetInteger(0, "percentLabel", OBJPROP_YDISTANCE, (long) y + 10);
      
      ChartRedraw();

      //Comment(labelText);
   }   


   
  }
//+------------------------------------------------------------------+
