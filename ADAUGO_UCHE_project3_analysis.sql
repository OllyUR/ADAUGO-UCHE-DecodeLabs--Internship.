SELECT *FROM sales_data
LIMIT 10;
--Basic Extraction (SELECT):
SELECT OrderID, Product, TotalPrice FROM sales_data LIMIT 10;

--Filtering Rows (WHERE): Isolate specific thresholds or string patterns (e.g., orders matching a specific marketing source or high-value amounts):
SELECT * FROM sales_data 
WHERE OrderStatus = 'Shipped' AND TotalPrice >= 500.00;

--Categorical Buckets (GROUP BY & Aggregations): Collapse raw rows into executive summaries to count metrics, calculate averages, or sum revenue across distinct groups:
SELECT Product, COUNT(OrderID) AS TotalOrders, AVG(UnitPrice) AS AvgPrice, SUM(TotalPrice) AS TotalRevenue
FROM sales_data
GROUP BY Product
ORDER BY TotalRevenue DESC;

--Missing Tracking Numbers
SELECT *
FROM sales_data
WHERE trackingnumber IS NULL;

--Missing Referral Sources
SELECT COUNT(*) AS missing_referral_source
FROM sales_data
WHERE referralsource IS NULL;

--Handle Missing Values
--Replace Missing Referral Sources
UPDATE sales_data
SET referralsource = 'Unknown'
WHERE referralsource IS NULL;

--Calculate Count
SELECT 
    COUNT(quantity) AS quantity_count,
    COUNT(unitprice) AS unitprice_count,
    COUNT(totalprice) AS totalprice_count
FROM sales_data;

--Calculate Mean (Average)
SELECT 
    AVG(quantity) AS avg_quantity,
    AVG(unitprice) AS avg_unitprice,
    AVG(totalprice) AS avg_totalprice
FROM sales_data;

--Calculate Median
SELECT
PERCENTILE_CONT(0.5) 
WITHIN GROUP (ORDER BY totalprice) AS median_totalprice
FROM sales_data;

--Compare Mean vs Median
--Interpretation:
--If Mean ≈ Median → symmetric distribution
--If Mean > Median → right-skewed distribution
--If Mean < Median → left-skewed distribution

--OUTLIER IDENTIFICATION
--Generate 5-Number Summary
SELECT
MIN(totalprice) AS minimum,
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY totalprice) AS q1,
PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY totalprice) AS median,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY totalprice) AS q3,
MAX(totalprice) AS maximum
FROM sales_data;

--Calculate IQR
--Formula:
--IQR=Q3−Q1
WITH quartiles AS (
SELECT
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY totalprice) AS q1,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY totalprice) AS q3
FROM sales_data
)

SELECT
q1,
q3,
(q3 - q1) AS iqr
FROM quartiles;

--Detect Outliers
--Formula:
--Lower Boundary=Q1−1.5(IQR)
--Upper Boundary=Q3+1.5(IQR)
WITH quartiles AS (
SELECT
PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY totalprice) AS q1,
PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY totalprice) AS q3
FROM sales_data
),

bounds AS (
SELECT
q1,
q3,
(q3 - q1) AS iqr,
(q1 - 1.5 * (q3 - q1)) AS lower_bound,
(q3 + 1.5 * (q3 - q1)) AS upper_bound
FROM quartiles
)

SELECT *
FROM sales_data, bounds
WHERE totalprice < lower_bound
OR totalprice > upper_bound;

--CATEGORICAL TREND ANALYSIS
--Products with Highest Revenue
SELECT
product,
SUM(totalprice) AS total_revenue
FROM sales_data
GROUP BY product
ORDER BY total_revenue DESC;

--Payment Methods Generating Highest Revenue
SELECT
paymentmethod,
SUM(totalprice) AS revenue
FROM sales_data
GROUP BY paymentmethod
ORDER BY revenue DESC;

--Referral Sources Performance
SELECT
referralsource,
SUM(totalprice) AS revenue
FROM sales_data
GROUP BY referralsource
ORDER BY revenue DESC;

--Cancellation Trends
SELECT
product,
COUNT(*) AS cancellations
FROM sales_data
WHERE orderstatus = 'Cancelled'
GROUP BY product
ORDER BY cancellations DESC;

--Online Payment Cancellation Rate
SELECT
paymentmethod,
COUNT(*) AS cancellations
FROM sales_data
WHERE orderstatus = 'Cancelled'
GROUP BY paymentmethod
ORDER BY cancellations DESC;

--Final Business Insights

-- 82% of orders were completed successfully.
-- Desk products generated the highest revenue.
-- Online payment methods showed the highest cancellation rates.
-- TotalPrice distribution was positively skewed due to extreme purchases.
-- Referral sources from online campaigns generated the highest sales revenue.