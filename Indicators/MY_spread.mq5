//+------------------------------------------------------------------+
//|                                                      iSpread.mq5 |
//|                                                    A.V. Oreshkin |
//|                                                   vk.com/mtforex |
//+------------------------------------------------------------------+
#property copyright "A.V. Oreshkin"
#property link      "vk.com/mtforex"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers   17
#property indicator_plots     8
#property indicator_label1    "Ratio";
#property indicator_color1    clrBlue
#property indicator_style1    STYLE_SOLID
#property indicator_type1     DRAW_LINE
#property indicator_width1    2
#property indicator_label2    "Mean Line";
#property indicator_color2    clrAqua
#property indicator_style2    STYLE_SOLID
#property indicator_type2     DRAW_LINE
#property indicator_width2    1
#property indicator_label3    "Upper Band";
#property indicator_color3    clrAqua
#property indicator_style3    STYLE_SOLID
#property indicator_type3    DRAW_LINE
#property indicator_width3    1
#property indicator_label4    "Lower Band";
#property indicator_color4    clrAqua
#property indicator_style4    STYLE_SOLID
#property indicator_type4     DRAW_LINE
#property indicator_width4    1
#property indicator_level1    0

#property indicator_type5  DRAW_LINE
#property indicator_color5 clrOrangeRed
#property indicator_style5 STYLE_DOT
#property indicator_width5 2
#property indicator_label5 "H2 Band"

#property indicator_type6  DRAW_LINE
#property indicator_color6 clrOrangeRed
#property indicator_style6 STYLE_DOT
#property indicator_width6 2
#property indicator_label6 "L2 Band"

#property indicator_type7  DRAW_LINE
#property indicator_color7 clrYellow
#property indicator_style7 STYLE_DOT
#property indicator_width7 2
#property indicator_label7 "H3 Band"

#property indicator_type8  DRAW_LINE
#property indicator_color8 clrYellow
#property indicator_style8 STYLE_DOT
#property indicator_width8 2
#property indicator_label8 "L3 Band"




#include <MovingAverages.mqh>
//+------------------------------------------------------------------+
//| enum MOVE                                                        |
//+------------------------------------------------------------------+
enum MOVE
  {
   Subtract=1,  //Difference
   Add=2,       //Sum   
   Multiply=3,  //Product
   Divizion=4   //Ratio
  };
//+------------------------------------------------------------------+
//| enum DET                                                         |
//+------------------------------------------------------------------+
enum DET
  {
   Returns=1,   //The first difference
   DeTrend=2    //Detrend using a simple MA
  };
//+------------------------------------------------------------------+
//| enum LVL                                                         |
//+------------------------------------------------------------------+
input datetime BeginTime=D'2013.01.01'; //Date to start
input string   Symbol1        =  "WIN$N";      //Symbol 1
input string   Symbol2        =  "WDO$N";      //Symbol 2
input MOVE     Action         =  Divizion;      //Action
input bool     Invert1        =  false;         //Reverse of symbol 1
input bool     Invert2        =  false;         //Reverse of symbol 2
input double   Pow1           =  1;             //Power of symbol 1
input double   Pow2           =  1;             //Power of symbol 2
input double   Multi1         =  1;             //Multiplier of symbol 1
input double   Multi2         =  1;             //Multiplier of symbol 2
input bool     Ln             =  false;         //The logarithm
input uint     Average        =  3;             //Smoothing.Period
input DET      Algo           =  DeTrend;       //Selecting an algorithm
input uint     Window         =  100;           //Period for the algorithm

input int      BandsPeriod    =  20;            //Periodo para as BB
input double   BandsDev       =  2.0;           //Desvio Padrao para as BB
input double   DesvioPerna2=3.0; // Desvio Perna2
input double   DesvioPerna3=4.0; // Desvio Perna3



bool     Error_Init=true;
datetime BeginDate=0;
double   BF[], //The final array for the output
PR1[],PR2[],   //Arrays of initial data after mathematical processing
PRA1[],PRA2[], //Arrays PR1 and PR2 smoothed by a MA
CALC[],        //Output here either after a detrend or after the first difference
DTR[],         //An array after detrend
LG1[],LG2[],   //An array for first differences
max,min;       //Extreme for normalization
double UB[],ML[],LB[],STDDEV[],Sup_Buffer2[],Inf_Buffer2[],Sup_Buffer3[],Inf_Buffer3[]; // Arrays para as bandas de bollinger

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   Error_Init=true;
   LOAD_DATA();
   max=-10000;min=10000;
   IndicatorSetString(INDICATOR_SHORTNAME,NAME());
   SetIndexBuffer(0,BF,INDICATOR_DATA);
   SetIndexBuffer(1,ML,INDICATOR_DATA);
   SetIndexBuffer(2,UB,INDICATOR_DATA);
   SetIndexBuffer(3,LB,INDICATOR_DATA);
   SetIndexBuffer(4,Sup_Buffer2,INDICATOR_DATA);
   SetIndexBuffer(5,Inf_Buffer2,INDICATOR_DATA);
   SetIndexBuffer(6,Sup_Buffer3,INDICATOR_DATA);
   SetIndexBuffer(7,Inf_Buffer3,INDICATOR_DATA);
   SetIndexBuffer(8,PR1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,PR2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,PRA1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,PRA2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,CALC,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,DTR,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,LG1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(15,LG2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(16,STDDEV,INDICATOR_CALCULATIONS);

//---
   ArraySetAsSeries(BF,false);
   ArraySetAsSeries(PR1,false);
   ArraySetAsSeries(PR2,false);
   ArraySetAsSeries(PRA1,false);
   ArraySetAsSeries(PRA2,false);
   ArraySetAsSeries(CALC,false);
   ArraySetAsSeries(DTR,false);
   ArraySetAsSeries(LG1,false);
   ArraySetAsSeries(LG2,false);

   IndicatorSetInteger(INDICATOR_DIGITS,4);

   ZeroMemory(BF);
   ZeroMemory(UB);
   ZeroMemory(ML);
   ZeroMemory(LB);
   ZeroMemory(STDDEV);

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
   if(Error_Init) LOAD_DATA();
   if(Error_Init) return(INIT_FAILED); //Initialization error

   double pr1[1],pr2[1];
   int x1,x2;
   int limit=prev_calculated;
   if(limit>1) limit=limit-2;

//--- step 1 - data preparation
   for(int pos=1+limit;pos<rates_total;pos++)
     {//preparing initial data
      if(time[pos]<BeginDate)
        {
         EMTF(pos);
         continue;
        }
      //---
      x1=CopyClose(Symbol1,PERIOD_CURRENT,time[pos],1,pr1);
      x2=CopyClose(Symbol2,PERIOD_CURRENT,time[pos],1,pr2);
      if(x1<=0 || x2<=0)
        {
         EMTF(pos);
         Print("Data omission: "+string(time[pos]));
         continue;
        }
      if(pr1[0]==0 || pr2[0]==0)
        {
         EMTF(pos);
         Print("Zero data received: "+string(time[pos]));
         continue;
        }

      PR1[pos]=MODIFY(pr1[0],Invert1,Pow1,Multi1);
      PR2[pos]=MODIFY(pr2[0],Invert2,Pow2,Multi2);
     }//preparing initial data

//--- smoothing the received data
   if(Average>1) for(int pos=1+limit;pos<rates_total;pos++) MA(pos);
   else
     {
      ArrayCopy(PRA1,PR1,0,0,WHOLE_ARRAY);
      ArrayCopy(PRA2,PR2,0,0,WHOLE_ARRAY);
     }
//--- merge two arrays into one
   for(int pos=1+limit;pos<rates_total;pos++) CALC[pos]=ACTION(PRA1[pos],PRA2[pos]);

//--- Data preparation completed. Next - the converting and getting the synthetic
//--- step 2 - creating the synthetic symbol
//--- depending on what we select, either detrend using the MA or calculate the difference
   if(Algo==DeTrend && Window>1)
     {
      for(int pos=1+limit;pos<rates_total;pos++)
        {
         DT(pos);
         if(DTR[pos]==EMPTY_VALUE)BF[pos]=EMPTY_VALUE;
         else BF[pos]=DTR[pos];
        }
     }
   else
   if(Algo==Returns && Window>0)
     {
      for(int pos=1+limit;pos<rates_total;pos++)
        {
         LAG(pos);
         if(LG1[pos]==EMPTY_VALUE || LG2[pos]==EMPTY_VALUE) BF[pos]=EMPTY_VALUE;
         else BF[pos]=LG1[pos]/LG2[pos]-1;

        }
     }

   else  ArrayCopy(BF,CALC,0,0,WHOLE_ARRAY);

   for(int pos=1+limit;pos<rates_total;pos++)
     {
      //--- middle line
      ML[pos]=SimpleMA(pos,BandsPeriod,BF);
      //--- calculate and write down StdDev
      STDDEV[pos]=StdDev_Func(pos,BF,ML,BandsPeriod);
      //--- upper line
      UB[pos]=ML[pos]+BandsDev*STDDEV[pos];
      //--- lower line
      LB[pos]=ML[pos]-BandsDev*STDDEV[pos];
               Sup_Buffer2[pos]=ML[pos]+DesvioPerna2*STDDEV[pos];
         //--- lower line
         Inf_Buffer2[pos]=ML[pos]-DesvioPerna2*STDDEV[pos];

         Sup_Buffer3[pos]=ML[pos]+DesvioPerna3*STDDEV[pos];
         //--- lower line
         Inf_Buffer3[pos]=ML[pos]-DesvioPerna3*STDDEV[pos];

     }


   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Changing the price                                               |
//+------------------------------------------------------------------+
double MODIFY(double in,bool inv,double pw,double ml)
  {
   if(inv) in=1/in;
   in=MathPow(in,pw)*ml;
   if(Ln) in=MathLog(in);
   return(in);
  }
//+------------------------------------------------------------------+
//| Mathematical action                                              |
//+------------------------------------------------------------------+
double ACTION(double in1,double in2)
  {
   if(in1==EMPTY_VALUE || in2==EMPTY_VALUE) return(EMPTY_VALUE);
   switch(Action)
     {
      case 1: return(in1-in2);
      case 2: return(in1+in2);
      case 3: return(in1*in2);
      case 4: return(in1/in2);
     }
   return(in1/in2);
  }
//+------------------------------------------------------------------+
//| Loading the required data                                        |
//+------------------------------------------------------------------+
bool LOAD_DATA()
  {
   string txt=TimeToString(TimeLocal(),TIME_SECONDS);
   if(!SymbolSelect(Symbol1,true))
     {
      txt=txt+"\nUnavailable "+Symbol1;
      Comment(txt);
      return(true);
     }
   if(!SymbolSelect(Symbol2,true))
     {
      txt=txt+"\nUnavailable "+Symbol2;
      Comment(txt);
      return(true);
     }
   int smb=int(Window)*2;
   if(Bars(Symbol1,PERIOD_CURRENT)<=smb)
     {
      txt=txt+"\nNot enough data of the first symbol";
      Comment(txt);
      return(true);
     }
   if(Bars(Symbol2,PERIOD_CURRENT)<=smb)
     {
      txt=txt+"\nNot enough data of the second symbol";
      Comment(txt);
      return(true);
     }
   datetime temp[1];
   if(CopyTime(Symbol1,PERIOD_CURRENT,Bars(Symbol1,PERIOD_CURRENT)-1,1,temp)<=0)
     {
      txt=txt+"\nGetting the date of the first symbol";
      Comment(txt);
      return(true);
     }
   BeginDate=MathMax(BeginTime,temp[0]);
   if(CopyTime(Symbol2,PERIOD_CURRENT,Bars(Symbol2,PERIOD_CURRENT)-1,1,temp)<=0)
     {
      txt=txt+"\nGetting the date of the second symbol";
      Comment(txt);
      return(true);
     }
   BeginDate=MathMax(BeginDate,temp[0]);
   Comment("");
   Error_Init=false;
   return(false);
  }
//+------------------------------------------------------------------+
//| Assigning an empty value to all arrays at the current position   |
//+------------------------------------------------------------------+
void EMTF(int i)
  {
   BF[i]=EMPTY_VALUE;
   CALC[i]=EMPTY_VALUE;
   PR1[i]=EMPTY_VALUE;
   PR2[i]=EMPTY_VALUE;
   PRA1[i]=EMPTY_VALUE;
   PRA2[i]=EMPTY_VALUE;
   DTR[i]=EMPTY_VALUE;
   LG1[i]=EMPTY_VALUE;
   LG2[i]=EMPTY_VALUE;
  }
//+------------------------------------------------------------------+
//| Averaging initial data using a simple MA with the Average period |
//+------------------------------------------------------------------+
void MA(int pos)
  {
//--- if we get EMPTY_VALUE, return it
   if(pos<=(int)Average || PR1[pos]==EMPTY_VALUE || PR1[pos]==EMPTY_VALUE)
     {
      PRA1[pos]=EMPTY_VALUE;
      PRA2[pos]=EMPTY_VALUE;
      return;
     }
//--- average the first series. Simple arithmetic average
   int x1=1;
   double temp=PR1[pos];
   for(int j=1;j<(int)Average;j++)
      if(PR1[pos-j]!=EMPTY_VALUE)
        {
         temp+=PR1[pos-j];
         x1++;
        }
   temp=temp/(double)x1;
   PRA1[pos]=temp;

//--- average the second series. Simple arithmetic average
   x1=1;
   temp=PR2[pos];
   for(int j=1;j<(int)Average;j++)
      if(PR2[pos-j]!=EMPTY_VALUE)
        {
         temp+=PR2[pos-j];
         x1++;
        }
   temp=temp/(double)x1;
   PRA2[pos]=temp;
  }
//+------------------------------------------------------------------+
//| Detrending the series                                            |
//+------------------------------------------------------------------+
void DT(int pos)
  {
   if(pos<=int(Average+Window) || CALC[pos]==EMPTY_VALUE)
     {
      DTR[pos]=EMPTY_VALUE;
      return;
     }
//--- averaging the price series.
   int x1=1;
   double temp=CALC[pos];
   for(int j=1;j<(int)Window;j++)
      if(CALC[pos-j]!=EMPTY_VALUE)
        {
         temp+=CALC[pos-j];
         x1++;
        }
   temp=temp/(double)x1;
   DTR[pos]=CALC[pos]-temp;
  }
//+------------------------------------------------------------------+
//| Calculate first differences (I use ratio not difference)         |
//+------------------------------------------------------------------+
void LAG(int pos)
  {
   if(pos<=int(Average+Window) || PRA1[pos]==EMPTY_VALUE || PRA2[pos]==EMPTY_VALUE || 
      PRA1[pos-Window]==EMPTY_VALUE || PRA2[pos-Window]==EMPTY_VALUE)
     {
      LG1[pos]=EMPTY_VALUE;
      LG2[pos]=EMPTY_VALUE;
      return;
     }
   if(PRA1[pos-Window]!=0) LG1[pos]=PRA1[pos]/PRA1[pos-Window];
   else LG1[pos]=PRA1[pos];
   if(PRA2[pos-Window]!=0) LG2[pos]=PRA2[pos]/PRA2[pos-Window];
   else LG2[pos]=PRA2[pos];
  }
//+------------------------------------------------------------------+
//| Make up the indicator name                                       |
//+------------------------------------------------------------------+
string NAME()
  {
   string name="";
   if(Invert1) name="(inv)"+Symbol1;
   else name=Symbol1;
   switch(Action)
     {
      case 1: name=name+"-";break;
      case 2: name=name+"+";break;
      case 3: name=name+"*";break;
      case 4: name=name+"/";break;
     }
   if(Invert2) name=name+"(inv)"+Symbol2;
   else name=name+Symbol2;
   return(name);
  }
//+------------------------------------------------------------------+
double StdDev_Func(int position,const double &price[],const double &MAprice[],int period)
  {
//--- variables
   double StdDev_dTmp=0.0;
//--- check for position
   if(position<period) return(StdDev_dTmp);
//--- calcualte StdDev
   for(int i=0;i<period;i++) StdDev_dTmp+=MathPow(price[position-i]-MAprice[position],2);
   StdDev_dTmp=MathSqrt(StdDev_dTmp/period);
//--- return calculated value
   return(StdDev_dTmp);
  }
//+------------------------------------------------------------------+
