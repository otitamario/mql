//+------------------------------------------------------------------+
//|                                   Copyright 2015, Erlon F. Souza |
//|                                       https://github.com/erlonfs |
//+------------------------------------------------------------------+
#define   robot_name    "BOX OF CONSOLIDATION"
#define   robot_version "2.4.0"

#property copyright     "Copyright 2015, Erlon F. Souza"
#property link          "https://github.com/erlonfs"
#property description   "Utiliza o setup de consolidação para mini dolar/mini indice.O programa exibi marcações em tela durante as analises. Quando o mesmo gerar uma area com cor neutra (cinza por definição), significa que não existe operação a realizar. Em marcações de cor vermelha (padrão), o mesmo espera uma entrada em venda descoberta, em marcações de cor azul (cor pre-definida) o programa espera uma entrada em compra.\n\n\nBons trades!\n\nEquipe BAD ROBOT.\nerlon.efs@gmail.com"
#property icon          "box_of_consolidation.ico";  

#include <..\Experts\box.bad-robot\src\BoxOfConsolidation.mqh>
#include <BadRobot.Framework\Enum.mqh>

input string               Secao1 = "###############";//### Definições Básicas ###
input string               HoraInicio="00:00";//Hora de início de execução da estratégia
input string               HoraFim="00:00";//Hora de término de execução da estratégia
input string               HoraInicioIntervalo="00:00";//Hora de início intervalo de execução da estratégia
input string               HoraFimIntervalo="00:00";//Hora de término intervalo de execução da estratégia
input ENUM_LOGIC           FecharPosition=0;//Fechar posições ao término de horario de execução?
input int                  Volume=0; //Volume
input ENUM_LAST_PRICE_TYPE TipoUltimoPreco=0;//Tipo de referência do ultimo preço
input int                  Spread = 0;//Spread para entrada na operação em ticks

input string               Secao2 = "###############";//### Alvos ###
input int                  StopGainEmTicks=0; //Stop Gain em ticks
input int                  StopLossEmTicks=0; //Stop Loss em ticks

input string               Secao3 = "###############";//### Gerenciamento de Stop ###
input ENUM_LOGIC           IsStopNoCandleAnterior=0;//Stop na máxima/ mínima do candle anterior?
input int                  SpreadStopNoCandleAnterior=0;//Spread utilizado no ajuste em ticks
input ENUM_LOGIC           WaitBreakEvenExecuted=0;//Aguardar execução do break even?
input ENUM_LOGIC           IsPeridoPersonalizadoStopNoCandleAnterior=0;//Utilizar período personalizado?
input ENUM_TIMEFRAMES      PeridoStopNoCandleAnterior=0;//Período personalizado

input string               Secao4 = "###############";//### Trailing Stop ###
input ENUM_LOGIC           IsTrailingStop=0;//Ativar Trailing Stop?
input int                  TrailingStopInicio=0; //Valor de inicio em ticks
input int                  TrailingStop=0; //Valor de Ajuste do Trailing Stop  em ticks

input string               Secao5 = "###############";//### Break-Even ###
input ENUM_LOGIC           IsBreakEven=0;//Ativar Break-Even?
input int                  BreakEven=0;//Valor do break-even, zero é o ponto inicial em ticks
input int                  BreakEvenInicio=0;//Valor de inicio em ticks

input string               Secao6 = "###############";//### Financeiro ###
input ENUM_LOGIC           IsGerenciamentoFinanceiro=0;//Ativar Gerenciamento Financeiro?
input double               MaximoLucroDiario=0; //Lucro máximo no dia
input double               MaximoPrejuizoDiario=0; //Prejuízo máximo no dia

input string               Secao7 = "###############";//### Realização de Parcial ###
input ENUM_LOGIC           IsParcial=0;//Ativar saída parcial?
input double               PrimeiraParcialVolume=0;//Volume da 1ª saída parcial
input int                  PrimeiraParcialInicio=0;//Valor de inicio da 1ª saída parcial em ticks
input double               SegundaParcialVolume=0;//Volume da 2ª saída parcial
input int                  SegundaParcialInicio=0;//Valor de inicio da 2ª saída parcial em ticks
input double               TerceiraParcialVolume=0;//Volume da 3ª saída parcial
input int                  TerceiraParcialInicio=0;//Valor de inicio da 3ª saída parcial em ticks

input string               Secao8 = "###############";//### Expert Control ###
input int                  NumeroMagico=0; //O número mágico é utilizado para diferenciar ordens de outros robôs

input string               Secao9 = "###############";//### Notificações ###
input ENUM_LOGIC           IsNotificacoesApp=0;//Ativar notificações no app do metatrader 5?

input string               Secao10 = "###############";//### Config de UI ###
input ENUM_LOGIC           IsDesenhar=0;//Desenhar marcações?
input ENUM_LOGIC           IsPreencher=0;//Preencher?
input ENUM_LOGIC           IsEnviarParaTras=0;//Enviar para Trás?
input color                Cor=clrDimGray;//Cor utilizada em marcaçoes nulas
input color                CorCompra=C'3,95,172';//Cor utilizada em marcações de Compra
input color                CorVenda=C'225,68,29';//Cor utilizada em marcações de Venda

input string               Secao11 = "###############";//### Config de Estratégia ###
input ENUM_LOGIC           IsUtilizarIndicadores=0;//Utilizar indicadores?
input int                  MediaLonga=0;//Média longa
input int                  MediaCurta=0;//Média curta
input ENUM_TIMEFRAMES      PeriodoIndicadores=PERIOD_CURRENT;//Periodo utilizados nos indicadores
input double               TamanhoMaximoCandle=0;//Tamanho máx. candle consolidacao
input int                  QuantidadeCandlesConsolidacao=0;//quantidade de candles usados na consolidacao
input ENUM_TIMEFRAMES      Periodo=PERIOD_CURRENT;//Periodo da estrategia

//variaveis
BoxOfConsolidation _ea;

int OnInit()
  {                  
   //Definições Básicas  
   _ea.SetSymbol(_Symbol);
   _ea.SetHoraInicio(HoraInicio);
   _ea.SetHoraFim(HoraFim);
   _ea.SetHoraInicioIntervalo(HoraInicioIntervalo);
   _ea.SetHoraFimIntervalo(HoraFimIntervalo);  
   _ea.SetIsClosePosition(FecharPosition);
   _ea.SetVolume(Volume);
   _ea.SetSpread(Spread);
   
   //Alvos
   _ea.SetStopGain(StopGainEmTicks);
   _ea.SetStopLoss(StopLossEmTicks);
   
   //Gerenciamento de Stop
   _ea.SetIsStopOnLastCandle(IsStopNoCandleAnterior);   
   
   //Trailing Stop
   _ea.SetIsTrailingStop(IsTrailingStop);
   _ea.SetTrailingStopInicio(TrailingStopInicio);
   _ea.SetTrailingStop(TrailingStop);   
   
   //Break-Even
   _ea.SetIsBreakEven(IsBreakEven);  
   _ea.SetBreakEvenInicio(BreakEvenInicio);
   _ea.SetBreakEven(BreakEven);
   
   //Financeiro
   _ea.SetIsGerenciamentoFinanceiro(IsGerenciamentoFinanceiro);
   _ea.SetMaximoLucroDiario(MaximoLucroDiario);
   _ea.SetMaximoPrejuizoDiario(MaximoPrejuizoDiario);     
   
   //Realização de Parcial
   _ea.SetIsParcial(IsParcial);
   _ea.SetPrimeiraParcialVolume(PrimeiraParcialVolume);
   _ea.SetPrimeiraParcialInicio(PrimeiraParcialInicio);   
   _ea.SetSegundaParcialVolume(SegundaParcialVolume);
   _ea.SetSegundaParcialInicio(SegundaParcialInicio);   
   _ea.SetTerceiraParcialVolume(TerceiraParcialVolume);
   _ea.SetTerceiraParcialInicio(TerceiraParcialInicio);    
   
   //Expert Control
   _ea.SetNumberMagic(NumeroMagico);
   _ea.SetRobotName(robot_name);
   _ea.SetRobotVersion(robot_version);
       
   //UI
   _ea.SetColor(Cor);
   _ea.SetColorBuy(CorCompra);
   _ea.SetColorSell(CorVenda);     
   _ea.SetIsDesenhar(IsDesenhar);
   _ea.SetIsEnviarParaTras(IsEnviarParaTras);
   _ea.SetIsPreencher(IsPreencher);
   
   //Notificacoes
   _ea.SetIsNotificacoesApp(IsNotificacoesApp);
   
   //Estratégia
   _ea.SetQtdCandleConsolidacao(QuantidadeCandlesConsolidacao);
   _ea.SetIsUtilizarIndicadores(IsUtilizarIndicadores);
   _ea.SetEMALongPeriod(MediaLonga);
   _ea.SetEMAShortPeriod(MediaCurta);
   _ea.SetPeriodIndicadores(PeriodoIndicadores);
   _ea.SetTamanhoMaxPrecoCandle(TamanhoMaximoCandle);
   _ea.SetPeriod(Periodo);
    
    //Load Expert
 	_ea.OnInit();
 	 	  
   return(INIT_SUCCEEDED);

}

void OnDeinit(const int reason)
{
	_ea.OnDeinit(reason);
}

void OnTick()
{
   _ea.OnTick();  
}

void OnTimer()
{
   _ea.OnTimer();
}

void OnTrade(){
   _ea.OnTrade();
}

void OnTradeTransaction(const MqlTradeTransaction& trans, const MqlTradeRequest& request, const MqlTradeResult& result)
{
	_ea.OnTradeTransaction(trans, request, result);
}

double OnTester()
{
	return _ea.OnTester();
}

void OnTesterInit()
{
	_ea.OnTesterInit();
}

void OnTesterPass()
{
	_ea.OnTesterPass();
}

void OnTesterDeinit()
{
	_ea.OnTesterDeinit();
}

void OnBookEvent(const string& symbol)
{
	_ea.OnBookEvent(symbol);
}

void OnChartEvent(const int id, const long& lparam, const double& dparam, const string& sparam)
{
   _ea.OnChartEvent(id, lparam, dparam, sparam);   
}