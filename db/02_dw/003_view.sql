-- Current view to show valid rows for ETF parameters
CREATE OR REPLACE VIEW dw.REF_ETF_PARAMETERS_CURRENT
AS
    SELECT OWNER
         , PARAMETER_NAME
         , VALUE
        FROM (
            SELECT OWNER
                , PARAMETER_NAME
                , VALUE
                , ROW_NUMBER() OVER(PARTITION BY OWNER, PARAMETER_NAME ORDER BY VALID_FROM DESC) AS RN
            FROM dw.REF_ETF_PARAMETERS
            WHERE CURRENT_DATE() >= VALID_FROM
        )
        WHERE RN = 1
;

