//+------------------------------------------------------------------+
//|                                      TwoSymbolCointergration.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window

#property indicator_buffers 3
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_width1  1
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum CointergrationCalType
  {
   ENUM_COINTERGRATION_TYPE_PLUS=1,//Adição
   ENUM_COINTERGRATION_TYPE_MINUS=2,//Subtração
   ENUM_COINTERGRATION_TYPE_MULTIPLY=3,//Multiplicação
   ENUM_COINTERGRATION_TYPE_DIVIDE=4,//Divisão
                                     //ENUM_COINTERGRATION_TYPE_LINEAR_FIXED=5,
   //ENUM_COINTERGRATION_TYPE_LINEAR_FREE=6,
   //ENUM_COINTERGRATION_TYPE_GARCH=7,
   ENUM_COINTERGRATION_TYPE_LOG_DIFF=8//Diferença de Logaritmos
  };

input string Inp_Minor_Symbol="PETR4";
input CointergrationCalType Inp_Cal_Type=ENUM_COINTERGRATION_TYPE_DIVIDE;

double price_combine[];
double price_main_symbol[];
double price_minor_symbol[];
int plot_begin;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- indicator buffers mapping
   SetIndexBuffer(0,price_combine,INDICATOR_DATA);
   SetIndexBuffer(1,price_main_symbol,INDICATOR_CALCULATIONS);
   SetIndexBuffer(2,price_minor_symbol,INDICATOR_CALCULATIONS);

   plot_begin=MathMin(Bars(_Symbol,_Period),Bars(Inp_Minor_Symbol,_Period));

   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,plot_begin);

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
   int limit;

   if(prev_calculated==0)
     {
      for(int i=0;i<rates_total;i++)
        {
         double price_minor[];
         while(CopyClose(Inp_Minor_Symbol,_Period,time[i],1,price_minor)==-1)
            Sleep(1000);
         //Print("Copy Close on-going");
         price_main_symbol[i]=close[i];
         price_minor_symbol[i]=price_minor[0];
         price_combine[i]=CalCointergration(price_main_symbol[i],price_minor_symbol[i]);
        }
      //limit=0;
      limit=0;
     }
   else
      limit=prev_calculated-1;

   for(int i=limit;i<rates_total;i++)
     {
      double price_minor[];
      while(CopyClose(Inp_Minor_Symbol,_Period,time[i],1,price_minor)==-1)
         Sleep(1000);
      //Print("Copy Close on-going");
      price_main_symbol[i]=close[i];
      price_minor_symbol[i]=price_minor[0];
      price_combine[i]=CalCointergration(price_main_symbol[i],price_minor_symbol[i]);
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

double CalCointergration(double x,double y)
  {
   double res;
   switch(Inp_Cal_Type)
     {
      case ENUM_COINTERGRATION_TYPE_PLUS: res=x+y; break;
      case ENUM_COINTERGRATION_TYPE_MULTIPLY: res=x*y; break;
      case ENUM_COINTERGRATION_TYPE_MINUS: res=x-y; break;
      case ENUM_COINTERGRATION_TYPE_DIVIDE:res=x/y; break;
      case ENUM_COINTERGRATION_TYPE_LOG_DIFF:res=log(x)-log(y);break;
      default:Print("Cointergration type not defined! Use plus method instead!");res=x+y; break;
     }
   return res;
  }
//+------------------------------------------------------------------+
