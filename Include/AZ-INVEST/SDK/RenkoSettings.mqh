#property copyright "Copyright 2017, AZ-iNVEST"
#property link      "http://www.az-invest.eu"

#include <AZ-INVEST/SDK/CommonSettings.mqh>
#ifdef P_RENKO_BR
   #ifdef P_RENKO_BR_PRO
      #define CUSTOM_CHART_NAME "P-RENKO BR Pro"
//      #import "P-RenkoEngine.dll"
      #import "P-RenkoEngineLite.dll"
         void InitializeEngine();
         int CheckInitDLL();
         int GetToken(int i);   
      #import      
   #else
      #define CUSTOM_CHART_NAME "P-RENKO BR Lite"
//      #import "P-RenkoEngine.dll"
      #import "P-RenkoEngineLite.dll"
         void InitializeEngine();
         int CheckInitDLL();
         int GetToken(int i);   
      #import      
   #endif
#else
   #define CUSTOM_CHART_NAME "Ultimate Renko"
#endif 

#ifdef SHOW_INDICATOR_INPUTS

   #ifdef P_RENKO_BR
    #ifdef P_RENKO_BR_PRO

      input ENUM_CHART_SIZE         barSizeInTicks = _2R;                     // Tipo de Gráfico
            double                  retracementFactor = 1;
            ENUM_BOOL               symetricalReversals = true; 
      input ENUM_BOOL               showWicks = BTrue;                        // Mostrar sombras
            ENUM_BOOL               atrEnabled = false;                       
            ENUM_TIMEFRAMES         atrTimeFrame = PERIOD_D1;                 
            int                     atrPeriod = 14;                           
            int                     atrPercentage = 10;                       
            ENUM_BOOL               useRealVolume = true;                     // Use real volume (false for FX)            
            ENUM_TICK_PRICE_TYPE    plotPrice = tickLast;                     // Plotar gráfico com (use Bid para FX)
      input int                     showNumberOfDays = 14;                    // Número de dias para mostrar histórico
            ENUM_BOOL               applyOffsetToFirstBar = false;            
            int                     offsetValue = 0;                          
      input ENUM_BOOL               resetOpenOnNewTradingDay = BFalse;        // Sincronizar abertura do primeiro box
      input double                  TopBottomPaddingPercentage = 0.30;        // Ajuste de plotagem do gráfico (0.0 - 1.0)
      input ENUM_PIVOT_POINTS       showPivots = ppNone;                      // Mostrar Ponto de Pivô
      input ENUM_PIVOT_TYPE         pivotPointCalculationType = ppHLC3;       // Cálculo do Ponto de Pivô
      input color                   RColor = clrDodgerBlue;                   // Cor da linha de Resistência
      input color                   PColor = clrGold;                         // Cor da linha de Pivô
      input color                   SColor = clrFireBrick;                    // Cor da linha de Resistência
      input color                   PDHColor = clrNONE;                       // Cor da máxima do dia anterior
      input color                   PDLColor = clrNONE;                       // Cor da mínima do dia anterior
      input color                   PDCColor = clrNONE;                       // Cor do fechamento do dia anterior
      input ENUM_BOOL               showNextBarLevels = BTrue;                // Mostrar projeção de fechamento do box
      input color                   HighThresholdIndicatorColor = clrLime;    // Cor da projeção do box de alta
      input color                   LowThresholdIndicatorColor = clrRed;      // Cor da projeção do box de baixa
            ENUM_BOOL               showCurrentBarOpenTime = true; 
      input color                   InfoTextColor = clrWhiteSmoke;            // Cor do texto do tipo de gráfico
      
      input ENUM_BOOL               NewBarAlert = BFalse;                     // Emitir som a cada nova barra
            ENUM_BOOL               ReversalBarAlert = false;
            ENUM_BOOL               MaCrossAlert = false;
            ENUM_BOOL               UseAlertWindow = false;
            ENUM_BOOL               UseSound = true;
            ENUM_BOOL               UsePushNotifications = false;
      
      input string                  SoundFileBull = "news.wav";               // Som do fechamento do box de alta
      input string                  SoundFileBear = "timeout.wav";            // Som do fechamento do box de baixa
      input ENUM_BOOL               MA1on = false;                            // Mostrar primeira média móvel 
      input int                     MA1period = 17;                           // Período da primeira média móvel
      input ENUM_MA_METHOD_EXT      MA1method =  _MODE_EMA;                   // Método de média
      input ENUM_APPLIED_PRICE      MA1applyTo = PRICE_CLOSE;                 // Aplicar a
      input int                     MA1shift = 0;                             // Deslocamento da primeira média
      input ENUM_BOOL               MA2on = false;                            // Mostrar segunda média móvel
      input int                     MA2period = 72;                           // Período da segunda média móvel
      input ENUM_MA_METHOD_EXT      MA2method = _MODE_EMA;                    // Método de média
      input ENUM_APPLIED_PRICE      MA2applyTo = PRICE_CLOSE;                 // Aplicar a
      input int                     MA2shift = 0;                             // Deslocamento da segunda média
      input ENUM_BOOL               MA3on = false;                            // Mostrar terceira média móvel
      input int                     MA3period = 200;                          // Período da terceira média móvel
      input ENUM_MA_METHOD_EXT      MA3method = _MODE_EMA;                    // Método de média
      input ENUM_APPLIED_PRICE      MA3applyTo = PRICE_CLOSE;                 // Aplicar a
      input int                     MA3shift = 0;                             // Deslocamento da segunda média
      input ENUM_CHANNEL_TYPE       ShowChannel = None;                       // Mostrar Bandas
      input string                  Channel_Settings = "-------------------"; // Ajustes das bandas 
      input int                     DonchianPeriod = 20;                      // Período do Canal de Donchian
      input ENUM_APPLIED_PRICE      BBapplyTo = PRICE_CLOSE;                  // Aplicar Bandas de Bollinger Bands em
      input int                     BollingerBandsPeriod = 20;                // Período da Banda de Bollinger
      input double                  BollingerBandsDeviations = 2.0;           // Desvio da Banda de Bollinger
      input int                     SuperTrendPeriod = 10;                    // Período do Super Trend
      input double                  SuperTrendMultiplier=1.7;                 // Multiplicador do Super Trend
      input string                  Misc_Settings = "-------------------";    // Outros ajustes
      input ENUM_BOOL               DisplayAsBarChart = false;                // Mostrar gráfico como barras
      input ENUM_BOOL               ShiftObj = false;                         // Shift objects with chart      
      input ENUM_BOOL               UsedInEA = false;                         // Não alterar este valor      


    #else    
      input ENUM_CHART_SIZE         barSizeInTicks = _2R;                     // Tipo de Gráfico
            double                  retracementFactor = 1;
            ENUM_BOOL               symetricalReversals = true; 
      input ENUM_BOOL               showWicks = BTrue;                        // Mostrar sombras
            ENUM_BOOL               atrEnabled = false;                       
            ENUM_TIMEFRAMES         atrTimeFrame = PERIOD_D1;                 
            int                     atrPeriod = 14;                           
            int                     atrPercentage = 10;                       
            ENUM_BOOL               useRealVolume = true;                     // Use real volume (false for FX)            
            ENUM_TICK_PRICE_TYPE    plotPrice = tickLast;                     // Plotar gráfico com (use Bid para FX)
      input int                     showNumberOfDays = 14;                    // Número de dias para mostrar histórico
            ENUM_BOOL               applyOffsetToFirstBar = false;            
            int                     offsetValue = 0;                          
      input ENUM_BOOL               resetOpenOnNewTradingDay = BFalse;        // Sincronizar abertura do primeiro box
      input double                  TopBottomPaddingPercentage = 0.30;        // Ajuste de plotagem do gráfico (0.0 - 1.0)
      input ENUM_PIVOT_POINTS       showPivots = ppNone;                      // Mostrar Ponto de Pivô
      input ENUM_PIVOT_TYPE         pivotPointCalculationType = ppHLC3;       // Cálculo do Ponto de Pivô
      input color                   RColor = clrDodgerBlue;                   // Cor da linha de Resistência
      input color                   PColor = clrGold;                         // Cor da linha de Pivô
      input color                   SColor = clrFireBrick;                    // Cor da linha de Resistência
      input color                   PDHColor = clrNONE;                       // Cor da máxima do dia anterior
      input color                   PDLColor = clrNONE;                       // Cor da mínima do dia anterior
      input color                   PDCColor = clrNONE;                       // Cor do fechamento do dia anterior
      input ENUM_BOOL               showNextBarLevels = BTrue;                // Mostrar projeção de fechamento do box
      input color                   HighThresholdIndicatorColor = clrLime;    // Cor da projeção do box de alta
      input color                   LowThresholdIndicatorColor = clrRed;      // Cor da projeção do box de baixa
            ENUM_BOOL               showCurrentBarOpenTime = true; 
      input color                   InfoTextColor = clrWhiteSmoke;            // Cor do texto do tipo de gráfico

            ENUM_BOOL               NewBarAlert = BFalse;                     // Emitir som a cada nova barra
            ENUM_BOOL               ReversalBarAlert = false;                 // Alert on a reversal bar
            ENUM_BOOL               MaCrossAlert = false;                     // Alert on MA crossover
            ENUM_BOOL               UseAlertWindow = false;                   // Display alert in Alert Window
            ENUM_BOOL               UseSound = false;                         // Play sound on alert
            ENUM_BOOL               UsePushNotifications = false;             // Send alert via push notification to a smartphone

      input string                  SoundFileBull = "news.wav";               // Som do fechamento do box de alta
      input string                  SoundFileBear = "timeout.wav";            // Som do fechamento do box de baixa
      input ENUM_BOOL               MA1on = false;                            // Mostrar primeira média móvel 
      input int                     MA1period = 17;                           // Período da primeira média móvel
      input ENUM_MA_METHOD_EXT      MA1method =  _MODE_EMA;                   // Método de média
      input ENUM_APPLIED_PRICE      MA1applyTo = PRICE_CLOSE;                 // Aplicar a
      input int                     MA1shift = 0;                             // Deslocamento da primeira média
      input ENUM_BOOL               MA2on = false;                            // Mostrar segunda média móvel
      input int                     MA2period = 72;                           // Período da segunda média móvel
      input ENUM_MA_METHOD_EXT      MA2method = _MODE_EMA;                    // Método de média
      input ENUM_APPLIED_PRICE      MA2applyTo = PRICE_CLOSE;                 // Aplicar a
      input int                     MA2shift = 0;                             // Deslocamento da segunda média
      input ENUM_BOOL               MA3on = false;                            // Mostrar terceira média móvel
      input int                     MA3period = 200;                          // Período da terceira média móvel
      input ENUM_MA_METHOD_EXT      MA3method = _MODE_EMA;                    // Método de média
      input ENUM_APPLIED_PRICE      MA3applyTo = PRICE_CLOSE;                 // Aplicar a
      input int                     MA3shift = 0;                             // Deslocamento da segunda média
            ENUM_CHANNEL_TYPE       ShowChannel = None;                       // Show Channel
            string                  Channel_Settings = "-------------------"; // Channel settings 
            int                     DonchianPeriod = 20;                      // Donchian Channel period
            ENUM_APPLIED_PRICE      BBapplyTo = PRICE_CLOSE;                  // Bollinger Bands apply to
            int                     BollingerBandsPeriod = 20;                // Bollinger Bands period
            double                  BollingerBandsDeviations = 2.0;           // Bollinger Bands deviations
            int                     SuperTrendPeriod = 10;                    // Super Trend period
            double                  SuperTrendMultiplier=1.7;                 // Super Trend multiplier
            string                  Misc_Settings = "-------------------";    // Misc settings
            ENUM_BOOL               DisplayAsBarChart = false;                
      input ENUM_BOOL               ShiftObj = false;                         // Shift objects with chart            
      input ENUM_BOOL               UsedInEA = false;                         // Não alterar este valor
    #endif
            
   #else
   
      input int                     barSizeInTicks = 100;                     // Bars size (in points)
      input double                  retracementFactor = 0.5;                  // Retracement factor (0.01 to 1.00)
      input ENUM_BOOL               symetricalReversals = true;               // Asymmetrical reversals
      input ENUM_BOOL               showWicks = true;                         // Show wicks
      input ENUM_BOOL               atrEnabled = false;                       // Enable ATR based bar size calculation
            ENUM_TIMEFRAMES         atrTimeFrame = PERIOD_D1;                 // Use ATR period
      input int                     atrPeriod = 14;                           // ATR period
      input int                     atrPercentage = 10;                       // Use percentage of ATR
            ENUM_BOOL               useRealVolume = false;                    // Use real volume ( false for FX )            
            ENUM_TICK_PRICE_TYPE    plotPrice = tickBid;                      // Build chart using
      input int                     showNumberOfDays = 14;                    // Show history for number of days
      input ENUM_BOOL               applyOffsetToFirstBar = false;            // Apply offset to first renko
      input int                     offsetValue = 0;                          // Offset value
      input ENUM_BOOL               resetOpenOnNewTradingDay = true;          // Synchronize first bar's open on new day

      #ifndef USE_CUSTOM_SYMBOL      
         input double                  TopBottomPaddingPercentage = 0.30;        // Use padding top/bottom (0.0 - 1.0)
         input ENUM_PIVOT_POINTS       showPivots = ppNone;                      // Show pivot levels
         input ENUM_PIVOT_TYPE         pivotPointCalculationType = ppHLC3;       // Pivot point calculation method
         input color                   RColor = clrDodgerBlue;                   // Resistance line color
         input color                   PColor = clrGold;                         // Pivot line color
         input color                   SColor = clrFireBrick;                    // Support line color   
         input color                   PDHColor = clrHotPink;                    // Previous day's high
         input color                   PDLColor = clrLightSkyBlue;               // Previous day's low
         input color                   PDCColor = clrGainsboro;                  // Previous day's close
         input ENUM_BOOL               showNextBarLevels = true;                 // Show current bar's close projections
         input color                   HighThresholdIndicatorColor = clrLime;    // Bullish bar projection color
         input color                   LowThresholdIndicatorColor = clrRed;      // Bearish bar projection color
         input ENUM_BOOL               showCurrentBarOpenTime = true;            // Display chart info and current bar's open time
         input color                   InfoTextColor = clrWhite;                 // Current bar's open time info color
         
         input ENUM_BOOL               NewBarAlert = false;                      // Alert on new a bar
         input ENUM_BOOL               ReversalBarAlert = false;                 // Alert on reversal bar
         input ENUM_BOOL               MaCrossAlert = false;                     // Alert on MA crossover
         input ENUM_BOOL               UseAlertWindow = false;                   // Display alert in Alert Window
         input ENUM_BOOL               UseSound = false;                         // Play sound on alert
         input ENUM_BOOL               UsePushNotifications = false;             // Send alert via push notification to a smartphone

         input string                  SoundFileBull = "news.wav";               // Use sound file for bullish bar close
         input string                  SoundFileBear = "timeout.wav";            // Use sound file for bearish bar close
         input ENUM_BOOL               MA1on = false;                            // Show first MA 
         input int                     MA1period = 20;                           // 1st MA period
         input ENUM_MA_METHOD_EXT      MA1method =  _MODE_SMA;                   // 1st MA method
         input ENUM_APPLIED_PRICE      MA1applyTo = PRICE_CLOSE;                 // 1st MA apply to
         input int                     MA1shift = 0;                             // 1st MA shift
         input ENUM_BOOL               MA2on = false;                            // Show second MA 
         input int                     MA2period = 50;                           // 2nd MA period
         input ENUM_MA_METHOD_EXT      MA2method = _MODE_EMA;                    // 2nd MA method
         input ENUM_APPLIED_PRICE      MA2applyTo = PRICE_CLOSE;                 // 2nd MA apply to
         input int                     MA2shift = 0;                             // 2nd MA shift
         input ENUM_BOOL               MA3on = false;                            // Show third MA 
         input int                     MA3period = 20;                           // 3rd MA period
         input ENUM_MA_METHOD_EXT      MA3method = _VWAP_TICKVOL;                // 3rd MA method
         input ENUM_APPLIED_PRICE      MA3applyTo = PRICE_CLOSE;                 // 3rd MA apply to
         input int                     MA3shift = 0;                             // 3rd MA shift
         input ENUM_CHANNEL_TYPE       ShowChannel = None;                       // Show Channel
         input string                  Channel_Settings = "-------------------"; // Channel settings 
         input int                     DonchianPeriod = 20;                      // Donchian Channel period
         input ENUM_APPLIED_PRICE      BBapplyTo = PRICE_CLOSE;                  // Bollinger Bands apply to
         input int                     BollingerBandsPeriod = 20;                // Bollinger Bands period
         input double                  BollingerBandsDeviations = 2.0;           // Bollinger Bands deviations
         input int                     SuperTrendPeriod = 10;                    // Super Trend period
         input double                  SuperTrendMultiplier=1.7;                 // Super Trend multiplier
         input string                  Misc_Settings = "-------------------";    // Misc settings
         input ENUM_BOOL               DisplayAsBarChart = false;                // Display as bar chart
         input ENUM_BOOL               ShiftObj = false;                         // Shift objects with chart      
         input ENUM_BOOL               UsedInEA = false;                         // Indicator used in EA via iCustom()
      #endif
   #endif

#else
  
   //
   //  This block should always be set to the following values
   //
   
      double                     TopBottomPaddingPercentage = 0;
      ENUM_PIVOT_POINTS          showPivots = ppNone;
      ENUM_PIVOT_TYPE            pivotPointCalculationType = ppHLC3;
      color                      RColor = clrNONE;
      color                      PColor = clrNONE;
      color                      SColor = clrNONE;
      color                      PDHColor = clrNONE;
      color                      PDLColor = clrNONE;
      color                      PDCColor = clrNONE;
      ENUM_BOOL                  showNextBarLevels = false;
      color                      HighThresholdIndicatorColor = clrNONE;
      color                      LowThresholdIndicatorColor = clrNONE;
      ENUM_BOOL                  showCurrentBarOpenTime = false;
      color                      InfoTextColor = clrNONE;
      
      ENUM_BOOL                  NewBarAlert = false; 
      ENUM_BOOL                  ReversalBarAlert = false;
      ENUM_BOOL                  MaCrossAlert = false;    
      ENUM_BOOL                  UseAlertWindow = false;  
      ENUM_BOOL                  UseSound = false;        
      ENUM_BOOL                  UsePushNotifications = false;

      string                     SoundFileBull = "";
      string                     SoundFileBear = "";
      ENUM_BOOL                  DisplayAsBarChart = true;
      ENUM_BOOL                  ShiftObj = false;      
      ENUM_BOOL                  UsedInEA = true; // This should always be set to TRUE for EAs & Indicators
   
   //
   //
   //
         
#endif

struct RENKO_SETTINGS
{
   int                  barSizeInTicks;
   double               retracementFactor;
   ENUM_BOOL            symetricalReversals;
   ENUM_BOOL            showWicks;
   ENUM_BOOL            atrEnabled;
   ENUM_TIMEFRAMES      atrTimeFrame;
   int                  atrPeriod;
   int                  atrPercentage;
   ENUM_BOOL            useRealVolume;
   ENUM_TICK_PRICE_TYPE plotPrice;
   int                  showNumberOfDays;
   ENUM_BOOL            applyOffsetToFirstBar;
   int                  offsetValue;   
   ENUM_BOOL            resetOpenOnNewTradingDay;   
};

class RenkoSettings
{
   protected:
   
      string                     settingsFileName;
      string                     chartTypeFileName;
      
      RENKO_SETTINGS             settings;
      CHART_INDICATOR_SETTINGS   chartIndicatorSettings;
      ALERT_INFO_SETTINGS        alertInfoSettings;
           
   public:
   
                                 RenkoSettings(void);
                                 ~RenkoSettings(void);
                                 
      RENKO_SETTINGS             GetRenkoSettings(void);
      ALERT_INFO_SETTINGS        GetAlertInfoSettings(void);
      CHART_INDICATOR_SETTINGS   GetChartIndicatorSettings(void);
      
      void                       Set(void);

      void                       Save(void);
      bool                       Load(void);
      void                       Delete(void);
      bool                       Changed(void);
};

void RenkoSettings::RenkoSettings(void)
{
   this.settingsFileName = CUSTOM_CHART_NAME+(string)ChartID()+".set";   
   this.chartTypeFileName = (string)ChartID()+".id";
}

void RenkoSettings::~RenkoSettings(void)
{

}

void RenkoSettings::Save(void)
{    
   if(IS_TESTING || this.chartIndicatorSettings.UsedInEA)
      return;

   this.Delete();

   //
   // Store indicator settings
   // 

   int handle = FileOpen(this.settingsFileName,FILE_SHARE_READ|FILE_WRITE|FILE_BIN);  
   uint result = 0;
   
   result += FileWriteStruct(handle,this.settings);
   result += FileWriteStruct(handle,this.chartIndicatorSettings);
   //FileWriteStruct(handle,this.alertInfoSettings);
   FileClose(handle);
   
   //
   // Store chart type identifier
   //
   /*
   handle = FileOpen(this.chartTypeFileName,FILE_SHARE_READ|FILE_WRITE|FILE_ANSI);
   FileWriteString(handle,CUSTOM_CHART_NAME);
   FileClose(handle);
   */
}

void RenkoSettings::Delete(void)
{
   if(IS_TESTING || this.chartIndicatorSettings.UsedInEA)
      return;

   if(FileIsExist(this.settingsFileName))
      FileDelete(this.settingsFileName);     
}

bool RenkoSettings::Load(void)
{
#ifdef SHOW_INDICATOR_INPUTS
   Set();
   return true;
#else 

   if(!FileIsExist(this.settingsFileName))
      return false;
      
   int handle = FileOpen(this.settingsFileName,FILE_SHARE_READ|FILE_BIN);  
   if(handle == INVALID_HANDLE)
      return false;
           
   if(FileReadStruct(handle,this.settings) <= 0)
   {
      Print("Failed loading settings(1)!");
      FileClose(handle); 
      return false;
   }
   
   if(FileReadStruct(handle,this.chartIndicatorSettings) <= 0)
   {
      Print("Failed loading settings(2)!");
      FileClose(handle); 
      return false;
   }
   
   /*
   if(FileReadStruct(handle,this.alertInfoSettings) <= 0)
   {
      Print("Failed loading settings(3)!");
      FileClose(handle); 
      return false;
   }
   */
   
   FileClose(handle);
   return true;

#endif 
}

ALERT_INFO_SETTINGS RenkoSettings::GetAlertInfoSettings(void)
{
   return this.alertInfoSettings;
}

CHART_INDICATOR_SETTINGS RenkoSettings::GetChartIndicatorSettings(void)
{
   return this.chartIndicatorSettings;
}

RENKO_SETTINGS RenkoSettings::GetRenkoSettings(void)
{
   return this.settings;
}

void RenkoSettings::Set(void)
{
#ifdef SHOW_INDICATOR_INPUTS

   settings.barSizeInTicks = barSizeInTicks;

   if(retracementFactor > 1)
      settings.retracementFactor = 1;
   else if(retracementFactor < 0.01)
      settings.retracementFactor = 0.01;
   else
      settings.retracementFactor = retracementFactor;
      
   settings.symetricalReversals = symetricalReversals;
   settings.showWicks = showWicks;
   settings.atrEnabled = atrEnabled;
   settings.atrTimeFrame = atrTimeFrame;
   settings.atrPeriod = atrPeriod;
   settings.atrPercentage = atrPercentage;   
   settings.useRealVolume = useRealVolume;
   settings.plotPrice = plotPrice;
   settings.showNumberOfDays = showNumberOfDays;
   settings.applyOffsetToFirstBar = applyOffsetToFirstBar;
   settings.offsetValue = offsetValue;
   settings.resetOpenOnNewTradingDay = resetOpenOnNewTradingDay;
      
   //
   //
   //
   
   #ifndef USE_CUSTOM_SYMBOL         
   chartIndicatorSettings.MA1on = MA1on;
   chartIndicatorSettings.MA1period = MA1period;
   chartIndicatorSettings.MA1method = MA1method;
   chartIndicatorSettings.MA1applyTo = MA1applyTo;
   chartIndicatorSettings.MA1shift = MA1shift;
   chartIndicatorSettings.MA2on = MA2on;
   chartIndicatorSettings.MA2period = MA2period;
   chartIndicatorSettings.MA2method = MA2method;
   chartIndicatorSettings.MA2applyTo = MA2applyTo;
   chartIndicatorSettings.MA2shift = MA2shift;
   /*
   chartIndicatorSettings.ShowVWAP = ShowVWAP;
   chartIndicatorSettings.VWAP_Period = VWAP_Period;
   chartIndicatorSettings.VWAPapplyTo = VWAPapplyTo;
   chartIndicatorSettings.VWAPvolume = VWAPvolume;
   */
   chartIndicatorSettings.MA3on = MA3on;
   chartIndicatorSettings.MA3period = MA3period;
   chartIndicatorSettings.MA3method = MA3method;
   chartIndicatorSettings.MA3applyTo = MA3applyTo;
   chartIndicatorSettings.MA3shift = MA3shift;
   chartIndicatorSettings.ShowChannel = ShowChannel;
   chartIndicatorSettings.DonchianPeriod = DonchianPeriod;
   chartIndicatorSettings.BBapplyTo = BBapplyTo;
   chartIndicatorSettings.BollingerBandsPeriod = BollingerBandsPeriod;
   chartIndicatorSettings.BollingerBandsDeviations = BollingerBandsDeviations;
   chartIndicatorSettings.SuperTrendPeriod = SuperTrendPeriod;
   chartIndicatorSettings.SuperTrendMultiplier = SuperTrendMultiplier;
   chartIndicatorSettings.ShiftObj = ShiftObj;
   chartIndicatorSettings.UsedInEA = UsedInEA;

   //
   //
   //
   
   alertInfoSettings.TopBottomPaddingPercentage = TopBottomPaddingPercentage;
   alertInfoSettings.showPiovots = showPivots;
   alertInfoSettings.pivotPointCalculationType = pivotPointCalculationType;
   alertInfoSettings.Rcolor = RColor;
   alertInfoSettings.Pcolor = PColor;
   alertInfoSettings.Scolor = SColor;
   alertInfoSettings.PDHColor = PDHColor;
   alertInfoSettings.PDLColor = PDLColor;
   alertInfoSettings.PDCColor = PDCColor;
   alertInfoSettings.showNextBarLevels = showNextBarLevels;
   alertInfoSettings.HighThresholdIndicatorColor = HighThresholdIndicatorColor;
   alertInfoSettings.LowThresholdIndicatorColor = LowThresholdIndicatorColor;
   alertInfoSettings.showCurrentBarOpenTime = showCurrentBarOpenTime;
   alertInfoSettings.InfoTextColor = InfoTextColor;
   
   alertInfoSettings.NewBarAlert = NewBarAlert; 
   alertInfoSettings.ReversalBarAlert = ReversalBarAlert;
   alertInfoSettings.MaCrossAlert = MaCrossAlert ;    
   alertInfoSettings.UseAlertWindow = UseAlertWindow;  
   alertInfoSettings.UseSound = UseSound;
   alertInfoSettings.UsePushNotifications = UsePushNotifications;

   alertInfoSettings.SoundFileBull = SoundFileBull;
   alertInfoSettings.SoundFileBear = SoundFileBear;
   alertInfoSettings.DisplayAsBarChart = DisplayAsBarChart;
   #endif
#endif
}

bool RenkoSettings::Changed(void)
{
   if(MQLInfoInteger((int)MQL5_TESTING))
      return false;
 
   static datetime prevFileTime = 0;

   if(!FileIsExist(this.settingsFileName))
      return false;
      
   int handle = FileOpen(this.settingsFileName,FILE_SHARE_READ|FILE_BIN);  
   datetime currFileTime = (datetime)FileGetInteger(handle,FILE_CREATE_DATE);  
   FileClose(handle); 
 
   if(prevFileTime != currFileTime)
   {
      prevFileTime = currFileTime;
      return true;
   }
   
   return false;
}