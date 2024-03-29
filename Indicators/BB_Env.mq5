#property copyright   "2019, White Trader - Programmer && Developer"
#property link      "https://www.mql5.com/pt/users/rycke.br"
#property icon "\\Indicators\\WT_Programmer&&Developer\\logo_bot.ico"


datetime TmpDataValidade=D'2099.06.15 00:00';  // Data de validade  // Indicador em teste



#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   8

#property indicator_label1  "Venda"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Compra"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrDodgerBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

#property indicator_label3  "[BB] Superior"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDeepSkyBlue

#property indicator_label4  "[Env] Superior"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrOrangeRed
#property indicator_style4  STYLE_SOLID



#property indicator_label5  "[BB] Centro"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDeepSkyBlue

#property indicator_label6  "[Env] Centro"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrOrangeRed


#property indicator_label7  "[BB] Inferior"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrDeepSkyBlue


#property indicator_label8  "[Env] Inferior"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrOrangeRed

input int     BandsPeriod=20;       // [BB] Período
/*input*/ int     BandsShift=0;         // [BB] Deslocar
input double  BandsDeviations=2.0;  // [BB] Desvios

input int     EnvPeriod=40;       // [Env] Período
/*input*/ int     EnvShift=0;         // [Env] Deslocar
input double  EnvDeviations=100;  // [Env] Desvio em Pontos

input ENUM_APPLIED_PRICE Preco=PRICE_CLOSE; // Preço
input ENUM_MA_METHOD Metodo=MODE_EMA; //Método de cálculo

input bool OcultarMedias=true; //Ocultar Média Central?

double         VendaBuffer[];
double         CompraBuffer[];

double         BB_UpperBuffer[];
double         Env_UpperBuffer[];

double         BB_CenterBuffer[];
double         Env_CenterBuffer[];

double         BB_LowerBuffer[];
double         Env_LowerBuffer[];




int bb,env;
//+------------------------------------------------------------------+
int OnInit()
  {
  
  
    Comment("");
     if(/*(AccountInfoString(ACCOUNT_NAME)!="Tester" && AccountInfoString(ACCOUNT_NAME)!=Nome1 && AccountInfoString(ACCOUNT_NAME)!=Nome2) ||*/TimeCurrent() > TmpDataValidade )
   {
   Print("Acesso  não autorizado para: ",(string)AccountInfoString(ACCOUNT_NAME));
   Comment("Contate o desenvolvedor do indicador");
   Print("Contate o desenvolvedor do indicador");
   PlotIndexSetInteger(0,PLOT_SHOW_DATA,false);
   PlotIndexSetInteger(1,PLOT_SHOW_DATA,false);
   return (-1);
   return (INIT_FAILED);
   }

   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);

   SetIndexBuffer(2,BB_UpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,Env_UpperBuffer,INDICATOR_DATA);
   
   SetIndexBuffer(4,BB_CenterBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,Env_CenterBuffer,INDICATOR_DATA);
   
   SetIndexBuffer(6,BB_LowerBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,Env_LowerBuffer,INDICATOR_DATA);

// Usa setas.
// Apenas visual, não faz dferença operacional
   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);

// Afasta um pouco as setas do gráfico.
// Apenas visual, não faz dferença operacional
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);
   


   bb=iBands(_Symbol,_Period,BandsPeriod,BandsShift,BandsDeviations,Preco);
   if(bb==INVALID_HANDLE)
     {
      Alert("Erro ao inicializar o indicador de Banda: ",GetLastError());
      return INIT_FAILED;
     }

   env=iMA(_Symbol,_Period,EnvPeriod,EnvShift,Metodo,Preco);
   if(env==INVALID_HANDLE)
     {
      Alert("Erro ao inicializar o indicador de Envelope: ",GetLastError());
      return INIT_FAILED;
     }

if(OcultarMedias==true)
{
PlotIndexSetInteger(4,PLOT_DRAW_TYPE,DRAW_NONE);
PlotIndexSetInteger(5,PLOT_DRAW_TYPE,DRAW_NONE);
PlotIndexSetInteger(4,PLOT_SHOW_DATA,false);
PlotIndexSetInteger(5,PLOT_SHOW_DATA,false);

}

   return INIT_SUCCEEDED;
  }
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
   int start=MathMax(0,prev_calculated-1);
   int count=rates_total-start;

   if(prev_calculated==0)
     {
      ArrayInitialize(VendaBuffer,EMPTY_VALUE);
      ArrayInitialize(CompraBuffer,EMPTY_VALUE);
      }


   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }

   if(prev_calculated<rates_total) 
   {
   CopyBuffer(bb,0,0,to_copy,BB_CenterBuffer);
   CopyBuffer(bb,1,0,to_copy,BB_UpperBuffer);
   CopyBuffer(bb,2,0,to_copy,BB_LowerBuffer);
   CopyBuffer(env,0,0,to_copy,Env_CenterBuffer);
   
   }

// Quantos candles para trás seu indicador analisa?
   int backstep=MathMax(BandsPeriod,EnvPeriod);

   for(int i=MathMax(backstep,prev_calculated-1); i<rates_total;i++)
     {
     Env_UpperBuffer[i]=Env_CenterBuffer[i]+EnvDeviations;
     Env_LowerBuffer[i]=Env_CenterBuffer[i]-EnvDeviations;
     
      // Vende quando fecha acima das duas bandas.
      VendaBuffer[i]=close[i]>Env_UpperBuffer[i] && close[i-1]<=Env_UpperBuffer[i-1] && Env_UpperBuffer[i]>BB_UpperBuffer[i] ? high[i]: EMPTY_VALUE;

      // Compra quando fecha abaixo das duas bandas
      CompraBuffer[i]= close[i]<Env_LowerBuffer[i] && close[i-1]>=Env_LowerBuffer[i-1] && Env_LowerBuffer[i]<BB_LowerBuffer[i]? low[i]: EMPTY_VALUE;
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

