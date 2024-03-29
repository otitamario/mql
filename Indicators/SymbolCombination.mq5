//+------------------------------------------------------------------+
//|                                            SymbolCombination.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window

#property indicator_buffers 4
#property indicator_plots   4
#property indicator_type1   DRAW_LINE
#property indicator_color1  Red
#property indicator_width1  1
#property indicator_type2   DRAW_LINE
#property indicator_color2  Green
#property indicator_width2  1
#property indicator_type3   DRAW_LINE
#property indicator_color3  Yellow
#property indicator_width3  1
#property indicator_type4   DRAW_LINE
#property indicator_color4  Yellow
#property indicator_width4  1
#include <Math\Stat\Math.mqh> 
  
input int Inp_Period=200;
input double Inp_delta=2.5;
input double Inp_Coef_PETR4=1.0;
input double Inp_Coef_VALE3=1.0;
input double Inp_Coef_ITUB4=1.0;
input double Inp_Coef_BBAS3=1.0;
input double Inp_Coef_USIM5=1.0;
input double Inp_Coef_GGBR4=1.0;
input double Inp_Coef_BBDC4=1.0;


#define SYMBOLS_COUNT   7 // Number of symbols


double price_combination[];
double ma_price[];
double up_price[];
double down_price[];

string symbol_names[SYMBOLS_COUNT]={"PETR4","VALE3","ITUB4","BBAS3","USIM5","GGBR4","BBDC4"};
double symbol_coef[SYMBOLS_COUNT];
double points[SYMBOLS_COUNT];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,price_combination,INDICATOR_DATA);
   SetIndexBuffer(1,ma_price,INDICATOR_DATA);
   SetIndexBuffer(2,up_price,INDICATOR_DATA);
   SetIndexBuffer(3,down_price,INDICATOR_DATA);
//---
   for(int i=0;i<SYMBOLS_COUNT;i++)
     {
         //--- add it to the Market Watch window and
      SymbolSelect(symbol_names[i],true);
      points[i]=SymbolInfoDouble(symbol_names[i],SYMBOL_POINT);
     }

    symbol_coef[0]=Inp_Coef_PETR4;
    symbol_coef[1]=Inp_Coef_VALE3;
    symbol_coef[2]=Inp_Coef_ITUB4;
    symbol_coef[3]=Inp_Coef_BBAS3;
    symbol_coef[4]=Inp_Coef_USIM5;
    symbol_coef[5]=Inp_Coef_GGBR4;
    symbol_coef[6]=Inp_Coef_BBDC4;
   

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,      // 输入时间序列大小 
                 const int prev_calculated,  // 前一次调用处理的柱 
                 const datetime& time[],     // 时间 
                 const double& open[],       // 开盘价 
                 const double& high[],       // 最高价 
                 const double& low[],        // 最低价 
                 const double& close[],      // 收盘价 
                 const long& tick_volume[],  // 订单交易量 
                 const long& volume[],       // 真实交易量 
                 const int& spread[]         )
  {
//---
   int limit=0;
   double close_price[1];
      
   if(prev_calculated==0)
     {
      price_combination[0]=0;
      ma_price[0]=0;
      up_price[0]=0;
      down_price[0]=0;
      for(int i=1;i<rates_total;i++)
        {
         double price_sum=0;
         for(int j=0;j<SYMBOLS_COUNT;j++)
           {
            CopyClose(symbol_names[j],_Period,time[i],1,close_price);
            price_sum+=close_price[0]*symbol_coef[j]/points[j];
           }
          price_combination[i]=price_sum;
          if(i<Inp_Period)
           {
            ma_price[i]=0;
            up_price[i]=0;
            down_price[i]=0;
           }
          else
            {
             double temp_price[];
             ArrayCopy(temp_price,price_combination,0,i-Inp_Period,Inp_Period);
             double std=MathStandardDeviation(temp_price);
             ma_price[i]=MathMean(temp_price);
             up_price[i]=ma_price[i]+Inp_delta*std;
             down_price[i]=ma_price[i]-Inp_delta*std;
            }
        }
     }
   else
     {
      limit=prev_calculated-1;
     }
   for(int i=limit;i<rates_total;i++)
     {
      double price_sum=0;
      for(int j=0;j<SYMBOLS_COUNT;j++)
        {
         CopyClose(symbol_names[j],_Period,time[i],1,close_price);
         price_sum+=close_price[0]*symbol_coef[j]/points[j];
        }
      price_combination[i]=price_sum; 
      if(i<Inp_Period)
           {
            ma_price[i]=0;
            up_price[i]=0;
            down_price[i]=0;
           }
       else
         {
          double temp_price[];
          ArrayCopy(temp_price,price_combination,0,i-Inp_Period,Inp_Period);
          double std=MathStandardDeviation(temp_price);
          ma_price[i]=MathMean(temp_price);
          up_price[i]=ma_price[i]+Inp_delta*std;
          down_price[i]=ma_price[i]-Inp_delta*std;
         }
     }
   
   return rates_total;
  }
//+------------------------------------------------------------------+

