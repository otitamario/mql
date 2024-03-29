//+------------------------------------------------------------------+
//|                                        Biblioteca TradeWatch.mqh |
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



#include "TradeWatchInc.mqh"


#import "TradeWatchLib.ex5"
   TradeWatch *tradeWatchInterface();
#import


TradeWatch *tradew;


void initTradeWatch(void) {

   tradew = tradeWatchInterface();
   tradew.setGlobalParameters(inUserEmail, inEA_Magic, inNotifyEmail, inNotifyPush, inUseOldFashionComment, inTickDelay, inDeviation, inCloseOnExpiration, inTradeType, inTradeSymbol, inPeriod, inShowIndicators, inDeleteIndicators);
   tradew.setRiskParameters(inRiskMode, inLot, inRiskParameter, inActualBalance);
   tradew.setOrderParameters(inPendingOrders, inPendingOffset);
   tradew.setDayTradeParameters(inDayTrade, inStartHour, inStartWaitMin, inStopHour, inStopBeforeEndMin, inNoTradeBeforeEndMin);
   tradew.setSLTPParameters(inSLTP, inSLValue, inTPValue, inPartialProfit, inPartialProfitLevel, inPartialProfitVol, inTrailingStop, inTrailingStopDelay, inTPMove,
                            inTPMoveValue, inTPMoveBars, inTimeStopCond, inTimeStopPeriod, inTimeStopValue, inPositionAdd, inPositionAddVol, inPositionAddMoveStop);
   tradew.setLimitParameters(inMaxDayLoss, inMaxDayProfit, inMaxWeekLoss, inMaxWeekProfit, inMaxMonthLoss, inMaxMonthProfit, inMaxDayTrades, inMaxDayTP, inCheckPLAfterClose,
                             inAvoidGapDays, inMaxGapSize, inTDWFilter, inTDWMonday, inTDWTuesday, inTDWWednesday, inTDWThursday, inTDWFriday);
   tradew.setInterlockParameters(inLockEnable, inLockMaster, inLockName, inLockValue);
   
   tradew.startTradeWatch();
   

}

void deinitTradeWatch(void) {

   delete(tradew);

}