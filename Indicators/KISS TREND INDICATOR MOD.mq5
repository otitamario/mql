//+------------------------------------------------------------------+
//|        06/12/18 10:42hs         KISS TREND INDICATOR MOD.mq5 |
//+------------------------------------------------------------------+
//| Version 01 (03-Feb-2018):                                        |
//|   01(a) Renamed Media <number>  to  Option <alphabet>            |
//|   01(b) Input parameters for Period optimized for iCustom        |
//|   01(c) Appended _V01 in the indicator's short-name              |
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                        KISTC_RENKO_GENERATOR.mq5 |
//|                Copyright 2011-2018, Keep It Simple Trading Corp. |
//|                                    http://www.keeptrading.com.br |
//+------------------------------------------------------------------+
#property copyright ""                      //Author
#property indicator_chart_window                //Indicator in separate window
#property icon      "\\Files\\icon_s.ico"
#property link      "http://keeptradingcorp.com/"
#property copyright "Copyright© 2011-2019, Keep It Simple Trading Corp®."
#property description "KISS TREND INDICATOR MOD."

#define d_ObjFunNom "image"

//Specify the number of buffers
//4 buffer for the candles + 1 color buffer + 4 buffer to serve the Medias data
#property indicator_buffers 45

//Specify the names, shown in the Data Window
#property indicator_label1 "Open;High;Low;Close"

#property indicator_plots 1                     //Number of graphic plots
#property indicator_type1 DRAW_COLOR_CANDLES    //Drawing style - color candles
#property indicator_width1 3   
//Width of the graphic plot (optional)

//string NomeCliente="NOME"; //NOME DO USUÁRIO
//bool blockCliente;

/*
ulong conta1=229150; // 
ulong conta2=5251512; // 
ulong conta3=9019798; // 
ulong conta4=92402887; // 
ulong conta5=594078; // 
ulong conta6=96200; // 
ulong conta7=3376449; // 
ulong conta8=2551819; // 
ulong conta9=2518645; // 
ulong conta10=2951931; // 
ulong conta11=2451267; // 
ulong conta12=92451267; // 
ulong conta13=82451267; // 
ulong conta14=72451267;
ulong conta15=10851390;
ulong conta16=10851364;
ulong conta17=10851294;
ulong conta18=15017023;
ulong conta19=0;
ulong conta20=0;
ulong conta21=0;
ulong conta22=10671178;
ulong conta23=671178;
ulong conta24=295949; // RODRIGO XP REAL
ulong conta25=50295949; // RODRIGO XP
ulong conta26=5102165; // RODRIGO ACTIVTRADES
ulong conta27=9015729; // RODRIGO TERRA
ulong conta28=3000141516; // RODRIGO RICO
ulong conta29=8012459; // RODRIGO TERRA
ulong conta30=9012459; // RODRIGO TERRA
bool blockCliente; */

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool gb_DEBUG = false,
     gb_PeriodsExtracted = false;
int gi_aPeriod[15]; // Periods for different Options

enum DATE_TYPE 
  {
   DAILY,
   WEEKLY,
   MONTHLY
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum PRICE_TYPE 
  {
   OPEN,
   CLOSE,
   HIGH,
   LOW,
   OPEN_CLOSE,
   HIGH_LOW,
   CLOSE_HIGH_LOW,
   OPEN_CLOSE_HIGH_LOW
  };

input ENUM_TIMEFRAMES period_velas=PERIOD_CURRENT;//Período das Velas
//
input bool Media1=false;// Usar Option A
bool Plot1=false;//Plotar Option A
input bool Media2=false;// Usar Option B
bool Plot2=false;//Plotar Option B
input bool Media3=false;// Usar Option C
bool Plot3=false;//Plotar Option C
input bool Media4=false;// Usar Option D
bool Plot4=false;//Plotar Option D
input bool Media5=false;// Usar Option E
bool Plot5=false;//Plotar Option E//

input bool Media6=false;// Usar Option F
bool Plot6=false;//Plotar Option F
input bool Media7=false;// Usar Option G
bool Plot7=false;//Plotar Option G
input bool Media8=false;// Usar Option H
bool Plot8=false;//Plotar Option H
input bool Media9=false;// Usar Option I
bool Plot9=false;//Plotar Option I
input bool Media10=false;// Usar Option J
bool Plot10=false;//Plotar Option J//

input bool Media11=false;// Usar Option K
bool Plot11=false;//Plotar Option K
input bool Media12=false;// Usar Option L
bool Plot12=false;//Plotar Option L
input bool Media13=false;// Usar Option M
bool Plot13=false;//Plotar Option M
input bool Media14=false;// Usar Option N
bool Plot14=false;//Plotar Option N
input bool Media15=false;// Usar Option O
bool Plot15=false;//Plotar Option O
//
string is_PeriodsSet1 = "1, 2, 3, 4, 5"; // Comma-Separated Periods for Options A to E
string is_PeriodsSet2 = "6, 7, 8, 9, 10"; // Comma-Separated Periods for Options F to J
string is_PeriodsSet3 = "11, 12, 13, 14, 15"; // Comma-Separated Periods for Options K to O
//
input bool ATRSTOP=false;// Usar ATRSTOP
input bool Plot_atr=false;//Plotar ATRSTOP
input uint   Length=5;           // Indicator period
input uint   ATRPeriod=20;         // Period of ATR
input double Kv=2.0;              // Volatility by ATR
input int    Shift=0;       // Shift
input bool Usar_VWAP=false; //Usar VWAP
input bool Plot_VWAP=false;//Plotar VWAP
input   PRICE_TYPE  Price_Type          = CLOSE;
input   bool        Calc_Every_Tick     = false;
input   bool        Enable_Daily        = false;
input   bool        Show_Daily_Value    = false;
input   bool        Enable_Weekly       = false;
input   bool        Show_Weekly_Value   = false;
input   bool        Enable_Monthly      = false;
input   bool        Show_Monthly_Value  = false;
input bool Usar_Hilo=false;// Usar Hilo
input bool Plot_hilo=false;//Plotar hilo
input int period_hilo=8;//Periodo Hilo
input int shift_hilo=0;// Deslocar Hilo


//Declaration of buffers
double buffer_open[],buffer_high[],buffer_low[],buffer_close[]; //Buffers for data
double buffer_color_line[]; //Buffer for color indexes
double buffer_ma1[];        //Indicator buffer for MA 1
double buffer_ma2[];        //Indicator buffer for MA 2
double buffer_ma3[];        //Indicator buffer for MA 3
double buffer_ma4[];        //Indicator buffer for MA 4

double buffer_ma5[];        //Indicator buffer for MA 5
double buffer_ma6[];        //Indicator buffer for MA 6
double buffer_ma7[];        //Indicator buffer for MA 7
double buffer_ma8[];        //Indicator buffer for MA 8
double buffer_ma9[];        //Indicator buffer for MA 9
double buffer_ma10[];        //Indicator buffer for MA 10
double buffer_ma11[];        //Indicator buffer for MA 11
double buffer_ma12[];        //Indicator buffer for MA 12
double buffer_ma13[];        //Indicator buffer for MA 13
double buffer_ma14[];        //Indicator buffer for MA 14
double buffer_ma15[];        //Indicator buffer for MA 15

double buffer_atr[];        //Indicator buffer for ATR
double buffer_vwap[];        //Indicator buffer for VWAP
double buffer_hilo[];        //Indicator buffer for Hilo

double buffer_tmp1[1],buffer_tmp2[1],buffer_tmp3[1],buffer_tmp4[1],buffer_tmp5[1],buffer_tmp6[1],buffer_tmp7[1],buffer_tmp8[1],buffer_tmp9[1],buffer_tmp10[1],buffer_tmp11[1],buffer_tmp12[1],buffer_tmp13[1],buffer_tmp14[1],buffer_tmp15[1],buffer_tmpatr[1];       //Temporary buffers for the Medias data copying
double buffer_tmpvwap[1],buffer_tmphilo[1];
int handle_ma1,handle_ma2,handle_ma3,handle_ma4,handle_ma5,handle_ma6,handle_ma7,handle_ma8,handle_ma9,handle_ma10,handle_ma11,handle_ma12,handle_ma13,handle_ma14,handle_ma15,handle_atr,handle_vwap,handle_hilo;           //Handle for the MA indicators
string s_media1,s_media2,s_media3,s_media4,s_media5,s_media6,s_media7,s_media8,s_media9,s_media10,s_media11,s_media12,s_media13,s_media14,s_media15,s_atr,s_vwap,s_hilo;
long curChartID;


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
  
  
  /*
  blockCliente=AccountInfoInteger(ACCOUNT_LOGIN)==conta1 || AccountInfoInteger(ACCOUNT_LOGIN)==conta2 || AccountInfoInteger(ACCOUNT_LOGIN)==conta3 || AccountInfoInteger(ACCOUNT_LOGIN)==conta4 || AccountInfoInteger(ACCOUNT_LOGIN)==conta5 || AccountInfoInteger(ACCOUNT_LOGIN)==conta6 || AccountInfoInteger(ACCOUNT_LOGIN)==conta7 || AccountInfoInteger(ACCOUNT_LOGIN)==conta8 || AccountInfoInteger(ACCOUNT_LOGIN)==conta9 
  || AccountInfoInteger(ACCOUNT_LOGIN)==conta10 || AccountInfoInteger(ACCOUNT_LOGIN)==conta11 || AccountInfoInteger(ACCOUNT_LOGIN)==conta12 || AccountInfoInteger(ACCOUNT_LOGIN)==conta13 || AccountInfoInteger(ACCOUNT_LOGIN)==conta14 || AccountInfoInteger(ACCOUNT_LOGIN)==conta15 || AccountInfoInteger(ACCOUNT_LOGIN)==conta16 || AccountInfoInteger(ACCOUNT_LOGIN)==conta17 || AccountInfoInteger(ACCOUNT_LOGIN)==conta18
  || AccountInfoInteger(ACCOUNT_LOGIN)==conta19 || AccountInfoInteger(ACCOUNT_LOGIN)==conta20 || AccountInfoInteger(ACCOUNT_LOGIN)==conta21 || AccountInfoInteger(ACCOUNT_LOGIN)==conta22 || AccountInfoInteger(ACCOUNT_LOGIN)==conta23 || AccountInfoInteger(ACCOUNT_LOGIN)==conta24 || AccountInfoInteger(ACCOUNT_LOGIN)==conta25 || AccountInfoInteger(ACCOUNT_LOGIN)==conta26 || AccountInfoInteger(ACCOUNT_LOGIN)==conta27
  || AccountInfoInteger(ACCOUNT_LOGIN)==conta28 || AccountInfoInteger(ACCOUNT_LOGIN)==conta29 || AccountInfoInteger(ACCOUNT_LOGIN)==conta30;  
  if(blockCliente) Print("Liberado para uso.");
   
  else
     
  {
      
  Print("Conta não autorizada");
      
  return(INIT_FAILED);

  } */

  //}



//Expiry date setting 
string ExpiryDate="2019.08.20";
if(TimeCurrent() >= StringToTime(ExpiryDate)){
Alert("O período de testes do KISS TREND INDICATOR MOD expirou.");
ChartIndicatorDelete(0,0,"KISS TREND INDICATOR MOD");
Print("Indicador removido devido ao periodo de utilização haver vencido. Nos contate para solicitar sua licença de uso!");
return(0);
}
else{
Print("KISS TREND INDICATOR MOD liberado para uso até 20/08/2019");
  } 
  
  IndicatorSetString(INDICATOR_SHORTNAME,"KISS TREND INDICATOR MOD");
  
  ObjectCreate    (0,d_ObjFunNom,OBJ_BITMAP_LABEL,0,0,0); 
  ObjectSetInteger(0,d_ObjFunNom,OBJPROP_XDISTANCE,1833); 
  ObjectSetInteger(0,d_ObjFunNom,OBJPROP_YDISTANCE,89);  
  ObjectSetInteger(0,d_ObjFunNom,OBJPROP_CORNER,CORNER_RIGHT_LOWER);  
  ObjectSetString (0,d_ObjFunNom,OBJPROP_BMPFILE,0,"\\Files\\image.bmp"); 
  ObjectSetInteger(0,d_ObjFunNom,OBJPROP_SELECTABLE,false); 
  ObjectSetInteger(0,d_ObjFunNom,OBJPROP_SELECTED  ,false); 
  ObjectSetInteger(0,d_ObjFunNom,OBJPROP_HIDDEN    ,false);

   gb_PeriodsExtracted = func_ExtractPeriods();
   if (gb_PeriodsExtracted == true)
   {
      curChartID=ChartID();
      IndicatorSetString(INDICATOR_SHORTNAME,"KISS TREND INDICATOR MOD");
      
      /**
      *       The order of the buffers assign is VERY IMPORTANT!
      *  The data buffers are first
      *       The color buffers are next
      *       And finally, the buffers for the internal calculations.
      */
      //Assign the arrays with the indicator's buffers
      SetIndexBuffer(0,buffer_open,INDICATOR_DATA);
      SetIndexBuffer(1,buffer_high,INDICATOR_DATA);
      SetIndexBuffer(2,buffer_low,INDICATOR_DATA);
      SetIndexBuffer(3,buffer_close,INDICATOR_DATA);
      
      //Assign the array with color indexes with the indicator's color indexes buffer
      SetIndexBuffer(4,buffer_color_line,INDICATOR_COLOR_INDEX);
      
      //Assign the array with the buffer of MA indicator data
      SetIndexBuffer(5,buffer_ma1,INDICATOR_CALCULATIONS);
      SetIndexBuffer(6,buffer_ma2,INDICATOR_CALCULATIONS);
      SetIndexBuffer(7,buffer_ma3,INDICATOR_CALCULATIONS);
      SetIndexBuffer(8,buffer_ma4,INDICATOR_CALCULATIONS);
      
      SetIndexBuffer(9,buffer_ma5,INDICATOR_CALCULATIONS);
      SetIndexBuffer(10,buffer_ma6,INDICATOR_CALCULATIONS);
      SetIndexBuffer(11,buffer_ma7,INDICATOR_CALCULATIONS);
      SetIndexBuffer(12,buffer_ma8,INDICATOR_CALCULATIONS);
      SetIndexBuffer(13,buffer_ma9,INDICATOR_CALCULATIONS);
      SetIndexBuffer(14,buffer_ma10,INDICATOR_CALCULATIONS);
      SetIndexBuffer(15,buffer_ma11,INDICATOR_CALCULATIONS);
      SetIndexBuffer(16,buffer_ma12,INDICATOR_CALCULATIONS);
      SetIndexBuffer(17,buffer_ma13,INDICATOR_CALCULATIONS);
      SetIndexBuffer(18,buffer_ma14,INDICATOR_CALCULATIONS);
      SetIndexBuffer(19,buffer_ma15,INDICATOR_CALCULATIONS);
      
      SetIndexBuffer(20,buffer_atr,INDICATOR_CALCULATIONS);
      SetIndexBuffer(21,buffer_vwap,INDICATOR_CALCULATIONS);
      SetIndexBuffer(22,buffer_hilo,INDICATOR_CALCULATIONS);
      
      //Define the number of color indexes, used for a graphic plot
      PlotIndexSetInteger(0,PLOT_COLOR_INDEXES,3);
      
      //Set color for each index
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,0,DodgerBlue);   //Zeroth index -> Branco ( ACIMA das medias)
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,1,Red); //First index  -> Rosa (ABAIXO das medias)
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,2,White); //Second index  -> Amarelo (caso contrário)
      
      
          //Get handle of MA indicators, it's necessary to get the MA indicator values
      handle_ma1=iMA(Symbol(),period_velas,gi_aPeriod[0],0,MODE_EMA,PRICE_CLOSE);//A//
      handle_ma2=iMA(Symbol(),period_velas,gi_aPeriod[1],0,MODE_EMA,PRICE_CLOSE);//B//
      handle_ma3=iMA(Symbol(),period_velas,gi_aPeriod[2],0,MODE_EMA,PRICE_CLOSE);//C//
      handle_ma4=iMA(Symbol(),period_velas,gi_aPeriod[3],0,MODE_EMA,PRICE_CLOSE);//D//  
      handle_ma5=iMA(Symbol(),period_velas,gi_aPeriod[4],0,MODE_SMA,PRICE_CLOSE);//E//     
      handle_ma6=iMA(Symbol(),period_velas,gi_aPeriod[5],0,MODE_SMA,PRICE_CLOSE);//F//
      
      handle_ma7=iMA(Symbol(),period_velas,gi_aPeriod[6],0,MODE_SMA,PRICE_CLOSE);//G//
      handle_ma8=iMA(Symbol(),period_velas,gi_aPeriod[7],0,MODE_SMA,PRICE_CLOSE);//H//
      handle_ma9=iMA(Symbol(),period_velas,gi_aPeriod[8],0,MODE_EMA,PRICE_CLOSE);//I//
      
      handle_ma10=iMA(Symbol(),period_velas,gi_aPeriod[9],0,MODE_EMA,PRICE_CLOSE);//J//
      handle_ma11=iMA(Symbol(),period_velas,gi_aPeriod[10],0,MODE_EMA,PRICE_CLOSE);//K//
      handle_ma12=iMA(Symbol(),period_velas,gi_aPeriod[11],0,MODE_EMA,PRICE_CLOSE);//L//
      
      handle_ma13=iMA(Symbol(),period_velas,gi_aPeriod[12],0,MODE_SMA,PRICE_CLOSE);//M//
      handle_ma14=iMA(Symbol(),period_velas,gi_aPeriod[13],0,MODE_EMA,PRICE_CLOSE);//N//
      handle_ma15=iMA(Symbol(),period_velas,gi_aPeriod[14],0,MODE_EMA,PRICE_CLOSE);//O//
      
      handle_atr=iCustom(Symbol(),period_velas,"atrstops_v1",Length,ATRPeriod,Kv,Shift);
      handle_vwap=iCustom(Symbol(),period_velas,"vwap_lite",Price_Type,Calc_Every_Tick,Enable_Daily,Show_Daily_Value,Enable_Weekly,Show_Weekly_Value,Enable_Monthly,Show_Monthly_Value);
      handle_hilo=iCustom(Symbol(),period_velas,"hilo_escada_smothed",period_hilo,MODE_SMMA,shift_hilo);
      
      if (Media1 && Plot1) ChartIndicatorAdd(curChartID,0,handle_ma1);
      if (Media2&& Plot2) ChartIndicatorAdd(curChartID,0,handle_ma2);
      if (Media3&& Plot3)ChartIndicatorAdd(curChartID,0,handle_ma3);
      if (Media4&& Plot4) ChartIndicatorAdd(curChartID,0,handle_ma4);
      
      if (Media5&& Plot5) ChartIndicatorAdd(curChartID,0,handle_ma5);
      if (Media6&& Plot6) ChartIndicatorAdd(curChartID,0,handle_ma6);
      if (Media7&& Plot7) ChartIndicatorAdd(curChartID,0,handle_ma7);
      if (Media8&& Plot8) ChartIndicatorAdd(curChartID,0,handle_ma8);
      if (Media9&& Plot9) ChartIndicatorAdd(curChartID,0,handle_ma9);
      if (Media10&& Plot10) ChartIndicatorAdd(curChartID,0,handle_ma10);
      if (Media11&& Plot11) ChartIndicatorAdd(curChartID,0,handle_ma11);
      if (Media12&& Plot12) ChartIndicatorAdd(curChartID,0,handle_ma12);
      if (Media13&& Plot13) ChartIndicatorAdd(curChartID,0,handle_ma13);
      if (Media14&& Plot14) ChartIndicatorAdd(curChartID,0,handle_ma14);
      if (Media15&& Plot15) ChartIndicatorAdd(curChartID,0,handle_ma15);
      
      if (ATRSTOP&& Plot_atr) ChartIndicatorAdd(curChartID,0,handle_atr);
      if (Usar_VWAP && Plot_VWAP) ChartIndicatorAdd(curChartID,0,handle_vwap);
      if (Usar_Hilo && Plot_hilo) ChartIndicatorAdd(curChartID,0,handle_hilo);
      
      
      s_media1="MA("+string(gi_aPeriod[0])+")";
      s_media2="MA("+string(gi_aPeriod[1])+")";
      s_media3="MA("+string(gi_aPeriod[2])+")";
      s_media4="MA("+string(gi_aPeriod[3])+")";
      
      s_media5="MA("+string(gi_aPeriod[4])+")";
      s_media6="MA("+string(gi_aPeriod[5])+")";
      s_media7="MA("+string(gi_aPeriod[6])+")";
      s_media8="MA("+string(gi_aPeriod[7])+")";
      s_media9="MA("+string(gi_aPeriod[8])+")";
      s_media10="MA("+string(gi_aPeriod[9])+")";
      s_media11="MA("+string(gi_aPeriod[10])+")";
      s_media12="MA("+string(gi_aPeriod[11])+")";
      s_media13="MA("+string(gi_aPeriod[12])+")";
      s_media14="MA("+string(gi_aPeriod[13])+")";
      s_media15="MA("+string(gi_aPeriod[14])+")";
      
      s_atr="";
      StringConcatenate(s_atr,"ATRStops_v1(",Length,", ",ATRPeriod,", ",DoubleToString(Kv,4),", ",Shift,")");
      s_vwap="vwap";
      s_hilo="HiLo";
      
      
      if (gb_DEBUG) { Print("[DE-BUG] ", __FUNCTION__, ": ", __FILE__, " Initialized Successfully"); }
      
      return(INIT_SUCCEEDED);
   }
   //
   if (gb_DEBUG) { Print("[DE-BUG] ", __FUNCTION__, ": FAILED to Initialize ", __FILE__); }
   return (INIT_FAILED);
}

//---
//} 
/*
}

 else{
 ChartIndicatorDelete(0,0,"KISS TREND INDICATOR MOD");
 //ExpertRemove();
 Print("Este indicador irá funcionar somente em contas previamente cadastradas pelo criador da ferramenta.");  
 Print("Favor contatar o criador da ferramenta se você possui autorização para uso da mesma.");   
             }
  return(INIT_SUCCEEDED);
  } */
  
  void OnDeinit(const int reason)
  {
   if (gb_DEBUG) { Print("[DE-BUG] ", __FUNCTION__, ": De-Initializing ", __FILE__); }
   
   Comment("");
   
   ObjectDelete(0,d_ObjFunNom);
   
   //
   if (gb_PeriodsExtracted == false)
   {
      return;
   }
   //
   if (Media1&& Plot1) ChartIndicatorDelete(curChartID,0,s_media1);
   if (Media2&& Plot2) ChartIndicatorDelete(curChartID,0,s_media2);
   if (Media3&& Plot3)ChartIndicatorDelete(curChartID,0,s_media3);
   if (Media4&& Plot4) ChartIndicatorDelete(curChartID,0,s_media4);
   
   if (Media5&& Plot5) ChartIndicatorDelete(curChartID,0,s_media5);
   if (Media6&& Plot6) ChartIndicatorDelete(curChartID,0,s_media6);
   if (Media7&& Plot7) ChartIndicatorDelete(curChartID,0,s_media7);
   if (Media8&& Plot8) ChartIndicatorDelete(curChartID,0,s_media8);
   if (Media9&& Plot9) ChartIndicatorDelete(curChartID,0,s_media9);
   if (Media10&& Plot10) ChartIndicatorDelete(curChartID,0,s_media10);
   if (Media11&& Plot11) ChartIndicatorDelete(curChartID,0,s_media11);
   if (Media12&& Plot12) ChartIndicatorDelete(curChartID,0,s_media12);
   if (Media13&& Plot13) ChartIndicatorDelete(curChartID,0,s_media13);
   if (Media14&& Plot14) ChartIndicatorDelete(curChartID,0,s_media14);
   if (Media15&& Plot15) ChartIndicatorDelete(curChartID,0,s_media15);
   
   if (ATRSTOP&& Plot_atr) ChartIndicatorDelete(curChartID,0,s_atr);
   if (Usar_VWAP&& Plot_VWAP) ChartIndicatorDelete(curChartID,0,s_vwap);
   if (Usar_Hilo&& Plot_hilo) ChartIndicatorDelete(curChartID,0,s_hilo);

  
  }
  
 
//+------------------------------------------------------------------+
//| Custom indicator calculation function                            |
//+-----------------------------------------------------------------+
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
//In the loop we fill the data buffers and color indexes buffers for each bar
   for(int i=prev_calculated;i<=rates_total-1;i++)
     {
      //Copying the MA indicator's data to the temporary buffer - buffer_tmp
      CopyBuffer(handle_ma1,0,BarsCalculated(handle_ma1)-i-1,1,buffer_tmp1);
      CopyBuffer(handle_ma2,0,BarsCalculated(handle_ma2)-i-1,1,buffer_tmp2);
      CopyBuffer(handle_ma3,0,BarsCalculated(handle_ma3)-i-1,1,buffer_tmp3);
      CopyBuffer(handle_ma4,0,BarsCalculated(handle_ma4)-i-1,1,buffer_tmp4);
      
      CopyBuffer(handle_ma5,0,BarsCalculated(handle_ma5)-i-1,1,buffer_tmp5);
      CopyBuffer(handle_ma6,0,BarsCalculated(handle_ma6)-i-1,1,buffer_tmp6);
      CopyBuffer(handle_ma7,0,BarsCalculated(handle_ma7)-i-1,1,buffer_tmp7);
      CopyBuffer(handle_ma8,0,BarsCalculated(handle_ma8)-i-1,1,buffer_tmp8);
      CopyBuffer(handle_ma9,0,BarsCalculated(handle_ma9)-i-1,1,buffer_tmp9);
      CopyBuffer(handle_ma10,0,BarsCalculated(handle_ma10)-i-1,1,buffer_tmp10);
      CopyBuffer(handle_ma11,0,BarsCalculated(handle_ma11)-i-1,1,buffer_tmp11);
      CopyBuffer(handle_ma12,0,BarsCalculated(handle_ma12)-i-1,1,buffer_tmp12);
      CopyBuffer(handle_ma13,0,BarsCalculated(handle_ma13)-i-1,1,buffer_tmp13);
      CopyBuffer(handle_ma14,0,BarsCalculated(handle_ma14)-i-1,1,buffer_tmp14);
      CopyBuffer(handle_ma15,0,BarsCalculated(handle_ma15)-i-1,1,buffer_tmp15);
      
      CopyBuffer(handle_atr,0,BarsCalculated(handle_atr)-i-1,1,buffer_tmpatr);
      CopyBuffer(handle_vwap,0,BarsCalculated(handle_vwap)-i-1,1,buffer_tmpvwap);
      CopyBuffer(handle_hilo,0,BarsCalculated(handle_hilo)-i-1,1,buffer_tmphilo);

      //Copying the values from the temporary buffer to the indicator's buffer
      buffer_ma1[i]=buffer_tmp1[0];
      buffer_ma2[i]=buffer_tmp2[0];
      buffer_ma3[i]=buffer_tmp3[0];
      buffer_ma4[i]=buffer_tmp4[0];
      
      buffer_ma5[i]=buffer_tmp5[0];
      buffer_ma6[i]=buffer_tmp6[0];
      buffer_ma7[i]=buffer_tmp7[0];
      buffer_ma8[i]=buffer_tmp8[0];
      buffer_ma9[i]=buffer_tmp9[0];
      buffer_ma10[i]=buffer_tmp10[0];
      buffer_ma11[i]=buffer_tmp11[0];
      buffer_ma12[i]=buffer_tmp12[0];
      buffer_ma13[i]=buffer_tmp13[0];
      buffer_ma14[i]=buffer_tmp14[0];
      buffer_ma15[i]=buffer_tmp15[0];
      
      buffer_atr[i]=buffer_tmpatr[0];
      buffer_vwap[i]=buffer_tmpvwap[0];
      buffer_hilo[i]=buffer_tmphilo[0];
      //Set data for plotting
      buffer_open[i]=open[i];  //Open price
      buffer_high[i]=high[i];  //High price
      buffer_low[i]=low[i];    //Low price
      buffer_close[i]=close[i];//Close price

      bool acima_media=true;
      bool abaixo_media=true;
      if (Media1)
      {
       acima_media=acima_media&& (close[i]>buffer_ma1[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_ma1[i]);
      }
      if (Media2)
      {
       acima_media=acima_media&& (close[i]>buffer_ma2[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_ma2[i]);
      }
      if (Media3)
      {
       acima_media=acima_media&& (close[i]>buffer_ma3[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_ma3[i]);
      }
      if (Media4)
      {
       acima_media=acima_media&& (close[i]>buffer_ma4[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_ma4[i]);
      }
       if (Media5)
      {
       acima_media=acima_media&& (close[i]>buffer_ma5[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_ma5[i]);
      }
       if (Media6)
      {
       acima_media=acima_media&& (close[i]>buffer_ma6[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_ma6[i]);
      }
       if (Media7)
      {
       acima_media=acima_media&& (close[i]>buffer_ma7[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_ma7[i]);
      }
       if (Media8)
      {
       acima_media=acima_media&& (close[i]>buffer_ma8[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_ma8[i]);
      }
       if (Media9)
      {
       acima_media=acima_media&& (close[i]>buffer_ma9[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_ma9[i]);
      }
       if (Media10)
      {
       acima_media=acima_media&& (close[i]>buffer_ma10[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_ma10[i]);
      }
       if (Media11)
      {
       acima_media=acima_media&& (close[i]>buffer_ma11[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_ma11[i]);
      }
       if (Media12)
      {
       acima_media=acima_media&& (close[i]>buffer_ma12[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_ma12[i]);
      }
       if (Media13)
      {
       acima_media=acima_media&& (close[i]>buffer_ma13[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_ma13[i]);
      }
       if (Media14)
      {
       acima_media=acima_media&& (close[i]>buffer_ma14[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_ma14[i]);
      }
       if (Media15)
      {
       acima_media=acima_media&& (close[i]>buffer_ma15[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_ma15[i]);
      }
      if (ATRSTOP)
      {
       acima_media=acima_media&& (close[i]>buffer_atr[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_atr[i]);
      
      }
      if (Usar_VWAP)
      {
       acima_media=acima_media&& (close[i]>buffer_vwap[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_vwap[i]);
      
      }
      if (Usar_Hilo)
      {
       acima_media=acima_media&& (close[i]>buffer_hilo[i]);
       abaixo_media=abaixo_media&& (close[i]<buffer_hilo[i]);
      
      }
      bool meio=(!acima_media) && (!abaixo_media);
      
                               //Add a simple condition -> If RSI less 50%:
      if(acima_media) buffer_color_line[i]=0; 
      if (abaixo_media) buffer_color_line[i]=1;
      if (meio) buffer_color_line[i]=2;
     }
   return(rates_total-1); //Return the number of calculated bars, 
                          //Subtract 1 for the last bar recalculation
  }
//+------------------------------------------------------------------+
bool func_ExtractPeriods()
{
   string ls_aPeriodsSet[3];
   ls_aPeriodsSet[0] = is_PeriodsSet1; 
   ls_aPeriodsSet[1] = is_PeriodsSet2;
   ls_aPeriodsSet[2] = is_PeriodsSet3;
   //
   for (int li_Set = 0; li_Set < 3; ++li_Set)
   {
      string ls_aPeriod[];
      //
      if (func_SplitPeriods(ls_aPeriodsSet[li_Set], ls_aPeriod) == false)
      {
         return (false);
      }
      //
      int li_Index = 5 * li_Set;
      for (int ij = 0; ij < 5; ++ij, ++li_Index)
      {
         gi_aPeriod[li_Index] = (int)StringToInteger(ls_aPeriod[ij]);
         //
         if (gb_DEBUG) { Print("[DE-BUG] ", __FUNCTION__, " Period #", (li_Index + 1), " = ", gi_aPeriod[li_Index]); }
      }
   }
   //
   return (true);
}
//
//
bool func_SplitPeriods(string ps_PeriodsSet, string & cs_aPeriod[])
{
   // remove all blank spaces
   StringReplace(ps_PeriodsSet, " ", "");
   //
   if (StringSplit(ps_PeriodsSet, StringGetCharacter(",", 0), cs_aPeriod) < 5)
   {
      if (gb_DEBUG) { Print("[DE-BUG] ", __FUNCTION__, " ERROR: Less than 5 Periods: ", ps_PeriodsSet); }
      //
      return (false);
   }
   //
   return (true);
}