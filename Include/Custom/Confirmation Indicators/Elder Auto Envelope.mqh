/* ===========================================================================================================================
   | Includes                                                                                                                |
   =========================================================================================================================== */

#include <Custom/ConfirmationIndicator.mqh>

/* ===========================================================================================================================
   | Enum                                                                                                                    |
   =========================================================================================================================== */

enum ELDER_AUTO_APP_PR{
   PR_CLOSE, // Close
   PR_OPER, // Open
   PR_HIGH, // High
   PR_LOW, // Low
   PR_MEDIAN, // Median
   PR_TYPICAL, // Typical
   PR_WEIGHTED, // Weighted
   PR_HA_CLOSE, // Heiken ashi close
   PR_HA_OPEN, // Heiken ashi open
   PR_HA_HIGH, // Heiken ashi high
   PR_HA_LOW, // Heiken ashi low
   PR_HA_MEDIAN, // Heiken ashi median
   PR_HA_TYPICAL, // Heiken ashi typical
   PR_HA_WEIGHTED, // Heiken ashi weighted
   PR_HA_AVERAGE // Heiken ashi average
};

/* ===========================================================================================================================
   |                                                                                                                         |
   | Class: Elder Auto Envelope                                                                                              |
   | --------------------------                                                                                              |
   =========================================================================================================================== */

class ElderAutoEnvelope : public TwoLineCrossIndicator {

public:
   // Inputs:
   int Slow_EMA_Period;
   int Fast_EMA_Period;
   ELDER_AUTO_APP_PR Elder_Auto_Applied_Price;
   double Deviations_Factor;
   int Deviations_Period;
   
   // Functions:
                           ElderAutoEnvelope(void);
   void                    Initialize(void) override;
};

/* ===========================================================================================================================
   | Constructor                                                                                                             |
   =========================================================================================================================== */

ElderAutoEnvelope::ElderAutoEnvelope(void) {
   Fast_Line_Buffer = 4;
   Slow_Line_Buffer = 2;
}

/* ===========================================================================================================================
   | Initialization Function                                                                                                 |
   =========================================================================================================================== */

void ElderAutoEnvelope::Initialize(void) override {
   Handle = iCustom(Pair,Timeframe,"elder_auto_envelope_1_2.ex5",Slow_EMA_Period,Fast_EMA_Period,Elder_Auto_Applied_Price,Deviations_Factor,Deviations_Period);
}
