/* ===========================================================================================================================
   | Includes                                                                                                                |
   =========================================================================================================================== */

#include <Custom/ConfirmationIndicator.mqh>
#include <SmoothAlgorithms.mqh>

/* ===========================================================================================================================
   |                                                                                                                         |
   | Class: Heiken Ashi Smoothed                                                                                             |
   | ---------------------------                                                                                             |
   =========================================================================================================================== */

class HeikenAshiSmoothed : public ColorChangeIndicator {

public:
   // Inputs: 
   Smooth_Method Smoothing_Method;
   int Smoothing_Length;                   
   int Smoothing_Phase;
   
   // Functions:
                           HeikenAshiSmoothed(void);
   void                    Initialize(void) override;
};

/* ===========================================================================================================================
   | Constructor                                                                                                             |
   =========================================================================================================================== */

HeikenAshiSmoothed::HeikenAshiSmoothed(void) {
   Color_Buffer = 4;
   Bullish_Color = 0;
   Bearish_Color = 1;
}

/* ===========================================================================================================================
   | Initialization Function                                                                                                 |
   =========================================================================================================================== */

void HeikenAshiSmoothed::Initialize(void) override {
   Handle = iCustom(Pair,Timeframe,"heiken_ashi_smoothed.ex5",Smoothing_Method,Smoothing_Length,Smoothing_Phase);
}
