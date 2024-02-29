--*************************************************************************--
-- Title: Assignment07
-- Author: TahminaRinger
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2024-02-25,TahminaRinger,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_TahminaRinger')
	 Begin 
	  Alter Database [Assignment07DB_TahminaRinger] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_TahminaRinger;
	 End
	Create Database Assignment07DB_TahminaRinger;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_TahminaRinger;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count], [ReorderLevel]) -- New column added this week
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, UnitsInStock, ReorderLevel
From Northwind.dbo.Products
UNIOn
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, UnitsInStock + 10, ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
UNIOn
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, abs(UnitsInStock - 10), ReorderLevel -- Using this is to create a made up value
From Northwind.dbo.Products
Order By 1, 2
go


-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/********************************* Questions and Answers *********************************/
Print
'NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.
-- <Put Your Code Here> --

-- View all columns in product table
SELECT * FROM vProducts;
GO

--View only the columns from product table we need to use
SELECT ProductName, UnitPrice 
	FROM vProducts;
GO

--Select all names and prices formatted in US currency
SELECT ProductName, FORMAT(UnitPrice, 'C', 'en-US') 
	AS 'US Format'
	FROM vProducts;
GO

--Order the results by ProductNames 
SELECT ProductName, FORMAT(UnitPrice, 'C', 'en-US') 
	AS 'US Format'
	FROM vProducts
ORDER BY ProductName;
GO

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.
-- <Put Your Code Here> --

--Get all Categories
SELECT * FROM vCategories;
GO
--Get all Products
SELECT * FROM vProducts;
GO

--Get the columns needed from category view
SELECT CategoryName 
	FROM vCategories;
GO

--Get the columns needed from Products view
SELECT ProductName, UnitPrice 
	FROM vProducts;
GO

SELECT CategoryName, ProductName, FORMAT(UnitPrice, 'C', 'en-US') 
	AS 'US Format'
	FROM vCategories
	AS C
INNER JOIN vProducts 
	AS P
ON C.CategoryID = P.CategoryID;
GO

--Order results by Category, Product
SELECT CategoryName, ProductName, FORMAT(UnitPrice, 'C', 'en-US') 
	AS 'US Format'
	FROM vCategories
	AS C
INNER JOIN vProducts 
	AS P
ON C.CategoryID = P.CategoryID
ORDER BY CategoryName, ProductName;
GO

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

--Get all Products
SELECT * FROM vProducts;
GO

--Get all Inventories
SELECT * FROM vInventories;
GO

--Get the columns you need from each view
SELECT ProductName
	FROM vProducts;
GO

SELECT InventoryDate, [COUNT]
	FROM vInventories;
GO

-- Get columns needed and join views
SELECT 
	ProductName, 
	InventoryDate = DATENAME(mm, InventoryDate) + ', ' + STR(YEAR(InventoryDate)), 
	[COUNT]
FROM vProducts 
	AS P
INNER JOIN vInventories 
	AS I
ON P.ProductID = I.ProductID;
GO

--Order Results by product name and date
SELECT 
	ProductName, 
	InventoryDate = DATENAME(mm, InventoryDate) + ', ' + STR(YEAR(InventoryDate)), 
	[COUNT]
FROM vProducts 
	AS P
INNER JOIN vInventories 
	AS I
ON P.ProductID = I.ProductID
ORDER BY ProductName, MONTH(InventoryDate);
GO

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --
-- DROP VIEW vProductInventories;
CREATE VIEW vProductInventories 
	AS
SELECT 
	P.ProductName, 
	InventoryDate = DATENAME(mm, I.InventoryDate) + ', ' + STR(YEAR(I.InventoryDate)), 
	I.[Count]
FROM vProducts
	AS P 
INNER JOIN vInventories 
	AS I
ON P.ProductID = I.ProductID;
GO

-- check view
SELECT * FROM vProductInventories;
GO

-- Order view by ProductName and date
ALTER VIEW vProductInventories 
	AS
SELECT TOP 10000
	P.ProductName, 
	InventoryDate = DATENAME(mm, I.InventoryDate) + ', ' + STR(YEAR(I.InventoryDate)), 
	I.[Count]
FROM vProducts
	AS P 
INNER JOIN vInventories 
	AS I
ON P.ProductID = I.ProductID
ORDER BY ProductName, MONTH(InventoryDate);
GO

-- Check that it works: Select * From vProductInventories;

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.
--DROP VIEW vCategoryInventories

-- Get all table columns
SELECT * FROM vCategories;
SELECT * FROM vProducts;
SELECT * FROM vInventories;

-- Get requested columns
SELECT 
	CategoryName 
FROM vCategories;
GO

SELECT 
	InventoryDate, 
	[Count] 
FROM vInventories;
GO

--Create view 
CREATE VIEW vCategoryInventories
	AS
SELECT
	CategoryName AS CategoryName, 
	FORMAT(InventoryDate, 'Y', 'en-US') AS InventoryDate,
	SUM([Count]) AS TotalInventoryCount
FROM vCategories 
	AS C
JOIN vProducts 
	AS P
ON C.CategoryID = P.CategoryID
JOIN vInventories 
	AS I
ON P.ProductID = I.ProductID
GROUP BY C.CategoryName,  InventoryDate;
GO

--Alter view to order by CategoryName, InventoryDate
ALTER VIEW vCategoryInventories
	AS	
SELECT TOP 10000
	CategoryName = CategoryName, 
	FORMAT(InventoryDate, 'Y', 'en-US') AS InventoryDate,
	SUM([Count]) AS TotalInventoryCount
FROM vCategories 
	AS C
JOIN vProducts 
	AS P
ON C.CategoryID = P.CategoryID
JOIN vInventories 
	AS I
ON P.ProductID = I.ProductID
GROUP BY C.CategoryName,  InventoryDate
ORDER BY CategoryName, InventoryDate;
GO

-- <Put Your Code Here> --

-- Check that it works: Select * From vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --
--Get all from vProductInventories view
SELECT * FROM vProductInventories;
GO

--Get all requested columns
SELECT
	ProductName, 
	InventoryDate,
	MonthCount = IIF([Count]=NULL, 0, [Count]),
	PrevMonthCount = LEAD([Count]) OVER(ORDER BY MONTH(InventoryDate))
FROM vProductInventories 
GO

--Create view
CREATE VIEW vProductInventoriesWithPreviousMonthCounts
	AS 
SELECT
	ProductName, 
	InventoryDate,
	MonthCount = IIF([Count]=NULL, 0, [Count]),
	PrevMonthCount = LEAD([Count]) OVER(ORDER BY MONTH(InventoryDate))
FROM vProductInventories;
GO 

--Check view was created
SELECT * FROM vProductInventoriesWithPreviousMonthCounts;
go

--Order results by Product and Date
ALTER VIEW vProductInventoriesWithPreviousMonthCounts
	AS 
SELECT TOP 10000
	ProductName, 
	InventoryDate,
	MonthCount = IsNull([Count], 0),
	PrevMonthCount = IIF(InventoryDate LIKE ('January%'), 0, IsNull(LAG([Count]) OVER(ORDER BY InventoryDate), 0))
FROM vProductInventories
ORDER BY ProductName, MONTH(InventoryDate);
GO 
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

--Get all columns from views
-- select all columns from the previous view
SELECT * FROM vProductInventoriesWithPreviousMonthCounts;
GO

-- Select columns that are requested
SELECT
	ProductName, 
	InventoryDate,
	MonthCount,
	PrevMonthCount
FROM vProductInventoriesWithPreviousMonthCounts;
GO 

-- Create a view and change prevMonth to KPI
--DROP VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
CREATE VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
	AS
SELECT
	ProductName, 
	InventoryDate,
	MonthCount,
	PrevMonthCount,
	PrevMonthCountKPI = CASE
		WHEN MonthCount > PrevMonthCount THEN 1
		WHEN MonthCount = PrevMonthCount THEN 0
		WHEN MonthCount < PrevMonthCount THEN -1
		END
FROM vProductInventoriesWithPreviousMonthCounts;
GO

--Check View 
SELECT * FROM vProductInventoriesWithPreviousMonthCountsWithKPIs;
GO

-- confirm order by product date
ALTER VIEW vProductInventoriesWithPreviousMonthCountsWithKPIs
	AS
SELECT TOP 10000
	ProductName, 
	InventoryDate,
	MonthCount,
	PrevMonthCount,
	PrevMonthCountKPI = CASE
		WHEN MonthCount > PrevMonthCount THEN 1
		WHEN MonthCount = PrevMonthCount THEN 0
		WHEN MonthCount < PrevMonthCount THEN -1
		END
FROM vProductInventoriesWithPreviousMonthCounts
ORDER BY ProductName, MONTH(InventoryDate);
GO

--Check View 
SELECT * FROM vProductInventoriesWithPreviousMonthCountsWithKPIs;
GO

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --
CREATE FUNCTION fProductInventoriesWithPreviousMonthCountsWithKPIs
(@num int)
RETURNS TABLE
	AS 
RETURN
	SELECT TOP 10000
		ProductName, 
		v1.InventoryDate,
		MonthCount,
		PrevMonthCount,
		PrevMonthCountKPI 
	FROM vProductInventoriesWithPreviousMonthCountsWithKPIs AS v1
	WHERE PrevMonthCountKPI = @num
	ORDER BY ProductName, MONTH(InventoryDate);
GO

-- EXEC fProductInventoriesWithPreviousMonthCountsWithKPIs @num = 1;

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/
go

/***************************************************************************************/