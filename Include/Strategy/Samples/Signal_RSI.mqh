//+------------------------------------------------------------------+
#property copyright "Mario"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum Applied_Price //Price to average
  {
   CLOSE,
   HIGH,
   LOW,
   OPEN
  };

#include <Strategy\Strategy.mqh>
#include <Expert\Signal\SignalRSI.mqh>
input int Magic_Number=111;//Magic Number
input ENUM_TIMEFRAMES periodEA=PERIOD_CURRENT;//EA TIMEFRAME
input ulong deviation_points=50;//Deviation Points
input bool UseFixLot=false;//Use Fix Lot
input double Lot=0.01;//Fix Lot Entry
input bool UseLotInc=true;//Use Lot Money Management
input double LotMargin=300.0;//Money for each 0.01 Lot
input double _Stop=100;//Stop Loss in Points
input double _TakeProfit=100;//Take Profit in Points

sinput string shorario="############------TIME FILTER------#################";
input bool UseTimer=true;//Use Time Filter
input string start_hour1="8:30";//Initial Pause Hour 1
input string end_hour1="10:30";//Final Pause Hour 1
input string start_hour2="18:00";//Initial Pause Hour 2
input string end_hour2="20:30";//Final Pause Hour 2
input string start_hour3="23:00";//Initial Pause Hour 3
input string end_hour3="03:00";//Final Pause Hour 3

input bool daytrade=true;//Close Positions on Time Pauses

sinput string STrailing="############---------------Trailing Stop----------########";
input bool   Use_TraillingStop=true; //Use Trailing Stop 
input int TraillingStart=30;//Minimum Profit to Start the Trailing Stop
input int TraillingDistance=90;// Distance in Points to Stop Loss
input int TraillingStep=5;// Trailing Step to update the Stop Loss

input int RSI_Period=14; // RSI Period

input bool every_tick=false;//Every Tick True/False
input int number_hours=6;//Number of Candles to Average
input ENUM_TIMEFRAMES TimeFrameAVG=PERIOD_M30;//TimeFrame of Candles to Avg Prices
input Applied_Price app_price=CLOSE;//Price to Average
input int up_points=100;//Up Range Points
input int down_points=100;//Down Range Points
input int   rsi_Pattern_0=40; //Pattern RSI is directed UP or DOWN
input int   rsi_Pattern_1=100;//Pattern reverse level of overselling/overbuying
input int   rsi_Pattern_2=90;//Pattern "failed swing" signal
input int   rsi_Pattern_3=0;//Pattern "divergence" signal
input int   rsi_Pattern_4=0;//Pattern "double divergence" signal
input int   rsi_Pattern_5=40;//"head/shoulders" signal

input int                Signal_ThresholdOpen          =70;           // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose         =70;           // Signal threshold value to close [0...100]
//+------------------------------------------------------------------+
//| Strategy receives events and displays in terminal.               |
//+------------------------------------------------------------------+
class COnSignal_RSI : public CStrategy
  {
private:
   CSignalRSI        m_signal_rsi;
   CSymbolInfo       mysymbol;
   CiOpen            m_open;
   CiHigh            m_high;
   CiLow             m_low;
   CiClose           m_close;
   CIndicators       m_indicators;
public:
                     COnSignal_RSI(void);
    bool     _InitBuy();
    bool      _InitSell();
    bool      _SupportBuy();
    bool      _SupportSell();
   double            AveragePrice();
   bool              AverageBuy();
   bool              AverageSell();

  };
//+------------------------------------------------------------------+
//| Initialization of the CSignalRSI signal module                  |
//+------------------------------------------------------------------+
COnSignal_RSI::COnSignal_RSI(void)
  {

   m_signal_rsi.Pattern_0(rsi_Pattern_0);
   m_signal_rsi.Pattern_1(rsi_Pattern_1);
   m_signal_rsi.Pattern_2(rsi_Pattern_2);
   m_signal_rsi.Pattern_3(rsi_Pattern_3);
   m_signal_rsi.Pattern_4(rsi_Pattern_4);
   m_signal_rsi.Pattern_5(rsi_Pattern_5);


   mysymbol.Name(Symbol());                                  // Initializing the object that represents the trading symbol of the strategy
   m_signal_rsi.Init(GetPointer(mysymbol),Period(),_Point);   // Initializing the signal module by the trading symbol and timeframe
   m_signal_rsi.InitIndicators(GetPointer(m_indicators)); // Creating required indicators in the signal module based on the empty list of indicators m_indicators
   m_signal_rsi.EveryTick(every_tick);                         // Testing mode
   m_signal_rsi.Magic(ExpertMagic());                     // Magic number
   m_signal_rsi.PatternsUsage(-1);                         // Pattern mask
   m_open.Create(Symbol(), Period());                      // Initializing the timeseries of Open prices
   m_high.Create(Symbol(), Period());                      // Initializing the timeseries of High prices
   m_low.Create(Symbol(), Period());                       // Initializing the timeseries of Low prices
   m_close.Create(Symbol(), Period());                     // Initializing the timeseries of Close prices
   m_signal_rsi.SetPriceSeries(GetPointer(m_open),// Initializing the signal module by timeseries objects
                               GetPointer(m_high),
                               GetPointer(m_low),
                               GetPointer(m_close));
   m_signal_rsi.PeriodRSI(RSI_Period);
   


  }
//+------------------------------------------------------------------+
//| Buying.                                                          |
//+------------------------------------------------------------------+
bool COnSignal_RSI::_InitBuy()
  {
    m_indicators.Refresh();
   m_signal_rsi.SetDirection();
   int power_buy=m_signal_rsi.LongCondition();

//   if(power_buy != 0)
  // if(power_buy>=Signal_ThresholdOpen && AverageBuy())

    //  Trade.Buy(Lot);
    return power_buy>=Signal_ThresholdOpen && AverageBuy();
  }
//+------------------------------------------------------------------+
//| Closing Buys                                                     |
//+------------------------------------------------------------------+
bool COnSignal_RSI::_SupportBuy()
  {
   m_indicators.Refresh();
   m_signal_rsi.SetDirection();
   int power_sell=m_signal_rsi.ShortCondition();
//if(power_sell != 0)

   //if(power_sell>=Signal_ThresholdClose)
     // pos.CloseAtMarket();
     return power_sell>=Signal_ThresholdClose;
  }
//+------------------------------------------------------------------+
//| Selling.                                                         |
//+------------------------------------------------------------------+
bool COnSignal_RSI::_InitSell()
  {
   m_indicators.Refresh();
   m_signal_rsi.SetDirection();
   int power_sell=m_signal_rsi.ShortCondition();
//if(power_sell != 0)

   //if(power_sell>=Signal_ThresholdOpen && AverageSell())
     // Trade.Sell(Lot);
     return power_sell>=Signal_ThresholdOpen && AverageSell();
  }
//+------------------------------------------------------------------+
//| Closing Buys                                                     |
//+------------------------------------------------------------------+
bool COnSignal_RSI::_SupportSell()
  {
   m_indicators.Refresh();
   m_signal_rsi.SetDirection();
   int power_buy=m_signal_rsi.LongCondition();
//if(power_buy != 0)
   //if(power_buy>=Signal_ThresholdClose)

     // pos.CloseAtMarket();
     return power_buy>=Signal_ThresholdClose;
  }
//+------------------------------------------------------------------+
double COnSignal_RSI::AveragePrice()
  {
   double avg=0;
   if(number_hours>0)
     {
      if(app_price==CLOSE)
        {
         for(int i=0;i<number_hours;i++)avg+=iClose(Symbol(),TimeFrameAVG,i);
         avg=NormalizeDouble(avg/number_hours,mysymbol.Digits());
        }
      if(app_price==HIGH)
        {
         for(int i=0;i<number_hours;i++)avg+=iHigh(Symbol(),TimeFrameAVG,i);
         avg=NormalizeDouble(avg/number_hours,mysymbol.Digits());
        }
      if(app_price==LOW)
        {
         for(int i=0;i<number_hours;i++)avg+=iLow(Symbol(),TimeFrameAVG,i);
         avg=NormalizeDouble(avg/number_hours,mysymbol.Digits());
        }
      if(app_price==OPEN)
        {
         for(int i=0;i<number_hours;i++)avg+=iOpen(Symbol(),TimeFrameAVG,i);
         avg=NormalizeDouble(avg/number_hours,mysymbol.Digits());
        }
     }
   return avg;
  }
//+------------------------------------------------------------------+
bool COnSignal_RSI::AverageBuy()
  {
   bool signal;
   signal=iClose(Symbol(),_Period,0)>AveragePrice() && iClose(Symbol(),_Period,0)-AveragePrice()>up_points*mysymbol.Point();

   return signal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool COnSignal_RSI::AverageSell()
  {
   bool signal;
   signal=iClose(Symbol(),_Period,0)<AveragePrice() && iClose(Symbol(),_Period,0)-AveragePrice()<-down_points*mysymbol.Point();
   return signal;
  }

//+------------------------------------------------------------------+
