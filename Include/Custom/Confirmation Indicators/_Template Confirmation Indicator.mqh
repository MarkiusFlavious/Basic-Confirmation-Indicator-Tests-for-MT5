/* ===========================================================================================================================
   | Includes                                                                                                                |
   =========================================================================================================================== */

#include <Custom/ConfirmationIndicator.mqh>

/* ===========================================================================================================================
   |                                                                                                                         |
   | Class: Confirmation Indicator Template                                                                                  |
   | --------------------------------------                                                                                  |
   =========================================================================================================================== */
// ConfirmationIndicator, TwoLineCrossIndicator, NumberCrossIndicator, ColorChangeIndicator, DualMethodIndicator
class IndicatorTemplate : public ConfirmationIndicator {

public:
   // Inputs:
   
   // Functions:
                           IndicatorTemplate(void);
   void                    Initialize(void) override;
   //TRADING_TERMS           CheckSignal(int start_pos) override;
   //bool                    Lookback(int start_pos) override;
};

/* ===========================================================================================================================
   | Constructor                                                                                                             |
   =========================================================================================================================== */

IndicatorTemplate::IndicatorTemplate(void) {
   // The 3 types already have their buffer variables declared
   
   // Two Lines Cross has: int Fast_Line_Buffer, Slow_Line_Buffer
   // Number Cross has: int Line_Buffer, double Number_Cross
   // Color Change has: int Color_Buffer, double Bullish_Color, Bearish_Color
   // Dual Method has: Two Line and Number Cross variables
}

/* ===========================================================================================================================
   | Initialization Function                                                                                                 |
   =========================================================================================================================== */

void IndicatorTemplate::Initialize(void) override {
   Handle = iCustom(Pair,Timeframe,".ex5");
}
