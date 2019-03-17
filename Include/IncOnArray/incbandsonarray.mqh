//+------------------------------------------------------------------+
//|                                              IncBandsOnArray.mqh |
//|                                                          Integer |
//|                          https://login.mql5.com/ru/users/Integer |
//+------------------------------------------------------------------+
#property copyright "Integer"
#property link      "https://login.mql5.com/ru/users/Integer"
#property version   "1.00"

/*

   External parameters:

   input int            BBPeriod    =  10;
   input ENUM_MA_METHOD BBMethod    =  MODE_SMA;
   input double         BBDeviation =  2;

   Declaration:

   #include <IncOnArray/IncBandsOnArray.mqh>
   CBandsOnArray bb;

   In OnInit:
   
   bb.Init(BBPeriod,BBMethod,BBDeviation);

   In OnCalculate:
   
   bb.Solve(rates_total,prev_calculated,data,CBuffer,UBuffer,LBuffer);

*/

#include <IncOnArray/IncMAOnArray.mqh>

class CBandsOnArray{
   private:
      int m_Period;
      ENUM_MA_METHOD m_Method;
      double m_Deviation;
      string m_Name;
      CMAOnArray m_ma;
      int m_br;
   public:
      void Init(int aPeriod=20,ENUM_MA_METHOD aMethod=MODE_SMA,double aDeviation=2.0){
         m_Period=aPeriod;
         m_Method=aMethod;
         m_Deviation=aDeviation;
         m_ma.Init(m_Period,m_Method);
         m_Name="BB("+IntegerToString(m_Period)+","+m_ma.NameMethod()+","+DoubleToString(m_Deviation,2)+")";
         m_br=m_ma.BarsRequired();
      }
      void Solve( const int aRatesTotal,
                  const int aPrevCalc,
                  double & aData[],
                  double & aMA[],
                  double & aUpper[],
                  double & aLower[]){
         m_ma.Solve(aRatesTotal,aPrevCalc,aData,aMA);
         int Start=0; 
               if(aPrevCalc==0){
                  for(int i=0;i<aRatesTotal;i++){
                     if(aMA[i]!=0 && aMA[i]!=EMPTY_VALUE){
                        Start=i+m_Period;
                        break;
                     }
                  }
               }
               else{
                  Start=aPrevCalc-1;
               }
               for(int i=Start;i<aRatesTotal;i++){
                  double m_StdDev=0;            
                     for(int j=i;j>i-m_Period;j--){
                        m_StdDev+=MathPow(aData[j]-aMA[i],2);
                     }
                  m_StdDev=m_Deviation*MathSqrt(m_StdDev/m_Period); 
                  aUpper[i]=aMA[i]+m_StdDev;
                  aLower[i]=aMA[i]-m_StdDev;
               }                  
      }
      int BarsRequired(){
         return(m_br);
      }       
      string Name(){
         return(m_Name);
      }  
      string About(){
         return("Integer's StdDevOnArray class. https://login.mql5.com/ru/users/Integer");
      }       
};
