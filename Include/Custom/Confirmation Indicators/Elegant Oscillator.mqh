/* ===========================================================================================================================
   | Includes                                                                                                                |
   =========================================================================================================================== */

#include <Custom/ConfirmationIndicator.mqh>

/* ===========================================================================================================================
   |                                                                                                                         |
   | Class: Elegant Oscillator                                                                                               |
   | -------------------------                                                                                               |
   =========================================================================================================================== */

class ElegantOscillator : public NumberCrossIndicator {

public:
   // Inputs:
   int Band_Edge;
   int Oscillator_Period;
   ENUM_APPLIED_PRICE Oscillator_Applied_Price;
   
   // Functions:
                           ElegantOscillator(void);
   void                    Initialize(void) override;
};

/* ===========================================================================================================================
   | Constructor                                                                                                             |
   =========================================================================================================================== */

ElegantOscillator::ElegantOscillator(void) {
   Line_Buffer = 0;
   Number_Cross = 0;
}

/* ===========================================================================================================================
   | Initialization Function                                                                                                 |
   =========================================================================================================================== */

void ElegantOscillator::Initialize(void) override {
   Handle = iCustom(Pair,Timeframe,"Elegant oscillator.ex5",Band_Edge,Oscillator_Period,Oscillator_Applied_Price);
}
