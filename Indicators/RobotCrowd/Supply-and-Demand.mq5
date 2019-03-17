//+------------------------------------------------------------------+
//|                                            supply_and_demand.mq5 |
//|                                                Antonio Guglielmi |
//|             RobotCrowd - Crowdsourcing para trading automatizado |
//|                                    https://www.robotcrowd.com.br |
//|                                                                  |
//| Este indicador eh uma conversao do shved_supply_and_demand.mq4   |
//| originalmente desenvolvido para o MetaTrader4 e disponivel na    |
//| comunidade MQL5.                                                 |
//+------------------------------------------------------------------+
//   Copyright 2017 Antonio Guglielmi - RobotCrowd
//
//   Licensed under the Apache License, Version 2.0 (the "License");
//   you may not use this file except in compliance with the License.
//   You may obtain a copy of the License at
//
//       http://www.apache.org/licenses/LICENSE-2.0
//
//   Unless required by applicable law or agreed to in writing, software
//   distributed under the License is distributed on an "AS IS" BASIS,
//   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//   See the License for the specific language governing permissions and
//   limitations under the License.

#property copyright     "Antonio Guglielmi - RobotCrowd"
#property link          "https://www.robotcrowd.com.br"
#property version       "1.00"
#property description   "Suply and Demand - baseado no indicador shved_supply_and_demand"
#property description   "  "
#property description   "Este indicador e distribuido gratuitamente para membros da comunidade RobotCrowd."
#property description   "A utilizacao em contas reais e de inteira responsabilidade do usuario e o site RobotCrowd nao se"
#property description   "responsabiliza por eventuais perdas decorrentes da utilizacao de qualquer um dos robos."
#property description   "  "
#property description   "RobotCrowd - Crowdsourcing para trading automatizado"


#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   4

#property indicator_color1 Red
#property indicator_color2 Red
#property indicator_color3 DodgerBlue
#property indicator_color4 DodgerBlue

input int BackLimit=1000;

input string pus1="/////////////////////////////////////////////////";
input bool zone_show_weak=true;           
input bool zone_show_untested = true;     
input bool zone_show_turncoat = false;    
input double zone_fuzzfactor=0.75;

input string pus2="/////////////////////////////////////////////////";
input bool fractals_show=false;
input double fractal_fast_factor = 3.0;
input double fractal_slow_factor = 6.0;
input bool SetGlobals=true;

input string pus3="/////////////////////////////////////////////////";
input bool zone_solid=true;
input int zone_linewidth=1;
input int zone_style=0;
input bool zone_show_info=true;
input int zone_label_shift=4;
input bool zone_merge=true;
input bool zone_extend=true;

input string pus4="/////////////////////////////////////////////////";
input bool zone_show_alerts  = false;
input bool zone_alert_popups = true;
input bool zone_alert_sounds = true;
input int zone_alert_waitseconds=300;

input string pus5="/////////////////////////////////////////////////";
input int Text_size=8;
input string Text_font = "Courier New";
input color Text_color = Yellow;
input string sup_name = "Sup";
input string res_name = "Res";
input string test_name= "Retests";
input color color_support_weak     = DarkSlateGray;
input color color_support_untested = SeaGreen;
input color color_support_verified = Green;
input color color_support_proven   = LimeGreen;
input color color_support_turncoat = OliveDrab;
input color color_resist_weak      = Indigo;
input color color_resist_untested  = Orchid;
input color color_resist_verified  = Crimson;
input color color_resist_proven    = Red;
input color color_resist_turncoat  = DarkOrange;

double FastDnPts[],FastUpPts[];
double SlowDnPts[],SlowUpPts[];

double zone_hi[1000],zone_lo[1000];
int    zone_start[1000],zone_hits[1000],zone_type[1000],zone_strength[1000],zone_count=0;
bool   zone_turn[1000];

#define ZONE_SUPPORT 1
#define ZONE_RESIST  2

#define ZONE_WEAK      0
#define ZONE_TURNCOAT  1
#define ZONE_UNTESTED  2
#define ZONE_VERIFIED  3
#define ZONE_PROVEN    4

#define UP_POINT 1
#define DN_POINT -1

int time_offset=0;

double ner_lo_zone_P1[];
double ner_lo_zone_P2[];
double ner_hi_zone_P1[];
double ner_hi_zone_P2[];


int atrHandle;
double atrVal[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit() 
  {
   //IndicatorBuffers(4);

   SetIndexBuffer(0,SlowDnPts);
   SetIndexBuffer(1,SlowUpPts);
   SetIndexBuffer(2,FastDnPts);
   SetIndexBuffer(3,FastUpPts);
   if(fractals_show==true)
     {
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_ARROW);
      PlotIndexSetInteger(0, PLOT_ARROW, 218);
      PlotIndexSetInteger(1, PLOT_ARROW, 217);
      PlotIndexSetInteger(2, PLOT_ARROW, 217);
      PlotIndexSetInteger(3, PLOT_ARROW, 217);
     }
   else
     {
      PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
      PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
     }

   SetIndexBuffer(4,ner_hi_zone_P1);
   SetIndexBuffer(5,ner_hi_zone_P2);
   SetIndexBuffer(6,ner_lo_zone_P1);
   SetIndexBuffer(7,ner_lo_zone_P2);

   PlotIndexSetInteger(4, PLOT_DRAW_TYPE, DRAW_NONE);
   PlotIndexSetInteger(5, PLOT_DRAW_TYPE, DRAW_NONE);
   PlotIndexSetInteger(6, PLOT_DRAW_TYPE, DRAW_NONE);
   PlotIndexSetInteger(7, PLOT_DRAW_TYPE, DRAW_NONE);

   PlotIndexSetString(4, PLOT_LABEL, "ner up zone P1");
   PlotIndexSetString(5, PLOT_LABEL, "ner up zone P2");
   PlotIndexSetString(6, PLOT_LABEL, "ner dn zone P1");
   PlotIndexSetString(7, PLOT_LABEL, "ner dn zone P2");

   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);

   atrHandle = iATR(_Symbol, _Period, 7);
   if (atrHandle < 0) {
      Print("Erro criando indicador ATR");
   }
   
   ArraySetAsSeries(atrVal, true);

   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   DeleteZones();
   DeleteGlobalVars();
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
   
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   
   if(NewBar()==true)
     {
      int old_zone_count=zone_count;

      FastFractals(time, open, high, low, close);
      SlowFractals(time, open, high, low, close);
      DeleteZones();
      FindZones(time, open, high, low, close);
      DrawZones(time, open, high, low, close);
      if(zone_count<old_zone_count)
         DeleteOldGlobalVars(old_zone_count);
     }

   if(zone_show_info==true)
     {
      for(int i=0; i<zone_count; i++)
        {
         string lbl;
         if(zone_strength[i]==ZONE_PROVEN)
            lbl="Proven";
         else if(zone_strength[i]==ZONE_VERIFIED)
            lbl="Verified";
         else if(zone_strength[i]==ZONE_UNTESTED)
            lbl="Untested";
         else if(zone_strength[i]==ZONE_TURNCOAT)
            lbl="Turncoat";
         else
            lbl="Weak";

         if(zone_type[i]==ZONE_SUPPORT)
            lbl=lbl+" "+sup_name;
         else
            lbl=lbl+" "+res_name;

         if(zone_hits[i]>0 && zone_strength[i]>ZONE_UNTESTED)
           {
            if(zone_hits[i]==1)
               lbl=lbl+", "+test_name+"="+zone_hits[i];
            else
               lbl=lbl+", "+test_name+"="+zone_hits[i];
           }

         int adjust_hpos;
         int wbpc=ChartGetInteger(0, CHART_VISIBLE_BARS, 0);
         //int k=Period()*60+(20+StringLen(lbl));
         int k=PeriodSeconds()+(20+StringLen(lbl));

         if(wbpc<80)
            adjust_hpos=time[0]+k*4;
         else if(wbpc<125)
            adjust_hpos=time[0]+k*8;
         else if(wbpc<250)
            adjust_hpos=time[0]+k*15;
         else if(wbpc<480)
            adjust_hpos=time[0]+k*29;
         else if(wbpc<950)
            adjust_hpos=time[0]+k*58;
         else
            adjust_hpos=time[0]+k*115;

         //

         int shift=k*zone_label_shift;
         double vpos=zone_hi[i]-(zone_hi[i]-zone_lo[i])/2;

         if(zone_strength[i]==ZONE_WEAK && zone_show_weak==false)
            continue;
         if(zone_strength[i]==ZONE_UNTESTED && zone_show_untested==false)
            continue;
         if(zone_strength[i]==ZONE_TURNCOAT && zone_show_turncoat==false)
            continue;

         string s="SSSR#"+i+"LBL";
         ObjectSetInteger(0, s, OBJPROP_ANCHOR, ANCHOR_RIGHT_UPPER);
         ObjectCreate(0, s, OBJ_TEXT, 0, adjust_hpos+shift, vpos);
         ObjectSetString(0, s, OBJPROP_TEXT, StringRightPad(lbl,36," ")); //, Text_size, Text_font, Text_color);
         ObjectSetInteger(0, s, OBJPROP_FONTSIZE, Text_size);
         ObjectSetString(0, s, OBJPROP_FONT, Text_font);
         ObjectSetInteger(0, s, OBJPROP_COLOR, Text_color);
        }
     }

   CheckAlerts(time, open, high, low, close);

   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckAlerts(const datetime &Time[], const double &Open[], const double &High[], const double &Low[], const double &Close[])
  {
   static int lastalert=0;

   if(zone_show_alerts==false)
      return;

   if(Time[0]-lastalert>zone_alert_waitseconds)
      if(CheckEntryAlerts(Time, Open, High, Low, Close)==true)
         lastalert=Time[0];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CheckEntryAlerts(const datetime &Time[], const double &Open[], const double &High[], const double &Low[], const double &Close[])
  {
// check for entries
   for(int i=0; i<zone_count; i++)
     {
      if(Close[0]>=zone_lo[i] && Close[0]<zone_hi[i])
        {
         if(zone_show_alerts==true)
           {
            if(zone_alert_popups==true)
              {
               if(zone_type[i]==ZONE_SUPPORT)
                  Alert(_Symbol+TimeFrameToString(Period())+": Support Zone Entered");
               else
                  Alert(_Symbol+TimeFrameToString(Period())+": Resistance Zone Entered");
              }

            if(zone_alert_sounds==true)
               PlaySound("alert_wav");
           }

         return(true);
        }
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteGlobalVars()
  {
   if(SetGlobals==false)
      return;

   GlobalVariableDel("SSSR_Count_"+_Symbol+(PeriodSeconds()/60));
   GlobalVariableDel("SSSR_Updated_"+_Symbol+(PeriodSeconds()/60));

   int old_count=zone_count;
   zone_count=0;
   DeleteOldGlobalVars(old_count);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteOldGlobalVars(int old_count)
  {
   if(SetGlobals==false)
      return;

   for(int i=zone_count; i<old_count; i++)
     {
      GlobalVariableDel("SSSR_HI_"+_Symbol+(PeriodSeconds()/60)+i);
      GlobalVariableDel("SSSR_LO_"+_Symbol+(PeriodSeconds()/60)+i);
      GlobalVariableDel("SSSR_HITS_"+_Symbol+(PeriodSeconds()/60)+i);
      GlobalVariableDel("SSSR_STRENGTH_"+_Symbol+(PeriodSeconds()/60)+i);
      GlobalVariableDel("SSSR_AGE_"+_Symbol+(PeriodSeconds()/60)+i);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FindZones(const datetime &Time[], const double &Open[], const double &High[], const double &Low[], const double &Close[])
  {
   int i,j,shift,bustcount=0,testcount=0;
   double hival,loval;
   bool turned=false,hasturned=false;

   double temp_hi[1000],temp_lo[1000];
   int    temp_start[1000],temp_hits[1000],temp_strength[1000],temp_count=0;
   bool   temp_turn[1000],temp_merge[1000];
   int merge1[1000],merge2[1000],merge_count=0;

// iterate through zones from oldest to youngest (ignore recent 5 bars),
// finding those that have survived through to the present___
   for(shift=MathMin(Bars(_Symbol, _Period)-1,BackLimit); shift>5; shift--)
     {
     
      if (CopyBuffer(atrHandle, 0, 0, shift + 1, atrVal) < 0) {
         Print("Erro copiando buffer do ATR: ", GetLastError());
         ResetLastError();
         return;
      }
      
      double atr= atrVal[shift];
      double fu = atr/2 * zone_fuzzfactor;
      bool isWeak;
      bool touchOk= false;
      bool isBust = false;

      if(FastUpPts[shift]>0.001)
        {
         // a zigzag high point
         isWeak=true;
         if(SlowUpPts[shift]>0.001)
            isWeak=false;

         hival=High[shift];
         if(zone_extend==true)
            hival+=fu;

         loval=MathMax(MathMin(Close[shift],High[shift]-fu),High[shift]-fu*2);
         turned=false;
         hasturned=false;
         isBust=false;

         bustcount = 0;
         testcount = 0;

         for(i=shift-1; i>=0; i--)
           {
            if((turned==false && FastUpPts[i]>=loval && FastUpPts[i]<=hival) || 
               (turned==true && FastDnPts[i]<=hival && FastDnPts[i]>=loval))
              {
               // Potential touch, just make sure its been 10+candles since the prev one
               touchOk=true;
               for(j=i+1; j<i+11; j++)
                 {
                  if((turned==false && FastUpPts[j]>=loval && FastUpPts[j]<=hival) || 
                     (turned==true && FastDnPts[j]<=hival && FastDnPts[j]>=loval))
                    {
                     touchOk=false;
                     break;
                    }
                 }

               if(touchOk==true)
                 {
                  // we have a touch_  If its been busted once, remove bustcount
                  // as we know this level is still valid & has just switched sides
                  bustcount=0;
                  testcount++;
                 }
              }

            if((turned==false && High[i]>hival) || 
               (turned==true && Low[i]<loval))
              {
               // this level has been busted at least once
               bustcount++;

               if(bustcount>1 || isWeak==true)
                 {
                  // busted twice or more
                  isBust=true;
                  break;
                 }

               if(turned == true)
                  turned = false;
               else if(turned==false)
                  turned=true;

               hasturned=true;

               // forget previous hits
               testcount=0;
              }
           }

         if(isBust==false)
           {
            // level is still valid, add to our list
            temp_hi[temp_count] = hival;
            temp_lo[temp_count] = loval;
            temp_turn[temp_count] = hasturned;
            temp_hits[temp_count] = testcount;
            temp_start[temp_count] = shift;
            temp_merge[temp_count] = false;

            if(testcount>3)
               temp_strength[temp_count]=ZONE_PROVEN;
            else if(testcount>0)
               temp_strength[temp_count]=ZONE_VERIFIED;
            else if(hasturned==true)
               temp_strength[temp_count]=ZONE_TURNCOAT;
            else if(isWeak==false)
               temp_strength[temp_count]=ZONE_UNTESTED;
            else
               temp_strength[temp_count]=ZONE_WEAK;

            temp_count++;
           }
        }
      else if(FastDnPts[shift]>0.001)
        {
         // a zigzag low point
         isWeak=true;
         if(SlowDnPts[shift]>0.001)
            isWeak=false;

         loval=Low[shift];
         if(zone_extend==true)
            loval-=fu;

         hival=MathMin(MathMax(Close[shift],Low[shift]+fu),Low[shift]+fu*2);
         turned=false;
         hasturned=false;

         bustcount = 0;
         testcount = 0;
         isBust=false;

         for(i=shift-1; i>=0; i--)
           {
            if((turned==true && FastUpPts[i]>=loval && FastUpPts[i]<=hival) || 
               (turned==false && FastDnPts[i]<=hival && FastDnPts[i]>=loval))
              {
               // Potential touch, just make sure its been 10+candles since the prev one
               touchOk=true;
               for(j=i+1; j<i+11; j++)
                 {
                  if((turned==true && FastUpPts[j]>=loval && FastUpPts[j]<=hival) || 
                     (turned==false && FastDnPts[j]<=hival && FastDnPts[j]>=loval))
                    {
                     touchOk=false;
                     break;
                    }
                 }

               if(touchOk==true)
                 {
                  // we have a touch_  If its been busted once, remove bustcount
                  // as we know this level is still valid & has just switched sides
                  bustcount=0;
                  testcount++;
                 }
              }

            if((turned==true && High[i]>hival) || 
               (turned==false && Low[i]<loval))
              {
               // this level has been busted at least once
               bustcount++;

               if(bustcount>1 || isWeak==true)
                 {
                  // busted twice or more
                  isBust=true;
                  break;
                 }

               if(turned == true)
                  turned = false;
               else if(turned==false)
                  turned=true;

               hasturned=true;

               // forget previous hits
               testcount=0;
              }
           }

         if(isBust==false)
           {
            // level is still valid, add to our list
            temp_hi[temp_count] = hival;
            temp_lo[temp_count] = loval;
            temp_turn[temp_count] = hasturned;
            temp_hits[temp_count] = testcount;
            temp_start[temp_count] = shift;
            temp_merge[temp_count] = false;

            if(testcount>3)
               temp_strength[temp_count]=ZONE_PROVEN;
            else if(testcount>0)
               temp_strength[temp_count]=ZONE_VERIFIED;
            else if(hasturned==true)
               temp_strength[temp_count]=ZONE_TURNCOAT;
            else if(isWeak==false)
               temp_strength[temp_count]=ZONE_UNTESTED;
            else
               temp_strength[temp_count]=ZONE_WEAK;

            temp_count++;
           }
        }
     }

// look for overlapping zones___
   if(zone_merge==true)
     {
      merge_count=1;
      int iterations=0;
      while(merge_count>0 && iterations<3)
        {
         merge_count=0;
         iterations++;

         for(i=0; i<temp_count; i++)
            temp_merge[i]=false;

         for(i=0; i<temp_count-1; i++)
           {
            if(temp_hits[i]==-1 || temp_merge[j]==true)
               continue;

            for(j=i+1; j<temp_count; j++)
              {
               if(temp_hits[j]==-1 || temp_merge[j]==true)
                  continue;

               if((temp_hi[i]>=temp_lo[j] && temp_hi[i]<=temp_hi[j]) || 
                  (temp_lo[i] <= temp_hi[j] && temp_lo[i] >= temp_lo[j]) ||
                  (temp_hi[j] >= temp_lo[i] && temp_hi[j] <= temp_hi[i]) ||
                  (temp_lo[j] <= temp_hi[i] && temp_lo[j] >= temp_lo[i]))
                 {
                  merge1[merge_count] = i;
                  merge2[merge_count] = j;
                  temp_merge[i] = true;
                  temp_merge[j] = true;
                  merge_count++;
                 }
              }
           }

         // ___ and merge them ___
         for(i=0; i<merge_count; i++)
           {
            int target = merge1[i];
            int source = merge2[i];

            temp_hi[target] = MathMax(temp_hi[target], temp_hi[source]);
            temp_lo[target] = MathMin(temp_lo[target], temp_lo[source]);
            temp_hits[target] += temp_hits[source];
            temp_start[target] = MathMax(temp_start[target], temp_start[source]);
            temp_strength[target]=MathMax(temp_strength[target],temp_strength[source]);
            if(temp_hits[target]>3)
               temp_strength[target]=ZONE_PROVEN;

            if(temp_hits[target]==0 && temp_turn[target]==false)
              {
               temp_hits[target]=1;
               if(temp_strength[target]<ZONE_VERIFIED)
                  temp_strength[target]=ZONE_VERIFIED;
              }

            if(temp_turn[target] == false || temp_turn[source] == false)
               temp_turn[target] = false;
            if(temp_turn[target] == true)
               temp_hits[target] = 0;

            temp_hits[source]=-1;
           }
        }
     }

// copy the remaining list into our official zones arrays
   zone_count=0;
   for(i=0; i<temp_count; i++)
     {
      if(temp_hits[i]>=0 && zone_count<1000)
        {
         zone_hi[zone_count]       = temp_hi[i];
         zone_lo[zone_count]       = temp_lo[i];
         zone_hits[zone_count]     = temp_hits[i];
         zone_turn[zone_count]     = temp_turn[i];
         zone_start[zone_count]    = temp_start[i];
         zone_strength[zone_count] = temp_strength[i];

         if(zone_hi[zone_count]<Close[4])
            zone_type[zone_count]=ZONE_SUPPORT;
         else if(zone_lo[zone_count]>Close[4])
            zone_type[zone_count]=ZONE_RESIST;
         else
           {
            for(j=5; j<1000; j++)
              {
               if(Close[j]<zone_lo[zone_count])
                 {
                  zone_type[zone_count]=ZONE_RESIST;
                  break;
                 }
               else if(Close[j]>zone_hi[zone_count])
                 {
                  zone_type[zone_count]=ZONE_SUPPORT;
                  break;
                 }
              }

            if(j==1000)
               zone_type[zone_count]=ZONE_SUPPORT;
           }

         zone_count++;
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawZones(const datetime &Time[], const double &Open[], const double &High[], const double &Low[], const double &Close[])
  {
   double lower_nerest_zone_P1=0;
   double lower_nerest_zone_P2=0;
   double higher_nerest_zone_P1=EMPTY_VALUE;
   double higher_nerest_zone_P2=EMPTY_VALUE;
   string s;

   if(SetGlobals==true)
     {
      GlobalVariableSet("SSSR_Count_"+_Symbol+(PeriodSeconds()/60),zone_count);
      GlobalVariableSet("SSSR_Updated_"+_Symbol+(PeriodSeconds()/60),TimeCurrent());
     }

   for(int i=0; i<zone_count; i++)
     {
      if(zone_strength[i]==ZONE_WEAK && zone_show_weak==false)
         continue;

      if(zone_strength[i]==ZONE_UNTESTED && zone_show_untested==false)
         continue;

      if(zone_strength[i]==ZONE_TURNCOAT && zone_show_turncoat==false)
         continue;

      //name sup
      if(zone_type[i]==ZONE_SUPPORT)
         s="SSSR#S"+i+" Strength=";
      else
      //name res
         s="SSSR#R"+i+" Strength=";

      if(zone_strength[i]==ZONE_PROVEN)
         s=s+"Proven, Test Count="+zone_hits[i];
      else if(zone_strength[i]==ZONE_VERIFIED)
         s=s+"Verified, Test Count="+zone_hits[i];
      else if(zone_strength[i]==ZONE_UNTESTED)
         s=s+"Untested";
      else if(zone_strength[i]==ZONE_TURNCOAT)
         s=s+"Turncoat";
      else
         s=s+"Weak";

      ObjectCreate(0, s, OBJ_RECTANGLE, 0, Time[zone_start[i]], zone_hi[i], Time[0], zone_lo[i]);
      ObjectSetInteger(0, s, OBJPROP_FILL, zone_solid);
      ObjectSetInteger(0, s, OBJPROP_WIDTH, zone_linewidth);
      ObjectSetInteger(0, s, OBJPROP_STYLE, zone_style);

      if(zone_type[i]==ZONE_SUPPORT)
        {
         // support zone
         if(zone_strength[i]==ZONE_TURNCOAT)
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_support_turncoat);
         else if(zone_strength[i]==ZONE_PROVEN)
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_support_proven);
         else if(zone_strength[i]==ZONE_VERIFIED)
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_support_verified);
         else if(zone_strength[i]==ZONE_UNTESTED)
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_support_untested);
         else
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_support_weak);
        }
      else
        {
         // resistance zone
         if(zone_strength[i]==ZONE_TURNCOAT)
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_resist_turncoat);
         else if(zone_strength[i]==ZONE_PROVEN)
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_resist_proven);
         else if(zone_strength[i]==ZONE_VERIFIED)
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_resist_verified);
         else if(zone_strength[i]==ZONE_UNTESTED)
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_resist_untested);
         else
            ObjectSetInteger(0, s, OBJPROP_COLOR, color_resist_weak);
        }


      if(SetGlobals==true)
        {
         GlobalVariableSet("SSSR_HI_"+_Symbol+(PeriodSeconds()/60)+i,zone_hi[i]);
         GlobalVariableSet("SSSR_LO_"+_Symbol+(PeriodSeconds()/60)+i,zone_lo[i]);
         GlobalVariableSet("SSSR_HITS_"+_Symbol+(PeriodSeconds()/60)+i,zone_hits[i]);
         GlobalVariableSet("SSSR_STRENGTH_"+_Symbol+(PeriodSeconds()/60)+i,zone_strength[i]);
         GlobalVariableSet("SSSR_AGE_"+_Symbol+(PeriodSeconds()/60)+i,zone_start[i]);
        }
        
      MqlTick lastTick;
      SymbolInfoTick(_Symbol, lastTick);

      //nearest zones
      if(zone_lo[i]>lower_nerest_zone_P2 && lastTick.bid>zone_lo[i]) {lower_nerest_zone_P1=zone_hi[i];lower_nerest_zone_P2=zone_lo[i];}
      if(zone_hi[i]<higher_nerest_zone_P1 && lastTick.bid<zone_hi[i]) {higher_nerest_zone_P1=zone_hi[i];higher_nerest_zone_P2=zone_lo[i];}
     }

   ner_hi_zone_P1[0]=higher_nerest_zone_P1;
   ner_hi_zone_P2[0]=higher_nerest_zone_P2;
   ner_lo_zone_P1[0]=lower_nerest_zone_P1;
   ner_lo_zone_P2[0]=lower_nerest_zone_P2;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Fractal(int M,int P,int shift, const double &High[], const double &Low[])
  {
   if((PeriodSeconds()/60)>P)
      P=PeriodSeconds()/60;

   P=P/(PeriodSeconds()/60)*2+MathCeil(P/(PeriodSeconds()/120));

   if(shift<P)
      return(false);

   if(shift>Bars(_Symbol, _Period)-P)
      return(false);

   for(int i=1; i<=P; i++)
     {
      if(M==UP_POINT)
        {
         if(High[shift+i]>High[shift])
            return(false);
         if(High[shift-i]>=High[shift])
            return(false);
        }
      if(M==DN_POINT)
        {
         if(Low[shift+i]<Low[shift])
            return(false);
         if(Low[shift-i]<=Low[shift])
            return(false);
        }
     }
   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void FastFractals(const datetime &Time[], const double &Open[], const double &High[], const double &Low[], const double &Close[])
  {
   int shift;
   int limit=MathMin(Bars(_Symbol, _Period)-1,BackLimit);
   int P=(PeriodSeconds()/60)*fractal_fast_factor;

   FastUpPts[0] = 0.0; FastUpPts[1] = 0.0;
   FastDnPts[0] = 0.0; FastDnPts[1] = 0.0;

   for(shift=limit; shift>1; shift--)
     {
      if(Fractal(UP_POINT,P,shift, High, Low)==true)
         FastUpPts[shift]=High[shift];
      else
         FastUpPts[shift]=0.0;

      if(Fractal(DN_POINT,P,shift, High, Low)==true)
         FastDnPts[shift]=Low[shift];
      else
         FastDnPts[shift]=0.0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SlowFractals(const datetime &Time[], const double &Open[], const double &High[], const double &Low[], const double &Close[])
  {
   int shift;
   int limit=MathMin(Bars(_Symbol, _Period)-1,BackLimit);
   int P=(PeriodSeconds()/60)*fractal_slow_factor;

   SlowUpPts[0] = 0.0; SlowUpPts[1] = 0.0;
   SlowDnPts[0] = 0.0; SlowDnPts[1] = 0.0;

   for(shift=limit; shift>1; shift--)
     {
      if(Fractal(UP_POINT,P,shift, High, Low)==true)
         SlowUpPts[shift]=High[shift];
      else
         SlowUpPts[shift]=0.0;

      if(Fractal(DN_POINT,P,shift, High, Low)==true)
         SlowDnPts[shift]=Low[shift];
      else
         SlowDnPts[shift]=0.0;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool NewBar()
  {
   static datetime LastTime=0;
   datetime newTime[1];
   int copied;
   
   copied = CopyTime(_Symbol,_Period,0,1,newTime);
   if (copied > 0) {
      if (LastTime != newTime[0]) {
         LastTime=newTime[0];
         return(true);
      }
      else {
         return(false);
      }
   }
  
   return (false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteZones()
  {
   int len=5;
   int i;

   for(i=0; i<ObjectsTotal(0); i++)
     {
      string objName=ObjectName(0, i);
      if(StringSubstr(objName,0,len)!="SSSR#")
        {
         continue;
        }
      ObjectDelete(0, objName);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TimeFrameToString(int tf) //code by TRO
  {
   string tfs;

   switch(tf)
     {
      case PERIOD_M1:
         tfs="M1";
         break;
      case PERIOD_M5:
         tfs="M5";
         break;
      case PERIOD_M15:
         tfs="M15";
         break;
      case PERIOD_M30:
         tfs="M30";
         break;
      case PERIOD_H1:
         tfs="H1";
         break;
      case PERIOD_H4:
         tfs="H4";
         break;
      case PERIOD_D1:
         tfs="D1";
         break;
      case PERIOD_W1:
         tfs="W1";
         break;
      case PERIOD_MN1:
         tfs="MN";
     }

   return(tfs);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringRepeat(string str,int n=1)
  {
   string outstr="";
   for(int i=0; i<n; i++) outstr=outstr+str;
   return(outstr);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string StringRightPad(string str,int n=1,string str2=" ")
  {
   return(str + StringRepeat(str2,n-StringLen(str)));
  }
//+------------------------------------------------------------------+

