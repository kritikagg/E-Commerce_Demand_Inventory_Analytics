-- Total revenue, quantity, orders, AOV
SELECT
    SUM(NetRevenue) AS TotalRevenue,
    SUM(Quantity) AS TotalUnits,
    COUNT(DISTINCT OrderID) AS TotalOrders,
    SUM(NetRevenue) / COUNT(DISTINCT OrderID) AS AvgOrderValue
FROM FactSales;

-- Revenue by category
SELECT p.Category, SUM(f.NetRevenue) AS Revenue
FROM FactSales f
JOIN DimProduct p ON f.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY Revenue DESC;

-- Monthly revenue and demand (using DimDate)
SELECT d.[Year], d.[Month], d.MonthName,
       SUM(f.NetRevenue) AS Revenue,
       SUM(f.Quantity) AS UnitsSold
FROM FactSales f
JOIN DimDate d ON f.DateKey = d.DateKey
GROUP BY d.[Year], d.[Month], d.MonthName
ORDER BY d.[Year], d.[Month];

-- Regional performance
SELECT r.RegionName, SUM(f.NetRevenue) AS Revenue, SUM(f.Quantity) AS Units
FROM FactSales f
JOIN DimRegion r ON f.RegionID = r.RegionID
GROUP BY r.RegionName
ORDER BY Revenue DESC;

-- Top 10 products by revenue, with rank
WITH ProductRevenue AS (
    SELECT p.ProductName, SUM(f.NetRevenue) AS Revenue
    FROM FactSales f
    JOIN DimProduct p ON f.ProductID = p.ProductID
    GROUP BY p.ProductName
)
SELECT TOP 10 ProductName, Revenue,
       RANK() OVER (ORDER BY Revenue DESC) AS RevenueRank
FROM ProductRevenue
ORDER BY Revenue DESC;

-- Slow-moving products (bottom 10 by units sold)
SELECT TOP 10 p.ProductName, SUM(f.Quantity) AS UnitsSold
FROM FactSales f
JOIN DimProduct p ON f.ProductID = p.ProductID
GROUP BY p.ProductName
ORDER BY UnitsSold ASC;

-- Inventory-risk products (current stock below reorder point, using latest known inventory snapshot per product)
WITH LatestInventory AS (
    SELECT ProductID, InventoryAtStart,
           ROW_NUMBER() OVER (PARTITION BY ProductID ORDER BY DateKey DESC) AS rn
    FROM FactSales
)
SELECT p.ProductName, li.InventoryAtStart, p.ReorderPoint,
       CASE WHEN li.InventoryAtStart < p.ReorderPoint THEN 'Below Reorder Point' ELSE 'OK' END AS Status
FROM LatestInventory li
JOIN DimProduct p ON li.ProductID = p.ProductID
WHERE li.rn = 1
ORDER BY Status DESC;

-- Profit and margin by category
SELECT p.Category,
       SUM(f.Profit) AS TotalProfit,
       SUM(f.Profit) / NULLIF(SUM(f.NetRevenue), 0) AS AvgMargin
FROM FactSales f
JOIN DimProduct p ON f.ProductID = p.ProductID
GROUP BY p.Category
ORDER BY TotalProfit DESC;
