#property description "Linear Regression"
#property description "1 classic & 3 alternative methods"
#property copyright   "ds2"
#property version     "1.0"
//+------------------------------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  Cyan
//+------------------------------------------------------------------+
enum LR_Method 
  {
   LR_M_Classic = 0,  // Standard
   LR_M_Sum     = 1,  // Moving totals
   LR_M_Func    = 2,  // Simplification
   LR_M_Approx  = 3   // Approximating
  };

// Input parameters

input LR_Method LRMethod  = LR_M_Sum;  // Calculation method
input int       LRPeriod  = 20;        // Bars in regression
input bool      ShowLog   = false;     // Display execution log
//+------------------------------------------------------------------+
// The main buffer - drawing a line on a chart
double ExtLRBuffer[];

// Buffers for the moving totals method
double ExtBufSx[], ExtBufSy[], ExtBufSxx[], ExtBufSxy[];

// Indicators for the simplification method
int h_SMA, h_LWMA;

// For execution time counter
uint TicksStart, TicksEnd;
//+------------------------------------------------------------------+
void OnInit()
  {
   TicksStart=GetTickCount();   
  
   SetIndexBuffer(0, ExtLRBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, LRPeriod-1);
   
   SetIndexBuffer(1, ExtBufSx,  INDICATOR_CALCULATIONS);
   SetIndexBuffer(2, ExtBufSy,  INDICATOR_CALCULATIONS);
   SetIndexBuffer(3, ExtBufSxx, INDICATOR_CALCULATIONS);
   SetIndexBuffer(4, ExtBufSxy, INDICATOR_CALCULATIONS);

   IndicatorSetString (INDICATOR_SHORTNAME,"Linear Regression");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
   
   // Creating indicators for the simplification method
   if (LRMethod == LR_M_Func) {
      h_SMA  = iMA(NULL, 0, LRPeriod, 0, MODE_SMA,  PRICE_CLOSE);
      h_LWMA = iMA(NULL, 0, LRPeriod, 0, MODE_LWMA, PRICE_CLOSE);   
   }

   // Data for execution speed counting
   if (ShowLog)
     Print("OnInit(). Beginning in ", TicksStart, ", end in ", GetTickCount());
  }
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const int begin,
                const double &price[])
  {
   if (ShowLog && ((rates_total - prev_calculated)>2))
     Print("OnCalculate(). Beginning in ", GetTickCount());   
   
   if (rates_total < LRPeriod)
      return(0);

   int limit = prev_calculated ? prev_calculated-1 : LRPeriod-1;
 
   bool IsExistsCalcBars = prev_calculated > 0;
   
   // The cycle along the calculated bars
   for (int bar = limit; bar < rates_total; bar++)
     {
      double lrvalue = 0; // the linear regression value in this bar
      
      //===============================
      // Calculate the value
      // of the linear regression function
      // by the required method
      //===============================
      
      double Sx=0, Sy=0, Sxy=0, Sxx=0;
      
      if ( (LRMethod == LR_M_Classic) || ((LRMethod == LR_M_Sum)&&(!IsExistsCalcBars)) )
        //----------------------------------//
        // Standard calculation method
        //----------------------------------//      
        {
            // Finding intermediate values-sums
            Sx  = 0;
            Sy  = 0;
            Sxx = 0;
            Sxy = 0;
            for (int x = 1; x <= LRPeriod; x++)
              {
               double y = price[bar-LRPeriod+x];
               Sx  += x;
               Sy  += y;
               Sxx += x*x;
               Sxy += x*y;
              }

            // Regression ratios
            double a = (LRPeriod * Sxy - Sx * Sy) / (LRPeriod * Sxx - Sx * Sx);
            double b = (Sy - a * Sx) / LRPeriod;

            lrvalue = a*LRPeriod + b;
            
            // The message for the LR_M_Sum method, what it has, what it should count from
            IsExistsCalcBars = true;
        }
        //----------------------------------//
      else if (LRMethod == LR_M_Sum)
        //----------------------------------//
        // Moving totals method
        //----------------------------------//
        {
            // (The very first bar was calculated using the standard method)        
        
            // Previous bar
            int prevbar = bar-1;
            
            //--- Calculating new values of intermediate totals 
            //   from the previous bar values
            
            Sx  = ExtBufSx [prevbar]; 
            
            // An old price comes out, a new one comes in
            Sy  = ExtBufSy [prevbar] - price[bar-LRPeriod] + price[bar]; 
            
            Sxx = ExtBufSxx[prevbar];
            
            // All the old prices come out once, a new one comes in with an appropriate weight
            Sxy = ExtBufSxy[prevbar] - ExtBufSy[prevbar] + price[bar]*LRPeriod;
            
            //---

            // Regression ratios (calculated the same way as in the standard method)
            double a = (LRPeriod * Sxy - Sx * Sy) / (LRPeriod * Sxx - Sx * Sx);
            double b = (Sy - a * Sx) / LRPeriod;

            lrvalue = a*LRPeriod + b;            
        }
        //----------------------------------//
      else if (LRMethod == LR_M_Func)
        //----------------------------------//
        // Simplification method
        //----------------------------------//      
        {
            double SMA [1];
            double LWMA[1];
            CopyBuffer(h_SMA,  0, rates_total-bar, 1, SMA);
            CopyBuffer(h_LWMA, 0, rates_total-bar, 1, LWMA);
            
            lrvalue = 3*LWMA[0] - 2*SMA[0];
        }
        //----------------------------------//
      else if (LRMethod == LR_M_Approx)
        //----------------------------------//
        // Approximating method
        //----------------------------------//
        {
           // The interval midpoint
           int HalfPeriod = (int) MathRound(LRPeriod/2);
           
           // Average price of the first half
           double s1 = 0;
           for (int i = 0; i < HalfPeriod; i++)
              s1 += price[bar-i];
           s1 /= HalfPeriod;
              
           // Average price of the second half
           double s2 = 0;
           for (int i = HalfPeriod; i < LRPeriod; i++)
              s2 += price[bar-i];
           s2 /= (LRPeriod-HalfPeriod);
           
           // Price excess by one bar
           double k = (s1-s2)/(LRPeriod/2);
           
           // Extrapolated price at the last bar
           lrvalue = s1 + k * (HalfPeriod-1)/2;
        }
        //----------------------------------//


      // Cashing intermediate totals into calculated buffers
      if (LRMethod == LR_M_Sum)
        {
         ExtBufSx  [bar] = Sx; 
         ExtBufSy  [bar] = Sy;
         ExtBufSxx [bar] = Sxx;
         ExtBufSxy [bar] = Sxy;
        }
        
      // Saving regression results
      ExtLRBuffer[bar] = lrvalue;
     }

   // Data for execution speed counting
   TicksEnd = GetTickCount();
   if (ShowLog && ((rates_total - prev_calculated)>2))
     {
      Print("OnCalculate(). End in ", TicksEnd);
      Print("Bars created: ", rates_total-limit,
            ". Execution time (from the beginning of OnInit), ms: ", TicksEnd-TicksStart);
     }

   return(rates_total);
  }
//+------------------------------------------------------------------+