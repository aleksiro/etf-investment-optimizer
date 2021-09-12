
-- Calculated monthly average prices per ETF
CREATE OR REPLACE VIEW pub.NN_KK_MONTHLY_AVG_PRICES
AS
    SELECT raw.TICKER
        , raw.MONTH
        , ROUND(AVG(raw.CLOSE_PRICE), 2) AS AVG_PRICE
        , ROW_NUMBER() OVER(PARTITION BY raw.TICKER ORDER BY raw.MONTH) AS ROW_NUMBER
    FROM (
        SELECT DISTINCT TICKER
            , FORMAT_DATE('%Y-%m', DATE) AS MONTH
            , DATE
            , CLOSE_PRICE
            , TURNOVER
        FROM (
            SELECT MAX(TIMESTAMP_MILLIS(LOAD_TIMESTAMP))    AS LOAD_TIMESTAMP
                , TICKER
                , DATE
                , MAX(CLOSE_PRICE)                         AS CLOSE_PRICE
                , MAX(TURNOVER)                            AS TURNOVER
            FROM dw.ETF_DAILY_CLOSE
            GROUP BY TICKER, DATE
        )
    ) raw
    GROUP BY raw.TICKER, raw.MONTH
    ORDER BY raw.TICKER, raw.MONTH DESC
;

-- Latest available price per ETF
CREATE OR REPLACE VIEW pub.NN_KK_LATEST_PRICE
AS 
    SELECT rnd.TICKER
        , MAX(ma.LATEST_DATE)   AS LATEST_DATE
        , MAX(rnd.CLOSE_PRICE)  AS CLOSE_PRICE
    FROM dw.ETF_DAILY_CLOSE rnd
    INNER JOIN (
        SELECT TICKER
            , MAX(DATE)    AS LATEST_DATE
        FROM dw.ETF_DAILY_CLOSE
        GROUP BY TICKER
    ) ma
        ON rnd.TICKER = ma.TICKER
        AND rnd.DATE = ma.LATEST_DATE 
    GROUP BY TICKER 
; 

-- Calculated slope, intercept and current price values per ETF
CREATE OR REPLACE VIEW pub.NN_KK_TREND_LINE_VALUES
AS
SELECT lr.TICKER
    , ROUND(lr.SLOPE * 100, 4)  AS SLOPE
    , ROUND((SELECT MAX(ROW_NUMBER) FROM pub.NN_KK_MONTHLY_AVG_PRICES WHERE TICKER = 'EUNL') * lr.SLOPE + lr.INTERCEPT, 3) AS CURRENT_PRICE
    , ROUND(INTERCEPT, 3)       AS INTERCEPT
FROM (
    SELECT TICKER 
        , ROW_NUMBER() OVER(PARTITION BY TICKER) AS ROW_NUMBER
        , SLOPE
        , MAX_AVG_PRICE_BAR
        , MAX_AVG_PRICE_BAR - MAX_ROW_NUMBER_BAR * SLOPE AS INTERCEPT
    FROM (
        SELECT TICKER 
            , SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (AVG_PRICE - AVG_PRICE_BAR)) 
                / IF(SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (ROW_NUMBER - ROW_NUMBER_BAR)) = 0, 1, SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (ROW_NUMBER - ROW_NUMBER_BAR)) ) AS SLOPE
            , MAX(ROW_NUMBER_BAR)  AS MAX_ROW_NUMBER_BAR
            , MAX(AVG_PRICE_BAR)   AS MAX_AVG_PRICE_BAR
        FROM (
            SELECT TICKER 
                , ROW_NUMBER
                , AVG(ROW_NUMBER) OVER() AS ROW_NUMBER_BAR
                , AVG_PRICE 
                , AVG(AVG_PRICE) OVER() AS AVG_PRICE_BAR
            FROM pub.NN_KK_MONTHLY_AVG_PRICES
            WHERE TICKER = 'EUNL'
        )
        GROUP BY TICKER
    )
    ) AS lr
    WHERE lr.TICKER = 'EUNL'

    UNION ALL 

    SELECT lr.TICKER
        , ROUND(lr.SLOPE * 100, 4)  AS SLOPE
        , ROUND((SELECT MAX(ROW_NUMBER) FROM pub.NN_KK_MONTHLY_AVG_PRICES WHERE TICKER = 'IUSN') * lr.SLOPE + lr.INTERCEPT, 3) AS CURRENT_PRICE
        , ROUND(INTERCEPT, 3)       AS INTERCEPT
    FROM (
        SELECT TICKER 
            , ROW_NUMBER() OVER(PARTITION BY TICKER) AS ROW_NUMBER
            , SLOPE
            , MAX_AVG_PRICE_BAR
            , MAX_AVG_PRICE_BAR - MAX_ROW_NUMBER_BAR * SLOPE AS INTERCEPT
        FROM (
            SELECT TICKER 
                , SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (AVG_PRICE - AVG_PRICE_BAR)) 
                    / IF(SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (ROW_NUMBER - ROW_NUMBER_BAR)) = 0, 1, SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (ROW_NUMBER - ROW_NUMBER_BAR)) ) AS SLOPE
                , MAX(ROW_NUMBER_BAR)  AS MAX_ROW_NUMBER_BAR
                , MAX(AVG_PRICE_BAR)   AS MAX_AVG_PRICE_BAR
            FROM (
                SELECT TICKER 
                    , ROW_NUMBER
                    , AVG(ROW_NUMBER) OVER() AS ROW_NUMBER_BAR
                    , AVG_PRICE 
                    , AVG(AVG_PRICE) OVER() AS AVG_PRICE_BAR
                FROM pub.NN_KK_MONTHLY_AVG_PRICES
                WHERE TICKER = 'IUSN'
            )
            GROUP BY TICKER
        )
    ) AS lr
    WHERE lr.TICKER = 'IUSN'

    UNION ALL 

    SELECT lr.TICKER
        , ROUND(lr.SLOPE * 100, 4)  AS SLOPE
        , ROUND((SELECT MAX(ROW_NUMBER) FROM pub.NN_KK_MONTHLY_AVG_PRICES WHERE TICKER = 'IS3N') * lr.SLOPE + lr.INTERCEPT, 3) AS CURRENT_PRICE
        , ROUND(INTERCEPT, 3)       AS INTERCEPT
    FROM (
        SELECT TICKER 
            , ROW_NUMBER() OVER(PARTITION BY TICKER) AS ROW_NUMBER
            , SLOPE
            , MAX_AVG_PRICE_BAR
            , MAX_AVG_PRICE_BAR - MAX_ROW_NUMBER_BAR * SLOPE AS INTERCEPT
        FROM (
            SELECT TICKER 
                , SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (AVG_PRICE - AVG_PRICE_BAR)) 
                    / IF(SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (ROW_NUMBER - ROW_NUMBER_BAR)) = 0, 1, SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (ROW_NUMBER - ROW_NUMBER_BAR)) ) AS SLOPE
                , MAX(ROW_NUMBER_BAR)  AS MAX_ROW_NUMBER_BAR
                , MAX(AVG_PRICE_BAR)   AS MAX_AVG_PRICE_BAR
            FROM (
                SELECT TICKER 
                    , ROW_NUMBER
                    , AVG(ROW_NUMBER) OVER() AS ROW_NUMBER_BAR
                    , AVG_PRICE 
                    , AVG(AVG_PRICE) OVER() AS AVG_PRICE_BAR
                FROM pub.NN_KK_MONTHLY_AVG_PRICES
                WHERE TICKER = 'IS3N'
            )
            GROUP BY TICKER
        )
    ) AS lr
    WHERE lr.TICKER = 'IS3N'
;


-- Monthly AVG and trend prices with current trend lines and upper&lower confidence intervals per ETF and Owner
CREATE OR REPLACE VIEW pub.NN_KK_MONTHLY_PRICES_WITH_TRENDS
AS
    SELECT ci.OWNER
        , tab.TICKER
        , tab.MONTH
        , tab.AVG_PRICE
        , tab.TREND_LINE
        , tab.CUR_TREND_LINE
        , tab.CUR_TREND_LINE * (1 + ci.CONFIDENCE_INTERVAL)    AS UPPER_CI
        , tab.CUR_TREND_LINE * (1 - ci.CONFIDENCE_INTERVAL)    AS LOWER_CI
    FROM (    
        SELECT pri.TICKER
            , pri.MONTH
            , pri.AVG_PRICE
            , ROUND(pri.ROW_NUMBER * mov_lr.SLOPE + mov_lr.INTERCEPT, 2) AS TREND_LINE
            , pri.ROW_NUMBER * cur_tre.SLOPE + cur_tre.INTERCEPT        AS CUR_TREND_LINE
        FROM pub.NN_KK_MONTHLY_AVG_PRICES pri
        LEFT JOIN (
            SELECT TICKER 
                , ROW_NUMBER() OVER(PARTITION BY TICKER) AS ROW_NUMBER
                , SLOPE
                , MAX_AVG_PRICE_BAR
                , MAX_AVG_PRICE_BAR - MAX_ROW_NUMBER_BAR * SLOPE AS INTERCEPT
            FROM (
                SELECT TICKER 
                    , SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (AVG_PRICE - AVG_PRICE_BAR)) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
                        / IF(SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (ROW_NUMBER - ROW_NUMBER_BAR)) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) = 0, 1, SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (ROW_NUMBER - ROW_NUMBER_BAR)) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS SLOPE
                    , MAX(ROW_NUMBER_BAR) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS MAX_ROW_NUMBER_BAR
                    , MAX(AVG_PRICE_BAR) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS MAX_AVG_PRICE_BAR
                FROM (
                    SELECT TICKER 
                        , ROW_NUMBER
                        , AVG(ROW_NUMBER) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ROW_NUMBER_BAR
                        , AVG_PRICE 
                        , AVG(AVG_PRICE) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS AVG_PRICE_BAR
                    FROM pub.NN_KK_MONTHLY_AVG_PRICES
                    WHERE TICKER = 'EUNL'
                )
            )
        ) AS mov_lr
            ON pri.TICKER = mov_lr.TICKER
            AND pri.ROW_NUMBER = mov_lr.ROW_NUMBER
        LEFT JOIN (
            SELECT TICKER
                , SLOPE / 100  AS SLOPE
                , INTERCEPT
            FROM pub.NN_KK_TREND_LINE_VALUES
            WHERE TICKER = 'EUNL'
        ) cur_tre
            ON pri.TICKER = cur_tre.TICKER
        WHERE pri.TICKER = 'EUNL'

        UNION ALL 

            SELECT pri.TICKER
            , pri.MONTH
            , pri.AVG_PRICE
            , ROUND(pri.ROW_NUMBER * mov_lr.SLOPE + mov_lr.INTERCEPT, 2) AS TREND_LINE
            , pri.ROW_NUMBER * cur_tre.SLOPE + cur_tre.INTERCEPT        AS CUR_TREND_LINE
        FROM pub.NN_KK_MONTHLY_AVG_PRICES pri
        LEFT JOIN (
            SELECT TICKER 
                , ROW_NUMBER() OVER(PARTITION BY TICKER) AS ROW_NUMBER
                , SLOPE
                , MAX_AVG_PRICE_BAR
                , MAX_AVG_PRICE_BAR - MAX_ROW_NUMBER_BAR * SLOPE AS INTERCEPT
            FROM (
                SELECT TICKER 
                    , SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (AVG_PRICE - AVG_PRICE_BAR)) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
                        / IF(SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (ROW_NUMBER - ROW_NUMBER_BAR)) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) = 0, 1, SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (ROW_NUMBER - ROW_NUMBER_BAR)) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS SLOPE
                    , MAX(ROW_NUMBER_BAR) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS MAX_ROW_NUMBER_BAR
                    , MAX(AVG_PRICE_BAR) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS MAX_AVG_PRICE_BAR
                FROM (
                    SELECT TICKER 
                        , ROW_NUMBER
                        , AVG(ROW_NUMBER) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ROW_NUMBER_BAR
                        , AVG_PRICE 
                        , AVG(AVG_PRICE) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS AVG_PRICE_BAR
                    FROM pub.NN_KK_MONTHLY_AVG_PRICES
                    WHERE TICKER = 'IUSN'
                )
            )
        ) AS mov_lr
            ON pri.TICKER = mov_lr.TICKER
            AND pri.ROW_NUMBER = mov_lr.ROW_NUMBER
        LEFT JOIN (
            SELECT TICKER
                , SLOPE / 100  AS SLOPE
                , INTERCEPT
            FROM pub.NN_KK_TREND_LINE_VALUES
            WHERE TICKER = 'IUSN'
        ) cur_tre
            ON pri.TICKER = cur_tre.TICKER
        WHERE pri.TICKER = 'IUSN'

        UNION ALL

            SELECT pri.TICKER
            , pri.MONTH
            , pri.AVG_PRICE
            , ROUND(pri.ROW_NUMBER * mov_lr.SLOPE + mov_lr.INTERCEPT, 2) AS TREND_LINE
            , pri.ROW_NUMBER * cur_tre.SLOPE + cur_tre.INTERCEPT        AS CUR_TREND_LINE
        FROM pub.NN_KK_MONTHLY_AVG_PRICES pri
        LEFT JOIN (
            SELECT TICKER 
                , ROW_NUMBER() OVER(PARTITION BY TICKER) AS ROW_NUMBER
                , SLOPE
                , MAX_AVG_PRICE_BAR
                , MAX_AVG_PRICE_BAR - MAX_ROW_NUMBER_BAR * SLOPE AS INTERCEPT
            FROM (
                SELECT TICKER 
                    , SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (AVG_PRICE - AVG_PRICE_BAR)) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
                        / IF(SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (ROW_NUMBER - ROW_NUMBER_BAR)) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) = 0, 1, SUM((ROW_NUMBER - ROW_NUMBER_BAR) * (ROW_NUMBER - ROW_NUMBER_BAR)) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)) AS SLOPE
                    , MAX(ROW_NUMBER_BAR) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS MAX_ROW_NUMBER_BAR
                    , MAX(AVG_PRICE_BAR) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS MAX_AVG_PRICE_BAR
                FROM (
                    SELECT TICKER 
                        , ROW_NUMBER
                        , AVG(ROW_NUMBER) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS ROW_NUMBER_BAR
                        , AVG_PRICE 
                        , AVG(AVG_PRICE) OVER(ORDER BY ROW_NUMBER ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS AVG_PRICE_BAR
                    FROM pub.NN_KK_MONTHLY_AVG_PRICES
                    WHERE TICKER = 'IS3N'
                )
            )
        ) AS mov_lr
            ON pri.TICKER = mov_lr.TICKER
            AND pri.ROW_NUMBER = mov_lr.ROW_NUMBER
        LEFT JOIN (
            SELECT TICKER
                , SLOPE / 100  AS SLOPE
                , INTERCEPT
            FROM pub.NN_KK_TREND_LINE_VALUES
            WHERE TICKER = 'IS3N'
        ) cur_tre
            ON pri.TICKER = cur_tre.TICKER
        WHERE pri.TICKER = 'IS3N'
    ) tab
    CROSS JOIN (
        SELECT OWNER
             , VALUE AS CONFIDENCE_INTERVAL
        FROM dw.REF_ETF_PARAMETERS_CURRENT
        WHERE PARAMETER_NAME = 'CONFIDENCE_INTERVAL'
    ) ci
;

-- Multipliers to use per ETF and owner
CREATE OR REPLACE VIEW pub.NN_KK_ETF_MULTIPLIERS
AS
    SELECT OWNER
        , TICKER
        , ROUND(PRICE_DIFFERENCE, 3)    AS PRICE_DIFFERENCE 
        , 2 * ((ADJ_PRICE_DIFF - (-1 * CI_MAX)) / (CI_MAX - (-1 * CI_MAX)))     AS MULTIPLIER
    FROM ( 
        SELECT ci.OWNER
            , pri.TICKER
            , PRICE_DIFFERENCE 
            , CASE
                WHEN pri.PRICE_DIFFERENCE >= ci.VALUE   THEN -1 * ci.VALUE
                WHEN pri.PRICE_DIFFERENCE <= (-1 * ci.VALUE)  THEN ci.VALUE
                ELSE ROUND(pri.PRICE_DIFFERENCE, 3) * -1
            END AS ADJ_PRICE_DIFF
            , ci.VALUE AS CI_MAX
        FROM (
            SELECT tlv.TICKER
                , tlv.CURRENT_PRICE    AS TREND_LINE_PRICE
                , lp.CLOSE_PRICE       AS LATEST_REALIZED_PRICE
                , (lp.CLOSE_PRICE - tlv.CURRENT_PRICE) / tlv.CURRENT_PRICE    AS PRICE_DIFFERENCE
            FROM pub.NN_KK_TREND_LINE_VALUES tlv
            LEFT JOIN pub.NN_KK_LATEST_PRICE lp
                ON tlv.TICKER = lp.TICKER
        ) AS pri
        CROSS JOIN (
            SELECT OWNER
                 , VALUE
            FROM dw.REF_ETF_PARAMETERS_CURRENT
            WHERE PARAMETER_NAME = 'CONFIDENCE_INTERVAL'
        ) AS ci
    )
;

--Calculated portions and sums to invest per ETF and Owner
CREATE OR REPLACE VIEW pub.NN_KK_ETF_CALC_RES_PORTION_AND_SUMS
AS
    SELECT mltp.OWNER
        , mltp.TICKER
        , mltp.PORTION                 AS ORIGINAL_PORTION
        , ROUND(mltp.MULTIPLIER, 3)    AS MULTIPLIER
        , ROUND(mltp.UNNORMALIZED_MULTIPLIER / SUM(mltp.UNNORMALIZED_MULTIPLIER) OVER(PARTITION BY mltp.OWNER), 3)   AS PORTION
        , ROUND(((1 - mltp.MOV_PART) * ins.INVESTMENT_SUM + mltp.MOV_PART * ins.INVESTMENT_SUM * AVG(mltp.MULTIPLIER) OVER(PARTITION BY mltp.OWNER)) *  ( mltp.UNNORMALIZED_MULTIPLIER / SUM(mltp.UNNORMALIZED_MULTIPLIER) OVER(PARTITION BY mltp.OWNER)), 2)  AS INVESTMENT_SUM
    FROM (
        SELECT rep.OWNER
            , rep.TICKER
            , rep.PORTION
            , em.MULTIPLIER
            , ci.MOV_PART
            , rep.PORTION * (1 - ci.MOV_PART) + rep.PORTION * ci.MOV_PART * em.MULTIPLIER   AS UNNORMALIZED_MULTIPLIER
        FROM dw.REF_ETF_PORTIONS rep
        LEFT JOIN pub.NN_KK_ETF_MULTIPLIERS em
            ON rep.TICKER = em.TICKER
            AND rep.OWNER = em.OWNER
        LEFT JOIN (
            SELECT OWNER
                 , VALUE AS MOV_PART
            FROM dw.REF_ETF_PARAMETERS_CURRENT
            WHERE PARAMETER_NAME = 'MOVING_PART'
        ) AS ci
            ON rep.OWNER = ci.OWNER
    ) mltp
    LEFT JOIN (
        SELECT OWNER
             , VALUE AS INVESTMENT_SUM
        FROM dw.REF_ETF_PARAMETERS_CURRENT
        WHERE PARAMETER_NAME = 'INVESTMENT_SUM'
    ) AS ins
        ON mltp.OWNER = ins.OWNER
;

-- Backtest to compare performance between fixed and adjusted price investing
CREATE OR REPLACE VIEW pub.NN_KK_ETF_PERFORMANCE    
AS
    SELECT tab.TICKER
        , COUNT(tab.BOUGHT_SUM_FIX) - 12            AS INVESTMENT_MONTHS
        , ROUND(SUM(tab.BOUGHT_SUM_ADJ) / SUM(tab.BOUGHT_AMOUNT_ADJ), 2)                            AS ADJ_AVERAGE_PRICE
        , ROUND(MAX(lp.CLOSE_PRICE) /  (SUM(tab.BOUGHT_SUM_ADJ) / SUM(tab.BOUGHT_AMOUNT_ADJ)) - 1, 3)   AS ADJ_TOTAL_RETURN
        , ROUND((MAX(lp.CLOSE_PRICE) /  (SUM(tab.BOUGHT_SUM_ADJ) / SUM(tab.BOUGHT_AMOUNT_ADJ)) - 1) / (COUNT(tab.BOUGHT_SUM_ADJ) - 12) * 12, 3)   AS ADJ_ROI_YEARLY
        , ROUND(SUM(tab.BOUGHT_SUM_FIX) / SUM(tab.BOUGHT_AMOUNT_FIX), 2)                            AS FIX_AVERAGE_PRICE
        , ROUND(MAX(lp.CLOSE_PRICE) / (SUM(tab.BOUGHT_SUM_FIX) / SUM(tab.BOUGHT_AMOUNT_FIX)) - 1, 3)    AS FIX_TOTAL_RETURN
        , ROUND((MAX(lp.CLOSE_PRICE) / (SUM(tab.BOUGHT_SUM_FIX) / SUM(tab.BOUGHT_AMOUNT_FIX)) - 1) / (COUNT(tab.BOUGHT_SUM_FIX) - 12) * 12, 3)    AS FIX_ROI_YEARLY 
        , ROUND(((MAX(lp.CLOSE_PRICE) /  (SUM(tab.BOUGHT_SUM_ADJ) / SUM(tab.BOUGHT_AMOUNT_ADJ)) - 1) / (COUNT(tab.BOUGHT_SUM_ADJ) - 12) * 12) - ((MAX(lp.CLOSE_PRICE) / (SUM(tab.BOUGHT_SUM_FIX) / SUM(tab.BOUGHT_AMOUNT_FIX)) - 1) / (COUNT(tab.BOUGHT_SUM_FIX) - 12) * 12), 4)    AS ADJ_VS_FIX_YEARLY_DIFFERENCE
    FROM (
        SELECT tb.TICKER
            , AVG_PRICE
            , ADJ_PRICE_DIFF
            , (mp.VALUE + mp.VALUE *  MULTIPLIER)    AS TRUE_MULTIPLIER
            , CASE
                WHEN ROWNUMBER > 12 THEN FLOOR((mp.VALUE + mp.VALUE *  MULTIPLIER) * ia.AMOUNT * por.PORTION / AVG_PRICE)                 
                ELSE 0
            END AS BOUGHT_AMOUNT_ADJ
            , CASE
                WHEN ROWNUMBER > 12 THEN FLOOR((mp.VALUE + mp.VALUE *  MULTIPLIER) * ia.AMOUNT * por.PORTION / AVG_PRICE) * AVG_PRICE    
                ELSE 0
            END AS BOUGHT_SUM_ADJ
            , CASE
                WHEN ROWNUMBER > 12 THEN FLOOR(ia.AMOUNT * por.PORTION / AVG_PRICE)              
                ELSE 0
            END AS BOUGHT_AMOUNT_FIX
            , CASE 
                WHEN ROWNUMBER > 12 THEN FLOOR(ia.AMOUNT * por.PORTION / AVG_PRICE) * AVG_PRICE  
                ELSE 0
            END AS BOUGHT_SUM_FIX
        FROM (
            SELECT TICKER
                , MONTH      
                , ROW_NUMBER() OVER(PARTITION BY TICKER ORDER BY MONTH ASC)     AS ROWNUMBER
                , AVG_PRICE
                , TREND_LINE
                , ADJ_PRICE_DIFF
                , 2 * ((ADJ_PRICE_DIFF - (-1 * CI_MAX)) / (CI_MAX - (-1 * CI_MAX)))     AS MULTIPLIER
            FROM (
                SELECT TICKER
                    , MONTH
                    , AVG_PRICE
                    , TREND_LINE
                    , CASE
                            WHEN PRICE_DIFF_PERC >= ci.VALUE   THEN -1 * ci.VALUE
                            WHEN PRICE_DIFF_PERC <= (-1 * ci.VALUE)  THEN ci.VALUE
                            ELSE ROUND(PRICE_DIFF_PERC, 3) * -1
                        END AS ADJ_PRICE_DIFF
                        , ci.VALUE AS CI_MAX
                FROM (
                    SELECT mpt.TICKER
                        , mpt.MONTH
                        , mpt.AVG_PRICE
                        , mpt.TREND_LINE
                        , mpt.AVG_PRICE - mpt.TREND_LINE   AS PRICE_DIFF
                        , (mpt.AVG_PRICE - mpt.TREND_LINE) / mpt.TREND_LINE    AS PRICE_DIFF_PERC
                    FROM pub.NN_KK_MONTHLY_PRICES_WITH_TRENDS mpt
                    WHERE OWNER = 'USER1'
                )
                CROSS JOIN (
                    SELECT OWNER
                            , VALUE
                    FROM dw.REF_ETF_PARAMETERS_CURRENT
                    WHERE PARAMETER_NAME = 'CONFIDENCE_INTERVAL'
                        AND OWNER = 'USER1'
                ) AS ci
            )
        ) tb
        LEFT JOIN (
            SELECT TICKER
                , PORTION
            FROM dw.REF_ETF_PORTIONS
            WHERE OWNER = 'USER1'
        ) AS por
            ON por.TICKER = tb.TICKER
        CROSS JOIN (
            SELECT OWNER
                    , VALUE
            FROM dw.REF_ETF_PARAMETERS_CURRENT
            WHERE PARAMETER_NAME = 'MOVING_PART'
                AND OWNER = 'USER1'
        ) AS mp
        CROSS JOIN (
            SELECT OWNER
                , VALUE     AS AMOUNT
            FROM dw.REF_ETF_PARAMETERS_CURRENT
            WHERE PARAMETER_NAME = 'INVESTMENT_SUM'
                AND OWNER = 'USER1'
        ) AS ia
    ) tab
    LEFT JOIN pub.NN_KK_LATEST_PRICE lp
        ON tab.TICKER = lp.TICKER
    GROUP BY tab.TICKER
;