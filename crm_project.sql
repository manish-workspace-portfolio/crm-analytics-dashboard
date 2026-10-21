							               /*======================================================
										                  CRM Analytics Dashboard
								                DOMAIN: Customer Relationship Management (CRM)
							                 ================================================= */       
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#CREATING A DATABASE
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE DATABASE crm_analytics;
USE crm_analytics;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#CREATING Leads & Opportunities TABLES TO GET IMPORTED DATA FROM MS EXCEL SHEET (DO NOT RUN BELOW QUERY AGAIN AS ONCE EXECUTED, REPEATED EXECUTION GIVES ERROR & DISTURBANCE)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE crm_leads (
    lead_id VARCHAR(18) NOT NULL,
    converted TINYINT,
    converted_account_id VARCHAR(18),
    converted_opportunity_id VARCHAR(18),
    created_date DATETIME,
    industry VARCHAR(150),
    lead_source VARCHAR(150),
    region VARCHAR(100),
    status VARCHAR(100),
    status_simplified VARCHAR(100),
    lead_score DECIMAL(10,2),
    is_converted TINYINT,
    lead_age_days INT,
    created_year INT,
    created_month VARCHAR(20),
    month_year DATE,
    converted_opportunity_expected_amount DECIMAL(18,2),
    industry_display VARCHAR(150),
    source_display VARCHAR(150),
    lead_source_standardized VARCHAR(150),

    PRIMARY KEY (lead_id)
);

SHOW TABLES;

CREATE TABLE crm_opportunities (
    opportunity_id VARCHAR(18) NOT NULL,
    account_id VARCHAR(18),
    close_date DATE,
    closed TINYINT,
    closed_lost_reason VARCHAR(150),
    created_date DATETIME,
    deleted TINYINT,
    industry VARCHAR(150),
    opportunity_type VARCHAR(150),
    owner_id VARCHAR(18),
    stage VARCHAR(200),
    won TINYINT,
    amount DECIMAL(18,2),
    expected_amount DECIMAL(18,2),
    probability DECIMAL(5,2),
    created_year INT,
    created_month VARCHAR(20),
    close_year INT,
    deal_size_band VARCHAR(50),
    days_to_close INT,
    stage_group VARCHAR(30),
    account_name VARCHAR(255),
    account_match_status VARCHAR(50),
    created_month_year DATE,
    created_month_label VARCHAR(20),
    close_month_label VARCHAR(20),
    opportunity_type_display VARCHAR(150),
    closed_lost_reason_display VARCHAR(150),
    is_active TINYINT,
    is_won TINYINT,
    is_lost TINYINT,
    is_closed TINYINT,
    won_revenue DECIMAL(18,2),
    opportunity_industry_standardized VARCHAR(150),

    PRIMARY KEY (opportunity_id)
);

SHOW TABLES;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Note - SOME CLEANING IN ABOVE TABLE TO GET DESIRED COLUMNS (DO NOT RUN BELOW QUERY AGAIN AS ONCE EXECUTED, REPEATED EXECUTION GIVES ERROR & DISTURBANCE)
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE crm_opportunities
ADD COLUMN created_date_start_of_month DATE AFTER account_match_status,
ADD COLUMN close_date_start_of_month DATE AFTER created_date_start_of_month;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#IMPORTING DATASETS
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SHOW VARIABLES LIKE 'local_infile';  #Note - (DO NOT RUN BELOW QUERY AGAIN AS ONCE EXECUTED, REPEATED EXECUTION GIVES ERROR & DISTURBANCE)
SET GLOBAL local_infile = 1;         #Note - (DO NOT RUN BELOW QUERY AGAIN AS ONCE EXECUTED, REPEATED EXECUTION GIVES ERROR & DISTURBANCE)

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#LEADS DATASET
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Note - (DO NOT RUN BELOW QUERY AGAIN AS ONCE EXECUTED, REPEATED EXECUTION GIVES ERROR & DISTURBANCE)
LOAD DATA LOCAL INFILE 'C:/Users/Manish/OneDrive/Desktop/CRM Project/Clean_lead.csv'
INTO TABLE crm_leads
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    @converted,
    @converted_account_id,
    @converted_opportunity_id,
    @created_date,
    @industry,
    @lead_id,
    @lead_source,
    @region,
    @status,
    @status_simplified,
    @lead_score,
    @is_converted,
    @lead_age_days,
    @created_year,
    @created_month,
    @month_year,
    @converted_opportunity_expected_amount,
    @industry_display,
    @source_display,
    @lead_source_standardized
)
SET
    lead_id = NULLIF(@lead_id, ''),
    converted = CASE
        WHEN UPPER(@converted) = 'TRUE' THEN 1
        WHEN UPPER(@converted) = 'FALSE' THEN 0
        ELSE NULL
    END,
    converted_account_id = NULLIF(@converted_account_id, ''),
    converted_opportunity_id = NULLIF(@converted_opportunity_id, ''),
    created_date = STR_TO_DATE(NULLIF(@created_date, ''), '%c/%e/%Y %H:%i'),
    industry = NULLIF(@industry, ''),
    lead_source = NULLIF(@lead_source, ''),
    region = NULLIF(@region, ''),
    status = NULLIF(@status, ''),
    status_simplified = NULLIF(@status_simplified, ''),
    lead_score = NULLIF(@lead_score, ''),
    is_converted = NULLIF(@is_converted, ''),
    lead_age_days = NULLIF(@lead_age_days, ''),
    created_year = NULLIF(@created_year, ''),
    created_month = NULLIF(@created_month, ''),
    month_year = STR_TO_DATE(NULLIF(@month_year, ''), '%c/%e/%Y'),
    converted_opportunity_expected_amount = NULLIF(@converted_opportunity_expected_amount, ''),
    industry_display = NULLIF(@industry_display, ''),
    source_display = NULLIF(@source_display, ''),
    lead_source_standardized = NULLIF(@lead_source_standardized, '');
    
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#DATA VALIDATION
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#1) Confirm Total Records and Check Table Display
SELECT COUNT(*) AS total_rows
FROM crm_leads;

SELECT
    lead_id,
    converted,
    created_date,
    industry,
    lead_source,
    status,
    status_simplified,
    lead_score,
    is_converted,
    lead_age_days,
    created_year,
    created_month,
    month_year
FROM crm_leads
LIMIT 10;

#2) Check Duplicate Lead IDs
SELECT lead_id, COUNT(*) AS duplicate_count
FROM crm_leads
GROUP BY lead_id
HAVING COUNT(*) > 1;

#3) Check NULL Lead IDs
SELECT COUNT(*) AS null_lead_ids
FROM crm_leads
WHERE lead_id IS NULL OR TRIM(lead_id) = '';

#4) Check Converted Values
SELECT converted, COUNT(*) AS count_records
FROM crm_leads
GROUP BY converted;

SELECT is_converted, COUNT(*) AS count_records
FROM crm_leads
GROUP BY is_converted;

#5) Check Important NULL or Missing Values
SELECT
    SUM(lead_id IS NULL) AS missing_lead_id,
    SUM(created_date IS NULL) AS missing_created_date,
    SUM(industry IS NULL) AS missing_industry,
    SUM(lead_source IS NULL) AS missing_lead_source,
    SUM(status IS NULL) AS missing_status,
    SUM(lead_score IS NULL) AS missing_lead_score
FROM crm_leads;

#6) Check Date Range
SELECT
    MIN(created_date) AS earliest_lead,
    MAX(created_date) AS latest_lead
FROM crm_leads;

#7) Check Lead Source Distribution
SELECT
    lead_source_standardized,
    COUNT(*) AS total_leads
FROM crm_leads
GROUP BY lead_source_standardized
ORDER BY total_leads DESC;

#8) Check Status Distribution
SELECT
    status,
    COUNT(*) AS total_leads
FROM crm_leads
GROUP BY status
ORDER BY total_leads DESC;

#9) Check Industry Distribution
SELECT
    industry_display,
    COUNT(*) AS total_leads
FROM crm_leads
GROUP BY industry_display
ORDER BY total_leads DESC;

#10) Check Conversion Rate
SELECT
    COUNT(*) AS total_leads,
    SUM(is_converted) AS converted_leads,
    ROUND(SUM(is_converted) * 100.0 / COUNT(*), 2) AS conversion_rate_pct
FROM crm_leads;

#11) Check Unique IDs 
SELECT COUNT(*) AS total,
       COUNT(DISTINCT lead_id) AS unique_ids
FROM crm_leads;

#12) Check Converted & Non-Converted Leads No.s
SELECT
    SUM(converted = 1) AS converted_leads,
    SUM(converted = 0) AS non_converted_leads
FROM crm_leads;

#13) Check What's the Value of Conversion Rate
SELECT
    ROUND(
        SUM(converted = 1) / COUNT(*) * 100,
        2
    ) AS conversion_rate_pct
FROM crm_leads;

#14) Check Leads by Source (as an example to see values)
SELECT
    lead_source,
    lead_source_standardized,
    COUNT(*) AS records
FROM crm_leads
GROUP BY
    lead_source,
    lead_source_standardized
ORDER BY
    lead_source;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
#LEADS VIEW
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#(A) LEADS DASHBOARD VIEW (DO NOT EXECUTE AGAIN, ONCE EXECUTED, TO CHECK EXECUTE BELOW VALIDATION)
CREATE OR REPLACE VIEW vw_lead_dashboard AS
SELECT
    l.lead_id,
    l.converted,
    l.converted_account_id,
    l.converted_opportunity_id,
    l.created_date,
    l.industry_display,
    l.lead_source_standardized,
    l.source_display,
    l.region,
    l.status,
    l.status_simplified,
    l.lead_score,
    l.is_converted,
    l.lead_age_days,
    l.created_year,
    l.created_month,
    l.month_year
FROM crm_leads l;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#VALIDATION
-----------
SELECT *
FROM vw_leads_dashboard
LIMIT 10;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*(B) LEADS KPIs VIEW (DO NOT EXECUTE AGAIN, ONCE EXECUTED, TO CHECK EXECUTE BELOW VALIDATION)
PART I - Joined crm_leads to crm_opportunities and calculated the amount using unique Opportunity IDs, avoiding double-counting OF the repeated opportunity references.*/
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_lead_kpis AS
SELECT
    COUNT(*) AS total_leads,

    SUM(
        CASE
            WHEN l.converted = 1 THEN 1
            ELSE 0
        END
    ) AS converted_leads,

    SUM(
        CASE
            WHEN l.converted = 0 THEN 1
            ELSE 0
        END
    ) AS unconverted_leads,

    ROUND(
        SUM(
            CASE
                WHEN l.converted = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),
        2
    ) AS conversion_rate_pct,

    (
        SELECT COUNT(DISTINCT converted_opportunity_id)
        FROM crm_leads
        WHERE converted = 1
          AND converted_opportunity_id IS NOT NULL
          AND TRIM(converted_opportunity_id) <> ''
    ) AS unique_converted_opportunities,

    (
        SELECT SUM(o.expected_amount)
        FROM (
            SELECT DISTINCT converted_opportunity_id
            FROM crm_leads
            WHERE converted = 1
              AND converted_opportunity_id IS NOT NULL
              AND TRIM(converted_opportunity_id) <> ''
        ) x
        INNER JOIN crm_opportunities o
            ON x.converted_opportunity_id = o.opportunity_id
    ) AS converted_expected_amount,

    SUM(
        CASE
            WHEN l.converted = 1
             AND (
                 l.converted_opportunity_id IS NULL
                 OR TRIM(l.converted_opportunity_id) = ''
             )
            THEN 1
            ELSE 0
        END
    ) AS converted_without_opportunity_id

FROM crm_leads l;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#VALIDATION
-----------
SELECT *
FROM vw_lead_kpis;

DESCRIBE vw_lead_kpis;

SHOW CREATE VIEW vw_lead_kpis;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*PART II - This is important because the Excel's cleaned dataset's converted-opportunity amount uses unique opportunities.
                                   (DO NOT EXECUTE AGAIN, ONCE EXECUTED, TO CHECK EXECUTE BELOW VALIDATION)*/ 
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_lead_kpis AS
SELECT
    COUNT(*) AS total_leads,

    SUM(
        CASE
            WHEN converted = 1 THEN 1
            ELSE 0
        END
    ) AS converted_leads,

    COUNT(DISTINCT converted_account_id)
        AS converted_accounts,

    COUNT(DISTINCT converted_opportunity_id)
        AS converted_opportunities,

    ROUND(
        SUM(
            CASE WHEN converted = 1 THEN 1 ELSE 0 END
        ) / COUNT(*) * 100,
        2
    ) AS conversion_rate_pct,

    (
        SELECT ROUND(SUM(x.expected_amount), 2)
        FROM (
            SELECT
                l.converted_opportunity_id,
                MAX(o.expected_amount) AS expected_amount
            FROM crm_leads l
            INNER JOIN crm_opportunities o
                ON l.converted_opportunity_id =
                   o.opportunity_id
            WHERE l.converted_opportunity_id IS NOT NULL
            GROUP BY l.converted_opportunity_id
        ) x
    ) AS expected_amount_from_converted_leads

FROM crm_leads;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#VALIDATION
-----------
SELECT *
FROM vw_lead_kpis;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*PART - III  SEPARATE 5 VIEWS makes the Tableau build much cleaner and allow you to reproduce the calculations from your Excel in MySQL.
                                (WHERE FOR EACH VIEW DATA VALIDATION QUERY GIVEN EXECUTE IT FOR GETTING OUTPUT)*/
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#View 1 - OVERALL LEADS KPI

CREATE OR REPLACE VIEW vw_lead_kpis AS
SELECT
    COUNT(*) AS total_leads,

    SUM(
        CASE
            WHEN is_converted = 1 THEN 1
            ELSE 0
        END
    ) AS converted_leads,

    ROUND(
        SUM(
            CASE
                WHEN is_converted = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS conversion_rate_pct,

    ROUND(AVG(lead_score), 2) AS average_lead_score

FROM crm_leads;
------------------
#VALIDATION
------------------
SELECT *
FROM vw_lead_kpis;
#--------------------------------------------------------------------------------------||-------------------------------------------------------------------------------------#
#View 2 - LEADS BY SOURCE

CREATE OR REPLACE VIEW vw_leads_by_source AS
SELECT
    COALESCE(source_display, 'Unknown') AS lead_source,

    COUNT(*) AS total_leads,

    SUM(
        CASE
            WHEN is_converted = 1 THEN 1
            ELSE 0
        END
    ) AS converted_leads,

    ROUND(
        SUM(
            CASE
                WHEN is_converted = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS conversion_rate_pct

FROM crm_leads
GROUP BY COALESCE(source_display, 'Unknown')
ORDER BY total_leads DESC;
--------------------------
#VALIDATION
--------------------------
SELECT *
FROM vw_leads_by_source;
#---------------------------------------------------------------------------------------||------------------------------------------------------------------------------------#
#View 3 - LEADS BY INDUSTRY

CREATE OR REPLACE VIEW vw_leads_by_industry AS
SELECT
    COALESCE(industry_display, 'Unknown') AS industry,

    COUNT(*) AS total_leads,

    SUM(
        CASE
            WHEN is_converted = 1 THEN 1
            ELSE 0
        END
    ) AS converted_leads,

    ROUND(
        SUM(
            CASE
                WHEN is_converted = 1 THEN 1
                ELSE 0
            END
        ) * 100.0 / NULLIF(COUNT(*), 0),
        2
    ) AS conversion_rate_pct

FROM crm_leads
GROUP BY COALESCE(industry_display, 'Unknown')
ORDER BY total_leads DESC;
-------------------------
#VALIDATION
-------------------------
SELECT *
FROM vw_leads_by_industry;
#-----------------------------------------------------------------------------------||----------------------------------------------------------------------------------------#
#View 4 - LEAD STATUS

CREATE OR REPLACE VIEW vw_leads_by_status AS
SELECT
    COALESCE(NULLIF(TRIM(status), ''), 'Unknown') AS status,

    COUNT(*) AS total_leads

FROM crm_leads
GROUP BY COALESCE(NULLIF(TRIM(status), ''), 'Unknown')
ORDER BY total_leads DESC;
-------------------------
#VALIDATION
-------------------------
SELECT *
FROM vw_leads_by_status;
#----------------------------------------------------------------------------------||-----------------------------------------------------------------------------------------#
#View 5 - CONVERTED ACCOUNTS, CONVERTED OPPORTUNITIES, EXPECTED AMOUNT FROM CONVERTED LEADS

CREATE OR REPLACE VIEW vw_converted_lead_summary AS

SELECT
    COUNT(DISTINCT l.converted_account_id) AS converted_accounts,

    COUNT(DISTINCT l.converted_opportunity_id) AS converted_opportunities,

    ROUND(
        (
            SELECT COALESCE(SUM(x.expected_amount), 0)
            FROM (
                SELECT DISTINCT
                    converted_opportunity_id,
                    converted_opportunity_expected_amount AS expected_amount
                FROM crm_leads
                WHERE is_converted = 1
                  AND converted_opportunity_id IS NOT NULL
            ) x
        ),
        2
    ) AS total_expected_amount

FROM crm_leads l
WHERE l.is_converted = 1;
-----------------------------
#VALIDATION
------------------------------
SELECT *
FROM vw_converted_lead_summary;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

/*IMPORTING OPPORTUNITIES DATASET (FOR AVAILING POPULATED OPPORTUNITIES TABLE AS FOR LEADS FEW KPI CALCULATION DEPENDENT ON LEADS-OPPORTUNITIES TABLE RELATIONSHIP)
                                    Note - (DO NOT EXECUTE AGAIN, ONCE EXECUTED BELOW IMPORTING QUERY, IT MAY DISTURB AND GIVE ERROR)*/
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LOAD DATA LOCAL INFILE 'C:/Users/Manish/OneDrive/Desktop/CRM Project/Clean_opportunity.csv'
INTO TABLE crm_opportunities
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
    account_id,
    close_date,
    closed,
    closed_lost_reason,
    created_date,
    deleted,
    industry,
    opportunity_id,
    opportunity_type,
    owner_id,
    stage,
    won,
    amount,
    expected_amount,
    probability,
    created_year,
    created_month,
    close_year,
    deal_size_band,
    days_to_close,
    stage_group,
    account_name,
    account_match_status,
    created_date_start_of_month,
    close_date_start_of_month,
    opportunity_type_display,
    closed_lost_reason_display,
    is_active,
    is_won,
    is_lost,
    is_closed,
    won_revenue,
    opportunity_industry_standardized,
    created_month_year,
    created_month_label,
    close_month_label
);
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#FEW VALIDATIONS TO CHECK PROPER IMORTING OF OPPORTUNITIES DATASET OCCURRED
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

SELECT COUNT(*) AS total_opportunities
FROM crm_opportunities;

SELECT *
FROM crm_opportunities
LIMIT 5;

SELECT
    opportunity_id,
    account_id,
    close_date,
    created_date,
    stage,
    won,
    amount,
    expected_amount,
    created_date_start_of_month,
    close_date_start_of_month,
    opportunity_type_display,
    closed_lost_reason_display,
    is_active,
    is_won,
    is_lost,
    is_closed,
    won_revenue,
    opportunity_industry_standardized,
    created_month_year,
    created_month_label,
    close_month_label
FROM crm_opportunities
LIMIT 10;

SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT opportunity_id) AS unique_opportunities
FROM crm_opportunities;

SELECT
    COUNT(*) AS total_opportunities,
    SUM(is_won) AS won_opportunities,
    SUM(is_lost) AS lost_opportunities,
    SUM(is_closed) AS closed_opportunities,
    SUM(is_active) AS active_opportunities,
    SUM(won_revenue) AS total_won_revenue,
    SUM(expected_amount) AS total_expected_amount
FROM crm_opportunities;

SELECT
    opportunity_id,
    account_id,
    close_date,
    closed,
    stage,
    won,
    amount,
    expected_amount,
    probability,
    created_date_start_of_month,
    close_date_start_of_month,
    is_won,
    is_lost,
    is_closed,
    won_revenue
FROM crm_opportunities
LIMIT 10;

SELECT
    COUNT(*) AS total_opportunities,
    COUNT(expected_amount) AS expected_amount_non_null,
    SUM(expected_amount) AS total_expected_amount
FROM crm_opportunities;

SELECT
    opportunity_id,
    amount,
    probability,
    expected_amount
FROM crm_opportunities
LIMIT 20;

SELECT
    COUNT(*) AS converted_leads,
    SUM(
        CASE
            WHEN converted_opportunity_id IS NULL
                 OR TRIM(converted_opportunity_id) = ''
            THEN 1
            ELSE 0
        END
    ) AS converted_without_opportunity_id,
    SUM(
        CASE
            WHEN converted_opportunity_id IS NOT NULL
                 AND TRIM(converted_opportunity_id) <> ''
            THEN 1
            ELSE 0
        END
    ) AS converted_with_opportunity_id
FROM crm_leads
WHERE converted = 1;

SELECT
    COUNT(*) AS converted_with_opportunity_id,
    COUNT(DISTINCT converted_opportunity_id) AS unique_converted_opportunities
FROM crm_leads
WHERE converted = 1
  AND converted_opportunity_id IS NOT NULL
  AND TRIM(converted_opportunity_id) <> '';

SELECT
    SUM(o.expected_amount) AS converted_expected_amount
FROM (
    SELECT DISTINCT converted_opportunity_id
    FROM crm_leads
    WHERE converted = 1
      AND converted_opportunity_id IS NOT NULL
      AND TRIM(converted_opportunity_id) <> ''
) l
INNER JOIN crm_opportunities o
    ON l.converted_opportunity_id = o.opportunity_id;
    

SELECT
    COUNT(*) AS unique_converted_opportunities,
    SUM(o.expected_amount) AS converted_expected_amount
FROM (
    SELECT DISTINCT converted_opportunity_id
    FROM crm_leads
    WHERE converted = 1
      AND converted_opportunity_id IS NOT NULL
      AND TRIM(converted_opportunity_id) <> ''
) l
INNER JOIN crm_opportunities o
    ON l.converted_opportunity_id = o.opportunity_id;
--------------------------------------------------------------------------------------------------------------  
#THE KEY TEST TO PROCEED FOR CORRECTLY CALCULATION OF THE LEAD-SIDE EXPECTED AMOUNT from the Opportunity table.
--------------------------------------------------------------------------------------------------------------
SELECT
    COUNT(*) AS converted_leads,
    COUNT(o.opportunity_id) AS matched_opportunities,
    COUNT(o.expected_amount) AS matched_expected_amounts
FROM crm_leads l
LEFT JOIN crm_opportunities o
    ON l.converted_opportunity_id = o.opportunity_id
WHERE l.converted = 1;

#Below Query tells for every converted lead that has an Opportunity ID, does that Opportunity ID actually exist in the Opportunities table
SELECT
    l.converted_opportunity_id
FROM crm_leads l
LEFT JOIN crm_opportunities o
    ON l.converted_opportunity_id = o.opportunity_id
WHERE l.converted = 1
  AND o.opportunity_id IS NULL
LIMIT 20;

#Below query tells Opportunities table complete and reliable enough to use for Expected Amount analysis
SELECT
    COUNT(*) AS total_opportunities,
    COUNT(DISTINCT opportunity_id) AS unique_opportunities,
    COUNT(expected_amount) AS opportunities_with_expected_amount
FROM crm_opportunities;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#OPPORTUNITIES KPIs VIEWS
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#View 1 - Expected Amount
CREATE OR REPLACE VIEW vw_opportunity_expected_amount_kpi AS
SELECT
    ROUND(SUM(COALESCE(expected_amount, 0)), 2) AS expected_amount
FROM crm_opportunities;
----------------
#DATA VALIDATION
----------------
SELECT *
FROM vw_opportunity_expected_amount_kpi;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#View 2 - Active Opportunities
CREATE OR REPLACE VIEW vw_opportunity_active_kpi AS
SELECT
    SUM(
        CASE
            WHEN is_active = 1 THEN 1
            ELSE 0
        END
    ) AS active_opportunities
FROM crm_opportunities;
----------------------
#DATA VALIDATION
----------------------
SELECT *
FROM vw_opportunity_active_kpi;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#View 3 - Conversion Rate
CREATE OR REPLACE VIEW vw_opportunity_conversion_rate_kpi AS
SELECT
    COUNT(DISTINCT opportunity_id) AS total_created_opportunities,

    COUNT(
        DISTINCT CASE
            WHEN is_won = 1 THEN opportunity_id
        END
    ) AS won_opportunities,

    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN is_won = 1 THEN opportunity_id
            END
        ) * 100.0
        / NULLIF(COUNT(DISTINCT opportunity_id), 0),
        2
    ) AS conversion_rate_pct

FROM crm_opportunities;
----------------------
#DATA VALIDATION
----------------------
SELECT * 
FROM vw_opportunity_conversion_rate_kpi;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#View 4 - Win Rate
CREATE OR REPLACE VIEW vw_opportunity_win_rate_kpi AS
SELECT
    COUNT(
        DISTINCT CASE
            WHEN is_won = 1 THEN opportunity_id
        END
    ) AS won_opportunities,

    COUNT(
        DISTINCT CASE
            WHEN is_lost = 1 THEN opportunity_id
        END
    ) AS lost_opportunities,

    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN is_won = 1 THEN opportunity_id
            END
        ) * 100.0
        /
        NULLIF(
            COUNT(
                DISTINCT CASE
                    WHEN is_won = 1 OR is_lost = 1
                    THEN opportunity_id
                END
            ),
            0
        ),
        2
    ) AS win_rate_pct

FROM crm_opportunities;
----------------------
#DATA VALIDATION
----------------------
SELECT * 
FROM vw_opportunity_win_rate_kpi;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#View 5 - Loss Rate
CREATE OR REPLACE VIEW vw_opportunity_loss_rate_kpi AS
SELECT
    COUNT(
        DISTINCT CASE
            WHEN is_lost = 1 THEN opportunity_id
        END
    ) AS closed_lost_opportunities,

    COUNT(DISTINCT opportunity_id) AS total_opportunities,

    ROUND(
        COUNT(
            DISTINCT CASE
                WHEN is_lost = 1 THEN opportunity_id
            END
        ) * 100.0
        / NULLIF(COUNT(DISTINCT opportunity_id), 0),
        2
    ) AS loss_rate_pct

FROM crm_opportunities;
-------------------
#DATA VALIDATION
-------------------
SELECT * 
FROM vw_opportunity_loss_rate_kpi;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#View 6 - Expected Amount by Opportunity Type
CREATE OR REPLACE VIEW vw_opportunity_expected_by_type AS
SELECT
    COALESCE(opportunity_type_display, 'Not Specified')
        AS opportunity_type,

    COUNT(DISTINCT opportunity_id)
        AS total_opportunities,

    ROUND(
        SUM(COALESCE(expected_amount, 0)),
        2
    ) AS expected_amount

FROM crm_opportunities

GROUP BY
    COALESCE(opportunity_type_display, 'Not Specified');
--------------------
#DATA VALIDATION
--------------------
SELECT *
FROM vw_opportunity_expected_by_type
ORDER BY expected_amount DESC;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#View 7 - Opportunities by Industry
CREATE OR REPLACE VIEW vw_opportunity_by_industry AS
SELECT
    COALESCE(
        opportunity_industry_standardized,
        industry,
        'Unknown'
    ) AS industry,

    COUNT(DISTINCT opportunity_id) AS total_opportunities,

    SUM(
        CASE
            WHEN is_won = 1 THEN 1
            ELSE 0
        END
    ) AS won_opportunities,

    SUM(
        CASE
            WHEN is_lost = 1 THEN 1
            ELSE 0
        END
    ) AS lost_opportunities,

    SUM(
        CASE
            WHEN is_active = 1 THEN 1
            ELSE 0
        END
    ) AS active_opportunities,

    ROUND(
        SUM(COALESCE(expected_amount, 0)),
        2
    ) AS expected_amount

FROM crm_opportunities

GROUP BY
    COALESCE(
        opportunity_industry_standardized,
        industry,
        'Unknown'
    );
------------------------
#DATA VALIDATION
------------------------
SELECT *
FROM vw_opportunity_by_industry
ORDER BY total_opportunities DESC;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#View 8 - Trend Analaysis
CREATE OR REPLACE VIEW vw_opportunity_trends AS

WITH monthly AS (
    SELECT
        created_month_year AS month,

        COUNT(DISTINCT opportunity_id)
            AS total_opportunities,

        SUM(
            CASE
                WHEN is_active = 1 THEN 1
                ELSE 0
            END
        ) AS active_opportunities,

        SUM(
            CASE
                WHEN is_won = 1 THEN 1
                ELSE 0
            END
        ) AS closed_won_opportunities,

        SUM(
            CASE
                WHEN is_closed = 1 THEN 1
                ELSE 0
            END
        ) AS total_closed_opportunities,

        SUM(COALESCE(amount, 0))
            AS total_pipeline_amount,

        SUM(COALESCE(expected_amount, 0))
            AS expected_revenue

    FROM crm_opportunities

    GROUP BY
        created_month_year
)

SELECT
    month,

    total_opportunities,
    active_opportunities,
    closed_won_opportunities,
    total_closed_opportunities,

    total_pipeline_amount,
    expected_revenue,

    SUM(expected_revenue) OVER (
        ORDER BY month
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_expected_revenue,

    SUM(total_pipeline_amount) OVER (
        ORDER BY month
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_pipeline_amount,

    SUM(active_opportunities) OVER (
        ORDER BY month
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_active_opportunities,

    SUM(total_opportunities) OVER (
        ORDER BY month
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_total_opportunities,

    SUM(closed_won_opportunities) OVER (
        ORDER BY month
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_closed_won_opportunities,

    SUM(total_closed_opportunities) OVER (
        ORDER BY month
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_total_closed

FROM monthly;
------------------
#DATA VALIDATION
------------------
SELECT *
FROM vw_opportunity_trends
ORDER BY month;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                                        #LEADS DASHBOARD VIEW
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_leads_dashboard AS
SELECT
    l.lead_id,
    l.converted,

    l.converted_account_id,
    l.converted_opportunity_id,

    l.created_date,

    l.industry,
    l.lead_source,
    l.region,
    l.status,
    l.status_simplified,

    /* Opportunity information */
    o.account_id AS opportunity_account_id,
    o.opportunity_id,
    o.opportunity_type,
    o.opportunity_type_display,
    o.stage,
    o.stage_group,

    /* Opportunity financial information */
    o.amount AS opportunity_amount,
    o.expected_amount AS opportunity_expected_amount,
    o.probability AS opportunity_probability,

    /* Opportunity status */
    o.is_active AS opportunity_is_active,
    o.is_won AS opportunity_is_won,
    o.is_lost AS opportunity_is_lost,
    o.is_closed AS opportunity_is_closed,
    o.won_revenue,

    /* Opportunity dates */
    o.close_date,
    o.created_date AS opportunity_created_date,
    o.created_year AS opportunity_created_year,
    o.created_month AS opportunity_created_month,
    o.close_year AS opportunity_close_year,

    /* Opportunity industry */
    o.opportunity_industry_standardized,

    /* Data-quality / relationship flag */
    CASE
        WHEN l.converted = 1
             AND l.converted_opportunity_id IS NOT NULL
             AND TRIM(l.converted_opportunity_id) <> ''
             AND o.opportunity_id IS NOT NULL
        THEN 'Matched Opportunity'

        WHEN l.converted = 1
             AND (
                 l.converted_opportunity_id IS NULL
                 OR TRIM(l.converted_opportunity_id) = ''
             )
        THEN 'Converted - No Opportunity ID'

        WHEN l.converted = 1
             AND o.opportunity_id IS NULL
        THEN 'Converted - Opportunity Not Found'

        ELSE 'Not Converted'
    END AS opportunity_match_status

FROM crm_leads l

LEFT JOIN crm_opportunities o
    ON l.converted_opportunity_id = o.opportunity_id;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																		  #DATA VALIDATION
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT COUNT(*) AS total_rows
FROM vw_leads_dashboard;

SELECT
    COUNT(*) AS total_leads,

    SUM(
        CASE
            WHEN converted = 1 THEN 1
            ELSE 0
        END
    ) AS converted_leads,

    SUM(
        CASE
            WHEN converted = 0 THEN 1
            ELSE 0
        END
    ) AS unconverted_leads

FROM vw_leads_dashboard;

SELECT
    opportunity_match_status,
    COUNT(*) AS lead_count
FROM vw_leads_dashboard
GROUP BY opportunity_match_status;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
																	#OPPORTUNITIES DASHBOARD VIEW
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_opportunity_dashboard AS
SELECT
    o.opportunity_id,
    o.account_id,

    /* Dates */
    o.created_date,
    o.close_date,

    o.created_date_start_of_month,
    o.close_date_start_of_month,

    o.created_year,
    o.created_month,
    o.close_year,

    o.created_month_year,
    o.created_month_label,
    o.close_month_label,

    /* Basic Opportunity information */
    o.opportunity_type,
    o.opportunity_type_display,

    o.stage,
    o.stage_group,

    o.closed_lost_reason,
    o.closed_lost_reason_display,

    /* Customer / Industry */
    o.account_name,
    o.industry,
    o.opportunity_industry_standardized,
    o.account_match_status,

    /* Owner */
    o.owner_id,

    /* Financial metrics */
    o.amount,
    o.expected_amount,
    o.probability,
    o.won_revenue,

    /* Opportunity status */
    o.closed,
    o.won,

    o.is_active,
    o.is_won,
    o.is_lost,
    o.is_closed,

    /* Deal information */
    o.deal_size_band,
    o.days_to_close,

    /* Useful dashboard flags */
    CASE
        WHEN o.is_won = 1 THEN 'Won'
        WHEN o.is_lost = 1 THEN 'Lost'
        WHEN o.is_active = 1 THEN 'Active'
        ELSE 'Other'
    END AS opportunity_status_group

FROM crm_opportunities o;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                                              #DATA VALIDATION
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT COUNT(*) AS total_rows
FROM vw_opportunity_dashboard;

SELECT
    COUNT(*) AS total_opportunities,
    COUNT(DISTINCT opportunity_id) AS unique_opportunities,
    COUNT(expected_amount) AS opportunities_with_expected_amount
FROM vw_opportunity_dashboard;

SELECT
    opportunity_status_group,
    COUNT(*) AS opportunity_count
FROM vw_opportunity_dashboard
GROUP BY opportunity_status_group
ORDER BY opportunity_count DESC;

SELECT
    ROUND(SUM(amount), 2) AS total_amount,
    ROUND(SUM(expected_amount), 2) AS total_expected_amount,
    ROUND(SUM(won_revenue), 2) AS total_won_revenue
FROM vw_opportunity_dashboard;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                                           #FINAL DATA VALIDATION
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
SELECT COUNT(*) FROM vw_leads_dashboard;

SELECT COUNT(*) FROM vw_opportunity_dashboard;

SELECT * FROM vw_lead_kpis;

SELECT * FROM vw_opportunity_expected_amount_kpi;

SELECT * FROM vw_opportunity_active_kpi;

SELECT * FROM vw_opportunity_conversion_rate_kpi;

SELECT * FROM vw_opportunity_win_rate_kpi;

SELECT * FROM vw_opportunity_loss_rate_kpi;

SELECT
    COUNT(*) AS total_opportunities,
    COUNT(created_date) AS non_blank_created_dates,
    MIN(created_date) AS first_created_date,
    MAX(created_date) AS last_created_date
FROM crm_opportunities;

SELECT
    created_year,
    created_month,
    COUNT(*) AS opportunity_count
FROM crm_opportunities
GROUP BY created_year, created_month
ORDER BY created_year, created_month;

SELECT
    created_year,
    created_month
FROM crm_opportunities
LIMIT 20;

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#CORRECTED TRENDS VIEW
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_opportunity_trends AS
WITH monthly AS (
    SELECT
        STR_TO_DATE(
            CONCAT(
                created_year,
                '-',
                LPAD(
                    MONTH(
                        STR_TO_DATE(
                            CONCAT('1 ', created_month, ' ', created_year),
                            '%e %M %Y'
                        )
                    ),
                    2,
                    '0'
                ),
                '-01'
            ),
            '%Y-%m-%d'
        ) AS month,

        COUNT(DISTINCT opportunity_id) AS total_opportunities,

        SUM(CASE WHEN is_active = 1 THEN 1 ELSE 0 END) AS active_opportunities,

        SUM(CASE WHEN is_won = 1 THEN 1 ELSE 0 END) AS closed_won_opportunities,

        SUM(CASE WHEN is_closed = 1 THEN 1 ELSE 0 END) AS total_closed_opportunities,

        SUM(COALESCE(amount, 0)) AS total_pipeline_amount,

        SUM(COALESCE(expected_amount, 0)) AS expected_revenue

    FROM crm_opportunities
    GROUP BY
        created_year,
        created_month
)

SELECT
    month,
    total_opportunities,
    active_opportunities,
    closed_won_opportunities,
    total_closed_opportunities,
    total_pipeline_amount,
    expected_revenue,

    SUM(expected_revenue) OVER (
        ORDER BY month
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_expected_revenue,

    SUM(total_pipeline_amount) OVER (
        ORDER BY month
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_pipeline_amount,

    SUM(active_opportunities) OVER (
        ORDER BY month
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_active_opportunities,

    SUM(total_opportunities) OVER (
        ORDER BY month
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_total_opportunities,

    SUM(closed_won_opportunities) OVER (
        ORDER BY month
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_closed_won_opportunities,

    SUM(total_closed_opportunities) OVER (
        ORDER BY month
        ROWS UNBOUNDED PRECEDING
    ) AS cumulative_total_closed

FROM monthly;

-------------------------
#DATA VALIDATION
-------------------------
SELECT
    COUNT(*) AS total_months,
    COUNT(month) AS non_blank_months,
    MIN(month) AS first_month,
    MAX(month) AS last_month
FROM vw_opportunity_trends;

SELECT *
FROM vw_opportunity_trends
ORDER BY month
LIMIT 20;

SELECT
    SUM(total_opportunities) AS total_opportunities,
    SUM(active_opportunities) AS active_opportunities,
    SUM(closed_won_opportunities) AS closed_won_opportunities,
    SUM(total_closed_opportunities) AS total_closed_opportunities,
    ROUND(SUM(total_pipeline_amount), 2) AS total_pipeline_amount,
    ROUND(SUM(expected_revenue), 2) AS total_expected_revenue
FROM vw_opportunity_trends;

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    DATA_TYPE,
    ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'crm_analytics'
  AND TABLE_NAME LIKE 'vw_%'
ORDER BY TABLE_NAME, ORDINAL_POSITION;

SHOW CREATE VIEW vw_leads_dashboard;

SHOW CREATE VIEW vw_opportunity_dashboard;

SHOW COLUMNS FROM crm_leads;

SHOW COLUMNS FROM crm_opportunities;

SHOW CREATE VIEW vw_opportunity_dashboard;

SHOW CREATE VIEW vw_leads_dashboard;

SELECT
    TABLE_NAME,
    LENGTH(VIEW_DEFINITION) AS definition_length
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'crm_analytics'
  AND TABLE_NAME IN (
      'vw_opportunity_dashboard',
      'vw_leads_dashboard'
  );
  
SELECT
    TABLE_NAME,
    SUBSTRING(VIEW_DEFINITION, 1, 4000) AS part_1
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'crm_analytics'
  AND TABLE_NAME IN (
      'vw_opportunity_dashboard',
      'vw_leads_dashboard'
  );
  
SELECT
    TABLE_NAME,
    SUBSTRING(VIEW_DEFINITION, 4001, 4000) AS part_2
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'crm_analytics'
  AND TABLE_NAME IN (
      'vw_opportunity_dashboard',
      'vw_leads_dashboard'
  );
  
SELECT
    TABLE_NAME,
    SUBSTRING(VIEW_DEFINITION, 8001, 4000) AS part_3
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'crm_analytics'
  AND TABLE_NAME IN (
      'vw_opportunity_dashboard',
      'vw_leads_dashboard'
  );
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                               #CONSOLIDATED VIEW FOR BI TOOLS BUILDING DASHBOARDS
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_crm_dashboard AS

/* ============================================================
   LEAD KPI 1 — TOTAL LEADS
   ============================================================ */

SELECT
    'Lead' AS kpi_group,
    'Total Lead' AS kpi_name,
    'All' AS category,
    CAST(NULL AS DATE) AS period_date,
    CAST(COUNT(*) AS DECIMAL(20,2)) AS value_1,
    CAST(NULL AS DECIMAL(20,2)) AS value_2,
    'Count' AS value_1_type,
    CAST(NULL AS CHAR(20)) AS value_2_type

FROM crm_leads


UNION ALL


/* ============================================================
   LEAD KPI 2 — EXPECTED AMOUNT FROM CONVERTED LEADS

   DISTINCT opportunity IDs prevent the same opportunity
   from being counted more than once.
   ============================================================ */

SELECT
    'Lead',
    'Expected Amount from Converted Leads',
    'All',
    CAST(NULL AS DATE),

    CAST(
        COALESCE(SUM(o.expected_amount),0)
        AS DECIMAL(20,2)
    ),

    CAST(NULL AS DECIMAL(20,2)),
    'Currency',
    NULL

FROM
(
    SELECT DISTINCT
        converted_opportunity_id
    FROM crm_leads
    WHERE converted = 1
      AND converted_opportunity_id IS NOT NULL
      AND TRIM(converted_opportunity_id) <> ''
) l

INNER JOIN crm_opportunities o
    ON l.converted_opportunity_id = o.opportunity_id


UNION ALL


/* ============================================================
   LEAD KPI 3 — CONVERSION RATE
   ============================================================ */

SELECT
    'Lead',
    'Conversion Rate',
    'All',
    CAST(NULL AS DATE),

    CAST(
        CASE
            WHEN COUNT(*) = 0 THEN 0
            ELSE
                SUM(
                    CASE
                        WHEN converted = 1 THEN 1
                        ELSE 0
                    END
                ) * 100.0 / COUNT(*)
        END
        AS DECIMAL(20,2)
    ),

    CAST(NULL AS DECIMAL(20,2)),
    'Percentage',
    NULL

FROM crm_leads


UNION ALL


/* ============================================================
   LEAD KPI 4 — CONVERTED ACCOUNTS
   ============================================================ */

SELECT
    'Lead',
    'Converted Accounts',
    'All',
    CAST(NULL AS DATE),

    CAST(
        COUNT(DISTINCT converted_account_id)
        AS DECIMAL(20,2)
    ),

    CAST(NULL AS DECIMAL(20,2)),
    'Count',
    NULL

FROM crm_leads

WHERE converted = 1
  AND converted_account_id IS NOT NULL
  AND TRIM(converted_account_id) <> ''


UNION ALL


/* ============================================================
   LEAD KPI 5 — CONVERTED OPPORTUNITIES
   ============================================================ */

SELECT
    'Lead',
    'Converted Opportunities',
    'All',
    CAST(NULL AS DATE),

    CAST(
        COUNT(DISTINCT converted_opportunity_id)
        AS DECIMAL(20,2)
    ),

    CAST(NULL AS DECIMAL(20,2)),
    'Count',
    NULL

FROM crm_leads

WHERE converted = 1
  AND converted_opportunity_id IS NOT NULL
  AND TRIM(converted_opportunity_id) <> ''


UNION ALL


/* ============================================================
   LEAD KPI 6 — LEAD BY SOURCE
   ============================================================ */

SELECT
    'Lead',
    'Lead by Source',

    COALESCE(
        NULLIF(TRIM(lead_source),''),
        'Unknown'
    ),

    CAST(NULL AS DATE),

    CAST(COUNT(*) AS DECIMAL(20,2)),

    CAST(NULL AS DECIMAL(20,2)),
    'Count',
    NULL

FROM crm_leads

GROUP BY
    COALESCE(
        NULLIF(TRIM(lead_source),''),
        'Unknown'
    )


UNION ALL


/* ============================================================
   LEAD KPI 7 — LEAD BY INDUSTRY
   ============================================================ */

SELECT
    'Lead',
    'Lead by Industry',

    COALESCE(
        NULLIF(TRIM(industry),''),
        'Unknown'
    ),

    CAST(NULL AS DATE),

    CAST(COUNT(*) AS DECIMAL(20,2)),

    CAST(NULL AS DECIMAL(20,2)),
    'Count',
    NULL

FROM crm_leads

GROUP BY
    COALESCE(
        NULLIF(TRIM(industry),''),
        'Unknown'
    )


UNION ALL


/* ============================================================
   LEAD KPI 8 — LEAD BY STAGE / STATUS
   ============================================================ */

SELECT
    'Lead' AS kpi_group,
    'Lead by Stage' AS kpi_name,

    COALESCE(
        NULLIF(TRIM(status), ''),
        'Unknown'
    ) AS category,

    CAST(NULL AS DATE) AS period_date,

    CAST(COUNT(*) AS DECIMAL(20,2)) AS value_1,

    CAST(NULL AS DECIMAL(20,2)) AS value_2,

    'Count' AS value_1_type,

    CAST(NULL AS CHAR(20)) AS value_2_type

FROM crm_leads

GROUP BY
    COALESCE(
        NULLIF(TRIM(status), ''),
        'Unknown'
    )
UNION ALL

/* ============================================================
   OPPORTUNITY KPI 1 — EXPECTED AMOUNT
   ============================================================ */

SELECT
    'Opportunity',
    'Expected Amount',
    'All',
    CAST(NULL AS DATE),

    CAST(
        COALESCE(SUM(expected_amount),0)
        AS DECIMAL(20,2)
    ),

    CAST(NULL AS DECIMAL(20,2)),
    'Currency',
    NULL

FROM crm_opportunities


UNION ALL


/* ============================================================
   OPPORTUNITY KPI 2 — ACTIVE OPPORTUNITIES
   ============================================================ */

SELECT
    'Opportunity',
    'Active Opportunities',
    'All',
    CAST(NULL AS DATE),

    CAST(
        SUM(
            CASE
                WHEN is_active = 1 THEN 1
                ELSE 0
            END
        )
        AS DECIMAL(20,2)
    ),

    CAST(NULL AS DECIMAL(20,2)),
    'Count',
    NULL

FROM crm_opportunities


UNION ALL


/* ============================================================
   OPPORTUNITY KPI 3 — CONVERSION RATE

   Won Opportunities / Total Opportunities × 100
   ============================================================ */

SELECT
    'Opportunity',
    'Conversion Rate',
    'All',
    CAST(NULL AS DATE),

    CAST(
        CASE
            WHEN COUNT(DISTINCT opportunity_id) = 0 THEN 0
            ELSE
                COUNT(
                    DISTINCT CASE
                        WHEN is_won = 1
                        THEN opportunity_id
                    END
                ) * 100.0
                /
                COUNT(DISTINCT opportunity_id)
        END
        AS DECIMAL(20,2)
    ),

    CAST(NULL AS DECIMAL(20,2)),
    'Percentage',
    NULL

FROM crm_opportunities


UNION ALL


/* ============================================================
   OPPORTUNITY KPI 4 — WIN RATE

   Won / (Won + Lost) × 100
   ============================================================ */

SELECT
    'Opportunity',
    'Win Rate',
    'All',
    CAST(NULL AS DATE),

    CAST(
        CASE
            WHEN
                SUM(
                    CASE
                        WHEN is_won = 1 OR is_lost = 1
                        THEN 1
                        ELSE 0
                    END
                ) = 0
            THEN 0
            ELSE
                SUM(
                    CASE
                        WHEN is_won = 1 THEN 1
                        ELSE 0
                    END
                ) * 100.0
                /
                SUM(
                    CASE
                        WHEN is_won = 1 OR is_lost = 1
                        THEN 1
                        ELSE 0
                    END
                )
        END
        AS DECIMAL(20,2)
    ),

    CAST(NULL AS DECIMAL(20,2)),
    'Percentage',
    NULL

FROM crm_opportunities


UNION ALL


/* ============================================================
   OPPORTUNITY KPI 5 — LOSS RATE

   Lost / Total Opportunities × 100
   ============================================================ */

SELECT
    'Opportunity',
    'Loss Rate',
    'All',
    CAST(NULL AS DATE),

    CAST(
        CASE
            WHEN COUNT(DISTINCT opportunity_id) = 0 THEN 0
            ELSE
                COUNT(
                    DISTINCT CASE
                        WHEN is_lost = 1
                        THEN opportunity_id
                    END
                ) * 100.0
                /
                COUNT(DISTINCT opportunity_id)
        END
        AS DECIMAL(20,2)
    ),

    CAST(NULL AS DECIMAL(20,2)),
    'Percentage',
    NULL

FROM crm_opportunities


UNION ALL


/* ============================================================
   OPPORTUNITY KPI 6 — EXPECTED AMOUNT BY OPPORTUNITY TYPE
   ============================================================ */

SELECT
    'Opportunity',
    'Expected Amount by Opportunity Type',

    COALESCE(
        NULLIF(TRIM(opportunity_type_display),''),
        NULLIF(TRIM(opportunity_type),''),
        'Unknown'
    ),

    CAST(NULL AS DATE),

    CAST(
        COALESCE(SUM(expected_amount),0)
        AS DECIMAL(20,2)
    ),

    CAST(NULL AS DECIMAL(20,2)),
    'Currency',
    NULL

FROM crm_opportunities

GROUP BY
    COALESCE(
        NULLIF(TRIM(opportunity_type_display),''),
        NULLIF(TRIM(opportunity_type),''),
        'Unknown'
    )


UNION ALL


/* ============================================================
   OPPORTUNITY KPI 7 — OPPORTUNITIES BY INDUSTRY

   DISTINCT opportunity_id prevents duplicate counting.
   ============================================================ */

SELECT
    'Opportunity',
    'Opportunities by Industry',

    COALESCE(
        NULLIF(TRIM(opportunity_industry_standardized),''),
        NULLIF(TRIM(industry),''),
        'Unknown'
    ),

    CAST(NULL AS DATE),

    CAST(
        COUNT(DISTINCT opportunity_id)
        AS DECIMAL(20,2)
    ),

    CAST(NULL AS DECIMAL(20,2)),
    'Count',
    NULL

FROM crm_opportunities

GROUP BY
    COALESCE(
        NULLIF(TRIM(opportunity_industry_standardized),''),
        NULLIF(TRIM(industry),''),
        'Unknown'
    )


/* ============================================================
   TREND KPI 1 — EXPECTED VS FORECAST

   Existing project trend logic is reused.

   value_1 = cumulative expected revenue
   value_2 = cumulative pipeline amount

   In this dashboard, pipeline amount represents Forecast.
   ============================================================ */

UNION ALL

SELECT
    'Opportunity',
    'Expected vs Forecast',
    'All',
    month,

    CAST(
        cumulative_expected_revenue
        AS DECIMAL(20,2)
    ),

    CAST(
        cumulative_pipeline_amount
        AS DECIMAL(20,2)
    ),

    'Currency',
    'Currency'

FROM vw_opportunity_trends

WHERE month IS NOT NULL


/* ============================================================
   TREND KPI 2 — ACTIVE VS TOTAL OPPORTUNITIES
   ============================================================ */

UNION ALL

SELECT
    'Opportunity',
    'Active vs Total Opportunities',
    'All',
    month,

    CAST(
        cumulative_active_opportunities
        AS DECIMAL(20,2)
    ),

    CAST(
        cumulative_total_opportunities
        AS DECIMAL(20,2)
    ),

    'Count',
    'Count'

FROM vw_opportunity_trends

WHERE month IS NOT NULL


/* ============================================================
   TREND KPI 3 — CLOSED WON VS TOTAL OPPORTUNITIES
   ============================================================ */

UNION ALL

SELECT
    'Opportunity',
    'Closed Won vs Total Opportunities',
    'All',
    month,

    CAST(
        cumulative_closed_won_opportunities
        AS DECIMAL(20,2)
    ),

    CAST(
        cumulative_total_opportunities
        AS DECIMAL(20,2)
    ),

    'Count',
    'Count'

FROM vw_opportunity_trends

WHERE month IS NOT NULL


/* ============================================================
   TREND KPI 4 — CLOSED WON VS TOTAL CLOSED
   ============================================================ */

UNION ALL

SELECT
    'Opportunity',
    'Closed Won vs Total Closed',
    'All',
    month,

    CAST(
        cumulative_closed_won_opportunities
        AS DECIMAL(20,2)
    ),

    CAST(
        cumulative_total_closed
        AS DECIMAL(20,2)
    ),

    'Count',
    'Count'

FROM vw_opportunity_trends

WHERE month IS NOT NULL;
---------------------------
#DATA VALIDATION
--------------------------
SELECT *
FROM vw_crm_dashboard
WHERE kpi_name = 'Expected vs Forecast'
ORDER BY period_date;

SELECT *
FROM vw_crm_dashboard
WHERE kpi_name = 'Opportunities by Industry'
ORDER BY value_1 DESC;

SELECT *
FROM vw_crm_dashboard
WHERE kpi_name = 'Expected Amount by Opportunity Type'
ORDER BY value_1 DESC;

SELECT
    kpi_group,
    kpi_name,
    COUNT(*) AS row_count
FROM vw_crm_dashboard
GROUP BY
    kpi_group,
    kpi_name
ORDER BY
    kpi_group,
    kpi_name;
    
SELECT *
FROM vw_crm_dashboard
LIMIT 100;

SELECT
    kpi_group,
    kpi_name,
    COUNT(*) AS rows_for_kpi
FROM vw_crm_dashboard
GROUP BY kpi_group, kpi_name
ORDER BY kpi_group, kpi_name;

SELECT
    kpi_name,
    category,
    period_date,
    value_1,
    value_2
FROM vw_crm_dashboard
WHERE kpi_name IN (
    'Opportunities by Industry',
    'Expected Amount by Opportunity Type',
    'Expected vs Forecast',
    'Active vs Total Opportunities',
    'Closed Won vs Total Opportunities',
    'Closed Won vs Total Closed'
)
ORDER BY kpi_name, period_date, category;

SELECT
    status,
    COUNT(*) AS total_leads
FROM crm_leads
GROUP BY status
ORDER BY total_leads DESC;

SELECT
    kpi_name,
    category,
    period_date,
    value_1,
    value_2
FROM vw_crm_dashboard
WHERE kpi_name = 'Expected vs Forecast'
ORDER BY period_date;

SELECT
    kpi_name,
    category,
    value_1
FROM vw_crm_dashboard
WHERE kpi_name = 'Opportunities by Industry'
ORDER BY value_1 DESC;

SELECT
    kpi_name,
    category,
    period_date,
    value_1,
    value_2
FROM vw_crm_dashboard
WHERE kpi_name = 'Expected vs Forecast'
ORDER BY period_date;

SELECT
    kpi_name,
    category,
    value_1
FROM vw_crm_dashboard
WHERE kpi_name = 'Opportunities by Industry'
ORDER BY value_1 DESC;

SELECT
    kpi_name,
    category,
    value_1
FROM vw_crm_dashboard
WHERE kpi_name = 'Expected Amount by Opportunity Type'
ORDER BY value_1 DESC;

SELECT
    kpi_name,
    category,
    value_1
FROM vw_crm_dashboard
WHERE kpi_name = 'Lead by Stage'
ORDER BY value_1 DESC;

SELECT *
FROM vw_crm_dashboard
LIMIT 20;

SHOW CREATE VIEW vw_crm_dashboard;

SELECT VIEW_DEFINITION
FROM information_schema.VIEWS
WHERE TABLE_SCHEMA = DATABASE()
  AND TABLE_NAME = 'vw_crm_dashboard';
  
SELECT
    kpi_group,
    kpi_name,
    category,
    period_date,
    value_1,
    value_2,
    value_1_type,
    value_2_type
FROM vw_crm_dashboard
WHERE kpi_group = 'Opportunity'
  AND kpi_name = 'Expected vs Forecast'
ORDER BY period_date;

SHOW CREATE VIEW vw_crm_dashboard;

SELECT VIEW_DEFINITION
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'crm_analytics'
  AND TABLE_NAME = 'vw_crm_dashboard';
  
SHOW CREATE VIEW vw_opportunity_trends;

SELECT VIEW_DEFINITION
FROM INFORMATION_SCHEMA.VIEWS
WHERE TABLE_SCHEMA = 'crm_analytics'
  AND TABLE_NAME = 'vw_opportunity_trends';
  
SELECT
    SUM(COALESCE(amount, 0)) AS total_pipeline_amount,
    SUM(COALESCE(amount, 0) * COALESCE(probability, 0) / 100) AS total_forecast,
    SUM(COALESCE(expected_amount, 0)) AS total_expected_amount
FROM crm_opportunities;

SELECT
    MIN(probability) AS min_probability,
    MAX(probability) AS max_probability,
    AVG(probability) AS avg_probability
FROM crm_opportunities;
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                                                         #CORRECTED VIEW FOR TABLEAU DESKTOP DASHBOARDS BUILDING
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_opportunity_trends AS

WITH monthly AS
(
    SELECT
        STR_TO_DATE(
            CONCAT(
                o.created_year,
                '-',
                LPAD(
                    MONTH(
                        STR_TO_DATE(
                            CONCAT(
                                '1 ',
                                o.created_month,
                                ' ',
                                o.created_year
                            ),
                            '%e %M %Y'
                        )
                    ),
                    2,
                    '0'
                ),
                '-01'
            ),
            '%Y-%m-%d'
        ) AS month,

        COUNT(DISTINCT o.opportunity_id) AS total_opportunities,

        SUM(
            CASE
                WHEN o.is_active = 1 THEN 1
                ELSE 0
            END
        ) AS active_opportunities,

        SUM(
            CASE
                WHEN o.is_won = 1 THEN 1
                ELSE 0
            END
        ) AS closed_won_opportunities,

        SUM(
            CASE
                WHEN o.is_closed = 1 THEN 1
                ELSE 0
            END
        ) AS total_closed_opportunities,

        SUM(
            COALESCE(o.amount, 0)
        ) AS total_pipeline_amount,

        SUM(
            COALESCE(o.expected_amount, 0)
        ) AS expected_revenue,

        SUM(
            COALESCE(o.amount, 0)
            * COALESCE(o.probability, 0)
            / 100
        ) AS forecast_amount

    FROM crm_opportunities o

    GROUP BY
        o.created_year,
        o.created_month
)

SELECT
    month,
    total_opportunities,
    active_opportunities,
    closed_won_opportunities,
    total_closed_opportunities,
    total_pipeline_amount,
    expected_revenue,
    forecast_amount,

    SUM(expected_revenue) OVER (
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_expected_revenue,

    SUM(forecast_amount) OVER (
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_forecast,

    SUM(active_opportunities) OVER (
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_active_opportunities,

    SUM(total_opportunities) OVER (
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_total_opportunities,

    SUM(closed_won_opportunities) OVER (
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_closed_won_opportunities,

    SUM(total_closed_opportunities) OVER (
        ORDER BY month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_total_closed

FROM monthly;
----------------
#DATA VALIDATION
----------------
SELECT
    month,
    cumulative_expected_revenue,
    cumulative_forecast
FROM vw_opportunity_trends
ORDER BY month;

SELECT
    MAX(cumulative_expected_revenue) AS final_expected,
    MAX(cumulative_forecast) AS final_forecast
FROM vw_opportunity_trends;

SHOW CREATE VIEW vw_crm_dashboard;

SELECT
    month,
    cumulative_expected_revenue,
    cumulative_forecast
FROM vw_opportunity_trends
ORDER BY month;

SELECT *
FROM vw_crm_dashboard;

SELECT
    kpi_group,
    kpi_name,
    COUNT(*) AS row_count
FROM vw_crm_dashboard
GROUP BY
    kpi_group,
    kpi_name
ORDER BY
    kpi_group,
    kpi_name;

SELECT
    SUM(converted_opportunity_expected_amount) AS total_expected_amount
FROM crm_leads
WHERE is_converted = 1;

SELECT
    period_date,
    category,
    value_1,
    value_2,
    value_1_type,
    value_2_type
FROM vw_crm_dashboard
WHERE kpi_group = 'Opportunity'
  AND kpi_name = 'Expected vs Forecast'
ORDER BY period_date;

SELECT
    created_month_year AS period_date,
    SUM(expected_amount) AS expected_amount,
    SUM(amount * probability / 100) AS forecast_amount
FROM crm_opportunities
GROUP BY created_month_year
ORDER BY created_month_year;

SELECT
    COUNT(*) AS total_opportunities,
    COUNT(created_date) AS valid_created_dates,
    COUNT(created_month_year) AS valid_created_month_year,
    MIN(created_date) AS earliest_created_date,
    MAX(created_date) AS latest_created_date,
    MIN(created_month_year) AS earliest_month_year,
    MAX(created_month_year) AS latest_month_year
FROM crm_opportunities;

SELECT
    close_date,
    created_date,
    created_month_year,
    COUNT(*) AS cnt
FROM crm_opportunities
GROUP BY close_date, created_date, created_month_year
ORDER BY cnt DESC
LIMIT 20;

SHOW CREATE VIEW vw_opportunity_trends;