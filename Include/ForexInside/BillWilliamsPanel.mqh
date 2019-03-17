//+------------------------------------------------------------------+
//|                                            BillWilliamsPanel.mqh |
//|                      Copyright 2015, ForexInside AlgoTrading Lab |
//|                                            http://forexinside.me |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, ForexInside AlgoTrading Lab"
#property link      "http://forexinside.me"

#include <ForexInside\BillWilliamsTS.mqh>

#include <Controls\Dialog.mqh>
#include <Controls\Button.mqh>
#include <Controls\Edit.mqh>
#include <Controls\DatePicker.mqh>
#include <Controls\ListView.mqh>
#include <Controls\ComboBox.mqh>
#include <Controls\SpinEdit.mqh>
#include <Controls\RadioGroup.mqh>
#include <Controls\CheckGroup.mqh>
#include <Controls\Label.mqh>

#define BILLWILLIAMS_DIALOG_WIDTH 420
#define BILLWILLIAMS_DIALOG_HEIGHT 250
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CBillWilliamsDialog : public CAppDialog
  {
public:
                     CBillWilliamsDialog(TBillWilliamsTSParams &_params);
                    ~CBillWilliamsDialog(void);

   virtual bool      Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2);
   virtual bool      OnEvent(const int id,const long &lparam,const double &dparam,const string &sparam);
   TBillWilliamsTSParams GetParams();
protected:
   TBillWilliamsTSParams params;
   void              FromParamsToView();
   void              FromViewToParams();
   void              CreateButton(CButton &btn,string name,string text,int x1,int y1,int x2,int y2);
   void              CreateLabel(CLabel &label,string name,string text,int x1,int y1,int x2,int y2);
   void              CreateEdit(CEdit &edit,string name,string text,int x1,int y1,int x2,int y2);
   void              CreateCheckBox(CCheckBox &chk,string name,string text,int x1,int y1,int x2,int y2);
   void              CreateDivider(CPanel &panel,string name,color clr,int x1,int y1,int x2,int y2);
   void              CreateComboBox(CComboBox &combo,string name,int x1,int y1,int x2,int y2);
   void              onAcceptClicked();
   void              onColorChanged();

   CLabel            labelAnalyzer;
   CLabel            labelAlligator;
   CPanel            divider0;

   CLabel            analyzerLabelBarCount;
   CEdit             analyzerBarCount;
   CCheckBox         analyzerShowSignals;
   CCheckBox         analyzerShowAllSignals;
   CPanel            divider1;

   CCheckBox         alligatorShow;
   CCheckBox         alligatorDisableSleepTrade;

   CLabel            alligatorJawLabel;
   CLabel            alligatorJawPeriodLabel;
   CEdit             alligatorJawPeriod;
   CLabel            alligatorJawShiftLabel;
   CEdit             alligatorJawShift;

   CLabel            alligatorTeethLabel;
   CLabel            alligatorTeethPeriodLabel;
   CEdit             alligatorTeethPeriod;
   CLabel            alligatorTeethShiftLabel;
   CEdit             alligatorTeethShift;

   CLabel            alligatorLipsLabel;
   CLabel            alligatorLipsPeriodLabel;
   CEdit             alligatorLipsPeriod;
   CLabel            alligatorLipsShiftLabel;
   CEdit             alligatorLipsShift;

   CLabel            alligatorMAMethodLabel;
   CComboBox         alligatorMAMethod;
   CLabel            alligatorPriceLabel;
   CComboBox         alligatorPrice;

   CLabel            labelDimensions;
   CLabel            labelDimensionsShow;
   CLabel            labelDimensionsEnableTrade;
   CLabel            labelDim1;
   CLabel            labelDim2;
   CLabel            labelDim3;
   CLabel            labelDim4;
   CLabel            labelDim5;
   CCheckBox         fractalShow;
   CCheckBox         fractalEnableTrade;
   CCheckBox         aoShow;
   CCheckBox         aoEnableTrade;
   CCheckBox         acShow;
   CCheckBox         acEnableTrade;
   CCheckBox         zoneShow;
   CCheckBox         zoneEnableTrade;
   CCheckBox         balanceLineShow;
   CCheckBox         balanceLineEnableTrade;

   CPanel            divider2;
   CLabel            tradeLotLabel;
   CEdit             tradeLot;
   CLabel            tradeMagicLabel;
   CEdit             tradeMagic;

   CLabel            viewColorRedLabel;
   CEdit             viewColorRed;
   CLabel            viewColorGreenLabel;
   CEdit             viewColorGreen;
   CLabel            viewColorBlueLabel;
   CEdit             viewColorBlue;
   CPanel            viewColorPanel;

   CButton           buAccept;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
EVENT_MAP_BEGIN(CBillWilliamsDialog)
ON_EVENT(ON_CLICK,buAccept,onAcceptClicked)
ON_EVENT(ON_END_EDIT,viewColorRed,onColorChanged)
ON_EVENT(ON_END_EDIT,viewColorGreen,onColorChanged)
ON_EVENT(ON_END_EDIT,viewColorBlue,onColorChanged)
EVENT_MAP_END(CAppDialog)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBillWilliamsDialog::CBillWilliamsDialog(TBillWilliamsTSParams &_params)
  {
   params=_params;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CBillWilliamsDialog::~CBillWilliamsDialog(void)
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
TBillWilliamsTSParams CBillWilliamsDialog::GetParams()
  {
   return params;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsDialog::CreateButton(CButton &btn,string name,string text,int x1,int y1,int x2,int y2)
  {
   btn.Create(m_chart_id,m_name+name,m_subwin,x1,y1,x2,y2);
   Add(btn);
   btn.Text(text);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsDialog::CreateLabel(CLabel &label,string name,string text,int x1,int y1,int x2,int y2)
  {
   label.Create(m_chart_id,m_name+name,m_subwin,x1,y1,x2,y2);
   Add(label);
   label.Text(text);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsDialog::CreateEdit(CEdit &edit,string name,string text,int x1,int y1,int x2,int y2)
  {
   edit.Create(m_chart_id,m_name+name,m_subwin,x1,y1,x2,y2);
   Add(edit);
   edit.Text(text);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsDialog::CreateCheckBox(CCheckBox &chk,string name,string text,int x1,int y1,int x2,int y2)
  {
   chk.Create(m_chart_id,m_name+name,m_subwin,x1,y1,x2,y2);
   Add(chk);
   chk.Text(text);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsDialog::CreateDivider(CPanel &panel,string name,color clr,int x1,int y1,int x2,int y2)
  {
   panel.Create(m_chart_id,m_name+name,m_subwin,x1,y1,x2,y2);
   Add(panel);
   panel.ColorBackground(clr);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsDialog::CreateComboBox(CComboBox &combo,string name,int x1,int y1,int x2,int y2)
  {
   combo.Create(m_chart_id,m_name+name,m_subwin,x1,y1,x2,y2);
   Add(combo);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsDialog::FromParamsToView()
  {
   analyzerBarCount.Text(IntegerToString(params.AnalyzerBarCount));
   analyzerShowSignals.Checked(params.AnalyzerShowSignals);
   analyzerShowAllSignals.Checked(params.AnalyzerShowAllSignals);
//---
   alligatorShow.Checked(params.AlligatorShow);
   alligatorJawPeriod.Text(IntegerToString(params.AlligatorJawPeriod));
   alligatorJawShift.Text(IntegerToString(params.AlligatorJawShift));
   alligatorTeethPeriod.Text(IntegerToString(params.AlligatorTeethPeriod));
   alligatorTeethShift.Text(IntegerToString(params.AlligatorTeethShift));
   alligatorLipsPeriod.Text(IntegerToString(params.AlligatorLipsPeriod));
   alligatorLipsShift.Text(IntegerToString(params.AlligatorLipsShift));
   alligatorMAMethod.Select(params.AlligatorMAMethod);
   alligatorPrice.Select(((int)params.AlligatorAppliedPrice)-1);
//---
   fractalEnableTrade.Checked(params.FractalEnableTrade);
   fractalShow.Checked(params.FractalShow);
   aoEnableTrade.Checked(params.AOEnableTrade);
   aoShow.Checked(params.AOShow);
   acEnableTrade.Checked(params.ACEnableTrade);
   acShow.Checked(params.ACShow);
   zoneShow.Checked(params.ZoneShow);
   zoneEnableTrade.Checked(params.ZoneEnableTrade);
   balanceLineShow.Checked(params.BalanceLineShow);
   balanceLineEnableTrade.Checked(params.BalanceLineEnableTrade);
//---
   tradeLot.Text(DoubleToString(params.TradeLot,2));
//---
   uint clr=params.ViewColor;
   viewColorBlue.Text(IntegerToString((clr>>16)&0xff));
   viewColorGreen.Text(IntegerToString((clr>>8)&0xff));
   viewColorRed.Text(IntegerToString((clr>>0)&0xff));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsDialog::FromViewToParams()
  {
   params.AnalyzerBarCount=(int)StringToInteger(analyzerBarCount.Text());
   params.AnalyzerShowSignals=analyzerShowSignals.Checked();
   params.AnalyzerShowAllSignals=analyzerShowAllSignals.Checked();
//---
   params.AlligatorShow=alligatorShow.Checked();
   params.AlligatorJawPeriod=(int)StringToInteger(alligatorJawPeriod.Text());
   params.AlligatorJawShift =(int)StringToInteger(alligatorJawShift.Text());
   params.AlligatorTeethPeriod=(int)StringToInteger(alligatorTeethPeriod.Text());
   params.AlligatorTeethShift = (int)StringToInteger(alligatorTeethShift.Text());
   params.AlligatorLipsPeriod = (int)StringToInteger(alligatorLipsPeriod.Text());
   params.AlligatorLipsShift=(int)StringToInteger(alligatorLipsShift.Text());
   params.AlligatorMAMethod =(ENUM_MA_METHOD)alligatorMAMethod.Value();
   params.AlligatorAppliedPrice=(ENUM_APPLIED_PRICE)(alligatorPrice.Value()+1);
//---
   params.FractalEnableTrade=fractalEnableTrade.Checked();
   params.FractalShow=fractalShow.Checked();
   params.AOEnableTrade=aoEnableTrade.Checked();
   params.AOShow=aoShow.Checked();
   params.ACEnableTrade=acEnableTrade.Checked();
   params.ACShow=acShow.Checked();
   params.ZoneShow=zoneShow.Checked();
   params.ZoneEnableTrade = zoneEnableTrade.Checked();
   params.BalanceLineShow = balanceLineShow.Checked();
   params.BalanceLineEnableTrade=balanceLineEnableTrade.Checked();
//---
   params.TradeLot=StringToDouble(tradeLot.Text());
//---
   onColorChanged();
   params.ViewColor=viewColorPanel.ColorBackground();
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsDialog::onAcceptClicked()
  {
   FromViewToParams();
   EventChartCustom(0,100,0,0,"");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CBillWilliamsDialog::onColorChanged()
  {
   uint r = (uint)StringToInteger(viewColorRed.Text());
   uint g = (uint)StringToInteger(viewColorGreen.Text());
   uint b = (uint)StringToInteger(viewColorBlue.Text());
   color clr=(color)((b<<16)+(g<<8)+(r));
   viewColorPanel.ColorBackground(clr);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CBillWilliamsDialog::Create(const long chart,const string name,const int subwin,const int x1,const int y1,const int x2,const int y2)
  {
   if(!CAppDialog::Create(chart,name,subwin,x1,y1,x2,y2)) return false;
   int x0=5;
   int y0=5;
   int hControl=20;
   int dy=2;
   int half=BILLWILLIAMS_DIALOG_WIDTH/2;
   int half_margin=10;
   int w=BILLWILLIAMS_DIALOG_WIDTH-half_margin;
   CreateDivider(divider1,"Divider1",0xdddddd,half-2,y0,half+2,BILLWILLIAMS_DIALOG_HEIGHT-28-y0);
//---
   int x=x0;
   int y=y0;
   CreateLabel(labelAnalyzer,"labelCommon","Analyzer:",x,y,0,0);
   CreateCheckBox(analyzerShowSignals,"analyzerShowSignals","Show signals",x+60,y,half-half_margin,y+hControl); y+=hControl+dy;
   CreateLabel(viewColorRedLabel,"viewColorRedLabel","R:",x,y,0,0);
   CreateEdit(viewColorRed,"viewColorRed","",x+15,y,x+45,y+hControl);
   CreateLabel(viewColorGreenLabel,"viewColorGreenLabel","G:",x+50,y,0,0);
   CreateEdit(viewColorGreen,"viewColorGreen","",x+65,y,x+95,y+hControl);
   CreateLabel(viewColorBlueLabel,"viewColorBlueLabel","B:",x+100,y,0,0);
   CreateEdit(viewColorBlue,"viewColorBlue","",x+115,y,x+145,y+hControl);
   CreateDivider(viewColorPanel,"viewColorPanel",clrGreen,x+150,y,x+190,y+hControl); y+=hControl+dy;
   CreateLabel(analyzerLabelBarCount,"analyzerLabelBarCount","BarCount:",x,y,0,0);
   CreateEdit(analyzerBarCount,"analyzerBarCount","",x+63,y,half-half_margin,y+hControl); y+=hControl+dy+dy+dy;
   CreateDivider(divider0,"Divider0",0xdddddd,x,y,half-half_margin,y+4); y+=dy+dy;
   CreateLabel(labelAlligator,"labelAlligator","Alligator:",x,y,0,0);
   CreateCheckBox(alligatorShow,"alligatorShow","Show",x+60,y,x+120,y+hControl); y+=hControl+dy;
   int xlab1=x+40;
   int xval1=x+90;
   int xlab2=x+125;
   int xval2=x+165;
   CreateLabel(alligatorJawLabel,"alligatorJawLabel","Jaw:",x,y,0,0);
   CreateLabel(alligatorJawPeriodLabel,"alligatorJawPeriodLabel","Period:",xlab1,y,0,0);
   CreateEdit(alligatorJawPeriod,"alligatorJawPeriod","",xval1,y,xlab2-7,y+hControl);
   CreateLabel(alligatorJawShiftLabel,"alligatorJawShiftLabel","Shift:",xlab2,y,0,0);
   CreateEdit(alligatorJawShift,"alligatorJawShift","",xval2,y,half-half_margin,y+hControl); y+=hControl+dy;
//---
   CreateLabel(alligatorTeethLabel,"alligatorTeethLabel","Teeth:",x,y,0,0);
   CreateLabel(alligatorTeethPeriodLabel,"alligatorTeethPeriodLabel","Period:",xlab1,y,0,0);
   CreateEdit(alligatorTeethPeriod,"alligatorTeethPeriod","",xval1,y,xlab2-7,y+hControl);
   CreateLabel(alligatorTeethShiftLabel,"alligatorTeethShiftLabel","Shift:",xlab2,y,0,0);
   CreateEdit(alligatorTeethShift,"alligatorTeethShift","",xval2,y,half-half_margin,y+hControl); y+=hControl+dy;
//---
   CreateLabel(alligatorLipsLabel,"alligatorLipsLabel","Lips:",x,y,0,0);
   CreateLabel(alligatorLipsPeriodLabel,"alligatorLipsPeriodLabel","Period:",xlab1,y,0,0);
   CreateEdit(alligatorLipsPeriod,"alligatorLipsPeriod","",xval1,y,xlab2-7,y+hControl);
   CreateLabel(alligatorLipsShiftLabel,"alligatorLipsShiftLabel","Shift:",xlab2,y,0,0);
   CreateEdit(alligatorLipsShift,"alligatorLipsShift","",xval2,y,half-half_margin,y+hControl); y+=hControl+dy;
//---
   CreateLabel(alligatorMAMethodLabel,"alligatorMAMethodLabel","MA:",x,y,0,0);
   CreateComboBox(alligatorMAMethod,"alligatorMAMethod",xlab1,y,half-half_margin,y+hControl); y+=hControl+dy;
   CreateLabel(alligatorPriceLabel,"alligatorPriceLabel","Price:",x,y,0,0);
   CreateComboBox(alligatorPrice,"alligatorPrice",xlab1,y,half-half_margin,y+hControl); y+=hControl+dy;
   alligatorMAMethod.AddItem("Simple",MODE_SMA);
   alligatorMAMethod.AddItem("Exponential",MODE_EMA);
   alligatorMAMethod.AddItem("Smoothed",MODE_SMMA);
   alligatorMAMethod.AddItem("Linear weighted",MODE_LWMA);
   alligatorPrice.AddItem("Close",PRICE_CLOSE);
   alligatorPrice.AddItem("Open",PRICE_OPEN);
   alligatorPrice.AddItem("High",PRICE_HIGH);
   alligatorPrice.AddItem("Low",PRICE_LOW);
   alligatorPrice.AddItem("Median",PRICE_MEDIAN);
   alligatorPrice.AddItem("Typical",PRICE_TYPICAL);
   alligatorPrice.AddItem("Weighted",PRICE_WEIGHTED);
//---
   x=half+x0;
   y=y0;
   CreateLabel(labelDimensions,"labelDimensions","Dimension",x+10,y,0,0);
   CreateLabel(labelDimensionsShow,"labelDimensionsShow","Show",x+100,y,0,0);
   CreateLabel(labelDimensionsEnableTrade,"labelDimensionsEnableTrade","Trade",x+150,y,0,0); y+=hControl+dy;
   int xshow=x+105;
   int xtrade=x+160;
   CreateLabel(labelDim1,"labelDim1","Dim1.Fractals:",x,y,0,0);
   CreateCheckBox(fractalShow,"fractalShow","",xshow,y,xshow+20,y+hControl);
   CreateCheckBox(fractalEnableTrade,"fractalEnableTrade","",xtrade,y,xtrade+20,y+hControl); y+=hControl+dy;
   CreateLabel(labelDim2,"labelDim2","Dim2.AO:",x,y,0,0);
   CreateCheckBox(aoShow,"aoShow","",xshow,y,xshow+20,y+hControl);
   CreateCheckBox(aoEnableTrade,"aoEnableTrade","",xtrade,y,xtrade+20,y+hControl); y+=hControl+dy;
   CreateLabel(labelDim3,"labelDim3","Dim3.AC:",x,y,0,0);
   CreateCheckBox(acShow,"acShow","",xshow,y,xshow+20,y+hControl);
   CreateCheckBox(acEnableTrade,"acEnableTrade","",xtrade,y,xtrade+20,y+hControl); y+=hControl+dy;
   CreateLabel(labelDim4,"labelDim4","Dim4.Zones:",x,y,0,0);
   CreateCheckBox(zoneShow,"zoneShow","",xshow,y,xshow+20,y+hControl);
   CreateCheckBox(zoneEnableTrade,"zoneEnableTrade","",xtrade,y,xtrade+20,y+hControl); y+=hControl+dy;
   CreateLabel(labelDim5,"labelDim5","Dim5.Balance:",x,y,0,0);
   CreateCheckBox(balanceLineShow,"balanceLineShow","",xshow,y,xshow+20,y+hControl);
   CreateCheckBox(balanceLineEnableTrade,"balanceLineEnableTrade","",xtrade,y,xtrade+20,y+hControl); y+=hControl+dy;
   CreateCheckBox(analyzerShowAllSignals,"analyzerShowAllSignals","Show out of trend signals",x-2,y,w,y+hControl); y+=hControl+dy;
//---
   CreateDivider(divider2,"Divider2",0xdddddd,x,y,w,y+4);y+=dy+dy+dy;
   xval1=x+50;
   CreateLabel(tradeLotLabel,"tradeLotLabel","Lot:",x,y,0,0);
   CreateEdit(tradeLot,"tradeLot","",xval1,y,w,y+hControl); y+=hControl+dy;
//---
   y+=dy;
   CreateButton(buAccept,"buAccept","Accept",half+5,y,half+5+100,y+hControl);
//---
   FromParamsToView();
   onColorChanged();
   return true;
  }
//+------------------------------------------------------------------+
