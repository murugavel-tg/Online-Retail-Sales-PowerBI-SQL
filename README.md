# Online-Retail-Sales-PowerBI-SQL
📌 Project Overview

This project analyzes transactional sales data from an online retail business using SQL Server and Microsoft Power BI.

The objective is to transform raw transactional data into meaningful business insights covering sales performance, customer behavior, customer segmentation, product performance, and geographic markets.

The project demonstrates an end-to-end data analytics workflow:

Raw Data → Data Cleaning → SQL Analysis → RFM Analysis → Power BI Dashboard → Business Insights

🎯 Business Objectives

The analysis focuses on answering key business questions:

What is the overall revenue and order performance?
How does revenue change month over month?
Which products generate the most revenue?
Which products have the highest sales volume?
Who are the highest-value customers?
Which customers are one-time vs repeat buyers?
How frequently do customers purchase?
Which customer segments generate the most revenue?
Which countries contribute the most revenue?
How does the UK market compare with international markets?

📂 Dataset

The project uses the Online Retail dataset from the UCI Machine Learning Repository.

The dataset contains transactional records from a UK-based online retailer covering December 2010 to December 2011.

Original dataset:

UCI Online Retail Dataset

Main columns
Column	Description
InvoiceNo	Transaction/invoice number
StockCode	Product code
Description	Product description
Quantity	Quantity purchased
InvoiceDate	Transaction date
UnitPrice	Price per unit
CustomerID	Customer identifier
Country	Customer country

🧹 Data Cleaning

The raw dataset contained missing values, duplicate records, cancelled transactions, negative quantities, and invalid prices.

Raw dataset
541,909 rows
8 columns
Cleaning performed
Removed duplicate transactions
Handled missing product descriptions
Handled missing customer identifiers
Removed cancelled transactions
Removed invalid negative/zero-price records
Created a Revenue column
Cleaned dataset
524,878 rows
9 columns

🗄️ SQL Analysis

SQL Server was used for data validation, KPI calculations, customer analysis, RFM segmentation, product analysis, and geographic analysis.

Key SQL analyses
Overall Business KPIs
Average Order Value
Monthly Sales Analysis
Month-over-Month Revenue Growth
Top 10 Products by Revenue
Top 10 Customers by Revenue
RFM Customer Analysis
RFM Scoring
Customer Segmentation
RFM Segment Summary
Top Countries by Revenue
Country Revenue Contribution
UK vs International Market Analysis
Revenue per Customer
One-Time vs Repeat Customers
Customer Purchase Frequency

📊 Power BI Dashboard

The Power BI dashboard contains three analytical pages.

1️⃣ Sales Overview

Provides a high-level view of business performance.

KPIs
💰 Total Revenue: £10.64M
🧾 Total Orders: 19.96K
👥 Total Customers: 4.34K
🛒 Average Order Value: £533
Visualizations
Monthly Revenue Trend
Monthly Revenue & MoM Growth
Top 10 Products by Revenue
Top 10 Countries by Revenue
Country Filter

2️⃣ Customer Analytics

Focuses on customer behavior and RFM segmentation.

Analysis
Customer Segments
Revenue by Customer Segment
One-Time vs Repeat Customers
Customer Purchase Frequency
RFM Segments
🏆 Champions
💎 Loyal Customers
⭐ Potential Loyalists
⚠️ At Risk
🔴 Lost Customers
Other

3️⃣ Product & Sales Analysis

Provides detailed product-level performance analysis.

Visualizations
Top 10 Products by Quantity Sold
Top 10 Products by Revenue
Top 10 Products by Number of Orders
Product Performance Table
Product Filter

🔍 Key Business Insights
📈 Sales Performance
Total revenue was approximately £10.64M.
November 2011 was the strongest month with approximately £1.50M in revenue.
February 2011 recorded the lowest monthly revenue at approximately £522.5K.
May 2011 recorded strong month-over-month growth of approximately 43.3%.
🌍 Geographic Performance
The UK generated approximately 84.6% of total revenue.
International markets contributed approximately 15.4%.
The Netherlands, Ireland, Germany, and France were among the strongest international markets.
👥 Customer Behavior
4,338 identifiable customers were included in the customer-level analysis.
2,845 customers were repeat customers.
1,493 customers made only one purchase.
Repeat customers generated substantially more revenue per customer than one-time customers.
🏆 Customer Value

RFM analysis identified Champions as the most valuable customer segment, contributing the largest share of identifiable customer revenue.

🔄 Purchase Frequency

A relatively small group of highly frequent customers generated a significant portion of customer revenue, highlighting the importance of customer retention and loyalty strategies.

📦 Product Performance

The analysis shows that the products with the highest quantity sold, revenue, and number of orders are not necessarily the same, demonstrating the importance of evaluating product performance from multiple perspectives.

🛠️ Technologies Used
SQL Server
Microsoft Power BI
DAX
Excel
Python — data preparation/validation
GitHub

📸 Dashboard Preview
Sales Overview

Add your 01_Sales_Overview.png screenshot here.

Customer Analytics

Add your 02_Customer_Analytics.png screenshot here.

Product & Sales Analysis

Add your 03_Product_Sales_Analysis.png screenshot here.

💡 Business Recommendations

Based on the analysis:

Focus on Champions and Loyal Customers through retention and loyalty programs.
Target Potential Loyalists with personalized offers to increase purchase frequency.
Re-engage At-Risk and Lost Customers using targeted campaigns.
Investigate opportunities for expanding the strongest international markets.
Analyze high-volume products separately from high-revenue products to improve inventory and pricing decisions.
Monitor unusual product-level transactions for potential data-quality or business-process issues.

👨‍💻 Author

Murugavel Gnanasekaran

Mechanical Engineer transitioning into Data Science / Data Analytics, with hands-on experience in SQL, Power BI, Python, Machine Learning, and NLP.

⭐ Project Highlights

End-to-end analytics project demonstrating:

Data Cleaning → SQL → RFM Analysis → DAX → Power BI → Business Insights



