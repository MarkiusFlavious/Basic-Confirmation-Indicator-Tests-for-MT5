#include <Custom/Confirmation Indicators/SSL_Channel.mqh>
int barTotal;
int IndiHandle;

SSLChannelChart SSL_Indicator(MODE_SMA,10,_Symbol,PERIOD_CURRENT);

int OnInit(){
   
   barTotal = iBars(_Symbol,PERIOD_CURRENT);
   IndiHandle = iCustom(_Symbol,PERIOD_CURRENT,"SSL_Channel_Chart_Chatgpt_Mod.ex5");
   SSL_Indicator.Initialize();
   
   return(INIT_SUCCEEDED);
  }

void OnDeinit(const int reason){}

void OnTick(){
   
   int barTotalUpdate = iBars(_Symbol,PERIOD_CURRENT);
   
   if (barTotal != barTotalUpdate){
      barTotal = barTotalUpdate;
    
      double BufferValueA[];
      CopyBuffer(IndiHandle,0,1,1,BufferValueA);
      double BufferValueB[];
      CopyBuffer(IndiHandle,1,1,1,BufferValueB);
      Print("Normal Buffer 0 - d value (down): ", BufferValueA[0], " | Normal Buffer 1 - u value (up): ", BufferValueB[0]);
      
      double fast_line[], slow_line[];
      SSL_Indicator.GetBufferValues(1,0,1,1,fast_line,slow_line);
      Print("Slow Line: ", slow_line[0], " | Fast Line: ", fast_line[0]);
   }
   
}

