#include <Trade/Trade.mqh>
//+------------------------------------------------------------------+
//| Custom Enums                                                     |
//+------------------------------------------------------------------+
enum TRADING_TERMS {
   BUY_SIGNAL,
   SELL_SIGNAL,
   NO_SIGNAL,
   BULLISH,
   BEARISH,
   GO_LONG,
   GO_SHORT
};
enum AROON_METHOD {
   ON_CROSS, // On Line Cross
   ON_CROSS_AND_MAX // Line Cross + Wait for Max
};
//+------------------------------------------------------------------+
//| Class CSingleIndicatorTester                                     |
//| - For Testing Confirmation Indicators                            |
//+------------------------------------------------------------------+
class CSingleIndicatorTester : public CObject {
private:
// Input Parameters:
   string Pair;
   ENUM_TIMEFRAMES Timeframe;
   
   // Risk Inputs
   double Risk_Percent;
   double Profit_Factor;
   uint ATR_Period;
   double ATR_Channel_Factor;
   double ATR_Channel_Applied_Price;
   
   // Aroon Inputs
   int Aroon_Period;
   int Aroon_Shift;
   AROON_METHOD Aroon_Method;
   int Aroon_Lookback;

// Indicator Handles:
   int ATR_Channel_Handle;
   int Aroon_Handle;
   
// Other Declarations:
   int Bar_Total;
   ulong Ticket_Number;
   bool In_Trade;
   CTrade trade;
     
// Private Function Declaration:
   TRADING_TERMS        LookForSignal(AROON_METHOD Aroon_Method_Input);
   double               CalculateLotSize(double risk_input, double stop_distance);
   void                 EnterPosition(TRADING_TERMS entry_type);
   void                 PositionCheckModify(TRADING_TERMS trade_signal);

public:
// Public Function/Constructor/Destructor Declaration:
                        CSingleIndicatorTester(string pair,
                                               ENUM_TIMEFRAMES timeframe,
                                               double risk_percent,
                                               double profit_factor,
                                               uint atr_period,
                                               double atr_channel_factor,
                                               double atr_channel_applied_price,
                                               int aroon_period,
                                               int aroon_shift,
                                               AROON_METHOD aroon_method,
                                               int aroon_lookback);
                        ~CSingleIndicatorTester(void);
   int                  OnInitEvent(void);
   void                 OnDeinitEvent(const int reason);
   void                 OnTickEvent(void);

};
//+------------------------------------------------------------------+
//| Constructor                                                      |
//+------------------------------------------------------------------+
CSingleIndicatorTester::CSingleIndicatorTester(string pair,
                                               ENUM_TIMEFRAMES timeframe,
                                               double risk_percent,
                                               double profit_factor,
                                               uint atr_period,
                                               double atr_channel_factor,
                                               double atr_channel_applied_price,
                                               int aroon_period,
                                               int aroon_shift,
                                               AROON_METHOD aroon_method,
                                               int aroon_lookback){
   // Initialize Inputs
   Pair = pair;
   Timeframe = timeframe;
   
   Risk_Percent = risk_percent;
   Profit_Factor = profit_factor;
   ATR_Period = atr_period;
   ATR_Channel_Factor = atr_channel_factor;
   ATR_Channel_Applied_Price = atr_channel_applied_price;
   
   Aroon_Period = aroon_period;
   Aroon_Shift = aroon_shift;
   Aroon_Method = aroon_method;
   Aroon_Lookback = aroon_lookback;
   
   // Other Variable Initialization
   Bar_Total = 0;
   Ticket_Number = 0;
   In_Trade = false;   
}
//+------------------------------------------------------------------+
//| Destructor                                                       |
//+------------------------------------------------------------------+
CSingleIndicatorTester::~CSingleIndicatorTester(void){
}
//+------------------------------------------------------------------+
//| OnInit Event Function                                            |
//+------------------------------------------------------------------+
int CSingleIndicatorTester::OnInitEvent(void){
   
   Bar_Total = iBars(Pair,Timeframe);
   ATR_Channel_Handle = iCustom(Pair,Timeframe,"ATR Channel.ex5",MODE_SMA,1,ATR_Period,ATR_Channel_Factor,ATR_Channel_Applied_Price);
   Aroon_Handle = iCustom(Pair,Timeframe,"aroon.ex5",Aroon_Period,Aroon_Shift);
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| OnDeinit Event Function                                          |
//+------------------------------------------------------------------+
void CSingleIndicatorTester::OnDeinitEvent(const int reason){}
//+------------------------------------------------------------------+
//| OnTick Event Function                                            |
//+------------------------------------------------------------------+
void CSingleIndicatorTester::OnTickEvent(void){
   
   int Bar_Total_Current = iBars(Pair,Timeframe);
   
   if (Bar_Total != Bar_Total_Current){
      Bar_Total = Bar_Total_Current;
      
      TRADING_TERMS trade_signal = LookForSignal(Aroon_Method);
      PositionCheckModify(trade_signal);
      
      if (!In_Trade){
         if (trade_signal == BUY_SIGNAL) EnterPosition(GO_LONG);
         else if (trade_signal == SELL_SIGNAL) EnterPosition(GO_SHORT);
      }
   }   
}
//+------------------------------------------------------------------+
//| Look For Signal Function                                         |
//+------------------------------------------------------------------+
TRADING_TERMS CSingleIndicatorTester::LookForSignal(AROON_METHOD Aroon_Method_Input){
   double green_line_values[],red_line_values[];
   CopyBuffer(Aroon_Handle,0,1,Aroon_Lookback + 2,green_line_values);
   CopyBuffer(Aroon_Handle,1,1,Aroon_Lookback + 2,red_line_values);
   ArrayReverse(green_line_values);
   ArrayReverse(red_line_values);
   
   if (green_line_values[0] == red_line_values[0]) return NO_SIGNAL;
   
   if (Aroon_Method_Input == ON_CROSS){
      
      if (green_line_values[0] > red_line_values[0] && green_line_values[1] <= red_line_values[1]) return BUY_SIGNAL;
      if (green_line_values[0] > red_line_values[0]) return BULLISH;
      if (green_line_values[0] < red_line_values[0] && green_line_values[1] >= red_line_values[1]) return SELL_SIGNAL;
      if (green_line_values[0] < red_line_values[0]) return BEARISH;
   }
   
   if (Aroon_Method_Input == ON_CROSS_AND_MAX){
      
      if (green_line_values[0] > 93 && green_line_values[0] > red_line_values[0]){
         for (int pos = 1; pos < ArraySize(green_line_values); pos++){
            if (green_line_values[pos] > 93 && green_line_values[pos] > red_line_values[pos]) return BULLISH;
            if (green_line_values[pos] <= red_line_values[pos]) return BUY_SIGNAL;
         }
      }
      if (green_line_values[0] > red_line_values[0]) return BULLISH;
      
      if (red_line_values[0] > 93 && red_line_values[0] > green_line_values[0]){
         for (int pos = 1; pos < ArraySize(red_line_values); pos++){
            if (red_line_values[pos] > 93 && red_line_values[pos] > green_line_values[pos]) return BEARISH;
            if (red_line_values[pos] <= green_line_values[pos]) return SELL_SIGNAL;
         }
      }
      if (red_line_values[0] > green_line_values[0]) return BEARISH;
   }
   return NO_SIGNAL;
}
//+------------------------------------------------------------------+
//| Lot Size Calculation Function                                    |
//+------------------------------------------------------------------+
double CSingleIndicatorTester::CalculateLotSize(double risk_input,double stop_distance){
   
   double tick_size = SymbolInfoDouble(Pair,SYMBOL_TRADE_TICK_SIZE);
   double tick_value = SymbolInfoDouble(Pair,SYMBOL_TRADE_TICK_VALUE);
   double lot_step = SymbolInfoDouble(Pair,SYMBOL_VOLUME_STEP);
   
   if (tick_size == 0 || tick_value == 0 || lot_step == 0){
      Print("Error: Lot size could not be calculated");
      return 0;
   }
   double risk_money = AccountInfoDouble(ACCOUNT_BALANCE) * risk_input / 100;
   double money_lot_step = (stop_distance / tick_size) * tick_value * lot_step;
   
   if (money_lot_step == 0){
      Print("Lot Size could not be calculated.");
      return 0;
   } 
   double lots = MathFloor(risk_money / money_lot_step) * lot_step;
   return lots;
}
//+------------------------------------------------------------------+
//| Enter Position Function                                          |
//+------------------------------------------------------------------+
void CSingleIndicatorTester::EnterPosition(TRADING_TERMS entry_type){
   
   double atr_channel_upper[],atr_channel_lower[];
   CopyBuffer(ATR_Channel_Handle,1,1,1,atr_channel_upper);
   CopyBuffer(ATR_Channel_Handle,2,1,1,atr_channel_lower);
   
   int digits = (int)SymbolInfoInteger(Pair,SYMBOL_DIGITS);
   double ask_price = NormalizeDouble(SymbolInfoDouble(Pair,SYMBOL_ASK),digits);
   double bid_price = NormalizeDouble(SymbolInfoDouble(Pair,SYMBOL_BID),digits);
   
   if (entry_type == GO_LONG){
      double stop_distance = ask_price - atr_channel_lower[0];
      double profit_distance = stop_distance * Profit_Factor;
      double stop_price = NormalizeDouble(atr_channel_lower[0],digits);
      double profit_price = NormalizeDouble((ask_price + profit_distance),digits);
      double lot_size = CalculateLotSize(Risk_Percent,stop_distance);
    
      if (trade.Buy(lot_size,Pair,ask_price,stop_price,profit_price)){
         if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
            Ticket_Number = trade.ResultOrder();
            In_Trade = true;
         }
      }
   }
   
   if (entry_type == GO_SHORT){
      double stop_distance = atr_channel_upper[0] - bid_price;
      double profit_distance = stop_distance * Profit_Factor;
      double stop_price = NormalizeDouble(atr_channel_upper[0],digits);
      double profit_price = NormalizeDouble((bid_price - profit_distance),digits);
      double lot_size = CalculateLotSize(Risk_Percent,stop_distance);
      
      if (trade.Sell(lot_size,Pair,bid_price,stop_price,profit_price)){
         if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
            Ticket_Number = trade.ResultOrder();
            In_Trade = true;
         }
      }
   }
}
//+------------------------------------------------------------------+
//| Position Check/Modify Function                                   |
//+------------------------------------------------------------------+
void CSingleIndicatorTester::PositionCheckModify(TRADING_TERMS trade_signal){
   
   if (In_Trade){
      if (PositionSelectByTicket(Ticket_Number)){
      
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
            if (trade_signal == SELL_SIGNAL){
               if (trade.PositionClose(Ticket_Number)){
                  In_Trade = false;
                  Ticket_Number = NULL;
               }
            }
         }
     
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
            if (trade_signal == BUY_SIGNAL){
               if (trade.PositionClose(Ticket_Number)){
                  In_Trade = false;
                  Ticket_Number = NULL;
               }
            }
         } 
      }
      else{ // If we cannot select the trade, it has either hit the tp or sl.
         In_Trade = false;
         Ticket_Number = NULL;
      }
   }
}