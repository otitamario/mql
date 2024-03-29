#include <Trade\Trade.mqh>
//#include <Timer.mqh>
#include <Auxiliares.mqh>

#include <comment.mqh>
#include<Trade\AccountInfo.mqh> // saber tipo de conta e outras coisas mais // CAccountInfo myaccount;
#include <Expert\Expert.mqh> // Saber dados do símbolo // CSymbolInfo simbolo;



//--- TODO Ver aqui o que vai aproveitar
#define EXPERT_VERSION  "0.1"
//--- custom colors
#define COLOR_BACK      clrBlack
#define COLOR_BORDER    clrDodgerBlue
#define COLOR_CAPTION   clrWhite
#define COLOR_TEXT      clrDodgerBlue
#define COLOR_WIN       clrLimeGreen
#define COLOR_LOSS      clrOrangeRed

CTrade Trade;
CNewBar NewBar;
#property script_show_inputs 
//--- SIM ou NÃO
enum SIM_NAO{ 
   SIM=1, // SIM
   NAO=0, // NÃO
}; 
    
// Configurações Base
input string configs_base = "Configurações Base"; //Configurações Base
input string nome_ea = "XM - Open Source(BETA)"; //Nome do EA
input ENUM_TIMEFRAMES tempo_grafico = PERIOD_M15; //Tempo Gráfico
input ulong magicNum = 123456; //Magic Number
input SIM_NAO exibir_logs_grafico = SIM; //Exibir Logs no gráfico?   // TODO falta implementar
//cor do log // TODO falta implementar
// tipo da janela móvel de resultados // TODO falta implementar
input ENUM_ORDER_TYPE_FILLING preenchimento = ORDER_FILLING_RETURN; //Tipo do preenchimento de ordens à mercado
input ENUM_ORDER_TYPE_FILLING preenchimento_ordens_pendentes = ORDER_FILLING_RETURN; //Tipo do preenchimento de ordens pendentes // TODO Falta implementar
input ENUM_ORDER_TYPE_TIME validade_ordens_pendentes = ORDER_TIME_DAY; //Tipo da validade das ordens pendentes

// Simulador de Custos Operacionais
input string custos_operacionais = "*** Custos Operacionais ***";//*** Custos Operacionais ***
input double custo_operacional_fixo_por_contrato = 0.48;//Custo operacional fixo por contrato // TODO Falta implementar
//custo operacional fixo por ordem // TODO Falta implementar
//exportação de dados do BT // TODO Falta implementar
//id do setup para hedge analyzer // TODO Falta implementar

// Parâmetros da Estratégia
input string parametros_estrategia = "*** Parâmetros da Estratégia ***";//*** Parâmetros da Estratégia ***
input int ma_periodo = 15; //Período da Média Móvel
input int distancia_media = 800; //Distância da Média em pontos
input int distancia_ordem_limit = 50; //Distância da ordem Limit
input int tempo_validade_ordem_limit = 900; //Tempo validade ordem limit [segundos] (0=Off)
input bool UmaOrdemPorCandle=false; // Aguardar novo candle para tentativa de reentrada? //Ricardo em 23/12
input int numero_contratos = 1; //Número de contratos
input int maximo_operacao_dia = 1; // Quantidade maxima de operacoes permitidas por dia
input SIM_NAO filtro_gap = NAO; //[FILTRO GAP] Não operar dias com GAP maior que // TODO Falta implementar

// Parâmetros de Saída
input string parametros_saida = "*** Parâmetros de Saída ***";//*** Parâmetros de Saída ***
input SIM_NAO fechar_operacao_tensao = SIM; //Fechar Operação pela Tensão? // TODO Falta implementar
input double percentual_tensao_saida = 0; //% Tensão p/ saída // TODO Falta implementar

// Stops iniciais
input string stops_iniciais = "*** Stops Iniciais ***";//*** Stops Iniciais ***
input int stop_loss = 1200; //Stop Loss em pontos (SL)
input int stop_gain = 5000; //Stop Gain em pontos (TP)

// Janela de Operações
input string janela_operacoes = "*** Janela de Operações ***"; //*** Janela de Operações ***
input SIM_NAO marcar_horarios_linhas_verticais = SIM; //Marcar horários c/ linhas verticais no gráfico?
//dias da semana permitidos
//operar de segunda-feira // TODO Falta implementar
//operar de terça-feira // TODO Falta implementar
//operar de quarta-feira // TODO Falta implementar
//operar de quinta-feira // TODO Falta implementar
//operar de sexta-feira // TODO Falta implementar
//operar de sábado // TODO Falta implementar
//operar de domingo // TODO Falta implementar

// Período Diário
input string periodo_diario = "Período Diário";  //Período Diário
input int horario_inicial_abrir_posicoes = 09;   //Horário inicial permitido p/ abrir posições
input int minuto_inicial_abrir_posicoes = 30;    //Minuto inicial permitido p/ abrir posições
input int horario_final_abrir_posicoes = 12;     //Horário final permitido p/ abrir posições
input int minuto_final_abrir_posicoes = 0;       //Minuto final permitido p/ abrir posições

    
// Fechamento Diário
input string fechamento_diario = "Fechamento Diário"; //Fechamento Diário
input SIM_NAO fechar_posicoes_final_dia = SIM; //Fechar posições no final de cada dia?
input int horario_fechar_todas_posicoes = 13; //Horário para fechar todas as posições em aberto
input int minuto_fechar_todas_posicoes = 00; //Minuto para fechar todas as posições em aberto

// Alertas e Notificações
input string alertas_notificacoes = "Alertas e Notificações"; //Alertas e Notificações
input SIM_NAO exibir_alerta_mt5_novas_posicoes = NAO; // Exibir um alerta no MT5 ao abrir novas posições? // TODO Falta implementar
input SIM_NAO enviar_notificacao_smartphone_primeiro_tick = SIM; // Notificação no Smartphone no primeiro tick do dia? // TODO Falta implementar
input SIM_NAO enviar_notificacao_smartphone_novas_posicoes = SIM;// Notificação no Smartphone ao abrir novas posições? // TODO Falta implementar
input SIM_NAO enviar_notificacao_smartphone_fechar_posicoes = SIM;// Notificação no Smartphone ao fechar posições? // TODO Falta implementar
input SIM_NAO enviar_notificacao_smartphone_perda_conexao_corretora = SIM;// Notificação no Smartphone ao perder conexão com a corretora? // TODO Falta implementar

// Parâmetros visuais
input string parametros_visuais = "Parâmetros Visuais"; //Parâmetros Visuais
input color cor_foreground = clrWhite; // Cores gerais no gráfico
input color cor_background = clrBlack; // Cor de fundo do gráfico
input color cor_candle_alta = clrLime; // Cor do candle de alta
input color cor_sombra_candle_alta = clrGray; // Cor da sombra do candle de alta
input color cor_candle_baixa = clrRed; // Cor do candle de baixa
input color cor_sombra_candle_baixa = clrGray; // Cor da sombra do candle de baixa
input color cor_candle_indecisao = clrGray; // Cor do candle de indecisão

// Configurações da média móvel (Sem deslocamento, preço de fechamento dos candles)
int ma_desloc = 0;//Deslocamento da Média
ENUM_MA_METHOD ma_metodo = MODE_SMA;//Método Média Móvel
ENUM_APPLIED_PRICE ma_preco = PRICE_CLOSE;//Preço para Média

// TODO Verificar esta informação aqui!!!!
ulong desvPts = 50;//Desvio em Pontos ??????

// Variáveis para tratar os dados da média
double smaArray[];
int smaHandle;

MqlTick ultimoTick;
MqlRates rates[];

int quantidade_rates; // TODO Verificar se precisa disso aqui...

MqlDateTime Time;


// Horários de funcionamento do robô
datetime inicio_dia;
datetime inicio_abertura;
datetime final_abertura;
datetime fechamento_posicoes;

// Barras limite para indicar condição de compra ou venda
double barra_inferior;
double barra_superior;

// Variáveis para controlar o cancelamento de ordens por tempo
bool marktime = false; //Marcador para cancelamento das ordens pendentes por tempo
datetime TimeS; // Contagem do tempo das ordens pendentes
bool AutorizaOperacaoNovoCandle = true; // Variável auxiliar para saber se deve aguardar novo candle (Ricardo em 23/12)

//--- global variables
CComment comentario;
CAccountInfo myaccount;
CSymbolInfo simbolo;
int tester;
int visual_mode;

//---Variáveis para trabalhar com o tipo de conta hedging ou netting
ENUM_ACCOUNT_MARGIN_MODE Tipo_Conta;
string PrintConta = "", PrintOrdem = "";

// Definição de variáveis para armazenar os ganhos do robô
const string GANHO_DIA = "XequeMate_OpenSource_" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) +_Symbol+"_GANHO_DIA";
const string GANHO_SEM = "XequeMate_OpenSource_" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) +_Symbol+"_GANHO_SEM";
const string GANHO_MES = "XequeMate_OpenSource_" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) +_Symbol+"_GANHO_MES";
const string GANHO_TOTAL = "XequeMate_OpenSource_" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) +_Symbol+"_GANHO_TOTAL";
string operacoes_dia = "XequeMate_OpenSource_" + IntegerToString(AccountInfoInteger(ACCOUNT_LOGIN)) +_Symbol+"_OPERACOES_DIA_"+IntegerToString(TimeCurrent());
MqlDateTime mql_date_time_start;
MqlDateTime mql_date_time_finish;
MqlDateTime mql_date_time_closeall;   

//+------------------------------------------------------------------+
//| Função executa quando o robô inicializa                          |
//+------------------------------------------------------------------+
int OnInit(){
   // Limpa indicadores da tela
   RemoveIndicadores();
   // Tenta construir o indicador, retorna falha em caso de erro
   if (!ConstrucaoIndicador()) return (INIT_FAILED);
   // Prepara tela
   PreparaTela();

   InicializaVariaveis();
   
   // Cria o quadro resumo - Lembrando que OnTimer() é executado nessa função
   CriarQuadroResumo();

   // Função para verificar se a conta é Netting ou Hedge e se a ordem é FOK, IOC, ...
   tipoConta(); tipoOrdem();
   Print(PrintConta," - ",PrintOrdem);   
   PermissaoNegociacaoAutomatizada();
   
   // Retorna operação com sucesso
   return(INIT_SUCCEEDED);

}

// Função de deinicialização do robô
void OnDeinit(const int reason){
   RemoveIndicadores();
   comentario.Destroy();
   EventKillTimer();   
}

// Função executada a cada novo tick
void OnTick(){
   
   // Teste de sanidade do sistema
   if (!VerificaSanidade()) return;           
   
    // Verifica se é um novo dia - Usado para funções que precisam ser executadas apenas umas vez ao dia    
    bool NovaBarraDiaria = NewBar.CheckNewBar(_Symbol, PERIOD_D1);
    if (NovaBarraDiaria == true){
      DefineDatas();
      CriarMarcacaoTelaVertical();      
      AutorizaOperacaoNovoCandle = true; // Ricardo em 23/12
    }
    
// Verifica o Máximo de operação do dia e Verifica se já foi realizada alguma operação no dia
   if (VerificaMaxOperacaoDia() == 0 || !VerificaMaxOperacaoDia()){
          
      if (ContarPosicoes() > 0){      
         //Se posição aberta, não precisa da marcacao
         DeletarMarcacaoTelaVertical();       
         // TODO Fechar posições por horário máximo de funcionamento do robô
         FecharTodasPosicoesHorarioFechamento();
      }
      
      if (VerificaHorarioFuncionamento()){          
         
         // Verifica se é um novo candle         
         bool NovaBarraTempoCorrente = NewBar.CheckNewBar(_Symbol, _Period);
         int barShift = 1;
         
         MqlTradeRequest request;
         MqlTradeResult  result;
         
         // Se for um novo candle, atualiza as barras superior e inferior
         if (NovaBarraTempoCorrente == true){
            
            // Define os valores das barras superior e inferior
            barra_superior = smaArray[0] + distancia_media;
            barra_inferior = smaArray[0] - distancia_media;
            AutorizaOperacaoNovoCandle = true;
            
            // Adiciona as barras de alerta de negociação
            if (ContarPosicoes() == 0 && GlobalVariableGet(operacoes_dia) == 0){
            
               // Gerencia as barras de distância à média
               ObjectDelete(0, "HorizontalTop");
               ObjectDelete(0, "HorizontalBottom");
               
               // Adiciona a barra superior
               //ObjectDelete(0, "HorizontalTop");
               ObjectCreate(0, "HorizontalTop", OBJ_HLINE, 0, rates[0].time, barra_superior);
               ObjectSetInteger(0, "HorizontalTop", OBJPROP_COLOR, clrRed);        
                           
               // Adiciona a barra inferior
               //ObjectDelete(0, "HorizontalBottom");
               ObjectCreate(0, "HorizontalBottom", OBJ_HLINE, 0, rates[0].time, barra_inferior);
               ObjectSetInteger(0, "HorizontalBottom", OBJPROP_COLOR, clrBlue);
            } else {
               // Seta a informação de que tem operação sendo realizada
               GlobalVariableSet(operacoes_dia, ContarPosicoes());
            }
            
            // Atualizar o TP da ordem de acordo com a média a cada novo candle
            if (ContarOrdens() > 0){
               
               double old_tp = OrderGetDouble(ORDER_TP);               
               if (old_tp != normalizePrice(smaArray[0])){
                  if(!Trade.OrderModify(OrderGetTicket(0), OrderGetDouble(ORDER_PRICE_OPEN), OrderGetDouble(ORDER_SL), normalizePrice(smaArray[0]), ORDER_TIME_DAY,TimeCurrent()))
                     PrintFormat("OrderSend error %d", GetLastError()); // se não foi possível enviar o pedido, exibir o código de erro          
                  //--- zerado dos valores do pedido e o seu resultado
               }
                  
            }
            
            // Atualizar o TP da posição de acordo com a média a cada novo candle
            if (ContarPosicoes() > 0){                  
               
               // Definição dos parâmetros de operação              
               double old_tp = PositionGetDouble(POSITION_TP);               

               if(!tester || visual_mode){
                  if (PositionGetDouble(POSITION_PROFIT) >= 0){
                     comentario.SetText(7, "No dia: R$" + DoubleToString(PositionGetDouble(POSITION_PROFIT)), COLOR_WIN);
                  } else {
                     comentario.SetText(7, "No dia: R$" + DoubleToString(PositionGetDouble(POSITION_PROFIT)), COLOR_LOSS);
                  }
                  comentario.Show();
               }

               double sl = PositionGetDouble(POSITION_SL); // Stop Loss da posição
               double tp = normalizePrice(smaArray[0]); // Take Profit da posição               
               if (old_tp != normalizePrice(smaArray[0])){
                if(!Trade.PositionModify(_Symbol,sl,tp)){
                     PrintFormat("Erro ao modificar posição %d", GetLastError()); // se não foi possível enviar o pedido, exibir o código de erro         
                }
               }
                              
            }
            
         }
         
         // Se estiver nas condições de compra ou de venda e não tiver nenhuma ordem ou posição em aberto, pendura a ordem
         double takeProfit = 0;
         if ((ultimoTick.last >= barra_superior) && ContarOrdens() == 0 && ContarPosicoes() == 0 && PermissaoNegociacaoAutomatizada() && AutorizaOperacaoNovoCandle){  
            takeProfit = (ultimoTick.last + distancia_ordem_limit - normalizePrice(smaArray[0])) < stop_gain ? normalizePrice(smaArray[0]) : ultimoTick.last - stop_gain;
            if (Trade.SellLimit(numero_contratos, normalizePrice(ultimoTick.last + distancia_ordem_limit), _Symbol, normalizePrice(ultimoTick.last + distancia_ordem_limit + stop_loss), takeProfit, validade_ordens_pendentes, tempo_validade_ordem_limit, "Ordem de Venda do XM")){
               Print("Ordem de Venda pelo Magic Number:"+IntegerToString(magicNum)+ " com sucesso. Código Transação:",Trade.ResultRetcode(), ", RetcodeDescription: ", Trade.ResultRetcodeDescription());
               
               // Marca o momento da colocação da ordem para quando precisar cancelar por tempo
               marktime = true;
               TimeS = TimeCurrent();
               
            } else {
               Print("Ordem de Venda pelo Magic Number:"+IntegerToString(magicNum)+ " falhou. ResultRetcode: ", Trade.ResultRetcode(), ", RetcodeDescription: ", Trade.ResultRetcodeDescription());
            }
         } else if ((ultimoTick.last <= barra_inferior) && ContarOrdens() == 0 && ContarPosicoes() == 0 && PermissaoNegociacaoAutomatizada() && AutorizaOperacaoNovoCandle){
            takeProfit = (normalizePrice(smaArray[0]) - ultimoTick.last + distancia_ordem_limit) < stop_gain ? normalizePrice(smaArray[0]) : ultimoTick.last + stop_gain;
            if (Trade.BuyLimit(numero_contratos, normalizePrice(ultimoTick.last - distancia_ordem_limit), _Symbol, normalizePrice(ultimoTick.last - distancia_ordem_limit - stop_loss), takeProfit, validade_ordens_pendentes, tempo_validade_ordem_limit, "Ordem de Compra do XM")){
               Print("Ordem de Compra feita pelo Magic Number:"+IntegerToString(magicNum)+ " com sucesso.", Trade.ResultRetcode(), ", RetcodeDescription: ", Trade.ResultRetcodeDescription());
               
               // Marca o momento da colocação da ordem para quando precisar cancelar por tempo
               marktime = true;
               TimeS = TimeCurrent();
               
            } else {
               Print("Ordem de Compra pelo Magic Number:"+IntegerToString(magicNum)+ " falhou. ResultRetcode: ", Trade.ResultRetcode(), ", RetcodeDescription: ", Trade.ResultRetcodeDescription());
            }
         }
         
         // Cancela as ordens que tiverem expirado o tempo de validade
         CancelarOrdensPorTempo();              
            
      }
   
   }
   
   AtualizaTelaResultadoFinal();
   
} // Fim do OnTick




void DefineDatas(){

    string CurrDate = TimeToString(TimeCurrent(), TIME_DATE);
    TimeToStruct(StringToTime(CurrDate), mql_date_time_start);
    TimeToStruct(StringToTime(CurrDate), mql_date_time_finish);
    TimeToStruct(StringToTime(CurrDate), mql_date_time_closeall);
    
     mql_date_time_start.hour = horario_inicial_abrir_posicoes;
     mql_date_time_start.min = minuto_inicial_abrir_posicoes;
     mql_date_time_start.sec = 0;
     
     mql_date_time_finish.hour = horario_final_abrir_posicoes;
     mql_date_time_finish.min = minuto_final_abrir_posicoes;
     mql_date_time_finish.sec = 0;
    
     mql_date_time_closeall.hour = horario_fechar_todas_posicoes;
     mql_date_time_closeall.min = minuto_fechar_todas_posicoes;
     mql_date_time_closeall.sec = 0;    
    
    inicio_abertura = StructToTime(mql_date_time_start);
    final_abertura = StructToTime(mql_date_time_finish);
    fechamento_posicoes = StructToTime(mql_date_time_closeall);
    
}

void funcoesConfiguracaoGeral(){};
//+---------------------------------------------------------------------------------+
//| Funções de configuração geral do robo
//+---------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Inicializa Variaveis de Ganho                                        |
//+------------------------------------------------------------------+
void InicializaVariaveis(){

 // Adiciona as variáveis que armazenam os ganhos inicialmente
   if (!GlobalVariableCheck(GANHO_DIA)){
      GlobalVariableSet(GANHO_DIA, 0);
   }
   if (!GlobalVariableCheck(GANHO_SEM)){
      GlobalVariableSet(GANHO_SEM, 0);
   }
   if (!GlobalVariableCheck(GANHO_MES)){
      GlobalVariableSet(GANHO_MES, 0);
   }
   if (!GlobalVariableCheck(GANHO_TOTAL)){
      GlobalVariableSet(GANHO_TOTAL, 0);
   }
   if (!GlobalVariableCheck(operacoes_dia)){
      GlobalVariableSet(operacoes_dia, 0);
      Print(operacoes_dia);
   }    
 
 
   // TODO - LUIZ GOUVEIA - SUGESTÃO COLOCAR ISSO NA PARTE DE ORDENS, NAO PRECISA SER NA INICIALIZAÇÃO
   // Seta o tipo do preenchimento de ordens à mercado
   Trade.SetTypeFilling(preenchimento);
   // Seta o desvio em pontos
   Trade.SetDeviationInPoints(desvPts);
   // Seta o magic number do EA
   Trade.SetExpertMagicNumber(magicNum);
 
   
}

void funcoesManipulacaoTela(){};
//+---------------------------------------------------------------------------------+
//| Funções de manipulação de tela - Exp.: Colocar texto, alterar cor do candle
//+---------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Prepara as configurações de tela                                 |
//+------------------------------------------------------------------+
void PreparaTela(){
// Prepara as propriedades do gráfico
   // Removendo o grid
   
   //SUGESTÃO DO RICARDO - Seria interessante rodar um script que limpasse a tela antes, acho que tem algo pronto nos exmeplos do metaeditor
   ChartSetInteger(0, CHART_SHOW_GRID, false);
   // Definindo a cor de foreground
   ChartSetInteger(0, CHART_COLOR_FOREGROUND, cor_foreground);
   // Definindo a cor de background
   ChartSetInteger(0, CHART_COLOR_BACKGROUND, cor_background);
   // Seta como gráfico de candles
   ChartSetInteger(0, CHART_MODE, CHART_CANDLES); 
   // Seta o tempo gráfico
   ChartSetSymbolPeriod(0, _Symbol, tempo_grafico);
   // Seta as cores da barra de alta
   ChartSetInteger(0, CHART_COLOR_CANDLE_BULL, cor_candle_alta);
   ChartSetInteger(0, CHART_COLOR_CHART_UP, cor_sombra_candle_alta);   
   // Seta as cores da barra de baixa
   ChartSetInteger(0, CHART_COLOR_CANDLE_BEAR, cor_candle_baixa);
   ChartSetInteger(0, CHART_COLOR_CHART_DOWN, cor_sombra_candle_baixa);
   //Seta a cor da barra de indecisão
   ChartSetInteger(0, CHART_COLOR_CHART_LINE, cor_candle_indecisao);
   // Seta a propriedade de exibir o último valor e a sua cor
   // TODO ver aqui porque não está ficando verde...   
   ChartSetInteger(0, CHART_SHOW_LAST_LINE, true);   
   ChartSetInteger(0, CHART_COLOR_LAST, clrGreen);   
   // Seta a propriedade de exibir o valor bid e a sua cor
   ChartSetInteger(0, CHART_SHOW_BID_LINE, true);      
   ChartSetInteger(0, CHART_COLOR_BID, clrGray);   
   // Seta a propriedade de exibir o valor ask e a sua cor
   ChartSetInteger(0, CHART_SHOW_ASK_LINE, true);
   ChartSetInteger(0, CHART_COLOR_ASK, clrGray);

}



//+------------------------------------------------------------------+
//| Cria o quadro resumo                                             |
//+------------------------------------------------------------------+
bool CriarQuadroResumo(){

   tester = MQLInfoInteger(MQL_TESTER);
   visual_mode = MQLInfoInteger(MQL_VISUAL_MODE);
   //--- panel position
   int y = 30;
   if(ChartGetInteger(0, CHART_SHOW_ONE_CLICK))
      y = 120;
   //--- panel name
   srand(GetTickCount());
   string name = "panel_" + IntegerToString(rand());
   comentario.Create(name, 20,y);
   //--- panel style
   comentario.SetAutoColors(false); //InpAutoColors
   comentario.SetColor(COLOR_BORDER, COLOR_BACK, 255);
   comentario.SetFont("Lucida Console", 13, false, 1.7);
   //---
   #ifdef __MQL5__
   comentario.SetGraphMode(!tester);
   #endif
   //--- not updated strings
   comentario.SetText(0, nome_ea + "[" + GetTipoConta() + "]x" + IntegerToString(numero_contratos) + " (" + _Symbol + ")", COLOR_CAPTION);
   comentario.SetText(1, DataHoraAtualFormatoBrasileiro(),COLOR_TEXT);
   comentario.SetText(2,"Posições: " + IntegerToString(ContarPosicoes()), COLOR_TEXT);
   comentario.SetText(3, "LUCROS COM O ROBÔ", COLOR_CAPTION);
   comentario.SetText(4, "Total:     R$0,00", COLOR_WIN);
   comentario.SetText(5, "No mês:    R$0,00", COLOR_WIN);
   comentario.SetText(6, "Na semana: R$0,00", COLOR_WIN);
   comentario.SetText(7, "No dia:    R$0,00", COLOR_WIN);   
   comentario.SetText(8, "EA em desenvolvimento baseado na ",COLOR_TEXT);
   comentario.SetText(9, "'Teoria das Operações Contra a Tendência'", COLOR_TEXT);
   comentario.SetText(10,"de Flávio Schotgues", COLOR_TEXT);
   comentario.Show();
   //--- run timer
   if(!tester || visual_mode)
      EventSetTimer(1);
   OnTimer();

   return true;
   
}

//+------------------------------------------------------------------+
//| Cria marcacao de tela vertical                                   |
//+------------------------------------------------------------------+
void CriarMarcacaoTelaVertical(){
      // Verifica a configuração de marcação dos horários com linhas verticais
      TimeToStruct (rates[0].time, Time);      
      if (marcar_horarios_linhas_verticais == SIM && Time.hour >= 9 && Time.min >= 0){
         
         // Recupera a data atual para utilizar nas variáveis das linhas de cada dia         
         string CurrDate = TimeToString(TimeCurrent(), TIME_DATE);
   
         // Plota a barra inicial do dia
         inicio_dia = StringToTime(CurrDate + " 09:00:00");
         ObjectCreate(0, "VerticalInicio" + CurrDate, OBJ_VLINE, 0, inicio_dia, 0); 
         ObjectSetInteger(0, "VerticalInicio" + CurrDate, OBJPROP_COLOR, clrSteelBlue);         
         ObjectSetInteger(0, "VerticalInicio" + CurrDate, OBJPROP_STYLE, STYLE_DOT);
         
         // Plota a barra inicial de abertura de posições         
         ObjectCreate(0, "VerticalInicioAbrirPosicoes" + CurrDate, OBJ_VLINE, 0, inicio_abertura, 0); 
         ObjectSetInteger(0, "VerticalInicioAbrirPosicoes" + CurrDate, OBJPROP_COLOR, clrMediumSpringGreen);         
         ObjectSetInteger(0, "VerticalInicioAbrirPosicoes" + CurrDate, OBJPROP_STYLE, STYLE_DOT);
         
         // Plota a barra final de abertura de posições         
         ObjectCreate(0,"VerticalFinalAbrirPosicoes" + CurrDate,OBJ_VLINE, 0, final_abertura, 0); 
         ObjectSetInteger(0,"VerticalFinalAbrirPosicoes" + CurrDate, OBJPROP_COLOR, clrSteelBlue);         
         ObjectSetInteger(0,"VerticalFinalAbrirPosicoes" + CurrDate, OBJPROP_STYLE, STYLE_DOT);
         
         // Plota a barra final de fechamento de todas as posições
         //fechamento_posicoes = StringToTime(CurrDate + " " + horario_fechar_todas_posicoes + ":00");
         ObjectCreate(0, "VerticalFinalFecharPosicoes" + CurrDate, OBJ_VLINE, 0, fechamento_posicoes, 0); 
         ObjectSetInteger(0, "VerticalFinalFecharPosicoes" + CurrDate, OBJPROP_COLOR, clrTomato);
         ObjectSetInteger(0, "VerticalFinalFecharPosicoes" + CurrDate, OBJPROP_STYLE, STYLE_DOT);
         
      }
}

//+------------------------------------------------------------------+
//| Cria marcacao de tela vertical                                   |
//+------------------------------------------------------------------+
void DeletarMarcacaoTelaVertical() {
         // Remove as barras se já tiver posições abertas
         ObjectDelete(0, "HorizontalTop");
         ObjectDelete(0, "HorizontalBottom");   
 }  

//+------------------------------------------------------------------+
//| Função de atualização do resultado $ do dia                      |
//+------------------------------------------------------------------+
void  AtualizaTelaResultadoFinal() {      
      // Ao final do Trade, coloca o valor de ganho ou perda perto da seta
      color BuyColor = clrBlue; 
      color SellColor = clrRed; 
      HistorySelect(0, TimeCurrent()); 
      uint total = HistoryDealsTotal(); 
      ulong ticket = 0; 
      double price; 
      double profit; 
      datetime time; 
      string symbol; 
      long type; 
      long entry; 
      for(uint i = 0; i < total; i++){          
         if((ticket = HistoryDealGetTicket(i)) > 0){ 
            price = HistoryDealGetDouble(ticket, DEAL_PRICE); 
            time = (datetime)HistoryDealGetInteger(ticket, DEAL_TIME); 
            symbol = HistoryDealGetString(ticket, DEAL_SYMBOL); 
            type = HistoryDealGetInteger(ticket, DEAL_TYPE); 
            entry = HistoryDealGetInteger(ticket, DEAL_ENTRY); 
            profit = HistoryDealGetDouble(ticket, DEAL_PROFIT); 
            if(price && time && symbol == Symbol() && profit != 0){ 
               string text_name = "EA_ResultadoTrade_" + IntegerToString(ticket); 
               ObjectCreate(0, text_name, OBJ_TEXT, 0, time, price); 
               ObjectSetInteger(0, text_name, OBJPROP_COLOR, profit < 0 ? clrRed : clrBlue); 
               ObjectSetString(0, text_name, OBJPROP_TEXT, profit < 0 ? "   -R$" : "   R$" + formatarReais(profit)); 
               ObjectSetString(0, text_name, OBJPROP_FONT, "Trebuchet MS"); 
               ObjectSetInteger(0, text_name, OBJPROP_FONTSIZE, 10); 
               ObjectSetInteger(0, text_name, OBJPROP_ANCHOR, ANCHOR_LEFT); 
               ObjectSetInteger(0, text_name, OBJPROP_SELECTABLE, false);
               // Atualiza o quadro resumo com o ganho ou a perda do dia
               if (profit >= 0){
                  comentario.SetText(7, "No dia:    R$" + formatarReais(profit), COLOR_WIN);
               } else {
                  comentario.SetText(7, "No dia:    R$" + formatarReais(profit), COLOR_LOSS);
               }  
               // Atualiza o quadro resumo com a quantidade de posições abertas
               comentario.SetText(2,"Posições: " + IntegerToString(ContarPosicoes()), COLOR_TEXT);
               comentario.Show();
               // TODO atualizar o restante do quadro resumo
               // TODO atualizar as variáveis globais que guarda os valores do quadro resumo
            } 
         } 
      } 

      ChartRedraw(); 
  }

//+------------------------------------------------------------------+
//| Função de evento do gráfico do Expert                            |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,         // ID do evento  
                  const long& lparam,   // parâmetro do evento do tipo long
                  const double& dparam, // parâmetro do evento do tipo double
                  const string& sparam){ // parâmetro do evento do tipo string
  
   int res = comentario.OnChartEvent(id, lparam, dparam, sparam);
   //--- move panel event
   if(res == EVENT_MOVE)
      return;
   //--- change background color
   if(res == EVENT_CHANGE)
      comentario.Show();
   
}

//+------------------------------------------------------------------+
//| OnTimer - Cada tempo definido no setTimer()                      |
//+------------------------------------------------------------------+
void OnTimer(){

   if(!tester || visual_mode){
      // Atualiza o quadro resumo com a data/hora atual
      comentario.SetText(1, DataHoraAtualFormatoBrasileiro(), COLOR_TEXT);
      if (ContarPosicoes() > 0){
         // Atualiza o quadro resumo com a situação da posição aberta
         comentario.SetText(2,"Posições: " + IntegerToString(ContarPosicoes()) + " - (Entrada: " + IntegerToString((int)PositionGetDouble(POSITION_PRICE_OPEN)) + ", SL: " + IntegerToString((int)PositionGetDouble(POSITION_SL)) + ", TP: " + IntegerToString((int)PositionGetDouble(POSITION_TP)) + ")", COLOR_TEXT);
         // Atualiza o quadro resumo com o ganho/perda da posição aberta
         if (PositionSelect(_Symbol)){
            if (PositionGetDouble(POSITION_PROFIT) >= 0){
               comentario.SetText(7, "No dia:    R$" + formatarReais(PositionGetDouble(POSITION_PROFIT)), COLOR_WIN);
            } else {
               comentario.SetText(7, "No dia:    R$" + formatarReais(PositionGetDouble(POSITION_PROFIT)), COLOR_LOSS);
            }
         }
      }      
      comentario.Show();
   }
   
}

void funcoesManipulacaoIndicador(){};
//+---------------------------------------------------------------------------------+
//| Funções de manipulação de indicadores - criação, alteração, exclusão
//+---------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Função para construir indicadores dos gráficos                   | 
//+------------------------------------------------------------------+
bool ConstrucaoIndicador(){

   smaHandle = iMA(_Symbol, _Period, ma_periodo, ma_desloc, ma_metodo, ma_preco);
   if(smaHandle == INVALID_HANDLE){
      Print("Erro ao criar média móvel - erro", GetLastError());
      return false;
   }   
   
   if(!ChartIndicatorAdd(0, 0, smaHandle)) {
      PrintFormat("Falha ao adicionar o indicador Média Móvel no gráfico. Código do Erro  %d", 0,GetLastError()); 
      return false;
   }              
   
   ArraySetAsSeries(smaArray, true);
   ArraySetAsSeries(rates, true);
   
   quantidade_rates = ArraySize(rates);
   return true;
   
}

//+------------------------------------------------------------------+
//| Função para remover todos os indicadores dos gráficos            |
//+------------------------------------------------------------------+
void RemoveIndicadores(){
   
   int    F_TotJanelaGrafico = int(ChartGetInteger(0,CHART_WINDOWS_TOTAL));
   int    F_NumeroJanelaTrabalho;
   int    F_TotalIndicadorJanela = 0;
   int    F_NumeroIndicadorTrabaho;
   string F_NomeIndicadorTrabalho = "";

   for (F_NumeroJanelaTrabalho = F_TotJanelaGrafico-1;F_NumeroJanelaTrabalho>=0;F_NumeroJanelaTrabalho--){
      F_TotalIndicadorJanela = ChartIndicatorsTotal(0,F_NumeroJanelaTrabalho);
      for (F_NumeroIndicadorTrabaho = F_TotalIndicadorJanela-1;F_NumeroIndicadorTrabaho>=0;F_NumeroIndicadorTrabaho--){
         F_NomeIndicadorTrabalho = ChartIndicatorName(0,F_NumeroJanelaTrabalho,F_NumeroJanelaTrabalho);
         ChartIndicatorDelete(0,F_NumeroIndicadorTrabaho,F_NomeIndicadorTrabalho);
      }
   }
   
}


void funcoesValidacoes(){};
//+---------------------------------------------------------------------------------+
//|Funções de validação - Exp.: Loss/Gain maximo atingido, restrição de horário
//+---------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| // Função verificar horário de funcionamento
//+------------------------------------------------------------------+
bool VerificaHorarioFuncionamento(){
   // Verifica se está no horário de funcionamento do robô
   datetime TCurrent = TimeCurrent();  // Para evitar chamar a função TimeCurrent duas vezes        
   if (TCurrent >= inicio_abertura && TCurrent < final_abertura)
      return true;
   else return false;
}   

//+------------------------------------------------------------------+
//| // Função que verifica se o dia já foi encerrado
//+------------------------------------------------------------------+
bool VerificaMaxOperacaoDia(){

    datetime start,finish;
    
    MqlDateTime mql_date_time_start_str;
    MqlDateTime mql_date_time_finish_str;
    TimeCurrent(mql_date_time_start_str);
    TimeCurrent(mql_date_time_finish_str);
    
    mql_date_time_start_str.hour = 0;
    mql_date_time_start_str.min = 0;
    mql_date_time_start_str.sec = 0;
 
    mql_date_time_finish_str.hour = 23;
    mql_date_time_finish_str.min = 59;
    mql_date_time_finish_str.sec = 59;
    
    start = StructToTime(mql_date_time_start_str);
    finish = StructToTime(mql_date_time_finish_str);
    // A data de inicio do historico tem que ser hoje 00:00 e a data fim hoje 23:59
    HistorySelect(start, finish); 
    
    // Variaveis que serao utilizadas no loop
    uint total = HistoryDealsTotal();
    ulong ticket = 0;
    string symbol;         
    long magicNumber;
    int totalOperacoes = 0;
    
    //Precisamos percorrer o historico para verificar se houve historico de operação no ativo que estamos e através do nosso EA
    for(uint i = 0; i < total; i++){ 
      if((ticket =HistoryDealGetTicket(i)) > 0){  
         symbol = HistoryDealGetString(ticket, DEAL_SYMBOL); 
            if(symbol == Symbol()){ 
               magicNumber = HistoryDealGetInteger(ticket, DEAL_MAGIC);
                  if (magicNumber == magicNum) totalOperacoes++;
             }            
       }
    }    
    
    // Checar se o total de operacoes do dia foi atingido
    if (totalOperacoes >= maximo_operacao_dia)
      return true;
    else   
      return false;

}

//+------------------------------------------------------------------+
//| // Verifica Sanidade
//+------------------------------------------------------------------+
bool VerificaSanidade(){          
   
   if(!SymbolInfoTick(Symbol(), ultimoTick)){
      Alert("Erro ao obter informações de Preços: ", GetLastError());
      return false;
   }
      
   if(CopyRates(_Symbol, _Period, 0, 3, rates)<0){
      Alert("Erro ao obter as informações de MqlRates: ", GetLastError());
      return false;
   }
   
   if(CopyBuffer(smaHandle, 0, 0, 3, smaArray)<0){
      Alert("Erro ao copiar dados da média móvel: ", GetLastError());
      return false;
   }
   return true;
      
}


void funcoesOrdemPosicao(){};
//+---------------------------------------------------------------------------------+
//|Funções de ordem e posição - Exp.: Abertura de ordem, verificar posição, etc..
//+---------------------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Função para contar a quantidade de ordens em aberto para o ativo |
//+------------------------------------------------------------------+
int ContarOrdens(){
  
   int ordens = 0;
   ulong ticket = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--) // returns the number of current orders
      ticket = OrderGetTicket(i);
      if (ticket != 0){
         string symbol = OrderGetString(ORDER_SYMBOL);
         long magic_number = OrderGetInteger(ORDER_MAGIC);
         long order_type = OrderGetInteger(ORDER_TYPE);
         
         if (symbol == _Symbol && magic_number == magicNum){
            if(order_type == ORDER_TYPE_BUY_LIMIT || order_type == ORDER_TYPE_SELL_LIMIT || order_type == ORDER_TYPE_BUY_STOP || order_type == ORDER_TYPE_SELL_STOP)
               ordens++;
         }
      }
      
   return(ordens);

}

//+--------------------------------------------------------------------+
//| Função para contar a quantidade de posições em aberto para o ativo |
//+--------------------------------------------------------------------+
int ContarPosicoes(){
  
   int posicoes = 0;

   for(int i = PositionsTotal() - 1; i >= 0; i--){
      string symbol = PositionGetSymbol(i);
      ulong magic = PositionGetInteger(POSITION_MAGIC);
      if(symbol == _Symbol && magic == magicNum){  
         posicoes++;
      }
   }
   
   return posicoes;
  
}

//+------------------------------------------------------------------+
//| Função para cancelar todas as ordens pendentes expiradas         |
//+------------------------------------------------------------------+
void CancelarOrdensPorTempo(){
   
   if (tempo_validade_ordem_limit > 0 && marktime == true && ContarOrdens() > 0 && ((long) TimeCurrent() - TimeS) > tempo_validade_ordem_limit){
      CancelarTodasOrdens();
      marktime = false;
      if(UmaOrdemPorCandle) AutorizaOperacaoNovoCandle=false; // Ricardo em 23/12
   }
   
}

//+------------------------------------------------------------------+
//| Função para cancelar todas as ordens pendentes                   |
//+------------------------------------------------------------------+
void CancelarTodasOrdens(){
   
   MqlTradeRequest req = {0};
   MqlTradeResult  res = {0};

   int orders = OrdersTotal();
   req.action = TRADE_ACTION_REMOVE;

   for(int i = orders - 1; i >= 0; i--){
      req.order = OrderGetTicket(i);
      if (OrderGetString(ORDER_SYMBOL) == _Symbol){
         ResetLastError();
         if(!OrderSend(req, res)){
           Print("Falha no cancelamento da ordem ", req.order, ": Error ", GetLastError(), ", retcode = ", res.retcode);
         }
      }
   }
   
}

//+------------------------------------------------------------------+
//| Função para fechar todas as operações no horário indicado        |
//+------------------------------------------------------------------+
void FecharTodasPosicoesHorarioFechamento(){
   
   // se estiver no horário de fechar todas as posições
   if (fechar_posicoes_final_dia == SIM && (TimeCurrent() > fechamento_posicoes || TimeCurrent() == fechamento_posicoes)){
      // Fecha todas as posições do robô
      FecharTodasPosicoes();
   }
   
}

//+------------------------------------------------------------------+
//| Função para fechar todas as operações para o ativo atual         |
//+------------------------------------------------------------------+
void FecharTodasPosicoes(){

   for (int i = PositionsTotal() - 1; i >= 0; i--){                 
      if (PositionGetSymbol(i) == _Symbol){
         if(!Trade.PositionClose(PositionGetSymbol(i))){
            // Mensagem de falha
            Print(PositionGetSymbol(i), "Erro ao fechar a posição. Return code=", Trade.ResultRetcode(), ". Code description: ", Trade.ResultRetcodeDescription());
         } else {
            // Mesnagem de sucesso
            Print(PositionGetSymbol(i), "Posição fechada com sucesso. Return code=", Trade.ResultRetcode(), " (", Trade.ResultRetcodeDescription(), ")");
         }
      }
   }
}

//+---------------------------------------------------------------------------------+
//| Função para verificar o tipo de ordem aceita pela corretora|
//+---------------------------------------------------------------------------------+
void tipoOrdem(){
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      PrintOrdem = "ORDER_FILLING_FOK";
      //Print("ORDER_FILLING_FOK");
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      PrintOrdem = "ORDER_FILLING_IOC";
      //Print("ORDER_FILLING_IOC");
   else
      PrintOrdem = "ORDER_FILLING_RETURN";
      //Print("ORDER_FILLING_RETURN");
      
   if(IsFillingTypeAllowed(SYMBOL_FILLING_FOK))
      Trade.SetTypeFilling(ORDER_FILLING_FOK);
   else if(IsFillingTypeAllowed(SYMBOL_FILLING_IOC))
      Trade.SetTypeFilling(ORDER_FILLING_IOC);
   else
      Trade.SetTypeFilling(ORDER_FILLING_RETURN);
      
   //Print(PrintConta," - ",PrintOrdem);  Esta print já está sendo feito no init
}

//+------------------------------------------------------------------+ 
//| Checks if the specified filling mode is allowed                  | 
//+------------------------------------------------------------------+ 
bool IsFillingTypeAllowed(int fill_type){
   
   //--- Obtain the value of the property that describes allowed filling modes 
   int filling=simbolo.TradeFillFlags();
   //--- Return true, if mode fill_type is allowed 
   return((filling & fill_type)==fill_type);
   
}

void funcoesApoio(){};
//+---------------------------------------------------------------------------------+
//| Funções de Apoio - Conversões, formatações
//+---------------------------------------------------------------------------------+

//+---------------------------------------------------------------------------------+
//| Função para verificar o tipo de conta |
//+---------------------------------------------------------------------------------+
void tipoConta(){

   if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING){
      PrintConta="Conta Hedging!";
      Tipo_Conta=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING;
   }

   if(myaccount.MarginMode()==ACCOUNT_MARGIN_MODE_RETAIL_NETTING){
      PrintConta="Conta Netting!";
      Tipo_Conta=ACCOUNT_MARGIN_MODE_RETAIL_NETTING;
   }
    
}

//+---------------------------------------------------------------------------------+
//| Normalização do preço para não ficar com valores quebrados direfentes de 0 ou 5 |
//+---------------------------------------------------------------------------------+
double normalizePrice(double price){

   double tickSize = SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   return(MathRound(price/tickSize)*tickSize);
   
}

//+------------------------------------------------------------------+
// Função para determinar o tipo da conta (DEMO, CONTEST ou REAL)    |
//+------------------------------------------------------------------+
string GetTipoConta(){
   
   ENUM_ACCOUNT_TRADE_MODE tradeMode = (ENUM_ACCOUNT_TRADE_MODE) AccountInfoInteger(ACCOUNT_TRADE_MODE); 
   // Descobre o tipo de conta 
   string retorno = "";
   switch(tradeMode){
      case(ACCOUNT_TRADE_MODE_DEMO): 
         retorno = "DEMO"; 
         break; 
      case(ACCOUNT_TRADE_MODE_CONTEST): 
         retorno = "CONTEST"; 
         break; 
      default:retorno = "REAL"; 
   }
   
   return retorno;       
   
}

//+-----------------------------------------------------------------------------------------+
// Função para verificação da permissão para realizar a negociação automatizada no terminal |
//+-----------------------------------------------------------------------------------------+
bool PermissaoNegociacaoAutomatizadaTerminal(){

   if (TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){
      return true;
   } else {
      return false;
   }
   
}

//+-----------------------------------------------------------------------------------------------------------+
// Função para verificação se a negociação é permitida para uma determinada execução do Expert Advisor/script |
//+-----------------------------------------------------------------------------------------------------------+
bool PermissaoNegociacaoDeterminadaExecucaoEA(){

   if (MQLInfoInteger(MQL_TRADE_ALLOWED)){
      return true;
   } else {
      return false;
   }
   
}

//+--------------------------------------------------------------------------------------------------------------+
// Função para verificar se a negociação é permitida para qualquer Expert Advisors/scripts para a conta corrente |
//+--------------------------------------------------------------------------------------------------------------+
bool PermissaoNegociacaoQualquerEAContaCorrente(){

   if (AccountInfoInteger(ACCOUNT_TRADE_EXPERT)){
      return true;
   } else {
      return false;
   }
   
}

//+------------------------------------------------------------------------+
// Função para verificar se a negociação é permitida para a conta corrente |
//+------------------------------------------------------------------------+
bool PermissaoNegociacaoContaCorrente(){

   if (AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)){
      return true;
   } else {
      return false;
   }
   
}

//+------------------------------------------------------------------------+
// Função para verificar se a negociação automatizada está totalmente ok   |
//+------------------------------------------------------------------------+
bool PermissaoNegociacaoAutomatizada(){

   if (!PermissaoNegociacaoAutomatizadaTerminal()){
      Print("Negociação automatizada no terminal está desabilitada! Clique no botão para habilitar!");
      return false;
   } else if (!PermissaoNegociacaoDeterminadaExecucaoEA()){
      Print("Negociação automatizada do EA está desabilitada! Verifique as configurações do EA!");
      return false;
   } else if (!PermissaoNegociacaoQualquerEAContaCorrente()){
      Print("Negociação automatizada é proibida para esta conta! Verifique com a sua corretora!");
      return false;
   } else if (!PermissaoNegociacaoContaCorrente()){
      Print("Negociação é proibida para esta conta! Verifique com a sua corretora!");
      return false;
   } else {
      Print("Negociação automatizada permitida e habilitada!");
      return true;
   }
   
}

//+------------------------------------------------------------------------+
// Função que formata valores double em reais                              |
//+------------------------------------------------------------------------+
string formatarReais(double number, int precision=2, string pcomma=".", string ppoint=","){

   string snum = DoubleToString(number, precision);
   int decp = StringFind(snum, ".", 0);
   string sright = StringSubstr(snum, decp + 1, precision);
   string sleft = StringSubstr(snum, 0, decp);
   string formated = "";
   string comma = "";
   
   while (StringLen(sleft) > 3){
      int length = StringLen(sleft);
      string part = StringSubstr(sleft, length - 3, 0);
           formated = part + comma + formated;
           comma = pcomma;
           sleft = StringSubstr(sleft, 0, length - 3);
   }
   
   if (sleft == "-") comma = ""; // this line missing previously
   if (sleft != "") formated = sleft + comma + formated;
   if (precision > 0) formated = formated + ppoint + sright;
   
   return(formated);
   
}

//+--------------------------------------------------------------------------------+
//  Função que retorna a data/hora atual em formato brasileiro DD/MM/YYYY HH:MM:SS |
//+--------------------------------------------------------------------------------+
string DataHoraAtualFormatoBrasileiro(){
   datetime tm = TimeCurrent();
   MqlDateTime stm;
   TimeToStruct(tm, stm);
   string dia = "";
   string mes = "";
   string hora = "";
   string minuto = "";
   string segundo = "";
   
   if(stm.day < 10){
      dia = "0" + (string) stm.day;
   } else {
      dia = (string) stm.day;
   } 
   if(stm.mon < 10){
      mes = "0" + (string) stm.mon;
   } else {
      mes = (string) stm.mon;
   }
   if(stm.hour < 10){
      hora = "0" + (string) stm.hour;
   } else {
      hora = (string) stm.hour;
   }
   if(stm.min < 10){
      minuto = "0" + (string) stm.min;
   } else {
      minuto = (string) stm.min;
   }
   if(stm.sec < 10){
      segundo = "0" + (string) stm.sec;
   } else {
      segundo = (string) stm.sec;
   }
   
   return dia + "/" + mes + "/" + (string)stm.year + " " + hora + ":" + minuto + ":" + segundo;   
}