//+------------------------------------------------------------------+
//|                                                      ProjectName |
//|                                      Copyright 2012, CompanyName |
//|                                       http://www.companyname.net |
//+------------------------------------------------------------------+
int OnInit()
  {

   MqlCalendarValue   value;          // array of values
   MqlCalendarEvent events[];
   MqlCalendarEvent cal_event;

   if(CalendarEventByCurrency("USD",events))
     {
      for(int i=0;i<ArraySize(events);i++)
        {
         //  Print("Importancia ",events[i].importance," Evento: ",events[i].name);

         if(CalendarValueById(events[i].id,value))
           {
            Print("Name ",events[i].name," Time ", value.time);
           }
        }

     }
   return INIT_SUCCEEDED;
  }
//+------------------------------------------------------------------+
