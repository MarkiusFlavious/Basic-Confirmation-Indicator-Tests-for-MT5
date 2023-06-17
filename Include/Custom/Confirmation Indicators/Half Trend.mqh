/* ===========================================================================================================================
   | Includes                                                                                                                |
   =========================================================================================================================== */

#include <Custom/ConfirmationIndicator.mqh>

/* ===========================================================================================================================
   |                                                                                                                         |
   | Class: Half Trend                                                                                                       |
   | -----------------                                                                                                       |
   =========================================================================================================================== */

class HalfTrend : public ColorChangeIndicator {

public:
   // Inputs:
   int Half_Trend_Amp;
    
   // Functions:
                           HalfTrend(void);
   void                    Initialize(void) override;
};

/* ===========================================================================================================================
   | Constructor                                                                                                             |
   =========================================================================================================================== */

HalfTrend::HalfTrend(void) {
   Color_Buffer = 1;
   Bullish_Color = 1;
   Bearish_Color = 0;
}

/* ===========================================================================================================================
   | Initialization Function                                                                                                 |
   =========================================================================================================================== */

void HalfTrend::Initialize(void) override {
   Handle = iCustom(Pair,Timeframe,"Half Trend New Alert.ex5",Half_Trend_Amp,"Arrow",233,234,10,"Alerts","alert.wav",3,3,false,false,false,false);
}
