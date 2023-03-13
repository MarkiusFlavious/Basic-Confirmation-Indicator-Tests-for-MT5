//+------------------------------------------------------------------+
//| Includes:                                                        |
//+------------------------------------------------------------------+
#include "Smoother STD Adaptive Test Class.mqh"
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

input group "STD Adaptive Inputs:"
input double input_smt_period = 15; // Calculation period
input SASTD_PRICES input_std_price  = PR_CLOSE; // Price to use
input int input_adaptive_period = 25; // Period for adapting
input SASTD_METHODS input_deviation_type = STD_CUST_SAM;  // Deviation calculation type
input int input_start_range = 24; // Colour values range 0-24(orange) 25-50(green.) Filter Mid range values between 
input int input_end_range = 25; // and
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
                                       input_smt_period,
                                       input_std_price,
                                       input_adaptive_period,
                                       input_deviation_type,
                                       input_start_range,
                                       input_end_range);
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
