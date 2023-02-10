/*
* Place the SmoothAlgorithms.mqh file 
  to the terminal_data_folder\MQL5\Include
*/
//+------------------------------------------------------------------+ 
//|                                                          KRI.mq5 | 
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+ 
#property copyright "Copyright © 2011, Nikolay Kositsin"
#property link "farria@mail.redcom.ru"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//---- number of indicator buffers
#property indicator_buffers 1 
//---- only one plot is used
#property indicator_plots   1
//+-----------------------------------+
//|  Indicator drawing parameters     |
//+-----------------------------------+
//---- drawing the indicator as a line
#property indicator_type1   DRAW_LINE
//---- use gold color for the indicator line
#property indicator_color1 Gold
//---- the indicator line is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator line width is equal to 1
#property indicator_width1  1
//---- displaying the indicator line label
#property indicator_label1  "KRI"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
enum Applied_price_ //Type of constant
  {
   PRICE_CLOSE_ = 1,     //PRICE_CLOSE
   PRICE_OPEN_,          //PRICE_OPEN
   PRICE_HIGH_,          //PRICE_HIGH
   PRICE_LOW_,           //PRICE_LOW
   PRICE_MEDIAN_,        //PRICE_MEDIAN
   PRICE_TYPICAL_,       //PRICE_TYPICAL
   PRICE_WEIGHTED_,      //PRICE_WEIGHTED
   PRICE_SIMPLE,         //PRICE_SIMPLE
   PRICE_QUARTER_,       //PRICE_QUARTER_
   PRICE_TRENDFOLLOW0_,  //PRICE_TRENDFOLLOW0_
   PRICE_TRENDFOLLOW1_   //PRICE_TRENDFOLLOW1_
  };
input int KRIPeriod=20;                    //Smoothing period
input ENUM_MA_METHOD MA_Method_=MODE_SMA;  //Smoothing method
input double Ratio=1.0;
input Applied_price_ IPC=PRICE_CLOSE_;     //Price constant
/* used for calculation of the indicator (1-CLOSE, 2-OPEN, 3-HIGH, 4-LOW, 
  5-MEDIAN, 6-TYPICAL, 7-WEIGHTED, 8-SIMPL, 9-QUARTER, 10-TRENDFOLLOW, 11-0.5 * TRENDFOLLOW.) */
input int Shift=0; // Horizontal shift of the indicator in bars

//---- indicator buffers
double KRIBuffer[];
//---- Declaration of integer variables of the start of data calculation
int StartBar;
//+------------------------------------------------------------------+
// Declaration of smoothing classes                                  |
//+------------------------------------------------------------------+ 
#include <SmoothAlgorithms.mqh>
//+------------------------------------------------------------------+    
//| KRI indicator initialization function                            | 
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of constants
   StartBar=KRIPeriod+1;
//---- set dynamic array as indicator buffer
   SetIndexBuffer(0,KRIBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- performing the shift of beginning of indicator 1 drawing
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBar);
//---- create label to display in DataWindow
   PlotIndexSetString(0,PLOT_LABEL,"KRI");
//---- setting values of the indicator that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- initialization of a variable for the indicator short name
   string shortname;
   StringConcatenate(shortname,"KRI( KRIPeriod = ",KRIPeriod,")");
//---- creation of the name to be displayed in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//---- determination of the indicator values displaying accuracy
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits+1);
//---- initialization end
  }
//+------------------------------------------------------------------+  
//| KRI iteration function                                           | 
//+------------------------------------------------------------------+  
int OnCalculate(const int rates_total,// number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<StartBar) return(0);

//---- Declaration of variables with a floating point  
   double price_,KRI,mov;
//---- Declaration of integer variables
   int first,bar;

//---- calculation of the 'first' starting number for the bars recalculation loop
   if(prev_calculated==0) // checking for the first start of the indicator calculation
     {
      first=0; // starting index for calculation of all bars
     }
   else // starting index for calculation of new bars
     {
      first=prev_calculated-1;
     }

//---- declaration of the Moving_Average and StdDeviation classes variables
   static CMoving_Average MA;

//---- Main channel center line calculation loop
   for(bar=first; bar<rates_total; bar++)
     {
      //---- Call of the PriceSeries function to get the Series input price
      price_=PriceSeries(IPC,bar,open,low,high,close);

      mov=MA.MASeries(0,prev_calculated,rates_total,KRIPeriod,MA_Method_,price_,bar,false);

      KRI=100 *(price_-mov)/mov;
      KRIBuffer[bar]=KRI;
     }
//----    
   return(rates_total);
  }
//+------------------------------------------------------------------+
