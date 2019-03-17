//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
enum UsarDemo
  {
   Sim,//Somente Demo
   Nao//Uso Livre
  };
#include <Bcrypt.mqh>
CBcrypt B;

input datetime validade=D'2100.12.31 23:59:59';//Data de validade
input int conta=9011600;//Conta
input UsarDemo usardemo=Sim;//Liberar Somente Demo
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string keystr="1233727cc760ccb228259500df1ae1fd";
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()

//+------------------------------------------------------------------+

  {

   string txt=IntegerToString(conta)+"_"+TimeToString(validade,TIME_DATE|TIME_SECONDS)+"_"+EnumToString(usardemo);
   B.SetData(txt);
   B.Init(keystr,NULL,txt);
   string senha=B.Encrypt();
   Print("Encrypt= ",senha);
   Alert(senha);

   return INIT_SUCCEEDED;

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
