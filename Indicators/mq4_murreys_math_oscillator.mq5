//+------------------------------------------------------------------+
//|                                      Murreys_Math_Oscillator.mq4 |
//+------------------------------------------------------------------+

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_buffers 1


#property indicator_label1  "MMLO"
#property indicator_type1   DRAW_HISTOGRAM
#property indicator_color1  clrLime,clrSpringGreen,clrLimeGreen,clrGreen,clrSaddleBrown,clrChocolate,clrTan,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2





//:::::::::::::::::::::::::::::::::::::::::::::::

input int Length=20;
input double Multiplier=0.125;
input bool Show_Lines=true;

double OP1[], OP2[], OP3[], OP4[], ON1[], ON2[], ON3[], ON4[];

int OnInit()
{
  //:::::::::::::::::::::::::::::::::::::::::::::
  double Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
  double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  int Bars=Bars(Symbol(),PERIOD_CURRENT);
  double Point=Point();
  //Etc.
  //:::::::::::::::::::::::::::::::::::::::::::::::

 //IndicatorShortName("Murreys Math oscillator");
 //IndicatorDigits(Digits);
 
 SetIndexBuffer(0,OP1,INDICATOR_DATA);
 SetIndexBuffer(1,OP2,INDICATOR_DATA);
 SetIndexBuffer(2,OP3,INDICATOR_DATA);
 SetIndexBuffer(3,OP4,INDICATOR_DATA);
 SetIndexBuffer(4,ON1,INDICATOR_DATA);
 SetIndexBuffer(5,ON2,INDICATOR_DATA);
 SetIndexBuffer(6,ON3,INDICATOR_DATA);
 SetIndexBuffer(7,ON4,INDICATOR_DATA);
 
 //if (Show_Lines)
 //{
 // SetLevelValue(0, 2.*Multiplier);
 // SetLevelValue(1, 4.*Multiplier);
 // SetLevelValue(2, 6.*Multiplier);
 // SetLevelValue(3, 8.*Multiplier);
 // SetLevelValue(4, -2.*Multiplier);
 // SetLevelValue(5, -4.*Multiplier);
 // SetLevelValue(6, -6.*Multiplier);
 // SetLevelValue(7, -8.*Multiplier);
 //}
 return(0);
}

int OnDeinit()
{


 return(0);
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
  //:::::::::::::::::::::::::::::::::::::::::::::
  double Ask=SymbolInfoDouble(Symbol(),SYMBOL_ASK);
  double Bid=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  int Bars=Bars(Symbol(),PERIOD_CURRENT);
  double Point=Point();
  //Etc.
  //:::::::::::::::::::::::::::::::::::::::::::::::

 if(Bars<=3) return(0);
 int ExtCountedBars=IndicatorCounted();
 if (ExtCountedBars<0) return(-1);
 int limit=Bars-2;
 if(ExtCountedBars>2) limit=Bars-ExtCountedBars-1;
 int pos;
 double Min, Max, Range;
 double MidLine;
 pos=limit;
 while(pos>=0)
 {
  Min=Low[iLowest(NULL, _Period, Length, pos)];
  Max=High[iHighest(NULL, _Period, Length, pos)];
  Range=Max-Min;
  MidLine=Min+Multiplier*Range*4.;
  
  if (Range!=0.)
  {
   OP1[pos]=2.*(Close[pos]-MidLine)/Range;
   OP2[pos]=0.; OP3[pos]=0.; OP4[pos]=0.; ON1[pos]=0.; ON2[pos]=0.; ON3[pos]=0.; ON4[pos]=0.;
   
   if (OP1[pos]>0.)
   {
    if (OP1[pos]>=6.*Multiplier)
    {
     OP4[pos]=OP1[pos];
    }
    else
    {
     if (OP1[pos]>=4.*Multiplier)
     {
      OP3[pos]=OP1[pos];
     }
     else
     {
      if (OP1[pos]>=2.*Multiplier)
      {
       OP2[pos]=OP1[pos];
      }
     }
    }
   }
   else
   {
    ON1[pos]=OP1[pos];
    if (OP1[pos]<=-6.*Multiplier)
    {
     ON4[pos]=OP1[pos];
    }
    else
    {
     if (OP1[pos]<=-4.*Multiplier)
     {
      ON3[pos]=OP1[pos];
     }
     else
     {
      if (OP1[pos]<=-2.*Multiplier)
      {
       ON2[pos]=OP1[pos];
      }
     }
    }
   }
  } 

  pos--;
 } 
   return(rates_total);
}

int iHighest(string symbol,ENUM_TIMEFRAMES tf,int count=WHOLE_ARRAY,int start=0)
  {
      double High[];
      ArraySetAsSeries(High,true);
      CopyHigh(symbol,tf,start,count,High);
      return(ArrayMaximum(High,0,count)+start);
     
     return(0);
}



int iLowest(string symbol,ENUM_TIMEFRAMES tf,int count=WHOLE_ARRAY,int start=0)
  {
      double Low[];
      ArraySetAsSeries(Low,true);
      CopyLow(symbol,tf,start,count,Low);
      return(ArrayMinimum(Low,0,count)+start);
     
     return(0);
}
