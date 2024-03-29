//+------------------------------------------------------------------+
//|                                        KISTC_RENKO_GENERATOR.mq5 |
//|                Copyright 2011-2018, Keep It Simple Trading Corp. |
//|                                    http://www.keeptrading.com.br |
//+------------------------------------------------------------------+
#property strict
#property icon      "\\Files\\icon_s.ico"
#property link      "http://www.keeptrading.com.br"
#property copyright "Copyright 2011-2018, Keep It Simple Trading Corp."
#define   VERSION   "6.00"
#property version   VERSION
#property description "KISTC RENKO GENERATOR."
#property indicator_chart_window

#define d_ObjFunNom "image"

#include <MQL4MarketInfo.mqh>

//string NomeCliente="FELIPE DOS SANTOS FABOSSI"; //NOME DO USUÁRIO
//bool blockCliente;

enum enum_type
{
   r1=0, //Sem Sombra
   r2=1, //Com Sombra
};

input string      is_UniqueID             = "A1";           //Nome do Símbolo (Necessita ser diferente do nome original.)
input int         ii_LookBackBars         = 5000;           //Qtde de barras do histórico
input enum_type   ie_RenkoShadowType      = 1;              //0 = Sem Sombras, 1= Com Sombras
input int         ii_RenkoBoxSize         = 50;             //Tamanho da box em (Pontos)

ENUM_TIMEFRAMES   ge_SymbolPeriod;          // time frame 

MqlRates          rates[];
MqlRates          Temp_rates[];
MqlTick           ticks[];

bool              gb_HighUpdated = false;
bool              gb_LowUpdated = false;
bool              gb_InvalidBar = false;
bool              gb_IsFirstTime = true;
bool              new_bar = false;

datetime          gdt_StartDate;             // data copying start date 
datetime          gadt_TimeBuff[]; 
datetime          CustomSymbolLastBarTime;

double            gad_OpenBuff[]; 
double            gad_CloseBuff[]; 
double            gad_HighBuff[]; 
double            gad_LowBuff[]; 
double            gd_TempHighP = 0;
double            gd_TempLowP = 0;
double            gd_TempOpenP = 0;
double            gd_LastBarCloseP = 0;

long              gal_TickVolBuff[];
long              gal_RealVolBuff[];
long              gl_CreatedChartID = -1;
long              gl_LastTickTime;

int               gi_digits;
int               gi_TimeDiffSec=0;
int               gi_StartBarCount;
int               gai_SpreadlBuff[];
int               gd_LastBarTime = 0;
int               SymbolBarStartTime;

string            short_name;
string            ver="";
string            gs_CustomSymbolName;
string            gs_SymbolName;            // currency pair 
string            InpFileName;

MqlTick           SymbolTick;
MqlTick           CustomSymbolTicks[1]; 

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  /*
  blockCliente=  AccountInfoString(ACCOUNT_NAME)== NomeCliente;
  if( blockCliente==true)  
 {
  {
  
  Print("Liberado para uso."); */
  
  
  //Expiry date setting 
string ExpiryDate="2100.07.13";
if(TimeCurrent() >= StringToTime(ExpiryDate)){
Alert("O período de testes do KISTC RENKO GENERATOR expirou.");
ChartIndicatorDelete(0,0,"KISTC RENKO GENERATOR");
//ExpertRemove();
Print("Indicador removido devido ao periodo de utilização haver vencido. Nos contate para solicitar sua licença de uso!");
return(0);
}
else{
Print("KISTC RENKO GENERATOR liberado para uso até 13/07/2018");
  }
  
  IndicatorSetString(INDICATOR_SHORTNAME,"KISTC RENKO GENERATOR");
  
  ObjectCreate    (0,d_ObjFunNom,OBJ_BITMAP_LABEL,0,0,0); 
  ObjectSetInteger(0,d_ObjFunNom,OBJPROP_XDISTANCE,182); 
  ObjectSetInteger(0,d_ObjFunNom,OBJPROP_YDISTANCE,100);  
  ObjectSetInteger(0,d_ObjFunNom,OBJPROP_CORNER,CORNER_RIGHT_LOWER);  
  ObjectSetString (0,d_ObjFunNom,OBJPROP_BMPFILE,0,"\\Files\\image.bmp"); 
  ObjectSetInteger(0,d_ObjFunNom,OBJPROP_SELECTABLE,false); 
  ObjectSetInteger(0,d_ObjFunNom,OBJPROP_SELECTED  ,false); 
  ObjectSetInteger(0,d_ObjFunNom,OBJPROP_HIDDEN    ,false);
  
//--- indicator buffers mapping. 
   if((int)StringToDouble(VERSION)<10)
   {
      ver="0"+IntegerToString((int)StringToDouble(VERSION));
   }
   else
   {
      ver=IntegerToString((int)StringToDouble(VERSION));
   }
   
   short_name= "_KISTC_RENKO_GENERATOR_V"+ver+"_MT5";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   
   /*
   if(AccountInfoInteger(ACCOUNT_LOGIN) != 90295949)            //Account Number Updation
   {
      Alert("This Account Number is not valid for this Indicator");
      for(int i = 0; i<CHART_WINDOWS_TOTAL; i++)
      {
         if(ChartIndicatorDelete(0,i,short_name))
         break;
      }
   }
   */
   
   if(ObjectFind(0,"KISTC_Renko_Creator")<0)
   {
      indi_name();
   }
   
   gs_SymbolName = Symbol();
   ge_SymbolPeriod = (ENUM_TIMEFRAMES)Period();
   
   
   if(Bars(gs_SymbolName,ge_SymbolPeriod) < ii_LookBackBars)
      gi_StartBarCount = Bars(gs_SymbolName,ge_SymbolPeriod)-2;
   else
      gi_StartBarCount = ii_LookBackBars;
   
   gdt_StartDate = iTime(gs_SymbolName,ge_SymbolPeriod,gi_StartBarCount);
   
   gs_CustomSymbolName = "RN_"+gs_SymbolName+"_"+(string)ii_RenkoBoxSize+"_"+func_PeriodToStr()+"_"+is_UniqueID;
   
   InpFileName = "HPCS_Saved_Data\\"+gs_CustomSymbolName;
   
   gi_TimeDiffSec = func_New_Bar_Seconds();
   
   gi_digits = Digits();
   
   new_bar = false;
   
   if(SymbolInfoInteger(gs_CustomSymbolName,SYMBOL_CUSTOM))
   {
      Print(gs_CustomSymbolName+" chart already exist. Please wait while the chart is updated.");
      
      long currChart,prevChart=ChartFirst(); 
      int i=0; 
      bool chartfound = false;
      
      if(ChartSymbol(prevChart) == gs_CustomSymbolName)
      chartfound = true;
      else
      {
         while(i<100)// We have certainly not more than 100 open charts 
         { 
            currChart=ChartNext(prevChart);
            
            if(currChart<0)
               break;
               
            if(ChartSymbol(currChart) == gs_CustomSymbolName)
            {
               chartfound = true;
               break;
            }
            prevChart=currChart;
            i++;
         }
      }
      
      if(chartfound == false)
      {
         gl_CreatedChartID = ChartOpen(gs_CustomSymbolName,ge_SymbolPeriod);
      
         ChartSetInteger(gl_CreatedChartID,CHART_SHIFT,true);
         ChartSetInteger(gl_CreatedChartID,CHART_MODE,CHART_CANDLES);
      }
      
      if(RetriveTimeFromFile() == false || SymbolBarStartTime == 0)
      {
         Print(gs_CustomSymbolName+" chart saved data not found. Trying to resolve History data.");
                  
         SymbolBarStartTime = (int)iTime(gs_SymbolName,ge_SymbolPeriod,0);
         
         if(iClose(gs_CustomSymbolName,ge_SymbolPeriod,1) > iOpen(gs_CustomSymbolName,ge_SymbolPeriod,1))
         gd_LastBarCloseP = iClose(gs_CustomSymbolName,ge_SymbolPeriod,1);
         else
         gd_LastBarCloseP = iOpen(gs_CustomSymbolName,ge_SymbolPeriod,1);
         
         gd_LastBarTime = (int)iTime(gs_CustomSymbolName,ge_SymbolPeriod,0);
         
         if(gd_LastBarTime > TimeCurrent()-600)
         gl_LastTickTime = ((long)TimeCurrent()-600) * 1000;
         else
         gl_LastTickTime = (long)gd_LastBarTime * 1000;         
         
         gd_TempOpenP = gd_LastBarCloseP;
         
         gb_IsFirstTime = false;
      }
      else
      {
         gdt_StartDate = (datetime)SymbolBarStartTime;   
         UpdateAlreadyCreatedChart();
      }
   }
   else
   {
      if(!CustomSymbolCreate(gs_CustomSymbolName))
      {
         Print("Error Creation Custom Symbol "+gs_CustomSymbolName);
         Print("Error n° "+(string)GetLastError());
      }
      else
         Print("Custom Symbol "+gs_CustomSymbolName+" created. Please wait while the chart is updated.");
         
      CustomSymbolSetInteger(gs_CustomSymbolName,SYMBOL_VISIBLE,1);
      CustomSymbolSetInteger(gs_CustomSymbolName,SYMBOL_DIGITS,Digits());
      
      SymbolSelect(gs_CustomSymbolName,true);
            
      gl_CreatedChartID = ChartOpen(gs_CustomSymbolName,ge_SymbolPeriod);
   
      ChartSetInteger(gl_CreatedChartID,CHART_SHIFT,true);
      ChartSetInteger(gl_CreatedChartID,CHART_MODE,CHART_CANDLES);
      
      gb_IsFirstTime = true;
   }
   EventSetMillisecondTimer(100);      
//---
   return(INIT_SUCCEEDED);
  }
  
    //---
 /*
 } 

 }
 else{
 ChartIndicatorDelete(0,0,"KISTC RENKO GENERATOR");
 ExpertRemove();
 Print("Este indicador irá funcionar somente em contas previamente cadastradas pelo criador da ferramenta.");  
 Print("Favor contatar o criador da ferramenta se você possui autorização para uso da mesma.");   
             }
  return(INIT_SUCCEEDED);
  }  */ 
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+

void OnDeinit(const int reason)
{

ObjectDelete(0,d_ObjFunNom);

//---
   SaveDataArrayToFile();
   ObjectDelete(0,"KISTC_Renko_Creator");
}

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
//---  
      return(rates_total);
  }
  
void OnTimer()
{
   if(gb_IsFirstTime == true)
   {
      datetime ld_EndDate = TimeCurrent(); 

      //--- reset the error value 
      ResetLastError(); 
      
      CopyTime(gs_SymbolName,ge_SymbolPeriod,gdt_StartDate,ld_EndDate,gadt_TimeBuff);
      
      CopyHigh(gs_SymbolName,ge_SymbolPeriod,gdt_StartDate,ld_EndDate,gad_HighBuff);
      
      CopyLow(gs_SymbolName,ge_SymbolPeriod,gdt_StartDate,ld_EndDate,gad_LowBuff);
      
      CopyOpen(gs_SymbolName,ge_SymbolPeriod,gdt_StartDate,ld_EndDate,gad_OpenBuff);
      
      CopyClose(gs_SymbolName,ge_SymbolPeriod,gdt_StartDate,ld_EndDate,gad_CloseBuff);
      
      CopyTickVolume(gs_SymbolName,ge_SymbolPeriod,gdt_StartDate,ld_EndDate,gal_TickVolBuff);
      
      CopyRealVolume(gs_SymbolName,ge_SymbolPeriod,gdt_StartDate,ld_EndDate,gal_RealVolBuff);
      
      CopySpread(gs_SymbolName,ge_SymbolPeriod,gdt_StartDate,ld_EndDate,gai_SpreadlBuff);

      gd_LastBarCloseP = gad_OpenBuff[0];
            
      for(int j=0; j<ArraySize(gadt_TimeBuff); j++)
      {
         SymbolBarStartTime = (int)gadt_TimeBuff[j];
         
         if(gd_LastBarCloseP < gad_CloseBuff[j])
         {
            while(MathAbs(gd_LastBarCloseP - gad_CloseBuff[j]) > ii_RenkoBoxSize*Point())
            {
               ArrayResize(rates,ArraySize(rates)+1);
               
               //------------------Time Management----------
               if(gd_LastBarTime > (int)gadt_TimeBuff[j])
                  gadt_TimeBuff[j] = (datetime)gd_LastBarTime;
               
               rates[ArraySize(rates)-1].time = gadt_TimeBuff[j];
               
               gd_LastBarTime = (int)gadt_TimeBuff[j]+gi_TimeDiffSec;
               if(DayOfWeek(gd_LastBarTime) == 6)
               gd_LastBarTime = gd_LastBarTime + 2*24*60*60;
               //------------------Time Management----------
            
               rates[ArraySize(rates)-1].open = gd_LastBarCloseP;
               rates[ArraySize(rates)-1].high = gd_LastBarCloseP+ii_RenkoBoxSize*Point();
               rates[ArraySize(rates)-1].low = gd_LastBarCloseP;
               rates[ArraySize(rates)-1].close = gd_LastBarCloseP+ii_RenkoBoxSize*Point();
               
               if(gal_TickVolBuff[j] < 4)
               gal_TickVolBuff[j] = 4;
               rates[ArraySize(rates)-1].tick_volume = gal_TickVolBuff[j];
               
               if(gal_RealVolBuff[j] < 4)
               gal_RealVolBuff[j] = 4;
               rates[ArraySize(rates)-1].real_volume = gal_RealVolBuff[j];
               rates[ArraySize(rates)-1].spread = gai_SpreadlBuff[j];
               
               gd_LastBarCloseP = gd_LastBarCloseP+ii_RenkoBoxSize*Point();
                              
               //CustomRatesUpdate(gs_CustomSymbolName,rates); 
            }
         }
         else if(gd_LastBarCloseP > gad_CloseBuff[j])
         {
            while(MathAbs(gd_LastBarCloseP - gad_CloseBuff[j]) > (2*(ii_RenkoBoxSize*Point())))
            {
            
               ArrayResize(rates,ArraySize(rates)+1);
               
               //------------------Time Management----------
               if(gd_LastBarTime > (int)gadt_TimeBuff[j])
                  gadt_TimeBuff[j] = (datetime)gd_LastBarTime;
                  
               rates[ArraySize(rates)-1].time = gadt_TimeBuff[j];
               
               gd_LastBarTime = (int)gadt_TimeBuff[j]+gi_TimeDiffSec;
               if(DayOfWeek(gd_LastBarTime) == 6)
               gd_LastBarTime = gd_LastBarTime + 2*24*60*60;
               //------------------Time Management----------
               
               rates[ArraySize(rates)-1].open = gd_LastBarCloseP-ii_RenkoBoxSize*Point();
               rates[ArraySize(rates)-1].high = gd_LastBarCloseP-ii_RenkoBoxSize*Point();
               rates[ArraySize(rates)-1].low = gd_LastBarCloseP -(2*(ii_RenkoBoxSize*Point()));
               rates[ArraySize(rates)-1].close = gd_LastBarCloseP -(2*(ii_RenkoBoxSize*Point()));
               
               if(gal_TickVolBuff[j] < 4)
               gal_TickVolBuff[j] = 4;
               rates[ArraySize(rates)-1].tick_volume = gal_TickVolBuff[j];
               
               if(gal_RealVolBuff[j] < 4)
               gal_RealVolBuff[j] = 4;
               rates[ArraySize(rates)-1].real_volume = gal_RealVolBuff[j];
               
               rates[ArraySize(rates)-1].spread = gai_SpreadlBuff[j];

               gd_LastBarCloseP = gd_LastBarCloseP-ii_RenkoBoxSize*Point();
               
               //CustomRatesUpdate(gs_CustomSymbolName,rates);
            }
         }
      }
      
      CustomRatesUpdate(gs_CustomSymbolName,rates);
      
      gd_TempOpenP = gd_LastBarCloseP;
      
      CustomSymbolLastBarTime = gd_LastBarTime;
      SaveTimeToFile();
      
      if(gd_LastBarTime > TimeCurrent()-600 || gd_LastBarTime == 0)
      gl_LastTickTime = ((long)TimeCurrent()-600) * 1000;
      else
      gl_LastTickTime = (long)gd_LastBarTime * 1000; 
      
      ArrayCopy(Temp_rates,rates);
      SaveDataArrayToFile(); 
      
      ArrayResize(rates,1);
            
      gb_IsFirstTime = false;
      return;
   }
   else
   {
      if(iBarShift(gs_SymbolName,ge_SymbolPeriod,(datetime)SymbolBarStartTime) > 5)
      {
         gdt_StartDate = (datetime)SymbolBarStartTime;
         UpdateAlreadyCreatedChart();
      }
      
      if((int)iTime(gs_SymbolName,ge_SymbolPeriod,0) != SymbolBarStartTime)
      {
         SymbolBarStartTime = (int)iTime(gs_SymbolName,ge_SymbolPeriod,0);
         CustomSymbolLastBarTime = gd_LastBarTime;
         SaveTimeToFile();
      }
      
      if(SymbolInfoTick(gs_SymbolName,SymbolTick))
      {
         if(CustomSymbolTicks[0].bid != SymbolTick.bid || CustomSymbolTicks[0].ask != SymbolTick.ask)
         gl_LastTickTime++;
         
         CustomSymbolTicks[0].ask = SymbolTick.ask;
         CustomSymbolTicks[0].bid = SymbolTick.bid;
         CustomSymbolTicks[0].last = SymbolTick.last;
         CustomSymbolTicks[0].time_msc = gl_LastTickTime;
         CustomTicksAdd(gs_CustomSymbolName,CustomSymbolTicks);
         SaveTimeToFile();
      }
      
      if(NormalizeDouble(gd_LastBarCloseP,gi_digits) < NormalizeDouble(SymbolTick.bid,gi_digits))                                                     //Bullish Bar
      {
         if(NormalizeDouble(MathAbs(gd_LastBarCloseP - SymbolTick.bid),gi_digits) > ii_RenkoBoxSize*Point())
         {                 
            rates[0].close = NormalizeDouble(NormalizeDouble(gd_LastBarCloseP,gi_digits)+ii_RenkoBoxSize*Point(),gi_digits);
            rates[0].high = NormalizeDouble(NormalizeDouble(gd_LastBarCloseP,gi_digits)+ii_RenkoBoxSize*Point(),gi_digits);
            rates[0].open = NormalizeDouble(gd_LastBarCloseP,gi_digits);
            gd_TempOpenP =  NormalizeDouble(gd_LastBarCloseP,gi_digits);
         
            if(gb_LowUpdated == true)
            {
               if(ie_RenkoShadowType == 1)
                  rates[0].low = gd_TempLowP;
               else
                  rates[0].low = NormalizeDouble(gd_LastBarCloseP,gi_digits);
            }
            else
               rates[0].low = NormalizeDouble(gd_LastBarCloseP,gi_digits);
         
            CopyTickVolume(gs_SymbolName,ge_SymbolPeriod,0,1,gal_TickVolBuff);
            CopyRealVolume(gs_SymbolName,ge_SymbolPeriod,0,1,gal_RealVolBuff);
            CopySpread(gs_SymbolName,ge_SymbolPeriod,0,1,gai_SpreadlBuff);
        
            if(gai_SpreadlBuff[0] < 0)
              gai_SpreadlBuff[0] = 0;
            rates[0].spread = gai_SpreadlBuff[0];
         
            if(gal_RealVolBuff[0] < 4)
               gal_RealVolBuff[0] = 4;
            rates[0].real_volume = gal_RealVolBuff[0];
            
            if(gal_TickVolBuff[0] < 4)
               gal_TickVolBuff[0] = 4;
            rates[0].tick_volume = gal_TickVolBuff[0];
         
            rates[0].time = (datetime)gd_LastBarTime;
            
            if(rates[0].open < rates[0].low)
            rates[0].low = rates[0].open;
         
            CustomRatesReplace(gs_CustomSymbolName,(datetime)gd_LastBarTime,(datetime)(gd_LastBarTime+gi_TimeDiffSec),rates);
            
            ArrayResize(Temp_rates,ArraySize(Temp_rates)+1); 
            
            Temp_rates[ArraySize(Temp_rates)-1].close = rates[0].close;
            Temp_rates[ArraySize(Temp_rates)-1].high = rates[0].high;
            Temp_rates[ArraySize(Temp_rates)-1].low = rates[0].low;
            Temp_rates[ArraySize(Temp_rates)-1].open = rates[0].open;
            Temp_rates[ArraySize(Temp_rates)-1].real_volume = rates[0].real_volume;
            Temp_rates[ArraySize(Temp_rates)-1].spread = rates[0].spread;
            Temp_rates[ArraySize(Temp_rates)-1].tick_volume = rates[0].tick_volume;
            Temp_rates[ArraySize(Temp_rates)-1].time = rates[0].time;
            
            SaveDataArrayToFile(); 
            
            CopyTime(gs_SymbolName,ge_SymbolPeriod,0,1,gadt_TimeBuff);           
            gd_LastBarTime = gd_LastBarTime+gi_TimeDiffSec;
            
            if(gd_LastBarTime < (int)gadt_TimeBuff[0])
               gd_LastBarTime = (int)gadt_TimeBuff[0];
               
            if(DayOfWeek(gd_LastBarTime) == 6)
            gd_LastBarTime = gd_LastBarTime + 2*24*60*60;   
               
            CustomSymbolLastBarTime = gd_LastBarTime;
            SaveTimeToFile();
                                 
            gd_LastBarCloseP = NormalizeDouble(NormalizeDouble(gd_LastBarCloseP,gi_digits)+ii_RenkoBoxSize*Point(),gi_digits);
            //gd_LastBarTime = (int)gadt_TimeBuff[0]+gi_TimeDiffSec;
            gb_HighUpdated = false;
            gb_LowUpdated = false;
            gd_TempHighP = 0;
            gd_TempLowP = 0;
            
            return;
         }
         else
         {            
            rates[0].close = NormalizeDouble(SymbolTick.bid,gi_digits);
            
            if(gd_TempHighP == 0)
               gd_TempHighP = NormalizeDouble(gd_LastBarCloseP,gi_digits);
            
            if(NormalizeDouble(SymbolTick.bid,gi_digits)>gd_TempHighP)
               gd_TempHighP = NormalizeDouble(SymbolTick.bid,gi_digits);
            
            rates[0].high = gd_TempHighP;
            rates[0].open = NormalizeDouble(gd_LastBarCloseP,gi_digits);
            gd_TempOpenP =  NormalizeDouble(gd_LastBarCloseP,gi_digits);

            if(gb_LowUpdated == true)
            {
               if(ie_RenkoShadowType == 1)
                  rates[0].low = gd_TempLowP;
               else
                  rates[0].low = NormalizeDouble(gd_LastBarCloseP,gi_digits);
            }
            else
               rates[0].low = NormalizeDouble(gd_LastBarCloseP,gi_digits);
            
            CopyTickVolume(gs_SymbolName,ge_SymbolPeriod,0,1,gal_TickVolBuff);
            CopyRealVolume(gs_SymbolName,ge_SymbolPeriod,0,1,gal_RealVolBuff);
            CopySpread(gs_SymbolName,ge_SymbolPeriod,0,1,gai_SpreadlBuff);
            
            if(gai_SpreadlBuff[0] < 0)
              gai_SpreadlBuff[0] = 0;
            rates[0].spread = gai_SpreadlBuff[0];
         
            if(gal_RealVolBuff[0] < 4)
               gal_RealVolBuff[0] = 4;
            rates[0].real_volume = gal_RealVolBuff[0];
            
            if(gal_TickVolBuff[0] < 4)
               gal_TickVolBuff[0] = 4;
            rates[0].tick_volume = gal_TickVolBuff[0];
            
            rates[0].time = (datetime)gd_LastBarTime;
            
            if(rates[0].open < rates[0].low)
            rates[0].low = rates[0].open;
                        
            CustomRatesReplace(gs_CustomSymbolName,(datetime)gd_LastBarTime,(datetime)(gd_LastBarTime+gi_TimeDiffSec),rates);
            
            gb_HighUpdated = true;
            gb_InvalidBar = true;
            return;
         }
      }
      else if(NormalizeDouble(NormalizeDouble(gd_LastBarCloseP,gi_digits)-(ii_RenkoBoxSize*Point()),gi_digits) > NormalizeDouble(SymbolTick.bid,gi_digits))                           //Bearish Bar
      {
         if(NormalizeDouble(MathAbs(gd_LastBarCloseP - SymbolTick.bid),gi_digits) > (2*(ii_RenkoBoxSize*Point())))
         {
            rates[0].close = NormalizeDouble(NormalizeDouble(gd_LastBarCloseP,gi_digits)-(2*(ii_RenkoBoxSize*Point())),gi_digits);
            rates[0].low = NormalizeDouble(NormalizeDouble(gd_LastBarCloseP,gi_digits)-(2*(ii_RenkoBoxSize*Point())),gi_digits);
            rates[0].open = NormalizeDouble(NormalizeDouble(gd_LastBarCloseP,gi_digits)-ii_RenkoBoxSize*Point(),gi_digits);
            gd_TempOpenP =  NormalizeDouble(NormalizeDouble(gd_LastBarCloseP,gi_digits)-ii_RenkoBoxSize*Point(),gi_digits);
         
            if(gb_HighUpdated == true)
            {
               if(ie_RenkoShadowType == 1)
                  rates[0].high = gd_TempHighP;
               else
                  rates[0].high = NormalizeDouble(NormalizeDouble(gd_LastBarCloseP,gi_digits)-ii_RenkoBoxSize*Point(),gi_digits);
            }
            else
               rates[0].high = NormalizeDouble(NormalizeDouble(gd_LastBarCloseP,gi_digits)-ii_RenkoBoxSize*Point(),gi_digits);
         
            CopyTickVolume(gs_SymbolName,ge_SymbolPeriod,0,1,gal_TickVolBuff);
            CopyRealVolume(gs_SymbolName,ge_SymbolPeriod,0,1,gal_RealVolBuff);
            CopySpread(gs_SymbolName,ge_SymbolPeriod,0,1,gai_SpreadlBuff);
         
            if(gai_SpreadlBuff[0] < 0)
              gai_SpreadlBuff[0] = 0; 
            rates[0].spread = gai_SpreadlBuff[0];
         
            if(gal_RealVolBuff[0] < 4)
               gal_RealVolBuff[0] = 4;
            rates[0].real_volume = gal_RealVolBuff[0];
            
            if(gal_TickVolBuff[0] < 4)
               gal_TickVolBuff[0] = 4;
            rates[0].tick_volume = gal_TickVolBuff[0];
                     
            rates[0].time = (datetime)gd_LastBarTime;
            
            if(rates[0].open > rates[0].high)
            rates[0].high = rates[0].open;
         
            CustomRatesReplace(gs_CustomSymbolName,(datetime)gd_LastBarTime,(datetime)(gd_LastBarTime+gi_TimeDiffSec),rates);
            
            ArrayResize(Temp_rates,ArraySize(Temp_rates)+1); 
            
            Temp_rates[ArraySize(Temp_rates)-1].close = rates[0].close;
            Temp_rates[ArraySize(Temp_rates)-1].high = rates[0].high;
            Temp_rates[ArraySize(Temp_rates)-1].low = rates[0].low;
            Temp_rates[ArraySize(Temp_rates)-1].open = rates[0].open;
            Temp_rates[ArraySize(Temp_rates)-1].real_volume = rates[0].real_volume;
            Temp_rates[ArraySize(Temp_rates)-1].spread = rates[0].spread;
            Temp_rates[ArraySize(Temp_rates)-1].tick_volume = rates[0].tick_volume;
            Temp_rates[ArraySize(Temp_rates)-1].time = rates[0].time;
            
            SaveDataArrayToFile(); 
            
            CopyTime(gs_SymbolName,ge_SymbolPeriod,0,1,gadt_TimeBuff);
            gd_LastBarTime = gd_LastBarTime+gi_TimeDiffSec;
            
            if(gd_LastBarTime < (int)gadt_TimeBuff[0])
               gd_LastBarTime = (int)gadt_TimeBuff[0];
               
            if(DayOfWeek(gd_LastBarTime) == 6)
            gd_LastBarTime = gd_LastBarTime + 2*24*60*60;   
               
            CustomSymbolLastBarTime = gd_LastBarTime;
            SaveTimeToFile();  
                     
            gd_LastBarCloseP = NormalizeDouble(NormalizeDouble(gd_LastBarCloseP,gi_digits)-ii_RenkoBoxSize*Point(),gi_digits);
            gb_HighUpdated = false;
            gb_LowUpdated = false;
            gd_TempHighP = 0;
            gd_TempLowP = 0;
            return;
         }
         else
         {            
            rates[0].close = NormalizeDouble(SymbolTick.bid,gi_digits);
            
            if(gd_TempLowP == 0)
               gd_TempLowP = NormalizeDouble(NormalizeDouble(gd_LastBarCloseP,gi_digits)-ii_RenkoBoxSize*Point(),gi_digits);
            
            if(NormalizeDouble(SymbolTick.bid,gi_digits)<gd_TempLowP)
               gd_TempLowP = NormalizeDouble(SymbolTick.bid,gi_digits);
            
            rates[0].low = gd_TempLowP;
            rates[0].open = NormalizeDouble(NormalizeDouble(gd_LastBarCloseP,gi_digits)-ii_RenkoBoxSize*Point(),gi_digits);
            gd_TempOpenP =  NormalizeDouble(NormalizeDouble(gd_LastBarCloseP,gi_digits)-ii_RenkoBoxSize*Point(),gi_digits);

            if(gb_HighUpdated == true)
            {
               if(ie_RenkoShadowType == 1)
                  rates[0].high = gd_TempHighP;
               else
                  rates[0].high = NormalizeDouble(NormalizeDouble(gd_LastBarCloseP,gi_digits)-ii_RenkoBoxSize*Point(),gi_digits);
            }
            else
               rates[0].high = NormalizeDouble(NormalizeDouble(gd_LastBarCloseP,gi_digits)-ii_RenkoBoxSize*Point(),gi_digits);
            
            CopyTickVolume(gs_SymbolName,ge_SymbolPeriod,0,1,gal_TickVolBuff);
            CopyRealVolume(gs_SymbolName,ge_SymbolPeriod,0,1,gal_RealVolBuff);
            CopySpread(gs_SymbolName,ge_SymbolPeriod,0,1,gai_SpreadlBuff);
         
            if(gai_SpreadlBuff[0] < 0)
              gai_SpreadlBuff[0] = 0;
            rates[0].spread = gai_SpreadlBuff[0];
         
            if(gal_RealVolBuff[0] < 4)
               gal_RealVolBuff[0] = 4;
            rates[0].real_volume = gal_RealVolBuff[0];
            
            if(gal_TickVolBuff[0] < 4)
               gal_TickVolBuff[0] = 4;
            rates[0].tick_volume = gal_TickVolBuff[0];
                       
            rates[0].time = (datetime)gd_LastBarTime;
            
            if(rates[0].open > rates[0].high)
            rates[0].high = rates[0].open;
                     
            CustomRatesReplace(gs_CustomSymbolName,(datetime)gd_LastBarTime,(datetime)(gd_LastBarTime+gi_TimeDiffSec),rates);
         
            gb_LowUpdated = true;
            gb_InvalidBar = true;
            return;
         }
      }
      else                                                               //Invalid Renko Bar
      {
         rates[0].close = NormalizeDouble(SymbolTick.bid,gi_digits);
            
         if(gd_TempLowP == 0)
            gd_TempLowP = gd_TempOpenP;
         
         if(gd_TempHighP == 0)
            gd_TempHighP = gd_TempOpenP;
         
         if(NormalizeDouble(SymbolTick.bid,gi_digits)<gd_TempLowP)
            gd_TempLowP = NormalizeDouble(SymbolTick.bid,gi_digits);

         rates[0].low = gd_TempLowP;
         rates[0].open = gd_TempOpenP;
         
         if(NormalizeDouble(SymbolTick.bid,gi_digits)>gd_TempHighP)
            gd_TempHighP = NormalizeDouble(SymbolTick.bid,gi_digits);
         
         rates[0].high = gd_TempHighP;
         
         CopyTickVolume(gs_SymbolName,ge_SymbolPeriod,0,1,gal_TickVolBuff);
         CopyRealVolume(gs_SymbolName,ge_SymbolPeriod,0,1,gal_RealVolBuff);
         CopySpread(gs_SymbolName,ge_SymbolPeriod,0,1,gai_SpreadlBuff);
         
         if(gai_SpreadlBuff[0] < 0)
           gai_SpreadlBuff[0] = 0;
         rates[0].spread = gai_SpreadlBuff[0];
      
         if(gal_RealVolBuff[0] < 4)
            gal_RealVolBuff[0] = 4;
         rates[0].real_volume = gal_RealVolBuff[0];
         
         if(gal_TickVolBuff[0] < 4)
            gal_TickVolBuff[0] = 4;
         rates[0].tick_volume = gal_TickVolBuff[0];
       
         rates[0].time = (datetime)gd_LastBarTime;
         
         CustomRatesReplace(gs_CustomSymbolName,(datetime)gd_LastBarTime,(datetime)(gd_LastBarTime+gi_TimeDiffSec),rates);
         
         gb_HighUpdated = true;
         gb_LowUpdated = true;
         return;
      }
   }

//--- return value of prev_calculated for next call
  }
//+------------------------------------------------------------------+

void UpdateAlreadyCreatedChart()
{        
   datetime ld_EndDate = TimeCurrent(); 
   //--- reset the error value 
   ResetLastError();
   
   if(RetriveDataArrayFromFile())
   { 
      //CustomRatesDelete(gs_CustomSymbolName,iTime(gs_CustomSymbolName,ge_SymbolPeriod,iBars(gs_CustomSymbolName,ge_SymbolPeriod)-1),CustomSymbolLastBarTime);
      
      if(rates[ArraySize(rates)-1].close > rates[ArraySize(rates)-1].open)
      gd_LastBarCloseP = NormalizeDouble(rates[ArraySize(rates)-1].close,gi_digits);
      else
      gd_LastBarCloseP = NormalizeDouble(rates[ArraySize(rates)-1].open,gi_digits);
   }
   else
   {
      if(iClose(gs_CustomSymbolName,ge_SymbolPeriod,1) > iOpen(gs_CustomSymbolName,ge_SymbolPeriod,1))
      gd_LastBarCloseP = iClose(gs_CustomSymbolName,ge_SymbolPeriod,1);
      else
      gd_LastBarCloseP = iOpen(gs_CustomSymbolName,ge_SymbolPeriod,1);
   }
   
   CopyTime(gs_SymbolName,ge_SymbolPeriod,gdt_StartDate,ld_EndDate,gadt_TimeBuff);
   
   CopyHigh(gs_SymbolName,ge_SymbolPeriod,gdt_StartDate,ld_EndDate,gad_HighBuff);
   
   CopyLow(gs_SymbolName,ge_SymbolPeriod,gdt_StartDate,ld_EndDate,gad_LowBuff);
   
   CopyOpen(gs_SymbolName,ge_SymbolPeriod,gdt_StartDate,ld_EndDate,gad_OpenBuff);
   
   CopyClose(gs_SymbolName,ge_SymbolPeriod,gdt_StartDate,ld_EndDate,gad_CloseBuff);
   
   CopyTickVolume(gs_SymbolName,ge_SymbolPeriod,gdt_StartDate,ld_EndDate,gal_TickVolBuff);
   
   CopyRealVolume(gs_SymbolName,ge_SymbolPeriod,gdt_StartDate,ld_EndDate,gal_RealVolBuff);
   
   CopySpread(gs_SymbolName,ge_SymbolPeriod,gdt_StartDate,ld_EndDate,gai_SpreadlBuff);
   
   gd_LastBarTime = (int)CustomSymbolLastBarTime;
            
   for(int j=0; j<ArraySize(gadt_TimeBuff); j++)
   {
      SymbolBarStartTime = (int)gadt_TimeBuff[j];
      
      if(gd_LastBarCloseP < gad_CloseBuff[j])
      {
         while(MathAbs(gd_LastBarCloseP - gad_CloseBuff[j]) > ii_RenkoBoxSize*Point())
         {
            ArrayResize(rates,ArraySize(rates)+1);
            
            //------------------Time Management----------
            if(gd_LastBarTime > (int)gadt_TimeBuff[j])
               gadt_TimeBuff[j] = (datetime)gd_LastBarTime;
            
            rates[ArraySize(rates)-1].time = gadt_TimeBuff[j];
            
            gd_LastBarTime = (int)gadt_TimeBuff[j]+gi_TimeDiffSec;
            
            if(DayOfWeek(gd_LastBarTime) == 6)
               gd_LastBarTime = gd_LastBarTime + 2*24*60*60;
            //------------------Time Management----------
         
            rates[ArraySize(rates)-1].open = gd_LastBarCloseP;
            rates[ArraySize(rates)-1].high = gd_LastBarCloseP+ii_RenkoBoxSize*Point();
            rates[ArraySize(rates)-1].low = gd_LastBarCloseP;
            rates[ArraySize(rates)-1].close = gd_LastBarCloseP+ii_RenkoBoxSize*Point();
            
            if(gal_TickVolBuff[j] < 4)
            gal_TickVolBuff[j] = 4;
            rates[ArraySize(rates)-1].tick_volume = gal_TickVolBuff[j];
            
            if(gal_RealVolBuff[j] < 4)
            gal_RealVolBuff[j] = 4;
            rates[ArraySize(rates)-1].real_volume = gal_RealVolBuff[j];
            rates[ArraySize(rates)-1].spread = gai_SpreadlBuff[j];
            
            gd_LastBarCloseP = gd_LastBarCloseP+ii_RenkoBoxSize*Point();
            
            //CustomRatesUpdate(gs_CustomSymbolName,rates); 
         }
      }
      else if(gd_LastBarCloseP > gad_CloseBuff[j])
      {
         while(MathAbs(gd_LastBarCloseP - gad_CloseBuff[j]) > (2*(ii_RenkoBoxSize*Point())))
         {
         
            ArrayResize(rates,ArraySize(rates)+1);
            
            //------------------Time Management----------
            if(gd_LastBarTime > (int)gadt_TimeBuff[j])
               gadt_TimeBuff[j] = (datetime)gd_LastBarTime;
         
            rates[ArraySize(rates)-1].time = gadt_TimeBuff[j];
            
            gd_LastBarTime = (int)gadt_TimeBuff[j]+gi_TimeDiffSec;
            if(DayOfWeek(gd_LastBarTime) == 6)
               gd_LastBarTime = gd_LastBarTime + 2*24*60*60;
            //------------------Time Management----------
            
            rates[ArraySize(rates)-1].open = gd_LastBarCloseP-ii_RenkoBoxSize*Point();
            rates[ArraySize(rates)-1].high = gd_LastBarCloseP-ii_RenkoBoxSize*Point();
            rates[ArraySize(rates)-1].low = gd_LastBarCloseP -(2*(ii_RenkoBoxSize*Point()));
            rates[ArraySize(rates)-1].close = gd_LastBarCloseP -(2*(ii_RenkoBoxSize*Point()));
            
            if(gal_TickVolBuff[j] < 4)
            gal_TickVolBuff[j] = 4;
            rates[ArraySize(rates)-1].tick_volume = gal_TickVolBuff[j];
            
            if(gal_RealVolBuff[j] < 4)
            gal_RealVolBuff[j] = 4;
            rates[ArraySize(rates)-1].real_volume = gal_RealVolBuff[j];
            
            rates[ArraySize(rates)-1].spread = gai_SpreadlBuff[j];

            gd_LastBarCloseP = gd_LastBarCloseP-ii_RenkoBoxSize*Point();
            
            //CustomRatesUpdate(gs_CustomSymbolName,rates);
         }
      }
   }
    
   CustomRatesReplace(gs_CustomSymbolName,0,(datetime)gd_LastBarTime,rates);
  
   gd_TempOpenP = gd_LastBarCloseP;
   
   CustomSymbolLastBarTime = gd_LastBarTime;
   SaveTimeToFile();
      
   ArrayCopy(Temp_rates,rates);
   SaveDataArrayToFile(); 
   
   ArrayResize(rates,1);
      
   gb_IsFirstTime = false;
}

int func_New_Bar_Seconds()
{
   switch (Period())
   {
     case PERIOD_M1:   return(1*60);  break;
     case PERIOD_M2:   return(2*60);  break;
     case PERIOD_M3:  return(3*60);  break;
     case PERIOD_M4:  return(4*60);  break;
     case PERIOD_M5:   return(5*60);  break;
     case PERIOD_M6:   return(6*60);  break;
     case PERIOD_M10:   return(10*60);  break;
     case PERIOD_M12:   return(12*60);  break;
     case PERIOD_M15:  return(15*60);  break;
     case PERIOD_M20:   return(20*60);  break;
     case PERIOD_M30:  return(30*60);  break;
     case PERIOD_H1:   return(1*60*60);  break;
     case PERIOD_H2:   return(2*60*60);  break;
     case PERIOD_H3:   return(3*60*60);  break;
     case PERIOD_H4:   return(4*60*60);  break;
     case PERIOD_H6:   return(6*60*60);  break;
     case PERIOD_H8:   return(8*60*60);  break;
     case PERIOD_H12:   return(12*60*60);  break;
     case PERIOD_D1:   return(24*60*60);  break;
     case PERIOD_W1:   return(7*24*60*60);  break;
     case PERIOD_MN1:  return(30*24*60*60);  break;
   }
   return 0;
}

string func_PeriodToStr()
{
   switch (Period())
   {
     case PERIOD_M1:   return("M1");  break;
     case PERIOD_M2:   return("M2");  break;
     case PERIOD_M3:  return("M3");  break;
     case PERIOD_M4:  return("M4");  break;
     case PERIOD_M5:   return("M5");  break;
     case PERIOD_M6:   return("M6");  break;
     case PERIOD_M10:   return("M10");  break;
     case PERIOD_M12:   return("M12");  break;
     case PERIOD_M15:  return("M15");  break;
     case PERIOD_M20:   return("M20");  break;
     case PERIOD_M30:  return("M30");  break;
     case PERIOD_H1:   return("H1");  break;
     case PERIOD_H2:   return("H2");  break;
     case PERIOD_H3:   return("H3");  break;
     case PERIOD_H4:   return("H4");  break;
     case PERIOD_H6:   return("H6");  break;
     case PERIOD_H8:   return("H8");  break;
     case PERIOD_H12:   return("H12");  break;
     case PERIOD_D1:   return("D1");  break;
     case PERIOD_W1:   return("W1");  break;
     case PERIOD_MN1:  return("MN1");  break;
   }
   return "";
}

bool indi_name()
{
   if(!ObjectCreate(0,"KISTC_Renko_Creator",OBJ_LABEL,0,0,0))
   {
      Print(__FUNCTION__,
            ": failed to create text label! Error code = ",GetLastError());
      return(false);
   }
   ObjectSetInteger(0,"KISTC_Renko_Creator",OBJPROP_XDISTANCE,245);
   ObjectSetInteger(0,"KISTC_Renko_Creator",OBJPROP_YDISTANCE,10);
   ObjectSetInteger(0,"KISTC_Renko_Creator",OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetString(0,"KISTC_Renko_Creator",OBJPROP_TEXT,short_name);
   ObjectSetInteger(0,"KISTC_Renko_Creator",OBJPROP_FONTSIZE,8);
   ObjectSetInteger(0,"KISTC_Renko_Creator",OBJPROP_ANCHOR,ANCHOR_BOTTOM);
   ObjectSetInteger(0,"KISTC_Renko_Creator",OBJPROP_COLOR,clrWhite);
   ObjectSetInteger(0,"KISTC_Renko_Creator",OBJPROP_BACK,true);
   return(true);
 }
 
void SaveTimeToFile()
{   
   int file_handle = FileOpen(InpFileName+".txt",FILE_WRITE|FILE_SHARE_WRITE|FILE_TXT);
   if(file_handle != INVALID_HANDLE)
   { 
      string value   = IntegerToString(SymbolBarStartTime) + "\r\n" + IntegerToString(CustomSymbolLastBarTime) + "\r\n" + IntegerToString(gl_LastTickTime);
      
      FileWriteString(file_handle, value);
      FileClose(file_handle);
   }
}

bool RetriveTimeFromFile()
{   
   int file_handle = FileOpen(InpFileName+".txt", FILE_READ|FILE_SHARE_READ|FILE_TXT);
   if(file_handle != INVALID_HANDLE)
   {
      string value;   
      value = FileReadString(file_handle);
      SymbolBarStartTime = (int)StringToInteger(value);
      value = FileReadString(file_handle);
      CustomSymbolLastBarTime = (datetime)(StringToInteger(value));
      value = FileReadString(file_handle);
      gl_LastTickTime = StringToInteger(value);
      
      FileClose(file_handle);
      return true;
   }
   return false;
}

void SaveDataArrayToFile()
{   
   int file_handle = FileOpen(InpFileName+".bin",FILE_READ|FILE_WRITE|FILE_BIN);
   if(file_handle != INVALID_HANDLE)
   { 
      FileWriteArray(file_handle,Temp_rates);
       
      FileClose(file_handle);
   }
}

bool RetriveDataArrayFromFile()
{   
   int file_handle = FileOpen(InpFileName+".bin",FILE_READ|FILE_BIN);
   if(file_handle != INVALID_HANDLE)
   {
      FileReadArray(file_handle,rates);
      
      FileClose(file_handle);
      return true;
   }
   return false;
}

int DayOfWeek(datetime date1)
 {
   MqlDateTime tm;
   TimeToStruct(date1, tm);
   return(tm.day_of_week);
 }