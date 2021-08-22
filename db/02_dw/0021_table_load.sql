-- Manual insert for ETF dimensional data
INSERT INTO dw.REF_TICKERS VALUES 
('IUSN', 'iShares MSCI World Small Cap UCITS ETF USD (Acc)', 'BlackRock Asset Management Ireland Limited', 'GER', 0.35, 'Accumulation', 'Physical'),
('EUNL', 'iShares Core MSCI World UCITS ETF', 'BlackRock Asset Management Ireland Limited', 'GER', 0.20, 'Accumulation', 'Physical'),
('IS3N', 'iShares Core MSCI EM IMI UCITS ETF USD (Acc)', 'BlackRock Asset Management Ireland Limited', 'GER', 0.18, 'Accumulation', 'Physical')
;

-- Manual insert for ETF portions
INSERT INTO dw.REF_ETF_PORTIONS VALUES 
    ('USER1', 'IUSN', 0.25),
    ('USER1', 'EUNL',  0.50),
    ('USER1', 'IS3N',  0.25),
    ('USER2', 'IUSN', 0.10),
    ('USER2', 'EUNL',  0.80),
    ('USER2', 'IS3N',  0.10)
;

--Manual insert for ETF parameters
INSERT INTO dw.REF_ETF_PARAMETERS VALUES 
    ('USER1', '2021-07-19', 'MOVING_PART', 0.50),
    ('USER1', '2021-07-19', 'CONFIDENCE_INTERVAL', 0.08),
    ('USER1', '2017-07-19', 'INVESTMENT_SUM', 1500),
    ('USER2', '2021-07-23', 'MOVING_PART', 0.25),
    ('USER2', '2021-07-23', 'CONFIDENCE_INTERVAL', 0.12),
    ('USER2', '2017-07-23', 'INVESTMENT_SUM', 1000)
;

-- Insert Yahoo historical data as base for ETF_DAILY_CLOSE table
INSERT INTO dw.ETF_DAILY_CLOSE
    SELECT ryt.LOAD_TIMESTAMP
        , ryt.TICKER
        , PARSE_DATE('%Y-%m-%d',  ryt.DATE)    AS DATE
        , ryt.CLOSE_PRICE
        , ryt.TURNOVER
    FROM stg.RAW_YAHOO_TABLE ryt 
    LEFT OUTER JOIN dw.ETF_DAILY_CLOSE edc
        ON ryt.TICKER = edc.TICKER
        AND PARSE_DATE('%Y-%m-%d',  ryt.DATE) = edc.DATE
    WHERE edc.CLOSE_PRICE IS NULL
    AND ryt.CLOSE_PRICE IS NOT NULL
; 

