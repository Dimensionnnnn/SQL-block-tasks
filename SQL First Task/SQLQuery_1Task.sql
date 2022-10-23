USE AdventureWorks2019
GO

--2 задание--
SELECT year(ModifiedDate) AS [Year], month(ModifiedDate) AS [Month], SUM(SubTotal) AS [TotalAmount]
FROM Sales.SalesOrderHeader

GROUP BY year(ModifiedDate), month(ModifiedDate)
ORDER BY year(ModifiedDate), month(ModifiedDate)


--3 задание--
SELECT TOP 10 [City], COUNT (BusinessEntityID) as [Priority]
FROM Sales.vIndividualCustomer
WHERE City IN (SELECT City
			  FROM Person.Address
			  EXCEPT
			  SELECT City FROM Sales.vStoreWithAddresses)

GROUP BY City
ORDER BY Priority desc


--4 задание--
SELECT Sales.SalesOrderDetail.SalesOrderID, Sales.SalesOrderDetail.ProductID, OrderQty, Customer.PersonID
INTO #TmpRaw
FROM Sales.SalesOrderDetail

JOIN Sales.SalesOrderHeader
ON SalesOrderDetail.SalesOrderID = SalesOrderHeader.SalesOrderID

JOIN Sales.Customer
ON Customer.CustomerID = SalesOrderHeader.CustomerID

SELECT PersonID, ProductID, SUM(OrderQty) AS Total
INTO #TmpCounted FROM #TmpRaw
GROUP BY PersonID, ProductID

SELECT LastName, FirstName, Name, Total
FROM Person.Person

JOIN #TmpCounted
ON #TmpCounted.PersonID = Person.Person.BusinessEntityID

JOIN Production.Product
ON Product.ProductID = #TmpCounted.ProductID
WHERE Total > 15
ORDER BY Total desc

DROP TABLE #TmpRaw
DROP TABLE #TmpCounted
GO


--5 задание--
SELECT OrderDate, LastName, FirstName, STRING_AGG(CONVERT(NVARCHAR(max), CONCAT(Name, ' ', N'Количество: ', OrderQty, N' шт.')), CHAR(13)) AS OrderContent
FROM (SELECT MIN(OrderDate) AS FirstOrder, BusinessEntityID
		FROM Sales.SalesOrderHeader
		JOIN Person.Person
		ON Person.BusinessEntityID = SalesOrderHeader.CustomerID
		GROUP BY BusinessEntityID) AS PersonDate

JOIN Person.Person ON PersonDate.BusinessEntityID = Person.BusinessEntityID

JOIN Sales.SalesOrderHeader AS SalesOrder
ON (PersonDate.BusinessEntityID = SalesOrder.CustomerID
	AND PersonDate.FirstOrder = SalesOrder.OrderDate)

JOIN Sales.SalesOrderDetail AS OrderDetails
ON (OrderDetails.SalesOrderID = SalesOrder.SalesOrderID)

JOIN Production.Product ON OrderDetails.ProductID = Product.ProductID

GROUP BY Person.BusinessEntityID, OrderDate, LastName, FirstName
ORDER BY OrderDate desc


--6 задание--
SELECT CONCAT(m.LastName, ' ', LEFT(m.FirstName,1),'.', LEFT(m.MiddleName,1),'.') as ManagerName, m.HireDate as MangerHireDate, m.BirthDate as ManagerBirthDate,
       CONCAT(w.LastName, ' ', LEFT(w.FirstName,1),'.', LEFT(w.MiddleName,1),'.') as WorkerName, w.HireDate as WorkerHireDate, w.BirthDate as WorkerHireDate

FROM (SELECT Person.BusinessEntityID, LastName, MiddleName, FirstName, HireDate, BirthDate, OrganizationLevel
		FROM Person.Person
		JOIN HumanResources.Employee
		ON Person.BusinessEntityID = Employee.BusinessEntityID) as m

JOIN (SELECT Person.BusinessEntityID, LastName, MiddleName, FirstName, HireDate, BirthDate, OrganizationLevel
		FROM Person.Person
		JOIN HumanResources.Employee
		ON Person.BusinessEntityID = Employee.BusinessEntityID) as w
ON (m.BirthDate > w.BirthDate AND m.HireDate > w.HireDate AND (m.OrganizationLevel = (w.OrganizationLevel - 1)))

ORDER BY m.OrganizationLevel, m.LastName, w.LastName


--7 задание--
CREATE PROCEDURE CountOfSingleMenInInterval(
	@dateFrom date,
	@dateTo date,
	@count int OUTPUT
	)
AS
BEGIN
	SELECT HumanResources.Employee.BusinessEntityID, FirstName, MiddleName, LastName, BirthDate, NationalIDNumber, OrganizationNode, MaritalStatus, Gender, HireDate
	FROM HumanResources.Employee, Person.Person
	WHERE (Gender='M' AND MaritalStatus='S' AND @dateFrom < BirthDate AND BirthDate < @dateTo) AND HumanResources.Employee.BusinessEntityID = Person.BusinessEntityID;
		
	SELECT @count = COUNT(BusinessEntityID)
	FROM HumanResources.Employee
	WHERE (Gender='M' AND MaritalStatus='S' AND @dateFrom < BirthDate AND BirthDate < @dateTo); 
END;

CREATE TABLE #TmpResult(
	BusinessEntityID int,
	FirstName nvarchar(50),
	MiddleName nvarchar(50),
	LastName nvarchar(50),
	BirthDate date,
	NationalIDNumber nvarchar(50),
	OrganizationNode hierarchyid,
	MaritalStatus nchar(1),
	Gender nchar(1),
	HireDate date
);

declare @df date = '1970-01-01';
declare @dt date = '1980-01-01';
declare @result int;
INSERT INTO #TmpResult
EXEC CountOfSingleMenInInterval @df, @dt, @result output
SELECT @result as CountedBachelors
SELECT * FROM #TmpResult

DROP PROCEDURE CountOfSingleMenInInterval
DROP TABLE #TmpResult
GO