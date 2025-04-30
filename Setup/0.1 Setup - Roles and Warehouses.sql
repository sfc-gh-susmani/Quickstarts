/***************************************************************************************************
Quickstart:   Tasty Bytes - Zero to Snowflake - Introduction
Version:      v2     
Author:       Jacob Kranzler
Copyright(c): 2024 Snowflake Inc. All rights reserved.
****************************************************************************************************
SUMMARY OF CHANGES
Date(yyyy-mm-dd)    Author              Comments
------------------- ------------------- ------------------------------------------------------------
2024-05-23          Jacob Kranzler      Initial Release
***************************************************************************************************/

USE ROLE accountadmin;
GRANT ROLE orgadmin to user <username>;


USE ROLE sysadmin;

-- assign Query Tag to Session 
ALTER SESSION SET query_tag = '{"origin":"sf_sit-is","name":"zts","version":{"major":1, "minor":1},"attributes":{"is_quickstart":1, "source":"sql", "vignette": "intro"}}';

/*--
 • database, schema and warehouse creation
--*/

-- create AeroFleet database
CREATE OR REPLACE DATABASE AeroFleet;

-- create raw_pos schema
CREATE OR REPLACE SCHEMA AeroFleet.raw_pos;

-- create raw_customer schema
CREATE OR REPLACE SCHEMA AeroFleet.raw_customer;

-- create harmonized schema
CREATE OR REPLACE SCHEMA AeroFleet.harmonized;

-- create analytics schema
CREATE OR REPLACE SCHEMA AeroFleet.analytics;

-- create warehouses
CREATE OR REPLACE WAREHOUSE de_wh
    WAREHOUSE_SIZE = 'large' -- Large for initial data load - scaled down to XSmall at end of this scripts
    WAREHOUSE_TYPE = 'standard'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
COMMENT = 'data engineering warehouse for tasty bytes';

CREATE OR REPLACE WAREHOUSE dev_wh
    WAREHOUSE_SIZE = 'xsmall'
    WAREHOUSE_TYPE = 'standard'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
COMMENT = 'developer warehouse for tasty bytes';

CREATE OR REPLACE WAREHOUSE ds_wh
    WAREHOUSE_SIZE = 'medium'
    WAREHOUSE_TYPE = 'standard'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE
COMMENT = 'data science warehouse for tasty bytes';

use role accountadmin;

--Create Resource Monitors on Warehouse
CREATE OR REPLACE RESOURCE MONITOR de_rm
WITH
    CREDIT_QUOTA = 100 -- set the quota to 100 credits
    FREQUENCY = monthly -- reset the monitor monthly
    START_TIMESTAMP = immediately -- begin tracking immediately
    TRIGGERS
        ON 75 PERCENT DO NOTIFY -- notify accountadmins at 75%
        ON 100 PERCENT DO SUSPEND -- suspend warehouse at 100 percent, let queries finish
        ON 110 PERCENT DO SUSPEND_IMMEDIATE; -- suspend warehouse and cancel all queries at 110 percent

CREATE OR REPLACE RESOURCE MONITOR dev_rm
WITH
    CREDIT_QUOTA = 50 -- set the quota to 100 credits
    FREQUENCY = monthly -- reset the monitor monthly
    START_TIMESTAMP = immediately -- begin tracking immediately
    TRIGGERS
        ON 75 PERCENT DO NOTIFY -- notify accountadmins at 75%
        ON 100 PERCENT DO SUSPEND -- suspend warehouse at 100 percent, let queries finish
        ON 110 PERCENT DO SUSPEND_IMMEDIATE; -- suspend warehouse and cancel all queries at 110 percent

CREATE OR REPLACE RESOURCE MONITOR ds_rm
WITH
    CREDIT_QUOTA = 100 -- set the quota to 100 credits
    FREQUENCY = monthly -- reset the monitor monthly
    START_TIMESTAMP = immediately -- begin tracking immediately
    TRIGGERS
        ON 75 PERCENT DO NOTIFY -- notify accountadmins at 75%
        ON 100 PERCENT DO SUSPEND -- suspend warehouse at 100 percent, let queries finish
        ON 110 PERCENT DO SUSPEND_IMMEDIATE; -- suspend warehouse and cancel all queries at 110 percent

ALTER WAREHOUSE de_wh SET RESOURCE_MONITOR = de_rm;
ALTER WAREHOUSE dev_wh SET RESOURCE_MONITOR = dev_rm;
ALTER WAREHOUSE ds_wh SET RESOURCE_MONITOR = ds_rm;



-- create roles
USE ROLE securityadmin;
    
CREATE ROLE IF NOT EXISTS data_engineer
    COMMENT = 'data engineer for truck analytics';
    
CREATE ROLE IF NOT EXISTS developer
    COMMENT = 'developer for truck analytics';

CREATE ROLE IF NOT EXISTS data_scientist
    COMMENT = 'data scientist for truck analytics';
    
-- role hierarchy

GRANT ROLE data_engineer TO ROLE sysadmin;
GRANT ROLE data_scientist TO ROLE sysadmin;
GRANT ROLE developer TO ROLE data_engineer;