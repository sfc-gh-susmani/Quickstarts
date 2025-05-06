/*----------------------------------------------------------------------------------
Object Tagging

In this script, we will create new tags, setting allowed values. We will leverage 
out of the box auto-classification and system tags using the UI. Finally, we will 
explore where tags have been applied using the built-in Governance dashboard.
----------------------------------------------------------------------------------*/

-- Set context
use role sysadmin;
use database aerofleet;
use schema raw_customer;
use warehouse compute;

-- Create tags
create or replace tag cost_center
    allowed_values 'FINANCE', 'ENGINEERING', 'HR';

alter tag cost_center
    add allowed_values 'SALES';

create or replace tag visibility allowed_values 'PUBLIC', 'PRIVATE';

-- Helpful functions
show tags in account;
select get_ddl('tag', 'cost_center');
select system$get_tag_allowed_values('aerofleet.raw_customer.cost_center');

-- Apply tag at schema level (can use UI or SQL)
-- alter schema raw_customer set tag cost_center = 'SALES';
-- alter warehouse compute set tag cost_center = 'SALES';

-- Apply tag at column level (can use UI or SQL)
-- alter table customer_loyalty modify column 
--     first_name set tag visibility = 'PRIVATE',
--     last_name set tag visibility = 'PRIVATE',
--     e_mail set tag visibility = 'PRIVATE',
--     phone_number set tag visibility = 'PRIVATE';