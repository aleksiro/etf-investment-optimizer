# Database documentation
Includes all sql-codes to initialize schemas, tables, views and procedures to perform needed calculations for optimizing ETF buyings.


## stg schema
Staging schema where data is inserted
### Tables
- `stg.RAW_NORDNET_DATA` - Ingestion table for raw Nordnet daily data (latest 5 years)
- `stg.RAW_YAHOO_DATA` - Ingestion table for raw Yahoo daily data (as far as ticker history available) 


## dw schema
Data warehouse schema where data is persisted and curated from different sources. **User input required for REF_ -tables.**
### Tables
- `dw.REF_TICKERS` - Dimensional background data for chosen ETF tickers
- `dw.REF_ETF_PORTIONS` - Chosen ETF portions per owner. The ETF portions should sum up to 1.00 per user  
- `dw.REF_ETF_PARAMETERS` - Required calculation parameters used in calculations per user. Parameters: 
  - MOVING_PART: Part of the investment sum that is adjusted according to the current market trend
  - CONFIDENCE_INTERVAL: Percentage allowed to differ from trend value. For example if current price is +15% from trend price and CONFIDENCE_INTERVAL is set to 0.08, used price in calculations is +8%
  - INVESTMENT_SUM: Desired monthly average investment sum
- `dw.ETF_DAILY_CLOSE` - Daily close prices and turnovers per ETF ticker. Combines and enriches raw Nordnet and Yahoo data

### Views
- `dw.REF_ETF_PARAMETERS_CURRENT` - Currently used parameter values per user. Used as a helping view for further calculations

### Procedures
- `dw.LOAD_NEW_ETF_DAILY_CLOSE()` - Used to load new rows from `stg.RAW_NORDNET_DATA` table to `dw.ETF_DAILY_CLOSE` table


## pub schema
Publish schema where calculations are performed and outputs are available to reporting tools

### Views
- `pub.NN_KK_MONTHLY_AVG_PRICES` - Calculated monthly close price averages per ETF tickers
- `pub.NN_KK_LATEST_PRICE` - Latest available close prices per ETF tickers
- `pub.NN_KK_TREND_LINE_VALUES` - Calculated Trend line slope, intercept value and current trend line price per ETF calculated from historical close data
- `pub.NN_KK_MONTHLY_PRICES_WITH_TRENDS` - Monthly (realized) average prices, calculated momentarily trend prices,  current trend line values over time per ETF and user with lower and upper condifence interval values. Used for visualizations in reporting tool 
- `pub.NN_KK_ETF_MULTIPLIERS` - Based on trend lines and current close prices multipliers and current price differences to use in monthly investments
- `pub.NN_KK_ETF_CALC_RES_PORTION_AND_SUMS` - Calculated portions and investment sums to input as Nordnet monthly investment inputs per owner and ETF ticker
- `pub.NN_KK_ETF_PERFORMANCE` - Backtest the performance of optimizing buying sums vs. buying fixed sums for the same period. Displays KPIs for the performances like ROI difference between two strategies