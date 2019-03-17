//+------------------------------------------------------------------+
//|                                                 IncMAOnArray.mqh |
//|                                                          Integer |
//|                          https://login.mql5.com/ru/users/Integer |
//+------------------------------------------------------------------+
#property copyright "Integer"
#property link      "https://login.mql5.com/ru/users/Integer"
#property version   "1.00"
/*
   External parameters:
   input int            MAPeriod    =  14;
   input ENUM_MA_METHOD MAMethod    =  MODE_SMA;

   Declaration:
   #include <IncOnArray/IncMAOnArray.mqh>
   CMAOnArray ma;
   
   â OnInit:
   ma.Init(VisibleBars,MAPeriod,MAMethod);

   â OnCalculate:
   ma.Solve(rates_total,prev_calculated,data,MABuffer);
*/
//+------------------------------------------------------------------+
//| CMAOnArray                                                       |
//+------------------------------------------------------------------+
class CMAOnArray
  {
private:
   int               m_MAPeriod;
   ENUM_MA_METHOD    m_Method;
   double            m_k1,m_k2;
   double            m_LK[];
   string            m_Name;
   string            m_sMethod;
   int               m_m;
   int               m_br;
   void SMA(const int aRatesTotal,const int aPrevCalc,double  &aData[],double  &aMA[])
     {
      int Start=0;
      if(aPrevCalc==0)
        {
         for(int i=0;i<aRatesTotal;i++)
           {
            if(aData[i]!=0 && aData[i]!=EMPTY_VALUE)
              {
               Start=i+m_MAPeriod-1;
               break;
              }
           }
         aMA[Start]=0;
         for(int i=Start;i>Start-m_MAPeriod;i--)
           {
            aMA[Start]+=aData[i];
           }
         aMA[Start]/=m_MAPeriod;
         Start++;
        }
      else
        {
         Start=aPrevCalc-1;
        }
      for(int i=Start;i<aRatesTotal;i++)
        {
         aMA[i]=aMA[i-1]-(aData[i-m_MAPeriod]-aData[i])/m_MAPeriod;
        }
     }
   void EMA(const int aRatesTotal,const int aPrevCalc,double  &aData[],double  &aMA[])
     {
      int Start=0;
      if(aPrevCalc==0)
        {
         for(int i=0;i<aRatesTotal;i++)
           {
            if(aData[i]!=0 && aData[i]!=EMPTY_VALUE)
              {
               Start=i+1;
               break;
              }
           }
         aMA[Start-1]=aData[Start-1];
        }
      else
        {
         Start=aPrevCalc-1;
        }
      for(int i=Start;i<aRatesTotal;i++)
        {
         aMA[i]=m_k1*aData[i]+m_k2*aMA[i-1];
        }
     }
   void LWMA(const int aRatesTotal,const int aPrevCalc,double  &aData[],double  &aMA[])
     {
      int Start=0;
      if(aPrevCalc==0)
        {
         for(int i=0;i<aRatesTotal;i++)
           {
            if(aData[i]!=0 && aData[i]!=EMPTY_VALUE)
              {
               Start=i+m_MAPeriod-1;
               break;
              }
           }
        }
      else
        {
         Start=aPrevCalc-1;
        }
      for(int i=Start;i<aRatesTotal;i++)
        {
         aMA[i]=0;
         for(int j=0;j<m_MAPeriod;j++)
           {
            aMA[i]+=aData[i-j]*m_LK[j];
           }
        }
     }
public:
   void Init(int aMAPeriod=14,ENUM_MA_METHOD aMethod=MODE_SMA)
     {
      m_m=10;
      m_MAPeriod=aMAPeriod;
      m_Method=aMethod;
      if(aMethod==MODE_SMA)
        {
         m_sMethod="SMA";
        }
      if(aMethod==MODE_EMA)
        {
         m_k1=2.0/(m_MAPeriod+1.0);
         m_k2=1.0-m_k1;
         m_sMethod="EMA";
        }
      if(aMethod==MODE_SMMA)
        {
         m_k1=1.0/m_MAPeriod;
         m_k2=1.0-m_k1;
         m_sMethod="SMMA";
        }
      if(aMethod==MODE_LWMA)
        {
         ArrayResize(m_LK,m_MAPeriod);
         double sum=0;
         for(int j=0;j<m_MAPeriod;j++)
           {
            m_LK[j]=m_MAPeriod-j;
            sum+=m_LK[j];
           }
         for(int j=0;j<m_MAPeriod;j++)
           {
            m_LK[j]/=sum;
           }
         sum=0;
         for(int j=0;j<m_MAPeriod;j++)
           {
            sum+=m_LK[j];
           }
         m_sMethod="LWMA";
        }
      m_Name=m_sMethod+"("+IntegerToString(m_MAPeriod)+")";
      if(m_Method==MODE_EMA || m_Method==MODE_SMMA)
        {
         m_br=m_MAPeriod*m_m;
        }
      else
        {
         m_br=m_MAPeriod;
        }
     }
   void Solve(const int aRatesTotal,const int aPrevCalc,double  &aData[],double  &aMA[])
     {
      switch(m_Method)
        {
         case MODE_SMA:
            SMA(aRatesTotal,aPrevCalc,aData,aMA);
            break;
         case MODE_EMA:
         case MODE_SMMA:
            EMA(aRatesTotal,aPrevCalc,aData,aMA);
            break;
         case MODE_LWMA:
            LWMA(aRatesTotal,aPrevCalc,aData,aMA);
            break;
        }
     }
   int BarsRequired()
     {
      return(m_br);
     }
   string Name()
     {
      return(m_Name);
     }
   string NameMethod()
     {
      return(m_sMethod);
     }
   string About()
     {
      return("Integer's MAOnArray class. https://login.mql5.com/ru/users/Integer");
     }
  };
//+------------------------------------------------------------------+
