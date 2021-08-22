-- Procedure used to load new rows from Nordnet staging table to ETF_DAILY_CLOSE table.
CREATE PROCEDURE IF NOT EXISTS stg.LOAD_NEW_ETF_DAILY_CLOSE()
BEGIN
    INSERT INTO dw.ETF_DAILY_CLOSE 
        SELECT stg.LOAD_TIMESTAMP
            , stg.TICKER
            , PARSE_DATE('%Y%m%d', stg.DATE) AS DATE 
            , stg.CLOSE_PRICE 
            , stg.TURNOVER 
        FROM stg.RAW_NORDNET_DATA stg
        INNER JOIN (
            SELECT MAX(LOAD_TIMESTAMP) AS MAX_TS
                , TICKER
                , DATE
            FROM stg.RAW_NORDNET_DATA
            GROUP BY TICKER, DATE
        ) latest
            ON stg.TICKER = latest.TICKER
            AND stg.DATE  = latest.DATE
            AND stg.LOAD_TIMESTAMP = MAX_TS
        WHERE CONCAT(stg.TICKER, PARSE_DATE('%Y%m%d', stg.DATE)) NOT IN 
            (SELECT CONCAT(TICKER, DATE)
            FROM dw.ETF_DAILY_CLOSE);
END
;