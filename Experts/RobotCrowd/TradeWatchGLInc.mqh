//+------------------------------------------------------------------+
//|                                      Biblioteca TradeWatchGL.mqh |
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



// Enumeracoes
enum tradeDirection {
     NONE,               // Nao usado
     BUY,                // Compra
     SELL                // Venda
};


// Modo de calculo dos stops
enum SLTPType { 
      SL_TP_NONE,        // Definido pelo EA
      SL_TP_AMPLITUDE,   // Amplitude barra entrada
      SL_TP_FIXED,       // Fixo: $ ou pontos
      SL_TP_PERCENT,     // % valor de entrada
      SL_TP_AMP_MIN,     // Amplitude ou valor minimo
      SL_TP_ATR          // Multiplicador do ATR

};

// Tipos de trade aceitos
enum tradeType {
      TRADE_TYPE_BOTH,   // Compra e Venda
      TRADE_TYPE_BUY,    // Apenas Compra
      TRADE_TYPE_SELL    // Apenas Venda
};


// Modo de stop no tempo
enum timeStopCondType {
      TIME_STOP_COND_NONE,     // Sem stop no tempo
      TIME_STOP_COND_ANY,      // Lucro ou prejuizo
      TIME_STOP_COND_PROFIT,   // Apenas com lucro
      TIME_STOP_COND_LOSS      // Apenas com prejuizo
};

// Tipos de manejo de risco
enum riskType {

      RISK_FIXED_LOT,          // Volume fixo
      RISK_PERCENT_BALANCE,    // Percentual de risco no capital
      RISK_CAPITAL_INCREMENT,  // Incremento por passo capital 
      RISK_DEFINED_BY_EA       // Definido pelo EA

};


// Estrutura para armazenamento de ordens pendentes e ordens a mercado ainda nao confirmadas
struct pendingOrderType {

      ulong  ticket;                   // Ticket de uma ordem aberta
      uint   tradeid;                  // Identificador de operacao do robo, que pode ser a mesma para diversas posicoes abertas 
      int    level;                    // Nivel da ordem na logica do gradiente linear
      double price;                    // Preco de execucao
      double volume;                   // Volume da ordem
      double sl;                       // Stop loss
      double tp;                       // Take profit
      bool   tradeDirChange;           // Ordem usada para virada de mao
      bool   market;                   // Ordem a mercado
      bool   positionClose;            // Ordem para fechamento de posicao
      bool   stop;                     // Ordem automatica de stop ou fechamento manual
      tradeDirection tradeDir;         // Tipo de ordem enviada (compra ou venda)
      ENUM_DEAL_ENTRY orderEntryType;  // Tipo de negocio que sera realizado (ENTRY_IN, ENTRY_OUT)
      double closeVolume;              // Volume da posicao original, que sera fechada
      ulong  sourcePosTicket;          // Ticket da posicao original para acrescimo e realizacao parcial
      double execVolume;               // Volume executado (acumulado) com os deals
      double execPrice;                // Preco de execucao, obtido a partir dos deals
      double closeProfit;              // Lucro/prejuizo obtido ao fechar a operacao

};


// Estrutura para armazenamento dos dados de posicoes abertas
struct openPositionType {

      ulong id;                     // Identificador unico da posicao associado a ordem de abertura
      uint  tradeid;                // Identificador de operacao do robo, que pode ser a mesma para diversas posicoes abertas 
      ulong ticket;                 // Ticket da posicao, usado para referenciamento, mas que pode alterar dependendo da execucao de ordens
      ulong sourceTicket;           // Ticket da posicao de origem (para os casos mudanca na posicao - acrescimo)
      int   level;                  // Nivel da ordem na logica do gradiente linear
      bool check;                   // Posicao verificada com as atualmente abertas
      tradeDirection type;          // Tipo da posicao (compra ou venda)
      double volume;                // Volume da posicao
      double profit;                // Lucro atual da posicao
      double openPrice;             // Preco de abertura da posicao
      double stopLoss;              // Valor atual do stop loss
      double takeProfit;            // Valor atual do take profit
      string comment;               // Comentario da posicao
      datetime openTime;            // Hora de abertura da posicao
      double risk;                  // Risco inicial da posicao
      double profitPoints;          // Distancia inicial do take profit
      int profitBarCount;           // Numero de barras no lucro
      double profitBarRefPrice;     // Preco de referencia para proxima verificacao de barra com lucro
      int tradeBarCount;            // Numero de barras desde a abertura da posicao

};



input string            inDesc0="===========================";       // ========= PARAMETROS GERAIS =========
input string            inUserEmail="";                              // e-mail cadastrado na RobotCrowd
input int               inEA_Magic=10000;                            // Numero magico do expert advisor
input bool              inNotifyEmail=false;                         // Enviar avisos por e-mail
input bool              inNotifyPush=false;                          // Enviar notificacoes push para terminal mobile
input bool              inUseOldFashionComment=false;                // Usar padrao antigo nas informacoes (Comment)
input int               inTickDelay=2;                               // Tempo de ciclo para processamento (segundos)
input int               inDeviation = 10;                            // Desvio maximo de preco em pontos
input bool              inCloseOnExpiration=true;                    // Encerrar operacao um dia antes da expiracao do contrato
input tradeType         inTradeType=TRADE_TYPE_BOTH;                 // Tipo de operacao
input string            inTradeSymbol="";                            // Ativo para negociacao (caso seja diferente do grafico)
input ENUM_TIMEFRAMES   inPeriod = PERIOD_CURRENT;                   // Periodo grafico principal
input bool              inShowIndicators = false;                    // Mostrar indicadores no grafico
input bool              inDeleteIndicators = false;                  // Apagar indicadores ao remover o EA

input string            inDesc1="===========================";       // ========= GERENCIAMENTO DE RISCO =========
input riskType          inRiskMode=RISK_FIXED_LOT;                   // Metodo para calculo de volume
input double            inLot = 1.0;                                 // Volume fixo ou incremento/minimo
input double            inRiskParameter = 0.0;                       // Incremento de capital ou risco percentual
input double            inActualBalance = 0.0;                       // Capital considerado (Zero usa saldo da conta/Negativo variavel global)

input string            inDesc3="===========================";       // ============= DAY TRADE ==============
input bool              inDayTrade=true;                             // Operacao apenas como day trade
input int               inStartHour=9;                               // -> Hora inicio negociacao
input int               inStartWaitMin=1;                            // -> Minutos a aguardar antes de iniciar operacoes
input int               inStopHour=18;                               // -> Hora fim negociacao
input int               inStopBeforeEndMin=15;                       // -> Minutos antes do fim para realizar
input int               inNoTradeBeforeEndMin=75;                    // -> Minutos antes do fim para abertura de posicao

input string            inDesc5="===========================";       // ======== LIMITES DE OPERACAO =========
input double            inMaxDayLoss=0.0;                            // Perda maxima aceitavel no dia (Zero ilimitado)
input double            inMaxDayProfit=0.0;                          // Objetivo de lucro diario (Zero ilimitado)
input double            inMaxWeekLoss=0.0;                           // Perda maxima aceitavel na semana (Zero ilimitado)
input double            inMaxWeekProfit=0.0;                         // Objetivo de lucro semanal (Zero ilimitado)
input double            inMaxMonthLoss=0.0;                          // Perda maxima aceitavel no mes (Zero ilimitado)
input double            inMaxMonthProfit=0.0;                        // Objetivo de lucro mensal (Zero ilimitado)
input int               inMaxDayTrades=0;                            // Numero maximo de trades no dia (Zero ilimitado)
input int               inMaxDayTP=0;                                // Numero maximo de take profit no dia (Zero ilimitado)
input bool              inCheckPLAfterClose=false;                   // Verificar limites de perda e ganho apenas apos fechar operacao
input bool              inTDWFilter=false;                           // Filtrar operacoes por dia da semana
input bool              inTDWMonday=true;                            // -> Operar segunda-feira
input bool              inTDWTuesday=true;                           // -> Operar terca-feira
input bool              inTDWWednesday=true;                         // -> Operar quarta-feira
input bool              inTDWThursday=true;                          // -> Operar quinta-feira
input bool              inTDWFriday=true;                            // -> Operar sexta-feira

input string            inDesc6="===========================";       // ===== INTERTRAVAMENTO ENTRE ROBOS =====
input bool              inLockEnable=false;                          // Habilita intertravamento
input bool              inLockMaster=false;                          // Robo e preferencial para trava
input string            inLockName="globalLockPAPEL";                // Nome da trava (Ex: globalLockWDOX15)
input double            inLockValue=0.0;                             // Valor atribuido a trava (unico para cada EA)

input string            inDesc4="===========================";       // ======== STOP LOSS E OBJETIVO ========
input timeStopCondType  inTimeStopCond=TIME_STOP_COND_NONE;          // Usar stop de tempo
input ENUM_TIMEFRAMES   inTimeStopPeriod=PERIOD_CURRENT;             // -> Periodo para determinacao do stop
input int               inTimeStopValue=10;                          // -> Numero de barras considerado
input SLTPType          inSLTP=SL_TP_FIXED;                          // Tipo de stop e objetivo
input double            inSLValue=200.0;                             // -> Valor ou multiplicador stop loss (Zero desativa)
input double            inTPValue=30.0;                              // -> Valor ou multiplicador objetivo (Zero desativa)

input string            inDesc7="===========================";       // ==== PARAMETROS GRADIENTE LINEAR =====
input double            inGLOffsetOpen=20.0;                         // Offset para novas ordens de entrada
input double            inGLOffsetClose=30.0;                        // Offset para realizacao de lucro 
input bool              inGLTrailingTrade=false;                     // Mover as ordens a favor do trade (trailing)
input int               inGLMaxLevels=0;                             // Numero maximo de ordens/niveis (Zero ilimitado)
input bool              inGLUseSingleOrderOut=false;                 // Usar ordem de saida unica na superacao do preco medio

class TradeWatchGL
  {

public:
         TradeWatchGL() { };
        ~TradeWatchGL() { };

        virtual void startNewTrade(tradeDirection dir, double start, double stop, double profit) { };
        virtual void moveGLOrders(const MqlRates &mrates[]) { };
        virtual void cancelTrade() { };
        virtual void checkPrices() { };
        virtual void checkPosition() { };
        virtual double calcStopLoss(const MqlRates &lastBar, double price, tradeDirection dir) { return(0.0); };
        virtual double calcTakeProfit(const MqlRates &lastBar, double price, tradeDirection dir) { return(0.0); };
        virtual bool checkBarCount(int count) { return(true); };
        virtual bool checkNewBar() { return(true); };
        virtual bool checkNewDay() { return(true); };
        virtual bool checkTickDelay() { return(true); };
        virtual bool isBuyPosition() { return(true); };
        virtual bool isSellPosition() { return(true); };
        virtual void closePosition() { };
        virtual bool checkTradeTime() { return(true); };
        virtual bool checkTradeLimits() { return(true); };
        virtual bool sellTriggered() { return(true); };
        virtual bool buyTriggered() { return(true); };
        
        virtual bool mutexCheckLock() { return(true); };
        virtual bool mutexTryLock() { return(true); };
        virtual bool mutexIsLocked() { return(true); };
        virtual bool mutexRelease() { return(true); };

        virtual void processTradeTransaction(const MqlTradeTransaction &trans, const MqlTradeRequest &request, const MqlTradeResult &result) { };
        virtual void processTimer() { };

        virtual void setGlobalParameters(string userEmail, int EA_Magic, bool notifyEmail, bool notifyPush, bool useOldFashionComment, int tickDelay, int setDeviation, 
                               bool closeOnExpiration, tradeType selTradeType, string tradeSymbolInput, ENUM_TIMEFRAMES selPeriod,
                               bool showIndicators, bool deleteIndicators) { };
        virtual void setRiskParameters(riskType riskMode, double lotInput, double riskParameter, double actualBalance) { };
        virtual void setDayTradeParameters(bool dayTrade, int startHour, int stopHour, int stopBeforeEndMin, int noTradeBeforeEndMin) { };
        virtual void setSLTPParameters(SLTPType sltp, double slValue, double tpValue, timeStopCondType timeStopCond, ENUM_TIMEFRAMES timeStopPeriod, int timeStopValue) { };
        virtual void setGLParameters(double glOffsetOpen, double glOffsetClose, bool glTrailingTrade, int glMaxLevels, bool glUseSingleOrderOut) { };
        virtual void setLimitParameters(double maxDayLoss, double maxDayProfit, double maxWeekLoss, double maxWeekProfit, double maxMonthLoss, double maxMonthProfit, 
                                int maxDayTrades, int maxDayTP, bool checkPLAfterClose, bool tdwFilter, 
                                bool tdwMonday, bool tdwTuesday, bool tdwWednesday, bool tdwThursday, bool tdwFriday) { };
        virtual void setInterlockParameters(bool lockEnable, bool lockMaster, string lockName, double lockValue) { };

        virtual void startTradeWatchGL() { };
        
        virtual bool compareDouble(double d1, double d2) { return(true); };

  };



