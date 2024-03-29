//+------------------------------------------------------------------+
//|                                         Novo_Apocalipse     |
//|                                 Super_Gain                            |
//|                                               |
//+------------------------------------------------------------------+
#property copyright "Super_Gain"
#property link      "Super_Gain"
#property version   "100.00"


//datetime TmpDataValidade=D'2020.12.31 00:00';  // Data de validade do robô  //ano.mes.dia


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



input int PeriodoMedia=1000; // Periodo Da Média de Entrada
input int AfastamentoMedia=1250; // Afastamento para entrada
input double OffsetFixo=600; //Distância Fixa
input double Arredondamento=0;// Para efeitos de arredonadamento


double         VendaBuffer[]; // Seta (Sinal) de Venda
double         CompraBuffer[]; // Seta (Sinal) de Compra
double         MediaBuffer[]; // Media Multiframe


double y_preco1 = 5350;
double y_preco2 = 6760;
datetime  x_tempo1=StringToTime("2018.10.03 09:00:00");
datetime  x_tempo2=StringToTime("2018.10.23 09:00:00");
datetime AcompanhaTempo;
double m=(y_preco2-y_preco1)/(x_tempo2-x_tempo1);


int ManipuladorMedia;
double   Media_variavel=EMPTY_VALUE; // Guardar o valor da Média do candle anterior no time frame maior


double precocompra=0;
double precovenda=0;

//MqlDateTime Data;

string MeuSimbolo = _Symbol; // Guardando O Papel do gráfico para não consultar diversas vezes
ENUM_TIMEFRAMES MeuTimeFrame = PERIOD_CURRENT; // Guardando o período para não consultar diversas 
input ENUM_TIMEFRAMES TimeMedia=PERIOD_CURRENT;//TIMEFRAME do média de entrada

 
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
  
    // if(TimeCurrent() > TmpDataValidade)return INIT_FAILED;

  
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


   ManipuladorMedia=iMA(MeuSimbolo,PERIOD_CURRENT,PeriodoMedia,0,MODE_SMA,PRICE_CLOSE);


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
     
         
         
  double principal = int((m*(time[i]-x_tempo1)+y_preco1)/5)*5;
 // double RestoEquacao, RestoPreco;
 // RestoEquacao = int(NormalizeDouble(fmod(principal,OffsetFixo),0)/5)*5;
  //RestoEquacao = int(RestoEquacao/10)*10;
 // RestoPreco =int(fmod(close[i],OffsetFixo)/5)*5;
  //double Diferenca=fabs(RestoPreco - RestoEquacao);
  int Multiplo=(int)NormalizeDouble(((close[i]-principal)/OffsetFixo),0);
         
         
         
         
         
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
     ObjectCreate(ChartID(),"Media MTF",OBJ_HLINE,0,0,Media_variavel,0);
     ObjectSetInteger(ChartID(),"Media MTF",OBJPROP_COLOR,clrBrown);
     
      precocompra=0;
      precovenda=0;
      ObjectDelete(ChartID(),"Gatilho Venda");
      ObjectDelete(ChartID(),"Gatilho Compra");

               precovenda = Media_variavel + AfastamentoMedia; // Autoriza Venda acima de precovenda
               ObjectCreate(ChartID(),"Gatilho Venda",OBJ_HLINE,0,0,precovenda);
               ObjectSetInteger(ChartID(),"Gatilho Venda",OBJPROP_COLOR,clrYellow);
         }               

  // if(Media_variavel>preco_aux)
         {
               precocompra = Media_variavel - AfastamentoMedia;  // Autoriza Combra abaixo de precocompra
               ObjectCreate(ChartID(),"Gatilho Compra",OBJ_HLINE,0,0,precocompra);
               ObjectSetInteger(ChartID(),"Gatilho Compra",OBJPROP_COLOR,clrCornflowerBlue);


     
     }
               //+------------------------------------------------------------------+

            //CompraBuffer[i]=VendaBuffer[i]=0; 
            


           
               //+------------------------------------------------------------------+
               //|Verificar se deve emitir sinal ou zerar a autorização             |
               //+------------------------------------------------------------------+

      

                   
                   
      if((low[i]<=principal+(Multiplo*OffsetFixo)-Arredondamento && high[i]>=principal+(Multiplo*OffsetFixo)-Arredondamento))
{                   
                   
               //+------------------------------------------------------------------+
               //|Emissão da ordem (seta)  de VENDA                                |
               //+------------------------------------------------------------------+      
                        if(high[i]>=precovenda && precovenda!=0)
                        {
                           VendaBuffer[i]=high[i];
                           precovenda=0;
                        }
                         //else
                        //{VendaBuffer[i]=0; }
                        
               //+------------------------------------------------------------------+
               //|Emissão da ordem (seta)  de COMPRA                                |
               //+------------------------------------------------------------------+      
                        if(low[i]<=precocompra)
                        {
                           CompraBuffer[i]=low[i];
                           precocompra=0;
                        }
                       // else{CompraBuffer[i]=0;}                        
}                  
   
     } //Fim do for

   return(rates_total);
  }
//+------------------------------------------------------------------+

