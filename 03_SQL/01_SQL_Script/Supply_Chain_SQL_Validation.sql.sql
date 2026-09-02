-- ============================================================
-- SUPPLY CHAIN ANALYSIS 
-- ============================================================
-- Database: MySQL 8.0+
-- Primary table: Supply_Chain_Data
--
-- BUSINESS OBJECTIVE
-- ------------------------------------------------------------
-- Measure supply-chain commercial performance, profitability,
-- customer contribution, product/category performance, shipping
-- reliability, departmental performance, regional performance,
-- and year-over-year trends. The outputs are designed to support
-- Power BI validation and business decision-making.

-- ============================================================
-- SUPPLY CHAIN ANALYSIS
-- Purpose:
--   Supply chain performance, sales, profit, product,
--   customer, shipping, department, regional, customer-level,
--   YoY and data-quality analysis.

-- Note:
--   Single-table analysis. No JOINs are required.
-- ============================================================


-- ============================================================
-- GROUP 01 — DATABASE & TABLE SETUP
-- QUERY PURPOSE: Create the analytical database and define the source table schema.
-- ============================================================
CREATE DATABASE Supply_Chain_DB;
USE Supply_Chain_DB;
CREATE TABLE Supply_Chain_Data(
Order_ID VARCHAR(30) ,
Order_Date DATE,
Order_Type VARCHAR(30),
Order_Item_ID VARCHAR(30),
Order_Quantity INT,
Product_ID VARCHAR(30),
Product_Category_ID VARCHAR(30),
Category_Name VARCHAR(30),
Product_Name VARCHAR(200),
Customer_ID VARCHAR(30),
Customer_Name VARCHAR(50),
Customer_Segment VARCHAR(30),
Customer_Country VARCHAR(60),
Customer_State VARCHAR(70),
Customer_City VARCHAR(70),
Customer_Street VARCHAR(70),
Customer_ZIP_Code VARCHAR(40) NULL,
Price_Per_Product DECIMAL(10,5),
Order_Item_Discount DECIMAL(10,5),
Discount_Rate  DECIMAL(10,7),
Discount_Range VARCHAR(30),
Sales  DECIMAL(10,5),
Sales_Per_Customer  DECIMAL(10,5),
Order_Profit  DECIMAL(10,5),
Profit_Margin_Percent  DECIMAL(10,7),
Profit_Category VARCHAR(30),
Ship_Date DATE,
Ship_Mode VARCHAR(30),
Scheduled_Ship_Days INT,
Actual_Ship_Days INT,
Ship_Delay_Days INT,
Ship_Status VARCHAR(30),
Order_Status VARCHAR(30),
Late_Delivery_Risk TINYINT,
Market VARCHAR(30),
Order_Region VARCHAR(30),
Order_Country VARCHAR(60),
Order_State VARCHAR(60),
Order_City VARCHAR(60),
Latitude  DECIMAL(10,5),
Longitude DECIMAL(10,5),
Department_ID VARCHAR(30),
Department_Name VARCHAR(30)
);

-- ============================================================
-- 02. DATA IMPORT & MYSQL CONFIGURATION
-- QUERY PURPOSE: Configure MySQL and import the cleaned Supply Chain dataset.
-- ============================================================
SET GLOBAL local_infile = 1;
SHOW GLOBAL VARIABLES LIKE 'local_infile';
LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Supply_Chain_Cleaned.csv.csv'
INTO TABLE Supply_Chain_Data
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS;

-- ============================================================
-- GROUP 03 — DATA STRUCTURE & QUALITY VALIDATION
-- PURPOSE: Validate table structure,data completeness and duplicate records.
-- ============================================================
SHOW CREATE TABLE Supply_Chain_Data;
SELECT *
FROM Supply_Chain_Data
LIMIT 10;
SELECT COUNT(*) AS Total_Rows
FROM Supply_Chain_Data;

-- Query 03.04 — Check Duplicate Order Items
SELECT Order_ID, Product_ID, Order_Item_ID, 
COUNT(*) AS Duplicate_Count
FROM Supply_Chain_Data
GROUP BY Order_ID, Product_ID, Order_Item_ID
HAVING COUNT(*) > 1;

-- Query 03.05 — Check Missing Critical Identifiers
SELECT *
FROM Supply_Chain_Data
WHERE Order_ID IS NULL
   OR Customer_ID IS NULL
   OR Product_ID IS NULL
   OR Order_Date IS NULL
   OR Sales IS NULL
   OR Order_Profit IS NULL;

-- ============================================================
-- GROUP 04 — OVERALL BUSINESS KPI ANALYSIS
-- ============================================================
-- Query 04.01 — Overall Business Performance KPIs
SELECT 
ROUND(SUM(Sales),0)AS Total_Sales,
ROUND(SUM(Order_Profit),0)AS Net_Profit,
ROUND(SUM(Order_Profit)*100/SUM(Sales),2)AS Profit_Margin,
COUNT(DISTINCT Customer_ID)AS Total_Customer,
COUNT(DISTINCT Order_ID)AS Total_Order,
ROUND(SUM(Sales)/ COUNT(DISTINCT Order_ID),0)AS Avg_Order_Value,
ROUND(AVG(Actual_Ship_Days),2)AS Avg_Ship_Days,
COUNT(DISTINCT CASE WHEN Ship_Status="Shipping On Time" THEN Order_ID ELSE 0 END) AS On_Time_Shipment
FROM Supply_Chain_Data;

-- Query 04.02 — Profitability & Order Performance KPIs
SELECT 
COUNT(DISTINCT CASE WHEN Profit_Category IN( "High" ,"Low")
       THEN  Order_ID ELSE 0 END) AS Profitable_Order,
ROUND(SUM(CASE WHEN Profit_Category IN ("Loss") THEN Order_Profit ELSE 0 END),0) AS Total_Loss,
ROUND(SUM(Order_Profit)/COUNT(DISTINCT Customer_ID),2)AS Avg_Profit_Per_Cust,
ROUND(AVG(Discount_Rate)*100,2)AS Avg_Discount_Percent,
ROUND(SUM(Order_Profit)/COUNT(DISTINCT Order_ID),2)AS Avg_Profit_Per_Order
FROM Supply_Chain_Data;

-- Query 04.03 — Overall Logistics Performance KPIs
SELECT 
COUNT(DISTINCT CASE WHEN Ship_Status<>"Shipping Cancelled"
       THEN  Order_ID ELSE 0 END) AS Total_Delivered_Order,
COUNT(DISTINCT CASE WHEN Ship_Status="Late Delivery" 
       THEN Order_ID ELSE 0 END) AS Late_Shipment,
ROUND(COUNT(DISTINCT CASE WHEN Ship_Status="Late Delivery" 
       THEN Order_ID ELSE 0 END)*100/COUNT(DISTINCT Order_ID),2)AS Late_Ship_Percent,
ROUND(AVG(Scheduled_Ship_Days),2)AS Avg_Schedule_Days,
ROUND(AVG(Actual_Ship_Days),2)AS Avg_Shipment_Days,
ROUND(AVG(Ship_Delay_Days),2)AS Avg_Ship_Delay_Days,
COUNT(DISTINCT CASE WHEN Ship_Status="Shipping Cancelled" 
       THEN Order_ID ELSE 0 END) AS Cancelled_Shipment
FROM Supply_Chain_Data;

-- Query 04.04 — Regional Sales & Profit Performance KPIs
SELECT 
ROUND(SUM(Sales)/COUNT(DISTINCT Customer_ID),0)AS Avg_Sales_Per_Cust,
ROUND(SUM(Order_Profit)/COUNT(DISTINCT Customer_ID),2)AS Avg_Profit_Per_Cust,
ROUND(COUNT(DISTINCT Order_ID)/COUNT(DISTINCT Customer_ID),2)AS Avg_Order_Per_Cust,
ROUND(SUM(Sales)/COUNT(DISTINCT Order_Region),0)AS Avg_Sales_Per_Region,
COUNT(DISTINCT Order_Region)AS Served_Region,
COUNT(DISTINCT Order_Country)AS Served_Country,
COUNT(DISTINCT Order_State)AS Served_State
FROM Supply_Chain_Data;
-- ============================================================
-- GROUP 05 — TIME & TREND ANALYSIS
-- ============================================================
-- Query 05.01 — Monthly Sales & Profit Trend
SELECT
YEAR(Order_Date)AS Order_Year,
MONTH(Order_Date)AS Order_Month,
DATE_FORMAT(Order_Date, '%Y-%m')AS _Year_Month ,
ROUND(SUM(Sales),0)AS Total_Sales,
ROUND(SUM(Order_Profit),0)AS Net_Profit,
ROUND(SUM(Order_Profit)*100/SUM(Sales),2)AS Profit_Margin
FROM Supply_Chain_Data
GROUP BY Order_Year,Order_Month,_Year_Month
ORDER BY Order_Year,Order_Month;

-- ============================================================
-- GROUP 06 — PRODUCT & CATEGORY ANALYSIS
-- ============================================================
-- Query 06.01 — Category Performance
SELECT Category_Name,
COUNT(DISTINCT Order_Item_ID)AS Order_Items,
SUM(Order_Quantity)AS Units_Sold,
ROUND(SUM(Sales),0)AS Category_Sales,
ROUND(SUM(Order_Profit),0)AS Category_Profit,
ROUND(SUM(Order_Profit)*100/SUM(Sales),2)AS Profit_Margin
FROM Supply_Chain_Data
GROUP BY Category_Name
ORDER BY Category_Sales DESC;

-- Query 06.02 — Product-Level Performance
SELECT 
Product_Name, Category_Name ,
ROUND(SUM(Sales),0)AS Total_Sales,
SUM(Order_Quantity)AS Units_Sold,
ROUND(SUM(Order_Profit),0)AS Net_Profit,
ROUND(SUM(Order_Profit)*100/SUM(Sales),2)AS Profit_Margin,
ROUND(SUM(CASE WHEN Profit_Category IN ("Loss") THEN Order_Profit ELSE 0 END),0) AS Total_Loss
FROM Supply_Chain_Data
GROUP BY Product_Name, Category_Name ;

-- Query 06.03 — Top 3 Products by Sales Within Each Category
WITH 
Product_Performance AS 
     (SELECT Category_Name,Product_Name,
			DENSE_RANK() OVER (PARTITION BY Category_Name
                  ORDER BY SUM(Sales) DESC) AS Product_Sales_Rank,
			ROUND(SUM(Sales),0) AS Product_Sales,
			ROUND(SUM(Order_Profit),0) AS Product_Profit
     FROM Supply_Chain_Data
     GROUP BY Category_Name,Product_Name)
SELECT Category_Name,Product_Name,Product_Sales,Product_Profit,Product_Sales_Rank
FROM Product_Performance
WHERE Product_Sales_Rank<=3
ORDER BY Category_Name,Product_Sales_Rank;

-- Query 06.04 — Top 3 Loss-Making Products Within Each Category
WITH 
Product_Performance AS 
     (SELECT Category_Name,Product_Name,
			DENSE_RANK() OVER (PARTITION BY Category_Name
                  ORDER BY ROUND(SUM(CASE WHEN Profit_Category IN ("Loss") THEN Order_Profit ELSE 0 END),0) ASC) AS Product_Loss_Rank,
			ROUND(SUM(Sales),0) AS Product_Sales,
			ROUND(SUM(CASE WHEN Profit_Category IN ("Loss") THEN Order_Profit ELSE 0 END),0) AS Product_Loss
     FROM Supply_Chain_Data
     GROUP BY Category_Name,Product_Name)
SELECT Category_Name,Product_Name,Product_Sales,Product_Loss,Product_Loss_Rank
FROM Product_Performance
WHERE Product_Loss_Rank<=3
ORDER BY Category_Name,Product_Loss_Rank;

-- ============================================================
-- GROUP 07 — CUSTOMER SEGMENT ANALYSIS
-- ============================================================
-- Query 07.01 — Customer Segment Performance
SELECT Customer_Segment,
COUNT(DISTINCT Customer_ID)AS Total_Customer,
ROUND(SUM(Sales),0)AS Total_Sales,
ROUND(SUM(Order_Profit),0)AS Net_Profit,
ROUND(SUM(Sales)*100/(SELECT SUM(Sales)FROM Supply_Chain_Data),2)AS Sales_Distribution_Percent
FROM Supply_Chain_Data
GROUP BY Customer_Segment
ORDER BY Total_Sales DESC;

-- ============================================================
-- GROUP 08 — SHIPPING & OPERATIONAL ANALYSIS
-- ============================================================
-- Query 08.01 — Shipping Mode Performance
SELECT Ship_Mode,
COUNT(DISTINCT Order_ID) AS Total_Orders,
COUNT(DISTINCT CASE WHEN Ship_Status = 'Advance Shipping'
                    THEN Order_ID END ) AS Advance_Shipments,
COUNT(DISTINCT CASE WHEN Ship_Status = 'Shipping On Time' 
                    THEN Order_ID END ) AS On_Time_Shipments,
COUNT( DISTINCT CASE WHEN Ship_Status = 'Shipping Cancelled'
                    THEN Order_ID END) AS Cancelled_Shipments,
COUNT(DISTINCT CASE WHEN Ship_Status = 'Late Delivery'
                    THEN Order_ID END) AS Late_Shipments,
ROUND(AVG(Scheduled_Ship_Days),2) AS Average_Scheduled_Ship_Days,
ROUND(AVG(Actual_Ship_Days),2) AS Average_Actual_Ship_Days,
ROUND(AVG(Ship_Delay_Days),2) AS Average_Ship_Delay_Days
FROM Supply_Chain_Data
GROUP BY Ship_Mode
ORDER BY Total_Orders DESC;

-- ============================================================
-- GROUP 09 — DEPARTMENT PERFORMANCE
-- ============================================================
-- Query 09.01 — Department Sales & Profit Distribution
WITH 
Department_Performance AS 
     (SELECT Department_ID, Department_Name,
             ROUND(SUM(Sales),0) AS Department_Sales,
             ROUND(SUM(Order_Profit),0) AS Department_Profit
      FROM Supply_Chain_Data
      GROUP BY Department_ID, Department_Name)
SELECT Department_ID, Department_Name, Department_Sales,
ROUND(Department_Sales*100/SUM(Department_Sales) OVER (),2)
AS Sales_Distribution_Percent,
Department_Profit,
ROUND(Department_Profit*100/SUM(Department_Profit) OVER (),2)
AS Profit_Distribution_Percent
FROM Department_Performance
ORDER BY Department_Sales DESC;

-- ============================================================
-- GROUP 10 — REGIONAL PERFORMANCE
-- ============================================================
-- Query 10.01 — Regional Sales & Profit Performance
SELECT Order_Region ,
COUNT(DISTINCT Order_ID)AS Total_Order,
ROUND(SUM(Sales),0)AS Total_Sales,
SUM(Order_Quantity)AS Units_Sold,
ROUND(SUM(Order_Profit),0)AS Net_Profit,
ROUND(SUM(Order_Profit)*100/SUM(Sales),2)AS Profit_Margin,
ROUND(SUM(CASE WHEN Profit_Category IN ("Loss") THEN Order_Profit ELSE 0 END),0) AS Total_Loss
FROM Supply_Chain_Data
GROUP BY Order_Region 
ORDER BY Total_Sales DESC;

-- ============================================================
-- GROUP 11 — CUSTOMER-LEVEL PERFORMANCE
-- ============================================================
-- Query 11.01 — Customer Sales Contribution & Cumulative Sales
WITH 
Customer_Sales AS
 (SELECT Customer_ID, Customer_Name, Customer_Segment,
        ROUND(SUM(Sales),0) AS Total_Customer_Sales
    FROM Supply_Chain_Data
    GROUP BY Customer_ID, Customer_Name, Customer_Segment
    )
SELECT Customer_ID, Customer_Name, Customer_Segment, Total_Customer_Sales,
ROUND(Total_Customer_Sales*100/SUM(Total_Customer_Sales) OVER (),4) AS Contribution_Percent,
ROUND(SUM(Total_Customer_Sales) OVER (ORDER BY Total_Customer_Sales DESC
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) * 100/
			    SUM(Total_Customer_Sales) OVER (),2) AS Cumulative_Sales_Percent
FROM Customer_Sales
ORDER BY Total_Customer_Sales DESC;

-- ============================================================
-- GROUP 12 — YEAR-OVER-YEAR PERFORMANCE VALIDATION
-- ============================================================
-- Query 12.01 — Annual Performance & YoY Validation
WITH 
YearlyPerformance AS
       (SELECT DATE_FORMAT(Order_Date,'%Y')AS Order_Year ,
              ROUND(SUM(Sales),0) AS Total_Sales,
              ROUND(SUM(Order_Profit),0) AS Total_Profit,
              ROUND(AVG(Profit_Margin_Percent),2)AS Profit_Margin,
              ROUND(SUM(CASE WHEN Profit_Category IN ("Loss") THEN Order_Profit ELSE 0 END),0) AS Total_Loss,
              COUNT(DISTINCT Customer_ID)AS Total_Customer,
              COUNT(DISTINCT Order_ID)AS Total_Order
       FROM Supply_Chain_Data
       GROUP BY DATE_FORMAT(Order_Date,'%Y')),
PreviousYear AS
       (SELECT 
              Order_Year, Total_Sales, Total_Profit, Profit_Margin, 
              Total_Loss, Total_Customer, Total_Order,
              LAG (Total_Sales) Over(ORDER BY Order_Year ) AS Previous_Year_Sales,
              LAG(Total_Profit) OVER (ORDER BY Order_Year) AS Previous_Year_Profit,
              LAG(Profit_Margin) OVER (ORDER BY Order_Year) AS Previous_Year_Profit_Margin,
              LAG(Total_Loss) OVER (ORDER BY Order_Year) AS Previous_Year_Loss,
              LAG(Total_Customer) OVER (ORDER BY Order_Year) AS Previous_Year_Customer,
              LAG(Total_Order) OVER (ORDER BY Order_Year) AS Previous_Year_Order
       FROM YearlyPerformance)
SELECT Order_Year,Total_Sales,Total_Profit,Profit_Margin,
Round((Total_Sales-Previous_Year_Sales)*100/
       NULLIF(Previous_Year_Sales,0),2) AS Sales_YoY_Percent,
Round((Total_Profit-Previous_Year_Profit)*100/
       NULLIF(Previous_Year_Profit,0),2) AS Profit_YoY_Percent,
Round((Profit_Margin-Previous_Year_Profit_Margin)*100/
       NULLIF(Previous_Year_Profit_Margin,0),2) AS Profit_MARGIN_YoY_Percent,
Round((Total_Loss-Previous_Year_Loss)*100/
       NULLIF(Previous_Year_Loss,0),2) AS Loss_YoY_Percent,
Round((Total_Customer-Previous_Year_Customer)*100/
       NULLIF(Previous_Year_Customer,0),2) AS Customer_YoY_Percent,
Round((Total_Order-Previous_Year_Order)*100/
       NULLIF(Previous_Year_Order,0),2) AS Order_YoY_Percent      
FROM PreviousYear
ORDER BY Order_Year;

-- ============================================================
-- GROUP 13 — FINAL DATA QUALITY VALIDATION
-- ============================================================
SELECT
SUM(CASE WHEN Sales < 0 
		 THEN 1 ELSE 0 END) AS Negative_Sales_Records,
SUM(CASE WHEN Order_Quantity <= 0
		 THEN 1 ELSE 0  END) AS Invalid_Quantity_Records,  
SUM(CASE WHEN Price_Per_Product < 0 
		 THEN 1 ELSE 0 END) AS Invalid_Price_Records,  
SUM(CASE WHEN Discount_Rate < 0 OR Discount_Rate > 1 
		 THEN 1 ELSE 0 END) AS Invalid_Discount_Records,  
SUM(CASE WHEN Profit_Margin_Percent < -1 OR Profit_Margin_Percent > 1 
		 THEN 1 ELSE 0 END) AS Invalid_Margin_Records,  
SUM(CASE WHEN Actual_Ship_Days < 0 OR Scheduled_Ship_Days < 0 OR Ship_Delay_Days < 0
		 THEN 1 ELSE 0 END) AS Invalid_Shipping_Duration_Records
FROM Supply_Chain_Data;

-- ============================================================
-- END OF SUPPLY CHAIN ANALYSIS
-- ============================================================