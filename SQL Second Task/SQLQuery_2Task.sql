USE master
GO

CREATE DATABASE Sales;

USE Sales
GO

CREATE SCHEMA Person
GO

CREATE TABLE Person.CustomerInfo(
		CustomerID int IDENTITY(1,1) NOT NULL,
		LastName nvarchar(50) NOT NULL,
		MiddleName nvarchar(50) NULL,
		FirstName nvarchar(50) NOT NULL,
		Gender nchar(1) NOT NULL,
		City nvarchar(20) NOT NULL,
		Address nvarchar(50) NOT NULL,
		PRIMARY KEY(CustomerID))
GO

CREATE SCHEMA Sales
GO

CREATE TABLE Sales.SalesOrderHeader(
		OrderID int IDENTITY(1,1) NOT NULL,
		CustomerID int NOT NULL,
		OrderDate date NOT NULL,
		TotalPrice money NOT NULL,
		PRIMARY KEY(OrderID))
GO

CREATE TABLE Sales.SalesOrderDetail(
		OrderDetailID int IDENTITY(1,1) NOT NULL,
		OrderID int NOT NULL,
		ProductID int NOT NULL,
		UnitPrice money NOT NULL,
		ProductQty int NOT NULL,
		PRIMARY KEY(OrderDetailID))
GO

CREATE SCHEMA Production
GO

CREATE TABLE Production.Product(
		ProductID int IDENTITY(1,1) NOT NULL,
		ProductName nvarchar(50) NOT NULL,
		UnitPrice money NOT NULL,
		PRIMARY KEY(ProductID))
GO

ALTER TABLE Sales.SalesOrderHeader
	ADD CONSTRAINT FK_OrderHeader_CustomerID FOREIGN KEY (CustomerID)
		REFERENCES Person.CustomerInfo (CustomerID)
		ON DELETE CASCADE
		ON UPDATE CASCADE
GO

ALTER TABLE Sales.SalesOrderDetail
	ADD CONSTRAINT FK_OrderDetail_OrderID FOREIGN KEY (OrderID)
		REFERENCES Sales.SalesOrderHeader (OrderID)
		ON DELETE CASCADE
		ON UPDATE CASCADE
GO

ALTER TABLE Sales.SalesOrderDetail
	ADD CONSTRAINT FK_OrderDetail_ProductID FOREIGN KEY (ProductID)
		REFERENCES Production.Product (ProductID)
		ON DELETE CASCADE
		ON UPDATE CASCADE
GO


