//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "© 2005-2007 RickD"
#property link      "www.e2e-fx.net"

#define major   1
#define minor   0

#include <Trade\Trade.mqh>
#include <Trade\PositionInfo.mqh>
#include <Expert\Expert.mqh>
#include<Trade\AccountInfo.mqh>

#import "user32.dll"
int SendMessageW(int hWnd,int Msg,int wParam,int lParam);
int FindWindowW(int lpClassName,string lpWindowName);

#import "kernel32.dll"
int GlobalAddAtomW(string str);
int GlobalDeleteAtom(int atom);
int GlobalGetAtomNameW(int atom,int &buf[],int size);
#import


CAccountInfo      myaccount;
CDealInfo         mydeal;
CTrade            mytrade;
CPositionInfo     myposition;
CSymbolInfo       mysymbol;
COrderInfo        myorder;
CHistoryOrderInfo myhistory;

#define FormClass NULL
#define WND_NAME  "MT4.DDE.2"

#define WM_USER         0x0400
#define WM_CHECKITEM    0x0401
#define WM_ADDITEM      0x0402
#define WM_SETITEM      0x0403

double _profit,swap;        //
string conta;
//-----------------------------------------------------------------------------

void OnInit()
  {
   EventSetTimer(1);
conta=IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN));
//--- creation of the indicator iMA
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {
//
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {
//--- filling an array MA[] with current values of iMA
//--- Copying 100 elements

// Check & Add Item DDE

   for(int i=PositionsTotal()-1;i>=0; i--)
     {
      if(myposition.SelectByIndex(i))
        {

         if(!CheckItem(conta+"_Position_"+IntegerToString(i),myposition.Symbol())) AddItem(conta+"_Position_"+IntegerToString(i),myposition.Symbol());
         _profit=myposition.Profit();
         SetItem(conta+"_Position_"+IntegerToString(i),myposition.Symbol(),DoubleToString(_profit,2));

         if(!CheckItem(conta+"_Swap_"+IntegerToString(i),myposition.Symbol())) AddItem(conta+"_Swap_"+IntegerToString(i),myposition.Symbol());
         swap=myposition.Swap();
         SetItem(conta+"_Swap_"+IntegerToString(i),myposition.Symbol(),DoubleToString(swap,2));


        }
     }

// Set Item Value DDE  

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
  }
//-------------------------------------------------------------------------------

bool CheckItem(string topic,string item)
  {
   int hWnd=FindWindowW(FormClass,WND_NAME);
   if(hWnd==0)
     {
      Alert("Cannot find "+WND_NAME+" window!");
      return(false);
     }

   int _item=GlobalAddAtomW(topic+"!"+item);
   if(_item==0)
     {
      Alert("Cannot create "+topic+"!"+item+" atom!");
      return(false);
     }

   int ret=SendMessageW(hWnd,WM_CHECKITEM,_item,0);
   GlobalDeleteAtom(_item);

   bool res=HIWORD(ret);
   if(res) return(true);

   int atm = LOWORD(ret);
   if(atm != 0)
     {
      int buf[255];
      int cnt=GlobalGetAtomNameW(atm,buf,255*4);
      GlobalDeleteAtom(atm);

      string str=MakeStr(buf,cnt);
      Alert("[CheckItem] "+str);
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool AddItem(string topic,string item)
  {
   int hWnd=FindWindowW(FormClass,WND_NAME);
   if(hWnd==0)
     {
      Alert("Cannot find "+WND_NAME+" window!");
      return(false);
     }

   int _item=GlobalAddAtomW(topic+"!"+item);
   if(_item==0)
     {
      Alert("Cannot create "+topic+"!"+item+" atom!");
      return(false);
     }

   int ret=SendMessageW(hWnd,WM_ADDITEM,_item,0);
   GlobalDeleteAtom(_item);

   bool res=HIWORD(ret);
   if(res) return(true);

   int atm = LOWORD(ret);
   if(atm != 0)
     {
      int buf[255];
      int cnt=GlobalGetAtomNameW(atm,buf,255*4);
      GlobalDeleteAtom(atm);

      string str=MakeStr(buf,cnt);
      Alert("[AddItem] "+str);
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool SetItem(string topic,string item,string val)
  {
   int hWnd=FindWindowW(FormClass,WND_NAME);
   if(hWnd==0)
     {
      Alert("Cannot find "+WND_NAME+" window!");
      return(false);
     }

   int _item= GlobalAddAtomW(topic+"!"+item);
   if(_item == 0)
     {
      Alert("Cannot create "+topic+"!"+item+" atom!");
      return(false);
     }

   int _val= GlobalAddAtomW(val);
   if(_val == 0)
     {
      Alert("Cannot create "+val+" atom!");
      GlobalDeleteAtom(_item);
      return(false);
     }

   int ret=SendMessageW(hWnd,WM_SETITEM,_item,_val);
   GlobalDeleteAtom(_val);
   GlobalDeleteAtom(_item);

   bool res=HIWORD(ret);
   if(res) return(true);

   int atm = LOWORD(ret);
   if(atm != 0)
     {
      int buf[255];
      int cnt=GlobalGetAtomNameW(atm,buf,255*4);
      GlobalDeleteAtom(atm);

      string str=MakeStr(buf,cnt);
      Alert("[SetItem] "+str);
     }

   return(false);
  }
//-----------------------------------------------------------------------------

int LOWORD(int val)
  {
   return((val>>16)  &0xFFFF);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int HIWORD(int val)
  {
   return(val  &0xFFFF);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string MakeStr(int &buf[],int cnt)
  {
   string str="";
   int ch=-1;

   for(int i=0; i<cnt; i++)
     {
      if(i%4 == 0) ch = buf[i/4] & 0xFF;
      if(i%4 == 1) ch = (buf[i/4] >> 8) & 0xFF;
      if(i%4 == 2) ch = (buf[i/4] >> 16) & 0xFF;
      if(i%4 == 3) ch = (buf[i/4] >> 24) & 0xFF;

      str=str+CharToString((uchar)ch);
     }

   return(str);
  }
//+------------------------------------------------------------------+
