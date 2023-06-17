#include "DSLU RSI Average Test Class.mqh"
#include <Arrays/ArrayObj.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "Currency Pairs and Timeframe Inputs:"
input string input_pairs = "EURUSD,USDJPY,GBPUSD,USDCHF,USDCAD,AUDUSD,GBPJPY,NZDUSD,EURGBP,EURJPY"; // Input forex pairs only, seperated by commas and with no spaces.
input ENUM_TIMEFRAMES input_timeframe = PERIOD_CURRENT; // Timeframe

input group "Risk Inputs:"
input double input_risk_percent = 1.0; // Risk Percent Per Trade
input double input_profit_factor = 1.5; // Profit factor
input uint input_atr_period = 25; // ATR Period
input double input_atr_channel_factor =1.5; // ATR Channel Factor
input ENUM_APPLIED_PRICE input_atr_channel_applied_price = PRICE_CLOSE; // ATR Channel Applied Price

input group "Trade Order Inputs:"
input TRADING_METHOD input_trade_method = SIMPLE; // Trade Order Method
input bool input_move_stop = true; // Move stop to break even after reaching profit target
input bool input_trail_stop = false; // Trail Stop after reaching target profit

input group "DSLU RSI of Average Inputs:"
input int input_rsi_period = 14; // RSI period
input int input_ma_period = 32; // Average period (<= 1 for no average)
input ENUM_MA_METHOD input_ma_method = MODE_EMA; // Average method
input ENUM_APPLIED_PRICE input_app_price = PRICE_CLOSE; // Applied Price
input double input_signal_period = 9; // Dsl signal period
input DSLU_DISPLAY input_zones = ZONES_YES; // Zones display mode 
//+------------------------------------------------------------------+
//| Globals                                                          |
//+------------------------------------------------------------------+
CArrayObj strategy_array;
string pair_array[];
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit(){
   // Validate String Input:
   ushort seperator = StringGetCharacter(input_pairs,6);
   StringSplit(input_pairs, seperator, pair_array);
   
   for (int pos = 0; pos < ArraySize(pair_array); pos++){
      if (StringLen(pair_array[pos]) != 6){
         Print("Error: Invalid Symbol Input Structure");
         return (INIT_FAILED);
      }
      else if (SymbolInfoInteger(pair_array[pos],SYMBOL_SECTOR) != SECTOR_CURRENCY){
         PrintFormat("Error: %s is not a valid Forex Symbol", pair_array[pos]);
         return (INIT_FAILED);
      }
   }
   // Populate strategy_array:
   for (int pos = 0; pos < ArraySize(pair_array); pos++){
      strategy_array.Add(new CSingleIndicatorTester(pair_array[pos],
                                                    input_timeframe,
                                                    input_risk_percent,
                                                    input_profit_factor,
                                                    input_atr_period,
                                                    input_atr_channel_factor,
                                                    input_atr_channel_applied_price,
                                                    input_trade_method,
                                                    input_move_stop,
                                                    input_trail_stop,
                                                    input_rsi_period,
                                                    input_ma_period,
                                                    input_ma_method,
                                                    input_app_price,
                                                    input_signal_period,
                                                    input_zones));
   }
   
   // Run OnInit Event:
   for (int pos = 0; pos < strategy_array.Total(); pos++){
      CSingleIndicatorTester* strategy_index = strategy_array.At(pos);
      strategy_index.OnInitEvent();
   }
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   for (int pos = 0; pos < strategy_array.Total(); pos++){
      CSingleIndicatorTester* strategy_index = strategy_array.At(pos);
      strategy_index.OnDeinitEvent(reason);
   }
}
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick(){
   for (int pos = 0; pos < strategy_array.Total(); pos++){
      CSingleIndicatorTester* strategy_index = strategy_array.At(pos);
      strategy_index.OnTickEvent();
   }
}
