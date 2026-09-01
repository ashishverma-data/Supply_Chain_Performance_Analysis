# Supply Chain Performance Analysis 🚚

## Project Overview

This project analyzes supply chain performance using an end-to-end data analytics workflow.

**Workflow:** Excel → Power Query → Power BI → MySQL

**Objective:** Analyze sales, profitability, customers, products, logistics, departments, regions and year-over-year performance to support data-driven business and operational decisions.

**Dataset:** 180,519 order-item records covering 01 Jan 2015 to 31 Jan 2018.

---

## Tools Used

- Excel
- Power Query
- Power BI
- MySQL
- SQL

---

## Project Workflow

### Data Preparation

Performed using Excel Power Query:

- Data type transformation
- Text standardization
- Column cleanup
- Duplicate removal
- Shipping delay calculation
- Profit classification
- Discount range classification
- Customer name standardization
- Data quality validation

**Final Dataset:** 180,519 rows × 43 columns

### Data Modeling & Dashboard

Power BI was used for dimensional data modeling, DAX measures and interactive dashboard development.

The dashboard contains **4 analytical pages**:

- Overview
- Sales & Profit
- Logistics
- Customer & Geography

Analysis covers sales, profit, margin, orders, customers, products, categories, departments, shipping performance and geographic performance. 1

---

## Key KPIs

| KPI | Value |
|---|---:|
| Total Sales | **$36.78M** |
| Net Profit | **$3.97M** |
| Profit Margin | **10.78%** |
| Total Orders | **65,752** |
| Total Customers | **20,652** |
| Average Order Value | **$559** |
| Average Actual Ship Days | **3.50** |

---

## Key Insights

- **Consumer** is the largest customer segment with approximately **$19.1M** in sales.
- **Fan Shop** is the largest department with approximately **$17.1M** in sales.
- **Fishing** is the leading category with approximately **$6.9M** in sales.
- **Standard Class** is the highest-volume shipping mode with **39,324 orders**.
- **Western Europe** and **Central America** are among the strongest regions by sales.
- The largest country by sales is **Estados Unidos**, followed by **Francia**.
- Discount analysis helps identify areas where higher sales may not translate into stronger profitability.
- Product-level loss analysis provides opportunities for profitability improvement.

---

## SQL Validation

MySQL was used as an independent validation layer for the Power BI analysis.

Performed:

- Database and table setup
- CSV data import
- Data-quality validation
- KPI reconciliation
- Monthly trend analysis
- Product and category analysis
- Customer segment analysis
- Shipping and logistics analysis
- Department analysis
- Regional analysis
- Customer contribution analysis
- Year-over-year validation

**SQL concepts:**

- Aggregations
- `CASE`
- `GROUP BY`
- `DENSE_RANK()`
- `LAG()`
- Window Functions
- Conditional Analysis

The SQL layer independently recalculates major Power BI metrics, reducing dependency on a single analytical system. 2

---

## Project Structure

```
Supply-Chain-Performance-Analysis/

├── 01_Raw_Data
│   └── Original supply chain dataset
├── 02_Cleaned_Data
│   └── Cleaned and engineered Excel/CSV data
├── 03_SQL
│   └── SQL validation & analysis queries
├── 04_Power_BI
│   └── Power BI dashboard (.pbix)
├── 05_Screenshots
│   └── Power Query & Power BI evidence
├── 06_Project_Report
│   └── Professional project documentation
└── README.md
```


## Skills Demonstrated

- Excel
- Power Query
- Power BI
- SQL / MySQL
- Data Cleaning
- Data Modeling
- DAX
- Dashboard Development
- Supply Chain Analysis
- Business Intelligence

## Conclusion

End-to-end supply chain analysis using Excel, Power Query, Power BI and SQL to deliver actionable business and operational insights.

## Project Information

**Title:** Supply Chain Performance Analysis  
**Prepared By:** Ashish Verma  
**Role:** Data Analyst / MIS Analyst  
**Tools Used:** Excel | Power Query | Power BI | MySQL  
**Project Type:** End-to-End Data Analytics & MIS Project
