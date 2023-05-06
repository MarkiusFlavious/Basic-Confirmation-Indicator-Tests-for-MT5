/* ===========================================================================================================================
   | Includes                                                                                                                |
   =========================================================================================================================== */

#include <Object.mqh>
#include <Custom/TradingTerms.mqh>

/* ===========================================================================================================================
   | Base Confirmation Indicator Class                                                                                       |
   =========================================================================================================================== */

class ConfirmationIndicator : public CObject {

protected:

   TRADING_TERMS              TwoLineCrossMethod(int fast_buffer, int slow_buffer, int start_pos);
   TRADING_TERMS              NumberCrossMethod(int line_buffer, double number_cross, int start_pos);
   TRADING_TERMS              ColorChangeMethod(int color_buffer, double bullish_color, double bearish_color, int start_pos);
   bool                       TwoLinesCrossLookback(int fast_buffer,int slow_buffer, int start_pos);
   bool                       NumberCrossLookback(int line_buffer, double number_cross, int start_pos);
   bool                       ColorChangeLookback(int color_buffer, double bullish_color, double bearish_color, int start_pos);

public:

   int                        Handle;
   string                     Pair;
   ENUM_TIMEFRAMES            Timeframe;
   int                        Tolerance;
   
   void                       GetBufferValues(int buffer_num, int start_pos, int bar_count, double &output_array[]);
   void                       GetBufferValues(int buffer_one, int buffer_two, int start_pos, int bar_count, double &output_array1[], double &output_array2[]);
   virtual void               Initialize(void)                          {}
   virtual TRADING_TERMS      CheckSignal(int start_pos)                {return NO_SIGNAL;}
   virtual bool               Lookback(int start_pos)                   {return false;}
};

/* ===========================================================================================================================
   | Get Buffer Values Function 1 - returns 1 double array in descending order                                               |
   =========================================================================================================================== */

void ConfirmationIndicator::GetBufferValues(int buffer_num,int start_pos,int bar_count,double &output_array[]){
   
   CopyBuffer(Handle,buffer_num,start_pos,bar_count,output_array);
   if (bar_count > 1) ArrayReverse(output_array);
}

/* ===========================================================================================================================
   | Get Buffer Values Function 2 - returns 2 double arrays in descending order                                              |
   =========================================================================================================================== */

void ConfirmationIndicator::GetBufferValues(int buffer_one,int buffer_two,int start_pos,int bar_count,double &output_array1[],double &output_array2[]){
   
   CopyBuffer(Handle,buffer_one,start_pos,bar_count,output_array1);
   CopyBuffer(Handle,buffer_two,start_pos,bar_count,output_array2);
   
   if (bar_count > 1){
      ArrayReverse(output_array1);
      ArrayReverse(output_array2);
   }
}

/* ===========================================================================================================================
   | Two Lines Cross Method                                                                                                  |
   =========================================================================================================================== */

TRADING_TERMS ConfirmationIndicator::TwoLineCrossMethod(int fast_buffer,int slow_buffer, int start_pos){
   
   double fast_line[], slow_line[];
   GetBufferValues(fast_buffer,slow_buffer,start_pos,2,fast_line,slow_line);
   
   if (fast_line[0] > slow_line[0]){
      if (fast_line[1] < slow_line[1]) return BUY_SIGNAL;
      else return BULLISH;
   }
   else if (fast_line[0] < slow_line[0]){
      if (fast_line[1] > slow_line[1]) return SELL_SIGNAL;
      else return BEARISH;
   }
   return NO_SIGNAL;
}


/* ===========================================================================================================================
   | Number Cross Method - Zero Cross, 50 Cross, etc.                                                                        |
   =========================================================================================================================== */

TRADING_TERMS ConfirmationIndicator::NumberCrossMethod(int line_buffer,double number_cross, int start_pos){
   
   double line_value[];
   GetBufferValues(line_buffer,start_pos,2,line_value);
   
   if (line_value[0] > number_cross){
      if (line_value[1] <= number_cross) return BUY_SIGNAL;
      else return BULLISH;
   }
   else if (line_value[0] < number_cross){
      if (line_value[1] >= number_cross) return SELL_SIGNAL;
      else return BEARISH;
   }
   return NO_SIGNAL;
}


   
/* ===========================================================================================================================
   | Color Change Method                                                                                                     |
   =========================================================================================================================== */

TRADING_TERMS ConfirmationIndicator::ColorChangeMethod(int color_buffer,double bullish_color,double bearish_color,int start_pos){
   
   double color_value[];
   GetBufferValues(color_buffer,start_pos,2,color_value);
   
   if (color_value[0] == bullish_color){
      if (color_value[1] != bullish_color) return BUY_SIGNAL;
      else return BULLISH;
   }
   else if (color_value[0] == bearish_color){
      if (color_value[1] != bearish_color) return SELL_SIGNAL;
      else return BEARISH;
   }
   return NO_SIGNAL;
}

/* ===========================================================================================================================
   | Two Lines Cross Lookback                                                                                                |
   =========================================================================================================================== */
bool ConfirmationIndicator::TwoLinesCrossLookback(int fast_buffer,int slow_buffer, int start_pos){
   
   int lookback_count = Tolerance + 2;
   double fast_line[], slow_line[];
   GetBufferValues(fast_buffer, slow_buffer, start_pos, lookback_count, fast_line, slow_line);
   
   if (fast_line[0] > slow_line[0]) {
      for (int pos = 1; pos < ArraySize(fast_line); pos++) {
         if (fast_line[pos] < slow_line[pos]) return true;
      }
   }
   else if (fast_line[0] < slow_line[0]) {
      for (int pos = 1; pos < ArraySize(fast_line); pos++) {
         if (fast_line[pos] > slow_line[pos]) return true;
      }
   }
   return false;
}

/* ===========================================================================================================================
   | Number Cross Lookback                                                                                                   |
   =========================================================================================================================== */
   
bool ConfirmationIndicator::NumberCrossLookback(int line_buffer,double number_cross,int start_pos){
   
   int lookback_count = Tolerance + 2;
   double line_value[];
   GetBufferValues(line_buffer,start_pos,lookback_count,line_value);
   
   if (line_value[0] > number_cross) {
      for (int pos = 1; pos < ArraySize(line_value); pos++) {
         if (line_value[pos] <= number_cross) return true;
      }
   }
   else if (line_value[0] < number_cross) {
      for (int pos = 1; pos < ArraySize(line_value); pos++) {
         if (line_value[pos] >= number_cross) return true;
      }
   }
   return false;
}

/* ===========================================================================================================================
   | Color Change Lookback                                                                                                   |
   =========================================================================================================================== */

bool ConfirmationIndicator::ColorChangeLookback(int color_buffer,double bullish_color,double bearish_color,int start_pos) {
   
   int lookback_count = Tolerance + 2;
   double color_value[];
   GetBufferValues(color_buffer,start_pos,lookback_count,color_value);
   
   if (color_value[0] == bullish_color) {
      for (int pos = 1; pos < ArraySize(color_value); pos++) {
         if (color_value[0] != bullish_color) return true; 
      }
   }
   else if (color_value[0] == bearish_color) {
      for (int pos = 1; pos < ArraySize(color_value); pos++) {
         if (color_value[0] != bearish_color) return true; 
      }
   }
   return false;
}

/* ===========================================================================================================================
   | Two Line Cross Indicator Class                                                                                          |
   =========================================================================================================================== */

class TwoLineCrossIndicator : public ConfirmationIndicator {

protected:

   int                     Fast_Line_Buffer, Slow_Line_Buffer;

public:

   TRADING_TERMS           CheckSignal(int start_pos) override;
   bool                    Lookback(int start_pos) override;

};

TRADING_TERMS TwoLineCrossIndicator::CheckSignal(int start_pos) {
   return TwoLineCrossMethod(Fast_Line_Buffer, Slow_Line_Buffer, start_pos);
}

bool TwoLineCrossIndicator::Lookback(int start_pos) {
   return TwoLinesCrossLookback(Fast_Line_Buffer, Slow_Line_Buffer, start_pos);
}

/* ===========================================================================================================================
   | Number Cross Indicator Class                                                                                            |
   =========================================================================================================================== */

class NumberCrossIndicator : public ConfirmationIndicator {

protected:

   int                     Line_Buffer;
   double                  Number_Cross;

public:
   
   TRADING_TERMS           CheckSignal(int start_pos) override;
   bool                    Lookback(int start_pos) override;
};

TRADING_TERMS NumberCrossIndicator::CheckSignal(int start_pos) {
   return NumberCrossMethod(Line_Buffer, Number_Cross, start_pos);
}

bool NumberCrossIndicator::Lookback(int start_pos) {
   return NumberCrossLookback(Line_Buffer, Number_Cross, start_pos);
}

/* ===========================================================================================================================
   | Color Change Indicator Class                                                                                            |
   =========================================================================================================================== */

class ColorChangeIndicator : public ConfirmationIndicator {

protected:

   int                     Color_Buffer;
   double                  Bullish_Color, Bearish_Color;

public:
   
   TRADING_TERMS           CheckSignal(int start_pos) override;
   bool                    Lookback(int start_pos) override;
};

TRADING_TERMS ColorChangeIndicator::CheckSignal(int start_pos) {
   return ColorChangeMethod(Color_Buffer, Bullish_Color, Bearish_Color, start_pos);
}

bool ColorChangeIndicator::Lookback(int start_pos) {
   return ColorChangeLookback(Color_Buffer, Bullish_Color, Bearish_Color, start_pos);
}
