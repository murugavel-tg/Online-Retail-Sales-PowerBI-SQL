/*
============================================================
ONLINE RETAIL SALES & CUSTOMER ANALYTICS
SQL SERVER PROJECT
============================================================

Dataset:
Online Retail

Table:
online_retail_cleaned

Key Analysis Areas:
1. Overall Business KPIs
2. Average Order Value
3. Monthly Sales Analysis
4. Month-over-Month Growth
5. Top Products
6. Top Customers
7. RFM Customer Analysis
8. RFM Scoring
9. Customer Segmentation
10. Country Analysis
11. Revenue Contribution by Country
12. UK vs International Analysis
13. Revenue per Customer
14. One-Time vs Repeat Customers
15. Customer Purchase Frequency
============================================================
*/


/*
============================================================
01. OVERALL BUSINESS KPIs
============================================================

Purpose:
Calculate the key metrics for the entire business.

Metrics:
- Total Revenue
- Total Orders
- Total Customers
- Total Products
- Total Countries
============================================================
*/

SELECT
    SUM(Revenue) AS TotalRevenue,
    COUNT(DISTINCT InvoiceNo) AS TotalOrders,
    COUNT(DISTINCT CustomerID) AS TotalCustomers,
    COUNT(DISTINCT StockCode) AS TotalProducts,
    COUNT(DISTINCT Country) AS TotalCountries
FROM online_retail_cleaned;


/*
============================================================
02. AVERAGE ORDER VALUE (AOV)
============================================================

Purpose:
Calculate the average revenue generated per order.

Formula:
AOV = Total Revenue / Total Orders

NULLIF prevents division-by-zero errors.
============================================================
*/

SELECT
    SUM(Revenue) AS TotalRevenue,
    COUNT(DISTINCT InvoiceNo) AS TotalOrders,

    SUM(Revenue) /
    NULLIF(COUNT(DISTINCT InvoiceNo), 0) AS AOV

FROM online_retail_cleaned;


/*
============================================================
03. MONTHLY SALES ANALYSIS
============================================================

Purpose:
Analyze revenue and order volume by month.

Business Questions:
- How does revenue change over time?
- Which months generate the most revenue?
- Which months have the highest order volume?
============================================================
*/

SELECT
    YEAR(InvoiceDate) AS SalesYear,
    MONTH(InvoiceDate) AS SalesMonth,
    DATENAME(MONTH, InvoiceDate) AS MonthName,

    SUM(Revenue) AS TotalRevenue,
    COUNT(DISTINCT InvoiceNo) AS TotalOrders

FROM online_retail_cleaned

GROUP BY
    YEAR(InvoiceDate),
    MONTH(InvoiceDate),
    DATENAME(MONTH, InvoiceDate)

ORDER BY
    SalesYear,
    SalesMonth;


/*
============================================================
04. MONTH-OVER-MONTH (MoM) REVENUE GROWTH
============================================================

Purpose:
Compare each month's revenue with the previous month.

LAG() retrieves the previous month's revenue.

Formula:
MoM Growth % =
(Current Month Revenue - Previous Month Revenue)
------------------------------------------------------------
Previous Month Revenue × 100
============================================================
*/

WITH MonthlySales AS
(
    SELECT
        YEAR(InvoiceDate) AS SalesYear,
        MONTH(InvoiceDate) AS SalesMonth,
        DATENAME(MONTH, InvoiceDate) AS MonthName,

        SUM(Revenue) AS TotalRevenue

    FROM online_retail_cleaned

    GROUP BY
        YEAR(InvoiceDate),
        MONTH(InvoiceDate),
        DATENAME(MONTH, InvoiceDate)
)

SELECT
    SalesYear,
    SalesMonth,
    MonthName,
    TotalRevenue,

    LAG(TotalRevenue) OVER
    (
        ORDER BY SalesYear, SalesMonth
    ) AS PreviousMonthRevenue,

    ROUND(
        (
            TotalRevenue -
            LAG(TotalRevenue) OVER
            (
                ORDER BY SalesYear, SalesMonth
            )
        )
        * 100.0
        /
        NULLIF(
            LAG(TotalRevenue) OVER
            (
                ORDER BY SalesYear, SalesMonth
            ),
            0
        ),
        2
    ) AS MoM_Growth_Percent

FROM MonthlySales

ORDER BY
    SalesYear,
    SalesMonth;


/*
============================================================
05. TOP 10 PRODUCTS BY REVENUE
============================================================

Purpose:
Identify the products generating the highest revenue.

Metrics:
- Quantity Sold
- Revenue
- Number of Orders
============================================================
*/

SELECT TOP 10
    StockCode,
    MAX(Description) AS Description,

    SUM(Quantity) AS TotalQuantitySold,
    SUM(Revenue) AS TotalRevenue,
    COUNT(DISTINCT InvoiceNo) AS NumberOfOrders

FROM online_retail_cleaned

GROUP BY
    StockCode

ORDER BY
    TotalRevenue DESC;


/*
============================================================
06. TOP 10 CUSTOMERS BY REVENUE
============================================================

Purpose:
Identify the highest-value customers based on revenue.

Metrics:
- Number of Orders
- Total Quantity Purchased
- Total Revenue
- Average Transaction Value
============================================================
*/

SELECT TOP 10
    CustomerID,

    COUNT(DISTINCT InvoiceNo) AS NumberOfOrders,
    SUM(Quantity) AS TotalQuantityPurchased,
    SUM(Revenue) AS TotalRevenue,

    SUM(Revenue) /
    NULLIF(COUNT(DISTINCT InvoiceNo), 0)
    AS AverageTransactionValue

FROM online_retail_cleaned

WHERE CustomerID IS NOT NULL

GROUP BY
    CustomerID

ORDER BY
    TotalRevenue DESC;


/*
============================================================
07. RFM CUSTOMER ANALYSIS
============================================================

RFM stands for:

R = Recency
F = Frequency
M = Monetary

Recency:
Number of days since the customer's last purchase.

Frequency:
Number of unique orders made by the customer.

Monetary:
Total revenue generated by the customer.

Lower Recency = Better
Higher Frequency = Better
Higher Monetary = Better
============================================================
*/

WITH CustomerRFM AS
(
    SELECT
        CustomerID,

        /*
        Recency:
        Find the customer's latest purchase date
        and compare it with the latest date in
        the entire dataset.
        */

        DATEDIFF(
            DAY,
            MAX(InvoiceDate),
            (
                SELECT MAX(InvoiceDate)
                FROM online_retail_cleaned
            )
        ) AS Recency,

        /*
        Frequency:
        Count the number of unique invoices/orders.
        */

        COUNT(DISTINCT InvoiceNo) AS Frequency,

        /*
        Monetary:
        Calculate total revenue generated.
        */

        SUM(Revenue) AS Monetary

    FROM online_retail_cleaned

    WHERE CustomerID IS NOT NULL

    GROUP BY
        CustomerID
)

SELECT
    CustomerID,
    Recency,
    Frequency,
    Monetary

FROM CustomerRFM

ORDER BY
    Monetary DESC;


/*
============================================================
08. RFM SCORING
============================================================

Purpose:
Convert Recency, Frequency and Monetary values
into scores from 1 to 5.

Recency:
Lower is better, so the score is reversed.

Frequency:
Higher is better.

Monetary:
Higher is better.

NTILE(5) divides customers into five groups.

For Recency:

6 - NTILE(5)

converts:

NTILE 1 → Score 5
NTILE 2 → Score 4
NTILE 3 → Score 3
NTILE 4 → Score 2
NTILE 5 → Score 1
============================================================
*/

WITH CustomerRFM AS
(
    SELECT
        CustomerID,

        DATEDIFF(
            DAY,
            MAX(InvoiceDate),
            (
                SELECT MAX(InvoiceDate)
                FROM online_retail_cleaned
            )
        ) AS Recency,

        COUNT(DISTINCT InvoiceNo) AS Frequency,

        SUM(Revenue) AS Monetary

    FROM online_retail_cleaned

    WHERE CustomerID IS NOT NULL

    GROUP BY
        CustomerID
),

RFMScores AS
(
    SELECT
        CustomerID,
        Recency,
        Frequency,
        Monetary,

        -- Lower Recency is better, so reverse the score.
        6 - NTILE(5) OVER
        (
            ORDER BY Recency
        ) AS R_Score,

        -- Higher Frequency is better.
        NTILE(5) OVER
        (
            ORDER BY Frequency
        ) AS F_Score,

        -- Higher Monetary value is better.
        NTILE(5) OVER
        (
            ORDER BY Monetary
        ) AS M_Score

    FROM CustomerRFM
)

SELECT
    CustomerID,
    Recency,
    Frequency,
    Monetary,
    R_Score,
    F_Score,
    M_Score,

    CONCAT(
        R_Score,
        F_Score,
        M_Score
    ) AS RFM_Score

FROM RFMScores

ORDER BY
    Monetary DESC;


/*
============================================================
09. RFM CUSTOMER SEGMENTATION
============================================================

Purpose:
Convert RFM scores into meaningful business segments.

Segments:
- Champions
- Loyal Customers
- Potential Loyalists
- At Risk
- Lost Customers
- Other
============================================================
*/

WITH CustomerRFM AS
(
    SELECT
        CustomerID,

        DATEDIFF(
            DAY,
            MAX(InvoiceDate),
            (
                SELECT MAX(InvoiceDate)
                FROM online_retail_cleaned
            )
        ) AS Recency,

        COUNT(DISTINCT InvoiceNo) AS Frequency,

        SUM(Revenue) AS Monetary

    FROM online_retail_cleaned

    WHERE CustomerID IS NOT NULL

    GROUP BY CustomerID
),

RFMScores AS
(
    SELECT
        CustomerID,
        Recency,
        Frequency,
        Monetary,

        6 - NTILE(5) OVER
        (
            ORDER BY Recency
        ) AS R_Score,

        NTILE(5) OVER
        (
            ORDER BY Frequency
        ) AS F_Score,

        NTILE(5) OVER
        (
            ORDER BY Monetary
        ) AS M_Score

    FROM CustomerRFM
),

RFMFinal AS
(
    SELECT
        *,
        CONCAT(
            R_Score,
            F_Score,
            M_Score
        ) AS RFM_Score

    FROM RFMScores
)

SELECT
    *,
    
    CASE

        WHEN R_Score >= 4
             AND F_Score >= 4
             AND M_Score >= 4
            THEN 'Champions'

        WHEN R_Score >= 3
             AND F_Score >= 4
             AND M_Score >= 3
            THEN 'Loyal Customers'

        WHEN R_Score >= 4
             AND F_Score <= 3
            THEN 'Potential Loyalists'

        WHEN R_Score <= 2
             AND F_Score >= 3
             AND M_Score >= 3
            THEN 'At Risk'

        WHEN R_Score <= 2
             AND F_Score <= 2
            THEN 'Lost Customers'

        ELSE 'Other'

    END AS CustomerSegment

FROM RFMFinal

ORDER BY
    Monetary DESC;


/*
============================================================
10. RFM SEGMENT SUMMARY
============================================================

Purpose:
Summarize customer count and revenue by RFM segment.

This is more useful for business reporting than
displaying thousands of individual customers.
============================================================
*/

WITH CustomerRFM AS
(
    SELECT
        CustomerID,

        DATEDIFF(
            DAY,
            MAX(InvoiceDate),
            (
                SELECT MAX(InvoiceDate)
                FROM online_retail_cleaned
            )
        ) AS Recency,

        COUNT(DISTINCT InvoiceNo) AS Frequency,

        SUM(Revenue) AS Monetary

    FROM online_retail_cleaned

    WHERE CustomerID IS NOT NULL

    GROUP BY CustomerID
),

RFMScores AS
(
    SELECT
        CustomerID,
        Recency,
        Frequency,
        Monetary,

        6 - NTILE(5) OVER
        (
            ORDER BY Recency
        ) AS R_Score,

        NTILE(5) OVER
        (
            ORDER BY Frequency
        ) AS F_Score,

        NTILE(5) OVER
        (
            ORDER BY Monetary
        ) AS M_Score

    FROM CustomerRFM
),

RFMFinal AS
(
    SELECT
        *,
        CONCAT(R_Score, F_Score, M_Score) AS RFM_Score

    FROM RFMScores
),

SegmentedCustomers AS
(
    SELECT
        *,

        CASE
            WHEN R_Score >= 4
                 AND F_Score >= 4
                 AND M_Score >= 4
                THEN 'Champions'

            WHEN R_Score >= 3
                 AND F_Score >= 4
                 AND M_Score >= 3
                THEN 'Loyal Customers'

            WHEN R_Score >= 4
                 AND F_Score <= 3
                THEN 'Potential Loyalists'

            WHEN R_Score <= 2
                 AND F_Score >= 3
                 AND M_Score >= 3
                THEN 'At Risk'

            WHEN R_Score <= 2
                 AND F_Score <= 2
                THEN 'Lost Customers'

            ELSE 'Other'
        END AS CustomerSegment

    FROM RFMFinal
)

SELECT
    CustomerSegment,

    COUNT(*) AS CustomerCount,

    SUM(Monetary) AS TotalRevenue,

    AVG(Monetary) AS AverageCustomerRevenue

FROM SegmentedCustomers

GROUP BY
    CustomerSegment

ORDER BY
    TotalRevenue DESC;


/*
============================================================
11. TOP 10 COUNTRIES BY REVENUE
============================================================

Purpose:
Identify the most important geographic markets.

Metrics:
- Orders
- Customers
- Quantity Sold
- Revenue
============================================================
*/

SELECT TOP 10
    Country,

    COUNT(DISTINCT InvoiceNo) AS TotalOrders,

    COUNT(DISTINCT CustomerID) AS TotalCustomers,

    SUM(Quantity) AS TotalQuantitySold,

    SUM(Revenue) AS TotalRevenue

FROM online_retail_cleaned

GROUP BY
    Country

ORDER BY
    TotalRevenue DESC;


/*
============================================================
12. REVENUE CONTRIBUTION BY COUNTRY
============================================================

Purpose:
Calculate each country's percentage contribution
to total company revenue.

Formula:

Country Revenue
---------------- × 100
Total Revenue
============================================================
*/

SELECT
    Country,

    SUM(Revenue) AS TotalRevenue,

    ROUND(
        SUM(Revenue) * 100.0
        /
        SUM(SUM(Revenue)) OVER (),
        2
    ) AS RevenuePercentage

FROM online_retail_cleaned

GROUP BY
    Country

ORDER BY
    TotalRevenue DESC;


/*
============================================================
13. UK VS INTERNATIONAL MARKET ANALYSIS
============================================================

Purpose:
Compare the domestic UK market with
international markets.

Markets:
- United Kingdom
- International
============================================================
*/

SELECT

    CASE
        WHEN Country = 'United Kingdom'
            THEN 'United Kingdom'
        ELSE 'International'
    END AS Market,

    COUNT(DISTINCT InvoiceNo) AS TotalOrders,

    COUNT(DISTINCT CustomerID) AS TotalCustomers,

    SUM(Quantity) AS TotalQuantitySold,

    SUM(Revenue) AS TotalRevenue,

    ROUND(
        SUM(Revenue) * 100.0
        /
        SUM(SUM(Revenue)) OVER (),
        2
    ) AS RevenuePercentage

FROM online_retail_cleaned

GROUP BY
    CASE
        WHEN Country = 'United Kingdom'
            THEN 'United Kingdom'
        ELSE 'International'
    END

ORDER BY
    TotalRevenue DESC;


/*
============================================================
14. REVENUE PER CUSTOMER
============================================================

Purpose:
Compare customer value between UK
and international markets.

CustomerID IS NOT NULL is used because
revenue per customer requires an identifiable customer.
============================================================
*/

SELECT

    CASE
        WHEN Country = 'United Kingdom'
            THEN 'United Kingdom'
        ELSE 'International'
    END AS Market,

    COUNT(DISTINCT CustomerID) AS TotalCustomers,

    SUM(Revenue) AS TotalRevenue,

    ROUND(
        SUM(Revenue)
        /
        NULLIF(
            COUNT(DISTINCT CustomerID),
            0
        ),
        2
    ) AS RevenuePerCustomer

FROM online_retail_cleaned

WHERE CustomerID IS NOT NULL

GROUP BY
    CASE
        WHEN Country = 'United Kingdom'
            THEN 'United Kingdom'
        ELSE 'International'
    END

ORDER BY
    RevenuePerCustomer DESC;


/*
============================================================
15. ONE-TIME VS REPEAT CUSTOMERS
============================================================

Purpose:
Understand customer retention and repeat purchasing.

One-Time Customer:
Exactly one order.

Repeat Customer:
More than one order.
============================================================
*/

WITH CustomerOrders AS
(
    SELECT
        CustomerID,

        COUNT(DISTINCT InvoiceNo) AS NumberOfOrders,

        SUM(Revenue) AS TotalRevenue

    FROM online_retail_cleaned

    WHERE CustomerID IS NOT NULL

    GROUP BY
        CustomerID
)

SELECT

    CASE
        WHEN NumberOfOrders = 1
            THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END AS CustomerType,

    COUNT(*) AS CustomerCount,

    SUM(TotalRevenue) AS TotalRevenue,

    AVG(TotalRevenue) AS AverageRevenuePerCustomer

FROM CustomerOrders

GROUP BY

    CASE
        WHEN NumberOfOrders = 1
            THEN 'One-Time Customer'
        ELSE 'Repeat Customer'
    END

ORDER BY
    TotalRevenue DESC;


/*
============================================================
16. CUSTOMER PURCHASE FREQUENCY
============================================================

Purpose:
Understand how frequently customers purchase.

Groups:
- 1 Order
- 2-5 Orders
- 6-10 Orders
- 11-20 Orders
- 20+ Orders

This helps identify customer retention
and loyalty opportunities.
============================================================
*/

WITH CustomerOrders AS
(
    SELECT
        CustomerID,

        COUNT(DISTINCT InvoiceNo) AS NumberOfOrders,

        SUM(Revenue) AS TotalRevenue

    FROM online_retail_cleaned

    WHERE CustomerID IS NOT NULL

    GROUP BY
        CustomerID
)

SELECT

    CASE

        WHEN NumberOfOrders = 1
            THEN '1 Order'

        WHEN NumberOfOrders BETWEEN 2 AND 5
            THEN '2-5 Orders'

        WHEN NumberOfOrders BETWEEN 6 AND 10
            THEN '6-10 Orders'

        WHEN NumberOfOrders BETWEEN 11 AND 20
            THEN '11-20 Orders'

        ELSE '20+ Orders'

    END AS PurchaseFrequency,

    COUNT(*) AS CustomerCount,

    SUM(TotalRevenue) AS TotalRevenue

FROM CustomerOrders

GROUP BY

    CASE

        WHEN NumberOfOrders = 1
            THEN '1 Order'

        WHEN NumberOfOrders BETWEEN 2 AND 5
            THEN '2-5 Orders'

        WHEN NumberOfOrders BETWEEN 6 AND 10
            THEN '6-10 Orders'

        WHEN NumberOfOrders BETWEEN 11 AND 20
            THEN '11-20 Orders'

        ELSE '20+ Orders'

    END

ORDER BY
    CustomerCount DESC;


/*
============================================================
END OF SQL ANALYSIS
============================================================
*/