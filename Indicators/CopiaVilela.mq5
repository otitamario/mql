//+------------------------------------------------------------------+
//|                                          Botao indicando preço   |
//|                                                           Ricardo |
//|                                                                   |
//+------------------------------------------------------------------+


#property indicator_chart_window
#property indicator_buffers 0   
#property indicator_plots   0   


string Entrada="Resistência"; 
double preco=98620;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {



 

CriandoTagPreco(clrYellow,Entrada, preco);
     
   


   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
ObjectDelete(0,Entrada);

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {

AtualizaPreco(Entrada, preco);


   return(rates_total);
  }
//+------------------------------------------------------------------+
void CriandoTagPreco(color cor, string botao, double alvo)
{
   ObjectCreate(0,botao,OBJ_BUTTON,0,0,0);
   ObjectSetInteger(0,botao,OBJPROP_CORNER,3); 
   ObjectSetInteger(0,botao,OBJPROP_XDISTANCE,CHART_HEIGHT_IN_PIXELS-5);
   
   int x, y;
   ChartTimePriceToXY(0,0,0,alvo,x,y);
   ObjectSetInteger(0,botao,OBJPROP_YDISTANCE,y); 


   ObjectSetInteger(0,botao,OBJPROP_XSIZE,100); 
   ObjectSetInteger(0,botao,OBJPROP_YSIZE,14); 
   ObjectSetInteger(0,botao,OBJPROP_READONLY,true); 
   ObjectSetInteger(0,botao,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,botao,OBJPROP_BACK,false);
   ObjectSetInteger(0,botao,OBJPROP_FONTSIZE,8);       
   
   ObjectSetInteger(0,botao,OBJPROP_BGCOLOR,cor);    
   ObjectSetInteger(0,botao,OBJPROP_BORDER_COLOR,cor);
   ObjectSetString(0,botao,OBJPROP_TEXT,botao);
  
   

}
void AtualizaPreco(string botao, double alvo)
{
   int x, y;
   ChartTimePriceToXY(0,0,0,alvo,x,y);
   ObjectSetInteger(0,botao,OBJPROP_YDISTANCE,y); 

}
   


 
   

