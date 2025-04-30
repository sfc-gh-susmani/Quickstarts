
-- privilege grants
USE ROLE accountadmin;

GRANT IMPORTED PRIVILEGES ON DATABASE snowflake TO ROLE data_engineer;

USE ROLE securityadmin;

GRANT USAGE ON DATABASE AeroFleet TO ROLE accountadmin;
GRANT USAGE ON DATABASE AeroFleet TO ROLE data_engineer;
GRANT USAGE ON DATABASE AeroFleet TO ROLE developer;
GRANT USAGE ON DATABASE AeroFleet TO ROLE sc;

GRANT USAGE ON ALL SCHEMAS IN DATABASE AeroFleet TO ROLE accountadmin;
GRANT USAGE ON ALL SCHEMAS IN DATABASE AeroFleet TO ROLE data_engineer;
GRANT USAGE ON ALL SCHEMAS IN DATABASE AeroFleet TO ROLE developer;
GRANT USAGE ON ALL SCHEMAS IN DATABASE AeroFleet TO ROLE data_scientist;

GRANT ALL ON SCHEMA AeroFleet.raw_pos TO ROLE accountadmin;
GRANT ALL ON SCHEMA AeroFleet.raw_pos TO ROLE data_engineer;
GRANT ALL ON SCHEMA AeroFleet.raw_pos TO ROLE developer;
GRANT ALL ON SCHEMA AeroFleet.raw_pos TO ROLE data_scientist;

GRANT ALL ON SCHEMA AeroFleet.harmonized TO ROLE accountadmin;
GRANT ALL ON SCHEMA AeroFleet.harmonized TO ROLE data_engineer;
GRANT ALL ON SCHEMA AeroFleet.harmonized TO ROLE developer;
GRANT ALL ON SCHEMA AeroFleet.harmonized TO ROLE data_scientist;


GRANT ALL ON SCHEMA AeroFleet.analytics TO ROLE accountadmin;
GRANT ALL ON SCHEMA AeroFleet.analytics TO ROLE data_engineer;
GRANT ALL ON SCHEMA AeroFleet.analytics TO ROLE developer;
GRANT ALL ON SCHEMA AeroFleet.analytics TO ROLE data_scientist;


-- warehouse grants
GRANT OWNERSHIP ON WAREHOUSE de_wh TO ROLE accountadmin COPY CURRENT GRANTS;
GRANT ALL ON WAREHOUSE de_wh TO ROLE accountadmin;
GRANT USAGE ON WAREHOUSE de_wh TO ROLE data_engineer;

GRANT ALL ON WAREHOUSE dev_wh TO ROLE accountadmin;
GRANT USAGE ON WAREHOUSE dev_wh TO ROLE data_engineer;
GRANT USAGE ON WAREHOUSE dev_wh TO ROLE developer;

GRANT ALL ON WAREHOUSE ds_wh TO ROLE accountadmin;
GRANT USAGE ON WAREHOUSE ds_wh TO ROLE data_scientist;

-- future grants
GRANT ALL ON FUTURE TABLES IN SCHEMA AeroFleet.raw_pos TO ROLE accountadmin;
GRANT ALL ON FUTURE TABLES IN SCHEMA AeroFleet.raw_pos TO ROLE data_engineer;
GRANT ALL ON FUTURE TABLES IN SCHEMA AeroFleet.raw_pos TO ROLE developer;
GRANT ALL ON FUTURE TABLES IN SCHEMA AeroFleet.raw_pos TO ROLE data_scientist;

GRANT ALL ON FUTURE TABLES IN SCHEMA AeroFleet.raw_customer TO ROLE accountadmin;
GRANT ALL ON FUTURE TABLES IN SCHEMA AeroFleet.raw_customer TO ROLE data_engineer;
GRANT ALL ON FUTURE TABLES IN SCHEMA AeroFleet.raw_customer TO ROLE developer;
GRANT ALL ON FUTURE TABLES IN SCHEMA AeroFleet.raw_customer TO ROLE data_scientist;


GRANT ALL ON FUTURE VIEWS IN SCHEMA AeroFleet.harmonized TO ROLE admin;
GRANT ALL ON FUTURE VIEWS IN SCHEMA AeroFleet.harmonized TO ROLE data_engineer;
GRANT ALL ON FUTURE VIEWS IN SCHEMA AeroFleet.harmonized TO ROLE developer;
GRANT ALL ON FUTURE VIEWS IN SCHEMA AeroFleet.harmonized TO ROLE data_scientist;


GRANT ALL ON FUTURE VIEWS IN SCHEMA AeroFleet.analytics TO ROLE admin;
GRANT ALL ON FUTURE VIEWS IN SCHEMA AeroFleet.analytics TO ROLE data_engineer;
GRANT ALL ON FUTURE VIEWS IN SCHEMA AeroFleet.analytics TO ROLE developer;
GRANT ALL ON FUTURE VIEWS IN SCHEMA AeroFleet.analytics TO ROLE data_scientist;


-- Apply Masking Policy Grants
USE ROLE accountadmin;
GRANT CREATE MASKING POLICY ON ACCOUNT TO ROLE admin;
GRANT APPLY MASKING POLICY ON ACCOUNT TO ROLE admin;
GRANT APPLY MASKING POLICY ON ACCOUNT TO ROLE data_engineer;

--Apply Row Level Policy Grants
USE ROLE accountadmin;
GRANT CREATE ROW ACCESS POLICY ON ACCOUNT TO ROLE admin;
GRANT APPLY ROW ACCESS POLICY ON ACCOUNT TO ROLE admin;
GRANT APPLY ROW ACCESS POLICY ON ACCOUNT TO ROLE data_engineer;
  
