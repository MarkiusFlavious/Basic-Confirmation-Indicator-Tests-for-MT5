//+------------------------------------------------------------------+
//| Includes:                                                        |
//+------------------------------------------------------------------+
#include "CorMarket Decycler Class.mqh"
//+------------------------------------------------------------------+
//| Inputs:                                                          |
//+------------------------------------------------------------------+
input group "Use Current or Different Timeframe:"
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

input group "Indicator Dominance:"
input DOMINANCE_MODE input_indicator_dominance = C1_DOMINANCE; // Dominance Mode

input group "Correlation Market State Inputs:"
input int input_cor_state_period = 35; // Period
input int input_cor_market_state_lookback_tolerance = 5; // Lookback Tolerance
input bool input_cor_market_state_is_exit = true; // Use As Exit

input group "Ehler's Decycler Oscillator Inputs:"
input int input_decycler_period1 = 10; // Period 1
input int input_decycler_period2 = 20; // Period 2
input int input_decycler_lookback_tolerance = 5; // Lookback Tolerance
input bool input_decycler_is_exit = false; // Use As Exit
//+------------------------------------------------------------------+
//|Global:                                                           |
//+------------------------------------------------------------------+
CDualIndicatorTest Simple_Strategy(_Symbol,
                                   input_timeframe,
                                   input_risk_percent,
                                   input_profit_factor,
                                   input_atr_period,
                                   input_atr_channel_factor,
                                   input_atr_channel_app_price,
                                   input_trade_method,
                                   input_move_stop,
                                   input_trail_stop,
                                   input_indicator_dominance,
                                   input_cor_state_period,
                                   input_cor_market_state_lookback_tolerance,
                                   input_cor_market_state_is_exit,
                                   input_decycler_period1,
                                   input_decycler_period2,
                                   input_decycler_lookback_tolerance,
                                   input_decycler_is_exit);
//+------------------------------------------------------------------+
//| Expert Initialization Function:                                  |
//+------------------------------------------------------------------+
int OnInit(){
   Simple_Strategy.OnInitEvent();
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert Deinitialization Function:                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){
   Simple_Strategy.OnDeinitEvent(reason);
}
//+------------------------------------------------------------------+
//| Expert Tick Function:                                            |
//+------------------------------------------------------------------+
void OnTick(){
   Simple_Strategy.OnTickEvent();  
}
