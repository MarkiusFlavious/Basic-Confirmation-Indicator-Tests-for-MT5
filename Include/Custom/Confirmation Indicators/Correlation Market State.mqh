/* ===========================================================================================================================
   | Includes                                                                                                                |
   =========================================================================================================================== */

#include <Custom/ConfirmationIndicator.mqh>

/* ===========================================================================================================================
   |                                                                                                                         |
   | Class: Correlation Market State                                                                                         |
   | -------------------------------                                                                                         |
   =========================================================================================================================== */

class CorrelationMarketState : public NumberCrossIndicator {

public:
   // Inputs: 
   int Cor_State_Period;
   
   // Functions:
                           CorrelationMarketState(void);
   void                    Initialize(void) override;
};

/* ===========================================================================================================================
   | Constructor                                                                                                             |
   =========================================================================================================================== */

CorrelationMarketState::CorrelationMarketState(void) {
   Line_Buffer = 2;
   Number_Cross = 0;
}

/* ===========================================================================================================================
   | Initialization Function                                                                                                 |
   =========================================================================================================================== */

void CorrelationMarketState::Initialize(void) override {
   Handle = iCustom(Pair,Timeframe,"Correlation market state.ex5", Cor_State_Period);
}