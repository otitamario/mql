//+------------------------------------------------------------------+
//|                                                      CUniOsc.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"

class COscUni{
   protected:
         
      int m_handle;		      // хэндл индикатора
      int m_bufferscnt;  	   // количество используемых буферов    
      string m_name;		      // имя индикатора	
      string m_label1;	      // название буфера 1	
      string m_label2;	      // название буфера 2
      int m_drawtype1;        // тип рисования буфера 1    
      int m_drawtype2;	      // тип рисования буфера 2	
      string m_help;		      // небольшая справка по параметрам индикатора
      int m_digits;		      // количество знаков после запятой у значений индикатора
      int m_levels_total;     // количество уровней
      double m_level_value[]; // массив для значений уровней

   public:
   
      void COscUni(){
         m_handle=INVALID_HANDLE;
      }
      
      void ~COscUni(){
         if(m_handle!=INVALID_HANDLE){
            IndicatorRelease(m_handle);
         }
      }
      
      int Handle(){
         return(m_handle);
      }
   
      virtual int Calculate( const int rates_total,
                     const int prev_calculated,
                     double & buffer0[],
                     double & buffer1[]
      ){
         return(rates_total);
      }
 
      bool CheckHandle(){
         return(m_handle!=INVALID_HANDLE);
      }
      
      string Name(){
         return(m_name);
      }    
         
      int BuffersCount(){
         return(m_bufferscnt);
      }
      
      string Label1(){
         return(m_label1);
      }
      
      string Label2(){
         return(m_label2);
      } 
      
      int DrawType1(){
         return(m_drawtype1);
      }
      
      int DrawType2(){
         return(m_drawtype2);
      }   
      
      string Help(){
         return(m_help);
      }
      
      int Digits(){
         return(m_digits);
      }
      
      int LevelsTotal(){
         return(m_levels_total);
      }
      
      double LevelValue(int index){
         return(m_level_value[index]);
      }
};

class COscUni_Calculate1:public COscUni{
   public:
      void COscUni_Calculate1(){
         m_bufferscnt=1;
      }
      virtual int Calculate( const int rates_total,
                     const int prev_calculated,
                     double & buffer0[],
                     double & buffer1[]
      ){
         
         int cnt,start;
         
         if(prev_calculated==0){
            cnt=rates_total;
            start=0; 
         }
         else{ 
            cnt=rates_total-prev_calculated+1; 
            start=prev_calculated-1;
         }  
         
         if(CopyBuffer(m_handle,0,0,cnt,buffer0)<=0){
            return(0);
         }
         
         for(int i=start;i<rates_total;i++){
            buffer1[i]=EMPTY_VALUE;
         }         
         
         return(rates_total);
      }
};


class COscUni_Calculate2:public COscUni{
   public:
      void COscUni_Calculate2(){
         m_bufferscnt=2;
      }   
      virtual int Calculate( const int rates_total,
                     const int prev_calculated,
                     double & buffer0[],
                     double & buffer1[]
      ){
         int cnt;
         if(prev_calculated==0){
            cnt=rates_total; 
         }
         else{ 
            cnt=rates_total-prev_calculated+1; 
         }   
                
         if(CopyBuffer(m_handle,0,0,cnt,buffer0)<=0){
            return(0);
         }
         if(CopyBuffer(m_handle,1,0,cnt,buffer1)<=0){
            return(0);
         }
         return(rates_total);
      } 
};

class COscUni_ATR:public COscUni_Calculate1{
   public:
   void COscUni_ATR(bool use_default,bool keep_previous,int & ma_period){
      if(use_default){
         if(keep_previous){
            if(ma_period==-1)ma_period=14;
         }
         else{
            ma_period=14;
         }      
      }    
      m_handle=iATR(Symbol(),Period(),ma_period);
      m_name=StringFormat("ATR(%i)",ma_period); // имя индикатора
      m_label1="ATR"; // названия буфера
      m_drawtype1=DRAW_LINE;  // тип рисования 
      m_help=StringFormat("ma_period - Period1(%i)",ma_period); // подсказка   
      m_digits=_Digits+1; // количество знаков после запятой у значений  
      m_levels_total=0; // количество уровней   
   }
};   

class COscUni_BearsPower:public COscUni_Calculate1{
   public:
   void COscUni_BearsPower(bool use_default,bool keep_previous,int & ma_period){
      if(use_default){
         if(keep_previous){
            if(ma_period==-1)ma_period=13;
         }
         else{
            ma_period=13;
         }      
      }   
      m_handle=iBearsPower(Symbol(),Period(),ma_period);
      m_name=StringFormat("BearsPower(%i)",ma_period);
      m_label1="BearsPower";
      m_drawtype1=DRAW_HISTOGRAM;
      m_help=StringFormat("ma_period - Period1(%i)",ma_period); 
      m_digits=_Digits+1;
      m_levels_total=0;
   }
};

class COscUni_BullsPower:public COscUni_Calculate1{
   public:
   void COscUni_BullsPower(bool use_default,bool keep_previous,int & ma_period){
      if(use_default){
         if(keep_previous){
            if(ma_period==-1)ma_period=13;
         }
         else{
            ma_period=13;
         }      
      }   
      m_handle=iBullsPower(Symbol(),Period(),ma_period);
      m_name=StringFormat("BullsPower(%i)",ma_period);
      m_label1="BullsPower";
      m_drawtype1=DRAW_HISTOGRAM;
      m_help=StringFormat("ma_period - Period1(%i)",ma_period); 
      m_digits=_Digits+1;
      m_levels_total=0;
   }
};

class COscUni_CCI:public COscUni_Calculate1{
   public:
   void COscUni_CCI(bool use_default,
                     bool keep_previous,
                     int & ma_period,
                     long & applied_price
   ){
   
      if(use_default){
         if(keep_previous){
            if(ma_period==-1)ma_period=14;
            if(applied_price==-1)applied_price=PRICE_TYPICAL;            
         }
         else{
            ma_period=14;
            applied_price=PRICE_TYPICAL;   
         }      
      }
      
      m_handle=iCCI(Symbol(),
                     Period(),
                     ma_period,
                     (ENUM_APPLIED_PRICE)applied_price);
      
      m_name=StringFormat( "iCCI(%i,%i,%i,%s)",
                           ma_period,
                           EnumToString((ENUM_APPLIED_PRICE)applied_price));
                           
      m_label1="CCI";
      m_drawtype1=DRAW_LINE;
      
      m_help=StringFormat( "ma_period - Period1(%i), "+
                           "applied_price - Price(%s)",
                           ma_period,
                           EnumToString((ENUM_APPLIED_PRICE)applied_price));  
      
      m_digits=2;   
      m_levels_total=2;
      ArrayResize(m_level_value,2);
      m_level_value[0]=100;
      m_level_value[1]=-100;                               
   }
};


class COscUni_Chaikin:public COscUni_Calculate1{
   public:
   void COscUni_Chaikin(bool use_default,
                     bool keep_previous,
                     int & fast_ema_period,
                     int & slow_ema_period,
                     long & ma_method,
                     long & applied_volume
   ){
   
      if(use_default){
         if(keep_previous){
            if(fast_ema_period==-1)fast_ema_period=3;
            if(slow_ema_period==-1)slow_ema_period=10;
            if(ma_method==-1)ma_method=MODE_EMA;
            if(applied_volume==-1)applied_volume=VOLUME_TICK;            
         }
         else{
            fast_ema_period=3;
            slow_ema_period=10;
            ma_method=MODE_EMA;
            applied_volume=VOLUME_TICK;
         }      
      }
      
      m_handle=iChaikin(Symbol(),
                     Period(),
                     fast_ema_period,
                     slow_ema_period,
                     (ENUM_MA_METHOD)ma_method,
                     (ENUM_APPLIED_VOLUME)applied_volume);
      
      m_name=StringFormat( "iChaikin(%i,%i,%i,%s)",
                           fast_ema_period,
                           slow_ema_period,
                           EnumToString((ENUM_MA_METHOD)ma_method),
                           EnumToString((ENUM_APPLIED_VOLUME)applied_volume));
                           
      m_label1="Chaikin";
      m_drawtype1=DRAW_LINE;
      
      m_help=StringFormat( "fast_ema_period - Period1(%i), "+
                           "slow_ema_period - Period2(%i), "+
                           "ma_method - MaMethod(%i), "+
                           "applied_price - Price(%s)",
                           fast_ema_period,
                           slow_ema_period,
                           EnumToString((ENUM_MA_METHOD)ma_method),
                           EnumToString((ENUM_APPLIED_VOLUME)applied_volume));   
                           
      m_digits=0;                           
   }
};

class COscUni_DeMarker:public COscUni_Calculate1{
   public:
   void COscUni_DeMarker(bool use_default,bool keep_previous,int & ma_period){
      if(use_default){
         if(keep_previous){
            if(ma_period==-1)ma_period=14;
         }
         else{
            ma_period=14;
         }      
      }    
      m_handle=iDeMarker(Symbol(),Period(),ma_period);
      m_name=StringFormat("DeMarker(%i)",ma_period);
      m_label1="DeMarker";
      m_drawtype1=DRAW_LINE;   
      m_help=StringFormat("ma_period - Period1(%i)",ma_period);    
      m_digits=3;    
      m_levels_total=3;
      ArrayResize(m_level_value,3);
      m_level_value[0]=0.3;
      m_level_value[1]=0.5;
      m_level_value[2]=0.7;      
                
   }
};  

class COscUni_Force:public COscUni_Calculate1{
   public:
   void COscUni_Force(bool use_default,
                     bool keep_previous,
                     int & ma_period,
                     long & ma_method,
                     long & applied_volume
   ){
   
      if(use_default){
         if(keep_previous){
            if(ma_period==-1)ma_period=13;
            if(ma_method==-1)ma_method=MODE_SMA;
            if(applied_volume==-1)applied_volume=VOLUME_TICK;            
         }
         else{
            ma_period=13;
            ma_method=MODE_SMA;
            applied_volume=VOLUME_TICK;   
         }      
      }
      
      m_handle=iForce(Symbol(),
                     Period(),
                     ma_period,
                     (ENUM_MA_METHOD)ma_method,
                     (ENUM_APPLIED_VOLUME)applied_volume);
      
      m_name=StringFormat( "iForce(%i,%s,%s)",
                           ma_period,
                           EnumToString((ENUM_MA_METHOD)ma_method),
                           EnumToString((ENUM_APPLIED_VOLUME)applied_volume));
                           
      m_label1="Force";
      m_drawtype1=DRAW_LINE;
      
      m_help=StringFormat( "ma_period - Period1(%i), "+
                           "ma_method - MaMethod(%i), "+
                           "applied_volume - Volume(%s)",
                           ma_period,
                           EnumToString((ENUM_MA_METHOD)ma_method),
                           EnumToString((ENUM_APPLIED_PRICE)applied_volume));  
                           
      m_digits=_Digits+1;                            
   }
};

class COscUni_Momentum:public COscUni_Calculate1{
   public:
   void COscUni_Momentum(bool use_default,
                     bool keep_previous,
                     int & ma_period,
                     long & applied_price
   ){
   
      if(use_default){
         if(keep_previous){
            if(ma_period==-1)ma_period=14;
            if(applied_price==-1)applied_price=PRICE_CLOSE;            
         }
         else{
            ma_period=14;
            applied_price=PRICE_CLOSE;
         }      
      }
      
      m_handle=iMomentum(Symbol(),
                     Period(),
                     ma_period,
                     (ENUM_APPLIED_PRICE)applied_price);
      
      m_name=StringFormat( "iMomentum(%i,%s)",
                           ma_period,
                           EnumToString((ENUM_APPLIED_PRICE)applied_price));
                           
      m_label1="Momentum";
      m_drawtype1=DRAW_LINE;
      
      m_help=StringFormat( "ma_period - Period1(%i), "+
                           "applied_price - Price(%s)",
                           ma_period,
                           EnumToString((ENUM_APPLIED_PRICE)applied_price));   
      
      m_digits=2;  
      m_levels_total=1;
      ArrayResize(m_level_value,1);
      m_level_value[0]=100;
   }
};

class COscUni_MACD:public COscUni_Calculate2{
   public:
   void COscUni_MACD(bool use_default,
                     bool keep_previous,
                     int & fast_ema_period,
                     int & slow_ema_period,
                     int & signal_period,
                     long & applied_price
   ){

      if(use_default){
         if(keep_previous){
            if(fast_ema_period==-1)fast_ema_period=12;
            if(slow_ema_period==-1)slow_ema_period=26;
            if(signal_period==-1)signal_period=9;
            if(applied_price==-1)applied_price=PRICE_CLOSE;            
         }
         else{
            fast_ema_period=12;
            slow_ema_period=26;
            signal_period=9;
            applied_price=PRICE_CLOSE;
         }      
      }
      
      m_handle=iMACD(Symbol(),
                     Period(),
                     fast_ema_period,
                     slow_ema_period,
                     signal_period,
                     (ENUM_APPLIED_PRICE)applied_price);
      
      m_name=StringFormat( "iMACD(%i,%i,%i,%s)",
                           fast_ema_period,
                           slow_ema_period,
                           signal_period,
                           EnumToString((ENUM_APPLIED_PRICE)applied_price));
                           
      m_label1="Main";
      m_label2="Signal";      
      m_drawtype1=DRAW_HISTOGRAM;             
      m_drawtype2=DRAW_LINE;
      
      m_help=StringFormat( "fast_ema_period - Period1(%i), "+
                           "slow_ema_period - Period2(%i), "+
                           "signal_period - Period3(%i), "+
                           "applied_price - Price(%s)",
                           fast_ema_period,
                           slow_ema_period,
                           signal_period,
                           EnumToString((ENUM_APPLIED_PRICE)applied_price));   
                           
      m_digits=_Digits+1;                           
   }
};


class COscUni_OsMA:public COscUni_Calculate1{
   public:
   void COscUni_OsMA(bool use_default,
                     bool keep_previous,
                     int & fast_ema_period,
                     int & slow_ema_period,
                     int & signal_period,
                     long & applied_price
   ){
   
      if(use_default){
         if(keep_previous){
            if(fast_ema_period==-1)fast_ema_period=12;
            if(slow_ema_period==-1)slow_ema_period=26;
            if(signal_period==-1)signal_period=9;
            if(applied_price==-1)applied_price=PRICE_CLOSE;            
         }
         else{
            fast_ema_period=12;
            slow_ema_period=26;
            signal_period=9;
            applied_price=PRICE_CLOSE;
         }      
      }
      
      m_handle=iOsMA(Symbol(),
                     Period(),
                     fast_ema_period,
                     slow_ema_period,
                     signal_period,
                     (ENUM_APPLIED_PRICE)applied_price);
      
      m_name=StringFormat( "iOsMA(%i,%i,%i,%s)",
                           fast_ema_period,
                           slow_ema_period,
                           signal_period,
                           EnumToString((ENUM_APPLIED_PRICE)applied_price));
                           
      m_label1="OsMA";
      m_drawtype1=DRAW_HISTOGRAM;             
      
      m_help=StringFormat( "fast_ema_period - Period1(%i), "+
                           "slow_ema_period - Period2(%i), "+
                           "signal_period - Period3(%i), "+
                           "applied_price - Price(%s)",
                           fast_ema_period,
                           slow_ema_period,
                           signal_period,
                           EnumToString((ENUM_APPLIED_PRICE)applied_price));  
                           
      m_digits=_Digits+2;                            
   }
};

class COscUni_RSI:public COscUni_Calculate1{
   public:
   void COscUni_RSI(bool use_default,
                     bool keep_previous,
                     int & ma_period,
                     long & applied_price
   ){
   
      if(use_default){
         if(keep_previous){
            if(ma_period==-1)ma_period=14;
            if(applied_price==-1)applied_price=PRICE_CLOSE;            
         }
         else{
            ma_period=14;
            applied_price=PRICE_CLOSE;
         }      
      }
      
      m_handle=iRSI(Symbol(),
                     Period(),
                     ma_period,
                     (ENUM_APPLIED_PRICE)applied_price);
      
      m_name=StringFormat( "iRSI(%i,%s)",
                           ma_period,
                           EnumToString((ENUM_APPLIED_PRICE)applied_price));
                           
      m_label1="RSI";
      m_drawtype1=DRAW_LINE;
      
      m_help=StringFormat( "ma_period - Period1(%i), "+
                           "applied_price - Price(%s)",
                           ma_period,
                           EnumToString((ENUM_APPLIED_PRICE)applied_price));
                           
      m_digits=2;  
      m_levels_total=3;
      ArrayResize(m_level_value,3);
      m_level_value[0]=30;
      m_level_value[1]=50;
      m_level_value[2]=70;                                          
   }
};

class COscUni_RVI:public COscUni_Calculate2{
   public:
   void COscUni_RVI(bool use_default,bool keep_previous,int & ma_period){
      if(use_default){
         if(keep_previous){
            if(ma_period==-1)ma_period=10;
         }
         else{
            ma_period=10;
         }      
      }    
      m_handle=iRVI(Symbol(),Period(),ma_period);
      m_name=StringFormat("RVI(%i)",ma_period);
      m_label1="Main";
      m_drawtype1=DRAW_LINE;   
      m_label2="Signal";
      m_drawtype2=DRAW_LINE;        
      
      m_help=StringFormat("ma_period - Period1(%i)",ma_period);      
      
      m_digits=3;          
   }
};   

class COscUni_Stochastic:public COscUni_Calculate2{
   public:
   void COscUni_Stochastic(bool use_default,
                           bool keep_previous,
                           int & k_period,
                           int & d_period,
                           int & slowing,
                           long & ma_method,
                           long & sto_price
   ){
   
      if(use_default){
         if(keep_previous){
            if(k_period==-1)k_period=5;
            if(d_period==-1)d_period=3;
            if(slowing==-1)slowing=3;
            if(ma_method==-1)ma_method=MODE_SMA;
            if(sto_price==-1)sto_price=STO_LOWHIGH;     
         }
         else{
            k_period=5;
            d_period=3;
            slowing=3;
            ma_method=MODE_SMA;
            sto_price=STO_LOWHIGH;
         }      
      } 
        
      m_handle=iStochastic(Symbol(),
                           Period(),
                           k_period,
                           d_period,
                           slowing,
                           (ENUM_MA_METHOD)ma_method,
                           (ENUM_STO_PRICE)sto_price);
      
      m_name=StringFormat( "iStochastic(%i,%i,%i,%s,%s)",
                           k_period,
                           d_period,
                           slowing,
                           EnumToString((ENUM_MA_METHOD)ma_method),
                           EnumToString((ENUM_STO_PRICE)sto_price));
                           
      m_label1="Main";
      m_label2="Signal";      
      m_drawtype1=DRAW_LINE;             
      m_drawtype2=DRAW_LINE;
      
      m_help=StringFormat( "k_period - Period1(%i), "+
                           "d_period - Period2(%i), "+
                           "slowing - Period3(%i), "+
                           "ma_method - MaMethod(%s), "+
                           "sto_price - StPrice(%s)",
                           k_period,d_period,slowing,
                           EnumToString((ENUM_MA_METHOD)ma_method),
                           EnumToString((ENUM_STO_PRICE)sto_price)); 
                           
      m_digits=2;     
      m_levels_total=3;
      ArrayResize(m_level_value,3);
      m_level_value[0]=20;
      m_level_value[1]=50;  
      m_level_value[2]=80;                                          
   }
};


class COscUni_TRIX:public COscUni_Calculate1{
   public:
   void COscUni_TRIX(bool use_default,
                     bool keep_previous,
                     int & ma_period,
                     long & applied_price
   ){
   
      if(use_default){
         if(keep_previous){
            if(ma_period==-1)ma_period=14;
            if(applied_price==-1)applied_price=PRICE_CLOSE;            
         }
         else{
            ma_period=14;
            applied_price=PRICE_CLOSE;
         }      
      }
      
      m_handle=iTriX(Symbol(),
                     Period(),
                     ma_period,
                     (ENUM_APPLIED_PRICE)applied_price);
      
      m_name=StringFormat( "iTriX(%i,%s)",
                           ma_period,
                           EnumToString((ENUM_APPLIED_PRICE)applied_price));
                           
      m_label1="TriX";
      m_drawtype1=DRAW_LINE;
      
      m_help=StringFormat( "ma_period - Period1(%i), "+
                           "applied_price - Price(%s)",
                           ma_period,
                           EnumToString((ENUM_APPLIED_PRICE)applied_price));   
                           
      m_digits=_Digits+1;                           
   }
};


class COscUni_WPR:public COscUni_Calculate1{
   public:
   void COscUni_WPR(bool use_default,bool keep_previous,int & ma_period){
      if(use_default){
         if(keep_previous){
            if(ma_period==-1)ma_period=14;
         }
         else{
            ma_period=13;
         }      
      }    
      m_handle=iWPR(Symbol(),Period(),ma_period);
      m_name=StringFormat("WPR(%i)",ma_period);
      m_label1="WPR";
      m_drawtype1=DRAW_LINE;   
      m_help=StringFormat("ma_period - Period1(%i)",ma_period);    
      m_digits=2;   
      m_levels_total=3;
      ArrayResize(m_level_value,3);
      m_level_value[0]=-20;
      m_level_value[1]=-50;  
      m_level_value[2]=-80;        
               
   }
};   