//+------------------------------------------------------------------+
//|                                                  Correlation.mq5 |
//|                                               Copyright 2012, iC |
//|                                         http://www.icreator.biz/ |
//+------------------------------------------------------------------+
#property copyright "Copyright 2012, iC"
#property link      "http://www.icreator.biz/"
#property version   "1.2"
//--- indicator settings
#property indicator_separate_window
#property indicator_minimum -1
#property indicator_maximum 1
#property indicator_buffers 5
#property indicator_plots   2
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_width1  2
#property indicator_type2   DRAW_COLOR_HISTOGRAM
#property indicator_style2  STYLE_DOT
#property indicator_width2  1
//--- defines
#define MAX_COL 64
//--- structures
struct CRGB
  {
   int               r;
   int               g;
   int               b;
  };
//--- input parametres
input string _SecondSymbol="EURUSD";                   // Second symbol
input int _SettPeriod=20;                              // Period
input ENUM_APPLIED_PRICE _AppliedPrice=PRICE_WEIGHTED; // Price
input color _Color1=clrBlack;                          // Min correlation
input color _Color2=clrFireBrick;                      // Max correlation
//--- indicator buffers
double buf[],buf2[];
double arr1[],arr2[];
double colors1[],colors2[];
double a3[];
//--- MA handles
int h1,h2;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,buf);
   SetIndexBuffer(1,colors1,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,buf2);
   SetIndexBuffer(3,colors2,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,arr1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,arr2,INDICATOR_CALCULATIONS);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0);
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,0);
   IndicatorSetInteger(INDICATOR_DIGITS,3);
   IndicatorSetString(INDICATOR_SHORTNAME,_Symbol+"/"+_SecondSymbol+", "+IntegerToString(_SettPeriod)+", "+EnumToString(_AppliedPrice)+",");
   setPlotColor(0,_Color1,_Color2);
   setPlotColor(1,_Color1,_Color2);
   h1=iMA(_Symbol,0,1,0,MODE_SMA,_AppliedPrice);
   h2=iMA(_SecondSymbol,0,1,0,MODE_SMA,_AppliedPrice);
   ArrayResize(a3,_SettPeriod*2);
   return 0;
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
   int i,j,c,limit,bars1,bars2;
   double averX1=0,averX2=0,v1=0,v2=0,v3=0;
   double a1[1],a2[1];
   datetime tm[1];
   bool cont=false;
//---
   if(prev_calculated>rates_total || 
      prev_calculated<=0)
     {
      limit=_SettPeriod-1;
      //---
      ArrayInitialize(buf,0);
      ArrayInitialize(buf2,0);
      //--- check symbol
      if(!SymbolSelect(_SecondSymbol,true))
        {
         printf("Wrong symbol! [ %s ]",_SecondSymbol);
         return 0;
        }
      //--- check for data
      bars1=Bars(_Symbol,0);
      bars2=Bars(_SecondSymbol,0);
      if(bars1==0 || bars2==0)
        {
         Print("The data is not formed yet! Wait...");
         return 0;
        }
      else if(bars1<_SettPeriod || 
         bars2<_SettPeriod)
           {
            Print("Bars is not enough to calculate!");
            return 0;
           }
         if(BarsCalculated(h1)<bars1)
           {
            printf("Not all data of MA is calculated. Error %i. [ %s ]",GetLastError(),_Symbol);
            return 0;
           }
      if(BarsCalculated(h2)<bars2)
        {
         printf("Not all data of MA is calculated. Error %i. [ %s ]",GetLastError(),_SecondSymbol);
         return 0;
        }
      //--- synchronization bars
      if(CopyTime(_SecondSymbol,0,bars2-1,1,tm)<=0)
        {
         Print("Error copying time.");
         return 0;
        }
      for(i=0;i<bars1;i++)
        {
         if(time[i]>=tm[0])
           {
            limit=i+_SettPeriod-1;
            break;
           }
        }
     }
   else
      limit=prev_calculated-1;
//---     
   for(i=limit;i<rates_total;i++)
     {
      averX1=0;
      averX2=0;
      for(j=0;j<_SettPeriod;j++)
        {
         if(CopyBuffer(h1,0,time[i-j],1,a1)<=0 ||
            CopyBuffer(h2,0,time[i-j],1,a2)<=0)
           {,            
            i+=_SettPeriod-j-1;
            cont=true;
            break;
           }
         a3[j]=a1[0];
         a3[_SettPeriod+j]=a2[0];
         averX1+=a1[0]/_SettPeriod;
         averX2+=a2[0]/_SettPeriod;
        }
      if(cont)
        {
         cont=false;
         continue;
        }
      v1=0;
      v2=0;
      v3=0;
      for(j=0;j<_SettPeriod;j++)
        {
         v1+=(a3[j]-averX1)*(a3[_SettPeriod+j]-averX2);
         v2+=pow((a3[j]-averX1),2);
         v3+=pow((a3[_SettPeriod+j]-averX2),2);
        }
      if(v1==0 || v2==0 || v3==0)
         return 0;
      buf[i]=v1/sqrt(v2*v3);
      buf2[i]=buf[i];
      c=getPlotColor(buf[i]);
      colors1[i]=c;
      colors2[i]=c;
     }
   return rates_total;
  }
//+------------------------------------------------------------------+
//| setPlotColor                                                     |
//+------------------------------------------------------------------+
void setPlotColor(int plot,color col1,color col2)
  {
   int i;
   CRGB c1,c2;
   double dr,dg,db;
   string s;
//---    
   PlotIndexSetInteger(plot,PLOT_COLOR_INDEXES,MAX_COL);
   ColorToRGB(col1,c1);
   ColorToRGB(col2,c2);
   dr=(double)(c2.r-c1.r)/MAX_COL;
   dg=(double)(c2.g-c1.g)/MAX_COL;
   db=(double)(c2.b-c1.b)/MAX_COL;
   for(i=0;i<MAX_COL;i++)
     {
      s=StringFormat("%i,%i,%i",
                     c1.r+(int)NormalizeDouble(dr*(i+1),0),
                     c1.g+(int)NormalizeDouble(dg*(i+1),0),
                     c1.b+(int)NormalizeDouble(db*(i+1),0));
      PlotIndexSetInteger(plot,PLOT_LINE_COLOR,i,StringToColor(s));
     }
  }
//+------------------------------------------------------------------+
//| getPlotColor                                                     |
//+------------------------------------------------------------------+
int getPlotColor(double current)
  {
   return((int)NormalizeDouble((MAX_COL-1)*fabs(current),0));
  }
//+------------------------------------------------------------------+
//| ColorToRGB                                                       |
//+------------------------------------------------------------------+
void ColorToRGB(color col,CRGB &res)
  {
   string s,s2;
   int n;
//---
   s=ColorToString(col);
   n=StringFind(s,",");
   s2=StringSubstr(s,0,n);
   res.r=(int)StringToInteger(s2);
   s=StringSubstr(s,n+1);
   n=StringFind(s,",");
   s2=StringSubstr(s,0,n);
   res.g=(int)StringToInteger(s2);
   s=StringSubstr(s,n+1);
   s2=StringSubstr(s,0);
   res.b=(int)StringToInteger(s2);
  }
//+------------------------------------------------------------------+
