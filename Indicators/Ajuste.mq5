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


#import "Class1.dll"
#import "BCB.dll"

input string vencimento="F19";//Vencimento
input string data="11/12/2018";//Data PTAx
input string data_ajuste="10/12/2018";//Data PTAx

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
  
     if(TimeCurrent()>D'2018.12.15 23:59:59')
     {
      string erro="Data de Validade Expirou";
      MessageBox(erro);
      Print(erro);
      return(INIT_PARAMETERS_INCORRECT);
     }

//---
   string x=Class1::getPrecoAjuste(vencimento,data_ajuste);
   string message="Ajuste  "+vencimento+" "+x;
   string bcb=BCB::getDados(data);
   Print(message);
   Alert(message);

   Print(bcb);
   Alert(bcb);

 SetIndexBuffer(0,openLine,INDICATOR_DATA);
//---
   return(INIT_SUCCEEDED);
}
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