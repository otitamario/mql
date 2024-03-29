//+------------------------------------------------------------------+
//|                                                      News_RB.mq5 |
//|                        Copyright 2019, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright     "Copyright © 2016-2019,Rogério Borges"
#property link          "http://rogeriob28@gmail.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum news_answer
  {
   news_yes=0,//Yes
   news_no=1//No
  };
input news_answer NEWS_Active=news_yes;//Use News Filter ? 
input int NEWS_Check=1;//Check News Calendar for Changes Every : (hours)
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum news_relevance
  {
   nr_only=0,//Relevant Only
   nr_usd=1,//Relevant+USD News
   nr_all=2,//All News
   nr_spec=3,//Specific
   nr_cust=4//Relevant + Custom
  };
input news_relevance NEWS_Selection=nr_all;//Which news should be considered ? 
input string NEWS_Specific_A="USD";//(for specific selection only)Specific currency A 
input string NEWS_Specific_B="EUR";//(for specific selection only)Specific currency B
input string NEWS_Custom_Currency_A="JPY";//(for Relevant+Custom only)Custom Currency
input string NEWS_Custom_Currency_B="";//(for Relevant+Custom only)Custom Currency B
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum news_importance
  {
   ni_all=0,//Any
   ni_med_and_high=1,//Medium+High
   ni_high=2//High Only
  };
input news_importance NEWS_Impact=ni_all;//What should their importance be ?
input int NEWS_LI_Mins_Before=10;//Low Impact , halt minutes before news
input int NEWS_LI_Mins_After=10;//Low Impact , halt minutes after news
input int NEWS_MI_Mins_Before=30;//Medium Impact , halt minutes before news
input int NEWS_MI_Mins_After=30;//Medium Impact , halt minutes after news 
input int NEWS_HI_Mins_Before=60;//High Impact , halt minutes before news 
input int NEWS_HI_Mins_After=60;//High Impact , halt minutes after news 


bool CTRL_News_Active=false;
bool CTRL_News_Loaded=false;
int CTRL_News_Loaded_Blink=0;
bool CTRL_News_In_Zone=false;
int CTRL_News_In_Zone_Blink=0;
int CTRL_News_Now_Impact=0;
int CTRL_News_Next_Impact=0;
string NEWS_loaded_html="";
int EVENT_Total=0;
string EVENT_Name[];
datetime EVENT_Time[];
string EVENT_Time_String[];
int EVENT_Importance[];
string EVENT_Currency[];
datetime EVENT_Deflection_Start[];

datetime EVENT_Deflection_End[];

string EVENT_Type[];//Holiday - Tentative(no specific time) - Normal (with time+importance)
datetime EVENTS_Next_Load;
bool NEWS_Fully_Loaded=false;
//master switch in news or not 
bool NEWS_In_News=false;
bool NEWS_Just_Entered_Zone=false;
bool NEWS_Just_Entered_Tight_Zone=false;
bool NEWS_Stops_Tight=false;
string NEWS_Title,NEWS_Currency,NEWS_Timestamp,NEWS_Importance;
datetime NEWS_Time,NEWS_Time_Start,NEWS_Time_End,NEWS_Time_Tight;
int NEWS_Index;
datetime NEWS_Next_Check;
//variables for upcoming events display
bool NEWS_Upcoming_Exists=false;
string NEWS_Upcoming_Title="";
datetime NEWS_Upcoming_Zone_Start,NEWS_Upcoming_Event_Time,NEWS_Upcoming_Zone_End;
string NEWS_Upcoming_Currency,NEWS_Upcoming_Importance;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   R_Create_Deck();
   CTRL_News_Active=false;
   CTRL_News_Loaded=false;
   CTRL_News_Loaded_Blink=0;
   CTRL_News_In_Zone=false;
   CTRL_News_In_Zone_Blink=0;
   CTRL_News_Now_Impact=0;
   CTRL_News_Next_Impact=0;
   CTRL_News_Active=false;
   if(NEWS_Active==news_yes) CTRL_News_Active=true;
//variables for upcoming events display
   NEWS_Upcoming_Exists=false;
   NEWS_Upcoming_Title="";
//reset news triggers 
   NEWS_Fully_Loaded=false;
   NEWS_In_News=false;
   NEWS_Just_Entered_Zone=false;
   NEWS_Just_Entered_Tight_Zone=false;
   NEWS_Stops_Tight=false;
   EVENT_Total=0;
   int mi=MQLInfoInteger(MQL_TESTER);
   if(CTRL_News_Active==true && mi!=1)
     {
      NEWS_Initiate();
      int time_seconds=NEWS_Check*60*60;
      NEWS_Next_Check=TimeLocal();
      NEWS_Next_Check=NEWS_Next_Check+time_seconds;
      EventSetTimer(time_seconds);
      UpdateNewsDeck();
     }

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

//News filter    
   int mi=MQLInfoInteger(MQL_TESTER);
   if(CTRL_News_Active==true && NEWS_Fully_Loaded==true && mi!=1)
     {
      //and in news os off
      bool ckn=NEWS_In_News;

      //if in news 
      if(ckn==true)
        {
         //cancel just breach (hits only once)
         NEWS_Just_Entered_Zone=false;
         NEWS_Just_Entered_Tight_Zone=false;
         datetime pc_time_now=TimeLocal();
         //check 1 for tight zone 
         if(NEWS_Stops_Tight==false)
           {
            if(pc_time_now>=NEWS_Time_Tight)
              {
               NEWS_Stops_Tight=true;
               NEWS_Just_Entered_Tight_Zone=true;
              }
           }
         //check 2 for zone exit
         if(pc_time_now>=NEWS_Time_End)
           {
            NEWS_In_News=false;
            CTRL_News_In_Zone=NEWS_In_News;
            CTRL_News_Now_Impact=0;
            //remove this event 
            NEWS_Remove_Event(NEWS_Index);
            ObjectsDeleteAll(0,"NEWS_");
           }
        }
      //if in news ends here 
      //if not in news 
      if(ckn==false)
        {
         //scan 
         datetime pc_time_now=TimeLocal();
         int biggest_impact=0;
         int biggest_index=-1;
         for(int x=0;x<EVENT_Total;x++)
           {
            if(pc_time_now>=EVENT_Deflection_Start[x] && pc_time_now<EVENT_Deflection_End[x])
              {
               //if first
               if(biggest_index==-1)
                 {
                  biggest_impact=EVENT_Importance[x];
                  biggest_index=x;
                  //Alert("Possible active event "+EVENT_Name[x]);
                 }
               if(biggest_index!=-1)
                 {
                  if(EVENT_Importance[x]>biggest_impact)
                    {
                     biggest_impact=EVENT_Importance[x];
                     biggest_index=x;
                     //Alert("Possible active event "+EVENT_Name[x]);          
                    }
                 }
              }
           }
         //scan ends here 
         //if a news has been found 
         if(biggest_index!=-1)
           {
            NEWS_In_News=true;
            CTRL_News_In_Zone=true;
            //enable just entered
            NEWS_Just_Entered_Zone=true;
            NEWS_Just_Entered_Tight_Zone=false;
            NEWS_Stops_Tight=false;
            NEWS_Title=EVENT_Name[biggest_index];
            NEWS_Currency=EVENT_Currency[biggest_index];
            NEWS_Timestamp=EVENT_Time_String[biggest_index];
            NEWS_Index=biggest_index;
            if(EVENT_Importance[biggest_index]==1) NEWS_Importance="Low";
            if(EVENT_Importance[biggest_index]==2) NEWS_Importance="Medium";
            if(EVENT_Importance[biggest_index]==3) NEWS_Importance="High";
            CTRL_News_Now_Impact=EVENT_Importance[biggest_index];
            NEWS_Time=EVENT_Time[biggest_index];
            NEWS_Time_Start=EVENT_Deflection_Start[biggest_index];
            NEWS_Time_End=EVENT_Deflection_End[biggest_index];

           }
         //if a news has been found ends here 
        }
      //find upcoming event
      //if news state changed
      if((ckn==false && NEWS_In_News==true) || (ckn==true && NEWS_In_News==false))
        {
         NEWS_Find_Next_Event();
         UpdateNewsDeck();
        }
      //if news state changed ends here 
      //find upcoming event ends here 
     }
//News filter ends here   




  }
//+------------------------------------------------------------------+


//FUNCTION TO INITIATE NEWS SCAN
void NEWS_Initiate()
  {
   string lod_settings;
   NEWS_Fully_Loaded=false;
   CTRL_News_Loaded=false;
   lod_settings="https://sslecal2.forexprostools.com/?columns=exc_currency,exc_importance&countries=25,32,6,37,72,22,17,39,14,10,35,43,56,36,110,11,26,12,4,5&calType=week&timeZone=55&lang=1";
   bool loadhtml=false;
//Load Investing news source into html source
   loadhtml=LoadHtmlCode(lod_settings);
   bool loadnews=false;
   if(loadhtml==true) loadnews=NEWS_Read_Data();
   if(loadnews==true)
     {
      NEWS_Fully_Loaded=true;
      CTRL_News_Loaded=true;
      NEWS_Find_Next_Event();
     }
  }
//FUNCTION TO INITIATE NEWS SCAN ENDS HERE 
//FUNCTION TO READ NEWS SOURCE 
bool NEWS_Read_Data()
  {
   int gmt_offset=TimeGMTOffset();
//reset events holder 
/*
  ArrayResize(EVENT_Currency,1,0);
  ArrayResize(EVENT_Importance,1,0);
  ArrayResize(EVENT_Name,1,0);
  ArrayResize(EVENT_Type,1,0);
  ArrayResize(EVENT_Time,1,0);
  */
   bool returnio=false;
   int head_loc;
   string extract;
//find <tbody pageStartAt>
   head_loc=StringFind(NEWS_loaded_html,"<tbody pageStartAt>",0);
   extract=StringSubstr(NEWS_loaded_html,head_loc+18);
//find </tbody>
   head_loc=StringFind(extract,"</tbody>",0);
   int tott=head_loc;
   extract=StringSubstr(extract,0,tott);
//separate by days available 
//safety first ,replace all ~ with ! so that they dont interfere
   int reps=StringReplace(extract,"~","!");
//replace all Class the day with ~ 
   reps=StringReplace(extract,"class=\"theDay\"","~");
//Alert(IntegerToString(reps)+" Instances Replaced !");
   string to_split=extract;   // A string to split into substrings
   string sep="~";                // A separator as a character
   ushort u_sep;                  // The code of the separator character
   string DAYS_result[];               // An array to get strings
   u_sep=StringGetCharacter(sep,0);
   int k=StringSplit(to_split,u_sep,DAYS_result);
   int days_total=k;
//Print("Days Total = "+IntegerToString(days_total));
//0 index is useless contains nothing 
//1 index is the first day
//Loop in Days Found 
   string specimen;
   int find;
   int star;
   int length;
// string time_extract;
   string importance_extract;
   string timestamp_extract;
   string title_extract;
   string currency_extract;
//string hours;
//string minutes;
//datetime now;
//int second;
//int day_of_week;
//int day_of_year;
//int month; //day,hour; //,minute; year,
   MqlDateTime next;
//datetime projection;
   string events_result[];
   int events_total=0;
   for(int day_scan=1;day_scan<days_total;day_scan++)
     {
      extract=DAYS_result[day_scan];
      //replace all ~ instances 
      reps=StringReplace(extract,"~","!");
      //replace all eventrowids with ~ for split
      reps=StringReplace(extract,"<tr id=\"eventRowId_","~");
      //and split 
      k=StringSplit(extract,u_sep,events_result);
      events_total=k;
      //Loop in events found for the day 
      for(int sl=1;sl<events_total;sl++)
        {
         //TIME EXTRACT 
         specimen=events_result[sl];
         //get timestamp
         find=StringFind(specimen,"event_timestamp=",0);
         timestamp_extract=StringSubstr(specimen,find+17,19);
         //Print(timestamp_extract);
         //read type 
         //if tentative exists 
         int tentative=StringFind(specimen,"Tentative",0);
         int holiday=StringFind(specimen,"Holiday",0);
         int all_day=StringFind(specimen,"All Day",0);
         //currency
         find=StringFind(specimen,"class=\"flagCur\">",0);
         find=StringFind(specimen,"</td>",find);
         currency_extract=StringSubstr(specimen,find-3,3);
         //Alert("Time "+time_extract);
         //Importance Extract
         find=StringFind(specimen,"<td class=\"sentiment\"",0);
         star=find+29;
         find=StringFind(specimen,"Expected",0);
         length=find-star-1;
         importance_extract=StringSubstr(specimen,star,length);
         //Alert(importance_extract);
         //Title Extract
         find=StringFind(specimen,"<td class=\"left event\">",0);
         star=find+23;
         //try with nbsp
         find=StringFind(specimen,"&nbsp;",star);
         if(find==-1)
           {
            find=StringFind(specimen,"</td>",star);
           }
         length=find-star;
         title_extract=StringSubstr(specimen,star,length);
         //look in events for this capture 
         int event_exist=-1;
         for(int e=0;e<EVENT_Total;e++)
           {
            if(title_extract==EVENT_Name[e])
              {
               if(currency_extract==EVENT_Currency[e])
                 {
                  if(timestamp_extract==EVENT_Time_String[e])
                    {
                     event_exist=e;
                     break;
                    }
                 }
              }
           }
         //look in events for this capture ends here 
         //relevance finder  
         bool relevance_allow=false;
         if(NEWS_Selection==nr_all) relevance_allow=true;
         if(NEWS_Selection==nr_only)
           {
            //find currency in pair 
            string this_pair=Symbol();
            string tof=currency_extract;
            int in_pair;
            in_pair=StringFind(this_pair,tof,0);
            if(in_pair!=-1) relevance_allow=true;
           }
         if(NEWS_Selection==nr_usd)
           {
            //find currency in pair 
            string this_pair=Symbol();
            string tof=currency_extract;
            int in_pair;
            in_pair=StringFind(this_pair,tof,0);
            if(in_pair!=-1) relevance_allow=true;
            if(currency_extract=="USD") relevance_allow=true;
           }
         if(NEWS_Selection==nr_spec)
           {
            string testo=NEWS_Specific_A;
            testo=StringToUpper(testo);
            if(currency_extract==testo && testo!="") relevance_allow=true;
            testo=NEWS_Specific_B;
            testo=StringToUpper(testo);
            if(currency_extract==testo && testo!="") relevance_allow=true;
           }
         if(NEWS_Selection==nr_cust)
           {
            //find currency in pair 
            string this_pair=Symbol();
            string tof=currency_extract;
            int in_pair;
            in_pair=StringFind(this_pair,tof,0);
            if(in_pair!=-1) relevance_allow=true;
            if(currency_extract==NEWS_Custom_Currency_A&&NEWS_Custom_Currency_A!="") relevance_allow=true;
            if(currency_extract==NEWS_Custom_Currency_B&&NEWS_Custom_Currency_B!="") relevance_allow=true;
           }
         //relevance finder ends here
         //IF EVENT DOES NOT ALREADY EXIST 
         if(event_exist==-1 && relevance_allow==true)
           {
            EVENT_Total++;
            ArrayResize(EVENT_Currency,EVENT_Total,0);
            ArrayResize(EVENT_Importance,EVENT_Total,0);
            ArrayResize(EVENT_Name,EVENT_Total,0);
            ArrayResize(EVENT_Time,EVENT_Total,0);
            ArrayResize(EVENT_Type,EVENT_Total,0);
            ArrayResize(EVENT_Time_String,EVENT_Total,0);
            ArrayResize(EVENT_Deflection_Start,EVENT_Total,0);
            ArrayResize(EVENT_Deflection_End,EVENT_Total,0);
            EVENT_Name[EVENT_Total-1]=title_extract;
            EVENT_Importance[EVENT_Total-1]=0;
            if(importance_extract=="Low Volatility") EVENT_Importance[EVENT_Total-1]=1;
            if(importance_extract=="Moderate Volatility") EVENT_Importance[EVENT_Total-1]=2;
            if(importance_extract=="High Volatility") EVENT_Importance[EVENT_Total-1]=3;
            EVENT_Currency[EVENT_Total-1]=currency_extract;
            //normal 
            if(tentative==-1 && all_day==-1)
              {
               EVENT_Type[EVENT_Total-1]="Normal";
              }
            //holiday
            if(holiday!=-1 && all_day!=-1)
              {
               EVENT_Type[EVENT_Total-1]="Holiday";
              }
            //tentative
            if(tentative!=-1)
              {
               EVENT_Type[EVENT_Total-1]="Tentative";
              }
            //format time if not a holiday 
            if(EVENT_Type[EVENT_Total-1]!="Holiday")
              {
               EVENT_Time_String[EVENT_Total-1]=timestamp_extract;
               //YYYY-MM-DD HH:MM:SS
               MqlDateTime constructed_time;
               string take;
               //year
               take=StringSubstr(timestamp_extract,0,4);
               constructed_time.year=StringToInteger(take);
               //month 
               take=StringSubstr(timestamp_extract,5,2);
               constructed_time.mon=StringToInteger(take);
               //day
               take=StringSubstr(timestamp_extract,8,2);
               constructed_time.day=StringToInteger(take);
               //hour 
               take=StringSubstr(timestamp_extract,11,2);
               constructed_time.hour=StringToInteger(take);
               //minute
               take=StringSubstr(timestamp_extract,14,2);
               constructed_time.min=StringToInteger(take);
               //second 
               take=StringSubstr(timestamp_extract,17,2);
               constructed_time.sec=StringToInteger(take);
               EVENT_Time[EVENT_Total-1]=StructToTime(constructed_time);
               //print original time 
               //Print("OriginalTime : "+TimeToString(EVENT_Time[EVENT_Total-1],TIME_DATE|TIME_MINUTES|TIME_SECONDS));
               //shift to users time 
               EVENT_Time[EVENT_Total-1]=EVENT_Time[EVENT_Total-1]-gmt_offset;
               //Print("AdjustedTime : "+TimeToString(EVENT_Time[EVENT_Total-1],TIME_DATE|TIME_MINUTES|TIME_SECONDS));
              }
            //format time if not a holiday ends here        
            //create halt zones 
            int seconds_addi_before;
            int seconds_addi_after;
            //high importance
            if(EVENT_Importance[EVENT_Total-1]==3 && EVENT_Type[EVENT_Total-1]!="Holiday")
              {
               seconds_addi_before=NEWS_HI_Mins_Before*60;
               seconds_addi_after=NEWS_HI_Mins_After*60;
               EVENT_Deflection_Start[EVENT_Total-1]=EVENT_Time[EVENT_Total-1]-seconds_addi_before;
               EVENT_Deflection_End[EVENT_Total-1]=EVENT_Time[EVENT_Total-1]+seconds_addi_after;
              }
            //high importance ends here  
            //medium importance
            if(EVENT_Importance[EVENT_Total-1]==2 && EVENT_Type[EVENT_Total-1]!="Holiday")
              {
               seconds_addi_before=NEWS_MI_Mins_Before*60;
               seconds_addi_after=NEWS_MI_Mins_After*60;
               EVENT_Deflection_Start[EVENT_Total-1]=EVENT_Time[EVENT_Total-1]-seconds_addi_before;
               EVENT_Deflection_End[EVENT_Total-1]=EVENT_Time[EVENT_Total-1]+seconds_addi_after;
              }
            //medium importance ends here  
            //low importance
            if(EVENT_Importance[EVENT_Total-1]==1 && EVENT_Type[EVENT_Total-1]!="Holiday")
              {
               seconds_addi_before=NEWS_LI_Mins_Before*60;
               seconds_addi_after=NEWS_LI_Mins_After*60;
               EVENT_Deflection_Start[EVENT_Total-1]=EVENT_Time[EVENT_Total-1]-seconds_addi_before;
               EVENT_Deflection_End[EVENT_Total-1]=EVENT_Time[EVENT_Total-1]+seconds_addi_after;
              }
            //low importance ends here        
            //event cancellation 
            //1.if end zone has gone by 
            //2.if its a holiday
            //3.if its not as important as we expect
            if(EVENT_Type[EVENT_Total-1]=="Holiday" || TimeLocal()>EVENT_Deflection_End[EVENT_Total-1] || EVENT_Importance[EVENT_Total-1]<NEWS_Impact+1)
              {
               EVENT_Total--;
              }
            //event cancellation ends here       
            //create halt zones ends here 
           }
         //IF EVENT DOES NOT ALREADY EXIST ENDS HERE 
        }
      //Loop in events found for the day ends here         
     }
//Loop in Days Found ends here 
   if(EVENT_Total>0) returnio=true;

//separate by days available ends here 
   return(returnio);
  }
//FUNCTION TO READ NEWS SOURCE ENDS HERE 
//FUNCTION TO LOAD HTML 
bool LoadHtmlCode(string url)
  {
   bool returnio=false;
   string cookie=NULL,headers;
   char post[],result[];
   int res;
   string google_url=url;
   ResetLastError();
   int timeout=1000;
   res=WebRequest("GET",google_url,cookie,NULL,timeout,post,0,result,headers);
   if(res==-1)
     {
      Print("News Error : Add the adress https://sslecal2.forexprostools.com in the allowed URLs list of MetaTrader ");
      returnio=false;
     }
   else
     {
      int tit=ArraySize(result)-1;
      NEWS_loaded_html="";
      for(int xx=0;xx<=tit;xx++)
        {
         NEWS_loaded_html=NEWS_loaded_html+CharToString(result[xx]);
        }
      returnio=true;
     }
   return(returnio);
  }
//FUNCTION TO LOAD HTML ENDS HERE 
//FUNCTION TO FIND NEXT EVENT 
void NEWS_Find_Next_Event()
  {
//variables for upcoming events display
   NEWS_Upcoming_Exists=false;
   NEWS_Upcoming_Title="No Events";
   NEWS_Upcoming_Currency="";
   NEWS_Upcoming_Importance="";
   int biggest_impact=0;
   int shortest_distance=TimeLocal();
   int biggest_index=-1;
   int event_distance;
   datetime now_time=TimeLocal();
   for(int x=0;x<EVENT_Total;x++)
     {
      //if time is before event start time  
      if(now_time<EVENT_Deflection_Start[x])
        {
         //get timestamp distance
         event_distance=EVENT_Deflection_Start[x]-now_time;
         //1 shortest distance
         if(event_distance<=shortest_distance)
           {
            //2 biggest impact if times are the same 
            if(EVENT_Importance[x]>biggest_impact)
              {

               biggest_impact=EVENT_Importance[x];
               shortest_distance=event_distance;
               biggest_index=x;

              }
            //2 biggest impact if times are the same ends here 
           }
         //1 shortest distance ends here 
        }
      //if time is before event start time ends here
     }
//if upcoming event exists 
   if(biggest_index!=-1)
     {
      NEWS_Upcoming_Exists=true;
      NEWS_Upcoming_Title=EVENT_Name[biggest_index];
      NEWS_Upcoming_Zone_Start=EVENT_Deflection_Start[biggest_index];
      NEWS_Upcoming_Event_Time=EVENT_Time[biggest_index];
      NEWS_Upcoming_Zone_End=EVENT_Deflection_End[biggest_index];
      NEWS_Upcoming_Currency=EVENT_Currency[biggest_index];
      if(EVENT_Importance[biggest_index]==1) NEWS_Upcoming_Importance="Low";
      if(EVENT_Importance[biggest_index]==2) NEWS_Upcoming_Importance="Medium";
      if(EVENT_Importance[biggest_index]==3) NEWS_Upcoming_Importance="High";
      CTRL_News_Next_Impact=EVENT_Importance[biggest_index];
     }
//if upcoming event exists ends here
  }
//FUNCTION TO FIND NEXT EVENT ENDS HERE 
//FUNCTION TO REMOVE EVENT 
void NEWS_Remove_Event(int index)
  {
   EVENT_Name[index]=EVENT_Name[EVENT_Total-1];
   EVENT_Time[index]=EVENT_Time[EVENT_Total-1];
   EVENT_Time_String[index]=EVENT_Time_String[EVENT_Total-1];
   EVENT_Importance[index]=EVENT_Importance[EVENT_Total-1];
   EVENT_Currency[index]=EVENT_Currency[EVENT_Total-1];
   EVENT_Deflection_Start[index]=EVENT_Deflection_Start[EVENT_Total-1];
   EVENT_Deflection_End[index]=EVENT_Deflection_End[EVENT_Total-1];
   EVENT_Type[index]=EVENT_Type[EVENT_Total-1];
   EVENT_Total--;
  }
//FUNCTION TO REMOVE EVENT ENDS HERE 

//FUNCTION TO UPDATE NEWS DECK 
void UpdateNewsDeck()
  {
   string text_to_send;
//in news
   text_to_send="In News Zone Now -> No";
   if(CTRL_News_In_Zone==true) text_to_send="In News Zone Now -> Yes";
   ObjectSetString(0,"ROG_In_News",OBJPROP_TEXT,text_to_send);
//title 
   text_to_send="no event...";
   if(CTRL_News_In_Zone==true)
     {
      text_to_send=NEWS_Currency+" "+NEWS_Importance+" "+NEWS_Title;
     }
   ObjectSetString(0,"ROG_News_Current",OBJPROP_TEXT,"Active News : "+text_to_send);
//event time
   text_to_send="...";
   if(CTRL_News_In_Zone==true)
     {
      text_to_send=TimeToString(NEWS_Time,TIME_DATE|TIME_MINUTES);
     }
   ObjectSetString(0,"ROG_News_Current_Time",OBJPROP_TEXT,"Active News Time : "+text_to_send);
//upcoming 
//titile
   text_to_send="no event...";
   if(NEWS_Upcoming_Exists==true && CTRL_News_Active==true)
     {
      text_to_send=NEWS_Upcoming_Currency+" "+NEWS_Upcoming_Importance+" "+NEWS_Upcoming_Title;
     }
   ObjectSetString(0,"ROG_News_Next",OBJPROP_TEXT,"Next News : "+text_to_send);
//time 
   text_to_send="...";
   if(NEWS_Upcoming_Exists==true && CTRL_News_Active==true)
     {
      text_to_send=TimeToString(NEWS_Upcoming_Event_Time,TIME_DATE|TIME_MINUTES);
     }
   ObjectSetString(0,"ROG_News_Next_Time",OBJPROP_TEXT,"Next At: "+text_to_send);
  }
//ROGERIO CREATE DECK 
void R_Create_Deck()
  {
   string objna;
   bool obji;
   int nx=10;
   int ny=10;
   int ns=20;
   int nf=8;
   color col=clrOrange;
   objna="ROG_gap4";
   ObjectDelete(0,objna);
   obji=ObjectCreate(0,objna,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,objna,OBJPROP_XDISTANCE,nx);
   ObjectSetInteger(0,objna,OBJPROP_YDISTANCE,ny);
   ObjectSetInteger(0,objna,OBJPROP_FONTSIZE,nf);
   ObjectSetInteger(0,objna,OBJPROP_COLOR,col);
   ObjectSetString(0,objna,OBJPROP_TEXT,"-----------------------------");
   ny=ny+ns;
//news flash
   objna="ROG_In_News";
   ObjectDelete(0,objna);
   obji=ObjectCreate(0,objna,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,objna,OBJPROP_XDISTANCE,nx);
   ObjectSetInteger(0,objna,OBJPROP_YDISTANCE,ny);
   ObjectSetInteger(0,objna,OBJPROP_FONTSIZE,nf);
   ObjectSetInteger(0,objna,OBJPROP_COLOR,col);
   ObjectSetString(0,objna,OBJPROP_TEXT,"In News Zone : ");
   ny=ny+ns;
//news current
   objna="ROG_News_Current";
   ObjectDelete(0,objna);
   obji=ObjectCreate(0,objna,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,objna,OBJPROP_XDISTANCE,nx);
   ObjectSetInteger(0,objna,OBJPROP_YDISTANCE,ny);
   ObjectSetInteger(0,objna,OBJPROP_FONTSIZE,nf);
   ObjectSetInteger(0,objna,OBJPROP_COLOR,col);
   ObjectSetString(0,objna,OBJPROP_TEXT,"News Current : ");
   ny=ny+ns;
//news current time
   objna="ROG_News_Current_Time";
   ObjectDelete(0,objna);
   obji=ObjectCreate(0,objna,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,objna,OBJPROP_XDISTANCE,nx);
   ObjectSetInteger(0,objna,OBJPROP_YDISTANCE,ny);
   ObjectSetInteger(0,objna,OBJPROP_FONTSIZE,nf);
   ObjectSetInteger(0,objna,OBJPROP_COLOR,col);
   ObjectSetString(0,objna,OBJPROP_TEXT,"Time: ");
   ny=ny+ns;
   objna="ROG_gap5";
   ObjectDelete(0,objna);
   obji=ObjectCreate(0,objna,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,objna,OBJPROP_XDISTANCE,nx);
   ObjectSetInteger(0,objna,OBJPROP_YDISTANCE,ny);
   ObjectSetInteger(0,objna,OBJPROP_FONTSIZE,nf);
   ObjectSetInteger(0,objna,OBJPROP_COLOR,col);
   ObjectSetString(0,objna,OBJPROP_TEXT,"-----------------------------");
   ny=ny+ns;
//news next
   objna="ROG_News_Next";
   ObjectDelete(0,objna);
   obji=ObjectCreate(0,objna,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,objna,OBJPROP_XDISTANCE,nx);
   ObjectSetInteger(0,objna,OBJPROP_YDISTANCE,ny);
   ObjectSetInteger(0,objna,OBJPROP_FONTSIZE,nf);
   ObjectSetInteger(0,objna,OBJPROP_COLOR,col);
   ObjectSetString(0,objna,OBJPROP_TEXT,"News Next : ");
   ny=ny+ns;
//news Next time
   objna="ROG_News_Next_Time";
   ObjectDelete(0,objna);
   obji=ObjectCreate(0,objna,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,objna,OBJPROP_XDISTANCE,nx);
   ObjectSetInteger(0,objna,OBJPROP_YDISTANCE,ny);
   ObjectSetInteger(0,objna,OBJPROP_FONTSIZE,nf);
   ObjectSetInteger(0,objna,OBJPROP_COLOR,col);
   ObjectSetString(0,objna,OBJPROP_TEXT,"Time: ");
   ny=ny+ns;
   objna="ROG_gap6";
   ObjectDelete(0,objna);
   obji=ObjectCreate(0,objna,OBJ_LABEL,0,0,0);
   ObjectSetInteger(0,objna,OBJPROP_XDISTANCE,nx);
   ObjectSetInteger(0,objna,OBJPROP_YDISTANCE,ny);
   ObjectSetInteger(0,objna,OBJPROP_FONTSIZE,nf);
   ObjectSetInteger(0,objna,OBJPROP_COLOR,col);
   ObjectSetString(0,objna,OBJPROP_TEXT,"-----------------------------");
   ny=ny+ns;
   UpdateNewsDeck();
  }
//ROGERIO CREATE DECK ENDS HErE 

//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
//Call news initiate and set timer for x hours to be rechecked
   if(CTRL_News_Active==true)
     {
      datetime time_now=TimeLocal();
      if(time_now>=NEWS_Next_Check)
        {
         NEWS_Initiate();
         int time_seconds=NEWS_Check*60*60;
         NEWS_Next_Check=TimeLocal();
         NEWS_Next_Check=NEWS_Next_Check+time_seconds;
        }
     }
  }
//+------------------------------------------------------------------+
