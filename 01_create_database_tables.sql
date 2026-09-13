-- 1. Database
CREATE DATABASE EcommerceAnalytics;
GO
USE EcommerceAnalytics;
GO

-- 2. Staging table (matches ecommerce_clean.csv exactly)
CREATE TABLE StagingRaw (
    OrderID         VARCHAR(20),
    OrderDate       DATE,
    ProductID       VARCHAR(20),
    ProductName     VARCHAR(100),
    Category        VARCHAR(50),
    SubCategory     VARCHAR(50),
    Quantity        INT,
    UnitPrice       DECIMAL(10,2),
    Discount        DECIMAL(5,2),
    CustomerID      VARCHAR(20),
    Region          VARCHAR(50),
    InventoryAtStart INT,
    ReorderPoint    INT,
    LeadTimeDays    INT,
    SupplierID      VARCHAR(20),
    Revenue         DECIMAL(12,2),
    DiscountAmount  DECIMAL(12,2),
    NetRevenue      DECIMAL(12,2),
    Cost            DECIMAL(12,2),
    Profit          DECIMAL(12,2),
    ProfitMargin    DECIMAL(6,4),
    [Year]          INT,
    [Month]         INT,
    MonthName       VARCHAR(10),
    Week            INT,
    DayOfWeek       VARCHAR(10),
    Quarter         INT
);
GO

-- 3. Dimension tables
CREATE TABLE DimProduct (
    ProductID     VARCHAR(20) PRIMARY KEY,
    ProductName   VARCHAR(100),
    Category      VARCHAR(50),
    SubCategory   VARCHAR(50),
    SupplierID    VARCHAR(20),
    ReorderPoint  INT,
    LeadTimeDays  INT
);

CREATE TABLE DimRegion (
    RegionID    INT IDENTITY(1,1) PRIMARY KEY,
    RegionName  VARCHAR(50) UNIQUE
);

CREATE TABLE DimCustomer (
    CustomerID  VARCHAR(20) PRIMARY KEY
);

CREATE TABLE DimDate (
    DateKey     DATE PRIMARY KEY,
    [Year]      INT,
    [Month]     INT,
    MonthName   VARCHAR(10),
    Week        INT,
    DayOfWeek   VARCHAR(10),
    Quarter     INT
);
GO

-- 4. Fact table
CREATE TABLE FactSales (
    OrderLineID     INT IDENTITY(1,1) PRIMARY KEY,
    OrderID         VARCHAR(20),
    ProductID       VARCHAR(20) FOREIGN KEY REFERENCES DimProduct(ProductID),
    DateKey         DATE FOREIGN KEY REFERENCES DimDate(DateKey),
    CustomerID      VARCHAR(20) FOREIGN KEY REFERENCES DimCustomer(CustomerID),
    RegionID        INT FOREIGN KEY REFERENCES DimRegion(RegionID),
    Quantity        INT,
    UnitPrice       DECIMAL(10,2),
    Discount        DECIMAL(5,2),
    Revenue         DECIMAL(12,2),
    DiscountAmount  DECIMAL(12,2),
    NetRevenue      DECIMAL(12,2),
    Cost            DECIMAL(12,2),
    Profit          DECIMAL(12,2),
    ProfitMargin    DECIMAL(6,4),
    InventoryAtStart INT
);
GO

-- 5. Indexes for common query patterns
CREATE NONCLUSTERED INDEX IX_FactSales_ProductID ON FactSales(ProductID);
CREATE NONCLUSTERED INDEX IX_FactSales_DateKey ON FactSales(DateKey);
CREATE NONCLUSTERED INDEX IX_FactSales_RegionID ON FactSales(RegionID);
GO