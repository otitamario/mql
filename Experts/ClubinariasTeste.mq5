//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
double Buy[],Sell[];
int indic_club;
int OnInit()
  {

   indic_club=iCustom(_Symbol,PERIOD_CURRENT,"Indicador_Clubinarias_6.0.ex5");
   ChartIndicatorAdd(0,0,indic_club);
   ArraySetAsSeries(Buy,true);
   ArraySetAsSeries(Sell,true);
   return (INIT_SUCCEEDED);

  }
//+------------------------------------------------------------------+
 void OnTick()
 {
 CopyBuffer(
 }