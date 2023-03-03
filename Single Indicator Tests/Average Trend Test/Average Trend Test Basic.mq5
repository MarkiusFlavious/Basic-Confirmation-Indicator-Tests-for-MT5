//+------------------------------------------------------------------+
//| Includes                                                         |
//+------------------------------------------------------------------+
#include "Average Trend Test Class.mqh"
//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+
input group "Use Current or Different Timeframe:"
input ENUM_TIMEFRAMES input_timeframe = PERIOD_CURRENT; // Timeframe

input group "Risk Inputs:"
input double input_risk_percent = 1.0; // Risk Percent Per Trade
input double input_profit_factor = 1.5; // Profit factor
input uint input_atr_period = 25; // ATR Period
input double input_atr_channel_factor =1.5; // ATR Channel Factor
input ENUM_APPLIED_PRICE input_atr_channel_app_price = PRICE_TYPICAL; // ATR Channel Applied Price

input group "Average Trend Inputs:"
input int input_atrend_period = 35; // Average Period
input ENUM_MA_METHOD input_atrend_method = MODE_EMA;    // Average Method
input ENUM_APPLIED_PRICE input_atrend_app_price = PRICE_CLOSE; // Applied Price
input double input_atrend_acceleration = 1.05; // Acceleration factor
//+------------------------------------------------------------------+
//|Globals:                                                          |
//+------------------------------------------------------------------+
<<<<<<< HEAD
=======
int Bar_Total{};
ulong Ticket_Number{};
bool In_Trade = false;
CTrade trade;
>>>>>>> main
CSingleIndicatorTester Simple_Strategy(_Symbol,
                                       input_timeframe,
                                       input_risk_percent,
                                       input_profit_factor,
                                       input_atr_period,
                                       input_atr_channel_factor,
                                       input_atr_channel_app_price,
                                       input_atrend_period,
                                       input_atrend_method,
                                       input_atrend_app_price,
                                       input_atrend_acceleration);
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
