//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
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
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "Use Current or Different Timeframe:"
input ENUM_TIMEFRAMES input_timeframe = PERIOD_CURRENT; // Timeframe

input group "Risk Inputs"
input double input_risk_percent = 1.0; // Risk Percent Per Trade
input double input_profit_factor = 1.5; // Profit factor
input uint input_atr_period = 25; // ATR Period
input double input_atr_channel_factor =1.5; // ATR Channel Factor
input ENUM_APPLIED_PRICE input_atr_channel_ap = PRICE_TYPICAL; // ATR Channel Applied Price

input group "Aroon Inputs"
input int input_aroon_period = 9; // Aroon Period 
input int input_aroon_shift = 0; // Aroon Horizontal Shift
input AROON_METHOD input_aroon_method = ON_CROSS_AND_MAX; // Aroon Trading method
input int input_aroon_lookback = 3; // Aroon Lookback. Will break if lower than 3.
//+------------------------------------------------------------------+
//| Handles                                                          |
//+------------------------------------------------------------------+
int ATR_Channel_Handle{};
int Aroon_Handle;
//+------------------------------------------------------------------+
//| Global Variables                                                 |
//+------------------------------------------------------------------+
int Bar_Total{};
ulong Ticket_Number{};
bool In_Trade = false;

//+------------------------------------------------------------------+
//| Objects                                                          |
//+------------------------------------------------------------------+
CTrade trade;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   
   Bar_Total = iBars(_Symbol,input_timeframe);
   ATR_Channel_Handle = iCustom(_Symbol,input_timeframe,"ATR Channel.ex5",MODE_SMA,1,input_atr_period,input_atr_channel_factor,input_atr_channel_ap);
   Aroon_Handle = iCustom(_Symbol,input_timeframe,"aroon.ex5",input_aroon_period,input_aroon_shift);
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
   int bar_total_current = iBars(_Symbol,input_timeframe);
   
   if (Bar_Total != bar_total_current){
      Bar_Total = bar_total_current;
    
      TRADING_TERMS trade_signal = LookForSignal(input_aroon_method);
      PositionCheckModify(trade_signal);
    
      if (In_Trade == false){
         if (trade_signal == BUY_SIGNAL) EnterPosition(GO_LONG);
         if (trade_signal == SELL_SIGNAL) EnterPosition(GO_SHORT);
      }
   }  
}
//+------------------------------------------------------------------+
//| Trade Signal Function:                                           |
//+------------------------------------------------------------------+
//|- Stay in the trade if it's bullish                               |
//|- Exit when the lines become equal                                |
//|- Lines can be equal for multiple bars                            |
//|- PositionCheckModify will close a position if it receives:       |
//|  - NO_SIGNAL                                                     |
//|  - An opposite signal to the current open position               |
//+------------------------------------------------------------------+
TRADING_TERMS LookForSignal(AROON_METHOD Aroon_Method){
   
   double green_line_values[],red_line_values[];
   CopyBuffer(Aroon_Handle,0,1,input_aroon_lookback + 2,green_line_values);
   CopyBuffer(Aroon_Handle,1,1,input_aroon_lookback + 2,red_line_values);
   ArrayReverse(green_line_values);
   ArrayReverse(red_line_values);
   
   if (green_line_values[0] == red_line_values[0]) return NO_SIGNAL;
   
   if (Aroon_Method == ON_CROSS){
      
      if (green_line_values[0] > red_line_values[0] && green_line_values[1] <= red_line_values[1]) return BUY_SIGNAL;
      if (green_line_values[0] > red_line_values[0]) return BULLISH;
      if (green_line_values[0] < red_line_values[0] && green_line_values[1] >= red_line_values[1]) return SELL_SIGNAL;
      if (green_line_values[0] < red_line_values[0]) return BEARISH;
   }
   
   if (Aroon_Method == ON_CROSS_AND_MAX){
      
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
double CalculateLotSize(double Risk_Percent, double Stop_Distance){
   
   double tick_size = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_SIZE);
   double tick_value = SymbolInfoDouble(_Symbol,SYMBOL_TRADE_TICK_VALUE);
   double lot_step = SymbolInfoDouble(_Symbol,SYMBOL_VOLUME_STEP);
   
   if (tick_size == 0 || tick_value == 0 || lot_step == 0){
      Print("Lot size could not be calculated");
      return 0;
   }
   
   double risk_money = AccountInfoDouble(ACCOUNT_BALANCE) * Risk_Percent / 100;
   double money_lot_step = (Stop_Distance / tick_size) * tick_value * lot_step;
   
   if (money_lot_step == 0){
      Print("Lot size could not be calculated.");
      return 0;
   }
   double lots = MathFloor(risk_money / money_lot_step) * lot_step;
   
   return lots;
}

//+------------------------------------------------------------------+
//| Enter Position Function                                          |
//+------------------------------------------------------------------+
void EnterPosition(TRADING_TERMS Entry_Type){
   
   double atr_channel_upper[],atr_channel_lower[];
   CopyBuffer(ATR_Channel_Handle,1,1,1,atr_channel_upper);
   CopyBuffer(ATR_Channel_Handle,2,1,1,atr_channel_lower);
   
   double ask_price = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double bid_price = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
   if (Entry_Type == GO_LONG){
      double stop_distance = ask_price - atr_channel_lower[0];
      double profit_distance = stop_distance * input_profit_factor;
      double stop_price = NormalizeDouble(atr_channel_lower[0],_Digits);
      double profit_price = NormalizeDouble((ask_price + profit_distance),_Digits);
      double lot_size = CalculateLotSize(input_risk_percent,stop_distance);
    
      if (trade.Buy(lot_size,_Symbol,ask_price,stop_price,profit_price)){
         if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
            Ticket_Number = trade.ResultOrder();
            In_Trade = true;
         }
      }
   }
   
   if (Entry_Type == GO_SHORT){
      double stop_distance = atr_channel_upper[0] - bid_price;
      double profit_distance = stop_distance * input_profit_factor;
      double stop_price = NormalizeDouble(atr_channel_upper[0],_Digits);
      double profit_price = NormalizeDouble((bid_price - profit_distance),_Digits);
      double lot_size = CalculateLotSize(input_risk_percent,stop_distance);
      
      if (trade.Sell(lot_size,_Symbol,bid_price,stop_price,profit_price)){
         if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
            Ticket_Number = trade.ResultOrder();
            In_Trade = true;
         }
      }
   }
}

//+------------------------------------------------------------------+
//| Position Check/Modify function:                                  |
//|------------------------------------------------------------------|
//|- Gets called every time there's a new bar.                       |
//+------------------------------------------------------------------+
void PositionCheckModify(TRADING_TERMS Trade_Signal){
   
   if (In_Trade == true){
      if (PositionSelectByTicket(Ticket_Number)){
         
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
            if (Trade_Signal == SELL_SIGNAL || Trade_Signal == BEARISH || Trade_Signal == NO_SIGNAL){
               if (trade.PositionClose(Ticket_Number)){
                  In_Trade = false;
                  Ticket_Number = 0;
               }
            }
         }
         if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
            if (Trade_Signal == BUY_SIGNAL || Trade_Signal == BULLISH || Trade_Signal == NO_SIGNAL){
               if (trade.PositionClose(Ticket_Number)){
                  In_Trade = false;
                  Ticket_Number = 0;
               }
            }
         }
      }
      else{
         In_Trade = false;
         Ticket_Number = 0;
      }
   }
}

//+------------------------------------------------------------------+
