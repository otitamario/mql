//+------------------------------------------------------------------+
//|                                                      iUniOsc.mq5 |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_separate_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot Label1
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Label2
#property indicator_label2  "Label2"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellow
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#include <UniOsc/UniOscDefines.mqh>
#include <UniOsc/CUniOsc.mqh>

//--- input parameters
input EOscUniType          Type        =  OscUni_ATR;
bool                 UseDefault  =  false;
bool                 KeepPrev    =  false;
input int                  Period1     =  14;
input int                  Period2     =  14;
input int                  Period3     =  14;
input ENUM_MA_METHOD       MaMethod    =  MODE_EMA;
input ENUM_APPLIED_PRICE   Price       =  PRICE_CLOSE;   
input ENUM_APPLIED_VOLUME  Volume      =  VOLUME_TICK;   
input ENUM_STO_PRICE       StPrice     =  STO_LOWHIGH;   
input color                ColorLine1  =  clrLightSeaGreen;
input color                ColorLine2  =  clrRed;
input color                ColorHisto  =  clrGray;

//--- indicator buffers

double         Label1Buffer[];
double         Label2Buffer[];

int                  _Period1;
int                  _Period2;
int                  _Period3;
long                 _MaMethod;
long                 _Price;   
long                 _Volume;   
long                 _StPrice; 
EOscUniType          _Type;

COscUni * osc;

string ProgName;
string ShortName;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(){

   SetIndexBuffer(0,Label1Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,Label2Buffer,INDICATOR_DATA);

   PrepareParameters();

   LoadOscillator();
   
   if(!osc.CheckHandle()){
      Alert("Ошибка загрузки индикатора "+osc.Name());
      return(INIT_FAILED);
   }

   SetStyles();
   
   Print("Parameters matching: "+osc.Help());
   
   ShortName=ProgName+": "+osc.Name();   
   IndicatorSetString(INDICATOR_SHORTNAME,ShortName);
   
   return(INIT_SUCCEEDED);
}
  
void OnDeinit(const int reason){
   delete(osc);
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
   
   osc.Calculate(rates_total,prev_calculated,Label1Buffer,Label2Buffer);
   
   return(rates_total);
}
//+------------------------------------------------------------------+

void PrepareParameters(){

   _Type=Type;

   if(UseDefault && KeepPrev){
      _Period1=-1;
      _Period2=-1;
      _Period3=-1;
      _MaMethod=-1;
      _Volume=-1;
      _Price=-1;   
      _StPrice=-1; 
   }
   else{   
      _Period1=Period1;
      _Period2=Period2;
      _Period3=Period3;
      _MaMethod=MaMethod;
      _Volume=Volume;
      _Price=Price;   
      _StPrice=StPrice;
   }
}

void LoadOscillator(){
   switch(_Type){
      case OscUni_ATR:
         osc=new COscUni_ATR(UseDefault,KeepPrev,_Period1);
      break;
      case OscUni_BearsPower:
         osc=new COscUni_BearsPower(UseDefault,KeepPrev,_Period1);
      break;
      case OscUni_BullsPower:
         osc=new COscUni_BullsPower(UseDefault,KeepPrev,_Period1);
      break;      
      case OscUni_CCI:
         osc=new COscUni_CCI(UseDefault,KeepPrev,_Period1,_Price);  
      break;         
      case OscUni_Chaikin:
         osc=new COscUni_Chaikin(UseDefault,KeepPrev,_Period1,_Period2,_MaMethod,_Volume);        
      break;         
      case OscUni_DeMarker:
         osc=new COscUni_DeMarker(UseDefault,KeepPrev,_Period1);
      break;         
      case OscUni_Force:
         osc=new COscUni_Force(UseDefault,KeepPrev,_Period1,_MaMethod,_Volume);      
      break;         
      case OscUni_Momentum:
         osc=new COscUni_Momentum(UseDefault,KeepPrev,_Period1,_Price);      
      break;         
      case OscUni_MACD:
         osc=new COscUni_MACD(UseDefault,KeepPrev,_Period1,_Period2,_Period3,_Price);
      break;        
      case OscUni_OsMA:
         osc=new COscUni_OsMA(UseDefault,KeepPrev,_Period1,_Period2,_Period3,_Price);      
      break;        
      case OscUni_RSI:
         osc=new COscUni_RSI(UseDefault,KeepPrev,_Period1,_Price); 
      break;        
      case OscUni_RVI:
         osc=new COscUni_RVI(UseDefault,KeepPrev,_Period1);      
      break;        
      case OscUni_Stochastic:
         osc=new COscUni_Stochastic(UseDefault,KeepPrev,_Period1,_Period2,_Period3,_MaMethod,_StPrice);
      break;        
      case OscUni_TriX:
         osc=new COscUni_TRIX(UseDefault,KeepPrev,_Period1,_Price);         
      break;        
      case OscUni_WPR:          
         osc=new COscUni_WPR(UseDefault,KeepPrev,_Period1);       
      break;     
   }   

}

void SetStyles(){   

   // установка стилей
   if(osc.BuffersCount()==2){
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,osc.DrawType1());
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,osc.DrawType2());
      PlotIndexSetInteger(0,PLOT_SHOW_DATA,true); 
      PlotIndexSetInteger(1,PLOT_SHOW_DATA,true); 
      PlotIndexSetString(0,PLOT_LABEL,osc.Label1()); 
      PlotIndexSetString(1,PLOT_LABEL,osc.Label2()); 
      if(osc.DrawType1()==DRAW_HISTOGRAM){
         PlotIndexSetInteger(0,PLOT_LINE_COLOR,ColorHisto);
      }
      else{
         PlotIndexSetInteger(0,PLOT_LINE_COLOR,ColorLine1);         
      }
      PlotIndexSetInteger(1,PLOT_LINE_COLOR,ColorLine2);   
   }
   else{
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE,osc.DrawType1());
      PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);   
      PlotIndexSetInteger(0,PLOT_SHOW_DATA,true); 
      PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);  
      PlotIndexSetString(0,PLOT_LABEL,osc.Label1());
      PlotIndexSetString(1,PLOT_LABEL,"");
      if(osc.DrawType1()==DRAW_HISTOGRAM){
         PlotIndexSetInteger(0,PLOT_LINE_COLOR,ColorHisto);
      }
      else{
         PlotIndexSetInteger(0,PLOT_LINE_COLOR,ColorLine1);         
      }        
   } 
   
   // установка digits
   IndicatorSetInteger(INDICATOR_DIGITS,osc.Digits());

   // установка уровней
   int levels=osc.LevelsTotal();
   IndicatorSetInteger(INDICATOR_LEVELS,levels);
   for(int i=0;i<levels;i++){
      IndicatorSetDouble(INDICATOR_LEVELVALUE,i,osc.LevelValue(i));
   }

}     

void SetToLabel(int obj_id,string val){
   string m_nm="OscUniParameters_"+IntegerToString(obj_id);
   if(ObjectFind(0,m_nm)==-1){
      ObjectCreate(0,m_nm,OBJ_LABEL,0,0,0);
      ObjectSetInteger(0,m_nm,OBJPROP_XDISTANCE,0);
      ObjectSetInteger(0,m_nm,OBJPROP_YDISTANCE,30+15*obj_id);      
                     
   }
   ObjectSetString(0,m_nm,OBJPROP_TEXT,val);  
}