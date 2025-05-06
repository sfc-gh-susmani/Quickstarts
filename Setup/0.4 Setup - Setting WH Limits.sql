use role accountadmin;

-- create home for the stp
create database procs;
create schema procs;
grant usage on database procs to role data_engineer;
grant usage on schema procs to role data_engineer;
use schema procs.procs;


-- create stored procedure with owner's rights (wh_admin's rights, ie modify privilege)
-- this STP allows wh_user to scale the warehouse between XS and Medium
create or replace procedure change_maxedWH(P_WH_NM varchar, P_WH_SIZE varchar)
    returns string
    language javascript
    execute as owner
    AS
$$
  var result = "";
  var sqlCmd = "";
  var sqlStmt = "";
  var rs = "";
  var curSize = "";
  var whSizesAllowed = ["X-SMALL", "XSMALL", "SMALL", "MEDIUM", "LARGE", "XLARGE", "X-LARGE"];

  try {
    // first validate the warehouse exists and get the current size
    sqlCmd = "SHOW WAREHOUSES LIKE '" + P_WH_NM + "'";
    sqlStmt = snowflake.createStatement( {sqlText: sqlCmd} );
    rs = sqlStmt.execute();

    if (sqlStmt.getRowCount() == 0) {
      throw new Error('No Warehouse Found by that name');
    } else {
      rs.next();
      curSize = rs.getColumnValue('size').toUpperCase();
    }

    // next validate the new size is in the acceptable range
    if (whSizesAllowed.indexOf(P_WH_SIZE.toUpperCase()) == -1) {
      throw new Error('Not a valid warehouse size');
    };

    // set Warehouse size
    sqlCmd = "ALTER WAREHOUSE " + P_WH_NM + " SET WAREHOUSE_SIZE = :1";
    sqlStmt = snowflake.createStatement( {sqlText: sqlCmd, binds: [P_WH_SIZE]} );
    sqlStmt.execute();

    result = "Resized warehouse " + P_WH_NM + " from " + curSize + " to " + P_WH_SIZE.toUpperCase();
  }
  catch (err) {
    if (err.code === undefined) {
      result = err.message
    } else {
      result =  "Failed: Code: " + err.code + " | State: " + err.state;
      result += "\n  Message: " + err.message;
      result += "\nStack Trace:\n" + err.stackTraceTxt;
      result += "\nParam:\n" + P_WH_NM + ", " + P_WH_SIZE;
    }
  }
  return result;
$$;

-- allow wh_user to call the STP
grant usage on procedure change_maxedWH(varchar, varchar) to role data_engineer;

-- switch to  role
use role data_engineer;
-- try to modify the warehouse traditional way; not allowed

--This is what they need to call. 
call procs.procs.change_maxedWH('MAXEDWH', 'MEDIUM');


