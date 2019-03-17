//+------------------------------------------------------------------+
//|                                               b2zCalendarV01.mqh |
//|                                                 Mohammad Bazrkar |
//|                            https://www.mql5.com/en/users/mhdbzr/ |
//+------------------------------------------------------------------+
#property copyright "Mohammad Bazrkar"
#property link      "https://www.mql5.com/en/users/mhdbzr/"
//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
// #define MacrosHello   "Hello, world!"
// #define MacrosYear    2010
//+------------------------------------------------------------------+
//| DLL imports                                                      |
//+------------------------------------------------------------------+
// #import "user32.dll"
//   int      SendMessageA(int hWnd,int Msg,int wParam,int lParam);
// #import "my_expert.dll"
//   int      ExpertRecalculate(int wParam,int lParam);
// #import
//+------------------------------------------------------------------+
//| EX5 imports                                                      |
//+------------------------------------------------------------------+
// #import "stdlib.ex5"
//   string ErrorDescription(int error_code);
// #import
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
class B2ZCalendarChecker{
protected:
   int __b2z_pointer; // = 1;
   string __b2z_content; // = "";
   enum calType{
      INVESTING,
      BABYPIPS
   };
   enum NewsImpact{
      noImpact = 0, // holidays, ...
      lowImpact = 1,
      mediumImpact = 2, //moderate
      highImpact = 3
   };
   struct NewsItem{
      NewsImpact Impact;
      string Title, Slug, SymbolCode;
      datetime DT;
   };
   NewsItem __b2z_news[];
   //+------------------------------------------------------------------+
   calType __b2z_myCalType; // = INVESTING; // Calendar
   // ----
   void SetCalendarType(calType inType){
      __b2z_myCalType = inType;
      ArrayResize(__b2z_news,0,10);
   }
   //+------------------------------------------------------------------+
   bool checkNews(NewsItem &inNews[],int fromSec, int toSec, string inSym = NULL, NewsImpact inSens = noImpact){
      NewsItem passedNews, nextNews;
      passedNews.DT= D'1970.01.01 00:00:00';
      nextNews.DT=   D'1970.01.01 00:00:00';
      datetime refTime = D'1970.01.01 00:00:00';
      // ----
      if(__b2z_myCalType==INVESTING){
         refTime = TimeLocal();
         if(ArraySize(inNews)<1 || inNews[ArraySize(inNews)-1].DT<(refTime-fromSec)){
            getInvesting(inNews);
         }
      }else if(__b2z_myCalType==BABYPIPS){
         refTime = TimeGMT();
         if(ArraySize(inNews)<1 || inNews[ArraySize(inNews)-1].DT<(refTime-fromSec)){
            getBabyPips(inNews);
         }
      }
      getFirstNews(refTime,passedNews,nextNews,inNews , inSym ,inSens);
      int pSec = int(refTime - passedNews.DT);
      int nSec = int(nextNews.DT - refTime  );
      if(nSec<0){ //no next news in current day or week!
         nSec = INT_MAX;
      }
      if(LogAndPrint) Print( passedNews.DT," ",passedNews.SymbolCode," ",passedNews.Title," --- ",nextNews.DT," ",passedNews.SymbolCode," ",nextNews.Title);
      if(LogAndPrint) Print( "pSec:",pSec," nSec:",nSec );
      // ----
      return (pSec<fromSec || nSec<toSec);
   }
   //+------------------------------------------------------------------+
   bool Goto(string key){
      __b2z_pointer = StringFind(__b2z_content, key, __b2z_pointer) + StringLen(key);
      return (__b2z_pointer > StringLen(key));
   }
   //+------------------------------------------------------------------+
   string GetTo(string key){
      int s = __b2z_pointer;
      if(!Goto(key)){return NULL;}
      return StringSubstr(__b2z_content, s , __b2z_pointer - s - StringLen(key) );
   }
   //+------------------------------------------------------------------+
   void getBabyPips(NewsItem &inc[]){
      string cookie=NULL,headers; 
      char post[],result_char[]; 
      string myUrl="https://www.babypips.com/economic-calendar"; 
      ResetLastError(); 
      int timeout=120000;
      int res = WebRequest("GET",myUrl,cookie,NULL,timeout,post,0,result_char,headers); 
      if(LogAndPrint) Print("News updating from Babypips.com!");
      if(res!=200){return;}
      string myComment = "";
      __b2z_content = CharArrayToString(result_char);
      int fIndex = 8;
      fIndex = StringFind(__b2z_content, "<div data-react-class=\"Calendar\" data-react-props=\"");
      int eIndex = StringFind(__b2z_content, "\">", fIndex);
      __b2z_content = CharArrayToString(result_char,fIndex,eIndex-fIndex);
      StringReplace(__b2z_content, "&quot;" , "\"" );
      Goto("\"events\"");
      int nIndx = -1;
      while(Goto("guid")) // \": \" // ' ' not ' '--space
      {
         nIndx++;
         // ----
         __b2z_pointer = __b2z_pointer + 3;
         string slug = GetTo("\"");
         Goto("name");__b2z_pointer = __b2z_pointer + 3;
         string title = GetTo("\"");
         Goto("currency_code");__b2z_pointer = __b2z_pointer + 2; // maybe null for "opec report for oil" !
         string sym = GetTo(",");
         if(sym!="null"){
            sym=StringSubstr(sym,1,StringLen(sym)-2);
         }
         Goto("impact");__b2z_pointer = __b2z_pointer + 2; //": null,
         string vola = GetTo(",");
         if(vola!="null"){
            vola=StringSubstr(vola,1,StringLen(vola)-2);
         }
         Goto("starts_at");__b2z_pointer = __b2z_pointer + 3;
         string dt = GetTo("\""); // 2018-03-12T18:00:00.000Z //~GMTTime()
         StringReplace(dt,"-",".");
         dt = StringSubstr(dt,0,10)+" "+StringSubstr(dt,11,5);StringTrimRight(dt);
         // ----
         ArrayResize(inc,nIndx+1, 10);
         inc[nIndx].DT = StringToTime(dt);
         inc[nIndx].SymbolCode = sym;
         inc[nIndx].Impact = (vola == "high" ? highImpact : (vola=="med" ? mediumImpact : (vola=="low" ? lowImpact : noImpact ) ) ); // +++
         inc[nIndx].Slug = slug;
         inc[nIndx].Title = title;
      }
   }
   //+------------------------------------------------------------------+
   void getInvesting(NewsItem &inc[]){
      string cookie=NULL,headers; 
      char post[],result_char[]; 
      string myUrl="https://www.investing.com/economic-calendar/"; 
      ResetLastError(); 
      int timeout=120000;
      int res = WebRequest("GET",myUrl,cookie,NULL,timeout,post,0,result_char,headers); 
      if(LogAndPrint) Print("News updating from Investing.com!");
      if(res!=200){return;}
      string myComment = "";
      __b2z_content = CharArrayToString(result_char);
      int fIndex = 8;
      fIndex = StringFind(__b2z_content, "<table id=\"economicCalendarData\"");
      int eIndex = StringFind(__b2z_content, "</table>", fIndex);
      __b2z_content = CharArrayToString(result_char,fIndex,eIndex-fIndex);
      int nIndx = -1;
      while(Goto("eventRowId_"))
      {
         nIndx++;
         // ----
         Goto("data-event-datetime=\"");
         string dt = GetTo("\">"); // 2018/03/18 17:00:00 //~LocalTime()
         StringReplace(dt, "/", ".");
         if(StringLen(dt)>16){ dt = StringSubstr(dt,0,16);}
         Goto("</span>");
         string sym = GetTo("</td>");
         StringTrimLeft(sym);StringTrimRight(sym);
         Goto("title=\"");
         string vola = GetTo(" ");
         Goto("href=\"/economic-calendar/");
         string slug = GetTo("\" ");
         Goto(">");
         string title = GetTo("</a>");
         StringTrimLeft(title);StringTrimRight(title);
         while(StringFind(title,"  ")>0){
            StringReplace(title,"  "," ");
         }
         // ----
         ArrayResize(inc,nIndx+1, 10);
         inc[nIndx].DT = StringToTime(dt);
         inc[nIndx].SymbolCode = sym;
         inc[nIndx].Impact = (vola == "High" ? highImpact : (vola=="Moderate" ? mediumImpact : (vola=="Low" ? lowImpact : noImpact ) ) ); // +++
         inc[nIndx].Slug = slug;
         inc[nIndx].Title = title;
      }
   }
   //+------------------------------------------------------------------+
   void getFirstNews(datetime inTime, NewsItem &passed, NewsItem &next, NewsItem &inNews[] , string inSym = NULL ,NewsImpact mySens = noImpact){
      int max = ArraySize(inNews);
      int indx;
      int p=-1 , n=-1;
      for(indx=0; indx<max; indx++){
         if(inSym!=NULL && inNews[indx].SymbolCode != inSym){ continue; }
         if(inNews[indx].Impact < mySens ) { continue; }
         if(inNews[indx].DT <= inTime){ p=indx; }
         if(inNews[indx].DT >= inTime){ n=indx; break;}
      }
      if(n>-1){ next=   inNews[n]; }
      if(p>-1){ passed= inNews[p]; }
   }
   
//+-------------------+
//|  Public Functions |
//+-------------------+

public:
   bool LogAndPrint;
   //\\//\\//\\
   
   B2ZCalendarChecker(calType inType){
      __b2z_pointer = 1;
      __b2z_content = "";
      __b2z_myCalType = inType;
      LogAndPrint = false;
   }
   
   //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
   
   bool CheckNews(int pSec, int nSec, string symb=NULL, NewsImpact imp=noImpact){
      return checkNews(__b2z_news,
         pSec,nSec,symb,imp
      );
   }
   
   //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
   
   void GetFirstNews(NewsItem &passed, NewsItem &next, string inSym = NULL ,NewsImpact mySens = noImpact){
      datetime inTime = (__b2z_myCalType==INVESTING) ? TimeLocal() : TimeGMT();
      getFirstNews( inTime, passed, next, __b2z_news, inSym , mySens);
   }
   
   //\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\//\\
   
   void GetNewsByTime(NewsItem &passed, NewsItem &next, datetime inTime, string inSym = NULL ,NewsImpact mySens = noImpact){
      getFirstNews( inTime, passed, next, __b2z_news, inSym , mySens);
   }
   
   void Refresh(){
      ArrayResize(__b2z_news,0);
      // ----
      if(__b2z_myCalType==INVESTING){
            getInvesting(__b2z_news);
      }else if(__b2z_myCalType==BABYPIPS){
            getBabyPips(__b2z_news);
      }
   }
};