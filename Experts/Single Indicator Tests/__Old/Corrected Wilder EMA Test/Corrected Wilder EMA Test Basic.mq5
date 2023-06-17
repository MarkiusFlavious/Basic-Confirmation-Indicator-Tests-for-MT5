//+------------------------------------------------------------------+
//| Includes:                                                        |
//+------------------------------------------------------------------+
#include "Corrected Wilder EMA Test Class.mqh"
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

input group "Corrected Wilder EMA Inputs"
input int input_avg_period = 14; // Average Period
input ENUM_APPLIED_PRICE input_avg_price = PRICE_CLOSE; // Applied Price
input int input_correction_period =  0; // "Correction" period (<0 no correction,0 to 1 same as average)
input COR_WIL_EMA_CHG_COLOR input_color_on = ON_LEVELS; // Color change on :
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
                                       input_avg_period,
                                       input_avg_price,
                                       input_correction_period,
                                       input_color_on,
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
