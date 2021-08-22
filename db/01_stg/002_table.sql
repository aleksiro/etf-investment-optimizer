
-- Ingest table for raw Nordnet daily data
CREATE OR REPLACE TABLE  stg.RAW_NORDNET_DATA (
    LOAD_TIMESTAMP INT,
    TICKER STRING,
    DATE STRING,
    CLOSE_PRICE DECIMAL(6,2),
    TURNOVER INT
)
;

-- Ingest table for raw Yahoo daily data
CREATE OR REPLACE TABLE  stg.RAW_NORDNET_DATA (
    LOAD_TIMESTAMP INT,
    TICKER STRING,
    DATE STRING,
    CLOSE_PRICE DECIMAL(6,2),
    TURNOVER INT
)
;
