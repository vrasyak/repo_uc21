WITH RevenueAndQuantity AS (
    SELECT
        si.[Stock Item] AS ProductCategory,
        SUM(o.[Total Including Tax]) AS Revenue,
        SUM(o.Quantity) AS Quantity,
        DATEPART(QUARTER, o.[Order Date Key]) AS Quarter,
        DATEPART(YEAR, o.[Order Date Key]) AS Year
    FROM [Fact].[Order] o
    JOIN [Dimension].[Stock Item] si ON o.[Stock Item Key] = si.[Stock Item Key]
    GROUP BY si.[Stock Item], DATEPART(QUARTER, o.[Order Date Key]), DATEPART(YEAR, o.[Order Date Key])
),

Totals AS (
    SELECT
        DATEPART(QUARTER, o.[Order Date Key]) AS Quarter,
        DATEPART(YEAR, o.[Order Date Key]) AS Year,
        SUM(o.[Total Including Tax]) AS TotalRevenue,
        SUM(o.Quantity) AS TotalQuantity
    FROM [Fact].[Order] o
    GROUP BY DATEPART(QUARTER, o.[Order Date Key]), DATEPART(YEAR, o.[Order Date Key])
)

SELECT
    r.ProductCategory,
    (CAST(r.Revenue AS DECIMAL(18, 4)) / CAST(t.TotalRevenue AS DECIMAL(18, 4))) * 100 AS [TotalRevenuePercentage],
    (CAST(r.Quantity AS DECIMAL(18, 4)) / CAST(t.TotalQuantity AS DECIMAL(18, 4))) * 100 AS [TotalQuantityPercentage],
    r.Quarter,
    r.Year
FROM RevenueAndQuantity r
JOIN Totals t ON r.Quarter = t.Quarter AND r.Year = t.Year
ORDER BY r.Year, r.Quarter, r.ProductCategory;