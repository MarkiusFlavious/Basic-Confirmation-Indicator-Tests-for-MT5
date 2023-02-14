# MT5 Simple Confirmation Indicator Tester 
The main file in this repository is Basic Template.mq5 which is a template that I created in order to speed up the process of creating simple Expert Advisors ment for backtesting confirmation indicators in MT5's strategy tester. I have also included all the EAs I've created so far with this template as well as the required indicators. [^1]  

[^1]: Some of the indicators I've tested used the file smoothalgorithms.mqh which is broken in the latest version of MetaTrader 5. Such indicators usually come with a fixed version of this file. I have added it here as well, place it in your Includes folder.

###### The Basic Rules of Trading:  
I have it set up so that the EAs will trade with the following rules:
- Only 1 trade at a time.
- Recieving a sell signal while in a long position will result in the long position closing and a short position being opened.
- Stop Loss and Take Profit are based on the ATR.  
***NOTE:*** While I could've just used [iATR](https://www.mql5.com/en/docs/indicators/iatr), I found a different incdicator that I prefer to use called ATR Channel. It is a hard requirement and included within this repository.

## How to make your own test EA:
I will be using the SSL indicator as an example here. I will also be assuming that you know how to use MetaTrader 5 and MetaEditor (which comes with MT5.)   
*** NOTE:*** While it's not entirely necessary, I highly recommend using only free indicators that come with their source code. Having the source code available makes passing the inputs into [iCustom](https://www.mql5.com/en/docs/indicators/icustom) easier becuase some indicators use their own custom enums. In addition to this you need to know which buffer values to pull data from and having the source code makes finding it much easier.  

### IndiProbe
With all that in mind, it's usually a good idea to "probe" and or double check that you have the correct buffer value. For that I use a very basic EA that I called IndiProbe. First let's look at the initialization function of our indicator.  

In SSL_Channel_Chart.mq5 we can see the following properties:  
```
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
```
We can see that it has 3 buffers and that it plots 2 values: an orange "bears" line and an aqua "bulls" line. If we look at the initialization function:  
```
   SetIndexBuffer(0, ssld, INDICATOR_DATA);
   SetIndexBuffer(1, sslu, INDICATOR_DATA);
   SetIndexBuffer(2, Hlv, INDICATOR_CALCULATIONS);
```
Buffer 0 and 1 are what we will be using in the [CopyBuffer](https://www.mql5.com/en/docs/series/copybuffer) function later. Not every indicator is going to be so simple and we might as well double check that "ssld" and "sslu" match up with the bears line and bulls line respectively.  

#### Using IndiProbe.mq5
To use any indicator we need to give it a handle which is just a global integer that we declare. I already declared one called IndiHandle so we can simple assign the SSL indicator to it in the OnInit function with the function [iCustom](https://www.mql5.com/en/docs/indicators/icustom). Please read the documentation.  
```
   IndiHandle = iCustom(_Symbol,PERIOD_CURRENT,"SSL_Channel_Chart.ex5");
```
Now all we need to do is take the data from the buffers and print them to the journal and we do this in the OnTick function. The OnTick funtion gets called every time price moves. The if statement is there so that the calculations are only performed at when a new bar/candle is formed. The code I have commented out is an example of what you might do if you want to check just 1 buffer. We will be replacing it with this:  
```
    double BufferValueA[];
    CopyBuffer(IndiHandle,0,1,1,BufferValueA);
    double BufferValueB[];
    CopyBuffer(IndiHandle,1,1,1,BufferValueB);
    Print("Buffer 0: ", BufferValueA[0], " | Buffer 1: ", BufferValueB[0]);
```
It's worth noting that CopyBuffer() will alway output an array of type double.  

We can now compile our file and try it out. This one is completely harmless and fine if you run it on a live chart. I highly recommend getting into the habit of running these programs in the strategy tester. There is no need to create a new file for every probe, just modify the existing one whenever you need it. 

We can now compare the values printed in the Journal to the values in the Data Window and will find that the values for the label "Bears" in the Data Window match the values we get from Buffer 0 and likewise for the "Bulls" label and Buffer 1. 

### Basic Template.mq5  
Now that we're sure about our indicator's buffers we can finally create our main backtest EA.  

1. The first thing you should do is create a new Expert Advisor. Choose the Expert Advisor (template) option, give it a name, click next, next, and finish.
2. Next, open Basic Template.mq5 and copy all of its code. (Ctrl+A, Ctrl+C)
3. Finally, replace everything in the new Expert Advisor. (Ctrl+A, Ctrl+V)  

#### Under Inputs:  
Add inputs for the indicator. You can find what inputs the indicator has in its source code. Also note that single line comments after input declarations will be used as labels in MT5's Trade Terminal.  
```
input group "SSL Inputs"
input ENUM_MA_METHOD inpSSL_MA_Method = MODE_SMA; // SSL MA Method
input int inpSSL_Period = 10; // SSL Period
```
#### Create and assign the handle:  
```
//+------------------------------------------------------------------+
//| Handles                                                          |
//+------------------------------------------------------------------+
int ATRChannelHandle;
int SSLHandle;
```
```
int OnInit()
  {
   barTotal = iBars(_Symbol,Timeframe);
   
   ATRChannelHandle = iCustom(_Symbol,Timeframe,"ATR Channel.ex5",MODE_SMA,1,inpATRPeriod,inpATRChannelFactor,inpATRChannelAppPrice);
   SSLHandle = iCustom(_Symbol,Timeframe,"SSL_Channel_Chart.ex5",inpSSL_MA_Method,inpSSL_Period);
   
   return(INIT_SUCCEEDED);
  }
```
Make sure that you add the inputs into iCustom in the same order that they appear in the indicator. It's always good to check the source code for this.  

#### Under Trade Signal Function:  
Firstly here's a small explanation. I created a custom enum called enTradeSignal with the following values:
- buy_signal
- sell_signal
- no_signal  
The trade signal function is of this type and must return one of those 3 value that then gets passed to the Check/Modify and Enter Position functions.  

The rules for the SSL indicator are simple. The aqua line crossing above the orange line is a buy signal and the the opposite  is a sell signal. 
```
//+------------------------------------------------------------------+
//| Trade Signal Function                                            |
//+------------------------------------------------------------------+
enTradeSignal CheckForSignal()
  {
   double SSLBullsValues[];
   CopyBuffer(SSLHandle,1,1,2,SSLBullsValues);
   ArrayReverse(SSLBullsValues);
   
   double SSLBearsValues[];
   CopyBuffer(SSLHandle,0,1,2,SSLBearsValues);
   ArrayReverse(SSLBearsValues);
   
   if ((SSLBullsValues[0] > SSLBearsValues[0]) && (SSLBullsValues[1] < SSLBearsValues[1]))
   {
    return buy_signal;
   }
   if ((SSLBullsValues[0] < SSLBearsValues[0]) && (SSLBullsValues[1] > SSLBearsValues[1]))
   {
    return sell_signal;
   }
   
   return no_signal;
  }

```
Why us ArrayReverse? So when we discuss trading strategies and talk about counting back a number of candles we count backwards from newest to oldest. The CopyBuffer function will return an array of candle data ordered oldest to newest. Using ArrayReverse just makes it easier to write and read your calculation code. We also start at candle position 1 (the most recent closed candle) because candle 0 is still open.  

And thats it. You can now compile and run your new EA in the strategy tester.  

### Final Notes:
***Do not*** run this EA in a live real money account, it can and will trade if you have Algo Trading enabled and could result in losses. Have fun testing confirmation indicators.  
At a later stage I might come back and add some functionality to allow you to choose between only 1 or multiple trades allowed at a time.
