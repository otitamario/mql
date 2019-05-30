
#property copyright   "2019, MX Scalper"


  // * * * * * * * *  mx scalper


#property version   "1.00"

#property indicator_chart_window
#property indicator_buffers 10   
#property indicator_plots   4   

#property indicator_label1  "Venda Short"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrOrangeRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Compra Short"
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


enum LT {
   HORA,            //LT Hora
   HORA2,            //LT 2 Horas
   DIARIO,        // LT Diária
   SEMANAL,    // LT Semanal
};

//--- input 
input    bool   UsarLTMacro=true; //Usar Filtro de Linhas de tendência Macro?
input LT PrazoLT=DIARIO; // Selecione o prazo para as LTA e LTB
input    short Pontos=10; //Variação minima entre extremos dos candles anteriores
input    double Percentual=50;//% do candle anterior para validar rompimento
input    bool     ExibirInformacoes=false; //Exibir informações na aba Expert?
double         Venda_Buffer[];
double         Compra_Buffer[];
double         Short_Buffer[];
double         Rompimento_Buffer[];




double         SentidoOperacao=0;
double preco=0;
  double MaxAnt[4];
  datetime  T_MaxAnt[4];
  double MinAnt[4];
  datetime  T_MinAnt[4];
  double Open[3];
  double Close[3];
  double precoLTmacro=0;
  int   direcaoMacro=0;

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

   PlotIndexSetInteger(0,PLOT_ARROW,234);          PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-20);
   PlotIndexSetInteger(1,PLOT_ARROW,233);          PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,20);

   _ChartID=ChartID();

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {

  ObjectDelete(_ChartID,"LTB");
  ObjectDelete(_ChartID,"LTA");
  ObjectDelete(_ChartID,"Short");
  
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

  bool isnewbar=false;

   if(prev_calculated==0)
     {
      ArrayInitialize(Compra_Buffer,EMPTY_VALUE);
      ArrayInitialize(Venda_Buffer,EMPTY_VALUE);
      }


   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
     

   for(int i=MathMax(2,prev_calculated-1); i<rates_total;i++)
     {
    
  if((PrazoLT==SEMANAL && WeekNum(time[i])!=WeekNum(time[i-1]))||(PrazoLT==DIARIO && time[i]/86400!=time[i-1]/86400)||(PrazoLT==HORA && time[i]/3600!=time[i-1]/3600)||(PrazoLT==HORA2 && time[i]/7200!=time[i-1]/7200)) //604800 = 60*60*24*7 (Segundos na semana)
  {
  ObjectDelete(_ChartID,"LTB");
  ObjectDelete(_ChartID,"LTA");
  direcaoMacro=0; //Futuramente preciso pesquisar se tenho uma LTA ou uma LTB - Aqui vai zerar as variáveis

  
  
  Close[1]=Close[0];
  Close[0]=close[i-1];
  
string LinhaMacro;

if(PrazoLT==0)LinhaMacro="LT Hora"; else if(PrazoLT==1)LinhaMacro="LT 2 Horas"; else if(PrazoLT==2)LinhaMacro="LT Diária";else LinhaMacro="LT Semanal";
if(ExibirInformacoes) Print("A Linha macro escolhida foi: ", LinhaMacro, ". OPEN: ", Open[0],", CLOSE: ",Close[0]);
  
  
  if(Close[0]<Open[0] && MaxAnt[0]<MaxAnt[1])
  {
  TrendCreate(_ChartID,"LTB",0,T_MaxAnt[1],MaxAnt[1],T_MaxAnt[0],MaxAnt[0],clrRed,STYLE_SOLID,3);//,DBack,DSelection,DRayLeft,DRayRight,DHidden,DZOrder);
if(ExibirInformacoes) Print("A LTB foi traçada de: ",MaxAnt[1],"(",T_MaxAnt[1],") até ",MaxAnt[0],"(",T_MaxAnt[0],")");
   direcaoMacro=-1;
  
  }
  if(Close[0]>Open[0] && MinAnt[0]>MinAnt[1])
  {
  TrendCreate(_ChartID,"LTA",0,T_MinAnt[1],MinAnt[1],T_MinAnt[0],MinAnt[0],clrBlue,STYLE_SOLID,3);//,DBack,DSelection,DRayLeft,DRayRight,DHidden,DZOrder);
if(ExibirInformacoes) Print("A LTA foi traçada de: ",MinAnt[1],"(",T_MinAnt[1],") até ",MinAnt[0],"(",T_MinAnt[0],")");
  direcaoMacro=1;
  }
  
  Open[1]=Open[0];
  Open[0]=open[i];
  
  

MaxAnt[2]=MaxAnt[1];
MaxAnt[1]=MaxAnt[0];
MaxAnt[0]=0;

T_MaxAnt[2]=T_MaxAnt[1];
T_MaxAnt[1]=T_MaxAnt[0];
T_MaxAnt[0]=0;


MinAnt[2]=MinAnt[1];
MinAnt[1]=MinAnt[0];
MinAnt[0]=0;

T_MinAnt[2]=T_MinAnt[1];
T_MinAnt[1]=T_MinAnt[0];
T_MinAnt[0]=0;


  }
  
  if(high[i]>MaxAnt[0]){MaxAnt[0]=high[i]; T_MaxAnt[0]=time[i];}  
  if(low[i]<MinAnt[0] || MinAnt[0]==0){MinAnt[0]=low[i]; T_MinAnt[0]=time[i];}  
    
     
  if(time[i]/1!=time[i-1]/1) { //Analisando abertura de cada candle
  
  ObjectDelete(_ChartID,"Short");
  
  isnewbar=true;
  SentidoOperacao=0;
   preco=0;
   precoLTmacro=0;

   
   ArrayInitialize(Short_Buffer,EMPTY_VALUE);
   ArrayInitialize(Rompimento_Buffer,EMPTY_VALUE);
   
   

double rompimento=(high[i-1]-low[i-1])*Percentual/100;

if((UsarLTMacro==true && direcaoMacro==1)||UsarLTMacro==false)
{
if(close[i-1]>open[i-1] && low[i-1]-Pontos>low[i-2] ){
TrendCreate(_ChartID,"Short",0,time[i-2],low[i-2],time[i-1],low[i-1],clrAqua,STYLE_DASH,2);

SentidoOperacao=1;
preco=low[i-1]+(low[i-1]-low[i-2]);
Short_Buffer[i-2]=low[i-2]; Short_Buffer[i-1]=low[i-1]; Short_Buffer[i]=low[i-1]+(low[i-1]-low[i-2]);
Rompimento_Buffer[i-2]=Rompimento_Buffer[i-1]=Rompimento_Buffer[i]=close[i-1]-rompimento;
}
}
if((UsarLTMacro==true && direcaoMacro==-1)||UsarLTMacro==false)
{
if (close[i-1]<open[i-1] && high[i-1]+Pontos<high[i-2]){
TrendCreate(_ChartID,"Short",0,time[i-2],high[i-2],time[i-1],high[i-1],clrPurple,STYLE_DASH,2);
//ChartRedraw();


SentidoOperacao=-1;
preco=high[i-1]-(high[i-2]-high[i-1]);
Short_Buffer[i-2]=high[i-2]; Short_Buffer[i-1]=high[i-1]; Short_Buffer[i]=high[i-1]-(high[i-2]-high[i-1]);
Rompimento_Buffer[i-2]=Rompimento_Buffer[i-1]=Rompimento_Buffer[i]=close[i-1]+rompimento;

}
}


  
  
}
else isnewbar=false;


     
if(isnewbar==true)
{
}




if(SentidoOperacao==1 && /*close[i]>preco && preco!=0 && */close[i]<Rompimento_Buffer[i]) Compra_Buffer[i]=low[i]; else Compra_Buffer[i]=EMPTY_VALUE;
if(SentidoOperacao==-1 && /*close[i]<preco && */close[i]>Rompimento_Buffer[i]) Venda_Buffer[i]=high[i]; else Venda_Buffer[i]=EMPTY_VALUE;


     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
long WeekNum(datetime aTime,bool aStartsOnMonday=false)
  {
//--- if the week starts on Sunday, add the duration of 4 days (Wednesday+Tuesday+Monday+Sunday),
//    if it starts on Monday, add 3 days (Wednesday, Tuesday, Monday)
   if(aStartsOnMonday)
     {
      aTime+=259200; // duration of three days (86400*3)
     }
   else
     {
      aTime+=345600; // duration of four days (86400*4)  
     }
   return(aTime/604800);
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