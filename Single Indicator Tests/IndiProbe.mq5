
int barTotal;
int IndiHandle;

int OnInit(){
   
   barTotal = iBars(_Symbol,PERIOD_CURRENT);
   IndiHandle = iCustom(_Symbol,PERIOD_CURRENT,"Vortex 2.ex5");
   
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason){}

void OnTick(){
   
   int barTotalUpdate = iBars(_Symbol,PERIOD_CURRENT);
   
   if (barTotal != barTotalUpdate){
      barTotal = barTotalUpdate;
    
      double BufferValueA[];
      CopyBuffer(IndiHandle,2,1,1,BufferValueA);
      double BufferValueB[];
      CopyBuffer(IndiHandle,4,1,1,BufferValueB);
      Print("Buffer 0: ", BufferValueA[0], " | Buffer 1: ", BufferValueB[0]);
   }
   
}

