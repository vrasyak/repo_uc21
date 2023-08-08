WITH CTE_Sales AS
(
  SELECT 
    [Stock Item Key], 
    DATEPART(QUARTER, [Order Date Key]) AS OrderQuarter, 
    DATEPART(YEAR, [Order Date Key]) AS OrderYear,
    SUM([Quantity] * [Unit Price]) AS Revenue,
    SUM([Quantity]) AS Quantity
  FROM [Fact].[Order]
  GROUP BY [Stock Item Key], DATEPART(QUARTER, [Order Date Key]), DATEPART(YEAR, [Order Date Key])
),
CTE_Growth AS
(
  SELECT 
    Curr.[Stock Item Key],
    Curr.OrderYear AS CurrentYear,
    Curr.OrderQuarter AS CurrentQuarter,
    Curr.Revenue, 
    Curr.Quantity, 
    CASE 
      WHEN Curr.OrderQuarter = 1 THEN Curr.OrderYear - 1
      ELSE Curr.OrderYear
    END AS PreviousYear,
    CASE 
      WHEN Curr.OrderQuarter = 1 THEN 4
      ELSE Curr.OrderQuarter - 1
    END AS PreviousQuarter,
    (Curr.Revenue - PrevQ.Revenue) / PrevQ.Revenue AS GrowthRevenueRate, 
    (Curr.Quantity - PrevQ.Quantity) / PrevQ.Quantity AS GrowthQuantityRate
  FROM CTE_Sales AS Curr
  LEFT JOIN CTE_Sales AS PrevQ 
    ON Curr.[Stock Item Key] = PrevQ.[Stock Item Key] 
    AND CASE 
          WHEN Curr.OrderQuarter = 1 THEN Curr.OrderYear - 1
          ELSE Curr.OrderYear
        END = PrevQ.OrderYear
    AND CASE 
          WHEN Curr.OrderQuarter = 1 THEN 4
          ELSE Curr.OrderQuarter - 1
        END = PrevQ.OrderQuarter
)
SELECT 
  SI.[Stock Item] AS ProductName,
  CG.GrowthRevenueRate,
  CG.GrowthQuantityRate,
  CG.CurrentQuarter,
  CG.CurrentYear,
  CG.PreviousQuarter,
  CG.PreviousYear
FROM CTE_Growth CG
JOIN [Dimension].[Stock Item] SI ON CG.[Stock Item Key] = SI.[Stock Item Key]
