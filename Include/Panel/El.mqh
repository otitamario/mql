//+------------------------------------------------------------------+
//|                                                   MBookPanel.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"
#include "Node.mqh"

class CEl : public CNode
{
private:
public:
   CEl();
   virtual void Show();
   virtual void Refresh(void);
   
};
CEl::Show(void)
{
   u//---
   OnShow();
}