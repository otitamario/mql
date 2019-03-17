//+------------------------------------------------------------------+
//|                                                   statistics.mqh |
//|                        Copyright 2015, Herajika                  |
//|                                         morinoherajika@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Herajika/Adam S³ucki"
#property link      "morinoherajika@gmail.com"
//+------------------------------------------------------------------+
//|      Set of statistical functions:                               |
//|      -mean: mean(T &arr[]);                                      |
//|      -standard deviation: std(double &arr[]);                    |
//|      -correlation coefficient:  correlation(&arr1[], &arr2[]);   |
//|      -time serie decomposition (trend removal):                  |
//|                    detrend(arr[], resultArray[]);                |
//|      -regression line:                                           |
//|           regression(&arr1[], &arr2[], &res[])                   |
//|      -regression line with coefficients:                         |
//|              regression(double &arr1[], double &arr2[],          |
//|                         double &res[], double &aCoeff,           |
//|                         double &bCoeff)                          |
//|      -Dickey-Fuller test for stationarity:                       | 
//|                   dickeyFuller(double &arr[])                    |
//|      -Engle Granger 2 step method for testing cointegration:     |
//|               engleGrangerTest(double &arr1[],                   |
//|                                double &arr2[],                   |
//|                                double &cointCoeff)               |
//|      -Autoregressive model with lag 1:    AR1(double &arr[])     |
//|      -signed integral: signedIntegral(double a, double b, int n)*|
//|      -error function: erf(double x)                              |
//|      -probality that variable is from normal distrbutoion:       |
//|           normDistZ(double z)                                    |
//+------------------------------------------------------------------+
//* You should add your own implementation of "foo" function which
//  you want to integrate. Default function is: f(x) = x.
//+------------------------------------------------------------------+
//|                           ATTENTION                              |
//| Time series avaliable in mql are indexed in a way that the newest|
//| data have a 0 index. It's good idea to reverse order of such     |
//| arrays and is absolutely necessay in AR model (arrays are not    |
//| reversed inside of the method to avoid confusion)                |
//+------------------------------------------------------------------+
//--- return mean of a serie
template<typename T>
T mean(T &arr[])
  {
//---
   T mean=0;
   int length=ArraySize(arr);
//---
   for(int i=0; i<length; i++)
     {
      mean+=arr[i];
     }
   mean/=length;
//---
   return(mean);
  }
//--- return standard deviation of a serie
double std(double &arr[])
  {
   double meanVal=0;
   double std=0;
   double length=ArraySize(arr);
//---
   for(int i=0; i<length;i++)
     {
      meanVal+=arr[i];
     }
//---
   meanVal/=length;
//---
   for(int i=0; i<length; i++)
     {
      std+=MathPow(arr[i]-meanVal,2);
     }
//---
   std=MathSqrt(std/length);
//---
   return(std);
  }
//--- time serie decomposition (remove trend)
void detrend(double &arr[],double &res[])
  {
   double regRes[];
   double iterator[];
   int length=ArraySize(arr);
   ArrayResize(regRes,length);
   ArrayResize(iterator,length);
//---
   for(int i=0; i<length; i++)
     {
      iterator[i]=i+1;
     }
//---
   regression(iterator,arr,regRes);
//---
   for(int i=0; i<length;i++)
     {
      res[i]=arr[i]-regRes[i];
     }
  }
//--- return corellation coefficient
double correlation(double &arrX[],double &arrY[])
  {
   double meanX,meanY,stdX,stdY,numerator,ccoeff;
   int length=ArraySize(arrX);
//---
   meanX = 0;
   meanY = 0;
   stdX= 0;
   stdY= 0;
   numerator=0;
//---
   if(ArraySize(arrY) != length) return(-2);
//---
   meanX = mean(arrX);
   meanY = mean(arrY);
//---
   for(int i=0; i<length; i++)
     {
      numerator+=(arrX[i]-meanX)*(arrY[i]-meanY);
     }
//---
   stdX = std(arrX);
   stdY = std(arrY);
//---
   ccoeff=numerator/(stdX*stdY*(length-1));
//---
   return(ccoeff);
  };
//--- return array with regression line values
void regression(double &arr1[],double &arr2[],double &res[])
  {
//---
   double a = 0;
   double b = 0;
//---
   int length=ArraySize(arr1);
//---
   ArrayResize(res,length);
//---
   double meanX = mean(arr1);
   double meanY = mean(arr2);
//---
   double sumXY=0;
   double sqSumX=0;
//---
   for(int i=0; i<length; i++)
     {
      sumXY+=arr1[i]*arr2[i];
      sqSumX+=MathPow(arr1[i],2);
     }
//---
   a = (sumXY - length*meanX*meanY)/(sqSumX - length*MathPow(meanX,2));
   b = meanY - a*meanX;
//---
   for(int i=0; i<length; i++)
     {
      res[i]=a*arr1[i]+b;
     }
  }
//--- return array with regression line values, plus regression line coefficients (a and b from y = ax+b)
void regression(double &arr1[],double &arr2[],double &res[],double &aCoeff,double &bCoeff)
  {
//---
   double a = 0;
   double b = 0;
//---
   int length=ArraySize(arr1);
//---
   ArrayResize(res,length);
//---
   double meanX = mean(arr1);
   double meanY = mean(arr2);
//---
   double sumXY=0;
   double sqSumX=0;
//---
   for(int i=0; i<length; i++)
     {
      sumXY+=arr1[i]*arr2[i];
      sqSumX+=MathPow(arr1[i],2);
     }
//---
   a = (sumXY - length*meanX*meanY)/(sqSumX - length*MathPow(meanX,2));
   b = meanY - a*meanX;
//---
   for(int i=0; i<length; i++)
     {
      res[i]=a*arr1[i]+b;
     }
   aCoeff = a;
   bCoeff = b;
  }
//--- Dickey Fuller test for stationarity
//--- based on paper: http://pl.scribd.com/doc/80877200/How-to-do-a-Dickey-Fuller-Test-using-Excel#scribd
//--- last access 04.2015
bool dickeyFuller(double &arr[])
  {
// n=25     50     100    250    500    >500
// {-2.62, -2.60, -2.58, -2.57, -2.57, -2.57};
   double cVal;
   bool result;
   int n=ArraySize(arr);
   double tValue;
   double corrCoeff;
   double copyArr[];
   double difference[];
   ArrayResize(difference,n-1);
//---
   for(int i=0; i<n-1; i++)
     {
      difference[i]=arr[i+1]-arr[i];
     }
//---
   ArrayCopy(copyArr,arr,0,0,n-1);
   corrCoeff=correlation(copyArr,difference);
   tValue=corrCoeff*MathSqrt((n-2)/(1-MathPow(corrCoeff,2)));
//---
   if(n<25)
     {
      cVal=-2.62;
        }else{
      if(n>=25 && n<50)
        {
         cVal=-2.60;
           }else{
         if(n>=50 && n<100)
           {
            cVal=-2.58;
              }else{
            cVal=-2.57;
           }
        }
     }
//Print(tValue);
   result=tValue>cVal;
   return(result);
  }
//--- return also beta parameter 
bool engleGrangerTest(double &arr1[],double &arr2[],double &cointCoeff)
  {
   bool result;
   int length=ArraySize(arr1);
   double regressionRes[];
   double residuals[];
   double copyArr1[],copyArr2[];
   double a;
   double b;
//---
   ArrayResize(regressionRes,length);
   ArrayResize(residuals,length);
   ArrayResize(copyArr1,length);
   ArrayResize(copyArr2,length);
//---
   ArrayCopy(copyArr1,arr1,0,0);
   ArrayCopy(copyArr2,arr2,0,0);
//---
   for(int i=0; i<length;i++)
     {
      copyArr1[i] = MathLog(copyArr1[i]);
      copyArr2[i] = MathLog(copyArr2[i]);
     }
//---
   regression(copyArr1,copyArr2,regressionRes,a,b);
   cointCoeff=a;
//---
   for(int i=0; i<length; i++)
     {
      residuals[i]=copyArr2[i]-regressionRes[i];
     }
//---
   result=dickeyFuller(residuals);
//---
   return(result);
  }
//--- Autoregressive model with lag 1; return forecast for next period
double AR1(double &arr[])
  {
   double arrY[],arrX[],regRes[];
   double a,b,fcst;
   int n=ArraySize(arr);
   ArrayResize(arrY,n-1);
   ArrayResize(arrX,n-1);
//---
   ArrayCopy(arrY,arr,0,1,n-1);
   ArrayCopy(arrX,arr,0,0,n-1);
//---
   regression(arrX,arrY,regRes,a,b);
   fcst=arr[n-1]*a+b;
//---
   return(fcst);
  }
//--- [a -> down, b -> up, n -> polynominal degree]
double signedIntegral(double a,double b,int n)
  {
//---
   int mult;
   double h=(b-a)/n;
   double integral=foo(a);
//---
   for(int i=1; i<n; i++)
     {
      if(i%2==0) mult=4; else mult=2;
      integral+=mult*(foo(a+i*h));
     }
//---
   integral += foo(a+n*h);
   integral *= h/3;
//---
   return integral;
  }
//--- edit to use with integral
double foo(double x)
  {
   return x;
  }
//--- credits to Sitt Chee Keen
double erf(double x)
  {
//--- A&S formula 7.1.26
   double a1 = 0.254829592;
   double a2 = -0.284496736;
   double a3 = 1.421413741;
   double a4 = -1.453152027;
   double a5 = 1.061405429;
   double p=0.3275911;
   x=MathAbs(x);
   double t=1/(1+p*x);
//---
   return 1 - ((((((a5 * t + a4) * t) + a3) * t + a2) * t) + a1) * t * MathExp(-1 * x * x);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double normDistZ(double z)
  {
   double sign=1;
   if(z<0) sign=-1;
   return 0.5 * (1.0 + sign * erf(MathAbs(z)/MathSqrt(2)));
  }
//+------------------------------------------------------------------+
