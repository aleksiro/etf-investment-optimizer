-- Dimensional data for chosen ETF tickers
CREATE OR REPLACE TABLE dw.REF_TICKERS
( 
    TICKER STRING,
    FULL_NAME STRING,
    ISSUER STRING,
    COUNTRY STRING,
    RUNNING_COST DECIMAL(4,2),
    DIVIDENT_POLICY STRING,
    ETF_TYPE STRING
)
;

-- Chosen ETF portions per owner. Should add up to 1.00 per owner.
CREATE OR REPLACE TABLE dw.REF_ETF_PORTIONS
( 
    OWNER STRING,
    TICKER STRING,
    PORTION DECIMAL (3,2)
)
;

-- Used parameters for ETF calculations per owner 
CREATE OR REPLACE TABLE dw.REF_ETF_PARAMETERS
( 
    OWNER STRING,
    VALID_FROM DATE,
    PARAMETER_NAME STRING,
    VALUE DECIMAL(10,2)
)
;

-- Daily close prices and and turnovers per ETF ticker 
CREATE OR REPLACE TABLE dw.ETF_DAILY_CLOSE (
    LOAD_TIMESTAMP INT,
    TICKER STRING,
    DATE DATE,
    CLOSE_PRICE DECIMAL(6,2),
    TURNOVER INT
);

