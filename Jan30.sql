USE AdventureWorks2012

/*
Use the INTERSECT operator to create a query that finds employees who are also Salespeople. Write a second query to 
achieve the same result with a JOIN.  Use the Query Execution Plan in SSMS to compare the performance of the two.
*/

SELECT BusinessEntityID FROM HumanResources.Employee
INTERSECT
SELECT BusinessEntityID FROM Sales.SalesPerson

SELECT E.BusinessEntityID
FROM HumanResources.Employee E
INNER JOIN Sales.SalesPerson S
ON S.BusinessEntityID = E.BusinessEntityID

--Their performance is exactly the same in every way.

GO



/*
Write the queries necessary to insert yourself into AdventureWorks as a SalesPerson.  You started with the company 
on 1/1/2016 and spent your first year in the Marketing department. On 1/1/2017, you transferred into Sales. Include 
department history and pay history.  Give yourself a Sales Territory and Sales Quota records for January, April, 
July and October of 2017.  Arrange the INSERT statements so that you can run them as a single batch and enclose them 
in a transaction.
*/

--4 = Marketing, 3 = Sales

BEGIN TRAN
INSERT Person.BusinessEntity (ModifiedDate)
VALUES (GETDATE())
DECLARE @MyID INT = (SELECT TOP 1 SCOPE_IDENTITY() FROM Person.BusinessEntity)
INSERT Person.Person
VALUES (@MyID, 'SP', 0, 'Mr.', 'Zachary', 'Aaron', 'Babcock', NULL, 0, NULL, NULL, NEWID(), GETDATE())

INSERT HumanResources.Employee (BusinessEntityID, NationalIDNumber, LoginID, JobTitle, BirthDate, MaritalStatus, Gender, HireDate, SalariedFlag, VacationHours, SickLeaveHours, CurrentFlag)
VALUES (@MyID, 'LOL8675309LOL', 'adventure-works\zack0', 'Sales Representative', '07-25-1996', 'S', 'M', '01-01-2016', 1, 12, 34, 1)

INSERT HumanResources.EmployeeDepartmentHistory
VALUES (@MyID, 4, 1, '01-01-2016', '01-01-2017', GETDATE())
,(@MyID, 3, 1, '01-01-2017', NULL, GETDATE())

INSERT HumanResources.EmployeePayHistory
VALUES (@MyID, '01-01-2016', 13.4615, 2, GETDATE()),
(@MyID, '01-01-2017', 23.0769, 2, GETDATE())


INSERT Sales.SalesPerson
VALUES (@MyID, 5, 250000, 450, 0.012, 692193.4595, 0.00, NEWID(), GETDATE())

INSERT Sales.SalesPersonQuotaHistory
VALUES (@MyID, '01-01-2017', 102000, NEWID(), GETDATE())
,(@MyID, '04-01-2017', 145000, NEWID(), GETDATE())
,(@MyID, '07-01-2017', 187500, NEWID(), GETDATE())
,(@MyID, '10-01-2017', 210000, NEWID(), GETDATE())

INSERT Person.[Address] (AddressLine1, City, PostalCode, StateProvinceID)
VALUES ('4117 SW 49th Ter.', 'Ocala', '34474', 15)

INSERT Person.BusinessEntityAddress (BusinessEntityID, AddressID, AddressTypeID)
VALUES(@MyID, (SELECT TOP 1 SCOPE_IDENTITY() FROM Person.[Address]), 2)

COMMIT TRAN
GO

/*
Write code to create a VendorIssues table under the Purchasing schema with the following fields: 
ReportID (Primary Key, IDENTITY), PurchaseOrderID, EntryDate, IssueDetails (VARCHAR), VendorResponse (VARCHAR), 
Resolved (BIT).  Include a foreign key to the PurchaseOrderHeader table.  Use SET IDENTITY_INSERT to add a field with a 
ReportID of 5.  Turn IDENTITY_INSERT off and then add five more rows for random purchase orders. 
Document the values created for the ReportID field.
*/

CREATE TABLE [Purchasing].[VendorIssues]
(
ReportID INT IDENTITY(1,1),
PurchaseOrderID INT NOT NULL,
EntryDate DATE NOT NULL,
IssueDetails VARCHAR(MAX) NULL,
VendorResponse VARCHAR(MAX) NULL,
Resolved BIT NOT NULL
CONSTRAINT PK_ReportID PRIMARY KEY (ReportID),
CONSTRAINT FK_VendorIssues_PurchaseHeader FOREIGN KEY (PurchaseOrderID) REFERENCES Purchasing.PurchaseOrderHeader(PurchaseOrderID)
)

SET IDENTITY_INSERT Purchasing.VendorIssues ON
INSERT Purchasing.VendorIssues(ReportID, PurchaseOrderID,EntryDate, Resolved)
VALUES (5, 4003, '06-26-2008', 1)
SET IDENTITY_INSERT Purchasing.VendorIssues OFF

INSERT Purchasing.VendorIssues (PurchaseOrderID, EntryDate, Resolved)
VALUES ( 3817, '08-24-2008', 0)

INSERT Purchasing.VendorIssues (PurchaseOrderID, EntryDate, Resolved)
VALUES ( 3868, '08-27-2008', 1)

INSERT Purchasing.VendorIssues (PurchaseOrderID, EntryDate, Resolved)
VALUES ( 3873, '09-01-2008', 1)

INSERT Purchasing.VendorIssues (PurchaseOrderID, EntryDate, Resolved)
VALUES ( 3940, '09-02-2008', 0)

INSERT Purchasing.VendorIssues (PurchaseOrderID, EntryDate, Resolved)
VALUES ( 3817, '08-24-2008', 1)

--The values of the ReportID resume after the forced value of 5, so there is no 1, 2, 3, or 4.

GO


/*
Create a view to return a mailing list for ** current ** salespeople. Include Title (from Person table),
first, last and middle names, e-mail address, phone number and complete address information including 
country.  Use the WITH CHECK OPTION clause
*/


CREATE VIEW CurrentSPMailList
AS

SELECT SP.BusinessEntityID, P.Title, P.FirstName, P.LastName, P.MiddleName, EA.EmailAddress, PP.PhoneNumber, A.AddressLine1, A.AddressLine2, A.City, A.PostalCode [Postal Code], STP.Name [State / Province], CR.Name [Country], E.CurrentFlag
FROM Sales.SalesPerson SP
INNER JOIN Person.Person P
ON P.BusinessEntityID = SP.BusinessEntityID
INNER JOIN HumanResources.Employee E
ON E.BusinessEntityID = SP.BusinessEntityID
LEFT JOIN Person.EmailAddress EA
ON EA.BusinessEntityID = SP.BusinessEntityID
LEFT JOIN Person.BusinessEntityAddress BEA
ON BEA.BusinessEntityID = SP.BusinessEntityID
LEFT JOIN Person.[Address] A
ON A.AddressID = BEA.AddressID
LEFT JOIN Person.PersonPhone PP
ON PP.BusinessEntityID = SP.BusinessEntityID
LEFT JOIN Person.StateProvince STP
ON STP.StateProvinceID = A.StateProvinceID
LEFT JOIN Person.CountryRegion CR
ON CR.CountryRegionCode = STP.CountryRegionCode
WHERE E.CurrentFlag <> 0

WITH CHECK OPTION

GO

/*
Use the mailing list you created in the last step in an update query to change a salesperson's current flag in the 
Employee table to false. Document the result.
*/

UPDATE CurrentSPMailList
SET CurrentFlag = 0
WHERE FirstName = 'Zachary'

--The update failed due to the WITH CHECK OPTION clause.

/*
Write an ALTER TABLE statement to add the Title, FirstName, LastName and MiddleName fields from 
Person.Person to HumanResources.Employee. Then write an UPDATE statement that will copy the values 
from Person to Employee based on BusinessEntityID.
*/

ALTER TABLE HumanResources.Employee

ADD Title NVARCHAR(8),
FirstName NVARCHAR(50) NOT NULL,
MiddleName NVARCHAR(50),
LastName NVARCHAR(50) NOT NULL

GO

UPDATE HumanResources.Employee 
SET Title = P.Title, FirstName = P.FirstName, MiddleName = P.MiddleName, LastName = P.LastName
FROM Person.Person P
WHERE HumanResources.Employee.BusinessEntityID = P.BusinessEntityID


GO

/*
Under the HumanResources schema, create a new EmployeeAddresses table that will hold the 
BusinessEntityID, two address lines, City, State, ZIP and Country. Create the appropriate foreign 
key to HumanResources.Employees. Write a single INSERT statement that will fill the new table from 
the other tables under the Person schema.
*/

CREATE TABLE [HumanResources].[EmployeeAddresses]
(
BusinessEntityID INT,
AddressLine1 NVARCHAR(60) NOT NULL,
AddressLine2 NVARCHAR(60) NULL,
City NVARCHAR(30) NOT NULL,
StateProvince NVARCHAR(50) NULL,
ZIPCode NVARCHAR(15) NOT NULL,
Country NVARCHAR(50) NOT NULL
CONSTRAINT PK_EmpAddressID PRIMARY KEY (BusinessEntityID),
CONSTRAINT FK_EmployeeAddresses_Employees FOREIGN KEY (BusinessEntityID) REFERENCES HumanResources.Employee(BusinessEntityID)
)

INSERT INTO HumanResources.EmployeeAddresses (BusinessEntityID, AddressLine1, AddressLine2, City, StateProvince, ZIPCode, Country)
SELECT E.BusinessEntityID, A.AddressLine1, A.AddressLine2, A.City, SP.Name, A.PostalCode, CR.Name
FROM HumanResources.Employee E
INNER JOIN Person.BusinessEntityAddress BEA
ON BEA.BusinessEntityID = E.BusinessEntityID
INNER JOIN Person.[Address] A
ON A.AddressID = BEA.AddressID
INNER JOIN Person.StateProvince SP
ON SP.StateProvinceID = A.StateProvinceID
INNER JOIN Person.CountryRegion CR
ON CR.CountryRegionCode = SP.CountryRegionCode

