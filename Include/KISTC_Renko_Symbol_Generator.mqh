//+------------------------------------------------------------------+
//|                                  HPCS_Renko_Symbol_Generator.mqh |
//|                        Copyright 2011-2018, HPC Sphere Pvt. Ltd. |
//|                                         http://www.hpcsphere.com |
//+------------------------------------------------------------------+
#property link      "http://www.hpcsphere.com"
#property copyright "Copyright 2011-2018, HPC Sphere Pvt. Ltd. India."
#property version   "1.00"

string gs_Symbol = Symbol();
//string gs_currSymbol;
string arr_Split[];

#define _KISTC_RENKO_SYMBOL func_generateSymbol()

void func_generateSymbol()
{
   //gs_currSymbol = Symbol();
   if(StringFind(Symbol(),"RN_")>=0)
   {
      ushort sep = StringGetCharacter("_",0);
      int k = StringSplit(Symbol(),sep,arr_Split);
      gs_Symbol = arr_Split[1];
      
      #define _Symbol func_NewSymbol()
      //#define Symbol() gs_currSymbol
      //#define _symbol gs_currSymbol
   }
}

string func_NewSymbol()
{
   return gs_Symbol;
}







