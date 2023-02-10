//+------------------------------------------------------------------+
//|                                              AroonOscillator.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2011, Nikolay Kositsin"
//---- link to the website of the author
#property link "farria@mail.redcom.ru"
//---- Indicator Version Number
#property version   "1.00"
//---- drawing the indicator in a separate window
#property indicator_separate_window
//----two buffers are used for calculation and drawing the indicator
#property indicator_buffers 2
//---- two plots are used
#property indicator_plots   2
//+----------------------------------------------+
//|  Parameters of drawing the bullish indicator |
//+----------------------------------------------+
//---- Drawing indicator 1 as a line
#property indicator_type1   DRAW_LINE
//---- lime color is used as the color of a bullish candlestick
#property indicator_color1  Lime
//---- line of the indicator 1 is a solid curve
#property indicator_style1  STYLE_SOLID
//---- thickness of line of the indicator 1 is equal to 1
#property indicator_width1  1
//---- bullish indicator label display
#property indicator_label1  "BullsAroon"
//+----------------------------------------------+
//|  Parameters of drawing the bearish indicator |
//+----------------------------------------------+
//---- drawing indicator 2 as a line
#property indicator_type2   DRAW_LINE
//---- red color is used as the color of the bearish indicator line
#property indicator_color2  Red
//---- line of the indicator 2 is a solid curve
#property indicator_style2  STYLE_SOLID
//---- thickness of line of the indicator 2 is equal to 1
#property indicator_width2  1
//---- bearish indicator label display
#property indicator_label2  "BearsAroon"
//+----------------------------------------------+
//| Horizontal levels display parameters         |
//+----------------------------------------------+
#property indicator_level1 70.0
#property indicator_level2 50.0
#property indicator_level3 30.0
#property indicator_levelcolor Gray
#property indicator_levelstyle STYLE_DASHDOTDOT
//+----------------------------------------------+
//| Input parameters of the indicator            |
//+----------------------------------------------+
input int AroonPeriod= 9; // period of the indicator 
input int AroonShift = 0; // horizontal shift of the indicator in bars 
//+----------------------------------------------+
//---- declaration of dynamic arrays that further 
// will be used as indicator buffers
double BullsAroonBuffer[];
double BearsAroonBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- transformation of the BullsAroonBuffer dynamic indicator into an indicator buffer
   SetIndexBuffer(0,BullsAroonBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by AroonShift
   PlotIndexSetInteger(0,PLOT_SHIFT,AroonShift);
//---- performing shift of the beginning of counting of drawing the indicator 1 by AroonPeriod
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,AroonPeriod);
//--- creation of a label to be displayed in the Data Window
   PlotIndexSetString(0,PLOT_LABEL,"BearsAroon");

//---- transformation of the BearsAroonBuffer dynamic array into an indicator buffer
   SetIndexBuffer(1,BearsAroonBuffer,INDICATOR_DATA);
//---- shifting the indicator 2 horizontally by AroonShift
   PlotIndexSetInteger(1,PLOT_SHIFT,AroonShift);
//---- performing shift of the beginning of counting of drawing the indicator 2 by AroonPeriod
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,AroonPeriod);
//--- creation of a label to be displayed in the Data Window
   PlotIndexSetString(1,PLOT_LABEL,"BullsAroon");

//---- Initialization of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"Aroon(",AroonPeriod,", ",AroonShift,")");
//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- determination of accuracy of displaying of the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,0);
//----
  }
//+------------------------------------------------------------------+
//|  searching index of the highest bar                              |
//+------------------------------------------------------------------+
int iHighest(
             const double &array[],// array for searching for maximum element index
             int count,// the number of the array elements (from a current bar to the index descending), 
             // along which the searching must be performed.
             int startPos //the initial bar index (shift relative to a current bar), 
             // the search for the greatest value begins from
             )
  {
//----
   int index=startPos;

//----checking correctness of the initial index
   if(startPos<0)
     {
      Print("Bad value in the function iHighest, startPos = ",startPos);
      return(0);
     }

//---- checking correctness of startPos value
   if(startPos-count<0)
      count=startPos;

   double max=array[startPos];

//---- searching for an index
   for(int i=startPos; i>startPos-count; i--)
     {
      if(array[i]>max)
        {
         index=i;
         max=array[i];
        }
     }
//---- returning of the greatest bar index
   return(index);
  }
//+------------------------------------------------------------------+
//|  searching index of the lowest bar                               |
//+------------------------------------------------------------------+
int iLowest(
            const double &array[],// array for searching for minimum element index
            int count,// the number of the array elements (from a current bar to the index descending), 
            // along which the searching must be performed.
            int startPos //the initial bar index (shift relative to a current bar), 
            // the search for the lowest value begins from
            )
  {
//----
   int index=startPos;

//----checking correctness of the initial index
   if(startPos<0)
     {
      Print("Bad value in the function iLowest, startPos = ",startPos);
      return(0);
     }

//---- checking correctness of startPos value
   if(startPos-count<0)
      count=startPos;

   double min=array[startPos];

//---- searching for an index
   for(int i=startPos; i>startPos-count; i--)
     {
      if(array[i]<min)
        {
         index=i;
         min=array[i];
        }
     }
//---- returning of the lowest bar index
   return(index);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(
                const int rates_total,    // amount of history in bars at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &time[],
                const double &open[],
                const double& high[],     // price array of maximums of price for the calculation of indicator
                const double& low[],      // price array of minimums of price for the calculation of indicator
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]
                )
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<AroonPeriod-1)
      return(0);

//---- declaration of local variables 
   int first,bar;
   double BULLS,BEARS;

//---- calculation of the starting number 'first' for the cycle of recalculation of bars
   if(prev_calculated>rates_total || prev_calculated<=0) // checking for the first start of calculation of an indicator
      first=AroonPeriod-1; // starting number for calculation of all bars

   else first=prev_calculated-1; // starting number for calculation of new bars

//---- main cycle of calculation of the indicator
   for(bar=first; bar<rates_total; bar++)
     {
      //---- calculation of the indicator values
      BULLS = 100 - (bar - iHighest(high, AroonPeriod, bar) + 0.5) * 100 / AroonPeriod;
      BEARS = 100 - (bar - iLowest (low,  AroonPeriod, bar) + 0.5) * 100 / AroonPeriod;

      //---- initialization of cells of the indicator buffers with obtained values 
      BullsAroonBuffer[bar] = BULLS;
      BearsAroonBuffer[bar] = BEARS;
     }
//----     
   return(rates_total);
  }
//+------------------------------------------------------------------+
