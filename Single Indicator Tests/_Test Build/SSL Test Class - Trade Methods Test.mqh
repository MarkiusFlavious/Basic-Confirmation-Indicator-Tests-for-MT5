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
enum TRADING_METHOD {
   SIMPLE, // Cap Profits
   SPLIT_ORDER, // Split Orders
   CLOSE_PARTIAL // Use Partial Close
};
struct TradeStatus {
   TRADING_METHOD       Trade_Method;
   bool                 Move_Stop;
   bool                 In_Trade;
   bool                 Modified;
   ulong                TicketA;
   ulong                TicketB;
   double               Profit_Target;
};
//+------------------------------------------------------------------+
//| Class CSingleIndicatorTester:                                    |
//+------------------------------------------------------------------+
//| - For Testing Confirmation Indicators                            |
//+------------------------------------------------------------------+
class CSingleIndicatorTester : public CObject {
private:
// Input Parameters:
   string Pair;
   ENUM_TIMEFRAMES Timeframe;
   // Risk Inputs:
   double Risk_Percent;
   double Profit_Factor;
   uint ATR_Period;
   double ATR_Channel_Factor;
   ENUM_APPLIED_PRICE ATR_Channel_App_Price;
   
   // SSL Inputs:
   ENUM_MA_METHOD SSL_MA_Method;
   int SSL_Period;

// Indicator Handles:
   int ATR_Channel_Handle;
   int SSL_Handle;
   
// Other Declarations:
   int Bar_Total;
   CTrade trade;
   TradeStatus TradePosition;
   
// Private Function Declaration:
   TRADING_TERMS        LookForSignal(void);
   double               CalculateLotSize(double risk_input, double stop_distance);
   void                 EnterPosition(TRADING_TERMS entry_type, TRADING_METHOD mode);
   void                 PositionCheckModify(TRADING_TERMS trade_signal,TRADING_METHOD mode);
   void                 PositionCheckModify(TRADING_METHOD mode);

public:
// Public Function/Constructor/Destructor Declaration:
                        CSingleIndicatorTester(string pair,
                                               ENUM_TIMEFRAMES timeframe,
                                               double risk_percent,
                                               double profit_factor,
                                               uint atr_period,
                                               double atr_channel_factor,
                                               ENUM_APPLIED_PRICE atr_channel_app_price,
                                               TRADING_METHOD trade_method,
                                               bool move_stop,
                                               ENUM_MA_METHOD ssl_ma_method,
                                               int ssl_period);
                        ~CSingleIndicatorTester(void);
   int                  OnInitEvent(void);
   void                 OnDeinitEvent(const int reason);
   void                 OnTickEvent(void);

};
//+------------------------------------------------------------------+
//| Constructor:                                                     |
//+------------------------------------------------------------------+
//| - Initialize inputs                                              |
//+------------------------------------------------------------------+
CSingleIndicatorTester::CSingleIndicatorTester(string pair,
                                               ENUM_TIMEFRAMES timeframe,
                                               double risk_percent,
                                               double profit_factor,
                                               uint atr_period,
                                               double atr_channel_factor,
                                               ENUM_APPLIED_PRICE atr_channel_app_price,
                                               TRADING_METHOD trade_method,
                                               bool move_stop,
                                               ENUM_MA_METHOD ssl_ma_method,
                                               int ssl_period){
   // Initialize Inputs
   Pair = pair;
   Timeframe = timeframe;
   
   Risk_Percent = risk_percent;
   Profit_Factor = profit_factor;
   ATR_Period = atr_period;
   ATR_Channel_Factor = atr_channel_factor;
   ATR_Channel_App_Price = atr_channel_app_price;
   
   TradePosition.Trade_Method = trade_method;
   TradePosition.Move_Stop = move_stop;
   
   SSL_MA_Method = ssl_ma_method;
   SSL_Period = ssl_period;
   
   // Other Variable Initialization
   Bar_Total = 0;
   TradePosition.In_Trade = false;
}
//+------------------------------------------------------------------+
//| Destructor:                                                      |
//+------------------------------------------------------------------+
CSingleIndicatorTester::~CSingleIndicatorTester(void){
}
//+------------------------------------------------------------------+
//| OnInit Event Function:                                           |
//+------------------------------------------------------------------+
int CSingleIndicatorTester::OnInitEvent(void){
   
   Bar_Total = iBars(Pair,Timeframe);
   ATR_Channel_Handle = iCustom(Pair,Timeframe,"ATR Channel.ex5",MODE_SMA,1,ATR_Period,ATR_Channel_Factor,ATR_Channel_App_Price);
   SSL_Handle = iCustom(Pair,Timeframe,"SSL_Channel_Chart.ex5",SSL_MA_Method,SSL_Period);
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| OnDeinit Event Function:                                         |
//+------------------------------------------------------------------+
void CSingleIndicatorTester::OnDeinitEvent(const int reason){}
//+------------------------------------------------------------------+
//| OnTick Event Function:                                           |
//+------------------------------------------------------------------+
void CSingleIndicatorTester::OnTickEvent(void){
   
   PositionCheckModify(TradePosition.Trade_Method);
   int Bar_Total_Current = iBars(Pair,Timeframe);
   
   if (Bar_Total != Bar_Total_Current){
      Bar_Total = Bar_Total_Current;
      
      TRADING_TERMS trade_signal = LookForSignal();
      PositionCheckModify(trade_signal,TradePosition.Trade_Method);
      
      if (!TradePosition.In_Trade){
         if (trade_signal == BUY_SIGNAL) EnterPosition(GO_LONG,TradePosition.Trade_Method);
         else if (trade_signal == SELL_SIGNAL) EnterPosition(GO_SHORT,TradePosition.Trade_Method);
      }
   }   
}
//+------------------------------------------------------------------+
//| Look For Signal Function:                                        |
//+------------------------------------------------------------------+
//| - PositionCheckModify will close a position if it receives:      |
//|   - NO_SIGNAL                                                    |
//|   - An opposite signal to the current open position              |
//| - Two Lines Cross:                                               |
//|   - When the blue line crosses the orange line we have a buy     |
//|     signal and vice versa                                        |
//|   - Bulls line buffer = 1 and bears line buffer = 0              |
//+------------------------------------------------------------------+
TRADING_TERMS CSingleIndicatorTester::LookForSignal(void){
   
   double bulls_line[],bears_line[];
   CopyBuffer(SSL_Handle,1,1,2,bulls_line);
   CopyBuffer(SSL_Handle,0,1,2,bears_line);
   ArrayReverse(bulls_line);
   ArrayReverse(bears_line);
   
   if (bulls_line[0] > bears_line[0]){
      if (bulls_line[1] < bears_line[1]) return BUY_SIGNAL;
      else return BULLISH;
   }
   else if (bulls_line[0] < bears_line[0]){
      if (bulls_line[1] > bears_line[1]) return SELL_SIGNAL;
      else return BEARISH;
   }
   else PrintFormat("Unexpected error when calling the function: %s", __FUNCTION__);
   return NO_SIGNAL;
}
//+------------------------------------------------------------------+
//| Lot Size Calculation Function:                                   |
//+------------------------------------------------------------------+
//| - Calculates lot sized based on percentage of account size       |
//| - Stop loss distance is calculated in the EnterPosition function |
//+------------------------------------------------------------------+
double CSingleIndicatorTester::CalculateLotSize(double risk_input,double stop_distance){
   
   double tick_size = SymbolInfoDouble(Pair,SYMBOL_TRADE_TICK_SIZE);
   double tick_value = SymbolInfoDouble(Pair,SYMBOL_TRADE_TICK_VALUE);
   double lot_step = SymbolInfoDouble(Pair,SYMBOL_VOLUME_STEP);
   
   if (tick_size == 0 || tick_value == 0 || lot_step == 0){
      Print("Error: Lot size could not be calculated");
      return 0;
   }
   
   double risk_money = AccountInfoDouble(ACCOUNT_BALANCE) * risk_input / 100;
   double money_lot_step = (stop_distance / tick_size) * tick_value * lot_step;
   
   if (money_lot_step == 0){
      Print("Lot Size could not be calculated.");
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
void CSingleIndicatorTester::EnterPosition(TRADING_TERMS entry_type, TRADING_METHOD mode){
   
   double atr_channel_upper[],atr_channel_lower[];
   CopyBuffer(ATR_Channel_Handle,1,1,1,atr_channel_upper);
   CopyBuffer(ATR_Channel_Handle,2,1,1,atr_channel_lower);
   
   int digits = (int)SymbolInfoInteger(Pair,SYMBOL_DIGITS);
   double ask_price = NormalizeDouble(SymbolInfoDouble(Pair,SYMBOL_ASK),digits);
   double bid_price = NormalizeDouble(SymbolInfoDouble(Pair,SYMBOL_BID),digits);
   double lot_step = SymbolInfoDouble(Pair,SYMBOL_VOLUME_STEP);
   
   if (entry_type == GO_LONG){
      double stop_distance = ask_price - atr_channel_lower[0];
      double profit_distance = stop_distance * Profit_Factor;
      double stop_price = NormalizeDouble(atr_channel_lower[0],digits);
      double profit_price = NormalizeDouble((ask_price + profit_distance),digits);
      double lot_size = CalculateLotSize(Risk_Percent,stop_distance);
      
      switch(mode) {
         case SIMPLE:
            if (trade.Buy(lot_size,Pair,ask_price,stop_price,profit_price)){
               if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
                  TradePosition.TicketA = trade.ResultOrder();
                  TradePosition.In_Trade = true;
               }
            }
            break;
         case CLOSE_PARTIAL:
            if ((lot_size/2) < lot_step){
               printf("%s > BUY could not be executed: Insufficient funds.",__FUNCTION__);
               break;
            }
            else if (trade.Buy(lot_size,Pair,ask_price,stop_price,0)){
               if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
                  TradePosition.TicketA = trade.ResultOrder();
                  TradePosition.In_Trade = true;
                  TradePosition.Profit_Target = profit_price;
               }
            }
            break;
         case SPLIT_ORDER:
            if ((lot_size/2) < lot_step){
               printf("%s > BUY could not be executed: Insufficient funds.",__FUNCTION__);
               break;
            }
            else {
               lot_size = MathFloor((lot_size/lot_step)/2)*lot_step;
               if (trade.Buy(lot_size,Pair,ask_price,stop_price,profit_price)){
                  if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
                     TradePosition.TicketA = trade.ResultOrder();
                  }
               }
               if (trade.Buy(lot_size,Pair,ask_price,stop_price,0)){
                  if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
                     TradePosition.TicketB = trade.ResultOrder();
                     TradePosition.In_Trade = true;
                  }
               }
            }
            break;
      }
   }
   else if (entry_type == GO_SHORT){
      double stop_distance = atr_channel_upper[0] - bid_price;
      double profit_distance = stop_distance * Profit_Factor;
      double stop_price = NormalizeDouble(atr_channel_upper[0],digits);
      double profit_price = NormalizeDouble((bid_price - profit_distance),digits);
      double lot_size = CalculateLotSize(Risk_Percent,stop_distance);
      
      switch(mode) {
         case SIMPLE:
            if (trade.Sell(lot_size,Pair,bid_price,stop_price,profit_price)){
               if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
                  TradePosition.TicketA = trade.ResultOrder();
                  TradePosition.In_Trade = true;
               }
            }
            break;
         case CLOSE_PARTIAL:
            if ((lot_size/2) < lot_step){
               printf("%s > SELL could not be executed: Insufficient funds.",__FUNCTION__);
               break;
            }
            else if (trade.Sell(lot_size,Pair,bid_price,stop_price,0)){
               if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
                  TradePosition.TicketA = trade.ResultOrder();
                  TradePosition.In_Trade = true;
                  TradePosition.Profit_Target = profit_price;
               }
            }
            break;
         case SPLIT_ORDER:
            if ((lot_size/2) < lot_step){
               printf("%s > BUY could not be executed: Insufficient funds.",__FUNCTION__);
               break;
            }
            else {
               lot_size = MathFloor((lot_size/lot_step)/2)*lot_step;
               if (trade.Sell(lot_size,Pair,bid_price,stop_price,profit_price)){
                  if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
                     TradePosition.TicketA = trade.ResultOrder();
                  }
               }
               if (trade.Sell(lot_size,Pair,bid_price,stop_price,0)){
                  if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
                     TradePosition.TicketB = trade.ResultOrder();
                     TradePosition.In_Trade = true;
                  }
               }
            }
            break;
      }
   }
}
//+------------------------------------------------------------------+
//| Position Check/Modify Function                                   |
//+------------------------------------------------------------------+
//|- Gets called every time there's a new bar                        |
//+------------------------------------------------------------------+
void CSingleIndicatorTester::PositionCheckModify(TRADING_METHOD mode){
   
   if (TradePosition.In_Trade == true && TradePosition.Modified == false){
      
      double ask_price = SymbolInfoDouble(Pair,SYMBOL_ASK);
      double bid_price = SymbolInfoDouble(Pair,SYMBOL_BID);
      double lot_step = SymbolInfoDouble(Pair,SYMBOL_VOLUME_STEP);
      
      switch (mode) {
         case SIMPLE:
            break;
         
         case CLOSE_PARTIAL:
            if (PositionSelectByTicket(TradePosition.TicketA)){
               double trade_volume = PositionGetDouble(POSITION_VOLUME);
               double close_volume = MathFloor((trade_volume/lot_step)/2)*lot_step;
               
               if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
                  if (ask_price >= TradePosition.Profit_Target){
                     if (trade.PositionClosePartial(TradePosition.TicketA,close_volume)){
                        TradePosition.Modified = true;
                     }
                     if (TradePosition.Move_Stop){
                        if (trade.PositionModify(TradePosition.TicketA,PositionGetDouble(POSITION_PRICE_OPEN),0)){
                           Print("Moved SL to break even");
                        }
                     }
                  }
               }
               else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
                  if (bid_price <= TradePosition.Profit_Target){
                     if (trade.PositionClosePartial(TradePosition.TicketA,close_volume)){
                        TradePosition.Modified = true;
                     }
                     if (TradePosition.Move_Stop){
                        if (trade.PositionModify(TradePosition.TicketA,PositionGetDouble(POSITION_PRICE_OPEN),0)){
                           Print("Moved SL to break even");
                        }
                     }
                  }
               }
            }
            else {
               TradePosition.TicketA = 0;
               TradePosition.Modified = false;
               TradePosition.In_Trade = false;
               TradePosition.Profit_Target = 0;
            }
            break;
         
         case SPLIT_ORDER:
            if (PositionSelectByTicket(TradePosition.TicketA)){
               break;
            }
            else if (PositionSelectByTicket(TradePosition.TicketB)){
               TradePosition.Modified = true;
               TradePosition.TicketA = 0;
               if (TradePosition.Move_Stop){
                  if (trade.PositionModify(TradePosition.TicketB,PositionGetDouble(POSITION_PRICE_OPEN),0)){
                     Print("Moved SL to break even");
                  }
               }
            }
            else {
               TradePosition.TicketA = 0;
               TradePosition.TicketB = 0;
               TradePosition.Modified = false;
               TradePosition.In_Trade = false;
            }
            break;
      }
   }
}

void CSingleIndicatorTester::PositionCheckModify(TRADING_TERMS trade_signal,TRADING_METHOD mode){
   
   if (TradePosition.In_Trade){
      if (TradePosition.Trade_Method == SIMPLE || TradePosition.Trade_Method == CLOSE_PARTIAL){
         if (PositionSelectByTicket(TradePosition.TicketA)){
         
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
               if (trade_signal == SELL_SIGNAL || trade_signal == BEARISH || trade_signal == NO_SIGNAL){
                  if (trade.PositionClose(TradePosition.TicketA)){
                     TradePosition.TicketA = 0;
                     TradePosition.In_Trade = false;
                     TradePosition.Modified = false;
                     TradePosition.Profit_Target = 0;
                  }
               }
            }
            else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
               if (trade_signal == BUY_SIGNAL || trade_signal == BULLISH || trade_signal == NO_SIGNAL){
                  if (trade.PositionClose(TradePosition.TicketA)){
                     TradePosition.TicketA = 0;
                     TradePosition.In_Trade = false;
                     TradePosition.Modified = false;
                     TradePosition.Profit_Target = 0;
                  }
               }
            } 
         }
         else{ // If we cannot select the trade, it has either hit the tp or sl.
            TradePosition.TicketA = 0;
            TradePosition.In_Trade = false;
            TradePosition.Modified = false;
            TradePosition.Profit_Target = 0;
         }
      }
      else if (TradePosition.Trade_Method == SPLIT_ORDER){
         if (TradePosition.Modified){
            if (PositionSelectByTicket(TradePosition.TicketB)){
               if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
                  if (trade_signal == SELL_SIGNAL || trade_signal == BEARISH || trade_signal == NO_SIGNAL){
                     if (trade.PositionClose(TradePosition.TicketB)){
                        TradePosition.TicketB = 0;
                        TradePosition.In_Trade = false;
                        TradePosition.Modified = false;
                     }
                  }
               }
               else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
                  if (trade_signal == BUY_SIGNAL || trade_signal == BULLISH || trade_signal == NO_SIGNAL){
                     if (trade.PositionClose(TradePosition.TicketB)){
                        TradePosition.TicketB = 0;
                        TradePosition.In_Trade = false;
                        TradePosition.Modified = false;
                     }
                  }
               } 
            }
            else{
               TradePosition.TicketB = 0;
               TradePosition.Modified = false;
               TradePosition.In_Trade = false;
            }
         }
         else if (PositionSelectByTicket(TradePosition.TicketA) && PositionSelectByTicket(TradePosition.TicketB)){
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
               if (trade_signal == SELL_SIGNAL || trade_signal == BEARISH || trade_signal == NO_SIGNAL){
                  if (trade.PositionClose(TradePosition.TicketA)){
                     TradePosition.TicketA = 0;
                  }
                  if (trade.PositionClose(TradePosition.TicketB)){
                     TradePosition.TicketB = 0;
                     TradePosition.In_Trade = false;
                     TradePosition.Modified = false;
                  }
               }
            }
            else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
               if (trade_signal == BUY_SIGNAL || trade_signal == BULLISH || trade_signal == NO_SIGNAL){
                  if (trade.PositionClose(TradePosition.TicketA)){
                     TradePosition.TicketA = 0;
                  }
                  if (trade.PositionClose(TradePosition.TicketB)){
                     TradePosition.TicketB = 0;
                     TradePosition.In_Trade = false;
                     TradePosition.Modified = false;
                  }
               }
            }
         }
      }
   }
}
