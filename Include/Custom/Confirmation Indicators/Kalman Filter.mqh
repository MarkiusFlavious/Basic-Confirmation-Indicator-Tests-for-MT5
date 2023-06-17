/* ===========================================================================================================================
   | Includes                                                                                                                |
   =========================================================================================================================== */

#include <Custom/ConfirmationIndicator.mqh>

/* ===========================================================================================================================
   | Enum                                                                                                                    |
   =========================================================================================================================== */

enum KALMAN_TIMEFRAMES {
   TF_CU = PERIOD_CURRENT, // Current time frame
   TF_M1 = PERIOD_M1, // 1 minute
   TF_M2 = PERIOD_M2, // 2 minutes
   TF_M3 = PERIOD_M3, // 3 minutes
   TF_M4 = PERIOD_M4, // 4 minutes
   TF_M5 = PERIOD_M5, // 5 minutes
   TF_M6 = PERIOD_M6, // 6 minutes
   TF_M10 = PERIOD_M10, // 10 minutes
   TF_M12 = PERIOD_M12, // 12 minutes
   TF_M15 = PERIOD_M15, // 15 minutes
   TF_M20 = PERIOD_M20, // 20 minutes
   TF_M30 = PERIOD_M30, // 30 minutes
   TF_H1 = PERIOD_H1, // 1 hour
   TF_H2 = PERIOD_H2, // 2 hours
   TF_H3 = PERIOD_H3, // 3 hours
   TF_H4 = PERIOD_H4, // 4 hours
   TF_H6 = PERIOD_H6, // 6 hours
   TF_H8 = PERIOD_H8, // 8 hours
   TF_H12 = PERIOD_H12, // 12 hours
   TF_D1 = PERIOD_D1, // daily
   TF_W1 = PERIOD_W1, // weekly
   TF_MN = PERIOD_MN1, // monthly
   TF_CP1 = -1, // Next higher time frame
   TF_CP2 = -2, // Second higher time frame
   TF_CP3 = -3 // Third higher time frame
};

enum KALMAN_INTERPOLATE {
   INTERPOLATE_YES = (int)true, // Interpolate data when in multi time frame
   INTERPOLATE_NO = (int)false // Do not interpolate data when in multi time frame
};

/* ===========================================================================================================================
   |                                                                                                                         |
   | Class: Kalman Filter                                                                                                    |
   | --------------------                                                                                                    |
   =========================================================================================================================== */

class KalmanFilter : public ColorChangeIndicator {

public:
   // Inputs:
   KALMAN_TIMEFRAMES KF_Timeframe;
   double KF_Period;
   ENUM_APPLIED_PRICE KF_App_Price;
   KALMAN_INTERPOLATE KF_Interpolate;
   
   // Functions:
                           KalmanFilter(void);
   void                    Initialize(void) override;
};

/* ===========================================================================================================================
   | Constructor                                                                                                             |
   =========================================================================================================================== */

KalmanFilter::KalmanFilter(void) {
   Color_Buffer = 1;
   Bullish_Color = 1;
   Bearish_Color = 2;
}

/* ===========================================================================================================================
   | Initialization Function                                                                                                 |
   =========================================================================================================================== */

void KalmanFilter::Initialize(void) override {
   Handle = iCustom(Pair,Timeframe,"Kalman filter (mtf).ex5",KF_Timeframe,KF_Period,KF_App_Price,KF_Interpolate);
}
