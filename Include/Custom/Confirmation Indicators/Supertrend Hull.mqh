/* ===========================================================================================================================
   | Includes                                                                                                                |
   =========================================================================================================================== */

#include <Custom/ConfirmationIndicator.mqh>

/* ===========================================================================================================================
   | Enum                                                                                                                    |
   =========================================================================================================================== */

enum SUPERTREND_HULL_PRICES {
   PR_CLOSE, // Close
   PR_OPEN, // Open
   PR_HIGH, // High
   PR_LOW, // Low
   PR_MEDIAN, // Median
   PR_TYPICAL, // Typical
   PR_WEIGHTED, // Weighted
   PR_AVERAGE // Average (high+low+oprn+close)/4
};

/* ===========================================================================================================================
   |                                                                                                                         |
   | Class: Supertrend Hull                                                                                                  |
   | ----------------------                                                                                                  |
   =========================================================================================================================== */

class SupertrendHull : public ColorChangeIndicator {

public:
   // Inputs:
   bool Trail_With_ST;
   int Hull_Period;
   SUPERTREND_HULL_PRICES Hull_Price;
   int ST_Atr_Period;
   double ST_Atr_Multiplier;
   
   // Functions:
                           SupertrendHull(void);
   void                    Initialize(void) override;
};

/* ===========================================================================================================================
   | Constructor                                                                                                             |
   =========================================================================================================================== */

SupertrendHull::SupertrendHull(void) {
   Color_Buffer = 1;
   Bullish_Color = 0;
   Bearish_Color = 1;
}

/* ===========================================================================================================================
   | Initialization Function                                                                                                 |
   =========================================================================================================================== */

void SupertrendHull::Initialize(void) override {
   Handle = iCustom(Pair,Timeframe,"Downloads\\super_trend_hull.ex5",Hull_Period,Hull_Price,ST_Atr_Period,ST_Atr_Multiplier);
}
