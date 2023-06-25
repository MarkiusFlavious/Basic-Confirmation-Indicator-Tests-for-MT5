/* ===========================================================================================================================
   | Includes                                                                                                                |
   =========================================================================================================================== */

#include <Custom/ConfirmationIndicator.mqh>

/* ===========================================================================================================================
   |                                                                                                                         |
   | Class: QQE                                                                                                              |
   | --------------------------------------                                                                                  |
   =========================================================================================================================== */

class QQE : public TwoLineCrossIndicator {

public:
   // Inputs:
   int QQE_RSI_Period;
   int QQE_RSI_Smoothing_Factor;
   double QQE_WP_Fast;
   double QQE_WP_Slow;
   ENUM_APPLIED_PRICE QQE_Applied_Price;
   
   // Functions:
                           QQE(void);
   void                    Initialize(void) override;
};

/* ===========================================================================================================================
   | Constructor                                                                                                             |
   =========================================================================================================================== */

QQE::QQE(void) {
   Fast_Line_Buffer = 0;
   Slow_Line_Buffer = 1;
}

/* ===========================================================================================================================
   | Initialization Function                                                                                                 |
   =========================================================================================================================== */

void QQE::Initialize(void) override {
   Handle = iCustom(Pair,Timeframe,"QQE.ex5",QQE_RSI_Period,QQE_RSI_Smoothing_Factor,QQE_WP_Fast,QQE_WP_Slow,QQE_Applied_Price);
}