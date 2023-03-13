//+------------------------------------------------------------------+
//| Includes:                                                        |
//+------------------------------------------------------------------+
#include "T3 Floating Levels Test Class.mqh"
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

input group "T3 Floating Levels V2 Inputs:"
input double input_t3_period = 25; // T3 period
input double input_t3_volume_factor = 0.7; // T3 volume factor
input T3_TYPE input_t3_calc_mode = FULKSMAT_T3; // T3 calculation mode
input ENUM_APPLIED_PRICE input_t3_app_price = PRICE_CLOSE; // Applied price
input T3_COLOR_CHG input_colour_chg = CHG_ON_LEVEL; // Color change on :
input int input_floating_period = 25; // Period for finding floating levels
input double input_floating_upper = 90; // Upper level %
input double input_floating_lower = 10; // Lower level %
//+------------------------------------------------------------------+
//|Global:                                                           |
//+------------------------------------------------------------------+
CSingleIndicatorTester Simple_Strategy(_Symbol,
                                       input_timeframe,
                                       input_risk_percent,
                                       input_profit_factor,
                                       input_atr_period,
                                       input_atr_channel_factor,
                                       input_atr_channel_app_price,
                                       input_trade_method,
                                       input_move_stop,
                                       input_trail_stop,
                                       input_t3_period,
                                       input_t3_volume_factor,
                                       input_t3_calc_mode,
                                       input_t3_app_price,
                                       input_colour_chg,
                                       input_floating_period,
                                       input_floating_upper,
                                       input_floating_lower);
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
