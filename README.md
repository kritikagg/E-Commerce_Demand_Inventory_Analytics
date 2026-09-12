# E-Commerce Demand Inventory Analytics

1. Project Overview

An end-to-end analytics project simulating a mid-size e-commerce business, built to demonstrate the full data pipeline a business/data analyst would own: from raw transaction data through cleaning, SQL modeling, demand forecasting, inventory risk scoring, and an executive-ready Power BI dashboard.

2. Business Problem

E-commerce businesses lose revenue in two opposite ways: stockouts on high-demand products, and excess capital tied up in slow-moving inventory. This project builds a lightweight, explainable framework to identify which products fall into each risk category and quantify the business impact.

3. Objectives
Build a reproducible data pipeline using only free/standard tools (Colab, SQL Server, Excel, Power BI)
Clean and model realistic (synthetic) transaction data
Answer core business questions about revenue, demand, and seasonality
Classify products by demand pattern (fast/medium/slow/volatile)
Forecast near-term demand for top-revenue products
Score inventory risk using standard supply-chain formulas (safety stock, reorder point)
Package findings into a business-facing dashboard
4. Dataset

Synthetic e-commerce order-line data, ~91,600 clean rows, 18 months (Apr 2024–Sep 2025), 50 products across 5 categories, 5 regions, ~6,000 customers. Generated with a fixed random seed and built-in seasonality, demand tiers, regional weighting, and intentional data-quality issues (duplicates, missing values, invalid entries) to demonstrate cleaning skills. Full generation logic is in notebooks/01_generate_dataset.ipynb.

5. Tools Used

Google Colab (Python: pandas, numpy, matplotlib, statsmodels), SQL Server Management Studio 22 (T-SQL), Excel/CSV, Power BI Desktop.

6. Methodology
Generate synthetic transactional data with realistic business patterns
Clean data (deduplication, missing values, invalid-value checks, type conversion)
Engineer derived fields (Revenue, NetRevenue, Profit, date parts)
Load into SQL Server star schema; validate with business queries
Compute per-product demand statistics and classify demand behavior
Forecast 30-day demand for the top 10 revenue products using exponential smoothing (selected via backtest against naive and moving-average baselines)
Score inventory risk using safety stock / reorder point formulas
Build a 3-page Power BI dashboard
Derive business insights and recommendations from the actual results
7. Data Pipeline
Synthetic generation → ecommerce_raw.csv → Python cleaning → ecommerce_clean.csv
    → SQL Server (StagingRaw → DimProduct/DimDate/DimRegion/DimCustomer → FactSales)
    → Python demand/forecast/risk analysis (CSV outputs)
    → Power BI (3-page dashboard)
8. SQL Analysis

Implemented a simplified star schema (FactSales + 4 dimension tables) in SQL Server. Business queries cover revenue by category/product/region, monthly trends, top/bottom product rankings (using RANK(), NTILE()), reorder-point violations, and inventory coverage — using CTEs, window functions, and CASE-based classification. Full scripts in sql/.

9. Demand Forecasting

Forecasted 30-day demand for the top 10 revenue products. Backtested three approaches (naive baseline, 7-day moving average, exponential smoothing) on a held-out 30-day window; exponential smoothing had the lowest average MAE/RMSE and was selected as the production model. MAPE excludes zero-demand days to avoid divide-by-zero distortion.

10. Inventory Risk Analysis

Applied standard inventory formulas:

Safety Stock = Z × σ(daily demand) × √(lead time), at a 95% service level (Z = 1.65)
Reorder Point = average demand during lead time + safety stock
Inventory Coverage (days) = current inventory / average daily demand

Products are scored into HIGH/MEDIUM/LOW risk using an additive rule that weights stockout risk highest, with volatility and excess inventory as secondary factors.

11. Power BI Dashboard

Three pages: Executive Overview (revenue/profit/order KPIs, trends, top products, regional performance), Demand Analytics (demand ranking, volatility, historical vs. forecast), Inventory Risk (risk-level KPIs, risk matrix scatter, reorder-point comparison, conditional formatting on risk level).

12. Key Findings
Top 10 products generate ~53% of total revenue
9 of the top 20 revenue products are currently below their computed reorder point
Festive-season (Oct–Dec) monthly demand runs ~42% above other months
7 of 17 slow-moving products also carry excess inventory (>60 days coverage)
Discount depth shows a mild positive association with order size, not a dramatic one
North and South regions contribute over half of total revenue; Central lags at ~10%
Category-level YoY growth is essentially flat (−1% to +1.6%) once compared on matching calendar months — a naive half-over-half comparison would have misleadingly shown decline across all categories due to a seasonal confound
13. Business Recommendations
Prioritize supply reliability and inventory buffers for the top-10 revenue products
Trigger immediate replenishment review for the 9 at-risk top-20 products
Build seasonal (Q4) safety-stock buffers rather than a flat year-round policy
Run clearance/markdown campaigns on slow-moving, excess-inventory SKUs
Validate discount ROI against margin impact before scaling promotions
Investigate the Central region's lower revenue share (demand vs. fulfillment gap)
14. Limitations
Data is synthetic; patterns are realistic but not real market data
Cost is modeled as a flat 60% of unit price (no real COGS data)
Forecasting covers only the top 10 products by revenue, not the full catalog
Safety stock assumes a fixed 95% service level for all products; a real business might vary this by product criticality
SQL-side average demand differs slightly from the Python version because zero-sale days aren't represented as rows in FactSales
15. Future Improvements
Extend forecasting to all products or use a hierarchical model
Incorporate real supplier lead-time variability instead of a fixed value per product
Add customer-level segmentation (RFM analysis)
Automate the pipeline with a scheduled ETL job instead of manual CSV imports
Vary the service level by product priority/margin instead of a flat 95%
