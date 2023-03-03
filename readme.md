# MT5 Simple Confirmation Indicator Tester

The main file in this repository is Basic Template.mq5 which is a template that I created in order to speed up the process of creating simple Expert Advisors ment for backtesting confirmation indicators in MT5's strategy tester. I have also included all the EAs I've created so far with this template as well as the required indicators. [^1]  

[^1]: Some of the indicators I've tested used the file smoothalgorithms.mqh which is broken in the latest version of MetaTrader 5. Such indicators usually come with a fixed version of this file. I have added it here as well, place it in your Includes folder.

## The Basic Rules of Trading

I have it set up so that the EAs will trade with the following rules:

- Only 1 trade at a time.
- Recieving a sell signal while in a long position will result in the long position closing and a short position being opened.
- Stop Loss and Take Profit are based on the ATR.

***NOTE:*** While I could've just used [iATR](https://www.mql5.com/en/docs/indicators/iatr), I found a different incdicator that I prefer to use called ATR Channel. It is a hard requirement and included within this repository.

## How to make your own test EA

I will be using the SSL indicator as an example here. I will also be assuming that you know how to use MetaTrader 5 and MetaEditor (which comes with MT5.)
***NOTE:*** While it's not entirely necessary, I highly recommend using only free indicators that come with their source code. Having the source code available makes passing the inputs into [iCustom](https://www.mql5.com/en/docs/indicators/icustom) easier becuase some indicators use their own custom enums. In addition to this you need to know which buffer values to pull data from and having the source code makes finding it much easier.  

### Step 1: Setup

Make a copy of the template folder and rename everything to match the indicator you're testing. In your basic and multi mq5 files, change the include statement to reflect your file name.  

```mql5
#include "SSL Test Class.mqh"
```

It's a good idea to compile the basic and main files at this point to make sure you set up everything correctly.  

Now open the source code of the indicator you're testing. Look at the properties and also look at where it says SetIndexBuffer. Also take note of the inputs, because we're going to copy them soon.

#### In SSL_Channel_Chart.mq5

```mql5
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   2
#property indicator_label1  "Bears"
#property indicator_color1 clrOrange
#property indicator_type1   DRAW_LINE
#property indicator_width1  2
#property indicator_label2  "Bulls"
#property indicator_color2 clrAqua
#property indicator_type2   DRAW_LINE
#property indicator_width2  2

//------------------------------------------------------------------

//---- input parameters
input ENUM_MA_METHOD MA_Method = MODE_SMA;  // Method
input int Lb = 10;
//---- buffers

double ssld[];
double sslu[];
double Hlv[];

int hMAHigh;
int hMALow;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   
   SetIndexBuffer(0, ssld, INDICATOR_DATA);
   SetIndexBuffer(1, sslu, INDICATOR_DATA);
   SetIndexBuffer(2, Hlv, INDICATOR_CALCULATIONS);
   
   hMAHigh = iMA(_Symbol, PERIOD_CURRENT, Lb, 0, MA_Method, PRICE_HIGH);
   hMALow = iMA(_Symbol, PERIOD_CURRENT, Lb, 0, MA_Method, PRICE_LOW);

   
   if(hMAHigh==INVALID_HANDLE)Print(" Failed to get handle of the iMA indicator");
   if(hMALow==INVALID_HANDLE)Print(" Failed to get handle of the iMA indicator");
   
   ArraySetAsSeries(ssld,true);
   ArraySetAsSeries(sslu,true);
   ArraySetAsSeries(Hlv,true);
//---
   return(INIT_SUCCEEDED);
  }
```

We can see that the SSL stores data in 3 buffers. The ones we care about are buffer 0 and 1 which store the values of the orange and blue lines for each bar. These are the values we will be using in the [CopyBuffer](https://www.mql5.com/en/docs/series/copybuffer) function.  

Take note of the input variables:  

```mql5
input ENUM_MA_METHOD MA_Method = MODE_SMA;  // Method
input int Lb = 10;
```

#### Using IndiProbe.mq5

Some indicators can have many buffer values and sometimes it's a good idea to double check that you are getting the values that you want. IndiProbe is a small expert that will print buffer values every time there is a new bar. It's really ment to be overwritten and used in the Strategy Tester.  

To use any indicator we need to give it a handle which is just a global integer that we declare. I already declared one called IndiHandle so we can simple assign the SSL indicator to it in the OnInit function with the function [iCustom](https://www.mql5.com/en/docs/indicators/icustom). Please read the documentation.  

```mql5
   IndiHandle = iCustom(_Symbol,PERIOD_CURRENT,"SSL_Channel_Chart.ex5");
```

Now all we need to do is take the data from the buffers and print them to the journal and we do this in the OnTick function. The OnTick funtion gets called every time price moves. The if statement is there so that the calculations are only performed at when a new bar/candle is formed. The code I have commented out is an example of what you might do if you want to check just 1 buffer. We will be replacing it with this:  

```mql5
    double BufferValueA[],BufferValueB[];
    CopyBuffer(IndiHandle,0,1,1,BufferValueA);
    CopyBuffer(IndiHandle,1,1,1,BufferValueB);
    Print("Buffer 0: ", BufferValueA[0], " | Buffer 1: ", BufferValueB[0]);
```

It's worth noting that CopyBuffer() will alway output an array of type double.  

We can now compile our file and run it in the Strategy Tester. Now we can compare the values printed in the Journal to the values in the Data Window and will find that the values for the label "Bears" in the Data Window match the values we get from Buffer 0 and likewise for the "Bulls" label and Buffer 1.  

### Step 2: Create Inputs

Copy and rename the inputs from the indicator into both the basic and multi mq5 files. I also like to put them in their own input group. Comments on the same line as an input declaration will be displayed as labels in MT5.

#### In The mq5 Files

```mql5
input group "Risk Inputs:"
input double input_risk_percent = 1.0; // Risk Percent Per Trade
input double input_profit_factor = 1.5; // Profit factor
input uint input_atr_period = 25; // ATR Period
input double input_atr_channel_factor =1.5; // ATR Channel Factor
input ENUM_APPLIED_PRICE input_atr_channel_app_price = PRICE_TYPICAL; // ATR Channel Applied Price

input group "SSL Inputs:"
input ENUM_MA_METHOD input_ssl_ma_method = MODE_SMA;  // SSL MA Method
input int input_ssl_period = 10; // SSL Period
```

If an indicator uses a custom enum type as an input, copy the enum to your class template and declare it outside the class, just after my own enum declaration.  

Some inputs aren't worth changing and can just be hardcoded into iCustom and you won't need to declare them as inputs. It's also worth noting that if an indicator is using input groups, we should pass empty values for each group into iCustom.  

#### In The mqh File

Add the inputs as private variables to the class and while we're at it declare a handle for the indicator as well. I like to just copy the code from the previous step and change it:

```mql5
private:
// Input Parameters:
   string Pair;
   ENUM_TIMEFRAMES Timeframe;
   // Risk Inputs:
   double Risk_Percent;
   double Profit_Factor;
   uint ATR_Period;
   double ATR_Channel_Factor;
   ENUM_APPLIED_PRICE ATR_Channel_App_Price;
   
   // SSL Inputs:
   ENUM_MA_METHOD SSL_MA_Method;
   int SSL_Period;

// Indicator Handles:
   int ATR_Channel_Handle;
   int SSL_Handle;
```

Now add and initialise the inputs in the Constructor. Note that I use lower case names for the constructor variables:  

```mql5
public:
// Public Function/Constructor/Destructor Declaration:
                        CSingleIndicatorTester(string pair,
                                               ENUM_TIMEFRAMES timeframe,
                                               double risk_percent,
                                               double profit_factor,
                                               uint atr_period,
                                               double atr_channel_factor,
                                               ENUM_APPLIED_PRICE atr_channel_app_price,
                                               ENUM_MA_METHOD ssl_ma_method,
                                               int ssl_period);
                        ~CSingleIndicatorTester(void);
   int                  OnInitEvent(void);
   void                 OnDeinitEvent(const int reason);
   void                 OnTickEvent(void);
```

```mql5
//+------------------------------------------------------------------+
//| Constructor:                                                     |
//+------------------------------------------------------------------+
//| - Initialize inputs                                              |
//+------------------------------------------------------------------+
CSingleIndicatorTester::CSingleIndicatorTester(string pair,
                                               ENUM_TIMEFRAMES timeframe,
                                               double risk_percent,
                                               double profit_factor,
                                               uint atr_period,
                                               double atr_channel_factor,
                                               ENUM_APPLIED_PRICE atr_channel_app_price,
                                               ENUM_MA_METHOD ssl_ma_method,
                                               int ssl_period){
   // Initialize Inputs
   Pair = pair;
   Timeframe = timeframe;
   
   Risk_Percent = risk_percent;
   Profit_Factor = profit_factor;
   ATR_Period = atr_period;
   ATR_Channel_Factor = atr_channel_factor;
   ATR_Channel_App_Price = atr_channel_app_price;
   
   SSL_MA_Method = ssl_ma_method;
   SSL_Period = ssl_period;
   
   // Other Variable Initialization
   Bar_Total = 0;
   Ticket_Number = 0;
   In_Trade = false;   
}
```

### Step 3: Create the Strategy

Every Expert Advisor usually has 3 main functions:

1. The Initialization function,
2. The Deinitialization function, and
3. The On Tick function.

In our strategy class we have 3 corresponding functions that we will call inside these 3 functions.  

To track trades, I've used a boolean variable as well the ticket number of a particular trade. There is no need to use a magic number to recover from crashes, etc. We're only going to run these programs in the strategy tester.  

The OnTick function is set up so that all checks are done at the end of every bar. If there is a new bar, it will look for a signal by calling the LookForSignal function. This is the main function that we will write later and it should return 1 of 5 of my TRADING\_TERMS enums: BUY\_SIGNAL, BULLISH, SELL\_SIGNAL, BEARISH and NO\_SIGNAL.  

Next it passes the result into the PositionCheckModify function that does a few things if In_Trade = true:  

- First it will try to select the position by ticket number and if it can't (the position is closed) it resets the ticket number and sets In_Trade to false.
- If it can select the position, it will check what type it is.
- If it's a buy position and the input result was either SELL\_SIGNAL, BEARISH or NO\_SIGNAL it will close the position and reset the tracking variables.
- This way, the indicator is also being used for exits by default.
- Most confirmation indicators will flip between bullish and bearish states and sometimes have states in which it's neither.
- If you happen to be testing an indicator that only prints buy and sell signals and otherwise has no other information that you can get from it, you will probably have to change the logic in this function a little.

#### In Our Class File

With all that explained we can create our basic strategy.  

##### In the OnInitEvent Function

We need to assign our indicator handle by calling iCustom. Put the inputs in the order they appear in the indicator:  

```mql5
int CSingleIndicatorTester::OnInitEvent(void){
   
   Bar_Total = iBars(Pair,Timeframe);
   ATR_Channel_Handle = iCustom(Pair,Timeframe,"ATR Channel.ex5",MODE_SMA,1,ATR_Period,ATR_Channel_Factor,ATR_Channel_App_Price);
   SSL_Handle = iCustom(Pair,Timeframe,"SSL_Channel_Chart.ex5",SSL_MA_Method,SSL_Period);
   
   return(INIT_SUCCEEDED);
}
```

##### Write LookForSignal Function

Now we can write our LookForSignal function. You will find it just after the OnTickEvent function:  

```mql5
//+------------------------------------------------------------------+
//| Look For Signal Function:                                        |
//+------------------------------------------------------------------+
//| - PositionCheckModify will close a position if it receives:      |
//|   - NO_SIGNAL                                                    |
//|   - An opposite signal to the current open position              |
//| - Two Lines Cross:                                               |
//|   - When the blue line crosses the orange line we have a buy     |
//|     signal and vice versa                                        |
//|   - Bulls line buffer = 1 and bears line buffer = 0              |
//+------------------------------------------------------------------+
TRADING_TERMS CSingleIndicatorTester::LookForSignal(void){
   
   double bulls_line[],bears_line[];
   CopyBuffer(SSL_Handle,1,1,2,bulls_line);
   CopyBuffer(SSL_Handle,0,1,2,bears_line);
   ArrayReverse(bulls_line);
   ArrayReverse(bears_line);
   
   if (bulls_line[0] > bears_line[0]){
      if (bulls_line[1] < bears_line[1]) return BUY_SIGNAL;
      else return BULLISH;
   }
   else if (bulls_line[0] < bears_line[0]){
      if (bulls_line[1] > bears_line[1]) return BUY_SIGNAL;
      else return BULLISH;
   }
   else PrintFormat("Unexpected error when calling the function: %s", __FUNCTION__);
   return NO_SIGNAL;
}
```

I like to use ArrayReverse so that the arrays are in order of most recent to oldest. That's generally how we count back bars.  

### Final Step  

All we need to do now is fix our object declarations in the basic and multi files:  

In the basic file:

```mql5
CSingleIndicatorTester Simple_Strategy(_Symbol,
                                       input_timeframe,
                                       input_risk_percent,
                                       input_profit_factor,
                                       input_atr_period,
                                       input_atr_channel_factor,
                                       input_atr_channel_app_price,
                                       input_ssl_ma_method,
                                       input_ssl_period);
```

In the multi file:

```mql5
for (int pos = 0; pos < ArraySize(pair_array); pos++){
      strategy_array.Add(new CSingleIndicatorTester(pair_array[pos],
                                                    input_timeframe,
                                                    input_risk_percent,
                                                    input_profit_factor,
                                                    input_atr_period,
                                                    input_atr_channel_factor,
                                                    input_atr_channel_app_price,
                                                    input_ssl_ma_method,
                                                    input_ssl_period));
   }
```

And we're done. Run the basic version in the strategy tester with visual mode enabled to make sure the EA is behaving as expected. If it is, you're ready to test different indicator settings as well as multi currency performance.

## Final Notes

***Do not*** run this EA in a live real money account, it can and will trade if you have Algo Trading enabled and could result in losses. Have fun testing confirmation indicators.  
At a later stage I might come back and add some functionality to allow you to choose between only 1 or multiple trades allowed at a time.
