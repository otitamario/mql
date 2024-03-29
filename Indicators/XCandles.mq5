//+------------------------------------------------------------------+
//|                                                     XCandles.mq5 |
//|                        Copyright 2018, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Baixa
#property indicator_label1  "Retangulos" 
#property indicator_type1   DRAW_NONE 
#property indicator_style1  STYLE_SOLID 
#property indicator_color1  clrRed 
#property indicator_width1  1 
//--- input parameters
input int      candles_baixa=3;
input color CorBaixa=clrMagenta;
input int      candles_alta=3;
input color CorAlta=clrAqua;
//--- indicator buffers
double         InvBuff[];
int  min_rates_total;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   min_rates_total=candles_baixa;

//--- indicator buffers mapping
   SetIndexBuffer(0,InvBuff,INDICATOR_DATA);

//--- shift the beginning of indicator drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);

   ArraySetAsSeries(InvBuff,true);
   ArrayInitialize(InvBuff,0.0);

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   int  apaga=ObjectsDeleteAll(ChartID(),"Retang_Baixa");
   int  apaga2=ObjectsDeleteAll(ChartID(),"Retang_Alta");


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
   int limit,bar;
   bool altas,baixas;
   double candle_high,candle_low;
//---- checking the number of bars to be enough for the calculation
//---- indexing elements in arrays as timeseries  

//---- calculation of the 'first' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total;                 // starting index for calculation of all bars
     }
   else
     {
      limit=rates_total-prev_calculated;                 // starting index for calculation of new bars
     }

   ArraySetAsSeries(open,true);
   ArraySetAsSeries(close,true);
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(high,true);
//---- main indicator calculation loop
   for(bar=limit; bar>=0; bar--)
     {
      baixas=true;

      for(int k=bar;k<bar+candles_baixa;k++)
        {
         baixas=baixas && (iOpen(Symbol(),_Period,k)>iClose(Symbol(),_Period,k));
        }

      if(baixas)
        {
         candle_high=Maior_Alta(bar+candles_baixa-1);

         candle_low=Menor_Baixa(bar+candles_baixa-1);
         RectangleCreate(0,"Retang_Baixa"+IntegerToString(bar),0,iTime(Symbol(),_Period,bar+candles_baixa-1),candle_high,iTime(Symbol(),_Period,bar),candle_low,CorBaixa,
                         STYLE_SOLID,1,false,false,true,true,0);
        }

      altas=true;

      for(int k=bar;k<bar+candles_alta;k++)
        {
         altas=altas && (iOpen(Symbol(),_Period,k)<iClose(Symbol(),_Period,k));
        }

      if(altas)
        {
         candle_high=Maior_Alta(bar+candles_alta-1);

         candle_low=Menor_Baixa(bar+candles_alta-1);
         RectangleCreate(0,"Retang_Alta"+IntegerToString(bar),0,iTime(Symbol(),_Period,bar+candles_alta-1),candle_high,iTime(Symbol(),_Period,bar),candle_low,CorAlta,
                         STYLE_SOLID,1,false,false,true,true,0);
        }

     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
double HighestHigh(string pSymbol,ENUM_TIMEFRAMES pPeriod,int pBars,int pStart=0)
  {
   double vetor[];
   ArraySetAsSeries(vetor,true);

   int copied= CopyHigh(pSymbol,pPeriod,pStart,pBars,vetor);
   if(copied == -1) return(copied);

   int maxIdx=ArrayMaximum(vetor);
   double highest=vetor[maxIdx];

   return(highest);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double LowestLow(string pSymbol,ENUM_TIMEFRAMES pPeriod,int pBars,int pStart=0)
  {
   double vetor[];
   ArraySetAsSeries(vetor,true);

   int copied= CopyLow(pSymbol,pPeriod,pStart,pBars,vetor);
   if(copied == -1) return(copied);

   int minIdx=ArrayMinimum(vetor);
   double lowest=vetor[minIdx];

   return(lowest);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+ 
//| Criar retângulo pelas coordenadas fornecidas                     | 
//+------------------------------------------------------------------+ 
bool RectangleCreate(const long            chart_ID=0,        // ID do gráfico 
                     const string          name="Rectangle",  // nome do retângulo 
                     const int             sub_window=0,      // índice da sub-janela 
                     datetime              time1=0,           // primeiro ponto de tempo 
                     double                price1=0,          // primeiro ponto de preço 
                     datetime              time2=0,           // segundo ponto de tempo 
                     double                price2=0,          // segundo ponto de preço 
                     const color           clr=clrRed,        // cor do retângulo 
                     const ENUM_LINE_STYLE style=STYLE_SOLID, // estilo das linhas do retângulo 
                     const int             width=1,           // largura das linhas do retângulo 
                     const bool            fill=false,        // preenchimento do retângulo com cor 
                     const bool            back=false,        // no fundo 
                     const bool            selection=true,    // destaque para mover 
                     const bool            hidden=true,       // ocultar na lista de objetos 
                     const long            z_order=0)         // prioridade para clique do mouse 
  {
//--- definir coordenadas de pontos de ancoragem, se eles não estão definidos 
   ChangeRectangleEmptyPoints(time1,price1,time2,price2);
//--- redefine o valor de erro 
   ResetLastError();
//--- criar um retângulo pelas coordenadas dadas 
   if(!ObjectCreate(chart_ID,name,OBJ_RECTANGLE,sub_window,time1,price1,time2,price2))
     {
      Print(__FUNCTION__,
            ": falha ao criar um retângulo! Código de erro = ",GetLastError());
      return(false);
     }
//--- definir a cor do retângulo 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- definir o estilo de linhas do retângulo 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- definir a largura das linhas do retângulo 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- habilitar (true) ou desabilitar (false) o modo de preenchimento do retângulo 
   ObjectSetInteger(chart_ID,name,OBJPROP_FILL,fill);
//--- exibir em primeiro plano (false) ou fundo (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- habilitar (true) ou desabilitar (false) o modo de destaque para mover o retângulo 
//--- ao criar um objeto gráfico usando a função ObjectCreate, o objeto não pode ser 
//--- destacado e movimentado por padrão. Dentro deste método, o parâmetro de seleção 
//--- é verdade por padrão, tornando possível destacar e mover o objeto 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- ocultar (true) ou exibir (false) o nome do objeto gráfico na lista de objeto  
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- definir a prioridade para receber o evento com um clique do mouse no gráfico 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- sucesso na execução 
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ChangeRectangleEmptyPoints(datetime &time1,double &price1,
                                datetime &time2,double &price2)
  {
//--- se o tempo do primeiro ponto não está definido, será na barra atual 
   if(!time1)
      time1=TimeCurrent();
//--- se o preço do primeiro ponto não está definido, ele terá valor Bid 
   if(!price1)
      price1=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- se o tempo do segundo ponto não está definido, está localizado a 9 barras deixadas a partir da segunda 
   if(!time2)
     {
      //--- array para receber o tempo de abertura das últimos 10 barras 
      datetime temp[10];
      CopyTime(Symbol(),Period(),time1,10,temp);
      //--- definir o segundo ponto 9 barras a esquerda do primeiro 
      time2=temp[0];
     }
//--- se o preço do primeiro ponto não está definido, mover 300 pontos a mais do que o segundo 
   if(!price2)
      price2=price1-300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
  }  
//+------------------------------------------------------------------+
double Maior_Alta(const int nc)
  {
   double n_high;
   int idx=iHighest(Symbol(),PERIOD_CURRENT,MODE_HIGH,nc,1);
   n_high=iHigh(Symbol(),PERIOD_CURRENT,idx);
   return n_high;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double Menor_Baixa(const int nc)
  {
   double n_low;
   int idx=iLowest(Symbol(),PERIOD_CURRENT,MODE_LOW,nc,1);
   n_low=iLow(Symbol(),PERIOD_CURRENT,idx);
   return n_low;
  }

//+------------------------------------------------------------------+
