//+------------------------------------------------------------------+
//|                                         FX5_SelfAdjustingRSI.mq5 | 
//|                                            Copyright � 2008, FX5 | 
//|                                                    hazem@uk2.net | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright � 2008, FX5"
#property link "hazem@uk2.net"
#property description ""
//---- ����� ������ ����������
#property version   "1.00"
//---- ��������� ���������� � ��������� ����
#property indicator_separate_window
//---- ���������� ������������ ������� 4
#property indicator_buffers 4 
//---- ������������ ����� ��� ����������� ����������
#property indicator_plots   3
//+-----------------------------------+
//| ��������� ��������� ����������    |
//+-----------------------------------+
//---- ��������� ���������� � ���� �����
#property indicator_type1   DRAW_LINE
//---- � �������� ����� ����� ���������� ����������� DodgerBlue ����
#property indicator_color1 clrDodgerBlue
//---- ����� ���������� - �������� ������
#property indicator_style1  STYLE_SOLID
//---- ������� ����� ���������� ����� 2
#property indicator_width1  2
//---- ����������� ����� ����������
#property indicator_label1  "RSI"
//+--------------------------------------------+
//| ��������� ��������� ���������� BB �������  |
//+--------------------------------------------+
//---- ��������� ������� ����������� � ���� �����
#property indicator_type2   DRAW_LINE
#property indicator_type3   DRAW_LINE
//---- ������ ������ ������� �����������
#property indicator_color2  clrMediumSeaGreen
#property indicator_color3  clrMagenta
//---- ������ ����������� - �������� ������
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID
//---- ������� ������� ����������� ����� 2
#property indicator_width2  2
#property indicator_width3  2
//---- ����������� ����� ������� �����������
#property indicator_label2  "OverBought"
#property indicator_label3  "OverSold"
//+----------------------------------------------+
//| ��������� ����������� �������������� ������� |
//+----------------------------------------------+
#property indicator_level1 80.0
#property indicator_level2 50.0
#property indicator_level3 20.0
#property indicator_levelcolor clrBlueViolet
#property indicator_levelstyle STYLE_DASHDOTDOT
//+-----------------------------------+
//| ���������� ��������               |
//+-----------------------------------+
#define RESET  0 // ��������� ��� �������� ��������� ������� �� �������� ����������
//+-----------------------------------+
//| ������� ��������� ����������      |
//+-----------------------------------+
input uint Length=12; // ������ RSI
input ENUM_APPLIED_PRICE   RSIPrice=PRICE_CLOSE; // ���� ��������� RSI
input double BandsDeviation=2.0; // ��������
input bool MA_Method=true; // ������������ ����������� ��� �����������
input int Shift=0; // ����� ���������� �� ����������� � �����
//+-----------------------------------+
//---- ���������� ������������ ��������, ������� ����� � 
//---- ���������� ������������ � �������� ������������ �������
double ExtLineBuffer[],ExtLineBuffer1[],ExtLineBuffer2[],ExtCalcBuffer[];
//---- ���������� ������������� ���������� ������ ������� ������
int min_rates_total,min_rates_;
//---- ���������� ������������� ���������� ��� ������� �����������
int RSI_Handle,STD_Handle;
//+------------------------------------------------------------------+   
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- ������������� ���������� ������ ������� ������
   min_rates_=int(Length);
   min_rates_total=int(min_rates_+2*Length);
//---- ��������� ������ ���������� iRSI
   RSI_Handle=iRSI(NULL,PERIOD_CURRENT,Length,RSIPrice);
   if(RSI_Handle==INVALID_HANDLE) Print(" �� ������� �������� ����� ���������� iRSI");
//---- ��������� ������ ���������� iStdDev
   if(!MA_Method)
     {
      STD_Handle=iStdDev(NULL,PERIOD_CURRENT,Length,0,MODE_SMA,RSI_Handle);
      if(STD_Handle==INVALID_HANDLE) Print(" �� ������� �������� ����� ���������� iStdDev");
     }
//---- ����������� ������������� ������� � ������������ �����
   SetIndexBuffer(0,ExtLineBuffer,INDICATOR_DATA);
//---- ������������� ������ ���������� 1 �� �����������
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- ������������� ������ ������ ������� ��������� ����������
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- ��������� �������� ����������, ������� �� ����� ������ �� �������
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- ���������� ��������� � ������ ��� � ���������
   ArraySetAsSeries(ExtLineBuffer,true);
//---- ����������� ������������ �������� � ������������ ������
   SetIndexBuffer(1,ExtLineBuffer1,INDICATOR_DATA);
   SetIndexBuffer(2,ExtLineBuffer2,INDICATOR_DATA);
//---- ��������� �������, � ������� ���������� ��������� ������� �����������
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,min_rates_total);
//---- ������ �� ��������� ����������� ������ ��������
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- ���������� ��������� � ������ ��� � ���������
   ArraySetAsSeries(ExtLineBuffer1,true);
   ArraySetAsSeries(ExtLineBuffer2,true);
//---- ����������� ������������� ������� � ������������ �����
   SetIndexBuffer(3,ExtCalcBuffer,INDICATOR_CALCULATIONS);
//---- ������������� ���������� ��� ��������� ����� ����������
   string shortname;
   StringConcatenate(shortname,"FX5_SelfAdjustingRSI(",Length,")");
//--- �������� ����� ��� ����������� � ��������� ������� � �� ����������� ���������
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- ����������� �������� ����������� �������� ����������
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//---- ���������� �������������
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,    // ���������� ������� � ����� �� ������� ����
                const int prev_calculated,// ���������� ������� � ����� �� ���������� ����
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- �������� ���������� ����� �� ������������� ��� �������
   if(BarsCalculated(RSI_Handle)<rates_total
      || (!MA_Method && BarsCalculated(STD_Handle)<rates_total)
      || rates_total<min_rates_total)
      return(RESET);
//---- ���������� ��������� ���������� 
   int to_copy,limit,bar;
   double STD[];
//---- ������� ������������ ���������� ���������� ������ � ���������� ������ limit ��� ����� ��������� �����
   if(prev_calculated>rates_total || prev_calculated<=0)// �������� �� ������ ����� ������� ����������
     {
      limit=rates_total-min_rates_-1; // ��������� ����� ��� ������� ���� �����
     }
   else
     {
      limit=rates_total-prev_calculated; // ��������� ����� ��� ������� ����� �����
     }
//----
   to_copy=limit+1;
//---- �������� ����� ����������� ������ � �������
   if(CopyBuffer(RSI_Handle,0,0,to_copy,ExtLineBuffer)<=0) return(RESET);
   if(!MA_Method)if(CopyBuffer(STD_Handle,0,0,to_copy,STD)<=0) return(RESET);
//---- ���������� ��������� � �������� ��� � ����������  
   ArraySetAsSeries(STD,true);
//---- �������� ���� ������� ����������
   if(MA_Method==true)
     {
      for(bar=limit; bar>=0 && !IsStopped(); bar--)
        {
         double smoothedRSI=GetSmoothedRSI(bar);
         ExtCalcBuffer[bar]=MathAbs(ExtLineBuffer[bar]-smoothedRSI);
         double kDiviation=BandsDeviation*GetAbsDiviationAverage(bar);
         ExtLineBuffer1[bar]=50+kDiviation;
         ExtLineBuffer2[bar]=50-kDiviation;
        }
     }
   else
     {
      for(bar=limit; bar>=0 && !IsStopped(); bar--)
        {
         double kDiviation=BandsDeviation*STD[bar];
         ExtLineBuffer1[bar]=50+kDiviation;
         ExtLineBuffer2[bar]=50-kDiviation;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetSmoothedRSI(int shift)
  {
//----
   double sum=0;
   for(int iii=int(shift+Length-1); iii>=shift; iii--) sum+=ExtLineBuffer[iii];
//----
   return(sum/Length);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetAbsDiviationAverage(int shift)
  {
//----
   double sum=0;
   for(int iii=int(shift+Length-1); iii>=shift; iii--) sum+=ExtCalcBuffer[iii];
//----
   return(sum/Length);
  }
//+------------------------------------------------------------------+
