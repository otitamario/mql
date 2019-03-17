#property copyright "Copyright 2011-2018, AZ-iNVEST"

static bool IS_TESTING = (bool)MQLInfoInteger(MQL_TESTER);

enum ENUM_BOOL
{
#ifdef P_RENKO_BR
   BFalse = 0,             // Não 
   BTrue = 1,              // Sim 
#else
   BFalse = 0,             // No 
   BTrue = 1,              // Yes 
#endif
};

enum ENUM_MA_METHOD_EXT
{
#ifdef P_RENKO_BR
   _MODE_SMA = 0,          // Simples 
   _MODE_EMA,              // Exponencial 
   _MODE_SMMA,             // Suavizada 
   _MODE_LWMA,             // Ponderada
   _VWAP_TICKVOL = 998,    // VWMA (tick volume)
   _VWAP_REALVOL = 999,    // VWMA (real volume)
#else
   _MODE_SMA = 0,          // Simple
   _MODE_EMA,              // Exponential
   _MODE_SMMA,             // Smoothed
   _MODE_LWMA,             // Linear-weighted
   _VWAP_TICKVOL = 998,    // Volume-weighted (tick volume)
   _VWAP_REALVOL = 999,    // Volume-weighted (real volume)
#endif
};
enum ENUM_CHANNEL_TYPE
{
   None = 0,               // None
   Donchian_Channel,       // Donchian Channel
   Bollinger_Bands,        // Bollinger Bands
   SuperTrend,             // Super Trend
};

enum ENUM_TICK_PRICE_TYPE
{
   tickBid,                // Bid price
   tickAsk,                // Ask price
   tickLast,               // Last price
};

enum ENUM_PIVOT_POINTS
{
   ppNone = 0,             // None
   ppClassic,              // Classic
   ppFibo,                 // Fibonacci
};

enum ENUM_PIVOT_TYPE
{
   ppHLC3,                 // (H+L+C) / 3
   ppOHLC4,                // (O+H+L+C) / 4
};

enum ENUM_ALERT_TYPE 
{
   ALERT_NEW_BAR_BULL = 0,
   ALERT_NEW_BAR_BEAR,
   ALERT_MA_CROSS_BULL,
   ALERT_MA_CROSS_BEAR,
};

//
//  Settigns used by CustomBarProcessor class for alert & info purposes
//

struct ALERT_INFO_SETTINGS
{
   double            TopBottomPaddingPercentage;
   ENUM_PIVOT_POINTS showPiovots;
   ENUM_PIVOT_TYPE   pivotPointCalculationType; 
   color             Rcolor;
   color             Pcolor;
   color             Scolor;
   color             PDHColor;
   color             PDLColor;
   color             PDCColor;   
   ENUM_BOOL         showNextBarLevels;
   color             HighThresholdIndicatorColor;
   color             LowThresholdIndicatorColor;
   ENUM_BOOL         showCurrentBarOpenTime;
   color             InfoTextColor;
   
   ENUM_BOOL         NewBarAlert;
   ENUM_BOOL         ReversalBarAlert;
   ENUM_BOOL         MaCrossAlert;
   ENUM_BOOL         UseAlertWindow;
   ENUM_BOOL         UseSound; 
   ENUM_BOOL         UsePushNotifications;
   string            SoundFileBull;
   string            SoundFileBear;
   
   ENUM_BOOL         DisplayAsBarChart;
};

//
// Settings used for on chart indicators
//

struct CHART_INDICATOR_SETTINGS
{
   ENUM_BOOL            MA1on; 
   int                  MA1period;
   ENUM_MA_METHOD_EXT   MA1method;
   ENUM_APPLIED_PRICE   MA1applyTo;
   int                  MA1shift;
   
   ENUM_BOOL            MA2on; 
   int                  MA2period;
   ENUM_MA_METHOD_EXT   MA2method;
   ENUM_APPLIED_PRICE   MA2applyTo;
   int                  MA2shift;

   ENUM_BOOL            MA3on; 
   int                  MA3period;
   ENUM_MA_METHOD_EXT   MA3method;
   ENUM_APPLIED_PRICE   MA3applyTo;
   int                  MA3shift;
      
   ENUM_CHANNEL_TYPE    ShowChannel;
   
   int                  DonchianPeriod;
   
   ENUM_APPLIED_PRICE   BBapplyTo;
   int                  BollingerBandsPeriod;
   double               BollingerBandsDeviations;
   
   int                  SuperTrendPeriod;
   double               SuperTrendMultiplier;   
   
   ENUM_BOOL            UsedInEA;
   ENUM_BOOL            ShiftObj;
};

#ifdef P_RENKO_BR
enum ENUM_CHART_SIZE
{
   _1R = 1, //1R (Renko)
   _2R, //2R (Renko)
   _3R, //3R (Renko)
   _4R, //4R (Renko)
   _5R, //5R (Renko)
   _6R, //6R (Renko)
   _7R, //7R (Renko)
   _8R, //8R (Renko)
   _9R, //9R (Renko)
   _10R, //10R (Renko)
   _11R, //11R (Renko)
   _12R, //12R (Renko)
   _13R, //13R (Renko)
   _14R, //14R (Renko)
   _15R, //15R (Renko)
   _16R, //16R (Renko)
   _17R, //17R (Renko)
   _18R, //18R (Renko)
   _19R, //19R (Renko)
   _20R, //20R (Renko)
   _21R, //21R (Renko)
   _22R, //22R (Renko)
   _23R, //23R (Renko)
   _24R, //24R (Renko)
   _25R, //25R (Renko)
   _26R, //26R (Renko)
   _27R, //27R (Renko)
   _28R, //28R (Renko)
   _29R, //29R (Renko)
   _30R, //30R (Renko)
   _31R, //31R (Renko)
   _32R, //32R (Renko)
   _33R, //33R (Renko)
   _34R, //34R (Renko)
   _35R, //35R (Renko)
   _36R, //36R (Renko)
   _37R, //37R (Renko)
   _38R, //38R (Renko)
   _39R, //39R (Renko)
   _40R, //40R (Renko)
   _41R, //41R (Renko)
   _42R, //42R (Renko)
   _43R, //43R (Renko)
   _44R, //44R (Renko)
   _45R, //45R (Renko)
   _46R, //46R (Renko)
   _47R, //47R (Renko)
   _48R, //48R (Renko)
   _49R, //49R (Renko)
   _50R, //50R (Renko)
   _1P, //1P (Preço)
   _2P, //2P (Preço)
   _3P, //3P (Preço)
   _4P, //4P (Preço)
   _5P, //5P (Preço)
   _6P, //6P (Preço)
   _7P, //7P (Preço)
   _8P, //8P (Preço)
   _9P, //9P (Preço)
   _10P, //10P (Preço)
   _11P, //11P (Preço)
   _12P, //12P (Preço)
   _13P, //13P (Preço)
   _14P, //14P (Preço)
   _15P, //15P (Preço)
   _16P, //16P (Preço)
   _17P, //17P (Preço)
   _18P, //18P (Preço)
   _19P, //19P (Preço)
   _20P, //20P (Preço)
   _21P, //21P (Preço)
   _22P, //22P (Preço)
   _23P, //23P (Preço)
   _24P, //24P (Preço)
   _25P, //25P (Preço)
   _26P, //26P (Preço)
   _27P, //27P (Preço)
   _28P, //28P (Preço)
   _29P, //29P (Preço)
   _30P, //30P (Preço)
   _31P, //31P (Preço)
   _32P, //32P (Preço)
   _33P, //33P (Preço)
   _34P, //34P (Preço)
   _35P, //35P (Preço)
   _36P, //36P (Preço)
   _37P, //37P (Preço)
   _38P, //38P (Preço)
   _39P, //39P (Preço)
   _40P, //40P (Preço)
   _41P, //41P (Preço)
   _42P, //42P (Preço)
   _43P, //43P (Preço)
   _44P, //44P (Preço)
   _45P, //45P (Preço)
   _46P, //46P (Preço)
   _47P, //47P (Preço)
   _48P, //48P (Preço)
   _49P, //49P (Preço)
   _50P, //50P (Preço)
};
#endif

