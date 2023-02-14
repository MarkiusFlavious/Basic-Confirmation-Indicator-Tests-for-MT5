

int barTotal;
int IndiHandle;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   barTotal = iBars(_Symbol,PERIOD_CURRENT);
   //IndiHandle = iCustom(_Symbol,PERIOD_CURRENT,"",);
   
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int barTotalUpdate = iBars(_Symbol,PERIOD_CURRENT);
   if (barTotal != barTotalUpdate)
   {
    barTotal = barTotalUpdate;
    
    /*double BufferValueA[];
    CopyBuffer(IndiHandle,2,1,1,BufferValueA);
    ArrayPrint(BufferValueA);*/
   }
   
  }
//+------------------------------------------------------------------+
