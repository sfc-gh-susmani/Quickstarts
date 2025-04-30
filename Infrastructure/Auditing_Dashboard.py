# === Imports ===
import streamlit as st
from snowflake.snowpark.context import get_active_session
import pandas as pd
import plotly.express as px
import altair as alt
from datetime import datetime, timedelta

# === Page Configuration ===
st.set_page_config(page_title="Snowflake Monitor", layout="wide")

# === Active Snowflake Session ===
session = get_active_session()

# === Helper: Create Altair Heatmap ===
def create_activity_heatmap(df, var='NAME', metric='CREDITS_USED'):
    df['HOUR'] = df['START_TIME'].dt.hour
    df['HOUR_DISPLAY'] = df['HOUR'].apply(lambda x: f'{x:02d}:00')
    agg_df = df.groupby([var, 'HOUR_DISPLAY'])[metric].sum().reset_index()

    heatmap = alt.Chart(agg_df).mark_rect(stroke='black', strokeWidth=1).encode(
        x='HOUR_DISPLAY:O',
        y=alt.Y(f'{var}:N', title='', axis=alt.Axis(labelLimit=250, labelPadding=10)),
        color=alt.Color(f'{metric}:Q', scale=alt.Scale(scheme='viridis'),
                        legend=alt.Legend(title=metric.replace("_", " ").title())),
        tooltip=['HOUR_DISPLAY', var, metric]
    ).properties(
        title=f'Hourly Credit Usage Heatmap by {var}'
    )
    return heatmap

# === Main App ===
def main():
    st.title("Snowflake Account Monitoring Dashboard")

    # === Sidebar Filters ===
    st.sidebar.header("Filters")
    date_range = st.sidebar.selectbox(
        "Select Time Range", ["Last 24 Hours", "Last 7 Days", "Last 30 Days", "Last 90 Days"]
    )
    end_date = datetime.now()
    delta_days = {"Last 24 Hours": 1, "Last 7 Days": 7, "Last 30 Days": 30, "Last 90 Days": 90}
    start_date = end_date - timedelta(days=delta_days[date_range])

    # === Tabs ===
    tab1, tab2, tab3, tab4, tab5 = st.tabs([
        "Warehouse Usage", "Credit Usage", "Storage Usage",
        "Query Performance", "Access History"
    ])

    # === Tab 1: Warehouse Usage ===
    with tab1:
        st.header("Warehouse Credit Usage (Hourly)")
        warehouse_query = f"""
        SELECT
            START_TIME,
            NAME,
            SUM(CREDITS_USED) AS CREDITS_USED
        FROM SNOWFLAKE.ACCOUNT_USAGE.METERING_HISTORY
        WHERE START_TIME BETWEEN '{start_date}' AND '{end_date}'
        GROUP BY START_TIME, NAME
        ORDER BY START_TIME, NAME
        """
        warehouse_df = session.sql(warehouse_query).to_pandas()

        # Summary bar chart
        usage_by_warehouse = warehouse_df.groupby("NAME")["CREDITS_USED"].sum().reset_index()
        st.plotly_chart(px.bar(usage_by_warehouse, x='NAME', y='CREDITS_USED', title="Total Credits Used by Warehouse"))

        # === Heatmap ===
        st.subheader("Hourly Usage Heatmap")
        heatmap = create_activity_heatmap(warehouse_df)
        st.altair_chart(heatmap, use_container_width=True)

    # === Tab 2: Credit Usage ===
    with tab2:
        st.header("Credit Usage Trends")
        credit_df = warehouse_df.groupby(pd.Grouper(key='START_TIME', freq='D'))[['CREDITS_USED']].sum().reset_index()
        st.plotly_chart(px.line(credit_df, x='START_TIME', y='CREDITS_USED', title='Daily Credit Usage Trend'))

    # === Tab 3: Storage Usage ===
    with tab3:
        st.header("Storage Usage")
        storage_query = """
        SELECT 
            USAGE_DATE,
            STORAGE_BYTES/POWER(1024, 4) AS STORAGE_TB,
            STAGE_BYTES/POWER(1024, 4) AS STAGE_TB,
            FAILSAFE_BYTES/POWER(1024, 4) AS FAILSAFE_TB
        FROM SNOWFLAKE.ACCOUNT_USAGE.STORAGE_USAGE
        ORDER BY USAGE_DATE DESC
        LIMIT 30
        """
        storage_df = session.sql(storage_query).to_pandas()
        st.plotly_chart(px.area(storage_df, x='USAGE_DATE',
                                y=['STORAGE_TB', 'STAGE_TB', 'FAILSAFE_TB'],
                                title='Storage Usage Trend'))

    # === Tab 4: Query Performance ===
    with tab4:
        st.header("Query Performance Analysis")
        perf_query = f"""
        SELECT 
            WAREHOUSE_NAME, QUERY_TYPE,
            AVG(TOTAL_ELAPSED_TIME)/1000 AS AVG_EXECUTION_TIME_SECONDS,
            COUNT(*) AS QUERY_COUNT
        FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
        WHERE START_TIME BETWEEN '{start_date}' AND '{end_date}'
        GROUP BY WAREHOUSE_NAME, QUERY_TYPE
        HAVING COUNT(*) > 10
        ORDER BY AVG_EXECUTION_TIME_SECONDS DESC
        """
        perf_df = session.sql(perf_query).to_pandas()
        st.dataframe(perf_df)

    # === Tab 5: Access History ===
    with tab5:
        st.header("User Access History")
        access_query = f"""
        SELECT 
            USER_NAME, EVENT_TIMESTAMP, EVENT_TYPE,
            CLIENT_IP, REPORTED_CLIENT_TYPE
        FROM SNOWFLAKE.ACCOUNT_USAGE.LOGIN_HISTORY
        WHERE EVENT_TIMESTAMP BETWEEN '{start_date}' AND '{end_date}'
        ORDER BY EVENT_TIMESTAMP DESC
        LIMIT 1000
        """
        access_df = session.sql(access_query).to_pandas()
        st.dataframe(access_df)

    # === Footer Summary ===
    st.markdown("---")
    col1, col2 = st.columns(2)
    col1.metric("Total Credits Used", f"{warehouse_df['CREDITS_USED'].sum():.2f}")
    col2.metric("Active Warehouses", len(warehouse_df['NAME'].unique()))

# === Entrypoint ===
if __name__ == "__main__":
    main()
