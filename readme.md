# MT5 Indicator Testers  
The files in this repository are basic MetaTrader5 Expert Advisors(EAs) that I created for the purpose of testing single confirmation indicators.  
> I did this by first creating my own basic template to use. This made it easy to create multiple EAs as the process involved copying the template, changing a few lines and writing a function for the indicator.  

## Disclaimer:  
The Expert Advisors within this repository are written to be used with MetaTrader 5's Backtester. **DO NOT** use them to trade live. Trading invloves significant risk and I take *no* responsible for any losses incured by ignoring my warning.  

## EAs:  
If you just want to view the source code look at the .mq5 files. If you want to run these within MetaTrader 5's backtester, you will need to place the ex5 and mq5 files into MQL5/Experts folder. You may need to recompile the some of them from within MetaEditor. You will also need the required indicators.  

## Indicators:
The provided indicators come from the MQL5 codebase and are considered freeware. If you encounter errors about being unable to locate an indicator, either change the source code to point the EA to where the Indicator is stored. The EAs here with either look in MQL5/Indicators/Downloads or just MQL5/Indicators. 