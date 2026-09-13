INSERT INTO StagingRaw SELECT * FROM StagingRaw_Import

--to see the duplicate rows

SELECT 
    ProductID,
    COUNT(*) AS NumberOfRows
FROM StagingRaw
GROUP BY ProductID
HAVING COUNT(*) > 1
ORDER BY NumberOfRows DESC;

SELECT 
    ProductID,
    COUNT(DISTINCT ProductName) AS ProductNames,
    COUNT(DISTINCT Category) AS Categories,
    COUNT(DISTINCT SubCategory) AS SubCategories,
    COUNT(DISTINCT SupplierID) AS Suppliers,
    COUNT(DISTINCT ReorderPoint) AS ReorderPoints,
    COUNT(DISTINCT LeadTimeDays) AS LeadTimes
FROM StagingRaw
GROUP BY ProductID
HAVING 
    COUNT(DISTINCT ProductName) > 1
    OR COUNT(DISTINCT Category) > 1
    OR COUNT(DISTINCT SubCategory) > 1
    OR COUNT(DISTINCT SupplierID) > 1
    OR COUNT(DISTINCT ReorderPoint) > 1
    OR COUNT(DISTINCT LeadTimeDays) > 1;


USE EcommerceAnalytics;
GO

-- ============================================
-- 1. PRODUCT DIMENSION
-- Keep exactly one row per ProductID
-- ============================================

WITH ProductDedup AS (
    SELECT
        ProductID,
        ProductName,
        Category,
        SubCategory,
        SupplierID,
        ReorderPoint,
        LeadTimeDays,
        ROW_NUMBER() OVER (
            PARTITION BY ProductID
            ORDER BY OrderDate
        ) AS rn
    FROM StagingRaw
)
INSERT INTO DimProduct
(
    ProductID,
    ProductName,
    Category,
    SubCategory,
    SupplierID,
    ReorderPoint,
    LeadTimeDays
)
SELECT
    ProductID,
    ProductName,
    Category,
    SubCategory,
    SupplierID,
    ReorderPoint,
    LeadTimeDays
FROM ProductDedup
WHERE rn = 1;


-- ============================================
-- 2. REGION DIMENSION
-- ============================================

INSERT INTO DimRegion (RegionName)
SELECT DISTINCT Region
FROM StagingRaw;


-- ============================================
-- 3. CUSTOMER DIMENSION
-- ============================================

INSERT INTO DimCustomer (CustomerID)
SELECT DISTINCT CustomerID
FROM StagingRaw;


-- ============================================
-- 4. DATE DIMENSION
-- ============================================

INSERT INTO DimDate
(
    DateKey,
    [Year],
    [Month],
    MonthName,
    Week,
    DayOfWeek,
    Quarter
)
SELECT DISTINCT
    OrderDate,
    [Year],
    [Month],
    MonthName,
    Week,
    DayOfWeek,
    Quarter
FROM StagingRaw;


-- ============================================
-- 5. FACT TABLE
-- ============================================

INSERT INTO FactSales
(
    OrderID,
    ProductID,
    DateKey,
    CustomerID,
    RegionID,
    Quantity,
    UnitPrice,
    Discount,
    Revenue,
    DiscountAmount,
    NetRevenue,
    Cost,
    Profit,
    ProfitMargin,
    InventoryAtStart
)
SELECT
    s.OrderID,
    s.ProductID,
    s.OrderDate,
    s.CustomerID,
    r.RegionID,
    s.Quantity,
    s.UnitPrice,
    s.Discount,
    s.Revenue,
    s.DiscountAmount,
    s.NetRevenue,
    s.Cost,
    s.Profit,
    s.ProfitMargin,
    s.InventoryAtStart
FROM StagingRaw s
JOIN DimRegion r
    ON r.RegionName = s.Region;
GO

--verification

SELECT COUNT(*) AS StagingRows
FROM StagingRaw;

SELECT COUNT(*) AS ProductRows
FROM DimProduct;

SELECT COUNT(*) AS RegionRows
FROM DimRegion;

SELECT COUNT(*) AS CustomerRows
FROM DimCustomer;

SELECT COUNT(*) AS DateRows
FROM DimDate;

SELECT COUNT(*) AS FactRows
FROM FactSales;

USE EcommerceAnalytics;
GO

--blunder: staging raw has duplicate rows since the data got inserted twice
-- script to fix the error

SELECT 
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT OrderID) AS UniqueOrders
FROM StagingRaw;

DELETE FROM FactSales;
GO

WITH DuplicateRows AS
(
    SELECT *,
           ROW_NUMBER() OVER
           (
               PARTITION BY
                   OrderID,
                   OrderDate,
                   ProductID,
                   ProductName,
                   Category,
                   SubCategory,
                   Quantity,
                   UnitPrice,
                   Discount,
                   CustomerID,
                   Region,
                   InventoryAtStart,
                   ReorderPoint,
                   LeadTimeDays,
                   SupplierID,
                   Revenue,
                   DiscountAmount,
                   NetRevenue,
                   Cost,
                   Profit,
                   ProfitMargin,
                   [Year],
                   [Month],
                   MonthName,
                   Week,
                   DayOfWeek,
                   Quarter
               ORDER BY (SELECT NULL)
           ) AS rn
    FROM StagingRaw
)
DELETE FROM DuplicateRows
WHERE rn > 1;
GO

SELECT COUNT(*) AS StagingRows
FROM StagingRaw;

SELECT 
    COUNT(*) AS TotalRows,
    COUNT(DISTINCT OrderID) AS UniqueOrders
FROM StagingRaw;

INSERT INTO FactSales
(
    OrderID,
    ProductID,
    DateKey,
    CustomerID,
    RegionID,
    Quantity,
    UnitPrice,
    Discount,
    Revenue,
    DiscountAmount,
    NetRevenue,
    Cost,
    Profit,
    ProfitMargin,
    InventoryAtStart
)
SELECT
    s.OrderID,
    s.ProductID,
    s.OrderDate,
    s.CustomerID,
    r.RegionID,
    s.Quantity,
    s.UnitPrice,
    s.Discount,
    s.Revenue,
    s.DiscountAmount,
    s.NetRevenue,
    s.Cost,
    s.Profit,
    s.ProfitMargin,
    s.InventoryAtStart
FROM StagingRaw s
JOIN DimRegion r
    ON r.RegionName = s.Region;
GO

-- verification 

SELECT COUNT(*) AS StagingRows
FROM StagingRaw;

SELECT COUNT(*) AS FactRows
FROM FactSales;

SELECT COUNT(*) AS ProductRows
FROM DimProduct;

SELECT COUNT(*) AS RegionRows
FROM DimRegion;

SELECT COUNT(*) AS CustomerRows
FROM DimCustomer;

SELECT COUNT(*) AS DateRows
FROM DimDate;

