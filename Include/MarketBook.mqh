//+------------------------------------------------------------------+
//|                                                   MarketBook.mqh |
//|                        Copyright 2015, MetaQuotes Software Corp. |
//|                                              http://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, MetaQuotes Software Corp."
#property link      "http://www.mql5.com"

#define LAST_ASK_INDEX 0
#define LAST_BID_INDEX m_depth_total-1
//+------------------------------------------------------------------+
//| Side of MarketBook.                                              |
//+------------------------------------------------------------------+
enum ENUM_MBOOK_SIDE
  {
   MBOOK_ASK,                    // Ask side
   MBOOK_BID                     // Bid (offer) side
  };
//+------------------------------------------------------------------+
//| Market Book info integer properties.                             |
//+------------------------------------------------------------------+
enum ENUM_MBOOK_INFO_INTEGER
  {
   MBOOK_BEST_ASK_INDEX,         // Best ask index
   MBOOK_BEST_BID_INDEX,         // Best bid index
   MBOOK_LAST_ASK_INDEX,         // Last (worst) ask index
   MBOOK_LAST_BID_INDEX,         // Last (worst) bid index
   MBOOK_DEPTH_ASK,              // Depth of ask side
   MBOOK_DEFTH_BID,              // Depth of bid side
   MBOOK_DEPTH_TOTAL             // Total depth
  };
//+------------------------------------------------------------------+
//| Market Book info double properties.                              |
//+------------------------------------------------------------------+
enum ENUM_MBOOK_INFO_DOUBLE
  {
   MBOOK_BEST_ASK_PRICE,         // Best ask price,
   MBOOK_BEST_BID_PRICE,         // Best bid price,
   MBOOK_LAST_ASK_PRICE,         // Last (worst) ask price, 
   MBOOK_LAST_BID_PRICE,         // Last (worst) bid price,
   MBOOK_AVERAGE_SPREAD          // Average spread for work time
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CMarketBook
  {
private:
   string            m_symbol;                 // Market Book symbol
   int               m_depth_total;            // Market depth total
   bool              m_available;              // True if market book available, otherwise false
   double            m_spread_sum;             // Accumulation spread;
   int               m_count_refresh;          // Count call CMarketBook::Refresh()
/* Indexes fields*/
   int               m_best_ask_index;         // Best ask index
   int               m_best_bid_index;         // Best bid index

   void              InitLocalVariables();
   void              SetBestAskAndBidIndex(void);
   bool              FindBestBid(void);
public:
   MqlBookInfo       MarketBook[];             // Array of market book
                     CMarketBook();
                     CMarketBook(string symbol);
   int               InfoGetInteger(ENUM_MBOOK_INFO_INTEGER property);
   double            InfoGetDouble(ENUM_MBOOK_INFO_DOUBLE property);
   void              Refresh(void);
   bool              IsAvailable(void);
   bool              SetMarketBookSymbol(string symbol);
   string            GetMarketBookSymbol(void);
   double            GetDeviationByVol(long vol,ENUM_MBOOK_SIDE side);
  };
//+------------------------------------------------------------------+
//| Default constructor.                                             |
//+------------------------------------------------------------------+
CMarketBook::CMarketBook(void)
  {
   InitLocalVariables();
   SetMarketBookSymbol(Symbol());
  }
//+------------------------------------------------------------------+
//| Create Market Book and set symbol for it.                        |
//+------------------------------------------------------------------+
CMarketBook::CMarketBook(string symbol)
  {
   InitLocalVariables();
   SetMarketBookSymbol(symbol);
  }
//+------------------------------------------------------------------+
//| Initialize local variables.                                      |
//+------------------------------------------------------------------+
CMarketBook::InitLocalVariables(void)
  {
//m_symbol = NULL;
//m_best_ask_index = -1;
//m_best_bid_index = -1;
  }
//+------------------------------------------------------------------+
//| Get symbol for market book.                                      |
//+------------------------------------------------------------------+
string CMarketBook::GetMarketBookSymbol(void)
  {
   return m_symbol;
  }
//+------------------------------------------------------------------+
//| Set symbol for market book.                                      |
//+------------------------------------------------------------------+
bool CMarketBook::SetMarketBookSymbol(string symbol)
  {
   bool isSelect=SymbolSelect(symbol,true);
   if(isSelect)
      m_symbol=symbol;
   else
     {
      if(!SymbolSelect(m_symbol,true) && SymbolSelect(Symbol(),true))
         m_symbol=Symbol();
     }
   return isSelect;
  }
//+------------------------------------------------------------------+
//| Refresh Market Book.                                             |
//+------------------------------------------------------------------+
void CMarketBook::Refresh(void)
  {
   m_available=MarketBookGet(m_symbol,MarketBook);
   m_depth_total=ArraySize(MarketBook);
   SetBestAskAndBidIndex();
   m_count_refresh++;
   m_spread_sum+=MarketBook[m_best_bid_index].price-MarketBook[m_best_ask_index].price;
  }
//+------------------------------------------------------------------+
//| Return true if market book is available, otherwise return false  |
//+------------------------------------------------------------------+
bool CMarketBook::IsAvailable(void)
  {
   return m_available;
  }
//+------------------------------------------------------------------+
//| Find best ask and bid indexes and set this indexes for           |
//| m_best_ask_index and m_best_bid field                            |
//+------------------------------------------------------------------+
void CMarketBook::SetBestAskAndBidIndex(void)
  {
   if(!FindBestBid())
     {
      //Find best ask by slow full search
      int bookSize=ArraySize(MarketBook);
      for(int i=0; i<bookSize; i++)
        {
         if((MarketBook[i].type==BOOK_TYPE_BUY) || (MarketBook[i].type==BOOK_TYPE_BUY_MARKET))
           {
            m_best_ask_index=i-1;
            FindBestBid();
            break;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Fast find best bid by best ask                                   |
//+------------------------------------------------------------------+
bool CMarketBook::FindBestBid(void)
  {
   m_best_bid_index=-1;
   int bestBid=m_best_ask_index+1;
   bool isBestBid=bestBid>=0 && (MarketBook[bestBid].type==BOOK_TYPE_BUY || 
                                 MarketBook[bestBid].type==BOOK_TYPE_BUY_MARKET);
   if(isBestBid)
     {
      m_best_bid_index=bestBid;
      return true;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Get integer property by ENUM_MBOOK_INFO_INTEGER modifier         |
//+------------------------------------------------------------------+
int CMarketBook::InfoGetInteger(ENUM_MBOOK_INFO_INTEGER property)
  {
   switch(property)
     {
      case MBOOK_BEST_ASK_INDEX:
         return m_best_ask_index;
      case MBOOK_BEST_BID_INDEX:
         return m_best_bid_index;
      case MBOOK_LAST_ASK_INDEX:
         return LAST_ASK_INDEX;
      case MBOOK_LAST_BID_INDEX:
         return LAST_BID_INDEX;
      case MBOOK_DEPTH_TOTAL:
         return m_depth_total;
      case MBOOK_DEFTH_BID:
         return (m_depth_total - m_best_bid_index);
      case MBOOK_DEPTH_ASK:
         return m_best_bid_index;
     }
   return 0;
  }
//+------------------------------------------------------------------+
//| Get double property by ENUM_MBOOK_INFO_DOUBLE modifier           |
//+------------------------------------------------------------------+
double CMarketBook::InfoGetDouble(ENUM_MBOOK_INFO_DOUBLE property)
  {
   switch(property)
     {
      case MBOOK_BEST_ASK_PRICE:
         return MarketBook[m_best_ask_index].price;
      case MBOOK_BEST_BID_PRICE:
         return MarketBook[m_best_bid_index].price;
      case MBOOK_LAST_ASK_PRICE:
         return MarketBook[LAST_ASK_INDEX].price;
      case MBOOK_LAST_BID_PRICE:
         return MarketBook[LAST_BID_INDEX].price;
      case MBOOK_AVERAGE_SPREAD:
         return (m_spread_sum/m_count_refresh);
     }
   return 0.0;
  }
//#define DEBUG
bool print_book=true;
#ifdef DEBUG
int total = InfoGetInteger(MBOOK_DEPTH_ASK);
for(int i = 0; i < total; i++)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   //+------------------------------------------------------------------+
   //|                                                                  |
   //+------------------------------------------------------------------+
  {
   string p = DoubleToString(MarketBook[i].price, 0);
   string v = (string)MarketBook[i].volume;
   printf((string)i+"   "+p+"   "+v+"   "+EnumToString(MarketBook[i].type));
  }
#endif
//+------------------------------------------------------------------+
//| Get deviation value by volume. Retun -1.0 if deviation is        |
//| infinity (insufficient liquidity)                                |
//+------------------------------------------------------------------+
double CMarketBook::GetDeviationByVol(long vol,ENUM_MBOOK_SIDE side)
  {
   if(vol==0)return -1;
   int best_ask = InfoGetInteger(MBOOK_BEST_ASK_INDEX);
   int last_ask = InfoGetInteger(MBOOK_LAST_ASK_INDEX);
   int best_bid = InfoGetInteger(MBOOK_BEST_BID_INDEX);
   int last_bid = InfoGetInteger(MBOOK_LAST_BID_INDEX);
   double avrg_price=0.0;
   long volume_exe=vol;
   if(side==MBOOK_ASK)
     {
      for(int i=best_ask; i>=last_ask; i--)
        {
         long currVol=MarketBook[i].volume<volume_exe ?
                      MarketBook[i].volume : volume_exe;
         avrg_price += currVol * MarketBook[i].price;
         volume_exe -= MarketBook[i].volume;
         if(volume_exe<=0)break;
        }
     }
   else
     {
      for(int i=best_bid; i<=last_bid; i++)
        {
         long currVol=MarketBook[i].volume<volume_exe ?
                      MarketBook[i].volume : volume_exe;
         avrg_price += currVol * MarketBook[i].price;
         volume_exe -= MarketBook[i].volume;
         if(volume_exe<=0)break;
        }
     }
   if(volume_exe>0)
      return -1.0;
   avrg_price/=(double)vol;
   double deviation=0.0;
   if(side==MBOOK_ASK)
      deviation=avrg_price-MarketBook[best_ask].price;
   else
      deviation=MarketBook[best_bid].price-avrg_price;
   return deviation;
  }
//+------------------------------------------------------------------+
