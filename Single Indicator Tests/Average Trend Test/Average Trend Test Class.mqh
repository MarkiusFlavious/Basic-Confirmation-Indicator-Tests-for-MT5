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
   
   int ATrend_Period;
   ENUM_MA_METHOD ATrend_Method;
   ENUM_APPLIED_PRICE ATrend_App_Price;
   double ATrend_Acceleration;

// Indicator Handles:
   int ATR_Channel_Handle;
   int ATrend_Handle;
// Other Declarations:
   int Bar_Total;
   ulong Ticket_Number;
   bool In_Trade;
   CTrade trade;
   
// Private Function Declaration:
   TRADING_TERMS        LookForSignal(void);
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
                                               int atrend_period,
                                               ENUM_MA_METHOD atrend_method,
                                               ENUM_APPLIED_PRICE atrend_app_price,
                                               double atrend_acceleration);
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
                                               int atrend_period,
                                               ENUM_MA_METHOD atrend_method,
                                               ENUM_APPLIED_PRICE atrend_app_price,
                                               double atrend_acceleration){
   // Initialize Inputs
   Pair = pair;
   Timeframe = timeframe;
   
   Risk_Percent = risk_percent;
   Profit_Factor = profit_factor;
   ATR_Period = atr_period;
   ATR_Channel_Factor = atr_channel_factor;
   ATR_Channel_Applied_Price = atr_channel_applied_price;
   
   ATrend_Period = atrend_period;
   ATrend_Method = atrend_method;
   ATrend_App_Price = atrend_app_price;
   ATrend_Acceleration = atrend_acceleration;
   
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
   ATrend_Handle = iCustom(Pair,Timeframe,"Average trend.ex5",ATrend_Period,ATrend_Method,ATrend_App_Price,ATrend_Acceleration);
   
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
      
      TRADING_TERMS trade_signal = LookForSignal();
      PositionCheckModify(trade_signal);
      
      if (!In_Trade){
         if (trade_signal == BUY_SIGNAL) EnterPosition(GO_LONG);
         else if (trade_signal == SELL_SIGNAL) EnterPosition(GO_SHORT);
      }
   }   
}
//+------------------------------------------------------------------+
//| Look For Signal Function:                                        |
//+------------------------------------------------------------------+
//| - PositionCheckModify will close a position if it receives:      |
//|  - NO_SIGNAL                                                     |
//|  - An opposite signal to the current open position               |
//+------------------------------------------------------------------+
TRADING_TERMS CSingleIndicatorTester::LookForSignal(void){
   
   double colour_value[];
   CopyBuffer(ATrend_Handle,1,1,2,colour_value);
   ArrayReverse(colour_value);
   
   if (colour_value[0] == 0) return NO_SIGNAL;
   
   else if (colour_value[0] == 1){
      if (colour_value[1] == 2) return BUY_SIGNAL;
      else return BULLISH;
   }
   else if (colour_value[0] == 2){
      if (colour_value[1] == 1) return SELL_SIGNAL;
      else return BEARISH; 
   }
   return NO_SIGNAL;
}
//+------------------------------------------------------------------+
//| Lot Size Calculation Function:                                   |
//+------------------------------------------------------------------+
//| - Calculates lot sized based on percentage of account size.      |
//| - Stop loss distance is calculated in the EnterPosition function.|
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
//| Enter Position Function:                                         |
//+------------------------------------------------------------------+
//| - Uses ATR Channel for stop loss placement                       |
//| - The channel distance is placed at ATR * ATR_Channel_Factor     |
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
   else if (entry_type == GO_SHORT){
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
//|- Gets called every time there's a new bar.                       |
//+------------------------------------------------------------------+
void CSingleIndicatorTester::PositionCheckModify(TRADING_TERMS trade_signal){
   
   if (In_Trade){
      if (PositionSelectByTicket(Ticket_Number)){
      
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
            if (trade_signal == SELL_SIGNAL || trade_signal == BEARISH || trade_signal == NO_SIGNAL){
               if (trade.PositionClose(Ticket_Number)){
                  In_Trade = false;
                  Ticket_Number = NULL;
               }
            }
         }
         else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
            if (trade_signal == BUY_SIGNAL || trade_signal == BULLISH || trade_signal == NO_SIGNAL){
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