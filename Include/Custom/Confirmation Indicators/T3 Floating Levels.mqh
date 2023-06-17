/* ===========================================================================================================================
   | Includes                                                                                                                |
   =========================================================================================================================== */

#include <Custom/ConfirmationIndicator.mqh>

/* ===========================================================================================================================
   | Enums                                                                                                                   |
   =========================================================================================================================== */

enum T3_TYPE {
   TILLSON_T3  = (int)true,  // Tim Tillson way of calculation
   FULKSMAT_T3 = int(false), // Fulks/Matulich way of calculation
};
   
enum T3_COLOR_CHG {
   CHG_ON_SLOPE,  // change color on slope change
   CHG_ON_LEVEL,  // Change color on outer levels cross
   CHG_ON_MIDDLE  // Change color on middle level cross
};

/* ===========================================================================================================================
   |                                                                                                                         |
   | Class: T3 Floating Levels                                                                                               |
   | -------------------------                                                                                               |
   =========================================================================================================================== */

class T3FloatingLevels : public ColorChangeIndicator {

public:
   // Inputs:
   double T3_Period;
   double T3_Volume_Factor;
   T3_TYPE T3_Calc_Mode;
   ENUM_APPLIED_PRICE T3_App_Price;
   T3_COLOR_CHG T3_Color_Chg;
   int T3_Floating_Period;
   double T3_Floating_Upper;
   double T3_Floating_Lower;
   
   // Functions:
                           T3FloatingLevels(void);
   void                    Initialize(void) override;
};

/* ===========================================================================================================================
   | Constructor                                                                                                             |
   =========================================================================================================================== */

T3FloatingLevels::T3FloatingLevels(void) {
   Color_Buffer = 4;
   Bullish_Color = 1;
   Bearish_Color = 2;
}

/* ===========================================================================================================================
   | Initialization Function                                                                                                 |
   =========================================================================================================================== */

void T3FloatingLevels::Initialize(void) override {
   Handle = iCustom(Pair,Timeframe,"T3 floating levels (2).ex5",T3_Period,T3_Volume_Factor,T3_Calc_Mode,T3_App_Price,
                                                               T3_Color_Chg,T3_Floating_Period,T3_Floating_Upper,T3_Floating_Lower);
}
