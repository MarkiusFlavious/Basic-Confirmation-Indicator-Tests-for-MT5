//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include "Aroon Test Class.mqh"
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
input ENUM_APPLIED_PRICE input_atr_channel_app_price = PRICE_TYPICAL; // ATR Channel Applied Price

input group "Aroon Inputs"
input int input_aroon_period = 9; // Aroon Period 
input int input_aroon_shift = 0; // Aroon Horizontal Shift
input AROON_METHOD input_aroon_method = ON_CROSS_AND_MAX; // Aroon Trading method
input int input_aroon_lookback = 3; // Aroon Lookback. Will break if lower than 3.
//+------------------------------------------------------------------+
//|Globals:                                                          |
//+------------------------------------------------------------------+
CSingleIndicatorTester Simple_Strategy(_Symbol,
                                       input_timeframe,
                                       input_risk_percent,
                                       input_profit_factor,
                                       input_atr_period,
                                       input_atr_channel_factor,
                                       input_atr_channel_app_price,
                                       input_aroon_period,
                                       input_aroon_shift,
                                       input_aroon_method,
                                       input_aroon_lookback);
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
