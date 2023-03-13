#include "Trend Rider Test Class.mqh"
#include <Arrays/ArrayObj.mqh>
//+------------------------------------------------------------------+
//| Inputs:                                                          |
//+------------------------------------------------------------------+
input group "Currency Pairs and Timeframe Inputs:"
input string input_pairs = "EURUSD,USDJPY,GBPUSD,USDCHF,USDCAD,AUDUSD,GBPJPY,NZDUSD,EURGBP,EURJPY"; // Input forex pairs only, seperated by commas and with no spaces.
input ENUM_TIMEFRAMES input_timeframe = PERIOD_CURRENT; // Timeframe

input group "Risk Inputs:"
input double input_risk_percent = 1.0; // Risk Percent Per Trade
input double input_profit_factor = 1.5; // Profit factor
input uint input_atr_period = 25; // ATR Period
input double input_atr_channel_factor =1.5; // ATR Channel Factor
input ENUM_APPLIED_PRICE input_atr_channel_app_price = PRICE_CLOSE; // ATR Channel Applied Price

input group "Trade Order Inputs:"
input TRADING_METHOD input_trade_method = SIMPLE; // Trade Order Method
input bool input_move_stop = true; // Move stop to break even after reaching profit target
input bool input_trail_stop = false; // Trail Stop after reaching target profit
input bool input_trail_with_trend_rider = false; // Use Trend Rider for trailing stop placement

input group "Trend Rider Inputs:"
input int input_trend_rider_atr_length = 10; // ATR calculaion period
input double input_trend_rider_atr_multiplier = 3.0; // ATR multiplier
input ENUM_APPLIED_PRICE input_trend_rider_atr_app_price = PRICE_CLOSE; // ATR Applied Price
input int input_trend_rider_rsi_period = 14; // RSI Period
input ENUM_APPLIED_PRICE input_trend_rider_rsi_app_price = PRICE_CLOSE; // RSI Applied Price
input int input_trend_rider_macd_fast_ema = 12; // MACD Fast Period
input int input_trend_rider_macd_slow_ema = 26; // MACD Slow Period
input int input_trend_rider_macd_signal_ema = 9; // MACD Signal period
input ENUM_APPLIED_PRICE input_trend_rider_macd_app_price = PRICE_CLOSE; // MACD Applied Price
//+------------------------------------------------------------------+
//| Globals:                                                         |
//+------------------------------------------------------------------+
CArrayObj strategy_array;
string pair_array[];
//+------------------------------------------------------------------+
//| Expert Initialization Function:                                  |
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
                                                    input_atr_channel_app_price,
                                                    input_trade_method,
                                                    input_move_stop,
                                                    input_trail_stop,
                                                    input_trail_with_trend_rider,
                                                    input_trend_rider_atr_length,
                                                    input_trend_rider_atr_multiplier,
                                                    input_trend_rider_atr_app_price,
                                                    input_trend_rider_rsi_period,
                                                    input_trend_rider_rsi_app_price,
                                                    input_trend_rider_macd_fast_ema,
                                                    input_trend_rider_macd_slow_ema,
                                                    input_trend_rider_macd_signal_ema,
                                                    input_trend_rider_macd_app_price));
   }
   
   // Run OnInit Event:
   for (int pos = 0; pos < strategy_array.Total(); pos++){
      CSingleIndicatorTester* strategy_index = strategy_array.At(pos);
      strategy_index.OnInitEvent();
   }
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert Deinitialization Function:                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   for (int pos = 0; pos < strategy_array.Total(); pos++){
      CSingleIndicatorTester* strategy_index = strategy_array.At(pos);
      strategy_index.OnDeinitEvent(reason);
   }
}
//+------------------------------------------------------------------+
//| Expert Tick Function:                                            |
//+------------------------------------------------------------------+
void OnTick(){
   for (int pos = 0; pos < strategy_array.Total(); pos++){
      CSingleIndicatorTester* strategy_index = strategy_array.At(pos);
      strategy_index.OnTickEvent();
   }
}
