//+------------------------------------------------------------------+
//|                                                     LibPhibo.mqh |
//+------------------------------------------------------------------+

class LibPhibo {

private:
   double BufferMax[];
   double Buffer786[];
   double Buffer618[];
   double Buffer500[];
   double Buffer382[];
   double Buffer214[];
   double BufferMin[];
   int    PhiboPeriod;
   
   int    iHighest(const double &array[], int count, int startPos);
   int    iLowest(const double &array[], int count, int startPos);

public:
    LibPhibo();
    ~LibPhibo();
    void SetPhiboPeriod(int period);
    int CalculatePhibo(const int rates_total, const int prev_calculated, 
                       const double& open[], const double& high[], const double& low[], const double& close[]);
    int SetIntermediateBuffer(int index);
    int SetIndicatorBuffer_All(int index);
    int SetIndicatorBuffer_Min(int index);
    int SetIndicatorBuffer_214(int index);
    int SetIndicatorBuffer_382(int index);
    int SetIndicatorBuffer_500(int index);
    int SetIndicatorBuffer_618(int index);
    int SetIndicatorBuffer_786(int index);
    int SetIndicatorBuffer_Max(int index);
    double GetMinValue(int position, bool asSeries);
    double Get214Value(int position, bool asSeries);
    double Get382Value(int position, bool asSeries);
    double Get500Value(int position, bool asSeries);
    double Get618Value(int position, bool asSeries);
    double Get786Value(int position, bool asSeries);
    double GetMaxValue(int position, bool asSeries);
};


LibPhibo::LibPhibo() { }

LibPhibo::~LibPhibo() { }



void LibPhibo::SetPhiboPeriod(int period) {

   PhiboPeriod = period;

}

//+------------------------------------------------------------------+
//|  searching index of the highest bar                              |
//+------------------------------------------------------------------+
int LibPhibo::iHighest(const double &array[], int count, int startPos) {
   
   int index=startPos;
   //----checking correctness of the initial index
   if(startPos<0) {
      Print("Bad value in the function iHighest, startPos = ",startPos);
      return(0);
   }
   //---- checking correctness of startPos value
   if(startPos-count<0)
      count=startPos;

   double max=array[startPos];
   //---- searching for an index
   for(int i=startPos; i>startPos-count; i--) {
      if(array[i]>max) {
         index=i;
         max=array[i];
      }
   }
   //---- returning of the greatest bar index
   return(index);
}
//+------------------------------------------------------------------+
//|  searching index of the lowest bar                               |
//+------------------------------------------------------------------+
int LibPhibo::iLowest(const double &array[], int count, int startPos) {

   int index=startPos;

   //----checking correctness of the initial index
   if(startPos<0) {
      Print("Bad value in the function iLowest, startPos = ",startPos);
      return(0);
   }

   //---- checking correctness of startPos value
   if(startPos-count<0)
      count=startPos;

   double min=array[startPos];

   //---- searching for an index
   for(int i=startPos; i>startPos-count; i--) {
      if(array[i]<min) {
         index=i;
         min=array[i];
      }
   }
   //---- returning of the lowest bar index
   return(index);
  
}

int LibPhibo::CalculatePhibo(const int rates_total, const int prev_calculated, 
                             const double& open[], const double& high[], 
                             const double& low[], const double& close[]) {

   if(rates_total < PhiboPeriod + 1) return(0);

   double SsMax=0,SsMin=0;
   int first, bar;

   if(prev_calculated==0)  {
      first = PhiboPeriod;    
   }
   else {
      first = prev_calculated-1; // starting number for calculation of new bars
   }

//---- Main cycle of calculation of the channel
   for (bar=first; bar<rates_total; bar++) {

      SsMax=high[iHighest(high,PhiboPeriod,bar)];
      SsMin=low[iLowest(low,PhiboPeriod,bar)];

      BufferMax[bar]=SsMax;
      BufferMin[bar]=SsMin;

      Buffer786[bar]=((SsMax - SsMin)*0.786) + SsMin;
      Buffer618[bar]=((SsMax - SsMin)*0.618) + SsMin;
      Buffer500[bar]=((SsMax - SsMin)*0.500) + SsMin;
      Buffer382[bar]=((SsMax - SsMin)*0.382) + SsMin;
      Buffer214[bar]=((SsMax - SsMin)*0.214) + SsMin;

   }
//----    
   return(rates_total);
}


int LibPhibo::SetIntermediateBuffer(int index) {

   SetIndexBuffer(index++, BufferMax, INDICATOR_CALCULATIONS);
   SetIndexBuffer(index++, Buffer786, INDICATOR_CALCULATIONS);
   SetIndexBuffer(index++, Buffer618, INDICATOR_CALCULATIONS);
   SetIndexBuffer(index++, Buffer500, INDICATOR_CALCULATIONS);
   SetIndexBuffer(index++, Buffer382, INDICATOR_CALCULATIONS);
   SetIndexBuffer(index++, Buffer214, INDICATOR_CALCULATIONS);
   SetIndexBuffer(index++, BufferMin, INDICATOR_CALCULATIONS);

   return(index);
}

int LibPhibo::SetIndicatorBuffer_All(int index){

   SetIndexBuffer(index++, BufferMax, INDICATOR_DATA);
   SetIndexBuffer(index++, Buffer786, INDICATOR_DATA);
   SetIndexBuffer(index++, Buffer618, INDICATOR_DATA);
   SetIndexBuffer(index++, Buffer500, INDICATOR_DATA);
   SetIndexBuffer(index++, Buffer382, INDICATOR_DATA);
   SetIndexBuffer(index++, Buffer214, INDICATOR_DATA);
   SetIndexBuffer(index++, BufferMin, INDICATOR_DATA);

   return(index);
}

int LibPhibo::SetIndicatorBuffer_Max(int index) {

   SetIndexBuffer(index++, BufferMax, INDICATOR_DATA);

   return(index);
}

int LibPhibo::SetIndicatorBuffer_786(int index) {

   SetIndexBuffer(index++, Buffer786, INDICATOR_DATA);

   return(index);
}

int LibPhibo::SetIndicatorBuffer_618(int index) {

   SetIndexBuffer(index++, Buffer618, INDICATOR_DATA);

   return(index);
}

int LibPhibo::SetIndicatorBuffer_500(int index) {

   SetIndexBuffer(index++, Buffer500, INDICATOR_DATA);

   return(index);
}

int LibPhibo::SetIndicatorBuffer_382(int index) {

   SetIndexBuffer(index++, Buffer382, INDICATOR_DATA);

   return(index);
}

int LibPhibo::SetIndicatorBuffer_214(int index) {

   SetIndexBuffer(index++, Buffer214, INDICATOR_DATA);

   return(index);
}

int LibPhibo::SetIndicatorBuffer_Min(int index) {

   SetIndexBuffer(index++, BufferMin, INDICATOR_DATA);

   return(index);
}


double LibPhibo::GetMaxValue(int position, bool asSeries) {

   double value = 0.0;

   if (position < 0 || position > Bars(_Symbol, _Period)) return(0.0);
   
   if (asSeries) {
      ArraySetAsSeries(BufferMax, true);
   }

   value = BufferMax[position];

   if (asSeries) {
      ArraySetAsSeries(BufferMax, false);
   }

   return(value);

}

double LibPhibo::Get786Value(int position, bool asSeries) {

   double value = 0.0;
   
   if (position < 0 || position > Bars(_Symbol, _Period)) return(0.0);
   
   if (asSeries) {
      ArraySetAsSeries(Buffer786, true);
   }

   value = Buffer786[position];

   if (asSeries) {
      ArraySetAsSeries(Buffer786, false);
   }

   return(value);

}

double LibPhibo::Get618Value(int position, bool asSeries) {

   double value = 0.0;
   
   if (position < 0 || position > Bars(_Symbol, _Period)) return(0.0);
   
   if (asSeries) {
      ArraySetAsSeries(Buffer618, true);
   }

   value = Buffer618[position];

   if (asSeries) {
      ArraySetAsSeries(Buffer618, false);
   }

   return(value);

}

double LibPhibo::Get500Value(int position, bool asSeries) {

   double value = 0.0;
   
   if (position < 0 || position > Bars(_Symbol, _Period)) return(0.0);
   
   if (asSeries) {
      ArraySetAsSeries(Buffer500, true);
   }

   value = Buffer500[position];

   if (asSeries) {
      ArraySetAsSeries(Buffer500, false);
   }

   return(value);

}

double LibPhibo::Get382Value(int position, bool asSeries) {

   double value = 0.0;
   
   if (position < 0 || position > Bars(_Symbol, _Period)) return(0.0);
   
   if (asSeries) {
      ArraySetAsSeries(Buffer382, true);
   }

   value = Buffer382[position];

   if (asSeries) {
      ArraySetAsSeries(Buffer382, false);
   }

   return(value);

}


double LibPhibo::Get214Value(int position, bool asSeries) {

   double value = 0.0;
   
   if (position < 0 || position > Bars(_Symbol, _Period)) return(0.0);
   
   if (asSeries) {
      ArraySetAsSeries(Buffer214, true);
   }

   value = Buffer214[position];

   if (asSeries) {
      ArraySetAsSeries(Buffer214, false);
   }

   return(value);

}


double LibPhibo::GetMinValue(int position, bool asSeries) {

   double value = 0.0;
   
   if (position < 0 || position > Bars(_Symbol, _Period)) return(0.0);
   
   if (asSeries) {
      ArraySetAsSeries(BufferMin, true);
   }

   value = BufferMin[position];

   if (asSeries) {
      ArraySetAsSeries(BufferMin, false);
   }

   return(value);

}

