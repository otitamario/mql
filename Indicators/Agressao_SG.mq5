//#property copyright "Mario"
#property version "1.0"
#property strict

#property indicator_separate_window

#property indicator_buffers 5
#property indicator_plots 4

#include <Agress_CTicks.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eType
  {
   CumulativeDelta,//Cumulative Delta
   DeltaCandles,//Delta Candles
   Delta,//Delta
   Delta2,//Delta 2
   VolumePP //Volume ++ 
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum eMode
  {
   Auto,
   Raw
  };

input string TicksSymbol=""; //Ticks symbol (empty - current)
input int BarCalc=1; //Bars
input eType Type=CumulativeDelta; //Indicator type
input eMode Mode=Auto; //Analysis mode

input string DB_="-------------- Daily Balance Settings --------------"; //-------------- Daily Balance Settings --------------
input color DB_PositiveColor=clrLimeGreen; //Positive balance color
input color DB_NegativeColor=clrRed; //Negative balance color
input int DB_Width=4; //Width

input string VD_="-------------- Volume Delta Settings --------------"; //-------------- Volume Delta Settings --------------
input color VD_PositiveColor=clrLimeGreen; //Positive Delta color
input color VD_NegativeColor=clrRed; //Negative Delta color
input int VD_Width=4; //Width

input string VPP_="-------------- Volume++ Settings --------------"; //-------------- Volume++ Settings --------------
input color VPP_Color=clrSilver; //Volume color
input int VPP_Width=5; //Width
input color VPP_BuyColor=clrBlue; //Buyers volume color
input int VPP_BuyWidth=4; //Width
input color VPP_SellColor=clrMagenta; //Sellers volume color
input int VPP_SellWidth=3; //Width
input color VPP_NeutralColor=clrLime; //Neutrals volume color
input int VPP_NeutralWidth=2; //Width

double Buf0[],Buf1[],Buf2[],Buf3[],Buf4[];
string TicksSymbol_;
CTicks Ticks(_Symbol,_Period,COPY_TICKS_TRADE,-1,-1,UINT_MAX,0);
bool RepeatControl=false;
int ControlNum=WRONG_VALUE;
int RatesTotal;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(!ValidarConta())
     {
      string erro="Conta Inválida";
      MessageBox(erro);
      Print(erro);
      return(INIT_FAILED);
     }

   TicksSymbol_=TicksSymbol;
   StringTrimRight(TicksSymbol_);
   StringTrimLeft(TicksSymbol_);
   if(TicksSymbol_=="") TicksSymbol_=_Symbol;
   Ticks.SetSymbol(TicksSymbol_);

   IndicatorSetInteger(INDICATOR_DIGITS,0);

// indicator buffers
   SetIndexBuffer(0,Buf0,INDICATOR_DATA);
   ArraySetAsSeries(Buf0,false);

   SetIndexBuffer(1,Buf1,INDICATOR_DATA);
   ArraySetAsSeries(Buf1,false);

   SetIndexBuffer(2,Buf2,INDICATOR_DATA);
   ArraySetAsSeries(Buf2,false);

   SetIndexBuffer(3,Buf3,INDICATOR_DATA);
   ArraySetAsSeries(Buf3,false);

   SetIndexBuffer(4,Buf4,INDICATOR_COLOR_INDEX);
   ArraySetAsSeries(Buf4,false);

   switch(Type)
     {
      case CumulativeDelta:
         IndicatorSetString(INDICATOR_SHORTNAME,"Cumulative Delta("+_Symbol+")");
         PlotIndexSetString(0,PLOT_LABEL,"Agressao");
         PlotIndexSetInteger(0,PLOT_SHOW_DATA,true);
         PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_COLOR_HISTOGRAM);
         PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,2);
         PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,DB_PositiveColor);
         PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,DB_NegativeColor);
         PlotIndexSetInteger(0,PLOT_LINE_WIDTH,DB_Width);
         SetIndexBuffer(1,Buf1,INDICATOR_COLOR_INDEX);
         PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
         PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
         PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
         SetIndexBuffer(4,Buf4,INDICATOR_CALCULATIONS);
         break;
      case DeltaCandles:
         IndicatorSetString(INDICATOR_SHORTNAME,"Delta Candles("+_Symbol+")");
         PlotIndexSetString(0,PLOT_LABEL,"Delta Open;Delta High;Delta Low;Delta Close");
         PlotIndexSetInteger(0,PLOT_SHOW_DATA,true);
         PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_COLOR_CANDLES);
         PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,2);
         PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,VD_PositiveColor);
         PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,VD_NegativeColor);
         PlotIndexSetInteger(0,PLOT_LINE_WIDTH,VD_Width);
         break;
      case Delta:
         IndicatorSetString(INDICATOR_SHORTNAME,"Delta("+_Symbol+")");
         PlotIndexSetString(0,PLOT_LABEL,"Delta");
         PlotIndexSetInteger(0,PLOT_SHOW_DATA,true);
         PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_COLOR_HISTOGRAM);
         PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,2);
         PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,VD_PositiveColor);
         PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,VD_NegativeColor);
         PlotIndexSetInteger(0,PLOT_LINE_WIDTH,VD_Width);
         PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
         PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
         PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
         break;
      case Delta2:
         IndicatorSetString(INDICATOR_SHORTNAME,"Delta 2("+_Symbol+")");
         PlotIndexSetString(0,PLOT_LABEL,"Buyers");
         PlotIndexSetInteger(0,PLOT_SHOW_DATA,true);
         PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
         PlotIndexSetInteger(0,PLOT_LINE_COLOR,VD_PositiveColor);
         PlotIndexSetInteger(0,PLOT_LINE_WIDTH,VD_Width);
         PlotIndexSetString(1,PLOT_LABEL,"Sellers");
         PlotIndexSetInteger(1,PLOT_SHOW_DATA,true);
         PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
         PlotIndexSetInteger(1,PLOT_LINE_COLOR,VD_NegativeColor);
         PlotIndexSetInteger(1,PLOT_LINE_WIDTH,VD_Width);
         PlotIndexSetInteger(2,PLOT_SHOW_DATA,false);
         PlotIndexSetInteger(3,PLOT_SHOW_DATA,false);
         break;
      case VolumePP:
         IndicatorSetString(INDICATOR_SHORTNAME,"Volume ++("+_Symbol+")");
         PlotIndexSetString(0,PLOT_LABEL,"Volume");
         PlotIndexSetInteger(0,PLOT_SHOW_DATA,true);
         PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
         PlotIndexSetInteger(0,PLOT_LINE_COLOR,VPP_Color);
         PlotIndexSetInteger(0,PLOT_LINE_WIDTH,VPP_Width);
         PlotIndexSetString(1,PLOT_LABEL,"Buyers");
         PlotIndexSetInteger(1,PLOT_SHOW_DATA,true);
         PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
         PlotIndexSetInteger(1,PLOT_LINE_COLOR,VPP_BuyColor);
         PlotIndexSetInteger(1,PLOT_LINE_WIDTH,VPP_BuyWidth);
         PlotIndexSetString(2,PLOT_LABEL,"Sellers");
         PlotIndexSetInteger(2,PLOT_SHOW_DATA,true);
         PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
         PlotIndexSetInteger(2,PLOT_LINE_COLOR,VPP_SellColor);
         PlotIndexSetInteger(2,PLOT_LINE_WIDTH,VPP_SellWidth);
         PlotIndexSetString(3,PLOT_LABEL,"Neutral");
         PlotIndexSetInteger(3,PLOT_SHOW_DATA,true);
         PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_HISTOGRAM);
         PlotIndexSetInteger(3,PLOT_LINE_COLOR,VPP_NeutralColor);
         PlotIndexSetInteger(3,PLOT_LINE_WIDTH,VPP_NeutralWidth);
         break;
     }
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   RatesTotal=rates_total;

   if(prev_calculated>0)
     {
      // current
      if(rates_total>prev_calculated)
        {
         // new bar
         if(RepeatControl && ControlNum==rates_total-2)
           {
            CheckRepeated(ControlNum,time[ControlNum],ControlNum==0 ? 0 : time[ControlNum-1]);
           }
         RepeatControl=false;
         ControlNum=WRONG_VALUE;
        }
      if(!Ticks.GetTicks()) return(prev_calculated);
      Ticks.SetFrom();
      CalcCurrentBar(false,rates_total,time,volume);
     }
   else
     {
      // initialize
      ArrayInitialize(Buf0,0);
      ArrayInitialize(Buf1,0);
      ArrayInitialize(Buf2,0);
      ArrayInitialize(Buf3,0);
      ArrayInitialize(Buf4,EMPTY_VALUE);

      RepeatControl=false;
      ControlNum=WRONG_VALUE;

      // history
      Ticks.SetTime(0);
      Ticks.SetFrom(iTime(_Symbol, _Period, BarCalc));
      if(Ticks.GetFrom() <= 0) return(0);
      Ticks.SetTo(long(time[rates_total-1] *MS_KOEF-1));
      if(!Ticks.GetTicksRange()) return(0);
      CalcHistoryBars(rates_total,time,volume);

      // current
      Ticks.SetTime(0);
      Ticks.SetFrom(long(time[rates_total - 1] * MS_KOEF));
      Ticks.SetTo(long(TimeCurrent() * MS_KOEF));
      if(!Ticks.GetTicksRange()) return(0);
      Ticks.SetTo(ULONG_MAX);
      Ticks.SetFrom();
      CalcCurrentBar(true,rates_total,time,volume);

      //todo: BarCalc
      Ticks.SetCount(4000);
     }
   return (rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalcCurrentBar(const bool firstLaunch,const int rates_total,const datetime &time[],const long &volume[])
  {
   static long sumVolBuy=0,sumVolSell=0,sumVolNeutral=0;
   static int bNum=WRONG_VALUE;
   if(firstLaunch)
     {
      sumVolBuy=0;
      sumVolSell=0;
      sumVolNeutral=0;
      bNum=WRONG_VALUE;
     }

   const int limit=Ticks.GetSize()-1;
   const ulong limitTime=Ticks.GetFrom();

   for(int i=0; i<limit && !IsStopped(); i++)
     {
      if(Ticks.GetTickTimeMs(i) == limitTime) return;
      if(Ticks.GetTickTime(i)>=time[rates_total-1]+PeriodSeconds())
        {
         Ticks.SetFrom(Ticks.GetTickTimeMs(i));
         return;
        }
      if(Ticks.IsNewCandle(i))
        {
         if(bNum>=0)
           {
            if(sumVolBuy>0 || sumVolSell>0 || sumVolNeutral)
              {
               CheckVolume(true,bNum,volume[bNum],time[bNum],bNum==0 ? 0 : time[bNum-1],sumVolBuy,sumVolSell,sumVolNeutral);
              }
           }
         sumVolBuy=0;
         sumVolSell=0;
         bNum=rates_total-1;
        }
      AddVolume(Ticks.GetTick(i),bNum,time[bNum],bNum==0 ? 0 : time[bNum-1],sumVolBuy,sumVolSell,sumVolNeutral);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CalcHistoryBars(const int rates_total,const datetime &time[],const long &volume[])
  {
   long sumVolBuy=0;
   long sumVolSell=0;
   long sumVolNeutral=0;
   int bNum=WRONG_VALUE;

   const int limit=Ticks.GetSize();

   for(int i=0; i<limit && !IsStopped(); i++)
     {
      if(Ticks.IsNewCandle(i))
        {
         if(bNum>=0)
           {
            if(sumVolBuy>0 || sumVolSell>0)
              {
               CheckVolume(false,bNum,volume[bNum],time[bNum],bNum==0 ? 0 : time[bNum-1],sumVolBuy,sumVolSell,sumVolNeutral);
              }
           }
         sumVolBuy=0;
         sumVolSell=0;
         sumVolNeutral=0;
         bNum=Ticks.GetNumByTime(false);
         if(bNum >= rates_total || bNum < 0) return(false);
        }
      AddVolume(Ticks.GetTick(i),bNum,time[bNum],bNum==0 ? 0 : time[bNum-1],sumVolBuy,sumVolSell,sumVolNeutral);
     }
   if(sumVolBuy>0 || sumVolSell>0 || sumVolNeutral>0)
     {
      CheckVolume(false,bNum,volume[bNum],time[bNum],bNum==0 ? 0 : time[bNum-1],sumVolBuy,sumVolSell,sumVolNeutral);
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckRepeated(const int num,const datetime time,const datetime time1)
  {
   CTicks cTicks(TicksSymbol_,_Period,COPY_TICKS_TRADE,time*1000,(time+PeriodSeconds())*1000-1);
   if(!cTicks.GetTicksRange()) return(false);
   return (RecalcCandle(cTicks, num, time, time1));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool RecalcCandle(const CTicks &ticks,const int num,const datetime time,const datetime time1)
  {
   long controlVolume[1];
   if(!GetVolumeData(_Symbol, _Period, time, 1, controlVolume)) return(false);
   const int limit= ticks.GetSize()-1;
   long sumVolBuy = 0,sumVolSell = 0,sumVolNeutral = 0;
   for(int i=0; i<=limit; i++)
     {
      AddVolume(ticks.GetTick(i),num,time,time1,sumVolBuy,sumVolSell,sumVolNeutral);
     }
   return (controlVolume[0] != sumVolBuy + sumVolSell + sumVolNeutral);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool GetVolumeData(const string symbol,const ENUM_TIMEFRAMES timeframe,const datetime startTime,const int count,long &vol[])
  {
   ResetLastError();
   const int num=CopyRealVolume(symbol,timeframe,startTime,count,vol);
   if(num>0)
     {
      if(GetLastError() == 0) return(true);
      else
        {
         Print(__FUNCTION__,": Error #",GetLastError()," while copying "+symbol+" data");
         return(false);
        }
     }
   Print(__FUNCTION__,": Error #",GetLastError()," while getting "+symbol+" data");
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void AddVolume(const MqlTick &tick,const int num,const datetime time,const datetime time1,long &sumVolBuy,long &sumVolSell,long &sumVolNeutral)
  {
   if(num >= RatesTotal) return;
   double
   vol=(double)tick.volume,
   volBuy=0,
   volSell=0,
   volNeutral=0;
   if((tick.flags  &TICK_FLAG_BUY)==TICK_FLAG_BUY && (tick.flags  &TICK_FLAG_SELL)==TICK_FLAG_SELL)
     {
      volNeutral=vol;
      sumVolNeutral+=(long)vol;
     }
   else if((tick.flags  &TICK_FLAG_BUY)==TICK_FLAG_BUY)
     {
      volBuy=vol;
      sumVolBuy+=(long)vol;
     }
   else if((tick.flags  &TICK_FLAG_SELL)==TICK_FLAG_SELL)
     {
      volSell=vol;
      sumVolSell+=(long)vol;
     }

   double delta=volBuy-volSell;
   MqlDateTime t,t1;
   switch(Type)
     {
      case CumulativeDelta:
         TimeToStruct(time,t);
         TimeToStruct(time1,t1);
         if(Buf4[num]==EMPTY_VALUE) Buf4[num]=0;
         Buf4[num]+=delta;
         // day started
         if(time1==0 || t1.day_of_year<t.day_of_year)
           {
            Buf0[num]=Buf4[num];
           }
         else
           {
            if(Buf4[num-1]!=EMPTY_VALUE)
              {
               Buf0[num]=Buf0[num-1]+Buf4[num];
              }
            else
              {
               Buf0[num]=Buf4[num];
              }
           }
         Buf1[num]=Buf0[num]>0 ? 0 : 1;
         break;
      case DeltaCandles:
         if(delta>Buf1[num]) Buf1[num]=delta;
         if(Buf2[num]==0 || delta<Buf2[num]) Buf2[num]=delta;
         Buf3[num] = delta;
         Buf4[num] = delta > 0 ? 0 : 1;
         break;
      case Delta:
         Buf0[num]+= delta;
         Buf1[num] = Buf0[num] > 0 ? 0 : 1;
         break;
         break;
      case Delta2:
         Buf0[num]+= volBuy;
         Buf1[num]-= volSell;
         break;
      case VolumePP:
         Buf0[num]+= volBuy + volSell + volNeutral;
         Buf1[num]+= volBuy;
         Buf2[num]+= volSell;
         Buf3[num]+= volNeutral;
         break;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckVolume(const bool useControl,const int num,const long vol,const datetime time,const datetime time1,const long sumVolBuy,const long sumVolSell,const long sumVolNeutral)
  {
   if(vol == (sumVolBuy + sumVolSell + sumVolNeutral)) return;
   if(useControl)
     {
      if(CheckRepeated(num, time, time1)) return;
      RepeatControl=true;
      ControlNum=num;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ValidarConta()
  {
   long conta[5]={52393380,309305,60309305,9011600,11600};
   for(int i=0;i<ArraySize(conta);i++)
      if(AccountInfoInteger(ACCOUNT_LOGIN)==conta[i])return true;
   return false;
  }
//+------------------------------------------------------------------+
