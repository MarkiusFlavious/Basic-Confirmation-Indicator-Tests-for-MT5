#include <Trade/Trade.mqh>
#include <Custom/TradingTerms.mqh>
#include <Custom/Confirmation Indicators/Correlation Market State.mqh>
#include <Custom/Confirmation Indicators/Ehlers Decycler Oscillator.mqh>
//+------------------------------------------------------------------+
//| Struct for tracking positions:                                   |
//+------------------------------------------------------------------+
struct TradeStatus {
   TRADING_METHOD       Trade_Method;
   bool                 Move_Stop;
   bool                 Trail_Stop;
   bool                 In_Trade;
   bool                 Modified;
   ulong                TicketA;
   ulong                TicketB;
   double               Profit_Target;
};
//+------------------------------------------------------------------+
//| Class CDualIndicatorTester:                                      |
//+------------------------------------------------------------------+
//| - For Testing Confirmation Indicators                            |
//+------------------------------------------------------------------+
class CDualIndicatorTest : public CObject {
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
   
// Indicators:
   CorrelationMarketState C1_CorrelationMarketState;
   EhlersDecyclerOscillator C2_EhlersDecyclerOscillator;

// Indicator Handles:
   int ATR_Channel_Handle;
   
// Other Declarations:
   int Bar_Total;
   CTrade trade;
   TradeStatus TradePosition;
   DOMINANCE_MODE Indicator_Dominance_Mode;
   
// Private Function Declaration:
   TRADING_TERMS        LookForSignal(void);
   TRADING_TERMS        CheckConfirmationIncidcators(void);
   TRADING_TERMS        CheckExit(void);
   double               CalculateLotSize(double risk_input, double stop_distance);
   void                 EnterPosition(TRADING_TERMS entry_type);
   void                 OpenTrade(TRADING_TERMS entry_type, double lot_size, double entry_price, double sl_price, double tp_price);
   void                 PositionCheckModify(void);
   void                 PositionCheckModify(TRADING_TERMS trade_signal);
   void                 TrailStop(void);
   void                 CloseTrade(void);
   void                 ResetTradeInfo(void);

public:
// Public Function/Constructor/Destructor Declaration:
                        CDualIndicatorTest(string pair,
                                             ENUM_TIMEFRAMES timeframe,
                                             double risk_percent,
                                             double profit_factor,
                                             uint atr_period,
                                             double atr_channel_factor,
                                             ENUM_APPLIED_PRICE atr_channel_app_price,
                                             TRADING_METHOD trade_method,
                                             bool move_stop,
                                             bool trail_stop,
                                             DOMINANCE_MODE indicator_dominance_mode,
                                             int cor_state_period,
                                             int cor_market_state_lookback_tolerance,
                                             bool cor_market_state_is_exit,
                                             int decycler_period1,
                                             int decycler_period2,
                                             int decycler_lookback_tolerance,
                                             bool decycler_is_exit);
                        ~CDualIndicatorTest(void);
   int                  OnInitEvent(void);
   void                 OnDeinitEvent(const int reason);
   void                 OnTickEvent(void);

};
//+------------------------------------------------------------------+
//| Constructor:                                                     |
//+------------------------------------------------------------------+
//| - Initialize inputs                                              |
//+------------------------------------------------------------------+
CDualIndicatorTest::CDualIndicatorTest(string pair,
                                           ENUM_TIMEFRAMES timeframe,
                                           double risk_percent,
                                           double profit_factor,
                                           uint atr_period,
                                           double atr_channel_factor,
                                           ENUM_APPLIED_PRICE atr_channel_app_price,
                                           TRADING_METHOD trade_method,
                                           bool move_stop,
                                           bool trail_stop,
                                           DOMINANCE_MODE indicator_dominance_mode,
                                           int cor_state_period,
                                           int cor_market_state_lookback_tolerance,
                                           bool cor_market_state_is_exit,
                                           int decycler_period1,
                                           int decycler_period2,
                                           int decycler_lookback_tolerance,
                                           bool decycler_is_exit){
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
   TradePosition.Trail_Stop = trail_stop;
   
   Indicator_Dominance_Mode = indicator_dominance_mode;
   
   C1_CorrelationMarketState.Pair = pair;
   C1_CorrelationMarketState.Timeframe = timeframe;
   C1_CorrelationMarketState.Cor_State_Period = cor_state_period;
   C1_CorrelationMarketState.Tolerance = cor_market_state_lookback_tolerance;
   C1_CorrelationMarketState.Is_Exit_Indicator = cor_market_state_is_exit;
   
   C2_EhlersDecyclerOscillator.Pair = pair;
   C2_EhlersDecyclerOscillator.Timeframe = timeframe;
   C2_EhlersDecyclerOscillator.Decycler_Period1 = decycler_period1;
   C2_EhlersDecyclerOscillator.Decycler_Period2 = decycler_period2;
   C2_EhlersDecyclerOscillator.Tolerance = decycler_lookback_tolerance;
   C2_EhlersDecyclerOscillator.Is_Exit_Indicator = decycler_is_exit;
   
   // Other Variable Initialization
   Bar_Total = 0;
   ResetTradeInfo(); 
}
//+------------------------------------------------------------------+
//| Destructor:                                                      |
//+------------------------------------------------------------------+
CDualIndicatorTest::~CDualIndicatorTest(void){
}
//+------------------------------------------------------------------+
//| OnInit Event Function:                                           |
//+------------------------------------------------------------------+
int CDualIndicatorTest::OnInitEvent(void){
   
   Bar_Total = iBars(Pair,Timeframe);
   ATR_Channel_Handle = iCustom(Pair,Timeframe,"ATR Channel.ex5",MODE_SMA,1,ATR_Period,ATR_Channel_Factor,ATR_Channel_App_Price);
   C1_CorrelationMarketState.Initialize();
   C2_EhlersDecyclerOscillator.Initialize();
   
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| OnDeinit Event Function:                                         |
//+------------------------------------------------------------------+
void CDualIndicatorTest::OnDeinitEvent(const int reason){}
//+------------------------------------------------------------------+
//| OnTick Event Function:                                           |
//+------------------------------------------------------------------+
void CDualIndicatorTest::OnTickEvent(void){
  
   PositionCheckModify();
   int bar_total_current = iBars(Pair,Timeframe);
   
   if (Bar_Total != bar_total_current){
      Bar_Total = bar_total_current;
      
      if (TradePosition.In_Trade){
         TRADING_TERMS exit_signal = CheckExit();
         PositionCheckModify(exit_signal);
         TrailStop();
      }
      if (!TradePosition.In_Trade){
         TRADING_TERMS trade_signal = LookForSignal();
         if (trade_signal == BUY_SIGNAL) EnterPosition(GO_LONG);
         else if (trade_signal == SELL_SIGNAL) EnterPosition(GO_SHORT);
      }
   }
}
//+------------------------------------------------------------------+
//| Look For Signal Function:                                        |
//+------------------------------------------------------------------+
//| - For now it will just return Check Confirmation Indicators      |
//|   - We will apply other filters here in time                     |
//+------------------------------------------------------------------+
TRADING_TERMS CDualIndicatorTest::LookForSignal(void){
   return CheckConfirmationIncidcators();
}
//+------------------------------------------------------------------+
//| Check Confirmation Indicators Function:                          |
//+------------------------------------------------------------------+
//| - We can test between C1, C2 or dual dominance                   |
//| - The main or dominant indicator initiates the check             |
//|   - The other indicator must agree and have had the same signal  |
//|     within the allowed amount of bars                            |
//+------------------------------------------------------------------+
TRADING_TERMS CDualIndicatorTest::CheckConfirmationIncidcators(void){
   
   TRADING_TERMS c1_signal = C1_CorrelationMarketState.CheckSignal(1);
   TRADING_TERMS c2_signal = C2_EhlersDecyclerOscillator.CheckSignal(1);
   bool c1_lookback = C1_CorrelationMarketState.Lookback(1);
   bool c2_lookback = C2_EhlersDecyclerOscillator.Lookback(1);
   
   switch (Indicator_Dominance_Mode) {
      
      case C1_DOMINANCE:
         if (c1_signal == BUY_SIGNAL){
            if (c2_signal == BUY_SIGNAL) return BUY_SIGNAL;
            else if (c2_signal == BULLISH && c2_lookback) return BUY_SIGNAL;
         }
         else if (c1_signal == SELL_SIGNAL){
            if (c2_signal == SELL_SIGNAL) return SELL_SIGNAL;
            else if (c2_signal == BEARISH && c2_lookback) return SELL_SIGNAL;
         }
         break;
         
      case C2_DOMINANCE:
         if (c2_signal == BUY_SIGNAL){
            if (c1_signal == BUY_SIGNAL) return BUY_SIGNAL;
            else if (c1_signal == BULLISH && c1_lookback) return BUY_SIGNAL;
         }
         else if (c2_signal == SELL_SIGNAL){
            if (c1_signal == SELL_SIGNAL) return SELL_SIGNAL;
            else if (c1_signal == BEARISH && c1_lookback) return SELL_SIGNAL;
         }
         break;
      
      case DUAL_DOMINANCE:
         if (c1_signal == BUY_SIGNAL || c2_signal == BUY_SIGNAL){
            if (c1_signal == BUY_SIGNAL && c2_signal == BUY_SIGNAL) return BUY_SIGNAL;
            else if (c1_signal == BULLISH && c1_lookback) return BUY_SIGNAL;
            else if (c2_signal == BULLISH && c2_lookback) return BUY_SIGNAL;
         }
         else if (c1_signal == SELL_SIGNAL || c2_signal == SELL_SIGNAL){
            if(c1_signal == SELL_SIGNAL && c2_signal == SELL_SIGNAL) return SELL_SIGNAL;
            else if (c1_signal == BEARISH && c1_lookback) return SELL_SIGNAL;
            else if (c2_signal == BEARISH && c2_lookback) return SELL_SIGNAL;
         }
         break;
   }
   return NO_SIGNAL;
}
//+------------------------------------------------------------------+
//| Check Exit Function:                                             |
//+------------------------------------------------------------------+
//| - In order for this to work, we should have either one or        |
//|   both indicators triggering exits                               |
//+------------------------------------------------------------------+
TRADING_TERMS CDualIndicatorTest::CheckExit(void){

   if (C1_CorrelationMarketState.Is_Exit_Indicator && !C2_EhlersDecyclerOscillator.Is_Exit_Indicator){
      return C1_CorrelationMarketState.CheckSignal(1);
   }
   else if (C2_EhlersDecyclerOscillator.Is_Exit_Indicator && !C1_CorrelationMarketState.Is_Exit_Indicator){
      return C2_EhlersDecyclerOscillator.CheckSignal(1);
   }
   else {
      TRADING_TERMS c1_signal = C1_CorrelationMarketState.CheckSignal(1);
      TRADING_TERMS c2_signal = C2_EhlersDecyclerOscillator.CheckSignal(1);
      
      if (c1_signal == BUY_SIGNAL || c1_signal == BULLISH){
         if (c2_signal == BUY_SIGNAL || c2_signal == BULLISH) return BULLISH;
         else return NO_SIGNAL;
      }
      else if (c1_signal == SELL_SIGNAL || c1_signal == BEARISH){
         if (c2_signal == SELL_SIGNAL || c2_signal == BEARISH) return BEARISH;
         else return NO_SIGNAL;
      }
   }
   return NO_SIGNAL;
}
//+------------------------------------------------------------------+
//| Lot Size Calculation Function:                                   |
//+------------------------------------------------------------------+
//| - Calculates lot sized based on percentage of account size       |
//| - Stop loss distance is calculated in the EnterPosition function |
//+------------------------------------------------------------------+
double CDualIndicatorTest::CalculateLotSize(double risk_input,double stop_distance){
   
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
void CDualIndicatorTest::EnterPosition(TRADING_TERMS entry_type){
   
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
      OpenTrade(GO_LONG,lot_size,ask_price,stop_price,profit_price);
   }
   else if (entry_type == GO_SHORT){
      double stop_distance = atr_channel_upper[0] - bid_price;
      double profit_distance = stop_distance * Profit_Factor;
      double stop_price = NormalizeDouble(atr_channel_upper[0],digits);
      double profit_price = NormalizeDouble((bid_price - profit_distance),digits);
      double lot_size = CalculateLotSize(Risk_Percent,stop_distance);
      OpenTrade(GO_SHORT,lot_size,bid_price,stop_price,profit_price);
   }
}
//+------------------------------------------------------------------+
//| Open Trade Function:                                             |
//+------------------------------------------------------------------+
void CDualIndicatorTest::OpenTrade(TRADING_TERMS entry_type,double lot_size,double entry_price,double sl_price,double tp_price){

   double lot_step = SymbolInfoDouble(Pair,SYMBOL_VOLUME_STEP);
   switch(TradePosition.Trade_Method) {
   
      case SIMPLE:
         if (entry_type == GO_LONG){
            if (trade.Buy(lot_size,Pair,entry_price,sl_price,tp_price)){
               if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
                  TradePosition.TicketA = trade.ResultOrder();
                  TradePosition.In_Trade = true;
                  break;
               }
               else {
                  printf("An unexpected error occured. TRADE RETCODE != DONE.");
                  break;
               }
            }
         }
         else if (trade.Sell(lot_size,Pair,entry_price,sl_price,tp_price)){
            if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
               TradePosition.TicketA = trade.ResultOrder();
               TradePosition.In_Trade = true;
               break;
            }
            else {
               printf("An unexpected error occured. TRADE RETCODE != DONE.");
               break;
            }
         }
         break;
      
      case CLOSE_PARTIAL:
         if ((lot_size/2) < lot_step){
            printf("%s > Trade could not be executed: Insufficient fund for Partial Close.",__FUNCTION__);
            break;
         }
         else if (entry_type == GO_LONG){
            if (trade.Buy(lot_size,Pair,entry_price,sl_price,0)){
               if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
                  TradePosition.TicketA = trade.ResultOrder();
                  TradePosition.In_Trade = true;
                  TradePosition.Profit_Target = tp_price;
                  break;
               }
               else {
                  printf("An Unexpected error occured. TRADE RETCODE != DONE.");
                  break;
               }
            }
         }
         else if (trade.Sell(lot_size,Pair,entry_price,sl_price,0)){
            if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
               TradePosition.TicketA = trade.ResultOrder();
               TradePosition.In_Trade = true;
               TradePosition.Profit_Target = tp_price;
               break;
            }
            else {
               printf("An unexpected error occured. TRADE RETCODE != DONE.");
               break;
            }
         }
         break;
      
      case SPLIT_ORDER:
         if ((lot_size/2) < lot_step){
            printf("%s > Trade could not be executed: Insufficient fund for Split Order.",__FUNCTION__);
            break;
         }
         else if (entry_type == GO_LONG){
            if (trade.Buy(lot_size,Pair,entry_price,sl_price,tp_price)){
               if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
                  TradePosition.TicketA = trade.ResultOrder();
               }
               else {
                  printf("An unexpected error occured. TRADE RETCODE != DONE.");
                  break;
               }
            }
            if (trade.Buy(lot_size,Pair,entry_price,sl_price,0)){
               if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
                  TradePosition.TicketB = trade.ResultOrder();
                  TradePosition.In_Trade = true;
                  break;
               }
               else {
                  printf("An unexpected error occured. TRADE RETCODE != DONE. Order partially filled");
                  break;
               }
            }
         }
         else{
            if (trade.Sell(lot_size,Pair,entry_price,sl_price,tp_price)){
               if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
                  TradePosition.TicketA = trade.ResultOrder();
               }
               else {
                  printf("An unexpected error occured. TRADE RETCODE != DONE.");
                  break;
               }
            }
            if (trade.Sell(lot_size,Pair,entry_price,sl_price,0)){
               if (trade.ResultRetcode() == TRADE_RETCODE_DONE){
                  TradePosition.TicketB = trade.ResultOrder();
                  TradePosition.In_Trade = true;
                  break;
               }
               else {
                  printf("An unexpected error occured. TRADE RETCODE != DONE. Order partially filled");
                  break;
               }
            }
         }
         break;
   }
}
//+------------------------------------------------------------------+
//| Position Check/Modify Function:                                  |
//+------------------------------------------------------------------+
//|- Gets called every tick                                          |
//+------------------------------------------------------------------+
void CDualIndicatorTest::PositionCheckModify(void){
   
   if (TradePosition.In_Trade && !TradePosition.Modified){
      
      double ask_price = SymbolInfoDouble(Pair,SYMBOL_ASK);
      double bid_price = SymbolInfoDouble(Pair,SYMBOL_BID);
      double lot_step = SymbolInfoDouble(Pair,SYMBOL_VOLUME_STEP);
      
      switch (TradePosition.Trade_Method) {
         case SIMPLE: break;
         
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
            else ResetTradeInfo();
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
            else ResetTradeInfo();
            break;
      }
   }
}
//+------------------------------------------------------------------+
//| Position Check/Modify Function                                   |
//+------------------------------------------------------------------+
//|- Gets called every time there's a new bar                        |
//+------------------------------------------------------------------+
void CDualIndicatorTest::PositionCheckModify(TRADING_TERMS trade_signal){
   
   if (TradePosition.In_Trade){
   
      switch(TradePosition.Trade_Method) {
         case SPLIT_ORDER:
            if (PositionSelectByTicket(TradePosition.TicketB)){
               if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
                  if (trade_signal == SELL_SIGNAL || trade_signal == BEARISH || trade_signal == NO_SIGNAL) CloseTrade();
               }
               else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
                  if (trade_signal == BUY_SIGNAL || trade_signal == BULLISH || trade_signal == NO_SIGNAL) CloseTrade();
               }
            }
            else ResetTradeInfo();
            break;
         default:
            if (PositionSelectByTicket(TradePosition.TicketA)){
               if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
                  if (trade_signal == SELL_SIGNAL || trade_signal == BEARISH || trade_signal == NO_SIGNAL) CloseTrade();
               }
               else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
                  if (trade_signal == BUY_SIGNAL || trade_signal == BULLISH || trade_signal == NO_SIGNAL) CloseTrade();
               }
            }
            else ResetTradeInfo(); 
            break;
      }
   }
}
//+------------------------------------------------------------------+
//| Trail Stop Function:                                             |
//+------------------------------------------------------------------+
void CDualIndicatorTest::TrailStop(void){
   if (TradePosition.Trail_Stop && TradePosition.Modified){
      double atr_upper[],atr_lower[];
      CopyBuffer(ATR_Channel_Handle,1,1,1,atr_upper);
      CopyBuffer(ATR_Channel_Handle,2,1,1,atr_lower);
      int digits = (int)SymbolInfoInteger(Pair,SYMBOL_DIGITS);
      
      if (TradePosition.Trade_Method == CLOSE_PARTIAL){
         if (PositionSelectByTicket(TradePosition.TicketA)){
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
               double new_stop = NormalizeDouble(atr_lower[0],digits);
               if (new_stop > PositionGetDouble(POSITION_SL)) trade.PositionModify(TradePosition.TicketA,new_stop,0);
            }
            else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
               double new_stop = NormalizeDouble(atr_upper[0],digits);
               if (new_stop < PositionGetDouble(POSITION_SL)) trade.PositionModify(TradePosition.TicketA,new_stop,0);
            }
         }
      }
      else if (TradePosition.Trade_Method == SPLIT_ORDER){
         if (PositionSelectByTicket(TradePosition.TicketB)){
            if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_BUY){
               double new_stop = NormalizeDouble(atr_lower[0],digits);
               if (new_stop > PositionGetDouble(POSITION_SL)) trade.PositionModify(TradePosition.TicketB,new_stop,0);
            }
            else if (PositionGetInteger(POSITION_TYPE) == POSITION_TYPE_SELL){
               double new_stop = NormalizeDouble(atr_upper[0],digits);
               if (new_stop < PositionGetDouble(POSITION_SL)) trade.PositionModify(TradePosition.TicketB,new_stop,0);
            }
         }
      }
   }
}
//+------------------------------------------------------------------+
//| Close Position Function:                                         |
//+------------------------------------------------------------------+
void CDualIndicatorTest::CloseTrade(void){
   switch(TradePosition.Trade_Method) {
      case SPLIT_ORDER:
         if(!TradePosition.Modified){
            if (trade.PositionClose(TradePosition.TicketA) && trade.PositionClose(TradePosition.TicketB)) ResetTradeInfo();
         }
         else {
            if (trade.PositionClose(TradePosition.TicketB)) ResetTradeInfo();
         }
         break;
      default:
         if (trade.PositionClose(TradePosition.TicketA)) ResetTradeInfo();
         break;
   }
}
//+------------------------------------------------------------------+
//| Reset Trade Tracking Info Function:                              |
//+------------------------------------------------------------------+
void CDualIndicatorTest::ResetTradeInfo(void){
   TradePosition.In_Trade = false;
   TradePosition.Modified = false;
   TradePosition.TicketA = 0;
   TradePosition.TicketB = 0;
   TradePosition.Profit_Target = 0;
}
