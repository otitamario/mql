//+------------------------------------------------------------------+
//|                                             Copyright, PipFinite |
//+------------------------------------------------------------------+
#property copyright     "PIPFINITE"
#property link          "http://www.pipfinite.com"
#property version       "1.00" 
#property strict
int shift = 1; //The shift used by this indicator
int handle_icustom;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   //Load EX5
   handle_icustom = iCustom  (
                              
                              NULL,                                  
                              0,                                     
                              "\\Market\\PipFinite Trend Pro MT5",//File Path of indicator   
                
                              //NEXT LINES WILL BE INDCATOR INPUTS                            
                              " ",
                              3,
                              2.00,
                              3000                                
                              //END FOR INPUTS
                                                                                   
                              );
                              
             
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---


      //Buy Signal (8)   
      //Sell Signal (9)
      //Uptrend (10)
      //Downtrend (11) 
      
      //TP1 Price (12)     
      //TP2 Price (13) 
      
      //TP1 Points (14)  
      //TP2 Points (15)
       
      //TP1 (16)
      //TP2 (17) 
      //EXIT Win (18)            
      //EXIT Loss (19)                  

      //TP1 Hit (20)             
      //TP2 Hit (21)  

      //TP1 Hit% (22)            
      //TP2 Hit% (23)                
      //EXIT Win% (24)             
      //EXIT Loss% (25) 
      
      //Signals (26)                
      //Wins (27)           
      //Loss (28) 
                     
      //Success Rate% (29)  
    
    
    
    
   /***Replace "Comment/Print" with your trade function***/  
        
   //Buy Signal              
   if( GetIndicatorValue(8) > 0 )   Comment("Buy Signal");   
   
   //Sell Signal
   if( GetIndicatorValue(9) > 0 )   Comment("Sell Signal");  


   //Sample Data             
   Print(DoubleToString (GetIndicatorValue(29),_Digits)+"Success Rate");   
    
            
  }
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Get Indicator Buffer Value                                       |
//+------------------------------------------------------------------+
double GetIndicatorValue(int buffer)
{
   if(shift < 0) return(NULL);  
   double Arr[1];
   if(CopyBuffer(handle_icustom,buffer,shift,1,Arr)>0) return(Arr[0]);
   return(NULL);   
}  
