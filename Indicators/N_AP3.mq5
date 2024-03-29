//+------------------------------------------------------------------+
//|                                         Novo_Apocalipse     |
//|                                 Super_Gain                            |
//|                                               |
//+------------------------------------------------------------------+
#property copyright "Super_Gain"
#property link      "Super_Gain"
#property version   "100.00"




#property indicator_chart_window
#property indicator_buffers 4   //4
#property indicator_plots   3   //3

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

input int PeriodoMedia=55; // Periodo Da Média de Entrada
input int AfastamentoMedia=650; // Afastamento para entrada
input int DesvioEntrada = 100; // Distância extra para colocação de ordens
input int ValidadeOrdem = 5; // Duraçao em candles do sinal de entrada
input ENUM_TIMEFRAMES TimeMedia=PERIOD_M20;//TIMEFRAME do média de entrada

double         VendaBuffer[]; // Seta (Sinal) de Venda
double         CompraBuffer[]; // Seta (Sinal) de Compra
double         MediaBuffer[]; // Media Multiframe



int ManipuladorMedia;
double   Media_variavel=EMPTY_VALUE; // Guardar o valor da Média do candle anterior no time frame maior

int   Contagem_Candles=0;
bool  autorizaoperacao = true; // Se expirar a contagem de candles muda para falso

double preco_aux=EMPTY_VALUE; // VAi guardar o preço de encerramento do candle Multi Frame
double precocompra=0;
double precovenda=0;

//MqlDateTime Data;

string MeuSimbolo = _Symbol; // Guardando O Papel do gráfico para não consultar diversas vezes
ENUM_TIMEFRAMES MeuTimeFrame = PERIOD_CURRENT; // Guardando o período para não consultar diversas 
 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   SetIndexBuffer(0,VendaBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,CompraBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,MediaBuffer,INDICATOR_CALCULATIONS);
   
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,PeriodoMedia-1);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,PeriodoMedia-1);
   PlotIndexSetInteger(2,PLOT_DRAW_BEGIN,PeriodoMedia-1);

   PlotIndexSetInteger(0,PLOT_ARROW,234);
   PlotIndexSetInteger(1,PLOT_ARROW,233);

   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,-10);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,10);


   ManipuladorMedia=iMA(MeuSimbolo,TimeMedia,PeriodoMedia,0,MODE_SMA,PRICE_CLOSE);

   ulong newChartID=ChartOpen(MeuSimbolo,TimeMedia);
   ChartIndicatorAdd(newChartID,0,ManipuladorMedia);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(ManipuladorMedia);
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

   int to_copy;
   if(prev_calculated>rates_total || prev_calculated<0) to_copy=rates_total;
   else
     {
      to_copy=rates_total-prev_calculated;
      if(prev_calculated>0) to_copy++;
     }
   CopyBuffer(ManipuladorMedia,0,0,to_copy,MediaBuffer);



   for(int i=MathMax(4,prev_calculated-1); i<rates_total && !IsStopped();i++)
     {
     
               //+------------------------------------------------------------------+
               //|Zerar contagem de candles no início da manhã                       |
               //+------------------------------------------------------------------+
           //TimeToStruct(TimeCurrent(), Data);
           //if(Data.hour==9 && Data.min < 15)
           //{
           //Contagem_Candles=0;
           //} 
               //+------------------------------------------------------------------+

               //+------------------------------------------------------------------+
               //|Atualizar valor da média multi frame                    |
               //+------------------------------------------------------------------+
     if (Media_variavel != NormalizeDouble(MediaBuffer[i-1],0)) //Atualiza os valores quando atualizar a Média Multi Frame
     {
     ObjectDelete(ChartID(),"Media MTF"); //Deleta a linha da média para redesenhar com novo valor
     Media_variavel = NormalizeDouble(MediaBuffer[i-1],0); // Obtém o novo valor da média
     Contagem_Candles=0;
     autorizaoperacao = true;
     preco_aux = iClose(MeuSimbolo,TimeMedia,1);
     ObjectCreate(ChartID(),"Media MTF",OBJ_HLINE,0,0,Media_variavel,0);
     ObjectSetInteger(ChartID(),"Media MTF",OBJPROP_COLOR,clrBrown);
     
      precocompra=0;
      precovenda=0;
      ObjectDelete(ChartID(),"Gatilho Venda");
      ObjectDelete(ChartID(),"Gatilho Compra");

     
     }
               //+------------------------------------------------------------------+

            CompraBuffer[i]=VendaBuffer[i]=0; 
            
if (MathAbs(Media_variavel-preco_aux) > AfastamentoMedia) // Se o afastamento ocorreu na abertura do candle
{

   if(preco_aux > Media_variavel)
         {
               precovenda = preco_aux+DesvioEntrada; // Autoriza Venda acima de precovenda
               ObjectCreate(ChartID(),"Gatilho Venda",OBJ_HLINE,0,0,precovenda);
               ObjectSetInteger(ChartID(),"Gatilho Venda",OBJPROP_COLOR,clrYellow);
         }               

   if(Media_variavel>preco_aux)
         {
               precocompra = preco_aux-DesvioEntrada;  // Autoriza Combra abaixo de precocompra
               ObjectCreate(ChartID(),"Gatilho Compra",OBJ_HLINE,0,0,precocompra);
               ObjectSetInteger(ChartID(),"Gatilho Compra",OBJPROP_COLOR,clrCornflowerBlue);
         }
               Contagem_Candles=i;

               
}  

           
               //+------------------------------------------------------------------+
               //|Verificar se deve emitir sinal ou zerar a autorização             |
               //+------------------------------------------------------------------+
                     if(i - Contagem_Candles > ValidadeOrdem)
                     {
                     
                     //ObjectDelete(0,"Gatilho");
                     
                     
                     
                     precocompra=0;
                     precovenda=0;
                     Contagem_Candles=0;
                     autorizaoperacao = false;
                     ObjectDelete(ChartID(),"Gatilho Venda");
                     ObjectDelete(ChartID(),"Gatilho Compra");
                     //ObjectDelete(ChartID(),"Media MTF");

                     } // fim do if(Contagem_Candles - i < - ValidadeOrdem)
 
      

                 if(Contagem_Candles != 0 && autorizaoperacao == true) // Está autorizando OPERAÇÃO
                   {
               //+------------------------------------------------------------------+
               //|Emissão da ordem (seta)  de VENDA                                |
               //+------------------------------------------------------------------+      
                        if(high[i-1]>=precovenda && precovenda!=0 && low[i]<precovenda )
                        {
                           VendaBuffer[i]=high[i];
                           VendaBuffer[i-1]=EMPTY_VALUE; // EMPTY_VALUE 0
                           precovenda=0;
                           Contagem_Candles=0;
                        }
                         else
                        {VendaBuffer[i]=0; }
                        
               //+------------------------------------------------------------------+
               //|Emissão da ordem (seta)  de COMPRA                                |
               //+------------------------------------------------------------------+      
                        if(low[i-1]<=precocompra && high[i]>precocompra  )
                        {
                           CompraBuffer[i]=low[i];
                           CompraBuffer[i-1]=EMPTY_VALUE; //EMPTY_VALUE 0
                           precocompra=0;
                           Contagem_Candles=0;
                        }
                        else{CompraBuffer[i]=0;}                        
                        
                        
                  } // fim do se estiver autorizado OPERAÇÃO
                  
   
     } //Fim do for

   return(rates_total);
  }
//+------------------------------------------------------------------+

