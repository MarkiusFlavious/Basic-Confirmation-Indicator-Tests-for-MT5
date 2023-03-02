//+------------------------------------------------------------------+
//| Includes:                                                        |
//+------------------------------------------------------------------+
#include <Trade/Trade.mqh>
//+------------------------------------------------------------------+
//| Custom Enums:                                                    |
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
enum DSL_DISPLAY{
   ZONES_YES = (int)true,   // Display filled zoned
   ZONES_NO  = (int)false,  // No filled zones display
};
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
input ENUM_APPLIED_PRICE input_atr_channel_ap = PRICE_TYPICAL; // ATR Channel Applied Price

input group "DSL RSI of Average Inputs"
input int input_rsi_period = 14; // RSI period
input int input_ma_period = 32; // Average period (<= 1 for no average)
input ENUM_MA_METHOD input_ma_method = MODE_EMA; // Average method
input ENUM_APPLIED_PRICE input_app_price = PRICE_CLOSE; // Price
input double input_signal_period = 9; // Dsl signal period
input DSL_DISPLAY input_zones  = ZONES_YES; // Zones display mode 
//+------------------------------------------------------------------+
//| Handles:                                                         |
//+------------------------------------------------------------------+
int ATR_Channel_Handle{};
int DSL_RSI_Average_Handle{};
//+------------------------------------------------------------------+
//| Other Globals:                                                   |
//+------------------------------------------------------------------+
int Bar_Total{};
ulong Ticket_Number{};
bool In_Trade = false;
CTrade trade;
//+------------------------------------------------------------------+
//| Expert Initialization Function:                                  |
//+------------------------------------------------------------------+
int OnInit(){
   
   Bar_Total = iBars(_Symbol,input_timeframe);
   ATR_Channel_Handle = iCustom(_Symbol,input_timeframe,"ATR Channel.ex5",MODE_SMA,1,input_atr_period,input_atr_channel_factor,input_atr_channel_ap);
   DSL_RSI_Average_Handle = iCustom(_Symbol,input_timeframe,"Dsl RSI of average.ex5",input_rsi_period,input_ma_period,input_ma_method,input_app_price,input_signal_period,input_zones);
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Expert Deinitialization Function:                                |
//+------------------------------------------------------------------+
void OnDeinit(const int reason){}
//+------------------------------------------------------------------+
//| Expert Tick Function:                                            |
//+------------------------------------------------------------------+
void OnTick(){
   int bar_total_current = iBars(_Symbol,input_timeframe);
   
   if (Bar_Total != bar_total_current){
      Bar_Total = bar_total_current;
    
      TRADING_TERMS trade_signal = LookForSignal();
      PositionCheckModify(trade_signal);
    
      if (In_Trade == false){
         if (trade_signal == BUY_SIGNAL) EnterPosition(GO_LONG);
         else if (trade_signal == SELL_SIGNAL) EnterPosition(GO_SHORT);
      }
   }  
}
//+------------------------------------------------------------------+
//| Look For Signal Function:                                        |
//+------------------------------------------------------------------+
//| - PositionCheckModify will close a position if it receives:      |
//|   - NO_SIGNAL                                                    |
//|   - An opposite signal to the current open position              |
//| - Line colour at buffer 5                                        |
//|   - Silver == 0, Green == 1, Orange == 2                         |
//+------------------------------------------------------------------+
TRADING_TERMS LookForSignal(){
   
   double line_colour[];
   CopyBuffer(DSL_RSI_Average_Handle,5,1,2,line_colour);
   ArrayReverse(line_colour);
   
   if (line_colour[0] == 1){
      if (line_colour[1] == 0 || line_colour[1] == 2) return BUY_SIGNAL;
      else return BULLISH;
   }
   else if (line_colour[0] == 2){
      if (line_colour[1] == 0 || line_colour[1] == 1) return SELL_SIGNAL;
      else return BEARISH;
   }
   return NO_SIGNAL;
}
//+------------------------------------------------------------------+
//| Lot Size Calculation Function:                                   |
//+------------------------------------------------------------------+
//| - Calculates lot sized based on percentage of account size       |
//| - Stop loss distance is calculated in the EnterPosition function |
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
//| Enter Position Function:                                         |
//+------------------------------------------------------------------+
//| - Uses ATR Channel for stop loss placement                       |
//| - The channel distance is placed at ATR * ATR_Channel_Factor     |
//+------------------------------------------------------------------+
void EnterPosition(TRADING_TERMS entry_type){
   
   double atr_channel_upper[],atr_channel_lower[];
   CopyBuffer(ATR_Channel_Handle,1,1,1,atr_channel_upper);
   CopyBuffer(ATR_Channel_Handle,2,1,1,atr_channel_lower);
   
   double ask_price = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_ASK),_Digits);
   double bid_price = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits);
   
   if (entry_type == GO_LONG){
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
   else if (entry_type == GO_SHORT){
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
//| Position Check/Modify Function:                                  |
//+------------------------------------------------------------------+
//| - Gets called every time there's a new bar                       |
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
         else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
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
