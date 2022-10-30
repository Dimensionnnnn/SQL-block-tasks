
-- Нужно ускорить запросы ниже любыми способами
-- Можно менять текст самого запроса или добавилять новые индексы
-- Схему БД менять нельзя
-- В овете пришлите итоговый запрос и все что было создано для его ускорения

-- Задача 1
--DROP INDEX ix_SessionStart ON Marketing.WebLog
CREATE INDEX ix_SessionStart ON Marketing.WebLog(SessionStart, ServerID, SessionID, UserName)

SELECT TOP(5000) wl.SessionID, wl.ServerID, wl.UserName 
FROM Marketing.WebLog AS wl
WHERE wl.SessionStart >= '2010-08-30 16:27'
ORDER BY wl.SessionStart, wl.ServerID;
GO

-- Задача 2
--DROP INDEX ix_StatePostalCode ON Marketing.PostalCode
CREATE INDEX ix_StatePostalCode ON Marketing.PostalCode(StateCode, PostalCode)

SELECT PostalCode, Country
FROM Marketing.PostalCode 
WHERE StateCode = 'KY'
ORDER BY StateCode, PostalCode;
GO

-- Задача 3

--DROP INDEX ix_LastName_FirstName ON Marketing.Prospect
CREATE INDEX ix_LastName_FirstName ON Marketing.Prospect(LastName, FirstName)

--DROP INDEX ix_LastName ON MArketing.Prospect
CREATE INDEX ix_LastName ON Marketing.Prospect(LastName)

SELECT prosp.LastName, prosp.FirstName
FROM Marketing.Prospect AS prosp
ORDER BY LastName, FirstName

SELECT *
FROM Marketing.Prospect WITH (INDEX = ix_LastName)
WHERE LastName = N'Smith'

-- Задача 4
--DROP INDEX ix_MarketingProduct ON Marketing.Product
CREATE INDEX ix_MarketingProduct ON Marketing.Product (SubcategoryID)
INCLUDE (ProductModelID) WITH(DROP_EXISTING = ON)

SELECT
	c.CategoryName,
	sc.SubcategoryName,
	pm.ProductModel,
	COUNT(p.ProductID) AS ModelCount
FROM Marketing.ProductModel pm
	JOIN Marketing.Product p
		ON p.ProductModelID = pm.ProductModelID
	JOIN Marketing.Subcategory sc
		ON sc.SubcategoryID = p.SubcategoryID
	JOIN Marketing.Category c
		ON c.CategoryID = sc.CategoryID
GROUP BY c.CategoryName,
	sc.SubcategoryName,
	pm.ProductModel
HAVING COUNT(p.ProductID) > 1