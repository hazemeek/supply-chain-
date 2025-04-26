-- 1. Inventory Management KPIs

-- Inventory Turnover Ratio Formula:Inventory Turnover = Cost of Goods Sold (COGS)\Average Inventory

SELECT *
FROM Sales.SalesOrderHeader soh JOIN Sales.SalesOrderDetail sod 
ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.ProductInventory pi 
ON sod.ProductID = pi.ProductID

SELECT 
    YEAR(soh.OrderDate) AS Year, 
    SUM(sod.LineTotal) AS COGS,
    sum(pi.Quantity) AS sumInventory,
    SUM(sod.LineTotal) / NULLIF(sum(pi.Quantity), 0) AS InventoryTurnover
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.ProductInventory pi ON sod.ProductID = pi.ProductID
GROUP BY YEAR(soh.OrderDate)


-- Stockout Rate Formula:Stockout Rate = total Stockouts \ Total Orders

SELECT *
FROM Sales.SalesOrderDetail sod
JOIN Production.ProductInventory pi ON sod.ProductID = pi.ProductID

SELECT 
    COUNT(*) AS TotalOrders, 
    SUM(CASE WHEN pi.Quantity = 0 THEN 1 ELSE 0 END) AS StockoutCount,
    (SUM(CASE WHEN pi.Quantity = 0 THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS StockoutRate
FROM Sales.SalesOrderDetail sod
JOIN Production.ProductInventory pi ON sod.ProductID = pi.ProductID

-- 2. Procurement & Supplier KPIs

-- On-Time Delivery Rate Formula:On-Time Delivery = On-Time Deliveries\Total Deliveries

SELECT *
FROM Purchasing.PurchaseOrderHeader poh JOIN Purchasing.PurchaseOrderDetail pod
ON poh.PurchaseOrderID = pod.PurchaseOrderID


  SELECT 
    poh.PurchaseOrderID,
    poh.OrderDate,
    poh.ShipDate,
    DATEDIFF(DAY, poh.OrderDate, poh.ShipDate) AS DaysBetweenOrderAndShip
FROM Purchasing.PurchaseOrderHeader poh
WHERE poh.ShipDate IS NOT NULL

-- Supplier Defect Rate Formula: Supplier Defect Rate = Defective Items\Total Items Received

SELECT *
FROM Purchasing.PurchaseOrderDetail

SELECT 
    COUNT(*) AS TotalItemsReceived,
    SUM(CASE WHEN RejectedQty > 0 THEN RejectedQty ELSE 0 END) AS DefectiveItems,
    (SUM(CASE WHEN RejectedQty > 0 THEN RejectedQty ELSE 0 END) * 100.0) / NULLIF(SUM(ReceivedQty), 0) AS DefectRate
FROM Purchasing.PurchaseOrderDetail

-- 3. Logistics & Distribution KPIs

-- On-Time Delivery Rate Formula: On-Time Delivery = Orders Delivered On-Time\ Total Orders

SELECT *
FROM Sales.SalesOrderHeader soh

SELECT 
    COUNT(*) AS TotalOrders,
    SUM(CASE WHEN soh.ShipDate <= soh.DueDate THEN 1 ELSE 0 END) AS OnTimeDeliveries,
    (SUM(CASE WHEN soh.ShipDate <= soh.DueDate THEN 1 ELSE 0 END) * 100.0) / COUNT(*) AS OnTimeDeliveryRate
FROM Sales.SalesOrderHeader soh

-- Freight Cost per Order
-- Formula: Freight Cost per Order= Total Freight Cost\ Total Orders

SELECT *
FROM Sales.SalesOrderHeader

SELECT 
    SUM(Freight) AS TotalFreightCost,
    COUNT(SalesOrderID) AS TotalOrders,
    SUM(Freight) / COUNT(SalesOrderID) AS FreightCostPerOrder
FROM Sales.SalesOrderHeader

-- 4. Demand & Forecasting KPIs

SELECT *
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID

SELECT 
    YEAR(OrderDate) AS Year, 
    MONTH(OrderDate) AS Month, 
    SUM(LineTotal) AS ActualSales
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Year, Month

-- 5. Financial KPIs

-- Total Supply Chain Cost Formula: Total Supply Chain Cost = Procurement Cost + Production Cost + Transportation Cost + Warehousing Cost

SELECT *
FROM Purchasing.PurchaseOrderDetail pod
JOIN Sales.SalesOrderHeader soh ON soh.SalesOrderID = soh.SalesOrderID

SELECT 
    SUM(pod.LineTotal) AS ProcurementCost,
    SUM(soh.Freight) AS TransportationCost
FROM Purchasing.PurchaseOrderDetail pod
JOIN Sales.SalesOrderHeader soh ON soh.SalesOrderID = soh.SalesOrderID

-- Extract the data from SQL Server then save result as CSV file.

SELECT *
FROM Sales.SalesOrderHeader soh JOIN Sales.SalesOrderDetail sod 
ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.ProductInventory pi 
ON sod.ProductID = pi.ProductID
join Production.Product pp
on pi.ProductID = pp.ProductID
join Production.ProductSubcategory psc
on pp.ProductSubcategoryID = psc.ProductSubcategoryID
join Production.ProductCategory ppc
on psc.ProductCategoryID = ppc.ProductCategoryID
join Sales.SalesTerritory sst
on soh.TerritoryID = sst.TerritoryID


SELECT *
FROM Purchasing.PurchaseOrderHeader poh JOIN Purchasing.PurchaseOrderDetail pod
ON poh.PurchaseOrderID = pod.PurchaseOrderID
join Purchasing.ShipMethod psm
on poh.ShipMethodID = psm.ShipMethodID
join Purchasing.Vendor pv
on poh.VendorID = pv.BusinessEntityID
JOIN Production.ProductInventory pi 
ON pod.ProductID = pi.ProductID
join Production.Product pp
on pi.ProductID = pp.ProductID
join Production.ProductSubcategory psc
on pp.ProductSubcategoryID = psc.ProductSubcategoryID
join Production.ProductCategory ppc
on psc.ProductCategoryID = ppc.ProductCategoryID