WITH sales_data AS (
    SELECT 
        si.[Stock Item] AS ProductName,
        SUM(fo.Quantity) AS SalesQuantity,
        SUM(fo.Quantity * fo.[Unit Price]) AS SalesRevenue,
        DATEPART(QUARTER, fo.[Order Date Key]) AS Quarter,
        DATEPART(YEAR, fo.[Order Date Key]) AS Year
    FROM 
        [Fact].[Order] fo
    JOIN 
        [Dimension].[Stock Item] si ON fo.[Stock Item Key] = si.[Stock Item Key]
    GROUP BY 
        si.[Stock Item], 
        DATEPART(QUARTER, fo.[Order Date Key]), 
        DATEPART(YEAR, fo.[Order Date Key])
),
ranked_sales AS (
    SELECT 
        sd.ProductName,
        sd.SalesQuantity,
        sd.SalesRevenue,
        sd.Quarter,
        sd.Year,
        RANK() OVER (
            PARTITION BY sd.Quarter, sd.Year 
            ORDER BY sd.SalesRevenue DESC
        ) AS rank
    FROM 
        sales_data sd
)
SELECT 
    rs.ProductName,
    rs.SalesQuantity,
    rs.SalesRevenue,
    rs.Quarter,
    rs.Year
FROM 
    ranked_sales rs
WHERE 
    rs.rank <= 10
ORDER BY 
    rs.Year, 
    rs.Quarter, 
    rs.rank;