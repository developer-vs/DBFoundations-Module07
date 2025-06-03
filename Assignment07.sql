--*************************************************************************--
-- Title: Assignment07
-- Author: VladimirSemenovich
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2025-06-02,VladimirSemenovich,Created File
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_VladimirSemenovich')
	 Begin 
	  Alter Database [Assignment07DB_VladimirSemenovich] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_VladimirSemenovich;
	 End
	Create Database Assignment07DB_VladimirSemenovich;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_VladimirSemenovich;

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
 2) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------'
-- Question 1 (5% of pts):
-- Show a list of Product names and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the product name.

-- <Put Your Code Here> --

Select
    P.ProductName,
    Format(P.UnitPrice, 'C', 'en-US') As UnitPrice
 From
    dbo.vProducts As P
 Order By
    P.ProductName;
go

-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product.
-- Use a function to format the price as US dollars.
-- Order the result by the Category and Product.

-- <Put Your Code Here> --

Select
    C.CategoryName,
    P.ProductName,
    Format(P.UnitPrice, 'C', 'en-US') As UnitPrice
 From
    dbo.vCategories As C
    Inner Join dbo.vProducts As P
        On C.CategoryID = P.CategoryID
 Order By
    C.CategoryName,
    P.ProductName;
go

-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count.
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

Select
    P.ProductName,
    Format(I.InventoryDate, 'MMMM, yyyy') As InventoryDate,
    I.[Count] As InventoryCount
 From
    dbo.vProducts As P
    Inner Join dbo.vInventories As I
        On P.ProductID = I.ProductID
 Order By
    P.ProductName,
    I.InventoryDate;
go

-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories. 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count. 
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

Create View vProductInventories With SchemaBinding
 AS
  Select TOP 100 PERCENT
    P.ProductName,
    Format(I.InventoryDate, 'MMMM, yyyy') As InventoryDate,
    I.[Count] As InventoryCount
  From
    dbo.vProducts As P
    Inner Join dbo.vInventories As I
        On P.ProductID = I.ProductID
  Order By
    P.ProductName,
    I.InventoryDate;
go

-- Check that it works: Select * From vProductInventories;
Select * From dbo.vProductInventories;
go

-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.
-- Order the results by the Product and Date.

-- <Put Your Code Here> --

Create View dbo.vCategoryInventories With SchemaBinding
As
 Select TOP 100 PERCENT
    C.CategoryName,
    Format(DateFromParts(Year(I.InventoryDate), Month(I.InventoryDate), 1), 'MMMM, yyyy') As InventoryDate,
    Sum(I.[Count]) As TotalInventoryCountByCategory
  From
    dbo.vCategories As C
    Inner Join dbo.vProducts As P
        On C.CategoryID = P.CategoryID
    Inner Join dbo.vInventories As I
        On P.ProductID = I.ProductID
  Group By
    C.CategoryName,
    Year(I.InventoryDate),
    Month(I.InventoryDate)
  Order By
    C.CategoryName,
    Year(I.InventoryDate),
    Month(I.InventoryDate);
go

-- Check that it works: Select * From vCategoryInventories;
Select * From dbo.vCategoryInventories;
go

-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts. 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product and Date. 
-- This new view must use your vProductInventories view.

-- <Put Your Code Here> --

If Object_ID('dbo.vProductInventoriesWithPreviousMonthCounts') Is Not Null
 Begin
    Drop View dbo.vProductInventoriesWithPreviousMonthCounts;
 End
go

Create View dbo.vProductInventoriesWithPreviousMonthCounts
As
 With ProductDataWithSortableDate As
  (
    -- Step 1: Select from vProductInventories and create a real date
    -- for proper chronological sorting within the LAG function.
    -- The InventoryDate from vProductInventories is a string like 'January, 2017'.
    Select
        ProductName,
        InventoryDate, -- This is the formatted string 'MMMM, yyyy'
        InventoryCount,
        -- Convert the formatted date string back to a real date for sorting.
        -- '01 ' is prepended to make it a full date string that CONVERT can parse.
        Convert(Date, '01 ' + InventoryDate, 107) As ActualInventoryDate
        -- Style 107 is 'Mon dd, yyyy', so '01 January, 2017' works.
    From
        dbo.vProductInventories
  )
-- Step 2: Use LAG function to get the previous month's count
Select Top 100 Percent -- Required for ORDER BY in a view definition
    PD.ProductName,
    PD.InventoryDate, -- The original formatted date string
    PD.InventoryCount,
    -- LAG function to get the InventoryCount from the previous row
    -- within the same ProductName partition, ordered by the ActualInventoryDate.
    -- The third argument to LAG is the default value if there's no preceding row (e.g., first month).
    -- This handles the "set any January NULL counts to zero" for the first month entry.
    Lag(PD.InventoryCount, 1, 0) Over (Partition By PD.ProductName Order By PD.ActualInventoryDate) As PreviousMonthCount
From
    ProductDataWithSortableDate As PD
Order By
    PD.ProductName,
    PD.ActualInventoryDate; -- Order by the actual date for correct chronological sequence
go

-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCounts;
Select * From dbo.vProductInventoriesWithPreviousMonthCounts;
go

-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --

If Object_ID('dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs') Is Not Null
 Begin
    Drop View dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs;
 End
go

Create View dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
As
Select Top 100 Percent
    V.ProductName,
    V.InventoryDate, -- This is the 'MMMM, yyyy' string from the source view
    V.InventoryCount,
    V.PreviousMonthCount,
    Case
        When V.InventoryCount > V.PreviousMonthCount Then 1
        When V.InventoryCount < V.PreviousMonthCount Then -1
        Else 0 -- Covers V.InventoryCount = V.PreviousMonthCount
    End As CountKPI
From
    dbo.vProductInventoriesWithPreviousMonthCounts As V
Order By
    V.ProductName,
    Convert(Date, '01 ' + V.InventoryDate, 107); -- Convert string date back to a real date for correct chronological ordering
go

-- Important: This new view must use your vProductInventoriesWithPreviousMonthCounts view!
-- Check that it works: Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
Select * From dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs;
go

-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view.
-- Varify that the results are ordered by the Product and Date.

-- <Put Your Code Here> --

If Object_ID('dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs') Is Not Null
 Begin
  Drop Function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs;
 End
go

Create Function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs
(
  @KPIFilterValue Int -- Input parameter to filter by a specific KPI value (1, 0, or -1)
)
Returns Table
As
Return
(
  Select
    V.ProductName,
    V.InventoryDate,
    V.InventoryCount,
    V.PreviousMonthCount,
    V.CountKPI -- This is the KPI (1, 0, or -1) derived in the view
  From
    dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs As V
  Where
    V.CountKPI = @KPIFilterValue -- Filter results based on the input KPI value
);
go

-- Verification and example usage:
Print '------------------------------------------------------------------------------------';
Print '-- Verifying fProductInventoriesWithPreviousMonthCountsWithKPIs UDF';
Print '------------------------------------------------------------------------------------';
Print '';

Print '--- Showing Products with Increased Inventory (KPI = 1) ---';
Select
    ProductName,
    InventoryDate,
    InventoryCount,
    PreviousMonthCount,
    CountKPI
From
    dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(1) -- Calling UDF for KPI = 1
Order By
    ProductName,
    Convert(Date, '01 ' + InventoryDate, 107); -- Order by Product and actual Date
go

Print '--- Showing Products with Unchanged Inventory (KPI = 0) ---';
Select
    ProductName,
    InventoryDate,
    InventoryCount,
    PreviousMonthCount,
    CountKPI
From
    dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(0) -- Calling UDF for KPI = 0
Order By
    ProductName,
    Convert(Date, '01 ' + InventoryDate, 107); -- Order by Product and actual Date
go

Print '--- Showing Products with Decreased Inventory (KPI = -1) ---';
Select
    ProductName,
    InventoryDate,
    InventoryCount,
    PreviousMonthCount,
    CountKPI
From
    dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(-1) -- Calling UDF for KPI = -1
Order By
    ProductName,
    Convert(Date, '01 ' + InventoryDate, 107); -- Order by Product and actual Date
go

/* Check that it works:
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
*/

-- Showing results for KPI = 1 (Increased inventory)
Select
    ProductName,
    InventoryDate,
    InventoryCount,
    PreviousMonthCount,
    CountKPI
From
    dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(1)
Order By
    ProductName,
    Convert(Date, '01 ' + InventoryDate, 107); -- Ensures consistent ordering for verification
go

-- Showing results for KPI = 0 (Unchanged inventory)
Select
    ProductName,
    InventoryDate,
    InventoryCount,
    PreviousMonthCount,
    CountKPI
From
    dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(0)
Order By
    ProductName,
    Convert(Date, '01 ' + InventoryDate, 107); -- Ensures consistent ordering for verification
go

-- Showing results for KPI = -1 (Decreased inventory)
Select
    ProductName,
    InventoryDate,
    InventoryCount,
    PreviousMonthCount,
    CountKPI
From
    dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(-1)
Order By
    ProductName,
    Convert(Date, '01 ' + InventoryDate, 107); -- Ensures consistent ordering for verification
go

/***************************************************************************************/