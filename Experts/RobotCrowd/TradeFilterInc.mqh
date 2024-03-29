//+------------------------------------------------------------------+
//|                                    Biblioteca TradeFilterInc.mqh |
//|                                                Antonio Guglielmi |
//|             RobotCrowd - Crowdsourcing para trading automatizado |
//|                                    https://www.robotcrowd.com.br |
//|                                                                  |
//+------------------------------------------------------------------+
//   Copyright 2017 Antonio Guglielmi - RobotCrowd
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.
   

/* Modo de funcionamento dos filtros */
enum filterModeType {
   FILTER_BOTH,        // Compra e Venda
   FILTER_BUY,         // Apenas Compra
   FILTER_SELL         // Apenas Venda
};

/* Barra a ser usada no calculo dos filtros */
enum filterBarType {
   FILTER_BAR_LAST,    // Barra anterior
   FILTER_BAR_CURRENT  // Barra atual
};

/* Modo de operacao do filtro IFR */
enum filterRSIMode {
   RSI_MODE_OB_OS,     // Sobrecompra/venda
   RSI_MODE_STRENGTH   // Forca relativa
};

/* Modo de operacao do filtro WPR */
enum filterWPRMode {
   WPR_MODE_OB_OS,     // Sobrecompra/venda
   WPR_MODE_TREND      // Confirma tendencia
};


/* Modo de operacao do filtro por candles */
enum filterCNDLMode {
   CNDL_MODE_CLOSE_PRO, // Fechamento a favor do trade
   CNDL_MODE_CLOSE_CON, // Fechamento contrario ao trade
   CNDL_MODE_INSIDE_BAR // Inside bar
};

input string              inDescFilter1="===========================";                 // ******* PARAMETROS PARA FILTRAGEM DE TRADES *******
input filterModeType      inFilterMode=FILTER_BOTH;                                    // Modo de operacao dos filtros
input filterBarType       inFilterBar=FILTER_BAR_LAST;                                 // Barra usada na verificacao dos filtros
input bool                inFilterShowIndicators=false;                                // Mostrar indicadores de filtro (apenas mesmo timeframe)
input string              inDescFilCNDL="===========================";                 // ====== Filtro pelos Candles (barras) ======
input bool                inFilCNDLEnable=false;                                       // Habilita Filtro por Candles
input filterCNDLMode      inFilCNDLMode=CNDL_MODE_CLOSE_PRO;                           // -> Tipo de filtro usado
input ENUM_TIMEFRAMES     inFilCNDLTimeFrame=PERIOD_CURRENT;                           // -> Tempo grafico para os candles
input int                 inFilCNDLBars=1;                                             // -> Numero barra anterior para comparacao candles (Zero atual)
input string              inFilCNDLSymbol="";                                          // -> Ativo para comparacao de candles (Se diferente do atual)
input string              inDescFilMA1="===========================";                  // ========= Filtro de Media Movel 1 =========
input bool                inFilMA1Enable=false;                                        // Habilita Filtro de Media Movel 1
input ENUM_TIMEFRAMES     inFilMA1TimeFrame=PERIOD_CURRENT;                            // -> Tempo grafico media movel 1
input int                 inFilMA1Period=20;                                           // -> Periodo media movel 1 (Barras)
input ENUM_MA_METHOD      inFilMA1Type=MODE_SMA;                                       // -> Tipo media movel 1 
input ENUM_APPLIED_PRICE  inFilMA1Price=PRICE_CLOSE;                                   // -> Preco media movel 1
input bool                inFilMA1AboveBelow=false;                                    // -> Observar preco acima/abaixo da media 1
input string              inFilMA1Symbol="";                                           // -> Ativo para calculo da media 1 (Se diferente do atual)
input string              inDescFilMA2="===========================";                  // ========= Filtro de Media Movel 2 =========
input bool                inFilMA2Enable=false;                                        // Habilita Filtro de Media Movel 2
input ENUM_TIMEFRAMES     inFilMA2TimeFrame=PERIOD_CURRENT;                            // -> Tempo grafico media movel 2
input int                 inFilMA2Period=20;                                           // -> Periodo media movel 2 (Barras)
input ENUM_MA_METHOD      inFilMA2Type=MODE_SMA;                                       // -> Tipo media movel 2
input ENUM_APPLIED_PRICE  inFilMA2Price=PRICE_CLOSE;                                   // -> Preco media movel 2
input bool                inFilMA2AboveBelow=false;                                    // -> Observar preco acima/abaixo da media 2
input bool                inFilMA2CompareMA1=false;                                    // -> Apenas com media 2 (rapida) acima/abaixo da media 1 (lenta)
input string              inFilMA2Symbol="";                                           // -> Ativo para calculo da media 2 (Se diferente do atual)
input string              inDescFilADX="===========================";                  // ============= Filtro pelo ADX =============
input bool                inFilADXEnable=false;                                        // Habilita Filtro pelo ADX
input ENUM_TIMEFRAMES     inFilADXTimeFrame=PERIOD_CURRENT;                            // -> Tempo grafico para ADX
input int                 inFilADXPeriod=8;                                            // -> Periodo para ADX
input bool                inFilADXUseMain=false;                                       // -> Usa valor do ADX no filtro
input double              inFilADXMin=20.0;                                            // --> Valor minimo ADX
input string              inDescFilMACD="===========================";                 // ============ Filtro pelo MACD =============
input bool                inFilMACDEnable=false;                                       // Habilita Filtro pelo MACD
input ENUM_TIMEFRAMES     inFilMACDTimeFrame=PERIOD_CURRENT;                           // -> Tempo grafico para MACD
input int                 inFilMACDFastMA=12;                                          // -> Periodo media rapida do MACD
input int                 inFilMACDSlowMA=26;                                          // -> Periodo media lenta do MACD
input int                 inFilMACDSignal=9;                                           // -> Periodo sinal do MACD
input string              inDescFilSAR="===========================";                  // ============ Filtro pelo SAR ==============
input bool                inFilSAREnable=false;                                        // Habilita Filtro pelo SAR
input ENUM_TIMEFRAMES     inFilSARTimeFrame=PERIOD_CURRENT;                            // -> Tempo grafico para o SAR
input double              inFilSARStep=0.02;                                           // -> Valor de passo para o SAR
input double              inFilSARMax=0.2;                                             // -> Valor maximo para o SAR
input string              inDescFilRSI="===========================";                  // ============ Filtro pelo IFR ==============
input bool                inFilRSIEnable=false;                                        // Habilita Filtro pelo IFR
input ENUM_TIMEFRAMES     inFilRSITimeFrame=PERIOD_CURRENT;                            // -> Tempo grafico IFR
input filterRSIMode       inFilRSIMode=RSI_MODE_OB_OS;                                 // -> Modo de operacao IFR
input int                 inFilRSIPeriod=2;                                            // -> Periodo para o IFR
input double              inFilRSIOSLevel=30.0;                                        // -> Nivel de sobrevenda do IFR
input double              inFilRSIOBLevel=70.0;                                        // -> Nivel de sobrecompra do IFR
input string              inDescFilVOL="===========================";                  // ============= Filtro por Volume =============
input bool                inFilVOLEnable=false;                                        // Habilita Filtro pelo Volume
input ENUM_TIMEFRAMES     inFilVOLTimeFrame=PERIOD_CURRENT;                            // -> Tempo grafico para volume
input ENUM_APPLIED_VOLUME inFilVOLType=VOLUME_REAL;                                    // -> Tipo de volume considerado
input int                 inFilVOLCompBars=5;                                          // -> Numero de barras para comparacao de volume
input bool                inFilVOLMean=false;                                          // -> Usar media de volume para comparacao
input int                 inFilVOLMeanPeriod=40;                                       // -> Periodo da media movel do volume
input string              inDescPhibo="===========================";                   // ============ Filtro pelo Phibo ============
input bool                inFilPhiboEnable=false;                                      // Habilita Filtro pelo Phibo
input ENUM_TIMEFRAMES     inFilPhiboTimeFrame=PERIOD_CURRENT;                          // -> Tempo grafico para o Phibo
input bool                inFilPhiboPVPC1=true;                                        // -> Compra/venda apenas acima/abaixo de PC1/PV1
input bool                inFilPhiboPVPC2=true;                                        // -> Compra/venda apenas acima/abaixo de PC2/PV2
input bool                inFilPhiboPVPC3=true;                                        // -> Compra/venda apenas acima/abaixo de PC3/PV3
input string              inDescWPR="===========================";                     // ============ Filtro pelo WPR ============
input bool                inFilWPREnable=false;                                        // Habilita Filtro pelo Williams' Percent Range
input ENUM_TIMEFRAMES     inFilWPRTimeFrame=PERIOD_CURRENT;                            // -> Tempo grafico para o WPR
input filterWPRMode       inFilWPRMode=WPR_MODE_TREND;                                 // -> Modo de operacao do WPR
input int                 inFilWPRPeriod=34;                                           // -> Periodo para calculo do WPR
input double              inFilWPROSLevel=-80;                                         // -> Nivel de sobrevenda do WPR
input double              inFilWPROBLevel=-20;                                         // -> Nivel de sobrecompra do WPR
input string              inDescMT="===========================";                      // ======= Filtro pelo MasterTrend =========
input bool                inFilMTEnable=false;                                         // Habilita Filtro pelo MasterTrend
input ENUM_TIMEFRAMES     inFilMTTimeFrame=PERIOD_CURRENT;                             // -> Tempo grafico para o MasterTrend
input int                 inFilMTCCIPeriod=10;                                         // -> Periodo do CCI para calculo do MasterTrend
input int                 inFilMTATRPeriod=5;                                          // -> Periodo do ATR para calculo do MasterTrend
input double              inFilMTATRRate=1.0;                                          // -> Multiplicador do ATR para calculo do MasterTrend
input int                 inFilMTMAPeriod=40;                                          // -> Periodo Media Movel para calculo do MasterTrend
input bool                inFilMTAboveBelow=false;                                     // -> Filtrar tambem com preco acima/abaixo da linha


class TradeFilter
  {
        
public:
         TradeFilter() { };
        ~TradeFilter() { };

        virtual bool checkBuyFilter() { return(true); };
        virtual bool checkBuyFilter(int bar) { return(true); };
        virtual bool checkSellFilter() { return(true); };
        virtual bool checkSellFilter(int bar) { return(true); };
        virtual void createFilterIndicators() { };
        virtual void releaseFilterIndicators() { };
        virtual bool checkFilterHandles() { return(true); };
        
        virtual void setGlobalFilterParam(filterModeType filterMode, filterBarType filterBar, bool filterShorIndicators) { };
        virtual void setCNDLFilterParam(bool filCNDLEnable, filterCNDLMode filCNDLMode, ENUM_TIMEFRAMES filCNDLTimeFrame, int filCNDLBars, string filCNDLSymbolInput) { };
        virtual void setMA1FilterParam(bool filMA1Enable, ENUM_TIMEFRAMES filMA1TimeFrame, int filMA1Period, ENUM_MA_METHOD filMA1Type, ENUM_APPLIED_PRICE filMA1Price, bool filMA1AboveBelow, string filMA1SymbolInput) { };
        virtual void setMA2FilterParam(bool filMA2Enable, ENUM_TIMEFRAMES filMA2TimeFrame, int filMA2Period, ENUM_MA_METHOD filMA2Type, ENUM_APPLIED_PRICE filMA2Price, bool filMA2AboveBelow, bool filMA2CompareMA1, string filMA2SymbolInput) { };
        virtual void setADXFilterParam(bool filADXEnable, ENUM_TIMEFRAMES filADXTimeFrame, int filADXPeriod, bool filADXUseMain, double filADXMin) { };
        virtual void setMACDFilterParam(bool filMACDEnable, ENUM_TIMEFRAMES filMACDTimeFrame, int filMACDFastMA, int filMACDSlowMA, int filMACDSignal) { };
        virtual void setSARFilterParam(bool filSAREnable, ENUM_TIMEFRAMES filSARTimeFrame, double filSARStep, double filSARMax) { };
        virtual void setRSIFilterParam(bool filRSIEnable, ENUM_TIMEFRAMES filRSITimeFrame, filterRSIMode filRSIMode, int filRSIPeriod, double filRSIOSLevel, double filRSIOBLevel) { };
        virtual void setVOLFilterParam(bool filVOLEnable, ENUM_TIMEFRAMES filVOLTimeFrame, ENUM_APPLIED_VOLUME filVOLType, int filVOLCompBars, bool filVOLMean, int filVOLMeanPeriod) { };
        virtual void setPhiboFilterParam(bool filPhiboEnable, ENUM_TIMEFRAMES filPhiboTimeFrame, bool filPhiboPVPC1, bool filPhiboPVPC2, bool filPhiboPVPC3) { };
        virtual void setWPRFilterParam(bool filWPREnable, ENUM_TIMEFRAMES filWPRTimeFrame, filterWPRMode filWPRMode, int filWPRPeriod, double filWPROSLevel, double filWPROBLevel) { };
        virtual void setMTFilterParam(bool filMTEnable, ENUM_TIMEFRAMES filMTTimeFrame, int filMTCCIPeriod, int filMTATRPeriod, double filMTATRRate, int filMTMAPeriod, bool filMTAboveBelow) { };


  };


