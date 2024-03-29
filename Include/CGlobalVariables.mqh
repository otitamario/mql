//+------------------------------------------------------------------+
//|                                             CGlobalVariables.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2016, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"


class CGlobalVariables{
   private:
      string m_common_prefix; // prefix of common variables
      string m_order_prefix; // prefix of order variables
      void DeleteAll(){
         GlobalVariablesDeleteAll(m_common_prefix);
         GlobalVariablesDeleteAll(m_order_prefix);         
      }
   public:
      // constructor
      void CGlobalVariables(string symbol="",int magic=0){
         Init(symbol,magic);
      }
      // destructor
      void ~CGlobalVariables(){
         Deinit();
      }
      void Init(string symbol,int magic){
         m_order_prefix="order_";
         m_common_prefix=MQLInfoString(MQL_PROGRAM_NAME)+"_"+symbol+"_"+IntegerToString(magic)+"_";
         if(MQLInfoInteger(MQL_TESTER)){
            m_order_prefix="tester_"+m_order_prefix;
            m_common_prefix="t_"+m_common_prefix;
            DeleteAll();
         }         
      }
      // for common variables
      bool Check(string name){
         return(GlobalVariableCheck(m_common_prefix+name));
      }
      void Set(string name,double value){
         GlobalVariableSet(m_common_prefix+name,value);      
      }      
      double Get(string name){
         return(GlobalVariableGet(m_common_prefix+name));
      } 
      void Delete(string name){
         GlobalVariableDel(m_common_prefix+name); 
      }
      // for order variables
      bool Check(ulong ticket,string name){
         return(GlobalVariableCheck(m_order_prefix+IntegerToString(ticket)+"_"+name));
      }
      void Set(ulong ticket,string name,double value){
         GlobalVariableSet(m_order_prefix+IntegerToString(ticket)+"_"+name,value);      
      }      
      double Get(ulong ticket,string name){
         return(GlobalVariableGet(m_order_prefix+IntegerToString(ticket)+"_"+name));
      } 
      void Delete(ulong ticket,string name){
         GlobalVariableDel(m_order_prefix+IntegerToString(ticket)+"_"+name); 
      }   
      void Deinit(){
         if(MQLInfoInteger(MQL_TESTER)){
            DeleteAll();
         }
      }
      void DeleteByPrefix(string prefix){
         GlobalVariablesDeleteAll(m_common_prefix+prefix);
      }
      string Prefix(){
         return(m_common_prefix);
      } 
      void Flush(){
         GlobalVariablesFlush();
      }
};
