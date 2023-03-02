#include "Aroon Test Class.mqh"
#include <Arrays/ArrayObj.mqh>
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "Use Current or Different Timeframe:"
input string input_pairs = "EURUSD,USDJPY,GBPUSD,USDCHF,USDCAD,AUDUSD,GBPJPY,NZDUSD,EURGBP,EURJPY,AUDCHF,AUDJPY,AUDNZD,CADCHF,CADJPY,CHFJPY,EURAUD,AUDCAD,EURCAD,NZDJPY,EURNZD,GBPAUD,GBPCAD,GBPCHF,GBPNZD,NZDCAD,NZDCHF"; // Input forex pairs only, seperated by commas and with no spaces.
input ENUM_TIMEFRAMES input_timeframe = PERIOD_CURRENT; // Timeframe

input group "Risk Inputs"
input double input_risk_percent = 1.0; // Risk Percent Per Trade
input double input_profit_factor = 1.5; // Profit factor
input uint input_atr_period = 25; // ATR Period
input double input_atr_channel_factor =1.5; // ATR Channel Factor
input ENUM_APPLIED_PRICE input_atr_channel_applied_price = PRICE_TYPICAL; // ATR Channel Applied Price

input group "Aroon Inputs"
input int input_aroon_period = 9; // Aroon Period 
input int input_aroon_shift = 0; // Aroon Horizontal Shift
input AROON_METHOD input_aroon_method = ON_CROSS_AND_MAX; // Aroon Trading method
input int input_aroon_lookback = 3; // Aroon Lookback. Will break if lower than 3.
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
                                                    input_aroon_period,
                                                    input_aroon_shift,
                                                    input_aroon_method,
                                                    input_aroon_lookback));
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
