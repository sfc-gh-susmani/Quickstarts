-- Snowflake Data Engineering Demo SQL Worksheet

-- =========================================
-- 1. Setting Up the Environment
-- =========================================
-- Using the appropriate role and warehouse for this demo.
USE ROLE data_engineer;
USE WAREHOUSE de_wh;

-- =========================================
-- 2. Creating the Silver Layer with Dynamic Tables
-- =========================================
-- Dynamic Tables allow for continuous transformation without complex scheduling.
alter warehouse de_wh set warehouse_size = 'XLarge';
CREATE OR REPLACE DYNAMIC TABLE AEROFLEET.HARMONIZED.ORDERS_DT_<name>
TARGET_LAG = 'DOWNSTREAM'
WAREHOUSE = 'DE_WH'
AS 
SELECT 
    oh.order_id,
    oh.truck_id,
    oh.order_ts,
    od.order_detail_id,
    od.line_number,
    od.menu_item_id,
    od.quantity,
    od.unit_price,
    od.price,
    oh.order_amount,
    oh.order_tax_amount,
    oh.order_discount_amount,
    oh.order_total,
    oh.location_id,
    oh.customer_id
FROM AEROFLEET.raw_pos.order_detail od
JOIN AEROFLEET.raw_pos.order_header oh
    ON od.order_id = oh.order_id;
    
    -- =========================================
-- 3. Enriching the Data – Gold Layer
-- =========================================
-- Bringing in additional dimensional data without manual pipeline management.
CREATE OR REPLACE DYNAMIC TABLE AEROFLEET.HARMONIZED.ORDERS_ENRICHED_DT_<name>
TARGET_LAG = '10 minutes'
WAREHOUSE = 'DE_WH'
AS 
SELECT 
    s.*,
    m.truck_brand_name,
    m.menu_type,
    m.menu_item_name,
    t.primary_city,
    t.region,
    t.country,
    t.franchise_flag,
    t.franchise_id,
    f.first_name AS franchisee_first_name,
    f.last_name AS franchisee_last_name,
    cl.first_name,
    cl.last_name,
    cl.e_mail,
    cl.phone_number,
    cl.children_count,
    cl.gender,
    cl.marital_status
FROM AEROFLEET.HARMONIZED.ORDERS_DT_<name> s
JOIN AEROFLEET.raw_pos.truck t 
    ON s.truck_id = t.truck_id
JOIN AEROFLEET.raw_pos.menu m 
    ON s.menu_item_id = m.menu_item_id
JOIN AEROFLEET.raw_pos.franchise f 
    ON t.franchise_id = f.franchise_id
LEFT JOIN AEROFLEET.raw_customer.customer_loyalty cl
    ON s.customer_id = cl.customer_id;

alter warehouse de_wh set warehouse_size = 'XSmall';
ALTER WAREHOUSE de_wh SUSPEND;
ALTER DYNAMIC TABLE AEROFLEET.HARMONIZED.ORDERS_DT_<name> SUSPEND;

-- =========================================
-- 4. Zero-Copy Cloning
-- =========================================
-- Instantly create a copy of a table without consuming extra storage.

CREATE OR REPLACE DYNAMIC TABLE AEROFLEET.RAW_CUSTOMER.CUSTOMER_LOYALTY_DEV_<name>
CLONE AEROFLEET.HARMONIZED.ORDERS_ENRICHED_DT_$uid;