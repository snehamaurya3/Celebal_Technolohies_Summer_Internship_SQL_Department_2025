USE AdventureWorks2022
GO

-- 1. List of all customers
SELECT * FROM Sales.Customer;

-- 2. List of all customers where company name ends with 'N'
SELECT c.CustomerID, s.Name AS CompanyName
FROM Sales.Customer c JOIN Sales.Store s 
ON c.StoreID = s.BusinessEntityID WHERE s.Name LIKE '%N';

-- 3. List of all customers who live in Berlin or London
SELECT * FROM Sales.Customer c JOIN Person.Address a 
ON c.CustomerID = a.AddressID WHERE a.City IN ('Berlin', 'London');

-- 4. List of all customers who live in UK or USA
SELECT * FROM Sales.Customer c JOIN Person.Address a 
ON c.CustomerID = a.AddressID 
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID 
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name IN ('United Kingdom', 'United States');

-- 5. List of all products sorted by product name
SELECT * FROM Production.Product ORDER BY Name;

-- 6. List of all products where product name starts with an 'A'
SELECT * FROM Production.Product WHERE Name LIKE 'A%';

-- 7. List of customers who ever placed an order
SELECT DISTINCT c.CustomerID, c.AccountNumber 
FROM Sales.Customer c 
JOIN Sales.SalesOrderHeader o ON c.CustomerID = o.CustomerID;

-- 8. List of customers who live in London and have bought Chai
SELECT DISTINCT c.CustomerID
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader o ON c.CustomerID = o.CustomerID
JOIN Sales.SalesOrderDetail od ON o.SalesOrderID = od.SalesOrderID
JOIN Production.Product p ON od.ProductID = p.ProductID
JOIN Person.Address a ON c.CustomerID = a.AddressID
WHERE a.City = 'London' AND p.Name = 'Chai';

-- 9. List of customers who never placed an order
SELECT * FROM Sales.Customer
WHERE CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Sales.SalesOrderHeader );

-- 10. List of customers who ordered Tofu
SELECT DISTINCT c.CustomerID 
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader o ON c.CustomerID = o.CustomerID
JOIN Sales.SalesOrderDetail od ON o.SalesOrderID = od.SalesOrderID
JOIN Production.Product p ON od.ProductID = p.ProductID
WHERE p.Name = 'Tofu';

-- 11. Details of first order in the system
SELECT TOP 1 * FROM Sales.SalesOrderHeader ORDER BY OrderDate;

-- 12. Find the details of the most expensive order date
SELECT TOP 1 * FROM Sales.SalesOrderHeader ORDER BY TotalDue DESC;

-- 13. For each order, get the OrderID and average quantity of items in that order
SELECT SalesOrderID, AVG(OrderQty) AS AverageQuantity 
FROM Sales.SalesOrderDetail GROUP BY SalesOrderID;

-- 14. For each order, get the OrderID, minimum quantity, and maximum quantity
SELECT SalesOrderID, MIN(OrderQty) AS MinimumQuantity, MAX(OrderQty) AS MaximumQuantity 
FROM Sales.SalesOrderDetail GROUP BY SalesOrderID;

-- 15. Get a list of all managers and the total number of employees who report to them
SELECT m.BusinessEntityID AS ManagerID, COUNT(e.BusinessEntityID) AS NumOfEmployees 
FROM HumanResources.Employee e
JOIN HumanResources.Employee m ON e.OrganizationNode.GetAncestor(1) = m.OrganizationNode 
GROUP BY m.BusinessEntityID;

-- 16. Get the OrderID and total quantity for each order that has a total quantity greater than 300
SELECT SalesOrderID, SUM(OrderQty) AS TotalQuantity 
FROM Sales.SalesOrderDetail
GROUP BY SalesOrderID HAVING SUM(OrderQty) > 300;

-- 17. List of all orders placed on or after 1996/12/31
SELECT * FROM Sales.SalesOrderHeader WHERE OrderDate >= '1996-12-31';

-- 18. List of all orders shipped to Canada
SELECT * FROM Sales.SalesOrderHeader WHERE ShipToAddressID IN (
    SELECT AddressID FROM Person.Address WHERE StateProvinceID IN (
        SELECT StateProvinceID FROM Person.StateProvince 
        WHERE CountryRegionCode = 'CA'));

-- 19. List of all orders with order total > 200
SELECT * FROM Sales.SalesOrderHeader WHERE TotalDue > 200;

-- 20. List of countries and sales made in each country
SELECT cr.Name AS Country, SUM(soh.TotalDue) AS TotalSales 
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.BillToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name;

-- 21. List of Customer ContactName and number of orders they placed
SELECT p.FirstName + ' ' + p.LastName AS CustomerName, COUNT(soh.SalesOrderID) AS NumberOfOrders 
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID 
GROUP BY p.FirstName, p.LastName;

-- 22. List of customer ContactNames who placed more than 3 orders
SELECT p.FirstName + ' ' + p.LastName AS CustomerName, COUNT(*) AS OrderCount 
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
GROUP BY p.FirstName, p.LastName HAVING COUNT(*) > 3;

--23. List of discontinued products ordered between 1/1/1997 and 1/1/1998
SELECT DISTINCT p.Name AS DiscontinuedProduct, p.SellEndDate, soh.OrderDate 
FROM Production.Product p
JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID = soh.SalesOrderID
WHERE p.SellEndDate IS NOT NULL 
AND soh.OrderDate BETWEEN '1997-01-01' AND '1998-01-01';

-- 24. List of employee FirstName, LastName, Supervisor FirstName, LastName
SELECT e.BusinessEntityID AS EmployeeID, p1.FirstName AS EmployeeFirstName,
    p1.LastName AS EmployeeLastName, p2.FirstName AS SuperviserFirstName, 
    p2.LastName AS SuperviserLastName
FROM HumanResources.Employee e
JOIN Person.Person p1 ON e.BusinessEntityID = p1.BusinessEntityID
LEFT JOIN HumanResources.Employee m ON e.OrganizationNode.GetAncestor(1) = m.OrganizationNode
LEFT JOIN Person.Person p2 ON m.BusinessEntityID = p2.BusinessEntityID;

-- 25. List of Employee IDs and total sales conducted by employee
SELECT soh.SalesPersonID AS EmployeeID, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh 
WHERE soh.SalesPersonID IS NOT NULL GROUP BY soh.SalesPersonID;

-- 26. List of employees whose FirstName contains the character 'a'
SELECT BusinessEntityID, FirstName, LastName
FROM Person.Person WHERE FirstName LIKE '%a%';

-- 27. List of managers with more than four people reporting to them
SELECT e1.BusinessEntityID AS ManagerID, COUNT(*) AS NumberOfReports
FROM HumanResources.Employee e1
JOIN HumanResources.Employee e2 ON e2.OrganizationNode.GetAncestor(1) = e1.OrganizationNode
GROUP BY e1.BusinessEntityID HAVING COUNT(*) > 4;

-- 28. List of Orders and ProductNames
SELECT soh.SalesOrderID, p.Name AS ProductName
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID;

-- 29. List of orders placed by the best customer
WITH BestCustomer AS (
    SELECT TOP 1 CustomerID
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
    ORDER BY SUM(TotalDue) DESC
)
SELECT soh.SalesOrderID, soh.OrderDate, soh.TotalDue
FROM Sales.SalesOrderHeader soh
JOIN BestCustomer bc ON soh.CustomerID = bc.CustomerID;

-- 30. List of orders placed by customers who do not have a Fax number
SELECT soh.SalesOrderID, soh.OrderDate, c.CustomerID
FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
LEFT JOIN Person.PersonPhone pp ON p.BusinessEntityID = pp.BusinessEntityID 
AND pp.PhoneNumberTypeID = 3 
WHERE pp.PhoneNumber IS NULL;

-- 31. List of Postal Codes where the product Tofu was shipped
SELECT DISTINCT a.PostalCode
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
WHERE p.Name = 'Tofu';

-- 32. List of product names that were shipped to France
SELECT DISTINCT p.Name
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
JOIN Person.Address a ON soh.ShipToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
WHERE cr.Name = 'France';

-- 33. List of ProductNames and Categories for the supplier Specialty Biscuits, Ltd.
SELECT p.Name, pc.Name AS Category
FROM Production.Product p
JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
JOIN Purchasing.ProductVendor pv ON p.ProductID = pv.ProductID
JOIN Purchasing.Vendor v ON pv.BusinessEntityID = v.BusinessEntityID
WHERE v.Name = 'Specialty Biscuits, Ltd.';

-- 34. List of products that were never ordered
SELECT p.Name FROM Production.Product p
LEFT JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
WHERE sod.ProductID IS NULL;

-- 35. List of products where UnitsInStock < 10 and UnitsOnOrder = 0
SELECT Name, SafetyStockLevel, ReorderPoint 
FROM Production.Product WHERE SafetyStockLevel < 10 AND ReorderPoint = 0;

-- 36. List of top 10 countries by sales
SELECT TOP 10 cr.Name AS Country, SUM(soh.TotalDue) AS TotalSales
FROM Sales.SalesOrderHeader soh
JOIN Person.Address a ON soh.BillToAddressID = a.AddressID
JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
JOIN Person.CountryRegion cr ON sp.CountryRegionCode = cr.CountryRegionCode
GROUP BY cr.Name ORDER BY TotalSales DESC;

-- 37. Number of orders each employee has taken for customers with CustomerIDs between A and AO
SELECT SalesPersonID, COUNT(*) AS OrderCount
FROM Sales.SalesOrderHeader
WHERE CustomerID IN (SELECT CustomerID FROM Sales.Customer WHERE CustomerID LIKE '[A][A-O]%')
GROUP BY SalesPersonID;

-- 38. Order date of the most expensive order
SELECT TOP 1 OrderDate, TotalDue FROM Sales.SalesOrderHeader ORDER BY TotalDue DESC;

-- 39. Product name and total revenue from that product
SELECT p.Name AS ProductName, SUM(sod.LineTotal) AS Revenue
FROM Sales.SalesOrderDetail sod
JOIN Production.Product p ON sod.ProductID = p.ProductID
GROUP BY p.Name ORDER BY Revenue DESC;

-- 40. SupplierID and number of products offered
SELECT BusinessEntityID AS SupplierID, COUNT(*) AS ProductCount 
FROM Purchasing.ProductVendor GROUP BY BusinessEntityID;

-- 41. Top ten customers based on their business
SELECT TOP 10 c.CustomerID, SUM(soh.TotalDue) AS TotalSpent
FROM Sales.Customer c
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY c.CustomerID ORDER BY TotalSpent DESC;

-- 42. What is the total revenue of the company?
SELECT SUM(TotalDue) AS CompanyRevenue FROM Sales.SalesOrderHeader;