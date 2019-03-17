//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   1
//+------------------------------------------------------------------+
#property indicator_label1  "HiLo"
#property indicator_type1   DRAW_COLOR_BARS
#property indicator_color1  clrLime,clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

//string NomeCliente="NOME"; //NOME DO USUÁRIO
//bool blockCliente;

/*
ulong conta1=90261;
ulong conta2=655259;
ulong conta3=3000141516;
ulong conta4=295949;
ulong conta5=50295949;
ulong conta6=60295949;
ulong conta7=70295949;
ulong conta8=80295949;
ulong conta9=90295949;
ulong conta10=5150793;
bool blockCliente; */

//+------------------------------------------------------------------+
input int      inPeriod=8;   // Periodo HiLo
//+------------------------------------------------------------------+
double         HiLoBuffer1[],HiLoBuffer2[],HiLoBuffer3[],HiLoBuffer4[];
double         HiLoColors[],HighMABuffer[],LowMABuffer[];
int            HighMAHandle,LowMAHandle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() 
  {
  
  /*
    blockCliente=  AccountInfoString(ACCOUNT_NAME)== NomeCliente;
  if( blockCliente==true)  
 {
  {
  
  Print("Liberado para uso."); */
  
/*
  
  blockCliente=AccountInfoInteger(ACCOUNT_LOGIN)==conta1 || AccountInfoInteger(ACCOUNT_LOGIN)==conta2 || AccountInfoInteger(ACCOUNT_LOGIN)==conta3 || AccountInfoInteger(ACCOUNT_LOGIN)==conta4 || AccountInfoInteger(ACCOUNT_LOGIN)==conta5 || AccountInfoInteger(ACCOUNT_LOGIN)==conta6 || AccountInfoInteger(ACCOUNT_LOGIN)==conta7 || AccountInfoInteger(ACCOUNT_LOGIN)==conta8 || AccountInfoInteger(ACCOUNT_LOGIN)==conta9 || AccountInfoInteger(ACCOUNT_LOGIN)==conta10;  
  if(blockCliente) Print("Liberado para uso.");
   
  else
     
  {
      
  Print("Conta não autorizada");
      
  return(INIT_FAILED);

  } */

  //}
  

//Expiry date setting 
string ExpiryDate="2019.01.01";
if(TimeCurrent() >= StringToTime(ExpiryDate)){
Alert("O período de testes do hilo_escada_smothed expirou.");
ChartIndicatorDelete(0,0,"hilo_escada_smothed");
//ExpertRemove();
Print("Indicador removido devido ao periodo de utilização haver vencido. Nos contate para solicitar sua licença de uso!");
return(0);
}
else{
Print("Indicador hilo_escada_smothed liberado para uso até 01/01/2019");
  }
  
  IndicatorSetString(INDICATOR_SHORTNAME,"hilo_escada_smothed");
     
   //IndicatorSetString(INDICATOR_SHORTNAME,"HiLo");

   SetIndexBuffer(0,HiLoBuffer1,INDICATOR_DATA);
   SetIndexBuffer(1,HiLoBuffer2,INDICATOR_DATA);
   SetIndexBuffer(2,HiLoBuffer3,INDICATOR_DATA);
   SetIndexBuffer(3,HiLoBuffer4,INDICATOR_DATA);
   SetIndexBuffer(4,HiLoColors,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,HighMABuffer,INDICATOR_DATA);
   SetIndexBuffer(6,LowMABuffer,INDICATOR_DATA);

   HighMAHandle= iMA(_Symbol,0,inPeriod,0,MODE_SMMA,PRICE_HIGH);
   LowMAHandle = iMA(_Symbol,0,inPeriod,0,MODE_SMMA,PRICE_LOW);

   return(0);

  }
  
//---
//} 
/*
}

 else{
 ChartIndicatorDelete(0,0,"hilo_escada_smothed");
 //ExpertRemove();
 Print("Este indicador irá funcionar somente em contas previamente cadastradas pelo criador da ferramenta.");  
 Print("Favor contatar o criador da ferramenta se você possui autorização para uso da mesma.");   
             }
  return(INIT_SUCCEEDED);
  } */
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

   int swing=0;
   double lastvalue=0.0;

   if(CopyBuffer(HighMAHandle,0,0,rates_total,HighMABuffer)<0) 
     {
      Print("Error copying HighMA values");
      return(rates_total);
     }

   if(CopyBuffer(LowMAHandle,0,0,rates_total,LowMABuffer)<0) 
     {
      Print("Error copying LowMA values");
      return(rates_total);
     }

   int bars=BarsCalculated(HighMAHandle);
   bars=MathMax(bars,BarsCalculated(LowMAHandle));

   if(bars>=rates_total) 
     {

      int start=1;
      if(prev_calculated>0) 
        {
         start=prev_calculated-1;
        }
      for(int i=start; i<rates_total; i++) 
        {

         lastvalue=HiLoBuffer4[i-1];

         if(close[i]<LowMABuffer[i-1]) 
           {
            if(swing==1) 
              {
               lastvalue=HighMABuffer[i-1];
              }
            swing=-1;
           }
         else if(close[i]>HighMABuffer[i-1]) 
           {
            if(swing==-1) 
              {
               lastvalue=LowMABuffer[i-1];
              }
            swing=1;
           }

         if(swing==-1) 
           {
            HiLoBuffer1[i]=lastvalue;
            HiLoBuffer2[i]=lastvalue;
            HiLoBuffer3[i]=HighMABuffer[i-1];
            HiLoBuffer4[i]=HighMABuffer[i-1];
            HiLoColors[i]=1;
           }
         else if(swing==1) 
           {
            HiLoBuffer1[i]=lastvalue;
            HiLoBuffer2[i]=LowMABuffer[i-1];
            HiLoBuffer3[i]=lastvalue;
            HiLoBuffer4[i]=LowMABuffer[i-1];
            HiLoColors[i]=0;
           }
        }
     }
   return(rates_total);
  }

//+------------------------------------------------------------------+
