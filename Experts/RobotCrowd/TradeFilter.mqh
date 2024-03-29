//+------------------------------------------------------------------+
//|                                       Biblioteca TradeFilter.mqh |
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
   

#include "TradeFilterInc.mqh"


#import "TradeFilterLib.ex5"
   TradeFilter *tradeFilterInterface();
#import


TradeFilter *filter;


void initTradeFilter(void) {

   filter = tradeFilterInterface();
   filter.setGlobalFilterParam(inFilterMode, inFilterBar, inFilterShowIndicators);
   filter.setCNDLFilterParam(inFilCNDLEnable, inFilCNDLMode, inFilCNDLTimeFrame, inFilCNDLBars, inFilCNDLSymbol);
   filter.setMA1FilterParam(inFilMA1Enable, inFilMA1TimeFrame, inFilMA1Period, inFilMA1Type, inFilMA1Price, inFilMA1AboveBelow, inFilMA1Symbol);
   filter.setMA2FilterParam(inFilMA2Enable, inFilMA2TimeFrame, inFilMA2Period, inFilMA2Type, inFilMA2Price, inFilMA2AboveBelow, inFilMA2CompareMA1, inFilMA2Symbol);
   filter.setADXFilterParam(inFilADXEnable, inFilADXTimeFrame, inFilADXPeriod, inFilADXUseMain, inFilADXMin);
   filter.setMACDFilterParam(inFilMACDEnable, inFilMACDTimeFrame, inFilMACDFastMA, inFilMACDSlowMA, inFilMACDSignal);
   filter.setSARFilterParam(inFilSAREnable, inFilSARTimeFrame, inFilSARStep, inFilSARMax);
   filter.setRSIFilterParam(inFilRSIEnable, inFilRSITimeFrame, inFilRSIMode, inFilRSIPeriod, inFilRSIOSLevel, inFilRSIOBLevel);
   filter.setVOLFilterParam(inFilVOLEnable, inFilVOLTimeFrame, inFilVOLType, inFilVOLCompBars, inFilVOLMean, inFilVOLMeanPeriod);
   filter.setPhiboFilterParam(inFilPhiboEnable, inFilPhiboTimeFrame, inFilPhiboPVPC1, inFilPhiboPVPC2, inFilPhiboPVPC3);
   filter.setWPRFilterParam(inFilWPREnable, inFilWPRTimeFrame, inFilWPRMode, inFilWPRPeriod, inFilWPROSLevel, inFilWPROBLevel);
   filter.setMTFilterParam(inFilMTEnable, inFilMTTimeFrame, inFilMTCCIPeriod, inFilMTATRPeriod, inFilMTATRRate, inFilMTMAPeriod, inFilMTAboveBelow);
   filter.createFilterIndicators();

}


void deinitTradeFilter(void) {

   delete(filter);
   
}