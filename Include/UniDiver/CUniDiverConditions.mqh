#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

class CDiverConditionsBase{
   protected:
      double m_pt;
      double m_it;
   public:
   void SetParameters(double pt,double it){
      m_pt=pt;
      m_it=it;
   }
   virtual bool CheckBuy(double i1,double p1,double i2,double p2){
      return(false);
   }
   virtual bool CheckSell(double i1,double p1,double i2,double p2){
      return(false);
   }
};

//===

class CDiverConditions0:public CDiverConditionsBase{
   private:
   public:
   bool CheckBuy(double i1,double p1,double i2,double p2){
      return(true);
   }
   bool CheckSell(double i1,double p1,double i2,double p2){
      return(true);
   }
};

//=== price more

class CDiverConditions1:public CDiverConditionsBase{
   private:
   public:
   bool CheckBuy(double i1,double p1,double i2,double p2){
      return((p1>p2+m_pt) && (i1>i2+m_it));
   }
   bool CheckSell(double i1,double p1,double i2,double p2){
      return((p1<p2-m_pt) && (i1<i2-m_it));
   }
};

class CDiverConditions2:public CDiverConditionsBase{
   private:
   public:
   bool CheckBuy(double i1,double p1,double i2,double p2){
      return((p1>p2+m_pt) && (MathAbs(i1-i2)<=m_it));
   }
   bool CheckSell(double i1,double p1,double i2,double p2){
      return((p1<p2-m_pt) && (MathAbs(i1-i2)<=m_it));
   }
};

class CDiverConditions3:public CDiverConditionsBase{
   private:
   public:
   bool CheckBuy(double i1,double p1,double i2,double p2){
      return((p1>p2+m_pt) && (i1<i2-m_it));
   }
   bool CheckSell(double i1,double p1,double i2,double p2){
      return((p1<p2-m_pt) && (i1>i2+m_it));
   }
};

//=== price eq

class CDiverConditions4:public CDiverConditionsBase{
   private:
   public:
   bool CheckBuy(double i1,double p1,double i2,double p2){
      return((MathAbs(p1-p2)<=m_pt) && (i1>i2+m_it));
   }
   bool CheckSell(double i1,double p1,double i2,double p2){
      return(MathAbs(p1-p2)<=m_pt && (i1<i2-m_it));
   }
};

class CDiverConditions5:public CDiverConditionsBase{
   private:
   public:
   bool CheckBuy(double i1,double p1,double i2,double p2){
      return(MathAbs(p1-p2)<=m_pt && (MathAbs(i1-i2)<=m_it));
   }
   bool CheckSell(double i1,double p1,double i2,double p2){
      return(MathAbs(p1-p2)<=m_pt && (MathAbs(i1-i2)<=m_it));
   }
};

class CDiverConditions6:public CDiverConditionsBase{
   private:
   public:
   bool CheckBuy(double i1,double p1,double i2,double p2){
      return(MathAbs(p1-p2)<=m_pt && (i1<i2-m_it));
   }
   bool CheckSell(double i1,double p1,double i2,double p2){
      return(MathAbs(p1-p2)<=m_pt && (i1>i2+m_it));
   }
};

//=== price less

class CDiverConditions7:public CDiverConditionsBase{
   private:
   public:
   bool CheckBuy(double i1,double p1,double i2,double p2){
      return((p1<p2-m_pt) && (i1>i2+m_it));
   }
   bool CheckSell(double i1,double p1,double i2,double p2){
      return((p1>p2+m_pt) && (i1<i2-m_it));
   }
};

class CDiverConditions8:public CDiverConditionsBase{
   private:
   public:
   bool CheckBuy(double i1,double p1,double i2,double p2){
      return((p1<p2-m_pt) && (MathAbs(i1-i2)<=m_it));
   }
   bool CheckSell(double i1,double p1,double i2,double p2){
      return((p1>p2+m_pt) && (MathAbs(i1-i2)<=m_it));
   }
};

class CDiverConditions9:public CDiverConditionsBase{
   private:
   public:
   bool CheckBuy(double i1,double p1,double i2,double p2){
      return((p1<p2-m_pt) && (i1<i2-m_it));
   }
   bool CheckSell(double i1,double p1,double i2,double p2){
      return((p1>p2+m_pt) && (i1>i2+m_it));
   }
};
