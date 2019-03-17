//+------------------------------------------------------------------+
//|                                            ZigZagOnParabolic.mq5 |
//|                                      Copyright � 2009, EarnForex |
//|                                        http://www.earnforex.com/ |
//+------------------------------------------------------------------+
//---- ��������� ����������
#property copyright "Copyright � 2009, EarnForex"
//---- ������ �� ���� ������
#property link      "http://www.earnforex.com"
//---- ����� ������ ����������
#property version   "1.01"
#property description "ZigZag on Parabolic"
//+----------------------------------------------+ 
//|  ��������� ��������� ����������              |
//+----------------------------------------------+ 
//---- ��������� ���������� � ������� ����
#property indicator_chart_window 
//---- ��� ������� � ��������� ���������� ������������ 3 ������
#property indicator_buffers 3
//---- ������������ ����� 1 ����������� ����������
#property indicator_plots   1

//---- � �������� ���������� ����������� ZIGZAG
#property indicator_type1   DRAW_COLOR_ZIGZAG
//---- ����������� ����� ����������
#property indicator_label1  "ZigZag"
//---- � �������� ������ ����� ���������� ������������
#property indicator_color1 clrDarkSalmon,clrDodgerBlue
//---- ����� ���������� - ������� �������
#property indicator_style1  STYLE_DASH
//---- ������� ����� ���������� ����� 1
#property indicator_width1  1

//+----------------------------------------------+ 
//| ������� ��������� ����������                 |
//+----------------------------------------------+ 
input double Step=0.02; //SAR ���
input double Maximum=0.2; //SAR ��������
input bool ExtremumsShift=true; //���� ������ �������
//+----------------------------------------------+

//---- ���������� ������������ ��������, ������� ����� � 
// ���������� ������������ � �������� ������������ �������
double LowestBuffer[];
double HighestBuffer[];
double ColorBuffer[];

//---- ���������� ����� ����������
int EShift;
//---- ���������� ����� ���������� ������ ������� ������
int min_rates_total;
//---- ���������� ����� ���������� ��� ������� �����������
int SAR_Handle;
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- ������������� ���������� ������ ������� ������
   min_rates_total=1;

//---- ������������� ��������   
   if(ExtremumsShift) EShift=1;
   else               EShift=0;

//---- ��������� ������ ���������� SAR
   SAR_Handle=iSAR(NULL,0,Step,Maximum);
   if(SAR_Handle==INVALID_HANDLE)Print(" �� ������� �������� ����� ���������� SAR");

//---- ����������� ������������ �������� � ������������ ������
   SetIndexBuffer(0,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,HighestBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,ColorBuffer,INDICATOR_COLOR_INDEX);
//---- ������ �� ��������� ����������� ������ ��������
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
//---- �������� ����� ��� ����������� � ���� ������
   PlotIndexSetString(0,PLOT_LABEL,"ZigZag Lowest");
   PlotIndexSetString(1,PLOT_LABEL,"ZigZag Highest");
//---- ���������� ��������� � ������� ��� � ����������   
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
   ArraySetAsSeries(ColorBuffer,true);
//---- ��������� �������, � ������� ���������� ��������� ������� �����������
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,min_rates_total);
//---- ��������� ������� �������� ����������� ����������
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- ��� ��� ���� ������ � ����� ��� �������� 
   string shortname;
   StringConcatenate(shortname,"ZigZag on Parabolic(",
           double(Step), ", ", double(Maximum), ", ", bool(ExtremumsShift), ")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//----   
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
//---- �������� ���������� ����� �� ������������� ��� �������
   if(BarsCalculated(SAR_Handle)<rates_total || rates_total<min_rates_total)return(0);

//---- ���������� ��������� ���������� 
   static int j_,lastcolor_;
   static bool dir_;
   static double h_,l_;
   int j,limit,climit,to_copy,bar,shift,NewBar,lastcolor;
   double h,l,mid0,mid1,SAR[];
   bool dir;

//---- ������ ���������� ������ limit ��� ����� ��������� ����� � ��������� ������������� ����������
   if(prev_calculated>rates_total || prev_calculated<=0)// �������� �� ������ ����� ������� ����������
     {
      limit=rates_total-1-min_rates_total; // ��������� ����� ��� ������� ���� �����

      h_=0.0;
      l_=999999999;
      dir_=false;
      j_=0;
      lastcolor_=0;
     }
   else
     {
      limit=rates_total-prev_calculated; // ��������� ����� ��� ������� ����� �����
     }
     
   climit=limit; // ��������� ����� ��� ��������� ����������

   to_copy=limit+2;
   if(limit==0) NewBar=1;
   else         NewBar=0;

//---- ���������� ��������� � �������� ��� � ���������� 
   ArraySetAsSeries(SAR,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   
//---- �������� ����� ����������� ������ � ������
   if(CopyBuffer(SAR_Handle,0,0,to_copy,SAR)<=0) return(0);

//---- ��������������� �������� ����������
   j=j_;
   dir=dir_;
   h=h_;
   l=l_;
   lastcolor=lastcolor_;

//---- ������ ������� ���� ������� ����������
   for(bar=limit; bar>=0 && !IsStopped(); bar--)
     {
      //---- ���������� �������� ���������� ����� ��������� �� ������� ����
      if(rates_total!=prev_calculated && bar==0)
        {
         j_=j;
         dir_=dir;
         h_=h;
         l_=l;
        }

      mid0=(high[bar]+low[bar])/2;
      mid1=(high[bar+1]+low[bar+1])/2;
      
      HighestBuffer[bar]=0.0;
      LowestBuffer[bar]=0.0;

      if(bar>0) j++;

      if(dir)
        {
         if(h<high[bar])
           {
            h=high[bar];
            j=NewBar;
           }
         if(SAR[bar+1]<=mid1 && SAR[bar]>mid0)
           {
            shift=bar+EShift *(j+NewBar);
            if(shift>rates_total-1) shift=rates_total-1;
            HighestBuffer[shift]=h;
            dir=false;
            l=low[bar];
            j=0;
            if(shift>climit) climit=shift;
           }
        }
      else
        {
         if(l>low[bar])
           {
            l=low[bar];
            j=NewBar;
           }
         if(SAR[bar+1]>=mid1 && SAR[bar]<mid0)
           {
            shift=bar+EShift *(j+NewBar);
            if(shift>rates_total-1) shift=rates_total-1;
            LowestBuffer[shift]=l;
            dir=true;
            h=high[bar];
            j=0;
            if(shift>climit) climit=shift;
           }
        }
     }

//---- ������ ������� ���� ��������� ����������
   for(bar=climit; bar>=0 && !IsStopped(); bar--)
     {
      if(rates_total!=prev_calculated && !bar) lastcolor_=lastcolor;

      if(!HighestBuffer[bar] || !LowestBuffer[bar]) ColorBuffer[bar]=lastcolor;

      if(HighestBuffer[bar] || LowestBuffer[bar])
        {
         if(lastcolor==0)
           {
            ColorBuffer[bar]=1;
            lastcolor=1;
           }
         else
           {
            ColorBuffer[bar]=0;
            lastcolor=0;
           }
        }

      if(!HighestBuffer[bar] || !LowestBuffer[bar])
        {
         ColorBuffer[bar]=1;
         lastcolor=1;
        }

      if(HighestBuffer[bar] || LowestBuffer[bar])
        {
         ColorBuffer[bar]=0;
         lastcolor=0;
        }
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
