//------------------------------------------------------------------
#property copyright   "© mladen, 2017, mladenfx@gmail.com"
#property link        "www.forex-station.com"
//------------------------------------------------------------------

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_label1  "Linha Dágua"
#property indicator_type1   DRAW_LINE
#property indicator_style1  STYLE_SOLID
#property indicator_color1  clrAqua
#property indicator_width1  2

int TimeShift = 0; // Time shift (in hours)
double openLine[];
//
//
//
//
//

int OnInit() { SetIndexBuffer(0,openLine,INDICATOR_DATA); return(0); }
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{
   if (Bars(_Symbol,_Period)<rates_total) return(-1);
      for (int i=(int)MathMax(prev_calculated-1,2); i<rates_total && !IsStopped(); i++)
      {
         string stime = TimeToString(time[i]+TimeShift*3600,TIME_DATE);
            openLine[i] = (i>0) ? (TimeToString(time[i-1]+TimeShift*3600,TIME_DATE)==stime) ? openLine[i-1] : close[i-1] : close[i-1];
      }
   return(rates_total);
}