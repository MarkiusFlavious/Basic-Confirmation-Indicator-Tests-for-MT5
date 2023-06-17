/* ===========================================================================================================================
   | Includes                                                                                                                |
   =========================================================================================================================== */

#include <Custom/ConfirmationIndicator.mqh>

/* ===========================================================================================================================
   | Enum                                                                                                                    |
   =========================================================================================================================== */
enum DSLU_DISPLAY{
   ZONES_YES = (int)true,   // Display filled zoned
   ZONES_NO  = (int)false,  // No filled zones display
};

/* ===========================================================================================================================
   |                                                                                                                         |
   | Class: DSLU RSI Average                                                                                                 |
   | -----------------------                                                                                                 |
   =========================================================================================================================== */

class DSLURSIAverage : public ColorChangeIndicator {

public:
   // Inputs:
   int DSLU_RSI_Period;
   int DSLU_MA_Period;
   ENUM_MA_METHOD DSLU_MA_Method;
   ENUM_APPLIED_PRICE DSLU_App_Price;
   double DSLU_Signal_Period;
   DSLU_DISPLAY DSLU_Zones;
   
   // Functions:
                           DSLURSIAverage(void);
   void                    Initialize(void) override;
};

/* ===========================================================================================================================
   | Constructor                                                                                                             |
   =========================================================================================================================== */

DSLURSIAverage::DSLURSIAverage(void) {
   Color_Buffer = 5;
   Bullish_Color = 1;
   Bearish_Color = 2;
}

/* ===========================================================================================================================
   | Initialization Function                                                                                                 |
   =========================================================================================================================== */

void DSLURSIAverage::Initialize(void) override {
   Handle = iCustom(Pair,Timeframe,"Dslu RSI of average.ex5",DSLU_RSI_Period,DSLU_MA_Period,DSLU_MA_Method,DSLU_App_Price,DSLU_Signal_Period,DSLU_Zones);
}
