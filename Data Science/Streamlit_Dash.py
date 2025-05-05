import streamlit as st
from snowflake.snowpark.context import get_active_session
import pandas as pd

# Set page config
st.set_page_config(page_title="Shift Sales Dashboard", layout="wide")

# Get Snowflake session
session = get_active_session()

# Load data
snowpark_df = session.table("aerofleet.analytics.shift_sales_v")
df = snowpark_df.to_pandas()
df["DATE"] = pd.to_datetime(df["DATE"])

# Sidebar filters
st.sidebar.header("Filters")

# Date range
min_date, max_date = df["DATE"].min(), df["DATE"].max()
date_range = st.sidebar.date_input("Select Date Range", [min_date, max_date], min_value=min_date, max_value=max_date)

# City filter
cities = df["CITY"].unique()
selected_cities = st.sidebar.multiselect("Select Cities", options=cities, default=list(cities))

# Filtered data
filtered_df = df[
    (df["DATE"] >= pd.to_datetime(date_range[0])) &
    (df["DATE"] <= pd.to_datetime(date_range[1])) &
    (df["CITY"].isin(selected_cities))
]

st.title("Aerofleet Shift Sales Dashboard")

# Sales Over Time
st.subheader("Total Sales Over Time")
sales_over_time = filtered_df.groupby("DATE")["SHIFT_SALES"].sum()
st.line_chart(sales_over_time)

# Sales by Shift
st.subheader("Total Sales by Shift")
shift_summary = filtered_df.groupby("SHIFT")["SHIFT_SALES"].sum()
st.bar_chart(shift_summary)

# Sales vs. City Population
st.subheader("Sales vs. City Population")
city_summary = filtered_df.groupby(["CITY", "CITY_POPULATION"])["SHIFT_SALES"].sum().reset_index()
city_summary = city_summary.set_index("CITY_POPULATION")
st.scatter_chart(city_summary[["SHIFT_SALES"]])

# Optional: Top Cities
st.subheader("Top Cities by Sales")
top_cities = filtered_df.groupby("CITY")["SHIFT_SALES"].sum().sort_values(ascending=False).head(10)
st.bar_chart(top_cities)

# Footer
st.markdown("---")
st.caption("Data Source: aerofleet.analytics.shift_sales_v | Streamlit Dashboard")
