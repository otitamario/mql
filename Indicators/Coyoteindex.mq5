
#property copyright   "2019, White Trader - Programmer && Developer"
#property link "https://www.mql5.com/pt/users/rycke.br"
//#property icon "\\Indicators\\WT_Programmer&&Developer\\logo_bot.ico"



#property version   "5.00"


datetime TmpDataValidade=D'2099.05.10 00:00';   // Definir aqui a data de validade




#property indicator_chart_window
#property indicator_buffers 4   //4
#property indicator_plots   4   //3

#property indicator_label1  "Venda"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Compra"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDarkTurquoise
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "Short"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrChartreuse
#property indicator_style3  STYLE_SOLID
#property indicator_width3  3

#property indicator_label4  "Rompimento"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrYellow
#property indicator_style4  STYLE_DASH
#property indicator_width4  2

//--- input parameters
input    double Pontos=10; //Variação minima entre extremos dos candles anteriores
input    bool     ModoAgressivo=true; //Modo Agressivo
input    bool     UsarCandleAtual=false; //Usar Candle Atual?
input    double Percentual=50;//% de retração (Modo Agressivo = false)
input    bool     ExibirRaio=false; //Exibir Raio?

double         Venda_Buffer[];
double         Compra_Buffer[];
double         Short_Buffer[];
double         Rompimento_Buffer[];

double         SentidoOperacao=0;
double preco=0;


long           _ChartID;

string MeuSimbolo = _Symbol; // Guardando O Papel do gráfico para não consultar diversas vezes
ENUM_TIMEFRAMES MeuTimeFrame = PERIOD_CURRENT; // Guardando o período para não consultar diversas 

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {





   SetIndexBuffer(0,Venda_Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,Compra_Buffer,INDICATOR_DATA);   
   SetIndexBuffer(2,Short_Buffer,INDICATOR_DATA);   
   SetIndexBuffer(3,Rompimento_Buffer,INDICATOR_DATA);   
   

   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);

   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-20);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,20);
   
   _ChartID=ChartID();

//int Max=60;
   

   
//(Manipulador_Signal=iCustom(NULL,_Period,"Market\\BoxInside MT5"));
//Manipulador_Filter=iMA(MeuSimbolo,MeuTimeFrame,Periodo_Filter,0,MODE_SMA,PRICE_CLOSE);

  // ulong newChartID=ChartOpen(MeuSimbolo,PERIOD_H1);
  // ChartIndicatorAdd(newChartID,0,Manipulador_Signal);
  // Print((int)UsarCandleAtual);
   
Comment("");

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
if(ExibirRaio)
{
  ObjectDelete(_ChartID,"Short");
}

   // ObjectsDeleteAll(_ChartID,0,OBJ_TREND);
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
   //ArraySetAsSeries(time,true);

//buffer 3 = MediumBox
/*
   datetime TimeNewBar[1];
   CopyTime(MeuSimbolo,PERIOD_H1,0,1,TimeNewBar);
   datetime tnewbar=TimeNewBar[0];

   bool isnewbar=tnewbar!=tlastbar;

   tlastbar=tnewbar;
  */
  bool isnewbar=false;

   if(prev_calculated==0)
     {
      ArrayInitialize(Compra_Buffer,EMPTY_VALUE);
      ArrayInitialize(Venda_Buffer,EMPTY_VALUE);
      //ArraySetAsSeries(Signal_Buffer,false);
      }


   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
     
      //int copy=CopyBuffer(Manipulador_Signal,6,0,to_copy,VAH_Buffer);
       //int copy2=CopyBuffer(Manipulador_Signal,7,0,to_copy,VAL_Buffer);
    

   //CopyBuffer(Manipulador_Filter,0,0,to_copy,Filter_Buffer);
   //ArraySetAsSeries(time,true);
   for(int i=MathMax(2,prev_calculated-1); i<rates_total;i++)
     {
     
  if(time[i]/1!=time[i-1]/1) {
  isnewbar=true;
  SentidoOperacao=0;
   preco=0;
   ArrayInitialize(Short_Buffer,EMPTY_VALUE);
   ArrayInitialize(Rompimento_Buffer,EMPTY_VALUE);
if(ExibirRaio)  ObjectDelete(_ChartID,"Short");
   

double rompimento=(high[i-1]-low[i-1])*Percentual/100;
  
if(close[i-(int)UsarCandleAtual]>open[i-(int)UsarCandleAtual] && low[i-(int)UsarCandleAtual]-Pontos>low[i-1-(int)UsarCandleAtual] ){
if(ExibirRaio && i+5>rates_total) TrendCreate(_ChartID,"Short",0,time[i-1-(int)UsarCandleAtual],low[i-1-(int)UsarCandleAtual],time[i-(int)UsarCandleAtual],low[i-(int)UsarCandleAtual],clrAqua,STYLE_DASH,2);
SentidoOperacao=1;
preco=low[i-(int)UsarCandleAtual]+(low[i-(int)UsarCandleAtual]-low[i-1-(int)UsarCandleAtual]);
Short_Buffer[i-1-(int)UsarCandleAtual]=low[i-1-(int)UsarCandleAtual]; Short_Buffer[i-(int)UsarCandleAtual]=low[i-(int)UsarCandleAtual]; Short_Buffer[i]=low[i-(int)UsarCandleAtual]+(low[i-(int)UsarCandleAtual]-low[i-1-(int)UsarCandleAtual]);
Rompimento_Buffer[i-1-(int)UsarCandleAtual]=Rompimento_Buffer[i-(int)UsarCandleAtual]=Rompimento_Buffer[i]=close[i-(int)UsarCandleAtual]-rompimento;
}
else if (close[i-(int)UsarCandleAtual]<open[i-(int)UsarCandleAtual] && high[i-(int)UsarCandleAtual]+Pontos<high[i-1-(int)UsarCandleAtual]){
if(ExibirRaio && i+5>rates_total) TrendCreate(_ChartID,"Short",0,time[i-1-(int)UsarCandleAtual],high[i-1-(int)UsarCandleAtual],time[i-(int)UsarCandleAtual],high[i-(int)UsarCandleAtual],clrPurple,STYLE_DASH,2);

SentidoOperacao=-1;
preco=high[i-(int)UsarCandleAtual]-(high[i-1-(int)UsarCandleAtual]-high[i-(int)UsarCandleAtual]);
Short_Buffer[i-1-(int)UsarCandleAtual]=high[i-1-(int)UsarCandleAtual]; Short_Buffer[i-(int)UsarCandleAtual]=high[i-(int)UsarCandleAtual]; Short_Buffer[i]=high[i-(int)UsarCandleAtual]-(high[i-1-(int)UsarCandleAtual]-high[i-(int)UsarCandleAtual]);
Rompimento_Buffer[i-1-(int)UsarCandleAtual]=Rompimento_Buffer[i-(int)UsarCandleAtual]=Rompimento_Buffer[i]=close[i-(int)UsarCandleAtual]+rompimento;

}

//ObjectSetInteger(_ChartID,(string)time[i-1],OBJPROP_RAY_RIGHT,1);
  
  
}

if(!ModoAgressivo)
{
if(SentidoOperacao==1 && close[i]<Rompimento_Buffer[i]) Compra_Buffer[i]=low[i]; else Compra_Buffer[i]=EMPTY_VALUE;
if(SentidoOperacao==-1 && close[i]>Rompimento_Buffer[i]) Venda_Buffer[i]=high[i]; else Venda_Buffer[i]=EMPTY_VALUE;
}
else
{
if(SentidoOperacao==1 && close[i]>open[i]) Compra_Buffer[i]=low[i]; else Compra_Buffer[i]=EMPTY_VALUE;
if(SentidoOperacao==-1 && close[i]<open[i]) Venda_Buffer[i]=high[i]; else Venda_Buffer[i]=EMPTY_VALUE;
Rompimento_Buffer[i-2]=Rompimento_Buffer[i-1]=Rompimento_Buffer[i]=EMPTY_VALUE;

}


     }

   //Comment(PERIOD_H1);
   return(rates_total);
  }
//+------------------------------------------------------------------+
bool TrendCreate(const long            chart_ID=0,        // ID графика 
                 const string          name="",  // имя линии 
                 const int             sub_window=0,      // номер подокна 
                 datetime              time1=0,           // время первой точки 
                 double                price1=0,          // цена первой точки 
                 datetime              time2=0,           // время второй точки 
                 double                price2=0,          // цена второй точки 
                 const color           clr=clrRed,        // цвет линии 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // стиль линии 
                 const int             width=1)           // толщина линии 

  {

   ObjectDelete(chart_ID,name);

   if(!ObjectCreate(chart_ID,name,OBJ_TREND,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": Não foi possível criar a linha de tendência devido ao erro = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr); 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style); 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_LEFT,false);
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,true);
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,true);
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,0);
   return(true);
  }  