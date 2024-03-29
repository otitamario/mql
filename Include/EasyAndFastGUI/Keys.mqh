//+------------------------------------------------------------------+
//|                                                         Keys.mqh |
//|                        Copyright 2016, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#include <EasyAndFastGUI\KeyCodes.mqh>
//+------------------------------------------------------------------+
//| Class for working with the keyboard                              |
//+------------------------------------------------------------------+
class CKeys
  {
public:
                     CKeys(void);
                    ~CKeys(void);
   //--- Returns the character of the pressed key
   string            KeySymbol(const long key_code);
   //--- Returns the state of the Ctrl key
   bool              KeyCtrlState(void);
   //--- Возвращает состояние клавиши Shift
   bool              KeyShiftState(void);
  };
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CKeys::CKeys(void)
  {
  }
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CKeys::~CKeys(void)
  {
  }
//+------------------------------------------------------------------+
//| Returns the character of the pressed key                         |
//+------------------------------------------------------------------+
string CKeys::KeySymbol(const long key_code)
  {
   string key_symbol="";
//--- If it is necessary to enter a space (Space key)
   if(key_code==KEY_SPACE)
     {
      key_symbol=" ";
     }
//--- If it is necessary to enter (1) an alphabetic character, or (2) a numeric pad character, or (3) a special character
   else if((key_code>=KEY_A && key_code<=KEY_Z) ||
           (key_code>=KEY_0 && key_code<=KEY_9) ||
           (key_code>=KEY_SEMICOLON && key_code<=KEY_SINGLE_QUOTE))
     {
      key_symbol=::ShortToString(::TranslateKey((int)key_code));
     }
//--- Return the character
   return(key_symbol);
  }
//+------------------------------------------------------------------+
//| Returns the state of the Ctrl key                                |
//+------------------------------------------------------------------+
bool CKeys::KeyCtrlState(void)
  {
   return(::TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL)<0);
  }
//+------------------------------------------------------------------+
//| Возвращает состояние клавиши Shift                               |
//+------------------------------------------------------------------+
bool CKeys::KeyShiftState(void)
  {
   return(::TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT)<0);
  }
//+------------------------------------------------------------------+
