//+------------------------------------------------------------------+
//|                                                 SampleSignal.mqh |
//|                      Copyright 2015, ForexInside AlgoTrading Lab |
//|                                            http://forexinside.me |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, ForexInside AlgoTrading Lab"
#property link      "http://forexinside.me"

#include <Expert\ExpertSignal.mqh>
#include <ForexInside\BillWilliamsTS.mqh>
#include <ForexInside\BillWilliamsPanel.mqh>
// wizard description start
//+------------------------------------------------------------------+
//| Description of the class                                         |
//| Title=Signal of BillWilliams trading system                      |
//| Type=SignalAdvanced                                              |
//| Name=BillWilliamsSignal                                          |
//| Class=CBillWilliamsSignal                                        |
//| Page=billwilliams_signal                                         |
//| Parameter=AnalyzerBarCount,int,300                               |
//| Parameter=AnalyzerShowSignals,bool,true                          |
//| Parameter=AnalyzerShowAllSignals,bool,false                      |
//| Parameter=AlligatorShow,bool,true                                |
//| Parameter=AlligatorJawPeriod,int,13                              |
//| Parameter=AlligatorJawShift,int,8                                |
//| Parameter=AlligatorTeethPeriod,int,8                             |
//| Parameter=AlligatorTeethShift,int,5                              |
//| Parameter=AlligatorLipsPeriod,int,5                              |
//| Parameter=AlligatorLipsShift,int,3                               |
//| Parameter=AlligatorMAMethod,ENUM_MA_METHOD,MODE_SMMA             |
//| Parameter=AlligatorAppliedPrice,ENUM_APPLIED_PRICE,PRICE_MEDIAN  |
//| Parameter=FractalShow,bool,true                                  |
//| Parameter=FractalEnableTrade,bool,true                           |
//| Parameter=AOShow,bool,true                                       |
//| Parameter=AOEnableTrade,bool,true                                |
//| Parameter=ACShow,bool,true                                       |
//| Parameter=ACEnableTrade,bool,true                                |
//| Parameter=ZoneShow,bool,true                                     |
//| Parameter=ZoneEnableTrade,bool,true                              |
//| Parameter=BalanceLineShow,bool,true                              |
//| Parameter=BalanceEnableTrade,bool,true                           |
//| Parameter=TradeLot,double,0.1                                    |
//| Parameter=ViewColor,color,clrBlue                                |
//+------------------------------------------------------------------+
// wizard description end
class CBillWilliamsSignal : public CExpertSignal
  {
private:
   CBillWilliamsDialog *dlg;
   CBillWilliamsTS *ts;
   TBillWilliamsTSParams params;
public:
                     CBillWilliamsSignal();
                    ~CBillWilliamsSignal();

   void              ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);

   void AnalyzerBarCount(int value) { params.AnalyzerBarCount=value; }
   void AnalyzerShowSignals(bool value) { params.AnalyzerShowSignals=value; }
   void AnalyzerShowAllSignals(bool value) { params.AnalyzerShowAllSignals=value; }
   void AlligatorShow(bool value) { params.AlligatorShow=value;}
   void AlligatorJawPeriod(int value) { params.AlligatorJawPeriod=value;}
   void AlligatorJawShift(int value) { params.AlligatorJawShift=value;}
   void AlligatorTeethPeriod(int value) { params.AlligatorTeethPeriod=value;}
   void AlligatorTeethShift(int value) { params.AlligatorTeethShift=value;}
   void AlligatorLipsPeriod(int value) { params.AlligatorLipsPeriod=value;}
   void AlligatorLipsShift(int value) { params.AlligatorLipsShift=value;}
   void AlligatorMAMethod(ENUM_MA_METHOD value) { params.AlligatorMAMethod=value;}
   void AlligatorAppliedPrice(ENUM_APPLIED_PRICE value) { params.AlligatorAppliedPrice=value;}
   void FractalShow(bool value) { params.FractalShow=value;}
   void FractalEnableTrade(bool value) { params.FractalEnableTrade=value;}
   void AOShow(bool value) { params.AOShow=value;}
   void AOEnableTrade(bool value) { params.AOEnableTrade=value;}
   void ACShow(bool value) { params.ACShow=value;}
   void ACEnableTrade(bool value) { params.ACEnableTrade=value;}
   void ZoneShow(bool value) { params.ZoneShow=value;}
   void ZoneEnableTrade(bool value) { params.ZoneEnableTrade=value;}
   void BalanceLineShow(bool value) { params.BalanceLineShow=value;}
   void BalanceEnableTrade(bool value) { params.BalanceLineEnableTrade=value;}
   void TradeLot(double value) { params.TradeLot=value;}
   void ViewColor(color value) { params.ViewColor=value;}

   virtual bool      ValidationSettings();
   virtual bool      InitIndicators(CIndicators *indicators);
   virtual bool      CheckOpenLong(double &price,double &sl,double &tp,datetime &expiration);
   virtual bool      CheckOpenShort(double &price,double &sl,double &tp,datetime &expiration);
   virtual int       LongCondition(void);
   virtual int       ShortCondition(void);
   virtual bool      OpenLongParams(double &price,double &sl,double &tp,datetime &expiration);
   virtual bool      OpenShortParams(double &price,double &sl,double &tp,datetime &expiration);
   virtual bool      CheckCloseLong(double &price);
   virtual bool      CheckCloseShort(double &price);
   virtual bool      CloseLongParams(double &price);
   virtual bool      CloseShortParams(double &price);

   void              ChartEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsSignal::CBillWilliamsSignal()
  {
   ts=NULL;
   dlg=NULL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBillWilliamsSignal::~CBillWilliamsSignal()
  {
   if(ts!=NULL) delete ts;
   if(dlg!=NULL) delete dlg;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBillWilliamsSignal::ValidationSettings()
  {
   if(ts!=NULL) delete ts;
   ts=new CBillWilliamsTS(params,true,false);
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBillWilliamsSignal::InitIndicators(CIndicators *indicators)
  {
   int x0=10;
   int y0=10;
   bool isTester=MQLInfoInteger(MQL_TESTER);
   if(!isTester)
     {
      dlg=new CBillWilliamsDialog(params);
      if(!dlg.Create(0,"BillWilliams Trade System Panel",0,x0,y0,x0+BILLWILLIAMS_DIALOG_WIDTH,y0+BILLWILLIAMS_DIALOG_HEIGHT)) return INIT_FAILED;
      dlg.Run();
     }
   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsSignal::ChartEvent(const int id,
                                     const long &lparam,
                                     const double &dparam,
                                     const string &sparam)
  {
   if(id==CHARTEVENT_CUSTOM+100)
     {
      if(dlg!=NULL)
        {
         if(ts!=NULL) delete ts;
         ts=new CBillWilliamsTS(dlg.GetParams(),true,false);
        }
      if(ts!=NULL) ts.ProcessTick();
      return;
     }
   if(dlg!=NULL) dlg.ChartEvent(id,lparam,dparam,sparam);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBillWilliamsSignal::CheckOpenLong(double &price,double &sl,double &tp,datetime &expiration)
  {
   ts.ProcessTick();
   if(ts.openBuySignal>0)
     {
      price=ts.openBuySignal;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBillWilliamsSignal::CheckOpenShort(double &price,double &sl,double &tp,datetime &expiration)
  {
   ts.ProcessTick();
   if(ts.openSellSignal>0)
     {
      price=ts.openSellSignal;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CBillWilliamsSignal::LongCondition()
  {
   ts.ProcessTick();
   if(ts.openBuySignal>0)
     {
      return 10;
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CBillWilliamsSignal::ShortCondition()
  {
   ts.ProcessTick();
   if(ts.openSellSignal>0)
     {
      return 10;
     }
   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBillWilliamsSignal::OpenLongParams(double &price,double &sl,double &tp,datetime &expiration)
  {
   return CheckOpenLong(price,sl,tp,expiration);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBillWilliamsSignal::OpenShortParams(double &price,double &sl,double &tp,datetime &expiration)
  {
   return CheckOpenShort(price,sl,tp,expiration);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBillWilliamsSignal::CheckCloseLong(double &price)
  {
   ts.ProcessTick();
   return ts.closeBuySignal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBillWilliamsSignal::CheckCloseShort(double &price)
  {
   ts.ProcessTick();
   return ts.closeSellSignal;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBillWilliamsSignal::CloseLongParams(double &price)
  {
   return CheckCloseLong(price);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBillWilliamsSignal::CloseShortParams(double &price)
  {
   return CheckCloseShort(price);
  }
//+------------------------------------------------------------------+
