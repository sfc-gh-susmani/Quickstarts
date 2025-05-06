/*----------------------------------------------------------------------------------
Data Quality

In this script, we will leverage system data metric functions (DMFs) and create custom
DMFs. We will attach a schedule to a table and attach the various DMFs to columns.
Lastly, we will monitor the event table for any data quality issues.
----------------------------------------------------------------------------------*/

-- Set context
use role accountadmin;
use database aerofleet;
use schema raw_customer;
use warehouse compute;

-- Grants to object owner to be able to execute the DMFs on the account
grant EXECUTE DATA METRIC FUNCTION on account to role sysadmin;


-- Change role to sysadmin
use role sysadmin;


-- Let's look at statistics on table using Snowsight UI
select * from customer_loyalty;


-- View available data metrics. See system DMFs here:
-- https://docs.snowflake.com/en/user-guide/data-quality-system-dmfs
show data metric functions;
show data metric functions in account;


-- Use System DMFs to check for nulls/duplicates
select snowflake.core.duplicate_count(
    select customer_id from customer_loyalty
);
select snowflake.core.null_count(
    select first_name from customer_loyalty
);


-- View rows from DMF scans
SELECT *
  FROM TABLE(SYSTEM$DATA_METRIC_SCAN(
    REF_ENTITY_NAME  => 'customer_loyalty',
    METRIC_NAME  => 'snowflake.core.null_count',
    ARGUMENT_NAME => 'first_name'
   ));



-- Set a schedule on the table. See scheduling options here:
-- https://docs.snowflake.com/en/sql-reference/sql/alter-table#data-metric-function-actions-datametricfunctionaction
alter table customer_loyalty set data_metric_schedule = '60 MINUTE';
alter table customer_loyalty set data_metric_schedule = 'USING CRON 0 6,12,18 * * MON,TUE,WED,THU,FRI UTC';
alter table customer_loyalty set data_metric_schedule = 'TRIGGER_ON_CHANGES';


-- Set DMFs on the table
alter table customer_loyalty add data metric function snowflake.core.duplicate_count on (customer_id);
alter table customer_loyalty add data metric function snowflake.core.null_count on (first_name);
alter table customer_loyalty add data metric function snowflake.core.null_count on (last_name);
alter table customer_loyalty add data metric function snowflake.core.null_count on (e_mail);
alter table customer_loyalty add data metric function snowflake.core.null_count on (phone_number);


-- Create custom DMF. See more about custom DMFs here:
-- https://docs.snowflake.com/en/user-guide/data-quality-custom-dmfs
CREATE DATA METRIC FUNCTION IF NOT EXISTS
  invalid_email_count (ARG_T table(ARG_C1 STRING))
  RETURNS NUMBER AS
  'SELECT COUNT_IF(FALSE = (
    ARG_C1 REGEXP ''^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$''))
    FROM ARG_T';

    
-- Set DMF on e_mail column
alter table customer_loyalty add data metric function invalid_email_count on (e_mail);


-- See all DMFs set on table
SELECT * FROM TABLE(INFORMATION_SCHEMA.DATA_METRIC_FUNCTION_REFERENCES(
  REF_ENTITY_NAME => 'CUSTOMER_LOYALTY',
  REF_ENTITY_DOMAIN => 'TABLE'));


-- Unset DMF from the table
alter table customer_loyalty drop data metric function snowflake.core.null_count on (phone_number);


-- Insert data into the table to trigger the DMF scan (if set to run on trigger)
INSERT INTO CUSTOMER_LOYALTY (CUSTOMER_ID, FIRST_NAME, LAST_NAME, E_MAIL, PHONE_NUMBER)
VALUES (1, NULL, NULL, 'This should fail DMF@example.com', NULL);


-- Query the event table
select * from snowflake.local.data_quality_monitoring_results_raw
order by timestamp desc;


-- View serverless credit consumption
-- Note that this view has a latency of 1-2 hours, so wait for the time to pass before querying
SELECT *
FROM SNOWFLAKE.ACCOUNT_USAGE.DATA_QUALITY_MONITORING_USAGE_HISTORY
WHERE TRUE
AND START_TIME >= CURRENT_TIMESTAMP - INTERVAL '3 days'
LIMIT 100;