//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#define VALIDADE   D'2100.12.31 23:59:59'//Data de Validade ano.mes.dia horas:minutos:segundos(opcional)
#define NUMERO_CONTA 9011600   //Numero da conta
#define ONLY_DEMO "NAO" //"SIM"- Somente em Demo,"NAO"- liberado para conta Real



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

#include<ChartObjects\ChartObjectsLines.mqh>


#include <EA_Igor\Params.mqh>
#include <EA_Igor\LinearRegExp.mqh>

/*
#include <EA_Igor\AfastMedia.mqh>
#include <EA_Igor\BolWprStoc.mqh>
#include <EA_Igor\DidiExp.mqh>
#include <EA_Igor\TresMedias.mqh>
#include <EA_Igor\AtrStpExp.mqh>
#include <EA_Igor\PTLRSOExp.mqh>
#include <EA_Igor\LinearRegExp.mqh>
#include <EA_Igor\HiLoPrNY.mqh>
*/
CAccountInfo      myaccount;
LinearRegRobot MyLinRegExp;

/*
AfastMedia MyAfastMed;
BolWprStoRobot MyBolWprSt;
DidiRobot MyDidiExp;
TresMedRobot MyTresMedExp;
ATRStpRobot MyAtrStpExp;
PTLRSORobot MyPTLRSOExp;
LinearRegRobot MyLinRegExp;
HiLoPrNYRobot MyHiLoPrNY;
*/
CLabel            m_label[50];
CLabel            label_cotacao[50];
CLabel            label_porc[50];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {

         return MyLinRegExp.OnInit();


/*  switch(Estrategia)
     {
      case Afast:
         return MyAfastMed.OnInit();
         break;
      case BolaWprSt:
         return MyBolWprSt.OnInit();
         break;
      case Didi:
         return MyDidiExp.OnInit();
         break;
      case TresMed:
         return MyTresMedExp.OnInit();
         break;
      case ATRStp:
         return MyAtrStpExp.OnInit();
         break;

      case PTLRSO:
         return MyPTLRSOExp.OnInit();
         break;

      case Regress:
         return MyLinRegExp.OnInit();
         break;

      case HiLoPrNY:
         return MyHiLoPrNY.OnInit();
         break;

      default:
         return INIT_FAILED;
         break;
     }
     
     */
//---
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
//---
         MyLinRegExp.OnDeinit(reason);
/*
  switch(Estrategia)
     {
      case Afast:
         MyAfastMed.OnDeinit(reason);
         break;
      case BolaWprSt:
         MyBolWprSt.OnDeinit(reason);
         break;
      case Didi:
         MyDidiExp.OnDeinit(reason);
         break;
      case TresMed:
         MyTresMedExp.OnDeinit(reason);
         break;
      case ATRStp:
         MyAtrStpExp.OnDeinit(reason);
         break;
      case PTLRSO:
         MyPTLRSOExp.OnDeinit(reason);
         break;
      case Regress:
         MyLinRegExp.OnDeinit(reason);
         break;
      case HiLoPrNY:
         MyHiLoPrNY.OnDeinit(reason);
         break;
     }*/

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer()
  {

         MyLinRegExp.OnTimer();
/*
 switch(Estrategia)
     {
      case Afast:
         MyAfastMed.OnTimer();
         break;
      case BolaWprSt:
         MyBolWprSt.OnTimer();
         break;
      case Didi:
         MyDidiExp.OnTimer();
         break;
      case TresMed:
         MyTresMedExp.OnTimer();
         break;
      case ATRStp:
         MyAtrStpExp.OnTimer();
         break;

      case PTLRSO:
         MyPTLRSOExp.OnTimer();
         break;
      case Regress:
         MyLinRegExp.OnTimer();
         break;

      case HiLoPrNY:
         MyHiLoPrNY.OnTimer();
         break;

     }
*/
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTradeTransaction(const MqlTradeTransaction &trans,
                        const MqlTradeRequest &request,
                        const MqlTradeResult &result)
  {

         MyLinRegExp.OnTradeTransaction(trans,request,result);

/* switch(Estrategia)
     {
      case Afast:
         MyAfastMed.OnTradeTransaction(trans,request,result);
         break;
      case BolaWprSt:
         MyBolWprSt.OnTradeTransaction(trans,request,result);
         break;
      case Didi:
         MyDidiExp.OnTradeTransaction(trans,request,result);
         break;
      case TresMed:
         MyTresMedExp.OnTradeTransaction(trans,request,result);
         break;
      case ATRStp:
         MyAtrStpExp.OnTradeTransaction(trans,request,result);
         break;
      case PTLRSO:
         MyPTLRSOExp.OnTradeTransaction(trans,request,result);
         break;
      case Regress:
         MyLinRegExp.OnTradeTransaction(trans,request,result);
         break;
      case HiLoPrNY:
         MyHiLoPrNY.OnTradeTransaction(trans,request,result);
         break;

     }
     */
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
         MyLinRegExp.OnTick();

/*
   switch(Estrategia)
     {
      case Afast:
         MyAfastMed.OnTick();
         break;
      case BolaWprSt:
         MyBolWprSt.OnTick();
         break;
      case Didi:
         MyDidiExp.OnTick();
         break;
      case TresMed:
         MyTresMedExp.OnTick();
         break;

      case ATRStp:
         MyAtrStpExp.OnTick();
         break;
      case PTLRSO:
         MyPTLRSOExp.OnTick();
         break;
      case Regress:
         MyLinRegExp.OnTick();
         break;
      case HiLoPrNY:
         MyHiLoPrNY.OnTick();
         break;

     }*/
  }
//+------------------------------------------------------------------+
