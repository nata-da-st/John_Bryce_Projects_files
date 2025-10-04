USE WideWorldImporters
/*
1 
*/
GO

 WITH CTE AS
(SELECT YEAR(i.InvoiceDate) AS InvoiceYear
		,SUM (il.ExtendedPrice- il.TaxAmount) AS IncomePerYear
		,COUNT (DISTINCT MONTH (i.InvoiceDate)) AS NumberOfDistinctMonth
		,SUM (il.ExtendedPrice- il.TaxAmount)*12/COUNT (DISTINCT MONTH (i.InvoiceDate)) AS YearlyLinearIncome	
		,LAG (SUM (il.ExtendedPrice- il.TaxAmount)*12/COUNT (DISTINCT MONTH (i.InvoiceDate))) OVER (ORDER BY YEAR(i.InvoiceDate)) AS LastYearLinearIncome
FROM  Sales.Invoices i JOIN sales.InvoiceLines il
ON il.InvoiceID=i.InvoiceID
GROUP BY  YEAR(i.InvoiceDate))
SELECT	 InvoiceYear
		 ,FORMAT (IncomePerYear,'#,#.00') AS IncomePerYear
		 ,NumberOfDistinctMonth
		 ,FORMAT (YearlyLinearIncome,'#,#.00') AS YearlyLinearIncome
		,CAST (ROUND ((YearlyLinearIncome/ LastYearLinearIncome -1)*100, 2)AS float) AS GrowthRate
 FROM CTE

 GO
/*
2  
*/
 
 WITH CTE AS 
 (SELECT YEAR (i.InvoiceDate) AS TheYear
		,DATEPART (Q, i.InvoiceDate) AS TheQuarter
		,c.CustomerName
		,SUM(il.ExtendedPrice-il.TaxAmount ) AS IncomePerQuarterYear
 FROM Sales.Customers c JOIN Sales.Invoices i
 ON c.CustomerID =  i.CustomerID
 JOIN Sales.InvoiceLines il
 ON i.InvoiceID=il.InvoiceID
 GROUP BY YEAR (i.InvoiceDate)  
		,DATEPART (Q, i.InvoiceDate)  
		,c.CustomerName),
RANK_CUST AS
(SELECT *
	,DENSE_RANK () OVER (PARTITION BY TheYear, TheQuarter ORDER BY IncomePerQuarterYear DESC ) AS DNR
FROM CTE)
SELECT *
FROM RANK_CUST
WHERE DNR <=5
 
 /*
3 
*/

SELECT  TOP 10 with ties si.StockItemID
	,si.StockItemName
	,SUM (il.ExtendedPrice-il.TaxAmount) AS TotalProfit
FROM Warehouse.StockItems si JOIN Sales.InvoiceLines il
ON si.StockItemID=il.StockItemID
GROUP BY si.StockItemID
	,si.StockItemName
ORDER BY TotalProfit DESC



 /*
4 
*/


SELECT ROW_NUMBER () OVER (ORDER BY (si.RecommendedRetailPrice -si.UnitPrice) DESC) AS Rn
	,si.StockItemID
	,si.StockItemName
	,si.UnitPrice
	,si.RecommendedRetailPrice
	,si.RecommendedRetailPrice -si.UnitPrice AS NominalProductProfit
	,DENSE_RANK () OVER (ORDER BY (si.RecommendedRetailPrice -si.UnitPrice) DESC) AS DNR
FROM Warehouse.StockItems si
WHERE si.ValidTo > GETDATE ()


 /*
5 
*/

SELECT CONCAT (s.SupplierID,' ','-',' ',s.SupplierName ) AS SupplierDetails
		,STRING_AGG ( CAST(si.StockItemID AS VARCHAR ) +' '+ si.StockItemName, ' / ,') AS ProductDetails
FROM Purchasing.Suppliers s JOIN Warehouse.StockItems si
ON s.SupplierID=si.SupplierID
GROUP BY s.SupplierID,s.SupplierName 
ORDER BY s.SupplierID


 /*
6 
*/

GO

CREATE VIEW V_TOP5_CUSTUMERS
AS
SELECT TOP 5 WITH TIES c.CustomerID
	,ac.CityName
	,acn.CountryName
	,acn.Continent
	,acn.Region
	,SUM( il.ExtendedPrice) AS TotalExtendedPrice
FROM Sales.Customers c JOIN Application.Cities ac
ON c.PostalCityID =ac.CityID
JOIN Application.StateProvinces asp
ON ac.StateProvinceID =asp.StateProvinceID
JOIN Application.Countries acn
ON asp.CountryID=acn.CountryID
JOIN Sales.Invoices i
ON c.CustomerID=i.CustomerID
JOIN Sales.InvoiceLines il
ON i.InvoiceID=il.InvoiceID
GROUP BY c.CustomerID
	,ac.CityName
	,acn.CountryName
	,acn.Continent
	,acn.Region
ORDER BY  TotalExtendedPrice DESC 

GO

SELECT v.CustomerID
	,v.CityName
	,v.CountryName
	,v.Continent
	,v.Region
	,FORMAT (v.TotalExtendedPrice,'#,#.00') AS TotalExtendedPrice
FROM V_TOP5_CUSTUMERS v
 

 GO




-- /*
--7   
--*/

GO 

CREATE VIEW v_Monthly_Sailes
AS
WITH CTE AS
 (SELECT YEAR (i.InvoiceDate) AS InvoiceYear
	,MONTH (i.InvoiceDate)  AS InvoiceMonth
	,SUM (il.ExtendedPrice-il.TaxAmount)  AS MonthlyTotal
FROM Sales.Invoices i JOIN Sales.InvoiceLines il
 ON i.InvoiceID = il.InvoiceID
  GROUP BY YEAR (i.InvoiceDate) 
	,MONTH (i.InvoiceDate)),
CumulativeTotal AS
(SELECT InvoiceYear
	,InvoiceMonth 
	,MonthlyTotal
	,SUM (MonthlyTotal) OVER (PARTITION BY InvoiceYear ORDER BY InvoiceMonth  
			ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )  AS CumulativeTotal
FROM CTE )
SELECT InvoiceYear
	,InvoiceMonth
	,MonthlyTotal
	,CumulativeTotal
FROM CumulativeTotal


WITH Combined AS
(SELECT InvoiceYear
	,CAST (InvoiceMonth AS VARCHAR) AS InvoiceMonth
	,FORMAT (MonthlyTotal, '#,#.00') AS MonthlyTotal
	,FORMAT (CumulativeTotal, '#,#.00') AS CumulativeTotal
	,ROW_NUMBER () OVER (PARTITION BY InvoiceYear ORDER BY InvoiceMonth) AS RN
FROM v_Monthly_Sailes
UNION  ALL
SELECT InvoiceYear
		,'Grand Total'
       ,FORMAT(SUM(MonthlyTotal), '#,#.00') 
        ,FORMAT(SUM(MonthlyTotal), '#,#.00') 
        ,13 AS RN
    FROM v_MonthlySalesRaw
    GROUP BY InvoiceYear)
SELECT InvoiceYear
	,InvoiceMonth
	,MonthlyTotal
	,CumulativeTotal
FROM Combined
ORDER BY InvoiceYear,RN


/*
8
*/

WITH CTE AS
(SELECT YEAR (o.OrderDate ) AS Order_Year
	,MONTH (o.OrderDate ) AS Order_Month
	,o.OrderID
	 FROM Sales.Orders o) 
SELECT Order_Month, [2013],[2014],[2015],[2016] 
FROM CTE
PIVOT (COUNT(OrderID) FOR Order_Year IN ([2013],[2014],[2015],[2016]) ) pvt
ORDER BY Order_Month



/*
9
*/

GO

CREATE VIEW v_Custumers_Orders AS
SELECT o.CustomerID
	, c.CustomerName
	, o.OrderDate
	, LAG (o.OrderDate) OVER (PARTITION BY o.CustomerID ORDER BY  o.OrderDate) AS PreviousOrderDate
	,DATEDIFF (dd,LAG (o.OrderDate) OVER (PARTITION BY o.CustomerID ORDER BY  o.OrderDate),o.OrderDate)
			AS DaysDiff
	,MAX (o.OrderDate) OVER (PARTITION BY o.CustomerID) AS LastCustOrderDate
FROM Sales.Orders o JOIN Sales.Customers c
ON o.CustomerID= c.CustomerID


WITH CTE AS
(SELECT CustomerID
	, CustomerName
	, OrderDate
	,PreviousOrderDate
	,AVG (DaysDiff) OVER ( PARTITION BY CustomerID ) AS AvgDaysBetweenOrders
	,LastCustOrderDate
	,MAX (OrderDate) OVER () AS LastOrderDateAll
	,DATEDIFF (dd,LastCustOrderDate, MAX (OrderDate) OVER () ) AS DaysSinceLastOrser
FROM  v_Custumers_Orders)
SELECT *
	,IIF(DATEDIFF(dd,LastCustOrderDate,LastOrderDateAll) >AvgDaysBetweenOrders*2,'Potential Chum','Active') AS CustumerStatus
FROM CTE 



/*
10
*/


GO
CREATE VIEW v_Cutumer_Distribution AS

WITH CTE AS 
 ( SELECT  cc.CustomerCategoryName,
    CASE 
      WHEN c.CustomerName LIKE 'Wingtip%' THEN 'Wingtip'
      WHEN c.CustomerName LIKE 'Tailspin%' THEN 'Tailspin'
      ELSE CustomerName   
    END AS UpdatedCustName
  FROM Sales.Customers c
  JOIN Sales.CustomerCategories cc 
    ON cc.CustomerCategoryID = c.CustomerCategoryID ),
CustCount AS 
(SELECT DISTINCT CustomerCategoryName
	,UpdatedCustName
  FROM CTE )
 SELECT 
	CustomerCategoryName
	,COUNT(*) AS CustomerCOUNT
FROM CustCount
GROUP BY CustomerCategoryName
 

 SELECT v.CustomerCategoryName
		,v.CustomerCOUNT
		,SUM (CustomerCOUNT) OVER () AS TotalCustCount
		,CONCAT (ROUND (CAST (v.CustomerCOUNT AS FLOAT)/(SUM (CustomerCOUNT) OVER ())*100,2),'%')  AS DistributionFactor
 FROM v_Cutumer_Distribution v

