//+------------------------------------------------------------------+
//|                                       ChannelPatternDetector.mq5 |
//| 				                 Copyright © 2014-2016, EarnForex.com |
//|                                       https://www.earnforex.com/ |
//+------------------------------------------------------------------+
#property copyright "EarnForex.com"
#property link      "https://www.earnforex.com/metatrader-indicators/Channel-Pattern-Detector/"
#property indicator_chart_window
#property version "1.01"

#property description "Finds channels and marks them with lines."
#property description "Uses OBJ_TREND objects."
#property description "1. Detects and draws 3-point lines."
#property description "2. Finds pairs, hides unpaired lines."
#property description "3. Finds pairs that form channels, hides non-channel lines."
#property description "Can send email, sound and visual alerts if enabled."
#property description "Uses objects' descriptions to store data."
#property description "WARNING: This indicator can remove your objects and chart's comment."

#property indicator_plots 0

#include <iChartPatternDetector.mqh>

input double Threshold = 0.007; // Threshold (as multiplier of (Highest - Lowest) @ LookBack)
input int MinBars = 10; // MinBars (minimum number of bars for a line)
input int MaxBars = 150; // MaxBars (maximum number of bars for a line)
input double Symmetry = 0.25; // Symmetry (symmetry coefficient for middle point location. 1 - maximum symmetry, 0 - minimum.)
input double PairMatchingRatio = 0.7; // PairMatchingRatio (how equal should be the high and low lines for them to count as pair? 1 - perfect match, 0 - no match.)
input double AngleDifference = 0.0007; // AngleDifference (maximum angle difference for channel lines. As multiplier of (Highest - Lowest) @ LookBack.)
input string NamePrefix = "LF-";
input int LookBack = 150; // LookBack (how many bars to look back?)
input color ColorSupportUp = clrLimeGreen;
input color ColorSupportDown = clrRed;
input color ColorResistanceUp = clrGreen;
input color ColorResistanceDown = clrMagenta;
input bool EmailAlert = false;
input bool SoundAlert = false;
input bool VisualAlert = false;

CChartPatternDetector *CPD;

void OnInit()
{
   CPD = new CChartPatternDetector(PairMatchingRatio, LookBack, NamePrefix, ColorSupportUp, ColorSupportDown, ColorResistanceUp, ColorResistanceDown, EmailAlert, SoundAlert, VisualAlert);
   Comment("ChannelPatternDetector");
}

void OnDeinit(const int reason)
{
   CPD.DeleteObjects();
   delete CPD;
   Comment("");
}

// Uses only rates_total, Time, High and Low.
int OnCalculate (const int rates_total,      // size of input time series
                 const int prev_calculated,  // bars handled in previous call
                 const datetime& Time[],     // Time
                 const double& open[],       // Open
                 const double& High[],       // High
                 const double& Low[],        // Low
                 const double& close[],      // Close
                 const long& tick_volume[],  // Tick Volume
                 const long& volume[],       // Real Volume
                 const int& spread[]         // Spread
)
{
   int limit = rates_total;
   int IC = prev_calculated;
   if (IC >= 0) limit = rates_total - IC;
   // Launches only on new bars. Does not use latest (current) bar in calculations.
   if (limit > 0)
   {
      CPD.SetChartData(rates_total, Time, High, Low);
      CPD.FindLines(Threshold, MinBars, MaxBars, Symmetry, limit);
      CPD.FilterPairs();
      CPD.FilterChannels(AngleDifference);
   }
   return(rates_total);
}
//+------------------------------------------------------------------+