//+------------------------------------------------------------------+
//|                                                   SinalAmaok.mq5 |
//|                                          Junior Cesar 01-12-2017 |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#include <Auxiliares.mqh>
#property copyright "Junior Cesar 01-12-2017"
#property link      "https://www.mql5.com"
#property version   "1.00"


enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2  // Heiken ashi trend biased (extreme) price
};


//Media 1
input string MEDIA_1="######MEDIA RAPIDA#####"; 
input int                AMA_PeriodMA1                  =7;          // Adaptive Moving Average(10,...) Period of averaging
input int                AMA_PeriodFast1                =5;           // Adaptive Moving Average(10,...) Period of fast EMA
input int                AMA_PeriodSlow1                =30;          // Adaptive Moving Average(10,...) Period of slow EMA
input int                AMA_Shift1                     =0;           // Adaptive Moving Average(10,...) Time shift
input ENUM_APPLIED_PRICE Applied_Price_MA_1            =PRICE_MEDIAN; // Adaptive Moving Average(10,...) Prices series

//media 2
input string MEDIA_2="######MEDIA LENTA#####"; 
input int                AMA_PeriodMA2                  =10;          // Adaptive Moving Average(10,...) Period of averaging
input int                AMA_PeriodFast2                =6;           // Adaptive Moving Average(10,...) Period of fast EMA
input int                AMA_PeriodSlow2                =70;          // Adaptive Moving Average(10,...) Period of slow EMA
input int                AMA_Shift2                     =0;           // Adaptive Moving Average(10,...) Time shift
input ENUM_APPLIED_PRICE Applied_Price_MA_2            =PRICE_MEDIAN; // Adaptive Moving Average(10,...) Prices series
//Controle da distância do candle da média rápida
input int      distancia=300;
//Para calculo do último cruzamento
input bool Usar_Laguerre_RSI=false;//Usar Laguerre RSI
//------------Laguerre RSI----------------------------------------------------
input double   RsiGamma             = 0.50;  // Laguerre RSI gamma
input enPrices RsiPrice             = 4;     // Price
input double   RsiSmoothGamma       = 0.001; // Laguerre RSI smooth gamma
input int      RsiSmoothSpeed       = 2;     // Laguerre RSI smooth speed (min 0, max 6)
input double   FilterGamma          = 0.60;  // Laguerre filter gamma
input int      FilterSpeed          = 2;     // Laguerre filter speed (min 0, max 6)
input double   LevelUp              = 0.85;  // Level up
input double   LevelDown            = 0.15;  // Level down
input bool     NoTradeZoneVisible   = true;  // Display no trade zone?
input double   NoTradeZoneUp        = 0.65;  // No trade zone up
input double   NoTradeZoneDown      = 0.35;  // No trade zone down
//--------------------------------------------------------------------------------------


double last_open,last_high,last_low,last_close;

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_plots 4

//--- plot Venda
#property indicator_label1  "Venda"
#property indicator_type1   DRAW_ARROW
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- plot Compra
#property indicator_label2  "Compra"
#property indicator_type2   DRAW_ARROW
#property indicator_color2  clrMediumBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//--- plot AMA1
#property indicator_label3  "AMA1"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
//--- plot AMA2
#property indicator_label4  "AMA2"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrYellow
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
//--- input parameters

//--- indicator buffers
double         VendaBuffer[];
double         CompraBuffer[];
double         AMA1Buffer[];
double         AMA2Buffer[];
double Laguerre_Buffer[],RSI_Buffer[];
int AMA1Handle,AMA2Handle,Lag_RSI_Handle;
CCandle LastCandleCompra=new CCandle;
CCandle LastCandleVenda=new CCandle;
string last_signal;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
  
  last_signal="";
  //Declarar variável par usar no último cruzamento das médias compra
  last_open=0;
  last_high=0;
  last_low=0;
  last_close=0;
//--- indicator buffers mapping
   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,AMA1Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,AMA2Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,RSI_Buffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,Laguerre_Buffer,INDICATOR_CALCULATIONS);
//--- setting a code from the Wingdings charset as the property of PLOT_ARROW
   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);
   ArrayInitialize(CompraBuffer,0.0);
   ArrayInitialize(VendaBuffer,0.0);
   AMA1Handle=iAMA(NULL,0,AMA_PeriodMA1,AMA_PeriodFast1,AMA_PeriodSlow1,AMA_Shift1,Applied_Price_MA_1);
   AMA2Handle=iAMA(NULL,0,AMA_PeriodMA2,AMA_PeriodFast2,AMA_PeriodSlow2,AMA_Shift2,Applied_Price_MA_2);
   Lag_RSI_Handle=iCustom(NULL,0,"Laguerre_RSI_with_Laguerre_filter",RsiGamma,RsiPrice,RsiSmoothGamma,RsiSmoothSpeed,FilterGamma,FilterSpeed,LevelUp,LevelDown,NoTradeZoneVisible,NoTradeZoneUp,NoTradeZoneDown);
  if(Usar_Laguerre_RSI) ChartIndicatorAdd(ChartID(),1,Lag_RSI_Handle);

     





//---
   return(INIT_SUCCEEDED);
  }
  
  
 void OnDeinit(const int reason)
  {
//---
  if(Usar_Laguerre_RSI)ChartIndicatorDelete(ChartID(),1,"Laguerre RSI with Laguerre filter("+(string)RsiGamma+","+(string)FilterGamma+")");
  } 
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
  
   
//---
   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
   CopyBuffer(AMA1Handle,0,0,to_copy,AMA1Buffer);
   CopyBuffer(AMA2Handle,0,0,to_copy,AMA2Buffer);
   CopyBuffer(Lag_RSI_Handle,2,0,to_copy,RSI_Buffer);
   CopyBuffer(Lag_RSI_Handle,3,0,to_copy,Laguerre_Buffer);   
   //Escrever condição e lógica para o indicador 
   for(int i=MathMax(3,prev_calculated-1); i<rates_total; i++)
   
    {
    RSI_Buffer[i]=NormalizeDouble(RSI_Buffer[i],1);
    Laguerre_Buffer[i]=NormalizeDouble(Laguerre_Buffer[i],1);
     // Cria um loop para achar qual foi a última indicação de compra ou venda
        //Pegando o ultimo candle COmpra/Venda
    if(CompraBuffer[i-1]>0)
   {
   last_signal="COMPRA";
   LastCandleCompra.Open(open[i-1]);
   LastCandleCompra.High(high[i-1]);
   LastCandleCompra.Low(low[i-1]);
   LastCandleCompra.Close(close[i-1]);
   LastCandleCompra.Bull();//Bull é pra saber se o candle é de alta ou baixa. True o candle é de alta
   LastCandleCompra.BodySize();//Corpo ou Tamanho Do Candle
   }
   if(VendaBuffer[i-1]>0)
   {
   last_signal="VENDA";
   LastCandleVenda.Open(open[i-1]);
   LastCandleVenda.High(high[i-1]);
   LastCandleVenda.Low(low[i-1]);
   LastCandleVenda.Close(close[i-1]);
   LastCandleVenda.Bull();
   LastCandleCompra.BodySize();
   }
   //-------------------------------------------
    
    //COndicao assim:
   // if (last_signal=="COMPRA")//Coloca em qualquer parte que tu quiser ou diferente !=
    
        // Condição para copiar os dados para memória no cruzamento das médias, para compra
  if ( AMA1Buffer[i-1]<AMA2Buffer[i-1] && AMA1Buffer[i]>AMA2Buffer[i])
  { last_open=open[i];last_close=close[i];last_high=high[i];last_low=low[i];}
  
   
    
    //Condição para compra
  
      if((
      
          //Retorno a média
          //(AMA1Buffer[i-1]>AMA2Buffer[i-1]
          //&& low[i-1]>AMA1Buffer[i-1] && low[i]<AMA1Buffer[i] && AMA1Buffer[i-1]-AMA2Buffer[i-1]>distancia-200)
          // Cruzamento do RSI
        // Cruzamento de média simples confere se é menor que a compra do candle antes
            (AMA1Buffer[i-1]<AMA2Buffer[i-1] && AMA1Buffer[i]>AMA2Buffer[i] && low[i]<LastCandleCompra.clow)
        // Cruzamento do RSI com laguerre e o último sinal ser venda
     ||(  RSI_Buffer[i-1]<=Laguerre_Buffer[i-1] && LastCandleVenda.clow>high[i] && open[i]<close[i]   
        && RSI_Buffer[i]>Laguerre_Buffer[i] && RSI_Buffer[i-1]<0.19 && AMA1Buffer[i-1]<AMA2Buffer[i-1] && last_signal=="VENDA" )
          // Cruzamento Laguerre 0,2 para cima, a venda tem que ser acima da vermelha e compra abaixo
        || (Laguerre_Buffer[i-1]<=0.18 && Laguerre_Buffer[i]>0.18 
        && LastCandleVenda.chigh>AMA1Buffer[i-1] && low[i-1]<AMA1Buffer[i-1] && last_signal=="VENDA" )
         //teste 2 cruzamento laguerre acima da vermelha
         || (Laguerre_Buffer[i-1]<=0.17 && Laguerre_Buffer[i]>0.17  )
         // Laguerre cruza para cima 0,9
         || (Laguerre_Buffer[i-1]<=0.85 && Laguerre_Buffer[i]>0.85  )
         
          // CRuzamento RSI para cima do 0,9 acima da média vermelha
    ||(RSI_Buffer[i-1]<=0.8  && RSI_Buffer[i]>0.8 && Laguerre_Buffer[i-1]<0.7  )
    ||(RSI_Buffer[i-1]<=0.8  && RSI_Buffer[i]>0.8 && AMA1Buffer[i-1]>low[i-1] && Laguerre_Buffer[i-1]<0.7 
    && LastCandleCompra.cclose<low[i] )
    //CRuza rsi para cima e ultimo candle for venda
    ||(RSI_Buffer[i-1]<=0.8  && RSI_Buffer[i]>0.8 && AMA1Buffer[i-1]<low[i-1]
    && last_signal=="VENDA" )
         // Cruzamento do RSI acima de 0,2 abaixo da vermelha e abaixo do último sinal de venda
         || (RSI_Buffer[i-1]<=0.18  && RSI_Buffer[i]>0.18 && AMA1Buffer[i-1]>high[i-1] && last_signal=="VENDA" 
         && LastCandleVenda.clow>high[i]  )
         
         // Cruzamento do RSI acima de 0,2 abaixo da vermelha e abaixo do último sinal de compra e do candle de compra
         || (RSI_Buffer[i-1]<=0.18  && RSI_Buffer[i]>0.18 && AMA1Buffer[i-1]>high[i-1] && last_signal=="COMPRA" 
         && LastCandleCompra.clow>low[i]  )
     // CRuza 0,8 para cima Acompanhamento de tendência com possível reversão, usar reversão de pivot na venda
         || ( RSI_Buffer[i-1]<=0.8 && RSI_Buffer[i]>0.8 && AMA1Buffer[i-1]>AMA2Buffer[i-1] && LastCandleVenda.chigh>open[i] 
         && Laguerre_Buffer[i-1]<0.7 && LastCandleCompra.cclose<low[i] )
      // Cruza o laguerre 0,19 para cima e a venda está acima dele
      || (Laguerre_Buffer[i-1]<=0.19 && Laguerre_Buffer[i]>0.19 && LastCandleVenda.clow>high[i] 
     && high[i-1]<AMA1Buffer[i-1] && last_signal=="VENDA" && RSI_Buffer[i-1]>0.20)
       
         // RSI cruza 0,2 para cima com média já cruzada
        || (  RSI_Buffer[i-1]<0.18 && RSI_Buffer[i]>0.18 && AMA1Buffer[i-1]<open[i-1] )
         // RSI cruza 0,2 para Cima 1 candles anteriores e o candle de venda ser maior que o atual e o último sinal tem que ser venda
       //- || ( RSI_Buffer[i-1]<=0.19 && RSI_Buffer[i]>0.19 && AMA1Buffer[i-1]<AMA2Buffer[i-1]
       //- && LastCandleVenda.chigh>low[i] && last_signal=="VENDA" )
         // RSI cruza 0,2 para Cima 1 candle anteriore
         || ( RSI_Buffer[i-1]<=0.19 && RSI_Buffer[i]>0.19 && AMA1Buffer[i-1]>AMA2Buffer[i-1] && LastCandleVenda.clow>low[i]
         && LastCandleVenda.chigh>AMA1Buffer[i-1] && low[i-1]<AMA1Buffer[i-1] )
         // RSI cruza 0,2 para Cima 1 candle anterior e Cruza a vermelha junto
         || ( RSI_Buffer[i-1]<=0.19 && RSI_Buffer[i]>0.19 && AMA1Buffer[i-1]>low[i-1] 
         &&  high[i]>AMA1Buffer[i] )
         // Distante de um certo valor da média depois de um pivot de alta
         //|| ( AMA1Buffer[i-1]<AMA2Buffer[i-1] && (high[i-1]+low[i-1])/2>(AMA1Buffer[i-1]+distancia)
          //&& low[i-2]>low[i-1] && RSI_Buffer[i-1]<0.2 && Laguerre_Buffer[i-1]<0.3 ) 
          // Compra quando RSI estiver perto de zero
         //|| ( low[i-2]>low[i-1] && RSI_Buffer[i]<0.1 && AMA1Buffer[i-1]<low[i-1] && Laguerre_Buffer[i-1]<0.4 )
         // Se o trade não andar 3 candles depois da venda ele compra e o candle atual ser de compra
      || (LastCandleVenda.chigh<high[i] && high[i-3]==LastCandleVenda.chigh && low[i-3]==LastCandleVenda.clow 
        && open[i]<close[i] && high[i]>high[i-2] && RSI_Buffer[i-1]>0 )
         || (LastCandleVenda.chigh<high[i] && high[i-3]==LastCandleVenda.chigh && low[i-3]==LastCandleVenda.clow 
          && low[i]>LastCandleVenda.chigh && RSI_Buffer[i-1]>0 )
         || (LastCandleVenda.chigh<high[i] && high[i-3]==LastCandleVenda.chigh && low[i-3]==LastCandleVenda.clow 
         && RSI_Buffer[i-1]<0.7 && open[i]<close[i] && high[i]>high[i-2] && RSI_Buffer[i-1]>0 )
         // Se o trade não andar e o última venda for igual a ultimo sinal de vena e fazer pivot de alta
         || (LastCandleVenda.chigh<high[i] && last_signal=="VENDA" && high[i-1]<AMA1Buffer[i-1]  
        && low[i-1]>LastCandleVenda.clow  )
       
         // Duplicar a compra se a abertura do candle atual for maior que a máxima da compra anterior
      //|| (LastCandleCompra.chigh<open[i] && AMA1Buffer[i-1]<low[i-1] && RSI_Buffer[i-1]>0.8 && low[i]>LastCandleCompra.chigh )
         
         
          
          //CRuzamento de média mas o preço tem que ser menor que um determinado valor e o segundo cruzamento não pode romper o fechamento do primeiro candle
        //|| (AMA1Buffer[i-1]<AMA2Buffer[i-1] 
        // && AMA1Buffer[i]>AMA2Buffer[i] && low[i]-AMA1Buffer[i]<distancia && last_low<close[i] && last_close !=0 )
          // o candle anterior cruza as duas médias de baixo para cima
         // || (low[i-1]<AMA2Buffer[i-1] && high[i-1]>AMA1Buffer[i-1] 
         // && AMA2Buffer[i-1]<AMA1Buffer[i-1] && close[i-2]<AMA2Buffer[i-2])
          // Quando a distância do candle da média for maior que um determinado valor
        //  || ( AMA1Buffer[i-1]<AMA2Buffer[i-1] && AMA1Buffer[i-1]-close[i-1]>distancia && close[i-2]<close[i-1] 
        //  && open[i-2]>close[i-2] && low[i-1]<low[i-2] && close[i]>close[i-1] )
          // Distância do Candle 2
        // || (AMA1Buffer[i-1]<AMA2Buffer[i-1] && AMA1Buffer[i-1]-close[i-1]>distancia && low[i-2]>low[i-1] 
        //  && low[i-1]<low[i] && high[i-1]-low[i-1]>5*(open[i-1]-close[i-1]))
          //Um candle cruza as duas médias 
        //  || (AMA1Buffer[i-1]<AMA2Buffer[i-1] && high[i-1]>AMA2Buffer[i-1] && low[i-1]>AMA1Buffer[i-1] 
         // && high[i]>AMA2Buffer[i] && low[i]<AMA1Buffer[i] && open[i-1]<AMA2Buffer[i-1])
             
          // Comprar quando o preço rompe as duas médias e não volta
        //  || ( low[i-2]<AMA1Buffer[i-2] && AMA1Buffer[i-2]<AMA2Buffer[i-2] && close[i-1]>AMA2Buffer[i-1]  )
         
          // Comprar quando o candle anterior romper a indicação de venda
         
        //  || (AMA1Buffer[i-1]<AMA2Buffer[i-1] && LastCandleCompra.cclose>0 && LastCandleVenda.chigh<high[i-1] 
        //  && low[i-1]<AMA2Buffer[i-1] && close[i-1]>AMA1Buffer[i-1]  )
          // Comprar quando o preço fizer bull back acima da venda e romper
       //   || (AMA1Buffer[i-1]>AMA2Buffer[i-1] && LastCandleCompra.cclose>0 && LastCandleVenda.chigh<high[i-1] 
        //  && low[i-1]<LastCandleVenda.chigh && high[i]>high[i-1] )
          // Retorno a média amarela depois de  passar pela vermelha
          
          // Exemplo de Condicao Ultimo Candle Compra: (LastCandleCompra.cclose>0 && close[i]>=LastCandleCompra.chigh && low[i]>=LastCandleCompra.clow)
          //Ind ependente da Condicao que colocar sempre coloque && LastCandleCompra.cclose>0 pois antes da primeira rodada close=high=low=open=0
          // So quando fizer a primeira compra que ele atualiza aí os valores vao ser>0
          // Para usar as informções tem que usar:
          //LastCandleCompra.cclose ,LastCandleCompra.chigh,LastCandleCompra.clow,LastCandleCompra.copen
          //LastCandleCompra.bull // Esse é booleano true se for candle de alta
          //LastCandleCompra.cbodysize
          // De mandeira Equivalente pode fazer as mesmas coisas com o candle de venda
          // Para usar no final //&& RSI_Buffer[i-3]<0.2 //&& RSI_Buffer[i]>=0.2
             )&& RSI_Buffer[i]<1.0 && low[i-1]>AMA1Buffer[i] //antes era open[i] && RSI_Buffer[i]<1
          
          )
          
         {
         CompraBuffer[i]=low[i]-20;
         }
       else
         {
          CompraBuffer[i]=0;
         }
         // Condição para Venda original 
         
   if( // Cruzamento de média com verificação da venda anterior
               ((AMA1Buffer[i-1]>AMA2Buffer[i-1] && AMA1Buffer[i]<AMA2Buffer[i]&& low[i]>LastCandleVenda.clow && LastCandleCompra.chigh<open[i])
        // Cruzamento do RSI
       ||(  RSI_Buffer[i-1]>=Laguerre_Buffer[i-1]
          && RSI_Buffer[i]<Laguerre_Buffer[i] && RSI_Buffer[i-1]>0.9 && AMA1Buffer[i-1]>AMA2Buffer[i-1]
          && low[i]>AMA1Buffer[i] && open[i-1]>LastCandleCompra.copen && last_signal=="COMPRA" && LastCandleCompra.chigh<low[i] )
          //Cruzamento rsi
         // ||(  RSI_Buffer[i-1]>=Laguerre_Buffer[i-1]
         // && RSI_Buffer[i]<Laguerre_Buffer[i] && RSI_Buffer[i-1]>0.85) 
         // Vende se o sinal anterior for de compra e ficar 2 candle abaixo da minima do candle último candle de compra
         ||(last_signal=="COMPRA" && LastCandleCompra.clow>low[i-1] && LastCandleCompra.clow>low[i] && low[i]<LastCandleVenda.chigh ) 
            
        // RSI cruza laguerre 0,9 para baixo
        || (  RSI_Buffer[i-1]>=Laguerre_Buffer[i-1] && low[i]>AMA1Buffer[i] && low[i]>AMA2Buffer[i]
          && RSI_Buffer[i]<Laguerre_Buffer[i] && RSI_Buffer[i-1]>0.9 && AMA1Buffer[i-1]>AMA2Buffer[i-1] && AMA1Buffer[i]>open[i] )
         // RSI cruza 0,9 para baixo 2 candles anteriores
         //*|| ( RSI_Buffer[i-2]>=0.9 && RSI_Buffer[i]<0.9 && AMA1Buffer[i-1]>AMA2Buffer[i-1] && low[i]>AMA1Buffer[i])
         // RSI cruza 0,9 para baixo 1 candles anteriores
        || ( RSI_Buffer[i-1]>=0.85 && RSI_Buffer[i]<0.85  && last_signal=="COMPRA")
        // RSI cruza 0,2 para baixo 1 candles anteriores e anterior é compra
        || ( RSI_Buffer[i-1]>=0.19 && RSI_Buffer[i]<0.19  && last_signal=="COMPRA")
        // RSI cruza 0,2 para baixo 1 candles anteriores e anterior é venda
        || ( RSI_Buffer[i-1]>=0.19 && RSI_Buffer[i]<0.19  && last_signal=="VENDA")
         // RSI cruza 0,9 para baixo tendência de baixa
        || ( RSI_Buffer[i-1]>=0.85 && RSI_Buffer[i]<0.85 && AMA1Buffer[i-1]<AMA2Buffer[i-1] && low[i]>AMA1Buffer[i] )
         // Distante de um certo valor da média depois de um pivot de baixa
        //* || ( AMA1Buffer[i-1]>AMA2Buffer[i-1] && (high[i-1]+low[i-1])/2>(AMA1Buffer[i-1]+distancia)
        //* && high[i-2]<high[i-1] && low[i]<low[i-3]  && RSI_Buffer[i-1]>0.9 && Laguerre_Buffer[i-1]>0.7 )
         //pivot acima da vermelha com RSI acima de 0,8 e Laguerre acima de 0,7 e se romper o fundo da compra com RSI abaixo de 0,9
         || (Laguerre_Buffer[i-1]>0.7 && high[i-1]>LastCandleCompra.clow && low[i]<LastCandleCompra.clow
         && RSI_Buffer[i]<0.9 && RSI_Buffer[i-2]>0.9 )
            // Acompanhamento de tendência com possível reversão, usar reversão de pivot na compra
        || ( RSI_Buffer[i-1]>=0.2 && RSI_Buffer[i]<0.2 && AMA1Buffer[i-1]<AMA2Buffer[i-1] && high[i]<AMA1Buffer[i] )
        //Laguerre cruza para baixo 0,18 abaixo da vermelha
        ||(AMA1Buffer[i-1]>low[i-1] && Laguerre_Buffer[i-1]>0.19 && Laguerre_Buffer[i]<0.19 && low[i-1]>AMA2Buffer[i-1]) 
         // CRuzamento do Laguere no 0,9
         || ( Laguerre_Buffer[i-1]>=0.85 && Laguerre_Buffer[i]<0.85 && AMA1Buffer[i-1]>AMA2Buffer[i-1] 
         && low[i]>LastCandleCompra.chigh && last_signal=="COMPRA")
         // ou 0,85
       //*  || ( Laguerre_Buffer[i-1]>=0.85 && Laguerre_Buffer[i]<0.85 && AMA1Buffer[i-1]<AMA2Buffer[i-1] && low[i]>AMA2Buffer[i])
         // Se o trade não andar 3 candles depois da compra ele vende
         || (LastCandleCompra.clow>low[i] && low[i-3]==LastCandleCompra.clow && high[i-3]==LastCandleCompra.chigh 
         && Laguerre_Buffer[i-1]<0.7 && open[i]>close[i] && high[i]<=LastCandleCompra.chigh )
         //Pivot acima de 0.9
       //*  ||(AMA1Buffer[i-1]>AMA2Buffer[i-1] && RSI_Buffer[i-1]>0.9 && high[i-3]<high[i-2]<high[i-1] && RSI_Buffer[i-2]>0.9 
       //*  && high[i-1]>high[i] && Laguerre_Buffer[i-1]<0.9 )
         // Rompimento do Pivot de continuação de baixa, candle abaixo do sinal de compra
        // || (LastCandleCompra.clow>low[i] && high[i-1]>high[i]  )
       
      // || (close[i-1]-AMA1Buffer[i-1]>distancia && high[i-3]<high[i-2] && high[i-2]>high[1]
      // && low[i-3]>low[i-2] && high[i-3]>high[i] )
       // Retorno a média vemelha não pode passar a amarela
      // || (high[i-3]<AMA1Buffer[i-3] && high[i-2]<AMA1Buffer[i-2] 
      // && high[i-1]<AMA1Buffer[i-1] && high[i]>AMA1Buffer[i] && AMA1Buffer[i-1]<AMA2Buffer[i-1]
      // && AMA2Buffer[i-1]>=AMA2Buffer[i] && high[i]<AMA2Buffer[i] )
       // Vender quando retorna para a amarela e não ultrapassa
      // || ( high[i-2]>AMA1Buffer[i-2] && AMA1Buffer[i-2]>AMA2Buffer[i-2] && close[i-1]<AMA2Buffer[i-1] )
       // Entrada após rompimento de duas médias
      // || (low[i-2]>AMA1Buffer[i-2] && AMA1Buffer[i-2]>AMA2Buffer[i-2] && high[i-1]>AMA1Buffer[i-1]
     //  && low[i-1]<AMA2Buffer[i-1] )
       // Vender quando formar pivot de baixa acima o candle que deu compra e  abaixo das médias
      // || (AMA1Buffer[i-1]<AMA2Buffer[i-1] && LastCandleCompra.cclose>0 && LastCandleCompra.clow<low[i-1] && high[i-1]<AMA1Buffer[i-1]
      // && high[i-3]<high[i-2] && high[i-2]>high[i] && low[i-2]>low[i-1] )
       // Vender quando romper o candle que deu compra e abaixo das médias 
      // || (AMA1Buffer[i-1]<AMA2Buffer[i-1] && LastCandleCompra.cclose>0 && LastCandleCompra.clow>low[i-1] && high[i-1]<AMA1Buffer[i-1]
      // &&  high[i-2]>high[i] && low[i-1]<AMA1Buffer[i-1] && close[i-1]<open[i] && close[i-1]>close[i-2] )
       // Cruzamento para baixo e última compra acima das médias
      // || (AMA2Buffer[i-1]>AMA1Buffer[i-1] && LastCandleCompra.cclose>0 && LastCandleCompra.cclose>AMA2Buffer[i-1] && open[i]>AMA1Buffer[i]
       // && close[i]<AMA1Buffer[i] )
        // Quando está em congestão na média vermelha e tem um rompimento para baixo
      //  || (AMA1Buffer[i-1]<AMA2Buffer[i-1] && LastCandleCompra.cclose>0 && LastCandleCompra.copen>AMA1Buffer[i-1] 
      //  && high[i-1]>AMA1Buffer[i-1] && open[i]<AMA1Buffer[i]  )
       // Rompimento de Pivot de baixa acima de um certo valor da média
      //  || ( AMA1Buffer[i-2]>AMA2Buffer[i-2] && low[i]<low[i-1] && (high[i-2]-AMA1Buffer[i-2] )>distancia && low[i-3]<low[i-2] && high[i-2]>high[i-3]  )
      // || AMA1Buffer[i-1]<AMA2Buffer[i-1] && AMA2Buffer[i-1]-AMA1Buffer[i-1]<100
               ) && RSI_Buffer[i-1]>0.1 && open[i]<AMA1Buffer[i]
      
      
      )
         {
         VendaBuffer[i]=high[i]+20;
         }
       else
         {
          VendaBuffer[i]=0;
         }
   }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//VendaBuffer[i]=AMA2Buffer[i]>AMA1Buffer[i] high[i] : 0;
// Uma possibilidade com o duningan if(AMA1Buffer[i-1]>AMA2Buffer[i-1] && low[i-1]<AMA1Buffer[i-1] && high[i]<high[i-1])



