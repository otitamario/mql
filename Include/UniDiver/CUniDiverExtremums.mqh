#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

#include <UniOsc/UniOscDefines.mqh>
#include <UniDiver/UniDiverDefines.mqh>
#include <UniDiver/CUniDiverConditions.mqh>
#include <UniDiver/UniDiverGObjects.mqh>

class CDiverBase{
   private:
   protected: 
   
      datetime m_LastTime;
      
      SExtremum m_upper[];
      SExtremum m_lower[];
      
      CDiverConditionsBase * m_conditions[];
      int m_ccnt;
      
      bool m_arrows;
      bool m_lines;
      color m_cbuy;
      color m_csell;

      void AddExtremum( SExtremum & a[],
                        int & cnt,
                        double iv,
                        double pv,
                        int mb,
                        int sb,
                        datetime et
      ){
         if(cnt>=ArraySize(a)){
            ArrayResize(a,ArraySize(a)+1024);
         }
         a[cnt].IndicatorValue=iv;
         a[cnt].PriceValue=pv;
         a[cnt].ExtremumBar=mb;
         a[cnt].SignalBar=sb;
         a[cnt].ExtremumTime=et;
         cnt++;
      }
      
      void CheckDiver(  int i,
                        int ucnt,
                        int lcnt,
                        const datetime & time[],
                        const double &high[],
                        const double &low[],                     
                        double & buy[],
                        double & sell[],
                        double & osc[]
      ){
      
         buy[i]=EMPTY_VALUE;
         sell[i]=EMPTY_VALUE;
         
         this.DelObjects(time[i]);
         
         if(ucnt>m_ccnt){
            if(m_upper[ucnt-1].SignalBar==i){
      
               bool check=true;
               
               for(int j=0;j<m_ccnt;j++){
                  bool result=m_conditions[j].CheckSell( m_upper[ucnt-1-j].IndicatorValue,
                                                         m_upper[ucnt-1-j].PriceValue,
                                                         m_upper[ucnt-1-j-1].IndicatorValue,
                                                         m_upper[ucnt-1-j-1].PriceValue
                                                      );
                  if(!result){
                     check=false;
                     break;
                  } 
                                      
               }
               if(check){
                  sell[i]=osc[i];
                  this.DrawSellObjects(time[i],high[i],ucnt);
               }
            }
         }
         
         if(lcnt>m_ccnt){
            if(m_lower[lcnt-1].SignalBar==i){
               bool check=true;
               for(int j=0;j<m_ccnt;j++){
                  bool result=m_conditions[j].CheckBuy(  m_lower[lcnt-1-j].IndicatorValue,
                                                         m_lower[lcnt-1-j].PriceValue,
                                                         m_lower[lcnt-2-j].IndicatorValue,
                                                         m_lower[lcnt-2-j].PriceValue
                                                      );
                  if(!result){
                     check=false;
                     break;
                  }                                          
               }
               if(check){
                  buy[i]=osc[i];
                  this.DrawBuyObjects(time[i],low[i],lcnt);
               }
            }
         }    
      }

      CDiverConditionsBase * CreateConditions(int i){
         switch(i){
            case 0:
               return(new CDiverConditions0());      
            break;
            case 1:
               return(new CDiverConditions1());      
            break;
            case 2:
               return(new CDiverConditions2());      
            break;
            case 3:
               return(new CDiverConditions3());      
            break;
            case 4:
               return(new CDiverConditions4());      
            break;
            case 5:
               return(new CDiverConditions5());      
            break;      
            case 6:
               return(new CDiverConditions6());      
            break;
            case 7:
               return(new CDiverConditions7());      
            break;
            case 8:
               return(new CDiverConditions8());      
            break;
            case 9:
               return(new CDiverConditions9());
            break;
         }
         return(new CDiverConditions0()); 
      }

      void DrawBuyObjects(datetime bartime,double arprice,int lcnt){
         if(m_lines){
            
            string pref=MQLInfoString(MQL_PROGRAM_NAME)+"_"+IntegerToString((long)bartime)+"_";
            
            for(int j=0;j<m_ccnt;j++){
                        
               fObjTrend(  pref+"bp_"+IntegerToString(j),
                           m_lower[lcnt-1-j].ExtremumTime,
                           m_lower[lcnt-1-j].PriceValue,
                           m_lower[lcnt-2-j].ExtremumTime,
                           m_lower[lcnt-2-j].PriceValue,
                           m_cbuy);
                           
               fObjTrend(  pref+"bi_"+IntegerToString(j),
                           m_lower[lcnt-1-j].ExtremumTime,
                           m_lower[lcnt-1-j].IndicatorValue,
                           m_lower[lcnt-2-j].ExtremumTime,
                           m_lower[lcnt-2-j].IndicatorValue,
                           m_cbuy,
                           ChartWindowFind(0,MQLInfoString(MQL_PROGRAM_NAME)));  
            }
         }
         
         if(m_arrows){
            fObjArrow(MQLInfoString(MQL_PROGRAM_NAME)+"_"+IntegerToString((long)bartime)+"_ba",
                     bartime,
                     arprice,
                     233,
                     m_cbuy,
                     ANCHOR_UPPER); 
         }
      }

      void DrawSellObjects(datetime bartime,double arprice,int ucnt){
         if(m_lines){
            
            string pref=MQLInfoString(MQL_PROGRAM_NAME)+"_"+IntegerToString((long)bartime)+"_";
            
            for(int j=0;j<m_ccnt;j++){
                        
               fObjTrend(  pref+"sp_"+IntegerToString(j),
                           m_upper[ucnt-1-j].ExtremumTime,
                           m_upper[ucnt-1-j].PriceValue,
                           m_upper[ucnt-2-j].ExtremumTime,
                           m_upper[ucnt-2-j].PriceValue,
                           m_csell);
                           
               fObjTrend(  pref+"si_"+IntegerToString(j),
                           m_upper[ucnt-1-j].ExtremumTime,
                           m_upper[ucnt-1-j].IndicatorValue,
                           m_upper[ucnt-2-j].ExtremumTime,
                           m_upper[ucnt-2-j].IndicatorValue,
                           m_csell,
                           ChartWindowFind(0,MQLInfoString(MQL_PROGRAM_NAME)));  
            }
         }
            
         if(m_arrows){
            fObjArrow(MQLInfoString(MQL_PROGRAM_NAME)+"_"+IntegerToString((long)bartime)+"_sa",
                     bartime,
                     arprice,
                     234,
                     m_csell,
                     ANCHOR_LOWER); 
         }            
      }   
      
      void DelObjects(datetime bartime){
         if(m_lines){
            string pref=MQLInfoString(MQL_PROGRAM_NAME)+"_"+IntegerToString((long)bartime)+"_";
            for(int j=0;j<m_ccnt;j++){
               ObjectDelete(0,pref+"bp_"+IntegerToString(j));
               ObjectDelete(0,pref+"bi_"+IntegerToString(j));  
               ObjectDelete(0,pref+"sp_"+IntegerToString(j));
               ObjectDelete(0,pref+"si_"+IntegerToString(j));  
            }            
         }
         if(m_arrows){
            ObjectDelete(0,MQLInfoString(MQL_PROGRAM_NAME)+"_"+IntegerToString((long)bartime)+"_ba");
            ObjectDelete(0,MQLInfoString(MQL_PROGRAM_NAME)+"_"+IntegerToString((long)bartime)+"_sa");
         }
      }   
      

   public:
   
      void ~CDiverBase(){
         for(int i=0;i<ArraySize(m_conditions);i++){
            if(CheckPointer(m_conditions[i])==POINTER_DYNAMIC){
               delete(m_conditions[i]);
            }      
         }  
         ObjectsDeleteAll(0,MQLInfoString(MQL_PROGRAM_NAME));
         ChartRedraw();          
      }   
      
      void SetConditions(int num,double pt,double it){
         if(num<1)num=1;   
         ArrayResize(m_conditions,10);
         m_ccnt=0;
         while(num>0){
            int cn=num%10;
            m_conditions[m_ccnt]=CreateConditions(cn);
            m_conditions[m_ccnt].SetParameters(pt,it);
            num=num/10;
            m_ccnt++;
         }
         ArrayResize(m_conditions,m_ccnt);   
      }
      
      void SetDrawParmeters(bool arrows,bool lines,color cbuy,color csell){
         m_arrows=arrows;
         m_lines=lines;
         m_cbuy=cbuy;
         m_csell=csell;
      }
      
      virtual void Calculate( const int rates_total,
                              const int prev_calculated,
                              const datetime &time[],
                              const double &high[],
                              const double &low[],
                              double & osc[],
                              double & buy[],     
                              double & sell[]
      ){}
};   

class CDiverBars:public CDiverBase{
   private:   
   
      SPseudoBuffers1 Cur;
      SPseudoBuffers1 Pre;        
      int m_left,m_right,m_start,m_period;   
   
   public:
         
      void CDiverBars(int Left,int Right){
         m_left=Left;
         m_right=Right;   
         if(m_left<1)m_left=m_right;
         if(m_right<1)m_right=m_left;
         if(m_left<1 && m_right<1){
            m_left=2;
            m_right=2;
         }
         m_start=m_left+m_right;
         m_period=m_start+1;
      }
   
      void Calculate( const int rates_total,
                      const int prev_calculated,
                      const datetime &time[],
                      const double &high[],
                      const double &low[],
                      double & osc[],
                      double & buy[],
                      double & sell[]
      ){
      
         int start;
         
         if(prev_calculated==0){
            start=m_period; 
            m_LastTime=0;
            Cur.Reset();
            Pre.Reset();
         }
         else{ 
            start=prev_calculated-1;
         }
      
         for(int i=start;i<rates_total;i++){
            
            if(time[i]>m_LastTime){
               m_LastTime=time[i];
               Pre=Cur;
            }
            else{
               Cur=Pre;
            }
            
            int sb=i-m_start;
            int mb=i-m_right;
            
            if(ArrayMaximum(osc,sb,m_period)==mb){
               this.AddExtremum(m_upper,Cur.UpperCnt,osc[mb],high[mb],mb,i,time[mb]);
            }
            if(ArrayMinimum(osc,sb,m_period)==mb){
               this.AddExtremum(m_lower,Cur.LowerCnt,osc[mb],low[mb],mb,i,time[mb]);
            }
            
            this.CheckDiver(i,Cur.UpperCnt,Cur.LowerCnt,time,high,low,buy,sell,osc);
         } 
      }
};

class CDiverThreshold:public CDiverBase{
   private:
      SPseudoBuffers2 Cur;
      SPseudoBuffers2 Pre;      
      double m_threshold;      
   public:      
   void CDiverThreshold(double Threshold){
      m_threshold=Threshold;
   }
   void Calculate(  const int rates_total,
                   const int prev_calculated,
                   const datetime &time[],
                   const double &high[],
                   const double &low[],                   
                   double & osc[],
                   double & buy[],
                   double & sell[]
   ){
   
      int start;
      
      if(prev_calculated==0){
         start=0; 
         m_LastTime=0;
         Cur.Reset();
         Pre.Reset();
      }
      else{ 
         start=prev_calculated-1;
      }  
   
      for(int i=start;i<rates_total;i++){
      
         if(time[i]>m_LastTime){
            m_LastTime=time[i];
            Pre=Cur;
         }
         else{
            Cur=Pre;
         }
         
         switch(Cur.Trend){
            case 1:
               if(osc[i]>Cur.MinMaxVal){
                  Cur.MinMaxVal=osc[i];
                  Cur.MinMaxBar=i;
               }
               if(osc[i]<Cur.MinMaxVal-m_threshold){
                  this.AddExtremum(m_upper,Cur.UpperCnt,Cur.MinMaxVal,high[Cur.MinMaxBar],Cur.MinMaxBar,i,time[Cur.MinMaxBar]);
                  Cur.Trend=-1;
                  Cur.MinMaxVal=osc[i];
                  Cur.MinMaxBar=i;               
               }
            break;
            case -1:
               if(osc[i]<Cur.MinMaxVal){
                  Cur.MinMaxVal=osc[i];
                  Cur.MinMaxBar=i;
               }
               if(osc[i]>Cur.MinMaxVal+m_threshold){
                  this.AddExtremum(m_lower,Cur.LowerCnt,Cur.MinMaxVal,low[Cur.MinMaxBar],Cur.MinMaxBar,i,time[Cur.MinMaxBar]);
                  Cur.Trend=1;
                  Cur.MinMaxVal=osc[i];
                  Cur.MinMaxBar=i;
               }         
            break;
         }
         
         this.CheckDiver(i,Cur.UpperCnt,Cur.LowerCnt,time,high,low,buy,sell,osc);
         
      } 
   }  
}; 
 
class CDiverMiddle:public CDiverBase{
   private:
      SPseudoBuffers2 Cur;
      SPseudoBuffers2 Pre;     
      double m_level;
   public:
   void CDiverMiddle(EOscUniType type){
      if(type==OscUni_Momentum){
         m_level=100.0;
      }
      else if(type==OscUni_RSI || type==OscUni_Stochastic){
         m_level=50.0;
      }
      else if(type==OscUni_WPR){
         m_level=-50.0;
      }
      else{
         m_level=0.0;
      }
   }
   void Calculate( const int rates_total,
                   const int prev_calculated,
                   const datetime &time[],
                   const double &high[],
                   const double &low[],                   
                   double & osc[],
                   double & buy[],
                   double & sell[]
   ){

      int start;
      
      if(prev_calculated==0){
         start=0; 
         m_LastTime=0;
         Cur.Reset();
         Pre.Reset();
      }
      else{ 
         start=prev_calculated-1;
      }  
   
      for(int i=start;i<rates_total;i++){
      
         if(time[i]>m_LastTime){
            m_LastTime=time[i];
            Pre=Cur;
         }
         else{
            Cur=Pre;
         }
         
         switch(Cur.Trend){
            case 1:
               if(osc[i]>Cur.MinMaxVal){
                  Cur.MinMaxVal=osc[i];
                  Cur.MinMaxBar=i;
               }
               if(osc[i]<m_level){
                  this.AddExtremum(m_upper,Cur.UpperCnt,Cur.MinMaxVal,high[Cur.MinMaxBar],Cur.MinMaxBar,i,time[Cur.MinMaxBar]);
                  Cur.Trend=-1;
                  Cur.MinMaxVal=osc[i];
                  Cur.MinMaxBar=i;               
               }
            break;
            case -1:
               if(osc[i]<Cur.MinMaxVal){
                  Cur.MinMaxVal=osc[i];
                  Cur.MinMaxBar=i;
               }
               if(osc[i]>m_level){
                  this.AddExtremum(m_lower,Cur.LowerCnt,Cur.MinMaxVal,low[Cur.MinMaxBar],Cur.MinMaxBar,i,time[Cur.MinMaxBar]);
                  Cur.Trend=1;
                  Cur.MinMaxVal=osc[i];
                  Cur.MinMaxBar=i;
               }         
            break;
         }
         
         this.CheckDiver(i,Cur.UpperCnt,Cur.LowerCnt,time,high,low,buy,sell,osc);
      } 
   } 
}; 
